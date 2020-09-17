C arpeggio/arpmng.F --- Arpeggio/Manager
C Maintainer:  SAITO Fuyuki
C Created: Oct 19 2011
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2020/09/17 08:40:44 fuyuki arpmng.F>'
#define _FNAME 'arpeggio/arpmng.F'
#define _REV   'Arpeggio 1.0'
CCC_! MANIFESTO
C
C Copyright (C) 2012--2020
C           Japan Agency for Marine-Earth Science and Technology
C
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
CCC_* Common macros
#include "ofdlct.h" /* fortran dialect */
#include "ologfm.h" /* log common format */
#include "oarpea.h"
#include "oarpkw.h"  /* operation id */
#include "oarpfi.h"  /* file-interface flags */
#include "odevva.h"
CCC_* [AMB] Arpeggio batch
CCC_ & AMBcfg  ## Arpeggio configuration suite (with no default)
      subroutine AMBcfg
     O    (iErr,
     W     W,                  LW,
     O     MHP,  LHP,          LHPref,
     O     MHG,  LHG,          LHGref,
     O     NZ,   LZ,    KZ0,   LZref,
     O     WW,                 LKW,
     O     IE,                 LIE,
     O     ipKW, icF,
     I     CR,   iMA,   IFPi,  IFPn,   IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
c
      _INTENT(IN, integer)   LW
      _INTENT(IN, integer)   LHPref,  LHGref, LZref
      _INTENT(IN, integer)   LKW
      _INTENT(IN, integer)   LIE
c
      _INTENT(OUT,_REALSTD)  W    (*)
      _INTENT(OUT,integer)   MHP,     LHP
      _INTENT(OUT,integer)   MHG,     LHG
      _INTENT(OUT,integer)   NZ,      LZ,     KZ0
c
      _INTENT(OUT,_REALSTD)  WW   (*)
c
      _INTENT(OUT,integer)   ipKW (*)
      _INTENT(OUT,integer)   IE   (*)
      _INTENT(OUT,integer)   icF
c
      _INTENT(IN, integer)   iMA (*)
      _INTENT(IN, character) CR*(*)
      _INTENT(IN, integer)   IFPi, IFPn, IFPl
c
      integer jedmy
      integer NZdef, IZT, IZB
      integer NXG,   NYG
      integer jcFH,  jcFZ
CCC_  - Body
      iErr = 0
CCC_   . default configuration
      NXG   = 0
      NYG   = 0
      NZdef = 0
      IZB   = 1
      IZT   = 0
CCC_   . coordinate family
      call ACCrgR (jedmy, icF, 0, CR, IFPl)
      jcFH = icF
      jcFZ = icF
CCC_   . 2d plane
      if (iErr.eq.0) then
         call AMHcns
     O       (iErr,
     W        W,
     O        MHP,   LHP,    MHG,    LHG,  WW,
     O        ipKW,  IE,
     I        NXG,   NYG,
     L        LW,    LHPref, LHGref, LKW,  LIE,
     I        jcFH,  CR,     iMA,    IFPi, IFPn, IFPl)
      endif
CCC_   . vertical
      if (iErr.eq.0) then
         call AMZcns
     O       (iErr,
     W        W,     LW,
     O        NZ,    LZ,    KZ0,
     I        NZdef, LZref, IZB, IZT, jcFZ, CR,  IFPi, IFPn, IFPl)
      endif
CCC_   . 3d
      if (iErr.eq.0) then
         call AMTcns
     O       (iErr,
     I        LHP,
     I        jcFH, jcFZ,  CR, IFPi, IFPn, IFPl)
      endif
CCC_   . fine
      if (iErr.eq.0) call AEAchp (iErr, IE, LHPref, 'LHPref', IFPl)
      RETURN
      END
CCC_ & AMBrep  ## Arpeggio report
      subroutine AMBrep
     O    (iErr,
     I     WW,  IE,  ipKW,
     I     MH,  LH,
     I     icF, CR,  CSW, CLS, ipFI, iMA)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, _REALSTD)  WW (*)
      _INTENT(IN, integer)   IE (*), ipKW (*)
      _INTENT(IN, integer)   MH, LH
      _INTENT(IN, integer)   icF
      _INTENT(IN, character) CR*(*)
      _INTENT(IN, character) CSW*(*), CLS*(*)
      _INTENT(IN, integer)   ipFI (*)
      _INTENT(IN, integer)   iMA  (*)
      integer jpL
CCC_  - Body
      iErr = 0
CCC_   . element-dealer table
      if (iErr.eq.0) then
         call AFEdvw
     O       (iErr,
     I        IE,   CSW, CLS, CR, ' ', ipFI, iMA)
      endif
CCC_   . 1d geometry
      if (iErr.eq.0) then
         call AMCdvw (iErr, CSW, CLS, icF, CR, 'X', ipFI, iMA)
      endif
      if (iErr.eq.0) then
         call AMCdvw (iErr, CSW, CLS, icF, CR, 'Y', ipFI, iMA)
      endif
      if (iErr.eq.0) then
         call AMCdvw (iErr, CSW, CLS, icF, CR, 'Z', ipFI, iMA)
      endif
CCC_   . kiwi weights
      if (iErr.eq.0) then
         call AMKdvw
     $       (iErr,
     $        WW,  MH,  LH,  ipKW,
     $        CSW, CLS, icF, CR, ipFI, IE, iMA)
      endif
CCC_   . end
      call AFUqip (jpL, 'L', ipFI)
      call DAtrcU (jpL, iErr, 'R', 'AMBREP')
      RETURN
      END
CCC_* [AMT] Arpeggio/3d
CCC_ & AMTcns ## Arpeggio configuration suite (T)
      subroutine AMTcns
     O    (iErr,
     I     LH,
     I     icFH, icFZ, CR, IFPi, IFPn, IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
c
      _INTENT(IN, integer)   icFH, icFZ
      _INTENT(IN, integer)   LH
c
      _INTENT(IN, character) CR*(*)
      _INTENT(IN, integer)   IFPi, IFPn, IFPl
c
      integer icHa, icHb, icHc, icHd
      integer icTa, icTb, icTc, icTd
      integer icZa
      integer iv (4)
      integer mdim
      integer jedmy, jcdmy
CCC_  - Body
      iErr = 0
CCC_   . preparation
      call ACCrfI (jedmy, jcdmy, iv, icFH, -1, 'H', IFPl)
      icHa = IV (1)
      icHb = IV (2)
      icHc = IV (3)
      icHd = IV (4)
      call ACCrfI (jedmy, jcdmy, iv, icFZ, -1, 'Z', IFPl)
      icZa = IV (1)
CCC_   . tag-name generation
      if (iErr.eq.0)
     $     call AMCrcT (iErr, icTa, icHa, icZa, LH, CR, 'a', IFPl)
      if (iErr.eq.0)
     $     call AMCrcT (iErr, icTb, icHb, icZa, LH, CR, 'b', IFPl)
      if (iErr.eq.0)
     $     call AMCrcT (iErr, icTc, icHc, icZa, LH, CR, 'c', IFPl)
      if (iErr.eq.0)
     $     call AMCrcT (iErr, icTd, icHd, icZa, LH, CR, 'd', IFPl)
CCC_   . append to family
      if (iErr.eq.0) then
         mdim = 4
         iv (1) = icTa
         iv (2) = icTb
         iv (3) = icTc
         iv (4) = icTd
         call ACCrgI (jedmy, jcdmy, iv, icFZ, mdim, 'T', IFPl)
      endif
CCC_   . loop decomposition
      if (iErr.eq.0) call ACWldi (iErr, icTa, icHa, IFPl)
      if (iErr.eq.0) call ACWldi (iErr, icTb, icHb, IFPl)
      if (iErr.eq.0) call ACWldi (iErr, icTc, icHc, IFPl)
      if (iErr.eq.0) call ACWldi (iErr, icTd, icHd, IFPl)
CCC_   . end
      call DAtrcU (IFPl, iErr, 'R', 'AMTCNS')
      RETURN
      END
CCC_* [AMZ] Arpeggio/1d
CCC_ & AMZcns ## Arpeggio configuration suite (Z)
      subroutine AMZcns
     O    (iErr,
     W     W,     LW,
     O     NZ,    LZ,    KZ0,
     I     NZdef, LZref, IZB, IZT, icF, CR,  IFPi, IFPn, IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
c
      _INTENT(OUT,_REALSTD)  W  (*)
      _INTENT(OUT,integer)   NZ,     LZ,   KZ0
c
      _INTENT(IN, integer)   LW
      _INTENT(IN, integer)   NZdef,  LZref
      _INTENT(IN, integer)   IZB,    IZT
      _INTENT(IN, integer)   icF
      _INTENT(IN, character) CR*(*)
      _INTENT(IN, integer)   IFPi,   IFPn,   IFPl
c
      integer icZa, icZb
      integer iv (2)
      integer mdim
      integer jedmy, jcdmy
CCC_  - Body
      iErr = 0
c
      NZ   = NZdef
      LZ   = NZ
      KZ0  = 1
c
      if (iErr.eq.0) then
         call ACZdcl
     $        (iErr, NZ, LZ, NZdef, CR, IFPi, IFPn, IFPl)
         LZ  = MAX (LZ, NZ)
         LZ  = MAX (LZ, NZ + (IZB + IZT))
         KZ0 = 1 + IZB
 101     format ('AMZCNS: OVERFLOW[', A, ']', 3I4)
         if (LZ.gt.LZref) then
            if       (COND_N(IFPl)) then
               write (IFPl, 101) _TRIM(CR), NZ, LZ, LZref
            else if (COND_S(IFPl)) then
               write (*,    101) _TRIM(CR), NZ, LZ, LZref
            endif
            iErr = -1
         endif
      endif
      if (iErr.eq.0) then
         call AMCrgZ
     O       (iErr, icZa, icZb,
     I        CR,
     I        NZ,   IZB,  IZT, IFPl)
      endif
      if (iErr.eq.0) then
         call AGZnmz
     O       (iErr,
     W        W,     LW,
     I        CR,    icZa, icZb,  IFPi,   IFPn,  IFPl)
      endif
      if (iErr.eq.0) then
         mdim = 2
         iv (1) = icZa
         iv (2) = icZb
         call ACCrgI (jedmy, jcdmy, iv, icF, mdim, 'Z', IFPl)
      endif
c
      call DAtrcU (IFPl, iErr, 'R', 'AMZCNS')
      RETURN
      END
CCC_* [AMH] Arpeggio/2d plane
CCC_ & AMHcns  ## Arpeggio configuration suite (no default geometry)
      subroutine AMHcns
     O    (iErr,
     W     W,
     O     MH,    LH,     MG,     LG,   WW,
     O     ipKW,  IE,
     I     NXG,   NYG,
     L     LW,    LHPref, LHGref, LKW,  LIE,
     I     icF,   CR,     iMA,    IFPi, IFPn, IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
c
      _INTENT(OUT,integer)   ipKW (*)
      _INTENT(OUT,integer)   IE   (*)
c
      _INTENT(OUT,_REALSTD)  W  (*)
      _INTENT(OUT,_REALSTD)  WW (*)
      _INTENT(OUT,integer)   MH,     LH
      _INTENT(OUT,integer)   MG,     LG
c
      _INTENT(IN, integer)   NXG, NYG
      _INTENT(IN, integer)   LW
      _INTENT(IN, integer)   LHPref, LHGref
      _INTENT(IN, integer)   LKW
      _INTENT(IN, integer)   LIE
      _INTENT(IN, integer)   iMA (*)
      _INTENT(IN, integer)   icF
      _INTENT(IN, character) CR*(*)
      _INTENT(IN, integer)   IFPi,   IFPn,  IFPl
CCC_  - Body
      iErr = 0
CCC_   . arpeggio/element dealer
      if (iErr.eq.0) then
         call AMHned
     O       (iErr,
     O        IE,
     I        LIE,  NXG,  NYG, iMA, CR, IFPi, IFPn, IFPl)
      endif
CCC_   . arpeggio/coordinates
      if (iErr.eq.0) then
         call AMHcco
     O       (iErr,
     O        MH,  LH,  LHPref,
     O        MG,  LG,  LHGref,
     I        IE,  iMA, icF, CR, IFPi, IFPn, IFPl)
      endif
CCC_   . arpeggio/geometry
      if (iErr.eq.0) then
         call AMHngm
     O       (iErr,
     W        W,   LW,
     I        icF, CR, IFPi, IFPn, IFPl)
      endif
CCC_   . arpeggio/kiwi
      if (iErr.eq.0) then
         call AMKcfg
     O       (iErr,
     O        WW,  ipKW,
     I        MH,  LH, LKW,
     I        icF, CR, IE,   IFPl)
      endif
CCC_   . return
      call DAtrcU (IFPl, iErr, 'R', 'AMHCNS')
      RETURN
      END
CCC_ & AMHcnr  ## Arpeggio configuration suite (with default geometry)
      subroutine AMHcnr
     O    (iErr,
     W     W,
     O     MH,    LH,     MG,     LG,   WW,
     O     ipKW,  IE,
     I     NXG,   NYG,
     I     vRX,   XW,     WXN,
     I     vRY,   YW,     WYN,
     L     LW,    LHPref, LHGref, LKW,  LIE,
     I     icF,   CR,     iMA,    IFPi, IFPn, IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
c
      _INTENT(OUT,integer)   ipKW (*)
      _INTENT(OUT,integer)   IE   (*)
c
      _INTENT(OUT,_REALSTD)  W  (*)
      _INTENT(OUT,_REALSTD)  WW (*)
      _INTENT(OUT,integer)   MH,     LH
      _INTENT(OUT,integer)   MG,     LG
c
      _INTENT(IN, _REALSTD)  vRX,  XW,   WXN
      _INTENT(IN, _REALSTD)  vRY,  YW,   WYN
      _INTENT(IN, integer)   NXG,  NYG
      _INTENT(IN, integer)   LW
      _INTENT(IN, integer)   LHPref, LHGref
      _INTENT(IN, integer)   LKW
      _INTENT(IN, integer)   LIE
      _INTENT(IN, integer)   iMA (*)
      _INTENT(IN, integer)   icF
      _INTENT(IN, character) CR*(*)
      _INTENT(IN, integer)   IFPi,   IFPn,  IFPl
CCC_  - Body
      iErr = 0
CCC_   . arpeggio/element dealer
      if (iErr.eq.0) then
         call AMHned
     O       (iErr,
     O        IE,
     I        LIE,  NXG,  NYG, iMA, CR, IFPi, IFPn, IFPl)
      endif
CCC_   . arpeggio/coordinates
      if (iErr.eq.0) then
         call AMHcco
     O       (iErr,
     O        MH,  LH,  LHPref,
     O        MG,  LG,  LHGref,
     I        IE,  iMA, icF, CR, IFPi, IFPn, IFPl)
      endif
CCC_   . arpeggio/geometry
      if (iErr.eq.0) then
         call AMHngr
     O       (iErr,
     W        W,   LW,
     I        vRX, XW, WXN,
     I        vRY, YW, WYN,
     I        icF, CR, IFPi, IFPn, IFPl)
      endif
CCC_   . arpeggio/kiwi
      if (iErr.eq.0) then
         call AMKcfg
     O       (iErr,
     O        WW,  ipKW,
     I        MH,  LH, LKW,
     I        icF, CR, IE,   IFPl)
      endif
CCC_   . return
      call DAtrcU (IFPl, iErr, 'R', 'AMHCNR')
      RETURN
      END
CCC_ & AMHned  ## element dealer configuration (2d plane)
      subroutine AMHned
     O    (iErr,
     O     IE,
     I     LIE,
     I     NXG,  NYG,
     I     iMA,  CR,   IFPi, IFPn, IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   LIE
      _INTENT(OUT,integer)   IE (LIE)
      _INTENT(IN, integer)   iMA (*), IFPi, IFPn, IFPl
      _INTENT(IN, integer)   NXG, NYG
      _INTENT(IN, character) CR*(*)
      integer IR,  NR
      integer LXB, LYB, LXO, LYO, LXW, LYW, ISH,  KDL
      integer LVDBG
CCC_  - Body
      iErr = 0
      call DMAget (IR, iMA, 'IR')
      call DMAget (NR, iMA, 'NR')
CCC_   . Configuration
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
     I        LVDBG, IFPi, IFPn, IFPl)
      endif
CCC_   . Elements configuration
      if (iErr.eq.0) then
         call AEAgen (iErr, IE, LIE, CR, IFPl)
      endif
CCC_   . return
      call DAtrcU (IFPl, iErr, 'R', 'AMNELM')
      RETURN
      END
CCC_ & AMHcco  ## coordinate configuration (2d plane)
      subroutine AMHcco
     O    (iErr,
     O     MHP, LHP,  LHPref,
     O     MHG, LHG,  LHGref,
     I     IE,  iMA,  icF,   CR, IFPi, IFPn, IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   MHP,  LHP
      _INTENT(OUT,integer)   MHG,  LHG
      _INTENT(IN, integer)   LHPref, LHGref
      _INTENT(IN, integer)   IE   (*)
      _INTENT(IN, integer)   iMA (*)
      _INTENT(IN, integer)   icF
      _INTENT(IN, character) CR*(*)
      _INTENT(IN, integer)   IFPi,  IFPn,  IFPl
c
      integer NHP, NHG
      integer NXG, NYG, MX, MY, LXO, LYO
      integer MXU, MYU
CCC_  - Body
      iErr = 0 * IFPi * IFPn
c
      MHP = EA_MP(IE)
      NHP = EA_NP(IE)
      NHG = EA_NG(IE)
      NXG = EA_NXG(IE)
      NYG = EA_NYG(IE)
      MX  = EA_MX(IE)
      MY  = EA_MY(IE)
      MXU = EA_MXU(IE)
      MYU = EA_MYU(IE)
      LXO = EA_LXO(IE)
      LYO = EA_LYO(IE)
c
      if (iErr.eq.0) call ACUsds (iErr, LHP, MHP, LHPref, CR, IFPl)
c
      if (iErr.eq.0) then
         call AMCrgH
     O       (iErr,
     I        LHP,   MHP,  NHP,  NHG,
     I        NXG,   MXU,  MX,   LXO,
     I        NYG,   MYU,  MY,   LYO,
     I        icF,   CR,   IFPl)
      endif
c
      MHG = EA_MG(IE)
      if (iErr.eq.0) call ACUsds (iErr, LHG, MHG, LHGref, CR, IFPl)
c
      RETURN
      END
CCC_ & AMHngm  ## geometry configuration (2d plane) with no default
      subroutine AMHngm
     O    (iErr,
     W     W,   LW,
     I     icF, CR,  IFPi, IFPn, IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(OUT,  _REALSTD)  W  (*)
      _INTENT(IN,   integer)   LW
      _INTENT(IN,   integer)   icF
      _INTENT(IN,   character) CR*(*)
      _INTENT(IN,   integer)   IFPi, IFPn, IFPl
c
      integer icXa, icXb
      integer icYa, icYb
      integer IV (2)
      integer jedmy, jcdmy
CCC_  - Body
      iErr = 0
CCC_   . Geometry preparation
      call ACCrfI (jedmy, jcdmy, iv, icF, -1, 'X', IFPl)
      icXa = IV (1)
      icXb = IV (2)
      call ACCrfI (jedmy, jcdmy, iv, icF, -1, 'Y', IFPl)
      icYa = IV (1)
      icYb = IV (2)
      if (iErr.eq.0) then
         call AGHnmz
     O       (iErr,
     W        W,    LW,
     I        CR,   'X', icXa, icXb, IFPi, IFPn, IFPl)
      endif
      if (iErr.eq.0) then
         call AGHnmz
     O       (iErr,
     W        W,    LW,
     I        CR,   'Y', icYa, icYb, IFPi, IFPn, IFPl)
      endif
c
      call DAtrcU (IFPl, iErr, 'R', 'AMNGMT')
      RETURN
      END
CCC_ & AMHngr  ## geometry configuration (2d plane) with default
      subroutine AMHngr
     O    (iErr,
     W     W,   LW,
     I     vRX, XW,  WXN,
     I     vRY, YW,  WYN,
     I     icF, CR,  IFPi, IFPn, IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,_REALSTD)  W  (*)
      _INTENT(IN, integer)   LW
      _INTENT(IN, _REALSTD)  vRX,  XW,   WXN
      _INTENT(IN, _REALSTD)  vRY,  YW,   WYN
      _INTENT(IN, integer)   icF
      _INTENT(IN, character) CR*(*)
      _INTENT(IN, integer)   IFPi, IFPn, IFPl
c
      integer icXa, icXb
      integer icYa, icYb
      integer IV (2)
      integer jedmy, jcdmy
CCC_  - Body
      iErr = 0
CCC_   . Geometry preparation
      call ACCrfI (jedmy, jcdmy, iv, icF, -1, 'X', IFPl)
      icXa = IV (1)
      icXb = IV (2)
      call ACCrfI (jedmy, jcdmy, iv, icF, -1, 'Y', IFPl)
      icYa = IV (1)
      icYb = IV (2)
      if (iErr.eq.0) then
         call AGHnmr
     O       (iErr,
     W        W,    LW,
     I        vRX,  XW,  WXN,
     I        CR,   'X', icXa, icXb, IFPi, IFPn, IFPl)
      endif
      if (iErr.eq.0) then
         call AGHnmr
     O       (iErr,
     W        W,    LW,
     I        vRY,  YW,  WYN,
     I        CR,   'Y', icYa, icYb, IFPi, IFPn, IFPl)
      endif
c
      call DAtrcU (IFPl, iErr, 'R', 'AMNGMR')
      RETURN
      END
CCC_* [AMC] Arpeggio/Coordinates
CCC_ & AMCrgH  ## H-coordinate registration
      subroutine AMCrgH
     O    (iErr,
     I     LHP,   MHP,   NHP,  NHG,
     I     NXG,   MXU,   MX,   LXO,
     I     NYG,   MYU,   MY,   LYO,
     I     icF,   CROOT, IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   LHP,   MHP,  NHP, NHG
      _INTENT(IN, integer)   NXG,   MXU,  MX,  LXO
      _INTENT(IN, integer)   NYG,   MYU,  MY,  LYO
      _INTENT(IN, integer)   icF
      _INTENT(IN, character) CROOT*(*)
      _INTENT(IN, integer)   IFPl
      integer icXa, icXb
      integer icYa, icYb
      integer icHa, icHb, icHc, icHd
      integer mdim, iv (4)
      integer jedmy, jcdmy
CCC_  - Body
      iErr = 0
CCC_   . 1d
      if (iErr.eq.0) then
         call AMCrcX
     $        (iErr, icXa, icXb, NXG, MXU, MX, LXO, CROOT, 'X', IFPl)
      endif
      if (iErr.eq.0) then
         call AMCrcX
     $        (iErr, icYa, icYb, NYG, MYU, MY, LYO, CROOT, 'Y', IFPl)
      endif
CCC_   . 2d
      if (iErr.eq.0) then
         call AMCrcH
     O       (iErr, icHa,
     I        LHP,  MHP, NHP, NHG, CROOT, 'a', icXa, icYa, IFPl)
      endif
      if (iErr.eq.0) then
         call AMCrcH
     O       (iErr, icHb,
     I        LHP,  MHP, NHP, NHG, CROOT, 'b', icXb, icYa, IFPl)
      endif
      if (iErr.eq.0) then
         call AMCrcH
     O       (iErr, icHc,
     I        LHP,  MHP, NHP, NHG, CROOT, 'c', icXa, icYb, IFPl)
      endif
      if (iErr.eq.0) then
         call AMCrcH
     O       (iErr, icHd,
     I        LHP,  MHP, NHP, NHG, CROOT, 'd', icXb, icYb, IFPl)
      endif
CCC_   . store to coordinate family
      if (iErr.eq.0) then
         mdim = 2
         iv (1) = icXa
         iv (2) = icXb
         call ACCrgI (jedmy, jcdmy, iv, icF, mdim, 'X', IFPl)
      endif
      if (iErr.eq.0) then
         mdim = 2
         iv (1) = icYa
         iv (2) = icYb
         call ACCrgI (jedmy, jcdmy, iv, icF, mdim, 'Y', IFPl)
      endif
      if (iErr.eq.0) then
         mdim = 4
         iv (1) = icHa
         iv (2) = icHb
         iv (3) = icHc
         iv (4) = icHd
         call ACCrgI (jedmy, jcdmy, iv, icF, mdim, 'H', IFPl)
      endif
CCC_   . loop decomposition
      if (iErr.eq.0) call ACWldi (iErr, icHa, icHa, IFPl)
      if (iErr.eq.0) call ACWldi (iErr, icHb, icHb, IFPl)
      if (iErr.eq.0) call ACWldi (iErr, icHc, icHc, IFPl)
      if (iErr.eq.0) call ACWldi (iErr, icHd, icHd, IFPl)
      RETURN
      END
CCC_ & AMCrcX  ## H-coordinate registration/1d sub
      subroutine AMCrcX
     O    (iErr,  icXa, icXb,
     I     NXG,   MXU,  MX,   LXO,
     I     CROOT, CDIR, IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   icXa, icXb
      _INTENT(IN, integer)   NXG,  MXU, MX,  LXO
      _INTENT(IN, character) CROOT*(*), CDIR*(*)
      _INTENT(IN, integer)   IFPl
      character CTAGa*(32), CTAGb*(32)
CCC_  - Body
      iErr = 0
CCC_   . null registration
      if (iErr.eq.0) then
         call AMCgtg (CTAGa, CROOT, CDIR,  'a')
         call AMCgtg (CTAGb, CROOT, CDIR,  'b')
c$$$         call AMCrtX (iErr, icXa, icXb, CROOT, CDIR, IFPl)
      endif
CCC_   . set attributes
      if (iErr.eq.0) then
c$$$         call ACBrgX (iErr, icXa, icXb, NXG, MXU, MX, LXO, IFPl)
         call ACBnrX
     $       (iErr,
     $        icXa,  icXb,
     $        CTAGa, CTAGb, NXG, MXU, MX, LXO, IFPl)
      endif
      RETURN
      END
CCC_ & AMCrtX  ## 1d coordinate tag registration (obsolete)
      subroutine AMCrtX
     O    (iErr,  icXa, icXb,
     I     CROOT, CDIR, IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   icXa, icXb
      _INTENT(IN, character) CROOT*(*), CDIR*(*)
      _INTENT(IN, integer)   IFPl
      character CTAGa*(32), CTAGb*(32)
CCC_  - Body
      iErr = 0
      call AMCgtg (CTAGa, CROOT, CDIR,  'a')
      call AMCgtg (CTAGb, CROOT, CDIR,  'b')
c     null-base registration
      call ACCrgX (iErr, icXa, 0,   0,  CTAGa, IFPl)
      call ACCrgX (iErr, icXb, 0,   0,  CTAGb, IFPl)
CCC_   . return
      call DAtrcU (IFPl, iErr, 'R', 'AMCRTX')
      if (icXa.eq.0 .or. icXb.eq.0) then
         iErr = -1
      else
         iErr = 0
      endif
      RETURN
      END
CCC_ & AMCrcH  ## H-coordinate registration sub
      subroutine AMCrcH
     O    (iErr,  icH,
     I     LHP,   MHP,  NHP, NHG,
     I     CROOT, CX,   icX, icY, IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   icH
      _INTENT(IN, integer)   LHP,  MHP, NHP, NHG
      _INTENT(IN, character) CROOT*(*), CX*(*)
      _INTENT(IN, integer)   icX, icY
      _INTENT(IN, integer)   IFPl
CCC_  - Body
      iErr = 0
CCC_   . null registration
      if (iErr.eq.0) then
         call AMCrtH (iErr, icH, CROOT, CX, icX, icY, IFPl)
      endif
CCC_   . set attributes
      if (iErr.eq.0) then
         call ACBrgH (iErr, icH,   NHG, NHP, MHP, LHP, IFPl)
      endif
      RETURN
      END
CCC_ & AMCrtH  ## H-coordinate tag registration
      subroutine AMCrtH
     O    (iErr,  icH,
     I     CROOT, CX, icX, icY, IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   icH
      _INTENT(IN, character) CROOT*(*), CX*(*)
      _INTENT(IN, integer)   icX, icY
      _INTENT(IN, integer)   IFPl
      integer   icW,        icS
      character CTAGw*(32), CTAGs*(32), CTAGh*(32)
CCC_  - Body
      iErr = 0
c
      icW  = 0
      icS  = 0
      icH  = 0
CCC_   . tag names
      call AMCgtg (CTAGw, CROOT, 'W', CX)
      call AMCgtg (CTAGs, CROOT, 'S', CX)
      call AMCgtg (CTAGh, CROOT, 'H', CX)
CCC_   . null-base registration
      call ACCrgM (iErr, icW,  icX, icY, 0,   CTAGw, IFPl)
      call ACCrgS (iErr, icS,  icW,      0,   CTAGs, IFPl)
      call ACCrgX (iErr, icH,  icS,      0,   CTAGh, IFPl)
CCC_   . return
      call DAtrcU (IFPl, iErr, 'R', 'AMCRTH')
      if (icW.eq.0 .or. icS.eq.0 .or. icH.eq.0) then
         iErr = -1
      else
         iErr = 0
      endif
      RETURN
      END
CCC_ & AMCrcT  ## T-coordinate registration/3d
      subroutine AMCrcT
     O    (iErr,  icT,
     I     icH,   icZ, LH,
     I     CROOT, CX,  IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   icT
      _INTENT(IN, integer)   icH, icZ
      _INTENT(IN, integer)   LH
      _INTENT(IN, character) CROOT*(*), CX*(*)
      _INTENT(IN, integer)   IFPl
CCC_  - Body
      iErr = 0
CCC_   . null registration
      if (iErr.eq.0) then
         call AMCrtT (iErr, icT, icH, icZ, CROOT, CX, IFPl)
      endif
CCC_   . set attributes
      if (iErr.eq.0) then
         call ACBrgT (iErr, icT, LH, IFPl)
      endif
      RETURN
      END
CCC_ & AMCrtT  ## T-coordinate tag registration
      subroutine AMCrtT
     O    (iErr,  icT,
     I     icH,   icZ, CROOT, CX, IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   icT
      _INTENT(IN, character) CROOT*(*), CX*(*)
      _INTENT(IN, integer)   icH, icZ
      _INTENT(IN, integer)   IFPl
      integer   icL
      character CTAGt*(32), CTAGl*(32)
CCC_  - Body
      iErr = 0
c
      icT  = 0
      icL  = 0
CCC_   . tag names
      call AMCgtg (CTAGt, CROOT, 'T', CX)
      call AMCgtg (CTAGl, CROOT, 'L', CX)
CCC_   . null-base registration
      call ACCrgX (iErr, icL,  icH,      0,   CTAGl, IFPl)
      call ACCrgM (iErr, icT,  icL, icZ, 0,   CTAGt, IFPl)
CCC_   . return
      call DAtrcU (IFPl, iErr, 'R', 'AMCRTT')
      if (icT.eq.0 .or. icL.eq.0) then
         iErr = -1
      else
         iErr = 0
      endif
      RETURN
      END
CCC_ & AMCrgZ  ## Z-coordinate registration [base:ACZrgS]
      subroutine AMCrgZ
     O    (iErr, icZa, icZb,
     I     CROOT,
     I     NZ,   IZB,  IZT, IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   icZa, icZb
      _INTENT(IN, character) CROOT*(*)
      _INTENT(IN, integer)   NZ, IZB, IZT
      _INTENT(IN, integer)   IFPl
CCC_  - Body
      iErr = 0
c
      icZa = 0
      icZb = 0
c
      if (iErr.eq.0) call AMCrsz (iErr, icZa, CROOT, 'a',  IFPl)
      if (iErr.eq.0) call AMCrsz (iErr, icZb, CROOT, 'b',  IFPl)
c
      call ACZreg
     O    (iErr,
     I     icZa,  icZb,
     I     NZ,    IZB,  IZT, IFPl)
c
      RETURN
      END
CCC_ & AMCrsZ  ## Z-coordinate registration sub [base:ACZrgZ]
      subroutine AMCrsZ
     O    (iErr,  icZ,
     I     CROOT, CX,   IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   icZ
      _INTENT(IN, character) CROOT*(*), CX*(*)
      _INTENT(IN, integer)   IFPl
      character CTAGB*(32), CTAGZ*(32)
      integer   icB
CCC_  - Body
      iErr = 0
      call AMCgtg (CTAGB, CROOT, 'B',  CX)
      call AMCgtg (CTAGZ, CROOT, 'Z',  CX)
c     null-base registration
      call ACCrgX (iErr, icB, 0,   0,  CTAGB, IFPl)
      if (icB.ne.0) call ACCrgX (iErr, icZ, icB, 0,  CTAGZ, IFPl)
CCC_   . return
      call DAtrcU (IFPl, iErr, 'R', 'AMCRSZ')
      if (icZ.eq.0) then
         iErr = -1
      else
         iErr = 0
      endif
      RETURN
      END
CCC_ & AMCdvw  ## coordinate output wrapper
      subroutine AMCdvw
     O    (iErr,
     I     CSW, CLS, icF, CR, CK, ipFI, iMA)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   icF
      _INTENT(IN, character) CSW*(*),  CLS*(*)
      _INTENT(IN, character) CR*(*),   CK*(*)
      _INTENT(IN, integer)   ipFI (*), iMA (*)
      integer iv (16)
      integer mdim
      integer jedmy, jcg
      integer jcx,   jg
      integer jpL,   jpV
CCC_  - Body
      iErr = 0
      mdim = 0
      call AFUqip (jpL, 'L', ipFI)
      call AFUqip (jpV, 'V', ipFI)
      call ACCrfI (jedmy, jcg, iv, icF, -1, CK, jpL)
      if (jcg.ne.0) call ACWdim (jedmy, mdim, jcg)
      do jg = 1, mdim
         if (iErr.eq.0) then
            jcx = iv (jg)
            call AFCwrb (iErr, jcx, CSW, CLS, CR, ipFI, iMA)
         endif
      enddo
      RETURN
      END
CCC_ & AMCgtg  ## Coordinate/Utility tag name generation (global) [old: ACUgtg]
      subroutine AMCgtg
     O    (Ctag,
     I     Croot, Ckind, Csfx)
      implicit none
      _INTENT(OUT,character) Ctag*(*)
      _INTENT(IN, character) Croot*(*), Ckind*(*), Csfx*(*)
 101  format (A, '.', A, A)
      if (HAVE_F77_TRIM.eq.0) then
         Ctag = Croot
         call USJnta (Ctag, '.', Ckind)
         call USJnta (Ctag, ' ', Csfx)
      else
         write (Ctag, 101) _TRIM(Croot), _TRIM(Ckind), _TRIM(Csfx)
      endif
      RETURN
      END
CCC_ & AMCkxg  ## coordinate tag name decomposition (kind-sfx)
      subroutine AMCkxg
     O    (CKX,
     I     Ctag, CROOT)
      implicit none
      _INTENT(OUT,character) CKX*(*)
      _INTENT(IN, character) Ctag*(*),  Croot*(*)
      integer jp, lt
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
      jp = INDEX (Ctag, '.')
      lt = len_trim (Ctag)
      if (jp.gt.0) then
         if (Ctag (1:jp-1).ne.CROOT) jp = 0
      endif
      CKX = Ctag (jp+1:lt)
      RETURN
      END
CCC_* [AMK] Arpeggio/Kiwi
CCC_ & AMKcfg  ## kiwi configuration wrapper
      subroutine AMKcfg
     O    (iErr,
     O     WW,  ipKW,
     I     MH,  LH, LKW,
     I     icF, CR, IE,   IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(OUT,  _REALSTD)  WW   (*)
      _INTENT(INOUT,integer)   ipKW (*)
      _INTENT(IN,   integer)   LKW
      _INTENT(IN,   integer)   MH,     LH
      _INTENT(IN,   integer)   icF
      _INTENT(IN,   character) CR*(*)
      _INTENT(IN,   integer)   IE (*)
      _INTENT(IN,   integer)   IFPl
c
      integer jedmy, jcdmy
      integer icHA (16)
CCC_  - Body
      iErr = 0
      if (iErr.eq.0) then
         call ACCrfI (jedmy, jcdmy, icHA, icF, -1, 'H', IFPl)
         call AKEcfg
     O       (iErr, WW, ipKW,
     I        LKW,  MH, LH,  icHA,  IE, CR, IFPl)
      endif
      RETURN
      END
CCC_ & AMKdvw  ## kiwi output wrapper
      subroutine AMKdvw
     O    (iErr,
     I     WW,  MH,  LH,  ipKW,
     I     CSW, CLS, icF, CR, ipFI, IE, iMA)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, _REALSTD)  WW   (*)
      _INTENT(IN, integer)   ipKW (*)
      _INTENT(IN, integer)   MH, LH
      _INTENT(IN, integer)   icF
      _INTENT(IN, character) CR*(*)
      _INTENT(IN, character) CSW*(*), CLS*(*)
      _INTENT(IN, integer)   ipFI (*)
      _INTENT(IN, integer)   IE  (*)
      _INTENT(IN, integer)   iMA (*)
c
      integer ivG
      integer icHA (4)
      integer jedmy, jcdmy
      integer jpL
CCC_  - Body
      iErr = 0
c
      call AFUqip (jpL, 'L', ipFI)
c$$$      call ACCrfI (jedmy, jcdmy, icHA, icF, -1, 'H', IFPl)
      call ACCrfI (jedmy, jcdmy, icHA, icF, -1, 'H', jpL)
c
      if (iErr.eq.0) then
         call AFBrgd
     O       (iErr,
     O        ivG,
     I        'AKW', MH,  LH, 0,    0,   0,  icHA (1),
     I        CSW,   CLS, CR, ipFI, iMA)
      endif
      if (iErr.eq.0) then
         call AFBgmf(iErr, ivG,  ' ', ' ', IE, ipFI)
      endif
      if (iErr.eq.0) then
         call AKPdvw
     O       (iErr,
     I        WW,   MH,  LH, ipKW,
     I        icHA, ivG, IE, iMA)
      endif
c
      RETURN
      END
CCC_* Obsolete subroutines (reserved)
CCC_ + begin
#if 0
CCC_ & AMCnco  ## Get number of coordinates from CKIND
      subroutine AMCnco
     O    (iErr, NCO,
     I     CKIND)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   NCO
      _INTENT(IN, character) CKIND*(*)
      integer j
c
      iErr = 0
c                 12345678
      j = INDEX ('HWSLTXYZ', CKIND (1:1))
      if (j.le.0) then
         iErr = -1
         NCO  = 0
      else if (j.lt.5) then
         NCO  = 2
      else if (j.lt.6) then
         NCO  = 3
      else
         NCO  = 1
      endif
      RETURN
      END
CCC_ & AMCctb  ## Coordinate-name table builder
      subroutine AMCctb
     O    (iErr,
     M     Ncnm,  Cnm,
     I     MaxCo, CR,  CK, CX)
CCC_  - Declaration
      _INTENT(OUT,  integer)   iErr
c
      _INTENT(IN,   integer)   MaxCo
      _INTENT(INOUT,integer)   Ncnm
      _INTENT(INOUT,character) Cnm (MaxCo)*(*)
      _INTENT(IN,   character) CR*(*), CK*(*), CX*(*)
c
      character TK*1, TX*1
CCC_  - Body
      iErr = 0
      TK = CK (1:1)
      TX = CX (1:1)
CCC_   . X
      if (INDEX ('HWSLT', TK).gt.0) then
         if      (INDEX ('ac', TX).gt.0) then
            call AMCstc (Ncnm, Cnm, MaxCo, CR, 'X', 'a')
         else if (INDEX ('bd', TX).gt.0) then
            call AMCstc (Ncnm, Cnm, MaxCo, CR, 'X', 'b')
         endif
      else if (TK.eq.'X') then
         call AMCstc (Ncnm, Cnm, MaxCo, CR, 'X', TX)
      endif
CCC_   . Y
      if (INDEX ('HWSLT', TK).gt.0) then
         if      (INDEX ('ab', TX).gt.0) then
            call AMCstc (Ncnm, Cnm, MaxCo, CR, 'Y', 'a')
         else if (INDEX ('cd', TX).gt.0) then
            call AMCstc (Ncnm, Cnm, MaxCo, CR, 'Y', 'b')
         endif
      else if (TK.eq.'Y') then
         call AMCstc (Ncnm, Cnm, MaxCo, CR, 'Y', TX)
      endif
CCC_   . Z
      if (INDEX ('T', TK).gt.0) then
         if      (INDEX ('abcd', TX).gt.0) then
            call AMCstc (Ncnm, Cnm, MaxCo, CR, 'Z', 'a')
         endif
      else if (TK.eq.'Z') then
         call AMCstc (Ncnm, Cnm, MaxCo, CR, 'Z', TX)
      endif
CCC_   . final
      if (Ncnm.gt.MaxCo) iErr = -1
      RETURN
      END
CCC_ & AMCstc  ## Coordinate-name table builder sub
      subroutine AMCstc
     M    (Ncnm,  Cnm,
     I     MaxCo, CR, CK, CX)
      implicit none
      _INTENT(IN,   integer)   MaxCo
      _INTENT(INOUT,integer)   Ncnm
      _INTENT(INOUT,character) Cnm (MaxCo)*(*)
      _INTENT(IN,   character) CR*(*), CK*(*), CX*(*)
      logical OFND
      integer j
      character CBASE*(32)
      call AMCgtg (CBASE, CR, CK, CX)
      OFND = .false.
      do j = 1, Ncnm
         if (Cnm (j).eq.CBASE) then
            OFND = .true.
            goto 100
         endif
      enddo
 100  continue
      if (OFND) then
         continue
      else
         Ncnm = Ncnm + 1
         if (Ncnm.lt.MaxCo) then
            Cnm (Ncnm) = CBASE
         endif
      endif
      RETURN
      END
CCC_ & AMCqdg  ## coordinate inquire and decomposition (global) [old: ACUqdg]
      subroutine AMCqdg
     O    (iErr, Croot, Ckind, Csfx,
     I     icX)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,character) Croot*(*), Ckind*(*), Csfx*(*)
      _INTENT(IN, integer)   icX
      character CTAG*(32)
      iErr = 0
      call ACWtag (iErr, CTAG, icX)
      call AMCdtg (Croot, Ckind, Csfx, Ctag)
      RETURN
      END
CCC_ & AMCdtg  ## coordinate tag name decomposition (global) [old: ACUdtg]
      subroutine AMCdtg
     O    (Croot, Ckind, Csfx,
     I     Ctag)
      implicit none
      _INTENT(OUT,character) Croot*(*), Ckind*(*), Csfx*(*)
      _INTENT(IN, character) Ctag*(*)
      integer jp, lt
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
      lt = len_trim (Ctag)
      jp = INDEX (Ctag, '.')
      if (jp.le.0) then
         Croot = ' '
         jp    = 0
      else
         Croot = Ctag (1:jp - 1)
      endif
      Csfx  = Ctag (lt:lt)
      Ckind = Ctag (jp + 1:lt - 1)
      RETURN
      END
CCC_ & AMVwgi  ## write tag/value tables (by id)  [old: ACVwgi]
      subroutine AMVwgi
     O    (iErr,
     I     idC, IFP, IFPv, OLP)
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   idC
      _INTENT(IN, integer)   IFP, IFPv
      _INTENT(IN, logical)   OLP
      character CROOT*(32), CKIND*(32), CSFX*(32)
      iErr = 0
      call AMCqdg (iErr, Croot, Ckind, Csfx, idC)
      call AMVwgc (iErr, Croot, Ckind, Csfx, IFPv)
      call AMVwcs (iErr, idC, IFP, IFPv)
      if (OLP) then
         call AMVwld (iErr, idC, IFP, IFPv)
      endif
      RETURN
      END
CCC_ & AMVwgc  ## write tag/value tables (CBASE with generation) [old:ACVwgc]
      subroutine AMVwgc
     O    (iErr,
     I     CROOT, CKIND, CSFX, IFP)
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, character) CROOT*(*), CKIND*(*), CSFX*(*)
      _INTENT(IN, integer)   IFP
      character CBASE*(32)
      call AMCgtg (CBASE, CROOT, CKIND, CSFX)
      call AMVwco (iErr,  CROOT, CBASE, IFP)
      if (CKIND.ne.' ') call DVTwta (iErr, 'CKIND', CKIND,  ' ', IFP)
      if (CSFX .ne.' ') call DVTwta (iErr, 'CSFX',  CSFX,   ' ', IFP)
      RETURN
      END
CCC_ & AMVwco  ## write tag/value tables (coordinate attributes) [old: ACVwco]
      subroutine AMVwco
     O    (iErr,
     I     CROOT, TagBas,  IFP)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, character) CROOT*(*)
      _INTENT(IN, character) TagBas*(*)
      _INTENT(IN, integer)   IFP
      if (CROOT.ne.' ')  call DVTwta (iErr, 'CROOT', CROOT,  ' ', IFP)
      if (TagBas.ne.' ') call DVTwta (iErr, 'CBASE', TagBas, ' ', IFP)
      RETURN
      END
CCC_ + end
#endif /* 0 */
CCC_& ARPMNG  ## Arpeggio/manager announcement
      subroutine ARPMNG (STRA, STRB, IOP)
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
CCC_* TEST
CCC_ @ AMTEST  ## Test program
#ifdef TEST_ARPMNG
      program AMTEST
CCC_  - Test suites
CC::   SOURCES agmtry.F akwopr.F
CCC_  - Declaration
      implicit none
#include "ofnstd.h"
#include "odevid.h"  /* MPI table */
      integer iErr
      integer ipA (LOG_CHANNEL_MAX)
      integer iMA (MAX_MPI_ATTR)
#define AKW_CLS 'V'
CCC_  - Body
      call DDcapo
     O    (iErr,
     I     2, ' ', 'O', _FNAME, -1)
      if (iErr.eq.0) then
         call DLCmng (ipA, 't')
         call DVHrgC (iErr, AKW_CLS, ' ', ' ', ipA)
      endif
      if (iErr.eq.0) then
         call DMAtma (iMA)
         call AMTESTmain (iErr, ipA, iMA)
      endif
      call DevFin (iErr)
c$$$      call DDcmin (iErr)
c$$$      if (iErr.eq.0) then
c$$$         call DLCmng (ipA, 't')
c$$$         call DMAtma (iMA)
c$$$         call AMTESTmain (iErr, ipA, iMA)
c$$$      endif
c$$$      call DDfmin (iErr)
      STOP
      END
CCC_ & AMTESTmain  ## Test/main
      subroutine AMTESTmain (iErr, ipA, iMA)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(IN, integer) ipA (*)
      _INTENT(IN, integer) iMA (*)
c
      integer    LIE
      parameter (LIE = 32769)
      integer    IE   (LIE)
c
      integer    LHPref
      parameter (LHPref = 8192)
      integer    LHGref
      parameter (LHGref = 8192)
c
      integer    LKW
      parameter (LKW = 256)
      _REALSTD   WW (LHPref * LKW)
      character  CROOT * (32)
c
      integer    LZref
      parameter (LZref = 128)
      integer    LKWZ
      parameter (LKWZ  = 16)
      _REALSTD   WZV (LZref * LKWZ)
c
      integer    LW
      parameter (LW = 16384)
      _REALSTD   W (LW)
c
      integer    ipKW (IPKW_FULL_DECL)
      integer    MHP, LHP
      integer    MHG, LHG
      integer    NZ,  LZ,   KZ0
c
      integer    icF
c
      integer    ITEST
      integer    ipP, ipC, ipL, ipV
c
      character  CSW*8
      character  CLS*8
c
      integer    ipFI (AFI_FLAG_MAX)
CCC_  - Body
      iErr  = 0
      CROOT = 'ID'
      ITEST = 0
      ipL   = FPL(ipA)
      ipP   = FPP(ipA)
      ipC   = FPC(ipA)
      ipV   = FPV(ipA)
c
      call UDTbni (ITEST, 'BEGIN', ' ', ipL)
c
      if (iErr.eq.0) call AKPini (ipKW)
      if (iErr.eq.0) call AKPdca (iErr, ipKW, ipL)
c
      if (iErr.eq.0) then
         call AMBcfg
     O       (iErr,
     W        W,                   LW,
     O        MHP,   LHP,          LHPref,
     O        MHG,   LHG,          LHGref,
     O        NZ,    LZ,    KZ0,   LZref,
     O        WW,                  LKW,
     O        IE,                  LIE,
     O        ipKW,  icF,
     I        CROOT, iMA,   ipP,   ipC,  ipL)
      endif
c
      CSW = 'C'
      CLS = 'V'
      call AFUifp (ipFI, ipP, ipC, ipL, ipV)
      if (iErr.eq.0) then
         call AMBrep
     O       (iErr,
     I        WW,  IE,    ipKW,
     I        MHP, LHP,
     I        icF, CROOT, CSW,  CLS, ipFI, iMA)
      endif
c
      call UDTbni (ITEST, 'END',   ' ', ipL)
c
      call ACCrep (ipL, 2)
c
      RETURN
      END
#endif /* TEST_ARMNG */
CCC_* Obsolete
CCC_ + begin
#if 0
CCC_ + end
#endif /* 0 */
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
