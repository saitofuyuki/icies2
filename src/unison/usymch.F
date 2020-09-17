C symmcheck/usymch.F --- Symmetry check for IcIES
C Author: SAITO Fuyuki
C Created: Mar 11 2011
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2020/09/15 11:45:57 fuyuki usymch.F>'
#define _FNAME 'symmcheck/usymch.F'
#define _REV   'Snoopy0.7'
CCC_! MANIFESTO
C
C Copyright (C) 2011--2020
C           Japan Agency for Marine-Earth Science and Technology
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
CCC_& USCscl  ## Symmetry check scalar
      subroutine USCscl
     O    (vAvr, vVar,
     I     vH,   iTbl)
CCC_ + Declaration
      implicit none
CCC_  = Arguments
      real*8  vAvr (*), vVar (*)
      real*8  vH   (*)
      integer iTbl (*)
CCC_  = Interior
      integer MR
      integer MC
      integer jc,  jr,  nr
      integer kt0, kv0
      real*8  P
CCC_ + Body
      MR   = iTbl (1)
      MC   = iTbl (2)
      do jr = 1, MR
         vAvr (jr) = 0.0d0
         vVar (jr) = 0.0d0
      enddo
      kt0  = 2 + MR * 2 + MC
      do jc = 1, MC
         kv0 = iTbl (kt0 + jc)     -  1
         nr  = iTbl (kt0 + jc + 1) - (kv0 + 1)
         do jr = 1, nr
            P = ABS (vH (iTbl (kv0 + jr))) - vAvr (jr)
            vAvr (jr) =
     $           vAvr (jr) +  P                           / dble (jc)
            vVar (jr) =
     $           vVar (jr) + (P ** 2.0d0) * dble (jc - 1) / dble (jc)
         enddo
      enddo
      RETURN
      END
CCC_& USClma  ## Symmetry check length of merge results
      subroutine USClma
     O    (lRowM,
     I     iTblX, iTblY)
      implicit none
      integer lRowM
      integer iTblX (*), iTblY (*)
      integer MR
      integer kt0, jr
c
      lRowM = 0
c
      MR    = iTblX (1)
      kt0 = 2 + MR
      do jr = 1, MR
         lRowM = MAX (lRowM, iTblX (jr))
      enddo
c
      MR    = iTblY (1)
      kt0 = 2 + MR
      do jr = 1, MR
         lRowM = MAX (lRowM, iTblY (jr))
      enddo
c
      RETURN
      END
CCC_& USCmrg  ## Symmetry check merge vector
      subroutine USCmrg
     O    (vAvrM, vVarM,
     I     vAvrX, vVarX, iTblX, vAvrY, vVarY, iTblY,
     I     lRowM)
      implicit none
      real*8  vAvrM (*), vVarM (*)
      real*8  vAvrX (*), vVarX (*)
      real*8  vAvrY (*), vVarY (*)
      integer iTblX (*), iTblY (*)
      integer lRowM
c
      integer mrx,  mry
      integer kt0
      integer jr, jx, nx, ny
c
      mrx = iTblX (1)
      mry = iTblY (1)
c
      do jr = 1, lRowM
         vAvrM (jr) = 0.0d0
         vVarM (jr) = 0.0d0
      enddo
c
      do jr = 1, mrx
         vAvrM (jr) = vAvrX (jr)
         vVarM (jr) = vVarX (jr)
      enddo
c
      kt0  = 2 + mry
      do jr = 1, mry
         jx = iTblY (kt0 + jr)
         nx = iTblX (2 + jx)
         if (jx.gt.mrx) nx = 0
         ny = iTblY (2 + jr)
         vVarM (jx) =
     $        (vVarM (jx) + vVarY (jr))
     $        + ((vAvrM (jx) - vAvrY (jr)) ** 2.0d0)
     $          * DBLE (nx) * DBLE (ny) / DBLE (nx + ny)
         vAvrM (jx) =
     $        (vAvrM (jx) * DBLE (nx) + vAvrY (jr) * DBLE (ny))
     $        / (DBLE (nx + ny))
      enddo
c
      RETURN
      END
CCC_& USCerd  ## Error distribution
      subroutine USCerd
     O    (vErr,
     I     NV,
     I     vAvr,
     I     vH,   iTbl)
CCC_ + Declaration
      implicit none
CCC_  = Arguments
      integer NV
      real*8  vErr (NV)
      real*8  vAvr (*)
      real*8  vH   (*)
      integer iTbl (*)
CCC_  = Interior
      integer MR
      integer MC
      integer jc,  jr,  nr,  jv
      integer kt0, kv0
CCC_ + Body
      do jv = 1, NV
         vErr (jv) = 0.0d0
      enddo
      MR   = iTbl (1)
      MC   = iTbl (2)
      kt0  = 2 + MR * 2 + MC
      do jc = 1, MC
         kv0 = iTbl (kt0 + jc)     -  1
         nr  = iTbl (kt0 + jc + 1) - (kv0 + 1)
         do jr = 1, nr
            jv = iTbl (kv0 + jr)
            vErr (jv) = ABS (vH (jv)) - vAvr (jr)
         enddo
      enddo
      RETURN
      END
CCC_& USCrtb  ## Read external table
      subroutine USCrtb
     O    (iErr,
     O     NX, NY, iTbl,
     I     MaxTbl,
     I     IFP)
      implicit none
      integer iErr
      integer MaxTbl
      integer IFP
      integer iTbl (MaxTbl)
      integer NX, NY
      integer IOS
      integer L, K
c
      iErr = 0
      IOS  = 0
      K    = 0
      DO
         call USCrtp (K, IOS, IFP)
         if (K.ge.0)   goto 100
         if (IOS.ne.0) goto 100
      ENDDO
 100  continue
      if (IOS.eq.0) then
         NX = K
         call USCrtp (K, IOS, IFP)
      endif
      if (IOS.eq.0) then
         NY = K
         L  = 0
         do
            call USCrtp (K, IOS, IFP)
            if (IOS.ne.0)  goto 200
            if (K.lt.0) goto 200
            L = L + 1
            iTbl (L) = K
            write (*, *) L, K
         enddo
 200     continue
      endif
      if (IOS.eq.0) then
         if (K.lt.0) iErr = 1
      endif
c
      RETURN
      END
CCC_& USCrtp  ## Read table (part)
      subroutine USCrtp
     O    (K, IOS,
     I     IFP)
      implicit none
      integer   K, IOS, IFP
      character S*(1024)
      DO
         if (IFP.lt.0) then
            READ (UNIT = *,   FMT = *, IOSTAT = IOS) S
         else
            READ (UNIT = IFP, FMT = *, IOSTAT = IOS) S
         endif
         if ((IOS.eq.0) .and. (S(1:1).ne.'#')) then
            READ (S, *) K
            goto 100
         else if (IOS.ne.0) then
            goto 100
         endif
      ENDDO
 100  continue
      RETURN
      END
CCC_& USYMCH  ## Symmetry check announcement
#ifndef OPT_SKIP_ANNOUNCEMENT
#include "ofdlct.h" /* fortran dialect */
      subroutine USYMCH (STRA, STRB, IOP)
CCC_ + Declaration
      implicit none
      _INTENT(IN, integer)    IOP
      _INTENT(OUT,character)  STRA*(*), STRB*(*)
CCC_ + Body
      if      (IOP.eq.0) then
         STRA = _TSTAMP
         STRB = ' '
      else if (IOP.eq.1) then
         STRA = _FNAME
         STRB = ' '
      else if (IOP.eq.2) then
         STRA = _REV
         STRB = ' '
      else
         STRA = ' '
         STRB = ' '
      endif
      RETURN
      END
#endif /* OPT_SKIP_ANNOUNCEMENT */
CCC_@ TestSC  ## Test program
#if TEST_USYMCH
      program TestSC
CCC_ + Declaration
      implicit none
CCC_  = Parameter
      integer    MaxTbl
      parameter (MaxTbl = 50000)
      integer    Mdim
      parameter (Mdim   = 10000)
CCC_  = Interior
      integer    iTblX (MaxTbl), iTblY (MaxTbl)
c$$$      integer    nTblX,          nTblY
c
      real*8     vX    (Mdim),   vY    (Mdim)
      real*8     AvrX  (Mdim),   AvrY  (Mdim), AvrM (Mdim)
      real*8     VarX  (Mdim),   VarY  (Mdim), VarM (Mdim)
      real*8     ErrX  (Mdim),   ErrY  (Mdim)
c
      integer    i, j, l, k
      integer    nx, ny, nxy
      real*8     X,  Y,  XO, YO
c$$$      integer    IOS
      integer    MRX, MRY
      logical    Ovct
      integer    iErr, IFP
      integer    lRowM
CCC_ + Body
CCC_  * Read configuration
CCC_   + basic information
      IFP = -1
      Ovct = .FALSE.
      call USCrtb (iErr, NX, NY, iTblX, MaxTbl, IFP)
      if (iErr.eq.1) then
         Ovct = .TRUE.
         call USCrtb (iErr, NX, NY, iTblY, MaxTbl, IFP)
      endif
      write (*, *) 'TABLE', iErr
#if 0
      read (UNIT = *, FMT = *) k
      if (k.gt.-99999) then
         write (*, *) 'NO DUMMY.  ABORT'
         stop
      endif
      read (UNIT = *, FMT = *) NX
      read (UNIT = *, FMT = *) NY
      Ovct = .FALSE.
CCC_   + X table
      l = 0
      do
         read (UNIT = *, FMT = *, IOSTAT = IOS) k
         if (IOS.ne.0)  goto 100
         if (k.le.-99999) then
            Ovct = .true.
            goto 100
         endif
         l = l + 1
         iTblX (l) = k
      enddo
 100  continue
      nTblX = l
CCC_   + Y table if necessary
      if (Ovct) then
         l = 0
         read (UNIT = *, FMT = *) k
         read (UNIT = *, FMT = *) k
         do
            read (UNIT = *, FMT = *, IOSTAT = IOS) k
            if (IOS.ne.0)  goto 200
            if (k.le.-999) goto 200
            l = l + 1
            iTblY (l) = k
         enddo
 200     continue
         nTblY = l
      endif
#endif
CCC_  * Set variable
      if (Ovct) then
         do j = 1, NY
            do i = 1, NX
               k = (j - 1) * NX + i
               XO = dble (NX + 1) / 2.0d0
               YO = dble (NY + 1) / 2.0d0
               X = dble (i) + 0.5d0 - XO
               Y = dble (j)         - YO
               vX (k) = (X**2.0d0 + Y**2.0d0 + 1.0d0)
     $                  * SIGN (1.0d0, X)
               X = dble (i)         - XO
               Y = dble (j) + 0.5d0 - YO
               vY (k) = (X**2.0d0 + Y**2.0d0 + 1.0d0)
     $                  * SIGN (1.0d0, Y)
            enddo
         enddo
      else
         do j = 1, NY
            do i = 1, NX
               k = (j - 1) * NX + i
               X = dble (i) - dble (NX + 1) / 2.0d0
               Y = dble (j) - dble (NY + 1) / 2.0d0
               vX (k) = X**2.0d0 + Y**2.0d0 + 1.0d0
               vY (k) = 0.0d0
            enddo
         enddo
      endif
CCC_  * Compute symmetry score
      if (Ovct) then
         MRX = iTblX (1)
         MRY = iTblY (1)
         call USClma (lRowM, iTblX, iTblY)
c
         call USCscl (AvrX, VarX, vX, iTblX)
         call USCscl (AvrY, VarY, vY, iTblY)
         call USCmrg
     O       (AvrM, VarM,
     I        AvrX, VarX, iTblX, AvrY, VarY, iTblY, lRowM)
         do l = 1, MRX
            write (*, *) 'X', l, AvrX (l), VarX (l)
         enddo
         do l = 1, MRY
            write (*, *) 'Y', l, AvrY (l), VarY (l)
         enddo
         do l = 1, lRowM
            write (*, *) 'M', l, AvrM (l), VarM (l)
         enddo
         NXY = NX * NY
         call USCerd (ErrX, NXY, AvrX, vX, iTblX)
         call USCerd (ErrY, NXY, AvrY, vY, iTblY)
         do j = 1, NY
            do i = 1, NX
               k = (j - 1) * NX + i
               write (*, *) i, j, ErrX (k), vX (k), ErrY (k), vY (k)
            enddo
         enddo
      else
         MRX = iTblX (1)
         call USCscl (AvrX, VarX, vX, iTblX)
         do l = 1, MRX
            write (*, *) l, AvrX (l), VarX (l)
         enddo
         NXY = NX * NY
         call USCerd (ErrX, NXY, AvrX, vX, iTblX)
         do j = 1, NY
            do i = 1, NX
               k = (j - 1) * NX + i
               write (*, *) i, j, ErrX (k), vX (k)
            enddo
         enddo
      endif
      STOP
      END
#endif /* TEST_USYMCH */
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
