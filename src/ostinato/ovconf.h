/* ostinato/ovconf.h --- IcIES/Ostinato/variable configuration */
/* Maintainer:  SAITO Fuyuki */
/* Created: Nov 27 2015 */
#ifdef HEADER_PROPERTY
#define _TSTAMP 'Time-stamp: <2020/09/17 08:48:51 fuyuki ovconf.h>'
#define _FNAME 'ostinato/ovconf.h'
#define _REV   'Snoopy0.97'
#endif /* HEADER_PROPERTY */
/***_! MANIFESTO */
/* Copyright (C) 2015--2020 */
/*           Japan Agency for Marine-Earth Science and Technology, */
/*           Ayako ABE-OUCHI */
/* Licensed under the Apache License, Version 2.0  */
/*   (https://www.apache.org/licenses/LICENSE-2.0) */
/***_* Definitions */
#ifndef    _OVCONF_H
#  define  _OVCONF_H
#  include "ounits.h"

/***_ + Macros */
#define UNIT_CFG 1
#define UNIT_SYS 2
#define UNIT_EXT 3
#define UNIT_MAX 3

#define UNIT_USE_PRM  '!' /* use primitive unit */
#define UNIT_USE_CFG  '-' /* use same unit as config */

/***_* End definitions */
#endif  /* not _OVCONF_H */
/***_! FOOTER */
