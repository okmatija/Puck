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
