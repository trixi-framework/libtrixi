# Known issues

## Missing cuda libraries

A warning similar to

```
--------------------------------------------------------------------------
Sorry!  You were supposed to get help about:
    dlopen failed
But I couldn't open the help file:
    <someJuliaPath>/share/openmpi/help-mpi-common-cuda.txt: No such file or directory.  Sorry!
--------------------------------------------------------------------------
```

hints at missing CUDA libraries, which are optional for `Trixi.jl`. You can use the environment
variable `OMPI_MCA_mpi_cuda_support=0` to prevent attempting to load the library.
