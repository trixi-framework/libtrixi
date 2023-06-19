"""
    trixi_initialize()::Cint

initialize a new simulation and return a handle to the corresponding
[`simulationstate`](@ref) as a `Cint` (i.e, a plain C `int`).
"""
Base.@ccallable function trixi_initialize()::Cint
    # Create new simulation state and store in global dict
    simstate = trixi_initialize_jl()
    handle = store_simstate(simstate)

    # Return handle for usage/storage on C side
    return handle
end
trixi_initialize_cfptr() = @cfunction(trixi_initialize, Cint, ())

"""
    trixi_finalize(simstate_handle::Cint)::Cvoid

Finalize a simulation and attempt to free the underlying memory.
"""
Base.@ccallable function trixi_finalize(simstate_handle::Cint)::Cvoid
    # Load simulation state and call finalizer
    simstate = load_simstate(simstate_handle)
    trixi_finalize_jl(simstate)

    # Remove all references to simulation state and call garbage collection
    simstate = nothing
    delete_simstate!(handle)
    GC.gc()

    return nothing
end
trixi_finalize_cfptr() = @cfunction(trixi_finalize, Cvoid, (Ptr{Cvoid},))

"""
    trixi_get_dt(simstate_handle::Cint))::Cdouble

Compute and return the time step size for the next time integration step.
"""
Base.@ccallable function trixi_get_dt(simstate_handle::Cint)::Cdouble
    simstate = load_simstate(simstate_handle)
    dt = trixi_get_dt_jl(simstate)

    return dt
end
trixi_get_dt_cfptr() = @cfunction(trixi_get_dt, Cdouble, (Cint,))

"""
    trixi_is_final_step(simstate_handle::Cint)::Cint

Return `0` if the next call to [`trixi_step`](@ref) is *not* the final time step. Return `1`
once the final time step has been reached and from then on onwards.
"""
Base.@ccallable function trixi_is_final_step(simstate_handle::Cint)::Cint
    simstate = load_simstate(simstate_handle)
    is_final_step = trixi_is_final_step_jl(simstate)

    return is_final_step ? 1 : 0
end
trixi_is_final_step_cfptr() = @cfunction(trixi_is_final_step, Cdouble, (Cint,))

"""
    trixi_step(simstate_handle::Cint)::Cvoid

Advance the simulation in time by one step.
"""
Base.@ccallable function trixi_step(simstate_handle::Cint)::Cvoid
    simstate = load_simstate(simstate_handle)
    trixi_step_jl(simstate)

    return nothing
end
trixi_step_cfptr() = @cfunction(trixi_step, Cvoid, (Cint,))

