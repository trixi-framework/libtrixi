#include <stdio.h>
#include <julia.h>
#include <mpi.h>

#include "trixi.h"



void init_mpi_internal ( int argc, char *argv[] ) {

    printf("\nSetting up MPI from C library...\n");

    int ret;

    int flag_init;
    ret = MPI_Initialized(&flag_init);
    printf("MPI Initialized: return %d, initialized %d\n", ret, flag_init);

    if ( flag_init == 0 ) {

        int provided_threadlevel;
        int requested_threadlevel = MPI_THREAD_SERIALIZED;
        ret = MPI_Init_thread(&argc, &argv, requested_threadlevel, &provided_threadlevel);
        printf("MPI_Init: return %d, threadlevel requested %d, provided %d\n", ret, requested_threadlevel, provided_threadlevel);
    }

    MPI_Comm comm = MPI_COMM_WORLD;

    int rank;
    ret = MPI_Comm_rank(comm, &rank);
    printf("MPI rank: return %d, rank %d\n", ret, rank);

    int nranks;
    ret = MPI_Comm_size(comm, &nranks);
    printf("MPI size: return %d, size %d\n", ret, nranks);
}


void trixi_initialize( int argc, char *argv[] ) {

    init_mpi_internal(argc, argv);

    printf("\n");

    // Init Julia
    jl_init();

    // Activate julia environment
    jl_eval_string("using Pkg; Pkg.activate(\"../../run_julia_MPIonly\");");

    // Check MPI
    jl_eval_string("println(\"\nChecking MPI from Julia...\n\")");
    jl_eval_string("using MPI");
    jl_eval_string("println(\"Initialized: \", MPI.Initialized())");
    jl_eval_string("println(\"COMM_WORLD: \", MPI.COMM_WORLD)");
    //jl_eval_string("println(MPI.Init())");
    jl_eval_string("println(\"MPI.jl: rank: \", MPI.Comm_rank(MPI.COMM_WORLD))");
    jl_eval_string("println(\"MPI.jl: size: \", MPI.Comm_size(MPI.COMM_WORLD))");

    printf("\n");
}
