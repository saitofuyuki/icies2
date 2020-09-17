C unison/ueaoms.F --- IcIES/Unison/Environment Argument Option manager
C Maintainer:  SAITO Fuyuki
C Created: Mar  7 2010
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2013/09/26 06:24:49 fuyuki ueaoms.F>'
#define _FNAME 'unison/ueaoms.F'
#define _REV   'Snoopy0.9'
CCC_! MANIFESTO
C
C Copyright (C) 2010--2020
C           Japan Agency for Marine-Earth Science and Technology,
C           Ayako ABE-OUCHI
C
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
CCC_* Macro
#include "ofdlct.h" /* fortran dialect */
CCC_ + Test
#ifndef TEST_UEAOMS
#  define TEST_UEAOMS 0
#endif
#ifndef   HAVE_F77_GET_ENVIRONMENT_VARIABLE
#  define HAVE_F77_GET_ENVIRONMENT_VARIABLE 0
#endif
#ifndef   HAVE_F77_GETENV
#  define HAVE_F77_GETENV 0
#endif
#if   TEST_UEAOMS == 1
#  undef  HAVE_F77_GET_ENVIRONMENT_VARIABLE
#  define HAVE_F77_GET_ENVIRONMENT_VARIABLE 1
#elif TEST_UEAOMS == 2
#  undef  HAVE_F77_GET_ENVIRONMENT_VARIABLE
#  define HAVE_F77_GET_ENVIRONMENT_VARIABLE 0
#  undef  HAVE_F77_GETENV
#  define HAVE_F77_GETENV 1
#elif TEST_UEAOMS == 3
#  undef  HAVE_F77_GET_ENVIRONMENT_VARIABLE
#  define HAVE_F77_GET_ENVIRONMENT_VARIABLE 0
#  undef  HAVE_F77_GETENV
#  define HAVE_F77_GETENV 0
#endif
CCC_& UEgenv  ## Utilitiy system-dependent getenv wrapper
      subroutine UEgenv (VALUE, ENVVAR)
CCC_ + Declaration
      implicit none
      _INTENT(IN, character) ENVVAR*(*)
      _INTENT(OUT,character) VALUE *(*)
CCC_ + Body
#if   HAVE_F77_GET_ENVIRONMENT_VARIABLE
      call GET_ENVIRONMENT_VARIABLE (ENVVAR, VALUE)
#elif HAVE_F77_GETENV
      call GETENV (ENVVAR, VALUE)
#else
CC       Dummy statements
      if (ENVVAR.eq.' ') continue
      VALUE = ' '
#endif
      RETURN
      END
CCC_& UEdiag  ## Utility system-dependent getenv diagnosis
      subroutine UEdiag
     O     (Kind)
CCC_ + Declaration
      implicit none
      _INTENT(OUT,integer) Kind
CCC_ + Body
#if   HAVE_F77_GET_ENVIRONMENT_VARIABLE
      Kind = 1
#elif HAVE_F77_GETENV
      Kind = 2
#else
      Kind = 0
#endif
      RETURN
      END
CCC_& UEAOMS  ## Unison/Environment manager announcement
      subroutine UEAOMS (STRA, STRB, IOP)
CCC_ + Description
CC     called by DevUtl () to return the source information
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
         STRA = 'TEST_UEAOMS'
         write (STRB, *) TEST_UEAOMS
      else if (IOP.eq.4) then
         STRA = 'HAVE_F77_GET_ENVIRONMENT_VARIABLE'
         write (STRB, *) HAVE_F77_GET_ENVIRONMENT_VARIABLE
      else if (IOP.eq.5) then
         STRA = 'HAVE_F77_GETENV'
         write (STRB, *) HAVE_F77_GETENV
      else
         STRA = ' '
         STRB = ' '
      endif
      RETURN
      END
CCC_* Test
CCC_ + begin
#if TEST_UEAOMS
CCC_ @ UETEST  ## Unison/Environment test program
      program UETEST
CCC_  - Test suites
CC::   KINDS 1 2 3
CCC_  - Declaration
      implicit none
      character E*(128)
      character V*(256)
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
#include "orevan.h" /* 0 */
CCC_  - Body
#define _ANNOUNCE UEAOMS
#define _LEXT     9999
#include "orevan.h" /* 1 */
c
 101  format ('[', A, '] ',A, '$')
      E = 'HOME'
      V = ' '
      call UEgenv (V, E)
      write (*, 101) _TRIM(E), _TRIM(V)
      E = 'XYZ'
      V = ' '
      call UEgenv (V, E)
      write (*, 101) _TRIM(E), _TRIM(V)
      STOP
      END
CCC_ + end
#endif /* TEST_UEAOMS */
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
