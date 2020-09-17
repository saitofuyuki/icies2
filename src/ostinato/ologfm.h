C ostinato/ologfm.h --- IcIES/Ostinato logging
C Maintainer:  SAITO Fuyuki
C Created: Oct 28 2011
#ifdef HEADER_PROPERTY
#define _TSTAMP 'Time-stamp: <2016/07/12 12:39:31 fuyuki ologfm.h>'
#define _FNAME 'ostinato/ologfm.h'
#define _REV   'Snoopy0.9'
#endif /* HEADER_PROPERTY */
CCC_! MANIFESTO
C
C Copyright (C) 2011--2020
C           Japan Agency for Marine-Earth Science and Technology,
C           Ayako ABE-OUCHI
C
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
CCC_* Description
#if 0 /* meta comment */
CCC_ + typical usage

#include "ologfm.h"
CC :
 101  format (A,A,A)
      if      (COND_N(IFP)) then
         write (IFP,_FORMAT(101)) A, B, C
      else if (COND_S(IFP)) then
         write (*,  _FORMAT(101)) A, B, C
      endif
CCC_ + another typical usage
CC :
      if      (COND_N(IFP)) then
         write (IFP,_FORMAT(101)) A, B, C
      else if (COND_S(IFP)) then
#        define IFP *
         write (IFP,_FORMAT(101)) A, B, C
#        undef  IFP
      endif
CC    You can insert the identical source into the star condition block.
#endif /* meta comment */
CCC_* Definitions
#ifndef    _OLOGFM_H
#  define  _OLOGFM_H

#  define LOGFMT_INM ('INM ', L1, ': ', 3I8, 1x, A)
#  define ITEMS_INM(I,N,M,S) (I.gt.M),I,N,M,S

#  define _CHMSG ': '
#  define _CHERR '# '

CCC_ + i/o unit special
#define IOUNIT_STAR   -1
#define IOUNIT_MIN    -1

CCC_ + log unit conditions
#define UNIT_COND_CHECK   0 /* normal */
#define UNIT_COND_STAR    1 /* always asterisk */
#define UNIT_COND_NUMBER  2 /* always number */
#define UNIT_COND_NEVER  -1 /* never */

CCC_ + condition choices
#if    OPT_UNIT_COND == UNIT_COND_CHECK
#  define COND_N(P) P .ge. 0
#  define COND_S(P) P .eq. IOUNIT_STAR
#elif  OPT_UNIT_COND == UNIT_COND_STAR
#  define COND_N(P) .true.
#  define COND_S(P) .false.
#elif  OPT_UNIT_COND == UNIT_COND_NUMBER
#  define COND_N(P) .false.
#  define COND_S(P) .true.
#elif  OPT_UNIT_COND == UNIT_COND_NEVER
#  define COND_N(P) .false.
#  define COND_S(P) .false.
#else
#      error "invalid i/o unit condition"
#endif

CCC_  - default choice
#ifndef   OPT_UNIT_COND
#  define OPT_UNIT_COND UNIT_COND_CHECK /* normal */
#endif

CCC_ + log format
#ifndef   OPT_FORMAT_STAR
#  define OPT_FORMAT_STAR 0
#endif
#if OPT_FORMAT_STAR
#  define _FORMAT(F) *
#else
#  define _FORMAT(F) F
#endif

CCC_ + Diagnostic
CC      opt_UNIT_COND:    OPT_UNIT_COND
CC      opt_FORMAT_STAR:  OPT_FORMAT_STAR
CC
#endif  /* _OLOGFM_H */
CCC_! FOOTER
C Local Variables:
C mode: fortran
C fff-style: "iciesShermy"
C End:
