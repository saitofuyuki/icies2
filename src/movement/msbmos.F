C movement/msbmos.F --- IcIES/Movement/SSA/b matrix operations
C Maintainer:  SAITO Fuyuki
C Created: Apr 17 2012
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2016/10/24 13:29:50 fuyuki msbmos.F>'
#define _FNAME 'movement/msbmos.F'
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
#include "ofdlct.h"   /* fortran dialect */
#include "oarpea.h"
#include "oarpkw.h"   /* operation id in arpeggio/kiwi */
#include "oarpgc.h"   /* geometry category */
#include "ologfm.h"   /* logging */
#ifndef   MSBMOS_VARIATION
#  define MSBMOS_VARIATION 4
#endif
#ifdef NO_MOVEMENT_H
#else
#  include "movement.h" /* movement definitions */
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
#define DEBUG_INM 0
#define DEBUG_CHK 0
c$$$#define DEBUG_INM 1
CCC_ + Matrix Option
#define SSA_ADJUST_PQ_GR 0 /* adjust PQ ground mask if needed (old default) */
#define SSA_ADJUST_UV_FL 1 /* adjust UV floating mask if needed */
#ifndef    OPT_SSA_ADJUST
#  define  OPT_SSA_ADJUST SSA_ADJUST_UV_FL
#endif
CCC_* Design variation 4
#if MSBMOS_VARIATION == 4
CCC_ & MSBdec  ## SSA/b/kiwi operators kiwi declaration
      subroutine MSBdec
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
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_GXab, KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_GYac, KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_GXba, KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_GYca, KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_GYbd, KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_GXcd, KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_GXdc, KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_GYdb, KWM_BOTH, IFP)
c
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_FCab, KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_FCac, KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_FCbd, KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_FCcd, KWM_BOTH, IFP)
c
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_Xa,   KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_Ya,   KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_Xb,   KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_Yb,   KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_Xc,   KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_Yc,   KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_Xd,   KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_Yd,   KWM_BOTH, IFP)
c reserved
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_DXba, KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_DYca, KWM_BOTH, IFP)
c
      RETURN
      END
CCC_ & MSBcgr  ## SSA/b/kiwi clone group declaration
      subroutine MSBcgr
     O    (iErr,
     O     ipCG,
     W     kDTA,
     I     LTBL, LCG, LH, LCK, ipKW, IE, IFP)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer) iErr
      _INTENT(IN,   integer) LCG, LH, LCK, LTBL
      _INTENT(OUT,  integer) ipCG (LCG, CGS_MAX)
      _INTENT(OUT,  integer) kDTA (LTBL, *)
      _INTENT(IN,   integer) ipKW (*), IE (*), IFP
c
      integer    kk
      integer    ko, kot, kwm
CCC_  - Body
      iErr = 0
CCC_   . normal
c     ko 0 for one-time cloning
      ko   = 1
      kwm = KWM_M
c
      kk = CGS_PaW
      if (iErr.eq.0) then
         call AKCgro (iErr, ipCG (1, kk), LCG, ko)
         call AKCgad (iErr, ipCG (1, kk), KWO_GXab, kwm, LCG)
         call AKCgad (iErr, ipCG (1, kk), KWO_Lab,  kwm, LCG)
         call AKCgso
     O       (iErr, ko,    ipCG (1, kk),  kDTA,
     I        LCG,  LTBL,  LH,   ipKW, IE,   IFP)
      endif
c
      kk = CGS_QaS
      if (iErr.eq.0) then
         call AKCgro (iErr, ipCG (1, kk), LCG, ko)
         call AKCgad (iErr, ipCG (1, kk), KWO_GYac, kwm, LCG)
         call AKCgad (iErr, ipCG (1, kk), KWO_Lac,  kwm, LCG)
         call AKCgso
     O       (iErr, ko,    ipCG (1, kk),  kDTA,
     I        LCG,  LTBL,  LH,   ipKW, IE,   IFP)
      endif
c
      kk = CGS_RdA
      if (iErr.eq.0) then
         call AKCgro (iErr, ipCG (1, kk), LCG, ko)
         call AKCgad (iErr, ipCG (1, kk), KWO_GYdb, kwm, LCG)
         call AKCgad (iErr, ipCG (1, kk), KWO_GXdc, kwm, LCG)
         call AKCgad (iErr, ipCG (1, kk), KWO_Ldb,  kwm, LCG)
         call AKCgad (iErr, ipCG (1, kk), KWO_Ldc,  kwm, LCG)
         call AKCgso
     O       (iErr, ko,    ipCG (1, kk),  kDTA,
     I        LCG,  LTBL,  LH,   ipKW, IE,   IFP)
      endif
c
      kk = CGS_UbS
      if (iErr.eq.0) then
         call AKCgro (iErr, ipCG (1, kk), LCG, ko)
         call AKCgad (iErr, ipCG (1, kk), KWO_GXba, kwm, LCG)
         call AKCgad (iErr, ipCG (1, kk), KWO_GYbd, kwm, LCG)
         call AKCgso
     O       (iErr, ko,    ipCG (1, kk),  kDTA,
     I        LCG,  LTBL,  LH,   ipKW, IE,   IFP)
      endif
c
      kk = CGS_VcW
      if (iErr.eq.0) then
         call AKCgro (iErr, ipCG (1, kk), LCG, ko)
         call AKCgad (iErr, ipCG (1, kk), KWO_GYca, kwm, LCG)
         call AKCgad (iErr, ipCG (1, kk), KWO_GXcd, kwm, LCG)
         call AKCgso
     O       (iErr, ko,    ipCG (1, kk),  kDTA,
     I        LCG,  LTBL,  LH,   ipKW, IE,   IFP)
      endif
c
      kk = CGS_UbN
      if (iErr.eq.0) then
         call AKCgro (iErr, ipCG (1, kk), LCG, ko)
         call AKCgad (iErr, ipCG (1, kk), KWO_GXba, kwm, LCG)
         call AKCgad (iErr, ipCG (1, kk), KWO_GYbd, kwm, LCG)
         call AKCgso
     O       (iErr, ko,    ipCG (1, kk),  kDTA,
     I        LCG,  LTBL,  LH,   ipKW, IE,   IFP)
      endif
c
      kk = CGS_VcE
      if (iErr.eq.0) then
         call AKCgro (iErr, ipCG (1, kk), LCG, ko)
         call AKCgad (iErr, ipCG (1, kk), KWO_GYca, kwm, LCG)
         call AKCgad (iErr, ipCG (1, kk), KWO_GXcd, kwm, LCG)
         call AKCgso
     O       (iErr, ko,    ipCG (1, kk),  kDTA,
     I        LCG,  LTBL,  LH,   ipKW, IE,   IFP)
      endif
c
CCC_   . transpose
c     kot 0 for one-time cloning
      kot = 1
      kwm = KWM_T
c
#if MSBMOS_VARIATION == 4
      kk = CGS_MuIPa
      if (iErr.eq.0) then
         call AKCgro (iErr, ipCG (1, kk), LCG, kot)
         call AKCgad (iErr, ipCG (1, kk), KWO_GXba, kwm, LCG)
         call AKCgad (iErr, ipCG (1, kk), KWO_GYca, kwm, LCG)
         call AKCgso
     O       (iErr, kot,   ipCG (1, kk), kDTA,
     I        LCG,  LTBL,  LH,   ipKW, IE,   IFP)
      endif
      kk = CGS_MuIQa
      if (iErr.eq.0) then
         call AKCgro (iErr, ipCG (1, kk), LCG, kot)
         call AKCgad (iErr, ipCG (1, kk), KWO_GYca, kwm, LCG)
         call AKCgad (iErr, ipCG (1, kk), KWO_GXba, kwm, LCG)
         call AKCgso
     O       (iErr, kot,   ipCG (1, kk), kDTA,
     I        LCG,  LTBL,  LH,   ipKW, IE,   IFP)
      endif
#else /* MSBMOS_VARIATION != 4 */
#  error "Not implemented"
#endif
CCC_   . report
      if (LCK.lt.ko) then
         iErr = -1
      endif
      if (LCK.lt.kot) then
         iErr = -1
      endif
      call DAtrcU (IFP, iErr, 'R', 'MSBCGR')
      RETURN
      END
CCC_ & MSBxml  ## SSA/b/matrix multiplication suite (13 unknowns)
      subroutine MSBxml
     M    (X,
     I     KXL,  KXR,
     W     C,    W,
     I     QS,   QC,   QV,   WW,
     I     iMA,  ipKW, ipCG, MH, LH, LXK, LCG)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH, KXR, KXL
      _INTENT(IN,   integer)  LXK, LCG
      _INTENT(INOUT,_REALSTD) X    (LH, LXK, *)
      _INTENT(OUT,  _REALSTD) C    (LH,  *)
      _INTENT(OUT,  _REALSTD) W    (LH,  *)
      _INTENT(IN,   _REALSTD) QS   (*)
      _INTENT(IN,   _REALSTD) QC   (LH,  *)
      _INTENT(IN,   _REALSTD) QV   (LH,  *)
      _INTENT(IN,   _REALSTD) WW   (*)
      _INTENT(IN,   integer)  iMA  (*),  ipKW (*)
      _INTENT(IN,   integer)  ipCG (LCG, *)
      integer KT
      integer KSW
      integer kbw
CCC_  - Body
      KSW = KWM_M
      KT  = 1
CCC_   . debug macros
c$$$#define DEBUG_XML_UB
c$$$#define DEBUG_XML_UN
c$$$#define DEBUG_XML_US
CCC_   . Clone group preparation
CCC_    * Clone P[W]:a  1:dP/dx:b  2:Lab     3:G(L)ac
      call AKCgux
     O    (C,
     I     X (1, VMSX_PaW, KXR),
     I     MH, LH, KT, iMA, ipCG (1, CGS_PaW))
CCC_    * Clone Q[S]:a  1:dQ/dy:c  2:Lac     3:G(L)ab
      call AKCgux
     O    (C,
     I     X (1, VMSX_QaS, KXR),
     I     MH, LH, KT, iMA, ipCG (1, CGS_QaS))
CCC_    * Clone R:d     1:dR/dy:b  2:dR/dx:c 3:Ldb  4:Ldc
      call AKCgux
     O    (C,
     I     X (1, VMSX_RdA, KXR),
     I     MH, LH, KT, iMA, ipCG (1, CGS_RdA))
CCC_    * Clone u[S]:b  1:du/dx:a  2:du/dy:d
      call AKCgux
     O    (C,
     I     X (1, VMSX_UbS, KXR),
     I     MH, LH, KT, iMA, ipCG (1, CGS_UbS))
CCC_    * Clone v[W]:c  1:dv/dy:a  2:dv/dx:d
      call AKCgux
     O    (C,
     I     X (1, VMSX_VcW, KXR),
     I     MH, LH, KT, iMA, ipCG (1, CGS_VcW))
CCC_    * Clone u[N]:b  1:du/dx:a  2:du/dy:d
      call AKCgux
     O    (C,
     I     X (1, VMSX_UbN, KXR),
     I     MH, LH, KT, iMA, ipCG (1, CGS_UbN))
CCC_    * Clone v[E]:c  1:dv/dy:a  2:dv/dx:d
      call AKCgux
     O    (C,
     I     X (1, VMSX_VcE, KXR),
     I     MH, LH, KT, iMA, ipCG (1, CGS_VcE))
CCC_  - u/v automatic generation (rev 4)
CCC_   . u:b common
CCC_    * [interior] MPR = dP/dx[EW]:b + dR/dy:b
CCC_     + B1: dP/dx[E]:b
      call AKBwaz
     O    (W (1, VMSN_B1),  C,
     I     X (1, VMSX_PaE, KXR), WW,
     I     MH,   LH,  ipKW, iMA, KWO_GXab, KSW)
CCC_     + B1: B1 * Switch dx[E]:b
      call UV1uma (W, QC, MH, LH, VMSN_B1, VMSC_DxSwEb)
CCC_     + B2: dP/dx[W]:b
      call AKGwaz
     O    (W (1, VMSN_B2),
     I     C,    X (1, VMSX_PaW, KXR), WW,
     I     MH,   LH,  ipKW, 1, ipCG (1, CGS_PaW))
CCC_     + B2: B2 * Switch dx[W]:b
      call UV1uma (W, QC, MH, LH, VMSN_B2, VMSC_DxSwWb)
CCC_     + MPR: B1 + B2
      call UV0naa (W, MH, LH, VMSN_MiPXRY, VMSN_B1, VMSN_B2)
CCC_     + B1: dR/dy:b
      call AKGwaz
     O    (W (1, VMSN_B1),
     I     C,    X (1, VMSX_RdA, KXR), WW,
     I     MH,   LH,  ipKW, 1, ipCG (1, CGS_RdA))
CCC_     + MPR: MPR + B1
      call UV0uaa (W, MH, LH, VMSN_MiPXRY, VMSN_B1)
CCC_     + MPR: MPR * I
      call UV1uma (W, QC, MH, LH, VMSN_MiPXRY, VMSC_Ub_MI)
CCC_    * [ghost/x] NyRd  = Ny:d * R:d
CCC_     + NyRd: Ny:d * R:d
      call UV3nma
     $     (W, X (1, 1, KXR),QC, MH, LH, VMSN_NyRd,VMSX_RdA,VMSC_NdY)
CCC_    * [ghost/x] SwPbH = LH P[EW]:a
CCC_     + SwPbH
      call AKBubz
     O    (W (1, VMSN_SwPbH),  C,
     I     X (1, 1, KXR), QC,
     I     MH,   LH,  VMSX_PaE, VMSX_PaW, VMSC_PbHw, VMSC_PbHe,
     I     ipKW, iMA, KWO_Lab, KSW)
CCC_    * [ghost/y] NxRd  = Nx:d * R:d * Nx Ny
      call UV3nma
     $     (W, X (1, 1, KXR),QC, MH, LH, VMSN_NxRd,VMSX_RdA,VMSC_NdXYX)
CCC_    * [ghost/y] SwQbH = LH Q[EW]:a
CCC_     + SwQbH
      call AKBubz
     O    (W (1, VMSN_SwQbH),  C,
     I     X (1, 1, KXR), QC,
     I     MH,   LH,  VMSX_QaE, VMSX_QaW, VMSC_QbHw, VMSC_QbHe,
     I     ipKW, iMA, KWO_Lab, KSW)
#ifdef DEBUG_XML_UB
      return
#endif
CCC_   = u[N]:b
CCC_    * [ghost/x]  to B3  use B1
      kbw = VMSN_B3
CCC_     + B1: PbN      by P[N]:a
      call AKBuaz
     O    (W (1, VMSN_B1),  C,
     I     X (1, VMSX_PaN, KXR), QC,
     I     MH,    LH,  VMSC_PbNw, VMSC_PbNe,
     I     ipKW,  iMA, KWO_Lab, KSW)
CCC_     + B.: P:d      by PbN, PbH(clone)
      call AKBwbx
     O    (W,  C,
     I     WW,
     I     MH, LH, kbw, VMSN_B1, VMSN_SwPbH,
     I     ipKW,   iMA, KWO_Lbd, KSW)
CCC_     + B.: B. * Nx:d
      call UV1uma (W, QC, MH, LH, kbw, VMSC_NdX)
CCC_     + B.: B. + Ny:d R:d
      call UV0uaa (W, MH, LH, kbw, VMSN_NyRd)
CCC_     + B.: SHIFT(NOP)
CCC_     + B.: B. * Corner[N]:b
      call UV1uma (W, QC, MH, LH, kbw, VMSC_CxSwNb)
CCC_    * [ghost/y]  to B2  use B1
      kbw = VMSN_B2
CCC_     + B1: QbN      by Q[N]:a
      call AKBuaz
     O    (W (1, VMSN_B1),  C,
     I     X (1, VMSX_QaN, KXR), QC,
     I     MH,    LH,  VMSC_QbNw, VMSC_QbNe,
     I     ipKW,  iMA, KWO_Lab, KSW)
CCC_     + B.: Q:d      by QbN, QbH(clone)
      call AKBwbx
     O    (W,  C,
     I     WW,
     I     MH, LH, kbw, VMSN_B1, VMSN_SwQbH,
     I     ipKW,   iMA, KWO_Lbd, KSW)
CCC_     + B.: B. * Nyxy:d
      call UV1uma (W, QC, MH, LH, kbw, VMSC_NdYXY)
CCC_     + B.: B. + Nxxy:d R:d
      call UV0uaa (W, MH, LH, kbw, VMSN_NxRd)
CCC_     + B.: SHIFT(NOP)
CCC_     + B.: B. * Corner[N]:b
      call UV1uma (W, QC, MH, LH, kbw, VMSC_CySwNb)
CCC_    * [ghost/xy] to B1  use B2 B3
CCC_     + B1: B2 + B3
      call UV0naa (W, MH, LH, VMSN_B1, VMSN_B2, VMSN_B3)
CCC_     + B1: B1 * G[N]:b
      call UV1uma (W, QC, MH, LH, VMSN_B1, VMSC_UbN_MG)
CCC_     + B1: B1 * Scale U:G
      call UV0uwa (W, MH, LH, VMSN_B1, QS (PMS_InvUG))
CCC_    * [fixed]    to B2
CCC_     + B2: u[N]:b * F[N]:b
      call UV3nma
     $    (W,       QC,          X (1, 1, KXR), MH, LH,
     $     VMSN_B2, VMSC_UbN_MF, VMSX_UbN)
CCC_     + B2: B2 * Scale U:F
      call UV0uwa (W, MH, LH, VMSN_B2, QS (PMS_InvUF))
CCC_    * [FG] to B1        use B2
      call UV0uaa (W, MH, LH, VMSN_B1, VMSN_B2)
CCC_    * [Drag] to B3
      call UV3nma
     $    (W,       QV,       X (1, 1, KXR), MH, LH,
     $     VMSN_B3, VMSV_BDb, VMSX_UbN)
CCC_    * B3: - Drag + MPR
      call UV1uma (W, QC, MH, LH, VMSN_B3, VMSC_Ub_MI)
      call UV0una (W, MH, LH, VMSN_B3, VMSN_MiPXRY)
CCC_    * [done u[N]:b] FGI = B1 + MPR
      call UV2nfa
     $     (X (1, 1, KXL), W, MH, LH, VMSX_UbN, VMSN_B1, VMSN_B3,
     $      QS (PMS_InvUI))
c$$$      call UV2nfa
c$$$     $     (X (1, 1, KXL), W, MH, LH, VMSX_UbN, VMSN_B1, VMSN_MiPXRY,
c$$$     $      QS (PMS_InvUI))
c$$$     call UV2naa
c$$$    $     (X (1, 1, KXL), W, MH, LH, VMSX_UbN, VMSN_B1, VMSN_MiPXRY)
#ifdef    DEBUG_XML_UN
      return
#endif /* DEBUG_XML_UN */
CCC_   = u[S]:b
CCC_    * [ghost/x]  to B3  use B1
      kbw = VMSN_B3
CCC_     + B.: PbS      by P[S]:a
      call AKBuaz
     O    (W (1, kbw),  C,
     I     X (1, VMSX_PaS, KXR), QC,
     I     MH,    LH,  VMSC_PbSw, VMSC_PbSe,
     I     ipKW,  iMA, KWO_Lab, KSW)
CCC_     + B1: P:d      by PbH, PbS(clone)
      call AKBwbx
     O    (W,  C,
     I     WW,
     I     MH, LH, VMSN_B1, VMSN_SwPbH, kbw,
     I     ipKW,   iMA, KWO_Lbd, KSW)
CCC_     + B1: B1 * Nx:d
      call UV1uma (W, QC, MH, LH, VMSN_B1, VMSC_NdX)
CCC_     + B1: B1 + Ny:d R:d
      call UV0uaa (W, MH, LH, VMSN_B1, VMSN_NyRd)
CCC_     + B.: SHIFT(B1)
      call AKBmex
     M    (W,    C,
     I     MH,   LH,  kbw, VMSN_B1,
     I     ipKW, iMA, KWO_Lca, KSW)
CCC_     + B.: B. * Corner[S]:b
      call UV1uma (W, QC, MH, LH, kbw, VMSC_CxSwSb)
CCC_    * [ghost/y]  to B2  use B1
      kbw = VMSN_B2
CCC_     + B.: QbS      by Q[S]:a
      call AKBuaz
     O    (W (1, kbw),  C,
     I     X (1, VMSX_QaS, KXR), QC,
     I     MH,    LH,  VMSC_QbSw, VMSC_QbSe,
     I     ipKW,  iMA, KWO_Lab, KSW)
CCC_     + B1: Q:d      by QbH, QbS(clone)
      call AKBwbx
     O    (W,  C,
     I     WW,
     I     MH, LH, VMSN_B1, VMSN_SwQbH, kbw,
     I     ipKW,   iMA, KWO_Lbd, KSW)
CCC_     + B1: B1 * Nyxy:d
      call UV1uma (W, QC, MH, LH, VMSN_B1, VMSC_NdYXY)
CCC_     + B1: B1 + Nxxy:d R:d
      call UV0uaa (W, MH, LH, VMSN_B1, VMSN_NxRd)
CCC_     + B.: SHIFT(B1)
      call AKBmex
     M    (W,    C,
     I     MH,   LH,  kbw, VMSN_B1,
     I     ipKW, iMA, KWO_Lca, KSW)
CCC_     + B.: B. * Corner[S]:b
      call UV1uma (W, QC, MH, LH, kbw, VMSC_CySwSb)
CCC_    * [ghost/xy] to B1  use B2 B3
CCC_     + B1: B2 + B3
      call UV0naa (W, MH, LH, VMSN_B1, VMSN_B2, VMSN_B3)
CCC_     + B1: B1 * G[S]:b
      call UV1uma (W, QC, MH, LH, VMSN_B1, VMSC_UbS_MG)
CCC_     + B1: B1 * Scale U:G
      call UV0uwa (W, MH, LH, VMSN_B1, QS (PMS_InvUG))
CCC_    * [fixed]    to B2
CCC_     + B2: u[S]:b * F[S]:b
      call UV3nma
     $    (W,       QC,          X (1, 1, KXR), MH, LH,
     $     VMSN_B2, VMSC_UbS_MF, VMSX_UbS)
CCC_     + B2: B2 * Scale U:F
      call UV0uwa (W, MH, LH, VMSN_B2, QS (PMS_InvUF))
CCC_    * [FG] to B1        use B2
      call UV0uaa (W, MH, LH, VMSN_B1, VMSN_B2)
CCC_    * [Drag] to B3
      call UV3nma
     $    (W,       QV,       X (1, 1, KXR), MH, LH,
     $     VMSN_B3, VMSV_BDb, VMSX_UbS)
CCC_    * B3: - Drag + MPR
      call UV1uma (W, QC, MH, LH, VMSN_B3, VMSC_Ub_MI)
      call UV0una (W, MH, LH, VMSN_B3, VMSN_MiPXRY)
CCC_    * [done u[S]:b] FGI = B1 + MPR
      call UV2nfa
     $     (X (1, 1, KXL), W, MH, LH, VMSX_UbS, VMSN_B1, VMSN_B3,
     $      QS (PMS_InvUI))
c$$$      call UV2nfa
c$$$     $     (X (1, 1, KXL), W, MH, LH, VMSX_UbS, VMSN_B1, VMSN_MiPXRY,
c$$$     $      QS (PMS_InvUI))
c$$$     call UV2naa
c$$$    $     (X (1, 1, KXL), W, MH, LH, VMSX_UbS, VMSN_B1, VMSN_MiPXRY)
#ifdef    DEBUG_XML_US
      return
#endif /* DEBUG_XML_US */
CCC_   . v:c common
CCC_    * [interior] MQR = dQ/dy[NS]:c + dR/dx:c
CCC_     + B1: dQ/dy[N]:c
      call AKBwaz
     O    (W (1, VMSN_B1),  C,
     I     X (1, VMSX_QaN, KXR), WW,
     I     MH,   LH,  ipKW, iMA, KWO_GYac, KSW)
CCC_     + B1: B1 * Switch dy[N]:c
      call UV1uma (W, QC, MH, LH, VMSN_B1, VMSC_DySwNc)
CCC_     + B2: dQ/dy[S]:c
      call AKGwaz
     O    (W (1, VMSN_B2),
     I     C,    X (1, VMSX_QaS, KXR), WW,
     I     MH,   LH,  ipKW, 1, ipCG (1, CGS_QaS))
CCC_     + B2: B2 * Switch dy[S]:c
      call UV1uma (W, QC, MH, LH, VMSN_B2, VMSC_DySwSc)
CCC_     + MQR: B1 + B2
      call UV0naa (W, MH, LH, VMSN_MiQYRX, VMSN_B1, VMSN_B2)
CCC_     + B1: dR/dx:c
      call AKGwaz
     O    (W (1, VMSN_B1),
     I     C,    X (1, VMSX_RdA, KXR), WW,
     I     MH,   LH,  ipKW, 2, ipCG (1, CGS_RdA))
CCC_     + MQR: MQR + B1
      call UV0uaa (W, MH, LH, VMSN_MiQYRX, VMSN_B1)
CCC_     + MQR: MQR * I
      call UV1uma (W, QC, MH, LH, VMSN_MiQYRX, VMSC_Vc_MI)
CCC_    * [ghost/y] NxRd  = Nx:d * R:d
CCC_     + NxRd: Nx:d * R:d
      call UV3nma
     $     (W, X (1, 1, KXR),QC, MH, LH, VMSN_NxRd,VMSX_RdA,VMSC_NdX)
CCC_    * [ghost/y] SwQcV = LV Q[NS]:a
CCC_     + SwQcV
      call AKBubz
     O    (W (1, VMSN_SwQcV),  C,
     I     X (1, 1, KXR), QC,
     I     MH,   LH,  VMSX_QaN, VMSX_QaS, VMSC_QcVs, VMSC_QcVn,
     I     ipKW, iMA, KWO_Lac, KSW)
CCC_    * [ghost/x] NyRd  = Ny:d * R:d * Nx Ny
      call UV3nma
     $     (W, X (1, 1, KXR),QC, MH, LH, VMSN_NyRd,VMSX_RdA,VMSC_NdYYX)
CCC_    * [ghost/x] SwPcV = LV P[NS]:a
CCC_     + SwPcV
      call AKBubz
     O    (W (1, VMSN_SwPcV),  C,
     I     X (1, 1, KXR), QC,
     I     MH,   LH,  VMSX_PaN, VMSX_PaS, VMSC_PcVs, VMSC_PcVn,
     I     ipKW, iMA, KWO_Lac, KSW)
#ifdef DEBUG_XML_VC
      return
#endif
CCC_   = v[E]:c
CCC_    * [ghost/y]  to B3  use B1
      kbw = VMSN_B3
CCC_     + B1: QcE      by Q[E]:a
      call AKBuaz
     O    (W (1, VMSN_B1),  C,
     I     X (1, VMSX_QaE, KXR), QC,
     I     MH,    LH,  VMSC_QcEs, VMSC_QcEn,
     I     ipKW,  iMA, KWO_Lac, KSW)
CCC_     + B.: Q:d      by QcE, QcV(clone)
      call AKBwbx
     O    (W,  C,
     I     WW,
     I     MH, LH, kbw, VMSN_B1, VMSN_SwQcV,
     I     ipKW,   iMA, KWO_Lcd, KSW)
CCC_     + B.: B. * Ny:d
      call UV1uma (W, QC, MH, LH, kbw, VMSC_NdY)
CCC_     + B.: B. + Nx:d R:d
      call UV0uaa (W, MH, LH, kbw, VMSN_NxRd)
CCC_     + B.: SHIFT(NOP)
CCC_     + B.: B. * Corner[E]:c
      call UV1uma (W, QC, MH, LH, kbw, VMSC_CySwEc)
CCC_    * [ghost/x]  to B2  use B1
      kbw = VMSN_B2
CCC_     + B1: PcE      by P[E]:a
      call AKBuaz
     O    (W (1, VMSN_B1),  C,
     I     X (1, VMSX_PaE, KXR), QC,
     I     MH,    LH,  VMSC_PcEs, VMSC_PcEn,
     I     ipKW,  iMA, KWO_Lac, KSW)
CCC_     + B.: P:d      by PcE, PcV(clone)
      call AKBwbx
     O    (W,  C,
     I     WW,
     I     MH, LH, kbw, VMSN_B1, VMSN_SwPcV,
     I     ipKW,   iMA, KWO_Lcd, KSW)
CCC_     + B.: B. * Nxxy:d
      call UV1uma (W, QC, MH, LH, kbw, VMSC_NdXXY)
CCC_     + B.: B. + Nyxy:d R:d
      call UV0uaa (W, MH, LH, kbw, VMSN_NyRd)
CCC_     + B.: SHIFT(NOP)
CCC_     + B.: B. * Corner[E]:c
      call UV1uma (W, QC, MH, LH, kbw, VMSC_CxSwEc)
CCC_    * [ghost/xy] to B1  use B2 B3
CCC_     + B1: B2 + B3
      call UV0naa (W, MH, LH, VMSN_B1, VMSN_B2, VMSN_B3)
CCC_     + B1: B1 * G[E]:c
      call UV1uma (W, QC, MH, LH, VMSN_B1, VMSC_VcE_MG)
CCC_     + B1: B1 * Scale V:G
      call UV0uwa (W, MH, LH, VMSN_B1, QS (PMS_InvVG))
CCC_    * [fixed]    to B2
CCC_     + B2: u[E]:c * F[E]:c
      call UV3nma
     $    (W,       QC,          X (1, 1, KXR), MH, LH,
     $     VMSN_B2, VMSC_VcE_MF, VMSX_VcE)
CCC_     + B2: B2 * Scale V:F
      call UV0uwa (W, MH, LH, VMSN_B2, QS (PMS_InvVF))
CCC_    * [FG] to B1        use B2
      call UV0uaa (W, MH, LH, VMSN_B1, VMSN_B2)
CCC_    * [Drag] to B3
      call UV3nma
     $    (W,       QV,       X (1, 1, KXR), MH, LH,
     $     VMSN_B3, VMSV_BDc, VMSX_VcE)
CCC_    * B3: - Drag + MQR
      call UV1uma (W, QC, MH, LH, VMSN_B3, VMSC_Vc_MI)
      call UV0una (W, MH, LH, VMSN_B3, VMSN_MiQYRX)
CCC_    * [done v[E]:c] FGI = B1 + MPR
      call UV2nfa
     $     (X (1, 1, KXL), W, MH, LH, VMSX_VcE, VMSN_B1, VMSN_B3,
     $      QS (PMS_InvVI))
c$$$      call UV2nfa
c$$$     $     (X (1, 1, KXL), W, MH, LH, VMSX_VcE, VMSN_B1, VMSN_MiQYRX,
c$$$     $      QS (PMS_InvVI))
c$$$     call UV2naa
c$$$    $     (X (1, 1, KXL), W, MH, LH, VMSX_VcE, VMSN_B1, VMSN_MiQYRX)
#ifdef    DEBUG_XML_VE
      return
#endif /* DEBUG_XML_VE */
CCC_   = v[W]:c
CCC_    * [ghost/y]  to B3  use B1
      kbw = VMSN_B3
CCC_     + B.: QcW      by Q[W]:a
      call AKBuaz
     O    (W (1, kbw),  C,
     I     X (1, VMSX_QaW, KXR), QC,
     I     MH,    LH,  VMSC_QcWs, VMSC_QcWn,
     I     ipKW,  iMA, KWO_Lac, KSW)
CCC_     + B1: Q:d      by QcV, QcW(clone)
      call AKBwbx
     O    (W,  C,
     I     WW,
     I     MH, LH, VMSN_B1, VMSN_SwQcV, kbw,
     I     ipKW,   iMA, KWO_Lcd, KSW)
CCC_     + B1: B1 * Ny:d
      call UV1uma (W, QC, MH, LH, VMSN_B1, VMSC_NdY)
CCC_     + B1: B1 + Nx:d R:d
      call UV0uaa (W, MH, LH, VMSN_B1, VMSN_NxRd)
CCC_     + B.: SHIFT(B1)
      call AKBmex
     M    (W,    C,
     I     MH,   LH,  kbw, VMSN_B1,
     I     ipKW, iMA, KWO_Lba, KSW)
CCC_     + B.: B. * Corner[W]:c
      call UV1uma (W, QC, MH, LH, kbw, VMSC_CySwWc)
CCC_    * [ghost/x]  to B2  use B1
      kbw = VMSN_B2
CCC_     + B.: PcW      by P[W]:a
      call AKBuaz
     O    (W (1, kbw),  C,
     I     X (1, VMSX_PaW, KXR), QC,
     I     MH,    LH,  VMSC_PcWs, VMSC_PcWn,
     I     ipKW,  iMA, KWO_Lac, KSW)
CCC_     + B1: P:d      by PcV, PcW(clone)
      call AKBwbx
     O    (W,  C,
     I     WW,
     I     MH, LH, VMSN_B1, VMSN_SwPcV, kbw,
     I     ipKW,   iMA, KWO_Lcd, KSW)
CCC_     + B1: B1 * Nxxy:d
      call UV1uma (W, QC, MH, LH, VMSN_B1, VMSC_NdXXY)
CCC_     + B1: B1 + Nyxy:d R:d
      call UV0uaa (W, MH, LH, VMSN_B1, VMSN_NyRd)
CCC_     + B.: SHIFT(B1)
      call AKBmex
     M    (W,    C,
     I     MH,   LH,  kbw, VMSN_B1,
     I     ipKW, iMA, KWO_Lba, KSW)
CCC_     + B.: B. * Corner[W]:c
      call UV1uma (W, QC, MH, LH, kbw, VMSC_CxSwWc)
CCC_    * [ghost/xy] to B1  use B2 B3
CCC_     + B1: B2 + B3
      call UV0naa (W, MH, LH, VMSN_B1, VMSN_B2, VMSN_B3)
CCC_     + B1: B1 * G[W]:c
      call UV1uma (W, QC, MH, LH, VMSN_B1, VMSC_VcW_MG)
CCC_     + B1: B1 * Scale V:G
      call UV0uwa (W, MH, LH, VMSN_B1, QS (PMS_InvVG))
CCC_    * [fixed]    to B2
CCC_     + B2: u[W]:c * F[W]:c
      call UV3nma
     $    (W,       QC,          X (1, 1, KXR), MH, LH,
     $     VMSN_B2, VMSC_VcW_MF, VMSX_VcW)
CCC_     + B2: B2 * Scale V:F
      call UV0uwa (W, MH, LH, VMSN_B2, QS (PMS_InvVF))
CCC_    * [FG] to B1        use B2
      call UV0uaa (W, MH, LH, VMSN_B1, VMSN_B2)
CCC_    * [Drag] to B3
      call UV3nma
     $    (W,       QV,       X (1, 1, KXR), MH, LH,
     $     VMSN_B3, VMSV_BDc, VMSX_VcW)
CCC_    * B3: - Drag + MQR
      call UV1uma (W, QC, MH, LH, VMSN_B3, VMSC_Vc_MI)
      call UV0una (W, MH, LH, VMSN_B3, VMSN_MiQYRX)
CCC_    * [done v[W]:c] FGI = B1 + MPR
      call UV2nfa
     $     (X (1, 1, KXL), W, MH, LH, VMSX_VcW, VMSN_B1, VMSN_B3,
     $      QS (PMS_InvVI))
c$$$      call UV2nfa
c$$$     $     (X (1, 1, KXL), W, MH, LH, VMSX_VcW, VMSN_B1, VMSN_MiQYRX,
c$$$     $      QS (PMS_InvVI))
c$$$     call UV2naa
c$$$    $     (X (1, 1, KXL), W, MH, LH, VMSX_VcW, VMSN_B1, VMSN_MiQYRX)
#ifdef    DEBUG_XML_VW
      return
#endif /* DEBUG_XML_VW */
CCC_  - manual generation (rev 4)
CCC_   . PQR common
CCC_    * du/dx[S]:a    by u[S]:a group
      call AKGwaz
     O    (W (1, VMSN_DUDXaS),
     I     C,    X (1, VMSX_UbS, KXR),  WW,
     I     MH,   LH,  ipKW, 1, ipCG (1, CGS_UbS))
CCC_    * du/dx[N]:a    by u[N]:a group
      call AKGwaz
     O    (W (1, VMSN_DUDXaN),
     I     C,    X (1, VMSX_UbN, KXR),  WW,
     I     MH,   LH,  ipKW, 1, ipCG (1, CGS_UbN))
CCC_    * du/dx:a
      call UV0naa (W, MH, LH, VMSN_SumDUDXa, VMSN_DUDXaS, VMSN_DUDXaN)
CCC_    * dv/dy[W]:a    by v[W]:a group
      call AKGwaz
     O    (W (1, VMSN_DVDYaW),
     I     C,    X (1, VMSX_VcW, KXR),  WW,
     I     MH,   LH,  ipKW, 1, ipCG (1, CGS_VcW))
CCC_    * dv/dy[E]:a    by v[E]:a group
      call AKGwaz
     O    (W (1, VMSN_DVDYaE),
     I     C,    X (1, VMSX_VcE, KXR),  WW,
     I     MH,   LH,  ipKW, 1, ipCG (1, CGS_VcE))
CCC_    * dv/dy:a
      call UV0naa (W, MH, LH, VMSN_SumDVDYa, VMSN_DVDYaE, VMSN_DVDYaW)
CCC_  - P/Q automatic generation (rev 4)
CCC_   . P[EW]:a common
CCC_    * [interior]  mu (4 du/dx:a + 2 dv/dy:a) to PIa use B1 B2
CCC_     + B1:  4 du/dx[S]:a
      call UV0nwa (W, MH, LH, VMSN_B1,  VMSN_SumDUDXa, 4.0d0)
CCC_     + B2:  2 dv/dy[W]:a
      call UV0nwa (W, MH, LH, VMSN_B2,  VMSN_SumDVDYa, 2.0d0)
CCC_     + PIa: B1 + B2
      call UV0naa (W, MH, LH, VMSN_PIa, VMSN_B1, VMSN_B2)
CCC_     + PIa: PIa * mu:a
      call UV1uma (W, QV, MH, LH, VMSN_PIa, VMSV_MUa)
CCC_    * [ghost]  nx (nx P + ny R) to NPNR
CCC_     + B1: P:b = Lab P:a    by P[EW]:a
      call AKGwbz
     O    (W (1, VMSN_B1),
     I     C,    X (1, 1, KXR),
     I     WW,
     I     MH,   LH,  VMSX_PaE, VMSX_PaW,
     I     ipKW, 2,   ipCG (1, CGS_PaW))
CCC_     + B1: B1 * Nx:b Nx:b
      call UV1uma (W, QC, MH, LH, VMSN_B1, VMSC_NbXX)
CCC_     + B2: Rb: Ldb R:d   by R:d
      call AKGwaz
     O    (W (1, VMSN_B2),
     I     C,    X (1, VMSX_RdA, KXR),
     I     WW,
     I     MH,   LH,
     I     ipKW, 3,   ipCG (1, CGS_RdA))
CCC_     + B2: B2 * Ny:b Nx:b
      call UV1uma (W, QC, MH, LH, VMSN_B2, VMSC_NbYX)
CCC_     + NPNR: B1 + B2
      call UV0naa (W, MH, LH, VMSN_NPNRb, VMSN_B1, VMSN_B2)
CCC_   = P[E]:a
CCC_    * [interior]  2 mu (4 du/dx + 2 dv/dy) - 2 P:a
CCC_     + B1: PIa - 2 P[E]:a
      call UV1nfa
     $     (W, X (1,1,KXR), MH, LH, VMSN_B1, VMSN_PIa, VMSX_PaE, -2.0d0)
CCC_     + B1: B1 * I:a
      call UV1uma (W, QC, MH, LH, VMSN_B1, VMSC_Da_MI)
CCC_     + B1: B1 * Scale P:G
      call UV0uwa (W, MH, LH, VMSN_B1, QS (PMS_InvPI))
CCC_    * [fixed]     P:a
CCC_     + B2: P[E]:a * F[E]:a
      call UV3nma
     $    (W,       QC,          X (1, 1, KXR), MH, LH,
     $     VMSN_B2, VMSC_PaE_MF, VMSX_PaE)
CCC_     + B1: B1 + B2 = (I) + Scale (F)
      call UV0ufa (W, MH, LH, VMSN_B1, VMSN_B2, QS (PMS_InvPF))
CCC_    * [ghost]     Nx P + Ny R
CCC_     + SHIFT(NOP)
CCC_     + B3: NPNR * G[E]:a
      call UV1nma (W, QC, MH, LH, VMSN_B3, VMSN_NPNRb, VMSC_PaE_MG)
CCC_    * [done P[E]:a] FGI = B1 + Scale B3
      call UV2nfa (X (1, 1, KXL), W, MH, LH, VMSX_PaE, VMSN_B1, VMSN_B3,
     $             QS (PMS_InvPG))
CCC_   = P[W]:a
CCC_    * [interior]  2 mu (4 du/dx + 2 dv/dy) - 2 P:a
CCC_     + B1: PIa - 2 P[W]:a
      call UV1nfa
     $     (W, X (1,1,KXR), MH, LH, VMSN_B1, VMSN_PIa, VMSX_PaW, -2.0d0)
CCC_     + B1: B1 * I:a
      call UV1uma (W, QC, MH, LH, VMSN_B1, VMSC_Da_MI)
CCC_     + B1: B1 * Scale P:G
      call UV0uwa (W, MH, LH, VMSN_B1, QS (PMS_InvPI))
CCC_    * [fixed]     P:a
CCC_     + B2: P[W]:a * F[W]:a
      call UV3nma
     $    (W,       QC,          X (1, 1, KXR), MH, LH,
     $     VMSN_B2, VMSC_PaW_MF, VMSX_PaW)
CCC_     + B1: B1 + B2 = (I) + Scale (F)
      call UV0ufa (W, MH, LH, VMSN_B1, VMSN_B2, QS (PMS_InvPF))
CCC_    * [ghost]     Nx P + Ny R
CCC_     + B2: SHIFT NPNR
      call AKBmex
     M    (W,    C,
     I     MH,   LH,  VMSN_B2, VMSN_NPNRb,
     I     ipKW, iMA, KWO_Lba, KSW)
CCC_     + B3: B2 * G[W]:a
      call UV1nma (W, QC, MH, LH, VMSN_B3, VMSN_B2, VMSC_PaW_MG)
CCC_    * [done P[W]:a] FGI = B1 + Scale B3
      call UV2nfa (X (1, 1, KXL), W, MH, LH, VMSX_PaW, VMSN_B1, VMSN_B3,
     $             QS (PMS_InvPG))
CCC_   = P[N]:a
CCC_    * [ghost] to B1
CCC_     + B2: -2 P[N]:a
      call UV1nwa (W, X (1, 1, KXR), MH, LH, VMSN_B2, VMSX_PaN, -2.0d0)
CCC_     + B2: B2 + Q[N]:a
      call UV1uaa (W, X (1, 1, KXR), MH, LH, VMSN_B2, VMSX_QaN)
CCC_     + B1: du/dx[N]:a * mu[N]:a
      call UV1nma (W, QV, MH, LH, VMSN_B1, VMSN_DUDXaN, VMSV_MUaN)
CCC_     + B1: B1 * 6
      call UV0uwa (W, MH, LH, VMSN_B1, 6.0d0)
CCC_     + B1: B1 + B2
      call UV0uaa (W, MH, LH, VMSN_B1, VMSN_B2)
CCC_     + B2: scale G
      call UV1nwa (W, QC, MH, LH, VMSN_B2, VMSC_PaN_MG, QS (PMS_InvPG))
CCC_     + B1: B1 * B2
      call UV0uma (W, MH, LH, VMSN_B1, VMSN_B2)
CCC_    * [interior]  2 mu (4 du/dx + 2 dv/dy) - 2 P:a
CCC_     + B2: PIa - 2 P[N]:a
      call UV1nfa
     $     (W, X (1,1,KXR), MH, LH, VMSN_B2, VMSN_PIa, VMSX_PaN, -2.0d0)
CCC_     + B2: B2 * I
      call UV1uma (W, QC, MH, LH, VMSN_B2, VMSC_Da_MI)
CCC_     + B2: B2 * Scale
      call UV0uwa (W, MH, LH, VMSN_B2, QS (PMS_InvPI))
CCC_    * [interior+ghost] to B1
CCC_     + B1: B1 + B2
      call UV0uaa (W, MH, LH, VMSN_B1, VMSN_B2)
CCC_    * [fixed]
CCC_     + B2: P[N]:a * F[N]:a
      call UV3nma
     $    (W,       QC,          X (1, 1, KXR), MH, LH,
     $     VMSN_B2, VMSC_PaN_MF, VMSX_PaN)
CCC_    * [done P[N]:a] FGI = B1 + scale B2
      call UV2nfa (X (1, 1, KXL), W, MH, LH, VMSX_PaN, VMSN_B1, VMSN_B2,
     $             QS (PMS_InvPF))
CCC_   = P[S]:a
CCC_    * [ghost] to B1
CCC_     + B2: -2 P[S]:a
      call UV1nwa (W, X (1, 1, KXR), MH, LH, VMSN_B2, VMSX_PaS, -2.0d0)
CCC_     + B2: B2 + Q[S]:a
      call UV1uaa (W, X (1, 1, KXR), MH, LH, VMSN_B2, VMSX_QaS)
CCC_     + B1: du/dx[S]:a * mu[S]:a
      call UV1nma (W, QV, MH, LH, VMSN_B1, VMSN_DUDXaS, VMSV_MUaS)
CCC_     + B1: B1 * 6
      call UV0uwa (W, MH, LH, VMSN_B1, 6.0d0)
CCC_     + B1: B1 + B2
      call UV0uaa (W, MH, LH, VMSN_B1, VMSN_B2)
CCC_     + B2: scale G
      call UV1nwa (W, QC, MH, LH, VMSN_B2, VMSC_PaS_MG, QS (PMS_InvPG))
CCC_     + B1: B1 * B2
      call UV0uma (W, MH, LH, VMSN_B1, VMSN_B2)
CCC_    * [interior]  2 mu (4 du/dx + 2 dv/dy) - 2 P:a
CCC_     + B2: PIa - 2 P[S]:a
      call UV1nfa
     $     (W, X (1,1,KXR), MH, LH, VMSN_B2, VMSN_PIa, VMSX_PaS, -2.0d0)
CCC_     + B2: B2 * I
      call UV1uma (W, QC, MH, LH, VMSN_B2, VMSC_Da_MI)
CCC_     + B2: B2 * Scale
      call UV0uwa (W, MH, LH, VMSN_B2, QS (PMS_InvPI))
CCC_    * [interior+ghost] to B1
CCC_     + B1: B1 + B2
      call UV0uaa (W, MH, LH, VMSN_B1, VMSN_B2)
CCC_    * [fixed]
CCC_     + B2: P[S]:a * F[S]:a
      call UV3nma
     $    (W,       QC,          X (1, 1, KXR), MH, LH,
     $     VMSN_B2, VMSC_PaS_MF, VMSX_PaS)
CCC_    * [done P[S]:a] FGI = B1 + scale B2
      call UV2nfa (X (1, 1, KXL), W, MH, LH, VMSX_PaS, VMSN_B1, VMSN_B2,
     $             QS (PMS_InvPF))
CCC_   . Q[NS]:a common
CCC_    * [interior]  mu (4 dv/dy:a + 2 du/dx:a) to QIa use B1 B2
CCC_     + B1:  4 dv/dy[W]:a
      call UV0nwa (W, MH, LH, VMSN_B1,  VMSN_SumDVDYa, 4.0d0)
CCC_     + B2:  2 du/dx[S]:a
      call UV0nwa (W, MH, LH, VMSN_B2,  VMSN_SumDUDXa, 2.0d0)
CCC_     + QIa: B1 + B2
      call UV0naa (W, MH, LH, VMSN_QIa, VMSN_B1, VMSN_B2)
CCC_     + QIa: QIa * mu:a
      call UV1uma (W, QV, MH, LH, VMSN_QIa, VMSV_MUa)
CCC_    * [ghost]  ny (ny Q + nx R) to NQNR
CCC_     + B1: Q:c = Lac Q:a    by Q[NS]:a
      call AKGwbz
     O    (W (1, VMSN_B1),
     I     C,    X (1, 1, KXR),
     I     WW,
     I     MH,   LH,  VMSX_QaN, VMSX_QaS,
     I     ipKW, 2,   ipCG (1, CGS_QaS))
CCC_     + B1: B1 * Ny:c Ny:c
      call UV1uma (W, QC, MH, LH, VMSN_B1, VMSC_NcYY)
CCC_     + B2: Rc: Ldc R:d   by R:d
      call AKGwaz
     O    (W (1, VMSN_B2),
     I     C,    X (1, VMSX_RdA, KXR),
     I     WW,
     I     MH,   LH,
     I     ipKW, 4,   ipCG (1, CGS_RdA))
CCC_     + B2: B2 * Nx:c Ny:c
      call UV1uma (W, QC, MH, LH, VMSN_B2, VMSC_NcXY)
CCC_     + NQNR: B1 + B2
      call UV0naa (W, MH, LH, VMSN_NQNRc, VMSN_B1, VMSN_B2)
CCC_   = Q[N]:a
CCC_    * [interior]  2 mu (4 dv/dy + 2 du/dx) - 2 Q:a
CCC_     + B1: QIa - 2 Q[N]:a
      call UV1nfa
     $     (W, X (1,1,KXR), MH, LH, VMSN_B1, VMSN_QIa, VMSX_QaN, -2.0d0)
CCC_     + B1: B1 * I:a
      call UV1uma (W, QC, MH, LH, VMSN_B1, VMSC_Da_MI)
CCC_     + B1: B1 * Scale Q:G
      call UV0uwa (W, MH, LH, VMSN_B1, QS (PMS_InvQI))
CCC_    * [fixed]     Q:a
CCC_     + B2: Q[N]:a * F[N]:a
      call UV3nma
     $    (W,       QC,          X (1, 1, KXR), MH, LH,
     $     VMSN_B2, VMSC_QaN_MF, VMSX_QaN)
CCC_     + B1: B1 + B2 = (I) + Scale (F)
      call UV0ufa (W, MH, LH, VMSN_B1, VMSN_B2, QS (PMS_InvQF))
CCC_    * [ghost]     Ny Q + Nx R
CCC_     + SHIFT(NOP)
CCC_     + B3: NQNR * G[N]:a
      call UV1nma (W, QC, MH, LH, VMSN_B3, VMSN_NQNRc, VMSC_QaN_MG)
CCC_    * [done Q[N]:a] FGI = B1 + Scale B3
      call UV2nfa (X (1, 1, KXL), W, MH, LH, VMSX_QaN, VMSN_B1, VMSN_B3,
     $             QS (PMS_InvQG))
CCC_   = Q[S]:a
CCC_    * [interior]  2 mu (4 dv/dy + 2 du/dx) - 2 Q:a
CCC_     + B1: QIa - 2 Q[S]:a
      call UV1nfa
     $     (W, X (1,1,KXR), MH, LH, VMSN_B1, VMSN_QIa, VMSX_QaS, -2.0d0)
CCC_     + B1: B1 * I:a
      call UV1uma (W, QC, MH, LH, VMSN_B1, VMSC_Da_MI)
CCC_     + B1: B1 * Scale Q:G
      call UV0uwa (W, MH, LH, VMSN_B1, QS (PMS_InvQI))
CCC_    * [fixed]     Q:a
CCC_     + B2: Q[S]:a * F[S]:a
      call UV3nma
     $    (W,       QC,          X (1, 1, KXR), MH, LH,
     $     VMSN_B2, VMSC_QaS_MF, VMSX_QaS)
CCC_     + B1: B1 + B2 = (I) + Scale (F)
      call UV0ufa (W, MH, LH, VMSN_B1, VMSN_B2, QS (PMS_InvQF))
CCC_    * [ghost]     Ny Q + Nx R
CCC_     + B2: SHIFT NQNR
      call AKBmex
     M    (W,    C,
     I     MH,   LH,  VMSN_B2, VMSN_NQNRc,
     I     ipKW, iMA, KWO_Lca, KSW)
CCC_     + B3: B2 * G[S]:a
      call UV1nma (W, QC, MH, LH, VMSN_B3, VMSN_B2, VMSC_QaS_MG)
CCC_    * [done Q[S]:a] FGI = B1 + Scale B3
      call UV2nfa (X (1, 1, KXL), W, MH, LH, VMSX_QaS, VMSN_B1, VMSN_B3,
     $             QS (PMS_InvQG))
CCC_   = Q[E]:a
CCC_    * [ghost] to B1
CCC_     + B2: -2 Q[E]:a
      call UV1nwa (W, X (1, 1, KXR), MH, LH, VMSN_B2, VMSX_QaE, -2.0d0)
CCC_     + B2: B2 + P[E]:a
      call UV1uaa (W, X (1, 1, KXR), MH, LH, VMSN_B2, VMSX_PaE)
CCC_     + B1: dv/dy[E]:a * mu[E]:a
      call UV1nma (W, QV, MH, LH, VMSN_B1, VMSN_DVDYaE, VMSV_MUaE)
CCC_     + B1: B1 * 6
      call UV0uwa (W, MH, LH, VMSN_B1, 6.0d0)
CCC_     + B1: B1 + B2
      call UV0uaa (W, MH, LH, VMSN_B1, VMSN_B2)
CCC_     + B2: scale G
      call UV1nwa (W, QC, MH, LH, VMSN_B2, VMSC_QaE_MG, QS (PMS_InvQG))
CCC_     + B1: B1 * B2
      call UV0uma (W, MH, LH, VMSN_B1, VMSN_B2)
CCC_    * [interior]  2 mu (4 dv/dy + 2 du/dx) - 2 Q:a
CCC_     + B2: QIa - 2 Q[E]:a
      call UV1nfa
     $     (W, X (1,1,KXR), MH, LH, VMSN_B2, VMSN_QIa, VMSX_QaE, -2.0d0)
CCC_     + B2: B2 * I
      call UV1uma (W, QC, MH, LH, VMSN_B2, VMSC_Da_MI)
CCC_     + B2: B2 * Scale
      call UV0uwa (W, MH, LH, VMSN_B2, QS (PMS_InvQI))
CCC_    * [interior+ghost] to B1
CCC_     + B1: B1 + B2
      call UV0uaa (W, MH, LH, VMSN_B1, VMSN_B2)
CCC_    * [fixed]
CCC_     + B2: Q[E]:a * F[E]:a
      call UV3nma
     $    (W,       QC,          X (1, 1, KXR), MH, LH,
     $     VMSN_B2, VMSC_QaE_MF, VMSX_QaE)
CCC_    * [done Q[E]:a] FGI = B1 + scale B2
      call UV2nfa (X (1, 1, KXL), W, MH, LH, VMSX_QaE, VMSN_B1, VMSN_B2,
     $             QS (PMS_InvQF))
CCC_   = Q[W]:a
CCC_    * [ghost] to B1
CCC_     + B2: -2 Q[W]:a
      call UV1nwa (W, X (1, 1, KXR), MH, LH, VMSN_B2, VMSX_QaW, -2.0d0)
CCC_     + B2: B2 + P[W]:a
      call UV1uaa (W, X (1, 1, KXR), MH, LH, VMSN_B2, VMSX_PaW)
CCC_     + B1: dv/dy[W]:a * mu[W]:a
      call UV1nma (W, QV, MH, LH, VMSN_B1, VMSN_DVDYaW, VMSV_MUaW)
CCC_     + B1: B1 * 6
      call UV0uwa (W, MH, LH, VMSN_B1, 6.0d0)
CCC_     + B1: B1 + B2
      call UV0uaa (W, MH, LH, VMSN_B1, VMSN_B2)
CCC_     + B2: scale G
      call UV1nwa (W, QC, MH, LH, VMSN_B2, VMSC_QaW_MG, QS (PMS_InvQG))
CCC_     + B1: B1 * B2
      call UV0uma (W, MH, LH, VMSN_B1, VMSN_B2)
CCC_    * [interior]  2 mu (4 dv/dy + 2 du/dx) - 2 Q:a
CCC_     + B2: QIa - 2 Q[W]:a
      call UV1nfa
     $     (W, X (1,1,KXR), MH, LH, VMSN_B2, VMSN_QIa, VMSX_QaW, -2.0d0)
CCC_     + B2: B2 * I
      call UV1uma (W, QC, MH, LH, VMSN_B2, VMSC_Da_MI)
CCC_     + B2: B2 * Scale
      call UV0uwa (W, MH, LH, VMSN_B2, QS (PMS_InvQI))
CCC_    * [interior+ghost] to B1
CCC_     + B1: B1 + B2
      call UV0uaa (W, MH, LH, VMSN_B1, VMSN_B2)
CCC_    * [fixed]
CCC_     + B2: Q[W]:a * F[W]:a
      call UV3nma
     $    (W,       QC,          X (1, 1, KXR), MH, LH,
     $     VMSN_B2, VMSC_QaW_MF, VMSX_QaW)
CCC_    * [done Q[W]:a] FGI = B1 + scale B2
      call UV2nfa (X (1, 1, KXL), W, MH, LH, VMSX_QaW, VMSN_B1, VMSN_B2,
     $             QS (PMS_InvQF))
CCC_  - manual generation (rev 4)
CCC_   = R:d
CCC_    * [interior] du/dy[NS] to B3  use B1 B2
CCC_     + B1: du/dy[N]:d
      call AKBwaz
     O    (W (1, VMSN_B1),  C,
     I     X (1, VMSX_UbN, KXR), WW,
     I     MH,   LH,  ipKW, iMA, KWO_GYbd, KSW)
CCC_     + B1: B1 * Switch dy[N]:d
      call UV1uma (W, QC, MH, LH, VMSN_B1, VMSC_DySwNd)
CCC_     + B2: du/dy[S]:d
      call AKGwaz
     O    (W (1, VMSN_B2),
     I     C,    X (1, VMSX_UbS, KXR), WW,
     I     MH,   LH,  ipKW, 2, ipCG (1, CGS_UbS))
CCC_     + B2: B2 * Switch dy[S]:d
      call UV1uma (W, QC, MH, LH, VMSN_B2, VMSC_DySwSd)
CCC_     + B3: B1 + B2
      call UV0naa (W, MH, LH, VMSN_B3, VMSN_B1, VMSN_B2)
CCC_    * [interior] dv/dx[EW] to B4  use B1 B2
CCC_     + B1: dv/dx[E]:d
      call AKBwaz
     O    (W (1, VMSN_B1),  C,
     I     X (1, VMSX_VcE, KXR), WW,
     I     MH,   LH,  ipKW, iMA, KWO_GXcd, KSW)
CCC_     + B1: B1 * Switch dx[E]:d
      call UV1uma (W, QC, MH, LH, VMSN_B1, VMSC_DxSwEd)
CCC_     + B2: dv/dx[W]:d
      call AKGwaz
     O    (W (1, VMSN_B2),
     I     C,    X (1, VMSX_VcW, KXR), WW,
     I     MH,   LH,  ipKW, 2, ipCG (1, CGS_VcW))
CCC_     + B2: B2 * Switch dx[W]:d
      call UV1uma (W, QC, MH, LH, VMSN_B2, VMSC_DxSwWd)
CCC_     + B4: B1 + B2
      call UV0naa (W, MH, LH, VMSN_B4, VMSN_B1, VMSN_B2)
CCC_    * B1: B3 + B4
      call UV0naa (W, MH, LH, VMSN_B1, VMSN_B3, VMSN_B4)
CCC_    * B1: B1 * mu:d
      call UV1uma (W, QV, MH, LH, VMSN_B1, VMSV_MUd)
CCC_    * B1: B1 - R:d
      call UV1usa (W, X (1, 1, KXR), MH, LH, VMSN_B1,  VMSX_RdA)
CCC_    * B1: B1 * I
      call UV1uma (W, QC, MH, LH, VMSN_B1, VMSC_Rd_MI)
CCC_    * B1: B1 * Scale
      call UV0uwa (W, MH, LH, VMSN_B1, QS (PMS_InvRI))
CCC_    * [fixed] to B2
CCC_      - B2: F:d * R:d
      call UV3nma
     $    (W,       QC,          X (1, 1, KXR), MH, LH,
     $     VMSN_B2, VMSC_RdA_MF, VMSX_RdA)
CCC_    * [done R:d] FI = B1 + Scale B2
      call UV2nfa (X (1, 1, KXL), W, MH, LH, VMSX_RdA, VMST_B1, VMST_B2,
     $             QS (PMS_InvRF))
CCC_  - return
      RETURN
      END
CCC_ & MSBsns  ## SSA/b/matrix solver suite (13 unknowns)
      subroutine MSBsns
     M    (X,
     I     KXL,  KXR,
     W     C,    W,
     I     QS,   QC,   QV,   WW,
     I     iMA,  ipKW, ipCG, MH, LH, LXK, LCG)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH, KXR, KXL
      _INTENT(IN,   integer)  LXK, LCG
      _INTENT(INOUT,_REALSTD) X    (LH, LXK, *)
      _INTENT(OUT,  _REALSTD) C    (LH,  *)
      _INTENT(OUT,  _REALSTD) W    (LH,  *)
      _INTENT(IN,   _REALSTD) QS   (*)
      _INTENT(IN,   _REALSTD) QC   (LH,  *)
      _INTENT(IN,   _REALSTD) QV   (LH,  *)
      _INTENT(IN,   _REALSTD) WW   (LH,  *)
      _INTENT(IN,   integer)  iMA  (*),  ipKW (*)
      _INTENT(IN,   integer)  ipCG (LCG, *)
      integer jv, jh
      integer KT
      integer KSW
CCC_  - Body
      KSW = KWM_M
      KT  = 1
CCC_   . just copy
      do jv = 1, VMSX_MAX
         do jh = 1, MH
            X (jh, jv, KXL) = X (jh, jv, KXR)
         enddo
      enddo
CCC_   . return
      return
      END
CCC_ & MSBxmt  ## SSA/b/matrix multiplication suite transpose (13 unknowns)
      subroutine MSBxmt
     M    (X,
     I     KXL,  KXR,
     W     C,    W,
     I     QS,   QC,   QV,   WW,
     I     iMA,  ipKW, ipCG, MH, LH, LXK, LCG)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH, KXR, KXL
      _INTENT(IN,   integer)  LXK, LCG
      _INTENT(INOUT,_REALSTD) X    (LH, LXK, *)
      _INTENT(OUT,  _REALSTD) C    (LH,  *)
      _INTENT(OUT,  _REALSTD) W    (LH,  *)
      _INTENT(IN,   _REALSTD) QS   (*)
      _INTENT(IN,   _REALSTD) QC   (LH,  *)
      _INTENT(IN,   _REALSTD) QV   (LH,  *)
      _INTENT(IN,   _REALSTD) WW   (*)
      _INTENT(IN,   integer)  iMA  (*),  ipKW (*)
      _INTENT(IN,   integer)  ipCG (LCG, *)
      integer KT
      integer KSW
CCC_  - Body
      KSW = KWM_T
      KT  = 1
CCC_   . common
CCC_    * IGPN
CCC_     + IGPN: scale G[N]:a
      call UV1nwa (W,QC, MH,LH, VMST_IGPN, VMSC_PaN_MG, QS(PMS_InvPG))
CCC_     + IGPN: IGPN * P[N]:a
      call UV1uma (W, X (1, 1, KXR), MH,LH, VMST_IGPN, VMSX_PaN)
CCC_    * IGPS
CCC_     + IGPS: scale G[S]:a
      call UV1nwa (W,QC, MH,LH, VMST_IGPS, VMSC_PaS_MG, QS(PMS_InvPG))
CCC_     + IGPS: IGPS * P[S]:a
      call UV1uma (W, X (1, 1, KXR), MH,LH, VMST_IGPS, VMSX_PaS)
CCC_    * IGQE
CCC_     + IGQE: scale G[E]:a
      call UV1nwa (W,QC, MH,LH, VMST_IGQE, VMSC_QaE_MG, QS(PMS_InvQG))
CCC_     + IGQE: IGQE * Q[E]:a
      call UV1uma (W, X (1, 1, KXR), MH,LH, VMST_IGQE, VMSX_QaE)
CCC_    * IGQW
CCC_     + IGQW: scale G[W]:a
      call UV1nwa (W,QC, MH,LH, VMST_IGQW, VMSC_QaW_MG, QS(PMS_InvQG))
CCC_     + IGQW: IGQW * Q[W]:a
      call UV1uma (W, X (1, 1, KXR), MH,LH, VMST_IGQW, VMSX_QaW)
CCC_   . uv common
CCC_    * B1: mu I
      call UV3nma (W, QC, QV, MH, LH, VMST_B1, VMSC_Da_MI, VMSV_MUa)
CCC_    * muIPa   mu I (P+P+P+P)
CCC_     + B2: P[E]:a + P[W]:a
      call UV2naa
     $     (W, X (1, 1, KXR), MH,LH, VMST_B2, VMSX_PaE, VMSX_PaW)
CCC_     + B3: P[N]:a + P[S]:a
      call UV2naa
     $     (W, X (1, 1, KXR), MH,LH, VMST_B3, VMSX_PaN, VMSX_PaS)
CCC_     + muIPa: P[E+W+N+S]:a
      call UV0naa (W, MH,LH, VMST_MuIPa, VMST_B2, VMST_B3)
CCC_     + muIPa: muIPa * B1
      call UV0uma (W, MH, LH, VMST_MuIPa, VMST_B1)
CCC_     + muIPa: muIPa * scale I
      call UV0uwa (W, MH, LH, VMST_MuIPa, QS (PMS_InvPI))
CCC_    * muIQa   mu I (Q+Q)
CCC_     + B2: Q[N]:a + Q[S]:a
      call UV2naa
     $     (W, X (1, 1, KXR), MH,LH, VMST_B2, VMSX_QaN, VMSX_QaS)
CCC_     + B3: Q[E]:a + Q[W]:a
      call UV2naa
     $     (W, X (1, 1, KXR), MH,LH, VMST_B3, VMSX_QaE, VMSX_QaW)
CCC_     + muIQa: Q[E+W+N+S]:a
      call UV0naa (W, MH,LH, VMST_MuIQa, VMST_B2, VMST_B3)
CCC_     + muIQa: muIQa * B1
      call UV0uma (W, MH, LH, VMST_MuIQa, VMST_B1)
CCC_     + muIQa: muIQa * scale I
      call UV0uwa (W, MH, LH, VMST_MuIQa, QS (PMS_InvQI))
CCC_    * muIRd
CCC_     + muIRd: mu I
      call UV3nma (W, QC, QV, MH, LH, VMST_MuIRd, VMSC_Rd_MI, VMSV_MUd)
CCC_     + muIRd: muIRd * R:d
      call UV1uma
     $     (W, X (1, 1, KXR), MH,LH, VMST_MuIRd, VMSX_RdA)
CCC_     + muIRd: muIRd * scale I
      call UV0uwa (W, MH, LH, VMST_MuIRd, QS (PMS_InvRI))
CCC_   . clone group
CCC_  - u/v automatic generation (rev 4)
CCC_   . u:b common
CCC_    * P[EW] Q[NS]
CCC_     + B1: 4 muIPa
      call UV0nwa (W, MH, LH, VMST_B1, VMST_MuIPa, 4.0d0)
CCC_     + B2: 2 muIQa
      call UV0nwa (W, MH, LH, VMST_B2, VMST_MuIQa, 2.0d0)
CCC_     + SumPQ: B1 + B2
      call UV0naa (W, MH, LH, VMST_SumMuIPQ, VMST_B1, VMST_B2)
CCC_   = u[N]:b
CCC_    * P[N]:a
CCC_     + B1: IGPN * Mu[N]:a
      call UV1nma (W, QV,  MH,LH, VMST_B1, VMST_IGPN, VMSV_MUaN)
CCC_     + B1: B1 * 6
      call UV0uwa (W,      MH,LH, VMST_B1, 6.0d0)
CCC_    * T d/dx PQ:a
CCC_     + B1: B1 + SumMuIPQ
      call UV0uaa (W, MH, LH, VMST_B1, VMST_SumMuIPQ)
CCC_     + B2: T d/dx b:a B1
      call AKBwax
     M    (W,    C,
     I     WW,
     I     MH,   LH,  VMST_B2, VMST_B1,
     I     ipKW, iMA, KWO_GXba, KSW)
CCC_    * R:d
CCC_     + B1: muIRd * Dysw[N]:d
      call UV1nma (W, QC, MH, LH, VMST_B1, VMST_MuIRd, VMSC_DySwNd)
CCC_     + B3: T d/dy b:d B1
      call AKBwax
     M    (W,    C,
     I     WW,
     I     MH,   LH,  VMST_B3, VMST_B1,
     I     ipKW, iMA, KWO_GYbd, KSW)
CCC_    * B1: B2 + B3
      call UV0naa (W, MH, LH, VMST_B1, VMST_B2, VMST_B3)
CCC_    * Drag
CCC_     + B3: drag:b * u[N]:b
      call UV3nma
     $    (W,       QV,       X (1, 1, KXR), MH, LH,
     $     VMST_B3, VMSV_BDb, VMSX_UbN)
CCC_     + B3: I[u]
      call UV1uma (W, QC, MH,LH, VMST_B3, VMSC_Ub_MI)
CCC_     + B1: B1 + scale B3
      call UV0ufa (W, MH, LH, VMST_B1, VMST_B3, -QS (PMS_InvUI))
CCC_    * u[N]:b
CCC_     + B2: F[N]:b * u[N]:b
      call UV3nma
     $     (W, X (1, 1, KXR), QC, MH,LH, VMST_B2, VMSX_UbN,VMSC_UbN_MF)
CCC_    * [done u[N]:b] B1 + scale B2
      call UV2nfa (X (1, 1, KXL), W, MH, LH, VMSX_UbN, VMST_B1, VMST_B2,
     $             QS (PMS_InvUF))
CCC_   = u[S]:b
CCC_    * P[S]:a
CCC_     + B1: IGPS * Mu[S]:a
      call UV1nma (W, QV,  MH,LH, VMST_B1, VMST_IGPS, VMSV_MUaS)
CCC_     + B1: B1 * 6
      call UV0uwa (W,      MH,LH, VMST_B1, 6.0d0)
CCC_    * T d/dx PQ:a
CCC_     + B1: B1 + SumMuIPQ
      call UV0uaa (W, MH, LH, VMST_B1, VMST_SumMuIPQ)
CCC_     + B2: T d/dx b:a B1
      call AKBwax
     M    (W,    C,
     I     WW,
     I     MH,   LH,  VMST_B2, VMST_B1,
     I     ipKW, iMA, KWO_GXba, KSW)
CCC_    * R:d
CCC_     + B1: muIRd * Dysw[S]:d
      call UV1nma (W, QC, MH, LH, VMST_B1, VMST_MuIRd, VMSC_DySwSd)
CCC_     + B3: T d/dy b:d B1
      call AKBwax
     M    (W,    C,
     I     WW,
     I     MH,   LH,  VMST_B3, VMST_B1,
     I     ipKW, iMA, KWO_GYbd, KSW)
CCC_    * B1: B2 + B3
      call UV0naa (W, MH, LH, VMST_B1, VMST_B2, VMST_B3)
CCC_    * Drag
CCC_     + B3: drag:b * u[S]:b
      call UV3nma
     $    (W,       QV,       X (1, 1, KXR), MH, LH,
     $     VMST_B3, VMSV_BDb, VMSX_UbS)
CCC_     + B3: I[u]
      call UV1uma (W, QC, MH,LH, VMST_B3, VMSC_Ub_MI)
CCC_     + B1: B1 + scale B3
      call UV0ufa (W, MH, LH, VMST_B1, VMST_B3, -QS (PMS_InvUI))
CCC_    * u[S]:b
CCC_     + B2: F[S]:b * u[S]:b
      call UV3nma
     $     (W, X (1, 1, KXR), QC, MH,LH, VMST_B2, VMSX_UbS,VMSC_UbS_MF)
CCC_    * [done u[S]:b] B1 + scale B2
      call UV2nfa (X (1, 1, KXL), W, MH, LH, VMSX_UbS, VMST_B1, VMST_B2,
     $             QS (PMS_InvUF))
CCC_   . v:c common
CCC_    * P[EW] Q[NS]
CCC_     + B1: 2 muIPa
      call UV0nwa (W, MH, LH, VMST_B1, VMST_MuIPa, 2.0d0)
CCC_     + B2: 4 muIQa
      call UV0nwa (W, MH, LH, VMST_B2, VMST_MuIQa, 4.0d0)
CCC_     + SumPQ: B1 + B2
      call UV0naa (W, MH, LH, VMST_SumMuIPQ, VMST_B1, VMST_B2)
CCC_   = v[E]:c
CCC_    * Q[E]:a
CCC_     + B1: IGQE * Mu[E]:a
      call UV1nma (W, QV,  MH,LH, VMST_B1, VMST_IGQE, VMSV_MUaE)
CCC_     + B1: B1 * 6
      call UV0uwa (W,      MH,LH, VMST_B1, 6.0d0)
CCC_    * T d/dy PQ:a
CCC_     + B1: B1 + SumMuIPQ
      call UV0uaa (W, MH, LH, VMST_B1, VMST_SumMuIPQ)
CCC_     + B2: T d/dy c:a B1
      call AKBwax
     M    (W,    C,
     I     WW,
     I     MH,   LH,  VMST_B2, VMST_B1,
     I     ipKW, iMA, KWO_GYca, KSW)
CCC_    * R:d
CCC_     + B1: muIRd * Dxsw[E]:d
      call UV1nma (W, QC, MH, LH, VMST_B1, VMST_MuIRd, VMSC_DxSwEd)
CCC_     + B3: T d/dx c:d B1
      call AKBwax
     M    (W,    C,
     I     WW,
     I     MH,   LH,  VMST_B3, VMST_B1,
     I     ipKW, iMA, KWO_GXcd, KSW)
CCC_    * B1: B2 + B3
      call UV0naa (W, MH, LH, VMST_B1, VMST_B2, VMST_B3)
CCC_    * Drag
CCC_     + B3: drag:c * v[E]:c
      call UV3nma
     $    (W,       QV,       X (1, 1, KXR), MH, LH,
     $     VMST_B3, VMSV_BDc, VMSX_VcE)
CCC_     + B3: I[u]
      call UV1uma (W, QC, MH,LH, VMST_B3, VMSC_Vc_MI)
CCC_     + B1: B1 + scale B3
      call UV0ufa (W, MH, LH, VMST_B1, VMST_B3, -QS (PMS_InvVI))
CCC_    * v[E]:c
CCC_     + B2: F[E]:c * v[E]:c
      call UV3nma
     $     (W, X (1, 1, KXR), QC, MH,LH, VMST_B2, VMSX_VcE,VMSC_VcE_MF)
CCC_    * [done v[E]:c] B1 + scale B2
      call UV2nfa (X (1, 1, KXL), W, MH, LH, VMSX_VcE, VMST_B1, VMST_B2,
     $             QS (PMS_InvVF))
CCC_   = v[W]:c
CCC_    * Q[W]:a
CCC_     + B1: IGQW * Mu[W]:a
      call UV1nma (W, QV,  MH,LH, VMST_B1, VMST_IGQW, VMSV_MUaW)
CCC_     + B1: B1 * 6
      call UV0uwa (W,      MH,LH, VMST_B1, 6.0d0)
CCC_    * T d/dy PQ:a
CCC_     + B1: B1 + SumMuIPQ
      call UV0uaa (W, MH, LH, VMST_B1, VMST_SumMuIPQ)
CCC_     + B2: T d/dy c:a B1
      call AKBwax
     M    (W,    C,
     I     WW,
     I     MH,   LH,  VMST_B2, VMST_B1,
     I     ipKW, iMA, KWO_GYca, KSW)
CCC_    * R:d
CCC_     + B1: muIRd * Dxsw[W]:d
      call UV1nma (W, QC, MH, LH, VMST_B1, VMST_MuIRd, VMSC_DxSwWd)
CCC_     + B3: T d/dx c:d B1
      call AKBwax
     M    (W,    C,
     I     WW,
     I     MH,   LH,  VMST_B3, VMST_B1,
     I     ipKW, iMA, KWO_GXcd, KSW)
CCC_    * B1: B2 + B3
      call UV0naa (W, MH, LH, VMST_B1, VMST_B2, VMST_B3)
CCC_    * Drag
CCC_     + B3: drag:c * v[W]:c
      call UV3nma
     $    (W,       QV,       X (1, 1, KXR), MH, LH,
     $     VMST_B3, VMSV_BDc, VMSX_VcW)
CCC_     + B3: I[u]
      call UV1uma (W, QC, MH,LH, VMST_B3, VMSC_Vc_MI)
CCC_     + B1: B1 + scale B3
      call UV0ufa (W, MH, LH, VMST_B1, VMST_B3, -QS (PMS_InvVI))
CCC_    * v[W]:c
CCC_     + B2: F[W]:c * v[W]:c
      call UV3nma
     $     (W, X (1, 1, KXR), QC, MH,LH, VMST_B2, VMSX_VcW,VMSC_VcW_MF)
CCC_    * [done v[W]:c] B1 + scale B2
      call UV2nfa (X (1, 1, KXL), W, MH, LH, VMSX_VcW, VMST_B1, VMST_B2,
     $             QS (PMS_InvVF))
CCC_  - manual generation (rev 4)
CCC_   . PQR common
CCC_    * I(u+u)
CCC_     + Iuu: u[N] + u[S]
      call UV2naa
     $     (W, X (1,1,KXR), MH, LH, VMST_Iuu, VMSX_UbN, VMSX_UbS)
CCC_     + Iuu: mask.I.u
      call UV1uma (W, QC, MH, LH, VMST_Iuu, VMSC_Ub_MI)
CCC_     + Iuu: scale
      call UV0uwa (W,     MH, LH, VMST_Iuu, QS (PMS_InvUI))
CCC_    * I(v+v)
CCC_     + Ivv: v[E] + v[W]
      call UV2naa
     $     (W, X (1,1,KXR), MH, LH, VMST_Ivv, VMSX_VcE, VMSX_VcW)
CCC_     + Ivv: mask.I.v
      call UV1uma (W, QC, MH, LH, VMST_Ivv, VMSC_Vc_MI)
CCC_     + Ivv: scale
      call UV0uwa (W,     MH, LH, VMST_Ivv, QS (PMS_InvVI))
CCC_    * (SHIFT G:a P[E] + SHIFT G:a P[W])
CCC_     + B1: G[W]:a * P[W]:a
      call UV3nma
     $     (W, X (1,1,KXR), QC, MH,LH, VMST_B1, VMSX_PaW,VMSC_PaW_MG)
CCC_     + B2: shift B1
      call AKBmex
     M    (W,    C,
     I     MH,   LH,  VMST_B2, VMST_B1,
     I     ipKW, iMA, KWO_Lba, KSW)
CCC_     + B1: G[E]:a * P[E]:a
      call UV3nma
     $     (W, X (1,1,KXR), QC, MH,LH, VMST_B1, VMSX_PaE,VMSC_PaE_MG)
CCC_     + SHIFT (NOP)
CCC_     + GSumPa: B1 + B2
      call UV0naa (W, MH, LH, VMST_GSumPa, VMST_B1, VMST_B2)
CCC_     + GSumPa: GsumPa * Scale
      call UV0uwa (W,     MH, LH, VMST_GSumPa, QS (PMS_InvPG))
CCC_    * (SHIFT G:a Q[N] + SHIFT G:a Q[S])
CCC_     + B1: G[S]:a * Q[S]:a
      call UV3nma
     $     (W, X (1,1,KXR), QC, MH,LH, VMST_B1, VMSX_QaS,VMSC_QaS_MG)
CCC_     + B2: shift B1
      call AKBmex
     M    (W,    C,
     I     MH,   LH,  VMST_B2, VMST_B1,
     I     ipKW, iMA, KWO_Lca, KSW)
CCC_     + B1: G[N]:a * Q[N]:a
      call UV3nma
     $     (W, X (1,1,KXR), QC, MH,LH, VMST_B1, VMSX_QaN,VMSC_QaN_MG)
CCC_     + SHIFT (NOP)
CCC_     + GSumQa: B1 + B2
      call UV0naa (W, MH, LH, VMST_GSumQa, VMST_B1, VMST_B2)
CCC_     + GSumQa: GsumQa * Scale
      call UV0uwa (W,     MH, LH, VMST_GSumQa, QS (PMS_InvQG))
CCC_  - P/Q automatic generation (rev 4)
CCC_   . P:a common
CCC_    * SHIFT Cx:b G:b u:b [N]  to B1
CCC_     + B1: G[N]:b u[N]:b
      call UV3nma
     $     (W, X (1, 1, KXR), QC, MH,LH, VMST_B1, VMSX_UbN, VMSC_UbN_MG)
CCC_     + B1: B1 * Cxsw[N]:b
      call UV1uma (W, QC, MH, LH, VMST_B1, VMSC_CxSwNb)
CCC_     + B1: B1 * Scale
      call UV0uwa (W, MH, LH, VMST_B1, QS (PMS_InvUG))
CCC_     + B1: SHIFT(NOP)
CCC_    * SHIFT Cx:b G:b u:b [S]  to B2 use B3
CCC_     + B3: G[S]:b u[S]:b
      call UV3nma
     $     (W, X (1, 1, KXR), QC, MH,LH, VMST_B3, VMSX_UbS,VMSC_UbS_MG)
CCC_     + B3: B3 * Cxsw[S]:b
      call UV1uma (W, QC, MH, LH, VMST_B3, VMSC_CxSwSb)
CCC_     + B3: B3 * Scale
      call UV0uwa (W, MH, LH, VMST_B3, QS (PMS_InvUG))
CCC_     + B2: SHIFT B3
      call AKBmex
     M    (W,    C,
     I     MH,   LH,  VMST_B2, VMST_B3,
     I     ipKW, iMA, KWO_Lca, KSW)
CCC_    * SumCxGU: B1 + B2
      call UV0naa (W, MH, LH, VMST_SumCxGU, VMST_B1, VMST_B2)
CCC_    * SumCxGU: SumCxGU * ny (for R:d)
      call UV1uma (W, QC, MH, LH, VMST_SumCxGU, VMSC_NdY)
CCC_    * nCGUN: nx:d B1
      call UV1nma (W, QC, MH, LH, VMST_nCGUN, VMST_B1, VMSC_NdX)
CCC_    * nCGUS: nx:d B2
      call UV1nma (W, QC, MH, LH, VMST_nCGUS, VMST_B2, VMSC_NdX)
CCC_    * SHIFT Cx:c G:c v:c [E]  to B1
CCC_     + B1: G[E]:c v[E]:c
      call UV3nma
     $     (W, X (1, 1, KXR), QC, MH,LH, VMST_B1, VMSX_VcE, VMSC_VcE_MG)
CCC_     + B1: B1 * Cxsw[E]:c
      call UV1uma (W, QC, MH, LH, VMST_B1, VMSC_CxSwEc)
CCC_     + B1: B1 * Scale
      call UV0uwa (W, MH, LH, VMST_B1, QS (PMS_InvVG))
CCC_     + B1: SHIFT(NOP)
CCC_    * SHIFT Cx:c G:c v:c [W]  to B2 use B3
CCC_     + B3: G[W]:c v[W]:c
      call UV3nma
     $     (W, X (1, 1, KXR), QC, MH,LH, VMST_B3, VMSX_VcW,VMSC_VcW_MG)
CCC_     + B3: B3 * Cxsw[W]:c
      call UV1uma (W, QC, MH, LH, VMST_B3, VMSC_CxSwWc)
CCC_     + B3: B3 * Scale
      call UV0uwa (W, MH, LH, VMST_B3, QS (PMS_InvVG))
CCC_     + B2: SHIFT B3
      call AKBmex
     M    (W,    C,
     I     MH,   LH,  VMST_B2, VMST_B3,
     I     ipKW, iMA, KWO_Lba, KSW)
CCC_    * SumCxGV: B1 + B2
      call UV0naa (W, MH, LH, VMST_SumCxGV, VMST_B1, VMST_B2)
CCC_    * SumCxGV: SumCxGV * ny nx ny:d (for R:d)
      call UV1uma (W, QC, MH, LH, VMST_SumCxGV, VMSC_NdYXY)
CCC_    * nCGVE: nx nx ny:d B1
      call UV1nma (W, QC, MH, LH, VMST_nCGVE, VMST_B1, VMSC_NdXXY)
CCC_    * nCGVW: nx nx ny:d B2
      call UV1nma (W, QC, MH, LH, VMST_nCGVW, VMST_B2, VMSC_NdXXY)
CCC_   . P[EW]:a common
CCC_    * LnCGU
CCC_     + LnCGU: T L b:d   by nCGUS, nCGUN(clone)
      call AKBwbx
     M    (W,    C,
     I     WW,
     I     MH,   LH,  VMST_LnCGU, VMST_nCGUS, VMST_nCGUN,
     I     ipKW, iMA, KWO_Lbd, KSW)
CCC_    * nGSumPa
CCC_     + nGSumPa: nx nx:b * GSumPa
      call UV1nma (W, QC, MH, LH, VMST_nGSumPa, VMST_GSumPa, VMSC_NbXX)
CCC_   = P[E]
CCC_    * v[E] to B4    use B1 B2 B3
CCC_     + B1: T L[0] c:d nx nx ny SHIFT C G V[E]
      call AKBwdx
     M    (W,
     I     WW,
     I     MH,   LH,  VMST_B1, VMST_nCGVE,
     I     ipKW, iMA, KWO_Lcd, KSW)
CCC_     + B4: T G[E] a:c B1   (work B2, B3)
      call AKBtbx
     M    (W,    C,
     I     QC,
     I     MH,   LH,
     I     VMST_B4, VMST_B1, VMST_B1, VMSC_PcEs, VMSC_PcEn,
     I     VMST_B2, VMST_B3,
     I     ipKW, iMA, KWO_Lac, KSW)
CCC_    * u[NS] L[0]
CCC_     + B2: T LH[0] a:b LnCGU
      call AKBudx
     M    (W,
     I     QC,
     I     MH,   LH,  VMST_B2, VMST_LnCGU, VMSC_PbHw,
     I     ipKW, iMA, KWO_Lab, KSW)
CCC_    * u[NS] D
CCC_     + B3: Dxsw[E]:b * Iuu
      call UV1nma (W, QC, MH, LH, VMST_B3, VMST_Iuu, VMSC_DxSwEb)
CCC_     + B1: T d/dx a:b
      call AKBwax
     M    (W,    C,
     I     WW,
     I     MH,   LH,  VMST_B1, VMST_B3,
     I     ipKW, iMA, KWO_GXab, KSW)
CCC_    * add u to B3
CCC_     + B3: B2 + B1
      call UV0naa (W, MH, LH, VMST_B3, VMST_B2, VMST_B1)
CCC_    * uv to B1
CCC_     + B1: B3 + B4
      call UV0naa (W, MH, LH, VMST_B1, VMST_B3, VMST_B4)
CCC_    * P[E] to B3
CCC_     + B3: scale F[E]:a - 2 scale I:a
      call UV2nga (W, QC, MH, LH, VMST_B3, VMSC_PaE_MF, VMSC_Da_MI,
     $             QS (PMS_InvPF), -2.0d0 * QS (PMS_InvPI))
CCC_     + B3: B3 * P[E]:a
      call UV1uma (W, X (1, 1, KXR), MH,LH, VMST_B3, VMSX_PaE)
CCC_    * P[EW] to B2
CCC_     + B2: T L[0] a:b nGSumPa
      call AKBwdx
     M    (W,
     I     WW,
     I     MH,   LH,  VMST_B2, VMST_nGSumPa,
     I     ipKW, iMA, KWO_Lab, KSW)
CCC_    * add P to B4
CCC_     + B4: B2 + B3
      call UV0naa (W, MH, LH, VMST_B4, VMST_B2, VMST_B3)
CCC_    * PQ to B2
CCC_     + B2: IGQE + B4
      call UV0naa (W, MH, LH, VMST_B2, VMST_IGQE, VMST_B4)
CCC_    * [done P[E]:a]
      call UV2naa (X (1, 1, KXL), W, MH, LH, VMSX_PaE, VMST_B1, VMST_B2)
CCC_   = P[W]
CCC_    * v[W] to B4    use B1 B2 B3
CCC_     + B1: T L[1] c:d nx nx ny SHIFT C G V[W]
      call AKBwex
     M    (W,    C,
     I     WW,
     I     MH,   LH,  VMST_B1, VMST_nCGVW,
     I     ipKW, iMA, KWO_Lcd, KSW)
CCC_     + B4: T G[W] a:c B1   (work B2, B3)
      call AKBtbx
     M    (W,    C,
     I     QC,
     I     MH,   LH,
     I     VMST_B4, VMST_B1, VMST_B1, VMSC_PcWs, VMSC_PcWn,
     I     VMST_B2, VMST_B3,
     I     ipKW, iMA, KWO_Lac, KSW)
CCC_    * u[NS] L[1]
CCC_     + B2: T LH[1] a:b LnCGU
      call AKBtex
     M    (W,    C,
     I     QC,
     I     MH,   LH,  VMST_B2, VMST_LnCGU, VMSC_PbHe,
     I     VMST_B3,
     I     ipKW, iMA, KWO_Lab, KSW)
CCC_    * u[NS] D
CCC_     + B3: Dxsw[W]:b * Iuu
      call UV1nma (W, QC, MH, LH, VMST_B3, VMST_Iuu, VMSC_DxSwWb)
CCC_     + B1: T d/dx a:b
      call AKBwax
     M    (W,    C,
     I     WW,
     I     MH,   LH,  VMST_B1, VMST_B3,
     I     ipKW, iMA, KWO_GXab, KSW)
CCC_    * add u to B3
CCC_     + B3: B2 + B1
      call UV0naa (W, MH, LH, VMST_B3, VMST_B2, VMST_B1)
CCC_    * uv to B1
CCC_     + B1: B3 + B4
      call UV0naa (W, MH, LH, VMST_B1, VMST_B3, VMST_B4)
CCC_    * P[W] to B3
CCC_     + B3: scale F[W]:a - 2 scale I:a
      call UV2nga (W, QC, MH, LH, VMST_B3, VMSC_PaW_MF, VMSC_Da_MI,
     $             QS (PMS_InvPF), -2.0d0 * QS (PMS_InvPI))
CCC_     + B3: B3 * P[W]:a
      call UV1uma (W, X (1, 1, KXR), MH,LH, VMST_B3, VMSX_PaW)
CCC_    * P[EW] to B2
CCC_     + B2: T L[1] a:b nGSumPa
      call AKBwex
     M    (W,    C,
     I     WW,
     I     MH,   LH,  VMST_B2, VMST_nGSumPa,
     I     ipKW, iMA, KWO_Lab, KSW)
CCC_    * add P to B4
CCC_     + B4: B2 + B3
      call UV0naa (W, MH, LH, VMST_B4, VMST_B2, VMST_B3)
CCC_    * PQ to B2
CCC_     + B2: IGQW + B4
      call UV0naa (W, MH, LH, VMST_B2, VMST_IGQW, VMST_B4)
CCC_    * [done P[W]:a]
      call UV2naa (X (1, 1, KXL), W, MH, LH, VMSX_PaW, VMST_B1, VMST_B2)
CCC_   . P[NS]:a common
CCC_    * LnCGV
CCC_     + LnCGV: T L c:d   by nCGVW, nCGVE(clone)
      call AKBwbx
     M    (W,    C,
     I     WW,
     I     MH,   LH,  VMST_LnCGV, VMST_nCGVW, VMST_nCGVE,
     I     ipKW, iMA, KWO_Lcd, KSW)
CCC_   = P[N]
CCC_    * u[N] to B4    use B1 B2 B3
CCC_     + B1: T L[0] b:d nx nx ny SHIFT C G U[N]
      call AKBwdx
     M    (W,
     I     WW,
     I     MH,   LH,  VMST_B1, VMST_nCGUN,
     I     ipKW, iMA, KWO_Lbd, KSW)
CCC_     + B4: T G[N] a:b B1   (work B2, B3)
      call AKBtbx
     M    (W,    C,
     I     QC,
     I     MH,   LH,
     I     VMST_B4, VMST_B1, VMST_B1, VMSC_PbNw, VMSC_PbNe,
     I     VMST_B2, VMST_B3,
     I     ipKW, iMA, KWO_Lab, KSW)
CCC_    * v[NS] L[0]
CCC_     + B2: T LV[0] a:c LnCGV
      call AKBudx
     M    (W,
     I     QC,
     I     MH,   LH,  VMST_B2, VMST_LnCGV, VMSC_PcVs,
     I     ipKW, iMA, KWO_Lac, KSW)
CCC_    * uv to B1
CCC_     + B1: B2 + B4
      call UV0naa (W, MH, LH, VMST_B1, VMST_B2, VMST_B4)
CCC_    * P[N]:a  to B2
CCC_     + B3: scale F - 2 scale I
      call UV2nga (W, QC, MH, LH, VMST_B3, VMSC_PaN_MF, VMSC_Da_MI,
     $             QS (PMS_InvPF), -2.0d0 * QS (PMS_InvPI))
CCC_     + B2: scale G
      call UV1nwa
     $     (W, QC, MH,LH, VMST_B2, VMSC_PaN_MG, QS (PMS_InvPG))
CCC_     + B2: -2 B2 + B3
      call UV0uea (W, MH, LH, VMST_B2, VMST_B3, -2.0d0)
CCC_     + B2: B2 * P[N]:a
      call UV1uma (W, X (1, 1, KXR), MH,LH, VMST_B2, VMSX_PaN)
CCC_    * [done P[N]:a]
      call UV2naa (X (1, 1, KXL), W, MH, LH, VMSX_PaN, VMST_B1, VMST_B2)
CCC_   = P[S]
CCC_    * u[S] to B4    use B1 B2 B3
CCC_     + B1: T L[1] b:d nx nx ny SHIFT C G U[S]
      call AKBwex
     M    (W,    C,
     I     WW,
     I     MH,   LH,  VMST_B1, VMST_nCGUS,
     I     ipKW, iMA, KWO_Lbd, KSW)
CCC_     + B4: T G[S] a:b B1   (work B2, B3)
      call AKBtbx
     M    (W,    C,
     I     QC,
     I     MH,   LH,
     I     VMST_B4, VMST_B1, VMST_B1, VMSC_PbSw, VMSC_PbSe,
     I     VMST_B2, VMST_B3,
     I     ipKW, iMA, KWO_Lab, KSW)
CCC_    * v[NS] L[1]
CCC_     + B2: T LV[1] a:c LnCGV
      call AKBtex
     M    (W,    C,
     I     QC,
     I     MH,   LH,  VMST_B2, VMST_LnCGV, VMSC_PcVn,
     I     VMST_B3,
     I     ipKW, iMA, KWO_Lac, KSW)
CCC_    * uv to B1
CCC_     + B1: B2 + B4
      call UV0naa (W, MH, LH, VMST_B1, VMST_B2, VMST_B4)
CCC_    * P[S]:a  to B2
CCC_     + B3: scale F - 2 scale I
      call UV2nga (W, QC, MH, LH, VMST_B3, VMSC_PaS_MF, VMSC_Da_MI,
     $             QS (PMS_InvPF), -2.0d0 * QS (PMS_InvPI))
CCC_     + B2: scale G
      call UV1nwa
     $     (W, QC, MH,LH, VMST_B2, VMSC_PaS_MG, QS (PMS_InvPG))
CCC_     + B2: -2 B2 + B3
      call UV0uea (W, MH, LH, VMST_B2, VMST_B3, -2.0d0)
CCC_     + B2: B2 * P[S]:a
      call UV1uma (W, X (1, 1, KXR), MH,LH, VMST_B2, VMSX_PaS)
CCC_    * [done P[S]:a]
      call UV2naa (X (1, 1, KXL), W, MH, LH, VMSX_PaS, VMST_B1, VMST_B2)
CCC_   . Q:a common
CCC_    * SHIFT Cy:c G:c v:c [E]  to B1
CCC_     + B1: G[E]:c v[E]:c
      call UV3nma
     $     (W, X (1, 1, KXR), QC, MH,LH, VMST_B1, VMSX_VcE, VMSC_VcE_MG)
CCC_     + B1: B1 * Cysw[E]:c
      call UV1uma (W, QC, MH, LH, VMST_B1, VMSC_CySwEc)
CCC_     + B1: B1 * Scale
      call UV0uwa (W, MH, LH, VMST_B1, QS (PMS_InvVG))
CCC_     + B1: SHIFT(NOP)
CCC_    * SHIFT Cy:c G:c v:c [W]  to B2 use B3
CCC_     + B3: G[W]:c v[W]:c
      call UV3nma
     $     (W, X (1, 1, KXR), QC, MH,LH, VMST_B3, VMSX_VcW,VMSC_VcW_MG)
CCC_     + B3: B3 * Cysw[W]:c
      call UV1uma (W, QC, MH, LH, VMST_B3, VMSC_CySwWc)
CCC_     + B3: B3 * Scale
      call UV0uwa (W, MH, LH, VMST_B3, QS (PMS_InvVG))
CCC_     + B2: SHIFT B3
      call AKBmex
     M    (W,    C,
     I     MH,   LH,  VMST_B2, VMST_B3,
     I     ipKW, iMA, KWO_Lba, KSW)
CCC_    * SumCyGV: B1 + B2
      call UV0naa (W, MH, LH, VMST_SumCyGV, VMST_B1, VMST_B2)
CCC_    * SumCyGV: SumCyGV * nx (for R:d)
      call UV1uma (W, QC, MH, LH, VMST_SumCyGV, VMSC_NdX)
CCC_    * nCGVE: ny:d B1
      call UV1nma (W, QC, MH, LH, VMST_nCGVE, VMST_B1, VMSC_NdY)
CCC_    * nCGVW: ny:d B2
      call UV1nma (W, QC, MH, LH, VMST_nCGVW, VMST_B2, VMSC_NdY)
CCC_    * SHIFT Cy:b G:b u:b [N]  to B1
CCC_     + B1: G[N]:b u[N]:b
      call UV3nma
     $     (W, X (1, 1, KXR), QC, MH,LH, VMST_B1, VMSX_UbN, VMSC_UbN_MG)
CCC_     + B1: B1 * Cysw[N]:b
      call UV1uma (W, QC, MH, LH, VMST_B1, VMSC_CySwNb)
CCC_     + B1: B1 * Scale
      call UV0uwa (W, MH, LH, VMST_B1, QS (PMS_InvUG))
CCC_     + B1: SHIFT(NOP)
CCC_    * SHIFT Cy:b G:b u:b [S]  to B2 use B3
CCC_     + B3: G[S]:b u[S]:b
      call UV3nma
     $     (W, X (1, 1, KXR), QC, MH,LH, VMST_B3, VMSX_UbS,VMSC_UbS_MG)
CCC_     + B3: B3 * Cysw[S]:b
      call UV1uma (W, QC, MH, LH, VMST_B3, VMSC_CySwSb)
CCC_     + B3: B3 * Scale
      call UV0uwa (W, MH, LH, VMST_B3, QS (PMS_InvUG))
CCC_     + B2: SHIFT B3
      call AKBmex
     M    (W,    C,
     I     MH,   LH,  VMST_B2, VMST_B3,
     I     ipKW, iMA, KWO_Lca, KSW)
CCC_    * SumCyGU: B1 + B2
      call UV0naa (W, MH, LH, VMST_SumCyGU, VMST_B1, VMST_B2)
CCC_    * SumCyGU: SumCyGU * nx nx ny:d (for R:d)
      call UV1uma (W, QC, MH, LH, VMST_SumCyGU, VMSC_NdXXY)
CCC_    * nCGUN: ny nx ny:d B1
      call UV1nma (W, QC, MH, LH, VMST_nCGUN, VMST_B1, VMSC_NdYXY)
CCC_    * nCGUS: ny nx ny:d B2
      call UV1nma (W, QC, MH, LH, VMST_nCGUS, VMST_B2, VMSC_NdYXY)
CCC_   . Q[NS]:a common
CCC_    * LnCGV
CCC_     + LnCGV: T L c:d   by nCGVW, nCGVE(clone)
      call AKBwbx
     M    (W,    C,
     I     WW,
     I     MH,   LH,  VMST_LnCGV, VMST_nCGVW, VMST_nCGVE,
     I     ipKW, iMA, KWO_Lcd, KSW)
CCC_    * nGSumQa
CCC_     + nGSumQa: ny ny:c * GSumQa
      call UV1nma (W, QC, MH, LH, VMST_nGSumQa, VMST_GSumQa, VMSC_NcYY)
CCC_   = Q[N]
CCC_    * u[N] to B4    use B1 B2 B3
CCC_     + B1: T L[0] b:d nx nx ny SHIFT C G U[N]
      call AKBwdx
     M    (W,
     I     WW,
     I     MH,   LH,  VMST_B1, VMST_nCGUN,
     I     ipKW, iMA, KWO_Lbd, KSW)
CCC_     + B4: T G[N] a:b B1   (work B2, B3)
      call AKBtbx
     M    (W,    C,
     I     QC,
     I     MH,   LH,
     I     VMST_B4, VMST_B1, VMST_B1, VMSC_QbNw, VMSC_QbNe,
     I     VMST_B2, VMST_B3,
     I     ipKW, iMA, KWO_Lab, KSW)
CCC_    * v[NS] L[0]
CCC_     + B2: T LV[0] a:c LnCGV
      call AKBudx
     M    (W,
     I     QC,
     I     MH,   LH,  VMST_B2, VMST_LnCGV, VMSC_QcVs,
     I     ipKW, iMA, KWO_Lac, KSW)
CCC_    * v[NS] D
CCC_     + B3: Dysw[N]:c * Ivv
      call UV1nma (W, QC, MH, LH, VMST_B3, VMST_Ivv, VMSC_DySwNc)
CCC_     + B1: T d/dy a:c
      call AKBwax
     M    (W,    C,
     I     WW,
     I     MH,   LH,  VMST_B1, VMST_B3,
     I     ipKW, iMA, KWO_GYac, KSW)
CCC_    * add v to B3
CCC_     + B3: B2 + B1
      call UV0naa (W, MH, LH, VMST_B3, VMST_B2, VMST_B1)
CCC_    * uv to B1
CCC_     + B1: B3 + B4
      call UV0naa (W, MH, LH, VMST_B1, VMST_B3, VMST_B4)
CCC_    * Q[N] to B3
CCC_     + B3: scale F[N]:a - 2 scale I:a
      call UV2nga (W, QC, MH, LH, VMST_B3, VMSC_QaN_MF, VMSC_Da_MI,
     $             QS (PMS_InvQF), -2.0d0 * QS (PMS_InvQI))
CCC_     + B3: B3 * Q[N]:a
      call UV1uma (W, X (1, 1, KXR), MH,LH, VMST_B3, VMSX_QaN)
CCC_    * Q[EW] to B2
CCC_     + B2: T L[0] a:c nGSumQa
      call AKBwdx
     M    (W,
     I     WW,
     I     MH,   LH,  VMST_B2, VMST_nGSumQa,
     I     ipKW, iMA, KWO_Lac, KSW)
CCC_    * add Q to B4
CCC_     + B4: B2 + B3
      call UV0naa (W, MH, LH, VMST_B4, VMST_B2, VMST_B3)
CCC_    * PQ to B2
CCC_     + B2: IGPN + B4
      call UV0naa (W, MH, LH, VMST_B2, VMST_IGPN, VMST_B4)
CCC_    * [done Q[N]:a]
      call UV2naa (X (1, 1, KXL), W, MH, LH, VMSX_QaN, VMST_B1, VMST_B2)
CCC_   = Q[S]
CCC_    * u[S] to B4    use B1 B2 B3
CCC_     + B1: T L[1] b:d nx nx ny SHIFT C G U[S]
      call AKBwex
     M    (W,    C,
     I     WW,
     I     MH,   LH,  VMST_B1, VMST_nCGUS,
     I     ipKW, iMA, KWO_Lbd, KSW)
CCC_     + B4: T G[S] a:b B1   (work B2, B3)
      call AKBtbx
     M    (W,    C,
     I     QC,
     I     MH,   LH,
     I     VMST_B4, VMST_B1, VMST_B1, VMSC_QbSw, VMSC_QbSe,
     I     VMST_B2, VMST_B3,
     I     ipKW, iMA, KWO_Lab, KSW)
CCC_    * v[NS] L[1]
CCC_     + B2: T LV[1] a:c LnCGV
      call AKBtex
     M    (W,    C,
     I     QC,
     I     MH,   LH,  VMST_B2, VMST_LnCGV, VMSC_QcVn,
     I     VMST_B3,
     I     ipKW, iMA, KWO_Lac, KSW)
CCC_    * v[NS] D
CCC_     + B3: Dysw[S]:c * Ivv
      call UV1nma (W, QC, MH, LH, VMST_B3, VMST_Ivv, VMSC_DySwSc)
CCC_     + B1: T d/dy a:c
      call AKBwax
     M    (W,    C,
     I     WW,
     I     MH,   LH,  VMST_B1, VMST_B3,
     I     ipKW, iMA, KWO_GYac, KSW)
CCC_    * add v to B3
CCC_     + B3: B2 + B1
      call UV0naa (W, MH, LH, VMST_B3, VMST_B2, VMST_B1)
CCC_    * uv to B1
CCC_     + B1: B3 + B4
      call UV0naa (W, MH, LH, VMST_B1, VMST_B3, VMST_B4)
CCC_    * Q[S] to B3
CCC_     + B3: scale F[S]:a - 2 scale I:a
      call UV2nga (W, QC, MH, LH, VMST_B3, VMSC_QaS_MF, VMSC_Da_MI,
     $             QS (PMS_InvQF), -2.0d0 * QS (PMS_InvQI))
CCC_     + B3: B3 * Q[S]:a
      call UV1uma (W, X (1, 1, KXR), MH,LH, VMST_B3, VMSX_QaS)
CCC_    * Q[EW] to B2
CCC_     + B2: T L[1] a:c nGSumQa
      call AKBwex
     M    (W,    C,
     I     WW,
     I     MH,   LH,  VMST_B2, VMST_nGSumQa,
     I     ipKW, iMA, KWO_Lac, KSW)
CCC_    * add Q to B4
CCC_     + B4: B2 + B3
      call UV0naa (W, MH, LH, VMST_B4, VMST_B2, VMST_B3)
CCC_    * PQ to B2
CCC_     + B2: IGPS + B4
      call UV0naa (W, MH, LH, VMST_B2, VMST_IGPS, VMST_B4)
CCC_    * [done Q[S]:a]
      call UV2naa (X (1, 1, KXL), W, MH, LH, VMSX_QaS, VMST_B1, VMST_B2)
CCC_   . Q[EW]:a common
CCC_    * LnCGU
CCC_     + LnCGU: T L b:d   by nCGUS, nCGUN(clone)
      call AKBwbx
     M    (W,    C,
     I     WW,
     I     MH,   LH,  VMST_LnCGU, VMST_nCGUS, VMST_nCGUN,
     I     ipKW, iMA, KWO_Lbd, KSW)
CCC_   = Q[E]
CCC_    * v[E] to B4    use B1 B2 B3
CCC_     + B1: T L[0] c:d nx nx ny SHIFT C G V[E]
      call AKBwdx
     M    (W,
     I     WW,
     I     MH,   LH,  VMST_B1, VMST_nCGVE,
     I     ipKW, iMA, KWO_Lcd, KSW)
CCC_     + B4: T G[E] a:c B1   (work B2, B3)
      call AKBtbx
     M    (W,    C,
     I     QC,
     I     MH,   LH,
     I     VMST_B4, VMST_B1, VMST_B1, VMSC_QcEs, VMSC_QcEn,
     I     VMST_B2, VMST_B3,
     I     ipKW, iMA, KWO_Lac, KSW)
CCC_    * u[NS] L[0]
CCC_     + B2: T LH[0] a:b LnCGU
      call AKBudx
     M    (W,
     I     QC,
     I     MH,   LH,  VMST_B2, VMST_LnCGU, VMSC_QbHw,
     I     ipKW, iMA, KWO_Lab, KSW)
CCC_    * uv to B1
CCC_     + B1: B2 + B4
      call UV0naa (W, MH, LH, VMST_B1, VMST_B2, VMST_B4)
CCC_    * Q[E]:a  to B2
CCC_     + B3: scale F - 2 scale I
      call UV2nga (W, QC, MH, LH, VMST_B3, VMSC_QaE_MF, VMSC_Da_MI,
     $             QS (PMS_InvQF), -2.0d0 * QS (PMS_InvQI))
CCC_     + B2: scale G
      call UV1nwa
     $     (W, QC, MH,LH, VMST_B2, VMSC_QaE_MG, QS (PMS_InvQG))
CCC_     + B2: -2 B2 + B3
      call UV0uea (W, MH, LH, VMST_B2, VMST_B3, -2.0d0)
CCC_     + B2: B2 * Q[E]:a
      call UV1uma (W, X (1, 1, KXR), MH,LH, VMST_B2, VMSX_QaE)
CCC_    * [done Q[E]:a]
      call UV2naa (X (1, 1, KXL), W, MH, LH, VMSX_QaE, VMST_B1, VMST_B2)
CCC_   = Q[W]
CCC_    * v[W] to B4    use B1 B2 B3
CCC_     + B1: T L[1] c:d nx nx ny SHIFT C G V[W]
      call AKBwex
     M    (W,    C,
     I     WW,
     I     MH,   LH,  VMST_B1, VMST_nCGVW,
     I     ipKW, iMA, KWO_Lcd, KSW)
CCC_     + B4: T G[W] a:c B1   (work B2, B3)
      call AKBtbx
     M    (W,    C,
     I     QC,
     I     MH,   LH,
     I     VMST_B4, VMST_B1, VMST_B1, VMSC_QcWs, VMSC_QcWn,
     I     VMST_B2, VMST_B3,
     I     ipKW, iMA, KWO_Lac, KSW)
CCC_    * u[NS] L[1]
CCC_     + B2: T LH[1] a:b LnCGU
      call AKBtex
     M    (W,    C,
     I     QC,
     I     MH,   LH,  VMST_B2, VMST_LnCGU, VMSC_QbHe,
     I     VMST_B3,
     I     ipKW, iMA, KWO_Lab, KSW)
CCC_    * uv to B1
CCC_     + B1: B2 + B4
      call UV0naa (W, MH, LH, VMST_B1, VMST_B2, VMST_B4)
CCC_    * Q[W]:a  to B2
CCC_     + B3: scale F - 2 scale I
      call UV2nga (W, QC, MH, LH, VMST_B3, VMSC_QaW_MF, VMSC_Da_MI,
     $             QS (PMS_InvQF), -2.0d0 * QS (PMS_InvQI))
CCC_     + B2: scale G
      call UV1nwa
     $     (W, QC, MH,LH, VMST_B2, VMSC_QaW_MG, QS (PMS_InvQG))
CCC_     + B2: -2 B2 + B3
      call UV0uea (W, MH, LH, VMST_B2, VMST_B3, -2.0d0)
CCC_     + B2: B2 * Q[W]:a
      call UV1uma (W, X (1, 1, KXR), MH,LH, VMST_B2, VMSX_QaW)
CCC_    * [done Q[W]:a]
      call UV2naa (X (1, 1, KXL), W, MH, LH, VMSX_QaW, VMST_B1, VMST_B2)
CCC_  - manual generation (rev 4)
CCC_   = R:d
CCC_    * u
CCC_     + B1: n SHIFT C G U
      call UV0naa (W, MH, LH, VMST_B1, VMST_SumCxGU, VMST_SumCyGU)
CCC_     + B2: T d/dy d:b Iuu
      call AKBwax
     M    (W,    C,
     I     WW,
     I     MH,   LH,  VMST_B2, VMST_Iuu,
     I     ipKW, iMA, KWO_GYdb, KSW)
CCC_     + B3: B1 + B2
      call UV0naa (W, MH, LH, VMST_B3, VMST_B1, VMST_B2)
CCC_    * v
CCC_     + B1: n SHIFT C G V
      call UV0naa (W, MH, LH, VMST_B1, VMST_SumCyGV, VMST_SumCxGV)
CCC_     + B2: T d/dx d:c Ivv
      call AKBwax
     M    (W,    C,
     I     WW,
     I     MH,   LH,  VMST_B2, VMST_Ivv,
     I     ipKW, iMA, KWO_GXdc, KSW)
CCC_     + B4: B1 + B2
      call UV0naa (W, MH, LH, VMST_B4, VMST_B1, VMST_B2)
CCC_    * uv to B1
      call UV0naa (W, MH, LH, VMST_B1, VMST_B3, VMST_B4)
CCC_    * P
CCC_     + B2: ny nx:b * GSumPa
      call UV1nma (W, QC, MH, LH, VMST_B2, VMST_GSumPa, VMSC_NbXY)
CCC_     + B3: T L d:b
      call AKBwax
     M    (W,    C,
     I     WW,
     I     MH,   LH,  VMST_B3, VMST_B2,
     I     ipKW, iMA, KWO_Ldb, KSW)
CCC_    * Q
CCC_     + B2: nx ny:c * GSumQa
      call UV1nma (W, QC, MH, LH, VMST_B2, VMST_GSumQa, VMSC_NcYX)
CCC_     + B4: T L d:c
      call AKBwax
     M    (W,    C,
     I     WW,
     I     MH,   LH,  VMST_B4, VMST_B2,
     I     ipKW, iMA, KWO_Ldc, KSW)
CCC_    * PQ to B2
CCC_     + B2: B3 + B4
      call UV0naa (W, MH, LH, VMST_B2, VMST_B3, VMST_B4)
CCC_    * R to B3
CCC_     + B3: scale F:d - scale I:d
      call UV2nga (W, QC, MH, LH, VMST_B3, VMSC_RdA_MF, VMSC_Rd_MI,
     $             QS (PMS_InvRF), -QS (PMS_InvRI))
CCC_     + B3: B3 * R:d
      call UV1uma (W, X (1, 1, KXR), MH,LH, VMST_B3, VMSX_RdA)
CCC_    * PQR to B4
CCC_     + B4: B2 + B3
      call UV0naa (W, MH, LH, VMST_B4, VMST_B2, VMST_B3)
CCC_    * [done R:d]
      call UV2naa (X (1, 1, KXL), W, MH, LH, VMSX_RdA, VMST_B1, VMST_B4)
CCC_  - return
      RETURN
      END
CCC_ & MSBsts  ## SSA/b/matrix solver suite (13 unknowns) transpose
      subroutine MSBsts
     M    (X,
     I     KXL,  KXR,
     W     C,    W,
     I     QS,   QC,   QV,   WW,
     I     iMA,  ipKW, ipCG, MH, LH, LXK, LCG)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH, KXR, KXL
      _INTENT(IN,   integer)  LXK, LCG
      _INTENT(INOUT,_REALSTD) X    (LH, LXK, *)
      _INTENT(OUT,  _REALSTD) C    (LH,  *)
      _INTENT(OUT,  _REALSTD) W    (LH,  *)
      _INTENT(IN,   _REALSTD) QS   (*)
      _INTENT(IN,   _REALSTD) QC   (LH,  *)
      _INTENT(IN,   _REALSTD) QV   (LH,  *)
      _INTENT(IN,   _REALSTD) WW   (LH,  *)
      _INTENT(IN,   integer)  iMA  (*),  ipKW (*)
      _INTENT(IN,   integer)  ipCG (LCG, *)
      integer jv, jh
      integer MO, LO, KT
      integer KSW
CCC_  - Body
      KSW = KWM_T
      KT  = 1
CCC_   . just copy
      do jv = 1, VMSX_MAX
         do jh = 1, MH
            X (jh, jv, KXL) = X (jh, jv, KXR)
         enddo
      enddo
CCC_   . return
      return
      END
CCC_* Design variation 3 or before (error)
#else /* MSBMOS_VARIATION != 4 */
#  error "Not implemented"
#endif /* MSBMOS_VARIATION != 4 */
CCC_* Common
CCC_ & MSBipN  ## SSA/b/vector inner product (normal)
      subroutine MSBipN
     O    (pi,
     W     GW,
     M     X,
     I     KXL, KXR1, KXR2,
     I     iMA, MH,   LH,   LXK, IROOT, IR, NR)
c
      implicit none
      _INTENT(OUT,  _REALSTD) pi
      _INTENT(IN,   integer)  MH, LH, LXK
      _INTENT(INOUT,_REALSTD) X (LH, LXK, *)
      _INTENT(IN,   integer)  NR
      _INTENT(OUT,  _REALSTD) GW (VMSX_MAX, NR)
      _INTENT(IN,   integer)  KXL, KXR1, KXR2
      _INTENT(IN,   integer)  iMA (*)
      _INTENT(IN,   integer)  IR, IROOT
c
      _REALSTD SS (VMSX_MAX), S
      integer  jh, jp
      integer  jv
      _REALSTD tu, tv, tp, tq
c
      do jv = 1, VMSX_MAX
         do jh = 1, MH
            X (jh, jv, KXL) = X (jh, jv, KXR1) * X (jh, jv, KXR2)
         enddo
      enddo
      do jv = 1, VMSX_MAX
         S = X (1, jv, KXL)
         do jh = 2, MH
            S = S + X (jh, jv, KXL)
         enddo
         SS (jv) = S
      enddo
      call DMWgts (GW, SS, VMSX_MAX, IROOT, iMA)
c
      pi = 0.0d0
      if (IR.eq.IROOT) then
         do jv = 1, VMSX_MAX
            S  = GW (jv, 1)
            do jp = 2, NR
               S = S + GW (jv, jp)
            enddo
            SS (jv)= S
         enddo
         tu = SS (VMSX_UbN) + SS (VMSX_UbS)
         tv = SS (VMSX_VcE) + SS (VMSX_VcW)
         tp =   (SS (VMSX_PaE) + SS (VMSX_PaW))
     $        + (SS (VMSX_PaN) + SS (VMSX_PaS))
         tq =   (SS (VMSX_QaE) + SS (VMSX_QaW))
     $        + (SS (VMSX_QaN) + SS (VMSX_QaS))
c$$$         tp =   (SS (VMSX_PaE) + SS (VMSX_PaW))
c$$$         tq =   (SS (VMSX_QaE) + SS (VMSX_QaW))
         pi = (tu + tv) + ((tp + tq) + SS (VMSX_RdA))
      endif
      call DMWbcs (pi, IROOT, iMA)
c
      RETURN
      END
CCC_ & MSBinm  ## SSA/b/vector infinity norm
      subroutine MSBinm
     O    (xnrm,
     I     X,    KXR, iMA, MH, LH, LXK)
      implicit none
      _INTENT(OUT,_REALSTD) xnrm
      _INTENT(IN, integer)  MH, LH, LXK, KXR
      _INTENT(IN, _REALSTD) X (LH, LXK, *)
      _INTENT(IN, integer)  iMA (*)
      integer jv, jh
#if DEBUG_INM
      integer mpos, mvar
#endif
c
#if DEBUG_INM
      mvar = 0
      mpos = 0
      do jv = 1, VMSX_MAX
         mpos = 0
         xnrm = 0.0d0
         do jh = 1, MH
            if (ABS (X (jh, jv, KXR)).gt.xnrm) then
               mpos = jh
               mvar = jv
               xnrm = ABS (X (jh, jv, KXR))
            endif
         enddo
         write (*, *) 'INM:', mvar, mpos, xnrm
      enddo
#endif
#if 1
      xnrm = 0.0d0
      do jv = 1, VMSX_MAX
c$$$      do jv = 1, VMSX_RdA
         do jh = 1, MH
            xnrm = MAX (ABS (X (jh, jv, KXR)), xnrm)
         enddo
      enddo
#else
      _REALSTD un, vn
c
      xnrm = 0.0d0
      un   = 0.0d0
      vn   = 0.0d0
      do jv = VMSX_UbN, VMSX_UbS
         do jh = 1, MH
            un = MAX (ABS (X (jh, jv, KXR)), un)
         enddo
      enddo
      do jv = VMSX_VcE, VMSX_VcW
         do jh = 1, MH
            vn = MAX (ABS (X (jh, jv, KXR)), vn)
         enddo
      enddo
      xnrm = max (un, vn)
#endif
      call DMWcma (xnrm, iMA)
      RETURN
      END
CCC_ & MSBina  ## SSA/b/vector infinity norm (return array)
      subroutine MSBina
     O    (xnrm,
     I     X,    KXR, iMA, MH, LH, LXK)
      implicit none
      _INTENT(OUT,_REALSTD) xnrm (*)
      _INTENT(IN, integer)  MH, LH, LXK, KXR
      _INTENT(IN, _REALSTD) X (LH, LXK, *)
      _INTENT(IN, integer)  iMA (*)
      integer jv, jh
      _REALSTD tnrm
c
      do jv = 1, VMSX_MAX
         tnrm = 0.0d0
         do jh = 1, MH
            tnrm = MAX (ABS (X (jh, jv, KXR)), tnrm)
         enddo
         call DMWcma (tnrm, iMA)
         xnrm (jv) = tnrm
      enddo
      RETURN
      END
CCC_* [MSS] matrix computation suites
CCC_ & MSSbcf  ## computation batch
      subroutine MSSbcf
     O    (iErr,
     M     VMSC, CW,   VMW,
     I     VMI,  VMC,  VMHB, VMSV, WW,  ipKW, iMA, MH, LH)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  MH,   LH
      _INTENT(INOUT,_REALSTD) VMSC (LH, *)
      _INTENT(OUT,  _REALSTD) VMW  (LH, *)
      _INTENT(OUT,  _REALSTD) CW   (LH, *)
      _INTENT(IN,   _REALSTD) VMI  (LH, *)
      _INTENT(IN,   _REALSTD) VMC  (LH, *)
      _INTENT(IN,   _REALSTD) VMHB (LH, *)
      _INTENT(IN,   _REALSTD) VMSV (LH, *)
      _INTENT(IN,   _REALSTD) WW   (LH, *)
      _INTENT(IN,   integer)  ipKW (*)
      _INTENT(IN,   integer)  iMA  (*)
CCC_  - Body
      iErr = 0
CCC_   . nx
      if (iErr.eq.0) then
         call MSSnns
     O       (iErr,
     M        VMSC, VMW, CW,
     I        VMC,  WW,  ipKW, iMA, MH, LH)
      endif
CCC_   . uv mask
      if (iErr.eq.0) then
         call MSSums
     O       (iErr,
     M        VMSC, VMW,  CW,
     I        VMC,  VMHB, VMSV, WW,  ipKW, iMA, MH, LH)
      endif
CCC_   . PQ mask
      if (iErr.eq.0) then
         call MSSdms
     O       (iErr,
     M        VMSC, VMW, CW,
     I        VMC,  WW,  ipKW, iMA, MH, LH)
      endif
CCC_   . R  mask/coeff
      if (iErr.eq.0) then
         call MSSrcs
     O       (iErr,
     M        VMSC, VMW, CW,
     I        VMC,  WW,  ipKW, iMA, MH, LH)
      endif
CCC_   . dx switch
      if (iErr.eq.0) then
         call MSSxss
     O       (iErr,
     M        VMSC, VMW,  CW,
     I        WW,   ipKW, iMA, MH, LH)
      endif
CCC_   . corner switch
      if (iErr.eq.0) then
         call MSScss
     O       (iErr,
     M        VMSC, VMW, CW,
     I        WW, ipKW,  iMA, MH, LH)
      endif
CCC_   . integral associate rate factor
      if (iErr.eq.0) then
         call MSSbhi
     O       (iErr,
     O        VMSC,
     I        VMI, MH, LH)
      endif
CCC_   . return
      RETURN
      END
CCC_ & MSSgca  ## adjust grid category bcd
      subroutine MSSgca
     O    (iErr,
     M     VMC,  W,    CW,
     I     WA,   ipKW, iMA, MH, LH)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  MH,   LH
      _INTENT(OUT,  _REALSTD) W    (LH, *)
      _INTENT(OUT,  _REALSTD) CW   (LH, *)
      _INTENT(INOUT,_REALSTD) VMC  (LH, *)
      _INTENT(IN,   _REALSTD) WA   (LH, *)
      _INTENT(IN,   integer)  ipKW (*)
      _INTENT(IN,   integer)  iMA  (*)
CCC_  - Body
      iErr = 0
      if (iErr.eq.0) then
         call MSUgcb
     $       (iErr,    VMC,     CW, W,
     $        VMC_IKa, VMC_IKb, KWO_FCab, WA, ipKW, iMA, MH, LH)
      endif
      if (iErr.eq.0) then
         call MSUgcb
     $       (iErr,    VMC,     CW, W,
     $        VMC_IKa, VMC_IKc, KWO_FCac, WA, ipKW, iMA, MH, LH)
      endif
CCC_   . TODO need check
      if (iErr.eq.0) then
         call MSUgcb
     $       (iErr,    VMC,     CW, W,
     $        VMC_IKb, VMC_IKd, KWO_FCac, WA, ipKW, iMA, MH, LH)
      endif
      if (iErr.eq.0) then
         call MSUgcb
     $       (iErr,    VMC,     CW, W,
     $        VMC_IKc, VMC_IKd, KWO_FCab, WA, ipKW, iMA, MH, LH)
      endif
      RETURN
      END
CCC_ & MSSnns  ## lateral boundary condition
      subroutine MSSnns
     O    (iErr,
     M     VMSC,  W,  CW,
     I     VMC,   WA, ipKW, iMA, MH, LH)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  MH,   LH
      _INTENT(OUT,  _REALSTD) W    (LH, *)
      _INTENT(OUT,  _REALSTD) CW   (LH, *)
      _INTENT(INOUT,_REALSTD) VMSC (LH, *)
      _INTENT(IN,   _REALSTD) VMC  (LH, *)
      _INTENT(IN,   _REALSTD) WA   (LH, *)
      _INTENT(IN,   integer)  ipKW (*)
      _INTENT(IN,   integer)  iMA  (*)
CCC_  - Body
      iErr = 0
      if (iErr.eq.0) then
         call MSUntl
     O       (iErr,
     O        VMSC,     CW,  W,
     I        VMC,
     I        VMSC_NbX, VMSC_NbY, VMC_IKa,  KWO_FCab,
     I        WA,       ipKW,     iMA,      MH, LH)
      endif
      if (iErr.eq.0) then
         call MSUntl
     O       (iErr,
     O        VMSC,     CW,  W,
     I        VMC,
     I        VMSC_NcY, VMSC_NcX, VMC_IKa,  KWO_FCac,
     I        WA,       ipKW,     iMA,      MH, LH)
      endif
      if (iErr.eq.0) then
         call UV0nma (VMSC, MH, LH, VMSC_NbXX, VMSC_NbX, VMSC_NbX)
         call UV0nma (VMSC, MH, LH, VMSC_NbYY, VMSC_NbY, VMSC_NbY)
         call UV0nma (VMSC, MH, LH, VMSC_NbXY, VMSC_NbX, VMSC_NbY)
         call UV0nma (VMSC, MH, LH, VMSC_NcXX, VMSC_NcX, VMSC_NcX)
         call UV0nma (VMSC, MH, LH, VMSC_NcYY, VMSC_NcY, VMSC_NcY)
         call UV0nma (VMSC, MH, LH, VMSC_NcXY, VMSC_NcX, VMSC_NcY)
CC no nx ny adjustment
c$$$      call UV0cpa (VC, MH, LH, KNTT, KNT)
c$$$      call UV0cpa (VC, MH, LH, KNLL, KNL)
c$$$      call UV0cpa (VC, MH, LH, KNTL, KNL)
      endif
      if (iErr.eq.0) then
         call MSUncr
     O       (iErr,
     O        VMSC,     CW,  W,
     I        VMC,
     I        VMSC_NdX, VMSC_NdY, VMC_IKa, KWO_FCab, KWO_FCac,
     I        WA,       ipKW,     iMA,     MH, LH)
      endif
      if (iErr.eq.0) then
         call UV0nma (VMSC, MH, LH, VMSC_NdXXY, VMSC_NdX, VMSC_NdX)
         call UV0uma (VMSC, MH, LH, VMSC_NdXXY, VMSC_NdY)
         call UV0nma (VMSC, MH, LH, VMSC_NdYYX, VMSC_NdY, VMSC_NdY)
         call UV0uma (VMSC, MH, LH, VMSC_NdYYX, VMSC_NdX)
      endif
      RETURN
      END
CCC_ & MSSums  ## u v mask
      subroutine MSSums
     O    (iErr,
     M     VMSC,  W,    CW,
     I     VMC,   VMHB, VMSV, WA, ipKW, iMA, MH, LH)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  MH,   LH
      _INTENT(OUT,  _REALSTD) W    (LH, *)
      _INTENT(OUT,  _REALSTD) CW   (LH, *)
      _INTENT(INOUT,_REALSTD) VMSC (LH, *)
      _INTENT(IN,   _REALSTD) VMC  (LH, *)
      _INTENT(IN,   _REALSTD) VMHB (LH, *)
      _INTENT(IN,   _REALSTD) VMSV (LH, *)
      _INTENT(IN,   _REALSTD) WA   (LH, *)
      _INTENT(IN,   integer)  ipKW (*)
      _INTENT(IN,   integer)  iMA  (*)
CCC_  - Body
      iErr = 0
      if (iErr.eq.0) then
         call MSUvms
     O       (iErr, VMSC, CW, W,
     I        VMC,  VMHB, VMSV,
     I        VMSC_Ub_MI,
     I        VMSC_UbN_MF, VMSC_UbN_MG, VMSC_UbS_MF,  VMSC_UbS_MG,
     I        VMSC_NdX,    VMSC_NdY,
     I        VMSV_UGb_MI,
     I        VMC_IKa,     VMC_IKb,     VMC_IKd,    VMHB_UMSKb,
     I        KWO_FCab,    KWO_FCac,    KWO_Xb,
     I        WA,          ipKW,        iMA,  MH,   LH)
      endif
      if (iErr.eq.0) then
         call MSUvms
     O       (iErr, VMSC, CW, W,
     I        VMC,  VMHB, VMSV,
     I        VMSC_Vc_MI,
     I        VMSC_VcE_MF, VMSC_VcE_MG, VMSC_VcW_MF,  VMSC_VcW_MG,
     I        VMSC_NdY,    VMSC_NdX,
     I        VMSV_VGc_MI,
     I        VMC_IKa,     VMC_IKc,     VMC_IKd,    VMHB_VMSKc,
     I        KWO_FCac,    KWO_FCab,    KWO_Yc,
     I        WA,          ipKW,        iMA,  MH,   LH)
      endif
      RETURN
      END
CCC_ & MSSdms  ## PQ mask
      subroutine MSSdms
     O    (iErr,
     M     VMSC,  W,  CW,
     I     VMC,   WA, ipKW, iMA, MH, LH)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  MH,   LH
      _INTENT(OUT,  _REALSTD) W    (LH, *)
      _INTENT(OUT,  _REALSTD) CW   (LH, *)
      _INTENT(INOUT,_REALSTD) VMSC (LH, *)
      _INTENT(IN,   _REALSTD) VMC  (LH, *)
      _INTENT(IN,   _REALSTD) WA   (LH, *)
      _INTENT(IN,   integer)  ipKW (*)
      _INTENT(IN,   integer)  iMA  (*)
CCC_  - Body
      iErr = 0
      if (iErr.eq.0) then
         call MSUpmi
     O       (iErr,
     M        VMSC, CW,    W,
     I        VMC,
     I        VMSC_Da_MI,
     I        VMSC_PaE_MF, VMSC_PaW_MF, VMSC_QaN_MF, VMSC_QaS_MF,
     I        VMC_IKa,     VMC_IKb,     VMC_IKc,
     I        KWO_FCab,    KWO_FCac,
     I        WA,          ipKW,        iMA,         MH,   LH)
      endif
      if (iErr.eq.0) then
         call MSUpmg
     O       (iErr,
     M        VMSC,  CW,    W,
     I        VMC,
     I        VMSC_PaE_MF, VMSC_PaE_MG, VMSC_PaW_MF, VMSC_PaW_MG,
     I        VMSC_QaE_MF, VMSC_QaE_MG, VMSC_QaW_MF, VMSC_QaW_MG,
     I        VMSC_NbX,    VMSC_NbY,
     I        VMC_IKa,     VMC_IKb,
     I        KWO_FCab,
     I        WA,          ipKW,        iMA,         MH,   LH)
      endif
      if (iErr.eq.0) then
         call MSUpmg
     O       (iErr,
     M        VMSC,  CW,    W,
     I        VMC,
     I        VMSC_QaN_MF, VMSC_QaN_MG, VMSC_QaS_MF, VMSC_QaS_MG,
     I        VMSC_PaN_MF, VMSC_PaN_MG, VMSC_PaS_MF, VMSC_PaS_MG,
     I        VMSC_NcY,    VMSC_NcX,
     I        VMC_IKa,     VMC_IKc,
     I        KWO_FCac,
     I        WA,          ipKW,        iMA,         MH,   LH)
      endif
      RETURN
      END
CCC_ & MSSrcs  ## R mask/coefficients
      subroutine MSSrcs
     O    (iErr,
     M     VMSC,  W,  CW,
     I     VMC,   WW, ipKW, iMA, MH, LH)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  MH,   LH
      _INTENT(OUT,  _REALSTD) W    (LH, *)
      _INTENT(OUT,  _REALSTD) CW   (LH, *)
      _INTENT(INOUT,_REALSTD) VMSC (LH, *)
      _INTENT(IN,   _REALSTD) VMC  (LH, *)
      _INTENT(IN,   _REALSTD) WW   (LH, *)
      _INTENT(IN,   integer)  ipKW (*)
      _INTENT(IN,   integer)  iMA  (*)
CCC_  - Body
      iErr = 0
      if (iErr.eq.0) then
         call MSUrms
     O       (iErr,
     M        VMSC, CW,   W,
     I        VMC,
     I        VMSC_Rd_MI,  VMSC_RdA_MF,
     I        VMSC_Ub_MI,
     I        VMSC_UbN_MF, VMSC_UbN_MG, VMSC_UbS_MF,  VMSC_UbS_MG,
     I        VMSC_Vc_MI,
     I        VMSC_VcE_MF, VMSC_VcE_MG, VMSC_VcW_MF,  VMSC_VcW_MG,
     I        VMSC_NdX,    VMSC_NdY,
     I        VMC_IKb,     VMC_IKc,
     I        KWO_FCab,    KWO_FCac,
     I        WW,          ipKW,        iMA,          MH, LH)
      endif
      if (iErr.eq.0) then
         call MSUrcf
     O       (iErr,
     O        VMSC, CW,   W,
     I        VMC,
     I        VMSC_PbHe, VMSC_PbHw,
     I        VMSC_PbNe, VMSC_PbNw,  VMSC_PbSe,   VMSC_PbSw,
     I        VMC_IKa,
     I        KWO_FCab,  KWO_Lab,    KWO_FCac,
     I        WW,        ipKW, iMA,  MH,   LH)
      endif
      if (iErr.eq.0) then
         call MSUrcf
     O       (iErr,
     O        VMSC, CW,   W,
     I        VMC,
     I        VMSC_QcVn, VMSC_QcVs,
     I        VMSC_QcEn, VMSC_QcEs,  VMSC_QcWn,   VMSC_QcWs,
     I        VMC_IKa,
     I        KWO_FCac,  KWO_Lac,    KWO_FCab,
     I        WW,        ipKW, iMA,  MH,   LH)
      endif
      RETURN
      END
CCC_ & MSSxss  ## dx switch
      subroutine MSSxss
     O    (iErr,
     M     VMSC,  W,    CW,
     I     WA,    ipKW, iMA, MH, LH)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  MH,   LH
      _INTENT(OUT,  _REALSTD) W    (LH, *)
      _INTENT(OUT,  _REALSTD) CW   (LH, *)
      _INTENT(INOUT,_REALSTD) VMSC (LH, *)
      _INTENT(IN,   _REALSTD) WA   (LH, *)
      _INTENT(IN,   integer)  ipKW (*)
      _INTENT(IN,   integer)  iMA  (*)
CCC_  - Body
      iErr = 0
      if (iErr.eq.0) then
         call MSUdsl
     O       (iErr,
     O        VMSC, CW,    W,
     I        VMSC_DxSwEb, VMSC_DxSwWb, VMSC_PaE_MG, VMSC_PaW_MG,
     I        KWO_FCab,
     I        WA,   ipKW, iMA,  MH,   LH)
      endif
      if (iErr.eq.0) then
         call MSUdsl
     O       (iErr,
     O        VMSC, CW,    W,
     I        VMSC_DySwNc, VMSC_DySwSc, VMSC_QaN_MG, VMSC_QaS_MG,
     I        KWO_FCac,
     I        WA,   ipKW, iMA,  MH,   LH)
      endif
      if (iErr.eq.0) then
         call MSUdsl
     O       (iErr,
     O        VMSC, CW,    W,
     I        VMSC_DxSwEd, VMSC_DxSwWd, VMSC_VcE_MG, VMSC_VcW_MG,
     I        KWO_FCab,
     I        WA,   ipKW, iMA,  MH,   LH)
      endif
      if (iErr.eq.0) then
         call MSUdsl
     O       (iErr,
     O        VMSC, CW,    W,
     I        VMSC_DySwNd, VMSC_DySwSd, VMSC_UbN_MG, VMSC_UbS_MG,
     I        KWO_FCac,
     I        WA,   ipKW, iMA,  MH,   LH)
      endif
      RETURN
      END
CCC_ & MSScss  ## corner switch
      subroutine MSScss
     O    (iErr,
     M     VMSC,  W,    CW,
     I     WA,    ipKW, iMA, MH, LH)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  MH,   LH
      _INTENT(OUT,  _REALSTD) W    (LH, *)
      _INTENT(OUT,  _REALSTD) CW   (LH, *)
      _INTENT(INOUT,_REALSTD) VMSC (LH, *)
      _INTENT(IN,   _REALSTD) WA   (LH, *)
      _INTENT(IN,   integer)  ipKW (*)
      _INTENT(IN,   integer)  iMA  (*)
CCC_  - Body
      iErr = 0
      if (iErr.eq.0) then
         call MSUcsw (iErr, VMSC, VMSC_CySwNb,  VMSC_CxSwNb, MH, LH)
      endif
      if (iErr.eq.0) then
         call MSUcsw (iErr, VMSC, VMSC_CySwSb,  VMSC_CxSwSb, MH, LH)
      endif
      if (iErr.eq.0) then
         call MSUcsw (iErr, VMSC, VMSC_CxSwEc,  VMSC_CySwEc, MH, LH)
      endif
      if (iErr.eq.0) then
         call MSUcsw (iErr, VMSC, VMSC_CxSwWc,  VMSC_CySwWc, MH, LH)
      endif
      RETURN
      END
CCC_ & MSSxcr  ## solution correction
      subroutine MSSxcr
     O    (iErr,
     M     VMSX,
     I     VMC,  VMSC,
     I     KXX,  MH, LH, LXK)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  MH,   LH, LXK
      _INTENT(INOUT,_REALSTD) VMSX (LH, LXK, *)
      _INTENT(IN,   _REALSTD) VMC  (LH, *)
      _INTENT(IN,   _REALSTD) VMSC (LH, *)
      _INTENT(IN,   integer)  KXX
CCC_  - Body
      iErr = 0
CCC_   . D
      if (iErr.eq.0) then
         call MSUcrd
     $       (VMSX (1,1,KXX),
     $        VMC, VMSC, VMSX_PaE, VMC_IKa, VMSC_PaE_MF, MH, LH)
         call MSUcrd
     $       (VMSX (1,1,KXX),
     $        VMC, VMSC, VMSX_PaW, VMC_IKa, VMSC_PaW_MF, MH, LH)
         call MSUcrd
     $       (VMSX (1,1,KXX),
     $        VMC, VMSC, VMSX_QaN, VMC_IKa, VMSC_QaN_MF, MH, LH)
         call MSUcrd
     $       (VMSX (1,1,KXX),
     $        VMC, VMSC, VMSX_QaS, VMC_IKa, VMSC_QaS_MF, MH, LH)
         call MSUcrd
     $       (VMSX (1,1,KXX),
     $        VMC, VMSC, VMSX_PaN, VMC_IKa, VMSC_PaN_MF, MH, LH)
         call MSUcrd
     $       (VMSX (1,1,KXX),
     $        VMC, VMSC, VMSX_PaS, VMC_IKa, VMSC_PaS_MF, MH, LH)
         call MSUcrd
     $       (VMSX (1,1,KXX),
     $        VMC, VMSC, VMSX_QaE, VMC_IKa, VMSC_QaE_MF, MH, LH)
         call MSUcrd
     $       (VMSX (1,1,KXX),
     $        VMC, VMSC, VMSX_QaW, VMC_IKa, VMSC_QaW_MF, MH, LH)
      endif
CCC_   . uv
      if (iErr.eq.0) then
         call MSUcrv
     $       (VMSX (1,1,KXX),
     $        VMC, VMSC, VMSX_UbN, VMC_IKb, VMSC_UbN_MF, MH, LH)
         call MSUcrv
     $       (VMSX (1,1,KXX),
     $        VMC, VMSC, VMSX_UbS, VMC_IKb, VMSC_UbS_MF, MH, LH)
         call MSUcrv
     $       (VMSX (1,1,KXX),
     $        VMC, VMSC, VMSX_VcE, VMC_IKc, VMSC_VcE_MF, MH, LH)
         call MSUcrv
     $       (VMSX (1,1,KXX),
     $        VMC, VMSC, VMSX_VcW, VMC_IKc, VMSC_VcW_MF, MH, LH)
      endif
      RETURN
      END
CCC_ & MSSxms  ## solution mask
      subroutine MSSxms
     O    (iErr,
     M     VMSX,
     I     VMSC,
     I     KXX,  MH, LH, LXK)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  MH,   LH, LXK
      _INTENT(INOUT,_REALSTD) VMSX (LH, LXK, *)
      _INTENT(IN,   _REALSTD) VMSC (LH, *)
      _INTENT(IN,   integer)  KXX
CCC_  - Body
      iErr = 0
CCC_   . uv
      if (iErr.eq.0) then
         call MSUxvf
     $       (VMSX (1,1,KXX),
     $        VMSC, VMSX_UbN, VMSC_UbN_MF, MH, LH)
         call MSUxvf
     $       (VMSX (1,1,KXX),
     $        VMSC, VMSX_UbS, VMSC_UbS_MF, MH, LH)
         call MSUxvf
     $       (VMSX (1,1,KXX),
     $        VMSC, VMSX_VcE, VMSC_VcE_MF, MH, LH)
         call MSUxvf
     $       (VMSX (1,1,KXX),
     $        VMSC, VMSX_VcW, VMSC_VcW_MF, MH, LH)
      endif
      RETURN
      END
CCC_ & MSSbhi  ## integral associate rate factor
      subroutine  MSSbhi
     O    (iErr,
     O     VMSC,
     I     VMI, MH, LH)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  MH,   LH
      _INTENT(OUT,  _REALSTD) VMSC (LH, *)
      _INTENT(IN,   _REALSTD) VMI  (LH, *)
      integer jp
CCC_  - Body
      iErr = 0
      do jp = 1, MH
         VMSC (jp, VMSC_BVIa) = VMI (jp, VMI_Ha) * VMI (jp, VMI_daBAa)
         VMSC (jp, VMSC_BVId) = VMI (jp, VMI_Hd) * VMI (jp, VMI_daBAd)
      enddo
      RETURN
      END
CCC_* [MSU] utilities
CCC_ & MSUgcb  ## grid category adjustment bc
      subroutine MSUgcb
     O    (iErr,
     M     VC,   CW,   W,
     I     KIKa, KIKb, KFC,
     I     WW,   ipKW, iMA,  MH,   LH)
CCC_  - Declaration
      implicit none
CCC_   . Arguments
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   MH, LH
      _INTENT(INOUT,_REALSTD)  VC   (LH, *)
      _INTENT(OUT,  _REALSTD)  W    (LH, *)
      _INTENT(OUT,  _REALSTD)  CW   (*)
      _INTENT(IN,   integer)   KIKa, KIKb
      _INTENT(IN,   integer)   KFC
      _INTENT(IN,   integer)   iMA (*)
      _INTENT(IN,   integer)   ipKW (IPKW_FULL_DECL)
      _INTENT(IN,   _REALSTD)  WW (LH, *)
CCC_   . Interior
      integer  jp
      integer  kaP
CCC_  - Body
      iErr = 0
      kaP   = 1
CC     c P
CC     M b P
CC       M
      call AKBwez
     O    (W  (1, kaP),   CW,
     I     VC (1, KIKa),  WW,
     I     MH,   LH,  ipKW, iMA, KFC, KWM_M)
CCC_   . derivation
      do jp = 1, MH
CC        force ocean to shelf if either neighbor is shelf
         if (VC (jp, KIKb) .eq. _dOC) then
            if ((VC (jp, KIKa) .eq. _dSH)
     $           .or. (W  (jp, kaP) .eq. _dSH)) then
               VC (jp, KIKb) = _dSH
            endif
         endif
CC        force ocean if both neighbors are ocean
         if ((VC (jp, KIKa) .eq. _dOC)
     $        .and. (W  (jp, kaP) .eq. _dOC)) then
            VC (jp, KIKb) = _dOC
         endif
      enddo
c
      RETURN
      END
CCC_ & MSUmgr  ## gradient adjustment at shelf ends (both)
      subroutine MSUmgr
     O    (iErr,
     M     VC,   CW,   W,
     I     VI,
     I     KGRb, KIKb, KIKa, KISb, KFCa, KFCb, KDX,
     I     KSWF, KSWE,
     I     WW,   ipKW, iMA,  MH,   LH)
CCC_  - Declaration
      implicit none
CCC_   . Arguments
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   MH, LH
      _INTENT(INOUT,_REALSTD)  VC   (LH, *)
      _INTENT(OUT,  _REALSTD)  W    (LH, *)
      _INTENT(OUT,  _REALSTD)  CW   (*)
      _INTENT(IN,   _REALSTD)  VI   (LH, *)
      _INTENT(IN,   integer)   KGRb, KIKb, KIKa
      _INTENT(IN,   integer)   KISb
      _INTENT(IN,   integer)   KFCa, KFCb, KDX
      _INTENT(IN,   integer)   KSWF, KSWE
      _INTENT(IN,   integer)   iMA (*)
      _INTENT(IN,   integer)   ipKW (IPKW_FULL_DECL)
      _INTENT(IN,   _REALSTD)  WW (LH, *)
CCC_   . Interior
      integer  jp
      integer  kaP, kaM, kaD, kaPD, kbM
      _REALSTD WG
CCC_  - Body
      iErr = 0
      kaP  = 1
      kaD  = 2
      kaPD = 3
      kbM  = 1
      kaM  = 4
CC     c P
CC     M b P
CC       M
CCC_   . ice-shelf front
      if (KSWF.eq.SW_DSFR_ZERO) then
         call AKBwez
     O       (W  (1, kaP),   CW,
     I        VC (1, KIKa),  WW,
     I        MH,   LH,  ipKW, iMA, KFCa, KWM_M)
         do jp = 1, MH
CC          force zero gradient at the front
            if (VC (jp, KIKb) .eq. _dSH) then
               if ((VC (jp, KIKa) .eq. _dOC)
     $              .or. (W  (jp, kaP) .eq. _dOC)) then
                  VC (jp, KGRb) = 0.0d0
               endif
            endif
         enddo
      endif
CCC_   . ice shelf end
      if (KSWE.eq.SW_DSSE_DOWN_A) then
         call AKBwez
     O       (W  (1, kbM),   CW,
     I        VC (1, KIKb),  WW,
     I        MH,   LH,  ipKW, iMA, KFCb, KWM_M)
c        front check
         do jp = 1, MH
            if (VC (jp, KIKa).eq. _dGR
     $           .and. VC (jp, KIKb).eq. _dSH
     $           .and. W  (jp, kbM) .eq. _dSH) then
               W (jp, kaM) = _dGI
            else
               W (jp, kaM) = VC (jp, KIKa)
            endif
         enddo
         call AKBwex
     O       (W,   CW,
     I        WW,
     I        MH,  LH,  kaP, kaM, ipKW, iMA, KFCa, KWM_M)
c
         call AKBwaz
     O       (W  (1, kaD),   CW,
     I        VI (1, KISb),  WW,
     I        MH,   LH,  ipKW, iMA, KDX, KWM_M)
         call AKBwex
     O       (W,   CW,
     I        WW,
     I        MH,  LH,  kaPD, kaD, ipKW, iMA, KFCa, KWM_M)
c
         do jp = 1, MH
            if (VC (jp, KIKb) .eq. _dSH) then
               if (W (jp, kaM) .eq. _dGR) then
                  if (W (jp, kaP).eq. _dSH
     $                 .or. W (jp, kaP).eq. _dOC) then
                     VC (jp, KGRb) = W (jp, kaPD)
                  endif
               else if (W (jp, kaP).eq. _dGR) then
                  if (W (jp, kaM).eq. _dSH
     $                 .or. W (jp, kaM).eq. _dOC) then
                     VC (jp, KGRb) = W (jp, kaD)
                  endif
               endif
            endif
         enddo
      endif
c
      RETURN
      END
CCC_ & MSUfgr  ## gradient adjustment at calving front
      subroutine MSUfgr
     O    (iErr,
     M     VC,   CW,   W,
     I     KGRb, KIKb, KIKa, KFC,
     I     WW,   ipKW, iMA,  MH,   LH)
CCC_  - Declaration
      implicit none
CCC_   . Arguments
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   MH, LH
      _INTENT(INOUT,_REALSTD)  VC   (LH, *)
      _INTENT(OUT,  _REALSTD)  W    (LH, *)
      _INTENT(OUT,  _REALSTD)  CW   (*)
      _INTENT(IN,   integer)   KGRb, KIKb, KIKa
      _INTENT(IN,   integer)   KFC
      _INTENT(IN,   integer)   iMA (*)
      _INTENT(IN,   integer)   ipKW (IPKW_FULL_DECL)
      _INTENT(IN,   _REALSTD)  WW (LH, *)
CCC_   . Interior
      integer  jp
      integer  kaP
      _REALSTD WG
CCC_  - Body
      iErr = 0
      kaP   = 1
CC     c P
CC     M b P
CC       M
      call AKBwez
     O    (W  (1, kaP),   CW,
     I     VC (1, KIKa),  WW,
     I     MH,   LH,  ipKW, iMA, KFC, KWM_M)
CCC_   . derivation
      do jp = 1, MH
CC        force ocean to shelf if either neighbor is shelf
         if (VC (jp, KIKb) .eq. _dSH) then
            if ((VC (jp, KIKa) .eq. _dOC)
     $           .or. (W  (jp, kaP) .eq. _dOC)) then
               VC (jp, KGRb) = 0.0d0
            endif
         endif
      enddo
c
      RETURN
      END
CCC_ & MSUbst  ## right hand vector suite
      subroutine MSUbst
     O    (iErr,
     M     X,
     W     W,    CW,
     I     PMS,  VMI,  VMC,  VMSC, VMID, KBB,
     I     WA,   ipKW, iMA,
     I     MH,   LH,   LXK)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  MH,   LH,  LXK
      _INTENT(OUT,  _REALSTD) W    (LH, *)
      _INTENT(OUT,  _REALSTD) CW   (LH, *)
      _INTENT(INOUT,_REALSTD) X    (LH, LXK, *)
      _INTENT(IN,   _REALSTD) PMS  (*)
      _INTENT(IN,   _REALSTD) VMI  (LH, *)
      _INTENT(IN,   _REALSTD) VMID (LH, *)
      _INTENT(IN,   _REALSTD) VMC  (LH, *)
      _INTENT(IN,   _REALSTD) VMSC (LH, *)
      _INTENT(IN,   _REALSTD) WA   (LH, *)
      _INTENT(IN,   integer)  KBB
      _INTENT(IN,   integer)  ipKW (*)
      _INTENT(IN,   integer)  iMA  (*)
CCC_  - Body
      iErr = 0
CCC_   . u:b    (2)
      call MSUbpv
     O    (iErr,
     M     X,          W,          CW,
     I     KBB,
     I     PMS,        VMID, VMI,  VMC,  VMSC,
     I     VMSX_UbN,   VMSX_UbS,
     I     PMS_InvUF,  PMS_InvUI,  PMS_InvUG,
     I     VMID_UIavb, VMID_UBb,   VMI_Hb,   VMI_Hd,  VMC_DSXb,
     I     VMSC_NdXYY,
     I     VMSC_Ub_MI,
     I     VMSC_UbN_MF, VMSC_UbN_MG, VMSC_UbS_MF, VMSC_UbS_MG,
     I     KWO_FCac,    ipKW,        iMA,
     I     WA, MH,  LH, LXK)
CCC_   . v:c    (2)
      call MSUbpv
     O    (iErr,
     M     X,          W,          CW,
     I     KBB,
     I     PMS,        VMID, VMI,  VMC,  VMSC,
     I     VMSX_VcE,   VMSX_VcW,
     I     PMS_InvVF,  PMS_InvVI,  PMS_InvVG,
     I     VMID_VIavc, VMID_VBc,   VMI_Hc,   VMI_Hd,  VMC_DSYc,
     I     VMSC_NdYXX,
     I     VMSC_Vc_MI,
     I     VMSC_VcE_MF, VMSC_VcE_MG, VMSC_VcW_MF, VMSC_VcW_MG,
     I     KWO_FCac,    ipKW,        iMA,
     I     WA, MH,  LH, LXK)
CCC_   . Pa:EW  (2)
      call MSUbpd
     O    (iErr,
     M     X,         W,         CW,
     I     KBB,
     I     PMS,       VMI,       VMSC,
     I     VMSX_PaE,  VMSX_PaW,
     I     PMS_InvPF, PMS_InvPI, PMS_InvPG,
     I     VMI_Hb,
     I     VMSC_NbXX,
     I     VMSC_Da_MI,
     I     VMSC_PaE_MF, VMSC_PaE_MG, VMSC_PaW_MF, VMSC_PaW_MG,
     I     KWO_FCab,    ipKW,        iMA,
     I     WA, MH,  LH, LXK)
CCC_   . Qa:NS  (2)
      call MSUbpd
     O    (iErr,
     M     X,         W,         CW,
     I     KBB,
     I     PMS,       VMI,       VMSC,
     I     VMSX_QaN,  VMSX_QaS,
     I     PMS_InvQF, PMS_InvQI, PMS_InvQG,
     I     VMI_Hc,
     I     VMSC_NcYY,
     I     VMSC_Da_MI,
     I     VMSC_QaN_MF, VMSC_QaN_MG, VMSC_QaS_MF, VMSC_QaS_MG,
     I     KWO_FCac,    ipKW,        iMA,
     I     WA, MH,  LH, LXK)
CCC_   . Pa:NS  (2)
      call MSUbpd
     O    (iErr,
     M     X,         W,         CW,
     I     KBB,
     I     PMS,       VMI,       VMSC,
     I     VMSX_PaN,  VMSX_PaS,
     I     PMS_InvPF, PMS_InvPI, PMS_InvPG,
     I     -1,
     I     -1,
     I     VMSC_Da_MI,
     I     VMSC_PaN_MF, VMSC_PaN_MG, VMSC_PaS_MF, VMSC_PaS_MG,
     I     KWO_FCac,    ipKW,        iMA,
     I     WA, MH,  LH, LXK)
CCC_   . Qa:EW  (2)
      call MSUbpd
     O    (iErr,
     M     X,         W,         CW,
     I     KBB,
     I     PMS,       VMI,       VMSC,
     I     VMSX_QaE,  VMSX_QaW,
     I     PMS_InvQF, PMS_InvQI, PMS_InvQG,
     I     -1,
     I     -1,
     I     VMSC_Da_MI,
     I     VMSC_QaE_MF, VMSC_QaE_MG, VMSC_QaW_MF, VMSC_QaW_MG,
     I     KWO_FCab,    ipKW,        iMA,
     I     WA, MH,  LH, LXK)
CCC_   . R:d    (1)
      call UV0sta (X (1,1,KBB), MH, LH, VMSX_RdA, 0.0d0)
c
      RETURN
      END
CCC_ & MSUbpv  ## right-hand vector (v)
      subroutine MSUbpv
     O    (iErr,
     M     VMSX,  W,     CW,
     I     KBB,
     I     PMS,   VMID,  VMI,    VMC,    VMSC,
     I     KXp,   KXm,
     I     KSf,   KSi,   KSg,
     I     KIVi,  KIVBi, KIH,    KIHd,   KIDSX,
     I     KCN,   KCMi,  KCMfp,  KCMgp,  KCMfm, KCMgm,
     I     KOfc,  ipKW,  iMA,
     I     WA,    MH,    LH,     LXK)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  MH,   LH, LXK
      _INTENT(OUT,  _REALSTD) W    (LH, *)
      _INTENT(OUT,  _REALSTD) CW   (LH, *)
      _INTENT(INOUT,_REALSTD) VMSX (LH, LXK, *)
      _INTENT(IN,   _REALSTD) PMS  (*)
      _INTENT(IN,   _REALSTD) VMID (LH, *)
      _INTENT(IN,   _REALSTD) VMI  (LH, *)
      _INTENT(IN,   _REALSTD) VMC  (LH, *)
      _INTENT(IN,   _REALSTD) VMSC (LH, *)
      _INTENT(IN,   _REALSTD) WA (LH, *)
      _INTENT(IN,   integer)  KBB
      _INTENT(IN,   integer)  KXp,  KXm
      _INTENT(IN,   integer)  KSf,  KSi,   KSg
      _INTENT(IN,   integer)  KIVi, KIVBi
      _INTENT(IN,   integer)  KIH,  KIDSX, KIHd
      _INTENT(IN,   integer)  KCN
      _INTENT(IN,   integer)  KCMi, KCMfp, KCMgp, KCMfm, KCMgm
      _INTENT(IN,   integer)  KOfc
      _INTENT(IN,   integer)  ipKW (*)
      _INTENT(IN,   integer)  iMA  (*)
      integer kw1, kw2, kw3, kw4, kw5
      integer jh
      _REALSTD DI, DW,  GR,  DSXLIM
c$$$      integer jp, jv
CCC_  - Body
      iErr = 0
c
      kw1  = 1
      kw2  = 2
      kw3  = 3
      kw4  = 4
      kw5  = 5
c
      DI = PMS (PMS_DENS)
      DW = PMS (PMS_DENSW)
      GR = PMS (PMS_GRAV)
      DSXLIM = PMS (PMS_DSXLIM)
CCC_   . common
CCC_    * kw1: dens g H dh/dx mask
      call UV1nwa (W, VMI,        MH, LH, kw1, KIH,  (DI * GR))
      if (DSXLIM.gt.0.0d0) then
         do jh = 1, MH
            W(jh, kw1) = W(jh, kw1)
     $           * MAX(-DSXLIM, MIN(+DSXLIM, VMC(jh,KIDSX)))
         enddo
      else
         call UV1uma (W, VMC,        MH, LH, kw1, KIDSX)
      endif
      call UV1uma (W, VMSC,       MH, LH, kw1, KCMi)
      call UV0uwa (W,             MH, LH, kw1, PMS (KSi))
CCC_    * kw5: ub+ui
      call UV2naa (W, VMID, MH, LH, kw5, KIVi, KIVBi)
CCC_    * kw3: H H rdens / 2
c$$$      call UV3nma (W, VMSI, VMSC, MH, LH, kw3, KIHSI, KCN)
      call MSFhsi (W, VMI, kw3,  KIHd, DI, DW, GR, MH, LH)
      call UV1uma (W, VMSC, MH, LH, kw3, KCN)
c
      call AKBwex
     M    (W,   CW,
     I     WA,
     I     MH,  LH,  kw4, kw3, ipKW, iMA, KOfc, KWM_T)
CCC_   . plus
      call UV1uma (W, VMSC,       MH, LH, kw3, KCMgp)
      call UV0uwa (W,             MH, LH, kw3, PMS (KSg))
c
c$$$      call UV3nma (W, VMID, VMSC, MH, LH, kw2, KIVi,  KCMfp)
      call UV1nma (W, VMSC, MH, LH, kw2, kw5, KCMfp)
      call UV0uwa (W,             MH, LH, kw2, PMS (KSf))
c
      call UV2naa (VMSX (1,1,KBB), W, MH, LH, KXp, kw1, kw2)
      call UV1uaa (VMSX (1,1,KBB), W, MH, LH, KXp, kw3)
CCC_   . minus
      call UV1uma (W, VMSC,       MH, LH, kw4, KCMgm)
      call UV0uwa (W,             MH, LH, kw4, PMS (KSg))
c
c$$$      call UV3nma (W, VMID, VMSC, MH, LH, kw2, KIVi,  KCMfm)
      call UV1nma (W, VMSC, MH, LH, kw2, kw5, KCMfm)
      call UV0uwa (W,             MH, LH, kw2, PMS (KSf))
c
      call UV2naa (VMSX (1,1,KBB), W, MH, LH, KXm, kw1, kw2)
      call UV1uaa (VMSX (1,1,KBB), W, MH, LH, KXm, kw4)
c
c$$$      jv = KXm
c$$$      do jp = 1, MH
c$$$         if (VMSC(jp,KCMfm).eq.1.0d0) then
c$$$            write (*, *) 'bpv', jv, jp,
c$$$     $           VMSC(jp,KCMfm), VMID(jp,KIVi), VMID(jp,KIVBi),
c$$$     $           VMSX(jp,jv,KBB)
c$$$         endif
c$$$      enddo
c$$$c
      RETURN
      END
CCC_ & MSUbpd  ## right-hand vector (derivative)
      subroutine MSUbpd
     O    (iErr,
     M     VMSX,  W,     CW,
     I     KBB,
     I     PMS,   VMI,   VMSC,
     I     KXp,   KXm,
     I     KSf,   KSi,   KSg,
     I     KIH,
     I     KCN,   KCMi,  KCMfp,  KCMgp,  KCMfm, KCMgm,
     I     KOfc,  ipKW,  iMA,
     I     WW,    MH,    LH,     LXK)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  MH,   LH, LXK
      _INTENT(INOUT,_REALSTD) VMSX (LH, LXK, *)
      _INTENT(OUT,  _REALSTD) W    (LH, *)
      _INTENT(OUT,  _REALSTD) CW   (LH, *)
      _INTENT(IN,   _REALSTD) PMS  (*)
      _INTENT(IN,   _REALSTD) VMI  (LH, *)
      _INTENT(IN,   _REALSTD) VMSC (LH, *)
      _INTENT(IN,   _REALSTD) WW (LH, *)
      _INTENT(IN,   integer)  KBB
      _INTENT(IN,   integer)  KXp,  KXm
      _INTENT(IN,   integer)  KSf,  KSi,   KSg
      _INTENT(IN,   integer)  KIH
      _INTENT(IN,   integer)  KCN
      _INTENT(IN,   integer)  KCMi, KCMfp, KCMgp, KCMfm, KCMgm
      _INTENT(IN,   integer)  KOfc
      _INTENT(IN,   integer)  ipKW (*)
      _INTENT(IN,   integer)  iMA  (*)
      integer kw1, kw2, kw3, kw4
      _REALSTD DI, DW,  GR
CCC_  - Body
      iErr = 0
c
      kw1  = 1
      kw2  = 2
      kw3  = 3
      kw4  = 4
c
      DI = PMS (PMS_DENS)
      DW = PMS (PMS_DENSW)
      GR = PMS (PMS_GRAV)
CCC_   . common
CCC_    * if interior, then right-hand vector is 0
      call UV1nwa (W, VMSC, MH, LH, kw4, KCMi, 0.0d0)
      call UV0uwa (W,       MH, LH, kw4, PMS (KSi))
c
CCC_    * ghost
      if (KIH.gt.0) then
CCC_     + if hydrostatic balance eq
c$$$         call UV3nma (W, VMSI, VMSC, MH, LH, kw2, KIHSI, KCN)
#if 0 /* test normal thickness */
         call MSFhsi (W, VMI, kw2, VMI_Ha, DI, DW, GR, MH, LH)
#else
         call MSFhsi (W, VMI, kw2,  KIH, DI, DW, GR, MH, LH)
#endif
         call UV1uma (W, VMSC, MH, LH, kw2, KCN)
         call AKBwex
     M       (W,   CW,
     I        WW,
     I        MH,  LH,  kw3, kw2, ipKW, iMA, KOfc, KWM_T)
      else
CCC_     + if PQ relation
         call UV0sta (W, MH, LH, kw2, 0.0d0)
         call UV0sta (W, MH, LH, kw3, 0.0d0)
      endif
CCC_   . plus
c$$$      call UV3nma (W, VMSC, VMSX (1,1,KXX), MH, LH, kw1, KCMfp, KXp)
c$$$      call UV0uwa (W,             MH, LH, kw1, PMS (KSf))
cc      force fixed solution as 0
      call UV0uwa (W,             MH, LH, kw1, 0.0d0)
c
      call UV1uma (W, VMSC,       MH, LH, kw2, KCMgp)
      call UV0uwa (W,             MH, LH, kw2, PMS (KSg))
c
      call UV2naa (VMSX (1,1,KBB), W, MH, LH, KXp, kw1, kw2)
CCC_   . minus
c$$$      call UV3nma (W, VMSC, VMSX (1,1,KXX), MH, LH, kw1, KCMfm, KXm)
c$$$      call UV0uwa (W,             MH, LH, kw1, PMS (KSf))
cc      force fixed solution as 0
      call UV0uwa (W,             MH, LH, kw1, 0.0d0)
c
      call UV1uma (W, VMSC,       MH, LH, kw3, KCMgm)
      call UV0uwa (W,             MH, LH, kw3, PMS (KSg))
c
      call UV2naa (VMSX (1,1,KBB), W, MH, LH, KXm, kw1, kw3)
c
      RETURN
      END
CCC_ & MSUhsi  ## HSI computation
      subroutine MSUhsi
     O    (iErr,
     O     V,
     I     MH, LH, DI, DW, GR, KHSI, KH)
      implicit none
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  MH, LH
      _INTENT(INOUT,_REALSTD) V (LH, *)
      _INTENT(IN,   _REALSTD) DI,   DW,  GR
      _INTENT(IN,   integer)  KHSI, KH
      integer jp
      _REALSTD   VH, DDG
c
      iErr = 0
c
      DDG = DI / DW * (DW - DI) * GR * 0.5d0
c
      do jp = 1, MH
         VH = V (jp, KH)
         V (jp, KHSI) = DDG * (VH * VH) * 1.0d0
      enddo
c
      RETURN
      END
CCC_ & MSUscl  ## Scales
      subroutine MSUscl
     O    (iErr,
     O     PMS,
     I     SCLH, SCLL, SCLU, SCLD, SCLN,
     I     DI,   DW,   GR,
     I     IFP)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,_REALSTD)  PMS   (*)
      _INTENT(IN, _REALSTD)  SCLH, SCLL
      _INTENT(IN, _REALSTD)  SCLU, SCLD, SCLN
      _INTENT(IN, _REALSTD)  DI,   DW,   GR
      _INTENT(IN, integer)   IFP
c
      _REALSTD TSD, TSN
      _REALSTD PD,  PN,  PV
c
      integer j
CCC_  - Body
      iErr = 0
CCC_   . preparation
      TSD = DI * GR * SCLH * SCLH / SCLL
      TSN = (DW - DI) * DI / DW * GR * SCLH * SCLH
c
      PD  = SCLD
      PN  = SCLN
      PV  = SCLU
c
      if (PD.eq.0.0d0) PD = TSD
      if (PN.eq.0.0d0) PN = TSN
      if (PV.eq.0.0d0) PV = 1.0d0
c
 101  format ('MSUscl:i: ', 3E16.8)
 102  format ('MSUscl:t: ', 3E16.8)
 103  format ('MSUscl:o: ', 3E16.8)
c
      if      (COND_N(IFP)) then
         write (IFP, 101) SCLD, SCLN, SCLU
         write (IFP, 102) TSD,  TSN,  1.0d0
         write (IFP, 103) PD,   PN,   PV
      else if (COND_S(IFP)) then
         write (*,   101) SCLD, SCLN, SCLU
         write (*,   102) TSD,  TSN,  1.0d0
         write (*,   103) PD,   PN,   PV
      endif
CCC_   . uv row
      PMS (PMS_SclUI) = (PD / PV)
      PMS (PMS_SclUF) = (PV / PV)
      PMS (PMS_SclUG) = (PN / PV)
      PMS (PMS_SclVI) = (PD / PV)
      PMS (PMS_SclVF) = (PV / PV)
      PMS (PMS_SclVG) = (PN / PV)
c
      PMS (PMS_InvUI) = 1.0d0 / (PD / PV)
      PMS (PMS_InvUF) = 1.0d0 / (PV / PV)
      PMS (PMS_InvUG) = 1.0d0 / (PN / PV)
      PMS (PMS_InvVI) = 1.0d0 / (PD / PV)
      PMS (PMS_InvVF) = 1.0d0 / (PV / PV)
      PMS (PMS_InvVG) = 1.0d0 / (PN / PV)
CCC_   . PQ row
      PMS (PMS_SclPI) =  PD
      PMS (PMS_SclPF) =  PD
      PMS (PMS_SclPG) =  PN
      PMS (PMS_SclQI) =  PD
      PMS (PMS_SclQF) =  PD
      PMS (PMS_SclQG) =  PN
c
      PMS (PMS_InvPI) = 1.0d0 / PD
      PMS (PMS_InvPF) = 1.0d0 / PD
      PMS (PMS_InvPG) = 1.0d0 / PN
      PMS (PMS_InvQI) = 1.0d0 / PD
      PMS (PMS_InvQF) = 1.0d0 / PD
      PMS (PMS_InvQG) = 1.0d0 / PN
CCC_   . R row
      PMS (PMS_SclRI) =  PD
      PMS (PMS_SclRF) =  PD
c
      PMS (PMS_InvRI) = 1.0d0 / PD
      PMS (PMS_InvRF) = 1.0d0 / PD
c
 201  format ('MSUscl:c:', I2.2, 1x, E16.9)
      if      (COND_N(IFP)) then
         do j = 1, PMS_MAX
            write (IFP, 201) j, PMS (j)
         enddo
      else if (COND_S(IFP)) then
         do j = 1, PMS_MAX
            write (*,   201) j, PMS (j)
         enddo
      endif
c
      RETURN
      END
CCC_ & MSUntl  ## nxy bc
      subroutine MSUntl
     O    (iErr,
     O     VC,   CW,   W,
     I     VI,
     I     KNT,  KNL,  KIK,  KFC,
     I     WW,   ipKW, iMA,  MH,   LH)
CCC_  - Declaration
      implicit none
CCC_   . Arguments
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   MH, LH
      _INTENT(OUT,_REALSTD)  VC   (LH, *)
      _INTENT(IN, _REALSTD)  VI   (LH, *)
      _INTENT(OUT,_REALSTD)  W    (LH, *)
      _INTENT(OUT,_REALSTD)  CW   (*)
      _INTENT(IN, integer)   KNT,  KNL
      _INTENT(IN, integer)   KIK
      _INTENT(IN, integer)   KFC
      _INTENT(IN, integer)   iMA (*)
      _INTENT(IN, integer)   ipKW (IPKW_FULL_DECL)
      _INTENT(IN, _REALSTD)  WW (LH, *)
CCC_   . Interior
      integer jp
      integer knp
CCC_  - Body
      iErr = 0
c
      knp  = 1
c
      call UV0sta (VC, MH, LH, KNT, 0.0d0)
      call UV0sta (VC, MH, LH, KNL, 0.0d0)
c
      call AKBwez
     M    (W (1, knp),  CW,
     I     VI (1, KIK), WW,
     I     MH,   LH,
     I     ipKW, iMA, KFC, KWM_M)
CC       a  b  a  b
CC      [o  +][o  +] o
CC      knm :  IK : knp
      do jp = 1, MH
c$$$         write (*, *) jp, VI (jp, KIK), W (jp, knp)
         if (((VI (jp, KIK) .eq. _dOC)
     $          .or.(VI (jp, KIK) .eq. _dBR))
     $       .and.
     $        ((W (jp, knp) .eq. _dSH)
     $          .or.(W (jp, knp) .eq. _dGR))) then
            VC (jp, KNT) = -1.0d0
         endif
         if (((W (jp, knp) .eq. _dOC)
     $          .or.(W (jp, knp) .eq. _dBR))
     $       .and.
     $        ((VI (jp, KIK) .eq. _dSH)
     $          .or.(VI (jp, KIK) .eq. _dGR))) then
            VC (jp, KNT) = +1.0d0
         endif
      enddo
c
      RETURN
      END
CCC_ & MSUncr  ## nxy d
      subroutine MSUncr
     O    (iErr,
     O     VC,   CW,   W,
     I     VI,
     I     KNX,  KNY,  KIK,  KFCX, KFCY,
     I     WW,   ipKW, iMA,  MH,   LH)
CCC_  - Declaration
      implicit none
CCC_   . Arguments
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   MH, LH
      _INTENT(OUT,_REALSTD)  VC   (LH, *)
      _INTENT(OUT,_REALSTD)  W    (LH, *)
      _INTENT(OUT,_REALSTD)  CW   (*)
      _INTENT(IN, _REALSTD)  VI   (LH, *)
      _INTENT(IN, integer)   KNX,   KNY
      _INTENT(IN, integer)   KIK
      _INTENT(IN, integer)   KFCX,  KFCY
      _INTENT(IN, integer)   iMA (*)
      _INTENT(IN, integer)   ipKW (IPKW_FULL_DECL)
      _INTENT(IN, _REALSTD)  WW (LH, *)
CCC_   . Interior
      integer jp
      integer khl, kfh, kfa, mf
      integer mN,  mS,  mE,  mW
      integer mNW, mNE, mSW, mSE
      integer mBS
CCC_  - Body
      iErr = 0
c
      khl = 1
      kfh = 2
      kfa = 3
CC    BR(3)/OC(4) treated as same
      mBS = 4
c
      mN  = _iSH*(mBS**0)+ _iSH*(mBS**1)+ _iBR*(mBS**2)+ _iBR*(mBS**3)
      mS  = _iBR*(mBS**0)+ _iBR*(mBS**1)+ _iSH*(mBS**2)+ _iSH*(mBS**3)
      mE  = _iSH*(mBS**0)+ _iBR*(mBS**1)+ _iSH*(mBS**2)+ _iBR*(mBS**3)
      mW  = _iBR*(mBS**0)+ _iSH*(mBS**1)+ _iBR*(mBS**2)+ _iSH*(mBS**3)
c
      mNE = _iSH*(mBS**0)+ _iBR*(mBS**1)+ _iBR*(mBS**2)+ _iBR*(mBS**3)
      mNW = _iBR*(mBS**0)+ _iSH*(mBS**1)+ _iBR*(mBS**2)+ _iBR*(mBS**3)
      mSE = _iBR*(mBS**0)+ _iBR*(mBS**1)+ _iSH*(mBS**2)+ _iBR*(mBS**3)
      mSW = _iBR*(mBS**0)+ _iBR*(mBS**1)+ _iBR*(mBS**2)+ _iSH*(mBS**3)
c
      call UV0sta (VC, MH, LH, KNX, 0.0d0)
      call UV0sta (VC, MH, LH, KNY, 0.0d0)
c
      call AKBwez
     M    (W (1, khl),  CW,
     I     VI (1, KIK), WW,
     I     MH,   LH,
     I     ipKW, iMA, KFCX, KWM_M)
      do jp = 1, MH
         W (jp, kfh)
     $        = MIN (_dBR, VI (jp, KIK))
     $        + MIN (_dBR, W (jp, khl)) * DBLE (mBS)
      enddo
      call AKBfax
     M    (W,  CW,
     I     DBLE (mBS*mBS),
     I     MH,   LH,  kfa,  kfh,
     I     ipKW, iMA, KFCY, KWM_M)
c
      do jp = 1, MH
         mf = int (W (jp, kfa))
         if      (mf .eq. mN) then
            VC (jp, KNX) =  0.0d0
            VC (jp, KNY) = +1.0d0
         else if (mf .eq. mS) then
            VC (jp, KNX) =  0.0d0
            VC (jp, KNY) = -1.0d0
         else if (mf .eq. mE) then
            VC (jp, KNX) = +1.0d0
            VC (jp, KNY) =  0.0d0
         else if (mf .eq. mW) then
            VC (jp, KNX) = -1.0d0
            VC (jp, KNY) =  0.0d0
         else if (mf .eq. mNE) then
            VC (jp, KNX) = +0.5d0
            VC (jp, KNY) = +0.5d0
         else if (mf .eq. mNW) then
            VC (jp, KNX) = -0.5d0
            VC (jp, KNY) = +0.5d0
         else if (mf .eq. mSE) then
            VC (jp, KNX) = +0.5d0
            VC (jp, KNY) = -0.5d0
         else if (mf .eq. mSW) then
            VC (jp, KNX) = -0.5d0
            VC (jp, KNY) = -0.5d0
         endif
      enddo
c
      RETURN
      END
CCC_ & MSUvms  ## velocity mask
      subroutine MSUvms
     O    (iErr,
     M     VC,   CW,   W,
     I     VI,   VHB,  VSV,
     I     KMI,  KPMF, KPMG, KMMF, KMMG, KCNX, KCNY,
     I     KVMGL,
     I     KIKa, KIKb, KIKd, KVMSK,
     I     KFC1, KFC2, KCOO,
     I     WW,   ipKW, iMA,  MH,   LH)
CCC_  - Declaration
      implicit none
CCC_   . Arguments
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   MH, LH
      _INTENT(INOUT,_REALSTD)  VC   (LH, *)
      _INTENT(OUT,  _REALSTD)  W    (LH, *)
      _INTENT(OUT,  _REALSTD)  CW   (*)
      _INTENT(IN,   _REALSTD)  VI   (LH, *)
      _INTENT(IN,   _REALSTD)  VHB  (LH, *)
      _INTENT(IN,   _REALSTD)  VSV  (LH, *)
      _INTENT(IN,   integer)   KMI,  KPMF, KPMG, KMMF, KMMG
      _INTENT(IN,   integer)   KIKa, KIKb, KIKd, KCNX, KCNY
      _INTENT(IN,   integer)   KVMGL
      _INTENT(IN,   integer)   KVMSK
      _INTENT(IN,   integer)   KFC1, KFC2, KCOO
      _INTENT(IN,   integer)   iMA (*)
      _INTENT(IN,   integer)   ipKW (IPKW_FULL_DECL)
      _INTENT(IN,   _REALSTD)  WW (LH, *)
CCC_   . Interior
      integer jp
      _REALSTD TV, TD, TN
      integer  kdM, kaP, kNxyP, kNxyM
      integer  kCT
CCC_  - Body
      iErr = 0
c
      TV = 1.0d0
      TD = 1.0d0
      TN = 1.0d0
c
      kCT = ipKW (KWI_SW0, KCOO, KWM_M)
      if (kCT .eq. _GZERO) then
         call UV0sta (VC, MH, LH, KMI,  0.0d0)
         call UV0sta (VC, MH, LH, KPMF, TV)
         call UV0sta (VC, MH, LH, KMMF, TV)
         call UV0sta (VC, MH, LH, KPMG, 0.0d0)
         call UV0sta (VC, MH, LH, KMMG, 0.0d0)
         RETURN
      endif
CCC_   . copy IKd (at minus)
      kdM   = 1
      kaP   = 2
      kNxyP = 3
      kNxyM = 4
CC
CC     c P
CC     M b P
CC       M
      call AKBwez
     O    (W  (1, kdM),   CW,
     I     VI (1, KIKd),  WW,
     I     MH,   LH,  ipKW, iMA, KFC2, KWM_T)
      call AKBwez
     O    (W  (1, kaP),   CW,
     I     VI (1, KIKa),  WW,
     I     MH,   LH,  ipKW, iMA, KFC1, KWM_M)
CCC_   . nx * ny corner
      call UV2nma (W, VC, MH, LH, kNxyP, KCnx, KCny)
      call AKBwex
     M    (W,    CW,
     I     WW,
     I     MH,   LH,  kNxyM,  kNxyP,
     I     ipKW, iMA, KFC2, KWM_T)
CCC_   . reset
      call UV0sta (VC, MH, LH, KMI,  0.0d0)
      call UV0sta (VC, MH, LH, KPMF, 0.0d0)
      call UV0sta (VC, MH, LH, KMMF, 0.0d0)
      call UV0sta (VC, MH, LH, KPMG, 0.0d0)
      call UV0sta (VC, MH, LH, KMMG, 0.0d0)
CCC_   . derivation
#if OPT_SSA_ADJUST == SSA_ADJUST_PQ_GR
#  if OPT_SSA_CORNER_FIXED
      do jp = 1, MH
         if (VHB(jp, KVMSK) .eq. 0.0d0) then
               VC (jp, KMMF) = TV
               VC (jp, KPMF) = TV
         else if (VI (jp, KIKb) .eq. _dSH) then
            VC (jp, KMI)  = TD
         else
            if (VI (jp, KIKb) .eq. _dGR) then
               VC (jp, KMMF) = TV
               VC (jp, KPMF) = TV
            else if ((VI (jp, KIKa) .eq. _dSH)
     $              .or. (W  (jp, kaP) .eq. _dSH)) then
               VC (jp, KMI)  = TD
            else
               VC (jp, KMMF) = TV
               VC (jp, KPMF) = TV
            endif
         endif
      enddo
#  else /* not OPT_SSA_CORNER_FIXED */
#  error "not fully checked."
      do jp = 1, MH
         if (VHB(jp, KVMSK) .eq. 0.0d0) then
               VC (jp, KMMF) = TV
               VC (jp, KPMF) = TV
         else if (VI (jp, KIKb) .eq. _dSH) then
            VC (jp, KMI)  = TD
         else
            if ((W (jp, kdM) .eq. _dSH
     $           .or. (VI (jp, KIKa) .eq. _dSH))
     $           .and. W (jp, kNxyM) .ne. 0.0d0) then
               VC (jp, KMMG) = TN
            else
               VC (jp, KMMF) = TV
            endif
            if ((VI (jp, KIKd) .eq. _dSH
     $           .or. (W (jp, kaP) .eq. _dSH))
     $           .and. W (jp, kNxyP) .ne. 0.0d0) then
               VC (jp, KPMG) = TN
            else
               VC (jp, KPMF) = TV
            endif
         endif
      enddo
# endif
#elif OPT_SSA_ADJUST == SSA_ADJUST_UV_FL
#  if OPT_SSA_CORNER_FIXED
      do jp = 1, MH
         if (VHB(jp, KVMSK) .eq. 0.0d0) then
               VC (jp, KMMF) = TV
               VC (jp, KPMF) = TV
         else if (VI (jp, KIKb) .eq. _dSH) then
#  ifdef OPT_SSA_ADJUST_OBSOLETE
            if ((VI (jp, KIKa) .eq. _dGR)
     $           .or. (W  (jp, kaP) .eq. _dGR)) then
               VC (jp, KMMF) = TV
               VC (jp, KPMF) = TV
            else
               VC (jp, KMI)  = TD
            endif
#  else  /* not OPT_SSA_ADJUST_OBSOLETE */
            VC (jp, KMI)  = TD
#  endif /* not OPT_SSA_ADJUST_OBSOLETE */
         else
            if (VI (jp, KIKb) .eq. _dGR) then
               VC (jp, KMMF) = TV
               VC (jp, KPMF) = TV
            else if ((VI (jp, KIKa) .eq. _dSH)
     $              .or. (W  (jp, kaP) .eq. _dSH)) then
               VC (jp, KMI)  = TD
            else
               VC (jp, KMMF) = TV
               VC (jp, KPMF) = TV
            endif
         endif
      enddo
#  else /* not OPT_SSA_CORNER_FIXED */
#  error "not fully checked."
# endif
#else
#  error "unknown OPT_SSA_ADJUST method"
#endif
c
      RETURN
      END
CCC_ & MSUpmi  ## PQ mask (part i interior/fixed)
      subroutine MSUpmi
     O    (iErr,
     M     VC,   CW,   W,
     I     VI,
     I     KMI,  KPMFx, KMMFx, KPMFy, KMMFy,
     I     KIK,  KIKb,  KIKc,
     I     KFCb, KFCc,
     I     WW,   ipKW,  iMA,   MH,   LH)
CCC_  - Declaration
      implicit none
CCC_   . Arguments
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   MH, LH
      _INTENT(INOUT,_REALSTD)  VC   (LH, *)
      _INTENT(OUT,  _REALSTD)  W    (LH, *)
      _INTENT(OUT,  _REALSTD)  CW   (*)
      _INTENT(IN,   _REALSTD)  VI   (LH, *)
      _INTENT(IN,   integer)   KMI
      _INTENT(IN,   integer)   KPMFx, KMMFx, KPMFy, KMMFy
      _INTENT(IN,   integer)   KIK,   KIKb,  KIKc
      _INTENT(IN,   integer)   KFCb, KFCc
      _INTENT(IN,   integer)   iMA (*)
      _INTENT(IN,   integer)   ipKW (IPKW_FULL_DECL)
      _INTENT(IN,   _REALSTD)  WW (LH, *)
CCC_   . Interior
      _REALSTD TV, TD
      integer kbM, kcM
      integer jp
CCC_  - Body
      iErr = 0
c
      TV = 1.0d0
      TD = 1.0d0
c
      kbM = 1
      kcM = 2
CCC_   . reset
      call UV0sta (VC, MH, LH, KMI,   0.0d0)
      call UV0sta (VC, MH, LH, KPMFx, 0.0d0)
      call UV0sta (VC, MH, LH, KMMFx, 0.0d0)
      call UV0sta (VC, MH, LH, KPMFy, 0.0d0)
      call UV0sta (VC, MH, LH, KMMFy, 0.0d0)
c
c   M a b
c   + o o
      call AKBwez
     M    (W  (1, kbM),  CW,
     I     VI (1, KIKb), WW,
     I     MH,    LH,    ipKW, iMA, KFCb, KWM_T)
      call AKBwez
     M    (W  (1, kcM),  CW,
     I     VI (1, KIKc), WW,
     I     MH,    LH,    ipKW, iMA, KFCc, KWM_T)
CCC_   . set
      do jp = 1, MH
CCC_    * if a is shelf
         if (VI (jp, KIK) .eq. _dSH) then
            VC (jp, KMI) = TD
CCC_    * if a is grounded
         else if (VI (jp, KIK) .eq. _dGR) then
            if ((VI (jp, KIKb) .eq. _dSH)
     $           .or. (VI (jp, KIKc) .eq. _dSH)
     $           .or. (W  (jp, KbM)  .eq. _dSH)
     $           .or. (W  (jp, KcM)  .eq. _dSH)) then
#if 1 /* OPT_SSA_ADJUST == SSA_ADJUST_PQ_GR */
               VC (jp, KMI) = TD
#else
               VC (jp, KPMFx) = TD
               VC (jp, KMMFx) = TD
               VC (jp, KPMFy) = TD
               VC (jp, KMMFy) = TD
#endif
            else
CC TODO: need check
CC       interior PQ always computation
c$$$               VC (jp, KMI) = TD
CC       interior PQ is fixed
               VC (jp, KPMFx) = TD
               VC (jp, KMMFx) = TD
               VC (jp, KPMFy) = TD
               VC (jp, KMMFy) = TD
            endif
CCC_    * other cases set by MSUpmg
         endif
      enddo
c
c$$$      do jp = 1, MH
c$$$         write (*, *) 'PM', jp-1, VC(jp, KMI),
c$$$     $        VI(jp,KIK), VI(jp,KIKb), W(jp,kbM),
c$$$     $        VI(jp,KIKc), W(jp,kcM)
c$$$      enddo
c
      RETURN
      END
CCC_ & MSUpmg  ## PQ mask (part ii. ghost/fixed)
      subroutine MSUpmg
     O    (iErr,
     M     VC,   CW,   W,
     I     VI,
     I     KPMF,  KPMG,  KMMF,  KMMG,
     I     KPMFd, KPMGd, KMMFd, KMMGd, KCNX, KCNY,
     I     KIK,   KIKb,
     I     KFCb,
     I     WW,    ipKW,  iMA,   MH,   LH)
CCC_  - Declaration
      implicit none
CCC_   . Arguments
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   MH,   LH
      _INTENT(INOUT,_REALSTD)  VC   (LH, *)
      _INTENT(OUT,  _REALSTD)  W    (LH, *)
      _INTENT(OUT,  _REALSTD)  CW   (*)
      _INTENT(IN,   _REALSTD)  VI   (LH, *)
      _INTENT(IN,   integer)   KPMF,  KPMG,  KMMF,  KMMG
      _INTENT(IN,   integer)   KPMFd, KPMGd, KMMFd, KMMGd
      _INTENT(IN,   integer)   KIK,  KIKb,  KCNX,  KCNY
      _INTENT(IN,   integer)   KFCb
      _INTENT(IN,   integer)   iMA (*)
      _INTENT(IN,   integer)   ipKW (IPKW_FULL_DECL)
      _INTENT(IN,   _REALSTD)  WW (LH, *)
CCC_   . Interior
      integer  jp
      integer  kbM, kNxyP, kNxyM
      integer  kaM, kaP
      _REALSTD TD, TN
CCC_  - Body
      iErr = 0
c
      kbM   = 1
      kaM   = 2
      kaP   = 3
      kNxyM = 4
      kNxyP = 5
c
      TN = 1.0d0
      TD = 1.0d0
c
c    M  . [a  b] P
c
      call AKBwez
     M    (W  (1, kbM),  CW,
     I     VI (1, KIKb), WW,
     I     MH,    LH,    ipKW, iMA, KFCb, KWM_T)
      call AKBwez
     M    (W  (1, kaM),  CW,
     I     VI (1, KIK),  WW,
     I     MH,    LH,    ipKW, iMA, KFCb, KWM_T)
      call AKBwez
     M    (W  (1, kaP),  CW,
     I     VI (1, KIK),  WW,
     I     MH,    LH,    ipKW, iMA, KFCb, KWM_M)
CCC_   . reset
c  KPMF, KMMF are already reset
      call UV0sta (VC, MH, LH, KPMG, 0.0d0)
      call UV0sta (VC, MH, LH, KMMG, 0.0d0)
c
      call UV0sta (VC, MH, LH, KPMFd, 0.0d0)
      call UV0sta (VC, MH, LH, KMMFd, 0.0d0)
      call UV0sta (VC, MH, LH, KPMGd, 0.0d0)
      call UV0sta (VC, MH, LH, KMMGd, 0.0d0)
CCC_   . set (longitudinal)
      do jp = 1, MH
CCC_    * shelf or grounded cases are skipped
         if (VI (jp, KIK) .eq. _dSH) then
            continue
         else if (VI (jp, KIK) .eq. _dGR) then
            continue
CCC_    * other cases
         else
            if ((W (jp, kbM) .eq. _dSH)
     $           .or. (W (jp, kaM) .eq. _dSH)) then
               VC (jp, KMMG) = TN
            else
               VC (jp, KMMF) = TD
            endif
            if ((VI (jp, KIKb) .eq. _dSH)
     $           .or. (W (jp, kaP) .eq. _dSH)) then
               VC (jp, KPMG) = TN
            else
               VC (jp, KPMF) = TD
            endif
         endif
      enddo
CCC_   . set (transverse)
      call UV2nma (W, VC, MH, LH, kNxyP, KCnx, KCny)
      call AKBwex
     M    (W,    CW,
     I     WW,
     I     MH,   LH,  kNxyM,  kNxyP,
     I     ipKW, iMA, KFCb, KWM_T)
      do jp = 1, MH
         VC (jp, KPMFd) = VC (jp, KPMF)
         VC (jp, KMMFd) = VC (jp, KMMF)
C     force fixed if nx (and/or) ny == 0 at front
         if (VC (jp, KPMG).ne.0.0d0) then
            if (W (jp, kNxyP).eq.0.0d0) then
               VC (jp, KPMFd) = TD
            else
               VC (jp, KPMGd) = VC (jp, KPMG)
            endif
         endif
         if (VC (jp, KMMG).ne.0.0d0) then
            if (W (jp, kNxyM).eq.0.0d0) then
               VC (jp, KMMFd) = TD
            else
               VC (jp, KMMGd) = VC (jp, KMMG)
            endif
         endif
      enddo
c
      RETURN
      END
CCC_ & MSUrms  ## R mask
      subroutine MSUrms
     O    (iErr,
     M     VC,   CW,   W,
     I     VI,
     I     KMI,  KMF,
     I     KUI,  KUNf, KUNg, KUSf, KUSg,
     I     KVI,  KVEf, KVEg, KVWf, KVWg, KCNX, KCNY,
     I     KIKb, KIKc,
     I     KFCb, KFCc,
     I     WW,   ipKW, iMA,  MH,   LH)
CCC_  - Declaration
      implicit none
CCC_   . Arguments
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   MH, LH
      _INTENT(INOUT,_REALSTD)  VC   (LH, *)
      _INTENT(OUT,_REALSTD)  W    (LH, *)
      _INTENT(OUT,_REALSTD)  CW   (*)
      _INTENT(IN, _REALSTD)  VI   (LH, *)
      _INTENT(IN, integer)   KMI,   KMF
      _INTENT(IN, integer)   KUI,   KVI
      _INTENT(IN, integer)   KUNf,  KUNg, KUSf, KUSg
      _INTENT(IN, integer)   KVEf,  KVEg, KVWf, KVWg
      _INTENT(IN, integer)   KIKb,  KIKc, KCNX,  KCNY
      _INTENT(IN, integer)   KFCb,  KFCc
      _INTENT(IN, integer)   iMA (*)
      _INTENT(IN, integer)   ipKW (IPKW_FULL_DECL)
      _INTENT(IN, _REALSTD)  WW (LH, *)
CCC_   . Interior
      integer  jp
      integer  ktmp
      integer  kkN, kkE, kkW, kkS
      integer  kNxy
      _REALSTD TD
CCC_   . Body
      iErr = 0
c
      ktmp = 1
      kkN  = 2
      kkS  = 3
      kkE  = 4
      kkW  = 5
      kNxy = 6
c
      TD = 1.0d0
CCC_   . reset
      call UV0sta (VC, MH, LH, KMI,  1.0d0)
      call UV0sta (VC, MH, LH, KMF,  0.0d0)
c
      call UV2nma (W, VC, MH, LH, kNxy, KCnx, KCny)
CCC_   . grid-category reversal (not same as IK)
cc         uS
cc      [vE d] vW
cc      [a uN]
#define _GH 3.d0
#define _IN 2.d0
#define _FX 1.d0
      call MSUrcg (W, VC, VI, MH, LH, kkN,  KUI, KUNf, KUNg, KIKb)
      call MSUrcg (W, VC, VI, MH, LH, kkE,  KVI, KVEf, KVEg, KIKc)
      call MSUrcg (W, VC, VI, MH, LH, ktmp, KUI, KUSf, KUSg, KIKb)
      call AKBwex
     M    (W,    CW,
     I     WW,
     I     MH,   LH,  kkS,  ktmp,
     I     ipKW, iMA, KFCc, KWM_M)
      call MSUrcg (W, VC, VI, MH, LH, ktmp, KVI, KVWf, KVWg, KIKc)
      call AKBwex
     M    (W,    CW,
     I     WW,
     I     MH,   LH,  kkW,  ktmp,
     I     ipKW, iMA, KFCb, KWM_M)
CCC_   . derivation
#if OPT_SSA_CORNER_FIXED
      do jp = 1, MH
         if ((W (jp, kkN).eq. _GH)
     $        .or. (W (jp, kkS).eq. _GH)
     $        .or. (W (jp, kkE).eq. _GH)
     $        .or. (W (jp, kkW).eq. _GH)) then
            VC (jp, KMF) = TD
            VC (jp, KMI) = 0.0d0
         else if ((W (jp, kkN).eq. _IN)
     $        .or. (W (jp, kkS).eq. _IN)
     $        .or. (W (jp, kkE).eq. _IN)
     $        .or. (W (jp, kkW).eq. _IN)) then
            VC (jp, KMF) = 0.0d0
            VC (jp, KMI) = TD
         else
            VC (jp, KMF) = TD
            VC (jp, KMI) = 0.0d0
         endif
      enddo
#else /* not OPT_SSA_CORNER_FIXED */
#error "not implemented"
#endif /* not OPT_SSA_CORNER_FIXED */
      RETURN
      END
CCC_ & MSUrcg  ## R mask helper
      subroutine MSUrcg
     M    (W,
     I     VC,  VI,
     I     MH,  LH,  KKC, KUI, KUF, KUG, KIK)
      implicit none
      _INTENT(IN, integer)   MH, LH
      _INTENT(OUT,_REALSTD)  W    (LH, *)
      _INTENT(IN, _REALSTD)  VC   (LH, *)
      _INTENT(IN, _REALSTD)  VI   (LH, *)
      _INTENT(IN, integer)   KKC
      _INTENT(IN, integer)   KUI,  KUF,  KUG
      _INTENT(IN, integer)   KIK
      integer jp
      do jp = 1, MH
         if (VC (jp, KUG).ne.0.0d0) then
            W (jp, KKC) = _GH
         else if (VC (jp, KUI).ne.0.0d0) then
            W (jp, KKC) = _IN
         else if (VC (jp, KUF).ne.0.0d0) then
            if (VI (jp, KIK) .eq. _dGR) then
               W (jp, KKC) = _FX
            else
               W (jp, KKC) = _GH
            endif
         else
            W (jp, KKC) = 0.0d0
         endif
      enddo
      RETURN
      END
CCC_ & MSUrcf  ## R coeff.
      subroutine MSUrcf
     O    (iErr,
     O     VC,   CW,   W,
     I     VI,
     I     KHp,  KHm,
     I     KUp,  KUm,  KLp,  KLm,
     I     KIK,
     I     KFC1, KLI1, KFC2,
     I     WW,   ipKW, iMA,  MH,   LH)
CCC_  - Declaration
      implicit none
CCC_   . Arguments
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   MH, LH
      _INTENT(OUT,_REALSTD)  VC   (LH, *)
      _INTENT(OUT,_REALSTD)  W    (LH, *)
      _INTENT(OUT,_REALSTD)  CW   (*)
      _INTENT(IN, _REALSTD)  VI   (LH, *)
      _INTENT(IN, integer)   KHp,  KHm
      _INTENT(IN, integer)   KUp,  KUm,  KLp,  KLm
      _INTENT(IN, integer)   KIK
      _INTENT(IN, integer)   KFC1, KLI1, KFC2
      _INTENT(IN, integer)   iMA (*)
      _INTENT(IN, integer)   ipKW (IPKW_FULL_DECL)
      _INTENT(IN, _REALSTD)  WW (LH, *)
CCC_   . Interior
      integer jp
      integer knh,  kch,  kcc
CCC_  - Body
      iErr = 0
c
      knh = 1
      kch = 2
      kcc = 3
c
      call UV0sta (VC, MH, LH, KHp, 0.0d0)
      call UV0sta (VC, MH, LH, KHm, 0.0d0)
      call UV0sta (VC, MH, LH, KUp, 0.0d0)
      call UV0sta (VC, MH, LH, KUm, 0.0d0)
      call UV0sta (VC, MH, LH, KLp, 0.0d0)
      call UV0sta (VC, MH, LH, KLm, 0.0d0)
c
      call UV0sta (W,  MH, LH, kch, -1.0d0)
      call UV0sta (W,  MH, LH, kcc, -1.0d0)
c
      call AKBwez
     M    (W (1, knh),  CW,
     I     VI (1, KIK), WW,
     I     MH,   LH,
     I     ipKW, iMA, KFC1, KWM_M)
c
CC    a    b  a
CC    Q:E     Q:W
CC
CC -  S    X  S     0.5 0.5
CC
CC -  S    X  O     0   1
CC
CC -  O    X  S     1   0
CCC_   . TODO: copy L coeff.
      do jp = 1, MH
         if (VI (jp, KIK).eq.2.0d0 .and. W (jp, knh).eq.2.0d0) then
            VC (jp, KHp) = 0.5d0
            VC (jp, KHm) = 0.5d0
            W  (jp, kch) = 3.0d0
         else if (VI (jp, KIK).eq.2.0d0 .and. W (jp, knh).eq.3.0d0) then
            VC (jp, KHp) = 1.0d0
            W  (jp, kch) = 1.0d0
         else if (VI (jp, KIK).eq.3.0d0 .and. W (jp, knh).eq.2.0d0) then
            VC (jp, KHm) = 1.0d0
            W  (jp, kch) = 2.0d0
         else if (VI (jp, KIK).eq.3.0d0 .and. W (jp, knh).eq.3.0d0) then
            W  (jp, kch) = 0.0d0
         endif
      enddo
CC
CC    a   b   a
CC    Q:N     Q:N
CC
CC    S   X   S     0.5 0.5    case 3
CC -  O       O     0.5 0.5
CC
CC    S   X   O     0   1      case 1
CC -  O       O     1   0
c
CC    O   X   S     1   0      case 2
CC -  O       O     0   1
c
      call AKBwex
     M    (W,  CW,
     I     WW,
     I     MH,   LH,  kcc,  kch,
     I     ipKW, iMA, KFC2, KWM_M)
c
      do jp = 1, MH
         if (W (jp, kch).eq.0.0d0) then
            if (W (jp, kcc).eq.3.0d0) then
               VC (jp, KUm) = 0.5d0
               VC (jp, KUp) = 0.5d0
            else if (W (jp, kcc).eq.1.0d0) then
               VC (jp, KUm) = 1.0d0
            else if (W (jp, kcc).eq.2.0d0) then
               VC (jp, KUp) = 1.0d0
            endif
         endif
      enddo
c
CC    a   b   a
CC    Q:S     Q:S
CC
CC -  O       O     0.5 0.5
CC    S   X   S     0.5 0.5    case 3
CC
CC -  O       O     1   0
CC    S   X   O     0   1      case 1
c
CC -  O       O     0   1
CC    O   X   S     1   0      case 2
c
      call AKBwex
     M    (W,  CW,
     I     WW,
     I     MH,   LH,  kcc,  kch,
     I     ipKW, iMA, KFC2, KWM_T)
c
      do jp = 1, MH
         if (W (jp, kch).eq.0.0d0) then
            if (W (jp, kcc).eq.3.0d0) then
               VC (jp, KLm) = 0.5d0
               VC (jp, KLp) = 0.5d0
            else if (W (jp, kcc).eq.1.0d0) then
               VC (jp, KLm) = 1.0d0
            else if (W (jp, kcc).eq.2.0d0) then
               VC (jp, KLp) = 1.0d0
            endif
         endif
      enddo
c
      RETURN
      END
CCC_ & MSUdsl  ## dx switch bcd
      subroutine MSUdsl
     O    (iErr,
     O     VC,   CW,   W,
     I     KDP,  KDM,
     I     KPMG, KMMG,
     I     KFC,
     I     WA,   ipKW, iMA,  MH,   LH)
CCC_  - Declaration
      implicit none
CCC_   . Arguments
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   MH, LH
      _INTENT(OUT,_REALSTD)  VC   (LH, *)
      _INTENT(OUT,_REALSTD)  W    (LH)
      _INTENT(OUT,_REALSTD)  CW   (*)
      _INTENT(IN, integer)   KDP,  KDM
      _INTENT(IN, integer)   KPMG, KMMG
c
      _INTENT(IN, integer)   KFC
      _INTENT(IN, integer)   iMA (*)
      _INTENT(IN, integer)   ipKW (IPKW_FULL_DECL)
      _INTENT(IN, _REALSTD)  WA (LH, *)
CCC_   . Interior
      integer jp
CCC_  - Body
      iErr = 0
c
      call UV0sta (VC, MH, LH, KDP, 0.0d0)
      call UV0sta (VC, MH, LH, KDM, 0.0d0)
c
      call AKBmez
     M    (W,  CW,
     I     VC (1, KMMG), MH, LH, ipKW, iMA, KFC, KWM_M)
c         G   I         I   G
c       o x o x o ... o x o x o
c
      do jp = 1, MH
         if (VC (jp, KPMG).ne.0.0d0) then
            VC (jp, KDP) = 1.0d0
         else if (W (jp).ne.0.0d0) then
            VC (jp, KDM) = 1.0d0
         else
            VC (jp, KDP) = 0.5d0
            VC (jp, KDM) = 0.5d0
         endif
      enddo
c
      RETURN
      END
CCC_ & MSUcsw  ## corner switch
      subroutine MSUcsw
     O    (iErr,
     O     VC,
     I     KDT,  KDL,
     I     MH,   LH)
CCC_  - Declaration
      implicit none
CCC_   . Arguments
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   MH, LH
      _INTENT(OUT,_REALSTD)  VC   (LH, *)
      _INTENT(IN, integer)   KDT, KDL
CCC_  - Body
      iErr = 0
c
      call UV0sta (VC, MH, LH, KDT, 1.0d0)
      call UV0sta (VC, MH, LH, KDL, 0.0d0)
c
      RETURN
      END
CCC_ & MSUcrd  ## correction D
      subroutine MSUcrd
     M    (X,
     I     VC, VMSC, KD, KIK, KMF, MH, LH)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)   MH, LH
      _INTENT(INOUT,_REALSTD)  X    (LH, *)
      _INTENT(IN,   _REALSTD)  VC   (LH, *)
      _INTENT(IN,   _REALSTD)  VMSC (LH, *)
      _INTENT(IN,   integer)   KD, KIK, KMF
      integer j
      do j = 1, MH
         if (VMSC (j, KMF) .ne. 0.0d0) then
            X (j, KD) = 0.0d0
         endif
      enddo
      RETURN
      END
CCC_ & MSUcrv  ## correction v
      subroutine MSUcrv
     M    (X,
     I     VC, VMSC, KV, KIK, KMF, MH, LH)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)   MH, LH
      _INTENT(INOUT,_REALSTD)  X    (LH, *)
      _INTENT(IN,   _REALSTD)  VC   (LH, *)
      _INTENT(IN,   _REALSTD)  VMSC (LH, *)
      _INTENT(IN,   integer)   KV, KIK, KMF
      integer j
      do j = 1, MH
         if (VMSC (j, KMF) .ne. 0.0d0
     $        .and. VC (j, KIK) .eq. _dOC) then
            X (j, KV) = 0.0d0
         endif
      enddo
      RETURN
      END
CCC_ & MSUxvf  ## v mask by F
      subroutine MSUxvf
     M    (X,
     I     VMSC, KV, KMF, MH, LH)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)   MH, LH
      _INTENT(INOUT,_REALSTD)  X    (LH, *)
      _INTENT(IN,   _REALSTD)  VMSC (LH, *)
      _INTENT(IN,   integer)   KV, KMF
      integer j
      do j = 1, MH
         if (VMSC (j, KMF) .eq. 0.0d0) then
            X (j, KV) = 0.0d0
         endif
      enddo
      RETURN
      END
CCC_* [MSV] variables cluster manipulation
CCC_ & MSVsxb  ## cluster wrapper x - b (update)
      subroutine MSVsxb
     M    (X,
     I     MH,  LH,  LXK, KXL, KXB)
      implicit none
      _INTENT(IN,   integer)  MH, LH, KXL, KXB
      _INTENT(IN,   integer)  LXK
      _INTENT(INOUT,_REALSTD) X (LH, LXK, *)
      integer jv, jh
      do    jv = 1, VMSX_MAX
         do jh = 1, MH
            X (jh, jv, KXL) = X (jh, jv, KXL) - X (jh, jv, KXB)
         enddo
      enddo
      RETURN
      END
CCC_& MSBpms  ## Parameters initialization
      subroutine MSBpms
     O    (iErr,
     O     PMS,
     I     CR,    ipP, ipC, ipL)
CCC_ + Declaration
      implicit none
CCC_  - Arguments
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,_REALSTD)  PMS (*)
      _INTENT(IN, character) CR*(*)
      _INTENT(IN, integer)   ipP, ipC, ipL
CCC_  - Configuration
      character  CROOT * (8)
      _REALSTD   DENS, DENSW,  GRAV, PF
      _REALSTD   SCU,  SCL,    SCH,  SCA
      _REALSTD   SCN,  SCD,    SCV,  XSC, SCXFSR
c$$$      _REALSTD   BDC,  BDP
      namelist /NIPRMS/
     $     CROOT,
     $     DENS,  DENSW, GRAV, PF,
     $     SCU,   SCL,   SCH,  SCA, SCN, SCD,
     $     SCV,   XSC,   SCXFSR
CCC_  - interior
      integer jc
      _REALSTD TVX, C
CCC_ + Body
      iErr = 0
CCC_  - Configuration
      jc = 0
 200  continue
      call UUrwnd (iErr, ipP)
c
 100  continue
c
      CROOT = ' '
      DENS  = 910.0d0
      DENSW = 1028.0d0
      GRAV  = 9.81d0
      PF    = 3.0d0
c
c$$$      BDC   = 7.2082d10 / 31556926.d0 * 1.0d-5
c$$$      BDC   = 0.0d0
c
c$$$      BDC   = 7.2082d10 / 31556926.d0
c$$$      BDP   = 1.0d0
c
      SCL    = 100.0d3
      SCH    = 100.0d0
      SCA    = 1.d-25 * 1.0d8
      XSC    = 1.0d0
      SCV    = 1.0d3
      SCXFSR = 0.0d0
c
      SCU    = 1.0d0
      SCN    = -1.0d0
      SCD    = 1.0d0
c
      READ  (ipP, NIPRMS, IOSTAT = iErr)
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
         write (ipC, NIPRMS, IOSTAT = iErr)
      endif
CCC_  - Packing
      PMS (PMS_DENS)   = DENS
      PMS (PMS_DENSW)  = DENSW
      PMS (PMS_GRAV)   = GRAV
      PMS (PMS_PF)     = PF
c
      PMS (PMS_SCU)    = SCU
      PMS (PMS_SCL)    = SCL
      PMS (PMS_SCH)    = SCH
      PMS (PMS_SCA)    = SCA
      PMS (PMS_SCN)    = SCN
      PMS (PMS_SCD)    = SCD
      PMS (PMS_SCV)    = SCV
      PMS (PMS_XSC)    = XSC
c
      PMS (PMS_SCV)    = PMS (PMS_SCV) * XSC
      if (SCXFSR.le.0.0d0) then
         C      = - (1.0d0 - 1.0d0 / PF) / 2.0d0
         TVX    = (SCV / SCL) ** 2.0d0
         SCXFSR = (TVX ** C) * 0.5d0
      endif
      PMS (PMS_SCXFSR) = SCXFSR
      if (COND_N(ipL)) then
         write (ipL, 101) SCXFSR
      else if (COND_S(ipL)) then
         write (*,   101) SCXFSR
      endif
 101  format ('Eff. strain rate sc: ', E16.9)
CC    TODO: BDC scaling
c$$$      PMS (PMS_BDRGC) = BDC
c$$$      PMS (PMS_BDRGP) = BDP
c
      call MSUscl
     O    (iErr,
     M     PMS,
     I     SCH,  SCL,   SCU,  SCD, SCN,
     I     DENS, DENSW, GRAV,
     I     ipL)
c
      call DAtrcU (ipL, iErr, 'R', 'MSBPMS')
      RETURN
      END
CCC_* [MSD] Debug
CCC_ & MSDmtr  ## Matrix Full Diag
      subroutine MSDmtr
     O    (iErr,
     O     VMSX,
     W     CW,   VMSW,
     I     PMS,  VMSC, VMSV, WW,
     I     iMA,  IE,   ipKW, ipCG, MH, LH, LXK, LCG,
     I     IFP)
CCC_  - Declaration
      implicit none
CCC_   . Arguments
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   MH, LH, LCG, LXK
      _INTENT(OUT,_REALSTD)  VMSX (LH, LXK, *)
      _INTENT(OUT,_REALSTD)  VMSW (LH, *)
      _INTENT(OUT,_REALSTD)  CW   (*)
      _INTENT(IN, _REALSTD)  PMS (*)
      _INTENT(IN, _REALSTD)  VMSC (LH, *)
      _INTENT(IN, _REALSTD)  VMSV (LH, *)
      _INTENT(IN, _REALSTD)  WW (LH, *)
      _INTENT(IN, integer)   IFP
      _INTENT(IN, integer)   ipKW (IPKW_FULL_DECL)
      _INTENT(IN, integer)   IE  (*)
      _INTENT(IN, integer)   iMA (*)
      _INTENT(IN, integer)   ipCG (LCG, CGS_MAX)
      integer jv, jg
      integer kv, kg, kh
      integer kxl, kxrn, kxrt
      integer mxk, nnz
CCC_  - Body
      iErr = 0
      kxl  = 1
      kxrn = 2
      kxrt = 3
c
      mxk = LXK
c
      do    jv = 1, VMSX_MAX
         do jg = 1, EA_MG(IE)
CCC_   . create left vector
            do kv = 1, LXK
               call UV0sta (VMSX (1, 1, kxl), MH, LH, kv, 0.0d0)
            enddo
            do kh = 1, MH
               kg = EA_listLW(IE,(kh-1))
               if (jg.eq.kg) VMSX (kh, jv, kxl) = 1.0d0
            enddo
 101        format ('FULLi ', I0, 1x, I0, 1x, I0, 1x, I0, 1x, F5.1)
 102        format ('FULLn ', I0, 1x, I0, 1x, I0, 1x, I0, 1x, E14.7)
 103        format ('FULLt ', I0, 1x, I0, 1x, I0, 1x, I0, 1x, E14.7)
 104        format ('FULLzn ', I0, 1x, I0, 1x, I0)
 105        format ('FULLzt ', I0, 1x, I0, 1x, I0)
            if (COND_N(IFP)) then
               do    kv = 1, LXK
                  do kh = 1, MH
                     kg = EA_listLW(IE,kh-1)
                     if (VMSX (kh, kv, kxl).ne.0.0d0) then
                        write (IFP, 101)
     $                       jv, jg, kv, kg, VMSX (kh, kv, kxl)
                     endif
                  enddo
               enddo
            else if (COND_S(IFP)) then
#             define IFP *
               do    kv = 1, LXK
                  do kh = 1, MH
                     kg = EA_listLW(IE,kh-1)
                     if (VMSX (kh, kv, kxl).ne.0.0d0) then
                        write (IFP, 101)
     $                       jv, jg, kv, kg, VMSX (kh, kv, kxl)
                     endif
                  enddo
               enddo
#             undef  IFP
            endif
CCC_   . operation
            call MSBxml
     M          (VMSX,
     I           kxrn, kxl,
     W           CW,   VMSW,
     I           PMS,  VMSC, VMSV, WW,
     I           iMA,  ipKW, ipCG, MH, LH, LXK, LCG)
            call MSBxmt
     M          (VMSX,
     I           kxrt, kxl,
     W           CW,   VMSW,
     I           PMS,  VMSC, VMSV, WW,
     I           iMA,  ipKW, ipCG, MH, LH, LXK, LCG)
CCC_   . output
            if (COND_N(IFP)) then
               nnz = 0
               do    kv = 1, MXK
                  do kh = 1, MH
                     kg = EA_listLW(IE,kh-1)
                     if (VMSX (kh, kv, kxrn).ne.0.0d0) then
                        nnz = nnz + 1
                        write (IFP, 102)
     $                       jv, jg, kv, kg, VMSX (kh, kv, kxrn)
                     endif
                  enddo
               enddo
               write (IFP, 104) jv, jg, nnz
               nnz = 0
               do    kv = 1, MXK
                  do kh = 1, MH
                     kg = EA_listLW(IE,kh-1)
                     if (VMSX (kh, kv, kxrt).ne.0.0d0) then
                        nnz = nnz + 1
                        write (IFP, 103)
     $                       kv, kg, jv, jg, VMSX (kh, kv, kxrt)
                     endif
                  enddo
               enddo
               write (IFP, 105) jv, jg, nnz
            else if (COND_S(IFP)) then
#             define IFP *
               nnz = 0
               do    kv = 1, MXK
                  do kh = 1, MH
                     kg = EA_listLW(IE,kh-1)
                     if (VMSX (kh, kv, kxrn).ne.0.0d0) then
                        nnz = nnz + 1
                        write (IFP, 102)
     $                       jv, jg, kv, kg, VMSX (kh, kv, kxrn)
                     endif
                  enddo
               enddo
               write (IFP, 104) jv, jg, nnz
               nnz = 0
               do    kv = 1, MXK
                  do kh = 1, MH
                     kg = EA_listLW(IE,kh-1)
                     if (VMSX (kh, kv, kxrt).ne.0.0d0) then
                        nnz = nnz + 1
                        write (IFP, 103)
     $                       kv, kg, jv, jg, VMSX (kh, kv, kxrt)
                     endif
                  enddo
               enddo
               write (IFP, 105) jv, jg, nnz
#             undef  IFP
            endif
         enddo
      enddo
      RETURN
      END
CCC_& MSBMOS  ## Movement/SSA/b/matrix announcement
      subroutine MSBMOS (STRA, STRB, IOP)
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
      else if (IOP.eq.3) then
         STRA = 'OPT_SSA_CORNER_FIXED'
         write (STRB, *) OPT_SSA_CORNER_FIXED
      else
         STRA = ' '
         STRB = ' '
      endif
      RETURN
      END
CCC_* [TEST]  ## test
#ifdef TEST_MSBMOS
#  ifndef TEST_MSBMOS_SUB
#    define TEST_MSBMOS_SUB 1
#  endif
#endif
CCC_ + Parameter cluster
#if TEST_MSBMOS_SUB
#endif
CCC_ + misc switch
c$$$#define RESET_CLONE 1
#define RESET_CLONE 0
CCC_ @ MSBMts  ## test program
#ifdef TEST_MSBMOS
c
#include "ofnstd.h"
#include "odevid.h"
      program MSBMts
CCC_  - Test suites
CC::   SOURCES mutcfg.F mibakw.F msfunc.F
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
         call MStestMain (iErr, ipA, iMA)
      endif
      if (iErr.eq.0) then
         call ACCrep (FPL(ipA), 0)
      endif
      call DevFin (iErr)
      STOP
      END
CCC_ & MStestMain  ## check main
      subroutine MStestMain (iErr, ipA, iMA)
CCC_  - Declaration
      implicit none
#include "odevva.h"
      _INTENT(OUT,integer)  iErr
      _INTENT(IN, integer)  ipA (*)
      _INTENT(IN, integer)  iMA (*)
CCC_   . Domain size limit
#ifndef   OPT_MSBMOS_LHP_MAX
#  define OPT_MSBMOS_LHP_MAX OPT_MOVEMENT_LHP_MAX
#endif
#ifndef   OPT_MSBMOS_LHG_MAX
#  define OPT_MSBMOS_LHG_MAX OPT_MOVEMENT_LHG_MAX
#endif
      integer    LHPref
      parameter (LHPref = OPT_MSBMOS_LHP_MAX)
      integer    LHGref
      parameter (LHGref = OPT_MSBMOS_LHG_MAX)
c
      integer    LCK
      parameter (LCK = 16)
CCC_   . Variable clusters
      integer    LVMW
      parameter (LVMW = LHPref * VMW_MAX)
      _REALSTD   VMW  (LVMW)
c
      _REALSTD   VMI  (LHPref * VMI_MAX)
      _REALSTD   VMC  (LHPref * VMC_MAX)
c
      _REALSTD   VMID (LHPref * VMID_MAX)
c
      _REALSTD   VMSC (LHPref * VMSC_MAX)
      _REALSTD   VMSV (LHPref * VMSV_MAX)
      _REALSTD   VMSX (LHPref * VMSX_MAX * BCGW_MAX)
c
      _REALSTD   PMS  (PMS_MAX)
      integer    LKW
      parameter (LKW = 128)
      _REALSTD   WW (LHPref * LKW)
      _REALSTD   CW (LHPref * LCK)
CCC_   . Table
      character  CR*8
      data       CR /'ID'/
      integer    LIE
      parameter (LIE = (LHPref * 8))
      integer    IE   (LIE)
      integer    ipKW (IPKW_FULL_DECL)
CCC_   . Work
      _REALSTD   WG (LHGref, 3)
CCC_   . Interior
      integer  MH, LH, MG, LG
      integer  NZ, LZ, KZ0
      integer  LXK
CCC_   . coordinate
      integer   icF
CCC_   . output
      integer   idGM (16)
      character CSW*(16)
      _REALSTD  T
CCC_   . Log
      integer ipL, ipP, ipC, ipV
      integer IFPa (16)
CCC_   . clone
      integer    LCG
      parameter (LCG = KWCG_DECL(4))
      integer    ipCG (LCG, CGS_MAX)
CCC_   . global/private stencils
      integer    LTBL
      parameter (LTBL = LHPref)
      integer    kDTA (LTBL, 3)
CCC_   . test variation
      logical OFULL, OSYMM
      namelist /NITEST/ OFULL, OSYMM
CCC_   . dummy
      _REALSTD WZV (1)
      integer  jerr
      integer  nxg, nyg
CCC_  - Body
      iErr = 0
c
      ipL  = FPL(ipA)
      ipP  = FPP(ipA)
      ipC  = FPC(ipA)
      ipV  = FPV(ipA)
c
      call AFUifp (IFPa, ipP, ipC, ipL, ipV)
c
      LXK  = VMSX_MAX
CCC_   . just for test
      NZ  = 0
      LZ  = 1
      KZ0 = 1
CCC_   . test variation
      OFULL = .false.
      OSYMM = .false.
      call UUrwnd (iErr, ipP)
      if (iErr.eq.0) then
         READ  (ipP, NITEST, IOSTAT = jerr)
         WRITE (ipC, NITEST, IOSTAT = jerr)
      endif
CCC_  - Arpeggio configuration
CCC_   . operatios
      if (iErr.eq.0) then
         if (iErr.eq.0) call AKPini (ipKW)
         if (iErr.eq.0) call MSBdec (iErr, ipKW, ipL)
      endif
CCC_   . table creation
      call ACCrgR (jerr, icF, 0, CR, ipL)
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
CCC_   . clone group
      if (iErr.eq.0) then
         call MSBcgr
     O       (iErr,
     O        ipCG,
     W        kDTA,
     I        LTBL, LCG, LH, LCK, ipKW, IE, ipL)
      endif
CCC_   . reports
      if (iErr.eq.0) then
         NZ  = 0
         LZ  = 1
         KZ0 = 1
         WZV (1) = 0.0d0
         call AMBrep
     O       (iErr,
     I        WW,  IE,  ipKW,
     I        MH,  LH,
     I        icF, CR,  'C',  MOVEMENT_DV_CLS,  IFPa, iMA)
      endif
CCC_  - parameters
      if (iErr.eq.0) then
         call MSbpms
     O       (iErr,
     O        PMS,
     I        CR,    ipP, ipC, ipL)
      endif
CCC_  - Test configuration
CCC_   . clear clone
      if (iErr.eq.0) then
         if (RESET_CLONE.eq.1) then
            call UV0sta (CW, LHPref * LCK, LHPref * LCK, 1, 0.0d0)
         endif
      endif
CCC_   . Initialization
CCC_    * set (with non-linear/linear solution)
      if (iErr.eq.0) then
         call MUTstp
     O       (iErr,
     W        VMW,  CW,  WG,
     O        VMSX, VMI, VMC, VMSV,   VMID,
     I        PMS,
     I        WW,   IE,  ipKW,   iMA,
     L        MH,   LH,  LXK, LHGref, CR,   ipP,  ipC, ipL)
      endif
CCC_  - Compute coefficients
CCC_   . category adjustment
      if (iErr.eq.0) then
         call MSSgca
     O       (iErr,
     M        VMC,  VMW,  CW,
     I        WW,   ipKW, iMA, MH, LH)
      endif
CCC_   . batch coefficients
      if (iErr.eq.0) then
         call MSSbcf
     O       (iErr,
     M        VMSC, CW,  VMW,
     I        VMI,  VMC, VMSV, WW, ipKW, iMA, MH, LH)
      endif
CCC_  - Solution correction
      if (iErr.eq.0) then
         call MSSxcr
     O       (iErr,
     M        VMSX,
     I        VMC, VMSC, BCGW_XX, MH, LH, LXK)
      endif
CCC_  - right
      if (iErr.eq.0) then
         call MSUbst
     O       (iErr,
     M        VMSX, VMW,  CW,
     I        PMS,  VMI,  VMC,  VMSC, VMID,
     I        BCGW_BB,
     I        WW,   ipKW, iMA, MH,   LH,   LXK)
      endif
CCC_  - Variable clusters output
      CSW = 'C'
      if (iErr.eq.0) then
         call MIVgst
     O       (iErr, idGM,
     I        icF,  MH,  LH, NZ,  LZ,  KZ0,
     I        CSW,  ' ', CR, IFPa, IE, iMA)
      endif
      if (iErr.eq.0) then
         call MSVgst
     O       (iErr, idGM,
     I        icF,  MH,  LH,
     I        CSW,  ' ', CR, IFPa, IE, iMA)
      endif
c
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
     I        VMSV,
     I        1,  idGM (VGRP_VMSV), 0, 0, T,  ' ',  ' ',  IE)
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
     I        VMSC,
     I        1,  idGM (VGRP_VMSC), VMSC_N0, VMSC_N9, T, ' ', 'CN', IE)
      endif
      if (iErr.eq.0) then
         call AFBptc
     O       (iErr,
     I        VMSC,
     I        1,  idGM (VGRP_VMSC), VMSC_I0, VMSC_I9, T, ' ', 'CI', IE)
      endif
      if (iErr.eq.0) then
         call AFBptc
     O       (iErr,
     I        VMSC,
     I        1,  idGM (VGRP_VMSC), VMSC_F0, VMSC_F9, T, ' ', 'CF', IE)
      endif
      if (iErr.eq.0) then
         call AFBptc
     O       (iErr,
     I        VMSC,
     I        1,  idGM (VGRP_VMSC), VMSC_G0, VMSC_G9, T, ' ', 'CG', IE)
      endif
      if (iErr.eq.0) then
         call AFBptc
     O       (iErr,
     I        VMSC,
     I        1,  idGM (VGRP_VMSC), VMSC_L0, VMSC_L9, T, ' ', 'CL', IE)
      endif
      if (iErr.eq.0) then
         call AFBptc
     O       (iErr,
     I        VMSC,
     I        1,  idGM (VGRP_VMSC), VMSC_D0, VMSC_D9, T, ' ', 'CD', IE)
      endif
      if (iErr.eq.0) then
         call AFBptc
     O       (iErr,
     I        VMSC,
     I        1,  idGM (VGRP_VMSC), VMSC_C0, VMSC_C9, T, ' ', 'CC', IE)
      endif
      if (iErr.eq.0) then
         call AFBptc
     O       (iErr,
     I        VMSX,
     I        BCGW_XX, idGM (VGRP_VMSX), 0, 0, T,  ' ',  'Xini',  IE)
      endif
      if (iErr.eq.0) then
         call AFBptc
     O       (iErr,
     I        VMSX,
     I        BCGW_BB,  idGM (VGRP_VMSX), 0, 0, T,  ' ',  'Xbb',   IE)
      endif
CCC_   . operation normal
      if (iErr.eq.0) then
         call MSBxml
     M       (VMSX,
     I        BCGW_P,     BCGW_XX,
     W        CW,   VMW,
     I        PMS,  VMSC, VMSV, WW,
     I        iMA,  ipKW, ipCG, MH, LH, VMSX_MAX, LCG)
         call AFBptc
     O       (iErr,
     I        VMSX,
     I        BCGW_P,  idGM (VGRP_VMSX), 0, 0, T,  ' ',  'Xn',  IE)
      endif
      if (iErr.eq.0) then
         call AFBptc
     O       (iErr,
     I        VMW,
     I        1,  idGM (VGRP_VMSN), 0, 0, T,  ' ',  ' ',  IE)
      endif
CCC_    * MX - b
      if (iErr.eq.0) then
         call MSVsxb
     M       (VMSX,
     I        MH,  LH,  VMSX_MAX, BCGW_P, BCGW_BB)
         call AFBptc
     O       (iErr,
     I        VMSX,
     I        BCGW_P,  idGM (VGRP_VMSX), 0, 0, T,  ' ',  'Dn',  IE)
      endif
CCC_   . operation transpose
      if (iErr.eq.0) then
         call MSBxmt
     M       (VMSX,
     I        BCGW_PP,    BCGW_P,
     W        CW,   VMW,
     I        PMS,  VMSC, VMSV, WW,
     I        iMA,  ipKW, ipCG, MH, LH, VMSX_MAX, LCG)
         call AFBptc
     O       (iErr,
     I        VMSX,
     I        BCGW_PP,  idGM (VGRP_VMSX), 0, 0, T,  ' ',  'Xt',  IE)
      endif
      if (iErr.eq.0) then
         call AFBptc
     O       (iErr,
     I        VMW,
     I        1,  idGM (VGRP_VMST), 0, 0, T,  ' ',  ' ',  IE)
      endif
CCC_   . other tests if required
CCC_    * full debug
      if (iErr.eq.0) then
         if (OFULL) then
            call MSDmtr
     O          (iErr,
     O           VMSX,
     W           CW,   VMW,
     I           PMS,  VMSC, VMSV, WW,
     I           iMA,  IE,   ipKW, ipCG, MH, LH, VMSX_MAX, LCG,
     I           ipL)
         endif
      endif
CCC_    * symmetric input
c$$$      if (iErr.eq.0) then
c$$$         if (OSYMM) then
c$$$            call MStestSymm
c$$$     O          (iErr,
c$$$     O           VMSX, VMSW, CW,   W,
c$$$     I           PMS, VMSC, VMSV, WO, WA,
c$$$     I           PMS,  IE,   ipKW, iMA, MH, LH, ipCG, LCG, idGM, ipL)
c$$$         endif
c$$$      endif
c
      call AFBrpG (jerr, ipL)
c
      RETURN
      END
CCC_ & MStestSymm  ## test variation (symmetry input)
#if 0
      subroutine MStestSymm
     O    (iErr,
     O     VMSX, VMSW, CW,   W,
     I     PMS,  VMSC, VMSV, WO, WA,
     I     PMS,  IE,   ipKW, iMA, MH, LH, ipCG, LCG, idGM, ipL)
      implicit none
      _INTENT(OUT,  integer)  iErr
      _INTENT(INOUT,_REALSTD) VMSX (*)
      _INTENT(OUT,  _REALSTD) VMSW (*), CW (*), W (*)
      _INTENT(IN,   _REALSTD) PMS  (*)
      _INTENT(IN,   _REALSTD) PMS (*)
      _INTENT(IN,   _REALSTD) VMSC (*), VMSV (*)
      _INTENT(IN,   _REALSTD) WO   (*), WA   (*)
      _INTENT(IN,   integer)  IE (*), ipKW (*), iMA (*)
      _INTENT(IN,   integer)  MH, LH, LCG
      _INTENT(IN,   integer)  idGM (*)
      _INTENT(IN,   integer)  ipCG (LCG, CGS_MAX)
      _INTENT(IN,   integer)  ipL
c
      _REALSTD T
c
      call MSinit_symm
     O    (iErr,
     O     VMSX,
     W     W,
     I     VMSX_PaW, 2,
     I     KWO_Xa, KWO_Ya, 'a',  ' ',
     I     PMS, WO,  IE,   ipKW, MH,  LH,  VMSX_MAX, ipL)
      call MSinit_symm
     O    (iErr,
     O     VMSX,
     W     W,
     I     VMSX_PaE, 2,
     I     KWO_Xa, KWO_Ya, 'a',  ' ',
     I     PMS, WO,  IE,   ipKW, MH,  LH,  VMSX_MAX, ipL)
      call MSinit_symm
     O    (iErr,
     O     VMSX,
     W     W,
     I     VMSX_QaW, 2,
     I     KWO_Xa, KWO_Ya, 'a',  ' ',
     I     PMS, WO,  IE,   ipKW, MH,  LH,  VMSX_MAX, ipL)
      call MSinit_symm
     O    (iErr,
     O     VMSX,
     W     W,
     I     VMSX_QaE, 2,
     I     KWO_Xa, KWO_Ya, 'a',  ' ',
     I     PMS, WO,  IE,   ipKW, MH,  LH,  VMSX_MAX, ipL)
      call MSinit_symm
     O    (iErr,
     O     VMSX,
     W     W,
     I     VMSX_UbS, 2,
     I     KWO_Xb, KWO_Yb, 'b',  'x',
     I     PMS, WO,  IE,   ipKW, MH,  LH,  VMSX_MAX, ipL)
c$$$         call MSinit_symm
c$$$     O       (iErr,
c$$$     O        VMSX,
c$$$     W        W,
c$$$     I        VMSX_UbN, 2,
c$$$     I        KWO_Xb, KWO_Yb, 'b',  'x',
c$$$     I        PMS, WO,  IE,   ipKW, MH,  LH,  VMSX_MAX, ipL)
c$$$         call MSinit_symm
c$$$     O       (iErr,
c$$$     O        VMSX,
c$$$     W        W,
c$$$     I        VMSX_VcE, 2,
c$$$     I        KWO_Xc, KWO_Yc, 'c',  'y',
c$$$     I        PMS, WO,  IE,   ipKW, MH,  LH,  VMSX_MAX, ipL)
c$$$         call MSinit_symm
c$$$     O       (iErr,
c$$$     O        VMSX,
c$$$     W        W,
c$$$     I        VMSX_VcW, 2,
c$$$     I        KWO_Xc, KWO_Yc, 'c',  'y',
c$$$     I        PMS, WO,  IE,   ipKW, MH,  LH,  VMSX_MAX, ipL)
      T = 0.0d0
      call MSBxmt
     M    (VMSX,
     I     3,    2,
     W     CW,   VMSW,
     I     PMS,  VMSC, VMSV, WW,
     I     iMA,  ipKW, ipCG, MH, LH, VMSX_MAX, LCG)
      call MUVbpt
     O    (iErr,
     I     VMSX,
     I     3,  idGM (VGRP_X), 0, 0, T,  ' ',  'VMSXs',  IE)
      RETURN
      END
#endif
#endif /* TEST_MSBMOS */
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
