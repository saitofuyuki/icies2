C unison/ustrmn.F --- IcIES/Unison/string manipulation
C Maintainer:  SAITO Fuyuki
C Created: Jan 6 2016 (folked from ufortw.F)
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2016/02/23 09:00:34 fuyuki ustrmn.F>'
#define _FNAME 'unison/ustrmn.F'
#define _REV   'Snoopy0.9'
CCC_! MANIFESTO
C
C Copyright (C) 2016--2020
C           Japan Agency for Marine-Earth Science and Technology,
C           Ayako ABE-OUCHI
C
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
CCC_* Macro
#include "ofdlct.h" /* fortran dialect */
#include "ologfm.h" /* logging */
CCC_* [USG] string generation
CC      l: conversion (left padding)
CC      b: append after blank unless blank
CC      a: append unless blank
CC
CC      f: format        n: no format
CCC_ & USGlfs  ## Real/standard to string (lpad/fmt) [UFxs2a]
      SUBROUTINE USGlfs
     O    (STR,
     I     SV, FMT)
      implicit none
      _INTENT(OUT,character) STR*(*)
      _INTENT(IN, _REALSTD)  SV
      _INTENT(IN, character) FMT*(*)
      character B*(32)
      integer   jp, lb, jpe, jpz
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
      if (FMT.eq.' ') then
         write (STR, '(E24.16)') SV
      else if (FMT(1:1).eq.'C') then
         if (ANINT(SV).eq.SV) then
            if (FMT.eq.'CI') then
               call USGlni (STR, INT(SV))
            else
               write (STR, '(F24.0, ''D0'')') SV
            endif
         else
            write (B, '(E24.16)') SV
            lb = len_trim(B)
            jpe = 0
            jpz = 0
            do jp = lb, 1, -1
               if (INDEX('DdEe', B(jp:jp)).gt.0) then
                  jpe = jp
                  goto 100
               endif
            enddo
 100        continue
            if (jpe.gt.0) then
               do jp = jpe - 1, 1, -1
                  if (B(jp:jp).ne.'0') then
                     jpz = jp
                     goto 110
                  endif
               enddo
            endif
 110        continue
            STR = ' '
            if (jpe.gt.0 .and. jpz.gt.0) then
               STR(1:jpz) = B(1:jpz)
               STR(jpz+1:jpz+(lb-jpe)+1) = B(jpe:lb)
            endif
         endif
      else
         write (STR, FMT) SV
      endif
#   if HAVE_F77_ADJUSTL
      STR = ADJUSTL (STR)
#   else
      call ufadjl (STR)
#   endif
      RETURN
      END
CCC_ & USGbni  ## Integer to string (append unless blank)(blank) [UFxiap]
      subroutine USGbni
     M    (STR,
     I     IV)
      implicit none
      _INTENT(INOUT,character) STR*(*)
      _INTENT(IN,   integer)   IV
      integer lstr
      character B*(32)
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
      call USGlni (B, IV)
      lstr = len_trim (STR)
      if (lstr.eq.0) then
         STR = B
      else
         write (STR, '(A, 1x, A)') _TRIM(STR), _TRIM(B)
      endif
      RETURN
      END
CCC_ & USGsni  ## Integer to string (append unless blank)(non-blank sep)
      subroutine USGsni
     M    (STR,
     I     IV, SEP)
      implicit none
      _INTENT(INOUT,character) STR*(*)
      _INTENT(IN,   integer)   IV
      _INTENT(IN,   character) SEP*(*)
      integer lstr
      character B*(32)
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
      call USGlni (B, IV)
      lstr = len_trim (STR)
      if (lstr.eq.0) then
         STR = B
      else if (SEP.eq.' ') then
         write (STR, '(A,A)')   _TRIM(STR), _TRIM(B)
      else
         write (STR, '(A,A,A)') _TRIM(STR), _TRIM(SEP), _TRIM(B)
      endif
      RETURN
      END
CCC_ & USGpni  ## Integer to string (append unless blank)(pair sep)
      subroutine USGpni
     M    (STR,
     I     IV, SEPL, SEPR)
      implicit none
      _INTENT(INOUT,character) STR*(*)
      _INTENT(IN,   integer)   IV
      _INTENT(IN,   character) SEPL*(*)
      _INTENT(IN,   character) SEPR*(*)
      integer lstr
      character B*(32)
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
      call USGlni (B, IV)
      lstr = len_trim (STR)
      if (lstr.eq.0) then
         write (STR, '(A,A,A)')
     $        _TRIM(SEPL), _TRIM(B), _TRIM(SEPR)
      else
         write (STR, '(A,A,A,A)')
     $        _TRIM(STR),
     $        _TRIM(SEPL), _TRIM(B), _TRIM(SEPR)
      endif
      RETURN
      END
CCC_ & USGani  ## Integer to string (append unless blank)(no sep)
      subroutine USGani
     M    (STR,
     I     IV)
      implicit none
      _INTENT(INOUT,character) STR*(*)
      _INTENT(IN,   integer)   IV
      character B*(32)
      call USGlni(B, IV)
      call USJntz(STR, B)
      RETURN
      END
CCC_ & USGlni  ## Integer to string, lpad [UFxi2s]
      SUBROUTINE USGlni
     O    (STR,
     I     IV)
      implicit none
      _INTENT(OUT,character) STR*(*)
      _INTENT(IN, integer)   IV
#     if HAVE_F77_FORMAT_WIDTH_ZERO
        write (STR, '(I0)') IV
#     else
        write (STR, *) IV
#       if HAVE_F77_ADJUSTL
          STR = ADJUSTL (STR)
#       else
          call ufadjl (STR)
#       endif
#     endif
      RETURN
      END
CCC_* [USP] string parser
CCC_ & USPsni  ## string to integer (simple)
      subroutine USPsni (iErr, IV, STR)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   IV
      _INTENT(IN, character) STR*(*)
      read (STR, *, IOSTAT = iErr) IV
      if (iErr.ne.0) then
         iErr = -1
         IV   = 0
      endif
      RETURN
      END
CCC_ & USPsns  ## string to real standard (simple)
      subroutine USPsns (iErr, SV, STR)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,_REALSTD)  SV
      _INTENT(IN, character) STR*(*)
      read (STR, *, IOSTAT = iErr) SV
      if (iErr.ne.0) then
         iErr = -1
         SV   = _XREALS(0.d0)
      endif
      RETURN
      END
CCC_* [USH] hexadecimal string
CCC_ & USHx2m  ## hexadecimal string to integer array [UFxx2a]
      SUBROUTINE USHx2m (IV,  NI, CV)
      implicit none
      _INTENT(OUT,integer)   IV (*), NI
      _INTENT(IN, character) CV*(*)
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
      integer   k, i
      character C1*(2)
      NI = 0
      i  = 0
      do k = 1, len_trim (CV)
         if (CV (k:k) .ne. '-' .and. CV (k:k) .ne. ' ') then
            i = i + 1
            C1 (i:i) = CV (k:k)
         endif
         if (i.eq.2) then
            i  = 0
            NI = NI + 1
            call USHx2i(IV (NI), C1)
         endif
      enddo
      if (i.eq.1) then
         i = i + 1
         C1 (i:i) = '0'
         NI = NI + 1
         call USHx2i(IV (NI), C1)
      endif
      RETURN
      END
CCC_ & USHx2i  ## hexadecimal string to integer (1 byte) [UFxx2i]
      SUBROUTINE USHx2i (IV,  CV)
      implicit none
      _INTENT(OUT,integer)   IV
      _INTENT(IN, character) CV*(*)
#if   HAVE_F77_FORMAT_Z
      character T*(2)
      T = CV
      read (T, '(Z2.2)') IV
#else /* not HAVE_F77_FORMAT_Z */
      character T*(2)
      character PU*(*), PL*(*)
      parameter (PU = '0123456789ABCDEF')
      parameter (PL = '0123456789abcdef')
      integer j, k
      T  = CV
      IV = 0
      do j = 1, 2
         k = INDEX (PU, T (j:j))
         if (k.eq.0) k = INDEX (PL, T (j:j))
         if (k.eq.0) then
            IV = -1
            goto 900
         endif
         IV = IV * 16 + (k - 1)
      enddo
 900  continue
#endif /* not HAVE_F77_FORMAT_Z */
      RETURN
      END
CCC_* [USC] string concatenation (clobber)
CCC_ & USCntc USJcs2  ## [null/trim] [cond. raw sep] plus c
      SUBROUTINE USCntc
     O    (VA,
     I     VS,
     I     VB, VC)
CCC_  - Example
CCC_  - Description
CC
CC      [S][]  [C]    [C]
CC      [S][ ] [C]    [C]
CC      [S][  ][C]    [C]
CC      [S][B] [C]    [BSC]
CC      [S][B ][C]    [BSC]
CC
CC        A: clobbered
CC        B: null if blank, or trim(B)
CC        S: S (only used when non-null B)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,character) VA*(*)
      _INTENT(IN, character) VS*(*)
      _INTENT(IN, character) VB*(*), VC*(*)
      integer la, j, lv
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
CCC_  - Body
      la = len(VA)
      j  = 1
      lv = len_trim(VB)
      VA = ' '
      call USJprm(VA, j, la, VB, lv, .FALSE.)
      if (lv.gt.0) then
         lv = len(VS)
         call USJprm(VA, j, la, VS, lv, .FALSE.)
      endif
      lv  = len_trim(VC)
      call USJprm(VA, j, la, VC, lv, .FALSE.)
      RETURN
      END
CCC_ & USCsta USJce2  ## [space/trim] plus c
      SUBROUTINE USCsta
     O    (VA,
     I     VB, VC)
CCC_  - Description
CC
CC      [ ][]  [C]    [ C]
CC      [ ][ ] [C]    [ C]
CC      [ ][  ][C]    [ C]
CC      [ ][B] [C]    [BC]
CC      [ ][B ][C]    [BC]
CC
CC        A: clobbered
CC        B: space if blank, or trim(B)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,character) VA*(*)
      _INTENT(IN, character) VB*(*), VC*(*)
      integer la, j, lv
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
CCC_  - Body
      la = len(VA)
      j  = 1
      lv = len_trim(VB)
      VA = ' '
      call USJprm(VA, j, la, VB, lv, .TRUE.)
      lv  = len_trim(VC)
      call USJprm(VA, j, la, VC, lv, .FALSE.)
      RETURN
      END
CCC_ & USCnst USJcsv  ## [null/trim][uncond. space/trim sep][table]  [UFjstr]
      SUBROUTINE USCnst
     O    (VA,
     I     VS, VI, N)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,character) VA*(*)
      _INTENT(IN, character) VS*(*)
      _INTENT(IN, integer)   N
      _INTENT(IN, character) VI(N)*(*)
      integer ji, jp, k, la, lv, ls
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
CCC_  - Body
      ls = len_trim(VS)
      if (ls.lt.1) then
         call USCnzt(VA, VI, N)
      else
         VA = ' '
         la = LEN(VA)
         ji = 1
         jp = 1
         lv = len_trim(VI(ji))
         if (lv.gt.0) then
            k  = MIN(la, jp + lv - 1)
            lv = k - jp + 1
            VA(jp:k) = VI(ji)(1:lv)
            jp = jp + lv
         endif
         do ji = 2, N
            if (jp.gt.la) goto 100
            k  = MIN(la, jp + ls - 1)
            lv = k - jp + 1
            VA(jp:k) = VS(1:lv)
            jp = jp + lv
            if (jp.gt.la) goto 100
            lv = len_trim(VI(ji))
            if (lv.gt.0) then
               k  = MIN(la, jp + lv - 1)
               lv = k - jp + 1
               VA(jp:k) = VI(ji)(1:lv)
               jp = jp + lv
            endif
         enddo
 100     continue
      endif
      RETURN
      END
CCC_ & USCnzt  ## [null/trim][uncond. space sep][table]
      subroutine USCnzt
     O    (VA,
     I     VI,  N)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,character) VA*(*)
      _INTENT(IN, integer)   N
      _INTENT(IN, character) VI(N)*(*)
      integer ji, jp, k, la, lv
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
CCC_  - Body
      VA = ' '
      la = LEN(VA)
      ji = 1
      jp = 1
      lv = len_trim(VI(ji))
      if (lv.gt.0) then
         k  = MIN(la, jp + lv - 1)
         lv = k - jp + 1
         VA(jp:k) = VI(ji)(1:lv)
         jp = jp + lv
      endif
      do ji = 2, N
         if (jp.gt.la) goto 100
         VA(jp:jp) = ' '
         jp = jp + 1
         if (jp.gt.la) goto 100
         lv = len_trim(VI(ji))
         if (lv.gt.0) then
            k  = MIN(la, jp + lv - 1)
            lv = k - jp + 1
            VA(jp:k) = VI(ji)(1:lv)
            jp = jp + lv
         endif
      enddo
 100  continue
      RETURN
      END
CCC_* [USJ] string concatenation (null if blank)
CCC_ & USJntz USJmi1  ## [null/trim]
      SUBROUTINE USJntz
     M    (VA,
     I     VB)
CCC_  - Description
CC      Substitue VB if blank VA, append otherwise
CC
CC      [ ][]      [ ]
CC      [ ][ ]     [ ]
CC      [ ][  ]    [ ]
CC      [ ][B]     [B]
CC      [ ][B ]    [B]
CC      [A][]      [A]
CC      [A][ ]     [A]
CC      [A][  ]    [A]
CC      [A][B]     [AB]
CC      [A][B ]    [AB]
CC
CC        A: null if blank, or A
CC        B: null if blank, or trim(B)
CCC_  - Declaration
      implicit none
      _INTENT(INOUT,character) VA*(*)
      _INTENT(IN,   character) VB*(*)
      integer la, j, lv
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
CCC_  - Body
      lv = len_trim(VB)
      la = len(VA)
      j  = len_trim(VA) + 1
      call USJprm(VA, j, la, VB, lv, .FALSE.)
      RETURN
      END
CCC_ & USJnta USJmi2  ## [null/trim] plus c
      SUBROUTINE USJnta
     M    (VA,
     I     VB, VC)
CCC_  - Description
CC
CC      [ ][]  [C]    [C]
CC      [ ][ ] [C]    [C]
CC      [ ][  ][C]    [C]
CC      [ ][B] [C]    [BC]
CC      [ ][B ][C]    [BC]
CC      [A][]  [C]    [AC]
CC      [A][ ] [C]    [AC]
CC      [A][  ][C]    [AC]
CC      [A][B] [C]    [ABC]
CC      [A][B ][C]    [ABC]
CC
CC        A: null if blank, or A
CC        B: null if blank, or trim(B)
CCC_  - Declaration
      implicit none
      _INTENT(INOUT,character) VA*(*)
      _INTENT(IN,   character) VB*(*), VC*(*)
      integer la, j, lv
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
CCC_  - Body
      la = len(VA)
      j  = len_trim(VA) + 1
      lv = len_trim(VB)
      call USJprm(VA, j, la, VB, lv, .FALSE.)
      lv  = len_trim(VC)
      call USJprm(VA, j, la, VC, lv, .FALSE.)
      RETURN
      END
CCC_ & USJsta USJme2  ## [space/trim] plus c [UFbcm2]
      SUBROUTINE USJsta
     M    (VA,
     I     VB, VC)
CCC_  - Description
CC
CC      [ ][]  [C]    [ C]
CC      [ ][ ] [C]    [ C]
CC      [ ][  ][C]    [ C]
CC      [ ][B] [C]    [BC]
CC      [ ][B ][C]    [BC]
CC      [A][]  [C]    [A C]
CC      [A][ ] [C]    [A C]
CC      [A][  ][C]    [A C]
CC      [A][B] [C]    [ABC]
CC      [A][B ][C]    [ABC]
CC
CC        A: null if blank, or A
CC        B: space if blank, or trim(B)
CCC_  - Declaration
      implicit none
      _INTENT(INOUT,character) VA*(*)
      _INTENT(IN,   character) VB*(*), VC*(*)
      integer la, j, lv
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
CCC_  - Body
      la = len(VA)
      j  = len_trim(VA) + 1
      lv = len_trim(VB)
      call USJprm(VA, j, la, VB, lv, .TRUE.)
      lv = len_trim(VC)
      call USJprm(VA, j, la, VC, lv, .FALSE.)
      RETURN
      END
CCC_ & USJxra USJms2  ## [xspace/raw] plus C
      SUBROUTINE USJxra
     M    (VA,
     I     VB, VC)
CCC_  - Description
CC
CC      [ ][]  [C]    [ C]
CC      [ ][ ] [C]    [ C]
CC      [ ][  ][C]    [  C]
CC      [ ][B] [C]    [BC]
CC      [ ][B ][C]    [B C]
CC      [A][]  [C]    [A C]
CC      [A][ ] [C]    [A C]
CC      [A][  ][C]    [A  C]
CC      [A][B] [C]    [ABC]
CC      [A][B ][C]    [AB C]
CC
CC        A: null if blank, or A
CC        B: space if null, or B
CCC_  - Declaration
      implicit none
      _INTENT(INOUT,character) VA*(*)
      _INTENT(IN,   character) VB*(*), VC*(*)
      integer la, j, lv
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
CCC_  - Body
      la = len(VA)
      j  = len_trim(VA) + 1
      lv = len(VB)
      call USJprm(VA, j, la, VB, lv, .TRUE.)
      lv = len_trim(VC)
      call USJprm(VA, j, la, VC, lv, .FALSE.)
      RETURN
      END
CCC_ & USJprm  ## concatenation primitive
      subroutine USJprm(VO, JP, LO, VI, LI, OSPC)
      implicit none
      _INTENT(INOUT,character) VO*(*)
      _INTENT(INOUT,integer)   JP
      _INTENT(IN,   integer)   LO
      _INTENT(IN,   character) VI*(*)
      _INTENT(IN,   integer)   LI
      _INTENT(IN,   logical)   OSPC
      integer k, lv
      if (LI.gt.0) then
         if (JP.le.LO) then
            k  = MIN(LO, JP + LI - 1)
            lv = k - JP + 1
            VO(JP:k) = VI(1:lv)
            JP = JP + lv
         endif
      else if (OSPC.and.JP.LE.LO) then
         VO(JP:JP) = ' '
         JP = JP + 1
      endif
      RETURN
      END
CCC_* [USS] string split
CCC_ & USSccv  ## split string into array [UFsplt]
      SUBROUTINE USSccv
     O    (V,  NV,
     I     LV, STR, SEPS)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)   LV
      _INTENT(OUT,character) V (LV)*(*)
      _INTENT(OUT,integer)   NV
      _INTENT(IN, character) STR*(*)
      _INTENT(IN, character) SEPS*(*)
      integer lstr, lp, lsep
      integer js
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
#if HAVE_F77_SCAN == 0
      integer scan
#endif
#if HAVE_F77_VERIFY == 0
      integer verify
#endif
CCC_  - Body
      NV   = 0
      lstr = len_trim (STR)
      lsep = MAX (1, len_trim (SEPS))
      lp   = 1
      do
c$$$         write (*, *) 'SPLITa', lp, '/', STR (lp:lstr), '/'
         if (lp.gt.lstr) goto 100
         js = SCAN (STR (lp:lstr), SEPS (1:lsep), .false.)
         if (js.eq.0) then
            js = lstr + 1
         else
            js = lp + js - 1
         endif
c$$$         write (*, *) 'SPLITb', js, '/', STR (lp:js-1), '/'
         NV = NV + 1
         if (NV.le.LV) V (NV) = STR (lp:js-1)
         lp = js
         if (lp.gt.lstr) goto 100
c$$$         write (*, *) 'SPLITc', lp, '/', STR (lp:lstr), '/'
         js = VERIFY (STR (lp:lstr), SEPS (1:lsep), .false.)
         if (js.eq.0) goto 100
         lp = lp + js - 1
      enddo
 100  continue
      RETURN
      END
CCC_* [USW] string output
CCC_ & USWitn  ## write string with trim (default format) [UFwtrd]
      SUBROUTINE USWitn
     O    (IOS,
     I     IFP,  STR)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IFP
      _INTENT(IN, character) STR*(*)
      call USWitf(IOS, IFP, '(A)', STR)
      RETURN
      END
CCC_ & USWutn  ## write string with trim (to i/o unit, default format) [UFutrd]
      SUBROUTINE USWutn
     O    (IOS,
     I     IFP, STR)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IFP
      _INTENT(IN, character) STR*(*)
      call USWutf(IOS, IFP, '(A)', STR)
      RETURN
      END
CCC_ & USWstn  ## write string with trim (to asterisk, default format) [UFstrd]
      SUBROUTINE USWstn
     O    (IOS,
     I     STR)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, character) STR*(*)
      call USWstf(IOS, '(A)', STR)
      RETURN
      END
CCC_ & USWitf  ## write string with trim [UFwtrm]
      SUBROUTINE USWitf
     O    (IOS,
     I     IFP,  FMT,  STR)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IFP
      _INTENT(IN, character) FMT*(*)
      _INTENT(IN, character) STR*(*)
      if (COND_N(IFP)) then
         call USWutf(IOS, IFP, FMT, STR)
      else if (COND_S(IFP)) then
         call USWstf(IOS, FMT, STR)
      else
         IOS = 0
      endif
      RETURN
      END
CCC_ & USWutf  ## write string with trim (i/o unit) [UFutrm]
      SUBROUTINE USWutf
     O    (IOS,
     I     IFP,  FMT,  STR)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IFP
      _INTENT(IN, character) FMT*(*)
      _INTENT(IN, character) STR*(*)
      integer lts
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
      if (HAVE_F77_TRIM.eq.0) then
         lts = len_trim (STR)
         if (lts.gt.0) then
            write (UNIT = IFP, FMT = FMT, IOSTAT = IOS) STR(1:lts)
         else
            write (UNIT = IFP, FMT = FMT, IOSTAT = IOS) ' '
         endif
      else
         write (UNIT = IFP, FMT = FMT, IOSTAT = IOS) _TRIM(STR)
      endif
      RETURN
      END
CCC_ & USWstf  ## write string with trim (to asterisk) [UFstrm]
      SUBROUTINE USWstf
     O    (IOS,
     I     FMT,  STR)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, character) FMT*(*)
      _INTENT(IN, character) STR*(*)
      integer lts
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
      if (HAVE_F77_TRIM.eq.0) then
         lts = len_trim (STR)
         if (lts.gt.0) then
            write (UNIT = *, FMT = FMT, IOSTAT = IOS) STR(1:lts)
         else
            write (UNIT = *, FMT = FMT, IOSTAT = IOS) ' '
         endif
      else
         write (UNIT = *, FMT = FMT, IOSTAT = IOS) _TRIM(STR)
      endif
      RETURN
      END
CCC_* [USM] other string manipulation
CCC_ & USMcpd  ## string copy or default when blank [UFScdb]
      SUBROUTINE USMcpd (D, S0, S1)
      implicit none
      _INTENT(OUT,character) D*(*)
      _INTENT(IN, character) S0*(*), S1*(*)
      if (S0.ne.' ') then
         D = S0
      else
         D = S1
      endif
      RETURN
      END
CCC_ & USMmlc  ## left shift string skipping characters [UFskpv]
      subroutine USMmlc
     M     (STR, CS)
      implicit none
      _INTENT(INOUT,character) STR*(*)
      _INTENT(IN,   character) CS*(*)
      integer  jp, l
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
#if HAVE_F77_VERIFY == 0
      integer verify
#endif
      l  = len_trim(STR)
      jp = verify (STR, CS, .false.)
      STR = STR(jp:l)
      RETURN
      END
CCC_* [UF] old interfaces for compatibility
CCC_ + Conditional compilation
#if WITH_UF_OLD_INTERFACES
CCC_ & UFxs2a  ## Real/Standard to string conversion
      SUBROUTINE UFxs2a (STR, SV, FMT)
      implicit none
      _INTENT(OUT,character) STR*(*)
      _INTENT(IN, _REALSTD)  SV
      _INTENT(IN, character) FMT*(*)
      call USGlfs(STR, SV, FMT)
      RETURN
      END
CCC_ & UFxiap  ## Integer to string conversion (append with blank)
      subroutine UFxiap (STR, IV)
      implicit none
      _INTENT(INOUT,character) STR*(*)
      _INTENT(IN,   integer)   IV
      call USGbni(STR, IV)
      RETURN
      END
CCC_ & UFxi2s  ## Integer to string conversion (no blanks)
      SUBROUTINE UFxi2s (STR, IV)
      implicit none
      _INTENT(OUT,character) STR*(*)
      _INTENT(IN, integer)   IV
      call USGlni(STR, IV)
      RETURN
      END
CCC_ & UFxx2a  ## hexadecimal string to integer array
      SUBROUTINE UFxx2a (IV,  NI, CV)
      implicit none
      _INTENT(OUT,integer)   IV (*), NI
      _INTENT(IN, character) CV*(*)
      call USHx2m(IV,  NI, CV)
      RETURN
      END
CCC_ & UFxx2i  ## hexadecimal string to integer (1 byte)
      SUBROUTINE UFxx2i (IV,  CV)
      implicit none
      _INTENT(OUT,integer)   IV
      _INTENT(IN, character) CV*(*)
      call USHx2i(IV,  CV)
      RETURN
      END
CCC_ & UFjstr  ## concatenation of strings
      SUBROUTINE UFjstr (STR, SEP, V,  NV)
      implicit none
      _INTENT(OUT,character) STR*(*)
      _INTENT(IN, character) SEP*(*)
      _INTENT(IN, integer)   NV
      _INTENT(IN, character) V (NV)*(*)
      call USCnst(STR, SEP, V,  NV)
      RETURN
      END
CCC_ & UFbct2  ## concatenation of strings (2 items, blank enabled, output)
      SUBROUTINE UFbct2 (STR, V0, V1)
      implicit none
      _INTENT(OUT,character) STR*(*)
      _INTENT(IN, character) V0*(*), V1*(*)
      call USCsta(STR, V0, V1)
      RETURN
      END
CCC_ & UFcat2  ## concatenation of strings (2 items, modify)
      SUBROUTINE UFcat2 (STR, V0, V1)
      implicit none
      _INTENT(INOUT,character) STR*(*)
      _INTENT(IN,   character) V0*(*), V1*(*)
      call USJnta(STR, V0, V1)
      RETURN
      END
CCC_ & UFbcm2  ## concatenation of strings (2 items, modify, blank allowed)
      SUBROUTINE UFbcm2 (STR, V0, V1)
      implicit none
      _INTENT(INOUT,character) STR*(*)
      _INTENT(IN,   character) V0*(*), V1*(*)
      call USJsta(STR, V0, V1)
      RETURN
      END
CCC_ & UFScdb  ## string copy or default when blank
      SUBROUTINE UFScdb (D, S0, S1)
      implicit none
      _INTENT(OUT,character) D*(*)
      _INTENT(IN, character) S0*(*), S1*(*)
      call USMcpd(D, S0, S1)
      RETURN
      END
CCC_ & UFskpv  ## left shift string skipping characters
      subroutine UFskpv (STR, CS)
      implicit none
      _INTENT(INOUT,character) STR*(*)
      _INTENT(IN,   character) CS*(*)
      call USMmlc(STR, CS)
      RETURN
      END
CCC_ & UFwtrd  ## write string with trim (default format)
      SUBROUTINE UFwtrd (IOS, IFP,  STR)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IFP
      _INTENT(IN, character) STR*(*)
      call USWitn(IOS, IFP,  STR)
      RETURN
      END
CCC_ & UFutrd  ## write string with trim (to i/o unit, default format)
      SUBROUTINE UFutrd (IOS, IFP, STR)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IFP
      _INTENT(IN, character) STR*(*)
      call USWutn(IOS, IFP, STR)
      RETURN
      END
CCC_ & UFstrd  ## write string with trim (to asterisk, default format)
      SUBROUTINE UFstrd (IOS, STR)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, character) STR*(*)
      call USWstn(IOS, STR)
      RETURN
      END
CCC_ & UFwtrm  ## write string with trim
      SUBROUTINE UFwtrm (IOS, IFP,  FMT,  STR)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IFP
      _INTENT(IN, character) FMT*(*)
      _INTENT(IN, character) STR*(*)
      call USWitf(IOS, IFP,  FMT,  STR)
      RETURN
      END
CCC_ & UFutrm  ## write string with trim (i/o unit)
      SUBROUTINE UFutrm (IOS, IFP,  FMT,  STR)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IFP
      _INTENT(IN, character) FMT*(*)
      _INTENT(IN, character) STR*(*)
      call USWutf(IOS, IFP,  FMT,  STR)
      RETURN
      END
CCC_ & UFstrm  ## write string with trim (to asterisk)
      SUBROUTINE UFstrm (IOS, FMT,  STR)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, character) FMT*(*)
      _INTENT(IN, character) STR*(*)
      call USWstf(IOS, FMT,  STR)
      RETURN
      END
CCC_ & UFsplt  ## split string into array
      SUBROUTINE UFsplt (V,  NV, LV, STR, SEPS)
      implicit none
      _INTENT(IN, integer)   LV
      _INTENT(OUT,character) V (LV)*(*)
      _INTENT(OUT,integer)   NV
      _INTENT(IN, character) STR*(*)
      _INTENT(IN, character) SEPS*(*)
      call USSccv(V,  NV, LV, STR, SEPS)
      RETURN
      END
CCC_ + end Conditional compilation
#endif /* WITH_UF_OLD_INTERFACES */
CCC_& USTRMN  ## Unison/String manipulation Announcement
      SUBROUTINE USTRMN (STRA, STRB, IOP)
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
CCC_* test
CCC_ + begin
#if TEST_USTRMN
CCC_ @ USTEST  ## Unison/String manipulation test
CCC_  - Test suites
CC::   SOURCES ufortw.F:_NEED_UFTEST_BANNER=1
      PROGRAM USTEST
CCC_  - Declaration
      implicit none
c
      character VI0*(32), VI1*(32)
      character VS0*(8),  VS1*(16)
c
      integer    LV, NV
      parameter (LV = 3)
      character  V (LV) * 4
c
      integer   IXV (16), NIX
c
      integer   iplog, itest
      integer   j
      _REALSTD  SI
      character STR*(32)
c
      character WA*(64)
      character WB*(8)
c
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
#include "orevan.h" /* 0 */
CCC_  - Body
c
#define _ANNOUNCE USTRMN
#define _LEXT     9999
#include "orevan.h" /* 1 */
c
      iplog = -1
      itest = 0
CCC_   . announcement
      call UFTEST_banner (itest, iplog, 'Announcement')
CCC_   . concatenation
      call UFTEST_banner (itest, iplog, 'concatenation')
      STR = ' '
      VI0 = 'VI0 '
      VI1 = 'VI1'
      call USJnta (STR, '@', VI0)
      call USJnta (STR, ': ', VI1)
      write (*, *) 'USJnta [', _TRIM(STR), ']'
      STR = ' '
      VI0 = '01234567890123456789012345678:'
      VI1 = ':12345678901234567890123456789'
      call USJnta (STR, ' ', VI0)
      call USJnta (STR, ' ', VI1)
      write (*, *) 'USJnta [', _TRIM(STR), ']'
      VS0 = '0123'
      VS1 = '4567890123456789'
      call USJntz(VS0, VS1)
      write (*, *) 'USJntz [', _TRIM(VS0), ']'
      VS0 = '    '
      VS1 = '0123456789012345'
      call USJntz(VS0, VS1)
      write (*, *) 'USJntz [', _TRIM(VS0), ']'
      VS0 = '0123'
      VS1 = '4   890123456789'
      call USJntz(VS0, VS1)
      write (*, *) 'USJntz [', _TRIM(VS0), ']'
CCC_   . concatenation batch
CCC_    * 3 items
      call USTEST_cat(WA, 'A', '',   'C', '',     iplog)
      call USTEST_cat(WA, 'A', '',   'C', 'S',    iplog)
      call USTEST_cat(WA, 'A', '',   'C', ' ',    iplog)
      call USTEST_cat(WA, 'A', '',   'C', '  ',   iplog)
      call USTEST_cat(WA, 'A', '',   'C', 'S ',   iplog)
c
      call USTEST_cat(WA, 'A', ' ',  'C', '',     iplog)
      call USTEST_cat(WA, 'A', ' ',  'C', 'S',    iplog)
      call USTEST_cat(WA, 'A', ' ',  'C', ' ',    iplog)
      call USTEST_cat(WA, 'A', ' ',  'C', '  ',   iplog)
      call USTEST_cat(WA, 'A', ' ',  'C', 'S ',   iplog)
c
      call USTEST_cat(WA, 'A', '  ', 'C', '',     iplog)
      call USTEST_cat(WA, 'A', '  ', 'C', 'S',    iplog)
      call USTEST_cat(WA, 'A', '  ', 'C', ' ',    iplog)
      call USTEST_cat(WA, 'A', '  ', 'C', '  ',   iplog)
      call USTEST_cat(WA, 'A', '  ', 'C', 'S ',   iplog)
c
      call USTEST_cat(WA, 'A', 'B',  'C', '',     iplog)
      call USTEST_cat(WA, 'A', 'B',  'C', 'S',    iplog)
      call USTEST_cat(WA, 'A', 'B',  'C', ' ',    iplog)
      call USTEST_cat(WA, 'A', 'B',  'C', '  ',   iplog)
      call USTEST_cat(WA, 'A', 'B',  'C', 'S ',   iplog)
c
      call USTEST_cat(WA, 'A', 'B ', 'C', '',     iplog)
      call USTEST_cat(WA, 'A', 'B ', 'C', 'S',    iplog)
      call USTEST_cat(WA, 'A', 'B ', 'C', ' ',    iplog)
      call USTEST_cat(WA, 'A', 'B ', 'C', '  ',   iplog)
      call USTEST_cat(WA, 'A', 'B ', 'C', 'S ',   iplog)
CCC_    * 2 items
      call USTEST_cat(WA, '',   '',   'C', '-',  iplog)
      call USTEST_cat(WA, '',   ' ',  'C', '-',  iplog)
      call USTEST_cat(WA, '',   '  ', 'C', '-',  iplog)
      call USTEST_cat(WA, '',   'B',  'C', '-',  iplog)
      call USTEST_cat(WA, '',   'B ', 'C', '-',  iplog)
c
      call USTEST_cat(WA, ' ',  '',   'C', '-',  iplog)
      call USTEST_cat(WA, ' ',  ' ',  'C', '-',  iplog)
      call USTEST_cat(WA, ' ',  '  ', 'C', '-',  iplog)
      call USTEST_cat(WA, ' ',  'B',  'C', '-',  iplog)
      call USTEST_cat(WA, ' ',  'B ', 'C', '-',  iplog)
c
      call USTEST_cat(WA, '  ', '',   'C', '-',  iplog)
      call USTEST_cat(WA, '  ', ' ',  'C', '-',  iplog)
      call USTEST_cat(WA, '  ', '  ', 'C', '-',  iplog)
      call USTEST_cat(WA, '  ', 'B',  'C', '-',  iplog)
      call USTEST_cat(WA, '  ', 'B ', 'C', '-',  iplog)
c
      call USTEST_cat(WA, 'A',  '',   'C', '-',  iplog)
      call USTEST_cat(WA, 'A',  ' ',  'C', '-',  iplog)
      call USTEST_cat(WA, 'A',  '  ', 'C', '-',  iplog)
      call USTEST_cat(WA, 'A',  'B',  'C', '-',  iplog)
      call USTEST_cat(WA, 'A',  'B ', 'C', '-',  iplog)
c
      call USTEST_cat(WA, 'A ', '',   'C', '-',  iplog)
      call USTEST_cat(WA, 'A ', ' ',  'C', '-',  iplog)
      call USTEST_cat(WA, 'A ', '  ', 'C', '-',  iplog)
      call USTEST_cat(WA, 'A ', 'B',  'C', '-',  iplog)
      call USTEST_cat(WA, 'A ', 'B ', 'C', '-',  iplog)
CCC_    * 1 item
      call USTEST_cat(WA, '',   '',   '-', '-',  iplog)
      call USTEST_cat(WA, '',   ' ',  '-', '-',  iplog)
      call USTEST_cat(WA, '',   '  ', '-', '-',  iplog)
      call USTEST_cat(WA, '',   'B',  '-', '-',  iplog)
      call USTEST_cat(WA, '',   'B ', '-', '-',  iplog)
c
      call USTEST_cat(WA, ' ',  '',   '-', '-',  iplog)
      call USTEST_cat(WA, ' ',  ' ',  '-', '-',  iplog)
      call USTEST_cat(WA, ' ',  '  ', '-', '-',  iplog)
      call USTEST_cat(WA, ' ',  'B',  '-', '-',  iplog)
      call USTEST_cat(WA, ' ',  'B ', '-', '-',  iplog)
c
      call USTEST_cat(WA, '  ', '',   '-', '-',  iplog)
      call USTEST_cat(WA, '  ', ' ',  '-', '-',  iplog)
      call USTEST_cat(WA, '  ', '  ', '-', '-',  iplog)
      call USTEST_cat(WA, '  ', 'B',  '-', '-',  iplog)
      call USTEST_cat(WA, '  ', 'B ', '-', '-',  iplog)
c
      call USTEST_cat(WA, 'A',  '',   '-', '-',  iplog)
      call USTEST_cat(WA, 'A',  ' ',  '-', '-',  iplog)
      call USTEST_cat(WA, 'A',  '  ', '-', '-',  iplog)
      call USTEST_cat(WA, 'A',  'B',  '-', '-',  iplog)
      call USTEST_cat(WA, 'A',  'B ', '-', '-',  iplog)
c
      call USTEST_cat(WA, 'A',  '',   '-', '-',  iplog)
      call USTEST_cat(WA, 'A ', ' ',  '-', '-',  iplog)
      call USTEST_cat(WA, 'A ', '  ', '-', '-',  iplog)
      call USTEST_cat(WA, 'A ', 'B',  '-', '-',  iplog)
      call USTEST_cat(WA, 'A ', 'B ', '-', '-',  iplog)
CCC_    * table
      call USTEST_cattbl(WA, iplog)
      call USTEST_cattbl(WB, iplog)
CCC_   . format (I0)
      call UFTEST_banner (itest, iplog, 'format I0')
 401  format (I12, ' :', A, ':')
      j = -100
      call USGlni (STR, j)
      write (*, 401) j, _TRIM(STR)
      j = 0
      call USGlni (STR, j)
      write (*, 401) j, _TRIM(STR)
      j = 987654321
      call USGlni (STR, j)
      write (*, 401) j, _TRIM(STR)
CCC_   . hexadecimal conversion
      call UFTEST_banner (itest, iplog, 'hexadecimal')
 421  format (I4, 1x, A2)
      VI0 = 'ff'
      call USHx2i (j, VI0)
      write (*, 421) j, VI0
      VI0 = 'fF'
      call USHx2i (j, VI0)
      write (*, 421) j, VI0
      VI0 = '80'
      call USHx2i (j, VI0)
      write (*, 421) j, VI0
      VI0 = '33'
      call USHx2i (j, VI0)
      write (*, 421) j, VI0
c
      VI0 = 'ff-a73bd6e0'
      call USHx2m (IXV, NIX, VI0)
 431  format ('<', A, '>', I3, ': ', 10I4.3)
      write (*, 431) _TRIM(VI0), NIX, (IXV (j), j=1, NIX)
CCC_   . real to string conversion
      call UFTEST_banner (itest, iplog, 'real-standard')
 501  format (E24.16, ' :', A, ':')
      SI = 1.0d4
      call USGlfs (STR, SI, ' ')
      write (*, 501) SI, _TRIM(STR)
      SI = 0.1d0
      call USGlfs (STR, SI, ' ')
      write (*, 501) SI, _TRIM(STR)
      SI = 1.0d-18
      call USGlfs (STR, SI, ' ')
      write (*, 501) SI, _TRIM(STR)
CCC_   . real to string conversion (compact)
      call UFTEST_banner (itest, iplog, 'real-standard/compact')
      SI = 1.0d4
      call USGlfs (STR, SI, 'C')
      write (*, 501) SI, _TRIM(STR)
      SI = 0.1d0
      call USGlfs (STR, SI, 'C')
      write (*, 501) SI, _TRIM(STR)
      SI = 1.0d-18
      call USGlfs (STR, SI, 'C')
      write (*, 501) SI, _TRIM(STR)
CCC_   . split string
      call UFTEST_banner (itest, iplog, 'split')
 801  format ('SPLIT ', 2I3, 1x, '<', A, '> ', '(', A, ')')
      STR = 'A B C D E'
      VI0 = ' '
      call USSccv (V,  NV, LV, STR, VI0)
      do j = 1, min (NV, LV)
         write (*, 801) j, NV, _TRIM(STR),_TRIM(V (j))
      enddo
      STR = ' A B C D E'
      VI0 = ' '
      call USSccv (V,  NV, LV, STR, VI0)
      do j = 1, min (NV, LV)
         write (*, 801) j, NV, _TRIM(STR),_TRIM(V (j))
      enddo
CCC_   . integer parser
      call UFTEST_banner (itest, iplog, 'parser')
      call USTEST_pi ('123',     iplog)
      call USTEST_pi ('123 ',    iplog)
      call USTEST_pi (' 123',    iplog)
      call USTEST_pi (' 123 ',   iplog)
      call USTEST_pi ('123.',    iplog)
      call USTEST_pi ('.123 ',   iplog)
      call USTEST_pi ('1.23',    iplog)
      call USTEST_pi ('1.2.3',   iplog)
      call USTEST_pi ('123ABC',  iplog)
      call USTEST_pi ('ABC123',  iplog)
      call USTEST_pi ('123 456', iplog)
CCC_   . end
      call UFTEST_banner (itest, iplog, 'fine')
      stop
      end
CCC_ + end
CCC_ & USTEST_cat
      subroutine USTEST_cat(W, VA, VB, VC, VS, iplog)
      implicit none
      _INTENT(OUT,character) W*(*)
      _INTENT(IN, character) VA*(*)
      _INTENT(IN, character) VB*(*), VC*(*)
      _INTENT(IN, character) VS*(*)
      _INTENT(IN, integer)   iplog
c
 101  format ('## [', A, '][', A, '][', A, '][', A, ']')
 102  format (A, ': ','[', A, ']',
     $     T20, '[', A, ']',
     $     T25, '[', A, ']',
     $     T30, '[', A, ']',
     $     T35, '[', A, ']')
 103  format (A, ': ','[', A, ']',
     $     T20, '[', A, ']',
     $     T25, '[', A, ']',
     $     T30, '[', A, ']')
 104  format (A, ': ','[', A, ']',
     $     T20, '[', A, ']',
     $     T25, '[', A, ']')
c
      if      (COND_N(iplog)) then
         write (iplog, 101) VA, VB, VC, VS
      else if (COND_S(iplog)) then
         write (*,     101) VA, VB, VC, VS
      endif
c
      if (VS.ne.'-') then
         W = VA
         call USCntc(W, VS, VB, VC)
         if      (COND_N(iplog)) then
            write (iplog, 102) 'USCNTC', _TRIM(W),
     $           VA, VB, VC, VS
         else if (COND_S(iplog)) then
            write (*,     102) 'USCNTC', _TRIM(W),
     $           VA, VB, VC, VS
         endif
      else if (VC.ne.'-') then
         W = VA
         call USCsta(W, VB, VC)
         if      (COND_N(iplog)) then
            write (iplog, 103) 'USCSTA', _TRIM(W),
     $           VA, VB, VC
         else if (COND_S(iplog)) then
            write (*,     103) 'USCSTA', _TRIM(W),
     $           VA, VB, VC
         endif
c
         W = VA
         call USJnta(W, VB, VC)
         if      (COND_N(iplog)) then
            write (iplog, 103) 'USJNTA', _TRIM(W),
     $           VA, VB, VC
         else if (COND_S(iplog)) then
            write (*,     103) 'USJNTA', _TRIM(W),
     $           VA, VB, VC
         endif
c
         W = VA
         call USJsta(W, VB, VC)
         if      (COND_N(iplog)) then
            write (iplog, 103) 'USJSTA', _TRIM(W),
     $           VA, VB, VC
         else if (COND_S(iplog)) then
            write (*,     103) 'USJSTA', _TRIM(W),
     $           VA, VB, VC
         endif
c
         W = VA
         call USJxra(W, VB, VC)
         if      (COND_N(iplog)) then
            write (iplog, 103) 'USJXRA', _TRIM(W),
     $           VA, VB, VC
         else if (COND_S(iplog)) then
            write (*,     103) 'USJXRA', _TRIM(W),
     $           VA, VB, VC
         endif
      else if (VB.ne.'-') then
         W = VA
         call USJntz(W, VB)
         if      (COND_N(iplog)) then
            write (iplog, 104) 'USJNTZ', _TRIM(W),
     $           VA, VB
         else if (COND_S(iplog)) then
            write (*,     104) 'USJNTZ', _TRIM(W),
     $           VA, VB
         endif
      endif
c
      RETURN
      END
CCC_ & USTEST_cattbl
      subroutine USTEST_cattbl(W, iplog)
      implicit none
      _INTENT(OUT,character) W*(*)
      _INTENT(IN, integer)   iplog
      integer   NS
      character CS(32)*(8)
      character SEP*(4)
c
      CS(1) = ' A '
      CS(2) = 'B '
      CS(3) = ' C'
      CS(4) = ' D'
      CS(5) = ' '
      CS(6) = '  '
      CS(7) = 'G'
      NS    = 7
c
 101  format (A, 1x, '[', A, '] >>', '/', A, '/')
      SEP = ' '
      call USCnst(W, SEP, CS, NS)
      if      (COND_N(iplog)) then
         write (iplog, 101) 'USCNST', SEP, _TRIM(W)
      else if (COND_S(iplog)) then
         write (*,     101) 'USCNST', SEP, _TRIM(W)
      endif
c
      SEP = '  '
      call USCnst(W, SEP, CS, NS)
      if      (COND_N(iplog)) then
         write (iplog, 101) 'USCNST', SEP, _TRIM(W)
      else if (COND_S(iplog)) then
         write (*,     101) 'USCNST', SEP, _TRIM(W)
      endif
c
      SEP = ' : '
      call USCnst(W, SEP, CS, NS)
      if      (COND_N(iplog)) then
         write (iplog, 101) 'USCNST', SEP, _TRIM(W)
      else if (COND_S(iplog)) then
         write (*,     101) 'USCNST', SEP, _TRIM(W)
      endif
c
      SEP = ': '
      call USCnst(W, SEP, CS, NS)
      if      (COND_N(iplog)) then
         write (iplog, 101) 'USCNST', SEP, _TRIM(W)
      else if (COND_S(iplog)) then
         write (*,     101) 'USCNST', SEP, _TRIM(W)
      endif
c
      SEP = ' :'
      call USCnst(W, SEP, CS, NS)
      if      (COND_N(iplog)) then
         write (iplog, 101) 'USCNST', SEP, _TRIM(W)
      else if (COND_S(iplog)) then
         write (*,     101) 'USCNST', SEP, _TRIM(W)
      endif
c
      SEP = ':'
      call USCnst(W, SEP, CS, NS)
      if      (COND_N(iplog)) then
         write (iplog, 101) 'USCNST', SEP, _TRIM(W)
      else if (COND_S(iplog)) then
         write (*,     101) 'USCNST', SEP, _TRIM(W)
      endif
c
      RETURN
      END
CCC_ & USTEST_pi
      subroutine USTEST_pi(STR, iplog)
      implicit none
      _INTENT(IN,character) STR*(*)
      _INTENT(IN,integer)   iplog
      integer iv, jei, jes
      _REALSTD sv
      call USPsni(jei, iv, str)
      call USPsns(jes, sv, str)
 101  format ('PI /', A, '/ ', I4, 1x, I3, '//', F9.3, 1x, I3)
      if (COND_N(iplog)) then
         write (iplog, 101) str, iv, jei, sv, jes
      else if (COND_S(iplog)) then
         write (*,     101) str, iv, jei, sv, jes
      endif
      RETURN
      END
#endif /* TEST_USTRMN */
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
