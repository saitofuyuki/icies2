/* ostinato/odevva.h --- Definition for IcIES/Development/VIO */
/* Maintainer:  SAITO Fuyuki */
/* Created: Jan 20 2012 */
#ifdef HEADER_PROPERTY
#define _TSTAMP 'Time-stamp: <2020/09/17 08:48:00 fuyuki odevva.h>'
#define _FNAME 'ostinato/odevva.h'
#define _REV   'Snoopy0.97'
#endif /* HEADER_PROPERTY */
/***_! MANIFESTO */
/* Copyright (C) 2010--2020 */
/*           Japan Agency for Marine-Earth Science and Technology */
/*           Ayako ABE-OUCHI */
/* Licensed under the Apache License, Version 2.0 */
/*   (https://www.apache.org/licenses/LICENSE-2.0) */

/***_* Definitions */
#ifndef    _ODEVVA_H
#  define  _ODEVVA_H

#include "odevel.h"
#include "olimit.h"
/***_* Error */
#define VIO_ERR_NO_UNIT   -31
#define VIO_ERR_NO_RECORD -33 /* no record on direct mode */
#define VIO_ERR_EOF       64  /* end of file */
/***_* arbitrary ID for access report */
#define VIO_ACCESS_ID_MAX  4
/* #define INFO_NAN (_INT_MIN) */
#define INFO_NAN (-_INT_MAX) /* gfortran 4.6 bug? */
/***_* Attributes cluster */
#define VIO_UNIT 1  /* file unit */
#define VIO_RECI 2  /* record (phisical) index */
#define VIO_LOGI 3  /* record (logical) index */
#define VIO_RECC 4  /* record (phisical) count */
#define VIO_LOGC 5  /* record (logical) count */
#define VIO_RLEN 6  /* record length */
#define VIO_RBYT 7  /* record length in bytes */
#define VIO_CINT 8  /* close/open interval */
#define VIO_CSTP 9  /* close/open steps */
#define VIO_PACT 10 /* action */
#define VIO_FORM 11 /* form */
#define VIO_PLCX 12 /* policy when exists */
#define VIO_PLCN 13 /* policy when not exists */
#define VIO_PLCU 14 /* policy for open/close */
#define VIO_ULOG 15 /* log unit */
#define VIO_UNRP 16 /* report unit (namelist form) */
#define VIO_IMPI 17 /* mpi rank */
#define VIO_NMPI 18 /* mpi size */
#define VIO_COMM 19 /* mpi communicator */
#define VIO_NRLG 20 /* report unit log */

#define VIO_KPOLICY_MAX 20

/***_* Policies */
#define VIO_ACTION_UNKNOWN      0
#define VIO_ACTION_READ         1
#define VIO_ACTION_WRITE        2
#define VIO_ACTION_RW           3

#define VIO_FORM_UNFORMATTED    0
#define VIO_FORM_FORMATTED      1
/***_ + when exists */
#define VIO_POLICY_X_ERR        0
#define VIO_POLICY_X_CLOBBER    1
#define VIO_POLICY_X_OVERWRITE  2
#define VIO_POLICY_X_APPEND     3
#define VIO_POLICY_X_IGNORE     4
/***_ + when not exists */
#define VIO_POLICY_N_ERR        0
#define VIO_POLICY_N_CREATE     1
#define VIO_POLICY_N_IGNORE     2
/***_ + open/close timing */
#define VIO_POLICY_U_COMMON     0
#define VIO_POLICY_U_FREE       1
#define VIO_POLICY_U_BLACK      2
#define VIO_POLICY_U_OPEN       3
/***_ + length adjustment */
#define VIO_POLICY_L_ERR        0
#define VIO_POLICY_L_EXTENSION  1
#define VIO_POLICY_L_SHRINKAGE  2
#define VIO_POLICY_L_COMMON     3
#define VIO_POLICY_L_OLD        4
/***_* String policy cluster */
/***_ + format string (not stored in the cluster) */
#define VIO_FORMAT_MAX    64
/***_ + open clause id */
#define VIO_CLAUSE_SIZE   4

#define VIO_CLAUSE_FORM(P)   P(1:1)
#define VIO_CLAUSE_ACTION(P) P(2:2)
#define VIO_CLAUSE_STATUS(P) P(3:3)
#define VIO_CLAUSE_POS(P)    P(4:4)

#define VIO_CLAUSE_FIRST(P)  P(1:4)
#define VIO_CLAUSE_LATER(P)  P(5:8)
/* 1:4 first open  5:8 second and later open */
/***_ + report tag (obsolete/reserved) */
#define VIO_REPORT(P)     P(VIO_REPORT_STT:VIO_REPORT_END)
#define VIO_REPORT_STT  10
#define VIO_REPORT_END  31
#define VIO_REPORT_MAX  VIO_REPORT_END-VIO_REPORT_STT+1
/***_ + file name */
#define VIO_FILENAME(P)   P(VIO_FILENAME_STT:VIO_FILENAME_END)
#define VIO_FILENAME_STT  33
#define VIO_FILENAME_END  VIO_SPOLICY_LEN

#define VIO_SPOLICY_LEN   OPT_FILENAME_MAX+VIO_FILENAME_STT-1
/***_* Tag/Value types */
#define KTYPE_SYSTEM  0
#define KTYPE_UNDEF   1
/***_ + separators */
#define KTYPE_SEP    -1
#define KTYPE_GROUP  -9
/***_* End definitions */
#endif  /* not _ODEVVA_H */
/***_! FOOTER */
