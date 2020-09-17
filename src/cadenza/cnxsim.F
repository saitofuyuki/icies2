C cadenza/cnxsim.F --- IcIES/Cadenza/NetCDF conversion
C Author: SAITO Fuyuki
C Created: Apr 18 2012
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2020/09/15 11:53:18 fuyuki cnxsim.F>'
#define _FNAME 'cadenza/cnxsim.F'
#define _REV   'Snoopy0.8'
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
#include "ofdlct.h" /* fortran dialect */
#include "ologfm.h" /* logging */
#include "ofnstd.h"
CC #include "oarpea.h"
#include "oarpfi.h"
#include "odevva.h"
#include "odevel.h"
#include "oarpkw.h"   /* operation id in arpeggio/kiwi */
CCC_* Macros
#ifndef   CNXSIM_SKIP_PROGRAM
#  define CNXSIM_SKIP_PROGRAM 0
#endif
c
#ifndef   AKW_CLS
#  define AKW_CLS 'V'
#endif
CCC_ + Buffers
#ifndef   CNXSIM_BUFFER_MAX
#  define CNXSIM_BUFFER_MAX 4194304
#endif
#ifndef   CNXSIM_GLOBAL_BUFFER_MAX
#  define CNXSIM_GLOBAL_BUFFER_MAX CNXSIM_BUFFER_MAX
#endif
#ifndef   CNXSIM_GLOBAL_TABLE_MAX
#  define CNXSIM_GLOBAL_TABLE_MAX  CNXSIM_BUFFER_MAX
#endif
c
#ifndef   CNXSIM_COOR_MAX
#  define CNXSIM_COOR_MAX 16
#endif
#ifndef   CNXSIM_TAG_MAX
#  define CNXSIM_TAG_MAX 32
#endif
#ifndef   CNXSIM_VARENTRY_MAX
#  define CNXSIM_VARENTRY_MAX 256
#endif
#ifndef   CNXSIM_TAG_LEN
#  define CNXSIM_TAG_LEN 8
#endif
#ifndef   CNXSIM_VALUE_LEN
#  define CNXSIM_VALUE_LEN 80
#endif
CCC_& CNXcor  ## Conversion get coordinate
CCC_& CNXcxg  ## Conversion main (cluster group batch)
      subroutine CNXcxg
     O    (iErr,
     I     VGRP,  CROOT,
     I     NRarg, KANCH, VTBL,  VCO,   VCOGR,
     I     FNM,   ipA,   iMA)
CCC_ + Declaration
      implicit none
c
      include 'netcdf.inc'
CCC_  - Arguments
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   ipA (*)
      _INTENT(IN, integer)   iMA (*)
      _INTENT(IN, integer)   NRarg
      _INTENT(IN, integer)   KANCH
      _INTENT(IN, character) VGRP  *(*)
      _INTENT(IN, character) CROOT *(*)
      _INTENT(IN, character) VTBL  *(*)
      _INTENT(IN, character) VCO   *(*)
      _INTENT(IN, character) VCOGR *(*)
      _INTENT(IN, character) FNM   *(*)
CCC_  - Parameters
      integer    LIE
      parameter (LIE    = CNXSIM_GLOBAL_TABLE_MAX)
      integer    LV
      parameter (LV     = CNXSIM_GLOBAL_BUFFER_MAX)
      integer    LW
      parameter (LW     = LV)
      integer    MaxCo
      parameter (MaxCo  = CNXSIM_COOR_MAX)
      integer    MaxVar
      parameter (MaxVar = CNXSIM_VARENTRY_MAX)
      integer    LTV
      parameter (LTV    = CNXSIM_TAG_MAX)
      integer    LTX
      parameter (LTX    = LTV)
c
      integer    Ltag, Lval
      parameter (Ltag   = CNXSIM_TAG_LEN)
      parameter (Lval   = CNXSIM_VALUE_LEN)
CCC_  - Interior
      integer    IE    (LIE)
      integer    kgTBL (LV)
      _REALSTD   SV    (LV)
      _REALSTD   SS    (LV, MaxCo)
      _REALSTD   W     (LW)
c
      character  TV   (LTV)*(Ltag)
      character  TagT (LTV)*(Ltag)
      character  TagX (LTX)*(Ltag)
c
      character  Colv (LTV)*(Lval), Val  (LTV)*(Lval)
      character  ColT (LTV)*(Lval), ValT (LTV)*(Lval)
      character  ColX (LTX)*(Lval), ValX (LTX)*(Lval)
c
      character  Attr (LTV)*(Lval), Expl (LTV)*(Lval)
c
      integer    NTV,   NtagT,  NtagX
      integer    NTVini
c
      real*8     TM
      integer    MG, MR
      integer    IR, NRi
      logical    Omatch
      integer    jco, NCO
      integer    jd,  K0
      integer    jv, kv, NKV, KV0
      integer    LPa (3)
c
      integer    jiITM
      integer    jiREC, jiTIME, jiCKV, jiKV, jiCBAS
c
      integer    ipL, ipC, ipP, ipV
c
      character VITEM*(Lval), VC*(Lval)
CCC_   . for netcdf
      integer    ncid
      integer    jnerr
      integer    idX (MaxCo), ivX (MaxCo), NX  (MaxCo)
      integer    idT, ivT
      integer    ivV (MaxVar)
c
      integer    krank
      integer    kdims  (MaxCo), kstart (MaxCo), kcount (MaxCo)
      integer    irec, irecm, irecc, nrecv, jrecr, jrecn
c
      integer    mrd, mra, nskp
CCC_ + Body
      iErr = 0
c
      ipL  = FPL(ipA)
      ipC  = FPC(ipA)
      ipP  = FPP(ipA)
      ipV  = FPV(ipA)
c
      K0  = 1
      mrd = 0
c
 101  format ('TARGET [', I0, '] ', A, '/')
 102  format ('SEARCH [', I0, '] ', I0)
 103  format ('NKV [', A, '] ', I0)
 105  format ('IRECM: ', I0)
 106  format ('RECORD CONVERSION: ', I0, 1x, I0, 1x, I0)
 107  format ('RECORD SKIP: ', I0, 1x, I0, 1x, I0)
 104  format ('RECORD FWD: ', I0, 1x, I0)
 401  format ('NCO: ', A, ':', I4)
c
 801  format ('PHASE [', I0, '] ', A, '/')
c
      if (COND_N(ipL)) then
         write (ipL, 101)
     $        mrd, _TRIM(VGRP)
      else if (COND_S(ipL)) then
         write (*,   101)
     $        mrd, _TRIM(VGRP)
      endif
c
CCC_  - find anchor (group)
      NTV = 0
      call UKAsvA (jiITM,  TV, ColV, NTV, LTV, K0, 'ITEM',  ' ')
      call UKAsvA (jd,     TV, ColV, NTV, LTV, K0, 'GROUP', VGRP)
      call UKAsvA (jd,     TV, ColV, NTV, LTV, K0, 'CSFX',  ' ')
      call UKAsvA (jd,     TV, ColV, NTV, LTV, K0, 'CROOT', CROOT)
      call UKAsvA (jiREC,  TV, ColV, NTV, LTV, K0, 'REC',   ' ')
      call UKAsvA (jiTIME, TV, ColV, NTV, LTV, K0, 'TIME',  ' ')
c
      call UKAsvA (jiKV,   TV, ColV, NTV, LTV, K0, 'KV',    ' ')
      call UKAsvA (jiCKV,  TV, ColV, NTV, LTV, K0, 'CKV',   ' ')
      call UKAsvA (jiCBAS, TV, ColV, NTV, LTV, K0, 'CBASE', ' ')
c
      call UKDkaa (iErr, TV, NTV, LTV, K0, ColV,  'GV0', ipL)
CCC_  - find anchor (item)
      NTVini = NTV
c
      call UUrwnd (iErr, ipP)
CCC_  - collation (first)
      mra = 0
      DO
         NTV = NTVini
         call DVTcol
     $       (iErr,
     $        nskp, NTV, TV, Val, Attr, Expl, ColV, Kanch, LTV, ipP)
         mra = mra + nskp
         if (iErr.ne.0) goto 800
         Omatch = .true.
         IR = -999
         call DVTcmp (Omatch, TV, Val, NTV, LTV, IR, NRarg)
         if (Omatch) goto 800
      enddo
 800  continue
      if (COND_N(ipL)) then
         write (ipL, 102) mra, iErr
      else if (COND_S(ipL)) then
         write (*,   102) mra, iErr
      endif
      call UKDkaa (iErr, TV, NTV, LTV, K0, Val,  'GV1', ipL)
c
      call ACVgdm (NKV, ' ', Val (jiCKV), ipP, ipC)
      if (COND_N(ipL)) then
         write (ipL, 103) _TRIM(Val (jiCKV)), NKV
      else if (COND_S(ipL)) then
         write (*,   103) _TRIM(Val (jiCKV)), NKV
      endif
CCC_  - unset RECORD if no-rec variable
      if (Val (jiREC).eq.' ') then
         jiREC = K0 - 1
         irecm = 1
      else
         read (Val (jiREC), *) irecm
      endif
      if (COND_N(ipL)) then
         write (ipL, 105) irecm
      else if (COND_S(ipL)) then
         write (*,   105) irecm
      endif
      if (Val (jiTIME).eq.' ') jiTIME = K0 - 1
CCC_  - NR adjustment
      if (NRarg.ge.0) then
         NRi = NRarg
      else
         call  DVTqmp (IR, NRi, TV,  Val, NTV, LTV)
      endif
CCC_  - NetCDF creation
      jnerr = NF_CREATE (FNM, NF_CLOBBER, ncid)
      call CNXchk (jnerr)
CCC_  - get global coordinates
      call ACVnco (iErr, NCO, TV, Val, NTV, LTV)
      VITEM = Val (jiITM)
      if (COND_N(ipL)) then
         write (ipL, 401) _TRIM(VITEM), NCO
      else if (COND_S(ipL)) then
         write (*,   401) _TRIM(VITEM), NCO
      endif
      do jco = 1, NCO
         call AFSgpc
     O       (iErr,
     O        SS (1, jco), MG,
     O        TagX,  ColX, NtagX, LTX,
     O        ValX,  Attr, Expl,
     I        TV,    Val,  NTV,   LTV,
     I        VCOGR, VCO,  jco,   LV,    ipP,  ipC,  ipL)
         call UKDkaa (iErr, TagX, NtagX, LTX, K0, ValX,  'X', ipL)
c
         call UKStgA (jd, TagX, NtagX, LTX, K0, 'CNAME')
         if (jd.ge.K0) then
            VC = ValX (jd)
         else
            call UKStgA (jd, TagX, NtagX, LTX, K0, 'CBASE')
            if (jd.ge.K0) then
               VC = ValX (jd)
            else
 301           format ('X', I2.2)
               write (VC, 301) jco
            endif
         endif
         jnerr = NF_DEF_DIM (ncid, VC, MG, idX (jco))
         call CNXchk (jnerr)
c
         krank = 1
         kdims (1) = idX (jco)
         jnerr = NF_DEF_VAR
     $        (ncid, VC, NF_DOUBLE, krank, kdims, ivX (jco))
         call CNXchk (jnerr)
         NX (jco) = MG
      enddo
CCC_  - coordinates (time)
      if (jiTIME.ge.K0) then
         jnerr = NF_DEF_DIM (ncid, 'time', NF_UNLIMITED,  idT)
         krank = 1
         kdims (1) = idT
         jnerr = NF_DEF_VAR (ncid, 'time', NF_DOUBLE, krank, kdims, ivT)
      endif
CCC_  - variable
      do jco = 1, NCO
         kdims (jco) = idX (jco)
      enddo
      krank = NCO
      if (jiTIME.ge.K0) then
         krank = krank + 1
         kdims (krank) = idT
      endif
      do jco = 1, NCO
         kstart (jco) = 1
         kcount (jco) = NX (jco)
      enddo
c
 108  format ('CLUSTER ENTRY: ', I0, 1x, A)
 109  format ('CLUSTER SKIP: ',  I0)
      KV0 = NKV + 1
      do jv = 1, NKV
         if (COND_N(ipL)) then
            write (ipL, 801) jv, 'CHECK'
         else if (COND_S(ipL)) then
            write (*,   801) jv, 'CHECK'
         endif
         call UUrwnd (iErr, ipP)
CCC_   . collation (individual)
         mra = 0
         call DVTsvi (ColV (jiKV), jv)
         DO
            NTV = NTVini
            call DVTcol
     $          (iErr,
     $           nskp, NTV, TV, Val, Attr, Expl, ColV, Kanch, LTV, ipP)
            mra = mra + nskp
            if (iErr.ne.0) goto 1800
            Omatch = .true.
            IR = -999
            call DVTcmp (Omatch, TV, Val, NTV, LTV, IR, NRarg)
            if (Omatch) goto 1800
         enddo
 1800    continue
         if (COND_N(ipL)) then
            write (ipL, 102) mra, iErr
         else if (COND_S(ipL)) then
            write (*,   102) mra, iErr
         endif
         call UKDkaa (iErr, TV, NTV, LTV, K0, Val,  'GV2', ipL)
c
         VITEM = Val (jiITM)
         if (VITEM.eq.' ') then
            if (COND_N(ipL)) then
               write (ipL, 109) jv
            else if (COND_S(ipL)) then
               write (*,   109) jv
            endif
         else
            call USJnta (VITEM, '.', Val (jiCBAS))
            if (COND_N(ipL)) then
               write (ipL, 108) jv, _TRIM (VITEM)
            else if (COND_S(ipL)) then
               write (*,   108) jv, _TRIM (VITEM)
            endif
            read  (Val (jiKV), *) kv
            kv0 = MIN (kv0, kv)
c
            jnerr = NF_DEF_VAR
     $           (ncid, VITEM, NF_DOUBLE, krank, kdims, ivV (jv))
            call CNXchk (jnerr)
         endif
      enddo
CCC_  - global attributes
      jnerr = NF_PUT_ATT_TEXT
     $     (ncid, NF_GLOBAL, 'Conventions', 13, 'COARDS/CF-1.0')
      call CNXchk (jnerr)
CCC_  - end definition
      jnerr = NF_ENDDEF (NCID)
      call CNXchk (jnerr)
CCC_  - set coordinates
      do jco = 1, NCO
         jnerr = NF_PUT_VARA_DOUBLE
     $        (ncid, ivX (jco), 1, NX (jco), SS (1, jco))
c$$$         write (*, *) jco, ivX (jco), NX (jco)
c$$$         write (*, *) (SS (j, jco), j = 1, NX (jco))
         call CNXchk (jnerr)
      enddo
CCC_  - get global collection table
      call AFSgtx
     O    (iErr,
     O     kgTbl, LV,    LPa,    MG,
     W     IE,    LIE,
     O     TagT,  ColT,  NtagT,  LTV,
     O     ValT,  Attr,  Expl,
     I     TV,    Val,   NTV,    LTV,
     I     VTBL,  NRi,   ipP,    ipC,    ipL)
CCC_  - Loop to read variables
      irec   = 0
      irecc  = 1
      jrecn  = 0
      DO
         if (COND_N(ipL)) then
            write (ipL, 801) irec, 'READ'
         else if (COND_S(ipL)) then
            write (*,   801) irec, 'READ'
         endif
         if (jrecn.gt.0) then
            irec  = jrecn
            jrecn = 0
         else
            irec  = irec + 1
         endif
         nrecv = 0
         do jv = KV0, NKV
            if (COND_N(ipL)) then
               write (ipL, 801) jv, 'READ KV'
            else if (COND_S(ipL)) then
               write (*,   801) jv, 'READ KV'
            endif
            mra = 0
            call UUrwnd (iErr, ipP)
            NTV = NTVini
c$$$            if (jiREC.ge.K0) call DVTsvi (ColV (jiREC), irec)
            if (jiREC.ge.K0) ColV (jiREC) = ' '
            ColV (jiTIME) = ' '
            ColV (jiITM)  = ' '
            call UKAsvA (jd,     TV, ColV, NTV, LTV, K0, 'CSFX',  ' ')
            call UKAsvA (jiCBAS, TV, ColV, NTV, LTV, K0, 'CBASE', ' ')
            call DVTsvi (ColV (jiKV), jv)
            call UKDkaa (iErr, TV, NTV, LTV, K0, ColV,  'RT', ipL)
            DO
               NTV = NTVini
               call DVTcol
     $             (iErr,
     $              nskp, NTV, TV, Val, Attr,Expl,ColV,Kanch,LTV,ipP)
               mra = mra + nskp
               if (iErr.ne.0) goto 2900
               Omatch = .true.
               if (jiREC.ge.K0) then
                  read (Val (jiREC), *) jrecr
                  Omatch = (irec.eq.jrecr)
                  if (jrecn.eq.0 .or. jrecr.lt.jrecn) then
                     if (jrecr.gt.irec) jrecn = jrecr
                  endif
c$$$                  write (ipL, *) irec, jrecr, jrecn
               endif
               if (Omatch) then
                  IR = -999
                  call DVTcmp (Omatch, TV, Val, NTV, LTV, IR, NRi)
               endif
               if (Omatch) goto 2900
            enddo
 2900       continue
            if (COND_N(ipL)) then
               write (ipL, 102) mra, iErr
            else if (COND_S(ipL)) then
               write (*,   102) mra, iErr
            endif
            if (iErr.eq.0) then
               call UKDkaa (iErr, TV, NTV, LTV, K0, Val, 'RV', ipL)
            endif
            if (iErr.eq.0) then
               NTV = NTVini
CCC_   . get variable globally
               call UUrwnd (iErr, ipP)
            endif
            if (iErr.eq.0) then
               call AFSggs
     O             (iErr,
     O              SV,    MR,
     W              W,
     M              TV,    ColV,  NTV,    LTV,
     M              Val,   Attr,  Expl,
     I              kgTbl, LPa,   MG,
     I              NRi,   LV,    LW,     ipP,   ipC,    ipL)
            else
               MR = -1
            endif
            if (iErr.eq.0) then
               nrecv = nrecv + 1
               if (COND_N(ipL)) then
                  write (ipL, 106) irec, irecc, nrecv
               else if (COND_S(ipL)) then
                  write (*,   106) irec, irecc, nrecv
               endif
               call UKDkaa (iErr, TV, NTV, LTV, K0, Val,  'V', ipL)
               if (jiTIME.ge.K0) then
                  kstart (krank) = irecc
                  kcount (krank) = 1
               endif
               jnerr = NF_PUT_VARA_DOUBLE
     $              (ncid, ivV (jv), kstart, kcount, SV)
               call CNXchk (jnerr)
               if (jiTIME.ge.K0) then
                  read (Val (jiTIME), *) TM
                  jnerr = NF_PUT_VARA_DOUBLE (ncid, ivT, irecc, 1, TM)
               endif
            else if (irec.lt.irecm) then
               if (COND_N(ipL)) then
                  write (ipL, 107) irec, irecm, irecc
               else if (COND_S(ipL)) then
                  write (*,   107) irec, irecm, irecc
               endif
            else if (jrecn.gt.0) then
               if (COND_N(ipL)) then
                  write (ipL, 104) irec, jrecn
               else if (COND_S(ipL)) then
                  write (*,   104) irec, jrecn
               endif
            else
               if (MR.le.0) iErr = 0
               goto 990
            endif
         ENDDO
         if (nrecv.gt.0) irecc = irecc + 1
         if (jiREC.lt.K0) goto 990
      ENDDO
CCC_  - Fine
 990  continue
      if (COND_N(ipL)) then
         write (ipL, 801) 99, 'Fine'
      else if (COND_S(ipL)) then
         write (*,   801) 99, 'Fine'
      endif
      jnerr = NF_CLOSE (ncid)
      call CNXchk (jnerr)
      call DAtrcU (ipL, iErr, 'R', 'CNXCXG')
      RETURN
      END
CCC_& CNXchk
      subroutine CNXchk (jErr)
      implicit none
      include 'netcdf.inc'
      integer jErr
      if (jerr .ne. NF_NOERR) then
         write (*, *) nf_strerror (jerr)
      endif
      RETURN
      END
CCC_& CNXdrv  ## Driver
      subroutine CNXdrv (iErr, ipA, iMA)
CCC_ + Declaration
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(IN, integer) ipA (*)
      _INTENT(IN, integer) iMA (*)
c
      integer    ipL, ipC, ipP, ipV
c
      integer    Lattr
      parameter (Lattr = 16)
c
      character  CLS*(Lattr)
      character  CROOT*(Lattr), CSFX*(Lattr)
      character  VITEM*(Lattr), VGRP*(Lattr), VSUB*(Lattr)
      character  VTBL *(Lattr), VCO*(Lattr),  VCOGR*(Lattr)
      integer    KANCH
      integer    NR
c
      character  FNM  *(OPT_FILENAME_MAX)
c
      namelist /NICNXS/
     $     VITEM, VGRP, VSUB,
     $     CROOT, CSFX,
     $     NR,    KANCH, VTBL, VCO, VCOGR,
     $     FNM
CCC_ + Body
      iErr = 0
      ipL  = FPL(ipA)
      ipC  = FPC(ipA)
      ipP  = FPP(ipA)
      ipV  = FPV(ipA)
c
      call UUrwnd (iErr, ipP)
c
      NR     = -1
      CLS    = AKW_CLS
      CROOT  = 'ID'
      CSFX   = 'a'
      VITEM  = ' '
      VGRP   = 'VMB'
      VSUB   = ' '
      VTBL   = 'IE'
c$$$      VCO    = 'CO'
      VCO    = 'CP'
      VCOGR  = ' '
      KANCH  = 0
      FNM    = 'out.nc'
c
      read  (ipP, NICNXS, IOSTAT = iErr)
      if (COND_N(ipC)) then
         write (ipC, NICNXS)
      else if (COND_S(ipC)) then
         write (*,   NICNXS)
      endif
c
c$$$      call CNXcxt
c$$$     $    (iErr,
c$$$     $     VITEM, VGRP,  VSUB, CROOT, CSFX,
c$$$     $     NR,    KANCH, VTBL, VCO,   VCOGR,
c$$$     $     FNM,   ipA,   iMA)
c
      call CNXcxg
     O    (iErr,
     I     VGRP,  CROOT,
     I     NR,    KANCH, VTBL, VCO,   VCOGR,
     I     FNM,   ipA,   iMA)
c
      RETURN
      END
CCC_& CNXSIM  ## IcIES/Cadenza/NetCDF announcement
      subroutine CNXSIM (STRA, STRB, IOP)
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
CCC_@ CNXPRG  ## Cadenza/NetCDF program
#if CNXSIM_SKIP_PROGRAM == 0
      program CNXPRG
CCC_ + Declaration
#include "odevid.h"  /* MPI table */
      implicit none
      integer iErr
      integer ipA (LOG_CHANNEL_MAX)
      integer iMA (MAX_MPI_ATTR)
CCC_ + Body
c$$$      call DDcapo
c$$$     O    (iErr,
c$$$     I     2, ' ', ' ', _FNAME, -1)
      call DDsmpl (iErr)
      if (iErr.eq.0) then
         call DLCmng (ipA, 't')
         call DVHrgC (iErr, ' ', ' ', ' ', ipA)
      endif
      if (iErr.eq.0) then
         call DMAtma (iMA)
         call CNXdrv (iErr, ipA, iMA)
         call ACCrep (FPL(ipA), 0)
      endif
      call DevFin (iErr)
      STOP
      END
#endif /* CNXSIM_SKIP_PROGRAM */
CCC_* Obsolete
#if 0 /* obsolete */
CCC_ & CNXcxt  ## Conversion main
      subroutine CNXcxt
     O    (iErr,
     I     VITEM, VGRP,  VSUB, CROOT, CSFX,
     I     NRarg, KANCH, VTBL, VCO,   VCOGR,
     I     FNM,   ipA,   iMA)
CCC_  - Declaration
      implicit none
c
      include 'netcdf.inc'
c
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   ipA (*)
      _INTENT(IN, integer)   iMA (*)
      _INTENT(IN, integer)   NRarg
      _INTENT(IN, integer)   KANCH
      _INTENT(IN, character) VITEM*(*)
      _INTENT(IN, character) VGRP*(*)
      _INTENT(IN, character) VSUB*(*)
      _INTENT(IN, character) CROOT*(*)
      _INTENT(IN, character) CSFX*(*)
      _INTENT(IN, character) VTBL*(*)
      _INTENT(IN, character) VCO*(*)
      _INTENT(IN, character) VCOGR*(*)
      _INTENT(IN, character) FNM*(*)
c
      integer   ipL, ipC, ipP, ipV
c
      integer    LIE
      parameter (LIE   = 65536)
      integer    IE (LIE)
      integer    lgTBL
      parameter (lgTBL = 65536)
      integer    kgTBL (lgTBL)
c
      integer    NRi
      integer    jd, K0
      integer    LTV
      parameter (LTV = 32)
      integer    NTV,   NtagT
      character  Val   (LTV)*80
      character  Attr  (LTV)*8,  Expl (LTV)*32
      character  TV    (LTV)*8,  Colv  (LTV)*80
      character  TagT  (LTV)*8,  ColvT (LTV)*80, ValT (LTV)*(80)
      integer    LtagX, NtagX
      parameter (LtagX = LTV)
      character  ColX (LtagX)*80, ValX (LtagX)*80
      character  TagX (LtagX)*8
      logical    Omatch
      integer    NTVini
      integer    jco, NCO
c
      character  VC * 16
      integer    jiREC, jiTIME
c
      integer    MaxCo
      parameter (MaxCo = 5)
c
      integer    LV
      parameter (LV = 65536)
      _REALSTD   SV (LV)
      _REALSTD   SS (LV, MaxCo)
c
      integer    LW
      parameter (LW = LV)
      _REALSTD   W  (LW)
c

      integer   ncid
      integer   jnerr
      integer   idX (MaxCo), ivX (MaxCo), NX  (MaxCo)
      integer   idT, ivT
      integer   ivV
      real*8    TM
c
      integer   krank, kdims (16)
      integer   kstart (16), kcount (16)
      integer   irec
      integer   MG
c
      integer   mrd, mra, nskp
      integer   IR
c
CCC_  - Body
      iErr = 0
c
      ipL  = FPL(ipA)
      ipC  = FPC(ipA)
      ipP  = FPP(ipA)
      ipV  = FPV(ipA)
c
 101  format ('TARGET [', I0, '] ', A, '/', A, '/', A)
 102  format ('SEARCH [', I0, '] ', I0)
 401  format ('NCO: ', A, ':', I4)
c$$$ 402  format ('CO[', I1, '] ', I3, 1x, F10.1)
c
      mrd = 0
      if (COND_N(ipL)) then
         write (ipL, 101)
     $        mrd, _TRIM(VGRP), _TRIM(VITEM), _TRIM(VSUB)
      else if (COND_S(ipL)) then
         write (*,   101)
     $        mrd, _TRIM(VGRP), _TRIM(VITEM), _TRIM(VSUB)
      endif
      K0 = 1
CCC_   . find anchor
      NTV = 0
      call UKAstA (jd, TV, NTV, LTV, K0, 'ITEM')
      if (jd.le.LTV) ColV (jd) = VITEM
      call UKAstA (jd, TV, NTV, LTV, K0, 'GROUP')
      if (jd.le.LTV) ColV (jd) = VGRP
c$$$      call UKAstA (jd, TV, NTV, LTV, K0, 'SUB')
c$$$      if (jd.le.LTV) ColV (jd) = VSUB
      call UKAstA (jd, TV, NTV, LTV, K0, 'CSFX')
      if (jd.le.LTV) ColV (jd) = CSFX
      call UKAstA (jd, TV, NTV, LTV, K0, 'CROOT')
      if (jd.le.LTV) ColV (jd) = CROOT
      call UKAstA (jiREC, TV, NTV, LTV, K0, 'REC')
      if (jiREC.le.LTV) ColV (jiREC) = ' '
      call UKAstA (jiTIME, TV, NTV, LTV, K0, 'TIME')
      if (jiTIME.le.LTV) ColV (jiTIME) = ' '
c
      call UKDkaa (iErr, TV, NTV, LTV, K0, ColV,  'V0', ipL)
c
      call UUrwnd (iErr, ipP)
      NTVini = NTV
CCC_   . collation (first)
      mra = 0
      DO
         NTV = NTVini
         call DVTcol
     $       (iErr,
     $        nskp, NTV, TV, Val, Attr, Expl, ColV, Kanch, LTV, ipP)
         mra = mra + nskp
         if (iErr.ne.0) goto 800
         Omatch = .true.
         IR = -999
         call DVTcmp (Omatch, TV, Val, NTV, LTV, IR, NRarg)
         if (Omatch) goto 800
      enddo
 800  continue
      if (COND_N(ipL)) then
         write (ipL, 102) mra, iErr
      else if (COND_S(ipL)) then
         write (*,   102) mra, iErr
      endif
      call UKDkaa (iErr, TV, NTV, LTV, K0, Val,  'V', ipL)
CCC_   . unset RECORD if no-rec variable
      if (Val (jiREC).eq.' ') jiREC = K0 - 1
      if (Val (jiTIME).eq.' ') jiTIME = K0 - 1
CCC_   . NR adjustment
      if (NRarg.ge.0) then
         NRi = NRarg
      else
         call  DVTqmp (IR, NRi, TV,  Val, NTV, LTV)
      endif
CCC_   . NetCDF creation
      jnerr = NF_CREATE (FNM, NF_CLOBBER, ncid)
      call CNXchk (jnerr)
CCC_   . get global coordinates
      call ACVnco (iErr, NCO, TV, Val, NTV, LTV)
      if (COND_N(ipL)) then
         write (ipL, 401) _TRIM(VITEM), NCO
      else if (COND_S(ipL)) then
         write (*,   401) _TRIM(VITEM), NCO
      endif
      do jco = 1, NCO
         call AFSgpc
     O       (iErr,
     O        SS (1, jco), MG,
     O        TagX,  ColX, NtagX, LtagX,
     O        ValX,  Attr, Expl,
     I        TV,    Val,  NTV,   LTV,
     I        VCOGR, VCO,  jco,   LV,    ipP,  ipC,  ipL)
         call UKDkaa (iErr, TagX, NtagX, LtagX, K0, ValX,  'X', ipL)
c
         call UKStgA (jd, TagX, NtagX, LtagX, K0, 'CNAME')
         if (jd.ge.K0) then
            VC = ValX (jd)
         else
            call UKStgA (jd, TagX, NtagX, LtagX, K0, 'CBASE')
            if (jd.ge.K0) then
               VC = ValX (jd)
            else
 301           format ('X', I2.2)
               write (VC, 301) jco
            endif
         endif
         jnerr = NF_DEF_DIM (ncid, VC, MG, idX (jco))
         call CNXchk (jnerr)
c
         krank = 1
         kdims (1) = idX (jco)
         jnerr = NF_DEF_VAR
     $        (ncid, VC, NF_DOUBLE, krank, kdims, ivX (jco))
         call CNXchk (jnerr)
         NX (jco) = MG
      enddo
CCC_   . coordinates (time)
      if (jiTIME.ge.K0) then
         jnerr = NF_DEF_DIM (ncid, 'time', NF_UNLIMITED,  idT)
         krank = 1
         kdims (1) = idT
         jnerr = NF_DEF_VAR (ncid, 'time', NF_DOUBLE, krank, kdims, ivT)
      endif
CCC_   . variable
      do jco = 1, NCO
         kdims (jco) = idX (jco)
      enddo
      krank = NCO
      if (jiTIME.ge.K0) then
         krank = krank + 1
         kdims (krank) = idT
      endif
      do jco = 1, NCO
         kstart (jco) = 1
         kcount (jco) = NX (jco)
      enddo
c
      jnerr = NF_DEF_VAR (ncid, VITEM, NF_DOUBLE, krank, kdims, ivV)
      call CNXchk (jnerr)
CCC_   . else
      jnerr = NF_PUT_ATT_TEXT
     $     (ncid, NF_GLOBAL, 'Conventions', 13, 'COARDS/CF-1.0')
      call CNXchk (jnerr)
CCC_   . end definition
      jnerr = NF_ENDDEF (NCID)
CCC_   . set coordinates
      call CNXchk (jnerr)
      do jco = 1, NCO
         jnerr = NF_PUT_VARA_DOUBLE
     $        (ncid, ivX (jco), 1, NX (jco), SS (1, jco))
      enddo
CCC_   . get global collection table
      call AFSgtx
     O    (iErr,
     O     kgTbl, lgTbl,
     W     IE,    LIE,
     O     TagT,  ColvT, NtagT,  LTV,
     O     ValT,  Attr,  Expl,
     I     TV,    Val,   NTV,    LTV,
     I     VTBL,  NRi,   ipP,    ipC,    ipL)
CCC_   . Loop to read variables
      irec   = 0
      DO
         irec = irec + 1
         call UUrwnd (iErr, ipP)
         mra = 0
         NTV = NTVini
         if (jiREC.ge.K0) call DVTsvi (ColV (jiREC), irec)
         ColV (jiTIME) = ' '
         call UKDkaa (iErr, TV, NTV, LTV, K0, ColV,  'RT', ipL)
         DO
            NTV = NTVini
            call DVTcol
     $          (iErr,
     $           nskp, NTV, TV, Val, Attr, Expl, ColV, Kanch, LTV, ipP)
            mra = mra + nskp
            if (iErr.ne.0) goto 900
            Omatch = .true.
            IR = -999
            call DVTcmp (Omatch, TV, Val, NTV, LTV, IR, NRi)
            if (Omatch) goto 900
         enddo
 900     continue
         if (COND_N(ipL)) then
            write (ipL, 102) mra, iErr
         else if (COND_S(ipL)) then
            write (*,   102) mra, iErr
         endif
         if (iErr.eq.0) then
            call UKDkaa (iErr, TV, NTV, LTV, K0, Val,  'RV', ipL)
         endif
         if (iErr.eq.0) then
c$$$         write (*, *) irec
c$$$         call DVTsvi (ColV (jiREC), irec)
            NTV = NTVini
CCC_    * get variable globally
            call UUrwnd (iErr, ipP)
         endif
         if (iErr.eq.0) then
            call AFSggs
     O          (iErr,
     O           SV,    MG,
     W           W,
     M           TV,    ColV,  NTV,    LTV,
     M           Val,   Attr,  Expl,
     I           kgTbl,
     I           NRi,   LV,    LW,     ipP,   ipC,    ipL)
         else
            MG = -1
         endif
         if (iErr.eq.0) then
            call UKDkaa (iErr, TV, NTV, LTV, K0, Val,  'V', ipL)
            if (jiTIME.ge.K0) then
               kstart (krank) = irec
               kcount (krank) = 1
            endif
            jnerr = NF_PUT_VARA_DOUBLE (ncid, ivV, kstart, kcount, SV)
            call CNXchk (jnerr)
            if (jiTIME.ge.K0) then
               read (Val (jiTIME), *) TM
               jnerr = NF_PUT_VARA_DOUBLE (ncid, ivT, irec, 1, TM)
            endif
         else
            if (MG.le.0) iErr = 0
            goto 990
         endif
         if (jiREC.lt.K0) goto 990
      ENDDO
 990  continue
      jnerr = NF_CLOSE (ncid)
      call CNXchk (jnerr)
      RETURN
      END
#endif /* 0 obsolete */
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
