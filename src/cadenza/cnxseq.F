C cadenza/cnxseq.F --- IcIES/Cadenza/NetCDF conversion (sequential variation)
C Maintainer:  SAITO Fuyuki
C Created: Apr 3 2013 (fork from cnxsim)
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2020/09/17 08:42:03 fuyuki cnxseq.F>'
#define _FNAME 'cadenza/cnxseq.F'
#define _REV   'Snoopy0.97'
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
#ifndef   CNXSEQ_SKIP_PROGRAM
#  define CNXSEQ_SKIP_PROGRAM 0
#endif
c
#ifndef   AKW_CLS
#  define AKW_CLS 'V'
#endif
CCC_ + Buffers
#ifndef   CNXSEQ_BUFFER_MAX
#  define CNXSEQ_BUFFER_MAX 4194304
#endif
#ifndef   CNXSEQ_GLOBAL_BUFFER_MAX
#  define CNXSEQ_GLOBAL_BUFFER_MAX CNXSEQ_BUFFER_MAX
#endif
#ifndef   CNXSEQ_GLOBAL_TABLE_MAX
#  define CNXSEQ_GLOBAL_TABLE_MAX  CNXSEQ_BUFFER_MAX
#endif
c
#ifndef   CNXSEQ_COOR_MAX
#  define CNXSEQ_COOR_MAX 32
#endif
#ifndef   CNXSEQ_COOR_VLIM
#  define CNXSEQ_COOR_VLIM 65536
#endif
#ifndef   CNXSEQ_TAG_MAX
#  define CNXSEQ_TAG_MAX 32
#endif
#ifndef   CNXSEQ_VARENTRY_MAX
#  define CNXSEQ_VARENTRY_MAX 512
#endif
#ifndef   CNXSEQ_TAG_LEN
#  define CNXSEQ_TAG_LEN 8
#endif
#ifndef   CNXSEQ_VALUE_LEN
#  define CNXSEQ_VALUE_LEN 80
#endif
CCC_& CNQchk  ## netcdf error monitoring
      subroutine CNQchk (jErr)
      implicit none
      include 'netcdf.inc'
      integer jErr
      if (jerr .ne. NF_NOERR) then
         write (*, *) nf_strerror (jerr)
      endif
      RETURN
      END
CCC_& CNQncd  ## netCDF definition
      subroutine CNQncd
     O    (iErr,
     O     ncID,  ncXI,  ncXV, ncTI, ncTV, ncSSV, ncVV,
     O     ncTPO, ncCNT, LNC,
     O     TT,    VV,    CV,   AA,   EE,   NT,    LT,
     I     TG,    VG,    NTG,  LTG,  K0,
     I     Nco,   NCM,
     I     Coor,  Ncnm,  CNM,  LCV,  CTkind,
     I     MAXV,  ivST,  ivEN,
     I     FNM,
     I     ipI,   ipO,   ipE,  itMEM)
CCC_ + Declaration
      implicit none
      include 'netcdf.inc'
c
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   NCID
      _INTENT(OUT,integer)   ncXI  (*), ncXV  (*)
      _INTENT(IN, integer)   LNC
      _INTENT(OUT,integer)   ncTPO (*)
      _INTENT(OUT,integer)   ncCNT (LNC, *)
      _INTENT(OUT,integer)   ncVV (*)
      _INTENT(OUT,integer)   ncTI, ncTV, ncSSV
c
      _INTENT(IN, integer)   LCV
      _INTENT(IN, integer)   Nco, Ncnm
      _INTENT(IN, integer)   NCM (*)
      _INTENT(IN, character) CNM (2,*)*(*)
      _INTENT(IN, _REALSTD)  Coor(LCV, *)
      _INTENT(IN, character) CTkind*(*)
c
      _INTENT(IN, integer)   MAXV,  ivST, ivEN
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
      _INTENT(IN, character) FNM*(*)
      _INTENT(IN, integer)   ipI, ipO, ipE
      _INTENT(IN, integer)   itMEM
c
      integer    MaxDim
      parameter (MaxDim = 32)
c
      integer jnerr
      integer jco, jv
      integer krank
      integer kdims (MaxDim)
      character CPRM (MaxDim)*32
      integer   nprm
c
      character VNM*(64)
      character CKX*(32)
c
      integer Kanch
c$$$      integer jmv
      integer jit, jbs, jkd, jsx, jkv, jcs
      integer nskp
      integer NTini
      integer jc, kco
      integer jcr, jss
      integer KV
      integer jsubs
c
      integer jci, jct
      integer jXCO (1)
CCC_ + Body
      iErr = 0
c
      call UKStgA (jcr, TG, NTG, LTG, K0, 'CROOT')
CCC_  - NetCDF creation
      jnerr = NF_CREATE (FNM, NF_CLOBBER, ncid)
      call CNQchk (jnerr)
CCC_  - coordinates (space)
      do jco = 1, Ncnm
CCC_   . get original name
         if (CNM(2,jco).ne.' ') then
            call AMCkxg (CKX, CNM (2, jco), VG (jcr))
         else
            call AMCkxg (CKX, CNM (1, jco), VG (jcr))
         endif
c$$$         write (*, *) 'CKX', CKX, CNM(1, jco), CNM(2, jco), VG (jcr)
         jnerr = NF_DEF_DIM (ncid, CKX, NCM (jco), ncXI (jco))
         call CNQchk (jnerr)
         krank = 1
         kdims (1) = ncXI (jco)
         jnerr = NF_DEF_VAR
     $        (ncid, CKX, NF_DOUBLE, krank, kdims, ncXV (jco))
         call CNQchk (jnerr)
c$$$      subroutine CNQgcv
c$$$     O    (iErr,
c$$$     M     JCP,
c$$$     O     CPR,  VCPR, LCV,  MaxCpr,
c$$$     O     TT,   VV,   CV,   AA,  EE,  NT,  LT,
c$$$     I     TG,   VG,   NTG,  LTG, K0,  CNM, PNM,
c$$$     I     DPFX, ipI,  ipO,  ipE)
      enddo
CCC_  - coordinates (time)
      call UKStgA (jss, TG, NTG, LTG, K0, 'SUBS')
      JSUBS = -1
      if (jss.gt.0) then
         read (VG(jss), *) JSUBS
      endif
      if (JSUBS.ge.0 .and. CTkind(1:1).ne.'N') then
         jnerr = NF_DEF_DIM (ncid, 'step', NF_UNLIMITED, ncTI)
         krank = 1
         kdims (1) = ncTI
         jnerr = NF_DEF_VAR
     $        (ncid, 'time', NF_DOUBLE, krank, kdims, ncTV)
         jnerr = NF_DEF_VAR
     $        (ncid, 'substep', NF_INT, krank, kdims, ncSSV)
      else
CC       CAUTION: assume valid netcdf variable id is positive
         ncSSV = -99999
         jnerr = NF_DEF_DIM (ncid, 'time', NF_UNLIMITED, ncTI)
         krank = 1
         kdims (1) = ncTI
         jnerr = NF_DEF_VAR
     $        (ncid, 'time', NF_DOUBLE, krank, kdims, ncTV)
      endif
CCC_  - coordinate variable
CCC_  - variable
      call UUrwnd (iErr, itMEM)
      Kanch = -1
      NT = 0
c
      if (iErr.eq.0) then
         call UKAsvA (jit,  TT, CV, NT, LT, K0, 'ITEM',  ' ')
         call UKAsvA (jbs,  TT, CV, NT, LT, K0, 'CBASE', ' ')
         call UKAsvA (jkd,  TT, CV, NT, LT, K0, 'CKIND', ' ')
         call UKAsvA (jsx,  TT, CV, NT, LT, K0, 'CSFX',  ' ')
         call UKAsvA (jkv,  TT, CV, NT, LT, K0, 'KV',    ' ')
         call UKAsvA (jcs,  TT, CV, NT, LT, K0, 'COSTR', ' ')
         call DVTcpi (TT, CV, NT, LT, TG, VG, NTG, LTG, 'CROOT')
         call UKDkaa (iErr, TT, NT, LT, K0, CV, 'NCD', ipE)
      endif
      NTini = NT
      DO jv = 1, maxv
         NT = NTini
         CV (jit) = ' '
         if (iErr.eq.0) then
            call DVTcol
     $          (iErr,
     $           nskp, NT, TT, VV, AA, EE, CV, Kanch, LT, itMEM)
         endif
         if (iErr.eq.0)
     $        call UKDkaa (iErr, TT, NT, LT, K0, VV, 'NCD', ipE)
         if (iErr.eq.0) then
            read (VV (jkv), *) KV
         endif
         if (iErr.eq.0) then
            call USSccv (CPRM, NPRM, MaxDim, VV (jcs), ' ;')
            krank = 0
            do jc = 1, NPRM
               kco = 0
               do jco = 1, Ncnm
                  if (CNM (1, jco).eq.CPRM (jc)) then
                     kco = jco
                     goto 190
                  endif
               enddo
 190           continue
               if (kco.eq.0) then
                  iErr = -99
               else
                  krank = krank + 1
                  kdims (krank) = ncXI (kco)
                  ncCNT (krank, KV) = NCM (jco)
               endif
            enddo
         endif
         if (iErr.eq.0) then
            VNM = VV (jit)
            call AMCkxg (CKX, VV (jbs), VG (jcr))
            call USJnta (VNM, '.', CKX)
            krank = krank + 1
            kdims (krank) = ncTI
            ncTPO (KV) = krank
            ncCNT (krank, KV) = 1
            if ((ivST.eq.0.and.ivEN.eq.0)
     $           .or. (ivST.le.KV.and.KV.le.ivEN)) then
               jnerr = NF_DEF_VAR
     $              (ncid, VNM, NF_DOUBLE, krank, kdims, ncVV (KV))
               call CNQchk (jnerr)
            endif
         endif
      enddo
CCC_  - attributes
      jnerr = NF_PUT_ATT_TEXT
     $     (ncid, NF_GLOBAL, 'Conventions', 13, 'COARDS/CF-1.0')
      call CNQchk (jnerr)
CCC_  - end definition
      jnerr = NF_ENDDEF (NCID)
      call CNQchk (jnerr)
CCC_  - define geometry
      do jco = 1, Ncnm
c$$$         write (*, *) 'GEOMETRY',
c$$$     $        ncid, jco, NCM (jco), Coor (1, jco), Coor (2, jco)
CCC_   . simple check whether width == 0
         if ((NCM (jco).le.1)
     $        .or. (Coor (1, jco).eq.Coor (2, jco))) then
 101        format ('CNQncd: index coordinate ', I4, 1x, I4)
            if (COND_N(ipE)) then
               write (ipE, 101) jco, NCM (jco)
            else if (COND_S(ipE)) then
               write (*,   101) jco, NCM (jco)
            endif
            do jci = 1, NCM (jco)
               jct = jci
               jXCO (1) = jci
               jnerr = NF_PUT_VAR1_INT
     $              (ncid, ncXV (jco), jXCO, jct)
            enddo
         else
            jnerr = NF_PUT_VARA_DOUBLE
     $           (ncid, ncXV (jco), 1, NCM (jco), Coor (1, jco))
         endif
         call CNQchk (jnerr)
      enddo
CCC_  - return
      call DAtrcU (ipE, iErr, 'R', 'CNQncd')
      RETURN
      END
CCC_& CNQncv  ## netCDF variables
      subroutine CNQncv
     O    (iErr,
     W     W,    WW,
     I     ncID, ncTV,  ncSSV, ncVV,
     I     ncTPO,ncCNT, LNC,
     O     TT,   VV,    CV,    AA,   EE,   NT,  LT,
     I     TG,   VG,    NTG,   LTG,  K0,
     I     KGX,  LGX,   MG,    LPa,
     I     DPFX, ipI,   ipO,   ipE)
CCC_ + Declaration
      implicit none
      include 'netcdf.inc'
c
      _INTENT(OUT,integer)   iErr
c
      _INTENT(OUT,_REALSTD)  W  (*)
      _INTENT(OUT,_REALSTD)  WW (*)
c
      _INTENT(IN, integer)   NCID
      _INTENT(IN, integer)   ncVV (*)
      _INTENT(IN, integer)   ncTV, ncSSV
      _INTENT(IN, integer)   LNC
      _INTENT(IN, integer)   ncTPO (*)
      _INTENT(IN, integer)   ncCNT (LNC, *)
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
c
      _INTENT(IN, integer)   LPa (*)
      _INTENT(IN, integer)   KGX (*)
      _INTENT(IN, integer)   MG
      _INTENT(IN, integer)   LGX
      _INTENT(IN, character) DPFX*(*)
c
      _INTENT(IN, integer)   ipI, ipO, ipE
c
      integer Kanch
      integer nskp
      integer NTini
      integer jkv, jtm, jrc, jnmp, jss
c
      integer   kaDV (VIO_KPOLICY_MAX)
      character saDV*(VIO_SPOLICY_LEN)
      character CTYP*(8)
      character FMT *(VIO_FORMAT_MAX)
      integer   KUFMT
      integer   NV
      integer   kp0
      integer   kg, kv
      integer   ncSTT (64), jd
      integer   IREC
      integer   ISSPRV, ISUB
      _REALSTD  TPREV,  TIME
c
      integer   IR, NR
      integer   jnerr
CCC_ + Body
      iErr = 0
c
      IREC = 0
      TPREV = 0.0d0
      ISSPRV = -1
      Kanch = -1
      NT = 0
      if (iErr.eq.0) then
         call DVTcpi (TT, CV, NT, LT, TG, VG, NTG, LTG, 'GROUP')
         call DVTcpi (TT, CV, NT, LT, TG, VG, NTG, LTG, 'CROOT')
         call UKAsvA (jkv,  TT, CV, NT, LT, K0, 'KV',    ' ')
         call UKAsvA (jrc,  TT, CV, NT, LT, K0, 'REC',   ' ')
         call UKAsvA (jtm,  TT, CV, NT, LT, K0, 'TIME',  ' ')
         call UKAsvA (jss,  TT, CV, NT, LT, K0, 'ISUB',  ' ')
         call UKDkaa (iErr, TT, NT, LT, K0, CV, 'NCV', ipE)
      endif
c
      call UKStgA (jnmp, TG, NTG, LTG, K0, 'NR')
      read (VG (jnmp), *) NR
c
      if (iErr.eq.0)
     $     call DVFati (iErr, kaDV,  saDV, -1, ' ')
c
      NTini = NT
      DO
         if (iErr.ne.0) goto 900
         DO
            NT = NTini
            if (iErr.eq.0) then
               call DVTcol
     $             (iErr,
     $              nskp, NT, TT, VV, AA, EE, CV, Kanch, LT, ipI)
            endif
            if (iErr.ne.0) goto 390
            if ((VV (jrc).ne.' ')
     $           .and. (VV (jkv).ne.' ')) goto 390
         ENDDO
 390     continue
         if (iErr.eq.0)
     $        call UKDkaa (iErr, TT, NT, LT, K0, VV, 'NCVz', ipE)
         if (iErr.eq.0) then
            call DVSbng
     O          (iErr,
     O           CTYP,  KUFMT, FMT,
     I           ' ',
     I           ipI,   ipO,   ipE)
            kp0 = 1
            do IR = 0, NR - 1
c$$$               write (*, *) 'IR', IR, kp0, NV
               call DVSbnr
     O             (iErr,
     M              kaDV,  saDV,  NV,
     I              DPFX,  FMT,   ipI,   ipO,   ipE)
               call DVHriS
     O             (iErr,
     M              kaDV,    saDV,
     O              W (kp0), NV,
     I              ' ',     KUFMT, FMT, ' ', ipE, ipO)
c$$$               do kg = 0, NV - 1
c$$$                  write (*, *) 'V', IR, KG, kp0 + kg, W(kp0 + kg)
c$$$               enddo
               kp0 = kp0 + NV
            enddo
         endif
         if (iErr.eq.0) then
            read (VV (jkv), *) kv
            read (VV (jtm), *) TIME
         endif
         if (iErr.eq.0) then
            if (VV(jss).eq.' ') then
               ISUB = -999
            else
               read (VV(jss), *) ISUB
            endif
         endif
         if (NCSSV.lt.0) then
            if (irec.eq.0) TPREV = TIME - 1.0d0
            if (TIME.ne.TPREV) then
               TPREV = TIME
               irec = irec + 1
               jnerr = NF_PUT_VARA_DOUBLE (ncid, ncTV, irec, 1, TIME)
               call CNQchk (jnerr)
            endif
         else
            if (irec.eq.0) then
               TPREV = TIME - 1.0d0
            endif
            if (TIME.ne.TPREV) then
               TPREV = TIME
               ISSPRV = ISUB - 1
            endif
            if (ISUB.ne.ISSPRV) then
               ISSPRV = ISUB
               irec = irec + 1
               jnerr = NF_PUT_VARA_DOUBLE (ncid, ncTV, irec, 1, TIME)
               jnerr = NF_PUT_VARA_INT (ncid, ncSSV, irec, 1, ISUB)
               call CNQchk (jnerr)
            endif
         endif
         if (iErr.eq.0) then
c$$$            do kg = 1, MG
c$$$               write (*, *) 'kg', kg, MG, KGX(kg)
c$$$            enddo
            do kg = 1, MG
               WW (kg) = W (KGX (kg))
c$$$               write (*, *) 'V', KV, kg, KGX (kg), WW(kg)
            enddo
c$$$            write (*, *) 'MG', MG
         endif
         if (iErr.eq.0) then
            do jd = 1, ncTPO (kv) - 1
               ncSTT (jd) = 1
            enddo
            ncSTT (ncTPO (kv)) = IREC
            jnerr = NF_PUT_VARA_DOUBLE
     $           (ncid, ncVV (kv), ncSTT, ncCNT(1,kv), WW)
            call CNQchk (jnerr)
         endif
      ENDDO
 900  continue
CCC_  - end
      iErr = NF_CLOSE (ncid)
      call CNQchk (iErr)
      call DAtrcU (ipE, iErr, 'R', 'CNQncv')
      RETURN
      END
CCC_& CNQdrv  ## Driver
      subroutine CNQdrv (iErr, ipA, iMA)
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
      character  VTKIND*(Lattr)
c
      character  DIRPFX*(OPT_FILENAME_MAX)
      character  FNM   *(OPT_FILENAME_MAX)
      character  TMPF  *(OPT_FILENAME_MAX)
c
      namelist /NICNXS/
     $     VITEM, VGRP, VSUB,
     $     CROOT, CSFX,
     $     VTBL,  VCO,  VCOGR, VTKIND,
     $     DIRPFX,
     $     FNM, TMPF
CCC_  - Collation arrays
      integer    Ltag, Lval
      parameter (Ltag = CNXSEQ_TAG_LEN)
      parameter (Lval = CNXSEQ_VALUE_LEN)
c
      integer    LTG
      parameter (LTG    = CNXSEQ_TAG_MAX)
      integer    LTC
      parameter (LTC    = CNXSEQ_TAG_MAX)
      integer    LCW
      parameter (LCW    = CNXSEQ_TAG_MAX)
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
      integer    itMEM
      integer    NSKP
CCC_  - Coordinates
      integer    MaxCo
      parameter (MaxCo = CNXSEQ_COOR_MAX)
      integer    LCV
      parameter (LCV   = CNXSEQ_COOR_VLIM)
      _REALSTD   COOR (LCV, MaxCo)
      character  CNM  (2, MaxCo)*(Lval)
      integer    NCM  (MaxCo)
      integer    NCO,  Ncnm
CCC_  - Table
      integer    LPa (3)
      integer    LIE
      parameter (LIE = CNXSEQ_GLOBAL_TABLE_MAX)
      integer    IE (LIE)
      integer    LGX
      parameter (LGX = CNXSEQ_GLOBAL_TABLE_MAX)
      integer    KGX (LGX)
      integer    MG
CCC_  - netCDF
      integer    LVAR
      parameter (LVAR = CNXSEQ_VARENTRY_MAX)
c
      integer    ncid
      integer    ncXI (MaxCo), ncXV (MaxCo)
      integer    ncVV (LVAR)
      integer    ncTI, ncTV, ncSSV
c
      integer    LNC
      parameter (LNC = CNXSEQ_COOR_MAX)
      integer    ncCNT (LNC, LVAR)
      integer    ncTPO (LVAR)
c
      integer    LW
      parameter (LW = CNXSEQ_GLOBAL_BUFFER_MAX)
      _REALSTD   W  (LW)
      _REALSTD   WW (LW)
c
      integer    ivST, ivEN, MaxV
CCC_ + Body
      iErr = 0
      ipL  = FPL(ipA)
      ipC  = FPC(ipA)
      ipP  = FPP(ipA)
      ipV  = FPV(ipA)
c
      K0 = 1
c
      call UUrwnd (iErr, ipP)
c
      CLS    = AKW_CLS
      CROOT  = 'ID'
      CSFX   = 'a'
      VITEM  = ' '
      VGRP   = ' '
      VSUB   = ' '
      VTBL   = 'IE'
      VCO    = 'CP'
      VCOGR  = ' '
      DIRPFX = ' '
      FNM    = 'out.nc'
      TMPF   = ' '
      VTKIND = ' '
c
      read  (ipP, NICNXS, IOSTAT = iErr)
      if (COND_N(ipC)) then
         write (ipC, NICNXS)
      else if (COND_S(ipC)) then
         write (*,   NICNXS)
      endif
c
#if 1 /* open temporary file */
      if (iErr.eq.0) call UUMCnu (iErr, itMEM)
      if (TMPF.eq.' ') then
         if (iErr.eq.0) call UUopnS (iErr, itMEM,  0, 'F')
      else
         if (iErr.eq.0) then
            call UUopnC (iErr, itMEM, TMPF, 0, 'F', ' ', ' ')
         endif
      endif
#else /* for test */
      itMEM = 99
#endif
      if (iErr.eq.0) then
         call CNQpre
     O       (iErr,
     O        TG,     VG,    CG,   NTG, LTG,
     O        TC,     VC,    CC,   NTC, LTC,
     O        AA,     EE,    K0,
     O        Nco,    NCM,
     O        Coor,   Ncnm,  CNM,  LCV, MaxCo,
     O        IE,     LIE,   KGX,  LGX, MG,  LPa,
     O        NSKP,
     O        MAXV,   ivST,  ivEN,
     I        VGRP,   CROOT, VCO,  VTBL,
     I        DIRPFX, ipP,   ipC,  ipL,  itMEM)
      endif
CCC_ + netcdf definition stage
      if (iErr.eq.0) then
         call UUrwnd (iErr, ipP)
         call DVTfwg (iErr, NSKP, ipP)
         call CNQncd
     O       (iErr,
     O        ncID,  ncXI,  ncXV, ncTI, ncTV, ncSSV, ncVV,
     O        ncTPO, ncCNT, LNC,
     O        TC,    VC,    CC,   AA,   EE,   NTC,   LTC,
     I        TG,    VG,    NTG,  LTG,  K0,
     I        Nco,   NCM,
     I        Coor,  Ncnm,  CNM,  LCV,  VTkind,
     I        MAXV,  ivST,  ivEN,
     I        FNM,
     I        ipP,   ipC,   ipL,  itMEM)
      endif
CCC_ + netcdf data stage
      if (iErr.eq.0) then
         call CNQncv
     O       (iErr,
     W        W,      WW,
     I        ncID,   ncTV,  ncSSV, ncVV,
     I        ncTPO,  ncCNT, LNC,
     O        TC,     VC,    CC,    AA,   EE,   NTC, LTC,
     I        TG,     VG,    NTG,   LTG,  K0,
     I        KGX,    LGX,   MG,    LPa,
     I        DIRPFX, ipP,   ipC,   ipL)
      endif
CC_  - return
      call DAtrcU (ipL, iErr, 'R', 'CNQdrv')
      RETURN
      END
CCC_& CNXSEQ  ## IcIES/Cadenza/NetCDF announcement
      subroutine CNXSEQ (STRA, STRB, IOP)
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
CCC_@ CNQPRG  ## Cadenza/NetCDF program
#if CNXSEQ_SKIP_PROGRAM == 0
      program CNQPRG
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
         call CNQdrv (iErr, ipA, iMA)
         call ACCrep (FPL(ipA), 0)
      endif
      call DevFin (iErr)
      STOP
      END
#endif /* CNQSEQ_SKIP_PROGRAM */
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
