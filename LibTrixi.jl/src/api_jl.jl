function trixi_initialize_simulation_jl(filename)
    # Load elixir with simulation setup
    Base.include(Main, abspath(filename))

    # Initialize simulation state
    # Note: we need `invokelatest` here since the function is dynamically upon `include`
    # Note: `invokelatest` is not exported until Julia v1.9, thus we call it through `Base`
    simstate = Base.invokelatest(Main.init_simstate)

    if show_debug_output()
        println("Simulation state initialized")
    end

    return simstate
end

function trixi_finalize_simulation_jl(simstate)
    # Run summary callback one final time
    for cb in simstate.integrator.opts.callback.discrete_callbacks
        if cb isa DiscreteCallback{<:Any, typeof(summary_callback)}
            cb()
        end
    end

    if show_debug_output()
        println("Simulation state finalized")
    end

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
    end

    return nothing
end

function trixi_ndims_jl(simstate)
    mesh, _, _, _ = mesh_equations_solver_cache(simstate.semi)
    return ndims(mesh)
end

function trixi_nelements_jl(simstate)
    _, _, solver, cache = mesh_equations_solver_cache(simstate.semi)
    return nelements(solver, cache)
end

function trixi_nvariables_jl(simstate)
    _, equations, _, _ = mesh_equations_solver_cache(simstate.semi)
    return nvariables(equations)
end

function trixi_load_cell_averages_jl(data_, simstate)
    mesh, equations, solver, cache = mesh_equations_solver_cache(simstate.semi)
    nels = nelements(solver, cache)
    nvars = nvariables(equations)

    # convert C to julia
    data = unsafe_wrap(Array, data_, nels*nvars)

    u_ode = simstate.integrator.u
    u = wrap_array(u_ode, mesh, equations, solver, cache)

    # temporary storage for mean value on current element for all variables
    u_mean = zero(get_node_vars(u, equations, solver, 1, 1, 1))

    for element in eachelement(solver, cache)

        u_mean = zero(u_mean)

        # compute mean value using nodal dg values and quadrature
        for j in eachnode(solver), i in eachnode(solver)
            u_node_prim = cons2prim(get_node_vars(u, equations, solver, i, j, element), equations)
            u_mean += u_node_prim * solver.basis.weights[i] * solver.basis.weights[j]
        end

        # normalize to unit element
        u_mean = u_mean / 2^ndims(mesh)

        # copy to provided array
        for ivar = 0:nvars-1
            data[element + ivar * nels] = u_mean[ivar+1]
        end
    end

    return nothing
end
