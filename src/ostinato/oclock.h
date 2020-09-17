/* ostinato/oclock.h --- Definition for system-dependent clock macros */
/* Maintainer:  SAITO Fuyuki */
/* Created: Apr 10 2013 */
#ifdef HEADER_PROPERTY
#define _TSTAMP 'Time-stamp: <2020/09/17 08:51:35 fuyuki oclock.h>'
#define _FNAME 'ostinato/oclock.h'
#define _REV   'Snoopy0.97'
#endif /* HEADER_PROPERTY */
/***_! MANIFESTO */
/* Copyright (C) 2013--2020 */
/*           Japan Agency for Marine-Earth Science and Technology, */
/*           Ayako ABE-OUCHI */
/* Licensed under the Apache License, Version 2.0 */
/*   (https://www.apache.org/licenses/LICENSE-2.0) */

/***_* Definitions */
#ifndef    _OCLOCK_H
#  define  _OCLOCK_H
#ifndef    OPT_USE_CLOCK
#  define  OPT_USE_CLOCK 0
#endif
/***_ + switch kinds */
#define _CLOCK_DEBUG     -999
#define _CLOCK_NULL      -1
#define _CLOCK_NONE      0
#define _CLOCK_SX_FTRACE 1
#define _CLOCK_EMBEDDED  2
/***_ + user interfaces */
/*      example:  CLOCK_I(AKXWAX, 'AKXWAX_1') */
#define CLOCK_I(K,T) CLOCK_IK(K,T,K)
#define CLOCK_O(K,T) CLOCK_OK(K,T,K)

#define CLOCK_IK(K,T,M) _CLOCK_I(K,T,_CLOCK_ID(K),_CLOCK_COND(K))
#define CLOCK_OK(K,T,M) _CLOCK_O(K,T,_CLOCK_ID(K),_CLOCK_COND(K))
/***_ + condition */
#if   HAVE_CPP_F_CONCATENATION
#  define _CLOCK_COND(K) _CLOCK_COND_ ## K
#  define _CLOCK_ID(K)  _CLOCK_ID_ ## K
#else
#  define _CLOCK_COND(K) _CLOCK_COND_/**/K
#  define _CLOCK_ID(K)  _CLOCK_ID_/**/K
#endif
/***_ + key */
/***_ + system-dependent core macros */
/***_  - default */
#if    OPT_USE_CLOCK == _CLOCK_NONE
#  define _CLOCK_I(K,T,I,C) continue
#  define _CLOCK_O(K,T,I,C) continue
/***_  - null */
#elif  OPT_USE_CLOCK == _CLOCK_NULL
#  define _CLOCK_I(K,T,I,C)
#  define _CLOCK_O(K,T,I,C)
/***_  - debug */
#elif  OPT_USE_CLOCK == _CLOCK_DEBUG
#  define _CLOCK_I !! clock:
#  define _CLOCK_O !! clock:
/***_  - sx ftrace */
#elif  OPT_USE_CLOCK == _CLOCK_SX_FTRACE
#  define _CLOCK_I(K,T,I,C) if(C)_CLOCK_SX_I(T)
#  define _CLOCK_O(K,T,I,C) if(C)_CLOCK_SX_O(T)
/***_  - embedded */
#elif  OPT_USE_CLOCK == _CLOCK_EMBEDDED
#  define _CLOCK_I(K,T,I,C) if(C)_CLOCK_EMBEDDED_I(I)
#  define _CLOCK_O(K,T,I,C) if(C)_CLOCK_EMBEDDED_O(I)
/***_  - else error */
#else
#  error "UNKNOWN SYSTEM-DEPENDENT CLOCK KIND"
#endif
/***_   . sx */
#define _CLOCK_SX_I(T)   CALL FTRACE_REGION_BEGIN(T)
#define _CLOCK_SX_O(T)   CALL FTRACE_REGION_END(T)
/***_   . embedded */
#define _CLOCK_EMBEDDED_I(I)   CALL UDCLKI(I)
#define _CLOCK_EMBEDDED_O(I)   CALL UDCLKO(I)
/***_ + conditions (automatic generation) */
#if OPT_USE_CLOCK > _CLOCK_NONE
#  include "lclcnd.h"
#endif
/***_* End definitions */
#endif  /* not _OCLOCK_H */
/***_! FOOTER */
