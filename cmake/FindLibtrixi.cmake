# Stop if already found
if (LIBTRIXI_FOUND)
    return()
endif()

# Look for include, libs, executables
find_path(LIBTRIXI_INCLUDE_DIR trixi.h PATHS ${LIBTRIXI_PREFIX}/include)
find_library(LIBTRIXI_LIBRARY trixi PATHS ${LIBTRIXI_PREFIX}/lib)

# Extract version
if (LIBTRIXI_INCLUDE_DIR)
    get_filename_component(_prefix ${LIBTRIXI_INCLUDE_DIR} DIRECTORY)
    set(_version_file "${_prefix}/share/julia/LIBTRIXI_VERSION")
    file(READ _version_file LIBTRIXI_VERSION_STRING)
    unset(_prefix)
    unset(_version_file)
elseif (LIBTRIXI_LIBRARY)
    get_filename_component(_prefix ${LIBTRIXI_LIBRARY} DIRECTORY)
    get_filename_component(_prefix ${_prefix} DIRECTORY)
    set(_version_file "${_prefix}/share/julia/LIBTRIXI_VERSION")
    file(READ _version_file LIBTRIXI_VERSION_STRING)
    unset(_prefix)
    unset(_version_file)
else()
    set(LIBTRIXI_VERSION_STRING "LIBTRIXI_VERSION_STRING-NOTFOUND")
endif()

# Finalize
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
    libtrixi
    REQUIRED_VARS   LIBTRIXI_LIBRARY LIBTRIXI_INCLUDE_DIR
    VERSION_VAR     LIBTRIXI_VERSION_STRING
)

set(LIBTRIXI_LIBRARIES ${LIBTRIXI_LIBRARY})
set(LIBTRIXI_INCLUDE_DIRS ${LIBTRIXI_INCLUDE_DIR})
