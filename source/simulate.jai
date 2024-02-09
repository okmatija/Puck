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
            ball_spawn_countdown.* = BALL_SPAWN_COUNTDOWN;
            ball.live = true;
            ball.health = BALL_MAX_HEALTH;

            if #complete ball.player_index == {
            case .P1;

                ball.active_body = ball.body[0];
                ball_update_active_body(ball,
                    position=.{get_game_extents().x - ball.radius, -ball.radius},
                    angle=0.0,
                    linear_velocity=BALL_INITIAL_SPEED * unit_vector(Vector2.{-1., -1.}),
                    angular_velocity=0.0);

            case .P2;

                ball.active_body = ball.body[1];
                ball_update_active_body(ball,
                    position=.{-get_game_extents().x + ball.radius, ball.radius},
                    angle=0.0,
                    linear_velocity=BALL_INITIAL_SPEED * unit_vector(Vector2.{1., 1.}),
                    angular_velocity=0.0);
                
            case .UNKNOWN;
                assert(false);
            }
        }

        // break; // Just spawn one new ball
    }

    // simulate_attractor_balls(5000);

    // Disable all balls that died/exploded
    for * ball : balls {
        if !ball.live {
            b2Body.SetEnabled(ball.active_body, false);
        }
    }

    // Update explosions
    for explosion : ball_explosions {
        if explosion.countdown == Explosion.EXPLOSION_DURATION {

            // Apply impulses
            for :LiveBalls ball : balls {
                position := get_position(ball.active_body);
                impulse := position - explosion.position;
                dist2 := normalize(*impulse);

                // add_debug_disk(.{center=explosion.position, radius=explosion.radius, color=RED});

                if dist2 < pow(explosion.radius, 2) {
                    ref_impulse := BALL_DENSITY * PI * BALL_INITIAL_RADIUS * BALL_INITIAL_RADIUS;
                    ref_impulse *= BALL_INITIAL_SPEED * BALL_INITIAL_SPEED;
                    impulse *= 1. * ref_impulse;
                    apply_linear_impulse_to_center(ball.active_body, impulse); 

                    // add_debug_segment(.{start=position, end=position + impulse, color=RED, thickness=4});
                }
            }

            // Apply damage
            apply_damage :: (using player : *Player, explosion : Explosion) {
                for * lives {
                    dist2 := length_squared(get_position(it.body) - explosion.position);
                    if dist2 < pow(explosion.radius, 2) {
                        it.health -= LIFE_MAX_HEALTH;
                        Clamp(*it.health, 0., LIFE_MAX_HEALTH); // @Cleanup Not needed?
                    }
                }
            }
            apply_damage(*player1, explosion);
            apply_damage(*player2, explosion);
        }

        countdown(*explosion.countdown);
        if explosion.countdown <= 0 {
            remove;
        }
    }

    // @Think not sure we really need the pre_step/post_step distinction...

    pre_step_update_player :: (using player : *Player) {
        if (time_factor == 1.0 && warp_duration_remaining > WARP_START_THRESHOLD) ||
           (time_factor != 1.0 && warp_duration_remaining > 0.0) {

            if down {
                time_factor = 0.1;
            } else if up {
                time_factor = 3.0;
            } else {
                time_factor = 1.0;
            }

        } else {
            time_factor = 1.0;
        }
    }

    pre_step_update_player(*player1);
    pre_step_update_player(*player2);

    /*
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
    */

    update_warp_duration_remaining :: (player : *Player) {
        if player.time_factor == 1.0 {
            countdown(*player.warp_duration_remaining, -1.0);
            Clamp(*player.warp_duration_remaining, 0., player.WARP_DURATION_MAX);
        } else {
            countdown(*player.warp_duration_remaining);
        }
    }
    update_warp_duration_remaining(*player1);
    update_warp_duration_remaining(*player2);



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
    b2World.Step(worlds[0], player1.time_factor * current_dt, 6, 2);
    b2World.Step(worlds[1], player2.time_factor * current_dt, 6, 2);

    // Move balls between worlds
    for * :LiveBalls ball : balls {

        transform := get_transform(ball.active_body);
        linear_velocity := get_linear_velocity(ball.active_body);
        angular_velocity := get_angular_velocity(ball.active_body);
        position := transform.p;
        angle := b2Rot.GetAngle(*transform.q);

        ball.active_body = ifx position.y < 0. then ball.body[0] else ball.body[1];
        ball_update_active_body(ball, position, angle, linear_velocity, angular_velocity);
    }

    // Update the transforms used for rendering
    {
        post_step_update_player :: (player : *Player) {
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

        post_step_update_player(*player1);
        post_step_update_player(*player2);

        // Collect data to send to clients
        for * balls {
            it.transform = b2Body.GetTransform(it.active_body);
        }
        for 0..1 {
            if level.obstructions[it].body {
                level.obstructions[it].transform = b2Body.GetTransform(level.obstructions[it].body);
            }
        }
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


        maybe_explode_ball :: (kind : Entity.Kind, speed2 : float, data : *b2BodyUserData) {
            if kind == .Ball && speed2 > BALL_DAMAGE_SPEED*BALL_DAMAGE_SPEED {
                ball := cast(*Ball)data.pointer;

                N :: 3.;
                ball.health -= (BALL_MAX_HEALTH / N + 1.); // +1 so N high speed collisions definitely kills the ball

                if ball.health < 0. {
                    // ball.SetEnabled(false); // Disable the collision
                    ball.live = false;

                    explosion : Explosion;
                    explosion.position = get_position(ball.active_body);
                    explosion.radius = 4. * ball.radius;
                    explosion.color = ball.color;
                    array_add(*ball_explosions, explosion);

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
                //life.health += LIFE_MAX_HEALTH / 2.; // @TODO :MatchingColorHeals Remove this, it was too complicated. It was kinda neat to have healing balls but not actually that fun in practice, its a casual game!
                life.health -= LIFE_MAX_HEALTH / 2.;
            } else {
                life.health -= LIFE_MAX_HEALTH / 2.;
            }
            Clamp(*life.health, 0., LIFE_MAX_HEALTH);

        } else if a_kind == .Ball && b_kind == .Life {

            life := cast(*Life)b_data.pointer;
            ball := cast(*Ball)a_data.pointer;
            if life. player_index == ball.player_index {
                //life.health += LIFE_MAX_HEALTH / 2.; // :MatchingColorHeals 
                life.health -= LIFE_MAX_HEALTH / 2.;
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
            using world_manifold : b2WorldManifold;
            b2Contact.GetWorldManifold(contact, *world_manifold);

            if player.index == .P1 {
                y_crit := get_position(player.body).y - PADDLE_EXTENTS.y;
                if points[0].y < y_crit || points[1].y < y_crit {
                    b2Contact.SetEnabled(contact, false);
                }
            } else if player.index == .P2 {
                y_crit := get_position(player.body).y + PADDLE_EXTENTS.y;
                if points[0].y >  y_crit || points[1].y >  y_crit {
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

ball_update_active_body :: (ball : *Ball, position : Vector2, angle : float, linear_velocity : Vector2, angular_velocity : float) {
    for * ball.body {
        if ball.active_body == it.* {
            b2Body.SetEnabled(it.*, true); // @Think Do we need to check .live here???
            b2Body.SetTransform(ball.active_body, position, angle);
            b2Body.SetLinearVelocity(ball.active_body, linear_velocity);
            b2Body.SetAngularVelocity(ball.active_body, angular_velocity);
        } else {
            b2Body.SetEnabled(it.*, false);
        }
    }
}

/*
// @TODO Update this code to handle multiple worlds
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
*/