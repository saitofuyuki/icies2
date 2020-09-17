C arpeggio/agmtry.F --- Arpeggio/Geometry
C Maintainer:  SAITO Fuyuki
C Created: Jan 27 2010
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2020/09/17 08:40:04 fuyuki agmtry.F>'
#define _FNAME 'arpeggio/agmtry.F'
#define _REV   'Arpeggio 1.0'
CCC_! MANIFESTO
C
C Copyright (C) 2012--2020
C           Japan Agency for Marine-Earth Science and Technology
C
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
CCC_* Common macros
#include "ofdlct.h" /* fortran dialect */
#include "ologfm.h" /* logging */
#include "odevva.h"
#include "ounelv.h" /* namelist emulation levels */
#include "oarpgc.h" /* geometry category */
#include "ovconf.h" /* variable configuration */
CCC_ + Options
#ifndef    OPT_NAMELIST_OUTPUT_EMULATION
#  define  OPT_NAMELIST_OUTPUT_EMULATION _UNMLEM_LEVEL_ENTRY
#endif
CCC_ + Mode
#define _GEOMETRY_LINEAR     0
#define _GEOMETRY_LEVELS     1
#define _GEOMETRY_POLYNOMIAL 2
CCC   _ + Item type
#define ITEM_DEFAULT    0
#define ITEM_POLYNOMIAL 1
#define ITEM_EXPONENT   2
CCC_ + Test
#ifndef    TEST_AGMTRY
#  define  TEST_AGMTRY 0
#endif
CCC_* [AGQ] 2d General orthogonal
CCC_* [AGS] 2d Geographic (spherical)
CCC_* [AGH] 2d Cartesian
CCC_ & AGHnmr  ## Geometry configuration by namelist (wrapper/ratio)
      subroutine AGHnmr
     O    (iErr,
     W     W,    LW,
     I     vRX,  XW,   WXN,
     I     CR,   CK,   icXa, icXb,
     I     IFPi, IFPn, IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,_REALSTD)  W (*)
      _INTENT(IN, _REALSTD)  vRX
      _INTENT(IN, _REALSTD)  XW
      _INTENT(IN, _REALSTD)  WXN
      _INTENT(IN, character) CR*(*), CK*(*)
      _INTENT(IN, integer)   icXa,   icXb
      _INTENT(IN, integer)   LW
      _INTENT(IN, integer)   IFPi,   IFPn,  IFPl
c
      _REALSTD PGA (AGS_MAX)
      integer  IGA (AGI_MAX)
CCC_  - Body
      iErr = 0
      call AGUrsp (IGA, PGA)
c
      IGA (AGI_OTYPE) = GEOMETRY_ORIGIN_RATIO
      PGA (AGS_OV)    = vRX
      PGA (AGS_WN)    = WXN
      PGA (AGS_DW)    = XW
c
      call AGHcgc
     O    (iErr,
     W     W,    LW,   PGA,  IGA,
     I     CR,   CK,   icXa, icXb,  .true., IFPi, IFPn, IFPl)
      RETURN
      END
CCC_ & AGHnmp  ## Geometry configuration by namelist (wrapper/point)
      subroutine AGHnmp
     O    (iErr,
     W     W,    LW,
     I     vRX,  XW,   WXN,
     I     CR,   CK,   icXa, icXb,
     I     IFPi, IFPn, IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,_REALSTD)  W (*)
      _INTENT(IN, _REALSTD)  vRX
      _INTENT(IN, _REALSTD)  XW
      _INTENT(IN, _REALSTD)  WXN
      _INTENT(IN, character) CR*(*), CK*(*)
      _INTENT(IN, integer)   icXa,   icXb
      _INTENT(IN, integer)   LW
      _INTENT(IN, integer)   IFPi,   IFPn,  IFPl
c
      _REALSTD PGA (AGS_MAX)
      integer  IGA (AGI_MAX)
CCC_  - Body
      iErr = 0
      call AGUrsp (IGA, PGA)
c
      IGA (AGI_OTYPE) = GEOMETRY_ORIGIN_EDGE
      PGA (AGS_OV)    = vRX
      PGA (AGS_WN)    = WXN
      PGA (AGS_DW)    = XW
c
      call AGHcgc
     O    (iErr,
     W     W,    LW,   PGA,  IGA,
     I     CR,   CK,   icXa, icXb,  .true., IFPi, IFPn, IFPl)
      RETURN
      END
CCC_ & AGHnmz  ## Geometry configuration by namelist (wrapper nodef)
      subroutine AGHnmz
     O    (iErr,
     W     W,    LW,
     I     CR,   CK,   icXa, icXb,
     I     IFPi, IFPn, IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,_REALSTD)  W (*)
      _INTENT(IN, character) CR*(*), CK*(*)
      _INTENT(IN, integer)   icXa,   icXb
      _INTENT(IN, integer)   LW
      _INTENT(IN, integer)   IFPi,   IFPn,  IFPl
c
      _REALSTD PGA (AGS_MAX)
      integer  IGA (AGI_MAX)
CCC_  - Body
      iErr = 0
      call AGUrsp (IGA, PGA)
      call AGHcgc
     O    (iErr,
     W     W,    LW,   PGA,  IGA,
     I     CR,   CK,   icXa, icXb,  .false., IFPi, IFPn, IFPl)
      RETURN
      END
CCC_ & AGHcgc  ## Geometry configuration/generation core
      subroutine AGHcgc
     O    (iErr,
     W     W,    LW,
     M     PGA,  IGA,
     I     CR,   CK,   icXa, icXb, ONOCFG,
     I     IFPi, IFPn, IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(OUT,  _REALSTD)  W (*)
      _INTENT(INOUT,_REALSTD)  PGA (*)
      _INTENT(INOUT,integer)   IGA (*)
      _INTENT(IN,   integer)   LW
      _INTENT(IN,   character) CR*(*), CK*(*)
      _INTENT(IN,   integer)   icXa,   icXb
      _INTENT(IN,   integer)   IFPi,   IFPn, IFPl
      _INTENT(IN,   logical)   ONOCFG
CCC_  - Body
      iErr = 0
      if (iErr.eq.0) then
         call AGUpnm (iErr, PGA, IGA, CR, CK, IFPi, IFPn, IFPl)
CC       clear warning
         if (ONOCFG) iErr = MIN (0, iErr)
      endif
      if (iErr.eq.0) then
         call AGHgen (iErr, W, LW, CR, CK, icXa, icXb, PGA, IGA, IFPl)
      endif
      RETURN
      END
CCC_ & AGHgen  ## 2d generation suite
      subroutine AGHgen
     O    (iErr,
     W     W,   LW,
     I     CR,  CK,  icXa, icXb, PGA,  IGA,
     I     IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   LW
      _INTENT(OUT,_REALSTD)  W (LW)
      _INTENT(IN, character) CR*(*), CK*(*)
      _INTENT(IN, integer)   icXa, icXb
      _INTENT(IN, _REALSTD)  PGA (*)
      _INTENT(IN, integer)   IGA (*)
      _INTENT(IN, integer)   IFPl
c
      logical    OEQ
      integer    kC
      _REALSTD   vC, DW, WN, ZDL, ZDU, RXL, RXU
      _REALSTD   vNAN
      integer    Nadd
CCC_  - Body
      iErr = 0
c
      vNAN  = PGA (AGS_VNAN)
      kC    = IGA (AGI_OTYPE)
      vC    = PGA (AGS_OV)
      WN    = PGA (AGS_WN)
      DW    = PGA (AGS_DW)
      ZDL   = PGA (AGS_ZDL)
      ZDU   = PGA (AGS_ZDU)
      RXL   = PGA (AGS_RXL)
      RXU   = PGA (AGS_RXU)
      Nadd  = 0
c
      call AGUife (OEQ, kC)
      if (OEQ) then
         call AGUeqm
     $       (iErr, W,    LW,
     $        kC,   vC,   DW, WN, ZDL, ZDU, RXL, RXU, vNAN, Nadd,
     $        icXa, icXb, CR, CK, IFPl)
      else
 101     format ('AGHGNS: INVALID TYPES ', A, 1x, A, I3)
         if      (COND_N(IFPl)) then
            write (IFPl, 101)
     $           _TRIM(CR), _TRIM(CK), kC
         else if (COND_S(IFPl)) then
            write (*,    101)
     $           _TRIM(CR), _TRIM(CK), kC
         endif
         iErr = -1
      endif
c
      call DATrcU (IFPl, iErr, 'R', 'AGHGNS')
      RETURN
      END
CCC_* [AGZ] 1d geometry
CCC_ & AGZnmz  ## 1d Geometry configuration by namelist (no default)
      subroutine AGZnmz
     O    (iErr,
     W     W,     LW,
     I     CR,    icZa, icZb,  IFPi, IFPn, IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,_REALSTD)  W   (*)
      _INTENT(IN, integer)   LW
      _INTENT(IN, character) CR*(*)
      _INTENT(IN, integer)   icZa, icZb
      _INTENT(IN, integer)   IFPi, IFPn, IFPl
      integer   KGMdef
      integer   NTdef
      integer   KITdef(1)
      integer   IXdef (1)
      _REALSTD  CTdef (2, 1)
CCC_  - Body
      iErr  = 0
c
      KGMdef = _GEOMETRY_LINEAR
      NTdef  = 0
      IXdef (1) = 0
      CTdef (1,1) = 0.0d0
      CTdef (2,1) = 0.0d0
      KITdef(1) = ITEM_POLYNOMIAL
      call AGZnmc
     O    (iErr,
     W     W,      LW,
     I     KGMdef, IXdef, CTdef, KITdef, NTdef,
     I     CR,     icZa,  icZb,  IFPi,   IFPn, IFPl)
      RETURN
      END
CCC_ & AGZnmc  ## 1d Geometry configuration by namelist (core)
      subroutine AGZnmc
     O    (iErr,
     W     W,      LW,
     I     KGMdef, IXdef, CTdef, KITdef, NTdef,
     I     CR,     icZa,  icZb,  IFPi,   IFPn, IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,_REALSTD)  W   (*)
      _INTENT(IN, integer)   LW
      _INTENT(IN, integer)   NTdef
      _INTENT(IN, integer)   KGMdef
      _INTENT(IN, integer)   IXdef (*)
      _INTENT(IN, integer)   KITdef (*)
      _INTENT(IN, _REALSTD)  CTdef (*)
      _INTENT(IN, character) CR*(*)
      _INTENT(IN, integer)   icZa, icZb
      _INTENT(IN, integer)   IFPi, IFPn, IFPl
CCC_   . interior
      integer    KGM
CCC_   . interior buffer
      integer    LT, NT
      parameter (LT = 32)
      integer    IX    (LT)
      integer    KIT   (LT)
      _REALSTD   CT (2, LT)
      _REALSTD   DNM
CCC_  - Body
      iErr = 0
c
      if (iErr.eq.0) then
         call AGZrnm
     O       (iErr,
     O        KGM,    IX,    CT,    KIT,    NT,   LT,
     O        DNM,
     I        KGMdef, IXdef, CTdef, KITdef, NTdef,
     I        CR,     IFPi,  IFPn,  IFPl)
      endif
      if (iErr.eq.0) then
         if (KGM .eq. _GEOMETRY_POLYNOMIAL
     $        .or. KGM .eq. _GEOMETRY_LINEAR) then
            call AGZgxp
     O          (iErr,
     W           W,
     I           LW,  CR,  icZa, icZb,
     I           IX,  CT,  KIT,  NT,   DNM,  IFPl)
         else if (KGM .eq. _GEOMETRY_LEVELS) then
            call AGZgxl
     O          (iErr,
     W           W,
     I           LW,  CR,  icZa, icZb,
     I           IX,  CT,  NT,   IFPl)
         else
            iErr = -1
         endif
      endif
      call DATrcU (IFPl, iErr, 'R', 'AGZNMC')
      RETURN
      END
CCC_ & AGZrnm  ## Geometry configuration namelist parser
      subroutine AGZrnm
     O    (iErr,
     O     KGM,    IX,    CT,    KIT,    NT,  LT,
     O     DNMARG,
     I     KGMdef, IXdef, CTdef, KITdef, NTdef,
     I     CR,     IFPi,  IFPn,  IFPl)
CCC_  - Description
CC  Configuration type is either
CC
CC    &NIGEOZ .. IPOWER=, CWGT=, COFS=, DNM=, &END
CC        only first non-zero DNM is applied
CC    or
CC    &NIGEOZ .. NLV=, DXN=, DXD=, &END
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(OUT,  integer)   IX  (*)
      _INTENT(OUT,  integer)   KGM
      _INTENT(OUT,  _REALSTD)  CT  (2, *)
      _INTENT(OUT,  _REALSTD)  DNMARG
      _INTENT(OUT,  integer)   KIT (*)
      _INTENT(OUT,  integer)   NT
      _INTENT(IN,   integer)   LT
      _INTENT(IN,   integer)   KGMdef
      _INTENT(IN,   integer)   IXdef (*)
      _INTENT(IN,   _REALSTD)  CTdef (2, *)
      _INTENT(IN,   integer)   KITdef(*)
      _INTENT(IN,   integer)   NTdef
      _INTENT(IN,   character) CR*(*)
      _INTENT(IN,   integer)   IFPi, IFPn, IFPl
CCC_   . interior
      integer IOS,  IOSR
      logical OSET, OEOF
      integer    MaxE
      parameter (MaxE = 3)
      integer    jErrC
      integer    jturn
      integer    jp
      integer    jtype
      character  CMSG*(1024)
CCC_   = NIGEOZ
      character CRR  *(32)
      character CROOT*(32)
      character CRINH*(32)
      character CIFLG*(32)
      integer   IPOWER
      integer   NLV
      _REALSTD  DXN,  DXD
      _REALSTD  CWGT, COFS, DNM
      namelist /NIGEOZ/
     $     CROOT, CRINH, IPOWER, CWGT, COFS, CIFLG, DNM,
     $     NLV,   DXN,   DXD
      integer    LVEML
      parameter (LVEML = OPT_NAMELIST_OUTPUT_EMULATION)
CCC_  - Body
      iErr = 0
      DNMARG = 0.0d0
CCC_   . first  turn: search inheritance
      jErrC = 0
c
      KGM    = 0
      NLV    = 0
      DXD    = 0.0d0
      DXN    = 0.0d0
      IPOWER = 0
      CWGT   = 0.0d0
      COFS   = 0.0d0
      DNM    = 0.0d0
      CIFLG  = ' '
      call UUrwnd (IOS, IFPi)
      DO
         CROOT = ' '
         CRINH = ' '
         IOSR  = 0
         if (IOS .eq. 0) then
            if (IFPi.ge.0) then
               read (IFPi, NIGEOZ, IOSTAT = IOS)
            else if (IFPi.eq.-1) then
               read (*,    NIGEOZ, IOSTAT = IOS)
            else
               OSET = .true.
               goto 900
            endif
         endif
         if (IOS.eq.0) then
            if (CROOT.eq.CR) then
               OSET = .true.
               goto 900
            endif
         else
            call UUieof (OEOF, IOS)
            if (OEOF) goto 900
            jErrC = jErrC + 1
            if (jErrC.gt.MaxE) goto 900
         endif
      ENDDO
 900  continue
CCC_    * result
      CROOT = CR
      IOSR  = IOS
      if (.not.OSET) CRINH = ' '
      if (LVEML.gt.0) then
         call UNBbgn (iErr, 'NIGEOZ',       IFPn, LVEML)
         call UNBint (iErr, 'IOSR',  IOSR,  IFPn, LVEML)
         call UNBstr (iErr, 'CROOT', CROOT, IFPn, LVEML)
         call UNBstr (iErr, 'CRINH', CRINH, IFPn, LVEML)
         call UNBend (iErr, 'NIGEOZ',       IFPn, LVEML)
      else
         if      (COND_N(IFPn)) then
            write (IFPn, NIGEOZ)
         else if (COND_S(IFPn)) then
            write (*,    NIGEOZ)
         endif
      endif
CCC_   . second turn: get attributes
      IOS = 0
      KGM = -1
      do jturn = 1, 2
         CRR = CROOT
         if (jturn.gt.2) CRR = CRINH
         jErrC = 0
         OSET  = .false.
         jp    = 0
         call UUrwnd (IOS, IFPi)
         DO
            CROOT  = ' '
            IPOWER = 0
            CWGT   = 0.0d0
            COFS   = 0.0d0
            CIFLG  = ' '
            IOSR   = 0
            NLV    = 0
            DXN    = 0.0d0
            DXD    = 0.0d0
            DNM    = 0.0d0
            if (IOS .eq. 0) then
               if (IFPi.ge.0) then
                  read (IFPi, NIGEOZ, IOSTAT = IOS)
               else if (IFPi.eq.-1) then
                  read (*,    NIGEOZ, IOSTAT = IOS)
               endif
            endif
            if (IOS.eq.0) then
               if (CROOT.eq.CRR) then
                  if (KGM.lt.0) then
                     if (NLV.le.0) then
                        KGM = _GEOMETRY_POLYNOMIAL
                     else
                        KGM = _GEOMETRY_LEVELS
                     endif
                  endif
                  if (KGM.eq. _GEOMETRY_LEVELS) then
                     if (IPOWER.ne.0
     $                    .or. CWGT.ne.0.0d0
     $                    .or. COFS.ne.0.0d0) then
                        iErr = -999
                        goto 2900
                     endif
                     jp = jp + 1
                     if (jp.le.LT) then
                        IX    (jp) = NLV
                        CT (1, jp) = DXN
                        CT (2, jp) = DXD
                        KIT   (jp) = ITEM_DEFAULT
                     endif
                  else if (KGM.eq. _GEOMETRY_POLYNOMIAL) then
                     if (NLV.ne.0
     $                    .or. DXN.ne.0.0d0
     $                    .or. DXD.ne.0.0d0) then
                        iErr = -999
                        goto 2900
                     endif
                     if (DNM.ne.0.0d0) then
                        if (DNMARG.ne.0.0d0) then
                           iErr = -999
                           goto 2900
                        endif
                        DNMARG = DNM
                     endif
                     if (CIFLG.eq.'E') then
                        jtype = ITEM_EXPONENT
                     else
                        jtype = ITEM_POLYNOMIAL
                     endif
                     jp = jp + 1
                     if (jp.le.LT) then
                        IX    (jp) = IPOWER
                        CT (1, jp) = CWGT
                        CT (2, jp) = COFS
                        KIT   (jp) = jtype
                     endif
                  endif
               endif
            else
               call UUieof (OEOF, IOS)
               if (OEOF) goto 1900
               jErrC = jErrC + 1
               if (jErrC.gt.MaxE) goto 1900
            endif
         ENDDO
 1900    continue
         if (jp.gt.0) goto 2900
      ENDDO
 2900 continue
CCC_    * adjustment
      iErr = 0
 201  format ('AGZRNM[', A, '] OVERFLOW ', 2I4)
 202  format ('AGZRNM[', A, ':', A, '] CONFIGURED/', I1, 1x, I4)
 203  format ('AGZRNM[', A, ':', A, '] DEFAULT/',    I1, 1x, I4)
 204  format ('AGZRNM[', A, ':', A, '] LINEAR ')
CCC_     + overflow
      if      (jp.gt.LT) then
         iErr = -1
         write (CMSG, 201) _TRIM(CRR), JP, LT
         NT   = 0
CCC_     + configured
      else if (jp.gt.0) then
         NT   = jp
         write (CMSG, 202) _TRIM(CR), _TRIM(CRR), KGM, NT
CCC_     + default (argument)
      else if (NTdef.gt.0) then
         KGM = KGMdef
         NT  = NTdef
         write (CMSG, 203) _TRIM(CR), _TRIM(CRR), KGM, NT
         do jp = 1, NT
            IX    (jp) = IXdef    (jp)
            CT (1, jp) = CTdef (1, jp)
            CT (2, jp) = CTdef (2, jp)
            KIT   (jp) = KITdef(jp)
         enddo
CCC_     + linear
      else
         write (CMSG, 204) _TRIM(CR), _TRIM(CRR)
         NT = 1
         jp = 1
         IX    (jp) = 1
         CT (1, jp) = 1.0d0
         CT (2, jp) = 0.0d0
         KIT   (jp) = ITEM_POLYNOMIAL
         KGM = _GEOMETRY_POLYNOMIAL
      endif
CCC_     + message
      if      (COND_N(IFPl)) then
         write (IFPl, '(A)') _TRIM(CMSG)
      else if (COND_S(IFPl)) then
         write (*,    '(A)') _TRIM(CMSG)
      endif
CCC_    * result
      if (iErr.eq.0) then
         CROOT = CR
         IOSR  = IOS
         do jp = 1, NT
            if (LVEML.gt.0) then
               call UNBbgn (iErr, 'NIGEOZ',             IFPn, LVEML)
               call UNBint (iErr, 'IOSR',   IOSR,       IFPn, LVEML)
               call UNBstr (iErr, 'CROOT',  CROOT,      IFPn, LVEML)
               if (KGM .eq. _GEOMETRY_LEVELS) then
                  call UNBint (iErr, 'NLV',    IX   (jp),  IFPn, LVEML)
                  call UNBrst (iErr, 'DXN',    CT (1,jp),  IFPn, LVEML)
                  call UNBrst (iErr, 'DXD',    CT (2,jp),  IFPn, LVEML)
               else
                  call UNBrst (iErr, 'CWGT',   CT (1,jp),  IFPn, LVEML)
                  call UNBrst (iErr, 'COFS',   CT (2,jp),  IFPn, LVEML)
                  call UNBint (iErr, 'IPOWER', IX   (jp),  IFPn, LVEML)
                  if (jp.eq.1.and.DNMARG.ne.0.0d0) then
                     call UNBrst (iErr, 'DNM', DNMARG,  IFPn, LVEML)
                  endif
                  if (KIT(jp).eq. ITEM_EXPONENT) then
                     CIFLG = 'E'
                     call UNBstr(iErr, 'CIFLG', CIFLG, IFPn, LVEML)
                  endif
               endif
               call UNBend (iErr, 'NIGEOZ',             IFPn, LVEML)
            else
C              to implement
               if      (COND_N(IFPn)) then
                  write (IFPn, NIGEOZ)
               else if (COND_S(IFPn)) then
                  write (*,    NIGEOZ)
               endif
            endif
         enddo
      endif
      RETURN
      END
CCC_ & AGZgxp  ## Geometry configuration (extended/polynomial)
      subroutine AGZgxp
     O    (iErr,
     W     W,
     I     LW,  CR, icZa,   icZb,
     I     IPW, CF, KITYPE, NPOL, DNM,  IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   LW
      _INTENT(OUT,_REALSTD)  W (LW)
      _INTENT(IN, character) CR*(*)
      _INTENT(IN, integer)   NPOL
      _INTENT(IN, integer)   icZa,  icZb
      _INTENT(IN, integer)   IPW   (NPOL)
      _INTENT(IN, integer)   KITYPE(NPOL)
      _INTENT(IN, _REALSTD)  CF(2, NPOL)
      _INTENT(IN, _REALSTD)  DNM
      _INTENT(IN, integer)   IFPl
      integer   icBa, icBb
CCC_  - Body
      iErr = 0
c
      if (iErr.eq.0) call ACWbs1 (iErr, icBa, icZa)
      if (iErr.eq.0) call ACWbs1 (iErr, icBb, icZb)
c
      if (iErr.eq.0) then
         call AGUgpm
     O       (iErr,
     W        W,
     I        LW,
     I        IPW,   CF,   KITYPE, NPOL, DNM,
     I        icBa,  icBb, CR,     'B',  IFPl)
      endif
c
      if (iErr.eq.0) then
         call AGUgpm
     O       (iErr,
     W        W,
     I        LW,
     I        IPW,   CF,   KITYPE, NPOL, DNM,
     I        icZa,  icZb, CR,     'Z',  IFPl)
      endif
      call DATrcU (IFPl, iErr, 'R', 'AGZGXP')
      RETURN
      END
CCC_ & AGZgxl  ## Geometry configuration (extended/levels)
      subroutine AGZgxl
     O    (iErr,
     W     W,
     I     LW,   CR, icZa, icZb,
     I     NLVa, CF, NTB,  IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   LW
      _INTENT(OUT,_REALSTD)  W (LW)
      _INTENT(IN, character) CR*(*)
      _INTENT(IN, integer)   NTB
      _INTENT(IN, integer)   icZa,  icZb
      _INTENT(IN, integer)   NLVa   (NTB)
      _INTENT(IN, _REALSTD)  CF  (2, NTB)
      _INTENT(IN, integer)   IFPl
      integer   icBa, icBb
      integer   Na,   Nb,  Lab
CCC_  - Body
      iErr = 0
c
      if (iErr.eq.0) call ACWbs1 (iErr, icBa, icZa)
      if (iErr.eq.0) call ACWbs1 (iErr, icBb, icZb)
      if (iErr.eq.0) call ACWdim (iErr, Na, icBa)
      if (iErr.eq.0) call ACWdim (iErr, Nb, icBb)
c
      if (iErr.eq.0) then
         Lab = MAX (Na, Nb)
         call AGUglm
     O       (iErr,
     W        W,
     I        Lab,
     I        NLVa,  CF,   NTB,
     I        icBa,  icBb, CR,  'B', IFPl)
      endif
c
      if (iErr.eq.0) call ACWdim (iErr, Na, icZa)
      if (iErr.eq.0) call ACWdim (iErr, Nb, icZb)
      if (iErr.eq.0) then
         Lab = MAX (Na, Nb)
         call AGUglm
     O       (iErr,
     W        W,
     I        Lab,
     I        NLVa,  CF,   NTB,
     I        icZa,  icZb, CR,  'Z', IFPl)
      endif
      call DATrcU (IFPl, iErr, 'R', 'AGZGXP')
      RETURN
      END
CCC_* [AGU] Utility
CCC_ & AGUpnm  ## common namelist parser (1d)
      subroutine AGUpnm
     O    (iErr,
     M     PGA,  IGA,
     I     CR,   CK,  IFPi,  IFPn,  IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,_REALSTD)  PGA (*)
      _INTENT(INOUT,integer)   IGA (*)
      _INTENT(IN,   character) CR*(*), CK*(*)
      _INTENT(IN,   integer)   IFPi,   IFPn,  IFPl
c
      character CROOT*(32), CKIND*(32)
      _REALSTD  O, W, WN, ZDL, ZDU, RXL, RXU
      character T*(4)
      character U(UNIT_MAX)*(OPT_UNIT_LEN)
      _REALSTD  vNAN
      integer   IOSR
      namelist /NIGEOM/
     $     CROOT, CKIND,
     $     O,     T,    W, WN, U, ZDL, ZDU, RXL, RXU,
     $     vNAN,  IOSR
      integer    LVEML
      parameter (LVEML = _UNMLEM_LEVEL_ENTRY)
c$$$      parameter (LVEML = _UNMLEM_LEVEL_END)
c
      character  DefT*(4)
c
      integer    MaxE
      parameter (MaxE = 3)
      integer    IOS,  jErrC
      logical    OEOF, OSET
CCC_  - Description
CCC_   . width
CC         WN   number of elements to prescribed width, if positive.
CC              if 0, equal to N; if negative, N - value.
CC         W    reference domain width
CCC_   . boundary condition
CC         ZDL  first derivative == 0 for X <= ZDL
CC         ZDU  first derivative == 0 for X >= ZDU
CC         RXL  mirror condition at X = RXL (lower)
CC         RXU  mirror condition at X = RXU (upper)
CCC_   . origin configuration
CC         ORG  origin property
CC         TYPE scheme for origin definition
CC            'P'   {west,south} point (where i==1)
CC            'L'   origin index i (where x == 0),
CC                  can be real value or beyond the domain.
CC            'R'   ratio between origin index i to domain width x.
CC                  When 0.5, e.g., the center of the domain becomes the origin.
CC
CCC_  - Body
      iErr  = 0
      jErrC = 0
      OSET  = .false.
      call AGUk2t (DefT, IGA (AGI_OTYPE))
CCC_   . read namelist
      call UUrwnd (IOS,  IFPi)
      DO
         CROOT = ' '
         CKIND = ' '
         IOSR  = 0
c
         vNAN  = PGA (AGS_VNAN)
c
         T     = DefT
         O     = PGA (AGS_OV)
         WN    = PGA (AGS_WN)
         W     = PGA (AGS_DW)
         ZDL   = PGA (AGS_ZDL)
         ZDU   = PGA (AGS_ZDU)
         RXL   = PGA (AGS_RXL)
         RXU   = PGA (AGS_RXU)
         U (UNIT_CFG) = ' '
         U (UNIT_SYS) = ' '
         U (UNIT_EXT) = ' '
c
         if (IOS .eq. 0) then
            if (IFPi.ge.0) then
               read (IFPi, NIGEOM, IOSTAT = IOS)
            else if (IFPi.eq.-1) then
               read (*,    NIGEOM, IOSTAT = IOS)
            else
               OSET = .true.
               goto 900
            endif
         endif
         if (IOS.eq.0) then
            if (CROOT.eq.CR .and. CKIND.eq.CK) then
               OSET = .true.
               goto 900
            endif
         else
            call UUieof (OEOF, IOS)
            if (OEOF) goto 900
            jErrC = jErrC + 1
            if (jErrC.gt.MaxE) goto 900
         endif
      ENDDO
 900  continue
CCC_   . write namelist
      CROOT = CR
      CKIND = CK
      IOSR  = IOS
      if (LVEML.gt.0) then
         call UNBbgn (iErr, 'NIGEOM',       IFPn, LVEML)
c
         call UNBint (iErr, 'IOSR',  IOSR,  IFPn, LVEML)
         call UNBstr (iErr, 'CROOT', CROOT, IFPn, LVEML)
         call UNBstr (iErr, 'CKIND', CKIND, IFPn, LVEML)
c
         call UNBrst (iErr, 'O',     O,     IFPn, LVEML)
         call UNBstr (iErr, 'T',     T,     IFPn, LVEML)
         call UNBrst (iErr, 'W',     W,     IFPn, LVEML)
         call UNBrst (iErr, 'WN',    WN,    IFPn, LVEML)
         call UNBsta (iErr, 'U',     U, UNIT_MAX, 0, IFPn, LVEML)
c
         if (ZDL.ne.vNAN)
     $        call UNBrst (iErr, 'ZDL',   ZDL,   IFPn, LVEML)
         if (ZDU.ne.vNAN)
     $        call UNBrst (iErr, 'ZDU',   ZDU,   IFPn, LVEML)
         if (RXL.ne.vNAN)
     $        call UNBrst (iErr, 'RXL',   RXL,   IFPn, LVEML)
         if (RXU.ne.vNAN)
     $        call UNBrst (iErr, 'RXU',   RXU,   IFPn, LVEML)
c
         call UNBrst (iErr, 'VNAN',  vNAN,  IFPn, LVEML)
c
         call UNBend (iErr, 'NIGEOM',       IFPn, LVEML)
      else
         if      (COND_N(IFPn)) then
            write (IFPn, NIGEOM)
         else if (COND_S(IFPn)) then
            write (*,    NIGEOM)
         endif
      endif
CCC_   . store results
      PGA (AGS_VNAN) = vNAN
c
      PGA (AGS_OV)   = O
      PGA (AGS_WN)   = WN
      PGA (AGS_DW)   = W
      PGA (AGS_ZDL)  = ZDL
      PGA (AGS_ZDU)  = ZDU
      PGA (AGS_RXL)  = RXL
      PGA (AGS_RXU)  = RXU
c
      call AGUt2k (IGA (AGI_OTYPE), T)
CCC_   . return
      if (OSET) then
         iErr = 0
      else if (jErrC.gt.MaxE) then
         iErr = -1
      else
         iErr = 1
      endif
      call DATrcU (IFPl, iErr, 'R', 'AGUPNM')
      RETURN
      END
CCC_ & AGUk2t  ## geometry kind to type
      subroutine AGUk2t (T, K)
      implicit none
      _INTENT(OUT,character) T*(*)
      _INTENT(IN, integer)   K
c
      if      (K .eq. GEOMETRY_ORIGIN_INDEX)  then
         T = 'L'
      else if (K .eq. GEOMETRY_ORIGIN_RATIO)  then
         T = 'R'
      else if (K .eq. GEOMETRY_ORIGIN_EDGE)   then
         T = 'P'
      else if (K .eq. GEOMETRY_ORIGIN_NRATIO) then
         T = 'M'
      else
         T = ' '
      endif
      RETURN
      END
CCC_ & AGUt2k  ## geometry type to kind
      subroutine AGUt2k (K, T)
      implicit none
      _INTENT(OUT,integer)   K
      _INTENT(IN, character) T*(*)
c
      if      (T.eq.'L') then
         K = GEOMETRY_ORIGIN_INDEX
      else if (T.eq.'R') then
         K = GEOMETRY_ORIGIN_RATIO
      else if (T.eq.'P') then
         K = GEOMETRY_ORIGIN_EDGE
      else if (T.eq.'M') then
         K = GEOMETRY_ORIGIN_NRATIO
      else
         K = GEOMETRY_ORIGIN_ERROR
      endif
      RETURN
      END
CCC_ & AGUrsp  ## reset parameter cluster
      subroutine AGUrsp
     O    (IGA, PGA)
      implicit none
      _INTENT(OUT,integer)  IGA (*)
      _INTENT(OUT,_REALSTD) PGA (*)
      _REALSTD   DefNaN
      parameter (DefNaN = -999.9d9)
      integer    j
c
      do j = 1, AGS_MAX
         PGA (j) = DefNaN
      enddo
      do j = 1, AGI_MAX
         IGA (j) = 0
      enddo
      IGA (AGI_OTYPE) = GEOMETRY_ORIGIN_ERROR
      RETURN
      END
CCC_ & AGUife  ## check if equal-dx
      subroutine AGUife
     O    (OEQ,
     I     kCX)
      implicit none
      _INTENT(OUT,logical)   OEQ
      _INTENT(IN, integer)   kCX
      if      (kCX .eq. GEOMETRY_ORIGIN_INDEX) then
         OEQ = .true.
      else if (kCX .eq. GEOMETRY_ORIGIN_RATIO) then
         OEQ = .true.
      else if (kCX .eq. GEOMETRY_ORIGIN_EDGE)  then
         OEQ = .true.
      else if (kCX .eq. GEOMETRY_ORIGIN_NRATIO) then
         OEQ = .true.
      else
         OEQ = .false.
      endif
      RETURN
      END
CCC_ & AGUqgi  ## inquire corresponding geometry coordinate id
      subroutine AGUqgi (iErr, iuX, icX, IFPl)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   iuX
      _INTENT(IN, integer)   icX
      _INTENT(IN, integer)   IFPl
      integer IV (1), Mdim
      integer jcdmy
      iErr = 0
      iuX  = 0
      Mdim = 1
      call ACCrfI (iErr, jcdmy, IV, icX, Mdim, 'CT', IFPl)
      if (iErr.eq.0) then
         if (IV(Mdim) .eq. _GCUML) then
            call ACWbs1 (iErr, iuX, icX)
         endif
      endif
      RETURN
      END
CCC_ & AGUeqm  ## Geometry (equal grid-size) generation (main)
      subroutine AGUeqm
     O    (iErr,
     W     W,
     I     LW,
     I     kCX,  vCX,  XW,    WXN,
     I     ZDXL, ZDXU, RXL,   RXU, vNAN, Nadd,
     I     icXa, icXb, CROOT, Tag, IFPl)
CCC_  - Description
CC      icXa icXb   (possibly) coordinates with block-cumulative sizes
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,_REALSTD)  W (*)
      _INTENT(IN, integer)   LW
      _INTENT(IN, integer)   kCX
      _INTENT(IN, _REALSTD)  vCX, XW, WXN
      _INTENT(IN, _REALSTD)  ZDXU, ZDXL
      _INTENT(IN, _REALSTD)  RXU,  RXL
      _INTENT(IN, _REALSTD)  vNAN
      _INTENT(IN, integer)   Nadd
      _INTENT(IN, integer)   icXa, icXb
      _INTENT(IN, character) CROOT*(*), Tag*(*)
      _INTENT(IN, integer)   IFPl
      integer ibXa, ibXb
      integer iuXa, iuXb
      integer Na, La, Nb, Lb
      _REALSTD X0, X0b, DX
c$$$      integer IV (1), Mdim
      integer jcdmy, jFlgF
CCC_  - Body
      iErr = 0
c
      jFlgF = 0
      call ACCfi1(iErr, jcdmy, jFlgF, icXa, 'FN', IFPl)
c$$$      write (*,*) 'FN',iErr,icXa, jFlgF
      if (iErr.eq.0.and.jFlgF.ne.0) then
         call ACCri1 (iErr, jcdmy, _GCUML, icXa, 'CT', IFPl)
         if (iErr.eq.0) call ACWbs1 (iErr, iuXa, icXa)
         if (iErr.eq.0) call ACWbs1 (iErr, ibXa, iuXa)
         if (iErr.eq.0) call ACWdim (iErr, Na,   ibXa)
         if (iErr.eq.0) call ACWdim (iErr, La,   iuXa)
      else
         iErr = 0
         iuXa = icXa
         if (iErr.eq.0) call ACWbs1 (iErr, ibXa, iuXa)
         if (iErr.eq.0) call ACWdim (iErr, Na,   ibXa)
         if (iErr.eq.0) call ACWdim (iErr, La,   iuXa)
      endif
      call DATrcU (IFPl, iErr, 'CHK:A', 'AGUEQM')
c
      jFlgF = 0
      call ACCfi1(iErr, jcdmy, jFlgF, icXb, 'FN', IFPl)
c$$$      write (*,*) 'FN',iErr,icXb, jFlgF
      if (iErr.eq.0.and.jFlgF.ne.0) then
         call ACCri1 (iErr, jcdmy, _GCUML, icXb, 'CT', IFPl)
         if (iErr.eq.0) call ACWbs1 (iErr, iuXb, icXb)
         if (iErr.eq.0) call ACWbs1 (iErr, ibXb, iuXb)
         if (iErr.eq.0) call ACWdim (iErr, Nb,   ibXb)
         if (iErr.eq.0) call ACWdim (iErr, Lb,   iuXb)
      else
         iErr = 0
         iuXb = icXb
         if (iErr.eq.0) call ACWbs1 (iErr, ibXb, iuXb)
         if (iErr.eq.0) call ACWdim (iErr, Nb,   ibXb)
         if (iErr.eq.0) call ACWdim (iErr, Lb,   iuXb)
      endif
      call DATrcU (IFPl, iErr, 'CHK:B', 'AGUEQM')
c$$$      if (iErr.eq.0) then
c$$$         Mdim      = 1
c$$$         IV (Mdim) = _GCUML
c$$$         call ACCrgI (iErr, jcdmy, IV, icXa, 1, 'CT', IFPl)
c$$$         call ACCrgI (iErr, jcdmy, IV, icXb, 1, 'CT', IFPl)
c$$$      endif
c$$$      if (iErr.eq.0) call ACWbs1 (iErr, ibXa, icXa)
c$$$      if (iErr.eq.0) call ACWdim (iErr, Na,   ibXa)
c$$$      if (iErr.eq.0) call ACWdim (iErr, La,   icXa)
c$$$      if (iErr.eq.0) call ACWbs1 (iErr, ibXb, icXb)
c$$$      if (iErr.eq.0) call ACWdim (iErr, Nb,   ibXb)
c$$$      if (iErr.eq.0) call ACWdim (iErr, Lb,   icXb)
c
      if (WXN.gt.0.0d0) then
         DX = DABS (XW) / WXN
      else
         DX = DABS (XW) / (DBLE (Na) + WXN)
      endif
      if (XW.ge.0.0d0) then
         if      (kCX .eq. GEOMETRY_ORIGIN_INDEX) then
            X0 = - (vCX - 1.0d0) * DX
         else if (kCX .eq. GEOMETRY_ORIGIN_RATIO) then
            X0 = - XW * vCX
         else if (kCX .eq. GEOMETRY_ORIGIN_NRATIO) then
            X0 = - (DBLE (Na) - 1.0d0) * vCX * DX
         else if (kCX .eq. GEOMETRY_ORIGIN_EDGE)  then
            X0 = vCX
         else
            X0 = 0.0d0
            iErr = -1
         endif
      else
         if      (kCX .eq. GEOMETRY_ORIGIN_INDEX) then
            X0 = XW - (vCX - 1.0d0) * DX
         else if (kCX .eq. GEOMETRY_ORIGIN_RATIO) then
            X0 = - XW * vCX
         else if (kCX .eq. GEOMETRY_ORIGIN_NRATIO) then
            X0 = - (DBLE (Na) - 1.0d0) * vCX * DX
         else if (kCX .eq. GEOMETRY_ORIGIN_EDGE)  then
            X0 = vCX
         else
            X0 = 0.0d0
            iErr = -1
         endif
      endif
 101  format ('AGUEQM:', A, ':', A, ':', 2E16.8)
      if      (COND_N(IFPl)) then
c$$$         write (IFPl, *) XW, kCX
         write (IFPl, 101) _TRIM(CROOT), _TRIM(Tag), DX, DX / 2.0d0
      else if (COND_S(IFPl)) then
c$$$         write (*, *) XW, kCX
         write (*,    101) _TRIM(CROOT), _TRIM(Tag), DX, DX / 2.0d0
      endif
c
      if (iErr.eq.0) then
         Na = Na + MAX (0, Nadd)
         call AGUeqs
     $       (iErr, W, LW, X0,  DX, ZDXL, ZDXU, RXL, RXU, vNAN,
     $        iuXa, Na, La, iuXb, Nb, Lb, 0, IFPl)
c$$$         call AGUeqs
c$$$     $       (iErr, W, LW, X0,  DX, ZDXL, ZDXU, RXL, RXU, vNAN,
c$$$     $        icXa, Na, La, icXb, Nb, Lb, 0, IFPl)
      endif
      call DATrcU (IFPl, iErr, 'CHK:C', 'AGUEQM')
      if (iErr.eq.0) then
         Nb = Nb + MAX (0, Nadd)
         X0b = X0 + DX * 0.5d0
         call AGUeqs
     $       (iErr, W, LW, X0b, DX, ZDXL, ZDXU, RXL, RXU, vNAN,
     $        iuXb, Nb, Lb, iuXa, Na, La, 1, IFPl)
c$$$         call AGUeqs
c$$$     $       (iErr, W, LW, X0b, DX, ZDXL, ZDXU, RXL, RXU, vNAN,
c$$$     $        icXb, Nb, Lb, icXa, Na, La, 1, IFPl)
      endif
      call DATrcU (IFPl, iErr, 'R', 'AGUEQM')
      RETURN
      END
CCC_ & AGUeqs  ## Geometry (equal grid-size) generation (sub)
      subroutine AGUeqs
     O    (iErr,
     W     W,
     I     LW,
     I     X0,   DX, ZDXL, ZDXU, RXL, RXU, vNAN,
     I     iuXo, No, Lo, iuXh, Nh, Lh, KSW, IFPl)
      implicit none
      _INTENT(OUT,integer)  iErr
      _INTENT(IN, integer)  No,  Lo,  Nh, Lh
      _INTENT(OUT,_REALSTD) W (Lo, *)
      _INTENT(IN, _REALSTD) X0, DX
      _INTENT(IN, _REALSTD) ZDXL, ZDXU, RXL, RXU, vNAN
      _INTENT(IN, integer)  LW
      _INTENT(IN, integer)  iuXo, iuXh
      _INTENT(IN, integer)  KSW
      _INTENT(IN, integer)  IFPl
      integer j, js, je
      integer jcdmy
      _REALSTD F
      _REALSTD FRUa, FRLa, FRUb, FRLb
      _REALSTD ERUa, ERLa, ERUb, ERLb
      _REALSTD XS
      integer IV (1), Mdim
c
      integer    KCO,     KCP,     KVa,     KVb
      parameter (KCO = 1, KCP = 2, KVa = 3, KVb = 4)
CCC_  - Body
CC    Dummy statement
CC    Lh, Nh are reserved for future (e.g., periodical bc)
      iErr = ((0 * iuXh) * Lh) * Nh
CCC_  - Array size check
      if (LW.gt.0 .and. LW.lt.(Lo * KVb)) then
         iErr = -1
         write(*, *) 'AGUEQS:', LW, Lo, KVb, Lo * KVb
      endif
      call DATrcU (IFPl, iErr, 'CHK:0', 'AGUEQS')
CCC_  - CT update
      if (iErr.eq.0) then
         Mdim      = 1
         if (DX.eq.0.0d0) then
            IV (Mdim) = _GZERO
         else
            IV (Mdim) = _GCARTESIAN
         endif
         call ACCrgI (iErr, jcdmy, IV, iuXo, 1, 'CT', IFPl)
      endif
      call DATrcU (IFPl, iErr, 'CHK:CT', 'AGUEQS')
CCC_  - CO (logical)
      if (iErr.eq.0) then
         call AGUxex (W (1, KCO), Lo, DX, X0)
         call ACCrgD (iErr, jcdmy, W (1, KCO),  iuXo, Lo,  'CO', IFPl)
      endif
      call DATrcU (IFPl, iErr, 'CHK:C0', 'AGUEQS')
CCC_  - CP (physical)
      if (iErr.eq.0) then
         call AGUxex (W (1, KCP), Lo, DX, X0)
         call ACCrgD (iErr, jcdmy, W (1, KCP),  iuXo, Lo,  'CP', IFPl)
      endif
      call DATrcU (IFPl, iErr, 'CHK:CP', 'AGUEQS')
CCC_  - DC
      if (iErr.eq.0) then
         do j = 1, Lo
            W (j, KVa) = DX
         enddo
         call ACCrgD (iErr, jcdmy, W (1, KVa),  iuXo, Lo,  'DC', IFPl)
      endif
      call DATrcU (IFPl, iErr, 'CHK:DC', 'AGUEQS')
CCC_  - DP
      if (iErr.eq.0) then
         do j = 1, Lo
            W (j, KVa) = DX
         enddo
         call ACCrgD (iErr, jcdmy, W (1, KVa),  iuXo, Lo,  'DP', IFPl)
      endif
      call DATrcU (IFPl, iErr, 'CHK:DP', 'AGUEQS')
CCC_  * D; G
      if (KSW.eq.0) then
         F    = -1.0d0
         js   = 1
         je   = No - 1
         XS   = DX / 2.0d0
         FRLa =  0.0d0
         FRLb = +2.0d0
         FRUa = -2.0d0
         FRUb =  0.0d0
         ERLa =  0.0d0
         ERLb =  1.0d0
         ERUa =  1.0d0
         ERUb =  0.0d0
      else
         F    = +1.0d0
         js   = 2
         je   = No
         XS   = -DX / 2.0d0
         FRLa = +2.0d0
         FRLb =  0.0d0
         FRUa =  0.0d0
         FRUb = -2.0d0
         ERLa =  1.0d0
         ERLb =  0.0d0
         ERUa =  0.0d0
         ERUb =  1.0d0
      endif
      if (iErr.eq.0) then
         if (DX.eq.0.0d0) then
            do j = 1, Lo
               W (j, KVa) = 0.0d0
               W (j, KVb) = 0.0d0
            enddo
         else
            do j = js, je
               W (j, KVa) = (+ F) / DX
               W (j, KVb) = (- F) / DX
            enddo
            do j = 1, js - 1
               W (j, KVa) = 0.0d0
               W (j, KVb) = 0.0d0
            enddo
            do j = 1 + je, Lo
               W (j, KVa) = 0.0d0
               W (j, KVb) = 0.0d0
            enddo
         endif
         if (ZDXL.ne.vNAN) then
            do j = 1, Lo
               if (W (j, KCO)+XS.le.ZDXL) then
                  W (j, KVa) = 0.0d0
                  W (j, KVb) = 0.0d0
               endif
            enddo
         endif
         if (ZDXU.ne.vNAN) then
            do j = 1, Lo
               if (W (j, KCO)+XS.ge.ZDXU) then
                  W (j, KVa) = 0.0d0
                  W (j, KVb) = 0.0d0
               endif
            enddo
         endif
         if (RXL.ne.vNAN) then
            do j = 1, Lo
               if (W (j, KCO)+XS.eq.RXL) then
                  W (j, KVa) = FRLa / DX
                  W (j, KVb) = FRLb / DX
               endif
            enddo
         endif
         if (RXU.ne.vNAN) then
            do j = 1, Lo
               if (W (j, KCO)+XS.eq.RXU) then
                  W (j, KVa) = FRUa / DX
                  W (j, KVb) = FRUb / DX
               endif
            enddo
         endif
         call ACCrgD (iErr, jcdmy, W (1, KVa),  iuXo, Lo,  'GA', IFPl)
         call ACCrgD (iErr, jcdmy, W (1, KVa),  iuXo, Lo,  'DA', IFPl)
         call ACCrgD (iErr, jcdmy, W (1, KVb),  iuXo, Lo,  'GB', IFPl)
         call ACCrgD (iErr, jcdmy, W (1, KVb),  iuXo, Lo,  'DB', IFPl)
      endif
      call DATrcU (IFPl, iErr, 'CHK:GD', 'AGUEQS')
CCC_  * L
      if (iErr.eq.0) then
         do j = js, je
            W (j, KVa) = 0.5d0
            W (j, KVb) = 0.5d0
         enddo
         do j = 1, js - 1
            W (j, KVa) = 0.0d0
            W (j, KVb) = 0.0d0
         enddo
         do j = 1 + je, Lo
            W (j, KVa) = 0.0d0
            W (j, KVb) = 0.0d0
         enddo
         if (RXL.ne.vNAN) then
            do j = 1, Lo
               if (W (j, KCO)+XS.eq.RXL) then
                  W (j, KVa) = ERLa
                  W (j, KVb) = ERLb
               endif
            enddo
         endif
         if (RXU.ne.vNAN) then
            do j = 1, Lo
               if (W (j, KCO)+XS.eq.RXU) then
                  W (j, KVa) = ERUa
                  W (j, KVb) = ERUb
               endif
            enddo
         endif
         call ACCrgD (iErr, jcdmy, W (1, KVa),  iuXo, Lo,  'LA', IFPl)
         call ACCrgD (iErr, jcdmy, W (1, KVb),  iuXo, Lo,  'LB', IFPl)
      endif
      call DATrcU (IFPl, iErr, 'CHK:L', 'AGUEQS')
CCC_  * ZO
      if (iErr.eq.0) then
         do j = js, je
            W (j, KVa) = 1.0d0
         enddo
         do j = 1, js - 1
            W (j, KVa) = 1.0d0
         enddo
         do j = 1 + je, Lo
            W (j, KVa) = 1.0d0
         enddo
         if (RXL.ne.vNAN) then
            do j = 1, Lo
               if (W (j, KCO)+XS.eq.RXL) then
                  W (j, KVa) = 0.0d0
               endif
            enddo
         endif
         if (RXU.ne.vNAN) then
            do j = 1, Lo
               if (W (j, KCO)+XS.eq.RXU) then
                  W (j, KVa) = 0.0d0
               endif
            enddo
         endif
         call ACCrgD (iErr, jcdmy, W (1, KVa),  iuXo, Lo,  'ZO', IFPl)
      endif
      call DATrcU (IFPl, iErr, 'CHK:Z', 'AGUEQS')
#if 0
CCC_  * DA; GA
      if (KSW.eq.0) then
         F    = -1.0d0
         js   = 1
         je   = No - 1
         XS   = DX / 2.0d0
         FRLa =  0.0d0
         FRLb =  2.0d0
         FRUa = -2.0d0
         FRUb =  0.0d0
         ERLa =  0.0d0
         ERUa = -2.0d0
         ERLb =  2.0d0
         ERUb =  0.0d0
      else
         F    = +1.0d0
         js   = 2
         je   = No
         XS   = -DX / 2.0d0
         FRLa = +2.0d0
         FRLb =  0.0d0
         FRUa =  0.0d0
         FRUb = -2.0d0
         ERLa = +2.0d0
         ERUa =  0.0d0
         ERLb =  0.0d0
         ERUb = -2.0d0
      endif
      if (iErr.eq.0) then
         if (DX.eq.0.0d0) then
            do j = 1, Lo
               W (j, KV) = 0.0d0
            enddo
         else
            do j = js, je
               W (j, KV) = F / DX
            enddo
            do j = 1, js - 1
               W (j, KV) = 0.0d0
            enddo
            do j = 1 + je, Lo
               W (j, KV) = 0.0d0
            enddo
         endif
c$$$         if (ZDXL.ne.vNAN) then
c$$$            do j = 1, Lo
c$$$               if (W (j, KCO)+XS.le.ZDXL) W (j, KV) = 0.0d0
c$$$            enddo
c$$$         endif
c$$$         if (ZDXU.ne.vNAN) then
c$$$            do j = 1, Lo
c$$$               if (W (j, KCO)+XS.ge.ZDXU) W (j, KV) = 0.0d0
c$$$            enddo
c$$$         endif
CCC_   + gradient if mirror
         if (RXL.ne.vNAN) then
            do j = 1, Lo
               if (W (j, KCO)+XS.eq.RXL) W (j, KV) = 0.0d0
            enddo
         endif
         if (RXU.ne.vNAN) then
            do j = 1, Lo
               if (W (j, KCO)+XS.eq.RXU) W (j, KV) = 0.0d0
            enddo
         endif
         call ACCrgD (iErr, jcdmy, W (1, KV),  icXo, Lo,  'GA', IFPl)
CCC_   + divergence if mirror
         if (RXL.ne.vNAN) then
            do j = 1, Lo
               if (W (j, KCO)+XS.eq.RXL) W (j, KV) = FRLa / DX
            enddo
         endif
         if (RXU.ne.vNAN) then
            do j = 1, Lo
               if (W (j, KCO)+XS.eq.RXU) W (j, KV) = FRUa / DX
            enddo
         endif
         call ACCrgD (iErr, jcdmy, W (1, KV),  icXo, Lo,  'DA', IFPl)
      endif
CCC_  - DB; GB
      if (iErr.eq.0) then
         if (DX.eq.0.0d0) then
            do j = 1, Lo
               W (j, KV) = 0.0d0
            enddo
         else
            do j = js, je
               W (j, KV) = (- F) / DX
            enddo
            do j = 1, js - 1
               W (j, KV) = 0.0d0
            enddo
            do j = 1 + je, Lo
               W (j, KV) = 0.0d0
            enddo
         endif
c$$$         if (ZDXL.ne.vNAN) then
c$$$            do j = 1, Lo
c$$$               if (W (j, KCO)+XS.le.ZDXL) W (j, KV) = 0.0d0
c$$$            enddo
c$$$         endif
c$$$         if (ZDXU.ne.vNAN) then
c$$$            do j = 1, Lo
c$$$               if (W (j, KCO)+XS.ge.ZDXU) W (j, KV) = 0.0d0
c$$$            enddo
c$$$         endif
CCC_   + gradient if mirror
         if (RXL.ne.vNAN) then
            do j = 1, Lo
               if (W (j, KCO)+XS.eq.RXL) W (j, KV) = 0.0d0
            enddo
         endif
         if (RXU.ne.vNAN) then
            do j = 1, Lo
               if (W (j, KCO)+XS.eq.RXU) W (j, KV) = 0.0d0
            enddo
         endif
         call ACCrgD (iErr, jcdmy, W (1, KV),  icXo, Lo,  'GB', IFPl)
CCC_   + divergence if mirror
         if (RXL.ne.vNAN) then
            do j = 1, Lo
               if (W (j, KCO)+XS.eq.RXL) W (j, KV) = FRLb / DX
            enddo
         endif
         if (RXU.ne.vNAN) then
            do j = 1, Lo
               if (W (j, KCO)+XS.eq.RXU) W (j, KV) = FRUb / DX
            enddo
         endif
         call ACCrgD (iErr, jcdmy, W (1, KV),  icXo, Lo,  'DB', IFPl)
      endif
#endif
c$$$CCC_  - LB/Xa
c$$$      if (iErr.eq.0) then
c$$$         do j = js, je
c$$$         enddo
c$$$         do j = 1, js - 1
c$$$            W (j, KVb) = 0.0d0
c$$$         enddo
c$$$         do j = 1 + je, Lo
c$$$            W (j, KVb) = 0.0d0
c$$$         enddo
c$$$         call ACCrgD (iErr, jcdmy, W (1, KV),  icXo, Lo,  'LB', IFPl)
c$$$      endif
      RETURN
      END
CCC_ & AGUgpm  ## Geometry (polynomial) configuration (main)
      subroutine AGUgpm
     O    (iErr,
     W     W,
     I     LW,
     I     IPW,  CF,   KITYPE, NPOL, DNM,
     I     icXa, icXb, CROOT,  Tag,  IFPl)
CCC_  - declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   LW
      _INTENT(OUT,_REALSTD)  W (LW)
      _INTENT(IN, integer)   icXa, icXb
      _INTENT(IN, integer)   NPOL
      _INTENT(IN, integer)   IPW(NPOL)
      _INTENT(IN, integer)   KITYPE(NPOL)
      _INTENT(IN, _REALSTD)  CF  (2, NPOL)
      _INTENT(IN, _REALSTD)  DNM
      _INTENT(IN, character) CROOT*(*), Tag*(*)
      _INTENT(IN, integer)   IFPl
      integer   Na, Nb
      integer   j
      integer   jcdmy
      integer   Nadd, IZB, IZT
      integer   IV (2)
      integer   Mdim
      integer   kCZ
      _REALSTD  vCZ,  ZW,  WZN
      _REALSTD  vNAN, ZDL, ZDU, RXL, RXU
CCC_  - Body
      iErr = 0
c
      if (iErr.eq.0) call ACWdim (iErr, Na, icXa)
      if (iErr.eq.0) call ACWdim (iErr, Nb, icXb)
c
      IZB = 0
      IZT = 0
      if (iErr.eq.0) then
         Mdim = 2
         call ACCrfI (iErr, jcdmy, IV, icXa, Mdim, 'XT', IFPl)
         if (iErr.eq.0) then
            IZB = IV (1)
            IZT = IV (2)
         else
 201        format ('AGUGPM: clear error ', 2I5)
            if      (COND_N(IFPl)) then
               write (IFPl, 201) icXa, icXb
            else if (COND_S(IFPl)) then
               write (*,    201) icXa, icXb
            endif
            iErr = 0
         endif
      endif
c
      if (iErr.eq.0) then
         Nadd = IZB + IZT
         kCZ  = GEOMETRY_ORIGIN_INDEX
         vCZ  = DBLE (IZB) + 1.0d0
         ZW   = 1.0d0
         WZN  = -1.0d0
         vNAN = -999.9d9
         ZDL  = vNAN
         ZDU  = vNAN
         RXL  = vNAN
         RXU  = vNAN
         call AGUeqm
     $       (iErr, W,    LW,
     $        kCZ,  vCZ,  ZW,    WZN,  ZDL, ZDU, RXL, RXU, vNAN, Nadd,
     $        icXa, icXb, CROOT, 'ZB', IFPl)
      endif
      call DATrcU (IFPl, iErr, 'CHK0', 'AGUGPM')
c
      if (iErr.eq.0) then
         call AGUgps
     $        (iErr, W, LW, IPW, CF, KITYPE, NPOL, DNM, icXa,  Na, IFPl)
      endif
      call DATrcU (IFPl, iErr, 'CHK1', 'AGUGPM')
      if (iErr.eq.0) then
         call AGUgps
     $        (iErr, W, LW, IPW, CF, KITYPE, NPOL, DNM, icXb,  Nb, IFPl)
      endif
      if (iErr.eq.0) then
         call AGUgph
     $        (iErr, W, LW, icXa, Na, icXb, Nb, IFPl)
      endif
      call DATrcU (IFPl, iErr, 'CHK2', 'AGUGPM')
      if (iErr.eq.0) then
         call ACCrfD (iErr, jcdmy, W (1 + Na), icXb, -1, 'CP', IFPl)
         W (1) = 0.0d0
         do j = 2, Na - 1
            W (j) = W (j + Na) - W (j + Na - 1)
         enddo
         W (Na) = 0.0d0
         call ACCrgD (iErr, jcdmy, W,  icXa, Na,  'DP', IFPl)
      endif
      call DATrcU (IFPl, iErr, 'CHK3', 'AGUGPM')
      if (iErr.eq.0) then
         call ACCrfD (iErr, jcdmy, W (1 + Nb), icXa, -1, 'CP', IFPl)
         do j = 1, Nb
            W (j) = W (j + Nb + 1) - W (j + Nb)
         enddo
         call ACCrgD (iErr, jcdmy, W,  icXb, Nb,  'DP', IFPl)
      endif
      call DATrcU (IFPl, iErr, 'CHK4', 'AGUGPM')
c
 101  format ('AGUGPM:', A, ':', A, ':', 2I3, 1x, I3, 1x, 2E16.8)
      do j = 1, NPOL
         if      (COND_N(IFPl)) then
            write (IFPl, 101)
     $           _TRIM(CROOT), _TRIM(Tag), j, NPOL, IPW (j),
     $           CF (1, j), CF (2, j)
         else if (COND_S(IFPl)) then
            write (*,    101)
     $           _TRIM(CROOT), _TRIM(Tag), j, NPOL, IPW (j),
     $           CF (1, j), CF (2, j)
         endif
      enddo
      call DATrcU (IFPl, iErr, CROOT, 'AGUGPM')
c
      RETURN
      END
CCC_ & AGUgps  ## Geometry (polynomial) configuration (sub)
      subroutine AGUgps
     O    (iErr,
     W     W,
     I     LW,
     I     IPW,  CF,   KITYPE, NPOL,  DNM,
     I     icX,  NX,   IFPl)
CCC_  - Note
CC     ZZ = sum (CF (j,1) (  Z + CF (j,2)) ** IPW (j))   if CF (j,2) ge 0
CC     ZZ = sum (CF (j,1) (- Z - CF (j,2)) ** IPW (j))   if CF (j,2) lt 0
CC     item formulation
CC       KITYPE 0  (Z + CF2) ** PW
CC              0  (- Z - CF2) ** PW
CC              1  (exp [PW * Z] + CF2) /  (exp [PW] + CF2)
CC     use DNM to normalize if not zero, otherwise use sum CF(j,1).
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)  iErr
      _INTENT(IN, integer)  NX
      _INTENT(OUT,_REALSTD) W (NX, *)
      _INTENT(IN, integer)  LW
      _INTENT(IN, integer)  icX
      _INTENT(IN, integer)  NPOL
      _INTENT(IN, integer)  IPW (NPOL)
      _INTENT(IN, integer)  KITYPE(NPOL)
      _INTENT(IN, _REALSTD) CF  (2, NPOL)
      _INTENT(IN, _REALSTD) DNM
      _INTENT(IN, integer)  IFPl
      _REALSTD  DN, Z, P, PP, CP
      _REALSTD  TC, TS
      _REALSTD  TED, TEN
c$$$      _REALSTD  DP
      integer   jz, jp
      integer   jcdmy
c$$$      integer   jzsp
CCC_  - Body
      iErr = 0
CCC_  - Array size check
      if (LW.gt.0 .and. LW.lt.(2 * NX)) iErr = -1
c$$$      write (*, *) 'CHK 00', iErr, icX
CCC_  - Get logical coordinates
      if (iErr.eq.0) then
         call ACCrfD (iErr, jcdmy, W (1, 2), icX, -1, 'CO', IFPl)
      endif
CCC_  - Compute derived coordinate
      if (iErr.eq.0) then
         if (DNM.ne.0.0d0) then
            DN = DNM
         else
            DN = 0.0d0
            DO jp = 1, NPOL
               DN = DN + CF (1, jp)
            ENDDO
         endif
         do jz = 1, NX
            W (jz, 1) = 0.0d0
         enddo
         do jp = 1, NPOL
            P  = DBLE (IPW (jp))
            TC = CF (2, jp)
            if (KITYPE(jp).eq. ITEM_POLYNOMIAL) then
               TS = 1.0d0
               if (TC.lt.0.0d0) then
                  TC = - TC
                  TS = -1.0d0
               endif
               do jz = 1, NX
                  Z = TS * W (jz, 2) + TC
                  W (jz, 1) = W (jz, 1) + CF (1, jp) * (Z ** P)
               enddo
            else if (KITYPE(jp).eq. ITEM_EXPONENT) then
               TED = EXP(P) + TC
               do jz = 1, NX
                  Z = P * W (jz, 2)
                  TEN = EXP(Z) + TC
                  W (jz, 1) = W (jz, 1) + CF (1, jp) * (TEN / TED)
               enddo
            else
               write(*, *) 'INVALID ITEM TYPE', jp, KITYPE(jp)
               stop
            endif
         enddo
         do jz = 1, NX
            W (jz, 1) = W (jz, 1) / DN
         enddo
         call ACCrgD (iErr, jcdmy, W,  icX, NX,  'CP', IFPl)
      endif
CCC_  - Compute the first derivative
      if (iErr.eq.0) then
         do jz = 1, NX
            W (jz, 1) = 0.0d0
         enddo
         do jp = 1, NPOL
            P  = DBLE (IPW (jp))
            TC = CF (2, jp)
            if (KITYPE(jp).eq. ITEM_POLYNOMIAL) then
               PP = P - 1.0d0
               TS = 1.0d0
               if (TC.lt.0.0d0) then
                  TC = - TC
                  TS = -1.0d0
               endif
               CP = TS * P
               if (CP.ne.0.0d0)then
                  do jz = 1, NX
                     Z = TS * W (jz, 2) + TC
                     W (jz, 1) = W (jz, 1)
     $                    + CP * CF (1, jp) * (Z ** PP)
                  enddo
               endif
            else if (KITYPE(jp).eq. ITEM_EXPONENT) then
               TED = EXP(P) + TC
               do jz = 1, NX
                  Z = P * W (jz, 2)
                  TEN = P * EXP(Z)
                  W (jz, 1) = W (jz, 1) + CF (1, jp) * (TEN / TED)
               enddo
            endif
         enddo
         do jz = 1, NX
            W (jz, 1) = W (jz, 1) / DN
         enddo
         call ACCrgD (iErr, jcdmy, W,  icX, NX,  'D1', IFPl)
      endif
CCC_  - Compute the second derivative
      if (iErr.eq.0) then
         do jz = 1, NX
            W (jz, 1) = 0.0d0
         enddo
         do jp = 1, NPOL
            P  = DBLE (IPW (jp))
            TC = CF (2, jp)
            if (KITYPE(jp).eq. ITEM_POLYNOMIAL) then
               PP = P - 2.0d0
               TS = 1.0d0
               if (TC.lt.0.0d0) then
                  TC = - TC
                  TS = -1.0d0
               endif
               CP = P * (P - 1.0d0)
               if (CP.ne.0.0d0) then
                  do jz = 1, NX
                     Z = TS * W (jz, 2) + TC
                     W (jz, 1) = W (jz, 1)
     $                    + CP * CF (1, jp) * (Z ** PP)
                  enddo
               endif
            else if (KITYPE(jp).eq. ITEM_EXPONENT) then
               TED = EXP(P) + TC
               do jz = 1, NX
                  Z = P * W (jz, 2)
                  TEN = (P * P) * EXP(Z)
                  W (jz, 1) = W (jz, 1) + CF (1, jp) * (TEN / TED)
               enddo
            endif
         enddo
         do jz = 1, NX
            W (jz, 1) = W (jz, 1) / DN
         enddo
         call ACCrgD (iErr, jcdmy, W,  icX, NX,  'D2', IFPl)
      endif
      RETURN
      END
CCC_ & AGUgph  ## Geometry (polynomial) configuration (health check)
      subroutine AGUgph
     O    (iErr,
     W     W,
     I     LW,
     I     icXa, NXa, icXb, NXb,  IFPl)
CCC_  - Note
CC      Check d1 == 0 only at the bottom
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)  iErr
      _INTENT(IN, integer)  NXa, NXb
      _INTENT(OUT,_REALSTD) W(NXa, *)
      _INTENT(IN, integer)  LW
      _INTENT(IN, integer)  icXa, icXb
      _INTENT(IN, integer)  IFPl
      integer   jz, jzspa, jzspb
      integer   jcdmy
      integer   jv
      integer   KPa, KDa, KPb, KCb, KW
      _REALSTD  V,   VD
CCC_  - Body
      iErr = 0
      KPa = 1
      KDa = 2
      KPb = 3
      KCb = 4
      KW  = 5
      jzspa = 0
      jzspb = 0
      if (LW.gt.0 .and. LW.lt.(5 * NXa)) iErr = -1
      if (iErr.eq.0) then
         call ACCrfD (iErr, jcdmy, W(1, KPa), icXa, -1, 'CP', IFPl)
      endif
      if (iErr.eq.0) then
         call ACCrfD (iErr, jcdmy, W(1, KPb), icXb, -1, 'CP', IFPl)
      endif
      if (iErr.eq.0) then
         call ACCrfD (iErr, jcdmy, W(1, KCb), icXb, -1, 'CO', IFPl)
      endif
      if (iErr.eq.0) then
         call ACCrfD (iErr, jcdmy, W(1, KDa), icXa, -1, 'D1', IFPl)
      endif
c$$$      write(IFPl, *) W(:,KPa)
c$$$      write(IFPl, *) W(:,KPb)
c$$$      write(IFPl, *) W(:,KCb)
c$$$      write(IFPl, *) W(:,KDa)
      do jz = NXa - 2, 1, -1
 101     format('AGUgph: bad z detected: ', I7, 1x, 3E16.8)
         if (W(jz,KPa).eq.0.0d0 .and. W(jz,KDa).le.0.0d0) then
            jzspa = jz
            write(IFPl, 101) jzspa,
     $           W(jzspa,KPa), W(jzspa+1,KPa), W(jz,KDa)
            goto 110
         endif
      enddo
 110  continue
      if (jzspa.gt.0) then
         do jz = NXb, 1, -1
            if (W(jz,KPb).gt.W(jzspa,KPa)
     $           .and.W(jz,KPb).lt.W(jzspa+1,KPa)) then
               jzspb = jz
 121           format('AGUgph: zb ', I7, 1x, 2E16.8)
               write(IFPl, 121) jzspb, W(jzspb,KPb),W(jzspb,KCb)
            goto 130
         endif
         enddo
 130     continue
         if (jzspb.eq.0) then
            iErr = -1
 122        format('AGUgph: PANIC ', 2I7)
            write(IFPl, 122) icXa, icXb
            write(IFPl, *) W(:,KPa)
            write(IFPl, *) W(:,KPb)
            write(IFPl, *) W(:,KDa)
         endif
      endif
      if (jzspb.gt.0) then
 141     format('AGUgph: modify ', A, 1x, I5, 1x, 2E16.8)
CCC_   . D1:a
C        dZ/dP = Zphys/Zlogi
         jv = KDa
         V = W(jzspb,KPb) / W(jzspb,KCb)
         do jz = jzspa, 1, -1
            write(IFPl, 141) 'D1', jz, V, W(jz,jv)
            W(jz,jv) = V
         enddo
         call ACCupD (iErr, jcdmy, W(1,jv), icXa, NXa, 'D1', IFPl)
CCC_   . D1:b
         jv = KW
         call ACCrfD (iErr, jcdmy, W(1,jv), icXb, -1, 'D1', IFPl)
         do jz = jzspb - 1, 1, -1
            write(IFPl, 141) 'D1', jz, V, W(jz,jv)
            W(jz,jv) = V
         enddo
         call ACCupD (iErr, jcdmy, W(1,jv), icXb, NXb, 'D1', IFPl)
CCC_   . CP:a
         jv = KPa
         VD = W(jzspb,KPb) * 2.0d0
         do jz = jzspa - 1, 1, -1
            V = VD * dble(jz - jzspa)
            write(IFPl, 141) 'CP', jz, V, W(jz,jv)
            W(jz,jv) = V
         enddo
         call ACCupD (iErr, jcdmy, W(1,jv), icXa, NXa, 'CP', IFPl)
CCC_   . CP:b
         jv = KPb
         VD = W(jzspb,KPb)
         do jz = jzspb - 1, 1, -1
            V = VD * dble(2 * (jz - jzspb) + 1)
            write(IFPl, 141) 'CP', jz, V, W(jz,jv)
            W(jz,jv) = V
         enddo
         call ACCupD (iErr, jcdmy, W(1,jv), icXb, NXb, 'CP', IFPl)
CCC_   . D2:a
         jv = KW
         call ACCrfD (iErr, jcdmy, W(1, jv), icXa, -1, 'D2', IFPl)
         V = 0.0d0
         do jz = jzspa, 1, -1
            write(IFPl, 141) 'D2', jz, V, W(jz,jv)
            W(jz,jv) = V
         enddo
         call ACCupD (iErr, jcdmy, W(1, jv), icXa, NXa, 'D2', IFPl)
CCC_   . D2:b
         jv = KW
         call ACCrfD (iErr, jcdmy, W(1, jv), icXb, -1, 'D2', IFPl)
         V = 0.0d0
         do jz = jzspb - 1, 1, -1
            write(IFPl, 141) 'D2', jz, V, W(jz,jv)
            W(jz,jv) = V
         enddo
         call ACCupD (iErr, jcdmy, W(1, jv), icXb, NXb, 'D2', IFPl)
      endif
c
      RETURN
      END
CCC_ & AGUxda  ## generation/equal dx array
      subroutine AGUxda
     O    (X,
     I     NX, DX, X0, JO)
      implicit none
      _INTENT(IN, integer)   NX
      _INTENT(OUT,_REALSTD)  X  (NX)
      _INTENT(IN, _REALSTD)  DX (NX)
      _INTENT(IN, _REALSTD)  X0
      _INTENT(IN, integer)   JO
      integer j
      X (1) = X0
      do j = 2, NX
         X (j) = X (j - 1) + DX (j + JO)
      enddo
      RETURN
      END
CCC_ & AGUxen  ## generation/equal dx (n0)
      subroutine AGUxen
     O    (X,
     I     NX, DX, N0)
      implicit none
      _INTENT(IN, integer)   NX
      _INTENT(OUT,_REALSTD)  X (NX)
      _INTENT(IN, _REALSTD)  DX
      _INTENT(IN, integer)   N0
      _REALSTD X0
      X0 = DX * DBLE (1 - N0)
      call AGUxeX (X, NX, DX, X0)
      RETURN
      END
CCC_ & AGUxex  ## generation/equal dx (x0)
      subroutine AGUxex
     O    (X,
     I     NX, DX, X0)
      implicit none
      _INTENT(IN, integer)   NX
      _INTENT(OUT,_REALSTD)  X (NX)
      _INTENT(IN, _REALSTD)  DX
      _INTENT(IN, _REALSTD)  X0
      integer j
      DO j = 0, NX - 1
         X (j + 1) = X0 + DX * DBLE (j)
      ENDDO
      RETURN
      END
CCC_ & AGUglm  ## Geometry (levels) configuration (main)
      subroutine AGUglm
     O    (iErr,
     W     W,
     I     LX,
     I     NLVa, CF,   NTB,
     I     icXa, icXb, CROOT, Tag, IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   LX
      _INTENT(OUT,_REALSTD)  W (LX, *)
      _INTENT(IN, integer)   icXa, icXb
      _INTENT(IN, integer)   NTB
      _INTENT(IN, integer)   NLVa   (NTB)
      _INTENT(IN, _REALSTD)  CF  (2, NTB)
      _INTENT(IN, character) CROOT*(*), Tag*(*)
      _INTENT(IN, integer)   IFPl
      integer   Na, Nb
      integer   jt
      integer   jz, jzcum
      integer   jcdmy
      integer   IZB, IZT
      integer   IV (2)
      integer   Mdim
      integer   NLP
      _REALSTD  Zcum, Zdnm
      integer   KXa,  KXb
      integer   KV1,  KV2
CCC_  - Body
      iErr = 0
c
      KXa  = 1
      KXb  = 2
      KV1  = 3
      KV2  = 4
c
      if (iErr.eq.0) call ACWdim (iErr, Na, icXa)
      if (iErr.eq.0) call ACWdim (iErr, Nb, icXb)
c
      IZB = 0
      IZT = 0
      if (iErr.eq.0) then
         Mdim = 2
         call ACCrfI (iErr, jcdmy, IV, icXa, Mdim, 'XT', IFPl)
         if (iErr.eq.0) then
            IZB = IV (1)
            IZT = IV (2)
         else
 201        format ('AGUGLM: clear error ', 2I5)
            if      (COND_N(IFPl)) then
               write (IFPl, 201) icXa, icXb
            else if (COND_S(IFPl)) then
               write (*,    201) icXa, icXb
            endif
            iErr = 0
         endif
      endif
CCC_  - set Xa times denominator
 301  format ('ZCHK', 2I4, 1x, 2E24.16)
 302  format ('ZCHK LOOP', 2I4, 1x, 2E24.16)
      jzcum = 0
      Zcum  = 0.0d0
      Zdnm  = CF (2, 1)
      do jt = 1, NTB
         write (*, 302) jt, jzcum, Zcum
         if (NLVa (jt).ge.0) then
            NLP = NLVa (jt)
         else
            NLP = Na - jzcum
         endif
         if (jzcum.lt.IZB) then
            do jz = 1, IZB
               W (jz, KXa) = CF (1, jt) * DBLE (jz - IZB - 1)
            enddo
            jzcum = IZB
         endif
         do jz = 1, NLP
            W (jzcum + jz, KXa) =
     $           (ZCUM + CF (1, jt) * DBLE (jz - 1))
         enddo
         jzcum = jzcum + NLVa (jt) - 1
         Zcum  = Zcum + CF (1, jt) * DBLE (NLP - 1)
      enddo
CCC_  - Xb times denominator
      do jz = 1, Nb
         W (jz, KXb) = (W (jz + 1, KXa) + W (jz, KXa)) * 0.5d0
      enddo
CCC_  - check X[ab]
      do jz = 1, Na
         write (*, 301) jz, jz - IZB, W (jz, KXa), W (jz, KXb)
      enddo
CCC_  - CO:a
      do jz = 1, Na
         W (jz, KV1) = W (jz, KXa) / ZDNM
      enddo
      call ACCrgD (iErr, jcdmy, W (1, KV1),  icXa, Na,  'CO', IFPl)
      call ACCrgD (iErr, jcdmy, W (1, KV1),  icXa, Na,  'CP', IFPl)
CCC_  - CO:b
      do jz = 1, Na
         W (jz, KV1) = W (jz, KXb) / ZDNM
      enddo
      call ACCrgD (iErr, jcdmy, W (1, KV1),  icXb, Nb,  'CO', IFPl)
      call ACCrgD (iErr, jcdmy, W (1, KV1),  icXb, Nb,  'CP', IFPl)
CCC_  - DP:a
      do jz = 2, Na - 1
         W (jz, KV1) = (W (jz, KXb) - W (jz - 1, KXb)) / ZDNM
      enddo
      W (1,  KV1) = W (2,      KV1)
      W (Na, KV1) = W (Na - 1, KV1)
      call ACCrgD (iErr, jcdmy, W (1, KV1),  icXa, Na,  'DC', IFPl)
      call ACCrgD (iErr, jcdmy, W (1, KV1),  icXa, Na,  'DP', IFPl)
CCC_  - DX:b
      W (1, KV2) = 0.0d0
      do jz = 2, Nb
         W (jz, KV2) = +ZDNM / (W (jz, KXb) - W (jz - 1, KXb))
      enddo
      call ACCrgD (iErr, jcdmy, W (1, KV2), icXb, Nb,  'DA', IFPl)
      do jz = 2, Nb
         W (jz, KV2) = -ZDNM / (W (jz, KXb) - W (jz - 1, KXb))
      enddo
      call ACCrgD (iErr, jcdmy, W (1, KV2), icXb, Nb,  'DB', IFPl)
CCC_  - L:b
      W (1, KV2) = 0.0d0
      do jz = 2, Nb
         W (jz, KV1) = W (jz, KXb) - W (jz - 1, KXb)
      enddo
      do jz = 2, Nb
         W (jz, KV2) = (W (jz, KXa) - W (jz - 1, KXb)) / W (jz, KV1)
      enddo
      call ACCrgD (iErr, jcdmy, W (1, KV2), icXb, Nb,  'LA', IFPl)
      do jz = 2, Nb
         W (jz, KV2) = (W (jz, KXb) - W (jz, KXa)) / W (jz, KV1)
      enddo
      call ACCrgD (iErr, jcdmy, W (1, KV2), icXb, Nb,  'LB', IFPl)
CCC_  - DP:b
      do jz = 1, Nb
         W (jz, KV1) = (W (jz + 1, KXa) - W (jz, KXa)) / ZDNM
      enddo
      call ACCrgD (iErr, jcdmy, W (1, KV1),  icXb, Nb,  'DC', IFPl)
      call ACCrgD (iErr, jcdmy, W (1, KV1),  icXb, Nb,  'DP', IFPl)
CCC_  - DX:a
      W (Na, KV2) = 0.0d0
      do jz = 1, Na - 1
         W (jz, KV2) = -ZDNM / (W (jz + 1, KXa) - W (jz, KXa))
      enddo
      call ACCrgD (iErr, jcdmy, W (1, KV2), icXa, Na,  'DA', IFPl)
      do jz = 1, Na - 1
         W (jz, KV2) = +ZDNM / (W (jz + 1, KXa) - W (jz, KXa))
      enddo
      call ACCrgD (iErr, jcdmy, W (1, KV2), icXa, Na,  'DB', IFPl)
CCC_  - L:a
      W (Na, KV2) = 0.0d0
      do jz = 1, Na - 1
         W (jz, KV1) = W (jz + 1, KXa) - W (jz, KXa)
      enddo
      do jz = 1, Na - 1
         W (jz, KV2) = (W (jz + 1, KXa) - W (jz, KXb)) / W (jz, KV1)
      enddo
      call ACCrgD (iErr, jcdmy, W (1, KV2), icXa, Na,  'LA', IFPl)
      do jz = 1, Na - 1
         W (jz, KV2) = (W (jz, KXb) - W (jz, KXa)) / W (jz, KV1)
      enddo
      call ACCrgD (iErr, jcdmy, W (1, KV2), icXa, Na,  'LB', IFPl)
CCC_  - D1 == 1
      do jz = 1, Max (Na, Nb)
         W (jz, KV1) = 1.0d0
      enddo
      call ACCrgD (iErr, jcdmy, W (1, KV1), icXa, Na,  'D1', IFPl)
      call ACCrgD (iErr, jcdmy, W (1, KV1), icXb, Nb,  'D1', IFPl)
CCC_  - D2 == 0
      do jz = 1, Max (Na, Nb)
         W (jz, KV1) = 0.0d0
      enddo
      call ACCrgD (iErr, jcdmy, W (1, KV1), icXa, Na,  'D2', IFPl)
      call ACCrgD (iErr, jcdmy, W (1, KV1), icXb, Nb,  'D2', IFPl)
CCC_  - CT update
      if (iErr.eq.0) then
         Mdim      = 1
         IV (Mdim) = _GCARTESIAN
         call ACCrgI (iErr, jcdmy, IV, icXa, 1, 'CT', IFPl)
         call ACCrgI (iErr, jcdmy, IV, icXb, 1, 'CT', IFPl)
      endif
CCC_  - log
 101  format ('AGUGLM:', A, ':', A, ':', 2I3, 1x, I3, 1x, 2E16.8)
      do jt = 1, NTB
         if      (COND_N(IFPl)) then
            write (IFPl, 101)
     $           _TRIM(CROOT), _TRIM(Tag), jt, NTB, NLVa (jt),
     $           CF (1, jt), CF (2, jt)
         else if (COND_S(IFPl)) then
            write (*,    101)
     $           _TRIM(CROOT), _TRIM(Tag), jt, NTB, NLVa (jt),
     $           CF (1, jt), CF (2, jt)
         endif
      enddo
      call DATrcU (IFPl, iErr, CROOT, 'AGUGLM')
c
      RETURN
      END
CCC_ & AGUgls  ## Geometry (levels) configuration (sub)
      subroutine AGUgls
     O    (iErr,
     W     W,
     I     LX,
     I     icXa, icXb, IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   LX
      _INTENT(OUT,_REALSTD)  W (LX, *)
      _INTENT(IN, integer)   icXa, icXb
      _INTENT(IN, integer)   IFPl
      integer jcdmy
      integer Na, Nb
CCC_  - Body
      iErr = 0
c
      if (iErr.eq.0) call ACWdim (iErr, Na, icXa)
      if (iErr.eq.0) call ACWdim (iErr, Nb, icXb)
c
      call ACCrfD (iErr, jcdmy, W (1, 1), icXa, -1, 'CP', IFPl)
      call ACCrfD (iErr, jcdmy, W (1, 1), icXb, -1, 'CP', IFPl)
c
      RETURN
      END
CCC_& AGMTRY  ## Arpeggio/Geometry announcement
      subroutine AGMTRY (STRA, STRB, IOP)
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
CCC_* TEST
CCC_ @ AGTEST  ## AGMTRY test program driver
#if TEST_AGMTRY
#ifndef   TEST_AGMTRY_SUB
#  define TEST_AGMTRY_SUB 1
#endif
#include "ofnstd.h"
      program AGTEST
CCC_  - Test suites
CC::   SOURCES acorms.F
CC::   KINDS   1 2
CCC_  - Declaration
      implicit none
      integer    iErr
      integer    ipA (LOG_CHANNEL_MAX)
      integer    ipL
CCC_   . Unit
      integer    LKU, LSU, LAU
      parameter (LKU = 1024)
      parameter (LSU = 1024)
      parameter (LAU = 256)
      integer    KU(LKU)
      character  AU(LAU)*(OPT_UNIT_LEN)
      _REALSTD   SU(LSU)
CCC_  - Body
      iErr  = 0
c
      call DDsmpl (iErr)
      if (iErr.ne.0) then
         call DevFin (iErr)
         stop
      endif
c
      call DLCmng (ipA, 't')
c
      ipL  = FPC(ipA)
c
      call UXinit
     $    (iErr,
     $     KU, SU, AU, LKU, LSU, LAU, 0, 0, 0, 0,
     $     ipL)
      call UXSrep (iErr, KU,SU,AU)
c
#if TEST_AGMTRY == 1
      call AGTEST_internal (iErr, ipA)
#else
      call AGTEST_runtime  (iErr, ipA)
#endif
c
      call ACCrep (ipL, 2)
      call UDTbnr ('@@FINE', ipL)
      call DevFin (iErr)
      STOP
      END
CCC_ & AGTEST_internal  ## test variation (internal only)
      subroutine AGTEST_internal (iErr, ipA)
      implicit none
CCC_  - Declaration
      _INTENT(OUT,integer) iErr
      _INTENT(IN, integer) ipA (*)
c
      integer    MTP
      parameter (MTP = 32)
      integer    NT
      integer    IPW (MTP)
      _REALSTD   CF  (2, MTP)
      integer    IZB, IZT
      integer    KGMdef
c
      _REALSTD   vCX, XW, WXN
c
      integer    LW
      parameter (LW = 1024)
      _REALSTD   W (LW)
      integer    NX, NY, NZ
      character  CR*(32), CK*(32)
      integer    icXa, icXb
c
      integer    ipL, ipC, ipP
c
      integer    icZa, icZb, icBa, icBb
c
      integer    ITEST
CCC_  - Body
      iErr  = 0
      ITEST = 0
      ipL  = FPC(ipA)
      ipC  = FPC(ipA)
      ipP  = FPP(ipA)
c
      call UDTbni (ITEST, 'BEGIN', ' ', ipL)
CCC_   . 2d
CCC_    * coordinate registration
      call UDTbni (ITEST, 'COOR1', ' ', ipL)
      CR = 'ID'
      CK = 'X'
      NX = 11
      call AGTEST_coor
     $     (iErr, icXa, icXb, NX, ipL)
CCC_    * geometry
      call UDTbni (ITEST, 'HNMR', ' ', ipL)
      XW  = DBLE (NX - 1) * 10.0d0
      WXN = -1.0d0
      vCX = 0.5d0
c
      call AGHnmr
     O    (iErr,
     W     W,    LW,
     I     vCX,  XW,   WXN,
     I     CR,   CK,   icXa, icXb,
     I     ipP,  ipC,  ipL)
CCC_    * another geometry
      call UDTbni (ITEST, 'COOR2', ' ', ipL)
      CR = 'IXX'
      CK = 'Y'
      NY = 7
CCC_    * geometry
      call UDTbni (ITEST, 'HNMZ', ' ', ipL)
      call AGTEST_coor
     $     (iErr, icXa, icXb, NX, ipL)
      call AGHnmz
     O    (iErr,
     W     W,    LW,
     I     CR,   CK,  icXa, icXb,
     I     ipP,  ipC, ipL)
CCC_   . 1d
      call UDTbni (ITEST, 'COOR1D', ' ', ipL)
c$$$      NZ = 9
      NZ = 33
      NT = 2
c$$$      NT = 1
      CF  (1,1) = 1.0d0
      CF  (2,1) = 0.0d0
      CF  (1,2) = 3.0d0
      CF  (2,2) = 0.0d0
      IPW (1) = 1
      IPW (2) = 4
c
      CF  (1,1) = -1.0d0
      CF  (2,1) =  0.0d0
      CF  (1,2) =  4.0d0
      CF  (2,2) = -2.0d0
      IPW (1) = 0
      IPW (2) = -2
c
      IZB = 1
      IZT = 2
c$$$      IZB = 0
c$$$      IZT = 0
c$$$      IZT = 1
c$$$      IZT = 2
c$$$      IZT = 4
c
      call ACCrgX (iErr, icBa,  0,    0,  ' ', ipL)
      call ACCrgX (iErr, icZa,  icBa, 0,  ' ', ipL)
      call ACCrgX (iErr, icBb,  0,    0,  ' ', ipL)
      call ACCrgX (iErr, icZb,  icBb, 0,  ' ', ipL)
      call ACZreg
     O    (iErr,
     I     icZa,  icZb, NZ, IZB,  IZT, ipL)
c$$$#define TEST_NODEF 1
#if TEST_NODEF
      call AGZnmz
     O    (iErr,
     W     W,     LW,
     I     CR,    icZa, icZb,  ipP,   ipC,  ipL)
#else
      KGMdef = _GEOMETRY_LINEAR
      call AGZnmc
     O    (iErr,
     W     W,      LW,
     I     KGMdef, IPW,   CF,    NT,
     I     CR,     icZa, icZb,  ipP,   ipC,  ipL)
#endif
CCC_   . End
      call UDTbni (ITEST, 'END', ' ', ipL)
      RETURN
      END
CCC_ & AGTEST_runtime   ## test variation (run-time definition)
      subroutine AGTEST_runtime (iErr, ipA)
      implicit none
CCC_  - Declaration
      _INTENT(OUT,integer) iErr
      _INTENT(IN, integer) ipA (*)
c
      integer ipL, ipC, ipP
c
      integer icXa, icXb
      integer icYa, icYb
      integer icZa, icZb, icBa, icBb
c
      character CROOT*(32), CKIND*(32)
      integer           NX, NY, NZ
      namelist /NITEST/ NX, NY, NZ
c
      integer  IZB, IZT, LZ, NZdef
c
      integer    LW
      parameter (LW = 1024)
      _REALSTD   W (LW)
c
      integer   ITEST
CCC_  - Body
      iErr  = 0
      ITEST = 0
c
      ipL   = FPC(ipA)
      ipC   = FPC(ipA)
      ipP   = FPP(ipA)
c
      call UDTbni (ITEST, 'BEGIN', ' ', ipL)
CCC_   . configuration
      NX    = 11
      NY    = 5
      NZ    = 6
      CROOT = 'ID'
      call UUrwnd (iErr, ipP)
      read  (ipP, NITEST, IOSTAT = iErr)
      write (ipC, NITEST, IOSTAT = iErr)
CCC_   . coordinate (x)
      CKIND = 'X'
      call UDTbni (ITEST, 'COORX', ' ', ipL)
      call AGTEST_coor (iErr, icXa, icXb, NX, ipL)
      call AGHnmz
     O    (iErr,
     W     W,     LW,
     I     CROOT, CKIND, icXa, icXb,
     I     ipP,   ipC,   ipL)
CCC_   . coordinate (y)
      CKIND = 'Y'
      call UDTbni (ITEST, 'COORY', ' ', ipL)
      call AGTEST_coor (iErr, icYa, icYb, NY, ipL)
      call AGHnmz
     O    (iErr,
     W     W,     LW,
     I     CROOT, CKIND, icYa, icYb,
     I     ipP,   ipC,   ipL)
CCC_   . coordinate (z)
      call UDTbni (ITEST, 'AGZ', ' ', ipL)
      NZdef = NZ
      call ACZdcl
     O    (iErr,
     O     NZ,    LZ,
     I     NZdef, CROOT, ipP, ipC, ipL)
      IZB = 1
      IZT = 2
c
      call ACCrgX (iErr, icBa,  0,    0,  ' ',  ipL)
      call ACCrgX (iErr, icZa,  icBa, 0,  'Za', ipL)
      call ACCrgX (iErr, icBb,  0,    0,  ' ',  ipL)
      call ACCrgX (iErr, icZb,  icBb, 0,  'Zb', ipL)
      call ACZreg
     O    (iErr,
     I     icZa,  icZb, NZ, IZB,  IZT, ipL)
CCC_   . geometry (z)
      call AGZnmz
     O    (iErr,
     W     W,     LW,
     I     CROOT, icZa, icZb,  ipP,   ipC,  ipL)
CCC_   . end
      call UDTbni (ITEST, 'END', ' ', ipL)
      RETURN
      END
#endif /* TEST_AGMTRY */
CCC_* [TEST/SUB] also used in other tests
#if TEST_AGMTRY_SUB
CCC_ & AGTEST_coor
      subroutine AGTEST_coor
     O    (iErr,
     O     icXa, icXb,
     I     NX,   ipL)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   icXa, icXb
      _INTENT(IN, integer)   NX
      _INTENT(IN, integer)   ipL
      integer   icN
c
      iErr  = 0
      if (iErr.eq.0) call ACCrgN (iErr, icN, NX, ipL)
      if (iErr.eq.0) call ACCrgX (iErr, icXa, icN, -1, ' ', ipL)
      iErr  = MIN (0, iErr)
      if (iErr.eq.0) call ACCrgX (iErr, icXb, icN, -1, ' ', ipL)
      iErr  = MIN (0, iErr)
      RETURN
      END
CCC_ + TEST/SUB end
#endif /* TEST_AGMTRY_SUB */
CCC_* obsolete
CCC_ + begin
#if 0  /* obsolete */
CCC_ + end
#endif /* 0 obsolete */
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
