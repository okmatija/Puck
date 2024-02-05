simulate :: () {

    if game_mode != .PLAYING {
        return;
    }

    assert(host_type == .SERVER || host_type == .LOCAL);

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

            if down {
                time_factor = .1;
            } else if up {
                if player_count == .One_Player {
                    // @TODO Implement speed up warps for multiplayer (need per-player physics worlds...)
                    time_factor = 3.;
                }
            } else {
                time_factor = 1.;
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
    apply_impulse_to_move_player(*player2);

    if player1.time_factor == TIME_FACTOR_SLOW ||
       player2.time_factor == TIME_FACTOR_SLOW {
        if world_time_factor == 1. {
            stream := Sound.make_stream(*sound_collision1, .GENERAL_SFX);
            stream.rate_scale = .5;
            stream.user_volume_scale = user_sfx_volume;
            Sound.start_playing(stream);
        }

        world_time_factor = TIME_FACTOR_SLOW;
    } else if player1.time_factor == TIME_FACTOR_FAST ||
              player2.time_factor == TIME_FACTOR_FAST {
        if world_time_factor != TIME_FACTOR_FAST {
            // stream := Sound.make_stream(*sound_collision1, .GENERAL_SFX);
            // stream.rate_scale = -.8;
            // stream.user_volume_scale = user_sfx_volume;
            // Sound.start_playing(stream);
        }

        world_time_factor = TIME_FACTOR_FAST;
    } else {
        if world_time_factor == TIME_FACTOR_SLOW {
            stream := Sound.make_stream(*sound_collision1, .GENERAL_SFX);
            stream.rate_scale = -.8;
            stream.user_volume_scale = user_sfx_volume;
            Sound.start_playing(stream);
        } else if world_time_factor == TIME_FACTOR_FAST {
            // stream := Sound.make_stream(*sound_collision1, .GENERAL_SFX);
            // stream.rate_scale = .3;
            // stream.user_volume_scale = user_sfx_volume;
            // Sound.start_playing(stream);
        }

        world_time_factor = 1.;
    }

    // If there are any dead balls revive one after the spawn countdown
    for * :DeadBalls ball : balls {
        ball_spawn_countdown : *float;
        if #complete ball.player_index == {
        case .P1;
            ball_spawn_countdown = *player1_ball_spawn_countdown;
        case .P2;
            ball_spawn_countdown = *player2_ball_spawn_countdown;
        case .UNKNOWN;
            assert(false);
        }

        countdown(ball_spawn_countdown);

        if ball_spawn_countdown.* <= 0.  {
            ball.live = true;
            ball.health = BALL_MAX_HEALTH;

            if ball.shape == .Circle {
                if #complete ball.player_index == {
                case .P1;
                    b2Body.SetTransform(ball.body, .{get_game_extents().x - ball.radius, -ball.radius}, 0);
                    ball_velocity := BALL_INITIAL_SPEED * unit_vector(Vector2.{-1., -1.});
                    b2Body.SetLinearVelocity(ball.body, ball_velocity);
                    b2Body.SetAngularVelocity(ball.body, 0.);
                case .P2;
                    b2Body.SetTransform(ball.body, .{-get_game_extents().x + ball.radius, ball.radius}, 0);
                    ball_velocity := BALL_INITIAL_SPEED * unit_vector(Vector2.{1., 1.});
                    b2Body.SetLinearVelocity(ball.body, ball_velocity);
                    b2Body.SetAngularVelocity(ball.body, 0.);
                case .UNKNOWN;
                    assert(false);
                }
            } else {
                d :: #run 3*BALL_INITIAL_RADIUS;
                offsets : [4]Vector2 : .[.{d, 0}, .{0, d}, .{-d, 0}, .{0, -d}];

                b2Body.SetTransform(ball.body, offsets[it_index], 0);
                b2Body.SetLinearVelocity(ball.body, .{0., 0.});
                b2Body.SetAngularVelocity(ball.body, 30);
            }
            b2Body.SetEnabled(ball.body, true);
            ball_spawn_countdown.* = BALL_SPAWN_COUNTDOWN;
        }

        // break; // Just spawn one new ball
    }

    // simulate_attractor_balls(5000);

    // Disable all balls that died/exploded
    for * ball : balls {
        if !ball.live {
            b2Body.SetEnabled(ball.body, false);
        }
    }

    // Update explosions
    for ball_explosions {
        countdown(*it.countdown);
        if it.countdown <= 0 {
            remove;
        }
    }

    // Old code to increment the score
    //for * :LiveBalls ball : balls {
    //    center := b2Body.GetPosition(ball.body).*;
    //    game_extents := get_game_extents();
    //    if center.y - ball.radius > game_extents.y {
    //        ball.live = false;
    //        b2Body.SetEnabled(ball.body, false);
    //        player1.score += 1;
    //    } else if center.y + ball.radius < -game_extents.y {
    //        ball.live = false;
    //        b2Body.SetEnabled(ball.body, false);
    //        player2.score += 1;
    //    }
    //}


    // Important: Do this after SetTransform above (see the comment on b2Body::SetTransform)
    b2World.Step(world, current_dt, 6, 2);

    // Update the transforms used for rendering
    update_player :: (player : *Player) {
        player.transform = b2Body.GetTransform(player.body);
        for * player.lives {
            it.transform = b2Body.GetTransform(it.body);
        }

        // Disable all lives that died
        for * life : player.lives {
            if life.health <= 0. {
                b2Body.SetEnabled(life.body, false);
            }
        }
    }

    update_player(*player1);
    update_player(*player2);

    for * balls {
        it.transform = b2Body.GetTransform(it.body);
    }
    if level.obstructions.body {
        level.obstructions.transform = b2Body.GetTransform(level.obstructions.body);
    }

    check_winning_condition();

    // for live_emitters update_emitter(it, current_dt);
}

contact_listener_begin_contact :: (this: *b2ContactListener, contact: *b2Contact) -> void #cpp_method {
    new_context : Context;
    push_context new_context {
        stream := Sound.make_stream(*sound_collision2, .GENERAL_SFX);
        stream.rate_scale = random_get_within_range(0.7, 1.22);
        stream.user_volume_scale = user_sfx_volume;
        Sound.start_playing(stream);

        a : *b2Fixture = b2Contact.GetFixtureA(contact);
        b : *b2Fixture = b2Contact.GetFixtureB(contact);

        a_body : *b2Body = b2Fixture.GetBody(a);
        a_speed2 := length_squared(b2Body.GetLinearVelocity(a_body).*);
        a_data : *b2BodyUserData = b2Body.GetUserData(a_body);
        a_kind : Entity.Kind = ifx a_data && a_data.pointer then (cast(*Entity)a_data.pointer).kind else .Unknown;

        b_body : *b2Body = b2Fixture.GetBody(b);
        b_speed2 := length_squared(b2Body.GetLinearVelocity(b_body).*);
        b_data : *b2BodyUserData = b2Body.GetUserData(b_body);
        b_kind : Entity.Kind = ifx b_data && b_data.pointer then (cast(*Entity)b_data.pointer).kind else .Unknown;


        // @TODOOOO explosions should apply forces around where they occur, so a tactic could be do get them to explode near the opponent
        maybe_explode_ball :: (kind : Entity.Kind, speed2 : float, data : *b2BodyUserData) {
            if kind == .Ball && speed2 > BALL_DAMAGE_SPEED*BALL_DAMAGE_SPEED {
                ball := cast(*Ball)data.pointer;

                N :: 3.;
                ball.health -= (BALL_MAX_HEALTH / N + 1.); // +1 so N high speed collisions definitely kills the ball

                if ball.health < 0. {
                    // ball.SetEnabled(false); // Disable the collision
                    ball.live = false;
                    explosion := Explosion.{position=b2Body.GetPosition(ball.body), radius=ball.radius, color=ball.color};
                    array_add(*ball_explosions, explosion);

                    // @TODOOOO explosions should apply forces around where they occur, so a tactic could be do get them to explode near the opponent

                    stream := Sound.make_stream(*sound_ball_explode, .GENERAL_SFX);
                    stream.rate_scale = random_get_within_range(0.7, 1.22);
                    stream.user_volume_scale = user_sfx_volume;
                    Sound.start_playing(stream);
                }
            }
        }

        maybe_explode_ball(a_kind, a_speed2, a_data);
        maybe_explode_ball(b_kind, b_speed2, b_data);


        DO_COLOR :: false;
        if DO_COLOR && a_kind == .Ball && b_kind == .Ball {
            a_ball := cast(*Ball)a_data.pointer;
            b_ball := cast(*Ball)b_data.pointer;
            assert(a_ball != b_ball);

            if a_ball.live && b_ball.live {
                if a_speed2 > b_speed2 {
                    b_ball.color = a_ball.color;
                } else {
                    a_ball.color = b_ball.color;
                }
            }
        } else if a_kind == .Ball && b_kind == .Player {

            ball := cast(*Ball)a_data.pointer;
            player := cast(*Player)b_data.pointer;
            if DO_COLOR
            ball.color = player.color;

        } else if a_kind == .Player && b_kind == .Ball {

            player := cast(*Player)a_data.pointer;
            ball := cast(*Ball)b_data.pointer;
            if DO_COLOR
            ball.color = player.color;

        } else if a_kind == .Life && b_kind == .Ball {

            // @Gameplay Maybe our color balls add health? (but can only set ball color from hitting on the front of paddle?)
            life := cast(*Life)a_data.pointer;
            ball := cast(*Ball)b_data.pointer;
            if life. player_index == ball.player_index {
                life.health += LIFE_MAX_HEALTH / 2.;
            } else {
                life.health -= LIFE_MAX_HEALTH / 2.;
            }
            Clamp(*life.health, 0., LIFE_MAX_HEALTH);

        } else if a_kind == .Ball && b_kind == .Life {

            life := cast(*Life)b_data.pointer;
            ball := cast(*Ball)a_data.pointer;
            if life. player_index == ball.player_index {
                life.health += LIFE_MAX_HEALTH / 2.;
            } else {
                life.health -= LIFE_MAX_HEALTH / 2.;
            }
            Clamp(*life.health, 0., LIFE_MAX_HEALTH);

        }
    }
}

contact_listener_pre_solve :: (this: *b2ContactListener, contact: *b2Contact, oldManifold: *b2Manifold) -> void #cpp_method {
    new_context : Context;
    push_context new_context {

        // Disable the player-ball collisions that occur in the goal and on the circle part of the player

        a : *b2Fixture = b2Contact.GetFixtureA(contact);
        a_body : *b2Body = b2Fixture.GetBody(a);
        a_data : *b2BodyUserData = b2Body.GetUserData(a_body);
        a_kind : Entity.Kind = ifx a_data && a_data.pointer then (cast(*Entity)a_data.pointer).kind else .Unknown;

        b : *b2Fixture = b2Contact.GetFixtureB(contact);
        b_body : *b2Body = b2Fixture.GetBody(b);
        b_data : *b2BodyUserData = b2Body.GetUserData(b_body);
        b_kind : Entity.Kind = ifx b_data && b_data.pointer then (cast(*Entity)b_data.pointer).kind else .Unknown;

        ball : *Ball;
        player : *Player;

        if a_kind == .Ball && b_kind == .Player {
            ball = cast(*Ball)a_data.pointer;
            player = cast(*Player)b_data.pointer;
        } else if a_kind == .Player && b_kind == .Ball {
            player = cast(*Player)a_data.pointer;
            ball = cast(*Ball)b_data.pointer;
        }

        if player && ball {
            world_manifold : b2WorldManifold;
            b2Contact.GetWorldManifold(contact, *world_manifold);
            if player.index == .P1 {
                if world_manifold.points[0].y < -get_game_extents().y ||
                world_manifold.points[1].y < -get_game_extents().y {
                    b2Contact.SetEnabled(contact, false);
                }
            } else if player.index == .P2 {
                if world_manifold.points[0].y > get_game_extents().y ||
                world_manifold.points[1].y > get_game_extents().y {
                    b2Contact.SetEnabled(contact, false);
                }
            }

        }
    }
}

contact_listener_end_contact :: (this: *b2ContactListener, contact: *b2Contact) -> void #cpp_method {}
contact_listener_post_solve :: (this: *b2ContactListener, contact: *b2Contact, impulse: *b2ContactImpulse) -> void #cpp_method {}
contact_listener_destructor :: (this: *b2ContactListener, flags: Msvc_Destructor_Flags = .NONE) -> void #cpp_method {}


#scope_file



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