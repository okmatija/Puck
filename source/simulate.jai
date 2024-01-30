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

simulate_attractor_balls :: (power : float) {
    for * :LiveBalls ball, ball_index : balls {
        center := b2Body.GetPosition(ball.body).*;

        for * :LiveBalls other_ball, other_index : balls {
            if ball != other_ball {
                if ball_index != 0 && other_index != 0 continue;

                other_center := b2Body.GetPosition(other_ball.body).*;

                to_other : Vector2 = other_center - center;
                dist2 := normalize(*to_other);
                force_mag := power * b2Body.GetMass(ball.body) * b2Body.GetMass(other_ball.body) / dist2;

                if ball_index == 0 
                    b2Body.ApplyForceToCenter(other_ball.body, -force_mag * to_other, true);
                else 
                    b2Body.ApplyForceToCenter(ball.body, force_mag * to_other, true);
            }
        }
    }
}