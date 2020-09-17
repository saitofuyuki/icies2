C movement/mumcol.F --- IcIES/Movement/Utility collection
C Maintainer:  SAITO Fuyuki
C Created: Nov 7 2018
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2020/01/08 14:56:23 fuyuki mumcol.F>'
#define _FNAME 'movement/mumcol.F'
#define _REV   'Snoopy0.97'
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
c$$$#include "ologfm.h"   /* log common format */
c$$$#include "oarpkw.h"   /* operation id in arpeggio/kiwi */
c$$$#include "movement.h" /* movement definitions */
CCC_ + Table index
#define TBL_FWD 1
#define TBL_BWD 2
CCC_ + Debug
#ifndef    DEBUG_MUMTDS
#  define  DEBUG_MUMTDS 0
#endif
CCC_* Target/skip index table
CCC_ & MUMidv  ## build index vector (inherit MTFidv)
      subroutine MUMidv
     O    (KTB, NH,
     I     VH,  KHH,
     I     HC,  MH,  LH)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)  MH,  LH
      _INTENT(OUT,integer)  KTB (LH, *)
      _INTENT(OUT,integer)  NH
      _INTENT(IN, _REALSTD) VH  (LH, *)
      _INTENT(IN, _REALSTD) HC
      _INTENT(IN, integer)  KHH
      integer  jh
      integer  nh0
      integer  kfw, kbw
CCC_  - Body
      NH  = 0
      NH0 = MH
      kfw = TBL_FWD
      kbw = TBL_BWD
      do jh = 1, MH
         if (VH (jh, KHH).le.HC) then
            KTB (NH0, kfw) = jh
            KTB (jh,  kbw) = NH0
            NH0 = NH0 - 1
         else
            NH = 1 + NH
            KTB (NH, kfw) = jh
            KTB (jh, kbw) = NH
         endif
      enddo
      RETURN
      END
CCC_ & MUMbwz  ## backward conversion via index table (inherit MTFbwz)
      subroutine MUMbwz
     O    (VZ,  KVZ,
     I     VX,  KVX,
     I     KTB, NH, MH, LH, NZ, LZ, KZ0)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)  MH, LH
      _INTENT(IN, integer)  NZ, LZ, KZ0
      _INTENT(IN, integer)  NH, KTB (LH, *)
      _INTENT(IN, integer)  KVX, KVZ
      _INTENT(OUT,_REALSTD) VZ (LH, LZ, *)
      _INTENT(IN, _REALSTD) VX (LH, LZ, *)
      integer  jz,  jz0, jz9
      integer  jh,  jht
      integer  kbw
CCC_  - Body
      kbw = TBL_BWD
      jz0 = max(1, KZ0 - 1)
      jz9 = KZ0 + NZ - 1
      do jz = jz0, jz9
         do jh = 1, MH
            jht = KTB (jh, kbw)
c$$$            write (*, *) jht, jz, VX (jht, jz, KVX)
            VZ (jh, jz, KVZ) = VX (jht, jz, KVX)
         enddo
      enddo
      RETURN
      END
CCC_ & MUMzsc  ## set skipped grids as constant (inherit MACzst)
      subroutine MUMzsc
     M    (VX,  KX,
     I     C0,
     I     KTB, NHt, MH, LH, NZ, LZ, KZ0)
CCC_  - Declaration
      implicit none
c
      _INTENT(IN, integer)  MH, LH
      _INTENT(IN, integer)  NZ, LZ, KZ0

      _INTENT(INOUT,_REALSTD) VX (LH, LZ, *)
      _INTENT(IN,   _REALSTD) C0
      _INTENT(IN,   integer)  KX
      _INTENT(IN,   integer)  KTB(LH, *)
      _INTENT(IN,   integer)  NHt
      integer  jh, jht
      integer  jz, jzz
      integer  kfw
CCC_  - Body
      kfw  = TBL_FWD
      do jzz = 1, NZ
         jz = KZ0 + jzz - 1
         do jht = NHt + 1, MH
            jh = KTB (jht, kfw)
            VX (jht, jz, KX) = C0
         enddo
      enddo
      RETURN
      END
CCC_ & MUMzsf  ## set skipped 3d grids as input 2d array (inherit MTTzst)
      subroutine MUMzsf
     M    (VX,  KX,
     I     VI,  KI,
     I     KTB, NHt, MH, LH, NZ, LZ, KZ0)
CCC_  - Declaration
      implicit none
c
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
      _INTENT(INOUT,_REALSTD) VX (LH, LZ, *)
      _INTENT(IN,   _REALSTD) VI (LH, *)
      _INTENT(IN,   integer)  KX, KI
      _INTENT(IN,   integer)  KTB(LH, *)
      _INTENT(IN,   integer)  NHt
      integer  jh, jht
      integer  jz, jzz
      integer  kfw
CCC_  - Body
      kfw = TBL_FWD
      do jzz = 1, NZ
         jz = KZ0 + jzz - 1
         do jht = NHt + 1, MH
            jh = KTB (jht, kfw)
            VX(jht, jz, KX) = VI(jh, KI)
         enddo
      enddo
      RETURN
      END
CCC_* Tridiagonal solver
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
      kfw   = TBL_FWD
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
      kfw   = TBL_FWD
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
