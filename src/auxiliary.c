#include "auxiliary.h"
#include "trixi.h"


// Run Julia command and check for errors
// Source: https://github.com/JuliaLang/julia/blob/c0dd6ff8363f948237304821941b06d67014fa6a/test/embedding/embedding.c#L17-L31
jl_value_t* checked_eval_string(const char* code, const char* func, const char* file, int lineno) {

    jl_value_t *result = jl_eval_string(code);

    if (jl_exception_occurred()) {

        // none of these allocate, so a gc-root (JL_GC_PUSH) is not necessary
        jl_printf(jl_stderr_stream(), "ERROR in %s:%d (%s):\n", file, lineno, func);
        jl_printf(jl_stderr_stream(),
                  "The following Julia code could not be evaluated: %s\n", code);
        jl_call2(jl_get_function(jl_base_module, "showerror"), jl_stderr_obj(),
                 jl_exception_occurred());
        jl_printf(jl_stderr_stream(), "\n");
        jl_atexit_hook(1);
        exit(1);
    }

    assert(result && "Missing return value but no exception occurred!");

    return result;
}


void print_and_die(const char* message, const char* func, const char* file, int lineno) {
    fprintf(stderr, "ERROR in %s:%d (%s): %s\n", file, lineno, func, message);
    exit(1);
}


int show_debug_output() {
    const char * env = getenv("LIBTRIXI_DEBUG");
    if (env == NULL) {
        return 0;
    }

    if (strcmp(env, "all") == 0 || strcmp(env, "c") == 0) {
        return 1;
    } else {
        return 0;
    }
}


/**
 * @anchor julia_eval_string_api_c
 *
 * @brief Execute Julia code
 *
 * Execute the provided code in the current Julia runtime environment.
 *
 * @warning Only for development. Code is not checked prior to execution.
 */
void julia_eval_string(const char * code) {

    checked_eval_string(code, LOC);
}
