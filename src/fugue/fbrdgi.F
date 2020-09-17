C fugue/fbrdgi.F --- IcIES/Fugue/Bridge interface
C Author: SAITO Fuyuki
C Created: Aug 19 2013
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2020/09/17 06:59:38 fuyuki fbrdgi.F>'
#define _FNAME 'fugue/fbrdgi.F'
#define _REV   'Snoopy0.97'
CCC_! MANIFESTO
C
C Copyright (C) 2013--2020
C           Japan Agency for Marine-Earth Science and Technology,
C           Ayako ABE-OUCHI
C
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
CCC_* Description
CC     shape of varibable clusters:  V (L, NV, *)
CCC_* Common macros
#include "ofdlct.h" /* fortran dialect */
#include "ologfm.h" /* log common format */
#include "ofnstd.h"
#include "odevel.h"
#include "ounelv.h"
CCC_ + Buffers for grouping
#ifndef   OPT_ABRDMS_GRP_MAX
#  define OPT_ABRDMS_GRP_MAX  32
#endif
#ifndef   OPT_ABRDMS_VAR_MAX
#  define OPT_ABRDMS_VAR_MAX  512
#endif
CCC_ + Attribute cluster
CCC_  - Group/integer
#define VGI_IVS  1 /* start index */
#define VGI_NMV  2 /* number of variables */
#define VGI_M    3 /* number of items to write in a variable */
#define VGI_L    4 /* number of items in declaration */
#define VGI_COR  5 /* standard coordinate */
#define VGI_PBRD 6 /* P/bridge flag */
#define VGI_GBRD 7 /* G/bridge flag */
#define VGI_WFIL 8 /* W/file flag   */
#define VGI_RFIL 9 /* R/file flag   */
#define VGI_MAX  10
CCC_  - Group/string
#define VGA_GNM 1 /* group name */
#define VGA_CRT 2 /* root */
#define VGA_MAX 2
CCC_  - Group/real-standard
#define VGS_WSTART 1   /* W start */
#define VGS_WEND   2   /* W end   */
#define VGS_WSTEP  3   /* W step  */
#define VGS_WTREC  4   /* W current time  */
#define VGS_WNEXT  5   /* W next  */

#define VGS_RSTART 6   /* R start */
#define VGS_REND   7   /* R end   */
#define VGS_RSTEP  8   /* R step  */
#define VGS_RTREC  9   /* R current time  */
#define VGS_RNEXT  10  /* R next  */

#define VGS_MAX   10
CCC_  - Variable/integer
#define VVI_COR 1 /* coordinate id */
#define VVI_REC 2 /* record */
#define VVI_PSW 3 /* P switch */
#define VVI_GSW 4 /* G switch */
CCC_  - Buffer/integer
#define VBI_IBS    1 /* buffer start index */
#define VBI_MAX    1
CCC_  - Buffer/real-standard
#define VBS_PSTART 1 /* P start */
#define VBS_PEND   2 /* P end */
#define VBS_GCUR   3 /* G current */

#define VBS_MAX    3
CCC_ + Options
#ifndef    OPT_NAMELIST_OUTPUT_EMULATION
#  define  OPT_NAMELIST_OUTPUT_EMULATION _UNMLEM_LEVEL_END
#endif
CCC_& FBRDGI  ## IcIES/Fugue/Bridge announcement
      subroutine FBRDGI (STRA, STRB, IOP)
CCC_ + Declaration
      implicit none
      _INTENT(IN, integer)    IOP
      _INTENT(OUT,character)  STRA*(*), STRB*(*)
CCC_ + Body
      if      (IOP.eq.0) then
         STRA = _TSTAMP
         STRB = ' '
      else if (IOP.eq.1) then
         STRA = _FNAME
         STRB = ' '
      else if (IOP.eq.2) then
         STRA = _REV
         STRB =' '
      else
         STRA = ' '
         STRB = ' '
      endif
      RETURN
      END
CCC_@ FBTEST  ## Fugue/Bridge test
#if TEST_FBRDGI
      program FBTEST
CCC_ + Test suites
CC::   SOURCES
CCC_ + Declaration
#include "odevid.h"  /* MPI table */
      implicit none
      integer iErr
      integer ipA (LOG_CHANNEL_MAX)
      integer iMA (MAX_MPI_ATTR)
#define _CLS 'V'
CCC_ + Body
      call DDcapo
     O    (iErr,
     I     2, ' ', 'O', _FNAME, -1)
      if (iErr.eq.0) then
         call DLCmng (ipA, 't')
         call DVHrgC (iErr, _CLS, ' ', ' ', ipA)
      endif
      if (iErr.eq.0) then
c$$$         call AKWtma (iMA)
c$$$         call AFTESTmain (iErr, ipA, iMA)
      endif
      call DevFin (iErr)
      STOP
      END
#endif /* TEST_FBRDGI */
CCC_* obsolete
CCC_ + begin
#if 0 /* obsolete */
CCC_ + end obsolete
#endif /* 0 obsolete */
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
