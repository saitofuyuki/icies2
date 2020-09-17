C unizon/uvclst.F --- IcIES/Unizon/Variable cluster manipulation
C Maintainer:  SAITO Fuyuki
C Created: Dec 22 2011
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2016/08/19 15:53:33 fuyuki uvclst.F>'
#define _FNAME 'unizon/uvclst.F'
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
CCC_* Description
CCC_ + naming convention
CC      ua        L =    L +    R
CC      ue        L = f  L +    R
CC      uf        L =    L + f  R
CC      ug        L = f1 L + f2 R
CC      ul        L =    L / max (abs (L))
CC      um        L =    L *    R
CC      un        L = -  L +    R
CC      uo        L = f  L + (1-f) R
CC      us        L =    L -    R
CC      uw        L = f  L
c
CC      na        L =    R1 +    R2
CC      nc        L =    R1 *    (c - R2)
CC      nd        L =    R1 /    R2
CC      ne        L = f  R1 +    R2
CC      nf        L =    R1 + f  R2
CC      ng        L = f1 R1 + f2 R2
CC      nh        L = sqrt (R1*R1 + R2*R2)
CC      nm        L =    R1 *    R2
CC      ns        L =    R1 -    R2
CC      nu        L =    R1 /    R2 or Undef
CC      nv        L =   (R1 +    R2)/2
CC      nw        L = f R
c
CCC_* Common macros
#include "ofdlct.h" /* fortran dialect */
#ifndef    OPT_UVCLST_ARRAY_OPERATION
#  define  OPT_UVCLST_ARRAY_OPERATION 0
#endif
CCC_* [UVC] common
      subroutine UVCpfx
     I    (CTAG,  ITAG,  KA, MK, IFP)
      implicit none
      _INTENT(IN, character) CTAG*(*)
      _INTENT(IN, integer)   ITAG
      _INTENT(IN, integer)   MK
      _INTENT(IN, integer)   KA (MK)
      _INTENT(IN, integer)   IFP
      integer ICOUNT
      data    ICOUNT /0/
      save    ICOUNT
 101  format ('DBGUV ', A, I6.6, 1x, I6.6, 1x, 10I3)
      write (IFP, 101) _TRIM(CTAG), ITAG, ICOUNT, KA
      ICOUNT = ICOUNT + 1
      RETURN
      END
CCC_* [UV0] manipulation internal only
CCC_ + debug
CCC_  & UV0nan  ## isnan check
      subroutine UV0nan
     I    (V,
     I     N,  L,  KVL, CTAG, ITAG, IFP)
CCC_   . Declaration
      implicit none
      _INTENT(IN,   integer)   N,   L
      _INTENT(IN,   integer)   KVL
      _INTENT(IN,   character) CTAG*(*)
      _INTENT(IN,   integer)   ITAG
      _INTENT(IN,   integer)   IFP
      _INTENT(INOUT,_REALSTD)  V (L, *)
#if HAVE_F77_ISNAN
      integer j
#endif
CCC_   . Body
#if HAVE_F77_ISNAN
 101  format ('ISNAN:', A, ':', I3.3, 1x, 3I6, 1x, E16.9)
      do j  = 1, N
         if (ISNAN (V (j, KVL))) then
            write (IFP, 101) _TRIM(CTAG), ITAG, j, N, L, V (j, KVL)
         endif
      enddo
#else  /* not HAVE_F77_ISNAN */
 101  format ('ISNAN:', A, ':', I3.3, 1x, 'NOT AVAILABLE')
      write (IFP, 101) _TRIM(CTAG), ITAG
#endif /* not HAVE_F77_ISNAN */
      RETURN
      END
CCC_  & UV0d1a  ## debug/1d
      subroutine UV0d1a
     I    (V,
     I     N,  L,  KVL, CTAG, ITAG, IFP)
CCC_   . Declaration
      implicit none
      _INTENT(IN,   integer)   N,   L
      _INTENT(IN,   integer)   KVL
      _INTENT(IN,   character) CTAG*(*)
      _INTENT(IN,   integer)   ITAG
      _INTENT(IN,   integer)   IFP
      _INTENT(INOUT,_REALSTD)  V (L, *)
      integer j
      integer   KA (1)
CCC_   . Body
      KA (1) = KVL
      call UVCpfx (CTAG, ITAG, KA, 1, IFP)
 101  format (I6, 1x, E16.9)
      do j  = 1, N
         write (IFP, 101) j, V (j, KVL)
      enddo
      write (IFP, *)
      RETURN
      END
CCC_  & UV0d2a  ## debug/1d
      subroutine UV0d2a
     I    (V,
     I     N,  L,  KV1, KV2, CTAG, ITAG, IFP)
CCC_   . Declaration
      implicit none
      _INTENT(IN,   integer)   N,   L
      _INTENT(IN,   integer)   KV1, KV2
      _INTENT(IN,   character) CTAG*(*)
      _INTENT(IN,   integer)   ITAG
      _INTENT(IN,   integer)   IFP
      _INTENT(INOUT,_REALSTD)  V (L, *)
      integer j
      integer KA (2)
CCC_   . Body
      KA (1) = KV1
      KA (2) = KV2
      call UVCpfx (CTAG, ITAG, KA, 2, IFP)
 101  format (I6, 1x, E16.9, 1x, E16.9)
      do j  = 1, N
         write (IFP, 101) j, V (j, KV1), V (j, KV2)
      enddo
      write (IFP, *)
      RETURN
      END
CCC_ + update
CCC_  & UV0uaa  ## update/addition/1d            V[L] += V[R]
      subroutine UV0uaa
     M    (V,
     I     N,  L,  KVL, KVR)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KVL, KVR
      _INTENT(INOUT,_REALSTD) V (L, *)
#if OPT_UVCLST_ARRAY_OPERATION
      V (1:N, KVL) = V (1:N, KVL) + V (1:N, KVR)
#else
      integer j
      do j  = 1, N
         V (j, KVL) = V (j, KVL) + V (j, KVR)
      enddo
#endif
      RETURN
      END
CCC_  & UV0uac  ## update/addition/2d/0            V[L] += V[R]
      subroutine UV0uac
     M    (V,
     I     N,  L,  N2, L2, K2, KVL, KVR)
      implicit none
      _INTENT(IN,   integer)  N,   L,  N2, L2, K2
      _INTENT(IN,   integer)  KVL, KVR
      _INTENT(INOUT,_REALSTD) V (L, L2, *)
#if OPT_UVCLST_ARRAY_OPERATION
      integer j2
      j2 = K2 + N2 - 1
      V (1:N, K2:j2, KVL) = V (1:N, K2:j2, KVL) + V (1:N, K2:j2, KVR)
#else
      integer j, j2
      do    j2 = K2, K2 + N2 - 1
         do j  = 1, N
            V (j, j2, KVL) = V (j, j2, KVL) + V (j, j2, KVR)
         enddo
      enddo
#endif
      RETURN
      END
CCC_  & UV0uea  ## update/addition (factor)/1d   V[L] = f V[L] + V[R]
      subroutine UV0uea
     M    (V,
     I     N,  L,  KVL, KVR, F)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KVL, KVR
      _INTENT(IN,   _REALSTD) F
      _INTENT(INOUT,_REALSTD) V (L, *)
#if OPT_UVCLST_ARRAY_OPERATION
      V (1:N, KVL) = F * V (1:N, KVL) + V (1:N, KVR)
#else
      integer j
      do j  = 1, N
         V (j, KVL) = F * V (j, KVL) + V (j, KVR)
      enddo
#endif
      RETURN
      END
CCC_  & UV0ueb  ## update/addition (factor)/2d   V[L] = f V[L] + V[R]
      subroutine UV0ueb
     M    (V,
     I     N,  L,  N2, L2, KVL, KVR, F)
      implicit none
      _INTENT(IN,   integer)  N,   L,  N2, L2
      _INTENT(IN,   integer)  KVL, KVR
      _INTENT(IN,   _REALSTD) F
      _INTENT(INOUT,_REALSTD) V (L, L2, *)
#if OPT_UVCLST_ARRAY_OPERATION
      V (1:N, 1:N2, KVL) = F * V (1:N, 1:N2, KVL) + V (1:N, 1:N2, KVR)
#else
      integer j, j2
      do    j2 = 1, N2
         do j  = 1, N
            V (j, j2, KVL) = F * V (j, j2, KVL) + V (j, j2, KVR)
         enddo
      enddo
#endif
      RETURN
      END
CCC_  & UV0ufa  ## update/addition (factor)/1d   V[L] += (f V[R])
      subroutine UV0ufa
     M    (V,
     I     N,  L,  KVL, KVR, F)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KVL, KVR
      _INTENT(IN,   _REALSTD) F
      _INTENT(INOUT,_REALSTD) V (L, *)
#if OPT_UVCLST_ARRAY_OPERATION
      V (1:N, KVL) = V (1:N, KVL) + F * V (1:N, KVR)
#else
      integer j
      do j  = 1, N
         V (j, KVL) = V (j, KVL) + F * V (j, KVR)
      enddo
#endif
      RETURN
      END
CCC_  & UV0ufb  ## update/addition (factor)/2d   V[L] += (f V[R])
      subroutine UV0ufb
     M    (V,
     I     N,  L,  N2, L2, KVL, KVR, F)
      implicit none
      _INTENT(IN,   integer)  N,   L,  N2, L2
      _INTENT(IN,   integer)  KVL, KVR
      _INTENT(IN,   _REALSTD) F
      _INTENT(INOUT,_REALSTD) V (L, L2, *)
#if OPT_UVCLST_ARRAY_OPERATION
      V (1:N, 1:N2, KVL) = V (1:N, 1:N2, KVL) + F * V (1:N, 1:N2, KVR)
#else
      integer j, j2
      do    j2 = 1, N2
         do j  = 1, N
            V (j, j2, KVL) = V (j, j2, KVL) + F * V (j, j2, KVR)
         enddo
      enddo
#endif
      RETURN
      END
CCC_  & UV0uga  ## update/addition (factor2)/1d   V[L] = f1 V[L]+ f2 V[R]
      subroutine UV0uga
     M    (V,
     I     N,  L,  KVL, KVR, F1, F2)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KVL, KVR
      _INTENT(IN,   _REALSTD) F1,  F2
      _INTENT(INOUT,_REALSTD) V (L, *)
#if OPT_UVCLST_ARRAY_OPERATION
      V (1:N, KVL) = F1 * V (1:N, KVL) + F2 * V (1:N, KVR)
#else
      integer j
      do j  = 1, N
         V (j, KVL) = F1 * V (j, KVL) + F2 * V (j, KVR)
      enddo
#endif
      RETURN
      END
CCC_  & UV0ugb  ## update/addition (factor2)/2d   V[L] = f1 V[L]+ f2 V[R]
      subroutine UV0ugb
     M    (V,
     I     N,  L,  N2, L2, KVL, KVR, F1, F2)
      implicit none
      _INTENT(IN,   integer)  N,   L,  N2, L2
      _INTENT(IN,   integer)  KVL, KVR
      _INTENT(IN,   _REALSTD) F1,  F2
      _INTENT(INOUT,_REALSTD) V (L, L2, *)
#if OPT_UVCLST_ARRAY_OPERATION
      V (1:N, 1:N2, KVL) =
     $     F1 * V (1:N, 1:N2, KVL) + F2 * V (1:N, 1:N2, KVR)
#else
      integer j, j2
      do    j2 = 1, N2
         do j  = 1, N
            V (j, j2, KVL) = F1 * V (j, j2, KVL) + F2 * V (j, j2, KVR)
         enddo
      enddo
#endif
      RETURN
      END
CCC_  & UV0ulb  ## update/normalize/2d for each level
      subroutine UV0ulb
     M    (V,
     I     N,  L,  N2, L2,  KVL)
      implicit none
      _INTENT(IN,   integer)  N,   L,  N2, L2
      _INTENT(IN,   integer)  KVL
      _INTENT(INOUT,_REALSTD) V (L, L2, *)
      integer j, j2
      _REALSTD T
      do    j2 = 1, N2
         T = 0.0d0
         do j  = 1, N
            T = MAX (ABS (V (j, j2, KVL)), T)
         enddo
         if (T.ne.0.0d0) then
            do j  = 1, N
               V (j, j2, KVL) = V (j, j2, KVL) / T
            enddo
         endif
      enddo
      RETURN
      END
CCC_  & UV0uma  ## update/multiplication/1d      V[L] *= V[R]
      subroutine UV0uma
     M    (V,
     I     N,  L,  KVL, KVR)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KVL, KVR
      _INTENT(INOUT,_REALSTD) V (L, *)
#if OPT_UVCLST_ARRAY_OPERATION
      V (1:N, KVL) = V (1:N, KVL) * V (1:N, KVR)
#else
      integer j
      do j  = 1, N
         V (j, KVL) = V (j, KVL) * V (j, KVR)
      enddo
#endif
      RETURN
      END
CCC_  & UV0umc  ## update/multiplication/2d/0 V[L] *= V[R]
      subroutine UV0umc
     M    (V,
     I     N,  L,  N2, L2, K2, KVL, KVR)
      implicit none
      _INTENT(IN,   integer)  N,   L,  N2, L2, K2
      _INTENT(IN,   integer)  KVL, KVR
      _INTENT(INOUT,_REALSTD) V (L, L2, *)
#if OPT_UVCLST_ARRAY_OPERATION
      integer j2
      j2 = K2 + N2 - 1
      V (1:N, K2:j2, KVL) = V (1:N, K2:j2, KVL) * V (1:N, K2:j2, KVR)
#else
      integer j, j2
      do    j2 = K2, K2 + N2 - 1
         do j  = 1, N
            V (j, j2, KVL) = V (j, j2, KVL) * V (j, j2, KVR)
         enddo
      enddo
#endif
      RETURN
      END
CCC_  & UV0una  ## update/addition (negative)/1d V[L] = - V[L] + V[R]
      subroutine UV0una
     M    (V,
     I     N,  L,  KVL, KVR)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KVL, KVR
      _INTENT(INOUT,_REALSTD) V (L, *)
#if OPT_UVCLST_ARRAY_OPERATION
      V (1:N, KVL) = V (1:N, KVR) - V (1:N, KVL)
#else
      integer j
      do j  = 1, N
         V (j, KVL) = V (j, KVR) - V (j, KVL)
      enddo
#endif
      RETURN
      END
CCC_  & UV0unb  ## update/addition (negative)/2d V[L] = - V[L] + V[R]
      subroutine UV0unb
     M    (V,
     I     N,  L,  N2, L2, KVL, KVR)
      implicit none
      _INTENT(IN,   integer)  N,   L,  N2, L2
      _INTENT(IN,   integer)  KVL, KVR
      _INTENT(INOUT,_REALSTD) V (L, L2, *)
#if OPT_UVCLST_ARRAY_OPERATION
      V (1:N, 1:N2, KVL) = - V (1:N, 1:N2, KVL) + V (1:N, 1:N2, KVR)
#else
      integer j, j2
      do    j2 = 1, N2
         do j  = 1, N
            V (j, j2, KVL) = - V (j, j2, KVL) + V (j, j2, KVR)
         enddo
      enddo
#endif
      RETURN
      END
CCC_  & UV0uoa  ## update/addition (normalized factor)/1d  V[L] = f V[L]+ (1-f) V[R]
      subroutine UV0uoa
     M    (V,
     I     N,  L,  KVL, KVR, F)
Cc  operation modified for guarantee when L==R
cc     V[L] = f (V[L]-V[R]) + V[R]
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KVL, KVR
      _INTENT(IN,   _REALSTD) F
      _INTENT(INOUT,_REALSTD) V (L, *)
#if OPT_UVCLST_ARRAY_OPERATION
      V (1:N, KVL) = F * (V (1:N, KVL) - V (1:N, KVR)) + V (1:N, KVR)
#else
      integer j
      do j  = 1, N
         V (j, KVL) = F * (V (j, KVL) - V (j, KVR)) + V (j, KVR)
      enddo
#endif
      RETURN
      END
CCC_  & UV0uob  ## update/addition (normalized factor)/2d  V[L] = f V[L]+ (1-f) V[R]
      subroutine UV0uob
     M    (V,
     I     N,  L,  N2, L2, KVL, KVR, F)
      implicit none
      _INTENT(IN,   integer)  N,   L,  N2, L2
      _INTENT(IN,   integer)  KVL, KVR
      _INTENT(IN,   _REALSTD) F
      _INTENT(INOUT,_REALSTD) V (L, L2, *)
#if OPT_UVCLST_ARRAY_OPERATION
      V (1:N, 1:N2, KVL) =
     $     F * (V (1:N, 1:N2, KVL) - V (1:N, 1:N2, KVR))
     $     + V (1:N, 1:N2, KVR)
#else
      integer j, j2
      do    j2 = 1, N2
         do j  = 1, N
            V (j, j2, KVL)
     $           = F * (V (j, j2, KVL) - V (j, j2, KVR))
     $           + V (j, j2, KVR)
         enddo
      enddo
#endif
      RETURN
      END
CCC_  & UV0usa  ## update/subtraction/1d            V[L] -= V[R]
      subroutine UV0usa
     M    (V,
     I     N,  L,  KVL, KVR)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KVL, KVR
      _INTENT(INOUT,_REALSTD) V (L, *)
#if OPT_UVCLST_ARRAY_OPERATION
      V (1:N, KVL) = V (1:N, KVL) - V (1:N, KVR)
#else
      integer j
      do j  = 1, N
         V (j, KVL) = V (j, KVL) - V (j, KVR)
      enddo
#endif
      RETURN
      END
CCC_  & UV0uwa  ## update/weight/1d              V[L] *= f
      subroutine UV0uwa
     M    (V,
     I     N,  L,  KVL, F)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KVL
      _INTENT(IN,   _REALSTD) F
      _INTENT(INOUT,_REALSTD) V (L, *)
#if OPT_UVCLST_ARRAY_OPERATION
      V (1:N, KVL) = V (1:N, KVL) * F
#else
      integer j
      do j  = 1, N
         V (j, KVL) = V (j, KVL) * F
      enddo
#endif
      RETURN
      END
CCC_  & UV0uwc  ## update/factor/2d/0 V[L] *= f
      subroutine UV0uwc
     M    (V,
     I     N,  L,  N2, L2, K2, KVL, F)
      implicit none
      _INTENT(IN,   integer)  N,   L,  N2, L2, K2
      _INTENT(IN,   integer)  KVL
      _INTENT(IN,   _REALSTD) F
      _INTENT(INOUT,_REALSTD) V (L, L2, *)
#if OPT_UVCLST_ARRAY_OPERATION
      integer j2
      j2 = K2 + N2 - 1
      V (1:N, K2:j2, KVL) = V (1:N, K2:j2, KVL) * F
#else
      integer j, j2
      do    j2 = K2, K2 + N2 - 1
         do j  = 1, N
            V (j, j2, KVL) = V (j, j2, KVL) * F
         enddo
      enddo
#endif
      RETURN
      END
CCC_ + new
CCC_  & UV0naa  ## new/addition/1d               V[L] = V[R1] + V[R2]
      subroutine UV0naa
     M    (V,
     I     N,  L,  KVL, KVR1, KVR2)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KVL, KVR1, KVR2
      _INTENT(INOUT,_REALSTD) V (L, *)
#if OPT_UVCLST_ARRAY_OPERATION
      V (1:N, KVL) = V (1:N, KVR1) + V (1:N, KVR2)
#else
      integer j
      do j  = 1, N
         V (j, KVL) = V (j, KVR1) + V (j, KVR2)
      enddo
#endif
      RETURN
      END
CCC_  & UV0nac  ## new/addition/2d/0             V[L] = V[R1] + V[R2]
      subroutine UV0nac
     M    (V,
     I     N,  L,  N2, L2, K2, KVL, KVR1, KVR2)
      implicit none
      _INTENT(IN,   integer)  N,   L, N2, L2, K2
      _INTENT(IN,   integer)  KVL, KVR1,  KVR2
      _INTENT(INOUT,_REALSTD) V (L, L2, *)
#if OPT_UVCLST_ARRAY_OPERATION
      integer j2
      j2 = K2 + N2 - 1
      V (1:N, K2:j2, KVL) = V (1:N, K2:j2, KVR1) + V (1:N, K2:j2, KVR2)
#else
      integer j, j2
      do    j2 = K2, K2 + N2 - 1
         do j  = 1, N
            V (j, j2, KVL) = V (j, j2, KVR1) + V (j, j2, KVR2)
         enddo
      enddo
#endif
      RETURN
      END
CCC_  & UV0nda  ## new/division/1d               V[L] = V[R1] / V[R2]
      subroutine UV0nda
     M    (V,
     I     N,  L,  KVL, KVR1, KVR2)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KVL, KVR1, KVR2
      _INTENT(INOUT,_REALSTD) V (L, *)
#if OPT_UVCLST_ARRAY_OPERATION
      V (1:N, KVL) = V (1:N, KVR1) / V (1:N, KVR2)
#else
      integer j
      do j  = 1, N
         V (j, KVL) = V (j, KVR1) / V (j, KVR2)
      enddo
#endif
      RETURN
      END
CCC_  & UV0nfb  ## new/addition (factor)/2d   V[L] = V[R1] + f V[R2]
      subroutine UV0nfb
     M    (V,
     I     N,  L,  N2, L2, KVL, KVR1, KVR2, F)
      implicit none
      _INTENT(IN,   integer)  N,   L,  N2, L2
      _INTENT(IN,   integer)  KVL, KVR1, KVR2
      _INTENT(IN,   _REALSTD) F
      _INTENT(INOUT,_REALSTD) V (L, L2, *)
#if OPT_UVCLST_ARRAY_OPERATION
      V (1:N, 1:N2, KVL) = V (1:N, 1:N2, KVR1) + F * V (1:N, 1:N2, KVR2)
#else
      integer j, j2
      do    j2 = 1, N2
         do j  = 1, N
            V (j, j2, KVL) = V (j, j2, KVR1) + F * V (j, j2, KVR2)
         enddo
      enddo
#endif
      RETURN
      END
CCC_  & UV0nha  ## new/magnitude/1d         V[L] = sqrt(V[R1]^2+V[R2]^2)
      subroutine UV0nha
     M    (V,
     I     N,  L,  KL, KR1, KR2)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KL,  KR1, KR2
      _INTENT(INOUT,_REALSTD) V (L, *)
#if OPT_UVCLST_ARRAY_OPERATION
      V (1:N, KL) =
     $     SQRT (V (1:N, KR1) * V (1:N, KR1)
     $           + V (1:N, KR2) * V (1:N, KR2))
#else
      integer j
      do j  = 1, N
         V (j, KL) =
     $        SQRT (V (j, KR1) * V (j, KR1)
     $             + V (j, KR2) * V (j, KR2))
      enddo
#endif
      RETURN
      END
CCC_  & UV0nma  ## new/multiplication/1d         V[L] = V[R1] * V[R2]
      subroutine UV0nma
     M    (V,
     I     N,  L,  KVL, KVR1, KVR2)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KVL, KVR1, KVR2
      _INTENT(INOUT,_REALSTD) V (L, *)
#if OPT_UVCLST_ARRAY_OPERATION
      V (1:N, KVL) = V (1:N, KVR1) * V (1:N, KVR2)
#else
      integer j
      do j  = 1, N
         V (j, KVL) = V (j, KVR1) * V (j, KVR2)
      enddo
#endif
      RETURN
      END
CCC_  & UV0nsa  ## new/subtraction/1d            V[L] = V[R1] - V[R2]
      subroutine UV0nsa
     M    (V,
     I     N,  L,  KVL, KVR1, KVR2)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KVL, KVR1, KVR2
      _INTENT(INOUT,_REALSTD) V (L, *)
#if OPT_UVCLST_ARRAY_OPERATION
      V (1:N, KVL) = V (1:N, KVR1) - V (1:N, KVR2)
#else
      integer j
      do j  = 1, N
         V (j, KVL) = V (j, KVR1) - V (j, KVR2)
      enddo
#endif
      RETURN
      END
CCC_  & UV0nsb  ## new/subtraction/2d               V[L] = V[R1] - V[R2]
      subroutine UV0nsb
     M    (V,
     I     N,  L,  N2, L2, KVL, KVR1, KVR2)
      implicit none
      _INTENT(IN,   integer)  N,   L,  N2, L2
      _INTENT(IN,   integer)  KVL, KVR1, KVR2
      _INTENT(INOUT,_REALSTD) V (L, L2, *)
#if OPT_UVCLST_ARRAY_OPERATION
      V (1:N, 1:N2, KVL) = V (1:N, 1:N2, KVR1) - V (1:N, 1:N2, KVR2)
#else
      integer j, j2
      do    j2 = 1, N2
         do j  = 1, N
            V (j, j2, KVL) = V (j, j2, KVR1) - V (j, j2, KVR2)
         enddo
      enddo
#endif
      RETURN
      END
CCC_  & UV0nwa  ## new/weight/1d                 V[L] = V[R]  * f
      subroutine UV0nwa
     M    (V,
     I     N,  L,  KVL, KVR, F)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KVL, KVR
      _INTENT(INOUT,_REALSTD) V (L, *)
      _INTENT(IN,   _REALSTD) F
#if OPT_UVCLST_ARRAY_OPERATION
      V (1:N, KVL) = V (1:N, KVR) * F
#else
      integer j
      do j  = 1, N
         V (j, KVL) = V (j, KVR) * F
      enddo
#endif
      RETURN
      END
CCC_ + others
CCC_  & UV0cpa  ## copy/1d                       V[L] = V[R]
      subroutine UV0cpa
     M    (V,
     I     N,  L,  KVL, KVR)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KVL, KVR
      _INTENT(INOUT,_REALSTD) V (L, *)
#if OPT_UVCLST_ARRAY_OPERATION
      V (1:N, KVL) = V (1:N, KVR)
#else
      integer j
      do j  = 1, N
         V (j, KVL) = V (j, KVR)
      enddo
#endif
      RETURN
      END
CCC_  & UV0cpb  ## copy/2d                       V[L] = V[R]
      subroutine UV0cpb
     M    (V,
     I     N,  L,  N2, L2, KVL, KVR)
      implicit none
      _INTENT(IN,   integer)  N,   L,  N2, L2
      _INTENT(IN,   integer)  KVL, KVR
      _INTENT(INOUT,_REALSTD) V (L, L2, *)
#if OPT_UVCLST_ARRAY_OPERATION
      V (1:N, 1:N2, KVL) = V (1:N, 1:N2, KVR)
#else
      integer j, j2
      do    j2 = 1, N2
         do j  = 1, N
            V (j, j2, KVL) = V (j, j2, KVR)
         enddo
      enddo
#endif
      RETURN
      END
CCC_  & UV0sta  ## set/1d                        V[L] = C
      subroutine UV0sta
     M    (V,
     I     N,  L, KVL, C)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KVL
      _INTENT(INOUT,_REALSTD) V (L, *)
      _INTENT(IN,   _REALSTD) C
#if OPT_UVCLST_ARRAY_OPERATION
      V (1:N, KVL) = C
#else
      integer j
      do j  = 1, N
         V (j, KVL) = C
      enddo
#endif
      RETURN
      END
CCC_  & UV0stb  ## set/2d                        V[L] = C
      subroutine UV0stb
     M    (V,
     I     N,  L, N2, L2, KVL, C)
      implicit none
      _INTENT(IN,   integer)  N,   L,  N2, L2
      _INTENT(IN,   integer)  KVL
      _INTENT(INOUT,_REALSTD) V (L, L2, *)
      _INTENT(IN,   _REALSTD) C
#if OPT_UVCLST_ARRAY_OPERATION
      V (1:N, 1:N2, KVL) = C
#else
      integer j, j2
      do    j2 = 1, N2
         do j  = 1, N
            V (j, j2, KVL) = C
         enddo
      enddo
#endif
      RETURN
      END
CCC_  & UV0stc  ## set/2d/0                      V[L] = C
      subroutine UV0stc
     M    (V,
     I     N,  L, N2, L2, K2, KVL, C)
      implicit none
      _INTENT(IN,   integer)  N,  L,  N2, L2, K2
      _INTENT(IN,   integer)  KVL
      _INTENT(INOUT,_REALSTD) V (L, L2, *)
      _INTENT(IN,   _REALSTD) C
#if OPT_UVCLST_ARRAY_OPERATION
      integer j2
      j2 = K2 + N2 - 1
      V (1:N, K2:j2, KVL) = C
#else
      integer j, j2
      do    j2 = K2, K2 + N2 -1
         do j  = 1, N
            V (j, j2, KVL) = C
         enddo
      enddo
#endif
      RETURN
      END
CCC_  & UV0sba  ## set (basis)/1d                V[L,j] = 1
      subroutine UV0sba
     M    (V,
     I     N,  L, KVL, KB)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KVL
      _INTENT(INOUT,_REALSTD) V (L, *)
      _INTENT(IN,   integer)  KB
      integer j
#if OPT_UVCLST_ARRAY_OPERATION
      V (1:KB-1, KVL) = 0.0d0
      V (KB,     KVL) = 1.0d0
      V (KB+1:N, KVL) = 0.0d0
#else
      do j  = 1, KB - 1
         V (j, KVL) = 0.0d0
      enddo
      V (KB, KVL) = 1.0d0
      do j  = KB + 1, N
         V (j, KVL) = 0.0d0
      enddo
#endif
      RETURN
      END
CCC_* [UV1] manipulation 1 external (V, X)
CCC_ + update
CCC_  & UV1uaa  ## update/addition/1d            V[L] += X[R]
      subroutine UV1uaa
     M    (V,
     I     X,
     I     N,  L,  KVL, KXR)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KVL, KXR
      _INTENT(INOUT,_REALSTD) V (L, *)
      _INTENT(IN,   _REALSTD) X (L, *)
#if OPT_UVCLST_ARRAY_OPERATION
      V (1:N, KVL) = V (1:N, KVL) + X (1:N, KXR)
#else
      integer j
      do j  = 1, N
         V (j, KVL) = V (j, KVL) + X (j, KXR)
      enddo
#endif
      RETURN
      END
CCC_  & UV1uma  ## update/multiplication/1d      V[L] *= X[R]
      subroutine UV1uma
     M    (V,
     I     X,
     I     N,  L,  KVL, KXR)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KVL, KXR
      _INTENT(INOUT,_REALSTD) V (L, *)
      _INTENT(IN,   _REALSTD) X (L, *)
#if OPT_UVCLST_ARRAY_OPERATION
      V (1:N, KVL) = V (1:N, KVL) * X (1:N, KXR)
#else
      integer j
      do j  = 1, N
         V (j, KVL) = V (j, KVL) * X (j, KXR)
      enddo
#endif
      RETURN
      END
CCC_  & UV1umc  ## update/multiplication/2d/0   V[L] *= X[R]
      subroutine UV1umc
     M    (V,
     I     X,
     I     N,  L,  N2, L2, K2, KVL, KXR)
      implicit none
      _INTENT(IN,   integer)  N,   L,  N2, L2, K2
      _INTENT(IN,   integer)  KVL, KXR
      _INTENT(INOUT,_REALSTD) V (L, L2, *)
      _INTENT(IN,   _REALSTD) X (L, L2, *)
#if OPT_UVCLST_ARRAY_OPERATION
      integer j2
      j2 = K2 + N2 - 1
      V (1:N, K2:j2, KVL) = V (1:N, K2:j2, KVL) * V (1:N, K2:j2, KVR)
#else
      integer j, j2
      do    j2 = K2, K2 + N2 - 1
         do j  = 1, N
            V (j, j2, KVL) = V (j, j2, KVL) * X (j, j2, KXR)
         enddo
      enddo
#endif
      RETURN
      END
CCC_  & UV1una  ## update/addition (negative)/1d V[L] = - V[L] + X[R]
      subroutine UV1una
     M    (V,
     I     X,
     I     N,  L,  KVL, KXR)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KVL, KXR
      _INTENT(INOUT,_REALSTD) V (L, *)
      _INTENT(IN,   _REALSTD) X (L, *)
#if OPT_UVCLST_ARRAY_OPERATION
      V (1:N, KVL) = X (1:N, KXR) - V (1:N, KVL)
#else
      integer j
      do j  = 1, N
         V (j, KVL) = X (j, KXR) - V (j, KVL)
      enddo
#endif
      RETURN
      END
CCC_  & UV1usa  ## update/subtraction/1d         V[L] -= X[R]
      subroutine UV1usa
     M    (V,
     I     X,
     I     N,  L,  KVL, KXR)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KVL, KXR
      _INTENT(INOUT,_REALSTD) V (L, *)
      _INTENT(IN,   _REALSTD) X (L, *)
#if OPT_UVCLST_ARRAY_OPERATION
      V (1:N, KVL) = V (1:N, KVL) - X (1:N, KXR)
#else
      integer j
      do j  = 1, N
         V (j, KVL) = V (j, KVL) - X (j, KXR)
      enddo
#endif
      RETURN
      END
CCC_ + new
CCC_  & UV1naa  ## new/addition/1d               V[L] = V[RV] + X[RX]
      subroutine UV1naa
     M    (V,
     I     X,
     I     N,  L,  KVL, KVR, KXR)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KVL, KVR,  KXR
      _INTENT(INOUT,_REALSTD) V (L, *)
      _INTENT(IN,   _REALSTD) X (L, *)
#if OPT_UVCLST_ARRAY_OPERATION
      V (1:N, KVL) = V (1:N, KVR) + X (1:N, KXR)
#else
      integer j
      do j  = 1, N
         V (j, KVL) = V (j, KVR) + X (j, KXR)
      enddo
#endif
      RETURN
      END
CCC_  & UV1nac  ## new/addition/2d/0             V[L] = V[RV] + X[RX]
      subroutine UV1nac
     M    (V,
     I     X,
     I     N,  L,  N2, L2, K2, KVL, KVR, KXR)
      implicit none
      _INTENT(IN,   integer)  N,   L, N2, L2, K2
      _INTENT(IN,   integer)  KVL, KVR,  KXR
      _INTENT(INOUT,_REALSTD) V (L, L2, *)
      _INTENT(IN,   _REALSTD) X (L, L2, *)
#if OPT_UVCLST_ARRAY_OPERATION
      integer j2
      j2 = K2 + N2 - 1
      V (1:N, K2:j2, KVL) = V (1:N, K2:j2, KVR) + X (1:N, K2:j2, KXR)
#else
      integer j, j2
      do    j2 = K2, K2 + N2 - 1
         do j  = 1, N
            V (j, j2, KVL) = V (j, j2, KVR) + X (j, j2, KXR)
         enddo
      enddo
#endif
      RETURN
      END
CCC_  & UV1nca  ## new/multipl.compl./1d         V[L] = V[RV] * (C-X[RX])
      subroutine UV1nca
     M    (V,
     I     X,
     I     N,  L,  KVL, KVR, KXR, C)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KVL, KVR,  KXR
      _INTENT(INOUT,_REALSTD) V (L, *)
      _INTENT(IN,   _REALSTD) X (L, *)
      _INTENT(IN,   _REALSTD) C
#if OPT_UVCLST_ARRAY_OPERATION
      V (1:N, KVL) = (C - X (1:N, KXR)) * V (1:N, KVR)
#else
      integer j
      do j  = 1, N
         V (j, KVL) = (C - X (j, KXR)) * V (j, KVR)
      enddo
#endif
      RETURN
      END
CCC_  & UV1nda  ## new/division/1d               V[L] = V[RV] / X[RX]
      subroutine UV1nda
     M    (V,
     I     X,
     I     N,  L,  KVL, KVR, KXR)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KVL, KVR,  KXR
      _INTENT(INOUT,_REALSTD) V (L, *)
      _INTENT(IN,   _REALSTD) X (L, *)
#if OPT_UVCLST_ARRAY_OPERATION
      V (1:N, KVL) = V (1:N, KVR) / X (1:N, KXR)
#else
      integer j
      do j  = 1, N
         V (j, KVL) = V (j, KVR) / X (j, KXR)
      enddo
#endif
      RETURN
      END
CCC_  & UV1nea  ## new/addition factor/1d         V[L] = f * V[RV] + X[RX]
      subroutine UV1nea
     M    (V,
     I     X,
     I     N,  L,  KVL, KVR, KXR, F)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KVL, KVR,  KXR
      _INTENT(INOUT,_REALSTD) V (L, *)
      _INTENT(IN,   _REALSTD) X (L, *)
      _INTENT(IN,   _REALSTD) F
#if OPT_UVCLST_ARRAY_OPERATION
      V (1:N, KVL) = F * V (1:N, KVR) + X (1:N, KXR)
#else
      integer j
      do j  = 1, N
         V (j, KVL) = F * V (j, KVR) + X (j, KXR)
      enddo
#endif
      RETURN
      END
CCC_  & UV1nfa  ## new/addition factor/1d         V[L] = V[RV] + f * X[RX]
      subroutine UV1nfa
     M    (V,
     I     X,
     I     N,  L,  KVL, KVR, KXR, F)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KVL, KVR,  KXR
      _INTENT(INOUT,_REALSTD) V (L, *)
      _INTENT(IN,   _REALSTD) X (L, *)
      _INTENT(IN,   _REALSTD) F
#if OPT_UVCLST_ARRAY_OPERATION
      V (1:N, KVL) = V (1:N, KVR) + F * X (1:N, KXR)
#else
      integer j
      do j  = 1, N
         V (j, KVL) = V (j, KVR) + F * X (j, KXR)
      enddo
#endif
      RETURN
      END
CCC_  & UV1nga  ## new/addition factors/1d         V[L] = f1 * V[RV] + f2 * X[RX]
      subroutine UV1nga
     M    (V,
     I     X,
     I     N,  L,  KVL, KVR, KXR, F1, F2)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KVL, KVR,  KXR
      _INTENT(INOUT,_REALSTD) V (L, *)
      _INTENT(IN,   _REALSTD) X (L, *)
      _INTENT(IN,   _REALSTD) F1, F2
#if OPT_UVCLST_ARRAY_OPERATION
      V (1:N, KVL) = F1 * V (1:N, KVR) + F2 * X (1:N, KXR)
#else
      integer j
      do j  = 1, N
         V (j, KVL) = F1 * V (j, KVR) + F2 * X (j, KXR)
      enddo
#endif
      RETURN
      END
CCC_  & UV1nma  ## new/multiplication/1d         V[L] = V[RV] * X[RX]
      subroutine UV1nma
     M    (V,
     I     X,
     I     N,  L,  KVL, KVR, KXR)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KVL, KVR,  KXR
      _INTENT(INOUT,_REALSTD) V (L, *)
      _INTENT(IN,   _REALSTD) X (L, *)
#if OPT_UVCLST_ARRAY_OPERATION
      V (1:N, KVL) = V (1:N, KVR) * X (1:N, KXR)
#else
      integer j
      do j  = 1, N
         V (j, KVL) = V (j, KVR) * X (j, KXR)
      enddo
#endif
      RETURN
      END
CCC_  & UV1nsa  ## new/subtraction/1d            V[L] = V[RV] - X[RX]
      subroutine UV1nsa
     M    (V,
     I     X,
     I     N,  L,  KVL, KVR, KXR)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KVL, KVR,  KXR
      _INTENT(INOUT,_REALSTD) V (L, *)
      _INTENT(IN,   _REALSTD) X (L, *)
#if OPT_UVCLST_ARRAY_OPERATION
      V (1:N, KVL) = V (1:N, KVR) - X (1:N, KXR)
#else
      integer j
      do j  = 1, N
         V (j, KVL) = V (j, KVR) - X (j, KXR)
      enddo
#endif
      RETURN
      END
CCC_  & UV1nwa  ## new/weight/1d                 V[L] = X[R] * f
      subroutine UV1nwa
     M    (V,
     I     X,
     I     N,  L,  KVL, KXR, F)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KVL, KXR
      _INTENT(INOUT,_REALSTD) V (L, *)
      _INTENT(IN,   _REALSTD) X (L, *)
      _INTENT(IN,   _REALSTD) F
#if OPT_UVCLST_ARRAY_OPERATION
      V (1:N, KVL) = X (1:N, KXR) * F
#else
      integer j
      do j  = 1, N
         V (j, KVL) = X (j, KXR) * F
      enddo
#endif
      RETURN
      END
CCC_  & UV1nwc  ## new/weight/2d/0               V[L] = X[R] * f
      subroutine UV1nwc
     M    (V,
     I     X,
     I     N,  L,  N2, L2, K2, KVL, KXR, F)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  N2,  L2, K2
      _INTENT(IN,   integer)  KVL, KXR
      _INTENT(INOUT,_REALSTD) V (L, L2, *)
      _INTENT(IN,   _REALSTD) X (L, L2, *)
      _INTENT(IN,   _REALSTD) F
#if OPT_UVCLST_ARRAY_OPERATION
      integer j2
      j2 = K2 + N2 - 1
      V (1:N, K2:j2, KVL) = X (1:N, K2:j2, KXR) * F
#else
      integer j, j2
      do    j2 = K2, K2 + N2 - 1
         do j  = 1, N
            V (j, j2, KVL) = X (j, j2, KXR) * F
         enddo
      enddo
#endif
      RETURN
      END
CCC_ + others
CCC_  & UV1cpa  ## copy/1d                       V[L] = X[R]
      subroutine UV1cpa
     M    (V,
     I     X,
     I     N,  L,  KVL, KXR)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KVL, KXR
      _INTENT(INOUT,_REALSTD) V (L, *)
      _INTENT(IN,   _REALSTD) X (L, *)
#if OPT_UVCLST_ARRAY_OPERATION
      V (1:N, KVL) = X (1:N, KXR)
#else
      integer j
      do j  = 1, N
         V (j, KVL) = X (j, KXR)
      enddo
#endif
      RETURN
      END
CCC_  & UV1cpc  ## copy/2d/0                      V[L] = X[R]
      subroutine UV1cpc
     M    (V,
     I     X,
     I     N,  L,  N2, L2, K2, KVL, KXR)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  N2,  L2, K2
      _INTENT(IN,   integer)  KVL, KXR
      _INTENT(INOUT,_REALSTD) V (L, L2, *)
      _INTENT(IN,   _REALSTD) X (L, L2, *)
#if OPT_UVCLST_ARRAY_OPERATION
      integer j2
      j2 = K2 + N2 - 1
      V (1:N, K2:j2, KVL) = X (1:N, K2:j2, KXR)
#else
      integer j, j2
      do    j2 = K2, K2 + N2 -1
         do j  = 1, N
            V (j, j2, KVL) = X (j, j2, KXR)
         enddo
      enddo
#endif
      RETURN
      END
CCC_  & UV1xta  ## extract/1d                    X[L] = V[R]
      subroutine UV1xta
     O    (X,
     I     V,
     I     N,  L,  KXL, KVR)
      implicit none
      _INTENT(IN, integer)  N,   L
      _INTENT(IN, integer)  KXL, KVR
      _INTENT(IN, _REALSTD) V (L, *)
      _INTENT(OUT,_REALSTD) X (L, *)
#if OPT_UVCLST_ARRAY_OPERATION
      X (1:N, KXL) = V (1:N, KVR)
#else
      integer j
      do j  = 1, N
         X (j, KXL) = V (j, KVR)
      enddo
#endif
      RETURN
      END
CCC_* [UV2] manipulation 1 external 2 id (V, X (1,2))
CCC_ + new
CCC_  & UV2naa  ## new/addition/1d               V[L] = X[R1] + X[R2]
      subroutine UV2naa
     M    (V,
     I     X,
     I     N,  L,  KVL, KXR1, KXR2)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KVL, KXR1, KXR2
      _INTENT(INOUT,_REALSTD) V (L, *)
      _INTENT(IN,   _REALSTD) X (L, *)
#if OPT_UVCLST_ARRAY_OPERATION
      V (1:N, KVL) = X (1:N, KXR1) + X (1:N, KXR2)
#else
      integer j
      do j  = 1, N
         V (j, KVL) = X (j, KXR1) + X (j, KXR2)
      enddo
#endif
      RETURN
      END
CCC_  & UV2nac  ## new/addition/2d/0             V[L] = X[R1] + X[R2]
      subroutine UV2nac
     M    (V,
     I     X,
     I     N,  L,  N2, L2, K2, KVL, KXR1, KXR2)
      implicit none
      _INTENT(IN,   integer)  N,   L, N2, L2, K2
      _INTENT(IN,   integer)  KVL, KXR1,  KXR2
      _INTENT(INOUT,_REALSTD) V (L, L2, *)
      _INTENT(IN,   _REALSTD) X (L, L2, *)
#if OPT_UVCLST_ARRAY_OPERATION
      integer j2
      j2 = K2 + N2 - 1
      V (1:N, K2:j2, KVL) = X (1:N, K2:j2, KXR1) + X (1:N, K2:j2, KXR2)
#else
      integer j, j2
      do    j2 = K2, K2 + N2 - 1
         do j  = 1, N
            V (j, j2, KVL) = X (j, j2, KXR1) + X (j, j2, KXR2)
         enddo
      enddo
#endif
      RETURN
      END
CCC_  & UV2nda  ## new/division/1d               V[L] = X[R1] / X[R2]
      subroutine UV2nda
     M    (V,
     I     X,
     I     N,  L,  KVL, KXR1, KXR2)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KVL, KXR1, KXR2
      _INTENT(INOUT,_REALSTD) V (L, *)
      _INTENT(IN,   _REALSTD) X (L, *)
#if OPT_UVCLST_ARRAY_OPERATION
      V (1:N, KVL) = X (1:N, KXR1) / X (1:N, KXR2)
#else
      integer j
      do j  = 1, N
         V (j, KVL) = X (j, KXR1) / X (j, KXR2)
      enddo
#endif
      RETURN
      END
CCC_  & UV2nfa  ## new/addition (factor)/1d       V[L] = X[R1] + f X[R2]
      subroutine UV2nfa
     M    (V,
     I     X,
     I     N,  L,  KVL, KXR1, KXR2, F)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KVL, KXR1, KXR2
      _INTENT(INOUT,_REALSTD) V (L, *)
      _INTENT(IN,   _REALSTD) X (L, *)
      _INTENT(IN,   _REALSTD) F
#if OPT_UVCLST_ARRAY_OPERATION
      V (1:N, KVL) = X (1:N, KXR1) + F * X (1:N, KXR2)
#else
      integer j
      do j  = 1, N
         V (j, KVL) = X (j, KXR1) + F * X (j, KXR2)
      enddo
#endif
      RETURN
      END
CCC_  & UV2nga  ## new/addition (factors)/1d       V[L] = f1 X[R1] + f2 X[R2]
      subroutine UV2nga
     M    (V,
     I     X,
     I     N,  L,  KVL, KXR1, KXR2, F1, F2)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KVL, KXR1, KXR2
      _INTENT(INOUT,_REALSTD) V (L, *)
      _INTENT(IN,   _REALSTD) X (L, *)
      _INTENT(IN,   _REALSTD) F1, F2
#if OPT_UVCLST_ARRAY_OPERATION
      V (1:N, KVL) = F1 * X (1:N, KXR1) + F2 * X (1:N, KXR2)
#else
      integer j
      do j  = 1, N
         V (j, KVL) = F1 * X (j, KXR1) + F2 * X (j, KXR2)
      enddo
#endif
      RETURN
      END
CCC_  & UV2nha  ## new/magnitude/1d         V[L] = sqrt(X[R1]^2+X[R2]^2)
      subroutine UV2nha
     M    (V,
     I     X,
     I     N,  L,  KVL, KXR1, KXR2)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KVL, KXR1, KXR2
      _INTENT(INOUT,_REALSTD) V (L, *)
      _INTENT(IN,   _REALSTD) X (L, *)
#if OPT_UVCLST_ARRAY_OPERATION
      V (1:N, KVL) =
     $     SQRT (X (1:N, KXR1) * X (1:N, KXR1)
     $         + X (1:N, KXR2) * X (1:N, KXR2))
#else
      integer j
      do j  = 1, N
         V (j, KVL) =
     $        SQRT (X (j, KXR1) * X (j, KXR1)
     $             + X (j, KXR2) * X (j, KXR2))
      enddo
#endif
      RETURN
      END
CCC_  & UV2nma  ## new/multiplication/1d         V[L] = X[R1] * X[R2]
      subroutine UV2nma
     M    (V,
     I     X,
     I     N,  L,  KVL, KXR1, KXR2)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KVL, KXR1, KXR2
      _INTENT(INOUT,_REALSTD) V (L, *)
      _INTENT(IN,   _REALSTD) X (L, *)
#if OPT_UVCLST_ARRAY_OPERATION
      V (1:N, KVL) = X (1:N, KXR1) * X (1:N, KXR2)
#else
      integer j
      do j  = 1, N
         V (j, KVL) = X (j, KXR1) * X (j, KXR2)
      enddo
#endif
      RETURN
      END
CCC_  & UV2nsa  ## new/subtraction/1d            V[L] = X[R1] - X[R2]
      subroutine UV2nsa
     M    (V,
     I     X,
     I     N,  L,  KVL, KXR1, KXR2)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KVL, KXR1, KXR2
      _INTENT(INOUT,_REALSTD) V (L, *)
      _INTENT(IN,   _REALSTD) X (L, *)
#if OPT_UVCLST_ARRAY_OPERATION
      V (1:N, KVL) = X (1:N, KXR1) - X (1:N, KXR2)
#else
      integer j
      do j  = 1, N
         V (j, KVL) = X (j, KXR1) - X (j, KXR2)
      enddo
#endif
      RETURN
      END
CCC_  & UV2nsc  ## new/subroutine/2d/0            V[L] = X[R1] - X[R2]
      subroutine UV2nsc
     M    (V,
     I     X,
     I     N,  L,  N2, L2, K2, KVL, KXR1, KXR2)
      implicit none
      _INTENT(IN,   integer)  N,   L, N2, L2, K2
      _INTENT(IN,   integer)  KVL, KXR1,  KXR2
      _INTENT(INOUT,_REALSTD) V (L, L2, *)
      _INTENT(IN,   _REALSTD) X (L, L2, *)
#if OPT_UVCLST_ARRAY_OPERATION
      integer j2
      j2 = K2 + N2 - 1
      V (1:N, K2:j2, KVL) = X (1:N, K2:j2, KXR1) - X (1:N, K2:j2, KXR2)
#else
      integer j, j2
      do    j2 = K2, K2 + N2 - 1
         do j  = 1, N
            V (j, j2, KVL) = X (j, j2, KXR1) - X (j, j2, KXR2)
         enddo
      enddo
#endif
      RETURN
      END
CCC_  & UV2nva  ## new/average/1d               V[L] = (X[R1] + X[R2])/2
      subroutine UV2nva
     M    (V,
     I     X,
     I     N,  L,  KVL, KXR1, KXR2)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KVL, KXR1, KXR2
      _INTENT(INOUT,_REALSTD) V (L, *)
      _INTENT(IN,   _REALSTD) X (L, *)
#if OPT_UVCLST_ARRAY_OPERATION
      V (1:N, KVL) = (X (1:N, KXR1) + X (1:N, KXR2)) * 0.5d0
#else
      integer j
      do j  = 1, N
         V (j, KVL) = (X (j, KXR1) + X (j, KXR2)) * 0.5d0
      enddo
#endif
      RETURN
      END
CCC_* [UV3] manipulation 2 external (V, X1, X2)
CCC_ + new
CCC_  & UV3naa  ## new/addition/1d               V[L] = X1[R1] + X2[R2]
      subroutine UV3naa
     M    (V,
     I     X1, X2,
     I     N,  L,  KVL, KXR1, KXR2)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KVL, KXR1, KXR2
      _INTENT(INOUT,_REALSTD) V  (L, *)
      _INTENT(IN,   _REALSTD) X1 (L, *), X2 (L, *)
#if OPT_UVCLST_ARRAY_OPERATION
      V (1:N, KVL) = X1 (1:N, KXR1) + X2 (1:N, KXR2)
#else
      integer j
      do j  = 1, N
         V (j, KVL) = X1 (j, KXR1) + X2 (j, KXR2)
      enddo
#endif
      RETURN
      END
CCC_  & UV3nca  ## new/multipl.compl./1d         V[L] = X2[R2] * (C-X1[R1])
      subroutine UV3nca
     M    (V,
     I     X1, X2,
     I     N,  L,  KVL, KXR1, KXR2, C)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KVL, KXR1, KXR2
      _INTENT(INOUT,_REALSTD) V  (L, *)
      _INTENT(IN,   _REALSTD) X1 (L, *), X2 (L, *)
      _INTENT(IN,   _REALSTD) C
#if OPT_UVCLST_ARRAY_OPERATION
      V (1:N, KVL) = (C - X1 (1:N, KXR1)) * X2 (1:N, KXR2)
#else
      integer j
      do j  = 1, N
         V (j, KVL) = (C - X1 (j, KXR1)) * X2 (j, KXR2)
      enddo
#endif
      RETURN
      END
CCC_  & UV3nda  ## new/division/1d               V[L] = X1[R1] / X2[R2]
      subroutine UV3nda
     M    (V,
     I     X1, X2,
     I     N,  L,  KVL, KXR1, KXR2)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KVL, KXR1, KXR2
      _INTENT(INOUT,_REALSTD) V  (L, *)
      _INTENT(IN,   _REALSTD) X1 (L, *), X2 (L, *)
#if OPT_UVCLST_ARRAY_OPERATION
      V (1:N, KVL) = X1 (1:N, KXR1) / X2 (1:N, KXR2)
#else
      integer j
      do j  = 1, N
         V (j, KVL) = X1 (j, KXR1) / X2 (j, KXR2)
      enddo
#endif
      RETURN
      END
CCC_  & UV3nma  ## new/multiplication/1d         V[L] = X1[R1] * X2[R2]
      subroutine UV3nma
     M    (V,
     I     X1, X2,
     I     N,  L,  KVL, KXR1, KXR2)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KVL, KXR1, KXR2
      _INTENT(INOUT,_REALSTD) V  (L, *)
      _INTENT(IN,   _REALSTD) X1 (L, *), X2 (L, *)
#if OPT_UVCLST_ARRAY_OPERATION
      V (1:N, KVL) = X1 (1:N, KXR1) * X2 (1:N, KXR2)
#else
      integer j
      do j  = 1, N
         V (j, KVL) = X1 (j, KXR1) * X2 (j, KXR2)
      enddo
#endif
      RETURN
      END
CCC_  & UV3nsa  ## new/subtraction/1d            V[L] = X1[R1] - X2[R2]
      subroutine UV3nsa
     M    (V,
     I     X1, X2,
     I     N,  L,  KVL, KXR1, KXR2)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KVL, KXR1, KXR2
      _INTENT(INOUT,_REALSTD) V  (L, *)
      _INTENT(IN,   _REALSTD) X1 (L, *), X2 (L, *)
#if OPT_UVCLST_ARRAY_OPERATION
      V (1:N, KVL) = X1 (1:N, KXR1) - X2 (1:N, KXR2)
#else
      integer j
      do j  = 1, N
         V (j, KVL) = X1 (j, KXR1) - X2 (j, KXR2)
      enddo
#endif
      RETURN
      END
c$$$CCC_  & UV3nso  ## new/subtraction/3d
c$$$      subroutine UV3nso
c$$$     M    (V,
c$$$     I     X1, X2,
c$$$     I     N,  L,  NV, LV, KVL, KXR1, KXR2)
c$$$      implicit none
c$$$      _INTENT(IN,   integer)  N,   L
c$$$      _INTENT(IN,   integer)  NV,  LV
c$$$      _INTENT(IN,   integer)  KVL, KXR1, KXR2
c$$$      _INTENT(INOUT,_REALSTD) V  (L, LV, *)
c$$$      _INTENT(IN,   _REALSTD) X1 (L, LV, *), X2 (L, LV, *)
c$$$      integer j, jv
c$$$      do jv = 1, NV
c$$$         do j  = 1, N
c$$$            V (j, KVL, jv) = X1 (j, KXR1, jv) - X2 (j, KXR2, jv)
c$$$         enddo
c$$$      enddo
c$$$      RETURN
c$$$      END
CCC_  & UV3nua  ## new/division or undef/1d  V[L] = X1[R1] / X2[R2]
      subroutine UV3nua
     M    (V,
     I     X1, X2,
     I     N,  L,  KVL, KXR1, KXR2, UD)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KVL, KXR1, KXR2
      _INTENT(INOUT,_REALSTD) V  (L, *)
      _INTENT(IN,   _REALSTD) X1 (L, *), X2 (L, *)
      _INTENT(IN,   _REALSTD) UD
#if OPT_UVCLST_ARRAY_OPERATION
      WHERE (X2 (1:N, KXR2).eq.0.0d0)
         V (1:N, KVL) = UD
      ELSEWHERE
         V (1:N, KVL) = X1 (1:N, KXR1) / X2 (1:N, KXR2)
      END WHERE
#else
      integer j
      do j  = 1, N
         if (X2 (j, KXR2).eq.0.0d0) then
            V (j, KVL) = UD
         else
            V (j, KVL) = X1 (j, KXR1) / X2 (j, KXR2)
         endif
      enddo
#endif
      RETURN
      END
CCC_* TEST
CCC_ + begin
#if TEST_UVCLST
CCC_ @ UVTEST  ## cluster operation test (especially for optimization)
      program UVTEST
CCC_  - Test suites
CC::   SOURCES udbgst.F
CCC_  - Declaration
#define CLOCK_GROUP_ON_UVCLST 1
#include "oclock.h"
      implicit none
      integer    LHref
      parameter (LHref = 131072)
      integer    LVref
      parameter (LVref = 72)
      integer    LHV
      parameter (LHV   = LHref * LVref)
      _REALSTD  A0 (LHV), D0, C0
      _REALSTD  A1 (LHV), D1, C1
      _REALSTD  A2 (LHV), D2, C2
      _REALSTD  A3 (LHV), D3, C3
      _REALSTD  A4 (LHV), D4, C4
      integer   K0, K1, K2, K3, K4
      integer   NP, LP
      integer   MX
c
      integer   ITEST, IFP
#ifndef   MLOOP
#  define MLOOP 1000000
#endif
      integer   jedmy
CCC_  - Body
      IFP   = -1
      ITEST = 0
      call UDCLKC (jedmy)
c
      call UDTbni (ITEST, 'BEGIN', ' ', IFP)
c
      LP = 301 * 301
      NP = LP
      K0 = 2
      K1 = 3
      K2 = 5
      K3 = 7
      K4 = 9
      D0 = 100.0d0
      D1 = 1.0d0 / 3.0d0
      D2 = SQRT (10.0d0)
      D3 = ATAN2 (1.0d0, 1.0d0)
      D4 = -130.0d0
      C0 =  3.0d0
      C1 = -4.0d0
      C2 =  5.0d0
      C3 = -6.0d0
      C4 =  7.0d0
c
      MX = MLOOP
c
      call UDTbni (ITEST, 'SUB0', ' ', IFP)
      call UVTEST_sub0
     $     (A0, A1, K0, K1, D0, D1, NP, LP, MX, ITEST, IFP)
c
      call UDTbni (ITEST, 'SUB1', ' ', IFP)
      call UVTEST_sub1
     $     (A0, A1, A2, K0, K1, K2, D0, D1, D2, NP, LP, MX, ITEST, IFP)
c
      call UDTbni (ITEST, 'SUB2', ' ', IFP)
      call UVTEST_sub2
     $    (A0, A1, A2, A3, A4,
     $     K0, K1, K2, K3, K4,
     $     D0, D1, D2, D3, D4,
     $     NP, LP, MX, ITEST, IFP)
c
      call UDTbni (ITEST, 'SUB3', ' ', IFP)
      call UVTEST_sub3
     $    (A0, A1, A2, A3, A4,
     $     K0, K1, K2, K3, K4,
     $     D0, D1, D2, D3, D4,
     $     C0, C1, C2, C3, C4,
     $     NP, LP, MX, ITEST, IFP)
c
      call UDTbni (ITEST, 'FINE', ' ', IFP)
c
      call UDCrep (IFP)
      stop
      end
CCC_ & UVTEST_sub0  ## 2 arrays
      subroutine UVTEST_sub0
     $     (A0, A1, K0, K1, D0, D1, NP, LP, MX, ITEST, IFP)
      implicit none
      _INTENT(IN,   integer)  NP, LP, MX
      _INTENT(IN,   integer)  K0, K1
      _INTENT(IN,   _REALSTD) D0, D1
      _INTENT(OUT,  _REALSTD) A0 (LP, *)
      _INTENT(OUT,  _REALSTD) A1 (LP, *)
      _INTENT(INOUT,integer)  ITEST
      _INTENT(IN,   integer)  IFP
      integer ix, jp
      call UDTbni (ITEST, '00', ' ', IFP)
CCC_  - plain/loop
      CLOCK_IK(UVCLST_PL0,'PlainLoop0',UVCLST)
      do ix = 1, mx
         call UV0sta  (A0,     NP, LP, K0, D0)
         call UV0sta  (A1,     NP, LP, K1, D1)
         do jp = 1, NP
            A0 (jp, K0) = A0 (jp, K0) * A1 (jp, K1)
         enddo
      enddo
      CLOCK_OK(UVCLST_PL0,'PlainLoop0',UVCLST)
CCC_  - plain/array
      CLOCK_IK(UVCLST_PA0,'PlainArray0',UVCLST)
      do ix = 1, mx
         call UV0sta  (A0,     NP, LP, K0, D0)
         call UV0sta  (A1,     NP, LP, K1, D1)
         A0 (1:NP, K0) = A0 (1:NP, K0) * A1 (1:NP, K1)
      enddo
      CLOCK_OK(UVCLST_PA0,'PlainArray0',UVCLST)
CCC_  - no expansion/loop
!CDIR NOIEXPAND(UV1UMAL0)
      CLOCK_IK(UVCLST_SL0,'SubLoop0',UVCLST)
      do ix = 1, mx
         call UV0sta   (A0,     NP, LP, K0, D0)
         call UV0sta   (A1,     NP, LP, K1, D1)
         call UV1umaL0 (A0, A1, NP, LP, K0, K1)
      enddo
      CLOCK_OK(UVCLST_SL0,'SubLoop0',UVCLST)
CCC_  - no expansion/array
!CDIR NOIEXPAND(UV1UMAA0)
      CLOCK_IK(UVCLST_SA0,'SubArray0',UVCLST)
      do ix = 1, mx
         call UV0sta   (A0,     NP, LP, K0, D0)
         call UV0sta   (A1,     NP, LP, K1, D1)
         call UV1umaA0 (A0, A1, NP, LP, K0, K1)
      enddo
      CLOCK_OK(UVCLST_SA0,'SubArray0',UVCLST)
CCC_  - inline expansion/loop
!CDIR IEXPAND(UV1UMAL1)
      CLOCK_IK(UVCLST_XL0,'XLoop0',UVCLST)
      do ix = 1, mx
         call UV0sta   (A0,     NP, LP, K0, D0)
         call UV0sta   (A1,     NP, LP, K1, D1)
         call UV1umaL1 (A0, A1, NP, LP, K0, K1)
      enddo
      CLOCK_OK(UVCLST_XL0,'XLoop0',UVCLST)
CCC_  - inline expansion/array
!CDIR IEXPAND(UV1UMAA1)
      CLOCK_IK(UVCLST_XA0,'XArray0',UVCLST)
      do ix = 1, mx
         call UV0sta   (A0,     NP, LP, K0, D0)
         call UV0sta   (A1,     NP, LP, K1, D1)
         call UV1umaA1 (A0, A1, NP, LP, K0, K1)
      enddo
      CLOCK_OK(UVCLST_XA0,'XArray0',UVCLST)
CCC_  - end
      call UDTbni (ITEST, '09', ' ', IFP)
      RETURN
      END
CCC_ & UVTEST_sub1  ## 3 arrays
      subroutine UVTEST_sub1
     $     (A0, A1, A2, K0, K1, K2, D0, D1, D2, NP, LP, MX, ITEST, IFP)
      implicit none
      _INTENT(IN,   integer)  NP, LP, MX
      _INTENT(IN,   integer)  K0, K1, K2
      _INTENT(IN,   _REALSTD) D0, D1, D2
      _INTENT(OUT,  _REALSTD) A0 (LP, *)
      _INTENT(OUT,  _REALSTD) A1 (LP, *)
      _INTENT(OUT,  _REALSTD) A2 (LP, *)
      _INTENT(INOUT,integer)  ITEST
      _INTENT(IN,   integer)  IFP
      integer ix, jp
      call UDTbni (ITEST, '00', ' ', IFP)
CCC_  - plain/loop/div
      CLOCK_IK(UVCLST_PLD1,'PlainLoopDiv1',UVCLST)
      do ix = 1, mx
         call UV0sta (A0,     NP, LP, K0, D0)
         call UV0sta (A1,     NP, LP, K1, D1)
         call UV0sta (A2,     NP, LP, K2, D2)
         do jp = 1, NP
            A1 (jp, K1) = A1 (jp, K1) * A2 (jp, K2)
         enddo
         do jp = 1, NP
            A0 (jp, K0) = A0 (jp, K0) * A1 (jp, K1)
         enddo
      enddo
      CLOCK_OK(UVCLST_PLD1,'PlainLoopDiv1',UVCLST)
CCC_  - plain/loop/div
      CLOCK_IK(UVCLST_PLF1,'PlainLoopFuse1',UVCLST)
      do ix = 1, mx
         call UV0sta (A0,     NP, LP, K0, D0)
         call UV0sta (A1,     NP, LP, K1, D1)
         call UV0sta (A2,     NP, LP, K2, D2)
         do jp = 1, NP
            A1 (jp, K1) = A1 (jp, K1) * A2 (jp, K2)
            A0 (jp, K0) = A0 (jp, K0) * A1 (jp, K1)
         enddo
      enddo
      CLOCK_OK(UVCLST_PLF1,'PlainLoopFuse1',UVCLST)
CCC_  - plain/array
      CLOCK_IK(UVCLST_PA1,'PlainArray1',UVCLST)
      do ix = 1, mx
         call UV0sta (A0,     NP, LP, K0, D0)
         call UV0sta (A1,     NP, LP, K1, D1)
         call UV0sta (A2,     NP, LP, K2, D2)
         A1 (1:NP, K1) = A1 (1:NP, K1) * A2 (1:NP, K2)
         A0 (1:NP, K0) = A0 (1:NP, K0) * A1 (1:NP, K1)
      enddo
      CLOCK_OK(UVCLST_PA1,'PlainArray1',UVCLST)
CCC_  - no expansion/loop
!CDIR NOIEXPAND(UV1UMAL0)
      CLOCK_IK(UVCLST_SL1,'SubLoop1',UVCLST)
      do ix = 1, mx
         call UV0sta   (A0,     NP, LP, K0, D0)
         call UV0sta   (A1,     NP, LP, K1, D1)
         call UV0sta   (A2,     NP, LP, K2, D2)
         call UV1umaL0 (A1, A2, NP, LP, K1, K2)
         call UV1umaL0 (A0, A1, NP, LP, K0, K1)
      enddo
      CLOCK_OK(UVCLST_SL1,'SubLoop1',UVCLST)
CCC_  - no expansion/array
!CDIR NOIEXPAND(UV1UMAA0)
      CLOCK_IK(UVCLST_SA1,'SubArray1',UVCLST)
      do ix = 1, mx
         call UV0sta   (A0,     NP, LP, K0, D0)
         call UV0sta   (A1,     NP, LP, K1, D1)
         call UV0sta   (A2,     NP, LP, K2, D2)
         call UV1umaA0 (A1, A2, NP, LP, K1, K2)
         call UV1umaA0 (A0, A1, NP, LP, K0, K1)
      enddo
      CLOCK_OK(UVCLST_SA1,'SubArray1',UVCLST)
CCC_  - inline expansion/loop
!CDIR IEXPAND(UV1UMAL1)
      CLOCK_IK(UVCLST_XL1,'XLoop1',UVCLST)
      do ix = 1, mx
         call UV0sta   (A0,     NP, LP, K0, D0)
         call UV0sta   (A1,     NP, LP, K1, D1)
         call UV0sta   (A2,     NP, LP, K2, D2)
         call UV1umaL1 (A1, A2, NP, LP, K1, K2)
         call UV1umaL1 (A0, A1, NP, LP, K0, K1)
      enddo
      CLOCK_OK(UVCLST_XL1,'XLoop1',UVCLST)
CCC_  - inline expansion/array
!CDIR IEXPAND(UV1UMAA1)
      CLOCK_IK(UVCLST_XA1,'XArray1',UVCLST)
      do ix = 1, mx
         call UV0sta   (A0,     NP, LP, K0, D0)
         call UV0sta   (A1,     NP, LP, K1, D1)
         call UV0sta   (A2,     NP, LP, K2, D2)
         call UV1umaA1 (A1, A2, NP, LP, K1, K2)
         call UV1umaA1 (A0, A1, NP, LP, K0, K1)
      enddo
      CLOCK_OK(UVCLST_XA1,'XArray1',UVCLST)
CCC_  - inline expansion/loop
!CDIR NEXPAND(UV1UMAL2)
      CLOCK_IK(UVCLST_NXL1,'NXLoop1',UVCLST)
      do ix = 1, mx
         call UV0sta   (A0,     NP, LP, K0, D0)
         call UV0sta   (A1,     NP, LP, K1, D1)
         call UV0sta   (A2,     NP, LP, K2, D2)
         call UV1umaL2 (A1, A2, NP, LP, K1, K2)
         call UV1umaL2 (A0, A1, NP, LP, K0, K1)
      enddo
      CLOCK_OK(UVCLST_NXL1,'NXLoop1',UVCLST)
CCC_  - inline expansion/array
!CDIR IEXPAND(UV1UMAA2)
      CLOCK_IK(UVCLST_NXA1,'NXArray1',UVCLST)
      do ix = 1, mx
         call UV0sta   (A0,     NP, LP, K0, D0)
         call UV0sta   (A1,     NP, LP, K1, D1)
         call UV0sta   (A2,     NP, LP, K2, D2)
         call UV1umaA2 (A1, A2, NP, LP, K1, K2)
         call UV1umaA2 (A0, A1, NP, LP, K0, K1)
      enddo
      CLOCK_OK(UVCLST_NXA1,'NXArray1',UVCLST)
CCC_  - end
      call UDTbni (ITEST, '09', ' ', IFP)
      RETURN
      END
CCC_ & UVTEST_sub2  ## 5 arrays
      subroutine UVTEST_sub2
     $    (A0, A1, A2, A3, A4,
     $     K0, K1, K2, K3, K4,
     $     D0, D1, D2, D3, D4, NP, LP, MX, ITEST, IFP)
      implicit none
      _INTENT(IN,   integer)  NP, LP, MX
      _INTENT(IN,   integer)  K0, K1, K2, K3, K4
      _INTENT(IN,   _REALSTD) D0, D1, D2, D3, D4
      _INTENT(OUT,  _REALSTD) A0 (LP, *)
      _INTENT(OUT,  _REALSTD) A1 (LP, *)
      _INTENT(OUT,  _REALSTD) A2 (LP, *)
      _INTENT(OUT,  _REALSTD) A3 (LP, *)
      _INTENT(OUT,  _REALSTD) A4 (LP, *)
      _INTENT(INOUT,integer)  ITEST
      _INTENT(IN,   integer)  IFP
      integer ix, jp
      call UDTbni (ITEST, '00', ' ', IFP)
CCC_  - plain/loop/div
      CLOCK_IK(UVCLST_PLD2,'PlainLoopDiv2',UVCLST)
      do ix = 1, mx
         call UV0sta (A0,     NP, LP, K0, D0)
         call UV0sta (A1,     NP, LP, K1, D1)
         call UV0sta (A2,     NP, LP, K2, D2)
         call UV0sta (A3,     NP, LP, K3, D3)
         call UV0sta (A4,     NP, LP, K4, D4)
         do jp = 1, NP
            A3 (jp, K3) = A3 (jp, K3) * A4 (jp, K4)
         enddo
         do jp = 1, NP
            A2 (jp, K2) = A2 (jp, K2) * A3 (jp, K3)
         enddo
         do jp = 1, NP
            A1 (jp, K1) = A1 (jp, K1) * A2 (jp, K2)
         enddo
         do jp = 1, NP
            A0 (jp, K0) = A0 (jp, K0) * A1 (jp, K1)
         enddo
      enddo
      CLOCK_OK(UVCLST_PLD2,'PlainLoopDiv2',UVCLST)
CCC_  - plain/loop/div
      CLOCK_IK(UVCLST_PLF2,'PlainLoopFuse2',UVCLST)
      do ix = 1, mx
         call UV0sta (A0,     NP, LP, K0, D0)
         call UV0sta (A1,     NP, LP, K1, D1)
         call UV0sta (A2,     NP, LP, K2, D2)
         call UV0sta (A3,     NP, LP, K3, D3)
         call UV0sta (A4,     NP, LP, K4, D4)
         do jp = 1, NP
            A3 (jp, K3) = A3 (jp, K3) * A4 (jp, K4)
            A2 (jp, K2) = A2 (jp, K2) * A3 (jp, K3)
            A1 (jp, K1) = A1 (jp, K1) * A2 (jp, K2)
            A0 (jp, K0) = A0 (jp, K0) * A1 (jp, K1)
         enddo
      enddo
      CLOCK_OK(UVCLST_PLF2,'PlainLoopFuse2',UVCLST)
CCC_  - plain/array
      CLOCK_IK(UVCLST_PA2,'PlainArray2',UVCLST)
      do ix = 1, mx
         call UV0sta (A0,     NP, LP, K0, D0)
         call UV0sta (A1,     NP, LP, K1, D1)
         call UV0sta (A2,     NP, LP, K2, D2)
         call UV0sta (A3,     NP, LP, K3, D3)
         call UV0sta (A4,     NP, LP, K4, D4)
         A3 (1:NP, K3) = A3 (1:NP, K3) * A4 (1:NP, K4)
         A2 (1:NP, K2) = A2 (1:NP, K2) * A3 (1:NP, K3)
         A1 (1:NP, K1) = A1 (1:NP, K1) * A2 (1:NP, K2)
         A0 (1:NP, K0) = A0 (1:NP, K0) * A1 (1:NP, K1)
      enddo
      CLOCK_OK(UVCLST_PA2,'PlainArray2',UVCLST)
CCC_  - no expansion/loop
!CDIR NOIEXPAND(UV1UMAL0)
      CLOCK_IK(UVCLST_SL2,'SubLoop2',UVCLST)
      do ix = 1, mx
         call UV0sta   (A0,     NP, LP, K0, D0)
         call UV0sta   (A1,     NP, LP, K1, D1)
         call UV0sta   (A2,     NP, LP, K2, D2)
         call UV0sta   (A3,     NP, LP, K3, D3)
         call UV0sta   (A4,     NP, LP, K4, D4)
         call UV1umaL0 (A3, A4, NP, LP, K3, K4)
         call UV1umaL0 (A2, A3, NP, LP, K2, K3)
         call UV1umaL0 (A1, A2, NP, LP, K1, K2)
         call UV1umaL0 (A0, A1, NP, LP, K0, K1)
      enddo
      CLOCK_OK(UVCLST_SL2,'SubLoop2',UVCLST)
CCC_  - no expansion/array
!CDIR NOIEXPAND(UV1UMAA0)
      CLOCK_IK(UVCLST_SA2,'SubArray2',UVCLST)
      do ix = 1, mx
         call UV0sta   (A0,     NP, LP, K0, D0)
         call UV0sta   (A1,     NP, LP, K1, D1)
         call UV0sta   (A2,     NP, LP, K2, D2)
         call UV0sta   (A3,     NP, LP, K3, D3)
         call UV0sta   (A4,     NP, LP, K4, D4)
         call UV1umaA0 (A3, A4, NP, LP, K3, K4)
         call UV1umaA0 (A2, A3, NP, LP, K2, K3)
         call UV1umaA0 (A1, A2, NP, LP, K1, K2)
         call UV1umaA0 (A0, A1, NP, LP, K0, K1)
      enddo
      CLOCK_OK(UVCLST_SA2,'SubArray2',UVCLST)
CCC_  - inline expansion/loop
!CDIR IEXPAND(UV1UMAL1)
      CLOCK_IK(UVCLST_XL2,'XLoop2',UVCLST)
      do ix = 1, mx
         call UV0sta   (A0,     NP, LP, K0, D0)
         call UV0sta   (A1,     NP, LP, K1, D1)
         call UV0sta   (A2,     NP, LP, K2, D2)
         call UV0sta   (A3,     NP, LP, K3, D3)
         call UV0sta   (A4,     NP, LP, K4, D4)
         call UV1umaL1 (A3, A4, NP, LP, K3, K4)
         call UV1umaL1 (A2, A3, NP, LP, K2, K3)
         call UV1umaL1 (A1, A2, NP, LP, K1, K2)
         call UV1umaL1 (A0, A1, NP, LP, K0, K1)
      enddo
      CLOCK_OK(UVCLST_XL2,'XLoop2',UVCLST)
CCC_  - inline expansion/array
!CDIR IEXPAND(UV1UMAA1)
      CLOCK_IK(UVCLST_XA2,'XArray2',UVCLST)
      do ix = 1, mx
         call UV0sta   (A0,     NP, LP, K0, D0)
         call UV0sta   (A1,     NP, LP, K1, D1)
         call UV0sta   (A2,     NP, LP, K2, D2)
         call UV0sta   (A3,     NP, LP, K3, D3)
         call UV0sta   (A4,     NP, LP, K4, D4)
         call UV1umaA1 (A3, A4, NP, LP, K3, K4)
         call UV1umaA1 (A2, A3, NP, LP, K2, K3)
         call UV1umaA1 (A1, A2, NP, LP, K1, K2)
         call UV1umaA1 (A0, A1, NP, LP, K0, K1)
      enddo
      CLOCK_OK(UVCLST_XA2,'XArray2',UVCLST)
CCC_  - inline expansion/loop
!CDIR NEXPAND(UV1UMAL2)
      CLOCK_IK(UVCLST_NXL2,'NXLoop2',UVCLST)
      do ix = 1, mx
         call UV0sta   (A0,     NP, LP, K0, D0)
         call UV0sta   (A1,     NP, LP, K1, D1)
         call UV0sta   (A2,     NP, LP, K2, D2)
         call UV0sta   (A3,     NP, LP, K3, D3)
         call UV0sta   (A4,     NP, LP, K4, D4)
         call UV1umaL2 (A3, A4, NP, LP, K3, K4)
         call UV1umaL2 (A2, A3, NP, LP, K2, K3)
         call UV1umaL2 (A1, A2, NP, LP, K1, K2)
         call UV1umaL2 (A0, A1, NP, LP, K0, K1)
      enddo
      CLOCK_OK(UVCLST_NXL2,'NXLoop2',UVCLST)
CCC_  - inline expansion/array
!CDIR NEXPAND(UV1UMAA2)
      CLOCK_IK(UVCLST_NXA2,'NXArray2',UVCLST)
      do ix = 1, mx
         call UV0sta   (A0,     NP, LP, K0, D0)
         call UV0sta   (A1,     NP, LP, K1, D1)
         call UV0sta   (A2,     NP, LP, K2, D2)
         call UV0sta   (A3,     NP, LP, K3, D3)
         call UV0sta   (A4,     NP, LP, K4, D4)
         call UV1umaA2 (A3, A4, NP, LP, K3, K4)
         call UV1umaA2 (A2, A3, NP, LP, K2, K3)
         call UV1umaA2 (A1, A2, NP, LP, K1, K2)
         call UV1umaA2 (A0, A1, NP, LP, K0, K1)
      enddo
      CLOCK_OK(UVCLST_NXA2,'NXArray2',UVCLST)
CCC_  - end
      call UDTbni (ITEST, '09', ' ', IFP)
      RETURN
      END
CCC_ & UVTEST_sub3  ## 5 arrays and constants
#if   HAVE_CPP_F_CONCATENATION
#  define _CAT(V,I) V##I
#else
#  define _CAT(V,I) V/**/I
#endif
      subroutine UVTEST_sub3
     $    (A0, A1, A2, A3, A4,
     $     K0, K1, K2, K3, K4,
     $     D0, D1, D2, D3, D4,
     $     C0, C1, C2, C3, C4,
     $     NP, LP, MX, ITEST, IFP)
      implicit none
      _INTENT(IN,   integer)  NP, LP, MX
      _INTENT(IN,   integer)  K0, K1, K2, K3, K4
      _INTENT(IN,   _REALSTD) D0, D1, D2, D3, D4
      _INTENT(IN,   _REALSTD) C0, C1, C2, C3, C4
      _INTENT(OUT,  _REALSTD) A0 (LP, *)
      _INTENT(OUT,  _REALSTD) A1 (LP, *)
      _INTENT(OUT,  _REALSTD) A2 (LP, *)
      _INTENT(OUT,  _REALSTD) A3 (LP, *)
      _INTENT(OUT,  _REALSTD) A4 (LP, *)
      _INTENT(INOUT,integer)  ITEST
      _INTENT(IN,   integer)  IFP
      integer ix, jp
      _REALSTD F
CCC_  - body
      call UDTbni (ITEST, '00', ' ', IFP)
CCC_  - helper macro
#define OPR0(L,D,S) _CAT(A,D)(L,_CAT(K,D)) = _CAT(A,D)(L,_CAT(K,D)) * _CAT(A,S)(L,_CAT(K,S))
c$$$#define OPR1(L,D)   _CAT(A,D)(L,_CAT(K,D)) = _CAT(A,D)(L,_CAT(K,D)) * _CAT(C,D)
#define OPR1(L,D)   _CAT(A,D)(L,_CAT(K,D)) = _CAT(A,D)(L,_CAT(K,D)) * F
#define OPR2(D,S)   F = _CAT(C,D) * _CAT(C,S)
CCC_  - plain/loop/div
      CLOCK_IK(UVCLST_PLD3,'PlainLoopDiv3',UVCLST)
      do ix = 1, mx
         call UV0sta (A0,     NP, LP, K0, D0)
         call UV0sta (A1,     NP, LP, K1, D1)
         call UV0sta (A2,     NP, LP, K2, D2)
         call UV0sta (A3,     NP, LP, K3, D3)
         call UV0sta (A4,     NP, LP, K4, D4)
         do jp = 1, NP
            OPR0(jp,3,4)
         enddo
         OPR2(3,4)
         do jp = 1, NP
            OPR1(jp,3)
         enddo
         do jp = 1, NP
            OPR0(jp,2,3)
         enddo
         OPR2(2,3)
         do jp = 1, NP
            OPR1(jp,2)
         enddo
         do jp = 1, NP
            OPR0(jp,1,2)
         enddo
         OPR2(1,2)
         do jp = 1, NP
            OPR1(jp,1)
         enddo
         do jp = 1, NP
            OPR0(jp,0,1)
         enddo
         OPR2(0,1)
         do jp = 1, NP
            OPR1(jp,0)
         enddo
      enddo
      CLOCK_OK(UVCLST_PLD3,'PlainLoopDiv3',UVCLST)
CCC_  - plain/loop/div
      CLOCK_IK(UVCLST_PLF3,'PlainLoopFuse3',UVCLST)
      do ix = 1, mx
         call UV0sta (A0,     NP, LP, K0, D0)
         call UV0sta (A1,     NP, LP, K1, D1)
         call UV0sta (A2,     NP, LP, K2, D2)
         call UV0sta (A3,     NP, LP, K3, D3)
         call UV0sta (A4,     NP, LP, K4, D4)
         do jp = 1, NP
            OPR0(jp,3,4)
            OPR2(3,4)
            OPR1(jp,3)
            OPR0(jp,2,3)
            OPR2(2,3)
            OPR1(jp,2)
            OPR0(jp,1,2)
            OPR2(1,2)
            OPR1(jp,1)
            OPR0(jp,0,1)
            OPR2(0,1)
            OPR1(jp,0)
         enddo
      enddo
      CLOCK_OK(UVCLST_PLF3,'PlainLoopFuse3',UVCLST)
CCC_  - plain/array
      CLOCK_IK(UVCLST_PA3,'PlainArray3',UVCLST)
      do ix = 1, mx
         call UV0sta (A0,     NP, LP, K0, D0)
         call UV0sta (A1,     NP, LP, K1, D1)
         call UV0sta (A2,     NP, LP, K2, D2)
         call UV0sta (A3,     NP, LP, K3, D3)
         call UV0sta (A4,     NP, LP, K4, D4)
         OPR0(1:NP,3,4)
         OPR2(3,4)
         OPR1(1:NP,3)
         OPR0(1:NP,2,3)
         OPR2(2,3)
         OPR1(1:NP,2)
         OPR0(1:NP,1,2)
         OPR2(1,2)
         OPR1(1:NP,1)
         OPR0(1:NP,0,1)
         OPR2(0,1)
         OPR1(1:NP,0)
      enddo
      CLOCK_OK(UVCLST_PA3,'PlainArray3',UVCLST)
CCC_  - no expansion/loop
!CDIR NOIEXPAND(UV1UMAL0)
!CDIR NOIEXPAND(UV0UWAL0)
      CLOCK_IK(UVCLST_SL3,'SubLoop3',UVCLST)
      do ix = 1, mx
         call UV0sta   (A0,     NP, LP, K0, D0)
         call UV0sta   (A1,     NP, LP, K1, D1)
         call UV0sta   (A2,     NP, LP, K2, D2)
         call UV0sta   (A3,     NP, LP, K3, D3)
         call UV0sta   (A4,     NP, LP, K4, D4)
         call UV1umaL0 (A3, A4, NP, LP, K3, K4)
         OPR2(3,4)
         call UV0uwaL0 (A3,     NP, LP, K3, F)
         call UV1umaL0 (A2, A3, NP, LP, K2, K3)
         OPR2(3,4)
         call UV0uwaL0 (A2,     NP, LP, K2, F)
         call UV1umaL0 (A1, A2, NP, LP, K1, K2)
         OPR2(3,4)
         call UV0uwaL0 (A1,     NP, LP, K1, F)
         call UV1umaL0 (A0, A1, NP, LP, K0, K1)
         OPR2(3,4)
         call UV0uwaL0 (A0,     NP, LP, K0, F)
      enddo
      CLOCK_OK(UVCLST_SL3,'SubLoop3',UVCLST)
CCC_  - no expansion/array
!CDIR NOIEXPAND(UV1UMAA0)
!CDIR NOIEXPAND(UV0UWAA0)
      CLOCK_IK(UVCLST_SA3,'SubArray3',UVCLST)
      do ix = 1, mx
         call UV0sta   (A0,     NP, LP, K0, D0)
         call UV0sta   (A1,     NP, LP, K1, D1)
         call UV0sta   (A2,     NP, LP, K2, D2)
         call UV0sta   (A3,     NP, LP, K3, D3)
         call UV0sta   (A4,     NP, LP, K4, D4)
         call UV1umaA0 (A3, A4, NP, LP, K3, K4)
         OPR2(3,4)
         call UV0uwaA0 (A3,     NP, LP, K3, F)
         call UV1umaA0 (A2, A3, NP, LP, K2, K3)
         OPR2(3,4)
         call UV0uwaA0 (A2,     NP, LP, K2, F)
         call UV1umaA0 (A1, A2, NP, LP, K1, K2)
         OPR2(3,4)
         call UV0uwaA0 (A1,     NP, LP, K1, F)
         call UV1umaA0 (A0, A1, NP, LP, K0, K1)
         OPR2(3,4)
         call UV0uwaA0 (A0,     NP, LP, K0, F)
      enddo
      CLOCK_OK(UVCLST_SA3,'SubArray3',UVCLST)
CCC_  - inline expansion/loop
!CDIR IEXPAND(UV1UMAL1)
!CDIR IEXPAND(UV0UWAL1)
      CLOCK_IK(UVCLST_XL3,'XLoop3',UVCLST)
      do ix = 1, mx
         call UV0sta   (A0,     NP, LP, K0, D0)
         call UV0sta   (A1,     NP, LP, K1, D1)
         call UV0sta   (A2,     NP, LP, K2, D2)
         call UV0sta   (A3,     NP, LP, K3, D3)
         call UV0sta   (A4,     NP, LP, K4, D4)
         call UV1umaL1 (A3, A4, NP, LP, K3, K4)
         OPR2(3,4)
         call UV0uwaL1 (A3,     NP, LP, K3, F)
         call UV1umaL1 (A2, A3, NP, LP, K2, K3)
         OPR2(3,4)
         call UV0uwaL1 (A2,     NP, LP, K2, F)
         call UV1umaL1 (A1, A2, NP, LP, K1, K2)
         OPR2(3,4)
         call UV0uwaL1 (A1,     NP, LP, K1, F)
         call UV1umaL1 (A0, A1, NP, LP, K0, K1)
         OPR2(3,4)
         call UV0uwaL1 (A0,     NP, LP, K0, F)
      enddo
      CLOCK_OK(UVCLST_XL3,'XLoop3',UVCLST)
CCC_  - inline expansion/array
!CDIR IEXPAND(UV1UMAA1)
!CDIR IEXPAND(UV0UWAA1)
      CLOCK_IK(UVCLST_XA3,'XArray3',UVCLST)
      do ix = 1, mx
         call UV0sta   (A0,     NP, LP, K0, D0)
         call UV0sta   (A1,     NP, LP, K1, D1)
         call UV0sta   (A2,     NP, LP, K2, D2)
         call UV0sta   (A3,     NP, LP, K3, D3)
         call UV0sta   (A4,     NP, LP, K4, D4)
         call UV1umaA1 (A3, A4, NP, LP, K3, K4)
         OPR2(3,4)
         call UV0uwaA1 (A3,     NP, LP, K3, F)
         call UV1umaA1 (A2, A3, NP, LP, K2, K3)
         OPR2(3,4)
         call UV0uwaA1 (A2,     NP, LP, K2, F)
         call UV1umaA1 (A1, A2, NP, LP, K1, K2)
         OPR2(3,4)
         call UV0uwaA1 (A1,     NP, LP, K1, F)
         call UV1umaA1 (A0, A1, NP, LP, K0, K1)
         OPR2(3,4)
         call UV0uwaA1 (A0,     NP, LP, K0, F)
      enddo
      CLOCK_OK(UVCLST_XA3,'XArray3',UVCLST)
CCC_  - inline expansion/loop
!CDIR NEXPAND(UV1UMAL2)
!CDIR NEXPAND(UV0UWAL2)
      CLOCK_IK(UVCLST_NXL3,'NXLoop3',UVCLST)
      do ix = 1, mx
         call UV0sta   (A0,     NP, LP, K0, D0)
         call UV0sta   (A1,     NP, LP, K1, D1)
         call UV0sta   (A2,     NP, LP, K2, D2)
         call UV0sta   (A3,     NP, LP, K3, D3)
         call UV0sta   (A4,     NP, LP, K4, D4)
         call UV1umaL2 (A3, A4, NP, LP, K3, K4)
         OPR2(3,4)
         call UV0uwaL2 (A3,     NP, LP, K3, F)
         call UV1umaL2 (A2, A3, NP, LP, K2, K3)
         OPR2(3,4)
         call UV0uwaL2 (A2,     NP, LP, K2, F)
         call UV1umaL2 (A1, A2, NP, LP, K1, K2)
         OPR2(3,4)
         call UV0uwaL2 (A1,     NP, LP, K1, F)
         call UV1umaL2 (A0, A1, NP, LP, K0, K1)
         OPR2(3,4)
         call UV0uwaL2 (A0,     NP, LP, K0, F)
      enddo
      CLOCK_OK(UVCLST_NXL3,'NXLoop3',UVCLST)
CCC_  - inline expansion/array
!CDIR NEXPAND(UV1UMAA2)
!CDIR NEXPAND(UV0UWAA2)
      CLOCK_IK(UVCLST_NXA3,'NXArray3',UVCLST)
      do ix = 1, mx
         call UV0sta   (A0,     NP, LP, K0, D0)
         call UV0sta   (A1,     NP, LP, K1, D1)
         call UV0sta   (A2,     NP, LP, K2, D2)
         call UV0sta   (A3,     NP, LP, K3, D3)
         call UV0sta   (A4,     NP, LP, K4, D4)
         call UV1umaA2 (A3, A4, NP, LP, K3, K4)
         OPR2(3,4)
         call UV0uwaA2 (A3,     NP, LP, K3, F)
         call UV1umaA2 (A2, A3, NP, LP, K2, K3)
         OPR2(3,4)
         call UV0uwaA2 (A2,     NP, LP, K2, F)
         call UV1umaA2 (A1, A2, NP, LP, K1, K2)
         OPR2(3,4)
         call UV0uwaA2 (A1,     NP, LP, K1, F)
         call UV1umaA2 (A0, A1, NP, LP, K0, K1)
         OPR2(3,4)
         call UV0uwaA2 (A0,     NP, LP, K0, F)
      enddo
      CLOCK_OK(UVCLST_NXA3,'NXArray3',UVCLST)
CCC_  - end
      call UDTbni (ITEST, '09', ' ', IFP)
      RETURN
      END
CCC_ & UV1umaL0
      subroutine UV1umaL0
     M    (V,
     I     X,
     I     N,  L,  KVL, KXR)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KVL, KXR
      _INTENT(INOUT,_REALSTD) V (L, *)
      _INTENT(IN,   _REALSTD) X (L, *)
      integer j
      do j  = 1, N
         V (j, KVL) = V (j, KVL) * X (j, KXR)
      enddo
      RETURN
      END
CCC_ & UV1umaA0
      subroutine UV1umaA0
     M    (V,
     I     X,
     I     N,  L,  KVL, KXR)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KVL, KXR
      _INTENT(INOUT,_REALSTD) V (L, *)
      _INTENT(IN,   _REALSTD) X (L, *)
      V (1:N, KVL) = V (1:N, KVL) * X (1:N, KXR)
      RETURN
      END
CCC_ & UV1umaL1
      subroutine UV1umaL1
     M    (V,
     I     X,
     I     N,  L,  KVL, KXR)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KVL, KXR
      _INTENT(INOUT,_REALSTD) V (L, *)
      _INTENT(IN,   _REALSTD) X (L, *)
      integer j
      do j  = 1, N
         V (j, KVL) = V (j, KVL) * X (j, KXR)
      enddo
      RETURN
      END
CCC_ & UV1umaA1
      subroutine UV1umaA1
     M    (V,
     I     X,
     I     N,  L,  KVL, KXR)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KVL, KXR
      _INTENT(INOUT,_REALSTD) V (L, *)
      _INTENT(IN,   _REALSTD) X (L, *)
      V (1:N, KVL) = V (1:N, KVL) * X (1:N, KXR)
      RETURN
      END
CCC_ & UV1umaL2
      subroutine UV1umaL2
     M    (V,
     I     X,
     I     N,  L,  KVL, KXR)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KVL, KXR
      _INTENT(INOUT,_REALSTD) V (L, *)
      _INTENT(IN,   _REALSTD) X (L, *)
      integer j
      do j  = 1, N
         V (j, KVL) = V (j, KVL) * X (j, KXR)
      enddo
      RETURN
      END
CCC_ & UV1umaA2
      subroutine UV1umaA2
     M    (V,
     I     X,
     I     N,  L,  KVL, KXR)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KVL, KXR
      _INTENT(INOUT,_REALSTD) V (L, *)
      _INTENT(IN,   _REALSTD) X (L, *)
      V (1:N, KVL) = V (1:N, KVL) * X (1:N, KXR)
      RETURN
      END
CCC_ & UV0uwaL0
      subroutine UV0uwaL0
     M    (V,
     I     N,  L,  KVL, F)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KVL
      _INTENT(IN,   _REALSTD) F
      _INTENT(INOUT,_REALSTD) V (L, *)
      integer j
      do j  = 1, N
         V (j, KVL) = V (j, KVL) * F
      enddo
      RETURN
      END
CCC_ & UV0uwaA0
      subroutine UV0uwaA0
     M    (V,
     I     N,  L,  KVL, F)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KVL
      _INTENT(IN,   _REALSTD) F
      _INTENT(INOUT,_REALSTD) V (L, *)
      V (1:N, KVL) = V (1:N, KVL) * F
      RETURN
      END
CCC_ & UV0uwaL1
      subroutine UV0uwaL1
     M    (V,
     I     N,  L,  KVL, F)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KVL
      _INTENT(IN,   _REALSTD) F
      _INTENT(INOUT,_REALSTD) V (L, *)
      integer j
      do j  = 1, N
         V (j, KVL) = V (j, KVL) * F
      enddo
      RETURN
      END
CCC_ & UV0uwaA1
      subroutine UV0uwaA1
     M    (V,
     I     N,  L,  KVL, F)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KVL
      _INTENT(IN,   _REALSTD) F
      _INTENT(INOUT,_REALSTD) V (L, *)
      V (1:N, KVL) = V (1:N, KVL) * F
      RETURN
      END
CCC_ & UV0uwaL2
      subroutine UV0uwaL2
     M    (V,
     I     N,  L,  KVL, F)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KVL
      _INTENT(IN,   _REALSTD) F
      _INTENT(INOUT,_REALSTD) V (L, *)
      integer j
      do j  = 1, N
         V (j, KVL) = V (j, KVL) * F
      enddo
      RETURN
      END
CCC_ & UV0uwaA2
      subroutine UV0uwaA2
     M    (V,
     I     N,  L,  KVL, F)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KVL
      _INTENT(IN,   _REALSTD) F
      _INTENT(INOUT,_REALSTD) V (L, *)
      V (1:N, KVL) = V (1:N, KVL) * F
      RETURN
      END
CCC_ + end
#endif /* TEST_UVCLST */
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
