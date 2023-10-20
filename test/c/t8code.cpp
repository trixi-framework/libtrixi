#include <gtest/gtest.h>

extern "C" {
    #include "../src/trixi.h"
}

// Julia project path defined via cmake
const char * julia_project_path = JULIA_PROJECT_PATH;

// Example libexlixir
const char * libelixir_path =
  "../../../LibTrixi.jl/examples/libelixir_t8code_2d_dgsem_advection_amr.jl";

TEST(CInterfaceTest, T8code) {

    // Initialize libtrixi
    trixi_initialize(julia_project_path, NULL);

    // Set up the Trixi simulation, get a handle
    int handle = trixi_initialize_simulation(libelixir_path);

    // Check t8code mesh
    t8_forest_t trixi_forest = trixi_get_t8code_forest(handle);
    EXPECT_NE(trixi_forest, nullptr);
    
    // Finalize Trixi simulation
    trixi_finalize_simulation(handle);

    // Finalize libtrixi
    trixi_finalize();
}
