#ifndef TEST_WVI
#define TEST_WVI 0
#endif

module wvi
  implicit none
  public
  integer,parameter :: KRF=selected_real_kind(P=10)

contains
  real(kind=KRF) function wnml(dp, pf, ms, mb, dHdt) &
       result (r)
    implicit none
    real(kind=KRF),intent(in) :: dp, pf
    real(kind=KRF),intent(in),optional :: ms, mb, dHdt

    real(kind=KRF) :: a, b, ht, f
    if (present(ms)) then
       a = ms
    else
       a = 1.0_KRF
    endif
    if (present(mb)) then
       b = mb
    else
       b = 0.0_KRF
    endif
    if (present(dHdt)) then
       ht = dHdt
    else
       ht = 0.0_KRF
    endif
    f = a + b - ht

    ! w = acc/(n+1) [(n+2)*(depth-1) - (depth**(n+2)-1)]
    r = ((pf + 2.0_KRF) * (dp - 1.0_KRF) &
         & - (dp ** (pf + 2.0_KRF) - 1.0_KRF)) / (pf + 1.0_KRF)
    r = r * f + b
    return
  end function wnml

  subroutine aintg &
       & (astp, dept, depo, ddep, &
       &  pf,   ms,   mb)
    implicit none
    real(kind=KRF),intent(out) :: astp
    real(kind=KRF),intent(in)  :: dept, depo, ddep
    real(kind=KRF),intent(in)  :: pf,   ms,   mb

    real(kind=KRF),save :: cdep = 0.0_KRF
    real(kind=KRF),save :: cage = 0.0_KRF
    integer,       save :: jstp = 0

    real(kind=KRF) :: dhi, dhe
    real(kind=KRF) :: fa,  fb,  fm

    ! write(*, *) 'cache: ', 0, cage, jstp, cdep

    if (depo.ge.cdep) then
       jstp = 0
       astp = 0.0_KRF
    else if (dept.lt.cdep) then
       jstp = 0
       astp = 0.0_KRF
    else
       astp = cage
    endif

    ! write(*, *) 'cache: ', 1, astp, jstp, depo

    do
       dhi = depo + ddep * real(jstp,   KIND=KIND(ddep))
       dhe = depo + ddep * real(jstp+1, KIND=KIND(ddep))
       if (dhe.ge.dept) exit
       fa = 1.0_KRF / wnml(dhi, pf, ms, mb)
       fb = 1.0_KRF / wnml(dhe, pf, ms, mb)
       fm = 1.0_KRF / wnml((dhi + dhe) * 0.5_KRF, pf, ms, mb)
       astp = astp + (ddep / 6.0_KRF) * ((fa + fb) + 4.0_KRF * fm)
       jstp = jstp + 1
    enddo
    cage = astp
    cdep = dhi

    dhe = dept
    fa = 1.0_KRF / wnml(dhi, pf, ms, mb)
    fb = 1.0_KRF / wnml(dhe, pf, ms, mb)
    fm = 1.0_KRF / wnml((dhi + dhe) * 0.5_KRF, pf, ms, mb)
    astp = astp + ((dhe - dhi) / 6.0_KRF) * ((fa + fb) + 4.0_KRF * fm)

    ! write(*, *) 'cache: ', 9, cage, cdep, astp, jstp

    return
  end subroutine aintg

end module wvi

#if TEST_WVI
program wvitest
  use wvi
  implicit none
  real(kind=KRF) :: pf = 3.0_KRF
  real(kind=KRF) :: ms = 0.015_KRF, mb = 0.0_KRF

  real(kind=KRF) :: astp, age

  integer :: no = 3, ni = 2
  integer :: mo,     mi
  integer :: jo,     ji
  real(kind=KRF) :: dini, dstep, ddh, ddhi
  real(kind=KRF) :: dtgt, dend

  mo = 2 ** no
  mi = 2 ** ni

  dini  = 0.0_KRF
  dstep = 1.0_KRF / real(mo,          KIND=KIND(dstep))
  ddh   = 1.0_KRF / real(mo * mi,     KIND=KIND(dstep))
  ddhi  = 1.0_KRF / real(mo * mi * 2, KIND=KIND(dstep))

  age = 0.0_KRF
  do jo = 0, mo - 1
     dend = dini + dstep
     ji   = 0
     do
        if (jo.eq.mo / 2) then
           dtgt = dini + ddhi * real(ji + 1, KIND=KIND(ddh))
        else
           dtgt = dend
        endif
        call aintg(astp, dtgt, dini, ddh, pf, ms, mb)
        write (*, *) jo, ji, dtgt, -(age + astp)
        if (dtgt.eq.dend) exit
        ji = ji + 1
     enddo
     dini = dend
     age = age + astp
  enddo
  stop
end program wvitest

#endif /* TEST_WVI */
