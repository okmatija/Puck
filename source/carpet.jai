my_logger :: (message: string, data: *void, info: Log_Info) {
    if context.log_level == {
    case .NORMAL;
        if info.common_flags & (Log_Flags.VERBOSE_ONLY | Log_Flags.VERY_VERBOSE_ONLY) {
            return;
        }
    case .VERBOSE;
        if info.common_flags & (Log_Flags.VERY_VERBOSE_ONLY) {
            return;
        }
    case .VERY_VERBOSE;
        // No filter
    }

    // "QPC is typically the best method to use to time-stamp events and measure small time intervals that
    // occur on the same system or virtual machine. Consider using GetSystemTimePreciseAsFileTime when you
    // want to time-stamp events across multiple machines, provided that each machine is participating in a
    // time synchronization scheme such as Network Time Protocol (NTP). QPC helps you avoid difficulties that
    // can be encountered with other time measurement approaches, such as reading the processor’s time stamp
    // counter (TSC) directly."
    // Source: https://learn.microsoft.com/en-us/windows/win32/sysinfo/acquiring-high-resolution-time-stamps
    //
    // By reading QPC at the time of compilation we can write more reasonably sized microsecond timestamps for readability
    COMPILATION_TIME :: #run current_time_monotonic();

    // Number of decimal digits needed to write 1 hour of microseconds with 2 added to ensure a leading group of 3 digits
    DIGITS :: #run tprint("%", 60*60*1000*1000).count + 2;

    timestamp_us := to_microseconds(current_time_monotonic() - COMPILATION_TIME);
    timestamp := formatInt(timestamp_us, digits_per_comma=3, comma_string=",", minimum_digits=DIGITS);

    // @Cleanup Think about how to do allocation properly here
    if info.common_flags & .ERROR {
        write_string(tprint("[error] %:% %", timestamp, current_frame, message));
    } else if info.common_flags & .WARNING {
        write_string(tprint("[warning] %:% %", timestamp, current_frame, message));
    } else {
        write_string(tprint("%:% %", timestamp, current_frame, message));
    }
}

log_error :: (format_string: string, args: .. Any, loc := #caller_location, flags := Log_Flags.NONE, user_flags : u32 = 0) {
    new_flags := flags | .ERROR;
    log(format_string, ..args, loc, new_flags, user_flags);
} @PrintLike

log_warning :: (format_string: string, args: .. Any, loc := #caller_location, flags := Log_Flags.NONE, user_flags : u32 = 0) {
    new_flags := flags | .WARNING;
    log(format_string, ..args, loc, new_flags, user_flags);
} @PrintLike

// This function is suitable for verbose logs which do not compute any additional data
log_verbose :: (format_string: string, args: .. Any, loc := #caller_location, flags := Log_Flags.NONE, user_flags : u32 = 0) {
    if context.log_level == .VERBOSE {
        new_flags := flags | .VERBOSE_ONLY;
        log(format_string, ..args, loc, new_flags, user_flags);
    }
} @PrintLike

to_radians :: (degrees : float) -> float {
    scale :: PI / 180;
    return degrees * scale;
}

to_degrees :: (radians : float) -> float {
    scale :: 180 / PI;
    return radians * scale;
}

// Note: argument must have type Any, this doesn't work with float
time_format :: (seconds : Any) -> FormatFloat {
    return .{value=seconds, trailing_width=2, zero_removal=.NO};
}

get_enum_count :: ($enum_type : Type) -> s64 {
    info := type_info(enum_type);
    assert(info.type == Type_Info_Tag.ENUM);
    info_enum := cast(*Type_Info_Enum) info;
    return info_enum.values.count;
}

printd :: ($a : string, loc := #caller_location) #expand {
    v := #insert a;
    s := a;
    s.count -= 1;
    print("%:% % = %\n", loc.fully_pathed_filename, loc. line_number, s, v);
}

printv :: (a : Code, loc := #caller_location) #expand {

    get_ident_name :: (code : Code) -> string {
        #import "Compiler";
        root := compiler_get_nodes(code);
        assert(root.kind == .IDENT);
        ident := cast(*Code_Ident) root;
        return ident.name;
    }

    new_context := context;

    //format_float := *new_context.print_style.default_format_float;
    //format_float.mode = .SCIENTIFIC;
    //format_float.width = 10;

    format_struct := *new_context.print_style.default_format_struct;
    format_struct.use_long_form_if_more_than_this_many_members = 4;
    format_struct.use_newlines_if_long_form = true;

    //format_array := *new_context.print_style.default_format_array;
    //format_array.stop_printing_after_this_many_elements = 10;

    push_context new_context {
#if true {
    print("%:% % = %\n", loc.fully_pathed_filename, loc.line_number, #run get_ident_name(a), #insert a);
} else {
    print("% = %\n", #run get_ident_name(a), #insert a);
}
    }
}

show_cursor :: inline ()
{
	#if OS == .WINDOWS
	{
		win32 :: #import "Windows";
		win32.ShowCursor (1);
	}
	else
	{
		// @Todo!
	}
}

hide_cursor :: inline ()
{
	#if OS == .WINDOWS
	{
		win32 :: #import "Windows";
		win32.ShowCursor (0);
	}
	else
	{
		// @Todo!
	}
}

UI_State :: struct {
    // 'k' is some resolution-adjusting unit of distance. Right now it is
    // 1/10 of the screen width/height, so, 192/108 pixels at 1920x1080.
    k : Vector2;

    // x/y is horizontal/vertical space between widgets
    padding : Vector2;

    ui_theme : UI.Overall_Theme;
}

make_ui_state :: () -> UI_State {
    using state : UI_State;
    k = Vector2.{window_width * .1, window_height * .1};
    padding = Vector2.{.1*k.x, .1*k.y}; // x/y is horizontal/vertical space between widgets
    ui_theme = UI.default_theme_procs[xx UI.Default_Themes.Default]();
    UI.set_default_theme(ui_theme);  // Just in case we don't explicitly pass themes sometimes...!
    return state;
}

CenteredCursor :: (init_y : float) -> Vector2 #expand {
    return .{5.*`k.x, init_y};
}

// Returns the next rect to use and moves the cursor to the bottom center of the rect
NextRect :: (w: float, h: float) -> UI.Rect #expand {
    r := UI.get_rect(`cursor.x - w*.5, `cursor.y, w, h);
    `cursor.y += h + `padding.y;
    return r;
}

NextRect2 :: (w: float, h: float) -> UI.Rect, UI.Rect #expand {
    l := UI.get_rect(`cursor.x - `padding.x*.5 - w , `cursor.y, w, h);
    r := UI.get_rect(`cursor.x + `padding.x*.5,      `cursor.y, w, h);
    `cursor.y += h + `padding.y;
    return l, r;
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
            return .{xy=world_to_screen(apply_transform(t, v))};
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

indent :: (level : int, c : u8 = #char " ", level_count := 2) {
    for 0..(level * level_count)-1 {
        c_str : string;
        c_str.count = 1;
        c_str.data = *c;
        print("%", c_str);
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



#import "Math";