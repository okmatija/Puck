menu :: () {

    for event : events_this_frame {
        if event.type == .QUIT || (event.type == .KEYBOARD && event.key_code == .ESCAPE && event.key_pressed) {
            if game_mode == .GAME_PAUSED {
                game_mode = .MAIN_MENU;
                deinit_game();
            } else if game_mode == .MAIN_MENU {
                // Disabled since it makes it too easy to accidentally quit the game
                //game_mode = .END_PROGRAM;
            }
        }

        UI.getrect_handle_event(event);
    }

    draw_menu_background();

    x, y, width, height := get_dimensions(window, true);
    UI.ui_per_frame_update(window, window_width, window_height, current_time);

    ui_theme : UI.Overall_Theme = UI.default_theme_procs[xx UI.Default_Themes.Default]();  // This gets filled out by calling the Theme_Proc for current_theme.
    UI.set_default_theme(ui_theme);  // Just in case we don't explicitly pass themes sometimes...!

    button_theme := ui_theme.button_theme;
    button_theme.font = font;
    button_theme.enable_variable_frame_thickness = true;
    button_theme.label_theme.alignment = .Center;

    dropdown_theme := *ui_theme.dropdown_theme;


    // 'k' is some resolution-adjusting unit of distance. Right now it is
    // 1/10 of the screen width/height, so, 192/108 pixels at 1920x1080.
    k := Vector2.{window_width * .1, window_height * .1};

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
        padding_y := .1*k.y;

        `cursor.x -= w*.5;
        r := UI.get_rect(`cursor.x, `cursor.y, w, h);
        `cursor.x += w*.5;
        `cursor.y += h + padding_y;
        return r;
    }

    if game_mode == .MAIN_MENU {

        cursor := Vector2.{5.*k.x, 5.2*k.y};

        r := NextRect(1.25*k.x, .75*k.y);

        _, _, released := UI.button(r, "Play", *button_theme);
        if released {
            game_mode = .GAME_PLAYING;
            init_game();
        }

        r = NextRect(2.*k.x, .5*k.y);
        UI.dropdown(r, ball_shape_choices, *current_ball_shape, dropdown_theme);
        
        r = NextRect(2.*k.x, .5*k.y);
        UI.dropdown(r, paddle_shape_choices, *current_paddle_shape, dropdown_theme);

        r = NextRect(2.*k.x, .5*k.y);
        UI.dropdown(r, level_choices, *current_level, dropdown_theme);

        // r = NextRect(2.*k.x, .5*k.y);
        // UI.slider(r, *friction, 0., 1., .01, *ui_theme.slider_theme, prefix="F ");

        // r = NextRect(2.*k.x, .5*k.y);
        // UI.slider(r, *restitution, 0., 1.5, .01, *ui_theme.slider_theme, prefix="R ");

        r = NextRect(1.25*k.x, .75*k.y);
        _, _, released = UI.button(r, "Quit", *button_theme);
        if released {
            game_mode = .END_PROGRAM;
        }

    } else if game_mode == .GAME_PAUSED {

        cursor := Vector2.{5.*k.x, 5.2*k.y};

        r := NextRect(1.25*k.x, .75*k.y);
        _, _, released := UI.button(r, "Resume", *button_theme);
        if released {
            game_mode = .GAME_PLAYING;
        }

        r = NextRect(1.75*k.x, .75*k.y);
        _, _, released = UI.button(r, "Main Menu", *button_theme);
        if released {
            game_mode = .MAIN_MENU;
            deinit_game();
        }

    }


    //
    // Text Input stuff:
    //

    // text_theme := ui_theme.text_input_theme;
    // text_theme.font = font;

    // r = UI.get_rect(5*k, 4*k, 5*k, font.character_height*1.35);
    // action_a, new_text_a := UI.text_input(r, player_name, *text_theme);
    // if action_a & .ENTERED  modify_string(*player_name, new_text_a);

    // text_theme.alignment = .Center;
    // r.y += font.character_height * 1.5;
    // action_b, new_socket_address := UI.text_input(r, socket_address, *text_theme);
    // if action_b & .ENTERED  modify_string(*socket_address, new_socket_address);

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