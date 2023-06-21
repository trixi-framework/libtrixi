module LibTrixi
  implicit none

  interface
    subroutine trixi_initialize(comm) bind(c)
      use, intrinsic :: iso_c_binding, only: c_int
      integer, intent(in) :: comm
    end subroutine

    subroutine trixi_finalize() bind(c)
    end subroutine

    subroutine trixi_step() bind(c)
    end subroutine

    subroutine julia_eval_string(code) bind(c)
      use, intrinsic :: iso_c_binding, only: c_char
      character(kind=c_char) :: code(*)
    end subroutine
  end interface
end module
