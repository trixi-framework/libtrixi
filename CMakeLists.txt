# Specify the minimum version (3.9 required for regex submatches).
cmake_minimum_required ( VERSION 3.9 )

## Get project version
# Reconfigure if VERSION file has changed
set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS "${CMAKE_SOURCE_DIR}/VERSION")
# Read file
file(READ "${CMAKE_SOURCE_DIR}/VERSION" version_string)
# Parse string
if (${version_string} MATCHES "^([0-9]+)\\.([0-9]+)\\.([0-9]+)([+-][A-Za-z0-9_-]+)?")
  set(LIBTRIXI_VERSION ${CMAKE_MATCH_0})
  set(LIBTRIXI_VERSION_MAJOR ${CMAKE_MATCH_1})
  set(LIBTRIXI_VERSION_MINOR ${CMAKE_MATCH_2})
  set(LIBTRIXI_VERSION_PATCH ${CMAKE_MATCH_3})
else()
  message(FATAL_ERROR "Unable to parse version from string")
endif()

# Specify the project info.
project ( trixi VERSION ${LIBTRIXI_VERSION_MAJOR}.${LIBTRIXI_VERSION_MINOR}.${LIBTRIXI_VERSION_PATCH}
          DESCRIPTION "Interface library for using Trixi.jl from C/C++/Fortran" )

# Enable C and Fortran
enable_language(C Fortran)

# Enabling setting rpath for installation
SET(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)



# Additional cmake modules
list ( APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/" )

# Find Julia
find_package( Julia REQUIRED )



# Find MPI
find_package( MPI REQUIRED )



# Library target
add_library ( ${PROJECT_NAME} SHARED
    src/trixi.c
    src/trixi_version.c
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

# Set appropriate compile flags
target_compile_options( ${PROJECT_NAME} PUBLIC "-fPIC" )

# Pass version information
target_compile_definitions( ${PROJECT_NAME} PRIVATE
                            LIBTRIXI_VERSION=\"${LIBTRIXI_VERSION}\"
                            LIBTRIXI_VERSION_MAJOR=${LIBTRIXI_VERSION_MAJOR}
                            LIBTRIXI_VERSION_MINOR=${LIBTRIXI_VERSION_MINOR}
                            LIBTRIXI_VERSION_PATCH=${LIBTRIXI_VERSION_PATCH})


# Add auxiliary *object* library to support fast thread-local storage (TLS)
add_library ( ${PROJECT_NAME}_tls OBJECT
    src/trixi_tls.c
)
target_include_directories( ${PROJECT_NAME}_tls PRIVATE ${JULIA_INCLUDE_DIRS} )

# Add examples
add_subdirectory( examples )



# Install configuration
install( TARGETS ${PROJECT_NAME} )
install( FILES ${CMAKE_Fortran_MODULE_DIRECTORY}/libtrixi.mod TYPE INCLUDE)
install( FILES $<TARGET_OBJECTS:${PROJECT_NAME}_tls> TYPE LIB RENAME lib${PROJECT_NAME}_tls.o )
install( DIRECTORY LibTrixi.jl DESTINATION share/libtrixi )
install( PROGRAMS utils/libtrixi-init-julia TYPE BIN )
