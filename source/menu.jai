menu :: () {

    hide_cursor();

    {
        using color := PLAYER2_COLOR * .7;
        Simp.clear_render_target(x, y, z, w);
    }

    draw_menu_logo();

    _, _, width, height := get_dimensions(window, true);
    UI.ui_per_frame_update(window, width, height, current_time);

    if #complete game_menu == {
    case .MAIN_MENU;

        main_menu();

    case .PAUSE_MENU;

        // The pause menu should only be reachable via the call in main.jai
        assert(false, tprint("% should only be reachable from the call in main.jai", game_menu));
        pause_menu();

    case .SETTINGS_MENU;

        settings_menu();

    case .PLAY_LOCAL_GAME_MENU;

        play_local_game_menu();

    case .JOIN_NETWORK_GAME_MENU;

        join_network_game_menu();

    case .HOST_NETWORK_GAME_MENU;

        host_network_game_menu();

    case .CONNECTING_TO_SERVER_MENU;

        connecting_to_server_menu();

    case .WAITING_FOR_PLAYERS_MENU;

        waiting_for_players_menu();
    }


    text_w := Simp.prepare_text(version_font, PONG_VERSION);
    scale := 0.2;
    Simp.draw_prepared_text(version_font,
        10,
        version_font.character_height/2,
        .{1, 1, 1, 1});

    draw_cursor();
}



modify_string :: (ps: *string, new_value: string) {
    free(ps.*);
    ps.* = copy_string(new_value);
}

pause_menu :: () {
    using ui_state := make_ui_state();

    button_theme := ui_theme.button_theme;
    button_theme.font = font;
    button_theme.enable_variable_frame_thickness = true;
    button_theme.label_theme.alignment = .Center;

    cursor := CenteredCursor(5.2*k.y);
    l, r : UI.Rect;

    r = NextRect(1.75*k.x, .75*k.y);
    _, _, released := UI.button(r, "Settings", *button_theme);
    if released {
        settings_back_target_menu = .PAUSE_MENU;
        game_menu = .SETTINGS_MENU;
    }

    l, r = NextRect2(1.25*k.x, .75*k.y);
    _, _, released = UI.button(r, "Resume", *button_theme);
    if released || esc_pressed { // @Cleanup only allow esc here for debugging?
        game_mode = .PLAYING;
    }
    _, _, released = UI.button(l, "Leave", *button_theme);
    if released {
        deinit_game();
    }
}

settings_menu :: () {
    using ui_state := make_ui_state();

    button_theme := ui_theme.button_theme;
    button_theme.font = font;
    button_theme.enable_variable_frame_thickness = true;
    button_theme.label_theme.alignment = .Center;

    slider_theme := ui_theme.slider_theme;
    slider_theme.foreground.font = font;
    slider_theme.surface_style = .NUB;

    cursor := CenteredCursor(5.2*k.y);
    r : UI.Rect;

    r = NextRect(4*k.x, .75*k.y);
    UI.slider(r, *user_sfx_volume, 0.0, 1.0, 0.1, *slider_theme, "", " SFX volume");

    r = NextRect(1.25*k.x, .75*k.y);
    _, _, released := UI.button(r, "Back", *button_theme);
    if released || esc_pressed {
        game_menu = settings_back_target_menu;
    }
}

#scope_file

main_menu :: () {
    using ui_state := make_ui_state();

    button_theme := ui_theme.button_theme;
    button_theme.font = font;
    button_theme.enable_variable_frame_thickness = true;
    button_theme.label_theme.alignment = .Center;

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
        settings_back_target_menu = .MAIN_MENU;
        game_menu = .SETTINGS_MENU;
    }

    r = NextRect(1.25*k.x, .75*k.y);
    _, _, released = UI.button(r, "Quit", *button_theme);
    if released {
        game_quitting = true;
    }
}

play_local_game_menu :: () {

    using ui_state := make_ui_state();

    button_theme := ui_theme.button_theme;
    button_theme.font = font;
    button_theme.enable_variable_frame_thickness = true;
    button_theme.label_theme.alignment = .Center;

    label_theme := button_theme.label_theme;
    label_theme.alignment = .Left;

    dropdown_theme := *ui_theme.dropdown_theme;

    player_count_s32 := cast(s32)player_count;
    paddle_shape_s32 := cast(s32)paddle_shape;
    ball_shape_s32 := cast(s32)ball_shape;
    level_s32 := cast(s32)level_id;

    cursor := CenteredCursor(5.2*k.y);
    l, r : UI.Rect;

    l, r = NextRect2(2.2*k.x, .5*k.y);
    PlayerCountDropdown(l, r);

    l, r = NextRect2(2.2*k.x, .5*k.y);
    BallShapeDropdown(l, r);

    // @TODOO Player 1 and 2 paddle shapes
    l, r = NextRect2(2.2*k.x, .5*k.y);
    PaddleShapeDropdown(l, r);

    // l, r = NextRect2(2.2*k.x, .5*k.y);
    // PaddleShapeDropdown(l, r, "P2 Paddle Shape");

    l, r = NextRect2(2.2*k.x, .5*k.y);
    LevelDropdown(l, r);

    // r = NextRect(2.*k.x, .5*k.y);
    // UI.slider(r, *friction, 0., 1., .01, *ui_theme.slider_theme, prefix="F ");

    // r = NextRect(2.*k.x, .5*k.y);
    // UI.slider(r, *restitution, 0., 1.5, .01, *ui_theme.slider_theme, prefix="R ");

    l, r = NextRect2(1.25*k.x, .75*k.y);
    _, _, released := UI.button(l, "Back", *button_theme);
    if released || esc_pressed {
        game_menu = .MAIN_MENU;
    }
    _, _, released = UI.button(r, "Play", *button_theme);
    if released {
        host_type = .LOCAL;

        init_game_state : Init_Game_State;
        // @TODOO local play option to choose paddle shape
        init_game_state.p1_paddle_shape = paddle_shape;
        init_game_state.p2_paddle_shape = paddle_shape;
        init_game_state.ball_shape = ball_shape;
        init_game_state.level_id = level_id;
        init_game_state.player_count = player_count;
        init_game(init_game_state);
    }

    UI.draw_popups();  // This draws Subwindows as well. Used by dropdowns
    player_count = cast(Player_Count)player_count_s32;
    paddle_shape = cast(Paddle_Shape)paddle_shape_s32;
    ball_shape = cast(Ball_Shape)ball_shape_s32;
    level_id = cast(Level_Id)level_s32;
}

join_network_game_menu :: () {

    using ui_state := make_ui_state();

    button_theme := ui_theme.button_theme;
    button_theme.font = font;
    button_theme.enable_variable_frame_thickness = true;
    button_theme.label_theme.alignment = .Center;

    text_theme := ui_theme.text_input_theme;
    text_theme.font = font;

    label_theme := button_theme.label_theme;
    label_theme.alignment = .Left;

    dropdown_theme := *ui_theme.dropdown_theme;

    paddle_shape_s32 : s32 = cast(s32)paddle_shape;

    cursor := CenteredCursor(5.2*k.y);
    l, r : UI.Rect;

    r = NextRect(4*k.x, .75*k.y);
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

    l, r = NextRect2(2.2*k.x, .5*k.y);
    PaddleShapeDropdown(l, r);

    l, r = NextRect2(1.25*k.x, .75*k.y);
    _, _, released := UI.button(l, "Back", *button_theme);
    if released || esc_pressed {
        game_menu = .MAIN_MENU;
    }
    _, _, released = UI.button(r, "Join", *button_theme);
    if released {
        game_menu = .CONNECTING_TO_SERVER_MENU;
        init_client(server_address, server_port);
    }

    UI.draw_popups();  // This draws Subwindows as well. Used by dropdowns
    paddle_shape = cast(Paddle_Shape)paddle_shape_s32;
}

host_network_game_menu :: () {

    using ui_state := make_ui_state();

    button_theme := ui_theme.button_theme;
    button_theme.font = font;
    button_theme.enable_variable_frame_thickness = true;
    button_theme.label_theme.alignment = .Center;

    text_theme := ui_theme.text_input_theme;
    text_theme.font = font;

    label_theme := button_theme.label_theme;
    label_theme.alignment = .Left;

    dropdown_theme := *ui_theme.dropdown_theme;

    paddle_shape_s32 := cast(s32)paddle_shape;
    ball_shape_s32 := cast(s32)ball_shape;
    level_s32 := cast(s32)level_id;


    cursor := CenteredCursor(5.2*k.y);
    l, r : UI.Rect;

    // @Cleanup This should not be editable
    // @CompilerBug When the program first starts this can be edited, but after going to the Join menu and back here it can't be
    r = NextRect(4*k.x, .75*k.y);
    text_theme.alignment = .Center;
    UI.text_input(r, ipv4_to_string(host_info.ipv4,,temp), *text_theme);

    r = NextRect(4*k.x, .75*k.y);
    text_theme.alignment = .Center;
    action, new_server_port_string := UI.text_input(r, server_port_string, *text_theme);
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

    l, r = NextRect2(2.2*k.x, .5*k.y);
    BallShapeDropdown(l, r);

    l, r = NextRect2(2.2*k.x, .5*k.y);
    PaddleShapeDropdown(l, r);

    l, r = NextRect2(2.2*k.x, .5*k.y);
    LevelDropdown(l, r);

    l, r = NextRect2(1.25*k.x, .75*k.y);
    _, _, released := UI.button(l, "Back", *button_theme);
    if released || esc_pressed {
        game_menu = .MAIN_MENU;
    }
    _, _, released = UI.button(r, "Host", *button_theme);
    if released {
        game_menu = .WAITING_FOR_PLAYERS_MENU;
        init_server(server_port);
    }

    UI.draw_popups();  // This draws Subwindows as well. Used by dropdowns
    paddle_shape = cast(Paddle_Shape)paddle_shape_s32;
    ball_shape = cast(Ball_Shape)ball_shape_s32;
    level_id = cast(Level_Id)level_s32;
}


connecting_to_server_menu :: () {

    using ui_state := make_ui_state();

    button_theme := ui_theme.button_theme;
    button_theme.font = font;
    button_theme.enable_variable_frame_thickness = true;
    button_theme.label_theme.alignment = .Center;

    label_theme := ui_theme.label_theme;
    label_theme.text_color = WHITE;

    cursor := CenteredCursor(5*k.y);
    r := NextRect(5*k.x, .75*k.y);
    label_theme.alignment = .Left;
    // UI.label(r, tprint("Connecting to Server... (%s)", time_format(remaining_time)), *label_theme);
    UI.label(r, "Connecting to Server...", *label_theme);

    disconnect := false;
    for event : network_events_this_frame {
        if event.type == {
        case .CONNECT;
            log_verbose("Sending player paddle shape to server", flags=.VERBOSE_ONLY);
            packet := Enet.packet_create(*paddle_shape, .RELIABLE); // @Leak?
            Enet.peer_send(peer=client.server, channel_id=0, packet=packet);

        case .DISCONNECT; #through;
        case .DISCONNECT_TIMEOUT;
            disconnect = true;
            // @Think Can this happen?
        case .RECEIVE;
            defer Enet.packet_destroy(event.packet);
            assert(client.server.state == .CONNECTED);
            if event.packet.data_length == size_of(Init_Game_State) {
                init_game_state := cast(*Init_Game_State)event.packet.data;
                init_game(init_game_state.*);
            }
        }
    }

    r = NextRect(1.25*k.x, .75*k.y);
    _, _, released := UI.button(r, "Cancel", *button_theme);
    if disconnect || released || esc_pressed {
        game_menu = .JOIN_NETWORK_GAME_MENU;
        deinit_client();
    }
}

waiting_for_players_menu :: () {

    using ui_state := make_ui_state();

    button_theme := ui_theme.button_theme;
    button_theme.font = font;
    button_theme.enable_variable_frame_thickness = true;
    button_theme.label_theme.alignment = .Center;

    label_theme := ui_theme.label_theme;
    label_theme.text_color = WHITE;

    cursor := CenteredCursor(5*k.y);
    r := NextRect(5*k.x, .75*k.y);
    label_theme.alignment = .Center;
    UI.label(r, "Waiting for players...", *label_theme);

    server.init_game_state.p1_paddle_shape = paddle_shape;
    server.init_game_state.ball_shape = ball_shape;
    server.init_game_state.level_id = level_id;
    server.init_game_state.player_count = player_count;

    disconnect := false;
    for event : network_events_this_frame {
        if event.type == {
        case .RECEIVE;
            defer Enet.packet_destroy(event.packet);
            if event.packet.data_length == size_of(Paddle_Shape) {
                server.init_game_state.p2_paddle_shape = (cast(*Paddle_Shape)event.packet.data).*;
                server.init_game_state_ready = true;
            }

        case .CONNECT;
            // Do nothing
        case .DISCONNECT; #through;
        case .DISCONNECT_TIMEOUT;
            disconnect = true;
            // This could happen a previously connected player disconnects before the game started?
            log("Disconnected peer %", event.peer.data);
            //event.peer.data = null; // @Cleanup http://enet.bespin.org/Tutorial.html says we should do this?
        }
    }

    r = NextRect(1.25*k.x, .75*k.y);
    _, _, released := UI.button(r, "Cancel", *button_theme);
    if disconnect || released || esc_pressed {
        game_menu = .HOST_NETWORK_GAME_MENU;
        deinit_server();
    }

    if server.init_game_state_ready {
        server.init_game_state_ready = false; // Reset for the next time

        for * peer: server.host.peers {
            if peer.state == .CONNECTED {
                packet := Enet.packet_create(*server.init_game_state, .RELIABLE); // @Leak?
                Enet.peer_send(peer=peer, channel_id=0, packet=packet);
            }
        }

        init_game(server.init_game_state);
    }
}

// The 'dropdown' function causes a popup to be created, which
// gets rendered at the end of the frame when we call draw_popups().
// The theme and choices array must remain valid until after that time!
// The 'current_theme' pointer also needs to remain pointing at valid memory
// until after that time, as that is when it will be changed. The value is
// also changed in the draw_popups call!!
PaddleShapeDropdown :: (l : UI.Rect, r : UI.Rect, label := "Paddle Shape") #expand {
    UI.label(l, label, *`label_theme);
    UI.dropdown(r, paddle_shape_choices, *`paddle_shape_s32, `dropdown_theme);
}
BallShapeDropdown :: (l : UI.Rect, r : UI.Rect) #expand {
    UI.label(l, "Ball Shape", *`label_theme);
    UI.dropdown(r, ball_shape_choices, *`ball_shape_s32, `dropdown_theme);
}
LevelDropdown :: (l : UI.Rect, r : UI.Rect) #expand {
    UI.label(l, "Play Area", *`label_theme);
    UI.dropdown(r, level_choices, *`level_s32, `dropdown_theme);
}
PlayerCountDropdown :: (l : UI.Rect, r : UI.Rect) #expand {
    UI.label(l, "Players", *`label_theme);
    UI.dropdown(r, player_count_choices, *`player_count_s32, `dropdown_theme);
}

ball_shape : Ball_Shape = .Circle;
paddle_shape : Paddle_Shape = .Dome;
level_id : Level_Id = .Spinning_Box;

settings_back_target_menu : Game_Menu = .MAIN_MENU;