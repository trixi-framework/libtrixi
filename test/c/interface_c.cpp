#include <gtest/gtest.h>

extern "C" {
    #include "../src/trixi.h"

    void store_function_pointers(int num_fptrs, const char * fptr_names[], void * fptrs[]);
}

// Julia project path defined via cmake
const char * julia_project_path = JULIA_PROJECT_PATH;

// Example libexlixir
const char * libelixir_path =
  "../../../LibTrixi.jl/examples/libelixir_p4est2d_dgsem_euler_sedov.jl";


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
    trixi_finalize();
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
    trixi_finalize();
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
    trixi_finalize();
}


TEST(CInterfaceTest, SimulationRun) {

    // Initialize libtrixi
    trixi_initialize( julia_project_path, NULL );

    // Set up the Trixi simulation, get a handle
    int handle = trixi_initialize_simulation(libelixir_path);
    EXPECT_EQ(handle, 1);

    // Using a non-existent handle should fail and exit
    EXPECT_DEATH(trixi_is_finished(42),
                 "the provided handle was not found in the stored simulation states: 42");

    // Do a simulation step
    trixi_step(handle);

    // Check time step length
    double dt = trixi_calculate_dt(handle);
    EXPECT_DOUBLE_EQ(dt, 0.0032132984504400627);
    
    // Check finished status
    int finished_status = trixi_is_finished(handle);
    EXPECT_EQ(finished_status, 0);

    // Check number of dimensions
    int ndims = trixi_ndims(handle);
    EXPECT_EQ(ndims, 2);

    // Check number of elements
    int nelements = trixi_nelements(handle);
    EXPECT_EQ(nelements, 256);

    // Check number of variables
    int nvariables = trixi_nvariables(handle);
    EXPECT_EQ(nvariables, 4);

    // Check cell averaged values
    int size = nelements * nvariables;
    std::vector<double> cell_averages(size);
    trixi_load_cell_averages(cell_averages.data(), handle);
    EXPECT_DOUBLE_EQ(cell_averages[0],      1.0);
    EXPECT_DOUBLE_EQ(cell_averages[928],    2.6605289164377273);
    EXPECT_DOUBLE_EQ(cell_averages[size-1], 1e-5);
    
    // Finalize Trixi simulation
    trixi_finalize_simulation( handle );

    // Handle is now invalid and subsequent use should fail
    EXPECT_DEATH(trixi_is_finished(handle),
                 "the provided handle was not found in the stored simulation states: 1");

    // Finalize libtrixi
    trixi_finalize();
}
