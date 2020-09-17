C development/devel.h --- Definition for IcIES/Development modules
C Maintainer:  SAITO Fuyuki
C Created: Mar 25 2010
#ifdef HEADER_PROPERTY
#define _TSTAMP 'Time-stamp: <2013/09/30 09:51:46 fuyuki odevel.h>'
#define _FNAME 'development/devel.h'
#define _REV   'Snoopy0.9'
#endif /* HEADER_PROPERTY */
CCC_! MANIFESTO
C
C Copyright (C) 2010--2020
C           Japan Agency for Marine-Earth Science and Technology,
C           Ayako ABE-OUCHI
C
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
CCC_* Definitions
#ifndef    _DEVEL_H
#  define  _DEVEL_H

#include "odevid.h"
CCC_ + Bootstrap units assembly
#define _IDX_BOOTSTRAP_IN    1
#define _IDX_BOOTSTRAP_OUT   2
#define _IDX_BOOTSTRAP_ERR   3
#define BOOTSTRAP_IN(B)  B(_IDX_BOOTSTRAP_IN)
#define BOOTSTRAP_OUT(B) B(_IDX_BOOTSTRAP_OUT)
#define BOOTSTRAP_ERR(B) B(_IDX_BOOTSTRAP_ERR)
#define _MAX_BOOTSTRAP_UNITS 3
CCC_ + MPI attributes assembly
#define _IDX_MPI_RANK    1 /* rank */
#define _IDX_MPI_NRANKS  2 /* number of ranks */
#define _IDX_MPI_COMM    3 /* communicator */
#define _IDX_MPI_PARENT  4 /* parent communicator (NULL if WORLD) */
#define _IDX_MPI_COLOR   5 /* color */
#define _IDX_MPI_NCOLORS 6 /* number of colors */
#define _IDX_MPI_LEVEL   7 /* split level (0 if WORLD) */
#define _IDX_MPI_ERROR   8 /* last error */
#if MAX_MPI_ATTR < _IDX_MPI_ERROR
#error "INVALID MAX_MPI_ATTR (see odevid.h)"
#endif
CCC_ + Option
#ifndef DMPIMS_COLOR_NAME_LEN
#  define DMPIMS_COLOR_NAME_LEN 16
#endif
CCC_  * filename length
#ifndef   OPT_FILENAME_MAX
#  define OPT_FILENAME_MAX 2048
#endif
CCC_* End definitions
#endif  /* _DEVEL_H */
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
