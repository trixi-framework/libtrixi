#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <julia_init.h>

// Track initialization/finalization status to prevent unhelpful errors
static int is_initialized = 0;
static int is_finalized = 0;

void trixi_initialize(const char * project_directory__unused,
                      const char * depot_path__unused) {
    // Prevent double initialization
    if (is_initialized) {
        fprintf(stderr, "ERROR in %s:%d (%s): %s\n", __FILE__, __LINE__, __func__,
                "trixi_initialize invoked multiple times");
        exit(1);
    }
    // Initialization after finalization is also erroneous, but finalization requires
    // initialization, so this is already caught above.

    // Check if we want debug output
    const char * env = getenv("LIBTRIXI_DEBUG");
    const int show_debug = (env != NULL &&
                            (strcmp(env, "all") == 0 || strcmp(env, "c") == 0));

    // Do not error if project directory or depot path are passed, since this is supposed to
    // work interchangeably with the C based library. However, if debugging is enabled, we
    // can at least inform the user about it
    if (project_directory__unused != NULL && show_debug) {
      printf("trixi_initialize: 'project_directory' is non-null but will not be used\n");
    }
    if (depot_path__unused != NULL && show_debug) {
      printf("trixi_initialize: 'depot_path' is non-null but will not be used\n");
    }

    // Init Julia (do not pass command line arguments)
    int argc = 0;
    char** argv = NULL;
    init_julia(argc, argv);

    if (show_debug) {
      printf("trixi_initialize: Julia has been initialized\n");
    }

    // Mark as initialized
    is_initialized = 1;
}

void trixi_finalize() {
    // Prevent finalization without initialization and double finalization
    if (!is_initialized) {
        fprintf(stderr, "ERROR in %s:%d (%s): %s\n", __FILE__, __LINE__, __func__,
                "trixi_initialize must be called before trixi_finalize");
        exit(1);
    }
    if (is_finalized) {
        fprintf(stderr, "ERROR in %s:%d (%s): %s\n", __FILE__, __LINE__, __func__,
                "trixi_finalize invoked multiple times");
        exit(1);
    }

    shutdown_julia(0);

    // Mark as finalized
    is_finalized = 1;
}
