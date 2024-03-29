#
# Stop if already found
#
if ( LIBTRIXI_FOUND )
    return()
endif()

#
# Look for include, libs, version file
#
find_path ( LIBTRIXI_INCLUDE_DIR trixi.h PATHS ${LIBTRIXI_PREFIX}/include )
find_library ( LIBTRIXI_LIBRARY trixi PATHS ${LIBTRIXI_PREFIX}/lib )
find_file ( LIBTRIXI_VERSION_FILE LIBTRIXI_VERSION PATHS ${LIBTRIXI_PREFIX}/share/julia )

#
# Extract version
#
file ( STRINGS ${LIBTRIXI_VERSION_FILE} LIBTRIXI_VERSION_STRING )

#
# Finalize
#
include ( FindPackageHandleStandardArgs )
find_package_handle_standard_args(
    LibTrixi
    REQUIRED_VARS   LIBTRIXI_LIBRARY LIBTRIXI_INCLUDE_DIR
    VERSION_VAR     LIBTRIXI_VERSION_STRING
)
