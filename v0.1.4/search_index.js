var documenterSearchIndex = {"docs":
[{"location":"reference-julia/#Julia-API","page":"Julia","title":"Julia API","text":"","category":"section"},{"location":"reference-julia/","page":"Julia","title":"Julia","text":"This page documents the Julia part of libtrixi, which is implemented in the LibTrixi.jl package. LibTrixi.jl provides Julia-based wrappers around Trixi.jl, making simulations controllable through a defined API.","category":"page"},{"location":"reference-julia/","page":"Julia","title":"Julia","text":"note: Internal and development use only\nThe Julia API provided by LibTrixi.jl is only provided for internal use by libtrixi and to facilitate easier development and debugging of new library features. It is not intended to be used by Julia developers: They should directly utilize Trixi.jl to benefit from its Julia-native implementation.","category":"page"},{"location":"reference-julia/","page":"Julia","title":"Julia","text":"CurrentModule = LibTrixi","category":"page"},{"location":"reference-julia/","page":"Julia","title":"Julia","text":"Modules = [LibTrixi]","category":"page"},{"location":"reference-julia/#LibTrixi.SimulationState","page":"Julia","title":"LibTrixi.SimulationState","text":"SimulationState\n\nData structure to store a simulation state that consists of a semidiscretization plus the time integrator.\n\n\n\n\n\n","category":"type"},{"location":"reference-julia/#LibTrixi.trixi_calculate_dt","page":"Julia","title":"LibTrixi.trixi_calculate_dt","text":"trixi_calculate_dt(simstate_handle::Cint)::Cdouble\n\nCompute, store, and return the time step size for the next time integration step.\n\n\n\n\n\n","category":"function"},{"location":"reference-julia/#LibTrixi.trixi_eval_julia","page":"Julia","title":"LibTrixi.trixi_eval_julia","text":"trixi_eval_julia(code::Cstring)::Cvoid\n\nExecute the provided code in the current Julia runtime environment.\n\nwarning: Only for development\nCode is not checked prior to execution.\n\n\n\n\n\n","category":"function"},{"location":"reference-julia/#LibTrixi.trixi_finalize_simulation","page":"Julia","title":"LibTrixi.trixi_finalize_simulation","text":"trixi_finalize_simulation(simstate_handle::Cint)::Cvoid\n\nFinalize a simulation and attempt to free the underlying memory.\n\n\n\n\n\n","category":"function"},{"location":"reference-julia/#LibTrixi.trixi_get_t8code_forest","page":"Julia","title":"LibTrixi.trixi_get_t8code_forest","text":"trixi_get_t8code_forest(simstate_handle::Cint)::::Ptr{Trixi.t8_forest}\n\nReturn t8code forest of the current T8codeMesh.\n\nwarning: Experimental\nThe interface to t8code is experimental and implementation details may change at any time without warning.\n\n\n\n\n\n","category":"function"},{"location":"reference-julia/#LibTrixi.trixi_initialize_simulation","page":"Julia","title":"LibTrixi.trixi_initialize_simulation","text":"trixi_initialize_simulation(libelixir::Cstring)::Cint\ntrixi_initialize_simulation(libelixir::AbstractString)::Cint\n\nInitialize a new simulation based on the file libelixirand return a handle to the corresponding SimulationState as a Cint (i.e, a plain C int).\n\nThe libelixir has a similar purpose as a regular \"elixir\" in Trixi.jl, as it completely defines a simulation setup in Julia code. A key difference (and thus the name libelixir) is that instead of running a simulation directly, it should define an argument-less function named init_simstate() that returns a SimulationState with the complete simulation setup. trixi_initialize_simulation will store the SimulationState object internally and allow one to use it in subsequent calls to libtrixi via the handle returned from this function.\n\nFor convenience, when using LibTrixi.jl directly from Julia, one can also pass a regular String in the libelixir argument.\n\nnote: Libelixir hygiene and `init_simstate`\nThe libelixir file will be evaluated in the Main module. Thus any previously defined function init_simstate will be overwritten, and any variables defined outside the function will live throughout the lifetime of the Julia process.\n\nwarning: Thread safety\nThis function is not thread safe. Since the libelixir file will be evaluated in the Main module, calling trixi_initialize_simulation simultaneously from different threads can lead to undefined behavior.\n\n\n\n\n\n","category":"function"},{"location":"reference-julia/#LibTrixi.trixi_is_finished","page":"Julia","title":"LibTrixi.trixi_is_finished","text":"trixi_is_finished(simstate_handle::Cint)::Cint\n\nReturn 0 if the simulation time has not yet reached the final time, and 1 otherwise.\n\n\n\n\n\n","category":"function"},{"location":"reference-julia/#LibTrixi.trixi_load_cell_averages","page":"Julia","title":"LibTrixi.trixi_load_cell_averages","text":"trixi_load_cell_averages(data::Ptr{Cdouble}, simstate_handle::Cint)::Cvoid\n\nReturn cell averaged solution state.\n\nCell averaged values for each cell and each primitive variable are stored in a contiguous array, where cell values for the first variable appear first and values for the other variables subsequently (structure-of-arrays layout).\n\nThe given array has to be of correct size and memory has to be allocated beforehand.\n\n\n\n\n\n","category":"function"},{"location":"reference-julia/#LibTrixi.trixi_ndims","page":"Julia","title":"LibTrixi.trixi_ndims","text":"trixi_ndims(simstate_handle::Cint)::Cint\n\nReturn number of spatial dimensions.\n\n\n\n\n\n","category":"function"},{"location":"reference-julia/#LibTrixi.trixi_nelements","page":"Julia","title":"LibTrixi.trixi_nelements","text":"trixi_nelements(simstate_handle::Cint)::Cint\n\nReturn number of local elements (cells).\n\n\n\n\n\n","category":"function"},{"location":"reference-julia/#LibTrixi.trixi_nelements_global","page":"Julia","title":"LibTrixi.trixi_nelements_global","text":"trixi_nelements_global(simstate_handle::Cint)::Cint\n\nReturn number of global elements (cells).\n\n\n\n\n\n","category":"function"},{"location":"reference-julia/#LibTrixi.trixi_nvariables","page":"Julia","title":"LibTrixi.trixi_nvariables","text":"trixi_nvariables(simstate_handle::Cint)::Cint\n\nReturn number of variables.\n\n\n\n\n\n","category":"function"},{"location":"reference-julia/#LibTrixi.trixi_step","page":"Julia","title":"LibTrixi.trixi_step","text":"trixi_step(simstate_handle::Cint)::Cvoid\n\nAdvance the simulation in time by one step.\n\n\n\n\n\n","category":"function"},{"location":"reference-julia/#LibTrixi.trixi_version_julia","page":"Julia","title":"LibTrixi.trixi_version_julia","text":"trixi_version_julia()::Cstring\n\nReturn name and version of loaded Julia packages LibTrixi directly depends on.\n\nThe return value is a read-only pointer to a NULL-terminated string with the name and version information of the loaded Julia packages, separated by newlines.\n\nThe returned pointer is to static memory and must not be used to change the contents of the version string. Multiple calls to the function will return the same address.\n\nThis function is thread-safe. It must be run after trixi_initialize has been called.\n\n\n\n\n\n","category":"function"},{"location":"reference-julia/#LibTrixi.trixi_version_julia_extended","page":"Julia","title":"LibTrixi.trixi_version_julia_extended","text":"trixi_version_julia_extended()::Cstring\n\nReturn name and version of all loaded Julia packages.\n\nThe return value is a read-only pointer to a NULL-terminated string with the name and version information of all loaded Julia packages, including implicit dependencies, separated by newlines.\n\nThe returned pointer is to static memory and must not be used to change the contents of the version string. Multiple calls to the function will return the same address.\n\nThis function is thread-safe. It must be run after trixi_initialize has been called.\n\n\n\n\n\n","category":"function"},{"location":"reference-julia/#LibTrixi.trixi_version_library","page":"Julia","title":"LibTrixi.trixi_version_library","text":"trixi_version_library()::Cstring\n\nReturn full version string of libtrixi.\n\nThe return value is a read-only pointer to a NULL-terminated string with the version information. This may include not just MAJOR.MINOR.PATCH but possibly also additional build or development version information.\n\nThe returned pointer is to static memory and must not be used to change the contents of the version string. Multiple calls to the function will return the same address.\n\nThis function is thread-safe. It must be run after trixi_initialize has been called.\n\n\n\n\n\n","category":"function"},{"location":"reference-julia/#LibTrixi.trixi_version_library_major","page":"Julia","title":"LibTrixi.trixi_version_library_major","text":"trixi_version_library_major()::Cint\n\nReturn major version number of libtrixi.\n\nThis function is thread-safe. It must be run after trixi_initialize has been called.\n\n\n\n\n\n","category":"function"},{"location":"reference-julia/#LibTrixi.trixi_version_library_minor","page":"Julia","title":"LibTrixi.trixi_version_library_minor","text":"trixi_version_library_minor()::Cint\n\nReturn minor version number of libtrixi.\n\nThis function is thread-safe. It must be run after trixi_initialize has been called.\n\n\n\n\n\n","category":"function"},{"location":"reference-julia/#LibTrixi.trixi_version_library_patch","page":"Julia","title":"LibTrixi.trixi_version_library_patch","text":"trixi_version_library_patch()::Cint\n\nReturn patch version number of libtrixi.\n\nThis function is thread-safe. It must be run after trixi_initialize has been called.\n\n\n\n\n\n","category":"function"},{"location":"reference-c-fortran/#C/Fortran-API","page":"C/Fortran","title":"C/Fortran API","text":"","category":"section"},{"location":"reference-c-fortran/","page":"C/Fortran","title":"C/Fortran","text":"The C/Fortran API of libtrixi is documented using doxygen. It can be found here:","category":"page"},{"location":"reference-c-fortran/","page":"C/Fortran","title":"C/Fortran","text":"C/Fortran API documentation","category":"page"},{"location":"license/#License","page":"License","title":"License","text":"","category":"section"},{"location":"license/","page":"License","title":"License","text":"MIT LicenseCopyright (c) 2023 Benedict Geihe and Michael Schlottke-LakemperPermission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.","category":"page"},{"location":"troubleshooting/#Troubleshooting","page":"Troubleshooting","title":"Troubleshooting","text":"","category":"section"},{"location":"troubleshooting/#dlopen-failed-is-triggered-by-OpenMPI","page":"Troubleshooting","title":"dlopen failed is triggered by OpenMPI","text":"","category":"section"},{"location":"troubleshooting/","page":"Troubleshooting","title":"Troubleshooting","text":"A warning similar to","category":"page"},{"location":"troubleshooting/","page":"Troubleshooting","title":"Troubleshooting","text":"--------------------------------------------------------------------------\nSorry!  You were supposed to get help about:\n    dlopen failed\nBut I couldn't open the help file:\n    <someJuliaPath>/share/openmpi/help-mpi-common-cuda.txt: No such file or directory.  Sorry!\n--------------------------------------------------------------------------","category":"page"},{"location":"troubleshooting/","page":"Troubleshooting","title":"Troubleshooting","text":"hints at missing CUDA libraries, which are optional for Trixi.jl. You can use the environment variable OMPI_MCA_mpi_cuda_support=0 to prevent attempting to load the library.","category":"page"},{"location":"#libtrixi","page":"Home","title":"libtrixi","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"(Image: Docs-stable) (Image: Docs-dev) (Image: Build Status) (Image: Coveralls) (Image: Codecov) (Image: License: MIT) (Image: DOI)","category":"page"},{"location":"","page":"Home","title":"Home","text":"Libtrixi is an interface library for using Trixi.jl from C/C++/Fortran.","category":"page"},{"location":"","page":"Home","title":"Home","text":"Note: This project is in an early stage and the API is still under development.  Nevertheless, basic functionality is already implemented and actively tested.","category":"page"},{"location":"#Getting-started","page":"Home","title":"Getting started","text":"","category":"section"},{"location":"#Prerequisites","page":"Home","title":"Prerequisites","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Currently, libtrixi is only developed and tested for Linux. Furthermore, the following software packages need to be made available locally before installing libtrixi:","category":"page"},{"location":"","page":"Home","title":"Home","text":"Julia v1.8+\nC compiler with support for C11 or later (e.g., gcc or clang)\nFortran compiler with support for Fortran 2018 or later (e.g., gfortran)\nCMake\nMPI (e.g., OpenMPI or MPICH)\nHDF5\nt8code","category":"page"},{"location":"#Get-the-sources","page":"Home","title":"Get the sources","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"git clone git@github.com:trixi-framework/libtrixi.git","category":"page"},{"location":"#building-libtrixi","page":"Home","title":"Building","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"For building, cmake and its typical workflow is used.","category":"page"},{"location":"","page":"Home","title":"Home","text":"It is recommended to create an out-of-source build directory, e.g.\nbash  mkdir build  cd build\nCall cmake\nbash  cmake -DCMAKE_BUILD_TYPE=(debug|release) -DCMAKE_INSTALL_PREFIX=<install_directory> ..\ncmake should find MPI and Julia automatically. If not, the directories  can be specified manually.  The cmake clients ccmake or cmake-gui could be useful.\nSpecifying the directory install_directory for later installation is optional.\nOptional specification of build type sets some default compiler options for optimized or debug code\nCall make\nbash  make\nThis will build and place libtrixi.so in the current directory along with its  header and a Fortran mod file. Your application will have to include and link  against these.\nExamples can be found in the examples subdirectory.\nInstall (optional)\nbash  make install\nThis will install all provided files to the specified location.","category":"page"},{"location":"#Setting-up-Julia","page":"Home","title":"Setting up Julia","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"After the library has been installed, you need to configure Julia for use with libtrixi. For this, create a directory where all necessary files will be placed, e.g., libtrixi-julia. Then, you can use the utils/libtrixi-init-julia tool (also available at <install_directory>/bin) to do the rest for you. A minimal example would be:","category":"page"},{"location":"","page":"Home","title":"Home","text":"mkdir libtrixi-julia\ncd libtrixi-julia\n<install_directory>/bin/libtrixi-init-julia \\\n    --t8code-library <t8code_install_directory>/lib/libt8.so\n    <install_directory>","category":"page"},{"location":"","page":"Home","title":"Home","text":"Use libtrixi-init-julia -h to get help.","category":"page"},{"location":"","page":"Home","title":"Home","text":"In your code, pass the path to the libtrixi-julia directory to trixi_initialize, see the code of the examples. If you did not modify the default value for the Julia depot when calling libtrixi-init-julia, libtrixi will find it automatically. Otherwise, when running a program that uses libtrixi, you need to make sure to set the JULIA_DEPOT_PATH environment variable to point to the <julia-depot> folder reported. ","category":"page"},{"location":"","page":"Home","title":"Home","text":"If you intend to use additional Julia packages, besides Trixi and OrdinaryDiffEq, you will have to add them to your Julia project (i.e. use julia --project=<libtrixi-julia_directory> and import Pkg; Pkg.add(<package>)).","category":"page"},{"location":"#Testing","page":"Home","title":"Testing","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Go to some directory from where you want to run a Trixi simulation.","category":"page"},{"location":"","page":"Home","title":"Home","text":"LIBTRIXI_DEBUG=all \\\n    <install_directory>/bin/simple_trixi_controller_c \\\n    <libtrixi-julia_directory> \\\n    <install_directory>/share/libtrixi/LibTrixi.jl/examples/libelixir_tree1d_dgsem_advection_basic.jl","category":"page"},{"location":"","page":"Home","title":"Home","text":"which should give you an output similar to this:","category":"page"},{"location":"","page":"Home","title":"Home","text":"████████╗██████╗ ██╗██╗  ██╗██╗\n╚══██╔══╝██╔══██╗██║╚██╗██╔╝██║\n   ██║   ██████╔╝██║ ╚███╔╝ ██║\n   ██║   ██╔══██╗██║ ██╔██╗ ██║\n   ██║   ██║  ██║██║██╔╝ ██╗██║\n   ╚═╝   ╚═╝  ╚═╝╚═╝╚═╝  ╚═╝╚═╝\n\n┌──────────────────────────────────────────────────────────────────────────────────────────────────┐\n│ SemidiscretizationHyperbolic                                                                     │\n│ ════════════════════════════                                                                     │\n│ #spatial dimensions: ………………………… 1                                                                │\n│ mesh: ………………………………………………………………… TreeMesh{1, Trixi.SerialTree{1}} with length 31                  │\n│ equations: …………………………………………………… LinearScalarAdvectionEquation1D                                  │\n│ initial condition: ……………………………… initial_condition_convergence_test                               │\n│ boundary conditions: ………………………… Trixi.BoundaryConditionPeriodic                                  │\n│ source terms: …………………………………………… nothing                                                          │\n│ solver: …………………………………………………………… DG                                                               │\n│ total #DOFs: ……………………………………………… 64                                                               │\n└──────────────────────────────────────────────────────────────────────────────────────────────────┘\n\n<snip>\n\n┌──────────────────────────────────────────────────────────────────────────────────────────────────┐\n│ Environment information                                                                          │\n│ ═══════════════════════                                                                          │\n│ #threads: ……………………………………………………… 1                                                                │\n└──────────────────────────────────────────────────────────────────────────────────────────────────┘\n\n────────────────────────────────────────────────────────────────────────────────────────────────────\n Simulation running 'LinearScalarAdvectionEquation1D' with DGSEM(polydeg=3)\n────────────────────────────────────────────────────────────────────────────────────────────────────\n #timesteps:                  0                run time:       7.20000000e-07 s\n Δt:             1.00000000e+00                └── GC time:    0.00000000e+00 s (0.000%)\n sim. time:      0.00000000e+00                time/DOF/rhs!:         NaN s\n                                               PID:                   Inf s\n #DOF:                       64                alloc'd memory:        143.411 MiB\n #elements:                  16\n\n Variable:       scalar\n L2 error:       2.78684204e-06\n Linf error:     6.06474411e-06\n ∑∂S/∂U ⋅ Uₜ :  -3.46944695e-18\n────────────────────────────────────────────────────────────────────────────────────────────────────\n\nCurrent time step length: 0.050000\n\n────────────────────────────────────────────────────────────────────────────────────────────────────\n Simulation running 'LinearScalarAdvectionEquation1D' with DGSEM(polydeg=3)\n────────────────────────────────────────────────────────────────────────────────────────────────────\n #timesteps:                 20                run time:       1.11329306e+00 s\n Δt:             5.00000000e-02                └── GC time:    5.11113150e-02 s (0.046%)\n sim. time:      1.00000000e+00                time/DOF/rhs!:  2.58861826e-08 s\n                                               PID:            1.57108461e-04 s\n #DOF:                       64                alloc'd memory:        116.126 MiB\n #elements:                  16\n\n Variable:       scalar\n L2 error:       6.03882964e-06\n Linf error:     3.21788773e-05\n ∑∂S/∂U ⋅ Uₜ :  -2.16706314e-09\n────────────────────────────────────────────────────────────────────────────────────────────────────\n\n ────────────────────────────────────────────────────────────────────────────────────\n              Trixi.jl                      Time                    Allocations\n                                   ───────────────────────   ────────────────────────\n         Tot / % measured:              1.13s /  52.4%           57.4MiB /  21.9%\n\n Section                   ncalls     time    %tot     avg     alloc    %tot      avg\n ────────────────────────────────────────────────────────────────────────────────────\n I/O                            3    495ms   83.5%   165ms   8.81MiB   70.0%  2.94MiB\n   ~I/O~                        3    230ms   38.8%  76.7ms   1.09MiB    8.7%   372KiB\n   get element variables        2    160ms   27.0%  80.2ms   1.90MiB   15.1%   975KiB\n   save solution                2    105ms   17.7%  52.5ms   5.81MiB   46.2%  2.91MiB\n   save mesh                    2    250ns    0.0%   125ns     0.00B    0.0%    0.00B\n analyze solution               2   98.1ms   16.5%  49.0ms   3.76MiB   29.9%  1.88MiB\n rhs!                         101    149μs    0.0%  1.47μs   6.61KiB    0.1%    67.0B\n   ~rhs!~                     101   88.1μs    0.0%   872ns   6.61KiB    0.1%    67.0B\n   volume integral            101   21.4μs    0.0%   212ns     0.00B    0.0%    0.00B\n   interface flux             101   10.2μs    0.0%   101ns     0.00B    0.0%    0.00B\n   prolong2interfaces         101   6.71μs    0.0%  66.4ns     0.00B    0.0%    0.00B\n   surface integral           101   5.52μs    0.0%  54.7ns     0.00B    0.0%    0.00B\n   Jacobian                   101   4.86μs    0.0%  48.1ns     0.00B    0.0%    0.00B\n   prolong2boundaries         101   3.79μs    0.0%  37.5ns     0.00B    0.0%    0.00B\n   reset ∂u/∂t                101   3.58μs    0.0%  35.5ns     0.00B    0.0%    0.00B\n   boundary flux              101   2.37μs    0.0%  23.5ns     0.00B    0.0%    0.00B\n   source terms               101   2.25μs    0.0%  22.3ns     0.00B    0.0%    0.00B\n calculate dt                  21   2.18μs    0.0%   104ns     0.00B    0.0%    0.00B\n ────────────────────────────────────────────────────────────────────────────────────","category":"page"},{"location":"","page":"Home","title":"Home","text":"If you change the executable name from simple_trixi_controller_c to simple_trixi_controller_f, you will get a near identical output. The corresponding source files simple_trixi_controller.c and simple_trixi_controller.f90 give you an idea on how to use the C and Fortran APIs of libtrixi, and can be found in the examples/ folder.","category":"page"},{"location":"","page":"Home","title":"Home","text":"If you just want to test the Julia part of libtrixi, i.e., LibTrixi.jl, you can also run everything from Julia. From the repository root, execute","category":"page"},{"location":"","page":"Home","title":"Home","text":"JULIA_DEPOT_PATH=$PWD/libtrixi-julia/julia-depot \\\n    julia --project=<libtrixi-julia_directory>\n    <install_directory>/share/libtrixi/LibTrixi.jl/examples/simple_trixi_controller.jl","category":"page"},{"location":"","page":"Home","title":"Home","text":"Note: Most auxiliary output is hidden unless the environment variable LIBTRIXI_DEBUG is set to all. Alternative values for the variable are c or julia to only show debug statements from the C or Julia part of the library, respectively. All values are case-sensitive and must be provided all lowercase.","category":"page"},{"location":"#Linking-against-libtrixi","page":"Home","title":"Linking against libtrixi","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"To use libtrixi in your program, you need to specify -I$LIBTRIXI_PREFIX/include for the include directory with header and module files, -L$LIBTRIXI_PREFIX/lib for the library directory, and -ltrixi for the library itself during your build process. Optionally, you can additionally specify -Wl,-rpath,$LIBTRIXI_PREFIX/lib such that the runtime loader knows where to find libtrixi.so. Here, $LIBTRIXI_PREFIX is the install prefix you specified during the CMake configure stage with -DCMAKE_INSTALL_PREFIX (see above).","category":"page"},{"location":"","page":"Home","title":"Home","text":"An example Makefile is provided with examples/MakefileExternal, which can be invoked from inside the examples/ directory as","category":"page"},{"location":"","page":"Home","title":"Home","text":"make -f MakefileExternal LIBTRIXI_PREFIX=path/to/libtrixi/prefix","category":"page"},{"location":"","page":"Home","title":"Home","text":"to build simple_trixi_controller_f.","category":"page"},{"location":"","page":"Home","title":"Home","text":"Note: On Linux and FreeBSD systems (i.e., not on macOS or Windows), Julia may internally use a faster implementation for thread-local storage (TLS), which is used whenever Julia functions such task management, garbage collection etc. are used in a multithreaded context, or when they are themselves multithreaded. To activate the fast TLS in your program, you need to add the file $LIBTRIXI_PREFIX/lib/libtrixi_tls.o to the list of files that are linked with your main program. See MakefileExternal for an example of how to do this. If you skip this step, everything will work as usual, but some things might run slightly slower.","category":"page"},{"location":"#Experimental-support-for-direct-compilation-of-the-Julia-sources","page":"Home","title":"Experimental support for direct compilation of the Julia sources","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"There is experimental support for compiling the Julia sources in LibTrixi.jl to a shared library with a C interface. This is possible with the use of the Julia package PackageCompiler.jl.","category":"page"},{"location":"","page":"Home","title":"Home","text":"To try this out, perform the following steps:","category":"page"},{"location":"","page":"Home","title":"Home","text":"Initialize the project directory libtrixi-julia using libtrixi-init-julia as described above.\nGo to the LibTrixi.jl/lib directory in the repository root, make sure that PROJECT_DIR (defined in Makefile) point to your libtrixi-julia directory, and call make:\ncd LibTrixi.jl/lib\nmake\nGo to the examples folder in the repository root and compile simple_trixi_controller_c:\ncd examples\nmake -f MakefileCompiled LIBTRIXI_PREFIX=$PWD/../LibTrixi.jl/lib/build\nThis will create a simple_trixi_controller_c file.\nFrom inside the examples folder you should be able to run the example (in parallel) with the following command:\nmpirun -n 2 simple_trixi_controller_c \\\n    ../libtrixi-julia \\\n    ../LibTrixi.jl/examples/libelixir_p4est2d_dgsem_euler_sedov.jl\nOptionally, you can set LIBTRIXI_DEBUG=all to get some debug output along the way.","category":"page"},{"location":"#Referencing","page":"Home","title":"Referencing","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"If you use libtrixi in your own research or write a paper using results obtained with the help of libtrixi, you can refer to libtrixi directly as","category":"page"},{"location":"","page":"Home","title":"Home","text":"@misc{schlottkelakemper2023libtrixi,\n  title={{L}ibtrixi: {I}nterface library for using {T}rixi.jl from {C}/{C}++/{F}ortran},\n  author={Schlottke-Lakemper, Michael and Geihe, Benedict and Gassner, Gregor J},\n  year={2023},\n  month={09},\n  howpublished={\\url{https://github.com/trixi-framework/libtrixi}},\n  doi={10.5281/zenodo.8321803}\n}","category":"page"},{"location":"","page":"Home","title":"Home","text":"Since libtrixi is based on Trixi.jl, you should also cite Trixi.jl in this case.","category":"page"},{"location":"#Authors","page":"Home","title":"Authors","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Libtrixi was initiated by Benedict Geihe (University of Cologne, Germany) and Michael Schlottke-Lakemper (RWTH Aachen University/High-Performance Computing Center Stuttgart (HLRS), Germany), who are also its principal maintainers.","category":"page"},{"location":"#readme-license","page":"Home","title":"License","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Libtrixi is licensed under the MIT license (see License).","category":"page"},{"location":"#Acknowledgments","page":"Home","title":"Acknowledgments","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"This project has benefited from funding by the Deutsche Forschungsgemeinschaft (DFG, German Research Foundation) through the research unit FOR 5409 \"Structure-Preserving Numerical Methods for Bulk- and Interface Coupling of Heterogeneous Models (SNuBIC)\" (project number 463312734).","category":"page"},{"location":"","page":"Home","title":"Home","text":"This project has benefited from funding from the German Federal Ministry of Education and Research through the project grant \"Adaptive earth system modeling with significantly reduced computation time for exascale supercomputers (ADAPTEX)\" (funding id: 16ME0668K).","category":"page"},{"location":"developers/#Developers","page":"Developers","title":"Developers","text":"","category":"section"},{"location":"developers/#Release-management","page":"Developers","title":"Release management","text":"","category":"section"},{"location":"developers/","page":"Developers","title":"Developers","text":"We manage releases through the tools provided by the Julia community for creating and publishing new Julia package releases.  Specifically, that means","category":"page"},{"location":"developers/","page":"Developers","title":"Developers","text":"we set the libtrixi version in LibTrixi.jl/Project.toml,\nwe use the Julia Registrator app for GitHub to register new versions of the Julia package LibTrixi.jl, and\nwe rely on the Julia TagBot to create associacted tags and GitHub releases once the Julia package is registered.","category":"page"},{"location":"developers/#Creating-a-new-release","page":"Developers","title":"Creating a new release","text":"","category":"section"},{"location":"developers/","page":"Developers","title":"Developers","text":"To create a new libtrixi release, follow these steps:","category":"page"},{"location":"developers/","page":"Developers","title":"Developers","text":"Ensure that all tests have passed for the current commit in main and that coverage is OK (>95%).\nBump the version in LibTrixi.jl/Project.toml to the next release version, following semantic versioning. For example, if the current release is v0.1.0, the next release with breaking changes would be v0.2.0, while the next non-breaking release would be v0.1.1. Commit this change to main.\nGo to the latest commit in main on the GitHub website. This should be the commit where you just updated the version. Scroll down and submit the following comment\n@JuliaRegistrator register subdir=LibTrixi.jl\nThis will prompt the Julia Registrator app to create a new release of the Julia package LibTrixi.jl. If there are no issues found that would prevent auto-merging the version update PR in the Julia General registry (e.g., if you did not skip a version number), the new version will become active after about 15 minutes. See the full set of rules here.\nThe Julia Registrator app is chatty and will let you know in the PR if your registration request meets all criteria for an auto-merge. Once this is the case, bump the version in LibTrixi.jl/Project.toml again and set it to the next development version. We do this to prevent confusion about whether the current state of the repository is identical to the latest release or not.   The next development version is obtained by increasing the patch number and appending -pre. For example, if you just released version v0.1.1, the next development version would be v0.1.2-pre.","category":"page"},{"location":"developers/#Testing","page":"Developers","title":"Testing","text":"","category":"section"},{"location":"developers/#Testing-the-C-interface","page":"Developers","title":"Testing the C interface","text":"","category":"section"},{"location":"developers/","page":"Developers","title":"Developers","text":"For testing the C interface of libtrixi we rely on GoogleTest. The tests are contained in cpp-files located under test/c. They are processed by cmake and made available via ctest, provided the options","category":"page"},{"location":"developers/","page":"Developers","title":"Developers","text":"-DENABLE_TESTING=ON -DJULIA_PROJECT_PATH=<libtrixi-julia_directory>","category":"page"},{"location":"developers/","page":"Developers","title":"Developers","text":"are passed to cmake during configuration. The executables can then be found under <build_directory>/test/c (they will not be installed). To run them, execute","category":"page"},{"location":"developers/","page":"Developers","title":"Developers","text":"ctest [-V] [-R <regex>]","category":"page"},{"location":"developers/","page":"Developers","title":"Developers","text":"from <build_directory>/test/c or the top-level directory <build_directory>. The optional argument -V turns on verbose output, and -R lets you specify a regular expression to select specific tests. A list of available tests can be obtained via ctest -N.","category":"page"},{"location":"developers/#Testing-the-Fortran-interface","page":"Developers","title":"Testing the Fortran interface","text":"","category":"section"},{"location":"developers/","page":"Developers","title":"Developers","text":"For testing the Fortran interface of libtrixi we rely on test-drive, which integrates with cmake and ctest as well. The tests are contained in f90-files under test/fortran. Usage is analogous to the C interface.","category":"page"},{"location":"developers/#Testing-the-Julia-interface","page":"Developers","title":"Testing the Julia interface","text":"","category":"section"},{"location":"developers/","page":"Developers","title":"Developers","text":"For testing the Julia interface of libtrixi, which is contained in the Julia package LibTrixi.jl, we rely on Julia's testing infrastructure. There is a dedicated test project, located under LibTrixi.jl/test, which contains runtest.jl and further jl-files containing the actual tests. Invoke via","category":"page"},{"location":"developers/","page":"Developers","title":"Developers","text":"JULIA_DEPOT_PATH=<julia-depot_directory> \\\nLIBTRIXI_DEBUG=all \\\n    julia --project=./LibTrixi.jl -e 'import Pkg; Pkg.test()'","category":"page"}]
}
