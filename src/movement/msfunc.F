C movement/msfunc.F --- IcIES/Movement/SSA/common
C Maintainer:  SAITO Fuyuki
C Created: Jan 3 2012
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2016/07/19 10:27:20 fuyuki msfunc.F>'
#define _FNAME 'movement/msfunc.F'
#define _REV   'Snoopy0.9/Three0.1'
CCC_! MANIFESTO
C
C Copyright (C) 2012--2020
C           Japan Agency for Marine-Earth Science and Technology,
C           Ayako ABE-OUCHI
C
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
CCC_* Common macros
#include "ofdlct.h" /* fortran dialect */
CCC_* primitives
CCC_ & MSFdux  ## Movement/SSA PQ to u-gradient conversion
      subroutine MSFdux
     O    (VO,
     I     VX, VV,
     I     KG, KP, KQ, Kmu, N, L)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)  N,  L
      _INTENT(OUT,_REALSTD) VO (L, *)
      _INTENT(IN, _REALSTD) VX (L, *)
      _INTENT(IN, _REALSTD) VV (L, *)
      _INTENT(IN, integer)  KG,  KP, KQ, Kmu
      integer j
CCC_  - Body
      do j = 1, N
         if (VV (j, Kmu).eq.0.0d0) then
            VO (j, KG) = 0.0d0
         else
            VO (j, KG) =
     $           (2.0d0 * VX (j, KP) - VX (j, KQ)) / 6.0d0 / VV (j, Kmu)
         endif
      enddo
      RETURN
      END
CCC_ & MSFvmg  ## Movement/SSA velocity magnitude suite
      subroutine MSFvmg
     O    (V,
     W     CW,
     I     X,    VC,   WW,
     I     KVa,  KVu,  KVv,
     I     KXU,  KXV,  KCMi,
     I     KOLx, KOLy, N,   L,   ipKW, iMA, KWM)
CCC_  - Description
CC    output V (*, KVa)
CC    work   V (*, KVu), V (*, KVv)
CC    input  X (*, KXU), X (*, KXV),  VC (*, KMI)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)  N,  L
      _INTENT(OUT,_REALSTD) V  (L, *)
      _INTENT(OUT,_REALSTD) CW (*)
      _INTENT(IN, _REALSTD) X  (L, *)
      _INTENT(IN, _REALSTD) VC (L, *)
      _INTENT(IN, _REALSTD) WW (*)
      _INTENT(IN, integer)  KVa,  KVu,  KVv
      _INTENT(IN, integer)  KXU,  KXV,  KCMi
      _INTENT(IN, integer)  KOLx, KOLy
      _INTENT(IN, integer)  ipKW (*)
      _INTENT(IN, integer)  iMA  (*), KWM
CCC_  - Body
CCC_   . L ba u
      call AKBwaz
     O    (V  (1, KVu),  CW,
     I     X  (1, KXU),  WW,
     I     N,  L,        ipKW, iMA, KOLx, KWM)
CCC_   . I:a u:a
      call UV1uma (V, VC, N, L, KVu, KCMi)
CCC_   . L ca v
      call AKBwaz
     O    (V  (1, KVv),  CW,
     I     X  (1, KXV),  WW,
     I     N,  L,        ipKW, iMA, KOLy, KWM)
CCC_   . I:a v:a
      call UV1uma (V, VC, N, L, KVv, KCMi)
CCC_   . sqrt uu+vv
      call UV0nha (V, N, L, KVa, KVu, KVv)
      RETURN
      END
CCC_ & MSFesr  ## Movement/SSA effective strain rate square
      subroutine MSFesr
     M    (V,
     I     KL,  KUX, KVY,  KR, N, L)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(INOUT,_REALSTD) V (L, *)
      _INTENT(IN,   integer)  KL
      _INTENT(IN,   integer)  KUX, KVY, KR
      integer  kp
      do kp = 1, N
         V (kp, KL) =
     $        (((V (kp, KUX)**2.0d0)+(V (kp, KVY)**2.0d0))
     $         +(V (kp, KUX) * V (kp, KVY)))
     $        +(V (kp, KR) ** 2.0d0 ) / 4.0d0
      enddo
      RETURN
      END
CCC_ & MSFess  ## Movement/SSA effective strain rate square
      subroutine MSFess
     M    (VG,
     I     KL,     KUX, KUY, KVX, KVY,  N, L)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KL
      _INTENT(IN,   integer)  KUX, KUY, KVX, KVY
      _INTENT(INOUT,_REALSTD) VG (L, *)
      integer  kp
      do kp = 1, N
         VG (kp, KL) =
     $        (((VG (kp, KUX)**2.0d0)+(VG (kp, KVY)**2.0d0))
     $         +(VG (kp, KUX) * VG (kp, KVY)))
     $        +((VG (kp, KUY) + VG (kp, KVX)) ** 2.0d0 ) / 4.0d0
      enddo
      RETURN
      END
CCC_ & MSFvsc  ## Movement/SSA viscosity
      subroutine MSFvsc
     M    (V,
     I     VC,   VLIM,
     I     KL,   KESS, KBI, PF, N, L)
      implicit none
      _INTENT(INOUT,_REALSTD) V  (L, *)
      _INTENT(IN,   _REALSTD) VC (L, *)
      _INTENT(IN,   _REALSTD) VLIM
      _INTENT(IN,   integer)  N,  L
      _INTENT(IN,   integer)  KL
      _INTENT(IN,   integer)  KESS, KBI
      _INTENT(IN,   _REALSTD) PF
      integer  kp
      _REALSTD C, E
      C = - (1.0d0 - 1.0d0 / PF) / 2.0d0
      do kp = 1, N
         E = MAX (VLIM, V (kp, KESS))
         V (kp, KL) =
     $        (E ** C) * VC (kp, KBI) * 0.5d0
c$$$         if (V (kp, KESS).eq.0.0d0) then
c$$$            V (kp, KL) = 0.0d0
c$$$         else
c$$$            V (kp, KL) =
c$$$     $           (V (kp, KESS) ** C) * VC (kp, KBI) * 0.5d0
c$$$         endif
      enddo
      RETURN
      END
CCC_ & MSFesp  ## Movement/SSA effective strain rate square, powered
      subroutine MSFesp
     O    (VF,
     I     V,   VLIM, PF,
     I     KL,  KUX,  KVY,  KR, N, L)
      implicit none
      _INTENT(IN, integer)  N,   L
      _INTENT(OUT,_REALSTD) VF (L, *)
      _INTENT(IN, _REALSTD) V  (L, *)
      _INTENT(IN, _REALSTD) VLIM, PF
      _INTENT(IN, integer)  KL
      _INTENT(IN, integer)  KUX, KVY, KR
      _REALSTD C, E
      integer  kp
CC VF = 0.5 [max(de,d0) ** (-(1-1/n))]
      C = - (1.0d0 - 1.0d0 / PF) / 2.0d0
      do kp = 1, N
         E =
     $        (((V (kp, KUX)**2.0d0)+(V (kp, KVY)**2.0d0))
     $         +(V (kp, KUX) * V (kp, KVY)))
     $        +(V (kp, KR) ** 2.0d0 ) / 4.0d0
         VF (kp, KL) = ((MAX (VLIM, E)) ** C) * 0.5d0
      enddo
      RETURN
      END
CCC_ & MSFfsp  ## Movement/SSA effective strain rate square, powered (b)
      subroutine MSFfsp
     M    (V,
     I     VLIM, PF,
     I     KL,   KUX,  KVY,  KR, N, L)
      implicit none
      _INTENT(IN,   integer)  N, L
      _INTENT(INOUT,_REALSTD) V (L, *)
      _INTENT(IN,   _REALSTD) VLIM, PF
      _INTENT(IN,   integer)  KL
      _INTENT(IN,   integer)  KUX, KVY, KR
      _REALSTD C, E
      integer  kp
CC VF = 0.5 [max(de,d0) ** (-(1-1/n))]
      C = - (1.0d0 - 1.0d0 / PF) / 2.0d0
      do kp = 1, N
         E =
     $        (((V (kp, KUX)**2.0d0)+(V (kp, KVY)**2.0d0))
     $         +(V (kp, KUX) * V (kp, KVY)))
     $        +(V (kp, KR) ** 2.0d0 ) / 4.0d0
         V (kp, KL) = ((MAX (VLIM, E)) ** C) * 0.5d0
      enddo
      RETURN
      END
c$$$CCC_ & MSFvsp  ## Movement/SSA viscosity (after MSFesp)
c$$$      subroutine MSFvsp
c$$$     M    (V,
c$$$     I     VF,   VC,
c$$$     I     KL,   KFF, KBI, N, L)
c$$$      implicit none
c$$$      _INTENT(INOUT,_REALSTD) V  (L, *)
c$$$      _INTENT(IN,   _REALSTD) VC (L, *)
c$$$      _INTENT(IN,   _REALSTD) VF (L, *)
c$$$      _INTENT(IN,   integer)  N,  L
c$$$      _INTENT(IN,   integer)  KL
c$$$      _INTENT(IN,   integer)  KFF, KBI
c$$$      integer  kp
c$$$      do kp = 1, N
c$$$         V (kp, KL) = VF (kp, KFF) * VC (kp, KBI)
c$$$      enddo
c$$$      RETURN
c$$$      END
CCC_ & MSFvsg  ## Movement/SSA viscosity (initial guess)
      subroutine MSFvsg
     M    (V,
     I     VC,
     I     KL,  KBI, SCXFSR, N, L)
      implicit none
      _INTENT(INOUT,_REALSTD) V  (L, *)
      _INTENT(IN,   _REALSTD) VC (L, *)
      _INTENT(IN,   integer)  N,  L
      _INTENT(IN,   integer)  KL
      _INTENT(IN,   integer)  KBI
      _INTENT(IN,   _REALSTD) SCXFSR
      integer  kp
c$$$      _REALSTD C, TVX, TVXC
c$$$      C    = - (1.0d0 - 1.0d0 / PF) / 2.0d0
c$$$      TVX  = (SCV / SCL) ** 2.0d0
c$$$      TVXC = (TVX ** C) * 0.5d0
      do kp = 1, N
         V (kp, KL) = SCXFSR * VC (kp, KBI)
c$$$         V (kp, KL) = TVXC * VC (kp, KBI)
      enddo
      RETURN
      END
CCC_ & MSFvsm  ## Movement/SSA viscosity (initial guess 2)
      subroutine MSFvsm
     M    (V,
     I     VC,
     I     KL,  KBI, SCXFSR, N, L)
      implicit none
      _INTENT(INOUT,_REALSTD) V  (L, *)
      _INTENT(IN,   _REALSTD) VC (L, *)
      _INTENT(IN,   integer)  N,  L
      _INTENT(IN,   integer)  KL
      _INTENT(IN,   integer)  KBI
      _INTENT(IN,   _REALSTD) SCXFSR
      integer  kp
c$$$      _REALSTD C, TVX, TVXC
c$$$      C    = - (1.0d0 - 1.0d0 / PF) / 2.0d0
c$$$      TVX  = (SCV / SCL) ** 2.0d0
c$$$      TVXC = (TVX ** C) * 0.5d0
      do kp = 1, N
         if (V (kp, KL).le.0.0d0) then
            V (kp, KL) = SCXFSR * VC (kp, KBI)
c$$$            V (kp, KL) = TVXC * VC (kp, KBI)
         endif
      enddo
      RETURN
      END
c$$$CCC_ & MSFvsc  ## Movement/SSA viscosity
c$$$      subroutine MSFvsc
c$$$     M    (VG,
c$$$     I     KL,   KESS, KH, KARFI, PF, N, L)
c$$$      implicit none
c$$$      _INTENT(IN,   integer)  N,  L
c$$$      _INTENT(IN,   integer)  KL
c$$$      _INTENT(IN,   integer)  KESS, KH, KARFI
c$$$      _INTENT(IN,   _REALSTD) PF
c$$$      _INTENT(INOUT,_REALSTD) VG (L, *)
c$$$      integer  kp
c$$$      _REALSTD C
c$$$      C = - (1.0d0 - 1.0d0 / PF) / 2.0d0
c$$$      do kp = 1, N
c$$$         VG (kp, KL) =
c$$$     $        (VG (kp, KESS) ** C) * VG (kp, KH) * VG (kp, KARFI)
c$$$     $        * 0.5d0
c$$$      enddo
c$$$      RETURN
c$$$      END
CCC_ & MSFhsi  ## hidrostatic pressure integral
      subroutine MSFhsi
     O    (V,
     I     VI,
     I     KL, KH, DI, DW, GR, N, L)
      implicit none
      _INTENT(IN, integer)  N, L
      _INTENT(OUT,_REALSTD) V  (L, *)
      _INTENT(IN, _REALSTD) VI (L, *)
      _INTENT(IN, _REALSTD) DI,  DW,  GR
      _INTENT(IN, integer)  KL, KH
      integer j
      _REALSTD   VH, DDG
c
      DDG = DI / DW * (DW - DI) * GR * 0.5d0
c
      do j = 1, N
         VH = VI (j, KH)
         V (j, KL) = DDG * (VH * VH) * 1.0d0
      enddo
c
      RETURN
      END
CCC_ & MSFhcv  ## thickness correction after calving
      subroutine MSFhcv
     M    (V,
     I     VI,
     I     N, L,  KL, KIK, KH, DOC)
      implicit none
      _INTENT(IN, integer)  N, L
      _INTENT(OUT,_REALSTD) V  (L, *)
      _INTENT(IN, _REALSTD) VI (L, *)
      _INTENT(IN, _REALSTD) DOC
      _INTENT(IN, integer)  KL, KH, KIK
      integer j
      do j = 1, N
         if (V (j, KIK) .eq. DOC) then
            V (j, KL) = 0.0d0
         else
            V (j, KL) = VI (j, KH)
         endif
      enddo
      RETURN
      END
CCC_& MSFUNC  ## Movement/SSA/functions announcement
      subroutine MSFUNC (STRA, STRB, IOP)
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
CCC_@ MSFTST  ## not implemented
CCC_ + Test suites
CC::   KINDS 0
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
