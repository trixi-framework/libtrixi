using LibTrixi
using OrdinaryDiffEq
using Trixi

# The function to create the simulation state needs to be named `init_simstate`
function init_simstate()

    ###############################################################################
    # initial condition: density wave + tracer blob

    function initial_condition_wave_blob(x, t,
                                        equations::PassiveTracerEquations)
        # Initial condition for flow equations: density wave
        v1 = 0.1
        v2 = 0.2
        rho = 1 + 0.5 * sinpi(2 * (x[1] + x[2] - t * (v1 + v2)))
        rho_v1 = rho * v1
        rho_v2 = rho * v2
        p = 20
        rho_e = p / (equations.flow_equations.gamma - 1) + 0.5 * rho * (v1^2 + v2^2)

        # Initial condition for tracers: blob in fraction of density
        tracer = 0.2 * exp(-20 * (x[1] + 0.45)^2 - 10 * (x[2] - 0.15)^2)

        return SVector(rho, rho_v1, rho_v2, rho_e, rho * tracer)
    end

    ###############################################################################
    # semidiscretization of the compressible Euler equations

    gamma = 1.4
    flow_equations = CompressibleEulerEquations2D(gamma)
    equations = PassiveTracerEquations(flow_equations, n_tracers = 1)

    # Create DG solver with polynomial degree = 5, Ranocha flux, and derived tracer flux
    solver = DGSEM(polydeg = 5, surface_flux = FluxTracerEquationsCentral(flux_ranocha))

    coordinates_min = (-1.0, -1.0) # minimum coordinates (min(x), min(y))
    coordinates_max = ( 1.0,  1.0) # maximum coordinates (max(x), max(y))
    trees_per_dimension = (4, 4)   # initial resolution (without refinement)
    mesh = T8codeMesh(trees_per_dimension, polydeg = 1,
                      coordinates_min = coordinates_min, coordinates_max = coordinates_max,
                      initial_refinement_level = 1)

    # Create spatial discretization
    semi = SemidiscretizationHyperbolic(mesh, equations, initial_condition_wave_blob,
                                        solver)

    ###############################################################################
    # ODE solvers, callbacks etc.

    # Create ODE problem with time span from 0.0 to 2.0
    ode = semidiscretize(semi, (0.0, 2.0));

    # SummaryCallback prints a summary of the simulation setup and recorded performance data
    summary_callback = SummaryCallback()

    # AnalysisCallback analyses the solution at regular intervals and prints the results
    analysis_interval = 100
    analysis_callback = AnalysisCallback(semi, interval=analysis_interval)

    # AliveCallback prints a one line summary at regular intervals
    alive_callback = AliveCallback(analysis_interval=analysis_interval)

    # StepsizeCallback handles the re-calculation of the maximum Δt after each time step
    stepsize_callback = StepsizeCallback(cfl = 1.0)

    # AMRCallback triggers adaptive mesh refinement
    @inline function first_tracer(u, equations::PassiveTracerEquations)
        return Trixi.tracers(u, equations)[1]
    end
    amr_controller = ControllerThreeLevel(semi, IndicatorMax(semi, variable=first_tracer),
                                          base_level=1,
                                          med_level=2, med_threshold=0.1,
                                          max_level=2, max_threshold=0.1)
    amr_callback = AMRCallback(semi, amr_controller,
                               interval=10,
                               adapt_initial_condition=true,
                               adapt_initial_condition_only_refine=true)

    # SaveSolutionCallback writes the solution at regular intervals
    save_solution = SaveSolutionCallback(interval=100,
                                         save_initial_solution=true,
                                         save_final_solution=true,
                                         solution_variables = cons2prim)

    # CallbackSet collects all callbacks
    callbacks = CallbackSet(summary_callback,
                            analysis_callback,
                            alive_callback,
                            amr_callback,
                            save_solution,
                            stepsize_callback)

    ###############################################################################
    # create the time integrator

    # OrdinaryDiffEq's `integrator`
    integrator = init(ode, CarpenterKennedy2N54(williamson_condition=false),
                      dt=1.0, # solve needs some value here but it will be overwritten by the stepsize_callback
                      save_everystep=false, callback=callbacks);

    ###############################################################################
    # Create simulation state

    simstate = SimulationState(semi, integrator)

    return simstate
end
