C development/doptms.F --- IcIES/Development/Option manipulation
C Maintainer:  SAITO Fuyuki
C Created: Nov 18 2019
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2020/09/17 08:43:08 fuyuki doptms.F>'
#define _FNAME 'development/doptms.F'
#define _REV   'Snoopy0.97'
CCC_! MANIFESTO
C
C Copyright (C) 2019, 2020
C           Japan Agency for Marine-Earth Science and Technology
C
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
CCC_* Macros
#include "ofdlct.h" /* fortran dialect */
#include "ologfm.h" /* logging */
#include "ounelv.h"

#include "odopts.h"
CCC_ + Options
#ifndef    OPT_NAMELIST_OUTPUT_EMULATION
#  define  OPT_NAMELIST_OUTPUT_EMULATION _UNMLEM_LEVEL_END
#endif
CCC_ + Lengths
#ifndef   OPT_DOPTMS_PARAM_LEN
#  define OPT_DOPTMS_PARAM_LEN 32
#endif
#ifndef   OPT_DOPTMS_TAG_LEN
#  define OPT_DOPTMS_TAG_LEN   32
#endif
#ifndef   OPT_DOPTMS_ROOT_LEN
#  define OPT_DOPTMS_ROOT_LEN  32
#endif
#ifndef   OPT_DOPTMS_VALUE_LEN
#  define OPT_DOPTMS_VALUE_LEN 256
#endif
#ifndef   OPT_DOPTMS_UNIT_LEN
#  define OPT_DOPTMS_UNIT_LEN  128
#endif
#ifndef   OPT_DOPTMS_STAT_LEN
#  define OPT_DOPTMS_STAT_LEN  32
#endif
#ifndef   OPT_DOPTMS_DESC_LEN
#  define OPT_DOPTMS_DESC_LEN  512
#endif
CCC_* Interfaces
CCC_ & DOgetI  ## Integer
      subroutine DOgetI
     O    (iErr,
     O     iVal,
     I     iDef, Param, Desc,
     I     CR,   Tag,   ipP,  ipC, ipL, KSW)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   iVal
      _INTENT(IN, integer)   iDef
      _INTENT(IN, character) CR*(*)
      _INTENT(IN, character) Tag*(*)
      _INTENT(IN, character) Param*(*)
      _INTENT(IN, character) Desc*(*)
      _INTENT(IN, integer)   ipP, ipC, ipL
      _INTENT(IN, integer)   KSW

      character V*(OPT_DOPTMS_VALUE_LEN)
      character U*(OPT_DOPTMS_UNIT_LEN)
      character C*(OPT_DOPTMS_ROOT_LEN)
      character T*(OPT_DOPTMS_TAG_LEN)
      character P*(OPT_DOPTMS_PARAM_LEN)
CCC_  - Body
      iErr = 0
      call USGlni(V, iDef)
      C = CR
      T = Tag
      P = Param
      U = ' '
      call DOgtry(iErr, V, U, C, T, P, Desc, ipP, ipC, ipL, KSW)
      if (iErr.eq.0) call USPsni(iErr, iVal, V)
      if (iErr.ne.0) iVal = iDef
      return
      end
CCC_ & DOgetS  ## Real standard
      subroutine DOgetS
     O    (iErr,
     O     rVal,
     I     uSys, rDef, uDef, Param, Desc,
     I     CR,   Tag,  ipP,  ipC,   ipL, KSW)
CCC_  - Description
CC      uSys:       target internal unit to convert
CC      rDef uDef:  default source value/unit for user
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,_REALSTD)  rVal
      _INTENT(IN, _REALSTD)  rDef
      _INTENT(IN, character) uSys*(*)
      _INTENT(IN, character) uDef*(*)
      _INTENT(IN, character) CR*(*)
      _INTENT(IN, character) Tag*(*)
      _INTENT(IN, character) Param*(*)
      _INTENT(IN, character) Desc*(*)
      _INTENT(IN, integer)   ipP, ipC, ipL
      _INTENT(IN, integer)   KSW

      character V*(OPT_DOPTMS_VALUE_LEN)
      character U*(OPT_DOPTMS_UNIT_LEN)
      character C*(OPT_DOPTMS_ROOT_LEN)
      character T*(OPT_DOPTMS_TAG_LEN)
      character P*(OPT_DOPTMS_PARAM_LEN)
CCC_  - Body
      iErr = 0
      call USGlfs(V, rDef, ' ')
      C = CR
      T = Tag
      P = Param
      U = uDef
      if (U.eq.' ') U = uSys
      call DOgtry(iErr, V, U, C, T, P, Desc, ipP, ipC, ipL, KSW)
      if (iErr.eq.0) call USPsns(iErr, rVal, V)
      return
      end
CCC_ & DOgetA  ## String
      subroutine DOgetA
     O    (iErr,
     O     Val,
     I     Def, Param, Desc,
     I     CR,  Tag,   ipP,  ipC, ipL, KSW)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,character) Val*(*)
      _INTENT(IN, character) Def*(*)
      _INTENT(IN, character) CR*(*)
      _INTENT(IN, character) Tag*(*)
      _INTENT(IN, character) Param*(*)
      _INTENT(IN, character) Desc*(*)
      _INTENT(IN, integer)   ipP, ipC, ipL
      _INTENT(IN, integer)   KSW

      character V*(OPT_DOPTMS_VALUE_LEN)
      character U*(OPT_DOPTMS_UNIT_LEN)
      character C*(OPT_DOPTMS_ROOT_LEN)
      character T*(OPT_DOPTMS_TAG_LEN)
      character P*(OPT_DOPTMS_PARAM_LEN)
CCC_  - Body
      iErr = 0
      V = Def
      U = ' '
      C = CR
      T = Tag
      P = Param
      call DOgtry(iErr, V, U, C, T, P, Desc, ipP, ipC, ipL, KSW)
      if (iErr.eq.0) then
         Val = V
      else
         Val = Def
      endif
      return
      end
CCC_* Core
CCC_ & DOgtry  ## Development/Option trial loop
      subroutine DOgtry
     O    (iErr,
     M     Val,  Unt,
     M     aCR,  aTag, Param,
     I     Desc, ipP,  ipC,  ipL,   KSW)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,character) Val*(*)
      _INTENT(INOUT,character) Unt*(*)
      _INTENT(INOUT,character) aCR*(*)
      _INTENT(INOUT,character) aTag*(*)
      _INTENT(INOUT,character) Param*(*)
      _INTENT(IN,   character) Desc*(*)
      _INTENT(IN,   integer)   ipP, ipC, ipL
      _INTENT(IN,   integer)   KSW
c
      character C*(OPT_DOPTMS_ROOT_LEN)
      character T*(OPT_DOPTMS_TAG_LEN)

      character dCR*(*), dTag*(*)
      parameter(dCR=' ', dTag=' ')
c
      integer LevB, LevC, LevT, LevN
CCC_  - Body
      iErr = -1
      if (IAND(KSW, DOPTS_LEVEL_MATCH_STRICT)
     $     .eq.DOPTS_LEVEL_MATCH_STRICT) then
         LevB = 1
         LevC = -1
         LevT = -1
         LevN = -1
      else
         if (IAND(KSW, DOPTS_LEVEL_MATCH_TAG)
     $        .eq.DOPTS_LEVEL_MATCH_TAG) then
            LevB = 0
            LevC = -1
            LevT = 1
            LevN = -1
         else if (IAND(KSW, DOPTS_LEVEL_MATCH_ROOT)
     $        .eq.DOPTS_LEVEL_MATCH_ROOT) then
            LevB = 0
            LevC = 1
            LevT = -1
            LevN = -1
         else
            LevB = 0
            LevC = 0
            LevT = 0
            LevN = 1
         endif
      endif
CCC_   . ArgR ArgT
      if (iErr.ne.0) then
         call UUrwnd(iErr, ipP)
         C = aCR
         T = aTag
         call DOcore
     $        (iErr, Val, Unt, C, T, Param, Desc, LevB, ipP, ipC, ipL)
      endif
CCC_   . ArgR DefT
      if (iErr.ne.0.and.LevC.ge.0) then
         call UUrwnd(iErr, ipP)
         C = aCR
         T = dTag
         call DOcore
     $        (iErr, Val, Unt, C, T, Param, Desc, LevC, ipP, ipC, ipL)
      endif
CCC_   . DefR ArgT
      if (iErr.ne.0.and.LevT.ge.0) then
         call UUrwnd(iErr, ipP)
         C = dCR
         T = aTag
         call DOcore
     $        (iErr, Val, Unt, C, T, Param, Desc, LevT, ipP, ipC, ipL)
      endif
CCC_   . DefR DefT
      if (iErr.ne.0.and.LevN.ge.0) then
         call UUrwnd(iErr, ipP)
         C = dCR
         T = dTag
         call DOcore
     $        (iErr, Val, Unt, C, T, Param, Desc, LevN, ipP, ipC, ipL)
      endif
CCC_   . fine
      if (iErr.eq.0) then
         aCR  = C
         aTag = T
      else if (IAND(KSW, DOPTS_LEVEL_ALLOW_NULL)
     $        .eq. DOPTS_LEVEL_ALLOW_NULL) then
         iErr = 0
      endif
      return
      end
CCC_ & DOcore  ## Development/Option core
      subroutine DOcore
     O    (iErr,
     M     Val,  Unt,
     M     CR,   Tag,  Param,
     I     Desc, LevV, ipP,   ipC, ipL)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,character) Val*(*)
      _INTENT(INOUT,character) Unt*(*)
      _INTENT(INOUT,character) CR*(*)
      _INTENT(INOUT,character) Tag*(*)
      _INTENT(INOUT,character) Param*(*)
      _INTENT(IN,   character) Desc*(*)
      _INTENT(IN,   integer)   LevV
      _INTENT(IN,   integer)   ipP, ipC, ipL
c
      integer    LVEML
      parameter (LVEML=OPT_NAMELIST_OUTPUT_EMULATION)
      character C*(OPT_DOPTMS_ROOT_LEN)
      character T*(OPT_DOPTMS_TAG_LEN)
      character P*(OPT_DOPTMS_PARAM_LEN)
      character V*(OPT_DOPTMS_VALUE_LEN)
      character U*(OPT_DOPTMS_UNIT_LEN)
      character S*(OPT_DOPTMS_STAT_LEN)
      character D*(OPT_DOPTMS_DESC_LEN)
      character X*(OPT_DOPTMS_DESC_LEN)
      namelist /NIOPTS/
     $     C, T, P, V, U, S, D, X
CCC_   . variables notes
CC      C: Root id
CC      T: Tag
CC      P: Parameter name
CC      V: Value
CC      U: Unit
CC      S: Status (run-time, by system)
CC      D: Description (build-time, by developer)
CC      X: Comment (run-time, by user)
      character WC*(*)
      parameter(WC='*')
      character CU*(OPT_DOPTMS_ROOT_LEN)
      character TU*(OPT_DOPTMS_TAG_LEN)
      character PU*(OPT_DOPTMS_PARAM_LEN)
c
      integer jedmy
CCC_  - Body
      iErr = 0
      CU = CR
      TU = Tag
      PU = Param
      call USMupc(CU)
      call USMupc(TU)
      call USMupc(PU)
c$$$ 101  format('Q:  ', A, ':', A, ':', A)
c$$$ 102  format('   R: ', A, ':', A, ':', A)
c$$$      write(*, 101) trim(CU), trim(TU), trim(PU)
      DO
         C = ' '
         T = ' '
         P = ' '
         V = Val
         U = Unt
         S = ' '
         D = ' '
         X = ' '
         if (ipP.ge.0) then
            read(ipP, NIOPTS, IOSTAT=iErr)
         else if (ipP.eq.-1) then
            read(*,   NIOPTS, IOSTAT=iErr)
         else
            goto 100
         endif
         if (iErr.ne.0) goto 100
         call USMupc(C)
         call USMupc(T)
         call USMupc(P)
c$$$         write(*, 102) trim(C), trim(T), trim(P)
         if       (CU.eq.WC .or.CU.eq.C) then
            if    (TU.eq.WC .or.TU.eq.T) then
               if (PU.eq.WC .or.PU.eq.P) then
                  goto 100
               endif
            endif
         endif
      ENDDO
 100  continue
      if (iErr.eq.0) then
         Val   = V
         Unt   = U
         CR    = C
         Tag   = T
         Param = P
         S     = 'SET'
      else
         S     = 'NULL'
      endif
      if (iErr.eq.0 .or. LevV.gt.0) then
         if (LVEML.gt.0) then
            call UNBbgn (jedmy, 'NIOPTS', ipC,   LVEML)
            call UNBstr (jedmy, 'C',      CR,    ipC, LVEML)
            call UNBstr (jedmy, 'T',      Tag,   ipC, LVEML)
            call UNBstr (jedmy, 'P',      Param, ipC, LVEML)
            call UNBstr (jedmy, 'V',      Val,   ipC, LVEML)
            call UNBstr (jedmy, 'U',      Unt,   ipC, LVEML)
            call UNBstr (jedmy, 'S',      S,     ipC, LVEML)
            if (Desc.ne.' ')
     $           call UNBstr (jedmy, 'D', Desc, ipC, LVEML)
            if (X.ne.' ')
     $           call UNBstr (jedmy, 'X', X,    ipC, LVEML)
            call UNBend (jedmy, 'NIOPTS', ipC,   LVEML)
         else
            if (COND_N(ipC)) then
               write (ipC, NIOPTS)
            else if (COND_S(ipC)) then
               write (*,   NIOPTS)
            endif
         endif
      endif
      RETURN
      END
CCC_& DOPTMS  ## Development/Option announcement
      subroutine DOPTMS (STRA, STRB, IOP)
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
CCC_@ DOtest  ## DoptMs test
#ifdef TEST_DOPTMS
#include "odevel.h"
      program DOTEST
CCC_ + Test suites
CC::   SOURCES dbstrp.F duntms.F
CCC_ + Declaration
      implicit none
      integer   ipI, ipO, ipE
      integer   iErr
      integer NHUS, NHUD, NHUC
CCC_ + Body
      iErr = 0
      call DBIcpy
     O    (iErr, ipI,
     I     -1, ' ', .FALSE.)
c
      ipO = -1
      ipE = -1
      write (*, *) 'BOOTSTRAP', ipI, ipO, ipE
c
      NHUS = 0
      NHUD = 0
      NHUC = 0
      call DUinit(iErr, NHUS, NHUD, NHUC, ipI, ipO, ipE)
c
      call DOTEST_gi(iErr, 'L1', ipI, ipO, ipE)
      call DOTEST_gi(iErr, 'L2', ipI, ipO, ipE)
      call DOTEST_gi(iErr, 'L3', ipI, ipO, ipE)
      call DOTEST_gi(iErr, 'L4', ipI, ipO, ipE)
      call DOTEST_gi(iErr, 'L5', ipI, ipO, ipE)

      call DOTEST_ge(iErr, 'E0', ipI, ipO, ipE)

      call DOTEST_gs(iErr, 'P1', 'm', ipI, ipO, ipE)
      call DOTEST_gs(iErr, 'P2', 'm', ipI, ipO, ipE)
      call DOTEST_gs(iErr, 'P3', 'm', ipI, ipO, ipE)
      call DOTEST_gs(iErr, 'P4', 'm', ipI, ipO, ipE)
      call DOTEST_gs(iErr, 'P5', 'm', ipI, ipO, ipE)

      call DEBrep (ipO)
      call DBswpW (iErr, -1, -1)

      STOP
      END
CCC_ + subroutines
      subroutine DOTEST_gi(iErr, P, ipI, ipO, ipE)
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   ipI, ipO, ipE
      _INTENT(IN, character) P*(*)

      integer idef
      integer iv
      integer KSW

      iErr = 0
      KSW  = 0
      idef = -987

      rewind (unit=ipI, IOSTAT=iErr)
      do ksw = 0, 7
         call DOgetI
     $       (iErr, iv,
     $        idef, P, 'desc', 'C0', 'T0', ipI, ipO, ipE, KSW)
         write(*, *) iErr, KSW, iv
      enddo

      return
      end
      subroutine DOTEST_gs(iErr, P, U, ipI, ipO, ipE)
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   ipI, ipO, ipE
      _INTENT(IN, character) P*(*)
      _INTENT(IN, character) U*(*)

      integer KSW
      _REALSTD rv, rdef

      iErr = 0
      KSW  = 0

      rewind (unit=ipI, IOSTAT=iErr)
      do ksw = 0, 7
         rdef = 1.23d4
         call DOgetS
     $       (iErr, rv,
     $        U,    rDef, ' ', P, 'desc',
     $        'C0', 'T1', ipI, ipO, ipE, KSW)
         write(*, *) iErr, KSW, rv
      enddo

      return
      end
      subroutine DOTEST_ge(iErr, P, ipI, ipO, ipE)
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   ipI, ipO, ipE
      _INTENT(IN, character) P*(*)

      integer idef
      integer iv
      integer KSW

      iErr = 0
      KSW  = 0
      idef = -987

      rewind (unit=ipI, IOSTAT=iErr)
      call DOgetI
     $    (iErr, iv,
     $     idef, P, 'desc', 'C0', 'T0', ipI, ipO, ipE, KSW)
      write(*, *) iErr, KSW, iv

      return
      end
#endif /* TEST_DOPTMS */
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
