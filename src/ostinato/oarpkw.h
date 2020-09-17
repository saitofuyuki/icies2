/* ostinato/oarpkw.h --- Ostinato/Arpeggio/Kiwi definitions */
/* Maintainer:  SAITO Fuyuki */
/* Created: Oct 27 2011 */
#ifdef HEADER_PROPERTY
#define _TSTAMP 'Time-stamp: <2020/09/17 08:37:57 fuyuki oarpkw.h>'
#define _FNAME 'ostinato/oarpkw.h'
#define _REV   'Arpeggio 1.0'
#endif /* HEADER_PROPERTY */
/***_! MANIFESTO */
/* Copyright (C) 2011--2020 */
/*           Japan Agency for Marine-Earth Science and Technology */
/* Licensed under the Apache License, Version 2.0 */
/*   (https://www.apache.org/licenses/LICENSE-2.0) */
/***_* Definitions */
#ifndef    _OARPKW_H
#  define  _OARPKW_H
/***_ + operation properties */
/***_  * for MPI */
#define KWC_IRS 1  /* clone source */
#define KWC_IRD 2  /* clone dist */
#define KWC_TPS 3  /* derived type (source) */
#define KWC_TPD 4  /* derived type (dist) */
#define KWC_NBS 5  /* counts of derived type (source) */
#define KWC_NBD 6  /* counts of derived type (dist) */
#define KWC_CWS 7  /* clone width S */
#define KWC_CWW 8  /* clone width W */
#define KWC_CWE 9  /* clone width E */
#define KWC_CWN 10 /* clone width N */
#define KWC_MAX 10
/***_  * for matrix */
#define KWI_OFC 11 /* offset (clone source) */
#define KWI_OFI 12 /* offset (internal) */
#define KWI_LC0 13 /* loop start (clone) */
#define KWI_LC9 14 /* loop end (clone) */
#define KWI_LCS 15 /* loop step (clone) */
#define KWI_LI0 16 /* loop start (internal) */
#define KWI_LI9 17 /* loop end (internal) */
#define KWI_LIS 18 /* loop step (internal) */
#define KWI_KWO 19 /* kind-index of weight:O */
#define KWI_KWA 20 /* kind-index of weight:A */
/***_  * misc switch */
#define KWI_SW0 21 /* arbitrary switch 0 */
/***_  * for declaration */
#define KWI_FLG 22 /* declaration flag */
#define KWI_MAX 22
/***_ + clone properties */
#define KWCP_OPR 1 /* input: operation id */
#define KWCP_MSW 2 /* input: operation switch */
#define KWCP_CID 3 /* output: corresponding clone index */
#define KWCP_MAX 3
/***_ + clone group attribute cluster */
#define KWCG_NOP 1 /* number of operations */
#define KWCG_NGR 2 /* number of clones */
#define KWCG_OFS 3 /* offset for clone */
/***_  * operation attributes */
#define KWCG_KOP(JOP) 4+(JOP-1)*3
#define KWCG_KSW(JOP) 5+(JOP-1)*3
#define KWCG_GID(JOP) 6+(JOP-1)*3
/***_  * group attributes */
#define KWCG_IRS(IPCG,JGR) 4+IPCG(KWCG_NOP)*3+(JGR-1)*4
#define KWCG_IRD(IPCG,JGR) 5+IPCG(KWCG_NOP)*3+(JGR-1)*4
#define KWCG_TPS(IPCG,JGR) 6+IPCG(KWCG_NOP)*3+(JGR-1)*4
#define KWCG_TPD(IPCG,JGR) 7+IPCG(KWCG_NOP)*3+(JGR-1)*4
/***_  * declaration helper */
#define KWCG_DECL(NOP) (3*NOP+4*NOP+3)
/***_ + matrix switch */
#define KWM_M    0  /* normal */
#define KWM_T    1  /* transpose */
#define KWM_BOTH 2  /* both (used only for declaration) */
#define KWM_DECL KWM_M:KWM_T
/***_ + Operation id */
/***_  - Gradient */
#define KWO_GXab     1
#define KWO_GXba     2
#define KWO_GXcd     3
#define KWO_GXdc     4

#define KWO_GYac     5
#define KWO_GYca     6
#define KWO_GYbd     7
#define KWO_GYdb     8

/***_  * Divergence */
#define KWO_DXab     9
#define KWO_DXba     10
#define KWO_DXcd     11
#define KWO_DXdc     12

#define KWO_DYac     13
#define KWO_DYca     14
#define KWO_DYbd     15
#define KWO_DYdb     16

/***_  * Linear interpolation */
#define KWO_Lab      17
#define KWO_Lba      18
#define KWO_Lcd      19
#define KWO_Ldc      20
#define KWO_Lac      21
#define KWO_Lca      22
#define KWO_Lbd      23
#define KWO_Ldb      24

/***_  * Exchange overlapped */
#define KWO_EWo      25
#define KWO_WEo      26
#define KWO_SNo      27
#define KWO_NSo      28
#define KWO_EWi      29
#define KWO_WEi      30
#define KWO_SNi      31
#define KWO_NSi      32

/***_  * Simple addition */
#define KWO_SAab     33
#define KWO_SAba     34
#define KWO_SAcd     35
#define KWO_SAdc     36
#define KWO_SAac     37
#define KWO_SAca     38
#define KWO_SAbd     39
#define KWO_SAdb     40

/***_  * Simple subtraction */
#define KWO_SDab     41
#define KWO_SDba     42
#define KWO_SDcd     43
#define KWO_SDdc     44
#define KWO_SDac     45
#define KWO_SDca     46
#define KWO_SDbd     47
#define KWO_SDdb     48

/***_  * Full clone */
#define KWO_FCab     49
#define KWO_FCba     50
#define KWO_FCcd     51
#define KWO_FCdc     52
#define KWO_FCac     53
#define KWO_FCca     54
#define KWO_FCbd     55
#define KWO_FCdb     56

/***_  * User def 0 */
#define KWO_U0ab     57
#define KWO_U0ba     58
#define KWO_U0cd     59
#define KWO_U0dc     60
#define KWO_U0ac     61
#define KWO_U0ca     62
#define KWO_U0bd     63
#define KWO_U0db     64

/***_  * User def 1 */
#define KWO_U1ab     65
#define KWO_U1ba     66
#define KWO_U1cd     67
#define KWO_U1dc     68
#define KWO_U1ac     69
#define KWO_U1ca     70
#define KWO_U1bd     71
#define KWO_U1db     72

/***_  * User def 2 */
#define KWO_U2ab     73
#define KWO_U2ba     74
#define KWO_U2cd     75
#define KWO_U2dc     76
#define KWO_U2ac     77
#define KWO_U2ca     78
#define KWO_U2bd     79
#define KWO_U2db     80

#define KWO2_MAX 80

/***_  * Derivative (for coordinates transfomation) */
#define KWO_XXa      81
#define KWO_XXb      82
#define KWO_XXc      83
#define KWO_XXd      84

#define KWO_YYa      85
#define KWO_YYb      86
#define KWO_YYc      87
#define KWO_YYd      88

#define KWO_XYa      89
#define KWO_XYb      90
#define KWO_XYc      91
#define KWO_XYd      92

#define KWO_YXa      93
#define KWO_YXb      94
#define KWO_YXc      95
#define KWO_YXd      96

/***_  * Coordinates */
#define KWO_Xa       97
#define KWO_Xb       98
#define KWO_Xc       99
#define KWO_Xd       100

#define KWO_Ya       101
#define KWO_Yb       102
#define KWO_Yc       103
#define KWO_Yd       104

/***_  * Size */
#define KWO_dXa      105
#define KWO_dXb      106
#define KWO_dXc      107
#define KWO_dXd      108

#define KWO_dYa      109
#define KWO_dYb      110
#define KWO_dYc      111
#define KWO_dYd      112

/***_  * Odd field mask */
#define KWO_ZXa      113
#define KWO_ZXb      114
#define KWO_ZXc      115
#define KWO_ZXd      116

#define KWO_ZYa      117
#define KWO_ZYb      118
#define KWO_ZYc      119
#define KWO_ZYd      120

/***_  * Area */
#define KWO_Aa       121
#define KWO_Ab       122
#define KWO_Ac       123
#define KWO_Ad       124

/***_  * Wing mask */
#define KWO_MWa      125
#define KWO_MWb      126
#define KWO_MWc      127
#define KWO_MWd      128

/***_  * Exchange wings */
#define KWO_HEW      129
#define KWO_HWE      130
#define KWO_HSN      131
#define KWO_HNS      132

#define KWO1_MAX 132

/***_  * Meta-info */
#define KWO_MIO      133
#define KWO_MIA      134

#define KWO_MAX 134

#define IPKW_FULL_DECL KWI_MAX,KWO_MAX,KWM_DECL
/***_* End definitions */
#endif  /* not _OARPKW_H */
/***_! FOOTER */
