# Note: This file is inspired by
# https://github.com/simonbyrne/libcg/blob/master/CG/build/build.jl.

using PackageCompiler: PackageCompiler
using TOML: TOML

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
package_or_project_dir = ARGS[1]
dest_dir = ARGS[2]

lib_name = "trixi"

incremental = true

filter_stdlibs = true

force = true

header_files = [joinpath(dirname(dirname(lib_dir)), "src", "trixi.h")]

julia_init_c_file = "init.c"

project_toml = realpath(joinpath(dirname(lib_dir), "Project.toml"))
long_version = TOML.parsefile(project_toml)["version"]
version = VersionNumber(long_version.major, long_version.minor, long_version.patch)

compat_level = "minor"

include_lazy_artifacts = false

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

total_time = @elapsed PackageCompiler.create_library(package_or_project_dir, dest_dir;
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

@info "Total time (in seconds)" total_time
