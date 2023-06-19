module LibTrixi

export trixi_initialize,
       trixi_initialize_cfptr,
       trixi_initialize_jl
export trixi_finalize,
       trixi_finalize_cfptr,
       trixi_finalize_jl
export trixi_get_dt,
       trixi_get_dt_cfptr,
       trixi_get_dt_jl
export trixi_step,
       trixi_step_cfptr,
       trixi_step_jl

include("simulationstate.jl")
include("api_c.jl")
include("api_jl.jl")

end # module LibTrixi
