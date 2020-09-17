C unison/ufortw.F --- IcIES/Unison/Fortran function wrappers and others
C Maintainer:  SAITO Fuyuki
C Created: Aug 26 2010
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2020/09/17 08:49:49 fuyuki ufortw.F>'
#define _FNAME 'unison/ufortw.F'
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
CCC_* Macro
#include "ofdlct.h" /* fortran dialect */
#include "ologfm.h" /* logging */
CCC_ + Test condition
#ifndef   TEST_UFORTW
#  define TEST_UFORTW 0
#endif
#ifndef   WITH_TEST_UFORTW
#  define WITH_TEST_UFORTW 0
#endif
CCC_  - choice
#if   TEST_UFORTW == 0
#  define TEST_UFORTW_LEVEL -1
#elif TEST_UFORTW == 1
#  define TEST_UFORTW_LEVEL 0
#  define TEST_UFORTW_MESSAGE  'FULL EMULATION'
#  define TEST_UFORTW_FP 0
#elif TEST_UFORTW == 2
#  define TEST_UFORTW_LEVEL 1
#  define TEST_UFORTW_MESSAGE  'FULL INTRINSIC'
#  define TEST_UFORTW_FP 1
#elif TEST_UFORTW == 3
#  define TEST_UFORTW_LEVEL -1
#  define TEST_UFORTW_MESSAGE  'DEFAULT'
#  define TEST_UFORTW_FP 1
#else
#  error "INVALID TEST KIND"
#endif
CCC_  - force overwrite macros when required
#if TEST_UFORTW_LEVEL >= 0

#  undef  HAVE_F77_ADJUSTL
#  undef  HAVE_F77_ARRAY_OPERATION
#  undef  HAVE_F77_DIGITS
#  undef  HAVE_F77_FLOOR
#  undef  HAVE_F77_FLUSH
#  undef  HAVE_F77_FORMAT_WIDTH_ZERO
#  undef  HAVE_F77_FORMAT_Z
#  undef  HAVE_F77_INQUIRE_CONVERT
#  undef  HAVE_F77_LEN_TRIM
#  undef  HAVE_F77_MAXEXPONENT
#  undef  HAVE_F77_MINEXPONENT
#  undef  HAVE_F77_PRECISION
#  undef  HAVE_F77_RADIX
#  undef  HAVE_F77_REPEAT
#  undef  HAVE_F77_SCAN
#  undef  HAVE_F77_VERIFY
#  undef  HAVE_F77_CPU_TIME
#  undef  HAVE_F77_ICHAR

#  define HAVE_F77_ADJUSTL             TEST_UFORTW_LEVEL
#  define HAVE_F77_ARRAY_OPERATION     TEST_UFORTW_LEVEL
#  define HAVE_F77_DIGITS              TEST_UFORTW_LEVEL
#  define HAVE_F77_FLOOR               TEST_UFORTW_LEVEL
#  define HAVE_F77_FLUSH               TEST_UFORTW_LEVEL
#  define HAVE_F77_FORMAT_WIDTH_ZERO   TEST_UFORTW_LEVEL
#  define HAVE_F77_FORMAT_Z            TEST_UFORTW_LEVEL
#  define HAVE_F77_INQUIRE_CONVERT     TEST_UFORTW_LEVEL
#  define HAVE_F77_LEN_TRIM            TEST_UFORTW_LEVEL
#  define HAVE_F77_MAXEXPONENT         TEST_UFORTW_LEVEL
#  define HAVE_F77_MINEXPONENT         TEST_UFORTW_LEVEL
#  define HAVE_F77_PRECISION           TEST_UFORTW_LEVEL
#  define HAVE_F77_RADIX               TEST_UFORTW_LEVEL
#  define HAVE_F77_REPEAT              TEST_UFORTW_LEVEL
#  define HAVE_F77_SCAN                TEST_UFORTW_LEVEL
#  define HAVE_F77_VERIFY              TEST_UFORTW_LEVEL
#  define HAVE_F77_CPU_TIME            TEST_UFORTW_LEVEL
#  define HAVE_F77_ICHAR               TEST_UFORTW_LEVEL

#endif /* TEST_UFORTW_LEVEL >= 0 */
CCC_* Array manipulation
CCC_ & UFasci  ## set constant (integer)
      SUBROUTINE ufasci (IV, N,  IC)
      implicit none
      _INTENT(IN, integer) N
      _INTENT(OUT,integer) IV (N)
      _INTENT(IN, integer) IC
#if HAVE_F77_ARRAY_OPERATION
      IV = IC
#else
      integer j
      do j = 1, N
         IV (j) = IC
      enddo
#endif
      RETURN
      END
CCC_ & UFarci  ## set constant (integer) with range
      SUBROUTINE ufarci (IV, KS, KE, KD,  IC)
      implicit none
      _INTENT(IN, integer) KS, KE, KD
      _INTENT(OUT,integer) IV (*)
      _INTENT(IN, integer) IC
#if HAVE_F77_ARRAY_OPERATION
      IV (KS:KE:KD) = IC
#else
      integer j
      do j = KS, KE, KD
         IV (j) = IC
      enddo
#endif
      RETURN
      END
CCC_ & UFascs  ## set constant (real/standard)
      SUBROUTINE ufascs (SV, N,  SC)
      implicit none
      _INTENT(IN, integer)  N
      _INTENT(OUT,_REALSTD) SV (N)
      _INTENT(IN, _REALSTD) SC
#if HAVE_F77_ARRAY_OPERATION
      SV = SC
#else
      integer j
      do j = 1, N
         SV (j) = SC
      enddo
#endif
      RETURN
      END
CCC_ & UFarcs  ## set constant (real/standard) with range
      SUBROUTINE ufarcs (SV, KS, KE, KD,  SC)
      implicit none
      _INTENT(IN, integer)  KS, KE, KD
      _INTENT(OUT,_REALSTD) SV (*)
      _INTENT(IN, _REALSTD) SC
#if HAVE_F77_ARRAY_OPERATION
      SV (KS:KE:KD) = SC
#else
      integer j
      do j = KS, KE, KD
         SV (j) = SC
      enddo
#endif
      RETURN
      END
CCC_ & UFacpi  ## copy (integer)
      SUBROUTINE ufacpi (IV, N,  JV)
      implicit none
      _INTENT(IN, integer) N
      _INTENT(OUT,integer) IV (N)
      _INTENT(IN, integer) JV (N)
#if HAVE_F77_ARRAY_OPERATION
      IV = JV
#else
      integer j
      do j = 1, N
         IV (j) = JV (j)
      enddo
#endif
      RETURN
      END
CCC_ & UFacps  ## copy (real/standard)
      SUBROUTINE ufacps (SV, N,  TV)
      implicit none
      _INTENT(IN, integer)  N
      _INTENT(OUT,_REALSTD) SV (N)
      _INTENT(IN, _REALSTD) TV (N)
#if HAVE_F77_ARRAY_OPERATION
      SV = TV
#else
      integer j
      do j = 1, N
         SV (j) = TV (j)
      enddo
#endif
      RETURN
      END
CCC_* System-dependent procedures
CCC_ & UFxbod  ## report byte-order
      SUBROUTINE UFxbod (BODR, IFP)
      implicit none
      _INTENT(OUT,character) BODR*(*)
      _INTENT(IN, integer)   IFP
#if  HAVE_F77_INQUIRE_CONVERT
      integer IOS
      character STR*(32)
      INQUIRE (CONVERT = STR, UNIT = IFP, IOSTAT = IOS)
      if (IOS.eq.0) then
         BODR = STR (1:1)
      else
         BODR = '!'
      endif
#else /* not HAVE_F77_INQUIRE_CONVERT */
      BODR = '-'
CC    dummy condition
      if (IFP.eq.0) return
#endif /* not HAVE_F77_INQUIRE_CONVERT */
      RETURN
      END
CCC_ & UFxfpi  ## report floating-point attributes
      SUBROUTINE UFxfpi
     O    (iErr,
     I     IFP)
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(IN, integer) IFP
      integer jrS, jrR, jrF, jrD
      iErr = 0
CCC_  - radix
#     if HAVE_F77_RADIX
      jrS = RADIX (_XREALS (1.0d0))
      jrR = RADIX (1.0)
      jrF = RADIX (1.0e0)
      jrD = RADIX (1.0d0)
#     else /* not HAVE_F77_RADIX */
      jrS = 0
      jrR = 0
      jrF = 0
      jrD = 0
#     endif
      call ufxfps (IFP, jrS, jrR, jrF, jrD, 'RADIX')
CCC_  - precision
#     if HAVE_F77_PRECISION
      jrS = PRECISION (_XREALS (1.0d0))
      jrR = PRECISION (1.0)
      jrF = PRECISION (1.0e0)
      jrD = PRECISION (1.0d0)
#     else /* not HAVE_F77_PRECISION */
      jrS = 0
      jrR = 0
      jrF = 0
      jrD = 0
#     endif
      call ufxfps (IFP, jrS, jrR, jrF, jrD, 'PRECISION')
CCC_  - digits
#     if HAVE_F77_DIGITS
      jrS = DIGITS (_XREALS (1.0d0))
      jrR = DIGITS (1.0)
      jrF = DIGITS (1.0e0)
      jrD = DIGITS (1.0d0)
#     else /* not HAVE_F77_DIGITS */
      jrS = 0
      jrR = 0
      jrF = 0
      jrD = 0
#     endif
      call ufxfps (IFP, jrS, jrR, jrF, jrD, 'DIGITS')
CCC_  - minexponent
#     if HAVE_F77_MINEXPONENT
      jrS = MINEXPONENT (_XREALS (1.0d0))
      jrR = MINEXPONENT (1.0)
      jrF = MINEXPONENT (1.0e0)
      jrD = MINEXPONENT (1.0d0)
#     else /* not HAVE_F77_MINEXPONENT */
      jrS = 0
      jrR = 0
      jrF = 0
      jrD = 0
#     endif
      call ufxfps (IFP, jrS, jrR, jrF, jrD, 'MINEXPONENT')
CCC_  - maxexponent
#     if HAVE_F77_MAXEXPONENT
      jrS = MAXEXPONENT (_XREALS (1.0d0))
      jrR = MAXEXPONENT (1.0)
      jrF = MAXEXPONENT (1.0e0)
      jrD = MAXEXPONENT (1.0d0)
#     else /* not HAVE_F77_MAXEXPONENT */
      jrS = 0
      jrR = 0
      jrF = 0
      jrD = 0
#     endif
      call ufxfps (IFP, jrS, jrR, jrF, jrD, 'MAXEXPONENT')
      RETURN
      END
CCC_ & UFxfps  ## ufxfpi sub
      SUBROUTINE UFxfps
     I     (IFP, jS, jR, jF, jD, STR)
      implicit none
      _INTENT(IN,integer)   IFP
      _INTENT(IN,integer)   jS, jR, jF, jD
      _INTENT(IN,character) STR*(*)
 101  format (A, T13, ' SRFD: ', 4I6)
      if (COND_N(IFP)) then
         write (IFP, 101) STR, jS, jR, jF, jD
      else if (COND_S(IFP)) then
         write (*,   101) STR, jS, jR, jF, jD
      endif
      RETURN
      END
CCC_ & UFxfpe  ## get machine epsilon
      SUBROUTINE UFxfpe (E, KSW, IFP)
      implicit none
      _INTENT(OUT,_REALSTD) E
      _INTENT(IN,integer)   IFP
      _INTENT(IN,integer)   KSW
      _REALSTD P, Q
      P = 1.0d0
      if (KSW.eq.0) then
#     if HAVE_F77_EPSILON
         E = EPSILON(P)
         return
#     else /* not HAVE_F77_EPSILON */
 109     format('UFXFPE: EPSILON() DISABLED.')
         if (COND_N(IFP)) then
            write(IFP, 109)
         else if (COND_S(IFP)) then
            write(*,   109)
         endif
#     endif /* not HAVE_F77_EPSILON */
      endif
      P = 1.0d0
      E = 1.0d0
 101  format('UFXFPE:CHK ', 3E26.18)
      do
         Q = P + E
         if (COND_N(IFP)) then
            write(IFP, 101) E, P, Q
         else if (COND_S(IFP)) then
            write(*,   101) E, P, Q
         endif
         if (P.eq.Q) goto 100
         E = E / 2.0d0
      enddo
 100  continue
      if (COND_N(IFP)) then
         write(IFP, 102) E
      else if (COND_S(IFP)) then
         write(*,   102) E
      endif
 102  format('UFXFPE:EPS = ', E26.18)
      RETURN
      END
CCC_* Other utilities
CCC_* GNU extension
CCC_ & flush ()  -- dummy (i/o unit mandatory)
#if    HAVE_F77_FLUSH == 0
      SUBROUTINE flush (IFP)
      implicit none
      integer  IFP
CC    dummy condition
      if (IFP.eq.0) return
      RETURN
      END
#endif /* HAVE_F77_FLUSH == 0 */
CCC_* Fortran 90
CCC_ & UFadjl  ## wrapper for adjustl ()
#if HAVE_F77_ADJUSTL == 0
      SUBROUTINE ufadjl (STRING)
      implicit none
      _INTENT(INOUT,character) STRING*(*)
      integer   l, j, l0
      l = LEN (STRING)
      l0 = 0
      do j = 1, l
         if (STRING (j:j).ne.' ') then
            l0 = j
            goto 100
         endif
      enddo
 100  continue
      if (l0.gt.0) then
         do j = 0, l - l0
            STRING (1 + j:1 + j) = STRING (l0 + j:l0 + j)
         enddo
         do j = l - l0 + 2, l
            STRING (j:j) = ' '
         enddo
      endif
      RETURN
      END
#endif
CCC_* Fortran 95
CCC_ & UFcput  ## cpu_time
      SUBROUTINE ufcput (TIME)
      _INTENT(OUT,_REALSTD) TIME
#if HAVE_F77_CPU_TIME
      real RT
      CALL CPU_TIME (RT)
      TIME = _XREALS(RT)
#else
      TIME = 0.0d0
#endif
      RETURN
      END
CCC_ & len_trim ()
#if HAVE_F77_LEN_TRIM == 0
      integer FUNCTION len_trim (STRING)
CCC_  - Declaration
      implicit none
      _INTENT(IN,character) STRING*(*)
      integer   j, l
CCC_  - Body
      l = LEN (STRING)
      len_trim = 0
      do j = l, 1, -1
         if (STRING (j:j).ne.' ') then
            len_trim = j
            goto 100
         endif
      enddo
 100  continue
      RETURN
      END
#endif /* HAVE_F77_LEN_TRIM */
CCC_ & trim
CCC_ & verify
#if HAVE_F77_VERIFY == 0
      integer FUNCTION verify (STRING, SET, BACK)
CCC_  - Declaration
      implicit none
      _INTENT(IN,character) STRING*(*), SET*(*)
      _INTENT(IN,logical)   BACK
      integer   lstr
      integer   j
CCC_  - Body
      lstr = LEN (STRING)
      verify = 0
      if (BACK) then
         do j = lstr, 1, -1
            if (INDEX (SET, STRING (j:j)).eq.0) then
               verify = j
               goto 100
            endif
         enddo
      else
         do j = 1, lstr
            if (INDEX (SET, STRING (j:j)).eq.0) then
               verify = j
               goto 100
            endif
         enddo
      endif
 100  continue
      RETURN
      END
#endif /* HAVE_F77_VERIFY */
CCC_ & scan
#if HAVE_F77_SCAN == 0
      integer FUNCTION scan (STRING, SET, BACK)
CCC_  - Declaration
      implicit none
      _INTENT(IN,character) STRING*(*), SET*(*)
      _INTENT(IN,logical)   BACK
      integer   lstr
      integer   j
CCC_  - Body
      lstr = LEN (STRING)
      scan = 0
      if (BACK) then
         do j = lstr, 1, -1
            if (INDEX (SET, STRING (j:j)).gt.0) then
               scan = j
               goto 100
            endif
         enddo
      else
         do j = 1, lstr
            if (INDEX (SET, STRING (j:j)).gt.0) then
               scan = j
               goto 100
            endif
         enddo
      endif
 100  continue
      RETURN
      END
#endif /* HAVE_F77_SCAN */
CCC_ & UFfrpt  ## wrapper for repeat()
      SUBROUTINE uffrpt (D, S, N)
      implicit none
      _INTENT(OUT,character) D*(*)
      _INTENT(IN, character) S*(*)
      _INTENT(IN, integer)   N
#if HAVE_F77_REPEAT == 1
      D = REPEAT (S, N)
#else /* not HAVE_F77_REPEAT */
      integer ld, ls
      integer i
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
      ld = LEN (D)
      ls = MAX (1, len_trim (S))
      D  = ' '
      do i = 1, MIN (N, (ld / ls)) * ls, ls
         D (i:i+ls-1) = S (1:ls)
      enddo
#endif /* not HAVE_F77_REPEAT */
      RETURN
      END
CCC_ + ichar family
CCC_  - macros for ichar/char
#    define _ICHAR_SEQUENCE_2 ' !"#$%&''()*+,-./'
#    define _ICHAR_SEQUENCE_3 '0123456789:;<=>?'
#    define _ICHAR_SEQUENCE_4 '@ABCDEFGHIJKLMNO'
#    define _ICHAR_SEQUENCE_5 'PQRSTUVWXYZ[\]^_'
#    define _ICHAR_SEQUENCE_6 '`abcdefghijklmno'
#    define _ICHAR_SEQUENCE_7 'pqrstuvwxyz{|}~ '
CCC_  & UFfc2i()  ## wrapper for ichar()
      integer function UFfc2i(C)
      _INTENT(IN, character) C
#   if   HAVE_F77_ICHAR
      UFfc2i = ICHAR(C)
#   else   /* not HAVE_F77_ICHAR */
      UFfc2i = 31 + INDEX(_ICHAR_SEQUENCE_2, C)
      if (UFfc2i.eq.31) then
         UFfc2i = 47 + INDEX(_ICHAR_SEQUENCE_3, C)
         if (UFfc2i.eq.47) then
            UFfc2i = 63 + INDEX(_ICHAR_SEQUENCE_4, C)
            if (UFfc2i.eq.63) then
               UFfc2i = 79 + INDEX(_ICHAR_SEQUENCE_5, C)
               if (UFfc2i.eq.79) then
                  UFfc2i = 95 + INDEX(_ICHAR_SEQUENCE_6, C)
                  if (UFfc2i.eq.95) then
                     UFfc2i = 111+ INDEX(_ICHAR_SEQUENCE_7, C)
                  endif
               endif
            endif
         endif
      endif
#   endif
      RETURN
      END
CCC_  & UFfi2c()  ## wrapper for char()
      character function UFfi2c(IC)
CCC_   . Description
CC     CHAR() intrinsic is actually a standard since Fortran-77.
CC     This counerpart function is prepared for consistincy with UFfc2i().
CCC_   . Body
      _INTENT(IN, integer) IC
      character PC*(16)
      if      (IC.gt.127) then
         UFfi2c = CHAR(IC)
      else if (IC.gt.111) then
         PC =_ICHAR_SEQUENCE_7
         UFfi2c  = PC(IC-111:IC-111)
      else if (IC.gt.95) then
         PC =_ICHAR_SEQUENCE_6
         UFfi2c  = PC(IC-95:IC-95)
      else if (IC.gt.79) then
         PC =_ICHAR_SEQUENCE_5
         UFfi2c  = PC(IC-79:IC-79)
      else if (IC.gt.63) then
         PC =_ICHAR_SEQUENCE_4
         UFfi2c  = PC(IC-63:IC-63)
      else if (IC.gt.47) then
         PC =_ICHAR_SEQUENCE_3
         UFfi2c  = PC(IC-47:IC-47)
      else if (IC.gt.31) then
         PC =_ICHAR_SEQUENCE_2
         UFfi2c  = PC(IC-31:IC-31)
      else
         UFfi2c = CHAR(IC)
      endif
      RETURN
      END
CCC_  & UFwc2i  ## wrapper for ichar()
      subroutine UFwc2i(IC, C)
      implicit none
      _INTENT(OUT,integer)   IC
      _INTENT(IN, character) C
      integer UFfc2i
      IC = UFfc2i(C)
      RETURN
      END
CCC_  & UFwi2c  ## wrapper for char()
      subroutine UFwi2c(C, IC)
      implicit none
      _INTENT(OUT,character) C
      _INTENT(IN, integer)   IC
      character UFfi2c
      C = UFfi2c(IC)
      RETURN
      END
CCC_ + floor family
#if HAVE_F77_FLOOR == 0
CCC_  & floord [double]
      integer FUNCTION floord (A)
      implicit none
      _INTENT(IN,_REALD)  A
      _REALD  T
      T = AINT (A)
      if (T.gt.A) then
         FLOORD = INT(T) - 1
      else
         FLOORD = INT(T)
      endif
      RETURN
      END
CCC_  & floors [std]
      integer FUNCTION floors (A)
      implicit none
      _INTENT(IN,_REALSTD)  A
      _REALSTD  T
      T = AINT (A)
      if (T.gt.A) then
         FLOORS = INT(T) - 1
      else
         FLOORS = INT(T)
      endif
      RETURN
      END
#endif /* HAVE_F77_FLOOR */
CCC_  & dfloor (implementation in double)
      _REALD FUNCTION dfloor (A)
      implicit none
      _INTENT(IN,_REALD)  A
      DFLOOR = AINT (A)
      if (DFLOOR.gt.A) DFLOOR = DFLOOR - 1.0d0
      RETURN
      END
CCC_  & sfloor (implementation in standard-real)
      _REALSTD FUNCTION sfloor (A)
      implicit none
      _INTENT(IN,_REALSTD)  A
      SFLOOR = AINT (A)
      if (SFLOOR.gt.A) SFLOOR = SFLOOR - _XREALS(1.0d0)
      RETURN
      END
CCC_ + bitwise logical
CCC_  & UFBand() - bitwise logical and
      integer function UFBand(K0, K1)
      implicit none
      _INTENT(IN,integer) K0, K1
      integer  N0, N1
      integer  m
      UFBand = 0
      N0 = K0
      N1 = K1
      m  = 1
      DO
         if (N0.eq.0.and.N1.eq.0) goto 100
         UFBand = UFBand + m * (MOD(N0,2) * MOD(N1,2))
         m = m * 2
         N0 = N0 / 2
         N1 = N1 / 2
      ENDDO
 100  continue
      return
      end
CCC_ & modulo
      integer FUNCTION imodul (K, L)
      implicit none
      _INTENT(IN,integer) K, L
#if       HAVE_F77_MODULO
      imodul = MODULO(K,L)
#else /* not HAVE_F77_MODULO */
      imodul = MOD(K, L)
      if (L.gt.0) then
         if (imodul.lt.0) imodul = imodul + L
      else if (L.lt.0) then
         if (imodul.gt.0) imodul = imodul + L
      endif
#endif
      RETURN
      END
CCC_* Health check
CCC_ & UFHmds ## MOD behaviour
      subroutine UFHmds(iErr, IFP, X, Y, Z)
      implicit none
      _INTENT(OUT,integer)  iErr
      _INTENT(IN, integer)  IFP
      _INTENT(IN, _REALSTD) X, Y, Z
      _REALSTD A
      iErr = 0
 101  format('HEALTH CHECK MOD:', 3F8.2, 1x, ' :: ', F8.2)
      A = MOD(X,Y)
      if (COND_N(IFP)) then
         write(IFP, 101) X, Y, Z, A
      else if (COND_S(IFP)) then
         write(*,   101) X, Y, Z, A
      endif
      if (A.ne.Z) iErr = -1
      RETURN
      END
CCC_ & UFHmdi ## MOD behaviour
      subroutine UFHmdi(iErr, IFP, K, L, M)
      implicit none
      _INTENT(OUT,integer)  iErr
      _INTENT(IN, integer)  IFP
      _INTENT(IN, integer)  K, L, M
      integer N
      iErr = 0
CC    MOD(A) = A - (INT(A/P) * P)
CC    INT(A) = SIGN(A) * (FLOOR(A))
 101  format('HEALTH CHECK MOD:', L1, 3(1x, I0), ' :: ', I0)
      N = MOD(K,L)
      if (COND_N(IFP)) then
         write(IFP, 101) M.eq.N, K, L, M, N
      else if (COND_S(IFP)) then
         write(*,   101) M.eq.N, K, L, M, N
      endif
      if (N.ne.M) iErr = -1
      RETURN
      END
CCC_ & UFHmli ## MODULO behaviour
      subroutine UFHmli(iErr, IFP, K, L, M)
      implicit none
      _INTENT(OUT,integer)  iErr
      _INTENT(IN, integer)  IFP
      _INTENT(IN, integer)  K, L, M
      integer N
      integer imodul
      iErr = 0
CC    Q = MODULO(A,P), A=Q*P+R, 0<=Q<P or P<Q<=0
 101  format('HEALTH CHECK MODULO:', L1, 3(1x, I0), ' :: ', I0)
      N = IMODUL(K,L)
      if (COND_N(IFP)) then
         write(IFP, 101) M.eq.N, K, L, M, N
      else if (COND_S(IFP)) then
         write(*,   101) M.eq.N, K, L, M, N
      endif
      if (N.ne.M) iErr = -1
      RETURN
      END
CCC_& UFORTW  ## Unison/Fortran function wrappers Announcement
      SUBROUTINE UFORTW (STRA, STRB, IOP)
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
      else if (IOP.eq.3) then
         STRA = 'HAVE_F77_ADJUSTL'
         write (STRB, *) HAVE_F77_ADJUSTL
      else if (IOP.eq.4) then
         STRA = 'HAVE_F77_LEN_TRIM'
         write (STRB, *) HAVE_F77_LEN_TRIM
      else if (IOP.eq.5) then
         STRA = 'HAVE_F77_VERIFY'
         write (STRB, *) HAVE_F77_VERIFY
      else if (IOP.eq.6) then
         STRA = 'HAVE_F77_SCAN'
         write (STRB, *) HAVE_F77_SCAN
      else if (IOP.eq.7) then
         STRA = 'HAVE_F77_FLOOR'
         write (STRB, *) HAVE_F77_FLOOR
      else
         STRA = ' '
         STRB = ' '
      endif
      RETURN
      END
CCC_* test
CCC_ + test subroutines
#if TEST_UFORTW || WITH_TEST_UFORTW
CCC_  - UFTEST_ichar  ## batch test for ichar()/char()
      subroutine UFTEST_ichar (iErr, KLEV, IFP)
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(IN, integer) KLEV
      _INTENT(IN, integer) IFP
      integer   j,  IC
      character CI, CC
      logical   OC, OI
      iErr = 0
      do j = 32, 126
         CI = CHAR(j)
         call UFwi2c(CC, j)
         call UFwc2i(IC, CI)
         OI = (IC.eq.j)
         OC = (CC.eq.CI)
         if (.not.OC) iErr = iErr - 1
         if (.not.OI) iErr = iErr - 1
 501     format (L1, L1, I3.3, 1x, '[', A1, A1, '] ', I3.3)
         if (KLEV.GT.0.or.(.not.OC).or.(.not.OI)) then
            if (COND_N(IFP)) then
               write (IFP, 501) OI, OC, j, CI, CC, IC
            else if (COND_S(IFP)) then
               write (*,   501) OI, OC, j, CI, CC, IC
            endif
         endif
      enddo
      RETURN
      END
#endif  /* TEST_UFORTW || WITH_TEST_UFORTW */
CCC_ + begin
#if TEST_UFORTW
#  define  _NEED_UFTEST_BANNER 1
CCC_ @ UFTEST  ## Unison/Fortran wrapper test
CCC_  - Test suites
CC::   KINDS 1 2 3
      PROGRAM UFTEST
CCC_  - Declaration
      implicit none
      character STR*(32)
      _REALD    d
      integer   j
c
      character STRL0*(*), STRL1*(*), STRL2*(*)
      parameter (STRL0 = 'ABC   XYZ   ')
      parameter (STRL1 = '   ABC   XYZ')
      parameter (STRL2 =  '0123456789012345678901234567890123456789')
c
      character  STRV*(*)
      parameter (STRV = 'FORTRAN')
      integer    jerr
      character  bodr*(16)
c
      integer   iplog, itest
c
#if TEST_UFORTW == 1
      integer  len_trim
      integer  verify
      integer  scan
      integer  floord
      external len_trim
      external verify
      external scan
      external floor
#  define FLOORD floord
#else
#  define FLOORD floor
#endif
c
      _REALD dfloor
#include "orevan.F" /* 0 */
CCC_  - Body
      iplog = -1
      itest = 0
CCC_   . announcement
      call UFTEST_banner (itest, iplog, 'Announcement')
#define _ANNOUNCE UFORTW
#define _LEXT     9999
#include "orevan.F" /* 1 */
CCC_   . variation
      call UFTEST_banner (itest, iplog, TEST_UFORTW_MESSAGE)
      write (*, *) 'TEST_UFORTW', TEST_UFORTW
CCC_   . len_trim
      call UFTEST_banner (itest, iplog, 'len_trim')
 301  format ('LEN_TRIM: <', A, '>', I3)
      write (*, 301) STRL0, len_trim (STRL0)
      write (*, 301) STRL1, len_trim (STRL1)
      write (*, 301) STRL2, len_trim (STRL2)
CCC_   . verify
      call UFTEST_banner (itest, iplog, 'verify')
 201  format ('VERIFY: <', A, '/', A, '>', I3)
      write (*, 201) STRV, 'AO',      verify (STRV, 'AO',      .false.)
      write (*, 201) STRV, 'FOO',     verify (STRV, 'FOO',     .false.)
      write (*, 201) STRV, 'C++',     verify (STRV, 'C++',     .false.)
      write (*, 201) STRV, 'C++',     verify (STRV, 'C++',     .true.)
      write (*, 201) STRV, 'FORTRAN', verify (STRV, 'FORTRAN', .false.)
CCC_   . scan
      call UFTEST_banner (itest, iplog, 'scan')
 202  format ('SCAN: <', A, '/', A, '>', I3)
      write (*, 202) STRV, 'AO',      scan (STRV, 'AO',      .false.)
      write (*, 202) STRV, 'AO',      scan (STRV, 'AO',      .true.)
      write (*, 202) STRV, 'C++',     scan (STRV, 'C++',     .false.)
CCC_   . repeat
      call UFTEST_banner (itest, iplog, 'repeat')
 701  format ('REPEAT ', I3, 1x, A, '/')
      do j = 1, (len (STR) / 5) * 5, 5
#if HAVE_F77_REPEAT == 0
         call uffrpt (STR, 'X', j)
#else
         STR = REPEAT ('X', j)
#endif
         write (*, 701) j, _TRIM(STR)
      enddo
      write (*, 701) 0, '0123456789012345678901234567890123456789'
CCC_   . adjustl/ufadjl
      call UFTEST_banner (itest, iplog, 'adjustl')
      STR = '   ABCDEF   '
#if HAVE_F77_ADJUSTL == 0
      call ufadjl (STR)
#else
      STR = ADJUSTL (STR)
#endif
      write (*, *) '<', STR, '>'
CCC_   . floor
      call UFTEST_banner (itest, iplog, 'floor')
 101  format ('FLOOR:', F7.4, 1x, I5, 1x, F4.1)
      d = 2.0d0
      do
         write (*, 101) d, FLOORD (d), dfloor (d)
         d  = d - 0.125d0
         if (d.lt.-2.0d0) goto 100
      enddo
 100  continue
CCC_   . floating-point attribute diagnosis
      call UFTEST_banner (itest, iplog, 'floating-point attributes')
      call ufxfpi (jerr, -1)
CCC_   . byte-order
      call UFTEST_banner (itest, iplog, 'byte-order')
      call ufxbod (bodr, 0)
      write (*, *) 'byte-order: ', bodr
CCC_   . sub floating-point properties
#if TEST_UFORTW_FP
      call UFTEST_banner (itest, iplog, 'floating-point sub')
      call UFTEST_fp ()
#endif
CCC_   . ichar
      call UFTEST_banner (itest, iplog, 'ichar')
      call UFTEST_ichar (jerr, +1, iplog)
      write (*, *) 'ichar: ', jerr
CCC_   . integer functions
      call UFTEST_banner (itest, iplog, 'integer functions')
      call UFTEST_int ()
CCC_   . bitwise functions
      call UFTEST_banner (itest, iplog, 'bitwise functions')
      call UFTEST_bitwise ()
CCC_   . end
      call UFTEST_banner (itest, iplog, 'fine')
c
      STOP
      END
CCC_ & UFTEST_fp  ## floating-point property test
#if TEST_UFORTW_FP
      SUBROUTINE UFTEST_fp ()
      implicit none
      integer  j, k
      integer  kdig
      _REALSTD v, vf, vm
      _INT64   lv
      v = 0.0d0
      kdig = DIGITS (v)

      do j = 0, kdig + 2
         k = j
         vf = FRACTION (v)
         vm = SET_EXPONENT (vf, kdig)
         lv = _XINT64 (vm)
 101     format (I3, 3E24.16, 1x, Z16.16, 1x, I2, 1x, I4)
         write (*, 101) j, v, vf, vm, lv, LEADZ (lv), EXPONENT (v)
         v  = v * 2.0d0 + 1.0d0
      enddo
      RETURN
      END
#endif /* TEST_UFORTW_FP */
#endif /* TEST_UFORTW */
#if _NEED_UFTEST_BANNER
CCC_ & UFTEST_int  ## various integer function tests
      subroutine UFTEST_int ()
      implicit none
      integer    NV
      parameter (NV = 5)
      _REALSTD V (NV)
      integer  j
c
      V (1) = 5.0d0
      V (2) = 5.3d0
      V (3) = 5.8d0
      V (4) = 0.3d0
      V (5) = 0.8d0
c
      write (*, *) '## INT-family test'
 101  format (A, T7, F5.1, 1x, I5,   1x, I5)
 102  format (A, T7, F5.1, 1x, F5.1, 1x, F5.1)
c
#define _CHECKI(N,F,V) write (*, 101) N, V, F(V), F(-V)
#define _CHECKA(N,F,V) write (*, 102) N, V, F(V), F(-V)
c
      do j = 1, NV
         _CHECKI('INT',INT,V (j))
      enddo
      do j = 1, NV
         _CHECKI('NINT',NINT,V (j))
      enddo
      do j = 1, NV
         _CHECKA('AINT',AINT,V (j))
      enddo
      do j = 1, NV
         _CHECKA('ANINT',ANINT,V (j))
      enddo
c
      write (*, *) '## INT-family test done'
      RETURN
      END
CCC_ & UFTEST_bitwise  ## various bitwise function tests
      subroutine UFTEST_bitwise ()
      implicit none
c
      write (*, *) '## BITWISE-family test'
      call UFTEST_bitwise_sub(1)
      call UFTEST_bitwise_sub(2)
      call UFTEST_bitwise_sub(4)
      call UFTEST_bitwise_sub(8+2)
      call UFTEST_bitwise_sub(32+8+1)
c
      write (*, *) '## BITWISE-family test done'
      RETURN
      END
CCC_ & UFTEST_bitwise_sub  ## various bitwise function tests
      subroutine UFTEST_bitwise_sub (K1)
      implicit none
      _INTENT(IN,integer) K1
      character B0*(32), B1*(32), B2*(32)
      integer   K0, K2, KA
      integer UFBand
      call UFTEST_binstr(B1, K1)
 101  format(I3, 1x, A)
 102  format(I3, 1x, A, 3x, A, 1x, I3, 1x, I3, 1x, L1)
      write (*, 101) K1, B1
      do K0 = 7, 15
         K2 = UFBand(K0, K1)
         KA = IAND(K0, K1)
         call UFTEST_binstr(B0, K0)
         call UFTEST_binstr(B2, K2)
         write(*, 102) K0, B0, B2, K2, KA, KA.eq.K2
      enddo
      RETURN
      END
CCC_ & UFTEST_binstr
      subroutine UFTEST_binstr (B, N)
      implicit none
      _INTENT(OUT,;character) B*(*)
      _INTENT(IN, integer)    N
      integer M, L
      integer j
      L = 32
      M = N
      do j = 0, L - 1
         write(B(L-j:L-j), '(I1)') MOD(M, 2)
         M = M / 2
      enddo
      RETURN
      END
CCC_ & UFTEST_banner  ## Test banner (with index)
      SUBROUTINE UFTEST_banner
     I    (ITEST, IFP, CMSG)
      implicit none
      _INTENT(INOUT,integer)   ITEST
      _INTENT(IN,   character) CMSG*(*)
      _INTENT(IN,   integer)   IFP
      character BM*(1024), BR*(1024)
      integer   lm, lr
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
      lm = len_trim (CMSG)
 101  format ('@TEST', I3.3, 1x, A)
      write (BM, 101) ITEST, CMSG (1:lm)
      lm = len_trim (BM)
      lr = lm + 2
      call UFFrpt (BR, '-', lr)
 103  format (A)
 102  format (1x, A)
      if (COND_N(IFP)) then
         write (IFP, 103) BR (1:lr)
         write (IFP, 102) BM (1:lm)
         write (IFP, 103) BR (1:lr)
      else if (COND_S(IFP)) then
         write (*,   103) BR (1:lr)
         write (*,   102) BM (1:lm)
         write (*,   103) BR (1:lr)
      endif
      ITEST = ITEST + 1
      RETURN
      END
#endif /* _NEED_UFTEST_BANNER */
CCC_ + end
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
