module simulationRun_suite
  use LibTrixi
  use testdrive, only : new_unittest, unittest_type, error_type, check
  use, intrinsic :: iso_c_binding, only: c_double, c_f_pointer, c_ptr
  implicit none
  private

  public :: collect_simulationRun_suite

  character(len=*), parameter, public :: julia_project_path = JULIA_PROJECT_PATH
  character(len=*), parameter, public :: libelixir_path = &
    "../../../LibTrixi.jl/examples/libelixir_p4est2d_euler_sedov.jl"

  contains

  !> Collect all exported unit tests
  subroutine collect_simulationRun_suite(testsuite)
    !> Collection of tests
    type(unittest_type), allocatable, intent(out) :: testsuite(:)

    testsuite = [ new_unittest("simulationRun", test_simulationRun) ]
  end subroutine collect_simulationRun_suite

  subroutine test_simulationRun(error)
    type(error_type), allocatable, intent(out) :: error
    integer :: handle, ndims, nelements, nelementsglobal, nvariables, ndofsglobal, &
               ndofselement, ndofs, size, nnodes, i
    logical :: finished_status
    ! dp as defined in test-drive
    integer, parameter :: dp = selected_real_kind(15)
    real(dp) :: dt, time, integral
    real(dp), dimension(:), allocatable :: data, weights
    type(c_ptr) :: raw_data_c
    real(c_double), dimension(:), pointer :: raw_data

    ! Initialize Trixi
    call trixi_initialize(julia_project_path)

    ! Set up the Trixi simulation, get a handle
    handle = trixi_initialize_simulation(libelixir_path)
    call check(error, handle, 1)

    ! Store a vector in registry
    allocate(data(3))
    call trixi_register_data(handle, 1, 3, data)
    deallocate(data)

    ! Do a simulation step
    call trixi_step(handle)

    ! Check time step length
    dt = trixi_calculate_dt(handle)
    call check(error, dt, 0.0032132984504400627_dp)

    ! Check time step length
    time = trixi_get_simulation_time(handle)
    call check(error, time, 0.0032382397675568731_dp)
    
    ! Check finished status
    finished_status = trixi_is_finished(handle)
    call check(error, finished_status, .false.)

    ! Check number of dimensions
    ndims = trixi_ndims(handle)
    call check(error, ndims, 2)

    ! Check number of elements
    nelements = trixi_nelements(handle)
    call check(error, nelements, 256)

    nelementsglobal = trixi_nelementsglobal(handle)
    call check(error, nelementsglobal, 256)

    ! Check number of dofs
    ndofselement = trixi_ndofselement(handle)
    call check(error, ndofselement, 25)

    ndofs = trixi_ndofs(handle)
    call check(error, ndofs, nelements * ndofselement)

    ndofsglobal = trixi_ndofsglobal(handle)
    call check(error, ndofsglobal, nelementsglobal * ndofselement)

    ! Check number of variables
    nvariables = trixi_nvariables(handle)
    call check(error, nvariables, 4)

    ! Check number of quadrature nodes
    nnodes = trixi_nnodes(handle)
    call check(error, nnodes, 5)

    ! Check quadrature, integrate f(x) = x^4 over [-1,1]
    size = nnodes
    allocate(data(size))
    allocate(weights(size))
    call trixi_load_node_reference_coordinates(handle, data)
    call trixi_load_node_weights(handle, weights)
    integral = 0.0_dp
    do i = 1, size
      integral = integral + weights(i) * data(i) * data(i) * data(i)* data(i)
    end do
    call check(error, integral, 0.4_dp)
    deallocate(data)

    ! Check conservative variable values
    size = ndofs
    allocate(data(size))
    call trixi_load_conservative_vars(handle, 1, data)
    call check(error, data(1),    1.0_dp)
    call check(error, data(3200), 1.0_dp)
    call check(error, data(size), 2.5e-5_dp)
    deallocate(data)

    ! Check primitive variable values
    allocate(data(size))
    call trixi_load_primitive_vars(handle, 1, data)
    call check(error, data(1),    1.0_dp)
    call check(error, data(3200), 1.0_dp)
    call check(error, data(size), 1.0_dp)
    deallocate(data)

    ! Check element averaged values
    size = nelements
    allocate(data(size))
    call trixi_load_element_averaged_primitive_vars(handle, 1, data)
    call check(error, data(1),    1.0_dp)
    call check(error, data(94),   0.99833232379996562_dp)
    call check(error, data(size), 1.0_dp)

    ! Check storing of conservative variables
    data(1) = 42.0
    data(ndofs) = 23.0
    call trixi_store_conservative_vars(handle, 1, data)

    raw_data_c = trixi_get_data_pointer(handle)
    call c_f_pointer(raw_data_c, raw_data, [ndofs])
    call check(error, data(1),     raw_data(1))
    call check(error, data(ndofs), raw_data(4*ndofs - 3))

    deallocate(data)

    ! Finalize Trixi simulation
    call trixi_finalize_simulation(handle)
    
    ! Finalize Trixi
    call trixi_finalize()
  end subroutine test_simulationRun

end module simulationRun_suite
