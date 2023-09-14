#include <stdio.h>

#include <t8.h>
#include <t8_forest/t8_forest_general.h>

#include <trixi.h>


/* Print the local and global number of elements of a forest. */
void t8_print_forest_information (t8_forest_t forest)
{
    t8_locidx_t         local_num_elements;
    t8_gloidx_t         global_num_elements;

    // Check that forest is a committed, that is valid and usable, forest.
    T8_ASSERT (t8_forest_is_committed (forest));

    // Get the local number of elements.
    local_num_elements = t8_forest_get_local_num_elements (forest);

    // Get the global number of elements.
    global_num_elements = t8_forest_get_global_num_elements (forest);

    printf ("\n*** T8code ***  Local number of elements:\t%i\n", local_num_elements);
    printf ("*** T8code ***  Global number of elements:\t%li\n", global_num_elements);
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
    trixi_initialize(argv[1], NULL);

    // Set up the Trixi simulation
    // We get a handle to use subsequently
    printf("\n*** Trixi controller ***   Set up Trixi simulation\n");
    int handle = trixi_initialize_simulation(argv[2]);

    // Main loop
    printf("\n*** Trixi controller ***   Entering main loop\n");
    while ( !trixi_is_finished(handle) ) {

        trixi_step(handle);
    }

    // get number of elements
    int nelements = trixi_nelements(handle);
    printf("\n*** Trixi controller ***   nelements %d\n", nelements);


    // get t8code forest
    t8_forest_t forest = trixi_get_t8code_forest(handle);
    t8_print_forest_information (forest);


    // Finalize Trixi simulation
    printf("\n*** Trixi controller ***   Finalize Trixi simulation\n");
    trixi_finalize_simulation(handle);

    // Finalize Trixi
    printf("\n*** Trixi controller ***   Finalize Trixi\n");
    trixi_finalize();

    return 0;
}
