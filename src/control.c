#include "trixi.h"
#include "function_pointers.h"


/**
 * @anchor trixi_initialize_simulation_api_c
 *
 * @brief Set up Trixi simulation
 *
 * Set up a Trixi simulation by reading the provided libelixir file. It resembles Trixi's
 * typical elixir files with the following differences:
 * - Everything (except `using ...`) has to be inside a `function init_simstate()`
 * - OrdinaryDiffEq's integrator has to be created by calling `init` (instead of `solve`)
 * - A `SimulationState` has to be created from the semidiscretization and the integrator
 * See the examples in the `LibTrixi.jl/examples` folder
 *
 * @param[in]  libelixir  Path to libelexir file.
 *
 * @return handle (integer) to Trixi simulation instance
 */
int trixi_initialize_simulation(const char * libelixir) {

    // Get function pointer
    int (*initialize_simulation)(const char *) = trixi_function_pointers[TRIXI_FTPR_INITIALIZE_SIMULATION];

    // Call function
    return initialize_simulation( libelixir );
}


/**
 * @anchor trixi_is_finished_api_c
 *
 * @brief Check if simulation is finished
 *
 * Checks if the simulation identified by handle has reached its final time.
 *
 * @param[in]  handle  simulation handle
 *
 * @return 1 if finished, 0 if not
 */
int trixi_is_finished(int handle) {

    // Get function pointer
    int (*is_finished)(int) = trixi_function_pointers[TRIXI_FTPR_IS_FINISHED];

    // Call function
    return is_finished( handle );
}


/**
 * @anchor trixi_step_api_c
 *
 * @brief Perform next simulation step
 *
 * Let the simulation identified by handle advance by one step.
 *
 * @param[in]  handle  simulation handle
 */
void trixi_step(int handle) {

    // Get function pointer
    int (*step)(int) = trixi_function_pointers[TRIXI_FTPR_STEP];

    // Call function
    step( handle );
}


/**
 * @anchor trixi_finalize_simulation_api_c
 *
 * @brief Finalize simulation
 *
 * Finalize the simulation identified by handle. This will also release the handle.
 *
 * @param[in]  handle  simulation handle
 */
void trixi_finalize_simulation(int handle) {

    // Get function pointer
    void (*finalize_simulation)(int) = trixi_function_pointers[TRIXI_FTPR_FINALIZE_SIMULATION];

    // Call function
    finalize_simulation(handle);
}

