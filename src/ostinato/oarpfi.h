C ostinato/oarpfi.h --- Ostinato/Arpeggio/File interface definitions
C Maintainer:  SAITO Fuyuki
C Created: Apr 9 2012
#ifdef HEADER_PROPERTY
#define _TSTAMP 'Time-stamp: <2020/09/15 12:12:08 fuyuki oarpfi.h>'
#define _FNAME 'ostinato/oarpfi.h'
#define _REV   'Arpeggio 1.0'
#endif /* HEADER_PROPERTY */
CCC_! MANIFESTO
C
C Copyright (C) 2012--2020
C           Japan Agency for Marine-Earth Science and Technology
C
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
CCC_* Definitions
#ifndef    _OARPFI_H
#  define  _OARPFI_H
CCC_ + file output status
#define AFSO_ERR  -1
#define AFSO_SKIP 0
#define AFSO_NEW  1
#define AFSO_REC  2
CCC_ + file output switch
#define AFSW_NEVER  -9
#define AFSW_QUIET  -1  /* can be enabled */
#define AFSW_NORMAL  0
CCC_ + file input switch
#define AFSR_NEVER  -1
#define AFSR_NORMAL  0
CCC_ + file interface integer flags
#define AFI_FLAG_MAX 5
CCC_  - system macro
#ifdef  OARPFI_DETAIL

#  define AFI_FPI 1 /* file unit/i */
#  define AFI_FPN 2 /* file unit/n */
#  define AFI_FPL 3 /* file unit/l */
#  define AFI_FPV 4 /* file unit/v */

#  define AFI_FPSTR 'INLV'

#  define AFI_KSW 5 /* default switch */

#endif /* OARPFI_DETAIL */
CCC_* End definitions
#endif  /* _OARPFI_H */
CCC_* Obsolete
CCC_ + begin
CCC_ + end
CCC_! FOOTER
C Local Variables:
C mode: fortran
C fff-style: "iciesShermy"
C End:
