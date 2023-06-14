# Specify the minimum version.
cmake_minimum_required ( VERSION 3.0 )

# Specify the project info.
project ( trixi VERSION 0.1.0 DESCRIPTION "Interface library for using Trixi.jl from C/C++/Fortran" )

# Enable fortran
enable_language(Fortran)



# Library target
add_library ( ${PROJECT_NAME} SHARED
    src/trixi.c
    src/trixi.h
    src/trixi.f90
)

# Include directories, private
target_include_directories ( ${PROJECT_NAME} PRIVATE src )

# Version info
set_target_properties ( ${PROJECT_NAME} PROPERTIES VERSION ${PROJECT_VERSION} )

# Version info for the shared object
set_target_properties ( ${PROJECT_NAME} PROPERTIES SOVERSION ${PROJECT_VERSION_MAJOR} )

# Include directories, public for actual users
set_target_properties ( ${PROJECT_NAME} PROPERTIES PUBLIC_HEADER src/trixi.h )



# Additional cmake modules
list ( APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/" )

# Find Julia
find_package( Julia REQUIRED )

include_directories( ${JULIA_INCLUDE_DIRS} )



# Find MPI
find_package( MPI REQUIRED )



# Add examples
add_subdirectory( examples )



target_include_directories(fortran_hello_world PRIVATE ${MPI_Fortran_INCLUDE_DIRS})
