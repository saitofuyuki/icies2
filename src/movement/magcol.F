C movement/magcol.F --- IcIES/Movement/Age collection
C Maintainer:  SAITO Fuyuki
C Created: Nov 1 2018
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2020/01/08 14:51:03 fuyuki magcol.F>'
#define _FNAME 'movement/magcol.F'
#define _REV   'Snoopy0.97'
CCC_! MANIFESTO
C
C Copyright (C) 2018--2020
C           Japan Agency for Marine-Earth Science and Technology,
C           Ayako ABE-OUCHI
C
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
CCC_* Common macros
#include "ofdlct.h"   /* fortran dialect */
#include "ologfm.h"   /* log common format */
#include "oarpkw.h"   /* operation id in arpeggio/kiwi */
#include "movement.h" /* movement definitions */
CCC_* Options
#ifndef OPT_AGE_BC_LATERAL
#define OPT_AGE_BC_LATERAL 0
#endif
#ifndef OPT_RCIP_ADJUST_SMALL_DAGE
#define OPT_RCIP_ADJUST_SMALL_DAGE 0
#endif
CCC_ + Debug
CCC_* [MAB] batch driver
CCC_ & MABstp  ## Movement/Age integration suite batch
      subroutine MABstp
     O    (iErr,
     M     CW,   VMTA, VMTD,
     I     KTB,  NHt,
     I     VMTI, VMHW,
     I     OMM,  IMM,  PMM,  T,     DT,
     I     WW,   WZV,
     I     MH,   LH,   NZ,   LZ,    KZ0,
     I     IE,   ipKW, iMA,  ipCG,  LCG,  idGM, IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
c
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
c
      _INTENT(INOUT,_REALSTD) VMTA (LH, LZ, *)
      _INTENT(INOUT,_REALSTD) VMTD (LH, LZ, *)
c
      _INTENT(IN,   _REALSTD) VMHW (LH, *)
      _INTENT(IN,   _REALSTD) VMTI (LH, LZ, *)
c
      _INTENT(OUT,  _REALSTD) CW   (*)
      _INTENT(IN,   integer)  KTB  (LH, *)
      _INTENT(IN,   integer)  NHt
c
      _INTENT(IN,   logical)  OMM  (*)
      _INTENT(IN,   integer)  IMM  (*)
      _INTENT(IN,   _REALSTD) PMM  (*)
      _INTENT(IN,   _REALSTD) T, DT
c
      _INTENT(IN,   _REALSTD) WW   (LH, *)
      _INTENT(IN,   _REALSTD) WZV  (*)
      _INTENT(IN,   integer)  IE   (*), iMA (*)
      _INTENT(IN,   integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN,   integer)  LCG, ipCG (*)
      _INTENT(IN,   integer)  idGM (*)
c
      _INTENT(IN,   integer)  IFPl
      integer jedmy
CCC_  - Body
      iErr = 0
CCC_   . upwind
      if (IMM(IMD_AGEC).eq. SW_AGEC_UPWIND) then
         if (iErr.eq.0) then
            call MACdah
     O          (iErr,
     M           VMTA, VMTD, CW,
     I           VMTI, VMHW,
     I           WW,
     I           KTB,  NHt,  MH,  LH,  NZ,   LZ,  KZ0,
     I           IMM,  ipKW, iMA)
         endif
         if (iErr.eq.0) then
           call MAUcxw
     O          (iErr,
     M           VMTD,
     I           VMTA, VMTI, VMHW,
     I           KTB,  WZV,
     I           NHt,  LH,   NZ,   LZ,  KZ0,
     I           IMM(IMD_AADVL),  IFPl)
        endif
        if (iErr.eq.0) then
           call MAUbld
     O         (iErr,
     M          VMTD,
     I          VMTA, VMHW,
     I          KTB,  WZV,  PMM,  IMM, DT,
     I          NHt,  LH,   NZ,   LZ,  KZ0,
     I          IFPl)
        endif
c       age solution to W1
        if (iErr.eq.0) then
            call MUMtds
     O          (iErr,
     M           VMTD,
     W           VMHW (1, VMHW_W1),
     I           VMTD_W1,  VMTD_W2,
     I           VMTD_QU,  VMTD_QD, VMTD_QL, VMTD_QB,
     I           KTB, NHt, LH,  NZ, LZ,  KZ0,
     I           IFPl)
         endif
c       dAge/dp diag to W2
         if (iErr.eq.0) then
            call MAUpsp
     O          (iErr,
     M           VMTD,
     I           VMTD_W2,  VMTD_W1,
     I           IMM,
     I           KTB,
     I           WZV, NHt, LH,  NZ, LZ,  KZ0)
         endif
CCC_   . upwind second-order explicit
      else if (IMM(IMD_AGEC).eq. SW_AGEC_UPWIND_2) then
         if (iErr.eq.0) then
            call MACdah
     O          (iErr,
     M           VMTA, VMTD, CW,
     I           VMTI, VMHW,
     I           WW,
     I           KTB,  NHt,  MH,  LH,  NZ,   LZ,  KZ0,
     I           IMM,  ipKW, iMA)
         endif
         if (iErr.eq.0) then
           call MAUcxw
     O          (iErr,
     M           VMTD,
     I           VMTA, VMTI, VMHW,
     I           KTB,  WZV,
     I           NHt,  LH,   NZ,   LZ,  KZ0,
     I           SW_ADVV_NORMAL,  IFPl)
        endif
        if (iErr.eq.0) then
           call MAUxsv
     O         (iErr,
     M          VMTD,
     I          VMTD_W1, VMTD_W2,
     I          VMTA,  VMHW,
     I          KTB,   WZV,  PMM,  IMM, DT,
     I          NHt,   LH,   NZ,   LZ,  KZ0,
     I          IFPl)
         endif
CCC_   . rcip
      else if (IMM(IMD_AGEC).eq. SW_AGEC_RCIP
     $        .or. IMM(IMD_AGEC).eq. SW_AGEC_RCIP_CORR) then
         if (iErr.eq.0) then
            call MACpad
     O          (iErr,
     M           VMTD,
     I           VMTA, VMTI, VMHW,
     I           KTB,  WZV,
     I           NHt,  LH,   NZ,   LZ,  KZ0,
     I           IMM,  IFPl)
         endif
         if (iErr.eq.0) then
            call MAVctb
     O          (iErr,
     O           VMTD,
     I           VMTA,
     I           WW,    WZV,  PMM,
     I           MH,    LH,   NZ,   LZ,   KZ0,
     I           IFPl)
         endif
         if (iErr.eq.0) then
            call MAVpha
     O          (iErr,
     O           VMTD,  VMTD_W1, VMTD_W2,
     I           VMTA,
     I           IMM(IMD_AGEC),
     I           WZV,   DT,
     I           KTB,   NHt,  LH,   NZ,   LZ,   KZ0)
         endif
         if (iErr.eq.0) then
            call MAVphn
     O          (iErr,
     M           VMTD,  VMTD_W1, VMTD_W2,
     I           VMTA,
     I           WZV,   DT,
     I           KTB,   NHt,  LH,   NZ,   LZ,   KZ0)
         endif
CCC_   . off
      else
         continue
      endif
CCC_  - outputs
      call AFBwmp (jedmy, VMTA, idGM (VGRP_VMTA), T, IE)
      call AFBwmp (jedmy, VMTD, idGM (VGRP_VMTD), T, IE)
CCC_  - post processing
      if (IMM(IMD_AGEC).ne. SW_AGEC_OFF) then
         if (iErr.eq.0) then
            call MUMzsc
     M          (VMTD,  VMTD_W1,
     I           0.0d0, KTB, NHt, MH, LH, NZ, LZ, KZ0)
            call MUMzsc
     M          (VMTD,  VMTD_W2,
     I           0.0d0, KTB, NHt, MH, LH, NZ, LZ, KZ0)
         endif
         if (iErr.eq.0) then
c           old:MTFbwz
            call MUMbwz
     O          (VMTA,  VMTA_age,
     I           VMTD,  VMTD_W1,
     I           KTB,   NHt, MH, LH, NZ, LZ, KZ0)
            call MUMbwz
     O          (VMTA,  VMTA_dad3,
     I           VMTD,  VMTD_W2,
     I           KTB,   NHt, MH, LH, NZ, LZ, KZ0)
         endif
      endif
CCC_   . return
c$$$      call DAtrcU (IFPl, iErr, 'R', 'MABstp')
      RETURN
      END
CCC_* [MAC] common
CCC_ & MACdah  ## age lateral derivatives
      subroutine MACdah
     O    (iErr,
     M     VMTA, VMTD, CW,
     I     VMTI, VMHW,
     I     WW,
     I     KTB,  NH,   MH,  LH,  NZ,   LZ,  KZ0,
     I     IMM,  ipKW, iMA)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  NH, KTB  (LH, *)
      _INTENT(IN,   integer)  NZ, LZ, KZ0
c
      _INTENT(OUT,  _REALSTD) CW   (LH, LZ, *)
c
      _INTENT(INOUT,_REALSTD) VMTD (LH, LZ, *)
      _INTENT(INOUT,_REALSTD) VMTA (LH, LZ, *)
      _INTENT(IN,   _REALSTD) VMTI (LH, LZ, *)
      _INTENT(IN,   _REALSTD) VMHW (LH, *)
      _INTENT(IN,   _REALSTD) WW  (*)
      _INTENT(IN,   integer)  ipKW (*), iMA (*)
      _INTENT(IN,   integer)  IMM(*)
c
      integer jh
      integer jzz, jz
      integer KHU, KHL
      integer KDA
      integer KOD, KOC
CCC_  - Body
      iErr = 0
      if (iErr.eq.0) then
         KHU = VMHW_ADVXe
         KHL = VMHW_ADVXw
         KDA = VMTA_dad1
         KOD = KWO_GXab
         KOC = KWO_FCba
CCC_   . W1 = dA/dx
         call AKBway
     O       (VMTD(1,1,VMTD_W1),    CW,
     I        VMTA(1,1,VMTA_age),   WW,
     I        MH,   LH,  NZ, LZ,    KZ0,
     I        ipKW, iMA, KOD,       KWM_M)
CCC_   . shift
         call AKBmew
     M       (VMTD, CW,
     I        MH,   LH,  NZ,  LZ,  KZ0,  VMTD_W2, VMTD_W1,
     I        ipKW, iMA, KOC, KWM_M)
CCC_   . result
         do    jzz = 1, NZ
            jz = KZ0 + jzz - 1
            do jh = 1,  MH
               VMTA(jh, jz, KDA) =
     $              +VMHW (jh, KHU) * VMTD (jh, jz, VMTD_W1)
     $              +VMHW (jh, KHL) * VMTD (jh, jz, VMTD_W2)
            enddo
         enddo
      endif
      if (iErr.eq.0) then
         KHU = VMHW_ADVYn
         KHL = VMHW_ADVYs
         KDA = VMTA_dad2
         KOD = KWO_GYac
         KOC = KWO_FCca
CCC_   . W1 = dA/dx
         call AKBway
     O       (VMTD(1,1,VMTD_W1),    CW,
     I        VMTA(1,1,VMTA_age),   WW,
     I        MH,   LH,  NZ, LZ,    KZ0,
     I        ipKW, iMA, KOD,       KWM_M)
CCC_   . shift
         call AKBmew
     M       (VMTD, CW,
     I        MH,   LH,  NZ,  LZ,  KZ0,  VMTD_W2, VMTD_W1,
     I        ipKW, iMA, KOC, KWM_M)
CCC_   . result
         do    jzz = 1, NZ
            jz = KZ0 + jzz - 1
            do jh = 1,  MH
               VMTA(jh, jz, KDA) =
     $              +VMHW (jh, KHU) * VMTD (jh, jz, VMTD_W1)
     $              +VMHW (jh, KHL) * VMTD (jh, jz, VMTD_W2)
            enddo
         enddo
      endif
c
      RETURN
      END
CCC_ & MACpad  ## P-space fields  (w:p dw:p/dp)
      subroutine MACpad
     O    (iErr,
     M     VMTD,
     I     VMTA, VMTI, VMHW,
     I     KTB,  WZV,
     I     NH,   LH,   NZ,   LZ,  KZ0,
     I     IMM,  IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  NH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
c
      _INTENT(INOUT,_REALSTD) VMTD (LH, LZ, *)
      _INTENT(IN,   _REALSTD) VMTA (LH, LZ, *)
      _INTENT(IN,   _REALSTD) VMTI (LH, LZ, *)
      _INTENT(IN,   _REALSTD) VMHW (LH, *)
c
      _INTENT(IN,   integer)  KTB  (LH, *)
      _INTENT(IN,   _REALSTD) WZV  (LZ, *)
c
      _INTENT(IN,   integer)  IMM(*)
      _INTENT(IN,   integer)  IFPl
c
      integer   jh,  jht
      integer   jzz, jz
      integer   kfw, kbw
c
      _REALSTD  B33, BZ
      _REALSTD  D3,  D33
      _REALSTD  E3
c
      _REALSTD  DZDT, DZDX,  DZDY
      _REALSTD  DZDZ, DDZDZ
      _REALSTD  DPDZ, DDPDZ, DDZDP
c
      _REALSTD  DZW0, DZW1
CCC   _  - Body
      iErr = 0
      kfw  = 1
      kbw  = 2
c
      DDZDZ = 0.0d0
c
      do    jzz = 1, NZ
         jz = KZ0 + jzz - 1
CCC_   . transformation factors (Z-[Z])
         DPDZ  = WZV (jz, VMVZ_dXa)
         DDPDZ = WZV (jz, VMVZ_ddXa)
         DDZDP = WZV (jz, VMVZ_iddXa)
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
CCC_   . Bz
            BZ  = - VMTI (jh, jz, VMTI_Wadv) * DZDZ
CCC_   . B33
c$$$            B33 = VMTD(jh, jz, VMTD_kai)
            B33 = 0.0d0
CCC_   . D3  = Bi   dZ/dxi + d^2 ZZ/dxi^2 Bii
            D3  =+ BZ
     $           +(B33 * DDZDZ)
CCC_   . D33 = Bii [dZ/dxi]^2
            D33 = B33 * (DZDZ * DZDZ)
CCC_   . E3  = D3   d[Z]/dZ + D33 d^2[Z]/dZ^2
            E3 = +(D3  * DPDZ)
     $           +(D33 * DDPDZ)
            VMTD(jh, jz, VMTD_w3adv) = -E3
CCC_   . Gamma
            DZW0 =
     $           ((VMTI(jh, jz, VMTI_dudZ) * DZDX
     $            +VMTI(jh, jz, VMTI_dvdZ) * DZDY)
     $            +VMTI(jh, jz, VMTI_dwdZ) * DZDZ)
     $           - (VMHW (jh, VMHW_dHdt)
     $            +(VMHW (jh, VMHW_dHdx) * VMTI(jh,jz, VMTI_Uadv)
     $             +VMHW (jh, VMHW_dHdy) * VMTI(jh,jz, VMTI_Vadv)))
     $            * VMHW(jh, VMHW_Hinv)
            DZW1 = BZ * DDZDP * (DPDZ * DPDZ)
            VMTD(jh, jz, VMTD_dw3d3) = DZW0 + DZW1
         enddo
      enddo
      RETURN
      END
CCC_* [MAU] Upwind scheme
CCC_ & MAUcxw  ## equation coefficients, variation wadj
      subroutine MAUcxw
     O    (iErr,
     M     VMTD,
     I     VMTA,  VMTI, VMHW,
     I     KTB,   WZV,
     I     NH,    LH,   NZ,   LZ,  KZ0,
     I     KSWAG, IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  NH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
c
      _INTENT(INOUT,_REALSTD) VMTD (LH, LZ, *)
      _INTENT(IN,   _REALSTD) VMTA (LH, LZ, *)
      _INTENT(IN,   _REALSTD) VMTI (LH, LZ, *)
      _INTENT(IN,   _REALSTD) VMHW (LH, *)
c
      _INTENT(IN,   integer)  KTB  (LH, *)
      _INTENT(IN,   _REALSTD) WZV  (LZ, *)
c
      _INTENT(IN,   integer)  KSWAG
      _INTENT(IN,   integer)  IFPl
c
      integer   jh,  jht
      integer   jzz, jz
      integer   kfw, kbw
c
      _REALSTD  B0, B1, B2, B33, BZ
      _REALSTD  D0, D1, D2, D3,  D33
      _REALSTD  E3, E3u, E3l
c
      _REALSTD  DZDZ, DDZDZ
      _REALSTD  DPDZ, DDPDZ
CCC_  - Body
      iErr = 0
      kfw  = 1
      kbw  = 2
c
      DDZDZ = 0.0d0
c
      do    jzz = 1, NZ
         jz = KZ0 + jzz - 1
CCC_   . transformation factors (Z-[Z])
         DPDZ  = WZV (jz, VMVZ_dXa)
         DDPDZ = WZV (jz, VMVZ_ddXa)
         do jht = 1, NH
            jh = KTB (jht, kfw)
CCC_   . transformation factors (z-Z)
            DZDZ = VMHW (jh, VMHW_Hinv)
CCC_   . B0
            B0  = -1.0d0
CCC_   . Bi = - Ui + (1/rho c) dK/dxi
            B1  = - VMTI (jh, jz, VMTI_Uadv)
            B2  = - VMTI (jh, jz, VMTI_Vadv)
CCC_   . Bz
            BZ  = - VMTI (jh, jz, VMTI_Wadv) * DZDZ
CCC_   . B33
            B33 = VMTD(jh, jz, VMTD_kai)
CCC_   . D0 (not necessary)
CCC_   . D[12]
            D1  = B1
            D2  = B2
CCC_   . D3  = Bi   dZ/dxi + d^2 ZZ/dxi^2 Bii
            D3  =+ BZ
     $           +(B33 * DDZDZ)
CCC_   . D33 = Bii [dZ/dxi]^2
            D33 = B33 * (DZDZ * DZDZ)
CCC_   . E0 (not necessary)
CCC_   . E[12]
            VMTD (jh, jz, VMTD_E1) = D1
            VMTD (jh, jz, VMTD_E2) = D2
CCC_   . E3  = D3   d[Z]/dZ + D33 d^2[Z]/dZ^2
            E3 = +(D3  * DPDZ)
     $           +(D33 * DDPDZ)
            VMTD (jh, jz, VMTD_E3p) = MAX (0.0d0, E3)
            VMTD (jh, jz, VMTD_E3m) = MIN (0.0d0, E3)
            VMTD (jh, jz, VMTD_W1)  = E3
c$$$            write(*, *) 'W', jh, jz, E3,
c$$$     $           D3, D33, DPDZ, BZ, DZDZ, VMTI(jh,jz,VMTI_Wadv)
CCC_   . E33 = D33 [d[Z]/dZ]^2
            VMTD (jh, jz, VMTD_E33) =
     $           + D33 * (DPDZ * DPDZ)
         enddo
      enddo
CCC_   . E3 adjustment
      if (KSWAG.eq. SW_ADVV_NORMAL) then
         continue
      else if (KSWAG.eq. SW_ADVV_STAGGERED) then
CCC_    * internal
         do    jzz = 2, NZ - 1
            jz = KZ0 + jzz - 1
            do jht = 1, NH
               jh = KTB (jht, kfw)
               E3  = VMTD(jh, jz, VMTD_W1)
               E3u = VMTD(jh, jz+1, VMTD_W1) * WZV(jz, VMVZ_Lbp)
     $              +E3                      * WZV(jz, VMVZ_Lbm)
               E3l = E3                      * WZV(jz-1, VMVZ_Lbp)
     $              +VMTD(jh, jz-1, VMTD_W1) * WZV(jz-1, VMVZ_Lbm)
               if (E3u.gt.0.0d0.and.E3l.gt.0.0d0) then
                  VMTD (jh, jz, VMTD_E3p) = E3u
                  VMTD (jh, jz, VMTD_E3m) = 0.0d0
               else if (E3u.lt.0.0d0.and.E3l.lt.0.0d0) then
                  VMTD (jh, jz, VMTD_E3p) = 0.0d0
                  VMTD (jh, jz, VMTD_E3m) = E3l
               else
                  continue
               endif
c$$$               write(*, *) 'WI', jh, jz, E3u, E3l, E3
            enddo
         enddo
CCC_    * bottom
         do    jzz = 1, 1
            jz = KZ0 + jzz - 1
            do jht = 1, NH
               jh = KTB (jht, kfw)
               E3  = VMTD(jh, jz, VMTD_W1)
               E3u = VMTD(jh, jz+1, VMTD_W1) * WZV(jz, VMVZ_Lbp)
     $              +E3                      * WZV(jz, VMVZ_Lbm)
c              caution: E3==0 allowed at the bottom
               if (E3.ge.0.0d0.and.E3u.gt.0.0d0) then
                  VMTD (jh, jz, VMTD_E3p) = E3u
                  VMTD (jh, jz, VMTD_E3m) = 0.0d0
               else
                  continue
               endif
            enddo
         enddo
CCC_    * surface
         do    jzz = NZ, NZ
            jz = KZ0 + jzz - 1
            do jht = 1, NH
               jh = KTB (jht, kfw)
               E3  = VMTD(jh, jz, VMTD_W1)
               E3l = E3                      * WZV(jz-1, VMVZ_Lbp)
     $              +VMTD(jh, jz-1, VMTD_W1) * WZV(jz-1, VMVZ_Lbm)
c              caution: E3==0 allowed at the surface
               if (E3.le.0.0d0.and.E3l.lt.0.0d0) then
                  VMTD (jh, jz, VMTD_E3p) = 0.0d0
                  VMTD (jh, jz, VMTD_E3m) = E3l
               else
                  continue
               endif
            enddo
         enddo
      else
         iErr = -1
 101     format('INVALID AADVL = ', I3)
         write(IFPl, 101) KSWAG
         stop
      endif
CCC_   . dAdp switch
      do    jzz = 1, NZ
         jz = KZ0 + jzz - 1
         do jht = 1, NH
            jh = KTB (jht, kfw)
            E3  = VMTD(jh, jz, VMTD_E3p) + VMTD(jh, jz, VMTD_E3m)
            if      (E3.gt.0.0d0) then
               VMTD(jht, jz, VMTD_dAswp) = 1.0d0
               VMTD(jht, jz, VMTD_dAswm) = 0.0d0
            else if (E3.lt.0.0d0) then
               VMTD(jht, jz, VMTD_dAswp) = 0.0d0
               VMTD(jht, jz, VMTD_dAswm) = 1.0d0
            else
               VMTD(jht, jz, VMTD_dAswp) = WZV(jz, VMVZ_Lap)
               VMTD(jht, jz, VMTD_dAswm) = WZV(jz, VMVZ_Lam)
            endif
         enddo
      enddo
      RETURN
      END
CCC_ & MAUxsv  ## Upwind: explicit second-order (vertical) solver
      subroutine MAUxsv
     O    (iErr,
     M     VMTD,
     I     Kage, Kgrd,
     I     VMTA, VMHW,
     I     KTB,  WZV,  PMM,  IMM, DT,
     I     NH,   LH,   NZ,   LZ,  KZ0,
     I     IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  NH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
c
      _INTENT(INOUT,_REALSTD) VMTD (LH, LZ, *)
      _INTENT(IN,   _REALSTD) VMTA (LH, LZ, *)
      _INTENT(IN,   _REALSTD) VMHW (LH, *)
      _INTENT(IN,   integer)  Kage, Kgrd
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
      _REALSTD  TA, TB
      _REALSTD  E3
c
      iErr  = 0
      kfw   = 1
      kbw   = 2
CCC_   . first order gradient to QD  [1+:NZ-]
      do    jzz = 1, NZ - 1
         jz = KZ0 + jzz - 1
         do jht = 1, NH
            jh = KTB (jht, kfw)
            jhti = jht
            VMTD (jhti, jz, VMTD_QD) =
     $           WZV (jz,   VMVZ_dWMb) * VMTA(jh,jz,  VMTA_age)
     $         + WZV (jz,   VMVZ_dWPb) * VMTA(jh,jz+1,VMTA_age)
         enddo
      enddo
CCC_   . second order gradient (+1 +2) to QU  [1:NZ-2]
      do    jzz = 1, NZ - 2
         jz = KZ0 + jzz - 1
         TA = (2.0d0 * WZV(jz, VMVZ_dPb) + WZV(jz+1, VMVZ_dPb))
     $        / (WZV(jz, VMVZ_dPb) + WZV(jz+1, VMVZ_dPb))
         TB = (- WZV(jz, VMVZ_dPb))
     $        / (WZV(jz, VMVZ_dPb) + WZV(jz+1, VMVZ_dPb))
         do jht = 1, NH
            jh = KTB (jht, kfw)
            jhti = jht
            VMTD (jhti, jz, VMTD_QU)
     $           = TA * VMTD (jhti, jz,   VMTD_QD)
     $           + TB * VMTD (jhti, jz+1, VMTD_QD)
         enddo
      enddo
CCC_    * [NZ-1:NZ]
      do    jzz = NZ - 1, NZ - 1
         jz = KZ0 + jzz - 1
         TA = 2.0d0
         TB = -1.0d0
         do jht = 1, NH
            jh = KTB (jht, kfw)
            jhti = jht
            E3 = VMTD(jh, jz+1, VMTD_E3p) + VMTD(jh, jz+1, VMTD_E3m)
            if (E3.lt.0.0d0) then
               VMTD (jhti, jz, VMTD_QU)
     $              = TA * VMTD (jhti, jz,   VMTD_QD)
     $              + TB * (1.0d0 / E3)
               VMTD (jhti, jz+1, VMTD_QU)
     $              = (1.0d0 / E3)
            else
               VMTD (jhti, jz, VMTD_QU)   = VMTD (jhti, jz, VMTD_QD)
               VMTD (jhti, jz+1, VMTD_QU) = VMTD (jhti, jz, VMTD_QD)
            endif
         enddo
      enddo
CCC_   . second order gradient (-1 -2) to QL [3:NZ]
      do    jzz = 3, NZ
         jz = KZ0 + jzz - 1
         TA = (-2.0d0 * WZV(jz-1, VMVZ_dPb) - WZV(jz-2, VMVZ_dPb))
     $        / (-WZV(jz-1, VMVZ_dPb) - WZV(jz-2, VMVZ_dPb))
         TB = (+ WZV(jz-1, VMVZ_dPb))
     $        / (-WZV(jz-1, VMVZ_dPb) - WZV(jz-2, VMVZ_dPb))
         do jht = 1, NH
            jh = KTB (jht, kfw)
            jhti = jht
            VMTD (jhti, jz, VMTD_QL)
     $           = TA * VMTD (jhti, jz-1, VMTD_QD)
     $           + TB * VMTD (jhti, jz-2, VMTD_QD)
         enddo
      enddo
CCC_    * [1:2]
      do    jzz = 2, 2
         jz = KZ0 + jzz - 1
         TA = 2.0d0
         TB = -1.0d0
         do jht = 1, NH
            jh = KTB (jht, kfw)
            jhti = jht
            E3 = VMTD(jh, jz-1, VMTD_E3p) + VMTD(jh, jz-1, VMTD_E3m)
            if (E3.gt.0.0d0) then
               VMTD (jhti, jz, VMTD_QL)
     $              = TA * VMTD (jhti, jz-1,   VMTD_QD)
     $              + TB * (1.0d0 / E3)
               VMTD (jhti, jz-1, VMTD_QL)
     $              = (1.0d0 / E3)
            else
               VMTD (jhti, jz,   VMTD_QL) = VMTD (jhti, jz-1, VMTD_QD)
               VMTD (jhti, jz-1, VMTD_QL) = VMTD (jhti, jz-1, VMTD_QD)
            endif
         enddo
      enddo
CCC_   . gradient choice (with simple filter)
      do    jzz = 2, NZ - 1
         jz = KZ0 + jzz - 1
         do jht = 1, NH
            if (VMTD(jht,jz,VMTD_QU).gt.0.0d0
     $           .and. VMTD(jht,jz,VMTD_QD).le.0.0d0) then
               VMTD(jht,jz,VMTD_QU) = VMTD(jht,jz,VMTD_QD)
            else if (VMTD(jht,jz,VMTD_QU).lt.0.0d0
     $              .and. VMTD(jht,jz,VMTD_QD).ge.0.0d0) then
               VMTD(jht,jz,VMTD_QU) = VMTD(jht,jz,VMTD_QD)
            endif
            if (VMTD(jht,jz,VMTD_QL).gt.0.0d0
     $           .and. VMTD(jht,jz-1,VMTD_QD).le.0.0d0) then
               VMTD(jht,jz,VMTD_QL) = VMTD(jht,jz-1,VMTD_QD)
            else if (VMTD(jht,jz,VMTD_QL).lt.0.0d0
     $              .and. VMTD(jht,jz-1,VMTD_QD).ge.0.0d0) then
               VMTD(jht,jz,VMTD_QL) = VMTD(jht,jz-1,VMTD_QD)
            endif
c$$$            if (VMTD(jht,jz-1,VMTD_QD).ge.0.0d0
c$$$     $           .and.VMTD(jht,jz,VMTD_QD).le.0.0d0) then
c$$$               VMTD(jht,jz,VMTD_QU) = VMTD(jht,jz,VMTD_QD)
c$$$            else if (VMTD(jht,jz-1,VMTD_QD).le.0.0d0
c$$$     $              .and.VMTD(jht,jz,VMTD_QD).ge.0.0d0) then
c$$$               VMTD(jht,jz,VMTD_QU) = VMTD(jht,jz,VMTD_QD)
c$$$            endif
c$$$            if (VMTD(jht,jz,VMTD_QD).ge.0.0d0
c$$$     $           .and.VMTD(jht,jz-1,VMTD_QD).le.0.0d0) then
c$$$               VMTD(jht,jz,VMTD_QL) = VMTD(jht,jz-1,VMTD_QD)
c$$$            else if (VMTD(jht,jz,VMTD_QD).le.0.0d0
c$$$     $              .and.VMTD(jht,jz-1,VMTD_QD).ge.0.0d0) then
c$$$               VMTD(jht,jz,VMTD_QL) = VMTD(jht,jz-1,VMTD_QD)
c$$$            endif
         enddo
      enddo
c
      do    jzz = 1, NZ
         jz = KZ0 + jzz - 1
         do jht = 1, NH
            VMTD(jht, jz, VMTD_dAswp) =
     $           VMTD(jht, jz, VMTD_dAswp) * VMTD(jht, jz, VMTD_QU)
            VMTD(jht, jz, VMTD_dAswm) =
     $           VMTD(jht, jz, VMTD_dAswm) * VMTD(jht, jz, VMTD_QL)
         enddo
      enddo
      do    jzz = 1, NZ
         jz = KZ0 + jzz - 1
         do jht = 1, NH
            VMTD(jht, jz, Kgrd) =
     $           VMTD(jht, jz, VMTD_dAswp) + VMTD(jht, jz, VMTD_dAswm)
         enddo
      enddo
CCC_   . explicit solver (TODO: 3d)
c          dA/dt = -W dA/dz + 1
      do    jzz = 1, NZ
         jz = KZ0 + jzz - 1
         do jht = 1, NH
            jh = KTB (jht, kfw)
            jhti = jht
            E3 = VMTD(jh, jz, VMTD_E3p) + VMTD(jh, jz, VMTD_E3m)
            VMTD(jht, jz, Kage) =
     $           (1.0d0 + VMTD(jht,jz,Kgrd) * E3)
     $           * DT    + VMTA (jh, jz, VMTA_age)
c$$$            write (*, *) 'A', jht, jz, DT,
c$$$     $           VMTD(jht,jz,Kgrd), E3,
c$$$     $           VMTA (jh, jz, VMTA_age), VMTD(jht, jz, Kage)
         enddo
      enddo
      do    jzz = 1, 1
         jz = KZ0 + jzz - 1
         do jht = 1, NH
            jh = KTB (jht, kfw)
            jhti = jht
            E3 = VMTD(jh, jz, VMTD_E3p) + VMTD(jh, jz, VMTD_E3m)
            if (E3.lt.0.0d0) then
               VMTD (jhti, jz, Kage) = 0.0d0
            endif
         enddo
      enddo
      do    jzz = NZ, NZ
         jz = KZ0 + jzz - 1
         do jht = 1, NH
            jh = KTB (jht, kfw)
            jhti = jht
            E3 = VMTD(jh, jz, VMTD_E3p) + VMTD(jh, jz, VMTD_E3m)
            if (E3.gt.0.0d0) then
               VMTD (jhti, jz, Kage) = 0.0d0
            endif
         enddo
      enddo
c
      RETURN
      END
CCC_ & MAUbld  ## Upwind: matrix builder core
      subroutine MAUbld
     O    (iErr,
     M     VMTD,
     I     VMTA, VMHW,
     I     KTB,  WZV,  PMM,  IMM, DT,
     I     NH,   LH,   NZ,   LZ,  KZ0,
     I     IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  NH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
c
      _INTENT(INOUT,_REALSTD) VMTD (LH, LZ, *)
      _INTENT(IN,   _REALSTD) VMTA (LH, LZ, *)
      _INTENT(IN,   _REALSTD) VMHW (LH, *)
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
      _REALSTD  E0, E0DT,   ECO,  E3
      _REALSTD  DZDZ,  DPDZ
      _REALSTD  BDSWu, BDSWl
      _REALSTD  ECOBC
CCC_  - Body
      iErr  = 0
      kfw   = 1
      kbw   = 2
      E0    = -1.0d0
      E0DT  = E0 / DT
      ECO   = 1.0d0
      if (IMM(IMD_ARSTT).eq. SW_AGEC_RESET_AFTER_ON) then
         write (*, *) 'AGEC_RESET_AFTER_ON DISABLED'
         stop
         ECOBC = ECO
      else
         ECOBC = 0.0d0
      endif
CCC_   . loop interior plus bottom and surface
      do    jzz = 1, NZ
         jz = KZ0 + jzz - 1
         do jht = 1, NH
            jh = KTB (jht, kfw)
            jhti = jht
            VMTD (jhti, jz, VMTD_QU) =
     $           +WZV (jz,   VMVZ_ddWPa)  * VMTD (jh, jz, VMTD_E33)
     $           +WZV (jz,   VMVZ_dWPb)   * VMTD (jh, jz, VMTD_E3p)
            VMTD (jhti, jz, VMTD_QL) =
     $           +WZV (jz,   VMVZ_ddWMa)  * VMTD (jh, jz, VMTD_E33)
     $           +WZV (jz-1, VMVZ_dWMb)   * VMTD (jh, jz, VMTD_E3m)
            VMTD (jhti, jz, VMTD_QD) =
     $           + WZV (jz,   VMVZ_ddWOa) * VMTD (jh, jz, VMTD_E33)
     $           +(WZV (jz,   VMVZ_dWMb)  * VMTD (jh, jz, VMTD_E3p)
     $            +WZV (jz-1, VMVZ_dWPb)  * VMTD (jh, jz, VMTD_E3m))
     $           + E0DT
            VMTD (jhti, jz, VMTD_QB) =
     $           + E0DT * VMTA (jh, jz, VMTA_age)
     $           -(VMTD (jh, jz, VMTD_E1) * VMTA(jh, jz, VMTA_dad1)
     $            +VMTD (jh, jz, VMTD_E2) * VMTA(jh, jz, VMTA_dad2))
     $           - ECO
         enddo
      enddo
CCC_   . bottom
      if (IMM (IMD_ABDZ).eq. SW_ADZ_CENTER) then
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
            E3 = VMTD (jh, jz, VMTD_E3p) + VMTD (jh, jz, VMTD_E3m)
            DZDZ = VMHW (jh, VMHW_Hinv)
            if (E3.eq.0.0d0) then
c              assume no diffusion (neglect dA/dzeta infinity)
               VMTD (jhti, jz, VMTD_QU) = 0.0d0
               VMTD (jhti, jz, VMTD_QL) = 0.0d0
               VMTD (jhti, jz, VMTD_QD) = + E0DT
               VMTD (jhti, jz, VMTD_QB) =
     $              + E0DT * VMTA (jh, jz, VMTA_age)
     $              -(VMTD(jh, jz, VMTD_E1) * VMTA(jh, jz, VMTA_dad1)
     $               +VMTD(jh, jz, VMTD_E2) * VMTA(jh, jz, VMTA_dad2))
     $              - ECO
            else if (E3.gt.0.0d0) then
c              E3 > 0 or w < 0
               continue
            else
               VMTD (jhti, jz, VMTD_QU) = 0.0d0
               VMTD (jhti, jz, VMTD_QL) = 0.0d0
               VMTD (jhti, jz, VMTD_QD) = + E0DT
#if OPT_AGE_BC_LATERAL
               VMTD (jhti, jz, VMTD_QB) =
     $              -(VMTD(jh, jz, VMTD_E1) * VMTA(jh, jz, VMTA_dad1)
     $               +VMTD(jh, jz, VMTD_E2) * VMTA(jh, jz, VMTA_dad2))
     $              -ECOBC
#else /* not OPT_AGE_BC_LATERAL */
               VMTD (jhti, jz, VMTD_QB) = -ECOBC
#endif /* not OPT_AGE_BC_LATERAL */
            endif
         enddo
      enddo
CCC_   . surface
      if (IMM (IMD_ASDZ).eq. SW_ADZ_CENTER) then
         BDSWl = 0.5d0
         BDSWu = 0.5d0
      else
         BDSWl = 0.0d0
         BDSWu = 1.0d0
      endif
      do    jzz = NZ,  NZ
         jz = KZ0 + jzz - 1
         DPDZ  = WZV (jz, VMVZ_dXa)
         do jht = 1,  NH
            jh = KTB (jht, kfw)
            jhti = jht
            E3 = VMTD (jh, jz, VMTD_E3p) + VMTD (jh, jz, VMTD_E3m)
            DZDZ = VMHW (jh, VMHW_Hinv)
            if (E3.eq.0.0d0) then
c              assume no diffusion (neglect dA/dzeta infinity)
               VMTD (jhti, jz, VMTD_QU) = 0.0d0
               VMTD (jhti, jz, VMTD_QL) = 0.0d0
               VMTD (jhti, jz, VMTD_QD) = + E0DT
               VMTD (jhti, jz, VMTD_QB) =
     $              + E0DT * VMTA (jh, jz, VMTA_age)
     $              -(VMTD(jh, jz, VMTD_E1) * VMTA(jh, jz, VMTA_dad1)
     $               +VMTD(jh, jz, VMTD_E2) * VMTA(jh, jz, VMTA_dad2))
     $              - ECO
            else if (E3.lt.0.0d0) then
c              E3 < 0 or w > 0
               continue
            else
               VMTD (jhti, jz, VMTD_QU) = 0.0d0
               VMTD (jhti, jz, VMTD_QL) = 0.0d0
               VMTD (jhti, jz, VMTD_QD) = + E0DT
#if OPT_AGE_BC_LATERAL
               VMTD (jhti, jz, VMTD_QB) =
     $              -(VMTD(jh, jz, VMTD_E1) * VMTA(jh, jz, VMTA_dad1)
     $               +VMTD(jh, jz, VMTD_E2) * VMTA(jh, jz, VMTA_dad2))
     $              -ECOBC
#else /* not OPT_AGE_BC_LATERAL */
               VMTD (jhti, jz, VMTD_QB) = -ECOBC
#endif /* not OPT_AGE_BC_LATERAL */
            endif
         enddo
      enddo
      RETURN
      END
CCC_ & MAUpsp  ## Upwind: post processing
      subroutine MAUpsp
     O    (iErr,
     M     VMTD,
     I     Kgrd, Kage,
     I     IMM,
     I     KTB,  WZV,
     I     NH,   LH,   NZ,   LZ,  KZ0)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  NH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
c
      _INTENT(IN,   integer)  Kage, Kgrd
      _INTENT(IN,   integer)  KTB(LH, *)
      _INTENT(IN,   integer)  IMM(*)
      _INTENT(INOUT,_REALSTD) VMTD (LH, LZ, *)
c
      _INTENT(IN,   _REALSTD) WZV  (LZ, *)
c
      integer   jh,  jht
      integer   jzz, jz
      integer   kfw
      _REALSTD  E3
CCC_  - Body
      iErr = 0
      kfw  = 1
c
      do    jzz = 1, NZ - 1
         jz = KZ0 + jzz - 1
         do jht = 1, NH
            VMTD(jht, jz, Kgrd) =
     $           + WZV(jz, VMVZ_dWPb) * VMTD(jht, jz+1, Kage)
     $           + WZV(jz, VMVZ_dWMb) * VMTD(jht, jz,   Kage)
         enddo
      enddo
      do jht = 1, NH
         jz = KZ0 - 1
         VMTD(jht, jz, Kgrd) = VMTD(jht, jz+1, Kgrd)
         jz = KZ0 + NZ - 1
         VMTD(jht, jz, Kgrd) = VMTD(jht, jz-1, Kgrd)
      enddo
c     dA switches are updated here
      do    jzz = 1, NZ
         jz = KZ0 + jzz - 1
         do jht = 1, NH
            VMTD(jht, jz, VMTD_dAswp) =
     $           VMTD(jht, jz, VMTD_dAswp) * VMTD(jht, jz,   Kgrd)
            VMTD(jht, jz, VMTD_dAswm) =
     $           VMTD(jht, jz, VMTD_dAswm) * VMTD(jht, jz-1, Kgrd)
         enddo
      enddo
      do    jzz = 1, NZ
         jz = KZ0 + jzz - 1
         do jht = 1, NH
            VMTD(jht, jz, Kgrd) =
     $           VMTD(jht, jz, VMTD_dAswp) + VMTD(jht, jz, VMTD_dAswm)
         enddo
      enddo
c
      if (IMM(IMD_ARSTT).eq. SW_AGEC_RESET_AFTER_ON) then
         do    jzz = 1,  1
            jz = KZ0 + jzz - 1
            do jht = 1,  NH
               jh = KTB (jht, kfw)
               E3 = VMTD (jh, jz, VMTD_E3p) + VMTD (jh, jz, VMTD_E3m)
               if (E3.lt.0.0d0) then
                  VMTD(jht, jz, Kage) = 0.0d0
               endif
            enddo
         enddo
         do    jzz = NZ,  NZ
            jz = KZ0 + jzz - 1
            do jht = 1,  NH
               jh = KTB (jht, kfw)
               E3 = VMTD (jh, jz, VMTD_E3p) + VMTD (jh, jz, VMTD_E3m)
               if (E3.gt.0.0d0) then
                  VMTD(jht, jz, Kage) = 0.0d0
               endif
            enddo
         enddo
      endif
      RETURN
      END
CCC_* [MAV] RCIP scheme (vertical only)
CCC_ & MAVctb  ## RCIP/vertical coefficient table (vertical)
      subroutine MAVctb
     O    (iErr,
     O     VMTD,
     I     VMTA,
     I     WW,    WZV,  PMM,
     I     MH,    LH,   NZ,   LZ,   KZ0,
     I     IFPl)
CCC_  - Declaration
      implicit none
c
      _INTENT(OUT,integer)   iErr
c
      _INTENT(IN, integer)  MH, LH
      _INTENT(IN, integer)  NZ, LZ,   KZ0
      _INTENT(OUT,_REALSTD) VMTD(LH, LZ, *)
      _INTENT(IN, _REALSTD) VMTA(LH, LZ, *)
c
      _INTENT(IN, _REALSTD) WZV(LZ, *)
      _INTENT(IN, _REALSTD) WW (*)
      _INTENT(IN, _REALSTD) PMM(*)
c
      _INTENT(IN, integer)  IFPl
c
      integer jz, jzz, jzs, jzup
      integer jh
      _REALSTD DZP, FDV, DA, ECHK
      _REALSTD BA,  A3, A2, A1
      _REALSTD TA
      _REALSTD EPSM
CCC_  - Body
      iErr = 0
      EPSM = PMM(PMT_AEPS)
c
      jzs  = KZ0 + NZ - 1
      do jzz = 0, NZ - 1
         jz = KZ0 + jzz
         do jh = 1, MH
CCC_   . check upwind
            if (VMTD(jh, jz, VMTD_w3adv).ge.0.0d0) then
c     w > 0  [k:k-1]
               jzup = MAX(jz - 1, KZ0)
               DZP = - WZV(MAX(KZ0,jz-1), VMVZ_dPb)
            else
c     w < 0  [k:k+1]
               jzup = MIN(jz + 1, jzs)
               DZP = + WZV(MIN(jz, jzs-1), VMVZ_dPb)
            endif
            VMTD(jh,jz,VMTD_cfl) = DZP
C     todo: use dW[PM]b
#if      OPT_RCIP_ADJUST_SMALL_DAGE
            DA = VMTA(jh, jzup, VMTA_age) - VMTA(jh, jz, VMTA_age)
            ECHK = ABS(DA) / MAX(EPSM, ABS(VMTA(jh, jz, VMTA_age)))
 101        format('MAVctb: small diff age detected = ',
     $           I5, I5, 1x, E12.5, 1x, E9.3, 1x, E9.3, 1x, E9.3)
            if (ECHK.gt.0.0d0.and.ECHK.le.EPSM) then
               write (IFPl, 101) jh, jz,
     $              DA, VMTA(jh, jz, VMTA_age), ECHK, ECHK / EPSM
               FDV = 0.0d0
            else
               FDV = DA / DZP
            endif
#else /* not OPT_RCIP_ADJUST_SMALL_DAGE */
            DA = VMTA(jh, jzup, VMTA_age) - VMTA(jh, jz, VMTA_age)
            FDV = DA / DZP
#endif /* not OPT_RCIP_ADJUST_SMALL_DAGE */
C           maybe this condition can be skipped (same as below)
            if (FDV.eq.VMTA(jh, jz, VMTA_dad3)
     $           .and.FDV.eq.0.0d0) then
               BA = 0.0d0
               A3 = 0.0d0
               A2 = 0.0d0
               A1 = 0.0d0
            else if ((VMTA(jh, jz, VMTA_dad3).le.FDV
     $           .and. FDV.lt.VMTA(jh, jzup, VMTA_dad3)) .or.
     $           (VMTA(jh, jz, VMTA_dad3).ge.FDV
     $           .and. FDV.gt.VMTA(jh, jzup, VMTA_dad3))) then
CCC_   . RCIP
               BA = (ABS ((FDV - VMTA(jh, jz, VMTA_dad3))
     $              / (VMTA(jh, jzup, VMTA_dad3) - FDV)) - 1.0d0)
     $              / DZP
               A3 = 0.0d0
               A2 = (FDV * BA
     $              + (FDV - VMTA(jh, jz, VMTA_dad3)) / DZP)
               A1 = VMTA(jh, jz, VMTA_dad3)
     $              + VMTA(jh, jz, VMTA_age) * BA
            else if (FDV.eq.VMTA(jh, jzup, VMTA_dad3)) then
               BA = 0.0d0
               A3 = 0.0d0
               A2 = 0.0d0
               A1 = FDV
            else
CCC_   . CIP
               BA = 0.0d0
               TA = +(VMTA(jh, jz,   VMTA_dad3) - FDV)
     $              +(VMTA(jh, jzup, VMTA_dad3) - FDV)
               A3 =  TA / (DZP * DZP)
               A2 = (2.0d0 * (FDV - VMTA(jh, jz,   VMTA_dad3))
     $              +1.0d0 * (FDV - VMTA(jh, jzup, VMTA_dad3)))
     $              / DZP
               A1 = VMTA(jh, jz, VMTA_dad3)
     $              + VMTA(jh, jz, VMTA_age) * BA
            endif
CCC_   . store
c$$$            VMTD(jh, jz, VMTD_a1) = A1
            VMTD(jh, jz, VMTD_a2) = A2
            VMTD(jh, jz, VMTD_a3) = A3
            VMTD(jh, jz, VMTD_ba) = BA
         enddo
      enddo
c$$$CCC_   . table generation
c$$$      do jzz = 0, NZ - 1
c$$$         jz = KZ0 + jzz
c$$$         call MAVctp
c$$$     O       (iErr,
c$$$     O        VMTD,
c$$$     I        VMTA,
c$$$     I        jz,
c$$$     I        WZV,
c$$$     I        MH,    LH,   NZ,   LZ,   KZ0,
c$$$     I        IFPl)
c$$$      enddo
      RETURN
      END
CCC_ & MAVpha  ## RCIP/vertical advection phase
      subroutine MAVpha
     O    (iErr,
     O     VMTD,  Kage, Kgrd,
     I     VMTA,
     I     KSCHM,
     I     WZV,   DT,
     I     KTB,   NHt,  LH,   NZ,   LZ,   KZ0)
CCC_  - Declaration
      implicit none
c
      _INTENT(OUT,  integer)  iErr
c
      _INTENT(IN,   integer)  Kage, Kgrd
c
      _INTENT(IN,   integer)  NHt, LH
      _INTENT(IN,   integer)  KTB(LH, *)
      _INTENT(IN,   integer)  KSCHM
      _INTENT(IN,   integer)  NZ,  LZ,   KZ0
      _INTENT(INOUT,_REALSTD) VMTD (LH, LZ, *)
      _INTENT(IN,   _REALSTD) VMTA (LH, LZ, *)
c
      _INTENT(IN,   _REALSTD) WZV(LZ, *)
      _INTENT(IN,   _REALSTD) DT
c
      integer  jz, jzz
      integer  jh, jht
      integer  kfw
      _REALSTD UDT,  GDT
      _REALSTD VNMR, VDNM, VNMG
      _REALSTD A1P,  A2P,  DAGE, DGRD
CCC_  - Body
      iErr = 0
      kfw  = 1
c
      if (KSCHM.eq. SW_AGEC_RCIP) then
         do jzz = 0, NZ - 1
            jz = KZ0 + jzz
            do jht = 1, NHt
               jh = KTB (jht, kfw)
               UDT = - VMTD(jh, jz, VMTD_w3adv) * DT
               VMTD(jh,jz,VMTD_udt) = UDT
            enddo
         enddo
      else
         do jzz = 0, NZ - 1
            jz = KZ0 + jzz
            do jht = 1, NHt
               jh = KTB (jht, kfw)
               if (VMTD(jh, jz, VMTD_dw3d3).eq.0.0d0) then
                  UDT = - VMTD(jh, jz, VMTD_w3adv) * DT
               else
                  GDT = - VMTD(jh, jz, VMTD_dw3d3) * DT
                  UDT = VMTD(jh, jz, VMTD_w3adv)
     $                 * (EXP(GDT) - 1.0d0) / VMTD(jh, jz, VMTD_dw3d3)
               endif
               VMTD(jh,jz,VMTD_udt) = UDT
            enddo
         enddo
      endif
      do jzz = 0, NZ - 1
         jz = KZ0 + jzz
         do jht = 1, NHt
            jh = KTB (jht, kfw)
            UDT = VMTD(jh, jz, VMTD_udt)
            VMTD(jh,jz,VMTD_cfl) = UDT / VMTD(jh,jz,VMTD_cfl)
         enddo
      enddo
      do jzz = 0, NZ - 1
         jz = KZ0 + jzz
         do jht = 1, NHt
            jh = KTB (jht, kfw)
            UDT = VMTD(jh, jz, VMTD_udt)
            A1P = VMTA(jh, jz, VMTA_dad3)
            VNMR =
     $           ((VMTD(jh, jz, VMTD_a3) * UDT
     $            +VMTD(jh, jz, VMTD_a2)) * UDT
     $             +A1P) * UDT
            VDNM = 1.0d0 + VMTD(jh, jz, VMTD_ba) * UDT
            DAGE = VNMR / VDNM
            VMTD(jht, JZ, Kage) =
     $           VMTA(jh, jz, VMTA_age) + DAGE
            A2P = VMTD(jh, jz, VMTD_a2) * 2.0d0
     $           - VMTD(jh, jz, VMTD_ba) * A1P
            VNMG =
     $           ((A2P + VMTD(jh, jz, VMTD_a3) * 3.0d0 * UDT)) * UDT
            DGRD = (VNMG - DAGE * VMTD(jh, jz, VMTD_ba)) / VDNM
            VMTD(jht, JZ, Kgrd) =
     $           VMTA(jh, jz, VMTA_dad3) + DGRD
         enddo
      enddo
c
      RETURN
      END
CCC_ & MAVphn  ## RCIP/vertical non-advection phase
      subroutine MAVphn
     O    (iErr,
     M     VMTD,  Kage, Kgrd,
     I     VMTA,
     I     WZV,   DT,
     I     KTB,   NHt,  LH,   NZ,   LZ,   KZ0)
CCC_  - Declaration
      implicit none
c
      _INTENT(OUT,  integer)  iErr
c
      _INTENT(IN,   integer)  Kage, Kgrd
c
      _INTENT(IN,   integer)  NHt, LH
      _INTENT(IN,   integer)  KTB(LH, *)
      _INTENT(IN,   integer)  NZ,  LZ,   KZ0
      _INTENT(INOUT,_REALSTD) VMTD (LH, LZ, *)
      _INTENT(IN,   _REALSTD) VMTA (LH, LZ, *)
c
      _INTENT(IN,   _REALSTD) WZV(LZ, *)
      _INTENT(IN,   _REALSTD) DT
c
      integer  jz, jzz
      integer  jh, jht
      integer  kfw
c
      iErr = 0
c
      kfw  = 1
#if 0 /* explicit (test3.  worse) */
c     dA/dt = 1
c     dG/dt = (Gn-Go)/dt = -dw/dx Go
c             Gn = -dw/dx Go dt + Go
c                = Go (1- dw/dx dt)
      do jzz = 1, NZ - 2
         jz = KZ0 + jzz
         do jht = 1, NHt
            jh = KTB (jht, kfw)
            VMTD(jht, JZ, Kage) = VMTD(jht, JZ, Kage) + DT
            VMTD(jht, JZ, Kgrd) =
     $           VMTD(jht, JZ, Kgrd)
     $           * (1.0d0 - VMTD(jh, JZ, VMTD_dw3d3) * DT)
         enddo
      enddo
      do jzz = 0, 0
         jz = KZ0 + jzz
         do jht = 1, NHt
            jh = KTB (jht, kfw)
            if (VMTD(jh, JZ, VMTD_w3adv).gt.0.0d0) then
               VMTD(jht, JZ, Kage) = 0.0d0
               VMTD(jht, JZ, Kgrd) = 1.0d0 / VMTD(jh, JZ, VMTD_w3adv)
            else if (VMTD(jh, JZ, VMTD_w3adv).eq.0.0d0) then
               VMTD(jht, JZ, Kage) = VMTD(jht, JZ, Kage) + DT
            else
               VMTD(jht, JZ, Kage) = VMTD(jht, JZ, Kage) + DT
               VMTD(jht, JZ, Kgrd) =
     $              VMTD(jht, JZ, Kgrd)
     $              * (1.0d0 - VMTD(jh, JZ, VMTD_dw3d3) * DT)
            endif
         enddo
      enddo
      do jzz = NZ - 1, NZ - 1
         jz = KZ0 + jzz
         do jht = 1, NHt
            jh = KTB (jht, kfw)
            if (VMTD(jh, JZ, VMTD_w3adv).lt.0.0d0) then
               VMTD(jht, JZ, Kage) = 0.0d0
               VMTD(jht, JZ, Kgrd) = 1.0d0 / VMTD(jh, JZ, VMTD_w3adv)
            else if (VMTD(jh, JZ, VMTD_w3adv).eq.0.0d0) then
               VMTD(jht, JZ, Kage) = VMTD(jht, JZ, Kage) + DT
            else
               VMTD(jht, JZ, Kage) = VMTD(jht, JZ, Kage) + DT
               VMTD(jht, JZ, Kgrd) =
     $              VMTD(jht, JZ, Kgrd)
     $              * (1.0d0 - VMTD(jh, JZ, VMTD_dw3d3) * DT)
            endif
         enddo
      enddo
#else
c     dA/dt = 1
c     dG/dt = (Gn-Go)/dt = -dw/dx Gn
c             (1/dt+dw/dx)Gn = Go/dt
c             Gn = Go / [dt (1/dt + dw/dx)]
      do jzz = 1, NZ - 2
         jz = KZ0 + jzz
         do jht = 1, NHt
            jh = KTB (jht, kfw)
            VMTD(jht, JZ, Kage) = VMTD(jht, JZ, Kage) + DT
            VMTD(jht, JZ, Kgrd) =
     $           VMTD(jht, JZ, Kgrd)
     $           / (1.0d0 + VMTD(jh, JZ, VMTD_dw3d3) * DT)
         enddo
      enddo
      do jzz = 0, 0
         jz = KZ0 + jzz
         do jht = 1, NHt
            jh = KTB (jht, kfw)
            if (VMTD(jh, JZ, VMTD_w3adv).gt.0.0d0) then
               VMTD(jht, JZ, Kage) = 0.0d0
               VMTD(jht, JZ, Kgrd) = 1.0d0 / VMTD(jh, JZ, VMTD_w3adv)
            else if (VMTD(jh, JZ, VMTD_w3adv).eq.0.0d0) then
               VMTD(jht, JZ, Kage) = VMTD(jht, JZ, Kage) + DT
            else
               VMTD(jht, JZ, Kage) = VMTD(jht, JZ, Kage) + DT
               VMTD(jht, JZ, Kgrd) =
     $              VMTD(jht, JZ, Kgrd)
     $              / (1.0d0 + VMTD(jh, JZ, VMTD_dw3d3) * DT)
            endif
         enddo
      enddo
      do jzz = NZ - 1, NZ - 1
         jz = KZ0 + jzz
         do jht = 1, NHt
            jh = KTB (jht, kfw)
            if (VMTD(jh, JZ, VMTD_w3adv).lt.0.0d0) then
               VMTD(jht, JZ, Kage) = 0.0d0
               VMTD(jht, JZ, Kgrd) = 1.0d0 / VMTD(jh, JZ, VMTD_w3adv)
            else if (VMTD(jh, JZ, VMTD_w3adv).eq.0.0d0) then
               VMTD(jht, JZ, Kage) = VMTD(jht, JZ, Kage) + DT
            else
               VMTD(jht, JZ, Kage) = VMTD(jht, JZ, Kage) + DT
               VMTD(jht, JZ, Kgrd) =
     $              VMTD(jht, JZ, Kgrd)
     $              / (1.0d0 + VMTD(jh, JZ, VMTD_dw3d3) * DT)
            endif
         enddo
      enddo
#endif
c
      RETURN
      END
CCC_& MAGnpm  ## Parameters initialization by namelist
      subroutine MAGnpm
     O    (iErr,
     O     OMM,  IMM,  PMM,
     I     CR,   IFPi, IFPn, IFPl)
CCC_ + Declaration
      implicit none
CCC_  - Arguments
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,logical)   OMM (*)
      _INTENT(OUT,integer)   IMM (*)
      _INTENT(OUT,_REALSTD)  PMM (*)
      _INTENT(IN, character) CR*(*)
      _INTENT(IN, integer)   IFPi, IFPn, IFPl
CCC_  - Configuration
      character  CROOT * (8)
      _REALSTD   ADIFF
      _REALSTD   AGEEPS
      namelist /NIPRMA/
     $     CROOT,
     $     ADIFF, AGEEPS
      _REALSTD   EPSM
CCC_  - interior
      integer jc
CCC_ + Body
      iErr = 0
CCC_  - Configuration
      jc = 0
 200  continue
      call UUrwnd (iErr, IFPi)
c
 100  continue
c
      CROOT = ' '
      ADIFF  = 0.0d0
c$$$      AGEEPS = 2.0d0
      AGEEPS = 0.0d0
c$$$      AGEEPS = 1.0d0
c$$$      AGEEPS = 2.1d0
c
      if (IFPi.ge.0) then
         READ  (IFPi, NIPRMA, IOSTAT = iErr)
      else if (IFPi.eq.-1) then
         READ  (*,    NIPRMA, IOSTAT = iErr)
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
            write (IFPn, NIPRMA, IOSTAT = iErr)
         else if (COND_S(IFPn)) then
            write (*,   NIPRMA, IOSTAT = iErr)
         endif
      endif
CCC_  - adjustment
#if OPT_RCIP_ADJUST_SMALL_DAGE
 301  format('MAGNMP ADJUST AGEEPS = ', 3E28.16)
      if (AGEEPS.ge.1.0d0) then
         call UFxfpe (EPSM, 1, IFPl)
         AGEEPS = AGEEPS * EPSM
         if (COND_N(IFPn)) then
            write (IFPn, 301) AGEEPS, EPSM, AGEEPS / EPSM
         else if (COND_S(IFPn)) then
            write (*,    301) AGEEPS, EPSM, AGEEPS / EPSM
         endif
      endif
#else /* OPT_RCIP_ADJUST_SMALL_DAGE */
 309  format('MAGNMP AGEEPS DISABLED. ABORT. ', E28.16)
      if (AGEEPS.ne.0.0d0) then
         if (COND_N(IFPn)) then
            write (IFPn, 309) AGEEPS
         else if (COND_S(IFPn)) then
            write (*,    309) AGEEPS
         endif
         iErr = 1
         stop
      endif
#endif /* OPT_RCIP_ADJUST_SMALL_DAGE */
CCC_  - Packing
      PMM(PMT_ADIFF) = ADIFF
      PMM(PMT_AEPS)  = AGEEPS
c
      call DAtrcU (IFPl, iErr, 'R', 'MAGNPM')
      RETURN
      END
CCC_& MAGCOL  ## Movement/Age announcement
      subroutine MAGCOL (STRA, STRB, IOP)
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
CCC_* obsolete
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
