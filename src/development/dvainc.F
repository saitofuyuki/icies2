#if     __DVAINC == 0
CCC_ & DVSwtI  ## Suite: open/write/close/report integer
      subroutine DVSwtI
     O    (iErr,
     O     IRN,
     M     kaDV, saDV,
     I     IRT,  IV, NV,  KU,  FMT, TXT)
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
      _INTENT(IN,   integer)   IV (NV)
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
         call DVAptI
     O       (iErr,
     O        MREC, MLOG,
     I        IV,
     I        NV,   LB,   KU, FMTtmp, IRX, jvP)
      endif
cc write(*, *) 'WTI PT', iErr, MREC, MLOG
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
     I     'W',  'I', KU,  FMTtmp,
     I     NV,   LB,   IRN, IRX, MREC, MLOG, TXT)
      RETURN
      END
CCC_ & DVSwtD  ## Suite: open/write/close/report double
      subroutine DVSwtD
     O    (iErr,
     O     IRN,
     M     kaDV, saDV,
     I     IRT,  DV, NV,  KU,  FMT, TXT)
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
      _INTENT(IN,   _REAL64)   DV (NV)
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
         call DVAptD
     O       (iErr,
     O        MREC, MLOG,
     I        DV,
     I        NV,   LB,   KU, FMTtmp, IRX, jvP)
      endif
cc write(*, *) 'WTD PT', iErr, MREC, MLOG
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
     I     'W',  'D', KU,  FMTtmp,
     I     NV,   LB,   IRN, IRX, MREC, MLOG, TXT)
      RETURN
      END
CCC_ & DVSwtF  ## Suite: open/write/close/report float
      subroutine DVSwtF
     O    (iErr,
     O     IRN,
     M     kaDV, saDV,
     I     IRT,  FV, NV,  KU,  FMT, TXT)
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
      _INTENT(IN,   _REAL32)   FV (NV)
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
         call DVAptF
     O       (iErr,
     O        MREC, MLOG,
     I        FV,
     I        NV,   LB,   KU, FMTtmp, IRX, jvP)
      endif
cc write(*, *) 'WTF PT', iErr, MREC, MLOG
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
     I     'W',  'F', KU,  FMTtmp,
     I     NV,   LB,   IRN, IRX, MREC, MLOG, TXT)
      RETURN
      END
CCC_ & DVSwtS  ## Suite: open/write/close/report real standard
      subroutine DVSwtS
     O    (iErr,
     O     IRN,
     M     kaDV, saDV,
     I     IRT,  SV, NV,  KU,  FMT, TXT)
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
      _INTENT(IN,   _REALSTD)   SV (NV)
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
         call DVAptS
     O       (iErr,
     O        MREC, MLOG,
     I        SV,
     I        NV,   LB,   KU, FMTtmp, IRX, jvP)
      endif
cc write(*, *) 'WTS PT', iErr, MREC, MLOG
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
     I     'W',  'S', KU,  FMTtmp,
     I     NV,   LB,   IRN, IRX, MREC, MLOG, TXT)
      RETURN
      END
#elif   __DVAINC == 1
CCC_ & DVSrdI  ## Suite: open/read/close/report integer
      subroutine DVSrdI
     O    (iErr,
     O     IV, IRN,
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
      _INTENT(OUT,  integer)   IV (NV)
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
         call DVAgtI
     O       (iErr,
     O        MREC,  MLOG,
     O        IV,
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
     I     'R',  'I', KU,  FMTtmp,
     I     NV,   LB,   IRN, IRX, MREC, MLOG, TXT)
      RETURN
      END
CCC_ & DVSrdD  ## Suite: open/read/close/report double
      subroutine DVSrdD
     O    (iErr,
     O     DV, IRN,
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
      _INTENT(OUT,  _REAL64)   DV (NV)
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
         call DVAgtD
     O       (iErr,
     O        MREC,  MLOG,
     O        DV,
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
     I     'R',  'D', KU,  FMTtmp,
     I     NV,   LB,   IRN, IRX, MREC, MLOG, TXT)
      RETURN
      END
CCC_ & DVSrdF  ## Suite: open/read/close/report float
      subroutine DVSrdF
     O    (iErr,
     O     FV, IRN,
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
      _INTENT(OUT,  _REAL32)   FV (NV)
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
         call DVAgtF
     O       (iErr,
     O        MREC,  MLOG,
     O        FV,
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
     I     'R',  'F', KU,  FMTtmp,
     I     NV,   LB,   IRN, IRX, MREC, MLOG, TXT)
      RETURN
      END
CCC_ & DVSrdS  ## Suite: open/read/close/report real standard
      subroutine DVSrdS
     O    (iErr,
     O     SV, IRN,
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
      _INTENT(OUT,  _REALSTD)   SV (NV)
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
         call DVAgtS
     O       (iErr,
     O        MREC,  MLOG,
     O        SV,
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
     I     'R',  'S', KU,  FMTtmp,
     I     NV,   LB,   IRN, IRX, MREC, MLOG, TXT)
      RETURN
      END
#elif   __DVAINC == 2
CCC_ & DVAptI  ## Access: put integer
      subroutine DVAptI
     O    (iErr,
     O     MREC,  MLOG,
     I     IV,
     I     N,     LB,  KUfmt, FMT,  IRX, ivP)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   MREC, MLOG
      _INTENT(IN, integer)   N,    KUfmt, LB
      _INTENT(IN, integer)   IRX,  ivP
      _INTENT(IN, character) FMT*(*)
      _INTENT(IN, integer) IV (N)
c
      integer    KUtyp
      parameter (KUtyp = INTEGER_0_BYTES)
c
      integer j, ir, nm, nvm
CCC_  * Body
      iErr = 0
      mrec = 0
      mlog = 0
c
cc write(*, *) 'PTI', KUfmt, IRX, N, LB, '/', FMT, '/'
CCC_   . sequential (LB<=0)
      if (LB.le.0) then
CCC_    * formatted
         if (FMT (1:1).eq.'(') then
            call UUwwFI (iErr, ivP, FMT, N, IV)
CCC_    * formatted asterisk
         else if (FMT .eq. '*') then
            call UUwwSI (iErr, ivP, N, IV)
CCC_    * unformatted
         else
            call UUwwUI (iErr, ivP, N, IV)
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
            call UUwwRI (iErr, ivP, ir, N, IV)
cc          write(*, *) 'DIRECT', ivP, ir, N, iErr
            if (iErr.eq.0) mrec = mrec + 1
CCC_    * direct divide
         else
            NVM = LB / KUtyp
            do j = 1, N, NVM
               ir = IRX + mrec
               nm = min (NVM, N - j + 1)
               call UUwwRI (iErr, ivP, ir, nm, IV (j))
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
            call UUwwDI (iErr, ivP, ir, FMT, N, IV)
            if (iErr.eq.0) mrec = mrec + 1
CCC_    * direct divide (every KUfmt members)
         else
            NVM = LB / KUfmt
            do j = 1, N, NVM
               ir = IRX + mrec
               nm = min (NVM, N - j + 1)
               call UUwwDI (iErr, ivP, ir, FMT, nm, IV (j))
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
CCC_ & DVAptD  ## Access: put double
      subroutine DVAptD
     O    (iErr,
     O     MREC,  MLOG,
     I     DV,
     I     N,     LB,  KUfmt, FMT,  IRX, ivP)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   MREC, MLOG
      _INTENT(IN, integer)   N,    KUfmt, LB
      _INTENT(IN, integer)   IRX,  ivP
      _INTENT(IN, character) FMT*(*)
      _INTENT(IN, _REAL64) DV (N)
c
      integer    KUtyp
      parameter (KUtyp = REAL_64_BYTES)
c
      integer j, ir, nm, nvm
CCC_  * Body
      iErr = 0
      mrec = 0
      mlog = 0
c
cc write(*, *) 'PTD', KUfmt, IRX, N, LB, '/', FMT, '/'
CCC_   . sequential (LB<=0)
      if (LB.le.0) then
CCC_    * formatted
         if (FMT (1:1).eq.'(') then
            call UUwwFD (iErr, ivP, FMT, N, DV)
CCC_    * formatted asterisk
         else if (FMT .eq. '*') then
            call UUwwSD (iErr, ivP, N, DV)
CCC_    * unformatted
         else
            call UUwwUD (iErr, ivP, N, DV)
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
            call UUwwRD (iErr, ivP, ir, N, DV)
cc          write(*, *) 'DIRECT', ivP, ir, N, iErr
            if (iErr.eq.0) mrec = mrec + 1
CCC_    * direct divide
         else
            NVM = LB / KUtyp
            do j = 1, N, NVM
               ir = IRX + mrec
               nm = min (NVM, N - j + 1)
               call UUwwRD (iErr, ivP, ir, nm, DV (j))
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
            call UUwwDD (iErr, ivP, ir, FMT, N, DV)
            if (iErr.eq.0) mrec = mrec + 1
CCC_    * direct divide (every KUfmt members)
         else
            NVM = LB / KUfmt
            do j = 1, N, NVM
               ir = IRX + mrec
               nm = min (NVM, N - j + 1)
               call UUwwDD (iErr, ivP, ir, FMT, nm, DV (j))
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
CCC_ & DVAptF  ## Access: put float
      subroutine DVAptF
     O    (iErr,
     O     MREC,  MLOG,
     I     FV,
     I     N,     LB,  KUfmt, FMT,  IRX, ivP)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   MREC, MLOG
      _INTENT(IN, integer)   N,    KUfmt, LB
      _INTENT(IN, integer)   IRX,  ivP
      _INTENT(IN, character) FMT*(*)
      _INTENT(IN, _REAL32) FV (N)
c
      integer    KUtyp
      parameter (KUtyp = REAL_32_BYTES)
c
      integer j, ir, nm, nvm
CCC_  * Body
      iErr = 0
      mrec = 0
      mlog = 0
c
cc write(*, *) 'PTF', KUfmt, IRX, N, LB, '/', FMT, '/'
CCC_   . sequential (LB<=0)
      if (LB.le.0) then
CCC_    * formatted
         if (FMT (1:1).eq.'(') then
            call UUwwFF (iErr, ivP, FMT, N, FV)
CCC_    * formatted asterisk
         else if (FMT .eq. '*') then
            call UUwwSF (iErr, ivP, N, FV)
CCC_    * unformatted
         else
            call UUwwUF (iErr, ivP, N, FV)
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
            call UUwwRF (iErr, ivP, ir, N, FV)
cc          write(*, *) 'DIRECT', ivP, ir, N, iErr
            if (iErr.eq.0) mrec = mrec + 1
CCC_    * direct divide
         else
            NVM = LB / KUtyp
            do j = 1, N, NVM
               ir = IRX + mrec
               nm = min (NVM, N - j + 1)
               call UUwwRF (iErr, ivP, ir, nm, FV (j))
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
            call UUwwDF (iErr, ivP, ir, FMT, N, FV)
            if (iErr.eq.0) mrec = mrec + 1
CCC_    * direct divide (every KUfmt members)
         else
            NVM = LB / KUfmt
            do j = 1, N, NVM
               ir = IRX + mrec
               nm = min (NVM, N - j + 1)
               call UUwwDF (iErr, ivP, ir, FMT, nm, FV (j))
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
#elif   __DVAINC == 3
CCC_ & DVAgtI  ## Access: get integer
      subroutine DVAgtI
     O    (iErr,
     O     MREC,  MLOG,
     O     IV,
     I     N,     LB,  KUfmt, FMT,  IRX, ivP)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   MREC, MLOG
      _INTENT(IN, integer)   N,    KUfmt, LB
      _INTENT(IN, integer)   IRX,  ivP
      _INTENT(IN, character) FMT*(*)
      _INTENT(OUT,integer) IV (N)
c
      integer    KUtyp
      parameter (KUtyp = INTEGER_0_BYTES)
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
            call UUwrFI (iErr, ivP, FMT, N, IV)
CCC_    * formatted asterisk
         else if (FMT .eq. '*') then
            call UUwrSI (iErr, ivP, N, IV)
CCC_    * unformatted
         else
            call UUwrUI (iErr, ivP, N, IV)
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
            call UUwrRI (iErr, ivP, ir, N, IV)
            if (iErr.eq.0) mrec = mrec + 1
CCC_    * direct divide
         else
            NVM = LB / KUtyp
            do j = 1, N, NVM
               ir = IRX + mrec
               nm = min (NVM, N - j + 1)
               call UUwrRI (iErr, ivP, ir, nm, IV (j))
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
            call UUwrDI (iErr, ivP, ir, FMT, N, IV)
            if (iErr.eq.0) mrec = mrec + 1
CCC_    * direct divide
         else
            NVM = LB / KUfmt
            do j = 1, N, NVM
               ir = IRX + mrec
               nm = min (NVM, N - j + 1)
               call UUwrDI (iErr, ivP, ir, FMT, nm, IV (j))
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
CCC_ & DVAgtD  ## Access: get double
      subroutine DVAgtD
     O    (iErr,
     O     MREC,  MLOG,
     O     DV,
     I     N,     LB,  KUfmt, FMT,  IRX, ivP)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   MREC, MLOG
      _INTENT(IN, integer)   N,    KUfmt, LB
      _INTENT(IN, integer)   IRX,  ivP
      _INTENT(IN, character) FMT*(*)
      _INTENT(OUT,_REAL64) DV (N)
c
      integer    KUtyp
      parameter (KUtyp = REAL_64_BYTES)
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
            call UUwrFD (iErr, ivP, FMT, N, DV)
CCC_    * formatted asterisk
         else if (FMT .eq. '*') then
            call UUwrSD (iErr, ivP, N, DV)
CCC_    * unformatted
         else
            call UUwrUD (iErr, ivP, N, DV)
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
            call UUwrRD (iErr, ivP, ir, N, DV)
            if (iErr.eq.0) mrec = mrec + 1
CCC_    * direct divide
         else
            NVM = LB / KUtyp
            do j = 1, N, NVM
               ir = IRX + mrec
               nm = min (NVM, N - j + 1)
               call UUwrRD (iErr, ivP, ir, nm, DV (j))
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
            call UUwrDD (iErr, ivP, ir, FMT, N, DV)
            if (iErr.eq.0) mrec = mrec + 1
CCC_    * direct divide
         else
            NVM = LB / KUfmt
            do j = 1, N, NVM
               ir = IRX + mrec
               nm = min (NVM, N - j + 1)
               call UUwrDD (iErr, ivP, ir, FMT, nm, DV (j))
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
CCC_ & DVAgtF  ## Access: get float
      subroutine DVAgtF
     O    (iErr,
     O     MREC,  MLOG,
     O     FV,
     I     N,     LB,  KUfmt, FMT,  IRX, ivP)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   MREC, MLOG
      _INTENT(IN, integer)   N,    KUfmt, LB
      _INTENT(IN, integer)   IRX,  ivP
      _INTENT(IN, character) FMT*(*)
      _INTENT(OUT,_REAL32) FV (N)
c
      integer    KUtyp
      parameter (KUtyp = REAL_32_BYTES)
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
            call UUwrFF (iErr, ivP, FMT, N, FV)
CCC_    * formatted asterisk
         else if (FMT .eq. '*') then
            call UUwrSF (iErr, ivP, N, FV)
CCC_    * unformatted
         else
            call UUwrUF (iErr, ivP, N, FV)
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
            call UUwrRF (iErr, ivP, ir, N, FV)
            if (iErr.eq.0) mrec = mrec + 1
CCC_    * direct divide
         else
            NVM = LB / KUtyp
            do j = 1, N, NVM
               ir = IRX + mrec
               nm = min (NVM, N - j + 1)
               call UUwrRF (iErr, ivP, ir, nm, FV (j))
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
            call UUwrDF (iErr, ivP, ir, FMT, N, FV)
            if (iErr.eq.0) mrec = mrec + 1
CCC_    * direct divide
         else
            NVM = LB / KUfmt
            do j = 1, N, NVM
               ir = IRX + mrec
               nm = min (NVM, N - j + 1)
               call UUwrDF (iErr, ivP, ir, FMT, nm, FV (j))
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
#endif
