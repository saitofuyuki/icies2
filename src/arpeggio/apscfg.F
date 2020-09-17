C arpeggio/apscfg --- Arpeggio/Parameter configuration
C Maintainer:  SAITO Fuyuki
C Created: Oct 26 2016
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2020/09/17 08:40:31 fuyuki apscfg.F>'
#define _FNAME 'arpeggio/apscfg.F'
#define _REV   'Arpeggio 1.0'
CCC_! MANIFESTO
C
C Copyright (C) 2016--2020
C           Japan Agency for Marine-Earth Science and Technology
C
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
CCC_* Description
CCC_* Common macros
#include "ofdlct.h" /* fortran dialect */
#include "ologfm.h" /* log common format */
CCC_& APSCFG  ## IcIES/Arpeggio/Parameter configuration announcement
      subroutine APSCFG(STRA, STRB, IOP)
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
         STRB =' '
      else
         STRA = ' '
         STRB = ' '
      endif
      RETURN
      END
CCC_@ APTEST  ## Arpeggio/Parameters test
#if TEST_APSCFG
      program APTEST
CCC_ + Test suites
CCC_ + Declaration
#include "odevid.h"  /* MPI table */
#include "ofnstd.h"
      implicit none
      integer iErr
      integer ipA(LOG_CHANNEL_MAX)
      integer iMA(MAX_MPI_ATTR)
#define AKW_CLS 'V'
CCC_ + Body
      call DDcapo
     O    (iErr,
     I     2, ' ', 'O', _FNAME, -1)
      if (iErr.eq.0) then
         call DLCmng(ipA, 't')
         call DVHrgC(iErr, AKW_CLS, ' ', ' ', ipA)
      endif
      if (iErr.eq.0) then
c$$$         call AKWtma (iMA)
c$$$         call AFTESTmain (iErr, ipA, iMA)
      endif
      call DevFin(iErr)
      STOP
      END
#endif /* TEST_APSCFG */
CCC_* obsolete
CCC_ + begin
#if 0 /* obsolete */
CCC_ + end obsolete
#endif /* 0 obsolete */
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
