using Test

@time @testset verbose=true showtiming=true "libtrixi tests" begin
    include("test_auxiliary.jl")
    include("test_function_pointers.jl")
    include("test_interface.jl")
end
