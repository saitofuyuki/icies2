dnl movement/mutests.m4 --- Template for Definition for IcIES/Movement TEST modules
dnl Maintainer:  SAITO Fuyuki
dnl Created: Oct 2 2015
m4_define([TIME_STAMP],
          ['Time-stamp: <2020/09/15 12:16:05 fuyuki mutests.m4>'])dnl
C movement/mutests.h --- Definition for IcIES/Movement TEST modules
C Maintainer:  SAITO Fuyuki
C Created: Oct 2 2015
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#ifdef HEADER_PROPERTY
[#]define _TSTAMP TIME_STAMP
#define _FNAME 'movement/mutests.h'
#define _REV   'Snoopy0.9'
#endif /* HEADER_PROPERTY */
CCC_! MANIFESTO
C
C Copyright (C) 2015--2020
C           Japan Agency for Marine-Earth Science and Technology,
C           Ayako ABE-OUCHI
C
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
CCC_* Definitions
#ifndef    _MUTEST_H
#  define  _MUTEST_H

CCC_ + Test configuration
CCC_  * [IMTI] parameter (SIA)
c_reset([IMTI])
c_xincr([CONFIG],  [configuration/general])
c_xincr([CFG_MASK],[configuration/mask])
c_xincr([CFG_VB],  [configuration/basal velocity])
c_xincr([CFG_R],   [configuration/bedrock])
c_xincr([CFG_MS],  [configuration/surface mass balance])
c_xincr([CFG_TS],  [configuration/surface temperature])
c_xincr([CFG_TB],  [configuration/bottom temperature])
c_xincr([CFG_H],   [configuration/thickness])
c_xincr([CFG_MBSH],[configuration/shelf-base mass balance])
c_xincr([CFG_VMSK],[configuration/velocity mask])
c_xkeep([MAX])

CCC_  * [PMTI] parameter (SIA)
c_reset([PMTI])
c_xincr([ACC],   [constant accumulation])
c_xincr([RFC],   [constant rate factor])
c_xincr([HINI],  [initial thickness])
c_xincr([TINI],  [initial temperature])
c_xincr([CVB],   [basal velocity coefficient])
c_xincr([EVB],   [basal velocity exponent (shear stress)])
c_xincr([DVB],   [basal velocity exponent (loading)])
c_xincr([BDRGC], [Basal drag coefficient])
c_xincr([BDRGP], [Basal drag power])
c_xincr([RA],    [bedrock amplitude])
c_xincr([RXL],   [bedrock scale length])
c_xincr([RYL],   [bedrock scale length])
c_xincr([RXO],   [bedrock summit location])
c_xincr([RYO],   [bedrock summit location])
c_xincr([SLV],   [background sea level])

c_xincr([BDDIVD], [obase: ref. bedrock elevation at divide])
c_xincr([BDOCEN], [obase: ref. bedrock elevation at end])
c_xincr([BDREFL], [obase: reference scale length])

c_xkeep([MAX])

CCC_  * [PMTS] parameter (movement/SSA)
c_reset([PMTS])
c_xincr([RFC], [constant rate factor])
c_xincr([HGL], [thickness at grounding line])
c_xincr([HCF], [thickness at calving front])
c_xincr([LX],  [lateral width x])
c_xincr([LY],  [lateral width y])
c_xincr([VGL], [velocity at grounding line])
c_xincr([DGL], [grounding line position (2d)])
c_xincr([DX],  [dx for u computation])
c_xincr([BDRGC], [Basal drag coefficient])
c_xincr([BDRGP], [Basal drag power])

c_xkeep([MAX])

CCC_* End definitions
#endif  /* _MUTEST_H */
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
