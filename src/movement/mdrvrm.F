C movement/mdrvrm.F --- IcIES/Movement/driver
C Maintainer: SAITO Fuyuki
C Created: Oct 28 2011
C Revision:  Snoopy0.9
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2018/12/18 09:20:32 fuyuki mdrvrm.F>'
#define _FNAME 'movement/mdrvrm.F'
#define _REV   'Snoopy0.9'
CCC_! MANIFESTO
C
C Copyright (C) 2011--2020
C           Japan Agency for Marine-Earth Science and Technology,
C           Ayako ABE-OUCHI
C
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
CCC_* Test
#ifndef   TEST_MDRVRM
#  define TEST_MDRVRM 0
#endif
#if       TEST_MDRVRM == 2 /* small/h1k */
#  define OPT_MOVEMENT_LHP_MAX 1153 /* for 7pe (1113) */
#  define OPT_MOVEMENT_LHG_MAX 1153
#  define OPT_MOVEMENT_LVZ_MAX 66
#elif     TEST_MDRVRM == 3 /* heino */
#  define OPT_MOVEMENT_LHP_MAX 8092
#  define OPT_MOVEMENT_LHG_MAX 8092
#  define OPT_MOVEMENT_LVZ_MAX 66
#elif     TEST_MDRVRM == 5 /* heino/10km/128 */
#  define OPT_MOVEMENT_LHP_MAX 262144
#elif     TEST_MDRVRM == 6 /* aa */
#  define OPT_MOVEMENT_LHP_MAX 32768
#  define OPT_MOVEMENT_LHG_MAX 32768
#  define OPT_MOVEMENT_LVZ_MAX 66
#elif     TEST_MDRVRM == 7 /* aa */
#  define OPT_MOVEMENT_LHP_MAX 1024
#  define OPT_MOVEMENT_LHG_MAX 1024
#  define OPT_MOVEMENT_LVZ_MAX 514
#elif     TEST_MDRVRM == 8 /* aa big */
#  define OPT_MOVEMENT_LHP_MAX 524288
#  define OPT_MOVEMENT_LHG_MAX 524288
#  define OPT_MOVEMENT_LVZ_MAX 21
#endif /* 1k */
CCC_* Common macros
#include "ofdlct.h"   /* fortran dialect */
#include "ofnstd.h"
#include "oarpea.h"
#include "oarpkw.h"   /* operation id in arpeggio/kiwi */
#include "odevva.h"
#include "movement.h" /* movement definitions */
#include "ounelv.h"
#include "ologfm.h"   /* logging */
CCC_ + System-dependent switches
#ifndef   OPT_FORMAT_STAR
#  define OPT_FORMAT_STAR 0
#endif
#if OPT_FORMAT_STAR
#  define _FORMAT(F) *
#else
#  define _FORMAT(F) F
#endif
CCC_ + Options
#ifndef    OPT_NAMELIST_OUTPUT_EMULATION
#  define  OPT_NAMELIST_OUTPUT_EMULATION _UNMLEM_LEVEL_END
#endif
CCC_* [Integration]
CCC_ & MDstpD  ## Movement/Driver integration suite (dynamics)
      subroutine MDstpD
     O    (iErr,
     M     VMHI, VMTI, VMI,
     W     XI,   XS,   CW,   GW,    VMW,  VMHW, VMTW,
     W     QM,   VMC,  VMID,
     W     VMSC, VMSV, VMSE,
     I     VMHB, OMM,  IMM,  PMM,   T,    DT,
     I     WW,   WZV,  GG,
     I     MH,   LH,   NZ,   LZ,    KZ0,  NTH,
     I     IE,   ipKW, iMA,  KSglb, ipCG, LCG,  idGM, IFP)
CCC_  - Description
CCC_   . VMHI
CC       input  o[HSB]a
CC       ouptut n[HSB]a ADV fr
CCC_   . VMTI
CC       input  Ta
CC       output [UVW]adv sh
CCC_   . VMI
CC       update: Ha, Sa, Ba
CC       input:  RFII[bc]  rate factor double integral
CC               TMB       total mass balance
CC               NR        next bedrock (next)
CC               VB[bc]    basal velocity
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
c
      _INTENT(IN,   integer)  MH, LH, LCG
      _INTENT(IN,   integer)  NZ, LZ, KZ0, NTH
c
      _INTENT(INOUT,_REALSTD) VMI  (LH, *)
      _INTENT(INOUT,_REALSTD) VMHI (LH, *)
      _INTENT(INOUT,_REALSTD) VMHW (LH, *)
      _INTENT(INOUT,_REALSTD) VMTI (LH, LZ, *)
c
      _INTENT(OUT,  _REALSTD) XI   (*)
      _INTENT(OUT,  _REALSTD) XS   (*)
      _INTENT(OUT,  _REALSTD) CW   (*)
      _INTENT(OUT,  _REALSTD) GW   (*)
      _INTENT(OUT,  _REALSTD) VMW  (*)
      _INTENT(OUT,  _REALSTD) VMTW (*)
c
      _INTENT(OUT,  _REALSTD) QM   (*)
      _INTENT(OUT,  _REALSTD) VMC  (LH, *)
      _INTENT(OUT,  _REALSTD) VMID (*)
c
      _INTENT(OUT,  _REALSTD) VMSC (*)
      _INTENT(OUT,  _REALSTD) VMSV (*)
      _INTENT(OUT,  _REALSTD) VMSE (*)
c
      _INTENT(IN,   logical)  OMM  (*)
      _INTENT(IN,   integer)  IMM  (*)
      _INTENT(IN,   _REALSTD) PMM  (*)
      _INTENT(IN,   _REALSTD) T, DT
c
      _INTENT(IN,   _REALSTD) VMHB (LH, *)
c
      _INTENT(IN,   _REALSTD) WW   (LH, *)
      _INTENT(IN,   _REALSTD) GG   (*),     WZV (*)
      _INTENT(IN,   integer)  IE   (*), iMA (*)
      _INTENT(IN,   integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN,   integer)  ipCG (*), KSglb (*)
      _INTENT(IN,   integer)  idGM (*)
c
      _INTENT(IN,   integer)  IFP
CCC_   . Interior
      integer  LXK
      integer  KXX
      integer  Itr,  ItrMax
      integer  ItrN
      _REALSTD Etol, EPS,   Efin, EfinN
      _REALSTD F0
      _REALSTD TI
c
      _REALSTD DENS, GRAV, PF, FG (3), WF
      integer  MSW,  MINI
      logical  OSSA
      integer  KDHDT
c
      _REALSTD DTcum, DTp
c
      integer  ITstp
      integer  jedmy
CCC_  - Body
      iErr = 0
c
      LXK  = VMSX_MAX
c
      Etol   = PMM (PMD_ETOL)
      EPS    = PMM (PMD_EPS)
      DENS   = PMM (PMD_DENS)
      GRAV   = PMM (PMD_GRAV)
      PF     = PMM (PMD_PF)
      FG (1) = PMM (PMD_FGX)
      FG (2) = PMM (PMD_FGY)
      FG (3) = PMM (PMD_FGZ)
      WF     = PMM (PMD_WF)
c
      MSW    = IMM (IMD_MSW)
      MINI   = IMM (IMD_MINI)
      ItrMax = IMM (IMD_ITRMAX)
      KDHDT  = IMM (IMD_DHDT)
c
      OSSA = OMM (OMM_WITH_SSA)
c
      DTcum  = 0.0d0
c
      ITstp   = 0
CCC_   . set old condition
      call MDstrD (iErr, VMI, VMHI, MH, LH)
CCC_   . LOOP start
      DO
         if (DTcum.ge.DT) goto 990
         TI = T + DTcum
CCC_   . preparation/topography
         if (iErr.eq.0) then
            call MDprpH
     O          (iErr,
     M           VMI,   VMC,
     W           VMW,   CW,
     I           VMHB,
     I           OMM,   IMM,  PMM,
     I           WW,    MH,   LH,
     I           ipCG,  LCG,  ipKW, iMA, IFP)
         endif
CCC_   . preparation/thermodynamics
         if (iErr.eq.0) then
            call MDprpT
     O          (iErr,
     O           VMI,   VMTI, VMTW,
     W           VMW,   CW,
     I           VMC,   VMHB,
     I           OMM,   IMM,  PMM,
     I           WW,    WZV,  GG,   NTH,
     I           MH,    LH,   NZ,   LZ,  KZ0,
     I           ipCG,  LCG,  ipKW, iMA, IFP)
         endif
CCC_   . SIA flux terms
         if (iErr.eq.0 .and. OMM (OMM_WITH_SIA)) then
            call MIBdfs
     O          (iErr,
     M           VMID,
     I           VMI,   VMC,   VMHB,
     I           DENS,  GRAV,  PF,   FG,
     I           MH,    LH)
         endif
CCC_   . basal velocity
         if (iErr.eq.0) then
            call MBSmng
     O          (iErr,
     M           VMID,
     I           VMI,   VMC,  VMHB, IMM, PMM, MH, LH)
         endif
CCC_   . SSA flux terms
         if (iErr.eq.0) then
            if (OSSA) then
               call MSNmdf
     O             (iErr,
     M              VMID, XS,    VMSC, VMSV, VMW, CW,   GW,
     I              TI,   IMM,   PMM,  VMSE, VMI, VMC,  VMHB,
     O              ItrN, EfinN, KXX,
     I              ipCG, LCG,   idGM,
     I              WW,   MH,    LH,   LXK,  IE,  ipKW, iMA, IFP)
            else
               call MGLnmv
     O             (iErr,
     M              VMID,
     M              VMSV, VMW,
     W              CW,   GW,
     I              IMM,  PMM, VMI, VMC,  VMHB,
     I              ipCG,
     I              WW,   MH,  LH,  ipKW, iMA, IFP)
            endif
         endif
CCC_   . CFL   dX/E > dt
         if (iErr.eq.0) then
            call MDdtca
     $          (DTp,   VMW,
     $           DTcum, DT, VMID, WW, IMM, ipKW, iMA, MH, LH, MSW, IFP)
         endif
CCC_   . thickness integration
         if (iErr.eq.0) then
            call MMXgen
     O          (iErr,
     O           XI,   QM,  F0,
     W           VMW,  CW,
     I           VMI,  VMC, VMHB, VMID, DTp, WF,
     I           WW,
     I           ipKW, iMA, ipCG, MH,   LH,  LCG, MSW, MINI)
         endif
         if (ItrMax.ge.0) then
            if (iErr.eq.0) then
               call MMSbuc
     O             (iErr,
     M              XI,     CW,   GW,  VMW,
     O              Itr,    Efin,
     I              ItrMax, Etol, EPS, MSW,
     I              QM,     F0,
     I              ipCG,   LCG,
     I              WW,     MH,   LH,  ipKW, KSglb, IE, iMA, IFP)
            endif
 101        format ('ITR', I2.2, ': ', I5, 1x, I5, 1x, E10.3)
            write (IFP, 101) MSW, iErr, Itr, Efin
         endif
         if (iErr.eq.0) then
            call MMScdh
     O          (iErr,
     M           XI,     CW,    VMW,
     I           MSW,
     I           QM,     F0,
     I           ipCG,   LCG,
     I           WW,     MH,    LH, ipKW, iMA, IFP)
         endif
         if (MSW.eq. MMXSW_CIPaxP
     $        .or. MSW.eq. MMXSW_CIPaxL) then
            call MMCitg
     O          (iErr,
     M           VMC,    XI,    CW,  VMW,
     I           ItrMax, MSW,
     I           QM,     F0,    DTp,
     I           ipCG,   LCG,
     I           WW,     MH,    LH, ipKW, IE, iMA, IFP)
         endif
CCC_   + set next H
         if (iErr.eq.0) then
            call MDnxtH
     $           (iErr, VMC,  XI, OMM, IMM, PMM, DTp, MH, LH, IFP)
c$$$            call UV1cpa (VMC, X, MH, LH, VMC_NHa, BCGW_XX)
         endif
CCC_   . velocity diagnosis
         if (ITstp.eq.0) then
CCC_    * update gradient
            if (iErr.eq.0) then
               call MDprpU
     O             (iErr,
     M              VMC,
     W              VMW,   CW,
     I              OMM,   IMM,  PMM,
     I              WW,    MH,   LH,
     I              ipCG,  LCG,  ipKW, iMA, IFP)
            endif
CCC_    * SIA velocity and integral
            if (iErr.eq.0) then
               call MIBvhs
     O             (iErr,
     W              VMW,
     O              VMTI,  VMTW,
     I              VMI,   VMID, VMC,  VMHB, WZV,
     I              DENS,  GRAV, PF,   FG,
     I              MH,    LH,   NZ,   LZ,   KZ0,
     I              IMM,   MSW)
            endif
CCC_    * second categorizing
            if (iErr.eq.0) then
               call MDctgs
     M             (VMC,
     I              VMI, VMHB, VMTI, PMM, IMM,
     I              MH,  LH,   NZ,   LZ,  KZ0)
            endif
CCC_    * SSA velocity and integral
            if (iErr.eq.0) then
               if (OSSA) then
                  call MSNmdv
     O                (iErr,
     W                 VMW,
     O                 VMTI,  VMTW, VMID,
     I                 VMI,   VMC,  VMHB,
     I                 VMSC,  VMSV, VMSE, XI,   WZV,
     I                 DENS,  GRAV, PF,   FG,
     I                 MH,    LH,   NZ,   LZ,   KZ0, KXX, LXK,
     I                 IMM,   MSW)
               endif
            endif
CCC_    * W preparation
            if (iErr.eq.0) then
               call MDprpW
     O             (iErr,
     M              VMC,
     W              VMW,   CW,
     I              VMHB,
     I              OMM,   IMM,  PMM,
     I              WW,    MH,   LH,
     I              ipCG,  LCG,  ipKW, iMA, IFP)
            endif
CCC_    * vertical velocity (other field for temperature update)
            if (iErr.eq.0) then
               call MMWcmp
     O             (iErr,
     M              VMHI,  VMTI,  VMTW,
     W              VMW,   CW,
     I              VMI,   VMC,   VMHB, QM,   F0,   WZV,  T, DT,
     I              IMM,   WW,
     I              MH,    LH,    NZ,   LZ,   KZ0,
     I              ipCG,  LCG,   ipKW, iMA,  IE,   IFP)
c$$$               if (IMM (IMD_WI).eq. SW_WI_SNOOPY) then
c$$$                  call MMWast
c$$$     O                (iErr,
c$$$     M                 VMHI,  VMTI,  VMTW,
c$$$     W                 VMW,   CW,
c$$$     I                 VMI,   VMC,   VMHB, WZV,  T, DT,
c$$$     I                 WW,
c$$$     I                 MH,    LH,    NZ,   LZ,   KZ0,
c$$$     I                 ipCG,  LCG,   ipKW, iMA,  IE,   IFP)
c$$$               else
c$$$                  call MMWsst
c$$$     O                (iErr,
c$$$     M                 VMHI,  VMTI,  VMTW,
c$$$     W                 VMW,   CW,
c$$$     I                 VMI,   VMC,   VMHB, WZV,  T, DT,
c$$$     I                 WW,
c$$$     I                 MH,    LH,    NZ,   LZ,   KZ0,
c$$$     I                 ipCG,  LCG,   ipKW, iMA,  IE,   IFP)
c$$$               endif
            endif
CCC_    * compute fields for temperature (i)
            if (iErr.eq.0) then
               call MTBuvs
     O             (iErr,
     M              VMTI,  VMTW, VMHI, VMHW,
     O              CW,
     I              VMID,  VMHB, PMM,  IMM,
     I              WW,    WZV,
     I              MH,    LH,   NZ,   LZ,   KZ0,
     I              ipCG,  LCG,  ipKW, iMA,  IFP)
            endif
CCC_    * end velocity computation
         endif
CCC_   . output primitive variables
         call AFBwmp (jedmy, VMI,  idGM (VGRP_VMI),  TI, IE)
         call AFBwmp (jedmy, VMTI, idGM (VGRP_VMTI), TI, IE)
c
         call AFBwmp (jedmy, VMC,  idGM (VGRP_VMC),  TI, IE)
         call AFBwmp (jedmy, VMID, idGM (VGRP_VMID), TI, IE)
         call AFBwmp (jedmy, VMHB, idGM (VGRP_VMHB), TI, IE)
         call AFBwmp (jedmy, XI,   idGM (VGRP_VMX),  TI, IE)
         call AFBwmp (jedmy, QM,   idGM (VGRP_VMQ),  TI, IE)
         call AFBwmp (jedmy, VMHI, idGM (VGRP_VMHI), TI, IE)
         call AFBwmp (jedmy, VMHW, idGM (VGRP_VMHW), TI, IE)
         call AFBwmr
     $       (jedmy,
     $        VMTW, idGM (VGRP_VMTW),
     $        1, VMTW_MAXD, TI, 'VMTWd', IE)
         call AFBwmr
     $       (jedmy,
     $        VMTW, idGM (VGRP_VMTW),
     $        VMTW_MAXD+1, VMTW_MAX, TI, 'VMTWt', IE)
CCC_   . update
CCC_    * todo correct Sa
CCC_    * todo history
         if (iErr.eq.0) then
c$$$            call UV1cpa (VMI, X, MH, LH, VMI_Ha, BCGW_XX)
            call UV1cpa (VMI, VMC, MH, LH, VMI_Ha, VMC_HE)
            call UV1cpa (VMI, VMC, MH, LH, VMI_HX, VMC_HX)
            call UV1cpa (VMI, VMC, MH, LH, VMI_HY, VMC_HY)
         else
            goto 990
         endif
CCC_   . LOOP end
         DTcum = DTcum + DTp
         ITstp = ITstp + 1
      enddo
 990  continue
CCC_   . set new field for temperature
      if (iErr.eq.0) then
         call MDfinD (iErr, VMHI,   VMHB, VMI, PMM, IMM, OSSA, MH, LH)
      endif
CCC_   . return
      call DAtrcU (IFP, iErr, 'R', 'MDSTPD')
      RETURN
      END
CCC_ & MDstpT  ## Movement/Driver integration suite (thermodynamics)
      subroutine MDstpT
     O    (iErr,
     M     VMHI, VMTI,
     W     CW,   VMHW, VMTW,
     I     KTB,
     I     VMHB, OMM,  IMM,  PMM,   T,    DT,
     I     WW,   WZV,
     I     MH,   LH,   NZ,   LZ,    KZ0,
     I     IE,   ipKW, iMA,  ipCG,  LCG,  idGM, IFPl)
CCC_  - Description
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
c
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
c
      _INTENT(INOUT,_REALSTD) VMHI (LH, *)
      _INTENT(INOUT,_REALSTD) VMHW (LH, *)
      _INTENT(INOUT,_REALSTD) VMTI (LH, LZ, *)
      _INTENT(INOUT,_REALSTD) VMTW (LH, LZ, *)
c
      _INTENT(OUT,  _REALSTD) CW   (*)
      _INTENT(OUT,  integer)  KTB  (LH, *)
c
      _INTENT(IN,   logical)  OMM  (*)
      _INTENT(IN,   integer)  IMM  (*)
      _INTENT(IN,   _REALSTD) PMM  (*)
      _INTENT(IN,   _REALSTD) T, DT
c
      _INTENT(IN,   _REALSTD) VMHB (LH, *)
c
      _INTENT(IN,   _REALSTD) WW   (LH, *)
      _INTENT(IN,   _REALSTD) WZV  (*)
      _INTENT(IN,   integer)  IE   (*), iMA (*)
      _INTENT(IN,   integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN,   integer)  LCG, ipCG (*)
      _INTENT(IN,   integer)  idGM (*)
c
      _INTENT(IN,   integer)  IFPl
CCC_   . interior
      integer NHt
CCC_  - Body
CCC_   . compute fields for temperature (ii)
      if (iErr.eq.0) then
         call MTButp
     O       (iErr,
     O        KTB,   NHt,
     M        VMTI,  VMTW, VMHI, VMHW,
     O        CW,
     I        VMHB,  PMM,  IMM,
     I        WW,    WZV,  DT,
     I        MH,    LH,   NZ,   LZ,   KZ0,
     I        ipCG,  LCG,  ipKW, iMA,  IFPl)
      endif
      if (iErr.eq.0) then
         call MTBupd
     O       (iErr,
     M        VMTI,  VMTW, VMHI, VMHW,
     I        VMHB,  PMM,  IMM,
     I        WZV,   DT,
     I        KTB,   NHt,
     I        MH,    LH,   NZ,   LZ,   KZ0,
     I        IFPl)
      endif
CCC_   . return
      call DAtrcU (IFPl, iErr, 'R', 'MDSTPT')
      RETURN
      END
CCC_* Bookends
CCC_ & MDstrD  ## Starting
      subroutine MDstrD
     O    (iErr,
     M     VMI,
     I     VMHI,
     I     MH,   LH)
CCC_  - Declaration
      implicit none
c
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  MH, LH
c
      _INTENT(INOUT,_REALSTD) VMI  (LH, *)
      _INTENT(IN,   _REALSTD) VMHI (LH, *)
CCC_  - Body
      iErr = 0
CCC_   . set starting thickness
      if (iErr.eq.0) call UV1cpa (VMI, VMHI, MH, LH, VMI_Ha, VMHI_oHa)
      if (iErr.eq.0) call UV1cpa (VMI, VMHI, MH, LH, VMI_HH, VMHI_oHa)
      if (iErr.eq.0) call UV1cpa (VMI, VMHI, MH, LH, VMI_HX, VMHI_oHXa)
      if (iErr.eq.0) call UV1cpa (VMI, VMHI, MH, LH, VMI_HY, VMHI_oHYa)
      RETURN
      END
CCC_ & MDfinD  ## Finalizing
      subroutine MDfinD
     O    (iErr,
     M     VMHI,
     I     VMHB, VMI,
     I     PMM,  IMM, OSSA,
     I     MH,   LH)
CCC_  - Declaration
      implicit none
c
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  MH, LH
c
      _INTENT(INOUT,_REALSTD) VMHI (LH, *)
      _INTENT(IN,   _REALSTD) VMI  (LH, *)
      _INTENT(IN,   _REALSTD) VMHB (LH, *)
      _INTENT(IN,   _REALSTD) PMM  (*)
      _INTENT(IN,   integer)  IMM  (*)
      _INTENT(IN,   logical)  OSSA
CCC_  - Body
      iErr = 0
CCC_   . set new thickness
      if (iErr.eq.0) call UV1cpa (VMHI, VMI, MH, LH, VMHI_nHa, VMI_Ha)
      if (iErr.eq.0) call MDadjH (VMHI, MH, LH, VMHI_nHa)
      if (iErr.eq.0) then
         call MDadjS
     $       (VMHI, VMHB, PMM, IMM, MH, LH,
     $        VMHI_nSa, VMHI_nBa, VMHI_nHa, VMHB_NRa, VMHB_SLVa, OSSA)
      endif
      RETURN
      END
CCC_* [Preparation]
CCC_ & MDprpH  ## Preparation suite
      subroutine MDprpH
     O    (iErr,
     M     VMI,   VMC,
     W     VMW,   CW,
     I     VMHB,
     I     OMM,   IMM,  PMM,
     I     WW,    MH,   LH,
     I     ipCG,  LCG,  ipKW, iMA, IFP)
CCC_  - Declaration
      implicit none
c
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  MH, LH, LCG
c
      _INTENT(INOUT,_REALSTD) VMI  (LH, *)
      _INTENT(OUT,  _REALSTD) VMW  (*)
      _INTENT(OUT,  _REALSTD) CW   (*)
      _INTENT(OUT,  _REALSTD) VMC  (LH, *)
      _INTENT(IN,   _REALSTD) VMHB (LH, *)
      _INTENT(IN,   logical)  OMM  (*)
      _INTENT(IN,   _REALSTD) PMM  (*)
      _INTENT(IN,   integer)  IMM  (*)
c
      _INTENT(IN,   _REALSTD) WW   (*)
      _INTENT(IN,   integer)  ipKW (*), iMA (*)
      _INTENT(IN,   integer)  ipCG (*)
c
      _INTENT(IN,   integer)  IFP
c
      integer j
      logical OSSA
      integer MSW
CCC_  - Body
      iErr = 0
      OSSA = OMM (OMM_WITH_SSA)
      MSW  = IMM (IMD_MSW)
CCC_   . thickness adjustment
      if (iErr.eq.0) call MDadjH (VMI, MH, LH, VMI_Ha)
      if (iErr.eq.0) call MDadjG (VMI, MH, LH, VMI_HX, VMI_Ha)
      if (iErr.eq.0) call MDadjG (VMI, MH, LH, VMI_HY, VMI_Ha)
CCC_   . topography computation when with shelf
      if (OSSA) then
         call MDclvp (VMI, VMHB, PMM, IMM, MH, LH)
CCC_    * thickness interpolation
         call MDitpH
     M       (VMI,
     W        VMW, CW,
     I        WW,  MH, LH, LCG, ipCG, ipKW, iMA)
CCC_    * surface adjustment
         call MDadjS
     $       (VMI,    VMHB,   PMM,    IMM,     MH, LH,
     $        VMI_Sa, VMI_Ba, VMI_Ha, VMHB_Ra, VMHB_SLVa, OSSA)
CCC_   . when without shelf
      else
CCC_    * surface adjustment a
         call MDadjS
     $       (VMI,    VMHB,   PMM,    IMM,     MH, LH,
     $        VMI_Sa, VMI_Ba, VMI_Ha, VMHB_Ra, VMHB_SLVa, OSSA)
CCC_    * calving where floated
         call MDfclv
     M       (VMI,
     I        VMHB,   PMM,    IMM,    MH,  LH,
     I        VMI_Sa, VMI_Ba, VMI_Ha, VMHB_Ra, VMHB_SLVa)
CCC_    * thickness interpolation
         call MDitpH
     M       (VMI,
     W        VMW, CW,
     I        WW,  MH, LH, LCG, ipCG, ipKW, iMA)
      endif
CCC_   . topography computation when using polynomial
      if (MSW.eq. MMXSW_CIPaxP
     $     .or. MSW.eq. MMXSW_CIPaxL) then
         call MMCpct
     O       (iErr,
     M        VMI,   VMC,
     W        VMW,   CW,
     I        VMHB,
     I        MSW,   OMM,   IMM,  PMM,
     I        WW,    MH,   LH,
     I        ipCG,  LCG,  ipKW, iMA, IFP)
CC test.  linear interpolate again
         if (MSW.eq. MMXSW_CIPaxL) then
            call MDitpH
     M          (VMI,
     W           VMW, CW,
     I           WW,  MH, LH, LCG, ipCG, ipKW, iMA)
         endif
      endif
CCC_   . surface adjustment bcd
      call MDadjS
     $    (VMI,    VMHB,   PMM,    IMM,     MH, LH,
     $     VMI_Sb, VMI_Bb, VMI_Hb, VMHB_Rb, VMHB_SLVb, OSSA)
      call MDadjS
     $    (VMI,    VMHB,   PMM,    IMM,     MH, LH,
     $     VMI_Sc, VMI_Bc, VMI_Hc, VMHB_Rc, VMHB_SLVc, OSSA)
      call MDadjS
     $    (VMI,    VMHB,   PMM,    IMM,     MH, LH,
     $     VMI_Sd, VMI_Bd, VMI_Hd, VMHB_Rd, VMHB_SLVd, OSSA)
CCC_   . surface/base  gradient (old field everywhere)
      if (MSW.eq. MMXSW_CIPaxP
     $     .or. MSW.eq. MMXSW_CIPaxL) then
         call MMCgrt
     O       (iErr,
     M        VMI,   VMC,
     W        VMW,   CW,
     I        VMHB,
     I        MSW,   OMM,   IMM,  PMM,
     I        WW,    MH,   LH,
     I        ipCG,  LCG,  ipKW, iMA, IFP)
CC linear diff. again
         if (MSW.eq. MMXSW_CIPaxL) then
            call MIBtgr
     O          (iErr,
     M           VMC, CW,
     I           VMI, WW,
     I           MH,  LH, ipCG, LCG, ipKW, iMA)
         endif
      else
         call MIBtgr
     O       (iErr,
     M        VMC, CW,
     I        VMI, WW,
     I        MH,  LH, ipCG, LCG, ipKW, iMA)
      endif
CCC_   . calving
      if (iErr.eq.0) then
         call MDclvs (VMC, VMI, VMHB, PMM, IMM, MH, LH)
      endif
CCC_   . category
      if (iErr.eq.0) then
         call MDctgr
     M       (VMC,
     W        VMW, CW,
     I        VMI, VMHB, PMM, IMM,
     I        WW,  MH,   LH, ipKW, iMA)
      endif
CCC_   . update next bottom gradient (partly modified with new field)
      if (iErr.eq.0) then
         call MDbngr
     M       (VMC,
     I        VMHB, PMM, IMM,
     I        MH,   LH)
      endif
CCC_   . surface gradient at calving front
      if (iErr.eq.0) then
         call MDgrdf
     O       (iErr,
     M        VMC, VMW, CW,
     I        VMI, PMM, IMM, WW, MH, LH, ipKW, iMA)
      endif
CCC_   . copy HX
      if (iErr.eq.0) then
         call UV1cpa (VMC, VMI, MH, LH, VMC_HX, VMI_HX)
         call UV1cpa (VMC, VMI, MH, LH, VMC_HY, VMI_HY)
      endif
CCC_   . shelfy stream (makeshift implementation)
c$$$#if SHELFY_STREAM
c$$$         if (iErr.eq.0) then
c$$$            do j = 1, MH
c$$$               if (VMI (j, VMI_Bb).eq.VMHB (j, VMHB_Rb)) then
c$$$                  VMI (j, VMI_SLDb) = 1.0d0
c$$$               else
c$$$                  VMI (j, VMI_SLDb) = 0.0d0
c$$$               endif
c$$$               if (VMI (j, VMI_Bc).eq.VMHB (j, VMHB_Rc)) then
c$$$                  VMI (j, VMI_SLDc) = 1.0d0
c$$$               else
c$$$                  VMI (j, VMI_SLDc) = 0.0d0
c$$$               endif
c$$$            enddo
c$$$         endif
c$$$#endif
      RETURN
      END
CCC_ & MDnxtH  ## next H set
      subroutine MDnxtH
     O    (iErr,
     M     VMC,
     I     VMX,   OMM,  IMM,  PMM,  DT,
     I     MH,    LH,   IFP)
CCC_  - Description
CC      Input
CC         VMX(BCGW_XH2) as dH/dt
CC         or VMX(BCGW_XX)  as new H
CC      Output
CC          VMC_HE; VMC_NHa; VMC_dHdtE
CCC_  - Declaration
      implicit none
c
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  MH, LH
c
      _INTENT(INOUT,_REALSTD) VMC  (LH, *)
      _INTENT(IN,   _REALSTD) VMX  (LH, *)
      _INTENT(IN,   logical)  OMM  (*)
      _INTENT(IN,   _REALSTD) PMM  (*)
      _INTENT(IN,   integer)  IMM  (*)
      _INTENT(IN,   _REALSTD) DT
c
      _INTENT(IN,   integer)  IFP
c
      integer jh
      integer KDHDT
CCC_  - Body
      iErr = 0
c
      KDHDT = IMM (IMD_DHDT)
c
      if (KDHDT.eq. SW_DHDT_FLUX) then
CCC_   . X: solution;  NHa: recomputed by flux
         do jh = 1, MH
            VMC (jh, VMC_HE)    =
     $           VMC (jh, VMC_HCa) + DT * VMX (jh, BCGW_XH2)
            VMC (jh, VMC_NHa)   = VMX (jh, BCGW_XX)
            VMC (jh, VMC_dHdtE) = VMX (jh, BCGW_XH2)
         enddo
      else
CCC_   . NHa, X: solution
         do jh = 1, MH
            VMC (jh, VMC_HE)    = VMX (jh, BCGW_XX)
            VMC (jh, VMC_NHa)   = VMX (jh, BCGW_XX)
            VMC (jh, VMC_dHdtE) =
     $           (VMX (jh, BCGW_XX) - VMC (jh, VMC_HCa)) / DT
         enddo
      endif
CCC_   . Todo
CC        Variation: use flux but compute dHdtE again
      RETURN
      END
CCC_ & MDprpU  ## Preparation for horizontal velocity field
      subroutine MDprpU
     O    (iErr,
     M     VMC,
     W     VMW,   CW,
     I     OMM,   IMM,  PMM,
     I     WW,    MH,   LH,
     I     ipCG,  LCG,  ipKW, iMA, IFP)
CCC_  - Description
CC       Update surface gradient (S[XY][bc]M) for velocity computation
CCC_  - Declaration
      implicit none
c
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  MH, LH, LCG
c
      _INTENT(OUT,  _REALSTD) VMW  (*)
      _INTENT(OUT,  _REALSTD) CW   (*)
      _INTENT(INOUT,_REALSTD) VMC  (LH, *)
      _INTENT(IN,   logical)  OMM  (*)
      _INTENT(IN,   _REALSTD) PMM  (*)
      _INTENT(IN,   integer)  IMM  (*)
c
      _INTENT(IN,   _REALSTD) WW   (*)
      _INTENT(IN,   integer)  ipKW (*), iMA (*)
      _INTENT(IN,   integer)  ipCG (*)
c
      _INTENT(IN,   integer)  IFP
CCC_  - Body
      iErr = 0
CCC_   . todo: dynamics switch
#if OPT_NHADJ_SALLY
      if (iErr.eq.0) then
         call UV1cpa (VMW, VMC, MH, LH, VMW_W1, VMC_NHa)
         call MDadjH (VMW, MH,  LH, VMW_W1)
      endif
#endif
      if (iErr.eq.0) then
         call MIBngs
     O       (iErr,
     M        VMC,    CW,  VMW,
     I        WW,
     I        VMW_W1, MH,  LH,  ipCG, LCG, ipKW,  iMA)
      endif
      RETURN
      END
CCC_ & MDprpW  ## Preparation for vertical velocity field
      subroutine MDprpW
     O    (iErr,
     M     VMC,
     W     VMW,   CW,
     I     VMHB,
     I     OMM,   IMM,  PMM,
     I     WW,    MH,   LH,
     I     ipCG,  LCG,  ipKW, iMA, IFP)
CCC_  - Description
CC        Compute Hsol:abc, bsol:abc
CCC_   . Consistent flow
CC          interpolate Hnext:bc
CC          compute bnext:abc
CC          interpolate Hsol:bc
CCC_  - Declaration
      implicit none
c
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  MH, LH, LCG
c
      _INTENT(OUT,  _REALSTD) VMW  (*)
      _INTENT(OUT,  _REALSTD) CW   (*)
      _INTENT(INOUT,_REALSTD) VMC  (LH, *)
      _INTENT(IN,   _REALSTD) VMHB (LH, *)
      _INTENT(IN,   logical)  OMM  (*)
      _INTENT(IN,   _REALSTD) PMM  (*)
      _INTENT(IN,   integer)  IMM  (*)
c
      _INTENT(IN,   _REALSTD) WW   (*)
      _INTENT(IN,   integer)  ipKW (*), iMA (*)
      _INTENT(IN,   integer)  ipCG (*)
c
      _INTENT(IN,   integer)  IFP
c
      integer j
      logical OSSA
CCC_  - Body
      iErr = 0
      OSSA = OMM (OMM_WITH_SSA)
CCC_   . first step   compute Bnext   from Hnext
CCC_    * sally compatible (reset H at this stage)
#if OPT_NHADJ_SALLY
      if (iErr.eq.0) call MDadjH (VMC, MH, LH, VMC_HE)
#endif
CCC_    * thickness interpolation
      if (iErr.eq.0) then
         call MDitpN
     M       (VMC,
     W        VMW, CW,
     I        VMC_HE, WW,  MH, LH, LCG, ipCG, ipKW, iMA)
      endif
CCC_    * compute Bnext
      if (iErr.eq.0) then
         call MDadjN
     O       (VMC,
     I        VMHB, PMM, IMM, MH, LH,
     I        VMC_NBa, VMC_HE, VMHB_NRa, VMHB_SLVa, OSSA)
         call MDadjN
     O       (VMC,
     I        VMHB, PMM, IMM, MH, LH,
     I        VMC_NBb, VMC_NHb, VMHB_NRb, VMHB_SLVb, OSSA)
         call MDadjN
     O       (VMC,
     I        VMHB, PMM, IMM, MH, LH,
     I        VMC_NBc, VMC_NHc, VMHB_NRc, VMHB_SLVc, OSSA)
      endif
CCC_   . second step  compute Hsol:bc from Hsol
#if OPT_NHADJ_SALLY
      if (iErr.eq.0) call MDadjH (VMC, MH, LH, VMC_NHa)
#endif
CCC_    * thickness interpolation
      if (iErr.eq.0) then
         call MDitpN
     M       (VMC,
     W        VMW, CW,
     I        VMC_NHa, WW,  MH, LH, LCG, ipCG, ipKW, iMA)
      endif
      RETURN
      END
CCC_ & MDadjH  ## thickness adjustment (a)
      subroutine MDadjH
     M    (VMI,
     I     MH, LH, KIH)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  MH,  LH
      _INTENT(INOUT,_REALSTD) VMI (LH, *)
      _INTENT(IN,   integer)  KIH
      integer kp
CCC_  - Body
      do kp = 1, MH
         VMI (kp, KIH) = MAX (0.0d0, VMI (kp, KIH))
      enddo
      RETURN
      END
CCC_ & MDadjG  ## thickness gradient adjustment (a)
      subroutine MDadjG
     M    (VMI,
     I     MH, LH, KIG, KIH)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  MH,  LH
      _INTENT(INOUT,_REALSTD) VMI (LH, *)
      _INTENT(IN,   integer)  KIG, KIH
      integer kp
CCC_  - Body
      do kp = 1, MH
         if (VMI(kp, KIH).le.0.0d0) VMI (kp, KIG) = 0.0d0
      enddo
      RETURN
      END
CCC_ & MDitpH  ## thickness interpolation
      subroutine MDitpH
     M    (VMI,
     W     VMW, CW,
     I     WW,  MH, LH, LCG, ipCG, ipKW, iMA)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH, LCG
c
      _INTENT(INOUT,_REALSTD) VMI (LH, *)
      _INTENT(OUT,  _REALSTD) VMW (LH, *)
      _INTENT(OUT,  _REALSTD) CW  (*)
c
      _INTENT(IN,   _REALSTD) WW  (*)
      _INTENT(IN,   integer)  ipCG (LCG, *)
      _INTENT(IN,   integer)  ipKW (*), iMA (*)
c
      integer  kp
CCC_  - Body
CCC_   . H:a operation (interpolation H:b H:c)
      call AKCgux
     O    (CW,
     I     VMI,  MH,    LH,  VMI_Ha,
     I     iMA,  ipCG (1, CGB_Ha))
c
      call AKGwax
     M    (VMI,
     I     CW,   WW,
     I     MH,   LH,  VMI_Hb, VMI_Ha,
     I     ipKW, 1,   ipCG (1, CGB_Ha))
      call AKGwax
     M    (VMI,
     I     CW,   WW,
     I     MH,   LH,  VMI_Hc, VMI_Ha,
     I     ipKW, 2,   ipCG (1, CGB_Ha))
CCC_   . H:d creation
CCC_    * interpolation b:d c:d
      call AKBwaz
     O    (VMW (1, VMIW_W1), CW,
     I     VMI (1, VMI_Hb),  WW,
     I     MH,  LH,   ipKW, iMA, KWO_Lbd, KWM_M)
      call AKBwaz
     O    (VMW (1, VMIW_W2), CW,
     I     VMI (1, VMI_Hc),  WW,
     I     MH,  LH,   ipKW, iMA, KWO_Lcd, KWM_M)
c$$$      call UV0d2a (VMW, MH, LH, VMIW_W1, VMIW_W2, 'HH', 0, 99)
      do kp = 1, MH
         VMI (kp, VMI_Hd)
     $        = (VMW (kp, VMIW_W1) + VMW (kp, VMIW_W2)) * 0.5d0
      enddo
      RETURN
      END
CCC_ & MDitpN  ## thickness interpolation (for new field)
      subroutine MDitpN
     M    (VMC,
     W     VMW, CW,
     I     KCH, WW,  MH, LH, LCG, ipCG, ipKW, iMA)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH, LCG
c
      _INTENT(INOUT,_REALSTD) VMC (LH, *)
      _INTENT(OUT,  _REALSTD) VMW (LH, *)
      _INTENT(OUT,  _REALSTD) CW  (*)
c
      _INTENT(IN,   integer)  KCH
      _INTENT(IN,   _REALSTD) WW  (*)
      _INTENT(IN,   integer)  ipCG (LCG, *)
      _INTENT(IN,   integer)  ipKW (*), iMA (*)
c
      integer  kp
CCC_  - Body
CCC_   . H:a operation (interpolation H:b H:c)
      call AKCgux
     O    (CW,
     I     VMC,  MH,    LH,  KCH,
     I     iMA,  ipCG (1, CGB_Ha))
c
      call AKGwax
     M    (VMC,
     I     CW,   WW,
     I     MH,   LH,  VMC_NHb, KCH,
     I     ipKW, 1,   ipCG (1, CGB_Ha))
      call AKGwax
     M    (VMC,
     I     CW,   WW,
     I     MH,   LH,  VMC_NHc, KCH,
     I     ipKW, 2,   ipCG (1, CGB_Ha))
      RETURN
      END
CCC_ & MDadjS  ## Surface/Base adjustment
      subroutine MDadjS
     M    (VMI,
     I     VMHB, PMM,  IMM,  MH,  LH,
     I     KIS,  KIB,  KIH,  KBR, KBSLV, OSSA)
CCC_  - Description
CC     Output: S, B
CC     Inputs: H, R, SLV
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  MH,  LH
      _INTENT(INOUT,_REALSTD) VMI  (LH, *)
      _INTENT(IN,   _REALSTD) VMHB (LH, *)
      _INTENT(IN,   _REALSTD) PMM  (*)
      _INTENT(IN,   integer)  IMM  (*)
      _INTENT(IN,   logical)  OSSA
      _INTENT(IN,   integer)  KIS, KIB, KIH
      _INTENT(IN,   integer)  KBR, KBSLV
c
      integer jp
      _REALSTD DENS, DENSW
      _REALSTD TB,  TR
CCC_  - Body
CCC_   . floating condition
      if (OSSA) then
         DENS   = PMM (PMD_DENS)
         DENSW  = PMM (PMD_DENSW)
         TR     = DENS / DENSW
         do jp = 1, MH
            TB = VMHB(jp, KBSLV) - TR * VMI (jp, KIH)
            VMI (jp, KIB) = MAX (TB, VMHB (jp, KBR))
            VMI (jp, KIS) = VMI (jp, KIH) + VMI (jp, KIB)
         enddo
CCC_   . No shelf case
      else
         do jp = 1, MH
            VMI (jp, KIS) = VMI (jp, KIH) + VMHB (jp, KBR)
            VMI (jp, KIB) = VMHB (jp, KBR)
         enddo
      endif
      RETURN
      END
CCC_ & MDadjN  ## Surface/Base adjustment (for new field)
      subroutine MDadjN
     M    (VMC,
     I     VMHB, PMM,  IMM,  MH,    LH,
     I     KCNB, KCNH, KBNR, KBSLV, OSSA)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  MH,  LH
      _INTENT(INOUT,_REALSTD) VMC  (LH, *)
      _INTENT(IN,   _REALSTD) VMHB (LH, *)
      _INTENT(IN,   _REALSTD) PMM  (*)
      _INTENT(IN,   integer)  IMM  (*)
      _INTENT(IN,   logical)  OSSA
      _INTENT(IN,   integer)  KCNB, KCNH
      _INTENT(IN,   integer)  KBNR, KBSLV
c
      integer  jp
      _REALSTD DENS, DENSW
      _REALSTD TB,  TR
CCC_  - Body
CCC_   . floating condition
      if (OSSA) then
         DENS   = PMM (PMD_DENS)
         DENSW  = PMM (PMD_DENSW)
         TR     = DENS / DENSW
         do jp = 1, MH
            TB = VMHB (jp, KBSLV) - TR * MAX (0.0d0, VMC (jp, KCNH))
            VMC (jp, KCNB) = MAX (TB, VMHB (jp, KBNR))
         enddo
CCC_   . No shelf case
      else
         do jp = 1, MH
            VMC (jp, KCNB) = VMHB (jp, KBNR)
         enddo
      endif
      RETURN
      END
CCC_ & MDfclv  ## calving when floated
      subroutine MDfclv
     M    (VMI,
     I     VMHB, PMM,  IMM,  MH,  LH,
     I     KIS,  KIB,  KIH,  KBR, KBSLV)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  MH,  LH
      _INTENT(INOUT,_REALSTD) VMI  (LH, *)
      _INTENT(IN,   _REALSTD) VMHB (LH, *)
      _INTENT(IN,   _REALSTD) PMM  (*)
      _INTENT(IN,   integer)  IMM  (*)
      _INTENT(IN,   integer)  KIS, KIB, KIH
      _INTENT(IN,   integer)  KBR, KBSLV
c
      integer jp
      _REALSTD DENS, DENSW
      _REALSTD TB,   TR
CCC_  - Body
      DENS   = PMM (PMD_DENS)
      DENSW  = PMM (PMD_DENSW)
      TR     = DENS / DENSW
CCC_   . floating condition
      do jp = 1, MH
         TB = VMHB (jp, KBSLV) - TR * VMI (jp, KIH)
         if (TB.gt.VMHB (jp, KBR)) VMI (jp, KIH) = 0.0d0
c$$$         write (*, *) jp, TB, VMHB (jp, KBR)
      enddo
      RETURN
      END
CCC_ & MDclvp  ## calving and category (a, preprocess)
      subroutine MDclvp
     M    (VMI,
     I     VMHB, PMM, IMM, MH, LH)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH
      _INTENT(INOUT,_REALSTD) VMI  (LH, *)
      _INTENT(IN,   _REALSTD) VMHB (LH, *)
      _INTENT(IN,   _REALSTD) PMM  (*)
      _INTENT(IN,   integer)  IMM  (*)
      _REALSTD CLV
      integer  jp
CCC_  - Body
      CLV    = PMM (PMD_CLV)
      do jp = 1, MH
         if (VMI (jp, VMI_Ba) .gt. VMHB (jp, VMHB_Ra)) then
            if (VMI (jp, VMI_Ha) .lt. CLV) then
               VMI (jp, VMI_Ha) = 0.0d0
            endif
         endif
      enddo
c
      RETURN
      END
CCC_ & MDclvs  ## calving and category (a)
      subroutine MDclvs
     M    (VMC,
     I     VMI, VMHB, PMM, IMM, MH, LH)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH
      _INTENT(INOUT,_REALSTD) VMC  (LH, *)
      _INTENT(IN,   _REALSTD) VMI  (LH, *)
      _INTENT(IN,   _REALSTD) VMHB (LH, *)
      _INTENT(IN,   _REALSTD) PMM  (*)
      _INTENT(IN,   integer)  IMM  (*)
      _REALSTD CLV
      _REALSTD TSH, SHH, DRSH
      integer  jp
CCC_  - Body
      if (IMM (IMD_SHSW).eq. SW_SHELFY_ALL) then
         TSH = _dSH
      else
         TSH = _dGR
      endif
      call UV1cpa (VMC, VMI, MH, LH, VMC_HCa, VMI_Ha)
c
      CLV    = PMM (PMD_CLV)
      do jp = 1, MH
         if (VMI (jp, VMI_Ba) .gt. VMHB (jp, VMHB_Ra)) then
            if (VMI (jp, VMI_Ha) .lt. CLV) then
               VMC (jp, VMC_HCa) = 0.0d0
            else
               VMC (jp, VMC_HCa) = VMI (jp, VMI_Ha)
            endif
         else
            VMC (jp, VMC_HCa) = VMI (jp, VMI_Ha)
         endif
      enddo
c
      SHH    = PMM (PMD_SHH)
      DRSH   = PMM (PMD_DRSH)
      do jp = 1, MH
         if (VMC (jp, VMC_HCa) .gt. 0.0d0) then
            if (VMI (jp, VMI_Ba) .gt. VMHB (jp, VMHB_Ra)) then
               VMC (jp, VMC_IKa) = _dSH
            else if (VMI (jp, VMI_Ha) .lt. SHH) then
               VMC (jp, VMC_IKa) = _dGR
            else if (VMI(jp, VMI_Ba).lt.VMHB(jp, VMHB_SLVa)+DRSH) then
               VMC (jp, VMC_IKa) = TSH
            else
               VMC (jp, VMC_IKa) = _dGR
            endif
         else
            if (VMHB (jp, VMHB_Ra) .ge. VMHB (jp, VMHB_SLVa)) then
               VMC (jp, VMC_IKa) = _dBR
            else
               VMC (jp, VMC_IKa) = _dOC
            endif
         endif
      enddo
      RETURN
      END
CCC_ & MDctgr  ## category bcd
      subroutine MDctgr
     M    (VMC,
     W     VMW, CW,
     I     VMI, VMHB, PMM, IMM,
     I     WW,  MH,   LH, ipKW, iMA)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH
c
      _INTENT(INOUT,_REALSTD) VMC  (LH, *)
      _INTENT(OUT,  _REALSTD) VMW  (LH, *)
      _INTENT(OUT,  _REALSTD) CW   (*)
c
      _INTENT(IN,   _REALSTD) VMI  (LH, *)
      _INTENT(IN,   _REALSTD) VMHB (LH, *)
      _INTENT(IN,   integer)  IMM  (*)
      _INTENT(IN,   _REALSTD) PMM  (*)
c
      _INTENT(IN,   _REALSTD) WW   (*)
      _INTENT(IN,   integer)  ipKW (*), iMA (*)
c
      integer  jedmy
CCC_  - Body
      call MDictg
     $    (VMC,     VMI,    VMHB,   PMM, IMM, MH, LH,
     $     VMC_IKb, VMI_Hb, VMI_Bb, VMHB_Rb,  VMHB_SLVb)
      call MDictg
     $    (VMC,     VMI,    VMHB,   PMM, IMM, MH, LH,
     $     VMC_IKc, VMI_Hc, VMI_Bc, VMHB_Rc,  VMHB_SLVc)
      call MDictg
     $    (VMC,     VMI,    VMHB,   PMM, IMM, MH, LH,
     $     VMC_IKd, VMI_Hd, VMI_Bd, VMHB_Rd,  VMHB_SLVd)
c
      call MSSgca
     O    (jedmy,
     M     VMC,  VMW,  CW,
     I     WW,   ipKW, iMA, MH, LH)
c
      RETURN
      END
CCC_ & MDictg  ## category using VMI
      subroutine MDictg
     M    (VMC,
     I     VMI, VMHB, PMM, IMM,
     I     MH,  LH,
     I     KIK, KIH,  KIB, KBR, KBSLV)
      implicit none
      _INTENT(IN,   integer)  MH, LH
      _INTENT(INOUT,_REALSTD) VMC  (LH, *)
      _INTENT(IN,   _REALSTD) VMI  (LH, *)
      _INTENT(IN,   _REALSTD) VMHB (LH, *)
      _INTENT(IN,   _REALSTD) PMM  (*)
      _INTENT(IN,   integer)  IMM  (*)
      _INTENT(IN,   integer)  KIK, KIH, KIB
      _INTENT(IN,   integer)  KBR, KBSLV
      _REALSTD TSH, SHH, DRSH
      integer  jp
c
      if (IMM (IMD_SHSW).eq. SW_SHELFY_ALL) then
         TSH = _dSH
      else
         TSH = _dGR
      endif
c
      SHH    = PMM (PMD_SHH)
      DRSH   = PMM (PMD_DRSH)
      do jp = 1, MH
         if (VMI (jp, KIH) .gt. 0.0d0) then
            if (VMI (jp, KIB) .gt. VMHB (jp, KBR)) then
               VMC (jp, KIK) = _dSH
            else if (VMI (jp, KIH) .lt. SHH) then
               VMC (jp, KIK) = _dGR
            else if (VMI(jp,KIB).lt.VMHB(jp,KBSLV)+DRSH) then
               VMC (jp, KIK) = TSH
            else
               VMC (jp, KIK) = _dGR
            endif
         else
            if (VMHB (jp, KBR) .ge. VMHB (jp, KBSLV)) then
               VMC (jp, KIK) = _dBR
            else
               VMC (jp, KIK) = _dOC
            endif
         endif
      enddo
      RETURN
      END
CCC_ & MDctgs  ## category bcd (use slip ratio)
      subroutine MDctgs
     M    (VMC,
     I     VMI, VMHB, VMTI, PMM, IMM,
     I     MH,  LH,   NZ,   LZ,  KZ0)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
c
      _INTENT(INOUT,_REALSTD) VMC  (LH, *)
c
      _INTENT(IN,   _REALSTD) VMI  (LH, *)
      _INTENT(IN,   _REALSTD) VMHB (LH, *)
      _INTENT(IN,   _REALSTD) VMTI (LH, LZ, *)
      _INTENT(IN,   integer)  IMM  (*)
      _INTENT(IN,   _REALSTD) PMM  (*)
CCC_  - Body
      call MDsctg
     $    (VMC,     VMI,    VMHB,    VMTI, PMM, IMM,
     $     MH, LH,  NZ, LZ, KZ0,
     $     VMC_IKb, VMI_Bb, VMHB_Rb, VMTI_UHb)
      call MDsctg
     $    (VMC,     VMI,    VMHB,    VMTI, PMM, IMM,
     $     MH, LH,  NZ, LZ, KZ0,
     $     VMC_IKc, VMI_Bc, VMHB_Rc, VMTI_VHc)
c
      RETURN
      END
CCC_ & MDsctg  ## category using slip ratio
      subroutine MDsctg
     M    (VMC,
     I     VMI,  VMHB, VMTI, PMM, IMM,
     I     MH,   LH,   NZ,   LZ,  KZ0,
     I     KCK,  KIB,  KBR,  KTV)
      implicit none
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
      _INTENT(INOUT,_REALSTD) VMC  (LH, *)
      _INTENT(IN,   _REALSTD) VMI  (LH, *)
      _INTENT(IN,   _REALSTD) VMHB (LH, *)
      _INTENT(IN,   _REALSTD) VMTI (LH, LZ, *)
      _INTENT(IN,   _REALSTD) PMM  (*)
      _INTENT(IN,   integer)  IMM  (*)
      _INTENT(IN,   integer)  KCK, KTV, KIB, KBR
      _REALSTD RVSH
      _REALSTD R, VS, VB
      integer  jp
c
      RVSH   = PMM (PMD_RVSH)
      do jp = 1, MH
         if (VMC(jp, KCK) .eq. _dSH
     $        .and. VMI(jp, KIB).le.VMHB(jp, KBR)) then
            VB = VMTI(jp, KZ0, KTV)
            VS = VMTI(jp, KZ0 + NZ - 1, KTV) + VB
            if (VS.ne.0.0d0) then
               R  = ABS(VB / VS)
               if (R.lt.RVSH) VMC(jp,KCK) = _dGR
            endif
         endif
      enddo
      RETURN
      END
CCC_ & MDbngr  ## bottom gradient at next step
      subroutine MDbngr
     M    (VMC,
     I     VMHB, PMM, IMM,
     I     MH,   LH)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH
c
      _INTENT(INOUT,_REALSTD) VMC  (LH, *)
      _INTENT(IN,   _REALSTD) VMHB (LH, *)
      _INTENT(IN,   integer)  IMM  (*)
      _INTENT(IN,   _REALSTD) PMM  (*)
c
      integer  jp
CCC_  - Todo
CC      may be better to use condition whether D equal zero or not
CC         D zero;     shelf
CC         D zero;     not shelf
CC         D nonzero;  shelf
CC         D nonzero;  not shelf    new dR/dx
CCC_  - Body
      do jp = 1, MH
         if (VMC (jp, VMC_IKb).ne. _dSH) then
            VMC (jp, VMC_BXbM) = VMHB (jp, VMHB_NRXb)
         endif
      enddo
      do jp = 1, MH
         if (VMC (jp, VMC_IKc).ne. _dSH) then
            VMC (jp, VMC_BYcM) = VMHB (jp, VMHB_NRYc)
         endif
      enddo
      RETURN
      END
CCC_ & MDgrdf  ## surface gradient at calving front
      subroutine MDgrdf
     O    (iErr,
     M     VMC,
     W     VMW, CW,
     I     VMI, PMM, IMM,
     I     WW,  MH,  LH, ipKW, iMA)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  MH, LH
c
      _INTENT(INOUT,_REALSTD) VMC (LH, *)
      _INTENT(OUT,  _REALSTD) CW  (LH, *)
      _INTENT(OUT,  _REALSTD) VMW (LH, *)
c
      _INTENT(IN,   _REALSTD) VMI (LH, *)
      _INTENT(IN,   _REALSTD) WW  (*)
      _INTENT(IN,   _REALSTD) PMM (*)
      _INTENT(IN,   integer)  IMM (*)
      _INTENT(IN,   integer)  ipKW (*), iMA (*)
c
      integer KDSFR, KDSSE
CCC_  - Body
      iErr = 0
      KDSFR = IMM (IMD_DSFR)
      KDSSE = IMM (IMD_DSSE)
      if (iErr.eq.0) then
         call MSUmgr
     O       (iErr,
     M        VMC,      CW,       VMW,
     I        VMI,
     I        VMC_DSXb, VMC_IKb,  VMC_IKa, VMI_Sb,
     I        KWO_FCab, KWO_FCba, KWO_GXba,
     I        KDSFR,    KDSSE,
     I        WW,       ipKW,     iMA,     MH, LH)
      endif
      if (iErr.eq.0) then
         call MSUmgr
     O       (iErr,
     M        VMC,      CW,       VMW,
     I        VMI,
     I        VMC_DSYc, VMC_IKc,  VMC_IKa, VMI_Sc,
     I        KWO_FCac, KWO_FCca, KWO_GYca,
     I        KDSFR,    KDSSE,
     I        WW,       ipKW,     iMA,     MH, LH)
      endif
#if 0 /* to save */
      if (IMM (IMD_DSFR) .eq. SW_DSFR_ZERO) then
         if (iErr.eq.0) then
            call MSUfgr
     O          (iErr,
     M           VMC,      CW,      VMW,
     I           VMC_DSXb, VMC_IKb, VMC_IKa, KWO_FCab,
     I           WW,       ipKW,    iMA,     MH, LH)
         endif
         if (iErr.eq.0) then
            call MSUfgr
     O          (iErr,
     M           VMC,      CW,      VMW,
     I           VMC_DSYc, VMC_IKc, VMC_IKa, KWO_FCac,
     I           WW,       ipKW,    iMA,     MH, LH)
         endif
      endif
#endif
      RETURN
      END
CCC_ & MDprpT  ## Preparation (temperature dependent)
      subroutine MDprpT
     O    (iErr,
     O     VMI,   VMTI, VMTW,
     W     VMW,   CW,
     I     VMC,   VMHB,
     I     OMM,   IMM,  PMM,
     I     WW,    WZV,  GG,   NTH,
     I     MH,    LH,   NZ,   LZ,  KZ0,
     I     ipCG,  LCG,  ipKW, iMA, IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
c
      _INTENT(IN,   integer)  MH, LH, LCG
      _INTENT(IN,   integer)  NZ, LZ, KZ0, NTH
c
      _INTENT(INOUT,_REALSTD) VMI  (LH, *)
      _INTENT(INOUT,_REALSTD) VMTI (LH, LZ, *)
      _INTENT(INOUT,_REALSTD) VMTW (LH, LZ, *)
      _INTENT(IN,   _REALSTD) VMC  (LH, *)
      _INTENT(IN,   _REALSTD) VMHB (LH, *)
c
      _INTENT(OUT,  _REALSTD) CW   (*)
      _INTENT(OUT,  _REALSTD) VMW  (LH, *)
c
      _INTENT(IN,   logical)  OMM  (*)
      _INTENT(IN,   integer)  IMM  (*)
      _INTENT(IN,   _REALSTD) PMM  (*)
c
      _INTENT(IN,   _REALSTD) WW   (LH, *)
      _INTENT(IN,   _REALSTD) GG   (*)
      _INTENT(IN,   _REALSTD) WZV  (LZ, *)
      _INTENT(IN,   integer)  iMA  (*)
      _INTENT(IN,   integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN,   integer)  ipCG (LCG, *)
c
      _INTENT(IN,   integer)  IFPl
c
      _REALSTD PF
      _REALSTD T0, CC
      integer  jh,   jz
      integer  KTC,  KTN
      logical  OWRF, OSSA
CCC_   . Body
      iErr = 0
      OWRF = OMM (OMM_WITH_RUPD)
      OSSA = OMM (OMM_WITH_SSA)
      T0   = PMM (PMT_T0)
      CC   = PMM (PMT_CLCLD)
CCC_   . enhancement factor
      call MDprpE
     O    (iErr,
     O     VMTI,  VMTW,
     W     VMW,   CW,
     I     VMC,   OMM,  IMM,  PMM,
     I     MH,    LH,   NZ,   LZ,  KZ0,
     I     ipCG,  LCG,  ipKW, iMA, IFPl)
CCC_   . T clone
      call AKCguw
     O    (CW,
     I     VMTI,  MH,   LH,  NZ, LZ, KZ0, VMTI_T,
     I     iMA,   ipCG (1, CGT_Ta))
CCC_   . T derivative (for temperature integration)
      call AKGwaw
     M    (VMTI,
     I     CW,   WW,
     I     MH,   LH,   NZ,   LZ,  KZ0, VMTI_dTdXb, VMTI_T,
     I     ipKW, CGT_Ta_GXab, ipCG(1, CGT_Ta))
      call AKGwaw
     M    (VMTI,
     I     CW,   WW,
     I     MH,   LH,   NZ,   LZ,  KZ0, VMTI_dTdYc, VMTI_T,
     I     ipKW, CGT_Ta_GYac, ipCG(1, CGT_Ta))
CCC_   . Interpolation bc
      if (OWRF) then
CC       T:ba (W3x)
         call AKGway
     M       (VMTW (1,1,VMTW_W3x),
     I        CW,   VMTI (1,1,VMTI_T), WW,
     I        MH,   LH,   NZ,   LZ,  KZ0,
     I        ipKW, CGT_Ta_Lab, ipCG(1, CGT_Ta))
CC       T:ca (W3y)
         call AKGway
     M       (VMTW (1,1,VMTW_W3y),
     I        CW,   VMTI (1,1,VMTI_T), WW,
     I        MH,   LH,   NZ,   LZ,  KZ0,
     I        ipKW, CGT_Ta_Lac, ipCG(1, CGT_Ta))
CCC_   . SSA preparation
         if (OSSA) then
            PF = PMM(PMD_PF)
CC       Associate rate factor:da
CC           product:   Bav
CC           temporary: T Tc A B
CC       T:da (temporary to ARFd)
            call AKBwaw
     O          (VMTW, CW,
     I           WW,
     I           MH,   LH,  NZ, LZ,  KZ0,   VMTW_W1, VMTW_W3x,
     I           ipKW, iMA, KWO_Lbd, KWM_M)
            call AKBwaw
     O          (VMTW, CW,
     I           WW,
     I           MH,   LH,  NZ, LZ,  KZ0,   VMTW_W2, VMTW_W3y,
     I           ipKW, iMA, KWO_Lcd, KWM_M)
            do jz = KZ0, KZ0 + NZ -1
               do jh = 1, MH
                  VMTW(jh,jz,VMTW_ARFd) = 0.5d0
     $                 * (VMTW(jh,jz,VMTW_W1) + VMTW(jh,jz,VMTW_W2))
               enddo
            enddo
CCC_    * for safety
            do jz = KZ0, KZ0 + NZ -1
               do jh = 1, LH
                  if (VMTW(jh,jz,VMTW_ARFd).lt.10.0d0) then
                     VMTW(jh,jz,VMTW_ARFd) = T0
                  endif
               enddo
            enddo
c$$$            call UV0d1a
c$$$     I          (VMTW(1,KZ0,VMTW_ARFd),
c$$$     I           LH, LH, 1, 'TD', 0, IFPl)
CC       Tc:da (to W1)
            call MPPtcc
     O          (VMTW(1, 1, VMTW_W1),
     I           VMTW(1, 1, VMTW_ARFd),
     I           VMI (1, VMI_Hd),  WZV (1, VMVZ_cZa),
     I           PMM,  MH, LH, NZ, LZ, KZ0)
CC       ARFd
            call MPRfaC
     O          (VMTW(1,1,VMTW_ARFd),
     I           VMTW(1,1,VMTW_W1), IMM, PMM, MH, LH, NZ, LZ, KZ0)
c$$$            call UV0d1a
c$$$     I          (VMTW(1,KZ0,VMTW_ARFd),
c$$$     I           LH, LH, 1, 'RD', 0, IFPl)
c$$$            call UV0d1a
c$$$     I          (VMTW(1,KZ0,VMTW_EFd),
c$$$     I           LH, LH, 1, 'ED', 0, IFPl)
            do jz = KZ0, KZ0 + NZ -1
               do jh = 1, MH
                  VMTW(jh,jz,VMTW_ARFd) =
     $                 (VMTW(jh,jz,VMTW_EFd) * VMTW(jh,jz,VMTW_ARFd))
     $                 ** (-1.0d0/PF)
               enddo
            enddo
c$$$            call UV0d1a
c$$$     I          (VMTW(1,KZ0,VMTW_ARFd),
c$$$     I           LH, LH, 1, 'AD', 0, IFPl)
CC       depth average
            call MTFeda
     O          (VMI(1,VMI_daBAd),
     I           VMTW(1,1,VMTW_ARFd), WZV (1,VMVZ_dZb),
     I           MH, LH, NZ, LZ, KZ0)
CC       Associate rate factor:aa
CC           product:   EAav B Bav
CC           temporary: T Tc A EA
CC       TC:aa
CC       RF:aa
CC       daRF
CC       ARF
CC       daBA
CC       Tc:aa (to W1)
            call MPPtcc
     O          (VMTW(1, 1, VMTW_W1),
     I           VMTI(1, 1, VMTI_T),
     I           VMI (1, VMI_Ha),  WZV (1, VMVZ_cZa),
     I           PMM,  MH, LH, NZ, LZ, KZ0)
CC       RF
            call MPRfaC
     O          (VMTW(1,1,VMTW_ARFa),
     I           VMTW(1,1,VMTW_W1), IMM, PMM, MH, LH, NZ, LZ, KZ0)
            do jz = KZ0, KZ0 + NZ -1
               do jh = 1, MH
                  VMTW(jh,jz,VMTW_ARFa) =
     $                 (VMTI(jh,jz,VMTI_EF) * VMTW(jh,jz,VMTW_ARFa))
               enddo
            enddo
CC       RF avr
            call MTFeda
     O          (VMI(1,VMI_daRFa),
     I           VMTW(1,1,VMTW_ARFa), WZV (1,VMVZ_dZb),
     I           MH, LH, NZ, LZ, KZ0)
CC       ARF
            do jz = KZ0, KZ0 + NZ -1
               do jh = 1, MH
                  VMTW(jh,jz,VMTW_ARFa) =
     $                 VMTW(jh,jz,VMTW_ARFa) ** (-1.0d0/PF)
               enddo
            enddo
CC       depth average
            call MTFeda
     O          (VMI(1,VMI_daBAa),
     I           VMTW(1,1,VMTW_ARFa), WZV (1,VMVZ_dZb),
     I           MH, LH, NZ, LZ, KZ0)
         endif
      endif
CCC_   . SIA preparation
      call MDprpV
     O    (iErr,
     O     VMI,   VMTW,
     I     OMM,   IMM,  PMM,
     I     WW,    WZV,  GG,   NTH,
     I     MH,    LH,   NZ,   LZ,  KZ0,
     I     VMI_Hb,      VMI_RFIIb,
     I     VMTW_W3x,
     I     VMTW_EFb,    VMTW_RFb,    VMTW_RFIb,  VMTW_RFIIb,
     I     IFPl)
      call MDprpV
     O    (iErr,
     O     VMI,   VMTW,
     I     OMM,   IMM,  PMM,
     I     WW,    WZV,  GG,   NTH,
     I     MH,    LH,   NZ,   LZ,  KZ0,
     I     VMI_Hc,      VMI_RFIIc,
     I     VMTW_W3y,
     I     VMTW_EFc,    VMTW_RFc,    VMTW_RFIc,  VMTW_RFIIc,
     I     IFPl)
CCC_   . TCR clone
      KTC = 1
      KTN = 2
      do jh = 1, MH
         VMW (jh, KTC) = VMTI (jh, KZ0, VMTI_T)
      enddo
      call MPPptc
     M    (VMW,
     I     VMI,  WZV (KZ0, VMVZ_cZa),
     I     T0,   CC,
     I     KTC,  KTC, VMI_Ha, MH, LH, 1, 1, 1)
      call AKCgux
     O    (CW,
     I     VMW,  MH,   LH,  KTC,
     I     iMA,  ipCG (1, CGT_CTB))
      call MDbsld
     O    (iErr,
     O     VMI,
     W     VMW,
     I     VMHB,
     I     CW,    OMM,   IMM,  PMM,
     I     MH,    LH,
     I     VMI_SLDb,     VMI_Bb,
     I     KTC,   KTN,   VMHB_Rb,
     I     CGT_CTB_FCab,
     I     ipCG (1, CGT_CTB),   ipKW, iMA, IFPl)
      call MDbsld
     O    (iErr,
     O     VMI,
     W     VMW,
     I     VMHB,
     I     CW,    OMM,   IMM,  PMM,
     I     MH,    LH,
     I     VMI_SLDc,   VMI_Bc,
     I     KTC,   KTN, VMHB_Rc,
     I     CGT_CTB_FCac,
     I     ipCG (1, CGT_CTB),   ipKW, iMA, IFPl)
      RETURN
      END
CCC_ & MDprpE  ## Preparation sub (enhancement factor) simple
      subroutine MDprpE
     O    (iErr,
     O     VMTI,  VMTW,
     W     VMW,   CW,
     I     VMC,   OMM,  IMM,  PMM,
     I     MH,    LH,   NZ,   LZ,  KZ0,
     I     ipCG,  LCG,  ipKW, iMA, IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
c
      _INTENT(IN,   integer)  MH, LH, LCG
      _INTENT(IN,   integer)  NZ, LZ, KZ0
c
      _INTENT(INOUT,_REALSTD) VMTI (LH, LZ, *)
      _INTENT(INOUT,_REALSTD) VMTW (LH, LZ, *)
      _INTENT(IN,   _REALSTD) VMC  (LH, *)
c
      _INTENT(OUT,  _REALSTD) CW   (*)
      _INTENT(OUT,  _REALSTD) VMW  (LH, *)
c
      _INTENT(IN,   logical)  OMM  (*)
      _INTENT(IN,   integer)  IMM  (*)
      _INTENT(IN,   _REALSTD) PMM  (*)
c
      _INTENT(IN,   integer)  iMA  (*)
      _INTENT(IN,   integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN,   integer)  ipCG (LCG, *)
c
      _INTENT(IN,   integer)  IFPl
c
      iErr = 0
c
      call MPEctc
     O    (VMTI(1,1,VMTI_EF),
     I     VMC(1,VMC_IKa), PMM, MH,   LH,  NZ, LZ,  KZ0)
      call MPEctc
     O    (VMTW(1,1,VMTW_EFb),
     I     VMC(1,VMC_IKb), PMM, MH,   LH,  NZ, LZ,  KZ0)
      call MPEctc
     O    (VMTW(1,1,VMTW_EFc),
     I     VMC(1,VMC_IKc), PMM, MH,   LH,  NZ, LZ,  KZ0)
      call MPEctc
     O    (VMTW(1,1,VMTW_EFd),
     I     VMC(1,VMC_IKd), PMM, MH,   LH,  NZ, LZ,  KZ0)
c
      RETURN
      END
CCC_ & MDprpV  ## Preparation sub (temperature dependent)
      subroutine MDprpV
     O    (iErr,
     O     VMI,   VMTW,
     I     OMM,   IMM,   PMM,
     I     WW,    WZV,   GG,   NTH,
     I     MH,    LH,    NZ,   LZ,    KZ0,
     I     KIH,   KIRFW,
     I     KWT,   KWEF,  KWRF, KWRFI, KWRFII,
     I     IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
c
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0, NTH
c
      _INTENT(INOUT,_REALSTD) VMI  (LH, *)
      _INTENT(INOUT,_REALSTD) VMTW (LH, LZ, *)
c
      _INTENT(IN,   logical)  OMM  (*)
      _INTENT(IN,   integer)  IMM  (*)
      _INTENT(IN,   _REALSTD) PMM  (*)
c
      _INTENT(IN,   _REALSTD) WW   (LH, *)
      _INTENT(IN,   _REALSTD) GG   (*)
      _INTENT(IN,   _REALSTD) WZV  (LZ, *)
c
      _INTENT(IN,   integer)  KIH,   KIRFW
      _INTENT(IN,   integer)  KWT
      _INTENT(IN,   integer)  KWEF
      _INTENT(IN,   integer)  KWRF, KWRFI, KWRFII
c
      _INTENT(IN,   integer)  IFPl
c
      _REALSTD  T0,   CC
      _REALSTD  Rgas, TM, QL, AL, QH, AH
      _REALSTD  PF
      logical   OWRF
      integer   jz, jh
CCC_  - Body
      iErr = 0
CC    Todo: Odd
CCC_   . Rate factor update
      OWRF = OMM (OMM_WITH_RUPD)
      if (OWRF) then
CCC_    * T interpolation (already done in caller)
CCC_    * temperature relative to pressure melting point
         T0 = PMM (PMT_T0)
         CC = PMM (PMT_CLCLD)
         call MPPptc
     M       (VMTW,
     I        VMI,  WZV (1, VMVZ_cZa),
     I        T0,   CC,
     I        KWT,  KWT, KIH, MH, LH, NZ, LZ, KZ0)
CCC_    * rate factor
         Rgas = PMM (PMD_RGAS)
         TM   = PMM (PMD_TM)
         QL   = PMM (PMD_QL)
         QH   = PMM (PMD_QH)
         AL   = PMM (PMD_AL)
         AH   = PMM (PMD_AH)
c$$$         call MPRfaC
c$$$     O          (VMTW(1,1,VMTW_ARFd),
c$$$     I           VMTW(1,1,VMTW_W1), PMM, MH, LH, NZ, LZ, KZ0)
         call MPRfaC
     O       (VMTW(1,1,KWRF),
     I        VMTW(1,1,KWT), IMM, PMM, MH, LH, NZ, LZ, KZ0)
c$$$         call MPRfaS
c$$$     M       (VMTW,
c$$$     I        Rgas, TM,  QL, QH, AL, AH,
c$$$     I        KWRF, KWT, MH, LH, NZ, LZ, KZ0)
CCC_    * rate factor integral
         if (IMM (IMD_RFI).eq. SW_RFI_GG) then
            call MIFgii
     O          (VMTW,
     I           GG,     WZV (1, VMVZ_Za), WZV (1, VMVZ_dZb),
     I           KWRFI,  KWEF, KWRF, MH, LH, NZ, LZ, KZ0, NTH)
            call MIFgio
     O          (VMTW,
     I           GG,     WZV (1, VMVZ_Za), WZV (1, VMVZ_dZb),
     I           KWRFII, KWEF, KWRF, MH, LH, NZ, LZ, KZ0, NTH)
            jz = KZ0 + NZ - 1
            do jh = 1, MH
               VMI (jh, KIRFW) = VMTW (jh, jz, KWRFII)
            enddo
         else if (IMM (IMD_RFI).eq. SW_RFI_EULER) then
            PF = PMM (PMD_PF)
            call MIFera
     O          (VMTW, VMI,
     I           WZV,
     I           KWRFI, KWRFII, KIRFW,
     I           KWRF,  KWEF,
     I           VMVZ_Za,   VMVZ_dZb,
     I           PF,
     I           MH,   LH,   NZ, LZ, KZ0)
         endif
      endif
CCC_   . basal sliding switch
c$$$      call AKGmey
c$$$     O    (VMTW (1,1,VMTW_W1),
c$$$     I     CW,   VMTI (1,1,VMTI_T1),
c$$$     I     MH,   LH,   1, LZ, KZ0,
c$$$     I     ipKW, KOPC, ipCG)
      RETURN
      END
CCC_ & MDbsld  ## Basal sliding factor
      subroutine MDbsld
     O    (iErr,
     O     VMI,
     W     VMW,
     I     VMHB,
     I     CW,    OMM,   IMM,  PMM,
     I     MH,    LH,
     I     KISLD, KIB,
     I     KWC,   KWN, KHBR,
     I     KOPC,
     I     ipCG,   ipKW, iMA, IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
c
      _INTENT(IN,   integer)  MH, LH
c
      _INTENT(INOUT,_REALSTD) VMI  (LH, *)
c
      _INTENT(INOUT,_REALSTD) VMW  (LH, *)
      _INTENT(IN,   _REALSTD) VMHB (LH, *)
      _INTENT(IN,   _REALSTD) CW   (*)
c
      _INTENT(IN,   logical)  OMM  (*)
      _INTENT(IN,   integer)  IMM  (*)
      _INTENT(IN,   _REALSTD) PMM  (*)
c
      _INTENT(IN,   integer)  iMA  (*)
      _INTENT(IN,   integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN,   integer)  ipCG (*)
c
      _INTENT(IN,   integer)  KISLD
      _INTENT(IN,   integer)  KIB
      _INTENT(IN,   integer)  KWC, KWN
      _INTENT(IN,   integer)  KHBR
      _INTENT(IN,   integer)  KOPC
c
      _INTENT(IN,   integer)  IFPl
c
      _REALSTD  TC
      integer   jh
      integer   KVBSW
CCC_  - Body
      iErr = 0
      KVBSW = IMM (IMD_VBSW)
CCC_   . preparation
      do jh = 1, MH
         if (VMI (jh, KIB).le.VMHB (jh, KHBR)) then
            VMI (jh, KISLD) = 1.0d0
         else
            VMI (jh, KISLD) = 0.0d0
         endif
      enddo
      if (KVBSW .eq. SW_VBSW_ALL) then
         continue
      else
         TC    = PMM (PMD_TCVB)
         call AKGmex
     M       (VMW,
     I        CW,
     I        MH,   LH,   KWN, KWC,
     I        ipKW, KOPC, ipCG)
cc       Todo: mirror
         if (KVBSW .eq. SW_VBSW_OR) then
            do jh = 1, MH
               if (VMW (jh, KWN).ge.TC
     $              .OR.
     $              VMW (jh, KWC).ge.TC) then
                  continue
c$$$                  VMI (jh, KISLD) = 1.0d0
               else
                  VMI (jh, KISLD) = 0.0d0
               endif
            enddo
         else if (KVBSW .eq. SW_VBSW_AND) then
            do jh = 1, MH
               if (VMW (jh, KWN).ge.TC
     $              .AND.
     $              VMW (jh, KWC).ge.TC) then
                  continue
c$$$                  VMI (jh, KISLD) = 1.0d0
               else
                  VMI (jh, KISLD) = 0.0d0
               endif
            enddo
         else
            iErr = -1
         endif
      endif
      RETURN
      END
CCC_ & MDdtca  ## time step adjustment
      subroutine MDdtca
     O    (DTp,
     W     W,
     I     DTcum, DT,
     I     VMID,  WW,  IMM,
     I     ipKW,  iMA, MH, LH, MSW, IFP)
      implicit none
      _INTENT(OUT,_REALSTD) DTp
      _INTENT(OUT,_REALSTD) W     (LH, *)
      _INTENT(IN, _REALSTD) DTcum, DT
      _INTENT(IN, integer)  MH, LH
      _INTENT(IN, _REALSTD) VMID  (LH, *)
      _INTENT(IN, _REALSTD) WW    (LH, *)
      _INTENT(IN, integer)  IMM(*)
      _INTENT(IN, integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN, integer)  iMA  (*)
      _INTENT(IN, integer)  MSW
      _INTENT(IN, integer)  IFP
      integer jp, kx, ky
      _REALSTD exmax, eymax, tx, ty, em, fm
      integer jtry
c 7/8 3/4 5/8 1/2 3/8 1/4 1/8
      fm    = 2.0d0
      exmax = 0.0d0
      eymax = 0.0d0
      kx = ipKW (KWI_KWO, KWO_dXb, KWM_M)
      ky = ipKW (KWI_KWO, KWO_dYc, KWM_M)
      do jp = 1, MH
         tx = (VMID (jp,VMID_UIavb) + VMID (jp,VMID_UBb)) / WW (jp, kx)
         ty = (VMID (jp,VMID_VIavc) + VMID (jp,VMID_VBc)) / WW (jp, ky)
         exmax = max (exmax, abs (tx))
         eymax = max (eymax, abs (ty))
      enddo
      call DMWcma (exmax, iMA)
      call DMWcma (eymax, iMA)
      em = max (exmax, eymax) * fm
      DTp = DT - DTcum
c
      if (em.gt.0.0d0) then
         em = 1.0d0 / em
         do jtry = 1, IMM (IMD_DTTRY)
            if (DTp .le. em) goto 100
            DTp = DTp / 2.0d0
         enddo
 100     continue
      endif
 101  format ('TIME STEP: ', E12.5, 1x, E10.3)
      write (IFP, 101) DTp, 1.0d0 / DTp
      RETURN
      END
CCC_* [Configuration]
CCC_ & MDBtim  ## Time initialization batch
      subroutine MDBtim
     O    (iErr,
     O     TINI,  TEND,  DT,
     O     TSSA,
     I     CR,    ipP,   ipC, ipL)
CCC_  - Declaration
      implicit none
CCC_   . Arguments
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,_REALSTD)  TINI, TEND, DT
      _INTENT(OUT,_REALSTD)  TSSA
      _INTENT(IN, character) CR*(*)
      _INTENT(IN, integer)   ipP, ipC, ipL
CCC_  - Body
      iErr = 0
      if (iErr.eq.0) then
         TINI  = 0.0d0
         TEND  = 200000.0d0
         DT    = 10.0d0
         TSSA  = 20000.0d0
      endif
CCC_   . default setting
      if (iErr.eq.0) then
         call MDnctm
     O       (iErr,
     M        TINI,  TEND,  DT,
     M        TSSA,
     I        ' ',   ipP,   ipC,  ipL)
         call DAtrcU (ipL, iErr, '-', 'MDBTIM')
         iErr = 0
      endif
CCC_   . individual setting
      if (iErr.eq.0) then
         call MDnctm
     O       (iErr,
     M        TINI,  TEND,  DT,
     M        TSSA,
     I        CR,    ipP,   ipC,  ipL)
         call DAtrcU (ipL, iErr, CR, 'MDBTIM')
      endif
CCC_   . reset error
      iErr = 0
      RETURN
      END
CCC_ & MDnctm  ## Time initialization by namelist
      subroutine MDnctm
     O    (iErr,
     M     TINI,  TEND,  DT,
     M     TSSA,
     I     CR,    ipP,   ipC,  ipL)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,_REALSTD)  TINI, TEND, DT
      _INTENT(INOUT,_REALSTD)  TSSA
      _INTENT(IN, character)   CR*(*)
      _INTENT(IN, integer)     ipP, ipC, ipL
c
      integer    KTM
      character  CROOT * (8)
      namelist /NITMMD/
     $     CROOT, KTM,
     $     TINI,  TEND, DT,
     $     TSSA
c
      _REALSTD  dTINI, dTEND, dDT
      _REALSTD  dTSSA
c
      integer    LVEML
      parameter (LVEML = OPT_NAMELIST_OUTPUT_EMULATION)
CCC_  - Body
      iErr = 0
c
      dTINI = TINI
      dTEND = TEND
      dDT   = DT
      dTSSA = TSSA
c
      call UUrwnd (iErr, ipP)
      DO
         KTM   = 0
         CROOT = ' '
         TINI = dTINI
         TEND = dTEND
         DT   = dDT
         TSSA = dTSSA
         if (iErr.eq.0) READ (ipP, NITMMD, IOSTAT = iErr)
         if (iErr.eq.0) then
            if (CROOT.eq.CR) goto 100
         endif
         if (iErr.ne.0) goto 100
      ENDDO
 100  continue
      if (iErr.eq.0) then
         if (LVEML.gt.0) then
            call UNBbgn (iErr, 'NITMMD',       ipC, LVEML)
            call UNBstr (iErr, 'CROOT', CR,    ipC, LVEML)
            call UNBint (iErr, 'KTM',   KTM,   ipC, LVEML)
            call UNBrst (iErr, 'TINI',  TINI,  ipC, LVEML)
            call UNBrst (iErr, 'TEND',  TEND,  ipC, LVEML)
            call UNBrst (iErr, 'DT',    DT,    ipC, LVEML)
            call UNBrst (iErr, 'TSSA',  TSSA,  ipC, LVEML)
            call UNBend (iErr, 'NITMMD',       ipC, LVEML)
         else
            CROOT = CR
            if (COND_N(ipC)) then
               write (ipC, NITMMD)
            else if (COND_S(ipC)) then
               write (*,   NITMMD)
            endif
         endif
      else
         TINI = dTINI
         TEND = dTEND
         DT   = dDT
         TSSA = dTSSA
      endif
c
      RETURN
      END
CCC_ & MDBpnm  ## Parameters initialization by namelist batch
      subroutine MDBpnm
     O    (iErr,
     O     OMM,  IMM,  PMM,
     I     CR,   ipP,  ipC,  ipL)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,logical)   OMM (*)
      _INTENT(OUT,integer)   IMM (*)
      _INTENT(OUT,_REALSTD)  PMM (*)
      _INTENT(IN, character) CR*(*)
      _INTENT(IN, integer)   ipP, ipC, ipL
      iErr = 0
      if (iErr.eq.0) then
         call MDnpmi (iErr, OMM, IMM, PMM, CR, ipP, ipC, ipL)
      endif
      if (iErr.eq.0) then
         call MDnswi (iErr, OMM, IMM, PMM, CR, ipP, ipC, ipL)
      endif
      if (iErr.eq.0) then
         call MSNbpi (iErr, OMM, PMM, IMM, CR, ipP, ipC, ipL)
      endif
      if (iErr.eq.0) then
         call MTTnpm (iErr, OMM, IMM, PMM, CR, ipP, ipC, ipL)
      endif
      if (iErr.eq.0) then
         call MAGnpm (iErr, OMM, IMM, PMM, CR, ipP, ipC, ipL)
      endif
      RETURN
      END
CCC_ & MDnpmi  ## Parameters initialization by namelist
      subroutine MDnpmi
     O    (iErr,
     O     OMM,  IMM,  PMM,
     I     CR,   ipP,  ipC, ipL)
CCC_  - Declaration
      implicit none
CCC_   . Arguments
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,logical)   OMM (*)
      _INTENT(OUT,integer)   IMM (*)
      _INTENT(OUT,_REALSTD)  PMM (*)
      _INTENT(IN, character) CR*(*)
      _INTENT(IN, integer)   ipP, ipC, ipL
CCC_   . Configuration
      character  CROOT * (8)
      _REALSTD   DENS,   DENSW, GRAV, FGZ,  FGX, FGY
      _REALSTD   PF,     EF,    EFSH, RF
      _REALSTD   ETOL,   EPS,   WF,   CLV
      _REALSTD   TM,     QL,    AL,   QH,   AH,  RGAS
      _REALSTD   TCVB,   SHH,   DRSH, RVSH, VBLIM
      integer    ITRMAX, MDTADJ
      namelist /NIPRMD/
     $     CROOT,
     $     DENS,   DENSW, GRAV, FGZ, FGX, FGY, PF, EF, EFSH, RF,
     $     ETOL,   EPS,   WF,   CLV,
     $     TM,     QL,    AL,   QH,  AH,  RGAS, TCVB,
     $     SHH,    DRSH,  RVSH, VBLIM,
     $     ITRMAX, MDTADJ
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
      DENS  = 910.0d0
      DENSW = 1028.0d0
      GRAV  = 9.81d0
      FGZ   = 1.0d0
      FGX   = 0.0d0
      FGY   = 0.0d0
      PF    = 3.0d0
      EF    = 1.0d0
      EFSH  = 0.0d0
c$$$      ETOL  = 1.0d-21
      ETOL  = 1.0d-15
      EPS   = 1.0d-31
      WF    = 1.0d0
      CLV   = 100.0d0
c$$$      SHH   = 50.0d0
      SHH   = 0.0d0
      DRSH  = -1.d10
      RVSH  = 2.0d0
c
      TM   = 263.15d0
      RF   = 1.0d-16
      QL   = 6.0d4
      QH   = 13.9d4
      AL   = 3.61d-13 * 31556926.0d0
      AH   = 1.73d3   * 31556926.0d0
      Rgas = 8.314d0
      TCVB = 273.15d0
      VBLIM= -1.0d0
c
      ITRMAX = 1024
      MDTADJ = 32
c
      if (ipP.ge.0) then
         READ  (ipP, NIPRMD, IOSTAT = iErr)
      else if (ipP.eq.-1) then
         READ  (*,   NIPRMD, IOSTAT = iErr)
      else
         iErr  = 0
         CROOT = CR
      endif
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
         if (COND_N(ipC)) then
            write (ipC, NIPRMD, IOSTAT = iErr)
         else if (COND_S(ipC)) then
            write (*,   NIPRMD, IOSTAT = iErr)
         endif
      endif
CCC_   . Packing
      if (EFSH.le.0.0d0) EFSH = EF
c
      PMM (PMD_DENS)  = DENS
      PMM (PMD_DENSW) = DENSW
      PMM (PMD_GRAV)  = GRAV
      PMM (PMD_PF)    = PF
      PMM (PMD_FGX)   = FGX
      PMM (PMD_FGY)   = FGY
      PMM (PMD_FGZ)   = FGZ
      PMM (PMD_RFC)   = RF
      PMM (PMD_EFC)   = EF
      PMM (PMD_EFCSH) = EFSH
      PMM (PMD_ETOL)  = ETOL
      PMM (PMD_EPS)   = EPS
      PMM (PMD_WF)    = WF
      PMM (PMD_CLV)   = CLV
c
      PMM (PMD_RGAS) = Rgas
      PMM (PMD_TM)   = TM
      PMM (PMD_QL)   = QL
      PMM (PMD_QH)   = QH
      PMM (PMD_AL)   = AL
      PMM (PMD_AH)   = AH
      PMM (PMD_TCVB) = TCVB
      PMM (PMD_SHH)  = SHH
      PMM (PMD_DRSH) = DRSH
      PMM (PMD_RVSH) = RVSH
      PMM (PMD_VBLIM)= VBLIM
c
      IMM (IMD_ITRMAX) = ITRMAX
      IMM (IMD_DTTRY)  = MDTADJ
c
      call DAtrcU (ipL, iErr, 'R', 'MDNPMI')
      RETURN
      END
CCC_ & MDnswi  ## Parameters initialization by namelist
      subroutine MDnswi
     O    (iErr,
     O     OMM,  IMM,  PMM,
     I     CR,   ipP,  ipC, ipL)
CCC_  - Declaration
      implicit none
CCC_   . Arguments
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,logical)   OMM (*)
      _INTENT(OUT,integer)   IMM (*)
      _INTENT(OUT,_REALSTD)  PMM (*)
      _INTENT(IN, character) CR*(*)
      _INTENT(IN, integer)   ipP, ipC, ipL
CCC_   . Configuration
      character  CROOT * (8)
      integer    MSW,   MINI
      integer    KRF,   KRFI,   KWI,   KTBDZ, KUSG
      integer    KUADV, KWADV
      integer    KVB,   KVBSW,  KSHSW, KFGSW, KEGSW, KTZLP
      integer    KDHDT, KSTRH
      integer    KHUPD
      integer    KAGEC, KARST,  KABDZ, KASDZ, KAADVL
      namelist /NIMSWD/
     $     MSW,   MINI,
     $     KRF,   KRFI,  KWI,   KTBDZ, KUSG,
     $     KUADV, KWADV,
     $     KVB,   KVBSW, KSHSW, KFGSW, KEGSW, KTZLP,
     $     KDHDT, KSTRH, KHUPD,
     $     KAGEC, KARST, KABDZ, KASDZ, KAADVL
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
c
      MSW    = MMXSW_DVB
      MINI   = MMXINI_0
c
      KRF    = SW_RF_CONST
      KRFI   = SW_RFI_GG
      KWI    = SW_WI_SNOOPY
      KTBDZ  = SW_TBDZ_CENTER
      KUSG   = SW_USG_SNOOPY
      KUADV  = SW_UADV_SELF
      KWADV  = SW_WADV_XKB
      KVB    = SW_VB_NONE
      KVBSW  = SW_VBSW_AND
      KSHSW  = SW_SHELFY_DEF
      KFGSW  = SW_DSFR_ZERO
      KEGSW  = SW_DSSE_NORMAL
      KTZLP  = SW_TZLP_OUTER
      KDHDT  = SW_DHDT_FLUX
      KSTRH  = SW_STRH_DEFAULT
      KHUPD  = SW_HUPD_TRUE
      KAGEC  = SW_AGEC_UPWIND
      KARST  = SW_AGEC_RESET_AFTER_OFF
      KASDZ  = SW_ADZ_CENTER
      KABDZ  = SW_ADZ_CENTER
      KAADVL = SW_ADVV_STAGGERED
c
      if (ipP.ge.0) then
         READ  (ipP, NIMSWD, IOSTAT = iErr)
      else if (ipP.eq.-1) then
         READ  (*,   NIMSWD, IOSTAT = iErr)
      else
         iErr  = 0
         CROOT = CR
      endif
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
         if (COND_N(ipC)) then
            write (ipC, NIMSWD, IOSTAT = iErr)
         else if (COND_S(ipC)) then
            write (*,   NIMSWD, IOSTAT = iErr)
         endif
      endif
CCC_   . Packing
      IMM (IMD_MSW)    = MSW
      IMM (IMD_MINI)   = MINI
c
      IMM (IMD_RF)     = KRF
      IMM (IMD_RFI)    = KRFI
      IMM (IMD_WI)     = KWI
      IMM (IMD_TBDZ)   = KTBDZ
      IMM (IMD_USG)    = KUSG
      IMM (IMD_UADV)   = KUADV
      IMM (IMD_WADV)   = KWADV
      IMM (IMD_VB)     = KVB
      IMM (IMD_VBSW)   = KVBSW
      IMM (IMD_SHSW)   = KSHSW
      IMM (IMD_DSFR)   = KFGSW
      IMM (IMD_DSSE)   = KEGSW
      IMM (IMD_TZLP)   = KTZLP
      IMM (IMD_DHDT)   = KDHDT
      IMM (IMD_STRH)   = KSTRH
      IMM (IMD_HUPD)   = KHUPD
      IMM (IMD_AGEC)   = KAGEC
      IMM (IMD_ARSTT)  = KARST
      IMM (IMD_ASDZ)   = KASDZ
      IMM (IMD_ABDZ)   = KABDZ
      IMM (IMD_AADVL)  = KAADVL
c
      if (IMM(IMD_AGEC).ne. SW_AGEC_OFF
     $     .and. IMM(IMD_WADV).eq. SW_WADV_RAW) then
 301     format('DATING WTIH RAW W NOT IMPLEMENTED.')
         write(ipL, 301)
         iErr = -1
      endif
c
      call DAtrcU (ipL, iErr, 'R', 'MDNSWI')
      RETURN
      END
CCC_ & MDBkwi  ## Kiwi operators declaration batch
      subroutine MDBkwi (iErr, ipKW, IFP)
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(OUT,integer) ipKW (*)
      _INTENT(IN, integer) IFP
      iErr = 0
      if (iErr.eq.0) call AKPini (ipKW)
      if (iErr.eq.0) call MIBdec (iErr, ipKW, IFP)
      if (iErr.eq.0) call MMXdec (iErr, ipKW, IFP)
      if (iErr.eq.0) call MSNdec (iErr, ipKW, IFP)
      if (iErr.eq.0) call MGLdec (iErr, ipKW, IFP)
      if (iErr.eq.0) call MSBdec (iErr, ipKW, IFP)
      if (iErr.eq.0) call MDUdec (iErr, ipKW, IFP)
      RETURN
      END
CCC_ & MDUdec  ## Kiwi operators declaration
      subroutine MDUdec (iErr, ipKW, IFP)
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(OUT,integer) ipKW (*)
      _INTENT(IN, integer) IFP
c
      iErr = 0
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_Xa, KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_Ya, KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_Xb, KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_Yb, KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_Xc, KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_Yc, KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_Xd, KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_Yd, KWM_BOTH, IFP)
c
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_ZXa, KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_ZYa, KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_ZXb, KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_ZYb, KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_ZXc, KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_ZYc, KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_ZXd, KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_ZYd, KWM_BOTH, IFP)
c
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_dXb, KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_dYc, KWM_BOTH, IFP)
      call DAtrcU (IFP, iErr, 'R', 'MDUdec')
      RETURN
      END
CCC_ & MDBkcg  ## Kiwi-weights/Coordinate/Geometry generation batch
      subroutine MDBkcg
     O    (iErr,
     W     W,
     O     MH,     LH,     MG,     LG,   WW,
     O     ipKW,   IE,     icF,
     O     NZ,     LZ,     KZ0,    GG,   WZV,
     I     LW,     LHPref, LHGref, LKW,  LIE,
     I     LZref,  NTH,
     I     IMM,    PMM,    CR,     iMA,  ipP,  ipC,  ipL)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
c
      _INTENT(OUT,_REALSTD)  W    (*)
      _INTENT(OUT,integer)   ipKW (*)
      _INTENT(OUT,integer)   IE   (*)
      _INTENT(OUT,integer)   icF
c
      _INTENT(OUT,_REALSTD)  WW  (*)
      _INTENT(OUT,_REALSTD)  WZV (*)
      _INTENT(OUT,_REALSTD)  GG  (*)
c
      _INTENT(OUT,integer)   MH,     LH
      _INTENT(OUT,integer)   MG,     LG
      _INTENT(OUT,integer)   NZ,     LZ,    KZ0
c
      _INTENT(IN, integer)   IMM (*)
      _INTENT(IN, _REALSTD)  PMM (*)
c
      _INTENT(IN, integer)   LW
      _INTENT(IN, integer)   LHPref, LHGref, LZref
      _INTENT(IN, integer)   LKW
      _INTENT(IN, integer)   LIE
      _INTENT(IN, integer)   NTH
      _INTENT(IN, integer)   iMA (*)
      _INTENT(IN, character) CR*(*)
      _INTENT(IN, integer)   ipP,    ipC,   ipL
c
      integer  icGz (2)
      integer  jedmy, jcdmy
      integer  jzb,   jz
      _REALSTD PF
CCC_  - Body
      iErr = 0
CCC_   . arpeggio configuration suite
      call AMBcfg
     O    (iErr,
     W     W,                  LW,
     O     MH,   LH,           LHPref,
     O     MG,   LG,           LHGref,
     O     NZ,   LZ,    KZ0,   LZref,
     O     WW,                 LKW,
     O     IE,                 LIE,
     O     ipKW, icF,
     I     CR,   iMA,   ipP,   ipC,    ipL)
CCC_   . integral table GG
      PF = PMM (PMD_PF)
      if (iErr.eq.0) then
         call ACCrfI (jedmy, jcdmy, icGz, icF, -1, 'Z', ipL)
         call MIFvgt
     O       (iErr,
     O        WZV,
     I        VMVZ_Za, VMVZ_cZa,  VMVZ_dZb,  VMVZ_cZaN,
     I        PF,
     I        LZ,      icGz (1),  icGz (2),  ipL)
      endif
      if (iErr.eq.0) then
         call MIFgst
     $        (GG,    WZV, NZ, LZ, KZ0, VMVZ_Za, NTH, PF)
      endif
      if (iErr.eq.0) then
         jzb = KZ0 - 1
         call MTFvgt
     O       (iErr,
     W        W,
     O        WZV,
     I        0,
     I        VMVZ_dPb,
     I        VMVZ_dWPb,  VMVZ_dWMb,  VMVZ_dXa,
     I        VMVZ_ddWPa, VMVZ_ddWOa, VMVZ_ddWMa, VMVZ_ddXa, VMVZ_iddXa,
     I        VMVZ_Lap,   VMVZ_Lam,   VMVZ_Lbp,   VMVZ_Lbm,
     I        NZ, LZ,  jzb, icGz (1), icGz (2),  ipL)
      endif
CCC_   . return
      call DAtrcU (ipL, iErr, 'R', 'MDBKCG')
      RETURN
      END
CCC_ & MDBcgd  ## Clone gloups declaration batch
      subroutine MDBcgd
     O    (iErr,
     O     KSglb, ipCG,
     W     kDTA,
     I     LNR,   LTBL, LCG, LH, LCK, ipKW, IE, IFP)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(IN, integer) LNR, LTBL, LCG, LCK, LH
      _INTENT(OUT,integer) KSglb (*)
      _INTENT(OUT,integer) kDTA  (LTBL, 3)
      _INTENT(OUT,integer) ipCG  (LCG, *)
      _INTENT(IN, integer) ipKW  (*), IE (*), IFP
      integer LHG
CCC_  - Body
      iErr = 0
c
      if (iErr.eq.0) then
         LHG  = 0
         call AESglb
     O       (iErr,
     O        KSglb,
     W        kDTA,
     I        LNR, LTBL, LH, LHG, IE, IFP)
      endif
c
      if (iErr.eq.0) then
         call MMBcgr
     O       (iErr,
     O        ipCG,
     W        kDTA,
     I        LTBL, LCG, LH, LCK, ipKW, IE, IFP)
      endif
c
      if (iErr.eq.0) then
         call MMWacg
     O       (iErr,
     O        ipCG,
     W        kDTA,
     I        LTBL, LCG, LH, LCK, ipKW, IE, IFP)
      endif
c
      if (iErr.eq.0) then
         call MSNcgr
     O       (iErr,
     O        ipCG,
     W        kDTA,
     I        LTBL, LCG, LH, LCK, ipKW, IE, IFP)
      endif
c
      if (iErr.eq.0) then
         call MTKcgr
     O       (iErr,
     O        ipCG,
     W        kDTA,
     I        LTBL, LCG, LH, LCK, ipKW, IE, IFP)
      endif
      RETURN
      END
CCC_* [Suite]
CCC_ & MDinit  ## initialization suite
      subroutine MDinit
     O    (iErr,
     O     MH,     LH,            LHPref,
     O     MG,     LG,            LHGref,
     O     NZ,     LZ,     KZ0,   LZref,
     O     GG,                    NTH,
     O     WZV,    WW,            LKW,
     O     IE,                    LIE,
     O     ipCG,                  LCG,   LCK,
     O     KSglb,                 LNR,
     O     kDTA,                  LTBL,
     O     VMW,                   LVMW,
     O     icF,    idGM,   ipFI,  ipKW,
     O     OMM,    IMM,    PMM,
     I     TINI,   TEND,
     I     CSW,    CLS,    CR,    iMA,  ipA)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)  iErr
CCC_   . arppegio configuration
      _INTENT(OUT,integer)  MH, LH, MG, LG, NZ, LZ, KZ0
      _INTENT(OUT,_REALSTD) WW (*), WZV (*), GG (*)
      _INTENT(OUT,integer)  icF
      _INTENT(OUT,integer)  idGM (*)
      _INTENT(OUT,integer)  ipFI (*)
      _INTENT(OUT,integer)  ipKW (*)
      _INTENT(OUT,integer)  IE   (*)
      _INTENT(OUT,integer)  ipCG (*)
      _INTENT(OUT,integer)  KSglb(*)
CCC_   . work
      _INTENT(OUT,integer)  kDTA (*)
      _INTENT(OUT,_REALSTD) VMW  (*)
CCC_   . movement configuration
      _INTENT(OUT,logical)  OMM  (*)
      _INTENT(OUT,integer)  IMM  (*)
      _INTENT(OUT,_REALSTD) PMM  (*)
CCC_   . inputs
      _INTENT(IN, integer)   LVMW
      _INTENT(IN, integer)   LHPref, LHGref
      _INTENT(IN, integer)   LZref,  NTH
      _INTENT(IN, integer)   LKW,    LIE
      _INTENT(IN, integer)   LNR,    LTBL,   LCG,    LCK
      _INTENT(IN, _REALSTD)  TINI,   TEND
      _INTENT(IN, character) CSW*(*)
      _INTENT(IN, character) CR*(*)
      _INTENT(IN, character) CLS*(*)
      _INTENT(IN, integer)   ipA (*)
      _INTENT(IN, integer)   iMA (*)
CCC_   . interior
      integer ipC, ipL, ipP, ipV
      _REALSTD DTRC
CCC_  - Body
      iErr = 0
CCC_   . file units
      ipL  = FPL(ipA)
      ipP  = FPP(ipA)
      ipC  = FPC(ipA)
      ipV  = FPV(ipA)
      call AFUnvp (ipFI)
      call AFUifp (ipFI, ipP, ipC, ipL, ipV)
CCC_   . i/o configuration
c$$$      CSW = 'C'
c$$$      CLS = MOVEMENT_DV_CLS
CCC_   . parameters initialization
      if (iErr.eq.0) then
         call MDBpnm
     O       (iErr,
     O        OMM, IMM, PMM,
     I        CR,  ipP, ipC, ipL)
      endif
CCC_   . Arpeggio configuration
CCC_    * output interval default
      DTRC = MAX(1.0d0, (TEND - TINI) / 10.0d0)
      if (iErr.eq.0) then
         call AFBdft (iErr, CR, TINI, TEND, DTRC, ipFI)
      endif
CCC_    * kiwi operators declaration
      if (iErr.eq.0) then
         call MDBkwi (iErr, ipKW, ipL)
      endif
CCC_    * table generation (kiwi-weight, coordinate, geometry)
      if (iErr.eq.0) then
         call MDBkcg
     O       (iErr,
     W        VMW,
     O        MH,     LH,     MG,     LG,   WW,
     O        ipKW,   IE,     icF,
     O        NZ,     LZ,     KZ0,    GG,   WZV,
     I        LVMW,   LHPref, LHGref, LKW,  LIE,
     I        LZref,  NTH,
     I        IMM,    PMM,    CR,     iMA,  ipP,  ipC,  ipL)
      endif
CCC_    * clone group/global stencil declaration
      if (iErr.eq.0) then
         call MDBcgd
     O       (iErr,
     O        KSglb, ipCG,
     W        kDTA,
     I        LNR,   LTBL, LCG, LH, LCK, ipKW, IE, ipL)
      endif
CCC_    * reports
      if (iErr.eq.0) then
         call AMBrep
     O       (iErr,
     I        WW,  IE,  ipKW,
     I        MH,  LH,
     I        icF, CR,  CSW,  CLS,  ipFI,  iMA)
      endif
CCC_   . Variable clusters
      if (iErr.eq.0) then
         call MUVrgd
     O       (iErr,
     O        idGM,
     I        icF,  MH,  LH, NZ,   LZ,  KZ0,
     I        CSW,  CLS, CR, ipFI, IE,  iMA)
      endif
CCC_   . end
      call DAtrcU (ipL, iErr, CR, 'MDINIT')
      RETURN
      END
CCC_ & MDfine  ## finalization suite
CCC_& MDRVRM  ## Movement/Driver announcement
      subroutine MDRVRM (STRA, STRB, IOP)
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
CCC_* Test
CCC_ @ MDTEST  ## Mdrvrm test program
#if TEST_MDRVRM
#include "ofnstd.h"
#include "odevid.h"
#include "TreeID"
#ifndef   GIT_INFOs
#  define GIT_INFOs 'none'
#endif
      program MDTEST
CCC_  - Test suites
CC::   KINDS 1 2 3 4 5 6 7 8
CC::   SOURCES mmcipc.F mmsbcg.F mutcfg.F msnita.F mibakw.F mmxoms.F mbscol.F msbmos.F mmwcol.F mttcol.F
CC::   SOURCES 4 dbg_mttcol.F
CCC_  - Declaration
      implicit none
      integer iErr
      integer ipA (LOG_CHANNEL_MAX)
      integer iMA (MAX_MPI_ATTR)
CCC_  - Body
      call DDxidP
     $     (iErr, GIT_INFOs)
      call DDcapo
     O    (iErr,
     I     2, ' ', 'O', _FNAME, TEST_MDRVRM)
c
      if (iErr.eq.0) then
         call DLCmng (ipA, 't')
         call DVHrgC (iErr, MOVEMENT_DV_CLS, ' ', ' ', ipA)
      endif
c
      if (iErr.eq.0) then
         call DMAtma (iMA)
         call MDtestMain (iErr, ipA, iMA)
      endif
      call DevFin (iErr)
      STOP
      END
CCC_ & MDtestMain  ## check main
      subroutine MDtestMain (iErr, ipA, iMA)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)  iErr
      _INTENT(IN, integer)  ipA (*)
      _INTENT(IN, integer)  iMA (*)
CCC_   . Domain size limit
#ifndef   OPT_MDRVRM_LHP_MAX
#  define OPT_MDRVRM_LHP_MAX OPT_MOVEMENT_LHP_MAX
#endif
#ifndef   OPT_MDRVRM_LHG_MAX
#  define OPT_MDRVRM_LHG_MAX OPT_MOVEMENT_LHG_MAX
#endif
#ifndef   OPT_MDRVRM_LVZ_MAX
#  define OPT_MDRVRM_LVZ_MAX OPT_MOVEMENT_LVZ_MAX
#endif
#ifndef   OPT_MDRVRM_LVP_MAX
#  define OPT_MDRVRM_LVP_MAX OPT_MOVEMENT_LVP_MAX
#endif
      integer    LHPref
      parameter (LHPref = OPT_MDRVRM_LHP_MAX)
      integer    LHGref
      parameter (LHGref = OPT_MDRVRM_LHG_MAX)
      integer    LTPref
      parameter (LTPref = OPT_MDRVRM_LVP_MAX)
      integer    LZref
      parameter (LZref  = OPT_MDRVRM_LVZ_MAX)
CCC_   . Variable clusters
CCC_    * work common
      integer    LVMW
      parameter (LVMW  = LHPref  * VMW_MAX)
      _REALSTD   VMW  (LVMW)
      integer    LVMTW
      parameter (LVMTW = LTPref * VMTW_MAX)
      _REALSTD   VMTW (LVMTW)
CCC_    * bcg solution/right/intermediate
      _REALSTD   XS   (LHPref * VMSX_MAX * BCGW_MAX)
      _REALSTD   XI   (LHPref * BCGW_MAX)
CCC_    * field common
      _REALSTD   VMHI (LHPref * VMHI_MAX)
      _REALSTD   VMHW (LHPref * VMHW_MAX)
c
      _REALSTD   VMI  (LHPref * VMI_MAX)
      _REALSTD   VMHB (LHPref * VMHB_MAX)
      _REALSTD   VMHR (LHPref * VMHR_MAX)
      _REALSTD   VMC  (LHPref * VMC_MAX)
CCC_    * thickness integration
      _REALSTD   QM   (LHPref * VMQQ_MAX)
      _REALSTD   VMID (LHPref * VMID_MAX)
CCC_    * SSA solver
      _REALSTD   VMSC (LHPref * VMSC_MAX)
      _REALSTD   VMSV (LHPref * VMSV_MAX)
      _REALSTD   VMSE (LHPref * VMSE_MAX)
CCC_    * 3d velocity
      _REALSTD   VMTI (LTPref * VMTI_MAX)
CCC_    * conversion table
      integer    KTB  (LHPref, 2)
CCC_    * integration weights
      integer    NTH
      parameter (NTH = 2)
      _REALSTD   GG  (LZref * 4 * (NTH + 1) * (NTH + 1))
CCC_   . kiwi weights
      integer    LKW
      parameter (LKW = 90)
      _REALSTD   WW (LHPref * LKW)
CCC_   . vertical geometry
      _REALSTD   WZV (LZref * VMVZ_MAX)
CCC_   . work
      integer    LCK
      parameter (LCK = LZref + 16)
      _REALSTD   CW (LHPref * LCK)
      _REALSTD   GW (LHGref)
CCC_   . Parameters
      logical    OMM (OMM_MAX)
      integer    IMM (IMM_MAX)
      _REALSTD   PMM (PMM_MAX)
CCC_   . Table
      character  CR*8
      data       CR /'ID'/
      integer    LIE
      parameter (LIE = (LHPref * 10))
      integer    IE   (LIE)
      integer    ipKW (IPKW_FULL_DECL)
CCC_    * global/private stencils
      integer    LNR
      parameter (LNR = 256)
      integer    KSglb (LNR * 2)
      integer    LTBL
      parameter (LTBL = LHPref)
      integer    kDTA (LTBL, 3)
CCC_    * clone group
      integer    LCG
      parameter (LCG = KWCG_DECL(CGRP_MEM_MAX))
      integer    ipCG (LCG, CGRP_MAX)
CCC_   . Interior
      integer    MH, LH, MG, LG
      integer    NZ, LZ, KZ0
CCC_   . Coordinate
      integer    icF
CCC_   . Time
      integer    ITstp
      _REALSTD   T,  TNXT
      _REALSTD   TSSA
      _REALSTD   DTI
      _REALSTD   TINI, TEND, DT
CCC_   . Output
      integer    idGM (32)
      character  CSW*(16), CLS*(16)
CCC_   . Log
      integer    ipL, ipP, ipC, ipV
      integer    ipFI (16)
CCC_   . Test configuration
      integer    MAXMTI,       MAXMTP
      parameter (MAXMTI = 128, MAXMTP = 128)
      integer  IMTI (MAXMTI)
      _REALSTD PMTI (MAXMTP)
CCC_   . misc
      integer    jedmy
CCC_  - Body
      iErr = 0
CCC_   . i/o configuration
      CSW = 'C'
      CLS = MOVEMENT_DV_CLS
CCC_   . file units
      ipL  = FPL(ipA)
      ipP  = FPP(ipA)
      ipC  = FPC(ipA)
      ipV  = FPV(ipA)
CCC_   . Health check for Test module
      if (iErr.eq.0) then
         call MUThch (iErr, MAXMTI, MAXMTP, ipP, ipC, ipL)
      endif
CCC_   . Model time
      if (iErr.eq.0) then
         call MDBtim
     O       (iErr,
     O        TINI,  TEND,  DT,
     O        TSSA,
     I        CR,    ipP,   ipC, ipL)
      endif
CCC_   . initialization suite
      if (iErr.eq.0) then
         call MDinit
     O       (iErr,
     O        MH,     LH,            LHPref,
     O        MG,     LG,            LHGref,
     O        NZ,     LZ,     KZ0,   LZref,
     O        GG,                    NTH,
     O        WZV,    WW,            LKW,
     O        IE,                    LIE,
     O        ipCG,                  LCG,   LCK,
     O        KSglb,                 LNR,
     O        kDTA,                  LTBL,
     O        VMW,                   LVMW,
     O        icF,    idGM,   ipFI,  ipKW,
     O        OMM,    IMM,    PMM,
     I        TINI,   TEND,
     I        CSW,    CLS,    CR,    iMA,  ipA)
      endif
CCC_   . Test configuration
      if (iErr.eq.0) then
         call MUTmsi
     O       (iErr,
     O        IMTI, PMTI,
     O        VMHR, VMHB, VMHI, VMTI, VMTW, VMI,
     W        CW,
     I        PMM,  IMM,  WW,   WZV,  GG,  NTH,
     I        MH,   LH,   NZ,   LZ,   KZ0,
     I        CR,   ipKW, iMA,  IE,   ipP, ipC, ipL)
      endif
CCC_   . Initialization
      if (iErr.eq.0) then
         call AFBrmp(jedmy, VMHI, VMW,LVMW, idGM(VGRP_VMHI), IE,ipFI)
         call AFBrmp(jedmy, VMTI, VMW,LVMW, idGM(VGRP_VMTI), IE,ipFI)
c$$$         call UV0d1a(VMI, MH, LH, VMI_HH, 'HH', 0, ipL)
      endif
#define CIP_TEST_IGR 1
c$$$#define CIP_TEST_IGR 0
#if CIP_TEST_IGR /* CIP test */
CCC_    * gradient dH/dx:b
      if (iErr.eq.0) then
         call MMCigr
     O       (iErr,
     M        VMHI,
     W        VMW,  CW,
     I        WW,    MH,   LH,
     I        ipCG,  LCG,  ipKW, iMA, ipL)
      endif
#endif
CCCCCCC
c$$$      OMM (OMM_WITH_RUPD) = .not. (IMM (IMD_RF) .eq. SW_RF_CONST)
      OMM (OMM_WITH_RUPD) = .TRUE.
      OMM (OMM_WITH_HUPD) = .TRUE.
      if (IMM(IMD_HUPD).eq. SW_HUPD_FALSE) OMM (OMM_WITH_HUPD) = .FALSE.
CCC_   . Loop
      if (iErr.eq.0) then
         ITstp  = 0
         T      = TINI
         TNXT   = TINI
c
 101     format ('#T ', I7.7, 1x, F13.4, 1x, F13.4)
         DO
CCC_    * time step adjustment
            TNXT = T + DT
            call AFBnxa (TNXT, T, idGM (VGRP_VMI))
            call AFBnxa (TNXT, T, idGM (VGRP_VMTI))
c
            write (ipL, _FORMAT(101)) ITstp, T, TNXT
#           if HAVE_F77_FLUSH
            call FLUSH (ipL)
#           endif
c
            DTI  = TNXT - T
c
            OMM (OMM_WITH_SIA)  = .true.
            OMM (OMM_WITH_SSA)  = (T.ge.TSSA)
            OMM (OMM_WITH_TUPD) = .true.
            OMM (OMM_WITH_VEL)  = .true.
CCC_    * new thickness
            call MDstpD
     O          (iErr,
     M           VMHI, VMTI, VMI,
     W           XI,   XS,   CW,   GW,    VMW,  VMHW, VMTW,
     W           QM,   VMC,  VMID,
     W           VMSC, VMSV, VMSE,
     I           VMHB, OMM,  IMM,  PMM,   T,    DTI,
     I           WW,   WZV,  GG,
     I           MH,   LH,   NZ,   LZ,    KZ0,  NTH,
     I           IE,   ipKW, iMA,  KSglb, ipCG, LCG, idGM, ipL)
CCC_    * loop break
            if (TNXT.gt.TEND) goto 900
CCC_    * suspend
CCC_    * boundary condition at new (or old) topography
            if (iErr.eq.0) then
               call MUTubc
     O             (iErr,
     O              VMHB,
     I              VMHI,
     I              PMM,  IMM,  WW,  IMTI, PMTI,
     I              MH,   LH,
     I              ipKW, ipL)
            endif
CCC_    * new temperature
            if (iErr.eq.0) then
               call MDstpT
     O             (iErr,
     M              VMHI, VMTI,
     W              CW,   VMHW, VMTW,
     W              KTB,
     I              VMHB, OMM,  IMM,   PMM,   T,   DTI,
     I              WW,   WZV,
     I              MH,   LH,   NZ,    LZ,    KZ0,
     I              IE,   ipKW, iMA,   ipCG,  LCG, idGM, ipL)
            endif
CCC_    * break
            if (iErr.ne.0) goto 900
CCC_    * outputs (profile)
CCC_    * update (must use the final state of VMI again).
            T     = TNXT
            ITstp = ITstp + 1
            if (OMM (OMM_WITH_HUPD)) then
               call UV1cpa (VMHI, VMI, MH, LH, VMHI_oHa,  VMI_Ha)
               call UV1cpa (VMHI, VMI, MH, LH, VMHI_oHXa, VMI_HX)
               call UV1cpa (VMHI, VMI, MH, LH, VMHI_oHYa, VMI_HY)
c$$$            call UV0cpa (VMHI, MH, LH, VMHI_oHa, VMHI_nHa)
            endif
         ENDDO
 900     continue
      endif
c
      call AFBrpg (jedmy, ipL)
      call ACCrep (ipL, 0)
c
      RETURN
      END
#endif /* TEST_MDRVRM */
CCC_* Obsolete
CCC_ + begin
#if 0 /* obsolete */
#endif /* 0 obsolete */
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
