---
title: '`libtrixi`: an interface library for using Trixi.jl from C/C++/Fortran'
tags:
  - numerical simulation
  - Julia
  - cross-language interoperability
  - computational fluid dynamics (CFD)
  - high performance computing (HPC)
authors:
  - name: Michael Schlottke-Lakemper
    orcid: 0000-0002-3195-2536
    corresponding: true
    affiliation: "1, 2" # (Multiple affiliations must be quoted)
  - name: Benedict Geihe
    orcid: 0000-0002-9519-6872
    affiliation: 3
  - name: Gregor J. Gassner
    orcid: 0000-0002-1752-1158
    affiliation: 3
affiliations:
 - name: Applied and Computational Mathematics, RWTH Aachen University, Germany
   index: 1
 - name: High-Performance Computing Center Stuttgart (HLRS), University of Stuttgart, Germany
   index: 2
 - name: Department of Mathematics and Computer Science, University of Cologne, Germany
   index: 3
date: 01 October 2023
bibliography: paper.bib
---


# Summary
The Julia programming language is able to natively call C and Fortran functions, which is
widely used to utilize the functionality of existing, mature software libraries in Julia. In
addition, Julia also provides an application programming interface (API) that allows calling
Julia functions from C or Fortran programs. However, since the higher-level elements of the
Julia language are not directly representable in C or Fortran, this direction of
cross-language interoperability is much harder to realize and has not been used in practice
so far.

With [`libtrixi`](https://github.com/trixi-framework/libtrixi)
[@schlottkelakemper2023libtrixi] we thus present, to the best of our knowledge, the first
software library to control complex Julia code from a main program written in
a different language. Specifically, `libtrixi` provides an API to
[Trixi.jl](https://github.com/trixi-framework/Trixi.jl) [@schlottkelakemper2020trixi;
@schlottkelakemper2021purely], a Julia package for adaptive numerical simulations of
conservation laws. The API allows one to manage the entire simulation process, including
setting up a simulation, advancing the numerical solution in time, and retrieving simulation
data for further analysis. The main program may either be written in C/C++/Fortran or use
any other language that can directly interact with the C/Fortran interface of `libtrixi`.
With this approach, users can continue to use existing applications or legacy frameworks
for the overall process control, while taking advantage of the modern, high-order discretization
schemes implemented in Trixi.jl.

`Libtrixi` is developed and used as part of the research project "ADAPTEX" (see also
section "Acknowledgments" below). Both `libtrixi` and Trixi.jl are available under the MIT
license.


# Statement of need

Numerical simulations of conservation laws are used to accurately predict many naturally
occurring processes in various areas of physics, such as fluid flow, astrophysics, earth
systems, or weather and climate modeling. These phenomena characteristically exhibit a broad
range of spatial and temporal length scales, making it necessary to use finely resolved
computational grids. Therefore, high-performance computing (HPC) techniques are required
to render the numerical solution feasible on large-scale compute systems.

Consequently, many simulation tools are written in traditional HPC languages such as C, C++,
or Fortran, e.g., deal.II [@dealii2019design] or PETSc [@petsc-efficient]. These languages
offer high computational performance, but often at the cost of being complex to learn and
maintain. On the other hand, languages like Python, which are more amenable for rapid
prototyping or less experienced users, are usually not fast enough to use without
specialized packages that utilize kernels written in a compiled language. For example,
Python's well-known NumPy library [@2020NumPy-Array] has its performance-critical code
implemented in C.

The Julia programming language [@Bezanson_Julia_A_fresh_2017] aims to provide a new approach
to scientific computing. It strives to combine convenience with performance by providing an
accessible, high-level syntax together with fast, just-in-time-compiled execution
[@churavy2022bridging]. Due to its native ability to call C or Fortran functions, in
multi-language projects Julia often acts as a glue code between newly developed
implementations written in Julia and existing libraries written in C/Fortran.

While there exist other numerical simulation codes in Julia, e.g., Gridap.jl [@Badia2020] or
Ferrite.jl [@Carlsson_Ferrite_jl], none of them provide the ability to use them directly
from another programming language. With `libtrixi`, we therefore enable new workflows by
allowing scientists to connect established research codes to a modern numerical simulation
package written in Julia. That is, a main program written in C/C++ or Fortran is able to
execute a simulation set up in Julia with Trixi.jl without sacrifices in performance.

This control direction, where a Julia package is managed from C/Fortran, has, to the best of
our knowledge, not been used in practical applications so far. Besides making Trixi.jl
available to a wider scientific audience, `libtrixi` is thus a research project to investigate
the efficacy of using Julia-based libraries in existing code environments, and can eventually
serve as a blueprint for other similar efforts. Questions such as how to retain the flexibility
of Julia while providing a traditional, fixed API, how to use system-local third-party libraries,
or how to interact with Fortran are investigated and answered.


# Technical overview
`Libtrixi` consists of three main parts:

- the Julia package
  [LibTrixi.jl](https://github.com/trixi-framework/libtrixi/tree/main/LibTrixi.jl), which
  provides a traditional library API to Trixi.jl in Julia,
- a C API that exposes this Julia API as an ordinary, shared C library,
- Fortran bindings for the C API.

\autoref{fig:libtrixi_overview} illustrates the general workflow: A main program written in
C/C++/Fortran interacts with the public-facing C or Fortran API of `libtrixi`. The Fortran
API is little more than a set of language bindings, with some extra code to handle the
conversion between certain Fortran and C data types, e.g., strings or Boolean values.
The C API is slightly more involved, providing functionality to initialize and eventually
finalize the Julia runtime. During initialization, C function pointers are obtained from
Julia to the relevant API functions implemented in LibTrixi.jl. Most of the C API then just
forwards the API calls to these function pointers.

Finally, LibTrixi.jl is the actual library layer. Since Trixi.jl uses a composable design
and relies heavily on Julia's type system, it is necessary to repackage this flexibility
such that it can be exposed in a traditional API with static types. This is achieved by
converting Trixi.jl's *elixirs*, which consist of all code to set up and run a simulation,
into so-called *libelixirs*. These libelixirs are used to initialize a simulation state,
which is then stored internally in LibTrixi.jl and assigned a unique integer. This integer
handle is exposed in the C/Fortran API and facilitates all interaction between the main
program and the actual simulation. It further allows controlling multiple independent
simulations simultaneously.

![A main program implemented in C/C++/Fortran is able to interact with Trixi.jl via
`libtrixi`.\label{fig:libtrixi_overview}](libtrixi-overview.pdf)

As an alternative to the aforementioned translation layer written in C, which exposes the
Julia API of LibTrixi.jl via function pointers, there exists experimental support in
`libtrixi` for compiling LibTrixi.jl directly into a C library. This is achieved with
PackageCompiler.jl[^1], a Julia package that allows one to compile Julia packages directly
into a shared C library or even a standalone executable. While other Julia packages exist
that provide build options for PackageCompiler.jl, they typically use it to offer the Julia
package as an executable and not as a library, e.g., Ribasim[^2], Comonicon.jl[^3], or
SpmImage Tycoon [@Riss_JOSS_2022].

In addition to the library itself, `libtrixi` comes with the tools necessary for a smooth
setup and installation process. A custom shell script installs all required Julia
dependencies and allows one to configure the use of system-local library dependencies, such
as for the MPI library. A CMake[^4]-based build system handles the build process of the C
translation layer and the Fortran bindings. All parts of `libtrixi` are extensively tested
using the built-in unit testing framework for Julia [^5], GoogleTest[^6] for the C API, and
test-drive[^7] for the Fortran bindings.

[^1]: PackageCompiler.jl, [https://github.com/JuliaLang/PackageCompiler.jl](https://github.com/JuliaLang/PackageCompiler.jl)
[^2]: Ribasim, [https://github.com/Deltares/Ribasim](https://github.com/Deltares/Ribasim)
[^3]: Comonicon.jl, [https://github.com/comonicon/Comonicon.jl](https://github.com/comonicon/Comonicon.jl)
[^4]: CMake, [https://cmake.org](https://cmake.org)
[^5]: Julia testing with `Test`, [https://docs.julialang.org/en/v1/stdlib/Test/](https://docs.julialang.org/en/v1/stdlib/Test/)
[^6]: GoogleTest, [https://google.github.io/googletest/](https://google.github.io/googletest/)
[^7]: test-drive, [https://github.com/fortran-lang/test-drive](https://github.com/fortran-lang/test-drive)


# Acknowledgments

This project has benefited from funding by the Deutsche Forschungsgemeinschaft (DFG, German
Research Foundation) through the research unit FOR 5409 "SNuBIC" (project number
463312734), and through an DFG individual grant (project number 528753982).

This project has benefited from funding from the German Federal Ministry of Education and
Research through the project grant "Adaptive earth system modeling with significantly
reduced computation time for exascale supercomputers (ADAPTEX)" (funding id: 16ME0668K).


# References
