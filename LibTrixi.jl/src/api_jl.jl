############################################################################################
# Simulation control                                                                       #
############################################################################################

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



############################################################################################
# Simulation data                                                                          #
############################################################################################

function trixi_calculate_dt_jl(simstate)
    return simstate.integrator.dtpropose
end


function trixi_ndims_jl(simstate)
    mesh, _, _, _ = mesh_equations_solver_cache(simstate.semi)
    return ndims(mesh)
end


function trixi_nelements_jl(simstate)
    _, _, solver, cache = mesh_equations_solver_cache(simstate.semi)
    return nelements(solver, cache)
end


function trixi_nelements_global_jl(simstate)
    _, _, solver, cache = mesh_equations_solver_cache(simstate.semi)
    return nelementsglobal(solver, cache)
end


function trixi_ndofs_jl(simstate)
    mesh, _, solver, cache = mesh_equations_solver_cache(simstate.semi)
    return ndofs(mesh, solver, cache)
end


function trixi_ndofs_global_jl(simstate)
    mesh, _, solver, cache = mesh_equations_solver_cache(simstate.semi)
    return ndofsglobal(mesh, solver, cache)
end


function trixi_ndofs_element_jl(simstate)
    mesh, _, solver, _ = mesh_equations_solver_cache(simstate.semi)
    return nnodes(solver)^ndims(mesh)
end


function trixi_nvariables_jl(simstate)
    _, equations, _, _ = mesh_equations_solver_cache(simstate.semi)
    return nvariables(equations)
end


function trixi_load_cell_averages_jl(data, index, simstate)
    mesh, equations, solver, cache = mesh_equations_solver_cache(simstate.semi)
    n_nodes = nnodes(solver)
    n_dims = ndims(mesh)

    u_ode = simstate.integrator.u
    u = wrap_array(u_ode, mesh, equations, solver, cache)

    # all permutations of nodes indices for arbitrary dimension
    node_cis = CartesianIndices(ntuple(i -> n_nodes, n_dims))

    for element in eachelement(solver, cache)

        # compute mean value using nodal dg values and quadrature
        u_mean = zero(eltype(u))
        for node_ci in node_cis
            u_node_prim = cons2prim(get_node_vars(u, equations, solver, node_ci, element),
                                    equations)[index]
            weight = 1.
            for node_index in Tuple(node_ci)
                weight *= solver.basis.weights[node_index]
            end
            u_mean += u_node_prim * weight
        end

        # normalize to unit element
        u_mean = u_mean / 2^n_dims

        # write to provided array
        data[element] = u_mean
    end

    return nothing
end


function trixi_load_prim_jl(data, index, simstate)
    mesh, equations, solver, cache = mesh_equations_solver_cache(simstate.semi)
    n_nodes_per_dim = nnodes(solver)
    n_dims = ndims(mesh)
    n_nodes = n_nodes_per_dim^n_dims

    u_ode = simstate.integrator.u
    u = wrap_array(u_ode, mesh, equations, solver, cache)

    # all permutations of nodes indices for arbitrary dimension
    node_cis = CartesianIndices(ntuple(i -> n_nodes_per_dim, n_dims))
    node_lis = LinearIndices(node_cis)

    for element in eachelement(solver, cache)
        for node_ci in node_cis
            node_vars = get_node_vars(u, equations, solver, node_ci, element)
            node_index = (element-1) * n_nodes + node_lis[node_ci]
            data[node_index] = cons2prim(node_vars, equations)[index]
        end
    end

    return nothing
end


function trixi_store_in_database_jl(data, index, simstate)
    simstate.data[index] = Ref(data)
    if show_debug_output()
        println("New data vector stored at index ", index)
    end
    return nothing
end


function trixi_get_time_jl(simstate)
    return simstate.integrator.t
end


function trixi_load_node_coordinates_jl(simstate, x)
    mesh, equations, solver, cache = mesh_equations_solver_cache(simstate.semi)

    n_nodes_per_dim = nnodes(solver)
    n_dims = ndims(mesh)
    n_nodes = n_nodes_per_dim^n_dims
    n_dofs = ndofs(mesh, solver, cache)

    # all permutations of nodes indices for arbitrary dimension
    node_cis = CartesianIndices(ntuple(i -> n_nodes_per_dim, n_dims))
    node_lis = LinearIndices(node_cis)

    for element in eachelement(solver, cache)
        for node_ci in node_cis
            x_local = get_node_coords(cache.elements.node_coordinates, equations, solver,
                                      node_ci, element)
            node_index = (element-1) * n_nodes + node_lis[node_ci]
            for d in 1:n_dims
                x[(d-1)*n_dofs + node_index] = x_local[d]
            end
        end
    end

    return nothing
end


function trixi_get_t8code_forest_jl(simstate)
    mesh, _, _, _ = Trixi.mesh_equations_solver_cache(simstate.semi)
    return mesh.forest
end

############################################################################################
# Auxiliary
############################################################################################
function trixi_eval_julia_jl(code)
    expr = Meta.parse(code)
    return Base.eval(Main, expr)
end
