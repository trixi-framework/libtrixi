!! This file is part of test-drive.
!! SPDX-Identifier: Apache-2.0 OR MIT
!!
!! Licensed under either of Apache License, Version 2.0 or MIT license
!! at your option; you may not use this file except in compliance with
!! the License.
!!
!! Unless required by applicable law or agreed to in writing, software
!! distributed under the License is distributed on an "AS IS" BASIS,
!! WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
!! See the License for the specific language governing permissions and
!! limitations under the License.

!> Driver for unit testing
program tester
  use, intrinsic :: iso_fortran_env, only : error_unit
  use testdrive, only : run_testsuite, new_testsuite, testsuite_type, &
    & select_suite, run_selected, get_argument
  use juliaCode_suite,     only : collect_juliaCode_suite
  use simulationRun_suite, only : collect_simulationRun_suite
  use t8code_suite,        only : collect_t8code_suite
  use versionInfo_suite,   only : collect_versionInfo_suite
  implicit none
  integer :: stat, is
  character(len=:), allocatable :: suite_name, test_name
  type(testsuite_type), allocatable :: testsuites(:)
  character(len=*), parameter :: fmt = '("#", *(1x, a))'

  stat = 0

  testsuites = [ new_testsuite("juliaCode_suite",     collect_juliaCode_suite),     &
                 new_testsuite("simulationRun_suite", collect_simulationRun_suite), &
                 new_testsuite("t8code_suite",        collect_t8code_suite),        &
                 new_testsuite("versionInfo_suite",   collect_versionInfo_suite) ]

  call get_argument(1, suite_name)
  call get_argument(2, test_name)

  if (allocated(suite_name)) then
    is = select_suite(testsuites, suite_name)
    if (is > 0 .and. is <= size(testsuites)) then
      if (allocated(test_name)) then
        write(error_unit, fmt) "Suite:", testsuites(is)%name
        call run_selected(testsuites(is)%collect, test_name, error_unit, stat)
        if (stat < 0) then
          error stop 1
        end if
      else
        write(error_unit, fmt) "Testing:", testsuites(is)%name
        call run_testsuite(testsuites(is)%collect, error_unit, stat)
      end if
    else
      write(error_unit, fmt) "Available testsuites"
      do is = 1, size(testsuites)
        write(error_unit, fmt) "-", testsuites(is)%name
      end do
      error stop 1
    end if
  else
    do is = 1, size(testsuites)
      write(error_unit, fmt) "Testing:", testsuites(is)%name
      call run_testsuite(testsuites(is)%collect, error_unit, stat)
    end do
  end if

  if (stat > 0) then
    write(error_unit, '(i0, 1x, a)') stat, "test(s) failed!"
    error stop 1
  end if

end program tester
