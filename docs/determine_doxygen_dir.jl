using Documenter

# Note: If you change any input values here, make sure you also update the values in
# `make.jl` accordingly
repo = "github.com/trixi-framework/libtrixi"
devbranch = "main"
push_preview = true

# Internally used values for convenience
branch = "gh-pages"
branch_previews = branch
devurl = "dev"
repo_previews = repo
tag_prefix = ""

# Create a deploy configuration for GitHub Actions (we ignore other CI systems here)
deploy_config = Documenter.GitHubActions();

# Create a deploy decision using the same default values as are used in Documenter.jl's
# implementation of `deploydocs(...)`
# See also: https://github.com/JuliaDocs/Documenter.jl/blob/7c97a86a31e360d7d22082a9a783b0cab24163b5/src/deploydocs.jl#L213-L221
deploy_decision = Documenter.deploy_folder(
    deploy_config;
    branch,
    branch_previews,
    devbranch,
    devurl,
    push_preview,
    repo,
    repo_previews,
    tag_prefix,
);

# Print (to stdout) the folder name relative to repo root
# Note: Warnings/info messages will be printed to stderr
println(joinpath(deploy_decision.subfolder, "c-fortran-api"))
