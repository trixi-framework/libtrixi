#include <stdio.h>
#include <stdlib.h>
#include <julia_init.h>

// Track initialization/finalization status to prevent unhelpful errors
static int is_initialized = 0;
static int is_finalized = 0;

void trixi_initialize(const char * _unused1 /* project_directory */,
                      const char * _unused2 /* depot_path */) {
    // Prevent double initialization
    if (is_initialized) {
        fprintf(stderr, "ERROR in %s:%d (%s): %s\n", __FILE__, __LINE__, __func__,
                "trixi_initialize invoked multiple times");
        exit(1);
    }
    // Initialization after finalization is also erroneous, but finalization requires
    // initialization, so this is already caught above.

    // Init Julia (do not pass command line arguments)
    int argc = 0;
    char** argv = NULL;
    init_julia(argc, argv);

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

