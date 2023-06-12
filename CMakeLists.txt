# Specify the minimum version.
cmake_minimum_required ( VERSION 3.0 )

# Specify the project info.
project ( libtrixi VERSION 0.1.0 DESCRIPTION "Interface library for using Trixi.jl from C/C++/Fortran" )

set ( PROJECT_SHORT_NAME trixi )

# Library target
add_library ( ${PROJECT_SHORT_NAME} SHARED
    src/libtrixi.c
    src/libtrixi.h
)

# Include directories, private
target_include_directories ( ${PROJECT_SHORT_NAME} PRIVATE src )

# Version info
set_target_properties ( ${PROJECT_SHORT_NAME} PROPERTIES VERSION ${PROJECT_VERSION} )

# Version info for the shared object
set_target_properties ( ${PROJECT_SHORT_NAME} PROPERTIES SOVERSION ${PROJECT_VERSION_MAJOR} )

# Include directories, public for actual users
set_target_properties ( ${PROJECT_SHORT_NAME} PROPERTIES PUBLIC_HEADER src/libtrixi.h )


# Additional cmake modules
list ( APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/" )

# Find Julia
find_package( Julia REQUIRED )

include_directories( ${JULIA_INCLUDE_DIRS} )