using LibTrixi
using Trixi
using OrdinaryDiffEq

# Callable struct holding vectors with source termshydrostatic base state
struct SourceTerm
    nnodesdim::Int
    nnodes::Int
    database::Vector{Ref{Vector{Float64}}}
end

@inline function (source::SourceTerm)(u, element, i, j, t,
                                      equations::CompressibleEulerEquations2D)
    @unpack nnodesdim, nnodes = source
    index_global = (element-1) * nnodes + (j-1) * nnodesdim + i
    # massive allocations occur when directly accessing source.database[1][][1]
    du1::Vector{Float64} = source.database[1][]
    du2::Vector{Float64} = source.database[2][]
    du4::Vector{Float64} = source.database[3][]
    return SVector(du1[index_global], du2[index_global],
                   du2[index_global], du4[index_global])
end

# The function to create the simulation state needs to be named `init_simstate`
function init_simstate()

    ###############################################################################
    # semidiscretization of the compressible Euler equations

    equations = CompressibleEulerEquations2D(1.4)

    initial_condition = initial_condition_convergence_test

    solver = DGSEM(polydeg = 3, surface_flux = flux_lax_friedrichs)
    nnodesdim = Trixi.nnodes(solver)
    nnodes = nnodesdim^2

    coordinates_min = (0.0, 0.0)
    coordinates_max = (2.0, 2.0)

    cells_per_dimension = (16, 16)

    mesh = StructuredMesh(cells_per_dimension, coordinates_min, coordinates_max)
    nelements = prod(size(mesh))

    # create the database and three vectors for the source terms
    database = LibTrixiDataBaseType(undef, 3)
    database[1] = Ref(Vector{Float64}(undef, nelements*nnodes))
    database[2] = Ref(Vector{Float64}(undef, nelements*nnodes))
    database[3] = Ref(Vector{Float64}(undef, nelements*nnodes))

    source_term_database = SourceTerm(nnodesdim, nnodes, database)

    semi = SemidiscretizationHyperbolic(mesh, equations, initial_condition, solver,
                                        source_terms = source_term_database)

    ###############################################################################
    # ODE solvers, callbacks etc.

    tspan = (0.0, 2.0)
    ode = semidiscretize(semi, tspan)

    summary_callback = SummaryCallback()

    analysis_interval = 100
    analysis_callback = AnalysisCallback(semi, interval = analysis_interval)

    alive_callback = AliveCallback(analysis_interval = analysis_interval)

    save_solution = SaveSolutionCallback(interval = 100,
                                        save_initial_solution = true,
                                        save_final_solution = true,
                                        solution_variables = cons2prim)

    stepsize_callback = StepsizeCallback(cfl = 1.0)

    callbacks = CallbackSet(summary_callback,
                            analysis_callback, alive_callback,
                            save_solution,
                            stepsize_callback)

    ###############################################################################
    # create OrdinaryDiffEq's `integrator`

    integrator = init(ode,
                      CarpenterKennedy2N54(williamson_condition=false),
                      dt=1.0, # will be overwritten by the stepsize_callback
                      save_everystep=false,
                      callback=callbacks);

    ###############################################################################
    # Create simulation state

    simstate = SimulationState(semi, integrator, database)

    return simstate
end
