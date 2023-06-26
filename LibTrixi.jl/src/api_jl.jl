function trixi_initialize_simulation_jl(filename)
    # Load elixir with simulation setup
    Base.include(Main, filename)

    # Initialize simulation state
    # Note: we need `invokelatest` here since the function is dynamically upon `include`
    simstate = invokelatest(Main.init_simstate)

    if show_debug_output()
        println("Simulation state initialized")
    end

    return simstate
end

function trixi_finalize_simulation_jl(simstate)
    (; u0, u) = simstate.integrator

    # Resize arrays to zero length
    resize!(u0, 0)
    resize!(u, 0)

    if show_debug_output()
        println("Simulation state finalized")
    end

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

        if show_debug_output()
            println("Current time: ", t[])
            println("Final time reached")
        end
    elseif t[] + dt[] > finaltime[]
        dt[] = finaltime[] - t[]
        t[] += dt[]

        if show_debug_output()
            println("Current time: ", t[])
            println("Final time reached")
        end
    else
        t[] += dt[]

        if show_debug_output()
            println("Current time: ", t[])
        end
    end

    return nothing
end
