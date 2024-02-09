Entity :: struct {
    Kind :: enum {
        Unknown;
        Ball;
        Player;
        Life;
        //Obstruction;
        //PowerUp;
    }

    kind : Kind;
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
    GAME_OVER_MENU;
}

Game_Mode :: enum u8 {
    NOT_STARTED :: 0; // Here the game is not initted
    //INITIALIZING;
    PLAYING;
    PAUSED;
}

Ai_Skill :: enum {
    Moron;  // TODO Actively tries to lose
    Mindless; // Very dumb AI
    Smart;  // Uses simulation to make sure it wins?
}
#insert #run generate_dropdown_choices("ai_skill_choices", Ai_Skill);

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

Paddle_Shape :: enum u8 {
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

// @Volatile, keep synced with Player_Index
Player_Count :: enum u8 #specified {
    One_Player :: 0;
    Two_Player :: 1;
    //Three_Player :: 2;
}
#insert #run generate_dropdown_choices("player_count_choices", Player_Count);


Player_Index :: enum u8 #specified {
    P1 :: 0;
    P2 :: 1;
    //P3 :: 2;
    //P4 :: 4;
    UNKNOWN :: 0xFF; // @Cleanup Do we need this???
}

Obstruction :: struct {
    live : bool;

    mesh : Mesh;
    color : Vector4 = .{1., 1., 1., 1.};
    transform : b2Transform;

    body : *b2Body; // Physics. This is not initialized or used by clients!
}

Boundary :: struct {
    color : Vector4 = BOUNDARY_COLOR;
    shape : Polyline_Soup;

    body : *b2Body; // Physics. This is not initialized or used by clients!
}

Level :: struct {
    level_id : Level_Id;
    obstructions : [2]Obstruction;
    boundary : Boundary;
}

Ball :: struct {
    using #as base : Entity;
    base.kind = .Ball;

    player_index : Player_Index;
    live : bool; // Orthogonal to health, since we might want to disable a ball without changing its health
    health : float = BALL_MAX_HEALTH;

    shape : Ball_Shape;
    radius : float = BALL_INITIAL_RADIUS;

    mesh : Mesh;
    color : Vector4 = YELLOW;
    transform : b2Transform;

    // Used on the server only:

    // We get the transform from the physics simulation via this pointer
    // Note: The body shape is collision geometry not render geometry
    active_body : *b2Body; // Just points into body array, do not free
    body : [2]*b2Body; // Physics. This is not initialized or used by clients!
}

Player :: struct {
    using #as base : Entity;
    base.kind = .Player;

    index : Player_Index;

    paddle_shape : Paddle_Shape;
    mesh : Mesh;
    color : Vector4;
    transform : b2Transform;

    left : u32;
    right : u32;
    down : u32;
    up : u32;
    power1 : u32;
    power2 : u32;

    // Time warp stuff
    time_factor := 1.;
    warp_duration_remaining := WARP_DURATION_MAX;
    WARP_DURATION_MAX :: 1.5;
    WARP_START_THRESHOLD :: #run WARP_DURATION_MAX / 3.;

    lives : [PLAYER_MAX_LIVES]Life;

    // @Cleanup remove this
    score : int;

    // Some powerups will change the size of the player
    // Note: The body shape is collision geometry not render geometry
    body : *b2Body; // Physics. This is not initialized or used by clients!
}

Life :: struct {
    using #as base : Entity;
    base.kind = .Life;

    player_index : Player_Index;

    body : *b2Body;

    mesh : Mesh;
    transform : b2Transform;

    health : float = LIFE_MAX_HEALTH;
}




// - Game coordinates are in meters
// - Game origin, (0,0) is at the center of the window
// - Game occupies a central vertical strip of the window, P1 at the bottom, P2 at the top
// - Game playable area is padded left and right by GAME_PADDING
// - Depends on level (shape of play area)

// Tight bbox of the playable area. Half-width/height in meters
get_game_extents :: () -> Vector2, float {
    extents := Vector2.{10., 15.};
    return extents, .75 * extents.y;
}

get_goal_extents :: () -> Vector2 {
    padding := get_game_padding();
    extents := get_game_extents();
    return .{ .85 * extents.x, .7 * (.5*padding.y)};
}

// At least this much padding separates the game extents from the edge of the window, in game units
get_game_padding :: () -> Vector2 {
    return .{1., 3.};
}

// Result is in meters
get_game_size :: () -> Vector2 {
    return get_game_extents() + get_game_padding();
}

check_winning_condition :: () {
    is_player_dead :: (player : Player) -> bool {
        for player.lives {
            if it.health > 0 {
                return false;
            }
        }
        return true;
    }

    if #complete player_count == {
    case .One_Player; #through;
    case .Two_Player;
        player1_dead := is_player_dead(player1);
        player2_dead := is_player_dead(player2);
        if player1_dead && player2_dead {
            // Draw!
            game_over_text = "Draw!";
            game_menu = .GAME_OVER_MENU;
            game_mode = .PAUSED;
        } else if !player1_dead && player2_dead {
            game_over_text = "Player 1 Wins!"; // @Volatile search literal!
            game_menu = .GAME_OVER_MENU;
            game_mode = .PAUSED;
        } else if player1_dead && !player2_dead {
            game_over_text = "Player 2 Wins!"; // @Volatile search literal!
            game_menu = .GAME_OVER_MENU;
            game_mode = .PAUSED;
        } else {
            // Game continues
            game_over_text = "";
        }
    }
}

deinit_game :: () {
    // We can call deinit_game before game was initted if the client connects but disconnects before
    if game_mode != .NOT_STARTED {

        // In game entities the reverse order to initialization

        for * ball : balls {
            deinit_ball(ball);
        }

        deinit_player(*player2);
        deinit_player(*player1);

        deinit_obstructions();
        deinit_boundary();
        
        deinit_world(1);
        deinit_world(0);
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

init_game :: (init_game_state : Init_Game_State) {
    assert(game_mode == .NOT_STARTED);

    if host_type != .CLIENT {
        init_world(0);
        init_world(1);
    }

    // Reset any AI players
    ai_player = Ai_Player.{};

    player_count = init_game_state.player_count;
    
    level.level_id = init_game_state.level_id;
    init_boundary(); // Must come before players since they are constrained relative to the level boundary
    init_obstructions(0);
    init_obstructions(1);

    init_player(*player1, .P1, init_game_state.p1_paddle_shape);
    init_player(*player2, .P2, init_game_state.p2_paddle_shape);

    for * ball : balls {
        if it_index == {
            /*
            case 0;
                ball.color = POWERUP_BASE_COLOR;
                ball.radius = BALL_INITIAL_RADIUS;
                init_ball(ball, .Square);
            case 1;
                ball.radius = .7 * BALL_INITIAL_RADIUS;
                init_ball(ball, init_game_state.ball_shape);
            */
            case;
                if it_index % 2 == 0 {
                    ball.player_index = .P1;
                    ball.color = player1.color;
                } else {
                    ball.player_index = .P2;
                    ball.color = player2.color;
                }
                ball.radius = BALL_INITIAL_RADIUS;
                init_ball(ball, init_game_state.ball_shape);
        }
    }

    game_mode = .PLAYING;
}

deinit_ball :: (ball : *Ball) {
    log_verbose("deinit_ball");

    mesh_deinit(ball.mesh);

    if host_type != .CLIENT {
        deinit_ball_physics(ball, worlds[0]);
        deinit_ball_physics(ball, worlds[1]);
    }
}

init_ball :: (using ball : *Ball, initial_shape : Ball_Shape) {
    live = false;
    health = BALL_MAX_HEALTH;
    shape = initial_shape;

    if #complete shape == {
    case .Circle;
        init_circle_mesh(mesh, radius);
    case .Square;
        init_prism_mesh(mesh, .{radius, radius}, 0.);
    }

    if host_type != .CLIENT {
        init_ball_physics(ball, worlds[0]);
        init_ball_physics(ball, worlds[1]);
    }

    // play_sound(sound_start_game); // @todo find a nicer sound for this!
}

deinit_boundary :: () {
    deinit_polyline_soup(*level.boundary.shape);

    if host_type != .CLIENT {
        deinit_boundary_physics(worlds[0]);
        deinit_boundary_physics(worlds[1]);
    }
}

init_boundary :: () {
    // The goal should fit within the extents and padding (two player game!)
    assert(get_goal_extents().x < get_game_extents().x);
    assert(get_goal_extents().y < get_game_padding().y);

    game, game_dy := get_game_extents();
    goal := get_goal_extents();
    goal_corner := .8 * goal.y;
    edge_middle := BALL_INITIAL_RADIUS * sqrt(2.); // @Volatile

    left : *Polyline = array_add(*level.boundary.shape.polylines);
    array_add(*left.points,
        .{-goal.x, -game.y},
        .{-game.x, -game_dy},
        .{-game.x, -edge_middle},
        .{-game.x + edge_middle, 0.},
        .{-game.x,  edge_middle},
        .{-game.x,  game_dy},
        .{-goal.x,  game.y});

    right : *Polyline = array_add(*level.boundary.shape.polylines);
    array_add(*right.points,
        .{goal.x, -game.y},
        .{game.x, -game_dy},
        .{game.x, -edge_middle},
        .{game.x - edge_middle, 0.},
        .{game.x,  edge_middle},
        .{game.x,  game_dy},
        .{goal.x,  game.y});

    goal_p1 : *Polyline = array_add(*level.boundary.shape.polylines);
    array_add(*goal_p1.points,
        .{-goal.x, -game.y},
        .{-goal.x, -game.y - 2*goal.y + goal_corner},
        .{-goal.x + goal_corner, -game.y-2*goal.y},
        .{ goal.x - goal_corner, -game.y-2*goal.y},
        .{ goal.x, -game.y - 2*goal.y + goal_corner},
        .{ goal.x, -game.y});

    goal_p2 : *Polyline = array_add(*level.boundary.shape.polylines);
    array_add(*goal_p2.points,
    .{-goal.x,  game.y},
    .{-goal.x,  game.y + 2*goal.y - goal_corner},
    .{-goal.x + goal_corner, game.y+2*goal.y},
    .{ goal.x - goal_corner, game.y+2*goal.y},
    .{ goal.x,  game.y + 2*goal.y - goal_corner},
    .{ goal.x,  game.y});

    if host_type != .CLIENT {
        init_boundary_physics(worlds[0]);
        init_boundary_physics(worlds[1]);
    }
}

deinit_obstructions :: () {
    if host_type != .CLIENT {
        deinit_obstructions_physics(worlds[0]);
        deinit_obstructions_physics(worlds[1]);
    }
}

init_obstructions :: (index : int) {
    obstructions := *level.obstructions[index];

    if #complete level.level_id == {
    case .Empty;
        // Do nothing
    case .Fixed_Box; #through;
    case .Spinning_Box;
        extents := PADDLE_EXTENTS;
        transform : b2Transform;
        b2Transform.Constructor(*transform);

        obstructions.color = BOUNDARY_COLOR_NO_COLLISION;
        obstructions.color.w = 1.;

        // @Think Why is this needed with -release?? @CompilerBug??
        mesh_reset(*obstructions.mesh);

        mesh : Mesh;
        defer mesh_deinit(mesh);

#if true {
        init_prism_mesh(mesh, Vector2.{PADDLE_EXTENTS.x, PADDLE_EXTENTS.y}, 0.);
        // init_circle_mesh(mesh, 2*PADDLE_EXTENTS.y, 32);
        b2Transform.Set(*transform, .{}, PI);
        mesh_transform(*mesh, transform);
        mesh_merge(*obstructions.mesh, mesh);
} else {
        init_prism_mesh(mesh, extents, 0.);
        b2Transform.Set(*transform, .{0,  8*PADDLE_EXTENTS.y}, PI);
        mesh_transform(*mesh, transform);
        mesh_merge(*obstructions.mesh, mesh);

        mesh_reset(*mesh);
        init_prism_mesh(mesh, extents, 0.);
        b2Transform.Set(*transform, .{0, -8*PADDLE_EXTENTS.y}, 0.);
        mesh_transform(*mesh, transform);
        mesh_merge(*obstructions.mesh, mesh);

        // Close off the parallels
        //mesh_reset(*mesh);
        //init_prism_mesh(mesh, extents, 0.);
        //b2Transform.Set(*transform, .{0,  8*PADDLE_EXTENTS.y}, 0.);
        //mesh_transform(*mesh, transform);
        //b2Transform.Set(*transform, .{0, 0}, PI/2.);
        //mesh_transform(*mesh, transform);
        //mesh_merge(*obstructions.mesh, mesh);
}
    }

    if host_type != .CLIENT {
        init_obstructions_physics(ifx index == 0 then worlds[0] else worlds[1]);
    }
}


deinit_player :: (player : *Player) {
    player.score = 0;
    mesh_deinit(player.mesh);
    if host_type != .CLIENT {
        deinit_player_physics(player);
    }
}

init_player :: (using player : *Player, player_index : Player_Index, player_paddle_shape : Paddle_Shape) {

    player.* = Player.{};

    index = player_index;
    color = ifx index == .P1 then PLAYER1_COLOR else PLAYER2_COLOR;
    paddle_shape = player_paddle_shape;

    for row : 0..LIVES_GRID_ROWS-1 for col : 0..LIVES_GRID_COLS-1 {
        life := *lives[col + row * LIVES_GRID_COLS];
        life.player_index = player_index;
        if row == 2 {
            if col < 6 || col > LIVES_GRID_COLS-7 {
                life.health = LIFE_MAX_HEALTH / 2.;
            } else {
                life.health = LIFE_MAX_HEALTH;
            }
        } else {
            life.health = 0.;
        }
    }

    if #complete paddle_shape == {
    case .Box;
        init_prism_mesh(mesh, PADDLE_EXTENTS, 0.);
    case .Prism;
        init_prism_mesh(mesh, PADDLE_EXTENTS, 1./3.);
    case .Dome;
        init_dome_mesh(mesh, PADDLE_EXTENTS, 2. * PADDLE_EXTENTS.x, 55);
    }

    for * life : lives {
        // @Bug cannot use alpha=1. here, it triggers an assert in box2d.dll
        _, extents, _ := compute_square_grid(get_goal_extents(), LIVES_GRID_COLS, LIVES_GRID_ROWS, LIVES_GRID_SPACING);
        init_prism_mesh(life.mesh, extents, .0);
    }

    if host_type != .CLIENT {
        init_player_physics(player);
    }
}






// If rate_multiplier < 0. then this will be a count up
countdown :: (value_pointer: *float, rate_multiplier := 1.) {
    value := value_pointer.*;
    value -= rate_multiplier * current_dt;
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

compute_square_grid :: (outer_extents : Vector2, col_count : int, row_count : int, gap : float) -> (offset : Vector2, extents : Vector2, stride : Vector2) {
    dxdy := 2. * outer_extents - gap * Vector2.{cast(float)col_count+1, cast(float)row_count+1};
    extents_dxy := min(dxdy.x / col_count, dxdy.y / row_count) / 2;

    extents := Vector2.{extents_dxy, extents_dxy};

    offset : Vector2 = ---;
    offset.x = (2. * outer_extents.x - col_count * 2. * extents.x - (col_count-1) * gap) / 2.;
    offset.y = (2. * outer_extents.y - row_count * 2. * extents.y - (row_count-1) * gap) / 2.;

    stride := 2. * extents + Vector2.{gap, gap};

    return offset, extents, stride;
}