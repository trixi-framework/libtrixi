"""
    trixi_initialize()::Cint

initialize a new simulation and return a handle to the corresponding
[`simulationstate`](@ref) as a `Cint` (i.e, a plain C `int`).
"""
function trixi_initialize end

Base.@ccallable function trixi_initialize()::Cint
    # Create new simulation state and store in global dict
    simstate = trixi_initialize_jl()
    simstate_handle = store_simstate(simstate)

    # Return handle for usage/storage on C side
    return simstate_handle
end

trixi_initialize_cfptr() = @cfunction(trixi_initialize, Cint, ())

"""
    trixi_finalize(simstate_handle::Cint)::Cvoid

Finalize a simulation and attempt to free the underlying memory.
"""
function trixi_finalize end

Base.@ccallable function trixi_finalize(simstate_handle::Cint)::Cvoid
    # Load simulation state and call finalizer
    simstate = load_simstate(simstate_handle)
    trixi_finalize_jl(simstate)

    # Remove all references to simulation state and call garbage collection
    simstate = nothing
    delete_simstate!(simstate_handle)
    GC.gc()

    return nothing
end

trixi_finalize_cfptr() = @cfunction(trixi_finalize, Cvoid, (Ptr{Cvoid},))

"""
    trixi_calculate_dt(simstate_handle::Cint))::Cdouble

Compute, store, and return the time step size for the next time integration step.
"""
function trixi_calculate_dt end

Base.@ccallable function trixi_calculate_dt(simstate_handle::Cint)::Cdouble
    simstate = load_simstate(simstate_handle)
    dt = trixi_calculate_dt_jl(simstate)

    return dt
end

trixi_calculate_dt_cfptr() = @cfunction(trixi_calculate_dt, Cdouble, (Cint,))

"""
    trixi_is_finished(simstate_handle::Cint)::Cint

Return `0` if the simulation time has not yet reached the final time, and `1` otherwise.
"""
function trixi_is_finished end

Base.@ccallable function trixi_is_finished(simstate_handle::Cint)::Cint
    simstate = load_simstate(simstate_handle)
    is_finished = trixi_is_finished_jl(simstate)

    return is_finished ? 1 : 0
end

trixi_is_finished_cfptr() = @cfunction(trixi_is_finished, Cdouble, (Cint,))

"""
    trixi_step(simstate_handle::Cint)::Cvoid

Advance the simulation in time by one step.
"""
function trixi_step end

Base.@ccallable function trixi_step(simstate_handle::Cint)::Cvoid
    simstate = load_simstate(simstate_handle)
    trixi_step_jl(simstate)

    return nothing
end

trixi_step_cfptr() = @cfunction(trixi_step, Cvoid, (Cint,))
