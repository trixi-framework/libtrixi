enable_testing()

include( GoogleTest )

set ( TESTS
      auxiliary.cpp
      interface_c.cpp )


foreach ( TEST ${TESTS} )

    get_filename_component ( TEST_BASE ${TEST} NAME_WE )

    # define target
    set ( TARGET_NAME ${TEST_BASE} )
    add_executable ( ${TARGET_NAME} ${TEST})

    # set libraries to link
    target_link_libraries(
        ${TARGET_NAME}
        PRIVATE MPI::MPI_C ${PROJECT_NAME} ${PROJECT_NAME}_tls GTest::gtest_main
    )

    # set include directories
    target_include_directories(
        ${TARGET_NAME}
        PRIVATE ${CMAKE_SOURCE_DIR}/src
    )

    # set runtime path for installed binaries
    set_target_properties(
        ${TARGET_NAME}
        PROPERTIES INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib"
    )

    # enable warnings
    target_compile_options( ${TARGET_NAME} PRIVATE -Wall -Wextra -Werror )

    # pass julia project path
    target_compile_definitions( ${TARGET_NAME} PRIVATE 
                                JULIA_PROJECT_PATH=\"${JULIA_PROJECT_PATH}\" )

    # TODO: add to installation?
    #install( TARGETS ${TARGET_NAME} )

    # discover tests
    gtest_discover_tests( ${TARGET_NAME} )

endforeach()

setup_target_for_coverage_gcovr_html( NAME coverage
                                      EXCLUDE "./test" )
