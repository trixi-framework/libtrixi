module TestInterface

using Test
using LibTrixi


@testset verbose=true showtiming=true "Version information" begin

    libtrixi_version = VersionNumber(unsafe_string(trixi_version_library()))
    @test libtrixi_version.major == trixi_version_library_major()
    @test libtrixi_version.minor == trixi_version_library_minor()
    @test libtrixi_version.patch == trixi_version_library_patch()

    @test occursin("LibTrixi", unsafe_string(trixi_version_julia()))
    @test occursin("Trixi", unsafe_string(trixi_version_julia_extended()))
    @test occursin("OrdinaryDiffEq", unsafe_string(trixi_version_julia_extended()))
end


libelixir = joinpath(dirname(pathof(LibTrixi)),
                     "../examples/libelixir_tree1d_dgsem_advection_basic.jl")

# initialize simulation directly from julia, get a simstate object
simstate_jl = trixi_initialize_simulation_jl(@__MODULE__, libelixir)

end # module
