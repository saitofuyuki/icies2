C unison/uprfem.F --- IcIES/Unison/Embedded profiler
C Maintainer:  SAITO Fuyuki
C Created: Apr 4 2013
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2013/09/26 06:49:30 fuyuki uprfem.F>'
#define _FNAME 'unison/uprfem.F'
#define _REV   'Snoopy0.9'
CCC_! MANIFESTO
C
C Copyright (C) 2013--2020
C           Japan Agency for Marine-Earth Science and Technology,
C           Ayako ABE-OUCHI
C
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
CCC_* Macro
#include "ofdlct.h" /* fortran dialect */
CCC_ + interior buffer
#ifndef    OPT_UPRFEM_BUFFER_LIM
#  define  OPT_UPRFEM_BUFFER_LIM 256
#endif
#ifndef    OPT_UPRFEM_LEVEL_LIM
#  define  OPT_UPRFEM_LEVEL_LIM 128
#endif
CCC_ + Test condition
#ifndef   TEST_UPRFEM
#  define TEST_UPRFEM 0
#endif
CCC_& UPRFEM  ## Unison/Profiler Announcement
      subroutine UPRFEM (STRA, STRB, IOP)
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
CCC_@ UPTEST  ## Unison/Profiler test
CCC_ + Test suites
#if TEST_UPRFEM
      program UPTEST
CCC_ + Declaration
      implicit none
CCC_ + Body
      STOP
      END
#endif /* TEST_UFORTW */
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
