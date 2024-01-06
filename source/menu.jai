menu :: () {

    esc_pressed : bool;
    for event : events_this_frame {
        if event.type == .QUIT || (event.type == .KEYBOARD && event.key_code == .ESCAPE && event.key_pressed) {
            esc_pressed = true;
        }

        UI.getrect_handle_event(event);
    }

    Simp.clear_render_target(1, 0, 0, 1);

    draw_menu_background();

    x, y, width, height := get_dimensions(window, true);
    UI.ui_per_frame_update(window, window_width, window_height, current_time);

    using ui_state := make_ui_state();

    button_theme := ui_theme.button_theme;
    button_theme.font = font;
    button_theme.enable_variable_frame_thickness = true;
    button_theme.label_theme.alignment = .Center;

    text_theme := ui_theme.text_input_theme;
    text_theme.font = font;

    dropdown_theme := *ui_theme.dropdown_theme;

    // The 'dropdown' function causes a popup to be created, which
    // gets rendered at the end of the frame when we call draw_popups().
    // The theme and choices array must remain valid until after that time!
    // The 'current_theme' pointer also needs to remain pointing at valid memory
    // until after that time, as that is when it will be changed.

    ball_shape_choices : [#run get_enum_count(Ball_Shape)]string;
    for 0..get_enum_count(Ball_Shape)-1 {
        text := tprint("%", cast(Ball_Shape)it);
        for 0..text.count-1 {
            if text[it] == #char "_"  text[it] = #char " ";  // Convert underscores to spaces!
        }
        ball_shape_choices[it] = text;
    }

    paddle_shape_choices : [#run get_enum_count(Paddle_Shape)]string;
    for 0..get_enum_count(Paddle_Shape)-1 {
        text := tprint("%", cast(Paddle_Shape)it);
        for 0..text.count-1 {
            if text[it] == #char "_"  text[it] = #char " ";  // Convert underscores to spaces!
        }
        paddle_shape_choices[it] = text;
    }

    level_choices : [#run get_enum_count(Level_Id)]string;
    for 0..get_enum_count(Level_Id)-1 {
        text := tprint("%", cast(Level_Id)it);
        for 0..text.count-1 {
            if text[it] == #char "_"  text[it] = #char " ";  // Convert underscores to spaces!
        }
        level_choices[it] = text;
    }


    if #complete game_menu == {
    case .MAIN_MENU;

        cursor := CenteredCursor(5.2*k.y);

        r := NextRect(3.25*k.x, .75*k.y);
        _, _, released := UI.button(r, "Play Local Game", *button_theme);
        if released {
            game_menu = .PLAY_LOCAL_GAME_MENU;
        }

        r = NextRect(3.25*k.x, .75*k.y);
        _, _, released = UI.button(r, "Join Network Game", *button_theme);
        if released {
            game_menu = .JOIN_NETWORK_GAME_MENU;
        }

        r = NextRect(3.25*k.x, .75*k.y);
        _, _, released = UI.button(r, "Host Network Game", *button_theme);
        if released {
            game_menu = .HOST_NETWORK_GAME_MENU;
        }

        r = NextRect(1.75*k.x, .75*k.y);
        _, _, released = UI.button(r, "Settings", *button_theme);
        if released {
            game_menu = .SETTINGS_MENU;
        }

        r = NextRect(1.25*k.x, .75*k.y);
        _, _, released = UI.button(r, "Quit", *button_theme);
        if released {
            game_quitting = true;
        }

    case .PLAY_LOCAL_GAME_MENU;

        cursor := CenteredCursor(5.2*k.y);

        r := NextRect(2.*k.x, .5*k.y);
        UI.dropdown(r, ball_shape_choices, *current_ball_shape, dropdown_theme);

        r = NextRect(2.*k.x, .5*k.y);
        UI.dropdown(r, paddle_shape_choices, *current_paddle_shape, dropdown_theme);

        r = NextRect(2.*k.x, .5*k.y);
        UI.dropdown(r, level_choices, *current_level, dropdown_theme);

        // r = NextRect(2.*k.x, .5*k.y);
        // UI.slider(r, *friction, 0., 1., .01, *ui_theme.slider_theme, prefix="F ");

        // r = NextRect(2.*k.x, .5*k.y);
        // UI.slider(r, *restitution, 0., 1.5, .01, *ui_theme.slider_theme, prefix="R ");

        l:, r = NextRect2(1.25*k.x, .75*k.y);
        _, _, released := UI.button(l, "Back", *button_theme);
        if released || esc_pressed {
            game_menu = .MAIN_MENU;
        }
        _, _, released = UI.button(r, "Play", *button_theme);
        if released {
            init_game(host_info.ipv4, host_info.ipv4);
        }

    case .PAUSE_MENU;

        cursor := CenteredCursor(5.2*k.y);

        l, r := NextRect2(1.25*k.x, .75*k.y);
        _, _, released := UI.button(r, "Resume", *button_theme);
        if released {
            game_mode = .PLAYING;
        }
        _, _, released = UI.button(l, "Leave", *button_theme);
        if released {
            game_menu = .MAIN_MENU;
            deinit_game();
        }

    case .JOIN_NETWORK_GAME_MENU;

        cursor := CenteredCursor(5.2*k.y);

        r := NextRect(4*k.x, .75*k.y);
        text_theme.alignment = .Center;
        action, new_server_address := UI.text_input(r, server_address, *text_theme);
        if action & .ENTERED {
            modify_string(*server_address, new_server_address);
        }

        r = NextRect(4*k.x, .75*k.y);
        text_theme.alignment = .Center;
        action=, new_server_port_string := UI.text_input(r, server_port_string, *text_theme);
        if action & .ENTERED {
            port, success, _ := to_integer(new_server_port_string);
            if success && (port >= 1024 && port <= 49151) {
                modify_string(*server_port_string, new_server_port_string);
                server_port = cast(u16)port;
            } else {
                // From: https://www.ibm.com/docs/en/ztpf/2023?topic=overview-port-numbers
                // Port numbers [1024,  49151] are reserved for user server applications.
                // Port numbers [49152, 65535] are reserved for clients.
                log_error("Enter a valid port integer in the range [1024, 49151], got %", server_port);
            }
        }

        l:, r = NextRect2(1.25*k.x, .75*k.y);
        _, _, released := UI.button(l, "Back", *button_theme);
        if released || esc_pressed {
            game_menu = .MAIN_MENU;
        }
        _, _, released = UI.button(r, "Join", *button_theme);
        if released {
            game_menu_if_waiting_cancelled = .JOIN_NETWORK_GAME_MENU;
            game_menu = .WAITING_FOR_PLAYERS_MENU;
        }

    case .HOST_NETWORK_GAME_MENU;

        cursor := CenteredCursor(5.2*k.y);

        // @Cleanup This should not be editable
        // @CompilerBug When the program first starts this can be edited, but after going to the Join menu and back here it can't be
        r := NextRect(4*k.x, .75*k.y);
        text_theme.alignment = .Center;
        UI.text_input(r, ipv4_to_string(host_info.ipv4,,temp), *text_theme);

        r = NextRect(4*k.x, .75*k.y);
        text_theme.alignment = .Center;
        action, new_host_port_string := UI.text_input(r, host_port_string, *text_theme);
        if action & .ENTERED {
            port, success, _ := to_integer(new_host_port_string);
            if success && (port >= 1024 && port <= 49151) {
                modify_string(*host_port_string, new_host_port_string);
                host_info.port = cast(u16)port;
            } else {
                // From: https://www.ibm.com/docs/en/ztpf/2023?topic=overview-port-numbers
                // Port numbers [1024,  49151] are reserved for user server applications.
                // Port numbers [49152, 65535] are reserved for clients.
                log_error("Enter a valid port integer in the range [1024, 49151], got %", server_port);
            }
        }

        l:, r = NextRect2(1.25*k.x, .75*k.y);
        _, _, released := UI.button(l, "Back", *button_theme);
        if released || esc_pressed {
            game_menu = .MAIN_MENU;
        }
        _, _, released = UI.button(r, "Host", *button_theme);
        if released {
            game_menu_if_waiting_cancelled = .HOST_NETWORK_GAME_MENU;
            game_menu = .WAITING_FOR_PLAYERS_MENU;

            host_socket = init_socket(host_info.ipv4, host_info.port);
            // nocommit:
            server_address = ipv4_to_string(host_info.ipv4); // @Leak?
            server_port = host_info.port;
        }

    case .WAITING_FOR_PLAYERS_MENU;

        countdown(*connection_retry_countdown);
        remaining_time := connection_retry_countdown + connection_retry_count * INITIAL_CONNECTION_RETRY_COUNTDOWN;
        remaining_time_formatted := FormatFloat.{value=remaining_time, trailing_width=2, zero_removal=.NO};

        label_theme := ui_theme.label_theme;
        label_theme.text_color = .{0, 0, 0, 1};

        message : string;
        if game_menu_if_waiting_cancelled == .HOST_NETWORK_GAME_MENU {
            message = tprint("Waiting for Players... %s", remaining_time_formatted);
        } else {
            message = tprint("Connecting to Server... %s", remaining_time_formatted);
        }

        cursor := CenteredCursor(5*k.y);
        r := NextRect(5*k.x, .75*k.y);
        label_theme.alignment = .Left;
        UI.label(r, message, *label_theme);

        // Only send a connection request (implemented via a dummy Client_Input) when the countdown expires
        if connection_retry_countdown <= 0 {
            // Send a null input to the server
            input : Client_Input;
            send_input_to_server(input);
            connection_retry_countdown = INITIAL_CONNECTION_RETRY_COUNTDOWN;
            connection_retry_count -= 1;
        }

        connected := false;
        {
            // TODO Receive a game state from the server
        }

        if connected {
            connection_ipv4 : u32;
            if game_menu_if_waiting_cancelled == .HOST_NETWORK_GAME_MENU {
                client_ipv4 := connection_ipv4;
                init_game(host_info.ipv4, client_ipv4);
            } else if game_menu_if_waiting_cancelled == .JOIN_NETWORK_GAME_MENU {
                server_ipv4 := connection_ipv4;
                init_game(server_ipv4, host_info.ipv4);
            }

        } else {

            r = NextRect(1.25*k.x, .75*k.y);
            _, _, released := UI.button(r, "Cancel", *button_theme);
            if released || remaining_time <= 0 {
                game_menu = game_menu_if_waiting_cancelled;
                connection_retry_count = INITIAL_CONNECTION_RETRY_COUNT;
                connection_retry_countdown = INITIAL_CONNECTION_RETRY_COUNTDOWN;

                Socket.close_and_reset(*host_socket);
            }

        }

    case .SETTINGS_MENU;

        cursor := CenteredCursor(5.2*k.y);
        r := NextRect(1.25*k.x, .75*k.y);
        _, _, released := UI.button(r, "Back", *button_theme);
        if released || esc_pressed {
            game_menu = .MAIN_MENU;
        }
    }



    UI.draw_popups();  // This draws Subwindows as well. Used by dropdowns

    // Draw cursor
    {
        Simp.set_shader_for_color(true);

        v : [4]Vector2;

        mouse_x, mouse_y, _ := get_mouse_pointer_position();
        D :: 20;
        v[0] = .{cast(float) mouse_x + D/2, window_height - cast(float)mouse_y - D};
        v[1] = .{cast(float) mouse_x + D/2, window_height - cast(float)mouse_y - D/2};
        v[2] = .{cast(float) mouse_x + D,   window_height - cast(float)mouse_y - D/2};
        v[3] = .{cast(float) mouse_x,       window_height - cast(float)mouse_y};
        color := Vector4.{1,1,1,1};

        Simp.immediate_quad(v[0], v[1], v[2], v[3], color);
    }
}