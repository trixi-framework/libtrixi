module TestInterface

using Test
using LibTrixi


@testset verbose=true showtiming=true "Version information" begin

    libtrixi_version = VersionNumber(unsafe_string(trixi_version_library()))
    @test libtrixi_version.major == trixi_version_library_major()
    @test libtrixi_version.minor == trixi_version_library_minor()
    @test libtrixi_version.patch == trixi_version_library_patch()

    @test occursin("OrdinaryDiffEq", unsafe_string(trixi_version_julia()))
    @test occursin("Trixi", unsafe_string(trixi_version_julia()))
    @test occursin("StartUpDG", unsafe_string(trixi_version_julia_extended()))
end

@testset verbose=true showtiming=true "Evaluate string as code (trixi_eval_string)" begin
    # We can't really do much more than a smoke test, since the C API does not return
    # anything useful
    @test_throws UndefVarError trixi_eval_julia(Cstring(pointer("wololo")))
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

    # using a non-existent handle
    @test_throws ErrorException trixi_is_finished(Int32(42))
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


@testset verbose=true showtiming=true "Data access" begin

    # compare number of dimensions
    ndims_c = trixi_ndims(handle)
    ndims_jl = trixi_ndims_jl(simstate_jl)
    @test ndims_c == ndims_jl

    # compare number of elements
    nelements_c = trixi_nelements(handle)
    nelements_jl = trixi_nelements_jl(simstate_jl)
    @test nelements_c == nelements_jl

    nelements_global_c = trixi_nelements_global(handle)
    nelements_global_jl = trixi_nelements_global_jl(simstate_jl)
    @test nelements_global_c == nelements_global_jl

    # compare number of dofs
    ndofs_c = trixi_ndofs(handle)
    ndofs_jl = trixi_ndofs_jl(simstate_jl)
    @test ndofs_c == ndofs_jl

    ndofs_global_c = trixi_ndofs_global(handle)
    ndofs_global_jl = trixi_ndofs_global_jl(simstate_jl)
    @test ndofs_global_c == ndofs_global_jl

    ndofs_element_c = trixi_ndofs_element(handle)
    ndofs_element_jl = trixi_ndofs_element_jl(simstate_jl)
    @test ndofs_element_c == ndofs_element_jl

    # compare number of variables
    nvariables_c = trixi_nvariables(handle)
    nvariables_jl = trixi_nvariables_jl(simstate_jl)
    @test nvariables_c == nvariables_jl

    # compare cell averaged values
    data_c = zeros(nelements_c)
    trixi_load_cell_averages(pointer(data_c), Int32(1), handle)
    data_jl = zeros(nelements_jl)
    trixi_load_cell_averages_jl(data_jl, 1, simstate_jl)
    @test data_c == data_jl

    # compare primitive variable values on all dofs
    data_c = zeros(ndofs_c)
    trixi_load_prim(pointer(data_c), Int32(1), handle)
    data_jl = zeros(ndofs_jl)
    trixi_load_prim_jl(data_jl, 1, simstate_jl)
    @test data_c == data_jl
end


@testset verbose=true showtiming=true "Finalization" begin

    # finalize simulation from julia
    trixi_finalize_simulation_jl(simstate_jl)

    # finalize simulation from API
    trixi_finalize_simulation(handle)

    # handle is now invalid
    @test_throws ErrorException trixi_is_finished(handle)

    # simulation cannot be finalized a second time
    @test_throws ErrorException trixi_finalize_simulation(handle)
end

end # module
