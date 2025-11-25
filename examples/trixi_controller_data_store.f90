program trixi_controller_data_store_f
  use LibTrixi
  use, intrinsic :: iso_fortran_env, only: error_unit
  use, intrinsic :: iso_c_binding, only: c_int, c_double, c_f_pointer, c_ptr

  implicit none

  integer(c_int) :: handle, ndofs, steps, i
  character(len=256) :: argument
  integer, parameter :: dp = selected_real_kind(12)
  real(dp) :: tracer, rho_val, rho_tracer_val
  real(dp), dimension(:), pointer :: rho => null(), rho_tracer => null()
  type(c_ptr) :: raw_data_c
  real(c_double), dimension(:), pointer :: raw_data


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

  ! Main loop
  steps = 0
  write(*, '(a)') "*** Trixi controller ***   Entering main loop"

  do
    ! Exit loop once simulation is completed
    if ( trixi_is_finished(handle) ) exit

    call trixi_step(handle)
    steps = steps + 1

    if (modulo(steps, 100) == 0) then
      ! get number of degrees of freedom
      ndofs = trixi_ndofsglobal(handle)

      ! Get a pointer to Trixi's internal simulation data
      raw_data_c = trixi_get_conservative_vars_pointer(handle)
      call c_f_pointer(raw_data_c, raw_data, [ndofs])

      do i = 1,ndofs
        ! density comes first
        rho_val = raw_data(5*(i-1) + 1 )

        ! tracer comes last
        rho_tracer_val = raw_data(5*i)

        ! Apply 10% damping to tracer (fraction of density)
        tracer = 0.9 * (rho_tracer_val / rho_val)
        raw_data(5*i) = tracer * rho_val
      end do
    end if

    if (modulo(steps, 100) == 50) then
      ! get number of degrees of freedom
      ndofs = trixi_ndofsglobal(handle)

      ! allocate memory
      if ( associated(rho) ) deallocate(rho)
      allocate( rho(ndofs) )
      if ( associated(rho_tracer) ) deallocate(rho_tracer)
      allocate( rho_tracer(ndofs) )

      ! get density and tracer
      call trixi_load_conservative_var(handle, 1, rho)
      call trixi_load_conservative_var(handle, 5, rho_tracer)

      do i = 1,ndofs
        ! apply 5% amplification to tracer (fraction of density)
        tracer = 1.05 * (rho_tracer(i) / rho(i))
        rho_tracer(i) = tracer * rho(i)
      end do

      ! write back tracer
      call trixi_store_conservative_var(handle, 5, rho_tracer)
    end if
  end do

  ! Finalize Trixi simulation
  write(*, '(a)') ""
  write(*, '(a)') "*** Trixi controller ***   Finalize Trixi simulation"
  call trixi_finalize_simulation(handle)

  ! Finalize Trixi
  write(*, '(a)') ""
  write(*, '(a)') "*** Trixi controller ***   Finalize Trixi"
  call trixi_finalize()

  deallocate(rho)
  nullify(rho)
  deallocate(rho_tracer)
  nullify(rho_tracer)
end program
