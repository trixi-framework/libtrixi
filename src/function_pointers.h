#ifndef FUNCTION_POINTERS_H_
#define FUNCTION_POINTERS_H_

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
    TRIXI_FTPR_VERSION,
    TRIXI_FTPR_VERSION_MAJOR,
    TRIXI_FTPR_VERSION_MINOR,
    TRIXI_FTPR_VERSION_PATCH,
    TRIXI_FTPR_VERSION_JULIA,
    TRIXI_FTPR_VERSION_JULIA_EXTENDED,

    // The last one is for the array size
    TRIXI_NUM_FPTRS
};

// Function pointer array
extern void* trixi_function_pointers[TRIXI_NUM_FPTRS];

// List of function names to obtain C function pointers from Julia
// OBS! If any name is longer than 250 characters, adjust buffer sizes in setup.c
extern const char* trixi_function_pointer_names[TRIXI_NUM_FPTRS];

#endif // ifndef FUNCTION_POINTERS_H_
