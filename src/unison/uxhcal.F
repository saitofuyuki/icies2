C unison/uxhcal.F --- IcIES/Unison/Calendar
C Maintainer:  SAITO Fuyuki
C Created: Oct  5 2010
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2020/09/15 11:46:13 fuyuki uxhcal.F>'
#define _FNAME 'unison/uxhcal.F'
#define _REV   'Snoopy0.9'
CCC_! MANIFESTO
C
C Copyright (C) 2010--2020
C           Japan Agency for Marine-Earth Science and Technology,
C
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
CCC_* Description
CCC_ + units
CC
CC     The time coordinate (sequential time) must be represented with linear units,
CC     e.g., /min/, /mon/, /yr/ and so on.  On the other hand, a time step can be
CC     represented with linear as well as non-linear units, e.g., /mon#g/ or /yr#g/.
CC     A time step with a non-linear unit is computed as a function of current
CC     time.
CC
CCC_ + symbol convention
CC
CC       t    sequential time (time coordinate)
CC       c    calendar date (e.g., Y,M,D,h,m,s, plus residual)
CC       d    day
CC       j    Julian day (plus residual)
CC       g    gregorian calendar date
CC
CC       residual times are in the same unit as the sequential time.
CC
CCC_ + Time stepping design
CC
CC     Time stepping method is controlled by the calendar/conversion index.
CC
CCC_  - (i) Calendar increment  (yr#c, mon#c) *irreversible*
CC
CC      1973/1/30 + 1 yr#c  == 1974/1/30
CC      1973/1/30 + 1 mon#c == 1973/2/30 == 1973/3/2
CC      1973/2/-1 + 1 mon#c == 1973/3/-1 == 1973/2/27 (not checked)
CC
CCC_  - (w) Stepwise forwarding (yr#g, mon#g) *reversible*
CC
CC      1973/1/30 + 3yr#g
CC         yr:197[345] == 365 day
CC         yr:1976     == 366 day
CC      i:    1973/1/30 == 1973/1/1 + 29/365 yr
CC      ii:   1973/1/30 to 1974/1/1               step (365-29)/365 yr:1973
CC      iii:  1974/1/1  to 1976/1/1               step            2 yr#c
CC      iv:   1976/1/1  to 1976/1/30 + residual   step       29/365 yr:1976
CC
CCC_* Common macros
#include "ofdlct.h" /* fortran dialect */
#include "ologfm.h" /* logging */
#include "ounits.h" /* units */
#include "ouhcal.h" /* calendar */
CCC_ + Modified Julian day (type [PJ]GREGO)
#ifndef   OPT_JULIAN_OFFSET
#  define OPT_JULIAN_OFFSET 2400000
#endif
#ifndef   OPT_JULIAN_DAY_OFFSET
#  define OPT_JULIAN_DAY_OFFSET 0.5d0
#endif
CCC_ + Ideal calendar (type IDEAL)
#ifndef   OPT_IDEAL_EPOCH_SEC
#  define OPT_IDEAL_EPOCH_SEC 0.0d0
#endif
CCC_ + Unit
#ifndef    OPT_UNIT_LEN   /* length of unit atom */
#  define  OPT_UNIT_LEN   32
#endif
CCC_ + Calendar parts
#define _DATE_YR  1
#define _DATE_MON 2
#define _DATE_DAY 3
#define _DATE_HR  4
#define _DATE_MIN 5
#define _DATE_SEC 6
#define _DATE_MAX 6
CCC_ + Attributes
#define _CATTR_TYPE 1  /* calendar type */
#define _CATTR_USEQ 2  /* time sequence unit id */
#define _CATTR_IOFF 3  /* offset for date index */

#define _CATTR_UID  3  /* [4,9]   unit id offset */
#define _CATTR_XID  9  /* [10,15] conversion id (to useq) offset */
#define _CATTR_XNL  15 /* [16,21] non-linear flag */
#define _CATTR_DOFF 21 /* [22,27] start count */

#define _CATTR_MAX  27

#define _CATTR_UYR  (_CATTR_UID+ _DATE_YR)
#define _CATTR_UMON (_CATTR_UID+ _DATE_MON)
#define _CATTR_UDAY (_CATTR_UID+ _DATE_DAY)
#define _CATTR_UHR  (_CATTR_UID+ _DATE_HR)
#define _CATTR_UMIN (_CATTR_UID+ _DATE_MIN)
#define _CATTR_USEC (_CATTR_UID+ _DATE_SEC)

#define _CATTR_XYR  (_CATTR_XID+ _DATE_YR)
#define _CATTR_XMON (_CATTR_XID+ _DATE_MON)
#define _CATTR_XDAY (_CATTR_XID+ _DATE_DAY)
#define _CATTR_XHR  (_CATTR_XID+ _DATE_HR)
#define _CATTR_XMIN (_CATTR_XID+ _DATE_MIN)
#define _CATTR_XSEC (_CATTR_XID+ _DATE_SEC)

CCC_  - health check
#if CATTR_MAX < _CATTR_MAX
#  error "PANIC: WRONG CALENDAR ATTRIBUTE"
#endif
CCC_* [UHS] Calendar shell
CCC_ & UHSinw  ## initialization wrapper
      subroutine UHSinw
     O    (iErr,   KAC,
     I     kType,  uSeq,
     M     KU,     SU,   AU)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(OUT,  integer)   KAC(*)
      _INTENT(IN,   integer)   kType
      _INTENT(IN,   character) uSeq*(*)
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
      integer iuSeq
CCC_  - Body
      iErr = 0
      if (iErr.eq.0) call UXCinq (iErr, iuSeq, uSeq, KU,AU)
      if (iErr.eq.0) then
         call UHSini (iErr, KAC, kTYPE, iuSeq, KU,SU,AU)
      endif
      RETURN
      END
CCC_ & UHSini  ## initialization
      subroutine UHSini
     O    (iErr,   KAC,
     I     kType,  iuSeq,
     M     KU,     SU,    AU)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(OUT,  integer)   KAC(*)
      _INTENT(IN,   integer)   kType
      _INTENT(IN,   integer)   iuSeq
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
CCC_  - Body
      iErr = 0
      if (kType.eq. CAL_JGREGO) then
         call UHSins
     O       (iErr,  KAC,
     I        kType, iuSeq,
     I        'yr#g', 'mon#g', 'day', 'hr', 'min', 's',
     I        'day',   KU,     SU,    AU)
      else if (kType.eq. CAL_PGREGO) then
         call UHSins
     O       (iErr,  KAC,
     I        kType, iuSeq,
     I        'yr#p', 'mon#p', 'day', 'hr', 'min', 's',
     I        'day',  KU,      SU,    AU)
      else if  (kType.eq. CAL_NORMAL) then
         call UHSins
     O       (iErr,  KAC,
     I        kType, iuSeq,
     I        'yr',  'mon',  'day', 'hr', 'min', 's',
     I        ' ',   KU,     SU,    AU)
      else if  (kType.eq. CAL_IDEAL) then
         call UHSins
     O       (iErr,  KAC,
     I        kType, iuSeq,
     I        'yr#i', 'mon#i', 'day', 'hr', 'min', 's',
     I        ' ',    KU,      SU,    AU)
      else
         iErr = -1
      endif
      RETURN
      END
CCC_ & UHSins  ## initialization sub
      subroutine UHSins
     O    (iErr,   KAC,
     I     kType,  iuSeq,
     I     uYR,    uMO,   uDY,  uHR,  uMI,  uSC,
     I     uMDL,   KU,    SU,   AU)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(OUT,  integer)   KAC(*)
      _INTENT(IN,   integer)   kType
      _INTENT(IN,   integer)   iuSeq
      _INTENT(IN,   character) uYR*(*), uMO*(*), uDY*(*)
      _INTENT(IN,   character) uHR*(*), uMI*(*), uSC*(*)
      _INTENT(IN,   character) uMDL*(*)
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
      integer iuYR, iuMO, iuDY
      integer iuHR, iuMI, iuSC
      integer iuMDL
      integer iDstt, iCstt
CCC_  - Body
      iErr = 0
CCC_   . modulo check
      if (iErr.eq.0.and.uMDL.ne.' ') then
         call UXCinq (iErr, iuMDL, uMDL, KU,AU)
         if (iErr.eq.0) then
            call UXCrch (iDstt, iCstt, iuSeq, iuMDL,  KU,SU,AU)
         endif
c        sign exhanging must fail
         if (iDstt.ne.0.or.iCstt.le.0) iErr = -1
      endif
CCC_   . calendar units
      if (iErr.eq.0) call UXCinq (iErr, iuYR, uYR, KU,AU)
      if (iErr.eq.0) call UXCinq (iErr, iuMO, uMO, KU,AU)
      if (iErr.eq.0) call UXCinq (iErr, iuDY, uDY, KU,AU)
      if (iErr.eq.0) call UXCinq (iErr, iuHR, uHR, KU,AU)
      if (iErr.eq.0) call UXCinq (iErr, iuMI, uMI, KU,AU)
      if (iErr.eq.0) call UXCinq (iErr, iuSC, uSC, KU,AU)
      if (iErr.eq.0) then
         call UHCcfg
     $       (iErr,  KAC,
     $        kType, iuSeq,
     $        iuYR,  iuMO, iuDY, iuHR, iuMI, iuSC, KU,SU,AU)
      endif
      RETURN
      END
CCC_ & UHSchk  ## check calendar properties
      subroutine UHSchk
     O    (iErr,
     I     KAC,  KU, AU, IFP)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   KAC(*)
      _INTENT(IN, integer)   IFP
      _INTENT(IN, integer)   KU(*)
      _INTENT(IN, character) AU(*)*(*)
      character USEQ*(128)
CCC_  - Body
      iErr = 0
      call UXMusq(USEQ, KAC(_CATTR_USEQ),  KU,AU)
 101  format ('CALENDAR PROPERTIES: ', I3, 1x, A)
 102  format ('CALENDAR PROPERTIES DONE')
      if       (COND_N(IFP)) then
         write (IFP, 101) KAC(_CATTR_TYPE), _TRIM(USEQ)
      else if  (COND_S(IFP)) then
         write (*,   101) KAC(_CATTR_TYPE), _TRIM(USEQ)
      endif
      if (iErr.eq.0)
     $     call UHSpch(iErr, CAL_DYR,  _DATE_YR,  KAC, KU,AU,IFP)
      if (iErr.eq.0)
     $     call UHSpch(iErr, CAL_DMON, _DATE_MON, KAC, KU,AU,IFP)
      if (iErr.eq.0)
     $     call UHSpch(iErr, CAL_DDAY, _DATE_DAY, KAC, KU,AU,IFP)
      if (iErr.eq.0)
     $     call UHSpch(iErr, CAL_DHR,  _DATE_HR,  KAC, KU,AU,IFP)
      if (iErr.eq.0)
     $     call UHSpch(iErr, CAL_DMIN, _DATE_MIN, KAC, KU,AU,IFP)
      if (iErr.eq.0)
     $     call UHSpch(iErr, CAL_DSEC, _DATE_SEC, KAC, KU,AU,IFP)
      if       (COND_N(IFP)) then
         write (IFP, 102)
      else if  (COND_S(IFP)) then
         write (*,   102)
      endif
      RETURN
      END
CCC_ & UHSpch  ## check calendar properties sub
      subroutine UHSpch
     O    (iErr,
     I     Tag,   KMEM, KAC, KU,AU, IFP)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, character) Tag*(*)
      _INTENT(IN, integer)   KAC(*)
      _INTENT(IN, integer)   kmem
      _INTENT(IN, integer)   IFP
      _INTENT(IN, integer)   KU(*)
      _INTENT(IN, character) AU(*)*(*)
      character UP*(128)
      integer   iuP, ixP, icP, jof
      iErr = 0
      iuP = KAC(_CATTR_UID+kmem)
      ixP = KAC(_CATTR_XID+kmem)
      icP = KAC(_CATTR_XNL+kmem)
      jof = KAC(_CATTR_DOFF+kmem)
      call UXMusq(UP, iuP,  KU,AU)
 101  format (A, T5, A, 1x, I4, 1x, I2, 1x, I2)
      if       (COND_N(IFP)) then
         write (IFP, 101) Tag, _TRIM(UP), ixP, icP, jof
      else if  (COND_S(IFP)) then
         write (*,   101) Tag, _TRIM(UP), ixP, icP, jof
      endif
      RETURN
      END
CCC_ & UHSt2a  ## time sequence to string
      subroutine UHSt2a
     O    (STR,
     I     T,   kFMT, icPosX,  KAC,  KU, SU, AU)
      implicit none
      _INTENT(OUT,character) STR*(*)
      _INTENT(IN, _REALSTD)  T
      _INTENT(IN, integer)   kFMT
      _INTENT(IN, integer)   icPosX
      _INTENT(IN, integer)   KAC(*)
      _INTENT(IN, integer)   KU(*)
      _INTENT(IN, _REALSTD)  SU(*)
      _INTENT(IN, character) AU(*)*(*)
      integer   KDT(_DATE_MAX)
      _REALSTD  ResC
      character USEQ*(128)
      integer   jerr
      _REALSTD  TX
      if      (kFMT.eq. CAL_FMT_SEQ) then
         TX = _XREALS(T)
         if (icPosX.eq.0) then
            call USGlfs(STR, _XREALS(TX), 'C')
            call UXAqun(jerr, USEQ, KAC(_CATTR_USEQ), ' ', KU,AU)
            call USJxra(STR, ' ', USEQ)
         else
            call UXCrvc(jerr, TX, icPosX, KU,SU)
            call USGlfs(STR, _XREALS(TX), 'C')
         endif
      else if (kFMT.eq. CAL_FMT_DATE) then
         call UHCt2c(KDT, ResC, T,    KAC, KU,SU)
         call UHCc2a(STR, KDT,  ResC, icPosX, KAC, KU,AU)
      else
         STR = ' '
      endif
      RETURN
      END
CCC_* [UHC] Calendar core
CCC_ & UHCcfg  ## attributes configuration
      subroutine UHCcfg
     O    (iErr,      KAC,
     I     kType,     iuSeq,
     I     iuY, iuMo, iuD,  iuH,  iuMi,  iuS,
     M     KU,  SU,   AU)
CCC_  - Description
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(OUT,  integer)   KAC(*)
      _INTENT(IN,   integer)   kType
      _INTENT(IN,   integer)   iuSeq
      _INTENT(IN,   integer)   iuY, iuMo, iuD
      _INTENT(IN,   integer)   iuH, iuMi, iuS
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
      integer LUX
CCC_  - Body
      iErr = 0
      KAC(_CATTR_TYPE) = kType
      KAC(_CATTR_USEQ) = iuSeq
      call UXClmx(LUX, 'L', KU)
      KAC(_CATTR_IOFF) = ((LUX + 1) / 1000 + 2) * 1000
      if (iErr.eq.0)
     $     call UHCpcf (iErr, KAC, _DATE_YR,  0,  iuY,  KU,SU,AU)
      if (iErr.eq.0)
     $     call UHCpcf (iErr, KAC, _DATE_MON, 1,  iuMo, KU,SU,AU)
      if (iErr.eq.0)
     $     call UHCpcf (iErr, KAC, _DATE_DAY, 1,  iuD,  KU,SU,AU)
      if (iErr.eq.0)
     $     call UHCpcf (iErr, KAC, _DATE_HR,  0,  iuH,  KU,SU,AU)
      if (iErr.eq.0)
     $     call UHCpcf (iErr, KAC, _DATE_MIN, 0,  iuMi, KU,SU,AU)
      if (iErr.eq.0)
     $     call UHCpcf (iErr, KAC, _DATE_SEC, 0,  iuS,  KU,SU,AU)
      RETURN
      END
CCC_ & UHCpcf  ## attributes configuration sub
      subroutine UHCpcf
     O    (iErr,
     M     KAC,
     I     kmem, Ioff, iuP,
     M     KU,   SU,   AU)
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,integer)   KAC(*)
      _INTENT(IN,   integer)   kmem
      _INTENT(IN,   integer)   Ioff
      _INTENT(IN,   integer)   iuP
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
      integer ixP
      integer iDstt, iCstt
c
      iErr = 0
c
      call UXCxrg (iErr, ixP, iuP, KAC(_CATTR_USEQ), KU,SU,AU)
      KAC(_CATTR_UID  + kmem) = iuP
      KAC(_CATTR_XID  + kmem) = ixP
      if (iErr.eq.0) then
         call UXCdch (iDstt, iCstt, ixP, KU,SU)
         if (iDstt.eq.0) then
            if (iCstt.ge.0) then
               KAC(_CATTR_XNL + kmem) = iCstt
            else
               KAC(_CATTR_XNL + kmem) = -9
            endif
         else
            KAC(_CATTR_XNL + kmem) = -99
         endif
      else
         KAC(_CATTR_XNL  + kmem) = -999
      endif
      KAC(_CATTR_DOFF + kmem) = Ioff
c
      if (KAC(_CATTR_XNL + kmem).lt.0) iErr = -1
      RETURN
      END
CCC_ & UHCqci  ## query calendar index
      subroutine UHCqci
     O    (idxC,
     I     CUnam, KAC)
      implicit none
      _INTENT(OUT,integer)   idxC
      _INTENT(IN, integer)   KAC(*)
      _INTENT(IN, character) CUnam*(*)
      if       (CUnam.eq. CAL_DYR)  then
         idxC = _DATE_YR
      else if  (CUnam.eq. CAL_DMON) then
         idxC = _DATE_MON
      else if  (CUnam.eq. CAL_DDAY) then
         idxC = _DATE_DAY
      else if  (CUnam.eq. CAL_DHR)  then
         idxC = _DATE_HR
      else if  (CUnam.eq. CAL_DMIN) then
         idxC = _DATE_MIN
      else if  (CUnam.eq. CAL_DSEC) then
         idxC = _DATE_SEC
      else if (CUnam.eq.' ') then
         if (KAC(_CATTR_TYPE).eq. CAL_NORMAL) then
            idxC = -1
         else
            idxC = 0
         endif
      else
         idxC = -1
      endif
      RETURN
      END
CCC_ & UHCqxu  ## query conversion id
      subroutine UHCqxu
     O    (iErr, ixP,
     I     unm,  KAC,  KU, SU, AU)
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(OUT,  integer)   ixP
      _INTENT(IN,   integer)   KAC(*)
      _INTENT(IN,   character) unm*(*)
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
      integer iuP
      iErr = 0
      if (iErr.eq.0) call UXCinq (iErr, iuP, unm, KU,AU)
      if (iErr.eq.0) then
         call UXCxrg (iErr, ixP, iuP, KAC(_CATTR_USEQ), KU,SU,AU)
      else
         ixP = -1
      endif
      RETURN
      END
CCC_ & UHCstw  ## compute Tref plus Tint (stepwise forwarding)
      subroutine UHCstw
     O    (iErr,  Tnxt,
     I     Tref,  Tstp,  icPos, KAC,  KU, SU)
CCC_  - Description
CC      Negative unit conversion should fail.
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,_REALSTD)  Tnxt
      _INTENT(IN, _REALSTD)  Tstp,   Tref
      _INTENT(IN, integer)   icPos
      _INTENT(IN, integer)   KAC (*)
      _INTENT(IN, integer)   KU(*)
      _INTENT(IN, _REALSTD)  SU(*)
      integer  KDT(_DATE_MAX)
      _REALSTD ResC, DTR, TL, TU
      _REALSTD C0, SDir
      integer  jdir
CCC_  - Body
      if (icPos.lt.1 .or. icPos.gt. _DATE_MAX) then
         iErr = -1
         RETURN
      endif
      iErr = 0
CCC_   . case non-linear
      if (KAC(_CATTR_XNL+icPos).eq.0) then
         C0 = _XREALS(0.0d0)
         call UHCt2c (KDT, ResC,  Tref, KAC, KU,SU)
         call UHPcrs (KDT, icPos, KAC)
CCC_    * forward
         if (Tstp.ge.0.0d0) then
            call UHCcdt (TL, KDT, C0, 0, icPos, KAC, KU,SU)
            jdir = +1
         else
            call UHCcdt (TL, KDT, C0, 1, icPos, KAC, KU,SU)
            jdir = -1
         endif
         Sdir = _XREALS(jdir)
         call UHCcdt (TU, KDT, C0, jdir, icPos, KAC, KU,SU)
         DTR = (TU - Tref)/(TU - TL)
         if (DTR .ge. Tstp * Sdir) then
            Tnxt = Tref + (TU - TL) * Tstp * Sdir
         else
            DTR = Tstp - DTR * Sdir
            call UHCcdt (TL, KDT, C0, INT(DTR), icPos, KAC, KU,SU)
            call UHCcdt (TU, KDT, C0, jdir,     icPos, KAC, KU,SU)
            DTR = DTR - AINT(DTR)
            Tnxt = TL + (TU - TL) * DTR * Sdir
         endif
CCC_   . case linear
      else
         call UHCstl
     O       (iErr,  Tnxt,
     I        Tref,  Tstp,  icPos, KAC, KU,SU)
      endif
      RETURN
      END
CCC_ & UHCsti  ## compute Tref plus Tint (calendar increment method)
      subroutine UHCsti
     O    (iErr,  Tnxt,
     I     Tref,  Tstp,  icPos, KAC,  KU, SU)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,_REALSTD)  Tnxt
      _INTENT(IN, _REALSTD)  Tstp,   Tref
      _INTENT(IN, integer)   icPos
      _INTENT(IN, integer)   KAC (*)
      _INTENT(IN, integer)   KU(*)
      _INTENT(IN, _REALSTD)  SU(*)
      integer  KDT(_DATE_MAX)
      integer  jdir
      _REALSTD ResC
      _REALSTD TL, TU, DTR
CCC_  - Body
      if (icPos.lt.1 .or. icPos.gt. _DATE_MAX) then
         iErr = -1
         RETURN
      endif
      iErr = 0
CCC_   . case non-linear
      if (KAC(_CATTR_XNL+icPos).eq.0) then
         call UHCt2c (KDT, ResC, Tref, KAC,  KU,SU)
         call UHCcdt (TL, KDT, ResC, INT(Tstp), icPos, KAC, KU,SU)
         DTR = Tstp - AINT(Tstp)
         if (DTR.eq. _XREALS(0.0d0)) then
            Tnxt = TL
         else
            jdir = INT(SIGN(_XREALS(1.0d0), DTR))
            call UHCcdt (TU, KDT, ResC, jdir, icPos, KAC, KU,SU)
            Tnxt = TL + (TU - TL) * DTR * _XREALS(jdir)
         endif
CCC_   . case linear
      else
         call UHCstl
     O       (iErr,  Tnxt,
     I        Tref,  Tstp,  icPos, KAC, KU,SU)
      endif
c
      RETURN
      END
CCC_ & UHCstl  ## compute Tref plus Tint (calendar sub when linear)
      subroutine UHCstl
     O    (iErr,  Tnxt,
     I     Tref,  Tstp,  icPos, KAC,  KU, SU)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,_REALSTD)  Tnxt
      _INTENT(IN, _REALSTD)  Tstp,   Tref
      _INTENT(IN, integer)   icPos
      _INTENT(IN, integer)   KAC (*)
      _INTENT(IN, integer)   KU(*)
      _INTENT(IN, _REALSTD)  SU(*)
      integer  KDT(_DATE_MAX)
      _REALSTD ResC, DTR
CCC_  - Body
      iErr = 0
      call UHCt2c (KDT, ResC, Tref, KAC, KU,SU)
      KDT(icPos) = KDT(icPos) + INT(Tstp)
      call UHCc2t (Tnxt, KDT, ResC, KAC, KU,SU)
      DTR = Tstp - AINT(Tstp)
      call UXCcnv(iErr, DTR, KAC(_CATTR_XID+icPos),  KU,SU)
      Tnxt = Tnxt + DTR
      RETURN
      END
CCC_ & UHCstu  ## compute Tref plus Tint (intrinsic unit conversion)
      subroutine UHCstu
     O    (iErr,  Tnxt,
     I     Tref,  Tstp,  icPos, KAC, KU, SU)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,_REALSTD)  Tnxt
      _INTENT(IN, _REALSTD)  Tstp,   Tref
      _INTENT(IN, integer)   icPos
      _INTENT(IN, integer)   KAC (*)
      _INTENT(IN, integer)   KU(*)
      _INTENT(IN, _REALSTD)  SU(*)
      integer jx
CCC_  - Body
      iErr = 0
      if      (icPos.eq.0) then
         Tnxt = Tref + Tstp
      else if (icPos.ge.1.and.icPos.le. _DATE_MAX) then
         jx = KAC(_CATTR_XID+icPos)
         call UHCstx (iErr, Tnxt, Tref, Tstp, jx, KAC, KU,SU)
      else
         iErr = -1
      endif
      RETURN
      END
CCC_ & UHCstx  ## compute Tref plus Tint (external unit conversion)
      subroutine UHCstx
     O    (iErr,  Tnxt,
     I     Tref,  Tstp,  ixTstp, KAC,  KU, SU)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,_REALSTD)  Tnxt
      _INTENT(IN, _REALSTD)  Tstp,   Tref
      _INTENT(IN, integer)   ixTstp
      _INTENT(IN, integer)   KAC (*)
      _INTENT(IN, integer)   KU(*)
      _INTENT(IN, _REALSTD)  SU(*)
      _REALSTD DT
CCC_  - Body
      iErr = 0
      DT   = Tstp
      call UXCcnv (iErr, DT, ixTstp,  KU,SU)
      Tnxt = Tref + DT
      RETURN
      END
CCC_ & UHCcdt  ## compute time step in calendar
      subroutine UHCcdt
     O    (TN,
     M     KDT, ResC, iTstp, icPos, KAC,  KU, SU)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  _REALSTD)  TN
      _INTENT(INOUT,integer)   KDT(*)
      _INTENT(INOUT,_REALSTD)  ResC
      _INTENT(IN,   integer)   iTstp
      _INTENT(IN,   integer)   icPos
      _INTENT(IN,   integer)   KAC (*)
      _INTENT(IN,   integer)   KU(*)
      _INTENT(IN,   _REALSTD)  SU(*)
CCC_  - Body
      KDT(icPos) = KDT(icPos) + iTstp
      call UHCc2t (TN, KDT, ResC, KAC, KU,SU)
      RETURN
      END
CCC_ & UHCfww  ## time forwarding (stepwise forwarding)
      subroutine UHCfww
     O    (iErr,
     M     T,
     I     Tref, Tstp, icPos, KAC, KU, SU)
CCC_  - Description
CC      Negative unit conversion should fail.
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,_REALSTD)  T
      _INTENT(IN, _REALSTD)  Tref, Tstp
      _INTENT(IN, integer)   icPos
      _INTENT(IN, integer)   KAC (*)
      _INTENT(IN, integer)   KU(*)
      _INTENT(IN, _REALSTD)  SU(*)
      _REALSTD Torg, DT
      _REALSTD TU,   TL
      _REALSTD DTU,  DTL, DTC
      _REALSTD FTU,  FTL, FTC
      _REALSTD C0,   C1,  C2
      integer    nco
      integer    mco
      parameter (mco = 32)
CCC_  - Body
      if (icPos.lt.1 .or. icPos.gt. _DATE_MAX) then
         iErr = -1
         RETURN
      endif
      iErr = 0
      C2 = _XREALS(2.0d0)
      C1 = _XREALS(1.0d0)
      C0 = _XREALS(0.0d0)
      Torg = T
      if (Tref.le.T) then
         FTL = C0
         FTU = +C1
         nco = 0
         DO
            DTU = FTU * Tstp
            call UHCstw(iErr, TU, Torg, DTU, icPos, KAC, KU,SU)
            if (TU.gt.Tref) goto 200
            FTL = FTU
            FTU = FTU * C2
            if (nco.gt.mco) then
               iErr = -1
               goto 200
            endif
            nco = nco + 1
         ENDDO
 200     continue
      else
         FTU = C0
         FTL = -C1
         nco = 0
         DO
            DTL = FTL * Tstp
            call UHCstw(iErr, TL, Torg, DTL, icPos, KAC, KU,SU)
            if (TL.lt.Tref) goto 210
            FTU = FTL
            FTL = FTL * C2
            if (nco.gt.mco) then
               iErr = -1
               goto 300
            endif
            nco = nco + 1
         ENDDO
 210     continue
      endif
      DO
         if ((FTL + C1).ge.FTU) goto 300
         FTC = AINT((FTU - FTL) / C2) + FTL
         DTC = FTC * Tstp
         call UHCstw(iErr, TL, Torg, DTC, icPos, KAC, KU,SU)
         if (TL.le.Tref) then
            FTL = FTC
         else
            FTU = FTC
         endif
      ENDDO
 300  continue
      DTU = FTU * Tstp
      call UHCstw(iErr, T, Torg, DTU, icPos, KAC, KU,SU)
      RETURN
      END
CCC_ & UHCfwi  ## time forwarding (calendar increment method)
      subroutine UHCfwi
     O    (iErr,
     M     T,
     I     Tref, Tstp, icPos, KAC, KU,SU)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,_REALSTD)  T
      _INTENT(IN, _REALSTD)  Tref, Tstp
      _INTENT(IN, integer)   icPos
      _INTENT(IN, integer)   KAC (*)
      _INTENT(IN, integer)   KU(*)
      _INTENT(IN, _REALSTD)  SU(*)
      _REALSTD Torg, DT
      _REALSTD TU,   TL
      _REALSTD DTU,  DTL, DTC
      _REALSTD FTU,  FTL, FTC
      _REALSTD C0,   C1,  C2
      integer    nco
      integer    mco
      parameter (mco = 32)
CCC_  - Body
      if (icPos.lt.1 .or. icPos.gt. _DATE_MAX) then
         iErr = -1
         RETURN
      endif
      iErr = 0
      C2 = _XREALS(2.0d0)
      C1 = _XREALS(1.0d0)
      C0 = _XREALS(0.0d0)
      Torg = T
      if (Tref.le.T) then
         FTL = C0
         FTU = +C1
         nco = 0
         DO
            DTU = FTU * Tstp
            call UHCsti(iErr, TU, Torg, DTU, icPos, KAC, KU,SU)
            if (TU.gt.Tref) goto 200
            FTL = FTU
            FTU = FTU * C2
            if (nco.gt.mco) then
               iErr = -1
               goto 200
            endif
            nco = nco + 1
         ENDDO
 200     continue
      else
         FTU = C0
         FTL = -C1
         nco = 0
         DO
            DTL = FTL * Tstp
            call UHCsti(iErr, TL, Torg, DTL, icPos, KAC, KU,SU)
            if (TL.lt.Tref) goto 210
            FTU = FTL
            FTL = FTL * C2
            if (nco.gt.mco) then
               iErr = -1
               goto 210
            endif
            nco = nco + 1
         ENDDO
 210     continue
      endif
      if (iErr.eq.0) then
         DO
            if ((FTL + C1).ge.FTU) goto 300
            FTC = AINT((FTU - FTL) / C2) + FTL
            DTC = FTC * Tstp
            call UHCsti(iErr, TL, Torg, DTC, icPos, KAC, KU,SU)
            if (TL.le.Tref) then
               FTL = FTC
            else
               FTU = FTC
            endif
         ENDDO
 300     continue
         DTU = FTU * Tstp
         call UHCsti(iErr, T, Torg, DTU, icPos, KAC, KU,SU)
      endif
      RETURN
      END
CCC_ & UHCfwu  ## time forwarding (intrinsic unit conversion)
      subroutine UHCfwu
     O    (iErr,
     M     T,
     I     Tref, Tstp, icPos, KAC,  KU, SU)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,_REALSTD)  T
      _INTENT(IN, _REALSTD)  Tref, Tstp
      _INTENT(IN, integer)   icPos
      _INTENT(IN, integer)   KAC (*)
      _INTENT(IN, integer)   KU(*)
      _INTENT(IN, _REALSTD)  SU(*)
      integer jx
      _REALSTD UHPflr
      _REALSTD A
CCC_  - Body
      iErr = 0
      if      (icPos.eq.0) then
         A = ABS(Tstp)
         T = T + (UHPflr((Tref - T) / A) + _XREALS(1.0d0)) * A
      else if (icPos.ge.1.and.icPos.le. _DATE_MAX) then
         jx = KAC(_CATTR_XID+icPos)
         call UHCfwx (iErr, T, Tref, Tstp, jx, KAC, KU,SU)
      else
         iErr = -1
      endif
      RETURN
      END
CCC_ & UHCfwx  ## time forwarding (external unit conversion)
      subroutine UHCfwx
     O    (iErr,
     M     T,
     I     Tref, Tstp, ixTstp, KAC,  KU, SU)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,_REALSTD)  T
      _INTENT(IN, _REALSTD)  Tref, Tstp
      _INTENT(IN, integer)   ixTstp
      _INTENT(IN, integer)   KAC (*)
      _INTENT(IN, integer)   KU(*)
      _INTENT(IN, _REALSTD)  SU(*)
      _REALSTD DTi, DT
      _REALSTD UHPflr
      _REALSTD Torg
      integer    nc
      integer    mco
      parameter (mco = 8)
CCC_  - Body
CC    negative unit conversion must be avoided
      if (Tstp.le.0.0d0) then
         iErr = -1
      else
         iErr = 0
         DTi  = Tref - T
         call UXCrvc (iErr, DTi, ixTstp,  KU,SU)
c$$$         write (*, *) 'FWX0', DTi, Tref, T
c
         DTi = UHPflr(DTi / Tstp) - _XREALS(2.0d0)
c$$$         write (*, *) 'FWX', DTi, Tstp, Tref, T
c
         nc = 0
         Torg = T
         DO
            if (nc.gt.mco) then
               iErr = -1
               goto 100
            endif
            DT = (DTi + _XREALS(nc)) * Tstp
            call UHCstx(iErr, T, Torg, DT, ixTstp, KAC, KU,SU)
            if (T.gt.Tref) goto 100
            nc = nc + 1
         ENDDO
 100     continue
      endif
      RETURN
      END
CCC_ & UHCt2c  ## sequential time to calendar date
      subroutine UHCt2c
     O    (KDT, ResC,
     I     TM,  KAC,  KU, SU)
      implicit none
      _INTENT(OUT,integer)   KDT(*)
      _INTENT(OUT,_REALSTD)  ResC
      _INTENT(IN, _REALSTD)  TM
      _INTENT(IN, integer)   KAC(*)
      _INTENT(IN, integer)   KU(*)
      _INTENT(IN, _REALSTD)  SU(*)
      integer kCal
c
      kCal = KAC(_CATTR_TYPE)
c
      if (kCal .eq. CAL_JGREGO) then
         call UHGt2g (KDT, ResC, TM, KAC, KU,SU)
      else if (kCal .eq. CAL_PGREGO) then
         call UHGt2g (KDT, ResC, TM, KAC, KU,SU)
      else if (kCal .eq. CAL_IDEAL) then
         call UHPt2i (KDT, ResC, TM, KAC, KU,SU)
      else if (kCal .eq. CAL_NORMAL) then
         call UHPt2i (KDT, ResC, TM, KAC, KU,SU)
      else
         write (*, *) 'INVALID calendar type'
         stop
      endif
      RETURN
      END
CCC_ & UHCc2t  ## calendar date to sequential time
      subroutine UHCc2t
     O    (TM,
     I     KDT, ResC, KAC,  KU,SU)
      _INTENT(OUT,_REALSTD)  TM
      _INTENT(IN, integer)   KDT(*)
      _INTENT(IN, _REALSTD)  ResC
      _INTENT(IN, integer)   KAC (*)
      _INTENT(IN, integer)   KU(*)
      _INTENT(IN, _REALSTD)  SU(*)
      integer kCal, juTM
c
      kCal = KAC(_CATTR_TYPE)
      juTM = KAC(_CATTR_USEQ)
c
      if (kCal .eq. CAL_JGREGO) then
         call UHGg2t (TM, KDT, ResC, KAC, KU,SU)
      else if (kCal .eq. CAL_PGREGO) then
         call UHGg2t (TM, KDT, ResC, KAC, KU,SU)
      else if (kCal .eq. CAL_IDEAL) then
         call UHPi2t (TM, KDT, ResC, KAC, KU,SU)
      else if (kCal .eq. CAL_NORMAL) then
         call UHPi2t (TM, KDT, ResC, KAC, KU,SU)
      else
         write (*, *) 'INVALID calendar type'
         stop
      endif
      RETURN
      END
CCC_ & UHCc2a  ## calendar date to string
      subroutine UHCc2a
     O    (STR,
     I     KDT, ResC, kFMT, KAC,  KU, AU)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,character) STR*(*)
      _INTENT(IN, integer)   KDT(*)
      _INTENT(IN, _REALSTD)  ResC
      _INTENT(IN, integer)   kFMT
      _INTENT(IN, integer)   KAC(*)
      _INTENT(IN, integer)   KU(*)
      _INTENT(IN, character) AU(*)*(*)
      character useq*(128)
      integer   jerr
CCC_  - Body
      call UXAqun (jErr, useq, KAC(_CATTR_USEQ), ' ', KU,AU)
      call UHPc2a (STR, KDT, ResC, kFMT, useq)
      RETURN
      END
CCC_* [UHG] Gregorian calendar utilities
CCC_ & UHGt2g  ## convert sequential time to Gregorian calendar date
      subroutine UHGt2g
     O    (KDT, ResC,
     I     TM,  KAC,  KU, SU)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)  KDT (*)
      _INTENT(OUT,_REALSTD) ResC
      _INTENT(IN, _REALSTD) TM
      _INTENT(IN, integer)  KAC (*)
      _INTENT(IN, integer)  KU(*)
      _INTENT(IN, _REALSTD) SU(*)
      integer  JulD
      _REALSTD ResJ
      integer  jxD2t, jxS2t
      logical  OPG
CCC_  - Body
      jxD2t = KAC(_CATTR_XDAY)
      jxS2t = KAC(_CATTR_XSEC)
      OPG   = (KAC(_CATTR_TYPE).eq. CAL_PGREGO)
      call UHPt2j (JulD, ResJ, TM,   jxD2t, KU,SU)
      call UHGj2g (KDT,  ResC, JulD, ResJ, jxS2t, OPG, KU,SU)
      RETURN
      END
CCC_ & UHGj2g  ## Julian day to Gregorian calendar date
      subroutine UHGj2g
     O    (KDT,   ResC,
     I     JulDi, ResJ, ixS2t, OPG,   KU, SU)
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(OUT,integer)  KDT (*)
      _INTENT(OUT,_REALSTD) ResC
      _INTENT(IN, integer)  JulDi
      _INTENT(IN, _REALSTD) ResJ
      _INTENT(IN, integer)  ixS2t
      _INTENT(IN, logical)  OPG
      _INTENT(IN, integer)  KU(*)
      _INTENT(IN, _REALSTD) SU(*)
CCC_   = Interior
      integer  JulD
      _REALSTD THD, ResS
      integer  KY, KMO, KD, KH, KMI, KS
      integer  NC, NK,  NE
c$$$      integer  NS
      integer  jErr
CCC_  - Body
      JulD  = JulDi
CCC_   . day adjustment (0.5 day shift)
      THD = 43200.0d0
      call UXCcnv(jErr, THD, ixS2t,  KU,SU)
      if (ResJ.ge.THD) then
         JulD = JulD + 1
         ResC = ResJ - THD
      else
         ResC = ResJ + THD
      endif
c
      if (OPG.or.JulD.ge.2299161) then
         JulD = JulD + 1 + (JulD - 1867216) / 36524
     $        - (JulD - 1867216) / 146096
      endif
      JulD = JulD + 1524
c
      NC = INT ((_XREALS(JulD) - _XREALS(122.1d0)) / _XREALS(365.25d0))
      NK = 365 * NC + NC / 4;
      NE = INT (_XREALS(JulD - NK) / _XREALS(30.6001d0))
c
      KY  = NC - 4716
      KMO = NE - 1
      if (KMO.gt.12) then
         KMO = KMO - 12
         KY  = KY  + 1
      endif
      KD  = JulD - NK - int (_XREALS(30.6d0) * _XREALS(NE))
CC    this is worse
c$$$      call UHPtsb(ResC, KH,  KAC(_CATTR_XHR))
c$$$      call UHPtsb(ResC, KMI, KAC(_CATTR_XMIN))
CC    this is better
      call UHPtsb(ResC, KS,  ixS2t, KU,SU)
      KH  = KS / 3600
      KMI = MOD(KS, 3600) / 60
      KS  = MOD(KS, 60)
c
      KDT (_DATE_YR)  = KY
      KDT (_DATE_MON) = KMO
      KDT (_DATE_DAY) = KD
      KDT (_DATE_HR)  = KH
      KDT (_DATE_MIN) = KMI
      KDT (_DATE_SEC) = KS
c
      RETURN
      END
CCC_ & UHGg2t  ## convert Gregorian calendar date to sequential time
      subroutine UHGg2t
     O    (TM,
     I     KDT, ResC, KAC,  KU,SU)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,_REALSTD) TM
      _INTENT(IN, integer)  KDT (*)
      _INTENT(IN, _REALSTD) ResC
      _INTENT(IN, integer)  KAC (*)
      _INTENT(IN, integer)  KU(*)
      _INTENT(IN, _REALSTD) SU(*)
      integer  JulD
      integer  jxD2t, jxS2t
      _REALSTD ResJ
      logical  OPG
CCC_  - Body
      jxD2t = KAC(_CATTR_XDAY)
      jxS2t = KAC(_CATTR_XSEC)
      OPG   = (KAC(_CATTR_TYPE).eq. CAL_PGREGO)
      call UHGg2j (JulD, ResJ, KDT,  ResC, jxS2t, OPG, KU,SU)
      call UHPj2t (TM,   JulD, ResJ, jxD2t, KU,SU)
      RETURN
      END
CCC_ & UHGg2j  ## Gregorian to Julian day
      subroutine UHGg2j
     O    (JulD, ResJ,
     I     KDT,  ResC, ixS2t, OPG,   KU, SU)
CCC_  - Description
CC      ResJ, ResC [useq]
CC
CCC_   . CAUTION
CC      Date normalization is performed only for month/year.
CC      Too large deviation from the normal range of day, hr,
CC      min and sec may result in undesired conversion.
CC      This is due to the gap during A.D. 1582, and therefore
CC      only happens when the deviation is across the gap.
CC
CC      1582/10/4
CC      1582/10/5  ==  10/15
CC      1582/10/6  ==  10/16
CC      :
CC      1582/10/14 ==  10/24
CC      1582/10/15 == *10/15*
CC      1582/10/16 ==  10/16
CC
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(OUT,integer)  JulD
      _INTENT(OUT,_REALSTD) ResJ
      _INTENT(IN, integer)  KDT (*)
      _INTENT(IN, _REALSTD) ResC
      _INTENT(IN, integer)  ixS2t
      _INTENT(IN, logical)  OPG
      _INTENT(IN, integer)  KU(*)
      _INTENT(IN, _REALSTD) SU(*)
      integer jE
CCC_   = Interior
      integer   KY,  KMO,  KD, KH, KMI, KS
      integer   JHSH
      logical   OGREG
c$$$      logical   OBC
      _REALSTD  ResS
CCC_   = function
#if HAVE_F77_FLOOR == 0
      integer floorS
#define FLOOR(V) FLOORS(V)
#endif
CCC_  - Body
      KY  = KDT (_DATE_YR)
      KMO = KDT (_DATE_MON)
      KD  = KDT (_DATE_DAY)
      KH  = KDT (_DATE_HR)
      KMI = KDT (_DATE_MIN)
      KS  = KDT (_DATE_SEC)
c
c$$$      OBC   = (KY.le.0)
c$$$      OGREG = ((KY.gt.1582)
c$$$     $         .or. ((KY.eq.1582 .and. KMO.gt.10))
c$$$     $         .or. ((KY.eq.1582 .and. KMO.eq.10 .and. KD.ge.15)))
CCC_  - normalize
      if (KMO.le.0) then
         KY  = KY - ((-KMO) / 12 + 1)
         KMO = 12 - MOD (-KMO, 12)
      endif
      if (KMO.gt.12) then
         KY  = KY + (KMO - 1) / 12
         KMO = MOD (KMO - 1, 12) + 1
      endif
CCC_  - compute
c$$$      OBC   = (KY.le.0)
      OGREG = ((KY.gt.1582)
     $         .or. ((KY.eq.1582 .and. KMO.gt.10))
     $         .or. ((KY.eq.1582 .and. KMO.eq.10 .and. KD.ge.15)))
c
      if (KMO.lt.3) then
         KY  = KY  - 1
         KMO = KMO + 12
      endif
c
      if (KH.lt.12) then
         JulD = 0
         JHSH = 12
      else
         JulD = 1
         JHSH = -12
      endif
c
      ResS = _XREALS((KH + JHSH) * 3600 + KMI * 60 + KS)
      call UXCcnv(jE, ResS, ixS2t,   KU,SU)
      ResJ = ResC + ResS
c
#if 0
      if (OBC) then
         JulD = JulD + (KY - 3) / 4
         if (OPG) then
            JulD = JulD + 2 - (KY - 99)/ 100 + (KY - 399)/ 400
         endif
      else
         JulD = JulD + KY /4
         if (OPG.or.OGREG) then
            JulD = JulD + 2 - KY / 100 + KY / 400
         endif
      endif
#else
      JulD = JulD + FLOOR(_XREALS(KY) / _XREALS(4.0d0))
      if (OPG.or.OGREG) then
         JulD = JulD + 2
     $        - FLOOR(_XREALS(KY) / _XREALS(100.0d0))
     $        + FLOOR(_XREALS(KY) / _XREALS(400.0d0))
      endif
#endif
      JulD = JulD + 1720994 + KY * 365
     $     + (KMO + 1) * 30 + (KMO + 1) * 3 / 5 + KD
C
      RETURN
      END
CCC_* [UHP] Calendar primitives
CCC_ & UHPt2i  ## convert time to ideal calendar
      subroutine UHPt2i
     O    (KDT, ResC,
     I     T,   KAC,   KU, SU)
CCC_  - Description
CC      T, ResC [useq]
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   KDT (*)
      _INTENT(OUT,_REALSTD)  ResC
      _INTENT(IN, _REALSTD)  T
      _INTENT(IN, integer)   KAC (*)
      _INTENT(IN, integer)   KU(*)
      _INTENT(IN, _REALSTD)  SU(*)
      _REALSTD  TT, E
      integer   jE
      integer   jp
CCC_  - Body
      E = OPT_IDEAL_EPOCH_SEC
      call UXCcnv (jE, E, KAC(_CATTR_XSEC),  KU,SU)
      TT = T + E
c
#if _DATE_YR > _DATE_SEC
#   error 'invalid date index'
#endif
      do jp = _DATE_YR, _DATE_SEC
         call UHPtsb (TT, KDT(jp),  KAC(_CATTR_XID+jp), KU,SU)
         KDT(jp) = KDT(jp) + KDT(_CATTR_DOFF+jp)
      enddo
      ResC = TT
      RETURN
      END
CCC_ & UHPtsb  ## convert time to calendar item (with conversion)
      subroutine UHPtsb (T, IV, ixV,  KU, SU)
      implicit none
      _INTENT(INOUT,_REALSTD)  T
      _INTENT(OUT,  integer)   IV
      _INTENT(IN,   integer)   ixV
      _INTENT(IN,   integer)   KU(*)
      _INTENT(IN,   _REALSTD)  SU(*)
      integer  jE
      _REALSTD D, DI
      _REALSTD UHPflr
c
      D = T
      call UXCrvc (jE, D, ixV,  KU,SU)
      DI = UHPflr(D)
      IV = INT(DI)
      call UXCcnv (jE, DI, ixV, KU,SU)
      T = T - DI
      RETURN
      END
CCC_ & UHPtsu  ## convert time to calendar item (with units, UHPtsb wrapper)
      subroutine UHPtsu (T, iuT, IV, iuV,  KU, SU, AU)
      implicit none
      _INTENT(INOUT,_REALSTD)  T
      _INTENT(OUT,  integer)   IV
      _INTENT(IN,   integer)   iuT, iuV
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
      integer jErr
      integer ixVT
      call UXCxrg(jErr, ixVT, iuV, iuT,  KU,SU,AU)
      if (jErr.eq.0) then
         call UHPtsb(T, IV, ixVT, KU,SU)
      endif
      RETURN
      END
CCC_ & UHPi2t  ## convert ideal calendar to time
      subroutine UHPi2t
     O    (T,
     I     KDT, ResC, KAC,  KU, SU)
CCC_  - Description
CC      T, ResC [useq]
CCC_  - Declaration
      implicit none
      _INTENT(OUT,_REALSTD)  T
      _INTENT(IN, integer)   KDT (*)
      _INTENT(IN, _REALSTD)  ResC
      _INTENT(IN, integer)   KAC (*)
      _INTENT(IN, integer)   KU(*)
      _INTENT(IN, _REALSTD)  SU(*)
      integer   jE
      integer   jp
      integer   jv
      _REALSTD  E
CCC_  - Body
      T = 0.0d0
#if _DATE_YR > _DATE_SEC
#   error 'invalid date index'
#endif
      do jp = _DATE_SEC, _DATE_YR, -1
         jv = KDT(jp) - KAC(_CATTR_DOFF + jp)
         call UHPtad (T, jv, KAC(_CATTR_XID + jp), KU,SU)
      enddo
      T = T + ResC
c
      E = OPT_IDEAL_EPOCH_SEC
      call UXCcnv (jE, E, KAC(_CATTR_XSEC),  KU,SU)
      T = T - E
      RETURN
      END
CCC_ & UHPtad  ## convert calendar item to time (to add)
      subroutine UHPtad (T, IV, ixV,  KU, SU)
      implicit none
      _INTENT(INOUT,_REALSTD) T
      _INTENT(IN,   integer)  IV
      _INTENT(IN,   integer)  ixV
      _INTENT(IN,   integer)  KU(*)
      _INTENT(IN,   _REALSTD) SU(*)
      integer  jE
      _REALSTD D
c
      D = _XREALS(IV)
      call UXCcnv (jE, D, ixV,  KU, SU)
      T = T + D
      RETURN
      END
CCC_ & UHPj2t  ## convert Julian day (plus residual) to sequential time
      subroutine UHPj2t
     O    (T,
     I     JulD, ResJ, ixD2t, KU, SU)
CCC_  - Description
CC      T, ResJ [useq]
CCC_  - Declaration
      implicit none
      _INTENT(OUT,_REALSTD) T
      _INTENT(IN, integer)  JulD
      _INTENT(IN, _REALSTD) ResJ
      _INTENT(IN, integer)  ixD2t
      _INTENT(IN, integer)  KU(*)
      _INTENT(IN, _REALSTD) SU(*)
      integer    jErr
CCC_  - Body
      T = _XREALS(JulD - OPT_JULIAN_OFFSET)
      T = T - _XREALS(OPT_JULIAN_DAY_OFFSET)
      call UXCcnv (jErr, T, ixD2t,  KU, SU)
      T = T + ResJ
      RETURN
      END
CCC_ & UHPt2j  ## convert sequential time to Julian day (plus residual)
      subroutine UHPt2j
     O    (JulD, ResJ,
     I     T,    ixD2t,  KU, SU)
CCC_  - Description
CC      T, ResJ [useq]
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)  JulD
      _INTENT(OUT,_REALSTD) ResJ
      _INTENT(IN, _REALSTD) T
      _INTENT(IN, integer)  ixD2t
      _INTENT(IN, integer)  KU(*)
      _INTENT(IN, _REALSTD) SU(*)
      _REALSTD   DT, FD, Toff, Tsh
      integer    jErr
      _REALSTD   UHPflr
CCC_  - Body
c     offset within a day
      Toff = _XREALS(OPT_JULIAN_DAY_OFFSET)
      call UXCcnv (jErr, Toff, ixD2t,  KU,SU)
      Tsh = T + Toff
      DT  = Tsh
      call UXCrvc (jErr, DT, ixD2t,  KU,SU)
c     floor
      FD   = UHPflr(DT)
      JulD = INT(FD)
c     residual in seqential unit
      call UXCcnv (jErr, FD, ixD2t,  KU,SU)
      ResJ = Tsh - FD
c     day offset
      JulD = JulD + OPT_JULIAN_OFFSET
c
      call UHPjnm (JulD, ResJ,  ixD2t, KU,SU)
c
      RETURN
      END
CCC_ & UHPjnm  ## Julian day normalize
      subroutine UHPjnm (JulD, ResJ, ixD2t,  KU, SU)
      implicit none
      _INTENT(INOUT,integer)  JulD
      _INTENT(INOUT,_REALSTD) ResJ
      _INTENT(IN,   integer)  ixD2t
      _INTENT(IN,   integer)  KU(*)
      _INTENT(IN,   _REALSTD) SU(*)
      _REALSTD DD
      integer  jErr
      _REALSTD UHPflr
      _REALSTD DSH
c     adjust ResJ to [0:1] day
      DD = 1.0d0
      call UXCcnv (jErr, DD, ixD2t,  KU,SU)
      DSH  = UHPflr(ResJ / DD)
      JulD = JulD + INT(DSH)
      ResJ = ResJ - DSH * DD
      RETURN
      END
CCC_ & UHPc2a  ## convert calendar date to string
      subroutine UHPc2a
     O    (STR,
     I     KDT, ResC, kFMT, ures)
      implicit none
      _INTENT(OUT,character) STR*(*)
      _INTENT(IN, integer)   KDT (*)
      _INTENT(IN, _REALSTD)  ResC
      _INTENT(IN, integer)   kFMT
      _INTENT(IN, character) ures*(*)
      character S0*(128), S1*(128)
      character SY*(24)
      integer   kend, jp
      logical   ORES
c
      ORES = .FALSE.
 101  format (I4.4,   I2.2, I2.2, 1x, 3I2.2)
 102  format ('+', A, I2.2, I2.2, 1x, 3I2.2)
 103  format      (A, I2.2, I2.2, 1x, 3I2.2)
      if (kFMT.eq.0) then
         kend = _DATE_SEC
         ORES = .TRUE.
      else if (kFMT.lt.0) then
         kend = -1
      else
         kend = MIN(kFMT, _DATE_SEC)
      endif
      if      (KDT(_DATE_YR).gt.9999) then
         call USGlni(SY,KDT(_DATE_YR))
         write (S0, 102)
     $        _TRIM(SY),
     $        (KDT(jp), jp = _DATE_MON, kend)
      else if (KDT(_DATE_YR).lt.0) then
         call USGlni(SY,KDT(_DATE_YR))
         write (S0, 103)
     $        _TRIM(SY),
     $        (KDT(jp), jp = _DATE_MON, kend)
      else
         write (S0, 101)
     $        KDT(_DATE_YR),
     $        (KDT(jp), jp = _DATE_MON, kend)
      endif
      STR = S0
c
      if (ORES.or.ResC.ne. _XREALS(0.0d0)) then
         call USGlfs (S1, ResC, 'C')
         call USJsta (STR, ' ', S1)
         call USJsta (STR, ' ', ures)
      endif
      RETURN
      END
CCC_ & UHPcrs  ## calendar date reset (after idxC part)
      subroutine UHPcrs
     M    (KDT,
     I     idxC,  KAC)
      implicit none
      _INTENT(INOUT,integer) KDT(*)
      _INTENT(IN,   integer) idxC
      _INTENT(IN,   integer) KAC(*)
      integer jp
      do jp = MAX(1, idxC + 1), _DATE_MAX
         KDT(jp) = KAC(_CATTR_DOFF + jp)
      enddo
      RETURN
      END
CCC_ & UHPflr()  ## floor function
      _REALSTD function UHPflr(V)
      implicit none
      _INTENT(IN,_REALSTD) V
      UHPflr = AINT(V)
      if (UHPflr.gt.V) UHPflr = UHPflr - _XREALS(1.d0)
      RETURN
      END
CCC_* Calendar interfaces
CCC_ & UHiniU  ## Unison/Calendar Calendar units registration
      subroutine UHiniU
     O    (iErr,
     M     KU,  SU, AU)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
CCC_  - Body
      iErr = 0
CCC_   . Julian-Gregorian
      if (iErr.eq.0) call UXSdnl (iErr, 'yr#g',  'day', KU,SU,AU)
      if (iErr.eq.0) call UXSdnl (iErr, 'mon#g', 'day', KU,SU,AU)
      if (iErr.eq.0) call UXSdnl (iErr, 'kyr#g', 'day', KU,SU,AU)
CCC_   . proleptic Gregorian
      if (iErr.eq.0) call UXSdnl (iErr, 'yr#p',  'day', KU,SU,AU)
      if (iErr.eq.0) call UXSdnl (iErr, 'mon#p', 'day', KU,SU,AU)
      if (iErr.eq.0) call UXSdnl (iErr, 'kyr#p', 'day', KU,SU,AU)
      RETURN
      END
CCC_ & UHinit  ## Unison/Calendar initialization
      subroutine UHinit
     O    (iErr,
     O     KU,  SU,  AU,
     I     LKU, LSU, LAU,
     I     MUI, MDI, MCI, KTYPE,  IFP)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   KU(*)
      _INTENT(OUT,_REALSTD)  SU(*)
      _INTENT(OUT,character) AU(*)*(*)
      _INTENT(IN, integer)   LKU, LSU, LAU
      _INTENT(IN, integer)   MUI, MDI, MCI
      _INTENT(IN, integer)   KTYPE
      _INTENT(IN, integer)   IFP
CCC_  - Body
      iErr = 0
      if (iErr.eq.0) then
         call UXinit
     O       (iErr,
     O        KU,  SU,  AU,
     I        LKU, LSU, LAU,
     I        MUI, MDI, MCI, KTYPE,  IFP)
      endif
      if (iErr.eq.0) then
         call UHiniU(iErr, KU, SU, AU)
      endif
      RETURN
      END
CCC_& UXHCAL  ## Unison/Calendar announcement
      subroutine UXHCAL (STRA, STRB, IOP)
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
         STRA = 'OPT_JULIAN_OFFSET'
         write (STRB, *) OPT_JULIAN_OFFSET
      else if (IOP.eq.4) then
         STRA = 'OPT_JULIAN_DAY_OFFSET'
         write (STRB, *) OPT_JULIAN_DAY_OFFSET
      else if (IOP.eq.5) then
         STRA = 'OPT_IDEAL_EPOCH_SEC'
         write (STRB, *) OPT_IDEAL_EPOCH_SEC
      else if (IOP.eq.6) then
         STRA = 'OPT_UNIT_LEN'
         write (STRB, *) OPT_UNIT_LEN
      else
         STRA = ' '
         STRB = ' '
      endif
      RETURN
      END
CCC_* Test
CCC_ + begin
#if TEST_UXHCAL || WITH_TEST_UXHCAL
CCC_ & UHTEST_TINIT
      subroutine UHTEST_TINIT
     O    (iErr, T,
     I     SW,   KAC,  KU, SU)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,_REALSTD)  T
      _INTENT(IN, character) SW*(*)
      _INTENT(IN, integer)   KAC(*)
      _INTENT(IN, integer)   KU(*)
      _INTENT(IN, _REALSTD)  SU(*)
      integer KDT (_DATE_MAX)
      _REALSTD ResC
      character CDT*(8)
      integer   iys
      integer   jci
      integer   lsw
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
c
      iErr = 0
      if (SW.eq.' ') then
         jci = _DATE_SEC
      else
         call UHCqci(jci, SW, KAC)
      endif
      if (jci.gt.0) then
         KDT(_DATE_YR)  = 0
         KDT(_DATE_MON) = 1
         KDT(_DATE_DAY) = 1
         KDT(_DATE_HR)  = 0
         KDT(_DATE_MIN) = 0
         KDT(_DATE_SEC) = 0
         if (jci.ge. _DATE_YR)  KDT(_DATE_YR)  = 1973
         if (jci.ge. _DATE_MON) KDT(_DATE_MON) = 1
         if (jci.ge. _DATE_DAY) KDT(_DATE_DAY) = 30
         if (jci.ge. _DATE_HR)  KDT(_DATE_HR)  = 12
         if (jci.ge. _DATE_MIN) KDT(_DATE_MIN) = 34
         if (jci.ge. _DATE_SEC) KDT(_DATE_SEC) = 56
         ResC = 0.0d0
         call UHCc2t (T, KDT, ResC, KAC, KU,SU)
      else if (SW.eq.'0') then
         T = _XREALS(0.0d0)
      else
         if (SW(1:1).eq.'-') then
            CDT = SW(2:len(SW))
            iys = -1
         else
            CDT = SW
            iys = +1
         endif
         LSW = len_trim(CDT)
         if (LSW.le.8) then
            KDT(_DATE_YR)  = 0
            KDT(_DATE_MON) = 1
            KDT(_DATE_DAY) = 1
            KDT(_DATE_HR)  = 0
            KDT(_DATE_MIN) = 0
            KDT(_DATE_SEC) = 0
            if (LSW.ge.4) READ(CDT(1:4), *) KDT(_DATE_YR)
            if (LSW.ge.6) READ(CDT(5:6), *) KDT(_DATE_MON)
            if (LSW.ge.8) READ(CDT(7:8), *) KDT(_DATE_DAY)
            ResC = 0.0d0
            KDT(_DATE_YR) = KDT(_DATE_YR) * iys
            call UHCc2t (T, KDT, ResC, KAC, KU,SU)
         else
            iErr = -1
         endif
      endif
      RETURN
      END
CCC_ & UHTEST_JD_nml
      subroutine UHTEST_JD_nml
     O    (iErr,
     I     JulDi, ResJi, Ures,
     M     KU,    SU,    AU,   KDS, ADS)
CCC_  - Declaration
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   JulDi
      _INTENT(IN,   _REALSTD)  ResJi
      _INTENT(IN,   character) URES*(*)
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
      _INTENT(INOUT,integer)   KDS(*)
      _INTENT(INOUT,character) ADS(*)*(*)
c
      character CJD*(24)
      character CRJ*(32)
      character CSTR*(128)
      integer   JulD
      _REALSTD  ResJ
      integer   ixD2t
      integer   iplog
CCC_  - Body
      iErr = 0
      call UDSquo(iplog, KDS)
c
      call USGlni (CJD, JulDi)
      call USGlfs (CRJ, ResJi, 'C')
 201  format ('JNM:', A, '+', A, 1x, A)
 202  format ('JNM:', A, A, 1x, A)
      if (ResJi.ge.0.0d0) then
         write (CSTR, 201) _TRIM(CJD), _TRIM(CRJ), _TRIM(URES)
      else
         write (CSTR, 202) _TRIM(CJD), _TRIM(CRJ), _TRIM(URES)
      endif
c
      call UDSnew(iErr, KDS, ADS, 0, CSTR)
c
      JulD = JulDi
      ResJ = _XREALS(ResJi)
      call UXCxps (iErr, ixD2t, 'day', Ures, KU,SU,AU)
      call UHPjnm (JulD, ResJ,  ixD2t, KU,SU)
c
      call USGlni (CJD, JulD)
      call USGlfs (CRJ, ResJ, 'C')
      write (CSTR, 201) _TRIM(CJD), _TRIM(CRJ), _TRIM(URES)
 209  format ('RESULT: ', A, '+', A, 1x, A)
      if (COND_N(iplog)) then
         write (iplog, 209) _TRIM(CJD), _TRIM(CRJ), _TRIM(URES)
      else if (COND_S(iplog)) then
         write (*,     209) _TRIM(CJD), _TRIM(CRJ), _TRIM(URES)
      endif
      RETURN
      END
CCC_ & UHTEST_JD
      subroutine UHTEST_JD
     O    (iErr,
     I     KY,   KMO, KD, KH, RC,
     I     JDi,  RJi,
     M     KU,   SU,  AU, KDS, ADS)
CCC_  - Declaration
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   KY,   KMO, KD, KH
      _INTENT(IN,   _REALSTD)  RC
      _INTENT(IN,   integer)   JDi
      _INTENT(IN,   _REALSTD)  RJi
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
      _INTENT(INOUT,integer)   KDS(*)
      _INTENT(INOUT,character) ADS(*)*(*)
      integer  KDT (_DATE_MAX), KDTr(_DATE_MAX)
      integer  KAC (CATTR_MAX)
      integer  JD,  JDp
      _REALSTD RJ,  RJp, RCr
      logical  OPG
      integer  iplog
      character Useq*(12)
CCC_  - Body
      iErr = 0
      call UDSquo(iplog, KDS)
      Useq = 'day'
CCC_   . Banner
      if (iErr.eq.0) call UDSopn(iErr, KDS, ADS, 0,  'DATE:')
      if (iErr.eq.0) call UDSmai(iErr, KDS, ADS, 0, -1, ' ', KY)
      if (iErr.eq.0) call UDSmai(iErr, KDS, ADS, 0, -1, '/', KMO)
      if (iErr.eq.0) call UDSmai(iErr, KDS, ADS, 0, -1, '/', KD)
      if (iErr.eq.0) call UDSmai(iErr, KDS, ADS, 0, -1, ' ', KH)
      if (iErr.eq.0) call UDSmas(iErr, KDS, ADS, 0, -1, ':00 +', RC)
      if (iErr.eq.0) call UDSmaa(iErr, KDS, ADS, 0, 0, ' ', Useq)
CCC_   . Calendar setup
      call UHSinw (iErr, KAC, CAL_JGREGO, USEQ,   KU,SU,AU)
CCC_   . Compute
      KDT(_DATE_YR)  = KY
      KDT(_DATE_MON) = KMO
      KDT(_DATE_DAY) = KD
      KDT(_DATE_HR)  = KH
      KDT(_DATE_MIN) = 0
      KDT(_DATE_SEC) = 0
      OPG   = (KAC(_CATTR_TYPE).eq. CAL_PGREGO)
c
      call UHGg2j
     $     (JD, RJ, KDT, RC, KAC(_CATTR_XSEC), OPG, KU,SU)
      call UHPjnm(JD, RJ, KAC(_CATTR_XDAY), KU,SU)
c
      call UHGg2j
     $     (JDp, RJp, KDT, RC, KAC(_CATTR_XSEC), (.not.OPG), KU,SU)
      call UHPjnm(JDp, RJp, KAC(_CATTR_XDAY), KU,SU)
      call UHGj2g
     $     (KDTr, RCr, JDp, RJp, KAC(_CATTR_XSEC), (.not.OPG), KU,SU)
CCC_   . result [J-G]
 101  format ('JD[J-G]:', I9, F5.1)
      if (COND_N(iplog)) then
         write (iplog, 101) JD, RJ
      else if (COND_S(iplog)) then
         write (*,     101) JD, RJ
      endif
c
      call UDTich (iErr, JD, JDi, 'JD', iplog)
      call UDTsch (iErr, RJ, RJi, 'RJ', iplog)
CCC_   . result [pG]
 102  format ('JD[pG]:',
     $     I4, 2I2.2, 1x, 3I2.2, 1x, F5.1, ' :: ', I9, F5.1)
      if (COND_N(iplog)) then
         write (iplog, 102) KDTr, RCr, JDp, RJp
      else if (COND_S(iplog)) then
         write (*,     102) KDTr, RCr, JDp, RJp
      endif
c
      RETURN
      END
CCC_ & UHTEST_JD_ctrl
      subroutine UHTEST_JD_ctrl
     $     (iErr,  KLVL,  KU,SU,AU,  KD,AD)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   KLVL
      _INTENT(INOUT,integer)   KD(*)
      _INTENT(INOUT,character) AD(*)*(*)
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
CCC_  - Body
      iErr = 0
      if (iErr.eq.0) call UDSnew(iErr, KD, AD, 0,  'JULIAN DAY')
      if (iErr.eq.0) call UDSset(iErr, KD, AD, +1)
CCC_   . normalize check
      if (iErr.eq.0) call UDSnew(iErr, KD, AD, 0,  'NORMALIZATION')
      if (iErr.eq.0) call UDSset(iErr, KD, AD, +1)
      if (iErr.eq.0) then
         call UHTEST_JD_nml
     $        (iErr, 100,  100.d0, 'hr', KU,SU,AU, KD,AD)
      endif
      if (iErr.eq.0) then
         call UHTEST_JD_nml
     $        (iErr, 100, -100.d0, 'hr', KU,SU,AU, KD,AD)
      endif
      if (iErr.eq.0) call UDSset(iErr, KD, AD, -1)
CCC_   . orig
      if (iErr.eq.0) call UDSnew(iErr, KD, AD, 0,  'CONVERSION')
      if (iErr.eq.0) call UDSset(iErr, KD, AD, +1)
      if (iErr.eq.0) then
         call UHTEST_JD
     O       (iErr,
     $        1973 , 1, 30,  12, 0.0d0, 2441713, 0.0d0,
     $        KU,SU,AU, KD,AD)
      endif
CCC_   . residual
      if (iErr.eq.0) then
         call UHTEST_JD
     O       (iErr,
     $        1973 , 1, 30,  0,  0.5d0, 2441713, 0.0d0,
     $        KU,SU,AU, KD,AD)
      endif
CCC_   . hour/day
      if (iErr.eq.0) then
         call UHTEST_JD
     O       (iErr,
     $        1973 , 1, 31, -12, 0.0d0, 2441713, 0.0d0,
     $        KU,SU,AU, KD,AD)
      endif
      if (iErr.eq.0) then
         call UHTEST_JD
     O       (iErr,
     $        1973 , 2,  5, -132, 0.0d0, 2441713, 0.0d0,
     $        KU,SU,AU, KD,AD)
      endif
CCC_   . day/month
      if (iErr.eq.0) then
         call UHTEST_JD
     O       (iErr,
     $        1973 , 2, -1,  12, 0.0d0, 2441713, 0.0d0,
     $        KU,SU,AU, KD,AD)
      endif
      if (iErr.eq.0) then
         call UHTEST_JD
     O       (iErr,
     $        1973 , 3, -29,  12, 0.0d0, 2441713, 0.0d0,
     $        KU,SU,AU, KD,AD)
      endif
      if (iErr.eq.0) then
         call UHTEST_JD
     O       (iErr,
     $        1973 , 4, -58, -36, 0.0d0, 2441713, 0.0d0,
     $        KU,SU,AU, KD,AD)
      endif
CCC_   . month/year
      if (iErr.eq.0) then
         call UHTEST_JD
     O       (iErr,
     $        1972 , 13, 30,  12, 0.0d0, 2441713, 0.0d0,
     $        KU,SU,AU, KD,AD)
      endif
      if (iErr.eq.0) then
         call UHTEST_JD
     O       (iErr,
     $        1971 , 25, 30,  12, 0.0d0, 2441713, 0.0d0,
     $        KU,SU,AU, KD,AD)
      endif
      if (iErr.eq.0) then
         call UHTEST_JD
     O       (iErr,
     $        1974 , -11, 30,  12, 0.0d0, 2441713, 0.0d0,
     $        KU,SU,AU, KD,AD)
      endif
      if (iErr.eq.0) then
         call UHTEST_JD
     O       (iErr,
     $        1975 , -23, 30,  12, 0.0d0, 2441713, 0.0d0,
     $        KU,SU,AU, KD,AD)
      endif
CCC_   . blank: 1582/10/5-14
      if (iErr.eq.0) then
         call UHTEST_JD
     O       (iErr,
     $        1582 , 10, 4,  12, 0.0d0,   2299160, 0.0d0,
     $        KU,SU,AU, KD,AD)
      endif
CCC_    * (10/4 + 1day == 10/15)
      if (iErr.eq.0) then
         call UHTEST_JD
     O       (iErr,
     $        1582 , 10, 5,   12, 0.0d0,  2299161, 0.0d0,
     $        KU,SU,AU, KD,AD)
      endif
      if (iErr.eq.0) then
         call UHTEST_JD
     O       (iErr,
     $        1582 , 10, 15,  12, 0.0d0,  2299161, 0.0d0,
     $        KU,SU,AU, KD,AD)
      endif
CCC_    * (10/4 + 10day == 10/24)
      if (iErr.eq.0) then
         call UHTEST_JD
     O       (iErr,
     $        1582 , 10, 24,  12, 0.0d0,  2299170, 0.0d0,
     $        KU,SU,AU, KD,AD)
      endif
      if (iErr.eq.0) then
         call UHTEST_JD
     O       (iErr,
     $        1582 , 10, 14,  12, 0.0d0,  2299170, 0.0d0,
     $        KU,SU,AU, KD,AD)
      endif
CCC_   . across the gap
      if (iErr.eq.0) then
         call UHTEST_JD
     O       (iErr,
     $        1582 ,  9, 35,  12, 0.0d0,  2299161, 0.0d0,
     $        KU,SU,AU, KD,AD)
      endif
      if (iErr.eq.0) then
         call UHTEST_JD
     O       (iErr,
     $        1582 , 9,  30,  12, 0.0d0,  2299156, 0.0d0,
     $        KU,SU,AU, KD,AD)
      endif
      if (iErr.eq.0) then
         call UHTEST_JD
     O       (iErr,
     $        1582 , 11, -21, 12, 0.0d0,  2299156, 0.0d0,
     $        KU,SU,AU, KD,AD)
      endif
CCC_   . epoch
      if (iErr.eq.0) then
         call UHTEST_JD
     O       (iErr,
     $        1 , 1, 1,  12, 0.0d0, 1721424, 0.0d0,
     $        KU,SU,AU, KD,AD)
      endif
      if (iErr.eq.0) then
         call UHTEST_JD
     O       (iErr,
     $        0 , 1, 1,  12, 0.0d0, 1721058, 0.0d0,
     $        KU,SU,AU, KD,AD)
      endif
      if (iErr.eq.0) then
         call UHTEST_JD
     O       (iErr,
     $        -1 , 1, 1,  12, 0.0d0, 1720693, 0.0d0,
     $        KU,SU,AU, KD,AD)
      endif
      if (iErr.eq.0) then
         call UHTEST_JD
     O       (iErr,
     $        -2 , 1, 1,  12, 0.0d0, 1720328, 0.0d0,
     $        KU,SU,AU, KD,AD)
      endif
      if (iErr.eq.0) then
         call UHTEST_JD
     O       (iErr,
     $        -3 , 1, 1,  12, 0.0d0, 1719963, 0.0d0,
     $        KU,SU,AU, KD,AD)
      endif
      if (iErr.eq.0) then
         call UHTEST_JD
     O       (iErr,
     $        -100 , 1, 1,  12, 0.0d0, 1684533, 0.0d0,
     $        KU,SU,AU, KD,AD)
      endif
      if (iErr.eq.0) then
         call UHTEST_JD
     O       (iErr,
     $        -99 ,  1, 1,  12, 0.0d0, 1684899, 0.0d0,
     $        KU,SU,AU, KD,AD)
      endif
c
      if (iErr.eq.0) call UDSset(iErr, KD, AD, -1)
      if (iErr.eq.0) call UDSset(iErr, KD, AD, -1)
      RETURN
      END
CCC_ & UHTEST_GREGO
      subroutine UHTEST_GREGO
     O    (iErr,
     I     USEQ,  KU,SU,AU,  KDS,ADS)
CCC_  - Description
CC        Initial time: 1973/1/30 + RINI[URES]
CC        Time step:    DSTP[day] + RSTP[URES]
CCC_  - Declaration
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   character) USEQ*(*)
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
      _INTENT(INOUT,integer)   KDS(*)
      _INTENT(INOUT,character) ADS(*)*(*)
c
      character URES*16
      _REALSTD  DSTP, RSTP, RINI
      integer   NMAX
      integer   iplog
c
      integer  KDT (_DATE_MAX)
      integer  KAC (CATTR_MAX)
      integer  n
      integer  JulD
      integer  ixRT, iuRes
      _REALSTD ResC, ResJ, DTR
      character CSTR*(128), CJD*(128), CRJ*(128)
      logical   OPG
CCC_  - Body
      iErr = 0
      call UDSquo(iplog, KDS)
c
      DSTP = 1.0d0
      RINI = 11.1d0
      RSTP = -3.0d0
      URES = 'hr'
      NMAX = 100
CCC_   . Banner
 201  format ('GREGO:', A, '+', A)
      write (CSTR, 201) _TRIM(USEQ), _TRIM(URES)
      call UDSnew(iErr, KDS, ADS, 0, CSTR)
CCC_   . Calendar setup
      call UHSinw (iErr, KAC, CAL_JGREGO, USEQ,   KU,SU,AU)
      OPG   = (KAC(_CATTR_TYPE).eq. CAL_PGREGO)
CCC_   . If not error
      if (iErr.eq.0) then
CCC_    * Start time
         call UHSchk (iErr, KAC, KU,AU, iplog)
         KDT (_DATE_YR)  = 1973
         KDT (_DATE_MON) = 1
         KDT (_DATE_DAY) = 30
c
         call UXCinq(iErr, iuRes, URES, KU,AU)
         ResC = RINI
         call UHPtsu
     $        (ResC, iuRes, KDT(_DATE_HR),  KAC(_CATTR_UHR),  KU,SU,AU)
         call UHPtsu
     $        (ResC, iuRes, KDT(_DATE_MIN), KAC(_CATTR_UMIN), KU,SU,AU)
         call UHPtsu
     $        (ResC, iuRes, KDT(_DATE_SEC), KAC(_CATTR_USEC), KU,SU,AU)
CCC_    * Time step
         call UHCqxu(iErr, ixRT, URES, KAC, KU,SU,AU)
         DTR = RSTP
         call UXCcnv (iErr, DTR,  ixRT,  KU,SU)
         call UXCcnv (iErr, ResC, ixRT,  KU,SU)
CCC_    * Julian day
         call UHGg2j
     $        (JulD, ResJ, KDT, ResC, KAC(_CATTR_XSEC), OPG, KU,SU)
CCC_    * Info
         call UHCc2a (CSTR, KDT, ResC, 0, KAC, KU,AU)
         call USGlni (CJD, JulD)
         call USGlfs (CRJ, ResJ, 'CI')
 102     format ('START: ', A, '[', A, 1x, A, ']')
 103     format ('DT: ', E12.3, ' day ',
     $        E12.3, 1x, A, ' (', E12.3, 1x, A, ')')
         if (COND_N(iplog)) then
            write (iplog, 102) _TRIM(CSTR), _TRIM(CJD), _TRIM(CRJ)
            write (iplog, 103) DSTP, DTR, _TRIM(USEQ), RSTP, _TRIM(URES)
         else if (COND_S(iplog)) then
            write (*,     102) _TRIM(CSTR), _TRIM(CJD), _TRIM(CRJ)
            write (*,     103) DSTP, DTR, _TRIM(USEQ), RSTP, _TRIM(URES)
         endif
CCC_    * Time evolution (use JD+RJ)
 101     format (I4.4, 1x, A, 1x, I8, 1x, E16.9)
         do n = 1, NMAX
            call UHGj2g
     $           (KDT, ResC, JulD, ResJ, KAC(_CATTR_XSEC), OPG, KU,SU)
            call UHCc2a(CSTR, KDT, ResC, 0, KAC,  KU,AU)
            if (COND_N(iplog)) then
               write (iplog, 101) n, _TRIM(CSTR), JulD, ResJ
            else if (COND_S(iplog)) then
               write (*,     101) n, _TRIM(CSTR), JulD, ResJ
            endif
            JulD = JulD + INT(DSTP)
            ResJ = ResJ + DTR
            call UHPjnm (JulD, ResJ, KAC(_CATTR_XDAY), KU,SU)
         enddo
      endif
CCC_   . return
      RETURN
      END
CCC_ & UHTEST_GREGO_ctrl
      subroutine UHTEST_GREGO_ctrl
     $     (iErr,  KLVL,  KU,SU,AU,  KD,AD)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   KLVL
      _INTENT(INOUT,integer)   KD(*)
      _INTENT(INOUT,character) AD(*)*(*)
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
CCC_  - Body
      iErr = 0
      if (iErr.eq.0) call UDSnew(iErr, KD, AD, 0,  'GREGORIAN')
      if (iErr.eq.0) call UDSset(iErr, KD, AD, +1)
c
      if (iErr.eq.0)
     $     call UHTEST_GREGO(iErr, 'day', KU,SU,AU, KD,AD)
      if (iErr.eq.0)
     $     call UHTEST_GREGO(iErr, 'hr',  KU,SU,AU, KD,AD)
      if (iErr.eq.0)
     $     call UHTEST_GREGO(iErr, 's',   KU,SU,AU, KD,AD)
      if (iErr.eq.0)
     $     call UHTEST_GREGO(iErr, 'ds',  KU,SU,AU, KD,AD)
      if (iErr.eq.0)
     $     call UHTEST_GREGO(iErr, 'mon#g', KU,SU,AU, KD,AD)
c     clear error
      if (iErr.ne.0) iErr = 0
c
      if (iErr.eq.0) call UDSset(iErr, KD, AD, -1)
      RETURN
      END
CCC_ & UHTEST_QCU
#define FW_W 0
#define FW_I 1
#define FW_U 2
#define FW_X 3
      subroutine UHTEST_QCU (iErr, icPosX, U, KM, KAC,  KU, SU, AU)
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(OUT,  integer)   icPosX
      _INTENT(IN,   character) U*(*)
      _INTENT(IN,   integer)   KAC(*)
      _INTENT(IN,   integer)   KM
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
      integer idU
      iErr = 0
      if (KM.eq. FW_X) then
         call UXCinq (iErr, idU, U, KU,AU)
         if (iErr.eq.0) then
            call UXCxrg (iErr, icPosX, idU, KAC(_CATTR_USEQ), KU,SU,AU)
         endif
      else
         call UHCqci(icPosX, U, KAC)
         if (icPosX.lt.0) iErr = -1
      endif
      RETURN
      END
CCC_ & UHTEST_DM
      subroutine UHTEST_DM (KM, C)
      implicit none
      _INTENT(OUT,integer)   KM
      _INTENT(IN, character) C*(*)
      if      (C(1:1).eq.'w') then
         KM = FW_W
      else if (C(1:1).eq.'i') then
         KM = FW_I
      else if (C(1:1).eq.'u') then
         KM = FW_U
      else if (C(1:1).eq.'x') then
         KM = FW_X
      else
         KM = -1
      endif
      RETURN
      END
CCC_ & UHTEST_GGAP
      subroutine UHTEST_GGAP
     O    (iErr, kCalT, SWD, KU,SU,AU, KD,AD)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   kCalT
      _INTENT(IN,   character) SWD*(*)
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
      _INTENT(INOUT,integer)   KD(*)
      _INTENT(INOUT,character) AD(*)*(*)
CCC_  - Body
      iErr = 0
      call UDSopn(iErr, KD, AD, 0, 'GAP')
      call UDSmsg(iErr, KD, AD, 0, 0, SWD)
      call UDSset(iErr, KD, AD, +1)
c
      call UHTEST_CAL
     O    (iErr,
     I     kCalT,      SWD,
     I     '15821001', 'day', 1.d0, 'DAY',
     I     ' ',         0.0d0, ' ', 0.0D0, ' ',
     I     ' ',  10,   KU,SU,AU,  KD,AD)
      call UHTEST_CAL
     O    (iErr,
     I     kCalT,      SWD,
     I     '15821001', 'day', 2.d0, 'DAY',
     I     ' ',         0.0d0, ' ', 0.0D0, ' ',
     I     ' ',  10,   KU,SU,AU,  KD,AD)
      call UHTEST_CAL
     O    (iErr,
     I     kCalT,      SWD,
     I     '15821001', 'day', 4.d0, 'DAY',
     I     ' ',         0.0d0, ' ', 0.0D0, ' ',
     I     ' ',  10,   KU,SU,AU,  KD,AD)
      call UHTEST_CAL
     O    (iErr,
     I     kCalT,      SWD,
     I     '15821001', 'day', 8.d0, 'DAY',
     I     ' ',         0.0d0, ' ', 0.0D0, ' ',
     I     ' ',  10,   KU,SU,AU,  KD,AD)
      call UHTEST_CAL
     O    (iErr,
     I     kCalT,      SWD,
     I     '15821001', 'day', 16.d0, 'DAY',
     I     ' ',         0.0d0, ' ', 0.0D0, ' ',
     I     ' ',  10,   KU,SU,AU,  KD,AD)
c
      call UDSset(iErr, KD, AD, -1)
      RETURN
      END
CCC_ & UHTEST_CAL
      subroutine UHTEST_CAL
     O    (iErr,
     I     kCalT, SWD,
     I     SWIS,  USEQ, DTS,  UDTS,
     I     SWIK,        DTK,  UDTK, EK, UK,
     I     FMT,   NMAX,
     M     KU,    SU,   AU, KDS,ADS)
CCC_  - Description
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   kCalT
      _INTENT(IN,   character) SWD*(*)
      _INTENT(IN,   character) SWIS*(*)
      _INTENT(IN,   character) USEQ*(*), UDTS*(*)
      _INTENT(IN,   character) SWIK*(*)
      _INTENT(IN,   character) UDTK*(*), UK*(*)
      _INTENT(IN,   character) FMT*(*)
      _INTENT(IN,   _REALSTD)  DTS, DTK, EK
      _INTENT(IN,   integer)   NMAX
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
      _INTENT(INOUT,integer)   KDS(*)
      _INTENT(INOUT,character) ADS(*)*(*)
c
      integer  iplog
      _REALSTD Ts,  Tnxs
      _REALSTD Tk,  Tnxk
      _REALSTD Etol
      character CSTR*(128), CSTR1*(128)
c
      integer KFWs, KFWk
c
      logical OKNOT
      integer KAC (CATTR_MAX)
      integer icDT, icDK, icE
      integer n
      integer kFMT, kFMTi
CCC_  - Body
      iErr = 0
      call UDSquo(iplog, KDS)
c
      OKNOT = (UDTK.ne.' ')
c
 201  format ('EVOL:', A, ': ', A, 1x, A)
      write (CSTR, 201) _TRIM(USEQ), _TRIM(UDTS), SWD
      if (OKNOT) then
 202     format ('[KNOT:', A, ': ', A, ']')
         write (CSTR1, 202) _TRIM(UDTK), _TRIM(UK)
         call USJxra(CSTR, ' ', CSTR1)
      endif
      call UDSnew(iErr, KDS, ADS, 0, CSTR)
CCC_   . init
      call UHSinw (iErr, KAC, KCALT, USEQ,   KU,SU,AU)
c
      call UHTEST_DM(KFWs, SWD(1:1))
      call UHTEST_DM(KFWk, SWD(2:2))
CCC_   . calendar format
      call UHCqci(KFMTi, FMT, KAC)
      if (KFMTi.ge.0) then
         KFMT = CAL_FMT_DATE
      else
         KFMT = CAL_FMT_SEQ
         if (FMT.eq.' ') then
            KFMTi = 0
         else
            call UHCqxu(iErr, KFMTi, FMT, KAC, KU,SU,AU)
         endif
      endif
CCC_   . set initial state
      if (iErr.eq.0) call UHTEST_TINIT(iErr, Ts, SWIS, KAC, KU,SU)
c
      if (iErr.eq.0)
     $     call UHTEST_QCU(iErr, icDT, UDTS, KFWs, KAC, KU,SU,AU)
      call UDMfi1 (iplog, '(''CI/DT: '', I5)', icDT)
      if (OKNOT) then
         if (iErr.eq.0) call UHTEST_TINIT(iErr, Tk, SWIK, KAC, KU,SU)
         if (iErr.eq.0)
     $        call UHTEST_QCU(iErr, icDK, UDTK, KFWk, KAC, KU,SU,AU)
         if (iErr.eq.0)
     $        call UHTEST_QCU(iErr, icE,  UK,   FW_X, KAC, KU,SU,AU)
         if (iErr.eq.0) then
            Etol = EK
            call UXCcnv (iErr, Etol, icE,  KU,SU)
         endif
         if (iErr.eq.0) then
            if       (KFWk.eq. FW_X) then
               call UHCfwx(iErr, Tk, Ts, DTK, icDK, KAC, KU,SU)
            else if  (KFWk.eq. FW_W) then
               call UHCfww(iErr, Tk, Ts, DTK, icDK, KAC, KU,SU)
            else if  (KFWk.eq. FW_U) then
               call UHCfwu(iErr, Tk, Ts, DTK, icDK, KAC, KU,SU)
            else if  (KFWk.eq. FW_I) then
               call UHCfwi(iErr, Tk, Ts, DTK, icDK, KAC, KU,SU)
            endif
         endif
         call UDMfi1 (iplog, '(''CI/DK: '', I5)', icDK)
         call UDMfi1 (iplog, '(''CI/E: '',  I5)', icE)
      endif
CCC_   . loop
 103  format ( 'KNOT [', A, '] ')
 102  format (I4.4, ' [', A, 1x, A, '] ', 3E24.16)
      if (OKNOT) then
         call UHSt2a (CSTR,  Tk,   kFMT, kFMTi, KAC, KU,SU,AU)
         write (*, 103) _TRIM(CSTR)
      endif
      do n = 1, NMAX
         if       (KFWs.eq. FW_X) then
            call UHCstx(iErr, Tnxs, Ts, DTS, icDT, KAC, KU,SU)
         else if  (KFWs.eq. FW_W) then
            call UHCstw(iErr, Tnxs, Ts, DTS, icDT, KAC, KU,SU)
         else if  (KFWs.eq. FW_U) then
            call UHCstu(iErr, Tnxs, Ts, DTS, icDT, KAC, KU,SU)
         else if  (KFWs.eq. FW_I) then
            call UHCsti(iErr, Tnxs, Ts, DTS, icDT, KAC, KU,SU)
         endif
         if (OKNOT) then
            if (Tnxs.ge.(Tk-Etol)) then
               Tnxs = Tk
               if       (KFWk.eq. FW_X) then
                  call UHCfwx(iErr, Tk, Tnxs, DTK, icDK, KAC, KU,SU)
               else if  (KFWk.eq. FW_W) then
                  call UHCfww(iErr, Tk, Tnxs, DTK, icDK, KAC, KU,SU)
               else if  (KFWk.eq. FW_U) then
                  call UHCfwu(iErr, Tk, Tnxs, DTK, icDK, KAC, KU,SU)
               else if  (KFWk.eq. FW_I) then
                  call UHCfwi(iErr, Tk, Tnxs, DTK, icDK, KAC, KU,SU)
               endif
               call UHSt2a (CSTR,  Tk,   kFMT, kFMTi, KAC, KU,SU,AU)
               write (*, 103) _TRIM(CSTR)
            endif
         endif
         call UHSt2a (CSTR,  Ts,   kFMT, kFMTi, KAC, KU,SU,AU)
         call UHSt2a (CSTR1, Tnxs, kFMT, kFMTi, KAC, KU,SU,AU)
         write (*, 102) n, _TRIM(CSTR), _TRIM(CSTR1),
     $        Ts, Tnxs, Tnxs-Ts
         TS = TNXS
      enddo
c
      RETURN
      END
CCC_ & UHTEST_EVOL_ctrl
      subroutine UHTEST_EVOL_ctrl
     $     (iErr,  KLVL,  KU,SU,AU,  KD,AD)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   KLVL
      _INTENT(INOUT,integer)   KD(*)
      _INTENT(INOUT,character) AD(*)*(*)
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
CCC_  - Body
      iErr = 0
      if (iErr.eq.0) call UDSnew(iErr, KD, AD, 0,  'EVOLUTION')
      if (iErr.eq.0) call UDSset(iErr, KD, AD, +1)
c
CCC_   . normal
CCC_    * +2yr [s]
      call UHTEST_CAL
     O    (iErr,
     I     CAL_NORMAL,  'xx',
     I     ' ',  's',  2.0d0, 'yr',
     I     ' ',        0.0d0, ' ', 0.0D0, ' ',
     I     ' ',  100,  KU,SU,AU,  KD,AD)
CCC_    * +1mon [s]
      call UHTEST_CAL
     O    (iErr,
     I     CAL_NORMAL,  'xx',
     I     'YR',  's',  1.d0,  'mon',
     I     '0',         0.0d0, ' ', 0.0D0, ' ',
     I     'yr',  100,  KU,SU,AU,  KD,AD)
CCC_    * +1mon [s] (knot 1yr-1s)
      call UHTEST_CAL
     O    (iErr,
     I     CAL_NORMAL,  'xx',
     I     'YR',  's',  1.d0,  'mon',
     I     '0',         1.0d0, 'yr',  1.0D0, 's',
     I     'yr',  100,  KU,SU,AU,  KD,AD)
CCC_    * +1mon [s] (knot 2hr-1ds)
      call UHTEST_CAL
     O    (iErr,
     I     CAL_NORMAL,  'xx',
     I     '0',   'ds', 1234.d0, 'ds',
     I     '0',         2.0d0,   'hr',  1.0D0, 'ds',
     I     'hr', 100,  KU,SU,AU,  KD,AD)
CCC_   . gregorian
CCC_    * +5mon [s]
      call UHTEST_CAL
     O    (iErr,
     I     CAL_JGREGO,  'ww',
     I     ' ',  's',   5.0d0, 'MON',
     I     ' ',         0.0d0, ' ', 0.0D0, ' ',
     I     ' ',  100,   KU,SU,AU,  KD,AD)
CCC_    * +5mon [day]
      call UHTEST_CAL
     O    (iErr,
     I     CAL_JGREGO,  'ww',
     I     ' ',  'day', 5.0d0, 'MON',
     I     ' ',         0.0d0, ' ', 0.0D0, ' ',
     I     ' ',  100,   KU,SU,AU,  KD,AD)
CCC_    * +5mon [day] knot 1yr-1s
      call UHTEST_CAL
     O    (iErr,
     I     CAL_JGREGO,  'ww',
     I     ' ',  'day', 5.0d0, 'MON',
     I     ' ',         5.0d0, 'YR', 1.0D0, 's',
     I     ' ',  100,   KU,SU,AU,  KD,AD)
CCC_    * +5mon [day] knot 1yr#c-1s
      call UHTEST_CAL
     O    (iErr,
     I     CAL_JGREGO,  'wi',
     I     ' ',  'day', 5.0d0, 'MON',
     I     ' ',         5.0d0, 'YR', 1.0D0, 's',
     I     ' ',  100,   KU,SU,AU,  KD,AD)
CCC_    * +1.75mon [s]
      call UHTEST_CAL
     O    (iErr,
     I     CAL_JGREGO,  'ww',
     I     'YR', 'day', 1.75d0, 'MON',
     I     ' ',         0.0d0, ' ', 0.0D0, ' ',
     I     ' ',  100,   KU,SU,AU,  KD,AD)
CCC_    * -1.75mon [s]
      call UHTEST_CAL
     O    (iErr,
     I     CAL_JGREGO,  'ww',
     I     '1987', 'day', -1.75d0, 'MON',
     I     ' ',         0.0d0, ' ', 0.0D0, ' ',
     I     ' ',  100,   KU,SU,AU,  KD,AD)
CCC_    * +1.75mon [s]
      call UHTEST_CAL
     O    (iErr,
     I     CAL_JGREGO,  'iw',
     I     'YR', 'day', 1.75d0, 'MON',
     I     ' ',         0.0d0, ' ', 0.0D0, ' ',
     I     ' ',  100,   KU,SU,AU,  KD,AD)
CCC_   . Gregorian gap
      call UHTEST_GGAP (iErr, CAL_JGREGO, 'iw', KU,SU,AU, KD,AD)
      call UHTEST_GGAP (iErr, CAL_JGREGO, 'ww', KU,SU,AU, KD,AD)
      call UHTEST_GGAP (iErr, CAL_PGREGO, 'iw', KU,SU,AU, KD,AD)
      call UHTEST_GGAP (iErr, CAL_PGREGO, 'ww', KU,SU,AU, KD,AD)
CCC_   . days in a year
      call UHTEST_CAL
     O    (iErr,
     I     CAL_JGREGO,  'iw',
     I     '-01000101', 'day', 1.d0, 'YR',
     I     ' ',           0.0d0, ' ', 0.0D0, ' ',
     I     'DAY',  2200,   KU,SU,AU,  KD,AD)
      call UHTEST_CAL
     O    (iErr,
     I     CAL_JGREGO,  'ww',
     I     '-01000101', 'day', 1.d0, 'YR',
     I     ' ',           0.0d0, ' ', 0.0D0, ' ',
     I     'DAY',  2200,   KU,SU,AU,  KD,AD)
c
      call UHTEST_CAL
     O    (iErr,
     I     CAL_PGREGO,  'iw',
     I     '-02000101', 'day', 1.d0, 'YR',
     I     ' ',           0.0d0, ' ', 0.0D0, ' ',
     I     'DAY',  2200,   KU,SU,AU,  KD,AD)
      call UHTEST_CAL
     O    (iErr,
     I     CAL_PGREGO,  'ww',
     I     '-02000101', 'day', 1.d0, 'YR',
     I     ' ',           0.0d0, ' ', 0.0D0, ' ',
     I     'DAY',  2200,   KU,SU,AU,  KD,AD)
c
      if (iErr.eq.0) call UDSset(iErr, KD, AD, -1)
      RETURN
      END
CCC_ & UHTEST_ctrl
      subroutine UHTEST_ctrl (iErr, KLVL,  KD,AD)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   KLVL
      _INTENT(INOUT,integer)   KD(*)
      _INTENT(INOUT,character) AD(*)*(*)
c
      integer    LKU, LSU, LAU
      parameter (LKU = 1024)
      parameter (LSU = 1024)
      parameter (LAU = 256)
      integer    KU(LKU)
      character  AU(LAU)*(OPT_UNIT_LEN)
      _REALSTD   SU(LSU)
      integer    MUI, MDI, MCI, KTYPE
      integer    iplog
CCC_  - Body
      iErr = 0
      call UDSquo(iplog, KD)
c
      if (iErr.eq.0) call UDSnew(iErr, KD, AD, 0, 'INITIALIZATION')
CCC_   . initialization
      MUI   = 0
      MDI   = 0
      MCI   = 0
      KTYPE = 0
c
      if (iErr.eq.0) then
         call UHinit
     O       (iErr,
     O        KU,  SU,  AU,
     I        LKU, LSU, LAU,
     I        MUI, MDI, MCI, KTYPE,  iplog)
         if (iErr.eq.0) call UXSdmi (iErr, 'ds', -1, 's', KU,SU,AU)
      endif
CCC_   . Julian day
      if (iErr.eq.0) then
         call UHTEST_JD_ctrl(iErr,  KLVL, KU,SU,AU, KD,AD)
      endif
CCC_  - Gregorian calendar
      if (iErr.eq.0) then
         call UHTEST_GREGO_ctrl(iErr,  KLVL, KU,SU,AU, KD,AD)
      endif
CCC_  - Time evolution
      if (iErr.eq.0) then
         call UHTEST_EVOL_ctrl(iErr,  KLVL, KU,SU,AU, KD,AD)
      endif
CCC_   . report
      if (iErr.eq.0) call UDSnew(iErr, KD, AD, 0, 'UNIT REPORT')
      if (iErr.eq.0) call UXSrep(iErr, KU, SU, AU)
      RETURN
      END
CCC_ + end subroutines
#endif /* TEST_UXHCAL || WITH_TEST_UXHCAL */
CCC_ @ UHTEST  ## Test program of Calendar
#ifdef TEST_UXHCAL
CCC_  - Test suites
CC::   SOURCES uxunit.F ufortw.F
      program UHTEST
CCC_  - Declaration
      implicit none
      integer iErr
      integer iplog
CCC_   . debug section
      integer    LDK, LDA
      parameter (LDK = 32, LDA = 24)
      integer    KD(LDK)
      character  AD(LDA)*(128)
c
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
#include "orevan.h" /* 0 */
CCC_  - Body
#define _ANNOUNCE UXHCAL
#define _LEXT     9999
#include "orevan.h" /* 1 */
c
      iErr  = 0
      iplog = -1
c
      call UDSbnm('UXHCAL TESTS', '#', 0, iplog)
      call UDSini(iErr, KD, AD, LDK, LDA, iplog)
      call UHTEST_ctrl(iErr, 0,  KD, AD)
      call UDSbnm('UXHCAL TESTS FINE', '#', 0, iplog)
c
      stop
      END
CCC_ + end
#endif /* TEST_UXHCAL */
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
