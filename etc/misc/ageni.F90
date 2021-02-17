!!!_! ageni.F90 - age integral with simpson method
! Maintainer:  SAITO Fuyuki
! Created: Nov 14 2018
#define TIME_STAMP 'Time-stamp: <2021/02/17 21:19:44 fuyuki ageni.F90>'
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
!!!_* includes
!!!_* program
program ageni
  use wvi
  implicit none

  real(kind=KRF) :: dini, dend, dstep
  real(kind=KRF) :: ddh

  real(kind=KRF) :: fb

  real(kind=KRF) :: age
  real(kind=KRF) :: dage, damd

  real(kind=KRF) :: w

  real(kind=KRF) :: pf

  real(kind=KRF) :: ms, mb, dHdt

  integer, parameter :: lmax = 32768
  integer :: nmax
  real(kind=KRF) :: rndep(lmax)
  real(kind=KRF) :: dtgt, dfile

  integer :: no, ni
  integer :: jo

  integer :: mo, mi

  character(len=128)  :: astr
  character(len=1024) :: fndep
  integer :: ipdep
  integer :: iErr, nargs, iarg
  integer :: kflg

  nargs = command_argument_count()

  if (nargs.lt.3) then
109  format('Not enough arguments.')
     write(*, 109)
301  format('USAGE:')
302  format('  ageni PF POWER-OUTER POWER-INNER [MS [MB [DEPTH FILE]]]')
     write(*, 301)
     write(*, 302)
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
  if (iarg.le.nargs) then
     call get_command_argument(iarg, astr)
     read(astr, *) ms
  else
     ms = 1.0_KRF
  endif
  iarg = iarg + 1
  if (iarg.le.nargs) then
     call get_command_argument(iarg, astr)
     read(astr, *) mb
  else
     mb = 0.0_KRF
  endif
  iarg = iarg + 1

  nmax = 1
  rndep(nmax) = 10.0_KRF     ! centry

  if (iarg.le.nargs) then
     call get_command_argument(iarg, fndep)
     ipdep = 10
     open(UNIT=ipdep, FILE=fndep, IOSTAT=ierr)
901  format('CANNOT OPEN: ', A)
     if (ierr.ne.0) then
        write (*, 901) TRIM(fndep)
        stop
     endif
     do
        read(ipdep, *, IOSTAT=ierr) dini
        if (ierr.ne.0) then
           ierr = 0
           exit
        endif
        nmax = nmax + 1
        rndep(nmax) = dini
        ! write(*, '(E24.16)') dini
     enddo
  else
     fndep = ' '
     ipdep = -1
  endif

  ! pf = 3.0_KRF
  ! no = 14
  ! ni = 10
  dHdt = 0.0_KRF

  mo = 2 ** no
  mi = 2 ** ni

  dini = 0.0_KRF
  dstep = 1.0_KRF / real(mo,      KIND=KIND(dstep))
  ddh   = 1.0_KRF / real(mo * mi, KIND=KIND(dstep))
101 format('# ', F4.0, 1x, I0, 1x, I0, 1x, E16.9, 1x, E16.9, 1x, E10.3, 1x, E10.3, 1x, A)
  write (*, 101) pf, no, ni, dstep, ddh, ms, mb, TRIM(fndep)

  age = 0.0_KRF

202 format(4(1x, E24.16), 1x, I1)
203 format('### ', 4(1x, E24.16), 1x, I1)
  jo = 0
  dage = 0.0_KRF
  w = wnml(dini, pf, ms, mb)
  fb = 1.0_KRF / w
  kflg = 0
  write(*, 202) dini, age, fb, w, kflg
  dfile = rndep(nmax)
  if (dfile.eq.0.0_KRF) nmax = nmax - 1

  do jo = 0, mo - 1
     dend = dini + dstep
     ! write(*, *) jo, dend, nmax, rndep(nmax)
     do
        dfile = rndep(nmax)
        dtgt = min(dfile, dend)
        call aintg(damd, dtgt, dini, ddh, pf, ms, mb)

        if (dtgt.eq.dend) then
           if (dtgt.eq.dfile) then
              kflg = 0
           else
              kflg = 1
           endif
        else
           kflg = 2
        endif
        w  = wnml(dtgt, pf, ms, mb)
        fb = 1.0_KRF / w
        if (w.eq.0.0_KRF) then
           write(*, 203) dtgt, -(age+damd), fb, w, kflg
        else
           write(*, 202) dtgt, -(age+damd), fb, w, kflg
        endif
        if (dtgt.eq.dend) then
           dini = dend
           age  = age + damd
           if (dfile.eq.dend) nmax = nmax - 1
           exit
        else
           nmax = nmax - 1
        endif
     enddo
  enddo

end program ageni

!!!_! FOOTER
!!!_ + Local variables
! Local Variables:
! End:
