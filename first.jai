#load "source/main.jai";

#run {
    Compiler :: #import "Compiler";

    // Check that you are compiling with the expected version of the compiler
    COMPILER_VERSION_INFO := Compiler.compiler_get_version_info(null);
    EXPECTED_COMPILER_VERSION_INFO :: "beta 0.1.083, built on 15 January 2024";
    if (COMPILER_VERSION_INFO != EXPECTED_COMPILER_VERSION_INFO) {
        message := tprint("\n\nYou are using compiler version '%'\nbut the program expects version '%'.\nThe program may not compile, or some things may be broken.", COMPILER_VERSION_INFO, EXPECTED_COMPILER_VERSION_INFO);
        Compiler.compiler_report(message, mode = Compiler.Report.ERROR_CONTINUABLE);
    }

    Compiler.set_build_options_dc(.{output_executable_name = "pong"});
};
