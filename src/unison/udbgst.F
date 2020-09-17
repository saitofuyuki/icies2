C unison/udbgst.F --- IcIES/Unison/debug/statistics/embedded profiler
C Maintainer:  SAITO Fuyuki
C Created: Apr 15 2013
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2020/09/17 08:49:36 fuyuki udbgst.F>'
#define _FNAME 'unison/udbgst.F'
#define _REV   'Snoopy0.97'
CCC_! MANIFESTO
C
C Copyright (C) 2013--2020
C           Japan Agency for Marine-Earth Science and Technology,
C           Ayako ABE-OUCHI
C
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
CCC_* Macros
#include "ofdlct.h" /* fortran dialect */
#include "ologfm.h" /* logging */
CCC_ + Options
CCC_  - clock
#ifndef   OPT_CLOCK_ID_LIMIT  /* maximum modules to clock */
#  define OPT_CLOCK_ID_LIMIT 256
#endif
#ifndef   OPT_CLOCK_STACK_LIMIT
#  define OPT_CLOCK_STACK_LIMIT 128
#endif
CCC_  - section
#ifndef   OPT_TEST_SECTION_LEVELS /* maximum section levels */
#  define OPT_TEST_SECTION_LEVELS 16
#endif
#ifndef   OPT_TEST_SECTION_LEN    /* maximum length of section titles */
#  define OPT_TEST_SECTION_LEN    64
#endif
#ifndef   OPT_TEST_SECTION_DESCR /* maximum length of section description */
#  define OPT_TEST_SECTION_DESCR 128
#endif
#ifndef   OPT_TEST_SECTION_BULLET
#  define OPT_TEST_SECTION_BULLET '#'
#endif
#ifndef   OPT_TEST_SECTION_MID
#  define OPT_TEST_SECTION_MID    '%'
#endif
#ifndef   OPT_TEST_SECTION_BOTTOM
#  define OPT_TEST_SECTION_BOTTOM ':'
#endif
CCC_* [UDC] embedded clock/statistics
CCC_ & UDCLKI  ## clock-in
      subroutine UDCLKI (ID)
      implicit none
      _INTENT(IN,integer) ID
      call UDCbgn (ID)
      RETURN
      END
CCC_ & UDCLKO  ## clock-out
      subroutine UDCLKO (ID)
      implicit none
      _INTENT(IN,integer) ID
      call UDCend (ID)
      RETURN
      END
CCC_ & UDCLKC  ## clock-core
      subroutine UDCLKC (iErr)
      implicit none
CCC_  - Declaration
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   ID
      _INTENT(IN, integer)   IFP
      _INTENT(IN, character) TAGS(0:*)*(*)
c
      integer    LID, MID
      parameter (LID = OPT_CLOCK_ID_LIMIT)
      parameter (MID = LID + 1)
      integer    NC (0:LID)
      data       NC /MID * 0/
      save       NC
c
      _REALSTD   TC (0:LID),   TS (0:LID)
      data       TC,           TS
     $         / MID*0.0d0,    MID*0.0d0 /
      save       TC,           TS
c
      integer    LRC, MRC
      parameter (LRC = OPT_CLOCK_STACK_LIMIT)
      parameter (MRC = LRC + 1)
      integer    IDSTK (0:LRC)
      save       IDSTK
      _REALSTD   T0STK (0:LRC)
      data       T0STK /MRC*0.0d0/
      save       T0STK
      integer    jst
      data       jst /0/
      save       jst
c
      integer  ji
      _REALSTD T, DT
CCC_  - Body
      iErr = 0
      call ufcput (T)
      ji = 0
      IDSTK (ji) = 0
      T0STK (ji) = T
      NC    (ji) = 1
      RETURN
CCC_  & UDCbgn  ## start clock
      entry UDCbgn (ID)
c
      NC (ID) = NC (ID) + 1
c
      call ufcput (T)
c
      ji = IDSTK (jst)
      DT = (T - T0STK (jst))
      TS (ji) = TS (ji) + DT
c
      jst = jst + 1
      IDSTK (jst) = ID
      T0STK (jst) = T
      RETURN
CCC_  & UDCend  ## stop clock
      entry UDCend (ID)
c
      call ufcput (T)
c
      DT = (T - T0STK (jst))
      TC (ID) = TC (ID) + DT
      TS (ID) = TS (ID) + DT
c
      jst = jst - 1
      ji = IDSTK (jst)
      DT = (T - T0STK (jst))
      TC (ji) = TC (ji) + DT
c
      T0STK (jst) = T
      RETURN
CCC_  & UDCrep  ## report
      entry UDCrep (IFP, TAGS)
c
      call ufcput (T)
      ji  = 0
      jst = 0
      TC (ji) = TC (ji) + T - T0stk (jst)
 101  format ('STATSTICS: ', I5, 1x, I12, 1x, F10.3, 1x, F10.3, 1x, A)
 102  format ('PROPERTY:  ', A5, 1x, A12, 1x, A10,   1x, A10,   1x, A)
 109  format ('CLOCK: ', I8)
      if (COND_N(IFP)) then
         write (IFP, _FORMAT(109)) LID
         write (IFP, _FORMAT(102)) 'ID', 'CALL', 'CUML', 'SELF', 'TAG'
         do ji = 0, LID
            if (NC (ji).gt.0) then
               write (IFP, _FORMAT(101)) ji,
     $              NC (ji), TC (ji), TS (ji), _TRIM(TAGS (ji))
            endif
         enddo
      else if (COND_S(IFP)) then
#        define IFP *
         write (IFP, _FORMAT(109)) LID
         write (IFP, _FORMAT(102)) 'ID', 'CALL', 'CUML', 'SELF', 'TAG'
         do ji = 0, LID
            if (NC (ji).gt.0) then
               write (IFP, _FORMAT(101)) ji,
     $              NC (ji), TC (ji), TS (ji), _TRIM(TAGS (ji))
            endif
         enddo
#        undef  IFP
      endif
      RETURN
      END
CCC_* [UDM] Message
CCC_ & UDMfi1  ## message format/integer 1
      subroutine UDMfi1 (IFP, FMT, IV)
      implicit none
      _INTENT(IN,integer)   IFP
      _INTENT(IN,character) FMT*(*)
      _INTENT(IN,integer)   IV
      if      (COND_N(IFP)) then
         if (FMT.eq.' ' .or. FMT.eq.'*') then
            write (IFP, *) IV
         else
            write (IFP, _FORMAT(FMT)) IV
         endif
      else if (COND_S(IFP)) then
         if (FMT.eq.' ' .or. FMT.eq.'*') then
            write (*,   *) IV
         else
            write (*,   _FORMAT(FMT)) IV
         endif
      endif
      RETURN
      END
CCC_ & UDMfa1  ## message format/string 1
      subroutine UDMfa1 (IFP, FMT, AV)
      implicit none
      _INTENT(IN,integer)   IFP
      _INTENT(IN,character) FMT*(*)
      _INTENT(IN,character) AV*(*)
      if      (COND_N(IFP)) then
         if (FMT.eq.' ' .or. FMT.eq.'*') then
            write (IFP, *) _TRIM(AV)
         else
            write (IFP, _FORMAT(FMT)) _TRIM(AV)
         endif
      else if (COND_S(IFP)) then
         if (FMT.eq.' ' .or. FMT.eq.'*') then
            write (*,   *) _TRIM(AV)
         else
            write (*,   _FORMAT(FMT)) _TRIM(AV)
         endif
      endif
      RETURN
      END
CCC_* [UDA] Array check
CCC_ & UDAtii  ## array check TAG:INT:INT
      subroutine UDAtii
     I    (TAG, IV0, IV1, NV, IFP)
      implicit none
      _INTENT(IN,character) TAG*(*)
      _INTENT(IN,integer)   NV
      _INTENT(IN,integer)   IV0 (*), IV1 (*)
      _INTENT(IN,integer)   IFP
      character SI*(24)
      character S0*(24), S1*(24)
      integer   l
 101  format (A, 1x, A, 1x, A, 1x, A)
      if (COND_N(IFP)) then
         do l = 1, NV
            call USGlni (SI, l)
            call USGlni (S0, IV0 (l))
            call USGlni (S1, IV1 (l))
            write (IFP, _FORMAT(101))
     $           _TRIM(TAG), _TRIM(SI),
     $           _TRIM(S0),  _TRIM(S1)
         enddo
      else if (COND_S(IFP)) then
         do l = 1, NV
            call USGlni (SI, l)
            call USGlni (S0, IV0 (l))
            call USGlni (S1, IV1 (l))
            write (*,  _FORMAT(101))
     $           _TRIM(TAG), _TRIM(SI),
     $           _TRIM(S0),  _TRIM(S1)
         enddo
      endif
      RETURN
      END
CCC_ & UDAtss  ## array check TAG:STD:STD
      subroutine UDAtss
     I    (TAG, SV0, SV1, NV, IFP)
      implicit none
      _INTENT(IN,character) TAG*(*)
      _INTENT(IN,integer)   NV
      _INTENT(IN,_REALSTD)  SV0 (*), SV1 (*)
      _INTENT(IN,integer)   IFP
      character SI*(24)
      integer   l
 101  format (A, 1x, A, 1x, E24.16, 1x, E24.16)
      if (COND_N(IFP)) then
         do l = 1, NV
            call USGlni (SI, l)
            write (IFP, _FORMAT(101))
     $           _TRIM(TAG), _TRIM(SI), SV0 (l), SV1 (l)
         enddo
      else if (COND_S(IFP)) then
         do l = 1, NV
            call USGlni (SI, l)
            write (*,  _FORMAT(101))
     $           _TRIM(TAG), _TRIM(SI), SV0 (l), SV1 (l)
         enddo
      endif
      RETURN
      END
CCC_* [UDS] Utility for sectioning
CCC_ + attribute cluster macros
CCC_  - integer
#define _TYPE(VI)     VI(1)  /* reserved: cluster type */
#define _STAT(VI)     VI(2)  /* reserved: status */
#define _LOGU(VI)     VI(3)  /* output unit number */
#define _MINLEV(VI)   VI(4)  /* root level */
#define _MAXLEV(VI)   VI(5)  /* maximum level */
#define _LEVC(VI)     VI(6)  /* current level */
#define _LEVO(VI)     VI(7)  /* previous level */
#define _LEVWOV(VI)   VI(8)  /* write overlines if less than */

#define _OFF          8
#define _MEMI         2
#define _MEMA         2

#define _ISEC(VI,L)   VI(_POS_ISEC(VI,L))
#define _IDSC(VI,L)   VI(_POS_IDSC(VI,L))
#define _POS_ISEC(VI,L) _OFF+((L)-_MINLEV(VI))*_MEMI+1
#define _POS_IDSC(VI,L) _OFF+((L)-_MINLEV(VI))*_MEMI+2
CCC_  - character
#define _TXT_SEC(VS,VI,L) VS(((L)-_MINLEV(VI))*_MEMA+1)
#define _TXT_DSC(VS,VI,L) VS(((L)-_MINLEV(VI))*_MEMA+2)
CCC_ & UDSini  ## section: initialization
      subroutine UDSini
     $     (iErr, KD, AD, LK, LA,  IFP)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   KD(*)
      _INTENT(OUT,character) AD(*)*(*)
      _INTENT(IN, integer)   LK, LA
      _INTENT(IN, integer)   IFP
      integer m1, m2, lv
c
      iErr = 0
      m1 = (LK - _OFF) / _MEMI
      m2 = LA / _MEMA
      if (m1.lt.2 .or. m2.lt.2) iErr = -1
      if (iErr.eq.0) then
         _TYPE(KD)   = 0
         _STAT(KD)   = 0
         _LOGU(KD)   = IFP
         _MINLEV(KD) = 0
         _MAXLEV(KD) = min(m1,m2) + _MINLEV(KD) - 1
         _LEVC(KD)   = 0
         _LEVO(KD)   = 0
         _LEVWOV(KD) = 2
      endif
      if (iErr.eq.0) then
         do lv = _MINLEV(KD), _MAXLEV(KD)
            _ISEC(KD,lv) = -1
            _IDSC(KD,lv) = -1
            _TXT_SEC(AD,KD,lv) = ' '
            _TXT_DSC(AD,KD,lv) = ' '
         enddo
      endif
c
      RETURN
      END
CCC_ & UDSquo  ## section: query output unit
      subroutine UDSquo (IFP, KD)
      implicit none
      _INTENT(OUT,integer)   IFP
      _INTENT(IN, integer)   KD(*)
      IFP = _LOGU(KD)
      RETURN
      END
CCC_ & UDSnew  ## section: new section (divert immediately)
      subroutine UDSnew (iErr, KD, AD, KLEV, T)
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,integer)   KD(*)
      _INTENT(INOUT,character) AD(*)*(*)
      _INTENT(IN,   integer)   KLEV
      _INTENT(IN,   character) T*(*)
      integer KSKP
CCC_  - Body
      iErr = 0
CCC_   . open new section
      if (iErr.eq.0) call UDSopn(iErr, KD, AD, KLEV, T)
CCC_   . divert
      KSKP = MAX(0, KLEV - 1)
      if (iErr.eq.0) call UDSdiv(iErr, KD, AD, KSKP)
      if (iErr.eq.0) call UDSfwd(iErr, KD, AD, KSKP)
c
      RETURN
      END
CCC_ & UDSopn  ## section: open new section (wait for message)
      subroutine UDSopn (iErr, KD, AD, KLEV, T)
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,integer)   KD(*)
      _INTENT(INOUT,character) AD(*)*(*)
      _INTENT(IN,   integer)   KLEV
      _INTENT(IN,   character) T*(*)
      integer KSKP
      integer KCH
CCC_  - flush previous description
      iErr = 0
      KCH = _LEVC(KD) + KLEV - _LEVO(KD)
      if (KCH.le.0) then
         if (iErr.eq.0) call UDSdiv(iErr, KD, AD, KLEV)
         if (iErr.eq.0) call UDSclr(iErr, KD, AD, KLEV)
      endif
CCC_  - section increment
      if (iErr.eq.0) call UDSinc(iErr, KD, AD, KLEV)
      if (iErr.eq.0) call UDSset(iErr, KD, AD, KLEV)
CCC_  - set title
      KSKP = MAX(0, KLEV - 1)
      if (iErr.eq.0) call UDSclr(iErr, KD, AD, KSKP)
      if (iErr.eq.0) call UDSapp(iErr, KD, AD, 0, T)
c
      RETURN
      END
CCC_ & UDSmai  ## section: output message (separator/integer)
      subroutine UDSmai (iErr, KD, AD, KLEV, KFLG, SEP, IV)
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,integer)   KD(*)
      _INTENT(INOUT,character) AD(*)*(*)
      _INTENT(IN,   integer)   KLEV
      _INTENT(IN,   integer)   KFLG
      _INTENT(IN,   character) SEP*(*)
      _INTENT(IN,   integer)   IV
      character T*(128)
c$$$      T = SEP
c$$$      call USGani(T, IV)
c$$$      call UDSmsg(iErr, KD, AD, KLEV, KFLG, T)
      call USGlni(T, IV)
      call UDSmaa(iErr, KD, AD, KLEV, KFLG, SEP, T)
      RETURN
      END
CCC_ & UDSmas  ## section: output message (separator/real-standard)
      subroutine UDSmas (iErr, KD, AD, KLEV, KFLG, SEP, SV)
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,integer)   KD(*)
      _INTENT(INOUT,character) AD(*)*(*)
      _INTENT(IN,   integer)   KLEV
      _INTENT(IN,   integer)   KFLG
      _INTENT(IN,   character) SEP*(*)
      _INTENT(IN,   _REALSTD)  SV
      character T*(128)
      call USGlfs(T, SV, 'C')
      call UDSmaa(iErr, KD, AD, KLEV, KFLG,   SEP, T)
c$$$      call UDSmsg(iErr, KD, AD, KLEV, KFLG, T)
      RETURN
      END
CCC_ & UDSmaa  ## section: output message (separator/string)
      subroutine UDSmaa (iErr, KD, AD, KLEV, KFLG, SEP, T)
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,integer)   KD(*)
      _INTENT(INOUT,character) AD(*)*(*)
      _INTENT(IN,   integer)   KLEV
      _INTENT(IN,   integer)   KFLG
      _INTENT(IN,   character) SEP*(*)
      _INTENT(IN,   character) T*(*)
      character TT*(256)
      call USCsta(TT, SEP, T)
      call UDSmsg(iErr, KD, AD, KLEV, KFLG, TT)
      RETURN
      END
CCC_ & UDSmsg  ## section: output message
      subroutine UDSmsg (iErr, KD, AD, KLEV, KFLG, T)
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,integer)   KD(*)
      _INTENT(INOUT,character) AD(*)*(*)
      _INTENT(IN,   integer)   KLEV
      _INTENT(IN,   integer)   KFLG
      _INTENT(IN,   character) T*(*)
c
      iErr = 0
      if (iErr.eq.0) call UDSapp(iErr, KD, AD, KLEV, T)
      if (KFLG.eq.0) then
         if (iErr.eq.0) call UDSdiv(iErr, KD, AD, KLEV)
         if (iErr.eq.0) call UDSfwd(iErr, KD, AD, KLEV)
         if (iErr.eq.0) call UDSclr(iErr, KD, AD, KLEV)
      endif
c
      RETURN
      END
CCC_ & UDSfin  ## section: finalize (divert pending outputs)
      subroutine UDSfin (iErr, KD, AD)
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,integer)   KD(*)
      _INTENT(INOUT,character) AD(*)*(*)
      integer KLEV
c
      iErr = 0
      KLEV = - _LEVC(KD)

      if (iErr.eq.0) call UDSdiv(iErr, KD, AD, KLEV)
      if (iErr.eq.0) call UDSclr(iErr, KD, AD, KLEV)
c
      RETURN
      END
CCC_ & UDSstt  ## section/low-level: show current status
      subroutine UDSstt
     $     (iErr, KD, AD, IFP)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   KD(*)
      _INTENT(IN, character) AD(*)*(*)
      _INTENT(IN, integer)   IFP
      integer jfp
      integer lv
c
      iErr = 0
      jfp  = IFP
      if (jfp.lt.IOUNIT_MIN) jfp = _LOGU(KD)
 101  format ('UDSSTT ', I4, ' -- ', I4, ' / ', I4, 1x, I4)
 102  format (I4, ':: ', I4, 1x, A, T30, ':', I4, 1x, A)
      if      (COND_N(jfp)) then
         write (jfp, 101)
     $        _MINLEV(KD), _MAXLEV(KD),
     $        _LEVC(KD),   _LEVO(KD)
         do lv = _MINLEV(KD), _MAXLEV(KD)
            write (jfp, 102) lv,
     $           _ISEC(KD,lv), _TRIM(_TXT_SEC(AD,KD,lv)),
     $           _IDSC(KD,lv), _TRIM(_TXT_DSC(AD,KD,lv))
         enddo
      else if (COND_S(jfp)) then
         write (*,   101)
     $        _MINLEV(KD), _MAXLEV(KD),
     $        _LEVC(KD),   _LEVO(KD)
         do lv = _MINLEV(KD), _MAXLEV(KD)
            write (*,   102) lv,
     $           _ISEC(KD,lv), _TRIM(_TXT_SEC(AD,KD,lv)),
     $           _IDSC(KD,lv), _TRIM(_TXT_DSC(AD,KD,lv))
         enddo
      endif
c
      RETURN
      END
CCC_ & UDSinc  ## section/low-level: increment section
      subroutine UDSinc (iErr, KD, AD, KLEV)
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,integer)   KD(*)
      _INTENT(IN,   character) AD(*)*(*)
      _INTENT(IN,   integer)   KLEV
      integer levN
      integer lv
c
      iErr = 0
      levN = _LEVC(KD) + KLEV
      if (levN.lt. _MINLEV(KD) .or. levN.gt. _MAXLEV(KD)) then
         iErr = -1
         levN = MAX(_MINLEV(KD), MIN(_MAXLEV(KD), levN))
      else
         iErr = 0
      endif
      do lv = _LEVC(KD) + 1, levN - 1
         _ISEC(KD,lv) = 0
         _IDSC(KD,lv) = 0
      enddo
      _ISEC(KD,levN) = _ISEC(KD,levN) + 1
      _IDSC(KD,levN) = 0
      do lv = levN + 1, _MAXLEV(KD)
         _ISEC(KD,lv) = -1
      enddo
c
      _LEVO(KD) = levN
c
      RETURN
      END
CCC_ & UDSset  ## section/low-level: change level
      subroutine UDSset (iErr, KD, AD, KLEV)
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,integer)   KD(*)
      _INTENT(IN,   character) AD(*)*(*)
      _INTENT(IN,   integer)   KLEV
      integer levN
c
      iErr = 0
      levN = _LEVC(KD) + KLEV
      levN = MAX(_MINLEV(KD), MIN(_MAXLEV(KD), levN))
      _LEVC(KD) = levN
      RETURN
      END
CCC_ & UDSapp  ## section/low-level: append text
      subroutine UDSapp (iErr, KD, AD, KLEV, T)
      implicit none
      _INTENT(OUT,   integer)   iErr
      _INTENT(IN,    integer)   KD(*)
      _INTENT(INOUT, character) AD(*)*(*)
      _INTENT(IN,    integer)   KLEV
      _INTENT(IN,    character) T*(*)
      integer levN
c
      iErr = 0
      levN = _LEVC(KD) + KLEV
      levN = MAX(_MINLEV(KD), MIN(_MAXLEV(KD), levN))
c
      if (_IDSC(KD,levN).eq.0) then
         call USJntz(_TXT_SEC(AD,KD,levN), T)
      else
         call USJntz(_TXT_DSC(AD,KD,levN), T)
      endif
c
      RETURN
      END
CCC_ & UDSclr  ## section/low-level: clear
      subroutine UDSclr (iErr, KD, AD, KLEV)
      implicit none
      _INTENT(OUT,   integer)   iErr
      _INTENT(IN,    integer)   KD(*)
      _INTENT(INOUT, character) AD(*)*(*)
      _INTENT(IN,    integer)   KLEV
      integer lvi, lve, lvs, l
c
      iErr = 0
      call UDSrng(lvi, lve, lvs, KD, KLEV)
      do l = MIN(lvi,lve), MAX(lvi,lve)
         if (_IDSC(KD,l).eq.0) then
            _TXT_SEC(AD,KD,l) = ' '
         else
            _TXT_DSC(AD,KD,l) = ' '
         endif
      enddo
c
      RETURN
      END
CCC_ & UDSdiv  ## section/low-level: divert
      subroutine UDSdiv (iErr, KD, AD, KLEV)
CCC_  - Description
CC     if KLEV positive   divert -KLEV,-KLEV+1...0
CC     if KLEV negative   divert 0,-1,..,KLEV
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   KD(*)
      _INTENT(IN, character) AD(*)*(*)
      _INTENT(IN, integer)   KLEV
c
      character  SECCH*(*)
      parameter (SECCH = '#*=-^"+~:._')
C                         0123456789012345
      integer   js
      integer   lvi, lve, lvs, l
      character T*(128)
      integer   jfp
CCC_  - Body
      iErr = 0
      jfp  = _LOGU(KD)
c
      call UDSrng(lvi, lve, lvs, KD, KLEV)
c
      do l = lvi, lve, lvs
         js  = l + 1 - _MINLEV(KD)
         call UDSnms(T, KD, l, '.')
CCC_   . title if 0
         if (_IDSC(KD,l).eq.0) then
            if (_TXT_SEC(AD,KD,l).ne.' ') then
               call USJsta(T, ' ', _TXT_SEC(AD,KD,l))
            endif
            call UDSbns(T, OPT_TEST_SECTION_BULLET, js, _LOGU(KD))
CCC_   . various description if positive
         else if (_IDSC(KD,l).gt.0) then
            call USGpni(T, _IDSC(KD,l), ' [', ']')
            if (_TXT_DSC(AD,KD,l).ne.' ') then
               call USJsta(T, ' ', _TXT_DSC(AD,KD,l))
            endif
            call UDSbns(T, OPT_TEST_SECTION_BOTTOM, js, _LOGU(KD))
CCC_   . skip if negative
         endif
      enddo
c
      RETURN
      END
CCC_ & UDSfwd  ## section/low-level: forward description index
      subroutine UDSfwd (iErr, KD, AD, KLEV)
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,integer)   KD(*)
      _INTENT(IN,   character) AD(*)*(*)
      _INTENT(IN,   integer)   KLEV
      integer lvi, lve, lvs, l
c
      iErr = 0
      call UDSrng(lvi, lve, lvs, KD, KLEV)
      do l = MIN(lvi,lve), MAX(lvi,lve)
         _IDSC(KD,l) = _IDSC(KD,l) + 1
      enddo
c
      RETURN
      END
CCC_ & UDSrng  ## section/low-level: section ranges
      subroutine UDSrng(LI, LE, LS, KD, KLEV)
      implicit none
      _INTENT(OUT,integer)   LI, LE, LS
      _INTENT(IN, integer)   KD(*)
      _INTENT(IN, integer)   KLEV
      integer KCH
c
      KCH = _LEVC(KD) + KLEV - _LEVO(KD)
      if (KCH.ge.0) then
         LI = MAX(_MINLEV(KD),_LEVC(KD) - KCH)
         LE = _LEVC(KD)
         LS = +1
      else
         LI = _LEVO(KD)
         LE = MAX(_MINLEV(KD),_LEVO(KD) + KCH)
         LS = -1
      endif
c
      RETURN
      END
CCC_ & UDSnms  ## section/low-level: section number string
      subroutine UDSnms(TXT, KD, LVL, SEP)
      implicit none
      _INTENT(OUT,character) TXT*(*)
      _INTENT(IN, integer)   KD(*)
      _INTENT(IN, integer)   LVL
      _INTENT(IN, character) SEP*(*)
      character TSEP*(8)
      integer   lv
c
      TSEP = SEP
      if (TSEP.eq.' ') TSEP = '.'
      TXT = ' '
      do lv = _MINLEV(KD), LVL
         call USGsni(TXT, _ISEC(KD,lv), TSEP)
      enddo
      call USJntz(TXT, TSEP)
c
      RETURN
      END
CCC_ & UDSbns  ## simple banner
      subroutine UDSbns
     I    (CMSG, BCH, LVS, IFP)
c
      implicit none
      _INTENT(IN,integer)   IFP
      _INTENT(IN,character) BCH*(*)
      _INTENT(IN,integer)   LVS
      _INTENT(IN,character) CMSG*(*)
      integer   lmsg
#if HAVE_F77_REPEAT == 0
      character B*(32)
#endif
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
c
      lmsg = len_trim (CMSG)
 102  format (A, 1x, A)
#if HAVE_F77_REPEAT
      if      (COND_N(IFP)) then
         write (IFP, _FORMAT(102))
     $        REPEAT(BCH, LVS), CMSG(1:lmsg)
      else if (COND_S(IFP)) then
         write (*,   _FORMAT(102))
     $        REPEAT(BCH, LVS), CMSG(1:lmsg)
      endif
#else /* not HAVE_F77_REPEAT */
      call UFFrpt (B, BCH, LVS)
      if      (COND_N(IFP)) then
         write (IFP, _FORMAT(102))
     $        B(1:LVS), CMSG(1:lmsg)
      else if (COND_S(IFP)) then
         write (*,   _FORMAT(102))
     $        B(1:LVS), CMSG(1:lmsg)
      endif
#endif /* not HAVE_F77_REPEAT */
      RETURN
      END
CCC_ & UDSbnm  ## multiline banner
      subroutine UDSbnm
     I    (CMSG, BCH, KFLG, IFP)
c
      implicit none
      _INTENT(IN,integer)   IFP
      _INTENT(IN,character) BCH*(*)
      _INTENT(IN,integer)   KFLG
      _INTENT(IN,character) CMSG*(*)
      integer   lmsg, lbar
#if HAVE_F77_REPEAT == 0
      character B*(1024)
#endif
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
c
      lmsg = len_trim (CMSG)
      lbar = lmsg
      if (KFLG.eq.0) lbar = lbar + 2
 101  format (A)
 102  format (1x, A)
 103  format (A)
#if HAVE_F77_REPEAT
      if      (COND_N(IFP)) then
         if (KFLG.le.0)
     $        write (IFP, _FORMAT(101)) REPEAT (BCH, lbar)
         if (KFLG.eq.0) then
            write (IFP, _FORMAT(102)) CMSG(1:lmsg)
         else
            write (IFP, _FORMAT(103)) CMSG(1:lmsg)
         endif
         if (KFLG.ge.0)
     $        write (IFP, _FORMAT(101)) REPEAT (BCH, lbar)
      else if (COND_S(IFP)) then
         if (KFLG.le.0)
     $        write (*,   _FORMAT(101)) REPEAT (BCH, lbar)
         if (KFLG.eq.0) then
            write (*,  _FORMAT(102)) CMSG(1:lmsg)
         else
            write (*,  _FORMAT(103)) CMSG(1:lmsg)
         endif
         if (KFLG.ge.0)
     $        write (*,   _FORMAT(101)) REPEAT (BCH, lbar)
      endif
#else /* not HAVE_F77_REPEAT */
      call UFFrpt (B, BCH, lbar)
      if      (COND_N(IFP)) then
         if (KFLG.le.0)
     $        write (IFP, _FORMAT(101)) B (1:lbar)
         if (KFLG.eq.0) then
            write (IFP, _FORMAT(102)) CMSG(1:lmsg)
         else
            write (IFP, _FORMAT(103)) CMSG(1:lmsg)
         endif
         if (KFLG.ge.0)
     $        write (IFP, _FORMAT(101)) B (1:lbar)
      else if (COND_S(IFP)) then
         if (KFLG.le.0)
     $        write (*,   _FORMAT(101)) B (1:lbar)
         if (KFLG.eq.0) then
            write (*,   _FORMAT(102)) CMSG(1:lmsg)
         else
            write (*,   _FORMAT(103)) CMSG(1:lmsg)
         endif
         if (KFLG.ge.0)
     $        write (*,   _FORMAT(101)) B (1:lbar)
      endif
#endif /* not HAVE_F77_REPEAT */
      RETURN
      END
CCC_* [UDT] Utility for test
CCC_ & UDTbni  ## (obsolete) Test banner (with index, increment at return)
      subroutine UDTbni
     M    (ITEST,
     I     CMSG, CMDL, IFP)
      implicit none
      _INTENT(INOUT,integer)   ITEST
      _INTENT(IN,   character) CMDL*(*)
      _INTENT(IN,   character) CMSG*(*)
      _INTENT(IN,   integer)   IFP
      call UDTbnj (ITEST, CMSG, CMDL, IFP)
      ITEST = ITEST + 1
      RETURN
      END
CCC_ & UDTbnj  ## (obsolete) Test banner (with index constant)
      subroutine UDTbnj
     I    (ITEST,
     I     CMSG, CMDL, IFP)
      implicit none
      _INTENT(IN,integer)   ITEST
      _INTENT(IN,character) CMDL*(*)
      _INTENT(IN,character) CMSG*(*)
      _INTENT(IN,integer)   IFP
      character BF*(1024)
 101  format (A, I3.3, 1x, A)
      if (CMDL.eq.' ') then
         write (BF, 101)
     $        '@TEST', ITEST, _TRIM(CMSG)
      else
         write (BF, 101)
     $        _TRIM(CMDL), ITEST, _TRIM(CMSG)
      endif
      call UDTbnr (BF, IFP)
      RETURN
      END
CCC_ & UDTbna  ## (obsolete) Test banner (with string)
      subroutine UDTbna
     I    (CMSG, CMDL, IFP)
      implicit none
      _INTENT(IN,character) CMDL*(*)
      _INTENT(IN,character) CMSG*(*)
      _INTENT(IN,integer)   IFP
      character BF*(1024)
 101  format (A, 1x, A)
      if (CMDL.eq.' ') then
         write (BF, 101)
     $        '@TEST', _TRIM(CMSG)
      else
         write (BF, 101)
     $        _TRIM(CMDL), _TRIM(CMSG)
      endif
      call UDTbnr (BF, IFP)
      RETURN
      END
CCC_ & UDTbnr  ## (obsolete) Test banner (simple)
      subroutine UDTbnr
     I    (CMSG, IFP)
      implicit none
      _INTENT(IN,integer)   IFP
      _INTENT(IN,character) CMSG*(*)
      integer   lmsg, lbar
#ifndef    BARCH       /* character for banner (len=1) */
#   define BARCH '-'
#endif
#if HAVE_F77_REPEAT == 0
      character B*(1024)
#endif
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
      lmsg = len_trim (CMSG)
      lbar = lmsg + 2
 101  format (A)
 102  format (1x, A)
#if HAVE_F77_REPEAT
      if      (COND_N(IFP)) then
         write (IFP, _FORMAT(101)) REPEAT (BARCH, lbar)
         write (IFP, _FORMAT(102)) CMSG(1:lmsg)
         write (IFP, _FORMAT(101)) REPEAT (BARCH, lbar)
      else if (COND_S(IFP)) then
         write (*,   _FORMAT(101)) REPEAT (BARCH, lbar)
         write (*,   _FORMAT(102)) CMSG(1:lmsg)
         write (*,   _FORMAT(101)) REPEAT (BARCH, lbar)
      endif
#else /* not HAVE_F77_REPEAT */
      call UFFrpt (B, BARCH, lbar)
      if      (COND_N(IFP)) then
         write (IFP, _FORMAT(101)) B (1:lbar)
         write (IFP, _FORMAT(102)) CMSG(1:lmsg)
         write (IFP, _FORMAT(101)) B (1:lbar)
      else if (COND_S(IFP)) then
         write (*,   _FORMAT(101)) B (1:lbar)
         write (*,   _FORMAT(102)) CMSG(1:lmsg)
         write (*,   _FORMAT(101)) B (1:lbar)
      endif
#endif /* not HAVE_F77_REPEAT */
      RETURN
      END
CCC_ & UDTbnc  ## (obsolete) Test banner core
      subroutine UDTbnc
     I    (CMSG, BCH, KFLG, IFP)
      implicit none
      _INTENT(IN,integer)   IFP
      _INTENT(IN,character) BCH*(*)
      _INTENT(IN,integer)   KFLG
      _INTENT(IN,character) CMSG*(*)
      integer   lmsg, lbar
#if HAVE_F77_REPEAT == 0
      character B*(1024)
#endif
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
      lmsg = len_trim (CMSG)
      lbar = lmsg
      if (KFLG.eq.0) lbar = lbar + 2
 101  format (A)
 102  format (1x, A)
 103  format (A)
#if HAVE_F77_REPEAT
      if      (COND_N(IFP)) then
         if (KFLG.le.0)
     $        write (IFP, _FORMAT(101)) REPEAT (BCH, lbar)
         if (KFLG.eq.0) then
            write (IFP, _FORMAT(102)) CMSG(1:lmsg)
         else
            write (IFP, _FORMAT(103)) CMSG(1:lmsg)
         endif
         if (KFLG.ge.0)
     $        write (IFP, _FORMAT(101)) REPEAT (BCH, lbar)
      else if (COND_S(IFP)) then
         if (KFLG.le.0)
     $        write (*,   _FORMAT(101)) REPEAT (BCH, lbar)
         if (KFLG.eq.0) then
            write (*,  _FORMAT(102)) CMSG(1:lmsg)
         else
            write (*,  _FORMAT(103)) CMSG(1:lmsg)
         endif
         if (KFLG.ge.0)
     $        write (*,   _FORMAT(101)) REPEAT (BCH, lbar)
      endif
#else /* not HAVE_F77_REPEAT */
      call UFFrpt (B, BCH, lbar)
      if      (COND_N(IFP)) then
         if (KFLG.le.0)
     $        write (IFP, _FORMAT(101)) B (1:lbar)
         if (KFLG.eq.0) then
            write (IFP, _FORMAT(102)) CMSG(1:lmsg)
         else
            write (IFP, _FORMAT(103)) CMSG(1:lmsg)
         endif
         if (KFLG.ge.0)
     $        write (IFP, _FORMAT(101)) B (1:lbar)
      else if (COND_S(IFP)) then
         if (KFLG.le.0)
     $        write (*,   _FORMAT(101)) B (1:lbar)
         if (KFLG.eq.0) then
            write (*,   _FORMAT(102)) CMSG(1:lmsg)
         else
            write (*,   _FORMAT(103)) CMSG(1:lmsg)
         endif
         if (KFLG.ge.0)
     $        write (*,   _FORMAT(101)) B (1:lbar)
      endif
#endif /* not HAVE_F77_REPEAT */
      RETURN
      END
CCC_ & UDTech  ## Test error check
      subroutine UDTech
     M    (iErr,
     I     iXerr, CMSG, IFP)
      implicit none
      _INTENT(INOUT,integer)   iErr
      _INTENT(IN,   integer)   iXerr
      _INTENT(IN,   character) CMSG*(*)
      _INTENT(IN,   integer)   IFP
      character  TE*24, TXE*24
      character  PFX*(*)
      parameter (PFX = '%% ')
c
      call USGlni(TE,  iErr)
 101  format (A, A, ':', A, '... SUCCESS')
 102  format (A, A, ':', A, '... FAILURE (', A, ')')
      if (iErr.eq.iXerr) then
         if      (COND_N(IFP)) then
            write (IFP, 101) PFX, CMSG, _TRIM(TE)
         else if (COND_S(IFP)) then
            write (*,   101) PFX, CMSG, _TRIM(TE)
         endif
         iErr = 0
      else
         call USGlni(TXE, iXErr)
         if      (COND_N(IFP)) then
            write (IFP, 102) PFX, CMSG, _TRIM(TE), _TRIM(TXE)
         else if (COND_S(IFP)) then
            write (*,   102) PFX, CMSG, _TRIM(TE), _TRIM(TXE)
         endif
         iErr = -1
      endif
      RETURN
      END
CCC_ & UDTich  ## Test number check (integer)
      subroutine UDTich
     O    (iErr,
     I     KCH,  KXP, CMSG, IFP)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   KCH, KXP
      _INTENT(IN, character) CMSG*(*)
      _INTENT(IN, integer)   IFP
      character  TCH*32, TXP*32
      character  PFX*(*)
      parameter (PFX = '%% ')
c
      call USGlni(TCH,  KCH)
 101  format (A, A, ':', A, '... SUCCESS')
 102  format (A, A, ':', A, '... FAILURE (', A, ')')
      if (KCH.eq.KXP) then
         if      (COND_N(IFP)) then
            write (IFP, 101) PFX, CMSG, _TRIM(TCH)
         else if (COND_S(IFP)) then
            write (*,   101) PFX, CMSG, _TRIM(TCH)
         endif
         iErr = 0
      else
         call USGlni(TXP,  KXP)
         if      (COND_N(IFP)) then
            write (IFP, 102) PFX, CMSG, _TRIM(TCH), _TRIM(TXP)
         else if (COND_S(IFP)) then
            write (*,   102) PFX, CMSG, _TRIM(TCH), _TRIM(TXP)
         endif
         iErr = -1
      endif
      RETURN
      END
CCC_ & UDTsch  ## Test number check (real standard)
      subroutine UDTsch
     O    (iErr,
     I     VCH,  VXP, CMSG, IFP)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, _REALSTD)  VCH, VXP
      _INTENT(IN, character) CMSG*(*)
      _INTENT(IN, integer)   IFP
      character  TCH*32, TXP*32
      character  PFX*(*)
      parameter (PFX = '%% ')
c
      call USGlfs(TCH,  VCH, 'CI')
 101  format (A, A, ':', A, '... SUCCESS')
 102  format (A, A, ':', A, '... FAILURE (', A, ')')
      if (VCH.eq.VXP) then
         if      (COND_N(IFP)) then
            write (IFP, 101) PFX, CMSG, _TRIM(TCH)
         else if (COND_S(IFP)) then
            write (*,   101) PFX, CMSG, _TRIM(TCH)
         endif
         iErr = 0
      else
         call USGlfs(TXP,  VXP, 'CI')
         if      (COND_N(IFP)) then
            write (IFP, 102) PFX, CMSG, _TRIM(TCH), _TRIM(TXP)
         else if (COND_S(IFP)) then
            write (*,   102) PFX, CMSG, _TRIM(TCH), _TRIM(TXP)
         endif
         iErr = -1
      endif
      RETURN
      END
CCC_& UDBGST  ## Unison/Debug announcement
      subroutine UDBGST (STRA, STRB, IOP)
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
         STRA = 'OPT_CLOCK_STACK_LIMIT'
         write (STRB, *) OPT_CLOCK_STACK_LIMIT
      else if (IOP.eq.4) then
         STRA = 'OPT_CLOCK_ID_LIMIT'
         write (STRB, *) OPT_CLOCK_ID_LIMIT
      else
         STRA = ' '
         STRB = ' '
      endif
      RETURN
      END
CCC_* Test
#ifndef   TEST_UDBGST
#  define TEST_UDBGST 0
#endif
#ifndef   WITH_TEST_UDBGST
#  define WITH_TEST_UDBGST 0
#endif
CCC_ + begin
#if       TEST_UDBGST || WITH_TEST_UDBGST
CCC_ & UDTEST_SECTION_00  ## test section (low-level subroutine)
      subroutine UDTEST_SECTION_00 (iErr, KLVL, IFP)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(IN, integer) KLVL
      _INTENT(IN, integer) IFP
c
      integer    LK, LA
      parameter (LK = 32, LA = 32)
      integer    KD(LK)
      character  AD(LA)*(128)
      integer    JPDBG
CCC_  - Body
      iErr = 0
      JPDBG = -2
c
      call UDSbnm ('SECTION[00]', '#', 0, IFP)
c
      call UDSini (iErr, KD, AD, LK, LA, IFP)
CCC_   . 0.
      if (iErr.eq.0) call UDSdiv(iErr, KD, AD, 0)
      if (iErr.eq.0) call UDSclr(iErr, KD, AD, 0)
c
      if (iErr.eq.0) call UDSinc(iErr, KD, AD, 0)
c
      if (iErr.eq.0) call UDSset(iErr, KD, AD, 0)
      if (iErr.eq.0) call UDSclr(iErr, KD, AD, 0)
      if (iErr.eq.0) call UDSapp(iErr, KD, AD, 0, 'SECTION:0')
      if (iErr.eq.0) call UDSdiv(iErr, KD, AD, 0)
      if (iErr.eq.0) call UDSfwd(iErr, KD, AD, 0)
c
      if (iErr.eq.0) call UDSapp(iErr, KD, AD, 0, 'msg:0')
CCC_   . 0.0.
      if (iErr.eq.0) call UDSinc(iErr, KD, AD, +1)
c
      if (iErr.eq.0) call UDSset(iErr, KD, AD, +1)
      if (iErr.eq.0) call UDSclr(iErr, KD, AD, 0)
      if (iErr.eq.0) call UDSapp(iErr, KD, AD, 0, 'SECTION:00')
      if (iErr.eq.0) call UDSdiv(iErr, KD, AD, 0)
      if (iErr.eq.0) call UDSfwd(iErr, KD, AD, 0)
c
      if (iErr.eq.0) call UDSapp(iErr, KD, AD, -1, 'msg:0b')
CCC_   . 0.1.
      if (iErr.eq.0) call UDSdiv(iErr, KD, AD, 0)
      if (iErr.eq.0) call UDSclr(iErr, KD, AD, 0)
c
      if (iErr.eq.0) call UDSinc(iErr, KD, AD, 0)
c
      if (iErr.eq.0) call UDSset(iErr, KD, AD, 0)
      if (iErr.eq.0) call UDSclr(iErr, KD, AD, 0)
      if (iErr.eq.0) call UDSapp(iErr, KD, AD, 0, 'SECTION:01')
      if (iErr.eq.0) call UDSdiv(iErr, KD, AD, 0)
      if (iErr.eq.0) call UDSfwd(iErr, KD, AD, 0)
CCC_    * message
      if (iErr.eq.0) call UDSapp(iErr, KD, AD, 0, 'msg:01(0)')
      if (iErr.eq.0) call UDSdiv(iErr, KD, AD, 0)
      if (iErr.eq.0) call UDSfwd(iErr, KD, AD, 0)
      if (iErr.eq.0) call UDSclr(iErr, KD, AD, 0)
c
      if (iErr.eq.0) call UDSapp(iErr, KD, AD, 0, 'msg:01(1)')
      if (iErr.eq.0) call UDSdiv(iErr, KD, AD, 0)
      if (iErr.eq.0) call UDSfwd(iErr, KD, AD, 0)
      if (iErr.eq.0) call UDSclr(iErr, KD, AD, 0)
CCC_   . 1.
      if (iErr.eq.0) call UDSdiv(iErr, KD, AD, -1)
      if (iErr.eq.0) call UDSclr(iErr, KD, AD, -1)
c
      if (iErr.eq.0) call UDSset(iErr, KD, AD, -1)
      if (iErr.eq.0) call UDSinc(iErr, KD, AD,  0)
c
      if (iErr.eq.0) call UDSset(iErr, KD, AD,  0)
      if (iErr.eq.0) call UDSclr(iErr, KD, AD, 0)
      if (iErr.eq.0) call UDSapp(iErr, KD, AD, 0, 'SECTION:1')
      if (iErr.eq.0) call UDSdiv(iErr, KD, AD, 0)
      if (iErr.eq.0) call UDSfwd(iErr, KD, AD, 0)
CCC_   . 2.
      if (iErr.eq.0) call UDSdiv(iErr, KD, AD, 0)
      if (iErr.eq.0) call UDSclr(iErr, KD, AD, 0)
c
      if (iErr.eq.0) call UDSinc(iErr, KD, AD, 0)
c
      if (iErr.eq.0) call UDSset(iErr, KD, AD, 0)
      if (iErr.eq.0) call UDSclr(iErr, KD, AD, 0)
      if (iErr.eq.0) call UDSapp(iErr, KD, AD, 0, 'SECTION:2')
      if (iErr.eq.0) call UDSdiv(iErr, KD, AD, 0)
      if (iErr.eq.0) call UDSfwd(iErr, KD, AD, 0)
CCC_   . 3.
      if (iErr.eq.0) call UDSdiv(iErr, KD, AD, 0)
      if (iErr.eq.0) call UDSclr(iErr, KD, AD, 0)
c
      if (iErr.eq.0) call UDSinc(iErr, KD, AD, 0)
c
      if (iErr.eq.0) call UDSset(iErr, KD, AD, 0)
      if (iErr.eq.0) call UDSclr(iErr, KD, AD, 0)
      if (iErr.eq.0) call UDSapp(iErr, KD, AD, 0, 'SECTION:3')
      if (iErr.eq.0) call UDSdiv(iErr, KD, AD, 0)
      if (iErr.eq.0) call UDSfwd(iErr, KD, AD, 0)
CCC_   . 3.0.0.0
      if (iErr.eq.0) call UDSinc(iErr, KD, AD, +3)
c
      if (iErr.eq.0) call UDSset(iErr, KD, AD, +3)
      if (iErr.eq.0) call UDSclr(iErr, KD, AD, +2)
      if (iErr.eq.0) call UDSapp(iErr, KD, AD, 0, 'SECTION:3000')
      if (iErr.eq.0) call UDSdiv(iErr, KD, AD, +2)
      if (iErr.eq.0) call UDSfwd(iErr, KD, AD, +2)
c
      if (iErr.eq.0) call UDSapp(iErr, KD, AD, -1, 'msg:300')
CCC_   . 3.1
      if (iErr.eq.0) call UDSdiv(iErr, KD, AD, -2)
      if (iErr.eq.0) call UDSclr(iErr, KD, AD, -2)
c
      if (iErr.eq.0) call UDSinc(iErr, KD, AD, -2)
c
      if (iErr.eq.0) call UDSset(iErr, KD, AD, -2)
      if (iErr.eq.0) call UDSclr(iErr, KD, AD, 0)
      if (iErr.eq.0) call UDSapp(iErr, KD, AD, 0, 'SECTION:31')
      if (iErr.eq.0) call UDSdiv(iErr, KD, AD, 0)
      if (iErr.eq.0) call UDSfwd(iErr, KD, AD, 0)
CCC_   . 3.1.0
      if (iErr.eq.0) call UDSinc(iErr, KD, AD, +1)
c
      if (iErr.eq.0) call UDSset(iErr, KD, AD, +1)
      if (iErr.eq.0) call UDSclr(iErr, KD, AD, 0)
      if (iErr.eq.0) call UDSapp(iErr, KD, AD, 0, 'SECTION:310')
      if (iErr.eq.0) call UDSdiv(iErr, KD, AD, 0)
      if (iErr.eq.0) call UDSfwd(iErr, KD, AD, 0)
CCC_   . 3.2
      if (iErr.eq.0) call UDSdiv(iErr, KD, AD, -1)
      if (iErr.eq.0) call UDSclr(iErr, KD, AD, -1)
c
      if (iErr.eq.0) call UDSset(iErr, KD, AD, -1)
c
      if (iErr.eq.0) call UDSinc(iErr, KD, AD, 0)
c
      if (iErr.eq.0) call UDSset(iErr, KD, AD, 0)
      if (iErr.eq.0) call UDSclr(iErr, KD, AD, 0)
      if (iErr.eq.0) call UDSapp(iErr, KD, AD, 0, 'SECTION:32')
      if (iErr.eq.0) call UDSdiv(iErr, KD, AD, 0)
      if (iErr.eq.0) call UDSfwd(iErr, KD, AD, 0)
CCC_   . 3.2.0
      if (iErr.eq.0) call UDSset(iErr, KD, AD, +1)
c
      if (iErr.eq.0) call UDSinc(iErr, KD, AD, 0)
c
      if (iErr.eq.0) call UDSset(iErr, KD, AD, 0)
      if (iErr.eq.0) call UDSclr(iErr, KD, AD, 0)
      if (iErr.eq.0) call UDSapp(iErr, KD, AD, 0, 'SECTION:320')
      if (iErr.eq.0) call UDSdiv(iErr, KD, AD, 0)
      if (iErr.eq.0) call UDSfwd(iErr, KD, AD, 0)
CCC_   . final
      if (iErr.eq.0) call UDSdiv(iErr, KD, AD, -3)
      if (iErr.eq.0) call UDSclr(iErr, KD, AD, -3)
c
      RETURN
      END
CCC_ & UDTEST_SECTION_01  ## test section
      subroutine UDTEST_SECTION_01 (iErr, KLVL, IFP)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(IN, integer) KLVL
      _INTENT(IN, integer) IFP
c
      integer    LK, LA
      parameter (LK = 32, LA = 32)
      integer    KD(LK)
      character  AD(LA)*(128)
      integer    JPDBG
CCC_  - Body
      iErr = 0
      JPDBG = -2
c
      call UDSbnm ('SECTION[01]', '#', 0, IFP)
c
      call UDSini (iErr, KD, AD, LK, LA, IFP)
CCC_   . 0.
      if (iErr.eq.0) call UDSnew(iErr, KD, AD, 0,  'SECTION:0')
      if (iErr.eq.0) call UDSmsg(iErr, KD, AD, 0,  -1, 'msg:0')
CCC_   . 0.0.
      if (iErr.eq.0) call UDSnew(iErr, KD, AD, +1, 'SECTION:00')
      if (iErr.eq.0) call UDSmsg(iErr, KD, AD, -1, -1, 'msg:0b')
CCC_   . 0.1.
      if (iErr.eq.0) call UDSnew(iErr, KD, AD, 0,  'SECTION:01')
      if (iErr.eq.0) call UDSmsg(iErr, KD, AD, 0,  0, 'msg:01(0)')
      if (iErr.eq.0) call UDSmsg(iErr, KD, AD, 0,  0, 'msg:01(1)')
CCC_   . 1.
      if (iErr.eq.0) call UDSnew(iErr, KD, AD, -1, 'SECTION:1')
CCC_   . 2.
      if (iErr.eq.0) call UDSopn(iErr, KD, AD, 0,  'SECTION:')
      if (iErr.eq.0) call UDSmsg(iErr, KD, AD, 0,  0, '2')
CCC_   . 3.
      if (iErr.eq.0) call UDSnew(iErr, KD, AD, 0,  'SECTION:3')
CCC_   . 3.0.0.0
      if (iErr.eq.0) call UDSnew(iErr, KD, AD, +3,  'SECTION:3000')
      if (iErr.eq.0) call UDSmsg(iErr, KD, AD, -1,  -1, 'msg:300')
CCC_   . 3.1
      if (iErr.eq.0) call UDSnew(iErr, KD, AD, -2,  'SECTION:31')
CCC_   . 3.1.0
      if (iErr.eq.0) call UDSnew(iErr, KD, AD, +1,  'SECTION:310')
CCC_   . 3.2
      if (iErr.eq.0) call UDSset(iErr, KD, AD, -1)
      if (iErr.eq.0) call UDSnew(iErr, KD, AD, 0,   'SECTION:32')
CCC_   . 3.2.0
      if (iErr.eq.0) call UDSset(iErr, KD, AD, +1)
      if (iErr.eq.0) call UDSnew(iErr, KD, AD, 0,   'SECTION:320')
CCC_   . final
      if (iErr.eq.0) call UDSfin(iErr, KD, AD)
c
      RETURN
      END
CCC_ & UDTEST_SECTION  ## test section
      subroutine UDTEST_SECTION (iErr, KLVL, IFP)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(IN, integer) KLVL
      _INTENT(IN, integer) IFP
CCC_  - Body
      iErr = 0
c
      if (KLVL.eq.0) then
         if (iErr.eq.0) call UDTEST_SECTION_00 (iErr, KLVL, IFP)
         if (iErr.eq.0) call UDTEST_SECTION_01 (iErr, KLVL, IFP)
      else if (KLVL.eq.1) then
         if (iErr.eq.0) call UDTEST_SECTION_00 (iErr, KLVL, 20)
         if (iErr.eq.0) call UDTEST_SECTION_01 (iErr, KLVL, 21)
      endif
c
      RETURN
      END
CCC_ & UDTEST_CLOCK  ## test clock
      subroutine UDTEST_CLOCK (iErr, KLVL, IFP)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(IN, integer) KLVL
      _INTENT(IN, integer) IFP
c
      integer    j
      integer    jlp, jw
      integer    lmd
      parameter (lmd = 10000000)
#include "gcldef.h"
      character TAGS(0:MAX_CLOCK_ID)*(32)
CCC_  - Body
      iErr = 0
      call UDSbnm ('CLOCK', '#', 0, IFP)
c
      call UDCLKC (iErr)
      call UDCLKI (1)
      call UDCLKO (1)
      do j = 2, 10
         call UDCLKI (j)
      enddo
      do j = 10, 2, -1
         jlp = j * lmd
         write (*, *) j, jlp
         do jw = 1, jlp
            if (mod (jw,lmd).eq.0) write (*,*) j, jw
         enddo
         call UDCLKO (j)
      enddo
      TAGS (0) = '-'
#define CLOCK_ID_TAG_SET TAGS
#include "gcldef.h"
#undef  CLOCK_ID_TAG_SET
      call UDCrep (IFP, TAGS)
      call UDSbnm ('CLOCK END', '-', 1, IFP)
c
      RETURN
      END
#endif /* TEST_UDBGST || WITH_TEST_UDBGST */
#if TEST_UDBGST
CCC_ @ UDtest  ## Unison/Debug test
      program UDtest
CCC_  - Test suites
CC::   SOURCES ustrmn.F ufortw.F
CCC_  - Declaration
      implicit none
      integer IFP
      integer iErr
CCC_  - Body
      IFP = -1
c
      call UDTEST_SECTION (iErr, 0, IFP)
      call UDTEST_SECTION (iErr, 1, IFP)
      stop
c
      call UDTEST_CLOCK   (iErr, 0, IFP)
c
      STOP
      END
CCC_ + END
#endif /* TEST_UDBGST */
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
