# Note: This file is inspired by
# https://github.com/simonbyrne/libcg/blob/master/CG/build/build.jl.

time_start = time()

using PackageCompiler: PackageCompiler
using TOML: TOML
using Pkg

lib_dir = @__DIR__

if length(ARGS) < 2 || "-h" in ARGS || "--help" in ARGS
    project = relpath(lib_dir)
    println("""
            usage: julia --project=$project $PROGRAM_FILE PACKAGE_OR_PROJECT_DIR DEST_DIR

            Build libtrixi as a library directly from the Julia sources using PackageCompiler.jl.

            positional arguments:
                PACKAGE_OR_PROJECT_DIR
                                Path to the package or project directory that should be compiled.
                DEST_DIR        Directory where the library bundle should be created.
            """)
    exit(1)
end

@info "Preparing arguments..."

# Location of package/project that should be built into a library
package_or_project_dir = ARGS[1]

# Prefix where compiled library should be installed
dest_dir = ARGS[2]

# Library name
lib_name = "trixi"

# Create a fresh sysimage and do not reuse the default sysimage
incremental = false

# Do not include stdlibs which are not needed
filter_stdlibs = true

# Overwrite existing files/folders at `dest_dir`
force = true

# Bundle header file with library (will be put in `PREFIX/include`)
header_files = [joinpath(dirname(dirname(lib_dir)), "src", "trixi.h")]

# Name of the files that include the initialization functions:
# - `init.c` contains `trixi_initialize`/`trixi_finalize` for API compatibility
# - the other file contains the `init_julia`/`shutdown_julia` functions from PackageCompiler
julia_init_c_file = ["init.c", PackageCompiler.default_julia_init()]

# Extract version from `Project.toml`
project_toml = joinpath(package_or_project_dir, "Project.toml")
ctx = Pkg.Types.Context(env=Pkg.Types.EnvCache(project_toml))
long_version = filter(p -> p.name == "LibTrixi", collect(values(ctx.env.manifest.deps)))[1].version
version = VersionNumber(long_version.major, long_version.minor, long_version.patch)

# Set compat level to minor. Since we using zerover at the moment, a bump in minor version
# comes with potential ABI breakage
compat_level = "minor"

# Do not include lazy artifacts to keep library bundle size within sane bounds
include_lazy_artifacts = false

# Do not include transitive dependencies unless really needed
include_transitive_dependencies = false

@info("List of arguments passed to `create_library`:",
      package_or_project_dir,
      dest_dir,
      lib_name,
      incremental,
      filter_stdlibs,
      force,
      header_files,
      julia_init_c_file,
      version,
      compat_level,
      include_lazy_artifacts,
      include_transitive_dependencies)

@info "Running `PackageCompiler.create_library`..."
lib_time = @elapsed PackageCompiler.create_library(package_or_project_dir, dest_dir;
                                                   lib_name,
                                                   incremental,
                                                   filter_stdlibs,
                                                   force,
                                                   header_files,
                                                   julia_init_c_file,
                                                   version,
                                                   compat_level,
                                                   include_lazy_artifacts,
                                                   include_transitive_dependencies)

version_file = joinpath(dest_dir, "share", "julia", "LIBTRIXI_VERSION")
@info "Writing version information to `$version_file`..."
write(version_file, string(version) * "\n")

total_time = time() - start_time()
@info "Duration (in seconds)" total_time lib_time
