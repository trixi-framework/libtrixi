# libtrixi

[![Docs-dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://trixi-framework.github.io/libtrixi/dev)
[![Coveralls](https://coveralls.io/repos/github/trixi-framework/libtrixi/badge.svg)](https://coveralls.io/github/trixi-framework/libtrixi)
[![Codecov](https://codecov.io/gh/trixi-framework/libtrixi/branch/main/graph/badge.svg)](https://codecov.io/gh/trixi-framework/libtrixi)
[![License: MIT](https://img.shields.io/badge/License-MIT-success.svg)](https://opensource.org/licenses/MIT)

**Libtrixi** is an interface library for using Trixi.jl from C/C++/Fortran.

**Note: This project is in a very early stage and subject to changes without warning at any time.**

## Getting started

### Prerequisites

Currently, libtrixi is only developed and tested for Linux.
Furthermore, a local installation of `MPI`,
[`p4est`](https://github.com/cburstedde/p4est) (see steps 5-7 in its README), and
[`Julia`](https://julialang.org/downloads/platform/) is required.

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
    cmake -DCMAKE_BUILD_TYPE=(debug|release) -DCMAKE_INSTALL_PREFIX=<install_directory> ..
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
    --p4est-library <p4est_install_directory>/lib/libp4est.so
    <install_directory>
```

Use `libtrixi-init-julia -h` to get help.
When running a program that uses libtrixi, make sure to set up the `JULIA_DEPOT_PATH`
environment variable to point to the `<julia-depot>` folder reported. In your code, pass
the path to the `libtrixi-julia` directory to `trixi_initialize`, see the code of the
examples.

### Testing

Go to some directory from where you want to run a Trixi simulation.

```shell
LIBTRIXI_DEBUG=all \
JULIA_DEPOT_PATH=<julia-depot> \
    <install_directory>/bin/simple_trixi_controller_c \
    <libtrixi-julia_directory> \
    <install_directory>/share/libtrixi/LibTrixi.jl/examples/libelixir_tree1d_dgsem_advection_basic.jl
```

This will run a C-executable controlling a Trixi simulation, similar to the example at
[Trixi.jl](https://github.com/trixi-framework/Trixi.jl).

If you change the executable name from `simple_trixi_controller_c` to
`simple_trixi_controller_f`, you will get a near identical output. The corresponding source
files `simple_trixi_controller.c` and `simple_trixi_controller.f90` give you an idea on how
to use the C and Fortran APIs of libtrixi, and can be found in the
[`examples/`](examples/) folder.

If you just want to test the Julia part of libtrixi, i.e., LibTrixi.jl, you can also run
everything from Julia. From the repository root, execute
```shell
JULIA_DEPOT_PATH=$PWD/libtrixi-julia/julia-depot \
    julia --project=<libtrixi-julia_directory>
    <install_directory>/share/libtrixi/LibTrixi.jl/examples/simple_trixi_controller.jl
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
