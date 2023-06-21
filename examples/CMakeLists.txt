#
# Fortran Hello World
#
#add_executable(fortran_hello_world fortran_hello_world.f90)

#target_link_directories(fortran_hello_world PRIVATE ${CMAKE_BINARY_DIR})

#target_link_libraries(fortran_hello_world PRIVATE ${MPI_Fortran_LIBRARIES} ${PROJECT_NAME} ${JULIA_LIBRARY})

#target_include_directories(fortran_hello_world PRIVATE ${MPI_Fortran_INCLUDE_DIRS})

# Set runtime path for installed binaries
#set_target_properties( fortran_hello_world PROPERTIES INSTALL_RPATH "../lib")

#install( TARGETS fortran_hello_world )



#
# MESSy mockup
#
add_executable(messy_mockup messy_mockup.c)

#target_link_libraries(messy_mockup PRIVATE ${MPI_C_LIB_NAMES} ${PROJECT_NAME} ${JULIA_LIBRARY})
target_link_libraries(messy_mockup PRIVATE ${PROJECT_NAME} ${MPI_C_LIB_NAMES})

target_include_directories(messy_mockup PRIVATE ${MPI_C_INCLUDE_DIRS} ${CMAKE_SOURCE_DIR}/src)

# Set runtime path for installed binaries
set_target_properties( messy_mockup PROPERTIES INSTALL_RPATH "../lib")

install( TARGETS messy_mockup )
