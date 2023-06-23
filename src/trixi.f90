module LibTrixi
  implicit none

  interface
    subroutine trixi_initialize(project_directory) bind(c)
      use, intrinsic :: iso_c_binding, only: c_char
      character(kind=c_char), intent(in) :: project_directory(*)
    end subroutine

    integer(c_int) function trixi_initialize_simulation(libelixir) bind(c)
      use, intrinsic :: iso_c_binding, only: c_char, c_int
      character(kind=c_char), intent(in) :: libelixir(*)
    end function

    real(c_double) function trixi_calculate_dt(handle) bind(c)
      use, intrinsic :: iso_c_binding, only: c_int, c_double
      integer(c_int), value, intent(in) :: handle
    end function

    integer(c_int) function trixi_is_finished(handle) bind(c)
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
end module
