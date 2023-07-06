
using LibTrixi
using Trixi
using OrdinaryDiffEq

# The function to create the simulation state needs to be named `init_simstate`
function init_simstate()

    ###############################################################################
    # semidiscretization of the compressible Euler equations

    equations = CompressibleEulerEquations2D(1.4)

    initial_condition = initial_condition_convergence_test

    source_terms = source_terms_convergence_test

    boundary_condition = BoundaryConditionDirichlet(initial_condition)

    boundary_conditions = (x_neg=boundary_condition,
                          x_pos=boundary_condition,
                          y_neg=boundary_condition,
                          y_pos=boundary_condition,)

    solver = DGSEM(polydeg=3, surface_flux=flux_lax_friedrichs)

    coordinates_min = (0.0, 0.0)
    coordinates_max = (2.0, 2.0)

    mesh = TreeMesh(coordinates_min, coordinates_max,
                    initial_refinement_level=4,
                    n_cells_max=10_000)

    semi = SemidiscretizationHyperbolic(mesh, equations, initial_condition, solver,
                                        source_terms=source_terms,
                                        boundary_conditions=boundary_conditions)


    ###############################################################################
    # ODE solvers, callbacks etc.

    tspan = (0.0, 1.0)
    ode = semidiscretize(semi, tspan)

    summary_callback = SummaryCallback()

    analysis_interval = 100
    #analysis_callback = AnalysisCallback(semi, interval=analysis_interval)

    alive_callback = AliveCallback(analysis_interval=analysis_interval)

    stepsize_callback = StepsizeCallback(cfl=0.8)

    callbacks = CallbackSet(summary_callback,
                            alive_callback,
                            stepsize_callback)


    ###############################################################################
    # create the time integrator

    integrator = init(ode, CarpenterKennedy2N54(williamson_condition=false),
                      dt=1.0, # solve needs some value here but it will be overwritten by the stepsize_callback
                      save_everystep=false, callback=callbacks);


    ###############################################################################
    # Create simulation state

    simstate = SimulationState(semi, integrator)

    return simstate

end
