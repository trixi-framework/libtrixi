#include <gtest/gtest.h>

extern "C" {
    #include "../src/trixi.h"

    void store_function_pointers(int num_fptrs, const char * fptr_names[], void * fptrs[]);
}

// Julia project path defined via cmake
const char * julia_project_path = JULIA_PROJECT_PATH;

// Example libexlixir
const char * libelixir_path =
  "../../LibTrixi.jl/examples/libelixir_p4est2d_dgsem_euler_sedov.jl";


TEST(CInterfaceTest, JuliaProject) {

    // be evil
    const char * garbage = "this_string_is_just_way_toooooooooooooooooooo_long"
                           "this_string_is_just_way_toooooooooooooooooooo_long"
                           "this_string_is_just_way_toooooooooooooooooooo_long"
                           "this_string_is_just_way_toooooooooooooooooooo_long"
                           "this_string_is_just_way_toooooooooooooooooooo_long"
                           "this_string_is_just_way_toooooooooooooooooooo_long"
                           "this_string_is_just_way_toooooooooooooooooooo_long"
                           "this_string_is_just_way_toooooooooooooooooooo_long"
                           "this_string_is_just_way_toooooooooooooooooooo_long"
                           "this_string_is_just_way_toooooooooooooooooooo_long"
                           "this_string_is_just_way_toooooooooooooooooooo_long"
                           "this_string_is_just_way_toooooooooooooooooooo_long"
                           "this_string_is_just_way_toooooooooooooooooooo_long"
                           "this_string_is_just_way_toooooooooooooooooooo_long"
                           "this_string_is_just_way_toooooooooooooooooooo_long"
                           "this_string_is_just_way_toooooooooooooooooooo_long"
                           "this_string_is_just_way_toooooooooooooooooooo_long"
                           "this_string_is_just_way_toooooooooooooooooooo_long"
                           "this_string_is_just_way_toooooooooooooooooooo_long"
                           "this_string_is_just_way_toooooooooooooooooooo_long";
    EXPECT_DEATH( trixi_initialize( garbage, "/tmp" ),
                  "buffer size not sufficient for activation command");
}


TEST(CInterfaceTest, VersionInfo) {

    // Initialize libtrixi
    trixi_initialize( julia_project_path, NULL );

    // Check libtrixi version information
    int major = trixi_version_library_major();
    int minor = trixi_version_library_minor();
    int patch = trixi_version_library_patch();
    std::string version_string("");
    version_string.append(std::to_string(major));
    version_string.append(".");
    version_string.append(std::to_string(minor));
    version_string.append(".");
    version_string.append(std::to_string(patch));
    
    EXPECT_STREQ(version_string.c_str(), trixi_version_library());

    // Check Julia packages version information
    std::string version_string_julia(trixi_version_julia());
    EXPECT_NE(version_string_julia.find("OrdinaryDiffEq"), std::string::npos);

    std::string version_string_julia_ext(trixi_version_julia_extended());
    EXPECT_NE(version_string_julia_ext.find("StartUpDG"), std::string::npos);

    // Finalize libtrixi
    trixi_initialize( julia_project_path, NULL );
}


TEST(CInterfaceTest, JuliaCode) {

    // Initialize libtrixi
    trixi_initialize( julia_project_path, NULL );

    // Execute correct Julia code
    // NOTE: capturing stdout somehow does not work
    trixi_eval_julia("println(\"Hello from Julia!\")");

    // Execute erroneous Julia code
    // NOTE: output before exit is somehow not captured here
    EXPECT_DEATH(trixi_eval_julia("printline(\"Hello from Julia!\")"), "");

    // Finalize libtrixi
    trixi_initialize( julia_project_path, NULL );
}


TEST(CInterfaceTest, FunctionPointers) {

    // Initialize libtrixi
    trixi_initialize( julia_project_path, NULL );

    const int num_fptrs = 2;
    void* fptrs[num_fptrs];
    const char* fptr_names[num_fptrs] = {"trixi_step_cfptr", "does_not_exist"};

    // get function pointer for valid name
    store_function_pointers(1, fptr_names, fptrs);

    // try to get function pointer for invalid name
    EXPECT_DEATH(store_function_pointers(num_fptrs, fptr_names, fptrs), "");

    // Finalize libtrixi
    trixi_initialize( julia_project_path, NULL );
}
