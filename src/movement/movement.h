C movement/movement.h - Definition for IcIES/Movement modules
C Maintainer:  SAITO Fuyuki
C Created: Dec 20 2011
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#ifdef HEADER_PROPERTY
#define _TSTAMP 'Time-stamp: <2021/04/12 07:53:36 fuyuki movement.m4>'
#define _FNAME 'movement/movement.h'
#define _REV   'JosePeterson0'
#endif /* HEADER_PROPERTY */
CCC_! MANIFESTO
C
C Copyright (C) 2011-2021
C           Japan Agency for Marine-Earth Science and Technology,
C           Ayako ABE-OUCHI
C
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
CCC_* Definitions
#ifndef    _MOVEMENT_H
#  define  _MOVEMENT_H

CCC_ + options
#ifndef   MSBMOS_VARIATION
#  define MSBMOS_VARIATION 4
#endif
#ifndef   OPT_SSA_CORNER_FIXED
c$$$#  define OPT_SSA_CORNER_FIXED  0
#  define OPT_SSA_CORNER_FIXED  1
#endif

#define SSA_ADJUST_PQ_GR 0 /* adjust PQ ground mask if needed (old default) */
#define SSA_ADJUST_UV_FL 1 /* adjust UV floating mask if needed */
#ifndef    OPT_SSA_ADJUST
#  define  OPT_SSA_ADJUST SSA_ADJUST_UV_FL
#endif
CCC_ + grid category
CCC_  * integer
#define _iGR 1  /* H > 0  and b == r */
#define _iSH 2  /* H > 0  and b > r  */
#define _iBR 3  /* H == 0 and r >= 0 */
#define _iOC 4  /* H == 0 and r < 0  */
#define _iGI 5  /* H > 0, b == r one-grid island */
CCC_  * double
#define _dGR 1.d0
#define _dSH 2.d0
#define _dBR 3.d0
#define _dOC 4.d0
#define _dGI 5.d0

CCC_ + Matrix switch
CCC_  * mmxoms
#define MMXSW_DVB 0  /* D=D E=VB   */
#define MMXSW_ZEV 1  /* D=0 E=E+VB */
#define MMXSW_DE  2  /* D=D E=E    */
#define MMXSW_D00 3  /* D=D E=0 (test only) */

#define MMXSW_UP1  4  /* first-order upwind */
#define MMXSW_UPD  5  /* first-order upwind (grad div method) */
#define MMXSW_UPE  6  /* first-order upwind (grad div method, conditionally ZEV) */
c
#define MMXSW_HU_ZEV  7   /* [HCE] upwind hybrid, ZEV compatible  */
#define MMXSW_HU_UP1  8   /* [HCU] upwind hybrid, UP1 compatible, Dec(v=0) U(other)  */
#define MMXSW_HU_UPD  9   /* [HCG] upwind hybrid, UPD compatible  Dec(whole) */
#define MMXSW_HU_UPE  10  /* [HCH] upwind hybrid, UPE compatible, E(grounded) Dec(other) */

#define MMXSW_HU_0    11  /* [H0] upwind hybrid, E (grounded) U(other) */

#define MMXSW_HU_1    12  /* [H0] upwind hybrid, Dec(v=0) E  (front) U(other) */
#define MMXSW_HU_2    13  /* [H1] upwind hybrid, Dec(v=0) Dec(front) U(other) */

#define MMXSW_CIPaxP  14  /* CIP regular grid; dir. splitting; explicit; bc polynomial */
#define MMXSW_CIPaxL  15  /* CIP regular grid; dir. splitting; explicit; bc interpolated */

c

#define MMXINI_0   0 /* initial guess zero */
#define MMXINI_OLD 1 /* initial guess previous */

CCC_ + Grounding line flux computatin
#define MGLX_MATRIX    0 /* embedded in matrix           */
#define MGLX_LINEAR    1 /* update after linear part     */
#define MGLX_NONLINEAR 2 /* update after non-linear part */

CCC_ + Grounding line flux evaluation method
#define GLP_CASE_E      5
#define GLP_CASE_G      7
#ifndef OPT_GLP_CASE
#  define OPT_GLP_CASE GLP_CASE_G
#endif

CCC_ + Parameter cluster
CCC_  * PMD SIA/thickness time integration

#define PMD_DENS         1   /* ice density */
#define PMD_DENSW        2   /* water density */
#define PMD_GRAV         3   /* gravity */
#define PMD_PF           4   /* flow law exponent */

#define PMD_RGAS         5   /* rgas */
#define PMD_TM           6   /* TM */
#define PMD_QL           7   /* QL */
#define PMD_QH           8   /* QH */
#define PMD_AL           9   /* AL */
#define PMD_AH          10   /* AH */

#define PMD_FGX         11   /* gravity unit vector component */
#define PMD_FGY         12   /*  */
#define PMD_FGZ         13   /*  */
#define PMD_EFC         14   /* constant enhancement factor */
#define PMD_EFCSH       15   /* constant enhancement factor for shelf */
#define PMD_RFC         16   /* constant rate factor */
#define PMD_EPS         17   /* matrix solver epsilon */
#define PMD_ETOL        18   /* matrix solver tolerance */
#define PMD_WF          19   /* overrelaxation factor */
#define PMD_CLV         20   /* parameter for calving */
#define PMD_TCVB        21   /* minimum temperature for sliding */
#define PMD_SHH         22   /* minimum thickness to use shelfy stream */
#define PMD_DRSH        23   /* upper limit rel. to sea level to use shelfy stream */
#define PMD_RVSH        24   /* vb/vs ratio lower limit to apply shelfy stream */
#define PMD_VBLIM       25   /* basal velocity limit */

#define PMD_MAX         25   /*  kept */

CCC_  * PMT Thermodynamics

#define PMT_DENS        26   /* density */
#define PMT_T0          27   /* triple point of water */
#define PMT_COND        28   /* heat conductivity coeff */
#define PMT_CONDP       29   /* heat conductivity exponent coeff */
#define PMT_HCAP        30   /* heat capatity coeff */
#define PMT_HCAPG       31   /* heat capatity gradient */
#define PMT_CLCLD       32   /* Melting point dependence on depth */
#define PMT_TBSHC       33   /* constant bottom temperature (ice shelf) */
#define PMT_LHC         34   /* latent heat capacity of ice */
#define PMT_ADIFF       35   /* diffusion coeff for age */
#define PMT_AEPS        36   /* epsilon number for age in RCIP */
#define PMT_MAX         36   /*  kept */

CCC_  * PMS SSA diagnostic

#define PMS_DENS        37   /*  */
#define PMS_DENSW       38   /*  */
#define PMS_GRAV        39   /*  */
#define PMS_PF          40   /* flow law exponent */
#define PMS_EPS         41   /*  */
#define PMS_TOLL        42   /*  */
#define PMS_TOLNL       43   /*  */
#define PMS_OVW         44   /*  */
#define PMS_OVWFC       45   /*  */
#define PMS_DSXLIM      46   /* horizontal surface gradient upper limit */
#define PMS_VXLIML      47   /* horizontal velocity gradient lower limit */
#define PMS_VXLIMU      48   /* horizontal velocity gradient upper limit */
#define PMS_VBLIML      49   /* lower limit of basal vel. on shelfy stream */
#define PMS_VSHLIM      50   /* shelf velocity upper limit */
#define PMS_VGLLIM      51   /* grounding line velocity upper limit */
#define PMS_HGLIML      52   /* grounding line thickness lower limit */
#define PMS_UDNML       53   /* velocity denominator lower limit */
#define PMS_PDNML       54   /* PQR denominator lower limit */

#define PMS_MUI         55   /* initial guess */

#define PMS_SCH         56   /* H scale (vertical length) */
#define PMS_SCL         57   /* L scale (horizontal length) */
#define PMS_SCU         58   /* u scale (linear part) */
#define PMS_SCV         59   /* u scale (for non-linear part) */
#define PMS_SCXFSR      60   /* effective strain-rate powered scale */
#define PMS_SCA         61   /* A scale */
#define PMS_SCN         62   /* hydrostatic pressure integral scale */
#define PMS_SCD         63   /* PQR scale */
#define PMS_XSC         64   /* external v scale */
#define PMS_SclUI       65   /* U scale parameter I */
#define PMS_SclUF       66   /* U scale parameter F */
#define PMS_SclUG       67   /* U scale parameter G */
#define PMS_SclVI       68   /* V scale parameter I */
#define PMS_SclVF       69   /* V scale parameter F */
#define PMS_SclVG       70   /* V scale parameter G */
#define PMS_SclPI       71   /* P scale parameter I */
#define PMS_SclPF       72   /* P scale parameter F */
#define PMS_SclPG       73   /* P scale parameter G */
#define PMS_SclQI       74   /* Q scale parameter I */
#define PMS_SclQF       75   /* Q scale parameter F */
#define PMS_SclQG       76   /* Q scale parameter G */
#define PMS_SclRI       77   /* R scale parameter I */
#define PMS_SclRF       78   /* R scale parameter F */

#define PMS_InvUI       79   /* U scale parameter inverse I */
#define PMS_InvUF       80   /* U scale parameter inverse F */
#define PMS_InvUG       81   /* U scale parameter inverse G */
#define PMS_InvVI       82   /* V scale parameter inverse I */
#define PMS_InvVF       83   /* V scale parameter inverse F */
#define PMS_InvVG       84   /* V scale parameter inverse G */
#define PMS_InvPI       85   /* P scale parameter inverse I */
#define PMS_InvPF       86   /* P scale parameter inverse F */
#define PMS_InvPG       87   /* P scale parameter inverse G */
#define PMS_InvQI       88   /* Q scale parameter inverse I */
#define PMS_InvQF       89   /* Q scale parameter inverse F */
#define PMS_InvQG       90   /* Q scale parameter inverse G */
#define PMS_InvRI       91   /* R scale parameter inverse I */
#define PMS_InvRF       92   /* R scale parameter inverse F */

#define PMS_MAX         92   /*  kept */

CCC_  * IMD thickness time integration

#define IMD_MSW          1   /* thickness integration matrix switch */
#define IMD_MINI         2   /* thickness integration initial guess */
#define IMD_ITRMAX       3   /* maximum iteration */
#define IMD_DTTRY        4   /* maximum trial for dt adjustement */

#define IMD_RF           5   /* rate factor method switch */
#define IMD_RFI          6   /* rate factor integral method switch */
#define IMD_WI           7   /* w integral method switch */
#define IMD_TBDZ         8   /* T bottom gradient method switch */
#define IMD_UADV         9   /* horizontal advection switch */
#define IMD_WADV        10   /* vertical advection switch */
#define IMD_TGRD        11   /* Ta grid computation switch */
#define IMD_USG         12   /* u v computation method */
#define IMD_VB          13   /* sliding velocity scheme */
#define IMD_VBSW        14   /* sliding velocity switch */
#define IMD_SHSW        15   /* shelf switch */
#define IMD_DSFR        16   /* calving front surface gradient */
#define IMD_DSSE        17   /* shelf end surface gradient */
#define IMD_DHDT        18   /* dH/dt computation switch */

#define IMD_HUPD        19   /* H update */
#define IMD_TUPD        20   /* T update */
#define IMD_TZLP        21   /* Z-loop outer/inner switch in T solver */
#define IMD_STRH        22   /* strain heating switch */
#define IMD_RFPR        23   /* rate factor procedure */

#define IMD_AGEC        24   /* age computation switch */
#define IMD_ARSTT       25   /* bc age reset timing */
#define IMD_ABDZ        26   /* Age bottom gradient method switch */
#define IMD_ASDZ        27   /* Age surface gradient method switch */
#define IMD_AADVL       28   /* age advection velocity level */

#define IMD_MAX         28   /*  kept */

#define SW_RF_CONST  0  /* constant rate factor */
#define SW_RF_FLOWAR 1  /* temperature dependent rate factor (AR) */

#define SW_RFI_CONST 0  /* analytical integration (only when constant) */
#define SW_RFI_EULER 1  /* euler numerical integration */
#define SW_RFI_GG    2  /* integration with GG table */

#define SW_RFPR_INTP_FIRST 0 /* T:a to T:bc, then rate factor */
#define SW_RFPR_INTP_LAST  1 /* T:a to RF:a, integral, then interpolation  */

#define SW_WI_SNOOPY  0  /* consistent method with kinematic condition */
#define SW_WI_SALLY   1  /* sally compatible method */
#define SW_WI_UDB     2  /* snoopy compatible, but bottom bc use u grad b */

#define SW_TBDZ_FIRST   0  /* first-order difference */
#define SW_TBDZ_CENTER  1  /* second-order central difference */

#define SW_UADV_UPH    0  /* use half-grid upwind */
#define SW_UADV_SELF   1  /* use same grid */

#define SW_WADV_RAW    0  /* use raw w */
#define SW_WADV_XKB    1  /* use adjusted w with kinematic bc */

#define SW_ADVV_NORMAL    0  /* use advection normal level */
#define SW_ADVV_STAGGERED 1  /* use advection half-upwind level */

#define SW_TGRD_INTP   0  /* interpolation */
#define SW_TGRD_DRCT   1  /* direct */

#define SW_TUPD_TRUE    0  /* T update */
#define SW_TUPD_FALSE   1  /* T update false */

#define SW_HUPD_TRUE    0  /* H update */
#define SW_HUPD_FALSE   1  /* H update false */

#define SW_USG_SNOOPY    0  /* default */
#define SW_USG_SALLY     1  /* sally compatible method (old gradient) */

#define SW_VB_NONE       0  /* default */
#define SW_VB_HSFUNC     1  /* weertman scheme var h (function of topography) */
#define SW_VB_SALLY_WA   2  /* weertman scheme var a/sally (function of topography) */
#define SW_VB_TWEERTMAN  3  /* weertman scheme var b (function of basal stress) */

#define SW_VBSW_AND       0  /* sliding when left AND right melting */
#define SW_VBSW_OR        1  /* sliding when left OR  right melting */
#define SW_VBSW_SALLY_AND 2  /* sliding when left AND right melting (with thickness check) */
#define SW_VBSW_ALL       3  /* sliding all */

#define SW_SHELFY_DEF     0  /* shelf when float */
#define SW_SHELFY_ALL     1  /* shelf even when grounded */

#define SW_DSFR_ZERO     0  /* zero gradient at calving front */
#define SW_DSFR_KEEP     1  /* normal gradient */

#define SW_DSSE_NORMAL   0  /* normal gradient at shelf ends */
#define SW_DSSE_DOWN_A   1  /* downwind gradient at shelf ends */

#define SW_TZLP_OUTER    0  /* outer */
#define SW_TZLP_INNER    1  /* inner */

#define SW_DHDT_FLUX   0 /* use flux solution for dH/dt */
#define SW_DHDT_SOL    1 /* use H solution for dH/dt */

#define SW_NOCONV_FINAL   0 /* use final solution when not converged  */
#define SW_NOCONV_SMALL   1 /* use smallest-redisual solution when not converged  */

#define SW_STRH_DEFAULT 0 /* se:bc, st:bc; sh:bc;      sh:a */
#define SW_STRH_SALLY   1 /* se:bc, st:bc; se:a, st:a; sh:a */

#define SW_AGEC_OFF      0  /* age computation excluded */
#define SW_AGEC_UPWIND   1  /* age computation upwind implicit first order */
#define SW_AGEC_RCIP     2  /* age computation rcip */
#define SW_AGEC_UPWIND_X 3  /* age computation upwind explicit first order */
#define SW_AGEC_UPWIND_2 4  /* age computation upwind explicit second order */
#define SW_AGEC_RCIP_CORR 5 /* age computation rcip with upstream correction */

#define SW_AGEC_RESET_AFTER_OFF 0
#define SW_AGEC_RESET_AFTER_ON  1

#define SW_ADZ_FIRST   0  /* first-order difference */
#define SW_ADZ_CENTER  1  /* second-order central difference */

CCC_  * IMS SSA diagnostic

#define IMS_ITRL        29   /* Maximum iteration for linear part */
#define IMS_ITRLmin     30   /* Minimum iteration for linear part */
#define IMS_ITRNL       31   /* Maximum iteration for non linear part */
#define IMS_ITRGL       32   /* Maximum iteration for grounding-line flux part */
#define IMS_MINNL       33   /* Minimum iteration for non linear part */
#define IMS_TRYNL       34   /* Maximum try for non-linear part */
#define IMS_SWNOV       35   /* solution choice when not converged */
#define IMS_SWL         36   /* initial guess switch for linear part */
#define IMS_SWNL        37   /* initial guess switch for non linear part */
#define IMS_SWNLG       38   /* initial guess switch for non linear part, grounding line */
#define IMS_GLUPD       39   /* grounding-line velocity update timing */
#define IMS_GLBT        40   /* buttressing effect switch */
#define IMS_XREPL       41   /* residual report lower */
#define IMS_XREPH       42   /* residual report higher */
#define IMS_MAX         42   /*  kept */

#define SW_GLBT_DEF       0  /* buttressing effect included */
#define SW_GLBT_EXCL      1  /* buttressing effect excluded */

CCC_  * OMM

#define OMM_WITH_SIA     1   /* with SIA */
#define OMM_WITH_SSA     2   /* with SSA */
#define OMM_WITH_HUPD    3   /* with H  update */
#define OMM_WITH_TUPD    4   /* with T  update */
#define OMM_WITH_RUPD    5   /* with RF update */
#define OMM_WITH_VEL     6   /* with VEL */
#define OMM_MAX          6   /*  kept */

CCC_  * P/IMM PMD/PMS integration
#define PMM_MAX 92
#define IMM_MAX 42

CCC_ + clone group
CCC_  * CGB SIA

#define CGB_Ha           1   /*  */
#  define CGB_Ha_Lab    1
#  define CGB_Ha_Lac    2
#define CGB_Sa           2   /*  */
#  define CGB_Sa_Lab    1
#  define CGB_Sa_Lac    2
#  define CGB_Sa_GXab   3
#  define CGB_Sa_GYac   4
#define CGB_Sd           3   /*  */
#  define CGB_Sd_GXdc   1
#  define CGB_Sd_GYdb   2
#define CGB_XHaN         4   /*  */
#  define CGB_XHaN_Lab    1
#  define CGB_XHaN_Lac    2
#  define CGB_XHaN_GXab   3
#  define CGB_XHaN_GYac   4
#define CGB_XHaT         5   /*  */
#  define CGB_XHaT_DXba   1
#  define CGB_XHaT_DYca   2
#define CGB_UHaT         6   /*  */
#  define CGB_UHaT_Lba    1
#  define CGB_UHaT_Lca    2
#define CGB_MAX          6   /*  kept */

CCC_  * CGV Velocity

#define CGV_Ub           7   /*  */
#  define CGV_Ub_DXba   1
#  define CGV_Ub_Lba    2
#  define CGV_Ub_FCba   3
#define CGV_Vc           8   /*  */
#  define CGV_Vc_DYca   1
#  define CGV_Vc_Lca    2
#  define CGV_Vc_FCca   3
#define CGV_MAX          8   /*  kept */

CCC_  - CGHV Velocity/MMH

#define CGHV_Ub          9   /*  */
#  define CGHV_Ub_DXba   1
#  define CGHV_Ub_Lba    2
#  define CGHV_Ub_FCba   3
#define CGHV_Vc         10   /*  */
#  define CGHV_Vc_DYca   1
#  define CGHV_Vc_Lca    2
#  define CGHV_Vc_FCca   3
#define CGHV_MAX        10   /*  kept */

CCC_  * CGT Thermo

#define CGT_Ha          11   /*  */
#  define CGT_Ha_GXab   1
#  define CGT_Ha_GXac   2
#define CGT_Ba          12   /*  */
#  define CGT_Ba_GXab   1
#  define CGT_Ba_GXac   2
#define CGT_Ta          13   /*  */
#  define CGT_Ta_Lab    1
#  define CGT_Ta_Lac    2
#  define CGT_Ta_GXab   3
#  define CGT_Ta_GYac   4
#  define CGT_Ta_FCab   5
#  define CGT_Ta_FCac   6
#define CGT_CTB         14   /*  */
#  define CGT_CTB_FCab   1
#  define CGT_CTB_FCac   2
#define CGT_MAX         14   /*  kept */

CCC_  * CGS SSA

CCC_   + in normal operation
#define CGS_UbS         15   /*  */
#  define CGS_UbS_GXba   1
#  define CGS_UbS_GYbd   2
#define CGS_VcW         16   /*  */
#  define CGS_VcW_GYca   1
#  define CGS_VcW_GXcd   2
#define CGS_UbN         17   /*  */
#  define CGS_UbN_GXba   1
#  define CGS_UbN_GYbd   2
#define CGS_VcE         18   /*  */
#  define CGS_VcE_GYca   1
#  define CGS_VcE_GXcd   2
#define CGS_PaW         19   /*  */
#  define CGS_PaW_GXab   1
#  define CGS_PaW_Lab    2
#define CGS_QaS         20   /*  */
#  define CGS_QaS_GYac   1
#  define CGS_QaS_Lac    2
#define CGS_RdA         21   /*  */
#  define CGS_RdA_GYdb   1
#  define CGS_RdA_GXdc   2
#  define CGS_RdA_Ldb    3
#  define CGS_RdA_Ldc    4
CCC_   + in transpose operation
CCCc_clgrp(MuRd)
#define CGS_MuIPa       22   /*  */
#  define CGS_MuIPa_GXba   1
#  define CGS_MuIPa_GYca   2
#define CGS_MuIQa       23   /*  */
#  define CGS_MuIQa_GYca   1
#  define CGS_MuIQa_GXba   2
CCC_   + in non-linear part
CCCc_clgrp(URa)
#define CGS_URd         24   /*  */
#  define CGS_URd_Ldb    1
#  define CGS_URd_Ldc    2
#define CGS_UXa         25   /*  */
#  define CGS_UXa_Lab    1
#  define CGS_UXa_Lac    2
#define CGS_VYa         26   /*  */
#  define CGS_VYa_Lab    1
#  define CGS_VYa_Lac    2
#define CGS_MAX         26   /*  kept */

c$$$CCC_  - CGG SSA/Grounding line
c$$$
c$$$#define CGG_Ha          27   /*  */
#  define CGG_Ha_FCab   1
#  define CGG_Ha_FCac   2
c$$$#define CGG_Ra          28   /*  */
#  define CGG_Ra_FCab   1
#  define CGG_Ra_FCac   2
c$$$#define CGG_IKa         29   /*  */
#  define CGG_IKa_FCab   1
#  define CGG_IKa_FCac   2
c$$$#define CGG_MAX         29   /*  kept */

CCC_   + clone-group cluster
c$$$#define CGRP_MAX     29
#define CGRP_MAX     26
#define CGRP_MEM_MAX 6

CCC_ + output
CCC_  * VGRP

#define VGRP_VMI         1   /*  */
#define VGRP_VMC         2   /*  */
#define VGRP_VMID        3   /*  */
#define VGRP_VMIW        4   /*  */

#define VGRP_VMQ         5   /*  */
#define VGRP_VMX         6   /*  */

#define VGRP_VMSC        7   /*  */
#define VGRP_VMSV        8   /*  */
#define VGRP_VMSX        9   /*  */
#define VGRP_VMSN       10   /*  */
#define VGRP_VMST       11   /*  */

#define VGRP_VMSXI      12   /* SSA residual */
#define VGRP_VMSXT      13   /* SSA solution */

#define VGRP_VMHB       14   /*  */
#define VGRP_VMHR       15   /*  */
#define VGRP_VMHI       16   /*  */
#define VGRP_VMHW       17   /*  */
#define VGRP_VMTI       18   /*  */
#define VGRP_VMTW       19   /*  */

#define VGRP_VMTA       20   /*  */
#define VGRP_VMTD       21   /*  */

#define VGRP_MAX        21   /*  kept */

CCC_ + Variable cluster
CCC_  * BCGW bcg solver work (common)


#define BCGW_BB          1   /* right-hand vector */
#define BCGW_R           2   /*  */
#define BCGW_P           3   /*  */
#define BCGW_Z           4   /*  */
#define BCGW_RR          5   /*  */
#define BCGW_PP          6   /*  */
#define BCGW_ZZ          7   /*  */
#define BCGW_B1          8   /*  */
#define BCGW_XB          9   /* buffer for BCG */
#define BCGW_XX         10   /* initial guess */
#define BCGW_XH0        10   /* alias */
#define BCGW_XH1        11   /* solution history 1 */
#define BCGW_XH2        12   /* solution history 2 */
#define BCGW_XHmax      12   /*  kept */
#define BCGW_MAX        12   /*  kept */

CCC_  - BCGS bcgs (bicgstab) solver work


#define BCGS_BB          1   /* right-hand vector */
#define BCGS_R           2   /*  */
#define BCGS_P           3   /*  */
#define BCGS_S           4   /*  */
#define BCGS_RR0         5   /*  */
#define BCGS_T1          6   /*  */
#define BCGS_T2          7   /*  */
#define BCGS_T3          8   /*  */
#define BCGS_XB          9   /* buffer for BCG */
#define BCGS_XX         10   /* initial guess */
#define BCGS_XH0        10   /* alias */
#define BCGS_XH1        11   /* solution history 1 */
#define BCGS_XH2        12   /* solution history 2 */
#define BCGS_XHmax      12   /*  kept */
#define BCGS_MAX        12   /*  kept */

#define BCG_MAX 12


CCC_  * VMI input field 2d/ice


CC fix thickness == 0
#define VMI_CLa          1   /* lateral bc */

#define VMI_HH           2   /* Ice thickness begin */

#define VMI_Ha           3   /* Ice thickness */
#define VMI_Sa           4   /* Ice surface */
#define VMI_Ba           5   /* Ice base */

#define VMI_Hb           6   /* Ice thickness */
#define VMI_Sb           7   /* Ice surface */
#define VMI_Bb           8   /* Ice base */

#define VMI_Hc           9   /* Ice thickness */
#define VMI_Sc          10   /* Ice surface */
#define VMI_Bc          11   /* Ice base */

#define VMI_Hd          12   /* Ice thickness */
#define VMI_Sd          13   /* Ice surface */
#define VMI_Bd          14   /* Ice base */

CCC_   + SIA
#define VMI_RFIIb       15   /* rate factor d-n double integral */
#define VMI_RFIIc       16   /* rate factor d-n double integral */

CCC_   + SSA
#define VMI_daRFa       17   /* rate factor depth average */
ccc_xincr(daRFd,   rate factor depth average,        daRF, d)
#define VMI_daBAa       18   /* assoc. rate factor depth average */
#define VMI_daBAd       19   /* assoc. rate factor depth average */

CCC_   + sliding
#define VMI_SLDb        20   /* basal sliding switch */
#define VMI_SLDc        21   /* basal sliding switch */

#define VMI_HX          22   /* dH/dx */
#define VMI_HY          23   /* dH/dy */

#define VMI_MAX         23   /*  kept */

CCC_  * VMC topography intermediate

CCC_    * common
#define VMC_HCa          1   /* Thickness (after calving) */

#define VMC_IKa          2   /* Grid category */
#define VMC_IKb          3   /* Grid category */
#define VMC_IKc          4   /* Grid category */
#define VMC_IKd          5   /* Grid category */

#define VMC_DSXb         6   /* surface gradient x */
#define VMC_DSYb         7   /* surface gradient y */
#define VMC_DSXc         8   /* surface gradient x */
#define VMC_DSYc         9   /* surface gradient y */
#define VMC_DSXd        10   /* surface gradient x (reserved) */
#define VMC_DSYd        11   /* surface gradient y (reserved) */

#define VMC_HE          12   /* new thickness corrected */

#define VMC_NHa         13   /* next thickness */
#define VMC_NHb         14   /* next thickness */
#define VMC_NHc         15   /* next thickness */

#define VMC_NBa         16   /* next base */
#define VMC_NBb         17   /* next base */
#define VMC_NBc         18   /* next base */

#define VMC_HX          19   /* next thickness gradient */
#define VMC_HY          20   /* next thickness gradient */

CC old when floated, next otherwise
#define VMC_SXbM        21   /* next/old surface gradient x */
#define VMC_SYcM        22   /* next/old surface gradient y */
#define VMC_BXbM        23   /* next/old base gradient x */
#define VMC_BYcM        24   /* next/old base gradient y */

#define VMC_dHdtE       25   /* dH/dt corrected */

#define VMC_QXaU        26   /* CIP x a-term */
#define VMC_QXbU        27   /* CIP x b-term */
#define VMC_QXcU        28   /* CIP x c-term */
#define VMC_QXdU        29   /* CIP x d-term */
#define VMC_QXaL        30   /* CIP x a-term */
#define VMC_QXbL        31   /* CIP x b-term */
#define VMC_QXcL        32   /* CIP x c-term */
#define VMC_QXdL        33   /* CIP x d-term */

#define VMC_QYaU        34   /* CIP y a-term */
#define VMC_QYbU        35   /* CIP y b-term */
#define VMC_QYcU        36   /* CIP y c-term */
#define VMC_QYdU        37   /* CIP y d-term */
#define VMC_QYaL        38   /* CIP y a-term */
#define VMC_QYbL        39   /* CIP y b-term */
#define VMC_QYcL        40   /* CIP y c-term */
#define VMC_QYdL        41   /* CIP y d-term */

CCC_    * SSA
CCc_xincr(HSIb, HSI,   HSI, b)
CCc_xincr(HSIc, HSI,   HSI, c)
CCc_xincr(HSId, HSI,   HSI, d)

#define VMC_MAX         41   /*  kept */

CCC_  * VMQ thickness integration matrix (DE)


#define VMQ_MSK          1   /*  */
#define VMQ_DIAG         2   /*  */
#define VMQ_BB           3   /* Flux offset term */
#define VMQ_Db           4   /*  */
#define VMQ_Dc           5   /*  */
#define VMQ_Eb           6   /*  */
#define VMQ_Ec           7   /*  */

#define VMQ_MAX          7   /*  kept */

CCC_  * VMQU thickness integration matrix (U)


#define VMQU_MSK         1   /*  */
#define VMQU_DIAG        2   /*  */
#define VMQU_BB          3   /* Flux offset term */
#define VMQU_UEava       4   /*  */
#define VMQU_VEava       5   /*  */
#define VMQU_WXp         6   /*  */
#define VMQU_WXm         7   /*  */
#define VMQU_WYp         8   /*  */
#define VMQU_WYm         9   /*  */
#define VMQU_CDIV       10   /* Conditional divergence */

#define VMQU_MAX        10   /*  kept */

CCC_  - VMQZ thickness integration matrix (Z/G/UPD)


#define VMQZ_MSK         1   /*  */
#define VMQZ_DIAG        2   /*  */
#define VMQZ_BB          3   /* Flux offset term */
#define VMQZ_UEava       4   /*  */
#define VMQZ_VEava       5   /*  */
#define VMQZ_WXp         6   /*  */
#define VMQZ_WXm         7   /*  */
#define VMQZ_WYp         8   /*  */
#define VMQZ_WYm         9   /*  */
#define VMQZ_DIV        10   /*  */

#define VMQZ_MAX        10   /*  kept */

CCC_  - VMQH obsolete thickness integration matrix (H)
cc_reset(VMQH)

cc_xincr(MSK)
cc_xincr(DIAG)
cc_xincr(BB, Flux offset term)
cc_xincr(UEava)
cc_xincr(VEava)
cc_xincr(CEb, Conditional E-term)
cc_xincr(CEc)
cc_xincr(WXp)
cc_xincr(WXm)
cc_xincr(WYp)
cc_xincr(WYm)
cc_xincr(CDIV)

cc_xkeep(MAX)

CCC_  - VMQH thickness integration matrix (upwind hybrid)


#define VMQH_MSK         1   /*  */
#define VMQH_DIAG        2   /*  */
#define VMQH_BB          3   /* Flux offset term */
#define VMQH_UEava       4   /*  */
#define VMQH_VEava       5   /*  */
#define VMQH_UEavb       6   /* Conditional E-term */
#define VMQH_CEb         6   /* alias */
#define VMQH_VEavc       7   /*  */
#define VMQH_CEc         7   /* alias */
#define VMQH_xDIVu       8   /*  */
#define VMQH_CDIV        8   /* alias */
#define VMQH_yDIVv       9   /*  */
#define VMQH_WXe        10   /* Switch X/e */
#define VMQH_WXd        11   /* Switch X/df */
#define VMQH_WXp        12   /* Switch X/uf/p (or UE copy temporal) */
#define VMQH_Ucp        12   /* alias */
#define VMQH_WXm        13   /* Switch X/uf/m */
#define VMQH_WYe        14   /* Switch Y/e */
#define VMQH_WYd        15   /* Switch Y/df */
#define VMQH_WYp        16   /* Switch Y/uf/p (or VE copy temporal) */
#define VMQH_Vcp        16   /* alias */
#define VMQH_WYm        17   /* Switch Y/uf/m */
#define VMQH_xDIVv      18   /* dV/dx term */
#define VMQH_yDIVu      19   /* dU/dy term */

#define VMQH_MAX        19   /*  kept */


CCC_  - VMQUd thickness integration matrix (U/d)


#define VMQUd_MSK        1   /*  */
#define VMQUd_DIAG       2   /*  */
#define VMQUd_DQx        3   /*  */
#define VMQUd_DQy        4   /*  */
#define VMQUd_UWp        5   /*  */
#define VMQUd_UWm        6   /*  */
#define VMQUd_VWp        7   /*  */
#define VMQUd_VWm        8   /*  */

#define VMQUd_MAX        8   /*  kept */


#define VMQQ_MAX 19

CCC_  * VMID SIA diagnostic


#define VMID_BSXb        1   /* basal shear stress x */
#define VMID_BSYb        2   /* basal shear stress y */
#define VMID_BNb         3   /* basal shear stress n */
#define VMID_Db          4   /* diffusion */
#define VMID_UIavb       5   /* uiav. depth-average ui */
#define VMID_UBb         6   /* ub. basal velocity x */
#define VMID_vBSXb       7   /* basal shear stress for sliding x */

#define VMID_BSXc        8   /* basal shear stress x */
#define VMID_BSYc        9   /* basal shear stress y */
#define VMID_BNc        10   /* basal shear stress n */
#define VMID_Dc         11   /* diffusion */
#define VMID_VIavc      12   /* viav. depth-average vi */
#define VMID_VBc        13   /* vb. basal velocity y */
#define VMID_vBSYc      14   /* basal shear stress for sliding y */

#define VMID_MAX        14   /*  kept */

CCC_  * VMIW work/SIA


#define VMIW_W1          1   /* work */
#define VMIW_W2          2   /* work */
#define VMIW_W3          3   /* work */
#define VMIW_W4          4   /* work */
#define VMIW_W5          5   /* work */
#define VMIW_W6          6   /* work */
#define VMIW_W7          7   /* work */

#define VMIW_MAX         7   /*  kept */

CCC_  * VMSX SSA diagnostic (13 N elements)


#define VMSX_PaE         1   /* P:a to E */
#define VMSX_PaW         2   /* P:a to W */
#define VMSX_QaN         3   /* Q:a to N */
#define VMSX_QaS         4   /* Q:a to S */
#define VMSX_UbN         5   /* u:b to N */
#define VMSX_UbS         6   /* u:b to S */
#define VMSX_VcE         7   /* v:c to E */
#define VMSX_VcW         8   /* v:c to W */
#define VMSX_RdA         9   /* R:d */
#define VMSX_PaN        10   /* P:a to N */
#define VMSX_PaS        11   /* P:a to S */
#define VMSX_QaE        12   /* Q:a to E */
#define VMSX_QaW        13   /* Q:a to W */

#define VMSX_MAX        13   /*  kept */

CCC_  * VMSC Coefficients (constant within non-linear solver)


CCC_   + I series (bool if interior)
#define VMSC_Da_MI       1   /* D:a    1 if interior */
#define VMSC_I0          1   /* alias */
#define VMSC_PaE_MI      1   /*  kept */
#define VMSC_PaW_MI      1   /* alias */
#define VMSC_PaN_MI      1   /* alias */
#define VMSC_PaS_MI      1   /* alias */
#define VMSC_QaE_MI      1   /* alias */
#define VMSC_QaW_MI      1   /* alias */
#define VMSC_QaN_MI      1   /* alias */
#define VMSC_QaS_MI      1   /* alias */
#define VMSC_Ub_MI       2   /* u:b    1 if interior */
#define VMSC_UbN_MI      2   /* alias */
#define VMSC_UbS_MI      2   /* alias */
#define VMSC_Vc_MI       3   /* v:c    1 if interior */
#define VMSC_VcE_MI      3   /* alias */
#define VMSC_VcW_MI      3   /* alias */
#define VMSC_Rd_MI       4   /* R:d    1 if interior */
#define VMSC_I9          4   /* alias */

#define VMSC_BVIa        5   /* assoc. rate factor integral */
#define VMSC_BVId        6   /* assoc. rate factor integral */

CCC_   + F series (bool if fixed)
#define VMSC_UbN_MF      7   /* u:b (N) 1 if fixed */
#define VMSC_F0          7   /* alias */
#define VMSC_UbS_MF      8   /* u:b (S) 1 if fixed */
#define VMSC_VcE_MF      9   /* v:c (E) 1 if fixed */
#define VMSC_VcW_MF     10   /* v:c (W) 1 if fixed */

#define VMSC_PaE_MF     11   /* P:a (E) 1 if fixed */
#define VMSC_PaW_MF     12   /* P:a (W) 1 if fixed */
#define VMSC_QaN_MF     13   /* Q:a (N) 1 if fixed */
#define VMSC_QaS_MF     14   /* Q:a (S) 1 if fixed */

#define VMSC_PaN_MF     15   /* P:a (N) 1 if fixed */
#define VMSC_PaS_MF     16   /* P:a (S) 1 if fixed */
#define VMSC_QaE_MF     17   /* Q:a (E) 1 if fixed */
#define VMSC_QaW_MF     18   /* Q:a (W) 1 if fixed */

#define VMSC_RdA_MF     19   /* R:d (A) 1 if fixed */
#define VMSC_F9         19   /* alias */

CCC_   + G series (bool if ghost)
#define VMSC_UbN_MG     20   /* u:b (N) 1 if ghost */
#define VMSC_G0         20   /* alias */
#define VMSC_UbS_MG     21   /* u:b (S) 1 if ghost */
#define VMSC_VcE_MG     22   /* v:c (E) 1 if ghost */
#define VMSC_VcW_MG     23   /* v:c (W) 1 if ghost */

#define VMSC_PaE_MG     24   /* P:a (E) 1 if ghost */
#define VMSC_PaW_MG     25   /* P:a (W) 1 if ghost */
#define VMSC_QaN_MG     26   /* Q:a (N) 1 if ghost */
#define VMSC_QaS_MG     27   /* Q:a (S) 1 if ghost */

#define VMSC_PaN_MG     28   /* P:a (N) 1 if ghost */
#define VMSC_PaS_MG     29   /* P:a (S) 1 if ghost */
#define VMSC_QaE_MG     30   /* Q:a (E) 1 if ghost */
#define VMSC_QaW_MG     31   /* Q:a (W) 1 if ghost */
#define VMSC_G9         31   /* alias */

CCC_   + L series
#define VMSC_QbHe       32   /* Q:b coeff. QaW e */
#define VMSC_PbHe       32   /* alias */
#define VMSC_L0         32   /* alias */
#define VMSC_QbHw       33   /* Q:b coeff. QaE w */
#define VMSC_PbHw       33   /* alias */
#define VMSC_QbNe       34   /* Q:b coeff. QaN e */
#define VMSC_PbNe       34   /* alias */
#define VMSC_QbNw       35   /* Q:b coeff. QaN w */
#define VMSC_PbNw       35   /* alias */
#define VMSC_QbSe       36   /* Q:b coeff. QaS e */
#define VMSC_PbSe       36   /* alias */
#define VMSC_QbSw       37   /* Q:b coeff. QaS w */
#define VMSC_PbSw       37   /* alias */

#define VMSC_PcVn       38   /* P:c coeff. PaS n */
#define VMSC_QcVn       38   /* alias */
#define VMSC_PcVs       39   /* P:c coeff. PaN s */
#define VMSC_QcVs       39   /* alias */
#define VMSC_PcEn       40   /* P:c coeff. PaE n */
#define VMSC_QcEn       40   /* alias */
#define VMSC_PcEs       41   /* P:c coeff. PaE s */
#define VMSC_QcEs       41   /* alias */
#define VMSC_PcWn       42   /* P:c coeff. PaW n */
#define VMSC_QcWn       42   /* alias */
#define VMSC_PcWs       43   /* P:c coeff. PaW s */
#define VMSC_QcWs       43   /* alias */
#define VMSC_L9         43   /* alias */

CCC_   + N series
#define VMSC_NdX        44   /* Nx:d */
#define VMSC_N0         44   /* alias */
#define VMSC_NdY        45   /* Ny:d */
#define VMSC_NbX        46   /* Nx:b */
#define VMSC_NbY        47   /* Ny:b */
#define VMSC_NcX        48   /* Nx:c */
#define VMSC_NcY        49   /* Ny:c */

#define VMSC_NdXXY      50   /* Nx:d Nx:d Ny:d */
#define VMSC_NdYXX      50   /* alias */
#define VMSC_NdXYX      50   /* alias */
#define VMSC_NdYYX      51   /* Ny:d Ny:d Nx:d */
#define VMSC_NdXYY      51   /* alias */
#define VMSC_NdYXY      51   /* alias */
CCc_xincr(NdXY, NdYX, Nx:d Ny:d,   NxNy, d)

#define VMSC_NbXX       52   /* Nx:b Nx:b */
#define VMSC_NbYY       53   /* Ny:b Ny:b */
#define VMSC_NbXY       54   /* Nx:b Ny:b */
#define VMSC_NbYX       54   /* alias */
#define VMSC_NcYY       55   /* Ny:c Ny:c */
#define VMSC_NcXX       56   /* Nx:c Nx:c */
#define VMSC_NcYX       57   /* Ny:c Nx:c */
#define VMSC_NcXY       57   /* alias */
#define VMSC_N9         57   /* alias */

CCC_   + D series (switch ddx)
#define VMSC_DxSwEb     58   /* Switch ddxE:b */
#define VMSC_D0         58   /* alias */
#define VMSC_DxSwWb     59   /* Switch ddxW:b */
#define VMSC_DySwNc     60   /* Switch ddyN:c */
#define VMSC_DySwSc     61   /* Switch ddyS:c */

#define VMSC_DxSwEd     62   /* Switch ddxE:d */
#define VMSC_DxSwWd     63   /* Switch ddxW:d */
#define VMSC_DySwNd     64   /* Switch ddyN:d */
#define VMSC_DySwSd     65   /* Switch ddyS:d */
#define VMSC_D9         65   /* alias */

CCC_   + C series (switch corner)
#define VMSC_CxSwNb     66   /* Switch Corner x:N:b */
#define VMSC_C0         66   /* alias */
#define VMSC_CySwNb     67   /* Switch Corner y:N:b */
#define VMSC_CxSwSb     68   /* Switch Corner x:S:b */
#define VMSC_CySwSb     69   /* Switch Corner y:S:b */

#define VMSC_CxSwEc     70   /* Switch Corner x:E:c */
#define VMSC_CySwEc     71   /* Switch Corner y:E:c */
#define VMSC_CxSwWc     72   /* Switch Corner x:W:c */
#define VMSC_CySwWc     73   /* Switch Corner y:W:c */
#define VMSC_C9         73   /* alias */

#define VMSC_MAX        73   /*  kept */

CCC_  * VMSV Variable coefficients (update after linear solver)


#define VMSV_fsrp        1   /* effective strain rate powered */
ccc_xincr(fsrpd,  effective strain rate powered, fsrp, d)
#define VMSV_URa         2   /* dudy+dvdx:a */
#define VMSV_UXa         3   /* dudx:a */
#define VMSV_VYa         4   /* dvdy:a */

#define VMSV_MUa         5   /* mu:a interior */
#define VMSV_MUd         6   /* mu:d */
#define VMSV_MUaN        7   /* mu:a to N */
#define VMSV_MUaS        8   /* mu:a to S */
#define VMSV_MUaE        9   /* mu:a to E */
#define VMSV_MUaW       10   /* mu:a to W */

#define VMSV_MUa0       11   /* mu:a buffer */
#define VMSV_MUd0       12   /* mu:d */
#define VMSV_MUa1       13   /* mu:a buffer */
#define VMSV_MUd1       14   /* mu:d */

#define VMSV_BDb        15   /* Basal drag visc. */
#define VMSV_BDc        16   /* Basal drag visc. */

CCC_   + GL series (grounding line flux)
#define VMSV_UGb_MI     17   /* Grounding line replacement flag */
#define VMSV_GL0        17   /* alias */
#define VMSV_VGc_MI     18   /* Grounding line replacement flag */
#define VMSV_UGb        19   /* Grounding line replacement vel */
#define VMSV_VGc        20   /* Grounding line replacement vel */

#define VMSV_Hglb       21   /* Grounding line thickness */
#define VMSV_Hglc       22   /* Grounding line thickness */
#define VMSV_Dglb       23   /* Grounding line direction */
#define VMSV_Dglc       24   /* Grounding line direction */
#define VMSV_Qglb       25   /* Grounding line flux */
#define VMSV_Qglc       26   /* Grounding line flux */
#define VMSV_BIglb      27   /* Grounding line BI */
#define VMSV_BIglc      28   /* Grounding line BI */
#define VMSV_CCglb      29   /* Grounding line C coeff */
#define VMSV_CCglc      30   /* Grounding line C coeff */
#define VMSV_CPglb      31   /* Grounding line C exponent */
#define VMSV_CPglc      32   /* Grounding line C exponent */
#define VMSV_WQgb       33   /* Grounding line weight */
#define VMSV_WQlb       34   /* Grounding line weight */
#define VMSV_WQob       34   /* alias */
#define VMSV_WQub       35   /* Grounding line weight */
#define VMSV_WQcb       35   /* alias */
#define VMSV_WQgc       36   /* Grounding line weight */
#define VMSV_WQlc       37   /* Grounding line weight */
#define VMSV_WQoc       37   /* alias */
#define VMSV_WQuc       38   /* Grounding line weight */
#define VMSV_WQcc       38   /* alias */
#define VMSV_WTglEb     39   /* Grounding line weight T */
#define VMSV_WTglWb     40   /* Grounding line weight T */
#define VMSV_WTglNc     41   /* Grounding line weight T */
#define VMSV_WTglSc     42   /* Grounding line weight T */
#define VMSV_Btrb       43   /* Buttressing ratio */
#define VMSV_Btrc       44   /* Buttressing ratio */
#define VMSV_Xglb       45   /* Grounding line position */
#define VMSV_Yglc       46   /* Grounding line position */
#define VMSV_GL9        46   /* alias */

#define VMSV_MAX        46   /*  kept */

CCC_  * VMSN work/SSA/normal operation


#define VMSN_B1          1   /* any */
#define VMSN_B2          2   /* any */
#define VMSN_B3          3   /* any */
#define VMSN_B4          4   /* any */

#define VMSN_MiPXRY      5   /* Mi (dP/dx+dR/dy) */
#define VMSN_MiQYRX      5   /* Mi (dQ/dy+dR/dx) kept */
#define VMSN_PIa         5   /* mu (4du/dx + 2dv/dy) kept */
#define VMSN_QIa         5   /* mu (2du/dx + 4dv/dy) kept */

#define VMSN_NxRd        6   /* Nx:d R:d */
#define VMSN_NyRd        7   /* Ny:d R:d */
#define VMSN_NPNRb       7   /* Nx P + Ny R b kept */
#define VMSN_NQNRc       7   /* Ny Q + Nx R c kept */
#define VMSN_NQNRb       7   /* Ny Q + Nx R b kept */
#define VMSN_NPNRc       7   /* Nx P + Ny R c kept */

#define VMSN_SwPbH       8   /* P:b from P:a (EW) corner/wall */
#define VMSN_SwQcV       8   /* alias */
#define VMSN_SwQbH       9   /* Q:b from Q:a (EW) corner/wall */
#define VMSN_SwPcV       9   /* alias */

#define VMSN_SumDUDXa   10   /* sum du/dx:a */
#define VMSN_SumDVDYa   11   /* sum dv/dy:a */
#define VMSN_DUDXaN     12   /* du/dx:a */
#define VMSN_DUDXaS     13   /* du/dx:a */
#define VMSN_DVDYaE     14   /* dv/dy:a */
#define VMSN_DVDYaW     15   /* dv/dy:a */

#define VMSN_Rb         16   /* R:b */
#define VMSN_Rc         16   /* R:c kept */

#define VMSN_MAX        16   /*  kept */

CCC_  * VMST work/SSA/transpose operation


#define VMST_B1          1   /* any */
#define VMST_B2          2   /* any */
#define VMST_B3          3   /* any */
#define VMST_B4          4   /* any */

#define VMST_MuIPa       5   /* mu I sum P:a */
#define VMST_MuIQa       6   /* mu I sum Q:a */

#define VMST_SumCxGU     7   /* n Cx G UNS */
#define VMST_SumCxGV     8   /* nnn Cx G VEW */

#define VMST_SumCyGV     9   /* n Cy G VEW */
#define VMST_SumCyGU    10   /* nnn Cy G UNS */

#define VMST_IGPN       11   /* (I+G) PN */
#define VMST_IGPS       12   /* (I+G) PS */
#define VMST_IGQE       13   /* (I+G) QE */
#define VMST_IGQW       14   /* (I+G) QW */

#define VMST_MuIRd      15   /* mu I R:d */

#define VMST_Iuu        16   /* mask.I sum U:b */
#define VMST_SumMuIPQ   16   /* alias */
#define VMST_MiSumUb    16   /* alias */
#define VMST_Ivv        17   /* mask.I sum V:b */
#define VMST_MiSumVc    17   /* alias */

#define VMST_GSumPa     18   /* (G P + Shift G P) */
#define VMST_GSumQa     19   /* (G Q + Shift G Q) */

#define VMST_nGSumPa    20   /* n (G P + Shift G P) */
#define VMST_nGSumQa    20   /* alias */

#define VMST_nCGUN      21   /* n shift C G UN */
#define VMST_nCGUS      22   /* n shift C G US */
#define VMST_nCGVE      23   /* n shift C G VE */
#define VMST_nCGVW      24   /* n shift C G VW */

#define VMST_LnCGU      25   /* L SumCGU */
#define VMST_LnCGV      25   /* alias */

cc_xincr(NGVE,     n:d       mask.G[vE] v[E]:c,  NGVu)
cc_xkeep(NGUN,     n:d       mask.G[uN] u[S]:b)
c
cc_xincr(NGVW,     n:d Shift mask.G[vW] v[W]:c,  NGVl)
cc_xkeep(NGUS,     n:d Shift mask.G[uS] u[N]:b)
c
cc_xincr(LTNGV,    T(L){NGVW,NGVE},              LNG)
cc_xkeep(LTNGU,    T(L){NGUS,NGUN})
c
cc_xincr(SumNyMgPh, ny (Mg P + Shift Mg P),      NGPh)
cc_xincr(SumNyMgPv, ny (Mg P + Shift Mg P),      NGPv)
cc_xincr(SumNxMgQh, nx (Mg Q + Shift Mg Q),      NGQh)
cc_xincr(SumNxMgQv, nx (Mg Q + Shift Mg Q),      NGQv)
#define VMST_MAX        25   /*  kept */

CCC_  * VMSZ work/SSA/non-linear


#define VMSZ_B1          1   /* any */
#define VMSZ_B2          2   /* any */

#define VMSZ_UXaN        3   /* dudxN:a */
#define VMSZ_Vb          3   /*  kept */
#define VMSZ_Uc          3   /* alias */
#define VMSZ_UXaS        4   /* dudxS:a */
#define VMSZ_UXaE        5   /* dudxE:a */
#define VMSZ_UXaW        6   /* dudxW:a */
#define VMSZ_VYaN        7   /* dvdyN:a */
#define VMSZ_VYaS        8   /* dvdyS:a */
#define VMSZ_VYaE        9   /* dvdyE:a */
#define VMSZ_VYaW       10   /* dvdyW:a */

ccc_xincr(URa,   dudy+dvdx:a, ur, a)
#define VMSZ_URb        11   /* dudy+dvdx:b */
#define VMSZ_URc        12   /* dudy+dvdx:c */
#define VMSZ_URd        13   /* dudy+dvdx:d */

ccc_xincr(UXa,   dudx:a, ux, a)
#define VMSZ_UXb        14   /* dudx:b */
#define VMSZ_UXc        15   /* dudx:c */
#define VMSZ_UXd        16   /* dudx:d */

ccc_xincr(VYa,   dvdy:a, vy, a)
#define VMSZ_VYb        17   /* dvdy:b */
#define VMSZ_VYc        18   /* dvdy:c */
#define VMSZ_VYd        19   /* dvdy:d */

#define VMSZ_MAX        19   /*  kept */

CCC_  * VMSG work/grounding-line

#define VMSG_IFGa        1   /* Float or not */
#define VMSG_IFGb        2   /* Float or not */
#define VMSG_IFGc        3   /* Float or not */
#define VMSG_PTN         4   /* pattern */
#define VMSG_PTNp        5   /* pattern +1 */
#define VMSG_PTNm        6   /* pattern -1 */
#define VMSG_PTNpp       7   /* pattern +2 */
#define VMSG_PTNmm       8   /* pattern -2 */

#define VMSG_CRFI        9   /* clone RFI */
#define VMSG_CH         10   /* clone H */
#define VMSG_CR         11   /* clone R */
#define VMSG_CSL        12   /* clone SLV */
#define VMSG_CCc        13   /* clone Cc */
#define VMSG_CCp        14   /* clone Cp */

#define VMSG_WDF        15   /* work dir flag */

#define VMSG_Hgi        16   /* Hg inside */
#define VMSG_Xrgi       17   /* Xrg inside */
#define VMSG_LRFi       18   /* LRF inside */
#define VMSG_Hgo        19   /* Hg outside */
#define VMSG_Xrgo       20   /* Xrg outside */
#define VMSG_LRFo       21   /* LRF outside */

#define VMSG_CHg        22   /* Clone Hgo */
#define VMSG_CXrg       23   /* Clone Xrgo */
#define VMSG_CLRF       24   /* Clone LRFI */
#define VMSG_CIK        25   /*  */
#define VMSG_CWDF       26   /* clone work dir flag */

c$$$#define VMSG_Qo         27   /* flux 0 */
c$$$#define VMSG_Qm         28   /* flux -1 */
c$$$#define VMSG_Qp         29   /* flux +1 */
c$$$#define VMSG_RWo        30   /* result weight 0 */
c$$$#define VMSG_RWm        31   /* result weight -1 */
c$$$#define VMSG_RWp        32   /* result weight +1 */

#define VMSG_MAX        32   /*  kept */

CCC_  * VMSE extrapolation coefficients/SSA


#define VMSE_Ebab        1   /*  E b a */
#define VMSE_Ebaa        2   /*  E  b a */
#define VMSE_abWa        3   /* a b  W */
#define VMSE_abWb        4   /*  a b W */
#define VMSE_Ncac        5   /*  N c a */
#define VMSE_Ncaa        6   /*  N  c a */
#define VMSE_acSa        7   /* a c  S */
#define VMSE_acSc        8   /*  a c S */

#define VMSE_MAX         8   /*  kept */

CCC_  * VMVZ Velocity and others input 1d vertical

#define VMVZ_Za          1   /* Zeta */
#define VMVZ_Zb          2   /* Zeta */
#define VMVZ_dZa         3   /* dZeta */
#define VMVZ_dZb         4   /* dZeta */
#define VMVZ_cZa         5   /* 1 - Zeta:a */
#define VMVZ_cZaN        6   /* 1 - Zeta:a n power */

#define VMVZ_dPb         7   /* dPb */
#define VMVZ_dWPb        8   /* first derivative weights */
#define VMVZ_dWMb        9   /* first derivative weights */
#define VMVZ_ddWPa      10   /* second derivative weights */
#define VMVZ_ddWOa      11   /* second derivative weights */
#define VMVZ_ddWMa      12   /* second derivative weights */

#define VMVZ_dXa        13   /* transformation factor */
#define VMVZ_ddXa       14   /* transformation factor */
#define VMVZ_iddXa      15   /* transformation factor */

#define VMVZ_Lap        16   /* interpolation factor p */
#define VMVZ_Lam        17   /* interpolation factor m */

#define VMVZ_Lbp        18   /* interpolation factor p */
#define VMVZ_Lbm        19   /* interpolation factor m */

#define VMVZ_MAX        19   /*  kept */

CCC_  * VMTI 3d to remember

#define VMTI_T           1   /* Temperature */
#define VMTI_EF          2   /* Enhancement factor */

#define VMTI_Wadv        3   /* wadv */
#define VMTI_Uadv        4   /* uadv */
#define VMTI_Vadv        5   /* vadv */

#define VMTI_dwdZ        6   /* dw/dzeta */
#define VMTI_dudZ        7   /* du/dzeta */
#define VMTI_dvdZ        8   /* dv/dzeta */

#define VMTI_WHa         9   /* wh. wb:wi hybrid */
#define VMTI_UHa        10   /* uh. ub:ui hybrid */
#define VMTI_VHa        11   /* vh. vb:vi hybrid */

#define VMTI_UHb        12   /* uh. ub:ui hybrid */
#define VMTI_VHc        13   /* vh. vb:vi hybrid */

#define VMTI_dTdXb      14   /* dT/dX */
#define VMTI_dTdYc      15   /* dT/dY */

#define VMTI_sh         16   /* strain heating */

#define VMTI_MAX        16   /*  kept */

CCC_  * VMTW 3d others


#define VMTW_RFb         1   /* Rate factor */
#define VMTW_RFIb        2   /* Rate factor d-n integral */
#define VMTW_RFIIb       3   /* Rate factor d-n double integral */

#define VMTW_RFc         4   /* Rate factor */
#define VMTW_RFIc        5   /* Rate factor d-n integral */
#define VMTW_RFIIc       6   /* Rate factor d-n double integral */

#define VMTW_ARFa        7   /* Associate enh.rate factor */
#define VMTW_ARFd        8   /* Associate enh.rate factor */

#define VMTW_divHziue    9   /* -P1:  div H zeta int dzeta ue; div H ub */
#define VMTW_ugradz     10   /* P2+3: ue grad z; ub grad b */

cc_xincr(uigradb,  ubgradb, P2: ui grad b; ub grad b,              uhgradb,  aa)
cc_xincr(zuegradH, usgrads, P3: ue zeta grad H; ue(s) grad s,      zuegradH, aa)

#define VMTW_divuh      11   /* P0: div ui;   div ub */
cc_xincr(divziuh,           P0: div ziUI; div ub,                divziuh,aa)

C     Notes: on case DVB, ziUI are diffusion-like terms,
C     i.e., ziUI grad H == int ui d zeta
#define VMTW_ziUIb      12   /* int ui d zeta (ub bottom) or D(zeta) */
#define VMTW_ziDIb      12   /* alias */
#define VMTW_ziVIc      13   /* int vi d zeta (vb bottom) or D(zeta) */
#define VMTW_ziDIc      13   /* alias */

#define VMTW_EFb        14   /* Enhancement factor */
#define VMTW_EFc        15   /* Enhancement factor */
#define VMTW_EFd        16   /* Enhancement factor */

#define VMTW_SXZb       17   /* Shear stress xz */
#define VMTW_EXZb       18   /* Shear strain-rate xz */
#define VMTW_SYZc       19   /* Shear stress yz */
#define VMTW_EYZc       20   /* Shear strain-rate yz */

#define VMTW_SXZa       21   /* Shear stress xz */
#define VMTW_SYZa       22   /* Shear stress yz */
#define VMTW_EXZa       23   /* Shear strain-rate xz */
#define VMTW_EYZa       24   /* Shear strain-rate yz */

#define VMTW_SXXa       25   /* stress xx */
#define VMTW_SYYa       26   /* stress yy */
#define VMTW_SXYa       27   /* stress xy */
#define VMTW_EXXa       28   /* strain-rate xx */
#define VMTW_EYYa       29   /* strain-rate yy */
#define VMTW_EXYa       30   /* strain-rate xy */

#define VMTW_dudZ       31   /* dudZ */
#define VMTW_dvdZ       32   /* dvdZ */

#define VMTW_MAXD       32   /*  kept */

#define VMTW_QD         33   /* matrix d */
#define VMTW_QU         34   /* matrix u */
#define VMTW_QL         35   /* matrix l */
#define VMTW_QB         36   /* matrix b */

CC assumption: B11 B22  == 0

#define VMTW_E1         37   /* coeff E1 */
#define VMTW_E2         38   /* coeff E2 */
#define VMTW_E3p        39   /* coeff E3p */
#define VMTW_E3m        40   /* coeff E3m */
#define VMTW_E33        41   /* coeff E33 */

#define VMTW_HS         42   /* HS */

CCc_xincr(dZdt,  dZ/dt,                       dZdt, aa)
CCc_xincr(dZdx,  dZ/dx,                       dZdx, aa)
CCc_xincr(dZdy,  dZ/dy,                       dZdy, aa)

#define VMTW_dTdXa      43   /* dT/dX */
#define VMTW_dTdYa      44   /* dT/dY */

#define VMTW_kti        45   /* thermal conductivity */
#define VMTW_dktidz     46   /* thermal conductivity dZ */
#define VMTW_hcap       47   /* heat capacity */

#define VMTW_W1         48   /* work */
#define VMTW_W2         49   /* work */
#define VMTW_W3x        50   /* work */
#define VMTW_W3y        51   /* work */
#define VMTW_W4         52   /* work */
#define VMTW_W5         53   /* work */

cc_xincr(DIVHziui, ubGRADS, P1:  div H int ui dzeta,  divHziui, aa)
cc_xkeep(DIVHziue,          PP1: div H int ue dzeta,  divHziue, aa)
cc_xincr(uiGRADZ,  ubGRADB, P2:  ui grad Z,           uigradZ,  aa)
cc_xkeep(uiGRADB,           PP2: ui grad b,           uigradb, aa)
cc_xincr(DIVuh,             P3:  div uh (div ui:div ub), divuh,   aa)
cc_xkeep(zueGRADH,          PP3: zeta ue grad H,         zuegradH,aa)

cc_xincr(xDIVuh,  xdiv uh, xdivuh, aa)
cc_xincr(yDIVuh,  ydiv uh, ydivuh, aa)

cc_xincr(DIVuh,   div uh,  divuh,  aa)

cc_xincr(xDIVzuh,  xdiv z uh + H uii, xdivzuh, aa)
cc_xincr(yDIVzuh,  ydiv z uh + H uii, ydivzuh, aa)
cc_xincr(DIVzuh,   div z uh,          divzuh,  aa)

cc_xincr(xDIVuii,  xdiv H uii, xdivuii, aa)
cc_xincr(yDIVuii,  ydiv H uii, ydivuii, aa)
cc_xincr(DIVuii,   div  H uii, divuii,  aa)

cc_xincr(HUHIb, H ui integral,         Huhi,ba)
cc_xincr(HVHIc, H vi integral,         Hvhi,ca)
cc_xincr(ZUHb,  z ui,                  zuh, ba)
cc_xkeep(UHINb)
cc_xincr(ZVHc,  z vi,                  zvh, ca)
cc_xkeep(VHINc)

#define VMTW_MAX        53   /*  kept */

CCC_  - VMTA 3d age


#define VMTA_age         1   /* age */
#define VMTA_dad3        2   /* dage/dC3 */
#define VMTA_dad1        3   /* dage/dC1 */
#define VMTA_dad2        4   /* dage/dC2 */
#define VMTA_dadz        5   /* dage/dz */

CCc_xincr(Wadv,    wadv,                    wadv,   aa)
CCc_xincr(Uadv,    uadv,                    uadv,   aa)
CCc_xincr(Vadv,    vadv,                    vadv,   aa)
#define VMTA_MAX         5   /*  kept */

CCC_  - VMTD 3d age others


#define VMTD_QD          1   /* matrix d */
#define VMTD_QU          2   /* matrix u */
#define VMTD_QL          3   /* matrix l */
#define VMTD_QB          4   /* matrix b */

CC assumption: B11 B22  == 0

#define VMTD_E1          5   /* coeff E1 */
#define VMTD_E2          6   /* coeff E2 */
#define VMTD_E3p         7   /* coeff E3p */
#define VMTD_w3adv       7   /* alias */
#define VMTD_E3m         8   /* coeff E3m */
#define VMTD_dw3d3       8   /* alias */
#define VMTD_E33         9   /* coeff E33 */

#define VMTD_dAswp      10   /* dad3 switch p */
#define VMTD_dAswm      11   /* dad3 switch m */

#define VMTD_kai        12   /* age diffusivity */

#define VMTD_W1         13   /* work */
#define VMTD_W2         14   /* work */

#define VMTD_a2         15   /* A2 coeff in RCIP numer */
#define VMTD_a3         16   /* A3 coeff in RCIP numer */
#define VMTD_ba         17   /* B alpha in RCIP denom */

#define VMTD_cfl        18   /* CFL number */
#define VMTD_udt        19   /* upstream distance */

#define VMTD_MAX        19   /*  kept */


CCC_  - VMHR 2d boundary condition references

#define VMHR_REFMS       1   /* Surface mass balance ref */
#define VMHR_REFTS       2   /* Surface temperature ref */
#define VMHR_MAX         2   /*  kept */

CCC_  * VMHB Topography and others (2d, boundary condition)


#define VMHB_TMBa        1   /* Net mass balance */
#define VMHB_MS          2   /* Surface mass balance */
#define VMHB_MB          3   /* Basal mass balance */

#define VMHB_TSI         4   /* Ts */
#define VMHB_TBI         5   /* basal temperature */
#define VMHB_GH          6   /* geothermal heat flux */
#define VMHB_TBFLG       7   /* Bottom temp. flag */

#define VMHB_Ra          8   /* Bedrock topography */
#define VMHB_Rb          9   /* Bedrock topography */
#define VMHB_Rc         10   /* Bedrock topography */
#define VMHB_Rd         11   /* Bedrock topography */

#define VMHB_NRa        12   /* Bedrock topography next */
#define VMHB_NRb        13   /* Bedrock topography next */
#define VMHB_NRc        14   /* Bedrock topography next */

#define VMHB_NRXb       15   /* dr/dx new */
#define VMHB_NRYc       16   /* dr/dy new */
#define VMHB_RXb        17   /* dr/dx old */
#define VMHB_RYc        18   /* dr/dy old */

#define VMHB_SLVa       19   /* sea level */
#define VMHB_SLVb       20   /* sea level */
#define VMHB_SLVc       21   /* sea level */
#define VMHB_SLVd       22   /* sea level */

#define VMHB_LMSK       23   /* Land mask */

#define VMHB_UMSKb      24   /* U mask */
#define VMHB_VMSKc      25   /* V mask */

#define VMHB_CVBb       26   /* VB coefficient (shear stress) */
#define VMHB_CVBc       27   /* VB coefficient (shear stress) */
#define VMHB_EVBb       28   /* VB exponent (shear stress) */
#define VMHB_EVBc       29   /* VB expontnt (shear stress) */
#define VMHB_DVBb       30   /* VB exponent (loading) */
#define VMHB_DVBc       31   /* VB expontnt (loading) */

#define VMHB_FVBb       32   /* VB coefficient (velocity) */
#define VMHB_FVBc       33   /* VB coefficient (velocity) */
#define VMHB_GVBb       34   /* VB exponent (velocity) */
#define VMHB_GVBc       35   /* VB exponent (velocity) */

#define VMHB_GLO        36   /* longitude */
#define VMHB_GLA        37   /* latitude */

#define VMHB_MAX        37   /*  kept */

CCC_  * VMHI Topography and others (2d to remember)


#define VMHI_oHa         1   /* Ice thickness (old) */
#define VMHI_oBa         2   /* Ice base      (old) */
#define VMHI_oSa         3   /* Ice surface   (old) */

#define VMHI_oHXa        4   /* dH/dx (old) */
#define VMHI_oHYa        5   /* dH/dy (old) */

#define VMHI_nHa         6   /* Ice thickness (new) */
#define VMHI_nBa         7   /* Ice base      (new) */
#define VMHI_nSa         8   /* Ice surface   (new) */

#define VMHI_ADVXe       9   /* advection switch xe */
#define VMHI_ADVXw      10   /* advection switch xw */

#define VMHI_ADVYn      11   /* advection switch yn */
#define VMHI_ADVYs      12   /* advection switch ys */

#define VMHI_frd        13   /* frictional dissipation (not heating) */
#define VMHI_bm         14   /* basal melting */

#define VMHI_MAX        14   /*  kept */

CCC_  * VMHW Temperature and others (2d)


#define VMHW_Hinv        1   /* Hinv */

CCCc_xincr(dZdz,  dZ/dz,                       dZdz, a)
#define VMHW_dHdt        2   /* dH/dt */
#define VMHW_dBdt        3   /* db/dt */

#define VMHW_dHdx        4   /* dH/dx */
#define VMHW_dBdx        5   /* db/dx */
#define VMHW_dHdy        6   /* dH/dy */
#define VMHW_dBdy        7   /* db/dy */

#define VMHW_HSB         8   /* HSB */

#define VMHW_W1          9   /* work */
#define VMHW_W2         10   /* work */
#define VMHW_W3         11   /* work */

#define VMHW_MAX        11   /*  kept */

CCC_  * category table


#define ICTG_GLBL        1   /* global profile domains */

#define ICTG_MAX         1   /*  kept */

CCC_  * global profiles


#define GPR_VOL          1   /* ice volume */
#define GPR_AREA         2   /* ice area */
#define GPR_MH           3   /* dH/dt */
#define GPR_MS           4   /* surface mass balance */
#define GPR_MB           5   /* basal mass balance */
#define GPR_MV           6   /* virtual mass balance */
#define GPR_MR           7   /* residual mass balance */
#define GPR_ME           8   /* mass balance error */

#define GPR_MAX          8   /*  kept */

CCC_  * common work area (2d)
CC maximum of VMIW_MAX, VMSN_MAX, VMST_MAX, VMSG_MAX
#define VMW_MAX 32


#define VMW_W1           1   /* work */
#define VMW_W2           2   /* work */
#define VMW_W3           3   /* work */
#define VMW_W4           4   /* work */
#define VMW_W5           5   /* work */
#define VMW_W6           6   /* work */

CCC_ + Work sizes
#ifndef   OPT_MOVEMENT_LHP_MAX
#  define OPT_MOVEMENT_LHP_MAX 65536
#endif
#ifndef   OPT_MOVEMENT_LHG_MAX
#  define OPT_MOVEMENT_LHG_MAX OPT_MOVEMENT_LHP_MAX
#endif
#ifndef   OPT_MOVEMENT_LVZ_MAX /* maximum layers for velocities */
#  define OPT_MOVEMENT_LVZ_MAX 66
#endif
#ifndef   OPT_MOVEMENT_LVP_MAX /* three-dimension maximum for velocities */
#  define OPT_MOVEMENT_LVP_MAX OPT_MOVEMENT_LHP_MAX * OPT_MOVEMENT_LVZ_MAX
#endif

CCC_ + Independent tests
#define MOVEMENT_DV_CLS 'V'
CCC_* End definitions
#endif  /* _MOVEMENT_H */
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
