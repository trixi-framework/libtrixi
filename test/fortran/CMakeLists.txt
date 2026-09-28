set ( TESTS
      juliaCode_suite
      simulationRun_suite
      versionInfo_suite )

if ( T8CODE_FOUND )
      list( APPEND TESTS t8code_suite )
endif()

set ( TEST_SRCS
      "main.f90"
)

foreach ( TEST ${TESTS} )
    list( APPEND TEST_SRCS ${TEST}.f90 )
endforeach()

# define fortran-tester target
set ( TARGET_NAME fortran-tester )
add_executable( ${TARGET_NAME} ${TEST_SRCS} )

# set libraries to link
target_link_libraries(
    ${TARGET_NAME}
    PRIVATE MPI::MPI_Fortran ${PROJECT_NAME} ${PROJECT_NAME}_tls "test-drive::test-drive"
)
if ( T8CODE_FOUND )
    target_link_libraries( ${TARGET_NAME} PRIVATE T8CODE::T8 )
endif()

# set include directories
target_include_directories(
    ${TARGET_NAME}
    PRIVATE ${CMAKE_SOURCE_DIR}/src
)
if ( T8CODE_FOUND )
    target_include_directories( ${TARGET_NAME} PRIVATE ${T8CODE_ROOT}/include/t8_fortran_interface/ )
endif()

# enable warnings
target_compile_options( ${TARGET_NAME} PRIVATE -cpp -Wno-uninitialized )

# Potentially, enable warnings
if( LIBTRIXI_ENABLE_WARNINGS )
    target_compile_options( ${TARGET_NAME} PRIVATE ${LIBTRIXI_WARNING_OPTIONS})
endif()

# Potentially, enable to interpret warnings as errors
if( LIBTRIXI_ENABLE_WERROR )
    target_compile_options( ${TARGET_NAME} PRIVATE ${LIBTRIXI_WERROR_OPTION})
endif()

# pass julia project path
target_compile_definitions( ${TARGET_NAME} PRIVATE 
                            JULIA_PROJECT_PATH=\"${JULIA_PROJECT_PATH}\" )

# add tests
foreach ( TEST ${TESTS} )
    add_test( test-drive/${TEST} ${TARGET_NAME} ${TEST} )
endforeach()
