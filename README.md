# libtrixi

[![Docs-stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://trixi-framework.github.io/libtrixi/stable)
[![Docs-dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://trixi-framework.github.io/libtrixi/dev)
[![Build Status](https://github.com/trixi-framework/libtrixi/workflows/CI/badge.svg)](https://github.com/trixi-framework/libtrixi/actions?query=workflow%3ACI)
[![Coveralls](https://coveralls.io/repos/github/trixi-framework/libtrixi/badge.svg)](https://coveralls.io/github/trixi-framework/libtrixi)
[![Codecov](https://codecov.io/gh/trixi-framework/libtrixi/branch/main/graph/badge.svg)](https://codecov.io/gh/trixi-framework/libtrixi)
[![License: MIT](https://img.shields.io/badge/License-MIT-success.svg)](https://opensource.org/licenses/MIT)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.8321803.svg)](https://doi.org/10.5281/zenodo.8321803)

**Libtrixi** is an interface library for using
[Trixi.jl](https://github.com/trixi-framework/Trixi.jl) from C/C++/Fortran.

**Note: This project is in an early stage and the API is still under development. 
Nevertheless, basic functionality is already implemented and actively tested.**


## Getting started

### Prerequisites

Currently, libtrixi is only developed and tested for Linux. Furthermore, the following
software packages need to be made available locally before installing libtrixi:
* [Julia](https://julialang.org/downloads/platform/) v1.8+
* C compiler with support for C11 or later (e.g., [gcc](https://gcc.gnu.org/) or [clang](https://clang.llvm.org/))
* Fortran compiler with support for Fortran 2018 or later (e.g., [gfortran](https://gcc.gnu.org/fortran/))
* [CMake](https://cmake.org/)
* MPI (e.g., [OpenMPI](https://www.open-mpi.org/) or [MPICH](https://www.mpich.org/))
* [HDF5](https://www.hdfgroup.org/solutions/hdf5/)
* [t8code](https://github.com/DLR-AMR/t8code)

### Get the sources

```bash
git clone git@github.com:trixi-framework/libtrixi.git
```

### Building

For building, `cmake` and its typical workflow is used.

1. It is recommended to create an out-of-source build directory, e.g.

    ```bash
    mkdir build
    cd build
    ```

2. Call cmake

    ```bash
    cmake -DCMAKE_BUILD_TYPE=(Debug|Release) -DCMAKE_INSTALL_PREFIX=<install_directory> ..
    ```

    `cmake` should find `MPI` and `Julia` automatically. If not, the directories
    can be specified manually.
    The `cmake` clients `ccmake` or `cmake-gui` could be useful.

    - Specifying the directory `install_directory` for later installation is optional.
    - Optional specification of build type sets some default compiler options for optimized
      or debug code

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

    This will install all provided files to the specified location.

### Setting up Julia
After the library has been installed, you need to configure Julia for use with libtrixi. For
this, create a directory where all necessary files will be placed, e.g., `libtrixi-julia`.
Then, you can use the [`utils/libtrixi-init-julia`](utils/libtrixi-init-julia) tool (also
available at `<install_directory>/bin`) to do the rest for you. A minimal example would be:

```shell
mkdir libtrixi-julia
cd libtrixi-julia
<install_directory>/bin/libtrixi-init-julia \
    --t8code-library <t8code_install_directory>/lib/libt8.so
    <install_directory>
```
Use `libtrixi-init-julia -h` to get help.

In your code, pass the path to the `libtrixi-julia` directory to `trixi_initialize`,
see the code of the examples. If you did not modify the default value for the Julia depot
when calling `libtrixi-init-julia`, libtrixi will find it automatically.
Otherwise, when running a program that uses libtrixi, you need to make sure to set the
`JULIA_DEPOT_PATH` environment variable to point to the `<julia-depot>` folder reported.

If you intend to use additional Julia packages, besides `Trixi` and `OrdinaryDiffEq`, you
will have to add them to your Julia project (i.e. use
`julia --project=<libtrixi-julia_directory>` and `import Pkg; Pkg.add(<package>)`).

### Testing

Go to some directory from where you want to run a Trixi simulation.

```shell
LIBTRIXI_DEBUG=all \
    <install_directory>/bin/simple_trixi_controller_c \
    <libtrixi-julia_directory> \
    <install_directory>/share/libtrixi/LibTrixi.jl/examples/libelixir_tree1d_dgsem_advection_basic.jl
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
everything from Julia.

```shell
JULIA_DEPOT_PATH=<julia-depot_directory> \
LIBTRIXI_DEBUG=all \
    julia --project=<libtrixi-julia_directory>
    <install_directory>/share/libtrixi/examples/simple_trixi_controller.jl
    <install_directory>/share/libtrixi/LibTrixi.jl/examples/libelixir_tree1d_dgsem_advection_basic.jl
```

Note: Most auxiliary output is hidden unless the environment variable `LIBTRIXI_DEBUG` is
set to `all`. Alternative values for the variable are `c` or `julia` to only show debug
statements from the C or Julia part of the library, respectively. All values are
case-sensitive and must be provided all lowercase.

### Linking against libtrixi
To use libtrixi in your program, you need to specify `-I$LIBTRIXI_PREFIX/include` for the
include directory with header and module files, `-L$LIBTRIXI_PREFIX/lib` for the library
directory, and `-ltrixi` for the library itself during your build process. Optionally, you
can additionally specify `-Wl,-rpath,$LIBTRIXI_PREFIX/lib` such that the runtime loader
knows where to find `libtrixi.so`. Here, `$LIBTRIXI_PREFIX` is the install prefix you
specified during the CMake configure stage with `-DCMAKE_INSTALL_PREFIX`
(see [above](#building)).

An example `Makefile` is provided with
[`examples/MakefileExternal`](examples/MakefileExternal), which can be invoked from inside
the `examples/` directory as
```shell
make -f MakefileExternal LIBTRIXI_PREFIX=path/to/libtrixi/prefix
```
to build `simple_trixi_controller_f`.

Note: On Linux and FreeBSD systems (i.e., *not* on macOS or Windows), Julia may internally
use a faster implementation for thread-local storage (TLS), which is used whenever Julia
functions such task management, garbage collection etc. are used in a multithreaded
context, or when they are themselves multithreaded. To activate the fast TLS in your
program, you need to add the file `$LIBTRIXI_PREFIX/lib/libtrixi_tls.o` to the list of files
that are linked with your main program. See `MakefileExternal` for an example of how to do
this. If you skip this step, everything will work as usual, but some things might run
slightly slower.

### Experimental support for direct compilation of the Julia sources
There is _experimental_ support for compiling the Julia sources in LibTrixi.jl to a shared
library with a C interface. This is possible with the use of the Julia package
[PackageCompiler.jl](https://github.com/JuliaLang/PackageCompiler.jl).

To try this out, perform the following steps:
1. Initialize the project directory `libtrixi-julia` using `libtrixi-init-julia` as
   described above.
2. Go to the `LibTrixi.jl/lib` directory in the repository root,
   make sure that `PROJECT_DIR` (defined in `Makefile`) points to your `libtrixi-julia` directory,
   and call `make`:
   ```shell
   cd LibTrixi.jl/lib
   make
   ```
3. Go to the `examples` folder in the repository root and compile
   `simple_trixi_controller_c`:
   ```shell
   cd examples
   make -f MakefileCompiled LIBTRIXI_PREFIX=$PWD/../LibTrixi.jl/lib/build
   ```
   This will create a `simple_trixi_controller_c` file.
4. From inside the `examples` folder you should be able to run the example (in parallel)
   with the following command:
   ```shell
   mpirun -n 2 simple_trixi_controller_c \
       ../libtrixi-julia \
       ../LibTrixi.jl/examples/libelixir_p4est2d_dgsem_euler_sedov.jl
   ```
   Optionally, you can set `LIBTRIXI_DEBUG=all` to get some debug output along the way.


## Documentation
Documentation for the current release can be found at https://trixi-framework.github.io/libtrixi,
and for the current development version at https://trixi-framework.github.io/libtrixi/dev.


## Referencing
If you use libtrixi in your own research or write a paper using results obtained
with the help of libtrixi, you can refer to libtrixi directly as
```bibtex
@misc{schlottkelakemper2023libtrixi,
  title={{L}ibtrixi: {I}nterface library for using {T}rixi.jl from {C}/{C}++/{F}ortran},
  author={Schlottke-Lakemper, Michael and Geihe, Benedict and Gassner, Gregor J},
  year={2023},
  month={09},
  howpublished={\url{https://github.com/trixi-framework/libtrixi}},
  doi={10.5281/zenodo.8321803}
}
```
Since libtrixi is based on Trixi.jl, you should also
[cite Trixi.jl](https://github.com/trixi-framework/Trixi.jl#referencing) in this case.


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
