# Specify the minimum version
cmake_minimum_required ( VERSION 3.12 )

# Specify a project name
project(ExternalLibTrixi)

# Additional cmake modules (should contain FindLibTrixi.cmake)
list ( APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/../../cmake" )

# Find MPI
find_package( MPI REQUIRED )

# Find LibTrixi
find_package( LibTrixi REQUIRED )

# Set sources
set ( TARGET_NAME trixi_controller_simple_c )
add_executable ( ${TARGET_NAME} ${CMAKE_SOURCE_DIR}/../trixi_controller_simple.c )

# Set libraries to link
target_link_libraries(
        ${TARGET_NAME}
        PRIVATE MPI::MPI_C ${LIBTRIXI_LIBRARY}
)

# Set include directories
target_include_directories(
    ${TARGET_NAME}
    PRIVATE ${LIBTRIXI_INCLUDE_DIR}
)

# Set compiler flag for position independent code
target_compile_options( ${TARGET_NAME} PRIVATE "-fPIC" )
