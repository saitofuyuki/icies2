C movement/mhaint.F --- IcIES/Movement/HOA/a integral
C Maintainer:  SAITO Fuyuki
C Created: Dec 8 2019
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2020/09/17 08:44:54 fuyuki mhaint.F>'
#define _FNAME 'movement/mhaint.F'
#define _REV   'Snoopy0.97/Three0.1'
CCC_! MANIFESTO
C
C Copyright (C) 2019, 2020
C           Japan Agency for Marine-Earth Science and Technology,
C           Ayako ABE-OUCHI
C
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
CCC_* Common macros
#include "ofdlct.h"   /* fortran dialect */
#include "ologfm.h"   /* logging */
CCC_* [MHD] Driver (Iteration)
CCC_* [MHQ] Runge-Kutta (4th order) integration
CCC_* [MHS] Runge-Kutta (2nd order) integration
CCC_* [MHO] ODE solver plane
CCC_* [MHA] algebraic solver
CCC_& MHAINT  ## Movement/HOA/a integral announcement
      subroutine MHAINT (STRA, STRB, IOP)
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
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
