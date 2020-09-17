C movement/mtfunc.F --- IcIES/Movement/Thermodynamics/functions
C Maintainer:  SAITO Fuyuki
C Created: Jan 4 2012
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2020/01/08 14:55:54 fuyuki mtfunc.F>'
#define _FNAME 'movement/mtfunc.F'
#define _REV   'Snoopy0.97'
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
#include "oarpkw.h"
#ifdef NO_MOVEMENT_H
#else
#  include "movement.h" /* movement definitions */
#endif
CCC_ + Test
#ifndef    TEST_MTFUNC
#  define  TEST_MTFUNC 0
#endif
CCC_* Geometry
CCC_ & MTFvgt  ## geometry and integral table
      subroutine MTFvgt
     O    (iErr,
     W     W,
     O     VZ,
     I     KZa,
     I     Kdp,
     I     K1p,        K1m,  K1x,
     I     K2p,  K2o,  K2m,  K2x,  K2xi,
     I     KLap, KLam, KLbp, KLbm,
     I     NZ,   LZ,   IZB,  icZa, icZb, IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)  iErr
      _INTENT(IN, integer)  NZ, LZ,  IZB
      _INTENT(OUT,_REALSTD) W  (LZ, *)
      _INTENT(OUT,_REALSTD) VZ (LZ, *)
      _INTENT(IN, integer)  KZa
      _INTENT(IN, integer)  Kdp
      _INTENT(IN, integer)  K1p,      K1m, K1x
      _INTENT(IN, integer)  K2p, K2o, K2m, K2x, K2xi
      _INTENT(IN, integer)  KLap, KLam, KLbp, KLbm
      _INTENT(IN, integer)  icZa,  icZb
      _INTENT(IN, integer)  IFPl
      _REALSTD T, TP, TM, Ta, Tb
      integer jcdmy
      integer jz
CCC_  - Body
      iErr  = 0
CCC_   . grid sizes
      if (iErr.eq.0) then
         call ACCchD (iErr, jcdmy,            icZb,     'DC', IFPl)
      endif
      if (iErr.eq.0) then
         call ACCrfD (iErr, jcdmy, W (1, 1),  icZb, -1, 'DC', IFPl)
      endif
      if (iErr.eq.0) then
         call ACCchD (iErr, jcdmy,            icZa,     'DC', IFPl)
      endif
      if (iErr.eq.0) then
         call ACCrfD (iErr, jcdmy, W (1, 2),  icZa, -1, 'DC', IFPl)
      endif
CCC_   . first derivative
      if (iErr.eq.0) then
c$$$         do jz = IZB + 1, IZB + NZ
         do jz = 1, IZB + NZ
            T  = W (jz, 1)
            if (T.eq.0.0d0) then
               VZ (jz, K1p) = 0.0d0
               VZ (jz, K1m) = 0.0d0
            else
               VZ (jz, K1p) = +1.0d0 / T
               VZ (jz, K1m) = -1.0d0 / T
            endif
         enddo
      endif
CCC_   . second derivative
      if (iErr.eq.0) then
         VZ (1, K2p) = 0.0d0
         VZ (1, K2m) = 0.0d0
         VZ (1, K2o) = 0.0d0
c$$$         do jz = IZB + 1, IZB + NZ
         do jz = MAX (1, IZB) + 1, IZB + NZ
            T  = W (jz,     2)
            TP = W (jz,     1)
            TM = W (jz - 1, 1)
            if (T.eq.0.0d0) then
               VZ (jz, K2p) = 0.0d0
               VZ (jz, K2m) = 0.0d0
               VZ (jz, K2o) = 0.0d0
            else
               Ta = 1.0d0 / T / TP
               Tb = 1.0d0 / T / TM
               VZ (jz, K2p) = +Ta
               VZ (jz, K2m) = +Tb
               VZ (jz, K2o) = -(Ta + Tb)
            endif
         enddo
      endif
CCC_   . transformation factors
      if (iErr.eq.0) then
         call ACCchD (iErr, jcdmy,              icZa,     'D1', IFPl)
      endif
      if (iErr.eq.0) then
         call ACCrfD (iErr, jcdmy, VZ (1, K1x), icZa, -1, 'D1', IFPl)
      endif
      if (iErr.eq.0) then
         do jz = 1, IZB + NZ
            if (VZ (jz, K1x).eq.0.0d0) then
               VZ (jz, K1x) = 0.0d0
            else
               VZ (jz, K1x) = 1.0d0 / VZ (jz, K1x)
            endif
         enddo
      endif
      if (iErr.eq.0) then
         call ACCchD (iErr, jcdmy,              icZa,     'D2', IFPl)
      endif
      if (iErr.eq.0) then
         call ACCrfD (iErr, jcdmy, VZ(1, K2xi), icZa, -1, 'D2', IFPl)
      endif
      if (iErr.eq.0) then
         call ACCchD (iErr, jcdmy,              icZa,     'D1', IFPl)
      endif
      if (iErr.eq.0) then
         call ACCrfD (iErr, jcdmy, W  (1, 1),   icZa, -1, 'D1', IFPl)
      endif
      if (iErr.eq.0) then
CC       ddy/dxx = - [ddx/dyy] / [dx/dy**3]
         do jz = 1, IZB + NZ
            if (W (jz, 1).eq.0.0d0) then
               VZ (jz, K2x) = 0.0d0
            else
               VZ (jz, K2x) = - VZ (jz, K2xi) / (W (jz, 1) ** 3.0d0)
            endif
         enddo
CC       absolutely error
c$$$         do jz = IZB + 1, IZB + NZ
c$$$            if (VZ (jz, K2x).eq.0.0d0) then
c$$$               VZ (jz, K2x) = 0.0d0
c$$$            else
c$$$               VZ (jz, K2x) = 1.0d0 / VZ (jz, K2x)
c$$$            endif
c$$$         enddo
      endif
CCC_   . geometry
      if (KZa.ne.0) then
         if (iErr.eq.0) then
            call ACCchD (iErr, jcdmy,              icZa,     'CP', IFPl)
         endif
         if (iErr.eq.0) then
            call ACCrfD (iErr, jcdmy, VZ (1, KZa), icZa, -1, 'CP', IFPl)
         endif
      endif
      if (Kdp.ne.0) then
         if (iErr.eq.0) then
            call ACCchD (iErr, jcdmy,              icZb,     'DC', IFPl)
         endif
         if (iErr.eq.0) then
            call ACCrfD (iErr, jcdmy, VZ (1, Kdp), icZb, -1, 'DC', IFPl)
         endif
      endif
      if (KLap.ne.0) then
         if (iErr.eq.0) then
            call ACCchD(iErr, jcdmy,              icZb,     'LA', IFPl)
         endif
         if (iErr.eq.0) then
            call ACCrfD(iErr, jcdmy, VZ(1, KLap), icZb, -1, 'LA', IFPl)
         endif
      endif
      if (KLam.ne.0) then
         if (iErr.eq.0) then
            call ACCchD(iErr, jcdmy,              icZb,     'LB', IFPl)
         endif
         if (iErr.eq.0) then
            call ACCrfD(iErr, jcdmy, VZ(1, KLam), icZb, -1, 'LB', IFPl)
         endif
      endif
      if (KLbp.ne.0) then
         if (iErr.eq.0) then
            call ACCchD(iErr, jcdmy,              icZa,     'LA', IFPl)
         endif
         if (iErr.eq.0) then
            call ACCrfD(iErr, jcdmy, VZ(1, KLbp), icZa, -1, 'LA', IFPl)
         endif
      endif
      if (KLbm.ne.0) then
         if (iErr.eq.0) then
            call ACCchD(iErr, jcdmy,              icZa,     'LB', IFPl)
         endif
         if (iErr.eq.0) then
            call ACCrfD(iErr, jcdmy, VZ(1, KLbm), icZa, -1, 'LB', IFPl)
         endif
      endif
      if (KLap.gt.0.and.KLam.gt.0) then
 101     format('ZA: ', I5, 1x, 2E11.4)
         do jz = 1, LZ
            write(IFPL, 101) jz,
     $           VZ(jz,KLap), VZ(jz,KLam)
         enddo
      endif
      if (KLbp.gt.0.and.KLbm.gt.0.and.Kdp.gt.0) then
 102     format('ZB: ', I5, 1x, 3E11.4)
         do jz = 1, LZ
            write(IFPL, 102) jz,
     $           VZ(jz,Kdp),
     $           VZ(jz,KLbp), VZ(jz,KLbm)
         enddo
      endif
CCC_   . check
 103  format('DZ1: ', I5, 1x, 3E11.4)
      do jz = IZB + 1, IZB + NZ
         write (IFPL, 103) jz,
     $        VZ (jz, K1p), VZ (jz, K1m), VZ (jz, K1x)
      enddo
 104  format('DZ2: ', I5, 1x, 5E11.4)
      do jz = IZB + 1, IZB + NZ
            write (IFPL, 104) jz,
     $        VZ (jz, K2p), VZ (jz, K2o),
     $        VZ (jz, K2m), VZ (jz, K2x), VZ(jz,K2xi)
      enddo
      RETURN
      END
CCC_* primitives
CCC_ & MTFchg  ## horizontal gradient (central)
CCC_ & MTFwhg  ## horizontal gradient (foreward/backward)
CCC_ & MTFdzd  ## dZ/d[xyt] (element of jacobian matrix) times H
      subroutine MTFdzd
     M    (VT,
     I     VH,  VZ,
     I     KTV, KHDB, KHDH, KZZ,
     I     NH,  LH,   NZ,   LZ,  KZ0)
CCC_  - Description
CC       KHDB:  db/d[xyt]
CC       KHDH:  dH/d[xyt]
CC       KZZ:   zeta
CC
CC       dZ/da = - [db/da + Z dH/da] / H
CC       The final operation (div H) is intentionally not performed.
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  NH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
      _INTENT(INOUT,_REALSTD) VT (LH, LZ, *)
      _INTENT(IN,   _REALSTD) VH (LH, *)
      _INTENT(IN,   _REALSTD) VZ (LZ, *)
      _INTENT(IN,   integer)  KTV
      _INTENT(IN,   integer)  KHDB, KHDH
      _INTENT(IN,   integer)  KZZ
      integer  jh, jz, jzz
CCC_  - Body
CC    Tdztdt = - (THbt(l) + CKzeta(k) * THt(l)) / _DZH (ij)
      do jzz = 0, NZ - 1
         jz = KZ0 + jzz
         do jh = 1, NH
            VT (jh, jz, KTV) =
     $           - (VH (jh, KHDB) + VZ (jz, KZZ) * VH (jh, KHDH))
         enddo
      enddo
      RETURN
      END
CCC_ & MTFdzz  ## dZ/dz     (element of jacobian matrix)
      subroutine MTFdzz
     M    (VH,
     I     KHV, KHH,
     I     NH,  LH)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  NH, LH
      _INTENT(INOUT,_REALSTD) VH (LH, *)
      _INTENT(IN,   integer)  KHV
      _INTENT(IN,   integer)  KHH
      integer  jh
CCC_  - Body
      do jh = 1, NH
         VH (jh, KHV) = 1.0d0 / VH (jh, KHH)
      enddo
      RETURN
      END
CCC_ & MTFshc  ## strain heating component
      subroutine MTFshc
     M    (VT,
     I     KVSH,
     I     KVST, KVSR,
     I     NH,   LH,   NZ,  LZ, KZ0)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  NH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
      _INTENT(INOUT,_REALSTD) VT (LH, LZ, *)
      _INTENT(IN,   integer)  KVSH
      _INTENT(IN,   integer)  KVST, KVSR
      integer  jh, jz, jzz
CCC_  - Body
      do jzz = 0, NZ - 1
         jz = KZ0 + jzz
         do jh = 1, NH
            VT (jh, jz, KVSH) =
     $           VT (jh, jz, KVST) * VT (jh, jz, KVSR)
         enddo
      enddo
      RETURN
      END
CCC_ & MTFshi  ## strain heating (SIA)
      subroutine MTFshi
     M    (VT,
     I     KVSH,
     I     KVSTx, KVSTy,
     I     KVSRx, KVSRy,
     I     NH,    LH,   NZ,  LZ, KZ0)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  NH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
      _INTENT(INOUT,_REALSTD) VT (LH, LZ, *)
      _INTENT(IN,   integer)  KVSH
      _INTENT(IN,   integer)  KVSTx, KVSRx
      _INTENT(IN,   integer)  KVSTy, KVSRy
      integer  jh, jz, jzz
CCC_  - Body
      do jzz = 0, NZ - 1
         jz = KZ0 + jzz
         do jh = 1, NH
            VT (jh, jz, KVSH) =
     $           (VT (jh, jz, KVSTx) * VT (jh, jz, KVSRx)
     $           +VT (jh, jz, KVSTy) * VT (jh, jz, KVSRy)) * 2.0d0
         enddo
      enddo
      RETURN
      END
CCC_ & MTFshs  ## strain heating (SSA)
      subroutine MTFshs
     M    (VT,
     I     KVSH,
     I     KVSTx, KVSTy, KVSTr,
     I     KVSRx, KVSRy, KVSRr,
     I     NH,    LH,    NZ,   LZ,  KZ0)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  NH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
      _INTENT(INOUT,_REALSTD) VT (LH, LZ, *)
      _INTENT(IN,   integer)  KVSH
      _INTENT(IN,   integer)  KVSTx, KVSRx
      _INTENT(IN,   integer)  KVSTy, KVSRy
      _INTENT(IN,   integer)  KVSTr, KVSRr
      integer  jh, jz, jzz
CCC_  - Body
      do jzz = 0, NZ - 1
         jz = KZ0 + jzz
         do jh = 1, NH
            VT (jh, jz, KVSH) =
     $           ((VT (jh, jz, KVSTx) * VT (jh, jz, KVSRx)
     $            +VT (jh, jz, KVSTy) * VT (jh, jz, KVSRy))
     $            +VT (jh, jz, KVSTr) * VT (jh, jz, KVSRr))* 2.0d0
     $           +(VT (jh, jz, KVSTy) * VT (jh, jz, KVSRx)
     $            +VT (jh, jz, KVSTx) * VT (jh, jz, KVSRy))
         enddo
      enddo
      RETURN
      END
CCC_ & MTFshf  ## strain heating (full)
CCC_ & MTFbfc  ## basal friction (dissipation) component; inconsistent timing
      subroutine MTFbfc
     M    (VH,    KHFR,
     I     VT,    KTU,
     I     VW,    KWST,
     I     MH,    LH,   NZ,    LZ, KZ0)
CCC_  - Description
CC      check MTFbfr()
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
      _INTENT(INOUT,_REALSTD) VH(LH, *)
      _INTENT(IN,   integer)  KHFR
      _INTENT(IN,   _REALSTD) VT(LH, LZ, *)
      _INTENT(IN,   integer)  KTU
      _INTENT(IN,   _REALSTD) VW(LH, LZ, *)
      _INTENT(IN,   integer)  KWST
      integer  jh
CCC_  - Body
      do jh = 1, MH
         VH (jh, KHFR) = -(VW(jh, KZ0, KWST) * VT(jh, KZ0, KTU))
      enddo
      RETURN
      END
CCC_ & MTFbfd  ## basal friction (dissipation) component; consistent timing
      subroutine MTFbfd
     M    (VH,    KHFR,
     I     VT,    KTU,
     I     VI,    KIST,
     I     MH,    LH,   NZ,    LZ, KZ0)
CCC_  - Description
CC      check MTFbfr()
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
      _INTENT(INOUT,_REALSTD) VH(LH, *)
      _INTENT(IN,   integer)  KHFR
      _INTENT(IN,   _REALSTD) VT(LH, LZ, *)
      _INTENT(IN,   integer)  KTU
      _INTENT(IN,   _REALSTD) VI(LH, *)
      _INTENT(IN,   integer)  KIST
      integer  jh
CCC_  - Body
      do jh = 1, MH
         VH (jh, KHFR) = -(VI(jh, KIST) * VT(jh, KZ0, KTU))
      enddo
      RETURN
      END
CCC_ & MTFbfr  ## basal friction (dissipation)
      subroutine MTFbfr
     M    (VH, KHFR,
     I     VT, KTU,   KTV,
     I     VW, KWSTx, KWSTy,
     I     MH, LH,    NZ,    LZ, KZ0)
CCC_  - Description
CC    In terms of frictional heating, the sign should be plus
CC    This term is to be added to geothermal heat flux (negative),
CC    so must be the same sign.
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
      _INTENT(INOUT,_REALSTD) VH (LH, *)
      _INTENT(IN,   integer)  KHFR
      _INTENT(IN,   _REALSTD) VT (LH, LZ, *)
      _INTENT(IN,   integer)  KTU,   KTV
      _INTENT(IN,   _REALSTD) VW (LH, LZ, *)
      _INTENT(IN,   integer)  KWSTx, KWSTy
      integer  jh
CCC_  - Body
      do jh = 1, MH
         VH(jh, KHFR) =
     $        -(VW(jh, KZ0, KWSTx) * VT(jh, KZ0, KTU)
     $         +VW(jh, KZ0, KWSTy) * VT(jh, KZ0, KTV))
      enddo
      RETURN
      END
CCC_ & MTFbfb  ## basal friction (b)
      subroutine MTFbfb
     M    (VH,
     I     VT,
     I     KHFR,
     I     KHUb,  KHVb,
     I     KVSTx, KVSTy,
     I     NH,    LH,   NZ,  LZ, KZ0)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  NH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
      _INTENT(INOUT,_REALSTD) VH (LH, *)
      _INTENT(IN,   _REALSTD) VT (LH, LZ, *)
      _INTENT(IN,   integer)  KHFR
      _INTENT(IN,   integer)  KHUb,  KHVb
      _INTENT(IN,   integer)  KVSTx, KVSTy
      integer  jh
CCC_  - Body
      do jh = 1, NH
         VH (jh, KHFR) =
     $        -(VT (jh, KZ0, KVSTx) * VH (jh, KHUb)
     $         +VT (jh, KZ0, KVSTy) * VH (jh, KHVb))
      enddo
      RETURN
      END
CCC_ &   ## 3d conversion a to d
CCC_ &   ## 3d conversion bc to d
CCC_ & MTFeda  ## simple euler depth average (no bottom offset)
      subroutine MTFeda
     O    (VO,
     I     VI, DZ,
     I     NH, LH, NZ, LZ, KZ0)
      implicit none
      _INTENT(IN, integer)  NH, LH, NZ, LZ, KZ0
      _INTENT(OUT,_REALSTD) VO (LH)
      _INTENT(IN, _REALSTD) VI (LH, LZ)
      _INTENT(IN, _REALSTD) DZ (LZ)
      integer   jh, jz, jzz
CCC_  * Body
      do jh = 1, NH
         VO (jh) = 0.0d0
      enddo
c
      do jzz = 2, NZ
         jz = KZ0 + jzz - 1
         do jh = 1, NH
            VO (jh) = VO (jh) +
     $           0.5d0 * DZ (jz-1) *
     $           ((VI (jh, jz)) + VI (jh, jz - 1))
         enddo
      enddo
      RETURN
      END
CCC_ & MTFitc  ## thermal conductivity (temperature dependent)
      subroutine MTFitc
     M    (VO,
     I     VT,
     I     CI,    CP,
     I     MH,    LH,   NZ,    LZ, KZ0)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
      _INTENT(OUT,  _REALSTD) VO (LH, LZ)
      _INTENT(IN,   _REALSTD) VT (LH, LZ)
      _INTENT(IN,   _REALSTD) CI, CP
      integer  jh
      integer  jz
CCC_  - Body
      do jz = 1, KZ0 + NZ - 1
         do jh = 1, MH
            VO(jh, jz) = CI * exp(CP * VT(jh, jz))
         enddo
      enddo
      RETURN
      END
CCC_ & MTFhct  ## spedific heat capacity (temperature dependent)
      subroutine MTFhct
     M    (VO,
     I     VT,
     I     C0,    C1,
     I     MH,    LH,   NZ,    LZ, KZ0)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
      _INTENT(OUT,  _REALSTD) VO (LH, LZ)
      _INTENT(IN,   _REALSTD) VT (LH, LZ)
      _INTENT(IN,   _REALSTD) C0, C1
      integer  jh
      integer  jz
CCC_  - Body
c$$$      write (*, *) 'HCT', C0, C1
      do jz = 1, KZ0 + NZ - 1
         do jh = 1, MH
            VO(jh, jz) = C0 + C1 * VT(jh, jz)
         enddo
      enddo
      RETURN
      END
CCC_& MTFUNC  ## Movement/Thermodynamics/function announcement
      subroutine MTFUNC (STRA, STRB, IOP)
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
CCC_* Test
CCC_ + begin
#if TEST_MTFUNC
CCC_ @ MTFTST  ## Test program
      program MTFTST
CCC_  - Test suites
CCC_  - Declaration
      implicit none
#include "ofnstd.h"
#include "odevid.h"
      integer iErr
      integer ipA (LOG_CHANNEL_MAX)
      integer iMA (MAX_MPI_ATTR)
CCC_  - Body
      call DDcapo
     O    (iErr,
     I     2, ' ', 'O', _FNAME, -1)
      if (iErr.eq.0) then
         call DLCmng (ipA, 't')
         call DMAtma (iMA)
         call MTFTSTmain (iErr, ipA)
         call ACCrep (FPL(ipA), 2)
      endif
      call DevFin (iErr)
      STOP
      END
CCC_ & MTFTSTmain  ## Test main
      subroutine MTFTSTmain (iErr, ipA)
#include "movement.h"
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)  iErr
      _INTENT(IN, integer)  ipA (*)
CCC_   . Vertical layers
      integer    LZref
      parameter (LZref = 256 + 1)
      integer    NZdef
      integer    NZ,  LZ
      integer    KZ0, IZT, IZB, NZX
      _REALSTD VMZ (LZref * VMVZ_MAX)
      integer  icGz (2), icZa, icZb
      _REALSTD X   (LZref, 5)
CCC_   . Horizontal
      integer    LH
      parameter (LH = 2)
      integer    NH
CCC_   . Coordinate
      character  CROOT*(32)
CCC_   . work area
      integer    LW
      parameter (LW = 512)
      _REALSTD   W(LW)
CCC_   . i/o
      integer ipL, ipP, ipC
CCC_   . misc
      integer jh, jz, jz0, jkz
      integer KVZ
c
      integer   icF
      integer   jedmy, jcdmy
CCC_  - Body
      iErr  = 0
c
      ipL = FPL(ipA)
      ipP = FPP(ipA)
      ipC = FPC(ipA)
CCC_   . domain configuration
      CROOT   = 'ID'
      NH      = 1
c
      NZdef   = 8 + 1
      IZT     = 1
      IZB     = 1
c
      call ACCrgR (jedmy, icF, 0, CROOT, ipL)
c
      call AMZcns
     O    (iErr,
     W     W,     LW,
     O     NZ,    LZ,    KZ0,
     I     NZdef, LZref, IZB, IZT,  icF, CROOT, ipP, ipC, ipL)
      call ACCrfI (jedmy, jcdmy, icGz, icF, -1, 'Z', ipL)
      icZa = icGz (1)
      icZb = icGz (2)
c     force overwrite
c$$$      LZ  = LZref
      NZX = KZ0 + NZ
      call MTFvgt
     O    (iErr,
     W     W,
     O     VMZ,
     I     VMVZ_Za,    VMVZ_dPb,
     I     VMVZ_dWPb,  VMVZ_dWMb,  VMVZ_dXa,
     I     VMVZ_ddWPa, VMVZ_ddWOa, VMVZ_ddWMa, VMVZ_ddXa, VMVZ_iddXa,
     I     VMVZ_Lap,   VMVZ_Lam,   VMVZ_Lbp,   VMVZ_Lbm,
     I     NZ, LZ,  IZB, icZa,  icZb,  ipL)
c
 102  format ('ZRANGE:', 4I4)
      write (ipL, 102) NZ, LZ, KZ0, NZX
 101  format ('ZCHK:', I2.2, 1x, I3.3, 1x, F10.6)
c
c$$$      do jkz = VMZ_dWPb, VMZ_ddXa
c$$$         do jz = 1, NZX
c$$$            write (ipL, 101) jkz, jz, VMZ ((jkz-1)*LZ+jz-1)
c$$$         enddo
c$$$      enddo
      call MTFTSTdz
     W    (X,
     I     VMZ, NZ, LZ, KZ0)
c
      RETURN
      END
CCC_ & MTFTSTdz  ## Test main
      subroutine MTFTSTdz
     W    (X,
     I     VMZ, NZ, LZ, KZ0)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)  NZ, LZ, KZ0
      _INTENT(OUT,_REALSTD) X   (LZ, *)
      _INTENT(IN, _REALSTD) VMZ (LZ, *)
      integer jz, jzz
CCC_  - Body
      do jz = 1, KZ0 + NZ
         X (jz, 1) = VMZ (jz, VMVZ_Za) ** 4.0d0 + VMZ (jz, VMVZ_Za)
c$$$         X (jz, 1) = VMZ (jz, VMVZ_Za) ** 4.0d0
c$$$         X (jz, 1) = VMZ (jz, VMVZ_Za) ** 2.0d0
c$$$         write (*, *) 'X', jz, VMZ (jz, VMVZ_Za), X (jz, 1)
      enddo
      do jzz = 0, NZ - 1
         jz = KZ0 + jzz
         X (jz, 2) =
     $        (X (jz,   1) * VMZ (jz, VMVZ_dWMb)
     $        +X (jz+1, 1) * VMZ (jz, VMVZ_dWPb))
      enddo
      do jzz = 0, NZ - 1
         jz = KZ0 + jzz
         X (jz, 3) =
     $        (X (jz-1, 1) * VMZ (jz, VMVZ_ddWMa)
     $        +X (jz,   1) * VMZ (jz, VMVZ_ddWOa)
     $        +X (jz+1, 1) * VMZ (jz, VMVZ_ddWPa))
      enddo
      do jzz = 0, NZ - 1
         jz = KZ0 + jzz
         X (jz, 4) = X (jz, 2) * VMZ (jz, VMVZ_dXa)
         X (jz, 5) = X (jz, 3) * (VMZ (jz, VMVZ_dXa) ** 2.0d0)
     $             + X (jz, 2) * VMZ (jz, VMVZ_ddXa)
      enddo
c
      do jz = 1, KZ0 + NZ - 1
         write (*, *) 'xZETA', jz, VMZ (jz, VMVZ_Za)
      enddo
      do jzz = 0, NZ - 1
         jz = KZ0 + jzz
         write (*, *) 'xC1', jz, VMZ (jz, VMVZ_dXa)
      enddo
      do jzz = 0, NZ - 1
         jz = KZ0 + jzz
         write (*, *) 'xC2', jz, VMZ (jz, VMVZ_ddXa)
      enddo
      do jzz = 0, NZ - 1
         jz = KZ0 + jzz
         write (*, *) 'xX', VMZ (jz, VMVZ_Za), X (jz, 1)
      enddo
      do jzz = 0, NZ - 1
         jz = KZ0 + jzz
         write (*, *) 'xD1', VMZ (jz, VMVZ_Za), X (jz, 2)
      enddo
      do jzz = 0, NZ - 1
         jz = KZ0 + jzz
         write (*, *) 'xD2', VMZ (jz, VMVZ_Za), X (jz, 3)
      enddo
      do jzz = 0, NZ - 1
         jz = KZ0 + jzz
         write (*, *) 'xDXDZ', VMZ (jz, VMVZ_Za), X (jz, 4)
      enddo
      do jzz = 0, NZ - 1
         jz = KZ0 + jzz
         write (*, *) 'xDDXDZ', VMZ (jz, VMVZ_Za), X (jz, 5)
      enddo
c$$$      do jzz = 0, NZ - 1
c$$$         jz = KZ0 + jzz
c$$$         write (*, *) 'DZ',  jz, VMZ (jz, VMVZ_Zb), X (jz, 2)
c$$$      enddo
      return
      end
CCC_ + end
#endif /* TEST_MTFUNC */
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
