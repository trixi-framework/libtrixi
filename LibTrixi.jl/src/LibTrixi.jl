module LibTrixi

using OrdinaryDiffEq: OrdinaryDiffEq, step!, check_error, DiscreteCallback
using Trixi: Trixi, summary_callback

export trixi_initialize_simulation,
       trixi_initialize_simulation_cfptr,
       trixi_initialize_simulation_jl
export trixi_finalize_simulation,
       trixi_finalize_simulation_cfptr,
       trixi_finalize_simulation_jl
export trixi_calculate_dt,
       trixi_calculate_dt_cfptr,
       trixi_calculate_dt_jl
export trixi_is_finished,
       trixi_is_finished_cfptr,
       trixi_is_finished_jl
export trixi_step,
       trixi_step_cfptr,
       trixi_step_jl
export trixi_get_t8code_mesh_cfptr
export trixi_ndims_cfptr
export trixi_nelements_cfptr
export trixi_nvariables_cfptr
export trixi_get_cell_averages_cfptr

export SimulationState, store_simstate, load_simstate, delete_simstate!

include("simulationstate.jl")
include("api_c.jl")
include("api_jl.jl")

# Show debug output depending on environment variable
function show_debug_output()
    if !haskey(ENV, "LIBTRIXI_DEBUG")
        return false
    end

    if ENV["LIBTRIXI_DEBUG"] in ("all", "julia")
        return true
    else
        return false
    end
end

end # module LibTrixi
