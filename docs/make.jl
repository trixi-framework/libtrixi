using Documenter
import Pkg

# Get LibTrixi.jl root directory
libtrixi_root_dir = dirname(@__DIR__)

# Fix for https://github.com/trixi-framework/Trixi.jl/issues/668
if (get(ENV, "CI", nothing) != "true") && (get(ENV, "TRIXI_DOC_DEFAULT_ENVIRONMENT", nothing) != "true")
    push!(LOAD_PATH, libtrixi_root_dir)
end

using LibTrixi

# Define module-wide setups such that the respective modules are available in doctests
DocMeta.setdocmeta!(LibTrixi, :DocTestSetup, :(using LibTrixi); recursive=true)

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
        "Reference" => [
                        "C/Fortran" => "reference-c-fortran.md",
                        "Julia" => "reference-julia.md",
                       ],
        "License" => "license.md"
    ],
    strict = true # to make the GitHub action fail when doctests fail, see https://github.com/neuropsychology/Psycho.jl/issues/34
)


# Note: If you change any input values here, make sure you also update the values in
# `determine_doxygen_dir.jl` accordingly
deploydocs(
    repo = "github.com/trixi-framework/libtrixi",
    devbranch = "main",
    push_preview = true
)
