C movement/mmheud.F --- IcIES/Movement/matrix/variation H (hybrid EUDF)
C Maintainer:  SAITO Fuyuki
C Created: Jul 23 2016
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2020/09/17 08:45:43 fuyuki mmheud.F>'
#define _FNAME 'movement/mmheud.F'
#define _REV   'Snoopy0.97'
CCC_! MANIFESTO
C
C Copyright (C) 2016--2020
C           Japan Agency for Marine-Earth Science and Technology,
C           Ayako ABE-OUCHI
C
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
CCC_* Description
C
C     M H = Mask [div Q] + F0 H
C
C     div Q =  + swE                         [div:ba E:b L:ab] H:a
C              + (1-swE-swD) [swFp, swFm]:ba [div:ab E:a]      H:a
C              + swD     E:a [swFp, swFm]:ba [grad:ab]         H:a
C              + swD     {div:ba E:b}                          H:a
C
C     E = int (ui + ub) dzeta
C
CCC_* Common macros
#include "ofdlct.h"   /* fortran dialect */
#include "oarpea.h"
#include "oarpkw.h"   /* operation id in arpeggio/kiwi */
#include "movement.h" /* movement definitions */
CCC_* Matrix generation
CCC_ & MMHgen  ## Movement/matrix generator suite
      subroutine MMHgen
     O    (iErr,
     O     X,    QM,   F0,
     W     VW,   CW,
     I     VMI,  VMC,  VMHB, VMID, DT,   WF,
     I     WW,
     I     ipKW, iMA,  ipCG, MH,   LH,   LCG,  MTYP)
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
      _INTENT(IN, integer)  LCG,  ipCG (LCG, *)
c
      integer jp
CCC_  * Body
      iErr = 0
CCC_   . M: Mask matrix
      if (iErr.eq.0) then
         call UV1cpa (QM, VMI, MH, LH, VMQH_MSK, VMI_CLa)
      endif
CCC_   . Flux divergence terms
      if (iErr.eq.0) then
         call MMHtrm
     O       (iErr,
     O        QM,
     W        VW,   CW,
     I        VMI,  VMID,
     I        WW,
     I        ipKW, iMA,  ipCG, MH,   LH,   LCG, MTYP)
      endif
CCC_   . Switchers
      if (iErr.eq.0) then
         call MMHswc
     O       (iErr,
     O        QM,
     W        VW,   CW,
     I        VMI,  VMC,
     I        WW,
     I        ipKW, iMA, MH,   LH,   MTYP)
      endif
CCC_   . F0: H new coeff
      F0 = 1.0d0 / DT
CCC_   . B: Right-hand vector
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
      endif
CCC_   . D: Diagnal vector
      if (iErr.eq.0) then
         call UV0sta (QM,  MH, LH, VMQH_DIAG, 1.0d0)
      endif
      RETURN
      END
CCC_ & MMHtrm  ## Movement/matrix generator (gradient divergence terms)
      subroutine MMHtrm
     O    (iErr,
     O     QM,
     W     VW,   CW,
     I     VMI,  VMID,
     I     WW,
     I     ipKW, iMA,  ipCG, MH,   LH,   LCG, MTYP)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,integer)  iErr
      _INTENT(IN, integer)  MH, LH
c
      _INTENT(OUT,_REALSTD) QM   (LH, *)
c
      _INTENT(OUT,_REALSTD) VW   (LH, *)
      _INTENT(OUT,_REALSTD) CW   (LH, *)
c
      _INTENT(IN, _REALSTD) VMI  (LH, *)
      _INTENT(IN, _REALSTD) VMID (LH, *)
c
      _INTENT(IN, _REALSTD) WW (LH, *)
      _INTENT(IN, integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN, integer)  iMA  (*)
      _INTENT(IN, integer)  MTYP
      _INTENT(IN, integer)  LCG,  ipCG (LCG, *)
CCC_  * Body
      iErr = 0
CCC_   . X
CCC_    * E:b (== int [ui+ub])
      call UV2naa (QM,VMID, MH,LH, VMQH_UEavb, VMID_UIavb,VMID_UBb)
CCC_    * Clone group
      call AKCgux
     O    (CW,
     I     QM,   MH, LH, VMQH_UEavb,
     I     iMA,  ipCG (1, CGHV_Ub))
CCC_    * Ex:a
      call AKGwax
     M    (QM,
     I     CW,   WW,
     I     MH,   LH,  VMQH_UEava, VMQH_UEavb,
     I     ipKW, CGHV_Ub_Lba, ipCG (1, CGHV_Ub))
CCC_    * Ex:b copy
      call AKGwax
     M    (QM,
     I     CW,   WW,
     I     MH,   LH,  VMQH_Ucp, VMQH_UEavb,
     I     ipKW, CGHV_Ub_FCba, ipCG (1, CGHV_Ub))
CCC_    * xdiv
      call AKGwax
     M    (QM,
     I     CW,   WW,
     I     MH,   LH,  VMQH_xDIVu, VMQH_UEavb,
     I     ipKW, CGHV_Ub_DXba, ipCG (1, CGHV_Ub))
CC       Todo: odd for div
CCC_    * odd field mask on Ex:a
      call AKBomx
     M    (QM,   CW,
     I     WW,
     I     MH,   LH,  VMQH_UEava, VMQH_UEava,
     I     ipKW, iMA, KWO_ZXb)
CCC_   . Y
CCC_    * E:c (== int [vi+vb])
      call UV2naa (QM,VMID, MH,LH, VMQH_VEavc, VMID_VIavc,VMID_VBc)
CCC_    * Clone group
      call AKCgux
     O    (CW,
     I     QM,   MH, LH, VMQH_VEavc,
     I     iMA,  ipCG (1, CGHV_Vc))
CCC_    * Ey:a
      call AKGwax
     M    (QM,
     I     CW,   WW,
     I     MH,   LH,  VMQH_VEava, VMQH_VEavc,
     I     ipKW, CGHV_Vc_Lca, ipCG (1, CGHV_Vc))
CCC_    * Ey:c copy
      call AKGwax
     M    (QM,
     I     CW,   WW,
     I     MH,   LH,  VMQH_Vcp, VMQH_VEavc,
     I     ipKW, CGHV_Vc_FCca, ipCG (1, CGHV_Vc))
CCC_    * ydiv
      call AKGwax
     M    (QM,
     I     CW,   WW,
     I     MH,   LH,  VMQH_yDIVv, VMQH_VEavc,
     I     ipKW, CGHV_Vc_DYca, ipCG (1, CGHV_Vc))
CC       Todo: odd for div
CCC_    * odd field mask on Ey:a
      call AKBomx
     M    (QM,   CW,
     I     WW,
     I     MH,   LH,  VMQH_VEava, VMQH_VEava,
     I     ipKW, iMA, KWO_ZYc)
CCC_   . CIP related terms
      if (MTYP.eq. MMXSW_CIPaxP
     $     .or. MTYP.eq. MMXSW_CIPaxL) then
CCC_    * EX:c
         call AKBwaz
     O       (VW(1, VMIW_W1),    CW,
     I        QM(1, VMQH_UEava), WW,
     I        MH,  LH,   ipKW, iMA, KWO_Lac, KWM_M)
CCC_    * dEX/dy:a
         call AKBwaz
     O       (QM(1, VMQH_yDIVu),   CW,
     I        VW(1, VMIW_W1),      WW,
     I        MH,  LH,   ipKW, iMA, KWO_DYca, KWM_M)
CCC_    * EY:b
         call AKBwaz
     O       (VW(1, VMIW_W1),    CW,
     I        QM(1, VMQH_VEava), WW,
     I        MH,  LH,   ipKW, iMA, KWO_Lab, KWM_M)
CCC_    * dEY/dx:a
         call AKBwaz
     O       (QM(1, VMQH_xDIVv),   CW,
     I        VW(1, VMIW_W1),      WW,
     I        MH,  LH,   ipKW, iMA, KWO_DXba, KWM_M)
      endif
      RETURN
      END
CCC_ & MMHswc  ## Movement/matrix generator (switches)
      subroutine MMHswc
     O    (iErr,
     O     QM,
     W     VW,   CW,
     I     VMI,  VMC,
     I     WW,
     I     ipKW, iMA, MH,   LH,   MTYP)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,integer)  iErr
      _INTENT(IN, integer)  MH, LH
c
      _INTENT(OUT,_REALSTD) QM   (LH, *)
      _INTENT(OUT,_REALSTD) VW   (LH, *)
      _INTENT(OUT,_REALSTD) CW   (LH, *)
c
      _INTENT(IN, _REALSTD) VMI  (LH, *)
      _INTENT(IN, _REALSTD) VMC  (LH, *)
c
      _INTENT(IN, _REALSTD) WW (LH, *)
      _INTENT(IN, integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN, integer)  iMA  (*)
      _INTENT(IN, integer)  MTYP
c
      integer jp
      integer jlo, jla
      _REALSTD PUZ
      integer KIKb, KIKc
CCC_  * Body
      iErr = 0
      PUZ  = 0.0d0
      KIKb = 1
      KIKc = 2
CCC_   . HU_0
      if      (MTYP .eq. MMXSW_HU_0) then
         call AKBwez
     O       (VW (1, KIKb),    CW,
     I        VMC(1, VMC_IKb), WW,
     I        MH,   LH,  ipKW, iMA, KWO_FCba, KWM_M)
         call AKBwez
     O       (VW (1, KIKc),    CW,
     I        VMC(1, VMC_IKc), WW,
     I        MH,   LH,  ipKW, iMA, KWO_FCca, KWM_M)
c
         call UV0sta (QM,  MH, LH, VMQH_WXd, 0.0d0)
         call UV0sta (QM,  MH, LH, VMQH_WYd, 0.0d0)
         do jp = 1, MH
c$$$            if      (VMC(jp, VMC_IKa).ne. _dSH) then
            if      (VMC(jp, VMC_IKb).ne. _dSH
     $           .and. VW(jp, KIKb).ne. _dSH) then
               QM (jp, VMQH_WXe) = 1.0d0
               QM (jp, VMQH_WXp) = 0.0d0
               QM (jp, VMQH_WXm) = 0.0d0
            else if (QM (jp, VMQH_UEava).gt.+PUZ) then
               QM (jp, VMQH_WXp) = 0.0d0
               QM (jp, VMQH_WXm) = 1.0d0
               QM (jp, VMQH_WXe) = 0.0d0
            else if (QM (jp, VMQH_UEava).lt.-PUZ) then
               QM (jp, VMQH_WXp) = 1.0d0
               QM (jp, VMQH_WXm) = 0.0d0
               QM (jp, VMQH_WXe) = 0.0d0
            else
               QM (jp, VMQH_WXe) = 1.0d0
               QM (jp, VMQH_WXp) = 0.0d0
               QM (jp, VMQH_WXm) = 0.0d0
            endif
         enddo
         do jp = 1, MH
c$$$            if      (VMC(jp, VMC_IKa).ne. _dSH) then
            if      (VMC(jp, VMC_IKc).ne. _dSH
     $           .and. VW(jp, KIKc).ne. _dSH) then
               QM (jp, VMQH_WYe) = 1.0d0
               QM (jp, VMQH_WYp) = 0.0d0
               QM (jp, VMQH_WYm) = 0.0d0
            else if (QM (jp, VMQH_VEava).gt.+PUZ) then
               QM (jp, VMQH_WYp) = 0.0d0
               QM (jp, VMQH_WYm) = 1.0d0
               QM (jp, VMQH_WYe) = 0.0d0
            else if (QM (jp, VMQH_VEava).lt.-PUZ) then
               QM (jp, VMQH_WYp) = 1.0d0
               QM (jp, VMQH_WYm) = 0.0d0
               QM (jp, VMQH_WYe) = 0.0d0
            else
               QM (jp, VMQH_WYe) = 1.0d0
               QM (jp, VMQH_WYp) = 0.0d0
               QM (jp, VMQH_WYm) = 0.0d0
            endif
         enddo
CCC_   . HU_1
      else if (MTYP .eq. MMXSW_HU_1) then
CCC_   . ZEV compatible
      else if (MTYP .eq. MMXSW_HU_ZEV) then
         call UV0sta (QM,  MH, LH, VMQH_WXe, 1.0d0)
         call UV0sta (QM,  MH, LH, VMQH_WYe, 1.0d0)
         call UV0sta (QM,  MH, LH, VMQH_WXd, 0.0d0)
         call UV0sta (QM,  MH, LH, VMQH_WYd, 0.0d0)
         call UV0sta (QM,  MH, LH, VMQH_WXp, 0.0d0)
         call UV0sta (QM,  MH, LH, VMQH_WYp, 0.0d0)
         call UV0sta (QM,  MH, LH, VMQH_WXm, 0.0d0)
         call UV0sta (QM,  MH, LH, VMQH_WYm, 0.0d0)
CCC_   . UP1 compatible
      else if (MTYP .eq. MMXSW_HU_UP1) then
         call UV0sta (QM,  MH, LH, VMQH_WXe, 0.0d0)
         call UV0sta (QM,  MH, LH, VMQH_WYe, 0.0d0)
         jlo = ipKW (KWI_KWO, KWO_Lba, KWM_M)
         jla = ipKW (KWI_KWA, KWO_Lba, KWM_M)
         do jp = 1, MH
            if      (QM (jp, VMQH_UEava).gt.+PUZ) then
               QM (jp, VMQH_WXp) = 0.0d0
               QM (jp, VMQH_WXm) = 1.0d0
               QM (jp, VMQH_WXd) = 0.0d0
            else if (QM (jp, VMQH_UEava).lt.-PUZ) then
               QM (jp, VMQH_WXp) = 1.0d0
               QM (jp, VMQH_WXm) = 0.0d0
               QM (jp, VMQH_WXd) = 0.0d0
            else
               QM (jp, VMQH_WXp) = WW (jp, jlo)
               QM (jp, VMQH_WXm) = WW (jp, jla)
               QM (jp, VMQH_WXd) = 1.0d0
            endif
         enddo
         jlo = ipKW (KWI_KWO, KWO_Lca, KWM_M)
         jla = ipKW (KWI_KWA, KWO_Lca, KWM_M)
         do jp = 1, MH
            if      (QM (jp, VMQH_VEava).gt.+PUZ) then
               QM (jp, VMQH_WYp) = 0.0d0
               QM (jp, VMQH_WYm) = 1.0d0
               QM (jp, VMQH_WYd) = 0.0d0
            else if (QM (jp, VMQH_VEava).lt.-PUZ) then
               QM (jp, VMQH_WYp) = 1.0d0
               QM (jp, VMQH_WYm) = 0.0d0
               QM (jp, VMQH_WYd) = 0.0d0
            else
               QM (jp, VMQH_WYp) = WW (jp, jlo)
               QM (jp, VMQH_WYm) = WW (jp, jla)
               QM (jp, VMQH_WYd) = 1.0d0
            endif
         enddo
CCC_   . UPD compatible
      else if (MTYP .eq. MMXSW_HU_UPD) then
         call UV0sta (QM,  MH, LH, VMQH_WXe, 0.0d0)
         call UV0sta (QM,  MH, LH, VMQH_WYe, 0.0d0)
         call UV0sta (QM,  MH, LH, VMQH_WXd, 1.0d0)
         call UV0sta (QM,  MH, LH, VMQH_WYd, 1.0d0)
         jlo = ipKW (KWI_KWO, KWO_Lba, KWM_M)
         jla = ipKW (KWI_KWA, KWO_Lba, KWM_M)
         do jp = 1, MH
            if      (QM (jp, VMQH_UEava).gt.+PUZ) then
               QM (jp, VMQH_WXp) = 0.0d0
               QM (jp, VMQH_WXm) = 1.0d0
            else if (QM (jp, VMQH_UEava).lt.-PUZ) then
               QM (jp, VMQH_WXp) = 1.0d0
               QM (jp, VMQH_WXm) = 0.0d0
            else
               QM (jp, VMQH_WXp) = WW (jp, jlo)
               QM (jp, VMQH_WXm) = WW (jp, jla)
            endif
         enddo
         jlo = ipKW (KWI_KWO, KWO_Lca, KWM_M)
         jla = ipKW (KWI_KWA, KWO_Lca, KWM_M)
         do jp = 1, MH
            if      (QM (jp, VMQH_VEava).gt.+PUZ) then
               QM (jp, VMQH_WYp) = 0.0d0
               QM (jp, VMQH_WYm) = 1.0d0
            else if (QM (jp, VMQH_VEava).lt.-PUZ) then
               QM (jp, VMQH_WYp) = 1.0d0
               QM (jp, VMQH_WYm) = 0.0d0
            else
               QM (jp, VMQH_WYp) = WW (jp, jlo)
               QM (jp, VMQH_WYm) = WW (jp, jla)
            endif
         enddo
CCC_   . UPE compatible
      else if (MTYP .eq. MMXSW_HU_UPE) then
         call UV0sta (QM,  MH, LH, VMQH_WXd, 0.0d0)
         call UV0sta (QM,  MH, LH, VMQH_WYd, 0.0d0)
         do jp = 1, MH
            if      (VMC(jp, VMC_IKa).ne. _dSH) then
               QM (jp, VMQH_WXe) = 1.0d0
               QM (jp, VMQH_WXp) = 0.0d0
               QM (jp, VMQH_WXm) = 0.0d0
            else if (QM (jp, VMQH_Ucp).gt.+PUZ
     $              .and. QM (jp, VMQH_UEavb).gt.+PUZ) then
               QM (jp, VMQH_WXp) = 0.0d0
               QM (jp, VMQH_WXm) = 1.0d0
               QM (jp, VMQH_WXe) = 0.0d0
            else if (QM (jp, VMQH_Ucp).lt.-PUZ
     $              .and. QM (jp, VMQH_UEavb).lt.-PUZ) then
               QM (jp, VMQH_WXp) = 1.0d0
               QM (jp, VMQH_WXm) = 0.0d0
               QM (jp, VMQH_WXe) = 0.0d0
            else
               QM (jp, VMQH_WXe) = 1.0d0
               QM (jp, VMQH_WXp) = 0.0d0
               QM (jp, VMQH_WXm) = 0.0d0
            endif
         enddo
         do jp = 1, MH
            if      (VMC(jp, VMC_IKa).ne. _dSH) then
               QM (jp, VMQH_WYe) = 1.0d0
               QM (jp, VMQH_WYp) = 0.0d0
               QM (jp, VMQH_WYm) = 0.0d0
            else if (QM (jp, VMQH_Vcp).gt.+PUZ
     $              .and. QM (jp, VMQH_VEavc).gt.+PUZ) then
               QM (jp, VMQH_WYp) = 0.0d0
               QM (jp, VMQH_WYm) = 1.0d0
               QM (jp, VMQH_WYe) = 0.0d0
            else if (QM (jp, VMQH_Vcp).lt.-PUZ
     $              .and. QM (jp, VMQH_VEavc).lt.-PUZ) then
               QM (jp, VMQH_WYp) = 1.0d0
               QM (jp, VMQH_WYm) = 0.0d0
               QM (jp, VMQH_WYe) = 0.0d0
            else
               QM (jp, VMQH_WYe) = 1.0d0
               QM (jp, VMQH_WYp) = 0.0d0
               QM (jp, VMQH_WYm) = 0.0d0
            endif
         enddo
CCC_   . CIP regular  (extract non-advection term)
      else if (MTYP.eq. MMXSW_CIPaxP
     $        .or. MTYP.eq. MMXSW_CIPaxL) then
         call UV0sta (QM,  MH, LH, VMQH_WXd, 1.0d0)
         call UV0sta (QM,  MH, LH, VMQH_WYd, 1.0d0)
         call UV0sta (QM,  MH, LH, VMQH_WXe, 0.0d0)
         call UV0sta (QM,  MH, LH, VMQH_WYe, 0.0d0)
         call UV0sta (QM,  MH, LH, VMQH_WXp, 0.0d0)
         call UV0sta (QM,  MH, LH, VMQH_WYp, 0.0d0)
         call UV0sta (QM,  MH, LH, VMQH_WXm, 0.0d0)
         call UV0sta (QM,  MH, LH, VMQH_WYm, 0.0d0)
CCC_   . otherwise
      else
         iErr = -1
      endif
      RETURN
      END
CCC_ & MMHdht  ## dH/dt computation
      subroutine MMHdht
     M    (X,
     I     KXL,  KXR,
     W     C,    W,
     I     F0,   QM,   WW,
     I     iMA,  ipKW, ipCG, MH, LH, LCG)
CCC_  - Declaration
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
      integer jp
      _REALSTD  F0Z
CCC_  - Body
      F0Z = 0.0d0 * F0
CCC_   . div q
      call MMHmns
     M    (X,
     I     KXL,  KXR,
     W     C,    W,
     I     F0Z,  QM,   WW,
     I     iMA,  ipKW, ipCG, MH, LH, LCG)
CCC_   . - div + mb
      do jp = 1, MH
         X (jp, KXL) = - X (jp, KXL) + QM (jp, VMQH_BB)
      enddo
      RETURN
      END
CCC_ & MMHdvq  ## Flux divergence == MMHmns
CCC_* Matrix multiplication
CCC_ & MMHmns  ## Movement/matrix multiplication suite
      subroutine MMHmns
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
CCC_   . E (div:ba E:b L:ab H:a)
CCC_    * [B3:b, B4:c] = <L a:bc> H:a (clone group)
      call AKGwaz
     M    (W (1, VMIW_W3),
     I     C,    X (1, KXR), WW,
     I     MH,   LH,   ipKW, CGB_XHaN_Lab, ipCG (1, CGB_XHaN))
      call AKGwaz
     M    (W (1, VMIW_W4),
     I     C,    X (1, KXR), WW,
     I     MH,   LH,   ipKW, CGB_XHaN_Lac, ipCG (1, CGB_XHaN))
CCC_    * [B3:b, B4:c] = [E:b, E:c] [B3:b, B4:c] = E <L> H
      call UV1uma (W,   QM, MH, LH,  VMIW_W3, VMQH_UEavb)
      call UV1uma (W,   QM, MH, LH,  VMIW_W4, VMQH_VEavc)
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
CCC_    * switch
      call UV1uma (W, QM, MH, LH,  VMIW_W1, VMQH_WXe)
      call UV1uma (W, QM, MH, LH,  VMIW_W2, VMQH_WYe)
CCC_    * X[L]:a   = B1:a + B2:a
      call UV2naa (X, W,  MH, LH, KXL, VMIW_W1, VMIW_W2)
CCC_   . U ([swFp, swFm] div:ab E:a H:a)
CCC_    * [B1:a, B2:a] = [Ex:a H:a, Ey:a H:a]
      call UV3nma (W, QM, X, MH, LH, VMIW_W1, VMQH_UEava, KXR)
      call UV3nma (W, QM, X, MH, LH, VMIW_W2, VMQH_VEava, KXR)
CCC_    * [B3:b, B4:c] = [<div_x> <div_y>] [B1:a, B2:a]
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
CCC_    * [B1:a]       = [Wp Wm]x [B3:b]
      call AKBuax
     O    (W,    C,
     I     QM,
     I     MH,   LH,  VMIW_W1,  VMIW_W3,  VMQH_WXp, VMQH_WXm,
     I     ipKW, iMA, KWO_Lba,  KSW)
CCC_    * [B2:a]       = [Wp Wm]y [B4:c]
      call AKBuax
     O    (W,    C,
     I     QM,
     I     MH,   LH,  VMIW_W2,  VMIW_W4,  VMQH_WYp, VMQH_WYm,
     I     ipKW, iMA, KWO_Lca,  KSW)
CCC_    * [B3 B4] switch
      do jp = 1, MH
         W(jp, VMIW_W3) =
     $        (1.0d0 - QM(jp, VMQH_WXd) - QM(jp, VMQH_WXe))
         W(jp, VMIW_W4) =
     $        (1.0d0 - QM(jp, VMQH_WYd) - QM(jp, VMQH_WYe))
      enddo
CCC_    * [B1 B2] *= switch
      call UV0uma (W, MH, LH, VMIW_W1, VMIW_W3)
      call UV0uma (W, MH, LH, VMIW_W2, VMIW_W4)
CCC_    * B3 = B1 + B2
      call UV0naa(W, MH, LH, VMIW_W3, VMIW_W1, VMIW_W2)
CCC_    * X[L]:a   = X[L]:a + U term
      call UV1uaa (X, W, MH, LH, KXL, VMIW_W3)
CCC_   . F  (E:a [swFp, swFm] grad:ab H:a)
CCC_    * [B1:b, B2:c] = <grad a:bc> H:a (clone group)
      call AKGwaz
     M    (W (1, VMIW_W1),
     I     C,    X (1, KXR), WW,
     I     MH,   LH,  ipKW, CGB_XHaN_GXab, ipCG (1, CGB_XHaN))
      call AKGwaz
     M    (W (1, VMIW_W2),
     I     C,    X (1, KXR), WW,
     I     MH,   LH,  ipKW, CGB_XHaN_GYac, ipCG (1, CGB_XHaN))
CCC_    * [B3:a]       = [Wp Wm]x [B1:b]
      call AKBuax
     O    (W,    C,
     I     QM,
     I     MH,   LH,  VMIW_W3,  VMIW_W1,  VMQH_WXp, VMQH_WXm,
     I     ipKW, iMA, KWO_Lba,  KSW)
CCC_    * [B4:a]       = [Wp Wm]y [B2:c]
      call AKBuax
     O    (W,    C,
     I     QM,
     I     MH,   LH,  VMIW_W4,  VMIW_W2,  VMQH_WYp, VMQH_WYm,
     I     ipKW, iMA, KWO_Lca,  KSW)
CCC_    * [B3:a, B4:a] = [Ex:a, Ey:a][B3, B4]
      call UV1uma (W, QM, MH, LH,  VMIW_W3, VMQH_UEava)
      call UV1uma (W, QM, MH, LH,  VMIW_W4, VMQH_VEava)
CCC_   . D  ((div:ba E:b) H:a)
CCC_    * [B1, B2] = (div E) H:a
      call UV3nma (W, QM, X, MH, LH, VMIW_W1, VMQH_xDIVu, KXR)
      call UV3nma (W, QM, X, MH, LH, VMIW_W2, VMQH_yDIVv, KXR)
CCC_   . DF
CCC_    * [B1, B2] = [B1,B2] (D) + [B3,B4] (F)
      call UV0uaa (W,   MH, LH,  VMIW_W1, VMIW_W3)
      call UV0uaa (W,   MH, LH,  VMIW_W2, VMIW_W4)
CCC_    * switch
      call UV1uma (W, QM, MH, LH,  VMIW_W1, VMQH_WXd)
      call UV1uma (W, QM, MH, LH,  VMIW_W2, VMQH_WYd)
CCC_    * B3 = B1 + B2
      call UV0naa(W, MH, LH, VMIW_W3, VMIW_W1, VMIW_W2)
CCC_    * X[L]:a   = X[L]:a + DF term
      call UV1uaa (X, W, MH, LH, KXL, VMIW_W3)
CCC_   . X[L]:a   = X[L]:a * Mask
      call UV1uma (X,   QM, MH, LH,  KXL, VMQH_MSK)
CCC_   + X[L]:a   = X[L]:a + f0 * X[R]:a
      call UV0ufa (X, MH, LH,  KXL, KXR,   F0)
      RETURN
      END
CCC_ & MMHmts  ## Movement/matrix multiplication suite (transpose)
      subroutine MMHmts
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
CCC_   + B1 = Mask * X[R]:a
      call UV3nma (W, QM, X, MH, LH, VMIW_W1, VMQH_MSK, KXR)
CCC_   . E   ([L:ab E:b div:ba] swE)
CCC_    * [B2 B3] = swE B1
      call UV1nma (W, QM, MH, LH, VMIW_W2, VMIW_W1, VMQH_WXe)
      call UV1nma (W, QM, MH, LH, VMIW_W3, VMIW_W1, VMQH_WYe)
CCC_    * [B4 B5] = div:ba T [B2 B3]
      call AKBwax
     O    (W,    C,
     I     WW,
     I     MH,   LH,  VMIW_W4, VMIW_W2,
     I     ipKW, iMA, KWO_DXba, KSW)
      call AKBwax
     O    (W,    C,
     I     WW,
     I     MH,   LH,  VMIW_W5, VMIW_W3,
     I     ipKW, iMA, KWO_DYca, KSW)
CCC_    * [B4 B5] = E:bc [B4 B5]
      call UV1uma (W,   QM, MH, LH,  VMIW_W4, VMQH_UEavb)
      call UV1uma (W,   QM, MH, LH,  VMIW_W5, VMQH_VEavc)
CCC_    * [B2 B3] = L:ab [B4 B5]
      call AKBwax
     O    (W,    C,
     I     WW,
     I     MH,   LH,  VMIW_W2, VMIW_W4,
     I     ipKW, iMA, KWO_Lab,  KSW)
      call AKBwax
     O    (W,    C,
     I     WW,
     I     MH,   LH,  VMIW_W3, VMIW_W5,
     I     ipKW, iMA, KWO_Lac,  KSW)
CCC_    * X[L]:a = (B2:a + B3:a)
      call UV2naa (X, W,  MH, LH, KXL, VMIW_W2, VMIW_W3)
CCC_   . U   ([E:a  div:ab] [swFp, swFm]:ba (1-swE-swD))
CCC_    * [B2] = swU
      do jp = 1, MH
         W(jp, VMIW_W2) =
     $        (1.0d0 - QM(jp, VMQH_WXd) - QM(jp, VMQH_WXe))
      enddo
CCC_    * [B2] = [B2] B1
      call UV0uma (W, MH, LH, VMIW_W2, VMIW_W1)
CCC_    * B3 = [swFp swFm]:ba T
      call AKBtax
     M    (W,    C,
     I     QM,
     I     MH,   LH,  VMIW_W3, VMIW_W2, VMQH_WXp, VMQH_WXm,
     I     VMIW_W5, VMIW_W6,
     I     ipKW, iMA, KWO_Lba, KSW)
CCC_    * [B2] = swU
      do jp = 1, MH
         W(jp, VMIW_W2) =
     $        (1.0d0 - QM(jp, VMQH_WYd) - QM(jp, VMQH_WYe))
      enddo
CCC_    * [B2] = [B2] B1
      call UV0uma (W, MH, LH, VMIW_W2, VMIW_W1)
CCC_    * B4 = [swFp swFm]:ca T
      call AKBtax
     M    (W,    C,
     I     QM,
     I     MH,   LH,  VMIW_W4, VMIW_W2, VMQH_WYp, VMQH_WYm,
     I     VMIW_W5, VMIW_W6,
     I     ipKW, iMA, KWO_Lca, KSW)
CCC_    * B2 = Div:ab T B3
      call AKBwax
     O    (W,    C,
     I     WW,
     I     MH,   LH,  VMIW_W2,  VMIW_W3,
     I     ipKW, iMA, KWO_DXab, KSW)
CCC_    * B3 = Div:ac T B4
      call AKBwax
     O    (W,    C,
     I     WW,
     I     MH,   LH,  VMIW_W3,  VMIW_W4,
     I     ipKW, iMA, KWO_DYac, KSW)
CCC_    * B2 *= U
      call UV1uma (W, QM, MH, LH, VMIW_W2, VMQH_UEava)
CCC_    * B3 *= V
      call UV1uma (W, QM, MH, LH, VMIW_W3, VMQH_VEava)
CCC_    * B4 = B2 + B3
      call UV0naa(W, MH, LH, VMIW_W4, VMIW_W2, VMIW_W3)
CCC_    * X[L]:a   = X[L]:a + U term
      call UV1uaa (X, W, MH, LH, KXL, VMIW_W4)
CCC_   . F   ([grad:ab]     [swFp, swFm]:ba E:a   swD)
CCC_    * [B2] = swD B1  kept
      call UV1nma (W, QM, MH, LH, VMIW_W2, VMIW_W1, VMQH_WXd)
CCC_    * [B3] = E:a [B2]
      call UV1nma (W, QM, MH, LH, VMIW_W3, VMIW_W2, VMQH_UEava)
CCC_    * B4 = [swFp, swFm]:ba T B3
      call AKBtax
     M    (W,    C,
     I     QM,
     I     MH,   LH,  VMIW_W4, VMIW_W3, VMQH_WXp, VMQH_WXm,
     I     VMIW_W6, VMIW_W7,
     I     ipKW, iMA, KWO_Lba, KSW)
CCC_    * [B3] = swD B1  kept, B1 final
      call UV1nma (W, QM, MH, LH, VMIW_W3, VMIW_W1, VMQH_WYd)
CCC_    * [B1] = E:a [B3]
      call UV1nma (W, QM, MH, LH, VMIW_W1, VMIW_W3, VMQH_VEava)
CCC_    * B5 = [swFp, swFm]:ca T B1
      call AKBtax
     M    (W,    C,
     I     QM,
     I     MH,   LH,  VMIW_W5, VMIW_W1, VMQH_WYp, VMQH_WYm,
     I     VMIW_W6, VMIW_W7,
     I     ipKW, iMA, KWO_Lca, KSW)
CCC_    * B6 = grad:ab T B4
      call AKBwax
     O    (W,    C,
     I     WW,
     I     MH,   LH,  VMIW_W6,  VMIW_W4,
     I     ipKW, iMA, KWO_GXab, KSW)
CCC_    * B7 = grad:ac T B5
      call AKBwax
     O    (W,    C,
     I     WW,
     I     MH,   LH,  VMIW_W7,  VMIW_W5,
     I     ipKW, iMA, KWO_GYac, KSW)
CCC_    * B1 = B6 + B7
      call UV0naa(W, MH, LH, VMIW_W1, VMIW_W6, VMIW_W7)
CCC_   . D   ({div:ba E:b} swD)
CCC_    * (div E) [B2, B3]
      call UV1uma (W, QM, MH, LH, VMIW_W2, VMQH_xDIVu)
      call UV1uma (W, QM, MH, LH, VMIW_W3, VMQH_yDIVv)
CCC_    * B4 = B2 + B3
      call UV0naa(W, MH, LH, VMIW_W4, VMIW_W2, VMIW_W3)
CCC_   . DF
      call UV0uaa(W, MH, LH, VMIW_W1, VMIW_W4)
CCC_    * X[L]:a   = X[L]:a + DF term
      call UV1uaa (X, W, MH, LH, KXL, VMIW_W1)
CCC_   + X[L]:a   = X[L]:a + f0 * X[R]:a
      call UV0ufa (X, MH, LH,  KXL, KXR,   F0)
      RETURN
      END
CCC_ & MMHsns  ## Movement/matrix solver
      subroutine MMHsns
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
CCC_ & MMHsts  ## Movement/matrix solver (transpose)
      subroutine MMHsts
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
CCC_* Continuity preparation
CCC_ & MMHwpr  ## preparation for vertical velocity
      subroutine MMHwpr
     O    (iErr,
     O     VMTW,  WH,    CW,
     I     VMI,   VMC,   VMTI,  QM,   F0,
     I     WW,    WZV,
     I     MH,    LH,    NZ,    LZ,   KZ0,
     I     ipCG,  LCG,   ipKW,  iMA,  MSW)
CCC_  - Description
CC
CC    Assumption: ub==ui==0 when int ue==0
CC
CCC_  * Declaration
      implicit none
c
      _INTENT(OUT,  integer)  iErr
c
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
      _INTENT(IN,   integer)  LCG
c
      _INTENT(INOUT,_REALSTD) VMTW (LH, LZ, *)
      _INTENT(OUT,  _REALSTD) CW   (LH, LZ, *)
      _INTENT(OUT,  _REALSTD) WH   (LH, *)
c
      _INTENT(IN,   _REALSTD) VMI  (LH, *)
      _INTENT(IN,   _REALSTD) VMC  (LH, *)
      _INTENT(IN,   _REALSTD) VMTI (LH, LZ, *)
      _INTENT(IN,   _REALSTD) QM   (LH, *)
      _INTENT(IN,   _REALSTD) F0
c
      _INTENT(IN,   _REALSTD) WW   (*)
      _INTENT(IN,   _REALSTD) WZV  (LZ, *)
      _INTENT(IN,   integer)  ipKW (*), iMA (*)
      _INTENT(IN,   integer)  ipCG (LCG, *)
c
      _INTENT(IN,   integer)  MSW
c
      integer jh, jz, jz0, jzb, jzs
c
      integer jwFC
      integer KUGXH, KUGYH
      integer KUGXB, KUGYB
      integer KSW
CCC_  * Body
      iErr = 0
      KUGXH = VMIW_W3
      KUGYH = VMIW_W4
      KUGXB = VMIW_W5
      KUGYB = VMIW_W6
      KSW   = KWM_M
CCC_   . H upwind gradient
      call AKCgux
     O    (CW,
     I     VMC,  MH,   LH,  VMC_NHa,
     I     iMA,  ipCG (1, CGB_XHaN))
CCC_    * [B1:b, B2:c] = <grad a:bc> H:a (clone group)
      call AKGwaz
     M    (WH (1, VMIW_W1),
     I     CW,   VMC (1, VMC_NHa), WW,
     I     MH,   LH,  ipKW, CGB_XHaN_GXab, ipCG (1, CGB_XHaN))
      call AKGwaz
     M    (WH (1, VMIW_W2),
     I     CW,   VMC (1, VMC_NHa), WW,
     I     MH,   LH,  ipKW, CGB_XHaN_GYac, ipCG (1, CGB_XHaN))
CCC_    * [B3:a]       = [Wp Wm]x [B1:b]
      call AKBuax
     O    (WH,   CW,
     I     QM,
     I     MH,   LH,  KUGXH,    VMIW_W1,  VMQH_WXp, VMQH_WXm,
     I     ipKW, iMA, KWO_Lba,  KSW)
CCC_    * [B4:a]       = [Wp Wm]y [B2:c]
      call AKBuax
     O    (WH,   CW,
     I     QM,
     I     MH,   LH,  KUGYH,    VMIW_W2,  VMQH_WYp, VMQH_WYm,
     I     ipKW, iMA, KWO_Lca,  KSW)
CCC_   . B upwind gradient
      call AKCgux
     O    (CW,
     I     VMC,  MH,   LH,  VMC_NBa,
     I     iMA,  ipCG (1, CGB_XHaN))
CCC_    * [B1:b, B2:c] = <grad a:bc> B:a (clone group)
      call AKGwaz
     M    (WH (1, VMIW_W1),
     I     CW,   VMC (1, VMC_NBa), WW,
     I     MH,   LH,  ipKW, CGB_XHaN_GXab, ipCG (1, CGB_XHaN))
      call AKGwaz
     M    (WH (1, VMIW_W2),
     I     CW,   VMC (1, VMC_NBa), WW,
     I     MH,   LH,  ipKW, CGB_XHaN_GYac, ipCG (1, CGB_XHaN))
CCC_    * [B5:a]       = [Wp Wm]x [B1:b]
      call AKBuax
     O    (WH,   CW,
     I     QM,
     I     MH,   LH,  KUGXB,    VMIW_W1,  VMQH_WXp, VMQH_WXm,
     I     ipKW, iMA, KWO_Lba,  KSW)
CCC_    * [B6:a]       = [Wp Wm]y [B2:c]
      call AKBuax
     O    (WH,   CW,
     I     QM,
     I     MH,   LH,  KUGYB,    VMIW_W2,  VMQH_WYp, VMQH_WYm,
     I     ipKW, iMA, KWO_Lca,  KSW)
CCC_   . -P1 term
      call MMHdvv
     O    (iErr,
     O     VMTW,  CW,
     I     VMI,   VMC,   VMTI,  QM,    F0,
     I     WW,    WZV,
     I     WH,    KUGXH, KUGYH, KUGXB, KUGYB,
     I     MH,    LH,    NZ,    LZ,    KZ0,
     I     ipCG,  LCG,   ipKW,  iMA,   MSW)
CCC_   . P2+P3 term
      call MMHdvb
     O    (iErr,
     O     VMTW,  CW,
     I     VMI,   VMC,   VMTI,  QM,    F0,
     I     WW,    WZV,
     I     WH,    KUGXH, KUGYH, KUGXB, KUGYB,
     I     MH,    LH,    NZ,    LZ,    KZ0,
     I     ipCG,  LCG,   ipKW,  iMA,   MSW)
      RETURN
      END
CCC_ & MMHdvv  ## preparation for vertical velocity (div integral v terms)
      subroutine MMHdvv
     O    (iErr,
     O     VMTW,  CW,
     I     VMI,   VMC,   VMTI,  QM,    F0,
     I     WW,    WZV,
     I     WH,    KUGXH, KUGYH, KUGXB, KUGYB,
     I     MH,    LH,    NZ,    LZ,    KZ0,
     I     ipCG,  LCG,   ipKW,  iMA,   MSW)
CCC_  * Declaration
      implicit none
c
      _INTENT(OUT,  integer)  iErr
c
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
      _INTENT(IN,   integer)  LCG
c
      _INTENT(INOUT,_REALSTD) VMTW (LH, LZ, *)
      _INTENT(OUT,  _REALSTD) CW   (LH, LZ, *)
c
      _INTENT(IN,   _REALSTD) VMI  (LH, *)
      _INTENT(IN,   _REALSTD) VMC  (LH, *)
      _INTENT(IN,   _REALSTD) VMTI (LH, LZ, *)
      _INTENT(IN,   _REALSTD) QM   (LH, *)
      _INTENT(IN,   _REALSTD) F0
c
      _INTENT(IN,   _REALSTD) WH   (LH, *)
      _INTENT(IN,   integer)  KUGXH, KUGYH
      _INTENT(IN,   integer)  KUGXB, KUGYB
c
      _INTENT(IN,   _REALSTD) WW   (*)
      _INTENT(IN,   _REALSTD) WZV  (LZ, *)
      _INTENT(IN,   integer)  ipKW (*), iMA (*)
      _INTENT(IN,   integer)  ipCG (LCG, *)
c
      _INTENT(IN,   integer)  MSW
c
      integer KSW
      integer jh, jz, jz0, jzb, jzs
      integer jwFC
CCC_  * Body
      iErr = 0
      KSW  = KWM_M
      jzb  = KZ0
CCC_   . UE:b
CCC_    * W[12] :: UE:b int dzeta ui + zeta ub (on b)
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_W1)
     $           = VMTW (jh, jz, VMTW_ziUIb)
     $           + WZV (jz, VMVZ_Za) * VMTI (jh, jzb, VMTI_UHb)
            VMTW (jh, jz, VMTW_W2)
     $           = VMTW (jh, jz, VMTW_ziVIc)
     $           + WZV (jz, VMVZ_Za) * VMTI (jh, jzb, VMTI_VHc)
         enddo
      enddo
CCC_   . E (div:ba UE:b H:b)
CCC_    * W[45] :: Hb UE:b
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_W4)
     $           = VMTW (jh, jz, VMTW_W1) * VMC(jh, VMC_NHb)
            VMTW (jh, jz, VMTW_W5)
     $           = VMTW (jh, jz, VMTW_W2) * VMC(jh, VMC_NHc)
         enddo
      enddo
CCC_    * W3 :: div W[45]
      call AKBwaw
     O    (VMTW, CW,
     I     WW,
     I     MH,   LH,  NZ, LZ,   KZ0, VMTW_W3x, VMTW_W4,
     I     ipKW, iMA, KWO_DXba, KWM_M)
      call AKBwaw
     O    (VMTW, CW,
     I     WW,
     I     MH,   LH,  NZ, LZ,   KZ0, VMTW_W3y, VMTW_W5,
     I     ipKW, iMA, KWO_DYca, KWM_M)
CCC_    * final/i with switch
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_divHziue)
     $           = (VMTW(jh, jz, VMTW_W3x) * QM(jh, VMQH_WXe)
     $             +VMTW(jh, jz, VMTW_W3y) * QM(jh, VMQH_WYe))
         enddo
      enddo
CCC_   . F  (UE:a [swFp, swFm] grad:ab H:a)
CCC_    * clone group
      call AKCguw
     O    (CW,
     I     VMTW,  MH, LH, NZ, LZ, KZ0, VMTW_W1,
     I     iMA,  ipCG (1, CGHV_Ub))
CCC_    * W[45] UE:a kept for U
      call AKGwaw
     M    (VMTW,
     I     CW,   WW,
     I     MH,   LH,  NZ,  LZ, KZ0, VMTW_W4, VMTW_W1,
     I     ipKW, CGHV_Ub_Lba, ipCG (1, CGHV_Ub))
CCC_    * W3    div UE:b
      call AKGwaw
     M    (VMTW,
     I     CW,   WW,
     I     MH,   LH,  NZ,  LZ, KZ0, VMTW_W3x, VMTW_W1,
     I     ipKW, CGHV_Ub_DXba, ipCG (1, CGHV_Ub))
CCC_    * clone group
      call AKCguw
     O    (CW,
     I     VMTW,  MH, LH, NZ, LZ, KZ0, VMTW_W2,
     I     iMA,  ipCG (1, CGHV_Vc))
CCC_    * W[45] UE:a
      call AKGwaw
     M    (VMTW,
     I     CW,   WW,
     I     MH,   LH,  NZ,  LZ, KZ0, VMTW_W5, VMTW_W2,
     I     ipKW, CGHV_Vc_Lca, ipCG (1, CGHV_Vc))
CCC_    * W4    div VE:c
      call AKGwaw
     M    (VMTW,
     I     CW,   WW,
     I     MH,   LH,  NZ,  LZ, KZ0, VMTW_W3y, VMTW_W2,
     I     ipKW, CGHV_Vc_DYca, ipCG (1, CGHV_Vc))
CCC_    * no more necessary W1, W2
CCC_   . D ((div:ba UE:b) H:a) plus F
CCC_    * W3 :: (div U) H
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_W3x)
     $           = VMTW (jh, jz, VMTW_W3x) * VMC(jh, VMC_NHa)
            VMTW (jh, jz, VMTW_W3y)
     $           = VMTW (jh, jz, VMTW_W3y) * VMC(jh, VMC_NHa)
         enddo
      enddo
CCC_    * W3 :: plus F switched
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_W3x) =
     $           VMTW (jh, jz, VMTW_W3x)
     $           + VMTW (jh, jz, VMTW_W4) * WH(jh, KUGXH)
            VMTW (jh, jz, VMTW_W3y) =
     $           VMTW (jh, jz, VMTW_W3y)
     $           + VMTW (jh, jz, VMTW_W5) * WH(jh, KUGYH)
         enddo
      enddo
CCC_    * W1 :: D + F switch (keep)
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW(jh, jz, VMTW_W1)
     $           = VMTW(jh, jz, VMTW_W3x) * QM(jh, VMQH_WXd)
     $           + VMTW(jh, jz, VMTW_W3y) * QM(jh, VMQH_WYd)
         enddo
      enddo
CCC_   . U ([swFp, swFm] div:ab UE:a H:a)
CCC_    * W[45] UE:a H:a
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_W4)
     $           = VMTW (jh, jz, VMTW_W4) * VMC(jh, VMC_NHa)
            VMTW (jh, jz, VMTW_W5)
     $           = VMTW (jh, jz, VMTW_W5) * VMC(jh, VMC_NHa)
         enddo
      enddo
CCC_    * W3 :: div
      call MMHudu
     O    (VMTW,  VMTW_W3x, VMTW_W4, VMTW_W2,
     W     CW,
     I     QM,           WW,
     I     KWO_DXab,     KWO_Lba,
     I     VMQH_WXp,     VMQH_WXm,
     I     MH,    LH,    NZ,    LZ,   KZ0,
     I     ipKW,  iMA)
      call MMHudu
     O    (VMTW,  VMTW_W3y, VMTW_W5, VMTW_W2,
     W     CW,
     I     QM,           WW,
     I     KWO_DYac,     KWO_Lca,
     I     VMQH_WYp,     VMQH_WYm,
     I     MH,    LH,    NZ,    LZ,   KZ0,
     I     ipKW,  iMA)
CCC_    * W2 :: U switch
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW(jh, jz, VMTW_W2)
     $           = VMTW(jh, jz, VMTW_W3x)
     $           * (1.0d0 - QM(jh, VMQH_WXd)-QM(jh, VMQH_WXe))
     $           + VMTW(jh, jz, VMTW_W3y)
     $           * (1.0d0 - QM(jh, VMQH_WYd)-QM(jh, VMQH_WYe))
         enddo
      enddo
CCC_   . Final
      call UV0uac
     $    (VMTW,
     $     MH, LH, NZ, LZ, KZ0, VMTW_divHziue, VMTW_W2)
      call UV0uac
     $    (VMTW,
     $     MH, LH, NZ, LZ, KZ0, VMTW_divHziue, VMTW_W1)
CCC_    * final/b
      do jh = 1, MH
         VMTW (jh, jzb, VMTW_divHziue) = 0.0d0
      enddo
      RETURN
      END
CCC_ & MMHdvb  ## preparation for vertical velocity (div vh terms)
      subroutine MMHdvb
     O    (iErr,
     O     VMTW,  CW,
     I     VMI,   VMC,   VMTI,  QM,    F0,
     I     WW,    WZV,
     I     WH,    KUGXH, KUGYH, KUGXB, KUGYB,
     I     MH,    LH,    NZ,    LZ,    KZ0,
     I     ipCG,  LCG,   ipKW,  iMA,   MSW)
CCC_  * Declaration
      implicit none
c
      _INTENT(OUT,  integer)  iErr
c
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
      _INTENT(IN,   integer)  LCG
c
      _INTENT(INOUT,_REALSTD) VMTW (LH, LZ, *)
      _INTENT(OUT,  _REALSTD) CW   (LH, LZ, *)
c
      _INTENT(IN,   _REALSTD) VMI  (LH, *)
      _INTENT(IN,   _REALSTD) VMC  (LH, *)
      _INTENT(IN,   _REALSTD) VMTI (LH, LZ, *)
      _INTENT(IN,   _REALSTD) QM   (LH, *)
      _INTENT(IN,   _REALSTD) F0

      _INTENT(IN,   _REALSTD) WH   (LH, *)
      _INTENT(IN,   integer)  KUGXH, KUGYH
      _INTENT(IN,   integer)  KUGXB, KUGYB
c
      _INTENT(IN,   _REALSTD) WW   (*)
      _INTENT(IN,   _REALSTD) WZV  (LZ, *)
      _INTENT(IN,   integer)  ipKW (*), iMA (*)
      _INTENT(IN,   integer)  ipCG (LCG, *)
c
      _INTENT(IN,   integer)  MSW
c
      integer KSW
      integer jh, jz, jz0, jzb, jzs
      integer jwFC
CCC_  * Body
      iErr = 0
      KSW  = KWM_M
      jzb  = KZ0
CCC_   . W[45] :: div uh
      call AKBway
     O    (VMTW (1,1,VMTW_W4),  CW,
     I     VMTI (1,1,VMTI_UHb), WW,
     I     MH,   LH,  NZ, LZ,   KZ0,
     I     ipKW, iMA, KWO_DXba, KWM_M)
      call AKBway
     O    (VMTW (1,1,VMTW_W5),  CW,
     I     VMTI (1,1,VMTI_VHc), WW,
     I     MH,   LH,  NZ, LZ,   KZ0,
     I     ipKW, iMA, KWO_DYca, KWM_M)
CCC_   . E   div:ba [ui:b z:b + ZZ ub:b H:b] - (z:a div:ba ui:b + ZZ H:a div:ba ub:b)
CCC_    * ui:b Znew:b
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_W1)
     $           = VMTI (jh, jz, VMTI_UHb)
     $           * (VMC(jh,VMC_NBb) + WZV(jz,VMVZ_Za) * VMC(jh,VMC_NHb))
            VMTW (jh, jz, VMTW_W2)
     $           = VMTI (jh, jz, VMTI_VHc)
     $           * (VMC(jh,VMC_NBc) + WZV(jz,VMVZ_Za) * VMC(jh,VMC_NHc))
         enddo
      enddo
CCC_    * ui:b Znew:b + zeta ub H:new:b
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_W1)
     $           = VMTW (jh, jz, VMTW_W1)
     $           + WZV (jz, VMVZ_Za) * VMTI (jh, jzb, VMTI_UHb)
     $             * VMC(jh,VMC_NHb)
            VMTW (jh, jz, VMTW_W2)
     $           = VMTW (jh, jz, VMTW_W2)
     $           + WZV (jz, VMVZ_Za) * VMTI (jh, jzb, VMTI_VHc)
     $             * VMC(jh,VMC_NHc)
         enddo
      enddo
CCC_    * bottom: overwrite with ub bnew:b
      jz = jzb
      do jh = 1, MH
         VMTW (jh, jz, VMTW_W1)
     $        = VMTI (jh, jz, VMTI_UHb) * VMC (jh, VMC_NBb)
         VMTW (jh, jz, VMTW_W2)
     $        = VMTI (jh, jz, VMTI_VHc) * VMC (jh, VMC_NBc)
      enddo
CCC_    * W3 div
      call AKBwaw
     O    (VMTW, CW,
     I     WW,
     I     MH,   LH,  NZ, LZ,   KZ0, VMTW_W3x, VMTW_W1,
     I     ipKW, iMA, KWO_DXba, KWM_M)
      call AKBwaw
     O    (VMTW, CW,
     I     WW,
     I     MH,   LH,  NZ, LZ,   KZ0, VMTW_W3y, VMTW_W2,
     I     ipKW, iMA, KWO_DYca, KWM_M)
CCC_    * W3 :: W3 - (Znew:a div ui + zeta H:new div ub)
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_W3x)
     $           = VMTW (jh, jz, VMTW_W3x)
     $           - (+ VMTW (jh, jz, VMTW_W4)
     $              * (VMC(jh,VMC_NBa)+WZV(jz,VMVZ_Za)*VMC(jh,VMC_NHa))
     $              + VMTW (jh, jzb, VMTW_W4)
     $              * (               +WZV(jz,VMVZ_Za)*VMC(jh,VMC_NHa)))
            VMTW (jh, jz, VMTW_W3y)
     $           = VMTW (jh, jz, VMTW_W3y)
     $           - (+ VMTW (jh, jz, VMTW_W5)
     $              * (VMC(jh,VMC_NBa)+WZV(jz,VMVZ_Za)*VMC(jh,VMC_NHa))
     $              + VMTW (jh, jzb, VMTW_W5)
     $              * (               +WZV(jz,VMVZ_Za)*VMC(jh,VMC_NHa)))
         enddo
      enddo
CCC_    * bottom: d1 - b:new div ub
      jz = jzb
      do jh = 1, MH
         VMTW (jh, jz, VMTW_W3x)
     $        = VMTW (jh, jz, VMTW_W3x)
     $        - VMTW (jh, jzb, VMTW_W4) * VMC(jh,VMC_NBa)
         VMTW (jh, jz, VMTW_W3y)
     $        = VMTW (jh, jz, VMTW_W3y)
     $        - VMTW (jh, jzb, VMTW_W5) * VMC(jh,VMC_NBa)
      enddo
CCC_    * switch
      do jz0 = 0, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW(jh, jz, VMTW_ugradz)
     $           = VMTW(jh, jz, VMTW_W3x) * QM(jh, VMQH_WXe)
     $           + VMTW(jh, jz, VMTW_W3y) * QM(jh, VMQH_WYe)
         enddo
      enddo
CCC_   . U   upw div:ab [ui:a z:a + ZZ ub:a H:a] - (z:a upw div:ab ui:a + ZZ H:a upw div:ab ub:a)
CCC_    * ui:a Znew:a
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_W1)
     $           = VMTI (jh, jz, VMTI_UHa)
     $           * (VMC(jh,VMC_NBa) + WZV(jz,VMVZ_Za) * VMC(jh,VMC_NHa))
         enddo
      enddo
CCC_    * ui:a Znew:a + zeta ub H:new:a
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_W1)
     $           = VMTW (jh, jz, VMTW_W1)
     $           + WZV (jz, VMVZ_Za) * VMTI (jh, jzb, VMTI_UHa)
     $             * VMC(jh,VMC_NHa)
         enddo
      enddo
CCC_    * bottom: overwrite with ub bnew:b
      jz = jzb
      do jh = 1, MH
         VMTW (jh, jz, VMTW_W1)
     $        = VMTI (jh, jzb, VMTI_UHa) * VMC (jh, VMC_NBa)
      enddo
CCC_    * W3 :: upwind xdiv
      call MMHudu
     O    (VMTW,  VMTW_W3x, VMTW_W1, VMTW_W2,
     W     CW,
     I     QM,           WW,
     I     KWO_DXab,     KWO_Lba,
     I     VMQH_WXp,     VMQH_WXm,
     I     MH,    LH,    NZ,    LZ,   KZ0,
     I     ipKW,  iMA)
CCC_    * vi:a Znew:a
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_W1)
     $           = VMTI (jh, jz, VMTI_VHa)
     $           * (VMC(jh,VMC_NBa) + WZV(jz,VMVZ_Za) * VMC(jh,VMC_NHa))
         enddo
      enddo
CCC_    * vi:a Znew:a + zeta vb H:new:a
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_W1)
     $           = VMTW (jh, jz, VMTW_W1)
     $           + WZV (jz, VMVZ_Za) * VMTI (jh, jzb, VMTI_VHa)
     $             * VMC(jh,VMC_NHa)
         enddo
      enddo
CCC_    * bottom: overwrite with ub bnew:b
      jz = jzb
      do jh = 1, MH
         VMTW (jh, jz, VMTW_W1)
     $        = VMTI (jh, jzb, VMTI_VHa) * VMC (jh, VMC_NBa)
      enddo
CCC_    * W3 :: upwind ydiv
      call MMHudu
     O    (VMTW,  VMTW_W3y, VMTW_W1, VMTW_W2,
     W     CW,
     I     QM,           WW,
     I     KWO_DYac,     KWO_Lca,
     I     VMQH_WYp,     VMQH_WYm,
     I     MH,    LH,    NZ,    LZ,   KZ0,
     I     ipKW,  iMA)
CCC_    * W[12] :: upwind xdiv u
      call AKBway
     O    (VMTW (1,1,VMTW_W4),  CW,
     I     VMTI (1,1,VMTI_UHa), WW,
     I     MH,   LH,  NZ, LZ,   KZ0,
     I     ipKW, iMA, KWO_DXab, KWM_M)
      call AKBway
     O    (VMTW (1,1,VMTW_W5),  CW,
     I     VMTI (1,1,VMTI_VHa), WW,
     I     MH,   LH,  NZ, LZ,   KZ0,
     I     ipKW, iMA, KWO_DYac, KWM_M)
      call AKBuaw
     O    (VMTW, CW,
     I     QM,
     I     MH,   LH,  NZ,  LZ,  KZ0,
     I     VMTW_W1,   VMTW_W4,  VMQH_WXp, VMQH_WXm,
     I     ipKW, iMA, KWO_Lba,  KSW)
      call AKBuaw
     O    (VMTW, CW,
     I     QM,
     I     MH,   LH,  NZ,  LZ,  KZ0,
     I     VMTW_W2,   VMTW_W5,  VMQH_WYp, VMQH_WYm,
     I     ipKW, iMA, KWO_Lca,  KSW)
CCC_    * W3 :: W3 - (z udiv ui + zeta H udiv ub)
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_W3x)
     $           = VMTW (jh, jz, VMTW_W3x)
     $           - (+ VMTW (jh, jz, VMTW_W1)
     $              * (VMC(jh,VMC_NBa)+WZV(jz,VMVZ_Za)*VMC(jh,VMC_NHa))
     $              + VMTW (jh, jzb, VMTW_W1)
     $              * (               +WZV(jz,VMVZ_Za)*VMC(jh,VMC_NHa)))
            VMTW (jh, jz, VMTW_W3y)
     $           = VMTW (jh, jz, VMTW_W3y)
     $           - (+ VMTW (jh, jz, VMTW_W2)
     $              * (VMC(jh,VMC_NBa)+WZV(jz,VMVZ_Za)*VMC(jh,VMC_NHa))
     $              + VMTW (jh, jzb, VMTW_W2)
     $              * (               +WZV(jz,VMVZ_Za)*VMC(jh,VMC_NHa)))
         enddo
      enddo
CCC_    * bottom
      jz = jzb
      do jh = 1, MH
         VMTW (jh, jz, VMTW_W3x)
     $        = VMTW (jh, jz, VMTW_W3x)
     $        - VMTW (jh, jzb, VMTW_W1) *VMC(jh,VMC_NBa)
         VMTW (jh, jz, VMTW_W3y)
     $        = VMTW (jh, jz, VMTW_W3y)
     $        - VMTW (jh, jzb, VMTW_W2) *VMC(jh,VMC_NBa)
      enddo
CCC_    * switch
      do jz0 = 0, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW(jh, jz, VMTW_W1)
     $           = VMTW(jh, jz, VMTW_W3x)
     $           * (1.0d0 - QM(jh, VMQH_WXd)-QM(jh, VMQH_WXe))
     $           + VMTW(jh, jz, VMTW_W3y)
     $           * (1.0d0 - QM(jh, VMQH_WYd)-QM(jh, VMQH_WYe))
         enddo
      enddo
CCC_    * final
      call UV0uac (VMTW, MH,LH,NZ,LZ,KZ0, VMTW_ugradz,VMTW_W1)
CCC_   . DF  ui:a [ZZ upw grad:ab H:a + upw grad:ab b:a] + ZZ ub:a upw grad:ab H:a
CCC_    * W3 ui grad H
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_W3x)
     $           = VMTI (jh, jz, VMTI_UHa)
     $           * (WH(jh,KUGXB) + WZV(jz,VMVZ_Za) * WH(jh,KUGXH))
            VMTW (jh, jz, VMTW_W3y)
     $           = VMTI (jh, jz, VMTI_VHa)
     $           * (WH(jh,KUGYB) + WZV(jz,VMVZ_Za) * WH(jh,KUGYH))
         enddo
      enddo
CCC_    * W3 plus zeta ub grad H
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_W3x)
     $           = VMTW (jh, jz, VMTW_W3x)
     $           + VMTI (jh, jzb, VMTI_UHa)
     $           * (WZV(jz,VMVZ_Za) * WH(jh,KUGXH))
            VMTW (jh, jz, VMTW_W3y)
     $           = VMTW (jh, jz, VMTW_W3y)
     $           + VMTI (jh, jzb, VMTI_VHa)
     $           * (WZV(jz,VMVZ_Za) * WH(jh,KUGYH))
         enddo
      enddo
CCC_    * bottom ub:a ugrad b:a
      jz = jzb
      do jh = 1, MH
         VMTW (jh, jz, VMTW_W3x)
     $        = VMTI (jh, jzb, VMTI_UHa) * WH(jh,KUGXB)
         VMTW (jh, jz, VMTW_W3y)
     $        = VMTI (jh, jzb, VMTI_VHa) * WH(jh,KUGYB)
      enddo
CCC_    * switch
      do jz0 = 0, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW(jh, jz, VMTW_W1)
     $           = VMTW(jh, jz, VMTW_W3x) * QM(jh, VMQH_WXd)
     $           + VMTW(jh, jz, VMTW_W3y) * QM(jh, VMQH_WYd)
         enddo
      enddo
CCC_    * final
      call UV0uac (VMTW, MH,LH,NZ,LZ,KZ0, VMTW_ugradz,VMTW_W1)
      RETURN
      END
CCC_ & MMHudu  ## upwind divergence
      subroutine MMHudu
     O    (VW,    KVWo,  KVWi,  KVWw,
     W     CW,
     I     QM,    WW,
     I     KOPD,  KOPL,  KQp,   KQm,
     I     MH,    LH,    NZ,    LZ,   KZ0,
     I     ipKW,  iMA)
CCC_  * Declaration
      implicit none
c
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
c
      _INTENT(INOUT,_REALSTD) VW   (LH, LZ, *)
      _INTENT(OUT,  _REALSTD) CW   (LH, LZ, *)
      _INTENT(IN,   _REALSTD) QM   (LH, *)
c
      _INTENT(IN,   integer)  KVWo, KVWi, KVWw
      _INTENT(IN,   integer)  KOPD, KOPL
      _INTENT(IN,   integer)  KQp,  KQm
c
      _INTENT(IN,   _REALSTD) WW   (*)
      _INTENT(IN,   integer)  ipKW (*), iMA (*)
CCC_  * body
      call AKBwaw
     O    (VW,   CW,
     I     WW,
     I     MH,   LH,  NZ, LZ, KZ0,   KVWw, KVWi,
     I     ipKW, iMA, KOPD,   KWM_M)
      call AKBuaw
     O    (VW,   CW,
     I     QM,
     I     MH,   LH,   NZ,   LZ,  KZ0,
     I     KVWo, KVWw, KQp,  KQm,
     I     ipKW, iMA,  KOPL, KWM_M)
      return
      END
CCC_* Declaration
CCC_ & MMHdec  ## Movement/matrix operators kiwi declaration
      subroutine MMHdec
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
CCC_ & MMHcgs  ## Movement/matrix clone group declaration
      subroutine MMHcgs
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
      integer kv, ko
CCC_  * Body
      iErr = 0
      kv   = 0
CCC_   . group Ub
      if (iErr.eq.0) then
         kv = CGHV_Ub
c        ko 0 for one-time cloning
         ko = 1
         call AKCgro (iErr, ipCG (1, kv), LCG, ko)
         call AKCgad (iErr, ipCG (1, kv), KWO_DXba,  KWM_M, LCG)
         call AKCgad (iErr, ipCG (1, kv), KWO_Lba,   KWM_M, LCG)
         call AKCgad (iErr, ipCG (1, kv), KWO_FCba,  KWM_M, LCG)
         call AKCgso
     O       (iErr, ko,   ipCG (1, kv), KDTA,
     I        LCG,  LTBL, LH,           ipKW, IE, IFP)
      endif
CCC_   . group Vc
      if (iErr.eq.0) then
         kv = CGHV_Vc
c        ko 0 for one-time cloning
         ko = 1
         call AKCgro (iErr, ipCG (1, kv), LCG, ko)
         call AKCgad (iErr, ipCG (1, kv), KWO_DYca,  KWM_M, LCG)
         call AKCgad (iErr, ipCG (1, kv), KWO_Lca,   KWM_M, LCG)
         call AKCgad (iErr, ipCG (1, kv), KWO_FCca,  KWM_M, LCG)
         call AKCgso
     O       (iErr, ko,   ipCG (1, kv), KDTA,
     I        LCG,  LTBL, LH,           ipKW, IE, IFP)
      endif
CCC_   + report
      call DAtrcU (IFP, iErr, 'R', 'MMHCGS')
      RETURN
      END
CCC_& MMHEUD  ## Movement/matrix/variation H announcement
      subroutine MMHEUD (STRA, STRB, IOP)
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
CCC_ @ MMHEUD  ## test program
#ifdef  TEST_MMHEUD
#include "ofnstd.h"
#include "odevid.h"
      program MMHTST
CCC_  - Test suites
CC::   SOURCES mifunc.F mibakw.F:TEST_MIBAKW_SUB=1 mmxoms.F:TEST_MMXOMS_SUB=1
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
         call MMHtestMain (iErr, ipA, iMA)
         call ACCrep (FPL(ipA), 0)
      endif
      call DevFin (iErr)
      STOP
      END
CCC_ & MMHtestMain   ## main
      subroutine MMHtestMain (iErr, ipA, iMA)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(IN, integer) ipA (*)
      _INTENT(IN, integer) iMA (*)
CCC_  - Body
      RETURN
      END
#endif /* TEST_MMHEUD */
CCC_* obsolete
CCC_ + begin
#if 0 /* obsolete */
CCC_ + end
#endif /* 0 */
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
