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
file(WRITE "${CMAKE_BINARY_DIR}/LIBTRIXI_VERSION" "${LIBTRIXI_VERSION}\n")

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

# Find t8code
find_package( T8code )
if ( NOT T8CODE_FOUND )
    message( NOTICE "t8code not found: t8code examples will NOT be built")
endif()

# Find MPI
find_package( MPI REQUIRED )

# Find Google Test and test-drive on demand
option( ENABLE_TESTING "Build tests using Google Test (C) and test-drive (Fortran)" )
if( ENABLE_TESTING )
    if ( NOT DEFINED JULIA_PROJECT_PATH )
        message( FATAL_ERROR "JULIA_PROJECT_PATH not set, tests will not work.")
    endif()
    set( JULIA_PROJECT_PATH ${JULIA_PROJECT_PATH} CACHE PATH
                            "Path to Julia project (typically 'libtrixi-julia').")

    find_package( GTest REQUIRED )

    set ( TEST_DRIVE_FIND_METHOD fetch )
    # Option TEST_DRIVE_BUILD_TESTING is hard-coded to ON, could be spared
    find_package( test-drive REQUIRED )
endif()

# Optionally use PackageCompiler.jl to build standalone libtrixi.so
option( USE_PACKAGE_COMPILER "Build standalone libtrixi.so using PackageCompiler.jl" )

# Fortran mod file location
set(CMAKE_Fortran_MODULE_DIRECTORY ${CMAKE_BINARY_DIR})

if( USE_PACKAGE_COMPILER )
    if ( NOT DEFINED JULIA_PROJECT_PATH )
        message( FATAL_ERROR "JULIA_PROJECT_PATH needs to be set for PackageCompiler.jl.")
    endif()
    if ( ENABLE_TESTING )
        message( NOTICE "Testing is not supported when PackageCompiler is used.")
    endif()

    # Copy source with initialization routines; an object file will be created
    file( MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/build-pc )
    file( COPY_FILE ${CMAKE_SOURCE_DIR}/LibTrixi.jl/lib/init.c
                    ${CMAKE_BINARY_DIR}/build-pc/init.c
                    ONLY_IF_DIFFERENT )

    # Define PackageCompiler.jl output file
    set( PC_LIBTRIXI_SO ${CMAKE_BINARY_DIR}/prefix-pc/lib/libtrixi.so )

    # Add a library target (libtrixi), only for Fortran module
    add_library( ${PROJECT_NAME} OBJECT
        src/api.f90
    )

    # Custom command to run PackageCompiler.jl to produce libtrixi.so
    add_custom_command( OUTPUT ${PC_LIBTRIXI_SO}
                        COMMENT "Building ${PROJECT_NAME} with PackageCompiler.jl..."
                        COMMAND ${JULIA_EXECUTABLE}
                                --project=${CMAKE_SOURCE_DIR}/LibTrixi.jl/lib
                                ${CMAKE_SOURCE_DIR}/LibTrixi.jl/lib/build.jl
                                ${JULIA_PROJECT_PATH}
                                ${CMAKE_BINARY_DIR}/prefix-pc
                        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/build-pc )

    # Custom target for PackageCompiler.jl's libtrixi.so
    add_custom_target( PC_LIBTRIXI DEPENDS ${PC_LIBTRIXI_SO} )

    # Dependency of main library target on PackageCompiler.jl target
    add_dependencies( ${PROJECT_NAME} PC_LIBTRIXI )

    # Add linking to PackageCompiler.jl's libtrixi.so
    target_link_libraries( ${PROJECT_NAME} INTERFACE ${PC_LIBTRIXI_SO} )

    # Install configuration
    install( DIRECTORY "${CMAKE_BINARY_DIR}/prefix-pc/lib/" TYPE LIB )
    install( DIRECTORY "${CMAKE_BINARY_DIR}/prefix-pc/share/julia"
             DESTINATION share
             PATTERN "cert.pem" EXCLUDE )
else()
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



    # Include directories
    target_include_directories( ${PROJECT_NAME} PRIVATE src ${JULIA_INCLUDE_DIRS} )
    if ( T8CODE_FOUND )
        target_include_directories( ${PROJECT_NAME} PRIVATE ${T8CODE_INCLUDE_DIR} )
    endif()

    # Libraries to link
    target_link_libraries( ${PROJECT_NAME} PRIVATE ${JULIA_LIBRARY} )

    # Set appropriate compile flags
    target_compile_options( ${PROJECT_NAME} PUBLIC "-fPIC" )
    target_compile_options( ${PROJECT_NAME} PRIVATE -Wall -Wextra -Werror)
    # Require C11 standard with GNU extensions for C files
    target_compile_options( ${PROJECT_NAME} PRIVATE $<$<COMPILE_LANGUAGE:C>:-std=gnu11>)
    # Require Fortran 2018 standard for Fortran files
    target_compile_options( ${PROJECT_NAME} PRIVATE $<$<COMPILE_LANGUAGE:Fortran>:-std=f2018>)



    # Add auxiliary *object* library to support fast thread-local storage (TLS)
    add_library ( ${PROJECT_NAME}_tls OBJECT
        src/tls.c
    )
    target_include_directories( ${PROJECT_NAME}_tls PRIVATE ${JULIA_INCLUDE_DIRS} )

    # Add test on demand
    if( ENABLE_TESTING )
        enable_testing()
        add_subdirectory( test/c )
        add_subdirectory( test/fortran )
    endif()


    # Install configuration
    install( FILES $<TARGET_OBJECTS:${PROJECT_NAME}_tls> TYPE LIB RENAME lib${PROJECT_NAME}_tls.o )
    install( FILES "${CMAKE_BINARY_DIR}/LIBTRIXI_VERSION" DESTINATION share/julia )
endif()



# Public header for libtrixi
set_target_properties ( ${PROJECT_NAME} PROPERTIES PUBLIC_HEADER src/trixi.h )

# Common install configuration
install( TARGETS ${PROJECT_NAME} )
install( DIRECTORY LibTrixi.jl DESTINATION share/libtrixi PATTERN "lib" EXCLUDE )
install( FILES ${CMAKE_Fortran_MODULE_DIRECTORY}/libtrixi.mod TYPE INCLUDE)
install( PROGRAMS utils/libtrixi-init-julia TYPE BIN )

# Add examples
add_subdirectory( examples )
