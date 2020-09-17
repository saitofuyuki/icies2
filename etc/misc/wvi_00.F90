module wviold
  implicit none
  public
  integer,parameter :: KRF=selected_real_kind(P=10)

contains
  real(kind=KRF) function wnml(dp, pf) &
       result (r)
    implicit none
    real(kind=KRF),intent(in) :: dp, pf
    ! w = acc/(n+1) [(n+2)*(depth-1) - (depth**(n+2)-1)]
    r = ((pf + 2.0_KRF) * (dp - 1.0_KRF) &
         & - (dp ** (pf + 2.0_KRF) - 1.0_KRF)) / (pf + 1.0_KRF)
    return
  end function wnml
end module wviold
