#include <limits.h>
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

// Auxiliary function to update JULIA_DEPOT_PATH environment variable
static void update_depot_path(const char * project_directory, const char * depot_path);

// Store function pointers to avoid overhead of `jl_eval_string`
enum {
  TRIXI_FTPR_INITIALIZE_SIMULATION,
  TRIXI_FTPR_CALCULATE_DT,
  TRIXI_FTPR_IS_FINISHED,
  TRIXI_FTPR_STEP,
  TRIXI_FTPR_FINALIZE_SIMULATION,

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
};

// Default depot path *relative* to the project directory
// OBS! If you change the value here, you should also update the default value of
// `LIBTRIXI_JULIA_DEPOT` in `utils/libtrixi-init-julia` accordingly
static const char* default_depot_path = "julia-depot";


/**
 * @brief Initialize Julia runtime environment
 * 
 * Initialize Julia and activate the project at `project_directory`. If `depot_path` is not
 * a null pointer, forcefully set the environment variable `JULIA_DEPOT_PATH` to the value
 * of `depot_path`. If `depot_path` *is* null, then proceed as follows:
 * If `JULIA_DEPOT_PATH` is already set, do not touch it. Otherwise, set `JULIA_DEPOT_PATH`
 * to `project_directory` + `default_depot_path`
 * 
 * @param project_directory Path to project directory.
 * @param depot_path Path to Julia depot path (optional; can be null pointer).
 */
void trixi_initialize(const char * project_directory, const char * depot_path) {
    // Update JULIA_DEPOT_PATH environment variable before initializing Julia
    update_depot_path(project_directory, depot_path);

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
      print_and_die("buffer size not sufficient for activation command", LOC);
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


/** Finalize Julia runtime environment.
 *
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



void julia_eval_string(const char * code) {

    checked_eval_string(code, LOC);
};


/** Set JULIA_DEPOT_PATH environment variable appropriately
 *
 */
void update_depot_path(const char * project_directory, const char * depot_path) {
  // Set/modify Julia's depot path if desired
  if (depot_path != NULL) {
    // If depot path is provided as an argument, set environment variable JULIA_DEPOT_PATH
    // to it
    setenv("JULIA_DEPOT_PATH", depot_path, 1);
    if (show_debug_output()) {
      printf("JULIA_DEPOT_PATH set to \"%s\"\n", depot_path);
    }
  } else if (getenv("JULIA_DEPOT_PATH") == NULL) {
    // Otherwise, if environment variable is *not* already set, set it to
    // `project_directory` + `default_depot_path`

    // Verify that buffer size is large enough (+2 for '/' and trailing null)
    char path[1024];
    if ( strlen(project_directory) + strlen(default_depot_path) + 2 > 1024 ) {
      print_and_die("buffer size not sufficient for depot path construction", LOC);
    }

    // Construct complete path
    strcpy(path, project_directory);
    strcat(path, "/");
    strcat(path, default_depot_path);

    // Construct absolute path
    char absolute_path[PATH_MAX];
    realpath(path, absolute_path);

    // Set environment variable
    setenv("JULIA_DEPOT_PATH", absolute_path, 1);
    if (show_debug_output()) {
      printf("JULIA_DEPOT_PATH set to \"%s\"\n", absolute_path);
    }
  }
}


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

int show_debug_output() {
  const char * env = getenv("LIBTRIXI_DEBUG");
  if (env == NULL) {
    return 0;
  }

  if (strcmp(env, "all") == 0 || strcmp(env, "c") == 0) {
    return 1;
  } else {
    return 0;
  }
}
