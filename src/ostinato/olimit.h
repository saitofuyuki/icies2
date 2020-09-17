/* ostinato/olimit.h --- IcIES/Ostinato/number limits */
/* Maintainer:  SAITO Fuyuki */
/* Created: Jan 13 2012 */
#ifdef HEADER_PROPERTY
#define _TSTAMP 'Time-stamp: <2020/09/17 08:48:28 fuyuki olimit.h>'
#define _FNAME 'ostinato/olimit.h'
#define _REV   'Snoopy0.97'
#endif /* HEADER_PROPERTY */
/***_! MANIFESTO */
/* Copyright (C) 2012--2020 */
/*           Japan Agency for Marine-Earth Science and Technology, */
/*           Ayako ABE-OUCHI */
/* Licensed under the Apache License, Version 2.0  */
/*   (https://www.apache.org/licenses/LICENSE-2.0) */

/***_* Definitions */
#ifndef    _OLIMIT_H
#  define  _OLIMIT_H

/***_ + integer */
#ifndef    _INT_MAX
#  define  _INT_MIN   (-_INT_MAX-1)
#  define  _INT_MAX   2147483647
#endif
/***_ + double */
#ifndef    _DBLE_HUGE
#  define  _DBLE_HUGE 1.0D300
#endif
#ifndef    _DBLE_MAX
#  define  _DBLE_MAX  1.7976931348623157D308
#endif
/***_* End definitions */
#endif  /* not _OLIMIT_H */
/***_! FOOTER */
