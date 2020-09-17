C movement/msnita.F --- IcIES/Movement/SSA non-linear iteration (a)
C Maintainer:  SAITO Fuyuki
C Created: Oct 2 2012
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2020/09/17 08:47:20 fuyuki msnita.F>'
#define _FNAME 'movement/msnita.F'
#define _REV   'Snoopy0.97/Three0.1'
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
#include "ofdlct.h"   /* fortran dialect */
#include "oarpea.h"
#include "oarpkw.h"   /* operation id in arpeggio/kiwi */
#include "olimit.h"   /* huge value */
#include "odopts.h"   /* option/parameter configuration */
#ifdef NO_MOVEMENT_H
#else
#  include "movement.h" /* movement definitions */
#endif
CCC_ + Method choices
#ifndef    OPT_MSNERR_DIFF     /* error check by diff or relative. */
#  define  OPT_MSNERR_DIFF 0   /* 0 means diff */
#endif
CCC_ + System-dependent switches
#ifndef   OPT_FORMAT_STAR
#  define OPT_FORMAT_STAR 0
#endif
#if OPT_FORMAT_STAR
#  define _FORMAT(F) *
#else
#  define _FORMAT(F) F
#endif
CCC_& MSNmdf  ## Movement/SSA/modify averaged velocities
      subroutine MSNmdf
     O    (iErr,
     M     VMID,
     M     VMSX, VMSC,  VMSV, VMW,
     W     CW,   WG,
     I     T,    IMS,   PMS,  VMSE, VMI, VMC,  VMHB,
     O     ItrN, EfinN, KXX,
     I     ipCG, LCG,   idGM,
     I     WW,   MH,    LH,   LXK,  IE,  ipKW, iMA, ipL)
CCC_ + Declaration
      _INTENT(OUT,  integer)   iErr
c
      _INTENT(IN,   integer)   MH, LH, LXK, LCG
      _INTENT(INOUT,_REALSTD)  VMID (LH, *)
c
      _INTENT(INOUT,_REALSTD)  VMSX (LH, LXK, *)
      _INTENT(INOUT,_REALSTD)  VMSC (LH, *)
      _INTENT(INOUT,_REALSTD)  VMSV (LH, *)
      _INTENT(OUT,  _REALSTD)  VMW  (LH, *)
      _INTENT(OUT,  _REALSTD)  WG (*)
      _INTENT(OUT,  _REALSTD)  CW (*)
c
      _INTENT(OUT,  integer)   KXX
      _INTENT(OUT,  integer)   ItrN
      _INTENT(OUT,  _REALSTD)  EfinN
c
      _INTENT(IN,   integer)   IMS (*)
      _INTENT(IN,   _REALSTD)  T
      _INTENT(IN,   _REALSTD)  PMS (*)
      _INTENT(IN,   _REALSTD)  VMSE (LH, *)
      _INTENT(IN,   _REALSTD)  VMHB (LH, *)
      _INTENT(IN,   _REALSTD)  VMI  (LH, *)
      _INTENT(IN,   _REALSTD)  VMC  (LH, *)
      _INTENT(IN,   _REALSTD)  WW   (LH, *)
c
      _INTENT(IN,   integer)   ipKW (*)
      _INTENT(IN,   integer)   ipCG (*)
      _INTENT(IN,   integer)   idGM (*)
      _INTENT(IN,   integer)   iMA  (*)
      _INTENT(IN,   integer)   IE   (*)
      _INTENT(IN,   integer)   ipL
c
      integer jp
      integer itrgl
      _REALSTD UMX
CCC_ + Body
      iErr = 0
      itrgl = IMS (IMS_ITRGL)
CCC_  - Grounding line properties
      call MGLprp
     O    (iErr,
     M     VMSV,
     W     VMW,    CW,    WG,
     I     IMS,    PMS,   VMI, VMC,  VMHB,
     I     .false.,
     I     WW,     MH,    LH,  ipKW, iMA, ipL)
CCC_  - SSA solver
      call MSNslv
     O    (iErr,
     M     VMSX,   VMSC,  VMSV, VMW,
     W     CW,     WG,
     I     IMS,    PMS,   VMSE, VMI, VMC, VMID, VMHB,
     O     ItrN,   EfinN, KXX,
     I     ipCG,   LCG,   idGM, T,
     I     WW,     MH,    LH,   LXK, IE,  ipKW, iMA, ipL)
CCC_  - Grounding line adjustment
      if (itrgl.gt.0) then
         if (iErr.eq.0)
     $        call AFBwmt (iErr, VMSC, idGM (VGRP_VMSC), T, 'VMSC0', IE)
         if (iErr.eq.0)
     $        call AFBwmt (iErr, VMSV, idGM (VGRP_VMSV), T, 'VMSV0', IE)
         if (iErr.eq.0) then
            call AFBptc
     O          (iErr,
     I           VMSX,
     I           KXX, idGM (VGRP_VMSX), 0, 0, T,  ' ',  'VMSX0',  IE)
         endif
         if (iErr.eq.0) then
            call AFBptc
     O          (iErr,
     I           VMSX,
     I           BCGW_BB, idGM (VGRP_VMSX), 0, 0, T,  ' ',  'bb0',  IE)
         endif
         call MGLbtr
     O       (iErr,
     O        VMSV,
     W        VMW,   CW,
     I        IMS,   PMS,
     I        VMSX,  VMI,
     I        WW,    MH,    LH,  LXK, KXX, ipKW, iMA)
         call MGLflx
     O       (iErr,
     M        VMSV,
     W        VMW,    CW,    WG,
     I        IMS,    PMS,   VMI,
     I        WW,     MH,    LH,  ipKW, iMA, ipL)
         call MGLqch
     O       (iErr,
     M        VMSV,
     W        VMW,    CW,    WG,
     I        VMSX,   VMI,
     I        WW,     MH,    LH,   LXK, KXX, ipKW, iMA, ipL)
         call MGLupd
     O       (iErr,
     M        VMSV,
     W        VMW,    CW,    WG,
     I        VMSX,   VMI,   PMS,
     I        WW,     MH,    LH,   LXK, KXX, ipKW, iMA, ipL)
CCC_   . Non-linear solver again
         call MSNslg
     O       (iErr,
     M        VMSX,   VMSC,  VMSV,  VMW,
     W        CW,     WG,
     I        IMS,    PMS,   VMSE,  VMI, VMC, VMID, VMHB,
     O        ItrN,   EfinN, KXX,
     I        ipCG,   LCG,   idGM,  T, 1,
     I        WW,     MH,    LH, LXK,  IE, ipKW, iMA, ipL)
      endif
CCC_  - store results
      UMX    = PMS (PMS_VSHLIM)
      call MSNulm(VMSX, UMX, KXX, MH, LH, LXK)
CCC   D  = Iu * 0  + (1 - Iu) D
CCC   E  = Iu * 0  + (1 - Iu) E
CCC   ub = Iu * Ua + (1 - Iu) E
      do jp = 1, MH
         VMID (jp, VMID_Db) =
     $        + (1.0d0 - VMSC (jp, VMSC_Ub_MI)) * VMID (jp, VMID_Db)
         VMID (jp, VMID_Dc) =
     $        + (1.0d0 - VMSC (jp, VMSC_Vc_MI)) * VMID (jp, VMID_Dc)
         VMID (jp, VMID_UIavb) =
     $        + (1.0d0 - VMSC (jp, VMSC_Ub_MI)) * VMID (jp, VMID_UIavb)
         VMID (jp, VMID_VIavc) =
     $        + (1.0d0 - VMSC (jp, VMSC_Vc_MI)) * VMID (jp, VMID_VIavc)
         VMID (jp, VMID_UBb) =
     $        + VMSC (jp, VMSC_Ub_MI) * VMSX (jp, VMSX_UbS, KXX)
     $        + (1.0d0 - VMSC (jp, VMSC_Ub_MI)) * VMID (jp, VMID_UBb)
         VMID (jp, VMID_VBc) =
     $        + VMSC (jp, VMSC_Vc_MI) * VMSX (jp, VMSX_VcW, KXX)
     $        + (1.0d0 - VMSC (jp, VMSC_Vc_MI)) * VMID (jp, VMID_VBc)
      enddo
      if (itrgl.gt.0) then
         do jp = 1, MH
            VMID (jp, VMID_Db) =
     $           + (1.0d0 - VMSV (jp, VMSV_UGb_MI)) * VMID (jp, VMID_Db)
            VMID (jp, VMID_Dc) =
     $           + (1.0d0 - VMSV (jp, VMSV_VGc_MI)) * VMID (jp, VMID_Dc)
            VMID (jp, VMID_UIavb) =
     $           + (1.0d0 - VMSV (jp, VMSV_UGb_MI))
     $           * VMID (jp, VMID_UIavb)
            VMID (jp, VMID_VIavc) =
     $           + (1.0d0 - VMSV (jp, VMSV_VGc_MI))
     $           * VMID (jp, VMID_VIavc)
            VMID (jp, VMID_UBb) =
     $           + VMSV (jp, VMSV_UGb_MI) * VMSX (jp, VMSX_UbS, KXX)
     $           + (1.0d0 - VMSV (jp,VMSV_UGb_MI)) * VMID (jp,VMID_UBb)
            VMID (jp, VMID_VBc) =
     $           + VMSV (jp, VMSV_VGc_MI) * VMSX (jp, VMSX_VcW, KXX)
     $           + (1.0d0 - VMSV (jp,VMSV_VGc_MI)) * VMID (jp,VMID_VBc)
         enddo
      endif
#if 0 /* obsolete */
      do jp = 1, MH
         VMID (jp, VMID_Db) =
     $        + (1.0d0 - VMSC (jp, VMSC_Ub_MI)) * VMID (jp, VMID_Db)
         VMID (jp, VMID_Dc) =
     $        + (1.0d0 - VMSC (jp, VMSC_Vc_MI)) * VMID (jp, VMID_Dc)
         VMID (jp, VMID_Eb) =
     $        + VMSC (jp, VMSC_Ub_MI) * VMSX (jp, VMSX_UbS, KXX)
     $        + (1.0d0 - VMSC (jp, VMSC_Ub_MI)) * VMID (jp, VMID_Eb)
         VMID (jp, VMID_Ec) =
     $        + VMSC (jp, VMSC_Vc_MI) * VMSX (jp, VMSX_VcW, KXX)
     $        + (1.0d0 - VMSC (jp, VMSC_Vc_MI)) * VMID (jp, VMID_Ec)
c$$$         write (*, *) jp,
c$$$     $        VMID (jp, VMID_Eb), VMID (jp, VMID_Ec),
c$$$     $        VMID (jp, VMID_Db), VMID (jp, VMID_Dc)
      enddo
      if (itrgl.gt.0) then
         do jp = 1, MH
            VMID (jp, VMID_Eb) =
     $           + VMSV (jp, VMSV_UGb_MI) * VMSX (jp, VMSX_UbS, KXX)
     $           + (1.0d0 - VMSV (jp, VMSV_UGb_MI)) * VMID (jp, VMID_Eb)
            VMID (jp, VMID_Ec) =
     $           + VMSV (jp, VMSV_VGc_MI) * VMSX (jp, VMSX_VcW, KXX)
     $           + (1.0d0 - VMSV (jp, VMSV_VGc_MI)) * VMID (jp, VMID_Ec)
         enddo
      endif
#endif /* obsolete */
c
      if (iErr.eq.0)
     $     call AFBwmp (iErr, VMSC, idGM (VGRP_VMSC), T, IE)
      if (iErr.eq.0)
     $     call AFBwmp (iErr, VMSV, idGM (VGRP_VMSV), T, IE)
      if (iErr.eq.0) then
         call AFBptc
     O        (iErr,
     I        VMSX,
     I        KXX, idGM (VGRP_VMSX), 0, 0, T,  ' ',  ' ',  IE)
      endif
      if (iErr.eq.0) then
         call AFBptc
     O       (iErr,
     I        VMSX,
     I        BCGW_BB, idGM (VGRP_VMSX), 0, 0, T,  ' ',  'bb',  IE)
      endif
c
      RETURN
      END
CCC_& MSNslv  ## Movement/SSA/non-linear solver suite
      subroutine MSNslv
     O    (iErr,
     M     VMSX,   VMSC,  VMSV, VMW,
     W     CW,     WG,
     I     IMS,    PMS,   VMSE, VMI, VMC,  VMID, VMHB,
     O     ItrN,   EfinN, KXX,
     I     ipCG,   LCG,   idGM, T,
     I     WW,     MH,    LH,   LXK, IE,   ipKW, iMA,  ipL)
CCC_ + Declaration
      _INTENT(OUT,  integer)   iErr
c
      _INTENT(IN,   integer)   MH, LH, LXK, LCG
      _INTENT(INOUT,_REALSTD)  VMSX (LH, LXK, *)
      _INTENT(INOUT,_REALSTD)  VMSV (LH, *)
      _INTENT(INOUT,_REALSTD)  VMSC (LH, *)
      _INTENT(OUT,  _REALSTD)  VMW  (LH, *)
      _INTENT(OUT,  _REALSTD)  WG (*)
      _INTENT(OUT,  _REALSTD)  CW (*)
c
      _INTENT(OUT,  integer)   KXX
      _INTENT(OUT,  integer)   ItrN
      _INTENT(OUT,  _REALSTD)  EfinN
c
      _INTENT(IN,   integer)   IMS (*)
      _INTENT(IN,   _REALSTD)  PMS (*)
      _INTENT(IN,   _REALSTD)  VMSE (LH, *)
      _INTENT(IN,   _REALSTD)  VMI  (LH, *)
      _INTENT(IN,   _REALSTD)  VMC  (LH, *)
      _INTENT(IN,   _REALSTD)  VMID (LH, *)
      _INTENT(IN,   _REALSTD)  VMHB (LH, *)
      _INTENT(IN,   _REALSTD)  WW (LH, *)
c
      _INTENT(IN,   _REALSTD)  T
c
      _INTENT(IN,   integer)   IE   (*)
      _INTENT(IN,   integer)   ipKW (*)
      _INTENT(IN,   integer)   ipCG (*)
      _INTENT(IN,   integer)   idGM (*)
      _INTENT(IN,   integer)   iMA  (*)
      _INTENT(IN,   integer)   ipL
c
      _REALSTD  PF, SCXFSR
      integer   KswN
      logical   OupdGL
CCC_ + Body
      iErr = 0
c
      SCXFSR = PMS (PMS_SCXFSR)
      PF     = PMS (PMS_PF)
      KswN   = IMS (IMS_SWNL)
C     grounding line flux not update
      OupdGL = .false.
CCC_  - coefficients
      if (iErr.eq.0) then
         call MSSbcf
     O       (iErr,
     M        VMSC, CW,   VMW,
     I        VMI,  VMC,  VMHB, VMSV, WW, ipKW, iMA, MH, LH)
      endif
CCC_  - right-hand vector
      if (iErr.eq.0) then
         call MSUbst
     O       (iErr,
     M        VMSX, VMW,  CW,
     I        PMS,  VMI,  VMC,  VMSC, VMID,
     I        BCGW_BB,
     I        WW,   ipKW, iMA,  MH,   LH,   LXK)
      endif
CCC_  - Initial guess for viscosity
      if (iErr.eq.0) then
         call MSNbdi
     O       (VMSV,
     W        VMW,  CW,
     I        VMID, VMI, VMHB,
     I        WW,
     I        PMS,
     I        MH,  LH, ipKW, iMA)
         call MSNnsi
     O       (VMSV,
     I        VMSC, SCXFSR, MH,   LH,   KswN, 0)
CCC_  - solver core
         call MSNsst
     O       (iErr,
     M        VMSX,   VMSV,  VMW,
     W        CW,     WG,
     I        IMS,    PMS,   VMSE,  VMSC, VMI,  VMHB, VMID,
     O        OupdGL, ItrN,  EfinN, KXX,
     I        ipCG,   LCG,   idGM,  T,    -1,
     I        WW,     MH,    LH,    LXK,  IE,   ipKW, iMA,  ipL)
      endif
CCC_  - backup mu
      call UV0cpa (VMSV, MH, LH, VMSV_MUa0, VMSV_MUa)
      call UV0cpa (VMSV, MH, LH, VMSV_MUd0, VMSV_MUd)
CCC_  - return
      RETURN
      END
CCC_& MSNslg  ## Movement/SSA/non-linear solver suite (incl. gl)
      subroutine MSNslg
     O    (iErr,
     M     VMSX, VMSC,  VMSV, VMW,
     W     CW,   WG,
     I     IMS,  PMS,   VMSE, VMI, VMC, VMID, VMHB,
     O     ItrN, EfinN, KXX,
     I     ipCG, LCG,   idGM, T,   ITRGL,
     I     WW,   MH,    LH,   LXK, IE,  ipKW, iMA, ipL)
CCC_ + Description
CC     Matrix components are modifed just where needed.
CCC_ + Declaration
      _INTENT(OUT,  integer)   iErr
c
      _INTENT(IN,   integer)   MH, LH, LXK, LCG
      _INTENT(INOUT,_REALSTD)  VMSX (LH, LXK, *)
      _INTENT(INOUT,_REALSTD)  VMSV (LH, *)
      _INTENT(INOUT,_REALSTD)  VMSC (LH, *)
      _INTENT(OUT,  _REALSTD)  VMW  (LH, *)
      _INTENT(OUT,  _REALSTD)  WG (*)
      _INTENT(OUT,  _REALSTD)  CW (*)
c
      _INTENT(OUT,  integer)   KXX
      _INTENT(OUT,  integer)   ItrN
      _INTENT(OUT,  _REALSTD)  EfinN
c
      _INTENT(IN,   integer)   IMS (*)
      _INTENT(IN,   _REALSTD)  PMS (*)
      _INTENT(IN,   _REALSTD)  VMSE (LH, *)
      _INTENT(IN,   _REALSTD)  VMI  (LH, *)
      _INTENT(IN,   _REALSTD)  VMC  (LH, *)
      _INTENT(IN,   _REALSTD)  VMID (LH, *)
      _INTENT(IN,   _REALSTD)  VMHB (LH, *)
      _INTENT(IN,   _REALSTD)  WW (LH, *)
      _INTENT(IN,   _REALSTD)  T
c
      _INTENT(IN,   integer)   ITRGL
      _INTENT(IN,   integer)   IE   (*)
      _INTENT(IN,   integer)   ipKW (*)
      _INTENT(IN,   integer)   ipCG (*)
      _INTENT(IN,   integer)   idGM (*)
      _INTENT(IN,   integer)   iMA  (*)
      _INTENT(IN,   integer)   ipL
c
      _REALSTD  PF, SCXFSR
      integer   KswNG
      logical   OupdGL
CCC_ + Body
      iErr = 0
c
      SCXFSR = PMS (PMS_SCXFSR)
      PF     = PMS (PMS_PF)
      KswNG  = IMS (IMS_SWNLG)
C     grounding line flux not update
      OupdGL = (IMS (IMS_GLUPD) .eq. 1)
CCC_  - modify matrix and vector
      if (iErr.eq.0) then
         call MGLcmd
     O       (iErr,
     M        VMSX, VMSC,
     M        VMSV, BCGW_BB, MH, LH, LXK)
      endif
CCC_  - Initial guess for viscosity
      if (iErr.eq.0) then
         call MSNbdi
     O       (VMSV,
     W        VMW,  CW,
     I        VMID, VMI, VMHB,
     I        WW,
     I        PMS,
     I        MH,  LH, ipKW, iMA)
      endif
      if (iErr.eq.0) then
         call MSNnsi
     O       (VMSV,
     I        VMSC, SCXFSR, MH,   LH,   KswNG, 1)
CCC_  - solver core
         call MSNsst
     O       (iErr,
     M        VMSX,   VMSV, VMW,
     W        CW,     WG,
     I        IMS,    PMS,  VMSE,  VMSC, VMI, VMHB, VMID,
     O        OupdGL, ItrN, EfinN, KXX,
     I        ipCG,   LCG,  idGM,  T,    ITRGL,
     I        WW,     MH,   LH,    LXK,  IE,  ipKW, iMA, ipL)
      endif
CCC_  - strain rate; stress diagnosis
CCC_  - backup mu
      call UV0cpa (VMSV, MH, LH, VMSV_MUa1, VMSV_MUa)
      call UV0cpa (VMSV, MH, LH, VMSV_MUd1, VMSV_MUd)
CCC_  - return
      RETURN
      END
CCC_& MSNsst  ## Movement/SSA/non-linear solver iteration
      subroutine MSNsst
     O    (iErr,
     M     VMSX,   VMSV, VMW,
     W     CW,     WG,
     I     IMS,    PMS,  VMSE,   VMSC, VMI, VMHB, VMID,
     O     OupdGL, ItrN, EfinNN, KXX,
     I     ipCG,   LCG,  idGM,   T,    ITRG,
     I     WW,     MH,   LH,     LXK,  IE,  ipKW, iMA, ipL)
CCC_ + Declaration
      implicit none
c
      _INTENT(OUT,  integer)   iErr
c
      _INTENT(IN,   integer)   MH, LH, LXK, LCG
      _INTENT(INOUT,_REALSTD)  VMSX (LH, LXK, *)
      _INTENT(INOUT,_REALSTD)  VMSV (LH, *)
      _INTENT(OUT,  _REALSTD)  VMW  (LH, *)
      _INTENT(OUT,  _REALSTD)  WG (*)
      _INTENT(OUT,  _REALSTD)  CW (*)
c
      _INTENT(OUT,  logical)   OupdGL
      _INTENT(OUT,  integer)   KXX
      _INTENT(OUT,  integer)   ItrN
      _INTENT(OUT,  _REALSTD)  EfinNN
c
      _INTENT(IN,   integer)   IMS (*)
      _INTENT(IN,   _REALSTD)  PMS (*)
      _INTENT(IN,   _REALSTD)  VMSE (LH, *)
      _INTENT(IN,   _REALSTD)  VMSC (LH, *)
      _INTENT(IN,   _REALSTD)  VMI  (LH, *)
      _INTENT(IN,   _REALSTD)  VMID (LH, *)
      _INTENT(IN,   _REALSTD)  VMHB (LH, *)
      _INTENT(IN,   _REALSTD)  WW (LH, *)
      _INTENT(IN,   _REALSTD)  T
c
      _INTENT(IN,   integer)   ITRG
      _INTENT(IN,   integer)   IE   (*)
      _INTENT(IN,   integer)   ipKW (*)
      _INTENT(IN,   integer)   ipCG (*)
      _INTENT(IN,   integer)   idGM (*)
      _INTENT(IN,   integer)   iMA  (*)
      _INTENT(IN,   integer)   ipL
c
      _REALSTD  Prlx,   PF
      _REALSTD  CVBL,   ESRL
c
      _REALSTD  EtolN,  EminN,  EtolL
      integer   ItrL,   MinItL, MaxItL
      integer   ItMaxN
      integer   ItrEMN
c$$$      _REALSTD  BDC,    BDP
      integer   KswLS
c
      integer   KXXprv, KXXcur, KXXmin, KXXbuf
c
      integer  jto, jtr, jtc, jxk
      integer  jTry
      integer  MaxTrN
      _REALSTD EfinL, EfinND
      _REALSTD PrlxFC
      logical  Ofin, OfinD
      _REALSTD UMX, UXLIMU
      _REALSTD DNMS(LXK), DNMS0(LXK)
      _REALSTD UnrmN, VnrmN, UnrmD, VnrmD
c
      character TVXI*(16), TBUF*(16)
      character TVXT*(16)
c
      integer   jx, jxo, ngr, jh
      _REALSTD  xth
CCC_ + Body
      iErr = 0
CCC_  - preparation
      KXXprv = -1
      KXXbuf = BCGW_XB
      KXXcur = BCGW_XX
      KXXmin = -1
c
      Prlx   = PMS (PMS_OVW)
      EtolN  = PMS (PMS_TOLNL)
      ItMaxN = IMS (IMS_ITRNL)
      KswLS  = IMS (IMS_SWL)
      PF     = PMS (PMS_PF)
      CVBL   = PMS (PMS_VBLIML)
      ESRL   = PMS (PMS_VXLIML) ** 2.0d0
c
      if (ITRG.le.0) then
         TVXI = ' '
         TVXT = ' '
      else
         call USGlni(TBUF, ITRG)
c$$$         write (*, *) 'BUF', _TRIM(TBUF)
         write (TVXI, 201) _TRIM(TBUF)
 201     format ('VMSXI', A)
         write (TVXT, 202) _TRIM(TBUF)
 202     format ('VMSXT', A)
      endif
c
      EminN  = _DBLE_HUGE
      ItrEMN = 0
      MaxTrN = IMS (IMS_TRYNL)
      PrlxFC = PMS (PMS_OVWFC)
      UMX    = PMS (PMS_VSHLIM)
      UXLIMU = PMS (PMS_VXLIMU)
c
      MaxItL = IMS (IMS_ITRL)
      MinItL = IMS (IMS_ITRLmin)
      ETOLL  = PMS (PMS_TOLL)
c
      DNMS(VMSX_PaE) = PMS(PMS_PDNML)
      DNMS(VMSX_PaW) = PMS(PMS_PDNML)
      DNMS(VMSX_QaN) = PMS(PMS_PDNML)
      DNMS(VMSX_QaS) = PMS(PMS_PDNML)
      DNMS(VMSX_UbN) = PMS(PMS_UDNML)
      DNMS(VMSX_UbS) = PMS(PMS_UDNML)
      DNMS(VMSX_VcE) = PMS(PMS_UDNML)
      DNMS(VMSX_VcW) = PMS(PMS_UDNML)
      DNMS(VMSX_RdA) = PMS(PMS_PDNML)
      DNMS(VMSX_PaN) = PMS(PMS_PDNML)
      DNMS(VMSX_PaS) = PMS(PMS_PDNML)
      DNMS(VMSX_QaE) = PMS(PMS_PDNML)
      DNMS(VMSX_QaW) = PMS(PMS_PDNML)
      do jxk = 1, LXK
         DNMS0(jxk) = 1.0d-12
      enddo
c
c$$$      BDC = PMS (PMS_BDRGC)
c$$$      BDP = PMS (PMS_BDRGP)
c
      ItrN   = 0
      EfinND = 0.0d0
      EfinNN = 0.0d0
      UnrmN  = 0.0d0
      VnrmN  = 0.0d0
c    new-style log
 301  format ('MSNQ:',
     $     I2,    1x, I2,    1x, I5,    1x,
     $     I5,    1x, I5,    1x, E10.3, 1x, E10.3, 1x,
     $     E10.3, 1x, E10.3, 1x, E10.3, 1x, E10.3)
c
      jTry = 0
      jto  = 0
CCC_  - iteration 0
CCC_   . initial guess for viscosity
c$$$      call UV0d2a (VMSV, MH, LH, VMSV_BDb, VMSV_BDc, 'BD', 0, 97)
CCC_  - iteration 1
      JTR = 1
         jtc = jto + jtr
CCC_   . initial guess for linear part
         call MSNlsi
     O       (VMSX,
     I        VMSC,   VMID,
     I        KXXprv, KXXcur, MH, LH, LXK,
     I        0)
         call MSLsvc
     O       (iErr,
     M        VMSX,   CW,     VMW,   WG,
     O        ItrL,   EfinL,
     I        MinItL, MaxItL, ETOLL, PMS, VMSC, VMSV,
     I        ipCG,   LCG,
     I        KXXcur, KXXbuf, WW,    MH,  LH,   LXK, ipKW, iMA, ipL)
         write (ipL, 301)
     $        ITRG,   jTry,   jtc,
     $        ItrL,   MaxItL, EfinL, EtolL,
     $        EfinNN, EfinND, UnrmN, VnrmN
         call AFBpts
     O       (iErr,
     I        VMSX,
     I        KXXcur, idGM (VGRP_VMSXT), 0,       0,
     I        T,      jtc,               .false., ' ', TVXT, IE)
      continue
CC    Special configuration (zero iteration)
      if (JTR.gt.ItMaxN) then
         OFIN = .false.
         goto 990
      endif
CCC_  - next guess
      KXXprv = KXXcur
      KXXmin = KXXprv
      KXXcur = KXXcur + 1
      if (KXXcur.gt.BCGW_MAX) KXXcur = BCGW_XX
      if (KXXcur.eq.KXXmin)   KXXcur = KXXcur + 1
      call UV0cpb (VMSX, MH, LH, VMSX_MAX, LXK, KXXcur, KXXprv)
CCC_  - Try
      DO
         call MSNulm(VMSX, UMX, KXXprv, MH, LH, LXK)
CCC_   . iteration loop from 2
         JTR = 2
         DO
           jtc = jto + jtr
           if (OupdGL) then
              call MGLbtr
     O            (iErr,
     O             VMSV,
     W             VMW,   CW,
     I             IMS,   PMS,
     I             VMSX,  VMI,
     I             WW,    MH,    LH,  LXK, KXXprv, ipKW, iMA)
              call MGLflx
     O            (iErr,
     M             VMSV,
     W             VMW,    CW,    WG,
     I             IMS,    PMS,   VMI,
     I             WW,     MH,    LH,  ipKW, iMA, ipL)
              call MGLupd
     O            (iErr,
     M             VMSV,
     W             VMW,    CW,    WG,
     I             VMSX,   VMI,   PMS,
     I             WW,     MH,    LH,   LXK, KXXprv, ipKW, iMA, ipL)
              call MGLcmd
     O            (iErr,
     M             VMSX, VMSC,
     M             VMSV, BCGW_BB, MH, LH, LXK)
           endif
c$$$     I        BDC,    BDP,
           call MSNbdr
     O         (VMSV,
     W          VMW,    CW,
     I          VMSX,   VMI, VMHB,
     I          WW,
     I          CVBL,
     I          KXXprv, MH,  LH, LXK, ipKW, iMA)
           call MSNupv
     O         (VMSV,
     W          VMW,    CW,
     I          VMSC,   VMSE, VMSX,
     I          WW,
     I          PF,     ESRL, UXLIMU,
     I          KXXprv, MH,   LH, LXK, LCG, ipCG, ipKW, iMA)
           call MSNlsi
     O         (VMSX,
     I          VMSC,   VMID,
     I          KXXprv, KXXcur, MH, LH,  LXK,
     I          KswLS)
           call MSLsvc
     O         (iErr,
     M          VMSX,   CW,     VMW,   WG,
     O          ItrL,   EfinL,
     I          MinItL, MaxItL, EtolL, PMS, VMSC, VMSV,
     I          ipCG,   LCG,
     I          KXXcur, KXXbuf, WW,    MH,  LH,   LXK, ipKW, iMA, ipL)
c$$$           write (*, *) 'MSLSVC', iErr
#if OPT_MSNERR_DIFF == 0
           call MSNchr
     $         (Ofin,  EfinNN, UnrmN,  VnrmN,
     $          VMSX,  KXXprv, KXXcur, BCGW_P, MH, LH, LXK,
     $          DNMS,  EtolN,  jtr,    iMA)
           call MSNchr
     $         (OfinD, EfinND, UnrmD,  VnrmD,
     $          VMSX,  KXXprv, KXXcur, BCGW_P, MH, LH, LXK,
     $          DNMS0, EtolN,  jtr,    iMA)
           write (ipL, 301)
     $          ITRG,   jTry,   jtc,
     $          ItrL,   MaxItL, EfinL, EtolL,
     $          EfinNN, EfinND, UnrmN, VnrmN
           call flush (ipL)
#else
           call MSNchk
     $         (Ofin,  EfinNN,
     $          VMSX,  KXXprv, KXXcur, BCGW_P, MH, LH, LXK,
     $          EtolN, jtr,    iMA,    ipL)
#endif
c
           call AFBpts
     O         (iErr,
     I          VMSX,
     I          BCGW_P, idGM (VGRP_VMSXI), 0,    0,
     I          T,      jtc,               OFIN, ' ', TVXI, IE)
c$$$           write (*, *) 'AFBpts', iErr
           call AFBpts
     O         (iErr,
     I          VMSX,
     I          KXXcur, idGM (VGRP_VMSXT), 0,    0,
     I          T,      jtc,               OFIN, ' ', TVXT, IE)
c
           if (EminN.gt.EfinNN) then
              EminN  = EfinNN
              ItrEMN = jtr
              KXXmin = KXXprv
           endif
           if (Ofin) goto 990
           JTR = JTR + 1
           if (JTR.gt.ItMaxN) goto 890
           call MSNups (VMSX, KXXprv, KXXcur, MH, LH, LXK, Prlx)
           KXXprv = KXXcur
           KXXcur = KXXcur + 1
           if (KXXcur.eq.KXXmin)   KXXcur = KXXcur + 1
           if (KXXcur.gt.BCGW_MAX) KXXcur = BCGW_XX
           if (KXXcur.eq.KXXmin)   KXXcur = KXXcur + 1
        ENDDO
 890    CONTINUE
CCC_   . end try
 101    format ('MSN: TRY ', I4, 1x, I5, 1x, 2E10.3)
        write (ipL, 101) jTry, ItrEMN, EminN, EfinNN
        if (jTry.ge.MaxTrN) then
           if (IMS(IMS_SWNOV).eq. SW_NOCONV_SMALL) KXXcur = KXXmin
           goto 990
        else
           jTry = jTry + 1
           jto  = jto + ItMaxN - 1
           KXXprv = KXXmin
           Prlx   = Prlx * PrlxFC
        endif
      ENDDO
 990  CONTINUE
c
      KXX = KXXcur
c$$$c     finalize
      if (.not.OFIN) then
         jtc = jto + 2
         call AFBpts
     O       (iErr,
     I        VMSX,
     I        BCGW_P, idGM (VGRP_VMSXI), 0,      0,
     I        T,      jtc,               .true., ' ', ' ', IE)
         call AFBpts
     O       (iErr,
     I        VMSX,
     I        KXXcur, idGM (VGRP_VMSXT), 0,      0,
     I        T,      jtc,               .true., ' ', TVXT, IE)
      endif
CCC_   . residual report
      jxo = NINT(LOG10(ETOLN))
c
 302  format ('MSNS:', I2, 1x, I2, 1x, I4, 1x, I12)
c$$$#if 0 /* temporary disabled */
#if 1
      do jx = IMS(IMS_XREPL), IMS(IMS_XREPH)
         xth = 10.d0 ** (jx + jxo)
         ngr = 0
         do jh = 1, MH
            if (ABS(VMSX(jh,VMSX_UbN,BCGW_P)).gt.xth) ngr = ngr + 1
            if (ABS(VMSX(jh,VMSX_VcE,BCGW_P)).gt.xth) ngr = ngr + 1
         enddo
         write (ipL, 302) ITRG, jTry, jx + jxo, ngr
      enddo
#endif
c$$$      if (.not.Ofin) then
c$$$         write (ipL, *) 'SNM:', jtr, ItrEMN, EminN, EfinN
c$$$      endif
c$$$      call DAtrcU (ipL, iErr, 'R', 'MSNSST')
c
      RETURN
      END
CCC_& MSNchk  ## Conversion check (max diff u)
      subroutine MSNchk
     $    (Ofin,  EfinL,
     $     VX,    KXXprv, KXXcur, KCHK,  MH, LH, LXK,
     $     EtolL, jtr,    iMA,    ipL)
CCC_ + Declaration
      implicit none
      _INTENT(OUT,_REALSTD)  EfinL
      _INTENT(OUT,logical)   Ofin
      _INTENT(IN, integer)   MH, LH, LXK
      _INTENT(INOUT,_REALSTD)  VX (LH, LXK, *)
      _INTENT(IN, _REALSTD)  EtolL
      _INTENT(IN, integer)   KXXprv, KXXcur
      _INTENT(IN, integer)   KCHK
      _INTENT(IN, integer)   jtr
      _INTENT(IN, integer)   iMA (*)
      _INTENT(IN, integer)   ipL
      _REALSTD xnrm (VMSX_MAX)
      _REALSTD um, vm, ua, va
CCC_ + Body
      Ofin = .false.
      call MSBina
     O    (xnrm,
     I     VX,   KXXcur, iMA, MH, LH, LXK)
      ua = MAX (xnrm (VMSX_UbS), xnrm (VMSX_UbN))
      va = MAX (xnrm (VMSX_VcW), xnrm (VMSX_VcE))
      call UV0nsb
     M    (VX,
     I     MH,  LH,  VMSX_MAX, LXK, KCHK, KXXprv, KXXcur)
CC
      call MSBina
     O    (xnrm,
     I     VX,   KCHK, iMA, MH, LH, LXK)
      um = MAX (xnrm (VMSX_UbS), xnrm (VMSX_UbN))
      vm = MAX (xnrm (VMSX_VcW), xnrm (VMSX_VcE))
      EfinL = MAX (um, vm)
c
      Ofin = (EfinL.lt.EtolL)
c$$$ 101  format ('MSN: ', I7, 1x, E10.3, 1x, E9.2, 1x, 2E10.3)
c$$$      write (ipL, 101) jtr, EfinL, EtolL, ua, va
 101  format ('MSN: ', I7, 1x, E10.3, 1x, 2E10.3)
      write (ipL, 101) jtr, EfinL, ua, va
      call flush (ipL)
      RETURN
      END
CCC_& MSNchr  ## Conversion check (max diff u relative)
      subroutine MSNchr
     $    (Ofin, EfinL,  Unrm,   Vnrm,
     $     VX,   KXXprv, KXXcur, KCHK, MH, LH, LXK,
     $     DNMS, EtolL,  jtr,    iMA)
CCC_ + Declaration
      implicit none
      _INTENT(OUT,  _REALSTD)  EfinL
      _INTENT(OUT,  logical)   Ofin
      _INTENT(OUT,  _REALSTD)  Unrm, Vnrm
      _INTENT(IN,   integer)   MH, LH, LXK
      _INTENT(INOUT,_REALSTD)  VX (LH, LXK, *)
      _INTENT(IN,   _REALSTD)  DNMS(*)
      _INTENT(IN,   _REALSTD)  EtolL
      _INTENT(IN,   integer)   KXXprv, KXXcur
      _INTENT(IN,   integer)   KCHK
      _INTENT(IN,   integer)   jtr
      _INTENT(IN,   integer)   iMA (*)
c$$$      _INTENT(IN,   integer)   ipL
c$$$      _INTENT(IN,   character) Tag*(*)
      _REALSTD xnrm (VMSX_MAX)
      _REALSTD um, vm, dm
      integer jh, jxk
CCC_ + Body
      Ofin = .false.
      call MSBina
     O    (xnrm,
     I     VX, KXXcur, iMA, MH, LH, LXK)
      Unrm = MAX (xnrm (VMSX_UbS), xnrm (VMSX_UbN))
      Vnrm = MAX (xnrm (VMSX_VcW), xnrm (VMSX_VcE))
      call UV0nsb
     M    (VX,
     I     MH,  LH,  VMSX_MAX, LXK, KCHK, KXXprv, KXXcur)
CC
      do jxk = 1, LXK
         dm = DNMS (jxk)
         do jh = 1, MH
            VX(jh,jxk,KCHK) =
     $           VX(jh,jxk,KCHK)
     $           / MAX(dm, ABS(VX(jh,jxk,KXXprv)))
         enddo
      enddo
CC
      call MSBina
     O    (xnrm,
     I     VX,   KCHK, iMA, MH, LH, LXK)
      um = MAX (xnrm (VMSX_UbS), xnrm (VMSX_UbN))
      vm = MAX (xnrm (VMSX_VcW), xnrm (VMSX_VcE))
      EfinL = MAX (um, vm)
c
      Ofin = (EfinL.lt.EtolL)
c$$$ 101  format (A, ': ', I7, 1x, E10.3, 1x, 2E10.3)
c$$$      write (ipL, 101) Tag, jtr, EfinL, ua, va
c$$$      call flush (ipL)
      RETURN
      END
CCC_& MSNssc  ## Movement/SSA/non-linear solver core
CCC_& MSNnsi  ## Movement/SSA/non-linear initial guess (non-linear)
      subroutine MSNnsi
     O    (VV,
     I     VC,
     I     SCXFSR,
     I     MH,     LH, Kmdl, Kmode)
CCC_ + Declaration
      implicit none
      _INTENT(IN,   integer)   MH, LH
      _INTENT(INOUT,_REALSTD)  VV (LH, *)
      _INTENT(IN,   _REALSTD)  VC (LH, *)
      _INTENT(IN,   integer)   Kmdl, Kmode
      _INTENT(IN,   _REALSTD)  SCXFSR
      logical OFIRST
      data    OFIRST /.true./
      save    OFIRST
CCC_ + Body
c$$$      call UV0sta (VV, MH, LH, VMSV_BDb, 0.0d0)
c$$$      call UV0sta (VV, MH, LH, VMSV_BDc, 0.0d0)
CCC_  - viscosity
       if (Kmdl.eq.0.or.OFIRST) then
c$$$          write (*, *) 'MSNNSI', kmdl, SclV, SclL, PF
         OFIRST = .false.
         call MSFvsg
     M       (VV,
     I        VC,
     I        VMSV_MUa,  VMSC_BVIa, SCXFSR, MH, LH)
         call UV0cpa (VV, MH, LH, VMSV_MUaN, VMSV_MUa)
         call UV0cpa (VV, MH, LH, VMSV_MUaS, VMSV_MUa)
         call UV0cpa (VV, MH, LH, VMSV_MUaE, VMSV_MUa)
         call UV0cpa (VV, MH, LH, VMSV_MUaW, VMSV_MUa)
         call MSFvsg
     M       (VV,
     I        VC,
     I        VMSV_MUd,  VMSC_BVId, SCXFSR, MH, LH)
         call UV0cpa (VV, MH, LH, VMSV_MUa0, VMSV_MUa)
         call UV0cpa (VV, MH, LH, VMSV_MUd0, VMSV_MUd)
         call UV0cpa (VV, MH, LH, VMSV_MUa1, VMSV_MUa)
         call UV0cpa (VV, MH, LH, VMSV_MUd1, VMSV_MUd)
      else
         if (Kmode.eq.0) then
            call UV0cpa (VV, MH, LH, VMSV_MUa, VMSV_MUa0)
            call UV0cpa (VV, MH, LH, VMSV_MUd, VMSV_MUd0)
         else
            call UV0cpa (VV, MH, LH, VMSV_MUa, VMSV_MUa1)
            call UV0cpa (VV, MH, LH, VMSV_MUd, VMSV_MUd1)
         endif
         call MSFvsm
     M       (VV,
     I        VC,
     I        VMSV_MUa,  VMSC_BVIa, SCXFSR, MH, LH)
         call UV0cpa (VV, MH, LH, VMSV_MUaN, VMSV_MUa)
         call UV0cpa (VV, MH, LH, VMSV_MUaS, VMSV_MUa)
         call UV0cpa (VV, MH, LH, VMSV_MUaE, VMSV_MUa)
         call UV0cpa (VV, MH, LH, VMSV_MUaW, VMSV_MUa)
         call MSFvsm
     M       (VV,
     I        VC,
     I        VMSV_MUd,  VMSC_BVId, SCXFSR, MH, LH)
      endif
      RETURN
      END
CCC_& MSNlsi  ## Movement/SSA/non-linear initial guess (linear)
      subroutine MSNlsi
     O    (VX,
     i     VC,     VID,
     I     KXXprv, KXXcur, MH, LH, LXK,
     I     Kmdl)
CCC_ + Declaration
      implicit none
      _INTENT(IN,   integer)   MH,  LH, LXK
      _INTENT(INOUT,_REALSTD)  VX  (LH, LXK, *)
      _INTENT(IN,   _REALSTD)  VC  (LH, *)
      _INTENT(IN,   _REALSTD)  VID (LH, *)
      _INTENT(IN, integer)   KXXprv, KXXcur
      _INTENT(IN, integer)   Kmdl
      integer jp
CCC_ + Body
      if (kmdl.eq.0) then
         do jp = 1, MH
#if 0 /* bug ? */
            VX (jp, VMSX_UbS, KXXcur)
     $           = VC (jp, VMSC_UbS_MF) * VX (jp, VMSX_UbS, BCGW_BB)
     $           + VID (jp, VMID_UBb)
            VX (jp, VMSX_UbN, KXXcur)
     $           = VC (jp, VMSC_UbN_MF) * VX (jp, VMSX_UbN, BCGW_BB)
     $           + VID (jp, VMID_UBb)
            VX (jp, VMSX_VcW, KXXcur)
     $           = VC (jp, VMSC_VcW_MF) * VX (jp, VMSX_VcW, BCGW_BB)
     $           + VID (jp, VMID_VBc)
            VX (jp, VMSX_VcE, KXXcur)
     $           = VC (jp, VMSC_VcE_MF) * VX (jp, VMSX_VcE, BCGW_BB)
     $           + VID (jp, VMID_VBc)
#else
            VX (jp, VMSX_UbS, KXXcur)
     $           = VC (jp, VMSC_UbS_MF) * VX (jp, VMSX_UbS, BCGW_BB)
            VX (jp, VMSX_UbN, KXXcur)
     $           = VC (jp, VMSC_UbN_MF) * VX (jp, VMSX_UbN, BCGW_BB)
            VX (jp, VMSX_VcW, KXXcur)
     $           = VC (jp, VMSC_VcW_MF) * VX (jp, VMSX_VcW, BCGW_BB)
            VX (jp, VMSX_VcE, KXXcur)
     $           = VC (jp, VMSC_VcE_MF) * VX (jp, VMSX_VcE, BCGW_BB)
#endif
            VX (jp, VMSX_PaN, KXXcur)
     $           = VC (jp, VMSC_PaN_MF) * VX (jp, VMSX_PaN, BCGW_BB)
            VX (jp, VMSX_PaS, KXXcur)
     $           = VC (jp, VMSC_PaS_MF) * VX (jp, VMSX_PaS, BCGW_BB)
            VX (jp, VMSX_PaE, KXXcur)
     $           = VC (jp, VMSC_PaE_MF) * VX (jp, VMSX_PaE, BCGW_BB)
            VX (jp, VMSX_PaW, KXXcur)
     $           = VC (jp, VMSC_PaW_MF) * VX (jp, VMSX_PaW, BCGW_BB)
            VX (jp, VMSX_QaN, KXXcur)
     $           = VC (jp, VMSC_QaN_MF) * VX (jp, VMSX_QaN, BCGW_BB)
            VX (jp, VMSX_QaS, KXXcur)
     $           = VC (jp, VMSC_QaS_MF) * VX (jp, VMSX_QaS, BCGW_BB)
            VX (jp, VMSX_QaE, KXXcur)
     $           = VC (jp, VMSC_QaE_MF) * VX (jp, VMSX_QaE, BCGW_BB)
            VX (jp, VMSX_QaW, KXXcur)
     $           = VC (jp, VMSC_QaW_MF) * VX (jp, VMSX_QaW, BCGW_BB)
            VX (jp, VMSX_RdA, KXXcur)
     $           = VC (jp, VMSC_RdA_MF) * VX (jp, VMSX_RdA, BCGW_BB)
         enddo
      else
         do jp = 1, MH
#if 0 /* good; temporary */
            VX (jp, VMSX_UbS, KXXcur)
     $           = VC (jp, VMSC_UbS_MF) * VX (jp, VMSX_UbS, BCGW_BB)
     $           + (1.0d0-VC(jp,VMSC_UbS_MF)) * VX(jp,VMSX_UbS,KXXprv)
            VX (jp, VMSX_UbN, KXXcur)
     $           = VC (jp, VMSC_UbN_MF) * VX (jp, VMSX_UbN, BCGW_BB)
     $           + (1.0d0-VC(jp,VMSC_UbN_MF)) * VX(jp,VMSX_UbN,KXXprv)
            VX (jp, VMSX_VcW, KXXcur)
     $           = VC (jp, VMSC_VcW_MF) * VX (jp, VMSX_VcW, BCGW_BB)
     $           + (1.0d0-VC(jp,VMSC_VcW_MF)) * VX(jp,VMSX_VcW,KXXprv)
            VX (jp, VMSX_VcE, KXXcur)
     $           = VC (jp, VMSC_VcE_MF) * VX (jp, VMSX_VcE, BCGW_BB)
     $           + (1.0d0-VC(jp,VMSC_VcE_MF)) * VX(jp,VMSX_VcE,KXXprv)
#else
            VX (jp, VMSX_UbS, KXXcur) = VX (jp, VMSX_UbS, KXXprv)
            VX (jp, VMSX_UbN, KXXcur) = VX (jp, VMSX_UbN, KXXprv)
            VX (jp, VMSX_VcW, KXXcur) = VX (jp, VMSX_VcW, KXXprv)
            VX (jp, VMSX_VcE, KXXcur) = VX (jp, VMSX_VcE, KXXprv)
#endif
            VX (jp, VMSX_PaN, KXXcur) = VX (jp, VMSX_PaN, KXXprv)
            VX (jp, VMSX_PaS, KXXcur) = VX (jp, VMSX_PaS, KXXprv)
            VX (jp, VMSX_PaE, KXXcur) = VX (jp, VMSX_PaE, KXXprv)
            VX (jp, VMSX_PaW, KXXcur) = VX (jp, VMSX_PaW, KXXprv)
            VX (jp, VMSX_QaN, KXXcur) = VX (jp, VMSX_QaN, KXXprv)
            VX (jp, VMSX_QaS, KXXcur) = VX (jp, VMSX_QaS, KXXprv)
            VX (jp, VMSX_QaE, KXXcur) = VX (jp, VMSX_QaE, KXXprv)
            VX (jp, VMSX_QaW, KXXcur) = VX (jp, VMSX_QaW, KXXprv)
            VX (jp, VMSX_RdA, KXXcur) = VX (jp, VMSX_RdA, KXXprv)
         enddo
      endif
      RETURN
      END
CCC_* update solution
CCC_ & MSNups
      subroutine MSNups
     M    (VX,
     I     KXXprv, KXXcur, MH, LH, LXK, Prlx)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)   MH, LH, LXK
      _INTENT(IN,   integer)   KXXprv, KXXcur
      _INTENT(INOUT,_REALSTD)  VX (LH, LXK, *)
      _INTENT(IN,   _REALSTD)  Prlx
      _REALSTD F1, F2
CCC_  - Body
c$$$      F1 = Prlx
c$$$      F2 = 1.0d0 - Prlx
c$$$      call UV0ugb (VX, MH, LH, VMSX_MAX, LXK, KXXcur, KXXprv, F1, F2)
      call UV0uob (VX, MH, LH, VMSX_MAX, LXK, KXXcur, KXXprv, Prlx)
      RETURN
      END
CCC_* update viscosity
CCC_ & MSNbdi  ## Movement/SSA/non-linear basal drag suite (for initialization)
      subroutine MSNbdi
     O    (VV,
     W     W,   CW,
     I     VID, VI, VHB,
     I     WW,
     I     PMS,
     I     MH,  LH, ipKW, iMA)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)   MH, LH
      _INTENT(OUT,_REALSTD)  VV  (LH, *)
      _INTENT(OUT,_REALSTD)  W   (LH, *)
      _INTENT(OUT,_REALSTD)  CW  (*)
      _INTENT(IN, _REALSTD)  VI  (LH, *)
      _INTENT(IN, _REALSTD)  VHB (LH, *)
      _INTENT(IN, _REALSTD)  VID (LH, *)
      _INTENT(IN, _REALSTD)  WW  (LH, *)
      _INTENT(IN, _REALSTD)  PMS (*)
      _INTENT(IN, integer)   ipKW (*)
      _INTENT(IN, integer)   iMA  (*)
      _REALSTD CVBL
CCC_  - Body
      CVBL   = PMS (PMS_VBLIML)
      call MSNbic
     O    (VV,
     W     W,         CW,
     I     VID,       VI,       VHB,
     I     VMSV_BDb,
     I     VMID_UBb,  VMID_VBc, VMI_SLDb,
     I     VMHB_FVBb, VMHB_GVBb,
     I     KWO_Lca,   KWO_Lab,
     I     WW,
     I     CVBL,
     I     MH,        LH,       ipKW, iMA)
      call MSNbic
     O    (VV,
     W     W,         CW,
     I     VID,       VI,       VHB,
     I     VMSV_BDc,
     I     VMID_VBc,  VMID_UBb, VMI_SLDc,
     I     VMHB_FVBc, VMHB_GVBc,
     I     KWO_Lba,   KWO_Lac,
     I     WW,
     I     CVBL,
     I     MH,        LH,       ipKW, iMA)
      RETURN
      END
CCC_ & MSNbic  ## Movement/SSA/non-linear basal drag suite (for initialization)
      subroutine MSNbic
     O    (VV,
     W     W,    CW,
     I     VID,  VI, VHB,
     I     KDR,  KU, KV,   KSL, KBC, KBP,
     I     KOLa, KOLb,
     I     WW,
     I     CVBL,
     I     MH,   LH, ipKW, iMA)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)   MH, LH
      _INTENT(OUT,_REALSTD)  VV  (LH, *)
      _INTENT(OUT,_REALSTD)  W   (LH, *)
      _INTENT(OUT,_REALSTD)  CW  (*)
      _INTENT(IN, _REALSTD)  VI  (LH, *)
      _INTENT(IN, _REALSTD)  VHB (LH, *)
      _INTENT(IN, _REALSTD)  VID (LH, *)
      _INTENT(IN, _REALSTD)  WW (LH, *)
      _INTENT(IN, _REALSTD)  CVBL
      _INTENT(IN, integer)   KDR
      _INTENT(IN, integer)   KU, KV
      _INTENT(IN, integer)   KSL
      _INTENT(IN, integer)   KBC, KBP
      _INTENT(IN, integer)   KOLa, KOLb
      _INTENT(IN, integer)   ipKW (*)
      _INTENT(IN, integer)   iMA  (*)
      integer jp
      _REALSTD U, V, P
      _REALSTD BDC, BDP
      _REALSTD tvlsq
CCC_  - Body
      tvlsq = CVBL * CVBL
CCC_   . v:b
CCC_    * B1: v:a
      call AKBwaz
     O    (W   (1, VMSZ_B1),  CW,
     I     VID (1, KV),       WW,
     I     MH,   LH,  ipKW, iMA,  KOLa, KWM_M)
CCC_    * v:b
      call AKBwax
     O    (W,    CW,
     I     WW,
     I     MH,   LH,  VMSZ_Vb, VMSZ_B1,
     I     ipKW, iMA, KOLb,    KWM_M)
CCC_   . coeff:b
      do jp = 1, MH
         BDC = VHB (jp, KBC)
         BDP = VHB (jp, KBP)
         P = (BDP - 1.0d0)/2.0d0
         U = VID (jp, KU)
         V = MAX (tvlsq, (U**2.0d0 + W (jp, VMSZ_Vb)**2.0d0))
         VV (jp, KDR) = VI (jp, KSL) * BDC * (V ** P)
c$$$         if (V.lt.CVBL) then
c$$$            VV (jp, KDR) = 0.0d0
c$$$         else
c$$$            VV (jp, KDR) = VI (jp, KSL) * BDC * (V ** P)
c$$$         endif
      enddo
      RETURN
      END
CCC_ & MSNbdr  ## Movement/SSA/non-linear basal drag suite
      subroutine MSNbdr
     O    (VV,
     W     W,   CW,
     I     VX,  VI,  VHB,
     I     WW,
     I     CVBL,
     I     KXX, MH,  LH, LXK, ipKW, iMA)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)   MH, LH, LXK, KXX
      _INTENT(OUT,_REALSTD)  VV  (LH, *)
      _INTENT(OUT,_REALSTD)  W   (LH, *)
      _INTENT(OUT,_REALSTD)  CW  (*)
      _INTENT(IN, _REALSTD)  VI  (LH, *)
      _INTENT(IN, _REALSTD)  VHB (LH, *)
      _INTENT(IN, _REALSTD)  VX  (LH, LXK, *)
      _INTENT(IN, _REALSTD)  WW (LH, *)
      _INTENT(IN, _REALSTD)  CVBL
      _INTENT(IN, integer)   ipKW (*)
      _INTENT(IN, integer)   iMA  (*)
      integer jp
      _REALSTD U, V, P
      _REALSTD BDC, BDP
      _REALSTD tvlsq
CCC_  - Body
      tvlsq = CVBL * CVBL
CCC_   . v:b
CCC_    * B1: v[E]:a  from v[E]:c
      call AKBwaz
     O    (W  (1, VMSZ_B1),       CW,
     I     VX (1, VMSX_VcE, KXX), WW,
     I     MH,   LH,  ipKW, iMA,  KWO_Lca, KWM_M)
CCC_    * B2: v[W]:a  from v[W]:c
      call AKBwaz
     O    (W  (1, VMSZ_B2),       CW,
     I     VX (1, VMSX_VcW, KXX), WW,
     I     MH,   LH,  ipKW, iMA,  KWO_Lca, KWM_M)
CCC_    * v:b from [EW]
      call AKBwbx
     O    (W,  CW,
     I     WW,
     I     MH, LH, VMSZ_Vb, VMSZ_B1, VMSZ_B2,
     I     ipKW,   iMA,     KWO_Lab, KWM_M)
CCC_   . coeff:b
      do jp = 1, MH
         BDC = VHB (jp, VMHB_FVBb)
         BDP = VHB (jp, VMHB_GVBb)
         P = (BDP - 1.0d0)/2.0d0
         U = (VX (jp, VMSX_UbN, KXX) + VX (jp, VMSX_UbS, KXX)) / 2.0d0
         V = MAX (tvlsq, (U**2.0d0 + W (jp, VMSZ_Vb)**2.0d0))
         VV (jp, VMSV_BDb) = VI (jp, VMI_SLDb) * BDC * (V ** P)
c$$$         V = (U**2.0d0 + W (jp, VMSZ_Vb)**2.0d0)
c$$$         if (V.lt.CVBL) then
c$$$            VV (jp, VMSV_BDb) = 0.0d0
c$$$         else
c$$$            VV (jp, VMSV_BDb) = VI (jp, VMI_SLDb) * BDC * (V ** P)
c$$$         endif
c$$$         write (*, *) jp, V, VV (jp, VMSV_BDb),
c$$$     $        ((35.0d0 ** 2.0d0) ** P) * BDC * 35.0d0
      enddo
CCC_   . u:c
CCC_    * B1: u[N]:a  from u[N]:b
      call AKBwaz
     O    (W  (1, VMSZ_B1),       CW,
     I     VX (1, VMSX_UbN, KXX), WW,
     I     MH,   LH,  ipKW, iMA,  KWO_Lba, KWM_M)
CCC_    * B2: u[S]:a  from u[S]:b
      call AKBwaz
     O    (W  (1, VMSZ_B2),       CW,
     I     VX (1, VMSX_UbS, KXX), WW,
     I     MH,   LH,  ipKW, iMA,  KWO_Lba, KWM_M)
CCC_    * u:c from [NS]
      call AKBwbx
     O    (W,  CW,
     I     WW,
     I     MH, LH, VMSZ_Uc, VMSZ_B1, VMSZ_B2,
     I     ipKW,   iMA,     KWO_Lac, KWM_M)
CCC_   . coeff:c
      do jp = 1, MH
         BDC = VHB (jp, VMHB_FVBc)
         BDP = VHB (jp, VMHB_GVBc)
         P = (BDP - 1.0d0)/2.0d0
         U = (VX (jp, VMSX_VcE, KXX) + VX (jp, VMSX_VcW, KXX)) / 2.0d0
         V = MAX (tvlsq, (U**2.0d0 + W (jp, VMSZ_Uc)**2.0d0))
         VV (jp, VMSV_BDc) = VI (jp, VMI_SLDc) * BDC * (V ** P)
c$$$         if (V.le.CVBL) then
c$$$            VV (jp, VMSV_BDc) = 0.0d0
c$$$         else
c$$$            VV (jp, VMSV_BDc) = VI (jp, VMI_SLDc) * BDC * (V ** P)
c$$$         endif
      enddo
CC    ABS (U**2+V**2) ** (P/2)
CC    V = L: [(L: VcE+VcW)n + (L: VcE+VcW)s]
c$$$      do jp = 1, MH
c$$$         U = (VX (jp, VMSX_UbN, KXX) + VX (jp, VMSX_UbS, KXX)) / 2.0d0
c$$$         VV (jp, VMSV_BDb) = VI (jp, VMI_SLDb) * BDC * (ABS (U) ** P)
c$$$         U = (VX (jp, VMSX_VcE, KXX) + VX (jp, VMSX_VcW, KXX)) / 2.0d0
c$$$         VV (jp, VMSV_BDc) = VI (jp, VMI_SLDc) * BDC * (ABS (U) ** P)
c$$$      enddo
      RETURN
      END
CCC_ & MSNulm  ## Movement/SSA/non-linear limit solution
      subroutine MSNulm
     M    (VX,
     I     UMX, KXX, MH, LH, LXK)
CCC_  - Declaration
      implicit none
      _INTENT(IN,    integer) MH, LH, LXK, KXX
      _INTENT(INOUT,_REALSTD) VX (LH, LXK, *)
      _INTENT(IN,   _REALSTD) UMX
      integer  jh
CCC_  - Body
      if (UMX.gt.0.0d0) then
         do jh = 1, MH
            VX(jh,VMSX_UbS,KXX) = MAX(-UMX,MIN(UMX,VX(jh,VMSX_UbS,KXX)))
            VX(jh,VMSX_UbN,KXX) = MAX(-UMX,MIN(UMX,VX(jh,VMSX_UbN,KXX)))
            VX(jh,VMSX_VcW,KXX) = MAX(-UMX,MIN(UMX,VX(jh,VMSX_VcW,KXX)))
            VX(jh,VMSX_VcE,KXX) = MAX(-UMX,MIN(UMX,VX(jh,VMSX_VcE,KXX)))
         enddo
      endif
      RETURN
      END
CCC_ & MSNupv  ## Movement/SSA/non-linear update viscosity suite
      subroutine MSNupv
     O    (VV,
     W     W,   CW,
     I     VC,  VE,   VX,
     I     WW,
     I     PF,  ESRL, UXLIMU,
     I     KXX, MH,   LH, LXK, LCG, ipCG, ipKW, iMA)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)   MH, LH, LXK, KXX, LCG
      _INTENT(OUT,_REALSTD)  VV (LH, *)
      _INTENT(OUT,_REALSTD)  W  (LH, *)
      _INTENT(OUT,_REALSTD)  CW (*)
      _INTENT(IN, _REALSTD)  VC (LH, *)
      _INTENT(IN, _REALSTD)  VE (LH, *)
      _INTENT(IN, _REALSTD)  VX (LH, LXK, *)
      _INTENT(IN, _REALSTD)  WW (LH, *)
      _INTENT(IN, _REALSTD)  PF, ESRL, UXLIMU
      _INTENT(IN, integer)   ipKW (*)
      _INTENT(IN, integer)   iMA  (*)
      _INTENT(IN, integer)   ipCG (LCG, *)
      integer  KT, KSW
      integer  jh
CCC_  - Body
      KT  = 1
      KSW = KWM_M
#if OPT_SSA_CORNER_FIXED
CCC_   . preparation
#if 0  /* new ux suite */
CCC_    * Clone
      call AKCgux
     O    (CW,
     I     VX (1, VMSX_UbS, KXX),
     I     MH, LH, KT, iMA, ipCG (1, CGS_UbS))
      call AKCgux
     O    (CW,
     I     VX (1, VMSX_VcW, KXX),
     I     MH, LH, KT, iMA, ipCG (1, CGS_VcW))
      call AKCgux
     O    (CW,
     I     VX (1, VMSX_UbN, KXX),
     I     MH, LH, KT, iMA, ipCG (1, CGS_UbN))
      call AKCgux
     O    (CW,
     I     VX (1, VMSX_VcE, KXX),
     I     MH, LH, KT, iMA, ipCG (1, CGS_VcE))
CCC_    * UXa
      call AKGwaz
     O    (W (1, VMSZ_B1),
     I     CW,   VX (1, VMSX_UbS, KXX),  WW,
     I     MH,   LH,  ipKW, 1, ipCG (1, CGS_UbS))
      call AKGwaz
     O    (W (1, VMSZ_B2),
     I     CW,   VX (1, VMSX_UbN, KXX),  WW,
     I     MH,   LH,  ipKW, 1, ipCG (1, CGS_UbN))
      do jh = 1, MH
         VV(jh, VMSV_UXa) = (W(jh, VMSZ_B1)+W(jh, VMSZ_B2))*0.5d0
      enddo
CCC_    * VYa
      call AKGwaz
     O    (W (1, VMSZ_B1),
     I     CW,   VX (1, VMSX_VcE, KXX),  WW,
     I     MH,   LH,  ipKW, 1, ipCG (1, CGS_VcE))
      call AKGwaz
     O    (W (1, VMSZ_B2),
     I     CW,   VX (1, VMSX_VcW, KXX),  WW,
     I     MH,   LH,  ipKW, 1, ipCG (1, CGS_VcW))
      do jh = 1, MH
         VV(jh, VMSV_VYa) = (W(jh, VMSZ_B1)+W(jh, VMSZ_B2))*0.5d0
      enddo
CCC_    * UYd (to URb, temporal)
      call AKGwaz
     O    (W (1, VMSZ_B1),
     I     CW,   VX (1, VMSX_UbS, KXX),  WW,
     I     MH,   LH,  ipKW, 2, ipCG (1, CGS_UbS))
      call AKGwaz
     O    (W (1, VMSZ_B2),
     I     CW,   VX (1, VMSX_UbN, KXX),  WW,
     I     MH,   LH,  ipKW, 2, ipCG (1, CGS_UbN))
      do jh = 1, MH
         VV(jh, VMSZ_URb) = (W(jh, VMSZ_B1)+W(jh, VMSZ_B2))*0.5d0
      enddo
CCC_    * VXd (to URc, temporal)
      call AKGwaz
     O    (W (1, VMSZ_B1),
     I     CW,   VX (1, VMSX_VcE, KXX),  WW,
     I     MH,   LH,  ipKW, 2, ipCG (1, CGS_VcE))
      call AKGwaz
     O    (W (1, VMSZ_B2),
     I     CW,   VX (1, VMSX_VcW, KXX),  WW,
     I     MH,   LH,  ipKW, 2, ipCG (1, CGS_VcW))
      do jh = 1, MH
         VV(jh, VMSZ_URc) = (W(jh, VMSZ_B1)+W(jh, VMSZ_B2))*0.5d0
      enddo
CCC_    * URd
      do jh = 1, MH
         W(jh, VMSZ_URd) = (W(jh, VMSZ_URb)+W(jh, VMSZ_URc))*0.5d0
      enddo
CCC_    * ux:a vy:a r:d again with velocity limit
#else /* ux from P */
CCC_    * ux:a use B1,B2
      call MSNugi
     O    (VV,        W,
     I     VX,
     I     VMSV_UXa,
     I     VMSZ_B1,   VMSZ_B2,
     I     VMSZ_UXaE, VMSZ_UXaW, VMSZ_UXaN, VMSZ_UXaS,
     I     VMSV_MUaE, VMSV_MUaW, VMSV_MUaN, VMSV_MUaS,
     I     VMSX_PaE,  VMSX_PaW,  VMSX_PaN,  VMSX_PaS,
     I     VMSX_QaE,  VMSX_QaW,  VMSX_QaN,  VMSX_QaS,
     I     UXLIMU,
     I     KXX,       MH,        LH,        LXK)
CCC_    * vy:a (use B1,B2)
      call MSNugi
     O    (VV,        W,
     I     VX,
     I     VMSV_VYa,
     I     VMSZ_B1,   VMSZ_B2,
     I     VMSZ_VYaE, VMSZ_VYaW, VMSZ_VYaN, VMSZ_VYaS,
     I     VMSV_MUaE, VMSV_MUaW, VMSV_MUaN, VMSV_MUaS,
     I     VMSX_QaE,  VMSX_QaW,  VMSX_QaN,  VMSX_QaS,
     I     VMSX_PaE,  VMSX_PaW,  VMSX_PaN,  VMSX_PaS,
     I     UXLIMU,
     I     KXX,       MH,        LH,        LXK)
c
CCC_    * r:d
c$$$      call UV3nda
c$$$     $     (W, VX (1, 1, KXX), VV, MH, LH, VMSZ_URd, VMSX_RdA, VMSV_MUd)
      call UV3nua
     $    (W, VX (1, 1, KXX), VV, MH, LH,
     $     VMSZ_URd, VMSX_RdA, VMSV_MUd, 0.0d0)
#endif
CCC_   . mu:a
CCC_    * r:a from r:d (use B1,B2)
      call MSNrda
     M    (VV,  W,   CW,
     I     WW,
     I     VMSV_URa,
     I     VMSZ_URb, VMSZ_URc, VMSZ_URd, VMSZ_B1,  VMSZ_B2,
     I     UXLIMU,
     I     MH,       LH,       ipKW,     iMA,      ipCG (1, CGS_URd))
CCC_    * get mu:a (interior) to B1
c$$$      call MSFesr (W,     VMSZ_B1,VMSZ_UXa,VMSZ_VYa,VMSZ_URa, MH,LH)
c$$$      call MSFvsc (W, VC, ESRL, VMSZ_B1,VMSZ_B1,VMSC_BVIa, PF, MH, LH)
c$$$      call MSFesp
c$$$     O    (VV,
c$$$     I     W, ESRL, PF, VMSV_fsrp, VMSZ_UXa,VMSZ_VYa,VMSZ_URa, MH,LH)
      call MSFfsp
     M    (VV,
     I     ESRL, PF, VMSV_fsrp, VMSV_UXa,VMSV_VYa,VMSV_URa, MH,LH)
CC      call MSFvsp (W, VV, VC, VMSZ_B1,VMSV_fsrp,VMSC_BVIa, MH, LH)
      call UV3nma (W, VV, VC, MH, LH, VMSZ_B1, VMSV_fsrp, VMSC_BVIa)
CCC_    * update mu:a = (1 - I) old + I new
      call UV1uma (W, VC, MH, LH, VMSZ_B1, VMSC_Da_MI)
      call UV3nca
     $     (W, VC, VV, MH, LH, VMSZ_B2, VMSC_Da_MI, VMSV_MUa, 1.0d0)
      call UV2naa (VV, W, MH, LH, VMSV_MUa, VMSZ_B1, VMSZ_B2)
CCC_   . mu:a others
      call UV3nca
     $     (W, VC, VV, MH, LH, VMSZ_B2, VMSC_Da_MI, VMSV_MUaN, 1.0d0)
      call UV2naa (VV, W, MH, LH, VMSV_MUaN, VMSZ_B1, VMSZ_B2)
      call UV3nca
     $     (W, VC, VV, MH, LH, VMSZ_B2, VMSC_Da_MI, VMSV_MUaS, 1.0d0)
      call UV2naa (VV, W, MH, LH, VMSV_MUaS, VMSZ_B1, VMSZ_B2)
      call UV3nca
     $     (W, VC, VV, MH, LH, VMSZ_B2, VMSC_Da_MI, VMSV_MUaE, 1.0d0)
      call UV2naa (VV, W, MH, LH, VMSV_MUaE, VMSZ_B1, VMSZ_B2)
      call UV3nca
     $     (W, VC, VV, MH, LH, VMSZ_B2, VMSC_Da_MI, VMSV_MUaW, 1.0d0)
      call UV2naa (VV, W, MH, LH, VMSV_MUaW, VMSZ_B1, VMSZ_B2)
CCC_   . mu:d
CCC_    * interior
CCC_     + ux:d from ux:a
      call MSNgad
     M    (W,    CW,
     I     VV,   WW,
     I     VMSZ_UXd,  VMSZ_UXb, VMSZ_UXc,
     I     VMSZ_B1,   VMSZ_B2,
     I     VMSV_UXa,
     I     MH,   LH,  ipKW, iMA, ipCG (1, CGS_UXa))
CCC_     + vy:d from vy:a
      call MSNgad
     M    (W,    CW,
     I     VV,   WW,
     I     VMSZ_VYd,  VMSZ_VYb, VMSZ_VYc,
     I     VMSZ_B1,   VMSZ_B2,
     I     VMSV_VYa,
     I     MH,   LH,  ipKW, iMA, ipCG (1, CGS_VYa))
CCC_     + get mu:d
c$$$      call MSFesr (W,     VMSZ_B1,VMSZ_UXd,VMSZ_VYd,VMSZ_URd, MH,LH)
c$$$      call MSFvsc (W, VC, ESRL, VMSZ_B1,VMSZ_B1,VMSC_BVId, PF, MH, LH)
c$$$      call MSFesp
c$$$     O    (VV,
c$$$     I     W, ESRL, PF, VMSV_fsrpd, VMSZ_UXd,VMSZ_VYd,VMSZ_URd, MH,LH)
      call MSFfsp
     M    (W,
     I     ESRL, PF, VMSZ_B1, VMSZ_UXd,VMSZ_VYd,VMSZ_URd, MH,LH)
C      B1(fsrp)*=BVId
c$$$  call MSFvsp (W, VV, VC, VMSZ_B1,VMSV_fsrpd,VMSC_BVId, MH, LH)
      call UV1uma (W, VC, MH, LH, VMSZ_B1, VMSC_BVId)
CCC_    * update mu:d = (1 - I) old + I new
      call UV1uma (W, VC, MH, LH, VMSZ_B1, VMSC_Rd_MI)
      call UV3nca
     $     (W, VC, VV, MH, LH, VMSZ_B2, VMSC_Rd_MI, VMSV_MUd, 1.0d0)
      call UV2naa (VV, W, MH, LH, VMSV_MUd, VMSZ_B1, VMSZ_B2)
CCC_    * update
#else /* not OPT_SSA_CORNER_FIXED */
#error "not implemented yet"
CCC_   . Mu:a
CCC_    * PQ to ux conversion
      call MSFdux
     $    (W, VX (1, 1, KXX), VV,
     $     VMSZ_UXaN, VMSX_PaN, VMSX_QaN, VMSV_MUaN,  MH, LH)
      call MSFdux
     $    (W, VX (1, 1, KXX), VV,
     $     VMSZ_UXaS, VMSX_PaS, VMSX_QaS, VMSV_MUaS,  MH, LH)
      call MSFdux
     $    (W, VX (1, 1, KXX), VV,
     $     VMSZ_UXaE, VMSX_PaE, VMSX_QaE, VMSV_MUaE,  MH, LH)
      call MSFdux
     $    (W, VX (1, 1, KXX), VV,
     $     VMSZ_UXaW, VMSX_PaW, VMSX_QaW, VMSV_MUaW,  MH, LH)
CCC_    * PQ to vy conversion
      call MSFdux
     $    (W, VX (1, 1, KXX), VV,
     $     VMSZ_VYaN, VMSX_QaN, VMSX_PaN, VMSV_MUaN,  MH, LH)
      call MSFdux
     $    (W, VX (1, 1, KXX), VV,
     $     VMSZ_VYaS, VMSX_QaS, VMSX_PaS, VMSV_MUaS,  MH, LH)
      call MSFdux
     $    (W, VX (1, 1, KXX), VV,
     $     VMSZ_VYaE, VMSX_QaE, VMSX_PaE, VMSV_MUaE,  MH, LH)
      call MSFdux
     $    (W, VX (1, 1, KXX), VV,
     $     VMSZ_VYaW, VMSX_QaW, VMSX_PaW, VMSV_MUaW,  MH, LH)
CCC_    * R to ur conversion
      call UV3nda
     $     (W, VX (1, 1, KXX), VV, MH, LH, VMSZ_URd, VMSX_RdA, VMSV_MUd)
CCC_    * group clone  1:Ldb 2:Ldc
      call AKCgux
     O    (CW,
     I     W (1, VMSZ_URd),
     I     MH, LH, KT, iMA, ipCG (1, CGS_URd))
CCC_    * ur:b
      call AKGwax
     O    (W,
     I     CW,   WW,
     I     MH,   LH,  VMSZ_URb, VMSZ_URd,
     I     ipKW, 1,   ipCG (1, CGS_URd))
CCC_    * ur:c
      call AKGwax
     O    (W,
     I     CW,   WW,
     I     MH,   LH,  VMSZ_URc, VMSZ_URd,
     I     ipKW, 2,   ipCG (1, CGS_URd))
CCC_    * ur:a by b
      call AKBwax
     M    (W,    CW,
     I     WW,
     I     MH,   LH,  VMSZ_B1, VMSZ_URb,
     I     ipKW, iMA, KWO_Lba, KSW)
CCC_    * ur:a by c
      call AKBwax
     M    (W,    CW,
     I     WW,
     I     MH,   LH,  VMSZ_B2, VMSZ_URc,
     I     ipKW, iMA, KWO_Lca, KSW)
CCC_    * ur:a (interior)
      call UV0naa (W, MH,LH, VMSZ_URa, VMSZ_B1, VMSZ_B2)
      call UV0uwa (W, MH,LH, VMSZ_URa, 2.0d0)
CCC_    * u:a (EW)
      call UV0naa (W, MH,LH, VMSZ_B1,  VMSZ_UXaW, VMSZ_UXaE)
CCC_    * u:a (NS)
      call UV0naa (W, MH,LH, VMSZ_B2,  VMSZ_UXaS, VMSZ_UXaN)
CCC_    * u:a      to B3
      call UV0naa (W, MH,LH, VMSZ_B3,  VMSZ_B1,   VMSZ_B2)
      call UV0uwa (W, MH,LH, VMSZ_B3,  0.25d0)
CCC_    * v:a (EW)
      call UV0naa (W, MH,LH, VMSZ_B1,  VMSZ_VYaW, VMSZ_VYaE)
CCC_    * v:a (NS)
      call UV0naa (W, MH,LH, VMSZ_B2,  VMSZ_VYaS, VMSZ_VYaN)
CCC_    * v:a      to B4
      call UV0naa (W, MH,LH, VMSZ_B4,  VMSZ_B1,   VMSZ_B2)
      call UV0uwa (W, MH,LH, VMSZ_B4,  0.25d0)
CCC_    * MU:a
      call MSUesr (VV,W, VMSV_MUa,VMSZ_B3,VMSZ_B4,VMSZ_URa, MH,LH)
CCC_    * group clone  1:Lab 2:Lac
      call AKCgux
     O    (CW,
     I     W (1, VMSZ_URa),
     I     MH, LH, KT, iMA, ipCG (1, CGS_URa))
CCC_    * ur:ab to ur[E]:a ghost
      call MSUxaM
     O    (W,
     I     CW,      VE,      WW,
     I     MH,      LH,
     I     VMSZ_B1, VMSZ_URa, VMSZ_URb, VMSE_Ebaa, VMSE_Ebab,
     I     ipKW,    1,        ipCG (1, CGS_URa))
CCC_    * MU[E]:a
      call MSUesr (VV,W, VMSV_MUaE,VMSZ_UXaE,VMSZ_VYaE,VMSZ_B1, MH,LH)
CCC_    * ur:ab to ur[W]:a ghost
      call MSUxaP
     O    (W,       CW,
     I     VE,      WW,
     I     MH,      LH,
     I     VMSZ_B1, VMSZ_URa, VMSZ_URb, VMSE_abWa, VMSE_abWb,
     I     ipKW,    iMA,      KWO_Lab,  KWM_T)
CCC_    * MU[W]:a
      call MSUesr (VV,W, VMSV_MUaW,VMSZ_UXaW,VMSZ_VYaW,VMSZ_B1, MH,LH)
CCC_    * ur:ac to ur[N]:a ghost
      call MSUxaM
     O    (W,
     I     CW,      VE,      WW,
     I     MH,      LH,
     I     VMSZ_B1, VMSZ_URa, VMSZ_URc, VMSE_Ncaa, VMSE_Ncac,
     I     ipKW,    2,        ipCG (1, CGS_URa))
CCC_    * MU[N]:a
      call MSUesr (VV,W, VMSV_MUaN,VMSZ_UXaN,VMSZ_VYaN,VMSZ_B1, MH,LH)
CCC_    * ur:ac to ur[S]:a ghost
      call MSUxaP
     O    (W,       CW,
     I     VE,      WW,
     I     MH,      LH,
     I     VMSZ_B1, VMSZ_URa, VMSZ_URc, VMSE_acSa, VMSE_acSc,
     I     ipKW,    iMA,      KWO_Lac,  KWM_T)
CCC_   . interior ux:a
CCC_    * B1:   2P - Q
CCC_    * uxa: B1 / mu
CCC_    * uxa: uxa / 6
CCC_   . ux:d interior
CCC_    * B1: ux:a to ux:b
CCC_    * B2: ux:b to ux:d
CCC_    * B1: ux:a to ux:c
CCC_    * B3: ux:c to ux:d
CCC_    * uxd: (B2 + B3) / 2
CCC_   . ux:d corner
CCC_   . ux:d done
CCC_   . interior vy:a
CCC_    * B1:   2Q - P
CCC_    * dvdy: B1 / mu
CCC_    * dvdy: dvdy / 6
CCC_   . ur:d
CCC_   . ur:b
CCC_   . ur:c
CCC_   . ur:a
CCC_   . ur:a ghost
CCC_   . ur:a done
CCC_   . update mu:a
CCC_   . update mu:d
#endif /* not OPT_SSA_CORNER_FIXED */
      RETURN
      END
CCC_ & MSNdsr  ## Movement/SSA/non-linear stress strain-rate diag
      subroutine MSNdsr
     O    (VV,
     W     W,   CW,
     I     VC,  VE, VX,
     I     WW,
     I     PF,  ESRL,UXLIMU,
     I     KXX, MH,  LH, LXK, LCG, ipCG, ipKW, iMA)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)   MH, LH, LXK, KXX, LCG
      _INTENT(INOUT, _REALSTD)  VV (LH, *)
      _INTENT(OUT,_REALSTD)  W  (LH, *)
      _INTENT(OUT,_REALSTD)  CW (*)
      _INTENT(IN, _REALSTD)  VC (LH, *)
      _INTENT(IN, _REALSTD)  VE (LH, *)
      _INTENT(IN, _REALSTD)  VX (LH, LXK, *)
      _INTENT(IN, _REALSTD)  WW (LH, *)
      _INTENT(IN, _REALSTD)  PF, ESRL, UXLIMU
      _INTENT(IN, integer)   ipKW (*)
      _INTENT(IN, integer)   iMA  (*)
      _INTENT(IN, integer)   ipCG (LCG, *)
      integer  KT, KSW
      _REALSTD UXMX
CCC_  - Body
      KT  = 1
      KSW = KWM_M
#if OPT_SSA_CORNER_FIXED
CCC_   . preparation
CCC_    * ux:a use B1,B2
      call MSNugi
     O    (VV,        W,
     I     VX,
     I     VMSV_UXa,
     I     VMSZ_B1,   VMSZ_B2,
     I     VMSZ_UXaE, VMSZ_UXaW, VMSZ_UXaN, VMSZ_UXaS,
     I     VMSV_MUaE, VMSV_MUaW, VMSV_MUaN, VMSV_MUaS,
     I     VMSX_PaE,  VMSX_PaW,  VMSX_PaN,  VMSX_PaS,
     I     VMSX_QaE,  VMSX_QaW,  VMSX_QaN,  VMSX_QaS,
     I     UXLIMU,
     I     KXX,       MH,        LH,        LXK)
CCC_    * vy:a (use B1,B2)
      call MSNugi
     O    (VV,        W,
     I     VX,
     I     VMSV_VYa,
     I     VMSZ_B1,   VMSZ_B2,
     I     VMSZ_VYaE, VMSZ_VYaW, VMSZ_VYaN, VMSZ_VYaS,
     I     VMSV_MUaE, VMSV_MUaW, VMSV_MUaN, VMSV_MUaS,
     I     VMSX_QaE,  VMSX_QaW,  VMSX_QaN,  VMSX_QaS,
     I     VMSX_PaE,  VMSX_PaW,  VMSX_PaN,  VMSX_PaS,
     I     UXLIMU,
     I     KXX,       MH,        LH,        LXK)
CCC_    * r:d
      call UV3nua
     $    (W, VX (1, 1, KXX), VV, MH, LH,
     $     VMSZ_URd, VMSX_RdA, VMSV_MUd, 0.0d0)
CCC_    * r:a from r:d (use B1,B2)
      call MSNrda
     M    (VV,  W,   CW,
     I     WW,
     I     VMSV_URa,
     I     VMSZ_URb, VMSZ_URc, VMSZ_URd, VMSZ_B1,  VMSZ_B2,
     I     UXLIMU,
     I     MH,       LH,       ipKW,     iMA,      ipCG (1, CGS_URd))
#else /* not OPT_SSA_CORNER_FIXED */
#error "not implemented yet"
#endif /* not OPT_SSA_CORNER_FIXED */
      RETURN
      END
CCC_ & MSNugi  ## interior d:a to g:a batch
      subroutine MSNugi
     O    (VV,   W,
     I     VX,
     I     KVga, KW1,  KW2,
     I     KgE,  KgW,  KgN,  KgS,
     I     KmuE, KmuW, KmuN, KmuS,
     I     KpE,  KpW,  KpN,  KpS,
     I     KqE,  KqW,  KqN,  KqS,
     I     UXLIMU,
     I     KXX,  MH,   LH,   LXK)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)   MH, LH, KXX, LXK
      _INTENT(INOUT,_REALSTD)  VV (LH, *)
      _INTENT(OUT,  _REALSTD)  W  (LH, *)
      _INTENT(IN,   _REALSTD)  VX (LH, LXK, *)
      _INTENT(IN,   _REALSTD)  UXLIMU
      _INTENT(IN,   integer)   KVga
      _INTENT(IN,   integer)   KW1,  KW2
      _INTENT(IN,   integer)   KgE,  KgW,  KgN,  KgS
      _INTENT(IN,   integer)   KmuE, KmuW, KmuN, KmuS
      _INTENT(IN,   integer)   KpE,  KpW,  KpN,  KpS
      _INTENT(IN,   integer)   KqE,  KqW,  KqN,  KqS
      integer jh
CCC_  - Body
      call MSFdux
     $    (W, VX (1,1,KXX), VV, KgN, KpN, KqN, KmuN, MH, LH)
      call MSFdux
     $    (W, VX (1,1,KXX), VV, KgS, KpS, KqS, KmuS, MH, LH)
      call MSFdux
     $    (W, VX (1,1,KXX), VV, KgE, KpE, KqE, KmuE, MH, LH)
      call MSFdux
     $    (W, VX (1,1,KXX), VV, KgW, KpW, KqW, KmuW, MH, LH)
c
      call UV0naa (W, MH,LH, KW1,  KgE, KgW)
      call UV0naa (W, MH,LH, KW2,  KgN, KgS)
c
c$$$      call UV0naa (W, MH,LH, KgA,  KW1, KW2)
c$$$      call UV0uwa (W, MH,LH, kgA,  0.25d0)
      call UV2naa (VV, W, MH,LH, KVga,  KW1, KW2)
      call UV0uwa (VV,    MH,LH, kVga,  0.25d0)
      if (UXLIMU.gt.0.0d0) then
         do jh = 1, MH
            VV(jh, KVga) = MAX(-UXLIMU,MIN(UXLIMU,VV(jh, KVga)))
         enddo
      endif
c
      RETURN
      END
CCC_ & MSNrda  ## interior r:a average
      subroutine MSNrda
     M    (VV,  W,   CW,
     I     WW,
     I     KVRa,
     I     KRb, KRc, KRd,  KW1, KW2,
     I     UXLIMU,
     I     MH,  LH,  ipKW, iMA, ipCG)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)   MH, LH
      _INTENT(IN, integer)   KVRa
      _INTENT(IN, integer)   KRb, KRc, KRd
      _INTENT(IN, integer)   KW1, KW2
      _INTENT(OUT,_REALSTD)  VV (LH, *)
      _INTENT(OUT,_REALSTD)  W  (LH, *)
      _INTENT(OUT,_REALSTD)  CW (*)
      _INTENT(IN, _REALSTD)  WW (LH, *)
      _INTENT(IN, integer)   ipKW (*)
      _INTENT(IN, integer)   iMA  (*)
      _INTENT(IN, integer)   ipCG (*)
      _INTENT(IN, _REALSTD)  UXLIMU
      integer  KT, KSW
      integer  jh
CCC_  - Body
      KT  = 1
      KSW = KWM_M
CCC_   . group clone  1:Ldb 2:Ldc
      call AKCgux
     O    (CW,
     I     W (1, KRd),
     I     MH, LH, KT, iMA, ipCG)
CCC_   . ur:b
      call AKGwax
     O    (W,
     I     CW,   WW,
     I     MH,   LH, KRb, KRd,
     I     ipKW, 1,  ipCG)
CCC_   . ur:c
      call AKGwax
     O    (W,
     I     CW,   Ww,
     I     MH,   LH, KRc, KRd,
     I     ipKW, 2,  ipCG)
CCC_   . ur:a by b
      call AKBwax
     M    (W,    CW,
     I     WW,
     I     MH,   LH,  KW1,     KRb,
     I     ipKW, iMA, KWO_Lba, KSW)
CCC_   . ur:a by c
      call AKBwax
     M    (W,    CW,
     I     WW,
     I     MH,   LH,  KW2,     KRc,
     I     ipKW, iMA, KWO_Lca, KSW)
CCC_   . ur:a (interior)  to VV
c$$$      call UV0naa (W, MH,LH, KRa, KW1, KW2)
c$$$      call UV0uwa (W, MH,LH, KRa, 0.5d0)
      call UV2naa (VV, W, MH, LH, KVRa, KW1, KW2)
      call UV0uwa (VV, MH,LH, KVRa, 0.5d0)
c
      if (UXLIMU.gt.0.0d0) then
         do jh = 1, MH
            VV(jh, KVRa) = MAX(-UXLIMU,MIN(UXLIMU,VV(jh, KVRa)))
         enddo
      endif
c
      RETURN
      END
CCC_ & MSNgad  ## interior g:d average
      subroutine MSNgad
     M    (W,    CW,
     I     VV,   WW,
     I     KGd,  KGb, KGc,
     I     KW1,  KW2,
     I     KVGa,
     I     MH,   LH,  ipKW, iMA, ipCG)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)   MH, LH
      _INTENT(IN, integer)   KGb, KGc, KGd
      _INTENT(IN, integer)   KW1, KW2
      _INTENT(IN, integer)   KVGa
      _INTENT(IN, _REALSTD)  VV (LH, *)
      _INTENT(OUT,_REALSTD)  W  (LH, *)
      _INTENT(OUT,_REALSTD)  CW (*)
      _INTENT(IN, _REALSTD)  WW (LH, *)
      _INTENT(IN, integer)   ipKW (*)
      _INTENT(IN, integer)   iMA  (*)
      _INTENT(IN, integer)   ipCG (*)
      integer  KT, KSW
CCC_  - Body
      KT  = 1
      KSW = KWM_M
c$$$CCC_   . group clone  1:Lab 2:Lac
c$$$      call AKCgux
c$$$     O    (CW,
c$$$     I     W (1, KGa),
c$$$     I     MH, LH, KT, iMA, ipCG)
c$$$CCC_   . ux:b
c$$$      call AKGwax
c$$$     O    (W,
c$$$     I     CW,   WW,
c$$$     I     MH,   LH,  KGb, KGa,
c$$$     I     ipKW, 1,   ipCG)
c$$$CCC_   . ux:c
c$$$      call AKGwax
c$$$     O    (W,
c$$$     I     CW,   WW,
c$$$     I     MH,   LH,  KGc, KGa,
c$$$     I     ipKW, 2,   ipCG)
CCC_   . group clone  1:Lab 2:Lac
      call AKCgux
     O    (CW,
     I     VV (1, KVGa),
     I     MH, LH, KT, iMA, ipCG)
CCC_   . ux:b
      call AKGwaz
     O    (W (1, KGb),
     I     CW,   VV (1, KVGa), WW,
     I     MH,   LH,  ipKW, 1, ipCG)
CCC_   . ux:c
      call AKGwaz
     O    (W (1, KGc),
     I     CW,   VV (1, KVGa), WW,
     I     MH,   LH,  ipKW, 2, ipCG)
CC_   . ux:d by b
      call AKBwax
     M    (W,    CW,
     I     WW,
     I     MH,   LH,  KW1,     KGb,
     I     ipKW, iMA, KWO_Lbd, KSW)
CCC_   . ux:d by c
      call AKBwax
     M    (W,    CW,
     I     WW,
     I     MH,   LH,  KW2,     KGc,
     I     ipKW, iMA, KWO_Lcd, KSW)
CCC_   . ux:d (interior)
      call UV0naa (W, MH,LH, KGd, KW1, KW2)
      call UV0uwa (W, MH,LH, KGd, 0.5d0)
c
      RETURN
      END
CCC_& MSNmdv  ## Movement/SSA/modify 3d velocities
      subroutine MSNmdv
     O    (iErr,
     W     VMW,
     O     VMTI,  VMTW, VMID,
     I     VMI,   VMC,  VMHB,
     I     VMSC,  VMSV, VMSE, VMSX, WZV,
     I     DENS,  GRAV, PF,   FG,
     I     MH,    LH,   NZ,   LZ,   KZ0,  KXX, LXK,
     I     IMS,   MTYP)
CCC_ + Description
CC     Output:  uh:b  vh:c  (horizontal velocity without basal)
CC              ub:b  vb:c  (basal velocity)
CC              uh:b  vh:c  zeta integral
CC              strain rate
CC              stress
CCC_ + Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
c
      _INTENT(IN,   integer)   MH,  LH, NZ, LZ, KZ0
      _INTENT(IN,   integer)   LXK, KXX
c
      _INTENT(OUT,  _REALSTD)  VMW  (LH, LZ, *)
      _INTENT(INOUT,_REALSTD)  VMTI (LH, LZ, *)
      _INTENT(INOUT,_REALSTD)  VMTW (LH, LZ, *)
      _INTENT(INOUT,_REALSTD)  VMID (LH, *)

      _INTENT(IN,   _REALSTD)  VMSX (LH, LXK, *)
c
      _INTENT(IN,   _REALSTD)  VMHB (LH, *)
      _INTENT(IN,   _REALSTD)  VMI  (LH, *)
      _INTENT(IN,   _REALSTD)  VMC  (LH, *)

      _INTENT(IN,   _REALSTD)  VMSE (LH, *)
      _INTENT(IN,   _REALSTD)  VMSC (LH, *)
      _INTENT(IN,   _REALSTD)  VMSV (LH, *)
c
      _INTENT(IN,   _REALSTD)  WZV  (LZ, *)
c
      _INTENT(IN,   _REALSTD)  DENS, GRAV, PF
      _INTENT(IN,   _REALSTD)  FG (3)
c
      _INTENT(IN,   integer)   IMS (*)
      _INTENT(IN,   integer)   MTYP
c
      integer jp, jz, jz0
      integer itrgl
c
      integer KWMa, KWMb, KWZ
      _REALSTD VISC2
CCC_ + Body
      iErr = 0
c
      call MSNmvs
     O    (iErr,
     O     VMTI,  VMTW, VMID,
     I     VMSC,  VMSC_Ub_MI, VMSC_Vc_MI,
     I     MH,    LH,   NZ,   LZ,   KZ0,
     I     IMS)
CCC_  - mask
      KWZ  = 1
      KWMa = 1
      KWMb = 2
      do jp = 1, MH
         VMW(jp, KWZ, KWMa) = VMSC(jp, VMSC_Da_MI)
         VMW(jp, KWZ, KWMb) = 1.0d0 - VMSC(jp, VMSC_Da_MI)
      enddo
CCC_  - strain-rate 3d
      do jz0 = 0, NZ - 1
         jz = KZ0 + jz0
         do jp = 1, MH
c$$$            write (*, *) 'EX', jp,
c$$$     $           VMTW(jp,jz,VMTW_EXXa),
c$$$     $           VMW(jp, KWZ, KWMb),VMW(jp, KWZ, KWMa),
c$$$     $           VMSV(jp,VMSV_UXa)
            VMTW(jp,jz,VMTW_EXXa) =
     $           VMTW(jp,jz,VMTW_EXXa) * VMW(jp, KWZ, KWMb)
     $           + VMSV(jp,VMSV_UXa)   * VMW(jp, KWZ, KWMa)
            VMTW(jp,jz,VMTW_EYYa) =
     $           VMTW(jp,jz,VMTW_EYYa) * VMW(jp, KWZ, KWMb)
     $           + VMSV(jp,VMSV_VYa)   * VMW(jp, KWZ, KWMa)
            VMTW(jp,jz,VMTW_EXYa) =
     $           VMTW(jp,jz,VMTW_EXYa) * VMW(jp, KWZ, KWMb)
     $           + VMSV(jp,VMSV_URa)   * VMW(jp, KWZ, KWMa)
         enddo
      enddo
c$$$      jz = KZ0
c$$$      do jp = 1, MH
c$$$         write (*, *) 'EX', jp,
c$$$     $        VMTW(jp,jz,VMTW_EXXa),
c$$$     $        VMW(jp, KWZ, KWMb),VMW(jp, KWZ, KWMa),
c$$$     $        VMSV(jp,VMSV_UXa)
c$$$      enddo
CCC_  - stress 3d
      do jz0 = 0, NZ - 1
         jz = KZ0 + jz0
         do jp = 1, MH
            VISC2 = VMSV(jp,VMSV_fsrp) * 2.0d0
            VMTW(jp,jz,VMTW_SXXa) =
     $           VMTW(jp,jz,VMTW_SXXa) * VMW(jp, KWZ, KWMb)
     $           + (VISC2 * VMTW(jp,jz,VMTW_ARFa)
     $              * VMTW(jp,jz,VMTW_EXXa)) * VMW(jp, KWZ, KWMa)
            VMTW(jp,jz,VMTW_SYYa) =
     $           VMTW(jp,jz,VMTW_SYYa) * VMW(jp, KWZ, KWMb)
     $           + (VISC2 * VMTW(jp,jz,VMTW_ARFa)
     $              * VMTW(jp,jz,VMTW_EYYa)) * VMW(jp, KWZ, KWMa)
            VMTW(jp,jz,VMTW_SXYa) =
     $           VMTW(jp,jz,VMTW_SXYa) * VMW(jp, KWZ, KWMb)
     $           + (VISC2 * VMTW(jp,jz,VMTW_ARFa)
     $              * VMTW(jp,jz,VMTW_EXYa)) * VMW(jp, KWZ, KWMa)
         enddo
      enddo
CCC_ + CAUTION
CC     VMSX is not as expected (used for dH/dt computation).
#if 0 /* temporary */
      if (iErr.eq.0) then
         call MSNmvp
     O       (iErr,
     O        VMTI,       VMTW,
     I        VMID,       VMI,       VMSC,
     I        MH,         LH,        NZ, LZ, KZ0,
     I        VMTI_UHb,
     I        VMTW_ziUIb, VMTW_SXZb, VMTW_EXZb,
     I        VMSC_Ub_MI, VMID_UBb)
      endif
      if (iErr.eq.0) then
         call MSNmvp
     O       (iErr,
     O        VMTI,       VMTW,
     I        VMID,       VMI,       VMSC,
     I        MH,         LH,        NZ, LZ, KZ0,
     I        VMTI_VHc,
     I        VMTW_ziVIc, VMTW_SYZc, VMTW_EYZc,
     I        VMSC_Vc_MI, VMID_VBc)
      endif
CCC_  * normal stress and strain rate
      if (iErr.eq.0) then
         call MSNnse
     O       (iErr,
     O        VMTW,
     I        VMTI,  VMID, VMI, VMSC, VMSV, VMSX (1, 1, KXX),
     I        MH,    LH,   NZ,  LZ,   KZ0)
      endif
#endif
CCC_  * when grounding line
c$$$      if (iErr.eq.0) then
c$$$         if (IMS (IMS_ITRGL).gt.0) then
c$$$CCC_   + velocity and integral at grounding line
c$$$CCC_   + normal stress and strain rate
c$$$         endif
c$$$      endif
      if (IMS (IMS_ITRGL).gt.0) then
         call MSNmvs
     O       (iErr,
     O        VMTI, VMTW, VMID,
     I        VMSV, VMSV_UGb_MI, VMSV_VGc_MI,
     I        MH,   LH,   NZ,          LZ, KZ0,
     I        IMS)
      endif
CCC_  * Strain rate
c$$$      jz = KZ0
c$$$      do jp = 1, MH
c$$$         VMTI (jp, jz, VMTI_UHb) =
c$$$     $        +          VMSC(jp,VMSC_Ub_MI)  * VMID (jp, VMID_UBb)
c$$$     $        + (1.0d0 - VMSC(jp,VMSC_Ub_MI)) * VMTI (jp, jz, VMTI_UHb)
c$$$         VMTI (jp, jz, VMTI_VHc) =
c$$$     $        +          VMSC(jp,VMSC_Vc_MI)  * VMID (jp, VMID_VBc)
c$$$     $        + (1.0d0 - VMSC(jp,VMSC_Vc_MI)) * VMTI (jp, jz, VMTI_VHc)
c$$$         VMTW (jp, jz, VMTW_ziUIb) = VMTI (jp, jz, VMTI_UHb)
c$$$         VMTW (jp, jz, VMTW_ziVIc) = VMTI (jp, jz, VMTI_VHc)
c$$$      enddo
c$$$      do jz0 = 1, NZ - 1
c$$$         jz = KZ0 + jz0
c$$$         do jp = 1, MH
c$$$            VMTI (jp, jz, VMTI_UHb)   =
c$$$     $        + (1.0d0-VMSC(jp,VMSC_Ub_MI)) * VMTI (jp, jz, VMTI_UHb)
c$$$            VMTI (jp, jz, VMTI_VHc)   =
c$$$     $        + (1.0d0-VMSC(jp,VMSC_Vc_MI)) * VMTI (jp, jz, VMTI_VHc)
c$$$            VMTW (jp, jz, VMTW_ziUIb) =
c$$$     $        + (1.0d0-VMSC(jp,VMSC_Ub_MI)) * VMTW (jp, jz, VMTW_ziUIb)
c$$$            VMTW (jp, jz, VMTW_ziVIc) =
c$$$     $        + (1.0d0-VMSC(jp,VMSC_Vc_MI)) * VMTW (jp, jz, VMTW_ziVIc)
c$$$         enddo
c$$$      enddo
c$$$      do jz0 = 0, NZ - 1
c$$$         jz = KZ0 + jz0
c$$$         do jp = 1, MH
c$$$            VMTW (jp, jz, VMTW_SXZb) =
c$$$     $        + (1.0d0-VMSC(jp,VMSC_Ub_MI)) * VMTW (jp,jz,VMTW_SXZb)
c$$$            VMTW (jp, jz, VMTW_SYZc) = 0.0d0
c$$$     $        + (1.0d0-VMSC(jp,VMSC_Vc_MI)) * VMTW (jp,jz,VMTW_SYZc)
c$$$            VMTW (jp, jz, VMTW_EXZb) = 0.0d0
c$$$     $        + (1.0d0-VMSC(jp,VMSC_Ub_MI)) * VMTW (jp,jz,VMTW_EXZb)
c$$$            VMTW (jp, jz, VMTW_EYZc) = 0.0d0
c$$$     $        + (1.0d0-VMSC(jp,VMSC_Vc_MI)) * VMTW (jp,jz,VMTW_EYZc)
c$$$         enddo
c$$$      enddo
c$$$CCC_  * vh (equal 0 under SSA)
c$$$      do jz0 = 1, NZ - 1
c$$$         jz = KZ0 + jz0
c$$$         do jp = 1, MH
c$$$            VMTI (jp, jz, VMTI_UHb) =
c$$$     $           + (1.0d0 - VMSC (jp, VMSC_Ub_MI))
c$$$     $           * VMTI (jp, jz, VMTI_UHb)
c$$$            VMTI (jp, jz, VMTI_VHc) =
c$$$     $           + (1.0d0 - VMSC (jp, VMSC_Vc_MI))
c$$$     $           * VMTI (jp, jz, VMTI_VHc)
c$$$         enddo
c$$$      enddo
c$$$      if (itrgl.gt.0) then
c$$$         do jz0 = 1, NZ - 1
c$$$            jz = KZ0 + jz0
c$$$            do jp = 1, MH
c$$$               VMTI (jp, jz, VMTI_UHb) =
c$$$     $              + (1.0d0 - VMSV (jp, VMSV_UGb_MI))
c$$$     $              * VMTI (jp, jz, VMTI_UHb)
c$$$               VMTI (jp, jz, VMTI_VHc) =
c$$$     $              + (1.0d0 - VMSV (jp, VMSV_VGc_MI))
c$$$     $              * VMTI (jp, jz, VMTI_VHc)
c$$$            enddo
c$$$         enddo
c$$$      endif
c$$$CCC_  * vb (from VMID)
c$$$      do jp = 1, MH
c$$$         VMTI (jp, KZ0, VMTI_UHb) = VMID (jp, VMID_UBb)
c$$$         VMTI (jp, KZ0, VMTI_VHc) = VMID (jp, VMID_VBc)
c$$$      enddo
      RETURN
      END
CCC_ & MSNmvs  ## Movement/SSA/modify 3d velocities (sub)
      subroutine MSNmvs
     O    (iErr,
     O     VMTI,  VMTW, VMID,
     I     VMSK,  KUM,  KVM,
     I     MH,    LH,   NZ,   LZ,   KZ0,
     I     IMS)
CCC_ + Declaration
      _INTENT(OUT,  integer)   iErr
c
      _INTENT(IN,   integer)   MH,  LH, NZ, LZ, KZ0
c
      _INTENT(INOUT,_REALSTD)  VMTI (LH, LZ, *)
      _INTENT(INOUT,_REALSTD)  VMTW (LH, LZ, *)
      _INTENT(INOUT,_REALSTD)  VMID (LH, *)
c
      _INTENT(IN,   _REALSTD)  VMSK (LH, *)
      _INTENT(IN,   integer)   KUM,  KVM
c
      _INTENT(IN,   integer)   IMS (*)
c
      integer jz, jp, jz0
CCC_ + Body
      jz = KZ0
      do jp = 1, MH
         VMTI (jp, jz, VMTI_UHb) =
     $        +          VMSK(jp,KUM)  * VMID (jp, VMID_UBb)
     $        + (1.0d0 - VMSK(jp,KUM)) * VMTI (jp, jz, VMTI_UHb)
         VMTI (jp, jz, VMTI_VHc) =
     $        +          VMSK(jp,KVM)  * VMID (jp, VMID_VBc)
     $        + (1.0d0 - VMSK(jp,KVM)) * VMTI (jp, jz, VMTI_VHc)
         VMTW (jp, jz, VMTW_ziUIb) = VMTI (jp, jz, VMTI_UHb)
         VMTW (jp, jz, VMTW_ziVIc) = VMTI (jp, jz, VMTI_VHc)
      enddo
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jp = 1, MH
            VMTI (jp, jz, VMTI_UHb)   =
     $        + (1.0d0-VMSK(jp,KUM)) * VMTI (jp, jz, VMTI_UHb)
            VMTI (jp, jz, VMTI_VHc)   =
     $        + (1.0d0-VMSK(jp,KVM)) * VMTI (jp, jz, VMTI_VHc)
            VMTW (jp, jz, VMTW_ziUIb) =
     $        + (1.0d0-VMSK(jp,KUM)) * VMTW (jp, jz, VMTW_ziUIb)
            VMTW (jp, jz, VMTW_ziVIc) =
     $        + (1.0d0-VMSK(jp,KVM)) * VMTW (jp, jz, VMTW_ziVIc)
         enddo
      enddo
      do jz0 = 0, NZ - 1
         jz = KZ0 + jz0
         do jp = 1, MH
            VMTW (jp, jz, VMTW_SXZb) = 0.0d0
     $        + (1.0d0-VMSK(jp,KUM)) * VMTW (jp,jz,VMTW_SXZb)
            VMTW (jp, jz, VMTW_SYZc) = 0.0d0
     $        + (1.0d0-VMSK(jp,KVM)) * VMTW (jp,jz,VMTW_SYZc)
            VMTW (jp, jz, VMTW_EXZb) = 0.0d0
     $        + (1.0d0-VMSK(jp,KUM)) * VMTW (jp,jz,VMTW_EXZb)
            VMTW (jp, jz, VMTW_EYZc) = 0.0d0
     $        + (1.0d0-VMSK(jp,KVM)) * VMTW (jp,jz,VMTW_EYZc)
         enddo
      enddo
      do jp = 1, MH
         VMID (jp, VMID_vBSXb) = 0.0d0
     $        + (1.0d0-VMSK(jp,KUM)) * VMID (jp, VMID_vBSXb)
         VMID (jp, VMID_vBSYc) = 0.0d0
     $        + (1.0d0-VMSK(jp,KVM)) * VMID (jp, VMID_vBSYc)
      enddo
      RETURN
      END
CCC_& MSNcit  ## Movement/SSA/non-linear create interpolation table
CCC_& MSNkdc  ## Movement/SSA/non-linear kiwi operators declaration
      subroutine MSNdec
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
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_Ldb,  KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_Ldc,  KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_Lbd,  KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_Lcd,  KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_Lba,  KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_Lca,  KWM_BOTH, IFP)
c
      RETURN
      END
CCC_& MSNcgr  ## Movement/SSA/non-linear clone group
      subroutine MSNcgr
     O    (iErr,
     O     ipCG,
     W     kDTA,
     I     LTBL, LCG, LH, LCK, ipKW, IE, IFP)
CCC_ + Declaration
      implicit none
      _INTENT(OUT,  integer) iErr
      _INTENT(IN,   integer) LCG, LH, LCK, LTBL
      _INTENT(OUT,  integer) ipCG (LCG,  *)
      _INTENT(OUT,  integer) kDTA (LTBL, *)
      _INTENT(IN,   integer) ipKW (*), IE (*), IFP
c
      integer    kk
      integer    ko, kot, kwm
CCC_ + Body
      iErr = 0
CCC_  - group in msbmos
      if (iErr.eq.0) then
         call MSBcgr
     O       (iErr,
     O        ipCG,
     W        kDTA,
     I        LTBL, LCG, LH, LCK, ipKW, IE, IFP)
      endif
CCC_  - normal
c     ko 0 for one-time cloning
      ko  = 1
      kwm = KWM_M
c
      kk = CGS_URd
      if (iErr.eq.0) then
         call AKCgro (iErr, ipCG (1, kk), LCG, ko)
         call AKCgad (iErr, ipCG (1, kk), KWO_Ldb, kwm, LCG)
         call AKCgad (iErr, ipCG (1, kk), KWO_Ldc, kwm, LCG)
         call AKCgso
     O       (iErr, ko,    ipCG (1, kk),  kDTA,
     I        LCG,  LTBL,  LH,   ipKW, IE,   IFP)
      endif
c
      kk = CGS_UXa
      if (iErr.eq.0) then
         call AKCgro (iErr, ipCG (1, kk), LCG, ko)
         call AKCgad (iErr, ipCG (1, kk), KWO_Lab, kwm, LCG)
         call AKCgad (iErr, ipCG (1, kk), KWO_Lac, kwm, LCG)
         call AKCgso
     O       (iErr, ko,    ipCG (1, kk),  kDTA,
     I        LCG,  LTBL,  LH,   ipKW, IE,   IFP)
      endif
c
      kk = CGS_VYa
      if (iErr.eq.0) then
         call AKCgro (iErr, ipCG (1, kk), LCG, ko)
         call AKCgad (iErr, ipCG (1, kk), KWO_Lab, kwm, LCG)
         call AKCgad (iErr, ipCG (1, kk), KWO_Lac, kwm, LCG)
         call AKCgso
     O       (iErr, ko,    ipCG (1, kk),  kDTA,
     I        LCG,  LTBL,  LH,   ipKW, IE,   IFP)
      endif
CCC_  - transpose
c     kot 0 for one-time cloning
      kot = 1
      kwm = KWM_T
CCC_  - report
      if (LCK.lt.ko) then
         iErr = -1
      endif
      if (LCK.lt.kot) then
         iErr = -1
      endif
      call DAtrcU (IFP, iErr, 'R', 'MSNCGR')
      RETURN
      END
CCC_& MSNbpi  ## Parameters initialization batch
      subroutine MSNbpi
     O    (iErr,
     O     OMS,  PMS,   IMS,
     I     CR,   ipP,   ipC, ipL)
CCC_ + Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,logical)   OMS (*)
      _INTENT(OUT,_REALSTD)  PMS (*)
      _INTENT(OUT,integer)   IMS (*)
      _INTENT(IN, character) CR*(*)
      _INTENT(IN, integer)   ipP, ipC, ipL
CCC_ + Body
      if (iErr.eq.0) then
         call MSBpms
     O       (iErr,
     O        PMS,
     I        CR,    ipP, ipC, ipL)
      endif
      if (iErr.eq.0) then
         call MSLpms
     O       (iErr,
     O        PMS,   IMS,
     I        CR,    ipP, ipC, ipL)
      endif
      if (iErr.eq.0) then
         call MSNpms
     O       (iErr,
     O        PMS,   IMS,
     I        CR,    ipP, ipC, ipL)
      endif
      RETURN
      END
CCC_& MSNpms  ## Parameters initialization
      subroutine MSNpms
     O    (iErr,
     O     PMS,   IMS,
     I     CR,    ipP, ipC, ipL)
CCC_ + Declaration
      implicit none
CCC_  - Arguments
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,_REALSTD)  PMS (*)
      _INTENT(OUT,integer)   IMS (*)
      _INTENT(IN, character) CR*(*)
      _INTENT(IN, integer)   ipP, ipC, ipL
CCC_  - Configuration
      _REALSTD  Etol,   Prlx
      _REALSTD  VXLIMU, VXLIML
      _REALSTD  VBLIML
      _REALSTD  VSHLIM, VGLLIM, HGLIML
      _REALSTD  FPrlx
      _REALSTD  VDNML,  PDNML,  DSXLIM
      integer   ItrMax, ItrMin, ItrGL
      integer   MaxTry
      integer   KswN, KswL, KswNG, KswGU, KswBT
      integer   KswNOV
      integer   IXRL, IXRH
CCC_  - Configuration
      character Tag*(*)
      parameter(Tag='SSAN')
      integer   KDOFLG
CCC_ + Body
      iErr = 0
      KDOFLG = DOPTS_LEVEL_ALLOW_NULL + DOPTS_LEVEL_MATCH_TAG
CCC_  - Parameters/options
      if (iErr.eq.0) then
         call DOgetI
     $       (iErr, ItrMax, 256,
     $        'ItrMax', 'Maximum iteration (SSA/nonlinear)',
     $         CR, Tag, ipP, ipC, ipL, KDOFLG)
      endif
      if (iErr.eq.0) then
         call DOgetI
     $       (iErr, ItrMin, 0,
     $        'ItrMin', 'Minimum iteration (SSA/nonlinear)',
     $         CR, Tag, ipP, ipC, ipL, KDOFLG)
      endif
      if (iErr.eq.0) then
         call DOgetI
     $       (iErr, ItrGL, 0,
     $        'ItrGL', 'Maximum iteration (grounding-line flux)',
     $        CR, Tag, ipP, ipC, ipL, KDOFLG)
      endif
      if (iErr.eq.0) then
         call DOgetI
     $       (iErr, MaxTry, 4,
     $        'MaxTry', 'Maximum trial (SSA/nonlinear)',
     $        CR, Tag, ipP, ipC, ipL, KDOFLG)
      endif
      if (iErr.eq.0) then
         call DOgetI
     $       (iErr, KswL, 0,
     $        'KswL', 'initial guess switch linear (SSA/nonlinear)',
     $        CR, Tag, ipP, ipC, ipL, KDOFLG)
      endif
      if (iErr.eq.0) then
         call DOgetI
     $       (iErr, KswN, 0,
     $        'KswN', 'initial guess switch nonlinear (SSA/nonlinear)',
     $        CR, Tag, ipP, ipC, ipL, KDOFLG)
      endif
      if (iErr.eq.0) then
         call DOgetI
     $       (iErr, KswNG, 1,
     $        'KswNG', 'initial guess switch gl (SSA/nonlinear)',
     $        CR, Tag, ipP, ipC, ipL, KDOFLG)
      endif
      if (iErr.eq.0) then
         call DOgetI
     $       (iErr, KswGU, 0,
     $        'KswGU', 'gl vel update timing (SSA/nonlinear)',
     $        CR, Tag, ipP, ipC, ipL, KDOFLG)
      endif
      if (iErr.eq.0) then
         call DOgetI
     $       (iErr, KswBT, SW_GLBT_DEF,
     $        'KswBT', 'buttressing effect switch (SSA/nonlinear)',
     $        CR, Tag, ipP, ipC, ipL, KDOFLG)
      endif
      if (iErr.eq.0) then
         call DOgetI
     $       (iErr, KswNOV, SW_NOCONV_FINAL,
     $        'KswNOV', 'solution when not converged (SSA/nonlinear)',
     $        CR, Tag, ipP, ipC, ipL, KDOFLG)
      endif
      if (iErr.eq.0) then
         call DOgetI
     $       (iErr, IXRL, -5,
     $        'IXRL', 'residual report lower (SSA/nonlinear)',
     $        CR, Tag, ipP, ipC, ipL, KDOFLG)
      endif
      if (iErr.eq.0) then
         call DOgetI
     $       (iErr, IXRH, +3,
     $        'IXRH', 'residual report higher (SSA/nonlinear)',
     $        CR, Tag, ipP, ipC, ipL, KDOFLG)
      endif
      if (iErr.eq.0) then
         call DOgetS
     $       (iErr, Etol, ' ', 1.0d-8, ' ',
     $        'ETOL', '(SSA/nonlinear)',
     $        CR, Tag, ipP, ipC, ipL, KDOFLG)
      endif
      if (iErr.eq.0) then
         call DOgetS
     $       (iErr, Prlx, ' ', 1.2d0, ' ',
     $        'Prlx', 'Relaxation (SSA/nonlinear)',
     $        CR, Tag, ipP, ipC, ipL, KDOFLG)
      endif
      if (iErr.eq.0) then
         call DOgetS
     $       (iErr, FPrlx, ' ', 0.95d0, ' ',
     $        'FPrlx', 'Relaxation coeff. (SSA/nonlinear)',
     $        CR, Tag, ipP, ipC, ipL, KDOFLG)
      endif
      if (iErr.eq.0) then
         call DOgetS
     $       (iErr, HGLIML, 'topography', 1.0d0, 'm',
     $        'HGLIML', 'GL H lower limit (SSA/nonlinear)',
     $        CR, Tag, ipP, ipC, ipL, KDOFLG)
      endif
      if (iErr.eq.0) then
         call DOgetS
     $       (iErr, DSXLIM, 'gradient', 0.0d0, '1',
     $        'DSXLIM', 'dsdx limit (SSA/nonlinear)',
     $        CR, Tag, ipP, ipC, ipL, KDOFLG)
      endif
      if (iErr.eq.0) then
         call DOgetS
     $       (iErr, VXLIML, 'dudx', 1.0d-4/10.d3, '/yr',
     $        'VXLIML', 'dudx lower limit (SSA/nonlinear)',
     $        CR, Tag, ipP, ipC, ipL, KDOFLG)
      endif
      if (iErr.eq.0) then
         call DOgetS
     $       (iErr, VXLIMU, 'dudx', 1.0d0/8.0d0, '/yr',
     $        'VXLIMU', 'dudx upper limit (SSA/nonlinear)',
     $        CR, Tag, ipP, ipC, ipL, KDOFLG)
      endif
      if (iErr.eq.0) then
         call DOgetS
     $       (iErr, VBLIML, 'velocity', 1.0d-2, 'm/yr',
     $        'VBLIML', 'SStA vb lower limit (SSA/nonlinear)',
     $        CR, Tag, ipP, ipC, ipL, KDOFLG)
      endif
      if (iErr.eq.0) then
         call DOgetS
     $       (iErr, VSHLIM, 'velocity', 1.0d20, 'm/yr',
     $        'VSHLIM', 'SSA velocity limit (SSA/nonlinear)',
     $        CR, Tag, ipP, ipC, ipL, KDOFLG)
      endif
      if (iErr.eq.0) then
         call DOgetS
     $       (iErr, VGLLIM, 'velocity', 1.0d20, 'm/yr',
     $        'VGLLIM', 'GL velocity limit (SSA/nonlinear)',
     $        CR, Tag, ipP, ipC, ipL, KDOFLG)
      endif
      if (iErr.eq.0) then
         call DOgetS
     $       (iErr, VDNML, ' ', 1.0d-2, ' ',
     $        'VDNML', 'V dominator lower limit (SSA/nonlinear)',
     $        CR, Tag, ipP, ipC, ipL, KDOFLG)
      endif
      if (iErr.eq.0) then
         call DOgetS
     $       (iErr, PDNML, ' ', 1.0d3, ' ',
     $        'PDNML', 'PQR dominator lower limit (SSA/nonlinear)',
     $        CR, Tag, ipP, ipC, ipL, KDOFLG)
      endif
CCC_  - Packing
      PMS (PMS_TOLNL)  = ETOL
      PMS (PMS_OVW)    = Prlx
      PMS (PMS_VXLIML) = VXLIML
      PMS (PMS_VXLIMU) = VXLIMU
      PMS (PMS_VBLIML) = VBLIML
      PMS (PMS_VSHLIM) = VSHLIM
      PMS (PMS_VGLLIM) = VGLLIM
      PMS (PMS_HGLIML) = HGLIML
      PMS (PMS_UDNML)  = VDNML
      PMS (PMS_PDNML)  = PDNML
      PMS (PMS_OVWFC)  = FPrlx
      PMS (PMS_DSXLIM) = DSXLIM
      IMS (IMS_ITRNL)  = ItrMax
      IMS (IMS_ITRGL)  = ItrGL
      IMS (IMS_MINNL)  = ItrMin
      IMS (IMS_TRYNL)  = MaxTry
      IMS (IMS_SWL)    = KswL
      IMS (IMS_SWNL)   = KswN
      IMS (IMS_SWNLG)  = KswNG
      IMS (IMS_SWNOV)  = KswNOV
      IMS (IMS_GLUPD)  = KswGU
      IMS (IMS_GLBT)   = KswBT
      IMS (IMS_XREPL)  = IXRL
      IMS (IMS_XREPH)  = IXRH
c$$$c
      call DAtrcU (ipL, iErr, 'R', 'MSNPMS')
      RETURN
      END
CCC_& obs_MSNpms  ## (obsolete) Parameters initialization (with local namelist)
      subroutine obs_MSNpms
     O    (iErr,
     O     PMS,   IMS,
     I     CR,    ipP, ipC, ipL)
CCC_ + Declaration
      implicit none
CCC_  - Arguments
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,_REALSTD)  PMS (*)
      _INTENT(OUT,integer)   IMS (*)
      _INTENT(IN, character) CR*(*)
      _INTENT(IN, integer)   ipP, ipC, ipL
CCC_  - Configuration
      character  CROOT * (8)
      _REALSTD  Etol,   Prlx
      _REALSTD  VXLIMU, VXLIML
      _REALSTD  VBLIML
      _REALSTD  VSHLIM, VGLLIM, HGLIML
      _REALSTD  FPrlx
      _REALSTD  VDNML,  PDNML,  DSXLIM
      integer   ItrMax, ItrMin, ItrGL
      integer   MaxTry
      integer   KswN, KswL, KswNG, KswGU, KswBT
      integer   KswNOV
      integer   IXRL, IXRH
      namelist /NISSAN/
     $     CROOT,
     $     ItrMax, ItrMin, Etol,  Prlx,
     $     VXLIML, VXLIMU, VBLIML,VSHLIM, VGLLIM, HGLIML,
     $     VDNML,  PDNML,
     $     DSXLIM,
     $     MaxTry, FPrlx,  KswNOV,
     $     ItrGL,  IXRL,   IXRH,
     $     KswN,   KswNG,  KswL,  KswGU,  KswBT
CCC_  - interior
      integer jc
CCC_ + Body
      iErr = 0
CCC_  - Configuration
      jc = 0
 200  continue
      call UUrwnd (iErr, ipP)
c
 100  continue
c
      CROOT  = ' '
      KswL   = 0
      KswN   = 0
      KswNG  = 1
      KswGU  = 0
      KswBT  = SW_GLBT_DEF
      KswNOV = SW_NOCONV_FINAL
      ItrMax = 256
      ItrMin = 0
      ItrGL  = 0
c$$$      ItrMax = 2
      Etol   = 1.0d-8
      Prlx   = 1.2d0
      FPrlx  = 0.95d0
      MaxTry = 4
c$$$      VBL    = 1.0d-8
c$$$      VXL    = 1.0d-2/10.d3
      VXLIML = 1.0d-4/10.d3
      VBLIML = 1.0d-2
c$$$      VXLIMU = 5.0d3/
      VXLIMU = 1.0d0/8.0d0
      VSHLIM = 1.0d20
      VGLLIM = 1.0d20
      HGLIML = 1.0d0
      VDNML  = 1.0d-2
      PDNML  = 1.0d3
      DSXLIM = 0.0d0
c$$$      VXL    = 0.0d0
c$$$      VBL    = 0.0d0
c
      IXRL = -5
      IXRH = +3
c
      READ  (ipP, NISSAN, IOSTAT = iErr)
c
      if (iErr.eq.0) then
         if (CROOT.eq.CR) goto 300
         if (jc.eq.1.and.CROOT.eq.' ') goto 300
         goto 100
      else
         jc = jc + 1
         if (jc.eq.2) then
            iErr = 0
            goto 300
         endif
         goto 200
      endif
c
 300  continue
      if (iErr.eq.0) then
         CROOT = CR
         write (ipC, NISSAN, IOSTAT = iErr)
      endif
CCC_  - Packing
      PMS (PMS_TOLNL)  = ETOL
      PMS (PMS_OVW)    = Prlx
      PMS (PMS_VXLIML) = VXLIML
      PMS (PMS_VXLIMU) = VXLIMU
      PMS (PMS_VBLIML) = VBLIML
      PMS (PMS_VSHLIM) = VSHLIM
      PMS (PMS_VGLLIM) = VGLLIM
      PMS (PMS_HGLIML) = HGLIML
      PMS (PMS_UDNML)  = VDNML
      PMS (PMS_PDNML)  = PDNML
      PMS (PMS_OVWFC)  = FPrlx
      PMS (PMS_DSXLIM) = DSXLIM
      IMS (IMS_ITRNL)  = ItrMax
      IMS (IMS_ITRGL)  = ItrGL
      IMS (IMS_MINNL)  = ItrMin
      IMS (IMS_TRYNL)  = MaxTry
      IMS (IMS_SWL)    = KswL
      IMS (IMS_SWNL)   = KswN
      IMS (IMS_SWNLG)  = KswNG
      IMS (IMS_SWNOV)  = KswNOV
      IMS (IMS_GLUPD)  = KswGU
      IMS (IMS_GLBT)   = KswBT
      IMS (IMS_XREPL)  = IXRL
      IMS (IMS_XREPH)  = IXRH
c
      call DAtrcU (ipL, iErr, 'R', 'MSNPMS')
      RETURN
      END
CCC_& MSNITA  ## Movement/SSA/non-linear announcement
      subroutine MSNITA (STRA, STRB, IOP)
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
#ifdef TEST_MSNITA
#include "ofnstd.h"
#include "odevid.h"
CCC_ @ MSLtst  ## test program
      program MSNtst
CCC_  - Test suites
CC::   SOURCES mslbcg.F mglcol.F msbmos.F:TEST_MSBMOS_SUB=1 mmxoms.F
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
         call MSNtestMain (iErr, ipA, iMA)
      endif
      if (iErr.eq.0) then
         call ACCrep (FPL(ipA), 0)
      endif
      call DevFin (iErr)
      STOP
      END
CCC_ & MSNtestMain  ## check main
      subroutine MSNtestMain (iErr, ipA, iMA)
CCC_  - Declaration
      implicit none
#include "odevva.h"
      _INTENT(OUT,integer)  iErr
      _INTENT(IN, integer)  ipA (*)
      _INTENT(IN, integer)  iMA (*)
CCC_   . Domain size limit
#ifndef   OPT_MSNITA_LHP_MAX
#  define OPT_MSNITA_LHP_MAX OPT_MOVEMENT_LHP_MAX
#endif
#ifndef   OPT_MSNITA_LHG_MAX
#  define OPT_MSNITA_LHG_MAX OPT_MOVEMENT_LHG_MAX
#endif
      integer    LHPref
      parameter (LHPref = OPT_MSNITA_LHP_MAX)
      integer    LHGref
      parameter (LHGref = OPT_MSNITA_LHG_MAX)
c
      integer    LCK
      parameter (LCK = 16)
CCC_   . Variable clusters
      integer    LVMW
      parameter (LVMW = LHPref * VMW_MAX)
      _REALSTD   VMW  (LHPref * VMW_MAX)
c
      _REALSTD   VMHB (LHPref * VMHB_MAX)
c
      _REALSTD   VMI  (LHPref * VMI_MAX)
      _REALSTD   VMC  (LHPref * VMC_MAX)
c
      _REALSTD   VMID (LHPref * VMID_MAX)
c
      _REALSTD   VMSC (LHPref * VMSC_MAX)
      _REALSTD   VMSV (LHPref * VMSV_MAX)
      _REALSTD   VMSX (LHPref * VMSX_MAX * BCGW_MAX)
      _REALSTD   VMSE (LHPref * VMSE_MAX)
c
      logical    OMM (OMM_MAX)
      integer    IMM (IMM_MAX)
      _REALSTD   PMM (PMM_MAX)
c
      integer    LKW
      parameter (LKW = 128)
      _REALSTD   WW (LHPref * LKW)
      _REALSTD   CW (LHPref * LCK)
c
      integer    LXK
CCC_   . Elements attributes
      integer    LIE
      parameter (LIE = (LHPref * 8))
      integer    IE   (LIE)
c
      integer    ipKW (IPKW_FULL_DECL)
CCC_   . global/private stencils
      integer    LTBL
      parameter (LTBL = LHPref)
      integer    kDTA (LTBL, 3)
CCC_   . clone
      integer    LCG
      parameter (LCG = KWCG_DECL(4))
      integer    ipCG (LCG, CGRP_MAX)
CCC_   . Variable clusters
      integer    idGM (16)
CCC_   . Work
      _REALSTD   WG (LHGref, 3)
CCC_   . Domain
      character  CR*8
      data       CR /'ID'/
      integer    icF
      integer    MH,  LH,  MG,  LG
      integer    NZ,  LZ,  KZ0
      character  CSW*(16)
CCC_   . Log
      integer ipL, ipP, ipC, ipV
      integer IFPa (16)
CCC_   . dummy
      _REALSTD WZV (1)
      integer  jedmy
      integer  nxg, nyg
CCC_  - Body
      iErr = 0
c
      ipL  = FPL(ipA)
      ipP  = FPP(ipA)
      ipC  = FPC(ipA)
      ipV  = FPV(ipA)
      call AFUifp (IFPa, ipP, ipC, ipL, ipV)
CCC_   . just for test
      NZ  = 0
      LZ  = 1
      KZ0 = 1
CCC_   . Arpeggio configuration
CCC_    * kiwi operators declaration
      if (iErr.eq.0) then
         call AKPini (ipKW)
         if (iErr.eq.0) call MSNdec (iErr, ipKW, ipL)
         if (iErr.eq.0) call MGLdec (iErr, ipKW, ipL)
         if (iErr.eq.0) call MSBdec (iErr, ipKW, ipL)
      endif
CCC_    * table creation
      call ACCrgR (jedmy, icF, 0, CR, ipL)
      NXG = 0
      NYG = 0
      if (iErr.eq.0) then
         call AMHcns
     O       (iErr,
     W        VMW,
     O        MH,    LH,     MG,     LG,   WW,
     O        ipKW,  IE,
     I        NXG,   NYG,
     L        LVMW,  LHPref, LHGref, LKW,  LIE,
     I        icF,   CR,     iMA,    ipP,  ipC,  ipL)
      endif
CCC_    * clone group
      if (iErr.eq.0) then
         call MSNcgr
     O       (iErr,
     O        ipCG,
     W        kDTA,
     I        LTBL, LCG, LH, LCK, ipKW, IE, ipL)
      endif
c$$$      if (iErr.eq.0) then
c$$$         call MSNcgg
c$$$     O       (iErr,
c$$$     O        ipCG,
c$$$     W        kDTA,
c$$$     I        LTBL, LCG, LH, LCK, ipKW, IE, ipL)
c$$$      endif
CCC_    * Parameters
      if (iErr.eq.0) then
         call MSNbpi
     O       (iErr,
     O        OMM, PMM,  IMM,
     I        CR,  ipP,  ipC, ipL)
      endif
CCC_    * Variable clusters
      CSW = 'C'
      if (iErr.eq.0) then
         call MSVgst
     O       (iErr, idGM,
     I        icF,  MH,  LH,
     I        CSW,  ' ', CR, IFPa, IE, iMA)
      endif
      if (iErr.eq.0) then
         call MIVgst
     O       (iErr, idGM,
     I        icF,  MH,  LH, NZ,   LZ,  KZ0,
     I        CSW,  ' ', CR, IFPa, IE,  iMA)
      endif
      if (iErr.eq.0) then
         call MMXgst
     O       (iErr, idGM,
     I        icF,  MH,  LH,
     I        CSW,  ' ', CR, IFPa, IE, iMA)
      endif
CCC_    * reports
      if (iErr.eq.0) then
         WZV (1) = 0.0d0
         call AMBrep
     O       (iErr,
     I        WW,  IE,  ipKW,
     I        MH,  LH,
     I        icF, CR,  'C',  MOVEMENT_DV_CLS,  IFPa,  iMA)
      endif
CCC_   . call test core
      if (iErr.eq.0) then
         LXK = VMSX_MAX
         call MSNtestCore
     O       (iErr,
     O        VMHB, VMI,  VMC,  VMID, VMSC, VMSV, VMSX, VMSE,
     W        VMW,  WG,   CW,
     I        IMM,  PMM,
     I        WW,
     I        MH,   LH,   LXK,  LHGref,
     I        CR,   ipCG, LCG,  icF,  ipKW, IE,   iMA,  ipA, idGM)
      endif
CCC_   . return
      RETURN
      END
CCC_ & MSNtestCore  ## check core
      subroutine MSNtestCore
     O    (iErr,
     O     VMHB, VMI,  VMC,  VMID, VMSC, VMSV, VMSX, VMSE,
     W     VMW,  WG,   CW,
     I     IMS,  PMS,
     I     WW,
     I     MH,   LH,   LXK,  LHGref,
     I     CR,   ipCG, LCG,  icF,  ipKW, IE,  iMA, ipA, idGM)
CCC_  - Declaration
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   MH, LH, LXK, LHGref
      _INTENT(OUT,_REALSTD)  VMHB (LH, *)
      _INTENT(OUT,_REALSTD)  VMI  (LH, *)
      _INTENT(OUT,_REALSTD)  VMC  (LH, *)
      _INTENT(OUT,_REALSTD)  VMID (LH, *)
      _INTENT(OUT,_REALSTD)  VMSC (LH, *)
      _INTENT(OUT,_REALSTD)  VMSV (LH, *)
      _INTENT(OUT,_REALSTD)  VMSX (LH, LXK, *)
      _INTENT(OUT,_REALSTD)  VMSE (LH, *)
      _INTENT(OUT,_REALSTD)  VMW  (LH, *)
      _INTENT(OUT,_REALSTD)  WG (*)
      _INTENT(OUT,_REALSTD)  CW (*)
      _INTENT(IN, integer)   IMS (*)
      _INTENT(IN, _REALSTD)  PMS (*)
      _INTENT(IN, _REALSTD)  WW (LH, *)
      _INTENT(IN, character) CR*(*)
      _INTENT(IN, integer)   LCG
      _INTENT(IN, integer)   ipCG (*)
      _INTENT(IN, integer)   ipKW (*)
      _INTENT(IN, integer)   IE   (*)
      _INTENT(IN, integer)   icF
      _INTENT(IN, integer)   iMA  (*)
      _INTENT(IN, integer)   ipA  (*)
      _INTENT(IN, integer)   idGM (*)
CCC_   . Log
      integer ipL, ipP, ipC, ipV
CCC_   . Variable
      _REALSTD  T
c
      integer   kvx
      integer   KXX
c
      _REALSTD  EfinN
      integer   ItrN
CCC_  - Body
      iErr = 0
      ipL  = FPL(ipA)
      ipP  = FPP(ipA)
      ipC  = FPC(ipA)
      ipV  = FPV(ipA)
CCC_   . Variables
CCC_   . Parameters
      if (iErr.eq.0) then
         call MSNtestInitAll
     O       (iErr,
     W        VMW,  CW,   WG,
     O        VMHB, VMI,  VMC,  VMID, VMSX, VMSV,
     I        WW,
     I        IMS,  PMS,
     I        MH,   LH,   LXK,  LHGref,
     I        CR,   IE,   ipKW, iMA, ipP, ipC, ipL)
      endif
CCC_   . Input fields
      T    = 0.0d0
      if (iErr.eq.0) then
         call AFBptc
     O       (iErr,
     I        VMI,
     I        1,  idGM (VGRP_VMI), 0, 0, T,  ' ',  ' ',  IE)
      endif
      if (iErr.eq.0) then
         call AFBptc
     O       (iErr,
     I        VMC,
     I        1,  idGM (VGRP_VMC), 0, 0, T,  ' ',  ' ',  IE)
      endif
      if (iErr.eq.0) then
         call AFBptc
     O       (iErr,
     I        VMHB,
     I        1,  idGM (VGRP_VMHB), 0, 0, T,  ' ',  ' ',  IE)
      endif
CCC_   . Grounding line properties
      call MGLprp
     O    (iErr,
     M     VMSV,
     W     VMW,    CW,    WG,
     I     IMS,    PMS,   VMI, VMC,  VMHB,
     I     .false.,
     I     WW,     MH,    LH,  ipKW, iMA, ipL)
CCC_   . Non-linear solver
      call MSNslv
     O    (iErr,
     M     VMSX,   VMSC,  VMSV,  VMW,
     W     CW,     WG,
     I     IMS,    PMS,   VMSE,  VMI, VMC,  VMID, VMHB,
     O     ItrN,   EfinN, KXX,
     I     ipCG,   LCG,   idGM,  T,
     I     WW,     MH,    LH,    LXK, ipKW, iMA,  ipL)
      if (iErr.eq.0) then
         call AFBptc
     O       (iErr,
     I        VMSX,
     I        KXX, idGM (VGRP_VMSX), 0, 0, T,  ' ',  'VMSX0',  IE)
      endif
CCC_   . Grounding line flux
      call MGLbtr
     O    (iErr,
     O     VMSV,
     W     VMW,   CW,
     I     IMS,   PMS,
     I     VMSX,  VMI,
     I     WW,    MH,    LH,  LXK, KXX, ipKW, iMA)
      call MGLflx
     O    (iErr,
     M     VMSV,
     W     VMW,    CW,    WG,
     I     IMS,    PMS,   VMI,
     I     WW,     MH,    LH,  ipKW, iMA, ipL)
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
     I     VMSX,   VMI,   PMS,
     I     WW,     MH,    LH,   LXK, KXX, ipKW, iMA, ipL)
CCC_   . Non-linear solver again
      call MSNslg
     O    (iErr,
     M     VMSX,   VMSC,  VMSV,  VMW,
     W     CW,     WG,
     I     IMS,    PMS,   VMSE,  VMI, VMC, VMID, VMHB,
     O     ItrN,   EfinN, KXX,
     I     ipCG,   LCG,   idGM,  T, 1,
     I     WW,     MH,    LH, LXK,  IE, ipKW, iMA, ipL)
CCC_   . check
      iErr = 0
      if (iErr.eq.0) then
         call AFBptc
     O       (iErr,
     I        VMSX,
     I        KXX, idGM (VGRP_VMSX), 0, 0, T,  ' ',  ' ',  IE)
      endif
CCC_   . solution diff
      if (iErr.eq.0) then
         call AFBptc
     O       (iErr,
     I        VMSX,
     I        BCGW_P, idGM (VGRP_VMSX), 0, 0, T,  ' ',  'dx',  IE)
      endif
CCC_   . magnitude
      if (iErr.eq.0) then
         call MSFvmg
     O       (VMW,
     W        CW,
     I        VMSX (1,1,KXX),   VMSC,      WW,
     I        VMSN_B3,  VMSN_B1,   VMSN_B2,
     I        VMSX_UbS, VMSX_VcW,  VMSC_Da_MI,
     I        KWO_Lba,  KWO_Lca,   MH,      LH, ipKW, iMA, KWM_M)
         call AFBptc
     O       (iErr,
     I        VMW,
     I        1, idGM (VGRP_VMSN), VMSN_B1,VMSN_B3, T,  ' ','vamp', IE)
      endif
CCC_   . matrix coefficients
      if (iErr.eq.0) then
         call AFBptc
     O       (iErr,
     I        VMSX,
     I        BCGW_BB, idGM (VGRP_VMSX), 0, 0, T,  ' ',  'bb',  IE)
      endif
      if (iErr.eq.0) then
         call AFBptc
     O       (iErr,
     I        VMSC,
     I        1,  idGM (VGRP_VMSC), 0, 0, T,  ' ',  ' ',  IE)
      endif
      if (iErr.eq.0) then
         call AFBptc
     O       (iErr,
     I        VMSV,
     I        1,  idGM (VGRP_VMSV),
     I        VMSV_GL0, VMSV_GL9, T, ' ', 'CGL', IE)
      endif
      if (iErr.eq.0) then
         call AFBptc
     O       (iErr,
     I        VMSV,
     I        1,  idGM (VGRP_VMSV), 0, 0, T,  ' ',  ' ',  IE)
      endif
CCC_  - return
      RETURN
      END
CCC_ & MSNtestInitAll
      subroutine MSNtestInitAll
     O    (iErr,
     W     VMW,  CW,   WG,
     O     VMHB, VMI,  VMC,  VMID, VMSX, VMSV,
     I     WW,
     I     IMS,  PMS,
     I     MH,   LH,   LXK,  LHGref,
     I     CR,   IE,   ipKW, iMA, ipP, ipC, ipL)
CCC_  - Declaration
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   MH, LH, LXK, LHGref
      _INTENT(OUT,_REALSTD)  VMHB (LH, *)
      _INTENT(OUT,_REALSTD)  VMI  (LH, *)
      _INTENT(OUT,_REALSTD)  VMC  (LH, *)
      _INTENT(OUT,_REALSTD)  VMID (LH, *)
      _INTENT(OUT,_REALSTD)  VMSV (LH, *)
      _INTENT(OUT,_REALSTD)  VMSX (LH, LXK, *)
c
      _INTENT(OUT,_REALSTD)  VMW (*)
      _INTENT(OUT,_REALSTD)  WG  (*)
      _INTENT(OUT,_REALSTD)  CW  (*)
c
      _INTENT(IN, integer)   IMS (*)
      _INTENT(IN, _REALSTD)  PMS (*)
      _INTENT(IN, _REALSTD)  WW (LH, *)

      _INTENT(IN, character) CR*(*)
      _INTENT(IN, integer)   ipKW (*)
      _INTENT(IN, integer)   IE   (*)
      _INTENT(IN, integer)   iMA  (*)
      _INTENT(IN, integer)   ipP, ipC, ipL
CCC_  - Body
      iErr = 0
      if (iErr.eq.0) then
         call MUTstp
     O       (iErr,
     W        VMW,  CW,  WG,
     O        VMHB, VMSX, VMI, VMC, VMSV,  VMID,
     I        PMS,
     I        WW,   IE,  ipKW,   iMA,
     L        MH,   LH,  LXK, LHGref, CR,   ipP,  ipC, ipL)
      endif
CCC_   . adjust grid category bcd
      if (iErr.eq.0) then
         call MSSgca
     O       (iErr,
     M        VMC,  VMW,  CW,
     I        WW,   ipKW, iMA, MH, LH)
      endif
CCC_  - return
      RETURN
      END
#endif /* TEST_MSNITA */
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
