C arpeggio/afintf.F --- Arpeggio/File interfaces
C Maintainer:  SAITO Fuyuki
C Created: Jan 31 2012
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2020/09/15 11:56:09 fuyuki afintf.F>'
#define _FNAME 'arpeggio/afintf.F'
#define _REV   'Arpeggio 1.0'
CCC_! MANIFESTO
C
C Copyright (C) 2012--2020
C           Japan Agency for Marine-Earth Science and Technology
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
#include "oarpea.h"
#define OARPFI_DETAIL /* use system macros */
#include "oarpfi.h"
#include "odevva.h"
#include "odevel.h"
#include "ounelv.h"
CCC_ + Buffers for grouping
#ifndef   OPT_AFINTF_GRP_MAX
#  define OPT_AFINTF_GRP_MAX  32
#endif
#ifndef   OPT_AFINTF_VAR_MAX
#  define OPT_AFINTF_VAR_MAX  1024
#endif
CCC_ + Attribute cluster
CCC_  - Group/integer
#define VGI_IVS   1  /* start index */
#define VGI_NMV   2  /* number of items (registered) */
#define VGI_NVX   3  /* number of items (to output) */
#define VGI_REC   4  /* serial record */
#define VGI_M     5  /* number of items to write in a variable */
#define VGI_L     6  /* number of items in declaration */
#define VGI_MH    7  /* member in a plane (effective) */
#define VGI_LH    8  /* member in a plane */
#define VGI_MZ    9  /* number of levels (effective) */
#define VGI_LZ    10 /* number of levels */
#define VGI_CMI   11 /* count of meta-info output */
#define VGI_COR   12 /* standard coordinate */
#define VGI_FLG   13 /* obsolete flag */
#define VGI_WFLG  14 /* W flag */
#define VGI_RFLG  15 /* R flag */
#define VGI_WBRD  16 /* W/bridge id */
#define VGI_RBRD  17 /* R/bridge id */
#define VGI_STEP  18 /* sub-step integer */
#define VGI_SUBI  19 /* current record sub-index */
#define VGI_MAX   19
CCC_  - Group/string
#define VGA_GNM 1 /* group name */
#define VGA_CRT 2 /* root */
#define VGA_MAX 2
CCC_  - Group/real-standard
#define VGS_START 1   /* obsolete start */
#define VGS_END   2   /* obsolete end   */
#define VGS_STEP  3   /* obsolete step  */
#define VGS_TREC  4   /* obsolete current record time  */
#define VGS_NEXT  5   /* obsolete next  */

#define VGS_WSTART 1   /* W start */
#define VGS_WEND   2   /* W end   */
#define VGS_WSTEP  3   /* W step  */
#define VGS_WTREC  4   /* W current time  */
#define VGS_WNEXT  5   /* W next  */

#define VGS_RSTART 6  /* R start */
#define VGS_REND   7  /* R end   */
#define VGS_RSTEP  8  /* R step  */
#define VGS_RTREC  9  /* R current time  */
#define VGS_RNEXT  10 /* R next  */

#define VGS_TCUR  11  /* current time */

#define VGS_MAX   11
CCC_  - Variable/integer
#define VVI_COR 1 /* coordinate id */
#define VVI_REC 2 /* record */
#define VVI_IDX 3 /* variable id at execution (padding) */
#define VVI_MAX 3

#define VVI_REC_WAIT -1  /* wait for output meta-info */
#define VVI_REC_SKIP -16 /* not output */
CCC_ + Options
#ifndef    OPT_NAMELIST_OUTPUT_EMULATION
#  define  OPT_NAMELIST_OUTPUT_EMULATION _UNMLEM_LEVEL_END
#endif
CCC_* [AFB] Global buffer manager
CCC_ & AFBmng  ## Group buffer manager
      subroutine AFBmng
     O    (iErr)
CCC_  - Declaration
      implicit none
CCC_   . Arguments
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   idG
      _INTENT(OUT,integer)   idVo
      _INTENT(OUT,integer)   NVo
      _INTENT(IN, integer)   NV
      _INTENT(IN, character) GNM*(*), VNM*(*)
      _INTENT(IN, integer)   icH
      _INTENT(IN, integer)   idGi, idVi
      _INTENT(IN, integer)   idVs, idVe
      _INTENT(IN, character) CSW*(*)
      _INTENT(IN, character) CLS*(*), CRT*(*)
      _INTENT(IN, character) SRC*(*)
      _INTENT(IN, integer)   MH,   LH
      _INTENT(IN, integer)   MZ,   LZ
      _INTENT(IN, integer)   ipFI (*), ipL
      _INTENT(IN, integer)   iMA  (*), IE (*)
      _INTENT(IN, integer)   KX
      _INTENT(IN, integer)   ISUB
      _INTENT(IN, logical)   OFIN
      _INTENT(IN, logical)   OSUBI
      _INTENT(IN, _REALSTD)  V (*)
      _INTENT(OUT,_REALSTD)  VO(*)
      _INTENT(OUT,_REALSTD)  W (*)
      _INTENT(IN, integer)   LW
      _INTENT(IN, _REALSTD)  T
      _INTENT(IN, _REALSTD)  TINI
      _INTENT(IN, _REALSTD)  TEN, DT
      _INTENT(INOUT,_REALSTD)  TNXT
CCC_   . Parameters
      integer    LBVar
      parameter (LBVar = OPT_AFINTF_VAR_MAX)
      integer    LBGrp
      parameter (LBGrp = OPT_AFINTF_GRP_MAX)
c
      integer    LGI
      parameter (LGI = VGI_MAX)
      integer    LGA
      parameter (LGA = VGA_MAX)
      integer    LGS
      parameter (LGS = VGS_MAX)
      integer    LVI
      parameter (LVI = VVI_MAX)
c
      integer    LtblG
      parameter (LtblG = 16)
      integer    LtblV
      parameter (LtblV = 16)
CCC_   . Buffer attributes
      integer    iTblG (LGI, 0:LBGrp)
      character  cTblG (LGA, 0:LBGrp)*(LtblG)
      _REALSTD   sTblG (LGS, 0:LBGrp)
      integer    iTblV (LVI, LBVar)
      character  cTblV (LBVar)*(LtblV)
c
      integer    LallIG, LallCG, LallSG
      parameter (LallIG = LGI * (LBGrp + 1))
      parameter (LallCG = LGA * (LBGrp + 1))
      parameter (LallSG = LGS * (LBGrp + 1))
      integer    LallIV, LallCV
      parameter (LallIV = LVI * LBVar)
      parameter (LallCV = LBVar)
c
      data       iTblG / LallIG * 0 /
      data       cTblG / LallCG * ' ' /
      data       sTblG / LallSG * 0.0d0 /
      data       iTblV / LallIV * 0 /
      data       cTblV / LallCV * ' ' /
      save       iTblG, cTblG, sTblG
      save       iTblV, cTblV
      integer    jGdef
      parameter (jGdef = 0)
c
      integer    kaDVg (VIO_KPOLICY_MAX, LBGrp)
      character  saDVg (LBGrp)*(VIO_SPOLICY_LEN)
      save       kaDVg, saDVg
c
      integer    iBV, nBV
      save       iBV, nBV
      data       iBV, nBV  / 2*0 /
      integer    iBG, nBG
      save       iBG, nBG
      data       iBG, nBG  / 2*0 /
c
      _REALSTD   TST
      integer    jvid
CCC_  - Body
      iErr = 0
      RETURN
CCC_  & AFBdft  ## Default timing
      entry AFBdft
     O    (iErr,
     I     CRT, TINI, TEN, DT, ipFI)
      iErr = 0
      TST  = TINI
      call AFGitm
     O    (iErr,
     M     iTblG,  cTblG, sTblG, nBG, LGI, LGA, LGS,
     I     jgDef,  TINI,  TST,   TEN, DT,  ipFI)
      call AFPstm
     O    (iErr,
     M     iTblG (1,jGdef), cTblG (1,jGdef), sTblG (1,jgDef),
     I     CRT,  ' ',  ipFI)
      RETURN
CCC_  & AFBrgd  ## Group registration (with default timing; no substep)
      entry AFBrgd
     O    (iErr,
     O     idG,
     I     GNM, MH,  LH,  MZ,   LZ,  NV, icH,
     I     CSW, CLS, CRT, ipFI, iMA)
      call AFGreg
     O    (iErr,   idG,
     M     kaDVg,  saDVg,
     M     iTblG,  cTblG,  sTblG, iBG,  nBG,  LBGrp, LGI, LGA, LGS,
     M     iTblV,  cTblV,         iBV,  nBV,  LBVar, LVI,
     I     MH,     LH,     MZ,    LZ,   NV,   GNM,   icH,  .FALSE.,
     I     CSW,    CLS,    CRT,   ipFI, iMA)
c$$$      call DAtrcU (ipFI (AFI_FPL), iErr,  'R', 'AFGBRG')
      RETURN
CCC_  & AFBrgc  ## Group registration (with default timing; with substep choice)
      entry AFBrgc
     O    (iErr,
     O     idG,
     I     GNM, OSUBI, MH,  LH,   MZ,  LZ,  NV,   icH,
     I     CSW, CLS,   CRT, ipFI, iMA)
      call AFGreg
     O    (iErr,   idG,
     M     kaDVg,  saDVg,
     M     iTblG,  cTblG,  sTblG, iBG,  nBG,  LBGrp, LGI, LGA, LGS,
     M     iTblV,  cTblV,         iBV,  nBV,  LBVar, LVI,
     I     MH,     LH,     MZ,    LZ,   NV,   GNM,   icH,  OSUBI,
     I     CSW,    CLS,    CRT,   ipFI, iMA)
      RETURN
CCC_  & AFBqvi  ## Item search
      entry AFBqvi
     O    (iErr,
     O     idVo,
     I     idGi, icH, VNM)
      call AFGqim
     O    (iErr,  idVo,
     I     iTblG,        nBG,  LGI,
     I     iTblV, cTblV,       LVI,
     I     idGi,  icH,   VNM)
      RETURN
CCC_  & AFBqni  ## number of items
      entry AFBqni (iErr, NVo, idGi)
      iErr = 0
      NVo  = iTblG (VGI_NMV, idGi)
      RETURN
CCC_  & AFBrgi  ## Item registration
      entry AFBrgi
     O    (iErr,
     I     idGi, idVi, icH, VNM)
      call AFGrgm
     O    (iErr,
     O     jvid,
     M     iTblG,              nBG,        LGI,
     M     iTblV, cTblV, iBV,  nBV, LBVar, LVI,
     I     idGi,  idVi,  icH,  VNM)
c$$$      call DAtrcU (IFP, iErr, 'R', 'AFGBRI')
      RETURN
CCC_  & AFBgmf  ## Group meta-info with filter
      entry AFBgmf
     O    (iErr,
     I     idGi, GNM, SRC, IE, ipFI)
      call AFGflt
     O    (iErr,
     M     iTblG, cTblG, nBG,  LGI, LGA,
     M     iTblV, cTblV,       LVI,
     I     idGi,  GNM,   ipFI)
      call AFGmiw
     O    (iErr,
     M     kaDVg, saDVg,
     M     iTblG, cTblG, nBG,  LGI, LGA,
     M     iTblV, cTblV,       LVI,
     I     idGi,  GNM,   SRC,  IE)
c$$$      call DAtrcU (IFP, iErr, 'R', 'AFGBMI')
      RETURN
CCC_  & AFBgmi  ## Group meta-info
      entry AFBgmi
     O    (iErr,
     I     idGi, GNM, SRC, IE)
      call AFGmiw
     O    (iErr,
     M     kaDVg, saDVg,
     M     iTblG, cTblG, nBG,  LGI, LGA,
     M     iTblV, cTblV,       LVI,
     I     idGi,  GNM,   SRC,  IE)
c$$$      call DAtrcU (IFP, iErr, 'R', 'AFGBMI')
      RETURN
CCC_  & AFBnxa  ## next time adjustment
      entry AFBnxa
     M    (Tnxt,
     I     T,
     I     idGi)
      call AFGnta
     M    (Tnxt,
     I     T,
     I     iTblG, cTblG, sTblG, nBG, LGI, LGA, LGS,
     I     idGi)
      RETURN
CCC_  & AFBptc  ## output interface (time check)
      entry AFBptc
     O    (iErr,
     I     V,
     I     KX, idGi, idVs, idVe,
     I     T,  SRC,  GNM,  IE)
      call AFGwpt
     O    (iErr,
     M     kaDVg, saDVg,
     M     iTblG, cTblG, sTblG, nBG, LGI, LGA, LGS,
     M     iTblV, cTblV,             LVI,
     I     V,
     I     idGi,  idVs,  idVe,  KX,  T,   GNM, SRC,  IE)
      RETURN
CCC_  & AFBpts  ## output interface (tag replacement; substep)
      entry AFBpts
     O    (iErr,
     I     V,
     I     KX, idGi, idVs, idVe,
     I     T,  ISUB, OFIN, SRC, GNM, IE)
      call AFGwps
     O    (iErr,
     M     kaDVg, saDVg,
     M     iTblG, cTblG, sTblG, nBG, LGI, LGA,  LGS,
     M     iTblV, cTblV,             LVI,
     I     V,
     I     idGi,  idVs,  idVe,  KX,  T,   ISUB, OFIN, GNM, SRC,  IE)
      return
CCC_  & AFBrmp  ## input interface (minimum)
      entry AFBrmp
     O    (iErr,
     O     VO,
     W     W,    LW,
     I     idGi, IE,     ipFI)
      call AFRbrm
     O    (iErr,
     O     VO,
     W     W,     LW,
     M     kaDVg, saDVg,
     M     iTblG, cTblG, sTblG, nBG, LGI, LGA, LGS,
     M     iTblV, cTblV,             LVI,
     I     idGi,  IE,    ipFI)
      RETURN
CCC_  & AFBwmp  ## output interface (minimum)
      entry AFBwmp
     O    (iErr,
     I     V,
     I     idGi, T, IE)
      call AFGbwm
     O    (iErr,
     M     kaDVg, saDVg,
     M     iTblG, cTblG, sTblG, nBG, LGI, LGA, LGS,
     M     iTblV, cTblV,             LVI,
     I     V,
     I     idGi,  T,     IE)
      RETURN
CCC_  & AFBwmt  ## output interface (tag replacement)
      entry AFBwmt
     O    (iErr,
     I     V,
     I     idGi, T, GNM, IE)
      call AFGbwt
     O    (iErr,
     M     kaDVg, saDVg,
     M     iTblG, cTblG, sTblG, nBG, LGI, LGA, LGS,
     M     iTblV, cTblV,             LVI,
     I     V,
     I     idGi,  T,     GNM,   IE)
      RETURN
CCC_  & AFBwmr  ## output interface (tag replacement; range)
      entry AFBwmr
     O    (iErr,
     I     V,
     I     idGi, idVs, idVe, T, GNM, IE)
      call AFGbwr
     O    (iErr,
     M     kaDVg, saDVg,
     M     iTblG, cTblG, sTblG, nBG, LGI, LGA, LGS,
     M     iTblV, cTblV,             LVI,
     I     V,
     I     idGi,  idVs,  idVe,  T,   GNM, IE)
      RETURN
CCC_  & AFBwnc  ## output interface (non-cluster)
      entry AFBwnc
     O    (iErr,
     I     V,
     I     idGi, VNM, icH, T, SRC, GNM, IE)
      call AFGbqn
     O    (iErr,
     M     kaDVg, saDVg,
     M     iTblG, cTblG, sTblG,      nBG,        LGI, LGA, LGS,
     M     iTblV, cTblV,        iBV, nBV, LBVar, LVI,
     I     V,
     I     idGi,  VNM,   icH,   GNM, T,   SRC,   IE)
      RETURN
CCC_  & AFBrpg  ## report
      entry AFBrpg (iErr, ipL)
      call AFGrep
     O    (iErr,
     I     iTblG, cTblG, sTblG, iBG, nBG, LBGrp, LGI, LGA, LGS,
     I     iTblV, cTblV,        iBV, nBV, LBVar, LVI,
     I     ipL)
      RETURN
CCC_  - END
      END
CCC_* [AFR] Cluster configuration interfaces
CCC_ & AFRbrm  ## Batch minimum input interface
      subroutine AFRbrm
     O    (iErr,
     O     V,
     W     W,     LW,
     I     kaDVg, saDVg,
     I     iTblG, cTblG, sTblG, nGrp, LGI, LGA, LGS,
     I     iTblV, cTblV,              LVI,
     I     idG,   IE,    ipFI)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(OUT,  _REALSTD)  V (*)
      _INTENT(OUT,  _REALSTD)  W (*)
      _INTENT(IN,   integer)   LW
c
      _INTENT(IN,   integer)   LGI, LGA, LGS
      _INTENT(IN,   integer)   LVI
c
      _INTENT(IN,   integer)   kaDVg (VIO_KPOLICY_MAX, *)
      _INTENT(IN,   character) saDVg (*)*(VIO_SPOLICY_LEN)
c
      _INTENT(IN,   integer)   nGrp
      _INTENT(IN,   integer)   iTblG (LGI, 0:*)
      _INTENT(IN,   character) cTblG (LGA, 0:*)*(*)
      _INTENT(IN,   _REALSTD)  sTblG (LGS, 0:*)
c
      _INTENT(IN,   integer)   iTblV (LVI, *)
      _INTENT(IN,   character) cTblV (*)*(*)
c
      _INTENT(IN,   integer)   idG
      _INTENT(IN,   integer)   IE (*)
      _INTENT(IN,   integer)   ipFI (*)
      integer KX,  idVs, idVe
      integer MH,  LH,   maxv, lv
      integer MHZ, LHZ
      character GNM*(8)
CCC_  - Body
      iErr = 0
      KX   = 1
      idVs = 0
      idVe = 0
      GNM  = ' '
c
      if (idG.lt.0 .or. idG.gt.nGRP) iErr = -1
      if (iErr.eq.0) then
         maxv = iTblG (VGI_NMV, idG)
         mh   = iTblG (VGI_MH,  idG)
         lh   = iTblG (VGI_LH,  idG)
         mhz  = iTblG (VGI_M,   idG)
         lhz  = iTblG (VGI_L,   idG)
         lv  = maxv
         call AFRcgt
     O       (iErr,
     O        V, mh, lh, mhz, lhz,  maxv, lv, idVs, idVe, KX,
     W        W, LW,
     M        kaDVg (1, idG), saDVg (idG),
     M        iTblG (1, idG), cTblG (1,idG), sTblG (1, idG),
     M        iTblV, cTblV, LVI,
     I        GNM,   IE,    ipFI)
      endif

      RETURN
      END
CCC_ & AFRcgt  ## Cluster variables input core
      subroutine AFRcgt
     O    (iErr,
     O     V,     MH,    LH,    MHZ, LHZ, MAXV, LV, kvs, kve, KX,
     W     W,     LW,
     M     kaDV,  saDV,
     I     iTblG, cTblG, sTblG,
     M     iTblV, cTblV,        LVI,
     I     VGRP,  IE,    ipFI)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
c
      _INTENT(IN,   integer)   KX
      _INTENT(IN,   integer)   MH,    LH,  LV
      _INTENT(IN,   integer)   MHZ,   LHZ
      _INTENT(IN,   integer)   MAXV,  kvs, kve
      _INTENT(OUT,  _REALSTD)  V(LHZ, LV, *)
c
      _INTENT(IN,   integer)   LW
      _INTENT(OUT,  _REALSTD)  W (*)
c
      _INTENT(INOUT,integer)   kaDV (*)
      _INTENT(INOUT,character) saDV*(*)
c
      _INTENT(INOUT,integer)   iTblG (*)
      _INTENT(INOUT,character) cTblG (*)*(*)
      _INTENT(INOUT,_REALSTD)  sTblG (*)
      _INTENT(IN,   integer)   LVI
      _INTENT(INOUT,integer)   iTblV (LVI, *)
      _INTENT(IN,   character) cTblV (*)*(*)

      _INTENT(IN,   character) VGRP*(*)
      _INTENT(IN,   integer)   IE  (*)
      _INTENT(IN,   integer)   ipFI(*)
c
      character FN*(OPT_FILENAME_MAX)
      character FTP*(32)
      integer   LB, IR
      _REALSTD  VAL
      integer   DIMS(32)
      character FMT*(32),  Tgrp*(32), CBASE*(32)
      integer   jpI, jpN, jpL
      integer   jv,  jvv, jvs,   jv0, jv9
      integer   kxi, jvi, jvo
      integer   idC
      integer   LPa (3)
      integer   jcdmy
CCC_  - Body
      iErr = 0
c
      jpI  = ipFI (AFI_FPI)
      jpN  = ipFI (AFI_FPN)
      jpL  = ipFI (AFI_FPL)
c
      jv0 = MAX (1, kvs)
      jv9 = kve
      if (jv9.eq.0) jv9 = MaxV
c
      jvs  = iTblG (VGI_IVS)
c
      call USMcpd (TGRP, VGRP, cTblG (VGA_GNM))
c
      FMT = ' '
CCC_   . member loop
      kxi = KX
      jvo = 0
      if (kxi.eq.0) then
         kxi = 1
         jvo = - jv0 + 1
      endif
      do jvv = jv0, jv9
         jv  = jvv
         jvi = jvv + jvo
 101     format ('AFRcgt: ', A, 1x, A, 1x, I3, 1x, A, 1x, A, 1x, 3I5)
         idC = iTblV (VVI_COR, jvs+jv)
         if (iErr.eq.0) call ACWtag (iErr, CBASE, idC)
         if (iErr.eq.0) then
            call ACCrfI (iErr, jcdmy, LPa, idC, 3, 'EL', jpL)
         endif
         if (iErr.eq.0) then
            write (jpL, 101)
     $           _TRIM(cTblG (VGA_CRT)),
     $           _TRIM(TGRP),
     $           jvv,
     $           _TRIM(cTblV (jvs+jv)),
     $           _TRIM(CBASE),
     $           LPa
         endif
CCC_   . get configuration
         if (iErr.eq.0) then
            call AFRcnm
     O          (iErr,
     O           FN, LB, IR, FTP, VAL, DIMS,
     I           cTblG (VGA_CRT), TGRP, cTblV (jvs+jv), CBASE,
     I           jpI, jpN, jpL)
         endif
CCC_   . read file
         if (iErr.eq.0) then
CCC_    * force skip
            if (FTP.eq.'SKIP') then
               continue
CCC_    * constant
            else if (FTP.eq.'CONST') then
               call UV0sta(V(1, 1, KX), MH, LH, jv, VAL)
CCC_    * ascii/binary
            else
               if (FTP.eq.'*') LB = -1
               call AFRvsa
     $             (iErr,
     $              V(1, jv, KX), MH, LH, MHZ, LHZ, VAL,
     $              W,   LW,
     $              LPa, DIMS,
     $              FN,  LB, IR, IE, jpL)
            endif
         endif
      enddo
c
      call DAtrcU (jpL, iErr, TGRP, 'AFRCGT')
      if (iErr.ne.0) iErr = -1
      RETURN
      END
CCC_ & AFRcnm  ## Configuration by namelist
      subroutine AFRcnm
     O    (iErr,
     O     FN,   LB,   IR,  FTP, VALo, DIMSo,
     I     CRi,  GRi,  VNi, COi,
     I     IFPp, IFPn, IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,character) FN*(*),  FTP*(*)
      _INTENT(OUT,integer)   LB,      IR
      _INTENT(OUT,integer)   DIMSo(*)
      _INTENT(OUT,_REALSTD)  VALo

      _INTENT(IN, character) CRi*(*), GRi*(*)
      _INTENT(IN, character) VNi*(*), COi*(*)
      _INTENT(IN, integer)   IFPn,    IFPp, IFPl
c
      integer    LVEML
      parameter (LVEML = OPT_NAMELIST_OUTPUT_EMULATION)
      character CROOT*(32)
      character GROUP*(32)
      character VAR*(32)
      character COOR*(32)
      character FNM*(OPT_FILENAME_MAX)
      character FMT*(128)
      character TV*(32), TC*(32)
      integer    LD
      parameter (LD = 5)
      integer   DIMS(LD)
      _REALSTD  VAL
      namelist /NIDATA/
     $     CROOT, GROUP, VAR, COOR,
     $     FNM,   FMT,   LB,  IR,  DIMS, VAL
      integer jtry
      integer j
      integer jedmy
CCC_  - Body
      iErr = 0
c
      do jtry = 0, 1
         if (jtry.eq.0) then
            TV = VNi
            TC = COi
         else if (jtry.eq.1) then
            TV = '*'
            TC = '*'
         endif

         rewind (IFPp, IOSTAT = iErr)

         DO
            CROOT  = ' '
            GROUP  = ' '
            VAR    = ' '
            COOR   = ' '
            FNM    = ' '
            FMT    = ' '
            LB     = 0
            IR     = 0
            VAL    = 0.0d0
            do j = 1, LD
               DIMS(j) = 0
            enddo
c
            READ  (IFPp, NIDATA, IOSTAT = iErr)
            if (iErr.ne.0) goto 110
            if (CROOT.eq.CRi
     $           .and. GROUP.eq.GRi
     $           .and. VAR.eq.TV
     $           .and. COOR.eq.TC) then
               goto 100
            endif
         ENDDO
 110     continue
      enddo
 100  continue
c
      if (LVEML.gt.0) then
         call UNBbgn (jedmy, 'NIDATA',       IFPn, LVEML)
         call UNBstr (jedmy, 'CROOT', CRi,   IFPn, LVEML)
         call UNBstr (jedmy, 'GROUP', GRi,   IFPn, LVEML)
         call UNBstr (jedmy, 'COOR',  COi,   IFPn, LVEML)
         call UNBstr (jedmy, 'VAR',   VNi,   IFPn, LVEML)
         call UNBstr (jedmy, 'FNM',   FNM,   IFPn, LVEML)
         call UNBstr (jedmy, 'FMT',   FMT,   IFPn, LVEML)
         call UNBint (jedmy, 'LB',    LB,    IFPn, LVEML)
         call UNBint (jedmy, 'IR',    IR,    IFPn, LVEML)
         call UNBrst (jedmy, 'VAL',   VAL,   IFPn, LVEML)
         call UNBina (jedmy, 'DIMS',  DIMS,  LD,   0, IFPn, LVEML)
         call UNBend (jedmy, 'NIDATA',       IFPn, LVEML)
      else
         if (COND_N(IFPn)) then
            write (IFPn, NIDATA)
         else if (COND_S(IFPn)) then
            write (*,    NIDATA)
         endif
      endif
      if (iErr.eq.0) then
         VALo = VAL
         FTP  = FMT
         FN   = FNM
         do j = 1, LD
            DIMSo(j) = DIMS(j)
            if (DIMS(j).eq.0) goto 200
         enddo
 200     continue
      else
         VALo    = 0.0d0
         FTP     = ' '
         FN      = ' '
         DIMS(1) = 0
      endif
      call DAtrcU (IFPl, iErr, VNi, 'AFRCNM')
      RETURN
      END
CCC_  & AFRvsa  ## ascii/binary input
      subroutine AFRvsa
     O    (iErr,
     O     V,   MH, LH,  MHZ, LHZ, VAL,
     W     W,   LW,
     I     LPa, DIMS,
     I     FN,  LB, IRS, IE,  IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
c
      _INTENT(OUT,  _REALSTD)  V (*)
      _INTENT(OUT,  _REALSTD)  W (*)
      _INTENT(IN,   integer)   MHZ,  LHZ
      _INTENT(IN,   integer)   MH,   LH,  LW
      _INTENT(IN,   _REALSTD)  VAL
      _INTENT(IN,   integer)   LPa (*)
      _INTENT(IN,   integer)   DIMS(*)
      _INTENT(IN,   integer)   IE  (*)
      _INTENT(IN,   integer)   IFPl
      _INTENT(IN,   character) FN*(*)
      _INTENT(IN,   integer)   LB, IRS
c
      integer  jfp
      integer  ir
      integer  LR
      integer  jp
      integer  ji,  jo, jd, jv
      integer  khx, khy
      integer  mw,  mi
      integer  kx,  ky, kg, kw
      integer  lbi, nhi
CCC_  - Body
      iErr = 0
      jfp  = -1
      if (iErr.eq.0) call UUMCnu (iErr, jfp)
      khx = 0
      khy = 0
      mw  = 1
      LR  = -1
CC      caution: hard-coded
      do jd = 1, 10
c$$$         write (IFPl, *) 'dims', jd, DIMS(jd)
         if (DIMS(jd).eq.0) then
            khx = jd - 2
            khy = jd - 1
            goto 100
         endif
         mw = mw * DIMS(jd)
      enddo
 100  continue
      if (khx.le.0.or.khy.le.0) iErr = -1
      if (khx.gt.2) iErr = -1
      if (iErr.eq.0) then
         if (mw.gt.LW) iErr = -1
      endif
      mi = mw / DIMS(khx) / DIMS (khy)
      ir = IRS
      if (iErr.eq.0) then
         if (LB.eq.0) then
            nhi = DIMS(khx) * DIMS(khy)
            call DVFltp(lbi, nhi, 'S')
            call DVPb2l(LR, LBI, ' ', ' ')
 103        format('RECORD LENGTH COMPUTED INTERNALY = ',  I12, I12)
            write (IFPl, 103) LR, lbi
         endif
         if (LB.gt.0) then
            call DVPb2l(LR, LB,  ' ', ' ')
         endif
      endif
      if (iErr.eq.0) then
         if (LR.gt.0) then
            call UUopen (iErr, jfp, FN, LR, 'U', 'O', 'R', ' ')
         else
            call UUopen (iErr, jfp, FN, LR, 'F', 'O', 'R', ' ')
         endif
      endif
      do jo = 1, LPa(3)
         if (iErr.eq.0) then
            if (LR.gt.0) then
               call UUwrRS (iErr, jfp, ir, mw, W)
               ir = ir + 1
            else
               call UUwrSS (iErr, jfp, mw, W)
            endif
         endif
         if (iErr.eq.0) then
            do jp = 0, MH - 1
               kx = EA_listLX(IE,jp)
               ky = EA_listLY(IE,jp)
               if (kx.lt.1
     $              .or.kx.gt.DIMS(khx)
     $              .or.ky.lt.1
     $              .or.ky.gt.DIMS(khy)) then
                  do ji = 1, LPa(1)
                     jv =    LPa(1) * LPa(2) * (jo - 1)
     $                    +  LPa(1) * jp
     $                    +  ji
                     V(jv) = VAL
                     write (IFPl, 301) ji, jp, jo,
     $                    kx, ky, -1, jv, V (jv)
                  enddo
               else
                  kg = (ky - 1) * DIMS(khx) + kx
                  do ji = 1, LPa(1)
                     jv =    LPa(1) * LPa(2) * (jo - 1)
     $                    +  LPa(1) * jp
     $                    +  ji
                     kw = (kg - 1) * mi + ji
                     V(jv) = W(kw)
                     write (IFPl, 301) ji, jp, jo,
     $                    kx, ky, kw, jv, V (jv)
                  enddo
               endif
            enddo
         endif
      enddo
 301  format (3I7,' : ', 4I7, 1x, E16.9)
      if (iErr.eq.0) then
         call UUclsC(iErr, jfp, FN, ' ')
      endif
      call DAtrcU (IFPl, iErr, FN, 'AFRVSA')
      RETURN
      END
CCC_* [AFG] dvio grouping
CCC_ & AFGbwm  ## Batch minimum output interface
      subroutine AFGbwm
     O    (iErr,
     M     kaDVg, saDVg,
     M     iTblG, cTblG, sTblG, nGrp, LGI, LGA, LGS,
     M     iTblV, cTblV,              LVI,
     I     V,
     I     idG, T, IE)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
c
      _INTENT(IN,   integer)   LGI, LGA, LGS
      _INTENT(IN,   integer)   LVI
c
      _INTENT(INOUT,integer)   kaDVg (VIO_KPOLICY_MAX, *)
      _INTENT(INOUT,character) saDVg (*)*(VIO_SPOLICY_LEN)
c
      _INTENT(INOUT,integer)   nGrp
      _INTENT(INOUT,integer)   iTblG (LGI, 0:*)
      _INTENT(INOUT,character) cTblG (LGA, 0:*)*(*)
      _INTENT(INOUT,_REALSTD)  sTblG (LGS, 0:*)
c
      _INTENT(INOUT,integer)   iTblV (LVI, *)
      _INTENT(INOUT,character) cTblV (*)*(*)
c
      _INTENT(IN, integer)   idG
      _INTENT(IN, _REALSTD)  V (*)
      _INTENT(IN, _REALSTD)  T
      _INTENT(IN, integer)   IE (*)
      integer   KX, idVs, idVe
      character SRC*(16), CNM*(1)
CCC_  - Body
      KX   = 1
      idVs = 0
      idVe = 0
      SRC  = 'AFGbwm'
      CNM  = ' '
      call AFGwpt
     O    (iErr,
     M     kaDVg, saDVg,
     M     iTblG, cTblG, sTblG, nGrp, LGI, LGA, LGS,
     M     iTblV, cTblV,              LVI,
     I     V,
     I     idG,   idVs,  idVe,  KX,   T,   CNM, SRC,  IE)
      RETURN
      END
CCC_ & AFGbwt  ## Batch minimum output interface (tag replacement)
      subroutine AFGbwt
     O    (iErr,
     M     kaDVg, saDVg,
     M     iTblG, cTblG, sTblG, nGrp, LGI, LGA, LGS,
     M     iTblV, cTblV,              LVI,
     I     V,
     I     idG, T, CNM,  IE)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
c
      _INTENT(IN,   integer)   LGI, LGA, LGS
      _INTENT(IN,   integer)   LVI
c
      _INTENT(INOUT,integer)   kaDVg (VIO_KPOLICY_MAX, *)
      _INTENT(INOUT,character) saDVg (*)*(VIO_SPOLICY_LEN)
c
      _INTENT(INOUT,integer)   nGrp
      _INTENT(INOUT,integer)   iTblG (LGI, 0:*)
      _INTENT(INOUT,character) cTblG (LGA, 0:*)*(*)
      _INTENT(INOUT,_REALSTD)  sTblG (LGS, 0:*)
c
      _INTENT(INOUT,integer)   iTblV (LVI, *)
      _INTENT(INOUT,character) cTblV (*)*(*)
c
      _INTENT(IN, integer)   idG
      _INTENT(IN, character) CNM*(*)
      _INTENT(IN, _REALSTD)  V (*)
      _INTENT(IN, _REALSTD)  T
      _INTENT(IN, integer)   IE (*)
      integer   KX, idVs, idVe
      character SRC*(16)
CCC_  - Body
      KX   = 1
      idVs = 0
      idVe = 0
      SRC  = 'AFGbwt'
      call AFGwpt
     O    (iErr,
     M     kaDVg, saDVg,
     M     iTblG, cTblG, sTblG, nGrp, LGI, LGA, LGS,
     M     iTblV, cTblV,              LVI,
     I     V,
     I     idG,   idVs,  idVe,  KX,   T,   CNM, SRC,  IE)
      RETURN
      END
CCC_ & AFGbwr  ## Batch output interface (tag replacement;range)
      subroutine AFGbwr
     O    (iErr,
     M     kaDVg, saDVg,
     M     iTblG, cTblG, sTblG, nGrp, LGI, LGA, LGS,
     M     iTblV, cTblV,              LVI,
     I     V,
     I     idG, idVs, idVe, T, CNM,  IE)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
c
      _INTENT(IN,   integer)   LGI, LGA, LGS
      _INTENT(IN,   integer)   LVI
c
      _INTENT(INOUT,integer)   kaDVg (VIO_KPOLICY_MAX, *)
      _INTENT(INOUT,character) saDVg (*)*(VIO_SPOLICY_LEN)
c
      _INTENT(INOUT,integer)   nGrp
      _INTENT(INOUT,integer)   iTblG (LGI, 0:*)
      _INTENT(INOUT,character) cTblG (LGA, 0:*)*(*)
      _INTENT(INOUT,_REALSTD)  sTblG (LGS, 0:*)
c
      _INTENT(INOUT,integer)   iTblV (LVI, *)
      _INTENT(INOUT,character) cTblV (*)*(*)
c
      _INTENT(IN, integer)   idG
      _INTENT(IN, integer)   idVs, idVe
      _INTENT(IN, character) CNM*(*)
      _INTENT(IN, _REALSTD)  V (*)
      _INTENT(IN, _REALSTD)  T
      _INTENT(IN, integer)   IE (*)
      integer   KX
      character SRC*(16)
CCC_  - Body
      KX   = 1
      SRC  = 'AFGbwr'
      call AFGwpt
     O    (iErr,
     M     kaDVg, saDVg,
     M     iTblG, cTblG, sTblG, nGrp, LGI, LGA, LGS,
     M     iTblV, cTblV,              LVI,
     I     V,
     I     idG,   idVs,  idVe,  KX,   T,   CNM, SRC,  IE)
      RETURN
      END
CCC_ & AFGbqn  ## Add/query item and put (non-cluster)
      subroutine AFGbqn
     O    (iErr,
     M     kaDVg, saDVg,
     M     iTblG, cTblG, sTblG,       nGrp,       LGI, LGA, LGS,
     M     iTblV, cTblV,        iVAR, nVar, lVar, LVI,
     I     V,
     I     idGi, VNM, icH, GNM, T, SRC, IE)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)   LGI, LGA, LGS
      _INTENT(IN,   integer)   LVI
      _INTENT(IN,   integer)   lVar
      _INTENT(INOUT,integer)   iVar, nVar
c
      _INTENT(INOUT,integer)   kaDVg (VIO_KPOLICY_MAX, *)
      _INTENT(INOUT,character) saDVg (*)*(VIO_SPOLICY_LEN)
c
      _INTENT(INOUT,integer)   nGrp
      _INTENT(INOUT,integer)   iTblG (LGI, 0:*)
      _INTENT(INOUT,character) cTblG (LGA, 0:*)*(*)
      _INTENT(INOUT,_REALSTD)  sTblG (LGS, 0:*)
c
      _INTENT(INOUT,integer)   iTblV (LVI, *)
      _INTENT(INOUT,character) cTblV (*)*(*)
c
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   character) GNM*(*), VNM*(*)
      _INTENT(IN,   integer)   icH
      _INTENT(IN,   integer)   idGi
      _INTENT(IN,   character) SRC*(*)
      _INTENT(IN,   integer)   IE (*)
      _INTENT(IN,   _REALSTD)  V (*)
      _INTENT(IN,   _REALSTD)  T
      integer idV, idVs, idVe
      integer jvid
      integer KX
CCC_  - Body
      iErr = 0
      if (iErr.eq.0) then
         call AFGqim
     O       (iErr,  idV,
     I        iTblG,        nGrp,  LGI,
     I        iTblV, cTblV,        LVI,
     I        idGi,  icH,   VNM)
      endif
      if (iErr.eq.0) then
         if (idV.eq.0) then
            call AFGrgm
     O          (iErr,
     O           jvid,
     M           iTblG,              nGrp,       LGI,
     M           iTblV, cTblV, iVAR, nVAR, lVar, LVI,
     I           idGi,  idV,   icH,  VNM)
            if (iErr.eq.0) then
               idV  = iTblG (VGI_NMV, idGi)
            endif
         endif
      endif
      if (iErr.eq.0) then
         idVs = idV
         idVe = idV
         KX   = 0
         call AFGwpt
     O       (iErr,
     M        kaDVg, saDVg,
     M        iTblG, cTblG, sTblG, nGrp, LGI, LGA, LGS,
     M        iTblV, cTblV,              LVI,
     I        V,
     I        idGi,  idVs,  idVe,  KX,   T,   GNM, SRC,  IE)
      endif
      RETURN
      END
CCC_ & AFGreg  ## cluster group registration
      subroutine AFGreg
     O    (iErr,  idG,
     M     kaDVg, saDVg,
     M     iTblG, cTblG, sTblG, iGrp, nGrp, lGrp, LGI, LGA, LGS,
     M     iTblV, cTblV,        iVar, nVar, lVar, LVI,
     I     MH,    LH,    MZ,    LZ,   NV,   GNM,  icH,  OSUBS,
     I     CSW,   CLS,   CRT,   ipFI, iMA)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(OUT,  integer)   idG
c
      _INTENT(IN,   integer)   LGI,  LGA, LGS
      _INTENT(IN,   integer)   LVI
      _INTENT(IN,   integer)   lGrp, lVar
c
      _INTENT(INOUT,integer)   kaDVg (VIO_KPOLICY_MAX, *)
      _INTENT(INOUT,character) saDVg (*)*(VIO_SPOLICY_LEN)
c
      _INTENT(INOUT,integer)   iGrp, nGrp
      _INTENT(INOUT,integer)   iTblG (LGI, 0:*)
      _INTENT(INOUT,character) cTblG (LGA, 0:*)*(*)
      _INTENT(INOUT,_REALSTD)  sTblG (LGS, 0:*)
c
      _INTENT(INOUT,integer)   iVar, nVar
      _INTENT(INOUT,integer)   iTblV (LVI, *)
      _INTENT(INOUT,character) cTblV (*)*(*)
c
      _INTENT(IN,   integer)   MH,  LH
      _INTENT(IN,   integer)   MZ,  LZ
      _INTENT(IN,   integer)   NV
      _INTENT(IN,   character) CSW*(*)
      _INTENT(IN,   character) CLS*(*), CRT*(*)
      _INTENT(IN,   character) GNM*(*)
      _INTENT(IN,   logical)   OSUBS
      _INTENT(IN,   integer)   icH
      _INTENT(IN,   integer)   iMA (*)
      _INTENT(IN,   integer)   ipFI (*)
c
      _REALSTD  TST, TEN, DT, TNXT, TCUR, TREC
      integer   KSW
c
      integer   jpI, jpN, jpL, jpV
      integer   ivs
      integer   l
      character DefNam*(32)
      integer    jgDef
      parameter (jgDef = 0)
      integer   MHZ, LHZ
      integer   jrecf
CCC_  - Body
      iErr = 0
      jpI  = ipFI (AFI_FPI)
      jpN  = ipFI (AFI_FPN)
      jpL  = ipFI (AFI_FPL)
      jpV  = ipFI (AFI_FPV)
c
      TST  = sTblG (VGS_START, jgDef)
      TCUR = sTblG (VGS_TCUR,  jgDef)
      TEN  = sTblG (VGS_END,   jgDef)
      DT   = sTblG (VGS_STEP,  jgDef)
      TNXT = sTblG (VGS_NEXT,  jgDef)
      TREC = sTblG (VGS_TREC,  jgDef)
      KSW  = iTblG (VGI_FLG,   jgDef)
CCC_   . group allocation
      if (iGRP.eq.0) then
         ivs = 0
      else
         ivs = iTblG (VGI_IVS, iGRP) + iTblG (VGI_NMV, iGRP)
      endif
      if (iErr.eq.0) then
         iGRP = iGRP + 1
         nGRP = MIN (iGRP, lGRP)
         if (iGRP.gt.lGRP) iErr = -1
      endif
      if (iErr.eq.0) then
         idG = iGRP
         iTblG (VGI_IVS,   idG) = ivs
         iTblG (VGI_NMV,   idG) = NV
         iTblG (VGI_REC,   idG) = 0
         iTblG (VGI_MH,    idG) = MH
         iTblG (VGI_LH,    idG) = LH
         iTblG (VGI_MZ,    idG) = MZ
         iTblG (VGI_LZ,    idG) = LZ
c$$$         iTblG (VGI_M,     idG) = MH
         MHZ = LH * MAX(1, MZ)
         LHZ = LH * MAX(1, LZ)
         iTblG (VGI_M,     idG) = MHZ
         iTblG (VGI_L,     idG) = LHZ
         iTblG (VGI_CMI,   idG) = 0
         iTblG (VGI_COR,   idG) = icH
         if (OSUBS) then
            iTblG (VGI_STEP,  idG) = 0
         else
            iTblG (VGI_STEP,  idG) = -1
         endif
         iTblG (VGI_SUBI,  idG) = -1
         cTblG (VGA_GNM,   idG) = GNM
         cTblG (VGA_CRT,   idG) = CRT
         sTblG (VGS_START, idG) = TST
         sTblG (VGS_END,   idG) = TEN
         sTblG (VGS_STEP,  idG) = DT
         sTblG (VGS_TCUR,  idG) = TCUR
         sTblG (VGS_NEXT,  idG) = TNXT
         sTblG (VGS_TREC,  idG) = TREC
         iTblG (VGI_FLG,   idG) = KSW
      else
         idG = 0
      endif
CCC_   . variable allocation
      if (iErr.eq.0) then
         iVAR = iVAR + MAX (0, NV)
         nVAR = MIN (iVAR, LVAR)
         if (iVAR.gt.LVAR) iErr = -1
      endif
      if (iErr.eq.0) then
 101     format ('VAR', I4.4)
         do l = 1, NV
            write (DefNam, 101) l + 1
            iTblV (VVI_IDX, ivs + l) = l
            iTblV (VVI_COR, ivs + l) = icH
            cTblV (ivs + l)          = DefNam
         enddo
      endif
CCC_   . file binder
      if (iErr.eq.0) then
         call AFDudw
     O       (iErr,
     O        kaDVg (1, idG), saDVg (idG),
     I        CSW,  'S', MHZ, CLS, CRT, GNM, ipFI, iMA)
      endif
CCC_   . timing
      if (iErr.eq.0) then
         call AFPstm
     O       (iErr,
     M        iTblG (1, idG), cTblG (1, idG), sTblG (1, idG),
     I        CRT,  GNM,  ipFI)
      endif
CCC_   . update variable flag
      if (iErr.eq.0) then
         if (iTblG(VGI_FLG, idG).eq. AFSW_NEVER
     $        .or. iTblG(VGI_FLG, idG).eq. AFSW_QUIET) then
            jrecf = VVI_REC_SKIP
         else
            jrecf = VVI_REC_WAIT
         endif
         do l = 1, NV
            iTblV (VVI_REC, ivs + l) = jrecf
         enddo
      endif
      if (iErr.eq.0) then
c$$$         write (*, *) idG,iTblG (VGI_FLG, idG)
         if (iTblG (VGI_FLG, idG).eq. AFSW_NEVER) then
            sTblG (VGS_START, idG) = TEN + MAX (DT, 1.0d0)
            sTblG (VGS_NEXT,  idG) = TEN + MAX (DT, 1.0d0)
            sTblG (VGS_TREC,  idG) = TST - MAX (DT, 1.0d0)
         endif
      endif
c$$$      write (*, *) 'REG', idG, sTblG (VGS_TREC,  idG)
      RETURN
      END
CCC_ & AFGqim  ## member inquiry
      subroutine AFGqim
     O    (iErr,  idVo,
     I     iTblG,        nGrp,  LGI,
     I     iTblV, cTblV,        LVI,
     I     idGi,  icH,   VNM)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   idVo
c
      _INTENT(IN, integer)   LGI,  LVI
      _INTENT(IN, integer)   nGrp
      _INTENT(IN, integer)   iTblG (LGI, 0:*)
      _INTENT(IN, integer)   iTblV (LVI, *)
      _INTENT(IN, character) cTblV (*)*(*)
c
      _INTENT(IN, integer)   idGi
      _INTENT(IN, character) VNM*(*)
      _INTENT(IN, integer)   icH
c
      integer l, jv, maxv
      logical OFOUND
CCC_  - Body
      iErr = 0
      idVo = 0
      if (idGi.lt.0 .or. idGi.gt.nGRP) iErr = -1
      if (iErr.eq.0) then
         maxv = iTblG (VGI_NMV, idGi)
         do l = 1, maxv
            jv = iTblG (VGI_IVS, idGi) + l
            OFOUND = .true.
            if (VNM .ne. cTblV (jv))          OFOUND = .false.
            if (icH .ne. iTblV (VVI_COR, jv)) OFOUND = .false.
            if (OFOUND) then
               idVo = l
               goto 100
            endif
         enddo
 100     continue
      endif
      RETURN
      END
CCC_ & AFGrgm  ## member registration
      subroutine AFGrgm
     O    (iErr,
     O     idVo,
     M     iTblG,               nGrp,         LGI,
     M     iTblV, cTblV, iVar,  nVar,  lVar,  LVI,
     I     idGi,  idVi,  icH,   VNM)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(OUT,  integer)   idVo
c
      _INTENT(IN,   integer)   LGI,  LVI
      _INTENT(IN,   integer)   lVar
c
      _INTENT(IN,   integer)   nGrp
      _INTENT(INOUT,integer)   iTblG (LGI, 0:*)
c
      _INTENT(INOUT,integer)   iVar, nVar
      _INTENT(INOUT,integer)   iTblV (LVI, *)
      _INTENT(INOUT,character) cTblV (*)*(*)
c
      _INTENT(IN,   integer)   idGi, idVi
c
      _INTENT(IN,   character) VNM*(*)
      _INTENT(IN,   integer)   icH
c
      integer jv, maxv, l, jp
      integer jg
      integer jrecf
CCC_  - Body
      iErr = 0
      jv   = -1
      if (idGi.lt.0 .or. idGi.gt.nGRP) iErr = -1
      if (iErr.eq.0) then
         maxv = iTblG (VGI_NMV, idGi)
         if (idVi.gt.maxv) iErr = -1
      endif
      if (iErr.eq.0) then
         if (iTblG(VGI_FLG, idGi).eq. AFSW_NEVER
     $        .or. iTblG(VGI_FLG, idGi).eq. AFSW_QUIET) then
            jrecf = VVI_REC_SKIP
         else
            jrecf = VVI_REC_WAIT
         endif
CCC_   . insertion
         if (idVi.eq.0) then
            do jg = 1 + idGi, nGRP
               iTblG (VGI_IVS, jg) = iTblG (VGI_IVS, jg) + 1
            enddo
            iVAR = iVAR + 1
            nVAR = MIN (iVAR, LVAR)
            if (iVAR.gt.LVAR) then
               iErr = -1
            else
               maxv = maxv + 1
               iTblG (VGI_NMV, idGi) =  maxv
               jv = iTblG (VGI_IVS, idGi) + maxv
               do l = 1 + jv, nVAR
                  do jp = 1, LVI
                     iTblV (jp, l + 1) = iTblV (jp, l)
                  enddo
                  cTblV (l + 1) = cTblV (l)
               enddo
               iTblV(VVI_IDX, jv) = maxv
               if (VNM.ne.' ') cTblV (jv)          = VNM
               if (icH.ne.0)   iTblV (VVI_COR, jv) = icH
c$$$               iTblV (VVI_REC, jv) = VVI_REC_WAIT
               iTblV (VVI_REC, jv) = jrecf
            endif
CCC_   . normal
         else
            jv = iTblG (VGI_IVS, idGi) + idVi
            iTblV (VVI_IDX, jv) = idVi
            if (VNM.ne.' ') cTblV (jv)          = VNM
            if (icH.ne.0)   iTblV (VVI_COR, jv) = icH
c$$$            iTblV (VVI_REC, jv) = VVI_REC_WAIT
            iTblV (VVI_REC, jv) = jrecf
         endif
      endif
      idVo = jv
      RETURN
      END
CCC_ & AFGflt  ## cluster group filter
      subroutine AFGflt
     O    (iErr,
     M     iTblG, cTblG, nGrp,  LGI,  LGA,
     M     iTblV, cTblV,        LVI,
     I     idGi,  GNM,   ipFI)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
c
      _INTENT(IN,   integer)   LGI,  LGA, LVI
c
      _INTENT(IN,   integer)   nGrp
      _INTENT(IN,   integer)   iTblG (LGI, 0:*)
      _INTENT(IN,   character) cTblG (LGA, 0:*)*(*)
c
      _INTENT(INOUT,integer)   iTblV (LVI, *)
      _INTENT(IN,   character) cTblV (*)*(*)
c
      _INTENT(IN,   integer)   idGi
      _INTENT(IN,   character) GNM*(*)
      _INTENT(IN,   integer)   ipFI(*)
      integer maxv
CCC_  - Body
      iErr = 0
      if (idGi.lt.0 .or. idGi.gt.nGRP) iErr = -1
      if (iErr.eq.0) then
         maxv = iTblG (VGI_NMV, idGi)
         call AFPgfl
     O       (iErr,
     I        iTblG  (1, idGi), cTblG (1, idGi),
     M        iTblV,            cTblV, LVI,
     I        maxv,  GNM,       ipFI)
         continue
      endif
      RETURN
      END
CCC_ & AFGmiw  ## cluster group meta-info
      subroutine AFGmiw
     O    (iErr,
     M     kaDVg, saDVg,
     M     iTblG, cTblG, nGrp,  LGI,  LGA,
     M     iTblV, cTblV,        LVI,
     I     idGi,  GNM,   SRC,   IE)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
c
      _INTENT(IN,   integer)   LGI,  LGA, LVI
c
      _INTENT(IN,   integer)   kaDVg (VIO_KPOLICY_MAX, *)
      _INTENT(IN,   character) saDVg (*)*(VIO_SPOLICY_LEN)
c
      _INTENT(IN,   integer)   nGrp
      _INTENT(INOUT,integer)   iTblG (LGI, 0:*)
      _INTENT(IN,   character) cTblG (LGA, 0:*)*(*)
c
      _INTENT(INOUT,integer)   iTblV (LVI, *)
      _INTENT(IN,   character) cTblV (*)*(*)
c
      _INTENT(IN,   integer)   idGi
      _INTENT(IN,   character) GNM*(*), SRC*(*)
      _INTENT(IN,   integer)   IE  (*)
      integer maxv
CCC_  - Body
      iErr = 0
      if (idGi.lt.0 .or. idGi.gt.nGRP) iErr = -1
      if (iErr.eq.0) then
         iTblG (VGI_CMI, idGi) = iTblG (VGI_CMI, idGi) + 1
         maxv = iTblG (VGI_NMV, idGi)
         call AFPmhi
     O       (iErr,
     I        kaDVg  (1, idGi), saDVg (idGi),
     I        iTblG  (1, idGi), cTblG (1, idGi),
     M        iTblV,            cTblV, LVI,
     I        maxv,  SRC, GNM,  IE)
      endif
      RETURN
      END
CCC_ & AFGitm  ## set timing info
      subroutine AFGitm
     O    (iErr,
     M     iTblG,  cTblG, sTblG, nGrp, LGI, LGA, LGS,
     I     idGi,   TINI,  TST,   TEN,   DT,   ipFI)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   nGrp
      _INTENT(IN,   integer)   LGI, LGA, LGS
      _INTENT(INOUT,integer)   iTblG (LGI, 0:*)
      _INTENT(INOUT,character) cTblG (LGA, 0:*)*(*)
      _INTENT(INOUT,_REALSTD)  sTblG (LGS, 0:*)
      _INTENT(IN,   integer)   idGi
      _INTENT(IN,   _REALSTD)  TINI
      _INTENT(IN,   _REALSTD)  TST, TEN, DT
      _INTENT(IN,   integer)   ipFI (*)
      _REALSTD TNXT
CCC_  - Body
      if (idGi.lt.0 .or. idGi.gt.nGRP) iErr = -1
      if (iErr.eq.0) then
         TNXT = TST
         if (DT.le.0.0d0) then
            TNXT = max(TINI, TNXT)
         else if (TNXT.lt.TINI) then
c$$$            write(*, *) 'ITM', TNXT, TINI, DT, TST
            TNXT = AINT((TINI-TNXT)/DT) * DT + TST
            if (TNXT.le.TINI) then
               TNXT = TNXT + DT
            endif
c$$$            write(*, *) 'ITM', TNXT, TINI, DT, TST
         endif
c$$$         write(*, *) 'AFGitm', idGi, TST,TEN, DT, TNXT, TINI
         sTblG (VGS_TCUR,  idGi) = TINI
         sTblG (VGS_START, idGi) = TST
         sTblG (VGS_END,   idGi) = TEN
         sTblG (VGS_STEP,  idGi) = DT
c$$$         sTblG (VGS_NEXT,  idGi) = TST
c$$$         sTblG (VGS_TREC,  idGi) = TST - MAX (DT, 1.0d0)
         sTblG (VGS_NEXT,  idGi) = TNXT
         sTblG (VGS_TREC,  idGi) = TNXT - MAX (DT, 1.0d0)
         iTblG (VGI_FLG,   idGi) = ipFI (AFI_KSW)
         iTblG (VGI_STEP,  idGi) = -1
         iTblG (VGI_SUBI,  idGi) = -1
c$$$         write(*, *) 'ITM',
c$$$     $        TNXT, TINI, DT, TST, TEN, sTblG (VGS_TREC,  idGi)
      endif
      RETURN
      END
CCC_ & AFGnta  ## next time adjustment
      subroutine AFGnta
     M    (Tnxt,
     I     Tcur,
     I     iTblG, cTblG, sTblG, nGrp, LGI, LGA, LGS,
     I     idGi)
CCC_  - Declaration
      implicit none
      _INTENT(INOUT,_REALSTD)  Tnxt
      _INTENT(IN,   _REALSTD)  Tcur
c
      _INTENT(IN,   integer)   nGrp
      _INTENT(IN,   integer)   LGI, LGA, LGS
c
      _INTENT(INOUT,integer)   iTblG (LGI, 0:*)
      _INTENT(INOUT,character) cTblG (LGA, 0:*)*(*)
      _INTENT(INOUT,_REALSTD)  sTblG (LGS, 0:*)
c
      _INTENT(IN,   integer)   idGi
      _REALSTD TT, TI
CCC_  - Body
      if (idGi.lt.0 .or. idGi.gt.nGRP) then
         continue
      else if (sTblG (VGS_STEP, idGi).le.0.0d0) then
         continue
      else
         TI = Tnxt
         TT = sTblG (VGS_NEXT, idGi)
         if (Tcur.ge.TT) TT = TT + sTblG (VGS_STEP, idGi)
         Tnxt = MIN (Tnxt, TT)
c$$$         write (*, *) 'AFGnta', Tcur, Tnxt, TT, sTblG (VGS_NEXT, idGi)
      endif
      RETURN
      END
CCC_ & AFGchk  ## Cluster variables (time check)
      subroutine AFGchk
     O    (iStt,
     M     iTblG, cTblG, sTblG, nGrp, LGI, LGA, LGS,
     I     TS,    TE,
     I     idGi)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iStt
c
      _INTENT(IN,   integer)   nGrp
      _INTENT(IN,   integer)   LGI, LGA, LGS
c
      _INTENT(INOUT,integer)   iTblG (LGI, 0:*)
      _INTENT(INOUT,character) cTblG (LGA, 0:*)*(*)
      _INTENT(INOUT,_REALSTD)  sTblG (LGS, 0:*)
c
      _INTENT(IN,   integer)   idGi
c
      _INTENT(IN,   _REALSTD)  TS, TE
CCC_  - Body
      iStt = 0
      if (idGi.lt.0 .or. idGi.gt.nGRP) iStt = -1
      if (iStt.eq.0) then
         call AFPtch
     $       (iStt,
     $        iTblG (1, idGi), cTblG (1, idGi), sTblG (1, idGi),
     $        TS,  TE)
      endif
      RETURN
      END
CCC_ & AFGchs  ## Cluster variables (time/substep check)
      subroutine AFGchs
     O    (iStt,
     M     iTblG, cTblG, sTblG, nGrp, LGI, LGA, LGS,
     I     TS,    TE,    ISUB,  OFIN,
     I     idGi)
CCC_  - Description
CC   Need to manualy call with OFIN=TRUE to terminate substep monitoring
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iStt
c
      _INTENT(IN,   integer)   nGrp
      _INTENT(IN,   integer)   LGI, LGA, LGS
c
      _INTENT(INOUT,integer)   iTblG (LGI, 0:*)
      _INTENT(INOUT,character) cTblG (LGA, 0:*)*(*)
      _INTENT(INOUT,_REALSTD)  sTblG (LGS, 0:*)
c
      _INTENT(IN,   integer)   idGi
c
      _INTENT(IN,   _REALSTD)  TS, TE
      _INTENT(IN,   integer)   ISUB
      _INTENT(IN,   logical)   OFIN
CCC_  - Body
      iStt = 0
      if (idGi.lt.0 .or. idGi.gt.nGRP) iStt = -1
      if (iStt.eq.0) then
         call AFPsch
     $       (iStt,
     $        iTblG (1, idGi), cTblG (1, idGi), sTblG (1, idGi),
     $        ISUB,  OFIN,     TS,  TE)
      endif
      RETURN
      END
CCC_ & AFGwpt  ## Cluster variables output (with time check)
      subroutine AFGwpt
     O    (iErr,
     M     kaDVg, saDVg,
     M     iTblG, cTblG, sTblG, nGrp, LGI, LGA, LGS,
     M     iTblV, cTblV,              LVI,
     I     V,
     I     idGi,  idVs,  idVe,  KX,   T,   GNM, SRC,  IE)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
c
      _INTENT(IN,   integer)   LGI, LGA, LGS
      _INTENT(IN,   integer)   LVI
c
      _INTENT(INOUT,integer)   kaDVg (VIO_KPOLICY_MAX, *)
      _INTENT(INOUT,character) saDVg (*)*(VIO_SPOLICY_LEN)
c
      _INTENT(INOUT,integer)   nGrp
      _INTENT(INOUT,integer)   iTblG (LGI, 0:*)
      _INTENT(INOUT,character) cTblG (LGA, 0:*)*(*)
      _INTENT(INOUT,_REALSTD)  sTblG (LGS, 0:*)
c
      _INTENT(INOUT,integer)   iTblV (LVI, *)
      _INTENT(INOUT,character) cTblV (*)*(*)
c
      _INTENT(IN,   integer)   idGi, idVs, idVe
      _INTENT(IN,   integer)   KX
c
      _INTENT(IN,   character) GNM*(*)
      _INTENT(IN,   character) SRC*(*)
      _INTENT(IN,   integer)   IE  (*)
c
      _INTENT(IN,   _REALSTD) V (*)
      _INTENT(IN,   _REALSTD) T
c
      integer  jStt
      _REALSTD TEi
      integer  jStp
CCC_  - Body
      iErr = 0
      TEi  = T
      jStp = -1
      call AFGchk
     O    (jStt,
     M     iTblG, cTblG, sTblG, nGrp, LGI, LGA, LGS,
     I     T,     TEi,   idGi)
      if (jStt.gt.0) then
         call AFGppt
     O       (iErr,
     M        kaDVg, saDVg,
     M        iTblG, cTblG, sTblG, nGrp, LGI, LGA, LGS,
     M        iTblV, cTblV, LVI,
     I        V,
     I        idGi,  idVs,  idVe,  KX,  T,   TEi,  jStp, GNM, SRC,  IE)
c$$$         call DAtrcU (-1, jstt, GNM, 'AFGWPT')
      else
         iErr = jStt
      endif
      RETURN
      END
CCC_ & AFGwps  ## Cluster variables output (with time/substep check)
      subroutine AFGwps
     O    (iErr,
     M     kaDVg, saDVg,
     M     iTblG, cTblG, sTblG, nGrp, LGI, LGA,  LGS,
     M     iTblV, cTblV,              LVI,
     I     V,
     I     idGi,  idVs,  idVe,  KX,   T,   ISUB, OFIN, GNM, SRC,  IE)
CCC_  - Description
CC   Need to manualy call with OFIN=TRUE to terminate substep monitoring
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
c
      _INTENT(IN,   integer)   LGI, LGA, LGS
      _INTENT(IN,   integer)   LVI
c
      _INTENT(INOUT,integer)   kaDVg (VIO_KPOLICY_MAX, *)
      _INTENT(INOUT,character) saDVg (*)*(VIO_SPOLICY_LEN)
c
      _INTENT(INOUT,integer)   nGrp
      _INTENT(INOUT,integer)   iTblG (LGI, 0:*)
      _INTENT(INOUT,character) cTblG (LGA, 0:*)*(*)
      _INTENT(INOUT,_REALSTD)  sTblG (LGS, 0:*)
c
      _INTENT(INOUT,integer)   iTblV (LVI, *)
      _INTENT(INOUT,character) cTblV (*)*(*)
c
      _INTENT(IN,   integer)   idGi, idVs, idVe
      _INTENT(IN,   integer)   KX
c
      _INTENT(IN,   character) GNM*(*)
      _INTENT(IN,   character) SRC*(*)
      _INTENT(IN,   integer)   IE  (*)
c
      _INTENT(IN,   _REALSTD) V (*)
      _INTENT(IN,   _REALSTD) T
      _INTENT(IN,   integer)  ISUB
      _INTENT(IN,   logical)  OFIN
c
      integer  jStt
      _REALSTD TEi
CCC_  - Body
      iErr = 0
      TEi  = T
      call AFGchs
     O    (jStt,
     M     iTblG, cTblG, sTblG, nGrp, LGI, LGA, LGS,
     I     T,     TEi,   ISUB,  OFIN, idGi)
      if (jStt.gt.0) then
         call AFGppt
     O       (iErr,
     M        kaDVg, saDVg,
     M        iTblG, cTblG, sTblG, nGrp, LGI, LGA, LGS,
     M        iTblV, cTblV, LVI,
     I        V,
     I        idGi,  idVs,  idVe,  KX,   T,   TEi, ISUB, GNM, SRC,  IE)
c$$$         call DAtrcU (-1, jstt, GNM, 'AFGWPT')
      else
         iErr = jStt
      endif
      RETURN
      END
CCC_ & AFGppt  ## Cluster variables output core
      subroutine AFGppt
     O    (iErr,
     M     kaDVg, saDVg,
     M     iTblG, cTblG, sTblG, nGrp, LGI, LGA, LGS,
     M     iTblV, cTblV,              LVI,
     I     V,
     I     idGi,  idVs,  idVe,  KX,   TS,  TE,  ISUB, GNM, SRC,  IE)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
c
      _INTENT(IN,   integer)   LGI, LGA, LGS
      _INTENT(IN,   integer)   LVI
c
      _INTENT(INOUT,integer)   kaDVg (VIO_KPOLICY_MAX, *)
      _INTENT(INOUT,character) saDVg (*)*(VIO_SPOLICY_LEN)
c
      _INTENT(INOUT,integer)   nGrp
      _INTENT(INOUT,integer)   iTblG (LGI, 0:*)
      _INTENT(INOUT,character) cTblG (LGA, 0:*)*(*)
      _INTENT(INOUT,_REALSTD)  sTblG (LGS, 0:*)
c
      _INTENT(INOUT,integer)   iTblV (LVI, *)
      _INTENT(INOUT,character) cTblV (*)*(*)
c
      _INTENT(IN,   integer)   idGi, idVs, idVe
      _INTENT(IN,   integer)   KX
c
      _INTENT(IN,   character) GNM*(*)
      _INTENT(IN,   character) SRC*(*)
      _INTENT(IN,   integer)   IE  (*)
c
      _INTENT(IN,   _REALSTD) V (*)
      _INTENT(IN,   _REALSTD) TS, TE
      _INTENT(IN,   integer)  ISUB
      integer MHZ, LHZ, maxv, lv
CCC_  - Body
      iErr = 0
      if (idGi.lt.0 .or. idGi.gt.nGRP) iErr = -1
      if (iErr.eq.0) then
         maxv = iTblG (VGI_NMV, idGi)
         mhz  = iTblG (VGI_M,   idGi)
         lhz  = iTblG (VGI_L,   idGi)
         if (KX.eq.0) then
            lv = 1
         else
            lv = maxv
         endif
         call AFPcpt
     O       (iErr,
     M        kaDVg (1, idGi), saDVg (idGi),
     M        iTblG (1, idGi), cTblG (1,idGi), sTblG (1, idGi),
     M        iTblV, cTblV, LVI,
     I        V,     MHZ,   LHZ,  LV,  MAXV, idVs, idVe, KX,
     I        TS,    TE,    ISUB, GNM, SRC,  IE)
      endif
      RETURN
      END
CCC_ & AFGrep  ## report
      subroutine AFGrep
     O    (iErr,
     I     iTblG, cTblG, sTblG, iGrp, nGrp, lGrp,  LGI,  LGA, LGS,
     I     iTblV, cTblV,        iVar, nVar, lVar,  LVI,
     I     IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
c
      _INTENT(IN, integer)   LGI,  LGA, LGS
      _INTENT(IN, integer)   LVI
      _INTENT(IN, integer)   lGrp, lVar
c
      _INTENT(IN, integer)   iGrp, nGrp
      _INTENT(IN, integer)   iTblG (LGI, 0:*)
      _INTENT(IN, character) cTblG (LGA, 0:*)*(*)
      _INTENT(IN, _REALSTD)  sTblG (LGS, 0:*)
c
      _INTENT(IN, integer)   iVar, nVar
      _INTENT(IN, integer)   iTblV (LVI, *)
      _INTENT(IN, character) cTblV (*)*(*)
c
      _INTENT(IN,   integer)   IFPl
      integer jg, jv
      integer maxv
CCC_  - Body
      iErr = 0
 401  format ('AFPREP/G:', 3I5)
 402  format ('AFPREP/V:', 3I5)
 409  format ('AFPREP: done')
 302  format (I4, 1x, I4, 1x, I5, 1x, A)
 304  format ('      ', 4x, 1x,    T20, 3x, 3x, T30, 5A10)
 303  format ('GROUP ', I4, 1x, A, T20, I3, I3,
     $     T30, F9.1, 1x, F9.1, 1x, F9.1, 1x, F9.1, 1x, F9.1)
      write (IFPl, 401) iGrp, nGrp, lGrp
      write (IFPl, 402) iVar, nVar, lVar
      write (IFPl, 304) 'REC', 'START', 'END', 'STEP', 'NEXT'
      do jg = 1, nGrp
         jv   = iTblG (VGI_IVS, jg)
         maxv = iTblG (VGI_NMV, jg)
         write (IFPl, 303) jg,
     $        _TRIM(cTblG (VGA_GNM, jg)), maxv, iTblG (VGI_CMI, jg),
     $        sTblG (VGS_TREC,  jg),
     $        sTblG (VGS_START, jg), sTblG (VGS_END,  jg),
     $        sTblG (VGS_STEP,  jg), sTblG (VGS_NEXT, jg)
      enddo
      do jv = 1, nVar
         write (IFPl, 302)
     $        jv, iTblV (VVI_COR,jv), iTblV (VVI_REC, jv),
     $        _TRIM(cTblV (jv))
      enddo
      write (IFPl, 409)
      RETURN
      END
CCC_* [AFP] grouping primitives
CCC_ & AFPgfl  ## Cluster variables meta info output
      subroutine AFPgfl
     O    (iErr,
     I     iTblG, cTblG,
     M     iTblV, cTblV, LVI,
     I     MAXV,  VGRP,  ipFI)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   iTblG (*)
      _INTENT(IN, character) cTblG (*)*(*)
c
      _INTENT(IN,   integer)   LVI
      _INTENT(INOUT,integer)   iTblV (LVI, *)
      _INTENT(IN,   character) cTblV (*)*(*)
c
      _INTENT(IN, integer)   MAXV
      _INTENT(IN, character) VGRP*(*)
      _INTENT(IN, integer)   ipFI(*)
      character Tgrp*(32)
      integer   jpL
      integer   jva, lv, jvs
CCC_  - Body
      iErr = 0
c
      jvs  = iTblG (VGI_IVS)
      jpL  = ipFI (AFI_FPL)
c
      call USMcpd (TGRP, VGRP, cTblG (VGA_GNM))
      do lv = 1, MAXV
         jva = jvs + lv
         call AFPfli
     O       (iErr,
     M        iTblV, cTblV,   LVI,
     I        cTBLG(VGA_CRT), TGRP,  jva,
     I        ipFI)
      enddo
      call DAtrcU (jpL, iErr, 'R', 'AFPGFL')
      RETURN
      END
CCC_ & AFPfli  ## member filter by namelist
      subroutine AFPfli
     O    (iErr,
     M     iTblV, cTblV, LVI,
     I     CRT,   GNM,   idVa,
     I     ipFI)
CCC_  - Note
CC    idVa is serial id, not vid in a group
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
c
      _INTENT(IN,   integer)   LVI
c
      _INTENT(INOUT,integer)   iTblV (LVI, *)
      _INTENT(INOUT,character) cTblV (*)*(*)
c
      _INTENT(IN,   integer)   idVa
      _INTENT(IN,   character) GNM*(*)
      _INTENT(IN,   character) CRT*(*)
      _INTENT(IN,   integer)   ipFI (*)
c
      integer   jpI, jpN, jpL, jpV
      integer   jos
c
      integer    LVEML
      parameter (LVEML = OPT_NAMELIST_OUTPUT_EMULATION)
c
      character CROOT*(16)
      character GROUP*(16)
      character VAR*(16)
      character VNM*(16)
      integer   KSW
c
      namelist /NIAVFL/
     $     CROOT, GROUP, VAR, KSW
CCC_  - Body
      iErr = 0
      jpI  = ipFI (AFI_FPI)
      jpN  = ipFI (AFI_FPN)
      jpL  = ipFI (AFI_FPL)
      jpV  = ipFI (AFI_FPV)
c
      VNM = cTblV(idVa)
c
      call UUrwnd (jos, jpI)
      do
         CROOT = ' '
         GROUP = ' '
         VAR   = ' '
c        keep
         KSW   = 0
         if (jos.eq.0) READ (jpI, NIAVFL, IOSTAT = jos)
         if (jos.eq.0) then
            if (CROOT.eq.CRT
     $           .and. GROUP.eq.GNM
     $           .and. VAR.eq.VNM) goto 100
         else
            KSW = 0
            jos = -1
            goto 100
         endif
      enddo
 100  continue
c$$$      write(*, *) jos, idVa, VNM, GNM, CRT, KSW, iTblV(VVI_REC, idVa)
      if (jos.eq.0) then
c$$$         write(*, *) 'A',
c$$$     $        idVA, VNM, KSW, iTblV(VVI_REC, idVa),
c$$$     $        iTblV(VVI_REC, 585),iTblV(VVI_REC, 586)
         if (KSW.lt.0) then
            iTblV(VVI_REC, idVa) = VVI_REC_SKIP
         else if (KSW.gt.0) then
            iTblV(VVI_REC, idVa) = VVI_REC_WAIT
         endif
         if (LVEML.gt.0) then
            call UNBbgn (iErr, 'NIAVFL',       jpN, LVEML)
            call UNBstr (iErr, 'CROOT', CRT,   jpN, LVEML)
            call UNBstr (iErr, 'GROUP', GNM,   jpN, LVEML)
            call UNBstr (iErr, 'VAR',   VNM,   jpN, LVEML)
            call UNBint (iErr, 'KSW',   KSW,   jpN, LVEML)
            call UNBend (iErr, 'NIAVFL',       jpN, LVEML)
         else
            CROOT = CRT
            GROUP = GNM
            VAR   = VNM
            if (COND_N(jpN)) then
               write (jpN, NIAVFL)
            else if (COND_S(jpN)) then
               write (*,   NIAVFL)
            endif
         endif
      endif

 101  format('AFGFLV ', I4, 1x, A, ':', A, ':', A, 1x, I3)
      if (COND_N(jpL)) then
         write (jpL, 101) idVa,
     $        _TRIM(VNM), _TRIM(CRT), _TRIM(GNM),
     $        iTblV(VVI_REC, idVa)
      else
         write (*,   101) idVa,
     $        _TRIM(VNM), _TRIM(CRT), _TRIM(GNM),
     $        iTblV(VVI_REC, idVa)
      endif
c$$$      call DAtrcU (jpL, iErr, VNM, 'AFPFLI')
c
      RETURN
      END
CCC_ & AFPmhi  ## Cluster variables meta info output
      subroutine AFPmhi
     O    (iErr,
     I     kaDV,  saDV,
     M     iTblG, cTblG,
     M     iTblV, cTblV, LVI,
     I     MAXV,  SRC,   VGRP, IE)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,   integer)   iErr
      _INTENT(IN,    integer)   kaDV (*)
      _INTENT(IN,    character) saDV*(*)
      _INTENT(INOUT, integer)   iTblG (*)
      _INTENT(IN,    character) cTblG (*)*(*)
c
      _INTENT(IN,   integer)   LVI
      _INTENT(INOUT,integer)   iTblV (LVI, *)
      _INTENT(IN,   character) cTblV (*)*(*)
c
      _INTENT(IN, integer)   MAXV
      _INTENT(IN, character) SRC*(*), VGRP*(*)
      _INTENT(IN, integer)   IE  (*)
      character Stmp*(256)
      character Tgrp*(32)
      character Txsp*(128)
      integer   jedmy, IFPv, IFPl
      integer   jv, lv, lv2, jv2, jvs, nv
      integer   jci
CCC_  - Body
      iErr = 0
c
      call DVFgru (IFPl, kaDV, 0)
      call DVFgru (IFPv, kaDV, 1)
c
      jvs  = iTblG (VGI_IVS)
      jci  = iTblG (VGI_CMI)
c
      nv = MAXV
      do lv = 1, MAXV
         jv = lv + jvs
         if (iTblV(VVI_REC, jv).eq. VVI_REC_SKIP) then
            iTblV(VVI_IDX, jv) = -1
            nv = nv - 1
            do lv2 = lv + 1, MAXV
               jv2 = lv2 + jvs
               if (iTblV(VVI_IDX, jv2).gt.0) then
                  iTblV(VVI_IDX, jv2) = iTblV(VVI_IDX, jv2) - 1
               endif
            enddo
         endif
      enddo
      iTblG(VGI_NVX)= NV
c
      Stmp = 'AFPmhi'
      if (SRC.ne.' ') call USJnta (Stmp, ':', SRC)
      call USMcpd (TGRP, VGRP, cTblG (VGA_GNM))
CCC_   . Group information
      call DVTwta (jedmy, 'GROUP', TGRP,  Stmp,    IFPv)
      call DVTwti (jedmy, 'CMI',   jci,   cTblG (VGA_GNM), IFPv)
      call AFCwgi
     $    (jedmy,
     $     cTblG (VGA_CRT), iTblG (VGI_COR), IFPl, IFPv, .true.)
      call DVTwti (jedmy, 'MAXVU', MaxV,  ' ',    IFPv)
      call DVTwti (jedmy, 'MAXV',  NV,    ' ',    IFPv)
      call AETtba (jedmy, IE,   IFPv, 1)
      call DVTwra (jedmy, kaDV, IFPv)
      call DVTwti (jedmy, 'SUBS', iTblG(VGI_STEP), ' ', IFPv)
      call USCsta (Txsp, 'META/GROUP:', TGRP)
      call DVTwsp (jeDmy, Txsp, IFPv)
CCC_   . Member information
      call USCsta (Txsp, 'META/MEMBER:', TGRP)
      do lv = 1, MAXV
         jv = lv + jvs
c$$$         write(*, *) 'B',
c$$$     $        jv, TGRP, iTblV(VVI_REC, jv),
c$$$     $        iTblV(VVI_REC, 585), iTblV(VVI_REC, 586)
         if (iTblV(VVI_REC, jv).eq. VVI_REC_WAIT) then
            call DVTwta (jedmy, 'GROUP', TGRP,      ' ', IFPv)
            call DVTwta (jedmy, 'ITEM',  cTblV(jv), ' ', IFPv)
            call AFCwgi
     $           (jedmy,
     $           cTblG (VGA_CRT), iTblV (VVI_COR, jv),
     $           IFPl, IFPv, .false.)
            call DVTwti (jedmy, 'KVU', lv,                ' ',    IFPv)
            call DVTwti (jedmy, 'KV',  iTblV(VVI_IDX,jv), ' ',    IFPv)
            call DVTwsp (jeDmy, Txsp, IFPv)
c$$$            iTblV (VVI_REC, jv) = 0
         endif
      enddo
      call DVTwsu (jeDmy, KTYPE_GROUP, 'META/GROUP/END', IFPv)
      call DAtrcU (IFPl, iErr, 'R', 'AFPMHI')
      RETURN
      END
CCC_ & AFPcpt  ## Cluster variables output core (no time check)
      subroutine AFPcpt
     O    (iErr,
     M     kaDV,  saDV,
     I     iTblG, cTblG, sTblG,
     M     iTblV, cTblV,        LVI,
     I     V,     MH,    LH,    LV,
     I     MAXV,  kvs,   kve,   KX,
     I     TS,    TE,    ISUB,  VGRP,  SRC,  IE)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
c
      _INTENT(INOUT,integer)   kaDV (*)
      _INTENT(INOUT,character) saDV*(*)
c
      _INTENT(INOUT,integer)   iTblG (*)
      _INTENT(INOUT,character) cTblG (*)*(*)
      _INTENT(INOUT,_REALSTD)  sTblG (*)
      _INTENT(IN,   integer)   LVI
      _INTENT(INOUT,integer)   iTblV (LVI, *)
      _INTENT(IN,   character) cTblV (*)*(*)

      _INTENT(IN,   _REALSTD)  TS,   TE
      _INTENT(IN,   integer)   ISUB
      _INTENT(IN,   integer)   KX
      _INTENT(IN,   integer)   MH,   LH,  LV
      _INTENT(IN,   integer)   MAXV, kvs, kve
      _INTENT(IN,   _REALSTD)  V  (LH, LV, *)
      _INTENT(IN,   character) SRC*(*), VGRP*(*)
      _INTENT(IN,   integer)   IE  (*)
c
      integer   IRX, IRN, KU
      character TagS*(32), Stmp*(256)
      character FMT*(32),  Tgrp*(32)
      integer   IREC
      integer   jedmy, IFPv, IFPl
      integer   jv,  jvv, jvs,   jv0, jv9
      integer   jvx
      integer   kxi, jvi, jvo
      integer   jsubs
CCC_  - Body
      iErr = 0
c
      Stmp = 'AFPcpt'
      call USJnta (Stmp, ':', SRC)
c
      call DVFgru (IFPl, kaDV, 0)
      call DVFgru (IFPv, kaDV, 1)
c
      jv0 = MAX (1, kvs)
      jv9 = kve
      if (jv9.eq.0) jv9 = MaxV
c
      jvs  = iTblG (VGI_IVS)
      IREC = iTblG (VGI_REC) + 1
c
      jsubs = iTblG (VGI_STEP)
c
      call USMcpd (TGRP, VGRP, cTblG (VGA_GNM))
c
      FMT = ' '
c
 201  format (A, 1x, I7.7, 1x, F9.1)
      write (TagS, 201) _TRIM(TGRP), IREC, TS
CCC_   . derived group
      if (VGRP.ne.' ') then
         call DVTwta (jedmy, 'GROUP', TGRP,  Stmp,  IFPv)
         call DVTwta (jedmy, 'GBASE', cTblG (VGA_GNM),  ' ',  IFPv)
         call AFCwgi
     $       (jedmy,
     $        cTblG (VGA_CRT), iTblG (VGI_COR), IFPl, IFPv, .true.)
         if (jv0.ne.1.or.jv9.ne.MaxV) then
            call DVTwti (jedmy, 'VSTART', jv0, ' ', IFPv)
            call DVTwti (jedmy, 'VEND',   jv9, ' ', IFPv)
         else
            call DVTwti (jedmy, 'MAXV',   jv9, ' ', IFPv)
         endif
         call DVTwsp (jeDmy, 'META/GROUP/BASE', IFPv)
      endif
CCC_   . member loop
#if 0 /* do not adjust close intervals */
      call DVAclm (iErr, kaDV, (jv9 - jv0))
#endif
      kxi = KX
      jvo = 0
      if (kxi.eq.0) then
         kxi = 1
         jvo = - jv0 + 1
      endif
c$$$      write(*, *) 'C',
c$$$     $     jvs,
c$$$     $     iTblV(VVI_REC, 585),iTblV(VVI_REC, 586)

      do jvv = jv0, jv9
         jv  = jvv
         jvi = jvv + jvo
c$$$         write(*, *) 'E',iErr,
c$$$     $        jv, jvs+jv, iTblV(VVI_REC, jvs+jv),
c$$$     $        iTblV(VVI_REC, 585),iTblV(VVI_REC, 586)
         if (iErr.eq.0) then
            jvx = iTblV(VVI_IDX,jvs + jv)
            if (iTblV(VVI_REC, jvs+jv).eq.VVI_REC_WAIT) then
               call DVTwta (jedmy, 'ITEM',  cTblV (jvs+jv), ' ', IFPv)
               call AFCwgi
     $             (jedmy,
     $              cTblG (VGA_CRT), iTblV (VVI_COR, jvs+jv),
     $              IFPl, IFPv, .false.)
               iTblV(VVI_REC, jvs+jv) = 0
            endif
            if (iTblV(VVI_REC, jvs+jv).ge.0) then
               call DVTwta (jedmy, 'GROUP', TGRP,  Stmp,  IFPv)
c$$$  call ACVwri (jedmy, ivA (jvs+lv), IFPv)
               call AFCwri
     $              (jedmy,
     $              cTblG (VGA_CRT), 0, IFPl, IFPv)
               call DVTwti (jedmy, 'KVU',   jv,     ' ',    IFPv)
               call DVTwti (jedmy, 'KV',    jvx,    ' ',    IFPv)
               call DVTwti (jedmy, 'REC',   IREC,   ' ',    IFPv)
               call DVTwts (jedmy, 'TIME',  TS,     ' ',    IFPv)
               call DVTwts (jedmy, 'TE',    TE,     ' ',    IFPv)
               if (jsubs.ge.0) then
                  call DVTwti (jedmy, 'ISUB', ISUB, ' ', IFPv)
               endif
               IRX = 0
               KU  = 0
               call DVSwtS
     O             (iErr,
     O              IRN,
     M              kaDV, saDV,
     I              IRX,  V (1, jvi, kxi), MH, KU, FMT, TagS)
               iTblV(VVI_REC, jvs+jv) =
     $              iTblV(VVI_REC, jvs+jv) + 1
            endif
         endif
c$$$         write(*, *) 'F',
c$$$     $        jv, jvs+jv,iTblV(VVI_REC, jvs+jv),
c$$$     $        iTblV(VVI_REC, 585),iTblV(VVI_REC, 586)
      enddo
c
      if (iErr.eq.0) iTblG (VGI_REC) = IREC

c$$$      write(*, *) 'D',
c$$$     $     jvs,
c$$$     $     iTblV(VVI_REC, 585),iTblV(VVI_REC, 586)
c
      call DAtrcU (IFPl, iErr, 'R', 'AFGCPT')
      RETURN
      END
CCC_ & AFPstm  ## set timings by namelist
      subroutine AFPstm
     O    (iErr,
     M     iTblG, cTblG, sTblG,
     I     CR,    GNM,   ipFI)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
c
      _INTENT(INOUT,integer)   iTblG (*)
      _INTENT(INOUT,character) cTblG (*)*(*)
      _INTENT(INOUT,_REALSTD)  sTblG (*)
c
      _INTENT(IN,   character) CR*(*)
      _INTENT(IN,   character) GNM*(*)
      _INTENT(IN,   integer)   ipFI (*)
c
      integer    LVEML
      parameter (LVEML = OPT_NAMELIST_OUTPUT_EMULATION)
c
      character CROOT*(16)
      character GROUP*(16)
      _REALSTD  TNXT, TINI, TEND, DT, TCUR
      integer   KSW
      integer   ISTEP
      namelist /NIAFWR/
     $     CROOT, GROUP, TINI, TEND, DT, ISTEP, KSW
c
      integer jpI, jpN, jpL
      integer jos
      logical OEOF
CCC_  - Body
      iErr = 0
      jpI  = ipFI (AFI_FPI)
      jpN  = ipFI (AFI_FPN)
      jpL  = ipFI (AFI_FPL)
c
      call UUrwnd (jos, jpI)
c
      TCUR  = sTblG (VGS_TCUR)
      do
         CROOT = ' '
         GROUP = ' '
         TINI  = sTblG (VGS_START)
         TNXT  = sTblG (VGS_NEXT)
         TEND  = sTblG (VGS_END)
         DT    = sTblG (VGS_STEP)
         KSW   = iTblG (VGI_FLG)
         ISTEP = iTblG (VGI_STEP)
         if (jos.eq.0) READ (jpI, NIAFWR, IOSTAT = jos)
         if (jos.eq.0) then
            if (CROOT.eq.CR .and. GROUP.eq.GNM) goto 100
         else
            jos = -1
            goto 100
         endif
      enddo
 100  continue
      if (jos.ge.0) then
         sTblG (VGS_START) = TINI
         sTblG (VGS_END)   = TEND
         sTblG (VGS_STEP)  = DT
c$$$         TNXT = TINI
         if (DT.le.0.0d0) then
            TNXT = max(TINI, TNXT)
c$$$         else if (TNXT.lt.TCUR) then
         else if (TNXT.le.TCUR) then
            TNXT = AINT((TCUR-TNXT)/DT) * DT + TCUR
            if (TNXT.lt.TCUR) then
               TNXT = TNXT + DT
            endif
         endif
c$$$         sTblG (VGS_NEXT)  = TINI
c$$$         sTblG (VGS_TREC)  = TINI
c$$$         write (*, *) 'AFPstm/', GNM, '/', TINI, TNXT, DT, TCUR
         sTblG (VGS_NEXT)  = TNXT
c$$$         sTblG (VGS_TREC)  = TNXT
         sTblG (VGS_TREC)  = TCUR
         iTblG (VGI_FLG)   = KSW
c$$$         write (*, *) 'AFPstm/', GNM, '/', TINI, TNXT, DT, TCUR
CC       only update when positive
         if (iTblG (VGI_STEP).ge.0) then
            iTblG (VGI_STEP)  = ISTEP
         else
            ISTEP = -999
         endif
         iErr = 0
      else
         call UUieof (Oeof, jos)
         if (Oeof) then
            iErr = 1
         else
            iErr = -1
         endif
      endif
      if (LVEML.gt.0) then
         call UNBbgn (iErr, 'NIAFWR',       jpN, LVEML)
         call UNBstr (iErr, 'CROOT', CR,    jpN, LVEML)
         call UNBstr (iErr, 'GROUP', GNM,   jpN, LVEML)
         call UNBint (iErr, 'KSW',   KSW,   jpN, LVEML)
         call UNBrst (iErr, 'TINI',  TINI,  jpN, LVEML)
         call UNBrst (iErr, 'TEND',  TEND,  jpN, LVEML)
         call UNBrst (iErr, 'DT',    DT,    jpN, LVEML)
         call UNBint (iErr, 'ISTEP', ISTEP, jpN, LVEML)
         call UNBend (iErr, 'NIAFWR',       jpN, LVEML)
      else
         CROOT = CR
         GROUP = GNM
         if (COND_N(jpN)) then
            write (jpN, NIAFWR)
         else if (COND_S(jpN)) then
            write (*,   NIAFWR)
         endif
      endif
c$$$      write(*,*) CROOT, GNM, iTblG (VGI_FLG)
c
      call DAtrcU (jpL, iErr, 'R', 'AFPSTM')
      iErr = MIN (0, iErr)
c$$$      write (*, *) iTblG (VGI_FLG)
      RETURN
      END
CCC_ & AFPtch  ## check times
      subroutine AFPtch
     O    (iStt,
     M     iTblG, cTblG, sTblG,
     I     TS,    TE)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iStt
c
      _INTENT(INOUT,integer)   iTblG (*)
      _INTENT(INOUT,character) cTblG (*)*(*)
      _INTENT(INOUT,_REALSTD)  sTblG (*)
c
      _INTENT(IN,   _REALSTD)  TS
      _INTENT(IN,   _REALSTD)  TE
c
      _REALSTD Tnxt, Trec, Tend
CCC_  - Body
      iStt = 0
c
      Tend = sTblG (VGS_END)
      Tnxt = sTblG (VGS_NEXT)
      Trec = sTblG (VGS_TREC)
c$$$      write (*, *) 'TCHK', Tend, Tnxt, Trec, TS
CCC_   . no more
      if      (TS.gt.Tend) then
         continue
CCC_   . new
      else if (TS.ge.Tnxt) then
         iStt = 1
         sTblG (VGS_TREC) = TS
         sTblG (VGS_NEXT) = Tnxt + sTblG (VGS_STEP)
CCC_   . current
      else if (TS.eq.Trec) then
         iStt = 2
      endif
c
      RETURN
      END
CCC_ & AFPsch  ## check times and substep
      subroutine AFPsch
     O    (iStt,
     M     iTblG, cTblG, sTblG,
     I     ISUB,  OFIN,  TS,    TE)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iStt
c
      _INTENT(INOUT,integer)   iTblG (*)
      _INTENT(INOUT,character) cTblG (*)*(*)
      _INTENT(INOUT,_REALSTD)  sTblG (*)
c
      _INTENT(IN,   integer)   ISUB
      _INTENT(IN,   logical)   OFIN
      _INTENT(IN,   _REALSTD)  TS
      _INTENT(IN,   _REALSTD)  TE
c
      _REALSTD Tnxt, Trec, Tend
      integer  jdstp, jstp
CCC_  - Body
      iStt = 0
c
      Tend = sTblG (VGS_END)
      Tnxt = sTblG (VGS_NEXT)
      Trec = sTblG (VGS_TREC)
c
      jdstp = iTblG (VGI_STEP)
      jstp  = iTblG (VGI_SUBI)
c$$$      write (*, *) 'SCH0', jdstp, jstp, ISUB
CCC_   . fall back to AFPtch if negative dstep (i.e., no substep)
      if (jdstp.lt.0) then
         call AFPtch(iStt, iTblG, cTblG, sTblG, TS, TE)
CCC_   . substep monitoring is not activated (output final only)
      else if (jdstp.eq.0) then
         call AFPtch(iStt, iTblG, cTblG, sTblG, TS, TE)
         if (iStt.gt.0.and.OFIN) then
            iStt = 9
         else
            iStt = 0
         endif
CCC_   . check time and activate if necessary
      else if (jstp.lt.0) then
         call AFPtch(iStt, iTblG, cTblG, sTblG, TS, TE)
         if (iStt.gt.0) then
            iTblG(VGI_SUBI) = ISUB + jdstp
         endif
CCC_   . check substep
      else if (OFIN) then
         iStt = 9
         iTblG(VGI_SUBI) = -1
      else if (jstp.le.ISUB) then
         iStt = 1
         iTblG(VGI_SUBI) = jstp + jdstp
      endif
c$$$      write (*, *) 'SCH9', iTblG(VGI_SUBI), iStt
      RETURN
      END
CCC_* [AFE] Elements dealer interface
CCC_ & AFEdvw  ## Tag/Value output for dv wrapper
      subroutine AFEdvw
     O    (iErr,
     I     IE,   CSW, CLS, CROOT, VITEM, ipFI, iMA)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   IE (*)
      _INTENT(IN, character) CSW*(*),   CLS*(*), CROOT*(*)
      _INTENT(IN, character) VITEM*(*)
      _INTENT(IN, integer)   ipFI (*), iMA (*)
      integer jmax
      character TVI*(32)
      integer   jpL, jpV
CCC_  - Body
      iErr = 0
      jpL  = ipFI (AFI_FPL)
      jpV  = ipFI (AFI_FPV)
      jmax = EA_MAX(IE)
      call USMcpd (TVI, VITEM, 'IE')
      call DVTwta (iErr, 'ITEM',  TVI,   _FNAME, jpV)
      call DVTwta (iErr, 'CROOT', CROOT, ' ',    jpV)
CC    full output of table attributes
      call AETtba (iErr, IE, jpV, 1)
      call AFDwoI
     $     (iErr, IE, jmax, CSW, CLS, CROOT, TVI, ' ', ipFI, iMA)
      call DAtrcU (jpL, iErr, CROOT, 'AFEDVW')
      RETURN
      END
CCC_* [AFC] Coordinate interface
CCC_ & AFCwri  ## write tag/value tables
      subroutine AFCwri
     O    (iErr,
     I     CRT, idC, IFPl, IFPv)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, character) CRT*(*)
      _INTENT(IN, integer)   idC
      _INTENT(IN, integer)   IFPl, IFPv
      character CBASE*(32)
      iErr = 0
      if (CRT  .ne.' ') call DVTwta (iErr, 'CROOT', CRT,   ' ', IFPv)
      if (idC.ne.0) then
         call ACWtag (iErr, CBASE, idC)
         if (CBASE.ne.' ') call DVTwta (iErr, 'CBASE', CBASE, ' ', IFPv)
      endif
      RETURN
      END
CCC_ & AFCwgi  ## write tag/value tables (by id)  [old: ACVwgi]
      subroutine AFCwgi
     O    (iErr,
     I     CRT, idC, IFPl, IFPv, OLP)
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, character) CRT*(*)
      _INTENT(IN, integer)   idC
      _INTENT(IN, integer)   IFPl, IFPv
      _INTENT(IN, logical)   OLP
      character CBASE*(32)
      iErr = 0
      if (CRT  .ne.' ') call DVTwta (iErr, 'CROOT', CRT,   ' ', IFPv)
      call ACWtag (iErr, CBASE, idC)
      if (CBASE.ne.' ') call DVTwta (iErr, 'CBASE', CBASE, ' ', IFPv)
      call AFCwcs (iErr, idC, IFPl, IFPv)
      if (OLP) then
         call AFCwld (iErr, idC, IFPl, IFPv)
      endif
      RETURN
      END
CCC_ & AFCwld  ## write tag/value tables (LOOP)
      subroutine AFCwld
     O    (iErr,
     I     idC,  IFPl, IFPv)
      implicit none
c
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   idC
      _INTENT(IN, integer)   IFPl, IFPv
      integer LPa (3)
      integer jcdmy
c
      iErr = 0
c
      call ACCrfI (iErr, jcdmy, LPa, idC, 3, 'EL', IFPl)
      if (iErr.eq.0) then
         call DVTwti (iErr, 'LOOPI', LPa (1), ' ' ,IFPv)
         call DVTwti (iErr, 'LOOPB', LPa (2), ' ' ,IFPv)
         call DVTwti (iErr, 'LOOPO', LPa (3), ' ' ,IFPv)
      else
         iErr = 0
      endif
c
      RETURN
      END
CCC_ & AFCwcs  ## write tag/value tables (COSTR)
      subroutine AFCwcs
     O    (iErr,
     I     idC,  IFPl, IFPv)
      implicit none
c
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   idC
      _INTENT(IN, integer)   IFPl, IFPv
      integer jcdmy
c
      integer    LPR
      parameter (LPR = 32)
      integer    icPRM (LPR), NPR
      character  VS (LPR)*(24)
      character  VSS*(256)
      integer    jp
c
      iErr = 0
c
      if (iErr.eq.0) then
         call ACCchI (iErr, jcdmy, idC, 'XM', IFPl)
         if (iErr.eq.0.and.jcdmy.eq.0) then
            call DAtrcU (IFPl, 0, 'W/XM', 'AMVWCS')
            call ACWrdi (iErr, jcdmy, idC, IFPl)
         endif
         if (iErr.eq.0.and.jcdmy.ne.0) then
            call ACWdim (iErr, NPR, jcdmy)
            call ACCrfI (iErr, jcdmy, icPRM, idC, NPR, 'XM', IFPl)
            do jp = 1, MIN (LPR, NPR)
               call ACWtag (iErr, VS (jp), icPRM (jp))
            enddo
            call USCnst(VSS, ';', VS, NPR)
         endif
         call DVTwta (iErr, 'COSTR', VSS, ' ' ,IFPv)
      endif
c
      RETURN
      END
CCC_ & AFCwnb  ## Arpeggio/Coordinate/VIO report (follow n bases)
      subroutine AFCwnb
     O    (iErr,
     I     idCtgt, NF, CSW, CLS, VITEM, ipFI, iMA)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   idCtgt
      _INTENT(IN, integer)   NF
      _INTENT(IN, character) CSW*(*), CLS*(*), VITEM*(*)
      _INTENT(IN, integer)   ipFI (*),  iMA (*)
      integer ji, jb, j
CCC_  - Body
      iErr = 0
      jb   = idCtgt
      do j = 1, NF
         ji = jb
         call ACWbs1 (iErr, jb,  ji)
         if (jb.eq.0.or.iErr.ne.0) then
            iErr = -1
            goto 100
         endif
      enddo
 100  continue
      if (iErr.eq.0) then
         call AFCwbi
     O       (iErr,
     I        jb, idCtgt, CSW, CLS, VITEM, ipFI, iMA)
      endif
      RETURN
      END
CCC_ & AFCwrb  ## Arpeggio/Coordinate/VIO report (trace when cumulative)
      subroutine AFCwrb
     O    (iErr,
     I     idCtgt, CSW, CLS, VITEM, ipFI, iMA)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   idCtgt
      _INTENT(IN, character) CSW*(*), CLS*(*), VITEM*(*)
      _INTENT(IN, integer)   ipFI (*),  iMA (*)
      integer ji, jb
      integer jpL
CCC_  - Body
      iErr = 0
      jpL  = ipFI(AFI_FPL)
c
      jb   = idCtgt
      do
         call AGUqgi (iErr, ji, jb, jpL)
         if (iErr.ne.0) goto 100
         if (ji.eq.0) goto 100
         jb = ji
      enddo
 100  continue
c
      if (iErr.eq.0) then
         call AFCwbi
     O       (iErr,
     I        jb, idCtgt, CSW, CLS, VITEM, ipFI, iMA)
      endif
      RETURN
      END
CCC_ & AFCwbi  ## Arpeggio/Coordinate/VIO report (with base id)
      subroutine AFCwbi
     O    (iErr,
     I     idCbas, idCtgt, CSW, CLS, VITEM, ipFI, iMA)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   idCbas, idCtgt
      _INTENT(IN, character) CSW*(*), CLS*(*), VITEM*(*)
      _INTENT(IN, integer)   ipFI (*),  iMA (*)
c
      integer    Lcoor
      parameter (Lcoor = 32)
      integer    MTg, NTg, ITg
      integer    idT, jC,  N, Jofs
      integer    jt
      character  TagO*(Lcoor), TagB*(Lcoor), TagT*(Lcoor)
      integer    ACFt2c
c
      integer    kaDV (VIO_KPOLICY_MAX)
      character  saDV*(VIO_SPOLICY_LEN)
      character  FMT
      character  VI*(32)
c
      integer    IRT, IRN, KU
      integer    Mdim
c
      integer    jErr
c
      integer    nac
      integer    jfpL, jfpV
CCC_  - Body
      iErr = 0
      FMT  = ' '
      IRT  = 0
      KU   = 0
      call USMcpd (VI, VITEM, 'di')
      nac  = 0
      jfpL = ipFI (AFI_FPL)
      jfpV = ipFI (AFI_FPV)
c
      if (iErr.eq.0) call ACWtag (iErr, TagB, idCbas)
      if (iErr.eq.0) call ACWtag (iErr, TagT, idCtgt)
      if (iErr.eq.0) call ACWdim (iErr, Mdim, idCbas)
c
      call ACOntg (ITg,  NTg,  MTg)
c$$$      write (*, *) NTg, TagB, Mdim, idCbas
      do jt = 1, NTg
        idT = jt
        jC = ACFt2c (idT)
        call ACWkbc (jErr, jC, idCbas, 'D')
c$$$        write (*, *) jt, jErr, jC
        if (jErr.eq.0) then
           call ACWtag (jErr, TagO, jC)
           call ACWdim (jErr, N, jC)
           call ACWgO1 (jErr, Jofs, 0, jC)
           if (nac.eq.0) then
              call AFDudw
     O            (iErr,
     O             kaDV, saDV,
     I             CSW,  'S',  MDIM, CLS, TagB, VI, ipFI, iMA)
           endif
           if (iErr.eq.0) then
              call DVTwta (jErr, 'ITEM',  TagO,    ' ', jfpV)
              call DVTwta (jErr, 'GROUP', 'COOR',  ' ', jfpV)
              call DVTwta (jErr, 'CBASE', TagT,    ' ', jfpV)
              call DVTwta (jErr, 'CORG',  TagB,    ' ', jfpV)
           endif
           if (iErr.eq.0) then
              call ACDsdv
     O            (iErr, IRN,
     I             kaDV, saDV,
     I             IRT,  Jofs, N, KU, FMT, TagO)
           endif
           nac = nac + 1
        endif
      enddo
c
      if (nac.gt.0) then
         call DVFrep (jErr, kaDV, saDV, jfpL, jfpV)
      else
 101     format ('ACVWBI: no access ', I5, 1x, A)
         if (COND_N(jfpL)) then
            write (jfpL, 101) idCbas, _TRIM(TagB)
         else
            write (*,    101) idCbas, _TRIM(TagB)
         endif
      endif
CCC_  - final
      RETURN
      END
CCC_* [AFD] dvio with path-name generation
CCC_ & AFDwoI  ## one-time write/path generation/I [old:DVHwoI]
      subroutine AFDwoI
     O    (iErr,
     I     IV,    N,
     I     PDP,   CLS,   CTGRY, VITEM,  TXT, ipFI, iMA)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   N
      _INTENT(IN, integer)   IV (N)
      _INTENT(IN, character) PDP*(*)
      _INTENT(IN, character) CLS*(*), CTGRY*(*), VITEM*(*)
      _INTENT(IN, character) TXT*(*)
      _INTENT(IN, integer)   ipFI (*), iMA (*)
c
      character FNM *(OPT_FILENAME_MAX)
c
      integer   jfpL, jfpV
CCC_  - Body
      iErr  = 0
c
      jfpL = ipFI (AFI_FPL)
      jfpV = ipFI (AFI_FPV)
c
      if (iErr.eq.0) then
         call AFDgen
     O       (iErr,
     O        FNM,
     I        CLS, CTGRY, VITEM, ' ', ipFI)
      endif
      if (iErr.eq.0) then
         call DVSwoI
     O       (iErr,
     I        IV,    N,
     I        PDP,   FNM, TXT, jfpL, jfpV, iMA)
      endif
c
      RETURN
      END
CCC_ & AFDwoS  ## one-time write/path generation/S [old:DVHwoS]
      subroutine AFDwoS
     O    (iErr,
     I     SV,    N,
     I     PDP,   CLS,   CTGRY, VITEM,  TXT, ipFI, iMA)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   N
      _INTENT(IN, _REALSTD)  SV (N)
      _INTENT(IN, character) PDP*(*)
      _INTENT(IN, character) CLS*(*), CTGRY*(*), VITEM*(*)
      _INTENT(IN, character) TXT*(*)
      _INTENT(IN, integer)   ipFI (*), iMA (*)
c
      character FNM *(OPT_FILENAME_MAX)
c
      integer   jfpL, jfpV
CCC_  - Body
      iErr  = 0
c
      jfpL = ipFI (AFI_FPL)
      jfpV = ipFI (AFI_FPV)
c
      if (iErr.eq.0) then
         call AFDgen
     O       (iErr,
     O        FNM,
     I        CLS, CTGRY, VITEM, ' ', ipFI)
      endif
      if (iErr.eq.0) then
         call DVSwoS
     O       (iErr,
     I        SV,    N,
     I        PDP,   FNM, TXT, jfpL, jfpV, iMA)
      endif
c
      RETURN
      END
CCC_ & AFDudw  ## check-in with path generation/udw [old:DVHudw]
      subroutine AFDudw
     O    (iErr,
     O     kaDV,  saDV,
     I     PDP,   CTYP,  N,    CLS, CTGRY, VITEM,
     I     ipFI,  iMA)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   kaDV  (*)
      _INTENT(OUT,character) saDV *(*)
      _INTENT(IN, character) PDP  *(*), CTYP*(*)
      _INTENT(IN, integer)   N
      _INTENT(IN, character) CLS*(*), CTGRY*(*), VITEM*(*)
      _INTENT(IN, integer)   ipFI (*), iMA (*)
c
      character FNM *(OPT_FILENAME_MAX)
c
      integer   jfpL, jfpV
CCC_  - Body
      iErr  = 0
c
      jfpL = ipFI (AFI_FPL)
      jfpV = ipFI (AFI_FPV)
c
      if (iErr.eq.0) then
         call AFDgen
     O       (iErr,
     O        FNM,
     I        CLS, CTGRY, VITEM, ' ', ipFI)
      endif
      if (iErr.eq.0) then
         call DVSudw
     O       (iErr,
     O        kaDV,  saDV,
     I        PDP,   CTYP,   N,    FNM, jfpL, jfpV, iMA)
      endif
      call DAtrcU (jfpL, iErr, FNM, 'AFDUDW')
      RETURN
      END
CCC_ & AFDgen  ## path-name generator [old:DVSgpn]
      subroutine AFDgen
     O    (iErr,
     O     FNM,
     I     CLS, CTGRY, VITEM, FILE, ipFI)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,character) FNM*(*)
      _INTENT(IN, character) CLS*(*), CTGRY*(*), VITEM*(*)
      _INTENT(IN, character) FILE*(*)
      _INTENT(IN, integer)   ipFI (*)
      integer    jCls
      integer    MT
      parameter (MT = 5)
      integer    NT
      character  TagA (MT)*(16)
      character  ValA (MT)*(OPT_FILENAME_MAX)
      integer    jfpL
CCC_  - Body
      iErr = 0
c
      jfpL = ipFI (AFI_FPL)
c
      if (iErr.eq.0) call DPBrgC (iErr, jCls, CLS)
      if (iErr.eq.0) then
         call DPUset (NT, TagA, ValA, MT, VITEM)
         if (CTGRY.ne.' ')
     $        call DPUadd (NT, TagA, ValA, MT, 'CATEGORY', CTGRY)
         FNM = FILE
         call DPUptC (iErr, FNM, jCls, TagA, ValA, NT, jfpL)
      else
 101     format ('AFDGEN: ERROR IN CLASS REG ', A, 1x, I5)
         if      (COND_N(jfpL)) then
            write (jfpL, 101) CLS, iErr
         else if (COND_S(jfpL)) then
            write (*,    101) CLS, iErr
         endif
         iErr = -128
         FNM  = ' '
      endif
      RETURN
      END
CCC_* [AFU] utilities
CCC_ & AFUnvp  ## reset property cluster (default never)
      subroutine AFUnvp
     O    (ipFI)
      implicit none
      _INTENT(OUT,integer) ipFI (*)
      call AFUrsp (ipFI, AFSW_NEVER)
      RETURN
      END
CCC_ & AFUrsp  ## reset property cluster
      subroutine AFUrsp
     O    (ipFI,
     I     KSW)
      implicit none
      _INTENT(OUT,integer) ipFI (*)
      _INTENT(IN, integer) KSW
      ipFI (AFI_FPI) = -1
      ipFI (AFI_FPN) = -1
      ipFI (AFI_FPL) = -1
      ipFI (AFI_FPV) = -1
c$$$      ipFI (AFI_KSW) = AFSW_NORMAL
      ipFI (AFI_KSW) = KSW
      RETURN
      END
CCC_ & AFUifp  ## set file unit cluster
      subroutine AFUifp
     O    (ipFI,
     I     ipI, ipN, ipL, ipV)
      implicit none
      _INTENT(OUT,integer) ipFI (*)
      _INTENT(IN, integer) ipI, ipN, ipL, ipV
      ipFI (AFI_FPI) = ipI
      ipFI (AFI_FPN) = ipN
      ipFI (AFI_FPL) = ipL
      ipFI (AFI_FPV) = ipV
      RETURN
      END
CCC_ & AFUqip  ## inquire file unit cluster
      subroutine AFUqip
     O    (ipX,
     I     Tag, ipFI)
      implicit none
      _INTENT(OUT,integer)   ipX
      _INTENT(IN, integer)   ipFI (*)
      _INTENT(IN, character) Tag
      integer j
      j = INDEX (AFI_FPSTR, Tag (1:1))
      if (j.lt.1) then
         ipX = -1
      else
         ipX = ipFI (j)
      endif
      RETURN
      END
CCC_& AFINTF  ## IcIES/Arpeggio/File interfaces announcement
      subroutine AFINTF (STRA, STRB, IOP)
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
CCC_@ AFTEST  ## Arpeggio/File test
#if TEST_AFINTF
      program AFTEST
CCC_ + Test suites
CC::   SOURCES aedlra.F acorms.F
CCC_ + Declaration
#include "odevid.h"  /* MPI table */
      implicit none
      integer iErr
      integer ipA (LOG_CHANNEL_MAX)
      integer iMA (MAX_MPI_ATTR)
#define AKW_CLS 'V'
CCC_ + Body
      call DDcapo
     O    (iErr,
     I     2, ' ', 'O', _FNAME, -1)
      if (iErr.eq.0) then
         call DLCmng (ipA, 't')
         call DVHrgC (iErr, AKW_CLS, ' ', ' ', ipA)
      endif
      if (iErr.eq.0) then
c$$$         call AKWtma (iMA)
c$$$         call AFTESTmain (iErr, ipA, iMA)
      endif
      call DevFin (iErr)
      STOP
      END
#endif /* TEST_AFINTF */
CCC_* obsolete
CCC_ + begin
#if 0 /* obsolete */
CCC_ + end obsolete
#endif /* 0 obsolete */
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
