subroutine source_terms_baroclinic( nnodes, nodes, forest, ndofs, &
                                    u1, u2, u3, u4, du2, du3, du4, du5 )
  use t8_fortran_interface_mod
  use, intrinsic :: iso_c_binding, only: c_ptr, c_int, c_double

  implicit none

  integer(c_int) :: nnodes, ndofs, num_local_trees, itree, num_elements_in_tree, ielement, &
                    index, i, j, k
  type(c_ptr) :: forest, element
  integer, parameter :: dp = selected_real_kind(12)
  real(dp) :: radius_earth, gravitational_acceleration, angular_velocity, &
              g_r2, ele, ele_corrected, temp
  real(dp), dimension(3) :: local_coords, global_coords
  real(dp), dimension(ndofs) :: u1, u2, u3, u4, du2, du3, du4, du5
  real(dp), dimension(nnodes) :: nodes
  
  radius_earth = 6.371229e6
  gravitational_acceleration = 9.80616
  angular_velocity = 7.29212e-5
  g_r2 = -gravitational_acceleration * radius_earth * radius_earth

  ! Get the number of trees that have elements
  num_local_trees = t8_forest_get_num_local_trees (forest)
  ! Iterate through all local trees
  index = 1
  do itree = 0,num_local_trees-1
    ! Get number of elements of this tree
    num_elements_in_tree = t8_forest_get_tree_num_elements (forest, itree)
    ! Iterate through all the local elements
    do ielement = 0,num_elements_in_tree-1
      ! Get a pointer to the current element
      element = t8_forest_get_element_in_tree (forest, itree, ielement)
      do k = 1,nnodes
        do j = 1,nnodes
          do i = 1,nnodes
            ! Get global coordinates of local quad point
            local_coords(1) = nodes(i)
            local_coords(2) = nodes(j)
            local_coords(3) = nodes(k)
            call t8_forest_element_from_ref_coords(forest, itree, element, & 
                                                   local_coords, 1, global_coords)

            ! The actual computation of source terms
            ele = sqrt( global_coords(1)*global_coords(1) + &
                        global_coords(2)*global_coords(2) + &
                        global_coords(3)*global_coords(3) )
            ele_corrected = max( ele - radius_earth, 0.0_dp ) + radius_earth

            ! Gravity term
            temp = g_r2 / (ele_corrected*ele_corrected*ele_corrected)
            du2(index) = temp * u1(index) * global_coords(1)
            du3(index) = temp * u1(index) * global_coords(2)
            du4(index) = temp * u1(index) * global_coords(3)
            du5(index) = temp * u1(index) * (u2(index) * global_coords(1) + &
                                             u3(index) * global_coords(2) + &
                                             u4(index) * global_coords(3))
            
            ! Coriolis term
            du2(index) = du2(index) + 2.0 * angular_velocity * u3(index) * u1(index)
            du3(index) = du3(index) - 2.0 * angular_velocity * u2(index) * u1(index)

            index = index + 1
          end do
        end do
      end do
    end do
  end do
end subroutine

program trixi_controller_baroclinic_f
  use LibTrixi
  use, intrinsic :: iso_fortran_env, only: error_unit
  use, intrinsic :: iso_c_binding, only: c_int, c_double, c_ptr

  implicit none

  integer(c_int) :: handle, nnodes, ndofs, i
  character(len=256) :: argument
  type(c_ptr) :: forest
  integer, parameter :: dp = selected_real_kind(12)
  real(dp), dimension(:), pointer :: u1, u2, u3, u4, du2, du3, du4, du5, nodes => null()


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
  call get_command_argument( 1, argument )
  call trixi_initialize( argument )

  ! Set up the Trixi simulation
  ! We get a handle to use subsequently
  write(*, '(a)') "*** Trixi controller ***   Set up Trixi simulation"
  call get_command_argument( 2, argument )
  handle = trixi_initialize_simulation( argument )

  ! Get number of degrees of freedom
  ndofs = trixi_ndofs( handle );

  ! Allocate memory for current state
  allocate( u1(ndofs) )
  allocate( u2(ndofs) )
  allocate( u3(ndofs) )
  allocate( u4(ndofs) )

  ! Allocate memory for source terms
  allocate( du2(ndofs) )
  allocate( du3(ndofs) )
  allocate( du4(ndofs) )
  allocate( du5(ndofs) )

  ! Store source term vectors in Trixi
  call trixi_register_data( handle, 1, ndofs, du2 )
  call trixi_register_data( handle, 2, ndofs, du3 )
  call trixi_register_data( handle, 3, ndofs, du4 )
  call trixi_register_data( handle, 4, ndofs, du5 )

  ! Get number of quadrature nodes
  nnodes = trixi_nnodes( handle )

  ! Allocate memory for quadrature node coordinates
  allocate( nodes(nnodes) )

  ! Get quadrature node coordinates
  call trixi_load_node_reference_coordinates( handle, nodes );

  ! Transform coordinates from [-1,1] to [0,1]
  do i = 1,nnodes
    nodes(i) = 0.5 * (nodes(i) + 1.0)
  end do

  ! Get t8code forest
  forest = trixi_get_t8code_forest( handle )

  ! Main loop
  write(*, '(a)') "*** Trixi controller ***   Entering main loop"

  do
    ! Exit loop once simulation is completed
    if ( trixi_is_finished(handle) ) exit

    ! Get current state
    call trixi_load_primitive_vars( handle, 1, u1 )
    call trixi_load_primitive_vars( handle, 2, u2 )
    call trixi_load_primitive_vars( handle, 3, u3 )
    call trixi_load_primitive_vars( handle, 4, u4 )

    ! Compute source terms
    call source_terms_baroclinic( nnodes, nodes, forest, ndofs, &
                                  u1, u2, u3, u4, du2, du3, du4, du5 )

    call trixi_step(handle)
  end do

  ! Finalize Trixi simulation
  write(*, '(a)') ""
  write(*, '(a)') "*** Trixi controller ***   Finalize Trixi simulation"
  call trixi_finalize_simulation(handle)

  ! Finalize Trixi
  write(*, '(a)') ""
  write(*, '(a)') "*** Trixi controller ***   Finalize Trixi"
  call trixi_finalize()

  deallocate(u1)
  deallocate(u2)
  deallocate(u3)
  deallocate(u4)
  deallocate(du2)
  deallocate(du3)
  deallocate(du4)
  deallocate(du5)
  deallocate(nodes)
  nullify(u1)
  nullify(u2)
  nullify(u3)
  nullify(u4)
  nullify(du2)
  nullify(du3)
  nullify(du4)
  nullify(du5)
  nullify(nodes)
end program
