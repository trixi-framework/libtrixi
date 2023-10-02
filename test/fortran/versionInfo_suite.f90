module versionInfo_suite
  use LibTrixi
  use, intrinsic :: iso_c_binding, only: c_null_char
  use testdrive, only : new_unittest, unittest_type, error_type, check
  implicit none
  private

  public :: collect_versionInfo_suite

  character(len=*), parameter, public :: julia_project_path = LIBTRIXI_JULIA_PROJECT

  contains

  !> Collect all exported unit tests
  subroutine collect_versionInfo_suite(testsuite)
    !> Collection of tests
    type(unittest_type), allocatable, intent(out) :: testsuite(:)

    testsuite = [ new_unittest("versionInfo", test_versionInfo) ]
  end subroutine collect_versionInfo_suite

  subroutine test_versionInfo(error)
    type(error_type), allocatable, intent(out) :: error
    character(len=11) :: version_string
    character(len=128) :: version_library
    integer :: string_len, substring_pos

    ! Initialize Trixi
    call trixi_initialize(julia_project_path)

    ! Check libtrixi version information
    write (version_string, '(i0,a,i0,a,i0)') &
           trixi_version_library_major(), ".", &
           trixi_version_library_minor(), ".", &
           trixi_version_library_patch()
    string_len = len_trim(version_string)
    version_library = trixi_version_library()
    call check(error, version_string(1:string_len), version_library(1:string_len))
    
    ! Check Julia packages version information
    substring_pos = index(trixi_version_julia(), "Trixi")
    call check(error, substring_pos /= 0)

    substring_pos = index(trixi_version_julia(), "OrdinaryDiffEq")
    call check(error, substring_pos /= 0)

    substring_pos = index(trixi_version_julia_extended(), "StartUpDG")
    call check(error, substring_pos /= 0)

    ! Finalize Trixi
    call trixi_finalize()
  end subroutine test_versionInfo

end module versionInfo_suite
