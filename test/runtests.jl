using Test

@time @testset verbose=true showtiming=true "libtrixi tests" begin
    include("test_interface_c.jl")
end
