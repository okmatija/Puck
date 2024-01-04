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

    ui_theme : UI.Overall_Theme = UI.default_theme_procs[xx UI.Default_Themes.Default]();  // This gets filled out by calling the Theme_Proc for current_theme.
    UI.set_default_theme(ui_theme);  // Just in case we don't explicitly pass themes sometimes...!

    button_theme := ui_theme.button_theme;
    button_theme.font = font;
    button_theme.enable_variable_frame_thickness = true;
    button_theme.label_theme.alignment = .Center;

    text_theme := ui_theme.text_input_theme;
    text_theme.font = font;

    dropdown_theme := *ui_theme.dropdown_theme;


    // 'k' is some resolution-adjusting unit of distance. Right now it is
    // 1/10 of the screen width/height, so, 192/108 pixels at 1920x1080.
    k := Vector2.{window_width * .1, window_height * .1};
    padding := Vector2.{.1*k.x, .1*k.y}; // x/y is horizontal/vertical space between widgets

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


    // Returns the next rect to use and moves the cursor to the bottom center of the rect
    NextRect :: (w: float, h: float) -> UI.Rect #expand {
        r := UI.get_rect(`cursor.x - w*.5, `cursor.y, w, h);
        `cursor.y += h + `padding.y;
        return r;
    }

    NextRect2 :: (w: float, h: float) -> UI.Rect, UI.Rect #expand {
        l := UI.get_rect(`cursor.x - padding.x*.5 - w , `cursor.y, w, h);
        r := UI.get_rect(`cursor.x + padding.x*.5,      `cursor.y, w, h);
        `cursor.y += h + `padding.y;
        return l, r;
    }

    CenteredCursor :: (init_y : float) -> Vector2 #expand {
        return .{5.*k.x, init_y};
    }

    if #complete game_menu == {
    case .NONE;

        assert(false); // We should not get here

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
            quitting = true;
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
            game_menu = .NONE;
            is_network_game = false;
            is_server = true;
            is_client = true;
            init_game();
        }

    case .PAUSE_MENU;

        cursor := CenteredCursor(5.2*k.y);

        l, r := NextRect2(1.25*k.x, .75*k.y);
        _, _, released := UI.button(r, "Resume", *button_theme);
        if released {
            game_menu = .NONE;
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
        action_b, new_socket_address := UI.text_input(r, socket_address, *text_theme);
        if action_b & .ENTERED  modify_string(*socket_address, new_socket_address);

        l:, r = NextRect2(1.25*k.x, .75*k.y);
        _, _, released := UI.button(l, "Back", *button_theme);
        if released || esc_pressed {
            game_menu = .MAIN_MENU;
        }
        _, _, released = UI.button(r, "Join", *button_theme);
        if released {
            // @Incomplete
            is_network_game = true;
            is_server = false;
            is_client = true;
        }

    case .HOST_NETWORK_GAME_MENU;

        cursor := CenteredCursor(5.2*k.y);

        // @Cleanup This should not be editable
        r := NextRect(4*k.x, .75*k.y);
        text_theme.alignment = .Center;
        UI.text_input(r, host_info.ipv4_string, *text_theme);

        l:, r = NextRect2(1.25*k.x, .75*k.y);
        _, _, released := UI.button(l, "Back", *button_theme);
        if released || esc_pressed {
            game_menu = .MAIN_MENU;
        }
        _, _, released = UI.button(r, "Host", *button_theme);
        if released {
            game_menu = .NONE;
            is_network_game = true;
            is_server = true;
            is_client = true;
            init_game();
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