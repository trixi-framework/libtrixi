module t8code_suite
  use LibTrixi
  use testdrive, only : new_unittest, unittest_type, error_type, check
  use, intrinsic :: iso_c_binding, only: c_ptr, c_null_ptr, c_associated

  implicit none
  private

  public :: collect_t8code_suite

  character(len=*), parameter, public :: julia_project_path = JULIA_PROJECT_PATH
  character(len=*), parameter, public :: libelixir_path = &
    "../../../LibTrixi.jl/examples/libelixir_t8code_2d_dgsem_advection_amr.jl"

  contains

  !> Collect all exported unit tests
  subroutine collect_t8code_suite(testsuite)
    !> Collection of tests
    type(unittest_type), allocatable, intent(out) :: testsuite(:)

    testsuite = [ new_unittest("t8code", test_t8code) ]
  end subroutine collect_t8code_suite

  subroutine test_t8code(error)
    type(error_type), allocatable, intent(out) :: error
    integer :: handle
    type(c_ptr) :: forest

    ! Initialize Trixi
    call trixi_initialize(julia_project_path)

    ! Set up the Trixi simulation, get a handle
    handle = trixi_initialize_simulation(libelixir_path)
    call check(error, handle, 1)

    ! Check t8code forest pointer
    forest = c_null_ptr
    forest = trixi_get_t8code_forest(handle)
    call check(error, c_associated(forest))

    ! Finalize Trixi simulation
    call trixi_finalize_simulation(handle)
    
    ! Finalize Trixi
    call trixi_finalize()
  end subroutine test_t8code

end module t8code_suite
