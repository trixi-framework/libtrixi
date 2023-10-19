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

    // Get number of variables
    int nvariables = trixi_nvariables( handle );
    printf("\n*** Trixi controller ***   nvariables %d\n", nvariables);

    // Main loop
    int steps = 0;
    int nelements = 0;
    double* data = NULL;

    printf("\n*** Trixi controller ***   Entering main loop\n");
    while ( !trixi_is_finished( handle ) ) {

        trixi_step( handle );
        steps++;

        if (steps % 10 == 0) {

            // Get number of elements
            nelements = trixi_nelements( handle );
            printf("\n*** Trixi controller ***   nelements %d\n", nelements);

            // Allocate memory
            data = realloc( data, sizeof(double) * nelements * nvariables );

            // Get averaged cell values for each variable
            trixi_load_cell_averages(data, handle);
        }
    }

    // Print first variable
    for (int i = 0; i < nelements; ++i) {
        printf("u[cell %3d] = %f\n", i, data[i]);
    }

    // Finalize Trixi simulation
    printf("\n*** Trixi controller ***   Finalize Trixi simulation\n");
    trixi_finalize_simulation( handle );

    // Finalize Trixi
    printf("\n*** Trixi controller ***   Finalize Trixi\n");
    trixi_finalize();

    free(data);

    return 0;
}
