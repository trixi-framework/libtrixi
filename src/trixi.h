#ifndef TRIXI_H_
#define TRIXI_H_

/**
 * @addtogroup api_c C API
 * @{
*/

// Setup
void trixi_initialize(const char * project_directory, const char * depot_path);
void trixi_finalize();

// Version information
int trixi_version_major();
int trixi_version_minor();
int trixi_version_patch();
const char* trixi_version();
const char* trixi_version_julia();
const char* trixi_version_julia_extended();

// Simulation control
int trixi_initialize_simulation(const char * libelixir);
void trixi_finalize_simulation(int handle);
int trixi_is_finished(int handle);
void trixi_step(int handle);

// Simulation data
int trixi_ndims(int handle);
int trixi_nelements(int handle);
int trixi_nvariables(int handle);
double trixi_calculate_dt(int handle);
void trixi_load_cell_averages(double * data, int handle);

/**
 * @}
 */

#endif // ifndef LIBTRIXI_H_
