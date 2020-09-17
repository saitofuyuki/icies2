C cadenza/cvglst.F --- IcIES/Cadenza/List
C Author: SAITO Fuyuki
C Created: Apr 17 2013
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2020/09/15 11:53:49 fuyuki cvglst.F>'
#define _FNAME 'cadenza/cvglst.F'
#define _REV   'Snoopy0.8'
CCC_! MANIFESTO
C
C Copyright (C) 2013--2020
C           Japan Agency for Marine-Earth Science and Technology,
C           Ayako ABE-OUCHI
C
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
CCC_* Common macros
#include "ofdlct.h" /* fortran dialect */
#include "ologfm.h" /* logging */
#include "ofnstd.h"
CC #include "oarpea.h"
#include "oarpfi.h"
#include "odevva.h"
#include "odevel.h"
#include "oarpkw.h" /* operation id in arpeggio/kiwi */
CCC_* Macros
#ifndef   CVGLST_SKIP_PROGRAM
#  define CVGSLT_SKIP_PROGRAM 0
#endif
#ifndef   AKW_CLS
#  define AKW_CLS 'V'
#endif
CCC_ + Buffers
#ifndef   CVGLST_TAG_MAX
#  define CVGLST_TAG_MAX 32
#endif
#ifndef   CVGLST_TAG_LEN
#  define CVGLST_TAG_LEN 8
#endif
#ifndef   CVGLST_VALUE_LEN
#  define CVGLST_VALUE_LEN 80
#endif
#ifndef   CVGLST_COOR_MAX
#  define CVGLST_COOR_MAX 32
#endif
c$$$#  define CVGLST_GROUP_MAX 4
#ifndef   CVGLST_GROUP_MAX
#  define CVGLST_GROUP_MAX 128
#endif
CCC_& CVLfng  ## find new group
      subroutine CVLfng
     O    (iErr,
     M     NCUM,
     O     GTB,   NGTB, LGTB, k0tb,
     O     TT,    VV,   CV,   AA,  EE,  NT,  LT, K0,
     I     iGRP,  ipI,  ipE,  ipRR)
CCC_ + Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,integer)   NCUM
c
      _INTENT(OUT,integer)   NGTB
      _INTENT(OUT,character) GTB (*)*(*)
      _INTENT(IN, integer)   LGTB, k0tb
c
      _INTENT(OUT,integer)   NT
      _INTENT(IN, integer)   K0, LT, iGRP
      _INTENT(OUT,character) TT (*)*(*)
      _INTENT(OUT,character) VV (*)*(*)
      _INTENT(OUT,character) AA (*)*(*)
      _INTENT(OUT,character) EE (*)*(*)
c
      _INTENT(IN, character) CV (*)*(*)
c
      _INTENT(IN, integer)   ipI, ipE, ipRR
c
      integer NTini
      integer NSKP
      integer itb
CCC_ + Body
      iErr = 0
c
      NTini = NT
      call UUrwnd (iErr, ipI)
      call UDMfi1 (ipE, '(''FORWARD: '', I4)', NCUM)
      call DVTfwg (iErr, NCUM, ipI)
c
      DO
         NT = NTini
         if (iErr.eq.0) then
            call CNQgsq
     O          (iErr,
     O           NSKP, TT,   VV,  CV, AA, EE, NT, LT, K0,
     I           ' ',  iGRP, ipE, ipI)
         endif
         if (iErr.eq.0) NCUM = NCUM + NSKP + 1
         if (iErr.ne.0) then
            if (VV (iGRP).eq.' ') iErr = 1
            goto 900
         endif
         call UKStgA (itb, GTB, ngtb, lgtb, k0tb, VV (iGRP))
 102     format ('CVLFNG:', I3, 1x, I4, 1x, A)
         if (itb.lt.k0tb) then
            ngtb = ngtb + 1
            if (ngtb.le.lgtb) GTB (ngtb) = VV (iGRP)
            if (COND_N(ipE)) then
               write (ipE, 102) ngtb, NCUM,
     $              _TRIM(VV(iGRP))
            else if (COND_S(ipE)) then
               write (*,   102) ngtb, NCUM,
     $              _TRIM(VV(iGRP))
            endif
            goto 900
         endif
      enddo
 900  continue
      if (ngtb.gt.lgtb) then
         call UDMfi1
     $        (ipE, '(''ERROR: Insufficient buffer '', I7)', lgtb)
         iErr = -1
      endif
      RETURN
      END
CCC_& CVLrpm  ## report member
      subroutine CVLrpm
     O    (iErr,
     O     TT,    VV,    CV,   AA,   EE,   NT,  LT,
     I     TG,    VG,    NTG,  LTG,  K0,
     I     ivST,  ivEN,
     I     ipI,   ipE,   ipRR)
CCC_ + Declaration
      implicit none
c
      _INTENT(OUT,integer)   iErr
c
      _INTENT(IN, integer)   ivST, ivEN
c
      _INTENT(OUT,integer)   NT
      _INTENT(IN, integer)   LT
c
      _INTENT(OUT,character) TT (*)*(*)
      _INTENT(OUT,character) VV (*)*(*)
      _INTENT(OUT,character) CV (*)*(*)
      _INTENT(OUT,character) AA (*)*(*)
      _INTENT(OUT,character) EE (*)*(*)
c
      _INTENT(IN, character) TG (*)*(*)
      _INTENT(IN, character) VG (*)*(*)
      _INTENT(IN, integer)   NTG, LTG, K0
      _INTENT(IN, integer)   ipI, ipE, ipRR
c
      character VNM*(64)
      character CKX*(32)
c
      integer Kanch
      integer jit, jkv, jcs, jcb
      integer jgr, jgrdef
      integer nskp
      integer NTini
      integer KV, NV, MV
      integer jdmy
c
      character BFmem*(128)
      character TBF1*(128), TBF2*(128)
      character TBF3*(128), TBF4*(128)
CCC_ + Body
      iErr = 0
CCC_  - variable
      Kanch = -1
      NT  = 0
      jgr = K0 - 1
c
      call UKStgA (jgrdef, TG, NTG, LTG, K0, 'GROUP')
c
      if (iErr.eq.0) then
         call UKAsvA (jit,  TT, CV, NT, LT, K0, 'ITEM',  ' ')
         call UKAsvA (jkv,  TT, CV, NT, LT, K0, 'KV',    ' ')
         call UKAsvA (jcs,  TT, CV, NT, LT, K0, 'COSTR', ' ')
         call UKAsvA (jcb,  TT, CV, NT, LT, K0, 'CBASE', ' ')
         call DVTcpi (TT, CV, NT, LT, TG, VG, NTG, LTG, 'CROOT')
         if (ivST.eq.0 .and. ivEN.eq.0) then
            call UKAsvA (jgr,  TT, CV, NT, LT, K0, 'GROUP', ' ')
         endif
      endif
      if (iErr.eq.0) then
         call UKDkaa (iErr, TT, NT, LT, K0, CV, 'NVLRPM:i', ipE)
      endif
      if (ivST.eq.0 .and. ivEN.eq.0) then
         MV = 0
      else
         MV = ivEN - ivST + 1
      endif
CCC_  - loop
      nv    = 0
      NTini = NT
      DO
         if (iErr.ne.0) goto 900
         if (MV.gt.0 .and. NV.ge.MV) goto 900
         NT = NTini
         if (iErr.eq.0) then
            call DVTcol
     $          (iErr,
     $           nskp, NT, TT, VV, AA, EE, CV, Kanch, LT, ipI)
         endif
         if (jgr.gt.0.and.jgrdef.gt.0) then
c$$$            write (*, *) jgrdef, VG (jgrdef)
c$$$            write (*, *) jgr, VV (jgr)
            if (VG (jgrdef).ne.VV (jgr)) iErr = 1
         endif
         if (iErr.eq.0) then
            NV = NV + 1
            call UKDkaa (iErr, TT, NT, LT, K0, VV, 'NVLRPM:o', ipE)
         endif
         if (iErr.eq.0) then
            call USMcpd (TBF1, VV (jit), '(null)')
            if (VV (jkv).eq.' ') then
               call USGlni (TBF2, NV)
            else
               TBF2 = VV (jkv)
            endif
            call USMcpd (TBF3, VV (jcs), ':')
            call USMcpd (TBF4, VV (jcb), ':')
 101        format (A, 1x, A, 1x, '[', A, '] [', A, ']')
            write (BFmem, 101)
     $           _TRIM(TBF1), _TRIM(TBF2),
     $           _TRIM(TBF4), _TRIM(TBF3)
            call UDMfa1 (ipRR, '(3x, A)', BFmem)
         endif
      ENDDO
 900  continue
CCC_  - return
      call DAtrcU (ipE, iErr, 'R', 'CVLrpm')
CC    positive if normal eof
      iErr = MIN (0, iErr)
      RETURN
      END
CCC_& CVLdrv  ## Driver
      subroutine CVLdrv (iErr, ipA, iMA)
CCC_ + Declaration
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(IN, integer) ipA (*)
      _INTENT(IN, integer) iMA (*)
c
      integer    ipL, ipC, ipP
      integer    ipRR
c
      integer    Lattr
      parameter (Lattr = 16)
c
      character  CLS  *(Lattr)
      character  CROOT*(Lattr), CSFX*(Lattr)
      character  VITEM*(Lattr), VGRP*(Lattr), VSUB*(Lattr)
      character  VTBL *(Lattr), VCO *(Lattr), VCOGR*(Lattr)
c
      character  FNM  *(OPT_FILENAME_MAX)
CCC_  - Collation arrays
      integer    Ltag, Lval
      parameter (Ltag = CVGLST_TAG_LEN)
      parameter (Lval = CVGLST_VALUE_LEN)
c
      integer    LTG
      parameter (LTG    = CVGLST_TAG_MAX)
      integer    LTC
      parameter (LTC    = CVGLST_TAG_MAX)
      integer    LCW
      parameter (LCW    = CVGLST_TAG_MAX)
c
      integer    NTG, NTC
c
      character  TG (LTG)*(Ltag)
      character  VG (LTG)*(Lval), CG (LTG)*(Lval)
c
      character  TC (LTC)*(Ltag)
      character  VC (LTC)*(Lval), CC (LTC)*(Lval)
c
      character  AA (LCW)*(Lval), EE (LCW)*(Lval)
      integer    K0
c
      integer    NCUM, NSKP
      integer    NTini
CCC_  - Coordinates
      integer    MaxCo
      parameter (MaxCo = CVGLST_COOR_MAX)
      character  CNM  (2, MaxCo)*(Lval)
      integer    NCM  (MaxCo)
      integer    NCO,  Ncnm
CCC_  - Table
      integer    Lgrp
      parameter (Lgrp = Lattr)
      integer    k0tb
      parameter (k0tb = 1)
      integer    MaxTbl
      parameter (MaxTbl = CVGLST_GROUP_MAX)
      character  TBGRP (k0tb:MaxTbl) * (Lgrp)
      integer    ntb, itb
CCC_  - Variable
      integer    jGRP, jGBS
      integer    jMXV, jVST, jVEN
      logical    OFOUND
      integer    kst, ken
CCC_  - string buffers
      character  tbf*(32)
      character  BFgbs*(16)
      character  BFrng*(32)
      character  BFgrp*(128)
CCC_ + Body
      iErr = 0
      ipL  = FPL(ipA)
      ipC  = FPC(ipA)
      ipP  = FPP(ipA)
c
      ipRR = 99
c
      K0    = 1
      NTG   = 0
      VGRP  = ' '
c
      call UKAsvA (jGRP, TG, CG, NTG, LTG, K0, 'GROUP',  VGRP)
      call UKAsvA (jGBS, TG, CG, NTG, LTG, K0, 'GBASE',  ' ')
      call UKAsvA (jMXV, TG, CG, NTG, LTG, K0, 'MAXV',   ' ')
      call UKAsvA (jVST, TG, CG, NTG, LTG, K0, 'VSTART', ' ')
      call UKAsvA (jVEN, TG, CG, NTG, LTG, K0, 'VEND',   ' ')
c
CCC_  - loop
      ntb   = k0tb - 1
      NCUM  = 0
      NTini = NTG
      DO
         NTG = NTini
CCC_   . new group
         if (iErr.eq.0) then
            call CVLfng
     O          (iErr,
     M           NCUM,
     O           TBGRP, NTB,  MaxTbl, k0tb,
     O           TG,    VG,   CG,     AA,  EE,  NTG, LTG, K0,
     I           jGRP,  ipP,  ipL,    ipRR)
         endif
         if (iErr.ne.0) goto 900
CCC_   . monitor
         call USMcpd (BFgbs, VG (jGBS), '-')
         call USGlni (BFrng, kst)
         call USGlni (tbf,   ken)
         call USJnta (BFrng, ':', tbf)
 102     format ('GROUP: ', I3, 1x, I4, 1x, A, 1x, A, 1x, '[', A, ']')
         write (BFgrp, 102) ntb, NCUM,
     $        _TRIM(VG(jGRP)), _TRIM(BFgbs), _TRIM(BFrng)
         call UDMfa1 (ipRR, '(A)', BFgrp)
CCC_   . contents
         if (VG (jMXV).ne.' ') then
            read (VG (jMXV), *) ken
            kst = 1
         else if (VG (jVST).ne.' ') then
            read (VG (jVST), *) kst
            read (VG (jVEN), *) ken
         else
            kst = 0
            ken = 0
         endif
         call CVLrpm
     O       (iErr,
     O        TC,    VC,    CC,   AA,   EE,   NTC,  LTC,
     I        TG,    VG,    NTG,  LTG,  K0,
     I        kST,   kEN,
     I        ipP,   ipL,   ipRR)
      ENDDO
 900  continue
CC    positive if normal eof
      iErr = MIN (0, iErr)
CC_  - return
      call DAtrcU (ipL, iErr, 'R', 'CVLdrv')
      RETURN
      END
CCC_& CVGLST  ## IcIES/Cadenza/List announcement
      subroutine CVGLST (STRA, STRB, IOP)
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
CCC_@ CVLPRG  ## Cadenza/List program
#if CVGLST_SKIP_PROGRAM == 0
      program CVLPRG
CCC_ + Declaration
#include "odevid.h"  /* MPI table */
      implicit none
      integer iErr
      integer ipA (LOG_CHANNEL_MAX)
      integer iMA (MAX_MPI_ATTR)
CCC_ + Body
      call DDsmpl (iErr)
      if (iErr.eq.0) then
         call DLCmng (ipA, 't')
         call DVHrgC (iErr, ' ', ' ', ' ', ipA)
      endif
      if (iErr.eq.0) then
         call DMAtma (iMA)
         call CVLdrv (iErr, ipA, iMA)
         call ACCrep (FPL(ipA), 0)
      endif
      call DevFin (iErr)
      STOP
      END
#endif /* CVGLST_SKIP_PROGRAM */
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
