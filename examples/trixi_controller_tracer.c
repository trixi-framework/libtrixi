#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include <t8.h>
#include <t8_forest/t8_forest_general.h>
#include <t8_forest/t8_forest_geometrical.h>

#include <trixi.h>

void source_terms_tracer(int nnodes, t8_forest_t forest,
                         const double tau, const double dt,
                         const double * u_tracer, double * du_tracer) {

    // Get the number of trees that have elements
    t8_locidx_t num_local_trees = t8_forest_get_num_local_trees (forest);
    // Iterates through all local trees
    for (t8_locidx_t itree = 0, index = 0; itree < num_local_trees; ++itree) {
        // Get number of elements of this tree
        t8_locidx_t num_elements_in_tree = t8_forest_get_tree_num_elements (forest, itree);
        // Iterate through all the local elements
        for (t8_locidx_t ielement = 0; ielement < num_elements_in_tree; ++ielement) {
            // Get a pointer to the current element
            for (int k = 0; k < nnodes; ++k) {
                for (int j = 0; j < nnodes; ++j) {
                    for (int i = 0; i < nnodes; ++i, ++index) {
                        du_tracer[index] = u_tracer[index] * (exp(-dt / tau) - 1) / dt;
                    }
                }
            }
        }
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

    // Radon decay 222Rn -> 218Po
    const double half_life = 3.8 * 60 * 60 * 24;
    const double lambda = log(2) / half_life;
    const double tau = 1.0 / lambda;

    // Initialize Trixi
    printf("\n*** Trixi controller ***   Initialize Trixi\n");
    trixi_initialize( argv[1], NULL );

    // Set up the Trixi simulation
    // We get a handle to use subsequently
    printf("\n*** Trixi controller ***   Set up Trixi simulation\n");
    int handle = trixi_initialize_simulation( argv[2] );

    // Get number of degrees of freedom
    int ndofs = trixi_ndofs( handle );

    // Allocate memory for current state
    double * u_tracer = calloc( ndofs, sizeof(double) );

    // Allocate memory for source terms
    double * du_tracer = calloc( ndofs, sizeof(double) );

    // Store source term vectors in Trixi
    trixi_register_data( handle, 1, ndofs, du_tracer );

    // Get number of quadrature nodes
    const int nnodes = trixi_nnodes( handle );

    // Get t8code forest
    t8_forest_t forest = trixi_get_t8code_forest(handle);
    
    // Main loop
    printf("\n*** Trixi controller ***   Entering main loop\n");
    int step = 0;
    while ( !trixi_is_finished( handle ) ) {
        step++;

        const int new_ndofs = trixi_ndofs( handle );

        if (new_ndofs != ndofs)  {
            ndofs = new_ndofs;

            // Reallocate memory
            u_tracer = realloc( u_tracer, sizeof(double) * ndofs );
            du_tracer = realloc( du_tracer, sizeof(double) * ndofs );
            trixi_register_data( handle, 1, ndofs, du_tracer );
            forest = trixi_get_t8code_forest(handle);
        }

        // Get current state
        trixi_load_conservative_var( handle, 6, u_tracer );

        // Get current time step
        const double dt = trixi_calculate_dt( handle );

        // Compute source terms
        source_terms_tracer( nnodes, forest, tau, dt,
                             u_tracer, du_tracer );

        // Perform next step
        trixi_step( handle );
    }

    // Finalize Trixi simulation
    printf("\n*** Trixi controller ***   Finalize Trixi simulation\n");
    trixi_finalize_simulation( handle );

    // Finalize Trixi
    printf("\n*** Trixi controller ***   Finalize Trixi\n");
    trixi_finalize();

    free(u_tracer);
    free(du_tracer);

    return 0;
}
