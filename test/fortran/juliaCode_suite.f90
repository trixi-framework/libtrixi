module juliaCode_suite
  use LibTrixi
  use testdrive, only : new_unittest, unittest_type, error_type, check
  implicit none
  private

  public :: collect_juliaCode_suite

  character(len=*), parameter, public :: julia_project_path = JULIA_PROJECT_PATH

  contains

  !> Collect all exported unit tests
  subroutine collect_juliaCode_suite(testsuite)
    !> Collection of tests
    type(unittest_type), allocatable, intent(out) :: testsuite(:)

    testsuite = [ new_unittest("juliaCode", test_juliaCode) ]
  end subroutine collect_juliaCode_suite

  subroutine test_juliaCode(error)
    type(error_type), allocatable, intent(out) :: error

    ! Initialize Trixi
    call trixi_initialize(julia_project_path)

    ! Execute Julia code
    call trixi_eval_julia('println("Hello from Julia!")');

    ! Finalize Trixi
    call trixi_finalize()
  end subroutine test_juliaCode

end module juliaCode_suite
