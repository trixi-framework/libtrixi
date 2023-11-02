program trixi_controller_data_f
  use LibTrixi
  use, intrinsic :: iso_fortran_env, only: error_unit
  use, intrinsic :: iso_c_binding, only: c_int, c_double

  implicit none

  integer(c_int) :: handle, nelements, nvariables, steps, i
  character(len=256) :: argument
  integer, parameter :: dp = selected_real_kind(12)
  real(dp), dimension(:), pointer :: data => null()


  if (command_argument_count() < 1) then
    call get_command_argument(0, argument)
    write(error_unit, '(a)') "ERROR: missing arguments: PROJECT_DIR LIBELIXIR_PATH"
    write(error_unit, '(a)') ""
    write(error_unit, '(3a)') "usage: ", trim(argument), " PROJECT_DIR LIBELIXIR_PATH"
    call exit(2)
  else if (command_argument_count() < 2) then
    call get_command_argument(0, argument)
    write(error_unit, '(a)') "ERROR: missing argument: LIBELIXIR_PATH"
    write(error_unit, '(a)') ""
    write(error_unit, '(3a)') "usage: ", trim(argument), " PROJECT_DIR LIBELIXIR_PATH"
    call exit(2)
  end if


  ! Initialize Trixi
  write(*, '(a)') ""
  write(*, '(a)') "*** Trixi controller ***   Initialize Trixi"
  call get_command_argument(1, argument)
  call trixi_initialize(argument)

  ! Set up the Trixi simulation
  ! We get a handle to use subsequently
  write(*, '(a)') "*** Trixi controller ***   Set up Trixi simulation"
  call get_command_argument(2, argument)
  handle = trixi_initialize_simulation(argument)

  ! get number of variables
  nvariables = trixi_nvariables( handle );
  write(*, '(a)') ""
  write(*, '(a,i6)') "*** Trixi controller ***   nvariables ", nvariables
  write(*, '(a)') ""

  ! Main loop
  steps = 0
  write(*, '(a)') "*** Trixi controller ***   Entering main loop"

  do
    ! Exit loop once simulation is completed
    if ( trixi_is_finished(handle) ) exit

    call trixi_step(handle)
    steps = steps + 1

    if (modulo(steps, 10) == 0) then
      ! get number of elements
      nelements = trixi_nelements(handle);
      write(*, '(a)') ""
      write(*, '(a,i6)') "*** Trixi controller ***   nelements ", nelements

      ! allocate memory
      if ( associated(data) ) deallocate(data)
      allocate( data(nelements*nvariables) )

      ! get averaged cell values for each variable
      call trixi_load_cell_averages(data, handle)
    end if
  end do

  ! print first variable
  do i = 1,nelements
    print "('u[cell  ', i4, '] = ', e14.8)", i, data(i)
  end do

  ! Finalize Trixi simulation
  write(*, '(a)') ""
  write(*, '(a)') "*** Trixi controller ***   Finalize Trixi simulation"
  call trixi_finalize_simulation(handle)

  ! Finalize Trixi
  write(*, '(a)') ""
  write(*, '(a)') "*** Trixi controller ***   Finalize Trixi"
  call trixi_finalize()

  deallocate(data)
  nullify(data)
end program
