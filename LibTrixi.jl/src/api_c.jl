"""
    trixi_initialize_simulation(libelixir::Cstring)::Cint
    trixi_initialize_simulation(libelixir::AbstractString)::Cint

Initialize a new simulation based on the file `libelixir`and return a handle to the
corresponding [`SimulationState`](@ref) as a `Cint` (i.e, a plain C `int`).

The libelixir has a similar purpose as a regular "elixir" in Trixi.jl, as it completely
defines a simulation setup in Julia code. A key difference (and thus the name libelixir) is
that instead of running a simulation directly, it should define an argument-less function
named `init_simstate()` that returns a [`SimulationState`](@ref) with the complete
simulation setup. `trixi_initialize_simulation` will store the `SimulationState` object
internally and allow one to use it in subsequent calls to libtrixi via the handle returned
from this function.

For convenience, when using LibTrixi.jl directly from Julia, one can also pass a regular
`String` in the `libelixir` argument.

!!! note "Libelixir hygiene and `init_simstate`"
    The libelixir file will be evaluated in the `Main` module. Thus any previously defined
    function `init_simstate` will be overwritten, and any variables defined outside the
    function will live throughout the lifetime of the Julia process.

!!! warning "Thread safety"
    **This function is not thread safe.** Since the libelixir file will be evaluated in the
    `Main` module, calling `trixi_initialize_simulation` simultaneously from different threads can lead
    to undefined behavior.

"""
function trixi_initialize_simulation end

Base.@ccallable function trixi_initialize_simulation(libelixir::Cstring)::Cint
    # Create string from Cstring
    filename = unsafe_string(libelixir)

    # Create new simulation state and store in global dict
    simstate = trixi_initialize_simulation_jl(filename)
    simstate_handle = store_simstate(simstate)

    # Return handle for usage/storage on C side
    return simstate_handle
end

trixi_initialize_simulation_cfptr() = @cfunction(trixi_initialize_simulation, Cint, (Cstring,))

# Convenience function when using this directly from Julia
function trixi_initialize_simulation(libelixir::String)
    # Convert string to byte array
    bytes = Vector{UInt8}(libelixir)

    # Make it a proper, NULL-terminated C-style char array
    push!(bytes, '\0')

    # Call `trixi_initialize_simulation` above with a raw pointer to the bytes array, which needs to be
    # protected from garbage collection
    GC.@preserve bytes begin
        simstate_handle = trixi_initialize_simulation(Cstring(pointer(bytes)))
    end

    return simstate_handle
end

"""
    trixi_finalize(simstate_handle::Cint)::Cvoid

Finalize a simulation and attempt to free the underlying memory.
"""
function trixi_finalize_simulation end

Base.@ccallable function trixi_finalize_simulation(simstate_handle::Cint)::Cvoid
    # Load simulation state and call finalizer
    simstate = load_simstate(simstate_handle)
    trixi_finalize_simulation_jl(simstate)

    # Remove all references to simulation state and call garbage collection
    simstate = nothing
    delete_simstate!(simstate_handle)
    GC.gc()

    return nothing
end

trixi_finalize_simulation_cfptr() = @cfunction(trixi_finalize_simulation, Cvoid, (Cint,))

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

trixi_is_finished_cfptr() = @cfunction(trixi_is_finished, Cint, (Cint,))

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


"""
    trixi_ndims(simstate_handle::Cint)::Cint

Return number of spatial dimensions.
"""
function trixi_ndims end

Base.@ccallable function trixi_ndims(simstate_handle::Cint)::Cint
    simstate = load_simstate(simstate_handle)
    return trixi_ndims_jl(simstate)
end

trixi_ndims_cfptr() = @cfunction(trixi_ndims, Cint, (Cint,))


"""
    trixi_nelements(simstate_handle::Cint)::Cint

Return number of elements (cells).
"""
function trixi_nelements end

Base.@ccallable function trixi_nelements(simstate_handle::Cint)::Cint
    simstate = load_simstate(simstate_handle)
    return trixi_nelements_jl(simstate)
end

trixi_nelements_cfptr() = @cfunction(trixi_nelements, Cint, (Cint,))


"""
    trixi_nvariables(simstate_handle::Cint)::Cint

Return number of variables.
"""
function trixi_nvariables end

Base.@ccallable function trixi_nvariables(simstate_handle::Cint)::Cint
    simstate = load_simstate(simstate_handle)
    return trixi_nvariables_jl(simstate)
end

trixi_nvariables_cfptr() = @cfunction(trixi_nvariables, Cint, (Cint,))


"""
    trixi_load_cell_averages(data::Ptr{Cdouble}, simstate_handle::Cint)::Cvoid

Return cell averaged solution state.

Cell averaged values for each cell and each primitive variable are stored in a contiguous
array, where cell values for the first variable appear first and values for the other
variables subsequently (structure-of-arrays layout).

The given array has to be of correct size and memory has to be allocated beforehand.
"""
function trixi_load_cell_averages end

Base.@ccallable function trixi_load_cell_averages(data::Ptr{Cdouble}, simstate_handle::Cint)::Cvoid
    simstate = load_simstate(simstate_handle)

    # convert C to julia array
    size = trixi_nvariables_jl(simstate) * trixi_nelements_jl(simstate)
    data_jl = unsafe_wrap(Array, data, size)

    trixi_load_cell_averages_jl(data_jl, simstate)
    return nothing
end

trixi_load_cell_averages_cfptr() = @cfunction(trixi_load_cell_averages, Cvoid, (Ptr{Cdouble}, Cint,))


"""
    trixi_version_major()::Cint

Return major version number of libtrixi.

This function is thread-safe. It must be run after `trixi_initialize` has been called.
"""
function trixi_version_major end

Base.@ccallable function trixi_version_major()::Cint
    return trixi_version_major_jl()
end

trixi_version_major_cfptr() = @cfunction(trixi_version_major, Cint, ())


"""
    trixi_version_minor()::Cint

Return minor version number of libtrixi.

This function is thread-safe. It must be run after `trixi_initialize` has been called.
"""
function trixi_version_minor end

Base.@ccallable function trixi_version_minor()::Cint
    return trixi_version_minor_jl()
end

trixi_version_minor_cfptr() = @cfunction(trixi_version_minor, Cint, ())


"""
    trixi_version_patch()::Cint

Return patch version number of libtrixi.

This function is thread-safe. It must be run after `trixi_initialize` has been called.
"""
function trixi_version_patch end

Base.@ccallable function trixi_version_patch()::Cint
    return trixi_version_patch_jl()
end

trixi_version_patch_cfptr() = @cfunction(trixi_version_patch, Cint, ())


"""
    trixi_version()::Cstring

Return full version string of libtrixi.

The return value is a read-only pointer to a NULL-terminated string with the version
information. This may include not just MAJOR.MINOR.PATCH but possibly also additional
build or development version information.

The returned pointer is to static memory and must not be used to change the contents of
the version string. Multiple calls to the function will return the same address.

This function is thread-safe. It must be run after `trixi_initialize` has been called.
"""
function trixi_version end

Base.@ccallable function trixi_version()::Cstring
    return pointer(_version_libtrixi[])
end

trixi_version_cfptr() = @cfunction(trixi_version, Cstring, ())


"""
    trixi_version_julia()::Cstring

Return name and version of loaded julia packages LibTrixi directly depends on.

The return value is a read-only pointer to a NULL-terminated string with the name and
version information of the loaded julia packages, separated by newlines.

The returned pointer is to static memory and must not be used to change the contents of
the version string. Multiple calls to the function will return the same address.

This function is thread-safe. It must be run after `trixi_initialize` has been called.
"""
function trixi_version_julia end

Base.@ccallable function trixi_version_julia()::Cstring
    return pointer(_version_info[])
end

trixi_version_julia_cfptr() = @cfunction(trixi_version_julia, Cstring, ())


"""
    trixi_version_julia_extended()::Cstring

Return name and version of all loaded julia packages.

The return value is a read-only pointer to a NULL-terminated string with the name and
version information of all loaded julia packages, including implicit dependencies,
separated by newlines.

The returned pointer is to static memory and must not be used to change the contents of
the version string. Multiple calls to the function will return the same address.

This function is thread-safe. It must be run after `trixi_initialize` has been called.
"""
function trixi_version_julia_extended end

Base.@ccallable function trixi_version_julia_extended()::Cstring
    return pointer(_version_info_extended[])
end

trixi_version_julia_extended_cfptr() = @cfunction(trixi_version_julia_extended, Cstring, ())