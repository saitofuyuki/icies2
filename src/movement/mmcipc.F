C movement/mmcipc.F --- IcIES/Movement CIP methods
C Maintainer:  SAITO Fuyuki
C Created: Nov 21 2016
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2020/09/15 12:17:16 fuyuki mmcipc.F>'
#define _FNAME 'movement/mmcipc.F'
#define _REV   'Snoopy0.9'
CCC_! MANIFESTO
C
C Copyright (C) 2016--2020
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
#include "olimit.h"   /* huge value */
#include "movement.h" /* movement definitions */
#include "ologfm.h"   /* logging */
CCC_* Polynomial computation
CCC_ & MMCpct  ## Preparation suite
      subroutine MMCpct
     O    (iErr,
     M     VMI,   VMC,
     W     VMW,   CW,
     I     VMHB,
     I     MSW,   OMM,  IMM,  PMM,
     I     WW,    MH,   LH,
     I     ipCG,  LCG,  ipKW, iMA, IFP)
CCC_  - Declaration
      implicit none
c
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  MH, LH, LCG
c
      _INTENT(INOUT,_REALSTD) VMI  (LH, *)
      _INTENT(OUT,  _REALSTD) VMW  (*)
      _INTENT(OUT,  _REALSTD) CW   (*)
      _INTENT(OUT,  _REALSTD) VMC  (LH, *)
      _INTENT(IN,   _REALSTD) VMHB (LH, *)
      _INTENT(IN,   integer)  MSW
      _INTENT(IN,   logical)  OMM  (*)
      _INTENT(IN,   _REALSTD) PMM  (*)
      _INTENT(IN,   integer)  IMM  (*)
c
      _INTENT(IN,   _REALSTD) WW   (*)
      _INTENT(IN,   integer)  ipKW (*), iMA (*)
      _INTENT(IN,   integer)  ipCG (*)
c
      _INTENT(IN,   integer)  IFP
c
      logical OSSA
CCC_  - Body
      iErr = 0
      OSSA = OMM (OMM_WITH_SSA)
      if (MSW.eq. MMXSW_CIPaxP
     $     .or. MSW.eq. MMXSW_CIPaxL) then
         call MMCpax
     O       (iErr,
     M        VMI,   VMC,
     W        VMW,   CW,
     I        VMHB,
     I        OMM,   IMM,  PMM,
     I        WW,    MH,   LH,
     I        ipCG,  LCG,  ipKW, iMA, IFP)
      else
         iErr = -1
      endif
      RETURN
      END
CCC_ & MMCpax  ## Preparation suite/CIP regular
      subroutine MMCpax
     O    (iErr,
     M     VMI,   VMC,
     W     VMW,   CW,
     I     VMHB,
     I     OMM,   IMM,  PMM,
     I     WW,    MH,   LH,
     I     ipCG,  LCG,  ipKW, iMA, IFP)
CCC_  - Declaration
      implicit none
c
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  MH, LH, LCG
c
      _INTENT(INOUT,_REALSTD) VMI  (LH, *)
      _INTENT(OUT,  _REALSTD) VMW  (LH, *)
      _INTENT(OUT,  _REALSTD) CW   (*)
      _INTENT(OUT,  _REALSTD) VMC  (LH, *)
      _INTENT(IN,   _REALSTD) VMHB (LH, *)
      _INTENT(IN,   logical)  OMM  (*)
      _INTENT(IN,   _REALSTD) PMM  (*)
      _INTENT(IN,   integer)  IMM  (*)
c
      _INTENT(IN,   _REALSTD) WW   (*)
      _INTENT(IN,   integer)  ipKW (*), iMA (*)
      _INTENT(IN,   integer)  ipCG (LCG, *)
c
      _INTENT(IN,   integer)  IFP
      integer jh
CCC_   . X
      call MMCpaq
     O    (iErr,
     M     VMC,   VMC_QXaU, VMC_QXbU, VMC_QXcU, VMC_QXdU,
     M            VMC_QXaL, VMC_QXbL, VMC_QXcL, VMC_QXdL,
     M     VMI,   VMI_HX,
     W     VMW,   CW,
     I     VMHB,
     I     KWO_FCab, KWO_dXb,
     I     OMM,   IMM,  PMM,
     I     WW,    MH,   LH,
     I     ipCG,  LCG,  ipKW, iMA, IFP)
CCC_   . Y
      call MMCpaq
     O    (iErr,
     M     VMC,   VMC_QYaU, VMC_QYbU, VMC_QYcU, VMC_QYdU,
     M            VMC_QYaL, VMC_QYbL, VMC_QYcL, VMC_QYdL,
     M     VMI,   VMI_HY,
     W     VMW,   CW,
     I     VMHB,
     I     KWO_FCac, KWO_dYc,
     I     OMM,   IMM,  PMM,
     I     WW,    MH,   LH,
     I     ipCG,  LCG,  ipKW, iMA, IFP)
CCC_   . H:b
      call MMCpah
     O    (iErr,
     O     VMI,  VMI_Hb,
     W     VMW,
     I     VMC,   VMC_QXaU, VMC_QXbU, VMC_QXcU, VMC_QXdU,
     I            VMC_QXaL, VMC_QXbL, VMC_QXcL, VMC_QXdL,
     I     0,
     W     KWO_Xa, KWO_Xb,KWO_dXb,
     I     WW,    MH,     LH,    ipKW)
CCC_   . H:c
      call MMCpah
     O    (iErr,
     O     VMI,  VMI_Hc,
     W     VMW,
     I     VMC,  VMC_QYaU, VMC_QYbU, VMC_QYcU, VMC_QYdU,
     I           VMC_QYaL, VMC_QYbL, VMC_QYcL, VMC_QYdL,
     I     0,
     W     KWO_Ya, KWO_Yc,KWO_dYc,
     I     WW,    MH,     LH,    ipKW)
CCC_   . H:d
      call AKBwaz
     O    (VMW (1, VMIW_W1), CW,
     I     VMI (1, VMI_Hb),  WW,
     I     MH,  LH,   ipKW, iMA, KWO_Lbd, KWM_M)
      call AKBwaz
     O    (VMW (1, VMIW_W2), CW,
     I     VMI (1, VMI_Hc),  WW,
     I     MH,  LH,   ipKW, iMA, KWO_Lcd, KWM_M)
      do jh = 1, MH
         VMI (jh, VMI_Hd)
     $        = (VMW (jh, VMIW_W1) + VMW (jh, VMIW_W2)) * 0.5d0
      enddo
      RETURN
      END
CCC_ & MMCpaq  ## Preparation suite/CIP regular primitive
      subroutine MMCpaq
     O    (iErr,
     M     VMC,   KCaU, KCbU, KCcU, KCdU,
     M            KCaL, KCbL, KCcL, KCdL,
     M     VMI,   KIGR,
     W     VMW,   CW,
     I     VMHB,
     I     KOPFC, KOPD,
     I     OMM,   IMM,  PMM,
     I     WW,    MH,   LH,
     I     ipCG,  LCG,  ipKW, iMA, IFP)
CCC_  - Declaration
      implicit none
c
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  MH, LH, LCG
c
      _INTENT(INOUT,_REALSTD) VMI  (LH, *)
      _INTENT(OUT,  _REALSTD) VMW  (LH, *)
      _INTENT(OUT,  _REALSTD) CW   (*)
      _INTENT(OUT,  _REALSTD) VMC  (LH, *)
      _INTENT(IN,   _REALSTD) VMHB (LH, *)
      _INTENT(IN,   logical)  OMM  (*)
      _INTENT(IN,   _REALSTD) PMM  (*)
      _INTENT(IN,   integer)  IMM  (*)
c
      _INTENT(IN,   integer)  KCaU, KCbU, KCcU, KCdU
      _INTENT(IN,   integer)  KCaL, KCbL, KCcL, KCdL
      _INTENT(IN,   integer)  KIGR
      _INTENT(IN,   integer)  KOPFC, KOPD
c
      _INTENT(IN,   _REALSTD) WW   (LH, *)
      _INTENT(IN,   integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN,   integer)  iMA (*)
      _INTENT(IN,   integer)  ipCG (*)
c
      _INTENT(IN,   integer)  IFP
c
      integer KHP, KGP
      integer kd
      integer jh
c
      _REALSTD  DX
      _REALSTD  H0, H1
      _REALSTD  G0, G1
CCC_  - Body
      iErr = 0
      KHP  = 1
      KGP  = 2
      kd = ipKW(KWI_KWO, KOPD, KWM_M)
      if (iErr.eq.0) then
         call AKBwez
     O       (VMW (1, KHP),     CW,
     I        VMI (1, VMI_Ha),  WW,
     I        MH,   LH,  ipKW, iMA, KOPFC, KWM_M)
         call AKBwez
     O       (VMW (1, KGP),    CW,
     I        VMI (1, KIGR),   WW,
     I        MH,   LH,  ipKW, iMA, KOPFC, KWM_M)
      endif
      if (iErr.eq.0) then
CCC_   . to left (ref i)
         do jh = 1, MH
            DX = WW (jh, kd)
            H0 = VMI(jh, VMI_Ha)
            H1 = VMW(jh, KHP)
            G0 = VMI(jh, KIGR)
            G1 = VMW(jh, KGP)
            VMC(jh, KCaU) =
     $           + (G0 + G1) / (DX * DX)
     $           + ((H0 - H1) / (DX * DX * DX)) * 2.0d0
            VMC(jh, KCbU) =
     $           - (2.0d0 * G0 + G1) / DX
     $           - ((H0 - H1) / (DX * DX))      * 3.0d0
            VMC(jh, KCcU) = G0
            VMC(jh, KCdU) = H0
         enddo
CCC_   . to right (ref i+1)
         do jh = 1, MH
            DX = - WW (jh, kd)
            H1 = VMI(jh, VMI_Ha)
            H0 = VMW(jh, KHP)
            G1 = VMI(jh, KIGR)
            G0 = VMW(jh, KGP)
            VMC(jh, KCaL) =
     $           + (G0 + G1) / (DX * DX)
     $           + ((H0 - H1) / (DX * DX * DX)) * 2.0d0
            VMC(jh, KCbL) =
     $           - (2.0d0 * G0 + G1) / DX
     $           - ((H0 - H1) / (DX * DX))      * 3.0d0
            VMC(jh, KCcL) = G0
            VMC(jh, KCdL) = H0
         enddo
      endif
      RETURN
      END
CCC_ & MMCpah  ## Preparation suite/CIP regular h staggered
      subroutine MMCpah
     O    (iErr,
     O     VMI,   KIH,
     W     VMW,
     I     VMC,   KCaU, KCbU, KCcU, KCdU,
     I            KCaL, KCbL, KCcL, KCdL,
     I     KSW,
     I     KOXa,  KOXb, KODX,
     I     WW,    MH,   LH,   ipKW)
CCC_  - Declaration
      implicit none
c
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  MH, LH
c
      _INTENT(INOUT,_REALSTD) VMI  (LH, *)
      _INTENT(OUT,  _REALSTD) VMW  (LH, *)
      _INTENT(IN,   _REALSTD) VMC  (LH, *)
c
      _INTENT(IN,   integer)  KCaU, KCbU, KCcU, KCdU
      _INTENT(IN,   integer)  KCaL, KCbL, KCcL, KCdL
      _INTENT(IN,   integer)  KIH
      _INTENT(IN,   integer)  KOXa, KOXb, KODX
      _INTENT(IN,   integer)  KSW
c
      _INTENT(IN,   _REALSTD) WW   (LH, *)
      _INTENT(IN,   integer)  ipKW (IPKW_FULL_DECL)
c
      _REALSTD Ta, Tb, Tc, Td
      _REALSTD Xp
      _REALSTD TU, TL
      integer  jh
      integer  kxa, kxb, kdx
CCC_  - Body
      iErr = 0
      kdx = ipKW(KWI_KWO, KODX, KWM_M)
      kxa = ipKW(KWI_KWO, KOXa, KWM_M)
      kxb = ipKW(KWI_KWO, KOXb, KWM_M)
CCC_   . to left
      if (KSW.lt.0) then
         do jh = 1, MH
            Xp = WW(jh, kxb) - WW(jh, kxa)
            Ta = VMC(jh, KCaU)
            Tb = VMC(jh, KCbU)
            Tc = VMC(jh, KCcU)
            Td = VMC(jh, KCdU)
            VMI(jh, KIH)
     $           = Ta * (Xp * Xp * Xp)
     $           + Tb * (Xp * Xp)
     $           + Tc * (Xp)
     $           + Td
         enddo
CCC_   . to right
      else if (KSW.gt.0) then
         do jh = 1, MH
            Xp = (WW(jh, kxb) - WW(jh, kxa)) - WW(jh, kdx)
            Ta = VMC(jh, KCaL)
            Tb = VMC(jh, KCbL)
            Tc = VMC(jh, KCcL)
            Td = VMC(jh, KCdL)
            VMI(jh, KIH)
     $           = Ta * (Xp * Xp * Xp)
     $           + Tb * (Xp * Xp)
     $           + Tc * (Xp)
     $           + Td
         enddo
CCC_   . average
      else
         do jh = 1, MH
            Xp = WW(jh, kxb) - WW(jh, kxa)
            Ta = VMC(jh, KCaU)
            Tb = VMC(jh, KCbU)
            Tc = VMC(jh, KCcU)
            Td = VMC(jh, KCdU)
            TU =   Ta * (Xp * Xp * Xp)
     $           + Tb * (Xp * Xp)
     $           + Tc * (Xp)
     $           + Td
            Xp = (WW(jh, kxb) - WW(jh, kxa)) - WW(jh, kdx)
            Ta = VMC(jh, KCaL)
            Tb = VMC(jh, KCbL)
            Tc = VMC(jh, KCcL)
            Td = VMC(jh, KCdL)
            TL =   Ta * (Xp * Xp * Xp)
     $           + Tb * (Xp * Xp)
     $           + Tc * (Xp)
     $           + Td
            VMI(jh, KIH) = (TU + TL) * 0.5d0
         enddo
      endif
      RETURN
      END
CCC_* Gradient suite
CCC_ & MMCgrt  ## Preparation suite (gradient)
      subroutine MMCgrt
     O    (iErr,
     M     VMI,   VMC,
     W     VMW,   CW,
     I     VMHB,
     I     MSW,   OMM,  IMM,  PMM,
     I     WW,    MH,   LH,
     I     ipCG,  LCG,  ipKW, iMA, IFP)
CCC_  - Declaration
      implicit none
c
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  MH, LH, LCG
c
      _INTENT(INOUT,_REALSTD) VMI  (LH, *)
      _INTENT(OUT,  _REALSTD) VMW  (*)
      _INTENT(OUT,  _REALSTD) CW   (*)
      _INTENT(OUT,  _REALSTD) VMC  (LH, *)
      _INTENT(IN,   _REALSTD) VMHB (LH, *)
      _INTENT(IN,   integer)  MSW
      _INTENT(IN,   logical)  OMM  (*)
      _INTENT(IN,   _REALSTD) PMM  (*)
      _INTENT(IN,   integer)  IMM  (*)
c
      _INTENT(IN,   _REALSTD) WW   (*)
      _INTENT(IN,   integer)  ipKW (*), iMA (*)
      _INTENT(IN,   integer)  ipCG (*)
c
      _INTENT(IN,   integer)  IFP
c
      logical OSSA
CCC_  - Body
      iErr = 0
      OSSA = OMM (OMM_WITH_SSA)
      if (MSW.eq. MMXSW_CIPaxP
     $     .or. MSW.eq. MMXSW_CIPaxL) then
         call MMCgax
     O       (iErr,
     M        VMI,   VMC,
     W        VMW,   CW,
     I        VMHB,
     I        OMM,   IMM,  PMM,
     I        WW,    MH,   LH,
     I        ipCG,  LCG,  ipKW, iMA, IFP)
      else
         iErr = -1
      endif
      RETURN
      END
CCC_ & MMCgax  ## Preparation suite/CIP regular gradient
      subroutine MMCgax
     O    (iErr,
     M     VMI,   VMC,
     W     VMW,   CW,
     I     VMHB,
     I     OMM,   IMM,  PMM,
     I     WW,    MH,   LH,
     I     ipCG,  LCG,  ipKW, iMA, IFP)
CCC_  - Declaration
      implicit none
c
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  MH, LH, LCG
c
      _INTENT(INOUT,_REALSTD) VMI  (LH, *)
      _INTENT(OUT,  _REALSTD) VMW  (LH, *)
      _INTENT(OUT,  _REALSTD) CW   (*)
      _INTENT(OUT,  _REALSTD) VMC  (LH, *)
      _INTENT(IN,   _REALSTD) VMHB (LH, *)
      _INTENT(IN,   logical)  OMM  (*)
      _INTENT(IN,   _REALSTD) PMM  (*)
      _INTENT(IN,   integer)  IMM  (*)
c
      _INTENT(IN,   _REALSTD) WW   (*)
      _INTENT(IN,   integer)  ipKW (*), iMA (*)
      _INTENT(IN,   integer)  ipCG (LCG, *)
c
      _INTENT(IN,   integer)  IFP
      integer jh
CCC_  - Body
      iErr = 0
CCC_   . dH:b
      call MMCpag
     O    (iErr,
     M     VMC,   VMC_DSXb,
     I            VMC_QXaU, VMC_QXbU, VMC_QXcU, VMC_QXdU,
     I            VMC_QXaL, VMC_QXbL, VMC_QXcL, VMC_QXdL,
     W     VMW,
     I     0,
     W     KWO_Xa, KWO_Xb,KWO_dXb,
     I     WW,     MH,     LH,    ipKW)
CCC_   . dH:c
      call MMCpag
     O    (iErr,
     M     VMC,  VMC_DSYc,
     M           VMC_QYaU, VMC_QYbU, VMC_QYcU, VMC_QYdU,
     I           VMC_QYaL, VMC_QYbL, VMC_QYcL, VMC_QYdL,
     W     VMW,
     I     0,
     W     KWO_Ya, KWO_Yc,KWO_dYc,
     I     WW,     MH,     LH,    ipKW)
CCC_   . db
      call AKCgux
     O    (CW,
     I     VMI,  MH,  LH, VMI_Ba,
     I     iMA,  ipCG (1, CGB_Sa))
CCC_   + gradient db/dx:b db/dy:c (old field everywhere, to be updated)
      call AKGwaz
     O    (VMC (1, VMC_BXbM),
     I     CW,  VMI (1, VMI_Ba),  WW,
     I     MH,  LH,  ipKW, 3,  ipCG (1, CGB_Sa))
      call AKGwaz
     O    (VMC (1, VMC_BYcM),
     I     CW,  VMI (1, VMI_Ba),  WW,
     I     MH,  LH,  ipKW, 4,  ipCG (1, CGB_Sa))
CCC_   . ds
      call UV0uaa(VMC, MH, LH, VMC_DSXb, VMC_BXbM)
      call UV0uaa(VMC, MH, LH, VMC_DSYc, VMC_BYcM)
CCC_   . gradient ds/dy:b ds/dx:c
CCC_    * db/dy:b db/dx:c
      call AKCgux
     O    (CW,
     I     VMI,  MH,  LH, VMI_Bd,
     I     iMA,  ipCG (1, CGB_Sd))
      call AKGwaz
     O    (VMC (1, VMC_DSXc),
     I     CW,  VMI (1, VMI_Bd),  WW,
     I     MH,  LH,  ipKW, CGB_Sd_GXdc,  ipCG (1, CGB_Sd))
      call AKGwaz
     O    (VMC (1, VMC_DSYb),
     I     CW,  VMI (1, VMI_Bd),  WW,
     I     MH,  LH,  ipKW, CGB_Sd_GYdb,  ipCG (1, CGB_Sd))
CCC_   . gradient dH/dx:c dH/dy:b
      call AKBwaz
     O    (VMW(1, VMIW_W1), CW,
     I     VMI(1, VMI_HX),  WW,
     I     MH,  LH, ipKW, iMA, KWO_Lac, KWM_M)
      call AKBwaz
     O    (VMW(1, VMIW_W2), CW,
     I     VMI(1, VMI_HY),  WW,
     I     MH,  LH, ipKW, iMA, KWO_Lab, KWM_M)
      call UV1uaa(VMC, VMW, MH, LH, VMC_DSXc, VMIW_W1)
      call UV1uaa(VMC, VMW, MH, LH, VMC_DSYb, VMIW_W2)
      RETURN
      END
CCC_ & MMCpag  ## Preparation suite/CIP regular dh staggered
      subroutine MMCpag
     O    (iErr,
     O     VMC,   KCGR,
     I            KCaU, KCbU, KCcU, KCdU,
     I            KCaL, KCbL, KCcL, KCdL,
     W     VMW,
     I     KSW,
     I     KOXa,  KOXb, KODX,
     I     WW,    MH,   LH,   ipKW)
CCC_  - Declaration
      implicit none
c
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  MH, LH
c
      _INTENT(INOUT,_REALSTD) VMC  (LH, *)
      _INTENT(OUT,  _REALSTD) VMW  (LH, *)
c
      _INTENT(IN,   integer)  KCGR
      _INTENT(IN,   integer)  KCaU, KCbU, KCcU, KCdU
      _INTENT(IN,   integer)  KCaL, KCbL, KCcL, KCdL
      _INTENT(IN,   integer)  KOXa, KOXb, KODX
      _INTENT(IN,   integer)  KSW
c
      _INTENT(IN,   _REALSTD) WW   (LH, *)
      _INTENT(IN,   integer)  ipKW (IPKW_FULL_DECL)
c
      _REALSTD Ta, Tb, Tc
      _REALSTD Xp
      _REALSTD TU, TL
      integer  jh
      integer  kxa, kxb, kdx
CCC_  - Body
      iErr = 0
      kdx = ipKW(KWI_KWO, KODX, KWM_M)
      kxa = ipKW(KWI_KWO, KOXa, KWM_M)
      kxb = ipKW(KWI_KWO, KOXb, KWM_M)
CCC_   . to left
      if (KSW.lt.0) then
         do jh = 1, MH
            Xp = WW(jh, kxb) - WW(jh, kxa)
            Ta = VMC(jh, KCaU)
            Tb = VMC(jh, KCbU)
            Tc = VMC(jh, KCcU)
            VMC(jh, KCGR)
     $           = Ta * (Xp * Xp) * 3.0d0
     $           + Tb * (Xp)      * 2.0d0
     $           + Tc
         enddo
CCC_   . to right
      else if (KSW.gt.0) then
         do jh = 1, MH
            Xp = (WW(jh, kxb) - WW(jh, kxa)) - WW(jh, kdx)
            Ta = VMC(jh, KCaL)
            Tb = VMC(jh, KCbL)
            Tc = VMC(jh, KCcL)
            VMC(jh, KCGR)
     $           = Ta * (Xp * Xp) * 3.0d0
     $           + Tb * (Xp)      * 2.0d0
     $           + Tc
         enddo
CCC_   . average
      else
         do jh = 1, MH
            Xp = WW(jh, kxb) - WW(jh, kxa)
            Ta = VMC(jh, KCaU)
            Tb = VMC(jh, KCbU)
            Tc = VMC(jh, KCcU)
            TU =   Ta * (Xp * Xp) * 3.0d0
     $           + Tb * (Xp)      * 2.0d0
     $           + Tc
            Xp = (WW(jh, kxb) - WW(jh, kxa)) - WW(jh, kdx)
            Ta = VMC(jh, KCaL)
            Tb = VMC(jh, KCbL)
            Tc = VMC(jh, KCcL)
            TL =   Ta * (Xp * Xp) * 3.0d0
     $           + Tb * (Xp)      * 2.0d0
     $           + Tc
            VMC(jh, KCGR) = (TU + TL) * 0.5d0
         enddo
      endif
c$$$      jh = 485
c$$$      write (*, *) 'HU', jh, VMC(jh, KCGR),
c$$$     $     VMC(jh,KCaU),VMC(jh,KCbU),VMC(jh,KCcU),VMC(jh,KCdU)
c$$$      write (*, *) 'HL', jh, VMC(jh, KCGR),
c$$$     $     VMC(jh,KCaL),VMC(jh,KCbL),VMC(jh,KCcL),VMC(jh,KCdL)
      RETURN
      END
CCC_* Time integration suite
CCC_ & MMCitg  ## time integration
      subroutine MMCitg
     O    (iErr,
     M     VMC,    X,     C,  VW,
     I     ItrMax, MTYP,
     I     QM,     F0,    DT,
     I     ipCG,   LCG,
     I     WW,     MH,    LH, ipKW, IE, iMA, ipL)
CCC_  - Description
CC      X (:,VXH) initial guess
CCC_  - Declaration
      implicit none
      _INTENT(OUT, integer)  iErr
      _INTENT(IN,  integer)  MH, LH, LCG
      _INTENT(IN,  integer)  ItrMax
      _INTENT(IN,  integer)  MTYP
      _INTENT(IN,  integer)  ipCG (LCG, *)
CCC_   . cgm work vector
      _INTENT(INOUT,_REALSTD) VMC(LH, *)
      _INTENT(INOUT,_REALSTD) X  (LH, *)
CCC_   . matrix coeff
      _INTENT(IN,   _REALSTD) QM (LH, *), F0, DT
CCC_   . matrix work
      _INTENT(OUT,  _REALSTD) VW (*)
      _INTENT(OUT,  _REALSTD) C  (*)
      _INTENT(IN,   _REALSTD) WW (*)
      _INTENT(IN,   integer)  ipKW (*), IE (*), iMA (*)
      _INTENT(IN,   integer)  ipL
c
      integer jh
CCC_  - Body
      iErr = 0
CCC_   . gradient non-advection phase
CC     set BCGW_Z, ZZ as intermediate Hx, Hy
      if (iErr.eq.0) then
         call MMCgna
     O       (iErr,
     M        X,     BCGW_XX, BCGW_Z, BCGW_ZZ,
     W        C,     VW,
     I        VMC,   ItrMax, MTYP,
     I        QM,    F0,
     I        ipCG,  LCG,
     I        WW,    MH,    LH, ipKW, IE, iMA, ipL)
      endif
CCC_   . adjustment (TODO: need redesign)
      do jh = 1, MH
         X(jh, BCGW_XX) = MAX(0.0d0, X(jh, BCGW_XX))
         if (X(jh, BCGW_XX).le.0.0d0) then
c$$$            X(jh, BCGW_Z) = 0.0d0
c$$$            X(jh, BCGW_ZZ) = 0.0d0
         endif
      enddo
CCC_   . advection phase x
#define SKIP_X 0
#define SKIP_Y 0
#if SKIP_X
#else
      call MMChad
     O    (iErr,
     M     X,        BCGW_XX, BCGW_Z,
     W     C,        VW,
     I     MTYP,
     I     QM,       DT,       VMQH_UEava,
     I     KWO_FCab, KWO_FCba, KWO_dXb,
     I     ipCG,     LCG,
     I     WW,       MH,    LH, ipKW, IE, iMA, ipL)
#endif /* not SKIP_X */
CCC_   . advection phase y
#if SKIP_Y
#else
      call MMChad
     O    (iErr,
     M     X,        BCGW_XX, BCGW_ZZ,
     W     C,        VW,
     I     MTYP,
     I     QM,       DT,       VMQH_VEava,
     I     KWO_FCac, KWO_FCca, KWO_dYc,
     I     ipCG,     LCG,
     I     WW,       MH,    LH, ipKW, IE, iMA, ipL)
#endif /* not SKIP_Y */
CCC_   . update gradient
      call UV1cpa(VMC, X, MH, LH, VMC_HX, BCGW_Z)
      call UV1cpa(VMC, X, MH, LH, VMC_HY, BCGW_ZZ)
      RETURN
      END
CCC_ & MMCgna  ## gradients non-advection phase
      subroutine MMCgna
     O    (iErr,
     M     X,     KH,     KHX,    KHY,
     W     CW,    VMW,
     I     VMC,   ItrMax, MTYP,
     I     QM,    F0,
     I     ipCG,  LCG,
     I     WW,    MH,    LH, ipKW, IE, iMA, ipL)
CCC_  - Description
CCC_  - Declaration
      implicit none
      _INTENT(OUT, integer)  iErr
      _INTENT(IN,  integer)  MH, LH, LCG
      _INTENT(IN,  integer)  ItrMax
      _INTENT(IN,  integer)  MTYP
      _INTENT(OUT,  _REALSTD) CW (*)
      _INTENT(OUT,  _REALSTD) VMW(LH, *)
      _INTENT(IN,   _REALSTD) WW (LH, *)
      _INTENT(INOUT,_REALSTD) X  (LH, *)
      _INTENT(IN,   _REALSTD) VMC(LH, *)
      _INTENT(IN,   _REALSTD) QM (LH, *), F0
      _INTENT(IN,  integer)  KH, KHX, KHY
      _INTENT(IN,  integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN,  integer)  IE (*), iMA (*)
      _INTENT(IN,  integer)  ipCG (LCG, *)
      _INTENT(IN,  integer)  ipL
      integer jh
      _REALSTD Tx0, Tx1, Tx2
      _REALSTD Ty0, Ty1, Ty2
      _REALSTD Det
      integer  KWG
      integer  KWGx, KWGy
      integer  KWW
CCC_  - Body
c$$$      [(1/dt + du/dx)  dv/dx         ] [Hx:new]    [1/dt Hx:old]
c$$$      [du/dy           (1/dt + dv/dy)] [Hy:new]  = [1/dt Hy:old]
      iErr = 0
      KWW  = 1
      KWG  = 2
      KWGx = 3
      KWGy = 4
CCC_   . G term   M - (Ux+Vy)H
      do jh = 1, MH
         VMW(jh, KWG) =
     $        QM(jh, VMQH_BB)
     $        - (QM(jh,VMQH_xDIVu) + QM(jh,VMQH_yDIVv)) * X(jh, KH)
      enddo
CCC_   . G gradient terms
      call MMCugw
     O    (iErr,
     M     VMW,   KWG,  KWGx, KWGy, KWW,
     W     CW,
     I     WW,    MH,   LH,
     I     ipCG,  LCG,  ipKW, iMA, ipL)
CCC_   . Gx -= V dHx/dy (explicit)
      call MMCugy
     O    (iErr,
     M     VMW,   KWGx, KWG,  KWW,
     I     VMC,   VMC_HX,
     I     QM,    VMQH_VEava,
     W     CW,
     I     WW,    MH,   LH,
     I     ipCG,  LCG,  ipKW, iMA, ipL)
CCC_   . Gx to Gx - V dHx/dy
c$$$      do jh = 1, MH
c$$$         VMW(jh, KWGx) = VMW(jh, KWGx)
c$$$     $        - QM(jh, VMQH_VEava) * VMW(jh, KWG)
c$$$      enddo
CCC_   . Gy -= U dHy/dx (explicit)
      call MMCugx
     O    (iErr,
     M     VMW,   KWGy, KWG,  KWW,
     I     VMC,   VMC_HY,
     I     QM,    VMQH_UEava,
     W     CW,
     I     WW,    MH,   LH,
     I     ipCG,  LCG,  ipKW, iMA, ipL)
CCC_   . Gy to Gy - U dHy/dx
c$$$      do jh = 1, MH
c$$$         VMW(jh, KWGy) = VMW(jh, KWGy)
c$$$     $        - QM(jh, VMQH_UEava) * VMW(jh, KWG)
c$$$      enddo
CCC_   . solve
      do jh = 1, MH
#if 0
         Tx0 = F0 * VMC(jh, VMC_HX)
         Tx1 = F0 + QM(jh, VMQH_xDIVu)
         Tx2 = 0.0d0
         Ty0 = F0 * VMC(jh, VMC_HY)
         Ty1 = 0.0d0
         Ty2 = F0 + QM(jh, VMQH_yDIVv)
#elif 0
         Tx0 = F0 * VMC(jh, VMC_HX) + VMW(jh, KWGx)
         Tx1 = F0 + QM(jh, VMQH_xDIVu)
         Tx2 = 0.0d0
         Ty0 = F0 * VMC(jh, VMC_HY)
         Ty1 = 0.0d0
         Ty2 = F0 + QM(jh, VMQH_yDIVv)
#else
         Tx0 = F0 * VMC(jh, VMC_HX) + VMW(jh, KWGx)
         Tx1 = F0 + QM(jh, VMQH_xDIVu)
         Tx2 =    + QM(jh, VMQH_xDIVv)
         Ty0 = F0 * VMC(jh, VMC_HY) + VMW(jh, KWGy)
         Ty1 =    + QM(jh, VMQH_yDIVu)
         Ty2 = F0 + QM(jh, VMQH_yDIVv)
#endif
         Det = Tx1 * Ty2 - Tx2 * Ty1
         X (jh, KHX) = (Ty2 * Tx0 - Tx2 * Ty0) / Det
         X (jh, KHY) = (Tx1 * Ty0 - Ty1 * Tx0) / Det
c$$$         write (*, *) 'HX', jh, VMC(jh,VMC_HX), X(jh, KHX)
c$$$         write (*, *) 'HY', jh, VMC(jh,VMC_HY), X(jh, KHY)
c$$$         write(*, *) 'HNA', jh, X(jh,KH)
      enddo
c$$$      jh = 491
c$$$      write(*, *) 'HNA', jh, X(jh,KH)
      RETURN
      END
CCC_ & MMChad  ## advection phase one direction
      subroutine MMChad
     O    (iErr,
     M     X,        KH,    KGR,
     W     CW,       VMW,
     I     MTYP,
     I     QM,       DT,    KQU,
     I     KOFC,     KOFCr, KOD,
     I     ipCG,     LCG,
     I     WW,       MH,    LH, ipKW, IE, iMA, ipL)
CCC_  - Declaration
      implicit none
      _INTENT(OUT, integer)  iErr
      _INTENT(IN,  integer)  MH, LH, LCG
      _INTENT(IN,  integer)  MTYP
      _INTENT(IN,  integer)  ipCG (LCG, *)
      _INTENT(INOUT,_REALSTD) X  (LH, *)
      _INTENT(IN,   _REALSTD) QM (LH, *), DT
      _INTENT(OUT,  _REALSTD) VMW(LH, *)
      _INTENT(OUT,  _REALSTD) CW (*)
      _INTENT(IN,   _REALSTD) WW (LH, *)
      _INTENT(IN,   integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN,   integer)  IE (*), iMA (*)
      _INTENT(IN,   integer)  ipL
      _INTENT(IN,   integer)  KH, KGR
      _INTENT(IN,   integer)  KQU
      _INTENT(IN,   integer)  KOFC, KOFCr, KOD
c
      integer KWH,  KWGR, KWU
      integer KWlX, KWuX, KWlG, KWuG
      integer kd
      integer jh
c
      _REALSTD  DX
      _REALSTD  H0, H1
      _REALSTD  G0, G1
c
      _REALSTD  Ta, Tb, Tc, Td
      _REALSTD  UT
CCC_  - Body
      iErr = 0
      KWH  = 1
      KWGR = 2
      KWU  = 3
      KWlX = 4
      KWuX = 5
      KWlG = 6
      KWuG = 7
c
      kd = ipKW(KWI_KWO, KOD, KWM_M)
c
      if (iErr.eq.0) then
         call AKBwez
     O       (VMW(1, KWH),    CW,
     I        X  (1, KH),     WW,
     I        MH,   LH,  ipKW, iMA, KOFC, KWM_M)
         call AKBwez
     O       (VMW(1, KWGR),   CW,
     I        X  (1, KGR),    WW,
     I        MH,   LH,  ipKW, iMA, KOFC, KWM_M)
         call AKBwez
     O       (VMW(1, KWU),    CW,
     I        QM (1, KQU),    WW,
     I        MH,   LH,  ipKW, iMA, KOFC, KWM_M)
      endif
c
      do jh = 1, MH
CCC_   . to left (ref i)
         DX = WW (jh, kd)
         H0 = X  (jh, KH)
         H1 = VMW(jh, KWH)
         G0 = X  (jh, KGR)
         G1 = VMW(jh, KWGR)
         Ta = + (G0 + G1) / (DX * DX)
     $        + ((H0 - H1) / (DX * DX * DX)) * 2.0d0
         Tb = - (2.0d0 * G0 + G1) / DX
     $        - ((H0 - H1) / (DX * DX))      * 3.0d0
         Tc = G0
         Td = H0
         UT = - MIN(0.0d0, QM(jh, KQU)) * DT
         VMW(jh, KWlX) =
     $        + Ta * (UT * UT * UT)
     $        + Tb * (UT * UT)
     $        + Tc *  UT
     $        + Td
         VMW(jh, KWlG) =
     $        + (Ta * (UT * UT)) * 3.0d0
     $        + (Tb *  UT)       * 2.0d0
     $        +  Tc
CCC_   . to right (ref i+1)
         DX = - WW (jh, kd)
         H1 = X  (jh, KH)
         H0 = VMW(jh, KWH)
         G1 = X  (jh, KGR)
         G0 = VMW(jh, KWGR)
         Ta = + (G0 + G1) / (DX * DX)
     $        + ((H0 - H1) / (DX * DX * DX)) * 2.0d0
         Tb = - (2.0d0 * G0 + G1) / DX
     $        - ((H0 - H1) / (DX * DX))      * 3.0d0
         Tc = G0
         Td = H0
         UT = - MAX(0.0d0, VMW(jh, KWU)) * DT
         VMW(jh, KWuX) =
     $        + Ta * (UT * UT * UT)
     $        + Tb * (UT * UT)
     $        + Tc *  UT
     $        + Td
         VMW(jh, KWuG) =
     $        + (Ta * (UT * UT)) * 3.0d0
     $        + (Tb *  UT)       * 2.0d0
     $        +  Tc
      enddo
      if (iErr.eq.0) then
         call AKBwex
     M       (VMW,    CW,
     I        WW,
     I        MH,   LH,  KWH,   KWuX,
     I        ipKW, iMA, KOFCr, KWM_M)
         call AKBwex
     M       (VMW,    CW,
     I        WW,
     I        MH,   LH,  KWGR,  KWuG,
     I        ipKW, iMA, KOFCr, KWM_M)
      endif
c$$$      jh = 485
c$$$      write(*,*) 'HT', jh,
c$$$     $     QM(jh, KQU), X(jh,KGR), VMW(jh, KWlG), VMW(jh, KWGR)
      do jh = 1, MH
c$$$         write (*, *) 'HAD',
c$$$     $        jh, QM(jh,KQU),
c$$$     $        VMW(jh,KWlX), VMW(jh,KWlG),
c$$$     $        VMW(jh,KWH),  VMW(jh,KWGR)
         if (QM(jh, KQU).lt.0.0d0) then
            X(jh, KH)  = VMW(jh, KWlX)
            X(jh, KGR) = VMW(jh, KWlG)
         else if (QM(jh, KQU).gt.0.0d0) then
            X(jh, KH)  = VMW(jh, KWH)
            X(jh, KGR) = VMW(jh, KWGR)
         endif
c$$$         write(*, *) 'HAX', jh, X(jh, KH)
      enddo
c$$$      jh = 491
c$$$      write(*, *) 'HAX', jh,
c$$$     $     QM(jh, KQU), X(jh,KH),
c$$$     $     VMW(jh+1, KWuX), VMW(jh+1, KWuG)
      RETURN
      END
CCC_* Utilities
CCC_ & MMCugw  ## gradients from a
      subroutine MMCugw
     O    (iErr,
     M     VMW,   KV,   KWX,  KWY,  KWW,
     W     CW,
     I     WW,    MH,   LH,
     I     ipCG,  LCG,  ipKW, iMA, IFP)
CCC_  - Declaration
      implicit none
c
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  MH, LH, LCG
      _INTENT(IN,   integer)  KV
      _INTENT(IN,   integer)  KWX, KWY
      _INTENT(IN,   integer)  KWW
c
      _INTENT(OUT,  _REALSTD) VMW (LH, *)
      _INTENT(OUT,  _REALSTD) CW  (*)
c
      _INTENT(IN,   _REALSTD) WW   (*)
      _INTENT(IN,   integer)  ipKW (*), iMA (*)
      _INTENT(IN,   integer)  ipCG (*)
c
      _INTENT(IN,   integer)  IFP
CCC_  - Body
      iErr = 0
      call AKBwax
     O    (VMW,  CW,
     I     WW,
     I     MH,   LH,  KWW,      KV,
     I     ipKW, iMA, KWO_DXab, KWM_M)
      call AKBwax
     O    (VMW,  CW,
     I     WW,
     I     MH,   LH,  KWX,     KWW,
     I     ipKW, iMA, KWO_Lba, KWM_M)
      call AKBwax
     O    (VMW,  CW,
     I     WW,
     I     MH,   LH,  KWW,      KV,
     I     ipKW, iMA, KWO_DYac, KWM_M)
      call AKBwax
     O    (VMW,  CW,
     I     WW,
     I     MH,   LH,  KWY,     KWW,
     I     ipKW, iMA, KWO_Lca, KWM_M)
      RETURN
      END
CCC_ & MMCugx  ## x-adv
      subroutine MMCugx
     O    (iErr,
     M     VMW,   KWL,  KWD,  KWW,
     I     VMC,   KCV,
     I     Q,     KQU,
     W     CW,
     I     WW,    MH,   LH,
     I     ipCG,  LCG,  ipKW, iMA, IFP)
CCC_  - Declaration
      implicit none
c
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  MH, LH, LCG
      _INTENT(IN,   integer)  KCV
      _INTENT(IN,   integer)  KWL
      _INTENT(IN,   integer)  KWD, KWW
      _INTENT(IN,   integer)  KQU
c
      _INTENT(OUT,  _REALSTD) VMW (LH, *)
      _INTENT(IN,   _REALSTD) VMC (LH, *)
      _INTENT(IN,   _REALSTD) Q   (LH, *)
      _INTENT(OUT,  _REALSTD) CW  (*)
c
      _INTENT(IN,   _REALSTD) WW   (*)
      _INTENT(IN,   integer)  ipKW (*), iMA (*)
      _INTENT(IN,   integer)  ipCG (*)
c
      _INTENT(IN,   integer)  IFP
      integer jh
CCC_  - Body
      iErr = 0
      call AKBwaz
     O    (VMW(1, KWW), CW,
     I     VMC(1, KCV), WW,
     I     MH,  LH, ipKW, iMA, KWO_DXab, KWM_M)
      call AKBwex
     M    (VMW,    CW,
     I     WW,
     I     MH,   LH,  KWD,      KWW,
     I     ipKW, iMA, KWO_FCba, KWM_M)
      do jh = 1, MH
         VMW(jh, KWL) = VMW(jh, KWL) -
     $        (MAX(0.0d0, Q(jh,KQU)) * VMW(jh, KWD)
     $        +MIN(0.0d0, Q(jh,KQU)) * VMW(jh, KWW))
      enddo
      RETURN
      END
CCC_ & MMCugy  ## y-adv
      subroutine MMCugy
     O    (iErr,
     M     VMW,   KWL,  KWD,  KWW,
     I     VMC,   KCV,
     I     Q,     KQU,
     W     CW,
     I     WW,    MH,   LH,
     I     ipCG,  LCG,  ipKW, iMA, IFP)
CCC_  - Declaration
      implicit none
c
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  MH, LH, LCG
      _INTENT(IN,   integer)  KCV
      _INTENT(IN,   integer)  KWL
      _INTENT(IN,   integer)  KWW, KWD
      _INTENT(IN,   integer)  KQU
c
      _INTENT(OUT,  _REALSTD) VMW (LH, *)
      _INTENT(IN,   _REALSTD) VMC (LH, *)
      _INTENT(IN,   _REALSTD) Q   (LH, *)
      _INTENT(OUT,  _REALSTD) CW  (*)
c
      _INTENT(IN,   _REALSTD) WW   (*)
      _INTENT(IN,   integer)  ipKW (*), iMA (*)
      _INTENT(IN,   integer)  ipCG (*)
c
      _INTENT(IN,   integer)  IFP
      integer jh
CCC_  - Body
      iErr = 0
      call AKBwaz
     O    (VMW(1, KWW), CW,
     I     VMC(1, KCV), WW,
     I     MH,  LH, ipKW, iMA, KWO_DYac, KWM_M)
      call AKBwex
     M    (VMW,  CW,
     I     WW,
     I     MH,   LH,  KWD,      KWW,
     I     ipKW, iMA, KWO_FCca, KWM_M)
      do jh = 1, MH
         VMW(jh, KWL) = VMW(jh, KWL) -
     $        (MAX(0.0d0, Q(jh,KQU)) * VMW(jh, KWD)
     $        +MIN(0.0d0, Q(jh,KQU)) * VMW(jh, KWW))
      enddo
c$$$      call AKBwax
c$$$     O    (VMW,  CW,
c$$$     I     WW,
c$$$     I     MH,   LH,  KWD,     KWW,
c$$$     I     ipKW, iMA, KWO_Lca, KWM_M)
      RETURN
      END
CCC_ & MMCigr  ## initial gradient
      subroutine MMCigr
     O    (iErr,
     M     VMHI,
     W     VMW,   CW,
     I     WW,    MH,   LH,
     I     ipCG,  LCG,  ipKW, iMA, IFP)
CCC_  - Declaration
      implicit none
c
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  MH, LH, LCG
c
      _INTENT(INOUT,_REALSTD) VMHI(LH, *)
      _INTENT(OUT,  _REALSTD) VMW (LH, *)
      _INTENT(OUT,  _REALSTD) CW  (*)
c
      _INTENT(IN,   _REALSTD) WW   (*)
      _INTENT(IN,   integer)  ipKW (*), iMA (*)
      _INTENT(IN,   integer)  ipCG (*)
c
      _INTENT(IN,   integer)  IFP
CCC_  - Body
      iErr = 0
      call AKBwaz
     O    (VMW (1, VMIW_W1),  CW,
     I     VMHI(1, VMHI_oHa), WW,
     I     MH,  LH,   ipKW, iMA, KWO_DXab, KWM_M)
      call AKBwaz
     O    (VMW (1, VMIW_W2),  CW,
     I     VMHI(1, VMHI_oHa), WW,
     I     MH,  LH,   ipKW, iMA, KWO_DYac, KWM_M)
      call AKBwaz
     O    (VMHI(1, VMHI_oHXa),  CW,
     I     VMW (1, VMIW_W1),    WW,
     I     MH,  LH,   ipKW, iMA, KWO_Lba, KWM_M)
      call AKBwaz
     O    (VMHI(1, VMHI_oHYa),  CW,
     I     VMW (1, VMIW_W2),    WW,
     I     MH,  LH,   ipKW, iMA, KWO_Lca, KWM_M)
      RETURN
      END
CCC_& MMCIPC ## Movement/update CIP announcement
      subroutine MMCIPC (STRA, STRB, IOP)
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
CCC_ @ MMCTST  ## Movemeent/update thickness test program
#ifdef     TEST_MMCIPC
#include "ofnstd.h"
#include "odevid.h"  /* MPI table */
      program MMCTST
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
         call MMCtestMain (iErr, ipA, iMA)
         call ACCrep (FPL(ipA), 0)
      endif
      call DevFin (iErr)
      STOP
      END
CCC_ & MMCtestMain   ## main
      subroutine MMCtestMain (iErr, ipA, iMA)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(IN, integer) ipA (*)
      _INTENT(IN, integer) iMA (*)
      RETURN
      END
#endif  /* TEST_MMCIPC */
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
