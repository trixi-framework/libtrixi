#include <stdio.h>

#include <trixi.h>

int main ( int argc, char *argv[] ) {

    if ( argc < 2 ) {
        fprintf(stderr, "error: missing arguments: PROJECT_DIR LIBELIXIR_PATH\n\n");
        fprintf(stderr, "usage: %s PROJECT_DIR LIBELIXIR_PATH\n", argv[0]);
        return 2;
    } else if ( argc < 3 ) {
        fprintf(stderr, "error: missing argument: LIBELIXIR_PATH\n\n");
        fprintf(stderr, "usage: %s PROJECT_DIR LIBELIXIR_PATH\n", argv[0]);
        return 2;
    }

    // Initialize Trixi
    trixi_initialize( argv[1] );

    // Setup the Trixi simulation
    // We get a handle to use subsequently
    int handle = trixi_setup_simulation( argv[2] );

    // Get time step length
    printf("Current time step length: %f\n", trixi_calculate_dt(handle));

    // Main loop
    while ( trixi_is_finished( handle ) == 0 ) {

        trixi_step( handle );
    }

    // Finalize Trixi
    trixi_finalize( handle );


    return 0;
}
