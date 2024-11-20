# A manufactured solution of a circular wind with constant angular velocity
# on a planetary-sized cubed sphere mesh with a blob detected by AMR
#
# Note that this libelixir is based on an elixir by Erik Faulhaber for Trixi.jl
# Source: https://github.com/trixi-framework/Trixi.jl/blob/main/examples/p4est_3d_dgsem/elixir_euler_circular_wind_nonconforming.jl

using OrdinaryDiffEq
using Trixi
using LinearAlgebra
using LibTrixi


function initial_condition_circular_wind(x, t, equations::CompressibleEulerEquations3D)
    radius_earth = 6.371229e6
    lambda, phi, r = cart_to_sphere(x)

    p = 1e5
    v1 = -10 * x[2] / radius_earth
    v2 = 10 * x[1] / radius_earth
    v3 = 0.0
    rho = 1.0 + 0.1  * exp(-50 * ((lambda-1.0)^2/2.0 + (phi-0.4)^2)) +
                0.08 * exp(-100 * ((lambda-0.8)^2/4.0 + (phi-0.5)^2))

    return prim2cons(SVector(rho, v1, v2, v3, p), equations)
end

@inline function source_terms_circular_wind(u, x, t,
                                            equations::CompressibleEulerEquations3D)
    radius_earth = 6.371229e6
    rho = u[1]
   
    du1 = 0.0
    du2 = -rho * (10 / radius_earth) * (10 * x[1] / radius_earth)
    du3 = -rho * (10 / radius_earth) * (10 * x[2] / radius_earth)
    du4 = 0.0
    du5 = 0.0

    return SVector(du1, du2, du3, du4, du5)
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


# The function to create the simulation state needs to be named `init_simstate`
function init_simstate()

    # compressible Euler equations
    gamma = 1.4
    equations = CompressibleEulerEquations3D(gamma)

    # setup of the problem
    initial_condition = initial_condition_circular_wind

    boundary_conditions = Dict(:inside => boundary_condition_slip_wall,
                               :outside => boundary_condition_slip_wall)

    # estimate for speed of sound
    surface_flux = FluxLMARS(374)
    solver = DGSEM(polydeg = 3, surface_flux = surface_flux)

    # increase trees_per_cube_face or initial_refinement_level to get nicer results
    lat_lon_levels = 2
    layers = 1
    mesh = Trixi.T8codeMeshCubedSphere(lat_lon_levels, layers, 6.371229e6, 30000.0,
                                       polydeg = 3, initial_refinement_level = 0)

    semi = SemidiscretizationHyperbolic(mesh, equations, initial_condition, solver,
                                        source_terms = source_terms_circular_wind,
                                        boundary_conditions = boundary_conditions)
    
    # increase number of days
    days = 0.1
    tspan = (0.0, days * 24 * 60 * 60.0)

    ode = semidiscretize(semi, tspan)

    summary_callback = SummaryCallback()

    analysis_interval = 5000
    analysis_callback = AnalysisCallback(semi, interval = analysis_interval)

    alive_callback = AliveCallback(analysis_interval = analysis_interval)

    save_solution = SaveSolutionCallback(interval = 2000,
                                         save_initial_solution = true,
                                         save_final_solution = true,
                                         solution_variables = cons2prim,
                                         output_directory = "out_tracer")

    amr_controller = ControllerThreeLevel(semi, IndicatorMax(semi, variable = first),
                                          base_level = 0,
                                          med_level = 1, med_threshold = 1.004,
                                          max_level = 3, max_threshold = 1.11)

    amr_callback = AMRCallback(semi, amr_controller,
                               interval = 2000,
                               adapt_initial_condition = true,
                               adapt_initial_condition_only_refine = true)

    callbacks = CallbackSet(summary_callback,
                            analysis_callback,
                            alive_callback,
                            amr_callback,
                            save_solution)

    # use a Runge-Kutta method with automatic (error based) time step size control
    integrator = init(ode, RDPK3SpFSAL49(thread = OrdinaryDiffEq.False());
                      abstol = 1.0e-6, reltol = 1.0e-6,
                      ode_default_options()..., callback = callbacks, maxiters=1e7);

    # create simulation state
    simstate = SimulationState(semi, integrator)

    return simstate
end
