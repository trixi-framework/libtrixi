#include <stdio.h>
#include <julia.h>
#include <mpi.h>

#include "libtrixi.h"



#define LOC __func__, __FILE__, __LINE__

// Auxiliary function to evaluate julia REPL string with exception handling
static jl_value_t* checked_eval_string(const char* code, const char* func, const char* file, int lineno);



void trixi_initialize(MPI_Fint* comm) {

    // Init Julia
    jl_init();

    // Activate current project
    checked_eval_string("using Pkg; Pkg.activate(\".\"); Pkg.status()", LOC);

    // Test Julia
    checked_eval_string("println(\"Hi, I'm julia!\")", LOC);

    // Load Trixi
    checked_eval_string("using Trixi; trixi_include(default_example())", LOC);
}


void trixi_finalize() {

    jl_atexit_hook(0);
}


double trixi_get_timestep() {

    return 1.0;
}


void trixi_integrate() {

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
