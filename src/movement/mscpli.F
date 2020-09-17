C movement/mscpli.F --- IcIES/SSA coupler (Three side)
C Author: SAITO Fuyuki
C Created: Oct 17 2012
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2020/09/15 12:01:21 fuyuki mscpli.F>'
#define _FNAME 'movement/mscpli.F'
#define _REV   'Snoopy0.8/Three0.1/Four/Sally'
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
#include "odevid.h"   /* mpi attributes */
#ifdef NO_MOVEMENT_H
#else
#  include "movement.h" /* movement definitions */
#endif
CCC_* Sources
CCC_ + Driver
CCC_  & MSCdrv  ## Driver suite
CCC_ + Exchanger (to Three/SSA)
CCC_ + Exchanger (from Three/SSA)
CCC_* Obsolete
#if 0 /* obsolete */
CCC_ + Initialization
CCC_  & MSCini  ## Initialization suite
      subroutine MSCini
     O    (iErr,
     W     W,
     O     MP,   LP,    WO,   WA,
     O     ipKW, IE,    ipCG,
     I     LIE,  NXG,   NYG,  LPref, LKWO, LKWA, LCG, LCK,
     I     I0,   J0,    DX,   DY,
     I     ipP,  ipC,   ipL)
      implicit none
      _INTENT(OUT,integer)  iErr
      _INTENT(OUT,integer)  ipKW (*)
      _INTENT(OUT,integer)  IE   (*)
      _INTENT(OUT,integer)  ipCG (*)
      _INTENT(OUT,_REALSTD)  W  (*)
      _INTENT(OUT,_REALSTD)  WO (*), WA (*)
      _INTENT(OUT,integer)   MP,    LP
      _INTENT(IN, _REALSTD)  DX,    DY
      _INTENT(IN, integer)   I0,    J0
      _INTENT(IN, integer)   LPref, LKWO, LKWA
      _INTENT(IN, integer)   LIE,   LCG,  LCK
      _INTENT(IN, integer)   NXG,   NYG
      _INTENT(IN, integer)   ipP,   ipC,   ipL
      integer   iMA (MAX_MPI_ATTR)
      character CR*(8)
CCC_   . Body
      iErr = 0
      CR   = 'ID'
CCC_    * development
      call DDcmin (iErr)
      if (iErr.eq.0) call DMAtma (iMA)
CCC_    * arpeggio/kiwi/operations
      if (iErr.eq.0) then
         call AKPini (ipKW)
         if (iErr.eq.0) call MSNdec (iErr, ipKW, ipL)
         if (iErr.eq.0) call MSBdec (iErr, ipKW, ipL)
      endif
CCC_    * arpeggio/element dealer
      if (iErr.eq.0) then
         call MSCiae
     O       (iErr,
     O        IE,
     I        LIE,  NXG,  NYG, iMA,  CR, ipP, ipC, ipL)
      endif
CCC_    * arpeggio/geometry
      if (iErr.eq.0) then
         call MSCiaG
     O       (iErr,
     W        W,
     M        ipKW,
     O        MP,     LP,    WO,   WA,
     I        I0,     J0,    DX,   DY,
     I        LPref,  LKWO,  LKWA,
     I        CR,     IE,    iMA,  ipP, ipC, ipL)
      endif
CCC_    * arpeggio/kiwi/clone
      if (iErr.eq.0) then
         call MSNcgr
     O       (iErr,
     O        ipCG,
     I        LCG,   LP,  LCK, ipKW,  IE,  ipL)
      endif
      RETURN
      END
CCC_  & MSCiae  ## arpeggio/element dealer  (cf. MDiniE)
      subroutine MSCiae
     O    (iErr,
     O     IE,
     I     LIE,
     I     NXG,  NYG,
     I     iMA,  CR,   ipP, ipC, ipL)
CCC_   . Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   LIE
      _INTENT(OUT,integer)   IE (LIE)
      _INTENT(IN, integer)   iMA (*), ipP, ipC, ipL
      _INTENT(IN, integer)   NXG, NYG
      _INTENT(IN, character) CR*(*)
      integer IR,  NR
      integer LXB, LYB, LXO, LYO, LXW, LYW, ISH,  KDL
      integer LVDBG
      integer icG (4)
CCC_   . Body
      iErr = 0
CCC_    * Configuration
      call DMAget (IR, iMA, 'IR')
      call DMAget (NR, iMA, 'NR')
      if (iErr.eq.0) then
         KDL   = 3
         LXO   = 0
         LYO   = 0
         LXB   = 1
         LYB   = 1
         LXW   = 0
         LYW   = 0
         ISH   = 1
         LVDBG = 0
         call AEAnsa
     O       (iErr,
     O        IE,
     I        LIE,
     I        NXG,  NYG, LXB, LYB, LXW, LYW, LXO, LYO,
     I        IR,   NR,  ISH, KDL,
     I        CR,
     I        LVDBG, ipP, ipC, ipL)
      endif
CCC_    * Elements configuration
      if (iErr.eq.0) then
         call AEAgen (iErr, IE, LIE, CR, ipL)
      endif
CCC_    * Coordinate configuration
      if (iErr.eq.0) then
         call AKWeai
     O       (iErr,
     O        icG,   IE,  LIE,
     I        iMA,   CR,  ipL)
      endif
CCC_    * return
      call DAtrcU (ipL, iErr, 'R', 'MSCiae')
      RETURN
      END
CCC_  & MSCiag  ## arpeggio/geometry  (cf. MDiniG)
      subroutine MSCiag
     O    (iErr,
     W     W,
     M     ipKW,
     O     MP,     LP,    WO,   WA,
     I     I0,     J0,    DX,   DY,
     I     LPref,  LKWO,  LKWA,
     I     CR,     IE,    iMA,  ipP, ipC, ipL)
CCC_   . declaration
      _INTENT(OUT,  integer)   iErr
      _INTENT(OUT,  _REALSTD)  W  (*)
      _INTENT(OUT,  _REALSTD)  WO (*), WA (*)
      _INTENT(OUT,  integer)   MP,    LP
      _INTENT(INOUT,integer)   ipKW (*)
      _INTENT(IN,  _REALSTD)   DX, DY
      _INTENT(IN,   integer)   I0, J0
      _INTENT(IN,   integer)   LPref, LKWO, LKWA
      _INTENT(IN,   character) CR*(*)
      _INTENT(IN,   integer)   IE (*), iMA (*)
      _INTENT(IN,   integer)   ipP, ipC, ipL
c
      integer    kCX, kCY
      _REALSTD   vCX, vCY, XW, YW, WXN, WYN
CCC_   . Body
      iErr = 0
CCC_    * Geometry preparation
      vCX = DBLE (I0)
      vCY = DBLE (J0)
      XW  = DX
      YW  = DY
      WXN = 1.0d0
      WYN = 1.0d0
      if (iErr.eq.0) then
         call AGHnmi
     O       (iErr,
     M        kCX,  vCX,  XW, WXN, kCY,  vCY,  YW, WYN,
     I        CR,
     I        ipP,  ipC,  ipL)
         iErr = Min (0, iErr)
      endif
CCC_    * Weights configuration
      if (iErr.eq.0) then
         call AKEcfg
     O       (iErr, MP,   LP,    WO,  WA,  W,  ipKW,
     I        LKWO, LKWA, LPref,
     I        kCX,  vCX,  XW,    WXN,
     I        kCY,  vCY,  YW,    WYN,  CR, IE, ipL)
      endif
c
      RETURN
      END
CCC_ + Finalization
CCC_  & MSCfin  ## Finalization suite
      subroutine MSCfin
     O    (iErr)
      implicit none
      _INTENT(OUT,integer) iErr
      iErr = 0
      call DDfmin (iErr)
      RETURN
      END
#endif /* obsolete */
CCC_@ MSCTST  ## test program
#if TEST_MSCPLI
      program MSCTST
CCC_ + Test suites
CC::   SOURCES msnita.F
CCC_ + Declaration
      implicit none
      integer iErr
      integer ipC, ipP, ipL
c
      integer    NXG, NYG
      parameter (NXG = 31, NYG = 31)
      integer    LPref
      parameter (LPref = NXG * NYG)

      integer    LIE
      parameter (LIE = (LPref * 8))
      integer    IE (LIE)
c
      integer    LKWO,      LKWA
      parameter (LKWO = 32, LKWA = 64)
c
      _REALSTD  WO (LPref, LKWO)
      _REALSTD  WA (LPref, LKWA)
      _REALSTD  W  (LPref)
c
      integer    MP, LP
      integer    ipKW (IPKW_FULL_DECL)
c
      integer    LCG
      parameter (LCG = KWCG_DECL(4))
      integer    ipCG (LCG, CGS_MAX)
c
      integer    LCK
      parameter (LCK = 16)
c
      integer    I0, J0
      _REALSTD   DX, DY
CCC_ + Body
      ipL = -1
      ipC = -1
      ipP = -2
c
#if 0 /* obsolete */
      I0 = NXG / 2 + 1
      J0 = NYG / 2 + 1
      DX = 50.0d3
      DY = 50.0d3
c
      call MSCini
     O    (iErr,
     W     W,
     O     MP,   LP,  WO,  WA,
     O     ipKW, IE,  ipCG,
     I     LIE,  NXG, NYG, LPref, LKWO, LKWA, LCG, LCK,
     I     I0,   J0,  DX,  DY,    ipP,  ipC,  ipL)
c
      call MSCfin (iErr)
#endif /* obsolete */
      STOP
      END
#endif /* TEST_MSCPLI */
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
