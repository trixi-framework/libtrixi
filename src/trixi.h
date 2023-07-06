#ifndef TRIXI_H_
#define TRIXI_H_

#include <t8.h>
#include <t8_forest/t8_forest_general.h>

// Setup
void trixi_initialize(const char * project_directory);
int trixi_initialize_simulation(const char * libelixir);
void trixi_finalize_simulation(int handle);
void trixi_finalize();

t8_forest_t trixi_get_t8code_mesh(int handle);

// Flow control
int trixi_is_finished(int handle);
void trixi_step(int handle);

// Basic querying
int trixi_ndims(int handle);         // Return number of spatial dimensions
int trixi_nelements(int handle);     // Return number of elements (cells)
// int trixi_polydeg(int handle);       // Return polynomial degree of DGSEM approximation
int trixi_nvariables(int handle);    // Return number of (conservative) variables
// int trixi_ndofs(int handle);         // Return total number of degrees of freedom
// int trixi_ndofs_element(int handle); // Return number of degrees of freedom for one element

// Data
void trixi_get_cell_averages(double * data, int handle);

// Misc
double trixi_calculate_dt(int handle);
void julia_eval_string(const char * code);

#endif // ifndef LIBTRIXI_H_
