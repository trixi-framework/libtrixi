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
    double* rho = NULL;
    double* rho_tracer = NULL;

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
                const double rho = raw_data[5*i];

                // Tracer comes last
                const double rho_tracer = raw_data[5*i + 4];

                // Apply 10% damping to tracer (fraction of density)
                const double tracer = 0.9 * (rho_tracer / rho);
                raw_data[5*i + 4] = tracer * rho;
            }
        }

        if (steps % 100 == 50) {

            // Get number of degrees of freedom
            int ndofs = trixi_ndofsglobal( handle );

            // Allocate memory
            rho = realloc( rho, sizeof(double) * ndofs );
            rho_tracer = realloc( rho_tracer, sizeof(double) * ndofs );

            // Get density and tracer
            trixi_load_conservative_vars(handle, 1, rho);
            trixi_load_conservative_vars(handle, 5, rho_tracer);

            for (int i = 0; i < ndofs; ++i) {
                // Apply 5% amplification to tracer (fraction of density)
                const double tracer = 1.05 * (rho_tracer[i] / rho[i]);
                rho_tracer[i] = tracer * rho[i];
            }

            // Write back tracer
            trixi_store_conservative_vars(handle, 5, rho_tracer);
        }
    }

    // Finalize Trixi simulation
    printf("\n*** Trixi controller ***   Finalize Trixi simulation\n");
    trixi_finalize_simulation( handle );

    // Finalize Trixi
    printf("\n*** Trixi controller ***   Finalize Trixi\n");
    trixi_finalize();

    free(rho);
    free(rho_tracer);

    return 0;
}
