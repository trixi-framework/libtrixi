#include "trixi.h"
#include "auxiliary.h"

/******************************************************************************************/
/* Function pointers                                                                      */
/******************************************************************************************/

// Enum to index function pointer array
enum {
    TRIXI_FTPR_INITIALIZE_SIMULATION,
    TRIXI_FTPR_CALCULATE_DT,
    TRIXI_FTPR_IS_FINISHED,
    TRIXI_FTPR_STEP,
    TRIXI_FTPR_FINALIZE_SIMULATION,
    TRIXI_FTPR_NDIMS,
    TRIXI_FTPR_NELEMENTS,
    TRIXI_FTPR_NVARIABLES,
    TRIXI_FTPR_LOAD_CELL_AVERAGES,
    TRIXI_FTPR_VERSION_LIBRARY,
    TRIXI_FTPR_VERSION_LIBRARY_MAJOR,
    TRIXI_FTPR_VERSION_LIBRARY_MINOR,
    TRIXI_FTPR_VERSION_LIBRARY_PATCH,
    TRIXI_FTPR_VERSION_JULIA,
    TRIXI_FTPR_VERSION_JULIA_EXTENDED,

    // The last one is for the array size
    TRIXI_NUM_FPTRS
};

// Function pointer array
static void* trixi_function_pointers[TRIXI_NUM_FPTRS];

// List of function names to obtain C function pointers from Julia
// OBS! If any name is longer than 250 characters, adjust buffer sizes in setup.c
static const char* trixi_function_pointer_names[] = {
    [TRIXI_FTPR_INITIALIZE_SIMULATION]  = "trixi_initialize_simulation_cfptr",
    [TRIXI_FTPR_CALCULATE_DT]           = "trixi_calculate_dt_cfptr",
    [TRIXI_FTPR_IS_FINISHED]            = "trixi_is_finished_cfptr",
    [TRIXI_FTPR_STEP]                   = "trixi_step_cfptr",
    [TRIXI_FTPR_FINALIZE_SIMULATION]    = "trixi_finalize_simulation_cfptr",
    [TRIXI_FTPR_NDIMS]                  = "trixi_ndims_cfptr",
    [TRIXI_FTPR_NELEMENTS]              = "trixi_nelements_cfptr",
    [TRIXI_FTPR_NVARIABLES]             = "trixi_nvariables_cfptr",
    [TRIXI_FTPR_LOAD_CELL_AVERAGES]     = "trixi_load_cell_averages_cfptr",
    [TRIXI_FTPR_VERSION_LIBRARY]        = "trixi_version_library_cfptr",
    [TRIXI_FTPR_VERSION_LIBRARY_MAJOR]  = "trixi_version_library_major_cfptr",
    [TRIXI_FTPR_VERSION_LIBRARY_MINOR]  = "trixi_version_library_minor_cfptr",
    [TRIXI_FTPR_VERSION_LIBRARY_PATCH]  = "trixi_version_library_patch_cfptr",
    [TRIXI_FTPR_VERSION_JULIA]          = "trixi_version_julia_cfptr",
    [TRIXI_FTPR_VERSION_JULIA_EXTENDED] = "trixi_version_julia_extended_cfptr"
};



/******************************************************************************************/
/* Setup                                                                                  */
/******************************************************************************************/

/**
 * @anchor trixi_initialize_api_c
 *
 * @brief Initialize Julia runtime environment
 * 
 * Initialize Julia and activate the project at `project_directory`. If `depot_path` is not
 * a null pointer, forcefully set the environment variable `JULIA_DEPOT_PATH` to the value
 * of `depot_path`. If `depot_path` *is* null, then proceed as follows:
 * If `JULIA_DEPOT_PATH` is already set, do not touch it. Otherwise, set `JULIA_DEPOT_PATH`
 * to `project_directory` + `default_depot_path`
 * 
 * @param[in]  project_directory  Path to project directory.
 * @param[in]  depot_path         Path to Julia depot path (optional; can be null pointer).
 */
void trixi_initialize(const char * project_directory, const char * depot_path) {
    // Update JULIA_DEPOT_PATH environment variable before initializing Julia
    update_depot_path(project_directory, depot_path);

    // Init Julia
    jl_init();

    // Construct activation command
    const char * activate = "using Pkg;\n"
                            "Pkg.activate(\"%s\"; io=devnull);\n";
    if ( strlen(activate) + strlen(project_directory) + 1 > 1024 ) {
        print_and_die("buffer size not sufficient for activation command", LOC);
    }
    char buffer[1024];
    snprintf(buffer, 1024, activate, project_directory);

    // Activate julia environment
    checked_eval_string(buffer, LOC);

    // Load LibTrixi module
    checked_eval_string("using LibTrixi;", LOC);
    if (show_debug_output()) {
        checked_eval_string("println(\"Module LibTrixi.jl loaded\")", LOC);
    }

    // Store function pointers to avoid overhead of `jl_eval_string`
    store_function_pointers(TRIXI_NUM_FPTRS, trixi_function_pointer_names,
                            trixi_function_pointers);

    // Show version info
    if (show_debug_output()) {
        printf("\nlibtrixi %s\n\n", trixi_version_library());
        printf("Loaded Julia packages:\n%s\n\n", trixi_version_julia());
    }
}


/**
 * @anchor trixi_finalize_api_c
 *
 * @brief Finalize Julia runtime environment
 */
void trixi_finalize() {

    if (show_debug_output()) {
        printf("libtrixi: finalize\n");
    }

    // Reset function pointers
    for (int i = 0; i < TRIXI_NUM_FPTRS; i++) {
        trixi_function_pointers[i] = NULL;
    }

    jl_atexit_hook(0);
}



/******************************************************************************************/
/* Version information                                                                    */
/******************************************************************************************/

/**
 * @anchor trixi_version_library_major_api_c
 *
 * @brief Return major version number of libtrixi.
 *
 * This function may be run before `trixi_initialize` has been called.
 *
 * @return Major version of libtrixi.
 */
int trixi_version_library_major() {

    // Get function pointer
    int (*version_library_major)() =
        trixi_function_pointers[TRIXI_FTPR_VERSION_LIBRARY_MAJOR];

    // Call function
    return version_library_major();
}


/**
 * @anchor trixi_version_library_minor_api_c
 *
 * @brief Return minor version number of libtrixi.
 *
 * This function may be run before `trixi_initialize` has been called.
 *
 * @return Minor version of libtrixi.
 */
int trixi_version_library_minor() {

    // Get function pointer
    int (*version_library_minor)() =
        trixi_function_pointers[TRIXI_FTPR_VERSION_LIBRARY_MINOR];

    // Call function
    return version_library_minor();
}


/**
 * @anchor trixi_version_library_patch_api_c
 *
 * @brief Return patch version number of libtrixi.
 *
 * This function may be run before `trixi_initialize` has been called.
 *
 * @return Patch version of libtrixi.
 */
int trixi_version_library_patch() {

    // Get function pointer
    int (*version_library_patch)() =
        trixi_function_pointers[TRIXI_FTPR_VERSION_LIBRARY_PATCH];

    // Call function
    return version_library_patch();
}


/**
 * @anchor trixi_version_library_api_c
 *
 * @brief Return full version string of libtrixi.
 *
 * The return value is a read-only pointer to a NULL-terminated string with the version
 * information. This may include not just MAJOR.MINOR.PATCH but possibly also additional
 * build or development version information.
 *
 * The returned pointer is to static memory and must not be used to change the contents of
 * the version string. Multiple calls to the function will return the same address.
 *
 * This function is thread-safe and may be run before `trixi_initialize` has been called.
 *
 * @return Pointer to a read-only, NULL-terminated character array with the full version of
 *         libtrixi.
 */
const char* trixi_version_library() {

    // Get function pointer
    const char* (*version_library)() = trixi_function_pointers[TRIXI_FTPR_VERSION_LIBRARY];

    // Call function
    return version_library();
}


/**
 * @anchor trixi_version_julia_api_c
 *
 * @brief Return name and version of loaded julia packages LibTrixi directly depends on.
 *
 * The return value is a read-only pointer to a NULL-terminated string with the name and
 * version information of the loaded julia packages, separated by newlines.
 *
 * The returned pointer is to static memory and must not be used to change the contents of
 * the version string. Multiple calls to the function will return the same address.
 *
 * This function is thread-safe. It must be run after `trixi_initialize` has been called.
 *
 * @return Pointer to a read-only, NULL-terminated character array with the names and
 *         versions of loaded Julia packages.
 */
const char* trixi_version_julia() {

    // Get function pointer
    const char* (*version_julia)() = trixi_function_pointers[TRIXI_FTPR_VERSION_JULIA];

    // Call function
    return version_julia();
}


/**
 * @anchor trixi_version_julia_extended_api_c
 *
 * @brief Return name and version of all loaded julia packages.
 *
 * The return value is a read-only pointer to a NULL-terminated string with the name and
 * version information of all loaded julia packages, including implicit dependencies,
 * separated by newlines.
 *
 * The returned pointer is to static memory and must not be used to change the contents of
 * the version string. Multiple calls to the function will return the same address.
 *
 * This function is thread-safe. It must be run after `trixi_initialize` has been called.
 *
 * @return Pointer to a read-only, NULL-terminated character array with the names and
 *         versions of all loaded julia packages.
 */
const char* trixi_version_julia_extended() {

    // Get function pointer
    const char* (*version_julia_extended)() =
        trixi_function_pointers[TRIXI_FTPR_VERSION_JULIA_EXTENDED];

    // Call function
    return version_julia_extended();
}



/******************************************************************************************/
/* Simulation control                                                                     */
/******************************************************************************************/

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
    int (*initialize_simulation)(const char *) =
        trixi_function_pointers[TRIXI_FTPR_INITIALIZE_SIMULATION];

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
    void (*finalize_simulation)(int) =
        trixi_function_pointers[TRIXI_FTPR_FINALIZE_SIMULATION];

    // Call function
    finalize_simulation(handle);
}



/******************************************************************************************/
/* Simulation data                                                                        */
/******************************************************************************************/

/**
 * @anchor trixi_calculate_dt_api_c
 *
 * @brief Get time step length
 *
 * Get the current time step length of the simulation identified by handle.
 *
 * @param[in]  handle  simulation handle
 *
 * @return Time step length
 */
double trixi_calculate_dt(int handle) {

    // Get function pointer
    double (*calculate_dt)(int) = trixi_function_pointers[TRIXI_FTPR_CALCULATE_DT];;

    // Call function
    return calculate_dt( handle );
}


/**
 * @anchor trixi_ndims_api_c
 *
 * @brief Return number of spatial dimensions
 *
 * @param[in]  handle  simulation handle
 */
int trixi_ndims(int handle) {

    // Get function pointer
    int (*ndims)(int) = trixi_function_pointers[TRIXI_FTPR_NDIMS];

    // Call function
    return ndims(handle);
}


/**
 * @anchor trixi_nelements_api_c
 *
 * @brief Return number of elements (cells)
 *
 * @param[in]  handle  simulation handle
 */
int trixi_nelements(int handle) {

    // Get function pointer
    int (*nelements)(int) = trixi_function_pointers[TRIXI_FTPR_NELEMENTS];

    // Call function
    return nelements(handle);
}


/**
 * @anchor trixi_nvariables_api_c
 *
 * @brief Return number of (conservative) variables
 *
 * @param[in]  handle  simulation handle
 */
int trixi_nvariables(int handle) {

    // Get function pointer
    int (*nvariables)(int) = trixi_function_pointers[TRIXI_FTPR_NVARIABLES];

    // Call function
    return nvariables(handle);
}


/** 
 * @anchor trixi_load_cell_averages_api_c
 *
 * @brief Return cell averaged values
 *
 * Cell averaged values for each cell and each primitive variable are stored in a
 * contiguous array, where cell values for the first variable appear first and values for
 * the other variables subsequently (structure-of-arrays layout).
 *
 * The given array has to be of correct size and memory has to be allocated beforehand.
 *
 * @param[in]  handle  simulation handle
 * @param[out] data    cell averaged values for all cells and all primitive variables
 */
void trixi_load_cell_averages(double * data, int handle) {

    // Get function pointer
    void (*load_cell_averages)(double *, int) =
        trixi_function_pointers[TRIXI_FTPR_LOAD_CELL_AVERAGES];

    // Call function
    load_cell_averages(data, handle);
}



/******************************************************************************************/
/* Misc                                                                                   */
/******************************************************************************************/

/**
 * @anchor trixi_eval_julia_api_c
 *
 * @brief Execute Julia code
 *
 * Execute the provided code in the current Julia runtime environment.
 *
 * @warning Only for development. Code is not checked prior to execution.
 */
void trixi_eval_julia(const char * code) {

    checked_eval_string(code, LOC);
}
