"""
    SimulationState

Data structure to store a simulation state consisting of
- a semidiscretization
- the time integrator
- an optional array of data vectors
"""
const LibTrixiDataBaseType = Array{Ref{Vector{Float64}}}

mutable struct SimulationState{SemiType, IntegratorType}
    semi::SemiType
    integrator::IntegratorType
    data::LibTrixiDataBaseType

    function SimulationState(semi, integrator, data = nothing)
        return new{typeof(semi), typeof(integrator)}(semi, integrator, data)
    end
end

# Global variables to store different simulation states
# This allows one to handle multiple Trixi.jl simulations independently
#
# Opaque handle type that can be passed to and stored in the C program
const SimulationStateHandle = Cint
# Variable that internally holds different simulation states such that they are not garbage
# collected prematurely
const simstates = Dict{SimulationStateHandle, SimulationState}()
# Number of simulation states already created
const simstate_counter = Ref(0)

# Take the simulation state and store it in the global simstate dict to prevent garbage
# collection, then return a C-compatible handle to it
function store_simstate(simstate)
    if simstate_counter[] >= typemax(SimulationStateHandle)
        error("maximum number of storable simulation states reached: ",
              typemax(SimulationStateHandle))
    end

    simstate_counter[] += 1
    handle = simstate_counter[]
    if in(handle, keys(simstates))
        error("simstate handle already exists - this should not be possible...")
    end

    simstates[handle] = simstate

    return handle
end

# Load the simulation state identified by the handle from the global simstate dict
function load_simstate(handle)
    if !in(handle, keys(simstates))
        error("the provided handle was not found in the stored simulation states: ", handle)
    end

    simstate = simstates[handle]

    return simstate
end

# Remove the simulation state identified by the handle from the global simstate dict
function delete_simstate!(handle)
    if !in(handle, keys(simstates))
        error("the provided handle was not found in the stored simulation states: ", handle)
    end

    delete!(simstates, handle)

    return handle
end
