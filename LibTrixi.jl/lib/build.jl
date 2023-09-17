# Note: This file is inspired by
# https://github.com/simonbyrne/libcg/blob/master/CG/build/build.jl.

using PackageCompiler: PackageCompiler
using TOML: TOML

lib_dir = @__DIR__
package_dir = dirname(lib_dir)

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

lib_name = "trixi"

# precompile_execution_file = joinpath(lib_dir, "precompile_execution_file.jl")
precompile_execution_file = ""

incremental = true

filter_stdlibs = true

force = true

header_files = [joinpath(dirname(dirname(lib_dir)), "src", "trixi.h")]

julia_init_c_file = ["init.c", PackageCompiler.default_julia_init()]

julia_init_h_file = [PackageCompiler.default_julia_init_header()]

project_toml = realpath(joinpath(dirname(lib_dir), "Project.toml"))
version = VersionNumber(TOML.parsefile(project_toml)["version"])

compat_level = "minor"

include_transitive_dependencies = true

@info("List of arguments passed to `create_library`:",
      package_dir,
      dest_dir,
      lib_name,
      precompile_execution_file,
      incremental,
      filter_stdlibs,
      force,
      header_files,
      julia_init_c_file,
      julia_init_h_file,
      version,
      compat_level,
      include_transitive_dependencies)

total_time = @elapsed PackageCompiler.create_library(package_dir, dest_dir;
                                                     lib_name,
                                                     precompile_execution_file,
                                                     incremental,
                                                     filter_stdlibs,
                                                     force,
                                                     header_files,
                                                     julia_init_c_file,
                                                     julia_init_h_file,
                                                     version,
                                                     compat_level,
                                                     include_transitive_dependencies)

@info "Total time (in seconds)" total_time
