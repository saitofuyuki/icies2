C ostinato/ofugca.h --- IcIES/Ostinato/Fugue common attribute definitions
C Author: SAITO Fuyuki
C Created: Aug 20 2013
#ifdef HEADER_PROPERTY
#define _TSTAMP 'Time-stamp: <2020/09/15 12:10:51 fuyuki ofugca.h>'
#define _FNAME 'ostinato/ofugca.h'
#define _REV   'Snoopy0.9'
#endif /* HEADER_PROPERTY */
CCC_! MANIFESTO
C
C Copyright (C) 2013--2020
C           Japan Agency for Marine-Earth Science and Technology,
C           Ayako ABE-OUCHI
C
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
CCC_* Definitions
#ifndef    _OFUGCA_H
#  define  _OFUGCA_H
CCC_ + file output status
#define AFSO_ERR  -1
#define AFSO_SKIP 0
#define AFSO_NEW  1
#define AFSO_REC  2
CCC_ + file output switch
#define AFSW_NEVER  -1
#define AFSW_NORMAL  0
CCC_ + file input switch
#define AFSR_NEVER  -1
#define AFSR_NORMAL  0
CCC_ + file interface integer flags
#define FAI_FLAG_MAX 6
CCC_  - system macro
#ifdef  OFUGCA_DETAIL

#  define FAI_FPI 1 /* file unit/i */
#  define FAI_FPN 2 /* file unit/n */
#  define FAI_FPL 3 /* file unit/l */
#  define FAI_FPV 4 /* file unit/v */

#  define FAI_FPSTR 'INLV'

#  define FAI_WSW 5 /* default switch/W */
#  define FAI_RSW 6 /* default switch/W */

#endif /* OFUGCA_DETAIL */
CCC_* End definitions
#endif  /* _OFUGCA_H */
CCC_* Obsolete
CCC_ + begin
CCC_ + end
CCC_! FOOTER
C Local Variables:
C mode: fortran
C fff-style: "iciesShermy"
C End:
