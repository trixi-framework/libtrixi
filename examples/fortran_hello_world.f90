program fortran_hello_world
  use LibTrixi

  implicit none

  !include 'mpif.h'

  integer :: input(10)
  integer :: res
  integer i, ierror, rank, nranks, expected

  ! Initialize MPI
  !call MPI_Init(ierror)

  ! Initialize Julia and Trixi
  call trixi_initialize()

  ! Say hello to julia
  call julia_eval_string('println("fortran:  Hello julia!")')

  ! Finalize Trixi and Julia
  call trixi_finalize()

  ! Finalize MPI
  !call MPI_Finalize(ierror)
end program
