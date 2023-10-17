# Developers

## Release management

We manage releases through the tools provided by the Julia community for creating and
publishing new Julia package releases.  Specifically, that means
* we set the libtrixi version in
  [`LibTrixi.jl/Project.toml`](https://github.com/trixi-framework/libtrixi/blob/main/LibTrixi.jl/Project.toml),
* we use the [Julia Registrator app](https://github.com/JuliaRegistries/Registrator.jl)
  for GitHub to register new versions of the Julia package LibTrixi.jl, and
* we rely on the Julia [TagBot](https://github.com/JuliaRegistries/TagBot)
  to create associacted tags and GitHub releases once the Julia package is registered.

### Creating a new release
To create a new libtrixi release, follow these steps:
1. Ensure that all tests have passed for the current commit in `main` and that coverage is
   OK (>95%).
2. Bump the version in
   [`LibTrixi.jl/Project.toml`](https://github.com/trixi-framework/libtrixi/blob/main/LibTrixi.jl/Project.toml)
   to the next release version, following [semantic versioning](https://semver.org/). For
   example, if the current release is `v0.1.0`, the next release with breaking changes would
   be `v0.2.0`, while the next non-breaking release would be `v0.1.1`. Commit this change to `main`.
3. Go to the [latest commit in `main`](https://github.com/trixi-framework/libtrixi/commit/HEAD)
   on the GitHub website. This should be the commit where you just updated the version.
   Scroll down and submit the following comment
   ```
   @JuliaRegistrator register subdir=LibTrixi.jl
   ```
   This will prompt the [Julia Registrator app](https://github.com/JuliaRegistries/Registrator.jl/)
   to create a new release of the Julia package LibTrixi.jl. If there are no issues found
   that would prevent auto-merging the version update PR in the Julia General registry
   (e.g., if you did not skip a version number), the new version will become active after
   about 15 minutes. See the full set of rules
   [here](https://github.com/JuliaRegistries/Registrator.jl/).
4. The Julia Registrator app is chatty and will let you know in the PR if your registration
   request meets all criteria for an auto-merge. Once this is the case, bump the version in
   [`LibTrixi.jl/Project.toml`](https://github.com/trixi-framework/libtrixi/blob/main/LibTrixi.jl/Project.toml)
   again and set it to the next development version. We do this to prevent confusion about
   whether the current state of the repository is identical to the latest release or not.  
   The next development version is obtained by increasing the *patch* number and appending
   `-pre`. For example, if you just released version `v0.1.1`, the next development version
   would be `v0.1.2-pre`.


## Testing

### Testing the C interface

For testing the C interface of libtrixi we rely on [GoogleTest](https://google.github.io/googletest).
The tests are contained in `cpp`-files located under `test/c`. They are processed by `cmake` and made available via
`ctest`, provided the options
```
-DENABLE_TESTING=ON -DJULIA_PROJECT_PATH=<libtrixi-julia_directory>
```
are passed to `cmake` during configuration.
The executables can then be found under `<build_directory>/test/c` (they will not be installed). To run them, execute
```
ctest [-V] [-R <regex>]
```
from `<build_directory>/test/c` or the top-level directory `<build_directory>`.
The optional argument `-V` turns on verbose output, and `-R` lets you specify a regular expression to select specific tests.
A list of available tests can be obtained via `ctest -N`.

### Testing the Fortran interface

For testing the Fortran interface of libtrixi we rely on [test-drive](https://github.com/fortran-lang/test-drive),
which integrates with `cmake` and `ctest` as well. The tests are contained in `f90`-files under `test/fortran`. Usage is
analogous to the C interface.

### Testing the Julia interface

For testing the Julia interface of libtrixi, which is contained in the Julia package `LibTrixi.jl`, we rely on
[Julia's testing infrastructure](https://docs.julialang.org/en/v1/stdlib/Test/). There is a dedicated test project,
located under `LibTrixi.jl/test`, which contains `runtest.jl` and further `jl`-files containing the actual tests.
Invoke via
```
JULIA_DEPOT_PATH=<julia-depot_directory> \
LIBTRIXI_DEBUG=all \
    julia --project=./LibTrixi.jl -e 'import Pkg; Pkg.test()'
```
