C arpeggio/aedlra.F --- Arpeggio/Elements dealer
C Maintainer:  SAITO Fuyuki
C Created: Jun 16 2010
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2020/09/17 08:39:37 fuyuki aedlra.F>'
#define _FNAME 'arpeggio/aedlra.F'
#define _REV   'Arpeggio 1.0'
CCC_! MANIFESTO
C
C Copyright (C) 2010--2020
C           Japan Agency for Marine-Earth Science and Technology
C
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
CCC_* Common macros
#include "ofdlct.h" /* fortran dialect */
#include "ologfm.h" /* log unit */
#include "oarpea.h"
#include "ounelv.h" /* namelist emulation levels */
CCC_* Function-like macro
#define _NG2NU(NG,LO) (NG) + MAX (0, (LO)) * 2
#define _NU2NB(NU,LB) ((NU) - 1) / (LB) + 1
#define _ND2NB(ND,LB) ((ND) - 1) / (LB) + 1
#define _NU2NBwe(NU,LW,LE) ((NU-2*(LW))-1)/(LE)+1
c$$$#define _NG2NW(NG,LO) (NG) + MAX (0, (LO)) * 2
c$$$#define _NW2NB(NW,LB) ((NW) - 1) / (LB) + 1
c$$$#define _NF2NB(NF,LB) ((NF) - 1) / (LB) + 1
c$$$#define _NW2NBwe(NW,LW,LE) ((NW-2*(LW))-1)/(LE)+1
CCC_* Test
#ifndef   TEST_AEDLRA
#  define TEST_AEDLRA 0
#endif
#ifndef    OPT_NAMELIST_OUTPUT_EMULATION
#  define  OPT_NAMELIST_OUTPUT_EMULATION _UNMLEM_LEVEL_ENTRY
#endif
CCC_* Description
CC     IE (LIE)    element-attributes table
CC     NXG, NYG    minimum required sizes (without overlap)
CC     LXB, LYB    unit block lengths (full length) (L[XY]C+2*L[XY]W)
CC                 negative for equal division
CC                 zero for full-width/height block
CC     LXW, LYW    wing lengths of a block
CC                 negative to keep block length
CC                 positive to extend block length
CC     LXE, LYE    interior block length minimum (internally computed)
CC     LXO, LYO    overlapped boundary widths
CC     IR,  NR     rank number and size
CC     ISH         rank shift number at next row
CC                 if ISH>=NR or ISH<=-NR or ISH==0, then automatic
CC                 column adjustment is not performed
CC     KDL         dealer kind (00-11 binary)
CC                 11==3 should be default
CC     CROOT       ID character
CC
CCC_ + dealer kind bit 0 (KDLnb)
CCC_  - KDLnb 0
CC
CC                    NXG
CC     NYG+1  3 4 .. x x x x x x
CC     NYG    o o o .... x 0 1 2
CC     :
CC     1
CC
CCC_  - KDLnb 1 (smaller)
CC
CC                    NXG
CC     NYG    o o o ...... P x x
CC     :
CC     1
CCC_ + dealer kind bit 1 (KDLbi)
CCC_  - [Y] KDLbi 0 (sequential in block)
CC        4 5 6 : . . .
CC        1 2 3 : 7 8 9
CC
CCC_  - [X] KDLbi 1 (sequential in x)
CC              : . . . :
CC        1 2 3 : 4 5 6 : 7 8 9 ...
CC
CCC_* [AEA] Attributes generation
CCC_ & AEAnsa  ## Arpeggio/Dealer/A table set args by namelist
      subroutine AEAnsa
     O    (iErr,
     O     IE,
     I     LIE,
     I     NXGd, NYGd, LXBd, LYBd, LXWd,   LYWd, LXOd, LYOd,
     I     IRd,  NRd,  ISHd, KDLd, CROOTd, LVDBGd,
     I     IFPi, IFPn, IFPl)
CCC_  * Declaration
      implicit none
CCC_   = Arguments
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   LIE
      _INTENT(OUT,integer)   IE (LIE)
      _INTENT(IN, integer)   NXGd,  NYGd, LXBd, LYBd
      _INTENT(IN, integer)   LXWd,  LYWd, LXOd, LYOd
      _INTENT(IN, integer)   IRd,   NRd,  ISHd, KDLd
      _INTENT(IN, character) CROOTd*(*)
      _INTENT(IN, integer)   IFPi,  IFPn,  IFPl
      _INTENT(IN, integer)   LVDBGd
CCC_   = Configuration
      character  CROOT * (32)
      integer    NXG,  NYG,  LXB,  LYB
      integer    LXW,  LYW,  LXO,  LYO
      integer    IR,   NR,   ISH,  KDL
      integer    LVDBG
      integer    IOSR
      namelist /NIEDLA/
     $     CROOT,
     $     KDL, NXG, NYG,
     $     LXO, LYO, LXW, LYW,   LXB, LYB,
     $     IR,  NR,  ISH, LVDBG, IOSR
CCC_   = Interior
      integer    LVEML
      parameter (LVEML = OPT_NAMELIST_OUTPUT_EMULATION)
c
      integer    MaxE
      parameter (MaxE = 3)
      integer    jErrC
      integer    IOS
      logical    OEOF
      logical    OSET
CCC_  * Body
      iErr  = 0
      jErrC = 0
      OSET  = .false.
CCC_   + if no parameter unit then use default
      if (IFPi.lt.-1) then
         OSET = .true.
         KDL   = KDLd
         NXG   = NXGd
         NYG   = NYGd
         LXO   = LXOd
         LYO   = LYOd
         LXB   = LXBd
         LYB   = LYBd
         LXW   = LXWd
         LYW   = LYWd
         IR    = IRd
         NR    = NRd
         ISH   = ISHd
         LVDBG = LVDBGd
         IOS   = 0
CCC_   + read namelist
      else
         call UUrwnd (IOS,  IFPi)
         DO
            CROOT = ' '
            IOSR  = 0
c
            KDL   = KDLd
            NXG   = NXGd
            NYG   = NYGd
            LXO   = LXOd
            LYO   = LYOd
            LXB   = LXBd
            LYB   = LYBd
            LXW   = LXWd
            LYW   = LYWd
            IR    = IRd
            NR    = NRd
            ISH   = ISHd
            LVDBG = LVDBGd
            if (IOS .eq. 0) then
               if (IFPi.ge.0) then
                  read (IFPi, NIEDLA, IOSTAT = IOS)
               else
                  read (*,    NIEDLA, IOSTAT = IOS)
               endif
            endif
            if (IOS.eq.0) then
               if (CROOT.eq.CROOTd) then
                  OSET = .true.
                  goto 900
               endif
            else
               call UUieof (OEOF, IOS)
               if (OEOF) goto 900
               jErrC = jErrC + 1
               if (jErrC.gt.MaxE) goto 900
            endif
         ENDDO
 900     continue
      endif
CCC_   + write namelist
      CROOT = CROOTd
      IOSR  = IOS
      if (LVEML.gt.0) then
         call UNBbgn (iErr, 'NIEDLA',       IFPn, LVEML)
         call UNBint (iErr, 'IOSR',  IOSR,  IFPn, LVEML)
         call UNBstr (iErr, 'CROOT', CROOT, IFPn, LVEML)
         call UNBint (iErr, 'KDL',   KDL,   IFPn, LVEML)
         call UNBint (iErr, 'NXG',   NXG,   IFPn, LVEML)
         call UNBint (iErr, 'NYG',   NYG,   IFPn, LVEML)
         call UNBint (iErr, 'LXO',   LXO,   IFPn, LVEML)
         call UNBint (iErr, 'LYO',   LYO,   IFPn, LVEML)
         call UNBint (iErr, 'LXB',   LXB,   IFPn, LVEML)
         call UNBint (iErr, 'LYB',   LYB,   IFPn, LVEML)
         call UNBint (iErr, 'LXW',   LXW,   IFPn, LVEML)
         call UNBint (iErr, 'LYW',   LYW,   IFPn, LVEML)
         call UNBint (iErr, 'IR',    IR,    IFPn, LVEML)
         call UNBint (iErr, 'NR',    NR,    IFPn, LVEML)
         call UNBint (iErr, 'ISH',   ISH,   IFPn, LVEML)
         call UNBint (iErr, 'LVDBG', LVDBG, IFPn, LVEML)
         call UNBend (iErr, 'NIEDLA',       IFPn, LVEML)
      else
         if      (COND_N(IFPn)) then
            write (IFPn, NIEDLA)
         else if (COND_S(IFPn)) then
            write (*,    NIEDLA)
         endif
      endif
CCC_   + store results
      call AEAarg
     $    (IE,
     $     LIE, NXG, NYG, LXB, LYB, LXW, LYW, LXO, LYO,
     $     IR,  NR,  ISH, KDL, LVDBG)
CCC_   + return
      if (OSET) then
         iErr = 0
      else if (jErrC.gt.MaxE) then
         iErr = -1
      else
         iErr = 1
      endif
      call DATrcU (IFPl, iErr, 'R', 'AEANSA')
      RETURN
      END
CCC_ & AEAarg  ## Reset/Store argument attributes
      subroutine AEAarg
     O    (IE,
     I     LIE, NXG, NYG, LXB, LYB, LXW, LYW, LXO, LYO,
     I     IR,  NR,  ISH, KDL, LVDBG)
CCC_  * Arguments
      implicit none
      _INTENT(OUT,integer) IE (*)
      _INTENT(IN, integer) LIE
      _INTENT(IN, integer) NXG,  NYG, LXB, LYB
      _INTENT(IN, integer) LXW,  LYW, LXO, LYO
      _INTENT(IN, integer) IR,   NR,  ISH, KDL
      _INTENT(IN, integer) LVDBG
CCC_  * Body
CCC_   + reset table
      call AETrst (IE, LIE)
c
      EA_LVDBG(IE)    = LVDBG
c
      EA_argKDL(IE)   = KDL
      EA_argNXG(IE)   = NXG
      EA_argNYG(IE)   = NYG
      EA_argLXO(IE)   = LXO
      EA_argLYO(IE)   = LYO
      EA_argLXB(IE)   = LXB
      EA_argLYB(IE)   = LYB
      EA_argLXW(IE)   = LXW
      EA_argLYW(IE)   = LYW
      EA_argIR(IE)    = IR
      EA_argNR(IE)    = NR
      EA_argISH(IE)   = ISH
      RETURN
      END
CCC_ & AEAgnw  ## Arpeggio/Dealer/A table generation wrapper
      subroutine AEAgnw
     O    (iErr,
     O     IE,
     I     LIE,
     I     NXG,   NYG, LXB, LYB, LXW, LYW, LXO, LYO,
     I     IR,    NR,  ISH, KDL,
     I     CROOT,
     I     LVDBG, IFPl)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   LIE
      _INTENT(OUT,integer)   IE (LIE)
      _INTENT(IN, integer)   NXG,  NYG
      _INTENT(IN, integer)   LXB,  LYB
      _INTENT(IN, integer)   LXW,  LYW
      _INTENT(IN, integer)   LXO,  LYO
      _INTENT(IN, integer)   IR,   NR
      _INTENT(IN, integer)   ISH,  KDL
      _INTENT(IN, character) CROOT*(*)
      _INTENT(IN, integer)   IFPl
      _INTENT(IN, integer)   LVDBG
CCC_  * Body
      call AEAarg
     O    (IE,
     I     LIE, NXG, NYG, LXB, LYB, LXW, LYW, LXO, LYO,
     I     IR,  NR,  ISH, KDL, LVDBG)
      call AEAgen (iErr, IE, LIE,  CROOT, IFPl)
      RETURN
      END
CCC_ & AEAgen  ## Arpeggio/Dealer/A table generation core
      subroutine AEAgen
     O    (iErr,
     O     IE,
     I     LIE, CROOT,IFPl)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   LIE
      _INTENT(OUT,integer)   IE (LIE)
      _INTENT(IN, character) CROOT*(*)
      _INTENT(IN, integer)   IFPl
CCC_  * Body
      iErr = 0
CCC_   + arguments adjustment
      if (iErr.eq.0) call AEArag (iErr, IE,  LIE, CROOT, IFPl)
CCC_   + sizes creation/registration
      if (iErr.eq.0) call AEArmn (iErr, IE,  LIE, CROOT, IFPl)
CCC_   + neighborhood creation/registration
      if (iErr.eq.0) call AEArnh (iErr, IE,  LIE, CROOT, IFPl)
CCC_   + neighborhood creation/registration (loop)
      if (iErr.eq.0) call AEAlpr (iErr, IE,  LIE, CROOT, IFPl)
CCC_   + periodicity creation/registration
      if (iErr.eq.0) call AEArpr (iErr, IE,  LIE, CROOT, IFPl)
CCC_   + index creation/registration
      if (iErr.eq.0) call AEArid (iErr, IE,  LIE, CROOT, IFPl)
CCC_   + report
      if (iErr.eq.0) call AEArep (iErr, IE,  LIE, CROOT, IFPl)
CCC_   + trace
      call DAtrcU (IFPl, iErr, 'R', 'AESGEN')
      RETURN
      END
CCC_ & AEArag  ## Arpeggio/Dealer/A arguments adjustment/registration
      subroutine AEArag
     O    (iErr,  IE,
     I     LIE,   CROOT, IFPl)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   LIE
      _INTENT(INOUT,integer)   IE (LIE)
      _INTENT(IN,   character) CROOT*(*)
      _INTENT(IN,   integer)   IFPl
      integer NXG, NYG, LXO,  LYO, KDL
      integer LXE, LYE, LXEz, LYEz
      integer LXB, LYB, LXBz, LYBz
      integer LXW, LYW, LXWz, LYWz
      integer IR,  NR,  NRz
      integer ISH,      ISHz
      integer LVDBG
CCC_  * Body
      iErr  = 0
      LVDBG = EA_LVDBG(IE)
c
      KDL = EA_argKDL(IE)
      NXG = EA_argNXG(IE)
      NYG = EA_argNYG(IE)
      LXO = EA_argLXO(IE)
      LYO = EA_argLYO(IE)
      LXB = EA_argLXB(IE)
      LYB = EA_argLYB(IE)
      LXW = EA_argLXW(IE)
      LYW = EA_argLYW(IE)
      IR  = EA_argIR(IE)
      NR  = EA_argNR(IE)
      ISH = EA_argISH(IE)
      LXE = 0
      LYE = 0
c
      call AEAmsg
     I    (CROOT, 0,
     I     IR,    NR,  KDL, NXG, NYG,
     I     LXB,   LYB, LXO, LYO, ISH, LXW, LYW, LXE, LYE,
     I     LVDBG, IFPl)
c
      call AEAadj
     O    (iErr,
     O     LXEz, LYEz,
     O     LXBz, LYBz, LXWz, LYWz, NRz, ISHz,
     I     LXB,  LYB,  LXW,  LYW,  NR,  ISH,
     I     NXG,  NYG,  LXO,  LYO)
c
      LXB = LXBz
      LYB = LYBz
      LXW = LXWz
      LYW = LYWz
      LXE = LXEz
      LYE = LYEz
      NR  = NRz
      ISH = ISHz
c
      call AEAmsg
     I    (CROOT, 1,
     I     IR,    NR,  KDL, NXG, NYG,
     I     LXB,   LYB, LXO, LYO, ISH, LXW, LYW, LXE, LYE,
     I     LVDBG, IFPl)
c
      call AEArcf
     O    (iErr,  IE,
     I     LIE,
     I     CROOT, LVDBG, IFPl,
     I     NXG,   NYG,   LXB, LYB, LXO, LYO,
     I     LXE,   LYE,   LXW, LYW, IR,  NR, ISH, KDL)
c
      RETURN
      END
CCC_ & AEAadj  ## Arpeggio/Dealer/A arguments adjustment
      subroutine AEAadj
     O    (iErr,
     O     LXEz, LYEz,
     O     LXBz, LYBz, LXWz, LYWz, NRz, ISHz,
     I     LXB,  LYB,  LXW,  LYW,  NR,  ISH,
     I     NXG,  NYG,  LXO,  LYO)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   LXEz, LYEz
      _INTENT(OUT,integer)   LXBz, LYBz, LXWz, LYWz
      _INTENT(OUT,integer)   NRz,  ISHz
      _INTENT(IN, integer)   LXB,  LYB,  LXW,  LYW
      _INTENT(IN, integer)   NR,   ISH
      _INTENT(IN, integer)   NXG,  NYG,  LXO,  LYO
      integer NXU, NYU, NBX
CCC_  * Body
      iErr = 0
CCC_   + total processe
      NRz = MAX (1, NR)
CCC_   + number of elements required (wide)
      NXU = _NG2NU(+NXG, +LXO)
      NYU = _NG2NU(+NYG, +LYO)
CCC_   + block/wing length adjustment
      call AEAabw (LXEz, LXBz, LXWz, LXB,  LXW,  NXU)
      call AEAabw (LYEz, LYBz, LYWz, LYB,  LYW,  NYU)
CCC_   + number of blocks
CC      NBX = _NW2NB(+NXW,+LXBz)
      NBX = _NU2NBwe(+NXU,+LXWz,+LXEz)
CCC_   + shift
      ISHz = ISH
      if (ISHz.ge.NRz .or. ISHz.le.-NRz .or. ISHZ.eq.0) then
         ISHz = MOD (NBX, NRz)
      else
         if (ISHz.lt.0) ISHz = ISHz + NRz
         ISHz = MOD (ISHz, NRz)
      endif
      RETURN
      END
CCC_ & AEAabw  ## Arpeggio/Dealer/A arguments adjustment (block/wing)
      subroutine AEAabw
     O    (LEz, LBz, LWz,
     I          LB,  LW,  NU)
      implicit none
      _INTENT(OUT,integer) LEz, LBz, LWz
      _INTENT(IN, integer)      LB,  LW
      _INTENT(IN, integer) NU
CC       if LB negative: total (-LX) blocks (with equal length)
CC       if LB zero:     1 block (with domain length)
      if (LB.lt.0) then
         LWz = ABS (LW)
         LEz = (NU - 2 * LWz - 1) / (-LB) + 1
         LBz = LEz + 2 * LWz
      else
         if (LB.eq.0) then
            LEz = NU
         else
            LEz = LB
         endif
         if (LW.gt.0) then
            LWz = LW
            LBz = LEz + 2 * LWz
         else
            LBz = LB
            LWz = - LW
            LEz = LBz - 2 * LWz
         endif
      endif
      RETURN
      END
CCC_ & AEAmsg  ## Arpeggio/Dealer/A message
      subroutine AEAmsg
     I    (CROOT, Kpass,
     I     IR,    NR,  KDL, NXG, NYG,
     I     LXB,   LYB, LXO, LYO, ISH, LXW, LYW, LXE, LYE,
     I     LVDBG, IFPl)
      implicit none
      _INTENT(IN,character) CROOT*(*)
      _INTENT(IN,integer)   Kpass
      _INTENT(IN,integer)   IR,    NR,  KDL, NXG, NYG
      _INTENT(IN,integer)   LXB,   LYB, LXO, LYO, ISH, LXW, LYW
      _INTENT(IN,integer)   LXE,   LYE
      _INTENT(IN,integer)   LVDBG, IFPl
c
      if (LVDBG.ge.0) then
 101     format ('AEAGNW:', A, ':', I1, 1x,
     $        I4, I4,  I2, 2I5,
     $        1x, I4,  1x, 2I3,
     $        1x, 2I5, 1x, 2I5, 1x, 2I3)
         if      (COND_N(IFPl)) then
            write (IFPl, 101) _TRIM(CROOT), Kpass,
     $           IR,  NR,  KDL, NXG, NYG,
     $           ISH, LXO, LYO,
     $           LXE, LYE, LXB, LYB, LXW, LYW
         else if (COND_S(IFPl)) then
            write (*,    101) _TRIM(CROOT), Kpass,
     $           IR,  NR,  KDL, NXG, NYG,
     $           ISH, LXO, LYO,
     $           LXE, LYE, LXB, LYB, LXW, LYW
         endif
      endif
      RETURN
      END
CCC_ & AEArcf  ## Arpeggio/Dealer/A table registration (configuration)
      subroutine AEArcf
     O    (iErr,  IE,
     I     LIE,
     I     CROOT, LVDBG, IFPl,
     I     NXG,   NYG,   LXB, LYB, LXO, LYO,
     I     LXE,   LYE,   LXW, LYW, IR,  NR, ISH, KDL)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   LIE
      _INTENT(INOUT,integer)   IE (LIE)
      _INTENT(IN,   character) CROOT*(*)
      _INTENT(IN,   integer)   LVDBG
      _INTENT(IN,   integer)   IFPl
      _INTENT(IN,   integer)   NXG, NYG, LXB, LYB, LXO, LYO
      _INTENT(IN,   integer)   LXE, LYE, LXW, LYW
      _INTENT(IN,   integer)   IR,  NR,  ISH, KDL
      integer KDLnb, KDLbi
CCC_  * Body
      iErr = 0
CCC_   + table assignment
      KDLnb = MOD (KDL, 2)
      KDLbi = MOD (KDL / 2, 2)
      EA_KDL(IE)   = KDL
      EA_KDLnb(IE) = KDLnb
      EA_KDLbi(IE) = KDLbi
      EA_NXG(IE)   = NXG
      EA_NYG(IE)   = NYG
      EA_LXB(IE)   = LXB
      EA_LYB(IE)   = LYB
      EA_LXO(IE)   = LXO
      EA_LYO(IE)   = LYO
      EA_LXE(IE)   = LXE
      EA_LYE(IE)   = LYE
      EA_LXW(IE)   = LXW
      EA_LYW(IE)   = LYW
      EA_IR(IE)    = IR
      EA_NR(IE)    = NR
      EA_ISH(IE)   = ISH
CCC_   + log
      if (LVDBG.gt.0) then
 101     format (A, ':K', I3, 1x, 2I2)
 201     format (A, ':I', 2I5, ' : ', 2I5)
 202     format (A, ':B', 2I5, ' : ', 2I5)
 203     format (A, ':P', I4, I4, I4)
 204     format (A, ':W', 2I5, ' : ', 2I5)
         if      (COND_N(IFPl)) then
            write (IFPl, 101) _TRIM(CROOT), KDL, KDLnb, KDLbi
            write (IFPl, 201) _TRIM(CROOT), NXG, NYG,   LXO,  LYO
            write (IFPl, 202) _TRIM(CROOT), LXB, LYB,   ISH,  ISH
            write (IFPl, 204) _TRIM(CROOT), LXE, LYE,   LXW,  LYW
            write (IFPl, 203) _TRIM(CROOT), IR,  NR,    NR
         else if (COND_S(IFPl)) then
#           define IFPl *
            write (IFPl, 101) _TRIM(CROOT), KDL, KDLnb, KDLbi
            write (IFPl, 201) _TRIM(CROOT), NXG, NYG,   LXO,  LYO
            write (IFPl, 202) _TRIM(CROOT), LXB, LYB,   ISH,  ISH
            write (IFPl, 204) _TRIM(CROOT), LXE, LYE,   LXW,  LYW
            write (IFPl, 203) _TRIM(CROOT), IR,  NR,    NR
#           undef  IFPl
         endif
      endif
      RETURN
      END
CCC_ & AEArmn  ## Arpeggio/Dealer/A table registration (sizes)
      subroutine AEArmn
     O    (iErr,  IE,
     I     LIE,   CROOT, IFPl)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   LIE
      _INTENT(INOUT,integer)   IE (LIE)
      _INTENT(IN,   character) CROOT*(*)
      _INTENT(IN,   integer)   IFPl
      integer NXG,  NYG,  LXB,  LYB, LXO, LYO
      integer LXE,  LYE,  LXW,  LYW
      integer IR,   NR,   ISH
      integer NBG,  MBG,  NBP,  MBP
      integer NG,   MG,   NP,   MP
      integer MBX,  MBY,  NBX,  NBY
      integer NXU,  NYU,  MX,   MY
      integer NXD,  NYD
      integer MXU,  MYU
      integer LXYB
      integer KDLnb,KDLbi
      integer irt, npt, kgt, kp, kpt
      integer jrt
      integer mtbl
      integer LVDBG
      integer kgXNC, INBCX, INBCY
CCC_  * Body
      iErr  = 0
      LVDBG = EA_LVDBG(IE)
c
      KDLnb = EA_KDLnb(IE)
      KDLbi = EA_KDLbi(IE)
c
      NXG    = EA_NXG(IE)
      NYG    = EA_NYG(IE)
      LXB    = EA_LXB(IE)
      LYB    = EA_LYB(IE)
      LXW    = EA_LXW(IE)
      LYW    = EA_LYW(IE)
      LXE    = EA_LXE(IE)
      LYE    = EA_LYE(IE)
      LXO    = EA_LXO(IE)
      LYO    = EA_LYO(IE)
      IR     = EA_IR(IE)
      NR     = EA_NR(IE)
      ISH    = EA_ISH(IE)
c
      LXYB = LXB * LYB
CCC_   + number of elements required (wide)
      NXU = _NG2NU(+NXG, +LXO)
      NYU = _NG2NU(+NYG, +LYO)
CCC_   + number of blocks required
c$$$      NBX = _NW2NB(+NXW, +LXB)
c$$$      NBY = _NW2NB(+NYW, +LYB)
      NBX = _NU2NBwe(+NXU,+LXW,+LXE)
      NBY = _NU2NBwe(+NYU,+LYW,+LYE)
CCC_   + number of blocks maximum
      MBX = ((NBX - ISH - 1 + NR) / NR) * NR + ISH
      if (KDLnb.eq.1) then
         NBG = (NBY - 1 ) * MBX + NBX
      else if (KDLnb.eq.0) then
         NBG = MBX * NBY
      endif
      MBG = ((NBG - 1) / NR + 1) * NR
      MBY = (MBG - 1) / MBX + 1
CCC_   + number of blocks (private)
      MBP = MBG / NR
      MP  = MBP * LXYB
c$$$      write (*,*) 'BMNx:', NXW,NBX,MBX,LXB,LXW,LXE
c$$$      write (*,*) 'BMNy:', NYW,NBY,MBY,LYB,LYW,LYE
CCC_   + number of elements with overlap minimum
      NXD = NXU + 2 * LXW * (NBX - 1)
      NYD = NYU + 2 * LYW * (NBY - 1)
CCC_   + number of elements maximum (unique)
      MXU = MBX * LXB - 2 * LXW * (MBX - 1)
      MYU = MBY * LYB - 2 * LYW * (MBY - 1)
CCC_   + number of elements maximum
      MX = MBX * LXB
      MY = MBY * LYB
      MG = MP  * NR
      if (NR.gt.0) then
         NG = -1
         do jrt = 0, NR - 1
            irt = jrt
            call AEPnfp
     O          (iErr,  npt,   NBP,
     I           irt,   NR,
     I           KDLnb, KDLbi, NXD, NYD, MP, NBG, MBP, MBX, LXB, LYB)
c$$$            call AEPnhp
c$$$     O          (iErr,  npt,   NBP,
c$$$     I           irt,   NR,
c$$$     I           KDLnb, KDLbi, NXW, NYW, MP, NBG, MBP, MBX, LXB, LYB)
            do kp = 0, npt - 1
               kpt = kp
               call AEPp2g (kgt, irt, kpt, LXB,LYB,MBX,MBP,NR,KDLbi)
c$$$               write (*, *) 'chk', jrt, kp, kgt
               NG = MAX (NG, kgt + 1)
            enddo
c$$$            write (*, *) 'NG:', irt, NR, NG, npt, kgt
         enddo
      else
         NG = MX * MY
      endif
      call AEPnhp
     O    (iErr,  NP,    NBP,
     I     IR,    NR,
     I     KDLnb, KDLbi, NXD, NYD, MP, NBG, MBP, MBX, LXB, LYB)
c$$$      call AEPnhp
c$$$     O    (iErr,  NP,    NBP,
c$$$     I     IR,    NR,
c$$$     I     KDLnb, KDLbi, NXW, NYW, MP, NBG, MBP, MBX, LXB, LYB)
CCC_   . null block corner (global logical)
      call AEPbgg (kgXNC, MBP * NR, LXB, LYB, MBX)
      INBCX = MOD(kgXNC, MX)
      INBCY = kgXNC / MX
CCC_   + table assignment
      EA_size0(IE) = MP
      EA_size1(IE) = NR
c
      EA_NXU(IE) = NXU
      EA_NYU(IE) = NYU
      EA_NBG(IE) = NBG
      EA_NBP(IE) = NBP
      EA_NP(IE)  = NP
      EA_NG(IE)  = NG
      EA_MX(IE)  = MX
      EA_MY(IE)  = MY
      EA_MXU(IE) = MXU
      EA_MYU(IE) = MYU
      EA_NXD(IE) = NXD
      EA_NYD(IE) = NYD
      EA_MBX(IE) = MBX
      EA_MBY(IE) = MBY
      EA_MBG(IE) = MBG
      EA_MBP(IE) = MBP
      EA_MP(IE)  = MP
      EA_MG(IE)  = MG
      EA_INBCX(IE)  = INBCX
      EA_INBCY(IE)  = INBCY
CCC_   + log
      if (LVDBG.gt.0) then
 301     format (A, ':H',   3I8, ' : ', 3I8)
 302     format (A, ':', A, 2I8, ' : ', 2I8)
 303     format (A, ':', A, 2I8, ' : ', 2I8)
         if      (COND_N(IFPl)) then
            write (IFPl, 301) _TRIM(CROOT), NXU, NYU, NP,  MX,  MY, MP
            write (IFPl, 302) _TRIM(CROOT), 'G', NBG, MBG, NG,  MG
            write (IFPl, 302) _TRIM(CROOT), 'P', NBP, MBP, NP,  MP
            write (IFPl, 303) _TRIM(CROOT), 'X', MBX, MX,  NXU, NXD
            write (IFPl, 303) _TRIM(CROOT), 'Y', MBY, MY,  NYU, NYD
         else if (COND_S(IFPl)) then
#           define IFPl *
            write (IFPl, 301) _TRIM(CROOT), NXU, NYU, NP,  MX,  MY, MP
            write (IFPl, 302) _TRIM(CROOT), 'G', NBG, MBG, NG,  MG
            write (IFPl, 302) _TRIM(CROOT), 'P', NBP, MBP, NP,  MP
            write (IFPl, 303) _TRIM(CROOT), 'X', MBX, MX,  NXU, NXD
            write (IFPl, 303) _TRIM(CROOT), 'Y', MBY, MY,  NYU, NYD
#           undef  IFPl
         endif
      endif
CCC_   + new log
      if (LVDBG.gt.0) then
 401     format ('AE:', A, ':', A, 1x, 5I6, 1x, 3I6, 1x, 2I4)
 402     format ('AE:', A, ':', A, 1x, 4I10, 1x, I4)
 403     format ('AE:', A, ':NBC',1x, 3I10)
         if      (COND_N(IFPl)) then
            write (IFPl, 401)
     $           _TRIM(CROOT), 'X', NXG, NXU, NXD, MXU, MX,
     $           NBX, MBX, LXB, LXW, LXO
            write (IFPl, 401)
     $           _TRIM(CROOT), 'Y', NYG, NYU, NYD, MYU, MY,
     $           NBY, MBY, LYB, LYW, LYO
            write (IFPl, 402)
     $           _TRIM(CROOT), 'G', NG,  MG,  NBG, MBG, NR
            write (IFPl, 402)
     $           _TRIM(CROOT), 'P', NP,  MP,  NBP, MBP, IR
            write (IFPl, 403)
     $           _TRIM(CROOT), kgXNC, INBCX, INBCY
         else if (COND_S(IFPl)) then
#           define IFPl *
            write (IFPl, 401)
     $           _TRIM(CROOT), 'X', NXG, NXU, NXD, MXU, MX,
     $           NBX, MBX, LXB, LXO, LXW
            write (IFPl, 401)
     $           _TRIM(CROOT), 'Y', NYG, NYU, NYD, MYU, MY,
     $           NBY, MBY, LYB, LYO, LYW
            write (IFPl, 402)
     $           _TRIM(CROOT), 'G', NG,  MG,  NBG, MBG, NR
            write (IFPl, 402)
     $           _TRIM(CROOT), 'P', NP,  MP,  NBP, MBP, IR
            write (IFPl, 403)
     $           _TRIM(CROOT), kgXNC, INBCX, INBCY
#           undef  IFPl
         endif
      endif
CCC_   + health check
      mtbl = EA_MAX (IE)
      if (mtbl.gt.LIE) then
         iErr = -1
      endif
 1009 format (A, ':IE/MAX ',I3, 1x, 2I9)
      if      (COND_N(IFPl)) then
         write (IFPl, 1009) _TRIM(CROOT), iErr, mtbl, LIE
      else if (COND_S(IFPl)) then
#        define IFPl *
         write (IFPl, 1009) _TRIM(CROOT), iErr, mtbl, LIE
#        undef  IFPl
      endif
      RETURN
      END
CCC_ & AEArnh  ## Arpeggio/Dealer/A table registration (neighborhood)
      subroutine AEArnh
     O    (iErr,  IE,
     I     LIE,   CROOT, IFPl)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   LIE
      _INTENT(INOUT,integer)   IE (LIE)
      _INTENT(IN,   character) CROOT*(*)
      _INTENT(IN,   integer)   IFPl
      integer LXB, LYB
      integer IR,  NR,  ISH
      integer LXYB
      integer KDLbi
c
      integer IRXP, IRXM, IRYP, IRYM
      integer ISXP, ISXM, ISYP, ISYM
      integer IIXP, IIXM, IIYP, IIYM
c
      integer IRNE, IRNW, IRSE, IRSW
      integer ISNE, ISNW, ISSE, ISSW
      integer IINE, IINW, IISE, IISW
c
      integer MBX, MBP
      integer LXW, LYW, LXWd, LYWd
      integer LVDBG
CCC_  * Body
      iErr  = 0
      LVDBG = EA_LVDBG(IE)
c
      KDLbi = EA_KDLbi(IE)
c
      LXB   = EA_LXB(IE)
      LYB   = EA_LYB(IE)
      IR    = EA_IR(IE)
      NR    = EA_NR(IE)
      ISH   = EA_ISH(IE)
      MBX   = EA_MBX(IE)
      MBP   = EA_MBP(IE)
      LXW   = EA_LXW(IE)
      LYW   = EA_LYW(IE)
      LXWd  = 2 * LXW
      LYWd  = 2 * LYW
c
      LXYB = LXB * LYB
CCC_   + Rank (independent on KDLbi)
      IRXP = MOD ((IR   + NR + 1),   NR)
      IRXM = MOD ((IR   + NR - 1),   NR)
      IRYP = MOD ((IR   + NR + ISH), NR)
      IRYM = MOD ((IR   + NR - ISH), NR)
      IRNE = MOD ((IRYP + NR + 1),   NR)
      IRSE = MOD ((IRYM + NR + 1),   NR)
      IRNW = MOD ((IRYP + NR - 1),   NR)
      IRSW = MOD ((IRYM + NR - 1),   NR)
      IIXP = +1
      IIXM = -1
CCC_   + TODO
      IINE = -9999
      IINW = -9999
      IISE = -9999
      IISW = -9999
CCC_   + KDLbi == 0
      if (KDLbi.eq.0) then
#if 1
         write (*, *) 'not fully tested'
         stop
#endif
         IIYP = +LXB
         IIYM = -LXB
         ISXP = + (1 - LXB * (1 - LYB * ((IR   + 1) / NR))) + LXWd
         ISXM = - (1 - LXB * (1 - LYB * ((IRXM + 1) / NR))) - LXWd
         ISYP = + (((MBX + IR)   / NR * LXYB) - (LXB * (LYB - 1)))
         ISYM = - (((MBX + IRYM) / NR * LXYB) - (LXB * (LYB - 1)))
         ISYP = ISYP + (LYWd * LXB)
         ISYM = ISYM - (LYWd * LXB)
         ISNE = ISYP + (1 - LXB * (1 - LYB * ((IRYP + 1) / NR))) + LXWd
         ISSE = ISYM + (1 - LXB * (1 - LYB * ((IRYM + 1) / NR))) + LXWd
         ISNW = ISYP - (1 - LXB * (1 - LYB * ((IRNW + 1) / NR))) - LXWd
         ISSW = ISYM - (1 - LXB * (1 - LYB * ((IRSW + 1) / NR))) - LXWd
CCC_   + KDLbi == 1
CC           TODO when bx==1 or by==1
      else
         IIYP = + (MBP * LXB)
         IIYM = - (MBP * LXB)
         ISXP = + (1 - LXB * (1 - (IR   + 1) / NR)) + LXWd
         ISXM = - (1 - LXB * (1 - (IRXM + 1) / NR)) - LXWd
         ISYP = +((IR   + MBX) / NR * LXB - (MBP * LXB * (LYB - 1)))
         ISYM = -((IRYM + MBX) / NR * LXB - (MBP * LXB * (LYB - 1)))
         ISYP = ISYP + (LYWd * MBP * LXB)
         ISYM = ISYM - (LYWd * MBP * LXB)
         ISNE = ISYP + (1 - LXB * (1 - (IRYP + 1) / NR)) + LXWd
         ISSE = ISYM + (1 - LXB * (1 - (IRYM + 1) / NR)) + LXWd
         ISNW = ISYP - (1 - LXB * (1 - (IRNW + 1) / NR)) - LXWd
         ISSW = ISYM - (1 - LXB * (1 - (IRSW + 1) / NR)) - LXWd
      endif
CCC_   + table assignment and log
      call AEAnhs (iErr, IE, IRXP, ISXP, IIXP, 'XP', CROOT, LVDBG, IFPl)
      call AEAnhs (iErr, IE, IRXM, ISXM, IIXM, 'XM', CROOT, LVDBG, IFPl)
      call AEAnhs (iErr, IE, IRYP, ISYP, IIYP, 'YP', CROOT, LVDBG, IFPl)
      call AEAnhs (iErr, IE, IRYM, ISYM, IIYM, 'YM', CROOT, LVDBG, IFPl)
      call AEAnhs (iErr, IE, IRNE, ISNE, IINE, 'NE', CROOT, LVDBG, IFPl)
      call AEAnhs (iErr, IE, IRNW, ISNW, IINW, 'NW', CROOT, LVDBG, IFPl)
      call AEAnhs (iErr, IE, IRSE, ISSE, IISE, 'SE', CROOT, LVDBG, IFPl)
      call AEAnhs (iErr, IE, IRSW, ISSW, IISW, 'SW', CROOT, LVDBG, IFPl)
c
      RETURN
      END
CCC_ & AEAnhs  ## Arpeggio/Dealer/A table registration (neighborhood/sub)
      subroutine AEAnhs
     O    (iErr, IE,
     I     IR,   IS,   II,  CDIR, CROOT, LVDBG, IFPl)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   IE (*)
      _INTENT(IN, integer)   IR, IS, II
      _INTENT(IN, character) CDIR*(*), CROOT*(*)
      _INTENT(IN, integer)   LVDBG
      _INTENT(IN, integer)   IFPl
      integer jk
c
      iErr = 0
      call AETqnk (jk, CDIR)
      if (jk.ge.0) then
         EA_IRn(IE,jk) = IR
         EA_ISn(IE,jk) = IS
         EA_IIn(IE,jk) = II
      else
         iErr = -1
      endif
c
      if (LVDBG.gt.0) then
 301     format (A, ':N:',  A, I5, 1x, I5, 1x, I7)
         if      (COND_N(IFPl)) then
            write (IFPl, 301) _TRIM(CROOT), _TRIM(CDIR), IR, IS, II
         else if (COND_S(IFPl)) then
            write (*,    301) _TRIM(CROOT), _TRIM(CDIR), IR, IS, II
         endif
      endif
      RETURN
      END
CCC_ & AEAlpr  ## Arpeggio/Dealer/A table registration (loop range)
      subroutine AEAlpr
     O    (iErr, IE,
     I     LIE,  CROOT, IFPl)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   LIE
      _INTENT(INOUT,integer)   IE (LIE)
      _INTENT(IN,   character) CROOT*(*)
      _INTENT(IN,   integer)   IFPl
c
      integer LXB,   LYB
      integer IR,    NR
      integer MBX,   MBP, NBG
      integer MP,    NP,  NXU, NYU
      integer KDLnb, KDLbi
      integer NHtmp
      integer MY
c
      integer NHXP, NHXM, NHYP, NHYM,  NHNE, NHNW, NHSE, NHSW
      integer JIXP, JIXM, JIYP, JIYM,  JINE, JINW, JISE, JISW
      integer JEXP, JEXM, JEYP, JEYM,  JENE, JENW, JESE, JESW
      integer JSXP, JSXM, JSYP, JSYM,  JSNE, JSNW, JSSE, JSSW
c
      integer IRXP, IRXM, IRYP, IRYM
      integer ISXP, ISXM, ISYP, ISYM
      integer LVDBG
      integer NXD,  NYD
c
      integer jp, k0p, i0g, j0g, jtmp
CCC_  * Body
      iErr  = 0
      LVDBG = EA_LVDBG(IE)
c
      LXB   = EA_LXB(IE)
      LYB   = EA_LYB(IE)
      IR    = EA_IR(IE)
      NR    = EA_NR(IE)
      NP    = EA_NP(IE)
      MP    = EA_MP(IE)
      MBX   = EA_MBX(IE)
      MBP   = EA_MBP(IE)
      NBG   = EA_NBG(IE)
      NXU   = EA_NXU(IE)
      NYU   = EA_NYU(IE)
      NXD   = EA_NXD(IE)
      NYD   = EA_NYD(IE)
      KDLbi = EA_KDLbi(IE)
      KDLnb = EA_KDLnb(IE)
c
      MY    = EA_MY(IE)
c
      IRXP  = EA_IRXP(IE)
      IRXM  = EA_IRXM(IE)
      IRYP  = EA_IRYP(IE)
      IRYM  = EA_IRYM(IE)
c
      ISXP  = EA_ISXP(IE)
      ISXM  = EA_ISXM(IE)
      ISYP  = EA_ISYP(IE)
      ISYM  = EA_ISYM(IE)
c
      call AEPnfp
     O    (iErr,  NHXP,  NHtmp,
     I     IRXP,  NR,
     I     KDLnb, KDLbi, NXD, NYD, MP, NBG, MBP, MBX, LXB, LYB)
      call AEPnfp
     O    (iErr,  NHXM,  NHtmp,
     I     IRXM,  NR,
     I     KDLnb, KDLbi, NXD, NYD, MP, NBG, MBP, MBX, LXB, LYB)
      call AEPnfp
     O    (iErr,  NHYP,  NHtmp,
     I     IRYP,  NR,
     I     KDLnb, KDLbi, NXD, NYD, MP, NBG, MBP, MBX, LXB, LYB)
      call AEPnfp
     O    (iErr,  NHYM,  NHtmp,
     I     IRYM,  NR,
     I     KDLnb, KDLbi, NXD, NYD, MP, NBG, MBP, MBX, LXB, LYB)
c$$$      call AEPnhp
c$$$     O    (iErr,  NHXP,  NHtmp,
c$$$     I     IRXP,  NR,
c$$$     I     KDLnb, KDLbi, NXW, NYW, MP, NBG, MBP, MBX, LXB, LYB)
c$$$      call AEPnhp
c$$$     O    (iErr,  NHXM,  NHtmp,
c$$$     I     IRXM,  NR,
c$$$     I     KDLnb, KDLbi, NXW, NYW, MP, NBG, MBP, MBX, LXB, LYB)
c$$$      call AEPnhp
c$$$     O    (iErr,  NHYP,  NHtmp,
c$$$     I     IRYP,  NR,
c$$$     I     KDLnb, KDLbi, NXW, NYW, MP, NBG, MBP, MBX, LXB, LYB)
c$$$      call AEPnhp
c$$$     O    (iErr,  NHYM,  NHtmp,
c$$$     I     IRYM,  NR,
c$$$     I     KDLnb, KDLbi, NXW, NYW, MP, NBG, MBP, MBX, LXB, LYB)
      NHNE = -9999
      NHNW = -9999
      NHSE = -9999
      NHSW = -9999
      JINE = -9999
      JINW = -9999
      JISE = -9999
      JISW = -9999
      JENE = -9999
      JENW = -9999
      JESE = -9999
      JESW = -9999
      JSNE = -9999
      JSNW = -9999
      JSSE = -9999
      JSSW = -9999
c
CC TODO: loop to check inside or not to further reduce the ranges.
CC       must take care to L[XY]O
      if (KDLbi.eq.1) then
         JSXP = LXB
         JSXM = LXB

         JIXP = LXB
         JIXM = 1
         JIXP = JIXP + ((JSXP - MIN (1, (JIXP + ISXP))) / JSXP) * JSXP
         JIXM = JIXM + ((JSXM - MIN (1, (JIXM + ISXM))) / JSXM) * JSXM
c
         JEXP = ((NP - LXB) / LXB) * LXB + LXB
         JEXM = ((NP - 1)   / LXB) * LXB + 1
         JEXP = JEXP
     $        - ((JSXP-1 + (MAX (NHXP,JEXP+ISXP) - NHXP))/JSXP) * JSXP
         JEXM = JEXM
     $        - ((JSXM-1 + (MAX (NHXM,JEXM+ISXM) - NHXM))/JSXM) * JSXM
c
         JSYM = 1
         JSYP = 1
c
         JIYM = 1
         JIYP = MBP * LXB * (LYB - 1) + 1
         JIYP = JIYP + ((JSYP - MIN (1, (JIYP + ISYP))) / JSYP) * JSYP
         JIYM = JIYM + ((JSYM - MIN (1, (JIYM + ISYM))) / JSYM) * JSYM
c
         JEYP = NP
         JEYM = MBP * LXB
         JEYP = JEYP
     $        - ((JSYP-1 + (MAX (NHYP,JEYP+ISYP) - NHYP))/JSYP) * JSYP
         JEYM = JEYM
     $        - ((JSYM-1 + (MAX (NHYM,JEYM+ISYM) - NHYM))/JSYM) * JSYM
c
CCC_   + adjust YM
 191     format ('AEAlpr: Adj[', A, ']: ', I7, ' to ', I7, 1x, I7)
         jtmp = JEYM + 1
         do jp = JIYM, JEYM, JSYM
            k0p = jp - 1
            call AEPpij
     $           (i0g, j0g, k0p, LXB, LYB, MBX, MBP, IR, NR, KDLbi)
c$$$            write (*, *) 'AYM', jp, i0g, j0g, JIYM, JEYM, JSYM
            if (j0g.gt.0) then
c$$$               jtmp = JIYM
               jtmp = jp
               goto 190
            endif
         enddo
 190     continue
         if      (COND_N(IFPl)) then
            write (IFPl, 191) 'YM', JIYM, jtmp, JEYM
         else if (COND_S(IFPl)) then
            write (*,    191) 'YM', JIYM, jtmp, JEYM
         endif
         JIYM = jtmp
CCC_   + adjust YP
         jtmp = JIYP - 1
         do jp = JEYP, JIYP, -JSYP
            k0p = jp - 1
            call AEPpij
     $           (i0g, j0g, k0p, LXB, LYB, MBX, MBP, IR, NR, KDLbi)
c$$$            write (*, *) 'AYP', jp, i0g, j0g, JIYM, JEYM, JSYM
            if (j0g.lt.(MY - 1)) then
               jtmp = jp
               goto 290
            endif
         enddo
 290     continue
         if      (COND_N(IFPl)) then
            write (IFPl, 191) 'YP', JEYP, jtmp, JIYP
         else if (COND_S(IFPl)) then
            write (*,    191) 'YP', JEYP, jtmp, JIYP
         endif
         JEYP = jtmp
      else
         JIXP = 0
         JIXM = 0
         JIYP = 0
         JIYM = 0
         JEXP = 0
         JEXM = 0
         JEYP = 0
         JEYM = 0
         JSXP = 0
         JSXM = 0
         JSYP = 0
         JSYM = 0
      endif
CCC_   + table assignment and log
      call AEAlps
     $     (iErr, IE, NHXP, JIXP, JEXP, JSXP, 'XP', CROOT, LVDBG, IFPl)
      call AEAlps
     $     (iErr, IE, NHXM, JIXM, JEXM, JSXM, 'XM', CROOT, LVDBG, IFPl)
      call AEAlps
     $     (iErr, IE, NHYP, JIYP, JEYP, JSYP, 'YP', CROOT, LVDBG, IFPl)
      call AEAlps
     $     (iErr, IE, NHYM, JIYM, JEYM, JSYM, 'YM', CROOT, LVDBG, IFPl)
      call AEAlps
     $     (iErr, IE, NHNE, JINE, JENE, JSNE, 'NE', CROOT, LVDBG, IFPl)
      call AEAlps
     $     (iErr, IE, NHNW, JINW, JENW, JSNW, 'NW', CROOT, LVDBG, IFPl)
      call AEAlps
     $     (iErr, IE, NHSE, JISE, JESE, JSSE, 'SE', CROOT, LVDBG, IFPl)
      call AEAlps
     $     (iErr, IE, NHSW, JISW, JESW, JSSW, 'SW', CROOT, LVDBG, IFPl)
      RETURN
      END
CCC_ & AEAlps  ## Arpeggio/Dealer/A table registration (loop range/sub)
      subroutine AEAlps
     O    (iErr, IE,
     I     NH,   JI, JE, JS,  CDIR, CROOT, LVDBG, IFPl)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   IE (*)
      _INTENT(IN, integer)   NH, JI, JE, JS
      _INTENT(IN, character) CDIR*(*), CROOT*(*)
      _INTENT(IN, integer)   LVDBG
      _INTENT(IN, integer)   IFPl
      integer jk
      iErr = 0
      call AETqnk (jk, CDIR)
      if (jk.ge.0) then
         EA_NHn(IE,jk) = NH
         EA_JIn(IE,jk) = JI
         EA_JEn(IE,jk) = JE
         EA_JSn(IE,jk) = JS
      else
         iErr = -1
      endif
c
      if (LVDBG.gt.0) then
 301     format (A, ':NP:',  A, I7)
 302     format (A, ':LP:',  A, I7, 1x, I7, 1x, I7)
         if      (COND_N(IFPl)) then
            write (IFPl, 301) _TRIM(CROOT), _TRIM(CDIR), NH
            write (IFPl, 302) _TRIM(CROOT), _TRIM(CDIR), JI, JE, JS
         else if (COND_S(IFPl)) then
            write (*,    301) _TRIM(CROOT), _TRIM(CDIR), NH
            write (*,    302) _TRIM(CROOT), _TRIM(CDIR), JI, JE, JS
         endif
      endif
      RETURN
      END
CCC_ & AEArpr  ## Arpeggio/Dealer/A table registration (periodicity/new)
      subroutine AEArpr
     O    (iErr,  IE,
     I     LIE,   CROOT, IFPl)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   LIE
      _INTENT(INOUT,integer)   IE (LIE)
      _INTENT(IN,   character) CROOT*(*)
      _INTENT(IN,   integer)   IFPl
      integer NXG,   NYG, LXB, LYB
      integer IR,    NR
      integer MBX,   MBP
      integer LCXi,  LCXo
      integer LCYi,  LCYo
      integer KDLbi
CC    o: block upper (e/n) side
CC    i: block lower (s/w) side
      integer LVDBG
CCC_  * Body
      iErr  = 0
      LVDBG = EA_LVDBG(IE)
c
      NXG   = EA_NXG(IE)
      NYG   = EA_NYG(IE)
      LXB   = EA_LXB(IE)
      LYB   = EA_LYB(IE)
      IR    = EA_IR(IE)
      NR    = EA_NR(IE)
      MBX   = EA_MBX(IE)
      MBP   = EA_MBP(IE)
      KDLbi = EA_KDLbi(IE)
c
      LCXi  = MOD (NXG, LXB)
      LCXo  = LXB - LCXi
      LCYi  = MOD (NYG, LYB)
      LCYo  = LYB - LCYi
c
      call AEAprs
     O    (IE,
     I     LXB,   LYB,   MBX, MBP, IR, NR, KDLbi,
     I     LCXi,  NXG,
     I     'E',   CROOT, LVDBG, IFPl)
      call AEAprs
     O    (IE,
     I     LXB,   LYB,   MBX, MBP, IR, NR, KDLbi,
     I     LCXi,  NXG,
     I     'W',   CROOT, LVDBG, IFPl)
      call AEAprs
     O    (IE,
     I     LXB,   LYB,   MBX, MBP, IR, NR, KDLbi,
     I     LCYi,  NYG,
     I     'N',   CROOT, LVDBG, IFPl)
      call AEAprs
     O    (IE,
     I     LXB,   LYB,   MBX, MBP, IR, NR, KDLbi,
     I     LCYi,  NYG,
     I     'S',   CROOT, LVDBG, IFPl)
CCC_   + table assignment and log
      EA_LCXo(IE) = LCXo
      EA_LCXi(IE) = LCXi
      EA_LCYo(IE) = LCYo
      EA_LCYi(IE) = LCYi
c
      if (LVDBG.gt.0) then
 401     format (A, ':C:', A, 1x, 5I2)
         if      (COND_N(IFPl)) then
            write (IFPl, 401) _TRIM(CROOT), 'X', LCXo,  LCXi
            write (IFPl, 401) _TRIM(CROOT), 'Y', LCYo,  LCYi
         else if (COND_S(IFPl)) then
            write (*,    401) _TRIM(CROOT), 'X', LCXo,  LCXi
            write (*,    401) _TRIM(CROOT), 'Y', LCYo,  LCYi
         endif
      endif
c
      RETURN
      END
CCC_ & AEAprs  ## Arpeggio/Dealer/A table registration (periodicity/sub)
      subroutine AEAprs
     O    (IE,
     I     LXB,    LYB,   MBX, MBP, IR, NR, KDLbi,
     I     lcSrc,  lAdd,
     I     CDIR,   CROOT, LVDBG, IFPl)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,integer)   IE(*)
      _INTENT(IN, integer)   LXB,   LYB
      _INTENT(IN, integer)   MBX,   MBP,  IR, NR, KDLbi
      _INTENT(IN, integer)   lcSrc, lAdd
      _INTENT(IN, character) CDIR*(*), CROOT*(*)
      _INTENT(IN, integer)   LVDBG
      _INTENT(IN, integer)   IFPl
      integer kbgRef
      integer irRef, irTgt, kpRef, kpTgt
      integer icSrc, jcSrc, iAdd,  jAdd
      integer IRoS,  ISoS,  IRoD,  ISoD
      integer IRiS,  ISiS,  IRiD,  ISiD
      integer jErr
CCC_  * Body
      if      (CDIR.eq.'E') then
         kbgRef = (MBX / NR) * NR + IR
         icSrc = lcSrc
         jcSrc = 0
         iAdd  = -lAdd
         jAdd  = 0
      else if (CDIR.eq.'W') then
         kbgRef = (MBX / NR) * NR + IR
         icSrc = lcSrc
         jcSrc = 0
         iAdd  = +lAdd
         jAdd  = 0
      else if (CDIR.eq.'N') then
         kbgRef = MBP * NR + IR
         icSrc = 0
         jcSrc = lcSrc
         iAdd  = 0
         jAdd  = -lAdd
      else
         kbgRef = MBP * NR + IR
         icSrc = 0
         jcSrc = lcSrc
         iAdd  = 0
         jAdd  = +lAdd
      endif
CCC_   + o/S
      call AEAprp
     O    (irRef,  irTgt, kpRef, kpTgt,
     I     kbgRef, LXB,   LYB,   MBX, MBP, NR, KDLbi,
     I     icSrc,  jcSrc, +iAdd, +jAdd)
      IRoS = irTgt
      ISoS = + (kpTgt - kpRef)
CCC_   + o/D
      call AEAprp
     O    (irRef,  irTgt, kpRef, kpTgt,
     I     kbgRef, LXB,   LYB,   MBX, MBP, NR, KDLbi,
     I     0,      0,     -iAdd, -jAdd)
      IRoD = irTgt
      ISoD = + (kpTgt - kpRef)
CCC_   + i/S
      call AEAprp
     O    (irRef,  irTgt, kpRef, kpTgt,
     I     kbgRef, LXB,   LYB,   MBX, MBP, NR, KDLbi,
     I     0,      0,     +iAdd, +jAdd)
      IRiS = irTgt
      ISiS = + (kpTgt - kpRef)
CCC_   + i/D
      call AEAprp
     O    (irRef,  irTgt, kpRef, kpTgt,
     I     kbgRef, LXB,   LYB,   MBX, MBP, NR, KDLbi,
     I     icSrc,  jcSrc, -iAdd, -jAdd)
      IRiD = irTgt
      ISiD = + (kpTgt - kpRef)
CCC_   + record
      call AEAptp (jErr, IE, CDIR, 'S', 'o', ISoS)
      call AEAptp (jErr, IE, CDIR, 'R', 'o', IRoS)
      call AEAptp (jErr, IE, CDIR, 'T', 'o', ISoD)
      call AEAptp (jErr, IE, CDIR, 'D', 'o', IRoD)
c
      call AEAptp (jErr, IE, CDIR, 'S', 'i', ISiS)
      call AEAptp (jErr, IE, CDIR, 'R', 'i', IRiS)
      call AEAptp (jErr, IE, CDIR, 'T', 'i', ISiD)
      call AEAptp (jErr, IE, CDIR, 'D', 'i', IRiD)
c
      if (LVDBG.gt.0) then
 301     format (A, ':C:', A, ':', A, 1x, I7,1x,I7, ' : ',I7,1x,I7)
         if      (COND_N(IFPl)) then
            write (IFPl, 301)
     $           _TRIM(CROOT), _TRIM(CDIR), 'o', ISoS, IRoS, ISoD, IRoD
            write (IFPl, 301)
     $           _TRIM(CROOT), _TRIM(CDIR), 'i', ISiS, IRiS, ISiD, IRiD
         else if (COND_S(IFPl)) then
            write (*,    301)
     $           _TRIM(CROOT), _TRIM(CDIR), 'o', ISoS, IRoS, ISoD, IRoD
            write (*,    301)
     $           _TRIM(CROOT), _TRIM(CDIR), 'i', ISiS, IRiS, ISiD, IRiD
         endif
      endif
c
      RETURN
      END
CCC_ & AEAptp  ## Arpeggio/Dealer/A table registration (periodicity/put)
      subroutine AEAptp
     O    (iErr, IE,
     I     CDIR, CPFX, Coi, IV)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   IE (*)
      _INTENT(IN, character) CDIR*(*), CPFX*(*), Coi*(*)
      _INTENT(IN, integer)   IV
      integer jp
      call AETqip (jp, CDIR, CPFX, Coi)
      if (jp.gt.0) then
         IE(jp) = IV
         iErr = 0
      else
         iErr = -1
      endif
      RETURN
      END
CCC_ & AEAgtp  ## Arpeggio/Dealer/A table registration (periodicity/get)
      subroutine AEAgtp
     O    (iErr, IV,
     I     CDIR, CPFX, Coi,
     I     IE)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   IV
      _INTENT(IN, character) CDIR*(*), CPFX*(*), Coi*(*)
      _INTENT(IN,integer)    IE (*)
      integer jp
c
      call AETqip (jp, CDIR, CPFX, Coi)
      if (jp.gt.0) then
         IV = IE(jp)
         iErr = 0
      else
         iErr = -1
      endif
      RETURN
      END
CCC_ & AEAprp  ## Arpeggio/Dealer/A table registration (periodicity/primitive)
      subroutine AEAprp
     O    (irRef,  irTgt, kpRef, kpTgt,
     I     kbgRef, LXB,   LYB,   MBX, MBP, NR, KDLbi,
     I     icSrc,  jcSrc, iAdd,  jAdd)
      implicit none
      _INTENT(OUT,integer)   irRef, irTgt
      _INTENT(OUT,integer)   kpRef, kpTgt
      _INTENT(IN, integer)   kbgRef
      _INTENT(IN, integer)   icSrc, jcSrc
      _INTENT(IN, integer)   MBX,   MBP, NR, KDLbi
      _INTENT(IN, integer)   LXB,   LYB
      _INTENT(IN, integer)   iAdd,  jAdd
      integer kt, lt
      integer icRef,  jcRef
      integer ibAdd,  jbAdd, icTgt, jcTgt
      integer kbgTgt, kbgRnm
      integer kgRef,  kgTgt
c$$$      integer kgXNC
      integer MX,     nadd
CC
CC  [ij]cSrc can be negative; normalized to [ij]cRef
CC
CC  CAUTION
CC    mixed sign mod;div operation may be system-dependent(?)
      MX = MBX * LXB
c
      kt    = icSrc + iAdd
      lt    = (LXB - 1) * ((1 - SIGN (1, kt)) / 2)
      icTgt = MOD ((LXB + SIGN (1, kt) * MOD (ABS (kt), LXB)), LXB)
      ibAdd = SIGN ((ABS (kt) + lt) / LXB, kt)
      icRef = MOD (icSrc + LXB, LXB)
c
      kt    = jcSrc + jAdd
      lt    = (LYB - 1) * ((1 - SIGN (1, kt)) / 2)
      jcTgt = MOD ((LYB + SIGN (1, kt) * MOD (ABS (kt), LYB)), LYB)
      jbAdd = SIGN ((ABS (kt) + lt) / LYB, kt)
      jcRef = MOD (jcSrc + LYB, LYB)
c
      kbgTgt = kbgRef + jbAdd * MBX + ibAdd
CC    normalize if kbgTgt<0
c$$$      write (*, *) 'BB0', kbgRef, kbgTgt
      if (kbgTgt.lt.0) then
         nadd = ((-kbgTgt) / NR + 1) * NR
         kbgRnm =kbgRef + nadd
         kbgTgt =kbgTgt + nadd
      else
         kbgRnm = kbgRef
      endif
      call AEPbgg (kgRef, kbgRnm, LXB, LYB, MBX)
      call AEPbgg (kgTgt, kbgTgt, LXB, LYB, MBX)
      kgRef = kgRef + icRef + jcRef * MX
      kgTgt = kgTgt + icTgt + jcTgt * MX
c
      call AEPg2p (irRef, kpRef, kgRef, LXB, LYB, MBX, MBP, NR, KDLbi)
      call AEPg2p (irTgt, kpTgt, kgTgt, LXB, LYB, MBX, MBP, NR, KDLbi)
c
      RETURN
      END
CCC_ & AEArid  ## Arpeggio/Dealer/A table registration (index)
      subroutine AEArid
     O    (iErr,  IE,
     I     LIE,   CROOT, IFPl)
CCC_  * Description
CC      todo: integrate CU generation
CCC_  * Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   LIE
      _INTENT(INOUT,integer)   IE (LIE)
      _INTENT(IN,   character) CROOT*(*)
      _INTENT(IN,   integer)   IFPl
      integer NXG, NXU, LXB, LXO, LXW
      integer NYG, NYU, LYB, LYO, LYW
      integer IR,  NR
      integer LCXi, LCXo, LCYi, LCYo
      integer MP, MX, MY, MBX, MBP, NP
      integer MXU, MYU
      integer kph, i0,  j0
      integer kv
      integer KDLbi
      integer ijg, ig, jg, kcu, kct
      integer kctb (8)
      integer kphtmp
      integer nEff
      integer l
      _REALSTD rEff, rOpr
      integer LVDBG
      integer jhp,  jhptmp
      integer jxlg, jxpt, kfx
      integer jylg, jypt, kfy
      integer jwgt
      integer INBCX, INBCY, nasx, nasy
CCC_  * Body
      iErr  = 0
      LVDBG = EA_LVDBG(IE)
c
      NXG   = EA_NXG(IE)
      NYG   = EA_NYG(IE)
      NXU   = EA_NXU(IE)
      NYU   = EA_NYU(IE)
      MXU   = EA_MXU(IE)
      MYU   = EA_MYU(IE)
      LXB   = EA_LXB(IE)
      LYB   = EA_LYB(IE)
      LXW   = EA_LXW(IE)
      LYW   = EA_LYW(IE)
      LXO   = EA_LXO(IE)
      LYO   = EA_LYO(IE)
      IR    = EA_IR(IE)
      NR    = EA_NR(IE)
      MP    = EA_MP(IE)
      MX    = EA_MX(IE)
      MY    = EA_MY(IE)
      NP    = EA_NP(IE)
      MBX   = EA_MBX(IE)
c
      LCXi  = EA_LCXi(IE)
      LCXo  = EA_LCXo(IE)
      LCYi  = EA_LCYi(IE)
      LCYo  = EA_LCYo(IE)
c
      KDLbi = EA_KDLbi(IE)
      MBP   = EA_MBP(IE)
c
      INBCX = EA_INBCX(IE)
      INBCY = EA_INBCY(IE)
CCC_   + format
 1001 format (A, ':', A, 5I7)
 1002 format (A, ':', A, 5I7, 1x, I4)
 1003 format (A, ':', A, 1x, 4(2I1,1x), 1x, 4I7)
CCC_   + MU, L[WXY]
      nEff = 0
      do kph = 0, MP - 1
         kphtmp = kph
         call AEPpij (i0, j0, kphtmp, LXB, LYB, MBX, MBP, IR, NR, KDLbi)
         call AEPpbm
     O       (kv,
     I        kphtmp,
     I        LXB,  LYB,  LXO,   LYO,  NXG, NYG,
     I        MBX,  MBP,  KDLbi, IR,   NR)
CCC_    * x
         if (kv.ge.0 .and. LXO.gt.0) then
            if (i0.lt.LXO) then
               kv = kv + 1
            else if (i0.ge.NXG + LXO) then
               kv = kv + 2
            endif
         endif
CCC_    * y
         if (kv.ge.0 .and. LYO.gt.0) then
            if (j0.lt.LYO) then
               kv = kv + 1 * 3
            else if (j0.ge.NYG + LYO) then
               kv = kv + 2 * 3
            endif
         endif
CCC_    * store
         ig  = i0 + 1
         jg  = j0 + 1
         ijg = j0 * MX + i0 + 1
         EA_listMU(IE,kph) = kv
         EA_listLW(IE,kph) = ijg
         EA_listLX(IE,kph) = ig
         EA_listLY(IE,kph) = jg
         kphtmp = kph + 1
         if (i0.ge.LXO.and.i0.lt.LXO+NXG
     $        .and.j0.ge.LYO.and.j0.lt.LYO+NYG) then
            nEff = nEff + 1
         endif
         if (kphtmp.gt.NP) kphtmp = - kphtmp
CCC_    * log
CC        format  ROOT:MU mask        (ij private) (i global) (j global)
CC                ROOT:LW (ij global) (ij private) (i global) (j global) rank
CC                ROOT:LX (i  global) (ij private) (i global) (j global)
CC                ROOT:LY (j  global) (ij private) (i global) (j global)
CC                ROOT:MN (ij global) (ij private) (i global) (j global)
CC                         negative if >=NP
         if (LVDBG.gt.1) then
            if      (COND_N(IFPl)) then
               write (IFPl, 1001) _TRIM(CROOT),'MU', kv,  kph,i0,j0
               write (IFPl, 1002) _TRIM(CROOT),'LW', ijg, kph,i0,j0, IR
               write (IFPl, 1001) _TRIM(CROOT),'LX', ig,  kph,i0,j0
               write (IFPl, 1001) _TRIM(CROOT),'LY', jg,  kph,i0,j0
               write (IFPl, 1001) _TRIM(CROOT),'MN', kphtmp,kph,i0,j0
            else if (COND_S(IFPl)) then
#              define IFPl *
               write (IFPl, 1001) _TRIM(CROOT),'MU', kv,  kph,i0,j0
               write (IFPl, 1002) _TRIM(CROOT),'LW', ijg, kph,i0,j0, IR
               write (IFPl, 1001) _TRIM(CROOT),'LX', ig,  kph,i0,j0
               write (IFPl, 1001) _TRIM(CROOT),'LY', jg,  kph,i0,j0
               write (IFPl, 1001) _TRIM(CROOT),'MN', kphtmp,kph,i0,j0
#              undef  IFPl
            endif
         endif
      enddo
CCC_    * CU/CT
      do kph = 0, MP - 1
         kphtmp = kph
         call AEPpcu
     O       (kcu,
     I        kphtmp,
     I        LCXi, LCXo, LCYi,  LCYo,
     I        LXB,  LYB,  LXO,   LYO,  NXG, NYG,
     I        MBX,  MBP,  KDLbi, IR,   NR)
         call AEPpct
     O       (kctb,
     I        kphtmp,
     I        LCXi, LCXo, LCYi,  LCYo,
     I        LXB,  LYB,  LXO,   LYO,  NXG, NYG,
     I        MBX,  MBP,  KDLbi, IR,   NR)
         kct = 0
         do l = 1, 8
            kct = kct + kctb (l) * (2 ** (l-1))
         enddo
         EA_listCU(IE,kph) = kcu
         EA_listCT(IE,kph) = kct
         call AEPpij (i0, j0, kphtmp, LXB, LYB, MBX, MBP, IR, NR, KDLbi)
         if (LVDBG.gt.1) then
            if      (COND_N(IFPl)) then
               write (IFPl, 1001) _TRIM(CROOT),'CU', kcu,  kph,i0,j0
               write (IFPl, 1003) _TRIM(CROOT),'CT', kctb, kph,i0,j0
            else if (COND_S(IFPl)) then
#              define IFPl *
               write (IFPl, 1001) _TRIM(CROOT),'CU', kcu,  kph,i0,j0
               write (IFPl, 1003) _TRIM(CROOT),'CT', kctb, kph,i0,j0
#              undef  IFPl
            endif
         endif
      enddo

      rEff = DBLE (nEff) / DBLE (MP)
      rOpr = DBLE (NP)   / DBLE (MP)
      if (LVDBG.ge.0) then
 1091    format (A, ':EFF ', I3, 1x,I7,1x,I7,1x,F7.4,1x,I7,1x,F7.4)
         if      (COND_N(IFPl)) then
            write (IFPl, 1091)
     $           _TRIM(CROOT), IR, MP, NP, rOpr, nEff, rEff
         else if (COND_S(IFPl)) then
            write (*,    1091)
     $           _TRIM(CROOT), IR, MP, NP, rOpr, nEff, rEff
         endif
      endif
CCC_   + new log
CC        format  ROOT:MT (w gl/lo) (type)   (i gl/lo) (j gl/lo)
CC                ROOT:HP (h pr/lo) (rank)   (i gl/lo) (j gl/lo)
CC                ROOT:WT (a gl/mt) (target) (i gl/lo) (j gl/lo)
CC                ROOT:XT (i gl/mt) (type)   (i gl/lo) (j gl/lo)
CC                ROOT:YT (j gl/mt) (type)   (i gl/lo) (j gl/lo)
 501  format ('AE:', A, ':', A, 1x, I8, 1x, I3, 1x, 2I8)
      do jhp = 0, MP - 1
         jhptmp = jhp
         call AEPh2e
     O       (jxlg, jylg,
     I        jhptmp,
     I        LXB, LYB, MBX, MBP, IR, NR, KDLbi)
         call AEPe2t (jxpt, kfx, nasx, jxlg, LXB, LXW, MX)
         call AEPe2t (jypt, kfy, nasy, jylg, LYB, LYW, MY)
         jwgt = jypt * MXU + jxpt
c$$$         write (*, *) 'ECHK', jhp, jxlg, jylg, nasx, nasy
c$$$         if (nasx.ne.0) then
c$$$            if (jxlg+nasx.ge.INBCX.and.jylg+0.ge.INBCY) then
c$$$               kfx = kfx * 2
c$$$            endif
c$$$         endif
c$$$         if (nasy.ne.0) then
c$$$            if (jxlg+0.ge.INBCX.and.jylg+nasy.ge.INBCY) then
c$$$               kfy = kfy * 2
c$$$            endif
c$$$         endif
         if (nasx.ne.0) then
            if (jxlg+nasx.ge.INBCX.and.jylg+0.ge.INBCY) then
               kfx = 0
            endif
         endif
         if (nasy.ne.0) then
            if (jylg+nasy.ge.INBCY.or.jylg.ge.INBCY) then
               kfy = 0
            endif
         endif
c
         kcu = EA_listCU(IE,jhp)
         kct = EA_listCT(IE,jhp)
c
         if (EA_VAR(IE) .gt. 257) then
            EA_listPW(IE,jhp) = jwgt + 1
            EA_listPX(IE,jhp) = jxpt + 1
            EA_listPY(IE,jhp) = jypt + 1
            EA_listXW(IE,jhp) = kfx
            EA_listYW(IE,jhp) = kfy
c$$$            write (*, *) 'PW', jxpt, jypt, jwgt
         endif
c
         if      (COND_N(IFPl)) then
            write (IFPl, 501)
     $           _TRIM(CROOT), 'MT', jwgt, 0,   jxlg, jylg
            write (IFPl, 501)
     $           _TRIM(CROOT), 'XT', jxpt, kfx, jxlg, jylg
            write (IFPl, 501)
     $           _TRIM(CROOT), 'YT', jypt, kfy, jxlg, jylg
            write (IFPl, 501)
     $           _TRIM(CROOT), 'HP', jhp,  IR,  jxlg, jylg
            write (IFPl, 501)
     $           _TRIM(CROOT), 'CC', kcu,  kct, jxlg, jylg
         else if (COND_S(IFPl)) then
#           define IFPl *
            write (IFPl, 501)
     $           _TRIM(CROOT), 'MT', jwgt, 0,   jxlg, jylg
            write (IFPl, 501)
     $           _TRIM(CROOT), 'XT', jxpt, kfx, jxlg, jylg
            write (IFPl, 501)
     $           _TRIM(CROOT), 'YT', jypt, kfy, jxlg, jylg
            write (IFPl, 501)
     $           _TRIM(CROOT), 'HP', jhp,  IR,  jxlg, jylg
            write (IFPl, 501)
     $           _TRIM(CROOT), 'CC', kcu,  kct, jxlg, jylg
#           undef  IFPl
         endif
      enddo
      RETURN
      END
CCC_ & AEArep  ## Arpeggio/Dealer/A table report
      subroutine AEArep
     $     (iErr, IE, LIE, CROOT, IFPl)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   LIE
      _INTENT(IN, integer)   IE (LIE)
      _INTENT(IN, character) CROOT*(*)
      _INTENT(IN, integer)   IFPl
      integer j, JMAX
      integer LVDBG
CCC_  * Body
      iErr  = 0
      LVDBG = EA_LVDBG(IE)
      JMAX  = EA_MAX(IE)
c
      if (JMAX.gt.LIE) then
         iErr = 99
      else if (LVDBG.gt.1) then
 1003    format (A, ':RR', 2I9)
         do j = 1, JMAX - 1
            if      (COND_N(IFPl)) then
               write (IFPl, 1003) _TRIM(CROOT), j, IE (j)
            else if (COND_S(IFPl)) then
#              define IFPl *
               write (IFPl, 1003) _TRIM(CROOT), j, IE (j)
#              undef  IFPl
            endif
         enddo
      endif
 1009 format (A, ':IE/REPORT ',I3, 1x, 2I9)
      if      (COND_N(IFPl)) then
         write (IFPl, 1009) _TRIM(CROOT), iErr, JMAX, LIE
      else if (COND_S(IFPl)) then
#        define IFPl *
         write (IFPl, 1009) _TRIM(CROOT), iErr, JMAX, LIE
#        undef  IFPl
      endif
      RETURN
      END
CCC_ & AEAchp  ## Arpeggio/Dealer/A check size against mp
      subroutine AEAchp
     O    (iErr,
     I     IE,   L, TAG, IFPl)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   IE (*)
      _INTENT(IN, integer)   L
      _INTENT(IN, character) TAG*(*)
      _INTENT(IN, integer)   IFPl
      integer MHP
CCC_  * Body
      iErr = 0
      MHP  = EA_MP(IE)
      call DAchmU (iErr, MHP, L, 'AEACHP', Tag, IFPl)
      RETURN
      END
CCC_* [AES] Stencil generation wrapper
CCC_ & AESglb  ## Stencil generator global/private
      subroutine AESglb
     O    (iErr,
     O     KSglb,
     W     kDTA,
     I     LNR,    LTBL,  LHP,   LHG, IE, IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   LNR,  LTBL, LHP, LHG
      _INTENT(OUT,integer)   KSglb (*)
c$$$      _INTENT(OUT,integer)   kDSP (LTBL), kTYP (LTBL), kABL (LTBL)
      _INTENT(OUT,integer)   kDTA (LTBL, 3)
      _INTENT(IN, integer)   IE (*)
      _INTENT(IN, integer)   IFPl
      integer ir, NR
      integer jr
      integer nc, np, nbp, kstn
      integer mpiRS, mpiLB, mpiUB, nBytRS
      integer LG, kp, kg, kptmp
      integer KDLbi, LXB, LYB, MBP, MBX
      integer MP
      integer nSize, nExt
CCC_  - Body
      iErr = 0
      if (iErr.eq.0) then
         MP = EA_MP(IE)
         NR = EA_NR(IE)
      endif
c
      if (LTBL .lt. MP + 2) iErr = -1
      if (LNR  .lt. NR)     iErr = iErr - 2
c
      if (iErr.eq.0) then
         call DMZqcn (iErr, mpiRS, '_REALSTD')
         call DMZqcn (iErr, mpiLB, 'LB')
         call DMZqcn (iErr, mpiUB, 'UB')
         call DMWtsz (iErr, nBytRS, mpiRS)
c
         KDLbi = EA_KDLbi(IE)
         LXB   = EA_LXB(IE)
         LYB   = EA_LYB(IE)
         MBX   = EA_MBX(IE)
         MBP   = EA_MBP(IE)
c
         LG = LHG
         if (LG.le.0) LG = EA_MG(IE)
      endif
CCC_   . send
      if (iErr.eq.0) then
         do jr = 0, NR - 1
            ir = jr
            call AEWnhp (iErr, np, nbp, ir, IE)
            nc = 1
            kDTA (nc, 1) = 0
            kDTA (nc, 2) = mpiLB
            kDTA (nc, 3) = 1
            nc = nc + 1
            kDTA (nc, 1) = 0
            kDTA (nc, 2) = mpiRS
            kDTA (nc, 3) = np
            nc = nc + 1
            kDTA (nc, 1) = nBytRS * LHP
            kDTA (nc, 2) = mpiUB
            kDTA (nc, 3) = 1
            call DMWdts
     $          (iErr,   kstn, nc, kDTA (1,3), kDTA (1,1), kDTA (1,2))
c$$$            call DMWdts (iErr, kstn, nc, kDTA (1,3), kDSP, kTYP)
            KSglb (1 + NR + IR) = kstn
         enddo
      endif
CCC_   . recieve
      if (iErr.eq.0) then
         do jr = 0, NR - 1
            ir = jr
            nc = 1
            kDTA (nc, 1) = 0
            kDTA (nc, 2) = mpiLB
            kDTA (nc, 3) = 1
            call AEWnhp (iErr, np, nbp, ir, IE)
            do kp = 1, NP
               kptmp = kp - 1
               call AEPp2g (kg, ir, kptmp, LXB,LYB,MBX,MBP,NR,KDLbi)
               nc = nc + 1
               kDTA (nc, 1) = nBytRS * kg
               kDTA (nc, 2) = mpiRS
               kDTA (nc, 3) = 1
            enddo
            nc = nc + 1
            kDTA (nc, 1) = nBytRS * LG
            kDTA (nc, 2) = mpiUB
            kDTA (nc, 3) = 1
            call DMWdts
     $          (iErr,   kstn, nc, kDTA (1,3), kDTA (1,1), kDTA (1,2))
c$$$            call DMWdts (iErr, kstn, nc, kABL, kDSP, kTYP)
            KSglb (1 + IR) = kstn
         enddo
      endif
CCC_   . report
 101  format ('AESGLB:', I3.3, ':', A, ': ', 2I7)
      if (iErr.eq.0) then
         if      (COND_N(IFPl))  then
            do ir = 0, NR - 1
               kstn = KSglb (1 + IR)
               call DMWtxt (iErr, nExt,  kstn)
               call DMWtsz (iErr, nSize, kstn)
               write (IFPl, 101) IR, 'R', nSize, nExt
               kstn = KSglb (1 + NR + IR)
               call DMWtxt (iErr, nExt,  kstn)
               call DMWtsz (iErr, nSize, kstn)
               write (IFPl, 101) IR, 'S', nSize, nExt
            enddo
         else if (COND_S(IFPl)) then
            do ir = 0, NR - 1
               kstn = KSglb (1 + IR)
               call DMWtxt (iErr, nExt,  kstn)
               call DMWtsz (iErr, nSize, kstn)
               write (*,   101) IR, 'R', nSize, nExt
               kstn = KSglb (1 + NR + IR)
               call DMWtxt (iErr, nExt,  kstn)
               call DMWtsz (iErr, nSize, kstn)
               write (*,   101) IR, 'S', nSize, nExt
            enddo
         endif
      endif
      call DAtrcU (IFPl, iErr, 'R', 'AESGLB')
      RETURN
      END
CCC_ & AESovg  ## Stencil generator (overlap/group/clone) suite
      subroutine AESovg
     O    (iErr,
     W     kDSP,   kTYP,   kABL,   KWI,
     O     nOVW,   kStncS, kStncD, IRStbl, IRDtbl,
     I     LOVL,   LTBL,   LHP,    IE,     OTRANS, IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(IN, integer) LOVL, LTBL, LHP
      _INTENT(OUT,integer) kStncS (LOVL), kStncD (LOVL)
      _INTENT(OUT,integer) IRStbl (LOVL), IRDtbl (LOVL)
      _INTENT(OUT,integer) kDSP (LTBL), kTYP (LTBL), kABL (LTBL)
      _INTENT(OUT,integer) KWI  (LHP)
      _INTENT(OUT,integer) nOVW
      _INTENT(IN, integer) IE (*)
      _INTENT(IN, logical) OTRANS
      _INTENT(IN, integer) IFPl
      integer IR, IRflg, KSflg
      integer jov
      integer KS
      character CRD
CCC_  - Body
      iErr = 0
      nOVW = 0
      IR = EA_IR(IE)
      if (iErr.eq.0) then
         call AESnov
     O       (iErr,
     O        nOVW, IRStbl, IRDtbl, LOVL,
     I        IE,   OTRANS, IFPl)
      endif
      do jov = 1, nOVW
         if (iErr.eq.0) then
            if (OTRANS) then
               IRflg = -1
               KSflg = 1
               CRD   = 'D'
            else
               IRflg = IR
               KSflg = 0
               CRD   = 'R'
            endif
            call AEScov
     O          (iErr,  KS,
     W           kDSP,  kTYP,  kABL,  KWI,
     I           CRD,   IRStbl (jov), IRflg, KSflg, 1,
     I           LHP,   LTBL,  IE,    IFPl)
            kStncS (jov) = KS
         endif
      enddo
      do jov = 1, nOVW
         if (iErr.eq.0) then
            if (OTRANS) then
               IRflg = IR
               KSflg = 0
               CRD   = 'R'
            else
               IRflg = -1
               KSflg = 1
               CRD   = 'D'
            endif
            call AEScov
     O          (iErr,  KS,
     W           kDSP,  kTYP,  kABL,  KWI,
     I           CRD,   IRDtbl (jov), IRflg, KSflg, 0,
     I           LHP,   LTBL,  IE,    IFPl)
            kStncD (jov) = KS
         endif
      enddo
      call DAtrcU (IFPl, iErr, 'R', 'AESOVG')
      RETURN
      END
CCC_ & AESnov  ## Attributes extraction
      subroutine AESnov
     O    (iErr,
     O     nOVW, IRStbl, IRDtbl, LOVL,
     I     IE,   OTRANS, IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(OUT,integer) nOVW
      _INTENT(IN, integer) LOVL
      _INTENT(OUT,integer) IRStbl (LOVL), IRDtbl (LOVL)
      _INTENT(IN, integer) IE (*)
      _INTENT(IN, logical) OTRANS
      _INTENT(IN, integer) IFPl
      integer j
      integer LXO, LYO
CCC_  - Body
      iErr = 0
      do j = 1, LOVL
         IRStbl (j) = -1
         IRDtbl (j) = -1
      enddo
      nOVW = 0
      LXO = EA_LXO(IE)
      LYO = EA_LYO(IE)
      if (LXO.gt.0) then
         if (iErr.eq.0)
     $        call AESogs (iErr,nOVW,IRStbl,IRDtbl,LOVL,IE,'Wi',OTRANS)
         if (iErr.eq.0)
     $        call AESogs (iErr,nOVW,IRStbl,IRDtbl,LOVL,IE,'Wo',OTRANS)
         if (iErr.eq.0)
     $        call AESogs (iErr,nOVW,IRStbl,IRDtbl,LOVL,IE,'Ei',OTRANS)
         if (iErr.eq.0)
     $        call AESogs (iErr,nOVW,IRStbl,IRDtbl,LOVL,IE,'Eo',OTRANS)
      endif
      if (LYO.gt.0) then
         if (iErr.eq.0)
     $        call AESogs (iErr,nOVW,IRStbl,IRDtbl,LOVL,IE,'Si',OTRANS)
         if (iErr.eq.0)
     $        call AESogs (iErr,nOVW,IRStbl,IRDtbl,LOVL,IE,'So',OTRANS)
         if (iErr.eq.0)
     $        call AESogs (iErr,nOVW,IRStbl,IRDtbl,LOVL,IE,'Ni',OTRANS)
         if (iErr.eq.0)
     $        call AESogs (iErr,nOVW,IRStbl,IRDtbl,LOVL,IE,'No',OTRANS)
      endif
CCC_   . report
 102  format ('AESNOV:0:', L1, ': ', I4, 1x, I4)
 101  format ('AESNOV:', I2.2, ': ', 2I4)
      if     (COND_N(IFPl))   then
         write (IFPl, 102) OTRANS, nOVW, LOVL
         do j = 1, nOVW
            write (IFPl, 101) j, IRStbl (j), IRDtbl (j)
         enddo
      else if (COND_S(IFPl)) then
#        define IFPl *
         write (IFPl, 102) OTRANS, nOVW, LOVL
         do j = 1, nOVW
            write (IFPl, 101) j, IRStbl (j), IRDtbl (j)
         enddo
#        undef  IFPl
      endif
      call DAtrcU (IFPl, iErr, 'R', 'AESNOV')
      RETURN
      END
CCC_ & AESogs  ## Arpeggio/Dealer/A helper to create stencil (overlap/group/sub)
      subroutine AESogs
     O    (iErr,
     O     nOVW, IRStbl, IRDtbl, LOVL,
     I     IE,   Ctag,   OTRANS)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer) iErr
      _INTENT(INOUT,integer) nOVW
      _INTENT(IN,   integer) LOVL
      _INTENT(OUT,  integer) IRStbl (LOVL), IRDtbl (LOVL)
      _INTENT(IN,   integer) IE (*)
      _INTENT(IN,   character) Ctag*(*)
      _INTENT(IN,   logical) OTRANS
      integer IRD, IRS, IR
      integer j
      logical OFOUND
      integer IR1, IR2
CCC_  - Body
      iErr = 0
      IR = EA_IR(IE)
      if (iErr.eq.0)
     $     call AEAgtp (iErr, IRD, Ctag(1:1), 'D', Ctag(2:2), IE)
      if (iErr.eq.0)
     $     call AEAgtp (iErr, IRS, Ctag(1:1), 'R', Ctag(2:2), IE)
c
      if (iErr.eq.0) then
         OFOUND = .false.
         if (OTRANS) then
            IR1 = IRD
            IR2 = IRS
         else
            IR1 = IRS
            IR2 = IRD
         endif
CC    skip if IR == IR1 (internal operation)
         if (IR.eq.IR1.and.IR.eq.IR2) then
            OFOUND =.true.
         else
            do j = 1, nOVW
               if (IRStbl (j).eq.IR1 .and. IRDtbl (j).eq.IR2) then
                  OFOUND = .true.
               endif
            enddo
         endif
         if (.not.OFOUND) then
            nOVW = nOVW + 1
            if (nOVW.gt.LOVL) then
               iErr = -1
            else
               IRStbl (nOVW) = IR1
               IRDtbl (nOVW) = IR2
            endif
         endif
      endif
      RETURN
      END
CCC_ & AEScov  ## Arpeggio/Dealer/A helper to create stencil (overlap)
      subroutine AEScov
     O    (iErr,  kStncl,
     W     kDSP,  kTYP,  kABL,  KWI,
     I     CRchk, IRchk, IRflg, KSflg, KSstn,
     I     LHP,   LTBL,  IE,    IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   kStncl
      _INTENT(IN, integer)   LHP, LTBL
      _INTENT(OUT,integer)   kDSP (LTBL), kTYP (LTBL), kABL (LTBL)
      _INTENT(OUT,integer)   KWI  (LHP)
      _INTENT(IN, character) CRchk*(*)
      _INTENT(IN, integer)   IRchk, IRflg, KSflg, KSstn
      _INTENT(IN, integer)   IE (*)
      _INTENT(IN, integer)   IFPl
      integer j,  nc,  kcu,   jcu
      integer NP, NBP, NHPlp, MP, LXO, LYO
      integer mpiRS, mpiLB, mpiUB, nBytRS
      integer nExt, nSize
      integer jRflg
CCC_  - Body
CC    KTYP is used twice (CU flag; Types for stencil)
      iErr = 0
c
      call DMZqcn (iErr, kStncl, 'DATATYPE_NULL')
c
      LXO   = EA_LXO(IE)
      LYO   = EA_LYO(IE)
      NHPlp = EA_NP(IE)
      MP    = EA_MP(IE)
c
      jRflg = IRflg
      if (jRflg.lt.0) jRflg = IRchk
c
      if (iErr.eq.0) call AEWtcu (iErr, KTYP,  LTBL, jRflg, IE)
      if (iErr.eq.0) call AEWnhp (iErr, NP,    NBP,  jRflg, IE)
c
      if (iErr.eq.0) then
         do j = 1, LHP
            KWI (j) = 0
         enddo
      endif
      if (LYO.gt.0) then
         do jcu = 1, 4
            kcu = jcu
            if (iErr.eq.0) then
               call AEScos
     $             (iErr,KWI,  LHP,
     $              kcu, CRchk,IRchk,KSflg,KSstn,NHPlp,NP,KTYP,IE, 1)
            endif
         enddo
      endif
      if (LXO.gt.0) then
         do jcu = 5, 8
            kcu = jcu
            if (iErr.eq.0) then
               call AEScos
     $             (iErr,KWI,  LHP,
     $              kcu, CRchk,IRchk,KSflg,KSstn,NHPlp,NP,KTYP,IE, 1)
            endif
         enddo
      endif
CCC_   . stencil creation
      if (iErr.eq.0) then
         call DMZqcn (iErr, mpiRS, '_REALSTD')
         call DMZqcn (iErr, mpiLB, 'LB')
         call DMZqcn (iErr, mpiUB, 'UB')
         call DMWtsz (iErr, nBytRS, mpiRS)
c
         nc = 1
         kDSP (nc) = 0
         kTYP (nc) = mpiLB
         kABL (nc) = 1
c
         do j = 1, MP
            if (KWI (j).gt.0) then
               nc = nc + 1
               kDSP (nc) = nBytRS * (j - 1)
               kTYP (nc) = mpiRS
               kABL (nc) = 1
            endif
         enddo
         nc = nc + 1
         kDSP (nc) = nBytRS * LHP
         kTYP (nc) = mpiUB
         kABL (nc) = 1
         if (nc.gt.LTBL) then
            iErr = -1
         else
            call DMWdts (iErr, kStncl, nc, kABL, kDSP, kTYP)
         endif
      endif
CCC_   . report
 101  format ('AESCOV:', A, 2I3, 1x, 2I7)
      if (iErr.eq.0) then
         call DMWtxt (iErr, nExt,  kStncl)
         call DMWtsz (iErr, nSize, kStncl)
         if      (COND_N(IFPl)) then
            write (IFPl, 101) CRchk, IRchk, jRflg, nExt, nSize
         else if (COND_S(IFPl)) then
            write (*,   101) CRchk, IRchk, jRflg, nExt, nSize
         endif
      endif
      call DAtrcU (IFPl, iErr, 'R', 'AESCOV')
      RETURN
      END
CCC_ & AEScos  ## Arpeggio/Dealer/A helper to create stencil (overlap/sub)
      subroutine AEScos
     O    (iErr,  KWI,   LKWI,
     I     KCU,   CRchk, IRchk, KSflg, KSstn,
     I     NHPlp, NP,    KCflg, IE,    KSW)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   NHPlp, NP, LKWI
      _INTENT(OUT,integer)   KWI  (LKWI)
      _INTENT(IN, character) CRchk*(*)
      _INTENT(IN, integer)   KCU, IRchk, KSflg,  KSstn
      _INTENT(IN, integer)   KCflg (*),  IE (*), KSW
      integer   kph
      integer   IRtgt, ISflg, ISstn
      integer   jf
      character Ctag*(2)
      integer   jkw, jkwmax, jkwmin
CCC_  - Body
      iErr = 0
      call AEPcts (Ctag, KCU)
c
      if (iErr.eq.0) then
         call AEAgtp (iErr, IRtgt, Ctag(1:1), CRchk(1:1), Ctag(2:2), IE)
      endif
      if (iErr.eq.0) then
         if (CRchk(1:1).eq.'D') then
            call AEAgtp (iErr, ISflg, Ctag(1:1), 'T', Ctag(2:2), IE)
         else
            call AEAgtp (iErr, ISflg, Ctag(1:1), 'S', Ctag(2:2), IE)
         endif
      endif
c
      if (iErr.eq.0) then
         ISstn = ISflg * KSstn
         ISflg = ISflg * KSflg
      endif
c
      jkwmax = 0
      jkwmin = 1
      if (iErr.eq.0) then
         if (IRtgt.eq.IRchk) then
            do kph = 0, NHPlp - 1
               jf = kph + ISflg
               if (jf.ge.0.and.jf.lt.NP) then
                  if (KCU .eq. KCflg (1 + jf)) then
                     jkw = kph + 1 + ISstn
                     KWI (jkw) = KWI (jkw) + KSW
                     jkwmax = MAX (jkwmax, jkw)
                     jkwmin = MIN (jkwmin, jkw)
                  endif
               endif
            enddo
         endif
      endif
c
      if (jkwmax.gt.LKWI .or. jkwmin.lt.1) iErr = -1
c
      RETURN
      END
CCC_ & AESowg  ## Stencil generator (overlap/single/overwrite) suite
      subroutine AESowg
     O    (iErr,
     W     kDSP,   kTYP,   kABL,  KWI,
     O     kwStnS, kwStnD, IRwsS, IRwsD,
     I     LwStn,  LTBL,   LHP,   IE,  OTRANS, IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(IN, integer) LwStn, LHP, LTBL
      _INTENT(OUT,integer) kwStnS (LwStn), kwStnD (LwStn)
      _INTENT(OUT,integer) IRwsS  (LwStn), IRwsD  (LwStn)
      _INTENT(OUT,integer) kDSP (LTBL), kTYP (LTBL), kABL (LTBL)
      _INTENT(OUT,integer) KWI  (LHP)
      _INTENT(IN, integer) IE (*)
      _INTENT(IN, integer) IFPl
      _INTENT(IN, logical) OTRANS
      integer kcu, kcutmp
      integer KS,  IRtgt, KSflg
      character CRD
CCC_  - Body
      iErr = 0
      if (LWstn.lt.8) iErr = -9
      do kcutmp = 1, 8
         kcu = kcutmp
         if (iErr.eq.0) then
            if (OTRANS) then
               CRD  = 'D'
               KSflg = 1
            else
               CRD  = 'R'
               KSflg = 0
            endif
            call AESco1
     O          (iErr,  KS,    IRtgt,
     W           kDSP,  kTYP,  kABL,  KWI,
     I           CRD,   KCU,   KSflg,
     I           LHP,   LTBL,  IE,    IFPl)
            kwStnS (kcu) = KS
            IRwsS  (kcu) = IRtgt
         endif
         if (iErr.eq.0) then
            if (OTRANS) then
               CRD  = 'R'
               KSflg = 0
            else
               CRD  = 'D'
               KSflg = 1
            endif
            call AESco1
     O          (iErr,  KS,    IRtgt,
     W           kDSP,  kTYP,  kABL,  KWI,
     I           CRD,   KCU,   KSflg,
     I           LHP,   LTBL,  IE,    IFPl)
            kwStnD (kcu) = KS
            IRwsD  (kcu) = IRtgt
         endif
      enddo
      call DAtrcU (IFPl, iErr, 'R', 'AESOWG')
      RETURN
      END
CCC_ & AESco1  ## Arpeggio/Dealer/A helper to create stencil (overlap/1)
      subroutine AESco1
     O    (iErr,  kStncl, IRtgt,
     W     kDSP,  kTYP,   kABL,  KWflg,
     I     CRchk, KCU,    KSflg,
     I     LHP,   LTBL,   IE,    IFPl)
CCC_  - Description
CC      Stencils to overwrite variables (not cloning)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   kStncl, IRtgt
      _INTENT(IN, integer)   LHP,  LTBL
      _INTENT(OUT,integer)   kDSP (LTBL), kTYP (LTBL), kABL (LTBL)
      _INTENT(OUT,integer)   KWflg (LHP)
      _INTENT(IN, character) CRchk*(*)
      _INTENT(IN, integer)   KCU, KSflg
      _INTENT(IN, integer)   IE (*)
      _INTENT(IN, integer)   IFPl
      integer mpiRS, mpiLB, mpiUB, nBytRS
      integer nc
      integer ISflg, IRflg
      integer kp, jf, NPlp, NP, NBP
      character Ctag*(8)
      integer nExt, nSize
CCC_  - Body
      iErr = 0
      call AEPcts (Ctag, KCU)
CC    to avoid uninitialized warning
      ISflg = 0
c
      if (CRchk(1:1).eq.'D') then
         call AEAgtp (iErr, IRtgt, Ctag(1:1), 'D', Ctag(2:2), IE)
         call AEAgtp (iErr, ISflg, Ctag(1:1), 'T', Ctag(2:2), IE)
         call AEAgtp (iErr, IRflg, Ctag(1:1), 'D', Ctag(2:2), IE)
      else
         call AEAgtp (iErr, IRtgt, Ctag(1:1), 'R', Ctag(2:2), IE)
         call AEAgtp (iErr, ISflg, Ctag(1:1), 'S', Ctag(2:2), IE)
         IRflg = EA_IR(IE)
      endif
c
      call AEWtcu (iErr, KWflg, LTBL, IRflg, IE)
      call AEWnhp (iErr, NP,    NBP,  IRflg, IE)
      NPlp = EA_NP(IE)
c
      ISflg = ISflg * KSflg
c
      call DMZqcn (iErr, mpiRS, '_REALSTD')
      call DMZqcn (iErr, mpiLB, 'LB')
      call DMZqcn (iErr, mpiUB, 'UB')
      call DMWtsz (iErr, nBytRS, mpiRS)
c
      if (iErr.eq.0) then
         nc = 1
         kDSP (nc) = 0
         kTYP (nc) = mpiLB
         kABL (nc) = 1
c
         do kp = 0, NPlp - 1
            jf = kp + ISflg
            if (jf.ge.0.and.jf.lt.NP) then
               if (KCU .eq. KWflg (1 + jf)) then
                  nc = nc + 1
                  kDSP (nc) = nBytRS * kp
                  kTYP (nc) = mpiRS
                  kABL (nc) = 1
               endif
            endif
         enddo
         nc = nc + 1
         kDSP (nc) = nBytRS * LHP
         kTYP (nc) = mpiUB
         kABL (nc) = 1
         if (nc.gt.LTBL) then
            iErr = -1
         else
            call DMWdts (iErr, kStncl, nc, kABL, kDSP, kTYP)
         endif
      endif
CCC_   . report
 101  format ('AESCO1:', A, I1, ': ', I4, 1x, 2I7)
      if (iErr.eq.0) then
         call DMWtxt (iErr, nExt,  kStncl)
         call DMWtsz (iErr, nSize, kStncl)
         if      (COND_N(IFPl)) then
            write (IFPl, 101) CRchk, KCU, IRtgt, nExt, nSize
         else if (COND_S(IFPl)) then
            write (*,   101) CRchk, KCU, IRtgt, nExt, nSize
         endif
      endif
      call DAtrcU (IFPl, iErr, 'R', 'AESCO1')
c
      RETURN
      END
CCC_ & AEScmt  ## Arpeggio/Dealer/A helper to create stencil (moat-type)
      subroutine AEScmt
     O    (iErr, kStncl,
     W     kDTA, LTBL,
     I     kWS,  kWW,  kWE,  kWN,
     I     LHP,  IE,   IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(OUT,integer) kStncl
      _INTENT(IN, integer) LTBL
c$$$      _INTENT(OUT,integer) kDSP (LTBL), kTYP (LTBL), kABL (LTBL)
      _INTENT(OUT,integer) kDTA (LTBL, 3)
      _INTENT(IN, integer) kWS, kWW, kWE, KWN
      _INTENT(IN, integer) LHP
      _INTENT(IN, integer) IE (*)
      _INTENT(IN, integer) IFPl
      integer mpiRS,  mpiLB, mpiUB, nBytRS
      integer nCount, nBL,   nStrd
      integer KDLbi,  LXB,   LYB
      integer MP,     MBP
      integer jST0,   jSTw,  jSTe,  jSTn, jSTs
      integer nExt,   nSize
CCC_  - Body
      iErr = 0
CCC_   . get MPI constants
      if (iErr.eq.0) then
         call DMZqcn (iErr, mpiRS, '_REALSTD')
         call DMZqcn (iErr, mpiLB, 'LB')
         call DMZqcn (iErr, mpiUB, 'UB')
         call DMWtsz (iErr, nBytRS, mpiRS)
      endif
CCC_   . get Dealer attributes
      if (iErr.eq.0) then
         LXB   = EA_LXB(IE)
         LYB   = EA_LYB(IE)
         MP    = EA_MP(IE)
         MBP   = EA_MBP(IE)
         KDLbi = EA_KDLbi(IE)
      endif
CCC_   . generation
      if (iErr.eq.0) then
CCC_    * case: clone all
CC       [LB 1 . NP . MP .. LHP UB]
CC       [   x x x  (x x)           ]
         if (((kWS + kWN).ge.LYB).or.((kWW + kWE).ge.LXB)) then
CC       TODO: check with NP
            call DMWdtc (iErr, jST0, MP, mpiRS)
            nCount = 3
            if (LTBL.lt.nCount) then
               iErr = -1
            else
               kDTA (1, 1) = 0
               kDTA (1, 2) = mpiLB
               kDTA (1, 3) = 1
               kDTA (2, 1) = 0
               kDTA (2, 2) = jST0
               kDTA (2, 3) = 1
               kDTA (3, 1) = nBytRS * LHP
               kDTA (3, 2) = mpiUB
               kDTA (3, 3) = 1
               call DMWdts
     $             (iErr,   kStncl,
     $              nCount, kDTA (1,3), kDTA (1,1), kDTA (1,2))
c$$$               kDSP (1) = 0
c$$$               kTYP (1) = mpiLB
c$$$               kABL (1) = 1
c$$$               kDSP (2) = 0
c$$$               kTYP (2) = jST0
c$$$               kABL (2) = 1
c$$$               kDSP (3) = nBytRS * LHP
c$$$               kTYP (3) = mpiUB
c$$$               kABL (3) = 1
c$$$               call DMWdts (iErr, kStncl, nCount, kABL, kDSP, kTYP)
            endif
CCC_    * case: external-moat type (bi 1)
         else if (KDLbi.eq.1) then
CC       TODO: check with NBP (need UB)
            if (kWS.gt.0) then
               nCount = MBP * LXB * kWS
               call DMWdtc (iErr, jSTs, nCOUNT, mpiRS)
            else
               jSTs = 0
            endif
            if (kWN.gt.0) then
               nCount = MBP * LXB * kWN
               call DMWdtc (iErr, jSTn, nCOUNT, mpiRS)
            else
               jSTn = 0
            endif
            if (kWE.gt.0) then
               nCount = MBP * (LYB - (KWS + KWN))
               nBl    = kWE
               nStrd  = LXB
               call DMWdtv (iErr, jSTe, nCount, nBL, nStrd, mpiRS)
            else
               jSTe = 0
            endif
            if (kWW.gt.0) then
               nCount = MBP * (LYB - (KWS + KWN))
               nBl    = kWW
               nStrd  = LXB
               call DMWdtv (iErr, jSTw, nCount, nBL, nStrd, mpiRS)
            else
               jSTw = 0
            endif
CCC_     + packing
            nCOUNT = 1
            kDTA (nCOUNT, 1) = 0
            kDTA (nCOUNT, 2) = mpiLB
            kDTA (nCOUNT, 3) = 1
            if (kWS.gt.0) then
               nCOUNT = nCOUNT + 1
               kDTA (nCOUNT, 1) = 0
               kDTA (nCOUNT, 2) = jSTs
               kDTA (nCOUNT, 3) = 1
            endif
            if (kWW.gt.0) then
               nCOUNT = nCOUNT + 1
               kDTA (nCOUNT, 1) = nBytRS * (MBP * LXB * kWS)
               kDTA (nCOUNT, 2) = jSTw
               kDTA (nCOUNT, 3) = 1
            endif
            if (kWE.gt.0) then
               nCOUNT = nCOUNT + 1
               kDTA (nCOUNT, 1) = nBytRS * (MBP * LXB * kWS + LXB - kWE)
               kDTA (nCOUNT, 2) = jSTe
               kDTA (nCOUNT, 3) = 1
            endif
            if (kWN.gt.0) then
               nCOUNT = nCOUNT + 1
               kDTA (nCOUNT, 1) = nBytRS * (MBP * LXB * (LYB - kWN))
               kDTA (nCOUNT, 2) = jSTn
               kDTA (nCOUNT, 3) = 1
            endif
            nCOUNT = nCOUNT + 1
            kDTA (nCOUNT, 1) = nBytRS * LHP
            kDTA (nCOUNT, 2) = mpiUB
            kDTA (nCOUNT, 3) = 1
c$$$            kDSP (nCOUNT) = 0
c$$$            kTYP (nCOUNT) = mpiLB
c$$$            kABL (nCOUNT) = 1
c$$$            if (kWS.gt.0) then
c$$$               nCOUNT = nCOUNT + 1
c$$$               kDSP (nCOUNT) = 0
c$$$               kTYP (nCOUNT) = jSTs
c$$$               kABL (nCOUNT) = 1
c$$$            endif
c$$$            if (kWW.gt.0) then
c$$$               nCOUNT = nCOUNT + 1
c$$$               kDSP (nCOUNT) = nBytRS * (MBP * LXB * kWS)
c$$$               kTYP (nCOUNT) = jSTw
c$$$               kABL (nCOUNT) = 1
c$$$            endif
c$$$            if (kWE.gt.0) then
c$$$               nCOUNT = nCOUNT + 1
c$$$               kDSP (nCOUNT) = nBytRS * (MBP * LXB * kWS + LXB - kWE)
c$$$               kTYP (nCOUNT) = jSTe
c$$$               kABL (nCOUNT) = 1
c$$$            endif
c$$$            if (kWN.gt.0) then
c$$$               nCOUNT = nCOUNT + 1
c$$$               kDSP (nCOUNT) = nBytRS * (MBP * LXB * (LYB - kWN))
c$$$               kTYP (nCOUNT) = jSTn
c$$$               kABL (nCOUNT) = 1
c$$$            endif
c$$$            nCOUNT = nCOUNT + 1
c$$$            kDSP (nCOUNT) = nBytRS * LHP
c$$$            kTYP (nCOUNT) = mpiUB
c$$$            kABL (nCOUNT) = 1
            if (LTBL.lt.nCount) then
               iErr = -1
            else
               call DMWdts
     $             (iErr,   kStncl,
     $              nCount, kDTA (1,3), kDTA (1,1), kDTA (1,2))
c$$$               call DMWdts (iErr, kStncl, nCount, kABL, kDSP, kTYP)
            endif
CCC_    * case: external-moat type (bi 0)
         else
CC       not implemented yet
            iErr = -9
         endif
      endif
CCC_   . report
      if (iErr.eq.0) then
         call DMWtxt (iErr, nExt,  kStncl)
         call DMWtsz (iErr, nSize, kStncl)
 101     format ('AESCMT:', 4I2.2, ': ', 2I7)
         if      (COND_N(IFPl)) then
            write (IFPl, 101) kWS,  kWW,  kWE,  kWN, nExt, nSize
         else if (COND_S(IFPl)) then
            write (*,   101) kWS,  kWW,  kWE,  kWN, nExt, nSize
         endif
      endif
      call DAtrcU (IFPl, iErr, 'R', 'AESCMT')
      RETURN
      END
CCC_ & AESwsh  ## Arpeggio/Dealer helper to create stencil (wing shifts)
      subroutine AESwsh
     O    (iErr,
     W     kDTA,
     O     kStncS, kStncD, IRStbl, IRDtbl,
     I     LTBL,   LHP,    IE,     IFPl)
CCC_  - Description
CC        Create stencils for E W N S shifts
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(IN, integer) LTBL, LHP
      _INTENT(OUT,integer) kStncS (*),  kStncD (*)
      _INTENT(OUT,integer) IRStbl (*),  IRDtbl (*)
      _INTENT(OUT,integer) kDTA (LTBL, 3)
      _INTENT(IN, integer) IE (*)
      _INTENT(IN, integer) IFPl
      integer mpiRS,  mpiND
      integer KDLbi,  LXB,   LYB,   LXW,  LYW
      integer MP,     MBP
      integer kSS,    kSD,   IRS,   IRD
      integer j,      ji,    jErr
      integer nExtS,  nSizS
      integer nExtD,  nSizD
#define _shiftE 1
#define _shiftW 2
#define _shiftN 3
#define _shiftS 4
CCC_  - Body
      iErr = 0
CCC_   . get MPI constants
      if (iErr.eq.0) then
         call DMZqcn (iErr, mpiRS, '_REALSTD')
         call DMZqcn (iErr, mpiND, 'DATATYPE_NULL')
      endif
CCC_   . get Dealer attributes
      LXB   = EA_LXB(IE)
      LYB   = EA_LYB(IE)
      LXW   = EA_LXW(IE)
      LYW   = EA_LYW(IE)
      MP    = EA_MP(IE)
      MBP   = EA_MBP(IE)
      KDLbi = EA_KDLbi(IE)
CCC_   . generation in X
 101  format ('AESWSH:', I1, 'S ', I7, I7, I3)
 102  format ('AESWSH:', I1, 'D ', I7, I7, I3)
      if (LXW.eq.0) then
         IRStbl(_shiftE) = -1
         IRStbl(_shiftW) = -1
         IRDtbl(_shiftE) = -1
         IRDtbl(_shiftW) = -1
         kStncS(_shiftE) = mpiND
         kStncS(_shiftW) = mpiND
         kStncD(_shiftE) = mpiND
         kStncD(_shiftW) = mpiND
      else
CCC_    * to East
         if (iErr.eq.0) then
            call AESwsx
     O          (iErr,  kSS,  IRS,
     W           kDTA,
     I           +LXW,  +LXW,
     I           mpiRS, LTBL, LHP,  IE,   IFPl)
            call AESwsx
     O          (iErr,  kSD,  IRD,
     W           kDTA,
     I           -LXW,  0,
     I           mpiRS, LTBL, LHP,  IE,   IFPl)
            IRStbl(_shiftE) = IRS
            IRDtbl(_shiftE) = IRD
            kStncS(_shiftE) = kSS
            kStncD(_shiftE) = kSD
         endif
CCC_    * to West
         if (iErr.eq.0) then
            call AESwsx
     O          (iErr,  kSS,  IRS,
     W           kDTA,
     I           -LXW,  +LXW,
     I           mpiRS, LTBL, LHP,  IE,   IFPl)
            call AESwsx
     O          (iErr,  kSD,  IRD,
     W           kDTA,
     I           +LXW,  0,
     I           mpiRS, LTBL, LHP,  IE,   IFPl)
            IRStbl(_shiftW) = IRS
            IRDtbl(_shiftW) = IRD
            kStncS(_shiftW) = kSS
            kStncD(_shiftW) = kSD
         endif
         if (iErr.eq.0) then
            do j = 1, 2
               if (j.eq.1) then
                  ji = _shiftE
               else
                  ji = _shiftW
               endif
               call DMWtxt (jErr, nExtS, kStncS(ji))
               call DMWtsz (jErr, nSizS, kStncS(ji))
               call DMWtxt (jErr, nExtD, kStncD(ji))
               call DMWtsz (jErr, nSizD, kStncD(ji))
               if      (COND_N(IFPl)) then
                  write (IFPl, 101) ji, nExtS, nSizS, IRStbl(ji)
                  write (IFPl, 102) ji, nExtD, nSizD, IRDtbl(ji)
               else if (COND_S(IFPl)) then
                  write (*,    101) ji, nExtS, nSizS, IRStbl(ji)
                  write (*,    102) ji, nExtD, nSizD, IRDtbl(ji)
               endif
            enddo
         endif
      endif
CCC_   . generation in Y
      if (LYW.eq.0) then
         IRStbl(_shiftN) = -1
         IRStbl(_shiftS) = -1
         IRDtbl(_shiftN) = -1
         IRDtbl(_shiftS) = -1
         kStncS(_shiftN) = mpiND
         kStncS(_shiftS) = mpiND
         kStncD(_shiftN) = mpiND
         kStncD(_shiftS) = mpiND
      else
         if (iErr.eq.0) then
CCC_    * to North
            call AESwsy
     O          (iErr,  kSS,  IRS,
     W           kDTA,
     I           +LYW,  +LYW,
     I           mpiRS, LTBL, LHP,  IE,   IFPl)
            call AESwsy
     O          (iErr,  kSD,  IRD,
     W           kDTA,
     I           -LYW,  0,
     I           mpiRS, LTBL, LHP,  IE,   IFPl)
            IRStbl(_shiftN) = IRS
            IRDtbl(_shiftN) = IRD
            kStncS(_shiftN) = kSS
            kStncD(_shiftN) = kSD
         endif
CCC_    * to South
         if (iErr.eq.0) then
            call AESwsy
     O          (iErr,  kSS,  IRS,
     W           kDTA,
     I           -LYW,  +LYW,
     I           mpiRS, LTBL, LHP,  IE,   IFPl)
            call AESwsy
     O          (iErr,  kSD,  IRD,
     W           kDTA,
     I           +LYW,  0,
     I           mpiRS, LTBL, LHP,  IE,   IFPl)
            IRStbl(_shiftS) = IRS
            IRDtbl(_shiftS) = IRD
            kStncS(_shiftS) = kSS
            kStncD(_shiftS) = kSD
         endif
         if (iErr.eq.0) then
            do j = 3, 4
               if (j.eq.3) then
                  ji = _shiftN
               else
                  ji = _shiftS
               endif
               call DMWtxt (jErr, nExtS, kStncS(ji))
               call DMWtsz (jErr, nSizS, kStncS(ji))
               call DMWtxt (jErr, nExtD, kStncD(ji))
               call DMWtsz (jErr, nSizD, kStncD(ji))
               if      (COND_N(IFPl)) then
                  write (IFPl, 101) ji, nExtS, nSizS, IRStbl(ji)
                  write (IFPl, 102) ji, nExtD, nSizD, IRDtbl(ji)
               else if (COND_S(IFPl)) then
                  write (*,    101) ji, nExtS, nSizS, IRStbl(ji)
                  write (*,    102) ji, nExtD, nSizD, IRDtbl(ji)
               endif
            enddo
         endif
      endif
c
      call DAtrcU (IFPl, iErr, 'R', 'AESWSH')
      RETURN
      END
CCC_ & AESwsx  ## Arpeggio/Dealer helper to create stencil (wing shifts/x)
      subroutine AESwsx
     O    (iErr,   KSTN,   IRNK,
     W     kDTA,
     I     LWID,   LOFS,
     I     mTYP,   LTBL,   LHP,    IE,     IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(IN, integer) LTBL, LHP
      _INTENT(OUT,integer) kSTN, IRNK
      _INTENT(OUT,integer) kDTA (LTBL,3)
      _INTENT(IN, integer) IE (*)
      _INTENT(IN, integer) IFPl
      _INTENT(IN, integer) mTYP
      _INTENT(IN, integer) LWID, LOFS
      integer nByt
      integer mpiLB, mpiUB
      integer nc
      integer LXB,   LYB,  MBP,  KDLbi
      integer kSblk, kSrow
      integer jb,    jhp,   jwp
CCC_  - Body
      iErr = 0
      kSTN = 0
      IRNK = -1
c
      if (iErr.eq.0) call DMZqcn (iErr, mpiLB, 'LB')
      if (iErr.eq.0) call DMZqcn (iErr, mpiUB, 'UB')
      if (iErr.eq.0) call DMWtsz (iErr, nByt,  mTYP)
c
      KDLbi = EA_KDLbi(IE)
      if (KDLbi.eq.0) then
         iErr = -999
         return
      endif
c
      LXB   = EA_LXB(IE)
      LYB   = EA_LYB(IE)
      MBP   = EA_MBP(IE)
c
      jwp = 0
      nc = 0
c
      if (iErr.eq.0) then
         nc = nc + 1
         kDTA (nc, 1) = 0
         kDTA (nc, 2) = mpiLB
         kDTA (nc, 3) = 1
      endif
      if (iErr.eq.0) then
         if (LWID.gt.0) then
            IRNK = EA_IRXP(IE)
            if (LOFS.gt.0) then
CCC_   . [    X-]
               jwp = LXB - 2 * LWID
            else
CCC_   . [     X]
               jwp = LXB - 1 * LWID
            endif
         else
            IRNK = EA_IRXM(IE)
            if (LOFS.gt.0) then
CCC_   . [-X    ]
               jwp = - LWID
            else
CCC_   . [X     ]
               jwp = 0
            endif
         endif
         nc = nc + 1
         kDTA (nc, 1) = nByt * jwp
         kDTA (nc, 2) = mTYP
         kDTA (nc, 3) = ABS (LWID)
      endif
      if (iErr.eq.0) then
         nc = nc + 1
         kDTA (nc, 1) = nByt * LXB
         kDTA (nc, 2) = mpiUB
         kDTA (nc, 3) = 1
      endif
c
      if (iErr.eq.0) then
         call DMWdts
     $        (iErr, kSblk, nc, kDTA (1,3), kDTA (1,1), kDTA (1,2))
      endif
CCC_   . work only when sequential in x  (jhp 0:)
      nc = 0
      if (iErr.eq.0) then
         nc = nc + 1
         kDTA (nc, 1) = 0
         kDTA (nc, 2) = mpiLB
         kDTA (nc, 3) = 1
      endif
      do jb = 0, MBP - 1
         jhp = jb * LXB + jwp
C         skip 2, -2 (src/dest to null-block)
         if (EA_listXW(IE,jhp).eq.1
     $        .or. EA_listXW(IE,jhp).eq.-1) then
            nc = nc + 1
            kDTA (nc, 1) = nByt * LXB * jb
            kDTA (nc, 2) = kSblk
            kDTA (nc, 3) = 1
         endif
      enddo
      if (iErr.eq.0) then
         nc = nc + 1
         kDTA (nc, 1) = nByt * LXB * MBP
         kDTA (nc, 2) = mpiUB
         kDTA (nc, 3) = 1
      endif
c
c$$$      do jb = 1, nc
c$$$         write (*, *) jb, kDTA(jb,1),kDTA(jb,2),kDTA(jb,3)
c$$$      enddo
      if (nc.gt.LTBL) iErr = -1
c
      if (iErr.eq.0) then
         call DMWdts
     $        (iErr, kSrow, nc, kDTA (1,3), kDTA (1,1), kDTA (1,2))
      endif
c
      nc = 0
      if (iErr.eq.0) then
         nc = nc + 1
         kDTA (nc, 1) = 0
         kDTA (nc, 2) = mpiLB
         kDTA (nc, 3) = 1
         nc = nc + 1
         kDTA (nc, 1) = 0
         kDTA (nc, 2) = kSrow
         kDTA (nc, 3) = LYB
         nc = nc + 1
         kDTA (nc, 1) = nByt * LHP
         kDTA (nc, 2) = mpiUB
         kDTA (nc, 3) = 1
      endif
c$$$c
c$$$      do jb = 1, nc
c$$$         write (*, *) jb, kDTA(jb,1),kDTA(jb,2),kDTA(jb,3)
c$$$      enddo
c
      if (iErr.eq.0) then
         call DMWdts
     $        (iErr, kSTN, nc, kDTA (1,3), kDTA (1,1), kDTA (1,2))
      endif
c
      call DAtrcU (IFPl, iErr, 'R', 'AESWSX')
      RETURN
      END
CCC_ & AESwsy  ## Arpeggio/Dealer helper to create stencil (wing shifts/y)
      subroutine AESwsy
     O    (iErr,   KSTN,   IRNK,
     W     kDTA,
     I     LWID,   LOFS,
     I     MTYP,   LTBL,   LHP,    IE,     IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(IN, integer) LTBL, LHP
      _INTENT(OUT,integer) kSTN, IRNK
      _INTENT(OUT,integer) kDTA (LTBL,3)
      _INTENT(IN, integer) IE (*)
      _INTENT(IN, integer) IFPl
      _INTENT(IN, integer) mTYP
      _INTENT(IN, integer) LWID, LOFS
CCC_  - Body
      integer nByt
      integer mpiLB, mpiUB
      integer nc
      integer LXB,   LYB,  MBP,  KDLbi
      integer jb,    jhp,  jwp
      integer jyb
CCC_  - Body
      iErr = 0
      kSTN = 0
      IRNK = -1
c
      if (iErr.eq.0) call DMZqcn (iErr, mpiLB, 'LB')
      if (iErr.eq.0) call DMZqcn (iErr, mpiUB, 'UB')
      if (iErr.eq.0) call DMWtsz (iErr, nByt,  mTYP)
c
      KDLbi = EA_KDLbi(IE)
      if (KDLbi.eq.0) then
         iErr = -999
         return
      endif
c
      LXB   = EA_LXB(IE)
      LYB   = EA_LYB(IE)
      MBP   = EA_MBP(IE)
c
      jwp = 0
      nc = 0
c
      if (iErr.eq.0) then
         nc = nc + 1
         kDTA (nc, 1) = 0
         kDTA (nc, 2) = mpiLB
         kDTA (nc, 3) = 1
      endif
      if (iErr.eq.0) then
         if (LWID.gt.0) then
            IRNK = EA_IRYP(IE)
            if (LOFS.gt.0) then
CCC_   . [    X-]
               jwp = LYB - 2 * LWID
            else
CCC_   . [     X]
               jwp = LYB - 1 * LWID
            endif
         else
            IRNK = EA_IRYM(IE)
            if (LOFS.gt.0) then
CCC_   . [-X    ]
               jwp = - LWID
            else
CCC_   . [X     ]
               jwp = 0
            endif
         endif
         jwp = jwp * LXB * MBP
      endif
CCC_   . work only when sequential in x  (jhp 0:)
      nc = 0
      if (iErr.eq.0) then
         nc = nc + 1
         kDTA (nc, 1) = 0
         kDTA (nc, 2) = mpiLB
         kDTA (nc, 3) = 1
      endif
      do jyb = 0, ABS(LWID) - 1
c$$$      do jyb = 0, 0
         do jb = 0, MBP - 1
            jhp = jb * LXB + jwp + jyb * LXB * MBP
C         skip 2, -2 (src/dest to null-block)
c$$$         write (*,*) 'WSY', jb, jhp,
c$$$     $        EA_listLW(IE,jhp),
c$$$     $        EA_listLX(IE,jhp),
c$$$     $        EA_listLY(IE,jhp),EA_listYW(IE,jhp)
            if (EA_listYW(IE,jhp).eq.1
     $           .or.EA_listYW(IE,jhp).eq.-1) then
               nc = nc + 1
               kDTA (nc, 1) = nByt * jhp
               kDTA (nc, 2) = mTYP
               kDTA (nc, 3) = LXB
            endif
         enddo
      enddo
      if (iErr.eq.0) then
         nc = nc + 1
         kDTA (nc, 1) = nByt * LHP
         kDTA (nc, 2) = mpiUB
         kDTA (nc, 3) = 1
      endif
c
      if (nc.gt.LTBL) iErr = -1
c
c$$$      do jb = 1, nc
c$$$         write (*, *) 'YS', jb, kDTA(jb,1),kDTA(jb,2),kDTA(jb,3),
c$$$     $        EA_IR(IE)
c$$$      enddo
c$$$c
      if (iErr.eq.0) then
         call DMWdts
     $        (iErr, kSTN, nc, kDTA (1,3), kDTA (1,1), kDTA (1,2))
      endif
c
      call DAtrcU (IFPl, iErr, 'R', 'AESWSY')
      RETURN
      END
CCC_* [AEG] Global data manipulation
CCC_ + AEGcls  ## Arpeggio/Dealer/A collect standard
      subroutine AEGcls
     O    (iErr,  VG,
     I     VP,    LP,    LG, MO,
     I     iROOT, KSglb, IE, iMA)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   LP, LG, MO
      _INTENT(OUT,_REALSTD)  VG (*)
      _INTENT(IN, _REALSTD)  VP (*)
      _INTENT(IN, integer)   iROOT
      _INTENT(IN, integer)   KSglb (*), IE (*), iMA (*)
      integer kg,  kp, ko
      integer NR,  jRoot
      integer NP
c
      iErr = 0
      call DMAget (NR,    iMA, 'NR')
c
      if (NR.le.1) then
         NP = EA_NP(IE)
         do ko = 0, MO - 1
            do kp = 0, NP - 1
               kg = ko * LG + EA_listLW(IE,kp)
               VG (kg) = VP (ko * LP + 1 + kp)
            enddo
         enddo
      else
         jRoot = iROOT
         if (jRoot.lt.0) jRoot = 0
         call DMDcol
     $       (iErr, VG,
     $        VP, jRoot, KSglb (1), KSglb (1 + NR), MO, iMA)
      endif
c
      RETURN
      END
CCC_ + AEGdss  ## Arpeggio/Dealer/A distribute standard
CCC_* [AEW] wrapper for primitives (with IE)
CCC_ & AEWtcu  ## Arpeggio/Dealer/A create CU table primitive (wrapper)
      subroutine AEWtcu
     O    (iErr, jTblCU,
     I     LTBL,  IR,  IE)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(IN, integer) LTBL
      _INTENT(OUT,integer) jTblCU (LTBL)
      _INTENT(IN, integer) IR, IE (*)
      integer MP
      integer LCXi, LCXo, LCYi, LCYo
      integer LXB,  LYB,  LXO,  LYO, NXG, NYG
      integer MBX,  MBP,  KDLbi
      integer IRtmp, NR
CCC_  - Body
      iErr = 0
      MP    = EA_MP(IE)
      LCXi  = EA_LCXi(IE)
      LCXo  = EA_LCXo(IE)
      LCYi  = EA_LCYi(IE)
      LCYo  = EA_LCYo(IE)
      LXB   = EA_LXB(IE)
      LYB   = EA_LYB(IE)
      LXO   = EA_LXO(IE)
      LYO   = EA_LYO(IE)
      NXG   = EA_NXG(IE)
      NYG   = EA_NYG(IE)
      MBX   = EA_MBX(IE)
      KDLbi = EA_KDLbi(IE)
      MBP   = EA_MBP(IE)
      NR    = EA_NR(IE)
c
      IRtmp = IR
      if (IRtmp.lt.0) IRtmp = EA_IR(IE)
c
      call AEPtcu
     O    (iErr,  jTblCU, LTBL,
     I     MP,
     I     LCXi,  LCXo, LCYi, LCYo,
     I     LXB,   LYB,  LXO,  LYO,  NXG, NYG,
     I     MBX,   MBP,  KDLbi,
     I     IRtmp, NR)
c
      RETURN
      END
CCC_ & AEWnhp  ## Arpeggio/Dealer/A NP (wrapper)
      subroutine AEWnhp
     O    (iErr,  NP,   NBP,
     I     IR,    IE)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   NP,   NBP
      _INTENT(IN, integer)   IR,    IE (*)
c
      integer   NR
      integer   KDLnb, KDLbi
      integer   NXU,   NYU,  MP
      integer   NBG,   MBP,  MBX
      integer   LXB,   LYB
c
      integer IRtmp
CCC_  - Body
      IRtmp = IR
      if (IRtmp.lt.0) IRtmp = EA_IR(IE)
      NR    = EA_NR(IE)
      KDLnb = EA_KDLnb(IE)
      KDLbi = EA_KDLbi(IE)
      NXU   = EA_NXU(IE)
      NYU   = EA_NYU(IE)
      MP    = EA_MP(IE)
      NBG   = EA_NBG(IE)
      MBP   = EA_MBP(IE)
      MBX   = EA_MBX(IE)
      LXB   = EA_LXB(IE)
      LYB   = EA_LYB(IE)
c
      call AEPnhp
     O    (iErr,  NP,    NBP,
     I     IRtmp, NR,
     I     KDLnb, KDLbi, NXU, NYU, MP, NBG, MBP, MBX, LXB, LYB)
      RETURN
      END
CCC_* [AEP] primitives
CCC_ & AEPt2e  ## Arpeggio/Dealer/A [t:mo/gl/xy] to [e:lo/gl/xy] (ordinal or source)
CCC_ & AEPe2t  ## Arpeggio/Dealer/A [e:lo/gl/xy] to [t:mo/gl/xy]
      subroutine AEPe2t
     O    (JPT, KFL, NAS,
     I     JLG, LB,  LW,  MLG)
c
      implicit none
      _INTENT(OUT,integer) JPT
      _INTENT(OUT,integer) NAS
      _INTENT(OUT,integer) KFL
      _INTENT(IN, integer) JLG
      _INTENT(IN, integer) LB, LW, MLG
      integer jbg, jc, mbg
      integer jld, jls, jus, jud
c KFL 0: ordinal;  +1: wing clone src; -1:wing clone dst
      jbg = JLG / LB
      mbg = (MLG - 1) / LB + 1
      JPT = JLG - (jbg * LW * 2)
      jc  = JLG - (jbg * LB)
      jld = LW
      jls = LW * 2
      jus = LB - (LW * 2)
      jud = LB - LW
      KFL = 0
      nas = 0
      if      (jc.lt.jld) then
         if (jbg.gt.0) then
            KFL = -1
            nas = - 2 * LW
         endif
      else if (jld.le.jc .and. jc.lt.jls) then
         if (jbg.gt.0) then
            KFL = +1
            nas = - 2 * LW
         endif
      else if (jus.le.jc .and. jc.lt.jud) then
         if (jbg.lt.mbg - 1) then
            KFL = +1
            nas = 2 * LW
         endif
      else if (jud.le.jc) then
         if (jbg.lt.mbg - 1) then
            KFL = -1
            nas = 2 * LW
         endif
      endif
      RETURN
      END
CCC_ & AEPh2e  ## (AEPpij) Arpeggio/Dealer/A [h:lo/pr/2d] to [e:lo/gl/xy]
      subroutine AEPh2e
     O    (JXLG, JYLG,
     I     JHLP,
     I     LXB, LYB, MBX, MBP, IR, NR, KDLbi)
CC horizontal index (start from zero)
      implicit none
      _INTENT(OUT,integer) JXLG, JYLG
      _INTENT(IN, integer) JHLP
      _INTENT(IN, integer) KDLbi
      _INTENT(IN, integer) LXB, LYB
      _INTENT(IN, integer) MBX, MBP
      _INTENT(IN, integer) IR,  NR
      integer jwbg, jhbp, iRef, jRef, jxc, jyc
c
c$$$  call AEPpbp (kbp,  JHLP, LXB, LYB, MBP, KDLbi)
      call AEPh2b (jhbp,  JHLP, LXB, LYB, MBP, KDLbi)
      jwbg = jhbp * NR + IR
      jRef =      (jwbg / MBX)  * LYB
      iRef = (MOD (jwbg,  MBX)) * LXB
c$$$  call AEPp2c (jxc, jyc,   JHLP, LXB, LYB, MBP, KDLbi)
      call AEPh2s (jxc, jyc,   JHLP, LXB, LYB, MBP, KDLbi)
      JXLG  = iRef + jxc
      JYLG  = jRef + jyc
      RETURN
      END
CCC_ & AEPh2b  ## (AEPpbp) Arpeggio/Dealer/A [h:lo/pr/2d] to [b:br/pr/2d]
      subroutine AEPh2b
     O    (JHBP,
     I     JHLP,  LXB, LYB, MBP, KDLbi)
      implicit none
      _INTENT(OUT,integer) JHBP
      _INTENT(IN, integer) JHLP
      _INTENT(IN, integer) LXB, LYB, MBP
      _INTENT(IN, integer) KDLbi
      if (KDLbi.eq.0) then
         JHBP  = JHLP / (LXB * LYB)
      else if (KDLbi.eq.1) then
         JHBP  = MOD (JHLP, (LXB * MBP)) / LXB
      else
         JHBP  = -1
      endif
      RETURN
      END
CCC_ & AEPh2s  ## (AEPp2c) Arpeggio/Dealer/A [h:lo/pr/2d] to [s:bi/xy]
      subroutine AEPh2s
     O    (JXC,  JYC,
     I     JHLP, LXB, LYB, MBP, KDLbi)
      implicit none
      _INTENT(OUT,integer) JXC, JYC
      _INTENT(IN, integer) JHLP
      _INTENT(IN, integer) LXB, LYB, MBP, KDLbi
      if (KDLbi.eq.0) then
         JXC = MOD (JHLP, LXB)
         JYC = MOD (JHLP / LXB, LYB)
      else if (KDLbi.eq.1) then
         JXC = MOD (JHLP, LXB)
         JYC = JHLP / (MBP * LXB)
      else
         JXC = -1
         JYC = -1
      endif
      RETURN
      END
c$$$CCC_ & AEPanm  ## Arpeggio/Dealer/A lo/priv[hl:a] to neg binary mask
c$$$      subroutine AEPanm
c$$$     O    (KNM,
c$$$     I     JHL,
c$$$     I     LXB,  LYB,  LXO,   LYO,  NXG, NYG,
c$$$     I     MBX,  MBP,  KDLbi, IR,   NR)
c$$$CCC_  * Description
c$$$CC        0 if interior (including overlaps)
c$$$CC       -1 otherwise
c$$$CCC_  * Declaration
c$$$      implicit none
c$$$      _INTENT(OUT,integer) KNM
c$$$      _INTENT(IN, integer) JHL
c$$$      _INTENT(IN, integer) LXB,  LYB,  LXO,  LYO, NXG, NYG
c$$$      _INTENT(IN, integer) MBX,  MBP,  KDLbi
c$$$      _INTENT(IN, integer) IR,   NR
c$$$      integer jxl, jyl
c$$$      integer NXU, NYU
c$$$CCC_  * Body
c$$$      NXU = _NG2NU(+NXG, +LXO)
c$$$      NYU = _NG2NU(+NYG, +LYO)
c$$$CC       log/prv[hl:a] to log/global xy (zero)
c$$$      call AEPa2l (jxl, jyl, JHL, LXB, LYB, MBX, MBP, IR, NR, KDLbi)
c$$$      KNM  = -1
c$$$CC       0 even if normal boundary
c$$$      if (LXO.gt.0 .and. LYO.gt.0) then
c$$$         if ((jxl.lt.NXU).and.(jyl.lt.NYU)) KNM = 0
c$$$      else if (LXO.gt.0) then
c$$$         if ((jxl.lt.NXU).and.
c$$$     $        (jyl.gt.0).and.(jyl.lt.(NYG-1))) KNM = 0
c$$$      else if (LYO.gt.0) then
c$$$         if ((jyl.lt.NYU).and.
c$$$     $        (jxl.gt.0).and.(jxl.lt.(NXG-1))) KNM = 0
c$$$      else
c$$$         if ((jyl.gt.0).and.(jyl.lt.(NYG-1))
c$$$     $        .and. (jxl.gt.0).and.(jxl.lt.(NXG-1))) KNM = 0
c$$$      endif
c$$$      RETURN
c$$$      END
CCC_ & AEPpbm  ## Arpeggio/Dealer/A private to binary mask
      subroutine AEPpbm
     O    (KV,
     I     KP,
     I     LXB,  LYB,  LXO,   LYO,  NXG, NYG,
     I     MBX,  MBP,  KDLbi, IR,   NR)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer) KV
      _INTENT(IN, integer) KP
      _INTENT(IN, integer) LXB,  LYB,  LXO,  LYO, NXG, NYG
      _INTENT(IN, integer) MBX,  MBP,  KDLbi
      _INTENT(IN, integer) IR,   NR
      integer i0,  j0
      integer NXU, NYU
CCC_  - Body
      NXU = _NG2NU(+NXG, +LXO)
      NYU = _NG2NU(+NYG, +LYO)
      call AEPpij (i0, j0, KP, LXB, LYB, MBX, MBP, IR, NR, KDLbi)
      kv  = -1
CC       0 even if normal boundary
      if (LXO.gt.0 .and. LYO.gt.0) then
         if ((i0.lt.NXU).and.(j0.lt.NYU)) kv = 0
      else if (LXO.gt.0) then
         if ((i0.lt.NXU).and.
     $        (j0.gt.0).and.(j0.lt.(NYG-1))) kv = 0
      else if (LYO.gt.0) then
         if ((j0.lt.NYU).and.
     $        (i0.gt.0).and.(i0.lt.(NXG-1))) kv = 0
      else
         if ((j0.gt.0).and.(j0.lt.(NYG-1))
     $        .and. (i0.gt.0).and.(i0.lt.(NXG-1))) kv = 0
      endif
      RETURN
      END
CCC_ & AEPcts  ## Arpeggio/Dealer/A private CT index to string
#define CU_So 2
#define CU_Wo 6
#define CU_Eo 8
#define CU_No 4
#define CU_Si 1
#define CU_Wi 5
#define CU_Ei 7
#define CU_Ni 3
      subroutine AEPcts (CT, kcu)
      implicit none
      _INTENT(OUT,character) CT*(*)
      _INTENT(IN, integer)   kcu
      character CTTbl (8)*(2)
      data      CTTbl /'Si','So','Ni','No', 'Wi','Wo','Ei','Eo'/
      save      CTTbl
      CT = CTTbl (kcu)
      RETURN
      END
CCC_ & AEPctu  ## Arpeggio/Dealer/A private CT string to index
      subroutine AEPctu (CT, kcu)
      implicit none
      _INTENT(IN, character) CT*(*)
      _INTENT(OUT,integer)   kcu
      character CTTbl (8)*(2)
      data      CTTbl /'Si','So','Ni','No', 'Wi','Wo','Ei','Eo'/
      save      CTTbl
      integer j
      kcu = 0
      do j = 1, 8
         if (CTTbl (j).eq.CT) kcu = j
      enddo
      RETURN
      END
CCC_ & AEPpct  ## Arpeggio/Dealer/A private CT index (table)
      subroutine AEPpct
     O    (KCTB,
     I     KP,
     I     LCXi, LCXo, LCYi, LCYo,
     I     LXB,  LYB,  LXO,  LYO,  NXG, NYG,
     I     MBX,  MBP,  KDLbi,
     I     IR,   NR)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer) KCTB (*)
      _INTENT(IN, integer) KP
      _INTENT(IN, integer) LCXi, LCXo, LCYi, LCYo
      _INTENT(IN, integer) LXB,  LYB,  LXO,  LYO, NXG, NYG
      _INTENT(IN, integer) MBX,  MBP,  KDLbi
      _INTENT(IN, integer) IR,   NR
      integer l
      integer i0,  j0, ic,  jc
      integer ioe, iow, jon, jos
      integer NXU, NYU
CCC_  - Body
      NXU = _NG2NU(+NXG, +LXO)
      NYU = _NG2NU(+NYG, +LYO)
      call AEPpij (i0, j0, KP, LXB, LYB, MBX, MBP, IR, NR, KDLbi)
      call AEPp2c (ic, jc, KP, LXB, LYB, MBP, KDLbi)
c
      do l = 1, 8
         KCTB (l) = 0
      enddo
      ioe = i0 + NXG
      iow = i0 - NXG
      jon = j0 + NYG
      jos = j0 - NYG
      if ((ioe.ge.NXG+LXO) .and. (ioe.lt.NXU)) then
CC          tEo/tEi
         if (ic.lt.LCXo) then
            kctb (CU_Eo) = 1
         else
            kctb (CU_Ei) = 1
         endif
      endif
      if ((iow.ge.0)       .and. (iow.lt.LXO)) then
CC          tWo/tWi
         if (ic.lt.LCXo) then
            kctb (CU_Wo) = 1
         else
            kctb (CU_Wi) = 1
         endif
      endif
      if ((jon.ge.NYG+LYO) .and. (jon.lt.NYU)) then
CC          tNo/tNi
         if (LXO.le.0.or. (i0.ge.LXO.and.i0.lt.NXG+LXO)) then
            if (jc.lt.LCYo) then
               kctb (CU_No) = 1
            else
               kctb (CU_Ni) = 1
            endif
         endif
      endif
      if ((jos.ge.0)       .and. (jos.lt.LYO)) then
CC          tSo/tSi
         if (LXO.le.0.or. (i0.ge.LXO.and.i0.lt.NXG+LXO)) then
            if (jc.lt.LCYo) then
               kctb (CU_So) = 1
            else
               kctb (CU_Si) = 1
            endif
         endif
      endif
      RETURN
      END
CCC_ & AEPpcu  ## Arpeggio/Dealer/A private CU index
      subroutine AEPpcu
     O    (KCU,
     I     KP,
     I     LCXi, LCXo, LCYi, LCYo,
     I     LXB,  LYB,  LXO,  LYO,  NXG, NYG,
     I     MBX,  MBP,  KDLbi,
     I     IR,   NR)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer) KCU
      _INTENT(IN, integer) KP
      _INTENT(IN, integer) LCXi, LCXo, LCYi, LCYo
      _INTENT(IN, integer) LXB,  LYB,  LXO,  LYO, NXG, NYG
      _INTENT(IN, integer) MBX,  MBP,  KDLbi
      _INTENT(IN, integer) IR,   NR
      integer i0,  j0, ic,  jc
      integer kv
CCC_  - Body
      call AEPpij (i0, j0, KP, LXB, LYB, MBX, MBP, IR, NR, KDLbi)
      call AEPp2c (ic, jc, KP, LXB, LYB, MBP, KDLbi)
c
      call AEPpbm
     O    (kv,
     I     KP,
     I     LXB,  LYB,  LXO,   LYO,  NXG, NYG,
     I     MBX,  MBP,  KDLbi, IR,   NR)
CCC_   . x
      kcu = 0
      if (kv.ge.0 .and. LXO.gt.0) then
         if (i0.lt.LXO) then
            kcu = CU_Wi
            if (ic.ge.LCXi) kcu = CU_Wo
         else if (i0.ge.NXG + LXO) then
            kcu = CU_Ei
            if (ic.ge.LCXo) kcu = CU_Eo
         endif
      endif
CCC_   . y
      if (kv.ge.0 .and. LYO.gt.0.and.kcu.eq.0) then
         if (j0.lt.LYO) then
            kcu = CU_Si
            if (jc.ge.LCYi) kcu = CU_So
         else if (j0.ge.NYG + LYO) then
            kcu = CU_Ni
            if (jc.ge.LCYo) kcu = CU_No
         endif
      endif
c
      RETURN
      END
CCC_ & AEPtcu  ## Arpeggio/Dealer/A create CU table primitive
      subroutine AEPtcu
     O    (iErr, jTblCU, LTBL,
     I     MP,
     I     LCXi, LCXo, LCYi, LCYo,
     I     LXB,  LYB,  LXO,  LYO,  NXG, NYG,
     I     MBX,  MBP,  KDLbi,
     I     IR,   NR)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(IN, integer) LTBL
      _INTENT(OUT,integer) jTblCU (LTBL)
      _INTENT(IN, integer) MP
      _INTENT(IN, integer) LCXi, LCXo, LCYi, LCYo
      _INTENT(IN, integer) LXB,  LYB,  LXO,  LYO, NXG, NYG
      _INTENT(IN, integer) MBX,  MBP,  KDLbi
      _INTENT(IN, integer) IR,   NR
      integer kp, kptmp
      integer kcu
CCC_  - Body
      if (LTBL.lt.MP) then
         iErr = -1
      else
         iErr = 0
         do kp = 0, MP - 1
            kptmp = kp
            call AEPpcu
     O          (kcu,
     I           kptmp,
     I           LCXi, LCXo, LCYi,  LCYo,
     I           LXB,  LYB,  LXO,   LYO,  NXG, NYG,
     I           MBX,  MBP,  KDLbi, IR,   NR)
            jTblCU (1 + kp) = kcu
         enddo
      endif
      RETURN
      END
CCC_ & AEPpij/h2d  ## Arpeggio/Dealer/A private to global/logical ij (0)
      subroutine AEPpij
     O    (I0,  J0,
     I     KP,
     I     LXB, LYB, MBX, MBP, IR, NR, KDLbi)
CC horizontal index (start from zero)
      implicit none
      _INTENT(OUT,integer) I0,  J0
      _INTENT(IN, integer) KP
      _INTENT(IN, integer) KDLbi
      _INTENT(IN, integer) LXB, LYB
      _INTENT(IN, integer) MBX, MBP
      _INTENT(IN, integer) IR,  NR
      integer kbg, kbp, iRef, jRef, ic, jc
c
      call AEPpbp (kbp,   KP, LXB, LYB, MBP, KDLbi)
      kbg  = kbp * NR + IR
      jRef =      (kbg / MBX)  * LYB
      iRef = (MOD (kbg,  MBX)) * LXB
      call AEPp2c (ic, jc,   KP, LXB, LYB, MBP, KDLbi)
      I0  = iRef + ic
      J0  = jRef + jc
      RETURN
      END
CCC_ & AEPpbp/h2b  ## Arpeggio/Dealer/A private grid to private block (0)
      subroutine AEPpbp
     O    (KBP,
     I     KP,  LXB, LYB, MBP, KDLbi)
      implicit none
      _INTENT(OUT,integer) KBP
      _INTENT(IN, integer) KP
      _INTENT(IN, integer) LXB, LYB, MBP
      _INTENT(IN, integer) KDLbi
      if (KDLbi.eq.0) then
         KBP  = KP / (LXB * LYB)
      else if (KDLbi.eq.1) then
         KBP  = MOD (KP, (LXB * MBP)) / LXB
      else
         KBP  = -1
      endif
      RETURN
      END
CCC_ & AEPp2c/h2s  ## Arpeggio/Dealer/A private grid to ij inside block (0)
      subroutine AEPp2c
     O    (IC,  JC,
     I     KP,  LXB, LYB, MBP, KDLbi)
      implicit none
      _INTENT(OUT,integer) IC, JC
      _INTENT(IN, integer) KP
      _INTENT(IN, integer) LXB, LYB, MBP, KDLbi
      if (KDLbi.eq.0) then
         IC = MOD (KP, LXB)
         JC = MOD (KP / LXB, LYB)
      else if (KDLbi.eq.1) then
         IC = MOD (KP, LXB)
         JC = KP / (MBP * LXB)
      else
         IC = -1
         JC = -1
      endif
      RETURN
      END
CCC_ & AEPbgg  ## Arpeggio/Dealer/A global block to global grid (0, sw)
      subroutine AEPbgg
     O    (KGsw,
     I     KBG, LXB, LYB, MBX)
      implicit none
      _INTENT(OUT,integer) KGsw
      _INTENT(IN, integer) KBG, LXB, LYB, MBX
      integer ig0, jg0
      ig0  = MOD (KBG,  MBX) * LXB
      jg0  =     (KBG / MBX) * LYB
      KGsw = jg0 * (MBX * LXB) + ig0
      RETURN
      END
CCC_ & AEPp2g  ## Arpeggio/Dealer/A private to global
      subroutine AEPp2g
     O    (KG,
     I     IR, KP, LXB, LYB, MBX, MBP, NR, KDLbi)
      implicit none
      _INTENT(OUT,integer) KG
      _INTENT(IN, integer) IR, KP
      _INTENT(IN, integer) LXB, LYB
      _INTENT(IN, integer) MBX, MBP
      _INTENT(IN, integer) NR
      _INTENT(IN, integer) KDLbi
      integer i0, j0
      integer MX
      call AEPpij
     O    (i0,  j0,
     I     KP,
     I     LXB, LYB, MBX, MBP, IR, NR, KDLbi)
      MX = LXB * MBX
      KG = j0 * MX + i0
      RETURN
      END
CCC_ & AEPg2p  ## Arpeggio/Dealer/A global to private
      subroutine AEPg2p
     O    (IR,  KP,
     I     KG,  LXB, LYB, MBX, MBP, NR, KDLbi)
      implicit none
      _INTENT(OUT,integer) IR, KP
      _INTENT(IN, integer) KG
      _INTENT(IN, integer) LXB, LYB
      _INTENT(IN, integer) MBX, MBP
      _INTENT(IN, integer) NR
      _INTENT(IN, integer) KDLbi
      integer MX
      integer ig0,  jg0,  ic0,  jc0
      integer kbg0, kbp0
c
      MX   = LXB * MBX
      ig0  = MOD (KG,  MX)
      jg0  =      KG / MX
      ic0  = MOD (ig0, LXB)
      jc0  = MOD (jg0, LYB)
      kbg0 = (jg0 / LYB) * MBX + (ig0 / LXB)
      kbp0 = kbg0 / NR
c
      if (kbg0.lt.0) then
         IR = MOD (kbg0 + ((ABS (kbg0) / NR) + 1) * NR, NR)
      else
         IR = MOD (kbg0, NR)
      endif
c
      if      (KDLbi.eq.0) then
         KP = kbp0 * LXB * LYB + jc0  * LXB + ic0
      else if (KDLbi.eq.1) then
         KP = jc0  * MBP * LXB + kbp0 * LXB + ic0
      else
         IR  = -1
         KP = -1
      endif
      RETURN
      END
CCC_ & AEPnhp  ## Arpeggio/Dealer/A NP (effective horizontal private)
      subroutine AEPnhp
     O    (iErr,  NP,    NBP,
     I     IR,    NR,
     I     KDLnb, KDLbi, NXU, NYU, MP, NBG, MBP, MBX, LXB, LYB)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   NP,    NBP
      _INTENT(IN, integer)   IR,    NR
      _INTENT(IN, integer)   KDLnb, KDLbi
      _INTENT(IN, integer)   NXU,   NYU,   MP
      _INTENT(IN, integer)   NBG,   MBP,  MBX
      _INTENT(IN, integer)   LXB,   LYB
      integer KHne, KHsw, KXsw, KYsw
      integer LXYB, NBX
      integer lb,   nhptmp
      integer i0,   j0
CCC_  - Body
      NBX = _NU2NB(+NXU, +LXB)
CCC_   . number of elements required (private)
      NBP = (NBG - 1 - IR) / NR + 1
      if (KDLnb.eq.1) then
         do
            if (MOD ((NBP - 1) * NR + IR, MBX).le.NBX) goto 100
            NBP = NBP - 1
            if (NBP.eq.0) then
               iERR = 2
               goto 100
            endif
         enddo
 100     continue
      endif
CCC_   . NP
      iErr = 0
      LXYB = LXB * LYB
      if (KDLbi.eq.0) then
         KHne  = NBP  * LXYB
         KHsw  = KHne - LXYB
         KXsw  = MOD ((NBP - 1) * NR + IR,   MBX) * LXB
         KYsw  =    (((NBP - 1) * NR + IR) / MBX) * LYB
         if (KDLnb.eq.0) then
            lb   = MIN (NYU - KYsw, LYB) * LXB
         else if (KDLnb.eq.1) then
            lb   = MAX (0, MIN (NYU - KYsw, LYB) - 1) * LXB
     $           + MAX (0, MIN (NXU - KXsw, LXB))
         else
            lb   = 0
         endif
         NP = KHsw + lb
      else if (KDLbi.eq.1) then
         NP = MP
         do
            nhptmp = NP - 1
            call AEPpij
     $           (i0, j0, nhptmp, LXB, LYB, MBX, MBP, IR, NR, KDLbi)
            if ((i0.ge.NXU).or.(j0.ge.NYU)) then
               NP = NP - 1
               if (NP.eq.0) then
                  iErr = -2
                  goto 200
               endif
            else
               goto 200
            endif
         enddo
 200     continue
      else
         NP = MP
      endif
      RETURN
      END
CCC_ & AEPnfp  ## Arpeggio/Dealer/A NP (effective horizontal private use NF)
      subroutine AEPnfp
     O    (iErr,  NP,    NBP,
     I     IR,    NR,
     I     KDLnb, KDLbi, NXD, NYD, MP, NBG, MBP, MBX, LXB, LYB)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   NP,    NBP
      _INTENT(IN, integer)   IR,    NR
      _INTENT(IN, integer)   KDLnb, KDLbi
      _INTENT(IN, integer)   NXD,   NYD,   MP
      _INTENT(IN, integer)   NBG,   MBP,  MBX
      _INTENT(IN, integer)   LXB,   LYB
      integer KHne, KHsw, KXsw, KYsw
      integer LXYB, NBX
      integer lb,   nhptmp
      integer i0,   j0
CCC_  - Body
      NBX = _ND2NB(+NXD, +LXB)
CCC_   . number of elements required (private)
      NBP = (NBG - 1 - IR) / NR + 1
      if (KDLnb.eq.1) then
         do
            if (MOD ((NBP - 1) * NR + IR, MBX).le.NBX) goto 100
            NBP = NBP - 1
            if (NBP.eq.0) then
               iERR = 2
               goto 100
            endif
         enddo
 100     continue
      endif
CCC_   . NP
      iErr = 0
      LXYB = LXB * LYB
      if (KDLbi.eq.0) then
         KHne  = NBP  * LXYB
         KHsw  = KHne - LXYB
         KXsw  = MOD ((NBP - 1) * NR + IR,   MBX) * LXB
         KYsw  =    (((NBP - 1) * NR + IR) / MBX) * LYB
         if (KDLnb.eq.0) then
            lb   = MIN (NYD - KYsw, LYB) * LXB
         else if (KDLnb.eq.1) then
            lb   = MAX (0, MIN (NYD - KYsw, LYB) - 1) * LXB
     $           + MAX (0, MIN (NXD - KXsw, LXB))
         else
            lb   = 0
         endif
         NP = KHsw + lb
      else if (KDLbi.eq.1) then
         NP = MP
         do
            nhptmp = NP - 1
            call AEPpij
     $           (i0, j0, nhptmp, LXB, LYB, MBX, MBP, IR, NR, KDLbi)
c$$$            write (*, *) 'chk np', nhptmp, i0, j0
            if ((i0.ge.NXD).or.(j0.ge.NYD)) then
               NP = NP - 1
               if (NP.eq.0) then
                  iErr = -2
                  goto 200
               endif
            else
               goto 200
            endif
         enddo
 200     continue
      else
         NP = MP
      endif
      RETURN
      END
CCC_* [AET] Attribute Table management
CCC_ & AETrst  ## attribute table reset
      subroutine AETrst
     $     (IE, LIE)
      implicit none
      _INTENT(IN, integer) LIE
      _INTENT(OUT,integer) IE (LIE)
      integer j, jM0
      jM0 = EA_list0(IE)
      do j = 1, jM0 - 1
         IE (j) = 0
      enddo
      do j = jM0, LIE
         IE (j) = -999
      enddo
      EA_VAR(IE) = REVID_EA
      RETURN
      END
CCC_ & AETqnk  ## neighborhood sub-id query
      subroutine AETqnk
     O    (idxN,
     I     CDIR)
      implicit none
      _INTENT(OUT,integer)   idxN
      _INTENT(IN, character) CDIR*(*)
      if      (CDIR.eq.'XP') then
         idxN = 0
      else if (CDIR.eq.'XM') then
         idxN = 1
      else if (CDIR.eq.'YP') then
         idxN = 2
      else if (CDIR.eq.'YM') then
         idxN = 3
      else if (CDIR.eq.'NE') then
         idxN = 4
      else if (CDIR.eq.'NW') then
         idxN = 5
      else if (CDIR.eq.'SE') then
         idxN = 6
      else if (CDIR.eq.'SW') then
         idxN = 7
      else
         idxN = -1
      endif
      RETURN
      END
CCC_ & AETqip  ## periodicity id query
      subroutine AETqip
     O    (idxP,
     I     CDIR, CPFX, Coi)
      implicit none
      _INTENT(OUT,integer)   idxP
      _INTENT(IN, character) CDIR*(*), CPFX*(*), Coi*(*)
      integer jErr
      integer jp0, jp1, jp2, jpr
      jErr = 0
      if (jErr.eq.0) then
         if      (CPFX.eq.'R') then
            jp0 = 0
         else if (CPFX.eq.'S') then
            jp0 = 1
         else if (CPFX.eq.'D') then
            jp0 = 2
         else if (CPFX.eq.'T') then
            jp0 = 3
         else
            jErr = -1
         endif
      endif
      if (jErr.eq.0) then
         if      (CDIR.eq.'W') then
            jpr = EA_IRWCo()
            jp1 = 0
         else if (CDIR.eq.'E') then
            jpr = EA_IRWCo()
            jp1 = 1
         else if (CDIR.eq.'S') then
            jpr = EA_IRSCo()
            jp1 = 0
         else if (CDIR.eq.'N') then
            jpr = EA_IRSCo()
            jp1 = 1
         else
            jErr = -1
         endif
      endif
      if (jErr.eq.0) then
         if      (Coi.eq.'o') then
            jp2 = jp1
         else if (Coi.eq.'i') then
            jp2 = 1 - jp1
         else
            jErr = -1
         endif
      endif
      if (jErr.eq.0) then
         idxP = jpr + 4 * jp0 + 2 * jp1 + jp2
      else
         idxP = -1
      endif
      RETURN
      END
CCC_ & AETtba  ## Table attributes output using DVT
      subroutine AETtba
     O    (iErr,
     I     IE, IFPv, KSW)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   IE (*)
      _INTENT(IN, integer)   KSW
      _INTENT(IN, integer)   IFPv
      if (KSW.gt.0) then
         call DVTwti (iErr, 'KDL',    EA_argKDL(IE), ' ', IFPv)
         call DVTwti (iErr, 'NXG',    EA_argNXG(IE), ' ', IFPv)
         call DVTwti (iErr, 'NYG',    EA_argNYG(IE), ' ', IFPv)
         call DVTwti (iErr, 'LXO',    EA_argLXO(IE), ' ', IFPv)
         call DVTwti (iErr, 'LYO',    EA_argLYO(IE), ' ', IFPv)
         call DVTwti (iErr, 'LXB',    EA_argLXB(IE), ' ', IFPv)
         call DVTwti (iErr, 'LYB',    EA_argLYB(IE), ' ', IFPv)
         call DVTwti (iErr, 'LXW',    EA_argLXW(IE), ' ', IFPv)
         call DVTwti (iErr, 'LYW',    EA_argLYW(IE), ' ', IFPv)
         call DVTwti (iErr, 'ISH',    EA_argISH(IE), ' ', IFPv)
      endif
      call DVTwti (iErr, 'IR',     EA_argIR(IE),  ' ', IFPv)
      call DVTwti (iErr, 'NR',     EA_argNR(IE),  ' ', IFPv)
      RETURN
      END
CCC_& AEDLRA  ## IcIES/Arpeggio/Elements dealer announcement
      subroutine AEDLRA (STRA, STRB, IOP)
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
         STRB =' '
      else
         STRA = ' '
         STRB = ' '
      endif
      RETURN
      END
CCC_* [Test]
#if TEST_AEDLRA
#ifndef   TEST_AEDLRA_CFG
#  define TEST_AEDLRA_CFG 1
#endif
CCC_ @ AETEST  ## Arpeggio/Dealer test
      program AETEST
CCC_  - Test suites
CC::   KINDS 1 2 3
CCC_  - Declaration
      implicit none
#if   TEST_AEDLRA == 1
      call AETESTmain
#elif TEST_AEDLRA == 2
      call AETESTstnsl
#elif TEST_AEDLRA == 3
      call AETESTstnslOVW
#endif
      STOP
      END
CCC_ & AETESTmain   ## test main part (IE)
#if   TEST_AEDLRA == 1
      subroutine AETESTmain
      implicit none
CCC_  = Interior
      integer    iErr
      integer    LIE
      parameter (LIE = 1048576)
      integer    IE  (LIE)
      data       IE  /LIE * -999/
      integer    IR,   NR,  jr0, jr9
      character  CROOT * (32)
c
      integer IFPi, IFPn, IFPl
CCC_  - Body
      IFPi = -1
      IFPn = -1
      IFPl = -1
c
      IR    = -1
      NR    = -1
      CROOT = 'ID'
      call AETESTcfg (iErr, IE, LIE, IR, NR, CROOT, IFPi, IFPn, IFPl)
c
      NR  = EA_argNR(IE)
      IR  = EA_argIR(IE)
c
      if (IR.ge.0) then
         jr0 = IR
         jr9 = IR
      else
         jr0 = 0
         jr9 = MAX (1, NR) - 1
      endif
c
      DO IR = jr0, jr9
 101     format ('## ', 2I4)
         write (*, 101) IR, NR
         EA_argIR(IE) = IR
         call AEAgen (iErr, IE, LIE, CROOT, IFPl)
         write (*, *) 'ERR IE = ', iERR
      ENDDO
c
      RETURN
      END
#endif /* TEST_AEDLRA == 1 */
CCC_ & AETESTstnsl  ## test main part (stencil)
#if   TEST_AEDLRA == 2
      subroutine AETESTstnsl
CCC_  - Declaration
      implicit none
      integer    LIE
      parameter (LIE = 16384)
      integer    iErr
      integer    IE  (LIE)
c
      integer    LXB,  LYB
      integer    IR,   NR
      character  CROOT * (32)
      integer    lt
      integer    kStncl (15)
      integer    MP, LHP, MBP, MO, LHG
      integer    LTBL
      parameter (LTBL = LIE)
      integer    kDSP (LTBL), kTYP (LTBL), kABL (LTBL)
      integer    KDTA (LTBL, 3)
      integer    kWS,  kWW,  kWE,  kWN
      integer    KS
      _REALSTD   V0 (LIE), V1 (LIE), VW (LIE * 128)
      integer    jv, jo, ij
      integer    jy, jx, kbmx
#include "ofnstd.h"
#include "odevid.h"  /* MPI table */
      integer ipA (LOG_CHANNEL_MAX)
      integer iMA (MAX_MPI_ATTR)
      integer ipL, ipC, ipP
      integer MX, MY, MG
c
      integer    LNR
      parameter (LNR = 256)
      integer    KSglb (LNR * 2)
c
      character CclrC*(16)
      integer IRfrm, IRto, KSfrm, KSto
CCC_  - Body
      iErr = 0
c
      MBP  = 0
      LXB  = 0
      LYB  = 0
c
      call DDcapo
     O    (iErr,
     I     2, ' ', 'O', _FNAME, TEST_AEDLRA)
c
      if (iErr.eq.0) then
         call DLCmng (ipA, 't')
         call DMArst (iMA)
         call DMAtop (iMA, CclrC)
c
         ipL = FPL(ipA)
         ipC = FPC(ipA)
         ipP = FPP(ipA)
c
         CROOT = 'ID'
c
         call DMAget (IR,    ima, 'IR')
         call DMAget (NR,    ima, 'NR')
         call AETESTcfg
     O       (iErr,
     O        IE,
     I        LIE, IR, NR, CROOT, ipP, ipC, ipL)
c
      endif
c
      if (iErr.eq.0) then
         call AEAgen (iErr, IE, LIE, CROOT, ipL)
c
         MP  = EA_MP(IE)
         MBP = EA_MBP(IE)
         LXB = EA_LXB(IE)
         LYB = EA_LYB(IE)
         LHP = MP + 3
         MG  = EA_MG(IE)
         LHG = MG + 1
      endif
CCC_   . moat-type stencil generation
      do lt = 1, 15
         KWS = MOD (lt, 2)
         KWW = MOD (lt / 2, 2)
         KWE = MOD (lt / 4, 2)
         KWN = MOD (lt / 8, 2)
         if (iErr.eq.0) then
            call AEScmt
     O          (iErr, KS,
     O           kDTA, LTBL,
     I           kWS,  kWW,  kWE,  kWN,
     I           LHP,  IE,   ipL)
            kStncl (lt) = KS
         endif
      enddo
c
      MO = 3
      do jo = 0, MO - 1
         do jv =0, MP - 1
            ij = jo * LHP + jv + 1
            V0 (ij) = DBLE (EA_listLW(IE,jv) + jo * 1000)
         enddo
      enddo
      kbmx = LXB * MBP
 501  format ('V0 ', I2.2,I2.2, ': ', 121F5.0)
      do jo = MO - 1, 0, -1
         do jy = LYB, 1, -1
            ij = jo * LHP + (jy - 1) * kbmx
            write (ipL, 501) jo, jy, (V0 (ij + jx), jx = 1, kbmx)
         enddo
      enddo
c
 503  format ('V1 ', I2.2,I2.2, I2.2, ': ', 121F5.0)
      do lt = 1, 15
         KSfrm = kStncl (lt)
         KSto  = kStncl (lt)
         IRfrm = 0
         IRto  = 1
         call DMDpsr
     O       (iErr, V1,
     I        V0,
     I        IRfrm, IRto, MP, KSfrm, KSto, MO, iMA)
         if (IR.eq.IRto) then
            do jo = MO - 1, 0, -1
               do jy = LYB, 1, -1
                  ij = jo * LHP + (jy - 1) * kbmx
                  write (ipL, 503)
     $                 lt, jo, jy, (V1 (ij + jx), jx = 1, kbmx)
               enddo
            enddo
         endif
      enddo
CCC_   . global/private stencil generation
      if (iErr.eq.0) then
         call AESglb
     O       (iErr,
     O        KSglb,
     W        kDTA,
     I        LNR,    LTBL,  LHP,   LHG, IE, ipL)
      endif
      if (iErr.eq.0) then
         call AEGcls
     O       (iErr,  VW,
     I        V0,    LHP,   LHG, MO,
     I        0,     KSglb, IE,  iMA)
      endif
 509  format ('VW ', I2.2, I2.2, ': ', 121F5.0)
      if (IR.eq.0) then
         MX = EA_MX(IE)
         MY = EA_MY(IE)
         do jo = MO - 1, 0, -1
            do jy = MY, 1, -1
               ij = jo * LHG + (jy - 1) * MX
               write (ipL, 509)
     $              jo, jy, (VW (ij + jx), jx = 1, MX)
            enddo
         enddo
      endif
      call DevFin (iErr)
      RETURN
      END
#endif /* TEST_AEDLRA == 2 */
CCC_ & AETESTstnslOVW  ## test main part (stencil/ovw)
#if   TEST_AEDLRA == 3
      subroutine AETESTstnslOVW
CCC_  - Declaration
      implicit none
      integer    LIE
      parameter (LIE = 16384)
      integer    iErr
      integer    IE  (LIE)
c
      integer    LXB,  LYB
      integer    IR,   NR,  iComm
      character  CROOT * (32)
      integer    MaxStn
      parameter (MaxStn = 8)
      integer    kStncS (MaxStn, 2), kStncD (MaxStn, 2)
      integer    IRSov  (MaxStn, 2), IRDov  (MaxStn, 2)
      integer    kwStnS (MaxStn, 2), kwStnD (MaxStn, 2)
      integer    IRwsS  (MaxStn, 2), IRwsD  (MaxStn, 2)
      integer    nOVW (2)
      integer    MP, LHP, MBP, MO, kcu
      integer    LTBL
      parameter (LTBL = LIE)
      integer    kDSP (LTBL), kTYP (LTBL), kABL (LTBL)
      integer    KSS,  KSD
      _REALSTD   V0 (LIE), V1 (LIE)
      integer    KWI (LIE)
      integer    jv, jo, ij
      integer    jy, jx, kbmx
#include "ofnstd.h"
#include "odevid.h"  /* MPI table */
      integer ipA (LOG_CHANNEL_MAX)
      integer iMA (MAX_MPI_ATTR)
      integer   ipL, ipC, ipP
      integer jst
      integer NV, IRS, IRD
      character CclrC*(16)
c
      integer KSW
CCC_  - Body
      iErr = 0
      MP   = 0
      MBP  = 0
      LXB  = 0
      LYB  = 0
c
      call DDcapo
     O    (iErr,
     I     2, ' ', 'O', _FNAME, TEST_AEDLRA)
c
      if (iErr.eq.0) then
         call DLCmng (ipA, 't')
         call DMArst (iMA)
         call DMAtop (iMA, CclrC)
c
         ipL = FPL(ipA)
         ipC = FPC(ipA)
         ipP = FPP(ipA)
c
         CROOT = 'ID'
c
         call DMAget (IR,    ima, 'IR')
         call DMAget (NR,    ima, 'NR')
         call DMAget (Icomm, ima, 'CO')
         call AETESTcfg
     O       (iErr,
     O        IE,
     I        LIE, IR, NR, CROOT, ipP, ipC, ipL)
      endif
c
      if (iErr.eq.0) then
         call AEAgen (iErr, IE, LIE, CROOT, ipL)
         MP  = EA_MP(IE)
         MBP = EA_MBP(IE)
         LXB = EA_LXB(IE)
         LYB = EA_LYB(IE)
         LHP = MP + 3
         if (LHP.gt.LIE) iErr = -9
      endif
CCC_   . set original data
      MO = 3
      do jo = 0, MO - 1
         do jv =0, MP - 1
            ij = jo * LHP + jv + 1
            V0 (ij) =
     $           DBLE (EA_listLY(IE,jv) * 100
     $                + EA_listLX(IE,jv) + jo * 10000)
         enddo
      enddo
      kbmx = LXB * MBP
 501  format ('V0 ', I2.2,I2.2, ': ', 12(10F6.0,':'))
      do jo = MO - 1, 0, -1
         do jy = LYB, 1, -1
            ij = jo * LHP + (jy - 1) * kbmx
            write (ipL, 501) jo, jy, (V0 (ij + jx), jx = 1, kbmx)
         enddo
      enddo
CCC_   . overlap/group
      if (iErr.eq.0) then
         call AESovg
     O       (iErr,
     W        kDSP,   kTYP,   kABL,   KWI,
     O        nOVW(1),kStncS(1,1), kStncD(1,1), IRSov(1,1), IRDov(1,1),
     I        MaxStn, LTBL,   LHP,    IE,     .false., ipL)
      endif
      if (iErr.eq.0) then
         call AESovg
     O       (iErr,
     W        kDSP,   kTYP,   kABL,   KWI,
     O        nOVW(2),kStncS(1,2), kStncD(1,2), IRSov(1,2), IRDov(1,2),
     I        MaxStn, LTBL,   LHP,    IE,     .true., ipL)
      endif
 503  format ('V',I1,1x, I2.2,I2.2,1x, I2.2,I2.2, ': ', 12(10F6.0,':'))
      do KSW = 1, 2
         NV = MO * LHP
         V1 = -1.0d0
         do jst = 1, nOVW (KSW)
            KSS = kStncS (jst, KSW)
            KSD = kStncD (jst, KSW)
            IRS = IRSov  (jst, KSW)
            IRD = IRDov  (jst, KSW)
            if (iErr.eq.0) then
               call DMDcsr
     O             (iErr,   V1,
     I              V0,
     I              IRS,    IRD, NV, KSS, KSD, MO, iMA)
            endif
            do jo = MO - 1, 0, -1
               do jy = LYB, 1, -1
                  ij = jo * LHP + (jy - 1) * kbmx
                  write (ipL, 503)
     $                 KSW, IRS,IR, jo,jy, (V1 (ij + jx), jx = 1, kbmx)
               enddo
            enddo
         enddo
      enddo
CCC_   . overlap/single
      if (iErr.eq.0) then
         call AESowg
     O       (iErr,
     W        kDSP,   kTYP,   kABL,  KWI,
     O        kwStnS(1,1), kwStnD(1,1), IRwsS(1,1), IRwsD(1,1),
     I        MaxStn, LTBL,   LHP,   IE,  .false., ipL)
      endif
      if (iErr.eq.0) then
         call AESowg
     O       (iErr,
     W        kDSP,   kTYP,   kABL,  KWI,
     O        kwStnS(1,2), kwStnD(1,2), IRwsS(1,2), IRwsD(1,2),
     I        MaxStn, LTBL,   LHP,   IE,  .true., ipL)
      endif
CCC_   . overlap check
 509  format ('V0M ', I2.2,1x,I2.2,1x, I2.2,I2.2,': ', 12(10F6.0,':'))
      do KSW = 1, 1
         do kcu = 1, 8
            KSS = kwStnS (kcu, KSW)
            KSD = kwStnD (kcu, KSW)
            IRS = IRwsS  (kcu, KSW)
            IRD = IRwsD  (kcu, KSW)
            call DMDmrs
     O          (iErr,
     M           V0,
     I           IRS, IRD, NV, KSS, KSD, MO, iMA)
         enddo
         do jo = MO - 1, 0, -1
            do jy = LYB, 1, -1
               ij = jo * LHP + (jy - 1) * kbmx
               write (ipL, 509)
     $              KSW, IR, jo,jy, (V0 (ij + jx), jx = 1, kbmx)
            enddo
         enddo
      enddo
c
      call DevFin (iErr)
      RETURN
      END
#endif /* TEST_AEDLRA == 3 */
#endif /* TEST_AEDLRA */
#if TEST_AEDLRA_CFG == 1
CCC_ & AETESTcfg   ## test configuration
      subroutine AETESTcfg
     O    (iErr,
     O     IE,
     I     LIE, IR, NR, CROOT, IFPi, IFPn, IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   IE (*)
      _INTENT(IN, integer)   LIE
      _INTENT(IN, integer)   IR, NR
      _INTENT(IN, character) CROOT*(*)
      _INTENT(IN, integer)   IFPi, IFPn, IFPl
c
      integer    NXG,  NYG,    LXB,  LYB
      integer    LXW,  LYW,    LXO,  LYO
      integer    ISH,  KDL
      integer    LVDBG
CCC_   . set default
      KDL = 3
      NXG = 11
      NYG = 11
      LXO = 0
      LYO = 0
      LXB = 1
      LYB = 1
      LXW = 0
      LYW = 0
      ISH = 1
      LVDBG = 999
c
      call AEAnsa
     O    (iErr,
     O     IE,
     I     LIE,
     I     NXG,  NYG, LXB, LYB, LXW, LYW, LXO, LYO,
     I     IR,   NR,  ISH, KDL,
     I     CROOT,
     I     LVDBG, IFPi, IFPn, IFPl)
c
      RETURN
      END
#endif /* TEST_AEDLRA_CFG */
CCC_* Obsolete implementation
CCC_ + begin
#if 0
CCC_ + end obsolete
#endif /* 0 */
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
