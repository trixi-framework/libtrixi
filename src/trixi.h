#ifndef TRIXI_H_
#define TRIXI_H_

/**
 * @addtogroup api_c C API
 * @{
*/

// Information
int trixi_version_major();
int trixi_version_minor();
int trixi_version_patch();
const char* trixi_version();
const char* trixi_version_julia();
const char* trixi_version_julia_extended();

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


// Store function pointers to avoid overhead of `jl_eval_string`
enum {
  TRIXI_FTPR_INITIALIZE_SIMULATION,
  TRIXI_FTPR_CALCULATE_DT,
  TRIXI_FTPR_IS_FINISHED,
  TRIXI_FTPR_STEP,
  TRIXI_FTPR_FINALIZE_SIMULATION,
  TRIXI_FTPR_NDIMS,
  TRIXI_FTPR_NELEMENTS,
  TRIXI_FTPR_NVARIABLES,
  TRIXI_FTPR_LOAD_CELL_AVERAGES,
  TRIXI_FTPR_VERSION,
  TRIXI_FTPR_VERSION_MAJOR,
  TRIXI_FTPR_VERSION_MINOR,
  TRIXI_FTPR_VERSION_PATCH,
  TRIXI_FTPR_VERSION_JULIA,
  TRIXI_FTPR_VERSION_JULIA_EXTENDED,

  // The last one is for the array size
  TRIXI_NUM_FPTRS
};

extern void* trixi_function_pointers[TRIXI_NUM_FPTRS];

// List of function names to obtain C function pointer from Julia
extern const char* trixi_function_pointer_names[TRIXI_NUM_FPTRS];

#endif // ifndef LIBTRIXI_H_
