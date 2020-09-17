C cadenza/caechk.F --- IcIES/Cadenza/Arpeggio checker
C Author: SAITO Fuyuki
C Created: Apr 8 2013
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2020/09/15 11:52:46 fuyuki caechk.F>'
#define _FNAME 'cadenza/caechk.F'
#define _REV   'Snoopy0.8'
CCC_! MANIFESTO
C
C Copyright (C) 2013--2020
C           Japan Agency for Marine-Earth Science and Technology,
C           Ayako ABE-OUCHI
C
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
CCC_* Common macros
#include "ofdlct.h" /* fortran dialect */
#include "ofnstd.h"
CC #include "oarpea.h"
#include "oarpfi.h"
#include "odevva.h"
#include "odevel.h"
#include "oarpkw.h"   /* operation id in arpeggio/kiwi */
CCC_& CAECHK  ## IcIES/Cadenza/Arpeggio checker announcement
      subroutine CAECHK (STRA, STRB, IOP)
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
CCC_@ CAEPRG  ## Cadenza/Arpeggio/checker program
      program CAEPRG
CCC_ + Declaration
      implicit none
      integer iErr
      integer ipA (LOG_CHANNEL_MAX)
      integer iMA (MAX_MPI_ATTR)
CCC_ + Body
      call DDnull (iErr)
      if (iErr.eq.0) then
         call DLCmng (ipA, 't')
         call DVHrgC (iErr, ' ', ' ', ' ', ipA)
      endif
      call DFnull (iErr)
      STOP
      END
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
C This file is a part of IcIES (Ice sheet model for Integrated
C Earth system Studies).
C
C You cannot redistribute it without the permission of
C the IcIES author group (see IcIES document).
C This file is a part of IcIES (Ice sheet model for Integrated
C Earth system Studies).
C
C You cannot redistribute it without the permission of
C the IcIES author group (see IcIES document).
