/* ostinato/oarpfi.h --- Ostinato/Arpeggio/File interface definitions */
/* Maintainer:  SAITO Fuyuki */
/* Created: Apr 9 2012 */
#ifdef HEADER_PROPERTY
#define _TSTAMP 'Time-stamp: <2020/09/17 08:34:45 fuyuki oarpfi.h>'
#define _FNAME 'ostinato/oarpfi.h'
#define _REV   'Arpeggio 1.0'
#endif /* HEADER_PROPERTY */
/***_! MANIFESTO */
/* Copyright (C) 2012--2020 */
/*           Japan Agency for Marine-Earth Science and Technology */
/* Licensed under the Apache License, Version 2.0  */
/*   (https://www.apache.org/licenses/LICENSE-2.0) */
/***_* Definitions */
#ifndef    _OARPFI_H
#  define  _OARPFI_H
/***_ + file output status */
#define AFSO_ERR  -1
#define AFSO_SKIP 0
#define AFSO_NEW  1
#define AFSO_REC  2
/***_ + file output switch */
#define AFSW_NEVER  -9
#define AFSW_QUIET  -1  /* can be enabled */
#define AFSW_NORMAL  0
/***_ + file input switch */
#define AFSR_NEVER  -1
#define AFSR_NORMAL  0
/***_ + file interface integer flags */
#define AFI_FLAG_MAX 5
/***_  - system macro */
#ifdef  OARPFI_DETAIL

#  define AFI_FPI 1 /* file unit/i */
#  define AFI_FPN 2 /* file unit/n */
#  define AFI_FPL 3 /* file unit/l */
#  define AFI_FPV 4 /* file unit/v */

#  define AFI_FPSTR 'INLV'

#  define AFI_KSW 5 /* default switch */

#endif /* OARPFI_DETAIL */
/***_* End definitions */
#endif  /* not _OARPFI_H */
/***_* Obsolete */
/***_ + begin */
/***_ + end */
/***_! FOOTER */
