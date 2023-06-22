function trixi_initialize_simulation_jl(filename)
    # Load elixir with simulation setup
    Base.include(Main, filename)

    # Initialize simulation state
    # Note: we need `invokelatest` here since the function is dynamically upon `include`
    simstate = invokelatest(Main.init_simstate)

    println("Simulation state initialized")

    return simstate
end

function trixi_finalize_simulation_jl(simstate)
    # TODO: call the SummaryCallback(), but its position is arbitrary
    simstate.integrator.opts.callback.discrete_callbacks[1]()

    println("Simulation state finalized")

    return nothing
end

function trixi_calculate_dt_jl(simstate)
    return simstate.integrator.dtpropose
end

function trixi_is_finished_jl(simstate)
    # Return true if current time is approximately the final time
    return isapprox(simstate.integrator.t, simstate.integrator.sol.prob.tspan[2])
end

function trixi_step_jl(simstate)
    step!(simstate.integrator)

    ret = check_error(simstate.integrator)

    if ret != :Success
        error("integrator failed to perform time step, return code: ", ret)
    else
        println("advanced to time ", simstate.integrator.t)
    end

    return nothing
end
