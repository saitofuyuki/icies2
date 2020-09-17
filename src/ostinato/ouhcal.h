/* ostinato/ouhcal.h --- Ostinato/Calendar system */
/* Maintainer:  SAITO Fuyuki */
/* Created: Dec 22 2015 */
#ifdef HEADER_PROPERTY
#define _TSTAMP 'Time-stamp: <2020/09/17 08:34:15 fuyuki ouhcal.h>'
#define _FNAME 'ostinato/ouhcal.h'
#define _REV   'Snoopy0.97'
#endif /* HEADER_PROPERTY */
/***_! MANIFESTO */
/* Copyright (C) 2015--2020 */
/*           Japan Agency for Marine-Earth Science and Technology */
/* Licensed under the Apache License, Version 2.0  */
/*   (https://www.apache.org/licenses/LICENSE-2.0) */
/***_* Definitions */
#ifndef    _OUHCAL_H
#  define  _OUHCAL_H

#include "ounits.h"

/***_* Macros */
/***_ + calendar type */
#define CAL_NORMAL  0 /* tropicalyear */
#define CAL_IDEAL   1 /* calendar; 30 days in month */
#define CAL_JGREGO  2 /* calendar; Julian-Gregorian */
#define CAL_PGREGO  3 /* calendar; proleptic Gregorian */

/***_ + calendar unit (and default stepping method) */
#define CAL_DYR   'YR'
#define CAL_DMON  'MON'
#define CAL_DDAY  'DAY'
#define CAL_DHR   'HR'
#define CAL_DMIN  'MIN'
#define CAL_DSEC  'SEC'

/***_ + calendar output format */
#define CAL_FMT_SEQ  0
#define CAL_FMT_DATE 1
/***_ + calendar increment stepping */
#define CAL_INCR_YR  'YR#c'
#define CAL_INCR_MON 'MON#c'
#define CAL_INCR_DAY 'DAY#c'
#define CAL_INCR_HR  'HR#c'
#define CAL_INCR_MIN 'MIN#c'
#define CAL_INCR_SEC 'SEC#c'

/***_ + stepwise calendar forwarding */
#define CAL_STPW_YR  'YR#s'
#define CAL_STPW_MON 'MON#s'
#define CAL_STPW_DAY 'DAY#s'
#define CAL_STPW_HR  'HR#s'
#define CAL_STPW_MIN 'MIN#s'
#define CAL_STPW_SEC 'SEC#s'

/***_ + date string type */
#define CAL_FMT_DEF 0 /* single unit */

/***_ + calendar attribute cluster (must be larger than _CATTR_MAX in uxhcal.F) */
#define CATTR_MAX  27
/***_* End definitions */
#endif  /* not _OUHCAL_H */
/***_! FOOTER */
