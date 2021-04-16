C movement/mutests.h --- Definition for IcIES/Movement TEST modules
C Maintainer:  SAITO Fuyuki
C Created: Oct 2 2015
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#ifdef HEADER_PROPERTY
#define _TSTAMP 'Time-stamp: <2020/09/15 12:16:05 fuyuki mutests.m4>'
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
CCC_  * IMTI parameter (SIA)

#define IMTI_CONFIG      1   /* configuration/general */
#define IMTI_CFG_MASK    2   /* configuration/mask */
#define IMTI_CFG_VB      3   /* configuration/basal velocity */
#define IMTI_CFG_R       4   /* configuration/bedrock */
#define IMTI_CFG_MS      5   /* configuration/surface mass balance */
#define IMTI_CFG_TS      6   /* configuration/surface temperature */
#define IMTI_CFG_TB      7   /* configuration/bottom temperature */
#define IMTI_CFG_H       8   /* configuration/thickness */
#define IMTI_CFG_MBSH    9   /* configuration/shelf-base mass balance */
#define IMTI_CFG_VMSK   10   /* configuration/velocity mask */
#define IMTI_MAX        10   /*  kept */

CCC_  * PMTI parameter (SIA)

#define PMTI_ACC         1   /* constant accumulation */
#define PMTI_RFC         2   /* constant rate factor */
#define PMTI_HINI        3   /* initial thickness */
#define PMTI_TINI        4   /* initial temperature */
#define PMTI_CVB         5   /* basal velocity coefficient */
#define PMTI_EVB         6   /* basal velocity exponent (shear stress) */
#define PMTI_DVB         7   /* basal velocity exponent (loading) */
#define PMTI_BDRGC       8   /* Basal drag coefficient */
#define PMTI_BDRGP       9   /* Basal drag power */
#define PMTI_RA         10   /* bedrock amplitude */
#define PMTI_RXL        11   /* bedrock scale length */
#define PMTI_RYL        12   /* bedrock scale length */
#define PMTI_RXO        13   /* bedrock summit location */
#define PMTI_RYO        14   /* bedrock summit location */
#define PMTI_SLV        15   /* background sea level */

#define PMTI_BDDIVD     16   /* obase: ref. bedrock elevation at divide */
#define PMTI_BDOCEN     17   /* obase: ref. bedrock elevation at end */
#define PMTI_BDREFL     18   /* obase: reference scale length */

#define PMTI_MAX        18   /*  kept */

CCC_  * PMTS parameter (movement/SSA)

#define PMTS_RFC         1   /* constant rate factor */
#define PMTS_HGL         2   /* thickness at grounding line */
#define PMTS_HCF         3   /* thickness at calving front */
#define PMTS_LX          4   /* lateral width x */
#define PMTS_LY          5   /* lateral width y */
#define PMTS_VGL         6   /* velocity at grounding line */
#define PMTS_DGL         7   /* grounding line position (2d) */
#define PMTS_DX          8   /* dx for u computation */
#define PMTS_BDRGC       9   /* Basal drag coefficient */
#define PMTS_BDRGP      10   /* Basal drag power */

#define PMTS_MAX        10   /*  kept */

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
