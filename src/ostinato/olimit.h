C ostinato/olimit.h --- IcIES/Ostinato/number limits
C Maintainer:  SAITO Fuyuki
C Created: Jan 13 2012
#ifdef HEADER_PROPERTY
#define _TSTAMP 'Time-stamp: <2020/09/15 12:11:04 fuyuki olimit.h>'
#define _FNAME 'ostinato/olimit.h'
#define _REV   'Snoopy0.9'
#endif /* HEADER_PROPERTY */
CCC_! MANIFESTO
C
C Copyright (C) 2012--2020
C           Japan Agency for Marine-Earth Science and Technology,
C           Ayako ABE-OUCHI
C
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
CCC_* Definitions
#ifndef    _OLIMIT_H
#  define  _OLIMIT_H

CCC_ + integer
#ifndef    _INT_MAX
#  define  _INT_MIN   (-_INT_MAX-1)
#  define  _INT_MAX   2147483647
#endif
CCC_ + double
#ifndef    _DBLE_HUGE
#  define  _DBLE_HUGE 1.0D300
#endif
#ifndef    _DBLE_MAX
#  define  _DBLE_MAX  1.7976931348623157D308
#endif
CCC_* End definitions
#endif  /* _OLIMIT_H */
CCC_! FOOTER
C Local Variables:
C mode: fortran
C fff-style: "iciesShermy"
C End:
