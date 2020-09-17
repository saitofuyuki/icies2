!!!_! ageni.F90 --- age integral with simpson method.
! Maintainer:  SAITO Fuyuki
! Created: Nov 14 2018
#define TIME_STAMP 'Time-stamp: <2020/09/17 09:01:45 fuyuki ageni_00.F90>'
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
!!!_! MANIFESTO
!
! Copyright (C) 2018--2020
!           Japan Agency for Marine-Earth Science and Technology
!
! Licensed under the Apache License, Version 2.0
!   (https://www.apache.org/licenses/LICENSE-2.0)
!
!!!_* includes
!!!_* program
program ageni
  use wviold
  implicit none

  real(kind=KRF) :: dini, dend, dstep
  real(kind=KRF) :: dhi,  dhe,  ddh

  real(kind=KRF) :: fa, fb, fm

  real(kind=KRF) :: age
  real(kind=KRF) :: dage

  real(kind=KRF) :: w

  real(kind=KRF) :: pf

  integer :: no, ni
  integer :: jo, ji

  integer :: mo, mi

  character(len=128) :: astr
  integer :: iErr, nargs, iarg

  nargs = command_argument_count()

  if (nargs.lt.3) then
109  format('Not enough arguments.')
     write(*, 109)
     stop
  endif

  iarg = 1
  call get_command_argument(iarg, astr)
  read(astr, *) pf
  iarg = iarg + 1
  call get_command_argument(iarg, astr)
  read(astr, *) no
  iarg = iarg + 1
  call get_command_argument(iarg, astr)
  read(astr, *) ni
  ! pf = 3.0_KRF
  ! no = 14
  ! ni = 10

  mo = 2 ** no
  mi = 2 ** ni

  dini = 0.0_KRF
  dstep = 1.0_KRF / real(mo,      KIND=KIND(dstep))
  ddh   = 1.0_KRF / real(mo * mi, KIND=KIND(dstep))
101 format('# ', F4.0, 1x, I0, 1x, I0, 1x, E16.9, 1x, E16.9)
  write (*, 101) pf, no, ni, dstep, ddh

  age = 0.0_KRF

  do jo = 0, mo - 1
     dend = dini + dstep
     ! write(*, *) jo, dini, dend
     dage = 0.0_KRF
     do ji = 0, mi - 1
        dhi = dini + ddh * real(ji,   KIND=KIND(ddh))
        dhe = dini + ddh * real(ji+1, KIND=KIND(ddh))
        fa = 1.0_KRF / wnml(dhi, pf)
        fb = 1.0_KRF / wnml(dhe, pf)
        fm = 1.0_KRF / wnml((dhi + dhe) * 0.5_KRF, pf)
        dage = dage + (ddh / 6.0_KRF) * ((fa + fb) + 4.0_KRF * fm)
        ! write (*, *) ji, dhi, dhe, dage
     enddo
     w = wnml(dini, pf)
     fa = 1.0_KRF / w
! 201  format(I0, 5(1x, E24.16))
201  format(5(1x, E24.16))
     write(*, 201) dini, -age, fa, w
     dini = dend
     age  = age + dage
  enddo

end program ageni

!!!_! FOOTER
!!!_ + Local variables
! Local Variables:
! End:
