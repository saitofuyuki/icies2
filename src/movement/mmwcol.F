C movement/mmwcol.F --- IcIES/Movement/vertical velocity collection
C Maintainer:  SAITO Fuyuki
C Created: Mar 27 2013
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2020/09/17 08:46:02 fuyuki mmwcol.F>'
#define _FNAME 'movement/mmwcol.F'
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
CCC_* Common macros
#include "ofdlct.h"   /* fortran dialect */
#include "oarpkw.h"   /* operation id in arpeggio/kiwi */
#include "movement.h" /* movement definitions */
CCC_ + Buffer size
#ifndef    OPT_MMWCOL_SALLY_HSIZE
#  define  OPT_MMWCOL_SALLY_HSIZE 32678
#endif
#ifndef    OPT_MMWCOL_SALLY_ZSIZE
#  define  OPT_MMWCOL_SALLY_ZSIZE 64
#endif
CCC_* misc
CCC_ & MMWacg  ## clone group declaration
      subroutine MMWacg
     O    (iErr,
     O     ipCG,
     W     kDTA,
     I     LTBL, LCG, LH, LCK, ipKW, IE, IFP)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(IN, integer) LCG, LH, LCK, LTBL
      _INTENT(OUT,integer) ipCG (LCG, *)
      _INTENT(OUT,integer) kDTA  (LTBL, 3)
      _INTENT(IN, integer) ipKW (*), IE (*), IFP
      integer    kv, ko
CCC_  - Body
      iErr = 0
      kv   = 0
CCC_   . group Ub
      if (iErr.eq.0) then
         kv = CGV_Ub
         ko = 1
         call AKCgro (iErr, ipCG (1, kv), LCG, ko)
         call AKCgad (iErr, ipCG (1, kv), KWO_DXba,  KWM_M, LCG)
         call AKCgad (iErr, ipCG (1, kv), KWO_Lba,   KWM_M, LCG)
         call AKCgad (iErr, ipCG (1, kv), KWO_FCba,  KWM_M, LCG)
         call AKCgso
     O       (iErr, ko,   ipCG (1, kv), KDTA,
     I        LCG,  LTBL, LH,           ipKW, IE, IFP)
      endif
CCC_   . group Vc
      if (iErr.eq.0) then
         kv = CGV_Vc
         call AKCgrs (iErr, ipCG (1, kv), LCG)
         call AKCgad (iErr, ipCG (1, kv), KWO_DYca,  KWM_M, LCG)
         call AKCgad (iErr, ipCG (1, kv), KWO_Lca,   KWM_M, LCG)
         call AKCgad (iErr, ipCG (1, kv), KWO_FCca,  KWM_M, LCG)
         call AKCgso
     O       (iErr, ko,   ipCG (1, kv), KDTA,
     I        LCG,  LTBL, LH,           ipKW, IE, IFP)
      endif
c
      call DAtrcU (IFP, iErr, 'R', 'MMWACG')
      RETURN
      END
CCC_* Vertical velocity computation
CCC_ & MMWcmp  ## Vertical velocity computation
      subroutine MMWcmp
     O    (iErr,
     M     VMHW,  VMTI,  VMTW,
     W     WH,    CW,
     I     VMI,   VMC,   VMHB, QM,   F0,  WZV,  T,   DT,
     I     IMM,   WW,
     I     MH,    LH,    NZ,   LZ,   KZ0,
     I     ipCG,  LCG,   ipKW, iMA,  IE,  IFP)
CCC_  * Description
CCC_  * Declaration
      implicit none
c
      _INTENT(OUT,  integer)  iErr
c
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
      _INTENT(IN,   integer)  LCG
c
      _INTENT(OUT,  _REALSTD) WH   (LH, *)
      _INTENT(OUT,  _REALSTD) CW   (*)
c
      _INTENT(INOUT,_REALSTD) VMHW (LH, *)
      _INTENT(INOUT,_REALSTD) VMTI (LH, LZ, *)
      _INTENT(INOUT,_REALSTD) VMTW (LH, LZ, *)
c
      _INTENT(IN,   _REALSTD) VMI  (LH, *)
      _INTENT(IN,   _REALSTD) VMC  (LH, *)
      _INTENT(IN,   _REALSTD) VMHB (LH, *)
      _INTENT(IN,   _REALSTD) QM   (LH, *)
      _INTENT(IN,   _REALSTD) T, DT, F0
c
      _INTENT(IN,   integer)  IMM  (*)
c
      _INTENT(IN,   _REALSTD) WZV  (LZ, *)
      _INTENT(IN,   _REALSTD) WW   (*)
      _INTENT(IN,   integer)  ipKW (*), iMA (*), IE (*)
      _INTENT(IN,   integer)  ipCG (*)
c
      _INTENT(IN,   integer)  IFP
c
      integer MSW, MWI, MWA
      _REALSTD wenrm
CCC_  * Body
      iErr = 0
c
      MSW = IMM (IMD_MSW)
      MWI = IMM (IMD_WI)
      MWA = IMM (IMD_WADV)
CCC_  * DVB sally compatible, just call MMWsst and return
      if (MWI .eq. SW_WI_SALLY
     $     .and. MSW .eq. MMXSW_DVB) then
         if (iErr.eq.0) then
            call MMWsst
     O          (iErr,
     M           VMHW,  VMTI,  VMTW,
     W           WH,    CW,
     I           VMI,   VMC,   VMHB, WZV,  T, DT,
     I           WW,
     I           MH,    LH,    NZ,   LZ,   KZ0,
     I           ipCG,  LCG,   ipKW, iMA,  IE,   IFP)
         endif
         RETURN
      endif
CCC_  * Other compatible cases
CCC_   + preparation common
      if (iErr.eq.0) then
         call MMWprc
     O       (iErr,
     O        VMHW,  VMTI,  VMTW,  CW,
     I        WW,
     I        MH,    LH,    NZ,    LZ,   KZ0,
     I        ipCG,  LCG,   ipKW,  iMA,  MSW)
      endif
CCC_   + preparation
      if (iErr.eq.0) then
         if (MSW .eq. MMXSW_DVB
     $           .or. MSW .eq. MMXSW_DE
     $           .or. MSW .eq. MMXSW_D00) then
            call MMWdpr
     O          (iErr,
     O           VMTW,  CW,
     I           VMI,   VMC,   VMTI,
     I           WW,    WZV,
     I           MH,    LH,    NZ,    LZ,   KZ0,
     I           ipCG,  LCG,   ipKW,  iMA,  MSW)
         else if (MSW .eq. MMXSW_ZEV) then
            call MMWepr
     O          (iErr,
     O           VMTW,  CW,
     I           VMI,   VMC,   VMTI,
     I           QM,    -1,    -1,    -1,   -1,
     I           WW,    WZV,
     I           MH,    LH,    NZ,    LZ,   KZ0,
     I           ipCG,  LCG,   ipKW,  iMA,  MSW)
         else if (MSW .eq. MMXSW_UPD) then
            call MMWzpr
     O          (iErr,
     O           VMTW,  WH,    CW,
     I           VMI,   VMC,   VMTI,  QM,   F0,
     I           WW,    WZV,
     I           MH,    LH,    NZ,    LZ,   KZ0,
     I           ipCG,  LCG,   ipKW,  iMA,  MSW)
         else if (MSW .eq. MMXSW_UPE) then
            call MMWepr
     O          (iErr,
     O           VMTW,  CW,
     I           VMI,   VMC,   VMTI,
     I           QM,    VMQH_WXp, VMQH_WXm,
     I                  VMQH_WYp, VMQH_WYm,
     I           WW,    WZV,
     I           MH,    LH,    NZ,    LZ,   KZ0,
     I           ipCG,  LCG,   ipKW,  iMA,  MSW)
            call MMWypr
     O          (iErr,
     O           VMTW,  WH,    CW,
     I           VMI,   VMC,   VMTI,  QM,   F0,
     I           WW,    WZV,
     I           MH,    LH,    NZ,    LZ,   KZ0,
     I           ipCG,  LCG,   ipKW,  iMA,  MSW)
         else if (MSW .eq. MMXSW_UP1) then
            call MMWupr
     O          (iErr,
     O           VMTW,  WH,    CW,
     I           VMI,   VMC,   VMTI,  QM,   F0,
     I           WW,    WZV,
     I           MH,    LH,    NZ,    LZ,   KZ0,
     I           ipCG,  LCG,   ipKW,  iMA,  MSW)
         else
            call MMHwpr
     O          (iErr,
     O           VMTW,  WH,    CW,
     I           VMI,   VMC,   VMTI,  QM,   F0,
     I           WW,    WZV,
     I           MH,    LH,    NZ,    LZ,   KZ0,
     I           ipCG,  LCG,   ipKW,  iMA,  MSW)
         endif
      endif
CCC_   . replace bottom bc
      if (iErr.eq.0) then
         if (MWI .eq. SW_WI_UDB) then
            call MMWugb
     O          (iErr,
     O           VMTW,  CW,  WH,
     I           VMTI,  VMI, WW,
     I           MH,    LH,  NZ,    LZ,   KZ0,
     I           ipKW,  iMA)
         endif
      endif
CCC_   + bottom and integral
      if (iErr.eq.0) then
         call MMWabi
     O       (iErr,
     O        VMTI,  VMTW,  WH,
     I        VMI,   VMC,   VMHB,  DT,   WZV,
     I        MH,    LH,    NZ,    LZ,   KZ0)
      endif
CCC_   . w advection coefficient
      if (iErr.eq.0) then
         if (MWA.eq. SW_WADV_RAW) then
            call MMTswa
     O          (iErr,
     M           VMTI,
     I           MH,    LH,    NZ,  LZ,  KZ0)
         else
            call MMTxwa
     O          (iErr,
     M           VMTI,  WH,
     I           VMTW,  VMI,   VMC,  VMHB, DT,   WZV,
     I           MH,    LH,    NZ,   LZ,   KZ0)
         endif
      endif
      if (iErr.eq.0) then
         call MMTuzi
     O       (iErr,
     O        VMTI, CW,
     I        VMTW,
     I        WW,
     I        MH,    LH,   NZ,    LZ,   KZ0,
     I        ipKW,  iMA)
      endif
CCC_   . surface consistency check
      if (iErr.eq.0) then
         call MMWasf
     O       (iErr,
     O        WH,    VMTW,
     I        VMTI,
     I        VMI,   VMC,   VMHB,  DT,
     I        MH,    LH,    NZ,    LZ,   KZ0)
         call MMXinm
     O       (wenrm,
     W        CW,
     I        WH,    VMW_W1, iMA, IE, MH, LH)
 101     format ('WSERR ', E16.9, 1x, E16.9)
         write (IFP, 101) T, wenrm
      endif
      RETURN
      END
CCC_* scheme/A - numerically consistent as much as possible
CCC_ & MMWprc  ## A/preparation (DVB/ZEV common)
      subroutine MMWprc
     O    (iErr,
     O     VMHW,  VMTI,  VMTW,  CW,
     I     WW,
     I     MH,    LH,    NZ,    LZ,   KZ0,
     I     ipCG,  LCG,   ipKW,  iMA,  MSW)
CCC_  * Description
CC      To compute
CC        P0 {div ui:div ub} at a
CC        uv:a
CC        advection switch
CCC_  * Declaration
      implicit none
c
      _INTENT(OUT,  integer)  iErr
c
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
      _INTENT(IN,   integer)  LCG
c
      _INTENT(INOUT,_REALSTD) VMHW (LH, *)
      _INTENT(INOUT,_REALSTD) VMTI (LH, LZ, *)
      _INTENT(INOUT,_REALSTD) VMTW (LH, LZ, *)
      _INTENT(OUT,  _REALSTD) CW   (LH, LZ, *)
c
      _INTENT(IN,   _REALSTD) WW   (*)
      _INTENT(IN,   integer)  ipKW (*), iMA (*)
      _INTENT(IN,   integer)  ipCG (LCG, *)
c
      _INTENT(IN,   integer)  MSW
CCC_  * Body
      iErr = 0
CCC_   + clone
      call AKCguw
     O    (CW,
     I     VMTI,  MH, LH, NZ, LZ, KZ0, VMTI_UHb,
     I     iMA,  ipCG (1, CGV_Ub))
CCC_   + x div uh  (div ui;   div ub)
      call AKGway
     O    (VMTW (1,1,VMTW_W3x),
     I     CW,  VMTI (1,1,VMTI_UHb), WW,
     I     MH,  LH, NZ, LZ, KZ0, ipKW, CGV_Ub_DXba, ipCG (1, CGV_Ub))
CCC_   + ua
      call AKGwaw
     M    (VMTI,
     I     CW,   WW,
     I     MH,   LH,  NZ,  LZ, KZ0, VMTI_UHa, VMTI_UHb,
     I     ipKW, CGV_Ub_Lba, ipCG (1, CGV_Ub))
      call AKBomw
     M    (VMTI,  CW,
     I     WW,
     I     MH,   LH,  NZ, LZ, KZ0, VMTI_UHa, VMTI_UHa,
     I     ipKW, iMA, KWO_ZXb)
CCC_   + uadv/switch
      call MMTsva
     O    (iErr,
     M     VMTI,  VMTI_Uadv,  VMTI_UHb,
     M     VMHW,  VMHW_ADVXe, VMHW_ADVXw,
     W     VMTW,  VMTW_W1,    CW,
     I     MH,    LH,    NZ,  LZ,    KZ0,
     I     ipKW,  CGV_Ub_FCba, ipCG (1, CGV_Ub))
CCC_   + clone
      call AKCguw
     O    (CW,
     I     VMTI,  MH, LH, NZ, LZ, KZ0, VMTI_VHc,
     I     iMA,  ipCG (1, CGV_Vc))
CCC_   + y div uh  (div vi;   div vb)
      call AKGway
     O    (VMTW (1,1,VMTW_W3y),
     I     CW,  VMTI (1,1,VMTI_VHc), WW,
     I     MH,  LH, NZ, LZ, KZ0, ipKW, CGV_Vc_DYca, ipCG (1, CGV_Vc))
CCC_   + va
      call AKGwaw
     M    (VMTI,
     I     CW,   WW,
     I     MH,   LH,  NZ,  LZ, KZ0, VMTI_VHa, VMTI_VHc,
     I     ipKW, CGV_Vc_Lca, ipCG (1, CGV_Vc))
      call AKBomw
     M    (VMTI,  CW,
     I     WW,
     I     MH,   LH,  NZ, LZ, KZ0, VMTI_VHa, VMTI_VHa,
     I     ipKW, iMA, KWO_ZYc)
CCC_   + vadv/switch
      call MMTsva
     O    (iErr,
     M     VMTI,  VMTI_Vadv,  VMTI_VHc,
     M     VMHW,  VMHW_ADVYn, VMHW_ADVYs,
     W     VMTW,  VMTW_W1,    CW,
     I     MH,    LH,    NZ,  LZ,    KZ0,
     I     ipKW,  CGV_Vc_FCca, ipCG (1, CGV_Vc))
CCC_   + P0 final
      call UV0nac
     $    (VMTW,
     $     MH, LH, NZ, LZ, KZ0, VMTW_divuh, VMTW_W3x, VMTW_W3y)
      RETURN
      END
CCC_ & MMWdpr  ## A/preparation (DVB)
      subroutine MMWdpr
     O    (iErr,
     O     VMTW,  CW,
     I     VMI,   VMC,   VMTI,
     I     WW,    WZV,
     I     MH,    LH,    NZ,    LZ,   KZ0,
     I     ipCG,  LCG,   ipKW,  iMA,  MSW)
CCC_  * Declaration
      implicit none
c
      _INTENT(OUT,  integer)  iErr
c
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
      _INTENT(IN,   integer)  LCG
c
      _INTENT(INOUT,_REALSTD) VMTW (LH, LZ, *)
      _INTENT(OUT,  _REALSTD) CW   (LH, LZ, *)
c
      _INTENT(IN,   _REALSTD) VMI  (LH, *)
      _INTENT(IN,   _REALSTD) VMC  (LH, *)
      _INTENT(IN,   _REALSTD) VMTI (LH, LZ, *)
c
      _INTENT(IN,   _REALSTD) WW   (*)
      _INTENT(IN,   _REALSTD) WZV  (LZ, *)
      _INTENT(IN,   integer)  ipKW (*), iMA (*)
      _INTENT(IN,   integer)  ipCG (LCG, *)
c
      _INTENT(IN,   integer)  MSW
c
      integer jh, jz, jz0, jzb
CCC_  * Body
      iErr = 0
c
      jzb = KZ0
CCC_   . -P1  div H (int dzeta ui + zeta ub)
CCC_    * Notes
CC       For consistency, may be better to compute as
CC       div(Dz grad H + zeta vb H) + div (Dz grad b)
CCC_    * grad:bc Snew:a
CCC_    * Dz:bc  grad Sn:bc
CCC_    * Dz:bc  grad Sn:bc
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_W1)
     $           = VMTW (jh, jz, VMTW_ziDIb) * VMC (jh, VMC_SXbM)
            VMTW (jh, jz, VMTW_W2)
     $           = VMTW (jh, jz, VMTW_ziDIc) * VMC (jh, VMC_SYcM)
         enddo
      enddo
CCC_    * vb:bc Hnew:bc
      do jh = 1, MH
         VMTW (jh, jzb, VMTW_W1)
     $        = VMTI (jh, jzb, VMTI_UHb) * VMC (jh, VMC_NHb)
         VMTW (jh, jzb, VMTW_W2)
     $        = VMTI (jh, jzb, VMTI_VHc) * VMC (jh, VMC_NHc)
      enddo
CCC_    * Dz grad S + zeta vb H
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_W1)
     $           = VMTW (jh, jz, VMTW_W1)
     $           + WZV (jz, VMVZ_Za) * VMTW (jh, jzb, VMTW_W1)
            VMTW (jh, jz, VMTW_W2)
     $           = VMTW (jh, jz, VMTW_W2)
     $           + WZV (jz, VMVZ_Za) * VMTW (jh, jzb, VMTW_W2)
         enddo
      enddo
CCC_    * div
      call AKBwaw
     O    (VMTW, CW,
     I     WW,
     I     MH,   LH,  NZ, LZ,   KZ0, VMTW_W3x, VMTW_W1,
     I     ipKW, iMA, KWO_DXba, KWM_M)
      call AKBwaw
     O    (VMTW, CW,
     I     WW,
     I     MH,   LH,  NZ, LZ,   KZ0, VMTW_W3y, VMTW_W2,
     I     ipKW, iMA, KWO_DYca, KWM_M)
CCC_    * final/i
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_divHziue)
     $           = (VMTW (jh, jz, VMTW_W3x) + VMTW (jh, jz, VMTW_W3y))
         enddo
      enddo
CCC_    * final/b
      do jh = 1, MH
         VMTW (jh, jzb, VMTW_divHziue) = 0.0d0
      enddo
CCC_   . P2+P3
CCC_    * ui:b Zold:b
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_W1)
     $           = VMTI (jh, jz, VMTI_UHb)
     $           * (VMI(jh,VMI_Bb) + WZV(jz,VMVZ_Za) * VMI(jh,VMI_Hb))
            VMTW (jh, jz, VMTW_W2)
     $           = VMTI (jh, jz, VMTI_VHc)
     $           * (VMI(jh,VMI_Bc) + WZV(jz,VMVZ_Za) * VMI(jh,VMI_Hc))
         enddo
      enddo
CCC_    * ui:b Zold:b + zeta ub H:new:b
CCC_    * vi:c Zold:c + zeta vb H:new:c
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_W1)
     $           = VMTW (jh, jz, VMTW_W1)
     $           + WZV (jz, VMVZ_Za) * VMTW (jh, jzb, VMTW_W1)
            VMTW (jh, jz, VMTW_W2)
     $           = VMTW (jh, jz, VMTW_W2)
     $           + WZV (jz, VMVZ_Za) * VMTW (jh, jzb, VMTW_W2)
         enddo
      enddo
CCC_    * bottom: overwrite with ub bnew:b
      do jh = 1, MH
         VMTW (jh, jzb, VMTW_W1)
     $        = VMTI (jh, jzb, VMTI_UHb) * VMC (jh, VMC_NBb)
         VMTW (jh, jzb, VMTW_W2)
     $        = VMTI (jh, jzb, VMTI_VHc) * VMC (jh, VMC_NBc)
      enddo
CCC_    * div (d1)
      call AKBwaw
     O    (VMTW, CW,
     I     WW,
     I     MH,   LH,  NZ, LZ,   KZ0, VMTW_W3x, VMTW_W1,
     I     ipKW, iMA, KWO_DXba, KWM_M)
      call AKBwaw
     O    (VMTW, CW,
     I     WW,
     I     MH,   LH,  NZ, LZ,   KZ0, VMTW_W3y, VMTW_W2,
     I     ipKW, iMA, KWO_DYca, KWM_M)
CCC_    * d1 - Zold:a div ui - zeta H:new div ub
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_ugradz)
     $           = (VMTW (jh, jz, VMTW_W3x) + VMTW (jh, jz, VMTW_W3y))
     $           - (+ VMTW (jh, jz, VMTW_divuh)
     $              * (VMI(jh,VMI_Ba)+WZV(jz,VMVZ_Za)*VMI(jh,VMI_Ha))
     $              + VMTW (jh, jzb, VMTW_divuh)
     $              * (              +WZV(jz,VMVZ_Za)*VMC(jh,VMC_NHa)))
         enddo
      enddo
CCC_    * bottom: d1 - b:new div ub
      do jh = 1, MH
         VMTW (jh, jzb, VMTW_ugradz)
     $        = (VMTW (jh, jzb, VMTW_W3x) + VMTW (jh, jzb, VMTW_W3y))
     $           - (VMTW (jh, jzb, VMTW_divuh) * VMC (jh, VMC_NBa))
      enddo
      RETURN
      END
CCC_ & MMWepr  ## A/preparation (ZEV)
      subroutine MMWepr
     O    (iErr,
     O     VMTW,  CW,
     I     VMI,   VMC,   VMTI,
     I     QM,    KQXp,  KQXm,  KQYp, KQYm,
     I     WW,    WZV,
     I     MH,    LH,    NZ,    LZ,   KZ0,
     I     ipCG,  LCG,   ipKW,  iMA,  MSW)
CCC_  * Declaration
      implicit none
c
      _INTENT(OUT,  integer)  iErr
c
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
      _INTENT(IN,   integer)  LCG
c
      _INTENT(INOUT,_REALSTD) VMTW (LH, LZ, *)
      _INTENT(OUT,  _REALSTD) CW   (LH, LZ, *)
c
      _INTENT(IN,   _REALSTD) VMI  (LH, *)
      _INTENT(IN,   _REALSTD) VMC  (LH, *)
      _INTENT(IN,   _REALSTD) VMTI (LH, LZ, *)
c
      _INTENT(IN,   _REALSTD) QM   (LH, *)
      _INTENT(IN,   integer)  KQXp,  KQXm,  KQYp, KQYm
c
      _INTENT(IN,   _REALSTD) WW   (*)
      _INTENT(IN,   _REALSTD) WZV  (LZ, *)
      _INTENT(IN,   integer)  ipKW (*), iMA (*)
      _INTENT(IN,   integer)  ipCG (LCG, *)
c
      _INTENT(IN,   integer)  MSW
c
      integer jh, jz, jz0, jzb
CCC_  * Body
      iErr = 0
      jzb = KZ0
CCC_   . -P1  div H (int dzeta ui + zeta ub)
CCC_    * int dzeta ui + zeta ub
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_W1)
     $           = VMTW (jh, jz, VMTW_ziUIb)
     $           + WZV (jz, VMVZ_Za) * VMTI (jh, jzb, VMTI_UHb)
            VMTW (jh, jz, VMTW_W2)
     $           = VMTW (jh, jz, VMTW_ziVIc)
     $           + WZV (jz, VMVZ_Za) * VMTI (jh, jzb, VMTI_VHc)
         enddo
      enddo
CCC_    * H int ue
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_W1)
     $           = VMTW (jh, jz, VMTW_W1) * VMC(jh, VMC_NHb)
            VMTW (jh, jz, VMTW_W2)
     $           = VMTW (jh, jz, VMTW_W2) * VMC(jh, VMC_NHc)
         enddo
      enddo
CCC_    * div
      call AKBwaw
     O    (VMTW, CW,
     I     WW,
     I     MH,   LH,  NZ, LZ,   KZ0, VMTW_W3x, VMTW_W1,
     I     ipKW, iMA, KWO_DXba, KWM_M)
      call AKBwaw
     O    (VMTW, CW,
     I     WW,
     I     MH,   LH,  NZ, LZ,   KZ0, VMTW_W3y, VMTW_W2,
     I     ipKW, iMA, KWO_DYca, KWM_M)
CCC_    * final/i
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_divHziue)
     $           = (VMTW (jh, jz, VMTW_W3x) + VMTW (jh, jz, VMTW_W3y))
         enddo
      enddo
CCC_    * final/b
      do jh = 1, MH
         VMTW (jh, jzb, VMTW_divHziue) = 0.0d0
      enddo
CCC_   . P2+P3
CCC_    * ui:b Znew:b
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_W1)
     $           = VMTI (jh, jz, VMTI_UHb)
     $           * (VMC(jh,VMC_NBb) + WZV(jz,VMVZ_Za) * VMC(jh,VMC_NHb))
            VMTW (jh, jz, VMTW_W2)
     $           = VMTI (jh, jz, VMTI_VHc)
     $           * (VMC(jh,VMC_NBc) + WZV(jz,VMVZ_Za) * VMC(jh,VMC_NHc))
         enddo
      enddo
CCC_    * ui:b Znew:b + zeta ub H:new:b
CCC_    * vi:c Znew:c + zeta vb H:new:c
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_W1)
     $           = VMTW (jh, jz, VMTW_W1)
     $           + WZV (jz, VMVZ_Za) * VMTI (jh, jzb, VMTI_UHb)
     $             * VMC(jh,VMC_NHb)
            VMTW (jh, jz, VMTW_W2)
     $           = VMTW (jh, jz, VMTW_W2)
     $           + WZV (jz, VMVZ_Za) * VMTI (jh, jzb, VMTI_VHc)
     $             * VMC(jh,VMC_NHc)
         enddo
      enddo
CCC_    * bottom: overwrite with ub bnew:b
      do jh = 1, MH
         VMTW (jh, jzb, VMTW_W1)
     $        = VMTI (jh, jzb, VMTI_UHb) * VMC (jh, VMC_NBb)
         VMTW (jh, jzb, VMTW_W2)
     $        = VMTI (jh, jzb, VMTI_VHc) * VMC (jh, VMC_NBc)
      enddo
CCC_    * div (d1)
      call AKBwaw
     O    (VMTW, CW,
     I     WW,
     I     MH,   LH,  NZ, LZ,   KZ0, VMTW_W3x, VMTW_W1,
     I     ipKW, iMA, KWO_DXba, KWM_M)
      call AKBwaw
     O    (VMTW, CW,
     I     WW,
     I     MH,   LH,  NZ, LZ,   KZ0, VMTW_W3y, VMTW_W2,
     I     ipKW, iMA, KWO_DYca, KWM_M)
CCC_    * d1 - Znew:a div ui - zeta H:new div ub
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_ugradz)
     $           = (VMTW (jh, jz, VMTW_W3x) + VMTW (jh, jz, VMTW_W3y))
     $           - (+ VMTW (jh, jz, VMTW_divuh)
     $              * (VMC(jh,VMC_NBa)+WZV(jz,VMVZ_Za)*VMC(jh,VMC_NHa))
     $              + VMTW (jh, jzb, VMTW_divuh)
     $              * (               +WZV(jz,VMVZ_Za)*VMC(jh,VMC_NHa)))
         enddo
      enddo
CCC_    * bottom: d1 - b:new div ub
      do jh = 1, MH
         VMTW (jh, jzb, VMTW_ugradz)
     $        = (VMTW (jh, jzb, VMTW_W3x) + VMTW (jh, jzb, VMTW_W3y))
     $           - (VMTW (jh, jzb, VMTW_divuh) * VMC (jh, VMC_NBa))
      enddo
      RETURN
      END
CCC_ & MMWzpr  ## A/preparation (Z/UPD)
      subroutine MMWzpr
     O    (iErr,
     O     VMTW,  WH,    CW,
     I     VMI,   VMC,   VMTI,  QM,   F0,
     I     WW,    WZV,
     I     MH,    LH,    NZ,    LZ,   KZ0,
     I     ipCG,  LCG,   ipKW,  iMA,  MSW)
CCC_  * Declaration
      implicit none
c
      _INTENT(OUT,  integer)  iErr
c
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
      _INTENT(IN,   integer)  LCG
c
      _INTENT(INOUT,_REALSTD) VMTW (LH, LZ, *)
      _INTENT(OUT,  _REALSTD) CW   (LH, LZ, *)
      _INTENT(OUT,  _REALSTD) WH   (LH, *)
c
      _INTENT(IN,   _REALSTD) VMI  (LH, *)
      _INTENT(IN,   _REALSTD) VMC  (LH, *)
      _INTENT(IN,   _REALSTD) VMTI (LH, LZ, *)
      _INTENT(IN,   _REALSTD) QM   (LH, *)
      _INTENT(IN,   _REALSTD) F0
c
      _INTENT(IN,   _REALSTD) WW   (*)
      _INTENT(IN,   _REALSTD) WZV  (LZ, *)
      _INTENT(IN,   integer)  ipKW (*), iMA (*)
      _INTENT(IN,   integer)  ipCG (LCG, *)
c
      _INTENT(IN,   integer)  MSW
c
      integer jh, jz, jz0, jzb, jzs
c$$$c
c$$$      _REALSTD Tmin, Tmax
CCC_  * Body
      iErr = 0
      jzb = KZ0
CCC_   . grad H upwind
      call MMWzgu
     O    (WH,    VMW_W3, VMW_W4, VMW_W5,
     W     CW,
     I     VMC,   VMC_NHa,
     I     QM,    WW,
     I     MH,    LH,
     I     ipCG,  LCG,   ipKW,  iMA)
CCC_   . -P1  div H (int dzeta ui + zeta ub)
CCC_    * int dzeta ui + zeta ub (on b)
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_W1)
     $           = VMTW (jh, jz, VMTW_ziUIb)
     $           + WZV (jz, VMVZ_Za) * VMTI (jh, jzb, VMTI_UHb)
         enddo
      enddo
CCC_    * div interpol
      call AKCguw
     O    (CW,
     I     VMTW,  MH, LH, NZ, LZ, KZ0, VMTW_W1,
     I     iMA,  ipCG (1, CGV_Ub))
CCC_    * div (W3x: xdiv)
      call AKGwaw
     M    (VMTW,
     I     CW,   WW,
     I     MH,   LH,  NZ,  LZ, KZ0, VMTW_W3x, VMTW_W1,
     I     ipKW, CGV_Ub_DXba, ipCG (1, CGV_Ub))
CCC_    * L b:a (W2: interpol)
      call AKGwaw
     M    (VMTW,
     I     CW,   WW,
     I     MH,   LH,  NZ,  LZ, KZ0, VMTW_W2, VMTW_W1,
     I     ipKW, CGV_Ub_Lba, ipCG (1, CGV_Ub))
CCC_    * int dzeta vi + zeta vb (on c)
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_W1)
     $           = VMTW (jh, jz, VMTW_ziVIc)
     $           + WZV (jz, VMVZ_Za) * VMTI (jh, jzb, VMTI_VHc)
         enddo
      enddo
CCC_    * div interpol
      call AKCguw
     O    (CW,
     I     VMTW,  MH, LH, NZ, LZ, KZ0, VMTW_W1,
     I     iMA,  ipCG (1, CGV_Vc))
CCC_    * div (W3y: ydiv)
      call AKGwaw
     M    (VMTW,
     I     CW,   WW,
     I     MH,   LH,  NZ,  LZ, KZ0, VMTW_W3y, VMTW_W1,
     I     ipKW, CGV_Vc_DYca, ipCG (1, CGV_Vc))
CCC_    * Note: L c:a pending (later)
CCC_    * H div U
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_divHziue)
     $           = (VMTW (jh, jz, VMTW_W3x)
     $             +VMTW (jh, jz, VMTW_W3y))
     $           * VMC(jh, VMC_NHa)
         enddo
      enddo
CCC_    * L c:a (W3y)
      call AKGwaw
     M    (VMTW,
     I     CW,   WW,
     I     MH,   LH,  NZ,  LZ, KZ0, VMTW_W3y, VMTW_W1,
     I     ipKW, CGV_Vc_Lca, ipCG (1, CGV_Vc))
CCC_    * U grad H upwind
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_divHziue) =
     $           VMTW (jh, jz, VMTW_divHziue)
     $           + (VMTW (jh, jz, VMTW_W2)  * WH(jh,VMW_W3)
     $             +VMTW (jh, jz, VMTW_W3y) * WH(jh,VMW_W4))
         enddo
      enddo
CCC_    * final/b
      do jh = 1, MH
         VMTW (jh, jzb, VMTW_divHziue) = 0.0d0
      enddo
CCC_   . P2+P3
CCC_    * grad b upwind to W5, W6
      call AKBuaz
     O    (WH (1, VMW_W5),   CW,
     I     VMC(1, VMC_BXbM), QM,
     I     MH,    LH,  VMQZ_WXp, VMQZ_WXm,
     I     ipKW,  iMA, KWO_Lba,  KWM_M)
      call AKBuaz
     O    (WH (1, VMW_W6),   CW,
     I     VMC(1, VMC_BYcM), QM,
     I     MH,    LH,  VMQZ_WYp, VMQZ_WYm,
     I     ipKW,  iMA, KWO_Lca,  KWM_M)
CCC_    * ui:a (grad b + zeta grad H) upwind
CCC_    * zeta ub:a grad H upwind
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_ugradz) =
     $           ((VMTI(jh, jz, VMTI_UHa)
     $             * (WH(jh,VMW_W5) + WZV(jz,VMVZ_Za)*WH(jh,VMW_W3))
     $             + VMTI(jh, jzb, VMTI_UHa)
     $             * (              + WZV(jz,VMVZ_Za)*WH(jh,VMW_W3)))
     $            +(VMTI(jh, jz, VMTI_VHa)
     $             * (WH(jh,VMW_W6) + WZV(jz,VMVZ_Za)*WH(jh,VMW_W4))
     $             + VMTI(jh, jzb, VMTI_VHa)
     $             * (              + WZV(jz,VMVZ_Za)*WH(jh,VMW_W4))))
         enddo
      enddo
      do jh = 1, MH
         VMTW (jh, jzb, VMTW_ugradz) =
     $           ((VMTI(jh, jzb, VMTI_UHa) * WH(jh,VMW_W5))
     $            +(VMTI(jh, jzb, VMTI_VHa) * WH(jh,VMW_W6)))
      enddo
CCC_    * bottom
      RETURN
      END
CCC_ & MMWzgu  ## A/preparation (Z/UPD) upwind gradient
      subroutine MMWzgu
     O    (VW,    KVWx,  KVWy,  KVWw,
     W     CW,
     I     VI,    KVI,
     I     QM,    WW,
     I     MH,    LH,
     I     ipCG,  LCG,   ipKW,  iMA)
CCC_  * Declaration
      implicit none
c
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  LCG
c
      _INTENT(INOUT,_REALSTD) VW (LH, *)
      _INTENT(OUT,  _REALSTD) CW (LH, *)
      _INTENT(IN,   _REALSTD) VI (LH, *)
      _INTENT(IN,   _REALSTD) QM (LH, *)
c
      _INTENT(IN,   integer)  KVWx, KVWy, KVWw
      _INTENT(IN,   integer)  KVI
c
      _INTENT(IN,   _REALSTD) WW   (*)
      _INTENT(IN,   integer)  ipKW (*), iMA (*)
      _INTENT(IN,   integer)  ipCG (LCG, *)
CCC_  * body
CCC_   . clone group
      call AKCgux
     O    (CW,
     I     VI,   MH,   LH, KVI,
     I     iMA,  ipCG (1, CGB_XHaN))
CCC_   . operation
cc      xgrad to Y, ygrad to W temporaly
      call AKGwaz
     M    (VW (1, KVWy),
     I     CW,   VI(1, KVI), WW,
     I     MH,   LH,  ipKW, CGB_XHaN_GXab, ipCG (1, CGB_XHaN))
      call AKGwaz
     M    (VW (1, KVWw),
     I     CW,   VI(1, KVI), WW,
     I     MH,   LH,  ipKW, CGB_XHaN_GYac, ipCG (1, CGB_XHaN))
CCC_   + upwind switch
CC     Y (xgrad) switched to X
CC     W (ygrad) switched to Y
      call AKBuax
     O    (VW, CW,
     I     QM,
     I     MH,   LH,
     I     KVWx, KVWy, VMQZ_WXp, VMQZ_WXm,
     I     ipKW, iMA,  KWO_Lba,  KWM_M)
      call AKBuax
     O    (VW,   CW,
     I     QM,
     I     MH,    LH,
     I     KVWy,  KVWw, VMQZ_WYp, VMQZ_WYm,
     I     ipKW,  iMA,  KWO_Lca,  KWM_M)
CCC_   + result
      return
      END
CCC_ & MMWypr  ## A/preparation (Y/UPE) NOT IMPLEMENTED
      subroutine MMWypr
     O    (iErr,
     O     VMTW,  WH,    CW,
     I     VMI,   VMC,   VMTI,  QM,   F0,
     I     WW,    WZV,
     I     MH,    LH,    NZ,    LZ,   KZ0,
     I     ipCG,  LCG,   ipKW,  iMA,  MSW)
CCC_  * Declaration
      implicit none
c
      _INTENT(OUT,  integer)  iErr
c
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
      _INTENT(IN,   integer)  LCG
c
      _INTENT(INOUT,_REALSTD) VMTW (LH, LZ, *)
      _INTENT(OUT,  _REALSTD) CW   (LH, LZ, *)
      _INTENT(OUT,  _REALSTD) WH   (LH, *)
c
      _INTENT(IN,   _REALSTD) VMI  (LH, *)
      _INTENT(IN,   _REALSTD) VMC  (LH, *)
      _INTENT(IN,   _REALSTD) VMTI (LH, LZ, *)
      _INTENT(IN,   _REALSTD) QM   (LH, *)
      _INTENT(IN,   _REALSTD) F0
c
      _INTENT(IN,   _REALSTD) WW   (*)
      _INTENT(IN,   _REALSTD) WZV  (LZ, *)
      _INTENT(IN,   integer)  ipKW (*), iMA (*)
      _INTENT(IN,   integer)  ipCG (LCG, *)
c
      _INTENT(IN,   integer)  MSW
c
      integer jh, jz, jz0, jzb, jzs
c$$$c
c$$$      _REALSTD Tmin, Tmax
CCC_  * Body
      iErr = 0
#if 0
CCC_    * clone
      call AKCguw
     O    (CW,
     I     VMTW,  MH, LH, NZ, LZ, KZ0, VMTW_ziUIb,
     I     iMA,  ipCG (1, CGV_Ub))
CCC_    * xdiv uh  (div int ui;   div ub)
      call AKGwaw
     M    (VMTW,
     I     CW,   WW,
     I     MH,   LH,  NZ,  LZ, KZ0, VMTW_W3x, VMTW_ziUIb,
     I     ipKW, CGV_Ub_DXba, ipCG (1, CGV_Ub))
CCC_    * ua
      call AKGwaw
     M    (VMTW,
     I     CW,   WW,
     I     MH,   LH,  NZ,  LZ, KZ0, VMTW_ziUIa, VMTW_ziUIb,
     I     ipKW, CGV_Ub_Lba, ipCG (1, CGV_Ub))
      call AKBomw
     M    (VMTW, CW,
     I     WW,
     I     MH,   LH,  NZ, LZ, KZ0, VMTW_ziUIa, VMTW_ziUIa,
     I     ipKW, iMA, KWO_ZXb)
CCC_    * clone
      call AKCguw
     O    (CW,
     I     VMTW,  MH, LH, NZ, LZ, KZ0, VMTW_ziVIc,
     I     iMA,  ipCG (1, CGV_Vc))
CCC_    * ydiv vh  (div int ui;   div ub)
      call AKGwaw
     M    (VMTW,
     I     CW,   WW,
     I     MH,   LH,  NZ,  LZ, KZ0, VMTW_W3y, VMTW_ziVIc,
     I     ipKW, CGV_Vc_DYca, ipCG (1, CGV_Vc))
CCC_    * va
      call AKGwaw
     M    (VMTW,
     I     CW,   WW,
     I     MH,   LH,  NZ,  LZ, KZ0, VMTW_ziVIa, VMTW_ziVIc,
     I     ipKW, CGV_Vc_Lca, ipCG (1, CGV_Vc))
      call AKBomw
     M    (VMTW,  CW,
     I     WW,
     I     MH,   LH,  NZ, LZ, KZ0, VMTW_ziVIa, VMTW_ziVIa,
     I     ipKW, iMA, KWO_ZYc)
CCC_    * final (center)
      call UV0nac
     $     (VMTW, MH,LH,NZ,LZ,KZ0, VMTW_divziuh,VMTW_W3x,VMTW_W3y)
c$$$CCC_   . integral u:[bc]
c$$$      call AKBwaw
c$$$     O    (VMTW, CW,
c$$$     I     WW,
c$$$     I     MH,   LH,  NZ, LZ,  KZ0, VMTW_ziUIa, VMTW_ziUIb,
c$$$     I     ipKW, iMA, KWO_Lba, KWM_M)
c$$$      call AKBwaw
c$$$     O    (VMTW, CW,
c$$$     I     WW,
c$$$     I     MH,   LH,  NZ, LZ,  KZ0, VMTW_ziVIa, VMTW_ziVIc,
c$$$     I     ipKW, iMA, KWO_Lca, KWM_M)
CCC_   . P2
CCC_    * clone group
      call AKCgux
     O    (CW,
     I     VMC,  MH,   LH, VMC_NBa,
     I     iMA,  ipCG (1, CGB_XHaN))
CCC_    * [B1:b, B2:c] = <grad_xy a:bc> H:a (clone group)
      call AKGwaz
     M    (WH (1, VMIW_W1),
     I     CW,   VMC(1, VMC_NBa), WW,
     I     MH,   LH,  ipKW, 3, ipCG (1, CGB_XHaN))
      call AKGwaz
     M    (WH (1, VMIW_W2),
     I     CW,   VMC(1, VMC_NBa), WW,
     I     MH,   LH,  ipKW, 4, ipCG (1, CGB_XHaN))
CCC_    * P2: [vi;vb:a] grad b upwind
      call MMWguo
     O    (VMTW,  VMTW_uigradb,
     W     WH,    VMIW_W1,  VMIW_W2, VMIW_W3, VMIW_W4,
     W     CW,
     I     VMTI,  VMTI_UHa, VMTI_VHa,
     I     QM,    VMQH_WXp, VMQH_WXm, VMQH_WYp, VMQH_WYm, WW,
     I     MH,    LH,    NZ,    LZ,   KZ0,
     I     ipKW,  iMA)
CCC_    * E terms
CCC_   . P3
CCC_    * clone group
      call AKCgux
     O    (CW,
     I     VMC,  MH,   LH, VMC_NHa,
     I     iMA,  ipCG (1, CGB_XHaN))
CCC_    * [B1:b, B2:c] = <grad_xy a:bc> H:a (clone group)
      call AKGwaz
     M    (WH (1, VMIW_W1),
     I     CW,   VMC(1, VMC_NHa), WW,
     I     MH,   LH,  ipKW, 3, ipCG (1, CGB_XHaN))
      call AKGwaz
     M    (WH (1, VMIW_W2),
     I     CW,   VMC(1, VMC_NHa), WW,
     I     MH,   LH,  ipKW, 4, ipCG (1, CGB_XHaN))
CCC_    * P3: [vi;vb:a] grad b upwind
CCC_     + caution  W3 W4 are used at P1 computation
      call MMWguo
     O    (VMTW,  VMTW_zuegradH,
     W     WH,    VMIW_W1,  VMIW_W2, VMIW_W3, VMIW_W4,
     W     CW,
     I     VMTI,  VMTI_UHa, VMTI_VHa,
     I     QM,    VMQH_WXp, VMQH_WXm, VMQH_WYp, VMQH_WYm, WW,
     I     MH,    LH,    NZ,    LZ,   KZ0,
     I     ipKW,  iMA)
c$$$      Tmin = 0.0d0
c$$$      Tmax = 0.0d0
c$$$      do jh = 1, MH
c$$$         Tmin = MIN (Tmin, WH(jh, VMIW_W1))
c$$$         Tmax = MAX (Tmax, WH(jh, VMIW_W1))
c$$$      enddo
c$$$      write (*, *) 'dHdx', Tmin, Tmax
CCC_    * P3: P3:i Zeta
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_zuegradH) =
     $           VMTW (jh, jz, VMTW_zuegradH) * WZV (jz, VMVZ_Za)
         enddo
      enddo
CCC_   . P1 [uint:gradH; ub:gradH]
      do jz0 = 0, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_divHziue)
     $           =  (VMTW(jh, jz, VMTW_ziUIa) * WH(jh,VMIW_W3)
     $              +VMTW(jh, jz, VMTW_ziVIa) * WH(jh,VMIW_W4))
         enddo
      enddo
CCC_    * plus H div int ve
      jzb = KZ0
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_divHziue)
     $           =  VMTW (jh, jz, VMTW_divHziue)
     $           + VMC(jh, VMC_NHa)
     $             * (VMTW(jh,jz, VMTW_divziuh)
     $               +VMTW(jh,jzb,VMTW_divziuh)* WZV(jz, VMVZ_Za))
         enddo
      enddo
CCC_    * P1 bottom
      jz = KZ0
      do jh = 1, MH
         VMTW (jh, jz, VMTW_divHziue) =
     $        VMTW (jh, jz, VMTW_divHziue)
     $        + VMTW (jh, jz, VMTW_uigradb)
      enddo
#endif
      RETURN
      END
CCC_ & MMWguo  ## A/preparation (UPD/E) upwind operator
      subroutine MMWguo
     O    (VMTW,  KTO,
     W     WH,    KHGX,  KHGY,  KHWx, KHWy,
     W     CW,
     I     VMTI,  KTIU,  KTIV,
     I     QM,    KQXP,  KQXM,  KQYP, KQYM, WW,
     I     MH,    LH,    NZ,    LZ,   KZ0,
     I     ipKW,  iMA)
CCC_  * Declaration
      implicit none
c
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
c
      _INTENT(INOUT,_REALSTD) VMTW (LH, LZ, *)
      _INTENT(INOUT,_REALSTD) WH   (LH, *)
      _INTENT(OUT,  _REALSTD) CW   (LH, LZ, *)
      _INTENT(IN,   _REALSTD) QM   (LH, *)
      _INTENT(IN,   _REALSTD) VMTI (LH, LZ, *)
c
      _INTENT(IN,   integer)  KTO
      _INTENT(IN,   integer)  KTIU, KTIV
      _INTENT(IN,   integer)  KHGX, KHGY, KHWx, KHWy
      _INTENT(IN,   integer)  KQXP, KQXM, KQYP, KQYM
c
      _INTENT(IN,   _REALSTD) WW   (*)
      _INTENT(IN,   integer)  ipKW (*), iMA (*)
c
      integer jh, jz, jz0, jzb, jzs
c$$$      integer jchk
c$$$      data    jchk /0/
c$$$      save    jchk
c$$$      _REALSTD Tmin, Tmax, TminI, TmaxI
CCC_  * body
c$$$      TminI = 0.0d0
c$$$      TmaxI = 0.0d0
c$$$      do jh = 1, MH
c$$$         TminI = MIN (TminI, WH(jh, KHGX))
c$$$         TmaxI = MAX (TmaxI, WH(jh, KHGX))
c$$$      enddo
CCC_   + upwind switch
      call AKBuax
     O    (WH,   CW,
     I     QM,
     I     MH,   LH,  KHWx,    KHGX,  KQXP, KQXM,
     I     ipKW, iMA, KWO_Lba, KWM_M)
      call AKBuax
     O    (WH,   CW,
     I     QM,
     I     MH,   LH,  KHWy,    KHGY,  KQYP, KQYM,
     I     ipKW, iMA, KWO_Lca, KWM_M)
c
c$$$      Tmin = 0.0d0
c$$$      Tmax = 0.0d0
c$$$      do jh = 1, MH
c$$$         Tmin = MIN (Tmin, WH(jh, KHWx))
c$$$         Tmax = MAX (Tmax, WH(jh, KHWx))
c$$$      enddo
c$$$      if (Tmax.gt.0.0d0) then
c$$$         write (*, *) 'guo', Tmin, Tmax, TminI, TmaxI
c$$$         do jh = 1, MH
c$$$            write (*, *) 'PM',jh, QM(jh, VMQG_WXp), QM(jh, VMQG_WYp)
c$$$         enddo
c$$$      endif
CCC_   + result
      do jz0 = 0, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, KTO)
     $           = (VMTI(jh, jz, KTIU) * WH(jh,KHWx)
     $             +VMTI(jh, jz, KTIV) * WH(jh,KHWy))
         enddo
      enddo
c$$$      jchk = jchk + 1
c$$$      if (jchk.gt.999) then
c$$$         jz = KZ0 + NZ - 1
c$$$         do jh = 1, MH
c$$$            write (*, *) 'GUO', jchk,
c$$$     $           WH (jh, KHWx), WH (jh, KHWy),
c$$$     $           VMTI(jh,jz,KTIU),VMTI(jh,jz,KTIV)
c$$$         enddo
c$$$      endif
      return
      END
CCC_ & MMWupr  ## A/preparation (UP1)
      subroutine MMWupr
     O    (iErr,
     O     VMTW,  WH,    CW,
     I     VMI,   VMC,   VMTI,  QM,   F0,
     I     WW,    WZV,
     I     MH,    LH,    NZ,    LZ,   KZ0,
     I     ipCG,  LCG,   ipKW,  iMA,  MSW)
CCC_  - Description
CC
CC    Assumption: ub==ui==0 when int ue==0
CC
CCC_  * Declaration
      implicit none
c
      _INTENT(OUT,  integer)  iErr
c
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
      _INTENT(IN,   integer)  LCG
c
      _INTENT(INOUT,_REALSTD) VMTW (LH, LZ, *)
      _INTENT(OUT,  _REALSTD) CW   (LH, LZ, *)
      _INTENT(OUT,  _REALSTD) WH   (LH, *)
c
      _INTENT(IN,   _REALSTD) VMI  (LH, *)
      _INTENT(IN,   _REALSTD) VMC  (LH, *)
      _INTENT(IN,   _REALSTD) VMTI (LH, LZ, *)
      _INTENT(IN,   _REALSTD) QM   (LH, *)
      _INTENT(IN,   _REALSTD) F0
c
      _INTENT(IN,   _REALSTD) WW   (*)
      _INTENT(IN,   _REALSTD) WZV  (LZ, *)
      _INTENT(IN,   integer)  ipKW (*), iMA (*)
      _INTENT(IN,   integer)  ipCG (LCG, *)
c
      _INTENT(IN,   integer)  MSW
c
      integer jh, jz, jz0, jzb, jzs
c
      integer jwFC
CCC_  * Body
      iErr = 0
      jzb = KZ0
CCC_   . upwind mask
      do jh = 1, MH
         WH (jh, VMW_W1) = 1.0d0
     $        - (QM (jh, VMQU_WXp) + QM (jh, VMQU_WXm))
         WH (jh, VMW_W2) = 1.0d0
     $        - (QM (jh, VMQU_WYp) + QM (jh, VMQU_WYm))
      enddo
CCC_   . grad H upwind
      call MMWugu
     O    (WH,    VMW_W3, VMW_W4, VMW_W5,
     W     CW,
     I     VMC,   VMC_NHa,
     I     QM,    WW,
     I     MH,    LH,
     I     ipCG,  LCG,   ipKW,  iMA)
CCC_   . -P1  div H (int dzeta ui + zeta ub)
CCC_    * int dzeta ui + zeta ub (on b)
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_W1)
     $           = VMTW (jh, jz, VMTW_ziUIb)
     $           + WZV (jz, VMVZ_Za) * VMTI (jh, jzb, VMTI_UHb)
         enddo
      enddo
CCC_    * div interpol
      call AKCguw
     O    (CW,
     I     VMTW,  MH, LH, NZ, LZ, KZ0, VMTW_W1,
     I     iMA,  ipCG (1, CGV_Ub))
CCC_    * div (W3x: xdiv)
      call AKGwaw
     M    (VMTW,
     I     CW,   WW,
     I     MH,   LH,  NZ,  LZ, KZ0, VMTW_W3x, VMTW_W1,
     I     ipKW, CGV_Ub_DXba, ipCG (1, CGV_Ub))
CCC_    * L b:a (W2: interpol)
      call AKGwaw
     M    (VMTW,
     I     CW,   WW,
     I     MH,   LH,  NZ,  LZ, KZ0, VMTW_W2, VMTW_W1,
     I     ipKW, CGV_Ub_Lba, ipCG (1, CGV_Ub))
CCC_    * int dzeta vi + zeta vb (on c)
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_W1)
     $           = VMTW (jh, jz, VMTW_ziVIc)
     $           + WZV (jz, VMVZ_Za) * VMTI (jh, jzb, VMTI_VHc)
         enddo
      enddo
CCC_    * div interpol
      call AKCguw
     O    (CW,
     I     VMTW,  MH, LH, NZ, LZ, KZ0, VMTW_W1,
     I     iMA,  ipCG (1, CGV_Vc))
CCC_    * div (W3y: ydiv)
      call AKGwaw
     M    (VMTW,
     I     CW,   WW,
     I     MH,   LH,  NZ,  LZ, KZ0, VMTW_W3y, VMTW_W1,
     I     ipKW, CGV_Vc_DYca, ipCG (1, CGV_Vc))
CCC_    * Note: L c:a pending (later)
CCC_    * H div U, masked
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_divHziue)
     $           = (VMTW (jh, jz, VMTW_W3x) * WH(jh,VMW_W1)
     $             +VMTW (jh, jz, VMTW_W3y) * WH(jh,VMW_W2))
     $           * VMC(jh, VMC_NHa)
         enddo
      enddo
CCC_    * L c:a (W3y)
      call AKGwaw
     M    (VMTW,
     I     CW,   WW,
     I     MH,   LH,  NZ,  LZ, KZ0, VMTW_W3y, VMTW_W1,
     I     ipKW, CGV_Vc_Lca, ipCG (1, CGV_Vc))
c
c$$$      jz = KZ0 + NZ - 1
c$$$      call UDAtss
c$$$     I    ('DX', VMTW(1,jz,VMTW_W2), QM(1,VMQU_UEava), MH, -1)
c$$$      call UDAtss
c$$$     I    ('DY', VMTW(1,jz,VMTW_W3y),QM(1,VMQU_VEava), MH, -1)
CCC_    * U grad H upwind
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_divHziue) =
     $           VMTW (jh, jz, VMTW_divHziue)
     $           + (VMTW (jh, jz, VMTW_W2)  * WH(jh,VMW_W3)
     $                                      * WH(jh,VMW_W1)
     $             +VMTW (jh, jz, VMTW_W3y) * WH(jh,VMW_W4)
     $                                      * WH(jh,VMW_W2))
         enddo
      enddo
CCC_    * Hnew Ue:a
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_W1) =
     $           VMTW (jh, jz, VMTW_W2) * VMC(jh, VMC_NHa)
         enddo
      enddo
CCC_    * xdiv HU upwind
      call MMWudu
     O    (VMTW,  VMTW_W3x, VMTW_W1, VMTW_W2,
     W     CW,
     I     QM,           WW,
     I     KWO_DXab,     KWO_Lba,
     I     VMQU_WXp,     VMQU_WXm,
     I     MH,    LH,    NZ,    LZ,   KZ0,
     I     ipKW,  iMA)
CCC_    * Hnew Ve:a
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_W1) =
     $           VMTW (jh, jz, VMTW_W3y) * VMC(jh, VMC_NHa)
         enddo
      enddo
CCC_    * ydiv HU upwind
      call MMWudu
     O    (VMTW,  VMTW_W3y, VMTW_W1, VMTW_W2,
     W     CW,
     I     QM,           WW,
     I     KWO_DYac,     KWO_Lca,
     I     VMQU_WYp,     VMQU_WYm,
     I     MH,    LH,    NZ,    LZ,   KZ0,
     I     ipKW,  iMA)
CCC_    * div HU upwind
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_divHziue) =
     $           VMTW (jh, jz, VMTW_divHziue)
     $           + (VMTW (jh, jz, VMTW_W3x)
     $             +VMTW (jh, jz, VMTW_W3y))
         enddo
      enddo
CCC_    * final/b
      do jh = 1, MH
         VMTW (jh, jzb, VMTW_divHziue) = 0.0d0
      enddo
CCC_   . P2+P3
CCC_    * ui:a Znew:a + zeta ub H:new:a
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_W1)
     $           = VMTI (jh, jz, VMTI_UHa)
     $           * (VMC(jh,VMC_NBa) + WZV(jz,VMVZ_Za) * VMC(jh,VMC_NHa))
     $           +  VMTI (jh, jzb, VMTI_UHa)
     $           * (                + WZV(jz,VMVZ_Za) * VMC(jh,VMC_NHa))
         enddo
      enddo
      do jh = 1, MH
         VMTW (jh, jzb, VMTW_W1)
     $        =  VMTI (jh, jzb, VMTI_UHa) * VMC(jh,VMC_NBa)
      enddo
CCC_    * div upwind
      call MMWudu
     O    (VMTW,  VMTW_W3x, VMTW_W1, VMTW_W2,
     W     CW,
     I     QM,           WW,
     I     KWO_DXab,     KWO_Lba,
     I     VMQU_WXp,     VMQU_WXm,
     I     MH,    LH,    NZ,    LZ,   KZ0,
     I     ipKW,  iMA)
CCC_    * vi:a Znew:a + zeta vb H:new:a
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_W1)
     $           = VMTI (jh, jz, VMTI_VHa)
     $           * (VMC(jh,VMC_NBa) + WZV(jz,VMVZ_Za) * VMC(jh,VMC_NHa))
     $           +  VMTI (jh, jzb, VMTI_VHa)
     $           * (                + WZV(jz,VMVZ_Za) * VMC(jh,VMC_NHa))
         enddo
      enddo
      do jh = 1, MH
         VMTW (jh, jzb, VMTW_W1)
     $        =  VMTI (jh, jzb, VMTI_VHa) * VMC(jh,VMC_NBa)
      enddo
CCC_    * div upwind
      call MMWudu
     O    (VMTW,  VMTW_W3y, VMTW_W1, VMTW_W2,
     W     CW,
     I     QM,           WW,
     I     KWO_DYac,     KWO_Lca,
     I     VMQU_WYp,     VMQU_WYm,
     I     MH,    LH,    NZ,    LZ,   KZ0,
     I     ipKW,  iMA)
CCC_    * div (uiZ + ub zeta H) upwind
      do jz0 = 0, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_ugradz) =
     $           + (VMTW (jh, jz, VMTW_W3x)+VMTW (jh, jz, VMTW_W3y))
         enddo
      enddo
CCC_    * div u upwind
      call MMWudy
     O    (VMTW,  VMTW_W3x, VMTW_W2,
     W     CW,
     I     VMTI,  VMTI_UHa,
     I     QM,           WW,
     I     KWO_DXab,     KWO_Lba,
     I     VMQU_WXp,     VMQU_WXm,
     I     MH,    LH,    NZ,    LZ,   KZ0,
     I     ipKW,  iMA)
      call MMWudy
     O    (VMTW,  VMTW_W3y, VMTW_W2,
     W     CW,
     I     VMTI,  VMTI_VHa,
     I     QM,           WW,
     I     KWO_DYac,     KWO_Lca,
     I     VMQU_WYp,     VMQU_WYm,
     I     MH,    LH,    NZ,    LZ,   KZ0,
     I     ipKW,  iMA)
CCC_    * - Z div ui - zeta H div ub
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_ugradz) =
     $           VMTW (jh, jz, VMTW_ugradz)
     $           - ((VMTW (jh, jz, VMTW_W3x)+VMTW (jh, jz, VMTW_W3y))
     $               *(VMC(jh,VMC_NBa)+WZV(jz,VMVZ_Za)*VMC(jh,VMC_NHa))
     $             +(VMTW (jh, jzb,VMTW_W3x)+VMTW (jh, jzb,VMTW_W3y))
     $               *(               +WZV(jz,VMVZ_Za)*VMC(jh,VMC_NHa)))
         enddo
      enddo
      do jh = 1, MH
         VMTW (jh, jzb, VMTW_ugradz) =
     $        VMTW (jh, jzb, VMTW_ugradz)
     $        - (VMTW (jh, jzb, VMTW_W3x)+VMTW (jh, jzb, VMTW_W3y))
     $           * VMC(jh,VMC_NBa)
      enddo
CCC_    * grad b upwind to W5, W6
      call AKBuaz
     O    (WH (1, VMW_W5),   CW,
     I     VMC(1, VMC_BXbM), QM,
     I     MH,    LH,  VMQU_WXp, VMQU_WXm,
     I     ipKW,  iMA, KWO_Lba,  KWM_M)
      call AKBuaz
     O    (WH (1, VMW_W6),   CW,
     I     VMC(1, VMC_BYcM), QM,
     I     MH,    LH,  VMQU_WYp, VMQU_WYm,
     I     ipKW,  iMA, KWO_Lca,  KWM_M)
CCC_    * ui:a (grad b + zeta grad H) upwind
CCC_    * zeta ub:a grad H upwind
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_ugradz) =
     $           VMTW (jh, jz, VMTW_ugradz) +
     $           ((VMTI(jh, jz, VMTI_UHa)
     $             * (WH(jh,VMW_W5) + WZV(jz,VMVZ_Za)*WH(jh,VMW_W3))
     $             + VMTI(jh, jzb, VMTI_UHa)
     $             * (              + WZV(jz,VMVZ_Za)*WH(jh,VMW_W3)))
     $             * WH(jh,VMW_W1)
     $            +(VMTI(jh, jz, VMTI_VHa)
     $             * (WH(jh,VMW_W6) + WZV(jz,VMVZ_Za)*WH(jh,VMW_W4))
     $             + VMTI(jh, jzb, VMTI_VHa)
     $             * (              + WZV(jz,VMVZ_Za)*WH(jh,VMW_W4)))
     $             * WH(jh,VMW_W2))
         enddo
      enddo
      do jh = 1, MH
         VMTW (jh, jzb, VMTW_ugradz) =
     $        VMTW (jh, jzb, VMTW_ugradz) +
     $           ((VMTI(jh, jzb, VMTI_UHa) * WH(jh,VMW_W5))
     $             * WH(jh,VMW_W1)
     $            +(VMTI(jh, jzb, VMTI_VHa) * WH(jh,VMW_W6))
     $             * WH(jh,VMW_W2))
      enddo
CCC_    * bottom
      RETURN
      END
CCC_ & MMWugu  ## A/preparation (UP1) upwind gradient
      subroutine MMWugu
     O    (VW,    KVWx,  KVWy,  KVWw,
     W     CW,
     I     VI,    KVI,
     I     QM,    WW,
     I     MH,    LH,
     I     ipCG,  LCG,   ipKW,  iMA)
CCC_  * Declaration
      implicit none
c
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  LCG
c
      _INTENT(INOUT,_REALSTD) VW (LH, *)
      _INTENT(OUT,  _REALSTD) CW (LH, *)
      _INTENT(IN,   _REALSTD) VI (LH, *)
      _INTENT(IN,   _REALSTD) QM (LH, *)
c
      _INTENT(IN,   integer)  KVWx, KVWy, KVWw
      _INTENT(IN,   integer)  KVI
c
      _INTENT(IN,   _REALSTD) WW   (*)
      _INTENT(IN,   integer)  ipKW (*), iMA (*)
      _INTENT(IN,   integer)  ipCG (LCG, *)
CCC_  * body
CCC_   . clone group
      call AKCgux
     O    (CW,
     I     VI,   MH,   LH, KVI,
     I     iMA,  ipCG (1, CGB_XHaN))
CCC_   . operation
cc      xgrad to Y, ygrad to W temporaly
      call AKGwaz
     M    (VW (1, KVWy),
     I     CW,   VI(1, KVI), WW,
     I     MH,   LH,  ipKW, CGB_XHaN_GXab, ipCG (1, CGB_XHaN))
      call AKGwaz
     M    (VW (1, KVWw),
     I     CW,   VI(1, KVI), WW,
     I     MH,   LH,  ipKW, CGB_XHaN_GYac, ipCG (1, CGB_XHaN))
CCC_   + upwind switch
CC     Y (xgrad) switched to X
CC     W (ygrad) switched to Y
      call AKBuax
     O    (VW, CW,
     I     QM,
     I     MH,   LH,
     I     KVWx, KVWy, VMQU_WXp, VMQU_WXm,
     I     ipKW, iMA,  KWO_Lba,  KWM_M)
      call AKBuax
     O    (VW,   CW,
     I     QM,
     I     MH,    LH,
     I     KVWy,  KVWw, VMQU_WYp, VMQU_WYm,
     I     ipKW,  iMA,  KWO_Lca,  KWM_M)
CCC_   + result
      return
      END
CCC_ & MMWudu  ## A/preparation (UP1) upwind divergence
      subroutine MMWudu
     O    (VW,    KVWo,  KVWi,  KVWw,
     W     CW,
     I     QM,    WW,
     I     KOPD,  KOPL,  KQp,   KQm,
     I     MH,    LH,    NZ,    LZ,   KZ0,
     I     ipKW,  iMA)
CCC_  * Declaration
      implicit none
c
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
c
      _INTENT(INOUT,_REALSTD) VW   (LH, LZ, *)
      _INTENT(OUT,  _REALSTD) CW   (LH, LZ, *)
      _INTENT(IN,   _REALSTD) QM   (LH, *)
c
      _INTENT(IN,   integer)  KVWo, KVWi, KVWw
      _INTENT(IN,   integer)  KOPD, KOPL
      _INTENT(IN,   integer)  KQp,  KQm
c
      _INTENT(IN,   _REALSTD) WW   (*)
      _INTENT(IN,   integer)  ipKW (*), iMA (*)
CCC_  * body
      call AKBwaw
     O    (VW,   CW,
     I     WW,
     I     MH,   LH,  NZ, LZ, KZ0,   KVWw, KVWi,
     I     ipKW, iMA, KOPD,   KWM_M)
      call AKBuaw
     O    (VW,   CW,
     I     QM,
     I     MH,   LH,   NZ,   LZ,  KZ0,
     I     KVWo, KVWw, KQp,  KQm,
     I     ipKW, iMA,  KOPL, KWM_M)
      return
      END
CCC_ & MMWudy  ## A/preparation (UP1) upwind divergence input sep
      subroutine MMWudy
     O    (VW,    KVWo,  KVWw,
     W     CW,
     I     VI,    KVI,
     I     QM,    WW,
     I     KOPD,  KOPL,  KQp,   KQm,
     I     MH,    LH,    NZ,    LZ,   KZ0,
     I     ipKW,  iMA)
CCC_  * Declaration
      implicit none
c
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
c
      _INTENT(INOUT,_REALSTD) VW   (LH, LZ, *)
      _INTENT(OUT,  _REALSTD) CW   (LH, LZ, *)
      _INTENT(IN,   _REALSTD) QM   (LH, *)
      _INTENT(IN,   _REALSTD) VI   (LH, LZ, *)
c
      _INTENT(IN,   integer)  KVWo, KVWw, KVI
      _INTENT(IN,   integer)  KOPD, KOPL
      _INTENT(IN,   integer)  KQp,  KQm
c
      _INTENT(IN,   _REALSTD) WW   (*)
      _INTENT(IN,   integer)  ipKW (*), iMA (*)
CCC_  * body
      call AKBway
     O    (VW (1,1,KVWw), CW,
     I     VI (1,1,KVI),  WW,
     I     MH,   LH,  NZ, LZ,   KZ0,
     I     ipKW, iMA, KOPD,     KWM_M)
      call AKBuaw
     O    (VW,   CW,
     I     QM,
     I     MH,   LH,   NZ,   LZ,  KZ0,
     I     KVWo, KVWw, KQp,  KQm,
     I     ipKW, iMA,  KOPL, KWM_M)
      return
      END
CCC_ & MMWouy  ## A/preparation (UP1) upwind operator with akbway
      subroutine MMWouy
     O    (VMTW,  KTWO,
     W     CW,
     I     VMTI,  KTIX,  KTIY,
     I     QM,    WW,
     I     KOPX,  KOPY,  KOPLX, KOPLY,
     I     MH,    LH,    NZ,    LZ,   KZ0,
     I     ipCG,  LCG,   ipKW,  iMA)
CCC_  * Declaration
      implicit none
c
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
      _INTENT(IN,   integer)  LCG
c
      _INTENT(INOUT,_REALSTD) VMTW (LH, LZ, *)
      _INTENT(OUT,  _REALSTD) CW   (LH, LZ, *)
      _INTENT(IN,   _REALSTD) VMTI (LH, LZ, *)
      _INTENT(IN,   _REALSTD) QM   (LH, *)
c
      _INTENT(IN,   integer)  KTWO
      _INTENT(IN,   integer)  KTIX, KTIY
      _INTENT(IN,   integer)  KOPX, KOPY, KOPLX, KOPLY
c
      _INTENT(IN,   _REALSTD) WW   (*)
      _INTENT(IN,   integer)  ipKW (*), iMA (*)
      _INTENT(IN,   integer)  ipCG (LCG, *)
c
      integer jh, jz, jz0, jzb, jzs
CCC_  * body
CCC_   + operation
      call AKBway
     O    (VMTW (1,1,VMTW_W3x), CW,
     I     VMTI (1,1,KTIX),     WW,
     I     MH,   LH,  NZ, LZ,   KZ0,
     I     ipKW, iMA, KOPX,     KWM_M)
      call AKBway
     O    (VMTW (1,1,VMTW_W3y), CW,
     I     VMTI (1,1,KTIY),     WW,
     I     MH,   LH,  NZ, LZ,   KZ0,
     I     ipKW, iMA, KOPY,     KWM_M)
CCC_   + upwind switch
      call AKBuaw
     O    (VMTW, CW,
     I     QM,
     I     MH,   LH,  NZ,  LZ,  KZ0,
     I     VMTW_W1,   VMTW_W3x, VMQU_WXp, VMQU_WXm,
     I     ipKW, iMA, KOPLX,    KWM_M)
      call AKBuaw
     O    (VMTW, CW,
     I     QM,
     I     MH,   LH,  NZ,  LZ,  KZ0,
     I     VMTW_W2,   VMTW_W3y, VMQU_WYp, VMQU_WYm,
     I     ipKW, iMA, KOPLY,    KWM_M)
CCC_   + result
      do jz0 = 0, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, KTWO)
     $           = (VMTW (jh, jz, VMTW_W1) + VMTW (jh, jz, VMTW_W2))
         enddo
      enddo
      return
      END
CCC_ & MMWouw  ## A/preparation (UP1) upwind operator with akbwaw
      subroutine MMWouw
     O    (VMTW,  KTWO,  KTWX,  KTWY,
     W     CW,
     I     QM,    WW,
     I     KOPX,  KOPY,  KOPLX, KOPLY,
     I     MH,    LH,    NZ,    LZ,   KZ0,
     I     ipCG,  LCG,   ipKW,  iMA)
CCC_  * Declaration
      implicit none
c
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
      _INTENT(IN,   integer)  LCG
c
      _INTENT(INOUT,_REALSTD) VMTW (LH, LZ, *)
      _INTENT(OUT,  _REALSTD) CW   (LH, LZ, *)
      _INTENT(IN,   _REALSTD) QM   (LH, *)
c
      _INTENT(IN,   integer)  KTWO
      _INTENT(IN,   integer)  KTWX, KTWY
      _INTENT(IN,   integer)  KOPX, KOPY, KOPLX, KOPLY
c
      _INTENT(IN,   _REALSTD) WW   (*)
      _INTENT(IN,   integer)  ipKW (*), iMA (*)
      _INTENT(IN,   integer)  ipCG (LCG, *)
c
      integer jh, jz, jz0, jzb, jzs
CCC_  * body
CCC_   + operation
      call AKBwaw
     O    (VMTW, CW,
     I     WW,
     I     MH,   LH,  NZ, LZ, KZ0,   VMTW_W3x, KTWX,
     I     ipKW, iMA, KOPX,   KWM_M)
      call AKBwaw
     O    (VMTW, CW,
     I     WW,
     I     MH,   LH,  NZ, LZ, KZ0,   VMTW_W3y, KTWY,
     I     ipKW, iMA, KOPY,   KWM_M)
CCC_   + upwind switch
      call AKBuaw
     O    (VMTW, CW,
     I     QM,
     I     MH,   LH,  NZ,  LZ,  KZ0,
     I     VMTW_W1,   VMTW_W3x, VMQU_WXp, VMQU_WXm,
     I     ipKW, iMA, KOPLX,    KWM_M)
      call AKBuaw
     O    (VMTW, CW,
     I     QM,
     I     MH,   LH,  NZ,  LZ,  KZ0,
     I     VMTW_W2,   VMTW_W3y, VMQU_WYp, VMQU_WYm,
     I     ipKW, iMA, KOPLY,    KWM_M)
CCC_   + result
      do jz0 = 0, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, KTWO)
     $           = (VMTW (jh, jz, VMTW_W1) + VMTW (jh, jz, VMTW_W2))
         enddo
      enddo
      return
      END
CCC_ & MMWugb  ## replace bottom bc to u grad b
      subroutine MMWugb
     O    (iErr,
     O     VMTW,  CW,  WH,
     I     VMTI,  VMI, WW,
     I     MH,    LH,  NZ,    LZ,   KZ0,
     I     ipKW,  iMA)
CCC_ + Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
c
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
c
      _INTENT(INOUT,_REALSTD) VMTW (LH, LZ, *)
      _INTENT(OUT,  _REALSTD) WH   (LH, *)
      _INTENT(OUT,  _REALSTD) CW   (*)
c
      _INTENT(IN,   _REALSTD) VMTI (LH, LZ, *)
c
      _INTENT(IN,   _REALSTD) VMI  (LH, *)
c
      _INTENT(IN,   _REALSTD) WW   (*)
      _INTENT(IN,   integer)  ipKW (*), iMA (*)
c
      integer jz, jh
CCC_ + Body
      iErr = 0
      call MTStpd
     O    (WH,     CW,
     I     VMI,    WW,
     I     MH,     LH,
     I     VMW_W2, VMW_W1,  VMI_Ba, KWO_GXab, KWO_Lba, ipKW, iMA)
      call MTStpd
     O    (WH,     CW,
     I     VMI,    WW,
     I     MH,     LH,
     I     VMW_W3, VMW_W1,  VMI_Ba, KWO_GYac, KWO_Lca, ipKW, iMA)
      jz = KZ0
      do jh = 1, MH
         VMTW (jh, jz, VMTW_ugradz) =
     $        VMTI (jh, KZ0, VMTI_UHa) * WH (jh, VMW_W2)
     $       +VMTI (jh, KZ0, VMTI_VHa) * WH (jh, VMW_W3)
      enddo
      RETURN
      END
CCC_ & MMWabi  ## A bottom and integral
      subroutine MMWabi
     O    (iErr,
     O     VMTI,  VMTW,  WH,
     I     VMI,   VMC,   VMHB,  DT,   WZV,
     I     MH,    LH,    NZ,    LZ,   KZ0)
CCC_  * Declaration
      implicit none
c
      _INTENT(OUT,  integer)  iErr
c
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
c
      _INTENT(OUT,  _REALSTD) WH   (LH, *)
      _INTENT(INOUT,_REALSTD) VMTI (LH, LZ, *)
      _INTENT(INOUT,_REALSTD) VMTW (LH, LZ, *)
c
      _INTENT(IN,   _REALSTD) VMI  (LH, *)
      _INTENT(IN,   _REALSTD) VMC  (LH, *)
      _INTENT(IN,   _REALSTD) VMHB (LH, *)
      _INTENT(IN,   _REALSTD) DT
      _INTENT(IN,   _REALSTD) WZV  (LZ, *)
c
      integer jh, jz, jz0
CCC_  * Body
      iErr = 0
CCC_   + db/dt
      do jh = 1, MH
         WH (jh, VMW_W1) = (VMC (jh, VMC_NBa) - VMI (jh, VMI_Ba)) / DT
      enddo
CCC_   + db/dt + Mb + ub grad b
c$$$      do jh = 1, MH
c$$$         write (*, *) 'WCHK', jh,
c$$$     $        VMI (jh, VMI_Ba),  VMI (jh, VMI_Ha),
c$$$     $        VMC (jh, VMC_NBa), VMC (jh, VMC_NHa),
c$$$     $        WH (jh, VMW_W1)
c$$$      enddo
      jz = KZ0
      do jh = 1, MH
         VMTI (jh, jz, VMTI_WHa) =
     $        (WH (jh, VMW_W1) + VMHB (jh, VMHB_MB))
     $        + VMTW (jh, jz, VMTW_ugradz)
      enddo
CCC_   + W interior
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTI (jh, jz, VMTI_WHa) =
     $           - VMTW (jh, jz, VMTW_divHziue)
     $           + VMTW (jh, jz, VMTW_ugradz)
         enddo
      enddo
c$$$CCC_   + W advection
c$$$      call MMTswa
c$$$     O    (iErr,
c$$$     M     VMTI,
c$$$     I     MH,    LH,    NZ,  LZ,  KZ0)
      RETURN
      END
CCC_ & MMWasf  ## A/surface velocity check
      subroutine MMWasf
     O    (iErr,
     O     WH,    VMTW,
     I     VMTI,
     I     VMI,   VMC,   VMHB,  DT,
     I     MH,    LH,    NZ,    LZ,   KZ0)
CCC_  * Declaration
      implicit none
c
      _INTENT(OUT,  integer)  iErr
c
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
c
      _INTENT(OUT,  _REALSTD) WH   (LH, *)
      _INTENT(OUT,  _REALSTD) VMTW (LH, LZ, *)
c
      _INTENT(IN,   _REALSTD) VMTI (LH, LZ, *)
c
      _INTENT(IN,   _REALSTD) VMI  (LH, *)
      _INTENT(IN,   _REALSTD) VMC  (LH, *)
      _INTENT(IN,   _REALSTD) VMHB (LH, *)
      _INTENT(IN,   _REALSTD) DT
c
      integer jh, jzs, jzb
CCC_  * Body
      iErr = 0
#if 1 /* Wi computation */
      jzs = KZ0 + NZ - 1
      jzb = KZ0
c$$$CCC_   + us grad s - ub grad b
c$$$      do jh = 1, MH
c$$$         WH (jh, VMW_W3) =
c$$$     $        +(VMTW (jh, jzs, VMTW_zuegradH)
c$$$     $        + VMTW (jh, jzb, VMTW_divHziue))
c$$$     $        + VMTW (jh, jzs, VMTW_uigradb)
c$$$      enddo
c$$$CCC_   + Wi surface (not We)
c$$$      do jh = 1, MH
c$$$         WH (jh, VMW_W1) =
c$$$     $        (VMC (jh, VMC_dHdtE) - VMHB (jh, VMHB_TMBa))
c$$$     $        + WH (jh, VMW_W3)
c$$$      enddo
CCC_   . Wi surface (not We)
C          ugradz equals to (us grad s - ub grad b) at the surface
      do jh = 1, MH
         WH (jh, VMW_W1) =
     $        (VMC (jh, VMC_dHdtE) - VMHB (jh, VMHB_TMBa))
     $        + VMTW (jh, jzs, VMTW_ugradz)
      enddo
      do jh = 1, MH
         if (VMC (jh, VMC_HE).gt.0.0d0) then
            WH (jh, VMW_W1) = WH (jh, VMW_W1)- VMTI (jh, jzs, VMTI_WHa)
         else
            WH (jh, VMW_W1) = 0.0d0
         endif
      enddo
#else /* obsolete Ws version */
CCC_   + s[new]
      do jh = 1, MH
         WH (jh, VMW_W3) = VMC (jh, VMC_NBa) + VMC (jh, VMC_NHa)
      enddo
CCC_   + ds/dt
      do jh = 1, MH
         WH (jh, VMW_W2) = (WH (jh, VMW_W3)
     $        - (VMI (jh, VMI_Ba) + VMC (jh, VMC_HCa))) / DT
      enddo
      jzs = KZ0 + NZ - 1
      jzb = KZ0
CCC_   + us grad s
      do jh = 1, MH
         WH (jh, VMW_W3) =
     $        +(VMTW (jh, jzs, VMTW_zuegradH)
     $        + VMTW (jh, jzb, VMTW_divHziue))
     $        +(VMTW (jh, jzs, VMTW_uigradb)
     $        + VMTW (jh, jzb, VMTW_uigradb))
      enddo
CCC_   + W surface
      do jh = 1, MH
         WH (jh, VMW_W1) =
     $        (WH (jh, VMW_W2) - VMHB (jh, VMHB_MS)) + WH (jh, VMW_W3)
      enddo
CCC_   + final [TODO: check about Hnew mask]
      do jh = 1, MH
         if (VMC (jh, VMC_NHa).gt.0.0d0) then
c$$$            write (*, *) 'WE', jh, WH (jh, VMW_W1),
c$$$     $           VMTI (jh, jzs, VMTI_WHa) + VMTI (jh, jzb, VMTI_WHa),
c$$$     $           WH (jh, VMW_W1) -
c$$$     $           (VMTI (jh, jzs, VMTI_WHa) + VMTI (jh, jzb, VMTI_WHa))
            WH (jh, VMW_W1) = WH (jh, VMW_W1)
     $           - (VMTI (jh, jzs, VMTI_WHa) + VMTI (jh, jzb, VMTI_WHa))
         else
            WH (jh, VMW_W1) = 0.0d0
         endif
      enddo
#endif /* obsolete Ws version */
c$$$CCC_   + ui(s) grad s[old] = div (s[old] ui(s)) - s[old] (div ui(s))
c$$$      do j = 1, MH
c$$$         WH (j, VMW_W2) = VMTW (j, KZS, VMTW_DIVuh) * VMI (j, VMI_Sa)
c$$$      enddo
c$$$      do j = 1, MH
c$$$         WH (j, VMW_W2) = VMTW (j, KZS, VMTW_DIVzuh) - WH (j, VMW_W2)
c$$$      enddo
c$$$CCC_   + ub grad s[new] = div (s[new] ub) - s[new] (div ub)
c$$$      do j = 1, MH
c$$$         WH (j, VMW_W1) = VMTW (j, KZ0, VMTW_DIVuh) * WH (j, VMW_W3)
c$$$      enddo
c$$$      do j = 1, MH
c$$$         WH (j, VMW_W1) = VMTW (j, KZ0, VMTW_DIVuii) - WH (j, VMW_W1)
c$$$      enddo
c$$$CCC_   + uh grad s
c$$$      call UV0uaa (WH, MH, LH, VMW_W1, VMW_W2)
c$$$CCC_   + ds/dt
c$$$      do j = 1, MH
c$$$         WH (j, VMW_W2) = (WH (j, VMW_W3)
c$$$     $        - (VMI (j, VMI_Ba) + VMC (j, VMC_HCa))) / DT
c$$$      enddo
c$$$CCC_   + ds/dt - Mb
c$$$      do j = 1, MH
c$$$         WH (j, VMW_W2) = WH (j, VMW_W2) - VMHB (j, VMHB_MS)
c$$$      enddo
c$$$CCC_   + final [TODO: check about Hnew mask]
c$$$      call UV0uaa (WH, MH, LH, VMW_W1, VMW_W2)
c$$$      do j = 1, MH
c$$$         if (VMC (j, VMC_NHa).gt.0.0d0) then
c$$$            WH (j, VMW_W1) = WH (j, VMW_W1)
c$$$     $           - (VMTI (j, KZS, VMTI_WHa) + VMTI (j, KZ0, VMTI_WHa))
c$$$         else
c$$$            WH (j, VMW_W1) = 0.0d0
c$$$         endif
c$$$      enddo
      RETURN
      END
CCC_* scheme/S - variation Sally (just for test)
CCC_ & MMWsst  ## S/suite
      subroutine MMWsst
     O    (iErr,
     M     VMHW,  VMTI,  VMTW,
     W     WH,    CW,
     I     VMI,   VMC,   VMHB, WZV,  T,   DT,
     I     WW,
     I     MH,    LH,    NZ,   LZ,   KZ0,
     I     ipCG,  LCG,   ipKW, iMA,  IE,  IFP)
CCC_  - Description
CC     W(k) = W(1) - H * (div Uint)
CC                 + (dbdx * (u(k)-u(1)) + dbdy * (v(k)-v(1)))
CC                 + (dHdx * (u(k)z(k) - u(1)z(1)) - Uint)
CC                 + (dHdy * (v(k)z(k) - v(1)z(1)) - Vint)
CC     Terms
CC      divUint  xdivUint  ydivVint
CC      Uint:a   Uint:b    Vint:a  Vint:c
CC      U:a      V:a
CC      dHdx:a   dHdy:a    dbdx:a  dbdy:a
CCC_  - Declaration
      implicit none
c
      _INTENT(OUT,  integer)  iErr
c
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
      _INTENT(IN,   integer)  LCG
c
      _INTENT(OUT,  _REALSTD) WH   (LH, *)
      _INTENT(OUT,  _REALSTD) CW   (*)
c
      _INTENT(INOUT,_REALSTD) VMHW (LH, *)
      _INTENT(INOUT,_REALSTD) VMTI (LH, LZ, *)
      _INTENT(INOUT,_REALSTD) VMTW (LH, LZ, *)
c
      _INTENT(IN,   _REALSTD) VMI  (LH, *)
      _INTENT(IN,   _REALSTD) VMC  (LH, *)
      _INTENT(IN,   _REALSTD) VMHB (LH, *)
      _INTENT(IN,   _REALSTD) T, DT
c
      _INTENT(IN,   _REALSTD) WZV  (LZ, *)
      _INTENT(IN,   _REALSTD) WW   (*)
      _INTENT(IN,   integer)  ipKW (*), iMA (*), IE (*)
      _INTENT(IN,   integer)  ipCG (*)
c
      _INTENT(IN,   integer)  IFP
c
#define UINTb 1
#define VINTc 2
#define UINTa 3
#define VINTa 4
#define DXUI  5
#define DYVI  6
      integer    LHW,        LZW
      parameter (LHW = OPT_MMWCOL_SALLY_HSIZE)
      parameter (LZW = OPT_MMWCOL_SALLY_ZSIZE)
      _REALSTD WTW (LHW * LZW * 8)
c
      integer   jh, jz, jzz
CCC_  * Body
      iErr = 0
CCC_   + preparation
      if (iErr.eq.0) then
         call MMWspr
     O       (iErr,
     O        VMHW,  VMTI,  VMTW,  CW,
     I        WW,
     I        MH,    LH,    NZ,    LZ,   KZ0,
     I        ipCG,  LCG,   ipKW,  iMA)
      endif
c
      call MTSvin
     O    (WTW,
     I     VMTI,  WZV, MH, LH, NZ, LZ, KZ0,
     I     UINTb, VMTI_UHb)
      call MTSvin
     O    (WTW,
     I     VMTI,  WZV, MH, LH, NZ, LZ, KZ0,
     I     UINTa, VMTI_UHa)
      call MTSvin
     O    (WTW,
     I     VMTI,  WZV, MH, LH, NZ, LZ, KZ0,
     I     VINTc, VMTI_VHc)
      call MTSvin
     O    (WTW,
     I     VMTI,  WZV, MH, LH, NZ, LZ, KZ0,
     I     VINTa, VMTI_VHa)
c
      call AKBwaw
     O    (WTW,  CW,
     I     WW,
     I     MH,   LH,  NZ, LZ,   KZ0, DXUI, UINTb,
     I     ipKW, iMA, KWO_DXba, KWM_M)
      call AKBwaw
     O    (WTW,  CW,
     I     WW,
     I     MH,   LH,  NZ, LZ,   KZ0, DYVI, VINTc,
     I     ipKW, iMA, KWO_DYca, KWM_M)
c
c$$$      call MTStpd
c$$$     O    (WH,     CW,
c$$$     I     VMC,    WW,
c$$$     I     MH,     LH,
c$$$     I     VMW_W2, VMW_W1,  VMC_NBa, KWO_GXab, KWO_Lba, ipKW, iMA)
c$$$      call MTStpd
c$$$     O    (WH,     CW,
c$$$     I     VMC,    WW,
c$$$     I     MH,     LH,
c$$$     I     VMW_W3, VMW_W1,  VMC_NBa, KWO_GYac, KWO_Lca, ipKW, iMA)
      call MTStpd
     O    (WH,     CW,
     I     VMI,    WW,
     I     MH,     LH,
     I     VMW_W2, VMW_W1,  VMI_Ba, KWO_GXab, KWO_Lba, ipKW, iMA)
      call MTStpd
     O    (WH,     CW,
     I     VMI,    WW,
     I     MH,     LH,
     I     VMW_W3, VMW_W1,  VMI_Ba, KWO_GYac, KWO_Lca, ipKW, iMA)
CCC_   + db/dt
      do jh = 1, MH
         WH (jh, VMW_W1) = (VMC (jh, VMC_NBa) - VMI (jh, VMI_Ba)) / DT
      enddo
CCC_   + db/dt + Mb
      do jh = 1, MH
         VMTI (jh, KZ0, VMTI_WHa) = WH (jh, VMW_W1) + VMHB (jh, VMHB_MB)
      enddo
CCC_   + W1 ub grad b
      do jh = 1, MH
         WH (jh, VMW_W1) =
     $        VMTI (jh, KZ0, VMTI_UHa) * WH (jh, VMW_W2)
     $       +VMTI (jh, KZ0, VMTI_VHa) * WH (jh, VMW_W3)
      enddo
      do jh = 1, MH
         VMTI (jh, KZ0, VMTI_WHa)
     $        = VMTI (jh, KZ0, VMTI_WHa) + WH (jh, VMW_W1)
      enddo
CCC_   + integral
c$$$      call MTStpd
c$$$     O    (WH,     CW,
c$$$     I     VMC,    WW,
c$$$     I     MH,     LH,
c$$$     I     VMW_W4, VMW_W1,  VMC_NHa, KWO_GXab, KWO_Lba, ipKW, iMA)
c$$$      call MTStpd
c$$$     O    (WH,     CW,
c$$$     I     VMC,    WW,
c$$$     I     MH,     LH,
c$$$     I     VMW_W5, VMW_W1,  VMC_NHa, KWO_GYac, KWO_Lca, ipKW, iMA)
      call MTStpd
     O    (WH,     CW,
     I     VMI,    WW,
     I     MH,     LH,
     I     VMW_W4, VMW_W1,  VMI_Ha, KWO_GXab, KWO_Lba, ipKW, iMA)
      call MTStpd
     O    (WH,     CW,
     I     VMI,    WW,
     I     MH,     LH,
     I     VMW_W5, VMW_W1,  VMI_Ha, KWO_GYac, KWO_Lca, ipKW, iMA)
c
      call MTSwin
     O    (VMTI,
     I     VMI,    WTW,    WH,     WZV,
     I     MH,     LH,     NZ,     LZ,   KZ0,
     I     DXUI,   DYVI,   UINTa,  VINTa,
     I     VMW_W2, VMW_W3, VMW_W4, VMW_W5)
c
      call MMTswa
     O    (iErr,
     M     VMTI,
     I     MH,    LH,    NZ,  LZ,  KZ0)
c$$$         FOWvel(ij,1) =
c$$$     $        (GAbase(ij) - FAbase(ij)) / DHtime
c$$$     $        + FAmbBs(ij)
c$$$     $        +(THbx(ij) * FOUvel(ij,1) + THby(ij) * FOVvel(ij,1))
c$$$      do 7000 j=1,Jsz
c$$$         do 7010 i=1,Isz-1
c$$$            TPUint(i,j,1)=0.0d0
c$$$            do 7020 k=2,Ksz
c$$$               TPUint(i,j,k) =
c$$$     $              TPUint(i,j,k-1)
c$$$     $                + 0.5d0 * CNdelz(k-1) *
c$$$     $                   ( FPUvel(i,j,k) + FPUvel(i,j,k-1) )
c$$$ 7020       continue
c$$$ 7010    continue
c$$$ 7000 continue
c$$$            FOWvel(ij,k)=
c$$$     $           FOWvel(ij,1)
c$$$     $           - FAthik(ij) *
c$$$     $           ( (TPUint(ijr,k) - TPUint(ijl,k)) / CAdx(ij)
c$$$     $            +(TQVint(iju,k) - TQVint(ijd,k)) / CAdy(ij))
c$$$     $           +(THbx(ij) * (FOUvel(ij,k) - FOUvel(ij,1))
c$$$     $            +THby(ij) * (FOVvel(ij,k) - FOVvel(ij,1)))
c$$$     $           +((THx (ij) * (FOUvel(ij,k) * CKzeta(k)
c$$$     $             - FOUvel(ij,1) * CKzeta(1) - TOUint(ij,k)))
c$$$     $            +(THy (ij) * (FOVvel(ij,k) * CKzeta(k)
c$$$     $             - FOVvel(ij,1) * CKzeta(1) - TOVint(ij,k))))
CCC_   + final
      call DAtrcU (IFP, iErr, 'R', 'MMWSST')
      RETURN
      END
CCC_ & MTStpd  ## variation S topography derivative
      subroutine MTStpd
     O    (WH,    CW,
     I     VI,    WW,
     I     MH,    LH,
     I     KL,    KW,    KR,   KOPd, KOPl, ipKW, iMA)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)  MH,   LH
      _INTENT(IN, integer)  KL,   KW,  KR
      _INTENT(IN, integer)  KOPd, KOPl
c
      _INTENT(OUT,_REALSTD) WH  (LH, *)
      _INTENT(OUT,_REALSTD) CW  (LH, *)
      _INTENT(IN, _REALSTD) VI  (LH, *)
      _INTENT(IN, _REALSTD) WW  (LH, *)
      _INTENT(IN, integer)  ipKW (*), iMA (*)
      integer   jh
CCC_  - Body
CCC_   . KW: derivative KOPd from VI(KR)
      call AKBwaz
     O    (WH  (1, KW),  CW,
     I     VI  (1, KR),  WW,
     I     MH,  LH, ipKW, iMA, KOPd, KWM_M)
CCC_   . KL: interpolation KOPl from WH(KW)
      call AKBwax
     O    (WH,   CW,
     I     WW,
     I     MH,   LH,  KL, KW,
     I     ipKW, iMA, KOPl, KWM_M)
c
c$$$      do jh = 1, MH
c$$$         write (*, *) 'TPD', jh,
c$$$     $        WH  (jh, KL),  WH  (jh, KW),
c$$$     $        VI  (jh, KR),  CW  (jh, 1)
c$$$      enddo
      RETURN
      END
CCC_ & MTSvin  ## variation S h velocity integral
      subroutine MTSvin
     O    (WTW,
     I     VMTI,  WZV,
     I     MH,    LH,    NZ,   LZ,   KZ0,
     I     KL,    KR)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)  MH,  LH
      _INTENT(IN, integer)  NZ,  LZ, KZ0
      _INTENT(IN, integer)  KL,  KR
c
      _INTENT(OUT,_REALSTD) WTW  (LH, LZ, *)
      _INTENT(IN, _REALSTD) VMTI (LH, LZ, *)
      _INTENT(IN, _REALSTD) WZV  (LZ, *)
      integer   jh, jz, jzz
      _REALSTD  VB
CCC_  - Body
      do jzz = 1, 1
         jz = KZ0 + jzz - 1
         do jh = 1, MH
            WTW (jh, jz, KL) = 0.0d0
         enddo
      enddo
      do jzz = 2, 2
         jz = KZ0 + jzz - 1
         do jh = 1, MH
            VB = VMTI (jh, KZ0, KR)
            WTW (jh, jz, KL) = WTW (jh, jz - 1, KL) +
     $           0.5d0 * WZV (jz-1, VMVZ_dZb) *
     $           ((VMTI (jh, jz,     KR) + VB)
     $            +VMTI (jh, jz - 1, KR))
         enddo
      enddo
      do jzz = 3, NZ
         jz = KZ0 + jzz - 1
         do jh = 1, MH
            VB = VMTI (jh, KZ0, KR)
            WTW (jh, jz, KL) = WTW (jh, jz - 1, KL) +
     $           0.5d0 * WZV (jz-1, VMVZ_dZb) *
     $           ((VMTI (jh, jz,     KR) + VB)
     $           +(VMTI (jh, jz - 1, KR) + VB))
         enddo
      enddo
      RETURN
      END
CCC_ & MMWspr  ## S/preparation
      subroutine MMWspr
     O    (iErr,
     O     VMHW,  VMTI,  VMTW,  CW,
     I     WW,
     I     MH,    LH,    NZ,    LZ,   KZ0,
     I     ipCG,  LCG,   ipKW,  iMA)
CCC_  - Declaration
      implicit none
c
      _INTENT(OUT,  integer)  iErr
c
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
      _INTENT(IN,   integer)  LCG
c
      _INTENT(INOUT,_REALSTD) VMHW (LH, *)
      _INTENT(INOUT,_REALSTD) VMTI (LH, LZ, *)
      _INTENT(INOUT,_REALSTD) VMTW (LH, LZ, *)
      _INTENT(OUT,  _REALSTD) CW   (LH, LZ, *)
c
      _INTENT(IN,   _REALSTD) WW   (*)
      _INTENT(IN,   integer)  ipKW (*), iMA (*)
      _INTENT(IN,   integer)  ipCG (LCG, *)
CCC_  - Body
      iErr = 0
CCC_   . u
CCC_    * clone u
      call AKCguw
     O    (CW,
     I     VMTI,  MH, LH, NZ, LZ, KZ0, VMTI_UHb,
     I     iMA,  ipCG (1, CGV_Ub))
CCC_    * x div uh  (div ui;   div ub)
c$$$      call AKGway
c$$$     O    (VMTW (1,1,VMTW_xDIVuh),
c$$$     I     CW,  VMTI (1,1,VMTI_UHb), WW,
c$$$     I     MH,  LH, NZ, LZ, KZ0, ipKW, CGV_Ub_DXba, ipCG (1, CGV_Ub))
CCC_    * ua
      call AKGwaw
     M    (VMTI,
     I     CW,   WW,
     I     MH,   LH,  NZ,  LZ, KZ0, VMTI_UHa, VMTI_UHb,
     I     ipKW, CGV_Ub_Lba, ipCG (1, CGV_Ub))
CCC_    * uadv/switch
      call MMTsva
     O    (iErr,
     M     VMTI,  VMTI_Uadv,  VMTI_UHb,
     M     VMHW,  VMHW_ADVXe, VMHW_ADVXw,
     W     VMTW,  VMTW_W1,    CW,
     I     MH,    LH,    NZ,  LZ,    KZ0,
     I     ipKW,  CGV_Ub_FCba, ipCG (1, CGV_Ub))
CCC_   . v
CCC_    * clone v
      call AKCguw
     O    (CW,
     I     VMTI,  MH, LH, NZ, LZ, KZ0, VMTI_VHc,
     I     iMA,  ipCG (1, CGV_Vc))
CCC_    * y div uh  (div vi;   div vb)
c$$$      call AKGway
c$$$     O    (VMTW (1,1,VMTW_yDIVuh),
c$$$     I     CW,  VMTI (1,1,VMTI_VHc), WW,
c$$$     I     MH,  LH, NZ, LZ, KZ0, ipKW, CGV_Vc_DYca, ipCG (1, CGV_Vc))
CCC_    * va
      call AKGwaw
     M    (VMTI,
     I     CW,   WW,
     I     MH,   LH,  NZ,  LZ, KZ0, VMTI_VHa, VMTI_VHc,
     I     ipKW, CGV_Vc_Lca, ipCG (1, CGV_Vc))
CCC_    * vadv/switch
      call MMTsva
     O    (iErr,
     M     VMTI,  VMTI_Vadv,  VMTI_VHc,
     M     VMHW,  VMHW_ADVYn, VMHW_ADVYs,
     W     VMTW,  VMTW_W1,    CW,
     I     MH,    LH,    NZ,  LZ,    KZ0,
     I     ipKW,  CGV_Vc_FCca, ipCG (1, CGV_Vc))
CCC_   . div uh
c$$$      call UV0nac
c$$$     $    (VMTW,
c$$$     $     MH, LH, NZ, LZ, KZ0, VMTW_DIVuh, VMTW_xDIVuh, VMTW_yDIVuh)
CCC_   . div Zuh (div Z ui; div b ub)
c$$$      call AKBwaw
c$$$     O    (VMTW, CW,
c$$$     I     WW,
c$$$     I     MH,   LH,  NZ, LZ,   KZ0, VMTW_xDIVzuh, VMTW_ZUHb,
c$$$     I     ipKW, iMA, KWO_DXba, KWM_M)
c$$$      call AKBwaw
c$$$     O    (VMTW, CW,
c$$$     I     WW,
c$$$     I     MH,   LH,  NZ, LZ,   KZ0, VMTW_yDIVzuh, VMTW_ZVHc,
c$$$     I     ipKW, iMA, KWO_DYca, KWM_M)
c$$$      call UV0nac
c$$$     $    (VMTW,
c$$$     $     MH, LH, NZ, LZ, KZ0, VMTW_DIVzuh, VMTW_xDIVzuh, VMTW_yDIVzuh)
CCC_   . div H uii
c$$$      call AKBwaw
c$$$     O    (VMTW, CW,
c$$$     I     WW,
c$$$     I     MH,   LH,  NZ, LZ,   KZ0, VMTW_xDIVuii, VMTW_HUHIb,
c$$$     I     ipKW, iMA, KWO_DXba, KWM_M)
c$$$      call AKBwaw
c$$$     O    (VMTW, CW,
c$$$     I     WW,
c$$$     I     MH,   LH,  NZ, LZ,   KZ0, VMTW_yDIVuii, VMTW_HVHIc,
c$$$     I     ipKW, iMA, KWO_DYca, KWM_M)
c$$$      call UV0nac
c$$$     $    (VMTW,
c$$$     $     MH, LH, NZ, LZ, KZ0, VMTW_DIVuii, VMTW_xDIVuii, VMTW_yDIVuii)
      RETURN
      END
CCC_ & MTSwin  ## variation S w velocity integral
      subroutine MTSwin
     O    (VMTI,
     I     VMI,   WTW,   WH,   WZV,
     I     MH,    LH,    NZ,   LZ,   KZ0,
     I     KUX,   KVY,   KUI,  KVI,
     I     KBX,   KBY,   KHX,  KHY)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)  MH,  LH
      _INTENT(IN, integer)  NZ,  LZ, KZ0
c
      _INTENT(OUT,_REALSTD) VMTI (LH, LZ, *)
      _INTENT(IN, _REALSTD) VMI  (LH, *)
      _INTENT(IN, _REALSTD) WTW  (LH, LZ, *)
      _INTENT(IN, _REALSTD) WH   (LH, *)
      _INTENT(IN, _REALSTD) WZV  (LZ, *)
c
      _INTENT(IN, integer)  KUX, KVY, KUI, KVI
      _INTENT(IN, integer)  KBX, KBY, KHX, KHY
c
      integer   jh, jz, jzz
c
      do jzz = 2, NZ
         jz = KZ0 + jzz - 1
         do jh = 1, MH
            VMTI (jh, jz, VMTI_WHa) =
     $           - VMI (jh, VMI_Ha) *
     $            (WTW (jh, jz, KUX) + WTW (jh, jz, KVY))
     $           +(WH (jh, KBX) * VMTI (jh, jz, VMTI_UHa)
     $            +WH (jh, KBY) * VMTI (jh, jz, VMTI_VHa))
     $           +(WH (jh, KHX) *
     $             ((VMTI (jh,jz,VMTI_UHa)+VMTI (jh,KZ0,VMTI_UHa))
     $               *WZV (jz, VMVZ_Za) - WTW (jh, jz, KUI)))
     $           +(WH (jh, KHY) *
     $             ((VMTI (jh,jz,VMTI_VHa)+VMTI (jh,KZ0,VMTI_VHa))
     $               *WZV (jz, VMVZ_Za) - WTW (jh, jz, KVI)))
         enddo
      enddo
      RETURN
      END
CCC_* [MMT]  ## velocity for advection
CCC_ & MMTsva  ## uv variation/S (Sally/NH2 inheritance)
      subroutine MMTsva
     O    (iErr,
     M     VT,    KTA,   KTI,
     M     VH,    KHU,   KHL,
     W     VW,    KW,    CW,
     I     MH,    LH,    NZ,  LZ,  KZ0,
     I     ipKW,  jOpr,  ipCG)
CCC_  - Declaration
      implicit none
c
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  MH,   LH
      _INTENT(IN,   integer)  NZ,   LZ, KZ0
c
      _INTENT(INOUT,_REALSTD) VT(LH, LZ, *)
      _INTENT(IN,   integer)  KTI, KTA
c
      _INTENT(INOUT,_REALSTD) VH(LH, *)
      _INTENT(IN,   integer)  KHU, KHL
c
      _INTENT(OUT,  _REALSTD) VW(LH, LZ, *)
      _INTENT(IN,   integer)  KW
c
      _INTENT(OUT,  _REALSTD) CW(LH, LZ, *)
c
      _INTENT(IN,   integer)  ipKW (*)
      _INTENT(IN,   integer)  jOpr, ipCG (*)
c
      integer   jh
      _REALSTD  tu,  tl
      _REALSTD  fu,  fl
      integer   kzs
      integer   jz,  jzz
CCC_  - Body
      iErr = 0
c
      kzs = KZ0 + NZ - 1
CCC_   . clone
      call AKGmey
     O    (VW(1, 1, KW),
     I     CW,   VT(1, 1, KTI),
     I     MH,   LH,   NZ, LZ, KZ0,
     I     ipKW, jOpr, ipCG)
CCC_   . compute switch
CC       todo: OPT_THERMO_ADV_STAGGERED
      do jh = 1, MH
         tu = VT(jh, kzs, KTI) + VT(jh, KZ0, KTI)
         tl = VW(jh, kzs, KW)  + VW(jh, KZ0, KW)
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
         VH(jh, KHU) = fu
         VH(jh, KHL) = fl
      enddo
CCC_   . compute velocity used for advection
      do    jzz = 2, NZ
         jz = KZ0 + jzz - 1
         do jh = 1,  MH
            tu = VT(jh, jz, KTI) + VT(jh, KZ0, KTI)
            tl = VW(jh, jz, KW)  + VW(jh, KZ0, KW)
            VT (jh, jz, KTA) =
     $           +VH(jh, KHU) * tu + VH(jh, KHL) * tl
         enddo
      enddo
      do    jzz = 1, 1
         jz = KZ0 + jzz - 1
         do jh = 1,  MH
            tu = VT(jh, jz, KTI)
            tl = VW(jh, jz, KW)
            VT(jh, jz, KTA) =
     $           +VH(jh, KHU) * tu + VH(jh, KHL) * tl
         enddo
      enddo
      RETURN
      END
CCC_ & MMTxwa  ## w adv variation/X
      subroutine MMTxwa
     O    (iErr,
     M     VMTI,  WH,
     I     VMTW,  VMI,   VMC,  VMHB, DT,   WZV,
     I     MH,    LH,    NZ,   LZ,   KZ0)
CCC_  - Description
CC      generate Wadv term used when SW_WADV_XKB set
CC      Wadv = -[Zeta dHdt - Mb + div(H int d Zeta u)]
CC      actual adv term will be Wadv/H dT/dzeta
CC      CAUTION on the sign (same sign as w velocity)
CCC_  * Declaration
      implicit none
c
      _INTENT(OUT,  integer)  iErr
c
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
c
      _INTENT(INOUT,_REALSTD) VMTI (LH, LZ, *)
      _INTENT(OUT,  _REALSTD) WH   (LH, *)
c
      _INTENT(IN,   _REALSTD) VMTW (LH, LZ, *)
      _INTENT(IN,   _REALSTD) VMI  (LH, *)
      _INTENT(IN,   _REALSTD) VMC  (LH, *)
      _INTENT(IN,   _REALSTD) VMHB (LH, *)
      _INTENT(IN,   _REALSTD) DT
      _INTENT(IN,   _REALSTD) WZV  (LZ, *)
c
      integer jh, jz, jz0, jzz
CCC_  - Body
      iErr = 0
CCC_   . dH/dt
      do jh = 1, MH
         WH (jh, VMW_W1) = (VMC (jh, VMC_NHa) - VMI (jh, VMI_Ha)) / DT
      enddo
CCC_   . compute internal
      do    jzz = 2, NZ
         jz = KZ0 + jzz - 1
         do jh = 1,  MH
            VMTI(jh, jz, VMTI_Wadv) =
     $           -(WH(jh,VMW_W1) * WZV (jz, VMVZ_Za)
     $             + (VMTW(jh, jz, VMTW_divHziue)
     $                +WZV (jz, VMVZ_Za)*VMTW(jh, KZ0, VMTW_divHziue)))
     $           + VMHB (jh, VMHB_MB)
         enddo
      enddo
CCC_   . compute bottom
      do    jzz = 1, 1
         jz = KZ0 + jzz - 1
         do jh = 1,  MH
            VMTI(jh, jz, VMTI_Wadv) = + VMHB (jh, VMHB_MB)
         enddo
      enddo
      RETURN
      END
CCC_ & MMTswa  ## w variation/S (Sally/NH2 inheritance)
      subroutine MMTswa
     O    (iErr,
     M     VMTI,
     I     MH,    LH,    NZ,  LZ,  KZ0)
CCC_  - Declaration
      implicit none
c
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  MH,   LH
      _INTENT(IN,   integer)  NZ,   LZ, KZ0
c
      _INTENT(INOUT,_REALSTD) VMTI (LH, LZ, *)
c
      integer   jh
      integer   jz,  jzz
CCC_  - Body
      iErr = 0
c
      do    jzz = 2, NZ
         jz = KZ0 + jzz - 1
         do jh = 1,  MH
            VMTI (jh, jz, VMTI_Wadv) =
     $           VMTI (jh, jz, VMTI_WHa) + VMTI (jh, KZ0, VMTI_WHa)
         enddo
      enddo
      do    jzz = 1, 1
         jz = KZ0 + jzz - 1
         do jh = 1,  MH
            VMTI (jh, jz, VMTI_Wadv) = VMTI (jh, jz, VMTI_WHa)
         enddo
      enddo
c
      RETURN
      END
CCC_ & MMTuzi  ## du/dzeta interpolation
      subroutine MMTuzi
     O    (iErr,
     O     VMTI, CW,
     I     VMTW,
     I     WW,
     I     MH,    LH,   NZ,    LZ,   KZ0,
     I     ipKW,  iMA)
CCC_  * Declaration
      implicit none
c
      _INTENT(OUT,  integer)  iErr
c
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
c
      _INTENT(INOUT,_REALSTD) VMTI (LH, LZ, *)
      _INTENT(IN,   _REALSTD) VMTW (LH, LZ, *)
      _INTENT(OUT,  _REALSTD) CW   (LH, LZ, *)
c
      _INTENT(IN,   _REALSTD) WW   (*)
      _INTENT(IN,   integer)  ipKW (*), iMA (*)
CCC_  * Body
      iErr = 0
      call AKBway
     O    (VMTI(1,1,VMTI_dudZ),  CW,
     I     VMTW(1,1,VMTW_dudZ),  WW,
     I     MH,   LH,  NZ, LZ,    KZ0,
     I     ipKW, iMA, KWO_Lba,   KWM_M)
      call AKBway
     O    (VMTI(1,1,VMTI_dvdZ),  CW,
     I     VMTW(1,1,VMTW_dvdZ),  WW,
     I     MH,   LH,  NZ, LZ,    KZ0,
     I     ipKW, iMA, KWO_Lca,   KWM_M)
      RETURN
      END
CCC_& MMWCOL  ## Movement/vertical velocity announcement
      subroutine MMWCOL (STRA, STRB, IOP)
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
CCC_ @ MMWTST  ## Movement/vertical velocity test program
#ifdef     TEST_MMWCOL
#include "ofnstd.h"
#include "odevid.h"  /* MPI table */
      program MMWTST
CCC_  - Test suites
CC::   SOURCES mmxoms.F
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
         call MMWtestMain (iErr, ipA, iMA)
         call ACCrep (FPL(ipA), 0)
      endif
      call DevFin (iErr)
      STOP
      END
CCC_ & MMWtestMain   ## main
      subroutine MMWtestMain (iErr, ipA, iMA)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(IN, integer) ipA (*)
      _INTENT(IN, integer) iMA (*)
CCC_  - Body
      iErr = 0
      RETURN
      END
#endif  /* TEST_MMWCOL */
CCC_* Obsolete
CCC_ + begin
#if 0 /* obsolete */
CCC_ & (obsolete) MMWdpr  ## A/preparation (DVB)
      subroutine MMWdpr_obsolete
     O    (iErr,
     O     VMTW,  CW,
     I     VMI,   VMC,   VMTI,
     I     WW,    WZV,
     I     MH,    LH,    NZ,    LZ,   KZ0,
     I     ipCG,  LCG,   ipKW,  iMA,  MSW)
CCC_  * Declaration
      implicit none
c
      _INTENT(OUT,  integer)  iErr
c
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
      _INTENT(IN,   integer)  LCG
c
      _INTENT(INOUT,_REALSTD) VMTW (LH, LZ, *)
      _INTENT(OUT,  _REALSTD) CW   (LH, LZ, *)
c
      _INTENT(IN,   _REALSTD) VMI  (LH, *)
      _INTENT(IN,   _REALSTD) VMC  (LH, *)
      _INTENT(IN,   _REALSTD) VMTI (LH, LZ, *)
c
      _INTENT(IN,   _REALSTD) WW   (*)
      _INTENT(IN,   _REALSTD) WZV  (LZ, *)
      _INTENT(IN,   integer)  ipKW (*), iMA (*)
      _INTENT(IN,   integer)  ipCG (LCG, *)
c
      _INTENT(IN,   integer)  MSW
c
      integer jh, jz, jz0, jzb
CCC_  * Body
      iErr = 0
c
      jzb = KZ0
CCC_   + P2 {ui(zeta) grad b; ub grad b}
CCC_    * ub b:new
      jz = jzb
      do jh = 1, MH
         VMTW (jh, jz, VMTW_W1)
     $        = VMTI (jh, jz, VMTI_UHb) * VMC (jh, VMC_NBb)
         VMTW (jh, jz, VMTW_W2)
     $        = VMTI (jh, jz, VMTI_VHc) * VMC (jh, VMC_NBc)
      enddo
CCC_    * ui b:old
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_W1)
     $           = VMTI (jh, jz, VMTI_UHb) * VMI (jh, VMI_Bb)
            VMTW (jh, jz, VMTW_W2)
     $           = VMTI (jh, jz, VMTI_VHc) * VMI (jh, VMI_Bc)
         enddo
      enddo
CCC_    * div {ui b; ub b}
      call AKBwaw
     O    (VMTW, CW,
     I     WW,
     I     MH,   LH,  NZ, LZ,   KZ0, VMTW_W3x, VMTW_W1,
     I     ipKW, iMA, KWO_DXba, KWM_M)
      call AKBwaw
     O    (VMTW, CW,
     I     WW,
     I     MH,   LH,  NZ, LZ,   KZ0, VMTW_W3y, VMTW_W2,
     I     ipKW, iMA, KWO_DYca, KWM_M)
CCC_    * final/b: div (ub b) - b div ub
      jz = jzb
      do jh = 1, MH
         VMTW (jh, jz, VMTW_uigradb)
     $        = (VMTW (jh, jz, VMTW_W3x) + VMTW (jh, jz, VMTW_W3y))
     $        -  VMTW (jh, jz, VMTW_divuh) * VMC (jh, VMC_NBa)
      enddo
CCC_    * final/i: div (ui b) - b div ui
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_uigradb)
     $           = (VMTW (jh, jz, VMTW_W3x) + VMTW (jh, jz, VMTW_W3y))
     $           -  VMTW (jh, jz, VMTW_divuh) * VMI (jh, VMI_Ba)
         enddo
      enddo
CCC_   + P3 {zeta ue grad H; -}
CCC_    * Caution
CC        zeta div (ub H) is excluded (due to cancellation with P1)
CCC_    * ub H:new
      jz = jzb
      do jh = 1, MH
         VMTW (jh, jz, VMTW_W1)
     $        = VMTI (jh, jz, VMTI_UHb) * VMC (jh, VMC_NHb)
         VMTW (jh, jz, VMTW_W2)
     $        = VMTI (jh, jz, VMTI_VHc) * VMC (jh, VMC_NHc)
      enddo
CCC_    * ui H:old
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_W1)
     $           = VMTI (jh, jz, VMTI_UHb) * VMI (jh, VMI_Hb)
            VMTW (jh, jz, VMTW_W2)
     $           = VMTI (jh, jz, VMTI_VHc) * VMI (jh, VMI_Hc)
         enddo
      enddo
CCC_    * div {ui H; ub H}
      call AKBwaw
     O    (VMTW, CW,
     I     WW,
     I     MH,   LH,  NZ, LZ,   KZ0, VMTW_W3x, VMTW_W1,
     I     ipKW, iMA, KWO_DXba, KWM_M)
      call AKBwaw
     O    (VMTW, CW,
     I     WW,
     I     MH,   LH,  NZ, LZ,   KZ0, VMTW_W3y, VMTW_W2,
     I     ipKW, iMA, KWO_DYca, KWM_M)
CCC_    * div (ub H) - H:new div ub
      jz = jzb
      do jh = 1, MH
         VMTW (jh, jz, VMTW_zuegradH)
     $        = (0.0d0 -VMTW (jh, jz, VMTW_divuh) * VMC (jh, VMC_NHa))
CCC      div ub H = (VMTW (jh, jz, VMTW_W3x) + VMTW (jh, jz, VMTW_W3y))
      enddo
CCC_    * final
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_zuegradH)
     $           = (((VMTW (jh, jz, VMTW_W3x) + VMTW (jh, jz, VMTW_W3y))
     $               -VMTW (jh, jz, VMTW_divuh) * VMI (jh, VMI_Ha))
     $             +VMTW (jh, jzb, VMTW_zuegradH))
     $           * WZV (jz, VMVZ_Za)
         enddo
      enddo
CCC_   + P1 {div H int ue; div H:new ub}
CCC_    * div H:new ub (to save)
      jz = jzb
      do jh = 1, MH
         VMTW (jh, jz, VMTW_divHziue)
     $        = (VMTW (jh, jz, VMTW_W3x) + VMTW (jh, jz, VMTW_W3y))
      enddo
CCC_    * H:old int ui
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_W1)
     $           = VMTW (jh, jz, VMTW_ziUIb) * VMI (jh, VMI_Hb)
            VMTW (jh, jz, VMTW_W2)
     $           = VMTW (jh, jz, VMTW_ziVIc) * VMI (jh, VMI_Hc)
         enddo
      enddo
CCC_    * div
      call AKBwaw
     O    (VMTW, CW,
     I     WW,
     I     MH,   LH,  NZ, LZ,   KZ0, VMTW_W3x, VMTW_W1,
     I     ipKW, iMA, KWO_DXba, KWM_M)
      call AKBwaw
     O    (VMTW, CW,
     I     WW,
     I     MH,   LH,  NZ, LZ,   KZ0, VMTW_W3y, VMTW_W2,
     I     ipKW, iMA, KWO_DYca, KWM_M)
CCC_    * final
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_divHziue)
     $           = VMTW (jh, jz, VMTW_W3x) + VMTW (jh, jz, VMTW_W3y)
         enddo
      enddo
      RETURN
      END
CCC_ & obsolete MMWepr  ## A/preparation (ZEV)
      subroutine MMWepr
     O    (iErr,
     O     VMTW,  CW,
     I     VMI,   VMC,   VMTI,  QM,
     I     WW,    WZV,
     I     MH,    LH,    NZ,    LZ,   KZ0,
     I     ipCG,  LCG,   ipKW,  iMA,  MSW)
CCC_  * Declaration
      implicit none
c
      _INTENT(OUT,  integer)  iErr
c
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
      _INTENT(IN,   integer)  LCG
c
      _INTENT(INOUT,_REALSTD) VMTW (LH, LZ, *)
      _INTENT(OUT,  _REALSTD) CW   (LH, LZ, *)
c
      _INTENT(IN,   _REALSTD) VMI  (LH, *)
      _INTENT(IN,   _REALSTD) VMC  (LH, *)
      _INTENT(IN,   _REALSTD) VMTI (LH, LZ, *)
      _INTENT(IN,   _REALSTD) QM   (LH, *)
c
      _INTENT(IN,   _REALSTD) WW   (*)
      _INTENT(IN,   _REALSTD) WZV  (LZ, *)
      _INTENT(IN,   integer)  ipKW (*), iMA (*)
      _INTENT(IN,   integer)  ipCG (LCG, *)
c
      _INTENT(IN,   integer)  MSW
c
      integer jh, jz, jz0, jzb
CCC_  * Body
      iErr = 0
c
      jzb = KZ0
CCC_   + P2 {ui(zeta) grad b; ub grad b}
CCC_    * ui b:new; ub b:new
      do jz0 = 0, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_W1)
     $           = VMTI (jh, jz, VMTI_UHb) * VMC (jh, VMC_NBb)
            VMTW (jh, jz, VMTW_W2)
     $           = VMTI (jh, jz, VMTI_VHc) * VMC (jh, VMC_NBc)
         enddo
      enddo
CCC_    * div {ui b; ub b}
      call AKBwaw
     O    (VMTW, CW,
     I     WW,
     I     MH,   LH,  NZ, LZ,   KZ0, VMTW_W3x, VMTW_W1,
     I     ipKW, iMA, KWO_DXba, KWM_M)
      call AKBwaw
     O    (VMTW, CW,
     I     WW,
     I     MH,   LH,  NZ, LZ,   KZ0, VMTW_W3y, VMTW_W2,
     I     ipKW, iMA, KWO_DYca, KWM_M)
CCC_    * final: div (ui b) - b div ui
      do jz0 = 0, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_uigradb)
     $           = (VMTW (jh, jz, VMTW_W3x) + VMTW (jh, jz, VMTW_W3y))
     $           -  VMTW (jh, jz, VMTW_divuh) * VMC (jh, VMC_NBa)
         enddo
      enddo
CCC_   + P3 {zeta ue grad H; -}
CCC_    * Caution
CC        zeta div (ub H) is excluded (due to cancellation with P1)
CCC_    * ui H:new; ub H:new
      do jz0 = 0, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_W1)
     $           = VMTI (jh, jz, VMTI_UHb) * VMC (jh, VMC_NHb)
            VMTW (jh, jz, VMTW_W2)
     $           = VMTI (jh, jz, VMTI_VHc) * VMC (jh, VMC_NHc)
         enddo
      enddo
CCC_    * div {ui H; ub H}
      call AKBwaw
     O    (VMTW, CW,
     I     WW,
     I     MH,   LH,  NZ, LZ,   KZ0, VMTW_W3x, VMTW_W1,
     I     ipKW, iMA, KWO_DXba, KWM_M)
      call AKBwaw
     O    (VMTW, CW,
     I     WW,
     I     MH,   LH,  NZ, LZ,   KZ0, VMTW_W3y, VMTW_W2,
     I     ipKW, iMA, KWO_DYca, KWM_M)
CCC_    * div (ub H) - H:new div ub
      jz = jzb
      do jh = 1, MH
         VMTW (jh, jz, VMTW_zuegradH)
     $        = (0.0d0 -VMTW (jh, jz, VMTW_divuh) * VMC (jh, VMC_NHa))
CCC      div ub H = (VMTW (jh, jz, VMTW_W3x) + VMTW (jh, jz, VMTW_W3y))
      enddo
CCC_    * final
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_zuegradH)
     $           = (((VMTW (jh, jz, VMTW_W3x) + VMTW (jh, jz, VMTW_W3y))
     $               -VMTW (jh, jz, VMTW_divuh) * VMC (jh, VMC_NHa))
     $             +VMTW (jh, jzb, VMTW_zuegradH))
     $           * WZV (jz, VMVZ_Za)
         enddo
      enddo
CCC_   + P1 {div H int ue; H:new div ub}
CCC_    * H:new ub (to save)
      jz = jzb
      do jh = 1, MH
         VMTW (jh, jz, VMTW_divHziue)
     $        = (VMTW (jh, jz, VMTW_W3x) + VMTW (jh, jz, VMTW_W3y))
      enddo
CCC_    * H:new int ui
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_W1)
     $           = VMTW (jh, jz, VMTW_ziUIb) * VMC (jh, VMC_NHb)
            VMTW (jh, jz, VMTW_W2)
     $           = VMTW (jh, jz, VMTW_ziVIc) * VMC (jh, VMC_NHc)
         enddo
      enddo
CCC_    * div
      call AKBwaw
     O    (VMTW, CW,
     I     WW,
     I     MH,   LH,  NZ, LZ,   KZ0, VMTW_W3x, VMTW_W1,
     I     ipKW, iMA, KWO_DXba, KWM_M)
      call AKBwaw
     O    (VMTW, CW,
     I     WW,
     I     MH,   LH,  NZ, LZ,   KZ0, VMTW_W3y, VMTW_W2,
     I     ipKW, iMA, KWO_DYca, KWM_M)
CCC_    * final
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_divHziue)
     $           = VMTW (jh, jz, VMTW_W3x) + VMTW (jh, jz, VMTW_W3y)
         enddo
      enddo
      RETURN
      END
CCC_ & obsolete MMWupr  ## A/preparation (UP1)
      subroutine MMWupr
     O    (iErr,
     O     VMTW,  WH,    CW,
     I     VMI,   VMC,   VMTI,  QM,   F0,
     I     WW,    WZV,
     I     MH,    LH,    NZ,    LZ,   KZ0,
     I     ipCG,  LCG,   ipKW,  iMA,  MSW)
CCC_  * Declaration
      implicit none
c
      _INTENT(OUT,  integer)  iErr
c
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
      _INTENT(IN,   integer)  LCG
c
      _INTENT(INOUT,_REALSTD) VMTW (LH, LZ, *)
      _INTENT(OUT,  _REALSTD) CW   (LH, LZ, *)
      _INTENT(OUT,  _REALSTD) WH   (LH, *)
c
      _INTENT(IN,   _REALSTD) VMI  (LH, *)
      _INTENT(IN,   _REALSTD) VMC  (LH, *)
      _INTENT(IN,   _REALSTD) VMTI (LH, LZ, *)
      _INTENT(IN,   _REALSTD) QM   (LH, *)
      _INTENT(IN,   _REALSTD) F0
c
      _INTENT(IN,   _REALSTD) WW   (*)
      _INTENT(IN,   _REALSTD) WZV  (LZ, *)
      _INTENT(IN,   integer)  ipKW (*), iMA (*)
      _INTENT(IN,   integer)  ipCG (LCG, *)
c
      _INTENT(IN,   integer)  MSW
c
      integer jh, jz, jz0, jzb, jzs
c
      integer jwFC
CCC_  * Body
      iErr = 0
CCC_   + div uh (upwind) [or zero]
      call MMWouy
     O    (VMTW,  VMTW_divuh,
     W     CW,
     I     VMTI,  VMTI_UHa, VMTI_VHa,
     I     QM,    WW,
     I     KWO_DXab, KWO_DYac,
     I     KWO_Lba,  KWO_Lca,
     I     MH,    LH,    NZ,    LZ,   KZ0,
     I     ipCG,  LCG,   ipKW,  iMA)
CCC_   + P2
CCC_    * ui:a b:a[new]; ub:a b:a[new]
      do jz0 = 0, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_W1)
     $           = VMTI (jh, jz, VMTI_UHa) * VMC (jh, VMC_NBa)
            VMTW (jh, jz, VMTW_W2)
     $           = VMTI (jh, jz, VMTI_VHa) * VMC (jh, VMC_NBa)
         enddo
      enddo
CCC_    * div {ui b; ub b} at bc  [or zero]
      call MMWouw
     O    (VMTW,  VMTW_uigradb, VMTW_W1, VMTW_W2,
     W     CW,
     I     QM,    WW,
     I     KWO_DXab, KWO_DYac,
     I     KWO_Lba,  KWO_Lca,
     I     MH,    LH,    NZ,    LZ,   KZ0,
     I     ipCG,  LCG,   ipKW,  iMA)
CCC_    * grad b:a b   [or zero]
      do jz0 = 0, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_uigradb) =
     $           VMTW (jh, jz, VMTW_uigradb)
     $           -  VMTW (jh, jz, VMTW_divuh) * VMC (jh, VMC_NBa)
         enddo
      enddo
CCC_   + P3
CCC_    * ui:a H:a[new]; ub:a H:a[new]
      do jz0 = 0, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_W1)
     $           = VMTI (jh, jz, VMTI_UHa) * VMC (jh, VMC_NHa)
            VMTW (jh, jz, VMTW_W2)
     $           = VMTI (jh, jz, VMTI_VHa) * VMC (jh, VMC_NHa)
         enddo
      enddo
CCC_    * div {ui H; ub H} at bc  [or zero]
      call MMWouw
     O    (VMTW,  VMTW_zuegradH, VMTW_W1, VMTW_W2,
     W     CW,
     I     QM,    WW,
     I     KWO_DXab, KWO_DYac,
     I     KWO_Lba,  KWO_Lca,
     I     MH,    LH,    NZ,    LZ,   KZ0,
     I     ipCG,  LCG,   ipKW,  iMA)
CCC_    * grad b:a H   [or zero]
      jzb = KZ0
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_zuegradH) =
     $           VMTW (jh, jz, VMTW_zuegradH)
     $           - VMC (jh, VMC_NHa)
     $           * (VMTW (jh, jz, VMTW_divuh)
     $             + VMTW (jh, jzb, VMTW_divuh))
         enddo
      enddo
CCC_   + P1
CCC_    * center
      do jh = 1, MH
         WH (jh, VMW_W1) = 1.0d0
     $        - (QM (jh, VMQU_WXp) + QM (jh, VMQU_WXm))
         WH (jh, VMW_W2) = 1.0d0
     $        - (QM (jh, VMQU_WYp) + QM (jh, VMQU_WYm))
      enddo
CCC_    * clone
      call AKCguw
     O    (CW,
     I     VMTW,  MH, LH, NZ, LZ, KZ0, VMTW_ziUIb,
     I     iMA,  ipCG (1, CGV_Ub))
CCC_    * xdiv uh  (div int ui;   div ub)
      call AKGwaw
     M    (VMTW,
     I     CW,   WW,
     I     MH,   LH,  NZ,  LZ, KZ0, VMTW_W3x, VMTW_ziUIb,
     I     ipKW, CGV_Ub_DXba, ipCG (1, CGV_Ub))
CCC_    * ua
      call AKGwaw
     M    (VMTW,
     I     CW,   WW,
     I     MH,   LH,  NZ,  LZ, KZ0, VMTW_ziUIa, VMTW_ziUIb,
     I     ipKW, CGV_Ub_Lba, ipCG (1, CGV_Ub))
      call AKBomw
     M    (VMTW, CW,
     I     WW,
     I     MH,   LH,  NZ, LZ, KZ0, VMTW_ziUIa, VMTW_ziUIa,
     I     ipKW, iMA, KWO_ZXb)
CCC_    * clone
      call AKCguw
     O    (CW,
     I     VMTW,  MH, LH, NZ, LZ, KZ0, VMTW_ziVIc,
     I     iMA,  ipCG (1, CGV_Vc))
CCC_    * ydiv vh  (div int ui;   div ub)
      call AKGwaw
     M    (VMTW,
     I     CW,   WW,
     I     MH,   LH,  NZ,  LZ, KZ0, VMTW_W3y, VMTW_ziVIc,
     I     ipKW, CGV_Vc_DYca, ipCG (1, CGV_Vc))
CCC_    * va
      call AKGwaw
     M    (VMTW,
     I     CW,   WW,
     I     MH,   LH,  NZ,  LZ, KZ0, VMTW_ziVIa, VMTW_ziVIc,
     I     ipKW, CGV_Vc_Lca, ipCG (1, CGV_Vc))
      call AKBomw
     M    (VMTW,  CW,
     I     WW,
     I     MH,   LH,  NZ, LZ, KZ0, VMTW_ziVIa, VMTW_ziVIa,
     I     ipKW, iMA, KWO_ZYc)
CCC_    * final (center)
      do jz0 = 0, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_divziuh)
     $           = WH (jh, VMW_W1) * VMTW (jh, jz, VMTW_W3x)
     $           + WH (jh, VMW_W2) * VMTW (jh, jz, VMTW_W3y)
         enddo
      enddo
CCC_    * H Ui at a
      do jz0 = 0, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_W1)
     $           = VMTW (jh, jz, VMTW_ziUIa) * VMC (jh, VMC_NHa)
            VMTW (jh, jz, VMTW_W2)
     $           = VMTW (jh, jz, VMTW_ziVIa) * VMC (jh, VMC_NHa)
         enddo
      enddo
CCC_    * div {H Ui} at b
      call MMWouw
     O    (VMTW,  VMTW_divHziue, VMTW_W1, VMTW_W2,
     W     CW,
     I     QM,    WW,
     I     KWO_DXab, KWO_DYac,
     I     KWO_Lba,  KWO_Lca,
     I     MH,    LH,    NZ,    LZ,   KZ0,
     I     ipCG,  LCG,   ipKW,  iMA)
CCC_   + grad b
      call MTStpd
     O    (WH,     CW,
     I     VMC,    WW,
     I     MH,     LH,
     I     VMW_W3, VMW_W5,  VMC_NBa, KWO_GXab, KWO_Lba, ipKW, iMA)
      call MTStpd
     O    (WH,     CW,
     I     VMC,    WW,
     I     MH,     LH,
     I     VMW_W4, VMW_W5,  VMC_NBa, KWO_GYac, KWO_Lca, ipKW, iMA)
CCC_   + P2 MOD
      do jz0 = 0, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_uigradb) =
     $           VMTW (jh, jz, VMTW_uigradb)
     $           + (WH(jh,VMW_W1)*WH(jh,VMW_W3)*VMTI(jh,jz,VMTI_UHa)
     $             +WH(jh,VMW_W2)*WH(jh,VMW_W4)*VMTI(jh,jz,VMTI_VHa))
         enddo
      enddo
CCC_   + grad H
      call MTStpd
     O    (WH,     CW,
     I     VMC,    WW,
     I     MH,     LH,
     I     VMW_W3, VMW_W5,  VMC_NHa, KWO_GXab, KWO_Lba, ipKW, iMA)
      call MTStpd
     O    (WH,     CW,
     I     VMC,    WW,
     I     MH,     LH,
     I     VMW_W4, VMW_W5,  VMC_NHa, KWO_GYac, KWO_Lca, ipKW, iMA)
CCC_   + P3 MOD
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_zuegradH) =
     $           (VMTW (jh, jz, VMTW_zuegradH)
     $            + (WH(jh,VMW_W1)*WH(jh,VMW_W3)*VMTI(jh,jz,VMTI_UHa)
     $              +WH(jh,VMW_W2)*WH(jh,VMW_W4)*VMTI(jh,jz,VMTI_VHa)))
     $           * WZV (jz, VMVZ_Za)
         enddo
      enddo
CCC_   + P1 MOD
      jzb = KZ0
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_divHziue) =
     $           VMTW (jh, jz, VMTW_divHziue)
     $           +(((VMTW(jh,jz,VMTW_divziuh)
     $              +VMTW(jh,jzb,VMTW_divziuh)*WZV(jz,VMVZ_Za))
     $              *VMC(jh,VMC_NHa))
     $            +((WH(jh,VMW_W1)*WH(jh,VMW_W3)
     $               *VMTW(jh,jz,VMTW_ziUIa)
     $              +WH(jh,VMW_W2)*WH(jh,VMW_W4)
     $               *VMTW(jh,jz,VMTW_ziVIa))))
         enddo
      enddo
      RETURN
      END
CCC_ & obsolete MMWzpr  ## A/preparation (Z/UPD)
      subroutine MMWzpr
     O    (iErr,
     O     VMTW,  WH,    CW,
     I     VMI,   VMC,   VMTI,  QM,   F0,
     I     WW,    WZV,
     I     MH,    LH,    NZ,    LZ,   KZ0,
     I     ipCG,  LCG,   ipKW,  iMA,  MSW)
CCC_  * Declaration
      implicit none
c
      _INTENT(OUT,  integer)  iErr
c
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
      _INTENT(IN,   integer)  LCG
c
      _INTENT(INOUT,_REALSTD) VMTW (LH, LZ, *)
      _INTENT(OUT,  _REALSTD) CW   (LH, LZ, *)
      _INTENT(OUT,  _REALSTD) WH   (LH, *)
c
      _INTENT(IN,   _REALSTD) VMI  (LH, *)
      _INTENT(IN,   _REALSTD) VMC  (LH, *)
      _INTENT(IN,   _REALSTD) VMTI (LH, LZ, *)
      _INTENT(IN,   _REALSTD) QM   (LH, *)
      _INTENT(IN,   _REALSTD) F0
c
      _INTENT(IN,   _REALSTD) WW   (*)
      _INTENT(IN,   _REALSTD) WZV  (LZ, *)
      _INTENT(IN,   integer)  ipKW (*), iMA (*)
      _INTENT(IN,   integer)  ipCG (LCG, *)
c
      _INTENT(IN,   integer)  MSW
c
      integer jh, jz, jz0, jzb, jzs
c$$$c
c$$$      _REALSTD Tmin, Tmax
CCC_  * Body
      iErr = 0
#if 0
CCC_    * clone
      call AKCguw
     O    (CW,
     I     VMTW,  MH, LH, NZ, LZ, KZ0, VMTW_ziUIb,
     I     iMA,  ipCG (1, CGV_Ub))
CCC_    * xdiv uh  (div int ui;   div ub)
      call AKGwaw
     M    (VMTW,
     I     CW,   WW,
     I     MH,   LH,  NZ,  LZ, KZ0, VMTW_W3x, VMTW_ziUIb,
     I     ipKW, CGV_Ub_DXba, ipCG (1, CGV_Ub))
CCC_    * ua
      call AKGwaw
     M    (VMTW,
     I     CW,   WW,
     I     MH,   LH,  NZ,  LZ, KZ0, VMTW_ziUIa, VMTW_ziUIb,
     I     ipKW, CGV_Ub_Lba, ipCG (1, CGV_Ub))
      call AKBomw
     M    (VMTW, CW,
     I     WW,
     I     MH,   LH,  NZ, LZ, KZ0, VMTW_ziUIa, VMTW_ziUIa,
     I     ipKW, iMA, KWO_ZXb)
CCC_    * clone
      call AKCguw
     O    (CW,
     I     VMTW,  MH, LH, NZ, LZ, KZ0, VMTW_ziVIc,
     I     iMA,  ipCG (1, CGV_Vc))
CCC_    * ydiv vh  (div int ui;   div ub)
      call AKGwaw
     M    (VMTW,
     I     CW,   WW,
     I     MH,   LH,  NZ,  LZ, KZ0, VMTW_W3y, VMTW_ziVIc,
     I     ipKW, CGV_Vc_DYca, ipCG (1, CGV_Vc))
CCC_    * va
      call AKGwaw
     M    (VMTW,
     I     CW,   WW,
     I     MH,   LH,  NZ,  LZ, KZ0, VMTW_ziVIa, VMTW_ziVIc,
     I     ipKW, CGV_Vc_Lca, ipCG (1, CGV_Vc))
      call AKBomw
     M    (VMTW,  CW,
     I     WW,
     I     MH,   LH,  NZ, LZ, KZ0, VMTW_ziVIa, VMTW_ziVIa,
     I     ipKW, iMA, KWO_ZYc)
CCC_    * final (center)
      call UV0nac
     $     (VMTW, MH,LH,NZ,LZ,KZ0, VMTW_divziuh,VMTW_W3x,VMTW_W3y)
c$$$CCC_   . integral u:[bc]
c$$$      call AKBwaw
c$$$     O    (VMTW, CW,
c$$$     I     WW,
c$$$     I     MH,   LH,  NZ, LZ,  KZ0, VMTW_ziUIa, VMTW_ziUIb,
c$$$     I     ipKW, iMA, KWO_Lba, KWM_M)
c$$$      call AKBwaw
c$$$     O    (VMTW, CW,
c$$$     I     WW,
c$$$     I     MH,   LH,  NZ, LZ,  KZ0, VMTW_ziVIa, VMTW_ziVIc,
c$$$     I     ipKW, iMA, KWO_Lca, KWM_M)
CCC_   . P2
CCC_    * clone group
      call AKCgux
     O    (CW,
     I     VMC,  MH,   LH, VMC_NBa,
     I     iMA,  ipCG (1, CGB_XHaN))
CCC_    * [B1:b, B2:c] = <grad_xy a:bc> H:a (clone group)
      call AKGwaz
     M    (WH (1, VMIW_W1),
     I     CW,   VMC(1, VMC_NBa), WW,
     I     MH,   LH,  ipKW, 3, ipCG (1, CGB_XHaN))
      call AKGwaz
     M    (WH (1, VMIW_W2),
     I     CW,   VMC(1, VMC_NBa), WW,
     I     MH,   LH,  ipKW, 4, ipCG (1, CGB_XHaN))
CCC_    * P2: [vi;vb:a] grad b upwind
      call MMWguo
     O    (VMTW,  VMTW_uigradb,
     W     WH,    VMIW_W1,  VMIW_W2, VMIW_W3, VMIW_W4,
     W     CW,
     I     VMTI,  VMTI_UHa, VMTI_VHa,
     I     QM,    VMQG_WXp, VMQG_WXm, VMQG_WYp, VMQG_WYm, WW,
     I     MH,    LH,    NZ,    LZ,   KZ0,
     I     ipKW,  iMA)
CCC_   . P3
CCC_    * clone group
      call AKCgux
     O    (CW,
     I     VMC,  MH,   LH, VMC_NHa,
     I     iMA,  ipCG (1, CGB_XHaN))
CCC_    * [B1:b, B2:c] = <grad_xy a:bc> H:a (clone group)
      call AKGwaz
     M    (WH (1, VMIW_W1),
     I     CW,   VMC(1, VMC_NHa), WW,
     I     MH,   LH,  ipKW, 3, ipCG (1, CGB_XHaN))
      call AKGwaz
     M    (WH (1, VMIW_W2),
     I     CW,   VMC(1, VMC_NHa), WW,
     I     MH,   LH,  ipKW, 4, ipCG (1, CGB_XHaN))
CCC_    * P3: [vi;vb:a] grad b upwind
CCC_     + caution  W3 W4 are used at P1 computation
      call MMWguo
     O    (VMTW,  VMTW_zuegradH,
     W     WH,    VMIW_W1,  VMIW_W2, VMIW_W3, VMIW_W4,
     W     CW,
     I     VMTI,  VMTI_UHa, VMTI_VHa,
     I     QM,    VMQG_WXp, VMQG_WXm, VMQG_WYp, VMQG_WYm, WW,
     I     MH,    LH,    NZ,    LZ,   KZ0,
     I     ipKW,  iMA)
c$$$      Tmin = 0.0d0
c$$$      Tmax = 0.0d0
c$$$      do jh = 1, MH
c$$$         Tmin = MIN (Tmin, WH(jh, VMIW_W1))
c$$$         Tmax = MAX (Tmax, WH(jh, VMIW_W1))
c$$$      enddo
c$$$      write (*, *) 'dHdx', Tmin, Tmax
CCC_    * P3: P3:i Zeta
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_zuegradH) =
     $           VMTW (jh, jz, VMTW_zuegradH) * WZV (jz, VMVZ_Za)
         enddo
      enddo
CCC_   . P1 [uint:gradH; ub:gradH]
      do jz0 = 0, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_divHziue)
     $           =  (VMTW(jh, jz, VMTW_ziUIa) * WH(jh,VMIW_W3)
     $              +VMTW(jh, jz, VMTW_ziVIa) * WH(jh,VMIW_W4))
         enddo
      enddo
CCC_    * plus H div int ve
      jzb = KZ0
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, MH
            VMTW (jh, jz, VMTW_divHziue)
     $           =  VMTW (jh, jz, VMTW_divHziue)
     $           + VMC(jh, VMC_NHa)
     $             * (VMTW(jh,jz, VMTW_divziuh)
     $               +VMTW(jh,jzb,VMTW_divziuh)* WZV(jz, VMVZ_Za))
         enddo
      enddo
CCC_    * P1 bottom
      jz = KZ0
      do jh = 1, MH
         VMTW (jh, jz, VMTW_divHziue) =
     $        VMTW (jh, jz, VMTW_divHziue)
     $        + VMTW (jh, jz, VMTW_uigradb)
      enddo
#endif
      RETURN
      END
CCC_ + end
#endif /* obsolete */
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
