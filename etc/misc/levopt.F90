!!!_! levopt.F90 - level optimization for age integral
! Maintainer:  SAITO Fuyuki
! Created: Jan 9 2019
#define TIME_STAMP 'Time-stamp: <2021/02/17 21:22:59 fuyuki levopt.F90>'
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
!!!_! MANIFESTO
!
! Copyright (C) 2019-2021
!           Japan Agency for Marine-Earth Science and Technology
!
! Licensed under the Apache License, Version 2.0
!   (https://www.apache.org/licenses/LICENSE-2.0)
!
!!!_* includes
!!!_* program
program levopt
  use wvi
  implicit none

  real(kind=KRF) :: dini, dend, dstep
  real(kind=KRF) :: ddh

  real(kind=KRF),allocatable :: aseq(:)
  real(kind=KRF),allocatable :: dseq(:)

  integer        :: jlev
  integer        :: jxa,  jxb, jxn, jxo
  real(kind=KRF) :: xa,   xb,  xn,  xo,  dxb
  real(kind=KRF) :: za,   zb,  zn

  real(kind=KRF) :: age,  dage
  real(kind=KRF) :: damd
  real(kind=KRF) :: anew, aold, atgt
  real(kind=KRF) :: pf

  real(kind=KRF) :: ms, mb, dHdt, refh
  real(kind=KRF) :: tres, ttol, yend
  integer :: mstp

  integer jgrp, ngrp
  integer, allocatable :: lgrp(:, :)

  integer :: no, ni
  integer :: jo, jn

  integer :: mo, mi
  integer :: levs
  integer :: llev
  integer :: levf

  character(len=128)  :: astr
  integer :: iErr, nargs, iarg

  nargs = command_argument_count()

  if (nargs.lt.8) then
109  format('Not enough arguments.')
     write(*, 109)
301  format('USAGE:')
302  format('  levopt PF POWER-OUTER POWER-INNER MS MB HREF TRES MSTP [TTOL [YEND]]')
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
  call get_command_argument(iarg, astr)
  read(astr, *) ms
  iarg = iarg + 1
  call get_command_argument(iarg, astr)
  read(astr, *) mb
  iarg = iarg + 1
  call get_command_argument(iarg, astr)
  read(astr, *) refh
  iarg = iarg + 1
  call get_command_argument(iarg, astr)
  read(astr, *) tres
  ! mstp == 0  bisection mode
  ! mstp >  0  level division by 2**mstp
  ! mstp <  0  level decrement by mstp
  iarg = iarg + 1
  call get_command_argument(iarg, astr)
  read(astr, *) mstp

  iarg = iarg + 1
  if (iarg.le.nargs) then
     call get_command_argument(iarg, astr)
     read(astr, *) ttol
  else
     ttol = 0.0_KRF
  endif
  iarg = iarg + 1
  if (iarg.le.nargs) then
     call get_command_argument(iarg, astr)
     read(astr, *) yend
  else
     yend = 0.0_KRF
  endif

  if (ttol.le.0.0_KRF) ttol = tres * 2.0_KRF

  dHdt = 0.0_KRF

  mo = 2 ** no
  mi = 2 ** ni

  dini = 0.0_KRF
  dstep = 1.0_KRF / real(mo,      KIND=KIND(dstep))
  ddh   = 1.0_KRF / real(mo * mi, KIND=KIND(dstep))
101 format('# ', F4.0, 1x, I0, 1x, I0, 1x, &
         &       E16.9, 1x, E16.9, 1x, &
         &       E10.3, 1x, E10.3, 1x, F6.0, 1x, &
         &       F7.0,  1x, I0)
  write (*, 101) pf, no, ni, dstep, ddh, ms, mb, refh, tres, mstp

  age = 0.0_KRF
  dini = 0.0_KRF
! ---------------------------------------- bisection mode
1101 format(I0, 1x, E24.16, 2(1x, E24.16), 1x, F12.0, 1x, F7.1)
  if (mstp.eq.0) then
     jlev = 0
     xn = 0.0_KRF
     xo = 0.0_KRF
     zn = 0.0_KRF
     atgt = zn
     write(*, 1101) jlev, xn, xn-xo, zn, atgt, abs(zn-atgt)

     jlev = jlev + 1
     aold = age
     atgt = aold + tres
     outer: do jo = 0, mo - 1
        dend = dini + dstep
        call aintg(damd, dend, dini, ddh, pf, ms, mb)
        anew = (age - damd) * refh
        jxo = -1
        jxn = 0
        do
           if (anew.lt.atgt) exit
           za = age * refh
           zb = anew
           jxa = jxn
           jxb = mi
           do
              ! write(*, *) 'BISECTION', jo, atgt, jxa,za, jxb,zb
              if (za.eq.atgt) then
                 zn = atgt
                 jxn = jxa
                 exit
              else if (zb.eq.atgt) then
                 zn = atgt
                 jxn = jxb
                 exit
              endif
              jxn = (jxa + jxb) / 2
              if (jxn.eq.jxa) then
                 zn = za
                 exit
              endif
              xn = dini + ddh * real(jxn, kind=KIND(ddh))
              call aintg(zn, xn, dini, ddh, pf, ms, mb)
              zn = (age - zn) * refh
              if (zn.gt.atgt) then
                 jxb = jxn
                 zb  = zn
              else
                 jxa = jxn
                 za  = zn
              endif
           enddo
           if (jxo.eq.jxn) then
              jxn = -999
              exit outer
           endif
           xn = dini + ddh * real(jxn, kind=KIND(ddh))
           call aintg(zn, xn, dini, ddh, pf, ms, mb)
           zn = (age - zn) * refh
           ! write(*, *) jxn, xn, zn, atgt
           dxb = xn - xo
           write(*, 1101) jlev, xn, dxb, zn, atgt, abs(zn-atgt)
           ! write(*, 1101) jlev, xo, dxb, zn, atgt, abs(zn-atgt)
           xo  = xn
           jlev = jlev + 1
           if (abs(zn-atgt).gt.ttol) exit outer
           if (yend.gt.0.0_KRF .and. atgt.gt.yend) exit outer
           atgt = atgt + tres
           jxo = jxn
        enddo
        age  = age - damd
        dini = dend
     enddo outer
     if (yend.gt.0.0_KRF .and. atgt.gt.yend) then
        dxb = (1.0_KRF - xn) / CEILING((1.0_KRF - xn) / dxb)
        dini = xn
        do
           dend = dini + dxb
           if (dend.gt.(1.0_KRF - ddh)) dend = 1.0_KRF
           call aintg(damd, dend, dini, ddh, pf, ms, mb)
           zn = (age - damd) * refh
           write(*, 1101) jlev, dend, dxb, zn, 0.0_KRF, -1.0_KRF
           jlev = jlev + 1
           age = age - damd
           dini = dend
           if (dend.ge.1.0_KRF) exit
        enddo
     else
        xb = 1.0_KRF
        ! jlev = jlev + int((xb - xn) / ddh)
        ! write(*, 1101) jlev, xb, dxb, zn, atgt, abs(zn-atgt)
     endif
! ---------------------------------------- otherwise
  else
     allocate(aseq(0:mo), dseq(0:mo), STAT=ierr)
     if (ierr.eq.0) allocate(lgrp(2, mo), STAT=ierr)
     if (ierr.ne.0) then
        write(*, *) 'PANIC in ALLOCATION: ', ierr
        stop
     endif

     jo = 0
     aseq(jo) = age
     dseq(jo) = dini

     do jo = 0, mo - 1
        dend = dini + dstep
        call aintg(damd, dend, dini, ddh, pf, ms, mb)
        age  = age - damd
        aseq(1+jo) = age * refh
        dseq(1+jo) = dend
        dini = dend
     enddo

     ! 202 format(2(1x, E24.16), 1x, I1)
     !   do jo = 0, mo
     !      write(*, 202) dseq(jo), aseq(jo)
     !   enddo

     ! set initial step
     levs = -1
     anew = aseq(0) + tres
401  format(I0, 1x, F9.0, 1x, F9.0, 1x, F9.0)
     do jo = 1, mo
        ! write(*, 401) jo, dseq(jo), aseq(jo), anew
        if (aseq(jo).gt.anew) then
           levs = jo - 1
           exit
        endif
     enddo
     if (mstp.gt.0) then
        levs = 2 ** int(floor(log(real(levs,KRF)) / log(2.0_KRF)))
     endif
     ! write(*, 401) levs, dseq(0+levs), aseq(0+levs)

     ! level optimization
     jgrp = 1
     lgrp(1, jgrp) = levs
     lgrp(2, jgrp) = 0
     jo = 0
501  format(I0, 1x, E24.16, 1x, E10.3, 1x, E10.3, 1x, I0)
     jn = 0
     write(*, 501) jn, dseq(jn), aseq(jn), aseq(jn) - aseq(jo), levs
     do
        if (jo.ge.mo) exit
        do
           jn = jo + levs
           dage = aseq(jn) - aseq(jo)
           if (dage.le.tres) exit
           if (mstp.lt.0) then
              if (levs.le.-mstp) then
                 levs = levs - 1
              else
                 levs = levs + mstp
              endif
           else
              levs = levs / (2 ** mstp)
           endif
           levs = max(1, levs)
           if (levs.le.1) exit
        enddo
        jn = jo + levs
        dage = aseq(jn) - aseq(jo)
        levf = levs
        if (dage.gt.tres) levf = 0
        write(*, 501) jn, dseq(jn), aseq(jn), dage, levf
        jo = jn
        if (lgrp(1, jgrp).eq.levs) then
           lgrp(2, jgrp) = lgrp(2, jgrp) + 1
        else
           jgrp = jgrp + 1
           lgrp(1, jgrp) = levs
           lgrp(2, jgrp) = 1
        endif
     enddo
     ngrp = jgrp
     llev = 0
     do jgrp = 1, ngrp
        llev = llev + lgrp(2,jgrp)
     enddo

601  format(I0, 3(1x, I0))
     do jgrp = ngrp, 1, -1
        write (*, 601) lgrp(1,jgrp), mo, lgrp(2,jgrp) + 1, llev + 1
     enddo
     ! print " &NIGEOZ CROOT='$croot', NLV=741, DXN= 1.d0,   DXD=16384.0d0 &END"
701  format(' &NIGEOZ CROOT=''$croot'',', &
          & ' NLV=', I0, ',', &
          & ' DXN=', I0, '.d0,', &
          & ' DXD=', I0, '.d0,', &
          & ' &END')
     jgrp = ngrp
     write (*, 701) lgrp(2,jgrp) + 1, lgrp(1,jgrp), mo
     do jgrp = ngrp - 1, 2, -1
        write (*, 701) lgrp(2,jgrp) + 1, lgrp(1,jgrp), 0
     enddo
     jgrp = 1
     write (*, 701) -1, lgrp(1,jgrp), 0
  endif

  stop
end program levopt

!!!_! FOOTER
!!!_ + Local variables
! Local Variables:
! End:
