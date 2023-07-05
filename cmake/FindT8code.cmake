#
# Stop if already found
#
if ( T8CODE_FOUND )
    return()
endif()



#
# Look for include, libs, executables
#
find_path ( T8CODE_INCLUDE_DIR t8.h PATHS ${T8CODE_PREFIX}/include )
find_program ( T8CODE_VERSION_EXE t8_version PATHS ${T8CODE_PREFIX}/bin )
find_library ( T8CODE_LIBRARY t8 PATHS ${T8CODE_PREFIX}/lib )



#
# Extract version
#
execute_process(
    COMMAND ${T8CODE_VERSION_EXE}
    OUTPUT_VARIABLE T8CODE_VERSION_STRING
    RESULT_VARIABLE RESULT
)

if( RESULT EQUAL 0 )
  string(REGEX REPLACE "\\[t8\\] ([0-9]+\\.[0-9]+\\.[0-9]+).*" "\\1" T8CODE_VERSION_STRING ${T8CODE_VERSION_STRING} )
endif ()



#
# Finalize
#
include ( FindPackageHandleStandardArgs )
find_package_handle_standard_args(
    T8code
    REQUIRED_VARS   T8CODE_LIBRARY T8CODE_INCLUDE_DIR
    VERSION_VAR     T8CODE_VERSION_STRING
)
