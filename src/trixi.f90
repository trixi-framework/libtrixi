module LibTrixi
  implicit none

  interface
    subroutine trixi_initialize_c(project_directory, depot_path) bind(c, name='trixi_initialize')
      use, intrinsic :: iso_c_binding, only: c_char, c_int
      character(kind=c_char), dimension(*), intent(in) :: project_directory
      character(kind=c_char), dimension(*), intent(in), optional :: depot_path
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

    subroutine julia_eval_string_c(code) bind(c, name='julia_eval_string')
      use, intrinsic :: iso_c_binding, only: c_char
      character(kind=c_char), dimension(*), intent(in) :: code
    end subroutine
  end interface

  contains

  logical function trixi_is_finished(handle)
    use, intrinsic :: iso_c_binding, only: c_int
    integer(c_int), intent(in) :: handle

    trixi_is_finished = trixi_is_finished_c(handle) == 1
  end function

  subroutine trixi_initialize(project_directory, depot_path)
    use, intrinsic :: iso_c_binding, only: c_null_char
    character(len=*), intent(in) :: project_directory
    character(len=*), intent(in), optional :: depot_path

    if (present(depot_path)) then
      call trixi_initialize_c(trim(adjustl(project_directory)) // c_null_char, &
                              trim(adjustl(depot_path)) // c_null_char)
    else
      call trixi_initialize_c(trim(adjustl(project_directory)) // c_null_char)
    end if
  end subroutine

  integer(c_int) function trixi_initialize_simulation(libelixir)
    use, intrinsic :: iso_c_binding, only: c_int, c_null_char
    character(len=*), intent(in) :: libelixir

    trixi_initialize_simulation = trixi_initialize_simulation_c(trim(adjustl(libelixir)) // c_null_char)
  end function

  subroutine julia_eval_string(code)
    use, intrinsic :: iso_c_binding, only: c_null_char
    character(len=*), intent(in) :: code

    call julia_eval_string_c(trim(adjustl(code)) // c_null_char)
  end subroutine
end module
