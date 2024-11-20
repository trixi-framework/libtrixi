# LibTrixi.jl

This package contains the Julia part of
[libtrixi](https://github.com/trixi-framework/libtrixi), the interface library for using
[Trixi.jl](https://github.com/trixi-framework/Trixi.jl) from C/C++/Fortran.
It provides the necessary Julia functionality to allow controlling Trixi.jl from the C
library libtrixi.

## Usage
You can add LibTrixi.jl as a Julia package via julia's REPL:

```julia
julia> using Pkg; Pkg.develop(path="path/to/LibTrixi.jl")
```

Quit and start the REPL again. Then you can set up,
run, and finalize a simulation by running the following code:
```julia
julia> using LibTrixi

julia> libelixir = pkgdir(LibTrixi, "examples", "libelixir_tree1d_advection_basic.jl")
"/path/to/libtrixi/LibTrixi.jl/examples/libelixir_tree1d_advection_basic.jl"

julia> handle = trixi_initialize_simulation(libelixir); # initialize a new simulation setup

████████╗██████╗ ██╗██╗  ██╗██╗
╚══██╔══╝██╔══██╗██║╚██╗██╔╝██║
   ██║   ██████╔╝██║ ╚███╔╝ ██║
   ██║   ██╔══██╗██║ ██╔██╗ ██║
   ██║   ██║  ██║██║██╔╝ ██╗██║
   ╚═╝   ╚═╝  ╚═╝╚═╝╚═╝  ╚═╝╚═╝

┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
│ SemidiscretizationHyperbolic                                                                     │
│ ════════════════════════════                                                                     │
│ #spatial dimensions: ………………………… 1                                                                │
│ mesh: ………………………………………………………………… TreeMesh{1, Trixi.SerialTree{1}} with length 31                  │
│ equations: …………………………………………………… LinearScalarAdvectionEquation1D                                  │
│ initial condition: ……………………………… initial_condition_convergence_test                               │
│ boundary conditions: ………………………… Trixi.BoundaryConditionPeriodic                                  │
│ source terms: …………………………………………… nothing                                                          │
│ solver: …………………………………………………………… DG                                                               │
│ total #DOFs: ……………………………………………… 64                                                               │
└──────────────────────────────────────────────────────────────────────────────────────────────────┘

<snip>

┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
│ Environment information                                                                          │
│ ═══════════════════════                                                                          │
│ #threads: ……………………………………………………… 1                                                                │
└──────────────────────────────────────────────────────────────────────────────────────────────────┘

────────────────────────────────────────────────────────────────────────────────────────────────────
 Simulation running 'LinearScalarAdvectionEquation1D' with DGSEM(polydeg=3)
────────────────────────────────────────────────────────────────────────────────────────────────────
 #timesteps:                  0                run time:       4.50000000e-07 s
 Δt:             1.00000000e+00                └── GC time:    0.00000000e+00 s (0.000%)
 sim. time:      0.00000000e+00                time/DOF/rhs!:         NaN s
                                               PID:                   Inf s
 #DOF:                       64                alloc'd memory:         66.831 MiB
 #elements:                  16

 Variable:       scalar
 L2 error:       2.78684204e-06
 Linf error:     6.06474411e-06
 ∑∂S/∂U ⋅ Uₜ :  -3.46944695e-18
────────────────────────────────────────────────────────────────────────────────────────────────────


julia> while trixi_is_finished(handle) == 0 # run time stepping loop
           trixi_step(handle)
       end

────────────────────────────────────────────────────────────────────────────────────────────────────
 Simulation running 'LinearScalarAdvectionEquation1D' with DGSEM(polydeg=3)
────────────────────────────────────────────────────────────────────────────────────────────────────
 #timesteps:                 20                run time:       8.15826500e-03 s
 Δt:             5.00000000e-02                └── GC time:    0.00000000e+00 s (0.000%)
 sim. time:      1.00000000e+00                time/DOF/rhs!:  2.04079350e-08 s
                                               PID:            1.23799675e-06 s
 #DOF:                       64                alloc'd memory:         67.009 MiB
 #elements:                  16

 Variable:       scalar
 L2 error:       6.03882964e-06
 Linf error:     3.21788773e-05
 ∑∂S/∂U ⋅ Uₜ :  -2.16706314e-09
────────────────────────────────────────────────────────────────────────────────────────────────────


julia> trixi_finalize_simulation(handle) # do some cleanup and show timers
 ────────────────────────────────────────────────────────────────────────────────────
              Trixi.jl                      Time                    Allocations
                                   ───────────────────────   ────────────────────────
         Tot / % measured:             9.26ms /  21.4%            222KiB /  32.5%

 Section                   ncalls     time    %tot     avg     alloc    %tot      avg
 ────────────────────────────────────────────────────────────────────────────────────
 I/O                            3   1.52ms   76.6%   506μs   42.9KiB   59.5%  14.3KiB
   save solution                2    789μs   39.8%   394μs   23.0KiB   31.8%  11.5KiB
   ~I/O~                        3    721μs   36.4%   240μs   16.8KiB   23.3%  5.61KiB
   get element variables        2   7.70μs    0.4%  3.85μs   3.16KiB    4.4%  1.58KiB
   save mesh                    2   60.0ns    0.0%  30.0ns     0.00B    0.0%    0.00B
 analyze solution               2    341μs   17.2%   171μs   22.6KiB   31.3%  11.3KiB
 rhs!                         101    121μs    6.1%  1.20μs   6.61KiB    9.2%    67.0B
   ~rhs!~                     101   64.6μs    3.3%   640ns   6.61KiB    9.2%    67.0B
   volume integral            101   22.4μs    1.1%   221ns     0.00B    0.0%    0.00B
   interface flux             101   8.56μs    0.4%  84.8ns     0.00B    0.0%    0.00B
   prolong2interfaces         101   6.25μs    0.3%  61.9ns     0.00B    0.0%    0.00B
   surface integral           101   4.26μs    0.2%  42.2ns     0.00B    0.0%    0.00B
   Jacobian                   101   4.11μs    0.2%  40.7ns     0.00B    0.0%    0.00B
   prolong2boundaries         101   3.28μs    0.2%  32.5ns     0.00B    0.0%    0.00B
   reset ∂u/∂t                101   3.16μs    0.2%  31.3ns     0.00B    0.0%    0.00B
   boundary flux              101   2.38μs    0.1%  23.6ns     0.00B    0.0%    0.00B
   source terms               101   2.25μs    0.1%  22.3ns     0.00B    0.0%    0.00B
 calculate dt                  21   1.23μs    0.1%  58.6ns     0.00B    0.0%    0.00B
 ────────────────────────────────────────────────────────────────────────────────────
```

## Documentation
For more information on LibTrixi.jl, please refer to the
[main documentation](https://trixi-framework.github.io/libtrixi) of libtrixi.

## Authors
For author information, see the
[Authors section](https://github.com/trixi-framework/libtrixi#authors) of the main
`README.md`.

## License
For license information, see the
[License section](https://github.com/trixi-framework/libtrixi#license) of the main
`README.md`.
