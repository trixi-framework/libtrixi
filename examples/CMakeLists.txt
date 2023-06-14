#
# Fortran Hello World
#
add_executable(fortran_hello_world fortran_hello_world.f90)

target_link_directories(fortran_hello_world PRIVATE ${CMAKE_BINARY_DIR})

target_link_libraries(fortran_hello_world PRIVATE ${MPI_Fortran_LIBRARIES} ${JULIA_LIBRARY} ${PROJECT_NAME})

target_include_directories(fortran_hello_world PRIVATE ${MPI_Fortran_INCLUDE_DIRS})

# Set runtime path for installed binaries
set_target_properties( fortran_hello_world PROPERTIES INSTALL_RPATH "../lib")

install( TARGETS fortran_hello_world )
