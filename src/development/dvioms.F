C development/dvioms.F --- IcIES/Development/variable i/o manager
C Maintainer:  SAITO Fuyuki
C Created: Jan 14 2012
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2018/11/13 13:01:59 fuyuki dvioms.F>'
#define _FNAME 'development/dvioms.F'
#define _REV   'Snoopy0.9'
CCC_! MANIFESTO
C
C Copyright (C) 2012--2020
C           Japan Agency for Marine-Earth Science and Technology,
C           Ayako ABE-OUCHI
C
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
CCC_* Macros
#include "ofdlct.h" /* fortran dialect */
#include "ologfm.h" /* logging */
#include "ofnstd.h"
#include "odevel.h"
#include "odevva.h"
#include "ounelv.h" /* namelist emulation levels */
#ifndef    OPT_NAMELIST_OUTPUT_EMULATION
#  define  OPT_NAMELIST_OUTPUT_EMULATION _UNMLEM_LEVEL_ENTRY
#endif
#ifndef    OPT_NAMELIST_OUTPUT_EMULATION_DVT
#  define  OPT_NAMELIST_OUTPUT_EMULATION_DVT _UNMLEM_LEVEL_END
#endif
#ifndef    OPT_NAMELIST_OUTPUT_EMULATION_DVG
#  define  OPT_NAMELIST_OUTPUT_EMULATION_DVG _UNMLEM_LEVEL_END
#endif
CCC_ + attribute cluster for log
#define DLC_NV    1
#define DLC_LB    2
#define DLC_IRX   3
#define DLC_ILX   4
#define DLC_MREC  5
#define DLC_MLOG  6
#define DLC_IR    7

#define DLC_LIM  7

#if TEST_DVIOMS
#  define OPT_DVIO_GATHER_MOD 2
#endif
#ifndef   OPT_DVIO_GATHER_MOD
#  define OPT_DVIO_GATHER_MOD 16
#endif
CCC_* [DVH] Helper
CCC_ & DVHriS  ## Helper: one-time read (id set) [S]
      subroutine DVHriS
     O    (iErr,
     M     kaDV,  saDV,
     O     SV,    N,
     I     PDP,   KUFMT, FMT, TXT, IFP, IFPv)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   N
      _INTENT(OUT,  _REALSTD)  SV (N)
      _INTENT(INOUT,character) saDV*(*)
      _INTENT(INOUT,integer)   kaDV (*)
      _INTENT(IN,   integer)   KUFMT
      _INTENT(IN,   character) PDP*(*), FMT*(*)
      _INTENT(IN,   character) TXT*(*)
      _INTENT(IN,   integer)   IFP, IFPv
c
      character PDPi
      integer   IRT, IRN
      integer   jErr
CCC_  - Body
      iErr  = 0
      call USMcpd (PDPi, PDP, 'R')
      call DVFppp (kaDV, PDPi)
      if (iErr.eq.0) call DVFxch (iErr, kaDV, saDV)
      if (iErr.eq.0) then
         IRT = kaDV (VIO_RECI)
         call DVSrdS
     O       (iErr,
     O        SV,   IRN,
     M        kaDV, saDV,
     I        IRT,  N,  KUFMT,  FMT, TXT)
      endif
c
      call DVFrep (jErr, kaDV, saDV, IFP, IFPv)
c
      RETURN
      END
CCC_ & DVHriI  ## Helper: one-time read (id set) [I]
      subroutine DVHriI
     O    (iErr,
     M     kaDV,  saDV,
     O     IV,    N,
     I     PDP,   KUFMT, FMT, TXT, IFP, IFPv)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   N
      _INTENT(OUT,  integer)   IV (N)
      _INTENT(INOUT,character) saDV*(*)
      _INTENT(INOUT,integer)   kaDV (*)
      _INTENT(IN,   integer)   KUFMT
      _INTENT(IN,   character) PDP*(*), FMT*(*)
      _INTENT(IN,   character) TXT*(*)
      _INTENT(IN,   integer)   IFP, IFPv
c
      character PDPi
      integer   IRT, IRN
      integer   jErr
CCC_  - Body
      iErr  = 0
      call USMcpd (PDPi, PDP, 'R')
      call DVFppp (kaDV, PDPi)
      if (iErr.eq.0) call DVFxch (iErr, kaDV, saDV)
      if (iErr.eq.0) then
         IRT = kaDV (VIO_RECI)
         call DVSrdI
     O       (iErr,
     O        IV,   IRN,
     M        kaDV, saDV,
     I        IRT,  N,  KUFMT,  FMT, TXT)
      endif
c
      call DVFrep (jErr, kaDV, saDV, IFP, IFPv)
c
      RETURN
      END
CCC_* [DVS] Suite
CCC_ & DVSbng  ## Suite:  Access binder (group common)
      subroutine DVSbng
     O    (iErr,
     O     CTYP,  KUFMT, FMT,
     I     SW,
     I     ipI,   ipO,   ipE)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(OUT,  integer)   KUFMT
      _INTENT(OUT,  character) CTYP*(*), FMT*(*)
      _INTENT(IN,   integer)   ipI, ipO, ipE
      _INTENT(IN,   character) SW*(*)
      character  SysTag*(4)
      integer    IOSR
      character  TSW*(16)
CCC_  - Body
      iErr  = 0
      TSW   = SW
      if (TSW.eq.' ') TSW = 'E'
c
      if (iErr.eq.0) then
         call DVLrnc
     O       (iErr,
     O        IOSR,
     O        SysTag, CTYP, KUFMT, FMT,
     I        TSW,    ipI)
      endif
CCC_  - check
      if (iErr.eq.0) then
         IOSR   = 0
         SysTag = 'R'
         call DVLwnc
     O       (iErr,
     I        IOSR,
     I        SysTag, CTYP, KUFMT, FMT,
     I        TSW,    ipO)
      endif
      call DAtrcU (ipE, iErr, 'R', 'DVSBNG')
      RETURN
      END
CCC_ & DVSbnr  ## Suite:  Access binder (single rank)
      subroutine DVSbnr
     O    (iErr,
     M     kaDV,  saDV,  NV,
     I     DPFX,  FMT,   ipI,   ipO,   ipE)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(OUT,  integer)   NV
      _INTENT(INOUT,integer)   kaDV  (*)
      _INTENT(INOUT,character) saDV *(*)
      _INTENT(IN,   character) FMT  *(*)
      _INTENT(IN,   character) DPFX *(*)
      _INTENT(IN,   integer)   ipI, ipO, ipE
      integer    LB, IR
CCC_  - Body
      iErr  = 0
c
      call DVFati (iErr, kaDV,  saDV, -1, ' ')
c
      if (iErr.eq.0) then
         call DVLrdx
     O       (iErr,
     O        NV,   LB,   kaDV, saDV,  IR,
     I        DPFX, ipI)
      endif
      if (iErr.eq.0) then
         kaDV (VIO_UNIT)    = -2
         kaDV (VIO_RBYT)    = LB
         kaDV (VIO_CINT)    = -1
         kaDV (VIO_CSTP)    = -1
CC       POLICY:EEC == always raise error
         call DVFl2p (kaDV, FMT)
         kaDV (VIO_PLCX)    = VIO_POLICY_X_ERR
         kaDV (VIO_PLCN)    = VIO_POLICY_N_ERR
         kaDV (VIO_PLCU)    = VIO_POLICY_U_COMMON
         kaDV (VIO_ULOG)    = ipE
         kaDV (VIO_UNRP)    = ipO
c$$$         kaDV (VIO_ULOG)    = -1
c$$$         kaDV (VIO_UNRP)    = -1
         call DVFbrl (kaDV, FMT, VIO_FILENAME(saDV))
      endif
      call DAtrcU (ipE, iErr, 'R', 'DVSBNR')
      RETURN
      END
CCC_ & DVSbnd  ## Suite:  Access binder
      subroutine DVSbnd
     O    (iErr,
     M     kaDV,  saDV,
     O     CTYP,  KUFMT, FMT,   NV,
     I     IRT,   SW,
     I     ipI,   ipO,   ipE)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,integer)   kaDV  (*)
      _INTENT(INOUT,character) saDV *(*)
      _INTENT(OUT,  integer)   NV,       KUFMT
      _INTENT(OUT,  character) CTYP*(*), FMT*(*)
      _INTENT(IN,   integer)   IRT
      _INTENT(IN,   integer)   ipI, ipO, ipE
      _INTENT(IN,   character) SW*(*)
c
      integer   LB
      integer   IRX, ILX, MREC, MLOG
      character FNM*(OPT_FILENAME_MAX)
CCC_  - Body
      iErr = 0
      saDV = ' '
      call DVSgra
     O    (iErr,
     O     CTYP,   KUFMT,  FMT,
     I     NV,     LB,     IRX,   ILX,   MREC, MLOG, FNM,
     I     IRT,    SW,
     I     ipI,    ipO,    ipE)
      if (iErr.eq.0) then
         kaDV (VIO_LOGI)    = ILX
         kaDV (VIO_RECI)    = IRX
         kaDV (VIO_RECC)    = MREC
         kaDV (VIO_LOGC)    = MLOG
         VIO_FILENAME(saDV) = FNM
c
         kaDV (VIO_UNIT)    = -2
         kaDV (VIO_RBYT)    = LB
         kaDV (VIO_CINT)    = -1
         kaDV (VIO_CSTP)    = -1
CC       POLICY:EEC == always raise error
         call DVFl2p (kaDV, FMT)
         kaDV (VIO_PLCX)    = VIO_POLICY_X_ERR
         kaDV (VIO_PLCN)    = VIO_POLICY_N_ERR
         kaDV (VIO_PLCU)    = VIO_POLICY_U_COMMON
         kaDV (VIO_ULOG)    = ipE
         kaDV (VIO_UNRP)    = ipO
c$$$         kaDV (VIO_ULOG)    = -1
c$$$         kaDV (VIO_UNRP)    = -1
         call DVFbrl (kaDV, FMT, FNM)
      endif
c
      call DAtrcU (ipE, iErr, 'R', 'DVSBND')
      RETURN
      END
CCC_ & DVSgra  ## Suite: get access (by record number)
      subroutine DVSgra
     O    (iErr,
     O     CTYPo,  KUFMTo, FMTo,
     O     NVo,    LBo,    IRXo,  ILXo,  MRECo, MLOGo, FNMo,
     I     IRT,    SW,
     I     ipI,    ipO,    ipE)
CCC_  - Declaration
      implicit none
c
      _INTENT(OUT,  integer)   iErr
      _INTENT(OUT,  integer)   NVo,       KUFMTo
      _INTENT(OUT,  character) CTYPo*(*), FMTo*(*)
      _INTENT(OUT,  character) FNMo *(*)
      _INTENT(OUT,  integer)   LBo,  IRXo, ILXo, MRECo, MLOGo
      _INTENT(IN,   integer)   IRT
      _INTENT(IN,   integer)   ipI, ipO, ipE
      _INTENT(IN,   character) SW*(*)
c
      character  SysTag*(4)
      integer    IOSR
      character  TSW*(16)
c
      integer    IOS
      logical    OFOUND, OEOF
CCC_  - Body
CC    IRT is reserved for future, to skip configuration in the loop
CC       Dummy statements
      iErr = 0 * IRT
c
      OFOUND = .false.
      IOS    = 0
      TSW    = SW
      if (TSW.eq.' ') TSW = 'E'
CCC_   . read next namelist
      if (IOS.eq.0) then
         call DVArnm
     O       (IOS,
     O        IOSR,
     O        SysTag, CTYPo, KUFMTo, FMTo,
     O        NVo,    LBo,   IRXo,   ILXo,  MRECo, MLOGo, FNMo,
     I        TSW,    ipI)
      endif
      if (IOS.eq.0) then
         OFOUND = .true.
      else
         OFOUND = .false.
      endif
CCC_   . when found
      call DAtrcU (ipE, IOS, 'A', 'DVSGRA')
      if (OFOUND) then
         iErr = 0
CCC_    * report
         IOSR   = IOS
         SysTag = 'R'
         call DVAwnm
     O       (IOS,
     I        IOSR,
     I        SysTag, CTYPo, KUFMTo, FMTo,
     I        NVo,    LBo,   IRXo,   ILXo,  MRECo, MLOGo, FNMo,
     I        TSW,    ipO)
      else
         call UUieof (OEOF, IOS)
         if (OEOF) then
            iErr = 1
         else
            iErr = -1
         endif
      endif
      call DAtrcU (ipE, iErr, 'R', 'DVSGRA')
      RETURN
      END
CCC_ & DVSwoS  ## one-time write/S [base:DVHwoS]
      subroutine DVSwoS
     O    (iErr,
     I     SV,    N,
     I     PDP,   FNM, TXT, IFP, IFPv, iMA)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   N
      _INTENT(IN, _REALSTD)  SV (N)
      _INTENT(IN, character) PDP*(*)
      _INTENT(IN, character) FNM*(*)
      _INTENT(IN, character) TXT*(*)
      _INTENT(IN, integer)   IFP, IFPv, iMA (*)
c
      integer   kaDV (VIO_KPOLICY_MAX)
      character saDV*(VIO_SPOLICY_LEN)
      character FMT, PDPi
c
      integer   IRT, IRN, KU
CCC_  - Body
      iErr  = 0
c
      call USMcpd (PDPi, PDP, 'W')
      call DVSudw
     O    (iErr,
     O     kaDV,  saDV,
     I     PDPi,  'S',   N,    FNM, IFP, IFPv, iMA)
c
      FMT   = ' '
      if (iErr.eq.0) then
         IRT = 0
         KU  = 0
         call DVSwtS
     O       (iErr,
     O        IRN,
     M        kaDV, saDV,
     I        IRT,  SV,   N,  KU,  FMT, TXT)
      endif
      RETURN
      END
CCC_ & DVSwoI  ## one-time write/I [base:DVHwoI]
      subroutine DVSwoI
     O    (iErr,
     I     IV,    N,
     I     PDP,   FNM, TXT, IFP, IFPv, iMA)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   N
      _INTENT(IN, integer)   IV (N)
      _INTENT(IN, character) PDP*(*)
      _INTENT(IN, character) FNM*(*)
      _INTENT(IN, character) TXT*(*)
      _INTENT(IN, integer)   IFP, IFPv, iMA (*)
c
      integer   kaDV (VIO_KPOLICY_MAX)
      character saDV*(VIO_SPOLICY_LEN)
      character FMT, PDPi
c
      integer   IRT, IRN, KU
CCC_  - Body
      iErr  = 0
c
      call USMcpd (PDPi, PDP, 'W')
      call DVSudw
     O    (iErr,
     O     kaDV,  saDV,
     I     PDPi,  'I',   N,    FNM, IFP, IFPv, iMA)
c
      FMT   = ' '
      if (iErr.eq.0) then
         IRT = 0
         KU  = 0
         call DVSwtI
     O       (iErr,
     O        IRN,
     M        kaDV, saDV,
     I        IRT,  IV,   N,  KU,  FMT, TXT)
      endif
      RETURN
      END
CCC_ & DVSudw  ## Suite: check-in (unformatted/direct/write) [base:DVHudw]
      subroutine DVSudw
     O    (iErr,
     O     kaDV,  saDV,
     I     PDP,   CTYP,  N,    FNM,
     I     IFP,   IFPv,  iMA)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   kaDV  (*)
      _INTENT(OUT,character) saDV *(*)
      _INTENT(IN, character) PDP  *(*), CTYP*(*)
      _INTENT(IN, integer)   N
      _INTENT(IN, character) FNM*(*)
      _INTENT(IN, integer)   IFP, IFPv, iMA (*)
c
      integer   LB
      character FMT, CPLCY
CCC_  - Body
      iErr  = 0
      LB    = 0
      FMT   = ' '
      CPLCY = ' '
      if (iErr.eq.0) call DVFltp (LB, N, CTYP)
      if (iErr.eq.0) then
         call DVSchk
     O       (iErr, kaDV,  saDV,
     I        LB,   FMT,   PDP,  CPLCY, FNM,
     I        IFP,  IFPv,  iMA)
      endif
      call DAtrcU (IFP, iErr, FNM, 'DVSUDW')
      RETURN
      END
CCC_ & DVSchk  ## Suite: check-in
      subroutine DVSchk
     O    (iErr,
     O     kaDV,  saDV,
     I     LB,    FMT,   PDP, CPLCY, FNM,
     I     IFP,   IFPv,  iMA)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   kaDV  (*)
      _INTENT(OUT,character) saDV *(*)
      _INTENT(IN, integer)   LB
      _INTENT(IN, character) FMT*(*),   PDP*(*), CPLCY*(*)
      _INTENT(IN, character) FNM*(*)
      _INTENT(IN, integer)   IFP, IFPv, iMA (*)
      character BF*(OPT_FILENAME_MAX)
      integer   impi
CCC_  - Body
      iErr = 0
      saDV = ' '
CCC_   . attributes set
      if (iErr.eq.0) then
         call DVFset
     O       (iErr,
     O        kaDV,  saDV,
     I        PDP,   LB,   FMT,   CPLCY,
     I        FNM,   IFP,  IFPv,  iMA)
      endif
CCC_   . warning
      if (iErr.gt.0) then
 201     format ('DVSCHK WARNING:', I4, 1x, A)
         if (COND_N(IFP)) then
            write (IFP, 201) iErr, _TRIM(FNM)
         else
            write (*,   201) iErr, _TRIM(FNM)
         endif
         iErr = 0
      endif
CCC_   . report
      if (iErr.eq.0) call DVFrep (iErr, kaDV, saDV, IFP, IFPv)
c
      impi = kaDV (VIO_IMPI)
      if (impi.eq.0) then
         if (kaDV (VIO_NRLG).lt.0) then
            call UUqrsu ('DVI', IFPv, -1, BF)
            kaDV (VIO_NRLG) = 0
         endif
      endif
c
      call DAtrcU (IFP, iErr, 'R', 'DVSCHK')
c
      RETURN
      END
CCC_ & DVSrpa  ## Suite: access report
      subroutine DVSrpa
     I    (iErr,
     I     kaDV, saDV,
     I     SysTag,
     I     CTYP, KUFMT, FMT, NV, LB, IRN, IRX, MREC, MLOG, TXTi)
CCC_  - Declaration
      implicit none
      _INTENT(IN,integer)   iErr
      _INTENT(IN,integer)   kaDV (*)
      _INTENT(IN,character) saDV*(*)
      _INTENT(IN,integer)   IRN
      _INTENT(IN,integer)   NV,   LB,   KUFMT
      _INTENT(IN,integer)   IRX,  MREC, MLOG
      _INTENT(IN,character) SysTag *(*), CTYP*(*), FMT*(*)
      _INTENT(IN,character) TXTi *(*)
CCC_   . Note
CC     If the last access succeed, then IRX, MREC, MLOG are the same
CC     as those stored in kaDV, but these variables are to be outputed
CC     instead for some error cases.  On the other hand DVSwmv uses
CC     kaDV attributes only.
c
      character  FNM *(OPT_FILENAME_MAX)
      character  TXT *(32)
      integer    IFP,  IFPv
      integer    ILX
      integer    jeDmy
c
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
CCC_  - Body
      IFP    = kaDV (VIO_ULOG)
      IFPv   = kaDV (VIO_UNRP)
      ILX    = kaDV (VIO_LOGI)
      FNM    = VIO_FILENAME(saDV)
c
      TXT = TXTi
      if (TXT.eq.' ') TXT = '-'
c
 101  format ('DVSRPA ', A, 1x,
     $     I4, 1x, A2, 1x, 2I8, 1x, 3I8, 1x, 2I8, 1x, A)
      if (COND_N(IFP)) then
         write (IFP, 101)
     $        _TRIML(TXT),
     $        iErr, _TRIML(CTYP),
     $        NV, LB, IRN, IRX, ILX, MREC, MLOG,
     $        _TRIML(FNM)
      else if (COND_S(IFP)) then
#        define IFP  *
         write (IFP, 101)
     $        _TRIML(TXT),
     $        iErr, _TRIML(CTYP),
     $        NV, LB, IRN, IRX, ILX, MREC, MLOG,
     $        _TRIML(FNM)
#        undef IFP
      endif
CCC_   . write Run-time Tag/Value
      if (SysTag.ne.'R') then
         call DVTwvr (jeDmy, kaDV, IFPv)
         call DVTwvx (jeDmy, IFPv)
CCC_   . terminate tag/value sequence
         call DVTwsp (jeDmy, TXTi, IFPv)
      endif
CCC_   . output access report
      call DVSwmv
     O    (jeDmy,
     I     kaDV,   saDV,
     I     SySTag, CTYP,   KUFMT, FMT,
     I     NV,     LB,
     I     IFPv)
      RETURN
      END
CCC_ & DVSwmv  ## Suite: write access report (from attribute cluster)
      subroutine DVSwmv
     O    (iErr,
     I     kaDV,   saDV,
     I     SySTag, CTYP,   KUFMT, FMT,
     I     NV,     LB,
     I     IFP)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   kaDV (*)
      _INTENT(IN, character) saDV*(*)
      _INTENT(IN, integer)   NV,   LB,   KUFMT
      _INTENT(IN, character) SysTag *(*), CTYP*(*), FMT*(*)
      _INTENT(IN, integer)   IFP
      integer    IOSR
      character  SW*(16)
CCC_  - Body
      IOSR = 0
CCC_   . set SW
      SW = 'E'
CCC_   . gather and outputs
      call DVLwnc
     O    (iErr,
     I     IOSR,
     I     SysTag, CTYP, KUFMT, FMT,
     I     SW,     IFP)
      call DVLbtg
     O    (iErr,
     I     NV, LB, kaDV, saDV, -1, IFP)
      RETURN
      END
CCC_ + automatic generation of write/read suites
#define __DVAINC 0 /* DVSwt */
#include "dvainc.F"
#undef  __DVAINC
#define __DVAINC 1 /* DVSrd */
#include "dvainc.F"
#undef  __DVAINC
CCC_* [DVT] Tag/Value management
CCC_ & DVTcpi  ## Copy single Tag/Value (keep when not found)
      subroutine DVTcpi
     O    (TagD, ValD, ND, LD,
     I     TagS, ValS, NS, LS, TGT)
      implicit none
      _INTENT(IN,   integer)   LD, NS, LS
      _INTENT(INOUT,integer)   ND
      _INTENT(OUT,  character) TagD (*)*(*), ValD (*)*(*)
      _INTENT(IN,   character) TagS (*)*(*), ValS (*)*(*)
      _INTENT(IN,   character) TGT*(*)
      integer js, jd, K0
      K0 = 1
      call UKStgA (js, TagS, NS, LS, K0, TGT)
      call UKAstA (jd, TagD, ND, LD, K0, TGT)
      if (jd.ge.K0) then
         if (js.ge.K0) then
            ValD (jd) = ValS (js)
         else
            ValD (jd) = ' '
         endif
      endif
      RETURN
      END
CCC_ & DVTcps  ## Copy Tag/Value (automatic/internal)
      subroutine DVTcps
     O    (TagD, ValD, ND, LD,
     I     TagS, ValS, NS, LS, PFX)
      implicit none
      _INTENT(IN,   integer)   LD, NS, LS
      _INTENT(INOUT,integer)   ND
      _INTENT(OUT,  character) TagD (*)*(*), ValD (*)*(*)
      _INTENT(IN,   character) TagS (*)*(*), ValS (*)*(*)
      _INTENT(IN,   character) PFX*(*)
      integer js, jd, K0
      K0 = 1
      if (PFX.eq.' ') then
         do js = K0, MIN (NS, LS)
            call UKAstA (jd, TagD, ND, LD, K0, TagS (js))
            if (jd.ge.K0.and.jd.le.LD) then
               ValD (jd) = ValS (js)
            endif
         enddo
      else
         do js = K0, MIN (NS, LS)
            if (INDEX (PFX, TagS (js)(1:1)).gt.0) then
               call UKAstA (jd, TagD, ND, LD, K0, TagS (js))
               if (jd.ge.K0.and.jd.le.LD) then
                  ValD (jd) = ValS (js)
               endif
            endif
         enddo
      endif
      RETURN
      END
CCC_ & DVTrvs  ## Revert Tag/Value (automatic/internal)
      subroutine DVTrvs
     O    (Col,
     I     N,   L,  Tag, Val, PFX)
      implicit none
      _INTENT(IN, integer)   N, L
      _INTENT(IN, character) Tag (*)*(*), Val (*)*(*)
      _INTENT(OUT,character) Col (*)*(*)
      _INTENT(IN, character) PFX*(*)
      integer js, K0
      K0   = 1
      if (PFX.eq.' ') then
         do js = K0, MIN (N, L)
            Col (js) = Val (js)
         enddo
      else
         do js = K0, MIN (N, L)
            if (INDEX (PFX, Tag (js)(1:1)).gt.0) then
               Col (js) = ' '
            else
               Col (js) = Val (js)
            endif
         enddo
      endif
      RETURN
      END
CCC_ & DVTclv  ## Clear values corresponding to prefix
      subroutine DVTclv
     M    (Tag, Val, N, L,
     I     PFX)
      implicit none
      _INTENT(IN,   integer)   L
      _INTENT(INOUT,integer)   N
      _INTENT(INOUT,character) Tag (*)*(*), Val (*)*(*)
      _INTENT(IN,   character) PFX*(*)
      integer js, K0
      if (PFX.eq.' ') return
      K0 = 1
      do js = K0, MIN (N, L)
         if (INDEX (PFX, Tag (js)(1:1)).gt.0) then
            Val (js) = ' '
         endif
      enddo
      RETURN
      END
CC_  & DVTwbx  ## Write Tag/Value (common through execution)
      subroutine DVTwbx (iErr, IFP)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   IFP
      character V*(128)
      iErr = 0
CCC_  - build
      call DEGtid (iErr, V)
      call DVTwta (iErr, '%TREE', V, ' ', IFP)
CCC_  - run
      RETURN
      END
CC_  & DVTwvx  ## Write Tag/Value (Executable automatic)
      subroutine DVTwvx (iErr, IFP)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   IFP
#if 1
      iErr = 0 * IFP
#else /* obsolete */
      logical OFIRST
      data    OFIRST /.true./
      save    OFIRST
      character TID*(80)
      save      TID
      data      TID /' '/
      iErr = 0
      if (OFIRST) then
         call DEGtid (iErr, TID)
         OFIRST = .false.
      endif
      call DVTwta (iErr, '%TREE', TID, ' ', IFP)
#endif /* obsolete */
      RETURN
      END
CC_  & DVTwvr  ## Write Tag/Value (DV* internal)
      subroutine DVTwvr (iErr, kaDV, IFP)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   kaDV (*)
      _INTENT(IN, integer)   IFP
      iErr = 0
#if 1
      call DVTwti (iErr, '@NR',   kaDV (VIO_NMPI), ' ', IFP)
#else /* obsolete */
      call DVTwti (iErr, '@IR',   kaDV (VIO_IMPI), ' ', IFP)
      call DVTwti (iErr, '@NR',   kaDV (VIO_NMPI), ' ', IFP)
      call DVTwti (iErr, '!IREC', kaDV (VIO_RECI), ' ', IFP)
      call DVTwti (iErr, '!ILOG', kaDV (VIO_LOGI), ' ', IFP)
#endif
      RETURN
      END
CC_  & DVTqmp  ## Inquire DV* internal mpi attributes
      subroutine DVTqmp
     O    (IR,   NR,
     I     Tag,  Val, NT, LT)
      _INTENT(OUT,integer)   IR,  NR
      _INTENT(IN, integer)   NT,  LT
      _INTENT(IN, character) Tag (LT)*(*), Val (LT)*(*)
      integer ji, K0
      K0 = 1
      call UKStgA (ji, Tag, NT, LT, K0, '@IR')
      if (ji.ge.K0) then
         call DVTqvi (IR, Val (ji), -1)
      endif
      call UKStgA (ji, Tag, NT, LT, K0, '@NR')
      if (ji.ge.K0) then
         call DVTqvi (NR, Val (ji), -1)
      endif
      RETURN
      END
CC_  & DVTsmp  ## Set DV* internal mpi attributes
      subroutine DVTsmp
     M    (Tag,  Val, NT, LT,
     I     IR,   NR)
      _INTENT(IN,   integer)   LT
      _INTENT(INOUT,character) Tag (LT)*(*), Val (LT)*(*)
      _INTENT(INOUT,integer)   NT
      _INTENT(IN,   integer)   IR,  NR
      integer ji, K0
      K0 = 1
      if (IR.ge.0) then
         call UKAstA (ji, Tag, NT, LT, K0, '@IR')
         if (ji.ge.K0 .and. ji.le.LT) then
            call DVTsvi (Val (ji), IR)
         endif
      endif
      if (NR.ge.0) then
         call UKAstA (ji, Tag, NT, LT, K0, '@NR')
         if (ji.ge.K0 .and. ji.le.LT) then
            call DVTsvi (Val (ji), NR)
         endif
      endif
      RETURN
      END
CC_  & DVTcmp  ## Collate DV* internal mpi attributes
      subroutine DVTcmp
     O    (Omatch,
     I     Tag,  Val, NTv, LTv,
     I     IR,   NR)
      _INTENT(INOUT,logical)   Omatch
      _INTENT(IN,   integer)   NTv, LTv
      _INTENT(IN,   character) Tag (LTv)*(*), Val (LTv)*(*)
      _INTENT(IN,   integer)   IR,  NR
      integer ji, K0
      K0 = 1
      if (IR.ge.0) then
         call UKStgA (ji, Tag, NTV, LTV, K0, '@IR')
         if (ji.ge.K0 .and. ji.le.LTv) then
            call DVTcvi (Omatch, Val (ji), IR)
         endif
      endif
      if (NR.ge.0) then
         call UKStgA (ji, Tag, NTV, LTV, K0, '@NR')
         if (ji.ge.K0 .and. ji.le.LTv) then
            call DVTcvi (Omatch, Val (ji), NR)
         endif
      endif
      RETURN
      END
CCC_ & DVTukw  ## Write U-key
CCC_ & DVTwra  ## Write Anchor by rank
      subroutine DVTwra
     O    (iErr,
     I     kaDV,  IFP)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   IFP
      _INTENT(IN, integer)   kaDV (*)
      call DVTwti (iErr, '-ANCHOR', kaDV (VIO_IMPI), 'RANK', IFP)
      RETURN
      END
CCC_ & DVTwta  ## Write tag-value pair (character)
      subroutine DVTwta
     O    (iErr,
     I     T,    AV,  E, IFP)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   IFP
      _INTENT(IN, character) AV*(*)
      _INTENT(IN, character) T*(*), E*(*)
      call DVTwtv (iErr, T, AV, 'A', E, IFP)
      RETURN
      END
CCC_ & DVTwts  ## Write tag-value pair (real/standard)
      subroutine DVTwts
     O    (iErr,
     I     T,    SV,  E, IFP)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   IFP
      _INTENT(IN, _REALSTD)  SV
      _INTENT(IN, character) T*(*), E*(*)
      character V*32
      call USGlfs (V, SV, ' ')
      call DVTwtv (iErr, T, V, 'S', E, IFP)
      RETURN
      END
CCC_ & DVTwti  ## Write tag-value pair (integer)
      subroutine DVTwti
     O    (iErr,
     I     T,    IV,  E, IFP)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   IFP
      _INTENT(IN, integer)   IV
      _INTENT(IN, character) T*(*), E*(*)
      character V*32
      call USGlni (V, IV)
      call DVTwtv (iErr, T, V, 'I', E, IFP)
      RETURN
      END
CCC_ & DVTsvi  ## Set value (integer)
      subroutine DVTsvi
     O    (V,
     I     IV)
      implicit none
      _INTENT(INOUT,character) V*(*)
      _INTENT(IN,   integer)   IV
      call USGlni (V, IV)
      RETURN
      END
CCC_ & DVTqvi  ## Inquire value (integer)
      subroutine DVTqvi
     O    (IV,
     I     V,   Idef)
      implicit none
      _INTENT(OUT,integer)   IV
      _INTENT(IN, character) V*(*)
      _INTENT(IN, integer)   Idef
      if (V.eq.' ') then
         IV = Idef
      else
         read (V, *) IV
      endif
      RETURN
      END
CCC_ & DVTcvi  ## Check collate value (integer)
      subroutine DVTcvi
     O    (Omatch,
     I     V,      IV)
      implicit none
      _INTENT(OUT,logical)   Omatch
      _INTENT(IN, character) V*(*)
      _INTENT(IN, integer)   IV
      integer jchk
      read (V, *) jchk
      Omatch  = (jchk.eq.IV)
      RETURN
      END
CCC_ & DVTcol  ## Tag/Value collation primitive
      subroutine DVTcol
     O    (iErr,
     O     Nskp,
     M     NTv,  TVo,   Vo,
     O     Ao,   Eo,
     I     ColV, Kanch,
     I     LTv,  IFP)
CCC_  - Description
CC    set TVo as tags to collate or collect
CC    set ColV as value to collate or blank to collect
CC    return Nskp as record counter from 0
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(OUT,  integer)   Nskp
      _INTENT(IN,   integer)   LTv
      _INTENT(INOUT,integer)   NTv
      _INTENT(INOUT,character) TVo(LTv)*(*), Vo(LTv)*(*)
      _INTENT(OUT,  character) Ao (LTv)*(*), Eo(LTv)*(*)
      _INTENT(IN,   character) ColV(*)*(*)
      _INTENT(IN,   integer)   Kanch
      _INTENT(IN,   integer)   IFP
      integer j
      integer NTVarg
      logical OMATCH
      integer jta
      integer K0
CCC_  - Body
      iErr   = 0
      Nskp   = 0
      K0     = 1
      if (Kanch.ge.0) then
         call UKAstA (jta, TVo, NTV, LTV, K0, '-ANCHOR')
      else
         jta = -1
      endif
      NTVarg = NTv
      do
         NTV = NTVarg
         call DVTrdg
     O       (iErr,
     M        NTv,  TVo,  Vo,
     O        Ao,   Eo,
     I        LTv,  IFP)
         if (iErr.ne.0) goto 900
         OMATCH = .true.
         do j = 1, NTVarg
            if ((j.ne.jta)
     $           .and. (ColV (j).ne.' ')
     $           .and. (ColV (j).ne.Vo (j))) then
               OMATCH = .false.
               goto 800
            endif
         enddo
 800     continue
         if (OMATCH.and.KANCH.ge.0) then
            call DVTcvi (Omatch, Vo (jta), KANCH)
         endif
         Nskp = Nskp + 1
         if (OMATCH) goto 900
      enddo
 900  continue
c$$$      call DAtrcU (-1, iErr, 'R', 'DVTCOL')
      RETURN
      END
CCC_ & DVTwar  ## Tag/Value array write
      subroutine DVTwar
     O    (iErr,
     I     T,    V,    A,   E,  NT, IFP)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   NT
      _INTENT(IN, character) T(*)*(*), V(*)*(*)
      _INTENT(IN, character) A(*)*(*), E(*)*(*)
      _INTENT(IN, integer)   IFP
      integer j
CCC_  - Body
      iErr   = 0
      do j = 1, NT
         if (iErr.eq.0) then
            if (V (j).ne.' ') then
               call DVTwtv (iErr, T (j), V (j), A (j), E (j), IFP)
            endif
         endif
      enddo
      if (iErr.eq.0) call DVTwsp (iErr, ' ', IFP)
      RETURN
      END
CCC_ & DVTmng  ## Tag/Value manager
      subroutine DVTmng
     O    (iErr)
CCC_  - Declaration
      implicit none
CCC_   . parameter
      integer    Ksep
      parameter (Ksep  = KTYPE_SEP)
      integer    Ktagv
      parameter (Ktagv = KTYPE_UNDEF)
      integer    Ltag, Lvalue, Lattr, Lexpl
      parameter (Ltag  = 16, Lvalue = 64)
      parameter (Lattr = 16, Lexpl  = 64)
CCC_   . arguments
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   IFP
      _INTENT(IN,   character) Ti*(*), Vi*(*), Ai*(*), Ei*(*)
      _INTENT(IN,   integer)   Nskp
      _INTENT(IN,   integer)   LTv
      _INTENT(INOUT,integer)   NTv
      _INTENT(INOUT,character) TVo(LTv)*(*), Vo(LTv)*(*)
      _INTENT(OUT,  character) Ao (LTv)*(*), Eo(LTv)*(*)
      _INTENT(IN,   integer)   KSU
      _INTENT(IN,   integer)   IFPi, IFPo
CCC_   . namelist
      character T*(Ltag),  V*(Lvalue)
      character A*(Lattr), E*(Lexpl)
      integer   K
      namelist /NIDVKM/ T, V, A, E, K
      integer    LVEML
      parameter (LVEML = OPT_NAMELIST_OUTPUT_EMULATION_DVT)
CCC_   . interior
      integer jrec
      integer j
      integer ji
      integer k0
CCC_  - Body
      iErr = 0
      RETURN
CCC_  & DVTfwg  ## Forward tag-value-key sets
      entry DVTfwg
     O    (iErr,
     I     Nskp, IFP)
      iErr = 0
      if (Nskp.lt.0) call UUrwnd (iErr, IFP)
      if (iErr.eq.0) then
         do jrec = 1, Nskp
            DO
               K = 0
               T = ' '
               read (IFP, NIDVKM, IOSTAT = iErr)
               if (iErr .ne.0) goto 510
               if (K .eq. Ksep) goto 500
            ENDDO
 500        continue
         enddo
 510     continue
      endif
      RETURN
CCC_  & DVTcln  ## clone tag-value-key sets
      entry DVTcln
     O    (iErr,
     I     KSU,  IFPi, IFPo)
      iErr = 0
      DO
         T = ' '
         V = ' '
         A = ' '
         E = ' '
         K = 0
         read  (IFPi, NIDVKM, IOSTAT = iErr)
         if (iErr.ne.0) goto 1900
         write (IFPo, NIDVKM, IOSTAT = iErr)
         if (K.eq.KSU) goto 1900
      enddo
 1900 continue
      RETURN
CCC_  & DVTrdg  ## Read next set of tag-value-key
      entry DVTrdg
     O    (iErr,
     M     NTv,  TVo,  Vo,
     O     Ao,   Eo,
     I     LTv,  IFP)
c
      iErr = 0
c
      do j = 1, NTv
         Ao  (j) = ' '
         Eo  (j) = ' '
         Vo  (j) = ' '
      enddo
      do j = NTv + 1, LTv
         TVo (j) = ' '
         Ao  (j) = ' '
         Eo  (j) = ' '
         Vo  (j) = ' '
      enddo
c
      k0 = 1
      do
         T = ' '
         V = ' '
         A = ' '
         E = ' '
         K = 0
         read (IFP, NIDVKM, IOSTAT = iErr)
         if (iErr.ne.0)  goto 900
         if (K.eq.Ksep) goto 900
         if (K.ge.0) then
            call UKAstA (ji, TVo, NTv, LTv, K0, T)
            if (ji.gt.0 .and. ji.le.LTv) then
               Vo  (ji) = V
               Ao  (ji) = A
               Eo  (ji) = E
            endif
         endif
      enddo
 900  continue
      RETURN
CCC_  & DVTwtv  ## Write tag-value pair
      entry DVTwtv
     O    (iErr,
     I     Ti,   Vi,  Ai, Ei, IFP)
      iErr = 0
      K    = Ktagv
      if (LVEML.gt.0) then
         call UNBbgn (iErr, 'NIDVKM',    IFP, LVEML)
         call UNBint (iErr, 'K', K,  IFP, LVEML)
         call UNBstr (iErr, 'T', Ti, IFP, LVEML)
         call UNBstr (iErr, 'V', Vi, IFP, LVEML)
         if (Ai.ne.' ') call UNBstr (iErr, 'A',  Ai, IFP, LVEML)
         if (Ei.ne.' ') call UNBstr (iErr, 'E',  Ei, IFP, LVEML)
         call UNBend (iErr, 'NIDVKM',    IFP, LVEML)
      else
         T = Ti
         V = Vi
         A = Ai
         E = Ei
         if (COND_N(IFP)) then
            write (IFP, NIDVKM)
         else if (COND_S(IFP)) then
            write (*,   NIDVKM)
         endif
      endif
      RETURN
CCC_  & DVTwsp  ## Write separator
      entry DVTwsp
     O    (iErr,
     I     Ei,   IFP)
      iErr = 0
      K    = Ksep
      T    = ' '
      if (LVEML.gt.0) then
         call UNBbgn (iErr, 'NIDVKM',  IFP, LVEML)
         call UNBint (iErr, 'K',    K, IFP, LVEML)
         call UNBstr (iErr, 'T',    T, IFP, LVEML)
         if (Ei.ne.' ') call UNBstr (iErr, 'E',  Ei, IFP, LVEML)
         call UNBend (iErr, 'NIDVKM',    IFP, LVEML)
      else
         V = ' '
         A = ' '
         E = Ei
         if (COND_N(IFP)) then
            write (IFP, NIDVKM)
         else if (COND_S(IFP)) then
            write (*,   NIDVKM)
         endif
      endif
      RETURN
CCC_  & DVTwsu  ## Write separator (user)
      entry DVTwsu
     O    (iErr,
     I     KSU,  Ei,   IFP)
      iErr = 0
      K    = KSU
      T    = ' '
      if (LVEML.gt.0) then
         call UNBbgn (iErr, 'NIDVKM',  IFP, LVEML)
         call UNBint (iErr, 'K',    K, IFP, LVEML)
         call UNBstr (iErr, 'T',    T, IFP, LVEML)
         if (Ei.ne.' ') call UNBstr (iErr, 'E',  Ei, IFP, LVEML)
         call UNBend (iErr, 'NIDVKM',    IFP, LVEML)
      else
         V = ' '
         A = ' '
         E = Ei
         if (COND_N(IFP)) then
            write (IFP, NIDVKM)
         else if (COND_S(IFP)) then
            write (*,   NIDVKM)
         endif
      endif
      RETURN
      END
CCC_* [DVF] File attribute/policy manager
CCC_ & DVFltp  ## length in bytes (from type)
      subroutine DVFltp
     O    (LB,
     I     N,  CTYP)
      implicit none
      _INTENT(OUT,integer)   LB
      _INTENT(IN, integer)   N
      _INTENT(IN, character) CTYP
      if      (CTYP .eq. 'I') then
         LB = N * INTEGER_0_BYTES
      else if (CTYP .eq. 'D') then
         LB = N * REAL_DOUBLE_BYTES
      else if (CTYP .eq. 'F') then
         LB = N * REAL_FLOAT_BYTES
      else if (CTYP .eq. 'S') then
         LB = N * REAL_STD_BYTES
      else
         LB = N
      endif
      RETURN
      END
CCC_ & DVFset  ## File: attribute init/check batch
      subroutine DVFset
     O    (iErr,
     O     kaDV,  saDV,
     I     PDP,   LB,   FMT,   CPLCY,
     I     FNM,   IFP,  IFPv,  iMA)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   kaDV  (*)
      _INTENT(OUT,character) saDV *(*)
      _INTENT(IN, character) PDP  *(*), CPLCY *(*), FMT *(*)
      _INTENT(IN, integer)   LB
      _INTENT(IN, character) FNM  *(*)
      _INTENT(IN, integer)   IFP, IFPv, iMA (*)
      integer jeDmy
CCC_  - Body
      iErr = 0
      if (iErr.eq.0) then
         call DVFati (iErr, kaDV, saDV, LB, FNM)
         call DVFppp (kaDV, PDP)
         call DVFbrl (kaDV, FMT, FNM)
         call DVFl2p (kaDV, FMT)
      endif
CC    always store; ignore error
      call DVFrpi (jeDmy, kaDV, IFP, IFPv, iMA)
c
      if (iErr.eq.0) call DVFs2p (kaDV, CPLCY)
      if (iErr.eq.0) call DVFxch (iErr, kaDV, saDV)
c
      RETURN
      END
CCC_ & DVFati  ## File: attribute initialization
      subroutine DVFati
     O    (iErr,
     O     kaDV,  saDV,
     I     LB,    FNM)
CCC_  - Description
CC      PDP   Predefined policies set {W,N,O,C,A,R,E}
CC      LB    length in bytes (negative for seq.)
CC      FMT   blank (unformatted) or asterisk (formatted)
CC
CC      When formatted/direct access, unit length (in bytes) must be set
CC      at write/read accesses.
CC      When formatted access, format string can be set at write/read
CC      accesses, or use asterisk.
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   kaDV (*)
      _INTENT(OUT,character) saDV*(*)
      _INTENT(IN, character) FNM *(*)
      _INTENT(IN, integer)   LB
CCC_  - Body
      iErr = 0
      kaDV (VIO_UNIT) = -2
      kaDV (VIO_RECI) = -1
      kaDV (VIO_LOGI) = -1
      kaDV (VIO_RECC) = 0
      kaDV (VIO_LOGC) = 0
      kaDV (VIO_RBYT) = LB
      kaDV (VIO_ULOG) = -1
      kaDV (VIO_UNRP) = -1
      kaDV (VIO_NRLG) = -1
      kaDV (VIO_IMPI) = -1
      kaDV (VIO_NMPI) = -1
      kaDV (VIO_COMM) = -1
CCC_   . string attributes
      saDV = ' '
      VIO_FILENAME(saDV) = FNM
c
      RETURN
      END
CCC_ & DVFppp  ## File: parse predefined policies
      subroutine DVFppp
     M    (kaDV,
     I     PDP)
      implicit none
      _INTENT(INOUT,integer)   kaDV (*)
      _INTENT(IN,   character) PDP*(*)
CCC_  - Write default (==N)
      if      (PDP.eq.'W') then
         kaDV (VIO_PACT) = VIO_ACTION_WRITE
         kaDV (VIO_PLCX) = VIO_POLICY_X_ERR
         kaDV (VIO_PLCN) = VIO_POLICY_N_CREATE
CCC_  - New (write/error/create)
      else if (PDP.eq.'N') then
         kaDV (VIO_PACT) = VIO_ACTION_WRITE
         kaDV (VIO_PLCX) = VIO_POLICY_X_ERR
         kaDV (VIO_PLCN) = VIO_POLICY_N_CREATE
CCC_  - Overwrite (write/overwrite/create)
      else if (PDP.eq.'O') then
         kaDV (VIO_PACT) = VIO_ACTION_WRITE
         kaDV (VIO_PLCX) = VIO_POLICY_X_OVERWRITE
         kaDV (VIO_PLCN) = VIO_POLICY_N_CREATE
CCC_  - Append (write/append/create)
      else if (PDP.eq.'A') then
         kaDV (VIO_PACT) = VIO_ACTION_WRITE
         kaDV (VIO_PLCX) = VIO_POLICY_X_APPEND
         kaDV (VIO_PLCN) = VIO_POLICY_N_CREATE
CCC_  - Clobber (write/clobber/create)
      else if (PDP.eq.'C') then
         kaDV (VIO_PACT) = VIO_ACTION_WRITE
         kaDV (VIO_PLCX) = VIO_POLICY_X_CLOBBER
         kaDV (VIO_PLCN) = VIO_POLICY_N_CREATE
CCC_  - Read default (==E)
      else if (PDP.eq.'R') then
         kaDV (VIO_PACT) = VIO_ACTION_READ
         kaDV (VIO_PLCX) = VIO_POLICY_X_IGNORE
         kaDV (VIO_PLCN) = VIO_POLICY_N_ERR
CCC_  - Exist-read (Read/ignore/error)
      else if (PDP.eq.'E') then
         kaDV (VIO_PACT) = VIO_ACTION_READ
         kaDV (VIO_PLCX) = VIO_POLICY_X_IGNORE
         kaDV (VIO_PLCN) = VIO_POLICY_N_ERR
      else
CCC_  - Else (Unknown/error/create)
         kaDV (VIO_PACT) = VIO_ACTION_UNKNOWN
         kaDV (VIO_PLCX) = VIO_POLICY_X_ERR
         kaDV (VIO_PLCN) = VIO_POLICY_N_CREATE
      endif
      RETURN
      END
CCC_ & DVFbrl  ## File: byte-length to record length
      subroutine DVFbrl
     M    (kaDV,
     I     FMT, FNM)
      implicit none
      _INTENT(INOUT,integer)   kaDV (*)
      _INTENT(IN,   character) FMT*(*), FNM*(*)
      integer LB, LR
      LB = kaDV (VIO_RBYT)
      call DVPb2l (LR, LB, FMT, FNM)
      kaDV (VIO_RLEN) = LR
      RETURN
      END
CCC_ & DVFl2p  ## File: length to policies
      subroutine DVFl2p
     M    (kaDV,
     I     FMT)
      implicit none
      _INTENT(INOUT,integer)   kaDV (*)
      _INTENT(IN,   character) FMT*(*)
      integer LB
      LB = kaDV (VIO_RBYT)
CCC_  - Default policy direct/sequential
      if (LB.gt.0) then
         kaDV (VIO_CINT) = 1
         kaDV (VIO_CSTP) = -1
         kaDV (VIO_PLCU) = VIO_POLICY_U_COMMON
c$$$         kaDV (VIO_PLCL) = VIO_POLICY_L_OLD
      else
         kaDV (VIO_CINT) = 0
         kaDV (VIO_CSTP) = -1
         kaDV (VIO_PLCU) = VIO_POLICY_U_BLACK
c$$$         kaDV (VIO_PLCL) = VIO_POLICY_L_OLD
      endif
CCC_  - form
      if (FMT.eq.' ') then
         kaDV (VIO_FORM) = VIO_FORM_UNFORMATTED
      else
         kaDV (VIO_FORM) = VIO_FORM_FORMATTED
      endif
      RETURN
      END
CCC_ & DVFadj  ## File: attribute adjustment
      subroutine DVFadj
     O    (iErr,
     M     kaDV,  saDV)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,integer)   kaDV (*)
      _INTENT(INOUT,character) saDV*(*)
CCC_  - Body
      iErr = 0
      if (kaDV (VIO_PLCU).eq.VIO_POLICY_U_COMMON) then
         kaDV (VIO_CINT) = 1
         kaDV (VIO_CSTP) = -1
      endif
      RETURN
      END
CCC_ & DVFxch  ## File: existence check/clause generation
      subroutine DVFxch
     O    (iErr,
     M     kaDV,  saDV)
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,integer)   kaDV (*)
      _INTENT(INOUT,character) saDV*(*)
      logical   OX
      character FNM*(OPT_FILENAME_MAX)
      integer   kpX, kpN, kpA
      character CLS0*(VIO_CLAUSE_SIZE)
      character CLS1*(VIO_CLAUSE_SIZE)
      integer   LR
CCC_  - Body
      iErr = 0
c
      call DVFadj (iErr, kaDV,  saDV)
c
      FNM  = VIO_FILENAME(saDV)
      LR   = kaDV (VIO_RLEN)
      CLS0 = '    '
      CLS1 = '    '
CCC_   . clause Action
      kpA = kaDV (VIO_PACT)
      if (kpA .eq. VIO_ACTION_READ) then
         VIO_CLAUSE_ACTION(CLS0) = 'R'
         VIO_CLAUSE_ACTION(CLS1) = 'R'
      else if (kpA .eq. VIO_ACTION_WRITE) then
         VIO_CLAUSE_ACTION(CLS0) = 'B'
         VIO_CLAUSE_ACTION(CLS1) = 'B'
c$$$         VIO_CLAUSE_ACTION(CLS0) = 'W'
c$$$         VIO_CLAUSE_ACTION(CLS1) = 'W'
      else if (kpA .eq. VIO_ACTION_RW) then
         VIO_CLAUSE_ACTION(CLS0) = 'B'
         VIO_CLAUSE_ACTION(CLS1) = 'B'
      endif
CCC_   . clause Form
      if (kaDV (VIO_FORM).eq.VIO_FORM_UNFORMATTED) then
         VIO_CLAUSE_FORM(CLS0) = 'U'
         VIO_CLAUSE_FORM(CLS1) = 'U'
      else
         VIO_CLAUSE_FORM(CLS0) = 'F'
         VIO_CLAUSE_FORM(CLS1) = 'F'
      endif
CCC_   . clauses Status/Position
      call UUqfex (iErr, OX, FNM)
      if (iErr.eq.0) then
         if (OX) then
            kpX = kaDV (VIO_PLCX)
            if      (kpX .eq. VIO_POLICY_X_ERR) then
               iErr = -1
            else if (kpX .eq. VIO_POLICY_X_CLOBBER) then
               VIO_CLAUSE_STATUS(CLS0) = 'R'
               iErr = 1
            else if (kpX .eq. VIO_POLICY_X_OVERWRITE) then
               VIO_CLAUSE_STATUS(CLS0) = 'O'
               iErr = 1
            else if (kpX .eq. VIO_POLICY_X_APPEND) then
               VIO_CLAUSE_STATUS(CLS0) = 'O'
               VIO_CLAUSE_POS(CLS0)    = 'A'
            else
               continue
            endif
         else
            kpN = kaDV (VIO_PLCN)
            if      (kpN .eq. VIO_POLICY_N_ERR) then
               iErr = -1
            else if (kpN .eq. VIO_POLICY_N_CREATE) then
               VIO_CLAUSE_STATUS(CLS0) = 'N'
               iErr = 1
            else
               continue
            endif
         endif
      endif
      VIO_CLAUSE_STATUS(CLS1) = 'O'
CCC_   . sequential
      if (LR.lt.0) then
         VIO_CLAUSE_POS(CLS1)    = 'A'
      endif
CCC_   . store clause
      VIO_CLAUSE_FIRST(saDV) = CLS0
      VIO_CLAUSE_LATER(saDV) = CLS1
      RETURN
      END
CCC_ & DVFrpi  ## File: misc attributes to report
      subroutine DVFrpi
     O    (iErr,
     M     kaDV,
     I     IFP, IFPv, iMA)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   kaDV (*)
      _INTENT(IN, integer)   IFP,  IFPv, iMA (*)
      iErr = 0
      kaDV (VIO_ULOG) = IFP
      kaDV (VIO_UNRP) = IFPv
      kaDV (VIO_NRLG) = -1
      call DMAget (kaDV (VIO_IMPI), iMA, 'IR')
      call DMAget (kaDV (VIO_NMPI), iMA, 'NR')
      call DMAget (kaDV (VIO_COMM), iMA, 'CO')
      RETURN
      END
CCC_ & DVFgru  ## File: get report file unit
      subroutine DVFgru
     O    (IFP,
     I     kaDV, KSW)
      implicit none
      _INTENT(OUT,integer) IFP
      _INTENT(IN, integer) kaDV (*)
      _INTENT(IN, integer) KSW
      if (KSW.eq.0) then
         IFP = kaDV (VIO_ULOG)
      else if (KSW.eq.1) then
         IFP = kaDV (VIO_UNRP)
      else
         IFP = kaDV (VIO_ULOG)
      endif
      RETURN
      END
CCC_ & DVFwrp  ## File: attributes report wrapper
      subroutine DVFwrp
     O    (iErr,
     I     kaDV,  saDV)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   kaDV (*)
      _INTENT(IN, character) saDV*(*)
      integer IFP, IFPv
      IFP  = kaDV (VIO_ULOG)
      IFPv = kaDV (VIO_UNRP)
      call DVFrep (iErr, kaDV, saDV, IFP, IFPv)
      RETURN
      END
CCC_ & DVFrep  ## File: attributes report
      subroutine DVFrep
     O    (iErr,
     I     kaDV,  saDV,  IFP, IFPv)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   kaDV (*)
      _INTENT(IN, character) saDV*(*)
      _INTENT(IN, integer)   IFP,  IFPv
      character FNM*(OPT_FILENAME_MAX)
      character CLS0*(VIO_CLAUSE_SIZE)
      character CLS1*(VIO_CLAUSE_SIZE)
      integer   ip, irc, ilg, intv, LR, LB
      integer   j
      character CPLCY*(8)
      integer   jeDmy
      integer    LVEML
      parameter (LVEML = _UNMLEM_LEVEL_ENTRY)
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
c
      iErr = 0
      FNM  = VIO_FILENAME(saDV)
      CLS0 = VIO_CLAUSE_FIRST(saDV)
      CLS1 = VIO_CLAUSE_LATER(saDV)
      do j = 1, VIO_CLAUSE_SIZE
         if (CLS0 (j:j).eq.' ') CLS0 (j:j) = '_'
         if (CLS1 (j:j).eq.' ') CLS1 (j:j) = '_'
      enddo
c
      ip   = kaDV (VIO_UNIT)
      irc  = kaDV (VIO_RECI)
      ilg  = kaDV (VIO_LOGI)
      intv = kaDV (VIO_CINT)
      LR   = kaDV (VIO_RLEN)
      LB   = kaDV (VIO_RBYT)
      call DVFp2s (CPLCY, kaDV)
c
 101  format ('DVFREP: ',
     $     I12, I3, I5, I5, 1x, I4, ' [', A3, ':', A4, ':', A4, '] ', A)
      if      (COND_N(IFP))  then
         write (IFP, 101)
     $        LR, ip, irc, ilg, intv, CPLCY, CLS0, CLS1,
     $        _TRIML(FNM)
      else if (COND_S(IFP)) then
#        define IFP *
         write (IFP, 101)
     $        LR, ip, irc, ilg, intv, CPLCY, CLS0, CLS1,
     $        _TRIML(FNM)
#        undef  IFP
      endif
c
      call UNBbgn (jeDmy, 'NIDVFR',     IFPv, LVEML)
      call UNBint (jeDmy, 'LB',   LB,   IFPv, LVEML)
      call UNBint (jeDmy, 'LR',   LR,   IFPv, LVEML)
      call UNBstr (jeDmy, 'CLS0', CLS0, IFPv, LVEML)
      call UNBstr (jeDmy, 'CLS1', CLS1, IFPv, LVEML)
      call UNBstr (jeDmy, 'FNM',  FNM,  IFPv, LVEML)
      call UNBend (jeDmy, 'NIDVFR',     IFPv, LVEML)
c
      RETURN
      END
CCC_ & DVFs2p  ## File: string to policies
      subroutine DVFs2p
     M    (kaDV,
     I     CPLCY)
CCC_  - Declaration
      implicit none
      _INTENT(INOUT,integer)   kaDV  (*)
      _INTENT(IN,   character) CPLCY*(*)
      character Tmp*(8)
CCC_  - Body
      Tmp = CPLCY
CCC_   . X/when exists
      if      (Tmp (1:1).eq.'E') then
         kaDV (VIO_PLCX) = VIO_POLICY_X_ERR
      else if (Tmp (1:1).eq.'C') then
         kaDV (VIO_PLCX) = VIO_POLICY_X_CLOBBER
      else if (Tmp (1:1).eq.'O') then
         kaDV (VIO_PLCX) = VIO_POLICY_X_OVERWRITE
      else if (Tmp (1:1).eq.'A') then
         kaDV (VIO_PLCX) = VIO_POLICY_X_APPEND
      else if (Tmp (1:1).eq.'I') then
         kaDV (VIO_PLCX) = VIO_POLICY_X_IGNORE
      endif
CCC_   . N/when not exists
      if      (Tmp (2:2).eq.'E') then
         kaDV (VIO_PLCN) = VIO_POLICY_N_ERR
      else if (Tmp (2:2).eq.'C') then
         kaDV (VIO_PLCN) = VIO_POLICY_N_CREATE
      else if (Tmp (2:2).eq.'I') then
         kaDV (VIO_PLCN) = VIO_POLICY_N_IGNORE
      endif
CCC_   . U/unit allocation
      if      (Tmp (3:3).eq.'C') then
         kaDV (VIO_PLCU) = VIO_POLICY_U_COMMON
      else if (Tmp (3:3).eq.'F') then
         kaDV (VIO_PLCU) = VIO_POLICY_U_FREE
      else if (Tmp (3:3).eq.'B') then
         kaDV (VIO_PLCU) = VIO_POLICY_U_BLACK
      else if (Tmp (3:3).eq.'O') then
         kaDV (VIO_PLCU) = VIO_POLICY_U_OPEN
      endif
      RETURN
      END
CCC_ & DVFp2s  ## File: policy to string
      subroutine DVFp2s
     O    (CPLCY,
     I     kaDV)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,character) CPLCY*(*)
      _INTENT(IN, integer)   kaDV  (*)
      character Tmp*(8)
CCC_  - Body
CCC_   . X/when exists
      if      (kaDV (VIO_PLCX).eq.VIO_POLICY_X_ERR)       then
         Tmp (1:1) = 'E'
      else if (kaDV (VIO_PLCX).eq.VIO_POLICY_X_CLOBBER)   then
         Tmp (1:1) = 'C'
      else if (kaDV (VIO_PLCX).eq.VIO_POLICY_X_OVERWRITE) then
         Tmp (1:1) = 'O'
      else if (kaDV (VIO_PLCX).eq.VIO_POLICY_X_APPEND)    then
         Tmp (1:1) = 'A'
      else if (kaDV (VIO_PLCX).eq.VIO_POLICY_X_IGNORE)    then
         Tmp (1:1) = 'I'
      else
         Tmp (1:1) = '-'
      endif
CCC_   . N/when not exists
      if      (kaDV (VIO_PLCN).eq.VIO_POLICY_N_ERR)    then
         Tmp (2:2) = 'E'
      else if (kaDV (VIO_PLCN).eq.VIO_POLICY_N_CREATE) then
         Tmp (2:2) = 'C'
      else if (kaDV (VIO_PLCN).eq.VIO_POLICY_N_IGNORE) then
         Tmp (2:2) = 'I'
      else
         Tmp (2:2) = '-'
      endif
CCC_   . U/unit allocation
      if      (kaDV (VIO_PLCU).eq.VIO_POLICY_U_COMMON) then
         Tmp (3:3) = 'C'
      else if (kaDV (VIO_PLCU).eq.VIO_POLICY_U_FREE)   then
         Tmp (3:3) = 'F'
      else if (kaDV (VIO_PLCU).eq.VIO_POLICY_U_BLACK)  then
         Tmp (3:3) = 'B'
      else if (kaDV (VIO_PLCU).eq.VIO_POLICY_U_OPEN)   then
         Tmp (3:3) = 'O'
      else
         Tmp (3:3) = '-'
      endif
      CPLCY = Tmp
      RETURN
      END
CCC_* [DVA] Open/Close/Read/Write accesses
CCC_ & DVApre  ## Access: preprocess (open/position) before write/read
      subroutine DVApre
     O    (iErr,
     O     LB,    FMTo, IRX,  IPV,
     M     kaDV,  saDV,
     I     FMTi,  IRT)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(OUT,  integer)   IPV,  IRX,  LB
      _INTENT(INOUT,integer)   kaDV (*)
      _INTENT(INOUT,character) saDV*(*)
      _INTENT(OUT,  character) FMTo*(*)
      _INTENT(IN,   character) FMTi*(*)
      _INTENT(IN,   integer)   IRT
c
      character CLS*(VIO_CLAUSE_SIZE)
      integer   jc0, jc9
      integer   ilg, irl
      character FNM*(OPT_FILENAME_MAX)
      integer   lr
      integer   IFP
CCC_  - Body
      iErr  = 0
      IPV   = kaDV (VIO_UNIT)
      IFP   = kaDV (VIO_ULOG)
CCC_   . unit allocation (IPV)
      if (IPV.lt.0) then
         call DVPalu (iErr, IPV, kaDV (VIO_PLCU))
      endif
CCC_   . format
      if (kaDV (VIO_FORM).eq.VIO_FORM_UNFORMATTED) then
         FMTo = ' '
      else if (FMTi.eq.' ') then
         FMTo = '*'
      else
         FMTo = FMTi
      endif
CCC_   . open/positioning (IRX)
      if (iErr.ne.0) then
         iErr = VIO_ERR_NO_UNIT
         IRX  = -2
      else
         kaDV (VIO_UNIT)= IPV
         lr  = kaDV (VIO_RLEN)
         ilg = kaDV (VIO_LOGI)
         irl = kaDV (VIO_RECI)
         jc0 = (MIN (0, MAX (-1, ilg)) + 1) * VIO_CLAUSE_SIZE + 1
         jc9 = jc0 + VIO_CLAUSE_SIZE - 1
         CLS = saDV (jc0:jc9)
         FNM = VIO_FILENAME(saDV)
         call DVPopp (iErr, IRX,   IRT, irl, lr, CLS, FNM, IPV, IFP)
      endif
      LB  = kaDV (VIO_RBYT)
      RETURN
      END
CCC_ & DVApos  ## Access: postprocess (close/reopen) after write/read
      subroutine DVApos
     O    (iErr,
     O     IRN,
     M     kaDV,
     I     saDV, IPV, IRX, MREC, MLOG, OFORCE)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(OUT,  integer)   IRN
      _INTENT(INOUT,integer)   kaDV (*)
      _INTENT(IN,   character) saDV*(*)
      _INTENT(IN,   logical)   OFORCE
      _INTENT(IN,   integer)   IPV, IRX, MREC, MLOG
c
      character CLS*(VIO_CLAUSE_SIZE)
      integer   jc0, jc9
      integer   ilg
      character FNM*(OPT_FILENAME_MAX)
      integer   lr
      integer   intv, nstp
      logical   OCLS, OREOPN
CCC_  - Body
      iErr = 0
      ilg  = kaDV (VIO_LOGI)
      ilg  = MAX (0, ilg) + MLOG
      OCLS = OFORCE
      if (.not.OCLS) then
         nstp = kaDV (VIO_CSTP)
         if (nstp.ge.0) then
            kaDV (VIO_CSTP) = kaDV (VIO_CSTP) - MLOG
            OCLS = (nstp .le. 0)
         else
            intv = kaDV (VIO_CINT)
            if (intv.gt.0) OCLS = (MOD (ilg, intv).eq.0)
         endif
      endif
c$$$      write(*, *) 'POSCLS', ilg, OFORCE, OCLS, nstp, intv, mlog
CCC_   . close
      if (OCLS) then
         OREOPN = (kaDV (VIO_PLCU) .eq. VIO_POLICY_U_OPEN)
         lr  = kaDV (VIO_RLEN)
         jc0 = VIO_CLAUSE_SIZE + 1
         jc9 = jc0 + VIO_CLAUSE_SIZE - 1
         CLS = saDV (jc0:jc9)
         FNM = VIO_FILENAME(saDV)
         call DVPclo (iErr, OREOPN, lr, CLS, FNM, IPV)
         if (kaDV (VIO_PLCU) .eq. VIO_POLICY_U_FREE) kaDV (VIO_UNIT)= -1
      endif
CCC_   . update status
      if (iErr.eq.0) then
         kaDV (VIO_RECI) = IRX + MREC - 1
         kaDV (VIO_LOGI) = ilg
         kaDV (VIO_RECC) = MREC
         kaDV (VIO_LOGC) = MLOG
         IRN = IRX + MREC
      else
         IRN = -1
      endif
      RETURN
      END
CCC_ & DVAclm  ## Access: modify close/reopen properties
      subroutine DVAclm
     O    (iErr,
     M     kaDV,  nLOGR)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,integer)   kaDV (*)
      _INTENT(IN,   integer)   nLOGR
CCC_  - Body
      iErr = 0
      kaDV (VIO_CSTP) = nLOGR
      RETURN
      END
CCC_ + automatic generation of put/get subroutines
#define __DVAINC 2 /* DVApt */
#include "dvainc.F"
#undef  __DVAINC
#define __DVAINC 3 /* DVAgt */
#include "dvainc.F"
#undef  __DVAINC
CCC_ & DVAptS  ## Access: put real standard
      subroutine DVAptS
     O    (iErr,
     O     MREC,  MLOG,
     I     SV,
     I     N,   LB, KUfmt, FMT,  IRX, IPV)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   MREC, MLOG
      _INTENT(IN, integer)   N,    KUfmt, LB
      _INTENT(IN, integer)   IRX,  IPV
      _INTENT(IN, character) FMT*(*)
      _INTENT(IN, _REALSTD)  SV (N)
CCC_  - Body
#if   REAL_STD_KIND == REAL_DOUBLE_KIND
      call DVAptD
     O    (iErr,
     O     MREC,  MLOG,
     I     SV,
     I     N,   LB, KUfmt, FMT,  IRX, IPV)
#elif REAL_STD_KIND == REAL_FLOAT_KIND
      call DVAptF
     O    (iErr,
     O     MREC,  MLOG,
     I     SV,
     I     N,   LB, KUfmt, FMT,  IRX, IPV)
#else
#     error "UNKNOWN REAL-STANDARD KIND"
#endif
      RETURN
      END
CCC_ & DVAgtS  ## Access: get real standard
      subroutine DVAgtS
     O    (iErr,
     O     MREC,  MLOG,
     O     SV,
     I     N,   LB, KUfmt, FMT,  IRX, IPV)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   MREC, MLOG
      _INTENT(IN, integer)   N,    KUfmt, LB
      _INTENT(IN, integer)   IRX,  IPV
      _INTENT(IN, character) FMT*(*)
      _INTENT(OUT,_REALSTD)  SV (N)
CCC_  - Body
#if   REAL_STD_KIND == REAL_DOUBLE_KIND
      call DVAgtD
     O    (iErr,
     O     MREC,  MLOG,
     O     SV,
     I     N,   LB, KUfmt, FMT,  IRX, IPV)
#elif REAL_STD_KIND == REAL_FLOAT_KIND
      call DVAgtF
     O    (iErr,
     O     MREC,  MLOG,
     O     SV,
     I     N,   LB, KUfmt, FMT,  IRX, IPV)
#else
#     error "UNKNOWN REAL-STANDARD KIND"
#endif
      RETURN
      END
CCC_ & DVAnml  ## Access: report/setup by namelist
      subroutine DVAnml (iErr)
CCC_  - Declaration
      implicit none
CCC_   . Arguments
      _INTENT(OUT,  integer)  iErr
c
      _INTENT(OUT,  character)  FNMo*(*)
      _INTENT(OUT,  character)  CTYPo*(*), FMTo*(*),   SysTo*(*)
      _INTENT(OUT,  integer)    NVo, LBo,  IRXo, ILXo, MRECo, MLOGo
      _INTENT(OUT,  integer)    KUFMTo,    IOSRo
c
      _INTENT(IN,   character)  FNMi*(*)
      _INTENT(IN,   character)  CTYPi*(*), FMTi*(*),   SysTi*(*)
      _INTENT(IN,   integer)    NVi, LBi,  IRXi, ILXi, MRECi, MLOGi
      _INTENT(IN,   integer)    KUFMTi,    IOSRi
      _INTENT(IN,   character)  SW*(*)
      _INTENT(IN,   integer)    IFP
CCC_   . Interior
      integer    KUFMT
      character  FNM *(OPT_FILENAME_MAX)
      character  CTYP*(16), SysTag*(16), FMT *(VIO_FORMAT_MAX)
c
      integer    LA
      parameter (LA = DLC_LIM)
      integer    MA (LA)
      integer    IOSR
      namelist /NIDVSR/
     $     IOSR,
     $     MA,    FNM, SYSTAG, CTYP, KUFMT, FMT
      integer    LVEML
      parameter (LVEML  = OPT_NAMELIST_OUTPUT_EMULATION)
CCC_  - Body
      iErr = 0
      RETURN
CCC_  & DVArnm  ## Read access report by namelist
      entry DVArnm
     O    (iErr,
     O     IOSRo,
     O     SysTo, CTYPo, KUFMTo, FMTo,
     O     NVo,   LBo,   IRXo,   ILXo,   MRECo, MLOGo, FNMo,
     I     SW,    IFP)
      iErr = 0
      CTYP  = ' '
      MA (DLC_NV)    = INFO_NAN
      MA (DLC_LB)    = INFO_NAN
      MA (DLC_ILX)   = INFO_NAN
      MA (DLC_IRX)   = INFO_NAN
      MA (DLC_MREC)  = INFO_NAN
      MA (DLC_MLOG)  = INFO_NAN
      FNM   = ' '
      KUFMT = 0
      FMT   = ' '
      IOSR  = 0
c
      if (COND_N(IFP)) then
         READ (UNIT = IFP, NML = NIDVSR, IOSTAT = iErr)
      else
         READ (UNIT = *,   NML = NIDVSR, IOSTAT = iErr)
      endif
      CTYPo  = CTYP
      NVo    = MA (DLC_NV)
      LBo    = MA (DLC_LB)
      IRXo   = MA (DLC_ILX)
      ILXo   = MA (DLC_IRX)
      MRECo  = MA (DLC_MREC)
      MLOGo  = MA (DLC_MLOG)
      FNMo   = FNM
      KUFMTo = KUFMT
      FMTo   = FMT
      SysTo  = SysTag
      IOSRo  = IOSR
      RETURN
CCC_  & DVAwnm  ## Write access report by namelist
      entry DVAwnm
     O    (iErr,
     I     IOSRi,
     I     SysTi, CTYPi, KUFMTi, FMTi,
     I     NVi,   LBi,   IRXi,   ILXi,   MRECi, MLOGi, FNMi,
     I     SW,    IFP)
CC    SysTag is to distinguish between Write report and Read report
      iErr = 0
CCC_   . NIDVSR
      MA (DLC_NV)   = NVi
      MA (DLC_LB)   = LBi
      MA (DLC_ILX)  = IRXi
      MA (DLC_IRX)  = ILXi
      MA (DLC_MREC) = MRECi
      MA (DLC_MLOG) = MLOGi
      MA (DLC_IR)   = -1
      if (LVEML.gt.0) then
         if (iErr.eq.0) call UNBbgn (iErr, 'NIDVSR',        IFP, LVEML)
         if (iErr.eq.0) call UNBint (iErr, 'IOSR',   IOSRi, IFP, LVEML)
         if (iErr.eq.0) call UNBstr (iErr, 'SYSTAG', SysTi, IFP, LVEML)
         if (INDEX (SW, 'E').gt.0) then
            if (iErr.eq.0)
     $           call UNBina (iErr, 'MA', MA, LA, 0, IFP,LVEML)
            if (iErr.eq.0) call UNBstr (iErr, 'CTYP', CTYPi, IFP,LVEML)
            if (iErr.eq.0) call UNBint (iErr, 'KUFMT',KUFMTi,IFP,LVEML)
            if (iErr.eq.0) call UNBstr (iErr, 'FMT',  FMTi,  IFP,LVEML)
            if (iErr.eq.0) call UNBstr (iErr, 'FNM',  FNMi,  IFP,LVEML)
         endif
         if (iErr.eq.0) call UNBend (iErr, 'NIDVSR', IFP, LVEML)
      else if (IFP.ge.-1) then
         IOSR   = IOSRi
         CTYP   = CTYPi
         MA (DLC_NV)   = NVi
         MA (DLC_LB)   = LBi
         MA (DLC_ILX)  = IRXi
         MA (DLC_IRX)  = ILXi
         MA (DLC_MREC) = MRECi
         MA (DLC_MLOG) = MLOGi
         MA (DLC_IR)   = -1
         FNM    = FNMi
         FMT    = FMTi
         KUFMT  = KUFMTi
         SysTag = SysTi
         if (COND_N(IFP)) then
            write (IFP, NIDVSR)
         else
            write (*,   NIDVSR)
         endif
      endif
      RETURN
CCC_  - End (DVAnml)
      END
CCC_* [DVL] meta-info log
CCC_ & DVLnmc  ## Log: namelist common among group
      subroutine DVLnmc (iErr)
CCC_  - Declaration
      implicit none
CCC_   . Arguments
      _INTENT(OUT,  integer)  iErr
c
      _INTENT(OUT,  character)  CTYPo*(*), FMTo*(*),   SysTo*(*)
      _INTENT(OUT,  integer)    KUFMTo,    IOSRo
c
      _INTENT(IN,   character)  CTYPi*(*), FMTi*(*),   SysTi*(*)
      _INTENT(IN,   integer)    KUFMTi,    IOSRi
      _INTENT(IN,   character)  SW*(*)
      _INTENT(IN,   integer)    IFP
CCC_   . Interior
      character  CTYP*(16), SysTag*(16), FMT *(VIO_FORMAT_MAX)
      integer    KUFMT
c
      integer    IOSR
      namelist /NIDVSC/ IOSR, SYSTAG, CTYP, FMT, KUFMT
      integer    LVEML
      parameter (LVEML  = _UNMLEM_LEVEL_END)
CCC_  - Body
      iErr = 0
      RETURN
CCC_  & DVLrnc  ## Read access report by namelist
      entry DVLrnc
     O    (iErr,
     O     IOSRo,
     O     SysTo, CTYPo, KUFMTo, FMTo,
     I     SW,    IFP)
      iErr  = 0
c
      CTYP  = ' '
      FMT   = ' '
      IOSR  = 0
      KUFMT = 0
c
      if (COND_N(IFP)) then
         READ (UNIT = IFP, NML = NIDVSC, IOSTAT = iErr)
      else
         READ (UNIT = *,   NML = NIDVSC, IOSTAT = iErr)
      endif
c
      CTYPo  = CTYP
      FMTo   = FMT
      SysTo  = SysTag
      IOSRo  = IOSR
      KUFMTo = KUFMT
      RETURN
CCC_  & DVLwnc  ## Write access report by namelist
      entry DVLwnc
     O    (iErr,
     I     IOSRi,
     I     SysTi, CTYPi, KUFMTi, FMTi,
     I     SW,    IFP)
CC    SysTag is to distinguish between Write report and Read report
      iErr = 0
CCC_   . NIDVSC
      if (LVEML.gt.0) then
         if (iErr.eq.0) call UNBbgn (iErr, 'NIDVSC',        IFP, LVEML)
         if (iErr.eq.0) call UNBint (iErr, 'IOSR',   IOSRi, IFP, LVEML)
         if (iErr.eq.0) call UNBstr (iErr, 'SYSTAG', SysTi, IFP, LVEML)
         if (INDEX (SW, 'E').gt.0) then
            if (iErr.eq.0) call UNBstr (iErr, 'CTYP', CTYPi, IFP,LVEML)
            if (iErr.eq.0) call UNBstr (iErr, 'FMT',  FMTi,  IFP,LVEML)
            if (iErr.eq.0) call UNBint (iErr, 'KUFMT',KUFMTi,IFP,LVEML)
         endif
         if (iErr.eq.0) call UNBend (iErr, 'NIDVSC', IFP, LVEML)
      else if (IFP.ge.-1) then
         IOSR   = IOSRi
         CTYP   = CTYPi
         FMT    = FMTi
         KUFMT  = KUFMTi
         SysTag = SysTi
         if (COND_N(IFP)) then
            write (IFP, NIDVSC)
         else
            write (*,   NIDVSC)
         endif
      endif
      RETURN
CCC_  - End (DVLnmc)
      END
CCC_ & DVLbtg  ## Log: gather and output batch
      subroutine DVLbtg
     O    (iErr,
     I     NV, LB, kaDV, saDV, KingI, IFP)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   kaDV (*)
      _INTENT(IN, character) saDV*(*)
      _INTENT(IN, integer)   NV,   LB
      _INTENT(IN, integer)   KingI
      _INTENT(IN, integer)   IFP
      integer    Mgrp
      parameter (Mgrp = OPT_DVIO_GATHER_MOD)
      integer    LMA
      parameter (LMA = DLC_LIM)
      integer    LSA
      parameter (LSA = OPT_FILENAME_MAX)
      integer    LMG, LSG
      parameter (LMG = LMA * Mgrp)
      parameter (LSG = LSA * Mgrp)
      integer    MAG (LMG)
      character  SAG*(LSG)
      integer    nmpi, impi, icom
      integer    jgs,  ksub
      integer    jr,   jm,   jss,  jse, j0
      integer    king
CCC_  - Body
      iErr = 0
c
      nmpi = MAX (1, kaDV (VIO_NMPI))
      impi = kaDV (VIO_IMPI)
      icom = kaDV (VIO_COMM)
c
      king = MAX (0, KingI)
c
      call DVLgsi
     O    (iErr,
     O     MAG,  SAG,
     I     Lma,  Lsa,  Mgrp,
     I     NV,   LB,   kaDV, saDV,
     I     impi, nmpi, icom)
c
      do jgs = 1, (nmpi - 1) / Mgrp + 1
         ksub = (jgs - 1) * Mgrp
         call DMWoci
     $        (iErr, MAG, LMG, impi, king, ksub, icom)
         call DMWoca
     $        (iErr, SAG, LSG, impi, king, ksub, icom)
         if (impi.eq.king) then
            j0 = (jgs - 1) * Mgrp
            do jr = j0, MIN (nmpi, jgs * Mgrp) - 1
               jm  = (jr - j0) * LMA + 1
               jss = (jr - j0) * LSA + 1
               jse = jss + LSA - 1
               call DVLwnm
     $             (iErr,
     $              MAG (jm),  SAG (jss:jse),  jr,
     $              IFP)
            enddo
         endif
      enddo
      RETURN
      END
CCC_ & DVLgsi  ## Log: gather information in sub-group
      subroutine DVLgsi
     O    (iErr,
     O     MAG,  SAG,
     I     Lma,  Lsa,  Mgrp,
     I     NV,   LB,   kaDV, saDV,
     I     impi, nmpi, icom)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   MAG (*)
      _INTENT(OUT,character) SAG*(*)
      _INTENT(IN, integer)   NV, LB
      _INTENT(IN, integer)   kaDV (*)
      _INTENT(IN, character) saDV*(*)
      _INTENT(IN, integer)   Lma, Lsa, Mgrp
      _INTENT(IN, integer)   nmpi, impi, icom
c
      character  FNM *(OPT_FILENAME_MAX)
      integer    LA
      parameter (LA = DLC_LIM)
      integer    MA (LA)
CCC_  - Body
      iErr = 0
c
      FNM  = VIO_FILENAME(saDV)
c
      MA (DLC_NV)   = NV
      MA (DLC_LB)   = LB
      MA (DLC_ILX)  = kaDV (VIO_LOGI)
      MA (DLC_IRX)  = kaDV (VIO_RECI)
      MA (DLC_MREC) = kaDV (VIO_RECC)
      MA (DLC_MLOG) = kaDV (VIO_LOGC)
      MA (DLC_IR)   = impi
c
      SAG = ' '
      call DMWgsa
     $    (iErr, SAG,  FNM, LSA, Mgrp,  impi, nmpi, icom)
      call DMWgsi
     $    (iErr, MAG,  MA,  LMA, Mgrp,  impi, nmpi, icom)
c
      RETURN
      END
CCC_ & DVLrdx  ## Log: read and conversion
      subroutine DVLrdx
     O    (iErr,
     O     NV,   LB,   kaDV, saDV,  IR,
     I     DPFX, IFP)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,integer)   NV, LB
      _INTENT(INOUT,integer)   kaDV (*)
      _INTENT(INOUT,character) saDV*(*)
      _INTENT(OUT,  integer)   IR
      _INTENT(IN,   character) DPFX*(*)
      _INTENT(IN,   integer)   IFP
c
      character  FNM *(OPT_FILENAME_MAX)
      character  TFNM*(OPT_FILENAME_MAX)
      integer    LA
      parameter (LA = DLC_LIM)
      integer    MA (LA)
CCC_  - Body
      iErr = 0
      call DVLrnm (iErr, MA,  FNM, IR, IFP)
      if (iErr.eq.0) then
         NV = MA (DLC_NV)
         LB = MA (DLC_LB)
         kaDV (VIO_LOGI) = MA (DLC_ILX)
         kaDV (VIO_RECI) = MA (DLC_IRX)
         kaDV (VIO_RECC) = MA (DLC_MREC)
         kaDV (VIO_LOGC) = MA (DLC_MLOG)
         if (DPFX.eq.' ') then
            VIO_FILENAME(saDV) = FNM
         else
            call USCsta(TFNM, DPFX, FNM)
            VIO_FILENAME(saDV) = TFNM
         endif
      endif
      RETURN
      END
CCC_ & DVLnml  ## Log: namelist manager
      subroutine DVLnml (iErr)
CCC_  - Declaration
      implicit none
CCC_   . Arguments
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   IRi
      _INTENT(IN, integer)   MAi  (*)
      _INTENT(IN, character) FNMi*(*)
c
      _INTENT(OUT,integer)   IRo
      _INTENT(OUT,integer)   MAo  (*)
      _INTENT(OUT,character) FNMo*(*)
c
      _INTENT(IN, integer)   IFP
CCC_   . Interior
      integer    LVEML
      parameter (LVEML = OPT_NAMELIST_OUTPUT_EMULATION_DVG)
c
      character  FNM *(OPT_FILENAME_MAX)
      integer    LA
      parameter (LA = DLC_LIM)
      integer    MA (LA)
      namelist /NIDVSG/ MA, FNM
c
      integer    ja
CCC_  - Body
      iErr = 0
      RETURN
CCC_  & DVLrnm  ## read log by namelist (part)
      entry DVLrnm
     $    (iErr,
     $     MAo,  FNMo, IRo,
     $     IFP)
      iErr = 0
      do ja = 1, LA
         MA (ja) = INFO_NAN
      enddo
      FNM = ' '
      if (COND_N(IFP)) then
         READ (UNIT = IFP, NML = NIDVSG, IOSTAT = iErr)
      else
         READ (UNIT = *,   NML = NIDVSG, IOSTAT = iErr)
      endif
      do ja = 1, LA
         MAo (ja) = MA (ja)
      enddo
      IRo  = MA (DLC_IR)
      FNMo = FNM
c$$$      write (*, *) 'RNM', iErr
      RETURN
CCC_  & DVLwnm  ## write log by namelist (part)
      entry DVLwnm
     $    (iErr,
     $     MAi,  FNMi, IRi,
     $     IFP)
      iErr = 0
      do ja = 1, LA
         MA (ja) = MAi (ja)
      enddo
      MA (DLC_IR) = IRi
      FNM =  FNMi
      if (LVEML.gt.0) then
         if (iErr.eq.0) call UNBbgn (iErr, 'NIDVSG', IFP, LVEML)
         if (iErr.eq.0)
     $        call UNBina (iErr, 'MA', MA, LA, 0, IFP, LVEML)
         if (iErr.eq.0) call UNBstr (iErr, 'FNM', FNM, IFP, LVEML)
         if (iErr.eq.0) call UNBend (iErr, 'NIDVSG', IFP, LVEML)
      else if (COND_N(IFP)) then
         write (IFP, NIDVSG)
      else if (COND_S(IFP)) then
         write (*,   NIDVSG)
      endif
      RETURN
CCC_  - End (DVLnml)
      END
CCC_* [DVP] Primitives
CCC_ & DVPb2l  ## Primitive: bytes to record length conversion
      subroutine DVPb2l
     O    (LR,
     I     LB, FMT, FNM)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   LR
      _INTENT(IN, integer)   LB
      _INTENT(IN, character) FMT*(*)
      _INTENT(IN, character) FNM*(*)
      integer LUNIT
      data    LUNIT /0/
      save    LUNIT
      integer jE
CCC_  - Body
CCC_   . sequential
      if (LB.lt.0) then
         LR = -1
CCC_   . direct/unformatted
      else if (FMT .eq. ' ') then
         if (LUNIT.eq.0) then
            call UUlenU (jE, LUNIT, FNM, -1, -1)
            if (jE.ne.0) LUNIT = 0
         endif
         if (LUNIT.eq.0) then
            LR = 0
         else
            LR = LB / LUNIT
         endif
CCC_   . direct/formatted
      else
         LR = LB
      endif
      RETURN
      END
CCC_ & DVPalu  ## Primitive: allocate i/o unit
      subroutine DVPalu
     O    (iErr,
     O     IP,
     I     kpU)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(OUT,  integer)   IP
      _INTENT(IN,   integer)   kpU
c
      integer IBLSAV
      data    IBLSAV /-1/
      save    IBLSAV
CCC_  - Body
      iErr = 0
      if (kpU .eq. VIO_POLICY_U_COMMON) then
         if (IBLSAV.eq.-1) then
            call UUMCnu (iErr, IBLSAV)
            if (iErr.eq.0) then
               call UUMCsf (IBLSAV, -1)
            else
               IBLSAV = -2
            endif
         endif
         IP = IBLSAV
      else
         call UUMCnu (iErr, IP)
         if (iErr.eq.0
     $        .and. kpU .eq. VIO_POLICY_U_BLACK) call UUMCsf (IP, -1)
      endif
      if (IP.lt.0) iErr = -1
      RETURN
      END
CCC_ & DVPopp  ## Primitive: open and position
      subroutine DVPopp
     O    (iErr,
     O     IRX,
     I     IRT, IRL, LR, CLS, FNM, IPV, IFP)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   IRX
      _INTENT(IN, integer)   IRT, IRL, LR
      _INTENT(IN, character) CLS*(*), FNM*(*)
      _INTENT(IN, integer)   IPV, IFP
c
      character TF, TS, TA, TP
      logical   OPND
c$$$      character FBF*1024
CCC_  - Body
      iErr = 0
      IRX  = -1
      call UUquop (iErr, OPND, IPV)
c$$$      write(*,*) 'OPP', iErr, OPND, IPV
c$$$      if (OPND) then
c$$$         call UUqrpu(IPV, -1, FBF)
c$$$      endif
      if (iErr.eq.0) then
         TF = VIO_CLAUSE_FORM(CLS)
         TS = VIO_CLAUSE_STATUS(CLS)
         TA = VIO_CLAUSE_ACTION(CLS)
         TP = VIO_CLAUSE_POS(CLS)
         if (.not.OPND) then
            call UUopen (iErr, IPV, FNM, LR, TF, TS, TA, TP)
         endif
      endif
      if (iErr.ne.0) then
 101     format('DVPOPP: ERROR AT OPEN = ', I4, 1x, A)
         if      (COND_N(IFP))  then
            write (IFP, 101) iErr, _TRIML(FNM)
         else if (COND_S(IFP)) then
#        define IFP *
            write (IFP, 101) iErr, _TRIML(FNM)
#        undef  IFP
         endif
      endif
      if (iErr.eq.0) then
         if (LR.gt.0) then
            call DVPdps (iErr, IRX, IRT, IRL, TF, TP, IPV)
         else
            call DVPsps (iErr, IRX, IRT, IRL, TF, TP, IPV)
         endif
      endif
      if (iErr.ne.0) then
 102     format('DVPOPP: ERROR AT POS = ', I4, 1x, 3I7, 1x, A)
         if      (COND_N(IFP))  then
            write (IFP, 102) iErr, IRX, IRT, IRL,
     $           _TRIML(FNM)
         else if (COND_S(IFP)) then
#        define IFP *
            write (IFP, 102) iErr, IRX, IRT, IRL,
     $           _TRIML(FNM)
#        undef  IFP
         endif
      endif
      RETURN
      END
CCC_ & DVPclo  ## Primitive: close and reopen
      subroutine DVPclo
     O    (iErr,
     I     OREOPN,
     I     LR, CLS, FNM, IPV)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, logical)   OREOPN
      _INTENT(IN, integer)   LR
      _INTENT(IN, character) CLS*(*), FNM*(*)
      _INTENT(IN, integer)   IPV
c
      character TF, TS, TA, TP
CCC_  - Body
      iErr = 0
      call UUclsC (iErr, IPV, FNM, ' ')
      if (iErr.eq.0.and.OREOPN) then
         TF = VIO_CLAUSE_FORM(CLS)
         TS = VIO_CLAUSE_STATUS(CLS)
         TA = VIO_CLAUSE_ACTION(CLS)
         TP = VIO_CLAUSE_POS(CLS)
         call UUopen (iErr, IPV, FNM, LR, TF, TS, TA, TP)
      endif
      RETURN
      END
CCC_ & DVPdps  ## Primitive: set position (direct access)
      subroutine DVPdps
     O    (iErr,
     O     IRX,
     I     IRT, IRL,  TF, TP, IPV)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   IRX
      _INTENT(IN, integer)   IRT, IRL
      _INTENT(IN, integer)   IPV
      _INTENT(IN, character) TF, TP
      logical   Onor
      integer   IOS
CCC_  - Body
      iErr = 0
CCC_   . seek last record
      if (IRT.eq.-1 .or. TP.eq.'A') then
         IRX = MAX (0, IRL)
         if (TF.eq.'F') then
            DO
               IRX = 1 + IRX
               READ (IPV, IOSTAT = IOS, REC = IRX, FMT = '(A1)')
               call UUinor (Onor, IOS)
               if (Onor) goto 100
               if (IOS.ne.0) then
                  iErr = -1
                  goto 100
               endif
            ENDDO
 100        CONTINUE
         else
            DO
               IRX = 1 + IRX
               READ (IPV, IOSTAT = IOS, REC = IRX)
               call UUinor (Onor, IOS)
               if (Onor) goto 110
               if (IOS.ne.0) then
                  iErr = -1
                  goto 110
               endif
            ENDDO
 110        CONTINUE
         endif
CCC_   . next record
      else if (IRT.eq.0) then
         IRX  = MAX (0, IRL) + 1
CCC_   . specified record
      else
         IRX = IRT
      endif
      RETURN
      END
CCC_ & DVPsps  ## Primitive: set position (sequential access)
      subroutine DVPsps
     O    (iErr,
     O     IRX,
     I     IRT, IRL,  TF, TP, IPV)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   IRX
      _INTENT(IN, integer)   IRT, IRL
      _INTENT(IN, integer)   IPV
      _INTENT(IN, character) TF, TP
      logical   Oeof
      integer   IOS
CCC_  - Body
      iErr = 0
CCC_   . next record
      if (IRT.eq.0) then
         IRX  = MAX (0, IRL) + 1
CCC_   . seek last/specified record
      else
CCC_    * if target record is before the current
         IRX = MAX (0, IRL)
         if (IRT.gt.0 .and. IRT.le.IRX) then
CC          if append, then return PANIC
            if (TP.eq.'A') then
               iErr = -999
            else
               call UUrwnd (iErr, IPV)
               IRX = 0
            endif
         endif
         if (iErr.eq.0) then
            IRX = MAX (0, IRX)
            if (TF.eq.'F') then
               DO
                  IRX = 1 + IRX
                  if (IRX.eq.IRT) goto 100
                  READ (IPV, IOSTAT = IOS, FMT = '(A1)')
                  call UUieof (Oeof, IOS)
                  if (Oeof) goto 100
                  if (IOS.ne.0) then
                     iErr = -1
                     goto 100
                  endif
               ENDDO
 100           CONTINUE
            else
               DO
                  IRX = 1 + IRX
                  if (IRX.eq.IRT) goto 110
                  READ (IPV, IOSTAT = IOS)
                  call UUieof (Oeof, IOS)
                  if (Oeof) goto 110
                  if (IOS.ne.0) then
                     iErr = -1
                     goto 110
                  endif
               ENDDO
 110           CONTINUE
            endif
         endif
      endif
      RETURN
      END
CCC_& DVIOMS  ## Development/vio announcement
      subroutine DVIOMS (STRA, STRB, IOP)
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
CCC_* [TEST]
CCC_ + begin test
#if TEST_DVIOMS
CCC_ @ DVTEST  ## Development/vio test
      program DVTEST
CCC_  - Test suites
CC::   SOURCES dmpims.F
CCC_  - Declaration
      implicit none
      integer   iErr
c
      character FNM*(OPT_FILENAME_MAX)

      integer   NC, kpU
      character CSW
      character FPFX*(OPT_FILENAME_MAX)
      namelist /NITEST/ CSW, NC, kpU, FPFX
c
      integer   ipI, ipO, ipE
      integer   ibsA (_MAX_BOOTSTRAP_UNITS)
      integer   ipV
c
      integer   ITEST
CCC_  - Body
      iErr  = 0
      ITEST = 0
c
      call DMinit (iErr, ibsA, 0, 1, 2)
c
      ipI = BOOTSTRAP_IN(ibsA)
      ipO = BOOTSTRAP_OUT(ibsA)
      ipE = BOOTSTRAP_ERR(ibsA)
      ipV = ipE
c
      CSW  = 'W'
      NC   = 0
      kpU  = 0
      FPFX = 'O/dvioms/ta'
c
      call UDTbni (ITEST, 'CONFIG', ' ', ipE)
c
      call UUrwnd (iErr, ipI)
      read  (ipI, NITEST, IOSTAT = iErr)
      write (ipO, NITEST, IOSTAT = iErr)
      iErr = 0
c
      call UDTbni (ITEST, 'FPOL', ' ', ipE)
c
      if (iErr.eq.0) then
         call DVTEST_FPOL
     $       (iErr, ITEST,
     $        FPFX, NC, CSW, kpU, 'UD', 16, 0, ' ', ipE, ipV)
      endif
      if (iErr.eq.0) then
         call DVTEST_FPOL
     $       (iErr, ITEST,
     $        FPFX, NC, CSW, kpU, 'US', -1, 0, ' ', ipE, ipV)
      endif
      if (iErr.eq.0) then
         call DVTEST_FPOL
     $       (iErr, ITEST,
     $        FPFX, NC, CSW, kpU, 'FD', 16, 5, '(20I5)', ipE, ipV)
      endif
      if (iErr.eq.0) then
         call DVTEST_FPOL
     $       (iErr, ITEST,
     $        FPFX, NC, CSW, kpU, 'FS', -1, 0, '*', ipE, ipV)
      endif
c
      call UDTbni (ITEST, 'OTW', ' ', ipE)
      call DVTEST_OTW (iErr, FPFX, ipE, ipV)
c
      call UDTbni (ITEST, 'FINDER', ' ', ipE)
c
c$$$      call DVTEST_Finder (iErr, ipA)
c
      call UUqrpr (-1, -1, -1, FNM)
c
      call UDTbni (ITEST, 'FINE', ' ', ipE)
c
      call DBswpW (iErr, -1, -1)
      call DMWfin (iErr)
c
      STOP
      END
CCC_ & DVTEST_FPOL
      subroutine DVTEST_FPOL
     $    (iErr, ITEST,
     $     FPFX, NC, CSW, kpU, DIR, LB, KU, FMT, IFP, IFPv)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,integer)   ITEST
      _INTENT(IN,   integer)   NC,  kpU
      _INTENT(IN,   character) CSW, DIR*(*)
      _INTENT(IN,   integer)   LB
      _INTENT(IN,   integer)   KU
      _INTENT(IN,   character) FPFX*(*)
      _INTENT(IN,   character) FMT*(*)
      _INTENT(IN,   integer)   IFP, IFPv
c
      character FNM*(OPT_FILENAME_MAX)
      integer   kpx, kpn
      integer   kaDV (VIO_KPOLICY_MAX)
      character saDV*(VIO_SPOLICY_LEN)
      character cpX (0:4), cpN (0:2), cpU (0:3)
      data      cpX /'E', 'C', 'O', 'A', 'I' /
      data      cpN /'E', 'C', 'I' /
      data      cpU /'C', 'F', 'B', 'O' /
      character CPLCY*(8)
c
      integer   NV, IRT, IRN
      integer   jedmy
      integer   iMA (MAX_MPI_ATTR)
      character PDP
c
      integer    LIV
      parameter (LIV = 16)
      integer    IV (LIV)
      integer    j
c
      character  BMSG*(128)
      character  Bfmt*(32)
      character  Bsign*(1)
c
      integer    IT1
      data       IT1 /0/
      save       IT1
      _REALSTD   T2
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
CCC_  - Body
      iErr = 0
CCC_   . test banner
      call USMcpd (Bfmt, FMT, 'null')
      if (LB.ge.0) then
         Bsign = '+'
      else
         Bsign = '-'
      endif

 301  format ('FPOL:',I1,':',I1,':',A,':',A,':',A1, I3.3,':',I2.2,':',A)
      write (BMSG, 301) NC, kpU, CSW,
     $        _TRIM(DIR), Bsign, ABS (LB), KU, _TRIM(Bfmt)
      call UDTbni (ITEST, BMSG, ' ', IFP)
CCC_   . test body
      NV   = 8
c
      IRT = 0
      call DMArst (iMA)
      PDP = CSW
c
 101  format ('fp', I1, ': ', I5, 1x, 3I1, 1x, A)
 201  format (A, A1, I1, I1, '/', A, '.', 2I1, A)
c
      do kpx = VIO_POLICY_X_ERR, VIO_POLICY_X_IGNORE
         do kpn = VIO_POLICY_N_ERR, VIO_POLICY_N_IGNORE
CCC_  - set
            CPLCY = ' '
            CPLCY(1:1) = cpX(kpx)
            CPLCY(2:2) = cpN(kpn)
            CPLCY(3:3) = cpU(kpu)
            write (FNM, 201)
     $           _TRIM(FPFX), PDP,
     $           kpu, NC, _TRIM(DIR), kpx, kpn, _TRIM(CPLCY)
            call DVFset
     O          (iErr, kaDV, saDV,
     I           PDP,  LB,   FMT,  CPLCY, FNM, IFP, IFPv, iMA)
            write (IFP, 101) 0, iErr, kpx, kpn, kpu,
     $           _TRIML(FNM)
            if (PDP.eq.'W') then
CCC_  - write 0
               call UDTbni (ITEST, 'WRITE0', ' ', IFP)
               if (iErr.ge.0) then
                  T2 = 100.0d0 * DBLE (IT1)
                  call DVTwta (iErr, 'T0', 'V0', ' ', IFPv)
                  call DVTwti (iErr, 'T1', IT1,  ' ', IFPv)
                  call DVTwts (iErr, 'T2', T2,   ' ', IFPv)
                  IT1 = IT1 + 1
                  do j = 1, NV
                     IV (j) = j * j * (NC + 1)
                  enddo
                  call DVSwtI
     O                (iErr, IRN,
     M                 kaDV, saDV,
     I                 IRT,  IV,   NV, KU, FMT, 'putI:8')
               endif
               write (IFP, 101) 8, iErr, kpx, kpn, kpu,
     $              _TRIML(FNM)
CCC_  - write 1
               call UDTbni (ITEST, 'WRITE1', ' ', IFP)
               if (iErr.eq.0) then
                  T2 = 100.0d0 * DBLE (IT1)
                  call DVTwta (iErr, 'T0', 'V0', ' ', IFPv)
                  call DVTwti (iErr, 'T1', IT1,  ' ', IFPv)
                  call DVTwts (iErr, 'T2', T2,   ' ', IFPv)
                  IT1 = IT1 + 1
                  do j = 1, NV
                     IV (j) = j * j * j * (NC + 1)
                  enddo
                  call DVSwtI
     O                (iErr, IRN,
     M                 kaDV, saDV,
     I                 IRT,  IV,   NV, KU, FMT, 'putI:9')
               endif
               write (IFP, 101) 9, iErr, kpx, kpn, kpu,
     $              _TRIML(FNM)
            else
CCC_  - read
               call UDTbni (ITEST, 'READ', ' ', IFP)
               iErr = MIN (0, iErr)
               DO
                  if (iErr.ne.0) goto 900
                  call DVSrdI
     O                (iErr, IV, IRN,
     M                 kaDV, saDV,
     I                 IRT,  NV, KU, FMT, 'getI')
                  if (iErr.eq.0) then
                     do j = 1, NV
                        write (IFP, *) j, IV (j)
                     enddo
                  endif
               ENDDO
 900           continue
            endif
CCC_  - report
            call UDTbni (ITEST, 'REP', ' ', IFP)
            call DVFrep (jedmy, kaDV, saDV, IFP, IFPv)
            iErr = 0
         enddo
      enddo
      call USJnta(BMSG, ':', 'DONE')
      call UDTbni (ITEST, BMSG, ' ', IFP)
      RETURN
      END
CCC_ & DVTEST_Finder
      subroutine DVTEST_Finder (iErr, ipA)
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(IN, integer) ipA (*)
      integer   kaDV (VIO_KPOLICY_MAX)
      character saDV*(VIO_SPOLICY_LEN)
      integer   ipI, ipO, ipE
      character CTYP*(16), FMT*(64)
      integer   NV,  KUfmt
      integer   IRL, IRT
c
      integer    LTv
      parameter (LTv = 16)
      character  TV (LTv)*8, Val (LTv)*32
      character  Att(LTv)*8, Expl(LTv)*32
      integer    NTv
      integer    j
c
      ipI = FPT(ipA)
      ipO = FPC(ipA)
      ipE = FPL(ipA)
c
      IRL = 0
      IRT = 0
c
      DO
         NTv = 0
         NTv = NTv + 1
         TV  (NTv) = 'T1'
         Val (NTv) = '---'
         NTv = NTv + 1
         TV  (NTv) = 'NONE'
         Val (NTv) = '---'
         call DVTrdg
     O       (iErr,
     O        NTv,  TV,    Val,   Att,   Expl,
     I        LTV,  ipI)
         IRL = IRL + 1
         write (ipE, *) 'FINDER: ', IRL, NTV, iErr
 301     format ('TV ', I3, 1x, A, ': ', A, '//')
         if (iErr.ne.0) goto 900
         do j = 1, MIN (LTV, NTV)
            write (ipE, 301) j, _TRIM(TV (j)), _TRIM(Val (j))
         enddo
         call DVSbnd
     O       (iErr,
     M        kaDV, saDV,
     O        CTYP, KUfmt, FMT, NV,
     I        IRT,  ' ',   ipI, ipO, ipE)
         if (iErr.ne.0) goto 900
      ENDDO
 900  continue
      write (ipE, *) 'FINDER: END', iErr
      iErr = 0
c
      RETURN
      END
CCC_ & DVTEST_OTW
      subroutine DVTEST_OTW (iErr, FPFX, ipL, ipV)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   ipL, ipV
      _INTENT(IN, character) FPFX*(*)
      integer    LIV
      parameter (LIV = 128)
      integer    IV (LIV)
      integer    j, N
c
      character  FNM*(OPT_FILENAME_MAX)
      integer    iMA (MAX_MPI_ATTR)
c
      iErr = 0
c
      call DMArst (iMA)
c
      N    = 8
      do j = 1, N
         IV (j) = j * 256 * 256 + j * 256 + j
      enddo
c
 101  format (A, A)
      write (FNM, 101) _TRIM(FPFX), 'OTWtest'
      call DVSwoI
     O    (iErr,
     I     IV,    N,
     I     ' ',   FNM, 'OTW test', ipL, ipV, iMA)
      RETURN
      END
#endif /* TEST_DVIOMS */
CCC_ + end test
CCC_* obsolete
CCC_ + begin
#if 0 /* obsolete */
CCC_ + end
#endif /* 0 obsolete */
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
