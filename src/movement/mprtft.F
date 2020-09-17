C movement/mprtft.F --- IcIES/Movement/Rate-factor (temperature dependent)
C Maintainer:  SAITO Fuyuki
C Created: Jan 5 2012
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2016/08/19 16:16:21 fuyuki mprtft.F>'
#define _FNAME 'movement/mprtft.F'
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
#include "movement.h"
CCC_* Parameter cluster
#define MPR_TM 1
#define MPR_QL 2
#define MPR_QH 3
#define MPR_AL 4
#define MPR_AH 5
#define MPR_RG 6
CCC_* Primitives
CCC_ & MPRstp  ## Rate-factor set parameter clusters
      subroutine MPRstp
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
      _REALSTD  TM, QL, AL, QH, AH, Rgas
      integer    LU
      parameter (LU = 32)
      character UTM*(LU), UQ*(LU), UA*(LU), UR*(LU)
CCC_  * Body
      iErr = (((0 * ipP) * ipL) * ipC) * KSW
      if (CTAG.eq.' ') continue
c$$$      iErr = 0
c
      call MPRdef (TM, UTM, QL, QH, UQ, AL, AH, UA, Rgas, UR)
c
      PG (MPR_RG) = Rgas
      PG (MPR_TM) = TM
      PG (MPR_QL) = QL
      PG (MPR_QH) = QH
      PG (MPR_AL) = AL
      PG (MPR_AH) = AH
c
      RETURN
      END
CCC_ & MPRdef  ## Rate-factor get default parameters
      subroutine MPRdef
     O    (TM,     UTM,
     O     QL, QH, UQ,
     O     AL, AH, UA,
     O     Rgas,   UR)
      implicit none
      _INTENT(OUT,_REALSTD)  TM, QL, AL, QH, AH
      _INTENT(OUT,_REALSTD)  Rgas
      _INTENT(OUT,character) UTM*(*)
      _INTENT(OUT,character) UQ*(*), UA*(*), UR*(*)
c
      _REALSTD YSEC
c
      TM   = 263.15d0
      UTM  = 'K'
c
      QL   = 6.0d4
      QH   = 13.9d4
      UQ   = ' '
c
      YSEC = 31556926.0d0
      AL   = 3.61d-13 * YSEC
      AH   = 1.73d3 * YSEC
      UA   = 'Pa^-3 yr^-1'
c
      Rgas = 8.314d0
      UR   = 'J mol^-1 K^-1'
c
      RETURN
      END
CCC_ & MPRprA  ## Rate-factor A/standard 2d (compatible with FLOWA)
      subroutine MPRprA
     M    (VMV,
     I     PG,
     I     KVA,  KVTC, NH, LH, NZ, LZ, KZ0)
      implicit none
      _INTENT(IN,   integer)  NH,  LH,  NZ, LZ, KZ0
      _INTENT(INOUT,_REALSTD) VMV (LH,  LZ, *)
      _INTENT(IN,   _REALSTD) PG (*)
      _INTENT(IN,   integer)  KVA
      _INTENT(IN,   integer)  KVTC
      integer jh, jz, jz0
      _REALSTD Rgas, TM, QL, AL, QH, AH
      _REALSTD Q, A, QLR, QHR
c
      Rgas = PG (MPR_RG)
      TM   = PG (MPR_TM)
      QL   = PG (MPR_QL)
      QH   = PG (MPR_QH)
      AL   = PG (MPR_AL)
      AH   = PG (MPR_AH)
c
      QLR = - QL / Rgas
      QHR = - QH / Rgas
      do jz0 = 0, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, NH
            if (VMV (jh, jz, KVTC) .lt. TM) then
               Q = QLR
               A = AL
            else
               Q = QHR
               A = AH
            endif
            VMV (jh, jz, KVA) = A * exp (Q / VMV (jh, jz, KVTC))
         enddo
      enddo
      RETURN
      END
CCC_ & MPRfaS  ## Rate-factor S/SIGN 2d (compatible with FLOWAR)
      subroutine MPRfaS
     M    (VMV,
     I     Rgas, TM,   QL, QH, AL, AH,
     I     KVA,  KVTC, NH, LH, NZ, LZ, KZ0)
      implicit none
      _INTENT(IN,   integer)  NH,  LH,  NZ, LZ, KZ0
      _INTENT(INOUT,_REALSTD) VMV (LH,  LZ, *)
      _INTENT(IN,   _REALSTD) Rgas, TM, QL, AL, QH, AH
      _INTENT(IN,   integer)  KVA
      _INTENT(IN,   integer)  KVTC
      integer jh, jz, jz0
      _REALSTD Q, A, QLR, QHR, TS
      _REALSTD TT
c
      QLR = - QL / Rgas
      QHR = - QH / Rgas
c
      do jz0 = 0, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, NH
            TT = MAX (1.0d0, VMV (jh, jz, KVTC))
            TS  = SIGN (0.5d0, TT - TM) + 0.5d0
            Q   = QLR * (1.0d0 - TS) + QHR * TS
            A   = AL  * (1.0d0 - TS) + AH  * TS
c$$$            write (*, *) 'RF', jh, jz0, TT
            VMV (jh, jz, KVA) = A * exp (Q / TT)
         enddo
      enddo
      RETURN
      END
CCC_ & MPRfaC  ## Rate-factor S/SIGN 2d (compatible with FLOWAR) with cluster
      subroutine MPRfaC
     O    (VRF,
     I     VTC, IMM, PMM, NH, LH, NZ, LZ, KZ0)
      implicit none
      _INTENT(IN, integer)  NH,  LH,  NZ, LZ, KZ0
      _INTENT(OUT,_REALSTD) VRF (LH,  LZ)
      _INTENT(IN, _REALSTD) VTC (LH,  LZ)
      _INTENT(IN, integer)  IMM (*)
      _INTENT(IN, _REALSTD) PMM (*)
      integer jh, jz, jz0
      _REALSTD Rgas, TM, QL, AL, QH, AH
      _REALSTD Q, A, QLR, QHR, TS
      _REALSTD TT
c
c$$$CC TEST
c$$$      do jz0 = 0, NZ - 1
c$$$         jz = KZ0 + jz0
c$$$         do jh = 1, NH
c$$$            VRF (jh, jz) = 1.546289374d-17
c$$$         enddo
c$$$      enddo
c$$$      return
      if (IMM(IMD_RF) .eq. SW_RF_CONST) then
         do jz0 = 0, NZ - 1
            jz = KZ0 + jz0
CCC_  - LH for safety
            do jh = 1, LH
               VRF (jh, jz) = PMM(PMD_RFC)
            enddo
         enddo
      else
         Rgas = PMM (PMD_RGAS)
         TM   = PMM (PMD_TM)
         QL   = PMM (PMD_QL)
         QH   = PMM (PMD_QH)
         AL   = PMM (PMD_AL)
         AH   = PMM (PMD_AH)
c
         QLR = - QL / Rgas
         QHR = - QH / Rgas
c
         do jz0 = 0, NZ - 1
            jz = KZ0 + jz0
            do jh = 1, NH
               TT = MAX (1.0d0, VTC (jh, jz))
               TS  = SIGN (0.5d0, TT - TM) + 0.5d0
               Q   = QLR * (1.0d0 - TS) + QHR * TS
               A   = AL  * (1.0d0 - TS) + AH  * TS
               VRF (jh, jz) = A * exp (Q / TT)
            enddo
         enddo
         do jz0 = 0, NZ - 1
            jz = KZ0 + jz0
            do jh = NH + 1, LH
               TT = TM
               TS  = SIGN (0.5d0, TT - TM) + 0.5d0
               Q   = QLR * (1.0d0 - TS) + QHR * TS
               A   = AL  * (1.0d0 - TS) + AH  * TS
               VRF (jh, jz) = A * exp (Q / TT)
            enddo
         enddo
      endif
      RETURN
      END
CCC_ & MPRprS  ## Rate-factor S/SIGN 2d (compatible with FLOWAR)
      subroutine MPRprS
     M    (VMV,
     I     PG,
     I     KVA,  KVTC, NH, LH, NZ, LZ, KZ0)
      implicit none
      _INTENT(IN,   integer)  NH,  LH,  NZ, LZ, KZ0
      _INTENT(INOUT,_REALSTD) VMV (LH,  LZ, *)
      _INTENT(IN,   _REALSTD) PG (*)
      _INTENT(IN,   integer)  KVA
      _INTENT(IN,   integer)  KVTC
      integer jh, jz, jz0
      _REALSTD Rgas, TM, QL, AL, QH, AH
      _REALSTD Q, A, QLR, QHR, TS
c
      Rgas = PG (MPR_RG)
      TM   = PG (MPR_TM)
      QL   = PG (MPR_QL)
      QH   = PG (MPR_QH)
      AL   = PG (MPR_AL)
      AH   = PG (MPR_AH)
c
      QLR = - QL / Rgas
      QHR = - QH / Rgas
c
      do jz0 = 0, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, NH
            TS  = SIGN (0.5d0, VMV (jh, jz, KVTC) - TM) + 0.5d0
            Q   = QLR * (1.0d0 - TS) + QHR * TS
            A   = AL  * (1.0d0 - TS) + AH  * TS
            VMV (jh, jz, KVA) = A * exp (Q / VMV (jh, jz, KVTC))
         enddo
      enddo
      RETURN
      END
CCC_& MPRTFT  ## Movement/Rate-factor announcement
      subroutine MPRTFT (STRA, STRB, IOP)
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
CCC_@ MPRTST  ## not implemented
CCC_ + Test suites
CC::   KINDS 0
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
