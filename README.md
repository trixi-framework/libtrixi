# libtrixi

[![Docs-dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://trixi-framework.github.io/libtrixi/dev)
[![Coveralls](https://coveralls.io/repos/github/trixi-framework/libtrixi/badge.svg)](https://coveralls.io/github/trixi-framework/libtrixi)
[![Codecov](https://codecov.io/gh/trixi-framework/libtrixi/branch/main/graph/badge.svg)](https://codecov.io/gh/trixi-framework/libtrixi)
[![License: MIT](https://img.shields.io/badge/License-MIT-success.svg)](https://opensource.org/licenses/MIT)

**Libtrixi** is an interface library for using Trixi.jl from C/C++/Fortran.

**Note: This project is in a very early stage and subject to changes without warning at any time.**

## Getting started

### Prerequisites

A local installation of `MPI` and `Julia` is required.

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
environment variable to point to the `JULIA_DEPOT_LIBTRIXI` subfolder in the
`libtrixi-julia` directory. In your code, pass the path to the `libtrixi-julia` directory as
the `project_directory` argument to `trixi_initialize`.

### Testing

Go to the repository root directory and run a simple demonstrator:
```shell
cd ..
JULIA_DEPOT_PATH=$PWD/libtrixi-julia/JULIA_DEPOT_LIBTRIXI \
    build/examples/simple_trixi_controller \
    $PWD/libtrixi-julia \
    LibTrixi.jl/examples/libelixir_demo.jl
```

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
