C cadenza/cabcnv.F --- IcIES/Cadenza/Ascii Binary conversion
C Author: SAITO Fuyuki
C Created: Jul 3 2013
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2020/09/17 08:41:48 fuyuki cabcnv.F>'
#define _FNAME 'cadenza/cabcnv.F'
#define _REV   'Snoopy0.97'
CCC_! MANIFESTO
C
C Copyright (C) 2010--2020
C           Japan Agency for Marine-Earth Science and Technology,
C           Ayako ABE-OUCHI
C
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
CCC_* Common macros
#include "ofdlct.h" /* fortran dialect */
#include "ofnstd.h"
CC #include "oarpea.h"
#include "oarpfi.h"
#include "odevva.h"
#include "odevel.h"
#include "oarpkw.h" /* operation id in arpeggio/kiwi */
#include "ologfm.h"
CCC_* Macros
#ifndef   CABCNV_SKIP_PROGRAM
#  define CABCNV_SKIP_PROGRAM 0
#endif
#ifndef   AKW_CLS
#  define AKW_CLS 'V'
#endif
CCC_ + Buffers
#ifndef   CABCNV_BUFFER_MAX
#  define CABCNV_BUFFER_MAX 4194304
#endif
#ifndef   CABCNV_GLOBAL_BUFFER_MAX
#  define CABCNV_GLOBAL_BUFFER_MAX CABCNV_BUFFER_MAX
#endif
#ifndef   CABCNV_GLOBAL_TABLE_MAX
#  define CABCNV_GLOBAL_TABLE_MAX  CABCNV_BUFFER_MAX
#endif
c
#ifndef   CABCNV_COOR_MAX
#  define CABCNV_COOR_MAX 32
#endif
#ifndef   CABCNV_COOR_VLIM
#  define CABCNV_COOR_VLIM 65536
#endif
#ifndef   CABCNV_TAG_MAX
#  define CABCNV_TAG_MAX 32
#endif
#ifndef   CABCNV_VARENTRY_MAX
#  define CABCNV_VARENTRY_MAX 512
#endif
#ifndef   CABCNV_TAG_LEN
#  define CABCNV_TAG_LEN 8
#endif
#ifndef   CABCNV_VALUE_LEN
#  define CABCNV_VALUE_LEN 80
#endif
c
#define OPT_INIT_MAXREC 1024
CCC_& CAXout  ## ascii/binary output
      subroutine CAXout
     O    (iErr,
     W     W,    WW,
     O     TT,   VV,    CV,   AA,   EE,   NT,  LT,
     O     KV2JV,
     I     TG,   VG,    NTG,  LTG,  K0,
     I     MAXV, KGX,   LGX,  MG,   LPa,
     I     VITEM,
     I     FMTw, FNM,   XPTN, CTIME,
     I     DPFX, ipI,   ipO,  ipE)
CCC_ + Declaration
      implicit none
c
      _INTENT(OUT,integer)   iErr
c
      _INTENT(OUT,_REALSTD)  W  (*)
      _INTENT(OUT,_REALSTD)  WW (*)
c
      _INTENT(OUT,integer)   NT
      _INTENT(IN, integer)   LT
c
      _INTENT(OUT,character) TT (*)*(*)
      _INTENT(OUT,character) VV (*)*(*)
      _INTENT(OUT,character) CV (*)*(*)
      _INTENT(OUT,character) AA (*)*(*)
      _INTENT(OUT,character) EE (*)*(*)
      _INTENT(OUT,integer)   KV2JV(*)
c
      _INTENT(IN, character) TG (*)*(*)
      _INTENT(IN, character) VG (*)*(*)
      _INTENT(IN, integer)   NTG, LTG, K0
c
      _INTENT(IN, integer)   MAXV
      _INTENT(IN, integer)   LPa (*)
      _INTENT(IN, integer)   KGX (*)
      _INTENT(IN, integer)   MG
      _INTENT(IN, integer)   LGX
      _INTENT(IN, character) VITEM*(*)
      _INTENT(IN, character) DPFX*(*)
      _INTENT(IN, character) XPTN*(*)
      _INTENT(IN, character) CTIME*(*)
      _INTENT(IN, character) FNM*(*)
      _INTENT(IN, character) FMTw*(*)
c
      _INTENT(IN, integer)   ipI, ipO, ipE
c
      integer Kanch
      integer nskp
      integer NTini
      integer jkv, jtm, jrc, jnmp
      integer jgr, jrt, jit
c
      integer   kaDV (VIO_KPOLICY_MAX)
      character saDV*(VIO_SPOLICY_LEN)
      character CTYP*(8)
      character FMTr*(VIO_FORMAT_MAX)
      integer   KUFMT
      integer   NVAR
      integer   NV
      integer   kp0
      integer   kg, kv, jv, jt
      integer   ncSTT (64), jd
      integer   IREC,  IRCW
      _REALSTD  TPREV, TIME
      _REALSTD  TTGT
      logical   OTALL
c
      integer   IR, NR
      integer   jnerr
c
      integer   ipOUT
      integer   NVREC, jrcw
      integer   jedmy
      integer   LU, LV, LB
      logical   OWR
c
      integer   jh
c
      character BfIdx*(128)
      character BfVal*(128)
c
      logical   OEOF
      logical   OWDIV
c$$$      integer    MAXR
c$$$      parameter (MAXR = OPT_INIT_MAXREC)
c$$$      integer    IRSKP (MAXR)
c$$$      integer    jr
#define SP_STAR   -1
#define SP_FORMAT -2
CCC_ + Body
      iErr = 0
c
C     set TRUE if obsolete binary format to separate records by rank.
      OWDIV = .false.
c
      IREC = 0
      IRCW = 0
      TPREV = 0.0d0
      Kanch = -1
      NT = 0
      TTGT = 0.0d0
c
c     kv == jv without filter
      if (VITEM.eq.' ') then
         NVAR = MAXV
         do jt = 1, MAXV
            kv2jv(jt) = jt
         enddo
      else
         NVAR = 0
         do jt = 1, MAXV
            kv2jv(jt) = -1
         enddo
      endif
c
      if (iErr.eq.0) then
         call DVTcpi (TT, CV, NT, LT, TG, VG, NTG, LTG, 'GROUP')
         call DVTcpi (TT, CV, NT, LT, TG, VG, NTG, LTG, 'CROOT')
         call UKAsvA (jkv,  TT, CV, NT, LT, K0, 'KV',    ' ')
         call UKAsvA (jrc,  TT, CV, NT, LT, K0, 'REC',   ' ')
         call UKAsvA (jtm,  TT, CV, NT, LT, K0, 'TIME',  ' ')
         call UKAsvA (jit,  TT, CV, NT, LT, K0, 'ITEM',  ' ')
c$$$         call UKAsvA (jit,  TT, CV, NT, LT, K0, 'ITEM',  VITEM)
         call UKDkaa (iErr, TT, NT, LT, K0, CV, 'NCV', ipE)
      endif
c
      call UKStgA (jnmp, TG, NTG, LTG, K0, 'NR')
      read (VG (jnmp), *) NR
c
      call UKStgA (jgr, TG, NTG, LTG, K0, 'GROUP')
      call UKStgA (jrt, TG, NTG, LTG, K0, 'CROOT')
c
      if (OWDIV) then
         NVREC = LPa (1) * LPa (2) * LPa (3)
      else
         NVREC = MG
      endif
c$$$      write (*, *) 'LPX', NVREC
c
c$$$      do jr = 1, MAXR
c$$$         IRSKP (jr) = 0
c$$$      enddo
c
      if (FNM.eq.' ') then
         ipOUT = -1
      else
         if (iErr.eq.0) call UUMCnu (iErr, ipOUT)
         if (FMTw.eq.' ') then
            LB = NVREC * REAL_STD_BYTES
            call DVPb2l (LV, LB, ' ', ' ')
            if (iErr.eq.0)
     $           call UUopOC (iErr, ipOUT, FNM, LV, 'U', 'W', ' ')
         else
            LV = -1
            if (iErr.eq.0)
     $           call UUopOC (iErr, ipOUT, FNM, LV, 'F', 'W', ' ')
            if (FMTw.eq.'*') then
               LB = SP_STAR
            else
               LB = SP_FORMAT
            endif
         endif
 101     format ('CAX:F ', 1x, I12, 1x, I12, 1x, 2I12,
     $        1x, A, 1x, A, 1x, A)
         if (COND_N(ipE)) then
            write (ipE, 101) NVREC, LB, NR, MAXV,
     $           _TRIM(VG(jrt)), _TRIM(VG(jgr)), _TRIM(FNM)
         else if (COND_S(ipE)) then
            write (*,   101) NVREC, LB, NR, MAXV,
     $           _TRIM(VG(jrt)), _TRIM(VG(jgr)), _TRIM(FNM)
         endif
#if 0 /* not use movement/test */
c$$$         call MUTnmw
c$$$     $       (jedmy,
c$$$     $        VG(jrt), VG(jgr), FNM, NVREC, LB, NR, MAXV, IRSKP, ipE)
c$$$         call MUTnmw
c$$$     $       (jedmy,
c$$$     $        VG(jrt), VG(jgr), FNM, NVREC, LB, NR, MAXV, IRSKP, ipO)
#endif
      endif
c
      if (CTIME.eq.' ') then
         OTALL = .true.
      else
         read (CTIME, *) TTGT
         OTALL = .false.
      endif
c
      if (iErr.eq.0)
     $     call DVFati (iErr, kaDV,  saDV, -1, ' ')
c
      jrcw  = 0
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
c$$$         write (*, *) 'DVTcol', iErr
c$$$         if (iErr.eq.0)
c$$$     $        call UKDkaa (iErr, TT, NT, LT, K0, VV, 'NCVz', ipE)
         if (iErr.eq.0) then
            read (VV (jkv), *) kv
            read (VV (jtm), *) TIME
         endif
c$$$         write (*, *) kv, TIME, iErr
         OWR = .false.
         if (OTALL) then
            OWR = .true.
         else if (TIME.eq.TTGT) then
            OWR = .true.
         endif
         if (irec.eq.0) TPREV = TIME - 1.0d0
         if (TIME.ne.TPREV) then
            TPREV = TIME
            irec = irec + 1
            if (OWR) IRCW = IRCW + 1
         endif
         jv = kv2jv (kv)
         if (VITEM.ne.' ') then
            if (VV(jit).ne.' ') then
               if (VITEM.eq.VV(jit)) then
                  NVAR = NVAR + 1
                  if (jv.lt.0) then
                     do jt = 1, MAXV
                        jv = MAX(jv, kv2jv(jt))
                     enddo
                     jv = MAX(0, jv) + 1
                     kv2jv(kv) = jv
                  endif
               endif
            endif
         endif
         if (OWR) then
            OWR = jv.gt.0
         endif
         if (OWR) then
            call UKDkaa (iErr, TT, NT, LT, K0, VV, 'NCVz', ipE)
 203        format ('CAX:V ', I5, 1x, I5, 1x, A)
            if (VV (jit).ne. ' ') then
               if (COND_N(ipE)) then
                  write (ipE, 203) kv, jv, _TRIM(VV (jit))
               else if (COND_S(ipE)) then
                  write (*,   203) kv, jv, _TRIM(VV (jit))
               endif
            endif
         endif
 201     format ('CAX:S ', I5, 1x, 2E16.9)
 202     format ('CAX:T ', I5, 1x, 2E16.9)
         if (OWR) then
            if (COND_N(ipE)) then
               write (ipE, 202) IREC, TIME, TTGT
            else if (COND_S(ipE)) then
               write (*,   202) IREC, TIME, TTGT
            endif
         else
            if (COND_N(ipE)) then
               write (ipE, 201) IREC, TIME, TTGT
            else if (COND_S(ipE)) then
               write (*,   201) IREC, TIME, TTGT
            endif
         endif
         if (iErr.eq.0.and. OWR) then
            call DVSbng
     O          (iErr,
     O           CTYP,  KUFMT, FMTr,
     I           ' ',
     I           ipI,   ipO,   ipE)
            kp0 = 1
 301        format ('CAX:W ', I12, 3I12)
 501        format (A, 1x, A)
            do IR = 0, NR - 1
               jrcw = 1 + IR + (jv - 1) * NR + (IRCW - 1) * NR * NVAR
               call DVSbnr
     O             (iErr,
     M              kaDV,  saDV,  NV,
     I              DPFX,  FMTr,  ipI,   ipO,   ipE)
               call DVHriS
     O             (iErr,
     M              kaDV,    saDV,
     O              W (kp0), NV,
     I              ' ',     KUFMT, FMTr, ' ', ipE, ipO)
               if (OWDIV) then
                  if      (LB.eq. SP_STAR) then
                     do jh = 1, NV
                        BfIdx = ' '
                        call USGbni (BfIdx, IREC)
                        call USGbni (BfIdx, KV)
                        call USGbni (BfIdx, IR)
                        call USGbni (BfIdx, JH)
                        write (BfVal, *) W (kp0 + (jh - 1))
                        write (ipOUT, 501) _TRIM(BfIdx), _TRIM(BfVal)
                     enddo
                  else if (LB.eq. SP_FORMAT) then
                     do jh = 1, NV
                        BfIdx = ' '
                        call USGbni (BfIdx, IREC)
                        call USGbni (BfIdx, KV)
                        call USGbni (BfIdx, IR)
                        call USGbni (BfIdx, JH)
                        write (BfVal, FMTw) W (kp0 + (jh - 1))
                        write (ipOUT, 501) _TRIM(BfIdx), _TRIM(BfVal)
                     enddo
                  else
                     call UUwwRS (iErr, ipOUT, jrcw, NV, W (kp0))
                  endif
               endif
c$$$               call UUwwFS (iErr, 93, '(E24.16)', NV, W (kp0))
               if (COND_N(ipE)) then
                  write (ipE, 301) jrcw, IR, KV, IRCW
               else if (COND_S(ipE)) then
                  write (*,   301) jrcw, IR, KV, IRCW
               endif
               kp0 = kp0 + NV
            enddo
            if (.not.OWDIV .and. iErr.eq.0) then
               do kg = 1, MG
                  WW (kg) = W (KGX (kg))
               enddo
               if (LB.gt.0) then
                  jrcw = 1 + (jv - 1) + (IRCW - 1) * NVAR
                  call UUwwRS (iErr, ipOUT, jrcw, MG, WW)
               else if (LB.eq. SP_STAR) then
                  do kg = 1, MG
                     BfIdx = ' '
                     call USGbni (BfIdx, IREC)
                     call USGbni (BfIdx, KV)
                     call USGbni (BfIdx, kg)
                     write (BfVal, *)   WW (kg)
                     write (ipOUT, 501) _TRIM(BfIdx), _TRIM(BfVal)
                  enddo
               else if (LB.eq. SP_FORMAT) then
                  do kg = 1, MG
                     BfIdx = ' '
                     call USGbni (BfIdx, IREC)
                     call USGbni (BfIdx, KV)
                     call USGbni (BfIdx, kg)
                     write (BfVal, FMTw) WW (kg)
                     write (ipOUT, 501) _TRIM(BfIdx), _TRIM(BfVal)
                  enddo
               endif
            endif
         endif
      ENDDO
 900  continue
CCC_  - end
c$$$      iErr = NF_CLOSE (ncid)
c$$$      call CNQchk (iErr)
      call DAtrcU (ipE, iErr, 'R', 'CAXout')
c
      call UUieof (OEOF, iErr)
      if (OEOF) then
         iErr = 0
      else
         iErr = -1
      endif
      call DAtrcU (ipE, iErr, 'R', 'CAXout')
      RETURN
      END
CCC_& CAXdrv  ## Driver
      subroutine CAXdrv (iErr, ipA, iMA)
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
CCC_  - NICABX
      character  CLS*(Lattr)
      character  CROOT*(Lattr), CSFX*(Lattr)
      character  VITEM*(Lattr), VGRP*(Lattr), VSUB*(Lattr)
      character  VTBL *(Lattr), VCO*(Lattr),  VCOGR*(Lattr)
c
      character  DIRPFX*(OPT_FILENAME_MAX)
      character  FMT   *(128)
      character  FNM   *(OPT_FILENAME_MAX)
      character  TMPF  *(OPT_FILENAME_MAX)
      character  XPTN  *(16)
      character  CTIME *(32)
c
      namelist /NICABX/
     $     VITEM, VGRP, VSUB,
     $     CROOT, CSFX,
     $     VTBL,  VCO,  VCOGR,
     $     DIRPFX,
     $     FMT,   FNM,  XPTN, CTIME
CCC_  - Collation arrays
      integer    Ltag, Lval
      parameter (Ltag = CABCNV_TAG_LEN)
      parameter (Lval = CABCNV_VALUE_LEN)
c
      integer    LTG
      parameter (LTG = CABCNV_TAG_MAX)
      integer    LTC
      parameter (LTC = CABCNV_TAG_MAX)
      integer    LCW
      parameter (LCW = CABCNV_TAG_MAX)
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
      parameter (MaxCo = CABCNV_COOR_MAX)
      integer    LCV
      parameter (LCV   = CABCNV_COOR_VLIM)
      _REALSTD   COOR (LCV, MaxCo)
      character  CNM  (2, MaxCo)*(Lval)
      integer    NCM  (MaxCo)
      integer    NCO,  Ncnm
CCC_  - Table
      integer    LPa (3)
      integer    LIE
      parameter (LIE = CABCNV_GLOBAL_TABLE_MAX)
      integer    IE (LIE)
      integer    LGX
      parameter (LGX = CABCNV_GLOBAL_TABLE_MAX)
      integer    KGX (LGX)
      integer    MG
CCC_  - Variable
      integer    LVAR
      parameter (LVAR = CABCNV_VARENTRY_MAX)
      integer    kv2jv(LVAR)
c
      integer    LW
      parameter (LW = CABCNV_GLOBAL_BUFFER_MAX)
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
      FNM    = ' '
      FMT    = ' '
      XPTN   = ' '
      CTIME  = ' '
      TMPF   = ' '
c
      read  (ipP, NICABX, IOSTAT = iErr)
      if      (COND_N(ipC)) then
         write (ipC, NICABX)
      else if (COND_S(ipC)) then
         write (*,   NICABX)
      endif
c
#if 1 /* open temporary file */
      itMEM = -1
      if (iErr.eq.0) call UUMCnu (iErr, itMEM)
      if (TMPF.eq.' ') then
         if (iErr.eq.0) call UUopnS (iErr, itMEM,  0, 'F')
      else
         if (iErr.eq.0) then
            call UUopnN (iErr, itMEM, TMPF, 0, 'F', ' ', ' ')
         endif
      endif
#else /* for test */
      itMEM = 99
#endif
c
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
CCC_ + conversion
      if (iErr.eq.0) then
         call CAXout
     O       (iErr,
     W        W,      WW,
     O        TC,     VC,    CC,   AA,   EE,   NTC, LTC,
     O        kv2jv,
     I        TG,     VG,    NTG,  LTG,  K0,
     I        MAXV,   KGX,   LGX,  MG,   LPa,
     I        VITEM,
     I        FMT,    FNM,   XPTN, CTIME,
     I        DIRPFX, ipP,   ipC,  ipL)
      endif
CC_  - return
      call DAtrcU (ipL, iErr, 'R', 'CAXdrv')
      RETURN
      END
CCC_& CABCNV  ## Announcement
      subroutine CABCNV (STRA, STRB, IOP)
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
CCC_@ CAXPRG  ## Main program
#if CABCNV_SKIP_PROGRAM == 0
      program CAXPRG
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
         call CAXdrv (iErr, ipA, iMA)
         call ACCrep (FPL(ipA), 0)
      endif
      call DevFin (iErr)
      STOP
      END
#endif /* CABCNV_SKIP_PROGRAM */
CCC_* Obsolete
#if 0 /* Obsolete */
CCC_ & CAXprp  ## Preparation (copy from CNQpre)
      subroutine CAXprp
     O    (iErr,
     O     TG,   VG,    CG,   NTG, LTG,
     O     TC,   VC,    CC,   NTC, LTC,
     O     AA,   EE,    K0,
     O     Nco,  NCM,
     O     Coor, Ncnm,  CNM,  LCV, MaxCo,
     O     IE,   LIE,   KGX,  LGX, MG,  LPa,
     O     NSKP,
     O     MAXV, ivST,  ivEN,
     I     VGRP, CROOT, VCO,  VTBL,
     I     DPFX, ipI,   ipO,  ipE,  itMEM)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
c
      _INTENT(IN, integer)   LCV, MaxCo
      _INTENT(OUT,integer)   Nco, Ncnm
      _INTENT(OUT,integer)   NCM (MaxCo)
      _INTENT(OUT,character) CNM (2, MaxCo)*(*)
      _INTENT(OUT,_REALSTD)  Coor(LCV, MaxCo)
c
      _INTENT(OUT,integer)   MAXV, ivST, ivEN
c
      _INTENT(IN, integer)   K0
      _INTENT(OUT,integer)   NTG, NTC
      _INTENT(IN, integer)   LTG, LTC
      _INTENT(OUT,character) AA (*)*(*)
      _INTENT(OUT,character) EE (*)*(*)
c
      _INTENT(OUT,character) TG (*)*(*)
      _INTENT(OUT,character) VG (*)*(*)
      _INTENT(OUT,character) CG (*)*(*)
c
      _INTENT(OUT,character) TC (*)*(*)
      _INTENT(OUT,character) VC (*)*(*)
      _INTENT(OUT,character) CC (*)*(*)
c
      _INTENT(OUT,integer)   LPa (*)
      _INTENT(OUT,integer)   IE  (*)
      _INTENT(OUT,integer)   KGX (*)
      _INTENT(OUT,integer)   MG
      _INTENT(IN, integer)   LIE, LGX
c
      _INTENT(IN, character) VGRP  *(*)
      _INTENT(IN, character) CROOT *(*)
      _INTENT(IN, character) VTBL  *(*)
      _INTENT(IN, character) VCO*(*)
c
      _INTENT(OUT,integer)   NSKP
c
      _INTENT(IN, character) DPFX*(*)
      _INTENT(IN, integer)   ipI, ipO, ipE
      _INTENT(IN, integer)   itMEM
c
      integer    j, jc
CCC_  - Body
      if (iErr.eq.0) call UUrwnd (iErr, ipI)
CCC_   . cue to group head, clone member info to a scratch
      if (iErr.eq.0) then
         call CNQgrq
     O       (iErr,
     O        MAXV, ivST, ivEN,
     O        NSKP,
     O        TG,   VG,  CG, AA, EE, NTG, LTG, K0,
     I        VGRP, CROOT,
     I        ipE,  ipI, itMEM)
      endif
CCC_   . maxv detection
      if (iErr.eq.0.and.MaxV.eq.0) then
         call CNQdmv
     O       (iErr,
     O        MAXV,
     O        TC,    VC,  CC,   AA,  EE,  NTC,  LTC,
     I        TG,    VG,  NTG,  LTG, K0,
     I        ipI,   ipO, ipE,  itMEM)
      endif
CCC_   . coordinate names
      if (iErr.eq.0) then
         call CNQgcn
     O       (iErr,
     O        Nco,   NCM,
     O        Ncnm,  CNM,  MaxCo,
     O        TC,    VC,   CC,   AA,  EE,  NTC, LTC,
     I        TG,    VG,   NTG,  LTG, K0,  VCO,
     I        itMEM, ipO,  ipE)
      endif
CCC_   . coordinates
      if (iErr.eq.0) then
         call CNQgco
     O       (iErr,
     O        NCM,  Coor, LCV,  MaxCo,
     O        TC,   VC,   CC,   AA,  EE,  NTC, LTC,
     I        TG,   VG,   NTG,  LTG, K0,  VCO,
     I        Ncnm, CNM,
     I        DPFX, ipI,  ipO,  ipE)
      endif
      do jc = 1, Ncnm
         do j = 1, NCM (jc)
            write (*, *) _TRIM(CNM(1, jc)), jc, j, COOR (j, jc)
         enddo
      enddo
CCC_   . global conversion table
      if (iErr.eq.0) then
         call CNQgxt
     O       (iErr,
     W        IE,   LIE,
     O        KGX,  LGX,  LPa,  MG,
     O        TC,   VC,   CC,   AA,  EE,  NTC,  LTC,
     I        TG,   VG,   NTG,  LTG, K0,
     I        CROOT,VTBL,
     I        DPFX, ipI,  ipO,  ipE)
      endif
CCC_   . end
      call DAtrcU (ipE, iErr, 'R', 'CAXprp')
      RETURN
      END
#endif /* obsolete */
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
