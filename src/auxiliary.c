#include <limits.h>
#include <stdio.h>
#include <stdlib.h>

#include "auxiliary.h"


// Default depot path *relative* to the project directory
// OBS! If you change the value here, you should also update the default value of
// `LIBTRIXI_JULIA_DEPOT` in `utils/libtrixi-init-julia` accordingly
static const char* default_depot_path = "julia-depot";


// Helper function to set JULIA_DEPOT_PATH environment variable
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
        char * ret = realpath(path, absolute_path);
        if (ret == NULL) {
            print_and_die("could not resolve depot path", LOC);
        }

        // Set environment variable
        setenv("JULIA_DEPOT_PATH", absolute_path, 1);
        if (show_debug_output()) {
            printf("JULIA_DEPOT_PATH set to \"%s\"\n", absolute_path);
        }
    }
}


// Function for more helpful error messages
void print_and_die(const char* message, const char* func, const char* file, int lineno) {
    fprintf(stderr, "ERROR in %s:%d (%s): %s\n", file, lineno, func, message);
    exit(1);
}


// Function to determine debug level
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


// Run Julia command and check for errors
// Source: https://github.com/JuliaLang/julia/blob/c0dd6ff8363f948237304821941b06d67014fa6a/test/embedding/embedding.c#L17-L31
jl_value_t* checked_eval_string(const char* code, const char* func, const char* file,
                                int lineno) {

    jl_value_t *result = jl_eval_string(code);

    if (jl_exception_occurred()) {

        // none of these allocate, so a gc-root (JL_GC_PUSH) is not necessary
        jl_printf(jl_stderr_stream(), "ERROR in %s:%d (%s):\n", file, lineno, func);
        jl_printf(jl_stderr_stream(),
                  "The following Julia code could not be evaluated: %s\n", code);
        jl_call2(jl_get_function(jl_base_module, "showerror"), jl_stderr_obj(),
                 jl_exception_occurred());
        jl_printf(jl_stderr_stream(), "\n");
        jl_atexit_hook(1);
        exit(1);
    }

    assert(result && "Missing return value but no exception occurred!");

    return result;
}


// Function to get and store function pointers from Julia to C functions
void store_function_pointers(int num_fptrs, const char * fptr_names[], void * fptrs[]) {

    char julia_command[256];

    for (int i = 0; i < num_fptrs; i++) {
        // Reset for error detection
        fptrs[i] = NULL;

        // Build Julia command
        snprintf(julia_command, 256, "%s()", fptr_names[i]);

        // Get and store function pointer
        fptrs[i] = (void *)jl_unbox_voidpointer( checked_eval_string(julia_command, LOC) );

        // Perform sanity check
        if (fptrs[i] == NULL) {
            fprintf(stderr, "ERROR: could not get function pointer with `%s()`\n",
                    fptr_names[i]);
            print_and_die("null pointer", LOC);
        }
    }
}
