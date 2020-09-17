C cadenza/cnxseq.F --- IcIES/Cadenza/NetCDF conversion (sequential variation)
C Maintainer:  SAITO Fuyuki
C Created: Apr 17 2013 (separated from cnxseq)
C Created: Apr 3 2013 (fork from cnxsim)
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2020/09/17 08:42:09 fuyuki cnxutl.F>'
#define _FNAME 'cadenza/cnxutl.F'
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
#if OARPEA_REV == 256
#  include "oarpea_obsolete256.h"
#else
#  include "oarpea.h"
#endif
#include "odevva.h"
CCC_& CNQgsq  ## Group header cuing (simple)
      subroutine CNQgsq
     O    (iErr,
     O     NSKP,
     O     TT, VV, CV,
     W     AA, EE,
     M     NT,
     I     LT, K0,
     I     VGRP,  iGRP,
     I     ipL,   ipP)
CCC_ + Description
CC     search recursively until blank GBASE
CCC_ + Declaration
      implicit none
CCC_  - Arguments
      _INTENT(OUT,  integer)   iErr
      _INTENT(OUT,  integer)   NT
      _INTENT(INOUT,integer)   iGRP
      _INTENT(OUT,  integer)   NSKP
      _INTENT(IN,   integer)   LT
      _INTENT(IN,   integer)   ipL, ipP
      _INTENT(IN,   character) VGRP  *(*)
      _INTENT(IN,   integer)   K0
c
      _INTENT(OUT,  character) TT (*)*(*)
      _INTENT(OUT,  character) VV (*)*(*)
      _INTENT(OUT,  character) AA (*)*(*)
      _INTENT(OUT,  character) EE (*)*(*)
c
      _INTENT(OUT,  character) CV (*)*(*)
CCC_  - interior
      integer    Kanch
      integer    jd
      integer    NTini
      integer    jedmy
      integer    nsdmy
CCC_ + Body
      iErr = 0
c
      Kanch = -1
c
      call UKDkaa (iErr, TT, NT, LT, K0, CV, 'GSQa', ipL)
      NTini = NT
CCC_  - find group anchor
      nskp = 0
 201  format ('SEARCH HEAD: ', A)
 202  format ('SEARCH HEAD: (ANY)')
      if (VGRP.eq.' ') then
         if (COND_N(ipL)) then
            write (ipL, 202)
         else if (COND_S(ipL)) then
            write (*,   202)
         endif
      else
         if (COND_N(ipL)) then
            write (ipL, 201) _TRIM(VGRP)
         else if (COND_S(ipL)) then
            write (*,   201) _TRIM(VGRP)
         endif
      endif
      do
         NT = NTini
         if (iErr.eq.0) then
            call DVTcol
     $          (iErr,
     $           nsdmy, NT, TT, VV, AA, EE, CV, Kanch, LT, ipP)
         endif
CC       loop until undef GBASE
         if (iErr.eq.0) then
            nskp = nskp + nsdmy
            if (VV (iGRP).ne.' ') goto 900
         endif
         if (iErr.ne.0) goto 900
      enddo
 900  continue
      call UKDkaa (jedmy, TT, NT, LT, K0, VV,  'GSQz', ipL)
      nskp = nskp - 1
 101  format ('NSKP: ', I6)
      if (COND_N(ipL)) then
         write (ipL, 101) nskp
      else if (COND_S(ipL)) then
         write (*,   101) nskp
      endif
CCC_  - end
      call DAtrcU (ipL, iErr, 'R', 'CNQgsq')
      RETURN
      END
CCC_& CNQgrq  ## Group/BASE header cuing
      subroutine CNQgrq
     O    (iErr,
     O     MAXV, ivST, ivEN,
     O     NSKP,
     O     TT, VV, CV,
     W     AA, EE,
     O     NT,
     I     LT, K0,
     I     VGRP,  CROOT,
     I     ipL,   ipP,   itMEM)
CCC_ + Description
CC     search recursively until blank GBASE
CCC_ + Declaration
      implicit none
CCC_  - Arguments
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   NT
      _INTENT(OUT,integer)   NSKP
      _INTENT(OUT,integer)   MAXV, ivST, ivEN
      _INTENT(IN, integer)   LT
      _INTENT(IN, integer)   ipL, ipP, itMEM
      _INTENT(IN, character) VGRP  *(*)
      _INTENT(IN, character) CROOT *(*)
      _INTENT(IN, integer)   K0
c
      _INTENT(OUT,character) TT (*)*(*)
      _INTENT(OUT,character) VV (*)*(*)
      _INTENT(OUT,character) AA (*)*(*)
      _INTENT(OUT,character) EE (*)*(*)
c
      _INTENT(OUT,character) CV (*)*(*)
CCC_  - interior
      integer    ngrp
      integer    Kanch
      integer    jd
      integer    jgb, jgr, jst, jen, jmv, jss
      integer    NTini
      integer    nsdmy
      integer    jedmy
CCC_ + Body
      iErr = 0
c
      ivst = 0
      iven = 0
c
      Kanch = -1

      NT = 0
      call UKAsvA (jgr, TT, CV, NT, LT, K0, 'GROUP', VGRP)
      call UKAsvA (jd,  TT, CV, NT, LT, K0, 'CROOT', CROOT)
c
      call UKAsvA (jgb, TT, CV, NT, LT, K0, 'GBASE', ' ')
      call UKAsvA (jd,  TT, CV, NT, LT, K0, 'CBASE', ' ')
      call UKAsvA (jmv, TT, CV, NT, LT, K0, 'MAXV',  ' ')
      call UKAsvA (jst, TT, CV, NT, LT, K0, 'VSTART', ' ')
      call UKAsvA (jen, TT, CV, NT, LT, K0, 'VEND',   ' ')
c
      call UKAsvA (jd,  TT, CV, NT, LT, K0, 'LOOPI',  ' ')
      call UKAsvA (jd,  TT, CV, NT, LT, K0, 'LOOPB',  ' ')
      call UKAsvA (jd,  TT, CV, NT, LT, K0, 'LOOPO',  ' ')
      call UKAsvA (jss, TT, CV, NT, LT, K0, 'SUBS',   ' ')
c
      call UKDkaa (iErr, TT, NT, LT, K0, CV, 'GRQa', ipL)
      NTini = NT
CCC_  - find group anchor
      ngrp = 0
      nskp = 0
 201  format ('SEARCH HEAD: ', I3, 1x, A, ':', A)
      do
         if (COND_N(ipL)) then
            write (ipL, 201) ngrp,
     $           _TRIM(VGRP), _TRIM(CV(jgr))
         else if (COND_S(ipL)) then
            write (*,   201) ngrp,
     $           _TRIM(VGRP), _TRIM(CV(jgr))
         endif
         NT = NTini
         if (iErr.eq.0) call UUrwnd (iErr, ipP)
         if (iErr.eq.0) then
            call DVTcol
     $          (iErr,
     $           nsdmy, NT, TT, VV, AA, EE, CV, Kanch, LT, ipP)
         endif
         if (ngrp.eq.0) nskp = nsdmy
         if (iErr.eq.0) then
            if (VV (jst).ne.' '.and.ivst.eq.0) then
               read (VV (jst), *) ivst
            endif
            if (VV (jen).ne.' '.and.iven.eq.0) then
               read (VV (jen), *) iven
            endif
         endif
CC       loop until undef GBASE
         if (iErr.eq.0) then
            if (VV (jgb).eq.' ') goto 900
            ngrp = ngrp + 1
            CV (jgr) = VV (jgb)
         endif
         if (iErr.ne.0) goto 900
      enddo
 900  continue
      call DAtrcU (ipL, iErr, 'C', 'CNQgrq')
      call UKDkaa (jedmy, TT, NT, LT, K0, VV,  'GRQz', ipL)
      if (ngrp.gt.0) nskp = nskp - 1
 101  format ('NSKP: ', I6)
      if (COND_N(ipL)) then
         write (ipL, 101) nskp
      else if (COND_S(ipL)) then
         write (*,   101) nskp
      endif
CCC_  - write member attributes to itMEM
      if (itMEM.ge.0) then
         if (iErr.eq.0) then
            call DVTcln (iErr, KTYPE_GROUP, ipP, itMEM)
         endif
      else
 102     format ('Skip clone of member attributes.')
         if (COND_N(ipL)) then
            write (ipL, 102)
         else if (COND_S(ipL)) then
            write (*,   102)
         endif
      endif
      call DAtrcU (ipL, iErr, 'M', 'CNQgrq')
CCC_  - recover GROUP;GBASE
      if (iErr.eq.0) then
         VV (jgb) = CV (jgr)
         CV (jgr) = VGRP
         VV (jgr) = VGRP
      endif
      if (VV (jmv).ne.' ') then
         read (VV (jmv), *) MAXV
      else
         MAXV = -1
      endif
CCC_  - end
      call DAtrcU (ipL, iErr, 'R', 'CNQgrq')
      RETURN
      END
CCC_& CNQdmv  ## Get MaxV and clone
      subroutine CNQdmv
     O    (iErr,
     O     MAXV,
     O     TT,    VV,  CV,   AA,  EE,  NT,  LT,
     I     TG,    VG,  NTG,  LTG, K0,
     I     ipI,   ipO, ipE,  itMEM)
CCC_ + Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   MAXV
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
      _INTENT(IN, integer)   ipI, ipO, ipE
      _INTENT(IN, integer)   itMEM
      integer nskp
      integer jit, jbs, jkv
      integer kanch
      integer NTini
      integer IR, NR, IRtmp
      integer kv
      integer jedmy
c
      integer    LVAR
      parameter (LVAR = 32768)
      integer    Kflg (LVAR)
      integer    jv
      logical    OEOF
CCC_ + Body
      iErr = 0
c
      MAXV = 0
      do jv = 1, LVAR
         kflg (jv) = 0
      enddo
c
      Kanch = -1
      NT = 0
      if (iErr.eq.0) then
         call UKAsvA (jit,  TT, CV, NT, LT, K0, 'ITEM',  ' ')
         call UKAsvA (jbs,  TT, CV, NT, LT, K0, 'CBASE', ' ')
         call UKAsvA (jkv,  TT, CV, NT, LT, K0, 'KV',    ' ')
         call DVTcpi (TT, CV, NT, LT, TG, VG, NTG, LTG, 'CROOT')
         call DVTcpi (TT, CV, NT, LT, TG, VG, NTG, LTG, 'GROUP')
         call UKDkaa (iErr, TT, NT, LT, K0, CV, 'DMV', ipE)
      endif
      NTini = NT
      call UUrwnd (iErr, ipI)
      DO
         NT = NTini
         call DVTcol
     $       (iErr,
     $        nskp, NT, TT, VV, AA, EE, CV, Kanch, LT, ipI)
         if (iErr.ne.0) goto 900
c$$$         call UKDkaa (jedmy, TT, NT, LT, K0, VV,  'DMVa', ipE)
         if (VV (jit).ne.' ') then
            if (VV (jkv).ne.' ')then
               read (VV (jkv), *) kv
               MAXV = MAX (KV, MAXV)
               if (kv.gt.LVAR) then
                  iErr = -1
                  call UDMfi1 (ipE, '(''OVERFLOW: '', I12)', LVAR)
                  goto 900
               endif
               if (Kflg (kv).eq.0) then
                  call DVTwar (jedmy, TT, VV, AA, EE, NT, itMEM)
               endif
               Kflg (kv) = Kflg (kv) + 1
            endif
         endif
      ENDDO
 900  continue
      call UUieof (OEOF, iErr)
      if (OEOF) then
         iErr = 1
      else
         iErr = -1
      endif
      call DAtrcU (ipE, iErr, 'R', 'CNQdmv')
      iErr = MIN (0, iErr)
      RETURN
      END
CCC_& CNQgcn  ## Get coordinate names
      subroutine CNQgcn
     O    (iErr,
     O     Nco,  NCM,
     O     Ncnm, CNM,  MaxCo,
     O     TT,   VV,   CV,   AA,  EE,  NT,  LT,
     I     TG,   VG,   NTG,  LTG, K0,  VCO,
     I     ipI,  ipO,  ipE)
CCC_ + Declaration
      _INTENT(OUT,integer)   iErr
c
      _INTENT(IN, integer)   MaxCo
      _INTENT(OUT,integer)   Nco, Ncnm
      _INTENT(OUT,integer)   NCM (MaxCo)
      _INTENT(OUT,character) CNM (2, MaxCo)*(*)
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
      _INTENT(IN, character) VCO*(*)
      _INTENT(IN, integer)   ipI, ipO, ipE
c
      integer jcs
      integer NTini
      integer Kanch, nskp
c
      integer    MaxDim
      parameter (MaxDim = 32)
      character  CPRM (MaxDim)*32
      integer    nprm
      integer    jc, jco, jgb, jd
c
      logical    OEOF, OFOUND
CCC_ + Body
      iErr = 0
      NCO  = 0
      Ncnm = 0
c
      Kanch = -1
      NT = 0
      if (iErr.eq.0) then
         call UKAsvA (jcs,  TT, CV, NT, LT, K0, 'COSTR', ' ')
         call DVTcpi (TT, CV, NT, LT, TG, VG, NTG, LTG, 'CROOT')
         call UKStgA (jgb, TG, NTG, LTG, K0, 'GBASE')
         if (jgb.ge.K0.and.VG (jgb).ne.' ') then
            call UKAsvA (jd,  TT, CV, NT, LT, K0, 'GROUP', VG (jgb))
          else
            call DVTcpi (TT, CV, NT, LT, TG, VG, NTG, LTG, 'GROUP')
         endif
         call UKDkaa (iErr, TT, NT, LT, K0, CV, 'GCM', ipE)
      endif
      NTini = NT
c
      call UUrwnd (iErr, ipI)
      DO
         NT = NTini
         call DVTcol
     $       (iErr,
     $        nskp, NT, TT, VV, AA, EE, CV, Kanch, LT, ipI)
         if (iErr.ne.0) goto 900
         if (VV (jcs).ne.' ') then
            call USSccv (CPRM, NPRM, MaxDim, VV (jcs), ' ;')
            NCO  = MAX (NPRM, NCO)
            do jc = 1, NPRM
               OFOUND = .false.
               do jco = 1, Ncnm
                  if (CNM (1, jco).eq.CPRM (jc)) then
                     OFOUND = .true.
                     goto 190
                  endif
               enddo
 190           continue
               if (.not.OFOUND) then
                  Ncnm = Ncnm + 1
                  CNM (1, Ncnm) = CPRm (jc)
               endif
            enddo
         endif
      ENDDO
 900  continue
      call UUieof (OEOF, iErr)
      if (OEOF) then
         iErr = 1
      else
         iErr = -1
      endif
      call DAtrcU (ipE, iErr, 'R', 'CNQgcn')
      iErr = MIN (0, iErr)
c
 103  format ('CNQGNM: ', I4, 1x, A)
      if (COND_N(ipE)) then
         do jco = 1, Ncnm
            write (ipE, 103) jco, _TRIM(CNM (1, jco))
         enddo
      else if (COND_S(ipE)) then
         do jco = 1, Ncnm
            write (*,   103) jco, _TRIM(CNM (1, jco))
         enddo
      endif
c
      RETURN
      END
CCC_& CNQgco  ## Get all coordinates
      subroutine CNQgco
     O    (iErr,
     O     NCM,  Coor, LCV, MaxCo,
     M     Ncnm, CNM,
     O     TT,   VV,   CV,   AA,  EE,  NT,  LT,
     I     TG,   VG,   NTG,  LTG, K0,  VCO,
     I     DPFX, ipI,  ipO,  ipE)
CCC_ + Declaration
      _INTENT(OUT,integer)   iErr
c
      _INTENT(IN, integer)   LCV, MaxCo
      _INTENT(OUT,integer)   NCM (MaxCo)
      _INTENT(OUT,_REALSTD)  Coor(LCV, MaxCo)
c
      _INTENT(IN,   integer)   Ncnm
      _INTENT(INOUT,character) CNM (2, *)*(*)
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
      _INTENT(IN, character) VCO*(*)
      _INTENT(IN, character) DPFX*(*)
      _INTENT(IN, integer)   ipI, ipO, ipE
c
      integer jck, jcx, jcr, jd, jcbs, jcorg
      integer j,   jco, jx
      integer NTini
      integer Kanch, nskp
c
      integer   kaDV (VIO_KPOLICY_MAX)
      character saDV*(VIO_SPOLICY_LEN)
      character CTYP*(8)
      character FMT *(VIO_FORMAT_MAX)
      integer   KUFMT
      integer   NV
CCC_ + Body
      iErr = 0
CCC_  - Coordinate geometries
      NT = 0
      call UKAsvA (jd,    TT, CV, NT, LT, K0, 'GROUP', 'COOR')
      call UKAsvA (jd,    TT, CV, NT, LT, K0, 'ITEM',  VCO)
      call UKAsvA (jcbs,  TT, CV, NT, LT, K0, 'CBASE', ' ')
      call UKAsvA (jcorg, TT, CV, NT, LT, K0, 'CORG',  ' ')
c
      call UKDkaa (iErr, TT, NT, LT, K0, CV, 'GCOa', ipE)
c
      jco   = 0
      NTini = NT
      Kanch = -1
      call UUrwnd (iErr, ipI)
      DO
         NT = NTini
         call DVTcol
     $       (iErr,
     $        nskp, NT, TT, VV, AA, EE, CV, Kanch, LT, ipI)
         if (iErr.ne.0) goto 900
         jx = 0
         do j = 1, MIN (Ncnm, MaxCo)
            if (VV (jcbs) .eq. Cnm (1, j)) then
               jco = jco + 1
               jx  = j
               goto 800
            endif
         enddo
 800     continue
         if (jx.gt.0) then
            CNM(2, jx) = VV(jcorg)
            call UKDkaa (iErr, TT, NT, LT, K0, VV, 'GCOx', ipE)
            call DVSbng
     O          (iErr,
     O           CTYP,  KUFMT, FMT,
     I           ' ',
     I           ipI,   ipO,   ipE)
            call DVSbnr
     O          (iErr,
     M           kaDV,  saDV,  NV,
     I           DPFX,  FMT,   ipI,   ipO,   ipE)
            call DVFrep (iErr, kaDV, saDV, ipO, ipE)
            NCM (jx) = NV
            call DVHriS
     O          (iErr,
     M           kaDV,  saDV,
     O           COOR (1, jx), NV,
     I           ' ',   KUFMT, FMT, ' ', ipO, ipE)
         endif
         if (jco.ge.Ncnm) goto 900
      ENDDO
 900  continue
CCC_  - end
 901  format ('CNQGCO: coordinates ', 2I5)
      if (COND_N(ipE)) then
         write (ipE, 901) jco, Ncnm
      else if (COND_S(ipE)) then
         write (*,   901) jco, Ncnm
      endif
c
      call DAtrcU (ipE, iErr, 'R', 'CNQgco')
      RETURN
      END
CCC_& CNQgcv  ## Get coordinate (property) variables
      subroutine CNQgcv
     O    (iErr,
     M     JCP,
     O     CPR,  VCPR, LCV,  MaxCpr,
     O     TT,   VV,   CV,   AA,  EE,  NT,  LT,
     I     TG,   VG,   NTG,  LTG, K0,  CNM, PNM,
     I     DPFX, ipI,  ipO,  ipE)
CCC_ + Declaration
      _INTENT(OUT,integer)   iErr
c
      _INTENT(INOUT,integer)   JCP
      _INTENT(IN,   integer)   LCV, MaxCpr
      _INTENT(OUT,  character) CPR (MaxCpr)*(*)
      _INTENT(OUT,  _REALSTD)  VCPR(LCV, MaxCpr)
c
      _INTENT(IN, character) CNM*(*)
      _INTENT(IN, character) PNM*(*)
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
      _INTENT(IN, character) DPFX*(*)
      _INTENT(IN, integer)   ipI, ipO, ipE
c
      integer jck, jcx, jcr, jci, jcbs, jcorg, jd
      integer j,   jx
      integer NTini
      integer Kanch, nskp
c
      integer   kaDV (VIO_KPOLICY_MAX)
      character saDV*(VIO_SPOLICY_LEN)
      character CTYP*(8)
      character FMT *(VIO_FORMAT_MAX)
      integer   KUFMT
      integer   NV
      integer   jcpini
CCC_ + Body
      iErr = 0
      jcpini = JCP
CCC_  - Coordinate geometries
      NT = 0
      call UKAsvA (jd,    TT, CV, NT, LT, K0, 'GROUP', 'COOR')
      call UKAsvA (jci,   TT, CV, NT, LT, K0, 'ITEM',  PNM)
      call UKAsvA (jcbs,  TT, CV, NT, LT, K0, 'CBASE', ' ')
      call UKAsvA (jcorg, TT, CV, NT, LT, K0, 'CORG',  CNM)
c
      call UKDkaa (iErr, TT, NT, LT, K0, CV, 'GCva', ipE)
c
      NTini = NT
      Kanch = -1
      call UUrwnd (iErr, ipI)
      DO
         NT = NTini
         call DVTcol
     $       (iErr,
     $        nskp, NT, TT, VV, AA, EE, CV, Kanch, LT, ipI)
         if (iErr.ne.0) goto 900
         jcp = jcp + 1
         CPR(jcp) = VV(jci)
         call UKDkaa (iErr, TT, NT, LT, K0, VV, 'GCVx', ipE)
         call DVSbng
     O        (iErr,
     O        CTYP,  KUFMT, FMT,
     I        ' ',
     I        ipI,   ipO,   ipE)
         call DVSbnr
     O        (iErr,
     M        kaDV,  saDV,  NV,
     I        DPFX,  FMT,   ipI,   ipO,   ipE)
         call DVFrep (iErr, kaDV, saDV, ipO, ipE)
         call DVHriS
     O        (iErr,
     M        kaDV,  saDV,
     O        VCPR(1, jcp), NV,
     I        ' ',   KUFMT, FMT, ' ', ipO, ipE)
         if (jcp.ge.MaxCpr) goto 900
      ENDDO
 900  continue
CCC_  - end
 901  format ('CNQGCV: coordinates ', 2I5)
      if (COND_N(ipE)) then
         write (ipE, 901) jcp, jcp - JCPINI
      else if (COND_S(ipE)) then
         write (*,   901) jcp, jcp - JCPINI
      endif
c
      call DAtrcU (ipE, iErr, 'R', 'CNQgcv')
      RETURN
      END
CCC_& CNQgxt  ## Get transformation table
      subroutine CNQgxt
     O    (iErr,
     W     IE,    LIE,
     O     KGX,   LGX,  LPa,  MG,
     O     TT,    VV,   CV,   AA,  EE,  NT,  LT,
     I     TG,    VG,   NTG,  LTG, K0,
     I     CROOT, VITM,
     I     DPFX,  ipI,  ipO,  ipE)
CCC_ + Declaration
      _INTENT(OUT,integer)   iErr
c
      _INTENT(IN, integer)   LIE, LGX
      _INTENT(OUT,integer)   IE (*)
      _INTENT(OUT,integer)   LPa (*)
      _INTENT(OUT,integer)   KGX (*)
      _INTENT(OUT,integer)   MG
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
      _INTENT(IN, character) VITM  *(*)
      _INTENT(IN, character) CROOT *(*)
      _INTENT(IN, character) DPFX  *(*)
c
      _INTENT(IN, integer)   ipI, ipO, ipE
c
      integer jd
      integer jrnk
      integer nskp, kanch
      integer jnmp
      integer IR, NR, IRtmp
      integer jedmy
c
      integer   kaDV (VIO_KPOLICY_MAX)
      character saDV*(VIO_SPOLICY_LEN)
      character CTYP*(8)
      character FMT *(VIO_FORMAT_MAX)
      integer   KUFMT
      integer   NV
      integer   NP, MP, MX, MY, MXY
      integer   MXU, MYU, MXYU
      integer   kp, kp0, kpp, kgg
      integer   ki, ko,  kg,  kxw, kyw
CCC_ + Body
      iErr = 0
      MG   = 0
CCC_  - Loop decomposition
      if (iErr.eq.0) then
         call UKStgA (jd, TG, NTG, LTG, K0, 'LOOPI')
         if (VG (jd).eq.' ') then
            LPa (1) = 0
            LPa (2) = 0
            LPa (3) = 0
         else
            if (jd.ge.K0) read (VG (jd), *) LPa (1)
            if (jd.ge.K0) call UKStgA (jd, TG, NTG, LTG, K0, 'LOOPB')
            if (jd.ge.K0) read (VG (jd), *) LPa (2)
            if (jd.ge.K0) call UKStgA (jd, TG, NTG, LTG, K0, 'LOOPO')
            if (jd.ge.K0) read (VG (jd), *) LPa (3)
            if (jd.lt.K0) iErr = -1
         endif
      endif
CCC_  - Global table
      NT = 0
      call UKAsvA (jd,   TT, CV, NT, LT, K0, 'ITEM',  VITM)
      call UKAsvA (jd,   TT, CV, NT, LT, K0, 'CROOT', CROOT)
      call UKAsvA (jrnk, TT, CV, NT, LT, K0, 'IR',    ' ')
      call UKAsvA (jnmp, TT, CV, NT, LT, K0, 'NR',    ' ')
c
      call DVTcpi (TT, CV, NT, LT, TG, VG, NTG, LTG, 'KDL')
      call DVTcpi (TT, CV, NT, LT, TG, VG, NTG, LTG, 'NXG')
      call DVTcpi (TT, CV, NT, LT, TG, VG, NTG, LTG, 'NYG')
      call DVTcpi (TT, CV, NT, LT, TG, VG, NTG, LTG, 'LXO')
      call DVTcpi (TT, CV, NT, LT, TG, VG, NTG, LTG, 'LYO')
      call DVTcpi (TT, CV, NT, LT, TG, VG, NTG, LTG, 'LXB')
      call DVTcpi (TT, CV, NT, LT, TG, VG, NTG, LTG, 'LYB')
      call DVTcpi (TT, CV, NT, LT, TG, VG, NTG, LTG, 'LXW')
      call DVTcpi (TT, CV, NT, LT, TG, VG, NTG, LTG, 'LYW')
      call DVTcpi (TT, CV, NT, LT, TG, VG, NTG, LTG, 'ISH')
      call DVTcpi (TT, CV, NT, LT, TG, VG, NTG, LTG, 'NR')
c
      call UKDkaa (iErr, TT, NT, LT, K0, CV, 'GXTa', ipE)
CCC_  - find group anchor
      Kanch = -999
      if (iErr.eq.0) then
         call UUrwnd (iErr, ipI)
         call DVTcol
     $       (iErr,
     $        nskp, NT, TT, VV, AA, EE, CV, Kanch, LT, ipI)
      endif
      if (iErr.eq.0)
     $     call UKDkaa (iErr, TT, NT, LT, K0, VV, 'GXTz', ipE)

 101  format ('NSKP: ', I6)
      if (COND_N(ipE)) then
         write (ipE, 101) nskp
      else if (COND_S(ipE)) then
         write (*,   101) nskp
      endif
c
      read (VV (jnmp), *) NR
c
      if (iErr.eq.0)
     $     call DVFati (iErr, kaDV,  saDV, -1, ' ')
      if (iErr.eq.0) then
         call DVSbng
     O       (iErr,
     O        CTYP,  KUFMT, FMT,
     I        ' ',
     I        ipI,   ipO,   ipE)
      endif
 201  format ('GXT: ', 2I5)
 301  format ('MATRIX CONVERSION: TO   ', 4I7)
 302  format ('MATRIX CONVERSION: FROM ', 4I7)
 303  format ('MATRIX SIZE ',I3, 1x, 3I5)
 309  format ('PANIC: INVALID REVISION ', I3, 1x, 2I7)
      kp0   = 1
      MXY   = 0
      MXYU  = 0
      do IR = 0, NR - 1
         if (COND_N(ipE)) then
            write (ipE, 201) IR, NR
         else if (COND_S(ipE)) then
            write (*,   201) IR, NR
         endif
         if (iErr.eq.0) then
            call DVSbnr
     O          (iErr,
     M           kaDV,  saDV,  NV,
     I           DPFX,  FMT,   ipI,   ipO,   ipE)
            call DVFrep (jeDmy, kaDV, saDV, ipE, ipO)
         endif
         if (iErr.eq.0) then
            call DVHriI
     O          (iErr,
     M           kaDV,  saDV,
     O           IE,    NV,
     I           ' ',   KUFMT, FMT, ' ', ipE, ipO)
         endif
         if (REVID_EA .ne. EA_VAR(IE)) then
            if (COND_N(ipE)) then
               write (ipE, 309) ir, EA_VAR(IE), REVID_EA
            else if (COND_S(ipE)) then
               write (*,   309) ir, EA_VAR(IE), REVID_EA
            endif
            stop
         endif
c$$$         do kp = 1, 49
c$$$            write (*, *) 'IE', kp, IE(kp)
c$$$         enddo
         NP = EA_NP(IE)
         MP = EA_MP(IE)
         if (COND_N(ipE)) then
            write (ipE, 303) ir, NP, MP, LPa (2)
         else if (COND_S(ipE)) then
            write (*,   303) ir, NP, MP, LPa (2)
         endif
         if (LPa (2).eq.0) then
            LPa (1) = 1
c$$$            LPa (2) = NP
            LPa (2) = MP
            LPa (3) = 1
         endif
c
         if (IR.eq.0) then
            MX  = EA_MX(IE)
            MY  = EA_MY(IE)
            MXY = MX * MY
            MXU  = EA_MXU(IE)
            MYU  = EA_MYU(IE)
            MXYU = MXU * MYU
            if (COND_N(ipE)) then
               write (ipE, 301) LPa(1), MXU,    MYU,    LPa(3)
               write (ipE, 302) LPa(1), LPa(2), LPa(3), MAX(1, NR)
            else if (COND_S(ipE)) then
               write (*,   301) LPa(1), MXU,    MYU,    LPa(3)
               write (*,   302) LPa(1), LPa(2), LPa(3), MAX(1, NR)
            endif
         endif
c$$$         write (*, *) 'KGX', LPa(1), LPa(2), LPa(3)
         do kp = 0, NP - 1
c$$$            kg = EA_listLW(IE,kp)
            kg  = EA_listPW(IE,kp)
            kxw = EA_listXW(IE,kp)
            kyw = EA_listYW(IE,kp)
c$$$            if (kxw.ge.0.and.kyw.ge.0) then
            if (kxw.ne.-1.and.kyw.ne.-1) then
               do    ko = 1, LPa (3)
                  do ki = 1, LPa (1)
                     kgg =  (ko - 1) * LPa (1) * MXYU
     $                    + (kg - 1) * LPa (1)
     $                    +  ki
c$$$                     kgg =  (ko - 1) * LPa (1) * MXY
c$$$     $                    + (kg - 1) * LPa (1)
c$$$     $                    +  ki
                     kpp =  (ko - 1) * LPa (1) * LPa (2)
     $                    + kp       * LPa (1)
     $                    + ki
                     KGX (kgg) = kp0 + kpp - 1
c$$$                     write (*,*) 'KGX',ki,ko,kp,IR,kpp,kg,kgg,KGX (kgg)
                  enddo
               enddo
            endif
         enddo
         kp0 = kp0 + LPa (1) * LPa (2) * LPa (3)
      enddo
      if (iErr.eq.0) then
c$$$         MG = LPa (1) * MXY * LPa (3)
         MG = LPa (1) * MXYU * LPa (3)
      endif
CCC_  - end
      call DAtrcU (ipE, iErr, 'R', 'CNQgxt')
      RETURN
      END
CCC_& CNQpre  ## Preparation
      subroutine CNQpre
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
CCC_ + Declaration
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
CCC_ + Body
      if (iErr.eq.0) call UUrwnd (iErr, ipI)
CCC_  - cue to group head, clone member info to a scratch
      if (iErr.eq.0) then
         call CNQgrq
     O       (iErr,
     O        MAXV, ivST, ivEN,
     O        NSKP,
     O        TG,   VG,  CG, AA, EE, NTG, LTG, K0,
     I        VGRP, CROOT,
     I        ipE,  ipI, itMEM)
      endif
CCC_  - maxv detection
      if (iErr.eq.0.and.MaxV.eq.0) then
         call CNQdmv
     O       (iErr,
     O        MAXV,
     O        TC,    VC,  CC,   AA,  EE,  NTC,  LTC,
     I        TG,    VG,  NTG,  LTG, K0,
     I        ipI,   ipO, ipE,  itMEM)
      endif
CCC_  - coordinate names
      if (iErr.eq.0) then
         call CNQgcn
     O       (iErr,
     O        Nco,   NCM,
     O        Ncnm,  CNM,  MaxCo,
     O        TC,    VC,   CC,   AA,  EE,  NTC, LTC,
     I        TG,    VG,   NTG,  LTG, K0,  VCO,
     I        itMEM, ipO,  ipE)
      endif
CCC_  - coordinates
      if (iErr.eq.0) then
         call CNQgco
     O       (iErr,
     O        NCM,  Coor, LCV,  MaxCo,
     M        Ncnm, CNM,
     O        TC,   VC,   CC,   AA,  EE,  NTC, LTC,
     I        TG,   VG,   NTG,  LTG, K0,  VCO,
     I        DPFX, ipI,  ipO,  ipE)
         do jc = 1, Ncnm
            do j = 1, NCM (jc)
               write (*, *) _TRIM(CNM(1,jc)), jc, j, COOR (j, jc)
            enddo
         enddo
      endif
CCC_  - global conversion table
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
CCC_  - end
      call DAtrcU (ipE, iErr, 'R', 'CNQpre')
      RETURN
      END
CCC_& CNXUTL  ## IcIES/Cadenza/NetCDF utility announcement
      subroutine CNXUTL (STRA, STRB, IOP)
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
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
