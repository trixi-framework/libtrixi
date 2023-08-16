module TestInterface

using Test
using LibTrixi


@testset verbose=true showtiming=true "Version information" begin

    libtrixi_version = VersionNumber(unsafe_string(trixi_version()))
    @test libtrixi_version.major == trixi_version_major()
    @test libtrixi_version.minor == trixi_version_minor()
    @test libtrixi_version.patch == trixi_version_patch()

    @test occursin("OrdinaryDiffEq", unsafe_string(trixi_version_julia()))
    @test occursin("StartUpDG", unsafe_string(trixi_version_julia_extended()))
end


libelixir = joinpath(dirname(pathof(LibTrixi)),
                     "../examples/libelixir_tree1d_dgsem_advection_basic.jl")

# initialize a simulation via API, receive a handle
handle = trixi_initialize_simulation(libelixir)

# initialize the same simulation directly from julia, get a simstate object
simstate_jl = trixi_initialize_simulation_jl(libelixir)


@testset verbose=true showtiming=true "Simulation handle" begin

    # one handle was created
    @test LibTrixi.simstate_counter[] == handle == 1

    # simstates are not the same
    @test LibTrixi.simstates[handle] != simstate_jl
end


@testset verbose=true showtiming=true "Simulation control" begin

    # do a step via API
    trixi_step(handle)

    # do a step via julia
    trixi_step_jl(simstate_jl)

    # compare time step length
    dt_c = trixi_calculate_dt(handle)
    dt_jl = trixi_calculate_dt_jl(simstate_jl)
    @test dt_c == dt_jl

    # compare finished status
    @test trixi_is_finished(handle) == 0
    @test !trixi_is_finished_jl(simstate_jl)
end

@testset verbose=true showtiming=true "Finalization" begin

    # finalize simulation from julia
    trixi_finalize_simulation_jl(simstate_jl)

    # finalize simulation from API
    trixi_finalize_simulation(handle)

    # handle is now invalid
    @test_throws ErrorException trixi_is_finished(handle)
end

end # module
