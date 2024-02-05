main :: () {
    context.logger = my_logger;
    context.logger_data = null;
    //context.log_level = .VERBOSE;

    args : []string = get_command_line_arguments();
    defer array_free(args);

    if args.count != 1 && args.count != 3 {
        log_error("Expected zero arguments or two arguments, the (x,y) window offset.");
        return;
    }

    window_x, window_y := 50, 50;
    if args.count == 3 {
        success := false;
        window_x, success, _ = to_integer(args[1]);
        if !success { log_error("Unexpected window_x argument, got %", window_x); return; }
        window_y, success, _ = to_integer(args[2]);
        if !success { log_error("Unexpected window_y argument, got %", window_y); return; }
    }

    path := path_strip_filename(System.get_path_of_running_executable());
    data_folder = join(path, "data");
    log_verbose("data_folder is '%'", data_folder);

    last_time = seconds_since_init();

    #if OS == .WINDOWS {
        Windows :: #import "Windows";
        Windows.SetProcessDPIAware();

        // Windows is very bad at thread-switching by default unless you do this. Sad.
        Windows.timeBeginPeriod(1);
    }

    window_height = WINDOW_HEIGHT_INITIAL;
    window_width = WINDOW_WIDTH_INITIAL;

    window = create_window(window_name="Pong", width=window_width, height=window_height, window_x=window_x, window_y=window_y);
    Simp.set_render_target(window);

    if !Enet.initialize() {
        log_error("Failed to initialize enet");
        return;
    }
    defer Enet.deinitialize();

    init_sounds(window);
    init_fonts();
    init_textures();
    UI.ui_init();

    // Get info about the host this program is running on
    init_host_info();

    // So that we have consistent memory handling after these strings are user-modified, we heap-allocate them
    server_address = ipv4_to_string(host_info.ipv4);
    server_port_string = copy_string(tprint("%", DEFAULT_PORT));

    // Don't update things that don't need updating e.g., sound stuff if we are a server but not a client
    while !game_quitting {
        reset_temporary_storage();

        current_frame += 1;
        current_time = seconds_since_init();
        current_dt = cast(float) (current_time - last_time);

        current_dt *= time_factor;

        if current_dt > DT_MAX current_dt = DT_MAX;
        last_time = current_time;

        update_window_events();

        for get_window_resizes() {
            Simp.update_window(it.window);

            if it.window == window {
                should_reinit := (it.width != window_width) || (it.height != window_height);

                window_width  = it.width;
                window_height = it.height;

                if should_reinit init_fonts();  // Resize the font for the new window size.
            }
        }

        Sound.update(current_dt);

        is_network_game := host_type == .CLIENT || host_type == .SERVER;
        if is_network_game {
            read_network_events_this_frame();

            // Handle network player disconnects, do this last so we don't try send/recieve from released peers
            for event : network_events_this_frame {
                if event.type == {
                case .DISCONNECT_TIMEOUT; #through;
                case .DISCONNECT;
                    deinit_game();
                    break; // @Think Is it ok to not handle anything else?
                }
            }
        }

        handle_inputs();

        if game_mode == .PAUSED {
            // draw game state
            render_one_frame();

            _, _, width, height := get_dimensions(window, true);
            UI.ui_per_frame_update(window, width, height, current_time);

            if game_menu == {
            case .PAUSE_MENU;
                pause_menu();
            case .GAME_OVER_MENU;
                game_over_menu();
            case.SETTINGS_MENU;
                settings_menu();
            case;
                assert(false, tprint("% should only be reachable from the call in menu.jai", game_menu));
            }

            draw_cursor();
        } else if game_mode == .PLAYING {

            // debug_explosion_animation();

            if esc_pressed {
                // @Cleanup Is this correct? What even is the QUIT event?
                game_menu = .PAUSE_MENU;
                game_mode = .PAUSED;
            }

            // Update the game state
            if host_type == {
            case .LOCAL;

                player1.left = xx input1.left_down;
                player1.right = xx input1.right_down;
                player1.down = xx input1.down_down;
                player1.up = xx input1.up_down;
                player1.power1 = xx input1.power1_down;
                player1.power2 = xx input1.power2_down;

                if #complete player_count == {
                case .One_Player;

                    compute_ai_inputs(*player2);

                case .Two_Player;
                    player2.left = xx input2.left_down;
                    player2.right = xx input2.right_down;
                    player2.down = xx input2.down_down;
                    player2.up = xx input2.up_down;
                    player2.power1 = xx input2.power1_down;
                    player2.power2 = xx input2.power2_down;
                }

                simulate();

            case .SERVER;

                player1.left = xx input1.left_down;
                player1.right = xx input1.right_down;
                player1.down = xx input1.down_down;
                player1.up = xx input1.up_down;
                player1.power1 = xx input1.power1_down;
                player1.power2 = xx input1.power2_down;

                input, received := receive_input();
                if received {
                    player2.left = xx input.left_down;
                    player2.right = xx input.right_down;
                    player2.down = xx input.down_down;
                    player2.up = xx input.up_down;
                    player2.power1 = xx input.power1_down;
                    player2.power2 = xx input.power2_down;
                }

                simulate();
                send_state(player2, get_game_state());

            case .CLIENT;

                // Note: Send input1 here since we would rather use those controls on the client computer
                send_input(input1);

                game_state, received := receive_state();
                if received {
                    set_game_state(game_state);
                }
            }

            // Debug/inspect enet
            //debug_network_game();

            // Draw game state
            render_one_frame();

        } else {
            menu();
        }

        Simp.swap_buffers(window);

        // memory_visualizer_per_frame_update();
    }

    // Notify peers to cleanly disconnect if we quit the game
    if host_type == .CLIENT {
        deinit_client();
    }
    if host_type == .SERVER {
        deinit_server();
    }
}

#scope_file

handle_inputs :: () {
    esc_pressed = false;
    input1.player_index = .P1;
    input2.player_index = .P2;
    for event : events_this_frame {
        if (event.type == .KEYBOARD && event.key_code == .ESCAPE && event.key_pressed) {
            esc_pressed = true;
        }

        if event.type == .QUIT {
            game_quitting = true;
        }

        if event.type == .KEYBOARD {
            if event.key_code == {

            case #char "I";
                input1.up_down = xx event.key_pressed;
            case #char "J";
                input1.left_down = xx event.key_pressed;
            case #char "K";
                input1.down_down = xx event.key_pressed;
            case #char "L";
                input1.right_down = xx event.key_pressed;
            case #char "U";
                input1.power1_down = xx event.key_pressed;
            case #char "O";
                input1.power2_down = xx event.key_pressed;

            case #char "W";
                input2.up_down = xx event.key_pressed;
            case #char "A";
                input2.left_down = xx event.key_pressed;
            case #char "S";
                input2.down_down = xx event.key_pressed;
            case #char "D";
                input2.right_down = xx event.key_pressed;
            case #char "Q";
                input2.power1_down = xx event.key_pressed;
            case #char "E";
                input2.power2_down = xx event.key_pressed;
            }
        }

        UI.getrect_handle_event(event);
    }
}

init_fonts :: () {
    // So that we can load our font, set to path of running executable.
    // @Incomplete: Pack a default font into Simp.
    path := path_strip_filename(System.get_path_of_running_executable());

    set_working_directory(path);
    pixel_height := window_height / 24;

    // font_name := "Anonymous Pro.ttf";
    font_name := "Skytree_by_MONTAGNA.ttf";

    // @Cleanup: Don't have path + name be separate.
    font = Simp.get_font_at_size("data", font_name, pixel_height);
    assert(font != null);

    version_font = Simp.get_font_at_size("data", font_name, pixel_height / 2);
    assert(version_font != null);

    game_over_font = Simp.get_font_at_size("data", font_name, 2 * pixel_height);
    assert(game_over_font != null);
}

init_textures :: () {
    make_texture :: (name: string) -> Texture, bool {
        filename := tprint("%/%", data_folder, name);

        result: Texture;
        success := Simp.texture_load_from_file(*result, filename);

        return result, success;
    }

    sky_map = make_texture("sky.png");
    menu_map = make_texture("pong2.png");
    okpong_map = make_texture("okPONG2.png");
    heart_map = make_texture("hearts.png");
    power_up_restore_all_life = make_texture("shining-heart.png");
}

init_sounds :: (window : *Window_Type) {
    // A shipping game would have some kind of asset catalog where you would
    // use handles (or maybe just the string name) when you play sound effects.

    // @Cleanup Rename the sounds
    sound_start_game = Sound.load_audio_file(tprint("%/start_game.wav", data_folder));
    sound_collision1 = Sound.load_audio_file(tprint("%/collision1.wav", data_folder));
    sound_collision2 = Sound.load_audio_file(tprint("%/collision2.wav", data_folder));
    sound_ball_explode = Sound.load_audio_file(tprint("%/mixkit-short-explosion-1694.wav", data_folder));

    success := Sound.sound_player_init(.{});
    assert(success);

}

#scope_export

// These are in jai/modules/
#import "Basic";
#import "String";
#import "Input";
#import "Wav_File";
#import "stb_vorbis";
#import "Thread";
#import "Window_Creation";
#import "Math";
#import "Random";
#import "File";
Sound :: #import "Sound_Player";
Socket :: #import "Socket";
UI :: #import "GetRect_LeftHanded";
System :: #import "System";
Simp :: #import "Simp";
Texture :: Simp.Texture;

#if OS == .WINDOWS #import "Windows";

// These are in ./modules/
Enet :: #import "enet";
#import "JaiBox2D";

// These are in ./source/
#load "Box2D_DebugDraw_Simp.jai";
#load "globals.jai";
#load "networking.jai";
#load "menu.jai";
#load "rendering.jai";
#load "rendering_utils.jai";
#load "simulate.jai";
#load "gameplay.jai";
#load "physics.jai";
#load "mesh.jai";
#load "carpet.jai";
#load "numeric.jai";
#load "debug.jai";
#load "ai.jai";