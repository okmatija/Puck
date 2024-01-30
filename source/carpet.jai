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


get_client_mouse_pos :: (window: *void) -> (x: s32, y: s32) {
    #if OS == .WINDOWS {
        Win32 :: #import "Windows";

        point: Win32.POINT;
        Win32.GetCursorPos(*point);
        Win32.ScreenToClient(window, *point);
        return point.x, point.y;
    } else {
        assert(false);
        return 0, 0;
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


indent :: (level : int, c : u8 = #char " ", level_count := 2) {
    for 0..(level * level_count)-1 {
        c_str : string;
        c_str.count = 1;
        c_str.data = *c;
        print("%", c_str);
    }
}

