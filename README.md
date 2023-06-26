# libtrixi

[![Docs-dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://trixi-framework.github.io/libtrixi/dev)
[![Coveralls](https://coveralls.io/repos/github/trixi-framework/libtrixi/badge.svg)](https://coveralls.io/github/trixi-framework/libtrixi)
[![Codecov](https://codecov.io/gh/trixi-framework/libtrixi/branch/main/graph/badge.svg)](https://codecov.io/gh/trixi-framework/libtrixi)
[![License: MIT](https://img.shields.io/badge/License-MIT-success.svg)](https://opensource.org/licenses/MIT)

**Libtrixi** is an interface library for using
[Trixi.jl](https://github.com/trixi-framework/Trixi.jl) from C/C++/Fortran.

**Note: This project is in a very early stage and subject to changes without warning at any time.**

## Getting started

### Prerequisites

Currently, libtrixi is only developed and tested for Linux.
Furthermore, a local installation of `MPI`, `p4est`, and `Julia` is required.

### Get the sources

```bash
git clone git@github.com:trixi-framework/libtrixi.git
```

### Building

For building, `cmake` and its typical workflow is used.

1. It is recommended to created an out-of-source build directory, e.g.

    ```bash
    mkdir build
    cd build
    ```

2. Call cmake

    ```bash
    cmake -DCMAKE_INSTALL_PREFIX=<install_directory> ..
    ```

    `cmake` should find `MPI` and `Julia` automatically. If not, the directories
    can be specified manually.
    The `cmake` clients `ccmake` or `cmake-gui` could be useful.

    Specifying the directory `install_directory` for later installation is optional.

3. Call make

    ```bash
    make
    ```

    This will build and place `libtrixi.so` in the current directory along with its
    header and a Fortran `mod` file. Your application will have to include and link
    against these.

    Examples can be found in the `examples` subdirectory.

4. Install (optional)

    ```bash
    make install
    ```

    This will install all provided file to the specified location.

### Setting up Julia
After the library has been installed, you need to configure Julia for use with libtrixi. For
this, create a directory where all necessary files will be placed, e.g., `libtrixi-julia`.
Then, you can use the [`utils/libtrixi-init-julia`](utils/libtrixi-init-julia) tool to do
the rest for you:
```shell
# Assuming you are in still in the `build/` directory inside the repo clone
cd ..
mkdir libtrixi-julia
cd libtrixi-julia
../utils/libtrixi-init-julia ..
```
When running a program that uses libtrixi, make sure the set up the `JULIA_DEPOT_PATH`
environment variable to point to the `julia-depot` subfolder in the
`libtrixi-julia` directory. In your code, pass the path to the `libtrixi-julia` directory as
the `project_directory` argument to `trixi_initialize`.

### Testing
Go to the repository root directory and run a simple demonstrator,
```shell
LIBTRIXI_DEBUG=all \
JULIA_DEPOT_PATH=$PWD/libtrixi-julia/julia-depot \
    build/examples/simple_trixi_controller_c \
    $PWD/libtrixi-julia \
    LibTrixi.jl/examples/libelixir_tree1d_dgsem_advection_basic.jl
```
which should give you an output similar to this:
```
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
 #timesteps:                  0                run time:       7.20000000e-07 s
 Δt:             1.00000000e+00                └── GC time:    0.00000000e+00 s (0.000%)
 sim. time:      0.00000000e+00                time/DOF/rhs!:         NaN s
                                               PID:                   Inf s
 #DOF:                       64                alloc'd memory:        143.411 MiB
 #elements:                  16

 Variable:       scalar
 L2 error:       2.78684204e-06
 Linf error:     6.06474411e-06
 ∑∂S/∂U ⋅ Uₜ :  -3.46944695e-18
────────────────────────────────────────────────────────────────────────────────────────────────────

Current time step length: 0.050000

────────────────────────────────────────────────────────────────────────────────────────────────────
 Simulation running 'LinearScalarAdvectionEquation1D' with DGSEM(polydeg=3)
────────────────────────────────────────────────────────────────────────────────────────────────────
 #timesteps:                 20                run time:       1.11329306e+00 s
 Δt:             5.00000000e-02                └── GC time:    5.11113150e-02 s (0.046%)
 sim. time:      1.00000000e+00                time/DOF/rhs!:  2.58861826e-08 s
                                               PID:            1.57108461e-04 s
 #DOF:                       64                alloc'd memory:        116.126 MiB
 #elements:                  16

 Variable:       scalar
 L2 error:       6.03882964e-06
 Linf error:     3.21788773e-05
 ∑∂S/∂U ⋅ Uₜ :  -2.16706314e-09
────────────────────────────────────────────────────────────────────────────────────────────────────

 ────────────────────────────────────────────────────────────────────────────────────
              Trixi.jl                      Time                    Allocations
                                   ───────────────────────   ────────────────────────
         Tot / % measured:              1.13s /  52.4%           57.4MiB /  21.9%

 Section                   ncalls     time    %tot     avg     alloc    %tot      avg
 ────────────────────────────────────────────────────────────────────────────────────
 I/O                            3    495ms   83.5%   165ms   8.81MiB   70.0%  2.94MiB
   ~I/O~                        3    230ms   38.8%  76.7ms   1.09MiB    8.7%   372KiB
   get element variables        2    160ms   27.0%  80.2ms   1.90MiB   15.1%   975KiB
   save solution                2    105ms   17.7%  52.5ms   5.81MiB   46.2%  2.91MiB
   save mesh                    2    250ns    0.0%   125ns     0.00B    0.0%    0.00B
 analyze solution               2   98.1ms   16.5%  49.0ms   3.76MiB   29.9%  1.88MiB
 rhs!                         101    149μs    0.0%  1.47μs   6.61KiB    0.1%    67.0B
   ~rhs!~                     101   88.1μs    0.0%   872ns   6.61KiB    0.1%    67.0B
   volume integral            101   21.4μs    0.0%   212ns     0.00B    0.0%    0.00B
   interface flux             101   10.2μs    0.0%   101ns     0.00B    0.0%    0.00B
   prolong2interfaces         101   6.71μs    0.0%  66.4ns     0.00B    0.0%    0.00B
   surface integral           101   5.52μs    0.0%  54.7ns     0.00B    0.0%    0.00B
   Jacobian                   101   4.86μs    0.0%  48.1ns     0.00B    0.0%    0.00B
   prolong2boundaries         101   3.79μs    0.0%  37.5ns     0.00B    0.0%    0.00B
   reset ∂u/∂t                101   3.58μs    0.0%  35.5ns     0.00B    0.0%    0.00B
   boundary flux              101   2.37μs    0.0%  23.5ns     0.00B    0.0%    0.00B
   source terms               101   2.25μs    0.0%  22.3ns     0.00B    0.0%    0.00B
 calculate dt                  21   2.18μs    0.0%   104ns     0.00B    0.0%    0.00B
 ────────────────────────────────────────────────────────────────────────────────────
```

If you change the executable name from `simple_trixi_controller_c` to
`simple_trixi_controller_f`, you will get a near identical output. The corresponding source
files `simple_trixi_controller.c` and `simple_trixi_controller.f90` give you an idea on how
to use the C and Fortran APIs of libtrixi, and can be found in the
[`examples/`](examples/) folder.

If you just want to test the Julia part of libtrixi, i.e., LibTrixi.jl, you can also run
everything from Julia. From the repositority root, execute
```shell
JULIA_DEPOT_PATH=$PWD/libtrixi-julia/julia-depot \
    julia --project=libtrixi-julia
    examples/simple_trixi_controller.jl
```

Note: Most auxiliary output is hidden unless the environment variable `LIBTRIXI_DEBUG` is
set to `all`. Alternative values for the variable are `c` or `julia` to only show debug
statements from the C or Julia part of the library, respectively. All values are
case-sensitive and must be provided all lowercase.

## Authors
Libtrixi was initiated by
[Benedict Geihe](https://www.mi.uni-koeln.de/NumSim/)
(University of Cologne, Germany) and
[Michael Schlottke-Lakemper](https://lakemper.eu)
(RWTH Aachen University/High-Performance Computing Center Stuttgart (HLRS), Germany), who
are also its principal maintainers.

## License
Libtrixi is licensed under the MIT license (see [LICENSE.md](LICENSE.md)).

## Acknowledgments
<p align="center">
  <!-- DFG -->
  <img align="middle" src="https://user-images.githubusercontent.com/3637659/231429826-31fd7e78-19b4-4bac-8d4c-d292c6570d93.jpg" height="100" />
  <!-- BMBF -->
  <img align="middle" src="https://user-images.githubusercontent.com/3637659/231436391-b28a76a4-f027-40f9-bd28-14e3a2f3e16a.png" height="100" />
</p>

This project has benefited from funding by the Deutsche Forschungsgemeinschaft (DFG, German Research Foundation)
through the research unit FOR 5409 "Structure-Preserving Numerical Methods for Bulk- and
Interface Coupling of Heterogeneous Models (SNuBIC)" (project number 463312734).

This project has benefited from funding from the German Federal Ministry of
Education and Research through the project grant "Adaptive earth system modeling
with significantly reduced computation time for exascale supercomputers
(ADAPTEX)" (funding id: 16ME0668K).
