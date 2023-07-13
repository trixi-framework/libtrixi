# Julia API

This page documents the Julia part of libtrixi, which is implemented in the LibTrixi.jl
package. LibTrixi.jl provides Julia-based wrappers around Trixi.jl, making simulations
controllable through a defined API.

!!! note "Internal and development use only"
    The Julia API provided by LibTrixi.jl is only provided for internal use by libtrixi and
    to facilitate easier development and debugging of new library features. It is *not*
    intended to be used by Julia developers: They should directly utilize Trixi.jl to
    benefit from its Julia-native implementation.

```@meta
CurrentModule = LibTrixi
```

```@autodocs
Modules = [LibTrixi]
```
