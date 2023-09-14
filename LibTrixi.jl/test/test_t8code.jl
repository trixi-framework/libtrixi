module TestT8code

using Test
using LibTrixi
using T8code


libelixir = joinpath(dirname(pathof(LibTrixi)),
                     "../examples/libelixir_t8code_2d_dgsem_advection_basic.jl")

# initialize a simulation via API, receive a handle
handle = trixi_initialize_simulation(libelixir)

# initialize the same simulation directly from julia, get a simstate object
simstate_jl = trixi_initialize_simulation_jl(libelixir)


@testset verbose=true showtiming=true "T8code mesh" begin
    # compare t8code forest
    forest_c = trixi_get_t8code_forest(handle)
    cmesh_c = trixi_get_t8code_cmesh(handle)
    cmesh_jl = t8_forest_get_cmesh(forest_c)
    @test cmesh_c === cmesh_jl
end


# finalize simulation from julia
trixi_finalize_simulation_jl(simstate_jl)

# finalize simulation from API
trixi_finalize_simulation(handle)

end # module
