#import "Basic";
#import "String";
#import "System";
#import "Input";
#import "Window_Creation";
#import "Math";

Simp    :: #import "Simp";
Texture :: Simp.Texture;

GAME_EXTENTS :: Vector2.{10., 10.};
ASPECT :: #run GAME_EXTENTS.x / GAME_EXTENTS.y;
VPIXELS :: 640;
METERS_TO_PIXELS :: #run VPIXELS / GAME_EXTENTS.y;
PIXELS_TO_METERS :: #run 1 / METERS_TO_PIXELS;
window_width  : s32 = cast(s32) (VPIXELS * ASPECT);
window_height : s32 = VPIXELS;

key_left  : u32;
key_right : u32;
key_up    : u32;
key_down  : u32;

should_ignore_input := false;
should_quit_game :=    false;

current_dt: float = 1. / 60.;
last_time:  float64;
DT_MAX : float : 0.15;

data_folder: string;

NUM_LIVES :: 2;
BALL_RADIUS :: .2;
PADDLE_EXTENTS :: Vector2.{.25, .10};
PADDLE_SPEED :: #run (GAME_EXTENTS.x / 1.0);

lives := NUM_LIVES;


Ball :: struct {
    center : Vector2;
    radius : float = BALL_RADIUS;
    velocity : Vector2;
    color : Vector4;
}

live_balls : [..] *Ball;
ball_spawn_countdown := 0;

Player :: struct {
    center : Vector2;
    extents : Vector2 = PADDLE_EXTENTS;
    color : Vector4;
}

player1 : Player;

sky_map : Texture;

init_textures :: () {
    make_texture :: (name: string) -> Texture, bool {
        filename := tprint("%/%", data_folder, name);

        result: Texture;
        success := Simp.texture_load_from_file(*result, filename);

        return result, success;
    }

    sky_map = make_texture("sky.png");
}

// Converts game units (meters) to pixels for rendering
world_to_screen :: (meters : Vector2) -> Vector2 {
    return meters * METERS_TO_PIXELS;
}

draw_ball_at :: (using ball : Ball) {
    p0 : Vector2 = world_to_screen(center - Vector2.{radius, radius});
    p2 : Vector2 = world_to_screen(center + Vector2.{radius, radius});
    p1 : Vector2 = .{p2.x, p0.y};
    p3 : Vector2 = .{p0.x, p2.y};

    Simp.immediate_quad(p0, p1, p2, p3, color); // @TODO Make the ball a circle
}

draw_player_at :: (using player : Player) {
    p0 : Vector2 = world_to_screen(center - extents);
    p2 : Vector2 = world_to_screen(center + extents);
    p1 : Vector2 = .{p2.x, p0.y};
    p3 : Vector2 = .{p0.x, p2.y};

    Simp.immediate_quad(p0, p1, p2, p3, color); // nocommit Fix color
}

simulate :: () {
    now := get_time();
    delta : float64 = now - last_time;
    current_dt = cast(float) delta;

    if current_dt > DT_MAX current_dt = DT_MAX;

    last_time = now;

/*
    update_sound_player(current_dt);

    old_invincibility := ship_invincibility_countdown;

    countdown(*ship_shot_cooldown);
    countdown(*ship_invincibility_countdown);
    countdown(*ship_v_shot_stability_countdown);
    countdown(*ship_penetrating_countdown);

    if ship_v_shot_stability_countdown <= 0 {
        ship_v_shot_angle_target = 0;

        // We are shrinking.
        if ship_v_shot_angle_current > ship_v_shot_angle_target {
            d_angle := SHIP_V_SHOT_SHRINK_DEGREES_PER_SECOND * current_dt;
            ship_v_shot_angle_current -= d_angle;
            if ship_v_shot_angle_current < 0  ship_v_shot_angle_current = 0;
        }
    } else {
        // We are growing.
        if ship_v_shot_angle_current < ship_v_shot_angle_target {
            ship_v_shot_angle_current += SHIP_V_SHOT_EXPAND_DEGREES_PER_SECOND * current_dt;
            if ship_v_shot_angle_current > ship_v_shot_angle_target  ship_v_shot_angle_current = ship_v_shot_angle_target;
        }
    }

    if ship_invincibility_countdown <= 0 && old_invincibility > 0 {
        play_sound(sound_shield_end);
    }

    if respawn_countdown >= 0 {
        respawn_countdown -= current_dt;
        if respawn_countdown < 0 {
            lives -= 1;

            if lives < 0 {
                should_quit_game = true;
            } else {
                init_ship_position();
                ship_destroyed = false;
            }
        }
    }
*/

    if !live_balls {
        if ball_spawn_countdown <= 0 {
            ball : *Ball = New(Ball);
            ball.center = .5 * GAME_EXTENTS;
            ball.velocity = Vector2.{-GAME_EXTENTS.x / 2.0, -GAME_EXTENTS.y / 3.0}; 
            array_add(*live_balls, ball);
        }
    }

    for event : events_this_frame {
        if event.type == .QUIT {
            should_quit_game = true;
            break;
        }

        if event.key_code == .ESCAPE
            if event.key_pressed should_quit_game = true;

        if event.type == .KEYBOARD {
            key := event.key_code;

            if key == .ARROW_LEFT   key_left  = event.key_pressed;
            if key == .ARROW_RIGHT  key_right = event.key_pressed;
            if key == .ARROW_DOWN   key_down  = event.key_pressed;
            if key == .ARROW_UP     key_up    = event.key_pressed;

            // if key == .SHIFT        shoot_button_down = cast(bool) event.key_pressed;
        }
    }

    // if shoot_button_down {
    //     maybe_fire_bullets();
    // }

    // Put direction into a vector, then normalize, so that
    // you don't move faster diagonally!
    dx: Vector2;

    // :Physics Use velocity constraints or impluses to move the player?
    if key_up     dx.y += 1;
    if key_left   dx.x -= 1;
    if key_down   dx.y -= 1;
    if key_right  dx.x += 1;

    if length(dx) > 1 {
        dx = unit_vector(dx);
    }

    player1.center += dx * PADDLE_SPEED * current_dt;

    x0 := player1.extents.x;
    x1 := GAME_EXTENTS.x - player1.extents.x;
    y0 := player1.extents.y;
    y1 := GAME_EXTENTS.y;

    Clamp(*player1.center.x, x0, x1);
    Clamp(*player1.center.y, y0, y1);

    // simulate_spawns();
    simulate_balls();
    // simulate_invaders();
    // simulate_pickups();

    // for live_emitters update_emitter(it, current_dt);
}

simulate_balls :: () {
    // Return true if the ball should be destroyed
    // @todo :Physics Do something smarter here, and support spin etc
    simulate_ball :: (ball: *Ball) -> bool {
        ball.center += ball.velocity * current_dt;

        // Test against borders
        // @todo @hack there are many bugs in this code
        if ball.center.x < 0 {
            ball.center.x = 0;
            ball.velocity.x *= -1;
        } else if ball.center.x > GAME_EXTENTS.x - ball.radius {
            ball.center.x = GAME_EXTENTS.x - ball.radius;
            ball.velocity.x *= -1;
        } else if ball.center.y > GAME_EXTENTS.y - ball.radius {
            // @todo :AddPlayer2 Remove this when we add player 2
            ball.center.y = GAME_EXTENTS.y - ball.radius;
            ball.velocity.y *= -1;
        } else if
            (ball.center.y - ball.radius <= player1.center.y + player1.extents.y) &&
            (ball.center.x + ball.radius >= player1.center.x - player1.extents.x) &&
            (ball.center.x - ball.radius <= player1.center.x + player1.extents.x)
        {
            // ball.center.y *= -1;
            ball.velocity.y *= -1;
        }


        if ball.center.y < 0. return true;

        return false;
    }

    for live_balls {
        done := simulate_ball(it);
        if done {
            // it.emitter.producing = false;
            remove it;
            free(it);
        }
    }
}

main :: () {
    path := path_strip_filename(get_path_of_running_executable());
    data_folder = join(path, "data");
    print("data_folder is '%'\n", data_folder);

    last_time = get_time();

    window := create_window(window_name="Pong", width=window_width, height=window_height, window_x=2000, window_y=500);
    Simp.set_render_target(window);

    init_textures();

    player1.center = Vector2.{GAME_EXTENTS.x / 2., 2 * player1.extents.y};
    player1.color = Vector4.{.3, .2, 0, 1};

    while !should_quit_game {
        reset_temporary_storage();

        Simp.clear_render_target(1, 0, 0, 1);

        update_window_events();

        simulate();

        { // Draw the sky background.
            Simp.set_shader_for_images(*sky_map);

            sky_color := Vector4.{1,1,1,1};

            Simp.immediate_quad(0, 0, xx window_width, xx window_height, sky_color);
        }

        Simp.set_shader_for_color();

        for live_balls
            draw_ball_at(it);

        // if !ship_destroyed
        draw_player_at(player1);

        Simp.swap_buffers(window);

        // memory_visualizer_per_frame_update();
    }
}


printv :: (a : Code, loc := #caller_location) #expand {

    get_ident_name :: (code : Code) -> string {
        #import "Compiler";
        root := compiler_get_nodes(code);
        assert(root.kind == .IDENT);
        ident := cast(*Code_Ident) root;
        return ident.name;
    }

    new_context := context;

    //format_float := *new_context.print_style.default_format_float;
    //format_float.mode = .SCIENTIFIC;
    //format_float.width = 10;

    format_struct := *new_context.print_style.default_format_struct;
    format_struct.use_long_form_if_more_than_this_many_members = 4;
    format_struct.use_newlines_if_long_form = true;

    //format_array := *new_context.print_style.default_format_array;
    //format_array.stop_printing_after_this_many_elements = 10;

    push_context new_context {
#if true {
    print("%:% % = %\n", loc.fully_pathed_filename, loc.line_number, #run get_ident_name(a), #insert a);
} else {
    print("% = %\n", #run get_ident_name(a), #insert a);
}
    }
}