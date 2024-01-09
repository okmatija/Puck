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

    array_add(*mesh.vertices, .{-extents.x, -extents.y});
    array_add(*mesh.vertices, .{ extents.x, -extents.y});
    array_add(*mesh.vertices, .{ extents.x - alpha * extents.x, extents.y});
    array_add(*mesh.vertices, .{-extents.x + alpha * extents.x, extents.y});

    array_add(*mesh.triangles, .{0, 1, 2});
    array_add(*mesh.triangles, .{0, 2, 3});
}

// Centered around the origin
init_circle_mesh :: (mesh : Mesh, radius : float) {
    CIRCLE_SEGMENTS :: 16;
    CIRCLE_INCREMENT :: #run TAU / CIRCLE_SEGMENTS;
    sinInc := sin(CIRCLE_INCREMENT);
    cosInc := cos(CIRCLE_INCREMENT);

    r1 : Vector2 = .{cosInc, sinInc};
    v1 : Vector2 = radius * r1;
    t0 : s8 = 0;
    for i : 0..CIRCLE_SEGMENTS-1 {
        // Perform rotation to avoid additional trigonometry.
        r2 : b2Vec2 = ---;
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
