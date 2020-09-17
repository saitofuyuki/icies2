/* ostinato/ounits.h --- Ostinato/Units and unit-systems */
/* Maintainer:  SAITO Fuyuki */
/* Created: Oct 21 2010 */

#ifdef HEADER_PROPERTY
#define _TSTAMP 'Time-stamp: <2020/09/17 08:34:23 fuyuki ounits.h>'
#define _FNAME 'ostinato/ounits.h'
#define _REV   'Snoopy0.97'
#endif /* HEADER_PROPERTY */
/***_! MANIFESTO */
/* Copyright (C) 2010--2020 */
/*           Japan Agency for Marine-Earth Science and Technology */
/* Licensed under the Apache License, Version 2.0 */
/*   (https://www.apache.org/licenses/LICENSE-2.0) */
/***_* Definitions */
#ifndef    _OUNITS_H
#  define  _OUNITS_H
/***_ + Options */
#ifndef    OPT_UNIT_LEN            /* length of unit atom */
#  define  OPT_UNIT_LEN            32
#endif
/***_ + Macros */
/***_  - unit conversion level */
#define UXLEV_F   0 /* factor */
#define UXLEV_FD  1 /* factor, denominator */
#define UXLEV_FDM 2 /* factor, denominator, magnitude */
/***_  - scale-table index */
#define UXC_F 1 /* factor */
#define UXC_D 2 /* denominator */
#define UXC_M 3 /* maginitude (power of ten) */
#define UXC_MAX 3
/***_  - units health check */
#define UX_DIFF_DIM 1 /* different dimension */
#define UX_NO_SCALE 2 /* same dimension but no valid scale */

/***_ + Errors */
/***_  - Warning */
#define ERR_UNIT_NEW_UNIT            1
#define ERR_UNIT_OLD_TO_SET          2
/***_  - Error */
#define ERR_UNIT_PANIC              -32768
#define ERR_UNIT_INSUFFICIENT       -32

#define ERR_UNIT_OVERFLOW_SINGLE         -1
#define ERR_UNIT_OVERFLOW_DECOMPOSITION  -2
#define ERR_UNIT_OVERFLOW_COMPOUND       -3
#define ERR_UNIT_OVERFLOW_TABLE          -4
#define ERR_UNIT_OVERFLOW_SEQUENCE       -5
#define ERR_UNIT_INVALID_SINGLE          -6
#define ERR_UNIT_INVALID_DECOMPOSITION   -7
#define ERR_UNIT_INVALID_COMPOUND        -8
#define ERR_UNIT_INVALID_TABLE           -9
#define ERR_UNIT_EXIST_SINGLE           -10
#define ERR_UNIT_EXIST_COMPOUND         -11
#define ERR_UNIT_INVALID_SWITCH         -12
#define ERR_UNIT_DUP_SINGLE             -13
#define ERR_UNIT_INVALID_BASE           -14
/***_  - Diagnostic */
#define ERR_UNIT_DIAG_DIFFERENT     16
#define ERR_UNIT_DIAG_SAME_DIM      17
/***_* End definitions */
#endif  /* not _OUNITS_H */
/***_! FOOTER */
