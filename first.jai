#run build();

EXPECTED_COMPILER_VERSION_INFO :: "beta 0.1.085, built on 3 February 2024";

build :: () #compile_time {
    Compiler :: #import "Compiler";

    // Check that you are compiling with the expected version of the compiler
    COMPILER_VERSION_INFO := Compiler.compiler_get_version_info(null);
    if (COMPILER_VERSION_INFO != EXPECTED_COMPILER_VERSION_INFO) {
        message := tprint("\n\nYou are using compiler version '%'\nbut the program expects version '%'.\nThe program may not compile, or some things may be broken.", COMPILER_VERSION_INFO, EXPECTED_COMPILER_VERSION_INFO);
        Compiler.compiler_report(message, mode = Compiler.Report.ERROR_CONTINUABLE);
    }

    Compiler.set_build_options_dc(.{output_executable_name = "pong"});
}

generate_dropdown_choices :: (array_name : string, $enum_type : Type) -> string #compile_time {
    builder: String_Builder;  // We will use this to concatenate a potentially big string.
    array_count := get_enum_count(enum_type);
    print_to_builder(*builder, "% : [%]string = .[\n", array_name, array_count);
    for 0..array_count-1 {
        array_value := tprint("%", cast(enum_type)it);
        for 0..array_value.count-1 {
            if array_value[it] == #char "_"  {
                array_value[it] = #char " ";
            }
        }
        print_to_builder(*builder, "    \"%\",\n", array_value);
    }
    print_to_builder(*builder, "];\n");
    return builder_to_string(*builder);
}


#load "source/main.jai";
