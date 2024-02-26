#include <stdio.h>
#include <stdlib.h>

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
    printf("\n*** Trixi controller ***   Initialize Trixi\n");
    trixi_initialize( argv[1], NULL );

    // Set up the Trixi simulation
    // We get a handle to use subsequently
    printf("\n*** Trixi controller ***   Set up Trixi simulation\n");
    int handle = trixi_initialize_simulation( argv[2] );

    // Get number of variables and elements
    int ndofs = trixi_ndofs( handle );

    // Allocate memory
    double * rho = calloc( sizeof(double), ndofs );
    double * source = calloc( sizeof(double), ndofs );

    // Main loop
    printf("\n*** Trixi controller ***   Entering main loop\n");
    while ( !trixi_is_finished( handle ) ) {

        // Get current solution at every DOF
        trixi_load_prim(rho, 1, handle);

        // Compute source term
        for ( int i = 0; i < ndofs; i++ ) {
            source[i] = rho[i];
        }

        // Store source terms
        trixi_store_in_database(source, ndofs, 1, handle);

        // Perform next step
        trixi_step( handle );
    }

    // Finalize Trixi simulation
    printf("\n*** Trixi controller ***   Finalize Trixi simulation\n");
    trixi_finalize_simulation( handle );

    // Finalize Trixi
    printf("\n*** Trixi controller ***   Finalize Trixi\n");
    trixi_finalize();

    free(rho);
    free(source);

    return 0;
}
