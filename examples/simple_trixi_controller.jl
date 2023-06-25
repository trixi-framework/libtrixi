using LibTrixi

project_dir = "libtrixi-julia"
libelixir = "LibTrixi.jl/examples/libelixir_tree1d_dgsem_advection_basic.jl"

println("*** Trixi controller ***   Set up Trixi simulation")
handle = trixi_initialize_simulation(libelixir)

println("*** Trixi controller ***   Current time step length: ", trixi_calculate_dt(handle))

println("*** Trixi controller ***   Entering main loop")

while trixi_is_finished(handle) == 0
    trixi_step(handle)
end

println("*** Trixi controller ***   Finalize Trixi simulation")
handle = trixi_finalize_simulation(handle)
