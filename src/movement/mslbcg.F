C movement/mslbcg.F --- IcIES/Movement/SSA/b matrix solver
C Maintainer:  SAITO Fuyuki
C Created: Sep 5 2012
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2016/08/19 14:29:56 fuyuki mslbcg.F>'
#define _FNAME 'movement/mslbcg.F'
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
#include "ologfm.h"   /* logging */
#include "oarpea.h"
#include "oarpkw.h"   /* operation id in arpeggio/kiwi */
#ifdef NO_MOVEMENT_H
#else
#  include "movement.h" /* movement definitions */
#endif
CCC_ + debug conditions
#ifndef   DEBUG_MSLBCG
C#  define DEBUG_MSLBCG 1
#  define DEBUG_MSLBCG 0
#endif
CCC_* MSLsvi  ## Solver iterator
      subroutine MSLsvi
     O    (iErr,
     M     X,    C,   W,  GW,
     O     Itr,  Efin,
     I     IMS,  PMS, QC, QV,
     I     ipCG, LCG,
     I     KXX,  WW,  MH, LH, LXK, ipKW, iMA, ipL)
CCC_ + Declaration
      implicit none
      _INTENT(OUT, integer)  iErr
      _INTENT(IN,  integer)  MH, LH, LCG, LXK
      _INTENT(OUT, integer)  Itr
      _INTENT(OUT, _REALSTD) Efin
      _INTENT(IN,  integer)  ipCG (LCG, CGS_MAX)
CCC_  - cgm work vector
      _INTENT(INOUT,_REALSTD) X  (LH, LXK, *)
CCC_  - solution id
      _INTENT(IN,   integer)  KXX
CCC_  - matrix work
      _INTENT(OUT,  _REALSTD) C  (*),  W  (*),  GW (*)
CCC_  - matrix coeff
      _INTENT(IN,   _REALSTD) PMS (*)
      _INTENT(IN,   _REALSTD) QC  (*),  QV (*)
      _INTENT(IN,   _REALSTD) WW  (*)
CCC_  - other properties
      _INTENT(IN,   integer)  ipKW (*), iMA (*)
      _INTENT(IN,   integer)  ipL
      _INTENT(IN,   integer)  IMS (*)
CCC_ + Body
      iErr   = 0
      RETURN
      END
CCC_* MSLsvm  ## Solver with old-style log
      subroutine MSLsvm
     O    (iErr,
     M     X,    C,    W,  GW,
     O     Itr,  Efin,
     I     IMS,  PMS,  QC, QV,
     I     ipCG, LCG,
     I     KXa,  KXb,  WW, MH, LH, LXK, ipKW, iMA, ipL)
CCC_ + Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  MH, LH, LCG, LXK
      _INTENT(OUT,  integer)  Itr
      _INTENT(OUT,  _REALSTD) Efin
      _INTENT(IN,   integer)  ipCG (LCG, CGS_MAX)
      _INTENT(INOUT,_REALSTD) X  (LH, LXK, *)
      _INTENT(IN,   integer)  KXa, KXb
      _INTENT(OUT,  _REALSTD) C  (*),  W  (*),  GW (*)
      _INTENT(IN,   _REALSTD) PMS (*)
      _INTENT(IN,   _REALSTD) QC  (*),  QV (*)
      _INTENT(IN,   _REALSTD) WW  (*)
      _INTENT(IN,   integer)  ipKW (*), iMA (*)
      _INTENT(IN,   integer)  ipL
      _INTENT(IN,   integer)  IMS (*)
CCC_  - interior
      integer  ItrMin, ItrMax
      _REALSTD Etol
CCC_ + Body
      ItrMax = IMS (IMS_ITRL)
      ItrMin = IMS (IMS_ITRLmin)
      ETOL   = PMS (PMS_TOLL)
c
      call MSLsvc
     O    (iErr,
     M     X,      C,      W,    GW,
     O     Itr,    Efin,
     I     ItrMin, ItrMax, Etol, PMS, QC, QV,
     I     ipCG,   LCG,
     I     KXa,    KXb,    WW,   MH,  LH, LXK, ipKW, iMA, ipL)
c
 101  format ('MSLSVC: iteration ', I10,   1x, I10,   1x, I10)
 102  format ('MSLSVC: tolerance ', E10.3, 1x, E10.3, 1x, E10.3)
      if      (COND_N(ipL)) then
         write (ipL, 101) Itr,  ItrMax, Itr
         write (ipL, 102) Efin, Etol,   Efin
      else if (COND_S(ipL)) then
         write (*,   101) Itr,  ItrMax, Itr
         write (*,   102) Efin, Etol,   Efin
      endif
      RETURN
      END
CCC_* MSLsvc  ## Solver core
      subroutine MSLsvc
     O    (iErr,
     M     X,      C,      W,    GW,
     O     Itr,    Efin,
     I     ItrMin, ItrMax, Etol, PMS, QC, QV,
     I     ipCG,   LCG,
     I     KXa,    KXb,    WW,   MH,  LH, LXK, ipKW, iMA, ipL)
CCC_ + Description
CC      X (:,KXa) initial guess
CC      Solution are (finally) stored in X(:,KXa)
CC      X(:,KXb) are used to keep best solution through the iteration
CCC_ + Declaration
      implicit none
      _INTENT(OUT, integer)  iErr
      _INTENT(IN,  integer)  MH, LH, LCG, LXK
      _INTENT(OUT, integer)  Itr
      _INTENT(OUT, _REALSTD) Efin
      _INTENT(IN,  integer)  ipCG (LCG, CGS_MAX)
CCC_  - cgm work vector
      _INTENT(INOUT,_REALSTD) X  (LH, LXK, *)
CCC_  - solution id
      _INTENT(IN,   integer)  KXa, KXb
CCC_  - matrix work
      _INTENT(OUT,  _REALSTD) C  (*),  W  (*),  GW (*)
CCC_  - matrix coeff
      _INTENT(IN,   _REALSTD) PMS (*)
      _INTENT(IN,   _REALSTD) QC  (*),  QV (*)
      _INTENT(IN,   _REALSTD) WW  (*)
CCC_  - other properties
      _INTENT(IN,   integer)  ipKW (*), iMA (*)
      _INTENT(IN,   integer)  ipL
      _INTENT(IN,   integer)  ItrMin, ItrMax
      _INTENT(IN,   _REALSTD) Etol
CCC_  - interior
      _REALSTD ak,   akden,  bk, bkden, bknum, bnrm, dxnrm
      _REALSTD xnrm, zm1nrm, znrm
      _REALSTD rnrm
      integer IR, IROOT, NR
      integer MXK
      _REALSTD Emin,   Emin2
      integer  jSmlst, jSml2
      _REALSTD EPS
      integer  jxts, jxt(0:1), jxxn, jxxo, jxxm
CCC_ + Body
      iErr   = 0
      EPS    = PMS (PMS_EPS)
c
      jxts   = 0
      jxt(jxts) = KXa
      jxt(1 - jxts) = KXb
CCC_  - preparation
      call DMAget (IR, iMA, 'IR')
      call DMAget (NR, iMA, 'NR')
      IROOT = 0
c
      Itr   = 0
      bkden = 0.0d0
      Efin  = Etol * 1.0d31
c
      jSmlst = 0
      jSml2  = 0
      Emin   = Efin * 1.0d31
      Emin2  = Emin
c
      MXK = VMSX_MAX
c
      jxxo = jxt(jxts)
      jxxn = jxt(jxts)
      jxxm = jxt(jxts)
CCC_   . [p] = 0, [pp] = 0
      call UV0stb (X, MH, LH, MXK, LXK, BCGW_P,  0.0d0)
      call UV0stb (X, MH, LH, MXK, LXK, BCGW_PP, 0.0d0)
CCC_   . [r] = M [x]
      call MSBxml
     M    (X,
     I     BCGW_R, jxxn,
     W     C,      W,
     I     PMS,    QC,   QV,   WW,
     I     iMA,    ipKW, ipCG, MH, LH, LXK, LCG)
CCC_   . [r] = -[r] + [b] = [b] - M [x]
      call UV0unb (X, MH, LH, MXK, LXK, BCGW_R,  BCGW_BB)
      call MSBinm (rnrm, X, BCGW_R, iMA, MH, LH, LXK)
c$$$      write (ipL, *) 'r0', rnrm
c$$$      if (rnrm.eq.0.0d0) return
      if (rnrm.eq.0.0d0) then
         Efin = 0.0d0
         jxxm = jxxn
         goto 900
      endif
CCC_   . [rr] = [r]
      call UV0cpb (X, MH, LH, MXK, LXK, BCGW_RR, BCGW_R)
      znrm = 1.0d0
CCC_   . solve M[z] = [b]
      call MSBsns
     M    (X,
     I     BCGW_Z, BCGW_BB,
     W     C,      W,
     I     PMS,    QC,   QV,   WW,
     I     iMA,    ipKW, ipCG, MH, LH, LXK, LCG)
CCC_   . b = |z|
      call MSBinm (bnrm, X, BCGW_Z, iMA, MH, LH, LXK)
CCC_   . solve M[z] = [r]
      call MSBsns
     M    (X,
     I     BCGW_Z, BCGW_R,
     W     C,      W,
     I     PMS,    QC,   QV,   WW,
     I     iMA,    ipKW, ipCG, MH, LH, LXK, LCG)
CCC_   . z = |z|
      call MSBinm (znrm, X, BCGW_Z, iMA, MH, LH, LXK)
c$$$      write (99, *) 'znrm', znrm, bnrm, rnrm
CCC_  - loop
 100  continue
      if (Itr.le.ItrMax) then
         if (Efin.eq.0.0d0) then
            iErr = 2
            Efin = Emin
            Itr  = jSmlst
            goto 900
         endif
         if (Efin.lt.Emin.and.Itr.ge.ItrMin) then
            Emin2  = Emin
            Emin   = Efin
            jSml2  = jSmlst
            jSmlst = Itr
            jxts = 1 - jxts
            jxxm = jxxn
            jxxo = jxxn
            jxxn = jxt(jxts)
         else
            jxxo = jxxn
         endif
         Itr = Itr + 1
CCC_   . current status
c$$$ 303     format ('MSLbcg[', I0, '] ', E16.9, 2I3)
c$$$         write (ipL, 303) Itr, Efin, jxxo, jxxn
#if       DEBUG_MSLBCG > 0
 301     format ('MSLbcg[', I0, '] ', E16.9)
         write (ipL, 301) Itr, Efin
         call flush (ipL)
#endif /* DEBUG_MSLBCG > 0 */
         zm1nrm = znrm
CCC_   . solve MT[zz] = [rr]
         call MSBsts
     M       (X,
     I        BCGW_ZZ,  BCGW_RR,
     W        C,    W,
     I        PMS,  QC,   QV,   WW,
     I        iMA,  ipKW, ipCG, MH, LH, LXK, LCG)
CCC_   . bk = [z],[rr]
         call MSBipN
     O       (bknum,
     W        GW,
     M        X,
     I        BCGW_B1, BCGW_Z, BCGW_RR,
     I        iMA, MH,   LH,   LXK, IROOT, IR, NR)
         if (Itr.eq.1) then
            bk = 0.0d0
         else
            bk = bknum / bkden
c$$$            write (ipL, *) 'bkden', bknum, bkden
         endif
CCC_   . [p] = bk * [p] + [z], [pp] = bk * [pp] + [zz]
         call UV0ueb (X, MH, LH, MXK, LXK, BCGW_P,  BCGW_Z,  bk)
         call UV0ueb (X, MH, LH, MXK, LXK, BCGW_PP, BCGW_ZZ, bk)
         bkden = bknum
CCC_   . [z] = M [p]
         call MSBxml
     M       (X,
     I        BCGW_Z, BCGW_P,
     W        C,      W,
     I        PMS,    QC,   QV,   WW,
     I        iMA,    ipKW, ipCG, MH, LH, LXK, LCG)
CCC_   . ak = [z],[pp]
         call MSBipN
     O       (akden,
     W        GW,
     M        X,
     I        BCGW_B1, BCGW_Z, BCGW_PP,
     I        iMA,     MH,     LH, LXK, IROOT, IR, NR)
         ak = bknum / akden
c$$$         write (*, *) 'akdenf', akden
c$$$         write (ipL, *) 'ak', ak, bknum, akden
CCC_   . [zz] = MT [pp]
         call MSBxmt
     M       (X,
     I        BCGW_ZZ, BCGW_PP,
     W        C,       W,
     I        PMS,     QC,   QV,   WW,
     I        iMA,     ipKW, ipCG, MH, LH, LXK, LCG)
CCC_   . [x] = [x] + ak [p]
CC       call UV0ufb (X, MH, LH, MXK, LXK, jxxn,    BCGW_P,  ak)
         call UV0nfb (X, MH, LH, MXK, LXK, jxxn, jxxo, BCGW_P, ak)
CCC_   . [r] = [r] - ak [z]
         call UV0ufb (X, MH, LH, MXK, LXK, BCGW_R,  BCGW_Z,  -ak)
CCC_   . [rr] = [rr] - ak [zz]
         call UV0ufb (X, MH, LH, MXK, LXK, BCGW_RR, BCGW_ZZ, -ak)
CCC_   . solve M[z] = [r]
         call MSBsns
     M       (X,
     I        BCGW_Z, BCGW_R,
     W        C,      W,
     I        PMS,    QC,   QV,   WW,
     I        iMA,    ipKW, ipCG, MH, LH, LXK, LCG)
CCC_   . z = |z|
         call MSBinm (znrm, X, BCGW_Z, iMA, MH, LH, LXK)
CCC_   . dx = |p|
         if (abs (zm1nrm - znrm).gt. EPS * znrm) then
            call MSBinm (dxnrm, X, BCGW_P, iMA, MH, LH, LXK)
            dxnrm = abs (ak) * dxnrm
            Efin  = znrm / abs (zm1nrm - znrm) * dxnrm
c$$$            write (ipL, *) 'efine 1', dxnrm, zm1nrm, znrm, Efin
         else
            Efin  = znrm / bnrm
c$$$            write (ipL, *) 'efine 2', bnrm, Efin
            goto 100
         endif
CCC_   . x = |x|
         call MSBinm (xnrm, X, jxxn, iMA, MH, LH, LXK)
CCC_   . loop end
         if (Efin .le. 0.5d0 * xnrm) then
            Efin = Efin / xnrm
c$$$            write (ipL, *) 'efine 3', xnrm, Efin
         else
            Efin = znrm / bnrm
c$$$            write (ipL, *) 'efine 4', bnrm, Efin
            goto 100
         endif
         if (Efin.gt.Etol) goto 100
         if (Itr.lt.ItrMin) goto 100
         jxxm = jxxn
      endif
CCC_  - fine
 900  continue
      if (Efin.gt.Etol) then
         iErr = 1
         Efin = Emin
         Itr  = jSmlst
      endif
c
      if (jxxm.ne.KXa) then
         call UV0cpb (X, MH, LH, MXK, LXK, KXa, jxxm)
      endif
      if (iErr.ne.0) then
         call DAtrcU (ipL, iErr, 'R', 'MSLSVC')
 101     format ('MSLSVC: iteration ', I10,   1x, I10,   1x, 2I10)
 102     format ('MSLSVC: tolerance ', E10.3, 1x, E10.3, 1x, 2E10.3)
         if      (COND_N(ipL)) then
            write (ipL, 101) Itr,  ItrMax, jSmlst, jSml2
            write (ipL, 102) Efin, Etol,   Emin,   Emin2
         else if (COND_S(ipL)) then
            write (*,   101) Itr,  ItrMax, jSmlst, jSml2
            write (*,   102) Efin, Etol,   Emin,   Emin2
         endif
      endif
      RETURN
      END
CCC_* MSLcbs  ## Solver core bicgstab
CCC_ + body
CCC_  - [r]   = b - A[x]
CCC_   . [r] = A[x]
CCC_   . [r] = [b] - [r]
CCC_  - [rr0] = [r]
CCC_  - [p]   = [r]
CCC_  - loop
CCC_  - a   = ([r],[rr0]) / (A[p],[rr0])
CCC_   . [t1] = A[p]
CCC_   . ([t1],[rr0])
CCC_   . ([r],[rr0])
CCC_   . a
CCC_  - [s] = [r] - a A[p]
CCC_   . [s] = [r] - a [t1]
CCC_  - w   = (A[s],[s]) / (A[s], A[s])
CCC_   . [t2] = A[s]
CCC_   . ([t2],[s])
CCC_   . ([t2],[t2])
CCC_  - [x] = [x] + a[p] + w[s]
CCC_  - [r(j+1)] = [s] - w A[s]
CCC_   . (r[j],[rr0]) before update of [r]
CCC_   . [r]
CCC_  - b   = ([r(j+1)],[rr0]) / (r[j],[rr0]) * (a/w)
CCC_   . ([r],[rr0])
CCC_   . b
CCC_  - [p] = [r(j+1)]+b([p]-w A[p])
CCC_   . [p] = [r]+b([p] - w [t1])
CCC_& MSLpms  ## Parameters initialization
      subroutine MSLpms
     O    (iErr,
     O     PMS,   IMS,
     I     CR,    ipP, ipC, ipL)
CCC_ + Declaration
      implicit none
CCC_  - Arguments
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,_REALSTD)  PMS (*)
      _INTENT(OUT,integer)   IMS (*)
      _INTENT(IN, character) CR*(*)
      _INTENT(IN, integer)   ipP, ipC, ipL
CCC_  - Configuration
      character  CROOT * (8)
      _REALSTD  Etol, EPS
      integer   ItrMin, ItrMax
      namelist /NISSAL/
     $     CROOT,
     $     ItrMin, ItrMax, Etol, EPS
CCC_  - interior
      integer jc
CCC_ + Body
      iErr = 0
CCC_  - Configuration
      jc = 0
 200  continue
      call UUrwnd (iErr, ipP)
c
 100  continue
c
      CROOT  = ' '
      ItrMin = 0
      ItrMax = 1024
c$$$      ItrMax = 1
c$$$      ItrMax = 100
      Etol   = 1.0d-12
c$$$      EPS    = 1.0d-9
      EPS    = 0.0d0
c
      READ  (ipP, NISSAL, IOSTAT = iErr)
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
         write (ipC, NISSAL, IOSTAT = iErr)
      endif
CCC_  - Packing
      PMS (PMS_TOLL)    = ETOL
      PMS (PMS_EPS)     = EPS
      IMS (IMS_ITRL)    = ItrMax
      IMS (IMS_ITRLmin) = ItrMin
c
      call DAtrcU (ipL, iErr, 'R', 'MSLPMS')
      RETURN
      END
CCC_& MSLBCG  ## Movement/SSA/b/solver announcement
      subroutine MSLBCG (STRA, STRB, IOP)
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
#ifdef TEST_MSLBCG
#  ifndef TEST_MSLBCG_SUB
#  define TEST_MSLBCG_SUB 1
#  endif
#endif
CCC_ @ MSLtst  ## test program
#ifdef TEST_MSLBCG
#include "ofnstd.h"
#include "odevid.h"
      program MSLtst
CCC_  - Test suites
CC::   SOURCES msbmos.F:TEST_MSBMOS_SUB=1 msfunc.F
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
         call MSLtestMain (iErr, ipA, iMA)
      endif
      if (iErr.eq.0) then
         call ACCrep (FPL(ipA), 0)
      endif
      call DevFin (iErr)
      STOP
      END
CCC_ & MSLtestMain  ## check main
      subroutine MSLtestMain (iErr, ipA, iMA)
CCC_  - Declaration
      implicit none
#include "odevva.h"
      _INTENT(OUT,integer)  iErr
      _INTENT(IN, integer)  ipA (*)
      _INTENT(IN, integer)  iMA (*)
CCC_   . Domain size limit
#ifndef   OPT_MSLBCG_LHP_MAX
#  define OPT_MSLBCG_LHP_MAX OPT_MOVEMENT_LHP_MAX
#endif
#ifndef   OPT_MSLBCG_LHG_MAX
#  define OPT_MSLBCG_LHG_MAX OPT_MOVEMENT_LHG_MAX
#endif
      integer    LHPref
      parameter (LHPref = OPT_MSLBCG_LHP_MAX)
      integer    LHGref
      parameter (LHGref = OPT_MSLBCG_LHG_MAX)
c
      integer    LCK
      parameter (LCK = 16)
CCC_   . Variable clusters
      _REALSTD   VMW  (LHPref * VMW_MAX)
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
      integer    IMS  (IMS_MAX)
c
      integer    LKW
      parameter (LKW = 128)
      _REALSTD   WW (LHPref * LKW)
      _REALSTD   CW (LHPref * LCK)
c
      integer    LW
      integer    LXK
CCC_   . Elements attributes
      integer    LIE
      parameter (LIE = (LHPref * 8))
      integer    IE   (LIE)
c
      integer    ipKW (IPKW_FULL_DECL)
CCC_   . clone
      integer    LCG
      parameter (LCG = KWCG_DECL(4))
      integer    ipCG (LCG, CGS_MAX)
CCC_   . global/private stencils
      integer    LTBL
      parameter (LTBL = LHPref)
      integer    kDTA (LTBL, 3)
CCC_   . Work
      _REALSTD   WG (LHGref, 3)
CCC_   . Domain
      character  CR*8
      data       CR /'ID'/
      integer icF
      integer MH,  LH,  MG,  LG
      integer NZ,  LZ,  KZ0
CCC_   . Log
      integer ipL, ipP, ipC, ipV
      integer IFPa (16)
CCC_   . dummy
      _REALSTD WZV (1)
      integer  jedmy
      integer  nxg, nyg
CCC_  - Body
      iErr = 0
c
      ipL  = FPL(ipA)
      ipP  = FPP(ipA)
      ipC  = FPC(ipA)
      ipV  = FPV(ipA)
      call AFUifp (IFPa, ipP, ipC, ipL, ipV)
c
      LW = LHPref * VMW_MAX
CCC_  - Arpeggio configuration
CCC_   . operatios
      if (iErr.eq.0) then
         if (iErr.eq.0) call AKPini (ipKW)
         if (iErr.eq.0) call MSBdec (iErr, ipKW, ipL)
      endif
CCC_   . table creation
      call ACCrgR (jedmy, icF, 0, CR, ipL)
      NXG = 0
      NYG = 0
      if (iErr.eq.0) then
         call AMHcns
     O       (iErr,
     W        VMW,
     O        MH,    LH,     MG,     LG,   WW,
     O        ipKW,  IE,
     I        NXG,   NYG,
     L        LW,    LHPref, LHGref, LKW,  LIE,
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
     I        WW,  IE,   ipKW,
     I        MH,  LH,
     I        icF, CR,  'C',  MOVEMENT_DV_CLS,  IFPa,  iMA)
      endif
CCC_    * call test core
      if (iErr.eq.0) then
         LXK = VMSX_MAX
         call MSLtestCore
     O       (iErr,
     O        IMS,  PMS,  VMI,  VMC,  VMID,
     O        VMSC, VMSV, VMSX,
     W        VMW,  WG,   CW,
     I        WW,
     I        MH,   LH,   LXK,  LHGref,
     I        CR,   ipCG, LCG,  icF,  ipKW, IE,   iMA,  ipA)
      endif
CCC_  - end
      RETURN
      END
#endif /* TEST_MSLBCG */
CCC_* [TEST/sub]
#if TEST_MSLBCG_SUB
CCC_ & MSLtestCore  ## check core
      subroutine MSLtestCore
     O    (iErr,
     O     IMS,  PMS,  VMI,  VMC,  VMID,
     O     VMSC, VMSV, VMSX,
     W     VMW,  WG,   CW,
     I     WW,
     I     MH,   LH,   LXK,  LHGref,
     I     CR,   ipCG, LCG,  icF,  ipKW, IE,  iMA, ipA)
CCC_  - Declaration
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   MH, LH, LXK, LHGref
      _INTENT(OUT,integer)   IMS (*)
      _INTENT(OUT,_REALSTD)  PMS (*)
      _INTENT(OUT,_REALSTD)  VMI  (LH, *)
      _INTENT(OUT,_REALSTD)  VMC  (LH, *)
      _INTENT(OUT,_REALSTD)  VMID (LH, *)
      _INTENT(OUT,_REALSTD)  VMSC (LH, *)
      _INTENT(OUT,_REALSTD)  VMSV (LH, *)
      _INTENT(OUT,_REALSTD)  VMSX (LH, LXK, *)
      _INTENT(OUT,_REALSTD)  VMW  (LH, *)
      _INTENT(OUT,_REALSTD)  WG (*)
      _INTENT(OUT,_REALSTD)  CW (*)
      _INTENT(IN, _REALSTD)  WW (LH, *)
      _INTENT(IN, character) CR*(*)
      _INTENT(IN, integer)   ipKW (*)
      _INTENT(IN, integer)   LCG
      _INTENT(IN, integer)   ipCG (*)
      _INTENT(IN, integer)   IE   (*)
      _INTENT(IN, integer)   icF
      _INTENT(IN, integer)   iMA  (*)
      _INTENT(IN, integer)   ipA (*)
CCC_   . Log
      integer ipL, ipP, ipC, ipV
      integer IFPa (16)
CCC_   . Variable
      integer   idGM (16)
      character CSW*(16)
c
      _REALSTD  T
c
      integer   ITR
      _REALSTD  Efin
c
      integer   kvx, jvx
      integer   KXa, KXb
c
      integer   NZ, LZ,  KZ0
CCC_  - Body
      iErr = 0
      ipL  = FPL(ipA)
      ipP  = FPP(ipA)
      ipC  = FPC(ipA)
      ipV  = FPV(ipA)
      call AFUifp (IFPa, ipP, ipC, ipL, ipV)
CCC_   . just for test
      NZ  = 0
      LZ  = 1
      KZ0 = 1
CCC_   . Variables
      CSW = 'C'
      if (iErr.eq.0) then
         call MSVgst
     O       (iErr, idGM,
     I        icF,  MH,  LH,
     I        CSW,  ' ', CR, IFPa, IE, iMA)
      endif
      if (iErr.eq.0) then
         call MIVgst
     O       (iErr, idGM,
     I        icF,  MH,  LH, NZ,   LZ,  KZ0,
     I        CSW,  ' ', CR, IFPa, IE,  iMA)
      endif
CCC_   . Parameters
      if (iErr.eq.0) then
         call MSLtestInitAll
     O       (iErr,
     W        VMW,  CW,   WG,
     O        IMS,  PMS,  VMI,  VMC,  VMID,
     O        VMSC, VMSV, VMSX,
     I        WW,
     I        MH,   LH,   LXK,  LHGref,
     I        CR,   IE,   ipKW, iMA, ipP, ipC, ipL)
      endif
CCC_   . Solver
CCC_    * initial guess
      KXa = BCGW_XX
      KXb = BCGW_XB
      if (iErr.eq.0) then
         call UV1uma (VMSX (1,1,KXa), VMSC, MH,LH, VMSX_UbS,VMSC_UbS_MF)
         call UV1uma (VMSX (1,1,KXa), VMSC, MH,LH, VMSX_UbN,VMSC_UbN_MF)
         call UV1uma (VMSX (1,1,KXa), VMSC, MH,LH, VMSX_VcW,VMSC_VcW_MF)
         call UV1uma (VMSX (1,1,KXa), VMSC, MH,LH, VMSX_VcE,VMSC_VcE_MF)
         call UV1uma (VMSX (1,1,KXa), VMSC, MH,LH, VMSX_PaE,VMSC_PaE_MF)
         call UV1uma (VMSX (1,1,KXa), VMSC, MH,LH, VMSX_PaW,VMSC_PaW_MF)
         call UV1uma (VMSX (1,1,KXa), VMSC, MH,LH, VMSX_PaN,VMSC_PaN_MF)
         call UV1uma (VMSX (1,1,KXa), VMSC, MH,LH, VMSX_PaS,VMSC_PaS_MF)
         call UV1uma (VMSX (1,1,KXa), VMSC, MH,LH, VMSX_QaE,VMSC_QaE_MF)
         call UV1uma (VMSX (1,1,KXa), VMSC, MH,LH, VMSX_QaW,VMSC_QaW_MF)
         call UV1uma (VMSX (1,1,KXa), VMSC, MH,LH, VMSX_QaN,VMSC_QaN_MF)
         call UV1uma (VMSX (1,1,KXa), VMSC, MH,LH, VMSX_QaS,VMSC_QaS_MF)
         call UV1uma (VMSX (1,1,KXa), VMSC, MH,LH, VMSX_RdA,VMSC_RdA_MF)
      endif
CCC_    * solve
      if (iErr.eq.0) then
         call UV0cpb (VMSX, MH, LH, LXK, LXK, BCGW_XH1, KXa)
c
         call MSLsvm
     O       (iErr,
     M        VMSX,   CW,    VMW,   WG,
     O        Itr,    Efin,
     I        IMS,    PMS,   VMSC,  VMSV,
     I        ipCG,   LCG,
     I        KXa,    KXb,   WW,    MH, LH, LXK, ipKW, iMA, ipL)
      endif
c
      T    = 0.0d0
      do jvx = 1, BCGW_MAX
         kvx = jvx
         call AFBptc
     O       (iErr,
     I        VMSX,
     I        kvx, idGM (VGRP_VMSX), 0, 0, T,  ' ',  ' ',  IE)
      enddo
CCC_   . magnitude
      if (iErr.eq.0) then
         call MSFvmg
     O       (VMW,
     W        CW,
     I        VMSX (1,1,KXa),     VMSC,      WW,
     I        VMSN_B3,  VMSN_B1,  VMSN_B2,
     I        VMSX_UbS, VMSX_VcW, VMSC_Da_MI,
     I        KWO_Lba,  KWO_Lca,  MH,      LH, ipKW, iMA, KWM_M)
         T    = 0.0d0
         call AFBptc
     O       (iErr,
     I        VMW,
     I        1, idGM (VGRP_VMSN), VMSN_B1,VMSN_B3, T,  ' ','vamp', IE)
      endif
CCC_   . final diag
      if (iErr.eq.0) then
         call MSBxml
     M       (VMSX,
     I        BCGW_XH1,   KXa,
     W        CW,   VMW,
     I        PMS,  VMSC, VMSV, WW,
     I        iMA,  ipKW, ipCG, MH, LH, VMSX_MAX, LCG)
         T    = 0.0d0
         call AFBptc
     O       (iErr,
     I        VMSX,
     I        BCGW_XH1, idGM (VGRP_VMSX), 0, 0, T,  ' ',  'fine',  IE)
      endif
CCC_   . normalize
      do jvx = 1, BCGW_MAX
         kvx = jvx
         T    = 1.0d0
         call UV0ulb (VMSX, MH, LH, LXK, LXK, kvx)
         call AFBptc
     O       (iErr,
     I        VMSX,
     I        kvx, idGM (VGRP_VMSX), 0, 0, T,  ' ',  'nmlz',  IE)
      enddo
CCC_   . matrix coefficients
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
     I        VMSC,
     I        1,  idGM (VGRP_VMSC), 0, 0, T,  ' ',  ' ',  IE)
      endif
      if (iErr.eq.0) then
         call AFBptc
     O       (iErr,
     I        VMSV,
     I        1,  idGM (VGRP_VMSV), 0, 0, T,  ' ',  ' ',  IE)
      endif
CCC_  - return
      RETURN
      END
CCC_ & MSLtestInitAll
      subroutine MSLtestInitAll
     O       (iErr,
     W        VMW,  CW,   WG,
     O        IMS,  PMS,  VMI,  VMC,  VMID,
     O        VMSC, VMSV, VMSX,
     I        WW,
     I        MH,   LH,   LXK,  LHGref,
     I        CR,   IE,   ipKW, iMA, ipP, ipC, ipL)
CCC_  - Declaration
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   MH, LH, LXK, LHGref
      _INTENT(OUT,_REALSTD)  VMI  (LH, *)
      _INTENT(OUT,_REALSTD)  VMID (LH, *)
      _INTENT(OUT,_REALSTD)  VMC  (LH, *)
      _INTENT(OUT,_REALSTD)  VMSC (LH, *)
      _INTENT(OUT,_REALSTD)  VMSV (LH, *)
      _INTENT(OUT,_REALSTD)  VMSX (LH, LXK, *)
      _INTENT(OUT,_REALSTD)  PMS (*)
      _INTENT(OUT,integer)   IMS (*)
c
      _INTENT(OUT,_REALSTD)  VMW (*)
      _INTENT(OUT,_REALSTD)  WG  (*)
      _INTENT(OUT,_REALSTD)  CW  (*)
c
      _INTENT(IN, _REALSTD)  WW (LH, *)
      _INTENT(IN, character) CR*(*)
      _INTENT(IN, integer)   ipKW (*)
      _INTENT(IN, integer)   IE   (*)
      _INTENT(IN, integer)   iMA  (*)
      _INTENT(IN, integer)   ipP, ipC, ipL
CCC_  - Body
      iErr = 0
      if (iErr.eq.0) then
         call MSbpms
     O       (iErr,
     O        PMS,
     I        CR,    ipP, ipC, ipL)
      endif
      if (iErr.eq.0) then
         call MSLpms
     O       (iErr,
     O        PMS,   IMS,
     I        CR,    ipP, ipC, ipL)
      endif
      if (iErr.eq.0) then
         call MUTstp
     O       (iErr,
     W        VMW,  CW,  WG,
     O        VMSX, VMI, VMC, VMSV,   VMID,
     I        PMS,
     I        WW,   IE,  ipKW,   iMA,
     L        MH,   LH,  LXK, LHGref, CR,   ipP,  ipC, ipL)
      endif
      if (iErr.eq.0) then
         call MSSgca
     O       (iErr,
     M        VMC,  VMW,  CW,
     I        WW,   ipKW, iMA, MH, LH)
      endif
      if (iErr.eq.0) then
         call MSSbcf
     O       (iErr,
     M        VMSC, CW,  VMW,
     I        VMI,  VMC, VMSV, WW,  ipKW, iMA, MH, LH)
      endif
      call MSSxcr
     O    (iErr,
     M     VMSX,
     I     VMC, VMSC, BCGW_XX, MH, LH, LXK)
      call MSSxms
     O    (iErr,
     M     VMSX,
     I     VMSC,      BCGW_XX, MH, LH, LXK)
      if (iErr.eq.0) then
         call MSUbst
     O       (iErr,
     M        VMSX, VMW,  CW,
     I        PMS,  VMI,  VMC,  VMSC, VMID,
     I        BCGW_BB,
     I        WW,   ipKW, iMA, MH,   LH,   LXK)
      endif
CCC_  - return
      RETURN
      END
#endif /* TEST_MSLBCG_SUB */
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
