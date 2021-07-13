C icies_tgv.F - IcIES/TGV (1d thermodynamics/age)
C Author: SAITO Fuyuki
C Created: May 31 2018
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2021/07/13 14:30:21 fuyuki icies_tgv.F>'
#define _FNAME 'icies_tgv.F'
#define _REV   'JosePeterson0'
CCC_! MANIFESTO
C
C Copyright (C) 2018-2021
C           Japan Agency for Marine-Earth Science and Technology,
C           Ayako ABE-OUCHI, Takashi OBASE
C
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
CCC_* Common macros
#include "ofdlct.h"   /* fortran dialect */
#include "odevva.h"
#include "ofnstd.h"
#include "ologfm.h"
CCC_ + Switches
#ifndef   OPT_VERBOSE
#  define OPT_VERBOSE 0
#endif
CCC_ + Domain size
#  define OPT_MOVEMENT_LHP_MAX 640
#  define OPT_MOVEMENT_LHG_MAX OPT_MOVEMENT_LHP_MAX
#  define OPT_MOVEMENT_LVZ_MAX 4100
CCC_ + TGV test parameter
#define ITGV_MSPATTERN   1 /* ms pattern */
#define ITGV_MBPATTERN   2 /* mb pattern */
#define ITGV_DHPATTERN   3 /* dH pattern */
#define ITGV_TSPATTERN   4 /* Ts pattern */
#  define SW_BCPAT_DEF         0
#  define SW_BCPAT_STEP        1
#  define SW_BCPAT_COS         2
#  define SW_BCPAT_LINEAR      3
#  define SW_BCPAT_EXP         4
#  define SW_DHPAT_EXP_VIALOV  5 /* exponential evolution toward vialov solution */
#define ITGV_WTYPE       5 /* w pattern */
#  define WTYPE_CONST    0
#  define WTYPE_VIALOV   1
#  define WTYPE_POWER    2
#define ITGV_XFILE_MS    6 /* unit of surface mass balance history */
#define ITGV_XFILE_TS    7 /* unit of surface temperature history */
#define ITGV_XFILE_MB    8 /* unit of basal mass balance history */
#define ITGV_XFILE_DH    9 /* unit of thickness history */
#define ITGV_MAX         9

#define PTGV_WPOWER      1   /* power parameter for w */

#define PTGV_S_TDECR     2   /* smb: decrement period */
#define PTGV_S_TINCR     3   /* smb: increment period */
#define PTGV_S_TLSTD     4   /* smb: steady low period */
#define PTGV_S_THSTD     5   /* smb: steady high period */
#define PTGV_S_DURATION  6   /* smb: total duration */
#define PTGV_S_PHASE     7   /* smb: phase offset */
#define PTGV_S_XTPREV    20   /* smb: xfile last time */
#define PTGV_S_XTNEXT    21   /* smb: xfile next time */
#define PTGV_S_VPREV     22   /* smb: xfile last value */
#define PTGV_S_VNEXT     23   /* smb: xfile next value */

#define PTGV_B_TDECR     8   /* bmb: decrement period */
#define PTGV_B_TINCR     9   /* bmb: increment period */
#define PTGV_B_TLSTD     10  /* bmb: steady low period */
#define PTGV_B_THSTD     11  /* bmb: steady high period */
#define PTGV_B_DURATION  12  /* bmb: total duration */
#define PTGV_B_PHASE     13  /* bmb: phase offset */
#define PTGV_B_XTPREV    14
#define PTGV_B_XTNEXT    15
#define PTGV_B_VPREV     16
#define PTGV_B_VNEXT     17

#define PTGV_H_TDECR     18  /* thickness: decrement period */
#define PTGV_H_TINCR     19  /* thickness: increment period */
#define PTGV_H_TLSTD     24  /* thickness: steady low period */
#define PTGV_H_THSTD     25  /* thickness: steady high period */
#define PTGV_H_DURATION  26  /* thickness: total duration */
#define PTGV_H_PHASE     27  /* thickness: phase offset */
#define PTGV_H_XTPREV    38  /* thickness: xfile last time */
#define PTGV_H_XTNEXT    39  /* thickness: xfile next time */
#define PTGV_H_VPREV     40  /* thickness: xfile last value */
#define PTGV_H_VNEXT     41  /* thickness: xfile next value */

#define PTGV_TS_TDECR    28   /* Ts: decrement period */
#define PTGV_TS_TINCR    29   /* Ts: increment period */
#define PTGV_TS_TLSTD    30   /* Ts: steady low period */
#define PTGV_TS_THSTD    31   /* Ts: steady high period */
#define PTGV_TS_DURATION 32   /* Ts: total duration */
#define PTGV_TS_PHASE    33   /* Ts: phase offset */

#define PTGV_TS_XTPREV   34   /* Ts: xfile last time */
#define PTGV_TS_XTNEXT   35   /* Ts: xfile next time */
#define PTGV_TS_VPREV    36   /* Ts: xfile last value */
#define PTGV_TS_VNEXT    37   /* Ts: xfile next value */

#define PTGV_MAX          41
CCC_ + TGV test field
#define VXCFG_MSMAX     1
#define VXCFG_MSMIN     2
#define VXCFG_MBMAX     3
#define VXCFG_MBMIN     4
#define VXCFG_HMAX      5
#define VXCFG_HMIN      6
#define VXCFG_TSMAX     7
#define VXCFG_TSMIN     8
#define VXCFG_MAX       8

#define VGRPX_VXCFG     1
CCC_ + evolution chocie
#define XOPR_MUL 1
#define XOPR_ADD 0
CCC_@ TGVdrv  ## IcIES/TGV driver
      program TGVdrv
CCC_ + Declaration
      implicit none
      integer iErr
      integer ipA (LOG_CHANNEL_MAX)
      integer iMA (MAX_MPI_ATTR)
CCC_ + Body
      call DDcapo
     O    (iErr,
     I     2, ' ', 'O', _FNAME, -1)
c
      if (iErr.eq.0) then
         call DLCmng (ipA, 't')
         call DVHrgC (iErr, 'V', ' ', ' ', ipA)
      endif
c
      if (iErr.eq.0) then
         call DMAtma (iMA)
         call TGVcnd (iErr, ipA, iMA)
      endif
      call DevFin (iErr)
      STOP
      END
CCC_& TGVcnd  ## IcIES/TGV conductor
#include "oarpea.h"
#include "oarpkw.h"   /* operation id in arpeggio/kiwi */
#include "movement/movement.h" /* movement definitions */
#include "begleitung/begleitung.h"
      SUBROUTINE TGVcnd (iErr, ipA, iMA)
CCC_ + System-dependent switches
#ifndef   OPT_FORMAT_STAR
#  define OPT_FORMAT_STAR 0
#endif
#if OPT_FORMAT_STAR
#  define _FORMAT(F) *
#else
#  define _FORMAT(F) F
#endif
CCC_ + Declaration
      implicit none
      _INTENT(OUT,integer)  iErr
      _INTENT(IN, integer)  ipA (*)
      _INTENT(IN, integer)  iMA (*)
CCC_  - Domain size limit
#ifndef   OPT_MDRVRM_LHP_MAX
#  define OPT_MDRVRM_LHP_MAX OPT_MOVEMENT_LHP_MAX
#endif
#ifndef   OPT_MDRVRM_LHG_MAX
#  define OPT_MDRVRM_LHG_MAX OPT_MOVEMENT_LHG_MAX
#endif
#ifndef   OPT_MDRVRM_LVZ_MAX
#  define OPT_MDRVRM_LVZ_MAX OPT_MOVEMENT_LVZ_MAX
#endif
#ifndef   OPT_MDRVRM_LVP_MAX
#  define OPT_MDRVRM_LVP_MAX OPT_MOVEMENT_LVP_MAX
#endif
#ifndef   OPT_BGLBRT_LVP_MAX
#  define OPT_BGLBRT_LVP_MAX (OPT_MDRVRM_LHP_MAX*OPT_BGLBRT_LVZ_MAX)
#endif
      integer    LHPref
      parameter (LHPref = OPT_MDRVRM_LHP_MAX)
      integer    LHGref
      parameter (LHGref = OPT_MDRVRM_LHG_MAX)
      integer    LTPref
      parameter (LTPref = OPT_MDRVRM_LVP_MAX)
      integer    LZref
      parameter (LZref  = OPT_MDRVRM_LVZ_MAX)
      integer    LZrefR
      parameter (LZrefR = OPT_BGLBRT_LVZ_MAX)
      integer    LBPref
      parameter (LBPref = OPT_BGLBRT_LVP_MAX)
CCC_  - Variable clusters
CCC_   . work common
      integer    LVMW
      parameter (LVMW  = LHPref  * VMW_MAX)
      _REALSTD   VMW  (LVMW)
      integer    LVMTW
      parameter (LVMTW = LTPref * VMTW_MAX)
      _REALSTD   VMTW (LVMTW)
CCC_   . bcg solution/right/intermediate
CCC_   . field common
      _REALSTD   VMHI (LHPref * VMHI_MAX)
      _REALSTD   VMHW (LHPref * VMHW_MAX)
c
      _REALSTD   VMHB (LHPref * VMHB_MAX)
      _REALSTD   VMHR (LHPref * VMHR_MAX)
CCC_   . 3d velocity
      _REALSTD   VMTI (LTPref * VMTI_MAX)
CCC_   . 3d age
      _REALSTD   VMTA (LTPref * VMTA_MAX)
      _REALSTD   VMTD (LTPref * VMTD_MAX)
CCC_   , bedrock temperature
      _REALSTD   VBBI (LHPref * VBBI_MAX)
      _REALSTD   VBBT (LBPref * VBBT_MAX)
      _REALSTD   VBBW (LBPref * VBBW_MAX)
CCC_   . experiment configuration
      _REALSTD   VXCFG(LHPref * VXCFG_MAX)
CCC_   . conversion table
      integer    KTB  (LHPref, 2)
CCC_   . integration weights
      integer    NTH
      parameter (NTH = 2)
      _REALSTD   GG  (LZref * 4 * (NTH + 1) * (NTH + 1))
CCC_  - kiwi weights
      integer    LKW
      parameter (LKW = 90)
      _REALSTD   WW (LHPref * LKW)
CCC_  - vertical geometry
      _REALSTD   WZV (LZref * VMVZ_MAX)
      _REALSTD   WZR (LZref * VBBZ_MAX)
CCC_  - work
      integer    LCK
      parameter (LCK = LZref + 16)
      _REALSTD   CW (LHPref * LCK)
CCC_  - Parameters
      logical    OMM (OMM_MAX)
      integer    IMM (IMM_MAX)
      _REALSTD   PMM (PMM_MAX)
      integer    IBB (IBB_MAX)
      _REALSTD   PBB (PBB_MAX)
c
      integer    ITGV (ITGV_MAX)
      _REALSTD   PTGV (PTGV_MAX)
CCC_  - Table
      character  CR*8
      data       CR /'ID'/
      character  CRR*8
      data       CRR /'RD'/
      character  CRX*8
      data       CRX /'XD'/
      integer    LIE
      parameter (LIE = (LHPref * 15))
      integer    IE   (LIE)
      integer    ipKW (IPKW_FULL_DECL)
CCC_   . global/private stencils
      integer    LNR
      parameter (LNR = 256)
      integer    KSglb (LNR * 2)
      integer    LTBL
      parameter (LTBL = LHPref)
      integer    kDTA (LTBL, 3)
CCC_   . clone group
      integer    LCG
      parameter (LCG = KWCG_DECL(CGRP_MEM_MAX))
      integer    ipCG (LCG, CGRP_MAX)
CCC_  - Interior
      integer    MH,  LH,  MG, LG
      integer    NZ,  LZ,  KZ0
      integer    NZR, LZR, KZ0R
CCC_  - Coordinate
      integer    icF
      integer    icFR
CCC_  - Time
      integer    ITstp
      _REALSTD   T,    TNXT
      _REALSTD   TSSA
      _REALSTD   DTI
      _REALSTD   TINI, TEND, DT
      _REALSTD   TBINI
CCC_  - Output
      integer    idGX (32)
      integer    idGM (32)
      integer    idGB (32)
      character  CSW*(16), CLS*(16)
CCC_  - Log
      integer    ipL, ipP, ipC, ipV
      integer    ipFI (16)
CCC_  - Test configuration
      integer    MAXMTI,       MAXMTP
      parameter (MAXMTI = 128, MAXMTP = 128)
      integer  IMTI (MAXMTI)
      _REALSTD PMTI (MAXMTP)
CCC_  - misc
      integer    jedmy
      _REALSTD T0
CCC   _   . MDstpD
      _REALSTD TI
CCC_   . MDstpT
      integer NHt
      _REALSTD   CONDI, CONDIP
CCC_   . MTButp
      integer  KHH, KHB
      _REALSTD HC
CCC_ + Body
      iErr = 0
CCC_  - configuration
CCC_   . from MTButp
      KHH = VMHI_nHa
      KHB = VMHI_nBa
      HC  = 0.0d0
CCC_  - i/o configuration
      CSW = 'C'
      CLS = MOVEMENT_DV_CLS
CCC_  - file units
      ipL  = FPL(ipA)
      ipP  = FPP(ipA)
      ipC  = FPC(ipA)
      ipV  = FPV(ipA)
CCC_  - Health check for Test module
      if (iErr.eq.0) then
         call MUThch (iErr, MAXMTI, MAXMTP, ipP, ipC, ipL)
      endif
CCC_  - Model time
      if (iErr.eq.0) then
         call MDBtim
     O       (iErr,
     O        TINI,  TEND,  DT,
     O        TSSA,
     I        CR,    ipP,   ipC, ipL)
      endif
      if (iErr.eq.0) then
         TBINI = MIN(MAX(100000.0d0, TINI), TEND)
         call BBitim
     O       (iErr,
     O        T,
     I        TBINI, TEND,  DT,
     I        CR,    ipP,   ipC, ipL)
         TBINI = T
      endif
CCC_   . initialization suite
      if (iErr.eq.0) then
         call MDinit
     O       (iErr,
     O        MH,     LH,            LHPref,
     O        MG,     LG,            LHGref,
     O        NZ,     LZ,     KZ0,   LZref,
     O        GG,                    NTH,
     O        WZV,    WW,            LKW,
     O        IE,                    LIE,
     O        ipCG,                  LCG,   LCK,
     O        KSglb,                 LNR,
     O        kDTA,                  LTBL,
     O        VMW,                   LVMW,
     O        icF,    idGM,   ipFI,  ipKW,
     O        OMM,    IMM,    PMM,
     I        TINI,   TEND,
     I        CSW,    CLS,    CR,    iMA,  ipA)
      endif
      if (iErr.eq.0) then
         call BBinit
     O       (iErr,
     O        NZR,  LZR,  KZ0R, LZrefR,
     O        WZR,
     O        IBB,  PBB,
     O        icFR, idGB,
     W        VMW,  LVMW,
     I        icF,  MH,   LH,  CSW,  CLS,  CRR,  CR, IE, iMA, ipA, ipFI)
      endif
      if (iErr.eq.0) then
         call TGVenv
     $        (iErr, ITGV, PTGV, PMM, (TINI - 1.0d0), ipP,  ipC, ipL)
c$$$         call TGVcfg(iErr, ITGV, PTGV, PMM, ipP, ipC, ipL)
c$$$         PTGV(PTGV_S_XTPREV) = TINI - 1.0d0
c$$$         PTGV(PTGV_S_XTNEXT) = TINI - 1.0d0
      endif
      if (iErr.eq.0) then
         call TGVrgc
     O       (iErr, idGX,
     I        icF,  MH,   LH,  CSW,  CLS,  CR, ipFI, IE, iMA)
      endif
CCC_   . Initialization
      if (iErr.eq.0) then
         T0 = 263.15d0
         call UV0stc (VMTI, MH, LH, LZ,   LZ,  1, VMTI_T, T0)
         call UV0stc (VBBT, MH, LH, LZR,  LZR, 1, VBBT_T, T0)
      endif
      if (iErr.eq.0) then
         T0 = 0.0d0
         call UV0stc (VMTA, MH, LH, LZ,   LZ,  1, VMTA_age,  T0)
         call UV0stc (VMTA, MH, LH, LZ,   LZ,  1, VMTA_dad3, T0)
         call UV0stc (VMTA, MH, LH, LZ,   LZ,  1, VMTA_dad1, T0)
         call UV0stc (VMTA, MH, LH, LZ,   LZ,  1, VMTA_dad2, T0)
      endif
      if (iErr.eq.0) then
         T0 = 0.0d0
         call UV0sta (VMHI, MH, LH, VMHI_ADVYn, T0)
         call UV0sta (VMHI, MH, LH, VMHI_ADVYs, T0)
         call UV0sta (VMHI, MH, LH, VMHI_ADVXe, T0)
         call UV0sta (VMHI, MH, LH, VMHI_ADVXw, T0)
         call UV0sta (VMHI, MH, LH, VMHI_frd,   T0)
      endif
      if (iErr.eq.0) then
         T0 = 0.0d0
         call UV0stc(VMTD, MH, LH, LZ, LZ, 1, VMTD_kai, T0)
      endif
      if (iErr.eq.0) then
         T0 = 3000.0d0
         call UV0sta (VBBI, MH, LH, VBBI_HR, T0)
         T0 = -42.0d-3 * 31556926d0
         call UV0sta (VBBI, MH, LH, VBBI_GH, T0)
      endif
      if (iErr.eq.0) then
         call AFBrmp(jedmy, VMHI, VMW,LVMW, idGM(VGRP_VMHI), IE,ipFI)
         call AFBrmp(jedmy, VMHB, VMW,LVMW, idGM(VGRP_VMHB), IE,ipFI)
         call AFBrmp(jedmy, VMHR, VMW,LVMW, idGM(VGRP_VMHR), IE,ipFI)
         call AFBrmp(jedmy, VMTI, VMW,LVMW, idGM(VGRP_VMTI), IE,ipFI)
         call AFBrmp(jedmy, VMTA, VMW,LVMW, idGM(VGRP_VMTA), IE,ipFI)
         call AFBrmp(jedmy, VMTD, VMW,LVMW, idGM(VGRP_VMTD), IE,ipFI)
      endif
      if (iErr.eq.0) then
         call AFBrmp(jedmy, VBBI, VMW,LVMW, idGB(VGRPB_VBBI), IE,ipFI)
      endif
      if (iErr.eq.0) then
         T0 = 0.0d0
         call UV0sta (VXCFG, MH, LH, VXCFG_MBMAX, T0)
         call UV0sta (VXCFG, MH, LH, VXCFG_MBMIN, T0)
         call AFBrmp(jedmy, VXCFG,VMW,LVMW, idGX(VGRPX_VXCFG), IE,ipFI)
      endif
      if (iErr.eq.0) then
         TI = 0.0d0
         call AFBwmp (jedmy, VMHR, idGM (VGRP_VMHR), TI, IE)
      endif
      if (iErr.eq.0) then
         TI = 0.0d0
         call AFBwmp (jedmy, VXCFG, idGX(VGRPX_VXCFG), TI, IE)
      endif
CCC_   . Loop
      if (iErr.eq.0) then
         ITstp  = 0
         T      = TINI
         TNXT   = TINI
c
 101     format ('#T ', I7.7, 1x, F13.4, 1x, F13.4)
         DO
CCC_    * time step adjustment
            TNXT = T + DT
c$$$            call AFBnxa (TNXT, T, idGM (VGRP_VMI))
            call AFBnxa (TNXT, T, idGM (VGRP_VMHB))
            call AFBnxa (TNXT, T, idGM (VGRP_VMTI))
            call AFBnxa (TNXT, T, idGM (VGRP_VMHW))
            call AFBnxa (TNXT, T, idGM (VGRP_VMHI))
            call AFBnxa (TNXT, T, idGM (VGRP_VMTW))
            call AFBnxa (TNXT, T, idGM (VGRP_VMTA))
            call AFBnxa (TNXT, T, idGM (VGRP_VMTD))
c
            write (ipL, _FORMAT(101)) ITstp, T, TNXT
#           if HAVE_F77_FLUSH
            call FLUSH (ipL)
#           endif
c
            DTI  = TNXT - T
CCC_    * loop break
            if (TNXT.gt.TEND) goto 900
CCC_    * suspend
CCC_    * MTBuvs (Thermodynamics preparation)
CCC_     + thermal conductivity
            if (iErr.eq.0) then
               CONDI  = PMM (PMT_COND)
               CONDIP = PMM (PMT_CONDP)
               call MTBthc
     O             (iErr,
     O              VMTW,
     I              VMTI, CONDI, CONDIP,
     I              MH,   LH,    NZ,  LZ, KZ0)
            else
               call DAtrcU (ipL, iErr, 'R', 'TGV/MTSTHC')
            endif
CCC_     + heat capacity
            if (iErr.eq.0) then
               call MTShcs
     O             (iErr,
     O              VMTW,
     I              VMTI,  PMM,
     I              MH,    LH,   NZ,  LZ, KZ0)
            else
               call DAtrcU (ipL, iErr, 'R', 'TGV/MTSHCS')
            endif
CCC_    * Environment computation
            if (iErr.eq.0) then
               call TGVubc
     O             (iErr,
     O              VMHB,  VBBI,
     M              PTGV,
     I              VXCFG, VMHR, VMHI, VMTI, VBBT,
     I              T,     DTI,  ITGV, PMM,  IMM, WW, IMTI, PMTI,
     I              PBB,   IBB,  WZR,
     I              MH,    LH,   NZ,   LZ,   KZ0,
     I              NZR,   LZR,  KZ0R,
     I              ipKW,  ipL)
            else
               call DAtrcU (ipL, iErr, 'R', 'TGV/TGVUBC')
            endif
CCC_     + basal melting
            call UV3naa
     $          (VMHW, VMHI, VMHB, MH, LH,
     $           VMHW_HSB,   VMHI_frd, VMHB_GH)
            if (iErr.eq.0) then
               call MTBdbm
     O             (iErr,
     M              VMHI, VMHW,
     I              VMTI, VMTW,
     I              WZV,  PMM,  IMM,
     I              MH,   LH,   NZ,   LZ,  KZ0)
            endif
CCC_    * Environment update
            call BBTupd
     O          (iErr,
     M           VBBT,  VBBW,
     I           VBBI,  PBB,  IBB,
     I           WZR,   T,    TBINI, DT,
     I           MH,    LH,   NZR,   LZR,   KZ0R,
     I           ipL)
            call AFBwmp (jedmy, VBBT, idGB(VGRPB_VBBT), TI, IE)
            call AFBwmp (jedmy, VBBI, idGB(VGRPB_VBBI), TI, IE)
CCC_    * Topography
            if (iErr.eq.0) then
               call UV0naa (VMHI, MH, LH, VMHI_oSa, VMHI_oHa, VMHI_oBa)
               call UV0cpa (VMHI, MH, LH, VMHI_nBa, VMHI_oBa)
            else
               call DAtrcU (ipL, iErr, 'R', 'TGV/BBTUPD')
            endif
CCC_    * Vertical velocity
            if (iErr.eq.0) then
               call TGVudi
     O             (iErr,
     O              VMTI, VMHW, VMHI,
     I              VMHB, VXCFG,
     I              T,    DTI,
     I              WW,   WZV,
     I              ITGV, PTGV, PMM,  IMM,  IMTI, PMTI, PBB, IBB,
     I              MH,   LH,   NZ,   LZ,   KZ0,
     I              ipKW, ipL)
            else
               call DAtrcU (ipL, iErr, 'R', 'TGV/TGVUDI')
            endif
CCC_    * MDstpD
            TI = T
            if (DTI.gt.0.0d0) then
CCC_     + output primitives
               call AFBwmp (jedmy, VMTI, idGM (VGRP_VMTI), TI, IE)
c
               call AFBwmp (jedmy, VMHB, idGM (VGRP_VMHB), TI, IE)
               call AFBwmp (jedmy, VMHI, idGM (VGRP_VMHI), TI, IE)
               call AFBwmp (jedmy, VMHW, idGM (VGRP_VMHW), TI, IE)
c
               call AFBwmr
     $             (jedmy,
     $              VMTW, idGM (VGRP_VMTW),
     $              1, VMTW_MAXD, TI, 'VMTWd', IE)
               call AFBwmr
     $             (jedmy,
     $              VMTW, idGM (VGRP_VMTW),
     $              VMTW_MAXD+1, VMTW_MAX, TI, 'VMTWt', IE)
            endif
CCC_     + MTBuvs
CCC_    * MDstpT
CCC_     + MTButp
            if (iErr.eq.0) then
               call MTStgp
     O             (iErr,
     O              KTB,   NHt,
     M              VMHW,  CW,
     I              VMHI,  WW,
     I              KHH,   KHB,
     I              HC,
     I              MH,    LH,  ipCG,  LCG, ipKW,  iMA)
            else
               call DAtrcU (ipL, iErr, 'R', 'TGV/MTSTGP')
            endif
            if (iErr.eq.0) then
               call MTSpjc
     O             (iErr,
     M              VMHW,
     I              VMHI,
     I              DT,
     I              KHH,   KTB,   NHt, MH,    LH)
            else
               call DAtrcU (ipL, iErr, 'R', 'TGV/MTSPJC')
            endif
            if (iErr.eq.0) then
               call MTStcg
     O             (iErr,
     O              VMTW,
     I              VMHW,
     I              KTB,  WZV,
     I              NHt,  LH,   NZ,  LZ, KZ0)
            endif
            if (iErr.eq.0) then
               if (IMM(IMD_WADV).eq. SW_WADV_RAW) then
                  call MTScxs
     O                (iErr,
     M                 VMTW,
     I                 VMTI, VMHW, VMHI, VMHB,
     I                 KTB,  WZV,  PMM,  IMM,
     I                 NHt,  LH,   NZ,   LZ,  KZ0,
     I                 ipL)
               else
                  call MTScxw
     O                (iErr,
     M                 VMTW,
     I                 VMTI, VMHW, VMHI, VMHB,
     I                 KTB,  WZV,  PMM,  IMM,
     I                 NHt,  LH,   NZ,   LZ,  KZ0,
     I                 ipL)
               endif
            else
               call DAtrcU (ipL, iErr, 'R', 'TGV/MTSCXW')
            endif
C           MTScxw option not used
C           MTSdts skipped (no dT/dx dT/dy)
C           VMTW_dTdXa VMTW_dTdYa
            if (iErr.eq.0) then
               call UV0stc(VMTW, MH, LH, NZ, LZ, KZ0, VMTW_dTdXa, 0.0d0)
               call UV0stc(VMTW, MH, LH, NZ, LZ, KZ0, VMTW_dTdYa, 0.0d0)
            endif
CCC_    * MTBupd
            if (iErr.eq.0) then
               call MTBupd
     O             (iErr,
     M              VMTI,  VMTW, VMHI, VMHW,
     I              VMHB,  PMM,  IMM,
     I              WZV,   DT,
     I              KTB,   NHt,
     I              MH,    LH,   NZ,   LZ,   KZ0,
     I              ipL)
            else
               call DAtrcU (ipL, iErr, 'R', 'TGV/MTBUPD')
            endif
CCC_    * MABstp
CCC_     + age integration
            if (iErr.eq.0) then
               call MABstp
     O             (iErr,
     M              CW,   VMTA, VMTD,
     I              KTB,  NHt,
     I              VMTI, VMTW, VMHI, VMHW,
     I              VMHB, OMM,  IMM,  PMM,   T,    DT,
     I              WW,   WZV,
     I              MH,   LH,   NZ,   LZ,    KZ0,
     I              IE,   ipKW, iMA,  ipCG,  LCG,  idGM, ipL)
            else
               call DAtrcU (ipL, iErr, 'R', 'TGV/MABSTP')
            endif
CCC_    * break
            if (iErr.ne.0) goto 900
CCC_    * update (must use the final state of VMI again).
            T     = TNXT
            ITstp = ITstp + 1
            call UV0cpa(VMHI, MH, LH, VMHI_oHa, VMHI_nHa)
         ENDDO
 900     continue
      endif
c
      call AFBrpg (jedmy, ipL)
      call ACCrep (ipL, 0)
c
      return
      END
CCC_* Hauptstimme/Movement
CCC_ & TGVudi  ## dynamics update
      subroutine TGVudi
     O    (iErr,
     M     VMTI, VMHW, VMHI,
     I     VMHB, VXCFG,
     I     T,    DT,
     I     WW,   WZV,
     I     ITGV, PTGV, PMD,  IMD,  IMTI, PMTI, PBB,  IBB,
     I     MH,   LH,   NZ,   LZ,   KZ0,
     I     ipKW, IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
      _INTENT(INOUT,_REALSTD) VMTI (LH, LZ, *)
      _INTENT(INOUT,_REALSTD) VMHW (LH, *)
      _INTENT(INOUT,_REALSTD) VMHI (LH, *)
      _INTENT(IN,   _REALSTD) VMHB (LH, *)
      _INTENT(IN,   _REALSTD) VXCFG(LH, *)
c
      _INTENT(IN, _REALSTD)  T, DT
c
      _INTENT(IN, integer)   ITGV(*)
      _INTENT(IN, _REALSTD)  PTGV(*)
      _INTENT(IN, _REALSTD)  PMD  (*)
      _INTENT(IN, integer)   IMD  (*)
      _INTENT(IN, _REALSTD)  PBB  (*)
      _INTENT(IN, integer)   IBB  (*)
      _INTENT(IN, integer)   IMTI (*)
      _INTENT(IN, _REALSTD)  PMTI (*)
      _INTENT(IN, _REALSTD)  WW   (LH, *)
      _INTENT(IN, _REALSTD)  WZV  (LZ, *)
      _INTENT(IN, integer)   ipKW (IPKW_FULL_DECL)
      _INTENT(IN, integer)   IFPl
c
      integer jz, jzz
      integer jh
      _REALSTD PF
      _REALSTD Dnml
      _REALSTD DnmlP
      _REALSTD F, XP
      _REALSTD ZMS
c
      _REALSTD TNXT
      _REALSTD TDUR, TINC, TDEC, TLST, THST, PHS
      _REALSTD CO
      integer  KSWEV
      integer  KWDH, KWDB
CCC_  - Body
      iErr = 0
      KWDH = VMHW_W1
      KWDB = VMHW_W2
CCC_   . log
#if OPT_VERBOSE
 101  format('UDI:', 1x, F9.1, 1x, F9.1)
      if (COND_N(IFPl)) then
         write (IFPl, 101) T, DT
      else if (COND_S(IFPl)) then
         write (*,    101) T, DT
      endif
#endif /* OPT_VERBOSE */
CCC_   . dH/dt
      KSWEV = ITGV(ITGV_DHPATTERN)
      if (ITGV(ITGV_XFILE_DH).gt.0) then
         call TGVxev
     O       (iErr,
     O        VMHI(1, VMHI_nHa),
     M        PTGV(PTGV_H_VPREV),    PTGV(PTGV_H_VNEXT),
     M        PTGV(PTGV_H_XTPREV),   PTGV(PTGV_H_XTNEXT),
     I        VXCFG(1, VXCFG_HMAX),  VXCFG(1, VXCFG_HMIN),
     I        ITGV(ITGV_XFILE_DH),
     I        KSWEV, XOPR_ADD,
     I        T,    MH,   LH, IFPl)
      else
         TDUR  = PTGV(PTGV_H_DURATION)
         TINC  = PTGV(PTGV_H_TINCR)
         TDEC  = PTGV(PTGV_H_TDECR)
         TLST  = PTGV(PTGV_H_TLSTD)
         THST  = PTGV(PTGV_H_THSTD)
         PHS   = PTGV(PTGV_H_PHASE)
         TNXT  = T + DT
c
         if (KSWEV.eq. SW_DHPAT_EXP_VIALOV) then
            XP = 1.0d0 / (2.0d0 * PMD(PMD_PF) + 2.0d0)
            do jh = 1, MH
               F = VMHB(jh, VMHB_MS) / VXCFG(jh, VXCFG_MSMAX)
               VMHW(jh, KWDH) = VXCFG(jh, VXCFG_HMAX) * (F ** XP)
            enddo
            CO  = 1.0d0 - EXP(- DT / TDUR)
            do jh = 1, MH
               VMHI(jh, VMHI_nHa) =
     $              + VMHI(jh, VMHI_oHa) * (1.0d0 - CO)
     $              + VMHW(jh, KWDH)     * CO
            enddo
         else
            call TGVtev
     O           (iErr,
     O           VMHI(1, VMHI_nHa),
     I           VXCFG(1, VXCFG_HMAX), VXCFG(1, VXCFG_HMIN),
     I           TDUR, TINC, TDEC, TLST, THST, PHS, KSWEV,
     I           TNXT, MH,   LH)
         endif
      endif
      call UV0naa (VMHI, MH, LH, VMHI_nSa, VMHI_nHa, VMHI_nBa)
      do jh = 1, MH
         VMHW(jh, KWDH)
     $        = (VMHI(jh, VMHI_nHa) - VMHI(jh, VMHI_oHa)) / DT
      enddo
      do jh = 1, MH
         VMHW(jh, KWDB)
     $        = (VMHI(jh, VMHI_nBa) - VMHI(jh, VMHI_oBa)) / DT
      enddo
CC  SW_WADV_XKB case
CC      Wadv = -[Zeta dHdt - Mb + div(H int d Zeta u)]
CC           = w - (dbdt + Zeta dHdt)
CCC_   . vertical velocity and gradient
      PF = PTGV(PTGV_WPOWER)
      if (ITGV(ITGV_WTYPE).eq. WTYPE_VIALOV) then
CC       w = acc/(n+1) [(n+2)*(depth-1) - (depth**(n+2)-1)]
CC            + db/dt + Mb
         do jzz = 1, NZ
            jz = KZ0 + jzz - 1
            Dnml  = WZV(jz, VMVZ_cZa)
            DnmlP = Dnml**(PF+2.0d0)
            F = ((PF+2.0d0)*(Dnml-1.0d0) - (DnmlP-1.0d0)) / (PF + 1.0d0)
            do jh = 1, MH
               ZMS = (VMHB(jh, VMHB_MS) + VMHB(jh, VMHB_MB))
     $              - VMHW(jh, KWDH)
               VMTI(jh, jz, VMTI_Wadv)
     $              = (ZMS * F + VMHB(jh, VMHB_MB))
     $              - WZV(jz, VMVZ_Za) * VMHW(jh, KWDH)
            enddo
         enddo
CC       dw/dzeta = - dw/ddepth
CC       dw/ddepth = acc (n+2)/(n+1) [1 - depth**(n+1)]
         do jzz = 1, NZ
            jz = KZ0 + jzz - 1
            Dnml  = WZV(jz, VMVZ_cZa)
            F = ((PF+2.0d0) *(1.0d0 - Dnml**(PF+1.0d0))) / (PF + 1.0d0)
            do jh = 1, MH
               ZMS = (VMHB(jh, VMHB_MS) + VMHB(jh, VMHB_MB))
     $              - VMHW(jh, KWDH)
               VMTI(jh, jz, VMTI_dwdZ) = - ZMS * F
            enddo
         enddo
      else if (ITGV(ITGV_WTYPE).eq. WTYPE_CONST) then
         do jzz = 1, NZ
            jz = KZ0 + jzz - 1
            do jh = 1, MH
               VMTI(jh, jz, VMTI_Wadv) = - VMHB(jh, VMHB_MS)
               VMTI(jh, jz, VMTI_dwdZ) = 0.0d0
            enddo
         enddo
      else
         stop
      endif
      do jzz = 1, NZ
         jz = KZ0 + jzz - 1
         do jh = 1, MH
            VMTI(jh, jz, VMTI_dudZ) = 0.0d0
            VMTI(jh, jz, VMTI_dvdZ) = 0.0d0
         enddo
      enddo
      RETURN
      END
CCC_* Begleitung
CCC_ & TGVubc  ## boundary condition update
      subroutine TGVubc
     O    (iErr,
     O     VMHB,  VBBI,
     M     PTGV,
     I     VXCFG, VMHR,  VMHI, VMTI, VBBT,
     I     T,     DT,
     I     ITGV,  PMD,  IMD,  WW,  IMTI, PMTI,
     I     PBB,   IBB,  WZR,
     I     MH,    LH,   NZ,   LZ,  KZ0,  NZR, LZR, KZ0R,
     I     ipKW,  IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   MH,   LH
      _INTENT(IN, integer)   NZ,   LZ,  KZ0
      _INTENT(IN, integer)   NZR,  LZR, KZ0R
      _INTENT(OUT,_REALSTD)  VMHB (LH, *)
      _INTENT(OUT,_REALSTD)  VBBI (LH, *)
c
      _INTENT(INOUT,_REALSTD)  PTGV(*)
c
      _INTENT(IN, _REALSTD)  VXCFG(LH, *)
      _INTENT(IN, _REALSTD)  VMHI (LH, *)
      _INTENT(IN, _REALSTD)  VMHR (LH, *)
      _INTENT(IN, _REALSTD)  VMTI (LH, LZ, *)
      _INTENT(IN, _REALSTD)  VBBT (LH, LZR, *)
      _INTENT(IN, _REALSTD)  T, DT
c
      _INTENT(IN, _REALSTD)  WZR  (LZR, *)
c
      _INTENT(IN, integer)   ITGV(*)
c
      _INTENT(IN, _REALSTD)  PMD  (*)
      _INTENT(IN, integer)   IMD  (*)
      _INTENT(IN, _REALSTD)  PBB  (*)
      _INTENT(IN, integer)   IBB  (*)
      _INTENT(IN, integer)   IMTI (*)
      _INTENT(IN, _REALSTD)  PMTI (*)
      _INTENT(IN, _REALSTD)  WW   (LH, *)
      _INTENT(IN, integer)   ipKW (IPKW_FULL_DECL)
      _INTENT(IN, integer)   IFPl
c
      _REALSTD GH
      _REALSTD KR, DTDP, DPDZ, DZDZ
      integer jzt
      integer jh
      _REALSTD TDUR, TINC, TDEC, TLST, THST, PHS
      integer  KSWEV
      _REALSTD VBUFMS(2, 2)
      save     VBUFMS
CCC_  - Body
      iErr = 0
CCC_   . log
#if OPT_VERBOSE
 101  format('UBC:', 1x, F9.1, 1x, F9.1)
      if (COND_N(IFPl)) then
         write (IFPl, 101) T, DT
      else if (COND_S(IFPl)) then
         write (*,    101) T, DT
      endif
#endif /* OPT_VERBOSE */
CCC   _   . misc properties
      call UV0sta (VMHB, MH, LH, VMHB_TBI,   0.0d0)
      call UV0sta (VMHB, MH, LH, VMHB_TBFLG, 0.0d0)
CCC_   . surface temperature
c$$$      call UV0sta(VMHB, MH, LH, VMHB_TSI, 210.d0)
      KSWEV = ITGV(ITGV_TSPATTERN)
      if (ITGV(ITGV_XFILE_TS).gt.0) then
         call TGVxev
     O       (iErr,
     O        VMHB(1, VMHB_TSI),
     M        PTGV(PTGV_TS_VPREV),    PTGV(PTGV_TS_VNEXT),
     M        PTGV(PTGV_TS_XTPREV),   PTGV(PTGV_TS_XTNEXT),
     I        VXCFG(1, VXCFG_TSMAX), VXCFG(1, VXCFG_TSMIN),
     I        ITGV(ITGV_XFILE_TS),
     I        KSWEV, XOPR_ADD,
     I        T,    MH,   LH, IFPl)
      else
         TDUR  = PTGV(PTGV_TS_DURATION)
         TINC  = PTGV(PTGV_TS_TINCR)
         TDEC  = PTGV(PTGV_TS_TDECR)
         TLST  = PTGV(PTGV_TS_TLSTD)
         THST  = PTGV(PTGV_TS_THSTD)
         PHS   = PTGV(PTGV_TS_PHASE)
         call TGVtev
     O       (iErr,
     O        VMHB(1, VMHB_TSI),
     I        VXCFG(1, VXCFG_TSMAX), VXCFG(1, VXCFG_TSMIN),
     I        TDUR, TINC, TDEC, TLST, THST, PHS, KSWEV,
     I        T,    MH,   LH)
      endif
CCC_   . surface mass balance
      KSWEV = ITGV(ITGV_MSPATTERN)
      if (ITGV(ITGV_XFILE_MS).gt.0) then
         call TGVxev
     O       (iErr,
     O        VMHB(1, VMHB_MS),
     M        PTGV(PTGV_S_VPREV),    PTGV(PTGV_S_VNEXT),
     M        PTGV(PTGV_S_XTPREV),   PTGV(PTGV_S_XTNEXT),
     I        VXCFG(1, VXCFG_MSMAX), VXCFG(1, VXCFG_MSMIN),
     I        ITGV(ITGV_XFILE_MS),
     I        KSWEV, XOPR_MUL,
     I        T,    MH,   LH, IFPl)
      else
         TDUR  = PTGV(PTGV_S_DURATION)
         TINC  = PTGV(PTGV_S_TINCR)
         TDEC  = PTGV(PTGV_S_TDECR)
         TLST  = PTGV(PTGV_S_TLSTD)
         THST  = PTGV(PTGV_S_THSTD)
         PHS   = PTGV(PTGV_S_PHASE)
         call TGVtev
     O       (iErr,
     O        VMHB(1, VMHB_MS),
     I        VXCFG(1, VXCFG_MSMAX), VXCFG(1, VXCFG_MSMIN),
     I        TDUR, TINC, TDEC, TLST, THST, PHS, KSWEV,
     I        T,    MH,   LH)
      endif
c$$$      write(*, *) 'MS', VMHB(:, VMHB_MS)
CCC_   . basal mass balance
      KSWEV = ITGV(ITGV_MBPATTERN)
      if (ITGV(ITGV_XFILE_MB).gt.0) then
         call TGVxev
     O       (iErr,
     O        VMHB(1, VMHB_MB),
     M        PTGV(PTGV_B_VPREV),    PTGV(PTGV_B_VNEXT),
     M        PTGV(PTGV_B_XTPREV),   PTGV(PTGV_B_XTNEXT),
     I        VXCFG(1, VXCFG_MBMAX), VXCFG(1, VXCFG_MBMIN),
     I        ITGV(ITGV_XFILE_MB),
     I        KSWEV, XOPR_ADD,
     I        T,    MH,   LH, IFPl)
      else
         TDUR  = PTGV(PTGV_B_DURATION)
         TINC  = PTGV(PTGV_B_TINCR)
         TDEC  = PTGV(PTGV_B_TDECR)
         TLST  = PTGV(PTGV_B_TLSTD)
         THST  = PTGV(PTGV_B_THSTD)
         PHS   = PTGV(PTGV_B_PHASE)
         call TGVtev
     O       (iErr,
     O        VMHB(1, VMHB_MB),
     I        VXCFG(1, VXCFG_MBMAX), VXCFG(1, VXCFG_MBMIN),
     I        TDUR, TINC, TDEC, TLST, THST, PHS, KSWEV,
     I        T,    MH,   LH)
      endif
CCC_   . geothermal heat flux
c$$$      GH = -42.0d-3 * 31556926.d0
c$$$      call UV0sta (VMHB, MH, LH, VMHB_GH,  GH)
C     G = k dT/dz = k dT/dp dP/dZ dZ/dz
      KR = PBB(PBB_CONDR)
      jzt = KZ0R + NZR - 1
      do jh = 1, MH
         DZDZ  = 1.0d0 / VBBI (jh, VBBI_HR)
         DPDZ  = WZR (jzt-1, VBBZ_dXa)
         DTDP  = WZR (jzt-1, VBBZ_dWPb) * VBBT(jh, jzt,   VBBT_T)
     $         + WZR (jzt-1, VBBZ_dWMb) * VBBT(jh, jzt-1, VBBT_T)
         VMHB(jh, VMHB_GH) = KR * DTDP * DPDZ * DZDZ
      enddo
c$$$      GH = -42.0d-3 * 31556926.d0
c$$$      call UV0sta (VMHB, MH, LH, VMHB_GH,  GH)
CCC_   . rock bc
c$$$      GH = -42.0d-3 * 31556926.d0
c$$$      call UV0sta (VBBI, MH, LH, VBBI_GH,  GH)
      do jh = 1, MH
         VBBI(jh, VBBI_TU) = VMTI(jh, KZ0, VMTI_T)
      enddo
c
c$$$      write(*, *) 'MS', 9, VMHB(:, VMHB_MS)
      RETURN
      END
CCC_ + Begl./Climate Ts
CCC_ + Begl./Climate Ms
CCC_ + Begl./Bedrock Heat flux
CCC_ + TGVenv - experiment configuration
      subroutine TGVenv
     O    (iErr,
     O     ITGV, PTGV,
     I     PMD,  TINI,
     I     ipP,  ipC, ipL)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)  iErr
      _INTENT(OUT,integer)  ITGV(*)
      _INTENT(OUT,_REALSTD) PTGV(*)
      _INTENT(IN, _REALSTD) PMD (*)
      _INTENT(IN, _REALSTD) TINI
      _INTENT(IN, integer)  ipP, ipC, ipL
CCC_   . interior
      integer  IOS
      logical  OEOF
CCC_   . Configuration
      integer  KWTYP
      _REALSTD POWW
      namelist /NITGVW/ KWTYP,  POWW
CCC_  - Body
      iErr = 0
c
      POWW  = PMD(PMD_PF)
      KWTYP = WTYPE_VIALOV
c
      if (ipP.ge.0) then
         call UUrwnd (iErr, ipP)
         READ(ipP, NITGVW, IOSTAT=IOS)
      else if (ipP.eq.-1) then
         READ(*,   NITGVW, IOSTAT=IOS)
      else
         IOS = 0
      endif
      if (IOS.ne.0) then
         call UUieof(OEOF, IOS)
         if (OEOF) IOS = 0
      endif
c
      if (COND_N(ipC)) then
         WRITE(ipC, NITGVW, IOSTAT=iErr)
      else if (COND_S(ipC)) then
         WRITE(*,   NITGVW, IOSTAT=iErr)
      endif
CCC_   . Packing
      PTGV(PTGV_WPOWER)       = POWW
      ITGV(ITGV_WTYPE)        = KWTYP
CCC_   . other environments
      if (ierr.eq.0) then
         call TGVecf
     O       (iErr, ITGV, PTGV,
     I        ITGV_MSPATTERN, ITGV_XFILE_MS,
     I        PTGV_S_TINCR,   PTGV_S_TDECR,    PTGV_S_THSTD,
     I        PTGV_S_TLSTD,   PTGV_S_DURATION, PTGV_S_PHASE,
     I        PTGV_S_XTPREV,  PTGV_S_XTNEXT,
     I        'MS',  TINI,  ipP, ipC, ipL)
      endif
      if (ierr.eq.0) then
         call TGVecf
     O       (iErr, ITGV, PTGV,
     I        ITGV_MBPATTERN, ITGV_XFILE_MB,
     I        PTGV_B_TINCR,   PTGV_B_TDECR,    PTGV_B_THSTD,
     I        PTGV_B_TLSTD,   PTGV_B_DURATION, PTGV_B_PHASE,
     I        PTGV_B_XTPREV,  PTGV_B_XTNEXT,
     I        'MB',  TINI,  ipP, ipC, ipL)
      endif
      if (ierr.eq.0) then
         call TGVecf
     O       (iErr, ITGV, PTGV,
     I        ITGV_DHPATTERN, ITGV_XFILE_DH,
     I        PTGV_H_TINCR,   PTGV_H_TDECR,    PTGV_H_THSTD,
     I        PTGV_H_TLSTD,   PTGV_H_DURATION, PTGV_H_PHASE,
     I        PTGV_H_XTPREV,  PTGV_H_XTNEXT,
     I        'DH',  TINI,  ipP, ipC, ipL)
      endif
      if (ierr.eq.0) then
         call TGVecf
     O       (iErr, ITGV, PTGV,
     I        ITGV_TSPATTERN, ITGV_XFILE_TS,
     I        PTGV_TS_TINCR,   PTGV_TS_TDECR,    PTGV_TS_THSTD,
     I        PTGV_TS_TLSTD,   PTGV_TS_DURATION, PTGV_TS_PHASE,
     I        PTGV_TS_XTPREV,  PTGV_TS_XTNEXT,
     I        'TS',  TINI,  ipP, ipC, ipL)
      endif
c
      if (IOS.ne.0) iErr = IOS
      call DAtrcU (ipL, iErr, 'R', 'TGVENV')
c
      return
      END
CCC_ + TGVecf - configuration bc general
      subroutine TGVecf
     O    (iErr,
     O     ITGV,  PTGV,
     I     KPAT,  KFILEU,
     I     KINCR, KDECR, KHSTD, KLSTD, KDUR, KPHASE,
     I     KTPREV,KTNEXT,
     I     TagBC, TINI,  ipP, ipC, ipL)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   ITGV(*)
      _INTENT(OUT,_REALSTD)  PTGV(*)
      _INTENT(IN, _REALSTD)  TINI
      _INTENT(IN, character) TagBC*(*)
      _INTENT(IN, integer)   ipP, ipC, ipL
c
      _INTENT(IN, integer) KPAT,  KFILEU
      _INTENT(IN, integer) KINCR, KDECR, KHSTD, KLSTD, KDUR, KPHASE
      _INTENT(IN, integer) KTPREV,KTNEXT
c
      integer   KSWPAT
      _REALSTD  TDECR, TINCR, TLSTD, THSTD, TDUR, TPHASE, TXINI
      character Tag*(16)
      character FILE*(OPT_FILENAME_MAX)
c
      integer   jfp, LR
c
      namelist /NITGVC/
     $     TAG,  KSWPAT, TDECR, TINCR, TLSTD, THSTD, TPHASE,
     $     FILE, TXINI
c
      iErr = 0
      if (ipP.ge.0) call UUrwnd (iErr, ipP)
      do
         KSWPAT = SW_BCPAT_STEP
         TDECR  = 0.0d0
         TINCR  = 0.0d0
         TLSTD  = 0.0d0
         THSTD  = 0.0d0
         TPHASE = 0.0d0
         FILE   = ' '
         TAG    = ' '
         TXINI  = TINI
         if (iErr.ne.0) goto 100
         if (ipP.ge.0) then
            READ(ipP, NITGVC, IOSTAT=iErr)
         else if (ipP.eq.-1) then
            READ(*,   NITGVC, IOSTAT=iErr)
         else
            iErr = -1
         endif
         if (iErr.ne.0) goto 100
         if (Tag.eq.TagBC) goto 100
      enddo
 100  continue
      if (iErr.ne.0) then
         KSWPAT = SW_BCPAT_STEP
         TDECR  = 0.0d0
         TINCR  = 0.0d0
         TLSTD  = 0.0d0
         THSTD  = 0.0d0
         TPHASE = 0.0d0
         FILE   = ' '
         TXINI  = TINI
      endif

      if (COND_N(ipC)) then
         WRITE(ipC, NITGVC, IOSTAT=iErr)
      else if (COND_S(ipC)) then
         WRITE(*,   NITGVC, IOSTAT=iErr)
      endif

      if (TDECR.eq.0.0d0 .and. TINCR.eq.0.0d0
     $     .and. TLSTD.eq.0.0d0 .and. THSTD.eq.0.0d0) then
         THSTD = 1.0d0
      endif
      TDUR = THSTD + TDECR + TLSTD + TINCR

      ITGV(KPAT)   = KSWPAT
      PTGV(KINCR)  = TINCR
      PTGV(KDECR)  = TDECR
      PTGV(KHSTD)  = THSTD
      PTGV(KLSTD)  = TLSTD
      PTGV(KDUR)   = TDUR
      PTGV(KPHASE) = TPHASE
      if (KTPREV.gt.0) PTGV(KTPREV) = TXINI
      if (KTNEXT.gt.0) PTGV(KTNEXT) = TXINI

      if (KFILEU.gt.0) then
         ITGV(KFILEU) = -1
         if (FILE.eq.' ') then
            continue
         else
            if (iErr.eq.0) call UUMCnu (iErr, jfp)
            if (iErr.eq.0) then
               LR = -1
               call UUopen (iErr, jfp, FILE, LR, 'F', 'O', 'R', ' ')
            endif
            if (iErr.eq.0) ITGV(KFILEU) = jfp
         endif
      else if (FILE.ne.' ') then
 109     format('external file disabled for ', A, ':', A)
         write(ipL, 109) Trim(Tag), Trim(FILE)
         iErr = -1
      endif
      call DAtrcU (ipL, iErr, 'R', 'TGVECF')
      return
      end
CCC_ + TGVcfg  ## initialization
      subroutine TGVcfg
     O    (iErr,
     O     ITGV,PTGV,
     I     PMD,
     I     ipP, ipC, ipL)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)  iErr
      _INTENT(OUT,integer)  ITGV(*)
      _INTENT(OUT,_REALSTD) PTGV(*)
      _INTENT(IN, _REALSTD) PMD (*)
      _INTENT(IN, integer)  ipP, ipC, ipL
CCC_   . interior
      integer  IOS
      logical  OEOF
CCC_   . Configuration
      integer  KSWMSP, KSWMBP, KSWDHP, KSWTSP
      integer  KWTYP
      _REALSTD TDECRS, TINCRS, TLSTDS, THSTDS, TDURS, TPHSS
      _REALSTD TDECRB, TINCRB, TLSTDB, THSTDB, TDURB, TPHSB
      _REALSTD TDECRH, TINCRH, TLSTDH, THSTDH, TDURH, TPHSH
      _REALSTD TDECRT, TINCRT, TLSTDT, THSTDT, TDURT, TPHST
      _REALSTD POWW
      character FILEMS*(OPT_FILENAME_MAX)
      character FILETS*(OPT_FILENAME_MAX)
      character FILEDH*(OPT_FILENAME_MAX)
      namelist /NITGVB/
     $     KSWMSP, TDECRS, TINCRS, TLSTDS, THSTDS, TPHSS,
     $     KSWMBP, TDECRB, TINCRB, TLSTDB, THSTDB, TPHSB,
     $     KSWDHP, TDECRH, TINCRH, TLSTDH, THSTDH, TPHSH,
     $     KSWTSP, TDECRT, TINCRT, TLSTDT, THSTDT, TPHST,
     $     KWTYP,  POWW,   FILEMS, FILETS, FILEDH
      integer jfpXT, LR
CCC_  - Body
      iErr = 0
c
      KSWMSP = SW_BCPAT_STEP
      TDECRS = 0.0d0
      TINCRS = 0.0d0
      TLSTDS = 0.0d0
      THSTDS = 0.0d0
      TPHSS  = 0.0d0

      KSWMBP = SW_BCPAT_STEP
      TDECRB = 0.0d0
      TINCRB = 0.0d0
      TLSTDB = 0.0d0
      THSTDB = 0.0d0
      TPHSB  = 0.0d0

      KSWDHP = SW_BCPAT_STEP
      TDECRH = 0.0d0
      TINCRH = 0.0d0
      TLSTDH = 0.0d0
      THSTDH = 0.0d0
      TPHSH  = 0.0d0

      KSWTSP = SW_BCPAT_STEP
      TDECRT = 0.0d0
      TINCRT = 0.0d0
      TLSTDT = 0.0d0
      THSTDT = 0.0d0
      TPHST  = 0.0d0

      POWW  = PMD(PMD_PF)
      KWTYP = WTYPE_VIALOV
c
      FILEMS = ' '
      FILETS = ' '
      FILEDH = ' '
c
      if (ipP.ge.0) then
         call UUrwnd (iErr, ipP)
         READ(ipP, NITGVB, IOSTAT=IOS)
      else if (ipP.eq.-1) then
         READ(*,   NITGVB, IOSTAT=IOS)
      else
         IOS = 0
      endif
      if (IOS.ne.0) then
         call UUieof(OEOF, IOS)
         if (OEOF) IOS = 0
      endif
c
      if (COND_N(ipC)) then
         WRITE(ipC, NITGVB, IOSTAT=iErr)
      else if (COND_S(ipC)) then
         WRITE(*,   NITGVB, IOSTAT=iErr)
      endif
CCC_   . Packing
      if (TDECRS.eq.0.0d0 .and. TINCRS.eq.0.0d0
     $     .and. TLSTDS.eq.0.0d0 .and. THSTDS.eq.0.0d0) then
         THSTDS = 1.0d0
      endif
      TDURS = THSTDS + TDECRS + TLSTDS + TINCRS
      if (TDECRB.eq.0.0d0 .and. TINCRB.eq.0.0d0
     $     .and. TLSTDB.eq.0.0d0 .and. THSTDB.eq.0.0d0) then
         THSTDB = 1.0d0
      endif
      TDURB = THSTDB + TDECRB + TLSTDB + TINCRB
      if (TDECRH.eq.0.0d0 .and. TINCRH.eq.0.0d0
     $     .and. TLSTDH.eq.0.0d0 .and. THSTDH.eq.0.0d0) then
         THSTDH = 1.0d0
      endif
      TDURH = THSTDH + TDECRH + TLSTDH + TINCRH
      if (TDECRT.eq.0.0d0 .and. TINCRT.eq.0.0d0
     $     .and. TLSTDT.eq.0.0d0 .and. THSTDT.eq.0.0d0) then
         THSTDT = 1.0d0
      endif
      TDURT = THSTDT + TDECRT + TLSTDT + TINCRT
c
      ITGV(ITGV_MSPATTERN)    = KSWMSP
      PTGV(PTGV_S_TINCR)      = TINCRS
      PTGV(PTGV_S_TDECR)      = TDECRS
      PTGV(PTGV_S_THSTD)      = THSTDS
      PTGV(PTGV_S_TLSTD)      = TLSTDS
      PTGV(PTGV_S_DURATION)   = TDURS
      PTGV(PTGV_S_PHASE)      = TPHSS
      ITGV(ITGV_MBPATTERN)    = KSWMBP
      PTGV(PTGV_B_TINCR)      = TINCRB
      PTGV(PTGV_B_TDECR)      = TDECRB
      PTGV(PTGV_B_THSTD)      = THSTDB
      PTGV(PTGV_B_TLSTD)      = TLSTDB
      PTGV(PTGV_B_DURATION)   = TDURB
      PTGV(PTGV_B_PHASE)      = TPHSB
      ITGV(ITGV_DHPATTERN)    = KSWDHP
      PTGV(PTGV_H_TINCR)      = TINCRH
      PTGV(PTGV_H_TDECR)      = TDECRH
      PTGV(PTGV_H_THSTD)      = THSTDH
      PTGV(PTGV_H_TLSTD)      = TLSTDH
      PTGV(PTGV_H_DURATION)   = TDURH
      PTGV(PTGV_H_PHASE)      = TPHSH
      ITGV(ITGV_TSPATTERN)   = KSWTSP
      PTGV(PTGV_TS_TINCR)     = TINCRT
      PTGV(PTGV_TS_TDECR)     = TDECRT
      PTGV(PTGV_TS_THSTD)     = THSTDT
      PTGV(PTGV_TS_TLSTD)     = TLSTDT
      PTGV(PTGV_TS_DURATION)  = TDURT
      PTGV(PTGV_TS_PHASE)     = TPHST
      PTGV(PTGV_WPOWER)       = POWW
      ITGV(ITGV_WTYPE)        = KWTYP
c
      ITGV(ITGV_XFILE_MS) = -1
      if (FILEMS.eq.' ') then
         continue
      else
         if (iErr.eq.0) call UUMCnu (iErr, jfpXT)
         if (iErr.eq.0) then
            LR = -1
            call UUopen (iErr, jfpXT, FILEMS, LR, 'F', 'O', 'R', ' ')
         endif
         if (iErr.eq.0) ITGV(ITGV_XFILE_MS) = jfpXT
      endif
      ITGV(ITGV_XFILE_TS) = -1
      if (FILETS.eq.' ') then
         continue
      else
         if (iErr.eq.0) call UUMCnu (iErr, jfpXT)
         if (iErr.eq.0) then
            LR = -1
            call UUopen (iErr, jfpXT, FILETS, LR, 'F', 'O', 'R', ' ')
         endif
         if (iErr.eq.0) ITGV(ITGV_XFILE_TS) = jfpXT
      endif
      ITGV(ITGV_XFILE_DH) = -1
      if (FILEDH.eq.' ') then
         continue
      else
         if (iErr.eq.0) call UUMCnu (iErr, jfpXT)
         if (iErr.eq.0) then
            LR = -1
            call UUopen (iErr, jfpXT, FILEDH, LR, 'F', 'O', 'R', ' ')
         endif
         if (iErr.eq.0) ITGV(ITGV_XFILE_DH) = jfpXT
      endif
c
      if (iErr.eq.0) then
         if (IOS.ne.0) iErr = IOS
      endif
      call DAtrcU (ipL, iErr, 'R', 'TGVCFG')
c
      return
      END
CCC_ & TGVrgc  ## Set VXCFG attributes
      subroutine TGVrgc
     O    (iErr, idVX,
     I     icF,  MH, LH, CSW, CLS, CRT, ipFI, IE, iMA)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   idVX(*)
      _INTENT(IN, integer)   icF
      _INTENT(IN, integer)   MH,  LH
      _INTENT(IN, character) CSW*(*)
      _INTENT(IN, character) CLS*(*), CRT*(*)
      _INTENT(IN, integer)   ipFI(*)
      _INTENT(IN, integer)   IE  (*)
      _INTENT(IN, integer)   iMA (*)
c
      integer jedmy, jcdmy
      integer icG (4)
      integer ipL
      integer jg
CCC_  - Body
      iErr = 0
c
      call AFUqip (ipL, 'L', ipFI)
      call ACCrfI (jedmy, jcdmy, icG, icF, -1, 'H', ipL)
c
      jg = -1
      call AFBrgd
     O    (iErr,
     O     jg,
     I     'VXCFG', MH,  LH,  0, 0,  VXCFG_MAX, icG (1),
     I     CSW,     CLS, CRT, ipFI,  iMA)
c
      call AFBrgi(iErr, jg, VXCFG_MSMAX,  icG (1), 'msmax')
      call AFBrgi(iErr, jg, VXCFG_MSMIN,  icG (1), 'msmin')
      call AFBrgi(iErr, jg, VXCFG_MBMAX,  icG (1), 'mbmax')
      call AFBrgi(iErr, jg, VXCFG_MBMIN,  icG (1), 'mbmin')
      call AFBrgi(iErr, jg, VXCFG_HMAX,   icG (1), 'hmax')
      call AFBrgi(iErr, jg, VXCFG_HMIN,   icG (1), 'hmin')
      call AFBrgi(iErr, jg, VXCFG_TSMAX,  icG (1), 'Tsmax')
      call AFBrgi(iErr, jg, VXCFG_TSMIN,  icG (1), 'Tsmin')
c
      if (iErr.eq.0) call AFBgmf(iErr, jg, ' ', ' ', IE, ipFI)
      if (iErr.ne.0) jg = -1
      idVX(VGRPX_VXCFG) = jg
c
      RETURN
      END
CCC_ & TGVtev  ## time-evolution
      subroutine TGVtev
     O    (iErr,
     O     VX,
     I     VVU,  VVL,
     I     TDUR, TINC, TDEC, TLST, THST, PHS, KSWEV,
     I     T,    MH,   LH)
      implicit none
      _INTENT(OUT,integer)  iErr
      _INTENT(IN, integer)  MH, LH
      _INTENT(OUT,_REALSTD) VX(*)
      _INTENT(IN, _REALSTD) VVU(*)
      _INTENT(IN, _REALSTD) VVL(*)
      _INTENT(IN, _REALSTD) TDUR, PHS
      _INTENT(IN, _REALSTD) TINC, TDEC, TLST, THST
      _INTENT(IN, _REALSTD) T
      _INTENT(IN, integer)  KSWEV
c
      _REALSTD TK10, TK21, TK32, TK43
      _REALSTD TK20, TK42, TK30
      _REALSTD TMDL, TCH
      _REALSTD PI4,  CO,   CM
      _REALSTD ZU,   ZL
      integer  jh
c
      iErr = 0
c     0....1....2....3....4(0)
c      hstd decr lstd incr
      TK20 = THST + TDEC
      TK30 = THST + TDEC + TLST
      TK42 = TDUR - TK20
      TK10 = THST
      TK21 = TDEC
      TK32 = TLST
      TK43 = TINC
      TMDL = MOD(T + (1.0d0 + PHS) * TDUR, TDUR)
      if (KSWEV.eq. SW_BCPAT_STEP) then
         if (TMDL.lt.TK20) then
            do jh = 1, MH
               VX(jh) = VVU(jh)
            enddo
         else
            do jh = 1, MH
               VX(jh) = VVL(jh)
            enddo
         endif
      else if (KSWEV.eq. SW_BCPAT_COS) then
         pi4 = atan2(1.0d0, 1.0d0)
         if (TMDL.lt.TK20) then
            TCH = MAX(0.0d0, TMDL - TK10)
            CO = COS(((TCH / TK21) * 4.0d0) * PI4)
            do jh = 1, MH
               VX(jh) = (VVU(jh) + VVL(jh)) * 0.5d0
     $                + ((VVU(jh) - VVL(jh)) * 0.5d0) * CO
            enddo
         else
            TCH = MIN(TK43, TDUR - TMDL)
            CO  = COS(((TCH / TK43) * 4.0d0) * PI4)
            do jh = 1, MH
               VX(jh) = (VVU(jh) + VVL(jh)) * 0.5d0
     $                + ((VVU(jh) - VVL(jh)) * 0.5d0) * CO
            enddo
         endif
      else if (KSWEV.eq. SW_BCPAT_LINEAR) then
         if (TMDL.lt.TK20) then
            TCH = MAX(0.0d0, TMDL - TK10)
            CO  = TCH / TK21
            do jh = 1, MH
               VX(jh) = VVU(jh) * (1.0d0 - CO) + VVL(jh) * CO
            enddo
         else
            TCH = MAX(0.0d0, TMDL - TK30)
            CO  = TCH / TK43
            do jh = 1, MH
               VX(jh) = VVL(jh) * (1.0d0 - CO) + VVU(jh) * CO
            enddo
         endif
      else if (KSWEV.eq. SW_BCPAT_EXP) then
         if (TMDL.ge.TK10.and.TMDL.lt.TK30) then
            TCH = TMDL - TK10
            CO  = 1.0d0 - EXP(- TCH / TK21)
            CM  = 1.0d0 - EXP(- (TK43+TK10) / TK43)
            do jh = 1, MH
               ZU     = VVL(jh) * (1.0d0 - CM) + VVU(jh) * CM
               VX(jh) = MIN(ZU,VVU(jh) * (1.0d0 - CO) + VVL(jh) * CO)
            enddo
         else
            if (TMDL.lt.TK10) then
               TCH = TK43 + TMDL
            else
               TCH = TMDL - TK30
            endif
            CO  = 1.0d0 - EXP (- TCH / TK43)
            CM  = 1.0d0 - EXP(- (TK21+TK32) / TK21)
            do jh = 1, MH
               ZL     = VVU(jh) * (1.0d0 - CM) + VVL(jh) * CM
               VX(jh) = MAX(ZL,VVL(jh) * (1.0d0 - CO) + VVU(jh) * CO)
            enddo
         endif
      else if (KSWEV.eq. SW_BCPAT_DEF) then
         do jh = 1, MH
            VX(jh) = VVU(jh)
         enddo
      else
         iErr = -1
         write(*, *) 'INVALID SWTICH KSWEV = ', KSWEV
      endif
      RETURN
      END
CCC_ & TGVxev  ## time-evolution (external file)
      subroutine TGVxev
     O    (iErr,
     O     VX,
     M     VPREV, VNEXT,
     M     TPREV, TNEXT,
     I     VVU,   VVL,
     I     jfpU,
     I     KSWEV, KOPR,
     I     T,     MH,     LH, IFPl)
      implicit none
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  MH, LH
      _INTENT(OUT,  _REALSTD) VX(*)
      _INTENT(INOUT,_REALSTD) VPREV, VNEXT
      _INTENT(INOUT,_REALSTD) TPREV, TNEXT
      _INTENT(IN, _REALSTD) VVU(*)
      _INTENT(IN, _REALSTD) VVL(*)
      _INTENT(IN, _REALSTD) T
      _INTENT(IN, integer)  KSWEV
      _INTENT(IN, integer)  jfpU
      _INTENT(IN, integer)  KOPR
      _INTENT(IN, integer)  IFPl
c
      _REALSTD TF, DF
      _REALSTD WT
c
      integer  jh
c
      iErr = 0 * KSWEV
      do
         if (T.ge.TPREV.and.T.lt.TNEXT) goto 100
         VPREV = VNEXT
         TPREV = TNEXT
         read(UNIT=jfpU, FMT=*, IOSTAT=ierr) TF, DF
         VNEXT = DF
         TNEXT = TF
         if (iErr.ne.0) goto 100
      enddo
 100  continue
c$$$      if (iErr.ne.0) then
c$$$         WT = VPREV
c$$$         ierr = 0
c$$$      else if (KSWEV .eq. SW_BCPAT_XFILE) then
c$$$         WT = VPREV
c$$$      else
c$$$         WT = VPREV
c$$$      endif
      WT = VPREV
      ierr = 0
 101  format('XEV: ', F9.1, 1x, F9.3, 2(1x, E9.3), 2(1x, F9.1))
      if (COND_N(ifpl)) then
         write(ifpl,101) T, WT, VPREV, VNEXT, TPREV, TNEXT
      else if (COND_S(ifpl)) then
         write(*,   101) T, WT, VPREV, VNEXT, TPREV, TNEXT
      endif
      if (KOPR.eq.XOPR_MUL) then
         do jh = 1, MH
            VX(jh) = VVU(jh) * WT
         enddo
      else
         do jh = 1, MH
            VX(jh) = VVU(jh) + WT
         enddo
      endif
      RETURN
      END
CCC_& IcIESa  ## Announcement
      subroutine IcIESa (STRA, STRB, IOP)
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
CCC_* Obsolete
CCC_ + begin
#if 0 /* obsolete */
CCC_ + end
#endif /* 0 obsolete */
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
