C ostinato/orevan.F --- IcIES/Ostinato/Revision announcement
C Maintainer:  SAITO Fuyuki
C Created: Aug 26 2010
#ifdef HEADER_PROPERTY
#define _TSTAMP 'Time-stamp: <2020/09/17 08:48:41 fuyuki orevan.F>'
#define _FNAME 'ostinato/orevan.F'
#define _REV   'Snoopy0.97'
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
CC    This file must be included twice, once in the declaration part
CC    and the other in the body part where you want to announce.
CC
CC    Macro _ANNOUNCE must be defined as announcement subroutine
CC    before the second inclusion.
CC
CC    When included more than twice, the format declaration is
CC    inserted only at the second inclusion.  Before third inclustion,
CC    macro _LEXT must be adjusted to new label number, otherwise
CC    an infinite loop is created.
CC
CC    Define macro _UNIT_ANN as an i/o unit or an integer variable,
CC    otherwise the asterisk is used.
CCC_* Main
#ifndef    _OREVAN_F
#  define  _OREVAN_F 0
#endif
#include "ofdlct.h"
#include "ologfm.h"
CCC_ + Declaration (case 0)
#if _OREVAN_F == 0
#  undef  _OREVAN_F
#  define _OREVAN_F 1    /* increment for second inclusion */

#  ifndef   _IOP
#    define _IOP  IOP
#  endif

#  ifndef   _STRA
#    define _STRA STRA
#  endif
#  ifndef   _STRB
#    define _STRB STRB
#  endif

#  ifndef   _LFMT
#    define _LFMT 1001
#  endif
      integer   _IOP
      character _STRA*(128), _STRB*(64)
CCC_ + Execution (case >0)
#elif _OREVAN_F > 0
#  ifndef _ANNOUNCE
#    error "_ANNOUNCE undefined."
#  endif
CCC_  - format (case 1 only)
#  if _OREVAN_F == 1
 _LFMT       format ('= ', I2.2, 1x, A, ':', A, '/')
#    undef  _OREVAN_F
#    define _OREVAN_F 2
#  endif
#  ifndef  _UNIT_ANN
#    define __UNIT 0
#    define _COND_N .FALSE.
#    define _COND_S .TRUE.
#  else
#    define __UNIT _UNIT_ANN
#    define _COND_N COND_N(_UNIT_ANN)
#    define _COND_S COND_S(_UNIT_ANN)
#  endif
      _IOP = 0
      do
        call _ANNOUNCE (_STRA, _STRB, _IOP)
#       if HAVE_STATEMENT_EXIT
          if (_STRA.eq.' ') exit
#       else
          if (_STRA.eq.' ') goto _LEXT
#       endif
#       if HAVE_F77_TRIM
          if (_COND_N) then
             write (__UNIT, _FORMAT(_LFMT))
     $            _IOP, _TRIM(_STRA), _TRIM(_STRB)
          else if (_COND_S) then
             write (*, _FORMAT(_LFMT))
     $            _IOP, _TRIM(_STRA), _TRIM(_STRB)
          endif
#       else
          if (_COND_N) then
             write (__UNIT, _FORMAT(_LFMT)) _IOP,
     $            _STRA(1:len_trim(_STRA)),
     $            _STRB(1:len_trim(_STRB))
          else if (_COND_S) then
             write (*, _FORMAT(_LFMT)) _IOP,
     $            _STRA(1:len_trim(_STRA)),
     $            _STRB(1:len_trim(_STRB))
          endif
#       endif
        _IOP = _IOP + 1
      enddo
#     if HAVE_STATEMENT_EXIT == 0
#       ifndef   _LEXT
#         error "_LEXT undefined."
#       endif
 _LEXT       continue
#     endif
#  undef _ANNOUNCE
#  undef _LEXT
#  undef __UNIT
#  undef _COND_N
#  undef _COND_S
#endif /* _OREVAN_F > 0 */
CCC_! FOOTER
C Local Variables:
C mode: fortran
C fff-style: "iciesShermy"
C End:
