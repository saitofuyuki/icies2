/* ostinato/ofugca.h --- IcIES/Ostinato/Fugue common attribute definitions */
/* Author: SAITO Fuyuki */
/* Created: Aug 20 2013 */
#ifdef HEADER_PROPERTY
#define _TSTAMP 'Time-stamp: <2020/09/17 08:32:11 fuyuki ofugca.h>'
#define _FNAME 'ostinato/ofugca.h'
#define _REV   'Snoopy0.97'
#endif /* HEADER_PROPERTY */
/***_! MANIFESTO */
/* Copyright (C) 2013--2020 */
/*           Japan Agency for Marine-Earth Science and Technology, */
/*           Ayako ABE-OUCHI */
/* Licensed under the Apache License, Version 2.0  */
/*   (https://www.apache.org/licenses/LICENSE-2.0) */
/***_* Definitions */
#ifndef    _OFUGCA_H
#  define  _OFUGCA_H
/***_ + file output status */
#define AFSO_ERR  -1
#define AFSO_SKIP 0
#define AFSO_NEW  1
#define AFSO_REC  2
/***_ + file output switch */
#define AFSW_NEVER  -1
#define AFSW_NORMAL  0
/***_ + file input switch */
#define AFSR_NEVER  -1
#define AFSR_NORMAL  0
/***_ + file interface integer flags */
#define FAI_FLAG_MAX 6
/***_  - system macro */
#ifdef  OFUGCA_DETAIL

#  define FAI_FPI 1 /* file unit/i */
#  define FAI_FPN 2 /* file unit/n */
#  define FAI_FPL 3 /* file unit/l */
#  define FAI_FPV 4 /* file unit/v */

#  define FAI_FPSTR 'INLV'

#  define FAI_WSW 5 /* default switch/W */
#  define FAI_RSW 6 /* default switch/W */

#endif /* OFUGCA_DETAIL */
/***_* End definitions */
#endif  /* not _OFUGCA_H */
/***_* Obsolete */
/***_ + begin */
/***_ + end */
/***_! FOOTER */
