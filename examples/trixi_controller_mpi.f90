subroutine init_mpi_external
  use mpi

  implicit none

  logical :: flag_init
  integer :: ierror, provided_threadlevel, requested_threadlevel, comm, rank, nranks

  comm = MPI_COMM_WORLD

  call MPI_Initialized(flag_init, ierror)
  write(*, '(a,i1,a,l,a,i0)') "[EXT] MPI Initialized: return ", ierror, &
                              ", initialized ", flag_init, &
                              ", MPI_COMM_WORLD ", comm

  if (.not.(flag_init)) then
    requested_threadlevel = MPI_THREAD_SERIALIZED
    call MPI_Init_thread(requested_threadlevel, provided_threadlevel, ierror)
    write(*, '(a,i1,a,i1,a,i1)') "[EXT] MPI_Init: return ", ierror, &
                                 ", threadlevel requested ", requested_threadlevel, &
                                 ", provided ", provided_threadlevel
  end if

  call MPI_Comm_rank(comm, rank, ierror)
  write(*, '(a,i1,a,i1)') "[EXT] MPI rank: return ", ierror, ", rank ", rank

  call MPI_Comm_size(comm, nranks, ierror)
  write(*, '(a,i1,a,i1)') "[EXT] MPI size: return ", ierror, ", size ", nranks

  call MPI_Comm_set_errhandler(comm, MPI_ERRORS_RETURN, ierror)
  write(*, '(a,i1,a,i1)') "[EXT] MPI errhandler: return ", ierror
end subroutine


program trixi_controller_mpi_f
  use LibTrixi
  use, intrinsic :: iso_fortran_env, only: error_unit
  use, intrinsic :: iso_c_binding, only: c_int, c_null_char

  implicit none

  integer :: ierror
  integer(c_int) :: handle
  character(len=256) :: argument

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

  ! Initialize MPI
  write(*, '(a)') ""
  write(*, '(a)') "*** Trixi controller ***   Initialize MPI"
  call init_mpi_external()

  ! Initialize Trixi
  write(*, '(a)') ""
  write(*, '(a)') "*** Trixi controller ***   Initialize Trixi"
  call get_command_argument(1, argument)
  call trixi_initialize(argument)

  ! Print version information
  write(*, '(a, i1, a, i1, a, i1, a, a)') "libtrixi version: ", &
        trixi_version_library_major(), ".", trixi_version_library_minor(), ".", &
        trixi_version_library_patch(), " ", trixi_version_library()
  write(*, '(a)') ""
  write(*, '(a)') "All loaded Julia packages:"
  write(*, '(a)') trixi_version_julia_extended()
  write(*, '(a)') ""

  ! Execute Julia code
  write(*, '(a)') "Execute Julia code"
  call trixi_eval_julia('println("3! = ", factorial(3))')
  write(*, '(a)') ""

  ! Set up the Trixi simulation
  ! We get a handle to use subsequently
  write(*, '(a)') "*** Trixi controller ***   Set up Trixi simulation"
  call get_command_argument(2, argument)
  handle = trixi_initialize_simulation(argument)

  ! Get time step length
  write(*, '(a, e14.8)') "*** Trixi controller ***   Current time step length: ", &
                         trixi_calculate_dt(handle)

  ! Main loop
  write(*, '(a)') ""
  write(*, '(a)') "*** Trixi controller ***   Entering main loop"
  do
    ! Exit loop once simulation is completed
    if ( trixi_is_finished(handle) ) exit

    call trixi_step(handle)
  end do

  ! Finalize Trixi simulation
  write(*, '(a)') "*** Trixi controller ***   Finalize Trixi simulation"
  write(*, '(a)') ""
  call trixi_finalize_simulation(handle)

  ! Finalize Trixi
  write(*, '(a)') "*** Trixi controller ***   Finalize Trixi"
  write(*, '(a)') ""
  call trixi_finalize()

  ! Finalize MPI
  write(*, '(a)') "*** Trixi controller ***   Finalize MPI"
  call MPI_Finalize(ierror)

end program
