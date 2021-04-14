dnl movement/movement.m4 - Template for Definition for IcIES/Movement modules
dnl Maintainer:  SAITO Fuyuki
dnl Created: Jan 17 2012
m4_define([TIME_STAMP],
          ['Time-stamp: <2021/04/12 07:53:36 fuyuki movement.m4>'])dnl
C movement/movement.h - Definition for IcIES/Movement modules
C Maintainer:  SAITO Fuyuki
C Created: Dec 20 2011
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#ifdef HEADER_PROPERTY
[#]define _TSTAMP TIME_STAMP
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
CCC_  * [PMD] SIA/thickness time integration
c_reset([PMD])
c_xincr([DENS],  [ice density])
c_xincr([DENSW], [water density])
c_xincr([GRAV],  [gravity])
c_xincr([PF],    [flow law exponent])

c_xincr([RGAS],  [rgas])
c_xincr([TM],    [TM])
c_xincr([QL],    [QL])
c_xincr([QH],    [QH])
c_xincr([AL],    [AL])
c_xincr([AH],    [AH])

c_xincr([FGX],   [gravity unit vector component])
c_xincr([FGY])
c_xincr([FGZ])
c_xincr([EFC],   [constant enhancement factor])
c_xincr([EFCSH], [constant enhancement factor for shelf])
c_xincr([RFC],   [constant rate factor])
c_xincr([EPS],   [matrix solver epsilon])
c_xincr([ETOL],  [matrix solver tolerance])
c_xincr([WF],    [overrelaxation factor])
c_xincr([CLV],   [parameter for calving])
c_xincr([TCVB],  [minimum temperature for sliding])
c_xincr([SHH],   [minimum thickness to use shelfy stream])
c_xincr([DRSH],  [upper limit rel. to sea level to use shelfy stream])
c_xincr([RVSH],  [vb/vs ratio lower limit to apply shelfy stream])
c_xincr([VBLIM], [basal velocity limit])

c_xkeep([MAX])

CCC_  * [PMT] Thermodynamics
c_reset([PMT],  [PMD_MAX])
c_xincr([DENS], [density])
c_xincr([T0],   [triple point of water])
c_xincr([COND],  [heat conductivity coeff])
c_xincr([CONDP], [heat conductivity exponent coeff])
c_xincr([HCAP],  [heat capatity coeff])
c_xincr([HCAPG], [heat capatity gradient])
c_xincr([CLCLD],[Melting point dependence on depth])
c_xincr([TBSHC],[constant bottom temperature (ice shelf)])
c_xincr([LHC],  [latent heat capacity of ice])
c_xincr([ADIFF],[diffusion coeff for age])
c_xincr([AEPS], [epsilon number for age in RCIP])
c_xkeep([MAX])

CCC_  * [PMS] SSA diagnostic
c_reset([PMS], [PMT_MAX])
c_xincr([DENS])
c_xincr([DENSW])
c_xincr([GRAV])
c_xincr([PF], [flow law exponent])
c_xincr([EPS])
c_xincr([TOLL])
c_xincr([TOLNL])
c_xincr([OVW])
c_xincr([OVWFC])
c_xincr([DSXLIM], [horizontal surface gradient upper limit])
c_xincr([VXLIML], [horizontal velocity gradient lower limit])
c_xincr([VXLIMU], [horizontal velocity gradient upper limit])
c_xincr([VBLIML], [lower limit of basal vel. on shelfy stream])
c_xincr([VSHLIM], [shelf velocity upper limit])
c_xincr([VGLLIM], [grounding line velocity upper limit])
c_xincr([HGLIML], [grounding line thickness lower limit])
c_xincr([UDNML],  [velocity denominator lower limit])
c_xincr([PDNML],  [PQR denominator lower limit])

c_xincr([MUI], [initial guess])

c_xincr([SCH],    [H scale (vertical length)])
c_xincr([SCL],    [L scale (horizontal length)])
c_xincr([SCU],    [u scale (linear part)])
c_xincr([SCV],    [u scale (for non-linear part)])
c_xincr([SCXFSR], [effective strain-rate powered scale])
c_xincr([SCA], [A scale])
c_xincr([SCN], [hydrostatic pressure integral scale])
c_xincr([SCD], [PQR scale])
c_xincr([XSC], [external v scale])
c_xincr([SclUI], [U scale parameter I])
c_xincr([SclUF], [U scale parameter F])
c_xincr([SclUG], [U scale parameter G])
c_xincr([SclVI], [V scale parameter I])
c_xincr([SclVF], [V scale parameter F])
c_xincr([SclVG], [V scale parameter G])
c_xincr([SclPI], [P scale parameter I])
c_xincr([SclPF], [P scale parameter F])
c_xincr([SclPG], [P scale parameter G])
c_xincr([SclQI], [Q scale parameter I])
c_xincr([SclQF], [Q scale parameter F])
c_xincr([SclQG], [Q scale parameter G])
c_xincr([SclRI], [R scale parameter I])
c_xincr([SclRF], [R scale parameter F])

c_xincr([InvUI], [U scale parameter inverse I])
c_xincr([InvUF], [U scale parameter inverse F])
c_xincr([InvUG], [U scale parameter inverse G])
c_xincr([InvVI], [V scale parameter inverse I])
c_xincr([InvVF], [V scale parameter inverse F])
c_xincr([InvVG], [V scale parameter inverse G])
c_xincr([InvPI], [P scale parameter inverse I])
c_xincr([InvPF], [P scale parameter inverse F])
c_xincr([InvPG], [P scale parameter inverse G])
c_xincr([InvQI], [Q scale parameter inverse I])
c_xincr([InvQF], [Q scale parameter inverse F])
c_xincr([InvQG], [Q scale parameter inverse G])
c_xincr([InvRI], [R scale parameter inverse I])
c_xincr([InvRF], [R scale parameter inverse F])

c_xkeep([MAX])

CCC_  * [IMD] thickness time integration
c_reset([IMD])
c_xincr([MSW],  [thickness integration matrix switch])
c_xincr([MINI], [thickness integration initial guess])
c_xincr([ITRMAX], [maximum iteration])
c_xincr([DTTRY],  [maximum trial for dt adjustement])

c_xincr([RF],     [rate factor method switch])
c_xincr([RFI],    [rate factor integral method switch])
c_xincr([WI],     [w integral method switch])
c_xincr([TBDZ],   [T bottom gradient method switch])
c_xincr([UADV],   [horizontal advection switch])
c_xincr([WADV],   [vertical advection switch])
c_xincr([TGRD],   [Ta grid computation switch])
c_xincr([USG],    [u v computation method])
c_xincr([VB],     [sliding velocity scheme])
c_xincr([VBSW],   [sliding velocity switch])
c_xincr([SHSW],   [shelf switch])
c_xincr([DSFR],   [calving front surface gradient])
c_xincr([DSSE],   [shelf end surface gradient])
c_xincr([DHDT],   [dH/dt computation switch])

c_xincr([HUPD],   [H update])
c_xincr([TUPD],   [T update])
c_xincr([TZLP],   [Z-loop outer/inner switch in T solver])
c_xincr([STRH],   [strain heating switch])
c_xincr([RFPR],   [rate factor procedure])

c_xincr([AGEC],   [age computation switch])
c_xincr([ARSTT],  [bc age reset timing])
c_xincr([ABDZ],   [Age bottom gradient method switch])
c_xincr([ASDZ],   [Age surface gradient method switch])
c_xincr([AADVL],  [age advection velocity level])

c_xkeep([MAX])

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

CCC_  * [IMS] SSA diagnostic
c_reset([IMS], [IMD_MAX])
c_xincr([ITRL],  [Maximum iteration for linear part])
c_xincr([ITRLmin], [Minimum iteration for linear part])
c_xincr([ITRNL], [Maximum iteration for non linear part])
c_xincr([ITRGL], [Maximum iteration for grounding-line flux part])
c_xincr([MINNL], [Minimum iteration for non linear part])
c_xincr([TRYNL], [Maximum try for non-linear part])
c_xincr([SWNOV], [solution choice when not converged])
c_xincr([SWL],   [initial guess switch for linear part])
c_xincr([SWNL],  [initial guess switch for non linear part])
c_xincr([SWNLG], [initial guess switch for non linear part, grounding line])
c_xincr([GLUPD], [grounding-line velocity update timing])
c_xincr([GLBT],  [buttressing effect switch])
c_xincr([XREPL], [residual report lower])
c_xincr([XREPH], [residual report higher])
c_xkeep([MAX])

#define SW_GLBT_DEF       0  /* buttressing effect included */
#define SW_GLBT_EXCL      1  /* buttressing effect excluded */

CCC_  * [OMM]
c_reset([OMM])
c_xincr([WITH_SIA],  [with SIA])
c_xincr([WITH_SSA],  [with SSA])
c_xincr([WITH_HUPD], [with H  update])
c_xincr([WITH_TUPD], [with T  update])
c_xincr([WITH_RUPD], [with RF update])
c_xincr([WITH_VEL],  [with VEL])
c_xkeep([MAX])

CCC_  * [P/IMM] PMD/PMS integration
[#]define PMM_MAX PMS_MAX
[#]define IMM_MAX IMS_MAX

CCC_ + clone group
CCC_  * [CGB] SIA
c_reset([CGB])
c_clgrp([Ha],   [], [Lab,  Lac])
c_clgrp([Sa],   [], [Lab,  Lac, GXab, GYac])
c_clgrp([Sd],   [], [GXdc, GYdb])
c_clgrp([XHaN], [], [Lab,  Lac, GXab, GYac])
c_clgrp([XHaT], [], [DXba, DYca])
c_clgrp([UHaT], [], [Lba,  Lca])
c_xkeep([MAX])

CCC_  * [CGV] Velocity
c_reset([CGV], [CGB_MAX])
c_clgrp([Ub], [], [DXba, Lba, FCba])
c_clgrp([Vc], [], [DYca, Lca, FCca])
c_xkeep([MAX])

CCC_  - [CGHV] Velocity/MMH
c_reset([CGHV], [CGV_MAX])
c_clgrp([Ub], [], [DXba, Lba, FCba])
c_clgrp([Vc], [], [DYca, Lca, FCca])
c_xkeep([MAX])

CCC_  * [CGT] Thermo
c_reset([CGT], [CGHV_MAX])
c_clgrp([Ha],   [], [GXab, GXac])
c_clgrp([Ba],   [], [GXab, GXac])
c_clgrp([Ta],   [], [Lab,  Lac, GXab, GYac, FCab, FCac])
c_clgrp([CTB],  [], [FCab, FCac])
c_xkeep([MAX])

CCC_  * [CGS] SSA
c_reset([CGS], [CGT_MAX])
CCC_   + in normal operation
c_clgrp([UbS], [],  [GXba, GYbd])
c_clgrp([VcW], [],  [GYca, GXcd])
c_clgrp([UbN], [],  [GXba, GYbd])
c_clgrp([VcE], [],  [GYca, GXcd])
c_clgrp([PaW], [],  [GXab, Lab])
c_clgrp([QaS], [],  [GYac, Lac])
c_clgrp([RdA], [],  [GYdb, GXdc, Ldb, Ldc])
CCC_   + in transpose operation
CCCc_clgrp([MuRd])
c_clgrp([MuIPa], [],  [GXba, GYca])
c_clgrp([MuIQa], [],  [GYca, GXba])
CCC_   + in non-linear part
CCCc_clgrp([URa])
c_clgrp([URd], [],  [Ldb, Ldc])
c_clgrp([UXa], [],  [Lab, Lac])
c_clgrp([VYa], [],  [Lab, Lac])
c_xkeep([MAX])

c$$$CCC_  - [CGG] SSA/Grounding line
c$$$c_reset([CGG], [CGS_MAX])
c$$$c_clgrp([Ha],   [],  [FCab, FCac])
c$$$c_clgrp([Ra],   [],  [FCab, FCac])
c$$$c_clgrp([IKa],  [],  [FCab, FCac])
c$$$c_xkeep([MAX])

CCC_   + clone-group cluster
c$$$[#]define CGRP_MAX     CGG_MAX
[#]define CGRP_MAX     CGS_MAX
[#]define CGRP_MEM_MAX _clmem_max

CCC_ + output
CCC_  * [VGRP]
c_reset([VGRP])
c_xincr([VMI])
c_xincr([VMC])
c_xincr([VMID])
c_xincr([VMIW])

c_xincr([VMQ])
c_xincr([VMX])

c_xincr([VMSC])
c_xincr([VMSV])
c_xincr([VMSX])
c_xincr([VMSN])
c_xincr([VMST])

c_xincr([VMSXI], [SSA residual])
c_xincr([VMSXT], [SSA solution])

c_xincr([VMHB])
c_xincr([VMHR])
c_xincr([VMHI])
c_xincr([VMHW])
c_xincr([VMTI])
c_xincr([VMTW])

c_xincr([VMTA])
c_xincr([VMTD])

c_xkeep([MAX])

CCC_ + Variable cluster
CCC_  * [BCGW] bcg solver work (common)
c_reset([BCGW])

c_xincr([BB], [right-hand vector])
c_xincr([R])
c_xincr([P])
c_xincr([Z])
c_xincr([RR])
c_xincr([PP])
c_xincr([ZZ])
c_xincr([B1])
c_xincr([XB],      [buffer for BCG])
c_xincr([XX, XH0], [initial guess])
c_xincr([XH1],     [solution history 1])
c_xincr([XH2],     [solution history 2])
c_xkeep([XHmax])
c_xkeep([MAX])

CCC_  - [BCGS] bcgs (bicgstab) solver work
c_reset([BCGS])

c_xincr([BB], [right-hand vector])
c_xincr([R])
c_xincr([P])
c_xincr([S])
c_xincr([RR0])
c_xincr([T1])
c_xincr([T2])
c_xincr([T3])
c_xincr([XB],      [buffer for BCG])
c_xincr([XX, XH0], [initial guess])
c_xincr([XH1],     [solution history 1])
c_xincr([XH2],     [solution history 2])
c_xkeep([XHmax])
c_xkeep([MAX])

[#]define BCG_MAX c_xmax([BCGW_MAX],[BCGS_MAX])


CCC_  * [VMI] input field 2d/ice
c_reset([VMI])

CC fix thickness == 0
c_xincr([CLa],  [lateral bc], [CL], [a])

c_xincr([HH],   [Ice thickness begin],[HH], [a])

c_xincr([Ha],   [Ice thickness],      [H], [a])
c_xincr([Sa],   [Ice surface],        [S], [a])
c_xincr([Ba],   [Ice base],           [B], [a])

c_xincr([Hb],   [Ice thickness],      [H], [b])
c_xincr([Sb],   [Ice surface],        [S], [b])
c_xincr([Bb],   [Ice base],           [B], [b])

c_xincr([Hc],   [Ice thickness],      [H], [c])
c_xincr([Sc],   [Ice surface],        [S], [c])
c_xincr([Bc],   [Ice base],           [B], [c])

c_xincr([Hd],   [Ice thickness],      [H], [d])
c_xincr([Sd],   [Ice surface],        [S], [d])
c_xincr([Bd],   [Ice base],           [B], [d])

CCC_   + SIA
c_xincr([RFIIb], [rate factor d-n double integral],  [RFII],  [b])
c_xincr([RFIIc], [rate factor d-n double integral],  [RFII],  [c])

CCC_   + SSA
c_xincr([daRFa],   [rate factor depth average],        [daRF], [a])
ccc_xincr([daRFd],   [rate factor depth average],        [daRF], [d])
c_xincr([daBAa],   [assoc. rate factor depth average], [daBA], [a])
c_xincr([daBAd],   [assoc. rate factor depth average], [daBA], [d])

CCC_   + sliding
c_xincr([SLDb], [basal sliding switch],   [SLD], [b])
c_xincr([SLDc], [basal sliding switch],   [SLD], [c])

c_xincr([HX],  [dH/dx],                   [HX],[a])
c_xincr([HY],  [dH/dy],                   [HY],[a])

c_xkeep([MAX])

CCC_  * [VMC] topography intermediate
c_reset([VMC])
CCC_    * common
c_xincr([HCa],  [Thickness (after calving)],  [HC], [a])

c_xincr([IKa],  [Grid category], [IK],  [a])
c_xincr([IKb],  [Grid category], [IK],  [b])
c_xincr([IKc],  [Grid category], [IK],  [c])
c_xincr([IKd],  [Grid category], [IK],  [d])

c_xincr([DSXb], [surface gradient x],      [DSX], [b])
c_xincr([DSYb], [surface gradient y],      [DSY], [b])
c_xincr([DSXc], [surface gradient x],      [DSX], [c])
c_xincr([DSYc], [surface gradient y],      [DSY], [c])
c_xincr([DSXd], [surface gradient x (reserved)], [DSX], [d])
c_xincr([DSYd], [surface gradient y (reserved)], [DSY], [d])

c_xincr([HE],   [new thickness corrected], [He],  [a])

c_xincr([NHa],  [next thickness],          [NH],  [a])
c_xincr([NHb],  [next thickness],          [NH],  [b])
c_xincr([NHc],  [next thickness],          [NH],  [c])

c_xincr([NBa],  [next base],               [NB],  [a])
c_xincr([NBb],  [next base],               [NB],  [b])
c_xincr([NBc],  [next base],               [NB],  [c])

c_xincr([HX],  [next thickness gradient],  [HX],  [a])
c_xincr([HY],  [next thickness gradient],  [HY],  [a])

CC old when floated, next otherwise
c_xincr([SXbM], [next/old surface gradient x], [dsdxm], [b])
c_xincr([SYcM], [next/old surface gradient y], [dsdym], [c])
c_xincr([BXbM], [next/old base gradient x],    [dbdxm], [b])
c_xincr([BYcM], [next/old base gradient y],    [dbdym], [c])

c_xincr([dHdtE], [dH/dt corrected],            [dHdte], [a])

c_xincr([QXaU],  [CIP x a-term],    [QXaU], [b])
c_xincr([QXbU],  [CIP x b-term],    [QXbU], [b])
c_xincr([QXcU],  [CIP x c-term],    [QXcU], [b])
c_xincr([QXdU],  [CIP x d-term],    [QXdU], [b])
c_xincr([QXaL],  [CIP x a-term],    [QXaL], [b])
c_xincr([QXbL],  [CIP x b-term],    [QXbL], [b])
c_xincr([QXcL],  [CIP x c-term],    [QXcL], [b])
c_xincr([QXdL],  [CIP x d-term],    [QXdL], [b])

c_xincr([QYaU],  [CIP y a-term],    [QYaU], [c])
c_xincr([QYbU],  [CIP y b-term],    [QYbU], [c])
c_xincr([QYcU],  [CIP y c-term],    [QYcU], [c])
c_xincr([QYdU],  [CIP y d-term],    [QYdU], [c])
c_xincr([QYaL],  [CIP y a-term],    [QYaL], [c])
c_xincr([QYbL],  [CIP y b-term],    [QYbL], [c])
c_xincr([QYcL],  [CIP y c-term],    [QYcL], [c])
c_xincr([QYdL],  [CIP y d-term],    [QYdL], [c])

CCC_    * SSA
CCc_xincr([HSIb], [HSI],   [HSI], [b])
CCc_xincr([HSIc], [HSI],   [HSI], [c])
CCc_xincr([HSId], [HSI],   [HSI], [d])

c_xkeep([MAX])

CCC_  * [VMQ] thickness integration matrix (DE)
c_reset([VMQ])

c_xincr([MSK])
c_xincr([DIAG])
c_xincr([BB], [Flux offset term])
c_xincr([Db])
c_xincr([Dc])
c_xincr([Eb])
c_xincr([Ec])

c_xkeep([MAX])

CCC_  * [VMQU] thickness integration matrix (U)
c_reset([VMQU])

c_xincr([MSK])
c_xincr([DIAG])
c_xincr([BB], [Flux offset term])
c_xincr([UEava])
c_xincr([VEava])
c_xincr([WXp])
c_xincr([WXm])
c_xincr([WYp])
c_xincr([WYm])
c_xincr([CDIV], [Conditional divergence])

c_xkeep([MAX])

CCC_  - [VMQZ] thickness integration matrix (Z/G/UPD)
c_reset([VMQZ])

c_xincr([MSK])
c_xincr([DIAG])
c_xincr([BB], [Flux offset term])
c_xincr([UEava])
c_xincr([VEava])
c_xincr([WXp])
c_xincr([WXm])
c_xincr([WYp])
c_xincr([WYm])
c_xincr([DIV])

c_xkeep([MAX])

CCC_  - [VMQH obsolete] thickness integration matrix (H)
cc_reset([VMQH])

cc_xincr([MSK])
cc_xincr([DIAG])
cc_xincr([BB], [Flux offset term])
cc_xincr([UEava])
cc_xincr([VEava])
cc_xincr([CEb], [Conditional E-term])
cc_xincr([CEc])
cc_xincr([WXp])
cc_xincr([WXm])
cc_xincr([WYp])
cc_xincr([WYm])
cc_xincr([CDIV])

cc_xkeep([MAX])

CCC_  - [VMQH] thickness integration matrix (upwind hybrid)
c_reset([VMQH])

c_xincr([MSK])
c_xincr([DIAG])
c_xincr([BB], [Flux offset term])
c_xincr([UEava])
c_xincr([VEava])
c_xincr([UEavb, CEb], [Conditional E-term])
c_xincr([VEavc, CEc])
c_xincr([xDIVu, CDIV])
c_xincr([yDIVv])
c_xincr([WXe],      [Switch X/e])
c_xincr([WXd],      [Switch X/df])
c_xincr([WXp, Ucp], [Switch X/uf/p (or UE copy temporal)])
c_xincr([WXm],      [Switch X/uf/m])
c_xincr([WYe],      [Switch Y/e])
c_xincr([WYd],      [Switch Y/df])
c_xincr([WYp, Vcp], [Switch Y/uf/p (or VE copy temporal)])
c_xincr([WYm],      [Switch Y/uf/m])
c_xincr([xDIVv],   [dV/dx term])
c_xincr([yDIVu],   [dU/dy term])

c_xkeep([MAX])


CCC_  - [VMQUd] thickness integration matrix (U/d)
c_reset([VMQUd])

c_xincr([MSK])
c_xincr([DIAG])
c_xincr([DQx])
c_xincr([DQy])
c_xincr([UWp])
c_xincr([UWm])
c_xincr([VWp])
c_xincr([VWm])

c_xkeep([MAX])


[#]define VMQQ_MAX c_xmax([VMQ_MAX],[VMQU_MAX],[VMQZ_MAX],[VMQH_MAX], [VMQUd_MAX])

CCC_  * [VMID] SIA diagnostic
c_reset([VMID])

c_xincr([BSXb],  [basal shear stress x],  [BSX],  [b])
c_xincr([BSYb],  [basal shear stress y],  [BSY],  [b])
c_xincr([BNb],   [basal shear stress n],  [BN],   [b])
c_xincr([Db],    [diffusion],             [D],    [b])
c_xincr([UIavb], [uiav. depth-average ui],[uiav], [b])
c_xincr([UBb],   [ub. basal velocity x],  [ub],   [b])
c_xincr([vBSXb], [basal shear stress for sliding x],  [vBSX], [b])

c_xincr([BSXc],  [basal shear stress x],  [BSX],  [c])
c_xincr([BSYc],  [basal shear stress y],  [BSY],  [c])
c_xincr([BNc],   [basal shear stress n],  [BN],   [c])
c_xincr([Dc],    [diffusion],             [D],    [c])
c_xincr([VIavc], [viav. depth-average vi],[viav], [c])
c_xincr([VBc],   [vb. basal velocity y],  [vb],   [c])
c_xincr([vBSYc], [basal shear stress for sliding y],  [vBSY], [c])

c_xkeep([MAX])

CCC_  * [VMIW] work/SIA
c_reset([VMIW])

c_xincr([W1],   [work],      [W1],   [a])
c_xincr([W2],   [work],      [W2],   [a])
c_xincr([W3],   [work],      [W3],   [a])
c_xincr([W4],   [work],      [W4],   [a])
c_xincr([W5],   [work],      [W5],   [a])
c_xincr([W6],   [work],      [W6],   [a])
c_xincr([W7],   [work],      [W7],   [a])

c_xkeep([MAX])

CCC_  * [VMSX] SSA diagnostic (13 N elements)
c_reset([VMSX])

c_xincr([PaE],  [P:a to E], [PE], [a])
c_xincr([PaW],  [P:a to W], [PW], [a])
c_xincr([QaN],  [Q:a to N], [QN], [a])
c_xincr([QaS],  [Q:a to S], [QS], [a])
c_xincr([UbN],  [u:b to N], [uN], [b])
c_xincr([UbS],  [u:b to S], [uS], [b])
c_xincr([VcE],  [v:c to E], [vE], [c])
c_xincr([VcW],  [v:c to W], [vW], [c])
c_xincr([RdA],  [R:d],      [R],  [d])
c_xincr([PaN],  [P:a to N], [PN], [a])
c_xincr([PaS],  [P:a to S], [PS], [a])
c_xincr([QaE],  [Q:a to E], [QE], [a])
c_xincr([QaW],  [Q:a to W], [QW], [a])

c_xkeep([MAX])

CCC_  * [VMSC] Coefficients (constant within non-linear solver)
c_reset([VMSC])

CCC_   + I series (bool if interior)
c_xincr([Da_MI, I0],  [D:a    1 if interior],   [ID], [a])
c_xkeep([PaE_MI, PaW_MI, PaN_MI, PaS_MI, QaE_MI, QaW_MI, QaN_MI, QaS_MI])
c_xincr([Ub_MI, UbN_MI, UbS_MI],  [u:b    1 if interior],   [Iu], [b])
c_xincr([Vc_MI, VcE_MI, VcW_MI],  [v:c    1 if interior],   [Iv], [c])
c_xincr([Rd_MI, I9],  [R:d    1 if interior],   [IR], [d])

c_xincr([BVIa],   [assoc. rate factor integral], [BVI], [a])
c_xincr([BVId],   [assoc. rate factor integral], [BVI], [d])

CCC_   + F series (bool if fixed)
c_xincr([UbN_MF, F0], [u:b (N) 1 if fixed],  [FuN], [b])
c_xincr([UbS_MF], [u:b (S) 1 if fixed],  [FuS], [b])
c_xincr([VcE_MF], [v:c (E) 1 if fixed],  [FvE], [c])
c_xincr([VcW_MF], [v:c (W) 1 if fixed],  [FvW], [c])

c_xincr([PaE_MF], [P:a (E) 1 if fixed],  [FpE], [a])
c_xincr([PaW_MF], [P:a (W) 1 if fixed],  [FpW], [a])
c_xincr([QaN_MF], [Q:a (N) 1 if fixed],  [FqN], [a])
c_xincr([QaS_MF], [Q:a (S) 1 if fixed],  [FqS], [a])

c_xincr([PaN_MF], [P:a (N) 1 if fixed],  [FpN], [a])
c_xincr([PaS_MF], [P:a (S) 1 if fixed],  [FpS], [a])
c_xincr([QaE_MF], [Q:a (E) 1 if fixed],  [FqE], [a])
c_xincr([QaW_MF], [Q:a (W) 1 if fixed],  [FqW], [a])

c_xincr([RdA_MF, F9], [R:d (A) 1 if fixed],  [FrA], [d])

CCC_   + G series (bool if ghost)
c_xincr([UbN_MG, G0], [u:b (N) 1 if ghost],  [GuN], [b])
c_xincr([UbS_MG], [u:b (S) 1 if ghost],  [GuS], [b])
c_xincr([VcE_MG], [v:c (E) 1 if ghost],  [GvE], [c])
c_xincr([VcW_MG], [v:c (W) 1 if ghost],  [GvW], [c])

c_xincr([PaE_MG], [P:a (E) 1 if ghost],  [GpE], [a])
c_xincr([PaW_MG], [P:a (W) 1 if ghost],  [GpW], [a])
c_xincr([QaN_MG], [Q:a (N) 1 if ghost],  [GqN], [a])
c_xincr([QaS_MG], [Q:a (S) 1 if ghost],  [GqS], [a])

c_xincr([PaN_MG], [P:a (N) 1 if ghost],  [GpN], [a])
c_xincr([PaS_MG], [P:a (S) 1 if ghost],  [GpS], [a])
c_xincr([QaE_MG], [Q:a (E) 1 if ghost],  [GqE], [a])
c_xincr([QaW_MG, G9], [Q:a (W) 1 if ghost],  [GqW], [a])

CCC_   + L series
c_xincr([QbHe, PbHe, L0],   [Q:b coeff. QaW e],    [LLhe], [b])
c_xincr([QbHw, PbHw],   [Q:b coeff. QaE w],    [LLhw], [b])
c_xincr([QbNe, PbNe],   [Q:b coeff. QaN e],    [LLNe], [b])
c_xincr([QbNw, PbNw],   [Q:b coeff. QaN w],    [LLNw], [b])
c_xincr([QbSe, PbSe],   [Q:b coeff. QaS e],    [LLSe], [b])
c_xincr([QbSw, PbSw],   [Q:b coeff. QaS w],    [LLSw], [b])

c_xincr([PcVn, QcVn],   [P:c coeff. PaS n],    [LLvn], [c])
c_xincr([PcVs, QcVs],   [P:c coeff. PaN s],    [LLvs], [c])
c_xincr([PcEn, QcEn],   [P:c coeff. PaE n],    [LLEn], [c])
c_xincr([PcEs, QcEs],   [P:c coeff. PaE s],    [LLEs], [c])
c_xincr([PcWn, QcWn],   [P:c coeff. PaW n],    [LLWn], [c])
c_xincr([PcWs, QcWs, L9],   [P:c coeff. PaW s],    [LLWs], [c])

CCC_   + N series
c_xincr([NdX, N0],    [Nx:d],   [Nx], [d])
c_xincr([NdY],    [Ny:d],   [Ny], [d])
c_xincr([NbX],    [Nx:b],   [Nx], [b])
c_xincr([NbY],    [Ny:b],   [Ny], [b])
c_xincr([NcX],    [Nx:c],   [Nx], [c])
c_xincr([NcY],    [Ny:c],   [Ny], [c])

c_xincr([NdXXY, NdYXX, NdXYX],  [Nx:d Nx:d Ny:d], [NxNxNy], [d])
c_xincr([NdYYX, NdXYY, NdYXY],  [Ny:d Ny:d Nx:d], [NyNyNx], [d])
CCc_xincr([NdXY, NdYX], [Nx:d Ny:d],   [NxNy], [d])

c_xincr([NbXX],        [Nx:b Nx:b],   [NxNx], [b])
c_xincr([NbYY],        [Ny:b Ny:b],   [NyNy], [b])
c_xincr([NbXY, NbYX],  [Nx:b Ny:b],   [NxNy], [b])
c_xincr([NcYY],        [Ny:c Ny:c],   [NyNy], [c])
c_xincr([NcXX],        [Nx:c Nx:c],   [NxNx], [c])
c_xincr([NcYX, NcXY, N9],[Ny:c Nx:c],   [NyNx], [c])

CCC_   + D series (switch ddx)
c_xincr([DxSwEb, D0],  [Switch ddx[E]:b],  [DxSwE], [b])
c_xincr([DxSwWb],      [Switch ddx[W]:b],  [DxSwW], [b])
c_xincr([DySwNc],      [Switch ddy[N]:c],  [DySwN], [c])
c_xincr([DySwSc],      [Switch ddy[S]:c],  [DySwS], [c])

c_xincr([DxSwEd],      [Switch ddx[E]:d],  [DxSwE], [d])
c_xincr([DxSwWd],      [Switch ddx[W]:d],  [DxSwW], [d])
c_xincr([DySwNd],      [Switch ddy[N]:d],  [DySwN], [d])
c_xincr([DySwSd, D9],  [Switch ddy[S]:d],  [DySwS], [d])

CCC_   + C series (switch corner)
c_xincr([CxSwNb, C0],  [Switch Corner x:[N]:b],  [CxSwN], [b])
c_xincr([CySwNb],      [Switch Corner y:[N]:b],  [CySwN], [b])
c_xincr([CxSwSb],      [Switch Corner x:[S]:b],  [CxSwS], [b])
c_xincr([CySwSb],      [Switch Corner y:[S]:b],  [CySwS], [b])

c_xincr([CxSwEc],      [Switch Corner x:[E]:c],  [CxSwE], [c])
c_xincr([CySwEc],      [Switch Corner y:[E]:c],  [CySwE], [c])
c_xincr([CxSwWc],      [Switch Corner x:[W]:c],  [CxSwW], [c])
c_xincr([CySwWc, C9],  [Switch Corner y:[W]:c],  [CySwW], [c])

c_xkeep([MAX],    [])

CCC_  * [VMSV] Variable coefficients (update after linear solver)
c_reset([VMSV])

c_xincr([fsrp],   [effective strain rate powered], [fsrp], [a])
ccc_xincr([fsrpd],  [effective strain rate powered], [fsrp], [d])
c_xincr([URa],    [dudy+dvdx:a], [ur], [a])
c_xincr([UXa],    [dudx:a], [ux], [a])
c_xincr([VYa],    [dvdy:a], [vy], [a])

c_xincr([MUa],   [mu:a interior], [mu], [a])
c_xincr([MUd],   [mu:d],          [mu], [d])
c_xincr([MUaN],  [mu:a to N],     [muN],[a])
c_xincr([MUaS],  [mu:a to S],     [muS],[a])
c_xincr([MUaE],  [mu:a to E],     [muE],[a])
c_xincr([MUaW],  [mu:a to W],     [muW],[a])

c_xincr([MUa0],  [mu:a buffer], [mubuf0], [a])
c_xincr([MUd0],  [mu:d],        [mubuf0], [d])
c_xincr([MUa1],  [mu:a buffer], [mubuf1], [a])
c_xincr([MUd1],  [mu:d],        [mubuf1], [d])

c_xincr([BDb],   [Basal drag visc.], [BD], [b])
c_xincr([BDc],   [Basal drag visc.], [BD], [c])

CCC_   + GL series (grounding line flux)
c_xincr([UGb_MI, GL0], [Grounding line replacement flag], [Iug],[b])
c_xincr([VGc_MI],      [Grounding line replacement flag], [Ivg],[c])
c_xincr([UGb],         [Grounding line replacement vel],  [ugl],[b])
c_xincr([VGc],         [Grounding line replacement vel],  [vgl],[c])

c_xincr([Hglb],      [Grounding line thickness], [Hgl], [b])
c_xincr([Hglc],      [Grounding line thickness], [Hgl], [c])
c_xincr([Dglb],      [Grounding line direction], [Dgl], [b])
c_xincr([Dglc],      [Grounding line direction], [Dgl], [c])
c_xincr([Qglb],      [Grounding line flux],      [Qgl], [b])
c_xincr([Qglc],      [Grounding line flux],      [Qgl], [c])
c_xincr([BIglb],     [Grounding line BI],        [BIgl],[b])
c_xincr([BIglc],     [Grounding line BI],        [BIgl],[c])
c_xincr([CCglb],     [Grounding line C coeff],   [CCgl], [b])
c_xincr([CCglc],     [Grounding line C coeff],   [CCgl], [c])
c_xincr([CPglb],     [Grounding line C exponent],[CPgl], [b])
c_xincr([CPglc],     [Grounding line C exponent],[CPgl], [c])
c_xincr([WQgb],      [Grounding line weight],      [WQg], [b])
c_xincr([WQlb, WQob], [Grounding line weight],      [WQl], [b])
c_xincr([WQub, WQcb], [Grounding line weight],      [WQu], [b])
c_xincr([WQgc],      [Grounding line weight],      [WQg], [c])
c_xincr([WQlc, WQoc], [Grounding line weight],      [WQl], [c])
c_xincr([WQuc, WQcc], [Grounding line weight],      [WQu], [c])
c_xincr([WTglEb],    [Grounding line weight T],  [WTglE], [b])
c_xincr([WTglWb],    [Grounding line weight T],  [WTglW], [b])
c_xincr([WTglNc],    [Grounding line weight T],  [WTglN], [c])
c_xincr([WTglSc],    [Grounding line weight T],  [WTglS], [c])
c_xincr([Btrb],      [Buttressing ratio],        [Btr],   [b])
c_xincr([Btrc],      [Buttressing ratio],        [Btr],   [c])
c_xincr([Xglb],      [Grounding line position],  [Xgl], [b])
c_xincr([Yglc, GL9], [Grounding line position],  [Ygl], [c])

c_xkeep([MAX])

CCC_  * [VMSN] work/SSA/normal operation
c_reset([VMSN])

c_xincr([B1], [any])
c_xincr([B2], [any])
c_xincr([B3], [any])
c_xincr([B4], [any])

c_xincr([MiPXRY], [Mi (dP/dx+dR/dy)],     [IDR])
c_xkeep([MiQYRX], [Mi (dQ/dy+dR/dx)])
c_xkeep([PIa],    [mu (4du/dx + 2dv/dy)])
c_xkeep([QIa],    [mu (2du/dx + 4dv/dy)])

c_xincr([NxRd],   [Nx:d R:d],             [NR])
c_xincr([NyRd],   [Ny:d R:d])
c_xkeep([NPNRb],  [Nx P + Ny R b])
c_xkeep([NQNRc],  [Ny Q + Nx R c])
c_xkeep([NQNRb],  [Ny Q + Nx R b])
c_xkeep([NPNRc],  [Nx P + Ny R c])

c_xincr([SwPbH, SwQcV],   [P:b from P:a (EW) corner/wall],    [SwPh])
c_xincr([SwQbH, SwPcV],   [Q:b from Q:a (EW) corner/wall],    [SwQh])

c_xincr([SumDUDXa], [sum du/dx:a],   [Sumdudx], [a])
c_xincr([SumDVDYa], [sum dv/dy:a],   [Sumdvdy], [a])
c_xincr([DUDXaN], [du/dx:a],   [dudxN], [a])
c_xincr([DUDXaS], [du/dx:a],   [dudxS], [a])
c_xincr([DVDYaE], [dv/dy:a],   [dvdyE], [a])
c_xincr([DVDYaW], [dv/dy:a],   [dvdyW], [a])

c_xincr([Rb], [R:b],           [R], [b])
c_xkeep([Rc], [R:c],           [R], [c])

c_xkeep([MAX])

CCC_  * [VMST] work/SSA/transpose operation
c_reset([VMST])

c_xincr([B1], [any])
c_xincr([B2], [any])
c_xincr([B3], [any])
c_xincr([B4], [any])

c_xincr([MuIPa], [mu I sum P:a],         [muIP], [a])
c_xincr([MuIQa], [mu I sum Q:a],         [muIQ], [a])

c_xincr([SumCxGU], [n Cx G U[NS]])
c_xincr([SumCxGV], [nnn Cx G V[EW]])

c_xincr([SumCyGV], [n Cy G V[EW]])
c_xincr([SumCyGU], [nnn Cy G U[NS]])

c_xincr([IGPN],  [(I+G) P[N]])
c_xincr([IGPS],  [(I+G) P[S]])
c_xincr([IGQE],  [(I+G) Q[E]])
c_xincr([IGQW],  [(I+G) Q[W]])

c_xincr([MuIRd],  [mu I R:d])

c_xincr([Iuu, SumMuIPQ, MiSumUb], [mask.I sum U:b], [Iuu], [b])
c_xincr([Ivv, MiSumVc], [mask.I sum V:b], [Ivv], [c])

c_xincr([GSumPa], [(G P + Shift G P)],       [GP])
c_xincr([GSumQa], [(G Q + Shift G Q)],       [GQ])

c_xincr([nGSumPa, nGSumQa], [n (G P + Shift G P)],       [nGP])

c_xincr([nCGUN], [n shift C G U[N]])
c_xincr([nCGUS], [n shift C G U[S]])
c_xincr([nCGVE], [n shift C G V[E]])
c_xincr([nCGVW], [n shift C G V[W]])

c_xincr([LnCGU, LnCGV],  [L SumCGU])

cc_xincr([NGVE],     [n:d       mask.G[vE] v[E]:c],  [NGVu])
cc_xkeep([NGUN],     [n:d       mask.G[uN] u[S]:b])
c
cc_xincr([NGVW],     [n:d Shift mask.G[vW] v[W]:c],  [NGVl])
cc_xkeep([NGUS],     [n:d Shift mask.G[uS] u[N]:b])
c
cc_xincr([LTNGV],    [T(L){NGVW,NGVE}],              [LNG])
cc_xkeep([LTNGU],    [T(L){NGUS,NGUN}])
c
cc_xincr([SumNyMgPh], [ny (Mg P + Shift Mg P)],      [NGPh])
cc_xincr([SumNyMgPv], [ny (Mg P + Shift Mg P)],      [NGPv])
cc_xincr([SumNxMgQh], [nx (Mg Q + Shift Mg Q)],      [NGQh])
cc_xincr([SumNxMgQv], [nx (Mg Q + Shift Mg Q)],      [NGQv])
c_xkeep([MAX])

CCC_  * [VMSZ] work/SSA/non-linear

c_reset([VMSZ])
c_xincr([B1], [any])
c_xincr([B2], [any])

c_xincr([UXaN], [dudx[N]:a], [uxN])
c_xkeep([Vb, Uc])
c_xincr([UXaS], [dudx[S]:a], [uxS])
c_xincr([UXaE], [dudx[E]:a], [uxE])
c_xincr([UXaW], [dudx[W]:a], [uxW])
c_xincr([VYaN], [dvdy[N]:a], [vyN])
c_xincr([VYaS], [dvdy[S]:a], [vyS])
c_xincr([VYaE], [dvdy[E]:a], [vyE])
c_xincr([VYaW], [dvdy[W]:a], [vyW])

ccc_xincr([URa],   [dudy+dvdx:a], [ur], [a])
c_xincr([URb],   [dudy+dvdx:b], [ur], [b])
c_xincr([URc],   [dudy+dvdx:c], [ur], [c])
c_xincr([URd],   [dudy+dvdx:d], [ur], [d])

ccc_xincr([UXa],   [dudx:a], [ux], [a])
c_xincr([UXb],   [dudx:b], [ux], [b])
c_xincr([UXc],   [dudx:c], [ux], [c])
c_xincr([UXd],   [dudx:d], [ux], [d])

ccc_xincr([VYa],   [dvdy:a], [vy], [a])
c_xincr([VYb],   [dvdy:b], [vy], [b])
c_xincr([VYc],   [dvdy:c], [vy], [c])
c_xincr([VYd],   [dvdy:d], [vy], [d])

c_xkeep([MAX])

CCC_  * [VMSG] work/grounding-line
c_reset([VMSG])
c_xincr([IFGa],  [Float or not], [IFG],   [a])
c_xincr([IFGb],  [Float or not], [IFG],   [b])
c_xincr([IFGc],  [Float or not], [IFG],   [c])
c_xincr([PTN],   [pattern],    [PTN],   [a])
c_xincr([PTNp],  [pattern +1], [PTNp],  [a])
c_xincr([PTNm],  [pattern -1], [PTNm],  [a])
c_xincr([PTNpp], [pattern +2], [PTNpp], [a])
c_xincr([PTNmm], [pattern -2], [PTNmm], [a])

c_xincr([CRFI], [clone RFI], [CRFI], [a])
c_xincr([CH],   [clone H],   [CH],  [a])
c_xincr([CR],   [clone R],   [CR],  [a])
c_xincr([CSL],  [clone SLV], [CSL], [a])
c_xincr([CCc],  [clone Cc],  [CCc],  [a])
c_xincr([CCp],  [clone Cp],  [CCp],  [a])

c_xincr([WDF],   [work dir flag],       [WDF],  [a])

c_xincr([Hgi],   [Hg inside],  [Hgi],   [a])
c_xincr([Xrgi],  [Xrg inside], [Xrgi],  [a])
c_xincr([LRFi],  [LRF inside], [LFFi],  [a])
c_xincr([Hgo],   [Hg outside], [Hgo],   [a])
c_xincr([Xrgo],  [Xrg outside],[Xrgo],  [a])
c_xincr([LRFo],  [LRF outside],[LFFo],  [a])

c_xincr([CHg],   [Clone Hgo],  [CHg],   [a])
c_xincr([CXrg],  [Clone Xrgo], [CXrg],  [a])
c_xincr([CLRF],  [Clone LRFI], [CLRF],  [a])
c_xincr([CIK])
c_xincr([CWDF],  [clone work dir flag], [CWDF], [a])

c$$$c_xincr([Qo],  [flux 0])
c$$$c_xincr([Qm],  [flux -1])
c$$$c_xincr([Qp],  [flux +1])
c$$$c_xincr([RWo], [result weight 0])
c$$$c_xincr([RWm], [result weight -1])
c$$$c_xincr([RWp], [result weight +1])

c_xkeep([MAX])

CCC_  * [VMSE] extrapolation coefficients/SSA
c_reset([VMSE])

c_xincr([Ebab], [ E [b] a])
c_xincr([Ebaa], [ E  b [a]])
c_xincr([abWa], [[a] b  W])
c_xincr([abWb], [ a [b] W])
c_xincr([Ncac], [ N [c] a])
c_xincr([Ncaa], [ N  c [a]])
c_xincr([acSa], [[a] c  S])
c_xincr([acSc], [ a [c] S])

c_xkeep([MAX])

CCC_  * [VMVZ] Velocity and others input 1d vertical
c_reset([VMVZ])
c_xincr([Za],     [Zeta],              [Z],    [za])
c_xincr([Zb],     [Zeta],              [Z],    [zb])
c_xincr([dZa],    [dZeta],             [dZ],   [za])
c_xincr([dZb],    [dZeta],             [dZ],   [zb])
c_xincr([cZa],    [1 - Zeta:a],        [cZ],   [za])
c_xincr([cZaN],   [1 - Zeta:a n power],[cZN],  [za])

c_xincr([dPb],    [dPb],               [dPb],  [zb])
c_xincr([dWPb],   [first derivative weights], [dWPb],  [zb])
c_xincr([dWMb],   [first derivative weights], [dWMb],  [zb])
c_xincr([ddWPa],  [second derivative weights],[ddWPb], [za])
c_xincr([ddWOa],  [second derivative weights],[ddWOb], [za])
c_xincr([ddWMa],  [second derivative weights],[ddWMb], [za])

c_xincr([dXa],    [transformation factor],  [dXa],  [za])
c_xincr([ddXa],   [transformation factor],  [ddXa], [za])
c_xincr([iddXa],  [transformation factor],  [iddXa], [za])

c_xincr([Lap],    [interpolation factor p],  [Lap],  [za])
c_xincr([Lam],    [interpolation factor m],  [Lam],  [za])

c_xincr([Lbp],    [interpolation factor p],  [Lbp],  [zb])
c_xincr([Lbm],    [interpolation factor m],  [Lbm],  [zb])

c_xkeep([MAX])

CCC_  * [VMTI] 3d to remember
c_reset([VMTI])
c_xincr([T],     [Temperature],                 [T],    [aa])
c_xincr([EF],    [Enhancement factor],          [ef],   [aa])

c_xincr([Wadv],  [wadv],                        [wadv], [aa])
c_xincr([Uadv],  [uadv],                        [uadv], [aa])
c_xincr([Vadv],  [vadv],                        [vadv], [aa])

c_xincr([dwdZ],  [dw/dzeta],                    [dwdZ], [aa])
c_xincr([dudZ],  [du/dzeta],                    [dudZ], [aa])
c_xincr([dvdZ],  [dv/dzeta],                    [dvdZ], [aa])

c_xincr([WHa],   [wh. wb:wi hybrid],            [wh],   [aa])
c_xincr([UHa],   [uh. ub:ui hybrid],            [uh],   [aa])
c_xincr([VHa],   [vh. vb:vi hybrid],            [vh],   [aa])

c_xincr([UHb],   [uh. ub:ui hybrid],            [uh],   [ba])
c_xincr([VHc],   [vh. vb:vi hybrid],            [vh],   [ca])

c_xincr([dTdXb], [dT/dX],                       [dTdX], [ba])
c_xincr([dTdYc], [dT/dY],                       [dTdY], [ca])

c_xincr([sh],    [strain heating],              [sh],   [aa])

c_xkeep([MAX])

CCC_  * [VMTW] 3d others
c_reset([VMTW])

c_xincr([RFb],   [Rate factor],          [rf],  [ba])
c_xincr([RFIb],  [Rate factor d-n integral], [rfi], [ba])
c_xincr([RFIIb], [Rate factor d-n double integral], [rfii], [ba])

c_xincr([RFc],   [Rate factor],          [rf],  [ca])
c_xincr([RFIc],  [Rate factor d-n integral], [rfi], [ca])
c_xincr([RFIIc], [Rate factor d-n double integral], [rfii], [ca])

c_xincr([ARFa],   [Associate enh.rate factor],   [arf],  [aa])
c_xincr([ARFd],   [Associate enh.rate factor],   [arf],  [da])

c_xincr([divHziue],          [-P1:  div H zeta int dzeta ue; div H ub], [divHziue], [aa])
c_xincr([ugradz],            [P2+3: ue grad z; ub grad b],              [ugradz],   [aa])

cc_xincr([uigradb,  ubgradb], [P2: ui grad b; ub grad b],              [uhgradb],  [aa])
cc_xincr([zuegradH, usgrads], [P3: ue zeta grad H; ue(s) grad s],      [zuegradH], [aa])

c_xincr([divuh],             [P0: div ui;   div ub],                [divuh],  [aa])
cc_xincr([divziuh],           [P0: div ziUI; div ub],                [divziuh],[aa])

C     Notes: on case DVB, ziUI are diffusion-like terms,
C     i.e., ziUI grad H == int ui d zeta
c_xincr([ziUIb, ziDIb], [int ui d zeta (ub bottom) or D(zeta)], [ziui], [ba])
c_xincr([ziVIc, ziDIc], [int vi d zeta (vb bottom) or D(zeta)], [zivi], [ca])

c_xincr([EFb],   [Enhancement factor],   [ef],  [ba])
c_xincr([EFc],   [Enhancement factor],   [ef],  [ca])
c_xincr([EFd],   [Enhancement factor],   [ef],  [da])

c_xincr([SXZb],  [Shear stress xz],       [sxz], [ba])
c_xincr([EXZb],  [Shear strain-rate xz],  [exz], [ba])
c_xincr([SYZc],  [Shear stress yz],       [syz], [ca])
c_xincr([EYZc],  [Shear strain-rate yz],  [eyz], [ca])

c_xincr([SXZa],  [Shear stress xz],       [sxz], [aa])
c_xincr([SYZa],  [Shear stress yz],       [syz], [aa])
c_xincr([EXZa],  [Shear strain-rate xz],  [exz], [aa])
c_xincr([EYZa],  [Shear strain-rate yz],  [eyz], [aa])

c_xincr([SXXa],  [stress xx],       [sxx], [aa])
c_xincr([SYYa],  [stress yy],       [syy], [aa])
c_xincr([SXYa],  [stress xy],       [sxy], [aa])
c_xincr([EXXa],  [strain-rate xx],  [exx], [aa])
c_xincr([EYYa],  [strain-rate yy],  [eyy], [aa])
c_xincr([EXYa],  [strain-rate xy],  [exy], [aa])

c_xincr([dudZ],  [dudZ],  [dudZ], [ba])
c_xincr([dvdZ],  [dvdZ],  [dvdZ], [ca])

c_xkeep([MAXD])

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

c_xincr([HS],   [HS],         [HS],  [aa])

CCc_xincr([dZdt],  [dZ/dt],                       [dZdt], [aa])
CCc_xincr([dZdx],  [dZ/dx],                       [dZdx], [aa])
CCc_xincr([dZdy],  [dZ/dy],                       [dZdy], [aa])

c_xincr([dTdXa],   [dT/dX],                       [dTdX], [aa])
c_xincr([dTdYa],   [dT/dY],                       [dTdY], [aa])

c_xincr([kti],    [thermal conductivity],    [kti],    [aa])
c_xincr([dktidz], [thermal conductivity dZ], [dktidz], [aa])
c_xincr([hcap],   [heat capacity],           [hcap],   [aa])

c_xincr([W1],   [work],      [W1],   [aa])
c_xincr([W2],   [work],      [W2],   [aa])
c_xincr([W3x],  [work],      [W3x],  [aa])
c_xincr([W3y],  [work],      [W3y],  [aa])
c_xincr([W4],   [work],      [W4],   [aa])
c_xincr([W5],   [work],      [W5],   [aa])

cc_xincr([DIVHziui, ubGRADS], [P1:  div H int ui dzeta],  [divHziui], [aa])
cc_xkeep([DIVHziue],          [PP1: div H int ue dzeta],  [divHziue], [aa])
cc_xincr([uiGRADZ,  ubGRADB], [P2:  ui grad Z],           [uigradZ],  [aa])
cc_xkeep([uiGRADB],           [PP2: ui grad b],           [uigradb], [aa])
cc_xincr([DIVuh],             [P3:  div uh (div ui:div ub)], [divuh],   [aa])
cc_xkeep([zueGRADH],          [PP3: zeta ue grad H],         [zuegradH],[aa])

cc_xincr([xDIVuh],  [xdiv uh], [xdivuh], [aa])
cc_xincr([yDIVuh],  [ydiv uh], [ydivuh], [aa])

cc_xincr([DIVuh],   [div uh],  [divuh],  [aa])

cc_xincr([xDIVzuh],  [xdiv z uh + H uii], [xdivzuh], [aa])
cc_xincr([yDIVzuh],  [ydiv z uh + H uii], [ydivzuh], [aa])
cc_xincr([DIVzuh],   [div z uh],          [divzuh],  [aa])

cc_xincr([xDIVuii],  [xdiv H uii], [xdivuii], [aa])
cc_xincr([yDIVuii],  [ydiv H uii], [ydivuii], [aa])
cc_xincr([DIVuii],   [div  H uii], [divuii],  [aa])

cc_xincr([HUHIb], [H ui integral],         [Huhi],[ba])
cc_xincr([HVHIc], [H vi integral],         [Hvhi],[ca])
cc_xincr([ZUHb],  [z ui],                  [zuh], [ba])
cc_xkeep([UHINb])
cc_xincr([ZVHc],  [z vi],                  [zvh], [ca])
cc_xkeep([VHINc])

c_xkeep([MAX])

CCC_  - [VMTA] 3d age
c_reset([VMTA])

c_xincr([age],     [age],                       [age],  [aa])
c_xincr([dad3],    [dage/dC3],                  [dad3], [aa])
c_xincr([dad1],    [dage/dC1],                  [dad1], [aa])
c_xincr([dad2],    [dage/dC2],                  [dad2], [aa])
c_xincr([dadz],    [dage/dz],                   [dadz], [aa])

CCc_xincr([Wadv],    [wadv],                    [wadv],   [aa])
CCc_xincr([Uadv],    [uadv],                    [uadv],   [aa])
CCc_xincr([Vadv],    [vadv],                    [vadv],   [aa])
c_xkeep([MAX])

CCC_  - [VMTD] 3d age others
c_reset([VMTD])

c_xincr([QD],   [matrix d],                     [qd],   [aa])
c_xincr([QU],   [matrix u],                     [qu],   [aa])
c_xincr([QL],   [matrix l],                     [ql],   [aa])
c_xincr([QB],   [matrix b],                     [qb],   [aa])

CC assumption: B11 B22  == 0

c_xincr([E1],            [coeff E1],   [E1],  [aa])
c_xincr([E2],            [coeff E2],   [E2],  [aa])
c_xincr([E3p, w3adv],    [coeff E3p],  [E3p], [aa])
c_xincr([E3m, dw3d3],    [coeff E3m],  [E3m], [aa])
c_xincr([E33],           [coeff E33],  [E33], [aa])

c_xincr([dAswp],   [dad3 switch p],   [dAswp], [aa])
c_xincr([dAswm],   [dad3 switch m],   [dAswm], [aa])

c_xincr([kai],  [age diffusivity],   [kai],    [aa])

c_xincr([W1],   [work],      [W1],   [aa])
c_xincr([W2],   [work],      [W2],   [aa])

c_xincr([a2],      [A2 coeff in RCIP numer],    [a2],     [aa])
c_xincr([a3],      [A3 coeff in RCIP numer],    [a3],     [aa])
c_xincr([ba],      [B alpha in RCIP denom],     [ba],     [aa])

c_xincr([cfl],     [CFL number],                [cfl],    [aa])
c_xincr([udt],     [upstream distance],         [udt],    [aa])

c_xkeep([MAX])


CCC_  - [VMHR] 2d boundary condition references
c_reset([VMHR])
c_xincr([REFMS],  [Surface mass balance ref],    [refMs],  [a])
c_xincr([REFTS],  [Surface temperature ref],     [refTs],  [a])
c_xkeep([MAX])

CCC_  * [VMHB] Topography and others (2d, boundary condition)
c_reset([VMHB])

c_xincr([TMBa], [Net mass balance],        [TMB],  [a])
c_xincr([MS],   [Surface mass balance],    [Ms],   [a])
c_xincr([MB],   [Basal mass balance],      [Mb],   [a])

c_xincr([TSI],  [Ts],                      [Tsi],  [a])
c_xincr([TBI],  [basal temperature],       [Tbi],  [a])
c_xincr([GH],   [geothermal heat flux],    [gh],   [a])
c_xincr([TBFLG], [Bottom temp. flag],      [Tbflg],  [a])

c_xincr([Ra],   [Bedrock topography],      [R],    [a])
c_xincr([Rb],   [Bedrock topography],      [R],    [b])
c_xincr([Rc],   [Bedrock topography],      [R],    [c])
c_xincr([Rd],   [Bedrock topography],      [R],    [d])

c_xincr([NRa],  [Bedrock topography next], [NR],   [a])
c_xincr([NRb],  [Bedrock topography next], [NR],   [b])
c_xincr([NRc],  [Bedrock topography next], [NR],   [c])

c_xincr([NRXb], [dr/dx new],               [drndx],[b])
c_xincr([NRYc], [dr/dy new],               [drndy],[c])
c_xincr([RXb],  [dr/dx old],               [drdx], [b])
c_xincr([RYc],  [dr/dy old],               [drdy], [c])

c_xincr([SLVa],  [sea level], [slv], [a])
c_xincr([SLVb],  [sea level], [slv], [b])
c_xincr([SLVc],  [sea level], [slv], [c])
c_xincr([SLVd],  [sea level], [slv], [d])

c_xincr([LMSK], [Land mask],              [lmsk], [a])

c_xincr([UMSKb], [U mask],              [umsk], [b])
c_xincr([VMSKc], [V mask],              [vmsk], [c])

c_xincr([CVBb], [VB coefficient (shear stress)], [Cvb],  [b])
c_xincr([CVBc], [VB coefficient (shear stress)], [Cvb],  [c])
c_xincr([EVBb], [VB exponent (shear stress)],    [Evb],  [b])
c_xincr([EVBc], [VB expontnt (shear stress)],    [Evb],  [c])
c_xincr([DVBb], [VB exponent (loading)],         [Dvb],  [b])
c_xincr([DVBc], [VB expontnt (loading)],         [Dvb],  [c])

c_xincr([FVBb], [VB coefficient (velocity)],     [Fvb],  [b])
c_xincr([FVBc], [VB coefficient (velocity)],     [Fvb],  [c])
c_xincr([GVBb], [VB exponent (velocity)],        [Gvb],  [b])
c_xincr([GVBc], [VB exponent (velocity)],        [Gvb],  [c])

c_xincr([GLO],  [longitude], [glo], [a])
c_xincr([GLA],  [latitude],  [gla], [a])

c_xkeep([MAX])

CCC_  * [VMHI] Topography and others (2d to remember)
c_reset([VMHI])

c_xincr([oHa],   [Ice thickness (old)],     [oH], [a])
c_xincr([oBa],   [Ice base      (old)],     [oB], [a])
c_xincr([oSa],   [Ice surface   (old)],     [oS], [a])

c_xincr([oHXa],  [dH/dx (old)],             [oHX],[a])
c_xincr([oHYa],  [dH/dy (old)],             [oHY],[a])

c_xincr([nHa],   [Ice thickness (new)],     [nH], [a])
c_xincr([nBa],   [Ice base      (new)],     [nB], [a])
c_xincr([nSa],   [Ice surface   (new)],     [nS], [a])

c_xincr([ADVXe], [advection switch xe],         [advxe],[a])
c_xincr([ADVXw], [advection switch xw],         [advxw],[a])

c_xincr([ADVYn], [advection switch yn],         [advyn],[a])
c_xincr([ADVYs], [advection switch ys],         [advys],[a])

c_xincr([frd],   [frictional dissipation (not heating)],        [frd],   [a])
c_xincr([bm],    [basal melting],                               [bm],    [a])

c_xkeep([MAX])

CCC_  * [VMHW] Temperature and others (2d)
c_reset([VMHW])

c_xincr([Hinv],  [Hinv],                        [Hinv], [a])

CCCc_xincr([dZdz],  [dZ/dz],                       [dZdz], [a])
c_xincr([dHdt],  [dH/dt],                       [dHdt], [a])
c_xincr([dBdt],  [db/dt],                       [dbdt], [a])

c_xincr([dHdx],  [dH/dx],                       [dHdx], [a])
c_xincr([dBdx],  [db/dx],                       [dbdx], [a])
c_xincr([dHdy],  [dH/dy],                       [dHdy], [a])
c_xincr([dBdy],  [db/dy],                       [dbdy], [a])

c_xincr([HSB],   [HSB],       [HSB],    [a])

c_xincr([W1],   [work],      [W1],   [a])
c_xincr([W2],   [work],      [W2],   [a])
c_xincr([W3],   [work],      [W3],   [a])

c_xkeep([MAX])

CCC_  * category table
c_reset([ICTG])

c_xincr([GLBL], [global profile domains])

c_xkeep([MAX])

CCC_  * global profiles
c_reset([GPR])

c_xincr([VOL],  [ice volume])
c_xincr([AREA], [ice area])
c_xincr([MH],   [dH/dt])
c_xincr([MS],   [surface mass balance])
c_xincr([MB],   [basal mass balance])
c_xincr([MV],   [virtual mass balance])
c_xincr([MR],   [residual mass balance])
c_xincr([ME],   [mass balance error])

c_xkeep([MAX])

CCC_  * common work area (2d)
CC maximum of [VMIW_MAX], [VMSN_MAX], [VMST_MAX], [VMSG_MAX]
[#]define VMW_MAX c_xmax([VMIW_MAX], [VMSN_MAX], [VMST_MAX], [VMSG_MAX])

c_reset([VMW])
c_xincr([W1],   [work],  [W1],  [a])
c_xincr([W2],   [work],  [W2],  [a])
c_xincr([W3],   [work],  [W3],  [a])
c_xincr([W4],   [work],  [W4],  [a])
c_xincr([W5],   [work],  [W5],  [a])
c_xincr([W6],   [work],  [W6],  [a])

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
