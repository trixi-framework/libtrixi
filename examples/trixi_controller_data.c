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

    // Main loop
    printf("\n*** Trixi controller ***   Entering main loop\n");
    while ( !trixi_is_finished( handle ) ) {

        trixi_step( handle );
    }

    // get number of elements
    int nelements = trixi_nelements( handle );
    printf("\n*** Trixi controller ***   nelements %d\n", nelements);

    // get number of variables
    int nvariables = trixi_nvariables( handle );
    printf("\n*** Trixi controller ***   nvariables %d\n", nvariables);

    // allocate memory
    double* data = malloc( sizeof(double) * nelements * nvariables );

    // get averaged cell values for each variable
    trixi_get_cell_averages(data, handle);

    // compute temperature
    const double gas_constant = 0.287;

    for (int i = 0; i < nelements; ++i) {

        printf("T[cell %3d] = %f\n", i, data[i+3*nelements] / (gas_constant * data[i]) );
    }

    // Finalize Trixi simulation
    printf("\n*** Trixi controller ***   Finalize Trixi simulation\n");
    trixi_finalize_simulation( handle );

    // Finalize Trixi
    printf("\n*** Trixi controller ***   Finalize Trixi\n");
    trixi_finalize();

    return 0;
}
