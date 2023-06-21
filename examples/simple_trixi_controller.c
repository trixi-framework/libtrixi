#include <stdio.h>

#include <trixi.h>

int main ( int argc, char *argv[] ) {

    // Initialize Trixi
    trixi_initialize();

    // An "elixir" file is required to configure the Trixi simulation
    const char * elixir = "../../LibTrixi.jl/examples/libelixir_demo.jl";

    // Set up the Trixi simulation
    // We get a handle to use subsequently
    int handle = trixi_initialize_simulation( elixir );

    // Get time step length
    printf("Current time step length: %f\n", trixi_calculate_dt(handle));

    // Main loop
    while ( trixi_is_finished( handle ) == 0 ) {

        trixi_step( handle );
    }

    // Finalize Trixi simulation
    trixi_finalize_simulation( handle );

    // Finalize Trixi
    trixi_finalize();

    return 0;
}
