C movement/mumcol.F --- IcIES/Movement/Utility collection
C Maintainer:  SAITO Fuyuki
C Created: Nov 7 2018
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2018/11/07 10:10:17 fuyuki mumcol.F>'
#define _FNAME 'movement/mumcol.F'
#define _REV   'Snoopy0.9'
CCC_! MANIFESTO
C
C Copyright (C) 2018--2020
C           Japan Agency for Marine-Earth Science and Technology,
C           Ayako ABE-OUCHI
C
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
CCC_* Common macros
#include "ofdlct.h"   /* fortran dialect */
#include "ologfm.h"   /* log common format */
#include "oarpkw.h"   /* operation id in arpeggio/kiwi */
#include "movement.h" /* movement definitions */
CCC_ + Debug
#ifndef    DEBUG_MUMTDS
#  define  DEBUG_MUMTDS 0
#endif
CCC_ & MUMtds  ## tridiagonal matrix solver (z outer)
      subroutine MUMtds
     O    (iErr,
     M     VX,
     W     W,
     I     KX,   KW,   KU,   KD,  KL,  KB,
     I     KTB,  NH,   LH,   NZ,  LZ,  KZ0,
     I     IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  NH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
      _INTENT(INOUT,_REALSTD) VX (LH, LZ, *)
      _INTENT(INOUT,_REALSTD) W  (*)
      _INTENT(IN,   integer)  KTB (LH, *)
      _INTENT(IN,   integer)  KX, KW
      _INTENT(IN,   integer)  KU, KD, KL, KB
      _INTENT(IN,   integer)  IFPl
c
      integer   jh
      integer   jzz, jz
#if DEBUG_MUMTDS
      integer   jht
      integer   kfw
#endif /* DEBUG_MUMTDS */
CCC_  - Body
      iErr  = 0
c
#if DEBUG_MUMTDS
      kfw   = 1
      do jht = 1, NH
         jh = KTB (jht, kfw)
         W  (jh) = VX (jh, KZ0, KD)
         VX (jh, KZ0, KX) = VX (jh, KZ0, KB) / W (jh)
      enddo
#else /* not  DEBUG_MUMTDS */
      do jh = 1, NH
         W  (jh) = VX (jh, KZ0, KD)
         VX (jh, KZ0, KX) = VX (jh, KZ0, KB) / W (jh)
      enddo
#endif /* not  DEBUG_MUMTDS */
c
      do jzz = 2, NZ
         jz = KZ0 + jzz - 1
#if DEBUG_MUMTDS
         do jht = 1, NH
            jh = KTB (jht, kfw)
            VX (jh, jz, KW) =
     $           VX (jh, jz - 1, KU) / W (jh)
            W  (jh) =
     $           VX (jh, jz, KD) - VX (jh, jz, KL) * VX (jh, jz, KW)
            VX (jh, jz, KX) =
     $           (VX (jh, jz, KB) - VX (jh, jz, KL) *  VX(jh, jz-1, KX))
     $           / W (jh)
         enddo
#else /* not  DEBUG_MUMTDS */
         do jh = 1, NH
            VX (jh, jz, KW) =
     $           VX (jh, jz - 1, KU) / W (jh)
            W  (jh) =
     $           VX (jh, jz, KD) - VX (jh, jz, KL) * VX (jh, jz, KW)
            VX (jh, jz, KX) =
     $           (VX (jh, jz, KB) - VX (jh, jz, KL) *  VX(jh, jz-1, KX))
     $           / W (jh)
         enddo
#endif /* not  DEBUG_MUMTDS */
      enddo
c
      do jzz = NZ - 1, 1, -1
         jz = KZ0 + jzz - 1
#if DEBUG_MUMTDS
         do jht = 1, NH
            jh = KTB (jht, kfw)
            VX (jh, jz, KX) =
     $           VX (jh, jz,KX) - (VX (jh, jz+1, KW) * VX (jh, jz+1,KX))
         enddo
#else /* not  DEBUG_MUMTDS */
         do jh = 1, NH
            VX (jh, jz, KX) =
     $           VX (jh, jz,KX) - (VX (jh, jz+1, KW) * VX (jh, jz+1,KX))
         enddo
#endif /* not  DEBUG_MUMTDS */
      enddo
      RETURN
      END
CCC_ & MUMtdz  ## matrix tridiagonal solver (z inner)
      subroutine MUMtdz
     O    (iErr,
     M     VX,
     W     W,
     I     KX,   KW,   KU,   KD,  KL,  KB,
     I     KTB,  NH,   LH,   NZ,  LZ,  KZ0,
     I     IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  NH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
      _INTENT(INOUT,_REALSTD) VX (LH, LZ, *)
      _INTENT(INOUT,_REALSTD) W  (*)
      _INTENT(IN,   integer)  KTB (LH, *)
      _INTENT(IN,   integer)  KX, KW
      _INTENT(IN,   integer)  KU, KD, KL, KB
      _INTENT(IN,   integer)  IFPl
c
      integer   jh
      integer   jzz, jz
#if DEBUG_MUMTDS
      integer   jht
      integer   kfw
#endif /* not  DEBUG_MUMTDS */
CCC_  - Body
      iErr  = 0
c
#if DEBUG_MUMTDS
      kfw   = 1
      do jht = 1, NH
         jh = KTB (jht, kfw)
         W  (jh) = VX (jh, KZ0, KD)
         VX (jh, KZ0, KX) = VX (jh, KZ0, KB) / W (jh)
      enddo
#else /* not  DEBUG_MUMTDS */
      do jh = 1, NH
         W  (jh) = VX (jh, KZ0, KD)
         VX (jh, KZ0, KX) = VX (jh, KZ0, KB) / W (jh)
      enddo
#endif
c
#if DEBUG_MUMTDS
      do jht = 1, NH
         jh = KTB (jht, kfw)
         do jzz = 2, NZ
            jz = KZ0 + jzz - 1
            VX (jh, jz, KW) =
     $           VX (jh, jz - 1, KU) / W (jh)
            W  (jh) =
     $           VX (jh, jz, KD) - VX (jh, jz, KL) * VX (jh, jz, KW)
            VX (jh, jz, KX) =
     $           (VX (jh, jz, KB) - VX (jh, jz, KL) *  VX(jh, jz-1, KX))
     $           / W (jh)
         enddo
      enddo
#else /* not  DEBUG_MUMTDS */
      do jh = 1, NH
         do jzz = 2, NZ
            jz = KZ0 + jzz - 1
            VX (jh, jz, KW) =
     $           VX (jh, jz - 1, KU) / W (jh)
            W  (jh) =
     $           VX (jh, jz, KD) - VX (jh, jz, KL) * VX (jh, jz, KW)
            VX (jh, jz, KX) =
     $           (VX (jh, jz, KB) - VX (jh, jz, KL) *  VX(jh, jz-1, KX))
     $           / W (jh)
         enddo
      enddo
#endif /* not  DEBUG_MUMTDS */
c
#if DEBUG_MUMTDS
      do jht = 1, NH
         jh = KTB (jht, kfw)
         do jzz = NZ - 1, 1, -1
            jz = KZ0 + jzz - 1
            VX (jh, jz, KX) =
     $           VX (jh, jz,KX) - (VX (jh, jz+1, KW) * VX (jh, jz+1,KX))
         enddo
      enddo
#else /* not  DEBUG_MUMTDS */
      do jh = 1, NH
         do jzz = NZ - 1, 1, -1
            jz = KZ0 + jzz - 1
            VX (jh, jz, KX) =
     $           VX (jh, jz,KX) - (VX (jh, jz+1, KW) * VX (jh, jz+1,KX))
         enddo
      enddo
#endif /* not  DEBUG_MUMTDS */
      RETURN
      END
CCC_& MUMCOL  ## Movement/Utility collection announcement
      subroutine MUMCOL (STRA, STRB, IOP)
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
CCC_* Test
CCC_ + begin
#if     TEST_MUMCOL
CCC_ @ MUMTST  ## Movement/Utility test program
#include "ofnstd.h"
#include "odevid.h"  /* MPI table */
      program MUMTST
CCC_  - Test suites
CCC_  - Declaration
      implicit none
      integer iErr
      integer ipA (LOG_CHANNEL_MAX)
      integer iMA (MAX_MPI_ATTR)
CCC_  - Body
      call DDcapo
     O    (iErr,
     I     2, ' ', 'O', _FNAME, -1)
      if (iErr.eq.0) then
         call DLCmng (ipA, 't')
         call DVHrgC (iErr, MOVEMENT_DV_CLS, ' ', ' ', ipA)
      endif
      if (iErr.eq.0) then
         call DMAtma (iMA)
         call MUMtestMain (iErr, ipA, iMA)
         call ACCrep (FPL(ipA), 0)
      endif
      call DevFin (iErr)
      STOP
      END
CCC_ & MUMtestMain   ## main
      subroutine MUMtestMain (iErr, ipA, iMA)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(IN, integer) ipA (*)
      _INTENT(IN, integer) iMA (*)
CCC_  - Body
      iErr = 0
      RETURN
      END
CCC_ + end
#endif  /* TEST_MUMCOL */
CCC_* obsolete
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
