C ostinato/ounelv.h --- IcIES/Ostinato/namelist emulation level
C Maintainer:  SAITO Fuyuki
C Created: Apr 5 2012
#ifdef HEADER_PROPERTY
#define _TSTAMP 'Time-stamp: <2020/09/15 12:11:28 fuyuki ounelv.h>'
#define _FNAME 'ostinato/ounelv.h'
#define _REV   'Snoopy0.9'
#endif /* HEADER_PROPERTY */
CCC_! MANIFESTO
C
C Copyright (C) 2012--2020
C           Japan Agency for Marine-Earth Science and Technology,
C           Ayako ABE-OUCHI
C
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
CCC_* Definitions
#ifndef    _OUNELV_H
#  define  _OUNELV_H

#  define  _UNMLEM_LEVEL_ELEMENT  3
#  define  _UNMLEM_LEVEL_ENTRY    2
#  define  _UNMLEM_LEVEL_END      1
#  ifndef  _UNMLEM_LEVEL_DEFAULT
#   define _UNMLEM_LEVEL_DEFAULT _UNMLEM_LEVEL_ENTRY
#  endif
CCC_* End definitions
#endif  /* _OUNELV_H */
CCC_! FOOTER
C Local Variables:
C mode: fortran
C fff-style: "iciesShermy"
C End:
