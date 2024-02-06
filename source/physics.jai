
init_world :: () {
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

    contact_listener.vtable = New(b2ContactListener_VTable); // @Leak
    contact_listener.vtable.BeginContact = contact_listener_begin_contact;
    contact_listener.vtable.EndContact = contact_listener_end_contact;
    contact_listener.vtable.PreSolve = contact_listener_pre_solve;
    contact_listener.vtable.PostSolve = contact_listener_post_solve;
    contact_listener.vtable.Destructor = contact_listener_destructor;
    b2World.SetContactListener(world, *contact_listener);

    // Setup ray cast callback used to render lasers for aiming
    ray_cast_callback.vtable = New(b2RayCastCallback_VTable); // @Leak
    ray_cast_callback.vtable.ReportFixture = ray_cast_report_fixture;
    ray_cast_callback.vtable.Destructor = ray_cast_callback_destructor;
}

ray_cast_report_fixture :: (this: *b2RayCastCallback, fixture: *b2Fixture, point: *b2Vec2, normal: *b2Vec2, fraction: float) -> float #cpp_method {
    new_context : Context;
    push_context new_context {
        body := b2Fixture.GetBody(fixture);
        if body == ray_cast_callback_data.ignore_body {
            // Ignore this collision: don't update data and don't change the ray length
            return 1.;
        }

        if fraction < ray_cast_callback_data.fraction {
            ray_cast_callback_data.fraction = fraction;
            ray_cast_callback_data.fixture = fixture;
            ray_cast_callback_data.point = point;
            ray_cast_callback_data.normal = normal;
        }
        return fraction;
    }
}

ray_cast_callback_destructor :: (this: *b2RayCastCallback, flags: Msvc_Destructor_Flags = .NONE) -> void #cpp_method {}





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
    fixture_def.filter.categoryBits = Ball_Category;
    fixture_def.filter.maskBits = Ball_Mask;
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

        add_fixture_from_mesh(level.obstructions.body, level.obstructions.mesh, Boundary_Category, Boundary_Mask);

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
    fixture_def.filter.categoryBits = Boundary_Category;
    fixture_def.filter.maskBits = Boundary_Mask;
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

    offset, extents, stride := compute_square_grid(get_goal_extents(), LIVES_GRID_COLS, LIVES_GRID_ROWS, .1);
    anchor := Vector2.{get_goal_extents().x, 2 * get_goal_extents().y + get_game_extents().y};
    
    for row : 0..LIVES_GRID_ROWS-1 for col : 0..LIVES_GRID_COLS-1 {
        life := *lives[col + row * LIVES_GRID_COLS];
        user_data : b2BodyUserData;
        b2BodyUserData.Constructor(*user_data);
        user_data.pointer = xx life;

        body_def : b2BodyDef;
        b2BodyDef.Constructor(*body_def);
        body_def.userData = user_data;
        body_def.type = .b2_staticBody;
        if index == {
        case .P1;
            body_def.position = -anchor + offset + extents + Vector2.{stride.x * col, stride.y * row};
            body_def.angle = 0.;
        case .P2;
            body_def.position =  anchor - offset - extents - Vector2.{stride.x * col, stride.y * row};
            body_def.angle = PI;
        }
        life.body = b2World.CreateBody(world, *body_def);

        add_fixture_from_mesh(life.body, life.mesh, Life_Category, Life_Mask);
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
                fixture_def.filter.categoryBits = Player_Category;
                fixture_def.filter.maskBits = Player_Mask;
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
                fixture_def.filter.categoryBits = Player_Category;
                fixture_def.filter.maskBits = Player_Mask;
                fixture_def.shape = *polygon_shape;
                fixture_def.density = PADDLE_DENSITY;
                fixture_def.friction = PADDLE_FRICTION;
                fixture_def.restitution = .5 * PADDLE_RESTITUTION;
                b2Body.CreateFixture(body, *fixture_def);
            }

        case .Dome;

            radius := 2. * PADDLE_EXTENTS.x;
            extents := PADDLE_EXTENTS;
            delta_y := sqrt(radius*radius - extents.x*extents.x);

            circle_shape : b2CircleShape;
            b2CircleShape.Constructor(*circle_shape);
            circle_shape.m_radius = radius;
            circle_shape.m_p.y = -delta_y - PADDLE_EXTENTS.y;

            circle_fixture_user_data : b2FixtureUserData;
            b2FixtureUserData.Constructor(*circle_fixture_user_data);
            circle_fixture_user_data.pointer = xx player;

            fixture_def : b2FixtureDef;
            b2FixtureDef.Constructor(*fixture_def);
            fixture_def.filter.categoryBits = Player_Category;
            fixture_def.filter.maskBits = Player_Mask;
            fixture_def.userData = xx circle_fixture_user_data;
            fixture_def.shape = *circle_shape;
            fixture_def.density = PADDLE_DENSITY;
            fixture_def.friction = PADDLE_FRICTION;
            fixture_def.restitution = .5 * PADDLE_RESTITUTION;
            b2Body.CreateFixture(body, *fixture_def);

            // Just to get collisions working with the bottom of the paddle

            bottom_mesh : Mesh;
            defer mesh_deinit(bottom_mesh);
            bottom_extents := PADDLE_EXTENTS;
            bottom_extents.y *= .5;
            init_prism_mesh(bottom_mesh, bottom_extents, .9);
            for * bottom_mesh.vertices {
                it.y -= bottom_extents.y;
            }
            add_fixture_from_mesh(body, bottom_mesh, Player_Category, Player_Mask);
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

get_angular_velocity :: (body : *b2Body) -> float {
    return b2Body.GetAngularVelocity(body);
}

get_linear_velocity :: (body : *b2Body) -> Vector2 {
    return b2Body.GetLinearVelocity(body).*;
}

get_position :: (body : *b2Body) -> Vector2 {
    return b2Body.GetPosition(body).*;
}

apply_linear_impulse_to_center :: (body : *b2Body, impulse : Vector2, wake := true) {
    b2Body.ApplyLinearImpulseToCenter(body, impulse, wake);
}

ray_cast_callback : b2RayCastCallback;
ray_cast_callback_data : Ray_Cast_Callback_Data;
Ray_Cast_Callback_Data :: struct {
    fixture: *b2Fixture;
    point: *b2Vec2;
    normal: *b2Vec2;
    fraction: float = FLOAT32_INFINITY;

    ignore_body : *b2Body; // We will set this to the ball whose trajectory we are inspecting via ray cast
}

#scope_file

add_fixture_from_mesh :: (body : *b2Body, mesh : Mesh, category_bits : u16, mask_bits : u16) {
    for t : mesh.triangles {
        polygon_shape : b2PolygonShape;
        b2PolygonShape.Constructor(*polygon_shape);
        points : [3]Vector2 = .[mesh.vertices[t.i], mesh.vertices[t.j], mesh.vertices[t.k]];
        b2PolygonShape.Set(*polygon_shape, points.data, 3);

        // No friction or energy loss for obstruction collisions, so its less likely balls get stuck
        fixture_def : b2FixtureDef;
        b2FixtureDef.Constructor(*fixture_def);
        fixture_def.filter.categoryBits = category_bits;
        fixture_def.filter.maskBits = mask_bits;
        fixture_def.shape = *polygon_shape;
        fixture_def.density = PADDLE_DENSITY;
        fixture_def.friction = 0.;
        fixture_def.restitution = 1.;
        b2Body.CreateFixture(body, *fixture_def);
    }
}

// See the default implementation of b2ContactFilter::ShouldCollide to understand categories/masks(/groups):
/*
// Return true if contact calculations should be performed between these two shapes.
// If you implement your own collision filter you may want to build from this implementation.
bool b2ContactFilter::ShouldCollide(b2Fixture* fixtureA, b2Fixture* fixtureB)
{
	const b2Filter& filterA = fixtureA->GetFilterData();
	const b2Filter& filterB = fixtureB->GetFilterData();

	if (filterA.groupIndex == filterB.groupIndex && filterA.groupIndex != 0)
	{
		return filterA.groupIndex > 0;
	}

	bool collide = (filterA.maskBits & filterB.categoryBits) != 0 && (filterA.categoryBits & filterB.maskBits) != 0;
	return collide;
}
*/

// @Cleanup make these #type,isa?

// Box2D collision categories (I am a...)
Player_Category : u16 : 0x0001;
Ball_Category : u16 : 0x0002;
Life_Category : u16 : 0x0004;
Boundary_Category : u16 : 0x0008;

// Box2D collision masks (I will collide with...)
Player_Mask : u16 : #run 0xFFFF ^ Boundary_Category;
Ball_Mask : u16 : 0xFFFF; // Everything
Life_Mask : u16 : Ball_Category;
Boundary_Mask : u16 : Ball_Category;

