/* ostinato/oarpgc.h --- Ostinato/Arpeggio/Geometry category */
/* Maintainer:  SAITO Fuyuki */
/* Created: Oct 30 2012 */
#ifdef HEADER_PROPERTY
#define _TSTAMP 'Time-stamp: <2020/09/17 08:34:57 fuyuki oarpgc.h>'
#define _FNAME 'ostinato/oarpgc.h'
#define _REV   'Arpeggio 1.0'
#endif /* HEADER_PROPERTY */
/***_! MANIFESTO */
/* Copyright (C) 2012--2020 */
/*           Japan Agency for Marine-Earth Science and Technology */
/* Licensed under the Apache License, Version 2.0 */
/*   (https://www.apache.org/licenses/LICENSE-2.0) */
/***_* Definitions */
#ifndef    _OARPGC_H
#  define  _OARPGC_H

/***_ + Index (Geometry origin type) */
#define GEOMETRY_ORIGIN_ERROR  -1
#define GEOMETRY_ORIGIN_INDEX   0
#define GEOMETRY_ORIGIN_RATIO   1
#define GEOMETRY_ORIGIN_EDGE    2
#define GEOMETRY_ORIGIN_NRATIO  3
/***_ + Index (2d Geometry type) */
#define _GZERO      -1 /* zero width */
#define _GGENERAL   0
#define _GCARTESIAN 1
#define _GSPHERICAL 2
#define _GSPHERICAL_LON 3
#define _GSPHERICAL_LAT 4
#define _GCUML          65536 /* block-cumulative coordinate */

/***_ + Parameter clusters */
/***_  - integer */
#define AGI_OTYPE 1 /* origin type */
#define AGI_UNITC 2 /* unit in configuration */
#define AGI_UNITS 3 /* unit in system */
#define AGI_UNITX 4 /* unit in files */
#define AGI_MAX   4
/***_  - real */
#define AGS_VNAN 1 /* undef value */
#define AGS_OV   2 /* origin property */
#define AGS_WN   3 /* number of elements to prescribed width, etc */
#define AGS_DW   4 /* domain width */
#define AGS_ZDL  5 /* lower boundary for d/dx == 0 */
#define AGS_ZDU  6 /* upper boundary for d/dx == 0 */
#define AGS_RXL  7 /* lower boundary for mirror symmetry */
#define AGS_RXU  8 /* upper boundary for mirror symmetry */
#define AGS_MAX  8

/***_* End definitions */
#endif  /* not _OARPGC_H */
/***_! FOOTER */
