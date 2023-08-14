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

function trixi_load_cell_averages_jl(data, simstate)
    mesh, equations, solver, cache = mesh_equations_solver_cache(simstate.semi)
    n_elements = nelements(solver, cache)
    n_variables = nvariables(equations)
    n_nodes = nnodes(solver)
    n_dims = ndims(mesh)

    u_ode = simstate.integrator.u
    u = wrap_array(u_ode, mesh, equations, solver, cache)

    # all permutations of nodes indices for arbitrary dimension
    node_cis = CartesianIndices(ntuple(i -> n_nodes, n_dims))

    # temporary storage for mean value on current element for all variables
    u_mean = get_node_vars(u, equations, solver, node_cis[1], 1)

    for element in eachelement(solver, cache)

        # compute mean value using nodal dg values and quadrature
        u_mean = zero(u_mean)
        for node_ci in node_cis
            u_node_prim = cons2prim(get_node_vars(u, equations, solver, node_ci, element), equations)
            weight = 1.
            for node_index in Tuple(node_ci)
                weight *= solver.basis.weights[node_index]
            end
            u_mean += u_node_prim * weight
        end

        # normalize to unit element
        u_mean = u_mean / 2^n_dims

        # copy to provided array
        # all element values for first variable, then for second, ...
        for ivar = 0:n_variables-1
            data[element + ivar * n_elements] = u_mean[ivar+1]
        end
    end

    return nothing
end

function trixi_version_julia_jl()
    return _version_info[]
end

function trixi_version_julia_extended_jl()
    return _version_info_extended[]
end
