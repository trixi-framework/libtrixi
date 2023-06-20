"""
    trixi_initialize(libelixir::Cstring)::Cint
    trixi_initialize(libelixir::AbstractString)::Cint

Initialize a new simulation based on the file `libelixir`and return a handle to the
corresponding [`simulationstate`](@ref) as a `Cint` (i.e, a plain C `int`).

The libelixir has a similar purpose as a regular "elixir" in Trixi.jl, as it completely
defines a simulation setup in Julia code. A key difference (and thus the name libelixir) is
that instead of running a simulation directly, it should define an argument-less function
named `init_simstate()` that returns a [`SimulationState`](@ref) with the complete
simulation setup. `trixi_initialize` will store the `SimulationState` object internally and
allow one to use it in subsequent calls to libtrixi via the handle returned from this
function.

For convenience, when using LibTrixi.jl directly from Julia, one can also pass a regular
`String` in the `libelixir` argument.

!!! note "Libelixir hygiene and `init_simstate`"
    The libelixir file will be evaluated in the `Main` module. Thus any previously defined
    function `init_simstate` will be overwritten, and any variables defined outside the
    function will live throughout the lifetime of the Julia process.

!!! warning "Thread safety"
    **This function is not thread safe.** Since the libelixir file will be evaluated in the
    `Main` module, calling `trixi_initialize` simultaneously from different threads can lead
    to undefined behavior.
    
"""
function trixi_initialize end

Base.@ccallable function trixi_initialize(libelixir::Cstring)::Cint
    # Create string from Cstring
    filename = unsafe_string(libelixir)

    # Create new simulation state and store in global dict
    simstate = trixi_initialize_jl(filename)
    simstate_handle = store_simstate(simstate)

    # Return handle for usage/storage on C side
    return simstate_handle
end

trixi_initialize_cfptr() = @cfunction(trixi_initialize, Cint, (Cstring,))

# Convenience function when using this directly from Julia
function trixi_initialize(libelixir::String)
    # Convert string to byte array
    bytes = Vector{UInt8}(libelixir)

    # Make it a proper, NULL-terminated C-style char array
    push!(bytes, '\0')

    # Call `trixi_initialize` above with a raw pointer to the bytes array, which needs to be
    # protected from garbage collection
    GC.@preserve bytes begin
        simstate_handle = trixi_initialize(Cstring(pointer(bytes)))
    end

    return simstate_handle
end

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
    trixi_calculate_dt(simstate_handle::Cint)::Cdouble

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
