#import "Basic";
#import "String";
#import "System";
#import "Input";
#import "Window_Creation";
#import "Math";

#import,dir "ThirdParty/JaiBox2D";
#load "Box2D_DebugDraw_Simp.jai";

// @Cleanup This is b2Mul in Box2D, it is not output by JaiBox2D/generate.jai, maybe because older versions of Bindings_Generator didn't do that
apply_transform :: (transform: b2Transform, point: Vector2) -> Vector2 {
    result : Vector2 = ---;
    result.x = (transform.q.c * point.x - transform.q.s * point.y) + transform.p.x;
    result.y = (transform.q.s * point.x + transform.q.c * point.y) + transform.p.y;
    return result;
}

#load "carpet.jai";

Simp :: #import "Simp";
Texture :: Simp.Texture;

// - Game coordinates are in meters
// - Game origin, (0,0) is at the center of the window
// - Game occupies a central vertical strip of the window, P1 at the bottom, P2 at the top
// - Game playable area is padded left and right by GAME_PADDING
GAME_EXTENTS :: Vector2.{10.0, 10.0}; // half-width/height in meters
GAME_PADDING :: 3.0; // Applied to both sides of game
WINDOW_HEIGHT_INITIAL :: 640;

BALL_RADIUS_INITIAL :: 0.2;
BALL_DENSITY :: 1.0;
BALL_FRICTION :: 0.3;
BALL_RESTITUTION :: 1.0;

WALL_FRICTION :: 0.0;
WALL_RESTITUTION :: 0.0;

PADDLE_EXTENTS :: Vector2.{2.00, 0.25};
PADDLE_SPEED :: #run (GAME_EXTENTS.x / 0.35);
PADDLE_DENSITY :: 1.;
PADDLE_FRICTION :: .2;
PADDLE_RESTITUTION :: 1.3;

meters_to_pixels :: () -> float {
    return window_height / (2. * GAME_EXTENTS.y);
}

pixels_to_meters :: () -> float {
    return 1. / meters_to_pixels();
}

//App :: struct {
window_height : s32 = WINDOW_HEIGHT_INITIAL;
window_width  : s32 = #run cast(s32)(WINDOW_HEIGHT_INITIAL * (GAME_EXTENTS.x / GAME_EXTENTS.y) + meters_to_pixels() * 2 * GAME_PADDING);
font : *Simp.Dynamic_Font;
//}

should_ignore_input := false;
should_quit_game :=    false;

current_dt: float = 1. / 60.;
last_time:  float64;
DT_MAX : float : 0.15;

data_folder: string;


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

live_balls : [..] *Ball;
ball_spawn_countdown := 0.;

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

player1 : Player;
player2 : Player;

sky_map : Texture;

world : *b2World;
landscape : *b2Body;

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

// Converts game units (meters) to pixels for rendering
world_to_screen :: (meters : Vector2) -> Vector2 {
    return (GAME_EXTENTS + Vector2.{GAME_PADDING, 0.} + meters) * meters_to_pixels();
}

countdown :: (value_pointer: *float) {
    value := value_pointer.*;
    value -= current_dt;
    if value < 0 {
        value = 0; // @Think Does this give consistent countdowns?
    }
    value_pointer.* = value;
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

// // @todo write a draw_b2Shape function?
// draw_b2PolygonShape :: (shape : b2PolygonShape, color : Vector4) {
//     Simp.set_shader_for_color();

//     triangle_count := shape.m_count - 2;
//     o := Vector3.{xy=world_to_screen(shape.m_vertices[0]), z=0};
//     for t : 0..triangle_count-1 {
//         a := Vector3.{xy=world_to_screen(shape.m_vertices[t + 1]), z=0};
//         b := Vector3.{xy=world_to_screen(shape.m_vertices[t + 2]), z=0};
//         Simp.immediate_triangle(o, a, b, color, color, color);
//     }
// }

simulate :: () {
    now := get_time();
    delta : float64 = now - last_time;
    current_dt = cast(float) delta;

    if current_dt > DT_MAX current_dt = DT_MAX;

    last_time = now;

    countdown(*ball_spawn_countdown);

    if !live_balls {
        if ball_spawn_countdown <= 0 {
            ball : *Ball = New(Ball);

            start_position := Vector2.{0., 0.}; // pitch center
            // start_linear_velocity := Vector2.{-GAME_EXTENTS.x / 2.0, -GAME_EXTENTS.y / 3.0};
            start_linear_velocity := Vector2.{.0, -GAME_EXTENTS.y / 1.0};

            body_def : b2BodyDef;
            b2BodyDef.Constructor(*body_def);
            body_def.type = .b2_dynamicBody;
            body_def.position = start_position;
            body_def.linearVelocity = start_linear_velocity;
            body_def.bullet=true; // Since ball restitution can be bigger than 1 it can move very fast!

            ball.body = b2World.CreateBody(world, *body_def);
            b2Body.SetSleepingAllowed(ball.body, false);

            // shape : b2PolygonShape;
            // b2PolygonShape.Constructor(*shape);
            // b2PolygonShape.SetAsBox(*shape, ball.radius, ball.radius, .{0., 0.}, 0);

            shape : b2CircleShape;
            b2CircleShape.Constructor(*shape);
            shape.m_radius = ball.radius;

            fixture_def : b2FixtureDef;
            b2FixtureDef.Constructor(*fixture_def);
            fixture_def.shape = *shape;
            fixture_def.density = BALL_DENSITY;
            fixture_def.friction = BALL_FRICTION;
            fixture_def.restitution = BALL_RESTITUTION;
            b2Body.CreateFixture(ball.body, *fixture_def);

            array_add(*live_balls, ball);
        }
    }

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

        if event.type == .KEYBOARD {
            if event.key_code == {
                case #char "A"; player1.left =  event.key_pressed;
                case #char "D"; player1.right = event.key_pressed;

                case #char "J"; player2.left =  event.key_pressed;
                case #char "L"; player2.right = event.key_pressed;

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
        current_velocity := b2Body.GetLinearVelocity(body);
        desired_velocity := 0.;
        if left  desired_velocity = -PADDLE_SPEED;
        if right desired_velocity =  PADDLE_SPEED;

        velocity_change := desired_velocity - current_velocity.x;
        impulse := b2Body.GetMass(body) * velocity_change;
        b2Body.ApplyLinearImpulse(body, b2Vec2.{impulse, 0.}, b2Body.GetWorldCenter(body), true);
    }

    apply_impulse_to_move_player(player1);
    apply_impulse_to_move_player(player2);

    // // Apply a small force toward other player to prevent the ball getting stuck in a horizontal bounce
    for ball : live_balls {
        if ball.last_hit_player == {
            case 1; b2Body.ApplyForceToCenter(ball.body, b2Vec2.{0., -100.}, true);
            case 2; b2Body.ApplyForceToCenter(ball.body, b2Vec2.{0., 100.}, true);
        }
    }

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

main :: () {
    path := path_strip_filename(get_path_of_running_executable());
    data_folder = join(path, "data");
    print("data_folder is '%'\n", data_folder);

    last_time = get_time();

    window := create_window(window_name="Pong", width=window_width, height=window_height, window_x=2000, window_y=500);
    Simp.set_render_target(window);

    init_fonts();
    init_textures();


    world = New(b2World);
    b2World.Constructor(world, Vector2.{0., 0.}); // nocommit Zero gravity in this game

    box2d_debug_draw_transform :: (world : Vector2) -> Vector3 { return .{xy=world_to_screen(world)}; }
    box2d_debug_draw := create_box2d_debug_draw_using_simp(box2d_debug_draw_transform);
    defer free(box2d_debug_draw);

    b2Draw.AppendFlags(box2d_debug_draw, xx b2Draw.e_2.shapeBit);
    // b2Draw.AppendFlags(box2d_debug_draw, xx b2Draw.e_2.jointBit);
    // b2Draw.AppendFlags(box2d_debug_draw, xx b2Draw.e_2.aabbBit);
    // b2Draw.AppendFlags(box2d_debug_draw, xx b2Draw.e_2.pairBit);
    // b2Draw.AppendFlags(box2d_debug_draw, xx b2Draw.e_2.centerOfMassBit);

    b2World.SetDebugDraw(world, box2d_debug_draw);

    { // Create landscape aka play area
        // extents := Vector2.{GAME_EXTENTS.x, 1.}; //Vector2.{GAME_EXTENTS.x / 8., GAME_EXTENTS.y / 10.};
        extents := .25 * GAME_EXTENTS;
        center := Vector2.{0., -.75 * GAME_EXTENTS.y};
        angle := 0.;

        body_def : b2BodyDef;
        b2BodyDef.Constructor(*body_def);
        landscape = b2World.CreateBody(world, *body_def);

        // Shape coordinates are local to the body

        // Central box obstruction
        // shape : b2PolygonShape;
        // b2PolygonShape.Constructor(*shape);
        // b2PolygonShape.SetAsBox(*shape, extents.x, extents.y, .{}, angle);
        // b2Body.CreateFixture(landscape, *shape, 0.);

        edge_shape : b2EdgeShape;
        b2EdgeShape.Constructor(*edge_shape);

        fixture_def : b2FixtureDef;
        b2FixtureDef.Constructor(*fixture_def);
        fixture_def.shape = *edge_shape;
        fixture_def.density = 0.;
        fixture_def.friction = WALL_FRICTION;
        fixture_def.restitution = WALL_RESTITUTION;

        b2EdgeShape.SetTwoSided(*edge_shape, -GAME_EXTENTS, .{-GAME_EXTENTS.x, GAME_EXTENTS.y});
        b2Body.CreateFixture(landscape, *fixture_def);

        b2EdgeShape.SetTwoSided(*edge_shape, .{GAME_EXTENTS.x, -GAME_EXTENTS.y}, GAME_EXTENTS);
        b2Body.CreateFixture(landscape, *fixture_def);

        // // @temporary Remove this boundary when player 2 is implemented
        // b2EdgeShape.SetTwoSided(*edge_shape, .{-GAME_EXTENTS.x, GAME_EXTENTS.y}, GAME_EXTENTS);
        // b2Body.CreateFixture(landscape, *edge_shape, 0.);
    }

    init_player :: (using player : *Player, center_y : float) {
        center = Vector2.{0., center_y};
        color = Vector4.{.3, .2, 0, 1};

        body_def : b2BodyDef;
        b2BodyDef.Constructor(*body_def);
        body_def.type = .b2_dynamicBody;
        body_def.position = center;
        body = b2World.CreateBody(world, *body_def);

        b2Body.SetSleepingAllowed(body, false);

        shape : b2PolygonShape;
        b2PolygonShape.Constructor(*shape);
        b2PolygonShape.SetAsBox(*shape, extents.x, extents.y, .{}, 0.);

        fixture_def : b2FixtureDef;
        b2FixtureDef.Constructor(*fixture_def);
        fixture_def.shape = *shape;
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

    init_player(*player1, -GAME_EXTENTS.y + player1.extents.y);
    init_player(*player2,  GAME_EXTENTS.y - player2.extents.y);

    while !should_quit_game {
        reset_temporary_storage();

        Simp.clear_render_target(1, 0, 0, 1);

        update_window_events();

        simulate();

        draw_background();

        /*
        draw_b2PolygonShape(test_ground_shape, Vector4.{0, 0, 1, 1}); // nocommit We should be drawing via the body, to get the fixture, and then get the shape from that

        {
            fixture : *b2Fixture = b2Body.GetFixtureList(test_physics_ball);
            while fixture != null {
                shape : *b2Shape = b2Fixture.GetShape(fixture);
                if shape.m_type == {
                    case .polygon;
                        draw_b2PolygonShape(cast(*b2PolygonShape)shape, Vector4.{1, 0, 1, 1});
                    case;
                        print("Error\n");
                }
                fixture = b2Fixture.GetNext(fixture);
            }
        }
        */

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

        Simp.swap_buffers(window);

        // memory_visualizer_per_frame_update();
    }
}
