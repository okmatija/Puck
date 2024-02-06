printd :: ($a : string, loc := #caller_location) #expand {
    v := #insert a;
    s := a;
    s.count -= 1;
    print("%:% % = %\n", loc.fully_pathed_filename, loc. line_number, s, v);
}








draw_body :: (body : *b2Body, color : Vector4) #deprecated "Render using mesh/transform data instead, this function only works on the server" {
    if body == null {
        log_error("draw_body only works on the servers, called from %", host_type);
        return;
    }

    fixture : *b2Fixture = b2Body.GetFixtureList(body);
    while fixture != null {
        defer fixture = b2Fixture.GetNext(fixture);

        shape : *b2Shape = b2Fixture.GetShape(fixture);
        shape_type : b2Shape.Type = b2Shape.GetType(shape);

        transform :: (body : *b2Body, v : Vector2) -> Vector3 {
            t := b2Body.GetTransform(body);
            return .{xy=world_to_screen(b2Mul(t, v))};
        }

        if shape_type == .polygon {
            using polygon_shape := cast(*b2PolygonShape)shape;

            v0 : Vector3 = transform(body, m_vertices[0]);
            for i : 1..m_count-2 {
                v1 : Vector3 = transform(body, m_vertices[i]);
                v2 : Vector3 = transform(body, m_vertices[i+1]);
                Simp.immediate_triangle(v0, v1, v2, color, color, color);
            }
        } else if shape_type == .circle {
            using circle_shape := cast(*b2CircleShape)shape;

            CIRCLE_SEGMENTS :: 16;
            CIRCLE_INCREMENT :: #run TAU / CIRCLE_SEGMENTS;

            sinInc := sin(CIRCLE_INCREMENT);
            cosInc := cos(CIRCLE_INCREMENT);
            v0 : Vector3 = transform(body, m_p);
            r1 : b2Vec2 = .{cosInc, sinInc};
            v1 : Vector3 = transform(body, m_p + m_radius * r1);
            for i : 0..CIRCLE_SEGMENTS-1 {
                // Perform rotation to avoid additional trigonometry.
                r2 : b2Vec2 = ---;
                r2.x = cosInc * r1.x - sinInc * r1.y;
                r2.y = sinInc * r1.x + cosInc * r1.y;
                v2 : Vector3 = transform(body, m_p + m_radius * r2);
                Simp.immediate_triangle(v0, v1, v2, color, color, color);
                r1 = r2;
                v1 = v2;
            }
        } else if shape_type == .edge {
            using edge_shape := cast(*b2EdgeShape)shape;

            SEGMENT_THICKNESS :: 1.; // Simp units aka pixels

            start : Vector2 = transform(body, m_vertex1).xy;
            end : Vector2 = transform(body, m_vertex2).xy;

            // assert(start.z == 0. && end.z == 0.);
            normal := unit_vector(end - start);
            normal.x, normal.y = normal.y, -normal.x; // Rotate the unit direction by 90 degrees
            q0 := start + normal * .5 * SEGMENT_THICKNESS;
            q3 := start - normal * .5 * SEGMENT_THICKNESS;
            q2 := end - normal * .5 * SEGMENT_THICKNESS;
            q1 := end + normal * .5 * SEGMENT_THICKNESS;
            Simp.immediate_quad(q0, q1, q2, q3, color, color, color, color);

        } else {
            assert(false); // @Incomplete
        }
    }
}







print_event :: (event : Enet.Event, event_index : int) {
    indent(1);
    print("[%] % %\n",
        event_index,
        event.type,
        event.channel_id,
        );

    if event.type == .RECEIVE {

        indent(2);
        type : Type = void;
        if event.packet.data_length == {
        case size_of(Client_Input);
            type = Client_Input;
        case size_of(Game_State);
            type = Game_State;
        }
        print("packet (%): flags=% data_length=% user_data.*=%\n",
            type,
            event.packet.flags,
            event.packet.data_length,
            ifx event.packet.user_data then event.packet.user_data.* else Any.{},
            );

        if event.peer {

            // indent(2);
            // print("peer: % or=%\n",
            //     event.peer.state,
            //     event.peer.outgoing_reliable_seq_number,
            //     );

            // channel
            indent(3);
            channel := *event.peer.channels[event.channel_id];
            print("channels[%]: or=% ou=% ir=% iu=%\n",
                event.channel_id,
                channel.outgoing_reliable_seq_number,
                channel.outgoing_unreliable_seq_number,
                channel.incoming_reliable_seq_number,
                channel.incoming_unreliable_seq_number,
                );

            print_list :: (name : string, list : *Enet.List, max_length := 10) {
                Iter :: (list: *Enet.List, body: Code, flags: For_Flags) #expand {
                    `it := Enet.list_begin(list);
                    `it_index := 0;
                    while it != Enet.list_end(list) {
                        defer it = Enet.list_next(it);
                        defer it_index += 1;

                        #insert body;
                    }
                }

                length := 0;
                for :Iter list {
                    length+=1;
                }

                indent(3);
                print("%: [%].(", name, length);
                for :Iter list {
                    outgoing_cmd := cast(*Enet.Outgoing_Command)it;
                    print("{%, %}, ", outgoing_cmd.sent_time, outgoing_cmd.send_attempts);
                    if it_index > max_length {
                        print("...");
                        break;
                    }
                }
                print(")\n");
            }

            print_list("outgoing_reliable_commands  ", *event.peer.outgoing_reliable_commands);
            print_list("outgoing_unreliable_commands", *event.peer.outgoing_unreliable_commands);
            print_list("acknowledgements            ", *event.peer.acknowledgements);
            print_list("sent_reliable_commands      ", *event.peer.sent_reliable_commands);
            print_list("sent_unreliable_commands    ", *event.peer.sent_unreliable_commands); // @EnetBug This grows unbounded???
            print_list("dispatched_commands         ", *event.peer.dispatched_commands);

        }
    }
}


debug_network_game :: () {
    is_network_game := host_type == .CLIENT || host_type == .SERVER;
    if is_network_game {
        log("incoming_bandwidth = %", get_host().incoming_bandwidth);
        log("outgoing_bandwidth = %", get_host().outgoing_bandwidth);
        log("total_sent_packets = %", get_host().total_sent_packets);
        log("total_sent_data = %", get_host().total_sent_data);
        log("total_received_data_length = %", get_host().total_received_data_length);
    }
}

debug_explosion_animation :: () {
    // Test ball explosion animation
    if ball_explosions.count == 0 {
        index := cast(int)random_get_within_range(0.1, 3.99);
        colors : [4]Vector4 : .[RED, GREEN, BLUE, WHITE];
        explosion : Explosion;
        explosion.color = colors[index];
        explosion.radius = BALL_INITIAL_RADIUS;
        array_add(*ball_explosions, explosion);
    }
}

debug_draw : Debug_Draw;

add_debug_segment :: (segment : Debug_Segment) {
    #if DEBUG_DRAW {
        array_add(*debug_draw.segments, segment);
    }
}

Debug_Draw :: struct {
    segments : [..]Debug_Segment;
}

Debug_Segment :: struct {
    start : Vector2;
    end : Vector2;
    color : Vector4;
    thickness : float = 4.;
}
