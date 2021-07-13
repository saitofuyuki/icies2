C movement/mttcol.F - IcIES/Movement/Thermodynamics collection
C Maintainer:  SAITO Fuyuki
C Created: May 7 2013
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2021/04/14 10:07:07 fuyuki mttcol.F>'
#define _FNAME 'movement/mttcol.F'
#define _REV   'JosePeterson0'
CCC_! MANIFESTO
C
C Copyright (C) 2013-2021
C           Japan Agency for Marine-Earth Science and Technology,
C           Ayako ABE-OUCHI
C
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
CCC_* Description
CCC_ + policy of horizontal index
CC       Matrix components Q[DMEB]   [1:nh]
CC       Other intermediate field    [1:mh]
CCC_* Common macros
#include "ofdlct.h"   /* fortran dialect */
#include "ologfm.h"   /* log common format */
#include "oarpkw.h"   /* operation id in arpeggio/kiwi */
#include "movement.h" /* movement definitions */
CCC_ + Debug
CC#define DEBUG_MTSBLD 1
#ifndef DEBUG_MTSBLD
#define DEBUG_MTSBLD 0
#endif
#ifndef   TEST_MTTCOL
#  define TEST_MTTCOL 0
#endif
#if TEST_MDRVRM == 4
#ifndef   DEBUG_MTTCOL_SPECIAL
#  define DEBUG_MTTCOL_SPECIAL 1
#endif
#endif
#ifndef   DEBUG_MTTCOL_SPECIAL
#  define DEBUG_MTTCOL_SPECIAL 0
#endif

c$$$#define DEBUG_CONSTANT_THCOND 1
c$$$#define DEBUG_CONSTANT_HCAPI  1
#ifndef   DEBUG_CONSTANT_THCOND
#  define DEBUG_CONSTANT_THCOND 0
#endif
#ifndef   DEBUG_CONSTANT_HCAPI
#  define DEBUG_CONSTANT_HCAPI  0
#endif
CCC_ + switch
#define  LOOP_CHOICE  -1  /* run-time configuration */
#define  LOOP_OUTER_Z  SW_TZLP_OUTER
#define  LOOP_INNER_Z  SW_TZLP_INNER
#ifndef    OPT_TZLP_METHOD
#  define  OPT_TZLP_METHOD  LOOP_CHOICE
#endif
CCC_* Initialization
CCC_ & MTTnpm - Parameters initialization by namelist
      subroutine MTTnpm
     O    (iErr,
     O     OMM,  IMM,  PMM,
     I     CR,   IFPi, IFPn, IFPl)
CCC_  - Declaration
      implicit none
CCC_   . Arguments
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,logical)   OMM (*)
      _INTENT(OUT,integer)   IMM (*)
      _INTENT(OUT,_REALSTD)  PMM (*)
      _INTENT(IN, character) CR*(*)
      _INTENT(IN, integer)   IFPi, IFPn, IFPl
CCC_   . Configuration
      character  CROOT * (8)
      _REALSTD   DENS
      _REALSTD   T0, HCAPI, HCAPIG, CONDI,  CLCLD, CONDIP
      _REALSTD   TBSHC, HCLI
      _REALSTD   YS
      namelist /NIPRMT/
     $     CROOT,
     $     T0, DENS,  HCAPI, HCAPIG, CONDI, CONDIP, CLCLD,
     $     TBSHC,     HCLI
CCC_   . interior
      integer jc
CCC_  - Body
      iErr = 0
      YS = 31556926.d0
CCC_   . Configuration
      jc = 0
 200  continue
      call UUrwnd (iErr, IFPi)
c
 100  continue
c
      CROOT = ' '
      T0    = 273.15d0
      DENS  = 910.0d0
c$$$      HCAPI = 2009.0d0 * (31556926.d0 ** 2.0d0)
#if   DEBUG_CONSTANT_HCAPI
c$$$      HCAPI  = 2009.0d0
      HCAPI  = 1800.0d0
      HCAPIG = 0.0d0
#else /* not DEBUG_CONSTANT_HCAPI */
      HCAPI  = 146.3d0
      HCAPIG = 7.253d0
#endif  /* not DEBUG_CONSTANT_HCAPI */
c$$$      CONDI = 2.1d0
c$$$      CONDI = 2.1d0    * (31556926.d0 ** 3.0d0)
#if DEBUG_CONSTANT_THCOND
      CONDI  = 2.1d0 * YS
c$$$      CONDI  = 2.3d0 * 31556926.d0
      CONDIP = 0.0d0
#else /* not DEBUG_CONSTANT_THCOND */
      CONDI  = 9.828d0 * YS
      CONDIP = -5.7d-3
#endif /* not DEBUG_CONSTANT_THCOND */
c$$$      CONDI = 2.1d0 * 31556926.d0
      CLCLD = 8.7d-4
      TBSHC = -2.0d0 + T0
      HCLI  = 335.0d3
c
      if (IFPi.ge.0) then
         READ  (IFPi, NIPRMT, IOSTAT = iErr)
      else if (IFPi.eq.-1) then
         READ  (*,    NIPRMT, IOSTAT = iErr)
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
         if (COND_N(IFPn)) then
            write (IFPn, NIPRMT, IOSTAT = iErr)
         else if (COND_S(IFPn)) then
            write (*,   NIPRMT, IOSTAT = iErr)
         endif
      endif
CCC_   . Packing
      PMM (PMT_DENS)  = DENS
      PMM (PMT_HCAP)  = HCAPI
      PMM (PMT_HCAPG) = HCAPIG
      PMM (PMT_COND)  = CONDI
      PMM (PMT_CONDP) = CONDIP
      PMM (PMT_CLCLD) = CLCLD
      PMM (PMT_T0)    = T0
      PMM (PMT_TBSHC) = TBSHC
      PMM (PMT_LHC)   = HCLI
c
      call DAtrcU (IFPl, iErr, 'R', 'MTTNPM')
      RETURN
      END
CCC_* temperature update
CCC_ & MTBuvs - temperature update (preparation i)
      subroutine MTBuvs
     O    (iErr,
     M     VMTI,  VMTW, VMHI, VMHW,
     O     CW,
     I     VMID,  VMHB, PMM,  IMM,
     I     WW,    WZV,
     I     MH,    LH,   NZ,   LZ,   KZ0,
     I     ipCG,  LCG,  ipKW, iMA,  IFPl)
CCC_  - Declaration
      implicit none
c
      _INTENT(OUT,  integer)  iErr
c
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
      _INTENT(INOUT,_REALSTD) VMTW (LH, LZ, *)
      _INTENT(INOUT,_REALSTD) VMTI (LH, LZ, *)
      _INTENT(INOUT,_REALSTD) VMHW (LH, *)
      _INTENT(INOUT,_REALSTD) VMHI (LH, *)
      _INTENT(OUT,  _REALSTD) CW   (*)
c
      _INTENT(IN,   _REALSTD) VMID (LH, *)
      _INTENT(IN,   _REALSTD) VMHB (LH, *)
      _INTENT(IN,   _REALSTD) PMM  (*)
      _INTENT(IN,   integer)  IMM  (*)
      _INTENT(IN,   _REALSTD) WZV  (*)
      _INTENT(IN,   _REALSTD) WW   (*)
      _INTENT(IN,   integer)  ipKW (*), iMA (*)
      _INTENT(IN,   integer)  LCG, ipCG (*)
      _INTENT(IN,   integer)  IFPl
c
      _REALSTD  CONDI, CONDIP
      _REALSTD  DENSI, TDC
      integer   jh, jz, jzz
CCC_  - Body
      iErr = 0
CCC_   . strain/frictional heating
      if (iErr.eq.0) then
         if (IMM(IMD_STRH).eq. SW_STRH_DEFAULT) then
            call MTShsd
     O          (iErr,
     O           VMTI,  VMHI, VMHW,
     M           VMTW,  CW,
     I           VMID,  WW,
     I           MH,    LH,   NZ,  LZ, KZ0, ipKW, iMA)
         else if (IMM(IMD_STRH).eq. SW_STRH_SALLY) then
            call MTShst
     O          (iErr,
     O           VMTI,  VMHI,
     M           VMTW,  CW,
     I           VMID,  WW,
     I           MH,    LH,   NZ,  LZ, KZ0, ipKW, iMA)
         else
            iErr = -1
         endif
      endif
CCC_   . thermal conductivity
      if (iErr.eq.0) then
         CONDI  = PMM (PMT_COND)
         CONDIP = PMM (PMT_CONDP)
         call MTFitc
     $       (VMTW(1, 1, VMTW_kti),
     $        VMTI(1, 1, VMTI_T), CONDI, CONDIP, MH, LH, NZ, LZ, KZ0)
c$$$         call MTBthc
c$$$     O       (iErr,
c$$$     O        VMTW,
c$$$     I        VMHW, VMTI,  CONDI, CONDIP,
c$$$     I        WZV,
c$$$     I        MH,   LH,    NZ,  LZ, KZ0)
      endif
CCC_   , heat capacity
      if (iErr.eq.0) then
         call MTShcs
     O       (iErr,
     O        VMTW,
     I        VMTI,  PMM,
     I        MH,    LH,   NZ,  LZ, KZ0)
      endif
CCC_   . total heat sources
      if (iErr.eq.0) then
         DENSI = PMM (PMT_DENS)
         do jz = 1, KZ0 + NZ - 1
            do jh = 1, MH
               TDC = 1.0d0/DENSI/VMTW(jh,jz,VMTW_hcap)
               VMTW(jh, jz, VMTW_HS) = VMTI(jh, jz, VMTI_sh) * TDC
            enddo
         enddo
      endif
      if (iErr.eq.0) then
         call UV3naa
     $        (VMHW, VMHI, VMHB, MH, LH, VMHW_HSB, VMHI_frd, VMHB_GH)
      endif
CCC_   . basal mass balance diagnose
      if (iErr.eq.0) then
         call MTBdbm
     O       (iErr,
     M        VMHI, VMHW,
     I        VMTI, VMTW,
     I        WZV,  PMM,  IMM,
     I        MH,   LH,   NZ,   LZ,  KZ0)
      endif
      RETURN
      END
CCC_ & MTButp - temperature update (preparation ii)
      subroutine MTButp
     O    (iErr,
     O     KTB,   NHt,
     M     VMTI,  VMTW, VMHI, VMHW,
     O     CW,
     I     VMHB,  PMM,  IMM,
     I     WW,    WZV,  DT,
     I     MH,    LH,   NZ,   LZ,   KZ0,
     I     ipCG,  LCG,  ipKW, iMA,  IFPl)
CCC_  - Declaration
      implicit none
c
      _INTENT(OUT,  integer)  iErr
c
      _INTENT(OUT,  integer)  NHt
      _INTENT(OUT,  integer)  KTB (LH, *)
c
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
      _INTENT(INOUT,_REALSTD) VMTW (LH, LZ, *)
      _INTENT(INOUT,_REALSTD) VMTI (LH, LZ, *)
      _INTENT(INOUT,_REALSTD) VMHW (LH, *)
      _INTENT(INOUT,_REALSTD) VMHI (LH, *)
      _INTENT(OUT,  _REALSTD) CW   (*)
c
      _INTENT(IN,   _REALSTD) VMHB (LH, *)
      _INTENT(IN,   _REALSTD) DT
      _INTENT(IN,   _REALSTD) PMM  (*)
      _INTENT(IN,   integer)  IMM  (*)
      _INTENT(IN,   _REALSTD) WZV  (*)
      _INTENT(IN,   _REALSTD) WW   (*)
      _INTENT(IN,   integer)  ipKW (*), iMA (*)
      _INTENT(IN,   integer)  LCG, ipCG (*)
      _INTENT(IN,   integer)  IFPl
c
      integer  KHH, KHB
      _REALSTD HC
CCC_  - Body
      iErr = 0
CCC_   . Table
      HC  = 0.0d0
c
      KHH = VMHI_nHa
      KHB = VMHI_nBa
c
      if (iErr.eq.0) then
         call MTStgp
     O       (iErr,
     O        KTB,   NHt,
     M        VMHW,  CW,
     I        VMHI,  WW,
     I        KHH,   KHB,
     I        HC,
     I        MH,    LH,  ipCG,  LCG, ipKW,  iMA)
      endif
      if (iErr.eq.0) then
         call MTSpjc
     O       (iErr,
     M        VMHW,
     I        VMHI,
     I        DT,
     I        KHH,   KTB,   NHt, MH,    LH)
      endif
      if (iErr.eq.0) then
         call MTStcg
     O       (iErr,
     O        VMTW,
     I        VMHW,
     I        KTB,  WZV,
     I        NHt,  LH,   NZ,  LZ, KZ0)
      endif
c
      if (iErr.eq.0) then
         if (IMM(IMD_WADV).eq. SW_WADV_RAW) then
            call MTScxs
     O          (iErr,
     M           VMTW,
     I           VMTI, VMHW, VMHI, VMHB,
     I           KTB,  WZV,  PMM,  IMM,
     I           NHt,  LH,   NZ,   LZ,  KZ0,
     I           IFPl)
         else
            call MTScxw
     O          (iErr,
     M           VMTW,
     I           VMTI, VMHW, VMHI, VMHB,
     I           KTB,  WZV,  PMM,  IMM,
     I           NHt,  LH,   NZ,   LZ,  KZ0,
     I           IFPl)
         endif
      endif
      if (iErr.eq.0) then
         call MTSdts
     O       (iErr,
     M        VMTW, CW,
     I        VMTI, VMHI,
     I        WW,
     I        KTB,  NHt,  MH,  LH,  NZ,   LZ,  KZ0,
     I        ipKW, iMA)
      endif
c
      RETURN
      END
CCC_ & MTBupd - temperature update (solver)
      subroutine MTBupd
     O    (iErr,
     M     VMTI,  VMTW, VMHI, VMHW,
     I     VMHB,  PMM,  IMM,
     I     WZV,   DT,
     I     KTB,   NHt,
     I     MH,    LH,   NZ,   LZ,   KZ0,
     I     IFPl)
CCC_  - Declaration
      implicit none
c
      _INTENT(OUT,  integer)  iErr
c
      _INTENT(OUT,  integer)  NHt
      _INTENT(OUT,  integer)  KTB (LH, *)
c
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
      _INTENT(INOUT,_REALSTD) VMTW (LH, LZ, *)
      _INTENT(INOUT,_REALSTD) VMTI (LH, LZ, *)
      _INTENT(INOUT,_REALSTD) VMHW (LH, *)
      _INTENT(INOUT,_REALSTD) VMHI (LH, *)
c
      _INTENT(IN,   _REALSTD) VMHB (LH, *)
      _INTENT(IN,   _REALSTD) DT
      _INTENT(IN,   _REALSTD) PMM  (*)
      _INTENT(IN,   integer)  IMM  (*)
      _INTENT(IN,   _REALSTD) WZV  (LZ, *)
      _INTENT(IN,   integer)  IFPl
c
      _REALSTD T0, CC
CCC_  * loop choice
#if    OPT_TZLP_METHOD == LOOP_CHOICE
#   define __LOOP IMM (IMD_TZLP)
#else
#   define __LOOP OPT_TZLP_METHOD
#endif
CCC_  - Body
      iErr = 0
c
#if DEBUG_MTTCOL_SPECIAL
      if (iErr.eq.0) then
         call MTTdbg_mtsbld
     O       (iErr,
     M        VMTW,
     I        VMTI, VMHW, VMHI, VMHB,
     I        KTB,  WZV,  PMM,  IMM, DT,
     I        NHt,  LH,   NZ,   LZ,  KZ0,
     I        IFPl)
      endif
#endif /* DEBUG_MTTCOL_SPECIAL */
      if (iErr.eq.0) then
         call MTSbld
     O       (iErr,
     M        VMTW,
     I        VMTI, VMHW, VMHI, VMHB,
     I        KTB,  WZV,  PMM,  IMM, DT,
     I        NHt,  LH,   NZ,   LZ,  KZ0,
     I        IFPl)
      endif
CCC_   + solver choices
      if (iErr.eq.0) then
         if (__LOOP .eq. SW_TZLP_OUTER) then
            call MUMtds
     O          (iErr,
     M           VMTW,
     W           VMHW (1, VMHW_W1),
     I           VMTW_W1,  VMTW_W2,
     I           VMTW_QU,  VMTW_QD, VMTW_QL, VMTW_QB,
     I           KTB, NHt, LH,  NZ, LZ,  KZ0,
     I           IFPl)
         else
            call MUMtdz
     O          (iErr,
     M           VMTW,
     W           VMHW (1, VMHW_W1),
     I           VMTW_W1,  VMTW_W2,
     I           VMTW_QU,  VMTW_QD, VMTW_QL, VMTW_QB,
     I           KTB, NHt, LH,  NZ, LZ,  KZ0,
     I           IFPl)
         endif
      endif
      if (iErr.eq.0) then
         call MTTzst
     O       (VMTW,
     I        VMHB,
     I        VMTW_W1,  KTB, NHt, MH, LH, NZ, LZ, KZ0)
      endif
#if DEBUG_MTSBLD
      call UV1cpc (VMTI, VMTW, MH, LH, NZ, LZ, KZ0, VMTI_T, VMTW_W1)
#else
      if (iErr.eq.0) then
         call MTFbwz
     O       (VMTI,  VMTI_T,
     I        VMTW,  VMTW_W1,
     I        KTB, NHt, MH, LH, NZ, LZ, KZ0)
      endif
#endif
      if (iErr.eq.0) then
         call MTBgta
     O       (iErr,
     M        VMTI,
     I        VMTW, VMHW, VMHI, VMHB,
     I        WZV,  PMM,  IMM,  DT,
     I        MH,   LH,   NZ,   LZ,  KZ0,
     I        IFPl)
      endif
      if (iErr.eq.0) then
         T0 = PMM (PMT_T0)
         CC = PMM (PMT_CLCLD)
         call MPPdtc
     M       (VMTI, VMTW,
     I        VMHI, WZV (1, VMVZ_cZa),
     I        T0,  CC,
     I        VMTI_T, VMTW_W1, VMHI_nHa, MH, LH, NZ, LZ, KZ0)
      endif
c
      RETURN
      END
CCC_ & MTBthc - Thermal conductivity
      subroutine MTBthc
     O    (iErr,
     O     VMTW,
     I     VMTI, CONDI, CONDIP,
     I     MH,   LH,    NZ,  LZ, KZ0)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
c
      _INTENT(INOUT,_REALSTD) VMTW (LH, LZ, *)
c
      _INTENT(IN,   _REALSTD) VMTI (LH, LZ, *)
c
      _INTENT(IN,   _REALSTD) CONDI, CONDIP
CCC_  . Body
      iErr = 0
      call MTFitc
     $    (VMTW(1, 1, VMTW_kti),
     $     VMTI(1, 1, VMTI_T), CONDI, CONDIP, MH, LH, NZ, LZ, KZ0)
      RETURN
      END
CCC_ & MTBgta - diag ghost temperature at bottom
      subroutine MTBgta
     O    (iErr,
     M     VMTI,
     I     VMTW, VMHW, VMHI, VMHB,
     I     WZV,  PMM,  IMM,  DT,
     I     MH,   LH,   NZ,   LZ,  KZ0,
     I     IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
c
      _INTENT(INOUT,_REALSTD) VMTI (LH, LZ, *)
      _INTENT(IN,   _REALSTD) VMTW (LH, LZ, *)
      _INTENT(IN,   _REALSTD) VMHW (LH, *)
      _INTENT(IN,   _REALSTD) VMHI (LH, *)
      _INTENT(IN,   _REALSTD) VMHB (LH, *)
c
      _INTENT(IN,   _REALSTD) PMM  (*)
      _INTENT(IN,   integer)  IMM  (*)
      _INTENT(IN,   _REALSTD) DT
      _INTENT(IN,   _REALSTD) WZV  (LZ, *)
c
      _INTENT(IN,   integer)  IFPl
c
      integer   kx
      integer   jh
      integer   jzz, jz
c
      _REALSTD  BU, BD, BL, BB
      _REALSTD  TKDD
      _REALSTD  DZDZ,  DPDZ
      _REALSTD  BDSWu, BDSWl
      _REALSTD  TBa, TBb
      _REALSTD  DLF
CCC_  - Body
      iErr  = 0
      KX = VMTI_T
CCC_   . loop interior
      DLF = (PMM(PMT_DENS) * PMM(PMT_LHC))
CCC_   . bottom
      if (IMM (IMD_TBDZ).eq. SW_TBDZ_CENTER) then
         BDSWl = 0.5d0
         BDSWu = 0.5d0
      else
         BDSWl = 1.0d0
         BDSWu = 0.0d0
      endif
      do    jzz = 1,  1
         jz = KZ0 + jzz - 1
         DPDZ  = WZV (jz, VMVZ_dXa)
         do jh = 1,  MH
            TBa   = VMHB (jh, VMHB_TBFLG)
            TBb   = 1.0d0 - TBa
            DZDZ  = VMHW (jh, VMHW_Hinv)
            TKDD  = VMTW (jh, jz, VMTW_kti) * DPDZ * DZDZ
            BU    = TKDD * BDSWu * WZV (jz,   VMVZ_dWPb)
            BL    = TKDD * BDSWl * WZV (jz-1, VMVZ_dWMb)
            BD    = TKDD *
     $           (BDSWu * WZV (jz,   VMVZ_dWMb)
     $           +BDSWl * WZV (jz-1, VMVZ_dWPb))
            BB    = VMHW (jh, VMHW_HSB)
     $           +  VMHI (jh, VMHI_bm) * DLF
            VMTI(jh, jz-1, KX) =
     $           TBb *
     $           ((BB - (BU*VMTI(jh,jz+1,KX)+BD*VMTI(jh,jz,KX)))/BL)
     $           + Tba * VMHB(jh, VMHB_TBI)
c$$$            if (jh.eq.6) then
c$$$               write(*, *) jh, BB, BU, BD, BL, VMTI(jh,jz-1:jz+1,KX)
c$$$            endif
         enddo
      enddo
      RETURN
      END
CCC_ & (obsolete) MTBgtb - diag ghost temperature at bottom
      subroutine MTBgtb
     O    (iErr,
     M     VMTW, KX,
     I     VMTI, VMHW, VMHI, VMHB,
     I     KTB,  WZV,  PMM,  IMM, DT,
     I     NH,   LH,   NZ,   LZ,  KZ0,
     I     IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  NH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
      _INTENT(IN,   integer)  KX
c
      _INTENT(INOUT,_REALSTD) VMTW (LH, LZ, *)
      _INTENT(IN,   _REALSTD) VMTI (LH, LZ, *)
      _INTENT(IN,   _REALSTD) VMHW (LH, *)
      _INTENT(IN,   _REALSTD) VMHI (LH, *)
      _INTENT(IN,   _REALSTD) VMHB (LH, *)
c
      _INTENT(IN,   integer)  KTB  (LH, *)
      _INTENT(IN,   _REALSTD) PMM  (*)
      _INTENT(IN,   integer)  IMM  (*)
      _INTENT(IN,   _REALSTD) DT
      _INTENT(IN,   _REALSTD) WZV  (LZ, *)
c
      _INTENT(IN,   integer)  IFPl
c
      integer   jh,  jht, jhti
      integer   jzz, jz
      integer   kfw, kbw
c
      _REALSTD  BU, BD, BL, BB
      _REALSTD  TKDD
      _REALSTD  DZDZ,  DPDZ
      _REALSTD  BDSWu, BDSWl
      _REALSTD  TBa, TBb
      _REALSTD  DLF
CCC_  - Body
      iErr  = 0
      kfw   = 1
      kbw   = 2
CCC_   . loop interior
      DLF = (PMM(PMT_DENS) * PMM(PMT_LHC))
CCC_   . bottom
      if (IMM (IMD_TBDZ).eq. SW_TBDZ_CENTER) then
         BDSWl = 0.5d0
         BDSWu = 0.5d0
      else
         BDSWl = 1.0d0
         BDSWu = 0.0d0
      endif
      do    jzz = 1,  1
         jz = KZ0 + jzz - 1
         DPDZ  = WZV (jz, VMVZ_dXa)
         do jht = 1,  NH
            jh = KTB (jht, kfw)
            jhti = jht
            TBa   = VMHB (jh, VMHB_TBFLG)
            TBb   = 1.0d0 - TBa
            DZDZ  = VMHW (jh, VMHW_Hinv)
            TKDD  = VMTW (jh, jz, VMTW_kti) * DPDZ * DZDZ
            BU    = TKDD * BDSWu * WZV (jz,   VMVZ_dWPb)
            BL    = TKDD * BDSWl * WZV (jz-1, VMVZ_dWMb)
            BD    = TKDD *
     $           (BDSWu * WZV (jz,   VMVZ_dWMb)
     $           +BDSWl * WZV (jz-1, VMVZ_dWPb))
            BB    = VMHW (jh, VMHW_HSB)
     $           +  VMHI (jh, VMHI_bm) * DLF
            VMTW(jht,jz - 1,KX) =
     $           TBb *
     $           ((BB - (BU*VMTW(jht,jz+1,KX)+BD*VMTW(jht,jz,KX)))/BL)
     $           + Tba * VMHB(jh, VMHB_TBI)
         enddo
      enddo
      RETURN
      END
CCC_ & MTBdbm - diagnose basal melting (similar method to MTBgtd)
      subroutine MTBdbm
     O    (iErr,
     M     VMHI, VMHW,
     I     VMTI, VMTW,
     I     WZV,  PMM,  IMM,
     I     MH,   LH,   NZ,   LZ,  KZ0)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
c
      _INTENT(INOUT,_REALSTD) VMHW (LH, *)
      _INTENT(INOUT,_REALSTD) VMHI (LH, *)
      _INTENT(IN,   _REALSTD) VMTW (LH, LZ, *)
      _INTENT(IN,   _REALSTD) VMTI (LH, LZ, *)
c
      _INTENT(IN,   _REALSTD) PMM  (*)
      _INTENT(IN,   integer)  IMM  (*)
      _INTENT(IN,   _REALSTD) WZV  (LZ, *)
c
      integer   jh,  jht, jhti
      integer   jzz, jz
      integer   kfw, kbw
      integer   kwhi, khh
      integer   KTT
c
      _REALSTD  BU, BD, BL, BB
      _REALSTD  TKDD
      _REALSTD  DZDZ,  DPDZ
      _REALSTD  BDSWu, BDSWl
      _REALSTD  DTF
      _REALSTD  DLD
      _REALSTD  T0, CC, P0
CCC_  - Body
      iErr = 0
c$$$      if (IMM (IMD_TBDZ).eq. SW_TBDZ_CENTER) then
c$$$         BDSWl = 0.5d0
c$$$         BDSWu = 0.5d0
c$$$      else
c$$$         BDSWl = 1.0d0
c$$$         BDSWu = 0.0d0
c$$$      endif
      if (IMM (IMD_BMTZ).eq. SW_BM_TBDZ_CENTER) then
         BDSWl = 0.5d0
         BDSWu = 0.5d0
      else
         BDSWl = 0.0d0
         BDSWu = 1.0d0
      endif
c
      khh  = VMHI_oHa
      kwhi = VMHW_W1
      ktt  = VMTI_T
c
      DLD = 1.0d0 / (PMM(PMT_DENS) * PMM(PMT_LHC))
c
      do jh = 1, MH
         if (VMHI(jh, KHH).le.0.0d0) then
            VMHW(jh, kwhi) = 0.0d0
         else
            VMHW(jh, kwhi) = 1.0d0 / VMHI(jh, KHH)
         endif
      enddo
      do    jzz = 1,  1
         jz = KZ0 + jzz - 1
         DPDZ  = WZV (jz, VMVZ_dXa)
         do jh = 1, MH
            DZDZ  = VMHW (jh, kwhi)
            TKDD  = VMTW (jh, jz, VMTW_kti) * DPDZ * DZDZ
            BU    = TKDD * BDSWu * WZV (jz,   VMVZ_dWPb)
            BL    = TKDD * BDSWl * WZV (jz-1, VMVZ_dWMb)
            BD    = TKDD *
     $           (BDSWu * WZV (jz,   VMVZ_dWMb)
     $           +BDSWl * WZV (jz-1, VMVZ_dWPb))
            BB    = VMHW (jh, VMHW_HSB)
            DTF = (BU * VMTI(jh, jz+1, ktt) + BL * VMTI(jh, jz-1, ktt))
     $           + BD * VMTI(jh, jz, ktt)
            VMHI(jh, VMHI_bm) = (DTF - BB) * DLD
c$$$            VMHI(jh, VMHI_bm) = (- BB) * DLD
c$$$            VMHI(jh, VMHI_bm) = (DTF) * DLD
         enddo
      enddo

      jz = KZ0 + 1 - 1
      T0 = PMM (PMT_T0)
      CC = PMM (PMT_CLCLD)
      P0 = 0.0d0
      call MPPmsk
     M    (VMHI, VMHI_bm, VMHI_oHa,
     I     P0,
     I     VMTI, VMTI_T,
     I     WZV(1, VMVZ_cZa), T0,  CC,
     I     MH,   LH,  JZ, LZ)
      return
      END
CCC_ & MTTzst - set skipped grids as surface temperature
      subroutine MTTzst
     O    (VMTW,
     I     VMHB,
     I     KTW,  KTB, NHt, MH, LH, NZ, LZ, KZ0)
CCC_  - Declaration
      implicit none
c
      _INTENT(IN, integer)  NHt
      _INTENT(IN, integer)  KTB (LH, *)
      _INTENT(IN, integer)  MH, LH
      _INTENT(IN, integer)  NZ, LZ, KZ0
      _INTENT(OUT,_REALSTD) VMTW (LH, LZ, *)
      _INTENT(IN, _REALSTD) VMHB (LH, *)
      _INTENT(IN, integer)  KTW
      integer  jh, jht
      integer  jz, jzz
      integer  kfw
CCC_  - Body
      kfw  = 1
      do jzz = 1, NZ
         jz = KZ0 + jzz - 1
         do jht = NHt + 1, MH
            jh = KTB (jht, kfw)
#if DEBUG_MTSBLD
            VMTW (jh,  jz, KTW) = VMHB (jh, VMHB_TSI)
#else
            VMTW (jht, jz, KTW) = VMHB (jh, VMHB_TSI)
#endif
         enddo
      enddo
      RETURN
      END
CCC_* kiwi
CCC_ & MTKcgr - clone gloup declaration
      subroutine MTKcgr
     O    (iErr,
     O     ipCG,
     W     kDTA,
     I     LTBL, LCG, LH, LCK, ipKW, IE, IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(IN, integer) LCG, LH, LCK, LTBL
      _INTENT(OUT,integer) ipCG (LCG, *)
      _INTENT(OUT,integer) kDTA  (LTBL, 3)
      _INTENT(IN, integer) ipKW (*), IE (*), IFPl
c
      integer    ko, kk, kwm
CCC_  - Body
      iErr = 0
c     ko 0 for one-time cloning
      ko   = 1
      kwm = KWM_M
CCC_   . group Ha
      kk = CGT_Ha
      if (iErr.eq.0) then
         call AKCgro (iErr, ipCG (1, kk), LCG, ko)
         call AKCgad (iErr, ipCG (1, kk), KWO_GXab, kwm, LCG)
         call AKCgad (iErr, ipCG (1, kk), KWO_GYac, kwm, LCG)
         call AKCgso
     O       (iErr, ko,    ipCG (1, kk),  kDTA,
     I        LCG,  LTBL,  LH,   ipKW, IE,   IFPl)
      endif
CCC_   . group Ba
      kk = CGT_Ba
      if (iErr.eq.0) then
         call AKCgro (iErr, ipCG (1, kk), LCG, ko)
         call AKCgad (iErr, ipCG (1, kk), KWO_GXab, kwm, LCG)
         call AKCgad (iErr, ipCG (1, kk), KWO_GYac, kwm, LCG)
         call AKCgso
     O       (iErr, ko,    ipCG (1, kk),  kDTA,
     I        LCG,  LTBL,  LH,   ipKW, IE,   IFPl)
      endif
CCC_   . group Ta
      kk = CGT_Ta
      if (iErr.eq.0) then
         ko   = 0
         call AKCgro (iErr, ipCG (1, kk), LCG, ko)
         call AKCgad (iErr, ipCG (1, kk), KWO_Lab,  kwm, LCG)
         call AKCgad (iErr, ipCG (1, kk), KWO_Lac,  kwm, LCG)
         call AKCgad (iErr, ipCG (1, kk), KWO_GXab, kwm, LCG)
         call AKCgad (iErr, ipCG (1, kk), KWO_GYac, kwm, LCG)
         call AKCgad (iErr, ipCG (1, kk), KWO_FCab, kwm, LCG)
         call AKCgad (iErr, ipCG (1, kk), KWO_FCac, kwm, LCG)
         call AKCgso
     O       (iErr, ko,    ipCG (1, kk),  kDTA,
     I        LCG,  LTBL,  LH,   ipKW, IE,   IFPl)
      endif
CCC_   . group Ta
      kk = CGT_CTB
      if (iErr.eq.0) then
         ko   = 0
         call AKCgro (iErr, ipCG (1, kk), LCG, ko)
         call AKCgad (iErr, ipCG (1, kk), KWO_FCab, kwm, LCG)
         call AKCgad (iErr, ipCG (1, kk), KWO_FCac, kwm, LCG)
         call AKCgso
     O       (iErr, ko,    ipCG (1, kk),  kDTA,
     I        LCG,  LTBL,  LH,   ipKW, IE,   IFPl)
      endif
c
      call DAtrcU (IFPl, iErr, 'R', 'MTKCGR')
      RETURN
      END
CCC_ & MTKodc - kiwi operator declaration
      subroutine MTKodc
     O    (iErr,
     M     ipKW,
     I     IFPl)
      implicit none
      _INTENT(OUT,  integer) iErr
      _INTENT(INOUT,integer) ipKW (*)
      _INTENT(IN,   integer) IFPl
      iErr = 0
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_GXab, KWM_M, IFPl)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_GYac, KWM_M, IFPl)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_FCba, KWM_M, IFPl)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_FCca, KWM_M, IFPl)
      RETURN
      END
CCC_* variation/V - Violet inheritance
CCC_* variation/N - Sally/NH[34] inheritance
CCC_* variation/S - Sally/NH2 inheritance
CCC_ & MTShsd - heating term computation (t:old) late interpolation
      subroutine MTShsd
     O    (iErr,
     O     VMTI,  VMHI, VMHW,
     M     VMTW,  CW,
     I     VMID,  WW,
     I     MH,    LH,   NZ,  LZ, KZ0, ipKW, iMA)
CCC_  - Description
CC      flow
CC           sxz:b   to  sxz:a
CC           syz:c   to  syz:a
CC           exz:b   to  exz:a
CC           eyz:c   to  eyz:a
CC           sh:sia  = sxz:a exz:a + syz:a eyz:a
CCC_  - Declaration
      implicit none
c
      _INTENT(OUT,  integer)  iErr
c
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
      _INTENT(INOUT,_REALSTD) VMHI (LH, *)
      _INTENT(INOUT,_REALSTD) VMHW (LH, *)
      _INTENT(INOUT,_REALSTD) VMTW (LH, LZ, *)
      _INTENT(INOUT,_REALSTD) VMTI (LH, LZ, *)
      _INTENT(OUT,  _REALSTD) CW   (*)
c
      _INTENT(IN,   _REALSTD) WW   (*)
      _INTENT(IN,   _REALSTD) VMID (LH, *)
      _INTENT(IN,   integer)  ipKW (*), iMA (*)
CCC_  - Body
      iErr = 0
CCC_   . xz:b
      call MTFshc
     M    (VMTW,
     I     VMTW_W1,
     I     VMTW_SXZb, VMTW_EXZb,
     I     MH,  LH,   NZ,  LZ, KZ0)
CCC_   . xz:a
      call AKBwaw
     M    (VMTW, CW,
     I     WW,
     I     MH,   LH,  NZ,  LZ,  KZ0, VMTW_W3x, VMTW_W1,
     I     ipKW, iMA, KWO_Lba,  KWM_M)
CCC_   . yz:c
      call MTFshc
     M    (VMTW,
     I     VMTW_W1,
     I     VMTW_SYZc, VMTW_EYZc,
     I     MH,  LH,   NZ,  LZ, KZ0)
CCC_   . yz:a
      call AKBwaw
     M    (VMTW, CW,
     I     WW,
     I     MH,   LH,  NZ,  LZ,  KZ0, VMTW_W3y, VMTW_W1,
     I     ipKW, iMA, KWO_Lca,  KWM_M)
CCC_   . shear:a
      call UV0nac
     M    (VMTW,
     I     MH,  LH, NZ, LZ, KZ0, VMTW_W1, VMTW_W3x, VMTW_W3y)
      call UV0uwc
     M    (VMTW,
     I     MH,  LH, NZ, LZ, KZ0, VMTW_W1, 2.0d0)
CCC_   . normal:a
      call MTFshs
     M    (VMTW,
     I     VMTW_W2,
     I     VMTW_SXXa, VMTW_SYYa, VMTW_SXYa,
     I     VMTW_EXXa, VMTW_EYYa, VMTW_EXYa,
     I     MH,  LH,   NZ,  LZ,   KZ0)
CCC_   . final
      call UV2nac
     M    (VMTI,
     I     VMTW,
     I     MH,  LH, NZ, LZ, KZ0, VMTI_sh, VMTW_W1, VMTW_W2)
CCC_   . frictional dissipation
#if 0 /* inconsistent timing */
      call MTFbfc
     M    (VMHW,
     I     VMTI,   VMTW,
     I     VMHW_W1,
     I     VMTI_UHb, VMTW_SXZb,
     I     MH,    LH,   NZ,    LZ, KZ0)
#else
      call MTFbfd
     M    (VMHW,
     I     VMTI,   VMID,
     I     VMHW_W1,
     I     VMTI_UHb, VMID_vBSXb,
     I     MH,    LH,   NZ,    LZ, KZ0)
#endif
      call AKBwax
     O    (VMHW, CW,
     I     WW,
     I     MH,   LH,  VMHW_W2,  VMHW_W1,
     I     ipKW, iMA, KWO_Lba,  KWM_M)
#if 0 /* inconsistent timing */
      call MTFbfc
     M    (VMHW,
     I     VMTI,   VMTW,
     I     VMHW_W1,
     I     VMTI_VHc, VMTW_SYZc,
     I     MH,    LH,   NZ,    LZ, KZ0)
#else
      call MTFbfd
     M    (VMHW,
     I     VMTI,   VMID,
     I     VMHW_W1,
     I     VMTI_VHc, VMID_vBSYc,
     I     MH,    LH,   NZ,    LZ, KZ0)
#endif
      call AKBwax
     O    (VMHW, CW,
     I     WW,
     I     MH,   LH,  VMHW_W3,  VMHW_W1,
     I     ipKW, iMA, KWO_Lca,  KWM_M)
      call UV2naa
     M    (VMHI,
     I     VMHW,
     I     MH,  LH, VMHI_frd, VMHW_W2, VMHW_W3)
      RETURN
      END
CCC_ & MTShst - heating term computation (t:old)  Sally compatible
      subroutine MTShst
     O    (iErr,
     O     VMTI,  VMHI,
     M     VMTW,  CW,
     I     VMID,  WW,
     I     MH,    LH,  NZ, LZ, KZ0, ipKW, iMA)
CCC_  - Description
CC      flow
CC           sxz:b   to  sxz:a
CC           syz:c   to  syz:a
CC           exz:b   to  exz:a
CC           eyz:c   to  eyz:a
CC           sh:sia  = sxz:a exz:a + syz:a eyz:a
CC      the basal drag timing may be inconsistent in addition,
CC      but consistent when using USG_SALLY to compute surface gradient
CC      for u diag.
CCC_  - Declaration
      implicit none
c
      _INTENT(OUT,  integer)  iErr
c
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
      _INTENT(INOUT,_REALSTD) VMHI (LH, *)
      _INTENT(INOUT,_REALSTD) VMTW (LH, LZ, *)
      _INTENT(INOUT,_REALSTD) VMTI (LH, LZ, *)
      _INTENT(OUT,  _REALSTD) CW   (*)
c
      _INTENT(IN,   _REALSTD) VMID (LH, *)
      _INTENT(IN,   _REALSTD) WW   (*)
      _INTENT(IN,   integer)  ipKW (*), iMA (*)
CCC_  - Body
      iErr = 0
CCC_   . interpolation sxz
      call AKBwaw
     M    (VMTW, CW,
     I     WW,
     I     MH,   LH,  NZ,  LZ,  KZ0, VMTW_SXZa, VMTW_SXZb,
     I     ipKW, iMA, KWO_Lba,  KWM_M)
CCC_   . interpolation exz
      call AKBwaw
     M    (VMTW, CW,
     I     WW,
     I     MH,   LH,  NZ,  LZ,  KZ0, VMTW_EXZa, VMTW_EXZb,
     I     ipKW, iMA, KWO_Lba,  KWM_M)
CCC_   . interpolation syz
      call AKBwaw
     M    (VMTW, CW,
     I     WW,
     I     MH,   LH,  NZ,  LZ,  KZ0, VMTW_SYZa, VMTW_SYZc,
     I     ipKW, iMA, KWO_Lca,  KWM_M)
CCC_   . interpolation eyz
      call AKBwaw
     M    (VMTW, CW,
     I     WW,
     I     MH,   LH,  NZ,  LZ,  KZ0, VMTW_EYZa, VMTW_EYZc,
     I     ipKW, iMA, KWO_Lca,  KWM_M)
CCC_   . strain heating intermediate SIA
      call MTFshi
     M    (VMTW,
     I     VMTW_W1,
     I     VMTW_SXZa, VMTW_SYZa,
     I     VMTW_EXZa, VMTW_EYZa,
     I     MH,  LH,   NZ,  LZ, KZ0)
CCC_   . todo SSA
      call MTFshs
     M    (VMTW,
     I     VMTW_W2,
     I     VMTW_SXXa, VMTW_SYYa, VMTW_SXYa,
     I     VMTW_EXXa, VMTW_EYYa, VMTW_EXYa,
     I     MH,  LH,   NZ,  LZ,   KZ0)
c$$$      call UV0stc
c$$$     M    (VMTW,
c$$$     I     MH,  LH, NZ, LZ, KZ0, VMTW_W2, 0.0d0)
CCC_   . final
      call UV2nac
     M    (VMTI,
     I     VMTW,
     I     MH,  LH, NZ, LZ, KZ0, VMTI_sh, VMTW_W1, VMTW_W2)
CCC_   . frictional dissipation
      call MTFbfr
     M    (VMHI,
     I     VMTI, VMTW,
     I     VMHI_frd,
     I     VMTI_UHa, VMTI_VHa, VMTW_SXZa, VMTW_SYZa,
     I     MH,  LH,  NZ,  LZ,  KZ0)
      RETURN
      END
CCC_ & MTShcs - specific heat capacity
      subroutine MTShcs
     O    (iErr,
     O     VMTW,
     I     VMTI,  PMM,
     I     MH,    LH,   NZ,  LZ, KZ0)
      implicit none
      _INTENT(OUT,  integer)  iErr
c
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
      _INTENT(INOUT,_REALSTD) VMTW (LH, LZ, *)
      _INTENT(IN,   _REALSTD) VMTI (LH, LZ, *)
      _INTENT(IN,   _REALSTD) PMM  (*)
CCC_  - Body
      iErr = 0
      if (iErr.eq.0) then
         call MTFhct
     $       (VMTW(1,1,VMTW_hcap),
     $        VMTI(1,1,VMTI_T),
     $        PMM(PMT_HCAP), PMM(PMT_HCAPG),
     $        MH,  LH,  NZ, LZ, KZ0)
      endif
      END
CCC_ & MTStgp - topography gradient preparation (t:new)
      subroutine MTStgp
     O    (iErr,
     O     KTB,   NH,
     M     VMHW,  CW,
     I     VMHI,  WW,
     I     KHH,   KHB,
     I     HC,
     I     MH,    LH,  ipCG,  LCG, ipKW,  iMA)
CCC_  - Description
CCC_   . Compatibility with Sally
CC  if OPT_THERMO_DZOLD == 0 /* DZ by new H (GA) */
CC    KHH = VMHI_ntHa
CC    KHB = VMHI_ntBa
CC  else                     /* DZ by old H (EA) */
CC    KHH = VMHI_otHa
CC    KHB = VMHI_otBa
CC
CCC_   . Todo
CC       Central difference (OPT_THERMO_ADV_DZCENTER == 1)
CC
CCC_  - Declaration
      implicit none
c
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  MH, LH, LCG
c
      _INTENT(OUT,  integer)  NH
      _INTENT(OUT,  integer)  KTB  (LH, *)
c
      _INTENT(INOUT,_REALSTD) VMHW (LH, *)
      _INTENT(IN,   _REALSTD) VMHI (LH, *)
      _INTENT(OUT,  _REALSTD) CW   (LH, *)
c
      _INTENT(IN,   _REALSTD) HC
      _INTENT(IN,   integer)  KHH, KHB
c
      _INTENT(IN,   _REALSTD) WW (*)
      _INTENT(IN,   integer)  ipCG (LCG, *)
      _INTENT(IN,   integer)  ipKW (*), iMA (*)
CCC_  - Body
      iErr = 0
CCC_   . build transformation table
      call MTFidv (KTB, NH,     VMHI, KHH, HC, MH, LH)
CCC_   . H:a operation
      call AKCgux
     O    (CW,
     I     VMHI, MH, LH, KHH,
     I     iMA,  ipCG (1, CGT_Ha))
CCC_    * gradient dH/dx:b
      call AKGwaz
     O    (VMHW (1, VMHW_W1),
     I     CW,  VMHI (1, KHH),  WW,
     I     MH,  LH,  ipKW, 1,  ipCG (1, CGT_Ha))
CCC_    * selection
      call MTSuws
     O    (iErr,
     M     VMHW,  CW,
     I     VMHI,
     I     VMHW_dHdx,  VMHW_W2,    VMHW_W1,
     I     VMHI_ADVXe, VMHI_ADVXw, KWO_FCba,
     I     KTB,   NH,
     I     MH,    LH,  ipKW,  iMA)
CCC_    * gradient dH/dy:c
      call AKGwaz
     O    (VMHW (1, VMHW_W1),
     I     CW,  VMHI (1, KHH),  WW,
     I     MH,  LH,  ipKW, 2,  ipCG (1, CGT_Ha))
CCC_    * selection
      call MTSuws
     O    (iErr,
     M     VMHW,  CW,
     I     VMHI,
     I     VMHW_dHdy,  VMHW_W2,    VMHW_W1,
     I     VMHI_ADVYn, VMHI_ADVYs, KWO_FCca,
     I     KTB,   NH,
     I     MH,    LH,  ipKW,  iMA)
CCC_   . B:a operation
      call AKCgux
     O    (CW,
     I     VMHI, MH, LH, KHB,
     I     iMA,  ipCG (1, CGT_Ba))
CCC_    * gradient db/dx:b
      call AKGwaz
     O    (VMHW (1, VMHW_W1),
     I     CW,  VMHI (1, KHB),  WW,
     I     MH,  LH,  ipKW, 1,  ipCG (1, CGT_Ba))
CCC_    * selection
      call MTSuws
     O    (iErr,
     M     VMHW,  CW,
     I     VMHI,
     I     VMHW_dBdx,  VMHW_W2,    VMHW_W1,
     I     VMHI_ADVXe, VMHI_ADVXw, KWO_FCba,
     I     KTB,   NH,
     I     MH,    LH,  ipKW,  iMA)
CCC_    * gradient db/dy:c
      call AKGwaz
     O    (VMHW (1, VMHW_W1),
     I     CW,  VMHI (1, KHB),  WW,
     I     MH,  LH,  ipKW, 2,  ipCG (1, CGT_Ba))
CCC_    * selection
      call MTSuws
     O    (iErr,
     M     VMHW,  CW,
     I     VMHI,
     I     VMHW_dBdy,  VMHW_W2,    VMHW_W1,
     I     VMHI_ADVYn, VMHI_ADVYs, KWO_FCca,
     I     KTB,   NH,
     I     MH,    LH,  ipKW,  iMA)
      RETURN
      END
CCC_ & MTSuws - upwind selection sub
      subroutine MTSuws
     O    (iErr,
     M     VW,    CW,
     I     VMHI,
     I     KWX,   KWC, KWS,
     I     KHU,   KHL, KOP,
     I     KTB,   NH,
     I     MH,    LH,  ipKW,  iMA)
CCC_  - Description
CCC_   . Compatibility with Sally
CC  if OPT_THERMO_DZOLD == 0 /* DZ by new H (GA) */
CC    KHH = VMHI_ntHa
CC    KHB = VMHI_ntBa
CC  else                     /* DZ by old H (EA) */
CC    KHH = VMHI_otHa
CC    KHB = VMHI_otBa
CC
CCC_   . Todo
CC       Central difference (OPT_THERMO_ADV_DZCENTER == 1)
CC
CCC_  - Declaration
      implicit none
c
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  MH, LH
c
      _INTENT(IN,  integer)   NH
      _INTENT(IN,  integer)   KTB  (LH, *)
c
      _INTENT(INOUT,_REALSTD) VW   (LH, *)
      _INTENT(IN,   _REALSTD) VMHI (LH, *)
      _INTENT(OUT,  _REALSTD) CW   (LH, *)
c
      _INTENT(IN,   integer)  KWX, KWC, KWS
      _INTENT(IN,   integer)  KHU, KHL
      _INTENT(IN,   integer)  KOP
c
      _INTENT(IN,   integer)  ipKW (*), iMA (*)
c
      integer  jh
CCC_  - Body
      iErr = 0
CCC_   . shift
      call AKBmex
     M    (VW,   CW,
     I     MH,   LH,  KWC, KWS,
     I     ipKW, iMA, KOP,    KWM_M)
CCC_   . result
      do jh = 1,  MH
         VW (jh, KWX) =
     $        +VMHI (jh, KHU) * VW (jh, KWS)
     $        +VMHI (jh, KHL) * VW (jh, KWC)
      enddo
c
      RETURN
      END
CCC_ & MTSuww - upwind selection (y)
      subroutine MTSuwy
     O    (iErr,
     M     VW,    CW,
     I     VI,    VMHI,
     I     KWX,   KWC, KIS,
     I     KHU,   KHL, KOP,
     I     KTB,   NH,
     I     MH,    LH,  NZ, LZ, KZ0, ipKW,  iMA)
CCC_  - Declaration
      implicit none
c
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
c
      _INTENT(IN,  integer)   NH
      _INTENT(IN,  integer)   KTB  (LH, *)
c
      _INTENT(INOUT,_REALSTD) VW   (LH, LZ, *)
      _INTENT(IN,   _REALSTD) VI   (LH, LZ, *)
      _INTENT(IN,   _REALSTD) VMHI (LH, *)
      _INTENT(OUT,  _REALSTD) CW   (LH, LZ, *)
c
      _INTENT(IN,   integer)  KWX, KWC, KIS
      _INTENT(IN,   integer)  KHU, KHL
      _INTENT(IN,   integer)  KOP
c
      _INTENT(IN,   integer)  ipKW (*), iMA (*)
c
      integer  jh
      integer  jz, jzz
CCC_  - Body
      iErr = 0
CCC_   . shift
      call AKBmey
     O    (VW (1, 1, KWC), CW,
     I     VI (1, 1, KIS),
     I     MH,   LH,  NZ,  LZ, KZ0,
     I     ipKW, iMA, KOP, KWM_M)
CCC_   . result
      do    jzz = 1, NZ
         jz = KZ0 + jzz - 1
         do jh = 1,  MH
            VW (jh, jz, KWX) =
     $           +VMHI (jh, KHU) * VI (jh, jz, KIS)
     $           +VMHI (jh, KHL) * VW (jh, jz, KWC)
         enddo
      enddo
c
      RETURN
      END
CCC_ & MTSpjc - derivative conversion coefficients preparation
      subroutine MTSpjc
     O    (iErr,
     M     VMHW,
     I     VMHI,
     I     DT,
     I     KHH,
     I     KTB,   NH,
     I     MH,    LH)
CCC_  - Declaration
      implicit none
c
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  MH, LH
c
      _INTENT(IN,   integer)  KHH
      _INTENT(IN,   integer)  NH
      _INTENT(IN,   integer)  KTB  (LH, *)
c
      _INTENT(INOUT,_REALSTD) VMHW (LH, *)
      _INTENT(IN,   _REALSTD) VMHI (LH, *)
      _INTENT(IN,   _REALSTD) DT
c
      integer   jh,  jht
      integer   kfw, kbw
CCC_  - Body
      iErr = 0
      kfw  = 1
      kbw  = 2
      do jht = 1, NH
         jh = KTB (jht, kfw)
c$$$         write (*, *) jht, NH, jh, VMHI (jh, KHH)
         VMHW (jh, VMHW_Hinv) = 1.0d0 / VMHI (jh, KHH)
         VMHW (jh, VMHW_dHdt) =
     $        (VMHI (jh, VMHI_nHa) - VMHI (jh, VMHI_oHa)) / DT
         VMHW (jh, VMHW_dBdt) =
     $        (VMHI (jh, VMHI_nBa) - VMHI (jh, VMHI_oBa)) / DT
      enddo
      RETURN
      END
CCC_ & MTScxs - equation coefficients  (temperature independent)
      subroutine MTScxs
     O    (iErr,
     M     VMTW,
     I     VMTI, VMHW, VMHI, VMHB,
     I     KTB,  WZV,  PMM,  IMM,
     I     NH,   LH,   NZ,   LZ,  KZ0,
     I     IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  NH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
c
      _INTENT(INOUT,_REALSTD) VMTW (LH, LZ, *)
      _INTENT(IN,   _REALSTD) VMTI (LH, LZ, *)
      _INTENT(IN,   _REALSTD) VMHW (LH, *)
      _INTENT(IN,   _REALSTD) VMHI (LH, *)
      _INTENT(IN,   _REALSTD) VMHB (LH, *)
c
      _INTENT(IN,   integer)  KTB  (LH, *)
      _INTENT(IN,   _REALSTD) PMM  (*)
      _INTENT(IN,   integer)  IMM  (*)
      _INTENT(IN,   _REALSTD) WZV  (LZ, *)
c
      _INTENT(IN,   integer)  IFPl
c
      integer   jh,  jht
      integer   jzz, jz
      integer   kfw, kbw
c
      _REALSTD  B0, B1, B2, B3, B33
      _REALSTD  D0, D1, D2, D3, D33
      _REALSTD  E3
c
      _REALSTD  DZDT, DZDX, DZDY, DZDZ, DDZDZ
      _REALSTD  DPDZ, DDPDZ
c
      _REALSTD  DENSI
      _REALSTD  TDC
CCC_  - Body
      iErr = 0
      kfw  = 1
      kbw  = 2
c
      DDZDZ = 0.0d0
      DENSI = PMM (PMT_DENS)
c$$$      CONDI = PMM (PMT_COND) * 31556926.0d0
c$$$      HCAPI = PMM (PMT_HCAP)
c
      do    jzz = 1, NZ - 1
         jz = KZ0 + jzz - 1
CCC_   . transformation factors (Z-[Z])
         DPDZ  = WZV (jz, VMVZ_dXa)
         DDPDZ = WZV (jz, VMVZ_ddXa)
         do jht = 1, NH
            jh = KTB (jht, kfw)
CCC_   . transformation factors (z-Z)
            DZDT = - (VMHW (jh, VMHW_dBdt)
     $               +VMHW (jh, VMHW_dHdt) * WZV (jz, VMVZ_Za))
     $             *  VMHW (jh, VMHW_Hinv)
            DZDX = - (VMHW (jh, VMHW_dBdx)
     $               +VMHW (jh, VMHW_dHdx) * WZV (jz, VMVZ_Za))
     $             *  VMHW (jh, VMHW_Hinv)
            DZDY = - (VMHW (jh, VMHW_dBdy)
     $               +VMHW (jh, VMHW_dHdy) * WZV (jz, VMVZ_Za))
     $             *  VMHW (jh, VMHW_Hinv)
            DZDZ = VMHW (jh, VMHW_Hinv)
CCC_   , density . capacity
            TDC = DENSI * VMTW(jh,jz,VMTW_hcap)
CCC_   . B0
            B0  = -1.0d0
CCC_   . Bi = - Ui + (1/rho c) dK/dxi
            B1  = - VMTI (jh, jz, VMTI_Uadv)
            B2  = - VMTI (jh, jz, VMTI_Vadv)
            B3  = - VMTI (jh, jz, VMTI_Wadv)
     $           + VMTW(jh, jz, VMTW_dktidz) / TDC
CCC_   . B33
c$$$            B33 = CONDI / (DENSI * HCAPI)
            B33 = VMTW(jh, jz, VMTW_kti) / TDC
CCC_   . D0 (not necessary)
CCC_   . D[12]
            D1  = B1
            D2  = B2
CCC_   . D3  = Bi   dZ/dxi + d^2 ZZ/dxi^2 Bii
            D3  =+(B0  * DZDT)
     $           +(B1  * DZDX + B2  * DZDY)
     $           +(B3  * DZDZ)
     $           +(B33 * DDZDZ)
CCC_   . D33 = Bii [dZ/dxi]^2
            D33 = B33 * (DZDZ * DZDZ)
CCC_   . E0 (not necessary)
CCC_   . E[12]
            VMTW (jh, jz, VMTW_E1) = D1
            VMTW (jh, jz, VMTW_E2) = D2
CCC_   . E3  = D3   d[Z]/dZ + D33 d^2[Z]/dZ^2
            E3 = +(D3  * DPDZ)
     $           +(D33 * DDPDZ)
CC       todo: central difference in vertical
            VMTW (jh, jz, VMTW_E3p) = MAX (0.0d0, E3)
            VMTW (jh, jz, VMTW_E3m) = MIN (0.0d0, E3)
CCC_   . E33 = D33 [d[Z]/dZ]^2
            VMTW (jh, jz, VMTW_E33) =
     $           + D33 * (DPDZ * DPDZ)
c$$$            write (*, *) 'B', jh, jz, B1, B2, B3, B33
c$$$            write (*, *) 'D', jh, jz, D1, D2, D3, D33
c$$$            write (*, *) 'BD',
c$$$     $           jh, jz, B33, D33, DZDZ, VMHI (jh, VMHI_nHa)
         enddo
      enddo
      RETURN
      END
CCC_ & MTScxw - equation coefficients, variation wadj (temperature independent)
      subroutine MTScxw
     O    (iErr,
     M     VMTW,
     I     VMTI, VMHW, VMHI, VMHB,
     I     KTB,  WZV,  PMM,  IMM,
     I     NH,   LH,   NZ,   LZ,  KZ0,
     I     IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  NH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
c
      _INTENT(INOUT,_REALSTD) VMTW (LH, LZ, *)
      _INTENT(IN,   _REALSTD) VMTI (LH, LZ, *)
      _INTENT(IN,   _REALSTD) VMHW (LH, *)
      _INTENT(IN,   _REALSTD) VMHI (LH, *)
      _INTENT(IN,   _REALSTD) VMHB (LH, *)
c
      _INTENT(IN,   integer)  KTB  (LH, *)
      _INTENT(IN,   _REALSTD) PMM  (*)
      _INTENT(IN,   integer)  IMM  (*)
      _INTENT(IN,   _REALSTD) WZV  (LZ, *)
c
      _INTENT(IN,   integer)  IFPl
c
      integer   jh,  jht
      integer   jzz, jz
      integer   kfw, kbw
c
      _REALSTD  B0, B1, B2, B33, B3, BZ
      _REALSTD  D0, D1, D2, D3,  D33
      _REALSTD  E3
c
      _REALSTD  DZDZ, DDZDZ
      _REALSTD  DPDZ, DDPDZ
c
      _REALSTD  DENSI, TDC
CCC_  - Body
      iErr = 0
      kfw  = 1
      kbw  = 2
c
      DDZDZ = 0.0d0
      DENSI = PMM (PMT_DENS)
c
      do    jzz = 1, NZ - 1
         jz = KZ0 + jzz - 1
CCC_   . transformation factors (Z-[Z])
         DPDZ  = WZV (jz, VMVZ_dXa)
         DDPDZ = WZV (jz, VMVZ_ddXa)
         do jht = 1, NH
            jh = KTB (jht, kfw)
CCC_   . transformation factors (z-Z)
            DZDZ = VMHW (jh, VMHW_Hinv)
CCC_   , density . capacity
            TDC = DENSI * VMTW(jh,jz,VMTW_hcap)
CCC_   . B0
            B0  = -1.0d0
CCC_   . Bi = - Ui + (1/rho c) dK/dxi
            B1  = - VMTI (jh, jz, VMTI_Uadv)
            B2  = - VMTI (jh, jz, VMTI_Vadv)
CCC_   . Bz
            BZ  = - VMTI (jh, jz, VMTI_Wadv) * DZDZ
CCC_   . B3
            B3  = + VMTW(jh, jz, VMTW_dktidz) / TDC
CCC_   . B33
            B33 = VMTW(jh, jz, VMTW_kti) / TDC
c$$$            B33 = CONDI / (DENSI * HCAPI)
CCC_   . D0 (not necessary)
CCC_   . D[12]
            D1  = B1
            D2  = B2
CCC_   . D3  = Bi   dZ/dxi + d^2 ZZ/dxi^2 Bii
            D3  =+ BZ
     $           +(B3  * DZDZ)
     $           +(B33 * DDZDZ)
CCC_   . D33 = Bii [dZ/dxi]^2
            D33 = B33 * (DZDZ * DZDZ)
CCC_   . E0 (not necessary)
CCC_   . E[12]
            VMTW (jh, jz, VMTW_E1) = D1
            VMTW (jh, jz, VMTW_E2) = D2
CCC_   . E3  = D3   d[Z]/dZ + D33 d^2[Z]/dZ^2
            E3 = +(D3  * DPDZ)
     $           +(D33 * DDPDZ)
CC       todo: central difference in vertical
            VMTW (jh, jz, VMTW_E3p) = MAX (0.0d0, E3)
            VMTW (jh, jz, VMTW_E3m) = MIN (0.0d0, E3)
CCC_   . E33 = D33 [d[Z]/dZ]^2
            VMTW (jh, jz, VMTW_E33) =
     $           + D33 * (DPDZ * DPDZ)
         enddo
      enddo
      RETURN
      END
CCC_ & MTStcg - Thermal conductivity gradient
      subroutine MTStcg
     O    (iErr,
     O     VMTW,
     I     VMHW,
     I     KTB,  WZV,
     I     NH,   LH,    NZ,  LZ, KZ0)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  NH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
c
      _INTENT(INOUT,_REALSTD) VMTW (LH, LZ, *)
c
      _INTENT(IN,   integer)  KTB  (LH, *)
      _INTENT(IN,   _REALSTD) VMHW (LH, *)
      _INTENT(IN,   _REALSTD) WZV  (LZ, *)
c
      integer   jh,  jht
      integer   jzz, jz
      integer   kfw, kbw
c
      _REALSTD  du, dl, da
      _REALSTD  DPDZ, DZDZ
CCC_  . Body
      iErr = 0
      kfw  = 1
      kbw  = 2
c
      do jzz = 1, NZ
         jz = KZ0 + jzz - 1
         do jht = 1, NH
            jh = KTB (jht, kfw)
            VMTW(jh, jz, VMTW_dktidz) =
     $           ( VMTW(jh,jz,  VMTW_kti) * WZV(jz-1,VMVZ_dWPb)
     $           + VMTW(jh,jz-1,VMTW_kti) * WZV(jz-1,VMVZ_dWMb))
         enddo
      enddo
      do jzz = 1, NZ - 1
         jz = KZ0 + jzz - 1
         du = WZV(jz,  VMVZ_dZb)
         dl = WZV(jz-1,VMVZ_dZb)
         da = du + dl
         du = du / da
         dl = dl / da
         DPDZ  = WZV (jz, VMVZ_dXa)
         do jht = 1, NH
            jh = KTB (jht, kfw)
            DZDZ  = VMHW (jh, VMHW_Hinv)
            VMTW(jh, jz, VMTW_dktidz) =
     $           ( VMTW(jh, jz,   VMTW_dktidz) * du
     $           + VMTW(jh, jz+1, VMTW_dktidz) * dl)
     $           * DPDZ * DZDZ
         enddo
      enddo
      do jzz = NZ, NZ
         jz = KZ0 + jzz - 1
         DPDZ  = WZV (jz, VMVZ_dXa)
         do jht = 1, NH
            jh = KTB (jht, kfw)
            DZDZ  = VMHW (jh, VMHW_Hinv)
            VMTW(jh, jz, VMTW_dktidz) =
     $           VMTW(jh, jz, VMTW_dktidz) * DPDZ * DZDZ
         enddo
      enddo
      RETURN
      END
CCC_ & MTSdts - equation coefficients  (temperature derivatives)
      subroutine MTSdts
     O    (iErr,
     M     VMTW, CW,
     I     VMTI, VMHI,
     I     WW,
     I     KTB,  NH,   MH,  LH,  NZ,   LZ,  KZ0,
     I     ipKW, iMA)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  NH, KTB  (LH, *)
      _INTENT(IN,   integer)  NZ, LZ, KZ0
c
      _INTENT(OUT,  _REALSTD) CW   (LH, LZ, *)
c
      _INTENT(INOUT,_REALSTD) VMTW (LH, LZ, *)
      _INTENT(IN,   _REALSTD) VMTI (LH, LZ, *)
      _INTENT(IN,   _REALSTD) VMHI (LH, *)
      _INTENT(IN,   _REALSTD) WW  (*)
      _INTENT(IN,   integer)  ipKW (*), iMA (*)
CCC_  - Body
      iErr = 0
      call MTSuwy
     O    (iErr,
     M     VMTW,  CW,
     I     VMTI,  VMHI,
     I     VMTW_dTdXa, VMTW_W2,    VMTI_dTdXb,
     I     VMHI_ADVXe, VMHI_ADVXw, KWO_FCba,
     I     KTB,   NH,
     I     MH,    LH,  NZ, LZ, KZ0, ipKW,  iMA)
      call MTSuwy
     O    (iErr,
     M     VMTW,  CW,
     I     VMTI,  VMHI,
     I     VMTW_dTdYa, VMTW_W2,    VMTI_dTdYc,
     I     VMHI_ADVYn, VMHI_ADVYs, KWO_FCca,
     I     KTB,   NH,
     I     MH,    LH,  NZ, LZ, KZ0, ipKW,  iMA)
c
      RETURN
      END
CCC_ & MTSbld - matrix builder core (temperature dependent)
      subroutine MTSbld
     O    (iErr,
     M     VMTW,
     I     VMTI, VMHW, VMHI, VMHB,
     I     KTB,  WZV,  PMM,  IMM, DT,
     I     NH,   LH,   NZ,   LZ,  KZ0,
     I     IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  NH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
c
      _INTENT(INOUT,_REALSTD) VMTW (LH, LZ, *)
      _INTENT(IN,   _REALSTD) VMTI (LH, LZ, *)
      _INTENT(IN,   _REALSTD) VMHW (LH, *)
      _INTENT(IN,   _REALSTD) VMHI (LH, *)
      _INTENT(IN,   _REALSTD) VMHB (LH, *)
c
      _INTENT(IN,   integer)  KTB  (LH, *)
      _INTENT(IN,   _REALSTD) PMM  (*)
      _INTENT(IN,   integer)  IMM  (*)
      _INTENT(IN,   _REALSTD) DT
      _INTENT(IN,   _REALSTD) WZV  (LZ, *)
c
      _INTENT(IN,   integer)  IFPl
c
      integer   jh,  jht, jhti
      integer   jzz, jz
      integer   kfw, kbw
c
      _REALSTD  E0, E0DT
      _REALSTD  BU, BD, BL, BB
      _REALSTD  QU, QD, QL, QB
      _REALSTD  TKDD
      _REALSTD  DZDZ,  DPDZ
      _REALSTD  BDSWu, BDSWl
c$$$      _REALSTD  CONDI
      _REALSTD  TBa, TBb
CCC_  - Body
      iErr  = 0
      kfw   = 1
      kbw   = 2
      E0    = -1.0d0
      E0DT  = E0 / DT
c$$$      CONDI = PMM (PMT_COND)
CCC_   . loop interior
      do    jzz = 1, NZ - 1
         jz = KZ0 + jzz - 1
         do jht = 1, NH
            jh = KTB (jht, kfw)
#           if DEBUG_MTSBLD
            jhti = jh
#           else
            jhti = jht
#           endif
            VMTW (jhti, jz, VMTW_QU) =
     $           +WZV (jz,   VMVZ_ddWPa)  * VMTW (jh, jz, VMTW_E33)
     $           +WZV (jz,   VMVZ_dWPb)   * VMTW (jh, jz, VMTW_E3p)
            VMTW (jhti, jz, VMTW_QL) =
     $           +WZV (jz,   VMVZ_ddWMa)  * VMTW (jh, jz, VMTW_E33)
     $           +WZV (jz-1, VMVZ_dWMb)   * VMTW (jh, jz, VMTW_E3m)
            VMTW (jhti, jz, VMTW_QD) =
     $           + WZV (jz,   VMVZ_ddWOa) * VMTW (jh, jz, VMTW_E33)
     $           +(WZV (jz,   VMVZ_dWMb)  * VMTW (jh, jz, VMTW_E3p)
     $            +WZV (jz-1, VMVZ_dWPb)  * VMTW (jh, jz, VMTW_E3m))
     $           + E0DT
            VMTW (jhti, jz, VMTW_QB) =
     $           + E0DT * VMTI (jh, jz, VMTI_T)
     $           -(VMTW (jh, jz, VMTW_E1) * VMTW (jh, jz, VMTW_dTdXa)
     $            +VMTW (jh, jz, VMTW_E2) * VMTW (jh, jz, VMTW_dTdYa))
     $           - VMTW (jh, jz, VMTW_HS)
         enddo
      enddo
CCC_   . bottom
      if (IMM (IMD_TBDZ).eq. SW_TBDZ_CENTER) then
         BDSWl = 0.5d0
         BDSWu = 0.5d0
      else
         BDSWl = 1.0d0
         BDSWu = 0.0d0
      endif
      do    jzz = 1,  1
         jz = KZ0 + jzz - 1
         DPDZ  = WZV (jz, VMVZ_dXa)
         do jht = 1,  NH
            jh = KTB (jht, kfw)
#           if DEBUG_MTSBLD
            jhti = jh
#           else
            jhti = jht
#           endif
            TBa   = VMHB (jh, VMHB_TBFLG)
            TBb   = 1.0d0 - TBa
            DZDZ  = VMHW (jh, VMHW_Hinv)
c$$$            TKDD  = CONDI * DPDZ * DZDZ
            TKDD  = VMTW (jh, jz, VMTW_kti) * DPDZ * DZDZ
            BU    = TKDD * BDSWu * WZV (jz,   VMVZ_dWPb)
            BL    = TKDD * BDSWl * WZV (jz-1, VMVZ_dWMb)
            BD    = TKDD *
     $           (BDSWu * WZV (jz,   VMVZ_dWMb)
     $           +BDSWl * WZV (jz-1, VMVZ_dWPb))
            BB    = VMHW (jh, VMHW_HSB)
            QU    = VMTW (jhti, jz, VMTW_QU)
            QL    = VMTW (jhti, jz, VMTW_QL)
            QD    = VMTW (jhti, jz, VMTW_QD)
            QB    = VMTW (jhti, jz, VMTW_QB)
c$$$            write (*, *) jh, jht,
c$$$     $           WZV (jz,   VMVZ_dWPb),WZV (jz,   VMVZ_dWMb),
c$$$     $           WZV (jz-1, VMVZ_dWPb),WZV (jz-1, VMVZ_dWMb)
c$$$            write (*, *) jh, jht, DPDZ, DZDZ, TKDD
c$$$            write (*, *) jh, jht, BU, BL, BD
c$$$            write (*, *) jh, jht, BU, BL, BD, BB, QU, QL, QD, QB
            VMTW (jhti, jz, VMTW_QU) = (QU * BL - QL * BU) * TBb
            VMTW (jhti, jz, VMTW_QD) = (QD * BL - QL * BD) * TBb + TBa
            VMTW (jhti, jz, VMTW_QB) = (QB * BL - QL * BB) * TBb
     $           + Tba * VMHB(jh, VMHB_TBI)
            VMTW (jhti, jz, VMTW_QL) = 0.0d0
         enddo
      enddo
CCC_   . surface
      do    jzz = NZ, NZ
         jz = KZ0 + jzz - 1
         do jht = 1,  NH
            jh = KTB (jht, kfw)
#           if DEBUG_MTSBLD
            jhti = jh
#           else
            jhti = jht
#           endif
            VMTW (jhti, jz, VMTW_QU) = 0.0d0
            VMTW (jhti, jz, VMTW_QL) = 0.0d0
            VMTW (jhti, jz, VMTW_QD) = E0DT * 1.0d0
c$$$            write (*, *) jh, VMHB (jh, VMHB_TSI)
            VMTW (jhti, jz, VMTW_QB) = E0DT * VMHB (jh, VMHB_TSI)
         enddo
      enddo
      RETURN
      END
CCC_& MTTCOL - Movement/Thermodynamics announcement
      subroutine MTTCOL (STRA, STRB, IOP)
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
CCC_ + begin
#if     TEST_MTTCOL
CCC_ @ MTTTST - Movement/Thermodynamics test program
#include "ofnstd.h"
#include "odevid.h"  /* MPI table */
      program MTTTST
CCC_  - Test suites
CC::   SOURCES mtfunc.F mppmth.F mumcol.F
CCC_  - Declaration
      implicit none
      integer iErr
      integer ipA (LOG_CHANNEL_MAX)
      integer iMA (MAX_MPI_ATTR)
CCC_  - Body
      call DDcapo
     O    (iErr,
     I     2, ' ', 'O', _FNAME, -1)
      if (iErr.eq.0) then
         call DLCmng (ipA, 't')
         call DVHrgC (iErr, MOVEMENT_DV_CLS, ' ', ' ', ipA)
      endif
      if (iErr.eq.0) then
         call DMAtma (iMA)
         call MTTtestMain (iErr, ipA, iMA)
         call ACCrep (FPL(ipA), 0)
      endif
      call DevFin (iErr)
      STOP
      END
CCC_ & MTTtestMain - main
      subroutine MTTtestMain (iErr, ipA, iMA)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(IN, integer) ipA (*)
      _INTENT(IN, integer) iMA (*)
CCC_  - Body
      iErr = 0
      RETURN
      END
CCC_ + end
#endif  /* TEST_MTTCOL */
CCC_* obsolete
CCC_ + begin
#if 0 /* obsolete */
CCC_ & MTSpvs - velocity/upwind switch preparation (t:old)
      subroutine MTSpvs
     O    (iErr,
     M     VMTI,  VMHI,
     W     VMTW,  CW,
     I     VV,    KVU,   KVV,  KVW,
     I     WO,    WA,
     I     KTB,   NH,
     I     MH,    LH,    NZ,   LZ,  KZ0,
     I     ipKW,  iMA)
CCC_  - Declaration
      implicit none
c
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  MH,   LH
      _INTENT(IN,   integer)  NH
      _INTENT(IN,   integer)  KTB  (LH, *)
      _INTENT(IN,   integer)  NZ,   LZ, KZ0
c
      _INTENT(INOUT,_REALSTD) VMHI (LH, *)
      _INTENT(INOUT,_REALSTD) VMTI (LH, LZ, *)
c
      _INTENT(OUT,  _REALSTD) CW   (LH, LZ, *)
      _INTENT(OUT,  _REALSTD) VMTW (LH, LZ, *)
c
      _INTENT(IN,   _REALSTD) VV   (LH, LZ, *)
      _INTENT(IN,   integer)  KVU, KVV, KVW
c
      _INTENT(IN,   _REALSTD) WO   (*), WA  (*)
      _INTENT(IN,   integer)  ipKW (*), iMA (*)
c
      integer   jh
      integer   jzz, jz
CCC_  - Body
      iErr = 0
CCC_   . U  Xswitch
      call MTSsvs
     O    (iErr,
     M     VMTI,   VMHI,
     W     VMTW,   CW,
     I     VV,
     I     VMTI_Uadv,  VMHI_ADVXe,  VMHI_ADVXw,
     I     KVU,     KWO_FCba,
     I     KTB, NH, MH, LH, NZ, LZ, KZ0, ipKW, iMA)
CCC_   . V  Yswitch
      call MTSsvs
     O    (iErr,
     M     VMTI,   VMHI,
     W     VMTW,   CW,
     I     VV,
     I     VMTI_Vadv,  VMHI_ADVYn,  VMHI_ADVYs,
     I     KVV,     KWO_FCca,
     I     KTB, NH, MH, LH, NZ, LZ, KZ0, ipKW, iMA)
CCC_   . W
      do    jzz = 2, NZ
         jz = KZ0 + jzz - 1
         do jh = 1,  MH
            VMTI (jh, jz, VMTI_Wadv) =
     $           VV (jh, jz, KVW) + VV (jh, KZ0, KVW)
         enddo
      enddo
      do    jzz = 1, 1
         jz = KZ0 + jzz - 1
         do jh = 1,  MH
            VMTI (jh, jz, VMTI_Wadv) = VV (jh, jz, KVW)
         enddo
      enddo
c$$$      MO   = KZ0 + NZ - 1
c$$$      LO   = LZ
c$$$CCC_   . u
c$$$      call AKBmez
c$$$     O    (VMTW (1, 1, VMTW_W1), CW,
c$$$     I     VV   (1, 1, KVU),
c$$$     I     MH,   LH,  MO,
c$$$     I     ipKW, iMA, KWO_FCba, KWM_M)
c$$$CCC_   . compute switch
c$$$      do jh = 1, MH
c$$$         tu = VV   (jh, KZ0 + NZ - 1, KVU)     + VV   (jh, KZ0, KVU)
c$$$         tl = VMTW (jh, KZ0 + NZ - 1, VMTW_W1) + VMTW (jh, KZ0, VMTW_W1)
c$$$         if       (tu.gt.0.0d0 .and. tl.gt.0.0d0) then
c$$$            fu = 0.0d0
c$$$            fl = 1.0d0
c$$$         else if  (tu.lt.0.0d0 .and. tl.lt.0.0d0) then
c$$$            fu = 1.0d0
c$$$            fl = 0.0d0
c$$$         else
c$$$            fu = 0.0d0
c$$$            fl = 0.0d0
c$$$         endif
c$$$         VMHW (jh, VMHW_ADVXe) = fu
c$$$         VMHW (jh, VMHW_ADVXw) = fl
c$$$      enddo
c$$$CCC_   . compute velocity used for advection
c$$$      do    jzz = 2, NZ
c$$$         jz = KZ0 + jzz - 1
c$$$         do jh = 1,  MH
c$$$            tu = VV   (jh, jz, KVU)     + VV   (jh, KZ0, KVU)
c$$$            tl = VMTW (jh, jz, VMTW_W1) + VMTW (jh, KZ0, VMTW_W1)
c$$$            VMTI (jh, jz, VMTI_U) =
c$$$     $           +VMHW (jh, VMHW_ADVXe) * tu
c$$$     $           +VMHW (jh, VMHW_ADVXw) * tl
c$$$         enddo
c$$$      enddo
      RETURN
      END
CCC_ & MTSsvs - velocity/upwind switch preparation (sub)
      subroutine MTSsvs
     O    (iErr,
     M     VMTI,  VMHI,
     W     VMTW,  CW,
     I     VV,
     I     KTV,   KHU,   KHL,  KVV, KOP,
     I     KTB,   NH,
     I     MH,    LH,    NZ,   LZ,  KZ0,
     I     ipKW,  iMA)
CCC_  - Declaration
      implicit none
c
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  MH,   LH
      _INTENT(IN,   integer)  NH
      _INTENT(IN,   integer)  KTB  (LH, *)
      _INTENT(IN,   integer)  NZ,   LZ, KZ0
c
      _INTENT(INOUT,_REALSTD) VMTI (LH, LZ, *)
      _INTENT(INOUT,_REALSTD) VMHI (LH, *)
c
      _INTENT(OUT,  _REALSTD) CW   (LH, LZ, *)
      _INTENT(OUT,  _REALSTD) VMTW (LH, LZ, *)
c
      _INTENT(IN,   _REALSTD) VV   (LH, LZ, *)
c
      _INTENT(IN,   integer)  KTV
      _INTENT(IN,   integer)  KHU, KHL
      _INTENT(IN,   integer)  KVV
      _INTENT(IN,   integer)  KOP
c
      _INTENT(IN,   integer)  ipKW (*), iMA (*)
c
      integer   MO,  LO
      integer   jh,  jht
      integer   jzz, jz
      integer   kfw, kbw
      _REALSTD  tu,  tl
      _REALSTD  fu,  fl
CCC_  - Body
      iErr = 0
      MO   = KZ0 + NZ - 1
      LO   = LZ
CCC_   . clone
      call AKBmez
     O    (VMTW (1, 1, VMTW_W1), CW,
     I     VV   (1, 1, KVV),
     I     MH,   LH,  MO,
     I     ipKW, iMA, KOP, KWM_M)
CCC_   . compute switch
CC       todo: OPT_THERMO_ADV_STAGGERED
      do jh = 1, MH
         tu = VV   (jh, KZ0 + NZ - 1, KVV)     + VV   (jh, KZ0, KVV)
         tl = VMTW (jh, KZ0 + NZ - 1, VMTW_W1) + VMTW (jh, KZ0, VMTW_W1)
         if       (tu.gt.0.0d0 .and. tl.gt.0.0d0) then
            fu = 0.0d0
            fl = 1.0d0
         else if  (tu.lt.0.0d0 .and. tl.lt.0.0d0) then
            fu = 1.0d0
            fl = 0.0d0
         else
            fu = 0.0d0
            fl = 0.0d0
         endif
         VMHI (jh, KHU) = fu
         VMHI (jh, KHL) = fl
      enddo
CCC_   . compute velocity used for advection
      do    jzz = 2, NZ
         jz = KZ0 + jzz - 1
         do jh = 1,  MH
            tu = VV   (jh, jz, KVV)     + VV   (jh, KZ0, KVV)
            tl = VMTW (jh, jz, VMTW_W1) + VMTW (jh, KZ0, VMTW_W1)
            VMTI (jh, jz, KTV) =
     $           +VMHI (jh, KHU) * tu
     $           +VMHI (jh, KHL) * tl
         enddo
      enddo
      do    jzz = 1, 1
         jz = KZ0 + jzz - 1
         do jh = 1,  MH
            tu = VV   (jh, jz, KVV)
            tl = VMTW (jh, jz, VMTW_W1)
            VMTI (jh, jz, KTV) =
     $           +VMHI (jh, KHU) * tu
     $           +VMHI (jh, KHL) * tl
         enddo
      enddo
CCC_   . return
      RETURN
      END
c$$$CCC_ & MTSbld - matrix builder core
c$$$      subroutine MTSbld
c$$$     O    (iErr,
c$$$     W     KTB,
c$$$     M     VMTW,
c$$$     I     VMTI, VMHW, VMHI,
c$$$     I     WZV,  PMM,  DT,
c$$$     I     NH,   LH,   NZ, LZ, KZ0,
c$$$     I     IFPl)
c$$$CCC_  - Declaration
c$$$      implicit none
c$$$      _INTENT(OUT,  integer)  iErr
c$$$      _INTENT(IN,   integer)  NH, LH
c$$$      _INTENT(IN,   integer)  NZ, LZ, KZ0
c$$$c
c$$$      _INTENT(OUT,  _REALSTD) KTB  (LH, *)
c$$$c
c$$$      _INTENT(INOUT,_REALSTD) VMTW (LH, LZ, *)
c$$$      _INTENT(IN,   _REALSTD) VMTI (LH, LZ, *)
c$$$      _INTENT(IN,   _REALSTD) VMHW (LH, *)
c$$$      _INTENT(IN,   _REALSTD) VMHI (LH, *)
c$$$c
c$$$      _INTENT(IN,   _REALSTD) PMM  (*)
c$$$      _INTENT(IN,   _REALSTD) DT
c$$$      _INTENT(IN,   _REALSTD) WZV  (LZ, *)
c$$$c
c$$$      _INTENT(IN,   integer)  IFPl
c$$$c
c$$$      integer   jh, jzz, jz
c$$$c
c$$$      _REALSTD  DENS
c$$$CCC_  - Body
c$$$      iErr = 0
c$$$CCC_   . parameters
c$$$      DENS   = PMM (PMD_DENS)
c$$$CCC_   . ax (coefficients ddT/dXX)
c$$$CCC_   . ay (coefficients ddT/dYY)
c$$$CCC_   . b  (coefficients ddT/dZZ)
c$$$#if 0
c$$$      call MTFscb
c$$$     M    (VMTW,
c$$$     I     VMHW, DENS,
c$$$     I     VMTW_CFB,   VMTW_TC,  VMTW_HC,  VMHW_DZZDZ,
c$$$     I     NH,   LH,   NZ,  LZ,  KZ0)
c$$$CCC_   . dx (coefficients dT/dX)
c$$$      call MTFscd
c$$$     M    (VMTW,
c$$$     I     VMHW,
c$$$     I     VMTW_CFDx,
c$$$     I     VMTW_UADVe, VMTW_UADVw,
c$$$     I     VMHW_ADVXe, VMHW_ADVXw,
c$$$     I     NH,   LH,   NZ,  LZ,  KZ0)
c$$$CCC_   . dy (coefficients dT/dY)
c$$$      call MTFscd
c$$$     M    (VMTW,
c$$$     I     VMHW,
c$$$     I     VMTW_CFDy,
c$$$     I     VMTW_VADVn, VMTW_VADVs,
c$$$     I     VMHW_ADVYn, VMHW_ADVYs,
c$$$     I     NH,   LH,   NZ,  LZ,  KZ0)
c$$$CCC_   . e  (coefficients dT/dZ)
c$$$      call MTFsce
c$$$     M    (VMTW,
c$$$     I     VMHW,
c$$$     I     VMTW_CFE,
c$$$     I     VMTW_
c$$$     I     VMHW_DHDT,  VMHW_DBDT, VMHW_DZH,
c$$$     I     NH,   LH,   NZ,  LZ,  KZ0)
c$$$CCC_   . f
c$$$      call MTFscf
c$$$     M    (VMTW,
c$$$     I     VMHW, DENS,
c$$$     I     VMTW_CFF,
c$$$     I     VMTW_SH,    VMTW_HC,
c$$$     I     NH,   LH,   NZ,  LZ,  KZ0)
c$$$#endif
c$$$CCC_   . loop interior
c$$$      do    jzz = 1, NZ - 1
c$$$         jz = KZ0 + jzz
c$$$         do jh  = 1, NH
c$$$         enddo
c$$$      enddo
c$$$CCC_   . surface
c$$$      do    jzz = NZ, NZ
c$$$         jz = KZ0 + jzz
c$$$         do jh  = 1,  NH
c$$$         enddo
c$$$      enddo
c$$$CCC_   . bottom
c$$$      do    jzz = 1, 1
c$$$         jz = KZ0 + jzz
c$$$         do jh  = 1, NH
c$$$         enddo
c$$$      enddo
c$$$CCC_   . end
c$$$      RETURN
c$$$      END
CCC_ & MTSslv - matrix solver core (z outer)
      subroutine MTSslv
     O    (iErr,
     M     VX,
     W     W,
     I     KX,   KW,   KU,   KD,  KL,  KB,
     I     KTB,  NH,   LH,   NZ,  LZ,  KZ0,
     I     IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  NH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
      _INTENT(INOUT,_REALSTD) VX (LH, LZ, *)
      _INTENT(INOUT,_REALSTD) W  (*)
      _INTENT(IN,   integer)  KTB (LH, *)
      _INTENT(IN,   integer)  KX, KW
      _INTENT(IN,   integer)  KU, KD, KL, KB
      _INTENT(IN,   integer)  IFPl
c
      integer   jh
      integer   jzz, jz
#if DEBUG_MTSBLD
      integer   jht
      integer   kfw
#endif
CCC_  - Body
      iErr  = 0
c
#if DEBUG_MTSBLD
      kfw   = 1
      do jht = 1, NH
         jh = KTB (jht, kfw)
         W  (jh) = VX (jh, KZ0, KD)
         VX (jh, KZ0, KX) = VX (jh, KZ0, KB) / W (jh)
      enddo
#else
      do jh = 1, NH
         W  (jh) = VX (jh, KZ0, KD)
         VX (jh, KZ0, KX) = VX (jh, KZ0, KB) / W (jh)
      enddo
#endif
c
      do jzz = 2, NZ
         jz = KZ0 + jzz - 1
#if DEBUG_MTSBLD
         do jht = 1, NH
            jh = KTB (jht, kfw)
            VX (jh, jz, KW) =
     $           VX (jh, jz - 1, KU) / W (jh)
            W  (jh) =
     $           VX (jh, jz, KD) - VX (jh, jz, KL) * VX (jh, jz, KW)
            VX (jh, jz, KX) =
     $           (VX (jh, jz, KB) - VX (jh, jz, KL) *  VX(jh, jz-1, KX))
     $           / W (jh)
         enddo
#else
         do jh = 1, NH
            VX (jh, jz, KW) =
     $           VX (jh, jz - 1, KU) / W (jh)
            W  (jh) =
     $           VX (jh, jz, KD) - VX (jh, jz, KL) * VX (jh, jz, KW)
            VX (jh, jz, KX) =
     $           (VX (jh, jz, KB) - VX (jh, jz, KL) *  VX(jh, jz-1, KX))
     $           / W (jh)
         enddo
#endif
      enddo
c
      do jzz = NZ - 1, 1, -1
         jz = KZ0 + jzz - 1
#if DEBUG_MTSBLD
         do jht = 1, NH
            jh = KTB (jht, kfw)
            VX (jh, jz, KX) =
     $           VX (jh, jz,KX) - (VX (jh, jz+1, KW) * VX (jh, jz+1,KX))
         enddo
#else
         do jh = 1, NH
            VX (jh, jz, KX) =
     $           VX (jh, jz,KX) - (VX (jh, jz+1, KW) * VX (jh, jz+1,KX))
         enddo
#endif
      enddo
      RETURN
      END
CCC_ & MTSslz - matrix solver core (z inner)
      subroutine MTSslz
     O    (iErr,
     M     VX,
     W     W,
     I     KX,   KW,   KU,   KD,  KL,  KB,
     I     KTB,  NH,   LH,   NZ,  LZ,  KZ0,
     I     IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  NH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
      _INTENT(INOUT,_REALSTD) VX (LH, LZ, *)
      _INTENT(INOUT,_REALSTD) W  (*)
      _INTENT(IN,   integer)  KTB (LH, *)
      _INTENT(IN,   integer)  KX, KW
      _INTENT(IN,   integer)  KU, KD, KL, KB
      _INTENT(IN,   integer)  IFPl
c
      integer   jh
      integer   jzz, jz
#if DEBUG_MTSBLD
      integer   jht
      integer   kfw
#endif
CCC_  - Body
      iErr  = 0
c
#if DEBUG_MTSBLD
      kfw   = 1
      do jht = 1, NH
         jh = KTB (jht, kfw)
         W  (jh) = VX (jh, KZ0, KD)
         VX (jh, KZ0, KX) = VX (jh, KZ0, KB) / W (jh)
      enddo
#else
      do jh = 1, NH
         W  (jh) = VX (jh, KZ0, KD)
         VX (jh, KZ0, KX) = VX (jh, KZ0, KB) / W (jh)
      enddo
#endif
c
#if DEBUG_MTSBLD
      do jht = 1, NH
         jh = KTB (jht, kfw)
         do jzz = 2, NZ
            jz = KZ0 + jzz - 1
            VX (jh, jz, KW) =
     $           VX (jh, jz - 1, KU) / W (jh)
            W  (jh) =
     $           VX (jh, jz, KD) - VX (jh, jz, KL) * VX (jh, jz, KW)
            VX (jh, jz, KX) =
     $           (VX (jh, jz, KB) - VX (jh, jz, KL) *  VX(jh, jz-1, KX))
     $           / W (jh)
         enddo
      enddo
#else
      do jh = 1, NH
         do jzz = 2, NZ
            jz = KZ0 + jzz - 1
            VX (jh, jz, KW) =
     $           VX (jh, jz - 1, KU) / W (jh)
            W  (jh) =
     $           VX (jh, jz, KD) - VX (jh, jz, KL) * VX (jh, jz, KW)
            VX (jh, jz, KX) =
     $           (VX (jh, jz, KB) - VX (jh, jz, KL) *  VX(jh, jz-1, KX))
     $           / W (jh)
         enddo
      enddo
#endif
c
#if DEBUG_MTSBLD
      do jht = 1, NH
         jh = KTB (jht, kfw)
         do jzz = NZ - 1, 1, -1
            jz = KZ0 + jzz - 1
            VX (jh, jz, KX) =
     $           VX (jh, jz,KX) - (VX (jh, jz+1, KW) * VX (jh, jz+1,KX))
         enddo
      enddo
#else
      do jh = 1, NH
         do jzz = NZ - 1, 1, -1
            jz = KZ0 + jzz - 1
            VX (jh, jz, KX) =
     $           VX (jh, jz,KX) - (VX (jh, jz+1, KW) * VX (jh, jz+1,KX))
         enddo
      enddo
#endif
      RETURN
      END
CCC_ + end
#endif  /* 0 obsolete */
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
