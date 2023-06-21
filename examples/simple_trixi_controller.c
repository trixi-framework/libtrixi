#include <stdio.h>

#include <trixi.h>

int main ( int argc, char *argv[] ) {

    // Initialize Trixi
    trixi_initialize();

    // An "elixir" file is required to configure the Trixi simulation
    const char * elixir = "../../LibTrixi.jl/examples/libelixir_demo.jl";

    // Setup the Trixi simulation
    // We get a handle to use subsequently
    int handle = trixi_setup_simulation( elixir );

    // Get time step length
    printf("Current time step length: %f\n", trixi_calculate_dt(handle));

    // Main loop
    while ( !trixi_is_finished( handle ) ) {

        trixi_step( handle );
    }

    // Finalize Trixi
    trixi_finalize( handle );


    return 0;
}
