C development/danntr.F --- IcIES/Development Announcement/Trace
C Maintainer:  SAITO Fuyuki
C Created: Mar 20 2010
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2020/09/17 08:42:24 fuyuki danntr.F>'
#define _FNAME 'devel/danntr.F'
#define _REV   'Snoopy0.97'
CCC_! MANIFESTO
C
C Copyright (C) 2010--2020
C           Japan Agency for Marine-Earth Science and Technology,
C           Ayako ABE-OUCHI
C
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
CCC_* Naming convention
CC      DA...A   i/o unit array argument (ipL (*))
CC      DA...B   bootstrap unit array (ibs (*)
CC      DA...U   unit (ifp)
CC      DA...N   no unit (0)
CC      DA...C   core
CCC_* Macro definition
#include "ofdlct.h" /* fortran dialect */
#include "ologfm.h" /* logging */
#include "odevel.h"
#include "ofnstd.h"
#include "ounelv.h" /* namelist emulation levels */
c
#ifndef    OPT_NAMELIST_OUTPUT_EMULATION
#  define  OPT_NAMELIST_OUTPUT_EMULATION _UNMLEM_LEVEL_END
#endif
CCC_* [DAC] Health check
CCC_ & DAchmU  ## Array size check [U]
      subroutine DAchmU
     O    (iErr,
     I     M,    L,  CMDL, CTAG, IFP)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   M, L
      _INTENT(IN, character) CMDL*(*), CTAG*(*)
      _INTENT(IN, integer)   IFP
      call DAchmC (iErr, M, L, CMDL, CTAG, IFP)
      RETURN
      END
CCC_ & DAchmC  ## Array size check [C]
      subroutine DAchmC
     O    (iErr,
     I     M,    L,  CMDL, CTAG, IFP)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   M, L
      _INTENT(IN, character) CMDL*(*), CTAG*(*)
      _INTENT(IN, integer)   IFP
CCC_  - Body
      if (M .le. L) then
         iErr = 0
      else
         iErr = -1
      endif
 101  format ('DACHMC:', A, ':', A, 1x, L1, 1x, I3, 1x, 2I9)
      if (COND_N(IFP)) then
         write (IFP, 101)
     $        _TRIM(CMDL), _TRIM(CTAG), (M.le.L), iErr, M, L
      else if (COND_S(IFP)) then
         write (*,   101)
     $        _TRIM(CMDL), _TRIM(CTAG), (M.le.L), iErr, M, L
      endif
      RETURN
      END
CCC_ & DAchfU  ## file report [U]
      subroutine DAchfU
     I     (ipTgt, CTXT, IFP)
CCC_  - Description
CC    Report file name bound to ipTgt
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(IN,integer)   IFP
      _INTENT(IN,integer)   ipTgt
      _INTENT(IN,character) CTXT*(*)
CCC_   = Interior
      character FN*(OPT_FILENAME_MAX)
      integer   IP
      logical   ONMD, OPND
      integer   IOS
      character TXT*(64)
      integer   jerr
      namelist /NICHKI/ FN, IP, TXT, OPND, ONMD
      integer    LVEML
      parameter (LVEML = OPT_NAMELIST_OUTPUT_EMULATION)
CCC_  - Body
      call UUquop (IOS, OPND, ipTgt)
      if (OPND) then
         call UUqunm (IOS, ONMD, FN, ipTgt)
         if (.not.ONMD) FN = '*scratch*'
      else
         ONMD = .false.
         FN = ' '
      endif
      TXT = CTXT
      IP  = ipTgt
      if (LVEML.gt.0) then
         call UNBbgn (jerr, 'NICHKI',     IFP, LVEML)
         call UNBint (jerr, 'IP',   IP,   IFP, LVEML)
         call UNBlog (jErr, 'ONMD', ONMD, IFP, LVEML)
         call UNBlog (jErr, 'OPND', OPND, IFP, LVEML)
         call UNBstr (jerr, 'FN',   FN,   IFP, LVEML)
         call UNBstr (jerr, 'TXT',  TXT,  IFP, LVEML)
         call UNBend (jerr, 'NICHKI',     IFP, LVEML)
      else if (COND_N(IFP)) then
         write (IFP, NICHKI)
      else if (COND_S(IFP)) then
         write (*,   NICHKI)
      endif
      RETURN
      END
CCC_* [DAA] Announcement interfaces
CCC_ & DAAviA  ## Announcement variable integer [A]
      subroutine DAAviA (ipA, CMDL, CVAR, IVAR)
      implicit none
      _INTENT(IN,integer)   ipA (*)
      _INTENT(IN,character) CMDL*(*), CVAR*(*)
      _INTENT(IN,integer)   IVAR
      call DAAviC (FPL(ipA), CMDL, CVAR, IVAR)
      RETURN
      END
CCC_ & DAAvsA  ## Announcement variable string [A]
      subroutine DAAvsA (ipA, CMDL, CVAR, VAR)
      implicit none
      _INTENT(IN,integer)   ipA (*)
      _INTENT(IN,character) CMDL*(*), CVAR*(*)
      _INTENT(IN,character) VAR*(*)
      call DAAvsC (FPL(ipA), CMDL, CVAR, VAR)
      RETURN
      END
CCC_ & DAAviC  ## Announcement variable integer [C]
      subroutine DAAviC (IFP, CMDL, CVAR, IVAR)
CCC_  - Declaration
      implicit none
      _INTENT(IN,integer)   IFP
      _INTENT(IN,character) CMDL*(*), CVAR*(*)
      _INTENT(IN,integer)   IVAR
CCC_  - Body
 101  format ('% ', A, ' [', A, '] ', I7)
      if      (COND_N(IFP)) then
         write (IFP, 101) _TRIM(CMDL), _TRIM(CVAR), IVAR
      else if (COND_S(IFP)) then
         write (*,   101) _TRIM(CMDL), _TRIM(CVAR), IVAR
      endif
      RETURN
      END
CCC_ & DAAvsC  ## Announcement variable string [C]
      subroutine DAAvsC (IFP, CMDL, CVAR, VAR)
CCC_  - Declaration
      implicit none
      _INTENT(IN,integer)   IFP
      _INTENT(IN,character) CMDL*(*), CVAR*(*)
      _INTENT(IN,character) VAR*(*)
CCC_  - Body
 101  format ('% ', A, ' [', A, '] ', A, '//')
      if      (COND_N(IFP)) then
         write (IFP, 101) _TRIM(CMDL), _TRIM(CVAR), _TRIM(VAR)
      else if (COND_S(IFP)) then
         write (*,   101) _TRIM(CMDL), _TRIM(CVAR), _TRIM(VAR)
      endif
      RETURN
      END
CCC_ & DAAbiA  ## Announcement basic info [A]
      subroutine DAAbiA (ipA, I, STRa, STRb)
      implicit none
      _INTENT(IN,integer)   ipA (*)
      _INTENT(IN,integer)   I
      _INTENT(IN,character) STRa*(*), STRb*(*)
      if (I.eq.0) then
         call DAAbiC (FPT(ipA), I, STRa, STRb)
      else if (I.ge.1.and.I.lt.3) then
         call DAAbiC (FPR(ipA), I, STRa, STRb)
      else
         call DAAbiC (FPL(ipA), I, STRa, STRb)
      endif
      RETURN
      END
CCC_ & DAAbiC  ## Announcement basic info [C]
      subroutine DAAbiC (IFP, I, STRa, STRb)
CCC_  - Declaration
      implicit none
      _INTENT(IN,integer)   IFP
      _INTENT(IN,integer)   I
      _INTENT(IN,character) STRa*(*), STRb*(*)
CCC_  - Body
#define CHAR_L '@'
#define CHAR_R '@'
 101  format (CHAR_L, I2.2, 1x, A, ':', A, CHAR_R)
 102  format (CHAR_L, I2.2, 1x, A, CHAR_R)
      if      (COND_N(IFP)) then
         if (STRb.eq.' ') then
            write (IFP, 102) I, _TRIM(STRa)
         else
            write (IFP, 101) I, _TRIM(STRa), _TRIM(STRb)
         endif
      else if (COND_S(IFP)) then
         if (STRb.eq.' ') then
            write (*,   102) I, _TRIM(STRa)
         else
            write (*,   101) I, _TRIM(STRa), _TRIM(STRb)
         endif
      endif
      RETURN
      END
CCC_* [DAB] Banner
CCC_ & DABnrA  ## Banner output [A]
      subroutine DABnrA (ipA, CMSG)
      implicit none
      _INTENT(IN,integer)   ipA  (*)
      _INTENT(IN,character) CMSG*(*)
      call DABnrC (FPL(ipA), CMSG)
      RETURN
      END
CCC_ & DABnrB  ## Banner output [B]
      subroutine DABnrB (ibsA, CMSG)
      implicit none
      _INTENT(IN,integer)   ibsA (*)
      _INTENT(IN,character) CMSG*(*)
      call DABnrC (BOOTSTRAP_ERR(ibsA), CMSG)
      RETURN
      END
CCC_ & DABnrU  ## Banner output [U]
      subroutine DABnrU (ifp, CMSG)
      implicit none
      _INTENT(IN,integer)   IFP
      _INTENT(IN,character) CMSG*(*)
      call DABnrC (IFP, CMSG)
      RETURN
      END
CCC_ & DABnrC  ## Banner output [C]
      subroutine DABnrC (IU, CMSG)
CCC_  - Declaration
      implicit none
      _INTENT(IN,integer)   IU
      _INTENT(IN,character) CMSG*(*)
CCC_   = Interior
#if HAVE_F77_REPEAT == 0
      integer    LHR
      parameter (LHR = 128)
      character HR*(LHR)
      integer   j
#endif
      integer   lmsg
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
CCC_  - Body
      lmsg = len_trim (CMSG)
 101  format (A)
 102  format (1x, A)
#if HAVE_F77_REPEAT
      if      (COND_N(IU)) then
         write (IU, 101) REPEAT ('-', lmsg + 2)
         write (IU, 102) CMSG(1:lmsg)
         write (IU, 101) REPEAT ('-', lmsg + 2)
      else if (COND_S(IU)) then
         write (*,  101) REPEAT ('-', lmsg + 2)
         write (*,  102) CMSG(1:lmsg)
         write (*,  101) REPEAT ('-', lmsg + 2)
      endif
#else /* not HAVE_F77_REPEAT */
      HR = ' '
      do j = 1, min (lmsg + 2, LHR)
         HR (j:j) = '-'
      enddo
      if      (COND_N(IU)) then
         write (IU, 101) HR(1:lmsg + 2)
         write (IU, 102) CMSG(1:lmsg)
         write (IU, 101) HR(1:lmsg + 2)
      else if (COND_S(IU)) then
         write (*,  101) HR(1:lmsg + 2)
         write (*,  102) CMSG(1:lmsg)
         write (*,  101) HR(1:lmsg + 2)
      endif
#endif /* not HAVE_F77_REPEAT */
      RETURN
      END
CCC_* [DAT] Trace
CCC_ & DATrcA  ## Trace return value [A]
      subroutine DATrcA
     I     (ipA, iErr, CK, CMDL)
      implicit none
      _INTENT(IN,integer)   ipA (*)
      _INTENT(IN,integer)   iErr
      _INTENT(IN,character) CK*(*), CMDL*(*)
      call DATrcC (FPD(ipA), iErr, CK, CMDL)
      RETURN
      END
CCC_ & DATrcB  ##  Trace return value [B]
      subroutine DATrcB
     I     (ibsA, iErr, CK, CMDL)
      implicit none
      _INTENT(IN,integer)   ibsA (*)
      _INTENT(IN,integer)   iErr
      _INTENT(IN,character) CK*(*), CMDL*(*)
      call DATrcC (BOOTSTRAP_ERR(ibsA), iErr, CK, CMDL)
      RETURN
      END
CCC_ & DATrcS  ##  Trace return value [U]
      subroutine DATrcU
     I     (IP, iErr, CK, CMDL)
      implicit none
      _INTENT(IN,integer)   IP
      _INTENT(IN,integer)   iErr
      _INTENT(IN,character) CK*(*), CMDL*(*)
      call DATrcC (IP, iErr, CK, CMDL)
      RETURN
      END
CCC_ & DATrcC  ##  Trace return value [C]
      subroutine DATrcC
     I     (IU, iErr, CK, CMDL)
CCC_  - Declaration
      implicit none
      _INTENT(IN,integer)   IU
      _INTENT(IN,integer)   iErr
      _INTENT(IN,character) CK*(*), CMDL*(*)
CCC_  - Body
 109  format ('TRACE:', A,         ': ', I5)
 108  format ('TRACE:', A, ':', A, ': ', I5)
      if (CK.eq.' ') then
         if      (COND_N(IU)) then
            write (IU, 109) _TRIM(CMDL), iErr
         else if (COND_S(IU)) then
            write (*,  109) _TRIM(CMDL), iErr
         endif
      else
         if      (COND_N(IU)) then
            write (IU, 108) _TRIM(CMDL), _TRIM(CK), iErr
         else if (COND_S(IU)) then
            write (*,  108) _TRIM(CMDL), _TRIM(CK), iErr
         endif
      endif
      RETURN
      END
CCC_ & DATdbN  ## Debug trace [N]
      subroutine DATdbN
     I    (Cmdl,  Ksw)
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(IN,character) Cmdl*(*)
      _INTENT(IN,integer)   Ksw
CCC_   = Save
      character Smdl * (32)
      save      Smdl
      data      Smdl /' '/
      integer   Istp
      save      Istp
      integer    ISTDER
      parameter (ISTDER = 0)
CCC_  - Body
      if (Ksw.eq.0) then
         Smdl = Cmdl
         Istp = 0
      else if (Ksw.lt.0) then
         Istp = 999
      else
         Istp = Istp + 1
      endif
 101  format ('TRACE ', I4, I5, 1x, A)
      if (COND_N(ISTDER)) then
         write (ISTDER, 101) Istp, Ksw, _TRIM(Smdl)
         call FLUSH (ISTDER)
      else if (COND_S(ISTDER)) then
         write (*,      101) Istp, Ksw, _TRIM(Smdl)
      endif
      RETURN
      END
CCC_& DAdsyB  ## Announcement/System diagnosis [B]
      subroutine DAdsyB (iErr, ibsA)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   ibsA (*)
      call DAdsys (iErr, BOOTSTRAP_ERR(ibsA))
      RETURN
      END
CCC_& DAdsys  ## Announcement/System diagnosis
      subroutine DAdsys
     O    (iErr,
     I     IFP)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   IFP
      character BODR*4
      integer   iptmp
CCC_ + Body
      iErr = 0
      iptmp = -9
CCC_ + Byte order
      if (iErr.eq.0) call UUMCnu (iErr, iptmp)
      if (iErr.eq.0) call UUopnS (iErr, iptmp,  1, 'U')
 101  format ('DADSYS/BYTE-ORDER: ', A)
      if (iErr.eq.0) then
         call ufxbod (BODR, iptmp)
         if (COND_N(IFP)) then
            write (IFP, 101) BODR
         else if (COND_S(IFP)) then
            write (*,   101) BODR
         endif
         call UUclsC (iErr, iptmp, ' ', ' ')
      endif
CCC_ + floating-point properties
      if (iErr.eq.0) call ufxfpi (iErr, IFP)
      RETURN
      END
CCC_& DANNTR  ## Development/Announcement announcement
      subroutine DANNTR (STRA, STRB, IOP)
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
#ifdef TEST_DANNTR
CCC_ @ DATEST  ## DANNTR test
      program DATEST
c
      implicit none
      integer IPL
      integer IOP
      character STRA*(128), STRB*(128)
      integer ip, jp
      integer iErr
c
      IPL = -1
      call DABnrU (IPL, 'DATEST begin...')
c
      IOP = 0
      do
         call DANNTR (STRA, STRB, IOP)
         if (STRA.eq.' ') goto 100
         call DAAbiC (IPL, IOP, STRA, STRB)
         IOP = IOP + 1
      enddo
 100  continue
c
      do ip = 0, 100
         jp = ip
         call DAchfU (jp, 'DATEST', IPL)
      enddo
c
      call DAdsys (iErr, -1)
c
      call DABnrU (IPL, 'DATEST end.....')
      STOP
      END
CCC_ + end
#endif /* TEST_DANNTR */
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
