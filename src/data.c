#include "trixi.h"
#include "function_pointers.h"


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
    void (*load_cell_averages)(double *, int) = trixi_function_pointers[TRIXI_FTPR_LOAD_CELL_AVERAGES];

    // Call function
    load_cell_averages(data, handle);
}
