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
                     "../examples/libelixir_tree1d_advection_basic.jl")

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

    # compare time
    time_c = trixi_get_simulation_time(handle)
    time_jl = trixi_get_simulation_time_jl(simstate_jl)
    @test time_c == time_jl

    # compare finished status
    @test trixi_is_finished(handle) == 0
    @test !trixi_is_finished_jl(simstate_jl)

    # manually increase registries (for testing only!)
    push!(simstate_jl.registry, Vector{Float64}())
    push!(LibTrixi.simstates[handle].registry, Vector{Float64}())
    # store a vector
    test_data = [1.0, 2.0, 3.0]
    trixi_register_data(handle, Int32(1), Int32(3), pointer(test_data))
    trixi_register_data_jl(simstate_jl, 1, test_data)
    # check that the same memory is referenced
    @test pointer(simstate_jl.registry[1]) ==
        pointer(LibTrixi.simstates[handle].registry[1])
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

    nelementsglobal_c = trixi_nelementsglobal(handle)
    nelementsglobal_jl = trixi_nelementsglobal_jl(simstate_jl)
    @test nelementsglobal_c == nelementsglobal_jl

    # compare number of dofs
    ndofs_c = trixi_ndofs(handle)
    ndofs_jl = trixi_ndofs_jl(simstate_jl)
    @test ndofs_c == ndofs_jl

    ndofsglobal_c = trixi_ndofsglobal(handle)
    ndofsglobal_jl = trixi_ndofsglobal_jl(simstate_jl)
    @test ndofsglobal_c == ndofsglobal_jl

    ndofselement_c = trixi_ndofselement(handle)
    ndofselement_jl = trixi_ndofselement_jl(simstate_jl)
    @test ndofselement_c == ndofselement_jl

    # compare number of variables
    nvariables_c = trixi_nvariables(handle)
    nvariables_jl = trixi_nvariables_jl(simstate_jl)
    @test nvariables_c == nvariables_jl

    # compare number of quadrature nodes
    nnodes_c = trixi_nnodes(handle)
    nnodes_jl = trixi_nnodes_jl(simstate_jl)
    @test nnodes_c == nnodes_jl

    # compare coordinates of quadrature nodes
    data_c = zeros(nnodes_c)
    trixi_load_node_reference_coordinates(handle, pointer(data_c))
    data_jl = zeros(nnodes_jl)
    trixi_load_node_reference_coordinates_jl(simstate_jl, data_jl)
    @test data_c == data_jl

    # compare weights of quadrature nodes
    data_c = zeros(nnodes_c)
    trixi_load_node_weights(handle, pointer(data_c))
    data_jl = zeros(nnodes_jl)
    trixi_load_node_weights_jl(simstate_jl, data_jl)
    @test data_c == data_jl

    # compare element averaged values
    data_c = zeros(nelements_c)
    trixi_load_element_averaged_primitive_vars(handle, Int32(1), pointer(data_c))
    data_jl = zeros(nelements_jl)
    trixi_load_element_averaged_primitive_vars_jl(simstate_jl, 1, data_jl)
    @test data_c == data_jl

    # compare conservative variable values on all dofs
    data_c = zeros(ndofs_c)
    trixi_load_conservative_vars(handle, Int32(1), pointer(data_c))
    data_jl = zeros(ndofs_jl)
    trixi_load_conservative_vars_jl(simstate_jl, 1, data_jl)
    @test data_c == data_jl

    # compare primitive variable values on all dofs
    data_c = zeros(ndofs_c)
    trixi_load_primitive_vars(handle, Int32(1), pointer(data_c))
    data_jl = zeros(ndofs_jl)
    trixi_load_primitive_vars_jl(simstate_jl, 1, data_jl)
    @test data_c == data_jl

    # write 1.0 to first variable and compare via raw access
    data_c = fill(1.0, ndofs_c)
    trixi_store_conservative_vars(handle, Int32(1), pointer(data_c))
    data_ptr_c = trixi_get_data_pointer(handle)
    data_jl = unsafe_wrap(Array, data_ptr_c, ndofs_c)
    @test all(data_jl .== 1.0)

    # write 2.0 to first variable and compare via raw access
    data_jl = fill(2.0, ndofs_jl)
    trixi_store_conservative_vars_jl(simstate_jl, 1, data_jl)
    data_ptr_jl = trixi_get_data_pointer_jl(simstate_jl)
    data_jl = unsafe_wrap(Array, data_ptr_jl, ndofs_jl)
    @test all(data_jl .== 2.0)
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
