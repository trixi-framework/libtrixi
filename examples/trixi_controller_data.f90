program simple_trixi_controller_f
  use LibTrixi
  use, intrinsic :: iso_fortran_env, only: error_unit
  use, intrinsic :: iso_c_binding, only: c_int, c_null_char, c_double, c_loc

  implicit none

  integer(c_int) :: handle, nelements, nvariables, i
  character(len=256) :: argument
  real(c_double), allocatable, target :: data(:)
  real(c_double) :: gas_constant


  if (command_argument_count() < 1) then
    call get_command_argument(0, argument)
    write(error_unit, '(a)') "ERROR: missing arguments: PROJECT_DIR LIBELIXIR_PATH"
    write(error_unit, '(a)') ""
    write(error_unit, '(3a)') "usage: ", trim(argument), " PROJECT_DIR LIBELIXIR_PATH"
    stop 1
  else if (command_argument_count() < 2) then
    call get_command_argument(0, argument)
    write(error_unit, '(a)') "ERROR: missing argument: LIBELIXIR_PATH"
    write(error_unit, '(a)') ""
    write(error_unit, '(3a)') "usage: ", trim(argument), " PROJECT_DIR LIBELIXIR_PATH"
    stop 1
  end if


  ! Initialize Trixi
  call get_command_argument(1, argument)
  call trixi_initialize(argument)

  ! Set up the Trixi simulation
  ! We get a handle to use subsequently
  call get_command_argument(2, argument)
  handle = trixi_initialize_simulation(argument)

  ! Main loop
  do
    ! Exit loop once simulation is completed
    if ( trixi_is_finished(handle) ) exit

    call trixi_step(handle)
  end do

  ! get number of elements
  nelements = trixi_nelements(handle);
  write(*, '(a,i6)') "*** Trixi controller ***   nelements ", nelements
  write(*, '(a)') ""

  ! get number of variables
  nvariables = trixi_nvariables( handle );
  write(*, '(a,i6)') "*** Trixi controller ***   nvariables ", nvariables
  write(*, '(a)') ""

  ! allocate memory
  allocate ( data(0:nelements*nvariables) )

  ! get averaged cell values for each variable
  call trixi_get_cell_averages(c_loc(data),handle);

  ! compute temperature
  gas_constant = 0.287;

  do i = 0,nelements-1
    print "('T[cell  ', i4, '] = ', e14.8)", i, data(i+3*nelements)/(gas_constant*data(i))
  end do

  write(*, '(a,i6)') "*** Trixi controller ***   Finalize Trixi simulation "
  write(*, '(a)') ""

  ! Finalize Trixi simulation
  call trixi_finalize_simulation(handle)

  ! Finalize Trixi
  call trixi_finalize()
end program
