simulate :: () {

    apply_impulse_to_move_player :: (using player : *Player) {
        Control_Mode :: enum {
            KEYBOARD_SET_VELOCITY_INF_ACCELERATION;
            KEYBOARD_SET_VELOCITY_NFRAME_ACCELERATION;
            MOUSE_SET_POSITION_INF_ACCELERATION;
            MOUSE_SET_POSITION_NFRAME_ACCELERATION;
        }

        // control_mode : Control_Mode = ifx index == .P1
        //     then .MOUSE_SET_POSITION_NFRAME_ACCELERATION
        //     else .KEYBOARD_SET_VELOCITY_NFRAME_ACCELERATION;
        control_mode : Control_Mode = .KEYBOARD_SET_VELOCITY_NFRAME_ACCELERATION;
        // control_mode : Control_Mode = .KEYBOARD_SET_VELOCITY_INF_ACCELERATION;

        if control_mode == {
        case .KEYBOARD_SET_VELOCITY_INF_ACCELERATION;

            current_velocity := b2Body.GetLinearVelocity(body);
            desired_velocity := 0.;
            if left  desired_velocity = -PADDLE_SPEED;
            if right desired_velocity =  PADDLE_SPEED;

            velocity_change := desired_velocity - current_velocity.x;
            impulse := b2Body.GetMass(body) * velocity_change;
            b2Body.ApplyLinearImpulse(body, b2Vec2.{impulse, 0.}, b2Body.GetWorldCenter(body), true);

        case .KEYBOARD_SET_VELOCITY_NFRAME_ACCELERATION;

            paddle_speed := PADDLE_SPEED;

            {
                if down && warp_countdown == WARP_COUNTDOWN {
                    stream := Sound.make_stream(*sound_collision1, .GENERAL_SFX);
                    stream.rate_scale = .5;
                    Sound.start_playing(stream);

                    warp_active = true;
                    time_factor = TIME_FACTOR;
                }

                if warp_active {
                    countdown(*warp_countdown);
                    paddle_speed *= WARP_SPEEDUP;
                }

                if warp_countdown <= 0  {
                    stream := Sound.make_stream(*sound_collision1, .GENERAL_SFX);
                    stream.rate_scale = -.8;
                    Sound.start_playing(stream);

                    warp_active = false;
                    time_factor = 1.;
                    warp_countdown = WARP_COUNTDOWN;
                }
            }

            accel := (paddle_speed / (3 * current_dt));
            decel := (paddle_speed / (1 * current_dt));

            current_velocity := b2Body.GetLinearVelocity(body);
            desired_velocity := 0.;
            if left       desired_velocity = max(-paddle_speed, current_velocity.x - current_dt * accel);
            else if right desired_velocity = min( paddle_speed, current_velocity.x + current_dt * accel);
            else {
                if current_velocity.x < 0      desired_velocity = min(0., current_velocity.x + current_dt * decel);
                else if current_velocity.x > 0 desired_velocity = max(0., current_velocity.x - current_dt * decel);
            }

            velocity_change := desired_velocity - current_velocity.x;
            impulse := b2Body.GetMass(body) * velocity_change;
            b2Body.ApplyLinearImpulse(body, b2Vec2.{impulse, 0.}, b2Body.GetWorldCenter(body), true);

        case .MOUSE_SET_POSITION_NFRAME_ACCELERATION;

            mouse_x, mouse_y, _ := get_mouse_pointer_position();
            mouse : Vector2;
            mouse.x, mouse.y = xx mouse_x, xx mouse_y;

            current_position_x := b2Body.GetPosition(body).x;
            desired_position_x := screen_to_world(mouse).x;
            desired_velocity := (desired_position_x - current_position_x) / current_dt;
            // @Feel Stop the paddle bouncing against the level border
            if desired_velocity < 0 {
                desired_velocity = max(desired_velocity, -PADDLE_SPEED);
            } else {
                desired_velocity = min(desired_velocity, PADDLE_SPEED);
            }
            current_velocity := b2Body.GetLinearVelocity(body);
            velocity_change := desired_velocity - current_velocity.x;
            impulse := b2Body.GetMass(body) * velocity_change;
            b2Body.ApplyLinearImpulse(body, b2Vec2.{impulse, 0.}, b2Body.GetWorldCenter(body), true);
        }
    }

    apply_impulse_to_move_player(*player1);
    if player_count >= .Two_Player {
        apply_impulse_to_move_player(*player2);
    }

    // If there are any dead balls revive one after the spawn countdown
    for * :DeadBalls ball : balls {
        countdown(*ball_spawn_countdown);

        if ball_spawn_countdown <= 0  {
            ball.live = true;

            if ball.shape == .Circle {
                b2Body.SetTransform(ball.body, .{get_game_extents().x - ball.radius, 0}, 0);
                b2Body.SetLinearVelocity(ball.body, initial_ball_velocity());
            } else {
                b2Body.SetTransform(ball.body, .{0, 0}, 0);
                b2Body.SetLinearVelocity(ball.body, .{0., 0.});
            }
            b2Body.SetAngularVelocity(ball.body, 0.);
            b2Body.SetEnabled(ball.body, true);
            ball_spawn_countdown = 2.;
        }

        break; // Just spawn one new ball
    }

    // simulate_attractor_balls(5000);

    for * :LiveBalls ball : balls {
        center := b2Body.GetPosition(ball.body).*;
        game_extents := get_game_extents();
        if center.y - ball.radius > game_extents.y {
            ball.live = false;
            b2Body.SetEnabled(ball.body, false);
            player1.score += 1;
        } else if center.y + ball.radius < -game_extents.y {
            ball.live = false;
            b2Body.SetEnabled(ball.body, false);
            player2.score += 1;
        }
    }

    // Important: Do this after SetTransform above (see the comment on b2Body::SetTransform)
    b2World.Step(world, current_dt, 6, 2);

    // Update the transforms used for rendering
    player1.transform = b2Body.GetTransform(player1.body);
    if player_count >= .Two_Player {
        player2.transform = b2Body.GetTransform(player2.body);
    }
    for * balls {
        it.transform = b2Body.GetTransform(it.body);
    }
    if level.obstructions.body {
        level.obstructions.transform = b2Body.GetTransform(level.obstructions.body);
    }

    // for live_emitters update_emitter(it, current_dt);
}



#scope_file


initial_ball_velocity :: () -> Vector2 {
    return .{-5.0 * PADDLE_EXTENTS.x / 1., 0};
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