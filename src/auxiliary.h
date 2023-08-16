#ifndef AUXILIARY_H_
#define AUXILIARY_H_

#include <julia.h>

// Function for more helpful error messages
void print_and_die(const char* message, const char* func, const char* file, int lineno);
#define LOC __func__, __FILE__, __LINE__

// Function to determine debug level
int show_debug_output();

// Function to evaluate julia REPL string with exception handling
jl_value_t* checked_eval_string(const char* code, const char* func, const char* file,
                                int lineno);

// Execute the provided code in the current Julia runtime environment
void julia_eval_string(const char * code);

#endif // ifndef AUXILIARY_H_
