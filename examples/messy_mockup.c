#include <stdio.h>
#include <mpi.h>

#include <trixi.h>


#if 1
void init_mpi_external ( int argc, char *argv[] ) {

    printf("\nSetting up MPI from calling C executable...\n");

    int ret;

    int flag_init;
    ret = MPI_Initialized(&flag_init);
    printf("MPI Initialized: return %d, init %d\n", ret, flag_init);

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
#else
void init_mpi_external ( int argc, char *argv[] ) {};
#endif


int main ( int argc, char *argv[] ) {

    init_mpi_external(argc, argv);

    trixi_initialize(argc, argv);

    return 0;
}
