Mesh :: struct {
    vertices : [..]Vector2;
    triangles : [..]Tuple3;
}

deinit_mesh :: (mesh : Mesh) {
    array_reset(*mesh.vertices);
    array_reset(*mesh.triangles);
}

// Centered around the origin, short edge is above long edge
init_prism_mesh :: (mesh : Mesh, extents : Vector2, alpha : float) {

    array_add(*mesh.vertices, .{        0., -extents.y});
    array_add(*mesh.vertices, .{-extents.x, -extents.y});
    array_add(*mesh.vertices, .{ extents.x, -extents.y});
    array_add(*mesh.vertices, .{ extents.x - alpha * extents.x, extents.y});
    array_add(*mesh.vertices, .{-extents.x + alpha * extents.x, extents.y});

    // @Volatile :VariablePaddleRestitution Use three triangles here so we can have different restitutions on each
    array_add(*mesh.triangles, .{0, 3, 4});
    array_add(*mesh.triangles, .{0, 4, 1});
    array_add(*mesh.triangles, .{0, 2, 3});
}

// Centered around the origin
init_circle_mesh :: (mesh : Mesh, radius : float) {
    // @Cleanup use circle_segment_mesh instead?
    CIRCLE_SEGMENTS :: 16;
    CIRCLE_INCREMENT :: #run TAU / CIRCLE_SEGMENTS;
    sinInc := sin(CIRCLE_INCREMENT);
    cosInc := cos(CIRCLE_INCREMENT);

    r1 : Vector2 = .{cosInc, sinInc};
    v1 : Vector2 = radius * r1;
    t0 : s8 = 0;
    for i : 0..CIRCLE_SEGMENTS-1 {
        // Perform rotation to avoid additional trigonometry.
        r2 : Vector2 = ---;
        r2.x = cosInc * r1.x - sinInc * r1.y;
        r2.y = sinInc * r1.x + cosInc * r1.y;
        v2 : Vector2 = radius * r2;
        array_add(*mesh.vertices, .{0, 0});
        array_add(*mesh.vertices, v1);
        array_add(*mesh.vertices, v2);
        array_add(*mesh.triangles, .{t0, t0+1, t0+2});
        r1 = r2;
        v1 = v2;
        t0 += 3;
    }
}

circle_segment_mesh :: (mesh : Mesh, radius : float, start_angle_radians : float, wedge_angle_radians : float, segment_count : int) {

    sinInc := sin(wedge_angle_radians / segment_count);
    cosInc := cos(wedge_angle_radians / segment_count);

    r1 : Vector2 = .{cos(start_angle_radians), sin(start_angle_radians)};
    v1 : Vector2 = radius * r1;
    i0 : s8 = 0;
    for i : 0..segment_count-1 {
        // Perform rotation to avoid additional trigonometry.
        r2 : Vector2 = ---;
        r2.x = cosInc * r1.x - sinInc * r1.y;
        r2.y = sinInc * r1.x + cosInc * r1.y;
        v2 : Vector2 = radius * r2;
        array_add(*mesh.vertices, .{0, 0});
        array_add(*mesh.vertices, v1);
        array_add(*mesh.vertices, v2);
        array_add(*mesh.triangles, .{i0, i0+1, i0+2});
        r1 = r2;
        v1 = v2;
        i0 += 3;
    }

}

init_dome_mesh :: (mesh : Mesh, extents : Vector2, radius : float, segment_count : int) {
    // The calculations below only work when radius >= extents.x but the intention is that radius >> extents.x
    radius = max(radius, 2 * extents.x);

    wedge_angle := PI - 2 * acos(extents.x / radius);

    circle_segment_mesh(mesh, radius, acos(extents.x / radius), wedge_angle, segment_count);

    // Transform circle sector mesh to a circle segment mesh with the bottom at -extents.y
    delta_y := sqrt(radius*radius - extents.x*extents.x);
    for t : mesh.triangles {
        mesh.vertices[t.i].y -= extents.y;
        for d : 1..2 {
            v := *mesh.vertices[t.component[d]];
            v.y -= delta_y + extents.y;
        }
    }

    // Debug: shift up by exents.y
    // for * v : mesh.vertices v.y += extents.y;
}
