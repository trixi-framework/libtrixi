#include <gtest/gtest.h>
#include <t8.h>
#include <t8_forest/t8_forest_general.h>

extern "C" {
    #include "../src/trixi.h"
}

// Julia project path defined via cmake
const char * julia_project_path = JULIA_PROJECT_PATH;

// Example libexlixir
const char * libelixir_path =
  "../../../LibTrixi.jl/examples/libelixir_t8code_2d_dgsem_advection_basic.jl";

TEST(CInterfaceTest, T8code) {

    // Initialize libtrixi
    trixi_initialize(julia_project_path, NULL);

    // Set up the Trixi simulation, get a handle
    int handle = trixi_initialize_simulation(libelixir_path);

    // Check t8code mesh
    t8_forest_t trixi_forest = trixi_get_t8code_forest(handle);
    t8_cmesh_t  trixi_cmesh  = trixi_get_t8code_cmesh(handle);
    t8_cmesh_t  t8code_cmesh = t8_forest_get_cmesh(trixi_forest);
    EXPECT_EQ(trixi_cmesh, t8code_cmesh);
    
    // Finalize Trixi simulation
    trixi_finalize_simulation(handle);

    // Finalize libtrixi
    trixi_finalize();
}
