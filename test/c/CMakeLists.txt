include( GoogleTest )

set ( TESTS
      auxiliary.cpp
      interface_c.cpp
      simulation.cpp )


foreach ( TEST ${TESTS} )

    get_filename_component ( TEST_BASE ${TEST} NAME_WE )

    # define target
    set ( TARGET_NAME ${TEST_BASE} )
    add_executable ( ${TARGET_NAME} ${TEST})

    # set libraries to link
    target_link_libraries(
        ${TARGET_NAME}
        PRIVATE MPI::MPI_CXX ${PROJECT_NAME} ${PROJECT_NAME}_tls GTest::gtest_main
    )

    # set include directories
    target_include_directories(
        ${TARGET_NAME}
        PRIVATE ${CMAKE_SOURCE_DIR}/src
    )

    # enable warnings
    target_compile_options( ${TARGET_NAME} PRIVATE -Wall -Wextra -Werror )

    # pass julia project path
    target_compile_definitions( ${TARGET_NAME} PRIVATE 
                                JULIA_PROJECT_PATH=\"${JULIA_PROJECT_PATH}\" )

    # discover tests
    gtest_discover_tests( ${TARGET_NAME} )

endforeach()

set_property(TARGET simulation
             PROPERTY CROSSCOMPILING_EMULATOR
             ${MPIEXEC_EXECUTABLE} ${MPIEXEC_NUMPROC_FLAG} 2
            )

# manually add MPI test
gtest_add_tests( TARGET simulation
                 TEST_SUFFIX "_MPI" )
