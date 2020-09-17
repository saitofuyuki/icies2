C begleitung/bglbrt.F --- IcIES/Begleitung/Rock tempearture
C Maintainer:  SAITO Fuyuki
C Created: Jun 16 2018
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2020/09/17 08:41:37 fuyuki bglbrt.F>'
#define _FNAME 'begleitung/bglbrt.F'
#define _REV   'Snoopy0.97'
CCC_! MANIFESTO
C
C Copyright (C) 2018--2020
C           Japan Agency for Marine-Earth Science and Technology,
C           Ayako ABE-OUCHI
C
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
CCC_* Description
CCC_* Common macros
#include "ofdlct.h"   /* fortran dialect */
#include "ofnstd.h"
#include "ologfm.h"   /* log common format */
#include "ounelv.h"
#include "begleitung.h"
#ifndef    OPT_NAMELIST_OUTPUT_EMULATION
#  define  OPT_NAMELIST_OUTPUT_EMULATION _UNMLEM_LEVEL_END
#endif
CCC_* Initialization
CCC_ & BBinit  ## initialization
      subroutine BBinit
     O    (iErr,
     O     NZR,  LZR,  KZ0R, LZrefR,
     O     WZR,
     O     IBB,  PBB,
     O     icFR, idGB,
     W     W,    LW,
     I     icFH, MH,   LH,  CSW,  CLS,  CRR,  CRH, IE, iMA, ipA, ipFI)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)  iErr
      _INTENT(OUT,_REALSTD) W    (*)
      _INTENT(IN, integer)  LW
CCC_   . arppegio configuration
      _INTENT(OUT,integer)  NZR, LZR, KZ0R
      _INTENT(OUT,_REALSTD) WZR (*)
CCC_   . configuration
      _INTENT(OUT,integer)  icFR
      _INTENT(OUT,integer)  idGB (*)
      _INTENT(OUT,integer)  IBB  (*)
      _INTENT(OUT,_REALSTD) PBB  (*)
CCC_   . inputs
      _INTENT(IN, integer)   icFH
      _INTENT(IN, integer)   MH, LH
      _INTENT(IN, integer)   LZrefR
      _INTENT(IN, character) CSW*(*)
      _INTENT(IN, character) CRR*(*), CRH*(*)
      _INTENT(IN, character) CLS*(*)
      _INTENT(IN, integer)   IE  (*)
      _INTENT(IN, integer)   ipA (*)
      _INTENT(IN, integer)   iMA (*)
      _INTENT(IN, integer)   ipFI(*)
CCC_   . interior
      integer  ipC, ipL, ipP
      integer  icGz (2)
      integer  jedmy, jcdmy
      integer  NZdef, IZB, IZT
c
      integer jg
      integer icGH (4)
      integer icGT (16)
      integer MZR
CCC_  - Body
      iErr = 0
c
      NZdef = 17
      IZB   = 1
      IZT   = 0
CCC_   . file units
      ipL  = FPL(ipA)
      ipP  = FPP(ipA)
      ipC  = FPC(ipA)
      if (iErr.eq.0) then
         call BBTpnm
     O       (iErr,
     O        IBB, PBB,
     I        CRR, ipP, ipC, ipL)
      endif
      if (iErr.eq.0) then
         call ACCrgR (jedmy, icFR, 0, CRR, ipL)
      endif
      if (iErr.eq.0) then
         call AMZcns
     O       (iErr,
     W        W,     LW,
     O        NZR,   LZR,    KZ0R,
     I        NZdef, LZrefR, IZB, IZT, icFR, CRR,  ipP, ipC, ipL)
      endif
      if (iErr.eq.0) then
         call ACCrfI (jedmy, jcdmy, icGz, icFR, -1, 'Z', ipL)
         call BBTvgt
     O       (iErr,
     O        WZR,
     W        W,
     I        VBBZ_Za,    VBBZ_cZa,   VBBZ_dZb,
     I        VBBZ_dWPb,  VBBZ_dWMb,  VBBZ_dXa,
     I        VBBZ_ddWPa, VBBZ_ddWOa, VBBZ_ddWMa, VBBZ_ddXa,
     I        NZR, LZR,   IZB,  icGz (1), icGz (2),  ipL)
      endif
      if (iErr.eq.0) then
         call AMTcns
     O       (iErr,
     I        LH,
     I        icFH, icFR, CRR, ipP, ipC, ipL)
      endif
      if (iErr.eq.0) then
         call AMCdvw (iErr, CSW, CLS, icFR, CRR, 'X', ipFI, iMA)
      endif
      if (iErr.eq.0) then
         call AMCdvw (iErr, CSW, CLS, icFR, CRR, 'Y', ipFI, iMA)
      endif
      if (iErr.eq.0) then
         call AMCdvw (iErr, CSW, CLS, icFR, CRR, 'Z', ipFI, iMA)
      endif
c
      MZR = NZR + KZ0R - 1
c
      call ACCrfI (jedmy, jcdmy, icGH, icFH, -1, 'H', ipL)
      call ACCrfI (jedmy, jcdmy, icGT, icFR, -1, 'T', ipL)
      if (iErr.eq.0) then
         call BBVrgt
     O       (iErr, jg,
     I        'VBBT', icGT, MH,  LH, MZR, LZR, CSW,  CLS, CRH,
     I        ipFI, IE,   iMA)
         if (iErr.eq.0) idGB (VGRPB_VBBT) = jg
      endif
      if (iErr.eq.0) then
         call BBVrgi
     O       (iErr, jg,
     I        'VBBI', icGH, MH,  LH, CSW,  CLS, CRH,
     I        ipFI, IE,   iMA)
         if (iErr.eq.0) idGB (VGRPB_VBBI) = jg
      endif
c
c$$$      if (iErr.eq.0) then
c$$$         call MUVmng
c$$$     O       (iErr, idGB,
c$$$     I        'VBBI',
c$$$     I        icFR, MH,  LH,  0,    0,  0,
c$$$     I        CSW,  CLS, CRR, ipFI, IE, iMA)
c$$$      endif
      return
      END
CCC_ & BBTpnm  ## Parameters initialization by namelist
      subroutine BBTpnm
     O    (iErr,
     O     IBB,  PBB,
     I     CR,   IFPi, IFPn, IFPl)
CCC_  - Declaration
      implicit none
CCC_   . Arguments
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   IBB (*)
      _INTENT(OUT,_REALSTD)  PBB (*)
      _INTENT(IN, character) CR*(*)
      _INTENT(IN, integer)   IFPi, IFPn, IFPl
CCC_   . Configuration
      character  CROOT * (8)
      _REALSTD   DENSR
      _REALSTD   HCAPR, CONDR
      namelist /NIPRMR/
     $     CROOT,
     $     DENSR,  HCAPR, CONDR
CCC_   . interior
      integer jc
CCC_  - Body
      iErr = 0
CCC_   . Configuration
      jc = 0
 200  continue
      call UUrwnd (iErr, IFPi)
c
 100  continue
c
      CROOT = ' '
c$$$      data PkapaR / 3.0d0 /
c$$$      data PhcapR / 1000.0d0 /
c$$$      data PRdens / 2700.0d0 /
      DENSR  = 2700.0d0
      HCAPR  = 1000.0d0
      CONDR  = 3.0d0 * 31556926.d0
c
      if (IFPi.ge.0) then
         READ  (IFPi, NIPRMR, IOSTAT = iErr)
      else if (IFPi.eq.-1) then
         READ  (*,    NIPRMR, IOSTAT = iErr)
      else
         iErr  = 0
         CROOT = CR
      endif
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
         if (COND_N(IFPn)) then
            write (IFPn, NIPRMR, IOSTAT = iErr)
         else if (COND_S(IFPn)) then
            write (*,   NIPRMR, IOSTAT = iErr)
         endif
      endif
CCC_   . Packing
      PBB (PBB_DENSR)  = DENSR
      PBB (PBB_HCAPR)  = HCAPR
      PBB (PBB_CONDR)  = CONDR
c
      call DAtrcU (IFPl, iErr, 'R', 'BBTPNM')
      RETURN
      END
CCC_ & BBitim  ## Time initialization batch
      subroutine BBitim
     O    (iErr,
     O     TBBT,
     I     TINI,  TEND,  DT,
     I     CR,    ipP,   ipC, ipL)
CCC_  - Declaration
      implicit none
CCC_   . Arguments
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,_REALSTD)  TBBT
      _INTENT(IN, _REALSTD)  TINI, TEND, DT
      _INTENT(IN, character) CR*(*)
      _INTENT(IN, integer)   ipP, ipC, ipL
c
      _REALSTD  TTI, TTE, TDT
CCC_  - Body
      iErr = 0
      TTI = TINI
      TTE = TEND
      TDT = DT
      call BBictm
     O    (iErr,
     M     TTI,   TTE,  TDT,
     I     ' ',   ' ',    ipP,   ipC,  ipL)
      call BBictm
     O    (iErr,
     M     TTI,   TTE,  TDT,
     I     ' ',   'B',    ipP,   ipC,  ipL)
      call BBictm
     O    (iErr,
     M     TTI,   TTE,  TDT,
     I     CR,    'B',    ipP,   ipC,  ipL)
      TBBT = TTI
CCC_   . reset error
      iErr = 0
      RETURN
      END
CCC_ & BBictm  ## Time initialization by namelist
      subroutine BBictm
     O    (iErr,
     M     TINI,  TEND,  DT,
     I     CR,    CB,    ipP,   ipC,  ipL)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,_REALSTD)  TINI, TEND, DT
      _INTENT(IN, character)   CR*(*)
      _INTENT(IN, character)   CB*(*)
      _INTENT(IN, integer)     ipP, ipC, ipL
c
      character  CROOT * (8)
      character  CBGL  * (8)
      namelist /NIBTIM/
     $     CROOT, CBGL,
     $     TINI,  TEND, DT
c
      _REALSTD dTINI, dTEND, dDT
c
      integer    LVEML
      parameter (LVEML = OPT_NAMELIST_OUTPUT_EMULATION)
CCC_  - Body
      iErr = 0
c
      dTINI = TINI
      dTEND = TEND
      dDT   = DT
c
      call UUrwnd (iErr, ipP)
      DO
         CROOT = ' '
         CBGL  = ' '
         TINI  = dTINI
         TEND  = dTEND
         DT    = dDT
         if (iErr.eq.0) READ (ipP, NIBTIM, IOSTAT = iErr)
         if (iErr.eq.0) then
            if (CROOT.eq.CR.and.CBGL.eq.CB) goto 100
         endif
         if (iErr.ne.0) goto 100
      ENDDO
 100  continue
      if (iErr.eq.0) then
         if (LVEML.gt.0) then
            call UNBbgn (iErr, 'NIBTIM',       ipC, LVEML)
            call UNBstr (iErr, 'CROOT', CR,    ipC, LVEML)
            call UNBstr (iErr, 'CBGL',  CB,    ipC, LVEML)
            call UNBrst (iErr, 'TINI',  TINI,  ipC, LVEML)
            call UNBrst (iErr, 'TEND',  TEND,  ipC, LVEML)
            call UNBrst (iErr, 'DT',    DT,    ipC, LVEML)
            call UNBend (iErr, 'NIBTIM',       ipC, LVEML)
         else
            CROOT = CR
            if (COND_N(ipC)) then
               write (ipC, NIBTIM)
            else if (COND_S(ipC)) then
               write (*,   NIBTIM)
            endif
         endif
      else
         TINI = dTINI
         TEND = dTEND
         DT   = dDT
      endif
c
      RETURN
      END
CCC_ & BBTvgt  ## geometry and integral table
      subroutine BBTvgt
     O    (iErr,
     O     VZ,
     O     W,
     I     KZa,  KCZa,  KDZb,
     I     K1p,         K1m,  K1x,
     I     K2p,  K2o,   K2m,  K2x,
     I     NZ,   LZ,    IZB,  icZa,  icZb, IFP)
C      follow MIFvgt MTFvgt
      implicit none
      _INTENT(OUT,integer)  iErr
      _INTENT(IN, integer)  NZ, LZ,  IZB
      _INTENT(OUT,_REALSTD) VZ (LZ, *)
      _INTENT(OUT,_REALSTD) W  (LZ, *)
      _INTENT(IN, integer)  KZa,   KCZa,  KDZb
      _INTENT(IN, integer)  K1p,      K1m, K1x
      _INTENT(IN, integer)  K2p, K2o, K2m, K2x
      _INTENT(IN, integer)  icZa,  icZb
      _INTENT(IN, integer)  IFP
      integer jcdmy, jz
      _REALSTD T, TP, TM, Ta, Tb
c
      iErr  = 0
      if (iErr.eq.0) then
         call ACCchD (iErr, jcdmy,               icZa,     'CP', IFP)
      endif
      if (iErr.eq.0) then
         call ACCrfD (iErr, jcdmy, VZ (1, KZa),  icZa, -1, 'CP', IFP)
      endif
      if (iErr.eq.0) then
         call ACCchD (iErr, jcdmy,               icZb,     'DP', IFP)
      endif
      if (iErr.eq.0) then
         call ACCrfD (iErr, jcdmy, VZ (1, KDZb), icZb, -1, 'DP', IFP)
      endif
      if (iErr.eq.0) then
         do jz = 1, LZ
            VZ (jz, KCZa)  =  1.0d0 - VZ (jz, KZa)
         enddo
      endif
CCC_   . grid sizes
      if (iErr.eq.0) then
         call ACCchD (iErr, jcdmy,            icZb,     'DC', IFP)
      endif
      if (iErr.eq.0) then
         call ACCrfD (iErr, jcdmy, W (1, 1),  icZb, -1, 'DC', IFP)
      endif
      if (iErr.eq.0) then
         call ACCchD (iErr, jcdmy,            icZa,     'DC', IFP)
      endif
      if (iErr.eq.0) then
         call ACCrfD (iErr, jcdmy, W (1, 2),  icZa, -1, 'DC', IFP)
      endif
CCC_   . first derivative
      if (iErr.eq.0) then
c$$$         do jz = IZB + 1, IZB + NZ
         do jz = 1, IZB + NZ
            T  = W (jz, 1)
            if (T.eq.0.0d0) then
               VZ (jz, K1p) = 0.0d0
               VZ (jz, K1m) = 0.0d0
            else
               VZ (jz, K1p) = +1.0d0 / T
               VZ (jz, K1m) = -1.0d0 / T
            endif
         enddo
      endif
CCC_   . second derivative
      if (iErr.eq.0) then
         VZ (1, K2p) = 0.0d0
         VZ (1, K2m) = 0.0d0
         VZ (1, K2o) = 0.0d0
c$$$         do jz = IZB + 1, IZB + NZ
         do jz = MAX (1, IZB) + 1, IZB + NZ
            T  = W (jz,     2)
            TP = W (jz,     1)
            TM = W (jz - 1, 1)
            if (T.eq.0.0d0) then
               VZ (jz, K2p) = 0.0d0
               VZ (jz, K2m) = 0.0d0
               VZ (jz, K2o) = 0.0d0
            else
               Ta = 1.0d0 / T / TP
               Tb = 1.0d0 / T / TM
               VZ (jz, K2p) = +Ta
               VZ (jz, K2m) = +Tb
               VZ (jz, K2o) = -(Ta + Tb)
            endif
         enddo
      endif
CCC_   . transformation factors
      if (iErr.eq.0) then
         call ACCchD (iErr, jcdmy,              icZa,     'D1', IFP)
      endif
      if (iErr.eq.0) then
         call ACCrfD (iErr, jcdmy, VZ (1, K1x), icZa, -1, 'D1', IFP)
      endif
      if (iErr.eq.0) then
         do jz = 1, IZB + NZ
            if (VZ (jz, K1x).eq.0.0d0) then
               VZ (jz, K1x) = 0.0d0
            else
               VZ (jz, K1x) = 1.0d0 / VZ (jz, K1x)
            endif
         enddo
      endif
      if (iErr.eq.0) then
         call ACCchD (iErr, jcdmy,              icZa,     'D2', IFP)
      endif
      if (iErr.eq.0) then
         call ACCrfD (iErr, jcdmy, VZ (1, K2x), icZa, -1, 'D2', IFP)
      endif
      if (iErr.eq.0) then
         call ACCchD (iErr, jcdmy,              icZa,     'D1', IFP)
      endif
      if (iErr.eq.0) then
         call ACCrfD (iErr, jcdmy, W  (1, 1),   icZa, -1, 'D1', IFP)
      endif
      if (iErr.eq.0) then
CC       ddy/dxx = - [ddx/dyy] / [dx/dy**3]
         do jz = 1, IZB + NZ
            if (W (jz, 1).eq.0.0d0) then
               VZ (jz, K2x) = 0.0d0
            else
               VZ (jz, K2x) = - VZ (jz, K2x) / (W (jz, 1) ** 3.0d0)
            endif
         enddo
      endif
CCC_   . geometry
      if (KZa.ne.0) then
         if (iErr.eq.0) then
            call ACCchD (iErr, jcdmy,              icZa,     'CP', IFP)
         endif
         if (iErr.eq.0) then
            call ACCrfD (iErr, jcdmy, VZ (1, KZa), icZa, -1, 'CP', IFP)
         endif
      endif
      RETURN
      END
CCC_ & BBVrgt  ## Set VBBT attributes
      subroutine BBVrgt
     O    (iErr, idVG,
     I     CGRP, icG,  MH,  LH, MZ, LZ, CSW,  CLS, CRT, IFPa, IE,  iMA)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   idVG
      _INTENT(IN, integer)   icG (*)
      _INTENT(IN, integer)   MH,  LH
      _INTENT(IN, integer)   MZ,  LZ
      _INTENT(IN, character) CGRP*(*)
      _INTENT(IN, character) CSW*(*)
      _INTENT(IN, character) CLS*(*), CRT*(*)
      _INTENT(IN, integer)   IFPa (*)
      _INTENT(IN, integer)   IE  (*)
      _INTENT(IN, integer)   iMA (*)
CCC_  * Body
      call AFBrgd
     O    (iErr,
     O     idVG,
     I     CGRP, MH,  LH,  MZ, LZ, VBBT_MAX, icG (1),
     I     CSW,  CLS, CRT, IFPa,   iMA)
c
      call AFBrgi (iErr, idVG, VBBT_T,    icG (1), 'T')
CC      call AFBrgi (iErr, idVG, VBBT_MAX,  icG (1), 'MAX')
c
      if (iErr.eq.0) call AFBgmf(iErr, idVG, ' ', ' ', IE, IFPa)
c
      RETURN
      END
CCC_ & BBVrgi  ## Set VBBI attributes
      subroutine BBVrgi
     O    (iErr, idVG,
     I     CGRP, icG,  MH, LH, CSW, CLS, CRT, IFPa, IE, iMA)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   idVG
      _INTENT(IN, integer)   icG (*)
      _INTENT(IN, integer)   MH, LH
      _INTENT(IN, character) CGRP*(*)
      _INTENT(IN, character) CSW*(*)
      _INTENT(IN, character) CLS*(*), CRT*(*)
      _INTENT(IN, integer)   IFPa (*)
      _INTENT(IN, integer)   IE  (*)
      _INTENT(IN, integer)   iMA (*)
CCC_  - Body
      call AFBrgd
     O    (iErr,
     O     idVG,
     I     CGRP, MH,  LH,  0, 0,  VBBI_MAX, icG (1),
     I     CSW,  CLS, CRT, IFPa,  iMA)
c
      call AFBrgi (iErr, idVG, VBBI_TU,   icG (1), 'Tu')
      call AFBrgi (iErr, idVG, VBBI_HR ,  icG (1), 'hR')
      call AFBrgi (iErr, idVG, VBBI_GH,   icG (1), 'gh')
CC      call AFBrgi (iErr, idVG, VBBI_MAX,  icG (1), 'MAX')
c
      if (iErr.eq.0) call AFBgmf(iErr, idVG, ' ', ' ', IE, IFPa)
c
      RETURN
      END
CCC_ & BBTupd  ## temperature update (solver)
      subroutine BBTupd
     O    (iErr,
     M     VBBT,  VBBW,
     I     VBBI,  PBB,  IBB,
     I     WZV,   T,    TINI, DT,
     I     MH,    LH,   NZ,   LZ,   KZ0,
     I     IFPl)
CCC_  - Declaration
      implicit none
c
      _INTENT(OUT,  integer)  iErr
c
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
      _INTENT(INOUT,_REALSTD) VBBT (LH, LZ, *)
      _INTENT(INOUT,_REALSTD) VBBW (LH, LZ, *)
      _INTENT(INOUT,_REALSTD) VBBI (LH, *)
      _INTENT(IN,   _REALSTD) T, TINI
      _INTENT(IN,   _REALSTD) DT
      _INTENT(IN,   _REALSTD) PBB  (*)
      _INTENT(IN,   integer)  IBB  (*)
      _INTENT(IN,   _REALSTD) WZV  (LZ, *)
      _INTENT(IN,   integer)  IFPl
c
      _REALSTD T0, CC, KR
      _REALSTD DPDZ, DTDP, DZDZ
      integer jzt, jzu
      integer jh, jz
      integer KSTATUS
      data    KSTATUS / 0 /
      save    KSTATUS
      integer KSTT0, KSTTTR, KSTTST
      parameter (KSTT0=0, KSTTTR=1, KSTTST=2)
CCC_  - Body
      iErr = 0
 101  format('BBTUPD/transient',1x, F10.1, 1x, F10.1)
 102  format('BBTUPD/steady',   1x, F10.1, 1x, F10.1)
      if (T.ge.TINI) then
         if (KSTATUS.ne.KSTTTR) then
            write (IFPl, 101) T, TINI
            KSTATUS = KSTTTR
         endif
         if (iErr.eq.0) then
            call BBTcxs
     O          (iErr,
     M           VBBW,
     I           VBBT, VBBI,
     I           WZV,  PBB,  IBB,
     I           MH,   LH,   NZ,   LZ,  KZ0,
     I           IFPl)
         endif
         if (iErr.eq.0) then
            call BBTbld
     O          (iErr,
     M           VBBW,
     I           VBBT, VBBI,
     I           WZV,  PBB,  IBB, DT,
     I           MH,   LH,   NZ,   LZ,  KZ0,
     I           IFPl)
         endif
         if (iErr.eq.0) then
            call BBTslv
     O          (iErr,
     M           VBBW,
     W           VBBI(1, VBBI_W),
     I           VBBW_W1,  VBBW_W2,
     I           VBBW_QU,  VBBW_QD, VBBW_QL, VBBW_QB,
     I           MH,   LH,   NZ,  LZ,  KZ0,
     I           IFPl)
         endif
         if (iErr.eq.0) then
            call UV1cpc
     $           (VBBT, VBBW, MH, LH, NZ, LZ, KZ0, VBBT_T, VBBW_W1)
         endif
      else
         if (KSTATUS.ne.KSTTST) then
            write (IFPl, 102) T, TINI
            KSTATUS = KSTTST
         endif
         JZT = KZ0 + NZ - 1
         KR  = PBB(PBB_CONDR)
         do jz = JZT, JZT
            do jh = 1, MH
               VBBT(jh, jz, VBBT_T) = VBBI(jh, VBBI_TU)
            enddo
         enddo
         do jz = JZT - 1, 1, -1
            jzu = jz + 1
            DPDZ = WZV (jz, VBBZ_dXa)
            do jh = 1, MH
               VBBT(jh, jz, VBBT_T) =
     $              ( VBBI(jh, VBBI_GH) / DPDZ / KR * VBBI (jh, VBBI_HR)
     $              - VBBT(jh, jzu, VBBT_T) * WZV (jz, VBBZ_dWPb))
     $              / WZV (jz, VBBZ_dWMb)
            enddo
         enddo

      endif
      END
CCC_ & BBTcxs  ## equation coefficients  (temperature independent)
      subroutine BBTcxs
     O    (iErr,
     M     VBBW,
     I     VBBT, VBBI,
     I     WZV,  PBB,  IBB,
     I     NH,   LH,   NZ,   LZ,  KZ0,
     I     IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  NH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
c
      _INTENT(INOUT,_REALSTD) VBBW (LH, LZ, *)
      _INTENT(IN,   _REALSTD) VBBT (LH, LZ, *)
      _INTENT(IN,   _REALSTD) VBBI (LH, *)
c
      _INTENT(IN,   _REALSTD) PBB  (*)
      _INTENT(IN,   integer)  IBB  (*)
      _INTENT(IN,   _REALSTD) WZV  (LZ, *)
c
      _INTENT(IN,   integer)  IFPl
c
      integer   jh
      integer   jzz, jz
c
      _REALSTD  B0, B1, B2, B3, B33
      _REALSTD  D0, D1, D2, D3, D33
      _REALSTD  E3
c
      _REALSTD  DZDT, DZDX, DZDY, DZDZ, DDZDZ
      _REALSTD  DPDZ, DDPDZ
c
      _REALSTD  DENSR, CONDR, HCAPR
      _REALSTD  TDC
CCC_  - Body
      iErr = 0
c
      CONDR = PBB (PBB_CONDR)
      HCAPR = PBB (PBB_HCAPR)
c
      DDZDZ = 0.0d0
      DENSR = PBB (PBB_DENSR)
c
      do    jzz = 1, NZ - 1
         jz = KZ0 + jzz - 1
CCC_   . transformation factors (Z-[Z])
         DPDZ  = WZV (jz, VBBZ_dXa)
         DDPDZ = WZV (jz, VBBZ_ddXa)
         do jh = 1, NH
CCC_   . transformation factors (z-Z)
            DZDT = 0.0d0
            DZDX = 0.0d0
            DZDY = 0.0d0
            DZDZ = 1.0d0 / VBBI (jh, VBBI_HR)
CCC_   , density . capacity
            TDC = DENSR * HCAPR
CCC_   . B0
            B0  = -1.0d0
CCC_   . Bi = - Ui + (1/rho c) dK/dxi
            B1  = 0.0d0
            B2  = 0.0d0
            B3  = 0.0d0
     $           + 0.0d0 / TDC
CCC_   . B33
            B33 = CONDR / TDC
c$$$            B33 = VMTW(jh, jz, VMTW_kti) / TDC
CCC_   . D0 (not necessary)
CCC_   . D[12]
            D1  = B1
            D2  = B2
CCC_   . D3  = Bi   dZ/dxi + d^2 ZZ/dxi^2 Bii
            D3  =+(B0  * DZDT)
     $           +(B1  * DZDX + B2  * DZDY)
     $           +(B3  * DZDZ)
     $           +(B33 * DDZDZ)
CCC_   . D33 = Bii [dZ/dxi]^2
            D33 = B33 * (DZDZ * DZDZ)
CCC_   . E0 (not necessary)
CCC_   . E[12]
            VBBW (jh, jz, VBBW_E1) = D1
            VBBW (jh, jz, VBBW_E2) = D2
CCC_   . E3  = D3   d[Z]/dZ + D33 d^2[Z]/dZ^2
            E3 = +(D3  * DPDZ)
     $           +(D33 * DDPDZ)
CC       todo: central difference in vertical
            VBBW (jh, jz, VBBW_E3p) = MAX (0.0d0, E3)
            VBBW (jh, jz, VBBW_E3m) = MIN (0.0d0, E3)
CCC_   . E33 = D33 [d[Z]/dZ]^2
            VBBW (jh, jz, VBBW_E33) =
     $           + D33 * (DPDZ * DPDZ)
         enddo
      enddo
      RETURN
      END
CCC_ & BBTbld  ## matrix builder core (temperature dependent)
      subroutine BBTbld
     O    (iErr,
     M     VBBW,
     I     VBBT, VBBI,
     I     WZV,  PBB,  IBB, DT,
     I     NH,   LH,   NZ,   LZ,  KZ0,
     I     IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  NH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
c
      _INTENT(INOUT,_REALSTD) VBBW (LH, LZ, *)
      _INTENT(IN,   _REALSTD) VBBT (LH, LZ, *)
      _INTENT(IN,   _REALSTD) VBBI (LH, *)
c
      _INTENT(IN,   _REALSTD) PBB  (*)
      _INTENT(IN,   integer)  IBB  (*)
      _INTENT(IN,   _REALSTD) DT
      _INTENT(IN,   _REALSTD) WZV  (LZ, *)
c
      _INTENT(IN,   integer)  IFPl
c
      integer   jh,  jhti
      integer   jzz, jz
      integer   kfw, kbw
c
      _REALSTD  E0, E0DT
      _REALSTD  BU, BD, BL, BB
      _REALSTD  QU, QD, QL, QB
      _REALSTD  TKDD
      _REALSTD  DZDZ,  DPDZ
      _REALSTD  BDSWu, BDSWl
      _REALSTD  CONDR
      _REALSTD  TBa, TBb
CCC_  - Body
      iErr  = 0
      kfw   = 1
      kbw   = 2
      E0    = -1.0d0
      E0DT  = E0 / DT
      CONDR = PBB (PBB_CONDR)
CCC_   . loop interior
      do    jzz = 1, NZ - 1
         jz = KZ0 + jzz - 1
         do jh = 1, NH
            jhti = jh
            VBBW (jhti, jz, VBBW_QU) =
     $           +WZV (jz,   VBBZ_ddWPa)  * VBBW (jh, jz, VBBW_E33)
     $           +WZV (jz,   VBBZ_dWPb)   * VBBW (jh, jz, VBBW_E3p)
            VBBW (jhti, jz, VBBW_QL) =
     $           +WZV (jz,   VBBZ_ddWMa)  * VBBW (jh, jz, VBBW_E33)
     $           +WZV (jz-1, VBBZ_dWMb)   * VBBW (jh, jz, VBBW_E3m)
            VBBW (jhti, jz, VBBW_QD) =
     $           + WZV (jz,   VBBZ_ddWOa) * VBBW (jh, jz, VBBW_E33)
     $           +(WZV (jz,   VBBZ_dWMb)  * VBBW (jh, jz, VBBW_E3p)
     $            +WZV (jz-1, VBBZ_dWPb)  * VBBW (jh, jz, VBBW_E3m))
     $           + E0DT
            VBBW (jhti, jz, VBBW_QB) =
     $           + E0DT * VBBT (jh, jz, VBBT_T)
         enddo
      enddo
CCC_   . bottom
c$$$      if (IMM (IMD_TBDZ).eq. SW_TBDZ_CENTER) then
         BDSWl = 0.5d0
         BDSWu = 0.5d0
c$$$      else
c$$$         BDSWl = 1.0d0
c$$$         BDSWu = 0.0d0
c$$$      endif
      do    jzz = 1,  1
         jz = KZ0 + jzz - 1
         DPDZ  = WZV (jz, VBBZ_dXa)
         do jh = 1,  NH
            jhti = jh
            TBa   = 0.0d0
            TBb   = 1.0d0 - TBa
c$$$            DZDZ  = VMHW (jh, VMHW_Hinv)
            DZDZ  = 1.0d0 / VBBI (jh, VBBI_HR)
            TKDD  = CONDR * DPDZ * DZDZ
c$$$            TKDD  = VBBW (jh, jz, VBBW_kti) * DPDZ * DZDZ
            BU    = TKDD * BDSWu * WZV (jz,   VBBZ_dWPb)
            BL    = TKDD * BDSWl * WZV (jz-1, VBBZ_dWMb)
            BD    = TKDD *
     $           (BDSWu * WZV (jz,   VBBZ_dWMb)
     $           +BDSWl * WZV (jz-1, VBBZ_dWPb))
            BB    = VBBI (jh, VBBI_GH)
            QU    = VBBW (jhti, jz, VBBW_QU)
            QL    = VBBW (jhti, jz, VBBW_QL)
            QD    = VBBW (jhti, jz, VBBW_QD)
            QB    = VBBW (jhti, jz, VBBW_QB)
            VBBW (jhti, jz, VBBW_QU) = (QU * BL - QL * BU) * TBb
            VBBW (jhti, jz, VBBW_QD) = (QD * BL - QL * BD) * TBb + TBa
            VBBW (jhti, jz, VBBW_QB) = (QB * BL - QL * BB) * TBb
            VBBW (jhti, jz, VBBW_QL) = 0.0d0
         enddo
      enddo
CCC_   . surface
      do    jzz = NZ, NZ
         jz = KZ0 + jzz - 1
         do jh = 1,  NH
            jhti = jh
            VBBW (jhti, jz, VBBW_QU) = 0.0d0
            VBBW (jhti, jz, VBBW_QL) = 0.0d0
            VBBW (jhti, jz, VBBW_QD) = E0DT * 1.0d0
            VBBW (jhti, jz, VBBW_QB) = E0DT * VBBI (jh, VBBI_TU)
         enddo
      enddo
      RETURN
      END
CCC_ & BBTslv  ## matrix solver core (z outer)
      subroutine BBTslv
     O    (iErr,
     M     VX,
     W     W,
     I     KX,   KW,   KU,  KD,  KL,  KB,
     I     MH,   LH,   NZ,  LZ,  KZ0,
     I     IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
      _INTENT(INOUT,_REALSTD) VX (LH, LZ, *)
      _INTENT(INOUT,_REALSTD) W  (*)
      _INTENT(IN,   integer)  KX, KW
      _INTENT(IN,   integer)  KU, KD, KL, KB
      _INTENT(IN,   integer)  IFPl
c
      integer   jh
      integer   jzz, jz
CCC_  - Body
      iErr  = 0
c
      do jh = 1, MH
         W  (jh) = VX (jh, KZ0, KD)
         VX (jh, KZ0, KX) = VX (jh, KZ0, KB) / W (jh)
      enddo
c
      do jzz = 2, NZ
         jz = KZ0 + jzz - 1
         do jh = 1, MH
            VX (jh, jz, KW) =
     $           VX (jh, jz - 1, KU) / W (jh)
            W  (jh) =
     $           VX (jh, jz, KD) - VX (jh, jz, KL) * VX (jh, jz, KW)
            VX (jh, jz, KX) =
     $           (VX (jh, jz, KB) - VX (jh, jz, KL) *  VX(jh, jz-1, KX))
     $           / W (jh)
         enddo
      enddo
c
      do jzz = NZ - 1, 1, -1
         jz = KZ0 + jzz - 1
         do jh = 1, MH
            VX (jh, jz, KX) =
     $           VX (jh, jz,KX) - (VX (jh, jz+1, KW) * VX (jh, jz+1,KX))
         enddo
      enddo
      RETURN
      END
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
