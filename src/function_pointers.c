#include "function_pointers.h"

void* trixi_function_pointers[TRIXI_NUM_FPTRS];

const char* trixi_function_pointer_names[] = {
    [TRIXI_FTPR_INITIALIZE_SIMULATION]  = "trixi_initialize_simulation_cfptr",
    [TRIXI_FTPR_CALCULATE_DT]           = "trixi_calculate_dt_cfptr",
    [TRIXI_FTPR_IS_FINISHED]            = "trixi_is_finished_cfptr",
    [TRIXI_FTPR_STEP]                   = "trixi_step_cfptr",
    [TRIXI_FTPR_FINALIZE_SIMULATION]    = "trixi_finalize_simulation_cfptr",
    [TRIXI_FTPR_NDIMS]                  = "trixi_ndims_cfptr",
    [TRIXI_FTPR_NELEMENTS]              = "trixi_nelements_cfptr",
    [TRIXI_FTPR_NVARIABLES]             = "trixi_nvariables_cfptr",
    [TRIXI_FTPR_LOAD_CELL_AVERAGES]     = "trixi_load_cell_averages_cfptr",
    [TRIXI_FTPR_VERSION]                = "trixi_version_cfptr",
    [TRIXI_FTPR_VERSION_MAJOR]          = "trixi_version_major_cfptr",
    [TRIXI_FTPR_VERSION_MINOR]          = "trixi_version_minor_cfptr",
    [TRIXI_FTPR_VERSION_PATCH]          = "trixi_version_patch_cfptr",
    [TRIXI_FTPR_VERSION_JULIA]          = "trixi_version_julia_cfptr",
    [TRIXI_FTPR_VERSION_JULIA_EXTENDED] = "trixi_version_julia_extended_cfptr"
};
