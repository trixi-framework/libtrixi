#ifndef LIBTRIXI_H_
#define LIBTRIXI_H_

#include <mpi.h> // required for MPI

void trixi_initialize();
void trixi_finalize();
double trixi_get_timestep();
void trixi_integrate();

#endif // ifndef LIBTRIXI_H_
