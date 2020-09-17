C movement/mglcol.F --- IcIES/Movement/Grounding-line schemes collection
C Maintainer:  SAITO Fuyuki
C Created: Oct 5 2013
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2020/09/17 08:44:37 fuyuki mglcol.F>'
#define _FNAME 'movement/mglcol.F'
#define _REV   'Snoopy0.97/Three0.1'
CCC_! MANIFESTO
C
C Copyright (C) 2013--2020
C           Japan Agency for Marine-Earth Science and Technology,
C           Ayako ABE-OUCHI
C
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
C#define OPT_GLP_CASE GLP_CASE_E
#define OPT_GLP_CASE GLP_CASE_G
CCC_* Common macros
#include "ofdlct.h"   /* fortran dialect */
#include "oarpea.h"
#include "oarpkw.h"   /* operation id in arpeggio/kiwi */
#ifdef NO_MOVEMENT_H
#else
#  include "movement.h" /* movement definitions */
#endif
CCC_ + Method choices
CCC_  - grounding line property cases
#ifndef   OPT_GLP_CASE
#  define OPT_GLP_CASE  GLP_CASE_G
c$$$#  define OPT_GLP_CASE  GLP_CASE_E
#endif
#ifndef   OPT_GLP_BINTP
#  define OPT_GLP_BINTP 0 /* interpolation at gl */
#endif
#ifndef   OPT_GLP_TINTP
#  define OPT_GLP_TINTP 2 /* use donwstream */
#endif
#if    OPT_GLP_CASE == GLP_CASE_G
#elif  OPT_GLP_CASE == GLP_CASE_E
#else
#  error "GLP_CASE NOT IMPLEMENTED"
#endif
#if  OPT_GLP_BINTP != 0
#  error "GLP_BINTP NOT IMPLEMENTED"
#endif
#if  OPT_GLP_TINTP != 2
#  error "GLP_TINTP NOT IMPLEMENTED"
#endif
CCC_ + float/grounded category
#define _dGRD  _dGR   /* grounded */
#define _dFLO  _dSH   /* floating or ocean */
#define _dBRR  _dBR   /* other */
CCC_& MGLnmv  ## Movement/Grounding-line velocity
      subroutine MGLnmv
     O    (iErr,
     M     VMID,
     M     VMSV,   VMW,
     W     CW,     WG,
     I     IMS,    PMS,   VMI, VMC,   VMHB,
     I     ipCG,
     I     WW,     MH,    LH,  ipKW,  iMA, ipL)
CCC_ + Declaration
      _INTENT(OUT,  integer)   iErr
c
      _INTENT(IN,   integer)   MH, LH
      _INTENT(INOUT,_REALSTD)  VMID (LH, *)
c
      _INTENT(INOUT,_REALSTD)  VMSV (LH, *)
      _INTENT(OUT,  _REALSTD)  VMW  (LH, *)
      _INTENT(OUT,  _REALSTD)  WG (*)
      _INTENT(OUT,  _REALSTD)  CW (*)
c
      _INTENT(IN,   integer)   IMS (*)
      _INTENT(IN,   _REALSTD)  PMS (*)
      _INTENT(IN,   _REALSTD)  VMHB (LH, *)
      _INTENT(IN,   _REALSTD)  VMI  (LH, *)
      _INTENT(IN,   _REALSTD)  VMC  (LH, *)
      _INTENT(IN,   _REALSTD)  WW (LH, *)
c
      _INTENT(IN,   integer)   ipKW (*)
      _INTENT(IN,   integer)   ipCG (*)
      _INTENT(IN,   integer)   iMA  (*)
      _INTENT(IN,   integer)   ipL
c
      integer jp
      integer itrgl
CCC_ + Body
      iErr = 0
      itrgl = IMS (IMS_ITRGL)
CCC_  - Grounding line properties
      call MGLprp
     O    (iErr,
     M     VMSV,
     W     VMW,    CW,    WG,
     I     IMS,    PMS,   VMI, VMC,  VMHB,
     I     .true.,
     I     WW,     MH,    LH,  ipKW, iMA, ipL)
c
      call UV0sta (VMSV, MH, LH, VMSV_Btrb, 1.0d0)
      call UV0sta (VMSV, MH, LH, VMSV_Btrc, 1.0d0)
c$$$      call MGLbtr
c$$$     O    (iErr,
c$$$     O     VMSV,
c$$$     W     VMW,
c$$$     I     IMS,   PMS,
c$$$     I     VMSX,  VMI,
c$$$     I     MH,    LH,  LXK, KXX)
      call MGLflx
     O    (iErr,
     M     VMSV,
     W     VMW,    CW,    WG,
     I     IMS,    PMS,   VMI,
     I     WW,     MH,    LH,  ipKW, iMA, ipL)
#if 0
      call MGLqch
     O    (iErr,
     M     VMSV,
     W     VMW,    CW,    WG,
     I     VMSX,   VMI,
     I     WW,     MH,    LH,   LXK, KXX, ipKW, iMA, ipL)
      call MGLupd
     O    (iErr,
     M     VMSV,
     W     VMW,    CW,    WG,
     I     VMSX,   VMI,
     I     WW,     MH,    LH,   LXK, KXX, ipKW, iMA, ipL)
#endif
CCC_  - store results
#if 0
CCC   D  = Iu * 0  + (1 - Iu) D
CCC   E  = Iu * 0  + (1 - Iu) E
CCC   ub = Iu * Ua + (1 - Iu) E
      do jp = 1, MH
         VMID (jp, VMID_Db) =
     $        + (1.0d0 - VMSC (jp, VMSC_Ub_MI)) * VMID (jp, VMID_Db)
         VMID (jp, VMID_Dc) =
     $        + (1.0d0 - VMSC (jp, VMSC_Vc_MI)) * VMID (jp, VMID_Dc)
         VMID (jp, VMID_Eb) =
     $        + (1.0d0 - VMSC (jp, VMSC_Ub_MI)) * VMID (jp, VMID_Eb)
         VMID (jp, VMID_Ec) =
     $        + (1.0d0 - VMSC (jp, VMSC_Vc_MI)) * VMID (jp, VMID_Ec)
         VMID (jp, VMID_UBb) =
     $        + VMSC (jp, VMSC_Ub_MI) * VMSX (jp, VMSX_UbS, KXX)
     $        + (1.0d0 - VMSC (jp, VMSC_Ub_MI)) * VMID (jp, VMID_UBb)
         VMID (jp, VMID_VBc) =
     $        + VMSC (jp, VMSC_Vc_MI) * VMSX (jp, VMSX_VcW, KXX)
     $        + (1.0d0 - VMSC (jp, VMSC_Vc_MI)) * VMID (jp, VMID_VBc)
      enddo
      if (itrgl.gt.0) then
         do jp = 1, MH
            VMID (jp, VMID_Eb) =
     $           + (1.0d0 - VMSV (jp, VMSV_UGb_MI)) * VMID (jp, VMID_Eb)
            VMID (jp, VMID_Ec) =
     $           + (1.0d0 - VMSV (jp, VMSV_VGc_MI)) * VMID (jp, VMID_Ec)
            VMID (jp, VMID_UBb) =
     $           + VMSV (jp, VMSV_UGb_MI) * VMSX (jp, VMSX_UbS, KXX)
     $           + (1.0d0 - VMSV (jp,VMSV_UGb_MI)) * VMID (jp,VMID_UBb)
            VMID (jp, VMID_VBc) =
     $           + VMSV (jp, VMSV_VGc_MI) * VMSX (jp, VMSX_VcW, KXX)
     $           + (1.0d0 - VMSV (jp,VMSV_VGc_MI)) * VMID (jp,VMID_VBc)
         enddo
      endif
#endif
c
      RETURN
      END
CCC_& MGLprp  ## Movement/grounding-line properties suite (from SSA)
      subroutine MGLprp
     O    (iErr,
     M     VMSV,
     W     VMW,    CW,    WG,
     I     IMS,    PMS,   VMI, VMC,  VMHB,
     I     OSBR,
     I     WW,     MH,    LH,  ipKW, iMA,  ipL)
CCC_ + Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
c
      _INTENT(IN,   integer)   MH, LH
      _INTENT(INOUT,_REALSTD)  VMSV (LH, *)
      _INTENT(OUT,  _REALSTD)  VMW  (LH, *)
      _INTENT(OUT,  _REALSTD)  WG (*)
      _INTENT(OUT,  _REALSTD)  CW   (LH, *)
c
      _INTENT(IN,   integer)   IMS (*)
      _INTENT(IN,   _REALSTD)  PMS (*)
      _INTENT(IN,   _REALSTD)  VMI  (LH, *)
      _INTENT(IN,   _REALSTD)  VMHB (LH, *)
      _INTENT(IN,   _REALSTD)  VMC  (LH, *)
      _INTENT(IN,   _REALSTD)  WW   (LH, *)
      _INTENT(IN,   logical)   OSBR
c
      _INTENT(IN,   integer)   ipKW (*)
      _INTENT(IN,   integer)   iMA  (*)
      _INTENT(IN,   integer)   ipL
c
      _REALSTD  DENSi, DENSw, PN
CCC_ + Body
      iErr = 0
      DENSi = PMS (PMS_DENS)
      DENSw = PMS (PMS_DENSW)
CCC_  - reset grounding line masks
      if (iErr.eq.0) then
         call UV0sta (VMSV, MH, LH, VMSV_UGb_MI, 0.0d0)
         call UV0sta (VMSV, MH, LH, VMSV_VGc_MI, 0.0d0)
         call UV0sta (VMSV, MH, LH, VMSV_UGb,    0.0d0)
         call UV0sta (VMSV, MH, LH, VMSV_VGc,    0.0d0)
      endif
CCC_  - set float/grounded
      if (iErr.eq.0) then
         if (OSBR) then
            call MGLnfg
     $          (VMW, VMSG_IFGa,
     $           VMI, VMI_Ha, VMI_Ba, VMHB, VMHB_Ra, VMHB_SLVa,
     $           DENSi, DENSw, MH, LH)
            call MGLnfg
     $          (VMW, VMSG_IFGb,
     $           VMI, VMI_Hb, VMI_Bb, VMHB, VMHB_Rb, VMHB_SLVb,
     $           DENSi, DENSw, MH, LH)
            call MGLnfg
     $          (VMW, VMSG_IFGc,
     $           VMI, VMI_Hc, VMI_Bc, VMHB, VMHB_Rc, VMHB_SLVc,
     $           DENSi, DENSw, MH, LH)
         else
            call MGLifg
     $          (VMW, VMSG_IFGa,
     $           VMI, VMI_Ha, VMI_Ba, VMHB, VMHB_Ra, VMHB_SLVa, MH, LH)
            call MGLifg
     $          (VMW, VMSG_IFGb,
     $           VMI, VMI_Hb, VMI_Bb, VMHB, VMHB_Rb, VMHB_SLVb, MH, LH)
            call MGLifg
     $          (VMW, VMSG_IFGc,
     $           VMI, VMI_Hc, VMI_Bc, VMHB, VMHB_Rc, VMHB_SLVc, MH, LH)
         endif
      endif
CCC_  - x direction
#if OPT_GLP_CASE == GLP_CASE_E
      if (iErr.eq.0) then
         call MGLpre
     O       (iErr,
     M        VMSV,
     W        VMW,    CW,    WG,
     I        VMI,    VMC,   VMHB,
     I        VMSV_Hglb,  VMSV_Dglb,  VMSV_Xglb, VMSV_CCglb, VMSV_CPglb,
     I        VMSV_WTglEb,VMSV_WTglWb,VMSV_BIglb,
     I        VMSG_IFGb,  VMI_Hb,
     I        VMHB_Rb,    VMHB_FVBb, VMHB_GVBb, VMHB_SLVb,
     I        KWO_FCab,   KWO_FCba,  KWO_Xa, KWO_Xb, KWO_dXb, KWO_Lab,
     I        DENSi,      DENSw,
     I        WW,         MH,  LH,   ipKW,   iMA, ipL)
      endif
CCC_  - y direction
      if (iErr.eq.0) then
         call MGLpre
     O       (iErr,
     M        VMSV,
     W        VMW,    CW,    WG,
     I        VMI,    VMC,   VMHB,
     I        VMSV_Hglc,  VMSV_Dglc,  VMSV_Yglc, VMSV_CCglc, VMSV_CPglc,
     I        VMSV_WTglNc,VMSV_WTglSc,VMSV_BIglc,
     I        VMSG_IFGc,  VMI_Hc,
     I        VMHB_Rc,    VMHB_FVBc, VMHB_GVBc, VMHB_SLVc,
     I        KWO_FCac,   KWO_FCca,  KWO_Ya, KWO_Yc, KWO_dYc, KWO_Lac,
     I        DENSi,      DENSw,
     I        WW,         MH,  LH,   ipKW,   iMA, ipL)
      endif
#elif OPT_GLP_CASE == GLP_CASE_G
      if (iErr.eq.0) then
         call MGLprg
     O       (iErr,
     M        VMSV,
     W        VMW,    CW,    WG,
     I        VMI,    VMC,   VMHB,
     I        VMSV_Hglb,  VMSV_Dglb,  VMSV_Xglb, VMSV_CCglb, VMSV_CPglb,
     I        VMSV_WTglEb,VMSV_WTglWb,VMSV_BIglb,
     I        VMSG_IFGb,  VMI_Hb,
     I        VMHB_Rb,    VMHB_FVBb, VMHB_GVBb, VMHB_SLVb,
     I        KWO_FCab,   KWO_FCba,  KWO_Xa, KWO_Xb, KWO_dXb, KWO_Lab,
     I        DENSi,      DENSw,
     I        WW,         MH,  LH,   ipKW,   iMA, ipL)
      endif
CCC_  - y direction
      if (iErr.eq.0) then
         call MGLprg
     O       (iErr,
     M        VMSV,
     W        VMW,    CW,    WG,
     I        VMI,    VMC,   VMHB,
     I        VMSV_Hglc,  VMSV_Dglc,  VMSV_Yglc, VMSV_CCglc, VMSV_CPglc,
     I        VMSV_WTglNc,VMSV_WTglSc,VMSV_BIglc,
     I        VMSG_IFGc,  VMI_Hc,
     I        VMHB_Rc,    VMHB_FVBc, VMHB_GVBc, VMHB_SLVc,
     I        KWO_FCac,   KWO_FCca,  KWO_Ya, KWO_Yc, KWO_dYc, KWO_Lac,
     I        DENSi,      DENSw,
     I        WW,         MH,  LH,   ipKW,   iMA, ipL)
      endif
#endif

      RETURN
      END
CCC_& MGLnfg  ## Movement/grounding-line floating/grounding switch (g)
      subroutine MGLnfg
     O    (VMW,  KFG,
     I     VMI,  KIH,  KIB,
     I     VMHB, KBR,  KBSLV,
     I     DI,   DW,   MH,   LH)
CCC_ + Declaration
      implicit none
c
      _INTENT(IN, integer)   MH, LH
      _INTENT(OUT,_REALSTD)  VMW (LH, *)
c
      _INTENT(IN, _REALSTD)  VMI  (LH, *)
      _INTENT(IN, _REALSTD)  VMHB (LH, *)
      _INTENT(IN, _REALSTD)  DI, DW
c
      _INTENT(IN, integer)   KFG
      _INTENT(IN, integer)   KIH, KIB
      _INTENT(IN, integer)   KBR, KBSLV
c
      integer   jp
      _REALSTD  T, TR, TB
CCC_ + Body
      TR     = DI / DW
c
      do jp = 1, MH
         if       (VMI  (jp, KIH).gt.0.0d0) then
            TB = VMHB (jp, KBSLV) - TR * VMI (jp, KIH)
            if (TB .le. VMHB (jp, KBR)) then
               T = _dGRD
            else
               T = _dFLO
            endif
         else if  (VMHB (jp, KBR).lt.VMHB (jp, KBSLV)) then
            T = _dFLO
         else
            T = _dBRR
         endif
         VMW (jp, KFG) = T
      enddo
      RETURN
      END
CCC_& MGLifg  ## Movement/grounding-line floating/grounding switch
      subroutine MGLifg
     O    (VMW,  KFG,
     I     VMI,  KIH,  KIB,
     I     VMHB, KBR,  KBSLV,
     I     MH,   LH)
CCC_ + Declaration
      implicit none
c
      _INTENT(IN, integer)   MH, LH
      _INTENT(OUT,_REALSTD)  VMW (LH, *)
c
      _INTENT(IN, _REALSTD)  VMI  (LH, *)
      _INTENT(IN, _REALSTD)  VMHB (LH, *)
c
      _INTENT(IN, integer)   KFG
      _INTENT(IN, integer)   KIH, KIB
      _INTENT(IN, integer)   KBR, KBSLV
c
      integer   jp
      _REALSTD  T
CCC_ + Body
      do jp = 1, MH
         if       (VMI  (jp, KIH).gt.0.0d0) then
            if (VMI (jp, KIB).le. VMHB (jp, KBR)) then
               T = _dGRD
            else
               T = _dFLO
            endif
         else if  (VMHB (jp, KBR).lt. VMHB (jp, KBSLV)) then
            T = _dFLO
         else
            T = _dBRR
         endif
         VMW (jp, KFG) = T
      enddo
      RETURN
      END
CCC_& MGLprg  ## Movement/grounding-line properties core/G
      subroutine MGLprg
     O    (iErr,
     M     VMSV,
     W     VMW,    CW,    WG,
     I     VMI,    VMC,   VMHB,
     I     KSH,    KSD,   KSP,  KSCC, KSCP,
     I     KSTu,   KSTl,  KSBIb,
     I     KWfgb,  KHb,   KRb,  KBc,  KBp,  KBSLV,
     I     KOFCa,  KOFCb, KOXa, KOXb, KOdx, KOL,
     I     DI,     DW,
     I     WW,     MH,    LH,   ipKW, iMA, ipL)
CCC_ + Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
c
      _INTENT(IN,   integer)   MH, LH
      _INTENT(INOUT,_REALSTD)  VMSV (LH, *)
      _INTENT(OUT,  _REALSTD)  VMW  (LH, *)
      _INTENT(OUT,  _REALSTD)  WG (*)
      _INTENT(OUT,  _REALSTD)  CW   (LH, *)
c
      _INTENT(IN,   integer)   KSH,   KSD,   KSP
      _INTENT(IN,   integer)   KSCC,  KSCP
      _INTENT(IN,   integer)   KSTu,  KSTl,  KSBIb
      _INTENT(IN,   integer)   KHb,   KRb
      _INTENT(IN,   integer)   KWfgb
      _INTENT(IN,   integer)   KBp,   KBc,   KBSLV
      _INTENT(IN,   integer)   KOFCa, KOFCb
      _INTENT(IN,   integer)   KOXa,  KOXb,  KOdx, KOL
c
      _INTENT(IN,   _REALSTD)  VMI  (LH, *)
      _INTENT(IN,   _REALSTD)  VMHB (LH, *)
      _INTENT(IN,   _REALSTD)  VMC  (LH, *)
      _INTENT(IN,   _REALSTD)  WW   (LH, *)
c
      _INTENT(IN,   _REALSTD)  DI, DW
c
      _INTENT(IN,   integer)   ipKW (IPKW_FULL_DECL)
      _INTENT(IN,   integer)   iMA  (*)
      _INTENT(IN,   integer)   ipL
c
      integer   jp
      integer   jlo, jla
      _REALSTD  Xrg, Tdr
      _REALSTD  Hi,  Ho,  Ri,  Ro,  SLi, SLo
      _REALSTD  Wu,  Wl
      _REALSTD  Tl0, Tl1, Tu0, Tu1
c
#define GH_Ff -1
#define GH_Gf -2
#define GH_Xf -3

#define GH_Fg +1
#define GH_Gg +2
#define GH_Xg +3

#define GH_Fx +4
#define GH_Gx +5
#define GH_Xx +6

c
#define GP_NONE       0
#define GP_WEST_IN   -1
#define GP_WEST_DOWN -2
#define GP_EAST_DOWN +2
#define GP_EAST_IN   +1
CCC_ + Body
      iErr  = 0
c
      TDR = DI / DW
c
      jlo = ipKW (KWI_KWO, KOL,  KWM_M)
      jla = ipKW (KWI_KWA, KOL,  KWM_M)
CCC_  - gather patterns
      do jp = 1, MH
CCC_   . [*f]
         if      (VMW (jp, KWfgb)   .eq. _dSH) then
            if      (VMW (jp, VMSG_IFGa).eq. _dGR) then
               VMW (jp, VMSG_PTN) = GH_Gf
            else if (VMW (jp, VMSG_IFGa).eq. _dSH) then
               VMW (jp, VMSG_PTN) = GH_Ff
            else
               VMW (jp, VMSG_PTN) = GH_Xf
            endif
CCC_   . [*g]
         else if (VMW (jp, KWfgb).eq. _dGR) then
            if      (VMW (jp, VMSG_IFGa).eq. _dGR) then
               VMW (jp, VMSG_PTN) = GH_Gg
            else if (VMW (jp, VMSG_IFGa).eq. _dSH) then
               VMW (jp, VMSG_PTN) = GH_Fg
            else
               VMW (jp, VMSG_PTN) = GH_Xg
            endif
CCC_   . [*n]
         else
            if      (VMW (jp, VMSG_IFGa).eq. _dGR) then
               VMW (jp, VMSG_PTN) = GH_Gx
            else if (VMW (jp, VMSG_IFGa).eq. _dSH) then
               VMW (jp, VMSG_PTN) = GH_Fx
            else
               VMW (jp, VMSG_PTN) = GH_Xx
            endif
         endif
c$$$         write (*, *) 'GH', jp, VMW (jp, VMSG_PTN)
      enddo
      call AKBwex
     M    (VMW,  CW,
     I     WW,
     I     MH,   LH,  VMSG_PTNp, VMSG_PTN,
     I     ipKW, iMA, KOFCa,     KWM_M)
      call AKBwex
     M    (VMW,  CW,
     I     WW,
     I     MH,   LH,  VMSG_PTNm, VMSG_PTN,
     I     ipKW, iMA, KOFCa,     KWM_T)
      call AKBwex
     M    (VMW,  CW,
     I     WW,
     I     MH,   LH,  VMSG_PTNpp, VMSG_PTNp,
     I     ipKW, iMA, KOFCa,      KWM_M)
      call AKBwex
     M    (VMW,  CW,
     I     WW,
     I     MH,   LH,  VMSG_PTNmm, VMSG_PTNm,
     I     ipKW, iMA, KOFCa,      KWM_T)
CCC_  - direction flag
      do jp = 1, MH
CCC_   . [f][f]<..>[Gn]  n: not f
         if ((VMW (jp, VMSG_PTNmm).lt.0)
     $        .and. (VMW (jp, VMSG_PTNm).lt.0)
     $        .and. ((VMW (jp, VMSG_PTNp).eq. GH_Gg)
     $               .or. (VMW (jp, VMSG_PTNp).eq. GH_Gx))) then
CCC_    * [f][f]<Fg>[Gn] West/In
            if      (VMW (jp, VMSG_PTN) .eq. GH_Fg) then
               VMSV (jp, KSD) = GP_WEST_IN
CCC_    * [f][f]<Fh>[Gn] West/Down
            else if (VMW (jp, VMSG_PTN) .eq. GH_Ff) then
               VMSV (jp, KSD) = GP_WEST_DOWN
CCC_    * others
            else
               VMSV (jp, KSD) = GP_NONE
            endif
CCC_   . [n]<..>[Ff][.f]
         else if ((VMW (jp, VMSG_PTNm).ge.0)
     $           .and. (VMW (jp, VMSG_PTNp).eq. GH_Ff)
     $           .and. (VMW (jp, VMSG_PTNpp).lt.0)) then
CCC_    * [n]<Gg>[Ff][.f] East/Down
            if      (VMW (jp, VMSG_PTN) .eq. GH_Gg) then
               VMSV (jp, KSD) = GP_EAST_DOWN
CCC_    * [n]<Gh>[Ff][.f] East/In
            else if (VMW (jp, VMSG_PTN) .eq. GH_Gf) then
               VMSV (jp, KSD) = GP_EAST_IN
CCC_    * others
            else
               VMSV (jp, KSD) = GP_NONE
            endif
CCC_   . others
         else
            VMSV (jp, KSD) = GP_NONE
         endif
c$$$ 101     format ('P', I4, 1x, 5F3.0, 1x, F3.0)
c$$$         write (*, 101) jp,
c$$$     $        VMW (jp, VMSG_PTNmm),
c$$$     $        VMW (jp, VMSG_PTNm),
c$$$     $        VMW (jp, VMSG_PTN),
c$$$     $        VMW (jp, VMSG_PTNp),
c$$$     $        VMW (jp, VMSG_PTNpp), VMSV (jp, KSD)
      enddo
CCC_  - full clone topography i+1 to i
      call AKBwez
     O    (VMW (1, VMSG_CH),  CW,
     I     VMI (1, VMI_Ha),   WW,
     I     MH,   LH,  ipKW,   iMA, KOFCa, KWM_M)
      call AKBwez
     O    (VMW  (1, VMSG_CR), CW,
     I     VMHB (1, VMHB_Ra), WW,
     I     MH,   LH,  ipKW,   iMA, KOFCa, KWM_M)
      call AKBwez
     O    (VMW  (1, VMSG_CSL),  CW,
     I     VMHB (1, VMHB_SLVa), WW,
     I     MH,   LH,  ipKW,     iMA, KOFCa, KWM_M)
      call AKBwez
     O    (VMW (1, VMSG_CRFI), CW,
     I     VMI (1, VMI_daRFa), WW,
     I     MH,   LH,  ipKW,    iMA, KOFCa, KWM_M)
CCC_  - Xrg Hg LRF
      do jp = 1, MH
CCC_   . <Fg>G
         if      (VMSV (jp, KSD) .eq. GP_WEST_IN) then
            Ho    = VMI  (jp, VMI_Ha)
            Ro    = VMHB (jp, VMHB_Ra)
            SLo   = VMHB (jp, VMHB_SLVa)
            Hi    = VMI  (jp, KHb)
            Ri    = VMHB (jp, KRb)
            SLi   = VMHB (jp, KBSLV)
            Tl0   = 1.0d0
            Tl1   = WW (jp, jlo)
            Tu0   = 0.0d0
            Tu1   = WW (jp, jla)
CCC_   . <Fh>G
         else if (VMSV (jp, KSD) .eq. GP_WEST_DOWN) then
            Ho    = VMI  (jp, KHb)
            Ro    = VMHB (jp, KRb)
            SLo   = VMHB (jp, KBSLV)
            Hi    = VMW  (jp, VMSG_CH)
            Ri    = VMW  (jp, VMSG_CR)
            SLi   = VMW  (jp, VMSG_CSL)
            Tl0   = WW (jp, jlo)
            Tl1   = 0.0d0
            Tu0   = WW (jp, jla)
            Tu1   = 1.0d0
CCC_   . <Gg>F
         else if (VMSV (jp, KSD) .eq. GP_EAST_DOWN) then
            Ho    = VMW  (jp, VMSG_CH)
            Ro    = VMW  (jp, VMSG_CR)
            SLo   = VMW  (jp, VMSG_CSL)
            Hi    = VMI  (jp, KHb)
            Ri    = VMHB (jp, KRb)
            SLi   = VMHB (jp, KBSLV)
            Tl0   = 0.0d0
            Tl1   = WW (jp, jlo)
            Tu0   = 1.0d0
            Tu1   = WW (jp, jla)
CCC_   . <Gh>F
         else if (VMSV (jp, KSD) .eq. GP_EAST_IN) then
            Ho    = VMI  (jp, KHb)
            Ro    = VMHB (jp, KRb)
            SLo   = VMHB (jp, KBSLV)
            Hi    = VMI  (jp, VMI_Ha)
            Ri    = VMHB (jp, VMHB_Ra)
            SLi   = VMHB (jp, VMHB_SLVa)
            Tl0   = WW (jp, jlo)
            Tl1   = 1.0d0
            Tu0   = WW (jp, jla)
            Tu1   = 0.0d0
         else
c$$$            Ri    = VMHB (jp, KBSLV)
            Ri    = VMHB (jp, VMHB_SLVa)
            Hi    = 0.0d0
            SLi   = VMHB (jp, VMHB_SLVa)
            Ho    = 0.0d0
            Ro    = -1.0d0
            SLo   = VMHB (jp, VMHB_SLVa)
            Tl0   = 0.0d0
            Tl1   = 0.0d0
            Tu0   = 0.0d0
            Tu1   = 0.0d0
         endif
         Xrg = (SLi - (Ri + Tdr * Hi))
     $        / (((Ro + Tdr * Ho) - (Ri + Tdr * Hi)) - (SLo - SLi))
c$$$         Xrg = (VMHB (jp, VMHB_SLVa) - (Ri + Tdr * Hi))
c$$$     $        / ((Ro + Tdr * Ho) - (Ri + Tdr * Hi))
         VMSV (jp, KSP) = Xrg
         VMSV (jp, KSH)  = Hi + (Ho - Hi) * Xrg
         Wu = Xrg * Tu0 + (1.0d0 - Xrg) * Tu1
         Wl = Xrg * Tl0 + (1.0d0 - Xrg) * Tl1
         VMSV (jp, KSBIb) =
     $          Wu * VMW (jp, VMSG_CRFI)
     $        + Wl * VMI (jp, VMI_daRFa)
      enddo
      call UV1cpa (VMSV, VMHB, MH, LH, KSCc, KBC)
      call UV1cpa (VMSV, VMHB, MH, LH, KSCp, KBP)
      do jp = 1, MH
         if       (VMSV (jp, KSD) .gt. 0) then
            VMSV (jp, KSTu) = 1.0d0
            VMSV (jp, KSTl) = 0.0d0
         else if  (VMSV (jp, KSD) .lt. 0) then
            VMSV (jp, KSTl) = 1.0d0
            VMSV (jp, KSTu) = 0.0d0
         else
            VMSV (jp, KSTl) = 0.0d0
            VMSV (jp, KSTu) = 0.0d0
         endif
      enddo
      do jp = 1, MH
         if (VMSV (jp, KSD) .eq. GP_NONE) then
            VMSV (jp, KSH)   = 0.0d0
            VMSV (jp, KSP)   = 0.0d0
            VMSV (jp, KSBIb) = 0.0d0
            VMSV (jp, KSCc)  = 1.0d0
            VMSV (jp, KSCp)  = 0.0d0
         endif
      enddo
      RETURN
      END
CCC_& MGLpre  ## Movement/grounding-line properties core/E
      subroutine MGLpre
     O    (iErr,
     M     VMSV,
     W     VMW,    CW,    WG,
     I     VMI,    VMC,   VMHB,
     I     KSH,    KSD,   KSP,  KSCC, KSCP,
     I     KSTu,   KSTl,  KSBIb,
     I     KWfgb,  KHb,   KRb,  KBc,  KBp,  KBSLV,
     I     KOFCa,  KOFCb, KOXa, KOXb, KOdx, KOL,
     I     DI,     DW,
     I     WW,     MH,    LH,   ipKW, iMA, ipL)
CCC_ + Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
c
      _INTENT(IN,   integer)   MH, LH
      _INTENT(INOUT,_REALSTD)  VMSV (LH, *)
      _INTENT(OUT,  _REALSTD)  VMW  (LH, *)
      _INTENT(OUT,  _REALSTD)  WG (*)
      _INTENT(OUT,  _REALSTD)  CW   (LH, *)
c
      _INTENT(IN,   integer)   KSH,   KSD,   KSP
      _INTENT(IN,   integer)   KSCC,  KSCP
      _INTENT(IN,   integer)   KSTu,  KSTl,  KSBIb
      _INTENT(IN,   integer)   KHb,   KRb
      _INTENT(IN,   integer)   KWfgb
      _INTENT(IN,   integer)   KBp,   KBc,   KBSLV
      _INTENT(IN,   integer)   KOFCa, KOFCb
      _INTENT(IN,   integer)   KOXa,  KOXb,  KOdx, KOL
c
      _INTENT(IN,   _REALSTD)  VMI  (LH, *)
      _INTENT(IN,   _REALSTD)  VMHB (LH, *)
      _INTENT(IN,   _REALSTD)  VMC  (LH, *)
      _INTENT(IN,   _REALSTD)  WW   (LH, *)
c
      _INTENT(IN,   _REALSTD)  DI, DW
c
      _INTENT(IN,   integer)   ipKW (IPKW_FULL_DECL)
      _INTENT(IN,   integer)   iMA  (*)
      _INTENT(IN,   integer)   ipL
c
      integer   jp
      integer   jlo, jla
      _REALSTD  Xrg, Tdr
      _REALSTD  Hi,  Ho,  Ri,  Ro,  SLi, SLo
      _REALSTD  Wu,  Wl
      _REALSTD  Tl0, Tl1, Tu0, Tu1
c
#define EH_Xx 0
#define EH_Fg +1
#define EH_Gg +2
#define EH_Xg +3
#define EH_Ff -1
#define EH_Gf -2
#define EH_Xf -3
c
#define EP_NONE       0
#define EP_WEST_IN   -1
#define EP_WEST_DOWN -2
#define EP_EAST_UP   +2
#define EP_EAST_IN   +1
CCC_ + Body
      iErr  = 0
c
      TDR = DI / DW
c
      jlo = ipKW (KWI_KWO, KOL,  KWM_M)
      jla = ipKW (KWI_KWA, KOL,  KWM_M)
CCC_  - gather patterns
      do jp = 1, MH
         if      (VMW (jp, KWfgb)   .eq. _dSH) then
            if      (VMW (jp, VMSG_IFGa).eq. _dGR) then
               VMW (jp, VMSG_PTN) = EH_Gf
            else if (VMW (jp, VMSG_IFGa).eq. _dSH) then
               VMW (jp, VMSG_PTN) = EH_Ff
            else
               VMW (jp, VMSG_PTN) = EH_Xf
            endif
         else if (VMW (jp, KWfgb).eq. _dGR) then
            if      (VMW (jp, VMSG_IFGa).eq. _dGR) then
               VMW (jp, VMSG_PTN) = EH_Gg
            else if (VMW (jp, VMSG_IFGa).eq. _dSH) then
               VMW (jp, VMSG_PTN) = EH_Fg
            else
               VMW (jp, VMSG_PTN) = EH_Xg
            endif
         else
            VMW (jp, VMSG_PTN) = EH_Xx
         endif
      enddo
      call AKBwex
     M    (VMW,  CW,
     I     WW,
     I     MH,   LH,  VMSG_PTNp, VMSG_PTN,
     I     ipKW, iMA, KOFCa,     KWM_M)
      call AKBwex
     M    (VMW,  CW,
     I     WW,
     I     MH,   LH,  VMSG_PTNm, VMSG_PTN,
     I     ipKW, iMA, KOFCa,     KWM_T)
      call AKBwex
     M    (VMW,  CW,
     I     WW,
     I     MH,   LH,  VMSG_PTNpp, VMSG_PTNp,
     I     ipKW, iMA, KOFCa,      KWM_M)
      call AKBwex
     M    (VMW,  CW,
     I     WW,
     I     MH,   LH,  VMSG_PTNmm, VMSG_PTNm,
     I     ipKW, iMA, KOFCa,      KWM_T)
CCC_  - direction flag
      do jp = 1, MH
CCC_   . [f][f]<..>[.n]  n: not f
         if ((VMW (jp, VMSG_PTNm).lt.0)
     $        .and. (VMW (jp, VMSG_PTNmm).lt.0)
     $        .and. (VMW (jp, VMSG_PTNp).ge.0)) then
CCC_    * [f][f]<Fg>[.n] West/In
            if      (VMW (jp, VMSG_PTN) .eq. EH_Fg) then
               VMW (jp, VMSG_WDF) = EP_WEST_IN
CCC_    * [f][f]<Gg>[.n] West/Down
            else if (VMW (jp, VMSG_PTN) .eq. EH_Gg) then
               VMW (jp, VMSG_WDF) = EP_WEST_DOWN
CCC_    * others
            else
               VMW (jp, VMSG_WDF) = EP_NONE
            endif
CCC_   . [n]<.g>[..][.f]
         else if ((VMW (jp, VMSG_PTNm).ge.0)
     $           .and. (VMW (jp, VMSG_PTNpp).lt.0)
     $           .and. (VMW (jp, VMSG_PTN).gt.0)) then
CCC_    * [n]<.g>[Ff][.f] East/Up
            if      (VMW (jp, VMSG_PTNp) .eq. EH_Ff) then
               VMW (jp, VMSG_WDF) = EP_EAST_UP
CCC_    * [n]<.g>[Gf][.f] East/In
            else if (VMW (jp, VMSG_PTNp) .eq. EH_Gf) then
               VMW (jp, VMSG_WDF) = EP_EAST_IN
CCC_    * others
            else
               VMW (jp, VMSG_WDF) = EP_NONE
            endif
CCC_   . others
         else
            VMW (jp, VMSG_WDF) = EP_NONE
         endif
      enddo
CCC_  - full clone direction i to i+1
      call AKBwex
     M    (VMW,  CW,
     I     WW,
     I     MH,   LH,  VMSG_CWDF,  VMSG_WDF,
     I     ipKW, iMA, KOFCb,      KWM_M)
CCC_  - full clone topography i+1 to i
      call AKBwez
     O    (VMW (1, VMSG_CH),  CW,
     I     VMI (1, VMI_Ha),   WW,
     I     MH,   LH,  ipKW,   iMA, KOFCa, KWM_M)
      call AKBwex
     M    (VMW,  CW,
     I     WW,
     I     MH,   LH,  VMSG_CIK,   VMSG_IFGa,
     I     ipKW, iMA, KOFCa,      KWM_M)
      call AKBwez
     O    (VMW  (1, VMSG_CR), CW,
     I     VMHB (1, VMHB_Ra), WW,
     I     MH,   LH,  ipKW,   iMA, KOFCa, KWM_M)
      call AKBwez
     O    (VMW  (1, VMSG_CSL),  CW,
     I     VMHB (1, VMHB_SLVa), WW,
     I     MH,   LH,  ipKW,     iMA, KOFCa, KWM_M)
      call AKBwez
     O    (VMW (1, VMSG_CRFI), CW,
     I     VMI (1, VMI_daRFa), WW,
     I     MH,   LH,  ipKW,    iMA, KOFCa, KWM_M)
CCC_  - Xrg Hg/i
      do jp = 1, MH
         if      (VMW (jp, VMSG_PTN) .eq. EH_Fg) then
            Ho    = VMI  (jp, VMI_Ha)
            Ro    = VMHB (jp, VMHB_Ra)
            SLo   = VMHB (jp, VMHB_SLVa)
            Hi    = VMI  (jp, KHb)
            Ri    = VMHB (jp, KRb)
            SLi   = VMHB (jp, KBSLV)
            Tl0   = 1.0d0
            Tl1   = WW (jp, jlo)
            Tu0   = 0.0d0
            Tu1   = WW (jp, jla)
         else if (VMW (jp, VMSG_PTN) .eq. EH_Gf) then
            Hi    = VMI  (jp, VMI_Ha)
            Ri    = VMHB (jp, VMHB_Ra)
            SLi   = VMHB (jp, VMHB_SLVa)
            Ho    = VMI  (jp, KHb)
            Ro    = VMHB (jp, KRb)
            SLo   = VMHB (jp, KBSLV)
            Tl0   = WW (jp, jlo)
            Tl1   = 1.0d0
            Tu0   = WW (jp, jla)
            Tu1   = 0.0d0
         else
c$$$            Ri    = VMHB (jp, KBSLV)
            Ri    = VMHB (jp, VMHB_SLVa)
            SLi   = VMHB (jp, VMHB_SLVa)
            Hi    = 0.0d0
            Ho    = 0.0d0
            SLo   = VMHB (jp, VMHB_SLVa)
            Ro    = -1.0d0
            Tl0   = 0.0d0
            Tl1   = 0.0d0
            Tu0   = 0.0d0
            Tu1   = 0.0d0
         endif
         Xrg = (SLi - (Ri + Tdr * Hi))
     $        / (((Ro + Tdr * Ho) - (Ri + Tdr * Hi)) - (SLo - SLi))
c$$$         Xrg = (VMHB (jp, VMHB_SLVa) - (Ri + Tdr * Hi))
c$$$     $        / ((Ro + Tdr * Ho) - (Ri + Tdr * Hi))
         VMW (jp, VMSG_Xrgi) = Xrg
         VMW (jp, VMSG_Hgi)  = Hi + (Ho - Hi) * Xrg
         Wu = Xrg * Tu0 + (1.0d0 - Xrg) * Tu1
         Wl = Xrg * Tl0 + (1.0d0 - Xrg) * Tl1
         VMW (jp, VMSG_LRFi) =
     $          Wu * VMW (jp, VMSG_CRFI)
     $        + Wl * VMI (jp, VMI_daRFa)
      enddo
CCC_  - Xrg Hg/o
      do jp = 1, MH
          if     ((VMW (jp, KWfgb)   .eq. _dSH)
     $        .and. (VMW (jp, VMSG_CIK) .eq. _dGR)) then
            Hi    = VMW  (jp, VMSG_CH)
            Ri    = VMW  (jp, VMSG_CR)
            SLi   = VMW  (jp, VMSG_CSL)
            Ho    = VMI  (jp, KHb)
            Ro    = VMHB (jp, KRb)
            SLo   = VMHB (jp, KBSLV)
            Tl0   = WW (jp, jlo)
            Tl1   = 0.0d0
            Tu0   = WW (jp, jla)
            Tu1   = 1.0d0
         else if ((VMW (jp, KWfgb)   .eq. _dGR)
     $        .and. (VMW (jp, VMSG_CIK) .eq. _dSH)) then
            Ho    = VMW  (jp, VMSG_CH)
            Ro    = VMW  (jp, VMSG_CR)
            SLo   = VMW  (jp, VMSG_CSL)
            Hi    = VMI  (jp, KHb)
            Ri    = VMHB (jp, KRb)
            SLi   = VMHB (jp, KBSLV)
            Tl0   = 0.0d0
            Tl1   = WW (jp, jlo)
            Tu0   = 1.0d0
            Tu1   = WW (jp, jla)
         else
c$$$            Ri    = VMHB (jp, KBSLV)
            Ri    = VMHB (jp, VMHB_SLVa)
            Hi    = 0.0d0
            SLi   = VMHB (jp, VMHB_SLVa)
            Ho    = 0.0d0
            Ro    = -1.0d0
            SLo   = VMHB (jp, VMHB_SLVa)
            Tl0   = 0.0d0
            Tl1   = 0.0d0
            Tu0   = 0.0d0
            Tu1   = 0.0d0
         endif
         Xrg = (SLi - (Ri + Tdr * Hi))
     $        / (((Ro + Tdr * Ho) - (Ri + Tdr * Hi)) - (SLo - SLi))
c$$$         Xrg = (VMHB (jp, VMHB_SLVa) - (Ri + Tdr * Hi))
c$$$     $        / ((Ro + Tdr * Ho) - (Ri + Tdr * Hi))
         VMW (jp, VMSG_Xrgo) = Xrg
         VMW (jp, VMSG_Hgo)  = Hi + (Ho - Hi) * Xrg
         Wu = Xrg * Tu0 + (1.0d0 - Xrg) * Tu1
         Wl = Xrg * Tl0 + (1.0d0 - Xrg) * Tl1
         VMW (jp, VMSG_LRFo) =
     $          Wu * VMW (jp, VMSG_CRFI)
     $        + Wl * VMI (jp, VMI_daRFa)
      enddo
CCC_  - full clone direction i to i+1
      call AKBwex
     M    (VMW,  CW,
     I     WW,
     I     MH,   LH,  VMSG_CHg,   VMSG_Hgo,
     I     ipKW, iMA, KOFCb,      KWM_M)
      call AKBwex
     M    (VMW,  CW,
     I     WW,
     I     MH,   LH,  VMSG_CXrg,  VMSG_Xrgo,
     I     ipKW, iMA, KOFCb,      KWM_M)
      call AKBwex
     M    (VMW,  CW,
     I     WW,
     I     MH,   LH,  VMSG_CLRF,  VMSG_LRFo,
     I     ipKW, iMA, KOFCb,      KWM_M)
      call AKBwez
     O    (VMW  (1, VMSG_CCc),CW,
     I     VMHB (1, KBC),     WW,
     I     MH,   LH,  ipKW,   iMA, KOFCb, KWM_M)
      call AKBwez
     O    (VMW  (1, VMSG_CCp),CW,
     I     VMHB (1, KBP),     WW,
     I     MH,   LH,  ipKW,   iMA, KOFCb, KWM_M)
CCC_  - result
      do jp = 1, MH
CCC_   . [f]<Fg>[.n] West/In   Here
         if (VMW (jp, VMSG_WDF) .eq. EP_WEST_IN) then
            VMSV (jp, KSD) = VMW (jp, VMSG_WDF)
            VMSV (jp, KSH) = VMW (jp, VMSG_Hgi)
            VMSV (jp, KSP) = VMW (jp, VMSG_Xrgi)
            VMSV (jp, KSBIb) = VMW (jp, VMSG_LRFi)
            VMSV (jp, KSCc) = VMHB (jp, KBC)
            VMSV (jp, KSCp) = VMHB (jp, KBP)
CCC_   . [f]<Gg>[.n] West/Down Here
         else if (VMW (jp, VMSG_WDF) .eq. EP_WEST_DOWN) then
            VMSV (jp, KSD) = VMW (jp, VMSG_WDF)
            VMSV (jp, KSH) = VMW (jp, VMSG_CHg)
            VMSV (jp, KSP) = VMW (jp, VMSG_CXrg)
            VMSV (jp, KSBIb) = VMW (jp, VMSG_CLRF)
            VMSV (jp, KSCc) = VMHB (jp, KBC)
            VMSV (jp, KSCp) = VMHB (jp, KBP)
CCC_   . [n]<.g>[Ff] East/Up   Left
         else if (VMW (jp, VMSG_CWDF) .eq. EP_EAST_UP) then
            VMSV (jp, KSD) = VMW (jp, VMSG_CWDF)
            VMSV (jp, KSH) = VMW (jp, VMSG_CHg)
            VMSV (jp, KSP) = VMW (jp, VMSG_CXrg)
            VMSV (jp, KSBIb) = VMW (jp, VMSG_CLRF)
            VMSV (jp, KSCc) = VMW (jp, VMSG_CCc)
            VMSV (jp, KSCp) = VMW (jp, VMSG_CCp)
CCC_   . [n]<.g>[Gf] East/In   Left
         else if (VMW (jp, VMSG_CWDF) .eq. EP_EAST_IN) then
            VMSV (jp, KSD) = VMW (jp, VMSG_CWDF)
            VMSV (jp, KSH) = VMW (jp, VMSG_Hgi)
            VMSV (jp, KSP) = VMW (jp, VMSG_Xrgi)
            VMSV (jp, KSBIb) = VMW (jp, VMSG_LRFi)
            VMSV (jp, KSCc) = VMW (jp, VMSG_CCc)
            VMSV (jp, KSCp) = VMW (jp, VMSG_CCp)
CCC_   . others
         else
            VMSV (jp, KSD) = EP_NONE
            VMSV (jp, KSH) = 0.0d0
            VMSV (jp, KSP) = 0.0d0
            VMSV (jp, KSBIb) = 0.0d0
            VMSV (jp, KSCc) = 1.0d0
            VMSV (jp, KSCp) = 0.0d0
         endif
      enddo
c$$$c
c$$$ 101  format ('PTN: ', I4, 1x, 3F3.0, 1x, F3.0, 1x, 2F5.0)
c$$$      do jp = 1, MH
c$$$         write (ipL, 101) jp, VMW (jp, VMSG_PTNm),
c$$$     $        VMW (jp, VMSG_PTN), VMW (jp, VMSG_PTNp),
c$$$     $        VMW (jp, VMSG_WDF),
c$$$     $        VMW (jp, VMSG_Hgi), VMW (jp, VMSG_CHg)
c$$$      enddo
      RETURN
      END
CCC_& MGLbtr  ## Movement/Grounding-line buttressing effect
      subroutine MGLbtr
     O    (iErr,
     O     VMSV,
     W     VMW,   CW,
     I     IMS,   PMS,
     I     VMSX,  VMI,
     I     WW,    MH,   LH,  LXK, KXX, ipKW, iMA)
CCC_ + Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
c
      _INTENT(IN,   integer)   MH, LH, LXK
c
      _INTENT(INOUT,_REALSTD)  VMSV (LH, *)
      _INTENT(OUT,  _REALSTD)  VMW  (LH, *)
      _INTENT(OUT,  _REALSTD)  CW   (LH, *)
      _INTENT(IN,   _REALSTD)  VMSX (LH, LXK, *)
      _INTENT(IN,   integer)   KXX
      _INTENT(IN,   _REALSTD)  VMI  (LH, *)
c
      _INTENT(IN,   integer)   IMS (*)
      _INTENT(IN,   _REALSTD)  PMS (*)
      _INTENT(IN,   _REALSTD)  WW  (*)
      _INTENT(IN,   integer)   ipKW (*)
      _INTENT(IN,   integer)   iMA  (*)
c
      _REALSTD PN, DI, DW, GR
      integer  JSW
CCC_ + Body
      iErr = 0
c
      PN = PMS (PMS_PF)
      DI = PMS (PMS_DENS)
      DW = PMS (PMS_DENSW)
      GR = PMS (PMS_GRAV)
c
      JSW = IMS (IMS_GLBT)
c
      if (JSW .eq. SW_GLBT_DEF) then
         if (iErr.eq.0) then
            call MGLbtp
     O          (iErr,
     M           VMSV, VMSV_Btrb,
     I                 VMSV_Hglb, VMSV_CPglb, VMSV_WTglEb, VMSV_WTglWb,
     W           VMW,  CW,
     I           VMI,  VMI_Ha,
     I           VMSX (1,1,KXX), VMSX_PaE, VMSX_PaW, VMSX_QaN, VMSX_QaS,
     I           WW, KWO_FCab,
     I           DI, DW, GR, PN,
     I           MH, LH, ipKW, iMA)
         endif
         if (iErr.eq.0) then
            call MGLbtp
     O          (iErr,
     M           VMSV, VMSV_Btrc,
     I                 VMSV_Hglc, VMSV_CPglc, VMSV_WTglNc, VMSV_WTglSc,
     W           VMW,  CW,
     I           VMI,  VMI_Ha,
     I           VMSX (1,1,KXX), VMSX_QaN, VMSX_QaS, VMSX_PaE, VMSX_PaW,
     I           WW, KWO_FCac,
     I           DI, DW, GR, PN,
     I           MH, LH, ipKW, iMA)
         endif
      else
         call UV0sta (VMSV, MH, LH, VMSV_Btrb, 1.0d0)
         call UV0sta (VMSV, MH, LH, VMSV_Btrc, 1.0d0)
      endif
      RETURN
      END
CCC_& MGLbtr  ## Movement/Grounding-line buttressing effect core
      subroutine MGLbtp
     O    (iErr,
     M     VMSV, KSBTR,   KSHG,  KSCP, KSTu, KSTl,
     W     VMW,  CW,
     I     VMI,           KIH,
     I     VMSX,          KXTp,  KXTn, KXLp, KXLn,
     I     WW,
     I     KOPfc,
     I     DI, DW, GR, PN,
     I     MH, LH, ipKW, iMA)
CCC_ + Description
CC     Use Tau downstream fron grounding line gridpoints
CCC_ + Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
c
      _INTENT(IN,   integer)   MH, LH
c
      _INTENT(INOUT,_REALSTD)  VMSV (LH, *)
      _INTENT(OUT,  _REALSTD)  VMW  (LH, *)
      _INTENT(OUT,  _REALSTD)  CW   (LH, *)
      _INTENT(IN,   _REALSTD)  VMSX (LH, *)
      _INTENT(IN,   _REALSTD)  VMI  (LH, *)
      _INTENT(IN,   _REALSTD)  WW   (LH, *)
      _INTENT(IN,   integer)   KSBTR
      _INTENT(IN,   integer)   KSHG, KSCP, KSTu, KSTl
      _INTENT(IN,   integer)   KIH
      _INTENT(IN,   integer)   KXTp, KXTn, KXLp, KXLn
      _INTENT(IN,   integer)   KOPfc
c
      _INTENT(IN,   _REALSTD)  DI, DW, GR, PN
      _INTENT(IN,   integer)   ipKW (*)
      _INTENT(IN,   integer)   iMA  (*)
c
      integer jp
      integer jTau, jtTau, jcW, jTfH
      _REALSTD TT2, TL
      _REALSTD TDD
      _REALSTD BX,  TBt
CCC_ + Body
      iErr  = 0
      jTau  = 1
      jTfH  = 2
      jtTau = 3
      jcW   = 4
      TDD  = DI * GR * (1.0d0 - DI / DW) / 4.0d0
#if OPT_GLP_CASE == GLP_CASE_E
      do jp = 1, MH
         TT2 =  VMSX (jp, KXTP) + VMSX (jp, KXTN)
         TL  = (VMSX (jp, KXLP) + VMSX (jp, KXLN)) * 0.5d0
         VMW (jp, jTau) = (TT2 - TL) / 3.0d0
      enddo
      do jp = 1, MH
         VMW (jp, jTfH) = TDD * VMSV (jp, KSHG) * VMI (jp, KIH)
      enddo
#elif OPT_GLP_CASE == GLP_CASE_G
      do jp = 1, MH
         TT2 =  VMSX (jp, KXTP) + VMSX (jp, KXTN)
         TL  = (VMSX (jp, KXLP) + VMSX (jp, KXLN)) * 0.5d0
         VMW (jp, jtTau) = (TT2 - TL) / 3.0d0
      enddo
      call AKBwex
     M    (VMW,  CW,
     I     WW,
     I     MH,   LH,  jcW,  jtTau,
     I     ipKW, iMA, KOPfc, KWM_M)
      do jp = 1, MH
         VMW (jp, jTau) =
     $        + VMW (jp, jtTau) * VMSV (jp, KSTl)
     $        + VMW (jp, jcW)   * VMSV (jp, KSTu)
c$$$         write (*, *) jp,
c$$$     $        VMW (jp, jtTau), VMW (jp, jcW),
c$$$     $        VMSV (jp, KSTl), VMSV (jp, KSTu)
      enddo
      call AKBwez
     O    (VMW  (1, jcW),   CW,
     I     VMI  (1, KIH),   WW,
     I     MH,   LH,  ipKW,  iMA, KOPfc, KWM_M)
      do jp = 1, MH
         VMW (jp, jTfH) = TDD * VMSV (jp, KSHG)
     $        * (VMI (jp, KIH)* VMSV (jp, KSTl)
     $          +VMW (jp, jcW)* VMSV (jp, KSTu))
      enddo
#endif
      do jp = 1, MH
         BX = PN * (VMSV (jp, KSCP) + 1.0d0)
         if (VMW (jp, jTfH).le.0.0d0) then
            TBt = 1.0d0
         else
            TBt = VMW (jp, jTau) / VMW (jp, jTfH)
            TBt = MIN (1.0d0, MAX (0.0d0, TBt))
         endif
c$$$         write (*, *) jp, VMW (jp, jTau), VMW (jp, jTfH)
         VMSV (jp, KSBTR) = TBt ** BX
      enddo
c$$$      do jp = 1, MH
c$$$         write (*, *) 'BT', jp, VMW (jp, jTau),
c$$$     $        VMSV (jp, KSBTR), VMW (jp, jTfH)
c$$$      enddo
      RETURN
      END
CCC_& MGLflx  ## Movement/Grounding-line/flux computation
      subroutine MGLflx
     O    (iErr,
     M     VMSV,
     W     VMW,    CW,    WG,
     I     IMS,    PMS,   VMI,
     I     WW,     MH,    LH,  ipKW, iMA, ipL)
CCC_ + Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
c
      _INTENT(IN,   integer)   MH, LH
      _INTENT(INOUT,_REALSTD)  VMSV (LH, *)
      _INTENT(OUT,  _REALSTD)  VMW  (LH, *)
      _INTENT(OUT,  _REALSTD)  WG (*)
      _INTENT(OUT,  _REALSTD)  CW   (LH, *)
c
      _INTENT(IN,   integer)   IMS (*)
      _INTENT(IN,   _REALSTD)  PMS (*)
      _INTENT(IN,   _REALSTD)  VMI  (LH, *)
      _INTENT(IN,   _REALSTD)  WW   (LH, *)
c
      _INTENT(IN,   integer)   ipKW (*)
      _INTENT(IN,   integer)   iMA  (*)
      _INTENT(IN,   integer)   ipL
c
      _REALSTD  DENSi, DENSw, GRAV
      _REALSTD  PN
      _REALSTD  UMX
CCC_ + Body
      iErr  = 0
      DENSi = PMS (PMS_DENS)
      DENSw = PMS (PMS_DENSW)
      PN    = PMS (PMS_PF)
      GRAV  = PMS (PMS_GRAV)
      UMX   = PMS (PMS_VGLLIM)
      if (iErr.eq.0) then
         call MGLqxc
     O       (iErr,
     M        VMSV,
     W        VMW,    CW,    WG,
     I        VMI,
     I        VMSV_Qglb,
     I        VMSV_Hglb,  VMSV_Dglb,   VMSV_Xglb,
     I        VMSV_BIglb ,VMSV_Btrb,   VMSV_CCglb, VMSV_CPglb,
     I        KWO_Lab,
     I        DENSi,  DENSw, GRAV, PN,   UMX,
     I        WW,     MH,    LH,   ipKW, iMA, ipL)
      endif
      if (iErr.eq.0) then
         call MGLqxc
     O       (iErr,
     M        VMSV,
     W        VMW,    CW,    WG,
     I        VMI,
     I        VMSV_Qglc,
     I        VMSV_Hglc,  VMSV_Dglc,   VMSV_Yglc,
     I        VMSV_BIglc ,VMSV_Btrc,   VMSV_CCglc, VMSV_CPglc,
     I        KWO_Lac,
     I        DENSi,  DENSw, GRAV, PN,   UMX,
     I        WW,     MH,    LH,   ipKW, iMA, ipL)
      endif
      RETURN
      END
CCC_& MGLqxc  ## Movement/Grounding-line/flux computation core
      subroutine MGLqxc
     O    (iErr,
     M     VMSV,
     W     VMW,    CW,    WG,
     I     VMI,
     I     KSQ,
     I     KSH,    KSD,   KSP, KSBI, KSBT, KSCC, KSCP,
     I     KOL,
     I     DI,     DW,    GR,   PN,   UMX,
     I     WW,     MH,    LH,   ipKW, iMA, ipL)
CCC_ + Declaration
      _INTENT(OUT,  integer)   iErr
c
      _INTENT(IN,   integer)   MH, LH
      _INTENT(INOUT,_REALSTD)  VMSV (LH, *)
      _INTENT(OUT,  _REALSTD)  VMW  (LH, *)
      _INTENT(OUT,  _REALSTD)  WG (*)
      _INTENT(OUT,  _REALSTD)  CW   (LH, *)
c
      _INTENT(IN,   integer)   KSQ
      _INTENT(IN,   integer)   KSH,   KSD,  KSP
      _INTENT(IN,   integer)   KSBI,  KSBT, KSCC, KSCP
      _INTENT(IN,   integer)   KOL
c
      _INTENT(IN,   _REALSTD)  VMI  (LH, *)
      _INTENT(IN,   _REALSTD)  WW   (LH, *)
      _INTENT(IN,   _REALSTD)  DI, DW, GR, PN, UMX
c
      _INTENT(IN,   integer)   ipKW (*)
      _INTENT(IN,   integer)   iMA  (*)
      _INTENT(IN,   integer)   ipL
c
      _REALSTD TM,  TC,  TA
      _REALSTD DD,  DGN, DRN
      _REALSTD XC,  XT,  XH
      _REALSTD CD,  CN,  DC, HG, BT
c
      _REALSTD TS,  TLIM
c
      integer  jp
CCC_ + Body
      iErr  = 0
c
      DGN   = (DI * GR)         ** (PN + 1.0d0)
      DRN   = (1.0d0 - DI / DW) **  PN
      DD    = DGN * DRN
      DC    = 4.0d0 ** PN
c
      do jp = 1, MH
         TM = VMSV (jp, KSCP)
         TC = VMSV (jp, KSCC)
         TA = VMSV (jp, KSBI)
         XC = 1.0d0 / (TM + 1.0d0)
         XH = (TM + PN + 3.0d0) / (TM + 1.0d0)
         CD = DC * TC
         CN = TA * DD
         HG = VMSV (jp, KSH)
         BT = VMSV (jp, KSBT)
c$$$         BT = 1.0d0
CC       trick  0 to 0; +1 +2 to +1; -1 -2 to -1
         TS = MIN (1.0d0, ABS (VMSV (jp, KSD)))
         TS = SIGN (TS, VMSV (jp, KSD))
         VMSV (jp, KSQ) = (((CN / CD) ** XC) * (HG ** XH)) * BT * TS
c$$$         write (*, *)
c$$$     $        jp, VMSV (jp, KSQ), CN, CD, XC, HG, XH, VMSV (jp, KSD)
      enddo
      if (UMX.gt.0.0d0) then
         do jp = 1, MH
            TLIM = UMX * VMSV (jp, KSH)
            VMSV (jp, KSQ) = MAX(-TLIM,MIN(TLIM,VMSV(jp,KSQ)))
         enddo
      endif
      RETURN
      END
CCC_& MGLqch  ## Movement/Grounding-line/check speed
      subroutine MGLqch
     O    (iErr,
     M     VMSV,
     W     VMW,    CW,    WG,
     I     VMSX,   VMI,
     I     WW,     MH,    LH,   LXK, KXX, ipKW, iMA, ipL)
CCC_ + Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
c
      _INTENT(IN,   integer)   MH, LH, LXK
      _INTENT(INOUT,_REALSTD)  VMSV (LH, *)
      _INTENT(OUT,  _REALSTD)  VMW  (LH, *)
      _INTENT(OUT,  _REALSTD)  WG (*)
      _INTENT(OUT,  _REALSTD)  CW   (LH, *)
      _INTENT(IN,   _REALSTD)  VMSX (LH, LXK, *)
      _INTENT(IN,   _REALSTD)  VMI  (LH, *)
      _INTENT(IN,   _REALSTD)  WW   (LH, *)
      _INTENT(IN,   integer)   KXX
c
      _INTENT(IN,   integer)   ipKW (*)
      _INTENT(IN,   integer)   iMA  (*)
      _INTENT(IN,   integer)   ipL
CCC_ + Body
      iErr  = 0
#if OPT_GLP_CASE == GLP_CASE_E
      if (iErr.eq.0) then
         call MGLqcp
     O       (iErr,
     M        VMSV,
     W        VMW,      CW,   WG,
     I        VMSX (1,1,KXX), VMI,
     I        VMSV_UGb, VMSV_UGb_MI,
     I        VMSV_WQob,VMSV_WQgb,VMSV_WQcb,
     I        VMSX_UbS, VMSX_UbN,
     I        VMI_Hb,   VMSV_Qglb, VMSV_Dglb,
     I        KWO_FCba,
     I        WW,       MH,    LH,   ipKW, iMA, ipL)
      endif
      if (iErr.eq.0) then
         call MGLqcp
     O       (iErr,
     M        VMSV,
     W        VMW,      CW,   WG,
     I        VMSX (1,1,KXX), VMI,
     I        VMSV_VGc, VMSV_VGc_MI,
     I        VMSV_WQoc,VMSV_WQgc,VMSV_WQcc,
     I        VMSX_VcW, VMSX_VcE,
     I        VMI_Hc,   VMSV_Qglc, VMSV_Dglc,
     I        KWO_FCca,
     I        WW,       MH,    LH,   ipKW, iMA, ipL)
      endif
#elif OPT_GLP_CASE == GLP_CASE_G
      if (iErr.eq.0) then
         call MGLqcg
     O       (iErr,
     M        VMSV,
     W        VMW,      CW,   WG,
     I        VMSX (1,1,KXX), VMI,
     I        VMSV_UGb, VMSV_UGb_MI,
     I        VMSV_WQgb,VMSV_WQub,VMSV_WQlb,
     I        VMSX_UbS, VMSX_UbN,
     I        VMI_Hb,   VMSV_Qglb, VMSV_Dglb,
     I        KWO_FCba,
     I        WW,       MH,    LH,   ipKW, iMA, ipL)
      endif
      if (iErr.eq.0) then
         call MGLqcg
     O       (iErr,
     M        VMSV,
     W        VMW,      CW,   WG,
     I        VMSX (1,1,KXX), VMI,
     I        VMSV_VGc, VMSV_VGc_MI,
     I        VMSV_WQgc,VMSV_WQuc,VMSV_WQlc,
     I        VMSX_VcW, VMSX_VcE,
     I        VMI_Hc,   VMSV_Qglc, VMSV_Dglc,
     I        KWO_FCca,
     I        WW,       MH,    LH,   ipKW, iMA, ipL)
      endif
#endif
      RETURN
      END
CCC_& MGLqcg  ## Movement/Grounding-line/check speed core/G
      subroutine MGLqcg
     O    (iErr,
     M     VMSV,
     W     VMW,    CW,    WG,
     I     VMSX,   VMI,
     I     KCUg,   KCUgM,
     I     KQMg,   KQMu,  KQMl,
     I     KXU0,   KXU1,  KIH,  KCQG, KCD,
     I     KOFC,
     I     WW,     MH,    LH,   ipKW, iMA, ipL)
CCC_ + Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
c
      _INTENT(IN,   integer)   MH, LH
      _INTENT(INOUT,_REALSTD)  VMSV (LH, *)
      _INTENT(OUT,  _REALSTD)  VMW  (LH, *)
      _INTENT(OUT,  _REALSTD)  WG (*)
      _INTENT(OUT,  _REALSTD)  CW   (LH, *)
c
      _INTENT(IN,   _REALSTD)  VMSX (LH, *)
      _INTENT(IN,   _REALSTD)  VMI  (LH, *)
      _INTENT(IN,   _REALSTD)  WW   (LH, *)
c
      _INTENT(IN,   integer)   KCUG, KCUGm
      _INTENT(IN,   integer)   KXU0, KXU1
      _INTENT(IN,   integer)   KQMg, KQMu, KQMl
      _INTENT(IN,   integer)   KIH
      _INTENT(IN,   integer)   KCQG, KCD
      _INTENT(IN,   integer)   KOFC
c
      _INTENT(IN,   integer)   ipKW (*)
      _INTENT(IN,   integer)   iMA  (*)
      _INTENT(IN,   integer)   ipL
c
      integer jwU,  jwQ
      integer jp
      integer jwWp, jwWm
c
      _REALSTD to, tg, tc
CCC_ + Body
      iErr  = 0
      jwU   = 1
      jwQ   = 2
      jwWp  = 3
      jwWm  = 4
CCC_  - get reference flux
      call UV2nva
     $     (VMW, VMSX, MH, LH, jwU, KXU0, KXU1)
      call UV1nma (VMW, VMI, MH, LH, jwQ, jwU, KIH)
      do jp = 1, MH
CC for test
c$$$         VMW (jp, jwQ) = VMW (jp, jwQ) * 2.0d0
c$$$         write (*, *) VMW (jp, jwQ), VMSV (jp, KCQG)
CCC_  - to negative
         if      (VMSV (jp, KCD) .lt. 0.0d0) then
            if      (VMW (jp, jwQ).gt.0.0d0) then
               VMSV (jp, KQMg)  = 0.0d0
               VMW  (jp, jwWp)  = 0.0d0
               VMW  (jp, jwWm)  = 0.0d0
            else if (VMW (jp, jwQ).lt.VMSV (jp, KCQG)) then
               VMSV (jp, KQMg)  = 0.0d0
               VMW  (jp, jwWp)  = 0.0d0
               VMW  (jp, jwWm)  = 1.0d0
            else
               VMSV (jp, KQMg)  = 1.0d0
               VMW  (jp, jwWp)  = 0.0d0
               VMW  (jp, jwWm)  = 0.0d0
            endif
CCC_  - to positive
         else if (VMSV (jp, KCD) .gt. 0.0d0) then
            if      (VMW (jp, jwQ).lt. 0.0d0) then
               VMSV (jp, KQMg)  = 0.0d0
               VMW  (jp, jwWp)  = 0.0d0
               VMW  (jp, jwWm)  = 0.0d0
            else if (VMW (jp, jwQ).gt.VMSV (jp, KCQG)) then
               VMSV (jp, KQMg)  = 0.0d0
               VMW  (jp, jwWp)  = 1.0d0
               VMW  (jp, jwWm)  = 0.0d0
            else
               VMSV (jp, KQMg)  = 1.0d0
               VMW  (jp, jwWp)  = 0.0d0
               VMW  (jp, jwWm)  = 0.0d0
            endif
         else
            VMSV (jp, KQMg)  = 0.0d0
            VMW  (jp, jwWp)  = 0.0d0
            VMW  (jp, jwWm)  = 0.0d0
         endif
      enddo
      call AKBwez
     O    (VMSV (1, KQMl),   CW,
     I     VMW  (1, jwWp),   WW,
     I     MH,   LH,  ipKW,  iMA, KOFC, KWM_M)
      call AKBwez
     O    (VMSV (1, KQMu),   CW,
     I     VMW  (1, jwWm),   WW,
     I     MH,   LH,  ipKW,  iMA, KOFC, KWM_T)
      do jp = 1, MH
         VMSV (jp, KCUGm) =
     $        VMSV (jp, KQMg) + VMSV (jp, KQMu) + VMSV (jp, KQMl)
      enddo
      RETURN
      END
CCC_& MGLqcp  ## Movement/Grounding-line/check speed core
      subroutine MGLqcp
     O    (iErr,
     M     VMSV,
     W     VMW,    CW,    WG,
     I     VMSX,   VMI,
     I     KCUg,   KCUgM,
     I     KQMo,   KQMg,  KQMc,
     I     KXU0,   KXU1,  KIH,  KCQG, KCD,
     I     KOFC,
     I     WW,     MH,    LH,   ipKW, iMA, ipL)
CCC_ + Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
c
      _INTENT(IN,   integer)   MH, LH
      _INTENT(INOUT,_REALSTD)  VMSV (LH, *)
      _INTENT(OUT,  _REALSTD)  VMW  (LH, *)
      _INTENT(OUT,  _REALSTD)  WG (*)
      _INTENT(OUT,  _REALSTD)  CW   (LH, *)
c
      _INTENT(IN,   _REALSTD)  VMSX (LH, *)
      _INTENT(IN,   _REALSTD)  VMI  (LH, *)
      _INTENT(IN,   _REALSTD)  WW   (LH, *)
c
      _INTENT(IN,   integer)   KCUG, KCUGm
      _INTENT(IN,   integer)   KXU0, KXU1
      _INTENT(IN,   integer)   KQMo, KQMg, KQMc
      _INTENT(IN,   integer)   KIH
      _INTENT(IN,   integer)   KCQG, KCD
      _INTENT(IN,   integer)   KOFC
c
      _INTENT(IN,   integer)   ipKW (*)
      _INTENT(IN,   integer)   iMA  (*)
      _INTENT(IN,   integer)   ipL
c
      integer jwU,  jwQ,  jwQC
      integer jwFcs
      integer jwQg
      integer jp
      integer jwWg, jwWp, jwWm
c
      _REALSTD to, tg, tc
CCC_ + Body
      iErr  = 0
      jwU   = 1
      jwQ   = 2
      jwQC  = 3
      jwFcs = 4
      jwQg  = 5
CCC_  - get reference flux
      call UV2nva
     $     (VMW, VMSX, MH, LH, jwU, KXU0, KXU1)
      call UV1nma (VMW, VMI, MH, LH, jwQ, jwU, KIH)
      call AKBwex
     M    (VMW,  CW,
     I     WW,
     I     MH,   LH,  jwQC, jwQ,
     I     ipKW, iMA, KOFC, KWM_M)
CCC_  - comparison
      do jp = 1, MH
         if      (VMSV (jp, KCD) .eq. EP_WEST_IN) then
            if      (VMW (jp, jwQ).gt.0.0d0) then
               VMSV (jp, KQMg)  = 0.0d0
               VMW  (jp, jwFcs) = 0.0d0
            else if (VMW (jp, jwQ).lt.VMSV (jp, KCQG)) then
               VMSV (jp, KQMg)  = 0.0d0
               VMW  (jp, jwFcs) = 1.0d0
            else
               VMSV (jp, KQMg)  = 1.0d0
               VMW  (jp, jwFcs) = 0.0d0
            endif
         else if (VMSV (jp, KCD) .eq. EP_WEST_DOWN) then
            if      (VMW (jp, jwQ).gt.0.0d0) then
               VMSV (jp, KQMg)  = 0.0d0
               VMW  (jp, jwFcs) = 0.0d0
#if 1
            else if (VMW (jp, jwQ).lt.VMSV (jp, KCQG)) then
               VMSV (jp, KQMg)  = 0.0d0
               VMW  (jp, jwFcs) = 1.0d0
            else
               VMSV (jp, KQMg)  = 1.0d0
               VMW  (jp, jwFcs) = 0.0d0
#else /* E-reverse */
            else if (VMW (jp, jwQ).lt.VMSV (jp, KCQG)) then
               VMSV (jp, KQMg)  = 1.0d0
               VMW  (jp, jwFcs) = 0.0d0
            else
               VMSV (jp, KQMg)  = 0.0d0
               VMW  (jp, jwFcs) = 1.0d0
#endif
            endif
c$$$            write (*, *) jp,
c$$$     $           VMSV (jp, KCD), VMW (jp, jwQ),
c$$$     $           VMSV (jp, KCQG), VMW (jp, jwFg), VMW (jp, jwFcs)
c$$$#define __VC -1000.0d0
#define __VC 0.0d0
         else if (VMSV (jp, KCD) .eq. EP_EAST_UP) then
            if      (VMW (jp, jwQC).lt. __VC) then
c$$$               write (IPL, *) 'GEU', jp, VMW (jp, jwQC)
               VMSV (jp, KQMg)  = 0.0d0
               VMW  (jp, jwFcs) = 0.0d0
            else if (VMW (jp, jwQC).gt.VMSV (jp, KCQG)) then
#if 1
               VMSV (jp, KQMg)  = 1.0d0
               VMW  (jp, jwFcs) = 0.0d0
#else /* test no clone */
               VMSV (jp, KQMg)  = 0.0d0
               VMW  (jp, jwFcs) = 1.0d0
#endif
            else
               VMSV (jp, KQMg)  = 0.0d0
               VMW  (jp, jwFcs) = 1.0d0
            endif
c$$$            write (*, *) jp,
c$$$     $           VMSV (jp, KCD), VMW (jp, jwQC),
c$$$     $           VMSV (jp, KCQG), VMSV (jp, KQMg), VMW (jp, jwFcs)
         else if (VMSV (jp, KCD) .eq. EP_EAST_IN) then
            if      (VMW (jp, jwQC).lt. __VC) then
c$$$               write (IPL, *) 'GEI', jp, VMW (jp, jwQC)
               VMSV (jp, KQMg)  = 0.0d0
               VMW  (jp, jwFcs) = 0.0d0
            else if (VMW (jp, jwQC).gt.VMSV (jp, KCQG)) then
#if 1
               VMSV (jp, KQMg)  = 1.0d0
               VMW  (jp, jwFcs) = 0.0d0
#else /* test no clone */
               VMSV (jp, KQMg)  = 0.0d0
               VMW  (jp, jwFcs) = 1.0d0
#endif
            else
               VMSV (jp, KQMg)  = 0.0d0
               VMW  (jp, jwFcs) = 1.0d0
            endif
c$$$            write (*, *) jp,
c$$$     $           VMSV (jp, KCD), VMW (jp, jwQC),
c$$$     $           VMSV (jp, KCQG), VMW (jp, jwFg), VMW (jp, jwFcs)
         else
            VMSV (jp, KQMg)  = 0.0d0
            VMW  (jp, jwFcs) = 0.0d0
         endif
      enddo
CCC_  - result
      call AKBwez
     O    (VMSV (1, KQMc),   CW,
     I     VMW  (1, jwFcs),  WW,
     I     MH,   LH,  ipKW,  iMA, KOFC, KWM_T)
c$$$      call AKBwex
c$$$     M    (VMW,  CW,
c$$$     I     WW,
c$$$     I     MH,   LH,  jwFcd, jwFcs,
c$$$     I     ipKW, iMA, KOFC,  KWM_T)
c$$$         tg = VMW (jp, jwFg)
c$$$         tc = VMW (jp, jwFcd)
c$$$         to = 1.0d0 - (tg + tc)
      do jp = 1, MH
         VMSV (jp, KCUGm) = VMSV (jp, KQMg) + VMSV (jp, KQMc)
         VMSV (jp, KQMo)  = 1.0d0 - VMSV (jp, KCUGm)
      enddo
c$$$      call AKBwez
c$$$     O    (VMW  (1, jwQg),   CW,
c$$$     I     VMSV (1, KCQG),   WW,
c$$$     I     MH,   LH,  ipKW,  iMA, KOFC, KWM_T)
c$$$      do jp = 1, MH
c$$$         tg = VMW (jp, jwFg)
c$$$         tc = VMW (jp, jwFcd)
c$$$         to = 1.0d0 - (tg + tc)
c$$$         VMSV (jp, KCUGm) = (tg + tc)
c$$$         VMSV (jp, KCUG) =
c$$$     $        + to * VMW (jp, jwU)
c$$$     $        + (tg * VMSV (jp, KCQG) + tc * VMW (jp, jwQg))
c$$$     $        / VMI (jp, KIH)
c$$$         VMSV (jp, KCUG) = VMSV (jp, KCUG) * (tg + tc)
c$$$c$$$         write (*, *) jp, tg, tc, to
c$$$      enddo
      RETURN
      END
c$$$         if      (VMW (jp, KCD) .eq. EP_WEST_IN) then
c$$$         else if (VMW (jp, KCD) .eq. EP_WEST_DOWN) then
c$$$         else if (VMW (jp, KCD) .eq. EP_EAST_UP) then
c$$$         else if (VMW (jp, KCD) .eq. EP_EAST_IN) then
c$$$         else
c$$$         endif
CCC_& MGLupd  ## Movement/Grounding-line/update velocity
      subroutine MGLupd
     O    (iErr,
     M     VMSV,
     W     VMW,    CW,    WG,
     I     VMSX,   VMI,   PMS,
     I     WW,     MH,    LH,   LXK, KXX, ipKW, iMA, ipL)
CCC_ + Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
c
      _INTENT(IN,   integer)   MH, LH, LXK
      _INTENT(INOUT,_REALSTD)  VMSV (LH, *)
      _INTENT(OUT,  _REALSTD)  VMW  (LH, *)
      _INTENT(OUT,  _REALSTD)  WG (*)
      _INTENT(OUT,  _REALSTD)  CW   (LH, *)
      _INTENT(IN,   _REALSTD)  VMSX (LH, LXK, *)
      _INTENT(IN,   _REALSTD)  VMI  (LH, *)
      _INTENT(IN,   _REALSTD)  PMS  (*)
      _INTENT(IN,   _REALSTD)  WW   (LH, *)
      _INTENT(IN,   integer)   KXX
c
      _INTENT(IN,   integer)   ipKW (*)
      _INTENT(IN,   integer)   iMA  (*)
      _INTENT(IN,   integer)   ipL
CCC_ + Body
      iErr  = 0
#if OPT_GLP_CASE == GLP_CASE_E
      if (iErr.eq.0) then
         call MGLupc
     O       (iErr,
     M        VMSV,
     W        VMW,    CW,    WG,
     I        VMSX (1,1,KXX), VMI,
     I        VMSV_UGb, VMSV_UGb_MI,
     I        VMSV_WQob,VMSV_WQgb,VMSV_WQcb,
     I        VMSX_UbS, VMSX_UbN,
     I        VMI_Hb,   VMSV_Qglb,
     I        KWO_FCba,
     I        WW,     MH,    LH,   ipKW, iMA, ipL)
      endif
      if (iErr.eq.0) then
         call MGLupc
     O       (iErr,
     M        VMSV,
     W        VMW,    CW,    WG,
     I        VMSX (1,1,KXX), VMI,
     I        VMSV_VGc, VMSV_VGc_MI,
     I        VMSV_WQoc,VMSV_WQgc,VMSV_WQcc,
     I        VMSX_VcW, VMSX_VcE,
     I        VMI_Hc,   VMSV_Qglc,
     I        KWO_FCca,
     I        WW,     MH,    LH,   ipKW, iMA, ipL)
      endif
#elif OPT_GLP_CASE == GLP_CASE_G
      if (iErr.eq.0) then
         call MGLupg
     O       (iErr,
     M        VMSV,
     W        VMW,    CW,    WG,
     I        VMSX (1,1,KXX), VMI,
     I        VMSV_UGb, VMSV_UGb_MI,
     I        VMSV_WQgb,VMSV_WQub,VMSV_WQlb,
     I        VMSX_UbS, VMSX_UbN,
     I        VMI_Hb,   VMSV_Qglb,
     I        KWO_FCba,
     I        PMS,      WW,  MH,  LH, ipKW, iMA, ipL)
      endif
      if (iErr.eq.0) then
         call MGLupg
     O       (iErr,
     M        VMSV,
     W        VMW,    CW,    WG,
     I        VMSX (1,1,KXX), VMI,
     I        VMSV_VGc, VMSV_VGc_MI,
     I        VMSV_WQgc,VMSV_WQuc,VMSV_WQlc,
     I        VMSX_VcW, VMSX_VcE,
     I        VMI_Hc,   VMSV_Qglc,
     I        KWO_FCca,
     I        PMS,      WW,  MH,  LH, ipKW, iMA, ipL)
      endif
#endif
      RETURN
      END
CCC_& MGLupg  ## Movement/Grounding-line/update velocity core/g
      subroutine MGLupg
     O    (iErr,
     M     VMSV,
     W     VMW,    CW,    WG,
     I     VMSX,   VMI,
     I     KCUg,   KCUgM,
     I     KQMg,   KQMu,  KQMl,
     I     KXU0,   KXU1,  KIH,  KCQG,
     I     KOFC,
     I     PMS,    WW,    MH,   LH,   ipKW, iMA, ipL)
CCC_ + Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
c
      _INTENT(IN,   integer)   MH, LH
      _INTENT(INOUT,_REALSTD)  VMSV (LH, *)
      _INTENT(OUT,  _REALSTD)  VMW  (LH, *)
      _INTENT(OUT,  _REALSTD)  WG (*)
      _INTENT(OUT,  _REALSTD)  CW   (LH, *)
c
      _INTENT(IN,   _REALSTD)  VMSX (LH, *)
      _INTENT(IN,   _REALSTD)  VMI  (LH, *)
      _INTENT(IN,   _REALSTD)  WW   (LH, *)
      _INTENT(IN,   _REALSTD)  PMS  (*)
c
      _INTENT(IN,   integer)   KXU0, KXU1
      _INTENT(IN,   integer)   KCUG, KCUGm
      _INTENT(IN,   integer)   KQMg, KQMu, KQMl
      _INTENT(IN,   integer)   KIH
      _INTENT(IN,   integer)   KCQG
      _INTENT(IN,   integer)   KOFC
c
      _INTENT(IN,   integer)   ipKW (*)
      _INTENT(IN,   integer)   iMA  (*)
      _INTENT(IN,   integer)   ipL
c
      integer jwU
      integer jwQu, jwQl
      integer jp
c
      _REALSTD to, tg, tu, tl, tvg
      _REALSTD UMX, HLIM
CCC_ + Body
      iErr  = 0
      jwU   = 1
      jwQu  = 2
      jwQl  = 3
c
      UMX  = PMS(PMS_VGLLIM)
      HLIM = PMS(PMS_HGLIML)
c
      call UV2nva
     $     (VMW, VMSX, MH, LH, jwU, KXU0, KXU1)
      call AKBwez
     O    (VMW  (1, jwQl),   CW,
     I     VMSV (1, KCQG),   WW,
     I     MH,   LH,  ipKW,  iMA, KOFC, KWM_M)
      call AKBwez
     O    (VMW  (1, jwQu),   CW,
     I     VMSV (1, KCQG),   WW,
     I     MH,   LH,  ipKW,  iMA, KOFC, KWM_T)
      do jp = 1, MH
         tg = VMSV (jp, KQMg)
         tu = VMSV (jp, KQMu)
         tl = VMSV (jp, KQMl)
         to = 1.0d0 - (tg + tu + tl)
         tvg =  tg * VMSV (jp, KCQG)
     $        + tu * VMW  (jp, jwQu)
     $        + tl * VMW  (jp, jwQl)
         tvg = tvg / MAX(HLIM, VMI (jp, KIH))
         VMSV (jp, KCUG) =
c$$$     $        + to  * VMW  (jp, jwU)
     $        + (1.0d0 - to) * tvg
c$$$         write (*, *) jp, tg, tc, to, VMSV (jp, KCUG)
c$$$         write (*, *) jp, tg, tc, to, VMSV (jp, KCUG)
      enddo
CC  limiter moved
c$$$      if (UMX.gt.0.0d0) then
c$$$         do jp = 1, MH
c$$$            VMSV (jp, KCUG) = MIN(UMX, MAX(-UMX, VMSV (jp, KCUG)))
c$$$         enddo
c$$$      endif
      RETURN
      END
CCC_& MGLupc  ## Movement/Grounding-line/update velocity core
      subroutine MGLupc
     O    (iErr,
     M     VMSV,
     W     VMW,    CW,    WG,
     I     VMSX,   VMI,
     I     KCUg,   KCUgM,
     I     KQMo,   KQMg,  KQMc,
     I     KXU0,   KXU1,  KIH,  KCQG,
     I     KOFC,
     I     WW,     MH,    LH,   ipKW, iMA, ipL)
CCC_ + Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
c
      _INTENT(IN,   integer)   MH, LH
      _INTENT(INOUT,_REALSTD)  VMSV (LH, *)
      _INTENT(OUT,  _REALSTD)  VMW  (LH, *)
      _INTENT(OUT,  _REALSTD)  WG (*)
      _INTENT(OUT,  _REALSTD)  CW   (LH, *)
c
      _INTENT(IN,   _REALSTD)  VMSX (LH, *)
      _INTENT(IN,   _REALSTD)  VMI  (LH, *)
      _INTENT(IN,   _REALSTD)  WW   (LH, *)
c
      _INTENT(IN,   integer)   KXU0, KXU1
      _INTENT(IN,   integer)   KCUG, KCUGm
      _INTENT(IN,   integer)   KQMo, KQMg, KQMc
      _INTENT(IN,   integer)   KIH
      _INTENT(IN,   integer)   KCQG
      _INTENT(IN,   integer)   KOFC
c
      _INTENT(IN,   integer)   ipKW (*)
      _INTENT(IN,   integer)   iMA  (*)
      _INTENT(IN,   integer)   ipL
c
      integer jwU
      integer jwFcs
      integer jwQg
      integer jp
c
      _REALSTD to, tg, tc
CCC_ + Body
      iErr  = 0
      jwU   = 1
      jwQg  = 2
cc
      call UV2nva
     $     (VMW, VMSX, MH, LH, jwU, KXU0, KXU1)
      call AKBwez
     O    (VMW  (1, jwQg),   CW,
     I     VMSV (1, KCQG),   WW,
     I     MH,   LH,  ipKW,  iMA, KOFC, KWM_T)
      do jp = 1, MH
         tg = VMSV (jp, KQMg)
         tc = VMSV (jp, KQMc)
         to = VMSV (jp, KQMo)
         VMSV (jp, KCUG) =
     $        + to  * VMW  (jp, jwU)
     $        + (tg * VMSV (jp, KCQG) + tc * VMW (jp, jwQg))
     $        / MAX(1.0d0, VMI (jp, KIH))
         VMSV (jp, KCUG) = VMSV (jp, KCUG) * (tg + tc)
      enddo
      RETURN
      END
c$$$         if      (VMW (jp, KCD) .eq. EP_WEST_IN) then
c$$$         else if (VMW (jp, KCD) .eq. EP_WEST_DOWN) then
c$$$         else if (VMW (jp, KCD) .eq. EP_EAST_UP) then
c$$$         else if (VMW (jp, KCD) .eq. EP_EAST_IN) then
c$$$         else
c$$$         endif
CCC_& MGLcmd  ## Movement/Grounding-line matrix modification
      subroutine MGLcmd
     O    (iErr,
     M     VMSX,   VMSC,
     I     VMSV,
     I     KBB,    MH,   LH, LXK)
CCC_ + Description
CC     Matrix components are modifed just where needed.
CCC_ + Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
c
      _INTENT(IN,   integer)   MH, LH, LXK
      _INTENT(INOUT,_REALSTD)  VMSX (LH, LXK, *)
      _INTENT(INOUT,_REALSTD)  VMSC (LH, *)
      _INTENT(IN,   integer)   KBB
      _INTENT(IN,   _REALSTD)  VMSV (LH, *)
CCC_ + Body
      iErr = 0
c
      if (iErr.eq.0) then
         call MGLcmc
     O       (iErr,
     M        VMSX (1,1,KBB), VMSC,
     I        VMSV,
     I        VMSX_UbS,    VMSX_UbN,
     I        VMSC_Ub_MI,
     I        VMSC_UbN_MF, VMSC_UbN_MG, VMSC_UbS_MF, VMSC_UbS_MG,
     I        VMSV_UGb,    VMSV_UGb_MI,
     I        MH,   LH)
      endif
      if (iErr.eq.0) then
         call MGLcmc
     O       (iErr,
     M        VMSX (1,1,KBB), VMSC,
     I        VMSV,
     I        VMSX_VcW,    VMSX_VcE,
     I        VMSC_Vc_MI,
     I        VMSC_VcE_MF, VMSC_VcE_MG, VMSC_VcW_MF, VMSC_VcW_MG,
     I        VMSV_VGc,    VMSV_VGc_MI,
     I        MH,   LH)
      endif
c
      RETURN
      END
CCC_& MGLcmc  ## Movement/Grounding-line matrix modification core
      subroutine MGLcmc
     O    (iErr,
     M     VMSX,   VMSC,
     I     VMSV,
     I     KXS,    KXN,
     I     KCi,    KCfN, KCgN, KCfS, KCgS,
     I     KVu,    KVm,
     I     MH,     LH)
CCC_ + Description
CC     Matrix components are modifed just where needed.
CCC_ + Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
c
      _INTENT(IN,   integer)   MH, LH
      _INTENT(INOUT,_REALSTD)  VMSX (LH, *)
      _INTENT(INOUT,_REALSTD)  VMSC (LH, *)
      _INTENT(IN,   _REALSTD)  VMSV (LH, *)
      _INTENT(IN,   integer)   KXS,    KXN
      _INTENT(IN,   integer)   KCi,    KCfN, KCgN, KCfS, KCgS
      _INTENT(IN,   integer)   KVu,    KVm
c
      integer jp
CCC_ + Body
      iErr = 0
      do jp = 1, MH
         if (VMSV (jp, KVm).eq.1.0d0) then
            VMSC (jp, KCi)  = 0.0d0
            VMSC (jp, KCfN) = 1.0d0
            VMSC (jp, KCfS) = 1.0d0
            VMSC (jp, KCgN) = 0.0d0
            VMSC (jp, KCgS) = 0.0d0
            VMSX (jp, KXS)  = VMSV (jp, KVu)
            VMSX (jp, KXN)  = VMSV (jp, KVu)
         endif
      enddo
      RETURN
      END
CCC_& MGLdec  ## Movement/Grounding-line/kiwi operators declaration
      subroutine MGLdec
     O    (iErr,
     M     ipKW,
     I     IFP)
      implicit none
      _INTENT(OUT,  integer) iErr
      _INTENT(INOUT,integer) ipKW (*)
      _INTENT(IN,   integer) IFP
      iErr = 0
c
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_FCab,  KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_FCac,  KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_FCba,  KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_FCca,  KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_Xa,    KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_Xb,    KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_Ya,    KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_Yc,    KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_dXb,   KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_dYc,   KWM_BOTH, IFP)
c
      RETURN
      END
CCC_& MGLCOL  ## Movement/Grounding-line announcement
      subroutine MGLCOL (STRA, STRB, IOP)
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
CCC_* [TEST]  ## test
#ifdef TEST_MGLCOL
#include "ofnstd.h"
#include "odevid.h"
CCC_ @ MGLtst  ## test program
      program MGLtst
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
c
      if (iErr.eq.0) then
         call DMAtma (iMA)
      endif
      if (iErr.eq.0) then
         call MGLtestMain (iErr, ipA, iMA)
      endif
      if (iErr.eq.0) then
         call ACCrep (FPL(ipA), 0)
      endif
      call DevFin (iErr)
      STOP
      END
CCC_ & MGLtestMain  ## check main
      subroutine MGLtestMain (iErr, ipA, iMA)
CCC_  - Declaration
      implicit none
#include "odevva.h"
      _INTENT(OUT,integer)  iErr
      _INTENT(IN, integer)  ipA (*)
      _INTENT(IN, integer)  iMA (*)
CCC_  - Body
      iErr = 0
      RETURN
      END
#endif /* TEST_MGLCOL */
CCC_* Obsolete
CCC_ + begin
#if 0  /* 0 */
CCC_ + end
#endif /* 0 */
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
