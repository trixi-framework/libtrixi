#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <julia.h>

#include "trixi.h"


// Auxiliary declarations for more helpful error messages
static void print_and_die(const char* message, const char* func, const char* file, int lineno);
#define LOC __func__, __FILE__, __LINE__

// Auxiliary function to evaluate julia REPL string with exception handling
static jl_value_t* checked_eval_string(const char* code, const char* func, const char* file, int lineno);

// Auxiliary function to determine debug level
static int show_debug_output();

// Store function pointers to avoid overhead of `jl_eval_string`
enum {
  TRIXI_FTPR_INITIALIZE_SIMULATION,
  TRIXI_FTPR_CALCULATE_DT,
  TRIXI_FTPR_IS_FINISHED,
  TRIXI_FTPR_STEP,
  TRIXI_FTPR_FINALIZE_SIMULATION,
  TRIXI_FTPR_GET_T8CODE_MESH,
  TRIXI_FTPR_NDIMS,
  TRIXI_FTPR_NELEMENTS,
  TRIXI_FTPR_NVARIABLES,
  TRIXI_FTPR_GET_CELL_AVERAGES,

  // The last one is for the array size
  TRIXI_NUM_FPTRS
};
static void* trixi_function_pointers[TRIXI_NUM_FPTRS];

// List of function names to obtain C function pointer from Julia
// OBS! If any name is longer than 250 characters, adjust buffer sizes below
static const char* trixi_function_pointer_names[] = {
  [TRIXI_FTPR_INITIALIZE_SIMULATION] = "trixi_initialize_simulation_cfptr",
  [TRIXI_FTPR_CALCULATE_DT]          = "trixi_calculate_dt_cfptr",
  [TRIXI_FTPR_IS_FINISHED]           = "trixi_is_finished_cfptr",
  [TRIXI_FTPR_STEP]                  = "trixi_step_cfptr",
  [TRIXI_FTPR_FINALIZE_SIMULATION]   = "trixi_finalize_simulation_cfptr",
  [TRIXI_FTPR_GET_T8CODE_MESH]       = "trixi_get_t8code_mesh_cfptr"
  [TRIXI_FTPR_NDIMS]                 = "trixi_ndims_cfptr",
  [TRIXI_FTPR_NELEMENTS]             = "trixi_nelements_cfptr",
  [TRIXI_FTPR_NVARIABLES]            = "trixi_nvariables_cfptr",
  [TRIXI_FTPR_GET_CELL_AVERAGES]     = "trixi_get_cell_averages_cfptr",
};



/** Initialize Julia runtime environment
 *
 *  \param[in]  project_directory  path to julia project directory
 */
void trixi_initialize(const char * project_directory) {

    // Init Julia
    jl_init();

    // Construct activation command
    const char * activate_regular = "using Pkg;\n"
                                    "Pkg.activate(\"%s\"; io=devnull);\n";
    const char * activate_debug = "using Pkg;\n"
                                  "Pkg.activate(\"%s\");\n"
                                  "Pkg.status();\n";
    const char * activate = show_debug_output() ? activate_debug : activate_regular;
    if ( strlen(activate) + strlen(project_directory) + 1 > 1024 ) {
        fprintf(stderr, "error: buffer size not sufficient for activation command\n");
        exit(1);
    }
    char buffer[1024];
    snprintf(buffer, 1024, activate, project_directory);

    // Activate julia environment
    checked_eval_string(buffer, LOC);

    // Load LibTrixi module
    checked_eval_string("using LibTrixi;", LOC);
    if (show_debug_output()) {
      checked_eval_string("println(\"Module LibTrixi.jl loaded\")", LOC);
    }

    // Load function pointers
    char julia_command[256];
    for (int i = 0; i < TRIXI_NUM_FPTRS; i++) {
      // Reset for error detection
      trixi_function_pointers[i] = NULL;

      // Build Julia command
      snprintf(julia_command, 256, "%s()", trixi_function_pointer_names[i]);

      // Get and store function pointer
      trixi_function_pointers[i] = (void *)jl_unbox_voidpointer( checked_eval_string(julia_command, LOC) );

      // Perform sanity check
      if (trixi_function_pointers[i] == NULL) {
        fprintf(stderr, "ERROR: could not get function pointer with `%s()`\n",
                trixi_function_pointer_names[i]);
        print_and_die("null pointer", LOC);
      }
    }
}


/** Set up Trixi simulation
 *
 *  \param[in]  libelixir  path to file containing Trixi setup
 *
 *  \return handle (integer) to Trixi simulation instance
 */
int trixi_initialize_simulation(const char * libelixir) {

    // Get function pointer
    int (*initialize_simulation)(const char *) = trixi_function_pointers[TRIXI_FTPR_INITIALIZE_SIMULATION];

    // Call function
    return initialize_simulation( libelixir );
}


/** Get time step length of Trixi simulation
 *
 *  \param[in] handle simulation handle to release
 *
 *  \return Time step length
 */
double trixi_calculate_dt(int handle) {

    // Get function pointer
    double (*calculate_dt)(int) = trixi_function_pointers[TRIXI_FTPR_CALCULATE_DT];;

    // Call function
    return calculate_dt( handle );
}


/** Check if Trixi simulation is finished
 *
 *  \param[in] handle simulation handle
 *
 *  \return 1 if finished, 0 if not
 */
int trixi_is_finished(int handle) {

    // Get function pointer
    int (*is_finished)(int) = trixi_function_pointers[TRIXI_FTPR_IS_FINISHED];

    // Call function
    return is_finished( handle );
}


/** Perform one step in Trixi simulation
 *
 *  \param[in] handle simulation handle
 */
void trixi_step(int handle) {

    // Get function pointer
    int (*step)(int) = trixi_function_pointers[TRIXI_FTPR_STEP];

    // Call function
    step( handle );
}


/** Finalize Trixi simulation
 *
 *  \param[in] handle simulation handle to release
 */
void trixi_finalize_simulation(int handle) {

    // Get function pointer
    void (*finalize_simulation)(int) = trixi_function_pointers[TRIXI_FTPR_FINALIZE_SIMULATION];

    // Call function
    finalize_simulation(handle);
}


/** Finalize Julia runtime environment
 */
void trixi_finalize() {

    if (show_debug_output()) {
        printf("libtrixi: finalize\n");
    }

    // Reset function pointers
    for (int i = 0; i < TRIXI_NUM_FPTRS; i++) {
      trixi_function_pointers[i] = NULL;
    }

    jl_atexit_hook(0);
}


/** Get t8code forest
 *
 *  For Trixi simulations on t8code meshes, the t8code forest is returned
 *
 *  \param[in] handle simulation handle to release
 *
 *  \return t8code forest
 */
t8_forest_t trixi_get_t8code_mesh(int handle) {

  // Get function pointer
  t8_forest_t (*get_t8code_mesh)(int) = trixi_function_pointers[TRIXI_FTPR_GET_T8CODE_MESH];

    // Call function
  return get_t8code_mesh(handle);
}


/** Return number of spatial dimensions
 *
 *  \param[in] handle simulation handle to release
 */
int trixi_ndims(int handle) {

    // Get function pointer
    int (*ndims)(int) = trixi_function_pointers[TRIXI_FTPR_NDIMS];

    // Call function
    return ndims(handle);
}


/** Return number of elements (cells)
 *
 *  \param[in] handle simulation handle to release
 */
int trixi_nelements(int handle) {

    // Get function pointer
    int (*nelements)(int) = trixi_function_pointers[TRIXI_FTPR_NELEMENTS];

    // Call function
    return nelements(handle);
}


/** Return number of (conservative) variables
 *
 *  \param[in] handle simulation handle to release
 */
int trixi_nvariables(int handle) {

    // Get function pointer
    int (*nvariables)(int) = trixi_function_pointers[TRIXI_FTPR_NVARIABLES];

    // Call function
    return nvariables(handle);
}

// int trixi_polydeg(int handle);       // Return polynomial degree of DGSEM approximation
// int trixi_ndofs(int handle);         // Return total number of degrees of freedom
// int trixi_ndofs_element(int handle); // Return number of degrees of freedom for one element


/** Return cell averaged values
 *
 *  Cell averaged values for each cell and each variable are stored in a contiguous array.
 *  The given array has to be of correct size and memory has to be allocated beforehand.
 *
 *  \param[in] handle simulation handle to release
 *  \param[out] data cell averaged values for all cells and all variables
 */
void trixi_get_cell_averages(double * data, int handle) {

    // Get function pointer
    void (*get_cell_averages)(double *, int) = trixi_function_pointers[TRIXI_FTPR_GET_CELL_AVERAGES];

    // Call function
    get_cell_averages(data, handle);
}


void julia_eval_string(const char * code) {

    checked_eval_string(code, LOC);
};


/*  Run Julia command and check for errors
 *
 *  Adapted from the Julia repository.
 *  Source: https://github.com/JuliaLang/julia/blob/c0dd6ff8363f948237304821941b06d67014fa6a/test/embedding/embedding.c#L17-L31
 */
jl_value_t* checked_eval_string(const char* code, const char* func, const char* file, int lineno) {

    jl_value_t *result = jl_eval_string(code);

    if (jl_exception_occurred()) {

        // none of these allocate, so a gc-root (JL_GC_PUSH) is not necessary
        jl_printf(jl_stderr_stream(), "ERROR in %s:%d (%s):\n", file, lineno, func);
        jl_printf(jl_stderr_stream(), "The following Julia code could not be evaluated: %s\n", code);
        jl_call2(jl_get_function(jl_base_module, "showerror"), jl_stderr_obj(), jl_exception_occurred());
        jl_printf(jl_stderr_stream(), "\n");
        jl_atexit_hook(1);
        exit(1);
    }

    assert(result && "Missing return value but no exception occurred!");

    return result;
}

void print_and_die(const char* message, const char* func, const char* file, int lineno) {
  fprintf(stderr, "ERROR in %s:%d (%s): %s\n", file, lineno, func, message);
  exit(1);
}

static int show_debug_output() {
  const char * env = getenv("LIBTRIXI_DEBUG");
  if (!env) {
    return 0;
  }

  if (strcmp(env, "all") == 0 || strcmp(env, "c") == 0) {
    return 1;
  } else {
    return 0;
  }
}
