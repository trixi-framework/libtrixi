module LibTrixi
  implicit none

  interface
    subroutine trixi_initialize_c(project_directory) bind(c, name='trixi_initialize')
      use, intrinsic :: iso_c_binding, only: c_char
      character(kind=c_char), dimension(*), intent(in) :: project_directory
    end subroutine

    integer(c_int) function trixi_initialize_simulation_c(libelixir) bind(c, name='trixi_initialize_simulation')
      use, intrinsic :: iso_c_binding, only: c_char, c_int
      character(kind=c_char), dimension(*), intent(in) :: libelixir
    end function

    real(c_double) function trixi_calculate_dt(handle) bind(c)
      use, intrinsic :: iso_c_binding, only: c_int, c_double
      integer(c_int), value, intent(in) :: handle
    end function

    integer(c_int) function trixi_is_finished_c(handle) bind(c, name='trixi_is_finished')
      use, intrinsic :: iso_c_binding, only: c_int
      integer(c_int), value, intent(in) :: handle
    end function

    subroutine trixi_step(handle) bind(c)
      use, intrinsic :: iso_c_binding, only: c_int
      integer(c_int), value, intent(in) :: handle
    end subroutine

    subroutine trixi_finalize_simulation(handle) bind(c)
      use, intrinsic :: iso_c_binding, only: c_int
      integer(c_int), value, intent(in) :: handle
    end subroutine

    subroutine trixi_finalize() bind(c)
    end subroutine

    subroutine julia_eval_string(code) bind(c)
      use, intrinsic :: iso_c_binding, only: c_char
      character(kind=c_char), intent(in) :: code(*)
    end subroutine
  end interface

  contains

  logical function trixi_is_finished(handle)
    use, intrinsic :: iso_c_binding, only: c_int
    integer(c_int), intent(in) :: handle

    trixi_is_finished = trixi_is_finished_c(handle) == 1
  end function

  subroutine trixi_initialize(project_directory)
    use, intrinsic :: iso_c_binding, only: c_null_char
    character(len=*), intent(in) :: project_directory

    call trixi_initialize_c(trim(adjustl(project_directory)) // c_null_char)
  end subroutine

  integer(c_int) function trixi_initialize_simulation(libelixir)
    use, intrinsic :: iso_c_binding, only: c_int, c_null_char
    character(len=*), intent(in) :: libelixir

    trixi_initialize_simulation = trixi_initialize_simulation_c(trim(adjustl(libelixir)) // c_null_char)
  end function

end module
