! Print the local and global number of elements of a forest.
subroutine t8_print_forest_information(forest)
    use t8_mo_fortran_interface
    use, intrinsic :: iso_c_binding, only: c_ptr, c_int
                  
    implicit none

    type(c_ptr) :: forest
    integer(c_int) :: local_num_elements, global_num_elements

    ! Check that forest is a committed, that is valid and usable, forest.
    ! T8_ASSERT (t8_forest_is_committed (forest));

    ! Get the local number of elements.
    local_num_elements = t8_forest_get_local_num_elements (forest)

    ! Get the global number of elements.
    global_num_elements = t8_forest_get_global_num_elements (forest)

    write(*, '(a,i6)') "*** T8code ***  Local number of elements:  ", local_num_elements
    write(*, '(a,i6)') "*** T8code ***  Global number of elements: ", global_num_elements
end subroutine


program trixi_controller_simple_f
  use LibTrixi
  use, intrinsic :: iso_fortran_env, only: error_unit
  use, intrinsic :: iso_c_binding, only: c_int, c_ptr

  implicit none

  integer(c_int) :: handle, nelements
  character(len=256) :: argument
  type(c_ptr) :: forest

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
  nelements = trixi_nelements( handle );
  write(*, '(a)') ""
  write(*, '(a,i6)') "*** Trixi controller ***   nelements ", nelements
  write(*, '(a)') ""

  ! get t8code forest
  forest = trixi_get_t8code_forest( handle )
  call t8_print_forest_information ( forest )

  ! Finalize Trixi simulation
  call trixi_finalize_simulation(handle)

  ! Finalize Trixi
  call trixi_finalize()
end program
