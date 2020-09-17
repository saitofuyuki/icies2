C movement/mmsbcg.F --- IcIES/Movement/update thickness (symmetric/kiwi)
C Maintainer:  SAITO Fuyuki
C Created: Oct 26 2011
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2020/09/15 12:00:51 fuyuki mmsbcg.F>'
#define _FNAME 'movement/mmsbcg.F'
#define _REV   'Snoopy0.9'
CCC_! MANIFESTO
C
C Copyright (C) 2011--2020
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
#include "olimit.h"   /* huge value */
#include "movement.h" /* movement definitions */
#include "ologfm.h"   /* logging */
CCC_ + module choice
#ifndef MMXOMS_IPR
#  define MMXOMS_IPR MMXipN
c$$$#  define MMXOMS_IPR MMXipK
c$$$#  define MMXOMS_IPR MMXipG
#endif
CCC_& MMBcgr  ## clone gloup declaration
      subroutine MMBcgr
     O    (iErr,
     O     ipCG,
     W     kDTA,
     I     LTBL, LCG, LHP, LCK, ipKW, IE, IFP)
CCC_ + Declaration
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(IN, integer) LCG, LHP, LCK, LTBL
      _INTENT(OUT,integer) kDTA  (LTBL, 3)
      _INTENT(OUT,integer) ipCG  (LCG, *)
      _INTENT(IN, integer) ipKW  (*), IE (*), IFP
CCC_ + Body
      iErr = 0
c
      if (iErr.eq.0) then
         call MMXcgs
     O       (iErr,
     O        ipCG,
     W        kDTA,
     I        LTBL, LCG, LHP, LCK, ipKW, IE, IFP)
      endif
c
      call DAtrcU (IFP, iErr, 'R', 'MMBCGR')
      RETURN
      END
CCC_& MMSbuc  ## Movement/Update biconjugate gradient method solver branch
      subroutine MMSbuc
     O    (iErr,
     M     X,      C,     GW,   VW,
     O     Itr,    Efin,
     I     ItrMax, Etol,  EPS,  MTYP,
     I     QM,     F0,
     I     ipCG,   LCG,
     I     WW,     MH,    LH, ipKW, KSglb, IE, iMA, ipL)
CCC_ + Description
CC      X (:,VXH) initial guess
CCC_ + Declaration
      implicit none
      _INTENT(OUT, integer)  iErr
      _INTENT(IN,  integer)  MH, LH, LCG
      _INTENT(OUT, integer)  Itr
      _INTENT(IN,  integer)  ItrMax
      _INTENT(IN,  integer)  MTYP
      _INTENT(OUT, _REALSTD) Efin
      _INTENT(IN,  _REALSTD) Etol,  EPS
      _INTENT(IN,  integer)  ipCG (LCG, *)
CCC_  - cgm work vector
      _INTENT(INOUT,_REALSTD) X (LH, *)
CCC_  - matrix coeff
      _INTENT(IN,   _REALSTD) QM (LH, *), F0
CCC_  - matrix work
      _INTENT(OUT,  _REALSTD) VW (*)
      _INTENT(OUT,  _REALSTD) C  (*),  GW (*)
      _INTENT(IN,   _REALSTD) WW (*)
      _INTENT(IN,   integer)  KSglb (*)
      _INTENT(IN,   integer)  ipKW (*), IE (*), iMA (*)
      _INTENT(IN,   integer)  ipL
CCC_  - interior
      _REALSTD Emin
      integer  ItrMin
      integer  ItrEM
      integer  jimin, jimax
      _REALSTD tetol
c$$$      _REALSTD F0Z
c$$$      integer jp
      integer jx
CCC_ + Body
      iErr   = 0 * ipL
      ItrMin = 0
 101  format ('MMSBUC: ', E12.5, 1x, E12.5, 1x, I5)
CCC_  - loop (twice if unconverged)
      jimin = ItrMin
      jimax = ItrMax
      tetol = Etol
      DO jx = 1, 2
         if      (MTYP .eq. MMXSW_UP1) then
            call MMBslu
     O          (iErr,
     M           X,      C,      GW,    VW,
     O           Itr,    Efin,   ItrEM, Emin,
     I           jimin,  jimax,  tetol, EPS,
     I           QM,     F0,
     I           ipCG,   LCG,
     I           WW,     MH,    LH, ipKW, KSglb, IE, iMA, ipL)
         else if (MTYP .eq. MMXSW_UPD) then
            call MMBslz
     O          (iErr,
     M           X,      C,      GW,    VW,
     O           Itr,    Efin,   ItrEM, Emin,
     I           jimin,  jimax,  tetol, EPS,
     I           QM,     F0,
     I           ipCG,   LCG,
     I           WW,     MH,    LH, ipKW, KSglb, IE, iMA, ipL)
         else if (MTYP .eq. MMXSW_UPE) then
            call MMBsly
     O          (iErr,
     M           X,      C,      GW,    VW,
     O           Itr,    Efin,   ItrEM, Emin,
     I           jimin,  jimax,  tetol, EPS,
     I           QM,     F0,
     I           ipCG,   LCG,
     I           WW,     MH,    LH, ipKW, KSglb, IE, iMA, ipL)
         else if (MTYP .eq. MMXSW_DVB
     $           .or. MTYP .eq. MMXSW_ZEV
     $           .or. MTYP .eq. MMXSW_DE
     $           .or. MTYP .eq. MMXSW_D00) then
            call MMBsld
     O          (iErr,
     M           X,      C,      GW,    VW,
     O           Itr,    Efin,   ItrEM, Emin,
     I           jimin,  jimax,  tetol, EPS,
     I           QM,     F0,
     I           ipCG,   LCG,
     I           WW,     MH,    LH, ipKW, KSglb, IE, iMA, ipL)
         else if (MTYP.eq. MMXSW_CIPaxP
     $           .or. MTYP.eq. MMXSW_CIPaxL) then
            call MMBslh
     O          (iErr,
     M           X,      C,      GW,    VW,
     O           Itr,    Efin,   ItrEM, Emin,
     I           jimin,  jimax,  tetol, EPS,
     I           QM,     F0,
     I           ipCG,   LCG,
     I           WW,     MH,    LH, ipKW, KSglb, IE, iMA, ipL)
         else
            call MMBslh
     O          (iErr,
     M           X,      C,      GW,    VW,
     O           Itr,    Efin,   ItrEM, Emin,
     I           jimin,  jimax,  tetol, EPS,
     I           QM,     F0,
     I           ipCG,   LCG,
     I           WW,     MH,    LH, ipKW, KSglb, IE, iMA, ipL)
         endif
CCC_   . break if get solution
         if (iErr.eq.0) then
            if (jx.gt.1) then
               if (COND_N(ipL)) then
                  write (ipL, 101) Efin, Emin, ItrEM
               else if (COND_S(ipL)) then
                  write (*,   101) Efin, Emin, ItrEM
               endif
            endif
            goto 100
         endif
CCC_   . repeat to get minimum
         if (COND_N(ipL)) then
            write (ipL, 101) Etol, Emin, ItrEM
         else if (COND_S(ipL)) then
            write (*,   101) Etol, Emin, ItrEM
         endif
         iErr = 0
         call UV0cpa (X, MH, LH, BCGW_XX, BCGW_XH1)
         jimin = 0
         jimax = ItrEM
         tetol = Emin
      enddo
CCC_  - loop end
 100  continue
      RETURN
      END
CCC_& MMScdh  ## Movement/Update dH/dt correction or explicit solver
      subroutine MMScdh
     O    (iErr,
     M     X,      C,     VW,
     I     MTYP,
     I     QM,     F0,
     I     ipCG,   LCG,
     I     WW,     MH,    LH, ipKW, iMA, ipL)
CCC_ + Description
CC      X (:,VXH) initial guess
CCC_ + Declaration
      implicit none
      _INTENT(OUT, integer)  iErr
      _INTENT(IN,  integer)  MH, LH, LCG
      _INTENT(IN,  integer)  MTYP
      _INTENT(IN,  integer)  ipCG (LCG, *)
CCC_  - cgm work vector
      _INTENT(INOUT,_REALSTD) X (LH, *)
CCC_  - matrix coeff
      _INTENT(IN,   _REALSTD) QM (LH, *), F0
CCC_  - matrix work
      _INTENT(OUT,  _REALSTD) VW (*)
      _INTENT(OUT,  _REALSTD) C  (*)
      _INTENT(IN,   _REALSTD) WW (*)
      _INTENT(IN,   integer)  ipKW (*), iMA (*)
      _INTENT(IN,   integer)  ipL
CCC_  - interior
      _REALSTD F0Z
      integer jp
CCC_ + Body
      iErr   = 0 * ipL
CCC_  - for dHdt correction
      if (iErr.eq.0) then
         F0Z = 0.0d0
         if      (MTYP.eq. MMXSW_UP1) then
            call MMUmns
     M          (X,
     I           BCGW_XH2,   BCGW_XX,
     W           C,    VW,
     I           F0Z,  QM,   WW,
     I           iMA,  ipKW, ipCG, MH, LH, LCG)
            do jp = 1, MH
               X (jp, BCGW_XH2) = - X (jp, BCGW_XH2) + QM (jp, VMQU_BB)
            enddo
         else if (MTYP.eq. MMXSW_UPD) then
            call MMZmns
     M          (X,
     I           BCGW_XH2,   BCGW_XX,
     W           C,    VW,
     I           F0Z,  QM,   WW,
     I           iMA,  ipKW, ipCG, MH, LH, LCG)
            do jp = 1, MH
               X (jp, BCGW_XH2) = - X (jp, BCGW_XH2) + QM (jp, VMQZ_BB)
            enddo
         else if (MTYP.eq. MMXSW_UPE) then
            call MMYmns
     M          (X,
     I           BCGW_XH2,   BCGW_XX,
     W           C,    VW,
     I           F0Z,  QM,   WW,
     I           iMA,  ipKW, ipCG, MH, LH, LCG)
            do jp = 1, MH
               X (jp, BCGW_XH2) = - X (jp, BCGW_XH2) + QM (jp, VMQH_BB)
            enddo
         else if (MTYP.eq.MMXSW_DVB
     $           .or. MTYP.eq.MMXSW_ZEV
     $           .or. MTYP.eq.MMXSW_DE
     $           .or. MTYP.eq.MMXSW_D00) then
            call MMDmns
     M          (X,
     I           BCGW_XH2,   BCGW_XX,
     W           C,    VW,
     I           F0Z,  QM,   WW,
     I           iMA,  ipKW, ipCG, MH, LH, LCG)
            do jp = 1, MH
c$$$               write (*, *) 'XH2',jp, X (jp, BCGW_XH2),QM (jp, VMQ_BB)
               X (jp, BCGW_XH2) = - X (jp, BCGW_XH2) + QM (jp, VMQ_BB)
            enddo
         else if (MTYP.eq. MMXSW_CIPaxP
     $           .or. MTYP.eq. MMXSW_CIPaxL) then
            call MMHdht
     M          (X,
     I           BCGW_XH2,   BCGW_XX,
     W           C,    VW,
     I           F0Z,  QM,   WW,
     I           iMA,  ipKW, ipCG, MH, LH, LCG)
         else
            call MMHdht
     M          (X,
     I           BCGW_XH2,   BCGW_XX,
     W           C,    VW,
     I           F0Z,  QM,   WW,
     I           iMA,  ipKW, ipCG, MH, LH, LCG)
         endif
      endif
      RETURN
      END
CCC_& MMBsld  ## Movement/Update biconjugate gradient method solver core (D/E)
      subroutine MMBsld
     O    (iErr,
     M     X,      C,      GW,    VW,
     O     Itr,    Efin,   ItrEM, Emin,
     I     ItrMin, ItrMax, Etol,  EPS,
     I     QM,     F0,
     I     ipCG,   LCG,
     I     WW,     MH,    LH, ipKW, KSglb, IE, iMA, ipL)
CCC_ + Description
CC      X (:,VXH) initial guess
CCC_ + Debug
c$$$#define DEBUG_D
CCC_ + Declaration
      implicit none
      _INTENT(OUT, integer)  iErr
      _INTENT(IN,  integer)  MH, LH, LCG
      _INTENT(OUT, integer)  Itr,    ItrEM
      _INTENT(OUT, _REALSTD) Efin,   Emin
      _INTENT(IN,  integer)  ItrMin, ItrMax
      _INTENT(IN,  _REALSTD) Etol,  EPS
      _INTENT(IN,  integer)  ipCG (LCG, *)
CCC_  - cgm work vector
      _INTENT(INOUT,_REALSTD) X (*)
CCC_  - matrix coeff
      _INTENT(IN,   _REALSTD) QM (*), F0
CCC_  - matrix work
      _INTENT(OUT,  _REALSTD) VW (*)
      _INTENT(OUT,  _REALSTD) C  (*),  GW (*)
      _INTENT(IN,   _REALSTD) WW (*)
      _INTENT(IN,   integer)  KSglb (*)
      _INTENT(IN,   integer)  ipKW (*), IE (*), iMA (*)
      _INTENT(IN,   integer)  ipL
CCC_  - interior
      _REALSTD ak,   akden,  bk,  bkden, bknum, bnrm, dxnrm
      _REALSTD xnrm, zm1nrm, znrm
      _REALSTD rnrm
      integer NG
      integer IR, IROOT, NR
CCC_ + Body
CC       Dummy statements
      iErr  = 0 * ipL
      NG = EA_NG(IE)
c$$$      call AETget (iErr, NG,   IE, 'NG')
      call DMAget (IR, iMA, 'IR')
      call DMAget (NR, iMA, 'NR')
      IROOT = 0
c
      Itr   = 0
      ItrEM = 0
      Efin  = 0.0d0
      Emin  = _DBLE_HUGE
      bkden = 0.0d0
CCC_  - [p] = 0, [pp] = 0
      call UV0sta (X, MH, LH, BCGW_P,  0.0d0)
      call UV0sta (X, MH, LH, BCGW_PP, 0.0d0)
CCC_  - [r] = M [x]
      call MMDmns
     M    (X,
     I     BCGW_R, BCGW_XX,
     W     C,      VW,
     I     F0,     QM,   WW,
     I     iMA,    ipKW, ipCG, MH, LH, LCG)
CCC_  - [r] = -[r] + [b]
      call UV0una (X, MH, LH, BCGW_R, BCGW_BB)
      call MMXinm (rnrm, GW, X, BCGW_R, iMA, IE, MH, LH)
c$$$      call UV0d2a (X, MH, LH, BCGW_R, BCGW_XX, 'RX0', 0, 97)
#ifdef DEBUG_D
      write (*, *) 'r0', rnrm
#endif
CCC_  - [rr] = [r]
      call UV0cpa (X, MH, LH, BCGW_RR, BCGW_R)
      znrm = 1.0d0
CCC_  - solve M[z] = [b]
      call MMDsns
     M    (X,
     I     BCGW_Z, BCGW_BB,
     W     C,      VW,
     I     F0,     QM,   WW,
     I     iMA,    ipKW, ipCG, MH, LH, LCG)
CCC_  - b = |z|
      call MMXinm (bnrm, GW, X, BCGW_Z, iMA, IE, MH, LH)
CCC_  - solve M[z] = [r]
      call MMDsns
     M    (X,
     I     BCGW_Z, BCGW_R,
     W     C,      VW,
     I     F0,     QM,   WW,
     I     iMA,    ipKW, ipCG, MH, LH, LCG)
CCC_  - z = |z|
      call MMXinm (znrm, GW, X, BCGW_Z, iMA, IE, MH, LH)
#ifdef DEBUG_D
      write (*, *) 'z0', znrm
#endif
CCC_  - loop
 100  continue
      if (Itr.le.ItrMax) then
         Itr = Itr + 1
         zm1nrm = znrm
CCC_  - solve MT[zz] = [rr]
         call MMDsts
     M       (X,
     I        BCGW_ZZ, BCGW_RR,
     W        C,       VW,
     I        F0,      QM,   WW,
     I        iMA,     ipKW, ipCG, MH, LH, LCG)
CCC_  - bk = [z],[rr]
         call MMXOMS_IPR
     $       (bknum, GW, X, BCGW_B1, BCGW_Z, BCGW_RR,
     $        iMA, KSglb, IE, MH, LH, NG, IR, IROOT, NR)
         if (Itr.eq.1) then
            bk = 0.0d0
         else
            bk = bknum / bkden
#ifdef DEBUG_D
            write (*, *) 'bkden', Itr, bkden
#endif
         endif
CCC_  - [p] = bk * [p] + [z], [pp] = bk * [pp] + [zz]
         call UV0uea (X, MH, LH, BCGW_P,  BCGW_Z,  bk)
         call UV0uea (X, MH, LH, BCGW_PP, BCGW_ZZ, bk)
         bkden = bknum
CCC_  - [z] = M [p]
         call MMDmns
     M       (X,
     I        BCGW_Z, BCGW_P,
     W        C,      VW,
     I        F0,     QM,   WW,
     I        iMA,    ipKW, ipCG, MH, LH, LCG)
CCC_  - ak = [z],[pp]
         call MMXOMS_IPR
     $       (akden, GW, X, BCGW_B1, BCGW_Z, BCGW_PP,
     $        iMA, KSglb, IE, MH, LH, NG, IR, IROOT, NR)
         ak = bknum / akden
#ifdef DEBUG_D
         write (*, *) 'akden', Itr, akden
#endif
CCC_  - [zz] = MT [pp]
         call MMDmts
     M       (X,
     I        BCGW_ZZ, BCGW_PP,
     W        C,       VW,
     I        F0,      QM,   WW,
     I        iMA,     ipKW, ipCG, MH, LH, LCG)
CCC_  - [x] = [x] + ak [p]
c$$$         call UV0d2a (X, MH, LH, BCGW_XX, BCGW_P, 'XP', itr, 97)
         call UV0ufa (X, MH, LH, BCGW_XX, BCGW_P,  ak)
CCC_  - [r] = [r] - ak [z]
         call UV0ufa (X, MH, LH, BCGW_R,  BCGW_Z,  -ak)
CCC_  - [rr] = [rr] - ak [zz]
         call UV0ufa (X, MH, LH, BCGW_RR, BCGW_ZZ, -ak)
CCC_  - solve M[z] = [r]
         call MMDsns
     M       (X,
     I        BCGW_Z, BCGW_R,
     W        C,      VW,
     I        F0,     QM,   WW,
     I        iMA,    ipKW, ipCG, MH, LH, LCG)
CCC_  - z = |z|
         call MMXinm (znrm, GW, X, BCGW_Z, iMA, IE, MH, LH)
CCC_  - dx = |p|
         if (abs (zm1nrm - znrm).gt. EPS * znrm) then
            call MMXinm (dxnrm, GW, X, BCGW_P, iMA, IE, MH, LH)
            dxnrm = abs (ak) * dxnrm
            Efin  = znrm / abs (zm1nrm - znrm) * dxnrm
#ifdef DEBUG_D
            write (*, *) 'zz', Itr, abs (zm1nrm - znrm), znrm
#endif
         else
            Efin  = znrm / bnrm
#ifdef DEBUG_D
            write (*, *) 'bnrm', Itr, bnrm
#endif
            goto 100
         endif
CCC_  - x = |x|
         call MMXinm (xnrm, GW, X, BCGW_XX, iMA, IE, MH, LH)
CCC_  - nan check
CCC_  - loop end
         if (Efin .le. 0.5d0 * xnrm) then
            Efin = Efin / xnrm
#ifdef DEBUG_D
            write (*, *) 'xnrm', Itr, xnrm
#endif
         else
            Efin = znrm / bnrm
#ifdef DEBUG_D
            write (*, *) 'bnrm 2', Itr, bnrm
#endif
            goto 100
         endif
#ifdef DEBUG_D
         write (*, *) 'efin', Itr, Efin, Etol
#endif
         if (Efin.gt.Etol) goto 100
      else
         iErr = 1
      endif
      RETURN
      END
CCC_& MMBslz  ## Movement/Update biconjugate gradient method solver (Z)
      subroutine MMBslz
     O    (iErr,
     M     X,      C,      GW,    VW,
     O     Itr,    Efin,   ItrEM, Emin,
     I     ItrMin, ItrMax, Etol,  EPS,
     I     QM,     F0,
     I     ipCG,   LCG,
     I     WW,     MH,    LH, ipKW, KSglb, IE, iMA, ipL)
CCC_ + Description
CC      X (:,VXH) initial guess
CCC_ + Declaration
      implicit none
      _INTENT(OUT, integer)  iErr
      _INTENT(IN,  integer)  MH, LH, LCG
      _INTENT(OUT, integer)  Itr,    ItrEM
      _INTENT(OUT, _REALSTD) Efin,   Emin
      _INTENT(IN,  integer)  ItrMin, ItrMax
      _INTENT(IN,  _REALSTD) Etol,  EPS
      _INTENT(IN,  integer)  ipCG (LCG, *)
CCC_  - cgm work vector
      _INTENT(INOUT,_REALSTD) X (*)
CCC_  - matrix coeff
      _INTENT(IN,   _REALSTD) QM (*), F0
CCC_  - matrix work
      _INTENT(OUT,  _REALSTD) VW (*)
      _INTENT(OUT,  _REALSTD) C  (*),  GW (*)
      _INTENT(IN,   _REALSTD) WW (*)
      _INTENT(IN,   integer)  KSglb (*)
      _INTENT(IN,   integer)  ipKW (*), IE (*), iMA (*)
      _INTENT(IN,   integer)  ipL
CCC_  - interior
      _REALSTD ak,   akden,  bk,  bkden, bknum, bnrm, dxnrm
      _REALSTD xnrm, zm1nrm, znrm
      _REALSTD rnrm
      integer NG
      integer IR, IROOT, NR
CCC_ + Body
CC       Dummy statements
      iErr  = 0 * ipL
      NG = EA_NG(IE)
c$$$      call AETget (iErr, NG,   IE, 'NG')
      call DMAget (IR, iMA, 'IR')
      call DMAget (NR, iMA, 'NR')
      IROOT = 0
c
      Itr   = 0
      ItrEM = 0
      Efin  = 0.0d0
      Emin  = _DBLE_HUGE
      bkden = 0.0d0
CCC_  - [p] = 0, [pp] = 0
      call UV0sta (X, MH, LH, BCGW_P,  0.0d0)
      call UV0sta (X, MH, LH, BCGW_PP, 0.0d0)
CCC_  - [r] = M [x]
      call MMZmns
     M    (X,
     I     BCGW_R, BCGW_XX,
     W     C,      VW,
     I     F0,     QM,   WW,
     I     iMA,    ipKW, ipCG, MH, LH, LCG)
CCC_  - [r] = -[r] + [b]
      call UV0una (X, MH, LH, BCGW_R, BCGW_BB)
      call MMXinm (rnrm, GW, X, BCGW_R, iMA, IE, MH, LH)
c$$$      call UV0d2a (X, MH, LH, BCGW_R, BCGW_XX, 'RX0', 0, 97)
c$$$      write (*, *) 'r0', rnrm
CCC_  - [rr] = [r]
      call UV0cpa (X, MH, LH, BCGW_RR, BCGW_R)
      znrm = 1.0d0
CCC_  - solve M[z] = [b]
      call MMZsns
     M    (X,
     I     BCGW_Z, BCGW_BB,
     W     C,      VW,
     I     F0,     QM,   WW,
     I     iMA,    ipKW, ipCG, MH, LH, LCG)
CCC_  - b = |z|
      call MMXinm (bnrm, GW, X, BCGW_Z, iMA, IE, MH, LH)
CCC_  - solve M[z] = [r]
      call MMZsns
     M    (X,
     I     BCGW_Z, BCGW_R,
     W     C,      VW,
     I     F0,     QM,   WW,
     I     iMA,    ipKW, ipCG, MH, LH, LCG)
CCC_  - z = |z|
      call MMXinm (znrm, GW, X, BCGW_Z, iMA, IE, MH, LH)
CCC_  - loop
 100  continue
      if (Itr.le.ItrMax) then
         Itr = Itr + 1
         zm1nrm = znrm
c$$$         write (*, *) 'CHK', Itr, Efin
CCC_  - solve MT[zz] = [rr]
         call MMZsts
     M       (X,
     I        BCGW_ZZ, BCGW_RR,
     W        C,       VW,
     I        F0,      QM,   WW,
     I        iMA,     ipKW, ipCG, MH, LH, LCG)
CCC_  - bk = [z],[rr]
         call MMXOMS_IPR
     $       (bknum, GW, X, BCGW_B1, BCGW_Z, BCGW_RR,
     $        iMA, KSglb, IE, MH, LH, NG, IR, IROOT, NR)
         if (Itr.eq.1) then
            bk = 0.0d0
         else
            bk = bknum / bkden
c$$$            write (*, *) 'bkden', Itr, bkden
         endif
CCC_  - [p] = bk * [p] + [z], [pp] = bk * [pp] + [zz]
         call UV0uea (X, MH, LH, BCGW_P,  BCGW_Z,  bk)
         call UV0uea (X, MH, LH, BCGW_PP, BCGW_ZZ, bk)
         bkden = bknum
CCC_  - [z] = M [p]
         call MMZmns
     M       (X,
     I        BCGW_Z, BCGW_P,
     W        C,      VW,
     I        F0,     QM,   WW,
     I        iMA,    ipKW, ipCG, MH, LH, LCG)
CCC_  - ak = [z],[pp]
         call MMXOMS_IPR
     $       (akden, GW, X, BCGW_B1, BCGW_Z, BCGW_PP,
     $        iMA, KSglb, IE, MH, LH, NG, IR, IROOT, NR)
         ak = bknum / akden
c$$$         write (*, *) 'akden', Itr, akden
CCC_  - [zz] = MT [pp]
         call MMZmts
     M       (X,
     I        BCGW_ZZ, BCGW_PP,
     W        C,       VW,
     I        F0,      QM,   WW,
     I        iMA,     ipKW, ipCG, MH, LH, LCG)
CCC_  - [x] = [x] + ak [p]
c$$$         call UV0d2a (X, MH, LH, BCGW_XX, BCGW_P, 'XP', itr, 97)
         call UV0ufa (X, MH, LH, BCGW_XX, BCGW_P,  ak)
CCC_  - [r] = [r] - ak [z]
         call UV0ufa (X, MH, LH, BCGW_R,  BCGW_Z,  -ak)
CCC_  - [rr] = [rr] - ak [zz]
         call UV0ufa (X, MH, LH, BCGW_RR, BCGW_ZZ, -ak)
CCC_  - solve M[z] = [r]
         call MMZsns
     M       (X,
     I        BCGW_Z, BCGW_R,
     W        C,      VW,
     I        F0,     QM,   WW,
     I        iMA,    ipKW, ipCG, MH, LH, LCG)
CCC_  - z = |z|
         call MMXinm (znrm, GW, X, BCGW_Z, iMA, IE, MH, LH)
CCC_  - dx = |p|
         if (abs (zm1nrm - znrm).gt. EPS * znrm) then
            call MMXinm (dxnrm, GW, X, BCGW_P, iMA, IE, MH, LH)
            dxnrm = abs (ak) * dxnrm
            Efin  = znrm / abs (zm1nrm - znrm) * dxnrm
c$$$            write (*, *) 'zz', Itr, abs (zm1nrm - znrm)
         else
            Efin  = znrm / bnrm
c$$$            write (*, *) 'bnrm', Itr, bnrm
            goto 100
         endif
CCC_  - x = |x|
         call MMXinm (xnrm, GW, X, BCGW_XX, iMA, IE, MH, LH)
CCC_  - nan check
CCC_  - loop end
         if (Efin .le. 0.5d0 * xnrm) then
            Efin = Efin / xnrm
c$$$            write (*, *) 'xnrm', Itr, xnrm
         else
            Efin = znrm / bnrm
c$$$            write (*, *) 'bnrm 2', Itr, bnrm
            goto 100
         endif
         if (Efin.gt.Etol) then
            if (Emin.gt.Efin) then
               Emin  = Efin
               ItrEM = Itr
            endif
            goto 100
         endif
      else
         iErr = 1
      endif
      RETURN
      END
CCC_& MMBsly  ## Movement/Update biconjugate gradient method solver (Y)
      subroutine MMBsly
     O    (iErr,
     M     X,      C,      GW,    VW,
     O     Itr,    Efin,   ItrEM, Emin,
     I     ItrMin, ItrMax, Etol,  EPS,
     I     QM,     F0,
     I     ipCG,   LCG,
     I     WW,     MH,    LH, ipKW, KSglb, IE, iMA, ipL)
CCC_ + Description
CC      X (:,VXH) initial guess
CCC_ + Declaration
      implicit none
      _INTENT(OUT, integer)  iErr
      _INTENT(IN,  integer)  MH, LH, LCG
      _INTENT(OUT, integer)  Itr,    ItrEM
      _INTENT(OUT, _REALSTD) Efin,   Emin
      _INTENT(IN,  integer)  ItrMin, ItrMax
      _INTENT(IN,  _REALSTD) Etol,  EPS
      _INTENT(IN,  integer)  ipCG (LCG, *)
CCC_  - cgm work vector
      _INTENT(INOUT,_REALSTD) X (*)
CCC_  - matrix coeff
      _INTENT(IN,   _REALSTD) QM (*), F0
CCC_  - matrix work
      _INTENT(OUT,  _REALSTD) VW (*)
      _INTENT(OUT,  _REALSTD) C  (*),  GW (*)
      _INTENT(IN,   _REALSTD) WW (*)
      _INTENT(IN,   integer)  KSglb (*)
      _INTENT(IN,   integer)  ipKW (*), IE (*), iMA (*)
      _INTENT(IN,   integer)  ipL
CCC_  - interior
      _REALSTD ak,   akden,  bk,  bkden, bknum, bnrm, dxnrm
      _REALSTD xnrm, zm1nrm, znrm
      _REALSTD rnrm
      integer NG
      integer IR, IROOT, NR
CCC_ + Body
CC       Dummy statements
      iErr  = 0 * ipL
      NG = EA_NG(IE)
c$$$      call AETget (iErr, NG,   IE, 'NG')
      call DMAget (IR, iMA, 'IR')
      call DMAget (NR, iMA, 'NR')
      IROOT = 0
c
      Itr   = 0
      ItrEM = 0
      Efin  = 0.0d0
      Emin  = _DBLE_HUGE
      bkden = 0.0d0
CCC_  - [p] = 0, [pp] = 0
      call UV0sta (X, MH, LH, BCGW_P,  0.0d0)
      call UV0sta (X, MH, LH, BCGW_PP, 0.0d0)
CCC_  - [r] = M [x]
      call MMYmns
     M    (X,
     I     BCGW_R, BCGW_XX,
     W     C,      VW,
     I     F0,     QM,   WW,
     I     iMA,    ipKW, ipCG, MH, LH, LCG)
CCC_  - [r] = -[r] + [b]
      call UV0una (X, MH, LH, BCGW_R, BCGW_BB)
      call MMXinm (rnrm, GW, X, BCGW_R, iMA, IE, MH, LH)
c$$$      call UV0d2a (X, MH, LH, BCGW_R, BCGW_XX, 'RX0', 0, 97)
c$$$      write (*, *) 'r0', rnrm
CCC_  - [rr] = [r]
      call UV0cpa (X, MH, LH, BCGW_RR, BCGW_R)
      znrm = 1.0d0
CCC_  - solve M[z] = [b]
      call MMYsns
     M    (X,
     I     BCGW_Z, BCGW_BB,
     W     C,      VW,
     I     F0,     QM,   WW,
     I     iMA,    ipKW, ipCG, MH, LH, LCG)
CCC_  - b = |z|
      call MMXinm (bnrm, GW, X, BCGW_Z, iMA, IE, MH, LH)
CCC_  - solve M[z] = [r]
      call MMYsns
     M    (X,
     I     BCGW_Z, BCGW_R,
     W     C,      VW,
     I     F0,     QM,   WW,
     I     iMA,    ipKW, ipCG, MH, LH, LCG)
CCC_  - z = |z|
      call MMXinm (znrm, GW, X, BCGW_Z, iMA, IE, MH, LH)
CCC_  - loop
 100  continue
      if (Itr.le.ItrMax) then
         Itr = Itr + 1
         zm1nrm = znrm
c$$$         write (*, *) 'CHK', Itr, Efin
CCC_  - solve MT[zz] = [rr]
         call MMYsts
     M       (X,
     I        BCGW_ZZ, BCGW_RR,
     W        C,       VW,
     I        F0,      QM,   WW,
     I        iMA,     ipKW, ipCG, MH, LH, LCG)
CCC_  - bk = [z],[rr]
         call MMXOMS_IPR
     $       (bknum, GW, X, BCGW_B1, BCGW_Z, BCGW_RR,
     $        iMA, KSglb, IE, MH, LH, NG, IR, IROOT, NR)
         if (Itr.eq.1) then
            bk = 0.0d0
         else
            bk = bknum / bkden
c$$$            write (*, *) 'bkden', Itr, bkden
         endif
CCC_  - [p] = bk * [p] + [z], [pp] = bk * [pp] + [zz]
         call UV0uea (X, MH, LH, BCGW_P,  BCGW_Z,  bk)
         call UV0uea (X, MH, LH, BCGW_PP, BCGW_ZZ, bk)
         bkden = bknum
CCC_  - [z] = M [p]
         call MMYmns
     M       (X,
     I        BCGW_Z, BCGW_P,
     W        C,      VW,
     I        F0,     QM,   WW,
     I        iMA,    ipKW, ipCG, MH, LH, LCG)
CCC_  - ak = [z],[pp]
         call MMXOMS_IPR
     $       (akden, GW, X, BCGW_B1, BCGW_Z, BCGW_PP,
     $        iMA, KSglb, IE, MH, LH, NG, IR, IROOT, NR)
         ak = bknum / akden
c$$$         write (*, *) 'akden', Itr, akden
CCC_  - [zz] = MT [pp]
         call MMYmts
     M       (X,
     I        BCGW_ZZ, BCGW_PP,
     W        C,       VW,
     I        F0,      QM,   WW,
     I        iMA,     ipKW, ipCG, MH, LH, LCG)
CCC_  - [x] = [x] + ak [p]
c$$$         call UV0d2a (X, MH, LH, BCGW_XX, BCGW_P, 'XP', itr, 97)
         call UV0ufa (X, MH, LH, BCGW_XX, BCGW_P,  ak)
CCC_  - [r] = [r] - ak [z]
         call UV0ufa (X, MH, LH, BCGW_R,  BCGW_Z,  -ak)
CCC_  - [rr] = [rr] - ak [zz]
         call UV0ufa (X, MH, LH, BCGW_RR, BCGW_ZZ, -ak)
CCC_  - solve M[z] = [r]
         call MMYsns
     M       (X,
     I        BCGW_Z, BCGW_R,
     W        C,      VW,
     I        F0,     QM,   WW,
     I        iMA,    ipKW, ipCG, MH, LH, LCG)
CCC_  - z = |z|
         call MMXinm (znrm, GW, X, BCGW_Z, iMA, IE, MH, LH)
CCC_  - dx = |p|
         if (abs (zm1nrm - znrm).gt. EPS * znrm) then
            call MMXinm (dxnrm, GW, X, BCGW_P, iMA, IE, MH, LH)
            dxnrm = abs (ak) * dxnrm
            Efin  = znrm / abs (zm1nrm - znrm) * dxnrm
c$$$            write (*, *) 'zz', Itr, abs (zm1nrm - znrm)
         else
            Efin  = znrm / bnrm
c$$$            write (*, *) 'bnrm', Itr, bnrm
            goto 100
         endif
CCC_  - x = |x|
         call MMXinm (xnrm, GW, X, BCGW_XX, iMA, IE, MH, LH)
CCC_  - nan check
CCC_  - loop end
         if (Efin .le. 0.5d0 * xnrm) then
            Efin = Efin / xnrm
c$$$            write (*, *) 'xnrm', Itr, xnrm
         else
            Efin = znrm / bnrm
c$$$            write (*, *) 'bnrm 2', Itr, bnrm
            goto 100
         endif
         if (Efin.gt.Etol) then
            if (Emin.gt.Efin) then
               Emin  = Efin
               ItrEM = Itr
            endif
            goto 100
         endif
      else
         iErr = 1
      endif
      RETURN
      END
CCC_& MMBslu  ## Movement/Update biconjugate gradient method solver (U)
      subroutine MMBslu
     O    (iErr,
     M     X,      C,      GW,    VW,
     O     Itr,    Efin,   ItrEM, Emin,
     I     ItrMin, ItrMax, Etol,  EPS,
     I     QM,     F0,
     I     ipCG,   LCG,
     I     WW,     MH,    LH, ipKW, KSglb, IE, iMA, ipL)
CCC_ + Description
CC      X (:,VXH) initial guess
CCC_ + Declaration
      implicit none
      _INTENT(OUT, integer)  iErr
      _INTENT(IN,  integer)  MH, LH, LCG
      _INTENT(OUT, integer)  Itr,    ItrEM
      _INTENT(OUT, _REALSTD) Efin,   Emin
      _INTENT(IN,  integer)  ItrMin, ItrMax
      _INTENT(IN,  _REALSTD) Etol,  EPS
      _INTENT(IN,  integer)  ipCG (LCG, *)
CCC_  - cgm work vector
      _INTENT(INOUT,_REALSTD) X (*)
CCC_  - matrix coeff
      _INTENT(IN,   _REALSTD) QM (*), F0
CCC_  - matrix work
      _INTENT(OUT,  _REALSTD) VW (*)
      _INTENT(OUT,  _REALSTD) C  (*),  GW (*)
      _INTENT(IN,   _REALSTD) WW (*)
      _INTENT(IN,   integer)  KSglb (*)
      _INTENT(IN,   integer)  ipKW (*), IE (*), iMA (*)
      _INTENT(IN,   integer)  ipL
CCC_  - interior
      _REALSTD ak,   akden,  bk,  bkden, bknum, bnrm, dxnrm
      _REALSTD xnrm, zm1nrm, znrm
      _REALSTD rnrm
      integer NG
      integer IR, IROOT, NR
CCC_ + Body
CC       Dummy statements
      iErr  = 0 * ipL
      NG = EA_NG(IE)
c$$$      call AETget (iErr, NG,   IE, 'NG')
      call DMAget (IR, iMA, 'IR')
      call DMAget (NR, iMA, 'NR')
      IROOT = 0
c
      Itr   = 0
      ItrEM = 0
      Efin  = 0.0d0
      Emin  = _DBLE_HUGE
      bkden = 0.0d0
CCC_  - [p] = 0, [pp] = 0
      call UV0sta (X, MH, LH, BCGW_P,  0.0d0)
      call UV0sta (X, MH, LH, BCGW_PP, 0.0d0)
CCC_  - [r] = M [x]
      call MMUmns
     M    (X,
     I     BCGW_R, BCGW_XX,
     W     C,      VW,
     I     F0,     QM,   WW,
     I     iMA,    ipKW, ipCG, MH, LH, LCG)
CCC_  - [r] = -[r] + [b]
      call UV0una (X, MH, LH, BCGW_R, BCGW_BB)
      call MMXinm (rnrm, GW, X, BCGW_R, iMA, IE, MH, LH)
c$$$      call UV0d2a (X, MH, LH, BCGW_R, BCGW_XX, 'RX0', 0, 97)
c$$$      write (*, *) 'r0', rnrm
CCC_  - [rr] = [r]
      call UV0cpa (X, MH, LH, BCGW_RR, BCGW_R)
      znrm = 1.0d0
CCC_  - solve M[z] = [b]
      call MMUsns
     M    (X,
     I     BCGW_Z, BCGW_BB,
     W     C,      VW,
     I     F0,     QM,   WW,
     I     iMA,    ipKW, ipCG, MH, LH, LCG)
CCC_  - b = |z|
      call MMXinm (bnrm, GW, X, BCGW_Z, iMA, IE, MH, LH)
CCC_  - solve M[z] = [r]
      call MMUsns
     M    (X,
     I     BCGW_Z, BCGW_R,
     W     C,      VW,
     I     F0,     QM,   WW,
     I     iMA,    ipKW, ipCG, MH, LH, LCG)
CCC_  - z = |z|
      call MMXinm (znrm, GW, X, BCGW_Z, iMA, IE, MH, LH)
CCC_  - loop
 100  continue
      if (Itr.le.ItrMax) then
         Itr = Itr + 1
         zm1nrm = znrm
c$$$         write (*, *) 'CHK', Itr, Efin
CCC_  - solve MT[zz] = [rr]
         call MMUsts
     M       (X,
     I        BCGW_ZZ, BCGW_RR,
     W        C,       VW,
     I        F0,      QM,   WW,
     I        iMA,     ipKW, ipCG, MH, LH, LCG)
CCC_  - bk = [z],[rr]
         call MMXOMS_IPR
     $       (bknum, GW, X, BCGW_B1, BCGW_Z, BCGW_RR,
     $        iMA, KSglb, IE, MH, LH, NG, IR, IROOT, NR)
         if (Itr.eq.1) then
            bk = 0.0d0
         else
            bk = bknum / bkden
c$$$            write (*, *) 'bkden', Itr, bkden
         endif
CCC_  - [p] = bk * [p] + [z], [pp] = bk * [pp] + [zz]
         call UV0uea (X, MH, LH, BCGW_P,  BCGW_Z,  bk)
         call UV0uea (X, MH, LH, BCGW_PP, BCGW_ZZ, bk)
         bkden = bknum
CCC_  - [z] = M [p]
         call MMUmns
     M       (X,
     I        BCGW_Z, BCGW_P,
     W        C,      VW,
     I        F0,     QM,   WW,
     I        iMA,    ipKW, ipCG, MH, LH, LCG)
CCC_  - ak = [z],[pp]
         call MMXOMS_IPR
     $       (akden, GW, X, BCGW_B1, BCGW_Z, BCGW_PP,
     $        iMA, KSglb, IE, MH, LH, NG, IR, IROOT, NR)
         ak = bknum / akden
c$$$         write (*, *) 'akden', Itr, akden
CCC_  - [zz] = MT [pp]
         call MMUmts
     M       (X,
     I        BCGW_ZZ, BCGW_PP,
     W        C,       VW,
     I        F0,      QM,   WW,
     I        iMA,     ipKW, ipCG, MH, LH, LCG)
CCC_  - [x] = [x] + ak [p]
c$$$         call UV0d2a (X, MH, LH, BCGW_XX, BCGW_P, 'XP', itr, 97)
         call UV0ufa (X, MH, LH, BCGW_XX, BCGW_P,  ak)
CCC_  - [r] = [r] - ak [z]
         call UV0ufa (X, MH, LH, BCGW_R,  BCGW_Z,  -ak)
CCC_  - [rr] = [rr] - ak [zz]
         call UV0ufa (X, MH, LH, BCGW_RR, BCGW_ZZ, -ak)
CCC_  - solve M[z] = [r]
         call MMUsns
     M       (X,
     I        BCGW_Z, BCGW_R,
     W        C,      VW,
     I        F0,     QM,   WW,
     I        iMA,    ipKW, ipCG, MH, LH, LCG)
CCC_  - z = |z|
         call MMXinm (znrm, GW, X, BCGW_Z, iMA, IE, MH, LH)
CCC_  - dx = |p|
         if (abs (zm1nrm - znrm).gt. EPS * znrm) then
            call MMXinm (dxnrm, GW, X, BCGW_P, iMA, IE, MH, LH)
            dxnrm = abs (ak) * dxnrm
            Efin  = znrm / abs (zm1nrm - znrm) * dxnrm
c$$$            write (*, *) 'zz', Itr, abs (zm1nrm - znrm)
         else
            Efin  = znrm / bnrm
c$$$            write (*, *) 'bnrm', Itr, bnrm
            goto 100
         endif
CCC_  - x = |x|
         call MMXinm (xnrm, GW, X, BCGW_XX, iMA, IE, MH, LH)
CCC_  - nan check
CCC_  - loop end
         if (Efin .le. 0.5d0 * xnrm) then
            Efin = Efin / xnrm
c$$$            write (*, *) 'xnrm', Itr, xnrm
         else
            Efin = znrm / bnrm
c$$$            write (*, *) 'bnrm 2', Itr, bnrm
            goto 100
         endif
         if (Efin.gt.Etol) then
            if (Emin.gt.Efin) then
               Emin  = Efin
               ItrEM = Itr
            endif
            goto 100
         endif
      else
         iErr = 1
      endif
      RETURN
      END
CCC_& MMBslh  ## Movement/Update biconjugate gradient method solver (H)
      subroutine MMBslh
     O    (iErr,
     M     X,      C,      GW,    VW,
     O     Itr,    Efin,   ItrEM, Emin,
     I     ItrMin, ItrMax, Etol,  EPS,
     I     QM,     F0,
     I     ipCG,   LCG,
     I     WW,     MH,    LH, ipKW, KSglb, IE, iMA, ipL)
CCC_ + Description
CC      X (:,VXH) initial guess
CCC_ + Declaration
      implicit none
      _INTENT(OUT, integer)  iErr
      _INTENT(IN,  integer)  MH, LH, LCG
      _INTENT(OUT, integer)  Itr,    ItrEM
      _INTENT(OUT, _REALSTD) Efin,   Emin
      _INTENT(IN,  integer)  ItrMin, ItrMax
      _INTENT(IN,  _REALSTD) Etol,  EPS
      _INTENT(IN,  integer)  ipCG (LCG, *)
CCC_  - cgm work vector
      _INTENT(INOUT,_REALSTD) X (*)
CCC_  - matrix coeff
      _INTENT(IN,   _REALSTD) QM (*), F0
CCC_  - matrix work
      _INTENT(OUT,  _REALSTD) VW (*)
      _INTENT(OUT,  _REALSTD) C  (*),  GW (*)
      _INTENT(IN,   _REALSTD) WW (*)
      _INTENT(IN,   integer)  KSglb (*)
      _INTENT(IN,   integer)  ipKW (*), IE (*), iMA (*)
      _INTENT(IN,   integer)  ipL
CCC_  - interior
      _REALSTD ak,   akden,  bk,  bkden, bknum, bnrm, dxnrm
      _REALSTD xnrm, zm1nrm, znrm
      _REALSTD rnrm
      integer NG
      integer IR, IROOT, NR
CCC_ + Body
CC       Dummy statements
      iErr  = 0 * ipL
      NG = EA_NG(IE)
c$$$      call AETget (iErr, NG,   IE, 'NG')
      call DMAget (IR, iMA, 'IR')
      call DMAget (NR, iMA, 'NR')
      IROOT = 0
c
      Itr   = 0
      ItrEM = 0
      Efin  = 0.0d0
      Emin  = _DBLE_HUGE
      bkden = 0.0d0
CCC_  - [p] = 0, [pp] = 0
      call UV0sta (X, MH, LH, BCGW_P,  0.0d0)
      call UV0sta (X, MH, LH, BCGW_PP, 0.0d0)
CCC_  - [r] = M [x]
      call MMHmns
     M    (X,
     I     BCGW_R, BCGW_XX,
     W     C,      VW,
     I     F0,     QM,   WW,
     I     iMA,    ipKW, ipCG, MH, LH, LCG)
CCC_  - [r] = -[r] + [b]
      call UV0una (X, MH, LH, BCGW_R, BCGW_BB)
      call MMXinm (rnrm, GW, X, BCGW_R, iMA, IE, MH, LH)
c$$$      call UV0d2a (X, MH, LH, BCGW_R, BCGW_XX, 'RX0', 0, 97)
c$$$      write (*, *) 'r0', rnrm
CCC_  - [rr] = [r]
      call UV0cpa (X, MH, LH, BCGW_RR, BCGW_R)
      znrm = 1.0d0
CCC_  - solve M[z] = [b]
      call MMHsns
     M    (X,
     I     BCGW_Z, BCGW_BB,
     W     C,      VW,
     I     F0,     QM,   WW,
     I     iMA,    ipKW, ipCG, MH, LH, LCG)
CCC_  - b = |z|
      call MMXinm (bnrm, GW, X, BCGW_Z, iMA, IE, MH, LH)
CCC_  - solve M[z] = [r]
      call MMHsns
     M    (X,
     I     BCGW_Z, BCGW_R,
     W     C,      VW,
     I     F0,     QM,   WW,
     I     iMA,    ipKW, ipCG, MH, LH, LCG)
CCC_  - z = |z|
      call MMXinm (znrm, GW, X, BCGW_Z, iMA, IE, MH, LH)
CCC_  - loop
 100  continue
      if (Itr.le.ItrMax) then
         Itr = Itr + 1
         zm1nrm = znrm
c$$$         write (*, *) 'CHK', Itr, Efin
CCC_  - solve MT[zz] = [rr]
         call MMHsts
     M       (X,
     I        BCGW_ZZ, BCGW_RR,
     W        C,       VW,
     I        F0,      QM,   WW,
     I        iMA,     ipKW, ipCG, MH, LH, LCG)
CCC_  - bk = [z],[rr]
         call MMXOMS_IPR
     $       (bknum, GW, X, BCGW_B1, BCGW_Z, BCGW_RR,
     $        iMA, KSglb, IE, MH, LH, NG, IR, IROOT, NR)
         if (Itr.eq.1) then
            bk = 0.0d0
         else
            bk = bknum / bkden
c$$$            write (*, *) 'bkden', Itr, bkden
         endif
CCC_  - [p] = bk * [p] + [z], [pp] = bk * [pp] + [zz]
         call UV0uea (X, MH, LH, BCGW_P,  BCGW_Z,  bk)
         call UV0uea (X, MH, LH, BCGW_PP, BCGW_ZZ, bk)
         bkden = bknum
CCC_  - [z] = M [p]
         call MMHmns
     M       (X,
     I        BCGW_Z, BCGW_P,
     W        C,      VW,
     I        F0,     QM,   WW,
     I        iMA,    ipKW, ipCG, MH, LH, LCG)
CCC_  - ak = [z],[pp]
         call MMXOMS_IPR
     $       (akden, GW, X, BCGW_B1, BCGW_Z, BCGW_PP,
     $        iMA, KSglb, IE, MH, LH, NG, IR, IROOT, NR)
         ak = bknum / akden
c$$$         write (*, *) 'akden', Itr, akden
CCC_  - [zz] = MT [pp]
         call MMHmts
     M       (X,
     I        BCGW_ZZ, BCGW_PP,
     W        C,       VW,
     I        F0,      QM,   WW,
     I        iMA,     ipKW, ipCG, MH, LH, LCG)
CCC_  - [x] = [x] + ak [p]
c$$$         call UV0d2a (X, MH, LH, BCGW_XX, BCGW_P, 'XP', itr, 97)
         call UV0ufa (X, MH, LH, BCGW_XX, BCGW_P,  ak)
CCC_  - [r] = [r] - ak [z]
         call UV0ufa (X, MH, LH, BCGW_R,  BCGW_Z,  -ak)
CCC_  - [rr] = [rr] - ak [zz]
         call UV0ufa (X, MH, LH, BCGW_RR, BCGW_ZZ, -ak)
CCC_  - solve M[z] = [r]
         call MMHsns
     M       (X,
     I        BCGW_Z, BCGW_R,
     W        C,      VW,
     I        F0,     QM,   WW,
     I        iMA,    ipKW, ipCG, MH, LH, LCG)
CCC_  - z = |z|
         call MMXinm (znrm, GW, X, BCGW_Z, iMA, IE, MH, LH)
CCC_  - dx = |p|
         if (abs (zm1nrm - znrm).gt. EPS * znrm) then
            call MMXinm (dxnrm, GW, X, BCGW_P, iMA, IE, MH, LH)
            dxnrm = abs (ak) * dxnrm
            Efin  = znrm / abs (zm1nrm - znrm) * dxnrm
c$$$            write (*, *) 'zz', Itr, abs (zm1nrm - znrm)
         else
            Efin  = znrm / bnrm
c$$$            write (*, *) 'bnrm', Itr, bnrm
            goto 100
         endif
CCC_  - x = |x|
         call MMXinm (xnrm, GW, X, BCGW_XX, iMA, IE, MH, LH)
CCC_  - nan check
CCC_  - loop end
         if (Efin .le. 0.5d0 * xnrm) then
            Efin = Efin / xnrm
c$$$            write (*, *) 'xnrm', Itr, xnrm
         else
            Efin = znrm / bnrm
c$$$            write (*, *) 'bnrm 2', Itr, bnrm
            goto 100
         endif
         if (Efin.gt.Etol) then
            if (Emin.gt.Efin) then
               Emin  = Efin
               ItrEM = Itr
            endif
            goto 100
         endif
      else
         iErr = 1
      endif
      RETURN
      END
CCC_& MMSdbg  ## Movement/update debug
      subroutine MMSdbg
     I    (X, MH, LH, Tag, Itr, IFP)
      implicit none
      _INTENT(IN, _REALSTD)  X (*)
      _INTENT(IN, integer)   MH, LH
      _INTENT(IN, integer)   Itr
      _INTENT(IN, character) Tag*(*)
      _INTENT(IN, integer)   IFP
 101  format ('MMSDBG:', A, ': ', I5)
      if (COND_N(IFP)) then
         write (IFP, 101) _TRIM(Tag), Itr
      else if (COND_S(IFP)) then
         write (*,   101) _TRIM(Tag), Itr
      endif
      call UV0nan (X, MH, LH, BCGW_P,  'P',  Itr, IFP)
      call UV0nan (X, MH, LH, BCGW_PP, 'PP', Itr, IFP)
      call UV0nan (X, MH, LH, BCGW_Z,  'Z',  Itr, IFP)
      call UV0nan (X, MH, LH, BCGW_ZZ, 'ZZ', Itr, IFP)
      call UV0nan (X, MH, LH, BCGW_R,  'R',  Itr, IFP)
      call UV0nan (X, MH, LH, BCGW_RR, 'RR', Itr, IFP)
      call UV0nan (X, MH, LH, BCGW_B1, 'B1', Itr, IFP)
      call UV0nan (X, MH, LH, BCGW_XX, 'XX', Itr, IFP)
      RETURN
      END
CCC_& MMSBCG  ## Movement/update thickness announcement
      subroutine MMSBCG (STRA, STRB, IOP)
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
CCC_ @ MMSTST  ## Movemeent/update thickness test program
#ifdef     TEST_MMSBCG
#include "ofnstd.h"
#include "odevid.h"  /* MPI table */
      program MMSTST
CCC_  - Test suites
CC::   SOURCES mibakw.F:TEST_MIBAKW_SUB=1 mmxoms.F:TEST_MMXOMS_SUB=1
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
      if (iErr.eq.0) then
         call DMAtma (iMA)
         call MMStestMain (iErr, ipA, iMA)
         call ACCrep (FPL(ipA), 0)
      endif
      call DevFin (iErr)
      STOP
      END
CCC_ & MMStestMain   ## main
      subroutine MMStestMain (iErr, ipA, iMA)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(IN, integer) ipA (*)
      _INTENT(IN, integer) iMA (*)
CCC_   . tables
      character  CROOT * (32)
CCC_   . kiwi
#ifndef   OPT_MMSBCG_LHP_MAX
#  define OPT_MMSBCG_LHP_MAX OPT_MOVEMENT_LHP_MAX
#endif
#ifndef   OPT_MMSBCG_LHG_MAX
#  define OPT_MMSBCG_LHG_MAX OPT_MOVEMENT_LHG_MAX
#endif
      integer    LHP
      parameter (LHP = OPT_MMSBCG_LHP_MAX)
      integer    LHG
      parameter (LHG = OPT_MMSBCG_LHG_MAX)
c
      integer    LIE
      parameter (LIE = (LHP * 8))
      integer    IE (LIE)
c
      integer    ipKW (IPKW_FULL_DECL)
      integer    LKW
      parameter (LKW = 64)
      _REALSTD   WW (LHP * LKW)
c
      integer    LWV
      parameter (LWV = OPT_MMSBCG_LHP_MAX)
      _REALSTD   WV (LWV)
c
      _REALSTD   VMW  (LHP * VMW_MAX)

      _REALSTD   X  (LHP * BCGW_MAX)
      _REALSTD   QM (LHP * VMQQ_MAX)
c
      _REALSTD   VMI  (LHP * VMI_MAX)
      _REALSTD   VMHB (LHP * VMHB_MAX)
      _REALSTD   VMC  (LHP * VMC_MAX)
c
      _REALSTD   VMID (LHP * VMID_MAX)
c
      integer    LCK
      parameter (LCK = 4)
      _REALSTD   CW   (LHP * LCK)
      _REALSTD   GW (LHG)
c
      _REALSTD   DENS, GRAV, PF, FG  (3)
      _REALSTD   DT,  WF
CCC_   . global/private stencils
      integer    LNR
      parameter (LNR = 256)
      integer    KSglb (LNR * 2)
      integer    LTBL
      parameter (LTBL = LHP)
      integer    kDTA (LTBL, 3)
CCC_   . clone group
      integer    LCG
      parameter (LCG = KWCG_DECL(4))
      integer    ipCG (LCG, CGB_MAX)
CCC_   . coordinate
      integer  icF
CCC_   . output
      integer  idGM (16)
      character CSW*(16)
CCC_   . size
      integer  MH, LH
      integer  NZ, LZ,  KZ0
c
      integer  ipL, ipP, ipC, ipV
      integer  IFPa (16)
CCC_  - Body
      iErr = 0
      ipL  = FPL(ipA)
      ipP  = FPP(ipA)
      ipC  = FPC(ipA)
      ipV  = FPV(ipA)
      call AFUifp (IFPa, ipP, ipC, ipL, ipV)
c
      CROOT = 'ID'
CCC_   . just for test
      NZ  = 0
      LZ  = 1
      KZ0 = 1
CCC_   . initialization
      if (iErr.eq.0) call AKPini (ipKW)
      if (iErr.eq.0) call MIBdec (iErr, ipKW, ipL)
      if (iErr.eq.0) call MMXdec (iErr, ipKW, ipL)
c
      if (iErr.eq.0) then
         call MIBKtestCfg
     O       (iErr,
     O        icF, IE,   LIE,  ipKW,
     O        WV,  WW,   MH,    LH,
     I        LHP, LKW,  LWV,   CROOT, ipA,  iMA)
      endif
      if (iErr.eq.0) then
         call MMXtestCfg
     O       (iErr,
     O        KSglb, kDTA,
     O        ipCG,
     I        LNR,   LTBL, LCG,  LHP, LCK, ipKW, IE, CROOT, ipA)
      endif
      if (iErr.eq.0) then
         call AESglb
     O       (iErr,
     O        KSglb,
     W        kDTA,
     I        LNR,  LTBL, LHP, 0, IE, ipL)
      endif
      if (iErr.eq.0) then
         call MMBcgr
     O       (iErr,
     O        ipCG,
     W        kDTA,
     I        LTBL, LCG, LHP, LCK, ipKW, IE, ipL)
      endif
      if (iErr.eq.0) then
         call MIBKtestField
     O       (iErr,
     O        VMI, VMHB,
     I        MH,  LH,   IE, CROOT, ipA)
      endif
      if (iErr.eq.0) then
         call MIBKtestField2
     O       (iErr,
     M        VMI,
     W        CW,    VMW,
     I        VMHB,
     I        WW,    MH,  LH,
     I        ipKW,  iMA)
      endif
      if (iErr.eq.0) then
         call MIBKtestParam
     O       (iErr,
     O        VMI,  VMHB, VMID,
     O        FG,   DENS, GRAV, PF, DT, WF,
     I        MH,   LH,   ipA)
      endif
c
      CSW = 'C'
      if (iErr.eq.0) then
         call MIVgst
     O       (iErr, idGM,
     I        icF,  MH,  LH,    NZ,   LZ,  KZ0,
     I        CSW,  ' ', CROOT, IFPa, IE,  iMA)
      endif
      if (iErr.eq.0) then
         call MMXgst
     O       (iErr, idGM,
     I        icF,  MH,  LH,
     I        CSW,  ' ', CROOT, IFPa, IE, iMA)
      endif
c$$$      if (iErr.eq.0) call MMShch (iErr, IE, ipL)
      if (iErr.eq.0) then
         call MIBKtestExe
     O       (iErr,
     O        VMC,  VMID, VMW,   CW,
     I        VMI,  FG,   DENS,  GRAV,  PF,
     I        WW,
     I        MH,   LH,
     I        ipCG, LCG,  ipKW,  ipA,   iMA, IE, idGM)
      endif
      call UV1cpa (VMC, VMI, MH, LH, VMC_HCa, VMI_Ha)
      if (iErr.eq.0) then
         call MMStestExe
     O       (iErr,
     O        X,     QM,     CW,    GW,    VMW,
     I        VMI,   VMHB,   VMC,   VMID,  DT,    WF,
     I        WW,
     I        KSglb, ipCG,  LCG,
     I        MH,    LH,     IE,    ipKW, ipA,  iMA, idGM,
     I        MMXSW_DVB)
      endif
      if (iErr.eq.0) then
         call MMStestExe
     O       (iErr,
     O        X,     QM,     CW,    GW,    VMW,
     I        VMI,   VMHB,   VMC,   VMID,  DT,    WF,
     I        WW,
     I        KSglb, ipCG,  LCG,
     I        MH,    LH,     IE,    ipKW, ipA,  iMA, idGM,
     I        MMXSW_ZEV)
      endif
      RETURN
      END
CCC_ & MMStestExe  ## execution
      subroutine MMStestExe
     O    (iErr,
     O     X,     QM,     CW,    GW,    VMW,
     I     VMI,   VMHB,   VMC,   VMID,  DT,    WF,
     I     WW,
     I     KSglb, ipCG,   LCG,
     I     MH,    LH,     IE,    ipKW, ipA,  iMA, idGM,
     I     MSW)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)  iErr
      _INTENT(IN, integer)  MH,  LH
      _INTENT(IN, integer)  ipKW (*), IE (*), ipA (*), iMA (*)
      _INTENT(OUT,_REALSTD) X (*),  QM (*),  CW (*), GW (*)
      _INTENT(OUT,_REALSTD) VMW (*)
      _INTENT(IN, _REALSTD) VMC  (*)
      _INTENT(IN, _REALSTD) VMHB (*)
      _INTENT(IN, _REALSTD) VMI  (*)
      _INTENT(IN, _REALSTD) VMID (*)
      _INTENT(IN, _REALSTD) DT, WF
      _INTENT(IN, _REALSTD) WW (*)
      _INTENT(IN, integer)  LCG
      _INTENT(IN, integer)  ipCG (*), KSglb (*)
      _INTENT(IN, integer)  idGM (*)
      _INTENT(IN, integer)  MSW
      _REALSTD F0
      integer  ipL
      integer  Itr, ItrMax
      _REALSTD Efin, Etol, EPS
      _REALSTD T
CCC_  - Body
      iErr = 0
      ipL  = FPL(ipA)
c
      Etol   = 1.0d-21
      EPS    = 1.0d-31
c$$$      ItrMax = 1024
      ItrMax = 256
c
      if (iErr.eq.0) then
         call UV0sta (VMID, MH, LH, VMID_UBb, 0.0d0)
         call UV0sta (VMID, MH, LH, VMID_VBc, 0.0d0)
      endif
      if (iErr.eq.0) then
         call MMXgen
     O       (iErr,
     O        X,    QM,   F0,
     W        VMW,  CW,
     I        VMI,  VMC,  VMHB, VMID,  DT,   WF,
     I        WW,
     I        ipKW, iMA,  MH,   LH,   MSW,  MMXINI_0)
      endif
      if (iErr.eq.0) then
         call MMSbuc
     O       (iErr,
     M        X,      CW,    GW,   VMW,
     O        Itr,    Efin,
     I        ItrMax, Etol,  EPS,  MSW,
     I        QM,     F0,
     I        ipCG,   LCG,
     I        WW,     MH,    LH, ipKW, KSglb, IE, iMA, ipL)
      endif
 101  format ('ITR', I1, ': ', I5, 1x, I5, 1x, E16.9)
      write (ipL, 101) MSW, iErr, Itr, Efin
CCC_   . output clusters
      T = 0.0d0
      if (iErr.eq.0) then
         call AFBptc
     O       (iErr,
     I        X,
     I        1, idGM (VGRP_VMX), 0, 0, T,  ' ',  ' ',  IE)
      endif
      if (iErr.eq.0) then
         call AFBptc
     O       (iErr,
     I        QM,
     I        1, idGM (VGRP_VMQ), 0, 0, T,  ' ',  ' ',  IE)
      endif
      if (iErr.eq.0) then
CCC_    * dH
         call UV3nsa
     $        (VMW, X, VMI, MH, LH, VMIW_W1, BCGW_XX, VMI_Ha)
         call AFBptc
     O       (iErr,
     I        VMW,
     I        1, idGM (VGRP_VMIW), VMIW_W1, VMIW_W1, T,  ' ',  ' ',  IE)
      endif
      RETURN
      END
#endif  /* TEST_MMSBCG */
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
