# Specify the minimum version (3.9 required for regex submatches).
cmake_minimum_required ( VERSION 3.9 )

# Reconfigure if Project.toml has changed
set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS "${CMAKE_SOURCE_DIR}/LibTrixi.jl/Project.toml")
# Get project version from LibTrixi.jl
file(READ "${CMAKE_SOURCE_DIR}/LibTrixi.jl/Project.toml" libtrixi_project_toml)
# Parse string
if (${libtrixi_project_toml} MATCHES "version = \"(([0-9]+)\\.([0-9]+)\\.([0-9]+)([+-]([A-Za-z0-9_-]+))?)\"")
  set(LIBTRIXI_VERSION ${CMAKE_MATCH_1})
  set(LIBTRIXI_VERSION_MAJOR ${CMAKE_MATCH_2})
  set(LIBTRIXI_VERSION_MINOR ${CMAKE_MATCH_3})
  set(LIBTRIXI_VERSION_PATCH ${CMAKE_MATCH_4})
  set(LIBTRIXI_VERSION_PRERELEASE ${CMAKE_MATCH_6})
else()
  message(FATAL_ERROR "Unable to parse version from LibTrixi.jl/Project.toml")
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

# Find google test on demand
option( TESTING "Build tests using google test" )
if( TESTING )
    find_package( GTest REQUIRED )
    if ( NOT DEFINED JULIA_PROJECT_PATH )
        message( WARNING "JULIA_PROJECT_PATH not set, tests will not work.")
    else()
        set( JULIA_PROJECT_PATH ${JULIA_PROJECT_PATH} CACHE PATH "Path to julia project.")
    endif()
endif()



# Library target
add_library ( ${PROJECT_NAME} SHARED
    src/api.c
    src/api.f90
    src/auxiliary.h
    src/auxiliary.c
    src/trixi.h
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
target_include_directories( ${PROJECT_NAME} PRIVATE src ${JULIA_INCLUDE_DIRS} )

# Libraries to link
target_link_libraries( ${PROJECT_NAME} PRIVATE ${JULIA_LIBRARY} MPI::MPI_C )

# Set appropriate compile flags
target_compile_options( ${PROJECT_NAME} PUBLIC "-fPIC" )
target_compile_options( ${PROJECT_NAME} PRIVATE -Wall -Wextra -Werror)



# Add auxiliary *object* library to support fast thread-local storage (TLS)
add_library ( ${PROJECT_NAME}_tls OBJECT
    src/tls.c
)
target_include_directories( ${PROJECT_NAME}_tls PRIVATE ${JULIA_INCLUDE_DIRS} )

# Add examples
add_subdirectory( examples )

# Add test on demand
if( TESTING )
    add_subdirectory( test )
endif()


# Install configuration
install( TARGETS ${PROJECT_NAME} )
install( FILES ${CMAKE_Fortran_MODULE_DIRECTORY}/libtrixi.mod TYPE INCLUDE)
install( FILES $<TARGET_OBJECTS:${PROJECT_NAME}_tls> TYPE LIB RENAME lib${PROJECT_NAME}_tls.o )
install( DIRECTORY LibTrixi.jl DESTINATION share/libtrixi )
install( PROGRAMS utils/libtrixi-init-julia TYPE BIN )
