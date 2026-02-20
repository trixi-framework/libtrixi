# A manufactured solution of a circular wind with constant angular velocity
# on a planetary-sized cubed sphere mesh with a blob detected by AMR
#
# Note that this libelixir is based on an elixir by Erik Faulhaber for Trixi.jl
# Source: https://github.com/trixi-framework/Trixi.jl/blob/main/examples/p4est_3d_dgsem/elixir_euler_circular_wind_nonconforming.jl

using OrdinaryDiffEq
using Trixi
using LinearAlgebra
using LibTrixi


function initial_condition_circular_wind(x, t, equations::PassiveTracerEquations)
    radius_earth = 6.371229e6
    lambda, phi, r = cart_to_sphere(x)
    z = r - radius_earth

    p = 1e5
    v1 = -10 * x[2] / radius_earth
    v2 = 10 * x[1] / radius_earth
    v3 = 0.0
    rho = 1.0

    # Initial condition for tracers: blob as a fraction of density
    tracer = 0.1  * exp(-20 * ((lambda-1.5)^2/2.0 + (phi-0.3)^2 + ((z)/40000)^2))

    return prim2cons(SVector(rho, v1, v2, v3, p, tracer), equations)
end

function cart_to_sphere(x)
    r = norm(x)
    lambda = atan(x[2], x[1])
    if lambda < 0
        lambda += 2 * pi
    end
    phi = asin(x[3] / r)

    return lambda, phi, r
end

# Boundary condition for passive tracers, missing in Trixi.jl
@inline function Trixi.boundary_condition_slip_wall(u_inner,
                                                    normal_direction::AbstractVector,
                                                    x, t, surface_flux_function,
                                                    tracer_equations::PassiveTracerEquations)
    @unpack flow_equations = tracer_equations
    u_flow = Trixi.flow_variables(u_inner, tracer_equations)
    bc_flow = boundary_condition_slip_wall(u_flow, normal_direction, x, t,
                                           surface_flux_function, flow_equations)
    bc_tracer = SVector(ntuple(@inline(v->0), Val(Trixi.ntracers(tracer_equations))))
    return vcat(bc_flow, bc_tracer)
end


# Callable struct holding vectors with source terms
struct SourceTerm
    nnodesdim::Int
    registry::LibTrixiDataRegistry
end

# We overwrite Trixi.jl's internal method here such that it calls source_terms with indices
# and with coordinates, respectively
function Trixi.calc_sources!(du, u, t, source_terms::SourceTerm,
                             equations::PassiveTracerEquations, dg::DG, cache)
    @unpack node_coordinates = cache.elements
    Trixi.@threaded for element in eachelement(dg, cache)
        for k in eachnode(dg), j in eachnode(dg), i in eachnode(dg)
            u_local = Trixi.get_node_vars(u, equations, dg, i, j, k, element)
            du_local_index = source_terms(u_local, i, j, k, element, t, equations)
            x_local = Trixi.get_node_coords(node_coordinates, equations, dg,
                                            i, j, k, element)
            du_local_coord = source_terms(u_local, x_local, t, equations)
            Trixi.add_to_node_vars!(du, du_local_index, equations, dg, i, j, k, element)
            Trixi.add_to_node_vars!(du, du_local_coord, equations, dg, i, j, k, element)
        end
    end
    return nothing
end

# source terms for circular wind, based on coordinates
@inline function (source::SourceTerm)(u, x, t,
                                      equations::PassiveTracerEquations)
    radius_earth = 6.371229e6
    rho = u[1]
   
    du0 = 0.0
    du2 = -rho * (10 / radius_earth) * (10 * x[1] / radius_earth)
    du3 = -rho * (10 / radius_earth) * (10 * x[2] / radius_earth)

    return SVector(du0, du2, du3, du0, du0, du0)
end

# additional source term read from data registry, based on indices
@inline function (source::SourceTerm)(u, i, j, k, element, t,
                                      equations::PassiveTracerEquations)
    @unpack nnodesdim = source
    index_global = (element-1) * nnodesdim^3 + (k-1) * nnodesdim^2 + (j-1) * nnodesdim + i
    du_tracer::Vector{Float64} = source.registry[1]
    du0 = zero(eltype(u))
    return SVector(du0, du0, du0, du0, du0, du_tracer[index_global])
end

# The function to create the simulation state needs to be named `init_simstate`
function init_simstate()

    # compressible Euler equations
    gamma = 1.4
    flow_equations = CompressibleEulerEquations3D(gamma)
    equations = PassiveTracerEquations(flow_equations, n_tracers = 1)

    # setup of the problem
    initial_condition = initial_condition_circular_wind

    boundary_conditions = Dict(:inside => boundary_condition_slip_wall,
                               :outside => boundary_condition_slip_wall)

    # estimate for speed of sound
    surface_flux = FluxTracerEquationsCentral(FluxLMARS(374))
    solver = DGSEM(polydeg = 4, surface_flux = surface_flux)

    # cells in horizonal and vertical direction, respectively
    lat_lon_cells = 4
    layers = 1

    # we use half the polynomial degree of the solver (free stream preserving)
    mesh = Trixi.T8codeMeshCubedSphere(lat_lon_cells, layers, 6.371229e6, 30000.0,
                                       polydeg = 2, initial_refinement_level = 0)

    # create the data registry and one vector for the source terms
    registry = LibTrixiDataRegistry(undef, 1)

    nnodesdim = Trixi.nnodes(solver)
    nnodes = nnodesdim^3
    nelements = Trixi.ncells(mesh)

    # provide some data because calc_sources! will already be called during initialization
    # provide even more data because AMR might refine already for the initial condition
    # TODO: better use something like FillArrays' Zero here
    # the data pointers in the registry will be overwritten before the first real use
    registry[1] = zeros(Float64, 8*nelements*nnodes)
    
    source_terms = SourceTerm(nnodesdim, registry)
    semi = SemidiscretizationHyperbolic(mesh, equations, initial_condition, solver,
                                        source_terms = source_terms,
                                        boundary_conditions = boundary_conditions)
    
    # 3 days
    days = 3
    tspan = (0.0, days * 24 * 60 * 60.0)

    ode = semidiscretize(semi, tspan)

    summary_callback = SummaryCallback()

    analysis_interval = 1000
    analysis_callback = AnalysisCallback(semi, interval = analysis_interval)

    alive_callback = AliveCallback(analysis_interval = analysis_interval)

    save_solution = SaveSolutionCallback(interval = analysis_interval,
                                         save_initial_solution = true,
                                         save_final_solution = true,
                                         solution_variables = cons2prim,
                                         output_directory = "out_zonalwind")

    @inline function first_tracer(u, equations::PassiveTracerEquations)
        return Trixi.tracers(u, equations)[1]
    end

    indicator_max = IndicatorMax(semi, variable = first_tracer)

    amr_controller = ControllerThreeLevel(semi, indicator_max,
                                          base_level = 0,
                                          med_level = 1, med_threshold = 0.03,
                                          max_level = 2, max_threshold = 0.04)

    amr_callback = AMRCallback(semi, amr_controller,
                               interval = analysis_interval,
                               adapt_initial_condition = true,
                               adapt_initial_condition_only_refine = true)

    stepsize_callback = StepsizeCallback(cfl = 0.8)

    callbacks = CallbackSet(summary_callback,
                            analysis_callback,
                            alive_callback,
                            amr_callback,
                            #stepsize_callback,
                            save_solution)

    # use a Runge-Kutta method with automatic (error based) time step size control
    # alternatively CarpenterKennedy with CFL-based time step control
    integrator = init(ode,
                      RDPK3SpFSAL49(thread = Trixi.False()); abstol = 1.0e-6, reltol = 1.0e-6,
                      #CarpenterKennedy2N54(williamson_condition=false); dt=0.001,
                      ode_default_options()..., callback = callbacks, maxiters=1e7);

    # create simulation state
    simstate = SimulationState(semi, integrator, registry)

    return simstate
end
