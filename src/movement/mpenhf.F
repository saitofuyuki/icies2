C movement/mpenhf.F --- IcIES/Movement/Enhancement-factor
C Maintainer:  SAITO Fuyuki
C Created: Feb 28 2012
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2020/09/17 08:46:20 fuyuki mpenhf.F>'
#define _FNAME 'movement/mpenhf.F'
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
#include "movement.h"
CCC_* Parameter cluster
#define MEF_CONST 1
CCC_* Primitives
CCC_ & MPEstp  ## Enhancement-factor set parameter clusters
      subroutine MPEstp
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
      _REALSTD  ENFC
CCC_  * Body
      iErr = (((0 * ipP) * ipL) * ipC) * KSW
      if (CTAG.eq.' ') continue
c$$$      iErr = 0
c
      call MPEdef (ENFC)
c
      PG (MEF_CONST) = ENFC
c
      RETURN
      END
CCC_ & MPEdef  ## Enhancement-factor get default parameters
      subroutine MPEdef
     O    (ENFC)
      implicit none
      _INTENT(OUT,_REALSTD)  ENFC
c
      ENFC = 1.0d0
c
      RETURN
      END
CCC_ & MPEset  ## Enhancement-factor set
      subroutine MPEset
     M    (VMV,
     I     PG,
     I     KVE, NH, LH, NZ, LZ)
      implicit none
      _INTENT(IN,   integer)  NH,  LH, NZ, LZ
      _INTENT(INOUT,_REALSTD) VMV (LH, LZ, *)
      _INTENT(IN,   _REALSTD) PG (*)
      _INTENT(IN,   integer)  KVE
      integer jh, jz
      do    jz = 1, NZ
         do jh = 1, NH
            VMV (jh, jz, KVE) = PG (MEF_CONST)
         enddo
      enddo
      RETURN
      END
CCC_ & MPEctc  ## Enhancement-factor (simple category) cluster
      subroutine MPEctc
     O    (VEF,
     I     VCT, PMM, NH, LH, NZ, LZ, KZ0)
      implicit none
      _INTENT(IN, integer)  NH,  LH,  NZ, LZ, KZ0
      _INTENT(OUT,_REALSTD) VEF (LH,  LZ)
      _INTENT(IN, _REALSTD) VCT (LH)
      _INTENT(IN, _REALSTD) PMM (*)
      integer jh, jz, jz0
c
      _REALSTD EFGR, EFSH
c
      EFGR  = PMM  (PMD_EFC)
      EFSH  = PMM  (PMD_EFCSH)
c
      do jz0 = 0, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, NH
            if (VCT(jh).eq. _dSH) then
               VEF(jh, jz) = EFSH
            else
               VEF(jh, jz) = EFGR
            endif
         enddo
      enddo
CCC_  - for safety
      do jz0 = 0, NZ - 1
         jz = KZ0 + jz0
         do jh = NH + 1, LH
            VEF(jh, jz) = EFGR
         enddo
      enddo
      RETURN
      END
CCC_& MPENHF  ## Movement/Enhancement-factor announcement
      subroutine MPENHF (STRA, STRB, IOP)
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
CCC_@ MPETST  ## not implemented
CCC_ + Test suites
CC::   KINDS 0
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
