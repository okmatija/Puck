
init_world :: () {
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






init_ball_physics :: (ball : *Ball) {
    assert(host_type == .SERVER || host_type == .LOCAL);

    user_data : b2BodyUserData;
    b2BodyUserData.Constructor(*user_data);
    user_data.pointer = xx ball;

    body_def : b2BodyDef;
    b2BodyDef.Constructor(*body_def);
    body_def.type = .b2_dynamicBody;
    body_def.bullet=true; // Balls can move very fast!
    body_def.userData = user_data;

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
        fixture_def.density = BALL_DENSITY;
        fixture_def.friction = BALL_FRICTION;
        fixture_def.restitution = BALL_RESTITUTION;
    case .Square;
        fixture_def.shape = *square_shape;
        fixture_def.density = 20 * BALL_DENSITY;
        fixture_def.friction = BALL_FRICTION;
        fixture_def.restitution = BALL_RESTITUTION;
    }
    b2Body.CreateFixture(ball.body, *fixture_def);

    b2Body.SetEnabled(ball.body, false);
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






init_player_physics :: (using player : *Player) {
    assert(host_type == .SERVER || host_type == .LOCAL);

    game_extents := get_game_extents();

    user_data : b2BodyUserData;
    b2BodyUserData.Constructor(*user_data);
    user_data.pointer = xx player;

    for * life : lives {
        game_size := get_game_size();
        dy := BALL_RADIUS_INITIAL;
        dx := game_extents.x / PLAYER_MAX_LIVES;

        user_data : b2BodyUserData;
        b2BodyUserData.Constructor(*user_data);
        user_data.pointer = xx life;

        body_def : b2BodyDef;
        b2BodyDef.Constructor(*body_def);
        body_def.userData = user_data;
        body_def.type = .b2_staticBody;
        if index == {
        case .P1;
            body_def.position = Vector2.{(xx it_index+.5)*dx - game_extents.x/2, -game_size.y + 2.5*dy};
            body_def.angle = PI;
        case .P2;
            body_def.position = Vector2.{(xx it_index+.5)*dx - game_extents.x/2,  game_size.y - 2.5*dy};
            body_def.angle = 0;
        }
        life.body = b2World.CreateBody(world, *body_def);

        add_fixture_from_mesh(life.body, life.mesh);
    }

    body_def : b2BodyDef;
    b2BodyDef.Constructor(*body_def);
    body_def.userData = user_data;
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





kinetic_energy :: (body : *b2Body) -> float {
    omega : float = b2Body.GetAngularVelocity(body);
    velocity : b2Vec2 = b2Body.GetLinearVelocity(body);
    mass_data : b2MassData;
    b2Body.GetMassData(body, *mass_data);
    return .5 * mass_data.mass * dot_product(velocity, velocity) + .5 * mass_data.I * omega * omega;
}



#scope_file

add_fixture_from_mesh :: (body : *b2Body, mesh : Mesh) {
    for t : mesh.triangles {
        polygon_shape : b2PolygonShape;
        b2PolygonShape.Constructor(*polygon_shape);
        points : [3]Vector2 = .[mesh.vertices[t.i], mesh.vertices[t.j], mesh.vertices[t.k]];
        b2PolygonShape.Set(*polygon_shape, points.data, 3);

        // No friction or energy loss for obstruction collisions, so its less likely balls get stuck
        fixture_def : b2FixtureDef;
        b2FixtureDef.Constructor(*fixture_def);
        fixture_def.shape = *polygon_shape;
        fixture_def.density = PADDLE_DENSITY;
        fixture_def.friction = 0.;
        fixture_def.restitution = 1.;
        b2Body.CreateFixture(body, *fixture_def);
    }
}
