C ostinato/ounits.h --- Ostinato/Units and unit-systems
C Maintainer:  SAITO Fuyuki
C Created: Oct 21 2010
#ifdef HEADER_PROPERTY
#define _TSTAMP 'Time-stamp: <2020/09/15 12:14:40 fuyuki ounits.h>'
#define _FNAME 'ostinato/ounits.h'
#define _REV   'Snoopy0.9'
#endif /* HEADER_PROPERTY */
CCC_! MANIFESTO
C
C Copyright (C) 2010--2020
C           Japan Agency for Marine-Earth Science and Technology
C
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
CCC_* Definitions
#ifndef    _OUNITS_H
#  define  _OUNITS_H

CCC_ + Options
#ifndef    OPT_UNIT_LEN            /* length of unit atom */
#  define  OPT_UNIT_LEN            32
#endif

CCC_ + Macros
CCC_  - unit conversion level
#define UXLEV_F   0 /* factor */
#define UXLEV_FD  1 /* factor, denominator */
#define UXLEV_FDM 2 /* factor, denominator, magnitude */
CCC_  - scale-table index
#define UXC_F 1 /* factor */
#define UXC_D 2 /* denominator */
#define UXC_M 3 /* maginitude (power of ten) */
#define UXC_MAX 3
CCC_  - units health check
#define UX_DIFF_DIM 1 /* different dimension */
#define UX_NO_SCALE 2 /* same dimension but no valid scale */

CCC_ + Errors
CCC_  - Warning
#define ERR_UNIT_NEW_UNIT            1
#define ERR_UNIT_OLD_TO_SET          2
CCC_  - Error
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
CCC_  - Diagnostic
#define ERR_UNIT_DIAG_DIFFERENT     16
#define ERR_UNIT_DIAG_SAME_DIM      17
CCC_* End definitions
#endif  /* _OUNITS_H */
CCC_! FOOTER
C Local Variables:
C mode: fortran
C fff-style: "iciesShermy"
C End:
