C ostinato/orevan.h --- IcIES/Ostinato/Revision announcement
C Maintainer:  SAITO Fuyuki
C Created: Aug 26 2010
#ifdef HEADER_PROPERTY
#define _TSTAMP 'Time-stamp: <2020/09/15 12:11:15 fuyuki orevan.h>'
#define _FNAME 'ostinato/orevan.h'
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
#ifndef    _OREVAN_H
#  define  _OREVAN_H 0
#endif
#include "ofdlct.h"
#include "ologfm.h"
CCC_ + Declaration (case 0)
#if _OREVAN_H == 0
#  undef  _OREVAN_H
#  define _OREVAN_H 1

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
#  if HAVE_F77_TRIM == 0
#     ifndef    _LSTRA
#       define  _LSTRA LSTRA
#     endif
#     ifndef    _LSTRB
#       define  _LSTRB LSTRB
#     endif
      integer   _LSTRA, _LSTRB
#  endif
CCC_ + Execution (case >0)
#elif _OREVAN_H > 0
#  ifndef _ANNOUNCE
#    error "_ANNOUNCE undefined."
#  endif
CCC_  - format (case 1 only)
#  if _OREVAN_H == 1
 _LFMT       format ('= ', I2.2, 1x, A, ':', A, '/')
#    undef  _OREVAN_H
#    define _OREVAN_H 2
#  endif
      _IOP = 0
      do
        call _ANNOUNCE (_STRA, _STRB, _IOP)
#         if HAVE_STATEMENT_EXIT
            if (_STRA.eq. ' ') exit
#         else
            if (_STRA.eq. ' ') goto _LEXT
#         endif
#         if HAVE_F77_TRIM
#           ifndef  _UNIT_ANN
              write (*, _FORMAT(_LFMT))
     $        _IOP, _TRIM(_STRA), _TRIM(_STRB)
#           else
              if (COND_N(_UNIT_ANN)) then
                write (_UNIT_ANN, _FORMAT(_LFMT))
     $            _IOP, _TRIM(_STRA), _TRIM(_STRB)
              else if ((COND_S(_UNIT_ANN)) then
                write (*, _FORMAT(_LFMT))
     $            _IOP, _TRIM(_STRA), _TRIM(_STRB)
              endif
#           endif
#         else
            _LSTRA = len_trim (_STRA)
            _LSTRB = len_trim (_STRB)
#           ifndef  _UNIT_ANN
              write (*, _FORMAT(_LFMT))
     $        _IOP, _STRA(1:_LSTRA), _STRB(1:_LSTRB)
#           else
              if (COND_N(_UNIT_ANN)) then
                write (_UNIT_ANN, _FORMAT(_LFMT))
     $            _IOP, _STRA(1:_LSTRA), _STRB(1:_LSTRB)
              else if (COND_S(_UNIT_ANN)) then
                write (*, _FORMAT(_LFMT))
     $            _IOP, _STRA(1:_LSTRA), _STRB(1:_LSTRB)
              endif
#           endif
#         endif
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
#endif /* _OREVAN_H > 0 */
CCC_! FOOTER
C Local Variables:
C mode: fortran
C fff-style: "iciesShermy"
C End:
