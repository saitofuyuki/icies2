C begleitung/begleitung.h --- Definition for IcIES/Begleitung modules
C Maintainer:  SAITO Fuyuki
C Created: Jun 16 2018
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#ifdef HEADER_PROPERTY
#define _TSTAMP 'Time-stamp: <2020/09/15 11:51:42 fuyuki begleitung.m4>'
#define _FNAME 'begleitung/begleitung.h'
#define _REV   'Snoopy0.9'
#endif /* HEADER_PROPERTY */
CCC_! MANIFESTO
C
C Copyright (C) 2018--2020
C           Japan Agency for Marine-Earth Science and Technology,
C           Ayako ABE-OUCHI
C
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
CCC_* Definitions
#ifndef    _BEGLEITUNG_H
#  define  _BEGLEITUNG_H

CCC_ + output
CCC_  * VGRPB

#define VGRPB_VBBI       1   /*  */
#define VGRPB_VBBT       2   /*  */
#define VGRPB_VBBW       3   /*  */

#define VGRPB_MAX        3   /*  kept */

CCC_ + Parameter cluster
CCC_  * PBB Begleitung/bedrock temperature

#define PBB_DENSR        1   /* rock density */
#define PBB_CONDR        2   /* rock heat conductivity coeff */
#define PBB_HCAPR        3   /* rock heat capatity coeff */
#define PBB_MAX          3   /*  kept */

CCC_  * IBB Begleitung/bedrock temperature

#define IBB_DUMMY        1   /* dummy */

#define IBB_MAX          1   /*  kept */

CCC_  * VBBI input field 2d

#define VBBI_TU          1   /* Tu */
#define VBBI_HR          2   /* HR */
#define VBBI_GH          3   /* geothermal heat flux */
#define VBBI_W           4   /* work */
#define VBBI_MAX         4   /*  kept */

CCC_  * VBBT 3d to remember

#define VBBT_T           1   /* Temperature */
#define VBBT_MAX         1   /*  kept */

CCC_  * VBBW 3d others


#define VBBW_QD          1   /* matrix d */
#define VBBW_QU          2   /* matrix u */
#define VBBW_QL          3   /* matrix l */
#define VBBW_QB          4   /* matrix b */

CC assumption: B11 B22  == 0

#define VBBW_E1          5   /* coeff E1 */
#define VBBW_E2          6   /* coeff E2 */
#define VBBW_E3p         7   /* coeff E3p */
#define VBBW_E3m         8   /* coeff E3m */
#define VBBW_E33         9   /* coeff E33 */

#define VBBW_W1         10   /* work */
#define VBBW_W2         11   /* work */
#define VBBW_W3x        12   /* work */
#define VBBW_W3y        13   /* work */
#define VBBW_W4         14   /* work */
#define VBBW_W5         15   /* work */

#define VBBW_MAX        15   /*  kept */

CCC_  * VBBZ Velocity and others input 1d vertical

#define VBBZ_Za          1   /* Zeta */
#define VBBZ_Zb          2   /* Zeta */
#define VBBZ_dZa         3   /* dZeta */
#define VBBZ_dZb         4   /* dZeta */
#define VBBZ_cZa         5   /* 1 - Zeta:a */

#define VBBZ_dWPb        6   /* first derivative weights */
#define VBBZ_dWMb        7   /* first derivative weights */
#define VBBZ_ddWPa       8   /* second derivative weights */
#define VBBZ_ddWOa       9   /* second derivative weights */
#define VBBZ_ddWMa      10   /* second derivative weights */

#define VBBZ_dXa        11   /* transformation factor */
#define VBBZ_ddXa       12   /* transformation factor */

#define VBBZ_MAX        12   /*  kept */

CCC_ + Work sizes
#ifndef   OPT_BGLBRT_LVZ_MAX /* maximum layers for velocities */
#  define OPT_BGLBRT_LVZ_MAX 66
#endif

CCC_ + Independent tests
#define BGLBRT_DV_CLS 'V'
CCC_* End definitions
#endif  /* _BEGLEITUNG_H */
CCC_* Obsolete
CCC_ + begin
#if 0 /* obsolete */
CCC_ + end
#endif /* 0 obsolete */
CCC_! FOOTER
C Local Variables:
C mode: fortran
C fff-style: "iciesShermy"
C End:
