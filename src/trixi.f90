!>
!! @addtogroup api_f Fortran API
!!
!! **NOTE**: It is a known limitation of doxygen that Fortran interfaces will be listed as
!! "Data Types". Please refer to the "Functions/Subroutines" section instead.
!!
!! @{

module LibTrixi
  implicit none

  interface
    !>
    !! @fn LibTrixi::trixi_initialize_c::trixi_initialize_c(project_directory, depot_path)
    !!
    !! @brief Initialize Julia runtime environment (C char pointer version)
    !!
    !! Initialize Julia and activate the project at `project_directory`. If `depot_path` is
    !! given, forcefully set the environment variable `JULIA_DEPOT_PATH` to the value of
    !! depot_path`. If `depot_path` is not given, then proceed as follows: If
    !! `JULIA_DEPOT_PATH` is already set, do not touch it. Otherwise, set
    !! `JULIA_DEPOT_PATH` to `project_directory` + `default_depot_path`.
    !!
    !! @param[in]  project_directory  Path to project directory (C char pointer)
    !! @param[in]  depot_path         Path to Julia depot path (optional, C char pointer)
    !!
    !! @see @ref trixi_initialize        "trixi_initialize (Fortran convenience version)"
    !! @see @ref trixi_initialize_api_c  "trixi_initialize (C API)"
    subroutine trixi_initialize_c(project_directory, depot_path) bind(c, name='trixi_initialize')
      use, intrinsic :: iso_c_binding, only: c_char
      character(kind=c_char), dimension(*), intent(in) :: project_directory
      character(kind=c_char), dimension(*), intent(in), optional :: depot_path
    end subroutine

    !>
    !! @fn LibTrixi::trixi_initialize_simulation_c::trixi_initialize_simulation_c(libelexir)
    !!
    !! @brief Set up Trixi simulation (C char pointer version)
    !!
    !! @param[in]  libelixir  Path to libelexir file.
    !!
    !! @return handle (integer) to Trixi simulation instance
    !!
    !! @see @ref trixi_initialize_simulation       "trixi_initialize_simulation (Fortran convenience version)"
    !! @see @ref trixi_initialize_simulation_api_c "trixi_initialize_simulation (C API)"
    integer(c_int) function trixi_initialize_simulation_c(libelixir) bind(c, name='trixi_initialize_simulation')
      use, intrinsic :: iso_c_binding, only: c_char, c_int
      character(kind=c_char), dimension(*), intent(in) :: libelixir
    end function

    !>
    !! @fn LibTrixi::trixi_calculate_dt::trixi_calculate_dt(handle)
    !!
    !! @brief Get time step length
    !!
    !! @param[in]  handle  simulation handle
    !!
    !! @return Time step length
    !!
    !! @see @ref trixi_calculate_dt_api_c "trixi_calculate_dt (C API)"
    real(c_double) function trixi_calculate_dt(handle) bind(c)
      use, intrinsic :: iso_c_binding, only: c_int, c_double
      integer(c_int), value, intent(in) :: handle
    end function

    !>
    !! @fn LibTrixi::trixi_is_finished_c::trixi_is_finished_c(handle)
    !!
    !! @brief Check if simulation is finished (C integer version)
    !!
    !! @param[in]  handle  simulation handle
    !!
    !! @return 1 if finished, 0 if not
    !!
    !! @see @ref trixi_is_finished       "trixi_is_finished (Fortran convenience version)"
    !! @see @ref trixi_is_finished_api_c "trixi_is_finished (C API)"
    integer(c_int) function trixi_is_finished_c(handle) bind(c, name='trixi_is_finished')
      use, intrinsic :: iso_c_binding, only: c_int
      integer(c_int), value, intent(in) :: handle
    end function

    !>
    !! @fn LibTrixi::trixi_step::trixi_step(handle)
    !!
    !! @brief Perform next simulation step
    !!
    !! @param[in]  handle  simulation handle
    !!
    !! @see @ref trixi_step_api_c "trixi_step (C API)"
    subroutine trixi_step(handle) bind(c)
      use, intrinsic :: iso_c_binding, only: c_int
      integer(c_int), value, intent(in) :: handle
    end subroutine

    !>
    !! @fn LibTrixi::trixi_finalize_simulation::trixi_finalize_simulation(handle)
    !!
    !! @brief Finalize simulation
    !!
    !! @param[in]  handle  simulation handle
    !!
    !! @see trixi_finalize_simulation_api_c "trixi_finalize_simulation (C API)"
    subroutine trixi_finalize_simulation(handle) bind(c)
      use, intrinsic :: iso_c_binding, only: c_int
      integer(c_int), value, intent(in) :: handle
    end subroutine

    !>
    !! @fn LibTrixi::trixi_finalize::trixi_finalize()
    !!
    !! @brief Finalize Julia runtime environment.
    !!
    !! @see @ref trixi_finalize_api_c "trixi_finalize (C API)"
    subroutine trixi_finalize() bind(c)
    end subroutine

    !>
    !! @fn LibTrixi::julia_eval_string_c::julia_eval_string_c(code)
    !!
    !! @brief Execute Julia code (C char pointer version)
    !!
    !! @warning Only for development. Code is not checked prior to execution.
    !!
    !! @see @ref julia_eval_string       "julia_eval_string_c (Fortran convenience version)"
    !! @see @ref julia_eval_string_api_c "julia_eval_string_c (C API)"
    subroutine julia_eval_string_c(code) bind(c, name='julia_eval_string')
      use, intrinsic :: iso_c_binding, only: c_char
      character(kind=c_char), dimension(*), intent(in) :: code
    end subroutine

    !>
    !! @fn LibTrixi::trixi_version_major::trixi_version_major()
    !!
    !! @brief Return major version number of libtrixi.
    !!
    !! @return Major version number as integer.
    !!
    !! @see @ref trixi_version_major_api_c "trixi_version_major (C API)"
    integer(c_int) function trixi_version_major() bind(c)
      use, intrinsic :: iso_c_binding, only: c_int
    end function

    !>
    !! @fn LibTrixi::trixi_version_minor::trixi_version_minor()
    !!
    !! @brief Return minor version number of libtrixi.
    !!
    !! @return Minor version number as integer.
    !!
    !! @see @ref trixi_version_minor_api_c "trixi_version_minor (C API)"
    integer(c_int) function trixi_version_minor() bind(c)
      use, intrinsic :: iso_c_binding, only: c_int
    end function

    !>
    !! @fn LibTrixi::trixi_version_patch::trixi_version_patch()
    !!
    !! @brief Return patch version number of libtrixi.
    !!
    !! @return Patch version number as integer.
    !!
    !! @see @ref trixi_version_patch_api_c "trixi_version_patch (C API)"
    integer(c_int) function trixi_version_patch() bind(c)
      use, intrinsic :: iso_c_binding, only: c_int
    end function

    !>
    !! @fn LibTrixi::trixi_version_c::trixi_version_c()
    !!
    !! @brief Return full version string of libtrixi (C char pointer version).
    !!
    !! @return Full version string as C char pointer.
    !!
    !! @see @ref trixi_version       "trixi_version (Fortran convenience version)"
    !! @see @ref trixi_version_api_c "trixi_version (C API)"
    type(c_ptr) function trixi_version_c() bind(c, name='trixi_version')
      use, intrinsic :: iso_c_binding, only: c_ptr
    end function
  end interface

  contains

  !>
  !! @brief Check if simulation is finished (Fortran convenience version)
  !!
  !! @param[in]  handle  simulation handle
  !!
  !! @return true if finished, false if not
  !!
  !! @see @ref trixi_is_finished_c::trixi_is_finished_c
  !!           "trixi_is_finished (C integer version)"
  !! @see @ref trixi_is_finished_api_c
  !!           "trixi_is_finished (C API)"
  logical function trixi_is_finished(handle)
    use, intrinsic :: iso_c_binding, only: c_int
    integer(c_int), intent(in) :: handle

    trixi_is_finished = trixi_is_finished_c(handle) == 1
  end function

  !>
  !! @brief Initialize Julia runtime environment (Fortran convenience version)
  !!
  !! @param[in]  project_directory  Path to project directory (Fortran string).
  !! @param[in]  depot_path         Path to Julia depot path (Fortran string).
  !!
  !! @see @ref trixi_initialize_c::trixi_initialize_c
  !!           "trixi_initialize_c (C char pointer version)"
  !! @see @ref trixi_initialize_api_c
  !!           "trixi_initialize (C API)"
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

  !>
  !! @brief Set up Trixi simulation (Fortran convencience version)
  !!
  !! @param[in]  libelixir  Path to libelexir file.
  !!
  !! @return handle (integer) to Trixi simulation instance
  !!
  !! @see @ref trixi_initialize_simulation_c::trixi_initialize_simulation_c
  !!           "trixi_initialize_simulation_c (C char pointer version)"
  !! @see @ref trixi_initialize_simulation_api_c
  !!           "trixi_initialize_simulation (C API)"
  integer(c_int) function trixi_initialize_simulation(libelixir)
    use, intrinsic :: iso_c_binding, only: c_int, c_null_char
    character(len=*), intent(in) :: libelixir

    trixi_initialize_simulation = trixi_initialize_simulation_c(trim(adjustl(libelixir)) // c_null_char)
  end function

  !>
  !! @brief Execute Julia code (Fortran convenience version)
  !!
  !! @warning Only for development. Code is not checked prior to execution.
  !!
  !! @see @ref julia_eval_string_c::julia_eval_string_c
  !!           "julia_eval_string_c (C char pointer version)"
  !! @see @ref julia_eval_string_api_c
  !!           "julia_eval_string_c (C API)"
  subroutine julia_eval_string(code)
    use, intrinsic :: iso_c_binding, only: c_null_char
    character(len=*), intent(in) :: code

    call julia_eval_string_c(trim(adjustl(code)) // c_null_char)
  end subroutine

  !>
  !! @brief Return full version string of libtrixi (Fortran convenience version).
  !!
  !! @return Full version string as Fortran allocatable string.
  !!
  !! @see @ref trixi_version_c::trixi_version_c
  !!           "trixi_version_c (C char pointer version)"
  !! @see @ref trixi_version_api_c
  !!           "trixi_version (C API)"
  function trixi_version()
    use, intrinsic :: iso_c_binding, only: c_char, c_null_char, c_f_pointer
    character(len=:), allocatable :: trixi_version
    character(len=128, kind=c_char), pointer :: buffer
    integer :: length, i

    ! Associate buffer with C pointer
    call c_f_pointer(trixi_version_c(), buffer)

    ! Determine the actual length of the version string
    length = 0
    do i = 1,128
      if ( buffer(i:i) == c_null_char ) exit
      length = length + 1
    end do

    ! Store relevant part in return value
    trixi_version = buffer(1:(length + 1))
  end function
end module

!>
!! @}