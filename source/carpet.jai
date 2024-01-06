
to_radians :: (degrees : float) -> float {
    scale :: PI / 180;
    return degrees * scale;
}

to_degrees :: (radians : float) -> float {
    scale :: 180 / PI;
    return radians * scale;
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


#import "Math";