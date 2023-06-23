module LibTrixi

using OrdinaryDiffEq
using Trixi

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

export SimulationState, store_simstate, load_simstate, delete_simstate!

include("simulationstate.jl")
include("api_c.jl")
include("api_jl.jl")

end # module LibTrixi
