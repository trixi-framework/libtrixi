using LibTrixi
using OrdinaryDiffEq
using Trixi

# Warm bubble test case from
# - Wicker, L. J., and Skamarock, W. C. (1998)
#   A time-splitting scheme for the elastic equations incorporating 
#   second-order Runge–Kutta time differencing
#   [DOI: 10.1175/1520-0493(1998)126%3C1992:ATSSFT%3E2.0.CO;2](https://doi.org/10.1175/1520-0493(1998)126%3C1992:ATSSFT%3E2.0.CO;2)
# See also
# - Bryan and Fritsch (2002)
#   A Benchmark Simulation for Moist Nonhydrostatic Numerical Models
#   [DOI: 10.1175/1520-0493(2002)130<2917:ABSFMN>2.0.CO;2](https://doi.org/10.1175/1520-0493(2002)130<2917:ABSFMN>2.0.CO;2)
# - Carpenter, Droegemeier, Woodward, Hane (1990)
#   Application of the Piecewise Parabolic Method (PPM) to 
#   Meteorological Modeling
#   [DOI: 10.1175/1520-0493(1990)118<0586:AOTPPM>2.0.CO;2](https://doi.org/10.1175/1520-0493(1990)118<0586:AOTPPM>2.0.CO;2)
struct WarmBubbleSetup
    # Physical constants
    g::Float64       # gravity of earth
    c_p::Float64     # heat capacity for constant pressure (dry air)
    c_v::Float64     # heat capacity for constant volume (dry air)
    gamma::Float64   # heat capacity ratio (dry air)

    function WarmBubbleSetup(; g = 9.81, c_p = 1004.0, c_v = 717.0, gamma = c_p / c_v)
        new(g, c_p, c_v, gamma)
    end
end

# Initial condition
function (setup::WarmBubbleSetup)(x, t, equations::CompressibleEulerEquations2D)
    @unpack g, c_p, c_v = setup

    # center of perturbation
    center_x = 10000.0
    center_z = 2000.0
    # radius of perturbation
    radius = 2000.0
    # distance of current x to center of perturbation
    r = sqrt((x[1] - center_x)^2 + (x[2] - center_z)^2)

    # perturbation in potential temperature
    potential_temperature_ref = 300.0
    potential_temperature_perturbation = 0.0
    if r <= radius
        potential_temperature_perturbation = 2 * cospi(0.5 * r / radius)^2
    end
    potential_temperature = potential_temperature_ref + potential_temperature_perturbation

    # Exner pressure, solves hydrostatic equation for x[2]
    exner = 1 - g / (c_p * potential_temperature) * x[2]

    # pressure
    p_0 = 100_000.0  # reference pressure
    R = c_p - c_v    # gas constant (dry air)
    p = p_0 * exner^(c_p / R)

    # temperature
    T = potential_temperature * exner

    # density
    rho = p / (R * T)

    v1 = 20.0
    v2 = 0.0
    E = c_v * T + 0.5 * (v1^2 + v2^2)
    return SVector(rho, rho * v1, rho * v2, rho * E)
end

# Source terms
@inline function (setup::WarmBubbleSetup)(u, x, t, equations::CompressibleEulerEquations2D)
    @unpack g = setup
    rho, _, rho_v2, _ = u
    return SVector(zero(eltype(u)), zero(eltype(u)), -g * rho, -g * rho_v2)
end


# The function to create the simulation state needs to be named `init_simstate`
function init_simstate()

    ###############################################################################
    # semidiscretization of the compressible Euler equations
    warm_bubble_setup = WarmBubbleSetup()

    equations = CompressibleEulerEquations2D(warm_bubble_setup.gamma)

    boundary_conditions = (x_neg = boundary_condition_periodic,
                        x_pos = boundary_condition_periodic,
                        y_neg = boundary_condition_slip_wall,
                        y_pos = boundary_condition_slip_wall)

    polydeg = 3
    basis = LobattoLegendreBasis(polydeg)

    # This is a good estimate for the speed of sound in this example.
    # Other values between 300 and 400 should work as well.
    surface_flux = FluxLMARS(340.0)

    volume_flux = flux_kennedy_gruber
    volume_integral = VolumeIntegralFluxDifferencing(volume_flux)

    solver = DGSEM(basis, surface_flux, volume_integral)

    coordinates_min = (0.0, 0.0)
    coordinates_max = (20_000.0, 10_000.0)

    # Same coordinates as in examples/structured_2d_dgsem/elixir_euler_warm_bubble.jl
    # However TreeMesh will generate a 20_000 x 20_000 square domain instead
    mesh = TreeMesh(coordinates_min, coordinates_max,
                    initial_refinement_level = 6,
                    n_cells_max = 100_000,
                    periodicity = (true, false))

    semi = SemidiscretizationHyperbolic(mesh, equations, warm_bubble_setup, solver,
                                        source_terms = warm_bubble_setup,
                                        boundary_conditions = boundary_conditions)

    ###############################################################################
    # ODE solvers, callbacks etc.

    tspan = (0.0, 1000.0)  # 1000 seconds final time

    ode = semidiscretize(semi, tspan)

    summary_callback = SummaryCallback()

    analysis_interval = 1000

    analysis_callback = AnalysisCallback(semi, interval = analysis_interval,
                                        extra_analysis_errors = (:entropy_conservation_error,))

    alive_callback = AliveCallback(analysis_interval = analysis_interval)

    save_solution = SaveSolutionCallback(interval = analysis_interval,
                                        save_initial_solution = true,
                                        save_final_solution = true,
                                        output_directory = "out_bubble",
                                        solution_variables = cons2prim)

    @inline function Tpot(u, equations::CompressibleEulerEquations2D)
        rho, _, _, p = cons2prim(u, equations)
        exner = (p / 100_000)^(1-inv(warm_bubble_setup.gamma))
        T = p / rho / (warm_bubble_setup.c_p - warm_bubble_setup.c_v)
        return T / exner
    end
    amr_indicator = IndicatorLöhner(semi, variable = Tpot)
    amr_controller = ControllerThreeLevel(semi, amr_indicator,
                                        base_level = 4,
                                        med_level = 6, med_threshold = 0.0002,
                                        max_level = 8, max_threshold = 0.0005)
    amr_callback = AMRCallback(semi, amr_controller,
                            interval = 50,
                            adapt_initial_condition = true,
                            adapt_initial_condition_only_refine = true)

    stepsize_callback = StepsizeCallback(cfl = 1.0)

    callbacks = CallbackSet(summary_callback,
                            analysis_callback,
                            alive_callback,
                            save_solution,
                            amr_callback,
                            stepsize_callback)

    ###############################################################################
    # create OrdinaryDiffEq's time integrator
    integrator = init(ode,
                      CarpenterKennedy2N54(williamson_condition=false),
                      dt=1.0, # solve needs some value here but it will be overwritten by the stepsize_callback
                      save_everystep=false,
                      callback=callbacks);

    ###############################################################################
    # Create simulation state
    simstate = SimulationState(semi, integrator)

    return simstate
end
