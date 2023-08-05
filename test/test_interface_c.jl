module TestInterfaceC

using Test
using Libdl
using LibTrixi

@testset verbose=true showtiming=true "C Interface" begin

    # get path of shared object, relative to LibTrixi.jl
    libtrixi_so_path = joinpath(dirname(pathof(LibTrixi)), "../../../../lib/")
    push!(Libdl.DL_LOAD_PATH, libtrixi_so_path)

    # try to load the shared object
    libtrixi_handle = dlopen("libtrixi")


    # TODO: get version and compare to something (?)
    @testset verbose=true showtiming=true "Version info" begin
        @test (@ccall "libtrixi".trixi_version_major()::Int64) == 0
        @test (@ccall "libtrixi".trixi_version_minor()::Int64) == 1
        @test (@ccall "libtrixi".trixi_version_patch()::Int64) == 0
    end


    # initialize julia from C
    @ccall "libtrixi".trixi_initialize(dirname(Base.active_project())::Cstring, C_NULL::Ptr{Cvoid})::Cvoid

    # TODO: test the simulation state handling
    #       therefore a libelexir is loaded
    libelixir_path = joinpath(dirname(pathof(LibTrixi)), "../examples/libelixir_tree1d_dgsem_advection_basic.jl")

    @testset verbose=true showtiming=true "Trixi simulation" begin

        # no simulation state handles exist yet
        @test LibTrixi.simstate_counter[] == 0

        # initialize simulation from C, get a handle to it
        handle_c = @ccall "libtrixi".trixi_initialize_simulation(libelixir_path::Cstring)::Cint
        @test LibTrixi.simstate_counter[] == handle_c == 1

        # initialize same simulation from julia, get a simstate object
        simstate_jl = trixi_initialize_simulation_jl(libelixir_path)

        # no additional handle is created
        @test LibTrixi.simstate_counter[] == handle_c == 1

        # simstate are not the same
        @test LibTrixi.simstates[handle_c] != simstate_jl

        # do a step in C
        @ccall "libtrixi".trixi_step(handle_c::Cint)::Cvoid

        # do a step in julia
        trixi_step_jl(simstate_jl)

        # compare time step length
        dt_c = @ccall "libtrixi".trixi_calculate_dt(handle_c::Cint)::Cdouble
        dt_jl = trixi_calculate_dt_jl(simstate_jl)
        @test dt_c == dt_jl

        # compare finished status
        @test (@ccall "libtrixi".trixi_is_finished(handle_c::Cint)::Cint) == 0
        @test !trixi_is_finished_jl(simstate_jl)

        # finalize simulation from julia
        trixi_finalize_simulation_jl(simstate_jl)

        # finalize simulation from C
        @ccall "libtrixi".trixi_finalize_simulation(handle_c::Cint)::Cvoid

        # handle is now invalid
        @test_throws ErrorException @ccall "libtrixi".trixi_is_finished(handle_c::Cint)::Cint
    end

    # finalize julia from C
    # segmentation fault when executing jl_atexit_hook(0)
    #@ccall "libtrixi".trixi_finalize()::Cvoid
end

end # module
