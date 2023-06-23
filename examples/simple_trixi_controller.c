#include <stdio.h>

#include <trixi.h>

int main ( int argc, char *argv[] ) {

    if ( argc < 2 ) {
        fprintf(stderr, "ERROR: missing arguments: PROJECT_DIR LIBELIXIR_PATH\n\n");
        fprintf(stderr, "usage: %s PROJECT_DIR LIBELIXIR_PATH\n", argv[0]);
        return 2;
    } else if ( argc < 3 ) {
        fprintf(stderr, "ERROR: missing argument: LIBELIXIR_PATH\n\n");
        fprintf(stderr, "usage: %s PROJECT_DIR LIBELIXIR_PATH\n", argv[0]);
        return 2;
    }

    // Initialize Trixi
    trixi_initialize( argv[1] );

    // Set up the Trixi simulation
    // We get a handle to use subsequently
    int handle = trixi_initialize_simulation( argv[2] );

    // Get time step length
    printf("Current time step length: %f\n", trixi_calculate_dt(handle));

    // Main loop
    while ( !trixi_is_finished( handle ) ) {

        trixi_step( handle );
    }

    // Finalize Trixi simulation
    trixi_finalize_simulation( handle );

    // Finalize Trixi
    trixi_finalize();

    return 0;
}
