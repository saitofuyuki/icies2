dnl movement/mdrvbf.m4 --- IcIES/Movement/driver buffer template
dnl Author: SAITO Fuyuki
dnl Created: Aug 9 2013
m4_divert(KILL)dnl
m4_define([TIME_STAMP],
          ['Time-stamp: <2020/09/17 08:16:16 fuyuki mdrvbf.m4>'])dnl
CCC_! m4 macros
CCC_ + root tag and suffix
CC
CC   _CROOT  _SFX     results
CC   set     set      keep
CC   set     not      _SFX   = _CROOT
CC   not     set      _CROOT = ID, keep _SFX
CC   not     not      _CROOT = ID, _SFX as blank
CC
m4_ifdef([_CROOT],
         [m4_ifndef([_SFX], [m4_define([_SFX], [_CROOT])])],
         [m4_define([_CROOT], [ID])
          m4_ifndef([_SFX], [m4_define([_SFX], [])])])
CCC_ + subroutine/entry declaration
CC _N(NAME)
m4_define([_N],
[m4_ifset([_SFX],
          [$1_[]_SFX],
          [$1])])
CCC_ + macro name declaration
CC _D(NAME)
m4_define([_D], [_N($@)])
CCC_ + end m4 definition
m4_divert()dnl
C movement/mdrvbf.F --- IcIES/Movement/driver buffer template
C Author: SAITO Fuyuki
C Created: Aug 9 2013
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
[#]define _TSTAMP TIME_STAMP
#define _FNAME 'movement/mdrvbf.F'
#define _REV   'Snoopy0.9'
CCC_! MANIFESTO
C
C Copyright (C) 2013--2020
C           Japan Agency for Marine-Earth Science and Technology,
C           Ayako ABE-OUCHI
C
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
CCC_* Test
#ifndef   TEST_MDRVBF
#  define TEST_MDRVBF 0
#endif
CCC_* Common macros
#include "ofdlct.h"   /* fortran dialect */
#include "oarpea.h"
#include "oarpkw.h"   /* operation id in arpeggio/kiwi */
#include "odevva.h"
#include "movement.h" /* movement definitions */
CCC_ + System-dependent switches
#ifndef   OPT_FORMAT_STAR
#  define OPT_FORMAT_STAR 0
#endif
#if OPT_FORMAT_STAR
#  define _FORMAT(F) *
#else
#  define _FORMAT(F) F
#endif
CCC_& _N(MDMNGR)  ## IcIES/movement buffer
      subroutine _N(MDMNGR) (iErr, ipA, iMA)
CCC_ + Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   ipA (*)
      _INTENT(IN, integer)   iMA (*)
      _INTENT(IN, character) CSW*(*)
      _INTENT(IN, character) CLS*(*)
      _INTENT(IN, _REALSTD)  TIRC, TERC, DTRC
CCC_  - Root tag
      character  CR*(*)
      parameter (CR = '_CROOT')
CCC_  - Domain size limit
[#]ifndef   _D(OPT_BUFFER)_LHP_MAX
[#]  define _D(OPT_BUFFER)_LHP_MAX OPT_MOVEMENT_LHP_MAX
[#]endif
[#]ifndef   _D(OPT_BUFFER)_LHG_MAX
[#]  define _D(OPT_BUFFER)_LHG_MAX OPT_MOVEMENT_LHG_MAX
[#]endif
[#]ifndef   _D(OPT_BUFFER)_LVZ_MAX
[#]  define _D(OPT_BUFFER)_LVZ_MAX OPT_MOVEMENT_LVZ_MAX
[#]endif
[#]ifndef   _D(OPT_BUFFER)_LVP_MAX
[#]  define _D(OPT_BUFFER)_LVP_MAX OPT_MOVEMENT_LVP_MAX
[#]endif
      integer    LHPref
      parameter (LHPref = _D(OPT_BUFFER)_LHP_MAX)
      integer    LHGref
      parameter (LHGref = _D(OPT_BUFFER)_LHG_MAX)
      integer    LTPref
      parameter (LTPref = _D(OPT_BUFFER)_LVP_MAX)
      integer    LZref
      parameter (LZref  = _D(OPT_BUFFER)_LVZ_MAX)
CCC_  - Variable clusters
CCC_   . work common
      integer    LVMW
      parameter (LVMW  = LHPref  * VMW_MAX)
      _REALSTD   VMW  (LVMW)
      integer    LVMTW
      parameter (LVMTW = LTPref * VMTW_MAX)
      _REALSTD   VMTW (LVMTW)
CCC_   . bcg solution/right/intermediate common
      _REALSTD   X    (LHPref * VMSX_MAX * BCGW_MAX)
CCC_   . field common
      _REALSTD   VMHI (LHPref * VMHI_MAX)
      _REALSTD   VMHW (LHPref * VMHW_MAX)
      save       VMHI, VMHW
c
      _REALSTD   VMI  (LHPref * VMI_MAX)
      _REALSTD   VMHB (LHPref * VMHB_MAX)
      _REALSTD   VMC  (LHPref * VMC_MAX)
      save       VMI,  VMHB, VMC
CCC_   . thickness integration
      _REALSTD   QM   (LHPref * VMQ_MAX)
      _REALSTD   VMID (LHPref * VMID_MAX)
      save       VMID
CCC_   . SSA solver
      _REALSTD   VMSC (LHPref * VMSC_MAX)
      _REALSTD   VMSV (LHPref * VMSV_MAX)
      _REALSTD   VMSE (LHPref * VMSE_MAX)
      save       VMSC, VMSV, VMSE
CCC_   . 3d velocity
      _REALSTD   VMTI (LTPref * VMTI_MAX)
      save       VMTI
CCC_   . conversion table
      integer    KTB  (LHPref, 2)
CCC_   . integration weights
      integer    NTH
      parameter (NTH = 2)
      _REALSTD   GG  (LZref * 4 * (NTH + 1) * (NTH + 1))
      save       GG
CCC_  - kiwi weights
      integer    LKW
      parameter (LKW = 64)
      _REALSTD   WW (LHPref * LKW)
      save       WW
CCC_  - vertical geometry
      _REALSTD   WZV (LZref * VMVZ_MAX)
      save       WZV
CCC_  - work
      integer    LCK
      parameter (LCK = LZref + 16)
      _REALSTD   CW (LHPref * LCK)
      _REALSTD   GW (LHGref)
CCC_  - Parameters
      logical    OMM (OMM_MAX)
      integer    IMM (IMM_MAX)
      _REALSTD   PMM (PMM_MAX)
      save       OMM, IMM, PMM
CCC_  - Table
      integer    LIE
      parameter (LIE = (LHPref * 8))
      integer    IE   (LIE)
      integer    ipKW (IPKW_FULL_DECL)
      save       IE, ipKW
CCC_   . global/private stencils
      integer    LNR
      parameter (LNR = 256)
      integer    KSglb (LNR * 2)
      save       KSglb
      integer    LTBL
      parameter (LTBL = LHPref)
      integer    kDTA (LTBL, 3)
      save       kDTA
CCC_   . clone group
      integer    LCG
      parameter (LCG = KWCG_DECL(CGRP_MEM_MAX))
      integer    ipCG (LCG, CGRP_MAX)
      save       ipCG
CCC_  - Domain sizes
      integer    MH, LH, MG, LG
      save       MH, LH, MG, LG
      integer    NZ, LZ, KZ0
      save       NZ, LZ, KZ0
CCC_  - Coordinate
      integer    icF
      save       icF
CCC_  - Time
      integer    ITstp
      save       ITstp
      _REALSTD   DT,   DTI,  TINI, TEND
      _REALSTD   T,  TNXT
      _REALSTD   TSSA
      integer    jedmy
CCC_  - Output
      integer    idGM (16)
      save       idGM
CCC_  - Log
      integer    ipL, ipP, ipC, ipV
      save       ipL, ipP, ipC, ipV
      integer    ipFI (16)
      save       ipFI
c$$$CCC_  - Test configuration
c$$$      integer  IMTI (IMTI_MAX)
c$$$      _REALSTD PMTI (PMTI_MAX)
c$$$      save     IMTI, PMTI
CCC_  - Body
      iErr  = 0
      ITstp = 0
      RETURN
CCC_  & _N(MDMini)  ## initialization wrapper
      entry _N(MDMini)
     O    (iErr,
     I     TIRC, TERC, DTRC,
     I     CSW,  CLS)
      iErr = 0
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
     I        TIRC,   TERC,   DTRC,
     I        CSW,    CLS,    CR,    iMA,  ipA)
      endif
      RETURN
CCC_  & _N(MDMfin)  ## finalization wrapper
      entry _N(MDMfin)
      RETURN
CCC_  & _N(MDMchk)  ## check status wrapper
      entry _N(MDMchk)
      RETURN
CCC_  & _N(MDMmst)  ## main suite wrapper
      entry _N(MDMmst)
      RETURN
CCC_  - end (_N(MDMNGR))
      END
c$$$CCC_ & MDbdpb  ## body suite/preparation BC
c$$$      subroutine MDbdpb
c$$$     O    (iErr,
c$$$     O     VMHB,
c$$$     M     idGM,
c$$$     I     icF, ipFI, IE, ipKW, iMA,
c$$$     I     TS,  TE)
c$$$CCC_  - Declaration
c$$$      implicit none
c$$$      _INTENT(OUT,  integer)  iErr
c$$$      _INTENT(OUT,  _REALSTD) VMHB (*)
c$$$      _INTENT(INOUT,integer)  idGM (*)
c$$$      _INTENT(IN,   _REALSTD) TS, TE
c$$$      _INTENT(IN,   integer)  icF
c$$$      _INTENT(IN,   integer)  ipFI (*)
c$$$      _INTENT(IN,   integer)  IE   (*)
c$$$      _INTENT(IN,   integer)  ipKW (*)
c$$$      _INTENT(IN,   integer)  iMA  (*)
c$$$CCC_  - Body
c$$$      iErr = 0
c$$$      if (iErr.eq.0) then
c$$$         call ABgtiS
c$$$     O       (iErr, VMHB,
c$$$     M        idGM (VGRP_VMHB), VMHB_Ra,
c$$$     I        TS, TE, icF, ipFI, IE, ipKW, iMA)
c$$$      endif
c$$$      if (iErr.eq.0) then
c$$$         call ABgtiS
c$$$     O       (iErr, VMHB,
c$$$     M        idGM (VGRP_VMHB), VMHB_Rb,
c$$$     I        TS, TE, icF, ipFI, IE, ipKW, iMA)
c$$$      endif
c$$$      if (iErr.eq.0) then
c$$$         call ABgtiS
c$$$     O       (iErr, VMHB,
c$$$     M        idGM (VGRP_VMHB), VMHB_Rc,
c$$$     I        TS, TE, icF, ipFI, IE, ipKW, iMA)
c$$$      endif
c$$$      if (iErr.eq.0) then
c$$$         call ABgtiS
c$$$     O       (iErr, VMHB,
c$$$     M        idGM (VGRP_VMHB), VMHB_Rd,
c$$$     I        TS, TE, icF, ipFI, IE, ipKW, iMA)
c$$$      endif
c$$$      if (iErr.eq.0) then
c$$$         call ABgtiS
c$$$     O       (iErr, VMHB,
c$$$     M        idGM (VGRP_VMHB), VMHB_NRa,
c$$$     I        TS, TE, icF, ipFI, IE, ipKW, iMA)
c$$$      endif
c$$$      if (iErr.eq.0) then
c$$$         call ABgtiS
c$$$     O       (iErr, VMHB,
c$$$     M        idGM (VGRP_VMHB), VMHB_NRb,
c$$$     I        TS, TE, icF, ipFI, IE, ipKW, iMA)
c$$$      endif
c$$$      if (iErr.eq.0) then
c$$$         call ABgtiS
c$$$     O       (iErr, VMHB,
c$$$     M        idGM (VGRP_VMHB), VMHB_NRc,
c$$$     I        TS, TE, icF, ipFI, IE, ipKW, iMA)
c$$$      endif
c$$$      if (iErr.eq.0) then
c$$$         call ABgtiS
c$$$     O       (iErr, VMHB,
c$$$     M        idGM (VGRP_VMHB), VMHB_NRXb,
c$$$     I        TS, TE, icF, ipFI, IE, ipKW, iMA)
c$$$      endif
c$$$      if (iErr.eq.0) then
c$$$         call ABgtiS
c$$$     O       (iErr, VMHB,
c$$$     M        idGM (VGRP_VMHB), VMHB_NRYc,
c$$$     I        TS, TE, icF, ipFI, IE, ipKW, iMA)
c$$$      endif
c$$$      if (iErr.eq.0) then
c$$$         call ABgtiS
c$$$     O       (iErr, VMHB,
c$$$     M        idGM (VGRP_VMHB), VMHB_RXb,
c$$$     I        TS, TE, icF, ipFI, IE, ipKW, iMA)
c$$$      endif
c$$$      if (iErr.eq.0) then
c$$$         call ABgtiS
c$$$     O       (iErr, VMHB,
c$$$     M        idGM (VGRP_VMHB), VMHB_RYc,
c$$$     I        TS, TE, icF, ipFI, IE, ipKW, iMA)
c$$$      endif
c$$$      if (iErr.eq.0) then
c$$$         call ABgtiS
c$$$     O       (iErr, VMHB,
c$$$     M        idGM (VGRP_VMHB), VMHB_MS,
c$$$     I        TS, TE, icF, ipFI, IE, ipKW, iMA)
c$$$      endif
c$$$      if (iErr.eq.0) then
c$$$         call ABgtiS
c$$$     O       (iErr, VMHB,
c$$$     M        idGM (VGRP_VMHB), VMHB_MB,
c$$$     I        TS, TE, icF, ipFI, IE, ipKW, iMA)
c$$$      endif
c$$$      RETURN
c$$$      END
CCC_& _N(MDRVBF)  ## Movement/Driver buffer announcement
      subroutine _N(MDRVBF) (STRA, STRB, IOP)
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
#if TEST_MDRVBF
#include "ofnstd.h"
#include "odevid.h"
CCC_ @ _N(MDMTST)  ## mdrvbf test program
      program _N(MDMTST)
CCC_  - Declaration
      implicit none
      integer iErr
      integer ipA (LOG_CHANNEL_MAX)
      integer iMA (MAX_MPI_ATTR)
CCC_  - Body
      call DDcapo
     O    (iErr,
     I     2, ' ', 'O', _FNAME, TEST_MDRVBF)
c
      if (iErr.eq.0) then
         call DLCmng (ipA, 't')
         call DVHrgC (iErr, MOVEMENT_DV_CLS, ' ', ' ', ipA)
      endif
c
      if (iErr.eq.0) then
         call DMAtma (iMA)
c$$$         call MDtestMain (iErr, ipA, iMA)
      endif
      call DevFin (iErr)
      STOP
      END
#endif /* TEST_MDRVBF */
CCC_* Obsolete
CCC_ + begin
#if 0 /* obsolete */
CCC_ + end
#endif /* 0 obsolete */
CCC_! FOOTER
C Local Variables:
C mode: fortran
C fff-style: "iciesShermy"
C End:
