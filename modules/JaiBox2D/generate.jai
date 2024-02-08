AT_COMPILE_TIME :: true;

COMPILE :: false; // Enable to compile the library from source before generating bindings
COMPILE_DEBUG :: false; // Compile a debug or release version, debug generates a more useful stacktrace if your program crashes in Box2D

// We provide box-2.4.1 souce code you could download a different one, update this path and re-generate the bindings.
BOX2D_PATH :: #run tprint("%box2d-2.4.1", #filepath);

#if AT_COMPILE_TIME {
    #run,stallable {
        set_build_options_dc(.{do_output=false});
        if !generate_bindings() {
            compiler_set_workspace_status(.FAILED);
        }
    }
} else {
    #import "System";

    main :: () {
        set_working_directory(path_strip_filename(get_path_of_running_executable()));
        if !generate_bindings() {
            exit(1);
        }
    }
}



generate_bindings :: () -> bool {

    #if COMPILE {
        #import "BuildCpp";

        cpp_files : [..] string;

        for file : file_list(tprint("%/src", BOX2D_PATH), true) {
            if !ends_with(file, "cpp") {
                continue; // Skip CMakeLists.txt
            }
            array_add(*cpp_files , file);
        }

        success := true;
        #if OS == {
        case .WINDOWS;
            extra : []string = .[
                "/DB2_SHARED=1",
                "/Dbox2d_EXPORTS",
                "/I", tprint("%/include", BOX2D_PATH),
                "/I", tprint("%/src", BOX2D_PATH)];

            make_directory_if_it_does_not_exist("windows");
            success &&= build_cpp_dynamic_lib("windows/Box2D", ..cpp_files , extra=extra, debug=COMPILE_DEBUG);
            success &&= build_cpp_static_lib("windows/Box2D", ..cpp_files , extra=extra, debug=COMPILE_DEBUG);
        case;
            assert(false); // @Incomplete
        }

        if !success return false;
    }

    output_filename : string;
    opts: Generate_Bindings_Options;
    {
        using opts;
        array_add(*system_include_paths, GENERATOR_DEFAULT_SYSTEM_INCLUDE_PATH);

        #if OS == {
        case .WINDOWS;
            array_add(*libpaths, "windows");
            output_filename = "windows.jai";
        case;
            assert(false); // @Incomplete
        }

        array_add(*libnames, "Box2D");

        // box2d.h contains the main API but does not include all the .h files in the folder, some of which are useful so we just add all of them
        //array_add(*source_files, tprint("%box2d-2.4.1/include/box2d/box2d.h", BOX2D_PATH));
        for file : file_list(tprint("%/include", BOX2D_PATH), true) {
            array_add(*source_files, file);
        }

        array_add(*extra_clang_arguments, "-x", "c++");

        c_enum_emulation = true;
        generate_compile_time_struct_checks = false;
        //log_stripped_declarations = true;
        //strip_flags |= .INLINED_FUNCTIONS;

        visitor = box2d_visitor;
    }

    return generate_bindings(opts, output_filename);
}




DECLARATIONS_TO_OMIT :: string.[
    // We have custom declarations for these in module.jai:
    "b2Vec2",
    "b2Vec3",

    // We add these to #file_scope in module.jai
    "int8",
    "int16",
    "int32",
    "uint8",
    "uint16",
    "uint32",
];

box2d_visitor :: (decl: *Declaration, parent_decl: *Declaration) -> Declaration_Visit_Result {
    if !parent_decl {
        if array_find(DECLARATIONS_TO_OMIT, decl.name) {
            decl.decl_flags |= .OMIT_FROM_OUTPUT;
            return .STOP;
        }
    }
    return .RECURSE;
}

#import "Bindings_Generator";
#import "Compiler";
#import "Basic";
#import "File";
#import "String";
#import "BuildCpp";
#import "File_Utilities";