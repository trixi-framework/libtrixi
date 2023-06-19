module LibTrixi

export trixi_initialize,
       trixi_initialize_cfptr,
       trixi_initialize_jl
export trixi_finalize,
       trixi_finalize_cfptr,
       trixi_finalize_jl
export trixi_calculate_dt,
       trixi_calculate_dt_cfptr,
       trixi_calculate_dt_jl
export trixi_is_finished,
       trixi_is_finished_cfptr,
       trixi_is_finished_jl
export trixi_step,
       trixi_step_cfptr,
       trixi_step_jl

export store_simstate, load_simstate, delete_simstate!

include("simulationstate.jl")
include("api_c.jl")
include("api_jl.jl")

end # module LibTrixi
