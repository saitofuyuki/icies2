C unison/uarmpi.F --- IcIES/Unison/Arithmetic Multi-precision Integers
C Maintainer:  SAITO Fuyuki
C Created: Jul 17 2010
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2020/09/15 11:45:27 fuyuki uarmpi.F>'
#define _FNAME 'unison/uarmpi.F'
#define _REV   'Snoopy0.9'
CCC_! MANIFESTO
C
C Copyright (C) 2010--2020
C           Japan Agency for Marine-Earth Science and Technology
C
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
CCC_* Description
CCC_ + [CAUTION]
CC      - INT_MIN cannot be handled.
CCC_ + Naming convention
CC      M   interior representation of integers.
CC          Size is stored in the first element.
CC          Sign is stored in the first element.
CC          4-or-more-byte integer array storing maximum 1 byte,
CC          from lower to upper from the second element.
CC      J   compact representation of integers.
CC          4-byte integer array storing maximum 4 byte,
CC          from lower to upper.
CC          Sign is stored in the largest bit of the final byte.
CC          2-item J is equivalent with 8 byte signed integer
CC          under the little endian
CC      I   signed compiler-default integer
CC      N   signed 4-byte integer
CC      L   signed 8-byte integer (if implemented)
CCC_* Common macros
#include "ofdlct.h" /* fortran dialect */
CCC_ + Test macro
#ifndef   TEST_UARMPI
#  define TEST_UARMPI 0
#endif
#if TEST_UARMPI
#  if        HAVE_INTEGER_64_KIND == 0
#    undef   HAVE_INTEGER_64_KIND
#    define  HAVE_INTEGER_64_KIND 1
#  endif
#  ifndef    DBG_UARMPI
#    define  DBG_UARMPI 1
#  endif
#endif
#if    TEST_UARMPI == 2
#  define  INTEGER_M_KIND INTEGER_64_KIND
#elif  TEST_UARMPI == 3
#  define  INTEGER_M_KIND INTEGER_32_KIND
#endif
CCC_ + debug
#ifndef    DBG_UARMPI
#  define  DBG_UARMPI 0
#endif
CCC_ + Types
CCC_  - [M]
#ifndef    INTEGER_M_KIND
#  define  INTEGER_M_KIND 0
#endif
#if INTEGER_M_KIND == 0
#  define  _INTM     integer
#  define  _XINTM(V) int(V)
#else
#  define  _INTM     _INTEGER(INTEGER_M_KIND)
#  define  _XINTM(V) _XINTK(V,INTEGER_M_KIND)
#endif
CCC_  - [J]
#define _INTJ       _INTEGER(INTEGER_32_KIND)
#define _INTJ_BYTES INTEGER_32_BYTES
#define _INTJ_MAX   INTEGER_32_MAX
#define _XINTJ      _XINT32
CCC_ + Properties
#define BASE       256
#define BIT_BASE   8
CCC_ + Storage
#define _SIGN 1
#define _SIZE 1
CCC_* [J] Compact representation by 4-byte signed integers
CCC_ & UAcomJ  ## Unison/Arithmetic Composition MA to JA
      subroutine UAcomJ (M, NJ, J, MaxJ)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,_INTJ)   J (*)
      _INTENT(OUT,integer) NJ
      _INTENT(IN, _INTM)   M (*)
      _INTENT(IN, integer) MaxJ
      _INTJ      JB
      parameter (JB = BASE)
      _INTJ      JX
      integer    nm
      integer    kj, km, kmj
      integer    UAnzdM
CCC_  - Body
      nm = ABS (UAnzdM (M))
      NJ = min (MaxJ, (nm - 1) / _INTJ_BYTES + 1)
      do kj = 1, NJ
         J (kj) = 0
      enddo
      do km = 1, _INTJ_BYTES - 1
         kj = 0
         do kmj = km, nm, _INTJ_BYTES
            kj = kj + 1
            JX = _XINTJ(M (1 + kmj))
            J (kj) = J (kj) + JX * (JB ** (km - 1))
         enddo
      enddo
      do km = _INTJ_BYTES, _INTJ_BYTES
         kj = 0
         do kmj = km, nm, _INTJ_BYTES
            kj = kj + 1
            if (M (1 + kmj) .ge. (JB / 2)) then
               JX = _XINTJ(M (1 + kmj)) - (JB / 2)
               J (kj) = J (kj) + JX * (JB ** (km - 1))
               J (kj) = (J (kj) - 1) - _INTJ_MAX
            else
               JX = _XINTJ(M (1 + kmj))
               J (kj) = J (kj) + JX * (JB ** (km - 1))
            endif
         enddo
      enddo
      if (M (1) .lt. 0) then
         J (1) = - J (1)
         do kj = 2, NJ
            J (kj) = - J (kj) - 1
         enddo
      endif
      RETURN
      END
CCC_ & UAdecJ  ## Unison/Arithmetic Decomposition JA to MA
      subroutine UAdecJ (M, J, NJ)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer) NJ
      _INTENT(IN, _INTJ)   J (*)
      _INTENT(OUT,_INTM)   M (*)
      _INTJ      JB
      parameter (JB = BASE)
      integer    nm
      integer    kj, km, kmj
      integer    jt, js
CCC_  - Body
      nm = NJ * _INTJ_BYTES
      do kj = 1, nj
         jt = J (kj)
         if (jt.lt.0) then
            JT = (JT + 1) + _INTJ_MAX
            JS = JB / 2
         else
            JS = 0
         endif
         do km = 1, _INTJ_BYTES
            kmj = 1 + ((kj - 1) * _INTJ_BYTES + km)
            M (kmj) = MOD (JT, JB)
            JT = JT / JB
         enddo
         km = _INTJ_BYTES
         kmj = 1 + ((kj - 1) * _INTJ_BYTES + km)
         M (kmj) = M (kmj) + JS
      enddo
      js = SIGN (1, J (NJ))
      if (js.lt.0) then
         M (2) = JB - M (2)
         do km = 1 + 2, 1 + nm
            M (km) = JB - M (km) - 1
         enddo
      endif
      M (1) = nm * js
      RETURN
      END
CCC_* [N] Single 32-bit integer
CCC_ & UAcomN  ## Unison/Arithmetic Composition M to N
      subroutine UAcomN (M, I)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,_INT32) I
      _INTENT(IN, _INTM)  M (*)
      integer    K
      parameter (K  = INTEGER_32_BYTES)
      _INT32     IB
      parameter (IB = BASE)
      integer    n, nm
      integer    UAnzdM
CCC_  - Body
      nm = ABS (UAnzdM (M))
      I  = 0
      DO n = 1 + 1, 1 + MIN (K, nm)
         I = I + _XINT32(M (n)) * (IB ** (n - 2))
      ENDDO
      if (M (1).lt.0) I = - I
      RETURN
      END
CCC_ & UAdecN  ## Unison/Arithmetic Decomposition N to M
      subroutine UAdecN (M, I)
CCC_  - Declaration
      implicit none
      _INTENT(IN, _INT32) I
      _INTENT(OUT,_INTM)  M (*)
      integer    K
      parameter (K  = INTEGER_32_BYTES)
      _INT32     IB
      parameter (IB = BASE)
      integer    n
      _INT32     IT
CCC_  - Body
      if (I .ge. 0) then
         IT    = I
         M (1) = K
      else
         IT    = - I
         M (1) = - K
      endif
      DO n = 1 + 1, 1 + K
         M (n) = MOD (IT, IB)
         IT    = IT / IB
      ENDDO
      RETURN
      END
CCC_* [I] Single compiler-default integer
CCC_ & UAcomI  ## Unison/Arithmetic Composition M to I
      subroutine UAcomI (M, I)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer) I
      _INTENT(IN, _INTM)   M (*)
      integer    K
      parameter (K  = INTEGER_0_BYTES)
      integer    IB
      parameter (IB = BASE)
      integer    n, nm
      integer    UAnzdM
CCC_  - Body
      nm = ABS (UAnzdM (M))
      I  = 0
      DO n = 1 + 1, 1 + MIN (K, nm)
         I = I + INT (M (n)) * (IB ** (n - 2))
      ENDDO
      if (M (1).lt.0) I = - I
      RETURN
      END
CCC_ & UAdecI  ## Unison/Arithmetic Decomposition I to M
      subroutine UAdecI (M, I)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer) I
      _INTENT(OUT,_INTM)   M (*)
      integer    K
      parameter (K  = INTEGER_0_BYTES)
      integer    IB
      parameter (IB = BASE)
      integer    n
      integer    IT
CCC_  - Body
      if (I .ge. 0) then
         IT    = I
         M (1) = K
      else
         IT    = - I
         M (1) = - K
      endif
      DO n = 1 + 1, 1 + K
         M (n) = MOD (IT, IB)
         IT    = IT / IB
      ENDDO
      RETURN
      END
CCC_* [L] Single 8-byte integer
#if HAVE_INTEGER_64_KIND
CCC_ & UAcomL  ## Unison/Arithmetic Composition M to L
      subroutine UAcomL (M, I)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,_INT64)  I
      _INTENT(IN, _INTM)   M (*)
      integer    K
      parameter (K  = INTEGER_64_BYTES)
      _INT64     IB
      parameter (IB = BASE)
      integer    n, nm
      integer    UAnzdM
CCC_  - Body
      nm = ABS (UAnzdM (M))
      I  = 0
      DO n = 1 + 1, 1 + MIN (K, nm)
         I = I + _XINT64(M (n)) * (IB ** (n - 2))
      ENDDO
      if (M (1).lt.0) I = - I
      RETURN
      END
CCC_ & UAdecL  ## Unison/Arithmetic Decomposition L to M
      subroutine UAdecL (M, I)
CCC_  - Declaration
      implicit none
      _INTENT(IN, _INT64)  I
      _INTENT(OUT,_INTM)   M (*)
      integer    K
      parameter (K  = INTEGER_64_BYTES)
      _INT64     IB
      parameter (IB = BASE)
      integer    n
      _INT64     IT
CCC_  - Body
      if (I .ge. 0) then
         IT    = I
         M (1) = K
      else
         IT    = - I
         M (1) = - K
      endif
      DO n = 1 + 1, 1 + K
         M (n) = _XINT64(MOD (IT, IB))
         IT    = IT / IB
      ENDDO
      RETURN
      END
#endif /* HAVE_INTEGER_64_KIND */
CCC_* [M] Multi-precision 1-byte arrays using M-type integers
CCC_ & UAsinM () ## Unison/Arithmetic sign (-1 or 1)
      integer function UAsinM (M)
      implicit none
      _INTENT(IN, _INTM) M (*)
      UAsinM = SIGN (1, INT (M (1)))
      RETURN
      END
CCC_ & UAnzdM () ## Unison/Arithmetic upper non-zero digits
      integer function UAnzdM (M)
      implicit none
      _INTENT(IN, _INTM) M (*)
      integer nn, nm, km
      nm = INT (ABS (M (1)))
      nn = nm
      do km = 1 + nn, 1 + 2, -1
         if (M (km).eq.0) then
            nm = nm - 1
         else
            goto 100
         endif
      enddo
 100  continue
      UAnzdM = SIGN (nm, INT (M (1)))
      RETURN
      END
CCC_ & UAtuzM  ## Unison/Arithmetic truncate upper zero
      subroutine UAtuzM
     M     (M)
      implicit none
      _INTENT(INOUT, _INTM) M (*)
      integer UAnzdM
      M (1) = UAnzdM (M)
      RETURN
      END
CCC_ & UAnmlM  ## Unison/Arithmetic normalization
      subroutine UAnmlM
     M     (M)
CC    Valid for positive carries
CC    May be valid for negative carries (not fully tested)
CCC_  - Declaration
      implicit none
      _INTENT(INOUT, _INTM) M (*)
      _INTM      MB
      parameter (MB = BASE)
      integer    km, nm
      _INTM      mc
CC DO NOT USE UAnzdM ()
CCC_  - Body
 100  continue
      nm = INT (ABS (M (1)))
      mc = 0
      do km = 1 + 1, 1 + nm
         mc = M (km) / MB
         M (km)     = MOD (M (km), MB)
         if (M (km).lt.0) then
            M (km) = M (km) + MB
            mc     = mc - 1
         endif
         M (km + 1) = M (km + 1) + mc
      enddo
      if (mc.gt.0) then
         nm = nm + 1
         M (1 + nm) = mc
         M (1) = SIGN (nm, INT (M (1)))
      else if (mc.lt.0) then
         nm = nm + 1
         M (1 + nm) = mc
         M (1) = SIGN (nm, INT (M (1)))
         do km = 1, nm + 1
            M (km) = - M (km)
         enddo
         goto 100
      endif
      RETURN
      END
CCC_ & UAcpyM  ## Unison/Arithmetic copy
      subroutine UAcpyM
     O    (MX,
     I     MY)
      implicit none
      _INTENT(OUT, _INTM) MX (*)
      _INTENT(IN,  _INTM) MY (*)
      integer ny, km
CC DO NOT USE UAnzdM ()
      ny = INT (ABS (MY (1)))
      do km = 1, 1 + ny
         MX (km) = MY (km)
      enddo
      call UAtuzM (MX)
      RETURN
      END
CCC_ & UAclrM  ## Unison/Arithmetic clear
      subroutine UAclrM
     O    (M)
      implicit none
      _INTENT(OUT, _INTM) M (*)
      M (1) = 1
      M (2) = 0
      RETURN
      END
CCC_ & UAbliM  ## Unison/Arithmetic block shift/insert lower
      subroutine UAbliM
     O    (M,
     I     MV)
CC  ISH > 0
      implicit none
      _INTENT(INOUT,_INTM) M (*)
      _INTENT(IN,   _INTM) MV
      integer nx, km, jsign
      integer UAnzdM, UAsinM
      jsign = UAsinM (M)
      nx    = ABS (UAnzdM (M))
      do km = 1 + nx, 1 + 1, -1
         M (km + 1) = M (km)
      enddo
      nx = nx + 1
      M (1)     = nx * jsign
      M (1 + 1) = MV
      call UAnmlM (M)
      RETURN
      END
CCC_ & UAlshM  ## Unison/Arithmetic shift left
      subroutine UAlshM
     O    (M,
     I     ISH)
CC  ISH > 0
      implicit none
      _INTENT(INOUT,_INTM)   M (*)
      _INTENT(IN,   integer) ISH
      integer nx, km, jb, jf, jsign
      integer UAnzdM, UAsinM
c
      jsign = UAsinM (M)
      nx    = ABS (UAnzdM (M))
      jb    = ISH / BIT_BASE
      do km = 1 + nx, 1 + 1, -1
         M (km + jb) = M (km)
      enddo
      do km = 1 + 1, 1 + jb
         M (km) = 0
      enddo
      nx    = nx + jb
      M (1) = nx * jsign
      jf    = 2 ** MOD (ISH, BIT_BASE)
      do km = 1 + jb + 1, 1 + nx
         M (km) = M (km) *  jf
      enddo
      call UAnmlM (M)
      call UAtuzM (M)
      RETURN
      END
CCC_ & UArshM  ## Unison/Arithmetic shift right
      subroutine UArshM
     O    (M,
     I     ISH)
CC  ISH > 0
      implicit none
      _INTENT(INOUT,_INTM)   M (*)
      _INTENT(IN,   integer) ISH
      integer    nx, km, jb, jf, jsign
      integer    UAnzdM, UAsinM
      _INTM      MB
      parameter (MB = BASE)
c
      jsign = UAsinM (M)
      nx    = ABS (UAnzdM (M))
      jb    = ISH / BIT_BASE
      if (jb.ge.nx) then
         call UAclrM (M)
      else
         nx    = nx - jb
         do km = 1 + 1, 1 + nx
            M (km) = M (km + jb)
         enddo
         do km = 1 + 1, 1 + nx - 1
            M (km)     = M (km) + M (km + 1) * MB
            M (km + 1) = 0
         enddo
         M (1) = nx * jsign
         jf    = 2 ** MOD (ISH, BIT_BASE)
         do km = 1 + 1, 1 + nx
            M (km) = M (km) /  jf
         enddo
         call UAnmlM (M)
         call UAtuzM (M)
      endif
      RETURN
      END
CCC_ & UAcmpA  ## Unison/Arithmetic comparison (absolute)
      subroutine UAcmpA
     O    (K,
     I     MX, MY)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer) K
      _INTENT(IN, _INTM)   MX (*), MY (*)
      integer km
      integer nx, ny
      integer UAnzdM
CCC_  - Body
      nx = ABS (UAnzdM (MX))
      ny = ABS (UAnzdM (MY))
      K  = 0
      if (nx.gt.ny) then
         K = 1
      else if (nx.lt.ny) then
         K = -1
      else
         do km = 1 + nx, 1 + 1, -1
            if      (MX (km).gt.MY (km)) then
               K = 1
               goto 100
            else if (MX (km).lt.MY (km)) then
               K = -1
               goto 100
            endif
         enddo
 100     continue
      endif
      RETURN
      END
CCC_ & UAsadM  ## Unison/Arithmetic Addition and substitute
      subroutine UAsadM
     M    (MZ,
     I     MX)
CCC_  - Declaration
      implicit none
      _INTENT(INOUT,_INTM) MZ (*)
      _INTENT(IN,   _INTM) MX (*)
      integer kcmp
      integer ksign
      integer UAsinM
CCC_  - Body
      Ksign = UAsinM (MZ) * UAsinM (MX)
      if (Ksign.eq.1) then
         call UAsadA (MZ, MX)
         MZ (1) = SIGN (MZ (1), MX (1))
      else
         call UAcmpA (kcmp, MZ, MX)
         call UAssbA (MZ, MX, Kcmp)
         MZ (1) = SIGN (MZ (1), MX (1)) * (- Kcmp)
      endif
      RETURN
      END
CCC_ & UAsadA  ## Unison/Arithmetic Addition and subst (absolute)
      subroutine UAsadA
     M    (MZ,
     I     MX)
CCC_  - Declaration
      implicit none
      _INTENT(INOUT,_INTM) MZ (*)
      _INTENT(IN,   _INTM) MX (*)
      integer nz, nx
      integer km
      integer UAnzdM
CCC_  - Body
      nz = ABS (UAnzdM (MZ))
      nx = ABS (UAnzdM (MX))
      do km = 1 + 1, 1 + MIN (nz, nx)
         MZ (km) = MZ (km) + MX (km)
      enddo
      do km = 1 + nz + 1, 1 + MAX (nz, nx)
         MZ (km) = MX (km)
      enddo
      MZ (1) = MAX (nz, nx)
      call UAnmlM (MZ)
      RETURN
      END
CCC_ & UAssbA  ## Unison/Arithmetic subtraction and subst (absolute)
      subroutine UAssbA
     M    (MZ,
     I     MX,  KSW)
CCC_  - Declaration
      implicit none
      _INTENT(INOUT,_INTM)   MZ (*)
      _INTENT(IN,   _INTM)   MX (*)
      _INTENT(IN,   integer) KSW
      integer nz, nx
      integer km
      integer UAnzdM
CCC_  - Body
      nz = ABS (UAnzdM (MZ))
      nx = ABS (UAnzdM (MX))
      do km = 1 + 1, 1 + MIN (nz, nx)
         MZ (km) = (MZ (km) - MX (km)) * KSW
      enddo
      do km = 1 + nz + 1, 1 + MAX (nz, nx)
         MZ (km) = (0       - MX (km)) * KSW
      enddo
      MZ (1) = MAX (nz, nx)
      call UAnmlM (MZ)
      RETURN
      END
CCC_ & UAaddM  ## Unison/Arithmetic Addition
      subroutine UAaddM
     O    (MZ,
     I     MX, MY)
CC    Now only valid for MX >0, MY >0
CCC_  - Declaration
      implicit none
      _INTENT(OUT,_INTM) MZ (*)
      _INTENT(IN, _INTM) MX (*), MY (*)
      integer kcmp
      integer ksign
CCC_  - Body
      call UAcmpA (kcmp, MX, MY)
      Ksign = SIGN (1, INT (MX (1))) * SIGN (1, INT (MY (1)))
      if (Ksign.eq.1) then
         if (Kcmp.eq.1) then
            call UAaddA (MZ, MX, MY)
         else
            call UAaddA (MZ, MY, MX)
         endif
         MZ (1) = SIGN (MZ (1), MX (1))
      else
         if (Kcmp.eq.1) then
            call UAsubA (MZ, MX, MY)
            MZ (1) = SIGN (MZ (1), MX (1))
         else
            call UAsubA (MZ, MY, MX)
            MZ (1) = SIGN (MZ (1), MY (1))
         endif
      endif
      RETURN
      END
CCC_ & UAaddA  ## Unison/Arithmetic Addition (absolute)
      subroutine UAaddA
     O    (MZ,
     I     ML, MS)
CCC_  - Declaration
CC         abs (ML) >= abs (MS)
      implicit none
      _INTENT(OUT,_INTM) MZ (*)
      _INTENT(IN, _INTM) ML (*), MS (*)
      integer nl, ns
      integer km
CCC_  - Body
      nl = ABS (ML (1))
      ns = ABS (MS (1))
      do km = 2, ns + 1
         MZ (km) = ML (km) + MS (km)
      enddo
      do km = ns + 2, nl + 1
         MZ (km) = ML (km)
      enddo
      MZ (1) = nl
      call UAnmlM (MZ)
      RETURN
      END
CCC_ & UAsubA  ## Unison/Arithmetic Subtraction (absolute)
      subroutine UAsubA
     O    (MZ,
     I     ML, MS)
CCC_  - Declaration
CC         abs (ML) >= abs (MS)
      implicit none
      _INTENT(OUT,_INTM) MZ (*)
      _INTENT(IN, _INTM) ML (*), MS (*)
      integer nl, ns
      integer km
CCC_  - Body
      nl = ABS (ML (1))
      ns = ABS (MS (1))
      do km = 2, ns + 1
         MZ (km) = ML (km) - MS (km)
      enddo
      do km = ns + 2, nl + 1
         MZ (km) = ML (km)
      enddo
      MZ (1) = nl
      call UAnmlM (MZ)
      RETURN
      END
CCC_ & UAmulM  ## Unison/Arithmetic Multiplication
      subroutine UAmulM
     O    (MZ,
     I     MX, MY)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,_INTM) MZ (*)
      _INTENT(IN, _INTM) MX (*), MY (*)
      integer nx, ny, nz
      integer k,  kx, ky, kz
      integer UAnzdM, UAsinM
CCC_  - Body
      nx = ABS (UAnzdM (MX))
      ny = ABS (UAnzdM (MY))
      nz = nx + ny
      MZ (1) = nz * UAsinM (MX) * UAsinM (MY)
      DO k = 1 + 1, 1 + nz
         MZ (k) = 0
      ENDDO
      DO kx = 1, nx
         DO ky = 1, ny
            kz = kx + ky - 1
            MZ (1 + kz) = MZ (1 + kz) + MX (1 + kx) * MY (1 + ky)
         ENDDO
         call UAnmlM (MZ)
      ENDDO
      call UAtuzM (MZ)
      RETURN
      END
CCC_ & UAmlsM  ## Unison/Arithmetic Multiplication (single digit)
      subroutine UAmlsM
     O    (MZ,
     I     MX, MC)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,_INTM)   MZ (*)
      _INTENT(IN, _INTM)   MX (*)
      _INTENT(IN, _INTM)   MC
      integer nx, nz
      integer k,  kx, kz
      integer UAnzdM, UAsinM
CCC_  - Body
      nx = ABS (UAnzdM (MX))
      nz = nx + 1
      MZ (1) = nz * UAsinM (MX) * SIGN (1, INT (MC))
      DO k = 1 + 1, 1 + nz
         MZ (k) = 0
      ENDDO
      DO kx = 1, nx
         kz = kx + 1 - 1
         MZ (1 + kz) = MZ (1 + kz) + MX (1 + kx) * ABS (MC)
         call UAnmlM (MZ)
      ENDDO
      call UAtuzM (MZ)
      RETURN
      END
CCC_ & UAdivM  ## Unison/Arithmetic division
      subroutine UAdivM
     O    (MZ,  MR,
     W     MXW, MYW, MW,
     I     MX,  MY)
CCC_  - Description
CC     MX = MZ * MY + MR
CCC_  - Declaration
      implicit none
      _INTENT(OUT,_INTM) MZ  (*), MR  (*)
      _INTENT(OUT,_INTM) MXW (*), MYW (*), MW (*)
      _INTENT(IN, _INTM) MX  (*), MY  (*)
      _INTM   MQ
      integer nx,  ny, ns
      integer iyh
      integer ish
      integer k,   kcmp
      integer isign
      integer UAnzdM, UAsinM
CCC_  - Body
      isign = UAsinM (MX) * UAsinM (MY)
CCC_   . cmp (X, Y)
      call UAcmpA (kcmp, MX, MY)
      if (kcmp.lt.0) then
         call UAclrM (MZ)
         call UAcpyM (MR, MX)
         goto 900
      endif
CCC_   . compute shift
      ny  = ABS (UAnzdM (MY))
      iyh = INT (MY (1 + ny))
      ish = 0
      do
         if (iyh .ge. (BASE / 2)) goto 100
         ish = ish + 1
         iyh = iyh * 2
      enddo
 100  continue
CCC_   . shift
      call UAcpyM (MXW, MX)
      call UAcpyM (MYW, MY)
      call UAlshM (MXW, ish)
      call UAlshM (MYW, ish)
      MXW (1) = ABS (MXW (1))
      MYW (1) = ABS (MYW (1))
      nx = INT (MXW (1))
      ny = INT (MYW (1))
CCC_   . initial
      ns = nx - ny
      do k = 1, ny
         MR (1 + k) = MXW (1 + k + ns)
      enddo
      MR (1) = ny
      call UAcmpA (kcmp, MR, MYW)
      if (kcmp.lt.0) then
         ns = ns - 1
         call UAbliM (MR, MXW (ns + 2))
      endif
      MZ (1) = ns + 1
c
      do
         call UAcmpA (kcmp, MR, MYW)
         if (kcmp.lt.0) goto 200
         call UAdvsM (MQ,  MR, MYW, MW)
         MZ (1 + ns + 1) = MQ
         do
            if (ns.eq.0) goto 300
            ns  = ns - 1
            call UAbliM (MR, MXW (ns + 2))
            call UAcmpA (kcmp, MR, MYW)
            if (kcmp.ge.0) goto 300
            MZ (1 + ns + 1) = 0
         enddo
 300     continue
      enddo
 200  continue
c
      call UArshM (MR, ish)
c
 900  continue
      call UAtuzM (MZ)
      call UAtuzM (MR)
c
      MZ (1) = ABS (MZ (1)) * isign
      MR (1) = ABS (MR (1)) * UAsinM (MX)
c
      RETURN
      END
CCC_ & UAdvsM  ## Unison/Arithmetic division (sub)
      subroutine UAdvsM
     O    (MQ,
     M     MX,
     I     MY,
     W     MW)
CCC_  - Description
CC     need truncate upper zero from MX, MY beforehand
CC     MX = MQ * MY + (new) MX
CC     xxx / yyy or xxxx / yyy
CC     nx must equal to ny or ny + 1
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  _INTM)   MQ
      _INTENT(INOUT,_INTM)   MX (*)
      _INTENT(IN,   _INTM)   MY (*)
      _INTENT(OUT,  _INTM)   MW (*)
      integer nx, ny
      integer Kcmp, isign
CCC_  - Body
      nx = INT (ABS (MX (1)))
      ny = INT (ABS (MY (1)))
      isign = SIGN (1, INT (MX (1))) * SIGN (1, INT (MY (1)))
      MQ = MX (1 + ny)
      if (nx.gt.ny) MQ = MQ + BASE * MX (1 + ny + 1)
      MQ = MQ / MY (1 + ny)
      DO
         call UAmlsM (MW, MY, MQ)
         call UAtuzM (MW)
         call UAcmpA (Kcmp, MW, MX)
         if (Kcmp.eq.1) then
            MQ = MQ - 1
            if (MQ.lt.0) goto 100
         else
            goto 100
         endif
      ENDDO
 100  continue
      MW (1) = - SIGN (MW (1), MX (1))
      call UAsadM (MX, MW)
      call UAtuzM (MX)
      MQ = MQ * isign
      RETURN
      END
CCC_* Debug
#if HAVE_INTEGER_64_KIND
CCC_ & UAchkL () ## Unison/Arithmetic debug (L cmp)
      subroutine UAchkL (ipL, L0, L1, C)
      implicit none
      _INTENT(IN,integer)   ipL
      _INTENT(IN,_INT64)    L0, L1
      _INTENT(IN,character) C*(*)
      character R*(16)
      if (L0.eq.L1) then
         R = 'SUCCESS'
      else if (ABS (L0).eq.ABS (L1)) then
         R = 'FAILED (ABS)'
      else
         R = 'FAILED'
      endif
 101  format ('DC/', A, ': ', A)
      if (ipL.ge.0) then
         write (ipL, 101) _TRIM(C), _TRIM(R)
      else if (ipL.eq.-1) then
         write (*,   101) _TRIM(C), _TRIM(R)
      endif
      RETURN
      END
#endif /* HAVE_INTEGER_64_KIND */
CCC_ & UAchkM () ## Unison/Arithmetic debug (M cmp)
      subroutine UAchkM (ipL, M0, M1, C)
      implicit none
      _INTENT(IN,integer)   ipL
      _INTENT(IN,_INTM)     M0 (*), M1 (*)
      _INTENT(IN,character) C*(*)
      character R*(16)
      integer kcmp, isign
      integer UAsinM
      call UAcmpA (kcmp, M0, M1)
      if (kcmp.eq.0) then
         isign = UAsinM (M0) * UAsinM (M1)
         if (isign.eq.1) then
            R = 'SUCCSESS'
         else
            R = 'FAILED (ABS)'
         endif
      else
         R = 'FAILED'
      endif
 101  format ('DM/', A, ': ', A)
      if (ipL.ge.0) then
         write (ipL, 101) _TRIM(C), _TRIM(R)
      else if (ipL.eq.-1) then
         write (*,   101) _TRIM(C), _TRIM(R)
      endif
      RETURN
      END
CCC_ & UAdbgM () ## Unison/Arithmetic debug
      subroutine UAdbgM (ipL, M, C)
      implicit none
      _INTENT(IN,integer)   ipL
      _INTENT(IN,_INTM)     M (*)
      _INTENT(IN,character) C*(*)
      integer nm, km
      nm = INT (ABS (M (1)))
 101  format ('DM/', A, ': ', I4, 1x, 16Z3.2)
      if (ipL.ge.0) then
         write (ipL, 101) _TRIM(C), M (1), (M (km), km = nm + 1, 2, -1)
      else if (ipL.eq.-1) then
         write (*,   101) _TRIM(C), M (1), (M (km), km = nm + 1, 2, -1)
      endif
      RETURN
      END
CCC_ & UAdbgI () ## Unison/Arithmetic debug (I)
      subroutine UAdbgI (ipL, I, C)
      implicit none
      _INTENT(IN,integer)   ipL
      _INTENT(IN,integer)   I
      _INTENT(IN,character) C*(*)
 101  format ('DI/', A, ': R ', Z8.8)
 102  format ('DI/', A, ': A ', Z8.8)
      if (ipL.ge.0) then
         write (ipL, 101) _TRIM(C), I
         write (ipL, 102) _TRIM(C), ABS (I)
      else if (ipL.eq.-1) then
         write (*,   101) _TRIM(C), I
         write (*,   102) _TRIM(C), ABS (I)
      endif
      RETURN
      END
CCC_ & UAdbgL () ## Unison/Arithmetic debug (L)
      subroutine UAdbgL (ipL, L, C)
      implicit none
      _INTENT(IN,integer)   ipL
      _INTENT(IN,_INT64)    L
      _INTENT(IN,character) C*(*)
 101  format ('DL/', A, ': R ', Z16.16, 1x, I24)
 102  format ('DL/', A, ': A ', Z16.16, 1x, I24)
      if (ipL.ge.0) then
         write (ipL, 101) _TRIM(C), L, L
         write (ipL, 102) _TRIM(C), ABS (L), ABS (L)
      else if (ipL.eq.-1) then
         write (*,   101) _TRIM(C), L, L
         write (*,   102) _TRIM(C), ABS (L), ABS (L)
      endif
      RETURN
      END
CCC_ & UAdbgJ () ## Unison/Arithmetic debug (J)
      subroutine UAdbgJ (ipL, J, NJ, C)
      implicit none
      _INTENT(IN,integer)   ipL
      _INTENT(IN,integer)   NJ
      _INTENT(IN,_INTJ)     J (NJ)
      _INTENT(IN,character) C*(*)
      integer k
 101  format ('DJ/', A, ': R ', I3.3, 1x, 8Z9.8)
 102  format ('DJ/', A, ': A ', I3.3, 1x, 8Z9.8)
      if (ipL.ge.0) then
         write (ipL, 101) _TRIM(C), NJ, (J (k), k = 1, NJ)
         write (ipL, 102) _TRIM(C), NJ, (ABS (J (k)), k = 1, NJ)
      else if (ipL.eq.-1) then
         write (*,   101) _TRIM(C), NJ, (J (k), k = 1, NJ)
         write (*,   102) _TRIM(C), NJ, (ABS (J (k)), k = 1, NJ)
      endif
      RETURN
      END
CCC_ & UAdbgD  ## Unison/Arithmetic debug division
#if HAVE_INTEGER_64_KIND
      subroutine UAdbgD (ipL, MX, MY, C)
      implicit none
      _INTENT(IN,integer)   ipL
      _INTENT(IN,_INTM)     MX (*)
      _INTENT(IN,_INTM)     MY (*)
      _INTENT(IN,character) C*(*)
      _INT64 LX, LY
      call UAcomL (MX, LX)
      call UAcomL (MY, LY)
 101  format ('DD/', A, ': R ', 4Z17.16)
 102  format ('DD/', A, ': A ', 4Z17.16)
      if (ipL.ge.0) then
         write (ipL, 101) _TRIM(C), LX, LY, LX / LY, MOD (LX, LY)
         LX = ABS (LX)
         LY = ABS (LY)
         write (ipL, 102) _TRIM(C), LX, LY, LX / LY, MOD (LX, LY)
      else if (ipL.eq.-1) then
         write (*,   101) _TRIM(C), LX, LY, LX / LY, MOD (LX, LY)
         LX = ABS (LX)
         LY = ABS (LY)
         write (*,   102) _TRIM(C), LX, LY, LX / LY, MOD (LX, LY)
      endif
      RETURN
      END
CCC_ & UAdbgA  ## Unison/Arithmetic debug addition
      subroutine UAdbgA (ipL, MX, MY, C)
      implicit none
      _INTENT(IN,integer)   ipL
      _INTENT(IN,_INTM)     MX (*)
      _INTENT(IN,_INTM)     MY (*)
      _INTENT(IN,character) C*(*)
      _INT64 LX, LY
      call UAcomL (MX, LX)
      call UAcomL (MY, LY)
 101  format ('DA/', A, ': R ', 4Z17.16)
 102  format ('DA/', A, ': A ', 4Z17.16)
      if (ipL.ge.0) then
         write (ipL, 101) _TRIM(C), LX, LY, LX + LY
         write (ipL, 102) _TRIM(C), LX, LY, ABS (LX + LY)
      else if (ipL.eq.-1) then
         write (*,   101) _TRIM(C), LX, LY, LX + LY
         write (*,   102) _TRIM(C), LX, LY, ABS (LX + LY)
      endif
      RETURN
      END
#endif /* HAVE_INTEGER_64_KIND */
CCC_& UARMPI  ## Unison/Arithmetic Announcement
      subroutine UARMPI (STRA, STRB, IOP)
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
         STRA = 'DBG_UARMPI'
         write (STRB, *) DBG_UARMPI
      else if (IOP.eq.4) then
         STRA = 'INTEGER_M_KIND'
         write (STRB, *) INTEGER_M_KIND
      else if (IOP.eq.5) then
         STRA = 'BASE'
         write (STRB, *) BASE
      else if (IOP.eq.6) then
         STRA = 'BIT_BASE'
         write (STRB, *) BIT_BASE
      else
         STRA = ' '
         STRB = ' '
      endif
      RETURN
      END
CCC_* Test
CCC_ + begin
#if TEST_UARMPI
CCC_ @ UAtest  ## Test program
CCC_  - Test suites
CC::   KINDS 1 2 3
      program UATEST
CCC_  - Declaration
      implicit none
      integer    IW, IX, IY, IZ, IT, IV
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
#include "orevan.h" /* 0 */
CCC_  - Body
#define _ANNOUNCE UARMPI
#define _LEXT     9999
#include "orevan.h" /* 1 */
      IX = (BASE * BASE) * 365 + 1234
      IY = (BASE * BASE) * 1 + (BASE * BASE - 1)
      IZ = -1
      IW = -1 - IX
      IT = IX
      IV = BASE * 365 + 1234
c
      call test_UAdecI (IX)
      call test_UAdecI (IY)
      call test_UAdecI (IZ)
      call test_UAdecI (IW)
c
      call test_UAaddM (IX, IY)
      call test_UAaddM (IX, IZ)
      call test_UAaddM (IX, IW)
      call test_UAaddM (IZ, IW)
      call test_UAaddM (IV, IZ)
c
      call test_UAmulM (IX, IY)
      call test_UAmulM (IX, IZ)
      call test_UAmulM (IX, IW)
      call test_UAmulM (IZ, IW)
c
      call test_UAdivM (IX, IY,  IT)
      call test_UAdivM (IX, IZ,  IT)
      call test_UAdivM (IX, IW,  IT)
      call test_UAdivM (IZ, IW,  IT)
c
      STOP
      END
CCC_ & test_UAdecI  ## decomposition test
      subroutine test_UAdecI (I)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)    I
      integer    N4
      parameter (N4 = INTEGER_32_BYTES + 1)
      _INTM      M (N4), MT (N4), MM (N4 * 2)
      integer    MaxJ
      parameter (MaxJ = 2)
      _INTJ      J (MaxJ)
      integer    k
      integer    II
      _INT64     L, LL
      integer    ipL
      character  PFX*(32)
      integer    NJ
CCC_  - Body
      ipL = -1
CCC_   . Test I0 simple decomposition/composition
      call UAdecI (M, I)
      call UAcomI (M, II)
      call UAdbgI (ipL, I,  'TI0/0')
      call UAdbgM (ipL, M,  'TI0/1')
      call UAdbgI (ipL, II, 'TI0/2')
      L  = I
      LL = II
      call UAchkL (ipL, L, LL, 'TI0')
CCC_   . Test J0
      call UAcomJ (M,  NJ, J, MaxJ)
      call UAdecJ (MT,     J, NJ)
      call UAdbgM (ipL, M,      'TJ0/0')
      call UAdbgJ (ipL, J,  NJ, 'TJ0/1')
      call UAdbgM (ipL, MT,     'TJ0/2')
      call UAchkM (ipL, M,  MT, 'TJ0')
c
 104  format ('TL0/',I2.2)
      do k = 0, 16
         call UAdecI (MM, I)
         call UAcomL (MM, L)
         L = L * (2 ** k)
         call UAlshM (MM, k)
         call UAcomL (MM, LL)
         write (PFX, 104) k
         call UAdbgM (ipL, MM,    PFX)
         call UAdbgL (ipL, L,     PFX)
         call UAchkL (ipL, L, LL, PFX)
      enddo
c
 105  format ('TR0/',I2.2)
      do k = 0, 24
         call UAdecI (MM, I)
         call UAcomL (MM, L)
         L = L / (2 ** k)
         call UArshM (MM, k)
         call UAcomL (MM, LL)
         write (PFX, 105) k
         call UAdbgM (ipL, MM,    PFX)
         call UAdbgL (ipL, L,     PFX)
         call UAchkL (ipL, L, LL, PFX)
      enddo
c
      RETURN
      END
CCC_ & test_UAaddM  ## addition test
      subroutine test_UAaddM (IX, IY)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)    IX, IY
CCC_  - Body
 101  format ('AH: ', I12, 1x, I12)
      write (*, 101) IX, IY
      call test_UAaddMsub (+IX, +IY)
      call test_UAaddMsub (+IX, -IY)
      call test_UAaddMsub (-IX, +IY)
      call test_UAaddMsub (-IX, -IY)
      call test_UAaddMsub (+IY, +IX)
      call test_UAaddMsub (+IY, -IX)
      call test_UAaddMsub (-IY, +IX)
      call test_UAaddMsub (-IY, -IX)
      RETURN
      END
CCC_ & test_UAaddMsub  ## addition test
      subroutine test_UAaddMsub (IX, IY)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)    IX, IY
c
      integer    N4
      parameter (N4 = INTEGER_32_BYTES + 1)
      integer    MaxJ
      parameter (MaxJ = 4)
c
      _INTM   MX (N4), MY (N4),  MZ (N4), MT (N4)
      _INT64  LX,      LY,       LZ
      _INT64  LZZ
      _INTJ   JZ (MaxJ)
      integer    ipL
      integer    NJ
CCC_  - Body
      ipL = -1
c
      LX = IX
      LY = IY
      LZ = LX + LY
c
      call UAdbgL (ipL, LX, 'TA0/0')
      call UAdbgL (ipL, LY, 'TA0/1')
      call UAdbgL (ipL, LZ, 'TA0/2')
c
      call UAdecI (MX, IX)
      call UAdecI (MY, IY)
      call UAaddM (MZ, MX, MY)
      call UAcomL (MZ, LZZ)
      call UAdbgL (ipL, LZZ,    'TA0/3')
      call UAdbgM (ipL, MZ,     'TA0/4')
      call UAdbgA (ipL, MX, MY, 'TA0/9')
      call UAchkL (ipL, LZ, LZZ, 'TA0')
c
      call UAcomJ (MZ, NJ, JZ, MaxJ)
      call UAdecJ (MT,     JZ, NJ)
      call UAdbgM (ipL, MZ,      'TJ1/0')
      call UAdbgJ (ipL, JZ, NJ,  'TJ1/1')
      call UAdbgM (ipL, MT,      'TJ1/2')
      call UAchkM (ipL, MZ, MT,  'TJ1')
c
      call UAdecI (MX, IX)
      call UAdecI (MY, IY)
      call UAaddM (MZ, MX, MY)
      call UAtuzM (MX)
      call UAtuzM (MY)
      call UAtuzM (MZ)
      call UAcomL (MZ, LZZ)
      call UAdbgM (ipL, MX,     'TA1/1')
      call UAdbgM (ipL, MY,     'TA1/2')
      call UAdbgL (ipL, LZZ,    'TA1/3')
      call UAdbgM (ipL, MZ,     'TA1/4')
      call UAdbgA (ipL, MX, MY, 'TA1/9')
      call UAchkL (ipL, LZ, LZZ, 'TA1')
c
      RETURN
      END
CCC_ & test_UAmulM  ## multiplication test
      subroutine test_UAmulM (IX, IY)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)    IX, IY
c
      integer    N4
      parameter (N4 = INTEGER_32_BYTES + 1)
      integer    N8
      parameter (N8 = N4 * 2 - 1)
      integer    MaxJ
      parameter (MaxJ = 8)
c
      _INTM   MX (N4), MY (N4),  MZ (N8), MT (N8)
      _INT64  LX,      LY,       LZ
      _INT64  LZZ,     LT
      _INTJ   JZ (MaxJ)
      integer    ipL
      integer    NJ
CCC_  - Body
      ipL = -1
c
      LX = IX
      LY = IY
      LZ = LX * LY
c
      call UAdbgL (ipL, LX, 'TM0/0')
      call UAdbgL (ipL, LY, 'TM0/1')
      call UAdbgL (ipL, LZ, 'TM0/2')
c
      call UAdecI (MX, IX)
      call UAdecI (MY, IY)
      call UAmulM (MZ, MX, MY)
      call UAcomL (MZ, LZZ)
c
      call UAdbgL (ipL, LZZ, 'TM0/8')
      call UAdbgM (ipL, MZ,  'TM0/9')
c
      call UAchkL (ipL, LZ, LZZ, 'TM0')
c
      call UAdecI (MX, IX)
      call UAdecI (MY, IY)
      call UAtuzM (MX)
      call UAtuzM (MY)
      call UAmulM (MZ, MX, MY)
      call UAtuzM (MZ)
      call UAcomL (MZ, LZZ)
c
      call UAchkL (ipL, LZ, LZZ, 'TM1')
c
      call UAcomJ (MZ, NJ, JZ, MaxJ)
      call UAcomL (MZ, LZ)
      call UAdecJ (MT,     JZ, NJ)
      call UAdbgM (ipL, MZ,     'TJ2/0')
      call UAdbgJ (ipL, JZ, NJ, 'TJ2/1')
      call UAdbgM (ipL, MT,     'TJ2/2')
      call UAchkM (ipL, MZ, MT, 'TJ2')
c
      call UAcomL (MT, LT)
      call UAchkL (ipL, LZ, LT, 'TJ2')
c
      RETURN
      END
CCC_ & test_UAdivM  ## division test
      subroutine test_UAdivM (IX, IY, IT)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)    IX, IY, IT
CCC_  - Body
      call test_UAdivMsub (+IX, +IY, IT)
      call test_UAdivMsub (+IX, -IY, IT)
      call test_UAdivMsub (-IX, +IY, IT)
      call test_UAdivMsub (-IX, -IY, IT)
      call test_UAdivMsub (+IY, +IX, IT)
      call test_UAdivMsub (+IY, -IX, IT)
      call test_UAdivMsub (-IY, +IX, IT)
      call test_UAdivMsub (-IY, -IX, IT)
      RETURN
      END
CCC_ & test_UAdivMsub  ## division test
      subroutine test_UAdivMsub (IX, IY, IT)
CC     compute IX * IT / IY
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)    IX, IY, IT
      integer    N4
      parameter (N4 = INTEGER_32_BYTES + 1)
      integer    N8
      parameter (N8 = N4 * 2 - 1)
c
      _INTM   MX (N4), MY (N4),  MZ (N8), MT (N4)
      _INT64  LX,      LY,       LZ,      LT
      _INTM   MW (N8), MXW (N8), MYW (N8), MD (N8)
      _INTM   MR (N8)
      _INT64  LR, LRR, LD, LDD
      integer    ipL
CCC_  - Body
      ipL = -1
c
      LX = IX
      LY = IY
      LT = IT
      LZ = LX * LT
      LD = LZ / LY
      LR = MOD (LZ, LY)
c
      call UAdbgL (ipL, LZ, 'TD0/0')
      call UAdbgL (ipL, LY, 'TD0/1')
      call UAdbgL (ipL, LD, 'TD0/2')
      call UAdbgL (ipL, LR, 'TD0/3')
c
      call UAdecI (MX, IX)
      call UAdecI (MY, IY)
      call UAdecI (MT, IT)
      call UAtuzM (MX)
      call UAtuzM (MY)
      call UAtuzM (MT)
      call UAmulM (MZ, MX, MT)
      call UAtuzM (MZ)
c
      call UAdivM (MD, MR, MXW, MYW, MW, MZ, MY)
      call UAcomL (MD, LDD)
      call UAcomL (MR, LRR)
      call UAdbgL (ipL, LDD, 'TD0/7')
      call UAdbgL (ipL, LRR, 'TD0/8')
c
      call UAchkL (ipL, LD, LDD, 'TD0')
      call UAchkL (ipL, LR, LRR, 'TD0')
c
      RETURN
      END
CCC_ + end
#endif /* TEST_UARMPI */
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
