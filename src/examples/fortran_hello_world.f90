module LibTrixi
  implicit none

  interface
    subroutine trixi_initialize(comm) bind(c)
      use, intrinsic :: iso_c_binding, only: c_int
      integer, intent(in) :: comm
    end subroutine

    subroutine trixi_finalize() bind(c)
    end subroutine

    subroutine julia_eval_repl(code) bind(c)
      use, intrinsic :: iso_c_binding, only: c_char
      character(kind=c_char) :: code(*)
    end subroutine
  end interface
end module


program fortran_hello_world
  use LibTrixi

  implicit none

  include 'mpif.h'

  integer :: input(10)
  integer :: res
  integer i, ierror, rank, nranks, expected

  ! Initialize MPI
  call MPI_Init(ierror)

  ! Initialize Julia and Trixi
  call trixi_initialize(MPI_COMM_WORLD)

  ! Say hello to julia
  call julia_eval_repl('println("fortran:  Hello julia!")')

  ! Finalize Trixi and Julia
  call trixi_finalize()

  ! Finalize MPI
  call MPI_Finalize(ierror)
end program
