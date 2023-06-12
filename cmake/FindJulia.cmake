#
# Stop if already found
#
if ( JULIA_FOUND )
    return()
endif()



#
# Find julia executable
#
find_program ( JULIA_EXECUTABLE julia DOC "Julia executable" )

if ( NOT JULIA_EXECUTABLE )
    return()
endif()



#
# Once julia is found, use julia-config
#
execute_process(
    COMMAND ${JULIA_EXECUTABLE} -e "print(dirname(Sys.BINDIR))"
    OUTPUT_VARIABLE JULIA_HOME
    RESULT_VARIABLE RESULT
)
if( NOT RESULT EQUAL 0 )
    message( WARNING "Could not determine julia's home directory" )
endif()

execute_process(
    COMMAND ${JULIA_EXECUTABLE} -e "print(joinpath(Sys.BINDIR, Base.DATAROOTDIR, \"julia\"))"
    OUTPUT_VARIABLE JULIA_SHARE
    RESULT_VARIABLE RESULT
)
if( NOT RESULT EQUAL 0 )
    message( WARNING "Could not determine julia's share directory" )
endif()



#
# Get flags
#
execute_process(
    COMMAND ${JULIA_SHARE}/julia-config.jl --cflags
    OUTPUT_VARIABLE JULIA_CFLAGS
    RESULT_VARIABLE RESULT
)

execute_process(
    COMMAND ${JULIA_SHARE}/julia-config.jl --ldflags
    OUTPUT_VARIABLE JULIA_LDLAGS
    RESULT_VARIABLE RESULT
)

execute_process(
    COMMAND ${JULIA_SHARE}/julia-config.jl --ldlibs
    OUTPUT_VARIABLE JULIA_LDLIBS
    RESULT_VARIABLE RESULT
)



#
# Julia includes
#
string ( REGEX REPLACE ".*-I'(.*)'.*" "\\1" JULIA_INCLUDE_DIRS ${JULIA_CFLAGS} )
set ( JULIA_INCLUDE_DIRS ${JULIA_INCLUDE_DIRS} CACHE PATH "Julia include directory" )



#
# Julia library location
#
execute_process(
    COMMAND ${JULIA_EXECUTABLE} -e "using Libdl; print(abspath(dirname(Libdl.dlpath(\"libjulia\"))))"
    OUTPUT_VARIABLE JULIA_LIBRARY_DIR
    RESULT_VARIABLE RESULT
)
if( RESULT EQUAL 0 )
    set( JULIA_LIBRARY_DIR ${JULIA_LIBRARY_DIR} CACHE PATH "Julia library directory" )
else()
    message( WARNING "Could not determine julia's library directory" )
endif()

find_library( JULIA_LIBRARY
    NAMES julia
    PATHS ${JULIA_LIBRARY_DIR}
)



#
# Extract julia version
#
execute_process(
    COMMAND ${JULIA_EXECUTABLE} --version
    OUTPUT_VARIABLE JULIA_VERSION_STRING
    RESULT_VARIABLE RESULT
)

if( RESULT EQUAL 0 )
  string(REGEX REPLACE ".*([0-9]+\\.[0-9]+\\.[0-9]+).*" "\\1" JULIA_VERSION_STRING ${JULIA_VERSION_STRING} )
endif ()



#
# Finalize
#
include ( FindPackageHandleStandardArgs )
find_package_handle_standard_args(
    Julia
    REQUIRED_VARS   JULIA_LIBRARY JULIA_LIBRARY_DIR JULIA_INCLUDE_DIRS
    VERSION_VAR     JULIA_VERSION_STRING
)
