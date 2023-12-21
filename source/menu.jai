current_theme: s32 = xx UI.Default_Themes.Default;
ui_theme: UI.Overall_Theme;  // This gets filled out by calling the Theme_Proc for current_theme.

Ball_Shape :: enum {
    Circle;
    Square;
    // Capsule;
    // Rounded_Box;
    // Triangle;
    // Pentagon;
    // Hexagon;
}

current_ball_shape: s32 = xx Ball_Shape.Circle;

Paddle_Shape :: enum {
    Box;     // aka rectangle
    Prism;   // aka isosceles trapezoid
    // Dome;    // aka circular segment
    // Capsule; // aka a half capsule cut along the line connecting circle centers
};

current_paddle_shape: s32 = xx Paddle_Shape.Prism;

INITIAL_PLAYER_NAME :: "Lord Dimwit Flathead";
INITIAL_SOCKET_ADDRESS :: "127.0.0.1:4269";

player_name: string;
socket_address: string;


menu :: () {
        for event : events_this_frame {
            if event.type == .QUIT {
                should_quit_game = true;
            }

            if event.type == .KEYBOARD && event.key_code == .ESCAPE && event.key_pressed {
                should_quit_game = true;
            }

            if should_quit_game {
                break;
            }

            UI.getrect_handle_event(event);
        }

        draw_background();

        x, y, width, height := get_dimensions(window, true);
        UI.ui_per_frame_update(window, window_width, window_height, current_time);

        proc := UI.default_theme_procs[current_theme];
        ui_theme = proc();
        UI.set_default_theme(ui_theme);  // Just in case we don't explicitly pass themes sometimes...!

        // 'k' is some resolution-adjusting unit of distance. Right now it is
        // 1/10 of the screen width/height, so, 192/108 pixels at 1920x1080.
        k := Vector2.{window_width * .1, window_height * .1};

        cursor : Vector2; // xy position of next rect

        padding_y := 10;

        // Play button
        {
            button_theme := ui_theme.button_theme;
            button_theme.font = font;
            button_theme.enable_variable_frame_thickness = true;
            play_button_width := k.x;
            play_button_height := .75*k.y;
            r := UI.get_rect(5.*k.x-play_button_width/2, 5.*k.y-play_button_height/2, play_button_width, play_button_height);

            cursor = .{r.x, r.y};
            cursor.y += r.h + padding_y;

            button_theme.label_theme.alignment = .Center;
            pressed := UI.button(r, "Play", *button_theme);
            if pressed in_game = true;
        }

        //
        // Dropdown stuff.
        //
        {
            width :=  k.x * 2;
            height := k.y * .5;

            cursor.x -= width / 2;
            r := UI.get_rect(cursor.x+width/4, cursor.y, width, height);
            dropdown_theme := *ui_theme.dropdown_theme;

            ball_shape_choices : [#run get_enum_count(Ball_Shape)]string;
            for 0..get_enum_count(Ball_Shape)-1 {
                text := tprint("%", cast(Ball_Shape)it);
                for 0..text.count-1 {
                    if text[it] == #char "_"  text[it] = #char " ";  // Convert underscores to spaces!
                }
                ball_shape_choices[it] = text;
            }

            // The 'dropdown' function causes a popup to be created, which
            // gets rendered at the end of the frame when we call draw_popups().
            // The theme and choices array must remain valid until after that time!
            // The 'current_theme' pointer also needs to remain pointing at valid memory
            // until after that time, as that is when it will be changed.
            UI.dropdown(r, ball_shape_choices, *current_ball_shape, dropdown_theme);
            
            cursor.y += r.h + padding_y;
            r = UI.get_rect(cursor.x+width/4, cursor.y, width, height);

            paddle_shape_choices : [#run get_enum_count(Paddle_Shape)]string;
            for 0..get_enum_count(Paddle_Shape)-1 {
                text := tprint("%", cast(Paddle_Shape)it);
                for 0..text.count-1 {
                    if text[it] == #char "_"  text[it] = #char " ";  // Convert underscores to spaces!
                }
                paddle_shape_choices[it] = text;
            }
            UI.dropdown(r, paddle_shape_choices, *current_paddle_shape, dropdown_theme);
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