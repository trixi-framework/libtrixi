#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include <trixi.h>

void source_term_wave(int ndofs, const double * x, const double t,
                      double * du1, double * du2, double * du4) {

    const double c = 2.0;
    const double A = 0.1;
    const double L = 2.0;
    const double f = 1.0 / L;
    const double omega = 2 * M_PI * f;
    const double gamma = 1.4;

    for (int i = 0; i < ndofs; ++i) {

        const double si = sin(omega * (x[i] + x[i+ndofs] - t));
        const double co = cos(omega * (x[i] + x[i+ndofs] - t));
        const double rho = c + A * si;
        const double rho_x = omega * A * co;
        const double tmp = (2 * rho - 1) * (gamma - 1);

        du1[i] = rho_x;
        du2[i] = rho_x * (1 + tmp);
        du4[i] = 2 * rho_x * (rho + tmp);
    }
}

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

    // Allocate memory for source terms
    double * du1 = calloc( sizeof(double), ndofs );
    double * du2 = calloc( sizeof(double), ndofs );
    double * du4 = calloc( sizeof(double), ndofs );

    // Store source term vectors in Trixi
    trixi_store_in_database(du1, ndofs, 1, handle);
    trixi_store_in_database(du2, ndofs, 2, handle);
    trixi_store_in_database(du4, ndofs, 3, handle);

    // Get node coordinates
    double * x = calloc( sizeof(double), 2*ndofs );
    trixi_load_node_coordinates( handle, x );

    // Main loop
    printf("\n*** Trixi controller ***   Entering main loop\n");
    double t = 0.0;
    while ( !trixi_is_finished( handle ) ) {

        // Get current time
        t = trixi_get_time( handle );

        // Compute source terms
        source_term_wave(ndofs, x, t, du1, du2, du4);

        // Perform next step
        trixi_step( handle );
    }

    // Finalize Trixi simulation
    printf("\n*** Trixi controller ***   Finalize Trixi simulation\n");
    trixi_finalize_simulation( handle );

    // Finalize Trixi
    printf("\n*** Trixi controller ***   Finalize Trixi\n");
    trixi_finalize();

    free(x);
    free(du1);
    free(du2);
    free(du4);

    return 0;
}
