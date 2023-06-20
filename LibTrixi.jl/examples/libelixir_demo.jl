using LibTrixi

# The function to create the simulation state needs to be named `init_simstate`
function init_simstate()
    # Create simulation state
    semi = (; mesh = "mesh", equations = "equations", solver = "solver", cache = Float64[])
    integrator = (; t = Ref(0.0), finaltime = Ref(1.0), dt = Ref(0.0), u0 = Float64[],
                    u = Float64[])
    simstate = SimulationState(semi, integrator)

    # Set up some dummy values
    (; dt, u0, u) = simstate.integrator
    dt[] = 0.3
    resize!(u0, 5)
    u0 .= 1
    resize!(u, 5)
    u .= u0

    return simstate
end
