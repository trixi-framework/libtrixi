#include <t8.h>                 /* General t8code header, always include this. */

int main (int argc, char **argv)
{
    int                 mpiret;

    /* Initialize MPI. This has to happen before we initialize sc or t8code. */
    mpiret = sc_MPI_Init (&argc, &argv);
    /* Error check the MPI return value. */
    SC_CHECK_MPI (mpiret);

    /* Initialize the sc library, has to happen before we initialize t8code. */
    sc_init (sc_MPI_COMM_WORLD, 1, 1, NULL, SC_LP_ESSENTIAL);
    /* Initialize t8code with log level SC_LP_PRODUCTION. See sc.h for more info on the log levels. */
    t8_init (SC_LP_PRODUCTION);

    /* Print a message on the root process. */
    t8_global_productionf (" [step0] \n");
    t8_global_productionf (" [step0] Hello, this is t8code :)\n");
    t8_global_productionf (" [step0] \n");

    sc_finalize ();

    mpiret = sc_MPI_Finalize ();
    SC_CHECK_MPI (mpiret);

    return 0;
}
