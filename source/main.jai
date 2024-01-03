// - Game coordinates are in meters
// - Game origin, (0,0) is at the center of the window
// - Game occupies a central vertical strip of the window, P1 at the bottom, P2 at the top
// - Game playable area is padded left and right by GAME_PADDING
GAME_EXTENTS :: Vector2.{10.0, 10.0}; // half-width/height in meters
GAME_PADDING :: 3.0; // Applied to both sides of game
WINDOW_HEIGHT_INITIAL :: 1440;
DT_MAX : float : 0.15;

BALL_RADIUS_INITIAL :: 0.2;
BALL_DENSITY :: 1.0;
BALL_FRICTION :: 0.3;
BALL_RESTITUTION :: 1.0;

WALL_FRICTION :: 0.0; // Set to zero because otherwise we get into situations where the ball bounces back and forth horizontally... also it seems better to have the spin only affected by player movement
WALL_RESTITUTION :: 0.0;

PADDLE_EXTENTS :: Vector2.{2.00, 0.25};
PADDLE_SPEED :: #run (GAME_EXTENTS.x / 0.35);
PADDLE_DENSITY :: 1000;
PADDLE_FRICTION :: 1.;
PADDLE_RESTITUTION :: 1.3;

friction := PADDLE_FRICTION;
restitution := PADDLE_RESTITUTION;

INITIAL_PLAYER_NAME :: "Lord Dimwit Flathead";
INITIAL_SOCKET_ADDRESS :: "127.0.0.1:4269";

player_name: string; // @Cleanup move to Player struct
socket_address: string;

window : Window_Type;
window_height : s32 = WINDOW_HEIGHT_INITIAL;
window_width  : s32 = #run cast(s32)(WINDOW_HEIGHT_INITIAL * (GAME_EXTENTS.x / GAME_EXTENTS.y) + meters_to_pixels() * 2 * GAME_PADDING);
font : *Simp.Dynamic_Font;

// @Cleanup Menus should be a state machine using this enum
Game_Mode :: enum {
    MAIN_MENU;
    PLAY_LOCAL_GAME_MENU;
    JOIN_NETWORK_GAME_MENU;
    HOST_NETWORK_GAME_MENU;
    SETTINGS_MENU;

    // nocommit Make is_paused a boolean, since in settings we want to paused if game is playing
    GAME_PAUSED_MENU;  // -> MAIN_MENU | GAME_PLAYING
    GAME_PLAYING; // -> GAME_PAUSED_MENU
    END_PROGRAM;
}

game_mode := Game_Mode.MAIN_MENU;

Player_State :: struct {
    position : float; // In the "player coordinate system" where left/right are determined by direction player is facing
};

Ball_State :: struct {
    position : Vector2;
    rotation : float;
    velocity : Vector2;
};

Game_State :: struct {
    mode : Game_Mode; // .GAME_PLAYING or .GAME_PAUSED_MENU only
    level : Level_Id;
    ball_shape : Ball_Shape;
    paddle_shape : Paddle_Shape;
}

// This data is sent by the server to all connected clients
// @TODO Generate the members using notes
Game_Snapshot :: struct {
    player1_state : Player_State;
    player2_state : Player_State;
    ball_state : Ball_State; // @Incomplete support more than one ball
    game_state : Game_State; // @TODO Only send this when game starts
}

// Networking.
// One program will host the game and will be the server.
// The server program will also be a client conneted via the loopback address
// The other player(s) will be connected via the clients IP address
// Server game loop: read client input from UDP packets, simulate the game and compute a current game state which will be sent to the clients

// Clients will send their input to the server
is_server : bool = true;
is_client : bool = true;

current_dt: float = 1. / 60.;
current_time: float64;
last_time:  float64;

player1 : Player;
player2 : Player;
level : Level;
live_balls : [..] *Ball;
ball_spawn_countdown := 0.;

world : *b2World;
world_debug_draw : *b2Draw;

Level :: struct {
    edges : *b2Body;
    obstruction : *b2Body;
}

data_folder: string;
sky_map : Texture;
menu_map : Texture;
sound_start_game : *Mixer_Sound_Data;
sound_collision1 : *Mixer_Sound_Data;
sound_collision2 : *Mixer_Sound_Data;

sound_player : *Sound_Player;

current_level : s32 = xx Level_Id.Spinning_Box;
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

Level_Id :: enum {
    Empty;
    Fixed_Box;
    Spinning_Box;
};

Ball :: struct {
    radius : float = BALL_RADIUS_INITIAL;
    color := Vector4.{0, 1, 0, 1};

    last_hit_player : int; // 1/2 => player1/player2

    // We get the transform from the physics simulation via this pointer
    // Note: The body shape is collision geometry not render geometry
    body : *b2Body;
}

Player_Index :: enum {
    P1;
    P2;
    //P3;
    //P4;
}

Player :: struct {
    index : Player_Index; // 1 => player 1, 2 => player 2 etc
    ip_address : u32 = #run Socket.inet_addr("127.0.0.1");
    port : u16 = 0;

    color : Vector4;

    left : u32;
    right : u32;
    score : int;

    // Some powerups will change the size of the player
    // Note: The body shape is collision geometry not render geometry
    body : *b2Body;
}

get_player_state :: (player : Player) -> Player_State {
    result : Player_State;

    return result;
}

get_game_state :: () -> Game_State {
    result : Game_State;
    result.mode = game_mode;
    result.level = xx current_level;
    result.ball_shape = xx current_ball_shape;
    result.paddle_shape = xx current_paddle_shape;
    return result;
}

main :: () {
    path := path_strip_filename(get_path_of_running_executable());
    data_folder = join(path, "data");
    print("data_folder is '%'\n", data_folder);

    last_time = seconds_since_init();

    #if OS == .WINDOWS {
        Windows :: #import "Windows";
        Windows.SetProcessDPIAware();

        // Windows is very bad at thread-switching by default unless you do this. Sad.
        Windows.timeBeginPeriod(1);
    }

    window = create_window(window_name="Pong", width=window_width, height=window_height, window_x=1100, window_y=400);
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

    while game_mode != .END_PROGRAM {
        reset_temporary_storage();

        current_time = seconds_since_init();
        current_dt = cast(float) (current_time - last_time);
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

        update_sound_player(current_dt);

        // @Cleanup Just do this when we enter the game/menu
        if #complete game_mode == {
        case .GAME_PLAYING;

            hide_cursor();

            if is_server {
                simulate();

                game_snapshot : Game_Snapshot;
                game_snapshot.game_state = get_game_state();
                game_snapshot.player1_state = get_player_state(player1);
                game_snapshot.player2_state = get_player_state(player2);
                // if live_balls game_snapshot.ball_state = get_ball_state(live_balls[0]);

                send_game_state_to_clients :: () {

                }

                send_game_state_to_clients();
            }

            if is_client {
                receive_game_state_from_server :: () {

                }

                receive_game_state_from_server();

                Simp.clear_render_target(1, 0, 0, 1);
                draw_game_background();
                draw_level();
                draw_player_at(player1);
                draw_player_at(player2);
                for live_balls draw_ball_at(it);
                draw_score();

                // Draws the physics/collision geometry
                //b2World.DebugDraw(world);
            }

        case .MAIN_MENU; #through;
        case .SETTINGS_MENU; #through;
        case .PLAY_LOCAL_GAME_MENU; #through;
        case .JOIN_NETWORK_GAME_MENU; #through;
        case .HOST_NETWORK_GAME_MENU; #through;
        case .GAME_PAUSED_MENU;

            menu();


            // @Incomplete

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
    menu_map = make_texture("pong.png");
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

draw_game_background :: () {
    Simp.set_shader_for_images(*sky_map);
    Simp.immediate_quad(0, 0, xx window_width, xx window_height, Vector4.{1,1,1,1});
}

draw_menu_background :: () {
    Simp.set_shader_for_images(*menu_map);
    Simp.immediate_quad(0, 0, xx window_width, xx window_height, Vector4.{1,1,1,1});
}

draw_body :: (body : *b2Body, color : Vector4) {
    if body == null return;

    fixture : *b2Fixture = b2Body.GetFixtureList(body);
    while fixture != null {
        defer fixture = b2Fixture.GetNext(fixture);

        shape : *b2Shape = b2Fixture.GetShape(fixture);
        shape_type : b2Shape.Type = b2Shape.GetType(shape);

        transform :: (body : *b2Body, v : Vector2) -> Vector3 {
            t := b2Body.GetTransform(body);
            return .{xy=world_to_screen(apply_transform(t, v))};
        }

        if shape_type == .polygon {
            using polygon_shape := cast(*b2PolygonShape)shape;

            v0 : Vector3 = transform(body, m_vertices[0]);
            for i : 1..m_count-2 {
                v1 : Vector3 = transform(body, m_vertices[i]);
                v2 : Vector3 = transform(body, m_vertices[i+1]);
                Simp.immediate_triangle(v0, v1, v2, color, color, color);
            }
        } else if shape_type == .circle {
            using circle_shape := cast(*b2CircleShape)shape;

            CIRCLE_SEGMENTS :: 16;
            CIRCLE_INCREMENT :: #run TAU / CIRCLE_SEGMENTS;

            sinInc := sin(CIRCLE_INCREMENT);
            cosInc := cos(CIRCLE_INCREMENT);
            v0 : Vector3 = transform(body, m_p);
            r1 : b2Vec2 = .{cosInc, sinInc};
            v1 : Vector3 = transform(body, m_p + m_radius * r1);
            for i : 0..CIRCLE_SEGMENTS-1 {
                // Perform rotation to avoid additional trigonometry.
                r2 : b2Vec2 = ---;
                r2.x = cosInc * r1.x - sinInc * r1.y;
                r2.y = sinInc * r1.x + cosInc * r1.y;
                v2 : Vector3 = transform(body, m_p + m_radius * r2);
                Simp.immediate_triangle(v0, v1, v2, color, color, color);
                r1 = r2;
                v1 = v2;
            }
        } else if shape_type == .edge {
            using edge_shape := cast(*b2EdgeShape)shape;

            SEGMENT_THICKNESS :: 1.; // Simp units aka pixels

            start : Vector2 = transform(body, m_vertex1).xy;
            end : Vector2 = transform(body, m_vertex2).xy;

            // assert(start.z == 0. && end.z == 0.);
            normal := unit_vector(end - start);
            normal.x, normal.y = normal.y, -normal.x; // Rotate the unit direction by 90 degrees
            q0 := start + normal * .5 * SEGMENT_THICKNESS;
            q3 := start - normal * .5 * SEGMENT_THICKNESS;
            q2 := end - normal * .5 * SEGMENT_THICKNESS;
            q1 := end + normal * .5 * SEGMENT_THICKNESS;
            Simp.immediate_quad(q0, q1, q2, q3, color, color, color, color);

        } else {
            assert(false); // @Incomplete
        }
    }
}


// @Incompleteee This should use the rendering geometry..!
draw_ball_at :: (using ball: Ball) {
    Simp.set_shader_for_color(true);

    draw_body(ball.body, ball.color);

}

// @Incompleteee This should use the rendering geometry..!
draw_player_at :: (using player: Player) {
    Simp.set_shader_for_color();

    draw_body(player.body, player.color);
}

draw_score :: () {
    text := sprint("%:%", player1.score, player2.score);
    defer free(text);
    text_w := Simp.prepare_text(font, text);
    scale := 0.5;
    Simp.draw_prepared_text(font, window_width/30, window_height-font.character_height, .{.5, .8, .2, 1});
}

simulate :: () {
    for event : events_this_frame {
        if event.type == .QUIT || (event.type == .KEYBOARD && event.key_code == .ESCAPE && event.key_pressed) {
            // @Cleanup Is this correct? What even is the QUIT event?
            game_mode = .GAME_PAUSED_MENU;
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

    apply_impulse_to_move_player :: (using player : Player) {

        Control_Mode :: enum {
            KEYBOARD_SET_VELOCITY_INF_ACCELERATION;
            KEYBOARD_SET_VELOCITY_NFRAME_ACCELERATION;
            MOUSE_SET_POSITION_INF_ACCELERATION;
            MOUSE_SET_POSITION_NFRAME_ACCELERATION;
        }

        // control_mode : Control_Mode = ifx index == .P1
        //     then .MOUSE_SET_POSITION_NFRAME_ACCELERATION
        //     else .KEYBOARD_SET_VELOCITY_NFRAME_ACCELERATION;
        control_mode : Control_Mode = .KEYBOARD_SET_VELOCITY_NFRAME_ACCELERATION;

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
                // @Feel Stop the paddle bouncing against the level border
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

    apply_impulse_to_move_player(player1);
    apply_impulse_to_move_player(player2);

    // // Apply a small force toward other player to prevent the ball getting stuck in a horizontal bounce
    // for ball : live_balls {
    //     if ball.last_hit_player == {
    //         case 1; b2Body.ApplyForceToCenter(ball.body, b2Vec2.{0., -100.}, true);
    //         case 2; b2Body.ApplyForceToCenter(ball.body, b2Vec2.{0., 100.}, true);
    //     }
    // }

    b2World.Step(world, current_dt, 6, 2);

    countdown(*ball_spawn_countdown);

    if !live_balls {
        if ball_spawn_countdown <= 0 {
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


    for ball : live_balls {
        center := b2Body.GetPosition(ball.body);
        if center.y > GAME_EXTENTS.y {
            player1.score += 1;
            deinit(ball);
            remove ball;
            free(ball);
            ball_spawn_countdown = 2.;
        } else if center.y < -GAME_EXTENTS.y {
            player2.score += 1;
            deinit(ball);
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

deinit :: (ball : *Ball) {
    b2World.DestroyBody(world, ball.body);
}

deinit :: (player : *Player) {
    player.score = 0;
    b2World.DestroyBody(world, player.body);
}

deinit_game :: () {
    for ball : live_balls {
        deinit(ball);
        remove ball;
        free(ball);
    }
    ball_spawn_countdown = 2.;

    deinit(*player2);
    deinit(*player1);
    deinit_level();
}

init_game :: () {
    init_level();
    init_player(*player1, .P1);
    init_player(*player2, .P2);
}

draw_level :: () {
    Simp.set_shader_for_color(true);

    draw_body(level.edges, Vector4.{1., 1., 1., 1.,});
    draw_body(level.obstruction, Vector4.{1., 1., 1., 1.,});
}

deinit_level :: () {
    if level.obstruction b2World.DestroyBody(world, level.obstruction);
    b2World.DestroyBody(world, level.edges);
}

init_level :: () {
    { // Create edges bounding the play area
        // extents := Vector2.{GAME_EXTENTS.x, 1.}; //Vector2.{GAME_EXTENTS.x / 8., GAME_EXTENTS.y / 10.};
        extents := .25 * GAME_EXTENTS;
        center := Vector2.{0., -.75 * GAME_EXTENTS.y};
        angle := 0.;

        body_def : b2BodyDef;
        b2BodyDef.Constructor(*body_def);
        level.edges = b2World.CreateBody(world, *body_def);

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
        b2Body.CreateFixture(level.edges, *fixture_def);

        // Right edge
        b2EdgeShape.SetTwoSided(*edge_shape, .{GAME_EXTENTS.x, -GAME_EXTENTS.y}, GAME_EXTENTS);
        b2Body.CreateFixture(level.edges, *fixture_def);

        // // Top edge
        //b2EdgeShape.SetTwoSided(*edge_shape, .{-GAME_EXTENTS.x, GAME_EXTENTS.y}, GAME_EXTENTS);
        //b2Body.CreateFixture(level.edges, *fixture_def);
    }

    // Central box obstruction
    if #complete cast(Level_Id)current_level == {
        case .Empty;
            // Do nothing
        case .Fixed_Box; #through;
        case .Spinning_Box;
            extents := .25 * GAME_EXTENTS;
            center := Vector2.{0., -.75 * GAME_EXTENTS.y};
            angle := 0.;

            body_def : b2BodyDef;
            b2BodyDef.Constructor(*body_def);
            body_def.type = .b2_kinematicBody;
            level.obstruction = b2World.CreateBody(world, *body_def);

            shape : b2PolygonShape;
            b2PolygonShape.Constructor(*shape);
            b2PolygonShape.SetAsBox(*shape, extents.x, extents.y, .{}, angle);

            fixture_def : b2FixtureDef;
            b2FixtureDef.Constructor(*fixture_def);
            fixture_def.shape = *shape;
            fixture_def.density = 0.;
            fixture_def.friction = WALL_FRICTION;
            fixture_def.restitution = WALL_RESTITUTION;
            b2Body.CreateFixture(level.obstruction, *fixture_def);

            joint_def : b2PrismaticJointDef;
            b2PrismaticJointDef.Constructor(*joint_def);
            b2PrismaticJointDef.Initialize(*joint_def, level.edges, level.obstruction, .{}, .{1., 0.});
            if cast(Level_Id)current_level == .Spinning_Box {
                b2Body.SetAngularVelocity(level.obstruction, .25);
            }
    }
}

init_player :: (using player : *Player, player_index : Player_Index) {

    index = player_index;

    center_y := ifx index == .P1
        then -GAME_EXTENTS.y + PADDLE_EXTENTS.y
        else  GAME_EXTENTS.y - PADDLE_EXTENTS.y;
    color = ifx index == .P1
        then Vector4.{1., .1, .1, 1.}
        else Vector4.{.1, .1, 1., 1.};

    body_def : b2BodyDef;
    b2BodyDef.Constructor(*body_def);
    body_def.type = .b2_dynamicBody;
    body_def.position = Vector2.{0, center_y};
    body = b2World.CreateBody(world, *body_def);

    b2Body.SetSleepingAllowed(body, false);

    trapezoid_paddle :: (extents : Vector2, short_over_long : float, player_index : Player_Index) -> b2PolygonShape {
        shape : b2PolygonShape;
        b2PolygonShape.Constructor(*shape);
        vertices : [4]b2Vec2 = ---;
        if player_index == .P1 {
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

    rectangle_paddle :: (extents : Vector2, short_over_long : float, player_index : Player_Index) -> b2PolygonShape {
        return trapezoid_paddle(extents, 0., player_index);
    }

    polygon_shape : b2PolygonShape;
    if #complete cast(Paddle_Shape)current_paddle_shape == {
        case .Box;   polygon_shape = rectangle_paddle(PADDLE_EXTENTS, 1./3., index);
        case .Prism; polygon_shape = trapezoid_paddle(PADDLE_EXTENTS, 1./3., index);
    }

    fixture_def : b2FixtureDef;
    b2FixtureDef.Constructor(*fixture_def);
    fixture_def.shape = *polygon_shape;
    fixture_def.density = PADDLE_DENSITY;
    fixture_def.friction = friction;
    fixture_def.restitution = restitution;
    b2Body.CreateFixture(body, *fixture_def);

    // Constrain player movement to within the GAME_EXTENTS
    joint_def : b2PrismaticJointDef;
    b2PrismaticJointDef.Constructor(*joint_def);
    b2PrismaticJointDef.Initialize(*joint_def, level.edges, body, -GAME_EXTENTS, .{1., 0.});
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
Socket :: #import "Socket";
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