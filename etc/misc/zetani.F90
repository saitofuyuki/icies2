!!!_! zetani.F90 - zeta integral with simpson method
! Maintainer:  SAITO Fuyuki
! Created: Nov 22 2018
#define TIME_STAMP 'Time-stamp: <2021/02/17 21:20:22 fuyuki zetani.F90>'
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
!!!_! MANIFESTO
!
! Copyright (C) 2018-2021
!           Japan Agency for Marine-Earth Science and Technology
!
! Licensed under the Apache License, Version 2.0
!   (https://www.apache.org/licenses/LICENSE-2.0)
!
!!!_* includes
!!!_* program
program zetani
  use wvi
  implicit none

  real(kind=KRF) :: dini, dend, dstep
  real(kind=KRF) :: dhi,  dhe,  ddh

  real(kind=KRF) :: fa, fb, fm

  real(kind=KRF) :: zeta
  real(kind=KRF) :: dzeta

  real(kind=KRF) :: w

  real(kind=KRF) :: pf

  integer :: no, ni
  integer :: jo, ji

  integer :: mo, mi
  integer :: mx

  character(len=128) :: astr
  integer :: iErr, nargs, iarg

  nargs = command_argument_count()

  if (nargs.lt.4) then
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
  iarg = iarg + 1
  call get_command_argument(iarg, astr)
  read(astr, *) mx
  ! pf = 3.0_KRF
  ! no = 14
  ! ni = 10

  mo = 2 ** no
  mi = 2 ** ni

  dini = 0.0_KRF
  dstep = 1.0_KRF / real(mo,      KIND=KIND(dstep))
  ddh   = 1.0_KRF / real(mo * mi, KIND=KIND(dstep))

  mx = mo * mx

101 format('# ', F4.0, 1x, I0, 1x, I0, 1x, I0, 1x, E16.9, 1x, E16.9)
  ! write (*, 101) pf, no, ni, mx, dstep, ddh

  zeta = 0.0_KRF

  do jo = 0, mx - 1
     dend = dini + dstep
     ! write(*, *) jo, dini, dend
     dzeta = 0.0_KRF
     do ji = 0, mi - 1
        dhi = dini + ddh * real(ji,   KIND=KIND(ddh))
        dhe = dini + ddh * real(ji+1, KIND=KIND(ddh))
        fa = -wnml(dhi, pf)
        fb = -wnml(dhe, pf)
        fm = -wnml((dhi + dhe) * 0.5_KRF, pf)
        dzeta = dzeta + (ddh / 6.0_KRF) * ((fa + fb) + 4.0_KRF * fm)
        ! write (*, *) ji, dhi, dhe, dage
     enddo
     w = -wnml(dini, pf)
     fa = w
201  format(I0, 1x, E16.9, 1x, E16.9, 1x, E16.9, 1x, E16.9, 1x, E16.9)
     write(*, 201) jo, dini, zeta, dzeta, fa, w
     dini = dend
     zeta  = zeta + dzeta
  enddo

end program zetani

!!!_! FOOTER
!!!_ + Local variables
! Local Variables:
! End:
