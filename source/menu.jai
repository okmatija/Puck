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
            game_menu = .SERVE_NETWORK_GAME_MENU;
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
            host_type = .LOCAL;
            init_game();
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

            if host_type == .CLIENT {
                game_menu = .JOIN_NETWORK_GAME_MENU;
                deinit_client();
            } else if host_type == .SERVER {
                game_menu = .SERVE_NETWORK_GAME_MENU;
                deinit_server();
            } else {
                game_menu = .PLAY_LOCAL_GAME_MENU;
            }

            game_mode = .NOT_STARTED;
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
            game_menu = .CONNECTING_TO_SERVER_MENU;
            init_client(server_address, server_port);
        }

    case .SERVE_NETWORK_GAME_MENU;

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
            game_menu = .WAITING_FOR_PLAYERS_MENU;
            init_server();
        }

    case .CONNECTING_TO_SERVER_MENU;

        label_theme := ui_theme.label_theme;
        label_theme.text_color = .{0, 0, 0, 1};

        cursor := CenteredCursor(5*k.y);
        r := NextRect(5*k.x, .75*k.y);
        label_theme.alignment = .Left;
        // UI.label(r, tprint("Connecting to Server... (%s)", time_format(remaining_time)), *label_theme);
        UI.label(r, "Connecting to Server...", *label_theme);

        timed_out := false;
        for event : network_events_this_frame {
            if event.type == {
            case .CONNECT;
                init_game();
            case .DISCONNECT; #through;
            case .DISCONNECT_TIMEOUT;
                timed_out = true;
            }
        }

        r = NextRect(1.25*k.x, .75*k.y);
        _, _, released := UI.button(r, "Cancel", *button_theme);
        if timed_out || released {
            game_menu = .JOIN_NETWORK_GAME_MENU;
            deinit_client();
        }

    case .WAITING_FOR_PLAYERS_MENU;

        label_theme := ui_theme.label_theme;
        label_theme.text_color = .{0, 0, 0, 1};

        cursor := CenteredCursor(5*k.y);
        r := NextRect(5*k.x, .75*k.y);
        label_theme.alignment = .Center;
        UI.label(r, "Waiting for players...", *label_theme);

        timed_out := false;

        for event : network_events_this_frame {
            if event.type == {
            case .CONNECT;
                init_game();
            case .DISCONNECT; #through;
            case .DISCONNECT_TIMEOUT;
                timed_out = true;
            }
        }

        r = NextRect(1.25*k.x, .75*k.y);
        _, _, released := UI.button(r, "Cancel", *button_theme);
        if timed_out || released {
            game_menu = .SERVE_NETWORK_GAME_MENU;
            deinit_server();
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

    draw_cursor();

    // Draw cursor
}