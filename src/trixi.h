#ifndef TRIXI_H_
#define TRIXI_H_

/**
 * @addtogroup api_c C API
 * @{
*/

// Setup
void trixi_initialize(const char * project_directory, const char * depot_path);
int trixi_initialize_simulation(const char * libelixir);
void trixi_finalize_simulation(int handle);
void trixi_finalize();

// Flow control
int trixi_is_finished(int handle);
void trixi_step(int handle);

// Basic querying
int trixi_ndims(int handle);         // Return number of spatial dimensions
int trixi_nelements(int handle);     // Return number of elements (cells)
int trixi_nvariables(int handle);    // Return number of (conservative) variables

// Data
void trixi_load_cell_averages(double * data, int handle);

// Misc
double trixi_calculate_dt(int handle);
void julia_eval_string(const char * code);

/**
 * @}
 */

#endif // ifndef LIBTRIXI_H_
