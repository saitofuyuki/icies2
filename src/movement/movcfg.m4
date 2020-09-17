dnl movement/movcfg.m4 --- Definition for IcIES/Movement parameters and switches
dnl Maintainer:  SAITO Fuyuki
dnl Created: Oct 31 2016
m4_define([TIME_STAMP],
          ['Time-stamp: <2020/09/15 12:18:09 fuyuki movcfg.m4>'])dnl
C movement/movcfg.h --- Definition for IcIES/Movement parameters and switches
C Maintainer:  SAITO Fuyuki
C Created: Oct 31 2016
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#ifdef HEADER_PROPERTY
[#]define _TSTAMP TIME_STAMP
#define _FNAME 'movement/movcfg.h'
#define _REV   'Snoopy0.9'
#endif /* HEADER_PROPERTY */
CCC_! MANIFESTO
C
C Copyright (C) 2016--2020
C           Japan Agency for Marine-Earth Science and Technology,
C           Ayako ABE-OUCHI
C
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
CCC_* Definitions
#ifndef    _MOVCFG_H
#  define  _MOVCFG_H
CCC_ + Movement switches
cGRP([M],   [Movement switches])
CCC_  - Thickness solver
cTAG([HSOLV], [Thickness matrix solver])
cFLG([DVB],   [Diff(grounded) E(floated)])
cFLG([ZEV],   [E])
cFLG([UP1],   [Dec(v=0) U(other)])
cFLG([UPD],   [Dec(whole)])
cFLG([UPE],   [E(grounded) Dec(other)])
cFLG([HCE],   [upwind hybrid: ZEV compatible], [], [128])
cFLG([HCU],   [upwind hybrid: UP1 compatible  Dec(v=0) U(other)])
cFLG([HCG],   [upwind hybrid: UPD compatible  Dec(whole)])
cFLG([HCH],   [upwind hybrid: UPE compatible  E(grounded) Dec(other)])
cFLG([H0],    [upwind hybrid: E(grounded)         U(other)])
cFLG([H1],    [upwind hybrid: Dec(v=0) E(front)   U(other)])
cFLG([H2],    [upwind hybrid: Dec(v=0) Dec(front) U(other)])
cFLG([CIPax], [CIP regular grid; dir. splitting; explicit], [], [256])

CCC_  - Thickness solver initial guess
cTAG([HINIG], [Thickness solver initial guess])
cFLG([ZERO],  [zero constant for the initial guess])
cFLG([PREV],  [Previous solution for the initial guess])

CCC_  - Maximum iteration for time-integration of H
cTAG([MAXITR],    [maximum iteration for dH/dt solver])

CCC_  - Maximum try
cTAG([MAXDTADJ],  [maximum trial for dt adjustement])

CCC_  - Rate factor method
cTAG([RF],     [rate factor method switch])
cFLG([CONST],  [constant rate factor])
cFLG([FLOWAR], [temperature dependent rate factor (AR)])

CCC_  - Rate factor vertical integral
cTAG([RFINTG], [rate factor integral method switch])
cFLG([CONST],  [analytical integration (only when constant)])
cFLG([EULER],  [euler integration])
cFLG([GG],     [integration with GG table])

CCC_  - Rate factor procedure
cTAG([RFINTP], [timing of rate factor interpolation])
cFLG([FIRST],  [T:a to T:bc, then rate factor])
cFLG([LAST],   [T:a to RF:a, integral, then interpolation])

CCC_  - W integral method
cTAG([WINTG],  [w integral method switch])
cFLG([SNOOPY], [consistent method with kinematic condition])
cFLG([SALLY],  [sally compatible method])
cFLG([UDB],    [snoopy compatible, but bottom bc use u grad b])

CCC_  - dH/dt computation
cTAG([DHDT], [dH/dt computation switch])
cFLG([FLUX], [use flux solution for dH/dt])
cFLG([SOL],  [H solution for dH/dt])

CCC_  - horizontal T advection
cTAG([UADV], [horizontal advection switch])
cFLG([UPH],  [use half-grid upwind])
cFLG([SELF], [use same grid])

CCC_  - vertical T advection
cTAG([WADV], [vertical advection switch])
cFLG([RAW],  [use raw w])
cFLG([XKB],  [use adjusted w with kinematic bc])

CCC_  - timing of surface gradient for the horizontal velocity
cTAG([USG],    [u v computation method])
cFLG([SNOOPY], [default])
cFLG([SALLY],  [ally compatible method (old gradient)])

CCC_  - basal sliding method
cTAG([VB],        [sliding velocity scheme])
cFLG([NONE],      [default])
cFLG([HSFUNC],    [weertman scheme var h (function of topography)])
cFLG([SALLY_WA],  [weertman scheme var a/sally (function of topography)])
cFLG([TWEERTMAN], [weertman scheme var b (function of basal stress)])

CCC_  - basal sliding occurrence
cTAG([VBSW],      [sliding velocity switch])
cFLG([AND],       [sliding when left AND right melting])
cFLG([OR],        [sliding when left OR  right melting])
cFLG([SALLY_AND], [sliding when left AND right melting (with thickness check)])
cFLG([ALL],       [sliding all])
cFLG([SUBMELT],   [sliding with submelt function])

CCC_  - ice shelf detection
cTAG([SHSW],  [shelf switch])
cFLG([DEF],   [shelf when float])
cFLG([ALL],   [shelf even when grounded])

CCC_  - surface gradient at calving fronts
cTAG([DSFR], [calving front surface gradient])
cFLG([ZERO], [zero gradient at calving front])
cFLG([KEEP], [normal gradient])

CCC_  - surface gradient at shelf ends
cTAG([DSSE],   [shelf end surface gradient])
cFLG([NORMAL], [normal gradient at shelf ends])
cFLG([DOWN_A], [downwind gradient at shelf ends])

CCC_  - temperature horizontal gradient at the bottom
cTAG([TBDZ],   [T bottom gradient method switch])
cFLG([FIRST],  [first-order difference])
cFLG([CENTER], [second-order central difference])

CCC_  - H update or not
cTAG([HUPD],  [whether to update H])
cFLG([TRUE],  [H update])
cFLG([FALSE], [H no update])

CCC_  - T update or not
cTAG([TUPD],  [whether to update T])
cFLG([TRUE],  [T update])
cFLG([FALSE], [T no update])

CCC_  - Z-loop in T solver
cTAG([TZLP],  [Z-loop outer/inner switch in T solver])
cFLG([OUTER], [outer])
cFLG([INNER], [inner])

CCC_  - strain heating procedure
cTAG([STRH],    [strain heating computation])
cFLG([DEFAULT], [se:bc, st:bc; sh:bc;      sh:a])
cFLG([SALLY],   [se:bc, st:bc; se:a, st:a; sh:a])

CCcTAG([TGRD],   [Ta grid computation switch])
dnl SW_TGRD_INTP   0  /* interpolation */
dnl SW_TGRD_DRCT   1  /* direct */

CCC_ + Movement/SSA switches
cGRP([MS],  [Movement/SSA switches])

#define SW_NOCONV_FINAL   0 /* use final solution when not converged  */
#define SW_NOCONV_SMALL   1 /* use smallest-redisual solution when not converged  */

CCC_* Index
cDIVERT(INDEX)
CCC_* End definitions
#endif  /* _MOVCFG_H */
CCC_* Obsolete
CCC_ + begin
#if 0 /* obsolete */
dnl apc_debug_prop()
dnl MINMAX
CCC_ + end
#endif /* 0 obsolete */
CCC_! FOOTER
C Local Variables:
C mode: fortran
C fff-style: "iciesShermy"
C End:
