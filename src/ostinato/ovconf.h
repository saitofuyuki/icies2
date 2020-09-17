C ostinato/ovconf.h --- IcIES/Ostinato/variable configuration
C Maintainer:  SAITO Fuyuki
C Created: Nov 27 2015
#ifdef HEADER_PROPERTY
#define _TSTAMP 'Time-stamp: <2020/09/15 12:11:40 fuyuki ovconf.h>'
#define _FNAME 'ostinato/ovconf.h'
#define _REV   'Snoopy0.9'
#endif /* HEADER_PROPERTY */
CCC_! MANIFESTO
C
C Copyright (C) 2015--2020
C           Japan Agency for Marine-Earth Science and Technology,
C           Ayako ABE-OUCHI
C
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
CCC_* Definitions
#ifndef    _OVCONF_H
#  define  _OVCONF_H
#  include "ounits.h"

CCC_ + Macros
#define UNIT_CFG 1
#define UNIT_SYS 2
#define UNIT_EXT 3
#define UNIT_MAX 3

#define UNIT_USE_PRM  '!' /* use primitive unit */
#define UNIT_USE_CFG  '-' /* use same unit as config */

CCC_* End definitions
#endif  /* _OVCONF_H */
CCC_! FOOTER
C Local Variables:
C mode: fortran
C fff-style: "iciesShermy"
C End:
