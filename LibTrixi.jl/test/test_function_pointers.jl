module TestFunctionPointers

using Test
using LibTrixi

@testset verbose=true showtiming=true "Setup cfptr" begin

    cfptr_symbols = names(LibTrixi) |> filter(x -> endswith(String(x), "_cfptr"))

    for cfptr in map(x -> getfield(LibTrixi, x)(), cfptr_symbols)
        @test cfptr isa Ptr{Nothing}
        @test cfptr != C_NULL
    end
end

end # module
