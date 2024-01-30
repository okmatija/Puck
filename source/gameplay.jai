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






countdown :: (value_pointer: *float) {
    value := value_pointer.*;
    value -= current_dt;
    if value < 0 {
        value = 0; // @Think Does this give consistent countdowns?
    }
    value_pointer.* = value;
}






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
