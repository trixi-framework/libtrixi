#ifndef AUXILIARY_H_
#define AUXILIARY_H_

#include <julia.h>

// Helper function to set JULIA_DEPOT_PATH environment variable
void update_depot_path(const char * project_directory, const char * depot_path);

// Function for more helpful error messages
#define LOC __func__, __FILE__, __LINE__
void print_and_die(const char* message, const char* func, const char* file, int lineno);

// Function to determine debug level
int show_debug_output();

// Function to evaluate Julia REPL string with exception handling
jl_value_t* checked_eval_string(const char* code, const char* func, const char* file,
                                int lineno);

// Function to get and store function pointers from Julia to C functions
void store_function_pointers(int num_fptrs, const char * fptr_names[], void * fptrs[]);

#endif // AUXILIARY_H_
