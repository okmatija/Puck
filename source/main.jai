// - Game coordinates are in meters
// - Game origin, (0,0) is at the center of the window
// - Game occupies a central vertical strip of the window, P1 at the bottom, P2 at the top
// - Game playable area is padded left and right by GAME_PADDING
// - Depends on level (shape of play area)

// Tight bbox of the playable area. Half-width/height in meters
get_game_extents :: () -> Vector2 {
    return .{10., 10.};
}

// At least this much padding separates the game extents from the edge of the window, in game units
get_game_padding :: () -> Vector2 {
    return .{1., 3.};
}

// Result is in meters
get_game_size :: () -> Vector2 {
    return get_game_extents() + get_game_padding();
}

// Compute data to convert world data to screen data
// * _screen is the postfix for screen coordinates
// * _world  is the postfix for world  coordinates
// * _pixels is the postfix for screen vectors
// * _meters is the postfix for world  vectors
get_world_to_screen_data :: () -> float, Vector2 {
    game_size := get_game_size();
    game_aspect := game_size.x / game_size.y;
    window_aspect := cast(float)window_width / cast(float)window_height;

    // Scale the game until it fits tightly in the window while keeping its aspect ratio
    // letter/pillarboxing will be used to fill in the remaining space. We only need to
    // consider aspect ratios (imagine of the game box scaling up from zero until it fits
    // in the window box)

    meters_to_pixels : float;
    offset_pixels : Vector2;
    if game_aspect < window_aspect {
        meters_to_pixels = window_height / (2 * game_size.y);
        offset_pixels.x = (window_width - 2 * game_size.x * meters_to_pixels) / 2;
    } else {
        meters_to_pixels = window_width / (2 * game_size.x);
        offset_pixels.y = (window_height - 2 * game_size.y * meters_to_pixels) / 2;
    }

    return meters_to_pixels, offset_pixels;
}

world_to_screen :: (point_world : Vector2) -> Vector2 {
    game_size := get_game_size();
    meters_to_pixels, offset_pixels := get_world_to_screen_data();
    return offset_pixels + (game_size + point_world) * meters_to_pixels;
}

screen_to_world :: (point_screen : Vector2) -> Vector2 {
    game_size := get_game_size();
    meters_to_pixels, offset_pixels := get_world_to_screen_data();
    return (point_screen - offset_pixels) / meters_to_pixels - game_size;
}

// Default to 1080p
WINDOW_WIDTH_INITIAL :: 1920;
WINDOW_HEIGHT_INITIAL :: 1080;
DT_MAX : float : 0.15;

BALL_RADIUS_INITIAL :: 0.4;
BALL_DENSITY :: 1.0;
BALL_FRICTION :: 0.3;
BALL_RESTITUTION :: 1.0;
BALL_COUNT_MAX :: 3;

WALL_FRICTION :: 0.0; // Set to zero because otherwise we get into situations where the ball bounces back and forth horizontally... also it seems better to have the spin only affected by player movement
WALL_RESTITUTION :: 0.0;

// The paddle extents is the main scaling entity!
PADDLE_EXTENTS :: Vector2.{2.0, 0.25};
PADDLE_SPEED :: #run (5.0 * PADDLE_EXTENTS.x / 0.35); // move 5 paddle widths in 0.35 seconds
PADDLE_DENSITY :: 1000;
PADDLE_FRICTION :: 1.;
PADDLE_RESTITUTION :: 1.2;

DEFAULT_PORT : u16 : 42069;

// player_name: string; // @Cleanup move to Player struct
// server_address: string;
host_info : Host_Info;

server_address : string;
server_port : u16 = DEFAULT_PORT;
server_port_string : string;

window : Window_Type;
window_height : s32;
window_width  : s32;

font : *Simp.Dynamic_Font;

game_quitting : bool;
game_menu : Game_Menu;
game_mode : Game_Mode;

current_frame : u64;
current_dt: float = 1. / 60.; // Seconds
current_time: float64; // Seconds
last_time:  float64; // Seconds

level : Level;
player1 : Player;
player2 : Player;
balls : [BALL_COUNT_MAX]Ball;

ball_spawn_countdown := 0.;

world : *b2World;
contact_listener : b2ContactListener;
world_debug_draw : *b2Draw;

host_type : Host_Type = .UNKNOWN;
server : Server;
client : Client;
network_events_this_frame : [..]Enet.Event;

// Important these are global and persist across frames to preserve previous key down state
input1 : Client_Input;
input2 : Client_Input;
esc_pressed : bool;

data_folder: string;
sky_map : Texture;
menu_map : Texture;
sound_start_game : Sound.Sound_Data;
sound_collision1 : Sound.Sound_Data;
sound_collision2 : Sound.Sound_Data;

DeadBalls :: (ball_array : *[BALL_COUNT_MAX]Ball, body : Code, flags : For_Flags) #expand {
    for *=cast(bool)(flags & .POINTER) ball, ball_index : ball_array.* {
        if !ball.live {
            `it_index := ball_index;
            `it := ball;
            #insert body;
        }
    }
}

LiveBalls :: (ball_array : *[BALL_COUNT_MAX]Ball, body : Code, flags : For_Flags) #expand {
    for *=cast(bool)(flags & .POINTER) ball, ball_index : ball_array.* {
        if ball.live {
            `it_index := ball_index;
            `it := ball;
            #insert body;
        }
    }
}

// @Cleanup Menus should be a state machine using this enum
Game_Menu :: enum u8 {
    MAIN_MENU :: 0;
    PLAY_LOCAL_GAME_MENU;
    JOIN_NETWORK_GAME_MENU;
    HOST_NETWORK_GAME_MENU;
    WAITING_FOR_PLAYERS_MENU;
    CONNECTING_TO_SERVER_MENU;
    SETTINGS_MENU;
    PAUSE_MENU;
}

Game_Mode :: enum u8 {
    NOT_STARTED :: 0; // Here the game is not initted
    //INITIALIZING;
    PLAYING;
    PAUSED;
}

Ball_Shape :: enum {
    Circle;
    Square;
    // Capsule;
    // Rounded_Box;
    // Triangle;
    // Pentagon;
    // Hexagon;
}
#insert #run generate_dropdown_choices("ball_shape_choices", Ball_Shape);

Paddle_Shape :: enum {
    Box;     // aka rectangle
    Prism;   // aka isosceles trapezoid
    Dome;    // aka circular segment
    // Capsule; // aka a half capsule cut along the line connecting circle centers
};
#insert #run generate_dropdown_choices("paddle_shape_choices", Paddle_Shape);

Level_Id :: enum {
    Empty;
    Fixed_Box;
    Spinning_Box;
};
#insert #run generate_dropdown_choices("level_choices", Level_Id);


Player_Index :: enum u8 #specified {
    P1 :: 1;
    P2 :: 2;
    //P3 :: ;
    //P4 :: 4;
}

Tuple3 :: struct (T : Type = s8) {
    i, j, k : T;
    #place i; component : [3] T = ---;
}

Obstruction :: struct {
    live : bool;

    mesh : Mesh;
    color : Vector4 = .{1., 1., 1., 1.};
    transform : b2Transform;

    body : *b2Body; // Physics. This is not initialized or used by clients!
}

Boundary :: struct {
    color : Vector4 = .{1., 1., 1., 1.};
    shape : Polyline_Soup;

    body : *b2Body; // Physics. This is not initialized or used by clients!
}

Level :: struct {
    level_id : Level_Id;
    obstructions : Obstruction;
    boundary : Boundary;
}

Ball :: struct {
    live : bool;

    shape : Ball_Shape;
    radius : float = BALL_RADIUS_INITIAL;

    mesh : Mesh;
    color : Vector4 = .{0, 1, 0, 1};
    transform : b2Transform;

    // Used on the server only:

    // We get the transform from the physics simulation via this pointer
    // Note: The body shape is collision geometry not render geometry
    body : *b2Body; // Physics. This is not initialized or used by clients!
}

Player :: struct {
    index : Player_Index;

    paddle_shape : Paddle_Shape;
    mesh : Mesh;
    color : Vector4;
    transform : b2Transform;

    Prismatic_Joint :: struct {
        anchor : Vector2;
        axis : Vector2;
        lower_translation : float;
        upper_translation : float;
    }

    joint : Prismatic_Joint; // Constrains the path of the paddle. Initted using the level id 

    left : u32;
    right : u32;
    down : u32;
    up : u32;

    warp_active := false;
    warp_countdown := WARP_COUNTDOWN;

    score : int;

    // Some powerups will change the size of the player
    // Note: The body shape is collision geometry not render geometry
    body : *b2Body; // Physics. This is not initialized or used by clients!
}

initial_ball_velocity :: () -> Vector2 {
    return .{-5.0 * PADDLE_EXTENTS.x / 1., 0};
}

time_factor := 1.;
TIME_FACTOR :: .3;
WARP_SPEEDUP :: #run 1. / TIME_FACTOR;
WARP_COUNTDOWN :: .4;;

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

    // We'll draw the cursor manually when we're in the menu
    // Note: @CompilerBug show_cursor() and hide_cursor() didn't seem to work correctly when called in the game/menu, but its not clear why
    hide_cursor();

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

        if game_mode == .PLAYING {

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

                player2.left = xx input2.left_down;
                player2.right = xx input2.right_down;
                player2.down = xx input2.down_down;
                player2.up = xx input2.up_down;

                simulate();

            case .SERVER;

                player1.left = xx input1.left_down;
                player1.right = xx input1.right_down;
                player1.down = xx input1.down_down;
                player1.up = xx input1.up_down;

                input, received := receive_input();
                if received {
                    player2.left = xx input.left_down;
                    player2.right = xx input.right_down;
                    player2.down = xx input.down_down;
                    player2.up = xx input.up_down;
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

            case #char "I"; #through; case .ARROW_UP;
                input1.up_down = xx event.key_pressed;
            case #char "J"; #through; case .ARROW_LEFT;
                input1.left_down = xx event.key_pressed;
            case #char "K"; #through; case .ARROW_DOWN;
                input1.down_down = xx event.key_pressed;
            case #char "L"; #through; case .ARROW_RIGHT;
                input1.right_down = xx event.key_pressed;

            case #char "W";
                input2.up_down = xx event.key_pressed;
            case #char "A";
                input2.left_down = xx event.key_pressed;
            case #char "S";
                input2.down_down = xx event.key_pressed;
            case #char "D";
                input2.right_down = xx event.key_pressed;

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
    // A shipping game would have some kind of asset catalog where you would
    // use handles (or maybe just the string name) when you play sound effects.

    // @Cleanup Rename the sounds
    sound_start_game = Sound.load_audio_file(tprint("%/start_game.wav", data_folder));
    sound_collision1 = Sound.load_audio_file(tprint("%/collision1.wav", data_folder));
    sound_collision2 = Sound.load_audio_file(tprint("%/collision2.wav", data_folder));

    success := Sound.sound_player_init(.{});
    assert(success);

}

// @Cleanup This is b2Mul in Box2D, it is not output by JaiBox2D/generate.jai, maybe because older versions of Bindings_Generator didn't do that
apply_transform :: (transform: b2Transform, point: Vector2) -> Vector2 {
    result : Vector2 = ---;
    result.x = (transform.q.c * point.x - transform.q.s * point.y) + transform.p.x;
    result.y = (transform.q.s * point.x + transform.q.c * point.y) + transform.p.y;
    return result;
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


simulate :: () {

    apply_impulse_to_move_player :: (using player : *Player) {

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
        // control_mode : Control_Mode = .KEYBOARD_SET_VELOCITY_INF_ACCELERATION;

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

            paddle_speed := PADDLE_SPEED;

            {
                if down && warp_countdown == WARP_COUNTDOWN {
                    stream := Sound.make_stream(*sound_collision1, .GENERAL_SFX);
                    stream.rate_scale = .5;
                    Sound.start_playing(stream);

                    warp_active = true;
                    time_factor = TIME_FACTOR;
                }

                if warp_active {
                    countdown(*warp_countdown);
                    paddle_speed *= WARP_SPEEDUP;
                }

                if warp_countdown <= 0  {
                    stream := Sound.make_stream(*sound_collision1, .GENERAL_SFX);
                    stream.rate_scale = -.8;
                    Sound.start_playing(stream);

                    warp_active = false;
                    time_factor = 1.;
                    warp_countdown = WARP_COUNTDOWN;
                }
            }

            accel := (paddle_speed / (3 * current_dt));
            decel := (paddle_speed / (1 * current_dt));

            current_velocity := b2Body.GetLinearVelocity(body);
            desired_velocity := 0.;
            if left       desired_velocity = max(-paddle_speed, current_velocity.x - current_dt * accel);
            else if right desired_velocity = min( paddle_speed, current_velocity.x + current_dt * accel);
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

    apply_impulse_to_move_player(*player1);
    apply_impulse_to_move_player(*player2);

    // If there are any dead balls revive one after the spawn countdown
    for * :DeadBalls ball : balls {
        countdown(*ball_spawn_countdown);

        if ball_spawn_countdown <= 0  {
            ball.live = true;
            b2Body.SetTransform(ball.body, .{get_game_extents().x - ball.radius, 0}, 0);
            b2Body.SetLinearVelocity(ball.body, initial_ball_velocity());
            b2Body.SetAngularVelocity(ball.body, 0.);
            b2Body.SetEnabled(ball.body, true);
            ball_spawn_countdown = 2.;
        }

        break; // Just spawn one new ball
    }

    // simulate_attractor_balls(5000);

    for * :LiveBalls ball : balls {
        center := b2Body.GetPosition(ball.body).*;
        game_extents := get_game_extents();
        if center.y - ball.radius > game_extents.y {
            ball.live = false;
            b2Body.SetEnabled(ball.body, false);
            player1.score += 1;
        } else if center.y + ball.radius < -game_extents.y {
            ball.live = false;
            b2Body.SetEnabled(ball.body, false);
            player2.score += 1;
        }
    }

    // Important: Do this after SetTransform above (see the comment on b2Body::SetTransform)
    b2World.Step(world, current_dt, 6, 2);

    // Update the transforms used for rendering
    player1.transform = b2Body.GetTransform(player1.body);
    player2.transform = b2Body.GetTransform(player2.body);
    for * balls {
        it.transform = b2Body.GetTransform(it.body);
    }
    if level.obstructions.body {
        level.obstructions.transform = b2Body.GetTransform(level.obstructions.body);
    }

    // for live_emitters update_emitter(it, current_dt);
}

init_world :: () {
    begin_contact :: (this: *b2ContactListener, contact: *b2Contact) -> void #cpp_method {
        new_context : Context;
        push_context new_context {
            stream := Sound.make_stream(*sound_collision2, .GENERAL_SFX);
            stream.rate_scale = random_get_within_range(0.7, 1.22);
            Sound.start_playing(stream);
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

    world = New(b2World); // @Leak
    b2World.Constructor(world, Vector2.{0., 0.});

    world_debug_draw_transform :: (world : Vector2) -> Vector3 { return .{xy=world_to_screen(world)}; }
    world_debug_draw = create_box2d_debug_draw_using_simp(world_debug_draw_transform);
    b2Draw.AppendFlags(world_debug_draw, xx b2Draw.e_2.shapeBit);
    //b2Draw.AppendFlags(world_debug_draw, xx b2Draw.e_2.jointBit);
    //b2Draw.AppendFlags(world_debug_draw, xx b2Draw.e_2.aabbBit);
    //b2Draw.AppendFlags(world_debug_draw, xx b2Draw.e_2.pairBit);
    //b2Draw.AppendFlags(world_debug_draw, xx b2Draw.e_2.centerOfMassBit);
    b2World.SetDebugDraw(world, world_debug_draw);

    b2World.SetContactListener(world, *contact_listener);
}

deinit_player :: (player : *Player) {
    player.score = 0;
    deinit_mesh(player.mesh);
    if host_type != .CLIENT {
        b2World.DestroyBody(world, player.body);
    }
}

deinit_game :: () {
    // We can call deinit_game before game was initted if the client connects but disconnects before
    if game_mode != .NOT_STARTED {
        deinit_level();
        deinit_player(*player1);
        deinit_player(*player2);
        for * ball : balls {
            deinit_ball(ball);
        }
        free(world_debug_draw);
    }

    // Make sure to deinit the client/server after deinitting the game above, to do that properly we need to know the host_type which is set to UNKNOWN below
    if host_type == {
    case .CLIENT;
        game_menu = .JOIN_NETWORK_GAME_MENU;
        deinit_client();
    case .SERVER;
        game_menu = .HOST_NETWORK_GAME_MENU;
        deinit_server();
    case .LOCAL;
        game_menu = .PLAY_LOCAL_GAME_MENU;
    }

    game_mode = .NOT_STARTED;
}

init_game :: (using init_game_state : Init_Game_State) {
    assert(game_mode == .NOT_STARTED);

    if host_type != .CLIENT {
        init_world();
    }

    init_level(level_id); // Must come before players since they are constrained relative to the level boundary
    init_player(*player1, .P1, p1_paddle_shape);
    init_player(*player2, .P2, p2_paddle_shape);
    for * ball : balls {
        if it_index == {
            case 0;
                ball.color = .{0., 1., 0., 1.};
                ball.radius *= .3;
            case 1;
                ball.color = .{1., 1., 0., 1.};
                ball.radius *= .7;
            case 2;
                ball.color = .{0., 1., 1., 1.};
        }
        init_ball(ball, ball_shape);
    }

    game_mode = .PLAYING;
}

deinit_level :: () {
    deinit_polyline_soup(*level.boundary.shape);

    if host_type != .CLIENT {
        if level.obstructions.body {
            b2World.DestroyBody(world, level.obstructions.body);
        }
        b2World.DestroyBody(world, level.boundary.body);
    }
}

deinit_ball :: (ball : *Ball) {
    log_verbose("deinit_ball");

    ball.live = false;

    deinit_mesh(ball.mesh);

    if host_type != .CLIENT {
        b2World.DestroyBody(world, ball.body);
    }
}

init_ball_physics :: (ball : *Ball) {
    assert(host_type == .SERVER || host_type == .LOCAL);

    body_def : b2BodyDef;
    b2BodyDef.Constructor(*body_def);
    body_def.type = .b2_dynamicBody;
    body_def.bullet=true; // Balls can move very fast!

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
    if #complete ball.shape == {
    case .Circle;
        fixture_def.shape = *circle_shape;
    case .Square;
        fixture_def.shape = *square_shape;
    }
    fixture_def.density = BALL_DENSITY;
    fixture_def.friction = BALL_FRICTION;
    fixture_def.restitution = BALL_RESTITUTION;
    b2Body.CreateFixture(ball.body, *fixture_def);

    b2Body.SetEnabled(ball.body, false);
}

init_ball :: (using ball : *Ball, initial_shape : Ball_Shape) {
    live = false;
    ball.shape = initial_shape;

    if #complete shape == {
    case .Circle;
        init_circle_mesh(mesh, radius);
    case .Square;
        init_prism_mesh(mesh, .{radius, radius}, 0.);
    }

    if host_type != .CLIENT {
        init_ball_physics(ball);
    }

    // play_sound(sound_start_game); // @todo find a nicer sound for this!
}

init_boundary :: () {
    game_extents := get_game_extents();

    #if true {
        using game_extents;
        ax := .65 * x;
        ay := .45 * y;

        left : *Polyline = array_add(*level.boundary.shape.polylines);
        array_add(*left.points, .{-ax, -y}, .{-x, -ay}, .{-x, ay}, .{-ax, y});

        right : *Polyline = array_add(*level.boundary.shape.polylines);
        array_add(*right.points, .{ax, -y}, .{x, -ay}, .{x, ay}, .{ax, y});

        top : *Polyline = array_add(*level.boundary.shape.polylines);
        array_add(*top.points, .{-ax, y}, .{ax, y});

        player1.joint.anchor = .{0., -y};
        player1.joint.axis = .{1, 0};
        player1.joint.lower_translation = -ax + PADDLE_EXTENTS.x;
        player1.joint.upper_translation =  ax - PADDLE_EXTENTS.x;

        player2.joint.anchor = .{0., y};
        player2.joint.axis = .{1, 0};
        player2.joint.lower_translation = -ax + PADDLE_EXTENTS.x;
        player2.joint.upper_translation =  ax - PADDLE_EXTENTS.x;

    } else {
        left : *Polyline = array_add(*level.boundary.shape.polylines);
        array_add(*left.points, -game_extents, Vector2.{-game_extents.x, game_extents.y});

        right : *Polyline = array_add(*level.boundary.shape.polylines);
        array_add(*right.points, .{game_extents.x, -game_extents.y}, game_extents);

        //top : *Polyline = array_add(*level.boundary.shape.polylines);
        //array_add(*top.points, .{-game_extents.x, game_extents.y}, game_extents);

        player1.joint.anchor = .{0., -game_extents.y};
        player1.joint.axis = .{1, 0};
        player1.joint.lower_translation = -game_extents.x + PADDLE_EXTENTS.x;
        player1.joint.upper_translation =  game_extents.x - PADDLE_EXTENTS.x;

        player2.joint.anchor = .{0., game_extents.y};
        player2.joint.axis = .{1, 0};
        player2.joint.lower_translation = -game_extents.x + PADDLE_EXTENTS.x;
        player2.joint.upper_translation =  game_extents.x - PADDLE_EXTENTS.x;
    }

    if host_type != .CLIENT {
        init_boundary_physics();
    }
}

init_boundary_physics :: () {
    assert(host_type == .SERVER || host_type == .LOCAL);

    body_def : b2BodyDef;
    b2BodyDef.Constructor(*body_def);
    level.boundary.body = b2World.CreateBody(world, *body_def);

    // Shape coordinates are local to the body

    edge_shape : b2EdgeShape;
    b2EdgeShape.Constructor(*edge_shape);

    fixture_def : b2FixtureDef;
    b2FixtureDef.Constructor(*fixture_def);
    fixture_def.shape = *edge_shape;
    fixture_def.density = 0.;
    fixture_def.friction = WALL_FRICTION;
    fixture_def.restitution = WALL_RESTITUTION;

    for :PolylineSegmentIterator level.boundary.shape {
        b2EdgeShape.SetTwoSided(*edge_shape, it.from, it.to);
        b2Body.CreateFixture(level.boundary.body, *fixture_def);
    }
}

init_obstructions_physics :: () {
    assert(host_type == .SERVER || host_type == .LOCAL);

    if #complete level.level_id == {
    case .Empty;
        // Do nothing
    case .Fixed_Box; #through;
    case .Spinning_Box;
        extents := .25 * Vector2.{5 * PADDLE_EXTENTS.x, 5 * PADDLE_EXTENTS.x};

        body_def : b2BodyDef;
        b2BodyDef.Constructor(*body_def);
        body_def.type = .b2_kinematicBody;
        body := b2World.CreateBody(world, *body_def);
        level.obstructions.body = body;

        add_fixture_from_mesh(level.obstructions.body, level.obstructions.mesh);

        joint_def : b2PrismaticJointDef;
        b2PrismaticJointDef.Constructor(*joint_def);
        b2PrismaticJointDef.Initialize(*joint_def, level.boundary.body, body, .{}, .{1., 0.});
        if level.level_id == .Spinning_Box {
            b2Body.SetAngularVelocity(body, .25);
        }
    }
}

init_obstructions :: () {
    if #complete level.level_id == {
    case .Empty;
        // Do nothing
    case .Fixed_Box; #through;
    case .Spinning_Box;
        extents := PADDLE_EXTENTS;
        transform : b2Transform;
        b2Transform.Constructor(*transform);

        mesh : Mesh;
        defer deinit_mesh(mesh);

        init_prism_mesh(mesh, extents, 0.);
        b2Transform.Set(*transform, .{0,  8*PADDLE_EXTENTS.y}, 0.);
        mesh_transform(*mesh, transform);
        mesh_merge(*level.obstructions.mesh, mesh);

        mesh_reset(*mesh);
        init_prism_mesh(mesh, extents, 0.);
        b2Transform.Set(*transform, .{0, -8*PADDLE_EXTENTS.y}, 0.);
        mesh_transform(*mesh, transform);
        mesh_merge(*level.obstructions.mesh, mesh);

        // Close off the parallels
        //mesh_reset(*mesh);
        //init_prism_mesh(mesh, extents, 0.);
        //b2Transform.Set(*transform, .{0,  8*PADDLE_EXTENTS.y}, 0.);
        //mesh_transform(*mesh, transform);
        //b2Transform.Set(*transform, .{0, 0}, PI/2.);
        //mesh_transform(*mesh, transform);
        //mesh_merge(*level.obstructions.mesh, mesh);
    }

    if host_type != .CLIENT {
        init_obstructions_physics();
    }
}

init_level :: (level_id : Level_Id) {
    level.level_id = level_id;

    init_boundary();
    init_obstructions();
}

init_player_physics :: (using player : *Player) {
    assert(host_type == .SERVER || host_type == .LOCAL);

    game_extents := get_game_extents();

    body_def : b2BodyDef;
    b2BodyDef.Constructor(*body_def);
    body_def.type = .b2_dynamicBody;
    if index == {
    case .P1;
        body_def.position = Vector2.{0, -game_extents.y + PADDLE_EXTENTS.y};
        body_def.angle = 0.;
    case .P2;
        body_def.position = Vector2.{0,  game_extents.y - PADDLE_EXTENTS.y};
        body_def.angle = PI;
    }
    body = b2World.CreateBody(world, *body_def);

    b2Body.SetSleepingAllowed(body, false);

    // :VariablePaddleRestitution

    if #complete paddle_shape == {
        case .Box; #through;
        case .Prism;
            {
                // Flat part
                polygon_shape : b2PolygonShape;
                b2PolygonShape.Constructor(*polygon_shape);
                t := mesh.triangles[0];
                points : [3]Vector2 = .[mesh.vertices[t.i], mesh.vertices[t.j], mesh.vertices[t.k]];
                b2PolygonShape.Set(*polygon_shape, points.data, 3);

                fixture_def : b2FixtureDef;
                b2FixtureDef.Constructor(*fixture_def);
                fixture_def.shape = *polygon_shape;
                fixture_def.density = PADDLE_DENSITY;
                fixture_def.friction = PADDLE_FRICTION;
                fixture_def.restitution = PADDLE_RESTITUTION;
                b2Body.CreateFixture(body, *fixture_def);
            }

            for 1..2 {
                polygon_shape : b2PolygonShape;
                b2PolygonShape.Constructor(*polygon_shape);
                t := mesh.triangles[it];
                points : [3]Vector2 = .[mesh.vertices[t.i], mesh.vertices[t.j], mesh.vertices[t.k]];
                b2PolygonShape.Set(*polygon_shape, points.data, 3);

                fixture_def : b2FixtureDef;
                b2FixtureDef.Constructor(*fixture_def);
                fixture_def.shape = *polygon_shape;
                fixture_def.density = PADDLE_DENSITY;
                fixture_def.friction = PADDLE_FRICTION;
                fixture_def.restitution = .5 * PADDLE_RESTITUTION;
                b2Body.CreateFixture(body, *fixture_def);
            }

        case .Dome;

            add_fixture_from_mesh(body, mesh);
    }

    // Constrain player movement
    joint_def : b2PrismaticJointDef;
    b2PrismaticJointDef.Constructor(*joint_def);
    b2PrismaticJointDef.Initialize(*joint_def, level.boundary.body, body, joint.anchor, joint.axis);
    joint_def.lowerTranslation = joint.lower_translation;
    joint_def.upperTranslation = joint.upper_translation;
    joint_def.enableLimit = true;
    b2World.CreateJoint(world, *joint_def);
}

init_player :: (using player : *Player, player_index : Player_Index, player_paddle_shape : Paddle_Shape) {

    index = player_index;
    color = ifx index == .P1 then Vector4.{1., .1, .1, 1.} else Vector4.{.1, .1, 1., 1.};
    paddle_shape = player_paddle_shape;

    if #complete paddle_shape == {
    case .Box;
        init_prism_mesh(mesh, PADDLE_EXTENTS, 0.);
    case .Prism;
        init_prism_mesh(mesh, PADDLE_EXTENTS, 1./3.);
    case .Dome;
        init_dome_mesh(mesh, PADDLE_EXTENTS, 2. * PADDLE_EXTENTS.x, 11);
    }

    if host_type != .CLIENT {
        init_player_physics(player);
    }
}

Texture :: Simp.Texture;

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
#if OS == .WINDOWS #import "Windows";

// These are in ./modules/
Enet :: #import "enet";
#import "JaiBox2D";

// These are in ./source/
#load "Box2D_DebugDraw_Simp.jai";
#load "networking.jai";
#load "menu.jai";
#load "rendering.jai";
#load "simulate.jai";
#load "mesh.jai";
#load "carpet.jai";
#load "numeric.jai";