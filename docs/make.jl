using Documenter
import Pkg

# Note: If you change any input values here, make sure you also update the values in
# `determine_doxygen_dir.jl` accordingly
repo = "github.com/trixi-framework/libtrixi"
devbranch = "main"
push_preview = true

# Get LibTrixi.jl root directory
libtrixi_root_dir = dirname(@__DIR__)

# Fix for https://github.com/trixi-framework/Trixi.jl/issues/668
if (get(ENV, "CI", nothing) != "true") && (get(ENV, "TRIXI_DOC_DEFAULT_ENVIRONMENT", nothing) != "true")
    push!(LOAD_PATH, libtrixi_root_dir)
end

using LibTrixi

# Define module-wide setups such that the respective modules are available in doctests
DocMeta.setdocmeta!(LibTrixi, :DocTestSetup, :(using LibTrixi); recursive=true)

# Generate source files from templates
template_dir = joinpath(@__DIR__, "templates")
doxygen_dir = get(ENV, "doxygen_dir", "DOXYGEN_DIR_NOT_SET")
doxygen_url = joinpath("https://trixi-framework.github.io/libtrixi", doxygen_dir)
reference_c_fortran_text = read(joinpath(template_dir, "reference-c-fortran.tmpl.md"), String)
reference_c_fortran_text = replace(reference_c_fortran_text, "{doxygen_url}" => doxygen_url)
write(joinpath(@__DIR__, "src", "reference-c-fortran.md"), reference_c_fortran_text)

# Copy some files from the top level directory to the docs and modify them
# as necessary
open(joinpath(@__DIR__, "src", "license.md"), "w") do io
    # Point to source license file
    println(io, """
    ```@meta
    EditURL = "https://github.com/trixi-framework/libtrixi/blob/main/LICENSE.md"
    ```
    """)
    # Write the modified contents
    println(io, "# License")
    println(io, "")
    for line in eachline(joinpath(dirname(@__DIR__), "LICENSE.md"))
        line = replace(line, "[LICENSE.md](LICENSE.md)" => "[License](@ref)")
        println(io, "> ", line)
    end
end

open(joinpath(@__DIR__, "src", "contributing.md"), "w") do io
  # Point to source license file
  println(io, """
  ```@meta
  EditURL = "https://github.com/trixi-framework/libtrixi/blob/main/CONTRIBUTING.md"
  ```
  """)
  # Write the modified contents
  println(io, "# Contributing")
  println(io, "")
  for line in eachline(joinpath(dirname(@__DIR__), "CONTRIBUTING.md"))
    line = replace(line, "[LICENSE.md](LICENSE.md)" => "[License](@ref)")
    println(io, "> ", line)
  end
end

# Make documentation
makedocs(
    # Specify modules for which docstrings should be shown
    modules = [LibTrixi],
    # Set sitename to Trixi.jl
    sitename="libtrixi",
    # Provide additional formatting options
    format = Documenter.HTML(
        # Disable pretty URLs during manual testing
        prettyurls = get(ENV, "CI", nothing) == "true",
        # Set canonical URL to GitHub pages URL
        canonical = "https://trixi-framework.github.io/libtrixi/stable"
    ),
    # Explicitly specify documentation structure
    pages = [
        "Home" => "index.md",
        "Developers" => "developers.md",
        "Troubleshooting" => "troubleshooting.md",
        "API Reference" => [
            "C/Fortran" => "reference-c-fortran.md",
            "Julia" => "reference-julia.md",
        ],
        "Contributing" => "contributing.md",
        "License" => "license.md"
    ],
    linkcheck_ignore = [doxygen_url]
)


# Note: If you change any input values here, make sure you also update the values in
# `determine_doxygen_dir.jl` accordingly
deploydocs(; repo, devbranch, push_preview)
