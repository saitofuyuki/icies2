C movement/mutcfg.F --- IcIES/Movement/Utility test configuration
C Maintainer:  SAITO Fuyuki
C Created: Oct 23 2012
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2020/09/17 08:47:34 fuyuki mutcfg.F>'
#define _FNAME 'movement/mutcfg.F>'
#define _REV   'Snoopy0.97'
CCC_! MANIFESTO
C
C Copyright (C) 2012--2020
C           Japan Agency for Marine-Earth Science and Technology,
C           Ayako ABE-OUCHI
C
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
CCC_* Common macros
#include "ofdlct.h"   /* fortran dialect */
#include "oarpea.h"
#include "oarpkw.h"   /* operation id in arpeggio/kiwi */
#include "odevva.h"
#include "ologfm.h"
#include "ounelv.h" /* namelist emulation levels */
#ifdef NO_MOVEMENT_H
#else
#  include "movement.h" /* movement definitions */
#endif
#include "mutests.h" /* Test definitions */
CCC_ + System-dependent switches
#ifndef   OPT_FORMAT_STAR
#  define OPT_FORMAT_STAR 0
#endif
#if OPT_FORMAT_STAR
#  define _FORMAT(F) *
#else
#  define _FORMAT(F) F
#endif
CCC_ + test configuration
#define CONFIG_DEFAULT  -1

#define BATCH_BENCHFIX  0
#define BATCH_BENCHMOV  1
#define BATCH_RSLOPE    2
#define BATCH_MISMIP1   3
#define BATCH_HEINO     4
#define BATCH_MISMIP3   5
#define BATCH_READ      6  /* read file and distribute */
#define BATCH_MISMIP_P  7  /* MISMIP+ 2016 */
#define BATCH_EP2S      8  /* EISMINT phase II sliding */

#define BATCH_USR_A    101 /* user-defined batch configuration A */

CCC_  - bedrock
#define CONFIG_R_FLAT     0  /* flat */
#define CONFIG_R_RCOS     1  /* cosine */
#define CONFIG_R_SLOPE    2
#define CONFIG_R_MISMIP1  3
#define CONFIG_R_MISMIP3  4
#define CONFIG_R_READ     5
#define CONFIG_R_RGAUSS   6  /* gauss */
#define CONFIG_R_MISMIP_P 7
#define CONFIG_R_RCANAL   8  /* canal */

#define CONFIG_R_USR_ENDS 101 /* user-defined A. two ends */
#define CONFIG_R_USR_POLI 102 /* user-defined B. polinomial */

CCC_  - thickness
#define CONFIG_H_CONST   0  /* const */
#define CONFIG_H_READ    1

CCC_  - mask
#define CONFIG_M_RECT     0
#define CONFIG_M_HEINO    1
#define CONFIG_M_READ     2
#define CONFIG_M_MISMIP_P 3
CCC_  - basal sliding
#define CONFIG_VB_UNIFORM 0
#define CONFIG_VB_HEINO   1
#define CONFIG_VB_READ    2
CCC_  - surface temperature
#define CONFIG_TS_BENCHFIX 0
#define CONFIG_TS_BENCHMOV 1
#define CONFIG_TS_HEINO    2
#define CONFIG_TS_UNIFORM  3
#define CONFIG_TS_SR0AA    4 /* SeaRISE/0 AA */
#define CONFIG_TS_EP2S     5 /* EISMINT phase ii sliding */
CCC_  - bottom temperature
#define CONFIG_TB_FIX      0
#define CONFIG_TB_PMP      1
#define CONFIG_TB_GRAD     2
#define CONFIG_TB_GEO      3 /* ariticial test, use geot even under shelves */
CCC_  - surface mass balance
#define CONFIG_MS_UNIFORM  0
#define CONFIG_MS_BENCHMOV 1
#define CONFIG_MS_HEINO    2
#define CONFIG_MS_FILE     3 /* constant mass balance (file) */
#define CONFIG_MS_ELA      4
CCC_  - shelf-base mass balance
#define CONFIG_MBSH_UNIFORM  0
#define CONFIG_MBSH_MISMIP_P 1
CCC_  - v mask
#define CONFIG_VMSK_NONE     0
#define CONFIG_VMSK_MISIMP_P 1
CCC_  - shelf
#define CONFIG_C2D 0 /* circular 2d */
#define CONFIG_X1D 1 /* 1d x direction */
#define CONFIG_Y1D 2 /* 1d y direction */
#define CONFIG_X2D 3 /* 2d x direction (lateral wall) */
#define CONFIG_Y2D 4 /* 2d y direction (lateral wall) */
c
#define CONFIG_MIN 0
#define CONFIG_MAX 4
CCC_ + Options
#ifndef    OPT_NAMELIST_OUTPUT_EMULATION
#  define  OPT_NAMELIST_OUTPUT_EMULATION _UNMLEM_LEVEL_END
#endif

#define OPT_INIT_MAXREC 1024
CCC_* Health check
CCC_ & MUThch  ## Test configuration check
      subroutine MUThch
     O    (iErr,
     I     MAXMTI, MAXMTP,
     I     ipP,    ipC,    ipL)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   MAXMTI, MAXMTP
      _INTENT(IN, integer)   ipP, ipC, ipL
CCC_  - Body
      iErr = 0
      if (MAXMTI.lt. IMTI_MAX) then
         iErr = iErr - 1
         write (ipL, 101) 'MAXMTI', MAXMTI, IMTI_MAX
      endif
      if (MAXMTP.lt. PMTI_MAX) then
         iErr = iErr - 1
         write (ipL, 101) 'MAXMTP', MAXMTP, PMTI_MAX
      endif
 101  format ('MUTHCH:', A, 1x, 2I12)
      call DAtrcU (ipL, iErr, 'R', 'MUTHCH')
      RETURN
      END
CCC_* SIA
CCC_ & MUTmsi  ## Test configuration suite (movement/SIA)
      subroutine MUTmsi
     O    (iErr,
     O     IMTI, PMTI,
     O     VMHR, VMHB, VMHI, VMTI, VMTW, VMI,
     W     CW,
     I     PMD,  IMD,  WW,   WZV,  GG,  NTH,
     L     MH,   LH,   NZ,   LZ,   KZ0,
     C     CR,   ipKW, iMA,  IE,   ipP, ipC, ipL)
CCC_  - Description
CC   set  VMI  CLa Ha  RFb RFc
CC   set  VMHB all
CCC_  - Declaration
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   MH, LH
      _INTENT(IN, integer)   NZ, LZ, KZ0
      _INTENT(IN, integer)   NTH
c
      _INTENT(OUT,integer)   IMTI (*)
      _INTENT(OUT,_REALSTD)  PMTI (*)
c
      _INTENT(OUT,_REALSTD)  CW   (*)
c
      _INTENT(OUT,_REALSTD)  VMI  (*)
      _INTENT(OUT,_REALSTD)  VMHI (*)
      _INTENT(OUT,_REALSTD)  VMHR (*)
      _INTENT(OUT,_REALSTD)  VMHB (*)
      _INTENT(OUT,_REALSTD)  VMTI (*)
      _INTENT(OUT,_REALSTD)  VMTW (*)
      _INTENT(IN, _REALSTD)  PMD  (*)
      _INTENT(IN, integer)   IMD  (*)
      _INTENT(IN, _REALSTD)  WW   (*)
      _INTENT(IN, _REALSTD)  WZV  (*)
      _INTENT(IN, _REALSTD)  GG   (*)
      _INTENT(IN, character) CR*(*)
      _INTENT(IN, integer)   ipKW (*)
      _INTENT(IN, integer)   iMA  (*)
      _INTENT(IN, integer)   IE   (*)
      _INTENT(IN, integer)   ipP, ipC, ipL
CCC_  - Body
      iErr = 0
c
      if (iErr.eq.0) then
         call MUTpmi
     O       (iErr,
     O        IMTI, PMTI,
     I        CR,   ipP,  ipC, ipL)
      endif
c
      if (iErr.eq.0) then
         call MUTami
     O       (iErr,
     O        VMHR, VMHB, VMHI, VMTI, VMTW, VMI,
     W        CW,
     I        PMD,  IMD,  WW,   WZV,  GG,   NTH,  IMTI, PMTI,
     I        MH,   LH,   NZ,   LZ,   KZ0,
     I        CR,   ipKW, iMA,  IE,   ipP,  ipC,  ipL)
      endif

      if (iErr.eq.0) then
         call MUTvmi
     O       (iErr,
     O        VMHR, VMHB, VMHI, VMTI, VMTW, VMI,
     W        CW,
     I        PMD,  IMD,  WW,   WZV,  GG,   NTH,  IMTI, PMTI,
     I        MH,   LH,   NZ,   LZ,   KZ0,
     I        CR,   ipKW, iMA,  IE,   ipP,  ipC,  ipL)
      endif
c
      if (iErr.eq.0) then
         call MUTfmi
     O       (iErr,
     O        VMHR, VMHB, VMHI, VMTI, VMTW, VMI,
     I        LH,   LZ,
     I        CR,   iMA,  ipP,  ipC,  ipL)
      endif
      if (iErr.eq.0) then
         call UV0cpa (VMI,        MH, LH, VMI_Ha,   VMI_HH)
         call UV1cpa (VMHI, VMI,  MH, LH, VMHI_oHa, VMI_Ha)
         call UV1cpa (VMHI, VMI,  MH, LH, VMHI_oBa, VMI_Ba)
         call UV1naa (VMHI, VMHB, MH, LH, VMHI_oSa, VMHI_oHa, VMHB_Ra)
      endif
c
      RETURN
      END
CCC_ & MUTpmi  ## Parameters initialization (movement/SIA)
      subroutine MUTpmi
     O    (iErr,
     O     IMTI, PMTI,
     I     CR,   ipP,  ipC, ipL)
CCC_  - Declaration
      implicit none
CCC_   . Arguments
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   IMTI (*)
      _INTENT(OUT,_REALSTD)  PMTI (*)
      _INTENT(IN, character) CR*(*)
      _INTENT(IN, integer)   ipP, ipC, ipL
CCC_   . Configuration
      character  CROOT * (8)
      _REALSTD   RF,   ACC,  SLV
      _REALSTD   Hini, Tini
      _REALSTD   VBc,  VBe,  VBd
      _REALSTD   BDC,  BDP
      _REALSTD   RA,   RL,   RXL,  RYL,  RXO,  RYO
      _REALSTD   BDDIVD, BDOCEN,   BDREFL
      integer    KSW
      integer    KCFGR, KCFGM,  KCFGVB, KCFGTS, KCFGMS
      integer    KCFGH, KCFGTB, KCFGSH, KCFGVM
      logical    OVBCAA
      namelist /NITPMI/
     $     CROOT,
     $     RF,     ACC,    SLV,
     $     BDDIVD, BDOCEN, BDREFL,
     $     KSW,    Hini,   Tini,   VBc,    VBe,    VBd,
     $     BDC,    BDP,
     $     RA,     RL,     RXL,    RYL,    RXO,    RYO,
     $     KCFGR,  KCFGM,  KCFGVB, KCFGTS, KCFGMS, KCFGH,
     $     KCFGTB, KCFGSH, KCFGVM, OVBCAA
      namelist /NITPMC/
     $     CROOT, KSW,
     $     KCFGR, KCFGM, KCFGVB, KCFGTS, KCFGMS, KCFGH,
     $     KCFGTB,KCFGSH,KCFGVM
CCC_   . interior
      integer jc
CCC_  - Body
CC       Dummy statements
      iErr = 0
CCC_   . Configuration
      jc = 0
 200  continue
      call UUrwnd (iErr, ipP)
c
 100  continue
c
      CROOT = ' '
      RF    = 1.0d-16
      ACC   = 0.3d0
      SLV   = 0.0d0
c$$$      Hini  = 100.0d0
      Hini  = 0.0d0
c$$$      Tini  = 273.15d0
      Tini  = 263.15d0
c
      BDP   = 1.0d0 / 3.0d0
      BDC   = 7.624d6 / (31556926.d0 ** BDP)
c
      BDDIVD = 720.0d0
      BDOCEN = -1148.4d0
      BDREFL = 1800.0d0
c
      OVBCAA = .FALSE.
c$$$      BDP   = 1.0d0
c$$$      BDC   = 7.2082d10 / 31556926.d0
#if 0 /* weertman standard */
      VBc   = 1.8d-10
      VBe   = 3.0d0
      VBd   = -1.0d0
#else
      VBd = 0.0d0
      VBc = BDC ** (- 1.0d0 / BDP)
      VBe = (1.0d0 - BDP) / BDP + 1.0d0
#endif
c$$$      write (*, *) 'VBCHK',
c$$$     $     VBc * (80.d3 ** VBe), VBe, VBc,
c$$$     $     BDC * (35.d0 ** BDP), BDP, BDC
c
      RA    = 0.0d0
      RL    = -1.0d0
      RXL   = 1.0d0
      RYL   = 1.0d0
      RXO   = 0.0d0
      RYO   = 0.0d0
c
      KSW    = BATCH_BENCHFIX
c
      KCFGR  = CONFIG_DEFAULT
      KCFGH  = CONFIG_DEFAULT
      KCFGVB = CONFIG_DEFAULT
      KCFGM  = CONFIG_DEFAULT
      KCFGMS = CONFIG_DEFAULT
      KCFGTS = CONFIG_DEFAULT
      KCFGTB = CONFIG_DEFAULT
      KCFGSH = CONFIG_DEFAULT
      KCFGVM = CONFIG_DEFAULT
c
      READ  (ipP, NITPMI, IOSTAT = iErr)
c
      if (iErr.eq.0) then
         if (CROOT.eq.CR) goto 300
         if (jc.eq.1.and.CROOT.eq.' ') goto 300
         goto 100
      else
         jc = jc + 1
         if (jc.eq.2) then
            iErr = 0
            goto 300
         endif
         goto 200
      endif
c
 300  continue
      if (iErr.eq.0) then
         CROOT = CR
         write (ipC, NITPMI, IOSTAT = iErr)
      endif
CCC_   . Compatibility
      if (iErr.eq.0) then
         if (RL.gt.0.0d0) then
            RXL = RL
            RYL = RL
         endif
      endif
CCC_   . Packing
      if (OVBCAA) then
         VBc = BDC ** (- 1.0d0 / BDP)
         VBe = (1.0d0 - BDP) / BDP + 1.0d0
      endif
      if (iErr.eq.0) then
         PMTI (PMTI_ACC)   = ACC
         PMTI (PMTI_RFC)   = RF
         PMTI (PMTI_HINI)  = Hini
         PMTI (PMTI_TINI)  = Tini
         PMTI (PMTI_CVB)   = VBc
         PMTI (PMTI_DVB)   = VBd
         PMTI (PMTI_EVB)   = VBe
         PMTI (PMTI_RA)    = RA
         PMTI (PMTI_RXL)   = RXL
         PMTI (PMTI_RYL)   = RYL
         PMTI (PMTI_RXO)   = RXO
         PMTI (PMTI_RYO)   = RYO
         PMTI (PMTI_BDRGC) = BDC
         PMTI (PMTI_BDRGP) = BDP
         PMTI (PMTI_SLV)   = SLV
         PMTI (PMTI_BDDIVD)= BDDIVD
         PMTI (PMTI_BDOCEN)= BDOCEN
         PMTI (PMTI_BDREFL)= BDREFL
      endif
CCC_   . configuration switches
      if (iErr.eq.0) then
         IMTI (IMTI_CONFIG) = KSW
CCC_    * bench fix
         if       (KSW.eq. BATCH_BENCHFIX) then
            if (KCFGR .eq. CONFIG_DEFAULT) KCFGR  = CONFIG_R_FLAT
            if (KCFGM .eq. CONFIG_DEFAULT) KCFGM  = CONFIG_M_RECT
            if (KCFGVB.eq. CONFIG_DEFAULT) KCFGVB = CONFIG_VB_UNIFORM
            if (KCFGTS.eq. CONFIG_DEFAULT) KCFGTS = CONFIG_TS_BENCHFIX
            if (KCFGMS.eq. CONFIG_DEFAULT) KCFGMS = CONFIG_MS_UNIFORM
            if (KCFGH .eq. CONFIG_DEFAULT) KCFGH  = CONFIG_H_CONST
            if (KCFGTB.eq. CONFIG_DEFAULT) KCFGTB = CONFIG_TB_FIX
            if (KCFGSH.eq. CONFIG_DEFAULT) KCFGSH = CONFIG_MBSH_UNIFORM
            if (KCFGVM.eq. CONFIG_DEFAULT) KCFGVM = CONFIG_VMSK_NONE
CCC_    * bench mov
         else if  (KSW.eq. BATCH_BENCHMOV) then
            if (KCFGR .eq. CONFIG_DEFAULT) KCFGR  = CONFIG_R_FLAT
            if (KCFGM .eq. CONFIG_DEFAULT) KCFGM  = CONFIG_M_RECT
            if (KCFGVB.eq. CONFIG_DEFAULT) KCFGVB = CONFIG_VB_UNIFORM
            if (KCFGTS.eq. CONFIG_DEFAULT) KCFGTS = CONFIG_TS_BENCHMOV
            if (KCFGMS.eq. CONFIG_DEFAULT) KCFGMS = CONFIG_MS_BENCHMOV
            if (KCFGH .eq. CONFIG_DEFAULT) KCFGH  = CONFIG_H_CONST
            if (KCFGTB.eq. CONFIG_DEFAULT) KCFGTB = CONFIG_TB_FIX
            if (KCFGSH.eq. CONFIG_DEFAULT) KCFGSH = CONFIG_MBSH_UNIFORM
            if (KCFGVM.eq. CONFIG_DEFAULT) KCFGVM = CONFIG_VMSK_NONE
CCC_    * heino
         else if  (KSW.eq. BATCH_HEINO)    then
            if (KCFGR .eq. CONFIG_DEFAULT) KCFGR  = CONFIG_R_FLAT
            if (KCFGM .eq. CONFIG_DEFAULT) KCFGM  = CONFIG_M_HEINO
            if (KCFGVB.eq. CONFIG_DEFAULT) KCFGVB = CONFIG_VB_HEINO
            if (KCFGTS.eq. CONFIG_DEFAULT) KCFGTS = CONFIG_TS_HEINO
            if (KCFGMS.eq. CONFIG_DEFAULT) KCFGMS = CONFIG_MS_HEINO
            if (KCFGH .eq. CONFIG_DEFAULT) KCFGH  = CONFIG_H_CONST
            if (KCFGTB.eq. CONFIG_DEFAULT) KCFGTB = CONFIG_TB_FIX
            if (KCFGSH.eq. CONFIG_DEFAULT) KCFGSH = CONFIG_MBSH_UNIFORM
            if (KCFGVM.eq. CONFIG_DEFAULT) KCFGVM = CONFIG_VMSK_NONE
CCC_    * r slope
         else if  (KSW.eq. BATCH_RSLOPE)   then
            if (KCFGR .eq. CONFIG_DEFAULT) KCFGR  = CONFIG_R_SLOPE
            if (KCFGM .eq. CONFIG_DEFAULT) KCFGM  = CONFIG_M_RECT
            if (KCFGVB.eq. CONFIG_DEFAULT) KCFGVB = CONFIG_VB_UNIFORM
            if (KCFGTS.eq. CONFIG_DEFAULT) KCFGTS = CONFIG_TS_UNIFORM
            if (KCFGMS.eq. CONFIG_DEFAULT) KCFGMS = CONFIG_MS_BENCHMOV
            if (KCFGH .eq. CONFIG_DEFAULT) KCFGH  = CONFIG_H_CONST
            if (KCFGTB.eq. CONFIG_DEFAULT) KCFGTB = CONFIG_TB_FIX
            if (KCFGSH.eq. CONFIG_DEFAULT) KCFGSH = CONFIG_MBSH_UNIFORM
            if (KCFGVM.eq. CONFIG_DEFAULT) KCFGVM = CONFIG_VMSK_NONE
CCC_    * mismip 1
         else if  (KSW.eq. BATCH_MISMIP1)  then
            if (KCFGR .eq. CONFIG_DEFAULT) KCFGR  = CONFIG_R_MISMIP1
            if (KCFGM .eq. CONFIG_DEFAULT) KCFGM  = CONFIG_M_RECT
            if (KCFGVB.eq. CONFIG_DEFAULT) KCFGVB = CONFIG_VB_UNIFORM
            if (KCFGTS.eq. CONFIG_DEFAULT) KCFGTS = CONFIG_TS_UNIFORM
            if (KCFGMS.eq. CONFIG_DEFAULT) KCFGMS = CONFIG_MS_UNIFORM
            if (KCFGH .eq. CONFIG_DEFAULT) KCFGH  = CONFIG_H_CONST
            if (KCFGTB.eq. CONFIG_DEFAULT) KCFGTB = CONFIG_TB_FIX
            if (KCFGSH.eq. CONFIG_DEFAULT) KCFGSH = CONFIG_MBSH_UNIFORM
            if (KCFGVM.eq. CONFIG_DEFAULT) KCFGVM = CONFIG_VMSK_NONE
CCC_    * mismip 3
         else if  (KSW.eq. BATCH_MISMIP3)  then
            if (KCFGR .eq. CONFIG_DEFAULT) KCFGR  = CONFIG_R_MISMIP3
            if (KCFGM .eq. CONFIG_DEFAULT) KCFGM  = CONFIG_M_RECT
            if (KCFGVB.eq. CONFIG_DEFAULT) KCFGVB = CONFIG_VB_UNIFORM
            if (KCFGTS.eq. CONFIG_DEFAULT) KCFGTS = CONFIG_TS_UNIFORM
            if (KCFGMS.eq. CONFIG_DEFAULT) KCFGMS = CONFIG_MS_UNIFORM
            if (KCFGH .eq. CONFIG_DEFAULT) KCFGH  = CONFIG_H_CONST
            if (KCFGTB.eq. CONFIG_DEFAULT) KCFGTB = CONFIG_TB_FIX
            if (KCFGSH.eq. CONFIG_DEFAULT) KCFGSH = CONFIG_MBSH_UNIFORM
            if (KCFGVM.eq. CONFIG_DEFAULT) KCFGVM = CONFIG_VMSK_NONE
CCC_    * read and distribute hack
         else if  (KSW.eq. BATCH_READ)  then
            if (KCFGR .eq. CONFIG_DEFAULT) KCFGR  = CONFIG_R_READ
            if (KCFGM .eq. CONFIG_DEFAULT) KCFGM  = CONFIG_M_READ
            if (KCFGVB.eq. CONFIG_DEFAULT) KCFGVB = CONFIG_VB_READ
            if (KCFGTS.eq. CONFIG_DEFAULT) KCFGTS = CONFIG_TS_UNIFORM
            if (KCFGMS.eq. CONFIG_DEFAULT) KCFGMS = CONFIG_MS_UNIFORM
            if (KCFGH .eq. CONFIG_DEFAULT) KCFGH  = CONFIG_H_READ
            if (KCFGTB.eq. CONFIG_DEFAULT) KCFGTB = CONFIG_TB_FIX
            if (KCFGSH.eq. CONFIG_DEFAULT) KCFGSH = CONFIG_MBSH_UNIFORM
            if (KCFGVM.eq. CONFIG_DEFAULT) KCFGVM = CONFIG_VMSK_NONE
CCC_    * mismip+
         else if  (KSW.eq. BATCH_MISMIP_P)  then
            if (KCFGR .eq. CONFIG_DEFAULT) KCFGR  = CONFIG_R_MISMIP_P
            if (KCFGM .eq. CONFIG_DEFAULT) KCFGM  = CONFIG_M_MISMIP_P
            if (KCFGVB.eq. CONFIG_DEFAULT) KCFGVB = CONFIG_VB_UNIFORM
            if (KCFGTS.eq. CONFIG_DEFAULT) KCFGTS = CONFIG_TS_UNIFORM
            if (KCFGMS.eq. CONFIG_DEFAULT) KCFGMS = CONFIG_MS_UNIFORM
            if (KCFGH .eq. CONFIG_DEFAULT) KCFGH  = CONFIG_H_CONST
            if (KCFGTB.eq. CONFIG_DEFAULT) KCFGTB = CONFIG_TB_FIX
            if (KCFGSH.eq. CONFIG_DEFAULT) KCFGSH = CONFIG_MBSH_MISMIP_P
            if (KCFGVM.eq. CONFIG_DEFAULT) KCFGVM = CONFIG_VMSK_MISIMP_P
CCC_    * EISMINT phase II sliding
         else if  (KSW.eq. BATCH_EP2S) then
            if (KCFGR .eq. CONFIG_DEFAULT) KCFGR  = CONFIG_R_FLAT
            if (KCFGM .eq. CONFIG_DEFAULT) KCFGM  = CONFIG_M_RECT
            if (KCFGVB.eq. CONFIG_DEFAULT) KCFGVB = CONFIG_VB_UNIFORM
            if (KCFGTS.eq. CONFIG_DEFAULT) KCFGTS = CONFIG_TS_EP2S
            if (KCFGMS.eq. CONFIG_DEFAULT) KCFGMS = CONFIG_MS_BENCHMOV
            if (KCFGH .eq. CONFIG_DEFAULT) KCFGH  = CONFIG_H_CONST
            if (KCFGTB.eq. CONFIG_DEFAULT) KCFGTB = CONFIG_TB_FIX
            if (KCFGSH.eq. CONFIG_DEFAULT) KCFGSH = CONFIG_MBSH_UNIFORM
            if (KCFGVM.eq. CONFIG_DEFAULT) KCFGVM = CONFIG_VMSK_NONE
CCC_    * user batch configuration A (following mismip 1)
         else if  (KSW.eq. BATCH_USR_A)  then
            if (KCFGR .eq. CONFIG_DEFAULT) KCFGR  = CONFIG_R_USR_ENDS
            if (KCFGM .eq. CONFIG_DEFAULT) KCFGM  = CONFIG_M_RECT
            if (KCFGVB.eq. CONFIG_DEFAULT) KCFGVB = CONFIG_VB_UNIFORM
            if (KCFGTS.eq. CONFIG_DEFAULT) KCFGTS = CONFIG_TS_UNIFORM
            if (KCFGMS.eq. CONFIG_DEFAULT) KCFGMS = CONFIG_MS_UNIFORM
            if (KCFGH .eq. CONFIG_DEFAULT) KCFGH  = CONFIG_H_CONST
            if (KCFGTB.eq. CONFIG_DEFAULT) KCFGTB = CONFIG_TB_FIX
            if (KCFGSH.eq. CONFIG_DEFAULT) KCFGSH = CONFIG_MBSH_UNIFORM
            if (KCFGVM.eq. CONFIG_DEFAULT) KCFGVM = CONFIG_VMSK_NONE
         else
            iErr = -1
         endif
      endif
      CROOT = CR
      write (ipC, NITPMC, IOSTAT = iErr)
      if (iErr.eq.0) then
         IMTI (IMTI_CFG_MASK) = KCFGM
         IMTI (IMTI_CFG_R)    = KCFGR
         IMTI (IMTI_CFG_VB)   = KCFGVB
         IMTI (IMTI_CFG_MS)   = KCFGMS
         IMTI (IMTI_CFG_TS)   = KCFGTS
         IMTI (IMTI_CFG_H)    = KCFGH
         IMTI (IMTI_CFG_TB)   = KCFGTB
         IMTI (IMTI_CFG_MBSH) = KCFGSH
         IMTI (IMTI_CFG_VMSK) = KCFGVM
      endif
c
      call DAtrcU (ipL, iErr, 'R', 'MUTPMI')
      RETURN
      END
CCC_ & MUTvmi  ## Variables initialization (movement/SIA)
      subroutine MUTvmi
     O    (iErr,
     O     VMHR, VMHB, VMHI, VMTI, VMTW, VMI,
     W     CW,
     I     PMD,  IMD,  WW,   WZV,  GG,  NTH,  IMTI, PMTI,
     I     MH,   LH,   NZ,   LZ,   KZ0,
     I     CR,   ipKW, iMA,  IE,   ipP, ipC,  ipL)
CCC_  - Declaration
      implicit none
CCC_   . Arguments
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   MH, LH
      _INTENT(IN, integer)   NZ, LZ, KZ0
      _INTENT(IN, integer)   NTH
      _INTENT(OUT,_REALSTD)  VMI  (LH, *)
      _INTENT(OUT,_REALSTD)  VMHI (LH, *)
      _INTENT(OUT,_REALSTD)  VMHR (LH, *)
      _INTENT(OUT,_REALSTD)  VMHB (LH, *)
      _INTENT(OUT,_REALSTD)  VMTI (LH, LZ, *)
      _INTENT(OUT,_REALSTD)  VMTW (LH, LZ, *)
c
      _INTENT(OUT,_REALSTD)  CW   (LH, *)
c
      _INTENT(IN, _REALSTD)  PMD  (*)
      _INTENT(IN, integer)   IMD  (*)
      _INTENT(IN, integer)   IMTI (*)
      _INTENT(IN, _REALSTD)  PMTI (*)
      _INTENT(IN, _REALSTD)  WZV  (LZ, *)
      _INTENT(IN, _REALSTD)  WW   (LH, *)
      _INTENT(IN, _REALSTD)  GG   (*)
      _INTENT(IN, integer)   ipKW (IPKW_FULL_DECL)
      _INTENT(IN, integer)   iMA  (*)
      _INTENT(IN, integer)   IE   (*)
      _INTENT(IN, character) CR*(*)
      _INTENT(IN, integer)   ipP, ipC, ipL
CCC_   . Configuration
CCC_   . interior
      _REALSTD RF, EF, PF, ACC, SLV
      _REALSTD BDDIVD, BDOCEN,  BDREFL
      _REALSTD H0
      _REALSTD D,  X,  Y,  V
c
      _REALSTD REL, S
      _REALSTD GRD, S0,  T0
      _REALSTD BA
      _REALSTD RA,  RXL, RYL, RXO, RYO
c
      _REALSTD BMX, BMN
      _REALSTD BDC, BDP
      integer  jp,  jx, jy
      integer  j0m, km
      integer  jh,  jz
c
      logical  ONRCPY, ORSTG
c
      integer KSW
CCC_  - Body
CC       Dummy statements
      iErr = (0 * ipP) * ipC
      if (CR .eq. ' ') continue
c
      PF   = PMD  (PMD_PF)
      EF   = PMD  (PMD_EFC)
c
      RF   = PMTI (PMTI_RFC)
      ACC  = PMTI (PMTI_ACC)
      H0   = PMTI (PMTI_HINI)
      T0   = PMTI (PMTI_TINI)
c
      RA   = PMTI (PMTI_RA)
      RXL  = PMTI (PMTI_RXL)
      RYL  = PMTI (PMTI_RYL)
      RXO  = PMTI (PMTI_RXO)
      RYO  = PMTI (PMTI_RYO)
      SLV  = PMTI (PMTI_SLV)
c
      BDDIVD  = PMTI (PMTI_BDDIVD)
      BDOCEN  = PMTI (PMTI_BDOCEN)
      BDREFL  = PMTI (PMTI_BDREFL)
c
      call UV0stb (VMTW, MH, LH, LZ, LZ, VMTW_RFb, RF)
      call UV0stb (VMTW, MH, LH, LZ, LZ, VMTW_RFc, RF)
      call UV0stb (VMTW, MH, LH, LZ, LZ, VMTW_EFb, EF)
      call UV0stb (VMTW, MH, LH, LZ, LZ, VMTW_EFc, EF)
c
      if (IMD (IMD_RFI).eq. SW_RFI_CONST) then
         call MIFcrw
     O       (VMI,
     I        RF,  EF, PF, VMI_RFIIb, MH, LH)
         call MIFcrw
     O       (VMI,
     I        RF,  EF, PF, VMI_RFIIc, MH, LH)
         call MIFcri
     O       (VMTW,
     I        WZV (1, VMVZ_Za),
     I        RF,  EF, PF, VMTW_RFIb,  MH, LH, NZ, LZ, KZ0)
         call MIFcri
     O       (VMTW,
     I        WZV (1, VMVZ_Za),
     I        RF,  EF, PF, VMTW_RFIc,  MH, LH, NZ, LZ, KZ0)
         call MIFcro
     O       (VMTW,
     I        WZV (1, VMVZ_Za),
     I        RF,  EF, PF, VMTW_RFIIb, MH, LH, NZ, LZ, KZ0)
         call MIFcro
     O       (VMTW,
     I        WZV (1, VMVZ_Za),
     I        RF,  EF, PF, VMTW_RFIIc, MH, LH, NZ, LZ, KZ0)
      else if (IMD (IMD_RFI).eq. SW_RFI_EULER) then
         call MIFera
     O       (VMTW, VMI,
     I        WZV,
     I        VMTW_RFIb, VMTW_RFIIb, VMI_RFIIb,
     I        VMTW_RFb,  VMTW_EFb,
     I        VMVZ_Za,   VMVZ_dZb,
     I        PF,
     I        MH,   LH,   NZ, LZ, KZ0)
         call MIFera
     O       (VMTW, VMI,
     I        WZV,
     I        VMTW_RFIc, VMTW_RFIIc, VMI_RFIIc,
     I        VMTW_RFc,  VMTW_EFc,
     I        VMVZ_Za,   VMVZ_dZb,
     I        PF,
     I        MH,   LH,   NZ, LZ, KZ0)
      else
         call MIFgii
     O       (VMTW,
     I        GG,     WZV (1, VMVZ_Za), WZV (1, VMVZ_dZb),
     I        VMTW_RFIb, VMTW_EFb, VMTW_RFb, MH, LH, NZ, LZ, KZ0, NTH)
         call MIFgii
     O       (VMTW,
     I        GG,     WZV (1, VMVZ_Za), WZV (1, VMVZ_dZb),
     I        VMTW_RFIc, VMTW_EFc, VMTW_RFc, MH, LH, NZ, LZ, KZ0, NTH)
         call MIFgio
     O       (VMTW,
     I        GG,     WZV (1, VMVZ_Za), WZV (1, VMVZ_dZb),
     I        VMTW_RFIIb, VMTW_EFb, VMTW_RFb, MH, LH, NZ, LZ, KZ0, NTH)
         call MIFgio
     O       (VMTW,
     I        GG,     WZV (1, VMVZ_Za), WZV (1, VMVZ_dZb),
     I        VMTW_RFIIc, VMTW_EFc, VMTW_RFc, MH, LH, NZ, LZ, KZ0, NTH)
         jz = KZ0 + NZ - 1
         do jh = 1, MH
            VMI (jh, VMI_RFIIb) = VMTW (jh, jz, VMTW_RFIIb)
            VMI (jh, VMI_RFIIc) = VMTW (jh, jz, VMTW_RFIIc)
         enddo
      endif
CCC_   . basal drag switch
      call UV0sta (VMI, MH, LH, VMI_SLDb, 0.0d0)
      call UV0sta (VMI, MH, LH, VMI_SLDc, 0.0d0)
CCC_   . associate rate factor average
      BA  = (RF * EF) ** (-1.0d0/PF)
      call UV0sta (VMI, MH, LH, VMI_daBAa, BA)
      call UV0sta (VMI, MH, LH, VMI_daBAd, BA)
c
      call UV0sta (VMI, MH, LH, VMI_daRFa,  RF * EF)
CCC_   . lateral bc
      KSW = IMTI (IMTI_CFG_MASK)
c$$$      write (*, *) 'CFG MSK', KSW
      if (KSW .ne. CONFIG_M_READ) then
         J0M = EA_idxMU(IE,0)
         call UV0sta (VMHB, MH, LH, VMHB_LMSK, 0.0d0)
         do jp = 1, MH
            km = IE (J0M + jp - 1)
c$$$            write (*, *) 'LMSK', jp, km
            if (km.eq.0) VMHB (jp, VMHB_LMSK) = 1.0d0
         enddo
      endif
      if (KSW .eq. CONFIG_M_HEINO) then
         jx = ipKW (KWI_KWO, KWO_Xa, KWM_M)
         jy = ipKW (KWI_KWO, KWO_Ya, KWM_M)
         do jp = 1, MH
            if (VMHB (jp, VMHB_LMSK).eq.0.0d0) then
               continue
            else
               X  = WW (jp, jx)
               Y  = WW (jp, jy)
               D  = SQRT (X * X + Y * Y)
               if (D.ge.2000.d3) VMHB (jp, VMHB_LMSK) = 0.0d0
            endif
         enddo
      endif
      if (KSW .eq. CONFIG_M_MISMIP_P) then
         jx = ipKW (KWI_KWO, KWO_Xa, KWM_M)
         jy = ipKW (KWI_KWO, KWO_Ya, KWM_M)
         do jp = 1, MH
            if (VMHB (jp, VMHB_LMSK).eq.0.0d0) then
               continue
            else
               X  = WW (jp, jx)
               Y  = WW (jp, jy)
               if (X.lt.0.0d0
     $              .OR. X.gt.640.0d3) then
                  VMHB (jp, VMHB_LMSK) = 0.0d0
               else if (Y.lt.0.0d0
     $                 .OR. Y.gt.80.0d3) then
                  VMHB (jp, VMHB_LMSK) = 0.0d0
               endif
            endif
         enddo
      endif
      call UV1cpa (VMI, VMHB, MH, LH, VMI_CLa, VMHB_LMSK)
CCC_   . basal drag coefficient
      BDC = PMTI (PMTI_BDRGC)
      BDP = PMTI (PMTI_BDRGP)
      call UV0sta (VMHB, MH, LH, VMHB_FVBb, BDC)
      call UV0sta (VMHB, MH, LH, VMHB_FVBc, BDC)
      call UV0sta (VMHB, MH, LH, VMHB_GVBb, BDP)
      call UV0sta (VMHB, MH, LH, VMHB_GVBc, BDP)
CCC_   . basal sliding config
      V = 0.0d0
      call UV0sta (VMHB, MH, LH, VMHB_CVBb, V)
      call UV0sta (VMHB, MH, LH, VMHB_CVBc, V)
      V = 1.0d0
      call UV0sta (VMHB, MH, LH, VMHB_EVBb, V)
      call UV0sta (VMHB, MH, LH, VMHB_EVBc, V)
c
      KSW = IMTI (IMTI_CFG_VB)
      if (KSW .eq. CONFIG_VB_HEINO) then
         jx = ipKW (KWI_KWO, KWO_Xb, KWM_M)
         jy = ipKW (KWI_KWO, KWO_Yb, KWM_M)
         call MUTBVH
     $       (VMHB, VMHB_CVBb, VMHB_EVBb,
     $        WW,   jx,    jy,    MH, LH)
         jx = ipKW (KWI_KWO, KWO_Xc, KWM_M)
         jy = ipKW (KWI_KWO, KWO_Yc, KWM_M)
         call MUTBVH
     $       (VMHB, VMHB_CVBc, VMHB_EVBc,
     $        WW,   jx,    jy,    MH, LH)
      else
         call MUTBVG
     $       (iErr,
     $        VMHB, VMHB_CVBb, VMHB_EVBb, VMHB_DVBb,
     $        PMD,  IMD, PMTI, MH, LH, ipL)
         call MUTBVG
     $       (iErr,
     $        VMHB, VMHB_CVBc, VMHB_EVBc, VMHB_DVBc,
     $        PMD,  IMD, PMTI, MH, LH, ipL)
      endif
CCC_   . thickness
      KSW = IMTI (IMTI_CFG_H)
      if (KSW .eq. CONFIG_H_CONST) then
         call UV0sta (VMI,  MH, LH, VMI_HH, H0)
      else
         continue
      endif
c$$$      call UV0sta (VMI,  MH, LH, VMI_Ha, H0)
CCC_   . temperature
      call UV0stc (VMTI, MH, LH, NZ, LZ, KZ0, VMTI_T, T0)
CCC_   . bedrock topography
      KSW = IMTI (IMTI_CFG_R)
      ONRCPY = .true.
      ORSTG  = .true.
CCC_    * flat
      if (KSW .eq. CONFIG_R_FLAT) then
         ONRCPY = .FALSE.
         ORSTG  = .FALSE.
         V = 0.0d0
         call UV0sta (VMHB, MH, LH, VMHB_Ra,  V)
         call UV0sta (VMHB, MH, LH, VMHB_Rb,  V)
         call UV0sta (VMHB, MH, LH, VMHB_Rc,  V)
         call UV0sta (VMHB, MH, LH, VMHB_Rd,  V)
         V = 0.0d0
         call UV0sta (VMHB, MH, LH, VMHB_NRa, V)
         call UV0sta (VMHB, MH, LH, VMHB_NRb, V)
         call UV0sta (VMHB, MH, LH, VMHB_NRc, V)
         V = 0.0d0
         call UV0sta (VMHB, MH, LH, VMHB_RXb,  V)
         call UV0sta (VMHB, MH, LH, VMHB_RYc,  V)
         call UV0sta (VMHB, MH, LH, VMHB_NRXb, V)
         call UV0sta (VMHB, MH, LH, VMHB_NRYc, V)
CCC_    * cosine
      else if (KSW .eq. CONFIG_R_RCOS) then
         call MUTbco
     $       (VMHB, VMHB_Ra, KWO_Xa, KWO_Ya,
     $        WW,   ipKW, RA,  RXL, RYL, MH, LH)
CC       to be adjusted later
c$$$         call MUTbco
c$$$     $       (VMHB, VMHB_Rb, KWO_Xb, KWO_Ya,
c$$$     $        WW,   ipKW, RA,  RL, MH, LH)
c$$$         call MUTbco
c$$$     $       (VMHB, VMHB_Rc, KWO_Xa, KWO_Yb,
c$$$     $        WW,   ipKW, RA,  RL, MH, LH)
c$$$         call MUTbco
c$$$     $       (VMHB, VMHB_Rd, KWO_Xb, KWO_Yb,
c$$$     $        WW,   ipKW, RA,  RL, MH, LH)
CCC_    * gaussian bump
      else if (KSW .eq. CONFIG_R_RGAUSS) then
         call MUTbgo
     $       (VMHB, VMHB_Ra, KWO_Xa, KWO_Ya,
     $        WW,   ipKW, RA,  RXL, RYL, RXO, RYO, MH, LH)
CCC_    * canal
      else if (KSW .eq. CONFIG_R_RCANAL) then
         call MUTbcn
     $       (VMHB, VMHB_Ra, KWO_Xa, KWO_Ya,
     $        WW,   ipKW, RA,  RXL, RYL, RXO, RYO, MH, LH)
CCC_    * mismip 3
      else if (KSW .eq. CONFIG_R_MISMIP3) then
         call MUTbm3
     $       (VMHB, VMHB_Ra, KWO_Xa, KWO_Ya,
     $        WW,   ipKW, MH, LH)
CCC_    * mismip+
      else if (KSW .eq. CONFIG_R_MISMIP_P) then
         call MUTbmp
     $       (VMHB, VMHB_Ra, KWO_Xa, KWO_Ya,
     $        WW,   ipKW, MH, LH)
CCC_    * slope
CC       to be adjusted later
      else if (KSW .eq. CONFIG_R_SLOPE
     $        .or. KSW .eq. CONFIG_R_MISMIP1) then
         ORSTG  = .FALSE.
         if (KSW .eq. CONFIG_R_SLOPE) then
            S0   = 100.0d0
            GRD  = - S0 / 50.0d3
         else
c      b(x) = (720 - 778.5 * x/750km) [m]
            S0  = 720.0d0
            GRD = - 778.5d0 / 750.0d3
         endif
         call MUTbrs
     $       (VMHB, VMHB_Ra, -1,      KWO_Xa, KWO_Ya,
     $        WW,   ipKW, S0, GRD, MH, LH)
         call MUTbrs
     $       (VMHB, VMHB_Rb, VMHB_RXb, KWO_Xb, KWO_Yb,
     $        WW,   ipKW, S0, GRD, MH, LH)
         call MUTbrs
     $       (VMHB, VMHB_Rc, VMHB_RYc, KWO_Yc, KWO_Xc,
     $        WW,   ipKW, S0, GRD, MH, LH)
         call MUTbrs
     $       (VMHB, VMHB_Rd, -1,      KWO_Xd, KWO_Yd,
     $        WW,   ipKW, S0, GRD, MH, LH)
CCC_    * user defined (slope by two ends)
      else if (KSW .eq. CONFIG_R_USR_ENDS) then
         ORSTG  = .FALSE.
         S0 = BDDIVD * 1.0d0
         GRD = - (BDDIVD - BDOCEN) * 0.001D0 / BDREFL
         call MUTbrs
     $       (VMHB, VMHB_Ra, -1,      KWO_Xa, KWO_Ya,
     $        WW,   ipKW, S0, GRD, MH, LH)
         call MUTbrs
     $       (VMHB, VMHB_Rb, VMHB_RXb, KWO_Xb, KWO_Yb,
     $        WW,   ipKW, S0, GRD, MH, LH)
         call MUTbrs
     $       (VMHB, VMHB_Rc, VMHB_RYc, KWO_Yc, KWO_Xc,
     $        WW,   ipKW, S0, GRD, MH, LH)
         call MUTbrs
     $       (VMHB, VMHB_Rd, -1,      KWO_Xd, KWO_Yd,
     $        WW,   ipKW, S0, GRD, MH, LH)
CCC_    * user defined (polinomial)
      else if (KSW .eq. CONFIG_R_USR_POLI) then
cc       not implemented yet
         iErr = -999
CCC_    * file read
      else if (KSW .eq. CONFIG_R_READ) then
         continue
      else
         iErr = -1
      endif
CCC_    * staggered grids adjustment
      if (ORSTG) then
         call AKBwax
     O       (VMHB, CW,
     I        WW,
     I        MH,   LH,  VMHB_Rb,  VMHB_Ra,
     I        ipKW, iMA, KWO_Lab, KWM_M)
         call AKBwax
     O       (VMHB, CW,
     I        WW,
     I        MH,   LH,  VMHB_Rc,  VMHB_Ra,
     I        ipKW, iMA, KWO_Lac, KWM_M)
c     NR[bc] used  temporary
         call AKBwax
     O       (VMHB, CW,
     I        WW,
     I        MH,   LH,  VMHB_NRb,  VMHB_Rb,
     I        ipKW, iMA, KWO_Lbd, KWM_M)
         call AKBwax
     O       (VMHB, CW,
     I        WW,
     I        MH,   LH,  VMHB_NRc,  VMHB_Rc,
     I        ipKW, iMA, KWO_Lcd, KWM_M)
         do jp = 1, MH
            VMHB (jp, VMHB_Rd) = 0.5d0 *
     $           (VMHB (jp,VMHB_NRb) + VMHB (jp,VMHB_NRc))
         enddo
c
         call AKBwax
     O       (VMHB, CW,
     I        WW,
     I        MH,   LH,  VMHB_RXb, VMHB_Ra,
     I        ipKW, iMA, KWO_GXab, KWM_M)
         call AKBwax
     O       (VMHB, CW,
     I        WW,
     I        MH,   LH,  VMHB_RYc, VMHB_Ra,
     I        ipKW, iMA, KWO_GYac, KWM_M)
      endif
CCC_    * next bedrocks
      if (ONRCPY) then
         call UV0cpa (VMHB, MH, LH, VMHB_NRXb, VMHB_RXb)
         call UV0cpa (VMHB, MH, LH, VMHB_NRYc, VMHB_RYc)
         call UV0cpa (VMHB, MH, LH, VMHB_NRa,  VMHB_Ra)
         call UV0cpa (VMHB, MH, LH, VMHB_NRb,  VMHB_Rb)
         call UV0cpa (VMHB, MH, LH, VMHB_NRc,  VMHB_Rc)
      endif
CCC_   . surface/base mass balance (todo floating part)
      KSW = IMTI (IMTI_CFG_MS)
c$$$      call UV1naa (VMI, VMHB, MH, LH, VMI_Sa, VMI_Ha, VMHB_Ra)
c$$$      call UV1naa (VMI, VMHB, MH, LH, VMI_Sa, VMI_HH, VMHB_Ra)
      call UV1cpa (VMI, VMHB, MH, LH, VMI_Ba, VMHB_Ra)
CCC_   . hack for moving margin surface temperature
      call UV1cpa (VMHI, VMI, MH, LH, VMHI_nSa, VMI_Sa)
CCC_   . mass balance
      if (KSW .eq. CONFIG_MS_UNIFORM) then
         call UV0sta (VMHB, MH, LH, VMHB_MS, ACC)
         call UV0sta (VMHB, MH, LH, VMHB_MB, 0.0d0)
      else if (KSW .eq. CONFIG_MS_BENCHMOV) then
         REL  = 450.0d3
         S    = 1.d-5
         jx = ipKW (KWI_KWO, KWO_Xa, KWM_M)
         jy = ipKW (KWI_KWO, KWO_Ya, KWM_M)
         do jp = 1, MH
            X  = WW (jp, jx)
            Y  = WW (jp, jy)
            D  = SQRT (X * X + Y * Y)
            V  = MIN (Acc, S * (REL - D))
            VMHB (jp, VMHB_MS) = V
         enddo
         call UV0sta (VMHB, MH, LH, VMHB_MB, 0.0d0)
      else if (KSW .eq. CONFIG_MS_HEINO) then
         BMX  = 0.30d0
         BMN  = 0.15d0
         jx = ipKW (KWI_KWO, KWO_Xa, KWM_M)
         jy = ipKW (KWI_KWO, KWO_Ya, KWM_M)
         do jp = 1, MH
            X  = WW (jp, jx)
            Y  = WW (jp, jy)
            D  = SQRT (X * X + Y * Y)
            V  = BMN + (BMX - BMN) * (D / 2000.d3)
            VMHB (jp, VMHB_MS) = V
         enddo
         call UV0sta (VMHB, MH, LH, VMHB_MB, 0.0d0)
      else if (KSW .eq. CONFIG_MS_FILE) then
         jx = ipKW (KWI_KWO, KWO_Xa, KWM_M)
         jy = ipKW (KWI_KWO, KWO_Ya, KWM_M)
 101     format ('MUTCFG/ACC/FILE:',2F10.1,1x,E16.9)
         do jp = 1, MH
            X  = WW (jp, jx)
            Y  = WW (jp, jy)
            write (ipL, 101) X, Y, VMHB (jp, VMHB_MS)
         enddo
         call UV0sta (VMHB, MH, LH, VMHB_MB, 0.0d0)
      else if (KSW .eq. CONFIG_MS_ELA) then
         continue
      else
         iErr = -1
      endif
      call UV0naa (VMHB, MH, LH, VMHB_TMBa, VMHB_MS, VMHB_MB)
c
c$$$      V = -42.0d-3 * (31556926.d0 ** 3.0d0)
c$$$      V = -42.0d-3
      V = -42.0d-3 * 31556926.d0
      call UV0sta (VMHB, MH, LH, VMHB_GH,  V)
CCC_   . local sea level
      call UV0sta (VMHB, MH, LH, VMHB_SLVa, SLV)
      call UV0sta (VMHB, MH, LH, VMHB_SLVb, SLV)
      call UV0sta (VMHB, MH, LH, VMHB_SLVc, SLV)
      call UV0sta (VMHB, MH, LH, VMHB_SLVd, SLV)
CCC_   . surface temperature
      if (iErr.eq.0) then
         call MUTtsf
     O       (iErr,
     O        VMHB,
     I        VMHI,
     I        PMD,  IMD,  WW,  IMTI, PMTI,
     I        MH,   LH,
     I        ipKW, ipL)
      endif
      if (iErr.eq.0) then
         do    jz = KZ0, KZ0 + NZ - 1
            do jh = 1,   MH
               VMTI (jh, jz, VMTI_T) = VMHB (jh, VMHB_TSI)
            enddo
            do jh = MH+1, LH
               VMTI (jh, jz, VMTI_T) = T0
            enddo
         enddo
      endif
CCC_   . bottom temperature
      if (iErr.eq.0) then
         V = -2.0d0 + 273.15d0
         call UV0sta (VMHB, MH, LH, VMHB_TBI, V)
      endif
CCC_  - velocity mask
      if (iErr.eq.0) then
         call UV0sta (VMHB, MH, LH, VMHB_UMSKb, 1.0d0)
         call UV0sta (VMHB, MH, LH, VMHB_VMSKc, 1.0d0)
         KSW = IMTI (IMTI_CFG_VMSK)
         if (KSW.eq. CONFIG_VMSK_MISIMP_P) then
            jx = ipKW (KWI_KWO, KWO_Xa, KWM_M)
            do jp = 1, MH
               X  = WW (jp, jx)
               if (X.le.0.0d0) then
                  VMHB (jp, VMHB_VMSKc) = 0.0d0
               endif
            enddo
         endif
      endif
CCC   _   . return
      call DAtrcU (ipL, iErr, 'R', 'MUTVMI')
      RETURN
      END
CCC_ & MUTBVH  ## basal sliding configuration for ISMIP/HEINO
      subroutine MUTBVH
     $    (VMHB, KVC, KVE,
     $     WW,   KWX, KWY,
     $     MH,   LH)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)   MH, LH
      _INTENT(OUT,_REALSTD)  VMHB  (LH, *)
      _INTENT(IN, _REALSTD)  WW    (LH, *)
      _INTENT(IN, integer)   KVC, KVE
      _INTENT(IN, integer)   KWX, KWY
      integer  jp
      _REALSTD X,  Y
      _REALSTD XO, YO
      _REALSTD xPA, yPA,  xPD, yPD
      _REALSTD xPE, yPE,  xPH, yPH
      parameter (xPA = 2300.d3, yPA = 2500.d3)
      parameter (xPD = 3300.d3, yPD = 1500.d3)
      parameter (xPE = xPD,     yPE = 2100.d3)
      parameter (xPH = 4000.d3, yPH = 1900.d3)
      parameter (XO  = 2000.d3, YO  = 2000.d3)
      _REALSTD  CS, CH
      _REALSTD  ES, EH
CCC_  - Body
      CS = 500.d0
      CH = 1.d5
      ES = 0.0d0
      EH = 2.0d0
      do jp = 1, MH
         X  = WW (jp, KWX) + XO
         Y  = WW (jp, KWY) + YO
c$$$         write (*, *) jp, X, Y,
c$$$     $        (xPA.le.X .and. X.le.xPD),
c$$$     $        (yPD.le.Y .and. Y.le.yPA),
c$$$     $        (xPE.le.X .and. X.le.xPH),
c$$$     $        (yPH.le.Y .and. Y.le.yPE)
         if (((xPA.le.X .and. X.le.xPD)
     $        .and. (yPD.le.Y .and. Y.le.yPA))
     $        .or.
     $       ((xPE.le.X .and. X.le.xPH)
     $        .and. (yPH.le.Y .and. Y.le.yPE))) then
            VMHB (jp, KVC) = CS
            VMHB (jp, KVE) = ES
         else
            VMHB (jp, KVC) = CH
            VMHB (jp, KVE) = EH
         endif
      enddo
      RETURN
      END
CCC_ & MUTBVG  ## basal sliding configuration general
      subroutine MUTBVG
     O    (iErr,
     O     VMHB, KVC, KVE, KVD,
     $     PMD,  IMD, PMTI,
     $     MH,   LH,  IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   MH, LH
      _INTENT(OUT,_REALSTD)  VMHB  (LH, *)
      _INTENT(IN, integer)   KVC, KVE, KVD
      _INTENT(IN, integer)   IMD  (*)
      _INTENT(IN, _REALSTD)  PMD  (*)
      _INTENT(IN, _REALSTD)  PMTI (*)
      _INTENT(IN, integer)   IFPl
      integer jh
      _REALSTD C,E,D
      _REALSTD DI, GR
CCC_  - Body
      DI  = PMD (PMD_DENS)
      GR  = PMD (PMD_GRAV)
      if       (IMD (IMD_VB) .eq. SW_VB_NONE) then
         iErr = 0
         do jh = 1, MH
            VMHB (jh, KVE) = 1.0d0
            VMHB (jh, KVD) = 1.0d0
            VMHB (jh, KVC) = 0.0d0
         enddo
      else if  (IMD (IMD_VB) .eq. SW_VB_SALLY_WA) then
         iErr = 0
         E = (PMTI (PMTI_EVB) - 1.0d0) / 2.0d0
         D =  PMTI (PMTI_DVB)
         C =  - PMTI (PMTI_CVB) * ((DI * GR) ** PMTI (PMTI_EVB))
         do jh = 1, MH
            VMHB (jh, KVE) = E
            VMHB (jh, KVD) = D
            VMHB (jh, KVC) = C
         enddo
      else if  (IMD (IMD_VB) .eq. SW_VB_TWEERTMAN) then
         iErr = 0
         E =  PMTI (PMTI_EVB)
         D =  PMTI (PMTI_DVB)
         C =  PMTI (PMTI_CVB)
         do jh = 1, MH
            VMHB (jh, KVE) = E
            VMHB (jh, KVD) = D
            VMHB (jh, KVC) = C
         enddo
      else
         iErr = -1
      endif
      call DAtrcU (IFPl, iErr, 'R', 'MUTBVG')
      RETURN
      END
CCC_ & MUTbco  ## bedrock topography (cosine)
      subroutine MUTbco
     M    (VMHB,
     I     KR, KCX,  KCY,
     I     WW, ipKW, BA,  BXL, BYL, MH, LH)
      implicit none
      _INTENT(IN, integer)   MH, LH
      _INTENT(OUT,_REALSTD)  VMHB  (LH, *)
      _INTENT(IN, _REALSTD)  WW    (LH, *)
      _INTENT(IN, integer)   ipKW (IPKW_FULL_DECL)
      _INTENT(IN, integer)   KR, KCX, KCY
      _INTENT(IN, _REALSTD)  BA, BXL, BYL
      integer  jx, jy, jp
      _REALSTD X,  Y,  D, V
      _REALSTD PI
c
      jx = ipKW (KWI_KWO, KCX, KWM_M)
      jy = ipKW (KWI_KWO, KCY, KWM_M)
c
      PI = ATAN2 (1.0d0, 1.0d0) * 4.0d0
CCC_  - for backward compatibility
      if (BXL.eq.BYL) then
         do jp = 1, MH
            X  = WW (jp, jx)
            Y  = WW (jp, jy)
            D  = SQRT (X * X + Y * Y)
            if (D.GE.BXL) then
               V = 0.0d0
            else
c$$$               D = (D / BL) * PI
               V  = (1.0d0 + COS ((D / BXL) * PI)) * BA
            endif
            VMHB (jp, KR) = V
            write (*, *) X, Y, D, V
         enddo
CCC_  - analyticaly identical, but numerically different
      else
         do jp = 1, MH
            X  = WW (jp, jx)
            Y  = WW (jp, jy)
            D  = SQRT ((X / BXL) ** 2.0d0 + (Y / BYL) ** 2.0d0)
            if (D.GE.1.0d0) then
               V = 0.0d0
            else
               V  = (1.0d0 + COS (D * PI)) * BA
            endif
            VMHB (jp, KR) = V
            write (*, *) X, Y, D, V
         enddo
      endif
      RETURN
      END
CCC_ & MUTbgo  ## bedrock topography (gaussian)
      subroutine MUTbgo
     M    (VMHB,
     I     KR, KCX,  KCY,
     I     WW, ipKW, BA,  BXL, BYL, BXO,  BYO,  MH, LH)
      implicit none
      _INTENT(IN, integer)   MH, LH
      _INTENT(OUT,_REALSTD)  VMHB  (LH, *)
      _INTENT(IN, _REALSTD)  WW    (LH, *)
      _INTENT(IN, integer)   ipKW (IPKW_FULL_DECL)
      _INTENT(IN, integer)   KR, KCX, KCY
      _INTENT(IN, _REALSTD)  BA, BXL, BYL, BXO,  BYO
      integer  jx, jy, jp
      _REALSTD X,   Y,  D, V
      _REALSTD DZL, BSQ
c
      jx = ipKW (KWI_KWO, KCX, KWM_M)
      jy = ipKW (KWI_KWO, KCY, KWM_M)
c
CCC_  - for backward compatibility
      if (BXL.eq.BYL) then
         DZL = 25.0d0 * (BXL * BXL)
         BSQ = 2.0d0  * (BXL * BXL)
         do jp = 1, MH
            X  = WW (jp, jx) - BXO
            Y  = WW (jp, jy) - BYO
            D  = (X * X + Y * Y)
            if (D.GE.DZL) then
               V = 0.0d0
            else
               V  = BA * exp (- (D / BSQ))
            endif
            VMHB (jp, KR) = V
            write (*, *) X, Y, D, V
         enddo
CCC_  - analyticaly identical, but numerically different
      else
         DZL = 25.0d0 * (BXL * BXL)
         BSQ = 2.0d0  * (BXL * BXL)
         do jp = 1, MH
            X  = WW (jp, jx) - BXO
            Y  = WW (jp, jy) - BYO
            D  = (X / BXL) ** 2.0d0 + (Y / BYL) ** 2.0d0
            if (D.GE.25.0d0) then
               V = 0.0d0
            else
               V  = BA * exp (- D / 2.0d0)
            endif
            VMHB (jp, KR) = V
            write (*, *) X, Y, D, V
         enddo
      endif
      RETURN
      END
CCC_ & MUTbcn  ## bedrock topography (canal)
      subroutine MUTbcn
     M    (VMHB,
     I     KR, KCX,  KCY,
     I     WW, ipKW, BA,  BXL, BYL, BXO,  BYO,  MH, LH)
      implicit none
      _INTENT(IN, integer)   MH, LH
      _INTENT(OUT,_REALSTD)  VMHB  (LH, *)
      _INTENT(IN, _REALSTD)  WW    (LH, *)
       _INTENT(IN, integer)   ipKW (IPKW_FULL_DECL)
      _INTENT(IN, integer)   KR, KCX, KCY
      _INTENT(IN, _REALSTD)  BA, BXL, BYL, BXO,  BYO
      integer  jx, jy, jp
c     BA        depth
c     BXO BYO   canal start
c     BXL zero      width BYL to east
c     BXL minus     width BYL to west
c     BYL zero      width BXL to north
c     BYL minus     width BXL to south
      _REALSTD X,   Y,  V
      _REALSTD SLV
c
      jx = ipKW (KWI_KWO, KCX, KWM_M)
      jy = ipKW (KWI_KWO, KCY, KWM_M)
      SLV = 0.0d0
CCC_  - bad configuration
      if (BXL.lt.0.0d0.and.BYL.lt.0.0d0) then
         do jp = 1, MH
            VMHB (jp, KR) = SLV
         enddo
CCC_  - east
      else if (BXL.eq.0.0d0) then
         do jp = 1, MH
            X  = WW (jp, jx)
            Y  = WW (jp, jy)
            V  = SLV
            if (X.ge.BXO
     $           .and. Y.le.(BYO+BYL)
     $           .and. Y.ge.(BYO-BYL)) then
               V = BA
            endif
            VMHB (jp, KR) = V
         enddo
CCC_  - west
      else if (BXL.lt.0.0d0) then
         do jp = 1, MH
            X  = WW (jp, jx)
            Y  = WW (jp, jy)
            V  = SLV
            if (X.le.BXO
     $           .and. Y.le.(BYO+BYL)
     $           .and. Y.ge.(BYO-BYL)) then
               V = BA
            endif
            VMHB (jp, KR) = V
         enddo
CCC_  - north
      else if (BYL.eq.0.0d0) then
         do jp = 1, MH
            X  = WW (jp, jx)
            Y  = WW (jp, jy)
            V  = SLV
            if (Y.ge.BYO
     $           .and. X.le.(BXO+BXL)
     $           .and. X.ge.(BXO-BXL)) then
               V = BA
            endif
            VMHB (jp, KR) = V
         enddo
CCC_  - south
      else if (BYL.lt.0.0d0) then
         do jp = 1, MH
            X  = WW (jp, jx)
            Y  = WW (jp, jy)
            V  = SLV
            if (Y.le.BYO
     $           .and. X.le.(BXO+BXL)
     $           .and. X.ge.(BXO-BXL)) then
               V = BA
            endif
            VMHB (jp, KR) = V
         enddo
CCC_  - default
      else
         do jp = 1, MH
            X  = WW (jp, jx)
            Y  = WW (jp, jy)
            V  = SLV
            if ((Y.le.(BYO+BYL).and.Y.ge.(BYO-BYL))
     $           .and. (X.ge.BXO.or.X.le.-BXO)) then
               V = BA
            else if ((X.le.(BXO+BXL).and.X.ge.(BXO-BXL))
     $              .and. (Y.ge.BYO.or.Y.le.-BYO)) then
               V = BA
            endif
            VMHB (jp, KR) = V
         enddo
      endif
      do jp = 1, MH
         X  = WW (jp, jx)
         Y  = WW (jp, jy)
         write (*, *) X, Y, VMHB(jp,KR)
      enddo
      RETURN
      END
CCC_ & MUTbm3  ## bedrock topography (mismip 3)
      subroutine MUTbm3
     M    (VMHB,
     I     KR, KCX,  KCY,
     I     WW, ipKW, MH, LH)
      implicit none
      _INTENT(IN, integer)   MH, LH
      _INTENT(OUT,_REALSTD)  VMHB  (LH, *)
      _INTENT(IN, _REALSTD)  WW    (LH, *)
      _INTENT(IN, integer)   ipKW (IPKW_FULL_DECL)
      _INTENT(IN, integer)   KR, KCX, KCY
      integer  jx, jy, jp
      _REALSTD X,  Y,  D, V
      _REALSTD P0, P2, P4, P6, WL
c
      jx = ipKW (KWI_KWO, KCX, KWM_M)
      jy = ipKW (KWI_KWO, KCY, KWM_M)
c
      WL  = 750.d3
      P0  = 729.0d0
      P2  = -2184.8d0
      P4  = 1031.72d0
      P6  = -151.72d0
c
      do jp = 1, MH
         X  = WW (jp, jx)
         Y  = WW (jp, jy)
         D  = SQRT (X * X + Y * Y)
         D =  D / WL
         V  = P0
     $        + P2 * (D * D)
     $        + P4 * (D * D * D * D)
     $        + P6 * (D * D * D * D * D * D)
         VMHB (jp, KR) = V
         write (*, *) X, Y, D, V
      enddo
      RETURN
      END
CCC_ & MUTbmp  ## bedrock topography (mismip+)
      subroutine MUTbmp
     M    (VMHB,
     I     KR, KCX,  KCY,
     I     WW, ipKW, MH, LH)
      implicit none
      _INTENT(IN, integer)   MH, LH
      _INTENT(OUT,_REALSTD)  VMHB  (LH, *)
      _INTENT(IN, _REALSTD)  WW    (LH, *)
      _INTENT(IN, integer)   ipKW (IPKW_FULL_DECL)
      _INTENT(IN, integer)   KR, KCX, KCY
      integer  jx, jy, jp
      _REALSTD X,  Y,  V
      _REALSTD XN, XS, YL
      _REALSTD DC, FC, WC
      _REALSTD B0, B2, B4, B6
      _REALSTD BX, BY, BMAX
c
      jx = ipKW (KWI_KWO, KCX, KWM_M)
      jy = ipKW (KWI_KWO, KCY, KWM_M)
c
      B0 = -150.0d0
      B2 = -728.8d0
      B4 = +343.91d0
      B6 = -50.57d0
c
      XS = 300.0d3
      FC = 4.0d3
      DC = 500.0d0
      WC = 24.0d3
c
      YL   = 80.0d3
      BMAX = 720.0d0
c
      do jp = 1, MH
         X  = WW (jp, jx)
         Y  = WW (jp, jy)
         XN = X / XS
         BX = B0
     $        + B2 * (XN * XN)
     $        + B4 * (XN * XN * XN * XN)
     $        + B6 * (XN * XN * XN * XN * XN * XN)
         BY = + DC / (1.0d0 + EXP(-2.0d0 * (Y - YL * 0.5d0 - WC) / FC))
     $        + DC / (1.0d0 + EXP(+2.0d0 * (Y - YL * 0.5d0 + WC) / FC))
         V = MAX(BX + BY, -BMAX)
         VMHB (jp, KR) = V
         write (*, *) X, Y, XN, V, BX, BY
      enddo
      RETURN
      END
CCC_ & MUTbrs  ## bedrock topography (case RSLOPE)
      subroutine MUTbrs
     M    (VMHB,
     I     KR, KGR,  KCX, KCY,
     I     WW, ipKW, S0,  GRD, MH, LH)
      implicit none
      _INTENT(IN, integer)   MH, LH
      _INTENT(OUT,_REALSTD)  VMHB  (LH, *)
      _INTENT(IN, _REALSTD)  WW    (LH, *)
      _INTENT(IN, integer)   ipKW (IPKW_FULL_DECL)
      _INTENT(IN, integer)   KR, KGR, KCX, KCY
      _INTENT(IN, _REALSTD)  S0, GRD
      integer  jx, jy, jp
      _REALSTD X,  Y,  D, V
c
      jx = ipKW (KWI_KWO, KCX, KWM_M)
      jy = ipKW (KWI_KWO, KCY, KWM_M)
c
      do jp = 1, MH
         X  = WW (jp, jx)
         Y  = WW (jp, jy)
         D  = SQRT (X * X + Y * Y)
         V  = S0 + GRD * D
         VMHB (jp, KR) = V
         if (KGR.gt.0) then
            if (D.eq.0.0d0) then
               V = 0.0d0
            else
               V  = GRD * X / D
            endif
            VMHB (jp, KGR)  = V
c$$$            VMHB (jp, KGR)  = GRD
         endif
      enddo
      RETURN
      END
CCC_ & MUTtim  ## Time initialization (for test)
      subroutine MUTtim
     O    (iErr,
     O     TINIo, TENDo, DTo,
     O     TSSAo,
     O     TIRCo, DTRCo,
     I     CR,    ipP,   ipC, ipL)
CCC_  - Declaration
      implicit none
CCC_   . Arguments
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,_REALSTD)  TINIo, TENDo, DTo
      _INTENT(OUT,_REALSTD)  TIRCo, DTRCo
      _INTENT(OUT,_REALSTD)  TSSAo
      _INTENT(IN, character) CR*(*)
      _INTENT(IN, integer)   ipP, ipC, ipL
CCC_   . Configuration
      integer    KTM
      character  CROOT * (8)
      _REALSTD   TINI, TEND, DT, TSSA
      _REALSTD   TIRC, DTRC
      namelist /NITMMD/
     $     CROOT, KTM, TINI, TEND, DT, TSSA,
     $     TIRC,  DTRC
CCC_   . interior
      integer jc
CCC_  - Body
CC       Dummy statements
      iErr = 0
CCC_   . Configuration
      jc = 0
 200  continue
      call UUrwnd (iErr, ipP)
c
 100  continue
c
      KTM   = 0
      CROOT = ' '
      TINI  = 0.0d0
      TEND  = 200000.0d0
      DT    = 10.0d0
      TSSA  = 20000.0d0
      TIRC  = TINI
      DTRC  = 10000.0d0
      READ  (ipP, NITMMD, IOSTAT = iErr)
c
      if (iErr.eq.0) then
         if (CROOT.eq.CR) goto 300
         if (jc.eq.1.and.CROOT.eq.' ') goto 300
         goto 100
      else
         jc = jc + 1
         if (jc.eq.2) then
            iErr = 0
            goto 300
         endif
         goto 200
      endif
c
 300  continue
      if (iErr.eq.0) then
         CROOT = CR
         write (ipC, NITMMD, IOSTAT = iErr)
      endif
CCC_   . Packing
      if (iErr.eq.0) then
         TINIo = TINI
         TENDo = TEND
         DTo   = DT
         TSSAo = TSSA
         TIRCo = TIRC
         DTRCo = DTRC
      endif
c
      call DAtrcU (ipL, iErr, 'R', 'MUTTIM')
      RETURN
      END
CCC_* SSA
CCC_ & MUTstp  ## Test configuration suite (movement/SSA/topography)
      subroutine MUTstp
     O    (iErr,
     W     VMW,  CW,  WG,
     O     VMHB, VX,  VMI,  VMC,  VMSV, VMID,
     I     PMS,
     I     WW,   IE,  ipKW, iMA,
     L     MH,   LH,  LXK,  LWG,  CR,   ipP, ipC, ipL)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   MH, LH, LXK, LWG
      _INTENT(OUT,_REALSTD)  VMW  (LH, *)
      _INTENT(OUT,_REALSTD)  WG   (*)
      _INTENT(OUT,_REALSTD)  CW   (LH, *)
c
      _INTENT(OUT,_REALSTD)  VMHB (LH, *)
      _INTENT(OUT,_REALSTD)  VX   (LH, LXK, *)
c
      _INTENT(OUT,_REALSTD)  VMI  (*)
      _INTENT(OUT,_REALSTD)  VMID (*)
      _INTENT(OUT,_REALSTD)  VMC  (*)
      _INTENT(OUT,_REALSTD)  VMSV (*)
c
      _INTENT(IN, _REALSTD)  PMS  (*)
c
      _INTENT(IN, character) CR*(*)
      _INTENT(IN, integer)   ipP, ipC, ipL
      _INTENT(IN, integer)   IE   (*), iMA  (*)
      _INTENT(IN, integer)   ipKW (IPKW_FULL_DECL)
      _INTENT(IN, _REALSTD)  WW (LH, *)
c
      integer kxx
CCC_   . Configuration
      _REALSTD   PMTS (PMTS_MAX)
      integer    KTEST
      _REALSTD   BDC
      _REALSTD   BA
CCC_  - Body
      iErr = 0
c
CCC_   . parameter
      if (iErr.eq.0) then
         call MUTpms
     O       (iErr,
     O        KTEST,  PMTS,
     I        PMS,    CR, ipP, ipC, ipL)
      endif
CCC_   . topography field
      if (iErr.eq.0) then
         call MUTvms
     O       (iErr,
     W        VMW,  CW,   WG,
     O        VMHB, VMI,  VMC,  BA,
     I        PMS,  PMTS, KTEST,
     I        WW,   IE,   ipKW, iMA,
     L        MH,   LH,   CR,   ipP,  ipC, ipL)
      endif
CCC_   . grounding line properties
      if (iErr.eq.0) then
         call UV0sta (VMSV, MH, LH, VMSV_UGb_MI, 0.0d0)
         call UV0sta (VMSV, MH, LH, VMSV_VGc_MI, 0.0d0)
         call UV0sta (VMSV, MH, LH, VMSV_UGb,    0.0d0)
         call UV0sta (VMSV, MH, LH, VMSV_VGc,    0.0d0)
      endif
CCC_   . analytical solution (non-linear)
      if (iErr.eq.0) then
c$$$         call MUTsna
c$$$     O       (iErr, VMSV,
c$$$     I        VMI,  VMSV_MUa,  VMI_Ha,  VMI_daBAa, PMS, PMTS, MH, LH)
         call MUTsna
     O       (iErr, VMSV,
     I        VMI,  VMSV_MUa,  VMI_Ha,  BA, PMS, PMTS, MH, LH)
      endif
      if (iErr.eq.0) then
         call UV0cpa (VMSV, MH, LH, VMSV_MUaN, VMSV_MUa)
         call UV0cpa (VMSV, MH, LH, VMSV_MUaS, VMSV_MUa)
         call UV0cpa (VMSV, MH, LH, VMSV_MUaE, VMSV_MUa)
         call UV0cpa (VMSV, MH, LH, VMSV_MUaW, VMSV_MUa)
      endif
      if (iErr.eq.0) then
         call MUTsna
     O       (iErr, VMSV,
     I        VMI,  VMSV_MUd,  VMI_Hd,  BA, PMS, PMTS, MH, LH)
      endif
c
c$$$      BDC = PMS (PMS_BDRGC)
c$$$      call UV0sta (VMSV, MH, LH, VMSV_BDb, BDC)
c$$$      call UV0sta (VMSV, MH, LH, VMSV_BDc, BDC)
      call UV0sta (VMSV, MH, LH, VMSV_BDb, 0.0d0)
      call UV0sta (VMSV, MH, LH, VMSV_BDc, 0.0d0)
CCC_   + basal velocity
      call UV0sta (VMID, MH, LH, VMID_UBb, 0.0d0)
      call UV0sta (VMID, MH, LH, VMID_VBc, 0.0d0)
CCC_   . analytical solution (linear)
      kxx = BCGW_XX
      if (iErr.eq.0) then
         call MUTslp
     O       (iErr, VX (1, 1, kxx),
     I        VMI,  VMSV, VMSX_PaE, VMSX_QaE, VMI_Ha, VMSV_MUa,
     I        PMS,  PMTS, WW,       ipKW,     MH,     LH)
      endif
      if (iErr.eq.0) then
         call UV0cpa (VX (1,1,kxx), MH, LH, VMSX_PaN, VMSX_PaE)
         call UV0cpa (VX (1,1,kxx), MH, LH, VMSX_PaS, VMSX_PaE)
         call UV0cpa (VX (1,1,kxx), MH, LH, VMSX_PaW, VMSX_PaE)
         call UV0cpa (VX (1,1,kxx), MH, LH, VMSX_QaN, VMSX_QaE)
         call UV0cpa (VX (1,1,kxx), MH, LH, VMSX_QaS, VMSX_QaE)
         call UV0cpa (VX (1,1,kxx), MH, LH, VMSX_QaW, VMSX_QaE)
c
         call UV0sta (VX (1,1,kxx), MH, LH, VMSX_RdA, 0.0d0)
      endif
      if (iErr.eq.0) then
         call MUTslv
     O       (iErr,
     M        VX (1,1,kxx), VMID,
     W        WG,    VMW,
     I        LWG,
     I        KTEST, PMS,   PMTS, WW, ipKW, MH, LH)
      endif
c$$$      if (iErr.eq.0) then
c$$$         call UV1cpa (VMID, VX (1,1,kxx), MH, LH, VMID_Eb, VMSX_UbN)
c$$$         call UV1cpa (VMID, VX (1,1,kxx), MH, LH, VMID_Ec, VMSX_VcE)
c$$$      endif
      RETURN
      END
CCC_ & MUTpms  ## Parameters initialization (for test)
      subroutine MUTpms
     O    (iErr,
     O     KTEST, PMTS,
     I     PMS,   CR,    ipP, ipC, ipL)
CCC_  - Declaration
      implicit none
CCC_   . Arguments
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,_REALSTD)  PMTS (*)
      _INTENT(IN, _REALSTD)  PMS  (*)
      _INTENT(OUT,integer)   KTEST
      _INTENT(IN, character) CR*(*)
      _INTENT(IN, integer)   ipP, ipC, ipL
CCC_   . Configuration
      character  CROOT * (8)
      _REALSTD   RF
      _REALSTD   HGL,   HCF,  WLX, WLY, VGL, DGL, DX
      _REALSTD   BDC,   BDP
      namelist /NITPMS/
     $     CROOT, KTEST,
     $     RF,    HGL,  HCF,  WLX, WLY, VGL, DGL, DX,
     $     BDC,   BDP
CCC_   . interior
      integer jc
CCC_  - Body
      iErr = 0
CCC_   . Configuration
      jc = 0
 200  continue
      call UUrwnd (iErr, ipP)
c
 100  continue
c
      CROOT = ' '
      KTEST = CONFIG_X1D
      WLX   = 200.0d3
      WLY   = 0.0d0
      RF    = 4.9d-25 * 31556926.d0
      VGL   = 100.0d0
      DGL   = 0.0d0
      HGL   = 400.0d0
      HCF   = 200.0d0
      DX    = 10.0d3
c$$$      BDP   = 1.0d0
c$$$      BDC   = 7.2082d10 / 31556926.d0
      BDP   = 1.0d0 / 3.0d0
      BDC   = 7.624d6 / (31556926.d0 ** BDP)
c
      READ  (ipP, NITPMS, IOSTAT = iErr)
c
      if (iErr.eq.0) then
         if (CROOT.eq.CR) goto 300
         if (jc.eq.1.and.CROOT.eq.' ') goto 300
         goto 100
      else
         jc = jc + 1
         if (jc.eq.2) then
            iErr = 0
            goto 300
         endif
         goto 200
      endif
c
 300  continue
      if (iErr.eq.0) then
         CROOT = CR
         write (ipC, NITPMS, IOSTAT = iErr)
      endif
CCC_   . test kind adjustment
      if (iErr.eq.0) then
         if (WLY.eq.0.0d0) then
            KTEST = CONFIG_X1D
         else if (WLX.eq.0.0d0) then
            KTEST = CONFIG_Y1D
         endif
         if (KTEST.eq.CONFIG_X1D) then
            WLY = 0.0d0
         else if (KTEST.eq.CONFIG_Y1D) then
            WLX = 0.0d0
         endif
      endif
      if (iErr.eq.0) then
         if (KTEST .lt. CONFIG_MIN .or. KTEST .gt. CONFIG_MAX) then
            iErr = -1
 309        format ('MUTPMS: INVALID TEST KIND ', I3)
            write (ipL, 309) KTEST
         else if (WLX.eq.0.0d0.and.WLY.eq.0.0d0) then
            iErr = -2
 308        format ('MUTPMS: INVALID W ', I3, 1x, 2F9.1)
            write (ipL, 308) KTEST, WLX, WLY
         endif
      endif
c
      if (iErr.eq.0) then
 301     format ('MUTPMS: TEST KIND ', I3, 1x, 2F9.1)
         write (ipL, 301) KTEST, WLX, WLY
      endif
c
CCC_   . Packing
      PMTS (PMTS_RFC)   = RF
      PMTS (PMTS_HGL)   = HGL
      PMTS (PMTS_HCF)   = HCF
      PMTS (PMTS_LX)    = WLX
      PMTS (PMTS_LY)    = WLY
      PMTS (PMTS_VGL)   = VGL
      PMTS (PMTS_DGL)   = DGL
      PMTS (PMTS_DX)    = DX
CC    TODO: BDC scaling
      PMTS (PMTS_BDRGC) = BDC
      PMTS (PMTS_BDRGP) = BDP
c
      PMTS (PMTS_VGL)   = PMTS (PMTS_VGL) * PMS (PMS_XSC)
      PMTS (PMTS_RFC)   = PMTS (PMTS_RFC) * PMS (PMS_XSC)
c
      call DAtrcU (ipL, iErr, 'R', 'MUTPMS')
      RETURN
      END
CCC_ & MUTvms  ## Variables initialization (movement/SSA)
      subroutine MUTvms
     O    (iErr,
     W     VMW,  CW,   WG,
     O     VMHB, VMI,  VMC,  BA,
     I     PMS,  PMTS, KTEST,
     I     WW,   IE,   ipKW, iMA,
     L     MH,   LH,   CR,   ipP,  ipC, ipL)
CCC_  - Declaration
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   MH, LH
      _INTENT(OUT,_REALSTD)  VMW  (LH, *)
      _INTENT(OUT,_REALSTD)  WG   (*)
      _INTENT(OUT,_REALSTD)  CW   (LH, *)
c
      _INTENT(OUT,_REALSTD)  VMHB (LH, *)
      _INTENT(OUT,_REALSTD)  VMI  (LH, *)
      _INTENT(OUT,_REALSTD)  VMC  (LH, *)
      _INTENT(OUT,_REALSTD)  BA
c
      _INTENT(IN, _REALSTD)  PMS  (*)
      _INTENT(IN, _REALSTD)  PMTS (*)
      _INTENT(IN, integer)   KTEST
c
      _INTENT(IN, character) CR*(*)
      _INTENT(IN, integer)   ipP, ipC, ipL
      _INTENT(IN, integer)   IE   (*), iMA  (*)
      _INTENT(IN, integer)   ipKW (IPKW_FULL_DECL)
      _INTENT(IN, _REALSTD)  WW (LH, *)
c
      _REALSTD  HGL, HCF, DI,  DW,  DGL
      _REALSTD  WL,  WLX, WLY
      _REALSTD  RF,  PF
      _REALSTD  BDC, BDP
      integer   jp
CCC_  - Body
      iErr = 0
CCC_   . distance
      WLX = PMTS (PMTS_LX)
      WLY = PMTS (PMTS_LY)
      DGL = PMTS (PMTS_DGL)
c
      HGL = PMTS (PMTS_HGL)
      HCF = PMTS (PMTS_HCF)
      DI  = PMS  (PMS_DENS)
      DW  = PMS  (PMS_DENSW)
c
      if (iErr.eq.0) then
         if      (KTEST .eq. CONFIG_X1D
     $        .or. KTEST .eq. CONFIG_X2D) then
            WL = WLX
            call MUTsds (VMW, WW, MH, LH, ipKW, DGL, WL, 1, KWO_Xa, -1)
            call MUTsds (VMW, WW, MH, LH, ipKW, DGL, WL, 2, KWO_Xb, -1)
            call MUTsds (VMW, WW, MH, LH, ipKW, DGL, WL, 3, KWO_Xc, -1)
            call MUTsds (VMW, WW, MH, LH, ipKW, DGL, WL, 4, KWO_Xd, -1)
         else if (KTEST .eq. CONFIG_Y1D
     $        .or. KTEST .eq. CONFIG_Y2D) then
            WL = WLY
            call MUTsds (VMW, WW, MH, LH, ipKW, DGL, WL, 1, KWO_Ya, -1)
            call MUTsds (VMW, WW, MH, LH, ipKW, DGL, WL, 2, KWO_Yb, -1)
            call MUTsds (VMW, WW, MH, LH, ipKW, DGL, WL, 3, KWO_Yc, -1)
            call MUTsds (VMW, WW, MH, LH, ipKW, DGL, WL, 4, KWO_Yd, -1)
         else if (KTEST .eq. CONFIG_C2D) then
            WL = MIN (DABS (WLX), DABS (WLY))
            call MUTsds (VMW, WW,MH,LH,ipKW, DGL,WL, 1, KWO_Xa,KWO_Ya)
            call MUTsds (VMW, WW,MH,LH,ipKW, DGL,WL, 2, KWO_Xb,KWO_Yb)
            call MUTsds (VMW, WW,MH,LH,ipKW, DGL,WL, 3, KWO_Xc,KWO_Yc)
            call MUTsds (VMW, WW,MH,LH,ipKW, DGL,WL, 4, KWO_Xd,KWO_Yd)
         else
            iErr = -1
         endif
      endif
CCC_   . topography
      if (iErr.eq.0) then
         call MUTsdt
     $       (VMI, VMHB, VMW, MH, LH, HGL,HCF,DW,DI,IE,
     $        VMI_Ha, VMI_Sa, VMI_Ba, VMHB_Ra, 1)
         call MUTsdt
     $       (VMI, VMHB, VMW, MH, LH, HGL,HCF,DW,DI,IE,
     $        VMI_Hb, VMI_Sb, VMI_Bb, VMHB_Rb, 2)
         call MUTsdt
     $       (VMI, VMHB, VMW, MH, LH, HGL,HCF,DW,DI,IE,
     $        VMI_Hc, VMI_Sc, VMI_Bc, VMHB_Rc, 3)
         call MUTsdt
     $       (VMI, VMHB, VMW, MH, LH, HGL,HCF,DW,DI,IE,
     $        VMI_Hd, VMI_Sd, VMI_Bd, VMHB_Rd, 4)
      endif
CCC_   . associate rate factor integral (zeta)
      PF  = PMS  (PMS_PF)
      RF  = PMTS (PMTS_RFC)
      BA  = RF ** (-1.0d0/PF)
c$$$      write (*, *) PF, RF, BA
c
      do jp = 1, MH
         VMI (jp, VMI_daBAa) = BA
         VMI (jp, VMI_daBAd) = BA
         VMI (jp, VMI_daRFa) = RF
      enddo
CCC_   . rate factor integral
c$$$      call UV0sta (VMI, MH, LH, VMI_RFb, RF)
c$$$      call UV0sta (VMI, MH, LH, VMI_RFc, RF)
CCC_   . bedrock topography
CCC_   . gradient
      if (iErr.eq.0) then
         if      (KTEST .eq. CONFIG_X1D
     $        .or. KTEST .eq. CONFIG_Y1D) then
            call MUTsdg
     $           (VMC, MH,LH, HGL,HCF,DW,DI, WLX,WLY,VMC_DSXb,VMC_DSYb)
            call MUTsdg
     $           (VMC, MH,LH, HGL,HCF,DW,DI, WLX,WLY,VMC_DSXc,VMC_DSYc)
            call MUTsdg
     $           (VMC, MH,LH, HGL,HCF,DW,DI, WLX,WLY,VMC_DSXd,VMC_DSYd)
         else if (KTEST .eq. CONFIG_X2D) then
            call MUTsdg
     $           (VMC, MH,LH, HGL,HCF,DW,DI, WLX,0.d0,VMC_DSXb,VMC_DSYb)
            call MUTsdg
     $           (VMC, MH,LH, HGL,HCF,DW,DI, WLX,0.d0,VMC_DSXc,VMC_DSYc)
            call MUTsdg
     $           (VMC, MH,LH, HGL,HCF,DW,DI, WLX,0.d0,VMC_DSXd,VMC_DSYd)
         else if (KTEST .eq. CONFIG_Y2D) then
            call MUTsdg
     $           (VMC, MH,LH, HGL,HCF,DW,DI, 0.d0,WLY,VMC_DSXb,VMC_DSYb)
            call MUTsdg
     $           (VMC, MH,LH, HGL,HCF,DW,DI, 0.d0,WLY,VMC_DSXc,VMC_DSYc)
            call MUTsdg
     $           (VMC, MH,LH, HGL,HCF,DW,DI, 0.d0,WLY,VMC_DSXd,VMC_DSYd)
         else
            WL = MIN (DABS (WLX), DABS (WLY))
            call MUTscg
     $          (VMC, WW, MH,LH, HGL,HCF,DW,DI, WL, ipKW,
     $           KWO_Xb,KWO_Yb, VMC_DSXb,VMC_DSYb)
            call MUTscg
     $          (VMC, WW, MH,LH, HGL,HCF,DW,DI, WL, ipKW,
     $           KWO_Xc,KWO_Yc, VMC_DSXc,VMC_DSYc)
            call MUTscg
     $          (VMC, WW, MH,LH, HGL,HCF,DW,DI, WL, ipKW,
     $           KWO_Xd,KWO_Yd, VMC_DSXd,VMC_DSYd)
         endif
      endif
CCC_   . grid category
      if (iErr.eq.0) then
         call MUTgct (VMC, VMI, MH,LH, HGL,HCF, VMC_IKa, VMI_Ha, IE)
         call MUTgct (VMC, VMI, MH,LH, HGL,HCF, VMC_IKb, VMI_Hb, IE)
         call MUTgct (VMC, VMI, MH,LH, HGL,HCF, VMC_IKc, VMI_Hc, IE)
         call MUTgct (VMC, VMI, MH,LH, HGL,HCF, VMC_IKd, VMI_Hd, IE)
         if (KTEST .eq. CONFIG_X2D) then
            call MUTgcl (VMC, WW, MH,LH, DGL, ipKW, VMC_IKa, KWO_Ya)
            call MUTgcl (VMC, WW, MH,LH, DGL, ipKW, VMC_IKb, KWO_Yb)
            call MUTgcl (VMC, WW, MH,LH, DGL, ipKW, VMC_IKc, KWO_Yc)
            call MUTgcl (VMC, WW, MH,LH, DGL, ipKW, VMC_IKd, KWO_Yd)
         else if (KTEST .eq. CONFIG_Y2D) then
            call MUTgcl (VMC, WW, MH,LH, DGL, ipKW, VMC_IKa, KWO_Xa)
            call MUTgcl (VMC, WW, MH,LH, DGL, ipKW, VMC_IKb, KWO_Xb)
            call MUTgcl (VMC, WW, MH,LH, DGL, ipKW, VMC_IKc, KWO_Xc)
            call MUTgcl (VMC, WW, MH,LH, DGL, ipKW, VMC_IKd, KWO_Xd)
         endif
      endif
CCC_   . bedrock adjustment where grounded
      if (iErr.eq.0) then
         call MUTbra
     $        (VMHB, VMI, VMC, MH, LH, VMHB_Ra, VMI_Ha, VMI_Ba, VMC_IKa)
         call MUTbra
     $        (VMHB, VMI, VMC, MH, LH, VMHB_Rb, VMI_Hb, VMI_Bb, VMC_IKb)
         call MUTbra
     $        (VMHB, VMI, VMC, MH, LH, VMHB_Rc, VMI_Hc, VMI_Bc, VMC_IKc)
         call MUTbra
     $        (VMHB, VMI, VMC, MH, LH, VMHB_Rd, VMI_Hd, VMI_Bd, VMC_IKd)
      endif
CCC_   . thickness after calving
      if (iErr.eq.0) then
         call MSFhcv (VMC, VMI, MH, LH, VMC_HCa, VMC_IKa, VMI_Ha, _dOC)
      endif
CCC_   . basal drag switch
      call UV0sta (VMI, MH, LH, VMI_SLDb, 0.0d0)
      call UV0sta (VMI, MH, LH, VMI_SLDc, 0.0d0)
CCC_   . basal drag coefficient
      BDC = PMTS (PMTS_BDRGC)
      BDP = PMTS (PMTS_BDRGP)
      call UV0sta (VMHB, MH, LH, VMHB_FVBb, BDC)
      call UV0sta (VMHB, MH, LH, VMHB_FVBc, BDC)
      call UV0sta (VMHB, MH, LH, VMHB_GVBb, BDP)
      call UV0sta (VMHB, MH, LH, VMHB_GVBc, BDP)
c$$$      call UV0sta (VMI, MH, LH, VMI_SLDb, 1.0d0)
c$$$      call UV0sta (VMI, MH, LH, VMI_SLDc, 1.0d0)
CCC_   . return
      RETURN
      END
CCC_ & MUTsds  ## distance ratio for topography
      subroutine MUTsds
     O    (V,
     I     WW, MH, LH, ipKW, DGL, WL, KV, KCX, KCY)
      implicit none
      _INTENT(IN, integer)   MH, LH
      _INTENT(OUT,_REALSTD)  V  (LH, *)
c
      _INTENT(IN, _REALSTD)  WW (LH, *)
      _INTENT(IN, _REALSTD)  DGL, WL
      _INTENT(IN, integer)   ipKW (IPKW_FULL_DECL)
      _INTENT(IN, integer)   KV
      _INTENT(IN, integer)   KCX, KCY
c
      _REALSTD X, Y, D, S
      integer  jx, jy,  jp
c
      jx = 0
      jy = 0
      if (KCX.gt.0) jx = ipKW (KWI_KWO, KCX, KWM_M)
      if (KCY.gt.0) jy = ipKW (KWI_KWO, KCY, KWM_M)
c
      do jp = 1, MH
         X  = 0.0d0
         Y  = 0.0d0
         if (jx.gt.0) X  = WW (jp, jx)
         if (jy.gt.0) Y  = WW (jp, jy)
         if (jx.gt.0 .and. jy.gt.0) then
            D  = SQRT (X**2.0d0+Y**2.0d0) - DGL
            S  = 1.0d0
         else
c$$$            X  = X - DGL
            D  = ABS (X)
            S  = SIGN (1.0d0, X) * SIGN (1.0d0, WL)
         endif
         V (jp, KV) = (D * S / DABS (WL))
c$$$         write (*, *) 'DD', KV, jp, D, S, V (jp, KV), DGL
      enddo
c
      RETURN
      END
CCC_ & MUTsdt  ## distance ratio to topography
      subroutine MUTsdt
     O    (VMI, VMHB,
     I     DD,  MH,  LH,
     I     HGL, HCF, DW, DI,
     I     IE,  KH,  KS, KB,  KR,  KD)
      implicit none
      _INTENT(IN, integer)   MH, LH
      _INTENT(OUT,_REALSTD)  VMI  (LH, *)
      _INTENT(OUT,_REALSTD)  VMHB (LH, *)
      _INTENT(IN, _REALSTD)  DD   (LH, *)
      _INTENT(IN, _REALSTD)  HGL, HCF, DW, DI
      _INTENT(IN, integer)   KH, KS, KB
      _INTENT(IN, integer)   KR
      _INTENT(IN, integer)   KD
      _INTENT(IN, integer)   IE (*)
c
      integer jp, kph, ig, jg, nx, ny
      _REALSTD D, VH, VS, VB, VR
      _REALSTD TDR
c
      nx  = EA_NXG(IE)
      ny  = EA_NYG(IE)
      TDR = DI / DW
c
      do jp = 1, MH
         kph = jp - 1
         ig = EA_listLX(IE,kph)
         jg = EA_listLY(IE,kph)
         if (ig.ge.1.and.ig.le.nx
     $        .and.jg.ge.1.and.jg.le.ny) then
            D  = DD (jp, KD)
            VH = HGL - (HGL - HCF) * D
c$$$            VS = ((DW - DI) / DW) * VH
c$$$            VB = ((   - DI) / DW) * VH
            VS = (1.0d0 - TDR) * VH
            VB = (      - TDR) * VH
            if (D.lt.0.0d0) then
               VH = HGL
               VB = VS - HGL
            endif
c$$$            write (*, *) jp, VB, VH, (DI / DW) * VH
         else
            VH = 0.0d0
            VB = 0.0d0
            VS = 0.0d0
         endif
         VR = VS - HGL
c
         VMI  (jp, KH)  = VH
         VMI  (jp, KB)  = VB
         VMI  (jp, KS)  = VS
         VMHB (jp, KR)  = VR
c$$$         write (*, *) 'HBS', jp, D, VH, VB, VS
      enddo
c
      RETURN
      END
CCC_ & MUTsdg  ## gradient
      subroutine MUTsdg
     O    (VMC,
     I     MH,  LH,
     I     HGL, HCF, DW, DI,
     I     WLX, WLY, KSX, KSY)
      implicit none
      _INTENT(IN, integer)   MH, LH
      _INTENT(OUT,_REALSTD)  VMC (LH, *)
      _INTENT(IN, _REALSTD)  HGL, HCF, DW, DI
      _INTENT(IN, _REALSTD)  WLX, WLY
      _INTENT(IN, integer)   KSX, KSY
c
      _REALSTD VDX, VDY
      integer  jp
c
      if (WLX.eq.0.0d0) then
         VDY = - (HGL - HCF) / WLY * ((DW - DI) / DW)
         VDX = 0.0d0
      else
         VDX = - (HGL - HCF) / WLX * ((DW - DI) / DW)
         VDY = 0.0d0
      endif
      do jp = 1, MH
         VMC (jp, KSX) = VDX
         VMC (jp, KSY) = VDY
      enddo
      RETURN
      END
CCC_ & MUTscg  ## gradient (c)
      subroutine MUTscg
     O    (VMC,
     I     WW,   MH,  LH,
     I     HGL,  HCF, DW,  DI, WL,
     I     ipKW, KCX, KCY, KSX, KSY)
      implicit none
      _INTENT(IN, integer)   MH, LH
      _INTENT(OUT,_REALSTD)  VMC (LH, *)
      _INTENT(IN, _REALSTD)  WW  (LH, *)
      _INTENT(IN, _REALSTD)  HGL, HCF, DW, DI, WL
      _INTENT(IN, integer)   KSX, KSY
      _INTENT(IN, integer)   KCX, KCY
      _INTENT(IN, integer)   ipKW (IPKW_FULL_DECL)
c
      _REALSTD VDS, X, Y, D, FX, FY
      integer  jp, jx, jy
c
      jx = ipKW (KWI_KWO, KCX, KWM_M)
      jy = ipKW (KWI_KWO, KCY, KWM_M)
      VDS = - (HGL - HCF) / WL * ((DW - DI) / DW)
c
      do jp = 1, MH
         X = WW (jp, jx)
         Y = WW (jp, jy)
         D = SQRT (X*X+Y*Y)
         if (D.eq.0.0d0) then
            FX = 0.0d0
            FY = 0.0d0
         else
            FX = X / D
            FY = Y / D
         endif
         VMC (jp, KSX) = VDS * FX
         VMC (jp, KSY) = VDS * FY
      enddo
c
      RETURN
      END
CCC_ & MUTgct  ## grid category
      subroutine MUTgct
     O    (VMC,
     I     VMI, MH,  LH,
     I     HGL, HCF, KIK, KH, IE)
      implicit none
      _INTENT(IN, integer)   MH, LH
      _INTENT(OUT,_REALSTD)  VMC (LH, *)
      _INTENT(IN, _REALSTD)  VMI (LH, *)
      _INTENT(IN, _REALSTD)  HGL, HCF
      _INTENT(IN, integer)   KIK, KH
      _INTENT(IN, integer)   IE (*)
      integer  jp
c
      if (HGL.gt.HCF) then
         do jp = 1, MH
            if (VMI (jp, KH) .ge. HGL) then
               VMC (jp, KIK) = _dGR
            else if (VMI (jp, KH) .ge. HCF) then
               VMC (jp, KIK) = _dSH
            else
               VMC (jp, KIK) = _dOC
            endif
         enddo
      else
         do jp = 1, MH
            if (VMI (jp, KH) .le. HGL) then
               VMC (jp, KIK) = _dGR
            else if (VMI (jp, KH) .le. HCF) then
               VMC (jp, KIK) = _dSH
            else
               VMC (jp, KIK) = _dOC
            endif
         enddo
      endif
c
      RETURN
      END
CCC_ & MUTgcl  ## grid category (l)
      subroutine MUTgcl
     O    (VMC,
     I     WW,  MH,   LH,
     I     DGL, ipKW, KIK, KCY)
      implicit none
      _INTENT(IN, integer)   MH, LH
      _INTENT(OUT,_REALSTD)  VMC (LH, *)
      _INTENT(IN, _REALSTD)  WW  (LH, *)
      _INTENT(IN, _REALSTD)  DGL
      _INTENT(IN, integer)   ipKW (IPKW_FULL_DECL)
      _INTENT(IN, integer)   KIK, KCY
c
      integer  jp, jy
c
      jy = ipKW (KWI_KWO, KCY, KWM_M)
      do jp = 1, MH
         if (DABS (WW (jp, jy)).ge.DGL) then
            VMC (jp, KIK) = _dGR
         endif
      enddo
c
      RETURN
      END
CCC_ & MUTbra  ## bedrock base adjustment
      subroutine MUTbra
     O    (VMHB,
     I     VMI,  VMC,  MH,   LH,
     I     KR,   KH,   KB,   KIK)
      implicit none
      _INTENT(IN,   integer)   MH, LH
      _INTENT(INOUT,_REALSTD)  VMHB (LH, *)
      _INTENT(IN,   _REALSTD)  VMI  (LH, *)
      _INTENT(IN,   _REALSTD)  VMC  (LH, *)
      _INTENT(IN,    integer)  KR
      _INTENT(IN,    integer)  KH, KB
      _INTENT(IN,    integer)  KIK
c
      integer  jp
c
      do jp = 1, MH
         if (VMC (jp, KIK).eq. _dGR) then
            VMHB (jp, KR) = VMI (jp, KB)
         endif
      enddo
c
      RETURN
      END
CCC_ & MUTsna  ## analytical solution (non-linear)
      subroutine MUTsna
     O    (iErr,
     O     VMSV,
     I     VMI,
     I     KMU,  KH,   PBA,
     I     PMS,  PMTS, MH,  LH)
c$$$      subroutine MUTsna
c$$$     O    (iErr,
c$$$     O     VMSV,
c$$$     I     VMI,
c$$$     I     KMU,  KH,   KBZI,
c$$$     I     PMS,  PMTS, MH,  LH)
CCC_  - Declaration
      implicit none
CCC_   . Arguments
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   MH, LH
      _INTENT(OUT,_REALSTD)  VMSV (LH, *)
      _INTENT(IN, _REALSTD)  VMI  (LH, *)
      _INTENT(IN, _REALSTD)  PMS  (*)
      _INTENT(IN, _REALSTD)  PMTS (*)
      _INTENT(IN, integer)   KH, KMU
c$$$      _INTENT(IN, integer)   KBZI
      _INTENT(IN, _REALSTD)  PBA
CCC_   . Interior
      _REALSTD  DI,   DW,   GR
      _REALSTD  PF,   RF,   BA
      _REALSTD  VH,   VBHI, VUX, VMU
      integer   jp
CCC_  - Body
      iErr = 0
c
      DI  = PMS (PMS_DENS)
      DW  = PMS (PMS_DENSW)
      GR  = PMS (PMS_GRAV)
      PF  = PMS (PMS_PF)

      RF  = PMTS (PMTS_RFC)
      BA  = RF ** (-1.0d0/PF)
c
      do jp = 1, MH
         VH   = VMI (jp, KH)
c$$$         VBHI = VMI (jp, KBZI) * VH
         VBHI = PBA * VH
         if (VH.gt.0.0d0) then
            VUX = (DI / DW * (DW - DI) * GR * VH / 4.0d0 / BA) ** PF
            VMU = VBHI / 2.0d0 * (VUX ** (-1.0d0 + 1.0d0/PF))
         else
            VMU = 0.0d0
         endif
         VMSV (jp, KMU) = VMU
      enddo
c
      RETURN
      END
CCC_ & MUTslp  ## analytical solution (linear/PQ)
      subroutine MUTslp
     O    (iErr,
     O     VX,
     I     VMI,  VMSV,
     I     KP,   KQ,
     I     KH,   KMU,
     I     PMS,  PMTS, WW,  ipKW,  MH,   LH)
CCC_  - Declaration
      implicit none
CCC_   . Arguments
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   MH, LH
      _INTENT(OUT,_REALSTD)  VX   (LH, *)
      _INTENT(IN, _REALSTD)  VMI  (LH, *)
      _INTENT(IN, _REALSTD)  VMSV (LH, *)
      _INTENT(IN, _REALSTD)  PMS (*)
      _INTENT(IN, _REALSTD)  PMTS (*)
      _INTENT(IN, integer)   KP, KQ
      _INTENT(IN, integer)   KMU
      _INTENT(IN, integer)   KH
      _INTENT(IN, integer)   ipKW (IPKW_FULL_DECL)
      _INTENT(IN, _REALSTD)  WW (LH, *)
CCC_   . Interior
      _REALSTD  DI,   DW,  GR
      _REALSTD  PF,   RF,  BA
      _REALSTD  VH,   VUX, VMU
      _REALSTD  WLX, WLY,  X,   Y,    D
      _REALSTD  CFux, CFvy
      integer   jp
      integer   jx,  jy
CCC_  - Body
      iErr = 0
c
      DI  = PMS (PMS_DENS)
      DW  = PMS (PMS_DENSW)
      GR  = PMS (PMS_GRAV)
      PF  = PMS (PMS_PF)
c
      WLX = PMTS (PMTS_LX)
      WLY = PMTS (PMTS_LY)
      RF  = PMTS (PMTS_RFC)
      BA  = RF ** (-1.0d0/PF)
c
      jx = ipKW (KWI_KWO, KWO_Xa, KWM_M)
      jy = ipKW (KWI_KWO, KWO_Ya, KWM_M)
c
      if (WLX.ne.0.0d0.and.WLY.ne.0.0d0) then
         do jp = 1, MH
            X = WW (jp, jx)
            Y = WW (jp, jy)
            D = SQRT (X*X+Y*Y)
            if (D.eq.0.0d0) then
               CFux = 0.0d0
               CFvy = 0.0d0
            else
               CFux = ABS (X) / D
               CFvy = ABS (Y) / D
            endif
            VH   = VMI (jp, KH)
            VUX  = (DI / DW * (DW - DI) * GR * VH / 4.0d0 / BA) ** PF
            VMU  = VMSV (jp, KMU)
            VX (jp, KP) = VMU * (4.0d0 * VUX*CFux + 2.0d0 * VUX*CFvy)
            VX (jp, KQ) = VMU * (2.0d0 * VUX*CFux + 4.0d0 * VUX*CFvy)
         enddo
      else
         if (WLY.eq.0.0d0) then
            CFux = 1.0d0
            CFvy = 0.0d0
         else
            CFux = 0.0d0
            CFvy = 1.0d0
         endif
         do jp = 1, MH
            VH   = VMI (jp, KH)
            VUX  = (DI / DW * (DW - DI) * GR * VH / 4.0d0 / BA) ** PF
            VMU  = VMSV (jp, KMU)
            VX (jp, KP) = VMU * (4.0d0 * VUX*CFux + 2.0d0 * VUX*CFvy)
            VX (jp, KQ) = VMU * (2.0d0 * VUX*CFux + 4.0d0 * VUX*CFvy)
         enddo
      endif
c
      RETURN
      END
CCC_ & MUTslv  ## analytical solution (linear/uv)
      subroutine MUTslv
     O    (iErr,
     M     VX,    VD,
     W     WG,    VW,
     I     NWG,
     I     KTEST, PMS,   PMTS, WW, ipKW, MH, LH)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   MH,  LH
      _INTENT(IN,   integer)   NWG
      _INTENT(IN,   integer)   KTEST
      _INTENT(INOUT,_REALSTD)  VX (LH,  *)
      _INTENT(INOUT,_REALSTD)  VD (LH,  *)
      _INTENT(OUT,  _REALSTD)  VW (LH,  *)
      _INTENT(OUT,  _REALSTD)  WG (NWG)
      _INTENT(IN,   _REALSTD)  PMS  (*)
      _INTENT(IN,   _REALSTD)  PMTS (*)
      _INTENT(IN,   integer)   ipKW (IPKW_FULL_DECL)
      _INTENT(IN,   _REALSTD)  WW (LH, *)
c
      _REALSTD DI,  DW,  PF,  RF,  GR, BA
      _REALSTD WLX, WLY, WL
      _REALSTD Xa,  Xb,  DX
      _REALSTD X,   Y,   D,   S
      _REALSTD X0,  X1,  W0,  W1
      _REALSTD HGL, HCF
      _REALSTD VHa, VGL, VUXa, DGL
      _REALSTD V,   XMAX
      integer  l,  lmax
      integer  jp, jx, jy, kv,  ku, keu, kev
CCC_  - Body
      iErr = 0
c
      DI  = PMS (PMS_DENS)
      DW  = PMS (PMS_DENSW)
      PF  = PMS (PMS_PF)
      GR  = PMS (PMS_GRAV)

      HGL = PMTS (PMTS_HGL)
      DGL = PMTS (PMTS_DGL)
      HCF = PMTS (PMTS_HCF)
      RF  = PMTS (PMTS_RFC)
      BA  = RF ** (-1.0d0/PF)
c
      WLX = PMTS (PMTS_LX)
      WLY = PMTS (PMTS_LY)
      if (WLX.eq.0.0d0) then
         WL = DABS (WLY)
      else if (WLY.eq.0.0d0) then
         WL = DABS (WLX)
      else
         WL = MIN (DABS (WLX), DABS (WLY))
      endif
c
      VGL  = PMTS (PMTS_VGL)
      DX   = PMTS (PMTS_DX)
      XMAX = WL * 1.5d0
c
      call UV0sta (VD, MH, LH, VMID_UIavb, 0.0d0)
      call UV0sta (VD, MH, LH, VMID_VIavc, 0.0d0)
c
      l = 1
      WG (l) = 0.0d0
      do
         Xa = (DBLE (l - 1) + 0.5d0) * DX
         Xb = (DBLE (l - 1) + 1.0d0) * DX
         if (Xb .gt. XMAX) goto 900
         VHa = HGL - (HGL - HCF) * (Xa / WL)
c$$$         VHa = HGL - (HGL - HCF) * (Xb / WL)
         if (VHa.le.0.0d0) goto 900
         VUXa = (DI / DW * (DW - DI) * GR * VHa / 4.0d0 / BA) ** PF
         WG (l+1) = WG (l) + VUXa * DX
         write (*, *) 'V', l, Xb, WG (l+1) + VGL, VHa
         l = l + 1
         if (l.gt.NWG) goto 900
      enddo
 900  continue
      lmax = l
c
CCC_   . 1d
      if (WLY.eq.0.0d0.or.WLX.eq.0.0d0) then
         if (WLY.eq.0.0d0) then
            jx = ipKW (KWI_KWO, KWO_Xb, KWM_M)
            kv = VMSX_UbN
            ku = VMSX_VcE
            kev = VMID_UIavb
            keu = VMID_VIavc
            S  = SIGN (1.0d0, WLX)
         else
            jx = ipKW (KWI_KWO, KWO_Yc, KWM_M)
            kv = VMSX_VcE
            ku = VMSX_UbN
            kev = VMID_VIavc
            keu = VMID_UIavb
            S  = SIGN (1.0d0, WLY)
         endif
         do jp = 1, MH
            X = WW (jp, jx)
            Xa = DABS (X)
            X0 = AINT (Xa / DX) * DX
            X1 = (AINT (Xa / DX) + 1.0d0) * DX
            if (X * S.le.0.0d0) then
               V  = VGL * S
               VD (jp, kev) = V
            else
               W0 = (X1 - Xa) / (X1 - X0)
               W1 = (Xa - X0) / (X1 - X0)
               l = INT (Xa / DX) + 1
               if (X1.gt.XMAX) then
                  V = VGL + WG (lmax)
               else
                  V = VGL + (WG (l+1) * W1 + WG (l) * W0)
               endif
               V = V * S
            endif
            write (*, *) jp, X, X0, X1, l, V
            VX (jp, kv) = V
            VX (jp, ku) = 0.0d0
         enddo
CCC_   . 2d circular
      else if (KTEST .eq. CONFIG_C2D) then
         jx = ipKW (KWI_KWO, KWO_Xb, KWM_M)
         jy = ipKW (KWI_KWO, KWO_Yb, KWM_M)
         ku  = VMSX_UbN
         keu = VMID_UIavb
         do jp = 1, MH
            X = WW (jp, jx)
            Y = WW (jp, jy)
            D = SQRT (X * X + Y * Y)
            Xa = D - DGL
            X0 = AINT (Xa / DX) * DX
            X1 = (AINT (Xa / DX) + 1.0d0) * DX
            if (Xa.le.0.0d0) then
CC             for compatiblity
               V = VGL
c$$$               V = D / DGL * VGL
            else
               W0 = (X1 - Xa) / (X1 - X0)
               W1 = (Xa - X0) / (X1 - X0)
               l = INT (Xa / DX) + 1
               if (X1.gt.XMAX) then
                  V = VGL + WG (lmax)
               else
                  V = VGL + (WG (l+1) * W1 + WG (l) * W0)
               endif
            endif
            if (D.eq.0.0d0) then
               V = 0.0d0
            else
               V = V * X / D
            endif
c$$$            write (*, *) 'UC2', jp, X, Y, D, Xa, V, X/D
            VX (jp, ku) = V
            if (Xa.le.0.0d0) VD (jp, keu) = V
         enddo
         jx = ipKW (KWI_KWO, KWO_Yc, KWM_M)
         jy = ipKW (KWI_KWO, KWO_Xc, KWM_M)
         ku  = VMSX_VcE
         keu = VMID_VIavc
         do jp = 1, MH
            X = WW (jp, jx)
            Y = WW (jp, jy)
            D = SQRT (X * X + Y * Y)
            Xa = D - DGL
            X0 = AINT (Xa / DX) * DX
            X1 = (AINT (Xa / DX) + 1.0d0) * DX
c$$$            write (*, *) jp, X, Y, D, Xa
            if (Xa.le.0.0d0) then
CC             for compatiblity
               V = VGL
c$$$               V = D / DGL * VGL
            else
               W0 = (X1 - Xa) / (X1 - X0)
               W1 = (Xa - X0) / (X1 - X0)
               l = INT (Xa / DX) + 1
               if (X1.gt.XMAX) then
                  V = VGL + WG (lmax)
               else
                  V = VGL + (WG (l+1) * W1 + WG (l) * W0)
               endif
            endif
            if (D.eq.0.0d0) then
               V = 0.0d0
            else
               V = V * X / D
            endif
            VX (jp, ku) = V
            if (Xa.le.0.0d0) VD (jp, keu) = V
         enddo
CCC_   . 2d lateral
      else
         if (KTEST .eq. CONFIG_X2D) then
            jx = ipKW (KWI_KWO, KWO_Xb, KWM_M)
            jy = ipKW (KWI_KWO, KWO_Yb, KWM_M)
            kv = VMSX_UbN
            ku = VMSX_VcE
            kev = VMID_UIavb
            S  = SIGN (1.0d0, WLX)
         else
            jx = ipKW (KWI_KWO, KWO_Yc, KWM_M)
            jy = ipKW (KWI_KWO, KWO_Xc, KWM_M)
            kv = VMSX_VcE
            ku = VMSX_UbN
            kev = VMID_VIavc
            S  = SIGN (1.0d0, WLY)
         endif
         do jp = 1, MH
            X = WW (jp, jx)
            Xa = DABS (X)
            X0 = AINT (Xa / DX) * DX
            X1 = (AINT (Xa / DX) + 1.0d0) * DX
            if (X * S.le.0.0d0) then
cc             velocity reduced interior
               V  = VGL * S
     $              * MAX (0.0d0, (WL - Xa) / WL)
c$$$               V  = VGL * S
            else
               W0 = (X1 - Xa) / (X1 - X0)
               W1 = (Xa - X0) / (X1 - X0)
               l = INT (Xa / DX) + 1
               if (X1.gt.XMAX) then
                  V = VGL + WG (lmax)
               else
                  V = VGL + (WG (l+1) * W1 + WG (l) * W0)
               endif
               V = V * S
            endif
            Y = WW (jp, jy)
            V = V * MAX (0.0d0, (WL - DABS (Y)) / WL)
            VX (jp, kv) = V
            VX (jp, ku) = 0.0d0
            if (X * S.le.0.0d0) VD (jp, kev) = V
         enddo
      endif
c
      call UV0cpa (VX, MH, LH, VMSX_UbS, VMSX_UbN)
      call UV0cpa (VX, MH, LH, VMSX_VcW, VMSX_VcE)
c
      RETURN
      END
c$$$CCC_ & MSinit_symm  ## Variables initialization
c$$$      subroutine MSinit_symm
c$$$     O    (iErr,
c$$$     O     VMSX,
c$$$     W     VMW,
c$$$     I     KV,  KXK,
c$$$     I     KCX, KCY, CPOS, CSW,
c$$$     I     PMS, WO,  IE,   ipKW, MH,  LH,  LXK, ipL)
c$$$CCC_  - Declaration
c$$$      implicit none
c$$$CCC_   . Arguments
c$$$      _INTENT(OUT,integer)   iErr
c$$$      _INTENT(IN, integer)   MH, LH, LXK
c$$$      _INTENT(OUT,_REALSTD)  VMSX (LH, LXK, *)
c$$$      _INTENT(OUT,_REALSTD)  VMW (LH, *)
c$$$      _INTENT(IN, _REALSTD)  PMS (*)
c$$$      _INTENT(IN, integer)   KV,  KXK
c$$$      _INTENT(IN, integer)   KCX, KCY
c$$$      _INTENT(IN, character) CPOS*(*)
c$$$      _INTENT(IN, character) CSW*(*)
c$$$      _INTENT(IN, integer)   ipL
c$$$      _INTENT(IN, integer)   IE   (*)
c$$$      _INTENT(IN, integer)   ipKW (IPKW_FULL_DECL)
c$$$      _INTENT(IN, _REALSTD)  WO (LH, *)
c$$$CCC_   . Interior
c$$$      _REALSTD  WL,  WLX, WLY
c$$$      _REALSTD  D,   S,   X,   Y
c$$$      _REALSTD  VH
c$$$      integer   jp,  jx,  jy,  jv
c$$$      integer   ig,  jg,  nx,  ny,  kph
c$$$CCC_  - Body
c$$$      iErr = 0
c$$$c
c$$$      do jv = 1, VMSX_MAX
c$$$         call UV0sta (VMSX (1, 1, KXK), MH, LH, jv, 0.0d0)
c$$$      enddo
c$$$c
c$$$      WLX = PMS (PMS_LX)
c$$$      WLY = PMS (PMS_LY)
c$$$c
c$$$      nx  = EA_NXG(IE)
c$$$      ny  = EA_NYG(IE)
c$$$c
c$$$      jx = ipKW (KWI_KWO, KCX, KWM_M)
c$$$      jy = ipKW (KWI_KWO, KCY, KWM_M)
c$$$c
c$$$      if      (WLX.eq.0.0d0) then
c$$$         WL = DABS (WLY)
c$$$      else if (WLY.eq.0.0d0) then
c$$$         WL = DABS (WLX)
c$$$      else
c$$$         WL = MIN (DABS (WLX), DABS (WLY))
c$$$      endif
c$$$CCC_   . Scaled distance from origin
c$$$ 101  format ('Dst', A, 1x, I4, 1x, F10.1, 1x, F10.1, 1x, E16.9)
c$$$      if (iErr.eq.0) then
c$$$         if (WLX.eq.0.0d0) then
c$$$            do jp = 1, MH
c$$$               X  = WO (jp, jx)
c$$$               Y  = WO (jp, jy)
c$$$               D  = ABS (Y)
c$$$               S = SIGN (1.0d0, Y) * SIGN (1.0d0, WLY)
c$$$               VMW (jp, 1) = (D * S / WL)
c$$$               write (ipL, 101) CPOS, jp, X, Y, VMW (jp, 1)
c$$$            enddo
c$$$         else if (WLY.eq.0.0d0) then
c$$$            do jp = 1, MH
c$$$               X  = WO (jp, jx)
c$$$               Y  = WO (jp, jy)
c$$$               D  = ABS (X)
c$$$               S = SIGN (1.0d0, X) * SIGN (1.0d0, WLX)
c$$$               VMW (jp, 1) = (D * S / WL)
c$$$               write (ipL, 101) CPOS, jp, X, Y, VMW (jp, 1)
c$$$            enddo
c$$$         else
c$$$            do jp = 1, MH
c$$$               X  = WO (jp, jx)
c$$$               Y  = WO (jp, jy)
c$$$               D  = SQRT (X**2.0d0+Y**2.0d0)
c$$$               VMW (jp, 1) = D / WL
c$$$               write (ipL, 101) CPOS, jp, X, Y, VMW (jp, 1)
c$$$            enddo
c$$$         endif
c$$$      endif
c$$$c
c$$$      if (iErr.eq.0) then
c$$$         do jp = 1, MH
c$$$            kph = jp - 1
c$$$            ig = EA_listLX(IE,kph)
c$$$            jg = EA_listLY(IE,kph)
c$$$            if (ig.ge.1.and.ig.le.nx
c$$$     $           .and.jg.ge.1.and.jg.le.ny) then
c$$$               D  = VMW (jp, 1)
c$$$               X  = WO (jp, jx)
c$$$               Y  = WO (jp, jy)
c$$$               if (CSW.eq.'x') then
c$$$                  VH = (D ** 2.0d0) * X
c$$$               else if (CSW.eq.'y') then
c$$$                  VH = (D ** 2.0d0) * Y
c$$$               else if (CSW.eq.'xy') then
c$$$                  VH = (D ** 2.0d0) * X * Y
c$$$               else
c$$$                  VH = (D ** 2.0d0)
c$$$               endif
c$$$            else
c$$$               VH = 0.0d0
c$$$            endif
c$$$            VMSX (jp, KV, KXK)  = VH
c$$$         enddo
c$$$      endif
c$$$c
c$$$      RETURN
c$$$      END
CCC_* Time-dependent boundary condition
CCC_ & MUTubc  ## boundary condition update suite
      subroutine MUTubc
     O    (iErr,
     O     VMHB,
     I     VMHI,
     I     PMD,  IMD,  WW,  IMTI, PMTI,
     I     MH,   LH,
     I     ipKW, IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   MH,   LH
      _INTENT(OUT,_REALSTD)  VMHB (LH, *)
c
      _INTENT(IN, _REALSTD)  VMHI (LH, *)
c
      _INTENT(IN, _REALSTD)  PMD  (*)
      _INTENT(IN, integer)   IMD  (*)
      _INTENT(IN, integer)   IMTI (*)
      _INTENT(IN, _REALSTD)  PMTI (*)
      _INTENT(IN, _REALSTD)  WW   (LH, *)
      _INTENT(IN, integer)   ipKW (IPKW_FULL_DECL)
      _INTENT(IN, integer)   IFPl
CCC_  - Body
      iErr = 0
CCC_   . surface temperature
      if (iErr.eq.0) then
         call MUTtsf
     O       (iErr,
     O        VMHB,
     I        VMHI, PMD,  IMD,  WW,  IMTI, PMTI,
     I        MH,   LH,   ipKW, IFPl)
      endif
CCC_   . surface mass balance
      if (iErr.eq.0) then
         call MUTsmb
     O       (iErr,
     O        VMHB,
     I        VMHI, PMD,  IMD,  WW,  IMTI, PMTI,
     I        MH,   LH,   ipKW, IFPl)
      endif
CCC_   . shelf-base mass balance
      if (iErr.eq.0) then
         call MUTshb
     O       (iErr,
     O        VMHB,
     I        VMHI, PMD,  IMD,  WW,  IMTI, PMTI,
     I        MH,   LH,   ipKW, IFPl)
      endif
CCC_   . bottom temperature bc
      if (iErr.eq.0) then
         call MUTtbt
     O       (iErr,
     O        VMHB,
     I        VMHI, PMD,  IMD,  WW,  IMTI, PMTI,
     I        MH,   LH,   ipKW, IFPl)
      endif
      RETURN
      END
CCC_ & MUTtsf  ## Surface temperature
      subroutine MUTtsf
     O    (iErr,
     O     VMHB,
     I     VMHI,
     I     PMD,  IMD,  WW,  IMTI, PMTI,
     I     MH,   LH,
     I     ipKW, IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   MH,   LH
      _INTENT(OUT,_REALSTD)  VMHB (LH, *)
c
      _INTENT(IN, _REALSTD)  VMHI (LH, *)
c
      _INTENT(IN, _REALSTD)  PMD  (*)
      _INTENT(IN, integer)   IMD  (*)
      _INTENT(IN, integer)   IMTI (*)
      _INTENT(IN, _REALSTD)  PMTI (*)
      _INTENT(IN, _REALSTD)  WW   (LH, *)
      _INTENT(IN, integer)   ipKW (IPKW_FULL_DECL)
      _INTENT(IN, integer)   IFPl
c
      integer jx, jy
      integer jp
      _REALSTD X, Y, D, V, H
      _REALSTD Toff, Tgrd, Tdu
      _REALSTD TCX (3, 3), THX(3)
      integer  KSW, KCX
CCC_  - Body
      iErr = 0
      KSW  = IMTI (IMTI_CFG_TS)
      if (KSW .eq. CONFIG_TS_BENCHFIX) then
         Toff = 239.0d0
         Tgrd = 8.0d-8
         Tdu  = 1.0d3
         jx = ipKW (KWI_KWO, KWO_Xa, KWM_M)
         jy = ipKW (KWI_KWO, KWO_Ya, KWM_M)
         do jp = 1, MH
            X  = WW (jp, jx)
            Y  = WW (jp, jy)
            D  = MAX (ABS (X), ABS (Y))
            V  = Toff + Tgrd * (D / Tdu) ** 3.0d0
            VMHB (jp, VMHB_TSI) = V
         enddo
      else if (KSW .eq. CONFIG_TS_BENCHMOV) then
         Toff = 270.0d0
         Tgrd = -0.01d0
         do jp = 1, MH
            VMHB (jp, VMHB_TSI) = Toff + Tgrd * VMHI (jp, VMHI_nSa)
         enddo
CC    Exp.A hard-coded
      else if (KSW .eq. CONFIG_TS_EP2S) then
         Toff = 238.15d0
         Tgrd = 1.67d-5
         jx = ipKW (KWI_KWO, KWO_Xa, KWM_M)
         jy = ipKW (KWI_KWO, KWO_Ya, KWM_M)
         do jp = 1, MH
            X  = WW (jp, jx)
            Y  = WW (jp, jy)
            D  = SQRT (X * X + Y * Y)
            V  = Toff + Tgrd * D
            VMHB (jp, VMHB_TSI) = V
         enddo
      else if (KSW .eq. CONFIG_TS_HEINO) then
         Toff = 233.15d0
         Tgrd = 2.5d-9
         Tdu  = 1.0d3
         jx = ipKW (KWI_KWO, KWO_Xa, KWM_M)
         jy = ipKW (KWI_KWO, KWO_Ya, KWM_M)
         do jp = 1, MH
            X  = WW (jp, jx)
            Y  = WW (jp, jy)
            D  = SQRT (X * X + Y * Y)
            V  = Toff + Tgrd * (D / Tdu) ** 3.0d0
            VMHB (jp, VMHB_TSI) = V
         enddo
      else if (KSW .eq. CONFIG_TS_SR0AA) then
         TCX(1,1) = 280.555d0
         TCX(2,1) = -0.014285d0
         TCX(3,1) = -0.180d0
         TCX(1,2) = 309.839d0
         TCX(2,2) = -0.005102d0
         TCX(3,2) = -0.725d0
         TCX(1,3) = 322.792d0
         TCX(2,3) = 0.0d0
         TCX(3,3) = -0.943d0
         THX(1)   = 1500.0d0
         THX(2)   = 200.0d0
         do jp = 1, MH
            H = Max(0.0d0, VMHI (jp, VMHI_nSa) - VMHB(jp, VMHB_SLVa))
c$$$            write (*, *) 'TS', jp, H
            if (H.gt.THX(1)) then
               KCX = 1
            else if (H.gt.THX(2)) then
               KCX = 2
            else
               KCX = 3
            endif
            VMHB (jp, VMHB_TSI) =
     $           TCX(1, KCX)
     $           + TCX(2, KCX) * H
     $           + TCX(3, KCX) * ABS (VMHB(jp, VMHB_GLA))
         enddo
      else
         continue
      endif
      RETURN
      END
CCC_ & MUTsmb  ## Surface mass balance
      subroutine MUTsmb
     O    (iErr,
     O     VMHB,
     I     VMHI,
     I     PMD,  IMD,  WW,  IMTI, PMTI,
     I     MH,   LH,
     I     ipKW, IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   MH,   LH
      _INTENT(OUT,_REALSTD)  VMHB (LH, *)
c
      _INTENT(IN, _REALSTD)  VMHI (LH, *)
c
      _INTENT(IN, _REALSTD)  PMD  (*)
      _INTENT(IN, integer)   IMD  (*)
      _INTENT(IN, integer)   IMTI (*)
      _INTENT(IN, _REALSTD)  PMTI (*)
      _INTENT(IN, _REALSTD)  WW   (LH, *)
      _INTENT(IN, integer)   ipKW (IPKW_FULL_DECL)
      _INTENT(IN, integer)   IFPl
c
      integer jx, jy
      integer jp
      _REALSTD X, Y, D, V, H
      _REALSTD Toff, Tgrd, Tdu
      _REALSTD TCX (3, 3), THX(3)
      integer  KSW, KCX
CCC_  - Body
      iErr = 0
      KSW  = IMTI (IMTI_CFG_MS)
      if (KSW .eq. CONFIG_MS_ELA) then
         do jp = 1, MH
            H = Max(0.0d0, VMHI (jp, VMHI_nSa) - VMHB(jp, VMHB_SLVa))
            VMHB (jp, VMHB_MS) =
     $           MIN(0.30d0,(H-1500.0d0)/1500.0d0*3.0d0)
            VMHB (jp, VMHB_TMBa) = VMHB(jp,VMHB_MS)
         enddo
      else
         continue
      endif
      RETURN
      END
CCC_ & MUTshb  ## Shelf-base mass balance
      subroutine MUTshb
     O    (iErr,
     O     VMHB,
     I     VMHI,
     I     PMD,  IMD,  WW,  IMTI, PMTI,
     I     MH,   LH,
     I     ipKW, IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   MH,   LH
      _INTENT(OUT,_REALSTD)  VMHB (LH, *)
c
      _INTENT(IN, _REALSTD)  VMHI (LH, *)
c
      _INTENT(IN, _REALSTD)  PMD  (*)
      _INTENT(IN, integer)   IMD  (*)
      _INTENT(IN, integer)   IMTI (*)
      _INTENT(IN, _REALSTD)  PMTI (*)
      _INTENT(IN, _REALSTD)  WW   (LH, *)
      _INTENT(IN, integer)   ipKW (IPKW_FULL_DECL)
      _INTENT(IN, integer)   IFPl
c
      integer jx, jy
      integer jp
      _REALSTD H,  R
      _REALSTD ZD, Z0, WM, HC, HC0
      _REALSTD HH, EP, EM, TH
      integer  KSW, KCX
CCC_  - Body
      iErr = 0
      KSW  = IMTI (IMTI_CFG_MBSH)
      if (KSW .eq. CONFIG_MBSH_MISMIP_P) then
         Z0  = -100.0d0
         HC0 = 75.0d0
         WM  = -0.20d0
         do jp = 1, MH
            ZD = VMHI(jp, VMHI_nBa)
            HC = ZD- VMHB(jp, VMHB_NRa)
            if (HC.gt.0.0d0) then
               HH = HC / HC0
               EP = EXP(+HC0)
               EM = EXP(-HC0)
               TH = (EP - EM) / (EP + EM)
               VMHB (jp, VMHB_MB) = WM * TH * MAX(0.0d0, Z0-ZD)
            else
               VMHB (jp, VMHB_MB) = 0.0d0
            endif
         enddo
         do jp = 1, MH
            VMHB (jp, VMHB_TMBa) =
     $           VMHB (jp, VMHB_TMBa) + VMHB(jp,VMHB_MB)
         enddo
      else
         continue
      endif
      RETURN
      END
CCC_ & MUTtbt  ## Bottom temperature bc
      subroutine MUTtbt
     O    (iErr,
     O     VMHB,
     I     VMHI,
     I     PMT,  IMT,  WW,  IMTI, PMTI,
     I     MH,   LH,
     I     ipKW, IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   MH,   LH
      _INTENT(OUT,_REALSTD)  VMHB (LH, *)
c
      _INTENT(IN, _REALSTD)  VMHI (LH, *)
c
      _INTENT(IN, _REALSTD)  PMT  (*)
      _INTENT(IN, integer)   IMT  (*)
      _INTENT(IN, integer)   IMTI (*)
      _INTENT(IN, _REALSTD)  PMTI (*)
      _INTENT(IN, _REALSTD)  WW   (LH, *)
      _INTENT(IN, integer)   ipKW (IPKW_FULL_DECL)
      _INTENT(IN, integer)   IFPl
c
      integer  jp
      integer  KSW
      _REALSTD V
CCC_  - Body
      iErr = 0
      KSW  = IMTI (IMTI_CFG_TB)
      if (KSW .eq. CONFIG_TB_FIX) then
         V = PMT (PMT_TBSHC)
         do jp = 1, MH
            if (VMHB(jp,VMHB_NRa).lt.VMHI(jp,VMHI_nBa)) then
               VMHB (jp, VMHB_TBI)   = V
               VMHB (jp, VMHB_TBFLG) = 1.0d0
            else
               VMHB (jp, VMHB_TBI)   = 0.0d0
               VMHB (jp, VMHB_TBFLG) = 0.0d0
            endif
         enddo
      else if (KSW .eq. CONFIG_TB_GEO) then
         call UV0sta (VMHB, MH, LH, VMHB_TBI,   0.0d0)
         call UV0sta (VMHB, MH, LH, VMHB_TBFLG, 0.0d0)
CCC_   . not implemented yet
      else
         iErr = 999
      endif
      RETURN
      END
CCC_* Initialization by external file
CCC_ & MUTami  ## Variables initialization (file/ascii individual)
      subroutine MUTami
     O    (iErr,
     O     VMHR, VMHB, VMHI, VMTI, VMTW, VMI,
     W     CW,
     I     PMD,  IMD,  WW,   WZV,  GG,  NTH,  IMTI, PMTI,
     I     MH,   LH,   NZ,   LZ,   KZ0,
     I     CR,   ipKW, iMA,  IE,   ipP, ipC,  ipL)
CCC_  - Declaration
      implicit none
CCC_   . Arguments
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   MH, LH
      _INTENT(IN, integer)   NZ, LZ, KZ0
      _INTENT(IN, integer)   NTH
      _INTENT(OUT,_REALSTD)  VMI  (LH, *)
      _INTENT(OUT,_REALSTD)  VMHI (LH, *)
      _INTENT(OUT,_REALSTD)  VMHR (LH, *)
      _INTENT(OUT,_REALSTD)  VMHB (LH, *)
      _INTENT(OUT,_REALSTD)  VMTI (LH, LZ, *)
      _INTENT(OUT,_REALSTD)  VMTW (LH, LZ, *)
c
      _INTENT(OUT,_REALSTD)  CW   (LH, *)
c
      _INTENT(IN, _REALSTD)  PMD  (*)
      _INTENT(IN, integer)   IMD  (*)
      _INTENT(IN, integer)   IMTI (*)
      _INTENT(IN, _REALSTD)  PMTI (*)
      _INTENT(IN, _REALSTD)  WZV  (LZ, *)
      _INTENT(IN, _REALSTD)  WW   (LH, *)
      _INTENT(IN, _REALSTD)  GG   (*)
      _INTENT(IN, integer)   ipKW (IPKW_FULL_DECL)
      _INTENT(IN, integer)   iMA  (*)
      _INTENT(IN, integer)   IE   (*)
      _INTENT(IN, character) CR*(*)
      _INTENT(IN, integer)   ipP, ipC, ipL
CCC_   . Configuration
      iErr = 0
CCC_  - Body
      if (iErr.eq.0) then
         call MUTafm
     $       (iErr,
     $        CW, VMI,  LH, VMI_MAX,  CR, 'VMI',  IE, ipP, ipC, ipL)
      endif
      if (iErr.eq.0) then
         call MUTafm
     $       (iErr,
     $        CW, VMHB, LH, VMHB_MAX, CR, 'VMHB', IE, ipP, ipC, ipL)
      endif
      if (iErr.eq.0) then
         call MUTafm
     $       (iErr,
     $        CW, VMHR, LH, VMHR_MAX, CR, 'VMHR', IE, ipP, ipC, ipL)
      endif
CCC_   + return
      call DAtrcU (ipL, iErr, 'R', 'MUTAMI')
      RETURN
      END
CCC_ & MUTafm  ## Variables initialization (file/ascii namelist)
      subroutine MUTafm
     O    (iErr,
     W     W,
     O     V,
     I     LH,   NVar,
     I     CR,   GRP,  IE,  ipP, ipC,  ipL)
CCC_  - Declaration
      implicit none
CCC_   . Arguments
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,_REALSTD)  W    (*)
      _INTENT(IN, integer)   LH,   Nvar
      _INTENT(OUT,_REALSTD)  V    (LH, *)
      _INTENT(IN, integer)   IE   (*)
      _INTENT(IN, character) CR*(*)
      _INTENT(IN, character) GRP*(*)
      _INTENT(IN, integer)   ipP, ipC, ipL
CCC_   . file configuration
      character CROOT*(32)
      character GROUP*(32)
      character FNM*(OPT_FILENAME_MAX)
      character FMT*(128)
      integer   idxV
      integer   IX, IY
      _REALSTD  VUNDEF
CCC_   + interior
      integer jfp
      integer lv, mw
      integer jp, np
      integer kg, kx, ky
CCC_  - Body
      iErr = 0
c
      jfp  = -1
      lv   = -1
      NP = EA_NP(IE)
c
      call UUrwnd (iErr, ipP)
      if (iErr.eq.0) call UUMCnu (iErr, jfp)
c
      DO
         if (iErr.eq.0) then
            call MUTanr
     $          (iErr,
     $           CROOT, GROUP, idxV, FNM, FMT, IX, IY, VUNDEF, ipP)
         endif
         if (iErr.eq.0) then
            if (CROOT.eq.CR .and. GROUP.eq.GRP) then
               if (idxV.gt.Nvar) then
                  iErr = -1
               else
                  call MUTanw
     $                (iErr,
     $                 CROOT,GROUP,idxV, FNM,FMT,IX,IY, VUNDEF, ipC)
                  mw = ix * iy
                  call UUopen (iErr, jfp, FNM, LV, 'F', 'O', 'R', ' ')
                  if (iErr.eq.0) call UUwrSS (iErr, jfp, mw, W)
                  write (ipL, 309) _TRIM(GRP), idxV
                  do jp = 0, NP - 1
                     kx = EA_listLX(IE,jp)
                     ky = EA_listLY(IE,jp)
                     if (kx.lt.1
     $                    .or.kx.gt.ix
     $                    .or.ky.lt.1
     $                    .or.ky.gt.iy) then
                        V (jp + 1, idxV) = VUNDEF
                     else
                        kg = (ky - 1) * ix + kx
                        V (jp + 1, idxV) = W (kg)
                     endif
c$$$                     write (ipL, 301) idxV, jp, kx, ky, V (jp + 1, idxV)
                     write (ipL, 301) jp, kx, ky, V (jp + 1, idxV)
                  enddo
               endif
            endif
         else
            goto 300
         endif
      ENDDO
 309  format ('MUTAFM:', A5, 1x, I5)
 301  format (3I5, 1x, E16.9)
 300  continue
      if (jfp.ge.0) call UUclsC (iErr, jfp, ' ', ' ')
      call DAtrcU (ipL, iErr, GRP, 'MUTAFM')
      RETURN
      END
CCC_ & MUTanw  ## Variables initialization (file/ascii/namelist/write)
      subroutine MUTanw
     O    (iErr,
     I     CRi, GRi, IDXi, FNi, FMTi, IXi, IYi, VUDi,
     I     IFPn)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, character) CRi*(*), GRi*(*)
      _INTENT(IN, character) FNi*(*), FMTi*(*)
      _INTENT(IN, integer)   IDXi,    IXi, IYi
      _INTENT(IN, _REALSTD)  VUDi
      _INTENT(OUT,character) CRo*(*), GRo*(*)
      _INTENT(OUT,character) FNo*(*), FMTo*(*)
      _INTENT(OUT,integer)   IDXo,    IXo, IYo
      _INTENT(OUT,_REALSTD)  VUDo
      _INTENT(IN, integer)   IFPn, IFPp
      integer    LVEML
      parameter (LVEML = OPT_NAMELIST_OUTPUT_EMULATION)
      character CROOT*(32)
      character GROUP*(32)
      character FNM*(OPT_FILENAME_MAX)
      character FMT*(128)
      integer   IDX, IX, IY
      _REALSTD  VUNDEF
      namelist /NITAMI/
     $     CROOT, GROUP, IDX,
     $     FNM,   FMT,   IX,  IY, VUNDEF
      integer jr
CCC_  - Body
      iErr = 0
      CROOT  = CRi
      GROUP  = GRi
      FNM    = FNi
      FMT    = FMTi
      IDX    = IDXi
      IX     = IXi
      IY     = IYi
      VUNDEF = VUDi
      if (LVEML.gt.0) then
         call UNBbgn (iErr, 'NITAMI',       IFPn, LVEML)
         call UNBstr (iErr, 'CROOT', CROOT, IFPn, LVEML)
         call UNBstr (iErr, 'GROUP', GROUP, IFPn, LVEML)
         call UNBstr (iErr, 'FNM',   FNM,   IFPn, LVEML)
         call UNBstr (iErr, 'FMT',   FMT,   IFPn, LVEML)
         call UNBint (iErr, 'IDX',   IDX,   IFPn, LVEML)
         call UNBint (iErr, 'IX',    IX,    IFPn, LVEML)
         call UNBint (iErr, 'IY',    IY,    IFPn, LVEML)
         call UNBrst (iErr, 'VUNDEF',VUNDEF,IFPn, LVEML)
         call UNBend (iErr, 'NITAMI',       IFPn, LVEML)
      else
         if (COND_N(IFPn)) then
            write (IFPn, NITAMI)
         else if (COND_S(IFPn)) then
            write (*,    NITAMI)
         endif
      endif
      RETURN
CCC_  & MUTanr  ## read namelist
      entry MUTanr
     O    (iErr,
     I     CRo, GRo, IDXo, FNo, FMTo, IXo, IYo, VUDo,
     I     IFPp)
      iErr = 0
c
      CROOT  = ' '
      GROUP  = ' '
      FNM    = ' '
      FMT    = ' '
      IDX    = -1
      IX     = 0
      IY     = 0
      VUNDEF = 0.0d0
c
      READ  (IFPp, NITAMI, IOSTAT = iErr)
      CRo  = CROOT
      GRo  = GROUP
      FNo  = FNM
      FMTo = FMT
      IDXo = IDX
      IXo  = IX
      IYo  = IY
      VUDo = VUNDEF
      RETURN
      END
CCC_ & MUTfmi  ## Variables initialization (file/cluster)
      subroutine MUTfmi
     O    (iErr,
     O     VMHR, VMHB, VMHI, VMTI, VMTW, VMI,
     I     LH,   LZ,
     I     CR,   iMA,  ipP,  ipC,  ipL)
CCC_  - Declaration
      implicit none
CCC_   . Arguments
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   LH
      _INTENT(IN, integer)   LZ
      _INTENT(OUT,_REALSTD)  VMI  (*)
      _INTENT(OUT,_REALSTD)  VMHI (*)
      _INTENT(OUT,_REALSTD)  VMTI (*)
      _INTENT(OUT,_REALSTD)  VMTW (*)
      _INTENT(OUT,_REALSTD)  VMHR (*)
      _INTENT(OUT,_REALSTD)  VMHB (*)
      _INTENT(IN, integer)   iMA  (*)
      _INTENT(IN, character) CR*(*)
      _INTENT(IN, integer)   ipP, ipC, ipL
      integer nv
      integer jerr, jstt
CCC_  - Body
      nv   = LH
      iErr = 0
      jstt = 0
      call MUTnfm
     $    (jErr, VMI,  nv, VMI_MAX,  CR, 'VMI',  iMA, ipP, ipC, ipL)
      if (jErr.ne.0) jStt = jStt + 1
      nv = LH * LZ
      call MUTnfm
     $    (jErr, VMTI, nv, VMTI_MAX, CR, 'VMTI', iMA, ipP, ipC, ipL)
      if (jErr.ne.0) jStt = jStt + 1
c$$$      nv = LH
c$$$      call MUTnfm
c$$$     $    (iErr, VMHI, nv, VMHI_MAX, CR, 'VMHI', iMA, ipP, ipC, ipL)
c$$$      nv = LH
c$$$      call MUTnfm
c$$$     $    (iErr, VMHB, nv, VMHB_MAX, CR, 'VMHB', iMA, ipP, ipC, ipL)
c$$$      nv = LH * LZ
c$$$      call MUTnfm
c$$$     $    (iErr, VMTW, nv, VMTW_MAX, CR, 'VMTW', iMA, ipP, ipC, ipL)
CCC_   . result
      if (jStt.eq.0) then
         iErr = 0
      else if (jStt.eq.2) then
         iErr = 1
      else
         iErr = -1
      endif
 101  format ('MUTFMI: SUCCESS')
 102  format ('MUTFMI: NO INIT')
 103  format ('MUTFMI: PANIC')
      if (COND_N(ipL)) then
         if (iErr.eq.0) then
            write (ipL, 101)
         else if (iErr.gt.0) then
            write (ipL, 102)
         else
            write (ipL, 103)
         endif
      else if (COND_S(ipL)) then
         if (iErr.eq.0) then
            write (*, 101)
         else if (iErr.gt.0) then
            write (*, 102)
         else
            write (*, 103)
         endif
      endif
      iErr = MIN (0, iErr)
      call DAtrcU (ipL, iErr, 'R', 'MUTFMI')
      RETURN
      END
CCC_ & MUTnfm  ## Variables initialization (file/namelist)
      subroutine MUTnfm
     O    (iErr,
     O     V,
     I     NVi,  MVi,
     I     CR,   GRP,  iMA,  ipP, ipC,  ipL)
CCC_  - Declaration
      implicit none
CCC_   . Arguments
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   NVi, MVi
      _INTENT(OUT,_REALSTD)  V    (NVi, MVi)
      _INTENT(IN, integer)   iMA  (*)
      _INTENT(IN, character) CR*(*)
      _INTENT(IN, character) GRP*(*)
      _INTENT(IN, integer)   ipP, ipC, ipL
CCC_   . file configuration
      character CROOT*(32)
      character GROUP*(32)
      character FNM*(OPT_FILENAME_MAX)
      integer   NV, LB, NR, MV
      integer    MAXR
      parameter (MAXR = OPT_INIT_MAXREC)
      integer    IRSKP (MAXR)
CCC_   . run-time
      integer   LV
      integer   IR, NRi
      integer   ivx, jrec
      integer   jfpini
      integer   j, jr
      logical   OSKP
CCC_  - Body
      iErr = 0
      call UUrwnd (iErr, ipP)
      do jr = 1, MAXR
         IRSKP (jr) = 0
      enddo
c
      DO
         if (iErr.eq.0) then
            call MUTnmr
     $           (iErr, CROOT, GROUP, FNM, NV, LB, NR, MV, IRSKP, ipP)
         endif
         if (iErr.eq.0) then
            if (CROOT.eq.CR .and. GROUP.eq.GRP) then
               call MUTnmw
     $             (iErr,
     $              CROOT, GROUP, FNM, NV, LB, NR, MV, IRSKP, ipC)
               goto 300
            endif
         else
            goto 300
         endif
      ENDDO
 300  continue
      jfpini = -1
      if (iErr.eq.0) then
         call DVPb2l (LV, LB, ' ', ' ')
         call UUMCnu (iErr, jfpini)
         if (iErr.eq.0)
     $        call UUopen (iErr, jfpini, FNM, LV, 'U', 'O', 'R', ' ')
         if (iErr.eq.0) then
            call DMAget (IR,  iMA, 'IR')
            call DMAget (NRi, iMA, 'NR')
            do ivx = 1, MVi
               OSKP = .false.
               do jr = 1, MVi
                  if (IRSKP (jr).eq.ivx) OSKP = .true.
               enddo
 301           format ('SKIP RECORD:', I5)
               if (OSKP) then
                  if      (COND_N(ipL)) then
                     write (ipL, 301) ivx
                  else if (COND_S(ipL)) then
                     write (*,   301) ivx
                  endif
               else
                  jrec = 1 + IR + (ivx - 1) * NRi
                  call UUwrRS (iErr, jfpini, jrec, NVi, V (1, ivx))
               endif
            enddo
         endif
         if (iErr.eq.0) call UUclsC (iErr, jfpini, FNM, ' ')
      endif
      call DAtrcU (ipL, iErr, GRP, 'MUTNFM')
      RETURN
      END
CCC_ & MUTnmw  ## Variables initialization (file/namelist/write)
      subroutine MUTnmw
     O    (iErr,
     I     CRi, GRi, FNi, NVi, LBi, NRi, MVi, IRSi,
     I     IFPn)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, character) CRi*(*), GRi*(*), FNi*(*)
      _INTENT(IN, integer)   NVi, LBi, NRi, MVi
      _INTENT(IN, integer)   IRSi (*)
      _INTENT(OUT,character) CRo*(*), GRo*(*), FNo*(*)
      _INTENT(OUT,integer)   NVo, LBo, NRo, MVo
      _INTENT(OUT,integer)   IRSo (*)
      _INTENT(IN, integer)   IFPn, IFPp
      integer    LVEML
      parameter (LVEML = OPT_NAMELIST_OUTPUT_EMULATION)
      character CROOT*(32)
      character GROUP*(32)
      character FNM*(OPT_FILENAME_MAX)
      integer   NV, LB, NR, MV
      integer    MAXR
      parameter (MAXR = OPT_INIT_MAXREC)
      integer    IRSKP (MAXR)
      namelist /NITFMI/
     $     CROOT, GROUP, NV, LB, NR, MV, FNM,
     $     IRSKP
      integer jr
CCC_  - Body
      iErr = 0
      CROOT = CRi
      GROUP = GRi
      FNM   = FNi
      NV    = NVi
      LB    = LBi
      NR    = NRi
      MV    = MVi
      do jr = 1, MAXR
         IRSKP (jr) = 0
      enddo
      do jr = 1, MV
         IRSKP (jr) = IRSi (jr)
      enddo
      if (LVEML.gt.0) then
         call UNBbgn (iErr, 'NITFMI',       IFPn, LVEML)
         call UNBstr (iErr, 'CROOT', CROOT, IFPn, LVEML)
         call UNBstr (iErr, 'GROUP', GROUP, IFPn, LVEML)
         call UNBstr (iErr, 'FNM',   FNM,   IFPn, LVEML)
         call UNBint (iErr, 'NV',    NV,    IFPn, LVEML)
         call UNBint (iErr, 'LB',    LB,    IFPn, LVEML)
         call UNBint (iErr, 'NR',    NR,    IFPn, LVEML)
         call UNBint (iErr, 'MV',    MV,    IFPn, LVEML)
         call UNBina (iErr, 'IRSKP', IRsi,  MV, 0, IFPn, LVEML)
         call UNBend (iErr, 'NITFMI',       IFPn, LVEML)
      else
         if (COND_N(IFPn)) then
            write (IFPn, NITFMI)
         else if (COND_S(IFPn)) then
            write (*,    NITFMI)
         endif
      endif
      RETURN
CCC_  & MUTnmr  ## read namelist
      entry MUTnmr
     O    (iErr,
     O     CRo, GRo, FNo, NVo, LBo, NRo, MVo, IRSo,
     I     IFPp)
      iErr = 0
c
      CROOT = ' '
      GROUP = ' '
      NV    = 0
      LB    = 0
      NR    = -1
      MV    = 0
      FNM   = ' '
      do jr = 1, MAXR
         IRSKP (jr) = 0
      enddo
c
      READ  (IFPp, NITFMI, IOSTAT = iErr)
      CRo = CROOT
      GRo = GROUP
      FNo = FNM
      NVo = NV
      LBo = LB
      NRo = NR
      MVo = MV
      do jr = 1, MV
         IRSo (jr) = IRSKP (jr)
      enddo
      RETURN
      END
CCC_& MUTCFG  ## Announcement
      subroutine MUTCFG (STRA, STRB, IOP)
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
         STRB = ' '
      else
         STRA = ' '
         STRB = ' '
      endif
      RETURN
      END
CCC_@ MUCTST  ## Test program
#ifdef TEST_MUTCFG
      program MUCTST
CCC_ + Test suites
CC::   SOURCES mifunc.F msfunc.F
CCC_ + Declaration
      implicit none
      integer iErr
CCC_ + Body
      call DDcmin (iErr)
      call DDfmin (iErr)
      STOP
      END
#endif /* TEST_MUTCFG */
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
