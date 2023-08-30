#include <gtest/gtest.h>
#include <mpi.h>

extern "C" {
    #include "../src/trixi.h"
}

// Julia project path defined via cmake
const char * julia_project_path = JULIA_PROJECT_PATH;

// Example libexlixir
const char * libelixir_path =
  "../../../LibTrixi.jl/examples/libelixir_p4est2d_dgsem_euler_sedov.jl";

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
    int nelements_local = trixi_nelements_local(handle);
    int nelements_global = trixi_nelements_global(handle);
    EXPECT_EQ(nelements_local * nranks, nelements_global);

    // Check number of variables
    int nvariables = trixi_nvariables(handle);
    EXPECT_EQ(nvariables, 4);

    // Check cell averaged values
    int size = nelements_local * nvariables;
    std::vector<double> cell_averages(size);
    trixi_load_cell_averages(cell_averages.data(), handle);
    if (nranks == 1) {
        EXPECT_DOUBLE_EQ(cell_averages[0],           1.0);
        EXPECT_DOUBLE_EQ(cell_averages[size/2-1],   -3.0346140495876783e-22);
        EXPECT_DOUBLE_EQ(cell_averages[size/2],      4.1457311447452736e-22);
        EXPECT_DOUBLE_EQ(cell_averages[size-1],      1.0e-5);
    }
    else if (nranks == 2) {
        if (rank == 0) {
            EXPECT_DOUBLE_EQ(cell_averages[0],       1.0);
            EXPECT_DOUBLE_EQ(cell_averages[size-1], -3.0346140495876783e-22);
        }
        else {
            EXPECT_DOUBLE_EQ(cell_averages[0],       4.1457311447452736e-22);
            EXPECT_DOUBLE_EQ(cell_averages[size-1],  1.0e-5);
        }
    }
    else {
        FAIL() << "Test cannot be run with " << nranks << " ranks.";
    }
    
    // Finalize Trixi simulation
    trixi_finalize_simulation( handle );

    // Handle is now invalid and subsequent use should fail
    EXPECT_DEATH(trixi_is_finished(handle),
                 "the provided handle was not found in the stored simulation states: 1");

    // Finalize libtrixi
    trixi_finalize();

    // Finalize MPI
    MPI_Finalize();
}
