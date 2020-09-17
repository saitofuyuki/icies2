C development/duntms.F --- IcIES/Development/Units manipulation
C Maintainer:  SAITO Fuyuki
C Created: Nov 20 2019
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2020/09/17 08:43:28 fuyuki duntms.F>'
#define _FNAME 'development/doptms.F'
#define _REV   'Snoopy0.97'
CCC_! MANIFESTO
C
C Copyright (C) 2019, 2020
C           Japan Agency for Marine-Earth Science and Technology
C
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
CCC_* Macros
#include "ofdlct.h" /* fortran dialect */
#include "ologfm.h" /* logging */
#include "ounits.h" /* units */
#include "ounelv.h"
CCC_ + Options
#ifndef    OPT_NAMELIST_OUTPUT_EMULATION
#  define  OPT_NAMELIST_OUTPUT_EMULATION _UNMLEM_LEVEL_END
#endif
CCC_ + Sizes
#ifndef    OPT_UNITS_IATTR_LIM
#  define  OPT_UNITS_IATTR_LIM   2048
#endif
#ifndef    OPT_UNITS_CATTR_LIM
#  define  OPT_UNITS_CATTR_LIM   2048
#endif
#ifndef    OPT_UNITS_RATTR_LIM
#  define  OPT_UNITS_RATTR_LIM   2048
#endif
CCC_ + Macros
#define _UNIT_DEF  ' '
#define _UNIT_AUTO '='
CCC_* Interfaces
CCC_ & DUinit  ## Development/Unit initialization
      subroutine DUinit
     O    (iErr,
     I     NHUS, NHUD, NHUC,
     I     ipP,  ipC,  ipL)
CCC_  - Declaration
      implicit none
CCC_   . arguments
      _INTENT(OUT,integer) iErr
      _INTENT(IN, integer) NHUS, NHUD, NHUC
      _INTENT(IN, integer) ipP,  ipC,  ipL
CCC_  - Body
      iErr = 0
      call DUBmng(iErr, ipP, ipC, ipL)
      call DUBini(iErr, NHUS, NHUD, NHUC)
      call DUBdef(iErr)
      RETURN
      END
CCC_ & DUfine  ## Development/Unit finialization
      subroutine DUfine(iErr)
CCC_  - Declaration
      implicit none
CCC_   . arguments
      _INTENT(OUT,integer) iErr
CCC_  - Body
      iErr = 0
      call DUBrep(iErr)
      RETURN
      END
CCC_ & DUregD  ## Development/Unit register quantity
      subroutine DUregD
     O    (iErr,
     I     qTgt, uDef)
      implicit none
      _INTENT(OUT,integer)  ierr
      _INTENT(IN,character) qTgt*(*), uDef*(*)
      iErr = 0
      call DUBrgD(iErr, qTgt, uDef)
      return
      end
CCC_ & DUregP  ## Development/Unit register (power)
      subroutine DUregP
     O    (iErr,
     I     qTgt, uBas, P)
      implicit none
      _INTENT(OUT,integer)  ierr
      _INTENT(IN,character) qTgt*(*), uBas*(*)
      _INTENT(IN,_REALSTD)  P
      iErr = 0
      call DUBrgP(iErr, qTgt, uBas, P)
      return
      end
CCC_ & DUregC  ## Development/Unit register conversion
      subroutine DUregC
     O    (idX,
     I     qTgt, qSrc)
      implicit none
      _INTENT(OUT,integer)  idX
      _INTENT(IN,character) qTgt*(*), qSrc*(*)
      integer jErr
      call DUBrgC(jErr, idX, qTgt, qSrc)
      return
      end
CCC_ & DUcnvS  ## Development/Unit conversion single
      subroutine DUcnvS (V, idX)
      implicit none
      _INTENT(INOUT,_REALSTD) V
      _INTENT(IN,   integer)  idX
      call DUBcvS(V, idX)
      RETURN
      END
CCC_ & DUcnvA  ## Development/Unit conversion array
      subroutine DUcnvA (V, N, idX)
      implicit none
      _INTENT(INOUT,_REALSTD) V(*)
      _INTENT(IN,   integer)  N
      _INTENT(IN,   integer)  idX
      call DUBcvA(V, N, idX)
      RETURN
      END
CCC_ & DUchek  ## Development/Unit check dimension
      subroutine DUchek
     O    (iErr,
     I     qTgt, qRef)
      implicit none
      _INTENT(OUT,integer)  ierr
      _INTENT(IN,character) qTgt*(*), qRef*(*)
      iErr = 0
      call DUBchk(iErr, qTgt, qRef)
      RETURN
      END
CCC_* Buffer
CCC_ & DUBmng ## Development/Unit buffer management
      subroutine DUBmng(iErr, ipPa, ipCa, ipLa)
CCC_  - Declaration
      implicit none
CCC_   . arguments
      _INTENT(OUT,  integer) iErr
      _INTENT(OUT,  integer) idXo
c
      _INTENT(INOUT,_REALSTD) VS
      _INTENT(INOUT,_REALSTD) VA(*)
      _INTENT(IN,   integer)  idXi
      _INTENT(IN,   integer)  N
c
      _INTENT(IN,   integer)  ipPa, ipCa, ipLa
      _INTENT(IN,   integer)  NHUS, NHUD, NHUC
c
      _INTENT(IN,   character) uBas*(*)
      _INTENT(IN,   character) uDef*(*)
      _INTENT(IN,   character) qTgt*(*)
      _INTENT(IN,   character) qRef*(*)
      _INTENT(IN,   character) qSrc*(*)
      _INTENT(IN,   _REALSTD)  P
CCC_   . unit attribute cluster
      integer    LKB, LSB, LAB
      parameter (LKB = OPT_UNITS_IATTR_LIM)
      parameter (LSB = OPT_UNITS_RATTR_LIM)
      parameter (LAB = OPT_UNITS_CATTR_LIM)
      integer    KU(LKB)
      _REALSTD   SU(LSB)
      character  AU(LAB)*(OPT_UNIT_LEN)
      SAVE       KU, SU, AU
CCC_   . i/o units
      integer ipP, ipC, ipL
      data    ipP, ipC, ipL  /-1, -1, -1/
      save    ipP, ipC, ipL
CCC_  - Body
      iErr = 0
      ipP = ipPa
      ipC = ipCa
      ipL = ipLa
      RETURN
CCC_  & DUBini ## initialization
      entry DUBini (iErr, NHUS, NHUD, NHUC)
      iErr = 0
      call UXinit
     $    (iErr,
     $     KU, SU, AU, LKB, LSB, LAB, NHUS, NHUD, NHUC, 0, ipL)
      RETURN
CCC_  & DUBrep ## report
      entry DUBrep (iErr)
      iErr = 0
      call UXMrep (iErr, ipL,  KU,SU,AU)
      RETURN
CCC_  & DUBdef ## set default
      entry DUBdef (iErr)
      iErr = 0
      call DUCdfs(iErr, KU, SU, AU, 99999, ipL)
      RETURN
CCC_  & DUBrgD ## quantity registration (auto)
      entry DUBrgD (iErr, qTgt, uDef)
      iErr = 0
      call DUCrgD
     $    (iErr, qTgt, uDef,
     $     KU,   SU,   AU,   ipP,  ipC, ipL)
      return
CCC_  & DUBrgP ## quantity registration (with power)
      entry DUBrgP (iErr, qTgt, uBas, P)
      iErr = 0
      call DUCrgP
     $    (iErr, qTgt, uBas, P,
     $     KU,   SU,   AU,   ipP,  ipC, ipL)
      return
CCC_  & DUBrgC ## conversion registration
      entry DUBrgC (iErr, idXo, qTgt, qSrc)
      idXo = 0
      call DUCrgC
     $    (iErr, idXo, qTgt, qSrc,
     $     KU,   SU,   AU,   ipP,  ipC, ipL)
      return
CCC_  & DUBcvS ## conversion single
      entry DUBcvS (VS, idXi)
      call DUCcvS
     $    (VS,
     $     idXi,  KU,   SU,   ipL)
      return
CCC_  & DUBcvA ## conversion array
      entry DUBcvA (VA, N, idXi)
      call DUCcvA
     $    (VA,    N,
     $     idXi,  KU,   SU,   ipL)
      return
CCC_  & DUBchk ## diagnose
      entry DUBchk (iErr, qTgt, qRef)
      iErr = 0
      call DUCchk
     $    (iErr, qTgt, qRef,
     $     KU,   SU,   AU,   ipL)
      return
CCC_  - end DUBmng
      END
CCC_* Core
CCC_ + DUCdfs ## default initialization of system
      subroutine DUCdfs
     O    (iErr,
     M     KU,   SU,   AU,
     I     KSW,  ipL)
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
      _INTENT(IN,   integer)   KSW
      _INTENT(IN,   integer)   ipL
      _REALSTD qpi
      integer LevI
c
      iErr = 0
      LevI = 0
c$$$#define _ERRCHK_ iErr.ge.0 /* to allow pending */
#define _ERRCHK_ iErr.eq.0
CCC_  - SI base units and quantities
      if (KSW.ge.LevI) then
         if (_ERRCHK_) call UXSdco(iErr, '1', 1.d0, KU,SU,AU)
         if (_ERRCHK_) call UXSdpc(iErr, 'm', 'LENGTH', KU,SU,AU)
         if (_ERRCHK_) call UXSdpc(iErr, 'kg', 'MASS', KU,SU,AU)
         if (_ERRCHK_) call UXSdpc(iErr, 's', 'TIME', KU,SU,AU)
         if (_ERRCHK_) call UXSdpc(iErr, 'K', 'TEMPERATURE', KU,SU,AU)
         if (_ERRCHK_) call UXSdpc(iErr, 'radian', 'ANGLE', KU,SU,AU)
         if (_ERRCHK_) call UXSdpc(iErr, 'mol', 'AMOUNT', KU,SU,AU)
      endif
      LevI = LevI + 1
CCC_  - some derived units
      if (KSW.ge.LevI) then
         if (_ERRCHK_) call UXSdal(iErr, 'N', 'kg m s^-2', KU,SU,AU)
         if (_ERRCHK_) call UXSdal(iErr, 'Pa', 'N m^-2', KU,SU,AU)
         if (_ERRCHK_) call UXSdal(iErr, 'J', 'N m', KU,SU,AU)
         if (_ERRCHK_) call UXSdal(iErr, 'W', 'J s^-1', KU,SU,AU)
c
         if (_ERRCHK_) call UXSdfi(iErr, 'min', 60,'s',  KU,SU,AU)
         if (_ERRCHK_) call UXSdfi(iErr, 'hr',  60,'min',KU,SU,AU)
         if (_ERRCHK_) call UXSdfi(iErr, 'day', 24,'hr', KU,SU,AU)
         if (_ERRCHK_)
     $        call UXSdfi(iErr, 'yr',  31556926,'s',  KU,SU,AU)
         if (_ERRCHK_) call UXSddi(iErr, 'mon', 12,'yr', KU,SU,AU)
         if (_ERRCHK_) call UXSdfi(iErr, 'yr#i',  360,'day', KU,SU,AU)
         if (_ERRCHK_) call UXSdfi(iErr, 'mon#i', 30,'day', KU,SU,AU)

         qpi = ATAN2 (1.d0, 1.d0)
         if (_ERRCHK_) call UXSdco(iErr, 'qpi', qpi, KU,SU,AU)
         if (_ERRCHK_) call UXSdfi(iErr, 'pi',  4, 'qpi',  KU,SU,AU)
         if (_ERRCHK_) call UXSdec(iErr, 'pi',  KU,SU,AU)
         if (_ERRCHK_)
     $        call UXSddi(iErr, 'degree', 45, 'qpi radian', KU,SU,AU)
c
         if (_ERRCHK_) call UXSdfi(iErr, '%', 100,'1', KU,SU,AU)
c        alias
         if (_ERRCHK_) call UXSdal(iErr, 'deg', 'degree',  KU,SU,AU)
         if (_ERRCHK_) call UXSdal(iErr, 'rad', 'radian',  KU,SU,AU)
      endif
      LevI = LevI + 1
CCC_  - prefixes and some prefix-ed units (standard)
      if (KSW.ge.LevI) then
         if (_ERRCHK_) call UXSpmi(iErr, 'M', +6,  KU,SU,AU)
         if (_ERRCHK_) call UXSpmi(iErr, 'k', +3,  KU,SU,AU)
         if (_ERRCHK_) call UXSpmi(iErr, 'h', +2,  KU,SU,AU)
         if (_ERRCHK_) call UXSpmi(iErr, 'c', -2,  KU,SU,AU)
         if (_ERRCHK_) call UXSpmi(iErr, 'm', -3,  KU,SU,AU)
         if (_ERRCHK_) call UXSpmi(iErr, 'u', -6,  KU,SU,AU)
c
         if (_ERRCHK_) call UXSdpu(iErr, 'k', 'm', KU,SU,AU)
         if (_ERRCHK_) call UXSdpu(iErr, 'c', 'm', KU,SU,AU)
         if (_ERRCHK_) call UXSdpu(iErr, 'm', 'm', KU,SU,AU)
         if (_ERRCHK_) call UXSdpu(iErr, 'u', 'm', KU,SU,AU)
c
         if (_ERRCHK_) call UXSdpu(iErr, 'k', 'g', KU,SU,AU)
         if (_ERRCHK_) call UXSdpu(iErr, 'm', 'g', KU,SU,AU)
c
         if (_ERRCHK_) call UXSdpu(iErr, 'k', 'Pa', KU,SU,AU)
         if (_ERRCHK_) call UXSdpu(iErr, 'h', 'Pa', KU,SU,AU)
c
         if (_ERRCHK_) call UXSdpu(iErr, 'k', 'yr', KU,SU,AU)
         if (_ERRCHK_) call UXSdpu(iErr, 'M', 'yr', KU,SU,AU)
         if (_ERRCHK_) call UXSdpu(iErr, 'k', 'yr#i', KU,SU,AU)
         if (_ERRCHK_) call UXSdpu(iErr, 'M', 'yr#i', KU,SU,AU)
      endif
      LevI = LevI + 1
CCC_  - prefixes and some prefix-ed units (more)
      if (KSW.ge.LevI) then
         if (_ERRCHK_) call UXSpmi(iErr, 'Y', +24, KU,SU,AU)
         if (_ERRCHK_) call UXSpmi(iErr, 'Z', +21, KU,SU,AU)
         if (_ERRCHK_) call UXSpmi(iErr, 'E', +18, KU,SU,AU)
         if (_ERRCHK_) call UXSpmi(iErr, 'P', +15, KU,SU,AU)
         if (_ERRCHK_) call UXSpmi(iErr, 'T', +12, KU,SU,AU)
         if (_ERRCHK_) call UXSpmi(iErr, 'G', +9,  KU,SU,AU)
         if (_ERRCHK_) call UXSpmi(iErr, 'da',+1,  KU,SU,AU)
         if (_ERRCHK_) call UXSpmi(iErr, 'd', -1,  KU,SU,AU)
         if (_ERRCHK_) call UXSpmi(iErr, 'n', -9,  KU,SU,AU)
         if (_ERRCHK_) call UXSpmi(iErr, 'p', -12, KU,SU,AU)
         if (_ERRCHK_) call UXSpmi(iErr, 'f', -15, KU,SU,AU)
         if (_ERRCHK_) call UXSpmi(iErr, 'a', -18, KU,SU,AU)
         if (_ERRCHK_) call UXSpmi(iErr, 'z', -21, KU,SU,AU)
         if (_ERRCHK_) call UXSpmi(iErr, 'y', -24, KU,SU,AU)
      endif
      LevI = LevI + 1
CCC_  - Some (named) compound quantities
      if (KSW.ge.LevI) then
         if (_ERRCHK_)
     $        call UXSdal(iErr, 'AREA', 'LENGTH^2', KU,SU,AU)
         if (_ERRCHK_)
     $        call UXSdal(iErr, 'VOLUME', 'LENGTH^3',  KU,SU,AU)
         if (_ERRCHK_)
     $        call UXSdal
     $            (iErr, 'FORCE', 'MASS LENGTH TIME^-2', KU,SU,AU)
         if (_ERRCHK_)
     $        call UXSdal
     $            (iErr, 'DENSITY', 'MASS VOLUME^-1', KU,SU,AU)
         if (_ERRCHK_)
     $        call UXSdal
     $            (iErr, 'STRESS', 'FORCE AREA^-1', KU,SU,AU)
         if (_ERRCHK_)
     $        call UXSdal
     $            (iErr, 'ENERGY', 'FORCE LENGTH', KU,SU,AU)
         if (_ERRCHK_)
     $        call UXSdal
     $            (iErr, 'POWER', 'ENERGY TIME^-1', KU,SU,AU)
         if (_ERRCHK_)
     $        call UXSdal
     $            (iErr, 'VELOCITY', 'LENGTH TIME^-1', KU,SU,AU)
         if (_ERRCHK_)
     $        call UXSdal
     $            (iErr, 'STRAIN.RATE', 'VELOCITY LENGTH^-1', KU,SU,AU)
         if (_ERRCHK_)
     $        call UXSdal
     $            (iErr, 'ACCELERATION', 'VELOCITY TIME^-1',  KU,SU,AU)
         if (_ERRCHK_)
     $        call UXSdal
     $            (iErr, 'SP.HEAT.CAPACITY',
     $             'ENERGY MASS^-1 TEMPERATURE^-1',KU,SU,AU)
         if (_ERRCHK_)
     $        call UXSdal
     $            (iErr, 'THERMAL.CONDUCTIVITY',
     $             'POWER LENGTH^-1 TEMPERATURE^-1',KU,SU,AU)
      endif
      call UXSchk(iErr, KU, SU, AU)
      if (_ERRCHK_) iErr = 0
      call DATrcU (ipL, iErr, 'R', 'DUCdfs')
#undef _ERRCHK_
      RETURN
      END
CCC_ + DUCrgD ## register and configuration
      subroutine DUCrgD
     O    (iErr,
     I     qTgt, uDef,
     M     KU,   SU,   AU,
     i     ipP,  ipC,  ipL)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   character) qTgt*(*), uDef*(*)
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
      _INTENT(IN,   integer)   ipP, ipC, ipL
      integer jDstt, jCstt
      character uRtu*(OPT_UNIT_LEN)
      _REALSTD FDM(UXC_MAX)
      character CR*(16)
CCC_  - Body
      iErr = 0
      CR = ' '
      uRtu = uDef
      call DUCcfg
     O    (iErr,
     M     uRtu, FDM,
     I     qTgt, CR, ipP, ipC, ipL)
 102  format('INCONSISTENT UNITS: ', A, ' = ', A, ' // ', A)
      if (uRtu.ne.'auto') then
         if (iErr.eq.0) then
            call DUCrgL(iErr, qTgt, uRtu, KU, SU, AU, ipL)
            iErr = MIN(0, iErr)
         endif
         if (iErr.eq.0) then
            call DUCrgL(iErr, qTgt, uDef, KU, SU, AU, ipL)
            iErr = MIN(0, iErr)
            if (iErr.ne.0) then
               call UXSqxr (jDstt, jCstt, uRtu, uDef, KU,SU,AU)
               iErr = jDStt
               if (iErr.ne.0) then
                  if (COND_N(ipL)) then
                     write(ipL, 102)
     $                    _TRIM(qTGT), _TRIM(uRtu), _TRIM(uDef)
                  else if (COND_S(ipL)) then
                     write(*,   102)
     $                    _TRIM(qTGT), _TRIM(uRtu), _TRIM(uDef)
                  endif
               endif
            endif
         endif
      endif
      call DATrcU (ipL, iErr, qTgt, 'DUCRGD')
      RETURN
      END
CCC_ + DUCrgL ## register (and log if pending)
      subroutine DUCrgL
     O    (iErr,
     I     qTgt, uDef,
     M     KU,   SU,   AU,
     i     ipL)
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   character) qTgt*(*), uDef*(*)
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
      _INTENT(IN,   integer)   ipL
CCC_  - Body
      iErr = 0
 101  format('PENDING TERMS: ', A, ' = ', A, 1x, I3)
      call UXSdal (iErr, qTgt, uDef, KU,SU,AU)
      if (iErr.gt.0) then
         if (COND_N(ipL)) then
            write(ipL, 101) _TRIM(qTgt), _TRIM(uDef), iErr
         else if (COND_S(ipL)) then
            write(*,   101) _TRIM(qTgt), _TRIM(uDef), iErr
         endif
      endif
c     return iErr as number of unknowns (uxsdal)
      RETURN
      END
CCC_ & DUCcfg  ## Development/Units run-time configuration
      subroutine DUCcfg
     O    (iErr,
     M     uUsr,
     O     FDM,
     I     qTgt, CR, ipP, ipC, ipL)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,character) uUsr*(*)
      _INTENT(OUT,  _REALSTD)  FDM(*)
      _INTENT(IN,   character) qTgt*(*)
      _INTENT(IN,   character) CR*(*)
      _INTENT(IN,   integer)   ipP, ipC, ipL
c
      integer    LVEML
      parameter (LVEML=OPT_NAMELIST_OUTPUT_EMULATION)
      character C*(64)
      character Q*(OPT_UNIT_LEN)
      character U*(OPT_UNIT_LEN)
      _REALSTD  F, D, E
      namelist /NIUNIT/
     $     C, Q, F, D, E, U
C     C=' ',
C     Q='NAME', F=FACTOR, D=DENOMINATOR, E=MAGNITUDE, U='UNIT',
      integer jedmy
CCC_  - Body
      iErr = 0
      call UUrwnd(iErr, ipP)
      DO
         C = ' '
         Q = ' '
         U = ' '
         F = 1.0d0
         D = 1.0d0
         E = 0.0d0
         if (ipP.ge.0) then
            read(ipP, NIUNIT, IOSTAT=iErr)
         else if (ipP.eq.-1) then
            read(*,   NIUNIT, IOSTAT=iErr)
         else
            goto 100
         endif
         if (iErr.ne.0) goto 100
         if (C.eq.CR.and.Q.eq.qTgt) then
            goto 100
         endif
      ENDDO
 100  continue
      if (C.eq.' ') C = CR
      if (U.eq. _UNIT_DEF .or.U.eq.'def') then
         U = uUsr
      else if (U.eq. _UNIT_AUTO .or.U.eq.'auto') then
         U = 'auto'
      endif
      if (Q.eq.' ') Q = qTgt
      if (LVEML.gt.0) then
         call UNBbgn (jedmy, 'NIUNIT', ipC,   LVEML)
         call UNBstr (jedmy, 'C',      C,     ipC, LVEML)
         call UNBstr (jedmy, 'Q',      Q,     ipC, LVEML)
         call UNBrst (jedmy, 'F',      F,     ipC, LVEML)
         call UNBrst (jedmy, 'D',      D,     ipC, LVEML)
         call UNBrst (jedmy, 'E',      E,     ipC, LVEML)
         call UNBstr (jedmy, 'U',      U,     ipC, LVEML)
         call UNBend (jedmy, 'NIUNIT', ipC,   LVEML)
      else
         if (COND_N(ipC)) then
            write (ipC, NIUNIT)
         else if (COND_S(ipC)) then
            write (*,   NIUNIT)
         endif
      endif
      FDM(UXC_F) = F
      FDM(UXC_D) = D
      FDM(UXC_M) = E
      uUsr = U
c$$$      call DATrcU (ipL, iErr, qTgt, 'DUCCFG')
      iErr = 0
      RETURN
      END
CCC_ + DUCrgP ## register derived quantity with power
      subroutine DUCrgP
     O    (iErr,
     I     qTgt, uBas, P,
     M     KU,   SU,   AU,
     i     ipP,  ipC,  ipL)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   character) qTgt*(*), uBas*(*)
      _INTENT(IN,   _REALSTD)  P
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
      _INTENT(IN,   integer)   ipP, ipC, ipL
      integer jDstt, jCstt
CCC_  - Body
      iErr = 0
      if (iErr.eq.0) call UXSqrg(iErr, qTgt, KU, AU)
CCC_   . check dimension if registered
      if (iErr.eq.0) then
         call UXSqxr(jDstt, jCstt, qTgt, uBas, KU, SU, AU)
         iErr = jDstt
 102     format('DUCRGD: INCONSISTENT UNITS: ', A, ' // ', A)
         if (iErr.ne.0) then
            if (COND_N(ipL)) then
               write(ipL, 102) _TRIM(qTgt), _TRIM(uBas)
            else if (COND_S(ipL)) then
               write(*,   102) _TRIM(qTgt), _TRIM(uBas)
            endif
         endif
CCC_   . if new quantity
      else
         iErr = 0
         if (iErr.eq.0) then
            call UXSdpw(iErr, qTgt, P, uBas, KU, SU,  AU)
         endif
      endif
      call DATrcU (ipL, iErr, qTgt, 'DUCRGP')
      RETURN
      END
CCC_ + DUCrgC ## register conversion
      subroutine DUCrgC
     O    (iErr, idX,
     I     qTgt, qSrc,
     M     KU,   SU,   AU,
     i     ipP,  ipC,  ipL)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(OUT,  integer)   idX
      _INTENT(IN,   character) qTgt*(*), qSrc*(*)
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
      _INTENT(IN,   integer)   ipP, ipC, ipL
CCC_  - Body
      iErr = 0
      if (iErr.eq.0) call UXSxps(iErr, idX, qTgt, qSrc, KU, SU, AU)
      call DATrcU (ipL, iErr, qTgt, 'DUCRGC')
      RETURN
      END
CCC_ + DUCcvS ## conversion single
      subroutine DUCcvS
     M    (VS,
     I     idX,
     I     KU,  SU, ipL)
CCC_  - Declaration
      implicit none
      _INTENT(INOUT,_REALSTD)  VS
      _INTENT(IN,   integer)   idX
      _INTENT(IN,   integer)   KU(*)
      _INTENT(IN,   _REALSTD)  SU(*)
      _INTENT(IN,   integer)   ipL
      integer jerr
CCC_  - Body
      call UXSixs (jErr, VS, idX, -1, KU,SU)
      RETURN
      END
CCC_ + DUCcvA ## conversion array
      subroutine DUCcvA
     M    (VA,
     I     N,    idX,
     I     KU,   SU,   ipL)
CCC_  - Declaration
      implicit none
      _INTENT(INOUT,_REALSTD)  VA(*)
      _INTENT(IN,   integer)   N
      _INTENT(IN,   integer)   idX
      _INTENT(IN,   integer)   KU(*)
      _INTENT(IN,   _REALSTD)  SU(*)
      _INTENT(IN,   integer)   ipL
      integer jErr
CCC_  - Body
      call UXSixa (jErr, VA, N, idX, -1, KU,SU)
      RETURN
      END
CCC_ + DUCchk ## check properties
      subroutine DUCchk
     O    (iErr,
     I     qTgt, qRef,
     M     KU,   SU,   AU,
     i     ipL)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   character) qTgt*(*), qRef*(*)
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
      _INTENT(IN,   integer)   ipL
      _REALSTD FDM(UXC_MAX)
      character CF*(128)
      character Udec*(OPT_UNIT_LEN)
CCC_  - Body
      iErr = 0
 101  format('CHECK: ', A, ' == ', A, 1x, A)
 102  format('CHECK: ', A, ' >> ', A, ' == ', A)
      call UXSdtu (iErr, FDM, Udec, qTgt, UXLEV_FDM, KU,SU,AU)
      if (iErr.eq.0) then
         call UXMcst(CF, FDM, +1)
         if (COND_N(ipL)) then
            write(ipL, 101) _TRIM(qTgt), _TRIM(CF), _TRIM(Udec)
         else if (COND_S(ipL)) then
            write(*,   101) _TRIM(qTgt), _TRIM(CF), _TRIM(Udec)
         endif
      endif
      if (iErr.eq.0) then
         if (qRef.ne.' ') then
            call UXSdct (iErr, FDM, qRef, UXLEV_FDM, KU,SU,AU)
            if (iErr.eq.0) then
               call UXMcst(CF, FDM, +1)
               if (COND_N(ipL)) then
                  write(ipL, 101) _TRIM(qRef), _TRIM(CF)
               else if (COND_S(ipL)) then
                  write(*,   101) _TRIM(qRef), _TRIM(CF)
               endif
            endif
            call UXSqfx
     O           (iErr, FDM, qTgt, qRef, UXLEV_FDM, KU,SU,AU)
            if (iErr.eq.0) then
               call UXMcst(CF, FDM, +1)
               if (COND_N(ipL)) then
                  write(ipL, 102) _TRIM(qTgt), _TRIM(qRef), _TRIM(CF)
               else if (COND_S(ipL)) then
                  write(*,   102) _TRIM(qTgt), _TRIM(qRef), _TRIM(CF)
               endif
            endif
         endif
      endif
      call DATrcU (ipL, iErr, qTgt, 'DUCCHK')
      RETURN
      END
CCC_& DUNTMS  ## Development/Unit announcement
      subroutine DUNTMS (STRA, STRB, IOP)
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
CCC_@ DUtest  ## DuntMs test
#ifdef TEST_DUNTMS
#include "odevel.h"
      program DUTEST
CCC_ + Test suites
CC::   SOURCES dbstrp.F danntr.F
CCC_ + Declaration
      implicit none
      integer   ipI, ipO, ipE
      integer   iErr
CCC_ + Body
      iErr = 0
      call DBIcpy
     O    (iErr, ipI,
     I     -1, ' ', .FALSE.)
c
      ipO = -1
      ipE = -1
      write (*, *) 'BOOTSTRAP', ipI, ipO, ipE
c
      call DUTEST_ini(iErr, ipI, ipO, ipE)
      call DUTEST_set(iErr, ipI, ipO, ipE)
      call DUTEST_fin(iErr, ipI, ipO, ipE)
c
      call DEBrep (ipO)
      call DBswpW (iErr, -1, -1)
c
      STOP
      END
CCC_ + subroutines
CCC_  - DUTEST_ini
      subroutine DUTEST_ini(iErr, ipI, ipO, ipE)
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   ipI, ipO, ipE
      integer NHUS, NHUD, NHUC
      iErr = 0
c$$$      NHUS = 1000
c$$$      NHUD = 1000
c$$$      NHUC = 1000
      NHUS = 0
      NHUD = 0
      NHUC = 0
      call DUinit(iErr, NHUS, NHUD, NHUC, ipI, ipO, ipE)
      return
      end
CCC_  - DUTEST_set
      subroutine DUTEST_set(iErr, ipI, ipO, ipE)
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   ipI, ipO, ipE
      integer  idX
      _REALSTD PF
      _REALSTD V

      iErr = 0
      PF = 3.0d0
c
      if (iErr.eq.0) call DUregD(iErr, 'length', 'LENGTH')
c
      if (iErr.eq.0) call DUregD(iErr, 'topo', 'length')
      if (iErr.eq.0) call DUregD(iErr, 'dx', 'length')
      if (iErr.eq.0) call DUregD(iErr, 'grav', 'ACCELERATION')
      if (iErr.eq.0) call DUregD(iErr, 'dens', 'DENSITY')
      if (iErr.eq.0) call DUregD(iErr, 'strain.rate', 'STRAIN.RATE')
      if (iErr.eq.0) call DUregD(iErr, '@stress', 'STRESS')
c     inconsistent
c$$$      if (iErr.eq.0) call DUregQ(iErr, 'topo', ' ', ' ')
c$$$      if (iErr.eq.0) call DUregQ(iErr, 'topo', '1', ' ')
c
      if (iErr.eq.0) call DUregD(iErr, 'dsdx', 'topo/dx')
      if (iErr.eq.0) call DUregD(iErr, 'drag', 'dens grav topo dsdx')
      if (iErr.eq.0) call DUregD(iErr, '%stress',   'drag/@stress')
      if (iErr.eq.0) call DUregP(iErr, '%stress#n', '%stress',    PF)
      if (iErr.eq.0) call DUregP(iErr, '%Pa#n', 'Pa/@stress', PF)
      if (iErr.eq.0) then
         call DUregD(iErr, 'rate.f', 'strain.rate %stress#n^-1')
      endif
c
      if (iErr.eq.0) call DUregD(iErr, 'rftest', 'yr^-1 %Pa#n^-1')
c$$$      if (iErr.eq.0) call DUregD(iErr, 'rftest', '%Pa#n^-1')
c
      if (iErr.eq.0) call DUTEST_conv(iErr, 'm', 'cm', ipE)
      if (iErr.eq.0)
     $     call DUTEST_conv(iErr, 'rate.f', 'yr^-1 %Pa#n^-1', ipE)
      if (iErr.eq.0) call DUTEST_conv(iErr, 'drag', 'Pa', ipE)
c
      if (iErr.eq.0) call DUchek(iErr, 'dsdx', ' ')
      if (iErr.eq.0) call DUchek(iErr, 'dx', ' ')
      if (iErr.eq.0) call DUchek(iErr, 'drag', ' ')
      if (iErr.eq.0) call DUchek(iErr, 'strain.rate', ' ')
      if (iErr.eq.0) call DUchek(iErr, 'rate.f', ' ')
      if (iErr.eq.0) call DUchek(iErr, 'rate.f', 'yr^-1 %Pa#n^-1')
c
      RETURN
      END
CCC_  - DUTEST_conv
      subroutine DUTEST_conv(iErr, qTgt, qSrc, ipE)
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   character) qTgt*(*), qSrc*(*)
      _INTENT(IN,   integer)   ipE
      integer  idX
      _REALSTD VD, VS
      iErr = 0
      if (iErr.eq.0) call DUregC(idX, qTgt, qSrc)
      VS = 1.0d0
      VD = VS
      if (iErr.eq.0) call DUcnvS(VD, idX)
 101  format('CONVERSION: ',
     $     E16.9, 1x, A, ' == ', E16.9, 1x, A)
      if (COND_N(ipE)) then
         write(ipE, 101) VS, trim(qSrc), VD, trim(qTgt)
      else if (COND_S(ipE)) then
         write(*,   101) VS, trim(qSrc), VD, trim(qTgt)
      endif
      RETURN
      END
CCC_  - DUTEST_fin
      subroutine DUTEST_fin(iErr, ipI, ipO, ipE)
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   ipI, ipO, ipE
      iErr = 0
      call DUfine(iErr)
      return
      end
#endif /* TEST_DUNTMS */
CCC_* Obsolete
#if 0 /* meta comment */
CCC_ + DUCrgQ ## register quantity (with user control)
      subroutine DUCrgQ
     O    (iErr,
     I     uNew, uPrm, uDef,
     M     KU,   SU,   AU,
     i     ipP,  ipC,  ipL)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   character) uNew*(*), uPrm*(*), uDef*(*)
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
      _INTENT(IN,   integer)   ipP, ipC, ipL
      integer jDstt, jCstt
      character uRtu*(OPT_UNIT_LEN)
      _REALSTD FDM(UXC_MAX)
CCC_  - Body
      iErr = 0
      if (iErr.eq.0) call UXSqrg(iErr, uNew, KU, AU)
CCC_   . check dimension if registered
      if (iErr.eq.0) then
         if (uPrm.ne.' ') then
            call UXSqxr(jDstt, jCstt, uNew, uPrm, KU, SU, AU)
            iErr = jDstt
         endif
 102     format('DUCRGQ: INCONSISTENT UNITS: ', A, ' // ', A)
         if (iErr.ne.0) then
            if (COND_N(ipL)) then
               write(ipL, 102) _TRIM(uNew), _TRIM(uPrm)
            else if (COND_S(ipL)) then
               write(*,   102) _TRIM(uNew), _TRIM(uPrm)
            endif
         endif
CCC_   . if new quantity
      else
         iErr = 0
         if (uPrm.eq.' ') then
            iErr = -1
         else
            uRtu = uDef
            if (uRtu.eq.' ') uRtu = uPrm
         endif
CCC_   . get run-time unit
         if (iErr.eq.0) then
            call DUCcfg(iErr, uRtu, FDM, uNew, ' ', ipP, ipC, ipL)
            iErr = 0
         endif
CCC_   . check dimension primitive vs user
         if (iErr.eq.0) then
            call UXSqxr(jDstt, jCstt, uPrm, uRtu, KU, SU, AU)
            iErr = jDstt
         endif
CCC_   . set quantity
         if (iErr.eq.0) then
            call UXSdft(iErr, uNew, FDM, uRtu, KU, SU,  AU)
         endif
      endif
      call DATrcU (ipL, iErr, uNew, 'DUCRGQ')
      RETURN
      END
#endif /* 0 meta comment */
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
