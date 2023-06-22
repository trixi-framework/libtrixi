# Specify the minimum version.
cmake_minimum_required ( VERSION 3.0 )

# Specify the project info.
project ( trixi VERSION 0.1.0 DESCRIPTION "Interface library for using Trixi.jl from C/C++/Fortran" )

# Enable C and Fortran
enable_language(C Fortran)

# Enabling setting rpath for installation
SET(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)



# Additional cmake modules
list ( APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/" )

# Find Julia
find_package( Julia REQUIRED )



# Find MPI
#find_package( MPI REQUIRED )



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

# Fortran mod file location
set(CMAKE_Fortran_MODULE_DIRECTORY ${CMAKE_BINARY_DIR})



# Include directories
target_include_directories( ${PROJECT_NAME} PRIVATE src ${MPI_C_INCLUDE_DIRS} ${JULIA_INCLUDE_DIRS} )

# Libraries to link
target_link_libraries( ${PROJECT_NAME} PRIVATE ${JULIA_LIBRARY} ${MPI_C_LIB_NAMES})



# Add examples
add_subdirectory( examples )



# Install configuration
install( TARGETS ${PROJECT_NAME} )
install( FILES ${CMAKE_Fortran_MODULE_DIRECTORY}/libtrixi.mod TYPE LIB)
