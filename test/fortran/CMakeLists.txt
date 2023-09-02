set ( TESTS
      juliaCode_suite
      simulationRun_suite
      versionInfo_suite )

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

# set include directories
target_include_directories(
    ${TARGET_NAME}
    PRIVATE ${CMAKE_SOURCE_DIR}/src
)

# enable warnings
target_compile_options( ${TARGET_NAME} PRIVATE -cpp -Wall -Wextra -Werror -Wno-uninitialized )

# pass julia project path
target_compile_definitions( ${TARGET_NAME} PRIVATE 
                            JULIA_PROJECT_PATH=\"${JULIA_PROJECT_PATH}\" )

# add tests
foreach ( TEST ${TESTS} )
    add_test( test-drive/${TEST} ${TARGET_NAME} ${TEST} )
endforeach()
