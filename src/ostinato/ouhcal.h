C ostinato/ouhcal.h --- Ostinato/Calendar system
C Maintainer:  SAITO Fuyuki
C Created: Dec 22 2015
#ifdef HEADER_PROPERTY
#define _TSTAMP 'Time-stamp: <2020/09/15 12:14:23 fuyuki ouhcal.h>'
#define _FNAME 'ostinato/ouhcal.h'
#define _REV   'Snoopy0.9'
#endif /* HEADER_PROPERTY */
CCC_! MANIFESTO
C
C Copyright (C) 2015--2020
C           Japan Agency for Marine-Earth Science and Technology
C
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
CCC_* Definitions
#ifndef    _OUHCAL_H
#  define  _OUHCAL_H

#include "ounits.h"

CCC_* Macros
CCC_ + calendar type
#define CAL_NORMAL  0 /* tropicalyear */
#define CAL_IDEAL   1 /* calendar; 30 days in month */
#define CAL_JGREGO  2 /* calendar; Julian-Gregorian */
#define CAL_PGREGO  3 /* calendar; proleptic Gregorian */

CCC_ + calendar unit (and default stepping method)
#define CAL_DYR   'YR'
#define CAL_DMON  'MON'
#define CAL_DDAY  'DAY'
#define CAL_DHR   'HR'
#define CAL_DMIN  'MIN'
#define CAL_DSEC  'SEC'

CCC_ + calendar output format
#define CAL_FMT_SEQ  0
#define CAL_FMT_DATE 1
CCC_ + calendar increment stepping
#define CAL_INCR_YR  'YR#c'
#define CAL_INCR_MON 'MON#c'
#define CAL_INCR_DAY 'DAY#c'
#define CAL_INCR_HR  'HR#c'
#define CAL_INCR_MIN 'MIN#c'
#define CAL_INCR_SEC 'SEC#c'

CCC_ + stepwise calendar forwarding
#define CAL_STPW_YR  'YR#s'
#define CAL_STPW_MON 'MON#s'
#define CAL_STPW_DAY 'DAY#s'
#define CAL_STPW_HR  'HR#s'
#define CAL_STPW_MIN 'MIN#s'
#define CAL_STPW_SEC 'SEC#s'

CCC_ + date string type
#define CAL_FMT_DEF 0 /* single unit */

CCC_ + calendar attribute cluster (must be larger than _CATTR_MAX in uxhcal.F)
#define CATTR_MAX  27
CCC_* End definitions
#endif  /* _OUHCAL_H */
CCC_! FOOTER
C Local Variables:
C mode: fortran
C fff-style: "iciesShermy"
C End:
