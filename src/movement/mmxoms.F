C movement/mmxoms.F --- IcIES/Movement/matrix operators (symmetric/kiwi)
C Maintainer:  SAITO Fuyuki
C Created: Dec 22 2011
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2020/09/17 08:46:09 fuyuki mmxoms.F>'
#define _FNAME 'movement/mmxoms.F'
#define _REV   'Snoopy0.97'
CCC_! MANIFESTO
C
C Copyright (C) 2011--2020
C           Japan Agency for Marine-Earth Science and Technology,
C           Ayako ABE-OUCHI
C
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
CCC_* Common macros
#include "ofdlct.h"   /* fortran dialect */
#include "oarpea.h"
#include "oarpkw.h"   /* operation id in arpeggio/kiwi */
#include "movement.h" /* movement definitions */
CCC_ + test features
#ifndef    OPT_MMXOMS_D00
#  define  OPT_MMXOMS_D00 0  /* do not allow D00 switch */
#endif
CCC_* [MMX] matrix common
CCC_ & MMXgen  ## Movement/matrix generator
      subroutine MMXgen
     O    (iErr,
     O     X,    QM,   F0,
     W     VW,   CW,
     I     VMI,  VMC,  VMHB, VMID, DT,   WF,
     I     WW,
     I     ipKW, iMA,  ipCG, MH,   LH,   LCG, MTYP, ITYP)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,integer)  iErr
      _INTENT(IN, integer)  MH, LH
c
      _INTENT(OUT,_REALSTD) X    (LH, *)
      _INTENT(OUT,_REALSTD) QM   (LH, *)
      _INTENT(OUT,_REALSTD) F0
c
      _INTENT(OUT,_REALSTD) VW   (LH, *)
      _INTENT(OUT,_REALSTD) CW   (LH, *)
c
      _INTENT(IN, _REALSTD) VMI  (LH, *)
      _INTENT(IN, _REALSTD) VMHB (LH, *)
      _INTENT(IN, _REALSTD) VMC  (LH, *)
      _INTENT(IN, _REALSTD) VMID (LH, *)
c
      _INTENT(IN, _REALSTD) DT, WF
      _INTENT(IN, _REALSTD) WW (*)
      _INTENT(IN, integer)  ipKW (*)
      _INTENT(IN, integer)  iMA  (*)
      _INTENT(IN, integer)  LCG,  ipCG (*)
      _INTENT(IN, integer)  MTYP, ITYP
      integer kp
CCC_  * Body
      iErr = 0
CCC_   + branch
      if      (MTYP.eq. MMXSW_UP1) then
         call MMUgen
     O       (iErr,
     O        X,    QM,   F0,
     W        VW,   CW,
     I        VMI,  VMC,  VMHB, VMID, DT,   WF,
     I        WW,
     I        ipKW, iMA,  MH,   LH,   MTYP)
      else if (MTYP.eq. MMXSW_UPD) then
         call MMZgen
     O       (iErr,
     O        X,    QM,   F0,
     W        VW,   CW,
     I        VMI,  VMC,  VMHB, VMID, DT,   WF,
     I        WW,
     I        ipKW, iMA,  MH,   LH,   MTYP)
      else if (MTYP.eq. MMXSW_UPE) then
         call MMYgen
     O       (iErr,
     O        X,    QM,   F0,
     W        VW,   CW,
     I        VMI,  VMC,  VMHB, VMID, DT,   WF,
     I        WW,
     I        ipKW, iMA,  MH,   LH,   MTYP)
      else if (MTYP.eq.MMXSW_DVB
     $        .or. MTYP.eq.MMXSW_ZEV
     $        .or. MTYP.eq.MMXSW_DE
     $        .or. MTYP.eq.MMXSW_D00) then
         call MMDgen
     O       (iErr,
     O        X,    QM,   F0,
     W        VW,   CW,
     I        VMI,  VMC,  VMHB, VMID, DT,   WF,
     I        WW,
     I        ipKW, iMA,  MH,   LH,   MTYP)
      else
         call MMHgen
     O       (iErr,
     O        X,    QM,   F0,
     W        VW,   CW,
     I        VMI,  VMC,  VMHB, VMID, DT,   WF,
     I        WW,
     I        ipKW, iMA,  ipCG, MH,   LH,   LCG, MTYP)
      endif
CCC_   . initial guess
      if (iErr.eq.0) then
         if      (ITYP.eq.MMXINI_0)   then
            call UV0sta (X,      MH, LH, BCGW_XX, 0.0d0)
         else if (ITYP.eq.MMXINI_OLD) then
            call UV1cpa (X, VMI, MH, LH, BCGW_XX, VMI_Ha)
         else
            iErr = -1
         endif
      endif
CCC_   . save initial guess
      if (iErr.eq.0) then
         call UV0cpa (X, MH, LH, BCGW_XH1, BCGW_XX)
      endif
      RETURN
      END
CCC_ & MMXcgs  ## Movement/matrix clone group declaration
      subroutine MMXcgs
     O    (iErr,
     O     ipCG,
     W     kDTA,
     I     LTBL, LCG, LH, LCK, ipKW, IE, IFP)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,  integer) iErr
      _INTENT(IN,   integer) LCG, LH, LTBL, LCK
      _INTENT(INOUT,integer) ipCG (LCG, *)
      _INTENT(IN,   integer) ipKW (*), IE (*), IFP
      _INTENT(OUT,  integer) kDTA (LTBL, 3)
CCC_  * Body
      iErr = 0
      if (iErr.eq.0) then
         call MMDcgs
     O       (iErr,
     O        ipCG,
     W        kDTA,
     I        LTBL, LCG, LH, LCK, ipKW, IE, IFP)
      endif
      if (iErr.eq.0) then
         call MMHcgs
     O       (iErr,
     O        ipCG,
     W        kDTA,
     I        LTBL, LCG, LH, LCK, ipKW, IE, IFP)
      endif
      RETURN
      END
CCC_ & MMXdec  ## Movement/matrix operators kiwi declaration
      subroutine MMXdec
     O    (iErr,
     M     ipKW,
     I     IFP)
      implicit none
      _INTENT(OUT,  integer) iErr
      _INTENT(INOUT,integer) ipKW (*)
      _INTENT(IN,   integer) IFP
c
      iErr = 0
      if (iErr.eq.0) call MMDdec (iErr, ipKW, IFP)
      if (iErr.eq.0) call MMUdec (iErr, ipKW, IFP)
      if (iErr.eq.0) call MMZdec (iErr, ipKW, IFP)
      if (iErr.eq.0) call MMYdec (iErr, ipKW, IFP)
      if (iErr.eq.0) call MMHdec (iErr, ipKW, IFP)
c
      RETURN
      END
CCC_ & MMXipN  ## Movement/matrix inner product (Normal)
      subroutine MMXipN
     O    (pi,
     W     GW,
     I     X,   KXL,   KXR1, KXR2,
     I     iMA, KSglb, IE,   MH,   LH, NG, IR, IROOT, NR)
c
      implicit none
      _INTENT(OUT,  _REALSTD) pi
      _INTENT(IN,   integer)  NR
      _INTENT(OUT,  _REALSTD) GW (NR)
      _INTENT(IN,   integer)  MH, LH, KXL, KXR1, KXR2, NG
      _INTENT(INOUT,_REALSTD) X (LH, *)
      _INTENT(IN,   integer)  iMA (*), IE (*), KSglb (*)
      _INTENT(IN,   integer)  IR, IROOT
      integer jp
      _REALSTD S
c
      call UV0nma (X, MH, LH, KXL, KXR1, KXR2)
c
      S = X (1, KXL)
      do jp = 2, MH
         S = S + X (jp, KXL)
      enddo
      call DMWgts (GW, S, 1, IROOT, iMA)
      pi = 0.0d0
      if (IR.eq.IROOT) then
         S  = GW (1)
         do jp = 2, NR
            S = S + GW (jp)
         enddo
         pi = S
      endif
      call DMWbcs (pi, IROOT, iMA)
      RETURN
      END
CCC_ & MMXipK  ## Movement/matrix inner product (Kahan)
      subroutine MMXipK
     O    (pi,
     W     GW,
     I     X,   KXL,   KXR1, KXR2,
     I     iMA, KSglb, IE,   MH,   LH, NG, IR, IROOT, NR)
c
      implicit none
      _INTENT(OUT,  _REALSTD) pi
      _INTENT(IN,   integer)  NR
      _INTENT(OUT,  _REALSTD) GW (2, NR)
      _INTENT(IN,   integer)  MH, LH, KXL, KXR1, KXR2, NG
      _INTENT(INOUT,_REALSTD) X (LH, *)
      _INTENT(IN,   integer)  iMA (*), IE (*), KSglb (*)
      _INTENT(IN,   integer)  IR, IROOT
      integer MO,   LG
      integer jErr
      integer jp
      _REALSTD S (2), T, Y, C
c
      call UV0nma (X, MH, LH, KXL, KXR1, KXR2)
c
      S (2) = 0.0d0
      S (1) = X (1, KXL)
      do jp = 2, MH
         Y     = X (jp, KXL) - S (2)
         T     = S (1) + Y
         S (2) = (T - S (1)) - Y
         S (1) = T
      enddo
c
      call DMWgts (GW, S, 2, IROOT, iMA)
      pi = 0.0d0
      if (IR.eq.IROOT) then
         S (2)  = 0.0d0
         S (1)  = GW (2, 1)
         do jp = 2, NR
            Y     = GW (2, jp) - S (2)
            T     = S (1) + Y
            S (2) = (T - S (1)) - Y
            S (1) = T
         enddo
         do jp = 1, NR
            Y     = GW (1, jp) - S (2)
            T     = S (1) + Y
            S (2) = (T - S (1)) - Y
            S (1) = T
         enddo
         pi = S (1)
      endif
      call DMWbcs (pi, IROOT, iMA)
      RETURN
      END
CCC_ & MMXipG  ## Movement/matrix inner product (collection)
      subroutine MMXipG
     O    (pi,
     W     GW,
     I     X,   KXL,   KXR1, KXR2,
     I     iMA, KSglb, IE,   MH,   LH, NG, IR, IROOT, NR)
c
      implicit none
      _INTENT(OUT,  _REALSTD) pi
      _INTENT(OUT,  _REALSTD) GW (*)
      _INTENT(IN,   integer)  MH, LH, KXL, KXR1, KXR2, NG
      _INTENT(INOUT,_REALSTD) X (LH, *)
      _INTENT(IN,   integer)  iMA (*), IE (*), KSglb (*)
      _INTENT(IN,   integer)  IR, IROOT, NR
      integer MO,   LG
      integer jErr, kg
c
      call UV0nma (X, MH, LH, KXL, KXR1, KXR2)
c
      MO    = 1
      LG    = LH
      call AEGcls
     O    (jErr,  GW, X (1, KXL), LH, LG, MO, iROOT, KSglb, IE, iMA)
      pi = 0.0d0
      if (IR.eq.IROOT) then
         do kg = 1, NG
            pi = pi + GW (kg)
         enddo
      endif
      call DMWbcs (pi, IROOT, iMA)
      RETURN
      END
CCC_ & MMXinm  ## Movement/matrix infinity-norm
      subroutine MMXinm
     O    (xnrm,
     W     GW,
     I     X,    KXR, iMA, IE, MH, LH)
      implicit none
      _INTENT(OUT,_REALSTD) xnrm
      _INTENT(IN, integer)  MH, LH, KXR
      _INTENT(OUT,_REALSTD) GW (*)
      _INTENT(IN, _REALSTD) X (LH, *)
      _INTENT(IN, integer)  iMA (*), IE (*)
      integer kp
      xnrm = 0.0d0
      do kp = 1, MH
         xnrm = MAX (ABS (X (kp, KXR)), xnrm)
      enddo
      call DMWcma (xnrm, iMA)
      RETURN
      END
CCC_* [MMD] D/E type matrix
CCC_ + Description
CC
CC               e         e   o        o   e
CC     M = Mask [Div:ab   [D:b Grd:ba + E:b L:ba]
CC               + Div:ac [D:c Grd:ca + E:c L:ca]]
CC       + F0
CC
CC     T = [[Grd:ba D:b + L:ba E:b] Div:ab
CC          + Grd:ca D:c + L:ca E:c] Div:ac] Mask
CC       + F0
CC
CCC_ & MMDmns  ## Movement/matrix multiplication suite
      subroutine MMDmns
     M    (X,
     I     KXL,  KXR,
     W     C,    W,
     I     F0,   QM,   WW,
     I     iMA,  ipKW, ipCG, MH, LH, LCG)
CCC_  * Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH, KXR, KXL
      _INTENT(IN,   integer)  LCG
      _INTENT(INOUT,_REALSTD) X    (LH,  *)
      _INTENT(OUT,  _REALSTD) C    (*)
      _INTENT(OUT,  _REALSTD) W    (LH,  *)
      _INTENT(IN,   _REALSTD) QM   (*),  F0
      _INTENT(IN,   _REALSTD) WW   (*)
      _INTENT(IN,   integer)  iMA  (*),  ipKW (*)
      _INTENT(IN,   integer)  ipCG (LCG, *)
      integer KSW
CCC_  * Body
      KSW = KWM_M
CCC_   + clone group
      call AKCgux
     O    (C,
     I     X,    MH,   LH,  KXR,
     I     iMA,  ipCG (1, CGB_XHaN))
CCC_   + [B1:b, B2:c] = <grad_xy a:bc> H:a (clone group)
      call AKGwaz
     M    (W (1, VMIW_W1),
     I     C,    X (1, KXR), WW,
     I     MH,   LH,  ipKW, 3, ipCG (1, CGB_XHaN))
      call AKGwaz
     M    (W (1, VMIW_W2),
     I     C,    X (1, KXR), WW,
     I     MH,   LH,  ipKW, 4, ipCG (1, CGB_XHaN))
CC       Todo: odd
CCC_   + [B1:b, B2:c] = [D:b, D:c] [B1:b, B2:c] = D <grad_xy> H
      call UV1uma (W,   QM, MH, LH,  VMIW_W1, VMQ_Db)
      call UV1uma (W,   QM, MH, LH,  VMIW_W2, VMQ_Dc)
CCC_   + [B3:b, B4:c] = <L a:bc> H:a (clone group)
      call AKGwaz
     M    (W (1, VMIW_W3),
     I     C,    X (1, KXR), WW,
     I     MH,   LH,   ipKW, 1, ipCG (1, CGB_XHaN))
      call AKGwaz
     M    (W (1, VMIW_W4),
     I     C,    X (1, KXR), WW,
     I     MH,   LH,   ipKW, 2, ipCG (1, CGB_XHaN))
CC       Todo: odd
CCC_   + [B3:b, B4:c] = [E:b, E:c] [B3:b, B4:c] = E <L> H
      call UV1uma (W,   QM, MH, LH,  VMIW_W3, VMQ_Eb)
      call UV1uma (W,   QM, MH, LH,  VMIW_W4, VMQ_Ec)
CCC_   + [B1:b, B2:c] = [B1:b, B2:c] + [B3:b, B4:c] = D <grad_xy> H + E <L> H
      call UV0uaa (W,   MH, LH,  VMIW_W1, VMIW_W3)
      call UV0uaa (W,   MH, LH,  VMIW_W2, VMIW_W4)
CCC_   + [B3:a, B4:a]  = [<div_x> <div_y>] [B1:b, B2:c]
      call AKBwax
     O    (W,    C,
     I     WW,
     I     MH,   LH,  VMIW_W3, VMIW_W1,
     I     ipKW, iMA, KWO_DXba, KSW)
      call AKBwax
     O    (W,    C,
     I     WW,
     I     MH,   LH,  VMIW_W4, VMIW_W2,
     I     ipKW, iMA, KWO_DYca, KSW)
CCC_   + X[L]:a   = B3:a + B4:a
      call UV2naa (X, W,  MH, LH, KXL, VMIW_W3, VMIW_W4)
CCC_   + X[L]:a   = X[L]:a * Mask
      call UV1uma (X,   QM, MH, LH,  KXL, VMQ_MSK)
CCC_   + X[L]:a   = X[L]:a + f0 * X[R]:a
      call UV0ufa (X, MH, LH,  KXL, KXR,   F0)
      RETURN
      END
CCC_ & MMDmts  ## Movement/matrix multiplication suite (transpose)
      subroutine MMDmts
     M    (X,
     I     KXL,  KXR,
     W     C,    W,
     I     F0,   QM,   WW,
     I     iMA,  ipKW, ipCG, MH, LH, LCG)
CCC_  * Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH, KXR, KXL
      _INTENT(IN,   integer)  LCG
      _INTENT(INOUT,_REALSTD) X (LH, *)
      _INTENT(OUT,  _REALSTD) C (*)
      _INTENT(OUT,  _REALSTD) W (LH, *)
      _INTENT(IN,   _REALSTD) QM (*), F0
      _INTENT(IN,   _REALSTD) WW (*)
      _INTENT(IN,   integer)  iMA (*), ipKW (*)
      _INTENT(IN,   integer)  ipCG (LCG, *)
      integer KSW
CCC_  * Body
      KSW = KWM_T
CCC_   + X[L]:a = QM * X[R]:a
      call UV1nma (X,   QM, MH, LH,  KXL, KXR, VMQ_MSK)
CCC_   + clone group
      call AKCgux
     O    (C,
     I     X,    MH,   LH,  KXL,
     I     iMA,  ipCG (1, CGB_XHaT))
CCC_   + [B1:b, B2:c] = <div_x b:a, div_y c:a>T Z:a = <div_x y>T (QM H:a)
      call AKGwaz
     M    (W (1, VMIW_W1),
     I     C,    X (1, KXL), WW,
     I     MH,   LH,   ipKW, 1, ipCG (1, CGB_XHaT))
      call AKGwaz
     M    (W (1, VMIW_W2),
     I     C,    X (1, KXL), WW,
     I     MH,   LH,   ipKW, 2, ipCG (1, CGB_XHaT))
CCC_   + [B3:b, B4:c] = [D:b, D:c] [B1:b, B2:c] = D <div_x y>T QM H
      call UV1nma (W,   QM, MH, LH,  VMIW_W3, VMIW_W1, VMQ_Db)
      call UV1nma (W,   QM, MH, LH,  VMIW_W4, VMIW_W2, VMQ_Dc)
CCC_   + [B1:b, B2:c] = [E:b, E:c] [B1:b, B2:c] = E <div_x y>T QM H
      call UV1uma (W,   QM, MH, LH,  VMIW_W1, VMQ_Eb)
      call UV1uma (W,   QM, MH, LH,  VMIW_W2, VMQ_Ec)
CCC_   + [B5:a, B6:a] = <grad_x a:b a:c>T [B3:b, B4:c] = <grad>T D <div>T QM H
      call AKBwax
     O    (W,    C,
     I     WW,
     I     MH,   LH,  VMIW_W5, VMIW_W3,
     I     ipKW, iMA, KWO_GXab, KSW)
      call AKBwax
     O    (W,    C,
     I     WW,
     I     MH,   LH,  VMIW_W6, VMIW_W4,
     I     ipKW, iMA, KWO_GYac, KSW)
CCC_   + [B3:a, B4:a] = <L a:b a:c>T [B1:b, B2:c] = <L>T E <div>T QM H
      call AKBwax
     O    (W,    C,
     I     WW,
     I     MH,   LH,  VMIW_W3, VMIW_W1,
     I     ipKW, iMA, KWO_Lab,  KSW)
      call AKBwax
     O    (W,    C,
     I     WW,
     I     MH,   LH,  VMIW_W4, VMIW_W2,
     I     ipKW, iMA, KWO_Lac,  KSW)
CCC_   + [B1:a, B2:a] = [B3:a, B4:a] + [B5:a + B6:a]
      call UV0naa (W,   MH, LH,  VMIW_W1, VMIW_W3, VMIW_W5)
      call UV0naa (W,   MH, LH,  VMIW_W2, VMIW_W4, VMIW_W6)
CCC_   + X[L]:a = (B1:a + B2:a)
      call UV2naa (X, W,  MH, LH, KXL, VMIW_W1, VMIW_W2)
CCC_   + X[L]:a = X[L]:a + f0 * X[R]:a
      call UV0ufa (X, MH, LH,  KXL, KXR,   F0)
      RETURN
      END
CCC_ & MMDsns  ## Movement/matrix solver
      subroutine MMDsns
     M    (X,
     I     KXL,  KXR,
     W     C,    W,
     I     F0,   QM,   WW,
     I     iMA,  ipKW, ipCG, MH, LH, LCG)
CCC_  * Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH, KXR, KXL
      _INTENT(IN,   integer)  LCG
      _INTENT(INOUT,_REALSTD) X (*)
      _INTENT(OUT,  _REALSTD) C (*)
      _INTENT(OUT,  _REALSTD) W (*)
      _INTENT(IN,   _REALSTD) QM (*), F0
      _INTENT(IN,   _REALSTD) WW (*)
      _INTENT(IN,   integer)  iMA (*), ipKW (*)
      _INTENT(IN,   integer)  ipCG (*)
CCC_  * Body
      call UV1nda (X, QM, MH, LH, KXL, KXR, VMQ_DIAG)
      RETURN
      END
CCC_ & MMDsts  ## Movement/matrix solver (transpose)
      subroutine MMDsts
     M    (X,
     I     KXL,  KXR,
     W     C,    W,
     I     F0,   QM,   WW,
     I     iMA,  ipKW, ipCG, MH, LH, LCG)
CCC_  * Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH, KXR, KXL
      _INTENT(IN,   integer)  LCG
      _INTENT(INOUT,_REALSTD) X (*)
      _INTENT(OUT,  _REALSTD) C (*)
      _INTENT(OUT,  _REALSTD) W (*)
      _INTENT(IN,   _REALSTD) QM (*), F0
      _INTENT(IN,   _REALSTD) WW (*)
      _INTENT(IN,   integer)  iMA (*), ipKW (*)
      _INTENT(IN,   integer)  ipCG (*)
CCC_  * Body
      call UV1nda (X, QM, MH, LH, KXL, KXR, VMQ_DIAG)
      RETURN
      END
CCC_ & MMDgen  ## Movement/matrix generator
      subroutine MMDgen
     O    (iErr,
     O     X,    QM,   F0,
     W     VW,   CW,
     I     VMI,  VMC,  VMHB, VMID, DT,   WF,
     I     WW,
     I     ipKW, iMA,  MH,   LH,   MTYP)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,integer)  iErr
      _INTENT(IN, integer)  MH, LH
c
      _INTENT(OUT,_REALSTD) X    (LH, *)
      _INTENT(OUT,_REALSTD) QM   (LH, *)
      _INTENT(OUT,_REALSTD) F0
c
      _INTENT(OUT,_REALSTD) VW   (LH, *)
      _INTENT(OUT,_REALSTD) CW   (LH, *)
c
      _INTENT(IN, _REALSTD) VMI  (LH, *)
      _INTENT(IN, _REALSTD) VMHB (LH, *)
      _INTENT(IN, _REALSTD) VMC  (LH, *)
      _INTENT(IN, _REALSTD) VMID (LH, *)
c
      _INTENT(IN, _REALSTD) DT, WF
      _INTENT(IN, _REALSTD) WW (*)
      _INTENT(IN, integer)  ipKW (*)
      _INTENT(IN, integer)  iMA  (*)
      _INTENT(IN, integer)  MTYP
      integer kp
CCC_  * Body
      iErr = 0
c
CC    H/dt + D Q = M + Ho/dt
CC    Q = D (dH + dr) + E H
CC    H/dt + d (D dH + EH) = M + Ho/dt - d (D dr)
CCC_   + M: Mask matrix
      if (iErr.eq.0) then
         call UV1cpa (QM, VMI, MH, LH, VMQ_MSK, VMI_CLa)
      endif
CCC_   + D: Diagnal vector
      if (iErr.eq.0) then
         call UV0sta (QM,  MH, LH, VMQ_DIAG, 1.0d0)
      endif
CCC_   + F0: H new coeff
      F0 = 1.0d0 / DT
CCC_   + D[bc];E[bc]:  Diffusion and Adevection terms
      if (iErr.eq.0) then
         if      (MTYP.eq.MMXSW_DVB) then
            call UV1cpa (QM, VMID, MH, LH, VMQ_Db, VMID_Db)
            call UV1cpa (QM, VMID, MH, LH, VMQ_Dc, VMID_Dc)
            call UV1cpa (QM, VMID, MH, LH, VMQ_Eb, VMID_UBb)
            call UV1cpa (QM, VMID, MH, LH, VMQ_Ec, VMID_VBc)
         else if (MTYP.eq.MMXSW_D00) then
#if OPT_MMXOMS_D00
            call UV1cpa (QM, VMID, MH, LH, VMQ_Db, VMID_Db)
            call UV1cpa (QM, VMID, MH, LH, VMQ_Dc, VMID_Dc)
            call UV0sta (QM,  MH, LH, VMQ_Eb, 0.0d0)
            call UV0sta (QM,  MH, LH, VMQ_Ec, 0.0d0)
#else
            iErr = -999
            call DAtrcU (-1, iErr, 'D00', 'MMXGEN')
#endif
         else if (MTYP.eq.MMXSW_ZEV) then
            call UV0sta (QM,  MH, LH, VMQ_Db, 0.0d0)
            call UV0sta (QM,  MH, LH, VMQ_Dc, 0.0d0)
            call UV2naa (QM, VMID, MH, LH, VMQ_Eb, VMID_UIavb,VMID_UBb)
            call UV2naa (QM, VMID, MH, LH, VMQ_Ec, VMID_VIavc,VMID_VBc)
         else if (MTYP.eq.MMXSW_DE)  then
            call UV1cpa (QM, VMID, MH, LH, VMQ_Db, VMID_Db)
            call UV1cpa (QM, VMID, MH, LH, VMQ_Dc, VMID_Dc)
            call UV1cpa (QM, VMID, MH, LH, VMQ_Eb, VMID_UIavb)
            call UV1cpa (QM, VMID, MH, LH, VMQ_Ec, VMID_VIavc)
         else
            iErr = -1
         endif
      endif
CCC_   + B: Right-hand vector
      if (iErr.eq.0) then
CCC_    * D grad r/b (new/old mixed)
         call UV3nma
     $        (VW, QM, VMC, MH, LH, VMIW_W1, VMQ_Db, VMC_BXbM)
         call UV3nma
     $        (VW, QM, VMC, MH, LH, VMIW_W2, VMQ_Dc, VMC_BYcM)
CCC_    * div (D grad r) new
         call AKBwax
     O       (VW,   CW,
     I        WW,
     I        MH,   LH,  VMIW_W3, VMIW_W1,
     I        ipKW, iMA, KWO_DXba, KWM_M)
CC       Todo: odd
         call AKBwax
     O       (VW,   CW,
     I        WW,
     I        MH,   LH,  VMIW_W4, VMIW_W2,
     I        ipKW, iMA, KWO_DYca, KWM_M)
CC       Todo: odd
CCC_    * B1 = B3 + B4
         call UV0naa (VW,  MH, LH, VMIW_W1, VMIW_W3, VMIW_W4)
CCC_    * done
CC     not VMI_Ha but VMC_HCa
         do kp = 1, MH
            QM (kp, VMQ_BB) =
     $           QM  (kp, VMQ_MSK)
     $           * (VMHB (kp, VMHB_TMBa) - VW (kp, VMIW_W1))
         enddo
         do kp = 1, MH
            X (kp, BCGW_BB) =
     $           QM  (kp, VMQ_BB) + VMC (kp, VMC_HCa) * F0
         enddo
c$$$         do kp = 1, MH
c$$$            X (kp, BCGW_BB) =
c$$$     $           QM  (kp, VMQ_MSK)
c$$$     $             * (VMHB (kp, VMHB_TMBa) - VW (kp, VMIW_W1))
c$$$     $           + VMC (kp, VMC_HCa) / DT
c$$$         enddo
      endif
      RETURN
      END
CCC_ & MMDcgs  ## Movement/matrix clone group declaration
      subroutine MMDcgs
     O    (iErr,
     O     ipCG,
     W     kDTA,
     I     LTBL, LCG, LH, LCK, ipKW, IE, IFP)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,  integer) iErr
      _INTENT(IN,   integer) LCG, LH, LTBL, LCK
      _INTENT(INOUT,integer) ipCG (LCG, *)
      _INTENT(IN,   integer) ipKW (*), IE (*), IFP
      _INTENT(OUT,  integer) kDTA (LTBL, 3)
c
      integer kv
      integer ko
CCC_  * Body
      iErr = 0
c
      if (iErr.eq.0) then
         call MIBcgr
     O       (iErr,
     O        ipCG,
     W        kDTA,
     I        LTBL, LCG, LH, LCK, ipKW, IE, IFP)
      endif
CCC_   + group normal
      if (iErr.eq.0) then
         kv   = CGB_XHaN
c     ko 0 for one-time cloning
         ko   = 1
         call AKCgro (iErr, ipCG (1, kv), LCG, ko)
         call AKCgad (iErr, ipCG (1, kv), KWO_Lab,  KWM_M, LCG)
         call AKCgad (iErr, ipCG (1, kv), KWO_Lac,  KWM_M, LCG)
         call AKCgad (iErr, ipCG (1, kv), KWO_GXab, KWM_M, LCG)
         call AKCgad (iErr, ipCG (1, kv), KWO_GYac, KWM_M, LCG)
         call AKCgso
     O       (iErr, ko,   ipCG (1, kv), KDTA,
     I        LCG,  LTBL, LH,           ipKW, IE, IFP)
      endif
CCC_   + group transpose
      if (iErr.eq.0) then
         kv   = CGB_XHaT
c     ko 0 for one-time cloning
         ko   = 1
         call AKCgro (iErr, ipCG (1, kv), LCG, ko)
         call AKCgad (iErr, ipCG (1, kv), KWO_DXba, KWM_T, LCG)
         call AKCgad (iErr, ipCG (1, kv), KWO_DYca, KWM_T, LCG)
         call AKCgso
     O       (iErr, ko,   ipCG (1, kv), KDTA,
     I        LCG,  LTBL, LH,           ipKW, IE, IFP)
      endif
CCC_   + report
      call DAtrcU (IFP, iErr, 'R', 'MMXCGS')
      RETURN
      END
CCC_ & MMDdec  ## Movement/matrix operators kiwi declaration
      subroutine MMDdec
     O    (iErr,
     M     ipKW,
     I     IFP)
      implicit none
      _INTENT(OUT,  integer) iErr
      _INTENT(INOUT,integer) ipKW (*)
      _INTENT(IN,   integer) IFP
      iErr = 0
c
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_Lab,  KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_Lac,  KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_GXab, KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_GYac, KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_DXba, KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_DYca, KWM_BOTH, IFP)
c
      RETURN
      END
CCC_* [MMZ] Upwind type matrix (grad div decomposition)
CCC_ + Description
CC
CC     M = Mask [  u:a <Wp:ab Wm:ab> Grad:ba + DivU
CC               + v:a <Wp:ac Wm:ac> Grad:ca + DivV ]
CC       + F0
CC
CC     T = [  Grad:ba <Wp:ab Wm:ab> u:a + DivU
CC          + Grad:ca <Wp:ac Wm:ac> v:a + DivV] Mask
CC       + F0
CC
CCC_ & MMZmns  ## Movement/matrix multiplication suite (grad div upwind)
      subroutine MMZmns
     M    (X,
     I     KXL,  KXR,
     W     C,    W,
     I     F0,   QM,   WW,
     I     iMA,  ipKW, ipCG, MH, LH, LCG)
CCC_  * Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH, KXR, KXL
      _INTENT(IN,   integer)  LCG
      _INTENT(INOUT,_REALSTD) X    (LH,  *)
      _INTENT(OUT,  _REALSTD) C    (*)
      _INTENT(OUT,  _REALSTD) W    (LH,  *)
      _INTENT(IN,   _REALSTD) QM   (*),  F0
      _INTENT(IN,   _REALSTD) WW   (*)
      _INTENT(IN,   integer)  iMA  (*),  ipKW (*)
      _INTENT(IN,   integer)  ipCG (LCG, *)
      integer KSW
CCC_  * Body
      KSW = KWM_M
CCC_   . clone group
      call AKCgux
     O    (C,
     I     X,    MH,   LH,  KXR,
     I     iMA,  ipCG (1, CGB_XHaN))
CCC_   . [B1:b, B2:c] = <grad_xy a:bc> H:a (clone group)
      call AKGwaz
     M    (W (1, VMIW_W1),
     I     C,    X (1, KXR), WW,
     I     MH,   LH,  ipKW, 3, ipCG (1, CGB_XHaN))
      call AKGwaz
     M    (W (1, VMIW_W2),
     I     C,    X (1, KXR), WW,
     I     MH,   LH,  ipKW, 4, ipCG (1, CGB_XHaN))
CCC_   . [B3:a] = [Wp, Wm] B1
      call AKBuax
     O    (W,    C,
     I     QM,
     I     MH,   LH,  VMIW_W3,  VMIW_W1,  VMQZ_WXp, VMQZ_WXm,
     I     ipKW, iMA, KWO_Lba,  KSW)
CCC_   . [B4:a] = [Wp, Wm] B2
      call AKBuax
     O    (W,    C,
     I     QM,
     I     MH,   LH,  VMIW_W4,  VMIW_W2,  VMQZ_WYp, VMQZ_WYm,
     I     ipKW, iMA, KWO_Lca,  KSW)
CCC_   . [B3:a] = [integral ue] B3
      call UV1uma(W, QM, MH, LH, VMIW_W3, VMQZ_UEava)
CCC_   . [B4:a] = [integral ue] B3
      call UV1uma(W, QM, MH, LH, VMIW_W4, VMQZ_VEava)
CCC_   . X[L]:a   = B3:a + B4:a
      call UV2naa (X, W,  MH, LH, KXL, VMIW_W3, VMIW_W4)
CCC_   . [B1:a]   = Div(u+v) H
      call UV3nma (W, QM, X, MH, LH, VMIW_W1, VMQZ_DIV, KXR)
CCC_   . X[L]:a   = X[L]:a + Div(u+v) H
      call UV1uaa (X, W, MH, LH, KXL, VMIW_W1)
CCC_   + X[L]:a   = X[L]:a * Mask
      call UV1uma (X,   QM, MH, LH,  KXL, VMQZ_MSK)
CCC_   + X[L]:a   = X[L]:a + f0 * X[R]:a
      call UV0ufa (X, MH, LH,  KXL, KXR,   F0)
      RETURN
      END
CCC_ & MMZmts  ## Movement/matrix multiplication suite (transpose)
      subroutine MMZmts
     M    (X,
     I     KXL,  KXR,
     W     C,    W,
     I     F0,   QM,   WW,
     I     iMA,  ipKW, ipCG, MH, LH, LCG)
CCC_  * Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH, KXR, KXL
      _INTENT(IN,   integer)  LCG
      _INTENT(INOUT,_REALSTD) X (LH, *)
      _INTENT(OUT,  _REALSTD) C (LH, *)
      _INTENT(OUT,  _REALSTD) W (LH, *)
      _INTENT(IN,   _REALSTD) QM (*), F0
      _INTENT(IN,   _REALSTD) WW (*)
      _INTENT(IN,   integer)  iMA (*), ipKW (*)
      _INTENT(IN,   integer)  ipCG (LCG, *)
      integer KSW
CCC_  * Body
      KSW = KWM_T
CCC_   + B1 = QM * X[R]:a
      call UV3nma (W, QM, X, MH, LH, VMIW_W1, VMQZ_MSK, KXR)
CCC_   . B6 = u:a B1
      call UV1nma (W, QM, MH, LH, VMIW_W6, VMIW_W1, VMQZ_UEava)
CCC_   . B2 = <Wp:ab Wm:ab>T B6
      call AKBtax
     M    (W,    C,
     I     QM,
     I     MH,   LH,  VMIW_W2, VMIW_W6, VMQZ_WXp, VMQZ_WXm,
     I     VMIW_W4, VMIW_W5,
     I     ipKW, iMA, KWO_Lba, KSW)
CCC_   . B6 = v:a B1
      call UV1nma (W, QM, MH, LH, VMIW_W6, VMIW_W1, VMQZ_VEava)
CCC_   + B3 = <Vp:ac Vm:ac>T B6
      call AKBtax
     M    (W,    C,
     I     QM,
     I     MH,   LH,  VMIW_W3, VMIW_W6, VMQZ_WYp, VMQZ_WYm,
     I     VMIW_W4, VMIW_W5,
     I     ipKW, iMA, KWO_Lca, KSW)
CCC_   + B4 = grad:ba T B2
      call AKBwax
     O    (W,    C (1,1),
     I     WW,
     I     MH,   LH,  VMIW_W4,  VMIW_W2,
     I     ipKW, iMA, KWO_GXab, KSW)
CCC_   + B5 = grad:ca T B3
      call AKBwax
     O    (W,    C (1,2),
     I     WW,
     I     MH,   LH,  VMIW_W5,  VMIW_W3,
     I     ipKW, iMA, KWO_GYac, KSW)
CCC_   + X[L]:a = (B4:a + B5:a)
      call UV2naa (X, W,  MH, LH, KXL, VMIW_W4, VMIW_W5)
CCC_   . B1:a = B1 (Mask X) * DIVu
      call UV1uma (W, QM, MH, LH, VMIW_W1, VMQZ_DIV)
CCC_   . X[L]:a = X[L]: + B1:a
      call UV1uaa (X, W, MH, LH, KXL, VMIW_W1)
CCC_   + X[L]:a = X[L]:a + f0 * X[R]:a
      call UV0ufa (X, MH, LH,  KXL, KXR,   F0)
      RETURN
      END
CCC_ & MMZsns  ## Movement/matrix solver
      subroutine MMZsns
     M    (X,
     I     KXL,  KXR,
     W     C,    W,
     I     F0,   QM,   WW,
     I     iMA,  ipKW, ipCG, MH, LH, LCG)
CCC_  * Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH, KXR, KXL
      _INTENT(IN,   integer)  LCG
      _INTENT(INOUT,_REALSTD) X (*)
      _INTENT(OUT,  _REALSTD) C (*)
      _INTENT(OUT,  _REALSTD) W (*)
      _INTENT(IN,   _REALSTD) QM (*), F0
      _INTENT(IN,   _REALSTD) WW (*)
      _INTENT(IN,   integer)  iMA (*), ipKW (*)
      _INTENT(IN,   integer)  ipCG (*)
CCC_  * Body
      call UV1nda (X, QM, MH, LH, KXL, KXR, VMQZ_DIAG)
      RETURN
      END
CCC_ & MMZsts  ## Movement/matrix solver (transpose)
      subroutine MMZsts
     M    (X,
     I     KXL,  KXR,
     W     C,    W,
     I     F0,   QM,   WW,
     I     iMA,  ipKW, ipCG, MH, LH, LCG)
CCC_  * Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH, KXR, KXL
      _INTENT(IN,   integer)  LCG
      _INTENT(INOUT,_REALSTD) X (*)
      _INTENT(OUT,  _REALSTD) C (*)
      _INTENT(OUT,  _REALSTD) W (*)
      _INTENT(IN,   _REALSTD) QM (*), F0
      _INTENT(IN,   _REALSTD) WW (*)
      _INTENT(IN,   integer)  iMA (*), ipKW (*)
      _INTENT(IN,   integer)  ipCG (*)
CCC_  * Body
      call UV1nda (X, QM, MH, LH, KXL, KXR, VMQZ_DIAG)
      RETURN
      END
CCC_ & MMZgen  ## Movement/matrix generator
      subroutine MMZgen
     O    (iErr,
     O     X,    QM,   F0,
     W     VW,   CW,
     I     VMI,  VMC,  VMHB, VMID, DT,   WF,
     I     WW,
     I     ipKW, iMA,  MH,   LH,   MTYP)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,integer)  iErr
      _INTENT(IN, integer)  MH, LH
c
      _INTENT(OUT,_REALSTD) X    (LH, *)
      _INTENT(OUT,_REALSTD) QM   (LH, *)
      _INTENT(OUT,_REALSTD) F0
c
      _INTENT(OUT,_REALSTD) VW   (LH, *)
      _INTENT(OUT,_REALSTD) CW   (LH, *)
c
      _INTENT(IN, _REALSTD) VMI  (LH, *)
      _INTENT(IN, _REALSTD) VMHB (LH, *)
      _INTENT(IN, _REALSTD) VMC  (LH, *)
      _INTENT(IN, _REALSTD) VMID (LH, *)
c
      _INTENT(IN, _REALSTD) DT, WF
      _INTENT(IN, _REALSTD) WW (LH, *)
      _INTENT(IN, integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN, integer)  iMA  (*)
      _INTENT(IN, integer)  MTYP
      integer jp
      _REALSTD PUZ
      integer jlo, jla
CCC_  * Body
      iErr = 0
c
      PUZ  = 0.0d0
C      PUZ  = 1.0d0
CC    H/dt + div Q = M + Ho/dt
CC    Q = [ub + E] H
CC    if ub+E==0:  H/dt + (ub+E) grad H + H div (ub+E) = M + Ho/dt
CCC_   + M: Mask matrix
      if (iErr.eq.0) then
         call UV1cpa (QM, VMI, MH, LH, VMQZ_MSK, VMI_CLa)
      endif
CCC_   + D: Diagnal vector
      if (iErr.eq.0) then
         call UV0sta (QM,  MH, LH, VMQZ_DIAG, 1.0d0)
      endif
CCC_   + F0: H new coeff
      F0 = 1.0d0 / DT
CCC_   + D[bc];E[bc]:  Diffusion and Adevection terms
      if (iErr.eq.0) then
         if      (MTYP.eq. MMXSW_UPD) then
CCC_    * w1: ue:b
            call UV2naa (VW, VMID, MH,LH, VMIW_W1, VMID_UBb,VMID_UIavb)
CC todo: clone group
CCC_    * up: ue:a
            call AKBwaz
     O          (QM (1, VMQZ_UEava), CW,
     I           VW (1, VMIW_W1),    WW,
     I           MH,   LH,  ipKW,    iMA, KWO_Lba, KWM_M)
CCC_    * w2: div:ba ue
            call AKBwax
     O          (VW,   CW,
     I           WW,
     I           MH,   LH,  VMIW_W2, VMIW_W1,
     I           ipKW, iMA, KWO_DXba, KWM_M)
CC          odd field mask
            call AKBomx
     M          (QM,  CW,
     I           WW,
     I           MH,   LH,  VMQZ_UEava, VMQZ_UEava,
     I           ipKW, iMA, KWO_ZXb)
CC       Todo: odd for div ba
CCC_    * w1: ve:b
            call UV2naa (VW, VMID, MH,LH, VMIW_W1, VMID_VBc,VMID_VIavc)
CCC_    * vp: ve:a
            call AKBwaz
     O          (QM (1, VMQZ_VEava), CW,
     I           VW (1, VMIW_W1),    WW,
     I           MH,   LH,  ipKW,    iMA, KWO_Lca, KWM_M)
CCC_    * w3: div:ca ve
            call AKBwax
     O          (VW,   CW,
     I           WW,
     I           MH,   LH,  VMIW_W3,  VMIW_W1,
     I           ipKW, iMA, KWO_DYca, KWM_M)
CC          odd field mask
            call AKBomx
     M          (QM,  CW,
     I           WW,
     I           MH,   LH,  VMQZ_VEava, VMQZ_VEava,
     I           ipKW, iMA, KWO_ZYc)
CC       Todo: odd for div ca
CC          odd field mask if zero
CCC_    * um
            jlo = ipKW (KWI_KWO, KWO_Lba, KWM_M)
            jla = ipKW (KWI_KWA, KWO_Lba, KWM_M)
            do jp = 1, MH
               if      (QM (jp, VMQZ_UEava).gt.+PUZ) then
                  QM (jp, VMQZ_WXm) = 1.0d0
                  QM (jp, VMQZ_WXp) = 0.0d0
               else if (QM (jp, VMQZ_UEava).lt.-PUZ) then
                  QM (jp, VMQZ_WXm) = 0.0d0
                  QM (jp, VMQZ_WXp) = 1.0d0
               else
                  QM (jp, VMQZ_WXp) = 0.0d0
                  QM (jp, VMQZ_WXm) = 0.0d0
               endif
            enddo
CCC_    * vm
            jlo = ipKW (KWI_KWO, KWO_Lca, KWM_M)
            jla = ipKW (KWI_KWA, KWO_Lca, KWM_M)
            do jp = 1, MH
               if      (QM (jp, VMQZ_VEava).gt.+PUZ) then
                  QM (jp, VMQZ_WYm) = 1.0d0
                  QM (jp, VMQZ_WYp) = 0.0d0
               else if (QM (jp, VMQZ_VEava).lt.-PUZ) then
                  QM (jp, VMQZ_WYm) = 0.0d0
                  QM (jp, VMQZ_WYp) = 1.0d0
               else
                  QM (jp, VMQZ_WYp) = 0.0d0
                  QM (jp, VMQZ_WYm) = 0.0d0
               endif
            enddo
CCC_    * div: w2+w3
            call UV2naa (QM, VW,  MH, LH, VMQZ_DIV, VMIW_W2, VMIW_W3)
         else
            iErr = -1
         endif
      endif
CCC_   + B: Right-hand vector
      if (iErr.eq.0) then
CC     not VMI_Ha but VMC_HCa
         do jp = 1, MH
            QM (jp, VMQZ_BB) =
     $           QM  (jp, VMQZ_MSK) * VMHB (jp, VMHB_TMBa)
         enddo
         do jp = 1, MH
            X (jp, BCGW_BB) =
     $           QM  (jp, VMQZ_BB) + VMC (jp, VMC_HCa) * F0
         enddo
c$$$         do jp = 1, MH
c$$$     $           QM  (jp, VMQ_MSK) * VMHB (jp, VMHB_TMBa)
c$$$     $           + VMC (jp, VMC_HCa) / DT
c$$$         enddo
      endif
      RETURN
      END
CCC_ & MMZdec  ## Movement/matrix operators kiwi declaration
      subroutine MMZdec
     O    (iErr,
     M     ipKW,
     I     IFP)
      implicit none
      _INTENT(OUT,  integer) iErr
      _INTENT(INOUT,integer) ipKW (*)
      _INTENT(IN,   integer) IFP
      iErr = 0
c
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_Lba,  KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_Lca,  KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_DXab, KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_DYac, KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_GXab, KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_GYac, KWM_BOTH, IFP)
c
      RETURN
      END
CCC_ & MMZcgs  ## Movement/matrix clone group declaration
      subroutine MMZcgs
     O    (iErr,
     O     ipCG,
     W     kDTA,
     I     LTBL, LCG, LH, LCK, ipKW, IE, IFP)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,  integer) iErr
      _INTENT(IN,   integer) LCG, LH, LTBL, LCK
      _INTENT(INOUT,integer) ipCG (LCG, *)
      _INTENT(IN,   integer) ipKW (*), IE (*), IFP
      _INTENT(OUT,  integer) kDTA (LTBL, 3)
c
      integer kv
CCC_  * Body
      iErr = 0
c
      if (iErr.eq.0) then
         call MIBcgr
     O       (iErr,
     O        ipCG,
     W        kDTA,
     I        LTBL, LCG, LH, LCK, ipKW, IE, IFP)
      endif
CCC_   + group normal (none)
CCC_   + group transpose
      if (iErr.eq.0) then
         kv   = CGB_UHaT
         call AKCgrs (iErr, ipCG (1, kv), LCG)
         call AKCgad (iErr, ipCG (1, kv), KWO_Lba, KWM_T, LCG)
         call AKCgad (iErr, ipCG (1, kv), KWO_Lca, KWM_T, LCG)
         call AKCgsb
     O       (iErr, ipCG (1, kv),  KDTA,
     I        LCG,  LTBL,  LH,   ipKW, IE,   IFP)
      endif
CCC_   + report
      call DAtrcU (IFP, iErr, 'R', 'MMZCGS')
      RETURN
      END
CCC_* [MMY] Upwind type matrix (grad div decomposition + ZEV)
CCC_ + Description
CC
CC     M = Mask [  u:a <Wp:ab Wm:ab> Grad:ba + DivU
CC               + v:a <Wp:ac Wm:ac> Grad:ca + DivV ]
CC         + Mask [MEX Div:ab [E:b L:ba] + MEY Div:ac [E:c L:ca]]
CC       + F0
CC
CC     T = [  Grad:ba <Wp:ab Wm:ab> u:a + DivU
CC          + Grad:ca <Wp:ac Wm:ac> v:a + DivV] Mask
CC         + [[L:ba E:b] Div:ab MEX + [L:ca E:c] Div:ac MEY] Mask
CC       + F0
CC
CCC_ & MMYmns  ## Movement/matrix multiplication suite (grad div upwind)
      subroutine MMYmns
     M    (X,
     I     KXL,  KXR,
     W     C,    W,
     I     F0,   QM,   WW,
     I     iMA,  ipKW, ipCG, MH, LH, LCG)
CCC_  * Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH, KXR, KXL
      _INTENT(IN,   integer)  LCG
      _INTENT(INOUT,_REALSTD) X    (LH,  *)
      _INTENT(OUT,  _REALSTD) C    (LH,  *)
      _INTENT(OUT,  _REALSTD) W    (LH,  *)
      _INTENT(IN,   _REALSTD) QM   (LH,  *),  F0
      _INTENT(IN,   _REALSTD) WW   (*)
      _INTENT(IN,   integer)  iMA  (*),  ipKW (*)
      _INTENT(IN,   integer)  ipCG (LCG, *)
      integer KSW
      integer jp
CCC_  * Body
      KSW = KWM_M
CCC_   . clone group
      call AKCgux
     O    (C,
     I     X,    MH,   LH,  KXR,
     I     iMA,  ipCG (1, CGB_XHaN))
CCC_   . [B1:b, B2:c] = <grad_xy a:bc> H:a (clone group)
      call AKGwaz
     M    (W (1, VMIW_W1),
     I     C,    X (1, KXR), WW,
     I     MH,   LH,  ipKW, 3, ipCG (1, CGB_XHaN))
      call AKGwaz
     M    (W (1, VMIW_W2),
     I     C,    X (1, KXR), WW,
     I     MH,   LH,  ipKW, 4, ipCG (1, CGB_XHaN))
CCC_   . [B3:a] = [Wp, Wm] B1  (one-time clone)
      call AKBuax
     O    (W,    C,
     I     QM,
     I     MH,   LH,  VMIW_W3,  VMIW_W1,  VMQH_WXp, VMQH_WXm,
     I     ipKW, iMA, KWO_Lba,  KSW)
CCC_   . [B4:a] = [Wp, Wm] B2  (one-time clone)
      call AKBuax
     O    (W,    C,
     I     QM,
     I     MH,   LH,  VMIW_W4,  VMIW_W2,  VMQH_WYp, VMQH_WYm,
     I     ipKW, iMA, KWO_Lca,  KSW)
CCC_   . [B3:a] = [integral ue] B3
      call UV1uma(W, QM, MH, LH, VMIW_W3, VMQH_UEava)
CCC_   . [B4:a] = [integral ue] B3
      call UV1uma(W, QM, MH, LH, VMIW_W4, VMQH_VEava)
CCC_   . X[L]:a   = B3:a + B4:a
      call UV2naa (X, W,  MH, LH, KXL, VMIW_W3, VMIW_W4)
CCC_   . [B1:a]   = Div(u+v) H
      call UV3nma (W, QM, X, MH, LH, VMIW_W1, VMQH_CDIV, KXR)
CCC_   . X[L]:a   = X[L]:a + Div(u+v) H
      call UV1uaa (X, W, MH, LH, KXL, VMIW_W1)
CCC_   . E terms
CCC_    * [B3:b, B4:c] = <L a:bc> H:a (clone group)
      call AKGwaz
     M    (W (1, VMIW_W3),
     I     C,    X (1, KXR), WW,
     I     MH,   LH,   ipKW, 1, ipCG (1, CGB_XHaN))
      call AKGwaz
     M    (W (1, VMIW_W4),
     I     C,    X (1, KXR), WW,
     I     MH,   LH,   ipKW, 2, ipCG (1, CGB_XHaN))
CCC_    * [B3:b, B4:c] = [E:b, E:c] [B3:b, B4:c] = E <L> H
      call UV1uma (W,   QM, MH, LH,  VMIW_W3, VMQH_CEb)
      call UV1uma (W,   QM, MH, LH,  VMIW_W4, VMQH_CEc)
CCC_    * [B1:a, B2:a]  = [<div_x> <div_y>] [B3:b, B4:c]
      call AKBwax
     O    (W,    C,
     I     WW,
     I     MH,   LH,  VMIW_W1, VMIW_W3,
     I     ipKW, iMA, KWO_DXba, KSW)
      call AKBwax
     O    (W,    C,
     I     WW,
     I     MH,   LH,  VMIW_W2, VMIW_W4,
     I     ipKW, iMA, KWO_DYca, KSW)
CCC_    * E masks
      do jp = 1, MH
         W(jp, VMIW_W1) = W(jp, VMIW_W1)
     $        * (1.0d0 - (QM(jp, VMQH_WXp) + QM(jp, VMQH_WXm)))
         W(jp, VMIW_W2) = W(jp, VMIW_W2)
     $        * (1.0d0 - (QM(jp, VMQH_WYp) + QM(jp, VMQH_WYm)))
      enddo
      call UV0naa (W,  MH, LH, VMIW_W3, VMIW_W1, VMIW_W2)
CCC_   . X[L]:a   = X[L]:a + Div EH
      call UV1uaa (X, W, MH, LH, KXL, VMIW_W3)
CCC_   . X[L]:a   = X[L]:a * Mask
      call UV1uma (X,   QM, MH, LH,  KXL, VMQH_MSK)
CCC_   + X[L]:a   = X[L]:a + f0 * X[R]:a
      call UV0ufa (X, MH, LH,  KXL, KXR,   F0)
      RETURN
      END
CCC_ & MMYmts  ## Movement/matrix multiplication suite (transpose)
      subroutine MMYmts
     M    (X,
     I     KXL,  KXR,
     W     C,    W,
     I     F0,   QM,   WW,
     I     iMA,  ipKW, ipCG, MH, LH, LCG)
CCC_  * Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH, KXR, KXL
      _INTENT(IN,   integer)  LCG
      _INTENT(INOUT,_REALSTD) X (LH, *)
      _INTENT(OUT,  _REALSTD) C (LH, *)
      _INTENT(OUT,  _REALSTD) W (LH, *)
      _INTENT(IN,   _REALSTD) QM (LH, *), F0
      _INTENT(IN,   _REALSTD) WW (*)
      _INTENT(IN,   integer)  iMA (*), ipKW (*)
      _INTENT(IN,   integer)  ipCG (LCG, *)
      integer KSW
      integer jp
CCC_  * Body
      KSW = KWM_T
CCC_   + B1 = QM * X[R]:a
      call UV3nma (W, QM, X, MH, LH, VMIW_W1, VMQH_MSK, KXR)
CCC_   . B6 = u:a B1
      call UV1nma (W, QM, MH, LH, VMIW_W6, VMIW_W1, VMQH_UEava)
CCC_   . B2 = <Wp:ab Wm:ab>T B6
      call AKBtax
     M    (W,    C,
     I     QM,
     I     MH,   LH,  VMIW_W2, VMIW_W6, VMQH_WXp, VMQH_WXm,
     I     VMIW_W4, VMIW_W5,
     I     ipKW, iMA, KWO_Lba, KSW)
CCC_   . B6 = v:a B1
      call UV1nma (W, QM, MH, LH, VMIW_W6, VMIW_W1, VMQH_VEava)
CCC_   + B3 = <Vp:ac Vm:ac>T B6
      call AKBtax
     M    (W,    C,
     I     QM,
     I     MH,   LH,  VMIW_W3, VMIW_W6, VMQH_WYp, VMQH_WYm,
     I     VMIW_W4, VMIW_W5,
     I     ipKW, iMA, KWO_Lca, KSW)
CCC_   + B4 = grad:ba T B2
      call AKBwax
     O    (W,    C (1,1),
     I     WW,
     I     MH,   LH,  VMIW_W4,  VMIW_W2,
     I     ipKW, iMA, KWO_GXab, KSW)
CCC_   + B5 = grad:ca T B3
      call AKBwax
     O    (W,    C (1,2),
     I     WW,
     I     MH,   LH,  VMIW_W5,  VMIW_W3,
     I     ipKW, iMA, KWO_GYac, KSW)
CCC_   + X[L]:a = (B4:a + B5:a)
      call UV2naa (X, W,  MH, LH, KXL, VMIW_W4, VMIW_W5)
CCC_   . B2:a = B1 (Mask X) * DIVu
      call UV1nma (W, QM, MH, LH, VMIW_W2, VMIW_W1, VMQH_CDIV)
CCC_   . X[L]:a = X[L]: + B2:a
      call UV1uaa (X, W, MH, LH, KXL, VMIW_W2)
CCC_   . E terms
      do jp = 1, MH
         W(jp, VMIW_W4) = W(jp, VMIW_W1)
     $        * (1.0d0 - (QM(jp, VMQH_WXp) + QM(jp, VMQH_WXm)))
         W(jp, VMIW_W5) = W(jp, VMIW_W1)
     $        * (1.0d0 - (QM(jp, VMQH_WYp) + QM(jp, VMQH_WYm)))
      enddo
CCC_    * [B2:b, B3:c] = <div_x b:a, div_y c:a>T Z:a = <div_x y>T (QM H:a)
      call AKBwax
     O    (W,    C,
     I     WW,
     I     MH,   LH,  VMIW_W2, VMIW_W4,
     I     ipKW, iMA, KWO_DXba,  KSW)
      call AKBwax
     O    (W,    C,
     I     WW,
     I     MH,   LH,  VMIW_W3, VMIW_W5,
     I     ipKW, iMA, KWO_DYca,  KSW)
CCC_    * [B2:b, B3:c] = [E:b, E:c] [B2:b, B3:c] = E <div_x y>T QM H
      call UV1uma (W,   QM, MH, LH,  VMIW_W2, VMQH_CEb)
      call UV1uma (W,   QM, MH, LH,  VMIW_W3, VMQH_CEc)
CCC_   . [B4:a, B5:a] = <L a:b a:c>T [B2:b, B3:c] = <L>T E <div>T QM H
      call AKBwax
     O    (W,    C,
     I     WW,
     I     MH,   LH,  VMIW_W4, VMIW_W2,
     I     ipKW, iMA, KWO_Lab,  KSW)
      call AKBwax
     O    (W,    C,
     I     WW,
     I     MH,   LH,  VMIW_W5, VMIW_W3,
     I     ipKW, iMA, KWO_Lac,  KSW)
CCC_    * [B2:a] = [B4:a] + [B5:a]
      call UV0naa (W,   MH, LH,  VMIW_W2, VMIW_W4, VMIW_W5)
CCC_   . X[L]:a = X[L]: + B2:a
      call UV1uaa (X, W, MH, LH, KXL, VMIW_W2)
CCC_   . X[L]:a = X[L]:a + f0 * X[R]:a
      call UV0ufa (X, MH, LH,  KXL, KXR,   F0)
      RETURN
      END
CCC_ & MMYsns  ## Movement/matrix solver
      subroutine MMYsns
     M    (X,
     I     KXL,  KXR,
     W     C,    W,
     I     F0,   QM,   WW,
     I     iMA,  ipKW, ipCG, MH, LH, LCG)
CCC_  * Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH, KXR, KXL
      _INTENT(IN,   integer)  LCG
      _INTENT(INOUT,_REALSTD) X (*)
      _INTENT(OUT,  _REALSTD) C (*)
      _INTENT(OUT,  _REALSTD) W (*)
      _INTENT(IN,   _REALSTD) QM (*), F0
      _INTENT(IN,   _REALSTD) WW (*)
      _INTENT(IN,   integer)  iMA (*), ipKW (*)
      _INTENT(IN,   integer)  ipCG (*)
CCC_  * Body
      call UV1nda (X, QM, MH, LH, KXL, KXR, VMQH_DIAG)
      RETURN
      END
CCC_ & MMYsts  ## Movement/matrix solver (transpose)
      subroutine MMYsts
     M    (X,
     I     KXL,  KXR,
     W     C,    W,
     I     F0,   QM,   WW,
     I     iMA,  ipKW, ipCG, MH, LH, LCG)
CCC_  * Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH, KXR, KXL
      _INTENT(IN,   integer)  LCG
      _INTENT(INOUT,_REALSTD) X (*)
      _INTENT(OUT,  _REALSTD) C (*)
      _INTENT(OUT,  _REALSTD) W (*)
      _INTENT(IN,   _REALSTD) QM (*), F0
      _INTENT(IN,   _REALSTD) WW (*)
      _INTENT(IN,   integer)  iMA (*), ipKW (*)
      _INTENT(IN,   integer)  ipCG (*)
CCC_  * Body
      call UV1nda (X, QM, MH, LH, KXL, KXR, VMQH_DIAG)
      RETURN
      END
CCC_ & MMYgen  ## Movement/matrix generator (UPE. UPD+ZEV)
      subroutine MMYgen
     O    (iErr,
     O     X,    QM,   F0,
     W     VW,   CW,
     I     VMI,  VMC,  VMHB, VMID, DT,   WF,
     I     WW,
     I     ipKW, iMA,  MH,   LH,   MTYP)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,integer)  iErr
      _INTENT(IN, integer)  MH, LH
c
      _INTENT(OUT,_REALSTD) X    (LH, *)
      _INTENT(OUT,_REALSTD) QM   (LH, *)
      _INTENT(OUT,_REALSTD) F0
c
      _INTENT(OUT,_REALSTD) VW   (LH, *)
      _INTENT(OUT,_REALSTD) CW   (LH, *)
c
      _INTENT(IN, _REALSTD) VMI  (LH, *)
      _INTENT(IN, _REALSTD) VMHB (LH, *)
      _INTENT(IN, _REALSTD) VMC  (LH, *)
      _INTENT(IN, _REALSTD) VMID (LH, *)
c
      _INTENT(IN, _REALSTD) DT, WF
      _INTENT(IN, _REALSTD) WW (LH, *)
      _INTENT(IN, integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN, integer)  iMA  (*)
      _INTENT(IN, integer)  MTYP
      integer jp
      _REALSTD PUZ
CCC_  * Body
      iErr = 0
c
      PUZ  = 0.0d0
C      PUZ  = 1.0d0
CC    H/dt + div Q = M + Ho/dt
CC    Q = [ub + E] H
CC    if ub+E==0:  H/dt + (ub+E) grad H + H div (ub+E) = M + Ho/dt
CCC_   + M: Mask matrix
      if (iErr.eq.0) then
         call UV1cpa (QM, VMI, MH, LH, VMQH_MSK, VMI_CLa)
      endif
CCC_   + D: Diagnal vector
      if (iErr.eq.0) then
         call UV0sta (QM,  MH, LH, VMQH_DIAG, 1.0d0)
      endif
CCC_   + F0: H new coeff
      F0 = 1.0d0 / DT
CCC_   + D[bc];E[bc]:  Diffusion and Adevection terms
      if (iErr.eq.0) then
         if      (MTYP.eq. MMXSW_UPE) then
CCC_    * CEb: ue:b
            call UV2naa (QM,VMID, MH,LH, VMQH_CEb, VMID_UIavb,VMID_UBb)
c$$$            call UV2naa (VW, VMID, MH,LH, VMIW_W1, VMID_UBb,VMID_UIavb)
CC todo: clone group
CCC_    * up: ue:a
            call AKBwax
     O          (QM,   CW,
     I           WW,
     I           MH,   LH,  VMQH_UEava, VMQH_CEb,
     I           ipKW, iMA, KWO_Lba, KWM_M)
CCC_    * wxm: copy (temporaly)
            call AKBwax
     O          (QM,   CW,
     I           WW,
     I           MH,   LH,  VMQH_WXm, VMQH_CEb,
     I           ipKW, iMA, KWO_FCba, KWM_M)
CCC_    * w2: div:ba ue
            call AKBwaz
     O          (VW (1, VMIW_W2),  CW,
     I           QM (1, VMQH_CEb), WW,
     I           MH,   LH,  ipKW,  iMA, KWO_DXba, KWM_M)
CC          odd field mask
            call AKBomx
     M          (QM,  CW,
     I           WW,
     I           MH,   LH,  VMQH_UEava, VMQH_UEava,
     I           ipKW, iMA, KWO_ZXb)
CC       Todo: odd for div ba
CCC_    * CEc: ve:b
            call UV2naa (QM,VMID, MH,LH, VMQH_CEc, VMID_VIavc,VMID_VBc)
c$$$            call UV2naa (VW, VMID, MH,LH, VMIW_W1, VMID_VBc,VMID_VIavc)
CCC_    * vp: ve:a
            call AKBwax
     O          (QM,   CW,
     I           WW,
     I           MH,   LH,  VMQH_VEava, VMQH_CEc,
     I           ipKW, iMA, KWO_Lca, KWM_M)
CCC_    * wym: copy (temporaly)
            call AKBwax
     O          (QM,   CW,
     I           WW,
     I           MH,   LH,  VMQH_WYm, VMQH_CEc,
     I           ipKW, iMA, KWO_FCca, KWM_M)
CCC_    * w3: div:ca ve
            call AKBwaz
     O          (VW (1, VMIW_W3),  CW,
     I           QM (1, VMQH_CEc), WW,
     I           MH,   LH,  ipKW,  iMA, KWO_DYca, KWM_M)
CC          odd field mask
            call AKBomx
     M          (QM,  CW,
     I           WW,
     I           MH,   LH,  VMQH_VEava, VMQH_VEava,
     I           ipKW, iMA, KWO_ZYc)
CC       Todo: odd for div ca
CC          odd field mask if zero
CCC_    * um
            do jp = 1, MH
               if (VMC(jp, VMC_IKa).ne. _dSH) then
                  QM (jp, VMQH_WXp) = 0.0d0
                  QM (jp, VMQH_WXm) = 0.0d0
                  VW (jp, VMIW_W2)  = 0.0d0
               else if (QM (jp, VMQH_WXm).gt.+PUZ
     $              .and. QM (jp, VMQH_CEb).gt.+PUZ) then
                  QM (jp, VMQH_WXm) = 1.0d0
                  QM (jp, VMQH_WXp) = 0.0d0
               else if (QM (jp, VMQH_WXm).lt.-PUZ
     $              .and. QM (jp, VMQH_CEb).lt.-PUZ) then
                  QM (jp, VMQH_WXm) = 0.0d0
                  QM (jp, VMQH_WXp) = 1.0d0
               else
                  QM (jp, VMQH_WXp) = 0.0d0
                  QM (jp, VMQH_WXm) = 0.0d0
                  VW (jp, VMIW_W2)  = 0.0d0
               endif
c$$$cc             force ZEV check
c$$$               QM (jp, VMQH_WXp) = 0.0d0
c$$$               QM (jp, VMQH_WXm) = 0.0d0
c$$$               VW (jp, VMIW_W2)  = 0.0d0
            enddo
CCC_    * vm
            do jp = 1, MH
               if (VMC(jp, VMC_IKa).ne. _dSH) then
                  QM (jp, VMQH_WYp) = 0.0d0
                  QM (jp, VMQH_WYm) = 0.0d0
                  VW (jp, VMIW_W3)  = 0.0d0
               else if (QM (jp, VMQH_WYm).gt.+PUZ
     $              .and. QM (jp, VMQH_CEc).gt.+PUZ) then
                  QM (jp, VMQH_WYm) = 1.0d0
                  QM (jp, VMQH_WYp) = 0.0d0
               else if (QM (jp, VMQH_WYm).lt.-PUZ
     $              .and. QM (jp, VMQH_CEc).lt.-PUZ) then
                  QM (jp, VMQH_WYm) = 0.0d0
                  QM (jp, VMQH_WYp) = 1.0d0
               else
                  QM (jp, VMQH_WYp) = 0.0d0
                  QM (jp, VMQH_WYm) = 0.0d0
                  VW (jp, VMIW_W3)  = 0.0d0
               endif
c$$$cc             force ZEV check
c$$$               QM (jp, VMQH_WYp) = 0.0d0
c$$$               QM (jp, VMQH_WYm) = 0.0d0
c$$$               VW (jp, VMIW_W3)  = 0.0d0
            enddo
CCC_    * div: w2+w3
            call UV2naa (QM, VW,  MH, LH, VMQH_CDIV, VMIW_W2, VMIW_W3)
         else
            iErr = -1
         endif
      endif
CCC_   + B: Right-hand vector
      if (iErr.eq.0) then
CC     not VMI_Ha but VMC_HCa
         do jp = 1, MH
            QM (jp, VMQH_BB) =
     $           QM  (jp, VMQH_MSK) * VMHB (jp, VMHB_TMBa)
         enddo
         do jp = 1, MH
            X (jp, BCGW_BB) =
     $           QM  (jp, VMQH_BB) + VMC (jp, VMC_HCa) * F0
         enddo
c$$$         do jp = 1, MH
c$$$     $           QM  (jp, VMQ_MSK) * VMHB (jp, VMHB_TMBa)
c$$$     $           + VMC (jp, VMC_HCa) / DT
c$$$         enddo
      endif
      RETURN
      END
CCC_ & MMYdec  ## Movement/matrix operators kiwi declaration
      subroutine MMYdec
     O    (iErr,
     M     ipKW,
     I     IFP)
      implicit none
      _INTENT(OUT,  integer) iErr
      _INTENT(INOUT,integer) ipKW (*)
      _INTENT(IN,   integer) IFP
      iErr = 0
c
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_Lba,  KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_Lca,  KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_FCba, KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_FCca, KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_DXab, KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_DYac, KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_GXab, KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_GYac, KWM_BOTH, IFP)
c
      RETURN
      END
CCC_ & MMYcgs  ## Movement/matrix clone group declaration
      subroutine MMYcgs
     O    (iErr,
     O     ipCG,
     W     kDTA,
     I     LTBL, LCG, LH, LCK, ipKW, IE, IFP)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,  integer) iErr
      _INTENT(IN,   integer) LCG, LH, LTBL, LCK
      _INTENT(INOUT,integer) ipCG (LCG, *)
      _INTENT(IN,   integer) ipKW (*), IE (*), IFP
      _INTENT(OUT,  integer) kDTA (LTBL, 3)
c
      integer kv
CCC_  * Body
      iErr = 0
c
      if (iErr.eq.0) then
         call MIBcgr
     O       (iErr,
     O        ipCG,
     W        kDTA,
     I        LTBL, LCG, LH, LCK, ipKW, IE, IFP)
      endif
CCC_   + group normal (none)
CCC_   + group transpose
      if (iErr.eq.0) then
         kv   = CGB_UHaT
         call AKCgrs (iErr, ipCG (1, kv), LCG)
         call AKCgad (iErr, ipCG (1, kv), KWO_Lba, KWM_T, LCG)
         call AKCgad (iErr, ipCG (1, kv), KWO_Lca, KWM_T, LCG)
         call AKCgsb
     O       (iErr, ipCG (1, kv),  KDTA,
     I        LCG,  LTBL,  LH,   ipKW, IE,   IFP)
      endif
CCC_   + report
      call DAtrcU (IFP, iErr, 'R', 'MMZCGS')
      RETURN
      END
CCC_* [MMU] Upwind type matrix
CCC_ + Description
CC
CC   W[pm] already use odd-field mask
CC                               e      o
CC     M = Mask [[ <Wp:ab Wm:ab> Div:ba u:a
CC                +<Wp:ac Wm:ac> Div:ca v:a]
CC               + (Div u + Div v)]
CC       + F0
CC
CC     T = [[u:a Div:ba <Wp:ab Wm:ab>
CC          + v:a Div:ca <Wp:ac Wm:ac>]
CC          + (Div u + Div v)] Mask
CC       + F0
CC
CC       Wp for +1/2   Wm for -1/2
CCC_ & MMUmns  ## Movement/matrix multiplication suite
      subroutine MMUmns
     M    (X,
     I     KXL,  KXR,
     W     C,    W,
     I     F0,   QM,   WW,
     I     iMA,  ipKW, ipCG, MH, LH, LCG)
CCC_  * Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH, KXR, KXL
      _INTENT(IN,   integer)  LCG
      _INTENT(INOUT,_REALSTD) X    (LH,  *)
      _INTENT(OUT,  _REALSTD) C    (*)
      _INTENT(OUT,  _REALSTD) W    (LH,  *)
      _INTENT(IN,   _REALSTD) QM   (*),  F0
      _INTENT(IN,   _REALSTD) WW   (*)
      _INTENT(IN,   integer)  iMA  (*),  ipKW (*)
      _INTENT(IN,   integer)  ipCG (LCG, *)
      integer KSW
CCC_  * Body
      KSW = KWM_M
CCC_   + [B1:a, B2:a] = [u:a H:a, v:a H:a]
      call UV3nma (W, QM, X, MH, LH, VMIW_W1, VMQU_UEava, KXR)
      call UV3nma (W, QM, X, MH, LH, VMIW_W2, VMQU_VEava, KXR)
CCC_   + [B3:b, B4:c] = [<div_x> <div_y>] [B1:a, B2:a]
      call AKBwax
     O    (W,    C,
     I     WW,
     I     MH,   LH,  VMIW_W3, VMIW_W1,
     I     ipKW, iMA, KWO_DXab, KSW)
      call AKBwax
     O    (W,    C,
     I     WW,
     I     MH,   LH,  VMIW_W4, VMIW_W2,
     I     ipKW, iMA, KWO_DYac, KSW)
CCC_   + [B1:a]       = [Wp Wm]x [B3:b]
      call AKBuax
     O    (W,    C,
     I     QM,
     I     MH,   LH,  VMIW_W1,  VMIW_W3,  VMQU_WXp, VMQU_WXm,
     I     ipKW, iMA, KWO_Lba,  KSW)
CCC_   + [B2:a]       = [Wp Wm]y [B4:c]
      call AKBuax
     O    (W,    C,
     I     QM,
     I     MH,   LH,  VMIW_W2,  VMIW_W4,  VMQU_WYp, VMQU_WYm,
     I     ipKW, iMA, KWO_Lca,  KSW)
CCC_   + X[L]:a   = B1:a + B2:a
      call UV2naa (X, W,  MH, LH, KXL, VMIW_W1, VMIW_W2)
CCC_   . [B1:a]   = Div(u+v) H
      call UV3nma (W, QM, X, MH, LH, VMIW_W1, VMQU_CDIV, KXR)
CCC_   . X[L]:a   = X[L]:a + Div(u+v) H
      call UV1uaa (X, W, MH, LH, KXL, VMIW_W1)
CCC_   + X[L]:a   = X[L]:a * Mask
      call UV1uma (X,   QM, MH, LH,  KXL, VMQU_MSK)
CCC_   + X[L]:a   = X[L]:a + f0 * X[R]:a
      call UV0ufa (X, MH, LH,  KXL, KXR,   F0)
      RETURN
      END
CCC_ & MMUmts  ## Movement/matrix multiplication suite (transpose)
      subroutine MMUmts
     M    (X,
     I     KXL,  KXR,
     W     C,    W,
     I     F0,   QM,   WW,
     I     iMA,  ipKW, ipCG, MH, LH, LCG)
CCC_  * Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH, KXR, KXL
      _INTENT(IN,   integer)  LCG
      _INTENT(INOUT,_REALSTD) X (LH, *)
      _INTENT(OUT,  _REALSTD) C (LH, *)
      _INTENT(OUT,  _REALSTD) W (LH, *)
      _INTENT(IN,   _REALSTD) QM (*), F0
      _INTENT(IN,   _REALSTD) WW (*)
      _INTENT(IN,   integer)  iMA (*), ipKW (*)
      _INTENT(IN,   integer)  ipCG (LCG, *)
      integer KSW
CCC_  * Body
      KSW = KWM_T
CCC_   + B1 = QM * X[R]:a
      call UV3nma (W, QM, X, MH, LH, VMIW_W1, VMQU_MSK, KXR)
CCC_   + B2 = <Wp:ab Wm:ab>T B1
      call AKBtax
     M    (W,    C,
     I     QM,
     I     MH,   LH,  VMIW_W2, VMIW_W1, VMQU_WXp, VMQU_WXm,
     I     VMIW_W4, VMIW_W5,
     I     ipKW, iMA, KWO_Lba, KSW)
c$$$      call UV0d2a (W, MH, LH, VMIW_W4, VMIW_W5, 'WXx', 0, 97)
CCC_   + B3 = <Wp:ac Wm:ac>T B1
      call AKBtax
     M    (W,    C,
     I     QM,
     I     MH,   LH,  VMIW_W3, VMIW_W1, VMQU_WYp, VMQU_WYm,
     I     VMIW_W4, VMIW_W5,
     I     ipKW, iMA, KWO_Lca, KSW)
c$$$      call UV0d2a (W, MH, LH, VMIW_W4, VMIW_W5, 'WXy', 0, 97)
c$$$      call UV0d2a (W, MH, LH, VMIW_W2, VMIW_W3, 'WW', 0, 97)
CCC_   + B4 = Div:ba T B2
      call AKBwax
     O    (W,    C (1,1),
     I     WW,
     I     MH,   LH,  VMIW_W4,  VMIW_W2,
     I     ipKW, iMA, KWO_DXab, KSW)
CCC_   + B5 = Div:ca T B3
      call AKBwax
     O    (W,    C (1,2),
     I     WW,
     I     MH,   LH,  VMIW_W5,  VMIW_W3,
     I     ipKW, iMA, KWO_DYac, KSW)
c$$$      call UV0d2a (W, MH, LH, VMIW_W4, VMIW_W5, 'DX', 0, 97)
c$$$      call UV0d2a (C, MH, LH, 1, 2, 'C',  0, 97)
CCC_   + B4 *= U
      call UV1uma (W, QM, MH, LH, VMIW_W4, VMQU_UEava)
CCC_   + B5 *= V
      call UV1uma (W, QM, MH, LH, VMIW_W5, VMQU_VEava)
c$$$      call UV0d2a (W,  MH, LH, VMIW_W4, VMIW_W5, 'UD', 0, 97)
c$$$      call UV0d2a (QM, MH, LH, VMQU_Ua, VMQU_Va, 'U',  0, 97)
CCC_   + X[L]:a = (B4:a + B5:a)
      call UV2naa (X, W,  MH, LH, KXL, VMIW_W4, VMIW_W5)
CCC_   . B1:a = B1 (Mask X) * DIVu
      call UV1uma (W, QM, MH, LH, VMIW_W1, VMQU_CDIV)
CCC_   . X[L]:a = X[L]: + B1:a
      call UV1uaa (X, W, MH, LH, KXL, VMIW_W1)
CCC_   + X[L]:a = X[L]:a + f0 * X[R]:a
      call UV0ufa (X, MH, LH,  KXL, KXR,   F0)
      RETURN
      END
CCC_ & MMUsns  ## Movement/matrix solver
      subroutine MMUsns
     M    (X,
     I     KXL,  KXR,
     W     C,    W,
     I     F0,   QM,   WW,
     I     iMA,  ipKW, ipCG, MH, LH, LCG)
CCC_  * Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH, KXR, KXL
      _INTENT(IN,   integer)  LCG
      _INTENT(INOUT,_REALSTD) X (*)
      _INTENT(OUT,  _REALSTD) C (*)
      _INTENT(OUT,  _REALSTD) W (*)
      _INTENT(IN,   _REALSTD) QM (*), F0
      _INTENT(IN,   _REALSTD) WW (*)
      _INTENT(IN,   integer)  iMA (*), ipKW (*)
      _INTENT(IN,   integer)  ipCG (*)
CCC_  * Body
      call UV1nda (X, QM, MH, LH, KXL, KXR, VMQU_DIAG)
      RETURN
      END
CCC_ & MMUsts  ## Movement/matrix solver (transpose)
      subroutine MMUsts
     M    (X,
     I     KXL,  KXR,
     W     C,    W,
     I     F0,   QM,   WW,
     I     iMA,  ipKW, ipCG, MH, LH, LCG)
CCC_  * Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH, KXR, KXL
      _INTENT(IN,   integer)  LCG
      _INTENT(INOUT,_REALSTD) X (*)
      _INTENT(OUT,  _REALSTD) C (*)
      _INTENT(OUT,  _REALSTD) W (*)
      _INTENT(IN,   _REALSTD) QM (*), F0
      _INTENT(IN,   _REALSTD) WW (*)
      _INTENT(IN,   integer)  iMA (*), ipKW (*)
      _INTENT(IN,   integer)  ipCG (*)
CCC_  * Body
      call UV1nda (X, QM, MH, LH, KXL, KXR, VMQU_DIAG)
      RETURN
      END
CCC_ & MMUgen  ## Movement/matrix generator
      subroutine MMUgen
     O    (iErr,
     O     X,    QM,   F0,
     W     VW,   CW,
     I     VMI,  VMC,  VMHB, VMID, DT,   WF,
     I     WW,
     I     ipKW, iMA,  MH,   LH,   MTYP)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,integer)  iErr
      _INTENT(IN, integer)  MH, LH
c
      _INTENT(OUT,_REALSTD) X    (LH, *)
      _INTENT(OUT,_REALSTD) QM   (LH, *)
      _INTENT(OUT,_REALSTD) F0
c
      _INTENT(OUT,_REALSTD) VW   (LH, *)
      _INTENT(OUT,_REALSTD) CW   (LH, *)
c
      _INTENT(IN, _REALSTD) VMI  (LH, *)
      _INTENT(IN, _REALSTD) VMHB (LH, *)
      _INTENT(IN, _REALSTD) VMC  (LH, *)
      _INTENT(IN, _REALSTD) VMID (LH, *)
c
      _INTENT(IN, _REALSTD) DT, WF
      _INTENT(IN, _REALSTD) WW (LH, *)
      _INTENT(IN, integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN, integer)  iMA  (*)
      _INTENT(IN, integer)  MTYP
      integer jp
      _REALSTD PUZ
      integer jlo, jla
CCC_  * Body
      iErr = 0
c
      PUZ  = 0.0d0
C      PUZ  = 1.0d0
CC    H/dt + div Q = M + Ho/dt
CC    Q = [ub + E] H
CC    H/dt + div ([ub + E] H) = M + Ho/dt
CC    if ub+E==0:  H/dt + H div (ub+E) = M + Ho/dt
CCC_   + M: Mask matrix
      if (iErr.eq.0) then
         call UV1cpa (QM, VMI, MH, LH, VMQU_MSK, VMI_CLa)
      endif
CCC_   + D: Diagnal vector
      if (iErr.eq.0) then
         call UV0sta (QM,  MH, LH, VMQU_DIAG, 1.0d0)
      endif
CCC_   + F0: H new coeff
      F0 = 1.0d0 / DT
CCC_   + D[bc];E[bc]:  Diffusion and Adevection terms
      if (iErr.eq.0) then
         if      (MTYP.eq. MMXSW_UP1) then
            call UV2naa (VW, VMID, MH,LH, VMIW_W1, VMID_UBb,VMID_UIavb)
CC todo: clone group
            call AKBwaz
     O          (QM (1, VMQU_UEava), CW,
     I           VW (1, VMIW_W1), WW,
     I           MH,   LH,  ipKW, iMA, KWO_Lba, KWM_M)
            call AKBwax
     O          (VW,   CW,
     I           WW,
     I           MH,   LH,  VMIW_W2, VMIW_W1,
     I           ipKW, iMA, KWO_DXba, KWM_M)
CC          odd field mask
            call AKBomx
     M          (QM,  CW,
     I           WW,
     I           MH,   LH,  VMQU_UEava, VMQU_UEava,
     I           ipKW, iMA, KWO_ZXb)
CC       Todo: odd for div ba
c
            call UV2naa (VW, VMID, MH,LH, VMIW_W1, VMID_VBc,VMID_VIavc)
            call AKBwaz
     O          (QM (1, VMQU_VEava), CW,
     I           VW (1, VMIW_W1), WW,
     I           MH,   LH,  ipKW, iMA, KWO_Lca, KWM_M)
            call AKBwax
     O          (VW,   CW,
     I           WW,
     I           MH,   LH,  VMIW_W3,  VMIW_W1,
     I           ipKW, iMA, KWO_DYca, KWM_M)
CC          odd field mask
            call AKBomx
     M          (QM,  CW,
     I           WW,
     I           MH,   LH,  VMQU_VEava, VMQU_VEava,
     I           ipKW, iMA, KWO_ZYc)
CC       Todo: odd for div ca
CC          odd field mask if zero
            jlo = ipKW (KWI_KWO, KWO_Lba, KWM_M)
            jla = ipKW (KWI_KWA, KWO_Lba, KWM_M)
            do jp = 1, MH
               if      (QM (jp, VMQU_UEava).gt.+PUZ) then
                  QM (jp, VMQU_WXp) = 0.0d0
                  QM (jp, VMQU_WXm) = 1.0d0
                  VW (jp, VMIW_W2)  = 0.0d0
               else if (QM (jp, VMQU_UEava).lt.-PUZ) then
                  QM (jp, VMQU_WXp) = 1.0d0
                  QM (jp, VMQU_WXm) = 0.0d0
                  VW (jp, VMIW_W2)  = 0.0d0
               else
c$$$                  QM (jp, VMQU_WXp) = 0.5d0
c$$$                  QM (jp, VMQU_WXm) = 0.5d0
c$$$                  QM (jp, VMQU_WXp) = WW (jp, jlo)
c$$$                  QM (jp, VMQU_WXm) = WW (jp, jla)
                  QM (jp, VMQU_WXp) = 0.0d0
                  QM (jp, VMQU_WXm) = 0.0d0
               endif
            enddo
            jlo = ipKW (KWI_KWO, KWO_Lca, KWM_M)
            jla = ipKW (KWI_KWA, KWO_Lca, KWM_M)
            do jp = 1, MH
               if      (QM (jp, VMQU_VEava).gt.+PUZ) then
                  QM (jp, VMQU_WYp) = 0.0d0
                  QM (jp, VMQU_WYm) = 1.0d0
                  VW (jp, VMIW_W3)  = 0.0d0
               else if (QM (jp, VMQU_VEava).lt.-PUZ) then
                  QM (jp, VMQU_WYp) = 1.0d0
                  QM (jp, VMQU_WYm) = 0.0d0
                  VW (jp, VMIW_W3)  = 0.0d0
               else
c$$$                  QM (jp, VMQU_WYp) = 0.5d0
c$$$                  QM (jp, VMQU_WYm) = 0.5d0
c$$$                  QM (jp, VMQU_WYp) = WW (jp, jlo)
c$$$                  QM (jp, VMQU_WYm) = WW (jp, jla)
                  QM (jp, VMQU_WYp) = 0.0d0
                  QM (jp, VMQU_WYm) = 0.0d0
               endif
            enddo
            call UV2naa (QM, VW,  MH, LH, VMQU_CDIV, VMIW_W2, VMIW_W3)
         else
            iErr = -1
         endif
      endif
CCC_   + B: Right-hand vector
      if (iErr.eq.0) then
CC     not VMI_Ha but VMC_HCa
         do jp = 1, MH
            QM (jp, VMQU_BB) =
     $           QM  (jp, VMQU_MSK) * VMHB (jp, VMHB_TMBa)
         enddo
         do jp = 1, MH
            X (jp, BCGW_BB) =
     $           QM  (jp, VMQU_BB) + VMC (jp, VMC_HCa) * F0
         enddo
c$$$         do jp = 1, MH
c$$$     $           QM  (jp, VMQ_MSK) * VMHB (jp, VMHB_TMBa)
c$$$     $           + VMC (jp, VMC_HCa) / DT
c$$$         enddo
      endif
      RETURN
      END
CCC_ & MMUdec  ## Movement/matrix operators kiwi declaration
      subroutine MMUdec
     O    (iErr,
     M     ipKW,
     I     IFP)
      implicit none
      _INTENT(OUT,  integer) iErr
      _INTENT(INOUT,integer) ipKW (*)
      _INTENT(IN,   integer) IFP
      iErr = 0
c
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_Lba,  KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_Lca,  KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_DXab, KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_DYac, KWM_BOTH, IFP)
c
      RETURN
      END
CCC_ & MMUcgs  ## Movement/matrix clone group declaration
      subroutine MMUcgs
     O    (iErr,
     O     ipCG,
     W     kDTA,
     I     LTBL, LCG, LH, LCK, ipKW, IE, IFP)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,  integer) iErr
      _INTENT(IN,   integer) LCG, LH, LTBL, LCK
      _INTENT(INOUT,integer) ipCG (LCG, *)
      _INTENT(IN,   integer) ipKW (*), IE (*), IFP
      _INTENT(OUT,  integer) kDTA (LTBL, 3)
c
      integer kv
CCC_  * Body
      iErr = 0
c
      if (iErr.eq.0) then
         call MIBcgr
     O       (iErr,
     O        ipCG,
     W        kDTA,
     I        LTBL, LCG, LH, LCK, ipKW, IE, IFP)
      endif
CCC_   + group normal (none)
CCC_   + group transpose
      if (iErr.eq.0) then
         kv   = CGB_UHaT
         call AKCgrs (iErr, ipCG (1, kv), LCG)
         call AKCgad (iErr, ipCG (1, kv), KWO_Lba, KWM_T, LCG)
         call AKCgad (iErr, ipCG (1, kv), KWO_Lca, KWM_T, LCG)
         call AKCgsb
     O       (iErr, ipCG (1, kv),  KDTA,
     I        LCG,  LTBL,  LH,   ipKW, IE,   IFP)
      endif
CCC_   + report
      call DAtrcU (IFP, iErr, 'R', 'MMUCGS')
      RETURN
      END
CCC_& MMXOMS  ## Movement/matrix operators announcement
      subroutine MMXOMS (STRA, STRB, IOP)
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
CCC_* test
CCC_ @ MMXTST  ## test program
#ifdef TEST_MMXOMS
#ifndef TEST_MMXOMS_SUB
#define TEST_MMXOMS_SUB 1
#endif
#include "ofnstd.h"
#include "odevid.h"
      program MMXTST
CCC_  - Test suites
CC::   SOURCES muvcio.F mmheud.F mifunc.F mibakw.F:TEST_MIBAKW_SUB=1
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
c
      if (iErr.eq.0) then
         call DMAtma (iMA)
         call MMXtestMain (iErr, ipA, iMA)
         call ACCrep (FPL(ipA), 0)
      endif
      call DevFin (iErr)
      STOP
      END
CCC_ & MMXtestMain   ## main
      subroutine MMXtestMain (iErr, ipA, iMA)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(IN, integer) ipA (*)
      _INTENT(IN, integer) iMA (*)
CCC_   . tables
      character  CROOT * (32)
CCC_   . kiwi
#ifndef   OPT_MMXOMS_LHP_MAX
#  define OPT_MMXOMS_LHP_MAX OPT_MOVEMENT_LHP_MAX
#endif
#ifndef   OPT_MMXOMS_LHG_MAX
#  define OPT_MMXOMS_LHG_MAX OPT_MOVEMENT_LHG_MAX
#endif
      integer    LHP
      parameter (LHP = OPT_MMXOMS_LHP_MAX)
      integer    LHG
      parameter (LHG = OPT_MMXOMS_LHG_MAX)
c
      integer    LIE
      parameter (LIE = (LHP * 8))
      integer    IE (LIE)
c
      integer    ipKW (IPKW_FULL_DECL)
      integer    LKW
      parameter (LKW = 64)
      _REALSTD   WW (LHP * LKW)
c
      integer    LWV
      parameter (LWV = OPT_MMXOMS_LHP_MAX)
      _REALSTD   WV (LWV)
c
      _REALSTD   DENS, GRAV, PF, FG  (3)
      _REALSTD   DT,   WF
c
      _REALSTD   VMW  (LHP * VMW_MAX)

      _REALSTD   X  (LHP * BCGW_MAX)
      _REALSTD   QM (LHP * VMQQ_MAX)
c
      _REALSTD   VMI  (LHP * VMI_MAX)
      _REALSTD   VMHB (LHP * VMHB_MAX)
      _REALSTD   VMC  (LHP * VMC_MAX)
c
      _REALSTD   VMID (LHP * VMID_MAX)
c
      integer    LCK
      parameter (LCK = 4)
      _REALSTD   CW (LHP * LCK)
c
      _REALSTD   GW (LHG)
c
      integer    LTBL
      parameter (LTBL = LHP)
      integer    kDTA (LTBL, 3)
CCC_   . clone group
      integer    LCG
      parameter (LCG = KWCG_DECL(4))
      integer    ipCG (LCG, CGB_MAX)
CCC_   . global/private stencils
      integer    LNR
      parameter (LNR = 256)
      integer    KSglb (LNR * 2)
CCC_   . size
      integer  MH, LH
      integer  NZ, LZ,  KZ0
c
      integer  ipL, ipP, ipC, ipV
      integer  IFPa (16)
CCC_   . coordinate
      integer  icF
CCC_   . output
      integer  idGM (16)
      character CSW*(16)
CCC_  - Body
      iErr = 0
c
      ipL  = FPL(ipA)
      ipP  = FPP(ipA)
      ipC  = FPC(ipA)
      ipV  = FPV(ipA)
      call AFUifp (IFPa, ipP, ipC, ipL, ipV)
c
      CROOT = 'ID'
CCC_   . just for test
      NZ  = 0
      LZ  = 1
      KZ0 = 1
CCC_   . initialization
      if (iErr.eq.0) call AKPini (ipKW)
      if (iErr.eq.0) call MIBdec (iErr, ipKW, ipL)
      if (iErr.eq.0) call MMXdec (iErr, ipKW, ipL)
c
      if (iErr.eq.0) then
         call MIBKtestCfg
     O       (iErr,
     O        icF, IE,   LIE,  ipKW,
     O        WV,  WW,   MH,   LH,
     I        LHP, LKW,  LWV,  CROOT, ipA,  iMA)
      endif
      if (iErr.eq.0) then
         call MMXtestCfg
     O       (iErr,
     O        KSglb, kDTA,
     O        ipCG,
     I        LNR,   LTBL, LCG,   LHP, LCK, ipKW,  IE,  CROOT, ipA)
      endif
c
      if (iErr.eq.0) then
         call MIBKtestField
     O       (iErr,
     O        VMI, VMHB,
     I        MH,  LH,   IE, CROOT, ipA)
      endif
      if (iErr.eq.0) then
         call MIBKtestField2
     O       (iErr,
     M        VMI,
     W        CW,    VMW,
     I        VMHB,
     I        WW,    MH,  LH,
     I        ipKW,  iMA)
      endif
      if (iErr.eq.0) then
         call MIBKtestParam
     O       (iErr,
     O        VMI,  VMHB, VMID,
     O        FG,   DENS, GRAV, PF, DT, WF,
     I        MH,   LH,   ipA)
      endif
c
      CSW = 'C'
      if (iErr.eq.0) then
         call MIVgst
     O       (iErr, idGM,
     I        icF,  MH,  LH,    NZ,   LZ,  KZ0,
     I        CSW,  ' ', CROOT, IFPa, IE,  iMA)
      endif
c
      if (iErr.eq.0) then
         call MUVmng
     O       (iErr, idGM,
     I        'VMHB',
     I        icF,  MH,  LH,    0,    0,
     I        CSW,  ' ', CROOT, IFPa, IE, iMA)
      endif
      if (iErr.eq.0) then
         call MUVmng
     O       (iErr, idGM,
     I        'VMQ',
     I        icF,  MH,  LH,    0,    0,
     I        CSW,  ' ', CROOT, IFPa, IE, iMA)
      endif
      if (iErr.eq.0) then
         call MUVmng
     O       (iErr, idGM,
     I        'VMX',
     I        icF,  MH,  LH,    0,    0,
     I        CSW,  ' ', CROOT, IFPa, IE, iMA)
      endif
c
      if (iErr.eq.0) then
         call MIBKtestExe
     O       (iErr,
     O        VMC,  VMID, VMW,   CW,
     I        VMI,  FG,   DENS,  GRAV,  PF,
     I        WW,
     I        MH,   LH,
     I        ipCG, LCG,  ipKW,  ipA,   iMA, IE, idGM)
      endif
      call UV1cpa (VMC, VMI, MH, LH, VMC_HCa, VMI_Ha)
      if (iErr.eq.0) then
         call MMXtestExe
     O       (iErr,
     O        X,     QM,     CW,    GW,    VMW,
     I        VMI,   VMHB,   VMC,   VMID,  DT,    WF,
     I        WW,
     I        ipCG,  LCG,
     I        MH,    LH,     KSglb, IE,    ipKW, ipA,  iMA, idGM,
     I        MMXSW_DVB)
         call MMXtestExe
     O       (iErr,
     O        X,     QM,     CW,    GW,    VMW,
     I        VMI,   VMHB,   VMC,   VMID,  DT,    WF,
     I        WW,
     I        ipCG,  LCG,
     I        MH,    LH,     KSglb, IE,    ipKW, ipA,  iMA, idGM,
     I        MMXSW_ZEV)
         call MMXtestExe
     O       (iErr,
     O        X,     QM,     CW,    GW,    VMW,
     I        VMI,   VMHB,   VMC,   VMID,  DT,    WF,
     I        WW,
     I        ipCG,  LCG,
     I        MH,    LH,     KSglb, IE,    ipKW, ipA,  iMA, idGM,
     I        MMXSW_UP1)
      endif
      RETURN
      END
CCC_ & MMXtestExe  ## execution
      subroutine MMXtestExe
     O    (iErr,
     O     X,     QM,     CW,    GW,    VMW,
     I     VMI,   VMHB,   VMC,   VMID,  DT,    WF,
     I     WW,
     I     ipCG,  LCG,
     I     MH,    LH,     KSglb, IE,    ipKW, ipA,  iMA, idGM,
     I     MSW)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)  iErr
      _INTENT(IN, integer)  MH,  LH, LCG
      _INTENT(IN, integer)  ipCG (LCG, *)
      _INTENT(IN, integer)  ipKW (*), IE (*), ipA (*), iMA (*)
      _INTENT(IN, integer)  KSglb (*)
      _INTENT(IN, integer)  idGM (*)
      _INTENT(OUT,_REALSTD) X (*),  QM (*),  CW (*), GW (*)
      _INTENT(OUT,_REALSTD) VMW (*)
      _INTENT(IN, _REALSTD) VMC  (*)
      _INTENT(IN, _REALSTD) VMHB (*)
      _INTENT(IN, _REALSTD) VMI  (*)
      _INTENT(IN, _REALSTD) VMID (*)
      _INTENT(IN, _REALSTD) DT, WF
      _INTENT(IN, _REALSTD) WW (*)
      _INTENT(IN, integer)  MSW
      _REALSTD F0
      integer  ipL
      integer  NG, IR, NR
      _REALSTD pi, xnrm
      _REALSTD T
CCC_  - Body
      iErr = 0
      ipL  = FPL(ipA)
      call DMAget (IR,    iMA, 'IR')
      call DMAget (NR,    iMA, 'NR')
      NG = EA_NG(IE)
      if (iErr.eq.0) then
         call MMXgen
     O       (iErr,
     O        X,    QM,   F0,
     W        VMW,  CW,
     I        VMI,  VMC,  VMHB, VMID,  DT,   WF,
     I        WW,
     I        ipKW, iMA,  MH,   LH,   MSW,  MMXINI_OLD)
      endif
      if (MSW .eq. MMXSW_UP1) then
         if (iErr.eq.0) then
            call MMUmns
     M          (X,
     I           BCGW_P, BCGW_XX,
     W           CW,     VMW,
     I           F0,     QM,   WW,
     I           iMA,    ipKW, ipCG, MH, LH, LCG)
         endif
         if (iErr.eq.0) then
            call MMUmts
     M          (X,
     I           BCGW_PP, BCGW_XX,
     W           CW,      VMW,
     I           F0,      QM,   WW,
     I           iMA,     ipKW, ipCG, MH, LH, LCG)
         endif
      else
         if (iErr.eq.0) then
            call MMDmns
     M          (X,
     I           BCGW_P, BCGW_XX,
     W           CW,     VMW,
     I           F0,     QM,   WW,
     I           iMA,    ipKW, ipCG, MH, LH, LCG)
         endif
         if (iErr.eq.0) then
            call MMDmts
     M          (X,
     I           BCGW_PP, BCGW_XX,
     W           CW,      VMW,
     I           F0,      QM,   WW,
     I           iMA,     ipKW, ipCG, MH, LH, LCG)
         endif
      endif
      if (iErr.eq.0) then
         call UV0nsa (X, MH, LH, BCGW_R,  BCGW_P,  BCGW_BB)
         call UV0nsa (X, MH, LH, BCGW_RR, BCGW_PP, BCGW_BB)
c
         call MMXipG
     O       (pi,
     W        GW,
     I        X,   BCGW_B1,  BCGW_R, BCGW_RR,
     I        iMA, KSglb, IE,   MH,   LH, NG, IR, 0, NR)
 101     format ('PI:', I1, 1x, E16.9)
         write (ipL, 101) MSW, pi
         call MMXipK
     O       (pi,
     W        GW,
     I        X,   BCGW_B1,  BCGW_R, BCGW_RR,
     I        iMA, KSglb, IE,   MH,   LH, NG, IR, 0, NR)
 103     format ('PIK:', I1, 1x, E16.9)
         write (ipL, 103) MSW, pi
         call MMXipN
     O       (pi,
     W        GW,
     I        X,   BCGW_B1,  BCGW_R, BCGW_RR,
     I        iMA, KSglb, IE,   MH,   LH, NG, IR, 0, NR)
 105     format ('PIN:', I1, 1x, E16.9)
         write (ipL, 105) MSW, pi
c
         call MMXinm
     O       (xnrm,
     W        GW,
     I        X,    BCGW_B1, iMA, IE, MH, LH)
 102     format ('XNRM:', I1, 1x, E16.9)
         write (ipL, 102) MSW, xnrm
      endif
c
      T = 0.0d0
CCC_   . output clusters
      if (iErr.eq.0) then
         call AFBptc
     O       (iErr,
     I        X,
     I        1, idGM (VGRP_VMX), 0, 0, T,  ' ',  ' ',  IE)
      endif
c
      if (iErr.eq.0) then
         call AFBptc
     O       (iErr,
     I        QM,
     I        1, idGM (VGRP_VMQ), 0, 0, T,  ' ',  ' ',  IE)
      endif
c
      if (iErr.eq.0) then
         call AFBptc
     O       (iErr,
     I        VMHB,
     I        1, idGM (VGRP_VMHB), 0, 0, T,  ' ',  ' ',  IE)
      endif
c
      RETURN
      END
#endif /* TEST_MMXOMS */
#if TEST_MMXOMS_SUB
#include "ofnstd.h"
CCC_ & MMXtestCfg  ## configuration
      subroutine MMXtestCfg
     O    (iErr,
     O     KSglb, kDTA,
     O     ipCG,
     I     LNR,   LTBL, LCG, LHP, LCK, ipKW,  IE,  CROOT, ipA)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer) iErr
      _INTENT(IN,   integer) LCG, LHP, LNR, LTBL, LCK
      _INTENT(OUT,  integer) KSglb (*)
      _INTENT(OUT,  integer) kDTA (LTBL, 3)
      _INTENT(OUT,  integer) ipCG  (LCG, *)
      _INTENT(IN,   integer) ipKW (*), IE (*), ipA (*)
      _INTENT(IN,   character) CROOT*(*)
c
      integer    ipL
      integer    LHG
CCC_  - Body
      iErr = 0
      ipL  = FPL(ipA)
c
      LHG  = 0
      if (iErr.eq.0) then
         call AESglb
     O       (iErr,
     O        KSglb,
     W        kDTA,
     I        LNR,    LTBL,  LHP,  LHG,  IE, ipL)
      endif
c
      if (iErr.eq.0) then
         call MMXcgs
     O       (iErr,
     O        ipCG,
     W        kDTA,
     I        LTBL, LCG, LHP, LCK, ipKW, IE, ipL)
      endif
      RETURN
      END
#endif /* TEST_MMXOMS_SUB */
CCC_* obsolete
CCC_ + begin
#if 0 /* obsolete */
CCC_ + end
#endif /* 0 */
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
