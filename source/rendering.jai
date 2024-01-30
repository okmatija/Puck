WHITE :: Vector4.{1,1,1,1};
GREY_50 :: Vector4.{.5,.5,.5,1};
GREY_70 :: Vector4.{.7,.7,.7,1};

BOUNDARY_COLOR :: WHITE;
BOUNDARY_COLOR_NO_COLLISION :: GREY_50;
POWERUP_BASE_COLOR :: GREY_70;

render_one_frame :: () {
    hide_cursor();

    Simp.clear_render_target(0, 0, 0, 1);
    draw_game_background();

    Simp.set_shader_for_color(true);

    // Cosmetics
    {
        game_extents := get_game_extents();
        draw_segment(.{-game_extents.x, 0}, .{game_extents.x, 0}, BOUNDARY_COLOR_NO_COLLISION);
        
        circle : Mesh;
        init_circle_mesh(*circle, PADDLE_EXTENTS.x, 32);
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

    for :PolylineSegmentIterator segment : level.boundary.shape {
        draw_segment(segment.from, segment.to, level.boundary.color);
    }

    draw_mesh(player1.mesh, player1.transform, player1.color);
    draw_mesh(player2.mesh, player2.transform, player2.color);

    for :LiveBalls balls {
        draw_mesh(it.mesh, it.transform, it.color);
    }

    draw_score();

    draw_powerups();

    // @TODOOO Only draw if the mouse recently moved?
    draw_cursor();

    // Draws the physics/collision geometry
    //b2World.DebugDraw(world);
}

draw_menu_background :: () {
    Simp.set_shader_for_images(*menu_map);
    Simp.immediate_quad(0, 0, xx window_width, xx window_height, Vector4.{1,1,1,1});
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

#scope_file

draw_game_background :: () {
    Simp.set_shader_for_images(*sky_map);
    Simp.immediate_quad(0, 0, xx window_width, xx window_height, Vector4.{1,1,1,1});
}

draw_mesh :: (mesh : Mesh, transform : b2Transform, color : Vector4) {
    apply :: (t : b2Transform, v : Vector2) -> Vector3 {
        return .{xy=world_to_screen(apply_transform(t, v))};
    }

    for t : mesh.triangles {
        a : Vector3 = apply(transform, mesh.vertices[t.i]);
        b : Vector3 = apply(transform, mesh.vertices[t.j]);
        c : Vector3 = apply(transform, mesh.vertices[t.k]);
        Simp.immediate_triangle(a, b, c, color, color, color);
    }
}

draw_segment :: (start : Vector2, end : Vector2, color : Vector4) {
    SEGMENT_THICKNESS :: 1.; // Simp units aka pixels

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

draw_powerups :: () {
    text_w := Simp.prepare_text(font, "Warp");
    scale := 0.5;

    warp_ready_color :: Vector4.{.8, .2, .0, 1.};
    warp_active_color :: Vector4.{.6, .6, .6, 1.};

    Simp.draw_prepared_text(font,
        window_width - 3 * window_width/30,
        font.character_height/2,
        ifx player1.warp_active then warp_active_color else warp_ready_color);

    if player_count >= .Two_Player {
        Simp.draw_prepared_text(font,
            window_width - 3 * window_width/30,
            window_height - font.character_height,
            ifx player2.warp_active then warp_active_color else warp_ready_color);
    }
}

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
