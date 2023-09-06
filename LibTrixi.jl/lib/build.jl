# Note: This file is inspired by
# https://github.com/simonbyrne/libcg/blob/master/CG/build/build.jl.

using PackageCompiler: PackageCompiler
using TOML: TOML

lib_dir = @__DIR__

if length(ARGS) < 1 || "-h" in ARGS || "--help" in ARGS
    project = relpath(lib_dir)
    println("""
            usage: julia --project=$project $PROGRAM_FILE DEST_DIR

            Build libtrixi as a library directly from the Julia sources using PackageCompiler.jl.

            positional arguments:
                DEST_DIR        Directory where the library bundle should be created.
            """)
    exit(1)
end

dest_dir = ARGS[1]
project_toml = realpath(joinpath(dirname(lib_dir), "Project.toml"))
version = VersionNumber(TOML.parsefile(project_toml)["version"])

package_dir = dirname(lib_dir)

precompile_execution_file = joinpath(lib_dir, "precompile_execution_file.jl")

header_files = [joinpath(dirname(dirname(lib_dir)), "src", "trixi.h")]

julia_init_c_file = []

@show package_dir
@show dest_dir
@show precompile_execution_file
@show header_files
@show version

PackageCompiler.create_library(package_dir, dest_dir;
                               lib_name = "trixi",
                               precompile_execution_file = precompile_execution_file,
                               incremental = false,
                               filter_stdlibs = true,
                               force = true,
                               header_files = header_files,
                               version = version,
                               compat_level = "minor",
                               include_transitive_dependencies = true,
                               julia_init_c_file = julia_init_c_file)
