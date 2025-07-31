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
    int steps = 0;

    printf("\n*** Trixi controller ***   Entering main loop\n");
    while ( !trixi_is_finished( handle ) ) {

        trixi_step( handle );
        steps++;

        if (steps % 100 == 0) {

            // Get number of degrees of freedom
            int ndofs = trixi_ndofsglobal( handle );

            // Get a pointer to Trixi's internal simulation data
            double * raw_data = trixi_get_data_pointer(handle);

            for (int i = 0; i < ndofs; ++i) {
                // Density comes first
                const double rho = raw_data[i];

                // Tracer comes last
                const double rho_tracer = raw_data[4*ndofs + i];

                // Apply 20% damping to tracer (fraction of density)
                const double tracer = 0.8 * (rho_tracer / rho);
                raw_data[4*ndofs + i] = tracer * rho;
            }
        }
    }

    // Finalize Trixi simulation
    printf("\n*** Trixi controller ***   Finalize Trixi simulation\n");
    trixi_finalize_simulation( handle );

    // Finalize Trixi
    printf("\n*** Trixi controller ***   Finalize Trixi\n");
    trixi_finalize();

    return 0;
}
