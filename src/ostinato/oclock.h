C ostinato/oclock.h --- Definition for system-dependent clock macros
C Maintainer:  SAITO Fuyuki
C Created: Apr 10 2013
#ifdef HEADER_PROPERTY
#define _TSTAMP 'Time-stamp: <2013/10/01 15:16:02 fuyuki oclock.h>'
#define _FNAME 'ostinato/oclock.h'
#define _REV   'Snoopy0.9'
#endif /* HEADER_PROPERTY */
CCC_! MANIFESTO
C
C Copyright (C) 2013--2020
C           Japan Agency for Marine-Earth Science and Technology,
C           Ayako ABE-OUCHI
C
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
CCC_* Definitions
#ifndef    _OCLOCK_H
#  define  _OCLOCK_H
#ifndef    OPT_USE_CLOCK
#  define  OPT_USE_CLOCK 0
#endif
CCC_ + switch kinds
#define _CLOCK_DEBUG     -999
#define _CLOCK_NULL      -1
#define _CLOCK_NONE      0
#define _CLOCK_SX_FTRACE 1
#define _CLOCK_EMBEDDED  2
CCC_ + user interfaces
CC  example:  CLOCK_I(AKXWAX, 'AKXWAX_1')
#define CLOCK_I(K,T) CLOCK_IK(K,T,K)
#define CLOCK_O(K,T) CLOCK_OK(K,T,K)

#define CLOCK_IK(K,T,M) _CLOCK_I(K,T,_CLOCK_ID(K),_CLOCK_COND(K))
#define CLOCK_OK(K,T,M) _CLOCK_O(K,T,_CLOCK_ID(K),_CLOCK_COND(K))
CCC_ + condition
#if   HAVE_CPP_F_CONCATENATION
#  define _CLOCK_COND(K) _CLOCK_COND_ ## K
#  define _CLOCK_ID(K)  _CLOCK_ID_ ## K
#else
#  define _CLOCK_COND(K) _CLOCK_COND_/**/K
#  define _CLOCK_ID(K)  _CLOCK_ID_/**/K
#endif
CCC_ + key
CCC_ + system-dependent core macros
CCC_  - default
#if    OPT_USE_CLOCK == _CLOCK_NONE
#  define _CLOCK_I(K,T,I,C) continue
#  define _CLOCK_O(K,T,I,C) continue
CCC_  - null
#elif  OPT_USE_CLOCK == _CLOCK_NULL
#  define _CLOCK_I(K,T,I,C)
#  define _CLOCK_O(K,T,I,C)
CCC_  - debug
#elif  OPT_USE_CLOCK == _CLOCK_DEBUG
#  define _CLOCK_I !! clock:
#  define _CLOCK_O !! clock:
CCC_  - sx ftrace
#elif  OPT_USE_CLOCK == _CLOCK_SX_FTRACE
#  define _CLOCK_I(K,T,I,C) if(C)_CLOCK_SX_I(T)
#  define _CLOCK_O(K,T,I,C) if(C)_CLOCK_SX_O(T)
CCC_  - embedded
#elif  OPT_USE_CLOCK == _CLOCK_EMBEDDED
#  define _CLOCK_I(K,T,I,C) if(C)_CLOCK_EMBEDDED_I(I)
#  define _CLOCK_O(K,T,I,C) if(C)_CLOCK_EMBEDDED_O(I)
CCC_  - else error
#else
#  error "UNKNOWN SYSTEM-DEPENDENT CLOCK KIND"
#endif
CCC_   . sx
#define _CLOCK_SX_I(T)   CALL FTRACE_REGION_BEGIN(T)
#define _CLOCK_SX_O(T)   CALL FTRACE_REGION_END(T)
CCC_   . embedded
#define _CLOCK_EMBEDDED_I(I)   CALL UDCLKI(I)
#define _CLOCK_EMBEDDED_O(I)   CALL UDCLKO(I)
CCC_ + conditions (automatic generation)
#if OPT_USE_CLOCK > _CLOCK_NONE
#  include "lclcnd.h"
#endif
CCC_* End definitions
#endif  /* _OCLOCK_H */
CCC_! FOOTER
C Local Variables:
C mode: fortran
C fff-style: "iciesShermy"
C End:
