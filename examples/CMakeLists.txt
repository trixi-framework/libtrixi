set ( EXAMPLES
      simple_trixi_controller.c
      simple_trixi_controller.f90
      trixi_controller_data.c
      trixi_controller_data.f90 )


foreach ( EXAMPLE ${EXAMPLES} )

    get_filename_component ( EXAMPLE_EXT ${EXAMPLE} EXT )
    get_filename_component ( EXAMPLE_BASE ${EXAMPLE} NAME_WE )

    if ( ${EXAMPLE_EXT} STREQUAL ".c" )
        set ( EXAMPLE_LANG "C" )
        set ( TARGET_EXT "c" )
    elseif ( ${EXAMPLE_EXT} STREQUAL ".f90" )
        set ( EXAMPLE_LANG "Fortran" )
        set ( TARGET_EXT "f" )
    else ()
        message( FATAL_ERROR "Cannot handle extension " ${EXAMPLE_EXT} )
    endif()

    # define target
    set ( TARGET_NAME ${EXAMPLE_BASE}_${TARGET_EXT} )
    add_executable ( ${TARGET_NAME} ${EXAMPLE})

    # set libraries to link
    target_link_libraries(
        ${TARGET_NAME}
        PRIVATE MPI::MPI_${EXAMPLE_LANG} ${PROJECT_NAME} ${PROJECT_NAME}_tls
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

    # add to installation
    install( TARGETS ${TARGET_NAME} )

endforeach()

# install the julia controller example as well
install( PROGRAMS simple_trixi_controller.jl DESTINATION share/libtrixi/examples/ )
