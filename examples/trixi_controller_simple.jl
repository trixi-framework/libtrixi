using LibTrixi

if length(ARGS) < 1
    error("ERROR: missing argument LIBELIXIR_PATH")
end

println("*** Trixi controller ***   Set up Trixi simulation")
handle = trixi_initialize_simulation(ARGS[1])

println("*** Trixi controller ***   Current time step length: ", trixi_calculate_dt(handle))

println("*** Trixi controller ***   Entering main loop")

while trixi_is_finished(handle) == 0
    trixi_step(handle)
end

println("*** Trixi controller ***   Finalize Trixi simulation")
trixi_finalize_simulation(handle)
