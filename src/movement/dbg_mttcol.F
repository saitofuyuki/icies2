C movement/dbg_mttcol.F --- IcIES/Movement/Debug mttcol
C Author: SAITO Fuyuki
C Created: Jun 3 2013
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2020/09/17 06:59:55 fuyuki dbg_mttcol.F>'
#define _FNAME 'movement/mttcol.F'
#define _REV   'Snoopy0.8'
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
#include "ologfm.h"   /* log common format */
#include "oarpkw.h"   /* operation id in arpeggio/kiwi */
#include "movement.h" /* movement definitions */
CCC_* Check if compile
#ifndef   TEST_MDRVRM
#  define TEST_MDRVRM 0
#endif
#if TEST_MDRVRM == 4 || TEST_MDRVRM == 0
#ifndef   DEBUG_MTTCOL_SPECIAL
#  define DEBUG_MTTCOL_SPECIAL 1
#endif
#endif
#ifndef   DEBUG_MTTCOL_SPECIAL
#  define DEBUG_MTTCOL_SPECIAL 0
#endif
CCC_* Special procedures for debug
#ifndef   TEST_DBG_MTTCOL
#  define TEST_DBG_MTTCOL 0
#endif
CCC_ + begin
#if   DEBUG_MTTCOL_SPECIAL
CCC_ & MTSbld_div  ## matrix builder core (temperature dependent)
      subroutine MTSbld_div
     O    (QU,  QB,
     I     E33, E3p, E1, E2, TX, TY, HS, TI,
     I     ZDD, ZD,  DT,
     I     NH,  LH,  NZ, LZ)
CCC_  - Declaration
      implicit none
c
      _INTENT(IN,integer)  NH, LH
      _INTENT(IN,integer)  NZ, LZ
c
      _INTENT(OUT,_REALSTD)  QU (LH, LZ)
      _INTENT(OUT,_REALSTD)  QB (LH, LZ)
c
      _INTENT(IN,_REALSTD)   E33 (LH, LZ)
      _INTENT(IN,_REALSTD)   E3P (LH, LZ)
      _INTENT(IN,_REALSTD)   E1  (LH, LZ)
      _INTENT(IN,_REALSTD)   E2  (LH, LZ)
      _INTENT(IN,_REALSTD)   TX  (LH, LZ)
      _INTENT(IN,_REALSTD)   TY  (LH, LZ)
      _INTENT(IN,_REALSTD)   HS  (LH, LZ)
      _INTENT(IN,_REALSTD)   TI  (LH, LZ)
c
      _INTENT(IN,_REALSTD)   ZDD (LZ)
      _INTENT(IN,_REALSTD)   ZD  (LZ)
      _INTENT(IN,_REALSTD)   DT
c
      integer   jh,  jz
c
      _REALSTD  E0, E0DT
CCC_  - Body
      E0    = -1.0d0
      E0DT  = E0 / DT
CCC_   . loop interior
      do    jz = 1, NZ
         do jh = 1, NH
             QU (jh, jz) =
     $            ZDD (jz) * E33 (jh, jz) + ZD (jz) * E3p (jh, jz)
             QB (jh, jz) =
     $            + E0DT * TI (jh, jz)
     $            -(E1 (jh, jz)*TX (jh, jz) + E2 (jh, jz)*TY (jh, jz))
     $            - HS (jh, jz)
         enddo
      enddo
      RETURN
      END
CCC_ & MTSbld_div_param  ##
      subroutine MTSbld_div_param
     I    (NH, NZ)
      implicit none
      _INTENT(IN,integer) NH, NZ
      integer    LH, LZ
      parameter (LH = 5, LZ = 6)
      _REALSTD  QU  (LH, LZ)
      _REALSTD  QB  (LH, LZ)
c
      _REALSTD  E33 (LH, LZ)
      _REALSTD  E3P (LH, LZ)
      _REALSTD  E1  (LH, LZ)
      _REALSTD  E2  (LH, LZ)
      _REALSTD  TX  (LH, LZ)
      _REALSTD  TY  (LH, LZ)
      _REALSTD  HS  (LH, LZ)
      _REALSTD  TI  (LH, LZ)
c
      _REALSTD  ZDD (LZ)
      _REALSTD  ZD  (LZ)
      _REALSTD  DT
      _REALSTD  E0, E0DT
c
      integer    jh, jz
c
      QU = 0.0d0
      QB = 0.0d0
      E33= 0.0d0
      E3P= 0.0d0
      E1 = 0.0d0
      E2 = 0.0d0
      TX = 0.0d0
      TY = 0.0d0
      HS = 0.0d0
      TI = 0.0d0
      ZDD= 0.0d0
      ZD = 0.0d0
c
      E33(1:NH, 1:NZ) = 0.430890398476311629D-04
      E3P(1:NH, 1:NZ) = 0.835593719010322452D-04
      E1 (1:NH, 1:NZ) = 0.305358201834205305D-01
      E2 (1:NH, 1:NZ) =-0.328867012561717309D-05
      TX (1:NH, 1:NZ) =-0.595113113309366643D-05
      TY (1:NH, 1:NZ) = 0.287863073886816118D-04
      HS (1:NH, 1:NZ) = 0.114966438439251860D-03
      TI (1:NH, 1:NZ) = 0.256087347803157854D+03
c
      ZDD (1:NZ) = 0.256000000000000000D+03
      ZD  (1:NZ) = 0.160000000000000000D+02
      DT         = 0.125d0
c
      call MTSbld_div
     O    (QU,  QB,
     I     E33, E3p, E1, E2, TX, TY, HS, TI,
     I     ZDD, ZD,  DT,
     I     NH,  LH,  NZ, LZ)
c
 101  format ('TEST ID ', 4I3)
 102  format (2I3, 1x, 2E26.18)
      write (*, 101) NH, NZ, LH, LZ
c
      E0    = -1.0d0
      E0DT  = E0 / DT
      do    jz = 1, NZ
         do jh = 1, NH
            write (*, 102)
     $           jh, jz,
     $           QB (jh, jz),
     $            + E0DT * TI (jh, jz)
     $            -(E1 (jh, jz)*TX (jh, jz) + E2 (jh, jz)*TY (jh, jz))
     $            - HS (jh, jz)
         enddo
      enddo
c
      RETURN
      END
CCC_ & MTSbld_clone  ## matrix builder core (temperature dependent)
      subroutine MTSbld_clone
     O    (iErr,
     M     VMTW,
     I     VMTI, VMHW, VMHI, VMHB,
     I     KTB,  WZV,  PMM,  IMM, DT,
     I     NH,   LH,   NZ,   LZ,  KZ0,
     I     IFPl, LVL)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  NH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
c
      _INTENT(IN,   integer)  LVL
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
      _REALSTD  CONDI
CCC_  - Body
      iErr  = 0
      kfw   = 1
      kbw   = 2
      E0    = -1.0d0
      E0DT  = E0 / DT
      CONDI = PMM (PMT_COND)
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
      if (LVL.gt.0) then
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
            DZDZ  = VMHW (jh, VMHW_Hinv)
            TKDD  = CONDI * DPDZ * DZDZ
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
            VMTW (jhti, jz, VMTW_QU) = QU * BL - QL * BU
            VMTW (jhti, jz, VMTW_QD) = QD * BL - QL * BD
            VMTW (jhti, jz, VMTW_QB) = QB * BL - QL * BB
            VMTW (jhti, jz, VMTW_QL) = 0.0d0
         enddo
      enddo
      endif
CCC_   . surface
      if (LVL.gt.1) then
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
            VMTW (jhti, jz, VMTW_QB) = E0DT * VMHB (jh, VMHB_TSI)
         enddo
      enddo
      endif
      RETURN
      END
CCC_ & MTSbld_clone2  ## matrix builder core (temperature dependent)
      subroutine MTSbld_clone2
     O    (iErr,
     M     VMTW,
     I     VMTI, VMHW, VMHI, VMHB,
     I     KTB,  WZV,  PMM,  IMM, DT,
     I     NH,   LH,   NZ,   LZ,  KZ0,
     I     IFPl, LVL)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  NH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
c
      _INTENT(IN,   integer)  LVL
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
      _REALSTD  CONDI
CCC_  - Body
      iErr  = 0
      kfw   = 1
      kbw   = 2
      E0    = -1.0d0
      E0DT  = E0 / DT
      CONDI = PMM (PMT_COND)
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
            VMTW (jhti, jz, VMTW_QB) =
     $           + E0DT * VMTI (jh, jz, VMTI_T)
     $           -(VMTW (jh, jz, VMTW_E1) * VMTW (jh, jz, VMTW_dTdXa)
     $            +VMTW (jh, jz, VMTW_E2) * VMTW (jh, jz, VMTW_dTdYa))
     $           - VMTW (jh, jz, VMTW_HS)
         enddo
      enddo
      RETURN
      END
CCC_ & MTSbld_min  ## matrix builder core (temperature dependent)
      subroutine MTSbld_min
     O    (iErr,
     M     VMTW,
     I     VMTI,
     I     WZV,  DT,
     I     NH,   LH,   NZ,   LZ,  KZ0,
     I     KQU,  KQB,  KZDD, KZD,
     I     KE33, KE3p, KE1,  KE2, KTX, KTY, KHS, KIT,
     I     IFPl, LVL)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  NH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
c
      _INTENT(IN,   integer)  LVL
c
      _INTENT(INOUT,_REALSTD) VMTW (LH, LZ, *)
      _INTENT(IN,   _REALSTD) VMTI (LH, LZ, *)
c
      _INTENT(IN,   _REALSTD) DT
      _INTENT(IN,   _REALSTD) WZV  (LZ, *)
c
      _INTENT(IN,   integer)  IFPl
      _INTENT(IN,   integer)  KQU,  KQB
      _INTENT(IN,   integer)  KZDD, KZD
      _INTENT(IN,   integer)  KE33, KE3p
      _INTENT(IN,   integer)  KE1,  KE2, KTX, KTY, KHS, KIT
c
      integer   jh
      integer   jzz, jz
c
      _REALSTD  E0, E0DT
CCC_  - Body
      iErr  = 0
      E0    = -1.0d0
      E0DT  = E0 / DT
CCC_   . loop interior
      do    jzz = 1, LZ
         jz = KZ0 + jzz - 1
         do jh = 1, NH
c$$$            VMTW (jh, jz, VMTW_QU) =
c$$$     $           +WZV (jz,   VMVZ_ddWPa)  * VMTW (jh, jz, VMTW_E33)
c$$$     $           +WZV (jz,   VMVZ_dWPb)   * VMTW (jh, jz, VMTW_E3p)
c$$$            VMTW (jh, jz, VMTW_QB) =
c$$$     $           + E0DT * VMTI (jh, jz, VMTI_T)
c$$$     $           -(VMTW (jh, jz, VMTW_E1) * VMTW (jh, jz, VMTW_dTdXa)
c$$$     $            +VMTW (jh, jz, VMTW_E2) * VMTW (jh, jz, VMTW_dTdYa))
c$$$     $           - VMTW (jh, jz, VMTW_HS)
            VMTW (jh, jz, KQU) =
     $           +WZV (jz,   KZDD)  * VMTW (jh, jz, KE33)
     $           +WZV (jz,   KZD)   * VMTW (jh, jz, KE3p)
            VMTW (jh, jz, KQB) =
     $           + E0DT * VMTI (jh, jz, KIT)
     $           -(VMTW (jh, jz, KE1) * VMTW (jh, jz, KTX)
     $            +VMTW (jh, jz, KE2) * VMTW (jh, jz, KTY))
     $           - VMTW (jh, jz, KHS)
         enddo
      enddo
      RETURN
      END
CCC_ & MTTdbg_mtsbld_core  ## MTSbld wrapper core
      subroutine MTTdbg_min_core
     O    (iErr,
     W     WMTW, WMTI,  WWZ,
     I     VMTW, VMTI,
     I     WZV,  DT,
     I     LHW,  LZW,   IHTGT, IZTGT,
     I     NHt,  LH,    NZ,   LZ,  KZ0,
     I     KQU,  KQB,   KZDD, KZD,
     I     KE33, KE3p,  KE1,  KE2, KTX, KTY, KHS, KIT,
     I     IFPl, ITSTP, CTAG, IR,  NR)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  NHt, LH
      _INTENT(IN,   integer)  NZ,  LZ, KZ0
c
      _INTENT(IN,   integer)  LHW, LZW, IHTGT, IZTGT
c
      _INTENT(OUT,  _REALSTD) WWZ  (LZW, *)
      _INTENT(OUT,  _REALSTD) WMTW (LHW, LZW, *)
      _INTENT(OUT,  _REALSTD) WMTI (LHW, LZW, *)
c
      _INTENT(IN,   _REALSTD) VMTW (LH, LZ, *)
      _INTENT(IN,   _REALSTD) VMTI (LH, LZ, *)
c
      _INTENT(IN,   _REALSTD) DT
      _INTENT(IN,   _REALSTD) WZV  (LZ, *)
c
      _INTENT(IN,   integer)   IFPl
      _INTENT(IN,   integer)   ITSTP
      _INTENT(IN,   character) CTAG*(*)
      _INTENT(IN,   integer)   IR, NR
c
      _INTENT(IN,   integer)  KQU,  KQB
      _INTENT(IN,   integer)  KZDD, KZD
      _INTENT(IN,   integer)  KE33, KE3p
      _INTENT(IN,   integer)  KE1,  KE2, KTX, KTY, KHS, KIT
c
      integer   jh
      integer   jzz, jz
      integer   nzw, kz0w
      _REALSTD E0DT
CCC_  - Body
      iErr = 0
      call MTSbld_min_copy
     $     (WMTW, LHW, LZW, KE33,  VMTW, LH, LZ, VMTW_E33, IHTGT, IZTGT)
      call MTSbld_min_copy
     $     (WMTW, LHW, LZW, KE3p,  VMTW, LH, LZ, VMTW_E3p, IHTGT, IZTGT)
      call MTSbld_min_copy
     $     (WMTW, LHW, LZW, KE1,   VMTW, LH, LZ, VMTW_E1,  IHTGT, IZTGT)
      call MTSbld_min_copy
     $     (WMTW, LHW, LZW, KE2,   VMTW, LH, LZ, VMTW_E2,  IHTGT, IZTGT)
      call MTSbld_min_copy
     $     (WMTW, LHW, LZW, KTX, VMTW, LH, LZ, VMTW_dTdXa, IHTGT, IZTGT)
      call MTSbld_min_copy
     $     (WMTW, LHW, LZW, KTY, VMTW, LH, LZ, VMTW_dTdYa, IHTGT, IZTGT)
      call MTSbld_min_copy
     $     (WMTW, LHW, LZW, KHS, VMTW, LH, LZ, VMTW_HS,    IHTGT, IZTGT)
c
      call MTSbld_min_copy
     $     (WMTI, LHW, LZW, KIT, VMTI, LH, LZ, VMTI_T,     IHTGT, IZTGT)
c
      call MTSbld_min_copy
     $     (WWZ,  1,   LZW, KZDD, WZV, 1, LZ, VMVZ_ddWPa,  1, IZTGT)
      call MTSbld_min_copy
     $     (WWZ,  1,   LZW, KZD,  WZV, 1, LZ, VMVZ_dWPb,   1, IZTGT)
c
      if (iErr.eq.0) then
         kz0w = 1
         nzw  = LZW
         call MTSbld_min
     O       (iErr,
     M        WMTW,
     I        WMTI,
     I        WWZ,  DT,
     I        NHt,  LHW,  NZW,  LZW, KZ0w,
     I        KQU,  KQB,  KZDD, KZD,
     I        KE33, KE3p, KE1,  KE2, KTX, KTY, KHS, KIT,
     I        IFPl, 0)
      endif
 302  format (A, I3, 1x, I6, 1x, I3, I5, 1x, 4E26.18)
      E0DT = -1.0d0 / DT
      do jh = 1,  NHt
         do jz = 1, LZW
            write (IFPl,302) CTAG, IR,
     $           ITSTP, jz,jh,
     $           WMTW (jh,jz,KQB),
     $           E0DT * WMTI (jh, jz, KIT)
     $           -(WMTW (jh, jz, KE1)*WMTW (jh, jz, KTX)
     $            +WMTW (jh, jz, KE2)*WMTW (jh, jz, KTY))
     $           -WMTW (jh, jz, KHS)
         enddo
      enddo
      RETURN
      END
CCC_ & MTSbld_min_copy
      subroutine MTSbld_min_copy
     $     (Z, LHZ, LZZ, KZ,  X, LHX, LZX, KX, IHTGT, IZTGT)
      implicit none
      _INTENT(IN,integer) LHZ, LZZ, KZ
      _INTENT(IN,integer) LHX, LZX, KX
      _INTENT(IN,integer) IHTGT, IZTGT
      _INTENT(OUT,_REALSTD)  Z (LHZ, LZZ, *)
      _INTENT(IN, _REALSTD)  X (LHX, LZX, *)
      integer jz, jx
      do jz = 1, LZZ
         do jx = 1, LHZ
            Z (jx, jz, KZ) = X (IHTGT, IZTGT, KX)
c$$$            write (*, *) jx,jz,KZ,KX,X (IHTGT, IZTGT, KX)
         enddo
      enddo
 101  format ('TGT: ', I3, 1x, E26.18)
      write (*, 101) KX, X (IHTGT, IZTGT, KX)
      RETURN
      END
CCC_ & MTTdbg_mtsbld  ## MTSbld wrapper
      subroutine MTTdbg_mtsbld
     O    (iErr,
     M     VMTW,
     I     VMTI, VMHW, VMHI, VMHB,
     I     KTB,  WZV,  PMM,  IMM, DT,
     I     NHt,  LH,   NZ,   LZ,  KZ0,
     I     IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  NHt, LH
      _INTENT(IN,   integer)  NZ,  LZ, KZ0
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
      integer    LTPref
      parameter (LTPref = OPT_MOVEMENT_LVP_MAX)
      integer    LHPref
      parameter (LHPref = OPT_MOVEMENT_LHP_MAX)
      _REALSTD   WMTW (LTPref * VMTW_MAX)
      _REALSTD   WMTI (LTPref * VMTI_MAX)
      _REALSTD   WMHW (LHPref * VMHW_MAX)
      _REALSTD   WMHI (LHPref * VMHI_MAX)
      _REALSTD   WMHB (LHPref * VMHB_MAX)
      _REALSTD   WWZ  (LHPref * VMVZ_MAX)
#if TEST_MDRVRM == 0
c$$$      save       WMTW, WMTI, WMHW, WMHI, WMHB
#endif
c
      integer    JTBL (LHPref * 2)
      save       JTBL
      integer    NHtmp
c
      integer  ITSTP
      data     ITSTP / 0 /
      save     ITSTP
      integer  jh, jht, kfw
c
      integer  IR, NR, ICOMM
      integer  jerr
      integer  jv, jvy, jvw
c
      integer  LHtmp, NZtmp, LZtmp
      integer  IHTGT, IZTGT
      integer  ifnum
c
      character TAG*(16)
      integer   jl, jn, jz
c
      integer  KQU,  KQB
      integer  KZDD, KZD
      integer  KE33, KE3p
      integer  KE1,  KE2, KTX, KTY, KHS, KIT
c
#if    TEST_DBG_MTTCOL
#  define TARGET_STEP     -1
#  define TARGET_STEP_END 999999999
#  define TARGET_JZ   6
#else
#  define TARGET_STEP     24817
#  define TARGET_STEP_END 24823
#  define TARGET_JZ   0
#endif
#define TARGET_IR   15
#define TARGET_JH   402
CCC_  - Body
 302  format (I6, 1x, I3, I5, 1x, 9E26.18)
      if (ITSTP.ge. TARGET_STEP
     $     .and. ITSTP.le. TARGET_STEP_END) then
         call DMZqcn (jErr, ICOMM, 'COMM_WORLD')
         call DMWrnk (IR,   NR,    IComm)
CCC_   . W (original)
         call MTTdbg_mtsbld_core
     O       (iErr,
     M        VMTW,
     I        VMTI, VMHW, VMHI, VMHB,
     I        KTB,  WZV,  PMM,  IMM, DT,
     I        NHt,  LH,   NZ,   LZ,  KZ0,
     I        IFPl,
     I        ITSTP, 'W', IR,   NR)
CCC_   . binary output
         if (IR.eq. TARGET_IR) then
            ifnum = ITSTP - (TARGET_STEP)
            call MTTdbg_write  (VMTW,LH,LZ, VMTW_MAX, ifnum, 'TW', ifpl)
            call MTTdbg_write  (VMTI,LH,LZ, VMTI_MAX, ifnum, 'TI', ifpl)
            call MTTdbg_write  (VMHW,LH,1,  VMHW_MAX, ifnum, 'HW', ifpl)
            call MTTdbg_write  (VMHI,LH,1,  VMHI_MAX, ifnum, 'HI', ifpl)
            call MTTdbg_write  (VMHB,LH,1,  VMHB_MAX, ifnum, 'HB', ifpl)
            call MTTdbg_write  (WZV, 1, LZ, VMVZ_MAX, ifnum, 'Z',  ifpl)
            call MTTdbg_write  (PMM, 1, 1,  PMM_MAX,  ifnum, 'P',  ifpl)
            call MTTdbg_writeI (KTB, LH,2,  1,        ifnum, 'KT', ifpl)
            write (ifpl, *) 'MTTDBG:0:', ifnum, NHt, LH, NZ, LZ, KZ0
            write (ifpl, *) 'MTTDBG:1:', ifnum, DT
            write (ifpl, *) 'MTTDBG:2:', ifnum, IR, NR
         endif
#if 0
CCC_   . X (target grid only)
         if (TARGET_JH .gt. 0) then
            NHtmp    = 1
            JTBL (1) = TARGET_JH
            call MTTdbg_mtsbld_core
     O          (iErr,
     M           VMTW,
     I           VMTI,  VMHW, VMHI, VMHB,
     I           JTBL,  WZV,  PMM,  IMM, DT,
     I           NHtmp, LH,   NZ,   LZ,  KZ0,
     I           IFPl,
     I           ITSTP, 'X', IR,   NR)
         endif
CCC_   . Z (until target grid)
         if (TARGET_JH .gt. 0) then
            NHtmp = 0
            kfw=1
            do jht = 1,  NHt
               jh = KTB (jht, kfw)
               if (jh .eq. TARGET_JH) then
                  NHtmp = jht
                  goto 100
               endif
            enddo
 100        continue
            call MTTdbg_mtsbld_core
     O          (iErr,
     M           VMTW,
     I           VMTI,  VMHW, VMHI, VMHB,
     I           KTB,   WZV,  PMM,  IMM, DT,
     I           NHtmp, LH,   NZ,   LZ,  KZ0,
     I           IFPl,
     I           ITSTP, 'Z', IR,   NR)
         endif
CCC_   . Y (copy everything)
         LHtmp = LH
         IHTGT = 0
         call MTTdbg_copy
     $        (WMTW, VMTW, LHtmp, LH, NZ, LZ, KZ0, VMTW_MAX, IHTGT)
         call MTTdbg_copy
     $        (WMTI, VMTI, LHtmp, LH, NZ, LZ, KZ0, VMTI_MAX, IHTGT)
         call MTTdbg_copy
     $        (WMHW, VMHW, LHtmp, LH, 1,  1,  1,   VMHW_MAX, IHTGT)
         call MTTdbg_copy
     $        (WMHI, VMHI, LHtmp, LH, 1,  1,  1,   VMHI_MAX, IHTGT)
         call MTTdbg_copy
     $        (WMHB, VMHB, LHtmp, LH, 1,  1,  1,   VMHB_MAX, IHTGT)
         call MTTdbg_mtsbld_core
     O       (iErr,
     M        WMTW,
     I        WMTI, WMHW,  WMHI, WMHB,
     I        KTB,  WZV,   PMM,  IMM, DT,
     I        NHt,  LHtmp, NZ,   LZ,  KZ0,
     I        IFPl,
     I        ITSTP, 'Y', IR,   NR)
CCC_   . U (copy everything, target only)
         LHtmp = LH
         IHTGT = TARGET_JH
         call MTTdbg_copy
     $        (WMTW, VMTW, LHtmp, LH, NZ, LZ, KZ0, VMTW_MAX, IHTGT)
         call MTTdbg_copy
     $        (WMTI, VMTI, LHtmp, LH, NZ, LZ, KZ0, VMTI_MAX, IHTGT)
         call MTTdbg_copy
     $        (WMHW, VMHW, LHtmp, LH, 1,  1,  1,   VMHW_MAX, IHTGT)
         call MTTdbg_copy
     $        (WMHI, VMHI, LHtmp, LH, 1,  1,  1,   VMHI_MAX, IHTGT)
         call MTTdbg_copy
     $        (WMHB, VMHB, LHtmp, LH, 1,  1,  1,   VMHB_MAX, IHTGT)
         call MTTdbg_mtsbld_core
     O       (iErr,
     M        WMTW,
     I        WMTI, WMHW,  WMHI, WMHB,
     I        KTB,  WZV,   PMM,  IMM, DT,
     I        NHt,  LHtmp, NZ,   LZ,  KZ0,
     I        IFPl,
     I        ITSTP, 'U', IR,   NR)
CCC_   . S (copy everything, target only 3)
         LHtmp = LH
         IHTGT = TARGET_JH
         IZTGT = TARGET_JZ
         call MTTdbg_copy3
     $        (WMTW, VMTW,LHtmp,LH, NZ, LZ, KZ0, VMTW_MAX, IHTGT, IZTGT)
         call MTTdbg_copy3
     $        (WMTI, VMTI,LHtmp,LH, NZ, LZ, KZ0, VMTI_MAX, IHTGT, IZTGT)
         call MTTdbg_copy3
     $        (WMHW, VMHW,LHtmp,LH, 1,  1,  1,   VMHW_MAX, IHTGT, IZTGT)
         call MTTdbg_copy3
     $        (WMHI, VMHI,LHtmp,LH, 1,  1,  1,   VMHI_MAX, IHTGT, IZTGT)
         call MTTdbg_copy3
     $        (WMHB, VMHB,LHtmp,LH, 1,  1,  1,   VMHB_MAX, IHTGT, IZTGT)
         call MTTdbg_mtsbld_core
     O       (iErr,
     M        WMTW,
     I        WMTI, WMHW,  WMHI, WMHB,
     I        KTB,  WZV,   PMM,  IMM, DT,
     I        NHt,  LHtmp, NZ,   LZ,  KZ0,
     I        IFPl,
     I        ITSTP, 'S', IR,   NR)
CCC_   . V (copy everything, different LH)
         LHtmp = LH + 1
         IHTGT = 0
         call MTTdbg_copy
     $        (WMTW, VMTW, LHtmp, LH, NZ, LZ, KZ0, VMTW_MAX, IHTGT)
         call MTTdbg_copy
     $        (WMTI, VMTI, LHtmp, LH, NZ, LZ, KZ0, VMTI_MAX, IHTGT)
         call MTTdbg_copy
     $        (WMHW, VMHW, LHtmp, LH, 1,  1,  1,   VMHW_MAX, IHTGT)
         call MTTdbg_copy
     $        (WMHI, VMHI, LHtmp, LH, 1,  1,  1,   VMHI_MAX, IHTGT)
         call MTTdbg_copy
     $        (WMHB, VMHB, LHtmp, LH, 1,  1,  1,   VMHB_MAX, IHTGT)
         call MTTdbg_mtsbld_core
     O       (iErr,
     M        WMTW,
     I        WMTI, WMHW,  WMHI, WMHB,
     I        KTB,  WZV,   PMM,  IMM, DT,
     I        NHt,  LHtmp, NZ,   LZ,  KZ0,
     I        IFPl,
     I        ITSTP, 'V', IR,   NR)
CCC_   . T (copy everything, target only, different LH)
         LHtmp = LH + 1
         IHTGT = TARGET_JH
         call MTTdbg_copy
     $        (WMTW, VMTW, LHtmp, LH, NZ, LZ, KZ0, VMTW_MAX, IHTGT)
         call MTTdbg_copy
     $        (WMTI, VMTI, LHtmp, LH, NZ, LZ, KZ0, VMTI_MAX, IHTGT)
         call MTTdbg_copy
     $        (WMHW, VMHW, LHtmp, LH, 1,  1,  1,   VMHW_MAX, IHTGT)
         call MTTdbg_copy
     $        (WMHI, VMHI, LHtmp, LH, 1,  1,  1,   VMHI_MAX, IHTGT)
         call MTTdbg_copy
     $        (WMHB, VMHB, LHtmp, LH, 1,  1,  1,   VMHB_MAX, IHTGT)
         call MTTdbg_mtsbld_core
     O       (iErr,
     M        WMTW,
     I        WMTI, WMHW,  WMHI, WMHB,
     I        KTB,  WZV,   PMM,  IMM, DT,
     I        NHt,  LHtmp, NZ,   LZ,  KZ0,
     I        IFPl,
     I        ITSTP, 'T1', IR,   NR)
CCC_   . T2 (copy everything, target only, different LH)
         LHtmp = LH + 2
         IHTGT = TARGET_JH
         call MTTdbg_copy
     $        (WMTW, VMTW, LHtmp, LH, NZ, LZ, KZ0, VMTW_MAX, IHTGT)
         call MTTdbg_copy
     $        (WMTI, VMTI, LHtmp, LH, NZ, LZ, KZ0, VMTI_MAX, IHTGT)
         call MTTdbg_copy
     $        (WMHW, VMHW, LHtmp, LH, 1,  1,  1,   VMHW_MAX, IHTGT)
         call MTTdbg_copy
     $        (WMHI, VMHI, LHtmp, LH, 1,  1,  1,   VMHI_MAX, IHTGT)
         call MTTdbg_copy
     $        (WMHB, VMHB, LHtmp, LH, 1,  1,  1,   VMHB_MAX, IHTGT)
         call MTTdbg_mtsbld_core
     O       (iErr,
     M        WMTW,
     I        WMTI, WMHW,  WMHI, WMHB,
     I        KTB,  WZV,   PMM,  IMM, DT,
     I        NHt,  LHtmp, NZ,   LZ,  KZ0,
     I        IFPl,
     I        ITSTP, 'T2', IR,   NR)
CCC_   . P1 (copy everything, target only, different LH)
         LHtmp = LH - 1
         IHTGT = TARGET_JH
         call MTTdbg_copy
     $        (WMTW, VMTW, LHtmp, LH, NZ, LZ, KZ0, VMTW_MAX, IHTGT)
         call MTTdbg_copy
     $        (WMTI, VMTI, LHtmp, LH, NZ, LZ, KZ0, VMTI_MAX, IHTGT)
         call MTTdbg_copy
     $        (WMHW, VMHW, LHtmp, LH, 1,  1,  1,   VMHW_MAX, IHTGT)
         call MTTdbg_copy
     $        (WMHI, VMHI, LHtmp, LH, 1,  1,  1,   VMHI_MAX, IHTGT)
         call MTTdbg_copy
     $        (WMHB, VMHB, LHtmp, LH, 1,  1,  1,   VMHB_MAX, IHTGT)
         call MTTdbg_mtsbld_core
     O       (iErr,
     M        WMTW,
     I        WMTI, WMHW,  WMHI, WMHB,
     I        KTB,  WZV,   PMM,  IMM, DT,
     I        NHt,  LHtmp, NZ,   LZ,  KZ0,
     I        IFPl,
     I        ITSTP, 'P1', IR,   NR)
CCC_   . P2 (copy everything, target only, different LH)
         LHtmp = LH - 2
         IHTGT = TARGET_JH
         call MTTdbg_copy
     $        (WMTW, VMTW, LHtmp, LH, NZ, LZ, KZ0, VMTW_MAX, IHTGT)
         call MTTdbg_copy
     $        (WMTI, VMTI, LHtmp, LH, NZ, LZ, KZ0, VMTI_MAX, IHTGT)
         call MTTdbg_copy
     $        (WMHW, VMHW, LHtmp, LH, 1,  1,  1,   VMHW_MAX, IHTGT)
         call MTTdbg_copy
     $        (WMHI, VMHI, LHtmp, LH, 1,  1,  1,   VMHI_MAX, IHTGT)
         call MTTdbg_copy
     $        (WMHB, VMHB, LHtmp, LH, 1,  1,  1,   VMHB_MAX, IHTGT)
         call MTTdbg_mtsbld_core
     O       (iErr,
     M        WMTW,
     I        WMTI, WMHW,  WMHI, WMHB,
     I        KTB,  WZV,   PMM,  IMM, DT,
     I        NHt,  LHtmp, NZ,   LZ,  KZ0,
     I        IFPl,
     I        ITSTP, 'P2', IR,   NR)
CCC_   . M (copy everything, target only, different TBL)
         NHtmp = NHt
         IHTGT = TARGET_JH
         do jh = 1, NHtmp
            JTBL (jh) = jh
         enddo
c$$$         do jl = LH, NHtmp, -10
         do jl = 321, NHtmp, -1
            write (Tag, '(''M'',I3.3)') jl
            LHtmp = jl
            call MTTdbg_copy
     $           (WMTW, VMTW, LHtmp, LH, NZ, LZ, KZ0, VMTW_MAX, IHTGT)
            call MTTdbg_copy
     $           (WMTI, VMTI, LHtmp, LH, NZ, LZ, KZ0, VMTI_MAX, IHTGT)
            call MTTdbg_copy
     $           (WMHW, VMHW, LHtmp, LH, 1,  1,  1,   VMHW_MAX, IHTGT)
            call MTTdbg_copy
     $           (WMHI, VMHI, LHtmp, LH, 1,  1,  1,   VMHI_MAX, IHTGT)
            call MTTdbg_copy
     $           (WMHB, VMHB, LHtmp, LH, 1,  1,  1,   VMHB_MAX, IHTGT)
            call MTTdbg_mtsbld_core
     O          (iErr,
     M           WMTW,
     I           WMTI,  WMHW,  WMHI, WMHB,
     I           JTBL,  WZV,   PMM,  IMM, DT,
     I           NHtmp, LHtmp, NZ,   LZ,  KZ0,
     I           IFPl,
     I           ITSTP, Tag, IR,   NR)
         enddo
CCC_   . N* (copy everything, target only, different LH/NH)
c$$$         do jl = 1, LH, (LH / 32) * 2
c$$$         do jl = LH - 32, LH, 2
         do jl = 0, -1
            LHtmp = jl
            NHtmp = jl
            IHTGT = TARGET_JH
            write (Tag, '(''N'',I3.3)') jl
            do jh = 1, NHtmp
               JTBL (jh) = jh
            enddo
            call MTTdbg_copy
     $           (WMTW, VMTW, LHtmp, LH, NZ, LZ, KZ0, VMTW_MAX, IHTGT)
            call MTTdbg_copy
     $           (WMTI, VMTI, LHtmp, LH, NZ, LZ, KZ0, VMTI_MAX, IHTGT)
            call MTTdbg_copy
     $           (WMHW, VMHW, LHtmp, LH, 1,  1,  1,   VMHW_MAX, IHTGT)
            call MTTdbg_copy
     $           (WMHI, VMHI, LHtmp, LH, 1,  1,  1,   VMHI_MAX, IHTGT)
            call MTTdbg_copy
     $           (WMHB, VMHB, LHtmp, LH, 1,  1,  1,   VMHB_MAX, IHTGT)
            call MTTdbg_mtsbld_core
     O          (iErr,
     M           WMTW,
     I           WMTI,  WMHW,  WMHI, WMHB,
     I           JTBL,  WZV,   PMM,  IMM, DT,
     I           NHtmp, LHtmp, NZ,   LZ,  KZ0,
     I           IFPl,
     I           ITSTP, Tag, IR,   NR)
         enddo
CCC_   . R (copy everything, target only, different NH)
         NHtmp = NHt - 1
         LHtmp = LH
         IHTGT = TARGET_JH
         call MTTdbg_copy
     $        (WMTW, VMTW, LHtmp, LH, NZ, LZ, KZ0, VMTW_MAX, IHTGT)
         call MTTdbg_copy
     $        (WMTI, VMTI, LHtmp, LH, NZ, LZ, KZ0, VMTI_MAX, IHTGT)
         call MTTdbg_copy
     $        (WMHW, VMHW, LHtmp, LH, 1,  1,  1,   VMHW_MAX, IHTGT)
         call MTTdbg_copy
     $        (WMHI, VMHI, LHtmp, LH, 1,  1,  1,   VMHI_MAX, IHTGT)
         call MTTdbg_copy
     $        (WMHB, VMHB, LHtmp, LH, 1,  1,  1,   VMHB_MAX, IHTGT)
         call MTTdbg_mtsbld_core
     O       (iErr,
     M        WMTW,
     I        WMTI,  WMHW,  WMHI, WMHB,
     I        KTB,   WZV,   PMM,  IMM, DT,
     I        NHtmp, LHtmp, NZ,   LZ,  KZ0,
     I        IFPl,
     I        ITSTP, 'R', IR,   NR)
CCC_   . Q (copy everything, target only, different NH b)
         NHtmp = NHt - 2
         LHtmp = LH
         IHTGT = TARGET_JH
         call MTTdbg_copy
     $        (WMTW, VMTW, LHtmp, LH, NZ, LZ, KZ0, VMTW_MAX, IHTGT)
         call MTTdbg_copy
     $        (WMTI, VMTI, LHtmp, LH, NZ, LZ, KZ0, VMTI_MAX, IHTGT)
         call MTTdbg_copy
     $        (WMHW, VMHW, LHtmp, LH, 1,  1,  1,   VMHW_MAX, IHTGT)
         call MTTdbg_copy
     $        (WMHI, VMHI, LHtmp, LH, 1,  1,  1,   VMHI_MAX, IHTGT)
         call MTTdbg_copy
     $        (WMHB, VMHB, LHtmp, LH, 1,  1,  1,   VMHB_MAX, IHTGT)
         call MTTdbg_mtsbld_core
     O       (iErr,
     M        WMTW,
     I        WMTI,  WMHW,  WMHI, WMHB,
     I        KTB,   WZV,   PMM,  IMM, DT,
     I        NHtmp, LHtmp, NZ,   LZ,  KZ0,
     I        IFPl,
     I        ITSTP, 'Q', IR,   NR)
CCC_   . L (copy everything, target only, different TBL)
         IHTGT = TARGET_JH
         do jh = 1, LH
            JTBL (jh) = jh
         enddo
c$$$         do jl = LH, NHtmp, -10
         do jl = 3, 21
            do jn = 1, jl
               write (Tag, '(''L'',I2.2,I2.2)') jl,jn
            LHtmp = jl
            NHtmp = jn
            call MTTdbg_copy
     $           (WMTW, VMTW, LHtmp, LH, NZ, LZ, KZ0, VMTW_MAX, IHTGT)
            call MTTdbg_copy
     $           (WMTI, VMTI, LHtmp, LH, NZ, LZ, KZ0, VMTI_MAX, IHTGT)
            call MTTdbg_copy
     $           (WMHW, VMHW, LHtmp, LH, 1,  1,  1,   VMHW_MAX, IHTGT)
            call MTTdbg_copy
     $           (WMHI, VMHI, LHtmp, LH, 1,  1,  1,   VMHI_MAX, IHTGT)
            call MTTdbg_copy
     $           (WMHB, VMHB, LHtmp, LH, 1,  1,  1,   VMHB_MAX, IHTGT)
            call MTTdbg_mtsbld_core
     O          (iErr,
     M           WMTW,
     I           WMTI,  WMHW,  WMHI, WMHB,
     I           JTBL,  WZV,   PMM,  IMM, DT,
     I           NHtmp, LHtmp, NZ,   LZ,  KZ0,
     I           IFPl,
     I           ITSTP, Tag, IR,   NR)
         enddo
         enddo
CCC_   . K
         IHTGT = TARGET_JH
         do jh = 1, LH
            JTBL (jh) = jh
         enddo
c$$$         do jl = LH, NHtmp, -10
         do jl = 5, 5
         do jn = 1, jl
         do jz = 4, NZ
            write (Tag, '(''K'',I2.2,I2.2)') jn,jz
            LHtmp = jl
            NHtmp = jn
            NZtmp = jz
            call MTTdbg_copy
     $           (WMTW, VMTW, LHtmp, LH, NZ, LZ, KZ0, VMTW_MAX, IHTGT)
            call MTTdbg_copy
     $           (WMTI, VMTI, LHtmp, LH, NZ, LZ, KZ0, VMTI_MAX, IHTGT)
            call MTTdbg_copy
     $           (WMHW, VMHW, LHtmp, LH, 1,  1,  1,   VMHW_MAX, IHTGT)
            call MTTdbg_copy
     $           (WMHI, VMHI, LHtmp, LH, 1,  1,  1,   VMHI_MAX, IHTGT)
            call MTTdbg_copy
     $           (WMHB, VMHB, LHtmp, LH, 1,  1,  1,   VMHB_MAX, IHTGT)
            call MTTdbg_mtsbld_core
     O          (iErr,
     M           WMTW,
     I           WMTI,  WMHW,  WMHI, WMHB,
     I           JTBL,  WZV,   PMM,  IMM, DT,
     I           NHtmp, LHtmp, NZtmp,LZ,  KZ0,
     I           IFPl,
     I           ITSTP, Tag, IR,   NR)
         enddo
         enddo
         enddo
#endif /* 0 */
CCC_   . JA
         IHTGT = TARGET_JH
         IZTGT = TARGET_JZ
         do jl = 5, 5
         do jn = 1, jl
         do jz = 4, 6
            write (Tag, '(''JA'',I2.2,I2.2,I2.2)') jl,jn,jz
            LHtmp = jl
            NHtmp = jn
            LZtmp = jz
            KQU = VMTW_QU
            KQB = VMTW_QB
            KZDD = VMVZ_ddWPa
            KZD  = VMVZ_dWPb
            KE33 = VMTW_E33
            KE3p = VMTW_E3p
            KE1 = VMTW_E1
            KE2 = VMTW_E2
            KHS = VMTW_HS
            KTX = VMTW_dTdXa
            KTY = VMTW_dTdYa
            KIT = VMTI_T
            call MTTdbg_min_core
     O          (iErr,
     W           WMTW,  WMTI,  WWZ,
     I           VMTW,  VMTI,
     I           WZV,   DT,
     I           LHtmp, LZtmp, IHTGT, IZTGT,
     I           NHtmp, LH,    NZ,   LZ,  KZ0,
     I           KQU,  KQB,   KZDD, KZD,
     I           KE33, KE3p,  KE1,  KE2, KTX, KTY, KHS, KIT,
     I           IFPl, ITSTP, TAG,  IR,  NR)
         enddo
         enddo
         enddo
CCC_   . JB
         IHTGT = TARGET_JH
         IZTGT = TARGET_JZ
         do jl = 5, 5
         do jn = 1, jl
         do jz = 4, 6
            write (Tag, '(''JB'',I2.2,I2.2,I2.2)') jl,jn,jz
            LHtmp = jl
            NHtmp = jn
            LZtmp = jz
            KQB = VMTW_RFb
c
            KQU = VMTW_QU
            KZDD = VMVZ_ddWPa
            KZD  = VMVZ_dWPb
            KE33 = VMTW_E33
            KE3p = VMTW_E3p
            KE1 = VMTW_E1
            KE2 = VMTW_E2
            KHS = VMTW_HS
            KTX = VMTW_dTdXa
            KTY = VMTW_dTdYa
            KIT = VMTI_T
            call MTTdbg_min_core
     O          (iErr,
     W           WMTW,  WMTI,  WWZ,
     I           VMTW,  VMTI,
     I           WZV,   DT,
     I           LHtmp, LZtmp, IHTGT, IZTGT,
     I           NHtmp, LH,    NZ,   LZ,  KZ0,
     I           KQU,  KQB,   KZDD, KZD,
     I           KE33, KE3p,  KE1,  KE2, KTX, KTY, KHS, KIT,
     I           IFPl, ITSTP, TAG,  IR,  NR)
         enddo
         enddo
         enddo
      endif
CCC_   . return
      ITSTP = ITSTP + 1
      RETURN
      END
CCC_ & MTTdbg_write
      subroutine MTTdbg_write
     $     (X, LH, LZ, NV, ifnum, SFX, ifpl)
      implicit none
      _INTENT(IN, integer)   LH, LZ, NV
      _INTENT(IN, integer)   ifnum
      _INTENT(IN, _REALSTD)  X (LH, LZ, NV)
      _INTENT(IN, character) SFX*(*)
      _INTENT(IN, integer)   ifpl
      integer  ipv
      character FNM*(1024)
      integer  jerr
      integer  LV, LU
      integer  irec
CCC_  - Body
      call UUlenU (jErr, LU, ' ', -1, -1)
      FNM = 'MTTdbg'
      call UFcat2 (FNM, '_', SFX)
      LV = (LH * LZ * NV) * (8 / LU)
      irec = ifnum + 1
      ipv  = -1
      call UUMCnu (jerr, ipv)
      if (jerr.eq.0) call UUopOC (jerr, ipv, FNM, LV, 'U', 'W', ' ')
      if (jerr.eq.0) write (ipv, IOSTAT = jerr, REC = irec) X
      if (jerr.eq.0) call UUclsC (jerr, ipv, FNM, ' ')
 101  format ('DEBUG:', A, ':', 5I3)
      write (ifpl, 101) _TRIM(FNM), ipv, irec, jerr
      RETURN
      END
CCC_ & MTTdbg_writeI
      subroutine MTTdbg_writeI
     $     (IX, LH, LZ, NV, ifnum, SFX, ifpl)
      implicit none
      _INTENT(IN, integer)   LH, LZ, NV
      _INTENT(IN, integer)   ifnum
      _INTENT(IN, integer)   IX (LH, LZ, NV)
      _INTENT(IN, character) SFX*(*)
      _INTENT(IN, integer)   ifpl
      integer  ipv
      character FNM*(1024)
      integer  jerr
      integer  LV, LU
      integer  irec
CCC_  - Body
      call UUlenU (jErr, LU, ' ', -1, -1)
      FNM = 'MTTdbg'
      call UFcat2 (FNM, '_', SFX)
      LV = (LH * LZ * NV) * (4 / LU)
      irec = ifnum + 1
      ipv  = -1
      call UUMCnu (jerr, ipv)
      if (jerr.eq.0) call UUopOC (jerr, ipv, FNM, LV, 'U', 'W', ' ')
      if (jerr.eq.0) write (ipv, IOSTAT = jerr, REC = irec) IX
      if (jerr.eq.0) call UUclsC (jerr, ipv, FNM, ' ')
 101  format ('DEBUG:', A, ':', 5I3)
      write (ifpl, 101) _TRIM(FNM), ipv, irec, jerr
      RETURN
      END
CCC_ & MTTdbg_read
      subroutine MTTdbg_read
     $     (X, LH, LZ, NV, ifnum, PFX, SFX, ifpl)
      implicit none
      _INTENT(IN, integer)   LH, LZ, NV
      _INTENT(IN, integer)   ifnum
      _INTENT(OUT,_REALSTD)  X (LH, LZ, NV)
      _INTENT(IN, character) PFX*(*), SFX*(*)
      _INTENT(IN, integer)   ifpl
      integer  ipv
      character FNM*(1024)
      integer  jerr
      integer  LV, LU
      integer  irec
CCC_  - Body
      call UUlenU (jErr, LU, ' ', -1, -1)
      FNM = PFX
      call UFcat2 (FNM, '_', SFX)
      LV = (LH * LZ * NV) * (8 / LU)
      irec = ifnum + 1
      ipv  = -1
      call UUMCnu (jerr, ipv)
      if (jerr.eq.0) call UUopOC (jerr, ipv, FNM, LV, 'U', 'R', ' ')
      if (jerr.eq.0) read (ipv, IOSTAT = jerr, REC = irec) X
      if (jerr.eq.0) call UUclsC (jerr, ipv, FNM, ' ')
 101  format ('DEBUG:', A, ':', 5I3)
      write (ifpl, 101) _TRIM(FNM), ipv, irec, jerr
      RETURN
      END
CCC_ & MTTdbg_readI
      subroutine MTTdbg_readI
     $     (IX, LH, LZ, NV, ifnum, PFX, SFX, ifpl)
      implicit none
      _INTENT(IN, integer)   LH, LZ, NV
      _INTENT(IN, integer)   ifnum
      _INTENT(OUT,integer)   IX (LH, LZ, NV)
      _INTENT(IN, character) PFX*(*), SFX*(*)
      _INTENT(IN, integer)   ifpl
      integer  ipv
      character FNM*(1024)
      integer  jerr
      integer  LV, LU
      integer  irec
CCC_  - Body
      call UUlenU (jErr, LU, ' ', -1, -1)
      FNM = PFX
      call UFcat2 (FNM, '_', SFX)
      LV = (LH * LZ * NV) * (4 / LU)
      irec = ifnum + 1
      ipv  = -1
      call UUMCnu (jerr, ipv)
      if (jerr.eq.0) call UUopOC (jerr, ipv, FNM, LV, 'U', 'R', ' ')
      if (jerr.eq.0) read (ipv, IOSTAT = jerr, REC = irec) IX
      if (jerr.eq.0) call UUclsC (jerr, ipv, FNM, ' ')
 101  format ('DEBUG:', A, ':', 5I3)
      write (ifpl, 101) _TRIM(FNM), ipv, irec, jerr
      RETURN
      END
CCC_ & MTTdbg_copy
      subroutine MTTdbg_copy
     $     (Z, X, LHZ, LHX, NZ, LZ, KZ0, NV, IHTGT)
      implicit none
      _INTENT(IN, integer)  LHZ, LHX
      _INTENT(IN, integer)  NZ, LZ, KZ0, NV
      _INTENT(IN, integer)  IHTGT
      _INTENT(OUT,_REALSTD) Z (LHZ, LZ, *)
      _INTENT(IN, _REALSTD) X (LHX, LZ, *)
      integer jv, jvz, jvx
      integer jz
      integer jht, jh
c$$$      integer kfw
c$$$      kfw = 1
c$$$      do jv = 1, NV
c$$$         jvz = jv
c$$$         jvx = jv
c$$$         call UV1cpc (Z, X, LH, LH, NZ, LZ, KZ0, jvz, jvx)
c$$$      enddo
      do       jv = 1, NV
         do    jz = 1, LZ
            do jh = 1, MIN (LHX, LHZ)
               Z (jh, jz, jv) = X (jh, jz, jv)
c$$$  Z (jh, jz, jv) = X (TARGET_JH, jz, jv)
            enddo
         enddo
      enddo
      if (IHTGT.gt.0) then
         do       jv = 1, NV
            do    jz = 1, LZ
               do jh = 1, MIN (LHX, LHZ)
                  Z (jh, jz, jv) = X (IHTGT, jz, jv)
               enddo
            enddo
         enddo
      endif
      RETURN
      END
CCC_ & MTTdbg_copy3
      subroutine MTTdbg_copy3
     $     (Z, X, LHZ, LHX, NZ, LZ, KZ0, NV, IHTGT, IZTGT)
      implicit none
      _INTENT(IN, integer)  LHZ, LHX
      _INTENT(IN, integer)  NZ, LZ, KZ0, NV
      _INTENT(IN, integer)  IHTGT, IZTGT
      _INTENT(OUT,_REALSTD) Z (LHZ, LZ, *)
      _INTENT(IN, _REALSTD) X (LHX, LZ, *)
      integer jv, jvz, jvx
      integer jz
      integer jht, jh
c$$$      integer kfw
c$$$      kfw = 1
c$$$      do jv = 1, NV
c$$$         jvz = jv
c$$$         jvx = jv
c$$$         call UV1cpc (Z, X, LH, LH, NZ, LZ, KZ0, jvz, jvx)
c$$$      enddo
      do       jv = 1, NV
         do    jz = 1, LZ
            do jh = 1, MIN (LHX, LHZ)
               Z (jh, jz, jv) = X (jh, jz, jv)
c$$$  Z (jh, jz, jv) = X (TARGET_JH, jz, jv)
            enddo
         enddo
      enddo
      if (IHTGT.gt.0.and.IZTGT.gt.0) then
         do       jv = 1, NV
            do    jz = 1, LZ
               do jh = 1, MIN (LHX, LHZ)
                  Z (jh, jz, jv) = X (IHTGT, IZTGT, jv)
               enddo
            enddo
         enddo
      endif
      RETURN
      END
CCC_ & MTTdbg_mtsbld_core  ## MTSbld wrapper core
      subroutine MTTdbg_mtsbld_core
     O    (iErr,
     M     VMTW,
     I     VMTI, VMHW,  VMHI, VMHB,
     I     KTB,  WZV,   PMM,  IMM, DT,
     I     NHt,  LH,    NZ,   LZ,  KZ0,
     I     IFPl, ITSTP, CTAG, IR,  NR)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  NHt, LH
      _INTENT(IN,   integer)  NZ,  LZ, KZ0
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
      _INTENT(IN,   integer)   IFPl
      _INTENT(IN,   integer)   ITSTP
      _INTENT(IN,   character) CTAG*(*)
      _INTENT(IN,   integer)   IR, NR
c
      integer   jh,  jht, jhti
      integer   jzz, jz
      integer   kfw, kbw
      _REALSTD E0DT
CCC_  - Body
      iErr = 0
#if TEST_DBG_MTTCOL
      if (iErr.eq.0) then
         call MTSbld_clone2
     O       (iErr,
     M        VMTW,
     I        VMTI, VMHW, VMHI, VMHB,
     I        KTB,  WZV,  PMM,  IMM, DT,
     I        NHt,  LH,   NZ,   LZ,  KZ0,
     I        IFPl, 0)
c$$$         call MTSbld_clone
c$$$     O       (iErr,
c$$$     M        VMTW,
c$$$     I        VMTI, VMHW, VMHI, VMHB,
c$$$     I        KTB,  WZV,  PMM,  IMM, DT,
c$$$     I        NHt,  LH,   NZ,   LZ,  KZ0,
c$$$     I        IFPl, 0)
      endif
#else
      if (iErr.eq.0) then
         call MTSbld
     O       (iErr,
     M        VMTW,
     I        VMTI, VMHW, VMHI, VMHB,
     I        KTB,  WZV,  PMM,  IMM, DT,
     I        NHt,  LH,   NZ,   LZ,  KZ0,
     I        IFPl)
      endif
#endif
 302  format (A, I3, 1x, I6, 1x, I3, 2I5, 1x, 8E26.18)
      E0DT = -1.0d0 / DT
      kfw=1
#if TEST_DBG_MTTCOL
      do jht = 1,  NHt
         jh = KTB (jht, kfw)
         do jz = 1, KZ0 + NZ - 1
            write (IFPl,302) CTAG, IR,
     $           ITSTP, jz,jh,jht,
     $           VMTW (jht,jz,VMTW_QU),
     $           VMTW (jht,jz,VMTW_QL),
     $           VMTW (jht,jz,VMTW_QD),
     $           VMTW (jht,jz,VMTW_QB),
     $           E0DT * VMTI (jh, jz, VMTI_T)
     $           -(VMTW (jh, jz, VMTW_E1)*VMTW (jh, jz, VMTW_dTdXa)
     $            +VMTW (jh, jz, VMTW_E2)*VMTW (jh, jz, VMTW_dTdYa))
     $           -VMTW (jh, jz, VMTW_HS)
         enddo
      enddo
#else
      do jht = 1,  NHt
         jh = KTB (jht, kfw)
         if (jh.eq.8 .or. jh.eq.9
     $        .or. jh.eq. TARGET_JH .or. jh.eq.403) then
            do jz = 1, KZ0 + NZ - 1
               write (IFPl,302) CTAG, IR,
     $              ITSTP, jz,jh,jht,
     $              VMTW (jht,jz,VMTW_QU),
     $              VMTW (jht,jz,VMTW_QL),
     $              VMTW (jht,jz,VMTW_QD),
     $              VMTW (jht,jz,VMTW_QB),
     $              E0DT * VMTI (jh, jz, VMTI_T)
     $              -(VMTW (jh, jz, VMTW_E1)*VMTW (jh, jz, VMTW_dTdXa)
     $               +VMTW (jh, jz, VMTW_E2)*VMTW (jh, jz, VMTW_dTdYa))
     $              -VMTW (jh, jz, VMTW_HS)
            enddo
         endif
      enddo
#endif
      RETURN
      END
CCC_ + end
#endif /* DEBUG_MTTCOL_SPECIAL */
CCC_* Test
CCC_ + begin
#if   TEST_DBG_MTTCOL
      program MTTDBG
      implicit none
      integer jz, jh, nh, nz
      do    jh = 1, 5
         do jz = 4, 6
            nh = jh
            nz = jz
            call MTSbld_div_param (nh, nz)
         enddo
      enddo
      stop
      end
#if 0
CCC_ @ MTTDBG  ## Movement/Thermodynamics test program
#include "ofnstd.h"
#include "odevid.h"  /* MPI table */
      program MTTDBG
CCC_  - Test suites
CC::   SOURCES mttcol.F
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
         call MTTdbgMain (iErr, ipA, iMA)
         call ACCrep (FPL(ipA), 0)
      endif
      call DevFin (iErr)
      STOP
      END
CCC_ & MTTdbgMain   ## main
      subroutine MTTdbgMain (iErr, ipA, iMA)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(IN, integer) ipA (*)
      _INTENT(IN, integer) iMA (*)
c
      integer    LTPref
      parameter (LTPref = OPT_MOVEMENT_LVP_MAX)
      integer    LHPref
      parameter (LHPref = OPT_MOVEMENT_LHP_MAX)
      integer    LZref
      parameter (LZref  = OPT_MOVEMENT_LVZ_MAX)
      _REALSTD   VMTW (LTPref * VMTW_MAX)
      _REALSTD   VMTI (LTPref * VMTI_MAX)
      _REALSTD   VMHW (LHPref * VMHW_MAX)
      _REALSTD   VMHI (LHPref * VMHI_MAX)
      _REALSTD   VMHB (LHPref * VMHB_MAX)
c
      _REALSTD   WZV (LZref * VMVZ_MAX)
      logical    OMM (OMM_MAX)
      integer    IMM (IMM_MAX)
      _REALSTD   PMM (PMM_MAX)
c
      integer    KTB (LHPref * 2)
      save       KTB
c
      integer    ifnum
      integer    NHt, LH
      integer    NZ,  LZ, KZ0
      integer    KTBDZ
      _REALSTD   DT
      character  FPFX*(1024)
      namelist  /NITDBG/
     $     NHt, LH, NZ, LZ, KZ0, DT, FPFX, ifnum, KTBDZ
c
      integer    ipL, ipP, ipC, ipV
CCC_  - Body
      iErr = 0
      ipL  = FPL(ipA)
      ipP  = FPP(ipA)
      ipC  = FPC(ipA)
      ipV  = FPV(ipA)
c
      ifnum = 1
      NHt   = 318
      LH    = 411
      NZ    = 17
      LZ    = 18
      KZ0   = 2
      DT    = 0.125d0
      FPFX  = ' '
      KTBDZ = SW_TBDZ_CENTER
      call UUrwnd (iErr, ipP)
      if (ipP.ge.0) then
         READ  (ipP, NITDBG, IOSTAT = iErr)
      else if (ipP.eq.-1) then
         READ  (*,   NITDBG, IOSTAT = iErr)
      else
         iErr  = 0
      endif
      write (ipL, NITDBG)
      IMM (IMD_TBDZ) = KTBDZ
c
      call MTTdbg_read  (VMTW,LH,LZ, VMTW_MAX, ifnum, FPFX, 'TW', ipl)
      call MTTdbg_read  (VMTI,LH,LZ, VMTI_MAX, ifnum, FPFX, 'TI', ipl)
      call MTTdbg_read  (VMHW,LH,1,  VMHW_MAX, ifnum, FPFX, 'HW', ipl)
      call MTTdbg_read  (VMHI,LH,1,  VMHI_MAX, ifnum, FPFX, 'HI', ipl)
      call MTTdbg_read  (VMHB,LH,1,  VMHB_MAX, ifnum, FPFX, 'HB', ipl)
      call MTTdbg_read  (WZV, 1, LZ, VMVZ_MAX, ifnum, FPFX, 'Z',  ipl)
      call MTTdbg_read  (PMM, 1, 1,  PMM_MAX,  ifnum, FPFX, 'P',  ipl)
      call MTTdbg_readI (KTB, LH,2,  1,        ifnum, FPFX, 'KT', ipl)
c
      call MTTdbg_mtsbld
     O    (iErr,
     M     VMTW,
     I     VMTI, VMHW, VMHI, VMHB,
     I     KTB,  WZV,  PMM,  IMM, DT,
     I     NHt,  LH,   NZ,   LZ,  KZ0,
     I     ipL)
c
      RETURN
      END
#endif
CCC_ + end
#endif  /* TEST_DBG_MTTCOL */
CCC_* obsolete
CCC_ + begin
#if 0 /* obsolete */
CCC_ + end
#endif  /* 0 obsolete */
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
