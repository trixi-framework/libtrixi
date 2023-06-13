#ifndef LIBTRIXI_H_
#define LIBTRIXI_H_

#include <mpi.h> // required for MPI

void trixi_initialize(MPI_Fint* comm);
void trixi_finalize();
double trixi_get_timestep();
void trixi_integrate();
void julia_eval_repl(const char * code);

#endif // ifndef LIBTRIXI_H_
