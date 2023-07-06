set ( EXAMPLES
      simple_trixi_controller.c
      simple_trixi_controller.f90
      simple_t8code.c 
      trixi_controller_data.c )


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
        PRIVATE ${MPI_${EXAMPLE_LANG}_LIBRARIES} ${PROJECT_NAME} ${PROJECT_NAME}_tls ${T8CODE_LIBRARIES}
    )

    # set include directories
    target_include_directories(
        ${TARGET_NAME}
        PRIVATE ${CMAKE_SOURCE_DIR}/src ${MPI_${EXAMPLE_LANG}_INCLUDE_DIRS} ${T8CODE_INCLUDE_DIR}
    )

    # set runtime path for installed binaries
    set_target_properties(
        ${TARGET_NAME}
        PROPERTIES INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib"
    )

    # add to installation
    install( TARGETS ${TARGET_NAME} )

endforeach()
