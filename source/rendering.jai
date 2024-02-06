RED :: Vector4.{1,0,0,1};
GREEN :: Vector4.{0,1,0,1};
BLUE :: Vector4.{0,0,1,1};
YELLOW :: Vector4.{1,1,0,1};
WHITE :: Vector4.{1,1,1,1};
BLACK :: Vector4.{0,0,0,1};
GREY_50 :: Vector4.{.5,.5,.5,1};
GREY_65 :: Vector4.{.65,.65,.65,1};
GREY_70 :: Vector4.{.7,.7,.7,1};

PLAYER1_COLOR :: Vector4.{1., .3, .2, 1.};
PLAYER2_COLOR :: Vector4.{.5, 0., 1., 1.};
LIFE_COLOR ::    Vector4.{.7, 0., .2, 1.};

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
        draw_mesh(level.obstructions.mesh, level.obstructions.transform, level.obstructions.color);
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
            use_color := lerp(BLACK, it.color, it.health / BALL_MAX_HEALTH);
            draw_mesh(it.mesh, it.transform, use_color);

            for t : it.mesh.triangles {
                start := b2Mul(it.transform, it.mesh.vertices[t.b]);
                end :=   b2Mul(it.transform, it.mesh.vertices[t.c]);
                edge_color := YELLOW;
                edge_color.w = .7;
                draw_segment(start, end, edge_color, 2);
            }
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

        use_radius := 0.;
        t_peak := .9;
        if t < t_peak {
            use_radius = lerp(r, 3.*r, t/t_peak);
        } else {
            use_radius = lerp(3.*r, 0., (t-t_peak)/(1.-t_peak));
        }

        circle : Mesh;
        init_circle_mesh(*circle, use_radius, 32);
        defer mesh_deinit(circle);
        transform : b2Transform;
        b2Transform.Constructor(*transform);
        b2Transform.Set(*transform, it.position, 0.);
        draw_mesh(circle, transform, use_color);
    }

    draw_aim_lasers();


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

    if DEBUG_DRAW_BOX2D {
        // Draws the physics/collision geometry
        b2World.DebugDraw(world);
    }


    if DEBUG_DRAW {
        for debug_draw.segments {
            draw_segment(it.start, it.end, it.color, it.thickness);
        }
        array_reset(*debug_draw.segments);
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
draw_segment :: (start : Vector2, end : Vector2, color : Vector4, SEGMENT_THICKNESS : float = .1) {
    Simp.set_shader_for_color(true);

    n := unit_vector(end - start);
    n.x, n.y = n.y, -n.x; // Rotate the unit direction by 90 degrees

    s := world_to_screen(start);
    e := world_to_screen(end);
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
            .{.6, .5, .5, 1},
            .{.6, .5, .5, 1},
            .{.3, .5, .9, 1},
            .{.3, .5, .9, 1},
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

draw_aim_lasers :: () {
    for :LiveBalls ball : balls {
        if host_type == .SERVER && ball.player_index != .P1 continue;
        if host_type == .CLIENT && ball.player_index != .P2 continue;

        player := ifx ball.player_index == .P1 then *player1 else *player2;

        // @Cleanup Get this from the ball
        ball_shape : b2CircleShape;
        b2CircleShape.Constructor(*ball_shape);
        ball_shape.m_radius = BALL_INITIAL_RADIUS;

        // @Cleanup Get this from the player?
        paddle_shape : b2CircleShape;
        b2CircleShape.Constructor(*paddle_shape);
        paddle_shape.m_radius = 2. * PADDLE_EXTENTS.x;

        dpa : b2DistanceProxy;
        b2DistanceProxy.Constructor(*dpa);
        b2DistanceProxy.Set(*dpa, *paddle_shape, 0);

        dpb : b2DistanceProxy;
        b2DistanceProxy.Constructor(*dpb);
        b2DistanceProxy.Set(*dpb, *ball_shape, 0);

        input : b2ShapeCastInput;
        input.proxyA = dpa;
        input.proxyB = dpb;
        input.transformA = b2Body.GetTransform(player.body).*;

        radius := 2. * PADDLE_EXTENTS.x;
        extents := PADDLE_EXTENTS;
        delta_y := sqrt(radius*radius - extents.x*extents.x) + PADDLE_EXTENTS.y;
        shift : b2Transform;
        b2Transform.Constructor(*shift);
        b2Transform.Set(*shift, .{0, -delta_y}, 0.);
        input.transformA = b2Mul(input.transformA, shift);

        input.transformB = b2Body.GetTransform(ball.body).*;
        input.translationB = 100. * unit_vector(b2Body.GetLinearVelocity(ball.body));

        output : b2ShapeCastOutput;

        hit := b2ShapeCast(*output, *input);
        origin := output.point + ball.radius * output.normal;

        allowed := false;
        {
            radius := 2. * PADDLE_EXTENTS.x;
            extents := PADDLE_EXTENTS;
            delta_y := sqrt(radius*radius - extents.x*extents.x);
            offset_y := delta_y / radius * ball.radius;

            if player.index == {
            case .P1;
                allowed = origin.y > -get_game_extents().y + offset_y;
            case .P2;
                allowed = origin.y < get_game_extents().y - offset_y;
            }
        }

        if hit && allowed {

            dir_in := origin - b2Body.GetPosition(ball.body);
            dir_out := -reflect_vector(dir_in, output.normal);

            unit_in := unit_vector(dir_in);
            unit_out := unit_vector(dir_out);
            game_radius := 2 * length(get_game_extents());

            laser_alpha := lerp(0., 1., pow(length(dir_in), 10.));

            use_color_in, use_color_in_core := GREEN, player.color;
            use_color_in.w = laser_alpha;
            use_color_in_core.w = laser_alpha;

            center := b2Body.GetPosition(ball.body).*;
            draw_segment(origin, center + ball.radius * unit_in, use_color_in, LASER_THICKNESS);
            draw_segment(origin, center + ball.radius * unit_in, use_color_in_core, LASER_THICKNESS_CORE);

            ray_cast_callback_data = .{}; // Clear previous result
            ray_cast_callback_data.ignore_body = ball.body;
            b2World.RayCast(world, *ray_cast_callback, origin, origin + game_radius*unit_out);

            use_color_out, use_color_out_core := RED, player.color;
            use_color_out.w = laser_alpha;
            use_color_out_core.w = laser_alpha;

            if ray_cast_callback_data.fraction && use_color_in.w > 0.05 {
                target := origin + ray_cast_callback_data.fraction * game_radius * unit_out;
                draw_segment(origin, target, use_color_out, LASER_THICKNESS);
                draw_segment(origin, target, use_color_out_core, LASER_THICKNESS_CORE);
            }
        }
    }
}
