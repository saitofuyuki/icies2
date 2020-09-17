C movement/msbakw.F --- IcIES/Movement/SSA/b kiwi
C Maintainer:  SAITO Fuyuki
C Created: Jan 3 2012
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2020/09/17 08:46:45 fuyuki msbakw.F>'
#define _FNAME 'movement/msbakw.F'
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
#ifdef NO_MOVEMENT_H
#else
#  include "movement.h" /* movement definitions */
#endif
#ifndef   TEST_MSBAKW
#  define TEST_MSBAKW 0
#endif

#if 0 /* Pending; Meta comment */
CCC_ + Work area
#ifndef   OPT_MSBAKW_LHP_MAX
#  define OPT_MSBAKW_LHP_MAX OPT_MOVEMENT_LHP_MAX
#endif
CCC_ + Clone group index
#define CGV_Ub 1 /* U:b */
#define CGV_Vc 2 /* V:c */
#define CGV_Da 3 /* dU/dx:a dV/dy:a */
#define CGV_Dd 4 /* dU/dy:d dV/dx:d */
#define CGV_MAX 4
CCC_& MSBprp  ## SSA matrix generation suite (u to dudx)
      subroutine MSBprp
     O    (iErr,
     M     VMS,
     W     CW,
     I     WO,    WA,
     I     MH,    LH,
     I     ipCG,  LCG,  ipKW,  IE,     iMA,    ipL)
CCC_ + Description
CC     input U:b V:c
CC     b     La:b [Gxb:a] U:b
CC           Ld:b [Gyb:d] U:b
CC           La:b [Gyc:a] V:c
CC           Ld:b [Gxc:d] V:c
CC     c     La:c [Gxb:a] U:b
CC           Ld:c [Gyb:d] U:b
CC           La:c [Gyc:a] V:c
CC           Ld:c [Gxc:d] V:c
CCC_ + Declaration
      implicit none
      integer    LVS
      parameter (LVS = VMS_MAX)
c
      _INTENT(OUT,integer)    iErr
      _INTENT(IN, integer)    MH, LH, LCG
c
      _INTENT(INOUT,_REALSTD) VMS (LH, LVS)
      _INTENT(OUT,  _REALSTD) CW (*)
c
      _INTENT(IN, _REALSTD) WO  (*), WA (*)
      _INTENT(IN, integer)  ipCG (LCG, 4)
      _INTENT(IN, integer)  ipKW (*), IE (*), iMA (*)
      _INTENT(IN, integer)  ipL
c
      integer MO, LO
      integer kp
CCC_ + Body
      iErr = 0
CCC_  * clone Ub
      MO   = 1
      LO   = 1
      call AKCgux
     O    (CW,
     I     VMS,  MH,    LH,  MO,  LO, VMS_Ub,
     I     iMA,  ipCG (1, CGV_Ub))
CCC_  * dU/dx b:a
      call AKBogx
     M    (VMS,
     I     CW,   WO,  WA,
     I     MH,   LH,  MO,   LO,  VMS_Uxa, VMS_Ub,
     I     ipKW, iMA, 1,    ipCG (1, CGV_Ub))
CCC_  * dU/dy b:d
      call AKBogx
     M    (VMS,
     I     CW,   WO,  WA,
     I     MH,   LH,  MO,   LO,  VMS_Uyd, VMS_Ub,
     I     ipKW, iMA, 2,    ipCG (1, CGV_Ub))
CCC_  * clone Vc
      MO   = 1
      LO   = 1
      call AKCgux
     O    (CW,
     I     VMS,  MH,    LH,  MO,  LO, VMS_Vc,
     I     iMA,  ipCG (1, CGV_Vc))
CCC_  * dV/dy c:a
      call AKBogx
     M    (VMS,
     I     CW,   WO,  WA,
     I     MH,   LH,  MO,   LO,  VMS_Vya, VMS_Vc,
     I     ipKW, iMA, 1,    ipCG (1, CGV_Vc))
CCC_  * dV/dx c:d
      call AKBogx
     M    (VMS,
     I     CW,   WO,  WA,
     I     MH,   LH,  MO,   LO,  VMS_Vxd, VMS_Vc,
     I     ipKW, iMA, 2,    ipCG (1, CGV_Vc))
CCC_  * clone [dUV]:a
      MO   = 2
      LO   = 2
      call AKCgux
     O    (CW,
     I     VMS,  MH,    LH,  MO,  LO, VMS_Uxa,
     I     iMA,  ipCG (1, CGV_Da))
CCC_  * dU/dx a:b dV/dy a:b
      call AKBogx
     M    (VMS,
     I     CW,   WO,  WA,
     I     MH,   LH,  MO,   LO,  VMS_Uxb, VMS_Uxa,
     I     ipKW, iMA, 1,    ipCG (1, CGV_Da))
CCC_  * dU/dx a:c dV/dy a:c
      call AKBogx
     M    (VMS,
     I     CW,   WO,  WA,
     I     MH,   LH,  MO,   LO,  VMS_Uxc, VMS_Uxa,
     I     ipKW, iMA, 2,    ipCG (1, CGV_Da))
CCC_  * clone [dUV]:d
      MO   = 2
      LO   = 2
      call AKCgux
     O    (CW,
     I     VMS,  MH,    LH,  MO,  LO, VMS_Uyd,
     I     iMA,  ipCG (1, CGV_Dd))
CCC_  * dU/dy d:b dV/dx d:b
      call AKBogx
     M    (VMS,
     I     CW,   WO,  WA,
     I     MH,   LH,  MO,   LO,  VMS_Uyb, VMS_Uyd,
     I     ipKW, iMA, 1,    ipCG (1, CGV_Da))
CCC_  * dU/dy d:c dV/dx d:c
      call AKBogx
     M    (VMS,
     I     CW,   WO,  WA,
     I     MH,   LH,  MO,   LO,  VMS_Uyc, VMS_Uyd,
     I     ipKW, iMA, 2,    ipCG (1, CGV_Da))
CCC_  * effective strain rate square:[bc]
      call MSFess
     M    (VMS,
     I     VMS_Eb,  VMS_Uxb, VMS_Uyb, VMS_Vxb, VMS_Vyb, MH, LH)
      call MSFess
     M    (VMS,
     I     VMS_Ec,  VMS_Uxc, VMS_Uyc, VMS_Vxc, VMS_Vyc, MH, LH)
      RETURN
      END
CCC_* MSBcgr  ## Movement/SSA/b clone gloup declaration
      subroutine MSBcgr
     O    (iErr,
     O     ipCG,
     I     LCG,   LH,     ipKW,  IE,  IFP)
CCC_ + Declaration
      implicit none
      _INTENT(OUT,  integer) iErr
      _INTENT(IN,   integer) LCG, LH
      _INTENT(OUT,  integer) ipCG (LCG, 4)
      _INTENT(IN,   integer) ipKW (*), IE (*), IFP
c
      integer    kv
      integer    LTBL
      parameter (LTBL = 16)
      integer kDSP (LTBL), kTYP (LTBL), kABL (LTBL)
CCC_ + Body
      iErr = 0
      kv   = 0
CCC_  * group Ub
      if (iErr.eq.0) then
         kv = CGV_Ub
         call AKCgrs (iErr, ipCG (1, kv), LCG)
         call AKCgad (iErr, ipCG (1, kv), KWO_GXba,  KWM_M, LCG)
         call AKCgad (iErr, ipCG (1, kv), KWO_GYbd,  KWM_M, LCG)
         call AKCgsb
     O       (iErr, ipCG (1, kv),  KDSP, KTYP, KABL,
     I        LCG,  LTBL,  LH,   ipKW, IE,   IFP)
      endif
CCC_  * group Vc
      if (iErr.eq.0) then
         kv = CGV_Vc
         call AKCgrs (iErr, ipCG (1, kv), LCG)
         call AKCgad (iErr, ipCG (1, kv), KWO_GYca,  KWM_M, LCG)
         call AKCgad (iErr, ipCG (1, kv), KWO_GXcd,  KWM_M, LCG)
         call AKCgsb
     O       (iErr, ipCG (1, kv),  KDSP, KTYP, KABL,
     I        LCG,  LTBL,  LH,   ipKW, IE,   IFP)
      endif
CCC_  * group Da
      if (iErr.eq.0) then
         kv = CGV_Da
         call AKCgrs (iErr, ipCG (1, kv), LCG)
         call AKCgad (iErr, ipCG (1, kv), KWO_Lab,  KWM_M, LCG)
         call AKCgad (iErr, ipCG (1, kv), KWO_Lac,  KWM_M, LCG)
         call AKCgsb
     O       (iErr, ipCG (1, kv),  KDSP, KTYP, KABL,
     I        LCG,  LTBL,  LH,   ipKW, IE,   IFP)
      endif
CCC_  * group Dd
      if (iErr.eq.0) then
         kv = CGV_Dd
         call AKCgrs (iErr, ipCG (1, kv), LCG)
         call AKCgad (iErr, ipCG (1, kv), KWO_Ldb,  KWM_M, LCG)
         call AKCgad (iErr, ipCG (1, kv), KWO_Ldc,  KWM_M, LCG)
         call AKCgsb
     O       (iErr, ipCG (1, kv),  KDSP, KTYP, KABL,
     I        LCG,  LTBL,  LH,   ipKW, IE,   IFP)
      endif
c
      call DAtrcU (IFP, iErr, 'R', 'MSBCGR')
      RETURN
      END
CCC_* MSBdec  ## Movement/SSA/b operator declaration
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
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_GXab, KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_GYac, KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_GXdc, KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_GYdb, KWM_BOTH, IFP)
c
      RETURN
      END
#endif /* Meta comment */
CCC_@ MSBTST  ## Movemeent/SSA/b test program
#if TEST_MSBAKW
#include "ofnstd.h"
#include "odevid.h"  /* MPI table */
      program MSBTST
CCC_ + Test suites
CC::   SOURCES msfunc.F
CCC_ + Declaration
      implicit none
      integer iErr
      integer ipA (LOG_CHANNEL_MAX)
      integer iMA (MAX_MPI_ATTR)
CCC_ + Body
      call DDcapo
     O    (iErr,
     I     2, ' ', 'O', _FNAME, -1)
      if (iErr.eq.0) then
         call DLCmng (ipA, 't')
         call ACMrgU (ipA)
         call DMAtma (iMA)
CC         call MIBKtestMain (iErr, ipA, iMA)
         call ACMrep (0)
      endif
      call DevFin (iErr)
      STOP
      END
#endif /* TEST_MSBAKW */
