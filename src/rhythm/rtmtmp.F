C rhythm/rtmtmp.F --- IcIES/rhythm/tempo
C Maintainer: SAITO Fuyuki
C Created: Nov 16 2019
C Revision:  Snoopy0.97
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2020/09/17 08:50:55 fuyuki rtmtmp.F>'
#define _FNAME 'rhythm/rtmtmp.F'
#define _REV   'Snoopy0.97'
CCC_! MANIFESTO
C
C Copyright (C) 2019, 2020
C           Japan Agency for Marine-Earth Science and Technology,
C           Ayako ABE-OUCHI
C
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
CCC_* Test
CCC_* Common macros
#include "ofdlct.h"   /* fortran dialect */
#include "ofnstd.h"
#include "ologfm.h"
#include "ounelv.h"
CCC_ + Options
#ifndef    OPT_NAMELIST_OUTPUT_EMULATION
#  define  OPT_NAMELIST_OUTPUT_EMULATION _UNMLEM_LEVEL_END
#endif
CCC_* [Configuration]
CCC_ & RTitim  ## Time initialization batch
      subroutine RTitim
     O    (iErr,
     O     TINI,  TEND,  DT,
     I     CR,    Tag,   ipP,   ipC, ipL)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,_REALSTD)  TINI, TEND, DT
      _INTENT(IN, character) CR*(*)
      _INTENT(IN, character) Tag*(*)
      _INTENT(IN, integer)   ipP, ipC, ipL
      character DefCR*(*), DefTag*(*)
      parameter(DefCR=' ', DefTag=' ')
CCC_  - Body
      iErr = 0
      if (iErr.eq.0) then
         TINI  = 0.0d0
         TEND  = 1000.0d0
         DT    = 1.0d0
      endif
CCC_   . default setting
      if (iErr.eq.0) then
         call RTnctm
     O       (iErr,
     M        TINI,  TEND,   DT,
     I        DefCR, DefTag, ipP,   ipC,  ipL)
         if (Tag.ne.DefTag) then
            call RTnctm
     O          (iErr,
     M           TINI,  TEND,  DT,
     I           DefCR, Tag,   ipP,   ipC,  ipL)
         endif
         call DAtrcU (ipL, iErr, '-', 'RTNCTM')
         iErr = 0
      endif
CCC_   . individual setting
      if (iErr.eq.0) then
         call RTnctm
     O       (iErr,
     M        TINI,  TEND,   DT,
     I        CR,    DefTag, ipP,   ipC,  ipL)
         if (Tag.ne.DefTag) then
            call RTnctm
     O          (iErr,
     M           TINI,  TEND,  DT,
     I           CR,    Tag,   ipP,   ipC,  ipL)
         endif
         call DAtrcU (ipL, iErr, CR, 'RTNCTM')
      endif
CCC_   . reset error
      iErr = 0
      RETURN
      END
CCC_ & RTnctm  ## Time initialization by namelist
      subroutine RTnctm
     O    (iErr,
     M     TINI,  TEND,  DT,
     I     CR,    aTag,  ipP,   ipC,  ipL)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,_REALSTD)  TINI, TEND, DT
      _INTENT(IN,   character) CR*(*)
      _INTENT(IN,   character) aTag*(*)
      _INTENT(IN,   integer)   ipP, ipC, ipL
c
      integer    KTM
      character  CROOT*(8)
      character  Tag  *(32)
      namelist /NITIME/
     $     CROOT, Tag,  KTM,
     $     TINI,  TEND, DT
c
      _REALSTD  dTINI, dTEND, dDT
c
      integer    LVEML
      parameter (LVEML=OPT_NAMELIST_OUTPUT_EMULATION)
CCC_  - Body
      iErr = 0
c
      dTINI = TINI
      dTEND = TEND
      dDT   = DT
c
      call UUrwnd (iErr, ipP)
      DO
         KTM   = 0
         CROOT = ' '
         Tag   = ' '
         TINI  = dTINI
         TEND  = dTEND
         DT    = dDT
         if (iErr.eq.0) READ (ipP, NITIME, IOSTAT = iErr)
         if (iErr.eq.0) then
            if (CROOT.eq.CR.and.Tag.eq.aTag) goto 100
         endif
         if (iErr.ne.0) goto 100
      ENDDO
 100  continue
      if (iErr.eq.0) then
         if (LVEML.gt.0) then
            call UNBbgn (iErr, 'NITIME',       ipC, LVEML)
            call UNBstr (iErr, 'CROOT', CR,    ipC, LVEML)
            call UNBstr (iErr, 'TAG',   Tag,   ipC, LVEML)
            call UNBint (iErr, 'KTM',   KTM,   ipC, LVEML)
            call UNBrst (iErr, 'TINI',  TINI,  ipC, LVEML)
            call UNBrst (iErr, 'TEND',  TEND,  ipC, LVEML)
            call UNBrst (iErr, 'DT',    DT,    ipC, LVEML)
            call UNBend (iErr, 'NITIME',       ipC, LVEML)
         else
            CROOT = CR
            Tag   = aTag
            if (COND_N(ipC)) then
               write (ipC, NITIME)
            else if (COND_S(ipC)) then
               write (*,   NITIME)
            endif
         endif
      else
         TINI = dTINI
         TEND = dTEND
         DT   = dDT
      endif
c
      RETURN
      END
CCC_& RTMTMP  ## Rhythm/Tempo announcement
      subroutine RTMTMP (STRA, STRB, IOP)
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
CCC_* Obsolete
CCC_ + begin
#if 0 /* obsolete */
#endif /* 0 obsolete */
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
