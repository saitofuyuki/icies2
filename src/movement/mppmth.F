C movement/mppmth.F --- IcIES/Movement/Pressure-melting point (constant density)
C Maintainer:  SAITO Fuyuki
C Created: Jan 5 2012
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2016/08/19 15:06:37 fuyuki mppmth.F>'
#define _FNAME 'movement/mppmth.F'
#define _REV   'Snoopy0.9'
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
#include "movement.h" /* parameter cluster */
CCC_* Parameter cluster
#define MPP_T0 1
#define MPP_CC 2
CCC_* Primitives
CCC_ & MPPstp  ## Pressure-melting set parameter clusters
      subroutine MPPstp
     O    (iErr,
     O     PG,
     I     KSW, CTAG, ipP, ipL, ipC)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,_REALSTD)  PG (*)
      _INTENT(IN, integer)   KSW
      _INTENT(IN, character) CTAG*(*)
      _INTENT(IN, integer)   ipP, ipL, ipC
c
      _REALSTD  T0, CC
      integer    LU
      parameter (LU = 32)
      character UT0*(LU), UCC*(LU)
CCC_  * Body
c$$$      iErr = 0
CC    to avoid warning
      iErr = (((0 * ipP) * ipL) * ipC) * KSW
      if (CTAG.eq.' ') continue
c
      call MPPdef (T0, UT0, CC, UCC)
c
      PG (MPP_T0) = T0
      PG (MPP_CC) = CC
c
      RETURN
      END
CCC_ & MPPdef  ## Pressure-melting point get default parameters
      subroutine MPPdef
     O    (T0, UT0,
     O     CC, UCC)
      implicit none
      _INTENT(OUT,_REALSTD)  T0,      CC
      _INTENT(OUT,character) UT0*(*), UCC*(*)
c
      T0   = 273.15d0
      UT0  = 'K'
c
      CC   = 8.7d-4
      UCC  = 'K/m'
c
      RETURN
      END
CCC_ & MPPpmt  ## Pressure melting point (with parameters)
      subroutine MPPpmt
     M    (VMT,
     I     VMH,  ZC,
     I     T0,   CC,
     I     KTX,  KHH,  NH, LH, NZ, LZ, KZ0)
      implicit none
      _INTENT(IN, integer)  NH,  LH, NZ, LZ, KZ0
      _INTENT(OUT,_REALSTD) VMT (LH, LZ, *)
      _INTENT(IN, _REALSTD) VMH (LH, *)
      _INTENT(IN, _REALSTD) ZC (*)
      _INTENT(IN, integer)  KTX
      _INTENT(IN, integer)  KHH
      _INTENT(IN, _REALSTD) T0, CC
      integer jh, jz, jz0
      _REALSTD HLD, PMT
CC   Tc = T + CC H (1-z)
      do jz0 = 0, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, NH
            HLD = VMH (jh, KHH) * ZC (jz)
            PMT = CC * HLD
            VMT (jh, jz, KTX) = T0 - PMT
         enddo
      enddo
      RETURN
      END
CCC_ & MPPdtc  ## Temperature correction (and set adjustment)
      subroutine MPPdtc
     M    (VMT, VMW,
     I     VMH, ZC,
     I     T0,  CC,
     I     KTT, KWD, KHH, NH, LH, NZ, LZ, KZ0)
      implicit none
      _INTENT(IN,   integer)  NH,  LH, NZ, LZ, KZ0
      _INTENT(INOUT,_REALSTD) VMT (LH, LZ, *)
      _INTENT(INOUT,_REALSTD) VMW (LH, LZ, *)
      _INTENT(IN,   _REALSTD) VMH (LH, *)
      _INTENT(IN,   _REALSTD) ZC (*)
      _INTENT(IN,   integer)  KTT, KWD
      _INTENT(IN,   integer)  KHH
      _INTENT(IN,   _REALSTD) T0, CC
      integer jh, jz, jz0
      _REALSTD HLD, PMT
C ZC = 1 - zeta
c$$$            Tpmt = Ptrpl - PClcl * BAthik(ij) * TKZTRV(k)
c$$$            AOtemp(ij,k) = MIN( AOtemp(ij,k), Tpmt )
c$$$            AOThmo(ij,k) = AOtemp(ij,k) - Tpmt + Ptrpl
CC   Tc = T + CC H (1-z)
      do jz0 = 0, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, NH
            HLD = VMH (jh, KHH) * ZC (jz)
            PMT = T0 - CC * HLD
            VMW (jh, jz, KWD) = MAX (0.0d0, VMT (jh, jz, KTT) - PMT)
            VMT (jh, jz, KTT) = MIN (VMT (jh, jz, KTT), PMT)
         enddo
      enddo
      RETURN
      END
CCC_ & MPPptc  ## Temperature correction (with parameters)
      subroutine MPPptc
     M    (VMV,
     I     VMD,  ZC,
     I     T0,   CC,
     I     KVTC, KVT, KDH, NH, LH, NZ, LZ, KZ0)
      implicit none
      _INTENT(IN,   integer)  NH,  LH, NZ, LZ, KZ0
      _INTENT(INOUT,_REALSTD) VMV (LH, LZ, *)
      _INTENT(IN,   _REALSTD) VMD (LH, *)
      _INTENT(IN,   _REALSTD) ZC (LZ)
      _INTENT(IN,   integer)  KVTC
      _INTENT(IN,   integer)  KVT, KDH
      _INTENT(IN,   _REALSTD) T0, CC
      integer jh, jz, jz0
      _REALSTD HLD, PMT
C ZC = 1 - zeta
c$$$            Tpmt = Ptrpl - PClcl * BAthik(ij) * TKZTRV(k)
c$$$            AOtemp(ij,k) = MIN( AOtemp(ij,k), Tpmt )
c$$$            AOThmo(ij,k) = AOtemp(ij,k) - Tpmt + Ptrpl
CC   Tc = T + CC H (1-z)
      do jz0 = 0, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, NH
            HLD = VMD (jh, KDH) * ZC (jz)
            PMT = CC * HLD
c$$$            write (*, *) 'TC', ZC (jz)
c$$$            write (*, *) 'TC', jh, jz0,
c$$$     $           PMT, T0, HLD,
c$$$     $           VMV (jh, jz, KVT)
            VMV (jh, jz, KVTC)
     $           = min ((VMV (jh, jz, KVT) + PMT), T0)
         enddo
      enddo
      RETURN
      END
CCC_ & MPPtcr  ## Temperature correction
      subroutine MPPtcr
     M    (VMV,
     I     VMD, ZC,
     I     PG,
     I     KVTC, KVT, KDH, NH, LH, NZ, LZ, KZ0)
      implicit none
      _INTENT(IN,   integer)  NH,  LH, NZ, LZ, KZ0
      _INTENT(INOUT,_REALSTD) VMV (LH, LZ, *)
      _INTENT(IN,   _REALSTD) VMD (LH, *)
      _INTENT(IN,   _REALSTD) ZC (LZ)
      _INTENT(IN,   integer)  KVTC
      _INTENT(IN,   integer)  KVT, KDH
      _INTENT(IN,   _REALSTD) PG (*)
      integer jh, jz, jz0
      _REALSTD HLD, PMT
      _REALSTD T0,  CC
C ZC = 1 - zeta
c$$$            Tpmt = Ptrpl - PClcl * BAthik(ij) * TKZTRV(k)
c$$$            AOtemp(ij,k) = MIN( AOtemp(ij,k), Tpmt )
c$$$            AOThmo(ij,k) = AOtemp(ij,k) - Tpmt + Ptrpl
CC   Tc = T + CC H (1-z)
      T0 = PG (MPP_T0)
      CC = PG (MPP_CC)
      do jz0 = 0, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, NH
            HLD = VMD (jh, KDH) * ZC (jz)
            PMT = CC * HLD
            VMV (jh, jz, KVTC)
     $           = min ((VMV (jh, jz, KVT) + PMT), T0)
         enddo
      enddo
      RETURN
      END
CCC_ & MPPtcc  ## Temperature correction with cluster
      subroutine MPPtcc
     M    (VTO,
     I     VTI, VH, ZC,
     I     PMM,
     I     NH, LH, NZ, LZ, KZ0)
      implicit none
      _INTENT(IN,   integer)  NH,  LH, NZ, LZ, KZ0
      _INTENT(OUT,_REALSTD) VTO (LH, LZ)
      _INTENT(IN, _REALSTD) VTI (LH, LZ)
      _INTENT(IN, _REALSTD) VH (LH)
      _INTENT(IN, _REALSTD) ZC (LZ)
      _INTENT(IN, _REALSTD) PMM (*)
      integer jh, jz, jz0
      _REALSTD HLD, PMT
      _REALSTD T0,  CC
C ZC = 1 - zeta
CC   Tc = T + CC H (1-z)
      T0 = PMM (PMT_T0)
      CC = PMM (PMT_CLCLD)
      do jz0 = 0, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, NH
            HLD = VH (jh) * ZC (jz)
            PMT = CC * HLD
            VTO (jh, jz) = min ((VTI (jh, jz) + PMT), T0)
         enddo
      enddo
      RETURN
      END
CCC_ & MPPprH  ## Pressure melting point by H (constant density) 2d
CCC_& MPPMTH  ## Movement/Pressure-melting point announcement
      subroutine MPPMTH (STRA, STRB, IOP)
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
CCC_@ MPPTST  ## not implemented
CCC_ + Test suites
CC::   KINDS 0
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
