module TestAuxiliary

using Test
using LibTrixi

@testset verbose=true showtiming=true "Debug output" begin

    envvar = "LIBTRIXI_DEBUG"

    # environment variable not set -> no debug output
    delete!(ENV, envvar)
    @test !LibTrixi.show_debug_output()

    # environment variable set to "all" -> debug output
    ENV[envvar] = "all"
    @test LibTrixi.show_debug_output();

    # environment variable set to "c" -> no debug output
    ENV[envvar] = "c"
    @test !LibTrixi.show_debug_output()

    # environment variable set to "julia" -> debug output
    ENV[envvar] = "julia"
    @test LibTrixi.show_debug_output()
end

end # module
