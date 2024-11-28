#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include <t8.h>
#include <t8_forest/t8_forest_general.h>
#include <t8_forest/t8_forest_geometrical.h>

#include <trixi.h>

void source_terms_baroclinic(int nnodes, double * nodes, t8_forest_t forest,
                             const double * u1, const double * u2, const double * u3,
                             const double * u4,
                             double * du2, double * du3, double * du4, double * du5) {

    const double radius_earth = 6.371229e6;
    const double gravitational_acceleration = 9.80616;
    const double angular_velocity = 7.29212e-5;
    const double g_r2 = -gravitational_acceleration * radius_earth * radius_earth;

    double local_coords[3];
    double global_coords[3];

    // Get the number of trees that have elements
    t8_locidx_t num_local_trees = t8_forest_get_num_local_trees (forest);
    // Iterates through all local trees
    for (t8_locidx_t itree = 0, index = 0; itree < num_local_trees; ++itree) {
        // Get number of elements of this tree
        t8_locidx_t num_elements_in_tree = t8_forest_get_tree_num_elements (forest, itree);
        // Iterate through all the local elements
        for (t8_locidx_t ielement = 0; ielement < num_elements_in_tree; ++ielement) {
            // Get a pointer to the current element
            const t8_element_t *element = t8_forest_get_element_in_tree (forest, itree, ielement);
            for (int k = 0; k < nnodes; ++k) {
                for (int j = 0; j < nnodes; ++j) {
                    for (int i = 0; i < nnodes; ++i, ++index) {
                        // Get global coordinates of local quad point
                        local_coords[0] = nodes[i];
                        local_coords[1] = nodes[j];
                        local_coords[2] = nodes[k];
                        t8_forest_element_from_ref_coords(forest, itree, element, local_coords, 1, global_coords);

                        // The actual computation of source terms
                        const double ele = sqrt( global_coords[0]*global_coords[0] +
                                                 global_coords[1]*global_coords[1] +
                                                 global_coords[2]*global_coords[2] );

                        const double ele_corrected = fmax( ele - radius_earth, 0.0) + radius_earth;
                        // Gravity term
                        const double temp = g_r2 / (ele_corrected*ele_corrected*ele_corrected);
                        du2[index] = temp * u1[index] * global_coords[0];
                        du3[index] = temp * u1[index] * global_coords[1];
                        du4[index] = temp * u1[index] * global_coords[2];
                        du5[index] = temp * u1[index] * (u2[index] * global_coords[0] +
                                                         u3[index] * global_coords[1] +
                                                         u4[index] * global_coords[2]);
                        // Coriolis term
                        du2[index] += 2.0 * angular_velocity * u3[index] * u1[index];
                        du3[index] -= 2.0 * angular_velocity * u2[index] * u1[index];
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
    double * u1 = calloc( ndofs, sizeof(double) );
    double * u2 = calloc( ndofs, sizeof(double) );
    double * u3 = calloc( ndofs, sizeof(double) );
    double * u4 = calloc( ndofs, sizeof(double) );

    // Allocate memory for source terms
    double * du2 = calloc( ndofs, sizeof(double) );
    double * du3 = calloc( ndofs, sizeof(double) );
    double * du4 = calloc( ndofs, sizeof(double) );
    double * du5 = calloc( ndofs, sizeof(double) );

    // Store source term vectors in Trixi
    trixi_register_data( handle, 1, ndofs, du2 );
    trixi_register_data( handle, 2, ndofs, du3 );
    trixi_register_data( handle, 3, ndofs, du4 );
    trixi_register_data( handle, 4, ndofs, du5 );

    // Get number of quadrature nodes
    int nnodes = trixi_nnodes( handle );

    // Allocate memory for quadrature node coordinates
    double * nodes = calloc( nnodes, sizeof(double) );

    // Get quadrature node coordinates
    trixi_load_node_reference_coordinates( handle, nodes );

    // Transform coordinates from [-1,1] to [0,1]
    for (int i = 0; i < nnodes; ++i) {
        nodes[i] = 0.5 * (nodes[i] + 1.0);
    }

    // Get t8code forest
    t8_forest_t forest = trixi_get_t8code_forest(handle);
    
    // Main loop
    printf("\n*** Trixi controller ***   Entering main loop\n");
    while ( !trixi_is_finished( handle ) ) {

        // Get current state
        trixi_load_primitive_vars( handle, 1, u1 );
        trixi_load_primitive_vars( handle, 2, u2 );
        trixi_load_primitive_vars( handle, 3, u3 );
        trixi_load_primitive_vars( handle, 4, u4 );

        // Compute source terms
        source_terms_baroclinic( nnodes, nodes, forest,
                                 u1, u2, u3, u4, du2, du3, du4, du5 );

        // Perform next step
        trixi_step( handle );
    }

    // Finalize Trixi simulation
    printf("\n*** Trixi controller ***   Finalize Trixi simulation\n");
    trixi_finalize_simulation( handle );

    // Finalize Trixi
    printf("\n*** Trixi controller ***   Finalize Trixi\n");
    trixi_finalize();

    free(u1);
    free(u2);
    free(u3);
    free(u4);
    free(du2);
    free(du3);
    free(du4);
    free(du5);
    free(nodes);

    return 0;
}
