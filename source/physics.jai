deinit_world :: (index : int) {
    free(world_debug_draws[index]);
    free(worlds[index]);
}

// @FIXMEEE WE stop the old contact_listener and ray_cast_callback here, also they are not freed
init_world :: (index : int) {
    worlds[index] = New(b2World); // @Leak
    b2World.Constructor(worlds[index], Vector2.{0., 0.});

    // Setup contact listener which is used for game simulation e.g., plays sounds, filters collisions etc
    contact_listener.vtable = New(b2ContactListener_VTable); // @Leak
    contact_listener.vtable.BeginContact = contact_listener_begin_contact;
    contact_listener.vtable.EndContact = contact_listener_end_contact;
    contact_listener.vtable.PreSolve = contact_listener_pre_solve;
    contact_listener.vtable.PostSolve = contact_listener_post_solve;
    contact_listener.vtable.Destructor = contact_listener_destructor;
    b2World.SetContactListener(worlds[index], *contact_listener);

    // Setup ray cast callback used to render lasers for aiming
    ray_cast_callback.vtable = New(b2RayCastCallback_VTable); // @Leak
    ray_cast_callback.vtable.ReportFixture = ray_cast_report_fixture;
    ray_cast_callback.vtable.Destructor = ray_cast_callback_destructor;

    // Setup debug drawing stuff
    world_debug_draw_transform :: (p_world : Vector2) -> Vector3 { return .{xy=world_to_screen(p_world)}; }
    world_debug_draws[index] = create_box2d_debug_draw_using_simp(world_debug_draw_transform);
    b2Draw.SetFlags(world_debug_draws[index], xx DEBUG_DRAW_BOX2D_FLAGS[index]);
    b2World.SetDebugDraw(worlds[index], world_debug_draws[index]);
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



deinit_ball_physics :: (ball : *Ball, world : *b2World) {
    assert(host_type == .SERVER || host_type == .LOCAL);

    body : **b2Body;
    if world == worlds[0] then body = *ball.body[0];
    else if world == worlds[1] then body = *ball.body[1];
    else assert(false);

    b2World.DestroyBody(world, body.*);
}

init_ball_physics :: (ball : *Ball, world : *b2World) {
    assert(host_type == .SERVER || host_type == .LOCAL);

    user_data : b2BodyUserData;
    b2BodyUserData.Constructor(*user_data);
    user_data.pointer = xx ball;

    body_def : b2BodyDef;
    b2BodyDef.Constructor(*body_def);
    body_def.type = .b2_dynamicBody;
    body_def.bullet=true; // Balls can move very fast!
    body_def.userData = user_data;

    body : **b2Body;
    if world == worlds[0] then body = *ball.body[0];
    else if world == worlds[1] then body = *ball.body[1];
    else assert(false);

    body.* = b2World.CreateBody(world, *body_def);
    ball.active_body = body.*; // Arbitrary

    b2Body.SetSleepingAllowed(body.*, false);

    circle_shape : b2CircleShape;
    b2CircleShape.Constructor(*circle_shape);
    circle_shape.m_radius = ball.radius;

    square_shape : b2PolygonShape;
    b2PolygonShape.Constructor(*square_shape);
    b2PolygonShape.SetAsBox(*square_shape, ball.radius, ball.radius, .{0., 0.}, 0);

    fixture_def : b2FixtureDef;
    b2FixtureDef.Constructor(*fixture_def);
    fixture_def.filter.categoryBits = BALL_CATEGORY;
    fixture_def.filter.maskBits = BALL_MASK;
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
    b2Body.CreateFixture(body.*, *fixture_def);

    b2Body.SetEnabled(body.*, false);
}



deinit_obstructions_physics :: (world : *b2World) {
    assert(host_type == .SERVER || host_type == .LOCAL);

    obstructions := ifx world == worlds[0] then *level.obstructions[0] else *level.obstructions[1];
    if obstructions.body {
        b2World.DestroyBody(world, obstructions.body);
    }
}

init_obstructions_physics :: (world : *b2World) {
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

        obstructions := ifx world == worlds[0] then *level.obstructions[0] else *level.obstructions[1];
        obstructions.body = body;

        add_fixture_from_mesh(obstructions.body, obstructions.mesh, BOUNDARY_CATEGORY, BOUNDARY_MASK);

        joint_def : b2PrismaticJointDef;
        b2PrismaticJointDef.Constructor(*joint_def);
        b2PrismaticJointDef.Initialize(*joint_def, level.boundary.body, body, .{}, .{1., 0.});
        if level.level_id == .Spinning_Box {
            b2Body.SetAngularVelocity(body, .25);
        }
    }
}



deinit_boundary_physics :: (world : *b2World) {
    assert(host_type == .SERVER || host_type == .LOCAL);

    b2World.DestroyBody(world, level.boundary.body);
}

init_boundary_physics :: (world : *b2World) {
    assert(host_type == .SERVER || host_type == .LOCAL);

    body_def : b2BodyDef;
    b2BodyDef.Constructor(*body_def);
    level.boundary.body = b2World.CreateBody(world, *body_def);

    // Shape coordinates are local to the body

    edge_shape : b2EdgeShape;
    b2EdgeShape.Constructor(*edge_shape);

    fixture_def : b2FixtureDef;
    b2FixtureDef.Constructor(*fixture_def);
    fixture_def.filter.categoryBits = BOUNDARY_CATEGORY;
    fixture_def.filter.maskBits = BOUNDARY_MASK;
    fixture_def.shape = *edge_shape;
    fixture_def.density = 0.;
    fixture_def.friction = WALL_FRICTION;
    fixture_def.restitution = WALL_RESTITUTION;

    for :PolylineSegmentIterator level.boundary.shape {
        b2EdgeShape.SetTwoSided(*edge_shape, it.from, it.to);
        b2Body.CreateFixture(level.boundary.body, *fixture_def);
    }
}





deinit_player_physics :: (using player : *Player) {
    assert(host_type == .SERVER || host_type == .LOCAL);

    world : *b2World;
    if player.index == .P1 then world = worlds[0];
    if player.index == .P2 then world = worlds[1];

    b2World.DestroyBody(world, player.body);

    for life : player.lives {
        mesh_deinit(life.mesh);
        b2World.DestroyBody(world, life.body);
    }
}

init_player_physics :: (using player : *Player) {
    assert(host_type == .SERVER || host_type == .LOCAL);

    world : *b2World;
    if player.index == .P1 then world = worlds[0];
    if player.index == .P2 then world = worlds[1];

    game_extents := get_game_extents();

    user_data : b2BodyUserData;
    b2BodyUserData.Constructor(*user_data);
    user_data.pointer = xx player;

    offset, extents, stride := compute_square_grid(get_goal_extents(), LIVES_GRID_COLS, LIVES_GRID_ROWS, .1);
    
    for row : 0..LIVES_GRID_ROWS-1 for col : 0..LIVES_GRID_COLS-1 {
        life := *lives[col + row * LIVES_GRID_COLS];
        user_data : b2BodyUserData;
        b2BodyUserData.Constructor(*user_data);
        user_data.pointer = xx life;

        body_def : b2BodyDef;
        b2BodyDef.Constructor(*body_def);
        body_def.userData = user_data;
        body_def.type = .b2_staticBody;

        anchor := Vector2.{get_goal_extents().x, 2 * get_goal_extents().y + get_game_extents().y};

        if index == {
        case .P1;
            body_def.position = -anchor + offset + extents + Vector2.{stride.x * col, stride.y * row};
            body_def.angle = 0.;
        case .P2;
            body_def.position =  anchor - offset - extents - Vector2.{stride.x * col, stride.y * row};
            body_def.angle = PI;
        }
        life.body = b2World.CreateBody(world, *body_def);

        add_fixture_from_mesh(life.body, life.mesh, LIFE_CATEGORY, LIFE_MASK);
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
    b2Body.SetFixedRotation(body, true);

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
                fixture_def.filter.categoryBits = PLAYER_CATEGORY;
                fixture_def.filter.maskBits = PLAYER_MASK;
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
                fixture_def.filter.categoryBits = PLAYER_CATEGORY;
                fixture_def.filter.maskBits = PLAYER_MASK;
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
            fixture_def.filter.categoryBits = PLAYER_CATEGORY;
            fixture_def.filter.maskBits = PLAYER_MASK;
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
            add_fixture_from_mesh(body, bottom_mesh, PLAYER_CATEGORY, PLAYER_MASK);
    }


    // Let the players disappear into the boundary halfway so you can position
    // the left/right facing edge of the paddle to a ball moving right/left

    game := get_game_extents();
    goal := get_goal_extents();

    if player.index == {
    case .P1;
        anchor := Vector2.{0., -game.y};
        axis := Vector2.{1, 0};
        lower_translation := -goal.x - PADDLE_EXTENTS.x;
        upper_translation :=  goal.x + PADDLE_EXTENTS.x;

        joint_def : b2PrismaticJointDef;
        b2PrismaticJointDef.Constructor(*joint_def);
        b2PrismaticJointDef.Initialize(*joint_def, level.boundary.body, body, anchor, axis);
        joint_def.lowerTranslation = lower_translation;
        joint_def.upperTranslation = upper_translation;
        joint_def.enableLimit = true;
        b2World.CreateJoint(world, *joint_def);

    case .P2;
        anchor := Vector2.{0., game.y};
        axis := Vector2.{1, 0};
        lower_translation := -goal.x - PADDLE_EXTENTS.x;
        upper_translation :=  goal.x + PADDLE_EXTENTS.x;

        joint_def : b2PrismaticJointDef;
        b2PrismaticJointDef.Constructor(*joint_def);
        b2PrismaticJointDef.Initialize(*joint_def, level.boundary.body, body, anchor, axis);
        joint_def.lowerTranslation = lower_translation;
        joint_def.upperTranslation = upper_translation;
        joint_def.enableLimit = true;
        b2World.CreateJoint(world, *joint_def);
    }
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

get_transform :: (body : *b2Body) -> b2Transform {
    return b2Body.GetTransform(body).*;
}

apply_linear_impulse_to_center :: (body : *b2Body, impulse : Vector2, wake := true) {
    b2Body.ApplyLinearImpulseToCenter(body, impulse, wake);
}

ray_cast_callback : b2RayCastCallback; // @Leak We need one for each world
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
PLAYER_CATEGORY : u16 : 0x0001;
BALL_CATEGORY : u16 : 0x0002;
LIFE_CATEGORY : u16 : 0x0004;
BOUNDARY_CATEGORY : u16 : 0x0008;
PLAYER_JOINT_CATEGORY : u16 : 0x0010;

// Box2D collision masks (I will collide with...)
EVERYTHING_MASK : u16 : 0xFFFF;
PLAYER_MASK : u16 : #run EVERYTHING_MASK ^ BOUNDARY_CATEGORY;
BALL_MASK : u16 : EVERYTHING_MASK;
LIFE_MASK : u16 : BALL_CATEGORY;
BOUNDARY_MASK : u16 : BALL_CATEGORY;

