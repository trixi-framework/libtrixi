#include <limits.h>
#include <stdio.h>
#include <stdlib.h>

#include "trixi.h"
#include "auxiliary.h"
#include "function_pointers.h"


// Default depot path *relative* to the project directory
// OBS! If you change the value here, you should also update the default value of
// `LIBTRIXI_JULIA_DEPOT` in `utils/libtrixi-init-julia` accordingly
static const char* default_depot_path = "julia-depot";


// Local helper function to set JULIA_DEPOT_PATH environment variable
void update_depot_path(const char * project_directory, const char * depot_path) {
    // Set/modify Julia's depot path if desired
    if (depot_path != NULL) {
        // If depot path is provided as an argument, set environment variable
        // JULIA_DEPOT_PATH to it
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


/**
 * @anchor trixi_initialize_api_c
 *
 * @brief Initialize Julia runtime environment
 * 
 * Initialize Julia and activate the project at `project_directory`. If `depot_path` is not
 * a null pointer, forcefully set the environment variable `JULIA_DEPOT_PATH` to the value
 * of `depot_path`. If `depot_path` *is* null, then proceed as follows:
 * If `JULIA_DEPOT_PATH` is already set, do not touch it. Otherwise, set `JULIA_DEPOT_PATH`
 * to `project_directory` + `default_depot_path`
 * 
 * @param[in]  project_directory  Path to project directory.
 * @param[in]  depot_path         Path to Julia depot path (optional; can be null pointer).
 */
void trixi_initialize(const char * project_directory, const char * depot_path) {
    // Update JULIA_DEPOT_PATH environment variable before initializing Julia
    update_depot_path(project_directory, depot_path);

    // Init Julia
    jl_init();

    // Construct activation command
    const char * activate = "using Pkg;\n"
                            "Pkg.activate(\"%s\"; io=devnull);\n";
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

    // Store function pointers to avoid overhead of `jl_eval_string`
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

    // Show version info
    if (show_debug_output()) {
      printf("\nlibtrixi %s\n\n", trixi_version());
      printf("Loaded Julia packages:\n%s\n\n", trixi_version_julia());
    }
}


/**
 * @anchor trixi_finalize_api_c
 *
 * @brief Finalize Julia runtime environment
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