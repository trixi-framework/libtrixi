#include <gtest/gtest.h>

extern "C" int trixi_version_major();
extern "C" int trixi_version_minor();
extern "C" int trixi_version_patch();
extern "C" const char* trixi_version();
extern "C" const char* trixi_version_julia();
extern "C" const char* trixi_version_julia_extended();
extern "C" void trixi_initialize(const char * project_directory, const char * depot_path);
extern "C" int trixi_initialize_simulation(const char * libelixir);
extern "C" void trixi_finalize_simulation(int handle);
extern "C" void trixi_finalize();
extern "C" int trixi_is_finished(int handle);
extern "C" void trixi_step(int handle);
extern "C" double trixi_calculate_dt(int handle);
extern "C" int trixi_ndims(int handle);
extern "C" int trixi_nelements(int handle);
extern "C" int trixi_nvariables(int handle);
extern "C" void trixi_load_cell_averages(double * data, int handle);


// Julia project path defined via cmake
const char * julia_project_path = JULIA_PROJECT_PATH;

// Example libexlixir
const char * libelixir_path =
  "../../LibTrixi.jl/examples/libelixir_p4est2d_dgsem_euler_sedov.jl";


TEST(CInterfaceTest, VersionInfo) {

    // Initialize Trixi
    trixi_initialize( julia_project_path, NULL );

    // Check libtrixi version information
    int major = trixi_version_major();
    int minor = trixi_version_minor();
    int patch = trixi_version_patch();
    std::string version_string("");
    version_string.append(std::to_string(major));
    version_string.append(".");
    version_string.append(std::to_string(minor));
    version_string.append(".");
    version_string.append(std::to_string(patch));
    
    EXPECT_STREQ(version_string.c_str(), trixi_version());

    // Check julia packages version information
    std::string version_string_julia(trixi_version_julia());
    EXPECT_NE(version_string_julia.find("OrdinaryDiffEq"), std::string::npos);

    std::string version_string_julia_ext(trixi_version_julia_extended());
    EXPECT_NE(version_string_julia_ext.find("StartUpDG"), std::string::npos);

    // Finalize Trixi
    trixi_initialize( julia_project_path, NULL );
}

TEST(CInterfaceTest, SimulationRun) {

    // Initialize Trixi
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

    // Finalize Trixi
    trixi_finalize();
}
