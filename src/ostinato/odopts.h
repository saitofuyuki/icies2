/* ostinato/odopts.h --- Definition for option/parameter configuration macros */
/* Maintainer:  SAITO Fuyuki */
/* Created: Nov 19 2019 */
/* Copyright (C) 2019--2020 */
/*           Japan Agency for Marine-Earth Science and Technology, */
/*           Ayako ABE-OUCHI */
/* Licensed under the Apache License, Version 2.0  */
/*   (https://www.apache.org/licenses/LICENSE-2.0) */
#if       HEADER_PROPERTY
#define _TSTAMP 'Time-stamp: <2020/01/07 15:31:11 fuyuki odopts.h>'
#define _FNAME 'ostinato/odopts.h'
#define _REV   'Snoopy0.97'
#endif /* HEADER_PROPERTY */

#ifndef    _ODOPTS_H
#  define  _ODOPTS_H

/* bitwise flag */
#define DOPTS_LEVEL_MATCH_TAG     1  /* require match with tag  */
#define DOPTS_LEVEL_MATCH_ROOT    2  /* require match with root */
#define DOPTS_LEVEL_MATCH_STRICT  3  /* require match with both root and tag (alias) */
#define DOPTS_LEVEL_ALLOW_NULL    4  /* allow null/default setting */

#endif /* not _ODOPTS_H */
