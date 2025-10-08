# An idealized baroclinic instability test case
#
# Note that this libelixir is based on the original baroclinic instability elixir by
# Erik Faulhaber for Trixi.jl
# Source: https://github.com/trixi-framework/Trixi.jl/blob/main/examples/p4est_3d_dgsem/elixir_euler_baroclinic_instability.jl
#
# References:
# - Paul A. Ullrich, Thomas Melvin, Christiane Jablonowski, Andrew Staniforth (2013)
#   A proposed baroclinic wave test case for deep- and shallow-atmosphere dynamical cores
#   https://doi.org/10.1002/qj.2241

using OrdinaryDiffEq
using Trixi
using LinearAlgebra
using LibTrixi


# Callable struct holding vectors with source terms
struct SourceTerm
    nnodesdim::Int
    registry::LibTrixiDataRegistry
end

# We overwrite Trixi.jl's internal method here such that it calls source_terms with indices
function Trixi.calc_sources!(du, u, t, source_terms::SourceTerm,
                             equations::CompressibleEulerEquations3D, dg::DG, cache)
    @unpack node_coordinates = cache.elements
    Trixi.@threaded for element in eachelement(dg, cache)
        for k in eachnode(dg), j in eachnode(dg), i in eachnode(dg)
            u_local = Trixi.get_node_vars(u, equations, dg, i, j, k, element)
            du_local = source_terms(u_local, i, j, k, element, t, equations)
            #x_local = Trixi.get_node_coords(node_coordinates, equations, dg,
            #                                i, j, k, element)
            #du_local_ref = source_terms_baroclinic_instability(u_local, x_local, t,
            #                                                   equations)
            Trixi.add_to_node_vars!(du, du_local, equations, dg, i, j, k, element)
        end
    end
    return nothing
end

@inline function (source::SourceTerm)(u, i, j, k, element, t,
                                      equations::CompressibleEulerEquations3D)
    @unpack nnodesdim = source
    index_global = (element-1) * nnodesdim^3 + (k-1) * nnodesdim^2 + (j-1) * nnodesdim + i
    du2::Vector{Float64} = source.registry[1]
    du3::Vector{Float64} = source.registry[2]
    du4::Vector{Float64} = source.registry[3]
    du5::Vector{Float64} = source.registry[4]
    return SVector(zero(eltype(u)), du2[index_global], du3[index_global],
                   du4[index_global], du5[index_global])
end


# Initial condition for an idealized baroclinic instability test
# https://doi.org/10.1002/qj.2241, Section 3.2 and Appendix A
function initial_condition_baroclinic_instability(x, t,
                                                  equations::CompressibleEulerEquations3D)
    lon, lat, r = cartesian_to_sphere(x)
    radius_earth = 6.371229e6
    # Make sure that the r is not smaller than radius_earth
    z = max(r - radius_earth, 0.0)

    # Unperturbed basic state
    rho, u, p = basic_state_baroclinic_instability_longitudinal_velocity(lon, lat, z)

    # Stream function type perturbation
    u_perturbation, v_perturbation = perturbation_stream_function(lon, lat, z)

    u += u_perturbation
    v = v_perturbation

    # Convert spherical velocity to Cartesian
    v1 = -sin(lon) * u - sin(lat) * cos(lon) * v
    v2 = cos(lon) * u - sin(lat) * sin(lon) * v
    v3 = cos(lat) * v

    return prim2cons(SVector(rho, v1, v2, v3, p), equations)
end

function cartesian_to_sphere(x)
    r = norm(x)
    lambda = atan(x[2], x[1])
    if lambda < 0
        lambda += 2 * pi
    end
    phi = asin(x[3] / r)

    return lambda, phi, r
end

# Unperturbed balanced steady-state.
# Returns primitive variables with only the velocity in longitudinal direction (rho, u, p).
# The other velocity components are zero.
function basic_state_baroclinic_instability_longitudinal_velocity(lon, lat, z)
    # Parameters from Table 1 in the paper
    # Corresponding names in the paper are commented
    radius_earth = 6.371229e6  # a
    half_width_parameter = 2           # b
    gravitational_acceleration = 9.80616     # g
    k = 3           # k
    surface_pressure = 1e5         # p₀
    gas_constant = 287         # R
    surface_equatorial_temperature = 310.0       # T₀ᴱ
    surface_polar_temperature = 240.0       # T₀ᴾ
    lapse_rate = 0.005       # Γ
    angular_velocity = 7.29212e-5  # Ω

    # Distance to the center of the Earth
    r = z + radius_earth

    # In the paper: T₀
    temperature0 = 0.5 * (surface_equatorial_temperature + surface_polar_temperature)
    # In the paper: A, B, C, H
    const_a = 1 / lapse_rate
    const_b = (temperature0 - surface_polar_temperature) /
              (temperature0 * surface_polar_temperature)
    const_c = 0.5 * (k + 2) * (surface_equatorial_temperature - surface_polar_temperature) /
              (surface_equatorial_temperature * surface_polar_temperature)
    const_h = gas_constant * temperature0 / gravitational_acceleration

    # In the paper: (r - a) / bH
    scaled_z = z / (half_width_parameter * const_h)

    # Temporary variables
    temp1 = exp(lapse_rate / temperature0 * z)
    temp2 = exp(-scaled_z^2)

    # In the paper: ̃τ₁, ̃τ₂
    tau1 = const_a * lapse_rate / temperature0 * temp1 +
           const_b * (1 - 2 * scaled_z^2) * temp2
    tau2 = const_c * (1 - 2 * scaled_z^2) * temp2

    # In the paper: ∫τ₁(r') dr', ∫τ₂(r') dr'
    inttau1 = const_a * (temp1 - 1) + const_b * z * temp2
    inttau2 = const_c * z * temp2

    # Temporary variables
    temp3 = r / radius_earth * cos(lat)
    temp4 = temp3^k - k / (k + 2) * temp3^(k + 2)

    # In the paper: T
    temperature = 1 / ((r / radius_earth)^2 * (tau1 - tau2 * temp4))

    # In the paper: U, u (zonal wind, first component of spherical velocity)
    big_u = gravitational_acceleration / radius_earth * k * temperature * inttau2 *
            (temp3^(k - 1) - temp3^(k + 1))
    temp5 = radius_earth * cos(lat)
    u = -angular_velocity * temp5 + sqrt(angular_velocity^2 * temp5^2 + temp5 * big_u)

    # Hydrostatic pressure
    p = surface_pressure *
        exp(-gravitational_acceleration / gas_constant * (inttau1 - inttau2 * temp4))

    # Density (via ideal gas law)
    rho = p / (gas_constant * temperature)

    return rho, u, p
end

# Perturbation as in Equations 25 and 26 of the paper (analytical derivative)
function perturbation_stream_function(lon, lat, z)
    # Parameters from Table 1 in the paper
    # Corresponding names in the paper are commented
    perturbation_radius = 1 / 6      # d₀ / a
    perturbed_wind_amplitude = 1.0      # Vₚ
    perturbation_lon = pi / 9     # Longitude of perturbation location
    perturbation_lat = 2 * pi / 9 # Latitude of perturbation location
    pertz = 15000    # Perturbation height cap

    # Great circle distance (d in the paper) divided by a (radius of the Earth)
    # because we never actually need d without dividing by a
    great_circle_distance_by_a = acos(sin(perturbation_lat) * sin(lat) +
                                      cos(perturbation_lat) * cos(lat) *
                                      cos(lon - perturbation_lon))

    # In the first case, the vertical taper function is per definition zero.
    # In the second case, the stream function is per definition zero.
    if z > pertz || great_circle_distance_by_a > perturbation_radius
        return 0.0, 0.0
    end

    # Vertical tapering of stream function
    perttaper = 1.0 - 3 * z^2 / pertz^2 + 2 * z^3 / pertz^3

    # sin/cos(pi * d / (2 * d_0)) in the paper
    sin_, cos_ = sincos(0.5 * pi * great_circle_distance_by_a / perturbation_radius)

    # Common factor for both u and v
    factor = 16 / (3 * sqrt(3)) * perturbed_wind_amplitude * perttaper * cos_^3 * sin_

    u_perturbation = -factor * (-sin(perturbation_lat) * cos(lat) +
                      cos(perturbation_lat) * sin(lat) * cos(lon - perturbation_lon)) /
                     sin(great_circle_distance_by_a)

    v_perturbation = factor * cos(perturbation_lat) * sin(lon - perturbation_lon) /
                     sin(great_circle_distance_by_a)

    return u_perturbation, v_perturbation
end

@inline function source_terms_baroclinic_instability(u, x, t,
                                                     equations::CompressibleEulerEquations3D)
    radius_earth = 6.371229e6  # a
    gravitational_acceleration = 9.80616     # g
    angular_velocity = 7.29212e-5  # Ω

    r = norm(x)
    # Make sure that r is not smaller than radius_earth
    z = max(r - radius_earth, 0.0)
    r = z + radius_earth

    du1 = zero(eltype(u))

    # Gravity term
    temp = -gravitational_acceleration * radius_earth^2 / r^3
    du2 = temp * u[1] * x[1]
    du3 = temp * u[1] * x[2]
    du4 = temp * u[1] * x[3]
    du5 = temp * (u[2] * x[1] + u[3] * x[2] + u[4] * x[3])

    # Coriolis term, -2Ω × ρv = -2 * angular_velocity * (0, 0, 1) × u[2:4]
    du2 -= -2 * angular_velocity * u[3]
    du3 -= 2 * angular_velocity * u[2]

    return SVector(du1, du2, du3, du4, du5)
end


# The function to create the simulation state needs to be named `init_simstate`
function init_simstate()

    # compressible euler equations
    gamma = 1.4
    equations = CompressibleEulerEquations3D(gamma)

    # setup of the problem
    initial_condition = initial_condition_baroclinic_instability

    boundary_conditions = Dict(:inside => boundary_condition_slip_wall,
                               :outside => boundary_condition_slip_wall)

    # estimate for the speed of sound
    surface_flux = FluxLMARS(340)
    volume_flux = flux_kennedy_gruber
    solver = DGSEM(polydeg = 5, surface_flux = surface_flux,
                   volume_integral = VolumeIntegralFluxDifferencing(volume_flux))

    # for nice results, use 4 and 8 here
    lat_lon_levels = 2
    layers = 4
    mesh = Trixi.T8codeMeshCubedSphere(lat_lon_levels, layers, 6.371229e6, 30000.0,
                                       polydeg = 5, initial_refinement_level = 0)

    # create the data registry and four vectors for the source terms
    registry = LibTrixiDataRegistry(undef, 4)

    nnodesdim = Trixi.nnodes(solver)
    nnodes = nnodesdim^3
    nelements = Trixi.ncells(mesh)

    # provide some data because calc_sources! will already be called during initialization
    # Note: the data pointers in the registry will be overwritten before the first real use
    registry[1] = zeros(Float64, nelements*nnodes)
    registry[2] = zeros(Float64, nelements*nnodes)
    registry[3] = zeros(Float64, nelements*nnodes)
    registry[4] = zeros(Float64, nelements*nnodes)

    source_term_data_registry = SourceTerm(nnodesdim, registry)

    semi = SemidiscretizationHyperbolic(mesh, equations, initial_condition, solver,
                                        source_terms = source_term_data_registry,
                                        boundary_conditions = boundary_conditions)

    # for nice results, use 10 days
    days = 0.02
    tspan = (0.0, days * 24 * 60 * 60.0)

    ode = semidiscretize(semi, tspan)

    summary_callback = SummaryCallback()

    analysis_interval = 5000
    analysis_callback = AnalysisCallback(semi, interval = analysis_interval)

    alive_callback = AliveCallback(analysis_interval = analysis_interval)

    save_solution = SaveSolutionCallback(interval = 500,
                                         save_initial_solution = true,
                                         save_final_solution = true,
                                         solution_variables = cons2prim,
                                         output_directory = "out_baroclinic")

    callbacks = CallbackSet(summary_callback,
                            analysis_callback,
                            alive_callback,
                            save_solution)

    # use a Runge-Kutta method with automatic (error based) time step size control
    integrator = init(ode, RDPK3SpFSAL49(thread = Trixi.False());
                      abstol = 1.0e-6, reltol = 1.0e-6,
                      ode_default_options()..., callback = callbacks, maxiters=1e7);

    # create simulation state
    simstate = SimulationState(semi, integrator, registry)

    return simstate
end
