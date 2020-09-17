C fugue/fvarms.F --- IcIES/Fugue/Variable manager
C Maintainer: SAITO Fuyuki
C Created: Aug 19 2013
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2020/09/17 08:43:55 fuyuki fvarms.F>'
#define _FNAME 'fugue/fvarms.F'
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
#include "ounelv.h"
#define  OFUGCA_DETAIL
#  include "ofugca.h" /* fugue common */
#undef   OFUGCA_DETAIL
CCC_* Options
#ifndef    OPT_NAMELIST_OUTPUT_EMULATION
#  define  OPT_NAMELIST_OUTPUT_EMULATION _UNMLEM_LEVEL_END
#endif
CCC_* Interior macros
#ifndef   OPT_FVARMS_CFG_MAX
#  define OPT_FVARMS_CFG_MAX  128
#endif
#ifndef   OPT_FVARMS_STF_MAX
#  define OPT_FVARMS_STF_MAX  2048
#endif
#ifndef   OPT_FVARMS_GRP_MAX
#  define OPT_FVARMS_GRP_MAX  32
#endif
#ifndef   OPT_FVARMS_VAR_MAX
#  define OPT_FVARMS_VAR_MAX  512
#endif
CCC_ + Attribute cluster (Configuration)
CCC_  - string
#define CA_RTM  1  /* rhythm */
#define CA_DIR  2  /* directory */
#define CA_CRT  3  /* category root */
#define CA_GRP  4  /* group */
#define CA_VAR  5  /* variable */
#define CA_COR  6  /* coordinate */
#define CA_TSW  7  /* timing switch */
#define CA_MAX  7
CCC_  - integer
#define CI_ACT  1  /* activation flag */
#define CI_IDR  2  /* rhythm id */
#define CI_IDG  3  /* group id */
#define CI_IDV  4  /* variable id */
#define CI_MAX  4
CCC_  - real standard
#define CS_START  1
#define CS_END    2
#define CS_STEP   3
#define CS_MAX    3
CCC_ + Attribute cluster (Staff)
CCC_  - integer
#define SI_GRP 1 /* group id */
#define SI_VAR 2 /* variable id */
#define SI_RTM 3 /* rhythm id */
#define SI_DIR 4 /* direction */
#define SI_ACT 5 /* activation */
#define SI_TSW 6 /* timing switch */
#define SI_MAX 6
CCC_  - string
#define SA_NAM 1 /* variable name */
#define SA_MAX 1
CCC_  - real standard
#define SS_START 1
#define SS_END   2
#define SS_DT    3
#define SS_TCUR  4
#define SS_TNXT  5
#define SS_MAX   5
CCC_ + Attribute cluster (Group)
CCC_  - integer
#define GI_VIS  1  /* variable index start */
#define GI_NMV  2  /* number of variables */
#define GI_M    3  /* effective number of items in a member */
#define GI_L    4  /* number of items of a cluster module */
#define GI_CFM  5  /* coordinate family */
#define GI_COR  6  /* standard coordinate id */
#define GI_MAX  6
CCC_  - string
#define GA_GNM  1 /* group name */
#define GA_CRT  2 /* coordinate family name */
#define GA_MAX  2
CCC_  - real standard
#define GS_DMY  1 /* dummy */
#define GS_MAX  1
CCC_ + Attribute cluster (Variable)
CCC_  - integer
#define VI_GRP 1 /* group */
#define VI_COR 2 /* coordinate id */
#define VI_STF 3
#define VI_NST 4
#define VI_MAX 4
CCC_  - string
#define VA_NAM 1 /* variable name */
#define VA_MAX 1
CCC_  - real standard
#define VS_DMY 1 /* dummy */
#define VS_MAX 1
CCC_* flags
CCC_ + status
#define RSTT_NONE 0
#define RSTT_SET  1
CCC_ + activation
#define ACTV_UNSET  0
#define ACTV_ALL    1
#define ACTV_NONE  -1
CCC_ + direction
#define DIR_NONE 0
#define DIR_ANY  1
#define DIR_W    2
#define DIR_R    3
#define DIR_P    4
#define DIR_G    5
#define DIR_IDSTR  ' WRPG'
CCC_ + switch
#define SW_NONE   0
#define SW_UNSET  1
#define SW_DEF    2
#define SW_ONCE   3
#define SW_NEVER  4
#define SW_EVERY  5
#define SW_UPDATE 6
#define SW_IDSTR  ' DONEU'
CCC_ + special
#define RHYTHM_AUTO '-'
#define RHYTHM_ANY  '*'
CCC_ + special id
#define IDG_SKIP 0   /* not specified */
#define IDG_ANY  -1  /* any group */
#define IDG_NONE -2  /* no group matched */

#define IDV_SKIP 0   /* not specified */
#define IDV_ANY  -1  /* any group */
#define IDV_NONE -2  /* no group matched */

#define IDC_SKIP 0   /* not specified */
#define IDC_ANY  -1  /* any group */
#define IDC_NONE -2  /* no group matched */
CCC_* [FVH] Helper
CCC_ & FVHini  ## initialization suite
      subroutine FVHini
     O    (iErr,
     O     ipFI,
     I     TS,  TE,  DT,  kACT,
     I     ipI, ipN, ipL, ipV)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   ipFI(*)
      _INTENT(IN, _REALSTD)  TS,  TE,   DT
      _INTENT(IN, integer)   kACT
      _INTENT(IN, integer)   ipI, ipN, ipL, ipV
      integer jCdef
CCC_  - Body
      iErr = 0
c
      if (iErr.eq.0) call FVUifp (ipFI, ipI, ipN, ipL, ipV)
      if (iErr.eq.0) call FVBrsa (iErr)
CCC_   . set sentry rhythms
      if (iErr.eq.0) then
         call FVHcrg
     O       (iErr, jCdef,
     I        ' ', ' ', ' ', TS, TE, DT, kACT, ipFI)
      endif
      if (iErr.eq.0) call FVHcrq (iErr, RHYTHM_ANY, ' ', 0, ' ', ipFI)
CCC_   . namelist configuration
      if (iErr.eq.0) call FVBrcf (iErr, jCdef, ipFI)
CCC_   . add default rhythms
      if (iErr.eq.0) call FVHcrq (iErr, ' ', 'W', 0, 'D', ipFI)
      if (iErr.eq.0) call FVHcrq (iErr, ' ', 'R', 0, 'O', ipFI)
      if (iErr.eq.0) call FVHcrq (iErr, ' ', 'P', 0, 'E', ipFI)
      if (iErr.eq.0) call FVHcrq (iErr, ' ', 'G', 0, 'U', ipFI)
c
      call DAtrcU (ipL, iErr, 'R', 'FVHINI')
      RETURN
      END
CCC_ & FVHstl  ## settlement suite
      subroutine FVHstl
     O    (iErr,
     O     ipFI)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   ipFI(*)
      integer jCdef, jCany
      integer jpL
CCC_  - Body
      iErr = 0
      jpL  = ipFI (FAI_FPL)
c
      if (iErr.eq.0) call FVBrcs (iErr, ipFI)
      if (iErr.eq.0) call FVBflv (iErr, ipFI)
      if (iErr.eq.0) then
         call FVBqiC (jCdef, ' ',        ' ')
         call FVBqiC (jCany, RHYTHM_ANY, ' ')
         call FVBstv (iErr, jCdef, jCany, ipFI)
      endif
      call DAtrcU (jpL, iErr, 'R', 'FVHSTL')
      RETURN
      END
CCC_ & FVHcrg  ## generate configuration and set
      subroutine FVHcrg
     O    (iErr,
     O     idC,
     I     RTM, DIR, TSW, TS, TE, DT, kACT, ipFI)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   idC
      _INTENT(IN, character) RTM*(*)
      _INTENT(IN, character) DIR*(*)
      _INTENT(IN, character) TSW*(*)
      _INTENT(IN, _REALSTD)  TS, TE, DT
      _INTENT(IN, integer)   kACT
      _INTENT(IN, integer)   ipFI(*)
CCC_  - Body
      iErr = 0
      call FVBgnC (idC, RTM, DIR, ipFI)
      if (idC.eq.0) then
         iErr = -1
      else
         call FVBsfC (iErr, idC, TSW, kACT, ipFI)
         call FVBstC (iErr, idC, TS,  TE,   DT, ipFI)
      endif
      RETURN
      END
CCC_ & FVHcrq  ## query configuration and set
      subroutine FVHcrq
     O    (iErr,
     I     RTM, DIR, kACT, TSW, ipFI)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, character) RTM*(*)
      _INTENT(IN, character) DIR*(*)
      _INTENT(IN, character) TSW*(*)
      _INTENT(IN, integer)   kACT
      _INTENT(IN, integer)   ipFI(*)
      integer jc
CCC_  - Body
      iErr = 0
      call FVBqiC (jc, RTM, DIR)
      if (jc.eq.0) call FVBgnC (jc, RTM, DIR, ipFI)
      if (jc.eq.0) then
         iErr = -1
      else
         call FVBsfC (iErr, jc, TSW, kACT, ipFI)
      endif
      RETURN
      END
CCC_* [FVB] Global buffer manager
CCC_ & FVBmng  ## Attribute manager
      subroutine FVBmng
     O    (iErr)
CCC_  - Declaration
      implicit none
CCC_   . Arguments
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   idG, idV
      _INTENT(OUT,integer)   idC
      _INTENT(IN, character) RTMi*(*)
      _INTENT(IN, character) DIRi*(*)
      _INTENT(IN, integer)   kACTi
      _INTENT(IN, character) TSWi*(*)
      _INTENT(IN, character) CRTi*(*)
      _INTENT(IN, character) GRPi*(*)
      _INTENT(IN, character) VARi*(*)
      _INTENT(IN, integer)   idCdef, idCany
      _INTENT(IN, integer)   idCi, idGi, idMi
      _INTENT(IN, integer)   NV
      _INTENT(IN, integer)   icH
      _INTENT(IN, integer)   MA,   LA
c$$$      _INTENT(IN, character) CSW*(*)
c$$$      _INTENT(IN, character) CLS*(*)
      _INTENT(IN, integer)   ipFI (*)
c$$$      _INTENT(IN, integer)   iMA  (*)
      _INTENT(IN, _REALSTD)  TST, TEN, DT
      _INTENT(IN, integer)   IFPl
CCC_   . Parameters
      integer    LBCfg
      parameter (LBCfg = OPT_FVARMS_CFG_MAX)
      integer    LBStf
      parameter (LBStf = OPT_FVARMS_STF_MAX)
      integer    LBGrp
      parameter (LBGrp = OPT_FVARMS_GRP_MAX)
      integer    LBVar
      parameter (LBVar = OPT_FVARMS_VAR_MAX)
c
      integer    LIC,          LAC,          LSC
      parameter (LIC = CI_MAX, LAC = CA_MAX, LSC = CS_MAX)
      integer    LIS,          LAS,          LSS
      parameter (LIS = SI_MAX, LAS = SA_MAX, LSS = SS_MAX)
      integer    LIG,          LAG,          LSG
      parameter (LIG = GI_MAX, LAG = GA_MAX, LSG = GS_MAX)
      integer    LIV,          LAV,          LSV
      parameter (LIV = VI_MAX, LAV = VA_MAX, LSV = VS_MAX)
c
      integer    LtblC,      LtblS,      LtblG,      LtblV
      parameter (LtblC = 16, LtblS = 16, LtblG = 16, LtblV = 16)
CCC_   . Buffer attributes
      integer    iTblC (LIC, LBCfg)
      character  aTblC (LAC, LBCfg)*(LtblC)
      _REALSTD   sTblC (LSC, LBCfg)
c
      integer    iTblS (LIS, LBStf)
      character  aTblS (LAS, LBStf)*(LtblS)
      _REALSTD   sTblS (LSS, LBStf)
c
      integer    iTblG (LIG, LBGrp)
      character  aTblG (LAG, LBGrp)*(LtblG)
      _REALSTD   sTblG (LSG, LBGrp)
c
      integer    iTblV (LIV, LBVar)
      character  aTblV (LAV, LBVar)*(LtblV)
      _REALSTD   sTblV (LSV, LBVar)
c
      save       iTblC, aTblC, sTblC
      save       iTblG, aTblG, sTblG
      save       iTblS, aTblS, sTblS
      save       iTblV, aTblV, sTblV
c
      integer    iBC, nBC, iBS, nBS, iBG, nBG, iBV, nBV
      save       iBC, nBC, iBS, nBS, iBG, nBG, iBV, nBV
      data       iBC, nBC, iBS, nBS, iBG, nBG, iBV, nBV / 8*0 /
c
      integer    nCsys
      save       nCsys
      data       nCsys /0/
c
      integer    ja
      integer    jc, jcc, jcn
      integer    js, jg, jr, jv
c
      integer    jpL
      character  cts, cdr
      integer    jvs
      integer    jGr, jCo
c
      character  Tmsg*(128), Tco*(16), Tva*(16)
CCC_  - Body
      iErr = 0
      RETURN
CCC_  & FVBrsa  ## reset all
      entry FVBrsa (iErr)
      iErr = 0
      if (iErr.eq.0) then
         call FVGrst
     $        (iErr, iTblG, aTblG, sTblG, LIG, LAG, LSG, 1, LBGrp)
      endif
      if (iErr.eq.0) then
         call FVVrst
     $        (iErr, iTblV, aTblV, sTblV, LIV, LAV, LSV, 1, LBVar)
      endif
      if (iErr.eq.0) then
         call FVSrst
     $        (iErr, iTblS, aTblS, sTblS, LIS, LAS, LSS, 1, LBStf)
      endif
      if (iErr.eq.0) then
         call FVCrst
     $        (iErr, iTblC, aTblC, sTblC, LIC, LAC, LSC, 1, LBCfg)
      endif
      RETURN
CCC_  & FVBqiC  ## inquiry first configuration interior
      entry FVBqiC
     O    (idC,
     I     RTMi, DIRi)
      idC = 0
      do jc = 1, nBC
         if (RTMi.eq.' ') then
            if (RTMi.eq.aTblC (CA_RTM, jc)
     $           .and.DIRi.eq.aTblC (CA_DIR, jc)) then
               idC = jc
               goto 190
            endif
         else
            if (RTMi.eq.aTblC (CA_RTM, jc)) then
               idC = jc
               goto 190
            endif
         endif
      enddo
 190  continue
      RETURN
CCC_  & FVBgnC  ## new configuration interior
      entry FVBgnC
     O    (idC,
     I     RTMi, DIRi, ipFI)
      iBC  = iBC + 1
      nBC  = min (iBC, LBcfg)
      if (iBC.le.LBcfg) then
         aTblC (CA_RTM,   iBC) = RTMi
         aTblC (CA_DIR,   iBC) = DIRi
         idC = iBC
      else
         idC = 0
      endif
      RETURN
CCC_  & FVBsfC  ## set rhythm flag
      entry FVBsfC
     O    (iErr,
     I     idCi,
     I     TSWi, kACTi, ipFI)
      iErr = 0
      if (idCi.gt.0.and.idCi.le.nBC) then
         if (TSWi.ne. ' ')          aTblC (CA_TSW, idCi) = TSWi
         if (kACTi.ne. ACTV_UNSET)  iTblC (CI_ACT, idCi) = kACTi
      else
         iErr = -1
      endif
      RETURN
CCC_  & FVBstC  ## set rhythm attributes
      entry FVBstC
     O    (iErr,
     I     idCi,
     I     TST, TEN, DT, ipFI)
      iErr = 0
      if (idCi.gt.0.and.idCi.le.nBC) then
         sTblC (CS_START, iBC) = TST
         sTblC (CS_END,   iBC) = TEN
         sTblC (CS_STEP,  iBC) = DT
      else
         iErr = -1
      endif
      RETURN
CCC_  & FVBrcf  ## run-time configuration (first)
      entry FVBrcf
     O    (iErr,
     I     idCdef, ipFI)
      iErr = 0
      if (nCsys.gt.0) then
         iErr = -1
      else
         nCsys = iBC
      endif
      if (iErr.eq.0) then
         call FVCrcf
     O       (iErr,
     O        iBC,   nBC,   LBcfg,
     M        iTblC, aTblC, sTblC, LIC, LAC, LSC,
     I        idCdef,
     I        ipFI)
      endif
      if (iErr.eq.0) then
         call FVCcad
     O       (iErr,
     I        iBC,   nBC,   LBcfg,
     M        iTblC, aTblC, sTblC, LIC, LAC, LSC,
     I        ipFI)
      endif
      if (iErr.eq.0) then
         call FVCdtm
     O       (iErr,
     I        iBC,   nBC,   LBcfg,
     M        iTblC, aTblC, sTblC, LIC, LAC, LSC,
     I        idCdef,
     I        ipFI)
      endif
      RETURN
CCC_  & FVBrcs  ## run-time configuration (second)
      entry FVBrcs
     O    (iErr,
     I     ipFI)
      call FVCrcs
     O    (iErr,
     O     iBC,   nBC,   LBcfg,
     M     iTblC, aTblC, sTblC, LIC, LAC, LSC,
     I     nCsys, ipFI)
      RETURN
CCC_  & FVBrgG  ## registration or query group
      entry FVBrgG
     O    (iErr,
     O     idG,
     I     CRTi, GRPi, MA, LA, NV, icH, ipFI)
      iErr = 0
      idG  = 0
      jpL = ipFI (FAI_FPL)
      call FVGinq
     O    (idG,
     I     iTblG, aTblG, sTblG, LIG, LAG, LSG, nBG, CRTi, GRPi, ipFI)
      if (idG.eq.0) then
         call FVGgen
     O       (iErr,
     M        iBG,   nBG,   LBgrp,
     O        iTblG, aTblG, sTblG, LIG, LAG, LSG,
     I        CRTi,  GRPi,  ipFI)
         if (iErr.eq.0) idG = iBG
      endif
      if (idG.gt.0) then
         call FVGset
     O       (iErr,
     M        iTblG, aTblG, sTblG, LIG, LAG, LSG,
     I        idG,   MA,    LA,    NV,  icH, ipFI)
      endif
      if (iErr.eq.0 .and. NV.gt.0) then
         call FVValc
     O       (iErr,
     O        jvs,
     M        iBV,   nBV,   LBVar,
     O        iTblV, aTblV, sTblV, LIV, LAV, LSV,
     I        NV,    idG,   icH,   ipFI)
         if (iErr.eq.0) iTblG (GI_VIS, idG) = jvs
      endif
      if (iErr.ne.0) idG = 0
c$$$      write (*, *) 'RGG: ', idG, GRPi
      call DAtrcU (jpL, iErr, 'R', 'FVBRGG')
      RETURN
CCC_  & FVBrgV  ## registration new variable
      entry FVBrgV
     O    (iErr,
     O     idV,
     I     idGi, idMi, VARi, icH, ipFI)
      idV  = 0
      jpL  = ipFI (FAI_FPL)
      call FVVinq
     O    (idV,
     I     iTblV, aTblV, sTblV, LIV, LAV, LSV, nBV,
     I     idGi,  VARi,  icH,   ipFI)
      if (idV.eq.0) then
         if (idMi.eq.0) then
            call FVValc
     O          (iErr,
     O           idV,
     M           iBV,   nBV,   LBvar,
     O           iTblV, aTblV, sTblV, LIV, LAV, LSV,
     I           1,     idGi,  icH,   ipFI)
            if (iErr.eq.0) then
               if (iTblG (GI_VIS, idGi).eq.0) iTblG (GI_VIS, idGi) = idV
               iTblG (GI_NMV, idGi) = iTblG (GI_NMV, idGi) + 1
            endif
         else
            idV = iTblG (GI_VIS, idGi) + idMi
         endif
c$$$         write (*, *) 'RGV', idV, idMi, VARi
         call FVVset
     O       (iErr,
     O        iTblV, aTblV, sTblV, LIV, LAV, LSV,
     I        idV,
     I        VARi,  idGi,  icH,   ipFI)
      else
         if (idMi.ne.0) then
            if (idV.ne.(iTblG (GI_VIS, idGi) + idMi)) iErr = -1
         endif
         if (iErr.eq.0) then
            call FVVset
     O          (iErr,
     O           iTblV, aTblV, sTblV, LIV, LAV, LSV,
     I           idV,
     I           VARi,  idGi,  icH,   ipFI)
         endif
      endif
      if (iErr.ne.0) idV = 0
      call DAtrcU (jpL, iErr, 'R', 'FVBRGV')
      RETURN
CCC_  & FVBflv  ## fill V attributes
      entry FVBflv
     O    (iErr,
     I     ipFI)
      iErr = 0
      do jv = 1, nBV
         jGr = iTblV (VI_GRP, jv)
         if (aTblV (VA_NAM, jv).eq.' ') then
 701        format ('G', I2.2, 'V', I4.4)
            write (Tva, 701) jGr, jv
            aTblV (VA_NAM, jv) = Tva
         endif
         if (iTblV (VI_COR, jv).eq.0) then
            iTblV (VI_COR, jv) = iTblG (GI_COR, jGr)
         endif
      enddo
      RETURN
CCC_  & FVBstv  ## staves binder
      entry FVBstv
     O    (iErr,
     I     idCdef, idCany,
     I     ipFI)
      iErr = 0
      jpL  = ipFI (FAI_FPL)
 801  format ('FVBstv:check ', I4, 1x, A)
 802  format ('  filter ', I4, 1x, A)
      do jv = 1, nBV
         jGr  = iTblV (VI_GRP, jv)
         jCo  = iTblV (VI_COR, jv)
         Tmsg = aTblG (GA_CRT, jGr)
         call UFcat2 (Tmsg, ':', aTblG (GA_GNM, jGr))
         call UFcat2 (Tmsg, ':', aTblV (VA_NAM, jv))
         call ACWtag (iErr, Tco, jCo)
         call UFcat2 (Tmsg, ':', Tco)
         if      (COND_N(jpL)) then
            write (jpL, 801) jv, _TRIM(Tmsg)
         else if (COND_S(jpL)) then
            write (*,   801) jv, _TRIM(Tmsg)
         endif
         call FVSgtb
     O       (iErr,
     O        iTblS, aTblS, sTblS, LIS, LAS, LSS, iBS, nBS, LBStf,
     I        iTblC, aTblC, sTblC, LIC, LAC, LSC,      nBC,
     I        iTblG (1,jGr),aTblG (1,jGr),sTblG (1,jGr),
     I        iTblV (1,jv), aTblV (1,jv), sTblV (1,jv),
     I        idCdef, idCany,
     I        ipFI)
      enddo
      RETURN
CCC_  & FVBarG  ## rhythm config for group
CCC_  & FVBarV  ## rhythm config for variable
CCC_  & FVBrgS  ## registration new staff interior
CCC_  & FVBrpG  ## report/G
      entry FVBrpG (iErr, IFPl)
      iErr = 0
 922  format ('FV report/G', 3I7)
 923  format (A3, 1x, 2A4, 1x, 2A7, 1x, 2A3, 1x, A8, 1x, A8)
 921  format (I3, 1x, 2I4, 1x, 2I7, 1x, 2I3, 1x, A8, 1x, A8)
      if (COND_N(IFPl)) then
         write (IFPl, 922) iBG, nBG, LBgrp
         write (IFPl, 923) 'i', 'v0', 'nv', 'm', 'l',
     $        'cf', 'cd', 'grp', 'root'
         do jg = 1, nBG
            write (IFPl, 921) jg,
     $           (iTblG (ja, jg), ja = 1, GI_MAX),
     $           (aTblG (ja, jg), ja = 1, GA_MAX)
         enddo
      else if (COND_S(IFPl)) then
#        define IFPl *
         write (IFPl, 922) iBG, nBG, LBgrp
         write (IFPl, 923) 'i', 'v0', 'nv', 'm', 'l',
     $        'cf', 'cd', 'grp', 'root'
         do jg = 1, nBG
            write (IFPl, 921) jg,
     $           (iTblG (ja, jg), ja = 1, GI_MAX),
     $           (aTblG (ja, jg), ja = 1, GA_MAX)
         enddo
#        undef  IFPl
      endif
      RETURN
CCC_  & FVBrpV  ## report/V
      entry FVBrpV (iErr, IFPl)
      iErr = 0
 932  format ('FV report/V', 3I7)
 933  format (A3, 1x, 4A4, 1x, A)
 931  format (I3, 1x, 4I4, 1x, A8)
      if (COND_N(IFPl)) then
         write (IFPl, 932) iBV, nBV, LBvar
         write (IFPl, 933) 'i', 'g', 'c', 's', 'n', 'v'
         do jv = 1, nBV
            write (IFPl, 931) jv,
     $           (iTblV (ja, jv), ja = 1, VI_MAX),
     $           (aTblV (ja, jv), ja = 1, VA_MAX)
         enddo
      else if (COND_S(IFPl)) then
#        define IFPl *
         write (IFPl, 932) iBV, nBV, LBvar
         write (IFPl, 933) 'i', 'g', 'c', 's', 'n', 'v'
         do jv = 1, nBV
            write (IFPl, 931) jv,
     $           (iTblV (ja, jv), ja = 1, VI_MAX),
     $           (aTblV (ja, jv), ja = 1, VA_MAX)
         enddo
#        undef  IFPl
      endif
      RETURN
CCC_  & FVBrpC  ## report/C
      entry FVBrpC (iErr, IFPl)
      iErr = 0
 912  format ('FV report/C', 3I7)
 913  format (A3, 1x, A12, A2, 5A8, 1x, 3A9,   1x, 4A4)
 911  format (I3, 1x, A12, A2, 5A8, 1x, 3F9.1, 1x, 4I4)
 914  format ('-')
      if (COND_N(IFPl)) then
         write (IFPl, 912) iBC, nBC, LBcfg
         write (IFPl, 913) 'i',
     $        'rtm', 'd', 'r', 'g', 'v', 'c', 't',
     $        'ts',  'te', 'dt',
     $        'a',   'ri', 'gi', 'vi'
         do jc = 1, nBC
            if (iTblC (CI_IDR, jc).ge.0) then
               jcc = jc
               do
                  write (IFPl, 911) jcc,
     $                 (aTblC (ja, jc), ja = 1, CA_MAX),
     $                 (sTblC (ja, jc), ja = 1, CS_MAX),
     $                 (iTblC (ja, jc), ja = 1, CI_MAX)
                  jcn = ABS (iTblC (CI_IDR, jcc))
                  if (jcc.eq.jcn) goto 90
                  jcc = jcn
                  if (jcc.eq.0) goto 90
               enddo
 90            continue
               write (IFPl, 914)
            endif
         enddo
      else if (COND_S(IFPl)) then
#        define IFPl *
         write (IFPl, 912) iBC, nBC, LBcfg
         write (IFPl, 913) 'i',
     $        'rtm', 'd', 'r', 'g', 'v', 'c', 't',
     $        'ts',  'te', 'dt',
     $        'a',   'ri', 'gi', 'vi'
         do jc = 1, nBC
            if (iTblC (CI_IDR, jc).ge.0) then
               jcc = jc
               do
                  write (IFPl, 911) jcc,
     $                 (aTblC (ja, jcc), ja = 1, CA_MAX),
     $                 (sTblC (ja, jcc), ja = 1, CS_MAX),
     $                 (iTblC (ja, jcc), ja = 1, CI_MAX)
                  jcn = ABS (iTblC (CI_IDR, jcc))
                  if (jcc.eq.jcn) goto 95
                  jcc = jcn
                  if (jcc.eq.0) goto 95
               enddo
 95            continue
               write (IFPl, 914)
            endif
         enddo
#        undef  IFPl
      endif
      RETURN
CCC_  - END
      END
CCC_* [FVC] Configuration buffer manipulation
CCC_ & FVCrst  ## reset attributes
      subroutine FVCrst
     O    (iErr,
     M     iTblC, aTblC, sTblC, LIC, LAC, LSC,
     I     id0,   id9)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   LIC, LAC, LSC
      _INTENT(OUT,integer)   iTblC (LIC, *)
      _INTENT(OUT,character) aTblC (LAC, *)*(*)
      _INTENT(OUT,_REALSTD)  sTblC (LSC, *)
      _INTENT(IN, integer)   id0, id9
CCC_  - Body
      iErr = 0
      call FVArst (iErr, iTblC, aTblC, sTblC, LIC, LAC, LSC, id0,id9)
      RETURN
      END
CCC_ & FVCrcf  ## read whole configuration by namelist (first)
      subroutine FVCrcf
     O    (iErr,
     O     iBC,   nBC,   LBC,
     M     iTblC, aTblC, sTblC, LIC, LAC, LSC,
     I     idCdef,
     I     ipFI)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   LIC, LAC, LSC
      _INTENT(OUT,integer)   iTblC (LIC, *)
      _INTENT(OUT,character) aTblC (LAC, *)*(*)
      _INTENT(OUT,_REALSTD)  sTblC (LSC, *)
      _INTENT(OUT,integer)   iBC, nBC
      _INTENT(IN, integer)   idCdef
      _INTENT(IN, integer)   LBC
      _INTENT(IN, integer)   ipFI (*)
c
      integer    Latt
      parameter (Latt = 16)
      character  CRT*(Latt), GRP*(Latt), VAR*(Latt), COR*(Latt)
      character  RTM*(Latt), DIR*(Latt), TSW*(Latt)
      integer    KACT
      _REALSTD   TINI, TEND, DT
c
      integer    KACTd
      _REALSTD   TSd,  TEd,  DTd
c
      integer jpI, jpN, jpL
      logical OCHK, OSKP
CCC_  - Body
      iErr = 0
      jpI  = ipFI (FAI_FPI)
      jpN  = -9
      jpL  = ipFI (FAI_FPL)
c
      TSd   = sTblC (CS_START, idCdef)
      TEd   = sTblC (CS_END,   idCdef)
      DTd   = sTblC (CS_STEP,  idCdef)
      KACTd = iTblC (CI_ACT,   idCdef)
c
      call UUrwnd (iErr, jpI)
      OSKP = .false.
      DO
         if (iErr.eq.0) then
            CRT  = ' '
            GRP  = ' '
            VAR  = ' '
            COR  = ' '
            RTM  = ' '
            DIR  = ' '
            TSW  = ' '
            KACT = KACTd
            TINI = TSd
            TEND = TEd
            DT   = DTd
            call FVCrnm
     $          (iErr,
     $           CRT, GRP,  VAR,  COR,
     $           RTM, DIR,  kACT,
     $           TSW, TINI, TEND, DT,
     $           jpI, jpN,  jpL,  OSKP)
         endif
         if (iErr.eq.0) then
            iBC = iBC + 1
            nBC = MIN (iBC, LBC)
            if (iBC.le.LBC) then
               aTblC (CA_CRT, iBC) = CRT
               aTblC (CA_GRP, iBC) = GRP
               aTblC (CA_VAR, iBC) = VAR
               aTblC (CA_COR, iBC) = COR
               aTblC (CA_RTM, iBC) = RTM
               aTblC (CA_DIR, iBC) = DIR
               aTblC (CA_TSW, iBC) = ' '
               sTblC (CS_START, iBC) = TINI
               sTblC (CS_END,   iBC) = TEND
               sTblC (CS_STEP,  iBC) = DT
               iTblC (CI_ACT, iBC) = kACT
               iTblC (CI_IDR, iBC) = 0
               iTblC (CI_IDG, iBC) = 0
               iTblC (CI_IDV, iBC) = 0
            endif
CCC_   . get sentry attributes
            OCHK = .true.
            if (aTblC (CA_CRT, iBC).ne.' ') OCHK = .false.
            if (aTblC (CA_GRP, iBC).ne.' ') OCHK = .false.
            if (aTblC (CA_VAR, iBC).ne.' ') OCHK = .false.
            if (aTblC (CA_COR, iBC).ne.' ') OCHK = .false.
            if (aTblC (CA_RTM, iBC).ne.' ') OCHK = .false.
            if (aTblC (CA_DIR, iBC).ne.' ') OCHK = .false.
            if (OCHK) then
               TSd   = TINI
               TEd   = TEND
               DTd   = DT
               kACTd = kACT
            endif
         else
            iErr = MIN (0, iErr)
            goto 100
         endif
      enddo
 100  continue
CCC_   . diag
 101  format ('FVCrcf: ', 3I5)
 102  format ('FVCrcf T/i: ', I3, 1x, 3F9.1)
 103  format ('FVCrcf T/u: ', I3, 1x, 3F9.1)
      if      (COND_N(jpL)) then
         write (jpL, 101) iBC, nBC, LBC
         write (jpL, 102)
     $        iTblC (CI_ACT,   idCdef),
     $        sTblC (CS_START, idCdef),sTblC (CS_END, idCdef),
     $        sTblC (CS_STEP,  idCdef)
         write (jpL, 103) kACTd, TSd, TEd, DTd
      else if (COND_S(jpL)) then
         write (*,   101) iBC, nBC, LBC
         write (*,   102)
     $        iTblC (CI_ACT,   idCdef),
     $        sTblC (CS_START, idCdef),sTblC (CS_END, idCdef),
     $        sTblC (CS_STEP,  idCdef)
         write (*,   103) kACTd, TSd, TEd, DTd
      endif
CCC_   . end
      if (iBC.gt.LBC) then
         iErr = -1
      else
         iErr = 0
      endif
      RETURN
      END
CCC_ & FVCcad  ## duplication adjustment
      subroutine FVCcad
     O    (iErr,
     I     iBC,   nBC,   LBC,
     M     iTblC, aTblC, sTblC, LIC, LAC, LSC,
     I     ipFI)
CCC_  - Note
CC      idR > 0   first entry, continue to idR
CC      idR < 0   intermediate entry, continue to -idR
CC      idR = jc  final entry
CC      idR = 0   special entry
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   LIC, LAC, LSC
      _INTENT(INOUT,integer)   iTblC (LIC, *)
      _INTENT(INOUT,character) aTblC (LAC, *)*(*)
      _INTENT(INOUT,_REALSTD)  sTblC (LSC, *)
      _INTENT(IN,   integer)   iBC, nBC, LBC
      _INTENT(IN,   integer)   ipFI (*)
c
      integer jpL
      integer jc1, jc2
      integer nDUP
      logical ODUP
CCC_  - Body
      iErr = 0
      jpL  = ipFI (FAI_FPL)
c
 103  format ('FVCcad: duplication [', A, ':', A, ']')
      do jc1 = 1, nBC
         iTblC (CI_IDV, jc1) = 0
      enddo
      nDUP = 0
      do jc1 = 1, nBC
         do jc2 = jc1 + 1, nBC
            ODUP = .true.
            if (aTblC (CA_RTM, jc1).eq.' ') then
               if (aTblC (CA_RTM, jc2).ne. ' ') ODUP = .false.
               if (aTblC (CA_DIR, jc1).ne.aTblC (CA_DIR, jc2)) then
                  ODUP = .false.
               endif
            else if (aTblC (CA_RTM, jc1).eq. RHYTHM_AUTO) then
               ODUP = .false.
c$$$            else if (aTblC (CA_RTM, jc1).eq. RHYTHM_ANY)  then
c$$$               ODUP = .false.
            else
               if (aTblC (CA_RTM, jc1).ne.aTblC (CA_RTM, jc2)) then
                  ODUP = .false.
               endif
            endif
            if (ODUP) then
               if      (COND_N(jpL)) then
                  write (jpL, 103)
     $                 _TRIM(aTblC (CA_RTM, jc1)),
     $                 _TRIM(aTblC (CA_DIR, jc1))
               else if (COND_S(jpL)) then
                  write (*, 103)
     $                 _TRIM(aTblC (CA_RTM, jc1)),
     $                 _TRIM(aTblC (CA_DIR, jc1))
               endif
CC             first entry
               if (iTblC (CI_IDR, jc1).eq.0) then
                  iTblC (CI_IDR, jc1) = jc2
CC             intermediate entry
               else
                  iTblC (CI_IDR, jc1) = -jc2
               endif
               iTblC (CI_IDR, jc2) = -jc2
               nDUP = nDUP + 1
               goto 190
            endif
         enddo
 190     continue
         if (iTblC (CI_IDR, jc1).eq.0) iTblC (CI_IDR, jc1) = jc1
      enddo
CCC_   . end
 101  format ('FVCcad: DUP ', I5)
      if      (COND_N(jpL)) then
         write (jpL, 101) nDUP
      else if (COND_S(jpL)) then
         write (*,   101) nDUP
      endif
      RETURN
      END
CCC_ & FVCdtm  ## default timing distribution
      subroutine FVCdtm
     O    (iErr,
     I     iBC,   nBC,   LBC,
     M     iTblC, aTblC, sTblC, LIC, LAC, LSC,
     I     idCdef,
     I     ipFI)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   LIC, LAC, LSC
      _INTENT(INOUT,integer)   iTblC (LIC, *)
      _INTENT(INOUT,character) aTblC (LAC, *)*(*)
      _INTENT(INOUT,_REALSTD)  sTblC (LSC, *)
      _INTENT(IN,   integer)   iBC, nBC, LBC
      _INTENT(IN,   integer)   idCdef
      _INTENT(IN,   integer)   ipFI (*)
      integer jpL
      integer jc
      integer jcdef, jcnxt
CCC_  - Body
      iErr = 0
      jpL  = ipFI (FAI_FPL)
      jcdef = idCdef
      do
         jcnxt = ABS (iTblC (CI_IDR, jcdef))
         if (jcnxt.eq.jcdef) goto 200
         jcdef = jcnxt
      enddo
 200  continue
      do jc = 1, LBC
         sTblC (CS_START, jc) = sTblC (CS_START, jcdef)
         sTblC (CS_END,   jc) = sTblC (CS_END,   jcdef)
         sTblC (CS_STEP,  jc) = sTblC (CS_STEP,  jcdef)
         iTblC (CI_ACT,   jc) = iTblC (CI_ACT,   jcdef)
      enddo
      RETURN
      END
CCC_ & FVCrcs  ## read whole configuration by namelist (second)
      subroutine FVCrcs
     O    (iErr,
     O     iBC,   nBC,   LBC,
     M     iTblC, aTblC, sTblC, LIC, LAC, LSC,
     I     nCskp, ipFI)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   LIC, LAC, LSC
      _INTENT(OUT,integer)   iTblC (LIC, *)
      _INTENT(OUT,character) aTblC (LAC, *)*(*)
      _INTENT(OUT,_REALSTD)  sTblC (LSC, *)
      _INTENT(OUT,integer)   iBC, nBC
      _INTENT(IN, integer)   nCskp
      _INTENT(IN, integer)   LBC
      _INTENT(IN, integer)   ipFI (*)
c
      integer    Latt
      parameter (Latt = 16)
      character  CRT*(Latt), GRP*(Latt), VAR*(Latt), COR*(Latt)
      character  RTM*(Latt), DIR*(Latt), TSW*(Latt)
      integer    KACT
      _REALSTD   TINI, TEND, DT
c
      integer jpI, jpN, jpL
      integer jc,  jcc, ja
      logical OSKP
CCC_  - Body
      iErr = 0
      jpI  = ipFI (FAI_FPI)
      jpN  = ipFI (FAI_FPN)
      jpL  = ipFI (FAI_FPL)
      call UUrwnd (iErr, jpI)
      DO jc = 1, nBC
         CRT  = aTblC (CA_CRT,   jc)
         GRP  = aTblC (CA_GRP,   jc)
         VAR  = aTblC (CA_VAR,   jc)
         COR  = aTblC (CA_COR,   jc)
         RTM  = aTblC (CA_RTM,   jc)
         DIR  = aTblC (CA_DIR,   jc)
         TSW  = aTblC (CA_TSW,   jc)
         KACT = iTblC (CI_ACT,   jc)
         TINI = sTblC (CS_START, jc)
         TEND = sTblC (CS_END,   jc)
         DT   = sTblC (CS_STEP,  jc)
 101     format ('@RTM@', I4.4)
         if (RTM.eq. RHYTHM_AUTO) write (RTM, 101) jc
         OSKP = (jc.le.nCskp)
         call FVCrnm
     $       (iErr,
     $        CRT, GRP,  VAR,  COR,
     $        RTM, DIR,  kACT,
     $        TSW, TINI, TEND, DT,
     $        jpI, jpN,  jpL,  OSKP)
         aTblC (CA_CRT, jc) = CRT
         aTblC (CA_GRP, jc) = GRP
         aTblC (CA_VAR, jc) = VAR
         aTblC (CA_COR, jc) = COR
         aTblC (CA_RTM, jc) = RTM
         aTblC (CA_DIR, jc) = DIR
         aTblC (CA_TSW, jc) = TSW
         iTblC (CI_ACT, jc) = kACT
         sTblC (CS_START, jc) = TINI
         sTblC (CS_END,   jc) = TEND
         sTblC (CS_STEP,  jc) = DT
         jcc = ABS (iTblC (CI_IDR, jc))
         if (jcc.ne.jc.and.jcc.gt.0) then
            if (RTM .ne. RHYTHM_ANY) then
               aTblC (CA_TSW,   jcc) = TSW
               iTblC (CI_ACT,   jcc) = kACT
               sTblC (CS_START, jcc) = TINI
               sTblC (CS_END,   jcc) = TEND
               sTblC (CS_STEP,  jcc) = DT
            endif
         endif
      enddo
      iErr = 0
      RETURN
      END
CCC_ & FVCrnm  ## read rhythm configuration by namelist
      subroutine FVCrnm
     O    (iErr,
     M     CRTa, GRPa,  VARa,  CORa,
     M     RTMa, DIRa,  kACTa,
     M     TSWa, TINIa, TENDa, DTa,
     I     ipI,  ipN,   ipL,   OSKP)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
c
      _INTENT(INOUT,_REALSTD)  TINIa, TENDa, DTa
      _INTENT(INOUT,integer)   kACTa
      _INTENT(INOUT,character) CRTa*(*), GRPa*(*)
      _INTENT(INOUT,character) VARa*(*), CORa*(*)
      _INTENT(INOUT,character) RTMa*(*), DIRa*(*)
      _INTENT(INOUT,character) TSWa*(*)
c
      _INTENT(IN,   integer)   ipI,  ipN,  ipL
      _INTENT(IN,   logical)   OSKP
c
      integer    LVEML
      parameter (LVEML = OPT_NAMELIST_OUTPUT_EMULATION)
c
      integer    Latt
      parameter (Latt = 16)
      character  CROOT *(Latt), GROUP*(Latt)
      character  VAR   *(Latt), COOR *(Latt)
      character  RHYTHM*(Latt), DIR  *(Latt), TFLG*(Latt)
      integer    KACT
      _REALSTD   TS, TE, DT
c
      namelist /NIFRTM/
     $     CROOT,  GROUP, VAR,   COOR,
     $     RHYTHM, DIR,   kACT,
     $     TFLG,   TS,    TE,    DT
c
      integer jos
      logical OEOF
CCC_  - Body
      iErr = 0
      jos  = 0
c
      CROOT = CRTa
      GROUP = GRPa
      VAR   = VARa
      COOR  = CORa
      RHYTHM= RTMa
      DIR   = DIRa
      TFLG  = TSWa
      kACT  = kACTa
      TS    = TINIa
      TE    = TENDa
      DT    = DTa
c
      if (.not.OSKP) READ (ipI, NIFRTM, IOSTAT = jos)
c
      if (jos.eq.0) then
         CRTa  = CROOT
         GRPa  = GROUP
         VARa  = VAR
         CORa  = COOR
         if (RHYTHM.eq. RHYTHM_AUTO .and.RTMa.ne.' ') RHYTHM = RTMa
         RTMa  = RHYTHM
         DIRa  = DIR
         TSWa  = TFLG
         kACTa = kACT
         TINIa = TS
         TENDa = TE
         DTa   = DT
         iErr  = 0
      else
         call UUieof (Oeof, jos)
         if (Oeof) then
            iErr = 1
         else
            iErr = -1
         endif
      endif
      if (jos.ne.0) call DAtrcU (ipL, jos, 'E', 'FVCRNM')
      if (LVEML.gt.0) then
         call UNBbgn (jos, 'NIFRTM',       ipN, LVEML)
         call UNBstr (jos, 'RHYTHM',RTMa,  ipN, LVEML)
         call UNBstr (jos, 'DIR',   DIRa,  ipN, LVEML)
         call UNBint (jos, 'KACT',  kACTa, ipN, LVEML)
         call UNBstr (jos, 'TFLG',  TSWa,  ipN, LVEML)
         call UNBrst (jos, 'TS',    TINIa,   ipN, LVEML)
         call UNBrst (jos, 'TE',    TENDa,   ipN, LVEML)
         call UNBrst (jos, 'DT',    DTa,   ipN, LVEML)
         call UNBstr (jos, 'CROOT', CRTa,  ipN, LVEML)
         call UNBstr (jos, 'GROUP', GRPa,  ipN, LVEML)
         call UNBstr (jos, 'VAR',   VARa,  ipN, LVEML)
         call UNBstr (jos, 'COOR',  CORa,  ipN, LVEML)
         call UNBend (jos, 'NIFRTM',       ipN, LVEML)
      else
         if (COND_N(ipN)) then
            write (ipN, NIFRTM)
         else if (COND_S(ipN)) then
            write (*,   NIFRTM)
         endif
      endif
c
      if (iErr.ne.0) call DAtrcU (ipL, iErr, 'R', 'FVCRNM')
      RETURN
      END
CCC_* [FVG] Group attribute manipulation
CCC_ & FVGrst  ## reset attributes
      subroutine FVGrst
     O    (iErr,
     O     iTblG, aTblG, sTblG, LIG, LAG, LSG,
     I     id0,   id9)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   LIG, LAG, LSG
      _INTENT(OUT,integer)   iTblG (LIG, *)
      _INTENT(OUT,character) aTblG (LAG, *)*(*)
      _INTENT(OUT,_REALSTD)  sTblG (LSG, *)
      _INTENT(IN, integer)   id0, id9
CCC_  - Body
      iErr = 0
      call FVArst (iErr, iTblG, aTblG, sTblG, LIG, LAG, LSG, id0,id9)
      RETURN
      END
CCC_ & FVGgen  ## generate group
      subroutine FVGgen
     O    (iErr,
     M     iBG,   nBG,   LBG,
     O     iTblG, aTblG, sTblG, LIG, LAG, LSG,
     I     CRT,   GRP,   ipFI)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,integer)   iBG, nBG
      _INTENT(IN,   integer)   LIG, LAG, LSG,   LBG
      _INTENT(OUT,  integer)   iTblG (LIG, *)
      _INTENT(OUT,  character) aTblG (LAG, *)*(*)
      _INTENT(OUT,  _REALSTD)  sTblG (LSG, *)
      _INTENT(IN,   character) CRT*(*), GRP*(*)
      _INTENT(IN,   integer)   ipFI (*)
CCC_  - Body
      iErr = 0
      iBG  = iBG + 1
      nBG  = min (iBG, LBG)
      if (iBG.le.LBG) then
         aTblG (GA_CRT, iBG) = CRT
         aTblG (GA_GNM, iBG) = GRP
         iTblG (GI_VIS, iBG) = 0
         iTblG (GI_M,   iBG) = 0
         iTblG (GI_L,   iBG) = 0
         iTblG (GI_NMV, iBG) = 0
         iTblG (GI_COR, iBG) = 0
      else
         iErr = -1
      endif
      RETURN
      END
CCC_ & FVGinq  ## inquire group
      subroutine FVGinq
     O    (idG,
     I     iTblG, aTblG, sTblG, LIG, LAG, LSG, nBG,
     I     CRT,   GRP,   ipFI)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   idG
      _INTENT(IN, integer)   LIG, LAG, LSG
      _INTENT(OUT,integer)   iTblG (LIG, *)
      _INTENT(OUT,character) aTblG (LAG, *)*(*)
      _INTENT(OUT,_REALSTD)  sTblG (LSG, *)
      _INTENT(IN, integer)   nBG
      _INTENT(IN, character) CRT*(*), GRP*(*)
      _INTENT(IN, integer)   ipFI (*)
      integer jg
      logical Omatch
CCC_  - Body
      idG  = 0
      do jg = 1, nBG
         Omatch = .true.
         if (CRT.ne.aTblG (GA_CRT, jg)) Omatch = .false.
         if (GRP.ne.aTblG (GA_GNM, jg)) Omatch = .false.
         if (Omatch) then
            idG = jg
            goto 190
         endif
      enddo
 190  continue
      RETURN
      END
CCC_ & FVGset  ## set or check attributes
      subroutine FVGset
     O    (iErr,
     O     iTblG, aTblG, sTblG, LIG, LAG, LSG,
     I     idG,
     I     MA,    LA,    NV,    icH, ipFI)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   LIG, LAG, LSG
      _INTENT(OUT,  integer)   iTblG (LIG, *)
      _INTENT(OUT,  character) aTblG (LAG, *)*(*)
      _INTENT(OUT,  _REALSTD)  sTblG (LSG, *)
      _INTENT(IN,   integer)   idG
      _INTENT(IN,   integer)   MA, LA, NV, icH
      _INTENT(IN,   integer)   ipFI (*)
      integer jpL
CCC_  - Body
      iErr = 0
      jpL = ipFI (FAI_FPL)
      if (iErr.eq.0) call FVUzsi (iErr, iTblG (GI_M,   idG), MA)
      if (iErr.eq.0) call FVUzsi (iErr, iTblG (GI_L,   idG), LA)
      if (iErr.eq.0) call FVUzsi (iErr, iTblG (GI_NMV, idG), NV)
      if (iErr.eq.0) call FVUzsi (iErr, iTblG (GI_COR, idG), icH)
 101  format ('FVGSET/N[', I3.3, '] ', 4I7)
 102  format ('FVGSET/O[', I3.3, '] ', 4I7)
      if      (COND_N(jpL)) then
         write (jpL, 101) idG, MA, LA, NV, icH
      else if (COND_S(jpL)) then
         write (*,   101) idG, MA, LA, NV, icH
      endif
      if (iErr.ne.0) then
         if      (COND_N(jpL)) then
            write (jpL, 102) idG,
     $           iTblG (GI_M,  idG), iTblG (GI_L,  idG),
     $           iTblG (GI_NMV,idG), iTblG (GI_COR,idG)
         else if (COND_S(jpL)) then
            write (*,   102) idG,
     $           iTblG (GI_M,  idG), iTblG (GI_L,  idG),
     $           iTblG (GI_NMV,idG), iTblG (GI_COR,idG)
         endif
      endif
      RETURN
      END
CCC_* [FVS] Staff attribute manipulation
CCC_ & FVSrst  ## reset attributes
      subroutine FVSrst
     O    (iErr,
     M     iTblS, aTblS, sTblS, LIS, LAS, LSS,
     I     id0,   id9)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   LIS, LAS, LSS
      _INTENT(OUT,integer)   iTblS (LIS, *)
      _INTENT(OUT,character) aTblS (LAS, *)*(*)
      _INTENT(OUT,_REALSTD)  sTblS (LSS, *)
      _INTENT(IN, integer)   id0, id9
CCC_  - Body
      iErr = 0
      call FVArst (iErr, iTblS, aTblS, sTblS, LIS, LAS, LSS, id0,id9)
      RETURN
      END
CCC_ & FVSgtb   ## staff table generation for a variable
      subroutine FVSgtb
     O    (iErr,
     O     iTblS,  aTblS, sTblS, LIS, LAS, LSS, iBS, nBS, LBS,
     I     iTblC,  aTblC, sTblC, LIC, LAC, LSC,      nBC,
     I     iTblG,  aTblG, sTblG,
     I     iTblV,  aTblV, sTblV,
     I     idCdef, idCany,
     I     ipFI)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,integer)   iBS, nBS
      _INTENT(IN,   integer)   LIS, LAS, LSS,   LBS
      _INTENT(IN,   integer)   LIC, LAC, LSC,   nBC
      _INTENT(INOUT,integer)   iTblS (LIS, *)
      _INTENT(INOUT,character) aTblS (LAS, *)*(*)
      _INTENT(INOUT,_REALSTD)  sTblS (LSS, *)
      _INTENT(IN,   integer)   iTblC (LIC, *)
      _INTENT(IN,   character) aTblC (LAC, *)*(*)
      _INTENT(IN,   _REALSTD)  sTblC (LSC, *)
      _INTENT(IN,   integer)   iTblG (*),     iTblV (*)
      _INTENT(IN,   character) aTblG (*)*(*), aTblV (*)*(*)
      _INTENT(IN,   _REALSTD)  sTblG (*),     sTblV (*)
      _INTENT(IN,   integer)   idCdef, idCany
      _INTENT(IN,   integer)   ipFI (*)
      integer jc, jcc, jcs, jcn
      integer kACT (16)
      integer kd
      logical Omatch
CCC_  - Body
      iErr = 0
      do jc = 1, nBC
         if (jc.ne.idCdef.and.jc.ne.idCany
     $        .and. iTblC (CI_IDR, jc) .gt.0) then
            jcc = jc
            jcs = idCany
            kACT (DIR_W) = iTblC (CI_ACT, idCdef)
            kACT (DIR_R) = iTblC (CI_ACT, idCdef)
            kACT (DIR_G) = iTblC (CI_ACT, idCdef)
            kACT (DIR_P) = iTblC (CI_ACT, idCdef)
            write (*, *) 'new rhythm', jcc, jcs
            do
               if (jcc.gt.nBC .and. jcs.gt.nBC) goto 100
               if (jcc.lt.jcs) then
                  if (iTblC (CI_ACT, jcc) .ne. 0) then
                     call FVUd2k (kd, aTblC (CA_DIR, jcc))
                     if (kd.eq. DIR_ANY) then
                        kACT (DIR_W) = iTblC (CI_ACT, jcc)
                        kACT (DIR_R) = iTblC (CI_ACT, jcc)
                        kACT (DIR_G) = iTblC (CI_ACT, jcc)
                        kACT (DIR_P) = iTblC (CI_ACT, jcc)
                     else
                        kACT (kd) = iTblC (CI_ACT, jcc)
                     endif
                  endif
                  jcn = ABS(iTblC (CI_IDR, jcc))
                  if (jcc.eq.jcn) then
                     jcc = nBC + 1
                  else
                     jcc = jcn
                  endif
               else
                  jcn = ABS(iTblC (CI_IDR, jcs))
                  if (jcs.eq.jcn) then
                     jcs = nBC + 1
                  else
                     jcs = jcn
                  endif
               endif
            enddo
 100        continue
            write (*, *) 'activation: ',
     $           kACT (DIR_W), kACT (DIR_R),
     $           kACT (DIR_P), kACT (DIR_G)
         endif
      enddo
c$$$         if (iTblC (CI_IDR, jc).eq.0) then
c$$$            Tmsg = aTblC (CA_RTM, jc)
c$$$            call UFcat2 (Tmsg, ':', aTblC (CA_DIR, jc))
c$$$            call UFcat2 (Tmsg, ':', aTblC (CA_CRT, jc))
c$$$            call UFcat2 (Tmsg, ':', aTblC (CA_GRP, jc))
c$$$            call UFcat2 (Tmsg, ':', aTblC (CA_VAR, jc))
c$$$            call UFcat2 (Tmsg, ':', aTblC (CA_COR, jc))
c$$$            if      (COND_N(jpL)) then
c$$$               write (jpL, 802) jc, _TRIM(Tmsg)
c$$$            else if (COND_S(jpL)) then
c$$$               write (*,   802) jc, _TRIM(Tmsg)
c$$$            endif
c$$$         endif
      RETURN
      END
CCC_* [FVV] Variable attribute manipulation
CCC_ & FVVrst  ## reset attributes
      subroutine FVVrst
     O    (iErr,
     M     iTblV, aTblV, sTblV, LIV, LAV, LSV,
     I     id0,   id9)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   LIV, LAV, LSV
      _INTENT(OUT,integer)   iTblV (LIV, *)
      _INTENT(OUT,character) aTblV (LAV, *)*(*)
      _INTENT(OUT,_REALSTD)  sTblV (LSV, *)
      _INTENT(IN, integer)   id0, id9
CCC_  - Body
      iErr = 0
      call FVArst (iErr, iTblV, aTblV, sTblV, LIV, LAV, LSV, id0,id9)
      RETURN
      END
CCC_ & FVValc  ## allocation
      subroutine FVValc
     O    (iErr,
     O     ivstt,
     M     iBV,   nBV,   LBV,
     M     iTblV, aTblV, sTblV, LIV, LAV, LSV,
     I     NV,    idG,   icH,   ipFI)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(OUT,  integer)   ivstt
      _INTENT(INOUT,integer)   iBV, nBV
      _INTENT(IN,   integer)   LIV, LAV, LSV, LBV
      _INTENT(OUT,  integer)   iTblV (LIV, *)
      _INTENT(OUT,  character) aTblV (LAV, *)*(*)
      _INTENT(OUT,  _REALSTD)  sTblV (LSV, *)
      _INTENT(IN,   integer)   NV
      _INTENT(IN,   integer)   idG, icH
      _INTENT(IN,   integer)   ipFI (*)
      integer jv
      character TV*(16)
CCC_  - Body
      iErr  = 0
      ivstt = iBV + 1
      iBV   = iBV + NV
      nBV   = MIN (iBV, LBV)
      do jv = ivstt, nBV
         iTblV (VI_GRP, jv) = idG
         iTblV (VI_COR, jv) = 0
         iTblV (VI_STF, jv) = 0
         iTblV (VI_NST, jv) = 0
c$$$ 101     format ('G', I2.2, 'V', I3.3)
c$$$         write (TV, 101) idG, (jv - ivstt)
c$$$         aTblV (VA_NAM, jv) = TV
         aTblV (VA_NAM, jv) = ' '
      enddo
      if (iBV.gt.LBV) iErr = -1
      RETURN
      END
CCC_ & FVVinq  ## inquire variable
      subroutine FVVinq
     O    (idV,
     I     iTblV, aTblV, sTblV, LIV, LAV, LSV, nBV,
     I     idG,   VAR,   icH,   ipFI)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   idV
      _INTENT(IN, integer)   LIV, LAV, LSV
      _INTENT(OUT,integer)   iTblV (LIV, *)
      _INTENT(OUT,character) aTblV (LAV, *)*(*)
      _INTENT(OUT,_REALSTD)  sTblV (LSV, *)
      _INTENT(IN, integer)   nBV
      _INTENT(IN, character) VAR*(*)
      _INTENT(IN, integer)   idG, icH
      _INTENT(IN, integer)   ipFI (*)
      integer jv
      logical Omatch
CCC_  - Body
      idV  = 0
      do jv = 1, nBV
         Omatch = .true.
         if (VAR.ne.aTblV (VA_NAM, jv)) Omatch = .false.
         if (idG.ne.iTblV (VI_GRP, jv)) Omatch = .false.
         if (icH.ne.iTblV (VI_COR, jv)) Omatch = .false.
         if (Omatch) then
            idV = jv
            goto 190
         endif
      enddo
 190  continue
      RETURN
      END
CCC_ & FVVset  ## set or check attributes
      subroutine FVVset
     O    (iErr,
     O     iTblV, aTblV, sTblV, LIV, LAV, LSV,
     I     idV,
     I     VAR,   idG,   icH,   ipFI)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   LIV, LAV, LSV
      _INTENT(OUT,  integer)   iTblV (LIV, *)
      _INTENT(OUT,  character) aTblV (LAV, *)*(*)
      _INTENT(OUT,  _REALSTD)  sTblV (LSV, *)
      _INTENT(IN,   character) VAR*(*)
      _INTENT(IN,   integer)   idV
      _INTENT(IN,   integer)   idG, icH
      _INTENT(IN,   integer)   ipFI (*)
      integer jpL
CCC_  - Body
      iErr = 0
      jpL = ipFI (FAI_FPL)
      if (iErr.eq.0) call FVUzsi (iErr, iTblV (VI_COR, idV), icH)
      if (iErr.eq.0) call FVUzsi (iErr, iTblV (VI_GRP, idV), idG)
      if (iErr.eq.0) call FVUzsa (iErr, aTblV (VA_NAM, idV), VAR)
 101  format ('FVVSET/N[', I3.3, '] ', 2I7, 1x, A)
 102  format ('FVVSET/O[', I3.3, '] ', 2I7, 1x, A)
      if      (COND_N(jpL)) then
         write (jpL, 101) idV, idG, icH, _TRIM(VAR)
      else if (COND_S(jpL)) then
         write (*,   101) idV, idG, icH, _TRIM(VAR)
      endif
      if (iErr.ne.0) then
         if      (COND_N(jpL)) then
            write (jpL, 102) idV,
     $           iTblV (VI_GRP,idV), iTblV (VI_COR,idV),
     $           _TRIM(aTblV (VA_NAM,idV))
         else if (COND_S(jpL)) then
            write (*,   102) idV,
     $           iTblV (VI_GRP,idV), iTblV (VI_COR,idV),
     $           _TRIM(aTblV (VA_NAM,idV))
         endif
      endif
      RETURN
      END
CCC_* [FVA] Attribute manipulation primitives
CCC_ & FVArst  ## reset attributes general
      subroutine FVArst
     O    (iErr,
     M     iTbl,  aTbl, sTbl, LI, LA, LS,
     I     id0,   id9)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   LI, LA, LS
      _INTENT(OUT,integer)   iTbl (LI, *)
      _INTENT(OUT,character) aTbl (LA, *)*(*)
      _INTENT(OUT,_REALSTD)  sTbl (LS, *)
      _INTENT(IN, integer)   id0, id9
      integer ja, ji
CCC_  - Body
      iErr = 0
      if (iErr.eq.0) then
         do ji = id0, id9
            do ja = 1, LI
               iTbl (ja, ji) = 0
            enddo
            do ja = 1, LA
               aTbl (ja, ji) = ' '
            enddo
            do ja = 1, LS
               sTbl (ja, ji) = 0.0d0
            enddo
         enddo
      endif
      RETURN
      END
CCC_ & FVAinq  ## name inquiry general
      subroutine FVAinq
     O    (ID,
     I     aTbl, kNM, LA, NB,  CNM)
      implicit none
      _INTENT(OUT,integer)   ID
      _INTENT(IN, integer)   kNM, LA, NB
      _INTENT(IN, character) aTbl (LA, *)*(*)
      _INTENT(IN, character) CNM*(*)
      integer jb
      ID = 0
      do jb = 1, NB
         if (aTbl (kNM, jb) .eq. CNM) then
            ID = jb
            goto 100
         endif
      enddo
 100  continue
      RETURN
      END
CCC_* [FVU] utilities
CCC_ + FVUzsi  ## attribute set (integer)
      subroutine FVUzsi
     O    (iErr,
     M     ITB,
     I     IV)
      implicit none
      _INTENT(OUT,  integer) iErr
      _INTENT(INOUT,integer) ITB
      _INTENT(IN,   integer) IV
      iErr = 0
      if (ITB.eq.0) then
         ITB  = IV
      else if (IV.eq.0) then
         continue
      else if (ITB.ne.IV) then
         iErr = -1
      endif
      RETURN
      END
CCC_ + FVUzsa  ## attribute set (string)
      subroutine FVUzsa
     O    (iErr,
     M     ATB,
     I     AV)
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,character) ATB*(*)
      _INTENT(IN,   character) AV*(*)
      iErr = 0
      if (ATB.eq.' ') then
         ATB  = AV
      else if (AV.eq.' ') then
         continue
      else if (ATB.ne.AV) then
         iErr = -1
      endif
      RETURN
      END
CCC_ + Rhythm name default
      subroutine FVUrns (TRTM, DIR)
      implicit none
      _INTENT(OUT,character) TRTM*(*)
      _INTENT(IN, character) DIR*(*)
 101  format ('@RTM@', A)
      write (TRTM, 101) _TRIM(DIR)
      RETURN
      END
CCC_ + direction to kind id
      subroutine FVUd2k (kdir, DIR)
      implicit none
      _INTENT(OUT,integer)   kdir
      _INTENT(IN, character) DIR*(*)
      character B
      B = DIR (1:1)
      kdir = INDEX (DIR_IDSTR, B)
      RETURN
      END
CCC_ + timing switch to kind id
      subroutine FVUs2k (ktsw, TSW)
      implicit none
      _INTENT(OUT,integer)   ktsw
      _INTENT(IN, character) TSW*(*)
      character B
      B = TSW (1:1)
      ktsw = INDEX (SW_IDSTR, B)
      RETURN
      END
CCC_ + direction from kind id
      subroutine FVUk2d (kdir, DIR)
      implicit none
      _INTENT(IN, integer)   kdir
      _INTENT(OUT,character) DIR*(*)
      character  S*(*)
      parameter (S = DIR_IDSTR)
      integer l
      l = len (S)
      if (kdir.le.0.or.kdir.gt.l) then
         DIR = '!'
      else
         DIR = S (kdir:kdir)
      endif
      RETURN
      END
CCC_ + timing switch from kind id
      subroutine FVUk2s (ktsw, TSW)
      implicit none
      _INTENT(IN, integer)   ktsw
      _INTENT(OUT,character) TSW*(*)
      character  S*(*)
      parameter (S = SW_IDSTR)
      integer l
      l = len (S)
      if (ktsw.le.0.or.ktsw.gt.l) then
         TSW = '!'
      else
         TSW = S (ktsw:ktsw)
      endif
      RETURN
      END
CCC_ & FVUifp  ## set file unit cluster
      subroutine FVUifp
     O    (ipFI,
     I     ipI, ipN, ipL, ipV)
      implicit none
      _INTENT(OUT,integer) ipFI (*)
      _INTENT(IN, integer) ipI, ipN, ipL, ipV
      ipFI (FAI_FPI) = ipI
      ipFI (FAI_FPN) = ipN
      ipFI (FAI_FPL) = ipL
      ipFI (FAI_FPV) = ipV
      RETURN
      END
CCC_& FVARMS  ## IcIES/Fugue/Variable manager announcement
      subroutine FVARMS (STRA, STRB, IOP)
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
CCC_* TEST
CCC_ + begin
#if TEST_FVARMS
CCC_ @ FVTEST  ## Fugue/Variable test main
      program FVTEST
CCC_  - Test suites
CC::   SOURCES
CCC_  - Declaration
#include "odevid.h"  /* MPI table */
      implicit none
      integer iErr
      integer ipA (LOG_CHANNEL_MAX)
      integer iMA (MAX_MPI_ATTR)
#define _CLS 'V'
CCC_  - Body
      call DDsmpl (iErr)
c$$$      call DDcapo
c$$$     O    (iErr,
c$$$     I     2, ' ', 'O', _FNAME, -1)
      if (iErr.eq.0) then
         call DLCmng (ipA, 't')
         call DVHrgC (iErr, _CLS, ' ', ' ', ipA)
      endif
      if (iErr.eq.0) then
         call DMAtma (iMA)
         call FVTESTmain (iErr, ipA, iMA)
      endif
      call DevFin (iErr)
      STOP
      END
CCC_ & FVTESTmain
      subroutine FVTESTmain (iErr, ipA, iMA)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(IN, integer) ipA (*)
      _INTENT(IN, integer) iMA (*)
      integer ipFI (16)
      integer ipL, ipP, ipC, ipV
c
      integer  idGa, idGb
      integer  idVa, idVb
      integer  idVx, idVy
      _REALSTD TS, TE, DT
CCC_  - Body
      iErr = 0
c
      ipL  = FPL(ipA)
      ipP  = FPP(ipA)
      ipC  = FPC(ipA)
      ipV  = FPV(ipA)
c
      TS = 0.0d0
      TE = 10.0d0
      DT = 1.0d0
c
      call FVHini
     $     (iErr, ipFI, TS, TE, DT, ACTV_NONE, ipP, ipC, ipL, ipV)
c
C                                          M  L  V  C
      call FVBrgG (iErr, idGa, 'ID', 'GA', 1, 2, 3, 4, ipFI)
      call FVBrgG (iErr, idGb, 'ID', 'GB', 0, 0, 0, 0, ipFI)
      call FVBrgG (iErr, idGb, 'ID', 'GB', 1, 2, 3, 4, ipFI)
c$$$      call FVBrgG (iErr, idGb, 'ID', 'GB', 0, 0, 0, 0, ipFI)
c$$$      call FVBrgG (iErr, idGb, 'ID', 'GB', 1, 2, 1, 1, ipFI)
c
C                                    M          C
      call FVBrgV (iErr, idVa, idGb, 0, 'FOOa', 1, ipFI)
      call FVBrgV (iErr, idVb, idGb, 2, 'FOOb', 1, ipFI)
      call FVBrgV (iErr, idVx, idGa, 1, 'BARx', 1, ipFI)
      call FVBrgV (iErr, idVy, idGa, 0, 'BARy', 1, ipFI)
c
      call FVHstl (iErr, ipFI)
c
      call FVBrpC (iErr, ipL)
      call FVBrpG (iErr, ipL)
      call FVBrpV (iErr, ipL)
      RETURN
      END
CCC_ + end
#endif /* TEST_FVARMS */
CCC_* obsolete
CCC_ + begin
#if 0 /* obsolete */
CCC_ + end obsolete
#endif /* 0 obsolete */
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
