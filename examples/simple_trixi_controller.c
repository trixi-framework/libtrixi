#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>

#include <trixi.h>



void init_mpi_external ( int argc, char *argv[] ) {

    int ret;

    int flag_init;
    ret = MPI_Initialized(&flag_init);
    printf("[EXT] MPI Initialized: return %d, initialized %d, MPI_COMM_WORLD %p\n", ret, flag_init, MPI_COMM_WORLD);

    if ( flag_init == 0 ) {

        int provided_threadlevel;
        int requested_threadlevel = MPI_THREAD_SERIALIZED;
        ret = MPI_Init_thread(&argc, &argv, requested_threadlevel, &provided_threadlevel);
        printf("[EXT] MPI_Init: return %d, threadlevel requested %d, provided %d\n", ret, requested_threadlevel, provided_threadlevel);
    }

    MPI_Comm comm = MPI_COMM_WORLD;

    int rank;
    ret = MPI_Comm_rank(comm, &rank);
    printf("[EXT] MPI rank: return %d, rank %d\n", ret, rank);

    int nranks;
    ret = MPI_Comm_size(comm, &nranks);
    printf("[EXT] MPI size: return %d, size %d\n", ret, nranks);

    ret = MPI_Comm_set_errhandler(comm, MPI_ERRORS_RETURN);
    printf("[EXT] MPI errhandler: return %d\n", ret);

}


int main ( int argc, char *argv[] ) {

    if ( argc < 2 ) {
        fprintf(stderr, "ERROR: missing arguments: PROJECT_DIR LIBELIXIR_PATH\n\n");
        fprintf(stderr, "usage: %s PROJECT_DIR LIBELIXIR_PATH\n", argv[0]);
        return 2;
    } else if ( argc < 3 ) {
        fprintf(stderr, "ERROR: missing argument: LIBELIXIR_PATH\n\n");
        fprintf(stderr, "usage: %s PROJECT_DIR LIBELIXIR_PATH\n", argv[0]);
        return 2;
    }

    // Initialize MPI
    printf("\n*** Trixi controller ***   Initialize MPI\n");
    init_mpi_external(argc, argv);

    // Initialize Trixi
    printf("\n*** Trixi controller ***   Initialize Trixi\n");
    trixi_initialize( argv[1], NULL );

    // Print version information
    printf("libtrixi version: %d.%d.%d %s\n",
        trixi_version_library_major(), trixi_version_library_minor(),
        trixi_version_library_patch(), trixi_version_library());
    printf("\nAll loaded julia packages:\n%s\n", trixi_version_julia_extended());

    // Execute julia code
    printf("\nExecute julia code\n");
    trixi_eval_julia("println(\"3! = \", factorial(3))");

    // Set up the Trixi simulation
    // We get a handle to use subsequently
    printf("\n*** Trixi controller ***   Set up Trixi simulation\n");
    int handle = trixi_initialize_simulation( argv[2] );

    // Get time step length
    printf("*** Trixi controller ***   Current time step length: %f\n", trixi_calculate_dt(handle));

    // Main loop
    printf("\n*** Trixi controller ***   Entering main loop\n");
    while ( !trixi_is_finished( handle ) ) {

        trixi_step( handle );
    }

    // Finalize Trixi simulation
    printf("\n*** Trixi controller ***   Finalize Trixi simulation\n");
    trixi_finalize_simulation( handle );

    // Finalize Trixi
    printf("\n*** Trixi controller ***   Finalize Trixi\n");
    trixi_finalize();

    // Finalize MPI
    printf("\n*** Trixi controller ***   Finalize MPI\n");
    MPI_Finalize();

    return 0;
}
