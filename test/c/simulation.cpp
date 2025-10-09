#include <gtest/gtest.h>
#include <mpi.h>

extern "C" {
    #include "../src/trixi.h"
}

// Julia project path defined via cmake
const char * julia_project_path = JULIA_PROJECT_PATH;

// Example libexlixir
const char * libelixir_path =
  "../../../LibTrixi.jl/examples/libelixir_p4est2d_euler_sedov.jl";

TEST(CInterfaceTest, SimulationRun) {

    // Initialize MPI
    int argc = 0;
    char *** argv = NULL;
    int provided_threadlevel;
    int requested_threadlevel = MPI_THREAD_SERIALIZED;
    MPI_Init_thread(&argc, argv, requested_threadlevel, &provided_threadlevel);

    MPI_Comm comm = MPI_COMM_WORLD;

    int rank;
    MPI_Comm_rank(comm, &rank);

    int nranks;
    MPI_Comm_size(comm, &nranks);

    // Initialize libtrixi
    trixi_initialize(julia_project_path, NULL);

    // Set up the Trixi simulation, get a handle
    int handle = trixi_initialize_simulation(libelixir_path);
    EXPECT_EQ(handle, 1);

    // Using a non-existent handle should fail and exit
    EXPECT_DEATH(trixi_is_finished(42),
                 "the provided handle was not found in the stored simulation states: 42");

    // Store a vector in registry
    std::vector<double> test_data(3);
    trixi_register_data(handle, 1, 3, test_data.data());
    EXPECT_DEATH(trixi_register_data(handle, 2, 3, test_data.data()),
                 "BoundsError");

    // Do 10 simulation steps
    for (int i = 0; i < 10; ++i) {
        trixi_step(handle);
    }

    // Check time step length
    double dt = trixi_calculate_dt(handle);
    EXPECT_NEAR(dt, 0.0028566952356658794, 1e-17);

    // Check time
    double time = trixi_get_simulation_time(handle);
    EXPECT_NEAR(time, 0.0304927240859461, 1e-16);
    
    // Check finished status
    int finished_status = trixi_is_finished(handle);
    EXPECT_EQ(finished_status, 0);

    // Check number of dimensions
    int ndims = trixi_ndims(handle);
    EXPECT_EQ(ndims, 2);

    // Check number of elements
    int nelements = trixi_nelements(handle);
    int nelementsglobal = trixi_nelementsglobal(handle);
    EXPECT_EQ(nelements * nranks, nelementsglobal);

    // Check number of dofs
    int ndofs = trixi_ndofs(handle);
    int ndofsglobal = trixi_ndofsglobal(handle);
    EXPECT_EQ(ndofs * nranks, ndofsglobal);

    int ndofselement = trixi_ndofselement(handle);
    EXPECT_EQ(nelements * ndofselement, ndofs);
    EXPECT_EQ(nelementsglobal * ndofselement, ndofsglobal);

    // Check number of variables
    int nvariables = trixi_nvariables(handle);
    EXPECT_EQ(nvariables, 4);

    // Check number of quadrature nodes
    int nnodes = trixi_nnodes(handle);
    EXPECT_EQ(nnodes, 5);

    // Check quadrature, integrate f(x) = x^4 over [-1,1]
    std::vector<double> nodes(nnodes);
    std::vector<double> weights(nnodes);
    trixi_load_node_reference_coordinates(handle, nodes.data());
    trixi_load_node_weights(handle, weights.data());
    double integral = 0.0;
    for (int i = 0; i < nnodes; ++i) {
        integral += weights[i] * nodes[i] * nodes[i] * nodes[i]* nodes[i];
    }
    EXPECT_NEAR(integral, 0.4, 1e-17);

    // Check conservative variable values
    std::vector<double> rho(ndofs);
    std::vector<double> rho_energy(ndofs);
    trixi_load_conservative_var(handle, 1, rho.data());
    trixi_load_conservative_var(handle, 4, rho_energy.data());
    // check memory borders
    EXPECT_DOUBLE_EQ(rho[0],              1.0);
    EXPECT_DOUBLE_EQ(rho[ndofs-1],        1.0);
    EXPECT_DOUBLE_EQ(rho_energy[0],       2.5e-5);
    EXPECT_DOUBLE_EQ(rho_energy[ndofs-1], 2.5e-5);

    // Check primitive variable values
    std::vector<double> energy(ndofs);
    trixi_load_primitive_var(handle, 1, rho.data());
    trixi_load_primitive_var(handle, 4, energy.data());
    // check memory borders
    EXPECT_DOUBLE_EQ(rho[0],          1.0);
    EXPECT_DOUBLE_EQ(rho[ndofs-1],    1.0);
    EXPECT_DOUBLE_EQ(energy[0],       1.0e-5);
    EXPECT_DOUBLE_EQ(energy[ndofs-1], 1.0e-5);

    // Check element averaged values
    std::vector<double> rho_averages(nelements);
    std::vector<double> v1_averages(nelements);
    std::vector<double> v2_averages(nelements);
    std::vector<double> e_averages(nelements);
    trixi_load_element_averaged_primitive_var(handle, 1, rho_averages.data());
    trixi_load_element_averaged_primitive_var(handle, 2, v1_averages.data());
    trixi_load_element_averaged_primitive_var(handle, 3, v2_averages.data());
    trixi_load_element_averaged_primitive_var(handle, 4, e_averages.data());
    if (nranks == 1) {
        // check memory borders (densities at the beginning, energies at the end)
        EXPECT_DOUBLE_EQ(rho_averages[0],         1.0);
        EXPECT_DOUBLE_EQ(e_averages[nelements-1], 1.0e-5);
        // check values somewhere near the center (expect symmetries)
        // densities
        EXPECT_NEAR(rho_averages[ 93],            0.88263491354796, 1e-14);
        EXPECT_NEAR(rho_averages[ 94],            0.88263491354796, 1e-14);
        EXPECT_NEAR(rho_averages[161],            0.88263491354796, 1e-14);
        EXPECT_NEAR(rho_averages[162],            0.88263491354796, 1e-14);
        // velocities
        EXPECT_NEAR(v1_averages[ 93],            -0.14037267400591, 1e-14);
        EXPECT_NEAR(v2_averages[ 94],            -0.14037267400591, 1e-14);
        EXPECT_NEAR(v2_averages[161],             0.14037267400591, 1e-14);
        EXPECT_NEAR(v1_averages[162],             0.14037267400591, 1e-14);
    }
    else if (nranks == 2) {
        if (rank == 0) {
            // check memory borders (densities at the beginning, energies at the end)
            EXPECT_DOUBLE_EQ(rho_averages[0],         1.0);
            EXPECT_DOUBLE_EQ(e_averages[nelements-1], 1.0e-5);
            // check values somewhere near the center (expect symmetries)
            // densities
            EXPECT_NEAR(rho_averages[93],             0.88263491354796, 1e-14);
            EXPECT_NEAR(rho_averages[94],             0.88263491354796, 1e-14);
            // velocities
            EXPECT_NEAR(v1_averages[93],             -0.14037267400591, 1e-14);
            EXPECT_NEAR(v2_averages[94],             -0.14037267400591, 1e-14);
        }
        else {
            // check memory borders (densities at the beginning, energies at the end)
            EXPECT_DOUBLE_EQ(rho_averages[0],         1.0);
            EXPECT_DOUBLE_EQ(e_averages[nelements-1], 1.0e-5);
            // check values somewhere near the center (expect symmetries)
            // densities
            EXPECT_NEAR(rho_averages[33],             0.88263491354796, 1e-14);
            EXPECT_NEAR(rho_averages[34],             0.88263491354796, 1e-14);
            // velocities
            EXPECT_NEAR(v2_averages[33],              0.14037267400591, 1e-14);
            EXPECT_NEAR(v1_averages[34],              0.14037267400591, 1e-14);
        }
    }
    else {
        FAIL() << "Test cannot be run with " << nranks << " ranks.";
    }

    // Check storing of conservative variables
    rho[0] = 42.0;
    rho[ndofs-1] = 23.0;
    trixi_store_conservative_var(handle, 1, rho.data());

    double * raw_data = trixi_get_conservative_vars_pointer(handle);
    EXPECT_DOUBLE_EQ(rho[0],       raw_data[0]);
    EXPECT_DOUBLE_EQ(rho[ndofs-1], raw_data[4*(ndofs-1)]);

    // Finalize Trixi simulation
    trixi_finalize_simulation(handle);

    // Handle is now invalid and subsequent use should fail
    EXPECT_DEATH(trixi_is_finished(handle),
                 "the provided handle was not found in the stored simulation states: 1");

    // Finalize libtrixi
    trixi_finalize();

    // Finalize MPI
    MPI_Finalize();
}
