C unison/uxunit.F --- IcIES/Unison/Unit-Dimension control
C Maintainer:  SAITO Fuyuki
C Created: Tue Feb  4 2003
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2020/09/15 11:44:01 fuyuki uxunit.F>'
#define _FNAME 'unison/uxunit.F'
#define _REV   'Snoopy0.9'
CCC_! MANIFESTO
C
C Copyright (C) 2010--2020
C           Japan Agency for Marine-Earth Science and Technology
C
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
CCC_! Description
CCC_ + /FDM/ scaling definition
CC      Linear unit conversions are declared with three numbers, called FDM table,
CC      which stands for Factor/Denominator/Magnitude.
CC
CC      ex.
CC         mm  := [F:1,  D:1,  M:-3] m    (mm  := 1  / 1  * 10^-3 m)
CC         day := [F:24, D:1,  M:0]  hr   (day := 24 / 1  * 10^0  hr)
CC         mon := [F:1,  D:12, M:0]  yr   (mon := 1  / 12 * 10^0  yr)
CC
CC      Non-linear unit conersions can be also declared, where FDM,
CC      is internally all set as 0.
CC
CC      ex.
CC         degC:=  [0, 0, 0] K
CC
CCC_ + decomposition and conversion
CC
CC     /Decomposition/ is to deduce a unique sequence of primitive units
CC    with a scaling array to multiply, from given (single or compound) units.
CC    For example, /86400 s/ from /day/, /1000 kg m^-1 s^-2/ from /kPa/ etc.
CC
CC    /Conversion/ from one unit to another is achieved through decomposition.
CC    First, /SRC DEST^-1/ is registered as a compound.  Then, this compound
CC    is decomposed.  If the dimension of SRC and that of DEST are identical,
CC    then the final decomposed unit is *DIMENSIONLESS*.
CC
CCC_* Macros
CCC_ + include
#include "ofdlct.h" /* fortran dialect */
#include "ologfm.h" /* logging */
#include "ounits.h"
CCC_ + Buffer configuration
#ifndef    OPT_UNIT_LEN             /* length of unit atom */
#  define  OPT_UNIT_LEN             32
#endif
#ifndef    OPT_UNIT_SEQUENCE_MAX    /* number of atom in unit sequence */
#  define  OPT_UNIT_SEQUENCE_MAX    64
#endif
#ifndef    OPT_UNIT_EXPANSION_LOOP  /* to fail */
#  define  OPT_UNIT_EXPANSION_LOOP  1024
#endif
#ifndef    OPT_UNIT_HASH_BASE       /* default hash base */
#  define  OPT_UNIT_HASH_BASE       13
#endif
#ifndef    OPT_UNIT_HASH_BASE_FINAL /* default hash base at bottom */
#  define  OPT_UNIT_HASH_BASE_FINAL 17
#endif
CCC_ + Dimension/Unit configuration
CCC_  - coeff-power table
#define _CPTBL_CF    1 /* constant */
#define _CPTBL_POW   2 /* power */
#define _CPTBL_MAX   2
CCC_  - id-power table
#define _IPTBL_ID    1 /* unit id */
#define _IPTBL_POW   2 /* power */
#define _IPTBL_MAX   2
CCC_  - coefficients array
#define _COEFF_F    1
#define _COEFF_D    2
#define _COEFF_M    3
#define _COEFF_MAX  3
CCC_  - single attributes
#define _UATTR_BASE  1 /* base */
#define _UATTR_DEC   2 /* decomposite */
#define _UATTR_MAX   2
CCC_  - decomposition attributes
#define _DATTR_BASE  1 /* derived unit */
#define _DATTR_SRC   2 /* source unit */
#define _DATTR_MAX   2
CCC_  - compound attributes
#define _CATTR_POS   1 /* start position */
#define _CATTR_NUM   2 /* number of elements */
#define _CATTR_DEC   3 /* decomposite */
#define _CATTR_MAX   3
CCC_ + Special
#define _ID_DIMENSIONLESS  0
#define _ID_PRIMITIVE     -1
#define _ID_WAIT          -9
#define _ID_UNDEF        -99
CCC_ + Special characters
#define _CHAR_DIV    '/'   /* division operator */
#define _CHAR_POW    '^'   /* exponent operator */
#define _CHAR_IGNORE ';'   /* ignored separator */
CCC_ + Attribute cluster
CC integer attributes allocation
CC           basic          _OFF_IATTR
CC   [P, ID] single         _UATTR_MAX * LS
CC   [P, ID] decomposition  _DATTR_MAX * LD
CC   [P, ID] compound       _CATTR_MAX * LC
CC   [P, ID] table          _IPTBL     * LT
#define _TYPE(VI)       VI(1) /* reserved */
#define _STAT(VI)       VI(2) /* status */
#define _MINUI(VI)      VI(3)
#define _MEMUI(VI)      VI(4) /* maximum single units */
#define _MINDI(VI)      VI(5)
#define _MEMDI(VI)      VI(6) /* maximum decomposition */
#define _MINCI(VI)      VI(7)
#define _MEMCI(VI)      VI(8) /* maximum compound units */
#define _IDEC(VI)       VI(9) /* current decomposition id */
#define _LCTB(VI)       VI(10) /* maximum compound table */
#define _ICTB(VI)       VI(11) /* current compound table */
#define _KSNG0(VI)      VI(12) /* offset attributes */
#define _KDEC0(VI)      VI(13)
#define _KCOM0(VI)      VI(14)
#define _KCTB0(VI)      VI(15)
#define _MAIS(VI)       VI(16) /* number of attributes */
#define _MAID(VI)       VI(17)
#define _MAIC(VI)       VI(18)
#define _MCTB(VI)       VI(19)
#define _MATS(VI)       VI(20) /* reserved */
#define _MATA(VI)       VI(21) /* reserved */
#define _HMAXU(VI)      VI(22)
#define _HMAXC(VI)      VI(23)
#define _LOGU(VI)       VI(24)
#define _HASHB(VI)      VI(25)
#define _HASHF(VI)      VI(26)
#define _OFF_IATTR      26
#define _JSNG(VI,P,ID)  _KSNG0(VI)+P+(ID)*_MAIS(VI)
#define _JDEC(VI,P,ID)  _KDEC0(VI)+P+(ID)*_MAID(VI)
#define _JCOM(VI,P,ID)  _KCOM0(VI)+P+(ID)*_MAIC(VI)
#define _JCTB(VI,P,ID)  _KCTB0(VI)+P+(ID)*_MCTB(VI)
#define _KSNG(VI,P,ID)  VI(_JSNG(VI,P,ID))  /* single unit attribute [ID,P] */
#define _KDEC(VI,P,ID)  VI(_JDEC(VI,P,ID))  /* decomposition attribute [ID,P] */
#define _KCOM(VI,P,ID)  VI(_JCOM(VI,P,ID))  /* compound unit attribute [ID,P] */
#define _KCTB(VI,P,ID)  VI(_JCTB(VI,P,ID))  /* compound table definition [ID,P] */
CC
#define _USTR(VS,ID)    VS(ID)
#define _CFTS(VS,P,ID)   VS(P+(ID-1)*_COEFF_MAX) /* coeff for single */
#define _CFTD(VS,P,ID)   VS(P+(ID-1)*_COEFF_MAX) /* coeff for decomposition */
CCC_ + Debug
#if TEST_UXUNIT
c$$$#  define _DBG_UNIT_PARSER
#endif
CCC_* [UXS] Unit shell
CCC_ & UXSdpc  ## Unit/Shell: define primitive unit and class
CC     Declare new Unit and Ucls as its alias
      subroutine UXSdpc
     O    (iErr,
     I     Uname, Ucls,
     M     KU,    SU,    AU)
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   character) Uname*(*)
      _INTENT(IN,   character) Ucls *(*)
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
      integer  idU, idC
      _REALSTD FDM (UXC_MAX)
c
      FDM(UXC_F) = 1.d0
      FDM(UXC_D) = 1.d0
      FDM(UXC_M) = 0.d0
      call UXCreg (iErr, idU, Uname, FDM, ' ', KU,SU,AU)
      if (iErr.eq.0) then
         if (Ucls.ne.' ') then
            call UXCnew (iErr, idC, Ucls, FDM, idU, KU,SU,AU)
         endif
      endif
      RETURN
      END
CCC_ & UXSdft  ## Unit/Shell: define with FDM table
      subroutine UXSdft
     O    (iErr,
     I     Uname, FDM, Ubase,
     M     KU,    SU,  AU)
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   character) Uname*(*)
      _INTENT(IN,   character) Ubase*(*)
      _INTENT(IN,   _REALSTD)  FDM(*)
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
      integer idU
c
      call UXCreg (iErr, idU, Uname, FDM, Ubase, KU,SU,AU)
      RETURN
      END
CCC_ & UXSdds  ## Unit/Shell: define by denominator
      subroutine UXSdds
     O    (iErr,
     I     Uname, D,  Ubase,
     M     KU,    SU, AU)
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   character) Uname*(*)
      _INTENT(IN,   character) Ubase*(*)
      _INTENT(IN,   _REALSTD)  D
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
      integer idU
c
      call UXCdnm (iErr, idU, Uname, D, Ubase, KU,SU,AU)
      RETURN
      END
CCC_ & UXSddi  ## Unit/Shell: define by integer denominator
      subroutine UXSddi
     O    (iErr,
     I     Uname, IDNM, Ubase,
     M     KU,    SU,   AU)
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   character) Uname*(*)
      _INTENT(IN,   character) Ubase*(*)
      _INTENT(IN,   integer)   IDNM
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
      integer idU
c
      call UXCdni (iErr, idU, Uname, IDNM, Ubase, KU,SU,AU)
      RETURN
      END
CCC_ & UXSdfs  ## Unit/Shell: define by factor
      subroutine UXSdfs
     O    (iErr,
     I     Uname, F,  Ubase,
     M     KU,    SU, AU)
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   character) Uname*(*)
      _INTENT(IN,   character) Ubase*(*)
      _INTENT(IN,   _REALSTD)  F
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
      integer idU
c
      call UXCfct (iErr, idU, Uname, F, Ubase, KU,SU,AU)
      RETURN
      END
CCC_ & UXSdfi  ## Unit/Shell: define by integer factor
      subroutine UXSdfi
     O    (iErr,
     I     Uname, IFCT, Ubase,
     M     KU,    SU,   AU)
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   character) Uname*(*)
      _INTENT(IN,   character) Ubase*(*)
      _INTENT(IN,   integer)   IFCT
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
      integer idU
c
      call UXCfci (iErr, idU, Uname, IFCT, Ubase, KU,SU,AU)
      RETURN
      END
CCC_ & UXSdms  ## Unit/Shell: define by magnitude
      subroutine UXSdms
     O    (iErr,
     I     Uname, E,  Ubase,
     M     KU,    SU, AU)
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   character) Uname*(*)
      _INTENT(IN,   character) Ubase*(*)
      _INTENT(IN,   _REALSTD)  E
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
      integer idU
c
      call UXCmgn (iErr, idU, Uname, E, Ubase, KU,SU,AU)
      RETURN
      END
CCC_ & UXSdmi  ## Unit/Shell: define by integer magnitude
      subroutine UXSdmi
     O    (iErr,
     I     Uname, IMAG, Ubase,
     M     KU,    SU,   AU)
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   character) Uname*(*)
      _INTENT(IN,   character) Ubase*(*)
      _INTENT(IN,   integer)   IMAG
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
      integer idU
c
      call UXCmgi (iErr, idU, Uname, IMAG, Ubase, KU,SU,AU)
      RETURN
      END
CCC_ & UXSdal  ## Unit/Shell: define alias
      subroutine UXSdal
     O    (iErr,
     I     Uname, Ubase,
     M     KU,    SU,    AU)
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   character) Uname*(*)
      _INTENT(IN,   character) Ubase*(*)
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
      integer idU
c
      call UXCali (iErr, idU, Uname, Ubase, KU,SU,AU)
      RETURN
      END
CCC_ & UXSdco  ## Unit/Shell: define constant (dimensionless)
      subroutine UXSdco
     O    (iErr,
     I     Uname, C,
     M     KU,    SU,    AU)
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   character) Uname*(*)
      _INTENT(IN,   _REALSTD)  C
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
      integer idU
c
      call UXCcon (iErr, idU, Uname, C, KU,SU,AU)
      RETURN
      END
CCC_ & UXSdnl  ## Unit/Shell: define non-linear
      subroutine UXSdnl
     O    (iErr,
     I     Uname, Ubase,
     M     KU,    SU,    AU)
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   character) Uname*(*)
      _INTENT(IN,   character) Ubase*(*)
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
      integer idU
c
      call UXCnln (iErr, idU, Uname, Ubase, KU,SU,AU)
      RETURN
      END
CCC_ & UXSdxu  ## Unit/Shell: define conversion
      subroutine UXSdxu
     O    (iErr,
     I     Usrc, Udst,
     M     KU,   SU,    AU)
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   character) Usrc*(*)
      _INTENT(IN,   character) Udst*(*)
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
      integer idX
c
      call UXCxps (iErr, idX, Usrc, Udst, KU,SU,AU)
      RETURN
      END
CCC_ & UXSdec  ## Unit/Shell: define decomposition
      subroutine UXSdec
     O    (iErr,
     I     Ustr,
     M     KU,    SU,    AU)
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   character) Ustr*(*)
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
      integer idU, idX
c
      iErr = 0
      if (iErr.eq.0) call UXCprc (iErr, idU, Ustr, KU,SU,AU)
c     fail if exist unknown units
      if (iErr.gt.0) iErr = ERR_UNIT_INVALID_COMPOUND
      if (iErr.eq.0) call UXCdcm (iErr, idX, idU, KU,SU,AU)
      RETURN
      END
CCC_ & UXSqfx  ## Unit/Shell: get conversion table
      subroutine UXSqfx
     O    (iErr,
     M     FDM,
     I     Usrc, Udst, KLV,
     M     KU,   SU,   AU)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(OUT,  _REALSTD)  FDM(*)
      _INTENT(IN,   character) Usrc*(*), Udst*(*)
      _INTENT(IN,   integer)   KLV
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
      integer idX
CCC_  - Body
      iErr = 0
      if (iErr.eq.0) call UXCxps (iErr, idX, Usrc, Udst, KU,SU,AU)
      call UXCftb (iErr, FDM, idX, .TRUE., KLV, KU,SU)
      RETURN
      END
CCC_ & UXSqxr  ## Unit/Shell: check relation between two units
      subroutine UXSqxr
     O    (iDstt, iCstt,
     I     Usrc,  Udst,
     M     KU,    SU,    AU)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iDstt,    iCstt
      _INTENT(IN,   character) Usrc*(*), Udst*(*)
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
      integer jErr
      integer idUs, idUd
CCC_  - Body
      jErr = 0
      if (jErr.ge.0) call UXCprc (jErr, idUs, Usrc, KU,SU,AU)
      if (jErr.ge.0) call UXCprc (jErr, idUd, Udst, KU,SU,AU)
      if (jErr.ge.0) call UXCrch (iDstt, iCstt, idUs, idUd, KU,SU,AU)
      RETURN
      END
CCC_ & UXScss  ## Unit/Shell: convert (single/assign)
      subroutine UXScss
     O    (iErr,
     O     VD, Udst,
     I     VS, Usrc, KSW,
     M     KU, SU,   AU)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)     iErr
      _INTENT(OUT,_REALSTD)    VD
      _INTENT(IN, _REALSTD)    VS
      _INTENT(IN, character)   Usrc*(*), Udst*(*)
      _INTENT(IN, integer)     KSW
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
CCC_  - Body
      iErr = 0
      VD   = VS
      call UXSxss (iErr, VD, Usrc, Udst, KSW, KU,SU,AU)
      RETURN
      END
CCC_ & UXScsa  ## Unit/Shell: convert (array/assign)
      subroutine UXScsa
     O    (iErr,
     O     VD, Udst,
     I     VS, Usrc, NV, KSW,
     M     KU, SU,   AU)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(OUT,  _REALSTD)  VD(*)
      _INTENT(IN,   _REALSTD)  VS(*)
      _INTENT(IN,   character) Usrc*(*), Udst*(*)
      _INTENT(IN,   integer)   NV
      _INTENT(IN,   integer)   KSW
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
      integer j
CCC_  - Body
      iErr = 0
      do j = 1, NV
         VD(j) = VS(j)
      enddo
      call UXSxsa (iErr, VD, NV, Usrc, Udst, KSW, KU,SU,AU)
      RETURN
      END
CCC_ & UXSxss  ## Unit/Shell: convert (single/modify)
      subroutine UXSxss
     O    (iErr,
     M     VS,
     I     Usrc, Udst, KSW,
     M     KU,   SU,   AU)
CCC_  - Description
CC         KSW positive or zero :: src to dst conversion
CC         KSW negative         :: dst to src conversion (reverse)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,_REALSTD)  VS
      _INTENT(IN,   character) Usrc*(*), Udst*(*)
      _INTENT(IN,   integer)   KSW
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
      integer idX
CCC_  - Body
      iErr = 0
      call UXCxps (iErr, idX, Usrc, Udst, KU,SU,AU)
      if (iErr.eq.0) then
         if (KSW.lt.0) then
            call UXCrvc (iErr, VS, idX, KU,SU)
         else
            call UXCcnv (iErr, VS, idX, KU,SU)
         endif
      endif
      RETURN
      END
CCC_ & UXSxsa  ## Unit/Shell: convert (array/modify)
      subroutine UXSxsa
     O    (iErr,
     M     VS,
     I     NV, Usrc, Udst, KSW,
     M     KU, SU,   AU)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,_REALSTD)  VS(*)
      _INTENT(IN,   character) Usrc*(*), Udst*(*)
      _INTENT(IN,   integer)   NV
      _INTENT(IN,   integer)   KSW
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
      integer idX
CCC_  - Body
      iErr = 0
      call UXCxps (iErr, idX, Usrc, Udst, KU,SU,AU)
      if (iErr.eq.0) then
         if (KSW.lt.0) then
            call UXCrca (iErr, VS, NV, idX, KU,SU)
         else
            call UXCcva (iErr, VS, NV, idX, KU,SU)
         endif
      endif
      RETURN
      END
CCC_ & UXSrep  ## Unit/Shell: report
      subroutine UXSrep (iErr, KU,SU,AU)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   KU(*)
      _INTENT(IN, _REALSTD)  SU(*)
      _INTENT(IN, character) AU(*)*(*)
c
      call UXMrep(iErr, -999,  KU,SU,AU)
      RETURN
      END
CCC_* [UXC] Unit core
CCC_ & UXCcnv  ## Unit/Core: unit conversion
      subroutine UXCcnv
     O    (iErr,  VS,
     I     idU,
     I     KU,    SU)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
      _INTENT(INOUT,_REALSTD) VS
      _INTENT(IN,   integer)  idU
      _INTENT(IN,   integer)  KU(*)
      _INTENT(IN,   _REALSTD) SU(*)
      _REALSTD FDM(UXC_MAX)
      _REALSTD F, D
CCC_  - Body
      iErr = 0
      call UXCftb (iErr, FDM, idU, .TRUE., UXLEV_FD, KU,SU)
      if (iErr.eq.0) then
         F = FDM(UXC_F)
         D = FDM(UXC_D)
         VS = (VS * F) / D
      endif
      RETURN
      END
CCC_ & UXCrvc  ## Unit/Core: unit conversion reverse
      subroutine UXCrvc
     O    (iErr,  VS,
     I     idU,
     I     KU,    SU)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
      _INTENT(INOUT,_REALSTD) VS
      _INTENT(IN,   integer)  idU
      _INTENT(IN,   integer)  KU(*)
      _INTENT(IN,   _REALSTD) SU(*)
      _REALSTD FDM(UXC_MAX)
      _REALSTD F, D
CCC_  - Body
      iErr = 0
      call UXCftb (iErr, FDM, idU, .TRUE., UXLEV_FD, KU,SU)
      if (iErr.eq.0) then
         F = FDM(UXC_F)
         D = FDM(UXC_D)
         VS = (VS * D) / F
      endif
      RETURN
      END
CCC_ & UXCcva  ## Unit/Core: unit conversion (array)
      subroutine UXCcva
     O    (iErr,  VS,
     I     NV,    idU,
     I     KU,    SU)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
      _INTENT(INOUT,_REALSTD) VS (*)
      _INTENT(IN,   integer)  idU
      _INTENT(IN,   integer)  NV
      _INTENT(IN,   integer)  KU(*)
      _INTENT(IN,   _REALSTD) SU(*)
      _REALSTD FDM(UXC_MAX)
      integer j
      _REALSTD F, D
CCC_  - Body
      iErr = 0
      call UXCftb (iErr, FDM, idU, .TRUE., UXLEV_FD, KU,SU)
      if (iErr.eq.0) then
         F = FDM(UXC_F)
         D = FDM(UXC_D)
         do j = 1, NV
            VS(j) = (VS(j) * F) / D
         enddo
      endif
      RETURN
      END
CCC_ & UXCrvc  ## Unit/Core: unit conversion reverse (array)
      subroutine UXCrca
     O    (iErr,  VS,
     I     NV,    idU,
     I     KU,    SU)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
      _INTENT(INOUT,_REALSTD) VS (*)
      _INTENT(IN,   integer)  idU
      _INTENT(IN,   integer)  NV
      _INTENT(IN,   integer)  KU(*)
      _INTENT(IN,   _REALSTD) SU(*)
      _REALSTD FDM(UXC_MAX)
      _REALSTD F, D
      integer j
CCC_  - Body
      iErr = 0
      call UXCftb (iErr, FDM, idU, .TRUE., UXLEV_FD, KU,SU)
      if (iErr.eq.0) then
         F = FDM(UXC_F)
         D = FDM(UXC_D)
         do j = 1, NV
            VS(j) = (VS(j) * D) / F
         enddo
      endif
      RETURN
      END
CCC_ & UXCrch  ## Unit/Core: check relation
      subroutine UXCrch
     O    (iDstt, iCstt,
     I     idUs,  idUd,
     M     KU,    SU,    AU)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iDstt, iCstt
      _INTENT(IN,   integer)   idUd,  idUs
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
      integer idX
      integer  jErr
CCC_  - Body
      jErr  = 0
      call UXCxrg (jErr, idX, idUs, idUd, KU,SU,AU)
      if (jErr.eq.0) then
         call UXCdch(iDstt, iCstt, idX, KU,SU)
      else
         iDstt = ERR_UNIT_PANIC
         iCstt = jErr
      endif
      RETURN
      END
CCC_ & UXCdch  ## Unit/Core: check decomposition result
      subroutine UXCdch
     O    (iDstt, iCstt,
     I     idU,
     I     KU,    SU)
CCC_  - Description
CC        Return negative error number or unit id of idU decomposition
CC       as iDstt, such that iDstt = 0 = _ID_DIMENSIONLESS if the same dimension.
CC        Return iCstt as conversion characteristics:  0 if non-linear,
CC       1 if identical, 2 if different.
CC      -1 if identical/negative, -2 if magnitude/sign both different
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iDstt, iCstt
      _INTENT(IN, integer)   idU
      _INTENT(IN, integer)   KU(*)
      _INTENT(IN, _REALSTD)  SU(*)
      integer  idB
      _REALSTD FDM (UXC_MAX), F
      integer  jErr
CCC_  - Body
      jErr  = 0
      iDstt = 0
      iCstt = 0
      if (jErr.eq.0) then
         call UXCftb (jErr, FDM, idU, .TRUE., UXLEV_F, KU,SU)
      endif
      if (jErr.eq.0) then
         F = FDM(UXC_F)
         if (F.eq. 1.d0) then
            iCstt = +1
         else if (F.eq. - 1.d0) then
            iCstt = -1
         else if (F.eq. 0.d0) then
            iCstt = 0
         else if (F.lt. 0.d0) then
            iCstt = -2
         else
            iCstt = +2
         endif
      endif
      if (jErr.eq.0) then
         call UXAgbi(jErr, idB, idU, KU)
      endif
      if (jErr.eq.0) then
         iDstt = idB
      endif
      if (jErr.lt.0) then
         iDstt = jErr
         iCstt = 0
      else if (jErr.gt.0) then
         iDstt = ERR_UNIT_PANIC
         iCstt = jErr
      endif
      RETURN
      END
CCC_ & UXCdnm  ## Unit/Core: unit registration with denominator
      subroutine UXCdnm
     O    (iErr,  idU,
     I     Uname, D,   Ubase,
     M     KU,    SU,  AU)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(OUT,  integer)   idU
      _INTENT(IN,   character) Uname *(*)
      _INTENT(IN,   character) Ubase *(*)
      _INTENT(IN,   _REALSTD)  D
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
      _REALSTD FDM(UXC_MAX)
CCC_  - Body
      FDM(UXC_F) = 1.d0
      FDM(UXC_D) = D
      FDM(UXC_M) = 0.d0
      call UXCreg (iErr, idU, Uname, FDM, Ubase, KU,SU,AU)
      RETURN
      END
CCC_ & UXCdni  ## Unit/Core: unit registration with integer denominator
      subroutine UXCdni
     O    (iErr,  idU,
     I     Uname, IDNM, Ubase,
     M     KU,    SU,   AU)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(OUT,  integer)   idU
      _INTENT(IN,   character) Uname *(*)
      _INTENT(IN,   character) Ubase *(*)
      _INTENT(IN,   integer)   IDNM
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
CCC_  - Body
      call UXCdnm (iErr, idU, Uname, _XREALS(IDNM), Ubase, KU,SU,AU)
      RETURN
      END
CCC_ & UXCfct  ## Unit/Core: unit registration with factor
      subroutine UXCfct
     O    (iErr,  idU,
     I     Uname, F,   Ubase,
     M     KU,    SU,  AU)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(OUT,  integer)   idU
      _INTENT(IN,   character) Uname *(*)
      _INTENT(IN,   character) Ubase *(*)
      _INTENT(IN,   _REALSTD)  F
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
      _REALSTD FDM(UXC_MAX)
CCC_  - Body
      FDM(UXC_F) = F
      FDM(UXC_D) = 1.d0
      FDM(UXC_M) = 0.d0
      call UXCreg (iErr, idU, Uname, FDM, Ubase, KU,SU,AU)
      RETURN
      END
CCC_ & UXCfci  ## Unit/Core: unit registration with integer factor
      subroutine UXCfci
     O    (iErr,  idU,
     I     Uname, IFCT, Ubase,
     M     KU,    SU,   AU)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(OUT,  integer)   idU
      _INTENT(IN,   character) Uname *(*)
      _INTENT(IN,   character) Ubase *(*)
      _INTENT(IN,   integer)   IFCT
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
CCC_  - Body
      call UXCfct (iErr, idU, Uname, _XREALS(IFCT), Ubase, KU,SU,AU)
      RETURN
      END
CCC_ & UXCmgn  ## Unit/Core: unit registration with magnitude
      subroutine UXCmgn
     O    (iErr,  idU,
     I     Uname, E,   Ubase,
     M     KU,    SU,  AU)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(OUT,  integer)   idU
      _INTENT(IN,   character) Uname *(*)
      _INTENT(IN,   character) Ubase *(*)
      _INTENT(IN,   _REALSTD)  E
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
      _REALSTD FDM(UXC_MAX)
CCC_  - Body
      FDM(UXC_F) = 1.d0
      FDM(UXC_D) = 1.d0
      FDM(UXC_M) = E
      call UXCreg (iErr, idU, Uname, FDM, Ubase, KU,SU,AU)
      RETURN
      END
CCC_ & UXCmgi  ## Unit/Core: unit registration with integer magnitude
      subroutine UXCmgi
     O    (iErr,  idU,
     I     Uname, IM,   Ubase,
     M     KU,    SU,   AU)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(OUT,  integer)   idU
      _INTENT(IN,   character) Uname *(*)
      _INTENT(IN,   character) Ubase *(*)
      _INTENT(IN,   integer)   IM
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
      _REALSTD E
CCC_  - Body
      E = _XREALS(IM)
      call UXCmgn (iErr, idU, Uname, E, Ubase, KU,SU,AU)
      RETURN
      END
CCC_ & UXCali  ## Unit/Core: unit registration alias
      subroutine UXCali
     O    (iErr,  idU,
     I     Uname, Ubase,
     M     KU,    SU,    AU)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(OUT,  integer)   idU
      _INTENT(IN,   character) Uname *(*)
      _INTENT(IN,   character) Ubase *(*)
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
      _REALSTD FDM(UXC_MAX)
CCC_  - Body
      FDM(UXC_F) = 1.d0
      FDM(UXC_D) = 1.d0
      FDM(UXC_M) = 0.d0
      call UXCreg (iErr, idU, Uname, FDM, Ubase, KU,SU,AU)
      RETURN
      END
CCC_ & UXCcon  ## Unit/Core: unit registration dimensionless
      subroutine UXCcon
     O    (iErr,  idU,
     I     Uname, C,
     M     KU,    SU,    AU)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(OUT,  integer)   idU
      _INTENT(IN,   character) Uname *(*)
      _INTENT(IN,   _REALSTD)  C
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
      _REALSTD FDM(UXC_MAX)
CCC_  - Body
      FDM(UXC_F) = C
      FDM(UXC_D) = 1.d0
      FDM(UXC_M) = 0.d0
      call UXCnew(iErr, idU, Uname, FDM, _ID_DIMENSIONLESS, KU,SU,AU)
      RETURN
      END
CCC_ & UXCnln  ## Unit/Core: unit registration non-linear
      subroutine UXCnln
     O    (iErr,  idU,
     I     Uname, Ubase,
     M     KU,    SU,    AU)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(OUT,  integer)   idU
      _INTENT(IN,   character) Uname *(*)
      _INTENT(IN,   character) Ubase *(*)
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
      _REALSTD FDM(UXC_MAX)
CCC_  - Body
      FDM(UXC_F) = 0.d0
      FDM(UXC_D) = 0.d0
      FDM(UXC_M) = 0.d0
      call UXCreg (iErr, idU, Uname, FDM, Ubase, KU,SU,AU)
      RETURN
      END
CCC_ & UXCxps  ## Unit/Core: conversion registration after parsing
      subroutine UXCxps
     O    (iErr, idX,
     I     Usrc, Udst,
     M     KU,   SU,    AU)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(OUT,  integer)   idX
      _INTENT(IN,   character) Usrc*(*), Udst*(*)
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
      integer idUs, idUd
CCC_  - Body
      iErr = 0
      idX  = _ID_UNDEF
CC    to do: UXCprc returns number of unknowns
      if (iErr.eq.0) call UXCprc (iErr, idUs, Usrc, KU,SU,AU)
      if (iErr.eq.0) call UXCprc (iErr, idUd, Udst, KU,SU,AU)
      if (iErr.gt.0) then
         iErr = ERR_UNIT_INVALID_COMPOUND
      else if (iErr.eq.0) then
         call UXCxrg (iErr, idX, idUs, idUd, KU,SU,AU)
      endif
      RETURN
      END
CCC_ & UXCxrg  ## Unit/Core: conversion registration
      subroutine UXCxrg
     O    (iErr, idX,
     I     idUs, idUd,
     M     KU,   SU,   AU)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(OUT,  integer)   idX
      _INTENT(IN,   integer)   idUd, idUs
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
      integer idS
CCC_  - Body
      iErr = 0
      idX  = _ID_UNDEF
      call UXCcvc(iErr, idS, idUs, idUd, KU,AU)
      if (iErr.eq.0) call UXCdcm (iErr, idX, idS, KU,SU,AU)
      RETURN
      END
CCC_ & UXCcvc  ## Unit/Core: conversion compound
      subroutine UXCcvc
     O    (iErr, idS,
     I     idUs, idUd,
     M     KU,   AU)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(OUT,  integer)   idS
      _INTENT(IN,   integer)   idUd, idUs
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(IN,   character) AU(*)*(*)
      integer    LipT, NipT
      parameter (LipT = OPT_UNIT_SEQUENCE_MAX)
      integer    ipTbl  (_IPTBL_MAX, LipT)
CCC_  - Body
      iErr = 0
      idS  = _ID_UNDEF
      NipT = 0
      if (idUs.gt.0) then
         NipT = NipT + 1
         ipTbl (_IPTBL_ID,  NipT) = idUs
         ipTbl (_IPTBL_POW, NipT) = 1
      endif
      if (idUd.gt.0) then
         NipT = NipT + 1
         ipTbl (_IPTBL_ID,  NipT) = idUd
         ipTbl (_IPTBL_POW, NipT) = -1
      endif
      if (NipT.eq.0) iErr = ERR_UNIT_INVALID_TABLE
c
      if (iErr.eq.0) then
         call UXCrcs (iErr, idS, ipTbl, NipT, KU,AU)
      endif
      RETURN
      END
CCC_ & UXCdcm  ## Unit/Core: decomposition registration
      subroutine UXCdcm
     O    (iErr, idX,
     I     idS,
     M     KU,   SU,  AU)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(OUT,  integer)   idX
      _INTENT(IN,   integer)   idS
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
      _REALSTD FDM (UXC_MAX)
      integer    idR
CCC_  - Body
      iErr = 0
      idX  = _ID_UNDEF
      idR  = _ID_UNDEF
CCC_   . decompose source unit
      if (iErr.eq.0) call UXCfdc(iErr, FDM, idR, idS, KU,SU,AU)
CCC_   . get decomposition id
      if (iErr.eq.0) call UXAgdi(iErr, idX, idS, KU)
CCC_   . set decomposition id
      if (iErr.eq.0) then
CCC_   . Todo: check consistency when already registered
         if (idX.gt.0) then
            continue
         else
            call UXAndi(iErr, idX, KU)
            if (iErr.eq.0) then
               call UXAndx(iErr, idX, FDM, idR,  KU,SU,AU)
            endif
            if (iErr.eq.0) then
               call UXAsdi(iErr, idS, idX, KU)
            endif
            call UXMdnd (idS, idX, 'uxcdcm', iErr, KU,SU,AU)
         endif
      endif
      RETURN
      END
CCC_ & UXCfdc  ## Unit/Core: decomposition
      subroutine UXCfdc
     O    (iErr, FDM, idR,
     I     idS,
     M     KU,   SU,  AU)
CCC_  - Description
CC      Decompose unit[idS] to primitive sequences,
CC      return coefficient array and result single/compound unit id.
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(OUT,  integer)   idR
      _INTENT(OUT,  _REALSTD)  FDM(*)
      _INTENT(IN,   integer)   idS
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(IN,   _REALSTD)  SU(*)
      _INTENT(IN,   character) AU(*)*(*)
c
      integer    LipT, NipT
      parameter (LipT = OPT_UNIT_SEQUENCE_MAX)
      integer    LcpT, NcpT
      parameter (LcpT = OPT_UNIT_SEQUENCE_MAX)
      integer    ipTbl  (_IPTBL_MAX, LipT)
      _REALSTD   cpTbl  (_CPTBL_MAX, LcpT)
CCC_  - Body
      iErr = 0
c
      NipT = 0
      NcpT = 0
c
      NipT = NipT + 1
      ipTbl (_IPTBL_ID,  NipT) = idS
      ipTbl (_IPTBL_POW, NipT) = 1
c
      call UXAxpn (iErr, ipTbl, NipT, LipT, cpTbl, NcpT, LcpT, KU,SU)
      if (iErr.eq.0) then
         call UXCrcs (iErr, idR, ipTbl, NipT, KU,AU)
      endif
      if (iErr.ge.0) then
         call UXPc2f (iErr, FDM, cpTbl, NcpT, UXLEV_FDM)
      endif
c
      RETURN
      END
CCC_ & UXCreg  ## Unit/Core: unit registration kernel
      subroutine UXCreg
     O    (iErr,  idU,
     I     Uname, FDM, Ubase,
     M     KU,    SU,  AU)
CCC_  - Description
CC      declare Uname as FDM. Ubase (or its reversal)
CC
CC      if blank Ubase:             declare as a primitive
CC      if Uname Ubase registered:  check consistency
CC      if Uname registered
CC             and single Ubase:    Ubase (reverse) declaration
CC      otherwise:                  Uname declaration
cC
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(OUT,  integer)   idU
      _INTENT(IN,   character) Uname *(*)
      _INTENT(IN,   character) Ubase *(*)
      _INTENT(IN,   _REALSTD)  FDM(*)
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
      integer    idB
      integer    nunk
CCC_  - Body
      iErr = 0
      if (Ubase.eq.' ') then
         idB = _ID_PRIMITIVE
         call UXCnew(iErr, idU, Uname, FDM, idB, KU,SU,AU)
      else
         call UXCprc(iErr, idB, Ubase, KU,SU,AU)
CC       iErr as number of unknowns
         if (iErr.gt.0) then
            nunk = iErr
            call UXCnrv(iErr, idU, Uname, FDM, idB, nunk, KU,SU,AU)
         else if (iErr.eq.0) then
            call UXCnew(iErr, idU, Uname, FDM, idB, KU,SU,AU)
         endif
      endif
      RETURN
      END
CCC_ & UXCnrv  ## Unit/Core: register new unit (reversal)
      subroutine UXCnrv
     O    (iErr,  idU,
     I     Uname, FDM, idB, nUnk,
     M     KU,    SU,  AU)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(OUT,  integer)   idU
      _INTENT(IN,   character) Uname *(*)
      _INTENT(IN,   integer)   idB
      _INTENT(IN,   _REALSTD)  FDM(*)
      _INTENT(IN,   integer)   nUnk
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
      integer ncu
CCC_  - Body
      if (nUnk.eq.0) then
CC       normally this clause is never executed
         call UXCnew (iErr, idU, Uname, FDM, idB, KU,SU,AU)
      else
         call UXAnch(ncu,  idB, KU)
         call UXAqui(iErr, idU, Uname, KU,AU)
CC       Uname registered / Ubase single unregistered
         if (iErr.eq.0.and.nUnk.eq.1) then
            call UXCinv (iErr, idU, FDM, idB, KU,SU,AU)
         else
            call UXCnew (iErr, idU, Uname, FDM, idB, KU,SU,AU)
            if (iErr.eq.0) iErr = nUnk
         endif
      endif
      RETURN
      END
CCC_ & UXCinv  ## Unit/Core: register inverse
      subroutine UXCinv
     O    (iErr,
     I     idU,  FDM,   idB,
     M     KU,   SU,    AU)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   idU
      _INTENT(IN,   _REALSTD)  FDM(*)
      _INTENT(IN,   integer)   idB
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)

      integer    LipT, NipT
      parameter (LipT = OPT_UNIT_SEQUENCE_MAX)
      integer    ipTbl  (_IPTBL_MAX, LipT)
      integer    j,  jb
      integer    juk,  idUK, ipUK
      integer    idRa, idRb, KSW
CCC_  - Body
      iErr = 0
      NipT = 0
      ipUK = 0
      call UXAqip (iErr, ipTbl, NipT, LipT, idB, KU)
      juk = 0
      do j = 1, NipT
         if (iErr.eq.0) then
            call UXAgbi(iErr, jb, ipTbl(_IPTBL_ID,j), KU)
            if (jb.eq. _ID_WAIT) juk = j
         endif
      enddo
      if (juk.eq.0) iErr = ERR_UNIT_PANIC
      if (iErr.eq.0) then
         idUK = ipTbl(_IPTBL_ID, juk)
         ipUK = ipTbl(_IPTBL_POW,juk)
         if (ipUK.ne.1.and.ipUK.ne.-1) iErr = ERR_UNIT_INVALID_COMPOUND
      endif
      if (iErr.eq.0) then
         ipTbl(_IPTBL_ID, juk) = _ID_DIMENSIONLESS
         call UXPnml (iErr, ipTbl, NipT)
         call UXCrcs (iErr, idRa, ipTbl, NipT, KU,AU)
      endif
      if (iErr.eq.0) then
         NipT = 2
         ipTbl(_IPTBL_ID,1) = idU
         ipTbl(_IPTBL_ID,2) = idRa
CC        U = F B = F R UK
         if (ipUK.ge.0) then
            ipTbl(_IPTBL_POW,1) = +1
            ipTbl(_IPTBL_POW,2) = -1
            KSW = -1
CC        U = F B = F R / UK
         else
            ipTbl(_IPTBL_POW,1) = -1
            ipTbl(_IPTBL_POW,2) = +1
            KSW = +1
         endif
         call UXPnml (iErr, ipTbl, NipT)
         call UXCrcs (iErr, idRb, ipTbl, NipT, KU,AU)
         if (iErr.eq.0) then
            call UXAnsw (iErr, idUK, ' ', FDM, idRb, KSW, KU,SU,AU)
         endif
         call UXMdnu (idUK, ' ', FDM, idRb, KSW, 'uxcinv', iErr, KU,AU)
      endif
      RETURN
      END
CCC_ & UXCnew  ## Unit/Core: register new unit
      subroutine UXCnew
     O    (iErr,  idU,
     I     Uname, FDM, idB,
     M     KU,    SU,  AU)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(OUT,  integer)   idU
      _INTENT(IN,   character) Uname *(*)
      _INTENT(IN,   integer)   idB
      _INTENT(IN,   _REALSTD)  FDM(*)
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
      integer idB0
CCC_  - Body
      iErr = 0
      call UXAqui (iErr, idU, Uname, KU,AU)
      if (iErr.eq. ERR_UNIT_NEW_UNIT) then
         call UXAnsu (iErr, idU, Uname, FDM, idB,            KU,SU,AU)
         call UXMdnu (idU, Uname, FDM, idB, +1, 'uxcnew', iErr, KU,AU)
      else
         call UXAgbi (iErr, idB0, idU,   KU)
         if (iErr.eq.0) then
            if (idB0.eq. _ID_WAIT) then
               call UXAnsu (iErr, idU, Uname, FDM, idB, KU,SU,AU)
               call UXMdnu
     $              (idU, Uname, FDM, idB, +1, 'uxcnew', iErr, KU,AU)
            else
               call UXCife (iErr, idU, idB, FDM,   KU,SU)
               if (iErr.ne.0) then
                  call UXMdnu
     $                 (idU, Uname, FDM, idB, +1, 'uxcnew', iErr, KU,AU)
                  if (iErr.gt.0) iErr = ERR_UNIT_DUP_SINGLE
               endif
            endif
         endif
      endif
      RETURN
      END
CCC_ & UXCife  ## Unit/Core: check if identical
      subroutine UXCife
     O    (iErr,
     I     idTgt, idRef, FDM,
     I     KU,    SU)
CCC_  - Description
CC     check if  idTgt == FDM * idRef
CC     return 0 if identical, positive if not, negative if error
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   idTgt
      _INTENT(IN, integer)   idRef
      _INTENT(IN, _REALSTD)  FDM(*)
      _INTENT(IN, integer)   KU(*)
      _INTENT(IN, _REALSTD)  SU(*)
      integer    LipT, NipT
      parameter (LipT = OPT_UNIT_SEQUENCE_MAX)
      integer    LcpT, NcpT
      parameter (LcpT = OPT_UNIT_SEQUENCE_MAX)
      integer    ipTbl  (_IPTBL_MAX, LipT)
      _REALSTD   cpTbl  (_CPTBL_MAX, LcpT)
      _REALSTD   C(1)
CCC_  - Body
      iErr = 0
      ipTbl(_IPTBL_ID,  1) = idRef
      ipTbl(_IPTBL_POW, 1) = +1
      ipTbl(_IPTBL_ID,  2) = idTgt
      ipTbl(_IPTBL_POW, 2) = -1
      NipT = 2
      if (iErr.eq.0)
     $     call UXPf2c (iErr, cpTbl, NcpT,  LcpT, FDM, UXLEV_FDM)
      if (iErr.eq.0)
     $     call UXAxpn
     $     (iErr, ipTbl, NipT,  LipT, cpTbl, NcpT, LcpT, KU,SU)
      if (iErr.eq.0)
     $     call UXPc2f (iErr, C, cpTbl, NcpT, UXLEV_F)
      if (iErr.eq.0) then
         if (NipT.eq.0) then
            if (C(1).eq. 1.d0) then
               iErr = 0
            else
               iErr = ERR_UNIT_DIAG_SAME_DIM
            endif
         else
            iErr = ERR_UNIT_DIAG_DIFFERENT
         endif
      endif
      RETURN
      END
CCC_ & UXCprc  ## Unit/Core: parse and register compound/single unit
      subroutine UXCprc
     O    (iErr,  idU,
     I     Udef,
     M     KU,    SU,    AU)
CCC_  - Description
CC         return negative if error
CC         otherwise return number of unknown unit atoms
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(OUT,  integer)   idU
      _INTENT(IN,   character) Udef *(*)
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
      integer    lSeq
      parameter (lSeq = OPT_UNIT_SEQUENCE_MAX)
      integer    lUnt
      parameter (lUnt = OPT_UNIT_LEN)
      integer    ipTbl (_IPTBL_MAX, lSeq)
      character  uSeq  (lSeq)*(lUnt)
      integer    kpSeq (lSeq)
      integer    nSeq, nTbl
      integer    js
      integer    idUp
      _REALSTD   FDM(UXC_MAX)
      integer    nnu
CCC_  - Body
      iErr = 0
      nTbl = 0
      idU  = _ID_UNDEF
      FDM(UXC_F) = 1.d0
      FDM(UXC_D) = 1.d0
      FDM(UXC_M) = 0.d0
      nnu = 0
c
      if (iErr.eq.0) then
         call UXPnew (iErr, uSeq, kpSeq, nSeq, lSeq, Udef)
      endif
      if (iErr.eq.0) then
         do js = 1, nSeq
            call UXAqui (iErr, idUp, uSeq(js), KU,AU)
            if (iErr.eq. ERR_UNIT_NEW_UNIT) then
CCC_   . Todo: string to number
               nnu = nnu + 1
               call UXAnsu
     $              (iErr, idUp, uSeq(js), FDM, _ID_WAIT, KU,SU,AU)
            endif
            if (iErr.eq.0) then
               nTbl = nTbl + 1
               ipTbl(_IPTBL_ID, nTbl) = idUp
               ipTbl(_IPTBL_POW,nTbl) = kpSeq (js)
            endif
         enddo
      endif
      if (iErr.eq.0) then
         call UXPnml (iErr, ipTbl, nTbl)
      endif
      if (iErr.eq.0) then
         call UXCrcs (iErr, idU, ipTbl, nTbl, KU,AU)
      endif
      if (iErr.ne.0.or.nnu.gt.0)
     $     call UXMdps (idU, Udef, nnu, 'uxcprc', iErr, KU,AU)
CCC_   . store result
      if (iErr.eq.0) iErr = nnu
      RETURN
      END
CCC_ & UXCrcs  ## Unit/Core: register compound/single unit by table
      subroutine UXCrcs
     O    (iErr,   idU,
     I     ipTbl,  nipt,
     M     KU,     AU)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(OUT,  integer)   idU
      _INTENT(IN,   integer)   ipTbl (_IPTBL_MAX, *)
      _INTENT(IN,   integer)   nipt
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(IN,   character) AU(*)*(*)
CCC_  - Body
      iErr = 0
      if (nipt.eq.0) then
         idU = _ID_DIMENSIONLESS
      else if (nipt.eq.1.and.ipTbl(_IPTBL_POW,1).eq.1) then
         idU = ipTbl(_IPTBL_ID,1)
      else if (nipt.eq.1
     $        .and.ipTbl(_IPTBL_ID,1).eq. _ID_DIMENSIONLESS) then
         idU = _ID_DIMENSIONLESS
      else
         call UXAqci (iErr, idU, ipTbl, nipt, KU)
         if (iErr.eq. ERR_UNIT_NEW_UNIT) then
            call UXAncu(iErr, idU, ipTbl, nipt, KU)
            call UXMdnc(idU, 'uxcrcs', iErr,    KU,AU)
CCC_   . Todo: report
         else if (iErr.eq.0) then
            continue
         endif
      endif
      RETURN
      END
CCC_ & UXCinq  ## Unit/Core: unit inquiry
      subroutine UXCinq
     O    (iErr, idU,
     I     Uname,
     M     KU,   AU)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(OUT,  integer)   idU
      _INTENT(IN,   character) Uname *(*)
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(IN,   character) AU(*)*(*)
CCC_  - Body
      call UXAqui (iErr, idU, Uname, KU, AU)
      if (iErr.ne.0) then
         iErr = ERR_UNIT_INVALID_SINGLE
         idU  = _ID_UNDEF
      endif
      RETURN
      END
CCC_ & UXCftb  ## Unit/Core: FDM table (or its variation)
      subroutine UXCftb
     O    (iErr, FDM,
     I     idU,  ODEC, KLV,
     I     KU,   SU)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,_REALSTD)  FDM(*)
      _INTENT(IN, integer)   idU
      _INTENT(IN, logical)   ODEC
      _INTENT(IN, integer)   KLV
      _INTENT(IN, integer)   KU(*)
      _INTENT(IN, _REALSTD)  SU(*)
      integer  idX
      _REALSTD XC(UXC_MAX)
      _REALSTD T10, T0, F, D, EP, EN
CCC_  - Body
      iErr = 0
      if (ODEC) then
         call UXAgdi(iErr, idX, idU, KU)
      else
         idX = idU
      endif
      if (iErr.eq.0) call UXAgxt (iErr, XC, idX, KU,SU)
      if (iErr.eq.0) then
         T10 = 10.d0
         T0  = 0.d0
         F   = XC(UXC_F)
         D   = XC(UXC_D)
         EP  = + MAX(T0, XC(UXC_M))
         EN  = - MIN(T0, XC(UXC_M))
         if      (KLV.eq. UXLEV_F)   then
            F = F * (T10 ** EP)
            D = D * (T10 ** EN)
            if (D.eq.0.0d0) then
               FDM(UXC_F) = 0.0d0
            else
               FDM(UXC_F) = F / D
            endif
         else if (KLV.eq. UXLEV_FD)  then
            FDM(UXC_F) = F * (T10 ** EP)
            FDM(UXC_D) = D * (T10 ** EN)
         else if (KLV.eq. UXLEV_FDM) then
            FDM(UXC_F) = F
            FDM(UXC_D) = D
            FDM(UXC_M) = EP - EN
         else
            iErr = ERR_UNIT_INVALID_SWITCH
         endif
      endif
      RETURN
      END
CCC_ & UXClmx  ## Unit/Core: get id limit
      subroutine UXClmx (LO, SW, KU)
      implicit none
      _INTENT(OUT,integer)   LO
      _INTENT(IN, character) SW*(*)
      _INTENT(IN, integer)   KU(*)
      integer LU, LC
      call UXArng(LU, LC, KU)
      if (SW.eq.'U') then
         LO = LU
      else if (SW.eq.'C') then
         LO = LC
      else if (SW.eq.'L') then
         LO = LC
      else
         LO = -1
      endif
      RETURN
      END
CCC_* [UXM] Message
CCC_ & UXMrep  ## Unit/Message: report summary
      subroutine UXMrep (iErr, IFP,  KU,SU,AU)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   IFP
      _INTENT(IN, integer)   KU(*)
      _INTENT(IN, _REALSTD)  SU(*)
      _INTENT(IN, character) AU(*)*(*)
      integer   ju
      integer   jfp
      integer   MHU, MHC
      integer   NU,  NC,   NT
c
      iErr = 0
      call UXAhst (MHU, MHC,      KU)
      call UXAnco (NU,  NC,  NT,  KU,AU)
c
 101  format ('UNIT REPORT ', 2I5, 1x, I5, 1x, 2I3)
 109  format ('UNIT REPORT DONE')
      call UXAgiu (jfp, IFP, KU)
c
      if (COND_N(jfp)) then
         write (jfp, 101) NU, NC, NT, MHU, MHC
      else if (COND_S(jfp)) then
         write (*,   101) NU, NC, NT, MHU, MHC
      endif
c
      ju = 0
      DO
         ju = ju + 1
         call UXMrps (iErr, ju, jfp,  KU,SU,AU)
         if (iErr.ne.0) goto 100
      ENDDO
 100  continue
      iErr = 0
c
      if (COND_N(jfp)) then
         write (jfp, 109)
      else if (COND_S(jfp)) then
         write (*,   109)
      endif
c
      RETURN
      END
CCC_ & UXMrps  ## Unit/Message: report unit attributes
      subroutine UXMrps (iErr, idU, IFP, KU,SU,AU)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   idU
      _INTENT(IN, integer)   IFP
      _INTENT(IN, integer)   KU(*)
      _INTENT(IN, _REALSTD)  SU(*)
      _INTENT(IN, character) AU(*)*(*)
      integer   jb, jd, jdb, js
      character U*(128)
      character B*(256), BU*(128)
      character D*(256), DU*(128)
      character T*(256)
c
      call UXAqun(iErr, U, idU, _CHAR_IGNORE, KU,AU)
      if (iErr.ne.0) return
      if (U.eq.' ')  return
c
      call UXAgbi(iErr, jb, idU, KU)
      if (iErr.eq.0) then
         call UXMcsq(B,  idU,     KU,SU)
         call UXMusq(BU, jb,      KU,AU)
         call USJsta(B,  ' ', BU)
      else
         B = ' '
      endif
      call UXAgds(iErr, js, idU, KU)
      if (js.eq. _ID_UNDEF) then
         call UXAgdi(iErr, jd, idU, KU)
         if (jd.ne. _ID_UNDEF) then
            call UXAgbi(iErr, jdb, jd, KU)
            call UXMcsq(D,    jd,      KU,SU)
            call UXMusq(DU,   jdb,     KU,AU)
            call USJsta(D, ' ', DU)
         else
            D = ' '
         endif
      else
         call UXMusq(D,   js,     KU,AU)
       endif
CCC_  - generate
      T = U
      if (B.ne.' ') call USJxra(T, ' = ',  B)
      if (D.ne.' ') call USJxra(T, ' == ', D)

 101  format (I4, 1x, A)
      if (COND_N(IFP)) then
         write (IFP, 101) idU, _TRIM(T)
      else if (COND_S(IFP)) then
         write (*,   101) idU, _TRIM(T)
      endif
      RETURN
      END
CCC_ & UXMdnu  ## Unit/Message: new unit declaration
      subroutine UXMdnu
     I    (idU, UNM, FDM, idB, kDIR, Tag, iStt,
     M     KU,  AU)
      implicit none
      _INTENT(IN, integer)   idU
      _INTENT(IN, character) UNM*(*)
      _INTENT(IN, _REALSTD)  FDM(*)
      _INTENT(IN, integer)   idB
      _INTENT(IN, integer)   kDIR
      _INTENT(IN, character) Tag*(*)
      _INTENT(IN, integer)   iStt
      _INTENT(IN, integer)   KU(*)
      _INTENT(IN, character) AU(*)*(*)
      character Tentr*(128)
      character Tun*(128), Tbs*(128), Tcf*(128)
      integer   jfp
c
      call UXAgid(jfp,              KU)
      call UXMent(Tentr, Tag, iStt)
      call UXMust(Tun,   idU, UNM,  KU,AU)
      call UXMusq(Tbs,   idB,       KU,AU)
      call UXMcst(Tcf,   FDM, kDIR)
c
 101  format (A, ' single ', A, ' = ', A, 1x, A)
      if      (COND_N(jfp)) then
         write (jfp, _FORMAT(101))
     $        _TRIM(Tentr),
     $        _TRIM(Tun),
     $        _TRIM(Tcf),
     $        _TRIM(Tbs)
      else if (COND_S(jfp)) then
         write (*,   _FORMAT(101))
     $        _TRIM(Tentr),
     $        _TRIM(Tun),
     $        _TRIM(Tcf),
     $        _TRIM(Tbs)
      endif
      RETURN
      END
CCC_ & UXMdnc  ## Unit/Message: new compound declaration
      subroutine UXMdnc
     I     (idU, Tag, iStt,  KU, AU)
      implicit none
      _INTENT(IN, integer)   idU
      _INTENT(IN, character) Tag*(*)
      _INTENT(IN, integer)   iStt
      _INTENT(IN, integer)   KU(*)
      _INTENT(IN, character) AU(*)*(*)

      character Tentr*(128)
      character Tun*(128)
      integer   jfp
c
      call UXAgid(jfp,   KU)
      call UXMent(Tentr, Tag, iStt)
      call UXMusq(Tun,   idU, KU,AU)
c
 101  format (A, ' compound ', A)
      if      (COND_N(jfp)) then
         write (jfp, _FORMAT(101))
     $        _TRIM(Tentr),
     $        _TRIM(Tun)
      else if (COND_S(jfp)) then
         write (*,   _FORMAT(101))
     $        _TRIM(Tentr),
     $        _TRIM(Tun)
      endif
      RETURN
      END
CCC_ & UXMdnd  ## Unit/Message: new decomposition declaration
      subroutine UXMdnd
     I    (idS, idX, Tag, iStt,
     I     KU,  SU,  AU)
      implicit none
      _INTENT(IN, integer)   idS
      _INTENT(IN, integer)   idX
      _INTENT(IN, character) Tag*(*)
      _INTENT(IN, integer)   iStt
      _INTENT(IN, integer)   KU(*)
      _INTENT(IN, _REALSTD)  SU(*)
      _INTENT(IN, character) AU(*)*(*)
      character Tentr*(128)
      character Tsrc*(128)
      character Tdec*(128)
      character Tbdc*(128)
      character Tcfx*(128)
      integer   idBx
      integer   jfp
      integer   jerr
c
      call UXAgid(jfp,               KU)
      call UXMent(Tentr, Tag,  iStt)
      call UXMusq(Tsrc,  idS,        KU,AU)
      call UXMusq(Tdec,  idX,        KU,AU)
      call UXMcsq(Tcfx,  idX,        KU,SU)
      call UXAgbi(jerr,  idBx, idX,  KU)
      call UXMusq(Tbdc,  idBx,       KU,AU)
c
 101  format (A, ' decomposition ', A, ' = ', A, 1x, A, 1x, A)
      if      (COND_N(jfp)) then
         write (jfp, _FORMAT(101))
     $        _TRIM(Tentr),
     $        _TRIM(Tsrc),
     $        _TRIM(Tcfx),
     $        _TRIM(Tbdc),
     $        _TRIM(Tdec)
      else if (COND_S(jfp)) then
         write (*,   _FORMAT(101))
     $        _TRIM(Tentr),
     $        _TRIM(Tsrc),
     $        _TRIM(Tcfx),
     $        _TRIM(Tbdc),
     $        _TRIM(Tdec)
      endif
      RETURN
      END
CCC_ & UXMdps  ## Unit/Message: parse result
      subroutine UXMdps
     I     (idU, Udef, Nnu, Tag, iStt, KU, AU)
      implicit none
      _INTENT(IN, integer)   idU
      _INTENT(IN, character) Udef*(*)
      _INTENT(IN, integer)   Nnu
      _INTENT(IN, character) Tag*(*)
      _INTENT(IN, integer)   iStt
      _INTENT(IN, integer)   KU(*)
      _INTENT(IN, character) AU(*)*(*)
      character Tentr*(128)
      character Tun*(128)
      integer   jfp
c
      call UXAgid(jfp,   KU)
      call UXMent(Tentr, Tag, iStt)
      call UXMust(Tun,   idU, Udef,  KU,AU)
c
 101  format (A, ' parse ', A, ' unknown ', I3)
      if      (COND_N(jfp)) then
         write (jfp, _FORMAT(101))
     $        _TRIM(Tentr),
     $        _TRIM(Tun),
     $        Nnu
      else if (COND_S(jfp)) then
         write (*,   _FORMAT(101))
     $        _TRIM(Tentr),
     $        _TRIM(Tun),
     $        Nnu
      endif
      RETURN
      END
CCC_ & UXMent  ## Unit/Message: entry string
      subroutine UXMent(Z, T, iStt)
      implicit none
      _INTENT(OUT,character) Z*(*)
      _INTENT(IN, character) T*(*)
      _INTENT(IN, integer)   iStt
      character SS*(24)
c
      call USGlni(SS, iStt)
 101  format (A, ':', A)
      write (Z, 101) _TRIM(T), _TRIM(SS)
      RETURN
      END
CCC_ & UXMust  ## Unit/Message: unit identifier
      subroutine UXMust(Z, id, U,  KU, AU)
      implicit none
      _INTENT(OUT,character) Z*(*)
      _INTENT(IN, integer)   id
      _INTENT(IN, character) U*(*)
      _INTENT(IN, integer)   KU(*)
      _INTENT(IN, character) AU(*)*(*)
      character SI*(24)
      integer   je
c
      if (U.eq.' ') then
         call UXMusq(Z, id,  KU, AU)
      else
         call USGlni(SI, id)
 101     format ('[', A, ']', A)
         write (Z, 101, IOSTAT=je) _TRIM(SI),_TRIM(U)
      endif
      RETURN
      END
CCC_ & UXMusq  ## Unit/Message: unit identifier (query)
      subroutine UXMusq(Z, id, KU, AU)
      implicit none
      _INTENT(OUT,character) Z*(*)
      _INTENT(IN, integer)   id
      _INTENT(IN, integer)   KU(*)
      _INTENT(IN, character) AU(*)*(*)
      character U *(OPT_UNIT_LEN)
      character SI*(24)
      integer   je
c
      call UXAqun(je, U, id, _CHAR_IGNORE, KU, AU)
      if (je.ne.0) then
         call USGlni(SI, je)
 102     format ('*', A, '*')
         write (U, 102) _TRIM(SI)
      endif
      call USGlni(SI, id)
 101  format ('[', A, ']', A)
      write (Z, 101) _TRIM(SI),_TRIM(U)
      RETURN
      END
CCC_ & UXMcsq  ## Unit/Message: coefficient string (query)
      subroutine UXMcsq(Z, id, KU, SU)
      implicit none
      _INTENT(OUT,character) Z*(*)
      _INTENT(IN, integer)   id
      _INTENT(IN, integer)   KU(*)
      _INTENT(IN, _REALSTD)  SU(*)
      integer    LcpT
      parameter (LcpT = OPT_UNIT_SEQUENCE_MAX)
      _REALSTD   cpT  (_CPTBL_MAX, LcpT)
      integer    NcpT
      integer   je
      character SI*(24)
c
      call UXAgcp (je, cpT, NcpT, LcpT, id,  KU, SU)
      if (je.eq.0) then
         call UXPgcs (je, Z, cpT, NcpT, _CHAR_IGNORE)
      endif
      if (je.eq.0) then
         if (Z.eq.' ') Z = '1'
      else
         call USGlni(SI, je)
 102     format ('*', A, '*')
         write (Z, 102) _TRIM(SI)
      endif
      RETURN
      END
CCC_ & UXMcst  ## Unit/Message: coefficient string (array)
      subroutine UXMcst(Z, FDM, kDIR)
      implicit none
      _INTENT(OUT,character) Z*(*)
      _INTENT(IN, _REALSTD)  FDM(*)
      _INTENT(IN, integer)   kDIR
      integer je
      character SI*(24)
c
      call UXPgca (je, Z, FDM, kDIR, _CHAR_IGNORE)
      if (je.eq.0) then
         if (Z.eq.' ') Z = '1'
      else
         call USGlni(SI, je)
 102     format ('*', A, '*')
         write (Z, 102) _TRIM(SI)
      endif
      RETURN
      END
CCC_* [UXA] Unit attribute cluster
CCC_ & UXAcfg  ## Unit/Attribute: attribute manager
      subroutine UXAcfg
     O    (iErr,
     O     KU,    SU,  AU,
     I     LKU,   LSU, LAU,
     I     MS,    MD,  MC,  NAS, NAD, NAC, NAT,
     I     KTYPE, IFPL)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   KU(*)
      _INTENT(OUT,_REALSTD)  SU(*)
      _INTENT(OUT,character) AU(*)*(*)
      _INTENT(IN, integer)   LKU, LSU, LAU
      _INTENT(IN, integer)   NAS, NAD, NAC, NAT
      _INTENT(IN, integer)   MS,  MD,  MC
      _INTENT(IN, integer)   KTYPE
      _INTENT(IN, integer)   IFPL
      integer ji,    jp
      integer j0s,   j0d,   j0c,   j0t
      integer mems,  memd,  memc,  memt
      integer MSI,   MDI,   MCI
      integer NKU,   NSU,   NAU
CCC_  - Body
      iErr = 0
c
      if (MS.le.0 .or. MC.le.0 .or. MD.le.0) then
         call UXAnsg
     O       (iErr, MSI, MDI, MCI,
     I        MS,   MD,  MC,
     I        LKU,  LSU, LAU, NAS, NAD, NAC, NAT,
     I        KTYPE)
      else
         MSI  = MS
         MCI  = MC
         MDI  = MD
         call UXAnrq
     O       (NKU, NSU, NAU,
     I        MSI, MDI, MCI, NAS, NAD, NAC, NAT,
     I        KTYPE)
         if (NKU.gt.LKU) iErr = ERR_UNIT_INSUFFICIENT
         if (NAU.gt.LAU) iErr = ERR_UNIT_INSUFFICIENT
         if (NSU.gt.LSU) iErr = ERR_UNIT_INSUFFICIENT
      endif
c
      if (iErr.eq.0) then
         mems = _UATTR_MAX + MAX(0,NAS)
         memd = _DATTR_MAX + MAX(0,NAD)
         memc = _CATTR_MAX + MAX(0,NAC)
         memt = _IPTBL_MAX + MAX(0,NAT)
c
         j0s  = _OFF_IATTR
         j0d  = j0s + MSI * mems
         j0c  = j0d + MDI * memd
         j0t  = j0c + MCI * memc
c
         _TYPE(KU)  = KTYPE
         _MINUI(KU) = 1
         _MEMUI(KU) = MSI
         _MINDI(KU) = MSI + 1
         _MEMDI(KU) = MDI
         _MINCI(KU) = MSI + MDI + 1
         _MEMCI(KU) = MCI
         _LCTB(KU)  = (LKU - j0t) / memt
         _ICTB(KU)  = 0
         _IDEC(KU)  = 0
         _HMAXU(KU) = 0
         _HMAXC(KU) = 0
         _KSNG0(KU) = j0s - mems
         _KDEC0(KU) = j0d - memd * _MINDI(KU)
         _KCOM0(KU) = j0c - memc * _MINCI(KU)
         _KCTB0(KU) = j0t - memt
         _MAIS(KU)  = mems
         _MAID(KU)  = memd
         _MAIC(KU)  = memc
         _MCTB(KU)  = memt
         _LOGU(KU)  = MAX(-2, IFPL)
         _MATS(KU)  = _COEFF_MAX
         _MATA(KU)  = 1
         _HASHB(KU) = OPT_UNIT_HASH_BASE
         _HASHF(KU) = OPT_UNIT_HASH_BASE_FINAL
         do jp = 1, MSI
            _KSNG(KU,_UATTR_BASE,jp) = _ID_UNDEF
            _KSNG(KU,_UATTR_DEC, jp) = _ID_UNDEF
         enddo
         do jp = 1, MDI
            ji = jp + _MINDI(KU) - 1
            _KDEC(KU,_DATTR_BASE,ji) = _ID_UNDEF
            _KDEC(KU,_DATTR_SRC, ji) = _ID_UNDEF
         enddo
         do jp = 1, MCI
            ji = jp + _MINCI(KU) - 1
            _KCOM(KU,_CATTR_POS,ji) = _ID_UNDEF
            _KCOM(KU,_CATTR_NUM,ji) = 0
            _KCOM(KU,_CATTR_DEC,ji) = _ID_UNDEF
         enddo
         do jp = 1, _LCTB(KU)
            _KCTB(KU,_IPTBL_ID, jp) = _ID_UNDEF
            _KCTB(KU,_IPTBL_POW,jp) = 0
         enddo
      endif
      if (iErr.eq.0) then
         do jp = 1, MSI
            _USTR(AU,jp) = ' '
         enddo
      endif
      if (iErr.eq.0) then
         do jp = 1, MSI
            _CFTS(SU,_COEFF_F,jp) = 1.0d0
            _CFTS(SU,_COEFF_D,jp) = 1.0d0
            _CFTS(SU,_COEFF_M,jp) = 0.0d0
         enddo
         do jp = 1, MDI
            ji = jp + _MINDI(KU) - 1
            _CFTD(SU,_COEFF_F,ji) = 1.0d0
            _CFTD(SU,_COEFF_D,ji) = 1.0d0
            _CFTD(SU,_COEFF_M,ji) = 0.0d0
         enddo
      endif
      RETURN
      END
CCC_ & UXAnrq  ## Unit/Attribute: query buffer size requirements
      subroutine UXAnrq
     O    (NKU, NSU, NAU,
     I     MS,  MD,  MC,  NAS, NAD, NAC, NAT,
     I     KTYPE)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   NKU, NSU, NAU
      _INTENT(IN, integer)   NAS, NAD, NAC, NAT
      _INTENT(IN, integer)   MS,  MD,  MC
      _INTENT(IN, integer)   KTYPE
      integer mems,  memd,  memc,  memt
      integer j0s,   j0d,   j0c,   j0t
CCC_  - Body
CC    to avoid warning
#if OPT_AVOID_WARNING
#else
      if (KTYPE.eq.0) then
         continue
      endif
#endif /* not OPT_AVOID_WARNING */
c
      mems = _UATTR_MAX + MAX(0,NAS)
      memd = _DATTR_MAX + MAX(0,NAD)
      memc = _CATTR_MAX + MAX(0,NAC)
      memt = _IPTBL_MAX + MAX(0,NAT)
c
      j0s  = _OFF_IATTR
      j0d  = j0s + MS * mems
      j0c  = j0d + MD * memd
      j0t  = j0c + MC * memc
      NKU  = j0t + MC * memt
c
      NSU  = (MS + MD) * _COEFF_MAX
c
      NAU  = MS * 1
c
      RETURN
      END
CCC_ & UXAnsg  ## Unit/Attribute: query buffer size suggestions
      subroutine UXAnsg
     O    (iErr, MSsg, MDsg, MCsg,
     I     MS,   MD,   MC,
     I     LKU,  LSU,  LAU,  NAS, NAD, NAC, NAT,
     I     KTYPE)
CCC_  - Description
CC      Give you suggested size of [MS,MD,MC]sg using
CC      the limit sizes of the cluster [LKU,LSU,LAU].
CC      The inputs [MS,MD,MC] are the hints used for
CC      those expected members of single/decomposition/compounds.
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(OUT,integer) MSsg, MDsg, MCsg
      _INTENT(IN, integer) MS,   MD,  MC
      _INTENT(IN, integer) LKU,  LSU, LAU
      _INTENT(IN, integer) NAS,  NAD, NAC, NAT
      _INTENT(IN, integer) KTYPE
      integer mems,  memd,  memct
      integer ltmpu, ltmps, luav
      integer jdlt
      integer NKU,   NSU,   NAU
CCC_  - Body
#define _SD_PARA 2
#define _SC_PARA 2
#define _CT_PARA 2
CC    to avoid warning
      iErr  = 0 * KTYPE
CCC_   . init
      MSsg  = MAX(0,MS)
      MCsg  = MAX(0,MC)
      MDsg  = MAX(0,MD)
      mems  = _UATTR_MAX + MAX(0,NAS)
      memd  = _DATTR_MAX + MAX(0,NAD)
      memct = _CATTR_MAX + MAX(0,NAC)
     $     + (_IPTBL_MAX + MAX(0,NAT)) * _CT_PARA
      luav  = LKU - _OFF_IATTR
CCC_   . MS
      if (MSsg.eq.0) then
         MSsg = LAU / 1
         MSsg = MIN(MSsg, (LSU - MDsg*_COEFF_MAX) / _COEFF_MAX)
         MSsg = MIN(MSsg, (luav - MDsg*memd - MCsg*memct) / mems)
         if (MSsg.lt.0) iErr = -1
         MSsg = MAX(MSsg, 0)
      endif
CCC_   . MD
      if (iErr.eq.0 .and. MDsg.eq.0) then
         MDsg = (LSU - MSsg*_COEFF_MAX) / _COEFF_MAX
         MDsg = MIN(MDsg, (luav - MSsg*mems - MCsg*memct) / memd)
         if (MDsg.le.(MSsg/_SD_PARA)) then
            MSsg = (LSU * _SD_PARA) / (_COEFF_MAX * (_SD_PARA + 1))
            MDsg = (LSU - MSsg*_COEFF_MAX) / _COEFF_MAX
            ltmpu = luav - MCsg*memct
            ltmps = (ltmpu * _SD_PARA) / (memd + mems*_SD_PARA)
            if (MSsg.gt.ltmps) then
               MSsg = ltmps
               MDsg = (ltmpu - MSsg * mems) / memd
            endif
         endif
         MSsg = MAX(MSsg, 0)
         MDsg = MAX(MDsg, 0)
      endif
CCC_   . MC
      if (iErr.eq.0 .and. MCsg.eq.0) then
         MCsg = (luav - MSsg * mems - MDsg * memd) / memct
         if (MCsg.le.(MSsg/_SC_PARA)) then
            ltmpu = MSsg*memct + _SC_PARA * (MSsg*mems + MDsg * memd)
            jdlt = ((ltmpu - _SC_PARA * luav)) * MSsg / ltmpu
            MDsg = MDsg * (MSsg - jdlt) / MSsg
            MSsg = MSsg - jdlt
            MCsg = (luav - MSsg * mems - MDsg * memd) / memct
         endif
      endif
CCC_   . result
      if (MSsg.le.0.or.MCsg.le.0.or.MDsg.le.0) then
         iErr = -1
         NKU  = 0
         NSU  = 0
         NAU  = 0
      else
         call UXAnrq
     O       (NKU, NSU,  NAU,
     I        MSsg,MDsg, MCsg, NAS, NAD, NAC, NAT,
     I        KTYPE)
         if (NKU.gt.LKU .or. NSU.gt.LSU .or. NAU.gt.LAU) then
            iErr = -1
         endif
      endif
CCC_   . other suggestion if error
      if (iErr.ne.0) then
         if (MS.le.0) then
            MSsg = MAX(MAX(0,MD)*_SD_PARA, MAX(0,MC)*_SC_PARA)
         endif
         if (MD.le.0) then
            MDsg = MAX(MAX(0,MS), MAX(0,MC)*_SC_PARA) / _SD_PARA
         endif
         if (MC.le.0) then
            MCsg = MAX(MAX(0,MS), MAX(0,MD)*_SD_PARA) / _SC_PARA
         endif
      endif
c$$$#if TEST_UXUNIT
c$$$      write (*, *) 'CHECK', NKU, NSU, NAU
c$$$      write (*, *) 'CHECK', LKU, LSU, LAU
c$$$      write (*, *) 'SUGGEST', iErr, MSsg, MDsg, MCsg
c$$$#endif
      RETURN
      END
CCC_ & UXAgid  ## Unit/Attribute: get io iunit
      subroutine UXAgid (IFP, KU)
      implicit none
      _INTENT(OUT,integer)   IFP
      _INTENT(IN, integer)   KU(*)
c
      IFP = _LOGU(KU)
      RETURN
      END
CCC_ & UXAgiu  ## Unit/Attribute: get io iunit
      subroutine UXAgiu (IFP, IFPi, KU)
      implicit none
      _INTENT(OUT,integer)   IFP
      _INTENT(IN, integer)   IFPi
      _INTENT(IN, integer)   KU(*)
c
      IFP = IFPi
      if (IFP.lt.IOUNIT_MIN) IFP = _LOGU(KU)
      RETURN
      END
CCC_ & UXAhst  ## Unit/Attribute: get Hash statistics
      subroutine UXAhst (MHU, MHC, KU)
      implicit none
      _INTENT(OUT,integer)   MHU, MHC
      _INTENT(IN, integer)   KU(*)
c
      MHU = _HMAXU(KU)
      MHC = _HMAXC(KU)
      RETURN
      END
CCC_ & UXArng  ## Unit/Attribute: maximum
      subroutine UXArng (LU, LC, KU)
      implicit none
      _INTENT(OUT,integer)   LU, LC
      _INTENT(IN, integer)   KU(*)
c
      LU = _MEMUI(KU)+ _MINUI(KU) -1
      LC = _MEMCI(KU)+ _MINCI(KU) -1
      RETURN
      END
CCC_ & UXAnco  ## Unit/Attribute: count
      subroutine UXAnco (NS, NC, NCTB, KU, AU)
      implicit none
      _INTENT(OUT,integer)   NS, NC, NCTB
      _INTENT(IN, integer)   KU(*)
      _INTENT(IN, character) AU(*)*(*)
      integer ju
c
      NS = 0
      NC = 0
      do ju = _MINUI(KU), _MEMUI(KU)+ _MINUI(KU) -1
         if (_USTR(AU,ju).ne.' ') NS = NS + 1
      enddo
      do ju = _MINCI(KU), _MEMCI(KU)+ _MINCI(KU) -1
         if (_KCOM(KU,_CATTR_POS,ju).ne. _ID_UNDEF)
     $        NC = NC + 1
      enddo
      NCTB = _ICTB(KU)
      RETURN
      END
CCC_ & UXAqui  ## Unit/Attribute: query (signle) unit index by name
      subroutine UXAqui
     O    (iErr, idU,
     I     U,
     M     KU,   AU)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(OUT,  integer)   idU
      _INTENT(IN,   character) U*(*)
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(IN,   character) AU(*)*(*)
      integer j, jh, ju
      integer UXPhds
CCC_  - Body
      iErr = ERR_UNIT_OVERFLOW_SINGLE
      idU  = _ID_UNDEF
c
      jh  = UXPhds(U, _MEMUI(KU), _HASHB(KU), _HASHF(KU))
      do j = 0, _MEMUI(KU) - 1
         ju = MOD (jh + j, _MEMUI(KU)) + _MINUI(KU)
CCC_   . if found set idUo
         if (_USTR(AU,ju).eq.U) then
            idU  = ju
            iErr = 0
            goto 100
CCC_   . if blank set idUo for preparation
         else if (_USTR(AU,ju).eq.' ') then
            idU  = ju
            iErr = ERR_UNIT_NEW_UNIT
            _HMAXU(KU) = MAX(_HMAXU(KU), j)
            goto 100
         endif
      enddo
CCC_   . loop end means overflow
 100  continue
      RETURN
      END
CCC_ & UXAqci  ## Unit/Attribute: query (compound) unit index by ip table
      subroutine UXAqci
     O    (iErr, idU,
     I     ipT,  NipT,
     M     KU)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(OUT,  integer)   idU
      _INTENT(IN,   integer)   ipT  (_IPTBL_MAX, *)
      _INTENT(IN,   integer)   NipT
      _INTENT(INOUT,integer)   KU(*)
      integer jh,  j, ju
      integer jt0, ntm
      integer UXPhdt
      logical Osame
CCC_  - Body
      iErr = ERR_UNIT_OVERFLOW_COMPOUND
      idU  = _ID_UNDEF
c
      jh   = UXPhdt (ipT, NipT, _MEMCI(KU))
      do j = 0, _MEMCI(KU) - 1
         ju  = MOD (jh + j, _MEMCI(KU)) + _MINCI(KU)
         jt0 = _KCOM(KU,_CATTR_POS,ju)
         if (jt0.eq. _ID_UNDEF) then
            iErr = ERR_UNIT_NEW_UNIT
            idU  = ju
            _HMAXC(KU) = MAX(_HMAXC(KU), j)
            goto 200
CC       TODO: same members with different order
         else
            ntm = _KCOM(KU,_CATTR_NUM,ju)
            call UXPteq
     $           (Osame, ipT, NipT, _KCTB(KU,1,jt0), ntm)
            if (Osame) then
               idU  = ju
               iErr = 0
               goto 200
            endif
         endif
      enddo
CCC_   . loop end means overflow
 200  continue
c
      RETURN
      END
CCC_ & UXAqip  ## Unit/Attribute: query ip table by unit index (append)
      subroutine UXAqip
     O    (iErr,
     M     ipT,   NipT, LipT,
     I     idU,
     I     KU)
CCC_  - Declaration
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   idU
      _INTENT(INOUT,integer)   ipT (_IPTBL_MAX, *)
      _INTENT(INOUT,integer)   NipT
      _INTENT(IN,   integer)   LipT
      _INTENT(IN,   integer)   KU(*)
      integer jt0
      integer jx, ntm
CCC_  - Body
      iErr = 0
      if (idU.ge. _MINUI(KU)
     $     .and.idU.lt. _MINUI(KU) + _MEMUI(KU)) then
         NipT = NipT + 1
         if (NipT.gt.LipT) then
            iErr = ERR_UNIT_OVERFLOW_SEQUENCE
         else
            ipT(_IPTBL_ID,  NipT) = idU
            ipT(_IPTBL_POW, NipT) = 1
         endif
CC       to do:  how to pass?
c$$$      else if (idU.ge. _MINDI(KU)
c$$$     $        .and.idU.lt. _MINDI(KU) + _MEMDI(KU)) then
c$$$         continue
      else if (idU.ge. _MINCI(KU)
     $        .and.idU.lt. _MINCI(KU) + _MEMCI(KU)) then
         jt0 = _KCOM(KU,_CATTR_POS,idU)
         ntm = _KCOM(KU,_CATTR_NUM,idU)
         do jx = 0, ntm - 1
            if (iErr.eq.0) then
               call UXPiap
     $             (iErr,
     $              ipT,  NipT, LipT,
     $              _KCTB(KU,_IPTBL_ID, jt0+jx),
     $              _KCTB(KU,_IPTBL_POW,jt0+jx))
            endif
         enddo
      else
         iErr = ERR_UNIT_PANIC
      endif
      if (iErr.eq.0) call UXPnml (iErr, ipT, NipT)
c
      RETURN
      END
CCC_ & UXAnsu  ## Unit/Attribute: register (single) unit
      subroutine UXAnsu
     O    (iErr,
     I     idU,  U,  X, idB,
     M     KU,   SU, AU)
CCC_  - Declaration
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   idU, idB
      _INTENT(IN,   character) U*(*)
      _INTENT(IN,   _REALSTD)  X(*)
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
CCC_  - Body
      iErr  = 0
      if (idU.lt. _MINUI(KU)
     $     .or.idU.ge. _MINUI(KU) + _MEMUI(KU)) then
         iErr = ERR_UNIT_INVALID_SINGLE
      endif
      if (iErr.eq.0) then
         if (_KSNG(KU,_UATTR_BASE,idU).eq. _ID_WAIT) then
            continue
         else if (_USTR(AU,idU).ne.' ') then
            iErr = ERR_UNIT_EXIST_SINGLE
         endif
      endif
      if (iErr.eq.0) then
         _USTR(AU,             idU) = U
         _KSNG(KU, _UATTR_BASE,idU) = idB
         _KSNG(KU, _UATTR_DEC, idU) = _ID_UNDEF
         _CFTS(SU, _COEFF_F,   idU) = X(UXC_F)
         _CFTS(SU, _COEFF_D,   idU) = X(UXC_D)
         _CFTS(SU, _COEFF_M,   idU) = X(UXC_M)
      endif
      RETURN
      END
CCC_ & UXAnsw  ## Unit/Attribute: register (single) unit with switch
      subroutine UXAnsw
     O    (iErr,
     I     idU,  U,  X, idB, KSW,
     M     KU,   SU, AU)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   idU, idB
      _INTENT(IN,   character) U  *(*)
      _INTENT(IN,   _REALSTD)  X(*)
      _INTENT(IN,   integer)   KSW
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
CCC_  - Body
      iErr  = 0
      if (idU.lt. _MINUI(KU)
     $     .or.idU.ge. _MINUI(KU) + _MEMUI(KU)) then
         iErr = ERR_UNIT_INVALID_SINGLE
      endif
      if (iErr.eq.0) then
         if (U.eq.' '.or. _USTR(AU,idU).eq.' ') then
            continue
         else if (_USTR(AU,idU).ne.U) then
            iErr = ERR_UNIT_EXIST_SINGLE
         endif
      endif
      if (iErr.eq.0) then
         if (U.ne.' ') _USTR(AU,idU) = U
         _KSNG(KU, _UATTR_BASE, idU) = idB
         _KSNG(KU, _UATTR_DEC,  idU) = _ID_UNDEF
         if (KSW.lt.0) then
            _CFTS(SU, _COEFF_F, idU) = X(UXC_D)
            _CFTS(SU, _COEFF_D, idU) = X(UXC_F)
            _CFTS(SU, _COEFF_M, idU) = - X(UXC_M)
         else
            _CFTS(SU, _COEFF_F, idU) = X(UXC_F)
            _CFTS(SU, _COEFF_D, idU) = X(UXC_D)
            _CFTS(SU, _COEFF_M, idU) = X(UXC_M)
         endif
      endif
      RETURN
      END
CCC_ & UXAndx  ## Unit/Attribute: register decomposition
      subroutine UXAndx
     O    (iErr,
     I     idU,  X, idB,
     M     KU,   SU, AU)
CCC_  - Declaration
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   idU, idB
      _INTENT(IN,   _REALSTD)  X(*)
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
CCC_  - Body
      iErr  = 0
      if (idU.lt. _MINDI(KU)
     $     .or.idU.ge. _MINDI(KU) + _MEMDI(KU)) then
         iErr = ERR_UNIT_INVALID_DECOMPOSITION
      endif
      if (iErr.eq.0) then
         _KDEC(KU, _DATTR_BASE,idU) = idB
         _KDEC(KU, _DATTR_SRC, idU) = _ID_UNDEF
         _CFTD(SU, _COEFF_F,   idU) = X(UXC_F)
         _CFTD(SU, _COEFF_D,   idU) = X(UXC_D)
         _CFTD(SU, _COEFF_M,   idU) = X(UXC_M)
      endif
      RETURN
      END
CCC_ & UXAncu  ## Unit/Attribute: register (compound) unit
      subroutine UXAncu
     O    (iErr,
     I     idU,  ipT, NipT,
     M     KU)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   idU
      _INTENT(IN,   integer)   ipT (_IPTBL_MAX, *)
      _INTENT(IN,   integer)   NipT
      _INTENT(INOUT,integer)   KU(*)
      integer jt, jt0
CCC_  - Body
      iErr = 0
      if (idU.lt. _MINCI(KU)
     $        .or.idU.ge. _MINCI(KU) + _MEMCI(KU)) then
         iErr = ERR_UNIT_INVALID_COMPOUND
      endif
      if (iErr.eq.0) then
         if (_KCOM(KU,_CATTR_POS,idU).ne. _ID_UNDEF) then
            iErr = ERR_UNIT_EXIST_COMPOUND
         endif
      endif
      if (iErr.eq.0) then
         _KCOM(KU,_CATTR_POS,idU) = _ICTB(KU) + 1
         _ICTB(KU) = _ICTB(KU) + NipT
         if (_ICTB(KU).gt. _LCTB(KU)) then
            iErr = ERR_UNIT_OVERFLOW_TABLE
            _KCOM(KU,_CATTR_NUM,idU) = _ID_UNDEF
         else
            _KCOM(KU,_CATTR_NUM,idU) = NipT
            jt0 = _KCOM(KU,_CATTR_POS,idU) - 1
            do jt = 1, NipT
               _KCTB(KU,_IPTBL_ID, jt0 + jt) = ipT(_IPTBL_ID,  jt)
               _KCTB(KU,_IPTBL_POW,jt0 + jt) = ipT(_IPTBL_POW, jt)
            enddo
         endif
      endif
      RETURN
      END
CCC_ & UXAgxt  ## Unit/Attribute: get coefficients array
      subroutine UXAgxt
     O    (iErr, X,
     I     idU,
     I     KU,   SU)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,_REALSTD)  X(*)
      _INTENT(IN, integer)   idU
      _INTENT(IN, integer)   KU(*)
      _INTENT(IN, _REALSTD)  SU(*)
CCC_  - Body
      iErr = 0
      if (idU.ge. _MINUI(KU)
     $     .and.idU.lt. _MINUI(KU) + _MEMUI(KU)) then
         X(UXC_F) = _CFTS(SU,_COEFF_F,idU)
         X(UXC_D) = _CFTS(SU,_COEFF_D,idU)
         X(UXC_M) = _CFTS(SU,_COEFF_M,idU)
      else if (idU.ge. _MINDI(KU)
     $        .and.idU.lt. _MINDI(KU) + _MEMDI(KU)) then
         X(UXC_F) = _CFTD(SU,_COEFF_F,idU)
         X(UXC_D) = _CFTD(SU,_COEFF_D,idU)
         X(UXC_M) = _CFTD(SU,_COEFF_M,idU)
      else if (idU.ge. _MINCI(KU)
     $        .and.idU.lt. _MINCI(KU) + _MEMCI(KU)) then
         X(UXC_F) = 1.d0
         X(UXC_D) = 1.d0
         X(UXC_M) = 0.d0
      else if (idU.eq._ID_PRIMITIVE) then
         X(UXC_F) = 1.d0
         X(UXC_D) = 1.d0
         X(UXC_M) = 0.d0
      else
         iErr = ERR_UNIT_PANIC
      endif
      RETURN
      END
CCC_ & UXAnch  ## Unit/Attribute: query single/compound status
      subroutine UXAnch
     O    (NCU,
     I     idU, KU)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)  NCU
      _INTENT(IN, integer)  idU
      _INTENT(IN, integer)  KU(*)
CCC_  - Body
      if (idU.ge. _MINUI(KU)
     $     .and.idU.lt. _MINUI(KU) + _MEMUI(KU)) then
         NCU = 0
      else if (idU.ge. _MINDI(KU)
     $        .and.idU.lt. _MINDI(KU) + _MEMDI(KU)) then
         NCU = 0
      else if (idU.ge. _MINCI(KU)
     $        .and.idU.lt. _MINCI(KU) + _MEMCI(KU)) then
         NCU = _KCOM(KU,_CATTR_NUM,idU)
      else if (idU.eq. _ID_PRIMITIVE
     $        .or. idU.eq. _ID_DIMENSIONLESS) then
         NCU = 0
      else
         NCU = -1
      endif
      RETURN
      END
CCC_ & UXAndi  ## Unit/Attribute: allocate decomposition id
      subroutine UXAndi
     O    (iErr, idD,
     M     KU)
CCC_  - Declaration
      _INTENT(OUT,  integer) iErr
      _INTENT(OUT,  integer) idD
      _INTENT(INOUT,integer) KU(*)
CCC_  - Body
      iErr = 0
      _IDEC(KU) = _IDEC(KU) + 1
      if (_IDEC(KU).le. _MEMDI(KU)) then
         idD = _MINDI(KU) + _IDEC(KU) - 1
      else
         idD  = _ID_UNDEF
         iErr = ERR_UNIT_OVERFLOW_DECOMPOSITION
      endif
      RETURN
      END
CCC_ & UXAsdi  ## Unit/Attribute: set decomposition id
      subroutine UXAsdi
     O    (iErr,
     I     idU,  idD,
     M     KU)
CCC_  - Declaration
      _INTENT(OUT,  integer) iErr
      _INTENT(IN,   integer) idU, idD
      _INTENT(INOUT,integer) KU(*)
CCC_  - Body
      iErr = 0
      if (idU.ge. _MINUI(KU)
     $     .and.idU.lt. _MINUI(KU) + _MEMUI(KU)) then
         _KSNG(KU,_UATTR_DEC,idU) = idD
         _KDEC(KU,_DATTR_SRC,idD) = idU
      else if (idU.ge. _MINCI(KU)
     $        .and.idU.lt. _MINCI(KU) + _MEMCI(KU)) then
         _KCOM(KU,_CATTR_DEC,idU) = idD
         _KDEC(KU,_DATTR_SRC,idD) = idU
      else
         iErr = ERR_UNIT_PANIC
      endif
      RETURN
      END
CCC_ & UXAgdi  ## Unit/Attribute: get decomposition id
      subroutine UXAgdi
     O    (iErr,  idD,
     I     idU,   KU)
CCC_  - Declaration
      _INTENT(OUT,integer) iErr
      _INTENT(OUT,integer) idD
      _INTENT(IN, integer) idU
      _INTENT(IN, integer) KU(*)
CCC_  - Body
      iErr = 0
      if (idU.ge. _MINUI(KU)
     $     .and.idU.lt. _MINUI(KU) + _MEMUI(KU)) then
         idD = _KSNG(KU,_UATTR_DEC,idU)
      else if (idU.ge. _MINDI(KU)
     $        .and.idU.lt. _MINDI(KU) + _MEMDI(KU)) then
         idD = idU
      else if (idU.ge. _MINCI(KU)
     $        .and.idU.lt. _MINCI(KU) + _MEMCI(KU)) then
         idD = _KCOM(KU,_CATTR_DEC,idU)
      else
         iErr = ERR_UNIT_PANIC
         idD  = _ID_UNDEF
      endif
      RETURN
      END
CCC_ & UXAgds  ## Unit/Attribute: get decomposition source
      subroutine UXAgds
     O    (iErr,  idS,
     I     idU,   KU)
CCC_  - Declaration
      _INTENT(OUT,integer) iErr
      _INTENT(OUT,integer) idS
      _INTENT(IN, integer) idU
      _INTENT(IN, integer) KU(*)
CCC_  - Body
      iErr = 0
      idS = _ID_UNDEF
      if (idU.ge. _MINUI(KU)
     $     .and.idU.lt. _MINUI(KU) + _MEMUI(KU)) then
         continue
      else if (idU.ge. _MINDI(KU)
     $        .and.idU.lt. _MINDI(KU) + _MEMDI(KU)) then
         idS = _KDEC(KU,_DATTR_SRC,idU)
      else if (idU.ge. _MINCI(KU)
     $        .and.idU.lt. _MINCI(KU) + _MEMCI(KU)) then
         continue
      else
         iErr = ERR_UNIT_PANIC
      endif
      RETURN
      END
CCC_ & UXAqun  ## Unit/Attribute: query unit/compound string by id
      subroutine UXAqun
     O    (iErr, U,
     I     idU,  Sep,
     I     KU,   AU)
CCC_  - Declaration
      _INTENT(OUT,  integer)   iErr
      _INTENT(OUT,  character) U*(*)
      _INTENT(IN,   integer)   idU
      _INTENT(IN,   character) Sep*(*)
      _INTENT(IN,   integer)   KU(*)
      _INTENT(IN,   character) AU(*)*(*)
      integer jt0, ntm
CCC_  - Body
      iErr = 0
      if (idU.ge. _MINUI(KU)
     $     .and.idU.lt. _MINUI(KU) + _MEMUI(KU)) then
         U = _USTR(AU,idU)
      else if (idU.ge. _MINDI(KU)
     $        .and.idU.lt. _MINDI(KU) + _MEMDI(KU)) then
         if (idU - _MINDI(KU).ge. _IDEC(KU)) then
            U = ' '
         else
            U = '$D'
         endif
      else if (idU.ge. _MINCI(KU)
     $        .and.idU.lt. _MINCI(KU) + _MEMCI(KU)) then
         ntm = _KCOM(KU,_CATTR_NUM,idU)
         jt0 = _KCOM(KU,_CATTR_POS,idU)
         if (jt0.eq. _ID_UNDEF) then
            U = ' '
         else
            call UXPgst
     O          (iErr,    U,
     I           _KCTB(KU,1,jt0), ntm, AU, _MEMUI(KU), Sep)
         endif
      else if (idU.eq. _ID_PRIMITIVE) then
         U = '$P'
      else if (idU.eq. _ID_DIMENSIONLESS) then
         U = '$1'
      else
         iErr = ERR_UNIT_PANIC
         U   = ' '
      endif
c
      RETURN
      END
CCC_ & UXAgbi  ## Unit/Attribute: get base id
      subroutine UXAgbi
     O    (iErr,  idB,
     I     idU,   KU)
CCC_  - Declaration
      _INTENT(OUT,integer) iErr
      _INTENT(OUT,integer) idB
      _INTENT(IN, integer) idU
      _INTENT(IN, integer) KU(*)
CCC_  - Body
      iErr = 0
      if (idU.ge. _MINUI(KU)
     $     .and.idU.lt. _MINUI(KU) + _MEMUI(KU)) then
         idB  = _KSNG(KU,_UATTR_BASE,idU)
      else if (idU.ge. _MINDI(KU)
     $        .and.idU.lt. _MINDI(KU) + _MEMDI(KU)) then
         idB  = _KDEC(KU,_DATTR_BASE,idU)
      else
         iErr = ERR_UNIT_PANIC
         idB  = _ID_UNDEF
      endif
      RETURN
      END
CCC_ & UXAgcp  ## Unit/Attribute: generate coeff-power table
      subroutine UXAgcp
     O    (iErr,
     O     cpT,  NcpT, LcpT,
     I     idU,
     I     KU,   SU)
CCC_  - Declaration
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   idU
      _INTENT(OUT,_REALSTD)  cpT (_CPTBL_MAX, *)
      _INTENT(OUT,integer)   NcpT
      _INTENT(IN, integer)   LcpT
      _INTENT(IN, integer)   KU(*)
      _INTENT(IN, _REALSTD)  SU(*)
      _REALSTD PW
CCC_  - Body
      NcpT = 0
CC    single
      if (idU.ge. _MINUI(KU)
     $     .and.idU.lt. _MINUI(KU) + _MEMUI(KU)) then
         iErr = 0
         PW   = 1.d0
         if (iErr.eq.0) then
            call UXPstc
     $           (iErr, cpT, NcpT, LcpT, _CFTS(SU,_COEFF_F,idU), PW)
         endif
         if (iErr.eq.0) then
            call UXPstc
     $           (iErr, cpT, NcpT, LcpT, _CFTS(SU,_COEFF_D,idU), -PW)
         endif
         if (iErr.eq.0) then
            PW = _CFTS(SU,_COEFF_M, idU)
            call UXPstc (iErr, cpT, NcpT, LcpT, 10.d0, PW)
         endif
      else if (idU.ge. _MINDI(KU)
     $        .and.idU.lt. _MINDI(KU) + _MEMDI(KU)) then
         iErr = 0
         PW   = 1.d0
         if (iErr.eq.0) then
            call UXPstc
     $           (iErr, cpT, NcpT, LcpT, _CFTD(SU,_COEFF_F,idU), PW)
         endif
         if (iErr.eq.0) then
            call UXPstc
     $           (iErr, cpT, NcpT, LcpT, _CFTD(SU,_COEFF_D,idU), -PW)
         endif
         if (iErr.eq.0) then
            PW = _CFTD(SU,_COEFF_M, idU)
            call UXPstc (iErr, cpT, NcpT, LcpT, 10.d0, PW)
         endif
      else
         iErr = ERR_UNIT_INVALID_SINGLE
      endif
      RETURN
      END
CCC_ & UXAxpn  ## Unit/Attribute: expansion
      subroutine UXAxpn
     O    (iErr,
     M     ipT,  NipT, LipT,
     M     cpT,  NcpT, LcpT,
     I     KU,   SU)
CCC_  - Declaration
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,integer)   ipT (_IPTBL_MAX, *)
      _INTENT(INOUT,_REALSTD)  cpT (_CPTBL_MAX, *)
      _INTENT(IN,   integer)   LipT, LcpT
      _INTENT(INOUT,integer)   NipT, NcpT
      _INTENT(IN,   integer)   KU(*)
      _INTENT(IN,   _REALSTD)  SU(*)
      integer    jt, jstg
      integer    jb, ju
      integer    jp, jt0, jtn, jx
      integer    LimXp
      parameter (LimXp  = OPT_UNIT_EXPANSION_LOOP)
      _REALSTD   PW
CCC_  - Body
      iErr = 0
      jt   = 1
      jstg = 0
      DO
         if (jstg.gt.LimXp) iErr = ERR_UNIT_PANIC
         if (iErr.ne.0)   goto 500
c
         if (jt.gt.NipT) goto 500
         ju = ipT(_IPTBL_ID, jt)
         jp = ipT(_IPTBL_POW,jt)
         PW = _XREALS(jp)
         if (ju.ge. _MINUI(KU)
     $     .and.ju.lt. _MINUI(KU) + _MEMUI(KU)) then
            jb = _KSNG(KU,_UATTR_BASE,ju)
            if (iErr.eq.0) then
               call UXPstc
     $              (iErr, cpT, NcpT, LcpT, _CFTS(SU,_COEFF_F,ju), PW)
            endif
            if (iErr.eq.0) then
               call UXPstc
     $              (iErr, cpT, NcpT, LcpT, _CFTS(SU,_COEFF_D,ju), -PW)
            endif
            if (iErr.eq.0) then
               PW = _CFTS(SU,_COEFF_M, ju) * PW
               call UXPstc
     $              (iErr, cpT, NcpT, LcpT, 10.d0, PW)
            endif
         else
            jb = ju
         endif
         if (iErr.eq.0) then
            if (jb.eq. _ID_DIMENSIONLESS) then
               ipT(_IPTBL_ID, jt) = jb
               jt = jt + 1
            else if (jb.le.0) then
               jt = jt + 1
            else if (jb.ge.1.and.jb.le. _MEMUI(KU)) then
               ipT(_IPTBL_ID, jt) = jb
            else if (jb.ge. _MINCI(KU)
     $              .and.jb.lt. _MINCI(KU) + _MEMCI(KU)) then
               jt0 = _KCOM(KU,_CATTR_POS,jb)
               jtn = _KCOM(KU,_CATTR_NUM,jb)
               ipT(_IPTBL_ID,  jt) = _ID_DIMENSIONLESS
               ipT(_IPTBL_POW, jt) = 0
               do jx = 0, jtn - 1
                  if (iErr.eq.0) then
                     call UXPiap
     $                   (iErr,
     $                    ipT, NipT, LipT,
     $                    _KCTB(KU,_IPTBL_ID, jt0+jx),
     $                    _KCTB(KU,_IPTBL_POW,jt0+jx) * jp)
                  endif
               enddo
               jt = jt + 1
            else
               iErr = ERR_UNIT_PANIC
               goto 500
            endif
         endif
c$$$ 510     continue
         jstg = jstg + 1
      ENDDO
 500  continue
      if (iErr.eq.0) then
         call UXPnml (iErr, ipT, NipT)
      endif
c
      RETURN
      END
CCC_* [UXP] primitive utilities
CCC_ & UXPhds ()  ## Unit/primitive: Hash decomposition (string)
      integer function UXPhds (U, nMem, IBS, IBF)
CCC_  - Declaration
      implicit none
      _INTENT(IN,character) U*(*)
      _INTENT(IN,integer)   nMem
      _INTENT(IN,integer)   IBS, IBF
      integer    mTbl
      parameter (mTbl = OPT_UNIT_LEN)
      integer    kTbl (mTbl)
      integer    UXFc2k, UXFghs
      integer    lt0, lt1, i
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
CCC_  - Body
      lt0 = 1
      lt1 = MIN (len_trim (U), mTbl)
      do i = 1, lt1
         kTbl (i) = UXFc2k (U (i:i))
      enddo
      UXPhds = UXFghs (kTbl, lt0, lt1, nmem, IBS, IBF)
      RETURN
      END
CCC_ & UXPhdt ()  ## Unit/primitive: Hash decomposition (table)
      integer function UXPhdt (ipTbl, NipT, nMem)
CCC_  - Declaration
      implicit none
      _INTENT(IN,integer) ipTbl(_IPTBL_MAX, *)
      _INTENT(IN,integer) NipT
      _INTENT(IN,integer) nMem
      integer jt
      integer ji, jp, js
      integer jh
CCC_  - Body
      jh = 0
      do jt = 1, NipT
         js = ISIGN(1, ipTbl(_IPTBL_POW, jt))
         ji = ipTbl(_IPTBL_ID, jt)
         jp = IABS(ipTbl(_IPTBL_POW, jt))
         jh = jh + MOD(js * (ji * jp), nMem)
      enddo
      UXPhdt = Mod((jh + nMem), nMem)
      RETURN
      END
CCC_ & UXPteq  ## Unit/Primitive: check if equal ip table
      subroutine UXPteq
     O    (Osame,
     I     iTbl0, N0,
     I     iTbl1, N1)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,logical) Osame
      _INTENT(IN, integer) iTbl0(_IPTBL_MAX, *)
      _INTENT(IN, integer) iTbl1(_IPTBL_MAX, *)
      _INTENT(IN, integer) N0, N1
      integer ja, jx
CCC_  - Body
      if (N0.ne.N1) then
         Osame = .FALSE.
         RETURN
      endif
c
      Osame = .TRUE.
      do jx = 1, N0
         do ja = 1, _IPTBL_MAX
            if (iTbl0(ja, jx).ne.iTbl1(ja,jx)) then
               Osame = .false.
               goto 100
            endif
         enddo
      enddo
 100  continue
c
      RETURN
      END
CCC_ & UXPiap  ## Unit/Primitive: append item to table
      subroutine UXPiap
     O    (iErr,
     M     ipT, Nip, Lip,
     I     idU, ipw)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,integer)   ipT (_IPTBL_MAX, *)
      _INTENT(INOUT,integer)   Nip
      _INTENT(IN,   integer)   Lip
      _INTENT(IN,   integer)   idU
      _INTENT(IN,   integer)   ipw
      integer jt
CCC_  - Body
      iErr = 0
      do jt = 1, Nip
         if (ipT(_IPTBL_ID, jt).eq.idU) then
            ipT(_IPTBL_POW, jt) = ipT(_IPTBL_POW, jt) + ipw
            goto 100
         endif
      enddo
      Nip = Nip + 1
      if (Nip.le.Lip) then
         ipT(_IPTBL_ID,  Nip) = idU
         ipT(_IPTBL_POW, Nip) = ipw
      else
         iErr = ERR_UNIT_OVERFLOW_SEQUENCE
      endif
 100  continue
      RETURN
      END
CCC_ & UXPnml  ## Unit/Primitive: table contraction/normalization
      subroutine UXPnml
     O    (iErr,
     M     ipT, Nip)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,integer)   ipT (_IPTBL_MAX, *)
      _INTENT(INOUT,integer)   Nip
      integer js, jd, ja, jtgt
      integer nsrt
      integer kBF(_IPTBL_MAX)
CCC_  - Body
      iErr = 0
      nsrt = 1
      do js = 2, Nip
         jtgt = nsrt + 1
         do jd = 1, nsrt
            if (ipT(_IPTBL_ID, jd).eq.ipT(_IPTBL_ID, js)) then
               ipT(_IPTBL_POW,jd) =
     $              ipT(_IPTBL_POW,jd) + ipT(_IPTBL_POW,js)
               goto 100
            else if (ipT(_IPTBL_ID, jd).ge.ipT(_IPTBL_ID, js)) then
               jtgt = jd
               goto 200
            endif
         enddo
 200     continue
         do ja = 1, _IPTBL_MAX
            kBF (ja) = ipT(ja, js)
         enddo
         call UXPshf (ipT, nsrt, jtgt, +1)
         do ja = 1, _IPTBL_MAX
            ipT(ja, jtgt) = kBF (ja)
         enddo
         nsrt = nsrt + 1
 100     continue
      enddo
      Nip = nsrt
      do js = nsrt, 1, -1
         if (ipT(_IPTBL_POW,js).eq.0
     $        .or. ipT(_IPTBL_ID,js).eq. _ID_DIMENSIONLESS) then
            call UXPshf(ipT, Nip, js + 1, -1)
            Nip = Nip - 1
         endif
      enddo
      RETURN
      END
CCC_ & UXPshf  ## Unit/Primitive: shift
      subroutine UXPshf
     M     (ipT, nt, ipos, idir)
CCC_  - Declaration
      implicit none
      _INTENT(INOUT,integer) ipT(_IPTBL_MAX, *)
      _INTENT(IN,   integer) nt, ipos, idir
      integer jd, ja
CCC_  - Body
      if (idir.gt.0) then
         do jd = nt, ipos, -1
            do ja = 1, _IPTBL_MAX
               ipT (ja, jd + idir) = ipT(ja, jd)
            enddo
         enddo
      else if (idir.lt.0) then
         do jd = ipos, nt
            do ja = 1, _IPTBL_MAX
               ipT (ja, jd + idir) = ipT(ja, jd)
            enddo
         enddo
      endif
      RETURN
      END
CCC_ & UXPstc  ## Unit/Primitive: coefficient contraction
      subroutine UXPstc
     O    (iErr,
     M     cpT, NcpT, LcpT,
     I     Cf,  Pw)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,_REALSTD)  cpT (_CPTBL_MAX, *)
      _INTENT(INOUT,integer)   NcpT
      _INTENT(IN,   integer)   LcpT
      _INTENT(IN,   _REALSTD)  Cf
      _INTENT(IN,   _REALSTD)  Pw
      integer j
CCC_  - Body
      iErr = 0
      do j = 1, NcpT
         if (cpT(_CPTBL_CF, j) .eq. Cf) then
            cpT(_CPTBL_POW, j) = cpT(_CPTBL_POW, j) + Pw
            goto 100
         endif
      enddo
      NcpT = NcpT + 1
      if (NcpT.le.LcpT) then
         cpT (_CPTBL_CF,  NcpT) = Cf
         cpT (_CPTBL_POW, NcpT) = Pw
      else
         iErr = ERR_UNIT_OVERFLOW_SEQUENCE
      endif
 100  continue
      RETURN
      END
CCC_ & UXPgca  ## Unit/Primitive: generate scale string from coeff array
      subroutine UXPgca
     O    (iErr, CF,
     I     FDM,  kDIR, Sep)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,character) CF*(*)
      _INTENT(IN, _REALSTD)  FDM(*)
      _INTENT(IN, integer)   kDIR
      _INTENT(IN, character) Sep*(*)
      _REALSTD PW
      integer  NcpT, LcpT
      parameter (LcpT = 3)
      _REALSTD cpT(_CPTBL_MAX, LcpT)
      _REALSTD S
CCC_  - Body
      iErr = 0
      NcpT = 0
      cpT(_CPTBL_CF,  1) = 1.d0
      cpT(_CPTBL_POW, 1) = 0.d0
      S = _XREALS(SIGN(1, kDIR))

      if (iErr.eq.0) then
         PW = + S * 1.d0
         call UXPstc
     $        (iErr, cpT, NcpT, LcpT, FDM(UXC_F), PW)
      endif
      if (iErr.eq.0) then
         PW = - S * 1.d0
         call UXPstc
     $        (iErr, cpT, NcpT, LcpT, FDM(UXC_D), PW)
      endif
      if (iErr.eq.0) then
         PW = S * FDM(UXC_M)
         call UXPstc
     $        (iErr, cpT, NcpT, LcpT, 10.d0, PW)
      endif
      if (iErr.eq.0) then
         call UXPgcs (iErr, CF, cpT, NcpT, Sep)
      else
         CF = ' '
      endif
      RETURN
      END
CCC_ & UXPc2f  ## Unit/Primitive: coeff-power table to scale sequence
      subroutine UXPc2f
     O    (iErr,  FDM,
     I     cpTbl, NcpT, KLV)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(OUT,  _REALSTD)  FDM(*)
      _INTENT(INOUT,_REALSTD)  cpTbl (_CPTBL_MAX, *)
      _INTENT(IN,   integer)   NcpT
      _INTENT(IN,   integer)   KLV
      integer    jt
      _REALSTD   C, P
      _REALSTD   F, D, EP, EN
      _REALSTD   T10, T0
CCC_  - Body
      iErr = 0
c
      T10 = 10.d0
      T0  = 0.d0
      F   = 1.d0
      D   = 1.d0
      EP  = 0.d0
      EN  = 0.d0
      do jt = 1, NcpT
         C = cpTbl (_CPTBL_CF,  jt)
         P = cpTbl (_CPTBL_POW, jt)
         if (C.eq.T10) then
            if (P.gt.T0) then
               EP = EP + P
            else if (P.lt.T0) then
               EN = EN - P
            endif
         else if (C.eq.T0) then
            F = T0
            D = T0
         else if (P.gt.T0) then
            F = F * (C ** P)
         else if (P.lt.T0) then
            D = D * (C ** (-P))
         endif
      enddo
CCC_   . store result
      if      (KLV.eq. UXLEV_F)   then
         F = F * (T10 ** EP)
         D = D * (T10 ** EN)
         FDM(UXC_F) = F / D
      else if (KLV.eq. UXLEV_FD)  then
         FDM(UXC_F) = F * (T10 ** EP)
         FDM(UXC_D) = D * (T10 ** EN)
      else if (KLV.eq. UXLEV_FDM) then
         FDM(UXC_F) = F
         FDM(UXC_D) = D
         FDM(UXC_M) = EP - EN
      else
         iErr = ERR_UNIT_INVALID_SWITCH
      endif
      RETURN
      END
CCC_ & UXPf2c  ## Unit/Primitive: scale sequence to coeff-power table
      subroutine UXPf2c
     O    (iErr,
     O     cpTbl, NcpT, LcpT,
     I     FDM,   KLV)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)  iErr
      _INTENT(OUT,_REALSTD) cpTbl (_CPTBL_MAX, *)
      _INTENT(OUT,integer)  NcpT
      _INTENT(IN, integer)  LcpT
      _INTENT(IN, _REALSTD) FDM(*)
      _INTENT(IN, integer)  KLV
      _REALSTD   PW
      logical    OF, OD, OM
CCC_  - Body
      iErr = 0
      NcpT = 0
      if (KLV.eq. UXLEV_FDM) then
         OF = .TRUE.
         OD = .TRUE.
         OM = .TRUE.
      else if (KLV.eq. UXLEV_FD) then
         OF = .TRUE.
         OD = .TRUE.
         OM = .FALSE.
      else if (KLV.eq. UXLEV_F) then
         OF = .TRUE.
         OD = .FALSE.
         OM = .FALSE.
      else
         OF = .FALSE.
         OD = .FALSE.
         OM = .FALSE.
         iErr = ERR_UNIT_INVALID_SWITCH
      endif
      if (iErr.eq.0.and.OF) then
         PW   = 1.d0
         call UXPstc (iErr, cpTbl, NcpT, LcpT, FDM(UXC_F), PW)
      endif
      if (iErr.eq.0.and.OD) then
         PW   = - 1.d0
         call UXPstc (iErr, cpTbl, NcpT, LcpT, FDM(UXC_D), PW)
      endif
      if (iErr.eq.0.and.OM) then
         PW = FDM(UXC_M)
         call UXPstc (iErr, cpTbl, NcpT, LcpT, 10.d0, PW)
      endif

      RETURN
      END
CCC_ & UXPgcs  ## Unit/Primitive: generate scale string from coeff-power seq
      subroutine UXPgcs
     O    (iErr,   CF,
     I     cpT,    ncpT,
     I     Sep)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,character) CF*(*)
      _INTENT(IN, integer)   NcpT
      _INTENT(IN, _REALSTD)  cpT  (_CPTBL_MAX, *)
      _INTENT(IN, character) Sep*(*)
c
      integer   jt
      character Tbf*(256)
      _REALSTD  TC, TP
CCC_  - Body
      iErr = 0
      CF   = ' '
      do jt = 1, ncpT
         TC = cpT(_CPTBL_CF, jt)
         TP = cpT(_CPTBL_POW, jt)
         if (TC .eq. 0.d0) then
            call USJsta (CF, Sep, '0')
         else if (TC .eq. 1.d0
     $        .or. TP.eq. 0.d0) then
            continue
         else
            call USGlfs (Tbf, _XREALS(TC), 'CI')
            call USJsta (CF, Sep, Tbf)
            if (TP.ne. 1.d0) then
               call USGlfs (Tbf, _XREALS(TP), 'CI')
               call USJnta (CF, '^', Tbf)
            endif
         endif
      enddo
      if (CF.ne.' ') call USMmlc(CF, Sep)
      RETURN
      END
CCC_ & UXPgst  ## Unit/Primitive: id array to unit string conversion
      subroutine UXPgst
     O    (iErr,  US,
     I     ipT,   NipT,
     I     Utbl,  Ltbl,
     I     Sep)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,character) US*(*)
      _INTENT(IN, integer)   ipT(_IPTBL_MAX,*)
      _INTENT(IN, integer)   NipT
      _INTENT(IN, character) Utbl(*)*(*)
      _INTENT(IN, integer)   Ltbl
      _INTENT(IN, character) Sep*(*)
      integer jt, ju, jp, l
      character Tx*(24)
      character Tstr*(128)
#if HAVE_F77_VERIFY == 0
      integer verify
#endif
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
CCC_  - Body
      iErr = 0
      US   = ' '
      do jt = 1, NipT
         ju = ipT(_IPTBL_ID, jt)
         jp = ipT(_IPTBL_POW,jt)
         if (ju.ge.1.and.ju.le.Ltbl) then
            if (jp.ne.0) then
               call USJsta (US, Sep, Utbl(ju))
               if (jp.ne.1) then
                  call USGlni (Tx, jp)
                  call USJnta (Us, '^', Tx)
               endif
            endif
         else if (ju.gt.0) then
            if (jp.ne.0) then
               TSTR = '$C'
               call USGani(Tstr, ju)
               call USJsta (US, Sep, tstr)
               if (jp.ne.1) then
                  call USGlni (Tx, jp)
                  call USJnta (Us, '^', Tx)
               endif
            endif
         else
            iErr = ERR_UNIT_INVALID_TABLE
         endif
      enddo
      if (iErr.eq.0) then
#if HAVE_F77_ADJUSTL == 0
         call ufadjl (US)
#else
         US = ADJUSTL (US)
#endif
         jp = verify(US, Sep, .false.)
         l  = len_trim(US)
         US = US(jp:l)
      endif
      RETURN
      END
CCC_ & UXPnew  ## Unit/Primitive: parser wrapper (new)
      subroutine UXPnew
     O    (iErr,
     M     uSeq,  ixSeq, nSeq, lSeq,
     I     DefS)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   nSeq
      _INTENT(IN, integer)   lSeq
      _INTENT(OUT,integer)   ixSeq (lSeq)
      _INTENT(OUT,character) uSeq  (lSeq)*(*)
      _INTENT(IN, character) DefS*(*)
CCC_  - Body
      nSeq = 0
      call UXPprc (iErr, uSeq, ixSeq, nSeq, lSeq, DefS)
      RETURN
      END
CCC_ & UXPprc  ## Unit/Primitive: parser core
      subroutine UXPprc
     O    (iErr,
     M     uSeq,  ixSeq, nSeq, lSeq,
     I     DefS)
CCC_  - Description
CC    Parse DefS into [uSeq (nSeq) ixSeq (nSeq)], which contains
CC    {(unit, power), (unit, power), ...}.
CC
CC    ixSeq, nSeq: to be modified
CC    set nSeq = 0 if new parse,
CC    otherwise new units are appended
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,integer)   nSeq
      _INTENT(IN,   integer)   lSeq
      _INTENT(OUT,  integer)   ixSeq (lSeq)
      _INTENT(OUT,  character) uSeq  (lSeq)*(*)
      _INTENT(IN,   character) DefS*(*)
      integer   lp, ll
      integer   ipN0, ipN1
      integer   ipC0, ipC1
      integer   nExp
      character C * (2)
      character CST
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
      integer   lE
      integer   jSW
CCC_  - Body
      iErr = 0
c$$$      nSeq = 0
c
      ll   = len_trim (DefS)
      lp   = 1
      CST  = 'P'
      ipN0 = -1
      ipN1 = -1
      ipC0 = -1
      ipC1 = -1
      jSW  = 1
CC status 'P' (waiting for unit/dimension start)
CC status 'U' (waiting for unit/dimension end)
CC status '^' (waiting for '^')
CC status 'E' (waiting for exponent start)
CC status 'N' (waiting for exponent end)
CC status '.' (need parse)
CCC_  - infinite loop
      lE = 0
#     ifdef _DBG_UNIT_PARSER
      write (*, *) 'INPUT: ', DefS
#     endif
      DO
CCC_   . Prevent unintentional loop
         if (lE.gt.ll + 100) then
            iErr = -999
            goto 900
         endif
         lE = lE + 1
CCC_   . Break
         if (lp.gt.ll) then
            if (CST.eq.'P') goto 900
            C = '$$'
         else
            C = DefS (lp:lp)
        endif
#        ifdef _DBG_UNIT_PARSER
         write (*, *) '  STEP', lp, CST, ' <', C, '>'
#        endif
CCC_   . waiting for unit/dimension start
         if (CST.eq.'P') then
            if (C.eq. _CHAR_DIV) then
               jSW = -1
            else if (C.eq. _CHAR_IGNORE) then
               continue
            else if (C.ne.' ') then
               ipC0 = lp
               CST  = 'U'
               nExp = 1
            endif
         endif
CCC_   . waiting for unit/dimension end
         if (CST.eq.'U') then
            if (C.eq.' ') then
               ipC1 = lp - 1
               CST = '^'
            else if (C.eq. _CHAR_IGNORE) then
               ipC1 = lp - 1
               CST = '.'
            else if (C.eq. _CHAR_POW) then
               ipC1 = lp - 1
               CST = 'E'
            else if (C.eq. _CHAR_DIV) then
               lp   = lp - 1
               ipC1 = lp
               CST = '.'
            else if (C.eq.'$$') then
               ipC1 = lp - 1
               CST = '.'
            endif
         endif
CCC_   . waiting for '^'
         if (CST.eq.'^') then
            if (C.eq. _CHAR_POW) then
               CST = 'E'
            else if (C.eq.' ') then
               continue
            else
               lp = lp - 1
               CST = '.'
            endif
         endif
CCC_   . waiting for exponent start
         if (CST.eq.'E') then
            if (INDEX ('+-', C (1:1)).gt.0) then
               ipN0 = lp
               CST = 'N'
               goto 100
            else if (INDEX ('0123456789', C (1:1)).gt.0) then
               ipN0 = lp
               CST = 'N'
            else if (C.eq.'$$') then
               CST = '.'
            else
               continue
            endif
         endif
CCC_   . waiting for exponent end
         if (CST.eq.'N') then
            if (INDEX ('0123456789', C (1:1)).gt.0) then
               continue
            else
               ipN1 = lp - 1
               lp   = lp - 1
               read (DefS (ipN0:ipN1), *) nExp
               CST = '.'
            endif
         endif
CCC_   . final parse
         if (CST.eq.'.') then
#           ifdef _DBG_UNIT_PARSER
            write (*, *) '  FIN ', nExp, JSW, nSeq, DefS (ipC0:ipC1)
#           endif
            nSeq = nSeq + 1
            if (nSeq.le.lSeq) then
               ixSeq (nSeq) = nExp * jSW
               uSeq  (nSeq) = DefS (ipC0:ipC1)
            else
               iErr = ERR_UNIT_OVERFLOW_SEQUENCE
               goto 900
            endif
            CST = 'P'
         endif
CCC_   . next
 100     continue
         lp = lp + 1
CCC_  - infinite loop done
      ENDDO
 900  continue
      RETURN
      END
CCC_* [UXF] misc. Functions
CCC_ & UXFghs ()  ## Unit/Function: decomposition core
      integer function UXFghs (Itbl, MinT, MaxT, nMem, IBS, IBF)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer) MinT, MaxT
      _INTENT(IN, integer) nMem
      _INTENT(IN, integer) Itbl (MinT:MaxT)
      _INTENT(IN, integer) IBS, IBF
      integer i
CCC_  - Body
      UXFghs = 0
      do i = MinT, MaxT - 1
         UXFghs = MOD (IBS * UXFghs + Itbl (i), nmem)
      enddo
      UXFghs = MOD (IBS * UXFghs + IBF * Itbl (MaxT), nmem)

      UXFghs = MAX (UXFghs, (nmem + UXFghs))
      UXFghs = MOD (UXFghs,  nmem)
      RETURN
      END
#define _UXF_STRING_SEQUENCE '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ.#:@_'
CCC_ & UXFc2k ()  ## Unit/Function: char to intermediate index
      integer function UXFc2k (PC)
      implicit none
      _INTENT(IN,character) PC*(*)
      character C*(1)
c
      C = PC (1:1)
      if (C.eq.' ') C = '0'
#     if     HAVE_F77_ICHAR == 1
      UXFc2k = ICHAR (C)
#     else  /* not HAVE_F77_ICHAR */
CC NOTE: Not fully functional
      UXFc2k = INDEX
     $     (_UXF_STRING_SEQUENCE, C)
#     endif /* not HAVE_F77_ICHAR */
      RETURN
      END
CCC_ & UXFk2c ()  ## Unit/Function: intermediate index to char
      character function UXFk2c (K)
      implicit none
      _INTENT(IN,integer) K
      character  PSTR*(*)
      parameter (PSTR = _UXF_STRING_SEQUENCE)
c
#     if     HAVE_F77_ICHAR == 1
      UXFk2c = CHAR (K)
#     else  /* not HAVE_F77_ICHAR */
      UXFk2c = PSTR (K:K)
#     endif /* not HAVE_F77_ICHAR */
      RETURN
      END
CCC_& UXiniS  ## Unison/Unit initialization default system
      subroutine UXiniS
     O    (iErr,
     M     KU,  SU, AU, KSW)
CCC_ + Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
      _INTENT(IN,   integer)   KSW
      _REALSTD qpi
CCC_ + Body
      iErr = 0 * KSW
CCC_  - Registration primitives
      if (iErr.eq.0)
     $     call UXSdpc (iErr, 'm',      'LENGTH',      KU,SU,AU)
      if (iErr.eq.0)
     $     call UXSdpc (iErr, 'kg',     'MASS',        KU,SU,AU)
      if (iErr.eq.0)
     $     call UXSdpc (iErr, 's',      'TIME',        KU,SU,AU)
      if (iErr.eq.0)
     $     call UXSdpc (iErr, 'K',      'TEMPERATURE', KU,SU,AU)
      if (iErr.eq.0)
     $     call UXSdpc (iErr, 'radian', 'ANGLE',       KU,SU,AU)
      if (iErr.eq.0)
     $     call UXSdpc (iErr, 'mol',    'AMOUNT',      KU,SU,AU)
CCC_  - Registration dimensionless
      if (iErr.eq.0) call UXSdco (iErr, '1', 1.d0,    KU,SU,AU)
CCC_  - Registration compounds
      if (iErr.eq.0)
     $     call UXSdal (iErr, 'AREA',   'LENGTH^2',    KU,SU,AU)
      if (iErr.eq.0)
     $     call UXSdal (iErr, 'VOLUME', 'LENGTH^3',    KU,SU,AU)
      if (iErr.eq.0)
     $     call UXSdal
     $     (iErr, 'FORCE',    'MASS LENGTH TIME^-2',   KU,SU,AU)
      if (iErr.eq.0)
     $     call UXSdal
     $     (iErr, 'DENSITY',  'MASS VOLUME^-1',        KU,SU,AU)
      if (iErr.eq.0)
     $     call UXSdal
     $     (iErr, 'STRESS',   'FORCE AREA^-1',         KU,SU,AU)
      if (iErr.eq.0)
     $     call UXSdal
     $     (iErr, 'ENERGY',   'FORCE LENGTH',          KU,SU,AU)
      if (iErr.eq.0)
     $     call UXSdal
     $     (iErr, 'POWER',    'ENERGY TIME^-1',        KU,SU,AU)
      if (iErr.eq.0)
     $     call UXSdal
     $     (iErr, 'VELOCITY', 'LENGTH TIME^-1',        KU,SU,AU)
      if (iErr.eq.0)
     $     call UXSdal
     $     (iErr, 'ACCELERATION', 'VELOCITY TIME^-1',  KU,SU,AU)
      if (iErr.eq.0)
     $     call UXSdal
     $     (iErr, 'SP.H.CAP', 'ENERGY MASS^-1 TEMPERATURE^-1',KU,SU,AU)
      if (iErr.eq.0)
     $     call UXSdal
     $     (iErr, 'TH.COND', 'POWER LENGTH^-1 TEMPERATURE^-1',KU,SU,AU)
      if (iErr.eq.0)
     $     call UXSdal (iErr, 'STR.RATE', 'TIME^-1',          KU,SU,AU)
c
      if (iErr.eq.0) call UXSdal (iErr, 'N',  'kg m s^-2',   KU,SU,AU)
      if (iErr.eq.0) call UXSdal (iErr, 'Pa', 'N m^-2',      KU,SU,AU)
      if (iErr.eq.0) call UXSdal (iErr, 'J',  'N m',         KU,SU,AU)
      if (iErr.eq.0) call UXSdal (iErr, 'W',  'J s^-1',      KU,SU,AU)
CCC_  - Registration (scaled) units
CCC_   . Length
      if (iErr.eq.0) call UXSdmi(iErr, 'km', +3, 'm',        KU,SU,AU)
      if (iErr.eq.0) call UXSdmi(iErr, 'cm', -2, 'm',        KU,SU,AU)
      if (iErr.eq.0) call UXSdmi(iErr, 'mm', -3, 'm',        KU,SU,AU)
CCC_   . Time standard
      if (iErr.eq.0) call UXSdfi (iErr, 'min', 60, 's',      KU,SU,AU)
      if (iErr.eq.0) call UXSdfi (iErr, 'hr',  60, 'min',    KU,SU,AU)
      if (iErr.eq.0) call UXSdfi (iErr, 'day', 24, 'hr',     KU,SU,AU)
      if (iErr.eq.0) call UXSdfi (iErr, 'yr',  31556926, 's',KU,SU,AU)
      if (iErr.eq.0) call UXSddi (iErr, 'mon', 12, 'yr',     KU,SU,AU)
      if (iErr.eq.0) call UXSdmi (iErr, 'kyr', +3, 'yr',     KU,SU,AU)
CCC_   . Time ideal
      if (iErr.eq.0) call UXSdfi (iErr, 'yr#i',  360, 'day', KU,SU,AU)
      if (iErr.eq.0) call UXSdfi (iErr, 'mon#i', 30,  'day', KU,SU,AU)
      if (iErr.eq.0) call UXSdmi (iErr, 'kyr#i', +3, 'yr#i', KU,SU,AU)
CCC_   . Power
      if (iErr.eq.0) call UXSdmi (iErr, 'mW', -3, 'W',    KU,SU,AU)
CCC_   . Mass
      if (iErr.eq.0) call UXSdmi (iErr, 'g', -3, 'kg',    KU,SU,AU)
CCC_   . Temperature
      if (iErr.eq.0) call UXSdnl (iErr, 'degC', 'K',      KU,SU,AU)
CCC_   . Angle
      qpi = ATAN2 (1.d0, 1.d0)
      if (iErr.eq.0) call UXSdco (iErr, 'qpi', qpi,       KU,SU,AU)
      if (iErr.eq.0) call UXSdfi (iErr, 'pi',  4, 'qpi',  KU,SU,AU)
      if (iErr.eq.0) call UXSdec (iErr, 'pi',             KU,SU,AU)
c
      if (iErr.eq.0)
     $     call UXSddi (iErr, 'degree', 45, 'qpi radian', KU,SU,AU)
      if (iErr.eq.0) call UXSdal (iErr, 'deg', 'degree',  KU,SU,AU)
      if (iErr.eq.0) call UXSdal (iErr, 'rad', 'radian',  KU,SU,AU)

      RETURN
      END
CCC_& UXinit  ## Unison/Unit initialization (default allocation)
      subroutine UXinit
     O    (iErr,
     O     KU,  SU,  AU,
     I     LKU, LSU, LAU,
     I     MSI, MDI, MCI, KTYPE,  IFPL)
CCC_ + Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   KU(*)
      _INTENT(OUT,_REALSTD)  SU(*)
      _INTENT(OUT,character) AU(*)*(*)
      _INTENT(IN, integer)   LKU, LSU, LAU
      _INTENT(IN, integer)   MSI, MDI, MCI
      _INTENT(IN, integer)   KTYPE
      _INTENT(IN, integer)   IFPL
CCC_ + Body
      iErr = 0
CCC_  - Call sub-managers
      if (iErr.eq.0) then
         call UXAcfg
     $       (iErr,
     $        KU,  SU,  AU,  LKU, LSU, LAU,
     $        MSI, MDI, MCI, 0,   0,   0,   0,   KTYPE, IFPL)
      endif
      if (iErr.eq.0) then
         call UXiniS(iErr, KU, SU, AU, 0)
      endif
      if (iErr.ne.0) then
         write (*, *) 'UXINIT FATAL', iErr
      endif
c
      RETURN
      END
CCC_& UXUNIT  ## Unison/Unit conversion Announcement
      subroutine UXUNIT (STRA, STRB, IOP)
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
      else if (IOP.eq.3) then
         STRA = 'OPT_UNIT_LEN'
         write (STRB, *) OPT_UNIT_LEN
      else if (IOP.eq.4) then
         STRA = 'OPT_UNIT_SEQUENCE_MAX'
         write (STRB, *) OPT_UNIT_SEQUENCE_MAX
      else if (IOP.eq.5) then
         STRA = 'OPT_UNIT_EXPANSION_LOOP'
         write (STRB, *) OPT_UNIT_EXPANSION_LOOP
      else if (IOP.eq.6) then
         STRA = 'OPT_UNIT_HASH_BASE'
         write (STRB, *) OPT_UNIT_HASH_BASE
      else if (IOP.eq.7) then
         STRA = 'OPT_UNIT_HASH_BASE_FINAL'
         write (STRB, *) OPT_UNIT_HASH_BASE_FINAL
      else
         STRA = ' '
         STRB = ' '
      endif
      RETURN
      END
CCC_* Test
#if       WITH_TEST_UXUNIT || TEST_UXUNIT
CCC_ + Macros
#define UXILIM(U,D,C,T) (U)*_UATTR_MAX+(D)*_DATTR_MAX+(C)*_CATTR_MAX+(T)*_IPTBL_MAX+_OFF_IATTR
#define UXALIM(U)       (U)
#define UXSLIM(U,D)     (U+D)*_COEFF_MAX
c
#ifndef    TEST_UNIT_SINGLE_MAX     /* number of single units */
#  define  TEST_UNIT_SINGLE_MAX     512
#endif
#ifndef    TEST_UNIT_COMPOUND_MAX   /* number of compound units */
#  define  TEST_UNIT_COMPOUND_MAX   512
#endif
#ifndef    TEST_UNIT_DECOMPOSITION_MAX   /* number of compound units */
#  define  TEST_UNIT_DECOMPOSITION_MAX   128
#endif
#ifndef    TEST_UNIT_CTABLE_MAX     /* elements of compound table */
#  define  TEST_UNIT_CTABLE_MAX     1024
#endif
CCC_ & UXTEST_nsg_do  ## suggestion test execution
      subroutine UXTEST_nsg_do
     $     (iErr, LKU, LSU, LAU, MSh, MDh, MCh, KD, AD)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer) iErr
      _INTENT(IN,   integer) LKU, LSU, LAU
      _INTENT(IN,   integer) MSh, MDh, MCh
      _INTENT(INOUT,integer)   KD(*)
      _INTENT(INOUT,character) AD(*)*(*)
      integer    MSs, MDs, MCs
      integer    NKU, NSU, NAU
      integer    NAS, NAD, NAC, NAT
      integer    KTYPE
      integer    IFP
CCC_  - Body
      iErr = 0
c
      if (iErr.eq.0) call UDSopn(iErr, KD, AD, 0,  'KSU = [')
      if (iErr.eq.0) call UDSmai(iErr, KD, AD, 0, -1, ' ', LKU)
      if (iErr.eq.0) call UDSmai(iErr, KD, AD, 0, -1, ',', LSU)
      if (iErr.eq.0) call UDSmai(iErr, KD, AD, 0, -1, ',', LAU)
      if (iErr.eq.0) call UDSmsg(iErr, KD, AD, 0, 0,  ']')
c
      call UDSquo(IFP, KD)
c
      NAS   = 0
      NAD   = 0
      NAC   = 0
      NAT   = 0
      KTYPE = 0
c
      call UXAnsg
     O    (iErr,
     O     MSs, MDs, MCs,
     I     MSh, MDh, MCh,
     I     LKU, LSU, LAU,   NAS, NAD, NAC, NAT, KTYPE)
c
      call UXAnrq
     O    (NKU, NSU,  NAU,
     I     MSs, MDs,  MCs,  NAS, NAD, NAC, NAT, KTYPE)
c
 101  format ('NSG:', I2,
     $     ' L(',   I5, I5, I5, ')',
     $     ' H(',   I5, I5, I5, ')',
     $     ' S[',   I5, I5, I5, ']',
     $     ' R[',   I5, I5, I5, ']')
      if      (COND_N(IFP)) then
         write (IFP, 101) iErr,
     $        LKU, LSU, LAU, MSh, MDh, MCh,
     $        MSs, MDs, MCs, NKU, NSU, NAU
      else if (COND_S(IFP)) then
         write (*,   101) iErr,
     $        LKU, LSU, LAU, MSh, MDh, MCh,
     $        MSs, MDs, MCs, NKU, NSU, NAU
      endif
      RETURN
      END
CCC_ & UXTEST_nsg_ctrl  ## suggestion tests control
      subroutine UXTEST_nsg_ctrl (iErr, KLVL,  KD,AD)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   KLVL
      _INTENT(INOUT,integer)   KD(*)
      _INTENT(INOUT,character) AD(*)*(*)
      integer LKU, LSU, LAU
      integer MSh, MDh, MCh
c
      integer    LU,  LD,  LC,  LT
      parameter (LU = TEST_UNIT_SINGLE_MAX)
      parameter (LD = TEST_UNIT_DECOMPOSITION_MAX)
      parameter (LC = TEST_UNIT_COMPOUND_MAX)
      parameter (LT = TEST_UNIT_CTABLE_MAX)
      integer    LKUp, LSUp, LAUp
      parameter (LKUp = UXILIM(LU,LD,LC,LT))
      parameter (LSUp = UXSLIM(LU,LD))
      parameter (LAUp = UXALIM(LU))
CCC_  - Body
      iErr = 0
c
      LKU  = 256
      LSU  = 512
      LAU  = 128
      MSh  = 0
      MDh  = 0
      MCh  = 0
c
      if (iErr.eq.0) call UDSnew(iErr, KD, AD, 0,  'SUGGESTION')
      if (iErr.eq.0) call UDSset(iErr, KD, AD, +1)
c
      call UXTEST_nsg_do(iErr, LKU,      LSU,LAU, MSh,MDh,MCh, KD,AD)
      call UXTEST_nsg_do(iErr, LKU / 3,  LSU,LAU, MSh,MDh,MCh, KD,AD)
      call UXTEST_nsg_do(iErr, LKU / 5,  LSU,LAU, MSh,MDh,MCh, KD,AD)
      call UXTEST_nsg_do(iErr, LKU / 7,  LSU,LAU, MSh,MDh,MCh, KD,AD)
      call UXTEST_nsg_do(iErr, LKU / 11, LSU,LAU, MSh,MDh,MCh, KD,AD)
c
      call UXTEST_nsg_do(iErr, LKUp,      LSUp,LAUp, MSh,MDh,MCh, KD,AD)
      call UXTEST_nsg_do(iErr, LKUp / 3,  LSUp,LAUp, MSh,MDh,MCh, KD,AD)
      call UXTEST_nsg_do(iErr, LKUp / 5,  LSUp,LAUp, MSh,MDh,MCh, KD,AD)
      call UXTEST_nsg_do(iErr, LKUp / 10, LSUp,LAUp, MSh,MDh,MCh, KD,AD)
c
      call UXTEST_nsg_do(iErr, LKUp / 10, LSUp,LAUp, MSh,MDh,100, KD,AD)
      call UXTEST_nsg_do(iErr, LKUp / 10, LSUp,LAUp, MSh,MDh,40,  KD,AD)
c
      if (iErr.eq.0) call UDSset(iErr, KD, AD, -1)
c
      RETURN
      END
CCC_ & UXTEST_decl_do  ## declaration test execution
      subroutine UXTEST_decl_do
     $     (iErr, UB, SW, iXerr,  KU,SU,AU, KD,AD)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   iXerr
      _INTENT(IN,   character) UB*(*)
      _INTENT(IN,   character) SW*(*)
      _INTENT(INOUT,integer)   KD(*)
      _INTENT(INOUT,character) AD(*)*(*)
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
c
      integer   NCO
      data      NCO /0/
      save      NCO
      character U*(32), C
      integer   ja, j0, j1
      integer   NSTP
      _REALSTD  F
CCC_  - Body
      iErr = 0
      j0   = NCO / 26
      NSTP = 1
      if (j0.ge.26) then
         iErr = -1
      else
         call UFwc2i(ja, 'a')
         j0 = j0 + ja
         j1 = MOD(NCO, 26) + ja
         U  = 'U??'
         call UFwi2c(C, j0)
         U(2:2) = C
         call UFwi2c(C, j1)
         U(3:3) = C
         if (iErr.eq.0) call UDSopn(iErr, KD, AD, 0,  'DECL')
         if (iErr.eq.0) call UDSmaa(iErr, KD, AD, 0, -1, '/', SW)
         if (iErr.eq.0) call UDSmaa(iErr, KD, AD, 0, 0,  ':', U)
      endif
      if (iErr.eq.0) then
         if (SW.eq.'F') then
            F = 123.d4
            call UXSdfs (iErr, U, F, UB, KU,SU,AU)
         else if (SW.eq.'D') then
            F = 234.d5
            call UXSdds (iErr, U, F, UB, KU,SU,AU)
         else if (SW.eq.'M') then
            F = 4.0d0
            call UXSdms (iErr, U, F, UB, KU,SU,AU)
         else if (SW.eq.'A') then
            call UXSdal (iErr, U,    UB, KU,SU,AU)
         else if (SW.eq.'N') then
            call UXSdnl (iErr, U,    UB, KU,SU,AU)
         else if (SW.eq.'R0') then
            F = 3.0d0
            call UXSdms (iErr, UB, F, U, KU,SU,AU)
         else if (SW(1:1).eq.'R') then
            ja = len_trim(SW)
            F = 3.0d0
 101        format (A, '^', A)
            write (U, 101) _TRIM(U), SW(2:ja)
            call USJntz(U, ' yr')
            call UXSdms (iErr, UB, F, U, KU,SU,AU)
         else
            call UXSdal (iErr, SW,    UB, KU,SU,AU)
         endif
         if (iErr.eq.iXerr) then
            iErr = 0
         else
            iErr = -2
         endif
      endif
      NCO = NCO + NSTP
c
      RETURN
      END
CCC_ & UXTEST_decl_ctrl  ## declaration tests control
      subroutine UXTEST_decl_ctrl
     $     (iErr,  KLVL,  KU,SU,AU,  KD,AD)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   KLVL
      _INTENT(INOUT,integer)   KD(*)
      _INTENT(INOUT,character) AD(*)*(*)
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
CCC_  - Body
      iErr = 0
      if (iErr.eq.0) call UDSnew(iErr, KD, AD, 0,  'SIMPLE DECL')
      if (iErr.eq.0) call UDSset(iErr, KD, AD, +1)
c
      if (iErr.eq.0)
     $     call UXTEST_decl_do(iErr, 'm', 'F', 0, KU,SU,AU, KD,AD)
      if (iErr.eq.0)
     $     call UXTEST_decl_do(iErr, 'm', 'D', 0, KU,SU,AU, KD,AD)
      if (iErr.eq.0)
     $     call UXTEST_decl_do(iErr, 'm', 'M', 0, KU,SU,AU, KD,AD)
      if (iErr.eq.0)
     $     call UXTEST_decl_do(iErr, 'm', 'A', 0, KU,SU,AU, KD,AD)
      if (iErr.eq.0)
     $     call UXTEST_decl_do(iErr, 'm', 'N', 0, KU,SU,AU, KD,AD)
CCC_  - ignored character
      if (iErr.eq.0) call UDSnew(iErr, KD, AD, -1, 'IGNORED CHAR')
      if (iErr.eq.0) call UDSset(iErr, KD, AD, +1)
      if (iErr.eq.0) then
         call UXTEST_decl_do
     $        (iErr, 'cm;/;;mon', 'A', 0, KU,SU,AU, KD,AD)
      endif
CCC_  - reversal registration
      if (iErr.eq.0) call UDSnew(iErr, KD, AD, -1, 'REVERSAL')
      if (iErr.eq.0) call UDSset(iErr, KD, AD, +1)
      if (iErr.eq.0) then
         call UXTEST_decl_do (iErr, 'mm', 'R0', 0, KU,SU,AU, KD,AD)
      endif
      if (iErr.eq.0) then
         call UXTEST_decl_do (iErr, 'mm', 'R+1',0, KU,SU,AU, KD,AD)
      endif
      if (iErr.eq.0) then
         call UXTEST_decl_do (iErr, 'mm', 'R-1',0, KU,SU,AU, KD,AD)
      endif
      if (iErr.eq.0) then
         call UXTEST_decl_do
     $       (iErr, 'mm', 'R+2', ERR_UNIT_INVALID_COMPOUND,
     $        KU,SU,AU, KD,AD)
      endif
CCC_  - unknown
      if (iErr.eq.0) call UDSnew(iErr, KD, AD, -1, 'UNKNOWN')
      if (iErr.eq.0) call UDSset(iErr, KD, AD, +1)
      if (iErr.eq.0) then
         call UXTEST_decl_do
     $       (iErr, 'u0', 'A', 1, KU,SU,AU, KD,AD)
      endif
      if (iErr.eq.0) then
         call UXTEST_decl_do
     $       (iErr, 'u1 u2 u3', 'A', 3, KU,SU,AU, KD,AD)
      endif
      if (iErr.eq.0) then
         call UXTEST_decl_do
     $       (iErr, 'u4^2', 'A', 1, KU,SU,AU, KD,AD)
      endif
      if (iErr.eq.0) then
         call UXTEST_decl_do
     $       (iErr, 'mm u5', 'A', 1, KU,SU,AU, KD,AD)
      endif
      if (iErr.eq.0) then
         call UXTEST_decl_do
     $       (iErr, 'm', 'u0', 0, KU,SU,AU, KD,AD)
      endif
c
      if (iErr.eq.0) call UDSset(iErr, KD, AD, -1)
      RETURN
      END
CCC_ & UXTEST_ddup_do  ## duplicated test execution
      subroutine UXTEST_ddup_do
     $     (iErr, T, F, UB, iXerr,  KU,SU,AU, KD,AD)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   iXerr
      _INTENT(IN,   character) T*(*)
      _INTENT(IN,   character) UB*(*)
      _INTENT(IN,   _REALSTD)  F
      _INTENT(INOUT,integer)   KD(*)
      _INTENT(INOUT,character) AD(*)*(*)
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
CCC_  - Body
      iErr = 0
      if (iErr.eq.0) call UDSopn(iErr, KD, AD, 0,  'DUP DECL')
      if (iErr.eq.0) call UDSmaa(iErr, KD, AD, 0, 0, '/', T)
      if (iErr.eq.0) then
         call UXSdfs (iErr, 'velo', F, UB, KU,SU,AU)
         if (iErr.eq.iXerr) then
            iErr = 0
         else
            iErr = -2
         endif
      endif
      RETURN
      END
CCC_ & UXTEST_ddup_ctrl  ## duplicated declaration tests control
      subroutine UXTEST_ddup_ctrl
     $     (iErr,  KLVL,  KU,SU,AU,  KD,AD)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   KLVL
      _INTENT(INOUT,integer)   KD(*)
      _INTENT(INOUT,character) AD(*)*(*)
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
CCC_  - Body
      iErr = 0
      if (iErr.eq.0) call UDSnew(iErr, KD, AD, 0,  'DUPLICATED')
      if (iErr.eq.0) call UDSset(iErr, KD, AD, +1)
c
      if (iErr.eq.0) then
         call UXTEST_ddup_do
     $        (iErr, 'ORIG', 1.d3, 'm/yr', 0, KU,SU,AU, KD,AD)
      endif
      if (iErr.eq.0) then
         call UXTEST_ddup_do
     $        (iErr, 'IDENT', 1.d3, 'm/yr', 0, KU,SU,AU, KD,AD)
      endif
      if (iErr.eq.0) then
         call UXTEST_ddup_do
     $        (iErr, 'DIFF-U', 1.d0, 'km/yr', 0, KU,SU,AU, KD,AD)
      endif
      if (iErr.eq.0) then
         call UXTEST_ddup_do
     $       (iErr, 'WRONG-C', 1.d0, 'm/yr', ERR_UNIT_DUP_SINGLE,
     $        KU,SU,AU, KD,AD)
      endif
      if (iErr.eq.0) then
         call UXTEST_ddup_do
     $       (iErr, 'WRONG-U', 1.d0, 'cm/yr', ERR_UNIT_DUP_SINGLE,
     $        KU,SU,AU, KD,AD)
      endif
      if (iErr.eq.0) then
         call UXTEST_ddup_do
     $       (iErr, 'WRONG-D', 1.d0, 'km', ERR_UNIT_DUP_SINGLE,
     $        KU,SU,AU, KD,AD)
      endif
c
      if (iErr.eq.0) call UDSset(iErr, KD, AD, -1)
      RETURN
      END
CCC_ & UXTEST_rel_check  ## relation check
      subroutine UXTEST_rel_check
     $     (iErr, T, US, UD, iXd, iXc, KU,SU,AU, KD,AD)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   iXd, iXc
      _INTENT(IN,   character) T*(*)
      _INTENT(IN,   character) US*(*)
      _INTENT(IN,   character) UD*(*)
      _INTENT(INOUT,integer)   KD(*)
      _INTENT(INOUT,character) AD(*)*(*)
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
      integer iDstt, iCstt
      integer IFP
CCC_  - Body
      iErr = 0
      call UDSquo(IFP, KD)
c
      if (iErr.eq.0) call UDSopn(iErr, KD, AD, 0,  'CHECK')
      if (iErr.eq.0) call UDSmaa(iErr, KD, AD, 0, 0, '/', T)
c
      if (iErr.eq.0) then
         call UXSqxr (iDstt, iCstt, US, UD, KU,SU,AU)
 201     format ('RCH ', A, 1x, A, ' == ', 2I5)
         if (COND_N(IFP)) then
            write (IFP, 201) _TRIM(US),_TRIM(UD),iDstt, iCstt
         else if (COND_S(IFP)) then
            write (*,   201) _TRIM(US),_TRIM(UD),iDstt, iCstt
         endif
         if (iXd.eq.0) then
            if (iCstt.eq.iXc .and. iDstt.eq.iXd) then
               iErr = 0
            else
               iErr = -2
            endif
         else
            if (iCstt.eq.iXc .and. iDstt.ne.0) then
               iErr = 0
            else
               iErr = -2
            endif
         endif
      endif
c
      RETURN
      END
CCC_ & UXTEST_conv_check  ## conversion check
      subroutine UXTEST_conv_check
     $     (iErr, SW, US, UD, iXerr, KU,SU,AU, KD,AD)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   iXerr
      _INTENT(IN,   character) SW*(*)
      _INTENT(IN,   character) US*(*)
      _INTENT(IN,   character) UD*(*)
      _INTENT(INOUT,integer)   KD(*)
      _INTENT(INOUT,character) AD(*)*(*)
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
      integer IFP
      integer jp, lsw
      _REALSTD VT(16)
      _REALSTD VXS, VXD, VXR
      integer  nvt
      integer  jt
      integer  jeP, jeN
      character UST*(128), UDT*(128)
      integer   iuSt,      iuDt,    ixSD
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
CCC_  - Body
      iErr = 0
      call UDSquo(IFP, KD)
c
      if (iErr.eq.0) call UDSopn(iErr, KD, AD, 0,  'CONV')
      if (iErr.eq.0) call UDSmaa(iErr, KD, AD, 0, -1, ':',  US)
      if (iErr.eq.0) call UDSmaa(iErr, KD, AD, 0, 0,  '>>', UD)
      if (iErr.eq.0) call UDSset(iErr, KD, AD, +1)
c
      nvt = 2
      VT(1) = 1.23d23
      VT(2) = 1.23d-23
c
      lsw = len_trim(SW)
 101  format ('RESULT: ', 3E24.16, 1x, L1)
      do jp = 1, lsw
         if (SW(jp:jp).eq.'d') then
            nvt   = 1
            VT(1) = 180.0d0
         else if (SW(jp:jp).eq.'U'.or.SW(jp:jp).eq.'u') then

            if (SW(jp:jp).eq.'U') then
               UST = US
               UDT = UD
            else
               UST = UD
               UDT = US
            endif
            if (iErr.eq.0) call UDSopn(iErr, KD, AD, 0,  'STR')
            if (iErr.eq.0) call UDSmaa(iErr, KD, AD, 0, -1, ':',  UST)
            if (iErr.eq.0) call UDSmaa(iErr, KD, AD, 0, 0,  '>>', UDT)
            do jt = 1, nvt
               VXS = VT(jt)
               VXD = VXS
               call UXSxss (jeP, VXD, UST, UDT, +1, KU,SU,AU)
               VXR = VXD
               call UXSxss (jeN, VXR, UST, UDT, -1, KU,SU,AU)
               if (COND_N(IFP)) then
                  write  (IFP, 101) VXS, VXD, VXR, (VXS.eq.VXR)
               else if (COND_S(IFP)) then
                  write  (*,   101) VXS, VXD, VXR, (VXS.eq.VXR)
               endif
            enddo
         else if (SW(jp:jp).eq.'I'.or.SW(jp:jp).eq.'i') then
            if (SW(jp:jp).eq.'I') then
               UST = US
               UDT = UD
            else
               UST = UD
               UDT = US
            endif
            if (iErr.eq.0) call UDSopn(iErr, KD, AD, 0,  'ID')
            if (iErr.eq.0) call UDSmaa(iErr, KD, AD, 0, -1, ':',  UST)
            if (iErr.eq.0) call UDSmaa(iErr, KD, AD, 0, 0,  '>>', UDT)
            if (iErr.eq.0) call UXCinq(iErr, iuSt, UST, KU,AU)
            if (iErr.eq.0) call UXCinq(iErr, iuDt, UDT, KU,AU)
            if (iErr.eq.0) then
               call UXCxrg (iErr, ixSD, iuSt, iuDt, KU,SU,AU)
            endif
            if (iErr.eq.0) then
               do jt = 1, nvt
                  VXS = VT(jt)
                  VXD = VXS
                  call UXCcnv (jeP, VXD, ixSD, KU,SU)
                  VXR = VXD
                  call UXCrvc (jeP, VXR, ixSD, KU,SU)
                  write  (*, 101) VXS, VXD, VXR, (VXS.eq.VXR)
               enddo
            endif
         endif
      enddo
      if (iErr.eq.0) call UDSset(iErr, KD, AD, -1)
c
      RETURN
      END
CCC_ & UXTEST_opr_ctrl  ## operation tests control
      subroutine UXTEST_opr_ctrl
     $     (iErr,  KLVL,  KU,SU,AU,  KD,AD)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   KLVL
      _INTENT(INOUT,integer)   KD(*)
      _INTENT(INOUT,character) AD(*)*(*)
      _INTENT(INOUT,integer)   KU(*)
      _INTENT(INOUT,_REALSTD)  SU(*)
      _INTENT(INOUT,character) AU(*)*(*)
CCC_  - Body
      iErr = 0
      if (iErr.eq.0) call UDSnew(iErr, KD, AD, 0,  'OPERATION')
      if (iErr.eq.0) call UDSset(iErr, KD, AD, +1)
CCC_   . Definition
      if (iErr.eq.0) call UDSnew(iErr, KD, AD, 0,  'DEFINITION')
      if (iErr.eq.0) call UXSdal(iErr, 'topo', 'm',       KU,SU,AU)
      if (iErr.eq.0) call UXSdal(iErr, 'dx',   'km',      KU,SU,AU)
      if (iErr.eq.0) call UXSdal(iErr, 'grav', 'm/s^2',   KU,SU,AU)
      if (iErr.eq.0) call UXSdal(iErr, 'dens', 'kg/m^3',  KU,SU,AU)
      if (iErr.eq.0) call UXSdal(iErr, 'dsdx', 'topo/dx', KU,SU,AU)
      if (iErr.eq.0)
     $     call UXSdal(iErr, 'bdrg@i', 'dens grav topo dsdx', KU,SU,AU)
      if (iErr.eq.0) call UXSdal(iErr, 'bdrg@u', 'Pa',  KU,SU,AU)
CCC_   . Relation check
      if (iErr.eq.0) call UDSnew(iErr, KD, AD, 0,  'RELATION CHECK')
      if (iErr.eq.0) then
         call UXTEST_rel_check
     $       (iErr, 'IDENTICAL', 'Pa', 'bdrg@u', 0, 1,
     $        KU,SU,AU, KD,AD)
      endif
      if (iErr.eq.0) then
         call UXTEST_rel_check
     $       (iErr, 'DIFF-COEFF', 'Pa', 'bdrg@i', 0, 2,
     $        KU,SU,AU, KD,AD)
      endif
      if (iErr.eq.0) then
         call UXTEST_rel_check
     $       (iErr, 'DIFF-BOTH', 'Pa', 'km/s', 1, 2,
     $        KU,SU,AU, KD,AD)
      endif
      if (iErr.eq.0) then
         call UXTEST_rel_check
     $       (iErr, 'DIFF-DIM', 'Pa', 'm/s', 1, 1,
     $        KU,SU,AU, KD,AD)
      endif
CCC_   . Conversion check
      if (iErr.eq.0) then
         call UXTEST_conv_check
     $       (iErr, 'UuIi', 'bdrg@i', 'bdrg@u', 0,
     $        KU,SU,AU, KD,AD)
      endif
      if (iErr.eq.0) then
         call UXTEST_conv_check
     $       (iErr, 'Uu', 'm', 'km', 0,
     $        KU,SU,AU, KD,AD)
      endif
      if (iErr.eq.0) then
         call UXTEST_conv_check
     $       (iErr, 'dU', 'deg', 'rad', 0,
     $        KU,SU,AU, KD,AD)
      endif
CCC_   . End
      if (iErr.eq.0) call UDSset(iErr, KD, AD, -1)
      RETURN
      END
CCC_ & UXTEST_unit_ctrl ## unit tests control
      subroutine UXTEST_unit_ctrl (iErr, KLVL,  KD,AD)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   KLVL
      _INTENT(INOUT,integer)   KD(*)
      _INTENT(INOUT,character) AD(*)*(*)
CCC_  - unit attribute cluster
      integer    LU,  LD,  LC,  LT
      parameter (LU = TEST_UNIT_SINGLE_MAX)
      parameter (LD = TEST_UNIT_DECOMPOSITION_MAX)
      parameter (LC = TEST_UNIT_COMPOUND_MAX)
      parameter (LT = TEST_UNIT_CTABLE_MAX)
      integer    LKU, LSU, LAU
      parameter (LKU = UXILIM(LU,LD,LC,LT))
      parameter (LSU = UXSLIM(LU,LD))
      parameter (LAU = UXALIM(LU))
      integer    KU(LKU)
      character  AU(LAU)*(OPT_UNIT_LEN)
      _REALSTD   SU(LSU)
      integer    MSI, MCI, MDI
      integer    iplog
CCC_  - Body
      iErr = 0
      call UDSquo(iplog, KD)
c
      if (iErr.eq.0) call UDSnew(iErr, KD, AD, 0,  'UNITS BASICS')
      if (iErr.eq.0) call UDSnew(iErr, KD, AD, +1, 'INITIALIZATION')
c
      MSI = LU
      MCI = LC
      MDI = LD
      call UXinit
     $    (iErr,
     $     KU, SU, AU, LKU, LSU, LAU, MSI, MDI, MCI, 0,
     $     iplog)
CCC_   . Declaration tests
      call UXTEST_decl_ctrl(iErr,  KLVL,  KU,SU,AU,  KD,AD)
CCC_   . Duplicated declaration tests
      call UXTEST_ddup_ctrl(iErr,  KLVL,  KU,SU,AU,  KD,AD)
CCC_   . Operation tests
      call UXTEST_opr_ctrl(iErr,  KLVL,  KU,SU,AU,  KD,AD)
CCC_   . Report
      if (iErr.eq.0) call UDSnew(iErr, KD, AD, 0, 'REPORT')
      call UXSrep (iErr, KU,SU,AU)
CCC_   . Final
      if (iErr.eq.0) call UDSset(iErr, KD, AD, -1)
      RETURN
      END
#endif /* WITH_TEST_UXUNIT || TEST_UXUNIT */
CCC_ @ UXtest  ## Test program
#if TEST_UXUNIT
CCC_  - Test suites
CC::   SOURCES udbgst.F
      program UXtest
CCC_  - Declaration
      implicit none
      integer iErr
      integer iplog
CCC_   . debug section
      integer    LDK, LDA
      parameter (LDK = 32, LDA = 24)
      integer    KD(LDK)
      character  AD(LDA)*(128)
c
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
#include "orevan.h" /* 0 */
CCC_  - Body
#define _ANNOUNCE UXUNIT
#define _LEXT     9999
#include "orevan.h" /* 1 */
c
      iErr  = 0
      iplog = -1
c
      call UDSbnm ('UXUNIT TESTS', '#', 0, iplog)
c
      call UDSini (iErr, KD, AD, LDK, LDA, iplog)
CCC_   . uxansg test
      call UXTEST_nsg_ctrl(iErr, 0,  KD, AD)
CCC_   . unit test
      call UXTEST_unit_ctrl(iErr, 0,  KD, AD)
#if 0 /* obsolete */
CCC_   . number in string
      call UXtest_dec
     O    (iErr, itest,
     $     '5:DEC/NUMBER', 'week', '7 day', 1.d0, 'A', 0,
     $     KU,SU,AU, iplog)
CCC_   . non linear
      call UXSdnl (iErr, 'mon#g', 'day', KU,SU,AU)
      call UXtest_dec
     O    (iErr, itest,
     $     '6:DEC/NONL/0', 'mon#g', 'day', 0.d0, 'X', 0,
     $     KU,SU,AU, iplog)
      call UXtest_dec
     O    (iErr, itest,
     $     '6:DEC/NONL/1', 'week#g', 'day', 0.d0, 'N', 0,
     $     KU,SU,AU, iplog)
CCC_   . fine
      call UDMfi1 (iplog, '(''## FINAL: '', I4)', iErr)
      call UDTbni (itest, 'FINE', ' ', iplog)
#endif
c
      call UDSbnm ('UXUNIT TESTS FINE', '#', 0, iplog)
c
      STOP
      END
#endif /* TEST_UXUNIT */
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
