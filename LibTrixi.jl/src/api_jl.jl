function trixi_initialize_jl()
    # Create simulation state
    semi = (; mesh = "mesh", equations = "equations", solver = "solver", cache = Float64[])
    integrator = (; t = 0.0, finaltime = 1.0, dt = 0.0, iter = 0, u0 = Float64[],
                  u = Float64[])
    simstate = SimulationState(semi, integrator)

    # Set up some dummy values
    simstate.integrator.dt = 1.2345
    simstate.integrator.u0 = ones(5)
    simstate.integrator.u = ones(5)

    return simstate
end

function  trixi_finalize_jl(simstate)
    (; u0, u) = simstate.integrator
    resize!(u0, 0)
    resize!(u, 0)

    return nothing
end

function trixi_get_dt_jl(simstate)
    (; t, finaltime, dt) = simstate.integrator
    if isapprox(t + dt, finaltime) || t + dt > finaltime
        dt = finaltime - t
    end

    return dt
end

function trixi_is_final_step_jl(simstate)
    (; t, finaltime, dt) = simstate.integrator

    if isapprox(t + dt, finaltime) || t + dt > finaltime
        return true
    else
        return false
    end
end

function trixi_step_jl(simstate)
    (; u) = simstate.integrator
    u .+= 1

    (; t, finaltime, dt) = simstate.integrator
    if trixi_is_final_step_jl(simstate)
        simstate.integrator.t = finaltime
    else
        simstate.integrator.t += dt
    end

    return nothing
end
