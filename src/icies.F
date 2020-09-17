C icies.F --- IcIES driver
C Author: SAITO Fuyuki
C Created: Nov 10 2019
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2020/09/17 06:51:32 fuyuki icies.F>'
#define _FNAME 'icies.F'
#define _REV   'Snoopy0.9'
CCC_! MANIFESTO
C
C Copyright (C) 2019--2020
C           Japan Agency for Marine-Earth Science and Technology,
C           Ayako ABE-OUCHI
C
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
CCC_* Common macros
#include "ofdlct.h"   /* fortran dialect */
#include "ofnstd.h"
#include "ologfm.h"

#include "odevid.h"
#include "TreeID"
#ifndef   GIT_INFOs
#  define GIT_INFOs 'none'
#endif
CCC_ + Switches
#ifndef   OPT_VERBOSE
#  define OPT_VERBOSE 0
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
CCC_@ IcIES  ## IcIES driver
      program IcIES
CCC_ + Declaration
      implicit none
      integer iErr
      integer ipA (LOG_CHANNEL_MAX)
      integer iMA (MAX_MPI_ATTR)
CCC_ + Body
      call DDxidP(iErr, GIT_INFOs)
c$$$      call DDcapo
c$$$     O    (iErr,
c$$$     I     2, ' ', 'O', _FNAME, -1)
      call DDsmpl(iErr)
c
      if (iErr.eq.0) then
         call DLCmng (ipA, 't')
         call DVHrgC (iErr, 'V', ' ', ' ', ipA)
      endif
c
      if (iErr.eq.0) then
         call DMAtma (iMA)
         call IcIESc (iErr, ipA, iMA)
      endif
      call DevFin (iErr)
      STOP
      END
CCC_& IcIESc  ## IcIES conductor
      SUBROUTINE IcIESc (iErr, ipA, iMA)
CCC_ + Macros
#define ROOT_ID 'ID'

#ifndef   OPT_ID_LHP_MAX
#  define OPT_ID_LHP_MAX 8092
#endif
#ifndef   OPT_ID_LHG_MAX
#  define OPT_ID_LHG_MAX 8091
#endif
#ifndef   OPT_ID_LVZ_MAX
#  define OPT_ID_LVZ_MAX 128
#endif
#ifndef   OPT_ID_LVP_MAX
#  define OPT_ID_LVP_MAX OPT_ID_LHP_MAX * OPT_ID_LVZ_MAX
#endif

#include "oarpea.h"
#include "oarpkw.h"   /* operation id in arpeggio/kiwi */
#include "movement/movement.h" /* movement definitions */
CCC_ + Declaration
      implicit none
      _INTENT(OUT,integer)  iErr
      _INTENT(IN, integer)  ipA (*)
      _INTENT(IN, integer)  iMA (*)
CCC_  - Domain size limit
      integer    LHPref
      parameter (LHPref=OPT_ID_LHP_MAX)
      integer    LHGref
      parameter (LHGref=OPT_ID_LHG_MAX)
      integer    LTPref
      parameter (LTPref=OPT_ID_LVP_MAX)
      integer    LZref
      parameter (LZref=OPT_ID_LVZ_MAX)
CCC_  - Thema/Movement
CCC_   . work common
      integer    LVMW
      parameter (LVMW=LHPref  * VMW_MAX)
      _REALSTD   VMW  (LVMW)
      integer    LVMTW
      parameter (LVMTW=LTPref * VMTW_MAX)
      _REALSTD   VMTW (LVMTW)
CCC_   . bcg solution/right/intermediate
      _REALSTD   XS   (LHPref * VMSX_MAX * BCGW_MAX)
      _REALSTD   XI   (LHPref * BCGW_MAX)
CCC_   . field common
      _REALSTD   VMHI (LHPref * VMHI_MAX)
      _REALSTD   VMHW (LHPref * VMHW_MAX)
c
      _REALSTD   VMI  (LHPref * VMI_MAX)
      _REALSTD   VMHB (LHPref * VMHB_MAX)
      _REALSTD   VMHR (LHPref * VMHR_MAX)
      _REALSTD   VMC  (LHPref * VMC_MAX)
CCC_   . thickness integration
      _REALSTD   QM   (LHPref * VMQQ_MAX)
      _REALSTD   VMID (LHPref * VMID_MAX)
CCC_   . SSA solver
      _REALSTD   VMSC (LHPref * VMSC_MAX)
      _REALSTD   VMSV (LHPref * VMSV_MAX)
      _REALSTD   VMSE (LHPref * VMSE_MAX)
CCC_   . 3d velocity
      _REALSTD   VMTI (LTPref * VMTI_MAX)
CCC_   . conversion table
      integer    KTB  (LHPref, 2)
CCC_   . integration weights
      integer    NTH
      parameter (NTH=2)
      _REALSTD   GG  (LZref * 4 * (NTH + 1) * (NTH + 1))
CCC_   . kiwi weights
      integer    LKW
      parameter (LKW=90)
      _REALSTD   WW (LHPref * LKW)
CCC_   . vertical geometry
      _REALSTD   WZV (LZref * VMVZ_MAX)
CCC_   . work
      integer    LCK
      parameter (LCK=LZref + 16)
      _REALSTD   CW (LHPref * LCK)
      _REALSTD   GW (LHGref)
CCC_   . Parameters
      logical    OMM (OMM_MAX)
      integer    IMM (IMM_MAX)
      _REALSTD   PMM (PMM_MAX)
CCC_  - Table
      character  CR*8
      data       CR /ROOT_ID/
      integer    LIE
      parameter (LIE=(LHPref * 10))
      integer    IE   (LIE)
      integer    ipKW (IPKW_FULL_DECL)
CCC_   . global/private stencils
      integer    LNR
      parameter (LNR=256)
      integer    KSglb (LNR * 2)
      integer    LTBL
      parameter (LTBL=LHPref)
      integer    kDTA (LTBL, 3)
CCC_   . clone group
      integer    LCG
      parameter (LCG=KWCG_DECL(CGRP_MEM_MAX))
      integer    ipCG (LCG, CGRP_MAX)
CCC_   . Interior
      integer    MH, LH, MG, LG
      integer    NZ, LZ, KZ0
CCC_   . Coordinate
      integer    icF
CCC_   . misc
      integer    NHt
      integer    KHH, KHB
      _REALSTD   HC
CCC_  - Begleitung
CCC_   . Configuration
      integer    LIMICF,     LIMPCF
      parameter (LIMICF=128, LIMPCF=128)
      integer  ICFG (LIMICF)
      _REALSTD PCFG (LIMPCF)
CCC_  - Time
      integer    ITstp
      _REALSTD   T,    TNXT
      _REALSTD   DTI
      _REALSTD   TINI, TEND,  DT
      _REALSTD   TSSA, dmyTE, dmyDT
CCC_  - Output
      integer    idGM (32)
      character  CSW*(16), CLS*(16)
CCC_  - Log
      integer    ipL, ipP, ipC, ipV
      integer    ipFI (16)
CCC_ + Body
      iErr = 0
CCC_  - file units
      ipL  = FPL(ipA)
      ipP  = FPP(ipA)
      ipC  = FPC(ipA)
      ipV  = FPV(ipA)
CCC_  - Health check for Test module
CCC_  - i/o configuration
      CSW = 'C'
      CLS = 'V'
CCC_  - Model time
      if (iErr.eq.0) then
         call RTitim
     O       (iErr,
     O        TINI, TEND,  DT,
     I        CR,   'SIA', ipP, ipC, ipL)
      endif
      if (iErr.eq.0) then
         call RTitim
     O       (iErr,
     O        TSSA, dmyTE, dmyDT,
     I        CR,   'SSA', ipP, ipC, ipL)
      endif
CCC_  - Initialization
      if (iErr.eq.0) then
         call MDinit
     O       (iErr,
     O        MH,    LH,   LHPref, MG,   LG, LHGref,
     O        NZ,    LZ,   KZ0,    LZref,
     O        GG,    NTH,  WZV,    WW,   LKW,
     O        IE,    LIE,  ipCG,   LCG,  LCK,
     O        KSglb, LNR,  kDTA,   LTBL,
     O        VMW,   LVMW,
     O        icF,   idGM, ipFI,   ipKW,
     O        OMM,   IMM,  PMM,    TINI, TEND,
     I        CSW,   CLS,  CR,     iMA,  ipA)
      endif
c
      KHH = VMHI_nHa
      KHB = VMHI_nBa
      HC  = 0.0d0
CCC_  - Main loop
      OMM (OMM_WITH_RUPD) = .TRUE.
      OMM (OMM_WITH_HUPD) = .TRUE.
      if (IMM(IMD_HUPD).eq. SW_HUPD_FALSE) OMM (OMM_WITH_HUPD) = .FALSE.
      if (iErr.eq.0) then
         ITstp  = 0
         T      = TINI
         TNXT   = TINI
c
 101     format ('#T ', I7.7, 1x, F13.4, 1x, F13.4)
         DO
CCC_   . time step adjustment
            TNXT = T + DT
            call AFBnxa (TNXT, T, idGM (VGRP_VMI))
            call AFBnxa (TNXT, T, idGM (VGRP_VMTI))
c
            write (ipL, _FORMAT(101)) ITstp, T, TNXT
c
            DTI  = TNXT - T
c
            OMM (OMM_WITH_SIA)  = .true.
            OMM (OMM_WITH_SSA)  = (T.ge.TSSA)
            OMM (OMM_WITH_TUPD) = .true.
            OMM (OMM_WITH_VEL)  = .true.
CCC_   . new thickness
            call MDstpD
     O          (iErr,
     M           VMHI, VMTI, VMI,
     W           XI,   XS,   CW,   GW,    VMW,  VMHW, VMTW,
     W           QM,   VMC,  VMID,
     W           VMSC, VMSV, VMSE,
     I           VMHB, OMM,  IMM,  PMM,   T,    DTI,
     I           WW,   WZV,  GG,
     I           MH,   LH,   NZ,   LZ,    KZ0,  NTH,
     I           IE,   ipKW, iMA,  KSglb, ipCG, LCG, idGM, ipL)
CCC_   . loop break
            if (TNXT.gt.TEND) goto 900
CCC_   . suspend
CCC_   . boundary condition at new (or old) topography
CCC_   . new temperature
            if (iErr.eq.0) then
               call MUMidv (KTB, NHt, VMHI, KHH, HC, MH, LH)
            endif
            if (iErr.eq.0) then
               call MDstpT
     O             (iErr,
     M              VMHI, VMTI,
     W              CW,   VMHW, VMTW,
     W              KTB,
     I              VMHB, OMM,  IMM,   PMM,   T,   DTI,
     I              WW,   WZV,
     I              MH,   LH,   NZ,    LZ,    KZ0,
     I              IE,   ipKW, iMA,   ipCG,  LCG, idGM, ipL)
            endif
CCC_   . break
            if (iErr.ne.0) goto 900
CCC_   . outputs (profile)
CCC_   . update (must use the final state of VMI again).
            T     = TNXT
            ITstp = ITstp + 1
            if (OMM (OMM_WITH_HUPD)) then
               call UV1cpa (VMHI, VMI, MH, LH, VMHI_oHa,  VMI_Ha)
               call UV1cpa (VMHI, VMI, MH, LH, VMHI_oHXa, VMI_HX)
               call UV1cpa (VMHI, VMI, MH, LH, VMHI_oHYa, VMI_HY)
            endif
         ENDDO
 900     continue
      endif

      RETURN
      END
CCC_& IcIESa  ## IcIES Announcement
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
