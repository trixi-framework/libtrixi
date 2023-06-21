#include <stdio.h>
#include <julia.h>
#include <mpi.h>

#include "trixi.h"



#define LOC __func__, __FILE__, __LINE__

// Auxiliary function to evaluate julia REPL string with exception handling
static jl_value_t* checked_eval_string(const char* code, const char* func, const char* file, int lineno);



/** Initialize Julia runtime environment
 *
 *  \todo Path is still hard-coded
 */
void trixi_initialize() {

    // Init Julia
    jl_init();

    // Activate julia environment
    checked_eval_string("using Pkg; Pkg.activate(\"../../LibTrixi.jl\"); Pkg.status()", LOC);

    // Load LibTrixi module
    checked_eval_string("using LibTrixi;", LOC);
    checked_eval_string("println(\"Module LibTrixi.jl loaded\")", LOC);
}


/** Setup Trixi simulation
 *
 *  \param[in]  elixir  path to file containing Trixi setup
 *
 *  \return handle (integer) to Trixi simulation instance
 */
int trixi_setup_simulation(const char * elixir) {

    // Get function pointer
    int (*trixi_setup_simulation_c)(const char *) = jl_unbox_voidpointer( checked_eval_string("trixi_setup_simulation_cfptr()", LOC) ) ;

    // Call function
    return trixi_setup_simulation_c( elixir );
}


/** Get time step length of Trixi simulation
 *
 *  \param[in] handle simulation handle to release
 *
 *  \return Time step length
 */
double trixi_calculate_dt(int handle) {

    // Get function pointer
    double (*trixi_calculate_dt_c)(int) = jl_unbox_voidpointer( checked_eval_string("trixi_calculate_dt_cfptr()", LOC) ) ;

    // Call function
    return trixi_calculate_dt_c( handle );
}


/** Check if Trixi simulation is finished
 *
 *  \param[in] handle simulation handle
 *
 *  \return 1 if finished, 0 if not
 */
int trixi_is_finished(int handle) {

    // Get function pointer
    int (*trixi_is_finished_c)(int) = jl_unbox_voidpointer( checked_eval_string("trixi_is_finished_cfptr()", LOC) ) ;

    // Call function
    return trixi_is_finished_c( handle );
}


/** Perform one step in Trixi simulation
 *
 *  \param[in] handle simulation handle
 */
void trixi_step(int handle) {

    // Get function pointer
    int (*trixi_step_c)(int) = jl_unbox_voidpointer( checked_eval_string("trixi_step_cfptr()", LOC) ) ;

    // Call function
    trixi_step_c( handle );
}


/** Finalize Trixi simulation
 *
 *  \param[in] handle simulation handle to release
 */
void trixi_finalize(int handle) {

    // Get function pointer
    void (*trixi_finalize_c)(int) = jl_unbox_voidpointer( checked_eval_string("trixi_finalize_cfptr()", LOC) ) ;

    // Call function
    trixi_finalize_c(handle);

    printf("libtrixi: finalize\n");

    jl_atexit_hook(0);
}



void julia_eval_string(const char * code) {

    checked_eval_string(code, LOC);
};


/*  Run Julia command and check for errors
 *
 *  Adapted from the Julia repository.
 *  Source: https://github.com/JuliaLang/julia/blob/c0dd6ff8363f948237304821941b06d67014fa6a/test/embedding/embedding.c#L17-L31
 */
jl_value_t* checked_eval_string(const char* code, const char* func, const char* file, int lineno) {

    jl_value_t *result = jl_eval_string(code);

    if (jl_exception_occurred()) {

        // none of these allocate, so a gc-root (JL_GC_PUSH) is not necessary
        jl_printf(jl_stderr_stream(), "ERROR in %s:%d (%s):\n", file, lineno, func);
        jl_printf(jl_stderr_stream(), "The following Julia code could not be evaluated: %s\n", code);
        jl_call2(jl_get_function(jl_base_module, "showerror"), jl_stderr_obj(), jl_exception_occurred());
        jl_printf(jl_stderr_stream(), "\n");
        jl_atexit_hook(1);
        exit(1);
    }

    assert(result && "Missing return value but no exception occurred!");

    return result;
}
