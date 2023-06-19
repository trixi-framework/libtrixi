function trixi_initialize_jl()
    # Create simulation state
    semi = (; mesh = "mesh", equations = "equations", solver = "solver", cache = Float64[])
    integrator = (; t = Ref(0.0), finaltime = Ref(1.0), dt = Ref(0.0), u0 = Float64[],
                  u = Float64[])
    simstate = SimulationState(semi, integrator)

    # Set up some dummy values
    (; dt, u0, u) = simstate.integrator
    dt[] = 0.3
    resize!(u0, 5)
    u0 .= 1
    resize!(u, 5)
    u .= u0

    return simstate
end

function trixi_finalize_jl(simstate)
    (; u0, u) = simstate.integrator

    # Resize arrays to zero length
    resize!(u0, 0)
    resize!(u, 0)

    return nothing
end

function trixi_calculate_dt_jl(simstate)
    (; t, finaltime, dt) = simstate.integrator

    # If next step would take us up to or beyond final time, reduce dt accordingly
    if isapprox(t[] + dt[], finaltime[]) || t[] + dt[] > finaltime[]
        dt[] = finaltime[] - t[]
    end

    return dt[]
end

function trixi_is_finished_jl(simstate)
    (; t, finaltime) = simstate.integrator

    # Return true if current time is approximately the final time
    return isapprox(t[], finaltime[])
end

function trixi_step_jl(simstate)
    (; t, finaltime, dt, u) = simstate.integrator

    # Sanity check
    if isapprox(t[], finaltime[])
        error("simulation is already finished: t ≈ finaltime")
    end

    # "Advance" solution in time
    u .+= 1

    # Update time such that we hit `finaltime` exactly
    if isapprox(t[] + dt[], finaltime[])
        t[] = finaltime[]
        println("Final time reached")
    elseif t[] + dt[] > finaltime[]
        dt[] = finaltime[] - t[]
    else
        t[] += dt[]
        println("Current time: ", t[])
    end

    return nothing
end
