# libtrixi

Interface library for using Trixi.jl from C/C++/Fortran.

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

### Testing

Check out the `fortran_hello_world` example.