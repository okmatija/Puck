RED :: Vector4.{1,0,0,1};
GREEN :: Vector4.{0,1,0,1};
BLUE :: Vector4.{0,0,1,1};
YELLOW :: Vector4.{1,1,0,1};
WHITE :: Vector4.{1,1,1,1};
BLACK :: Vector4.{0,0,0,1};
GREY_50 :: Vector4.{.5,.5,.5,1};
GREY_65 :: Vector4.{.65,.65,.65,1};
GREY_70 :: Vector4.{.7,.7,.7,1};

PLAYER1_COLOR :: Vector4.{1.0, 0.3, 0.2, 1.0};
PLAYER2_COLOR :: Vector4.{0.5, 0.2, 0.7, 1.0};
LIFE_COLOR ::    Vector4.{0.7, 0.0, 0.2, 1.0};

BOUNDARY_COLOR :: Vector4.{0., .3, 0., 1.};
BOUNDARY_COLOR_NO_COLLISION :: Vector4.{0., .3, 0., .2};
POWERUP_BASE_COLOR :: GREY_70;

render_one_frame :: () {
    hide_cursor();

    Simp.clear_render_target(.8, .4, .5, 1);

    draw_game_background();

    // Cosmetics
    {
        game_extents := get_game_extents();
        edge_middle := BALL_INITIAL_RADIUS * sqrt(2.); // @Volatile
        draw_segment(.{-game_extents.x + edge_middle, 0}, .{game_extents.x - edge_middle, 0}, BOUNDARY_COLOR_NO_COLLISION, BOUNDARY_THICKNESS_PX);

        goal_extents := get_goal_extents();
        draw_segment(.{-goal_extents.x, -game_extents.y}, .{goal_extents.x, -game_extents.y}, BOUNDARY_COLOR_NO_COLLISION, BOUNDARY_THICKNESS_PX);
        draw_segment(.{-goal_extents.x,  game_extents.y}, .{goal_extents.x,  game_extents.y}, BOUNDARY_COLOR_NO_COLLISION, BOUNDARY_THICKNESS_PX);
        
        circle : Mesh;
        init_circle_mesh(*circle, 2*PADDLE_EXTENTS.x, 32);
        defer mesh_deinit(circle);
        color := BOUNDARY_COLOR_NO_COLLISION;
        color.w = .2;
        transform : b2Transform;
        b2Transform.Constructor(*transform);
        b2Transform.SetIdentity(*transform);
        draw_mesh(circle, transform, color);
    }


    if level.level_id != .Empty {
        for 0..1 {
            obstructions := *level.obstructions[it];
            use_color := ifx it == 0 then player1.color else player2.color;
            use_color.w = .9;
            draw_mesh(obstructions.mesh, obstructions.transform, use_color);
        }
    }

    // Debug the game size rect
    //game_size := get_game_size();
    //draw_segment(.{-game_size.x, -game_size.y}, .{ game_size.x,  game_size.y}, .{1, 0, 0, 1});
    //draw_segment(.{-game_size.x,  game_size.y}, .{ game_size.x, -game_size.y}, .{0, 1, 0, 1});

    draw_player :: (player : Player) {
        draw_mesh(player.mesh, player.transform, player.color);
        for life : player.lives {
            if life.health > 0 {

                use_color := lerp(BLACK, LIFE_COLOR, life.health/LIFE_MAX_HEALTH);
                draw_mesh(life.mesh, life.transform, use_color);

                // Simp.set_shader_for_images(*heart_map);
                // Simp.immediate_quad(
                //     world_to_screen(b2Mul(life.transform, life.mesh.vertices[1])),
                //     world_to_screen(b2Mul(life.transform, life.mesh.vertices[2])),
                //     world_to_screen(b2Mul(life.transform, life.mesh.vertices[3])),
                //     world_to_screen(b2Mul(life.transform, life.mesh.vertices[4])),
                //     use_color);
            }
        }
    }

    draw_player(player1);
    draw_player(player2);

    for :LiveBalls balls {
        if it.shape == .Square {
            Simp.set_shader_for_color(true);
            draw_mesh(it.mesh, it.transform, LIFE_COLOR);

            Simp.set_shader_for_images(*power_up_restore_all_life);
            Simp.immediate_quad(
                world_to_screen(b2Mul(it.transform, it.mesh.vertices[1])),
                world_to_screen(b2Mul(it.transform, it.mesh.vertices[2])),
                world_to_screen(b2Mul(it.transform, it.mesh.vertices[3])),
                world_to_screen(b2Mul(it.transform, it.mesh.vertices[4])),
                Vector4.{1,1,1,1});
        } else {

            draw_mesh(it.mesh, it.transform, it.color);

            // mesh : Mesh;
            // defer mesh_deinit(mesh);
            // init_circle_mesh(mesh, it.radius*.4, 32);
            // draw_mesh(mesh, it.transform, YELLOW);

            // edge_color := lerp(BLACK, it.color, it.health / BALL_MAX_HEALTH);
            // for t : it.mesh.triangles {
            //     start := b2Mul(it.transform, it.mesh.vertices[t.b]);
            //     end :=   b2Mul(it.transform, it.mesh.vertices[t.c]);
            //     draw_segment(start, end, edge_color, 2);
            // }
        }
    }

    for :PolylineSegmentIterator segment : level.boundary.shape {
        draw_segment(segment.from, segment.to, level.boundary.color, BOUNDARY_THICKNESS_PX);
    }


    for ball_explosions {
        r := it.radius;
        t := it.countdown/it.EXPLOSION_DURATION;
        use_color := lerp(BLACK, it.color, t);
        use_color.w = lerp(0., 1., t);

        // use_radius := 0.;
        // t_peak := .9;
        // if t < t_peak {
        //     use_radius = lerp(r, 3.*r, t/t_peak);
        // } else {
        //     use_radius = lerp(3.*r, 0., (t-t_peak)/(1.-t_peak));
        // }

        use_radius := lerp(0., r, t*t*t);

        circle : Mesh;
        init_circle_mesh(*circle, use_radius, 32);
        defer mesh_deinit(circle);
        transform : b2Transform;
        b2Transform.Constructor(*transform);
        b2Transform.Set(*transform, it.position, 0.);
        draw_mesh(circle, transform, use_color);
    }

    draw_aim_lasers(worlds[0]);
    draw_aim_lasers(worlds[1]);


    // Draw warp bars
    draw_warp_bar :: (using player : Player) {

        anchor : Vector2;
        if player.index == .P1 {
            anchor = .{-PADDLE_EXTENTS.x / 2., -get_game_extents().y - 2*get_goal_extents().y - 2*PADDLE_EXTENTS.y};
        } else if player.index == .P2 {
            anchor = .{-PADDLE_EXTENTS.x / 2.,  get_game_extents().y + 2*get_goal_extents().y + 1*PADDLE_EXTENTS.y};
        }

        // Remaining duration section
        {
            t := warp_duration_remaining / WARP_DURATION_MAX;
            max := PADDLE_EXTENTS.x;
            lo := world_to_screen(anchor);
            hi := world_to_screen(anchor + .{lerp(0., max, t), PADDLE_EXTENTS.y});
            Simp.immediate_quad(lo.x, lo.y, hi.x, hi.y, YELLOW);
        }

        // No start allowed section
        {
            t := min(warp_duration_remaining, WARP_START_THRESHOLD) / WARP_START_THRESHOLD;
            max := PADDLE_EXTENTS.x * (WARP_START_THRESHOLD / WARP_DURATION_MAX);
            lo := world_to_screen(anchor);
            hi := world_to_screen(anchor + .{lerp(0., max, t), PADDLE_EXTENTS.y});
            Simp.immediate_quad(lo.x, lo.y, hi.x, hi.y, BLUE);
        }

        // Border and hour glass notch
        {
            min, max := anchor, anchor + PADDLE_EXTENTS;
            draw_segment(.{min.x, min.y}, .{max.x, min.y}, GREY_65, 2.);
            draw_segment(.{max.x, min.y}, .{max.x, max.y}, GREY_65, 2.);
            draw_segment(.{max.x, max.y}, .{min.x, max.y}, GREY_65, 2.);
            draw_segment(.{min.x, max.y}, .{min.x, min.y}, GREY_65, 2.);

            notch : [3]Vector3;

            avg := (min + max) / 2.;
            len := PADDLE_EXTENTS;

            notch[0] = .{xy=world_to_screen(.{avg.x - .15 * len.x, max.y}), z=10.};
            notch[1] = .{xy=world_to_screen(.{avg.x + .15 * len.x, max.y}), z=10.};
            notch[2] = .{xy=world_to_screen(.{avg.x, max.y - .35 * len.y}), z=10.};
            Simp.immediate_triangle(notch[0], notch[1], notch[2], GREY_65, GREY_65, GREY_65);

            notch[0] = .{xy=world_to_screen(.{avg.x - .2 * len.x, min.y}), z=10.};
            notch[1] = .{xy=world_to_screen(.{avg.x + .2 * len.x, min.y}), z=10.};
            notch[2] = .{xy=world_to_screen(.{avg.x, min.y + .35 * len.y}), z=10.};
            Simp.immediate_triangle(notch[0], notch[1], notch[2], GREY_65, GREY_65, GREY_65);
        }
    }
    draw_warp_bar(player1);
    draw_warp_bar(player2);


    // Only draw the cursor if the mouse recently moved (the cursor is useful to resize the window)
    {
        current_mouse_x, current_mouse_y := get_client_mouse_pos(window);
        if current_mouse_x != previous_mouse_x || current_mouse_y != previous_mouse_y {
            draw_mouse_in_game_countdown = DRAW_MOUSE_IN_GAME_COUNTDOWN;
        }
        previous_mouse_x, previous_mouse_y = current_mouse_x, current_mouse_y;

        countdown(*draw_mouse_in_game_countdown);
        Clamp(*draw_mouse_in_game_countdown, -1., DRAW_MOUSE_IN_GAME_COUNTDOWN);

        if draw_mouse_in_game_countdown > 0 {
            draw_cursor();
        }
    }

    debug_draw_world :: (index : int) {
        // Draws the physics/collision geometry, this is a no-op if b2World.SetDebugDraw was not called
        if host_type == .CLIENT {
            return;
        }

        b2World.DebugDraw(worlds[index]);

        if DEBUG_DRAW_BOX2D_FLAGS[index] & b2Draw.jointBit {
            // An alternative way to draw joints (ported from dynamics/b2_joint.cpp)
            joint : *b2Joint = b2World.GetJointList(worlds[index]);
            while joint {
                draw_joint(world_debug_draws[index], joint);
                joint = b2Joint.GetNext(joint);
            }
        }
    }
    debug_draw_world(0);
    debug_draw_world(1);


    if DEBUG_DRAW {
        get_color :: (shape : *Debug_Shape) -> Vector4 {
            use_color := shape.color;
            t := shape.ttl / shape.__ttl_max;
            use_color.w = lerp(0, 1., pow(t, 5));
            return use_color;
        }

        for * debug_draw.segments {
            draw_segment(it.start, it.end, get_color(it), it.thickness);
            countdown(*it.ttl);
            if it.ttl <= 0 remove;
        }

        for * debug_draw.disks {
            mesh : Mesh;
            mesh_deinit(mesh);
            init_circle_mesh(*mesh, it.radius, 32);
            transform : b2Transform;
            b2Transform.Constructor(*transform);
            b2Transform.Set(*transform, it.center, 0.);
            draw_mesh(mesh, transform, get_color(it));

            countdown(*it.ttl);
            if it.ttl <= 0 remove;
        }
    }
}

draw_menu_logo :: () {
    t := cast(float)(sin(current_time) + 1.) / 2.;
    Clamp(*t, 0., 1.);
    use_color := lerp(WHITE, GREY_65, t);
    Simp.set_shader_for_images(*okpong_map);
    w, h : float = cast(float)window_width, cast(float)window_height;
    Simp.immediate_quad(
        .{w/3., h/2.},
        .{2.*w/3., h/2.},
        .{2.*w/3., h/2.+h/4},
        .{w/3., h/2.+h/4},
        use_color);
}


draw_cursor :: () {
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


draw_mesh :: (mesh : Mesh, transform : b2Transform, color : Vector4) {
    Simp.set_shader_for_color(true);

    apply :: (t : b2Transform, v : Vector2) -> Vector3 {
        return .{xy=world_to_screen(b2Mul(t, v))};
    }

    for t : mesh.triangles {
        a : Vector3 = apply(transform, mesh.vertices[t.i]);
        b : Vector3 = apply(transform, mesh.vertices[t.j]);
        c : Vector3 = apply(transform, mesh.vertices[t.k]);
        Simp.immediate_triangle(a, b, c, color, color, color);
    }
}

// SEGMENT_THICKNESS in simp units aka pixels
draw_segment :: (start_world : Vector2, end_world : Vector2, color : Vector4, SEGMENT_THICKNESS : float = .1) {
    Simp.set_shader_for_color(true);

    n := unit_vector(end_world - start_world);
    n.x, n.y = n.y, -n.x; // Rotate the unit direction by 90 degrees

    s := world_to_screen(start_world);
    e := world_to_screen(end_world);
    q0 := s + n * .5 * SEGMENT_THICKNESS;
    q3 := s - n * .5 * SEGMENT_THICKNESS;
    q2 := e - n * .5 * SEGMENT_THICKNESS;
    q1 := e + n * .5 * SEGMENT_THICKNESS;
    Simp.immediate_quad(q0, q1, q2, q3, color, color, color, color);
}


#scope_file

draw_game_background :: () {
    #if true {
        Simp.immediate_quad(.{0, 0}, .{xx window_width, 0}, .{xx window_width, xx window_height}, .{0, xx window_height},
            .{.3, .5, .7, 1},
            .{.3, .5, .7, 1},
            .{.6, .5, .5, 1},
            .{.6, .5, .5, 1},
            );
    } else {
        Simp.set_shader_for_images(*sky_map);
        Simp.immediate_quad(0, 0, xx window_width, xx window_height, Vector4.{1,1,1,1});
    }
}

// @TODO This could draw a tennis-like game board (use a dot-matrix fonts like in Hoop Land)
draw_score :: () {
    if player_count == .One_Player {
        return;
    }

    {
        text := sprint("%", player1.score);
        defer free(text);
        text_w := Simp.prepare_text(font, text);
        scale := 0.5;

        Simp.draw_prepared_text(font, window_width/2, font.character_height, .{.5, .8, .2, 1});
    }

    {
        text := sprint("%", player2.score);
        defer free(text);
        text_w := Simp.prepare_text(font, text);
        scale := 0.5;

        Simp.draw_prepared_text(font, window_width/2, window_height-font.character_height, .{.5, .8, .2, 1});
    }
}

// @TODOO Remove all the physics references from this file (implement a compile-time check for this..!)
draw_aim_lasers :: (world : *b2World) {
    for player_index : 0..1 {
        player := ifx player_index == 0 then *player1 else *player2;

        if trajectory[player_index].count == 0 {
            continue;
        }

        segment0 := *trajectory[player_index][0];
        length0 := length(segment0.position_end - segment0.position_start);
        laser_alpha := lerp(0., 1., pow(length0, 10.));

        for trajectory[player_index] {
            segment := *trajectory[player_index][it_index];

            if it_index == 0 {
                use_color_in, use_color_in_core := GREEN, player.color;
                use_color_in.w = laser_alpha;
                use_color_in_core.w = laser_alpha;

                draw_segment(segment.position_start, segment.position_end, use_color_in, LASER_THICKNESS);
                draw_segment(segment.position_start, segment.position_end, use_color_in_core, LASER_THICKNESS_CORE);
            } else {
                use_color_out, use_color_out_core := player.color, player.color;
                use_color_out.w = laser_alpha;
                use_color_out_core.w = laser_alpha;

                draw_segment(segment.position_start, segment.position_end, use_color_out, LASER_THICKNESS);
                draw_segment(segment.position_start, segment.position_end, use_color_out_core, LASER_THICKNESS_CORE);
            }
        }
    }
}
