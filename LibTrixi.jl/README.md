# LibTrixi.jl

This package contains the Julia part of
[libtrixi](https://github.com/trixi-framework/libtrixi), the interface library for using
[Trixi.jl](https://github.com/trixi-framework/Trixi.jl) from C/C++/Fortran.
It provides the necessary Julia functionality to allow controlling Trixi.jl from the C
library libtrixi.

## Usage
Install LibTrixi.jl as a normal Julia package and start the REPL. Then you can set up,
run, and finalize a simulation by running the following code:
```julia
julia> using LibTrixi

julia> libelixir = pkgdir(LibTrixi, "examples", "libelixir_demo.jl")
"/path/to/libtrixi/LibTrixi.jl/examples/libelixir_demo.jl"

julia> handle = trixi_initialize(libelixir)
Simulation state initialized
1

julia> while trixi_is_finished(handle) == 0
           trixi_step(handle)
       end
Current time: 0.3
Current time: 0.6
Current time: 0.8999999999999999
Current time: 1.0
Final time reached

julia> trixi_finalize(handle)
Simulation state finalized
```

## Authors
For author information, see the
[Authors section](https://github.com/trixi-framework/libtrixi#authors) of the main
`README.md`.

## License
For license information, see the
[License section](https://github.com/trixi-framework/libtrixi#license) of the main
`README.md`.
