using LibTrixi
using OrdinaryDiffEq
using Trixi

# The function to create the simulation state needs to be named `init_simstate`
function init_simstate()

    ###############################################################################
    # semidiscretization of the linear advection equation

    advection_velocity = (0.2, -0.7)
    equations = LinearScalarAdvectionEquation2D(advection_velocity)

    # Create DG solver with polynomial degree = 3 and (local) Lax-Friedrichs/Rusanov flux as surface flux
    solver = DGSEM(polydeg=3, surface_flux=flux_lax_friedrichs)

    coordinates_min = (-1.0, -1.0) # minimum coordinates (min(x), min(y))
    coordinates_max = ( 1.0,  1.0) # maximum coordinates (max(x), max(y))

    mapping = Trixi.coordinates2mapping(coordinates_min, coordinates_max)

    trees_per_dimension = (4, 4)

    mesh = T8codeMesh(trees_per_dimension, polydeg=3,
                      mapping=mapping,
                      initial_refinement_level=1)

    # A semidiscretization collects data structures and functions for the spatial discretization
    semi = SemidiscretizationHyperbolic(mesh, equations, initial_condition_convergence_test, solver)


    ###############################################################################
    # ODE solvers, callbacks etc.

    # Create ODE problem with time span from 0.0 to 1.0
    ode = semidiscretize(semi, (0.0, 1.0));

    # At the beginning of the main loop, the SummaryCallback prints a summary of the simulation setup
    # and resets the timers
    summary_callback = SummaryCallback()

    # The AnalysisCallback allows to analyse the solution in regular intervals and prints the results
    analysis_interval = 100
    analysis_callback = AnalysisCallback(semi, interval=analysis_interval)

    alive_callback = AliveCallback(analysis_interval=analysis_interval)

    # The StepsizeCallback handles the re-calculation of the maximum Δt after each time step
    stepsize_callback = StepsizeCallback(cfl=0.5)

    # Create a CallbackSet to collect all callbacks such that they can be passed to the ODE solver
    callbacks = CallbackSet(summary_callback,
                            analysis_callback,
                            alive_callback,
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
