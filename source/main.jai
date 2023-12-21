// - Game coordinates are in meters
// - Game origin, (0,0) is at the center of the window
// - Game occupies a central vertical strip of the window, P1 at the bottom, P2 at the top
// - Game playable area is padded left and right by GAME_PADDING
GAME_EXTENTS :: Vector2.{10.0, 10.0}; // half-width/height in meters
GAME_PADDING :: 3.0; // Applied to both sides of game
WINDOW_HEIGHT_INITIAL :: 1280;
DT_MAX : float : 0.15;

BALL_RADIUS_INITIAL :: 0.2;
BALL_DENSITY :: 1.0;
BALL_FRICTION :: 0.3;
BALL_RESTITUTION :: 1.0;

WALL_FRICTION :: 0.0; // Set to zero because otherwise we get into situations where the ball bounces back and forth horizontally... also it seems better to have the spin only affected by player movement
WALL_RESTITUTION :: 0.0;

PADDLE_EXTENTS :: Vector2.{2.00, 0.25};
PADDLE_SPEED :: #run (GAME_EXTENTS.x / 0.35);
PADDLE_DENSITY :: 1.;
PADDLE_FRICTION :: .2;
PADDLE_RESTITUTION :: 1.3;

INITIAL_PLAYER_NAME :: "Lord Dimwit Flathead";
INITIAL_SOCKET_ADDRESS :: "127.0.0.1:4269";

player_name: string; // @Cleanup move to Player struct
socket_address: string;

window : Window_Type;
window_height : s32 = WINDOW_HEIGHT_INITIAL;
window_width  : s32 = #run cast(s32)(WINDOW_HEIGHT_INITIAL * (GAME_EXTENTS.x / GAME_EXTENTS.y) + meters_to_pixels() * 2 * GAME_PADDING);
font : *Simp.Dynamic_Font;

Game_State :: enum {
    GAME_PLAYING; // -> GAME_PAUSED
    GAME_PAUSED;  // -> MAIN_MENU | GAME_PLAYING
    MAIN_MENU;    // -> GAME_PLAYING | END_PROGRAM
    END_PROGRAM;  //
}

game_state := Game_State.MAIN_MENU;

current_dt: float = 1. / 60.;
current_time: float64;
last_time:  float64;

player1 : Player;
player2 : Player;
live_balls : [..] *Ball;
ball_spawn_countdown := 0.;

world : *b2World;
world_debug_draw : *b2Draw;
landscape : *b2Body;

data_folder: string;
sky_map : Texture;
sound_start_game : *Mixer_Sound_Data;
sound_collision1 : *Mixer_Sound_Data;
sound_collision2 : *Mixer_Sound_Data;

sound_player : *Sound_Player;

current_ball_shape : s32 = xx Ball_Shape.Circle;
current_paddle_shape : s32 = xx Paddle_Shape.Prism;

Ball_Shape :: enum {
    Circle;
    Square;
    // Capsule;
    // Rounded_Box;
    // Triangle;
    // Pentagon;
    // Hexagon;
}

Paddle_Shape :: enum {
    Box;     // aka rectangle
    Prism;   // aka isosceles trapezoid
    // Dome;    // aka circular segment
    // Capsule; // aka a half capsule cut along the line connecting circle centers
};

Ball :: struct {
    center : Vector2;
    radius : float = BALL_RADIUS_INITIAL;
    velocity : Vector2;
    color := Vector4.{0, 1, 0, 1};

    last_hit_player : int; // 1/2 => player1/player2

    // We get the transform from the physics simulation via this pointer
    // Note: The body shape is collision geometry not render geometry
    body : *b2Body;
}

Player :: struct {
    center : Vector2;
    extents : Vector2 = PADDLE_EXTENTS;
    color : Vector4;

    left : u32;
    right : u32;
    score : int;

    // Note: The body shape is collision geometry not render geometry
    body : *b2Body;
}

main :: () {
    path := path_strip_filename(get_path_of_running_executable());
    data_folder = join(path, "data");
    print("data_folder is '%'\n", data_folder);

    last_time = get_time();

    #if OS == .WINDOWS {
        Windows :: #import "Windows";
        Windows.SetProcessDPIAware();

        // Windows is very bad at thread-switching by default unless you do this. Sad.
        Windows.timeBeginPeriod(1);
    }

    window = create_window(window_name="Pong", width=window_width, height=window_height, window_x=2000, window_y=500);
    Simp.set_render_target(window);

    // We'll draw the cursor manually when we're in the menu
    // Note: @CompilerBug show_cursor() and hide_cursor() didn't seem to work correctly when called in the game/menu, but its not clear why
    hide_cursor();

    init_sounds(window);
    init_fonts();
    init_textures();
    UI.ui_init();

    // So that we have consistent memory handling after these
    // strings are user-modified, we heap-allocate them. You don't
    // have to do this; you just need some consistent way of
    // storing the strings.
    player_name = copy_string(INITIAL_PLAYER_NAME);
    socket_address = copy_string(INITIAL_SOCKET_ADDRESS);

    contact_listener : b2ContactListener;
    begin_contact :: (this: *b2ContactListener, contact: *b2Contact) -> void #cpp_method {
        new_context : Context;
        push_context new_context {
            play_sound(sound_collision2, true);
        }
    }
    end_contact :: (this: *b2ContactListener, contact: *b2Contact) -> void #cpp_method {}
    pre_solve :: (this: *b2ContactListener, contact: *b2Contact, oldManifold: *b2Manifold) -> void #cpp_method {}
    post_solve :: (this: *b2ContactListener, contact: *b2Contact, impulse: *b2ContactImpulse) -> void #cpp_method {}
    destructor :: (this: *b2ContactListener, flags: Msvc_Destructor_Flags = .NONE) -> void #cpp_method {}
    contact_listener.vtable = New(b2ContactListener_VTable); // @Leak
    contact_listener.vtable.BeginContact = begin_contact;
    contact_listener.vtable.EndContact = end_contact;
    contact_listener.vtable.PreSolve = pre_solve;
    contact_listener.vtable.PostSolve = post_solve;
    contact_listener.vtable.Destructor = destructor;

    init_world(*contact_listener);
    init_level();
    init_player(*player1, 1);
    init_player(*player2, 2);

    while game_state != .END_PROGRAM {
        reset_temporary_storage();

        current_time = get_time();
        delta : float64 = current_time - last_time;
        current_dt = cast(float) delta;
        if current_dt > DT_MAX current_dt = DT_MAX;
        last_time = current_time;

        Simp.clear_render_target(1, 0, 0, 1);

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

        update_sound_player(current_dt);

        // @Cleanup Just do this when we enter the game/menu
        if #complete game_state == {
        case .GAME_PLAYING;

            hide_cursor();

            simulate();

            draw_background();

            //for live_balls {
            //    draw_ball_at(it);
            //}
            //draw_player_at(player1);

            // Draws the physics/collision geometry
            b2World.DebugDraw(world);

            text := sprint("%:%", player1.score, player2.score);
            defer free(text);
            text_w := Simp.prepare_text(font, text);
            scale := 0.5;
            Simp.draw_prepared_text(font, window_width/30, window_height-font.character_height, .{.5, .8, .2, 1});

        case .MAIN_MENU; #through;
        case .GAME_PAUSED;

            menu();

        case .END_PROGRAM;

            // Do nothing, we'll quit next frame

        }

        Simp.swap_buffers(window);

        // memory_visualizer_per_frame_update();
    }

    free(world_debug_draw);
}



init_fonts :: () {
    // So that we can load our font, set to path of running executable.
    // @Incomplete: Pack a default font into Simp.
    path := path_strip_filename(get_path_of_running_executable());

    set_working_directory(path);
    pixel_height := window_height / 24;

    // @Cleanup: Don't have path + name be separate.
    font = Simp.get_font_at_size("data", "Anonymous Pro.ttf", pixel_height);
    assert(font != null);
}

init_textures :: () {
    make_texture :: (name: string) -> Texture, bool {
        filename := tprint("%/%", data_folder, name);

        result: Texture;
        success := Simp.texture_load_from_file(*result, filename);

        return result, success;
    }

    sky_map = make_texture("sky.png");
}

init_sounds :: (window : *Window_Type) {
    sound_player = New(Sound_Player);
    sound_player.update_history = true;

    //
    // Load sound effects
    //
    load_sound :: (basename: string) -> *Mixer_Sound_Data {
        name := tprint("%/%.wav", data_folder, basename);
        data := load_audio_file(name);

        if !data {
            print("Error: Could not load wav file: %\n", name);
            exit(1); // Hard-exit for now.
            return null;
        }

        return data;
    }

    // You might think, "hey, we can auto-generate this kind of
    // thing from a list of strings with metaprogramming." We could,
    // but this wouldn't allow us the freedom to change filenames,
    // or renaming a variable would break the game in an unintuitive
    // way because there would be no corresponding sound file.
    // So we do it the simple / dumb way. A shipping game would have
    // some kind of asset catalog where you would use handles (or
    // maybe just the string name) when you play sound effects.

    // nocommit Rename the sounds
    // sound_start_game = load_sound("start_game");
    sound_start_game = load_sound("collision1");
    sound_collision1 = load_sound("collision1");
    sound_collision2 = load_sound("collision2");

    success := init(sound_player, xx window, true, true);
    // assert(success); // @Incomplete We need an audio pass. Low priority (for now).
}

// @Cleanup This is b2Mul in Box2D, it is not output by JaiBox2D/generate.jai, maybe because older versions of Bindings_Generator didn't do that
apply_transform :: (transform: b2Transform, point: Vector2) -> Vector2 {
    result : Vector2 = ---;
    result.x = (transform.q.c * point.x - transform.q.s * point.y) + transform.p.x;
    result.y = (transform.q.s * point.x + transform.q.c * point.y) + transform.p.y;
    return result;
}

meters_to_pixels :: () -> float {
    return window_height / (2. * GAME_EXTENTS.y);
}

pixels_to_meters :: () -> float {
    return 1. / meters_to_pixels();
}

// Converts game units (meters) to pixels for rendering
world_to_screen :: (meters : Vector2) -> Vector2 {
    return (GAME_EXTENTS + Vector2.{GAME_PADDING, 0.} + meters) * meters_to_pixels();
}

screen_to_world :: (pixels : Vector2) -> Vector2 {
    return pixels * pixels_to_meters() - GAME_EXTENTS - Vector2.{GAME_PADDING, 0.};
}

countdown :: (value_pointer: *float) {
    value := value_pointer.*;
    value -= current_dt;
    if value < 0 {
        value = 0; // @Think Does this give consistent countdowns?
    }
    value_pointer.* = value;
}

kinetic_energy :: (body : *b2Body) -> float {
    omega : float = b2Body.GetAngularVelocity(body);
    velocity : b2Vec2 = b2Body.GetLinearVelocity(body);
    mass_data : b2MassData;
    b2Body.GetMassData(body, *mass_data);
    return .5 * mass_data.mass * dot_product(velocity, velocity) + .5 * mass_data.I * omega * omega;
}

draw_background :: () {
    Simp.set_shader_for_images(*sky_map);

        sky_color := Vector4.{1,1,1,1};

    Simp.immediate_quad(0, 0, xx window_width, xx window_height, sky_color);
}

draw_ball_at :: (using ball: Ball) {
    Simp.set_shader_for_color(true);

    lo, hi : Vector2 = center - Vector2.{radius, radius}, center + Vector2.{radius, radius};

    v : [4]Vector2;
    v[0] = lo;
    v[1] = Vector2.{hi.x, lo.y};
    v[2] = hi;
    v[3] = Vector2.{lo.x, hi.y};

    transform : b2Transform = b2Body.GetTransform(ball.body);
    for * v {
        it.* = world_to_screen(apply_transform(transform, it));
    }

    Simp.immediate_quad(v[0], v[1], v[2], v[3], color); // nocommit
}

draw_player_at :: (using player: Player) {
    Simp.set_shader_for_color();

    p0 : Vector2 = world_to_screen(center - extents);
    p2 : Vector2 = world_to_screen(center + extents);
    p1 : Vector2 = .{p2.x, p0.y};
    p3 : Vector2 = .{p0.x, p2.y};

    Simp.immediate_quad(p0, p1, p2, p3, color);
}

simulate :: () {
    countdown(*ball_spawn_countdown);

    if !live_balls {
        for 0..10 if ball_spawn_countdown <= 0 {
            ball : *Ball = New(Ball);

            body_def : b2BodyDef;
            b2BodyDef.Constructor(*body_def);
            body_def.type = .b2_dynamicBody;
            body_def.position = Vector2.{0., 0.}; // pitch center
            body_def.linearVelocity = Vector2.{.0, -GAME_EXTENTS.y / .5};
            body_def.bullet=true; // Since ball restitution can be bigger than 1 it can move very fast so better make it a bullet

            ball.body = b2World.CreateBody(world, *body_def);
            b2Body.SetSleepingAllowed(ball.body, false);

            circle_shape : b2CircleShape;
            b2CircleShape.Constructor(*circle_shape);
            circle_shape.m_radius = ball.radius;

            square_shape : b2PolygonShape;
            b2PolygonShape.Constructor(*square_shape);
            b2PolygonShape.SetAsBox(*square_shape, ball.radius, ball.radius, .{0., 0.}, 0);

            fixture_def : b2FixtureDef;
            b2FixtureDef.Constructor(*fixture_def);
            if cast(Ball_Shape)current_ball_shape == {
                case .Circle; fixture_def.shape = *circle_shape;
                case .Square; fixture_def.shape = *square_shape;
            }
            fixture_def.density = BALL_DENSITY;
            fixture_def.friction = BALL_FRICTION;
            fixture_def.restitution = BALL_RESTITUTION;
            b2Body.CreateFixture(ball.body, *fixture_def);

            array_add(*live_balls, ball);

            // play_sound(sound_start_game); // @todo find a nicer sound for this!
        }
    }

    for event : events_this_frame {
        if event.type == .QUIT || (event.type == .KEYBOARD && event.key_code == .ESCAPE && event.key_pressed) {
            // @Cleanup Is this correct? What even is the QUIT event?
            game_state = .GAME_PAUSED;
            break;
        }

        if event.type == .KEYBOARD {
            if event.key_code == {
                case #char "J";
                    player1.left =  event.key_pressed;
                case #char "L";
                    player1.right = event.key_pressed;

                case #char "A";
                    player2.left =  event.key_pressed;
                case #char "D";
                    player2.right = event.key_pressed;

                case #char "R";
                    start_position := Vector2.{0., 0.}; // pitch center
                    start_angle := 0.;
                    start_linear_velocity := Vector2.{.0, -GAME_EXTENTS.y / 1.0};

                    for live_balls {
                        b2Body.SetLinearVelocity(it.body, start_linear_velocity);
                        b2Body.SetAngularVelocity(it.body, 0.);
                        b2Body.SetTransform(it.body, start_position, start_angle);
                    }
            }
        }
    }

    apply_impulse_to_move_player :: (using player : Player, player_index : int) {

        Control_Mode :: enum {
            KEYBOARD_SET_VELOCITY_INF_ACCELERATION;
            KEYBOARD_SET_VELOCITY_NFRAME_ACCELERATION;
            MOUSE_SET_POSITION_INF_ACCELERATION;
            MOUSE_SET_POSITION_NFRAME_ACCELERATION;
        }

        control_mode : Control_Mode = ifx player_index == 1
            then .MOUSE_SET_POSITION_NFRAME_ACCELERATION
            else .KEYBOARD_SET_VELOCITY_NFRAME_ACCELERATION;
        // control_mode : Control_Mode = .KEYBOARD_SET_VELOCITY_WITH_ACCELERATION;

        if control_mode == {
            case .KEYBOARD_SET_VELOCITY_INF_ACCELERATION;

                current_velocity := b2Body.GetLinearVelocity(body);
                desired_velocity := 0.;
                if left  desired_velocity = -PADDLE_SPEED;
                if right desired_velocity =  PADDLE_SPEED;

                velocity_change := desired_velocity - current_velocity.x;
                impulse := b2Body.GetMass(body) * velocity_change;
                b2Body.ApplyLinearImpulse(body, b2Vec2.{impulse, 0.}, b2Body.GetWorldCenter(body), true);

            case .KEYBOARD_SET_VELOCITY_NFRAME_ACCELERATION;

                accel := (PADDLE_SPEED / (3 * current_dt));
                decel := (PADDLE_SPEED / (1 * current_dt));

                current_velocity := b2Body.GetLinearVelocity(body);
                desired_velocity := 0.;
                if left       desired_velocity = max(-PADDLE_SPEED, current_velocity.x - current_dt * accel);
                else if right desired_velocity = min( PADDLE_SPEED, current_velocity.x + current_dt * accel);
                else {
                    if current_velocity.x < 0      desired_velocity = min(0., current_velocity.x + current_dt * decel);
                    else if current_velocity.x > 0 desired_velocity = max(0., current_velocity.x - current_dt * decel);
                }

                velocity_change := desired_velocity - current_velocity.x;
                impulse := b2Body.GetMass(body) * velocity_change;
                b2Body.ApplyLinearImpulse(body, b2Vec2.{impulse, 0.}, b2Body.GetWorldCenter(body), true);

            case .MOUSE_SET_POSITION_NFRAME_ACCELERATION;

                mouse_x, mouse_y, _ := get_mouse_pointer_position();
                mouse : Vector2;
                mouse.x, mouse.y = xx mouse_x, xx mouse_y;

                current_position_x := b2Body.GetPosition(body).x;
                desired_position_x := screen_to_world(mouse).x;
                desired_velocity := (desired_position_x - current_position_x) / current_dt;
                if desired_velocity < 0 {
                    desired_velocity = max(desired_velocity, -PADDLE_SPEED);
                } else {
                    desired_velocity = min(desired_velocity, PADDLE_SPEED);
                }
                current_velocity := b2Body.GetLinearVelocity(body);
                velocity_change := desired_velocity - current_velocity.x;
                impulse := b2Body.GetMass(body) * velocity_change;
                b2Body.ApplyLinearImpulse(body, b2Vec2.{impulse, 0.}, b2Body.GetWorldCenter(body), true);
        }
    }

    apply_impulse_to_move_player(player1, 1);
    apply_impulse_to_move_player(player2, 2);

    // // Apply a small force toward other player to prevent the ball getting stuck in a horizontal bounce
    // for ball : live_balls {
    //     if ball.last_hit_player == {
    //         case 1; b2Body.ApplyForceToCenter(ball.body, b2Vec2.{0., -100.}, true);
    //         case 2; b2Body.ApplyForceToCenter(ball.body, b2Vec2.{0., 100.}, true);
    //     }
    // }

    b2World.Step(world, current_dt, 6, 2);

    for ball : live_balls {
        ball.center = b2Body.GetPosition(ball.body);
        ball.velocity = b2Body.GetLinearVelocity(ball.body);
    }

    for ball : live_balls {
        if ball.center.y > GAME_EXTENTS.y {
            player1.score += 1;
            remove ball;
            free(ball);
            ball_spawn_countdown = 2.;
        }
        if ball.center.y < -GAME_EXTENTS.y {
            player2.score += 1;
            remove ball;
            free(ball);
            ball_spawn_countdown = 2.;
        }
    }

    // for live_emitters update_emitter(it, current_dt);
}

init_world :: (contact_listener : *b2ContactListener) {
    world = New(b2World);
    b2World.Constructor(world, Vector2.{0., 0.});

    world_debug_draw_transform :: (world : Vector2) -> Vector3 { return .{xy=world_to_screen(world)}; }
    world_debug_draw = create_box2d_debug_draw_using_simp(world_debug_draw_transform);
    b2Draw.AppendFlags(world_debug_draw, xx b2Draw.e_2.shapeBit);
    //b2Draw.AppendFlags(world_debug_draw, xx b2Draw.e_2.jointBit);
    //b2Draw.AppendFlags(world_debug_draw, xx b2Draw.e_2.aabbBit);
    //b2Draw.AppendFlags(world_debug_draw, xx b2Draw.e_2.pairBit);
    //b2Draw.AppendFlags(world_debug_draw, xx b2Draw.e_2.centerOfMassBit);
    b2World.SetDebugDraw(world, world_debug_draw);

    b2World.SetContactListener(world, contact_listener);
}

init_level :: () {
    { // Create landscape aka play area
        // extents := Vector2.{GAME_EXTENTS.x, 1.}; //Vector2.{GAME_EXTENTS.x / 8., GAME_EXTENTS.y / 10.};
        extents := .25 * GAME_EXTENTS;
        center := Vector2.{0., -.75 * GAME_EXTENTS.y};
        angle := 0.;

        body_def : b2BodyDef;
        b2BodyDef.Constructor(*body_def);
        landscape = b2World.CreateBody(world, *body_def);

        // Shape coordinates are local to the body

        edge_shape : b2EdgeShape;
        b2EdgeShape.Constructor(*edge_shape);

        fixture_def : b2FixtureDef;
        b2FixtureDef.Constructor(*fixture_def);
        fixture_def.shape = *edge_shape;
        fixture_def.density = 0.;
        fixture_def.friction = WALL_FRICTION;
        fixture_def.restitution = WALL_RESTITUTION;

        // Left edge
        b2EdgeShape.SetTwoSided(*edge_shape, -GAME_EXTENTS, .{-GAME_EXTENTS.x, GAME_EXTENTS.y});
        b2Body.CreateFixture(landscape, *fixture_def);

        // Right edge
        b2EdgeShape.SetTwoSided(*edge_shape, .{GAME_EXTENTS.x, -GAME_EXTENTS.y}, GAME_EXTENTS);
        b2Body.CreateFixture(landscape, *fixture_def);

        // Top edge
        b2EdgeShape.SetTwoSided(*edge_shape, .{-GAME_EXTENTS.x, GAME_EXTENTS.y}, GAME_EXTENTS);
        b2Body.CreateFixture(landscape, *fixture_def);
    }

    // Central box obstruction
    {
        extents := .25 * GAME_EXTENTS;
        center := Vector2.{0., -.75 * GAME_EXTENTS.y};
        angle := 0.;

        body_def : b2BodyDef;
        b2BodyDef.Constructor(*body_def);
        body_def.type = .b2_kinematicBody;
        obstruction := b2World.CreateBody(world, *body_def); // nocommit cache this pointer

        shape : b2PolygonShape;
        b2PolygonShape.Constructor(*shape);
        b2PolygonShape.SetAsBox(*shape, extents.x, extents.y, .{}, angle);

        joint_def : b2PrismaticJointDef;
        b2PrismaticJointDef.Constructor(*joint_def);
        b2PrismaticJointDef.Initialize(*joint_def, landscape, obstruction, .{}, .{1., 0.});
        b2Body.SetAngularVelocity(obstruction, 1.);

        fixture_def : b2FixtureDef;
        b2FixtureDef.Constructor(*fixture_def);
        fixture_def.shape = *shape;
        fixture_def.density = 0.;
        fixture_def.friction = WALL_FRICTION;
        fixture_def.restitution = WALL_RESTITUTION;
        b2Body.CreateFixture(obstruction, *fixture_def);

    }
}

init_player :: (using player : *Player, player_index : int) {

    if player.body {
        free(player.body);
    }

    center_y := ifx player_index == 1
        then -GAME_EXTENTS.y + player1.extents.y
        else  GAME_EXTENTS.y - player2.extents.y;
    center = Vector2.{0, center_y};
    color = Vector4.{.3, .2, 0, 1};

    body_def : b2BodyDef;
    b2BodyDef.Constructor(*body_def);
    body_def.type = .b2_dynamicBody;
    body_def.position = center;
    body = b2World.CreateBody(world, *body_def);

    b2Body.SetSleepingAllowed(body, false);

    trapezoid_paddle :: (extents : Vector2, short_over_long : float, player_index : int) -> b2PolygonShape {
        shape : b2PolygonShape; 
        b2PolygonShape.Constructor(*shape);
        vertices : [4]b2Vec2 = ---;
        if player_index == 1 {
            vertices = .[
                .{-extents.x, -extents.y},
                .{ extents.x, -extents.y},
                .{ extents.x - short_over_long * extents.x, extents.y},
                .{-extents.x + short_over_long * extents.x, extents.y}
            ];
        } else {
            vertices = .[
                .{-extents.x + short_over_long * extents.x, -extents.y},
                .{ extents.x - short_over_long * extents.x, -extents.y},
                .{ extents.x, extents.y},
                .{-extents.x, extents.y} 
            ];
        }
        b2PolygonShape.Set(*shape, vertices.data, vertices.count);
        return shape;
    }

    rectangle_paddle :: (extents : Vector2, short_over_long : float, player_index : int) -> b2PolygonShape {
        return trapezoid_paddle(extents, 0., player_index);
    }

    polygon_shape : b2PolygonShape;
    if #complete cast(Paddle_Shape)current_paddle_shape == {
        case .Box;   polygon_shape = rectangle_paddle(player.extents, 1./3., player_index);
        case .Prism; polygon_shape = trapezoid_paddle(player.extents, 1./3., player_index);
    }

    fixture_def : b2FixtureDef;
    b2FixtureDef.Constructor(*fixture_def);
    fixture_def.shape = *polygon_shape;
    fixture_def.density = PADDLE_DENSITY;
    fixture_def.friction = PADDLE_FRICTION;
    fixture_def.restitution = PADDLE_RESTITUTION;
    b2Body.CreateFixture(body, *fixture_def);

    // Constrain player movement to within the GAME_EXTENTS
    joint_def : b2PrismaticJointDef;
    b2PrismaticJointDef.Constructor(*joint_def);
    b2PrismaticJointDef.Initialize(*joint_def, landscape, body, -GAME_EXTENTS, .{1., 0.});
    joint_def.lowerTranslation = -GAME_EXTENTS.x + PADDLE_EXTENTS.x;
    joint_def.upperTranslation =  GAME_EXTENTS.x - PADDLE_EXTENTS.x;
    joint_def.enableLimit = true;
    b2World.CreateJoint(world, *joint_def);
}

modify_string :: (ps: *string, new_value: string) {
    free(ps.*);
    ps.* = copy_string(new_value);
}

#import "Basic";
#import "String";
#import "System";
#import "Input";
#import "Sound_Player";
#import "Wav_File";
#import "stb_vorbis";
#import "Thread";
#import "Window_Creation";
#import "Math";
#import "Random";
#import "File";
UI :: #import "GetRect_LeftHanded";
Simp :: #import "Simp";
Texture :: Simp.Texture;

#if OS == .WINDOWS {
#import "Windows";
}

#import,dir "ThirdParty/JaiBox2D";
#load "Box2D_DebugDraw_Simp.jai";

#load "sound.jai";
#load "menu.jai";
#load "carpet.jai";