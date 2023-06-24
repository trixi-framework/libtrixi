#
# Fortran Hello World
#
add_executable(fortran_hello_world fortran_hello_world.f90)

target_link_directories(fortran_hello_world PRIVATE ${CMAKE_BINARY_DIR})

target_link_libraries(fortran_hello_world PRIVATE ${MPI_Fortran_LIBRARIES} ${PROJECT_NAME} ${JULIA_LIBRARY})

target_include_directories(fortran_hello_world PRIVATE ${MPI_Fortran_INCLUDE_DIRS})

# Set runtime path for installed binaries
set_target_properties( fortran_hello_world PROPERTIES INSTALL_RPATH "../lib")

install( TARGETS fortran_hello_world )



#
# Simple Trixi Controller (C version)
#
add_executable(simple_trixi_controller_c simple_trixi_controller.c)

target_link_libraries(simple_trixi_controller_c PRIVATE ${MPI_C_LIBRARIES} ${PROJECT_NAME})

target_include_directories(
  simple_trixi_controller_c
  PRIVATE ${CMAKE_SOURCE_DIR}/src ${MPI_C_INCLUDE_DIRS}
)

# Set runtime path for installed binaries
set_target_properties( simple_trixi_controller_c PROPERTIES INSTALL_RPATH "../lib")

install( TARGETS simple_trixi_controller_c )



#
# Simple Trixi Controller (Fortran version)
#
add_executable(simple_trixi_controller_f simple_trixi_controller.f90)

target_link_directories(simple_trixi_controller_f PRIVATE ${CMAKE_BINARY_DIR})

target_link_libraries(simple_trixi_controller_f PRIVATE ${PROJECT_NAME})

target_include_directories(
  simple_trixi_controller_f
  PRIVATE ${CMAKE_SOURCE_DIR}/src ${MPI_Fortran_INCLUDE_DIRS}
)

# Set runtime path for installed binaries
set_target_properties( simple_trixi_controller_f PROPERTIES INSTALL_RPATH "../lib")

install( TARGETS simple_trixi_controller_f )
