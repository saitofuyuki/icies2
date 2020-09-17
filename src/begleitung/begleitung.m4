dnl begleitung/begleitung --- Template for Definition for IcIES/begleitung modules
dnl Maintainer:  SAITO Fuyuki
dnl Created: Jun 16 2018
m4_define([TIME_STAMP],
          ['Time-stamp: <2020/09/17 06:52:50 fuyuki begleitung.m4>'])dnl
C begleitung/begleitung.h --- Definition for IcIES/Begleitung modules
C Maintainer:  SAITO Fuyuki
C Created: Jun 16 2018
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#ifdef HEADER_PROPERTY
[#]define _TSTAMP TIME_STAMP
#define _FNAME 'begleitung/begleitung.h'
#define _REV   'Snoopy0.97'
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
CCC_  * [VGRPB]
c_reset([VGRPB])
c_xincr([VBBI])
c_xincr([VBBT])
c_xincr([VBBW])

c_xkeep([MAX])

CCC_ + Parameter cluster
CCC_  * [PBB] Begleitung/bedrock temperature
c_reset([PBB])
c_xincr([DENSR], [rock density])
c_xincr([CONDR], [rock heat conductivity coeff])
c_xincr([HCAPR], [rock heat capatity coeff])
c_xkeep([MAX])

CCC_  * [IBB] Begleitung/bedrock temperature
c_reset([IBB])
c_xincr([DUMMY], [dummy])

c_xkeep([MAX])

CCC_  * [VBBI] input field 2d
c_reset([VBBI])
c_xincr([TU],   [Tu],                      [Tu],  [a])
c_xincr([HR] ,  [HR],                      [hR],  [a])
c_xincr([GH],   [geothermal heat flux],    [gh],  [a])
c_xincr([W],    [work],                    [W],   [a])
c_xkeep([MAX])

CCC_  * [VBBT] 3d to remember
c_reset([VBBT])
c_xincr([T],     [Temperature],                 [T],    [aa])
c_xkeep([MAX])

CCC_  * [VBBW] 3d others
c_reset([VBBW])

c_xincr([QD],   [matrix d],                     [qd],   [aa])
c_xincr([QU],   [matrix u],                     [qu],   [aa])
c_xincr([QL],   [matrix l],                     [ql],   [aa])
c_xincr([QB],   [matrix b],                     [qb],   [aa])

CC assumption: B11 B22  == 0

c_xincr([E1],   [coeff E1],   [E1],  [aa])
c_xincr([E2],   [coeff E2],   [E2],  [aa])
c_xincr([E3p],  [coeff E3p],  [E3p], [aa])
c_xincr([E3m],  [coeff E3m],  [E3m], [aa])
c_xincr([E33],  [coeff E33],  [E33], [aa])

c_xincr([W1],   [work],      [W1],   [aa])
c_xincr([W2],   [work],      [W2],   [aa])
c_xincr([W3x],  [work],      [W3x],  [aa])
c_xincr([W3y],  [work],      [W3y],  [aa])
c_xincr([W4],   [work],      [W4],   [aa])
c_xincr([W5],   [work],      [W5],   [aa])

c_xkeep([MAX])

CCC_  * [VBBZ] Velocity and others input 1d vertical
c_reset([VBBZ])
c_xincr([Za],     [Zeta],              [Z],    [za])
c_xincr([Zb],     [Zeta],              [Z],    [zb])
c_xincr([dZa],    [dZeta],             [dZ],   [za])
c_xincr([dZb],    [dZeta],             [dZ],   [zb])
c_xincr([cZa],    [1 - Zeta:a],        [cZ],   [za])

c_xincr([dWPb],   [first derivative weights], [dWPb],  [zb])
c_xincr([dWMb],   [first derivative weights], [dWMb],  [zb])
c_xincr([ddWPa],  [second derivative weights],[ddWPb], [za])
c_xincr([ddWOa],  [second derivative weights],[ddWOb], [za])
c_xincr([ddWMa],  [second derivative weights],[ddWMb], [za])

c_xincr([dXa],    [transformation factor],  [dXa],  [za])
c_xincr([ddXa],   [transformation factor],  [ddXa], [za])

c_xkeep([MAX])

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
