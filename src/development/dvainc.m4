dnl development/dvainc.m4 --- IcIES/Development/DVA generation
dnl Maintainer:  SAITO Fuyuki
dnl Created: Jan 17 2012
dnl Time-stamp: <2020/09/15 12:19:33 fuyuki dvainc.m4>
dnl Copyright: 2012--2020 JAMSTEC, Ayako ABE-OUCHI
dnl Licensed under the Apache License, Version 2.0
dnl   (https://www.apache.org/licenses/LICENSE-2.0)
m4_divert(KILL)dnl
## CREATE_DVSW(ID, TYPE, TEXT)
m4_define([CREATE_DVSw],
[dnl {%fortran%}
CCC_ & DVSwt$1  ## Suite: open/write/close/report $4
      subroutine DVSwt$1
     O    (iErr,
     O     IRN,
     M     kaDV, saDV,
     I     IRT,  $1[]V, NV,  KU,  FMT, TXT)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(OUT,  integer)   IRN
      _INTENT(INOUT,integer)   kaDV (*)
      _INTENT(INOUT,character) saDV*(*)
      _INTENT(IN,   integer)   IRT
      _INTENT(IN,   character) FMT*(*)
      _INTENT(IN,   character) TXT*(*)
      _INTENT(IN,   integer)   KU, NV
      _INTENT(IN,   $2)   $1[]V (NV)
      integer   jvP
      integer   IRX,  LB
      integer   MREC, MLOG
      character FMTtmp*(80)
CCC_  - Body
      iErr   = 0
      LB     = 0
      IRX    = 0
      MREC   = 0
      MLOG   = 0
      FMTtmp = ' '
      IRN    = -1
CCC_   , preprocess
      if (iErr.eq.0) then
         call DVApre
     O       (iErr,
     O        LB,   FMTtmp, IRX, jvP,
     M        kaDV, saDV,
     I        FMT,  IRT)
      endif
CCC_   , write
      if (iErr.eq.0) then
         call DVApt$1
     O       (iErr,
     O        MREC, MLOG,
     I        $1[]V,
     I        NV,   LB,   KU, FMTtmp, IRX, jvP)
      endif
cc write(*, *) 'WT$1 PT', iErr, MREC, MLOG
CCC_   , postprocess
      if (iErr.eq.0) then
         call DVApos
     O       (iErr,
     O        IRN,
     M        kaDV,
     I        saDV, jvP, IRX, MREC, MLOG, .false.)
      endif
cc write(*, *) 'POS', iErr, IRN
CCC_   , always repeat
      call DVSrpa
     I    (iErr,
     I     kaDV, saDV,
     I     'W',  '$1', KU,  FMTtmp,
     I     NV,   LB,   IRN, IRX, MREC, MLOG, TXT)
      RETURN
      END
dnl {%/fortran%}
])


## CREATE_DVSr(ID, TYPE, TEXT)
m4_define([CREATE_DVSr],
[dnl {%fortran%}
CCC_ & DVSrd$1  ## Suite: open/read/close/report $4
      subroutine DVSrd$1
     O    (iErr,
     O     $1[]V, IRN,
     M     kaDV, saDV,
     I     IRT,  NV,  KU,  FMT, TXT)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(OUT,  integer)   IRN
      _INTENT(INOUT,integer)   kaDV (*)
      _INTENT(INOUT,character) saDV*(*)
      _INTENT(IN,   integer)   IRT
      _INTENT(IN,   character) FMT*(*)
      _INTENT(IN,   character) TXT*(*)
      _INTENT(IN,   integer)   KU, NV
      _INTENT(OUT,  $2)   $1[]V (NV)
      integer   jvP
      integer   IRX,  LB
      integer   MREC, MLOG
      character FMTtmp*(80)
      integer   jedmy
      logical   OCLS
CCC_  - Body
      iErr = 0
CCC_   , preparationcess
      if (iErr.eq.0) then
         call DVApre
     O       (iErr,
     O        LB,   FMTtmp, IRX, jvP,
     M        kaDV, saDV,
     I        FMT,  IRT)
      endif
CCC_   , read
      if (iErr.eq.0) then
         call DVAgt$1
     O       (iErr,
     O        MREC,  MLOG,
     O        $1[]V,
     I        NV,    LB,   KU, FMTtmp, IRX, jvP)
      endif
CCC_   , postprocess (always)
      OCLS = (iErr.ne.0)
      call DVApos
     O    (jedmy,
     O     IRN,
     M     kaDV,
     I     saDV, jvP, IRX, MREC, MLOG, OCLS)
      if (iErr.eq.0) iErr = jedmy
CCC_   , always repeat
      call DVSrpa
     I    (iErr,
     I     kaDV, saDV,
     I     'R',  '$1', KU,  FMTtmp,
     I     NV,   LB,   IRN, IRX, MREC, MLOG, TXT)
      RETURN
      END
dnl {%/fortran%}
])


## CREATE_DVAp(ID, TYPE, BYTE, TEXT)
m4_define([CREATE_DVAp],
[dnl {%fortran%}
CCC_ & DVApt$1  ## Access: put $4
      subroutine DVApt$1
     O    (iErr,
     O     MREC,  MLOG,
     I     $1[]V,
     I     N,     LB,  KUfmt, FMT,  IRX, ivP)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   MREC, MLOG
      _INTENT(IN, integer)   N,    KUfmt, LB
      _INTENT(IN, integer)   IRX,  ivP
      _INTENT(IN, character) FMT*(*)
      _INTENT(IN, $2) $1[]V (N)
c
      integer    KUtyp
      parameter (KUtyp = $3)
c
      integer j, ir, nm, nvm
CCC_  * Body
      iErr = 0
      mrec = 0
      mlog = 0
c
cc write(*, *) 'PT$1', KUfmt, IRX, N, LB, '/', FMT, '/'
CCC_   . sequential (LB<=0)
      if (LB.le.0) then
CCC_    * formatted
         if (FMT (1:1).eq.'(') then
            call UUwwF$1 (iErr, ivP, FMT, N, $1[]V)
CCC_    * formatted asterisk
         else if (FMT .eq. '*') then
            call UUwwS$1 (iErr, ivP, N, $1[]V)
CCC_    * unformatted
         else
            call UUwwU$1 (iErr, ivP, N, $1[]V)
         endif
         if (iErr.eq.0) then
            mrec = mrec + 1
            mlog = mlog + 1
         endif
CCC_   . unformatted direct (LB>0; blank FMT)
      else if (FMT.eq.' ') then
         ir = IRX
CCC_    * direct once
         if ((KUtyp * N) .le. LB) then
            call UUwwR$1 (iErr, ivP, ir, N, $1[]V)
cc          write(*, *) 'DIRECT', ivP, ir, N, iErr
            if (iErr.eq.0) mrec = mrec + 1
CCC_    * direct divide
         else
            NVM = LB / KUtyp
            do j = 1, N, NVM
               ir = IRX + mrec
               nm = min (NVM, N - j + 1)
               call UUwwR$1 (iErr, ivP, ir, nm, $1[]V (j))
               if (iErr.ne.0) goto 220
               mrec = mrec + 1
            enddo
 220        continue
         endif
         if (iErr.eq.0) mlog = mlog + 1
CCC_   . formatted direct (LB > 0; non-blank FMT; KUfmt>0)
      else if (KUfmt.gt.0) then
         ir = IRX
CCC_    * direct once
         if ((KUfmt * N) .le. LB) then
            call UUwwD$1 (iErr, ivP, ir, FMT, N, $1[]V)
            if (iErr.eq.0) mrec = mrec + 1
CCC_    * direct divide (every KUfmt members)
         else
            NVM = LB / KUfmt
            do j = 1, N, NVM
               ir = IRX + mrec
               nm = min (NVM, N - j + 1)
               call UUwwD$1 (iErr, ivP, ir, FMT, nm, $1[]V (j))
               if (iErr.ne.0) goto 210
               mrec = mrec + 1
            enddo
 210        continue
         endif
         if (iErr.eq.0) mlog = mlog + 1
      else
CCC         write (*, *) LB, FMT, KUfmt
         iErr = -3
      endif
      RETURN
      END
dnl {%/fortran%}
])


## CREATE_DVAg(ID, TYPE, BYTE, TEXT)
m4_define([CREATE_DVAg],
[dnl {%fortran%}
CCC_ & DVAgt$1  ## Access: get $4
      subroutine DVAgt$1
     O    (iErr,
     O     MREC,  MLOG,
     O     $1[]V,
     I     N,     LB,  KUfmt, FMT,  IRX, ivP)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   MREC, MLOG
      _INTENT(IN, integer)   N,    KUfmt, LB
      _INTENT(IN, integer)   IRX,  ivP
      _INTENT(IN, character) FMT*(*)
      _INTENT(OUT,$2) $1[]V (N)
c
      integer    KUtyp
      parameter (KUtyp = $3)
c
      integer j, ir, nm, nvm
CCC_  * Body
      iErr = 0
      mrec = 0
      mlog = 0
CCC_   . sequential
      if (LB.le.0) then
CCC_    * formatted
         if (FMT (1:1).eq.'(') then
            call UUwrF$1 (iErr, ivP, FMT, N, $1[]V)
CCC_    * formatted asterisk
         else if (FMT .eq. '*') then
            call UUwrS$1 (iErr, ivP, N, $1[]V)
CCC_    * unformatted
         else
            call UUwrU$1 (iErr, ivP, N, $1[]V)
         endif
         if (iErr.eq.0) then
            mrec = mrec + 1
            mlog = mlog + 1
         endif
CCC_   . unformatted direct
      else if (FMT.eq.' ') then
         ir = IRX
CCC_    * direct once
         if ((KUtyp * N) .le. LB) then
            call UUwrR$1 (iErr, ivP, ir, N, $1[]V)
            if (iErr.eq.0) mrec = mrec + 1
CCC_    * direct divide
         else
            NVM = LB / KUtyp
            do j = 1, N, NVM
               ir = IRX + mrec
               nm = min (NVM, N - j + 1)
               call UUwrR$1 (iErr, ivP, ir, nm, $1[]V (j))
               if (iErr.ne.0) goto 220
               mrec = mrec + 1
            enddo
 220        continue
         endif
         if (iErr.eq.0) mlog = mlog + 1
CCC_   . formatted direct
      else if (KUfmt.gt.0) then
         ir = IRX
CCC_    * direct once
         if ((KUfmt * N) .le. LB) then
            call UUwrD$1 (iErr, ivP, ir, FMT, N, $1[]V)
            if (iErr.eq.0) mrec = mrec + 1
CCC_    * direct divide
         else
            NVM = LB / KUfmt
            do j = 1, N, NVM
               ir = IRX + mrec
               nm = min (NVM, N - j + 1)
               call UUwrD$1 (iErr, ivP, ir, FMT, nm, $1[]V (j))
               if (iErr.ne.0) goto 210
               mrec = mrec + 1
            enddo
 210        continue
         endif
         if (iErr.eq.0) mlog = mlog + 1
      else
CCC         write (*, *) LB, FMT, KUfmt
         iErr = -3
      endif
      RETURN
      END
dnl {%/fortran%}
])
m4_divert()dnl
dnl MAIN
#if     __DVAINC == 0
CREATE_DVSw(I, integer,  INTEGER_0_BYTES, integer)dnl
CREATE_DVSw(D, _REAL64,  REAL_64_BYTES,   double)dnl
CREATE_DVSw(F, _REAL32,  REAL_32_BYTES,   float)dnl
CREATE_DVSw(S, _REALSTD, REAL_STD_BYTES, [real standard])dnl
#elif   __DVAINC == 1
CREATE_DVSr(I, integer,  INTEGER_0_BYTES, integer)dnl
CREATE_DVSr(D, _REAL64,  REAL_64_BYTES,   double)dnl
CREATE_DVSr(F, _REAL32,  REAL_32_BYTES,   float)dnl
CREATE_DVSr(S, _REALSTD, REAL_STD_BYTES, [real standard])dnl
#elif   __DVAINC == 2
CREATE_DVAp(I, integer,  INTEGER_0_BYTES, integer)dnl
CREATE_DVAp(D, _REAL64,  REAL_64_BYTES,   double)dnl
CREATE_DVAp(F, _REAL32,  REAL_32_BYTES,   float)dnl
#elif   __DVAINC == 3
CREATE_DVAg(I, integer,  INTEGER_0_BYTES, integer)dnl
CREATE_DVAg(D, _REAL64,  REAL_64_BYTES,   double)dnl
CREATE_DVAg(F, _REAL32,  REAL_32_BYTES,   float)dnl
#endif
dnl Local Variables:
dnl mode: autoconf
dnl End:
