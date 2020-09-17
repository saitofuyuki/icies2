C unison/unmlem.F --- IcIES/Unison/Namelist output emulation
C Maintainer:  SAITO Fuyuki
C Created: Apr 4 2012 (inherited from uuioms)
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2016/07/05 13:16:36 fuyuki unmlem.F>'
#define _FNAME 'unison/unmlem.F'
#define _REV   'Snoopy0.9'
CCC_! MANIFESTO
C
C Copyright (C) 2012--2020
C           Japan Agency for Marine-Earth Science and Technology,
C           Ayako ABE-OUCHI
C
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
CCC_* Description
CC
CC    Namelist output (NOT input) emulation with shorter length.
CC
CC    UNBbgn                   initiate &NAMELIST
CC    UNB{int,str,rst,log}     add scalar entry  "VAR = VALUE,"
CC    UNB{ina,sta,rsa}         add array entry   "VAR = V(0), V(1), ... V(N),"
CC    UNBend                   finalize namelist (add &END)
CC
CC    UNB* routine has an internal buffer to store NAMELIST sequence.
CC    UNBbgn unconditionaly resets the buffer, and UNBend unconditionaly flushs the buffer.
CC    The buffer is flushed when full or new-line condition meets.
CC    Array routines UNB{ina,sta,rsa} flush the buffer every M element if M is positive;
CC    every OPT_NAMELIST_MODULE_DEFAULT element if M negative.
CC
CC    Real(standard) values are shown in /compact/ format using USGlfs().
CC    String values are trimmed and quoted by single quotes.
CC
CC    CAUTION: string which contains single quotes cannot be handled.
CC
CCC_* Macros
#include "ofdlct.h" /* fortran dialect */
#include "ounelv.h" /* namelist emulation level */
#include "ologfm.h" /* logging */
#ifndef    OPT_NAMELIST_PREFIX_CHAR
#  define  OPT_NAMELIST_PREFIX_CHAR '&'
#endif
#ifndef    OPT_NAMELIST_END_STRING
#  define  OPT_NAMELIST_END_STRING '&END'
#endif
#ifndef    OPT_NAMELIST_BUFFER_LEN
#  define  OPT_NAMELIST_BUFFER_LEN 1024
#endif
#ifndef    OPT_NAMELIST_MODULE_DEFAULT
#  define  OPT_NAMELIST_MODULE_DEFAULT 8
#endif
#ifndef    OPT_NAMELIST_ERROR_MAX
#  define  OPT_NAMELIST_ERROR_MAX 128
#endif
CCC_* [UNB] Default buffer
CCC_ & UNBmng  ## default buffer
      subroutine UNBmng
     O    (iErr,
     I     Lalloc)
CCC_  - Description
CC     LVEML 1   condense as much as possible
CC           2   new line after entries
CC           3   new line after elements
CC     M (module for array)
CC           0         try all the member in one line (N)
CC           negative  try default module (OPT_NAMELIST_MODULE_DEFAULT)
CC           positive  try M
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   Lalloc
      _INTENT(IN, character) Tag*(*)
      _INTENT(IN, character) VAR*(*)
      _INTENT(IN, integer)   IFP
      _INTENT(IN, integer)   LVEML
c
      _INTENT(IN, integer)   N, M
      _INTENT(IN, integer)   IV,     IVa (N)
      _INTENT(IN, character) AV*(*), AVa (N)*(*)
      _INTENT(IN, _REALSTD)  SV,     SVa (N)
      _INTENT(IN, logical)   OV
CCC_   . Save
      integer    Lbuf
      parameter (Lbuf = OPT_NAMELIST_BUFFER_LEN)
      character  Buf*(Lbuf), Dmy*(1)
      integer    kPOS,       kDmy
      data       kDmy /0/
      save       Buf, kPOS,  kDmy
      integer icount
      save    icount
CCC_  - Body
      iErr = 0 * Lalloc
CC    Lalloc is reserved for future (dynamic allocation)
      RETURN
CCC_  & UNBbgn  ## initiation
      entry UNBbgn
     O    (iErr,
     I     Tag, IFP, LVEML)
      if (LVEML.eq. _UNMLEM_LEVEL_END) then
         call UNCbgn(iErr, kPOS, Buf, Tag, IFP)
      else
         kPOS = 0
         call UNCbgn(iErr, kDmy, Dmy, Tag, IFP)
      endif
      icount = 0
      call UNBest(icount, iErr, Tag)
      RETURN
CCC_  & UNBend  ## termination
      entry UNBend
     O    (iErr,
     I     Tag, IFP, LVEML)
      if (LVEML.ne. _UNMLEM_LEVEL_END) then
         call UNPfls(iErr, kPOS, Buf, IFP)
      endif
      call UNCend(iErr, kPOS, Buf, Tag, IFP)
      call UNBest(icount, iErr, ' ')
      call UNBchk(Tag)
      RETURN
CCC_  & UNBint  ## scalar integer
      entry UNBint
     O    (iErr,
     I     VAR,  IV, IFP, LVEML)
      if (LVEML.eq. _UNMLEM_LEVEL_END) then
         call UNCint(iErr, kPOS, Buf, VAR, IV, IFP)
      else
         call UNPfls(iErr, kPOS, Buf, IFP)
         call UNCint(iErr, kDmy, Dmy, VAR, IV, IFP)
      endif
      call UNBest(icount, iErr, VAR)
      RETURN
CCC_  & UNBlog  ## scalar logical
      entry UNBlog
     O    (iErr,
     I     VAR,  OV, IFP, LVEML)
      if (LVEML.eq. _UNMLEM_LEVEL_END) then
         call UNClog(iErr, kPOS, Buf, VAR, OV, IFP)
      else
         call UNPfls(iErr, kPOS, Buf, IFP)
         call UNClog(iErr, kDmy, Dmy, VAR, OV, IFP)
      endif
      call UNBest(icount, iErr, VAR)
      RETURN
CCC_  & UNBstr  ## scalar string
      entry UNBstr
     O    (iErr,
     I     VAR,  AV, IFP, LVEML)
      if (LVEML.eq. _UNMLEM_LEVEL_END) then
         call UNCstr(iErr, kPOS, Buf, VAR, AV, IFP)
      else
         call UNPfls(iErr, kPOS, Buf, IFP)
         call UNCstr(iErr, kDmy, Dmy, VAR, AV, IFP)
      endif
      call UNBest(icount, iErr, VAR)
      RETURN
CCC_  & UNBrst  ## scalar real/standard
      entry UNBrst
     O    (iErr,
     I     VAR,  SV, IFP, LVEML)
      if (LVEML.eq. _UNMLEM_LEVEL_END) then
         call UNCrst(iErr, kPOS, Buf, VAR, SV, IFP)
      else
         call UNPfls(iErr, kPOS, Buf, IFP)
         call UNCrst(iErr, kDmy, Dmy, VAR, SV, IFP)
      endif
      call UNBest(icount, iErr, VAR)
      RETURN
CCC_  & UNBina  ## array integer
      entry UNBina
     O    (iErr,
     I     VAR,  IVa, N, M, IFP, LVEML)
      if (LVEML.eq. _UNMLEM_LEVEL_END) then
         call UNCina(iErr, kPOS, Buf, VAR, IVa, N, M, IFP)
      else if (LVEML.eq. _UNMLEM_LEVEL_ENTRY) then
         call UNPfls(iErr, kPOS, Buf, IFP)
         call UNCina(iErr, kPOS, Buf, VAR, IVa, N, M, IFP)
      else
         call UNPfls(iErr, kPOS, Buf, IFP)
         call UNCina(iErr, kDmy, Dmy, VAR, IVa, N, M, IFP)
      endif
      call UNBest(icount, iErr, VAR)
      RETURN
CCC_  & UNBsta  ## array string
      entry UNBsta
     O    (iErr,
     I     VAR,  AVa, N, M, IFP, LVEML)
      if (LVEML.eq. _UNMLEM_LEVEL_END) then
         call UNCsta(iErr, kPOS, Buf, VAR, AVa, N, M, IFP)
      else if (LVEML.eq. _UNMLEM_LEVEL_ENTRY) then
         call UNPfls(iErr, kPOS, Buf, IFP)
         call UNCsta(iErr, kPOS, Buf, VAR, AVa, N, M, IFP)
      else
         call UNPfls(iErr, kPOS, Buf, IFP)
         call UNCsta(iErr, kDmy, Dmy, VAR, AVa, N, M, IFP)
      endif
      call UNBest(icount, iErr, VAR)
      RETURN
CCC_  & UNBrsa  ## array real standard
      entry UNBrsa
     O    (iErr,
     I     VAR,  SVa, N, M, IFP, LVEML)
      if (LVEML.eq. _UNMLEM_LEVEL_END) then
         call UNCrsa(iErr, kPOS, Buf, VAR, SVa, N, M, IFP)
      else if (LVEML.eq. _UNMLEM_LEVEL_ENTRY) then
         call UNPfls(iErr, kPOS, Buf, IFP)
         call UNCrsa(iErr, kPOS, Buf, VAR, SVa, N, M, IFP)
      else
         call UNPfls(iErr, kPOS, Buf, IFP)
         call UNCrsa(iErr, kDmy, Dmy, VAR, SVa, N, M, IFP)
      endif
      call UNBest(icount, iErr, VAR)
      RETURN
CCC_  - END (UNBmng)
      END
CCC_ & UNBstc  ## conditional output scalar string
      subroutine UNBstc (iErr, VAR, AV, IFP, LVEML, ASKP, OVERB)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, character) VAR*(*)
      _INTENT(IN, integer)   IFP
      _INTENT(IN, integer)   LVEML
      _INTENT(IN, character) AV*(*), ASKP*(*)
      _INTENT(IN, logical)   OVERB
      if (OVERB .or. AV.ne.ASKP) then
         call UNBstr(iErr, VAR, AV, IFP, LVEML)
      else
         iErr = 0
      endif
      RETURN
      END
CCC_ & UNBstb  ## conditional output scalar string (unless blank)
      subroutine UNBstb (iErr, VAR, AV, IFP, LVEML, OVERB)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, character) VAR*(*)
      _INTENT(IN, integer)   IFP
      _INTENT(IN, integer)   LVEML
      _INTENT(IN, character) AV*(*)
      _INTENT(IN, logical)   OVERB
      call UNBstc(iErr, VAR, AV, IFP, LVEML, ' ', OVERB)
      RETURN
      END
CCC_ & UNBstq  ## conditional output scalar string (unless blank, quiet)
      subroutine UNBstq (iErr, VAR, AV, IFP, LVEML)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, character) VAR*(*)
      _INTENT(IN, integer)   IFP
      _INTENT(IN, integer)   LVEML
      _INTENT(IN, character) AV*(*)
      call UNBstb(iErr, VAR, AV, IFP, LVEML, .FALSE.)
      RETURN
      END
CCC_ & UNBerr  ## error buffer
      subroutine UNBerr
     O    (iErr,
     I     Lalloc, IFP)
CCC_  - Description
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   Lalloc
      _INTENT(IN,   integer)   IFP
      _INTENT(IN,   integer)   iStt
      _INTENT(INOUT,integer)   icount
      _INTENT(IN,   character) V*(*)
      _INTENT(IN,   character) T*(*)
CCC_   . Save
      integer    Lbuf
      parameter (Lbuf = OPT_NAMELIST_ERROR_MAX)
      character  VAR(Lbuf)*(24)
      integer    KERR(Lbuf)
      integer    KPOS(Lbuf)
      save       VAR, KERR, KPOS
      integer    ib
      save       ib
      integer    iplog
      data       iplog  /-1/
      save       iplog
CCC_   . Internal
      character TXT*(128)
      integer   j
      integer   je
CCC_  - Body
      iErr  = 0 * Lalloc
      iplog = IFP
      RETURN
CCC_  & UNBest  ## store error
      entry UNBest
     M    (icount,
     I     iStt,   V)
      if (icount.eq.0) ib = 0
      if (iStt.ne.0) then
         ib = ib + 1
         if (ib.le.Lbuf) then
            VAR(ib)  = V
            KPOS(ib) = icount
            KERR(ib) = iStt
         endif
      endif
      RETURN
CCC_  & UNBchk  ## check errors
      entry UNBchk (T)
      do j = 1, min(ib, Lbuf)
         TXT = 'ERROR['
         call USJnta(TXT, T, ']')
         call USGsni(TXT, KPOS(j), ':')
         call USGbni(TXT, KERR(j))
         call USJsta(TXT, ' ', VAR(j))
         call USWitn(je, iplog, TXT)
      enddo
      RETURN
CCC_  - END (UNBerr)
      END
CCC_* [UNC] String/File output
CCC_ & UNCbgn  ## namelist choice initiation
      subroutine UNCbgn
     O    (iErr,
     O     kPOS, Buf,
     I     Tag,  IFP)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   kPOS
      _INTENT(OUT,character) Buf*(*)
      _INTENT(IN, character) Tag*(*)
      _INTENT(IN, integer)   IFP
      iErr = 0
      call UNPbgS(iErr, kPOS, Buf, Tag)
      if (iErr.gt.0) call UNPbgF(iErr, Tag, IFP)
      RETURN
      END
CCC_ & UNCend  ## namelist choice termination
      subroutine UNCend
     O    (iErr,
     I     kPOS, Buf,
     I     Tag,  IFP)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   kPOS
      _INTENT(IN, character) Buf*(*)
      _INTENT(IN, character) Tag*(*)
      _INTENT(IN, integer)   IFP
      iErr = 0
      if (kPOS.gt.0) then
         call UNPenS(iErr, kPOS, Buf, Tag, IFP)
      else
         call UNPenF(iErr, Tag, IFP)
      endif
      RETURN
      END
CCC_ & UNCint  ## namelist choice scalar integer
      subroutine UNCint
     O    (iErr,
     M     kPOS, Buf,
     I     VAR,  IV, IFP)
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,integer)   kPOS
      _INTENT(INOUT,character) Buf*(*)
      _INTENT(IN,   character) VAR*(*)
      _INTENT(IN,   integer)   IV
      _INTENT(IN,   integer)   IFP
      iErr = 0
CCC_  - first try: append to buffer
      call UNEsiS(iErr, kPOS, Buf, VAR, IV)
CCC_  - if failed: flush and append
      if (iErr.gt.0) then
         call UNPfls(iErr, kPOS, Buf, IFP)
         call UNEsiS(iErr, kPOS, Buf, VAR, IV)
      endif
CCC_  - if still failed: file output
      if (iErr.gt.0) then
         call UNEsiF(iErr, VAR, IV, IFP)
      endif
      RETURN
      END
CCC_ & UNClog  ## namelist choice scalar logical
      subroutine UNClog
     O    (iErr,
     M     kPOS, Buf,
     I     VAR,  OV, IFP)
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,integer)   kPOS
      _INTENT(INOUT,character) Buf*(*)
      _INTENT(IN,   character) VAR*(*)
      _INTENT(IN,   logical)   OV
      _INTENT(IN,   integer)   IFP
      iErr = 0
      call UNEsoS(iErr, kPOS, Buf, VAR, OV)
      if (iErr.gt.0) then
         call UNPfls(iErr, kPOS, Buf, IFP)
         call UNEsoS(iErr, kPOS, Buf, VAR, OV)
      endif
      if (iErr.gt.0) then
         call UNEsoF(iErr, VAR, OV, IFP)
      endif
      RETURN
      END
CCC_ & UNCstr  ## namelist choice scalar string
      subroutine UNCstr
     O    (iErr,
     M     kPOS, Buf,
     I     VAR,  AV, IFP)
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,integer)   kPOS
      _INTENT(INOUT,character) Buf*(*)
      _INTENT(IN,   character) VAR*(*)
      _INTENT(IN,   character) AV*(*)
      _INTENT(IN,   integer)   IFP
      iErr = 0
      call UNEsaS(iErr, kPOS, Buf, VAR, AV)
      if (iErr.gt.0) then
         call UNPfls(iErr, kPOS, Buf, IFP)
         call UNEsaS(iErr, kPOS, Buf, VAR, AV)
      endif
      if (iErr.gt.0) then
         call UNEsaF(iErr, VAR, AV, IFP)
      endif
      RETURN
      END
CCC_ & UNCrst  ## namelist choice scalar real/standard
      subroutine UNCrst
     O    (iErr,
     M     kPOS, Buf,
     I     VAR,  SV, IFP)
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,integer)   kPOS
      _INTENT(INOUT,character) Buf*(*)
      _INTENT(IN,   character) VAR*(*)
      _INTENT(IN,   _REALSTD)  SV
      _INTENT(IN,   integer)   IFP
      iErr = 0
      call UNEssS(iErr, kPOS, Buf, VAR, SV)
      if (iErr.gt.0) then
         call UNPfls(iErr, kPOS, Buf, IFP)
         call UNEssS(iErr, kPOS, Buf, VAR, SV)
      endif
      if (iErr.gt.0) then
         call UNEssF(iErr, VAR, SV, IFP)
      endif
      RETURN
      END
CCC_ & UNCdmd () ## get module for array output
      integer function UNCdmd
     I     (M, N)
      implicit none
      _INTENT(IN,integer) M, N
      integer MM
      MM = M
      if (MM.eq.0) then
         MM = N
      else if (MM.lt.0) then
         MM = OPT_NAMELIST_MODULE_DEFAULT
      endif
      UNCdmd = MM
      RETURN
      END
CCC_ & UNCina  ## namelist choice  integer array
      subroutine UNCina
     O    (iErr,
     M     kPOS, Buf,
     I     VAR,  IV, N, M, IFP)
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,integer)   kPOS
      _INTENT(INOUT,character) Buf*(*)
      _INTENT(IN,   character) VAR*(*)
      _INTENT(IN,   integer)   N, M
      _INTENT(IN,   integer)   IV (N)
      _INTENT(IN,   integer)   IFP
      integer Nlast, Nend, MM
      integer UNCdmd
CCC_  - Body
      iErr  = 0
      MM    = UNCdmd (M, N)
      Nlast = -1
      DO
         Nend = MIN (N, MAX (1, Nlast) + MM)
         call UNEaiS(iErr, kPOS, Buf, Nlast, VAR, IV, Nend)
         if (Nlast.ge.N) goto 900
         call UNPfls(iErr, kPOS, Buf, IFP)
         if (Nlast.lt.0) then
            call UNEaiF(iErr, VAR, IV, 0, N, IFP)
            Nlast = N
         endif
      ENDDO
 900  continue
      RETURN
      END
CCC_ & UNCsta  ## namelist choice  string array
      subroutine UNCsta
     O    (iErr,
     M     kPOS, Buf,
     I     VAR,  AV, N, M, IFP)
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,integer)   kPOS
      _INTENT(INOUT,character) Buf*(*)
      _INTENT(IN,   character) VAR*(*)
      _INTENT(IN,   integer)   N, M
      _INTENT(IN,   character) AV (N)*(*)
      _INTENT(IN,   integer)   IFP
      integer Nlast, Nend, MM
      integer UNCdmd
CCC_  - Body
      iErr  = 0
      MM    = UNCdmd (M, N)
      Nlast = -1
      DO
         Nend = MIN (N, MAX (1, Nlast) + MM)
         call UNEaaS(iErr, kPOS, Buf, Nlast, VAR, AV, Nend)
         if (Nlast.ge.N) goto 900
         call UNPfls(iErr, kPOS, Buf, IFP)
         if (Nlast.lt.0) then
            call UNEaaF(iErr, VAR, AV, 0, N, IFP)
            Nlast = N
         endif
      ENDDO
 900  continue
      RETURN
      END
CCC_ & UNCrsa  ## namelist choice  real standard array
      subroutine UNCrsa
     O    (iErr,
     M     kPOS, Buf,
     I     VAR,  SV, N, M, IFP)
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,integer)   kPOS
      _INTENT(INOUT,character) Buf*(*)
      _INTENT(IN,   character) VAR*(*)
      _INTENT(IN,   integer)   N, M
      _INTENT(IN,   _REALSTD)  SV (N)
      _INTENT(IN,   integer)   IFP
      integer Nlast, Nend, MM
      integer UNCdmd
CCC_  - Body
      iErr  = 0
      MM    = UNCdmd (M, N)
      Nlast = -1
      DO
         Nend = MIN (N, MAX (1, Nlast) + MM)
         call UNEasS(iErr, kPOS, Buf, Nlast, VAR, SV, Nend)
         if (Nlast.ge.N) goto 900
         call UNPfls(iErr, kPOS, Buf, IFP)
         if (Nlast.lt.0) then
            call UNEasF(iErr, VAR, SV, 0, N, IFP)
            Nlast = N
         endif
      ENDDO
 900  continue
      RETURN
      END
CCC_* [UNE] Entries
CCC_ & UNEaiS  ## namelist entry array/integer/string
      subroutine UNEaiS
     O    (iErr,
     M     kPOS, STR, NLast,
     I     VAR,  IV,  N)
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,integer)   Nlast
      _INTENT(INOUT,integer)   kPOS
      _INTENT(INOUT,character) Str*(*)
      _INTENT(IN,   character) VAR*(*)
      _INTENT(IN,   integer)   N
      _INTENT(IN,   integer)   IV (N)
      integer j
      iErr = 0
      if (Nlast.le.0) then
         j = 1
         call UNEsiS(iErr, kPOS, STR, VAR, IV(j))
         if (iErr.eq.0) Nlast = 1
      endif
      if (iErr.eq.0) then
         do j = Nlast + 1, N
            call UNEsiS(iErr, kPOS, STR, ' ', IV(j))
            if (iErr.ne.0) then
               Nlast = j - 1
               goto 900
            endif
         enddo
 900     continue
         if (iErr.eq.0) then
            Nlast = N
         endif
      endif
      RETURN
      END
CCC_ & UNEaaS  ## namelist entry array/string/string
      subroutine UNEaaS
     O    (iErr,
     M     kPOS, STR, NLast,
     I     VAR,  AV,  N)
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,integer)   Nlast
      _INTENT(INOUT,integer)   kPOS
      _INTENT(INOUT,character) Str*(*)
      _INTENT(IN,   character) VAR*(*)
      _INTENT(IN,   integer)   N
      _INTENT(IN,   character) AV (N)*(*)
      integer j
      iErr = 0
      if (Nlast.le.0) then
         j = 1
         call UNEsaS(iErr, kPOS, STR, VAR, AV(j))
         if (iErr.eq.0) Nlast = 1
      endif
      if (iErr.eq.0) then
         do j = Nlast + 1, N
            call UNEsaS(iErr, kPOS, STR, ' ', AV(j))
            if (iErr.ne.0) then
               Nlast = j - 1
               goto 900
            endif
         enddo
 900     continue
         if (iErr.eq.0) then
            Nlast = N
         endif
      endif
      RETURN
      END
CCC_ & UNEasS  ## namelist entry array/real standard/string
      subroutine UNEasS
     O    (iErr,
     M     kPOS, STR, NLast,
     I     VAR,  SV,  N)
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,integer)   Nlast
      _INTENT(INOUT,integer)   kPOS
      _INTENT(INOUT,character) Str*(*)
      _INTENT(IN,   character) VAR*(*)
      _INTENT(IN,   integer)   N
      _INTENT(IN,   _REALSTD)  SV (N)
      integer j
      iErr = 0
      if (Nlast.le.0) then
         j = 1
         call UNEssS(iErr, kPOS, STR, VAR, SV(j))
         if (iErr.eq.0) Nlast = 1
      endif
      if (iErr.eq.0) then
         do j = Nlast + 1, N
            call UNEssS(iErr, kPOS, STR, ' ', SV(j))
            if (iErr.ne.0) then
               Nlast = j - 1
               goto 900
            endif
         enddo
 900     continue
         if (iErr.eq.0) then
            Nlast = N
         endif
      endif
      RETURN
      END
CCC_ & UNEaiF  ## namelist entry array/integer/file
      subroutine UNEaiF
     O    (iErr,
     I     VAR,  IV,  N0, N, IFP)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, character) VAR*(*)
      _INTENT(IN, integer)   N0, N
      _INTENT(IN, integer)   IV (N)
      _INTENT(IN, integer)   IFP
      integer j, j0
      if (N0.le.0) then
         j = 1
         call UNEsiF(iErr, VAR, IV(j), IFP)
         j0 = j + 1
      else
         j0 = N0
      endif
      do j = j0, N
         call UNEsiF(iErr, ' ', IV(j), IFP)
      enddo
      RETURN
      END
CCC_ & UNEaaF  ## namelist entry array/string/file
      subroutine UNEaaF
     O    (iErr,
     I     VAR,  AV,  N0, N, IFP)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, character) VAR*(*)
      _INTENT(IN, integer)   N0, N
      _INTENT(IN, character) AV (N)*(*)
      _INTENT(IN, integer)   IFP
      integer j, j0
      if (N0.le.0) then
         j = 1
         call UNEsaF(iErr, VAR, AV(j), IFP)
         j0 = j + 1
      else
         j0 = N0
      endif
      do j = j0, N
         call UNEsaF(iErr, ' ', AV(j), IFP)
      enddo
      RETURN
      END
CCC_ & UNEasF  ## namelist entry array/real standard/file
      subroutine UNEasF
     O    (iErr,
     I     VAR,  SV,  N0, N, IFP)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, character) VAR*(*)
      _INTENT(IN, integer)   N0, N
      _INTENT(IN, _REALSTD)  SV (N)
      _INTENT(IN, integer)   IFP
      integer j, j0
      if (N0.le.0) then
         j = 1
         call UNEssF(iErr, VAR, SV(j), IFP)
         j0 = j + 1
      else
         j0 = N0
      endif
      do j = j0, N
         call UNEssF(iErr, ' ', SV(j), IFP)
      enddo
      RETURN
      END
CCC_ & UNEsiF  ## namelist entry scalar/integer/file
      subroutine UNEsiF
     O    (iErr,
     I     VAR,  IV,  IFP)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, character) VAR*(*)
      _INTENT(IN, integer)   IV
      _INTENT(IN, integer)   IFP
      character B*32
      iErr = 0
      call USGlni(B, IV)
      call UNPvvF(iErr, VAR, B, ' ', ' ', IFP)
      RETURN
      END
CCC_ & UNEsoF  ## namelist entry scalar/logical/file
      subroutine UNEsoF
     O    (iErr,
     I     VAR,  OV,  IFP)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, character) VAR*(*)
      _INTENT(IN, logical)   OV
      _INTENT(IN, integer)   IFP
      character B*32
      iErr = 0
      write (B, '(L1)') OV
      call UNPvvF(iErr, VAR, B, ' ', ' ', IFP)
      RETURN
      END
CCC_ & UNEsaF  ## namelist entry scalar/string/file
      subroutine UNEsaF
     O    (iErr,
     I     VAR,  AV,  IFP)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, character) VAR*(*)
      _INTENT(IN, character) AV*(*)
      _INTENT(IN, integer)   IFP
      iErr = 0
      call UNPvvF(iErr, VAR, AV, '''', '''', IFP)
      RETURN
      END
CCC_ & UNEssF  ## namelist entry scalar/real standard/file
      subroutine UNEssF
     O    (iErr,
     I     VAR,  SV,  IFP)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, character) VAR*(*)
      _INTENT(IN, _REALSTD)  SV
      _INTENT(IN, integer)   IFP
      character B*32
      iErr = 0
      call USGlfs(B, SV, 'C')
      call UNPvvF(iErr, VAR, B, ' ', ' ', IFP)
      RETURN
      END
CCC_ & UNEsfF  ## namelist entry scalar/float/file
      subroutine UNEsfF
     O    (iErr,
     I     VAR,  FV,  IFP)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, character) VAR*(*)
      _INTENT(IN, _REAL32)   FV
      _INTENT(IN, integer)   IFP
      character B*32
      integer   J
      iErr = 0
      J = NINT (FV)
      if (_XREAL32(J) .eq. FV) then
         call USGlni(B, J)
         call USJnta(B, '.0', 'E0')
      else
         write (B, '(E24.16)') FV
      endif
      call UNPvvF(iErr, VAR, B, ' ', ' ', IFP)
      RETURN
      END
CCC_ & UNEsdF  ## namelist entry scalar/double/file
      subroutine UNEsdF
     O    (iErr,
     I     VAR,  DV,  IFP)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, character) VAR*(*)
      _INTENT(IN, _REAL64)   DV
      _INTENT(IN, integer)   IFP
      character B*32
      integer   J
      iErr = 0
      J = NINT (DV)
      if (_XREAL64(J) .eq. DV) then
         call USGlni(B, J)
         call USJnta(B, '.0', 'D0')
      else
         write (B, '(E24.16)') DV
      endif
      call UNPvvF(iErr, VAR, B, ' ', ' ', IFP)
      RETURN
      END
CCC_ & UNEsiS  ## namelist entry scalar/integer/string
      subroutine UNEsiS
     O    (iErr,
     M     kPOS, STR,
     I     VAR,  IV)
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,integer)   kPOS
      _INTENT(INOUT,character) Str*(*)
      _INTENT(IN,   character) VAR*(*)
      _INTENT(IN,   integer)   IV
      character B*32
      iErr = 0
      call USGlni(B, IV)
      call UNPvvS(iErr, kPOS, STR, VAR, B, ' ', ' ')
      RETURN
      END
CCC_ & UNEsoS  ## namelist entry scalar/logical/string
      subroutine UNEsoS
     O    (iErr,
     M     kPOS, STR,
     I     VAR,  OV)
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,integer)   kPOS
      _INTENT(INOUT,character) Str*(*)
      _INTENT(IN,   character) VAR*(*)
      _INTENT(IN,   logical)   OV
      character B*32
      iErr = 0
      write (B, '(L1)') OV
      call UNPvvS(iErr, kPOS, STR, VAR, B, ' ', ' ')
      RETURN
      END
CCC_ & UNEsaS  ## namelist entry scalar/string/string
      subroutine UNEsaS
     O    (iErr,
     M     kPOS, STR,
     I     VAR,  AV)
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,integer)   kPOS
      _INTENT(INOUT,character) Str*(*)
      _INTENT(IN,   character) VAR*(*)
      _INTENT(IN,   character) AV*(*)
      iErr = 0
      call UNPvvS(iErr, kPOS, STR, VAR, AV, '''', '''')
      RETURN
      END
CCC_ & UNEssS  ## namelist entry scalar/real-standard/string
      subroutine UNEssS
     O    (iErr,
     M     kPOS, STR,
     I     VAR,  SV)
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,integer)   kPOS
      _INTENT(INOUT,character) Str*(*)
      _INTENT(IN,   character) VAR*(*)
      _INTENT(IN,   _REALSTD)  SV
      character B*32
      iErr = 0
      call USGlfs(B, SV, 'C')
      call UNPvvS(iErr, kPOS, STR, VAR, B, ' ', ' ')
      RETURN
      END
CCC_* [UNP] Primitives
CCC_ & UNPbgF  ## namelist initiation (file)
      subroutine UNPbgF
     O    (iErr,
     I     Tag, IFP)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, character) Tag*(*)
      _INTENT(IN, integer)   IFP
      integer lt
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
      iErr = 0
      lt   = len_trim (Tag)
 101  format (1x, OPT_NAMELIST_PREFIX_CHAR, A)
      if      (COND_N(IFP))  then
         write (IFP, 101, IOSTAT = iErr) Tag(1:lt)
      else if (COND_S(IFP)) then
         write (*,   101, IOSTAT = iErr) Tag(1:lt)
      endif
      RETURN
      END
CCC_ & UNPbgS  ## namelist initiation (string)
      subroutine UNPbgS
     O    (iErr,
     O     kPOS,
     M     Str,
     I     Tag)
CC     RETURN 1 if unsufficient buffer
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(OUT,  integer)   kPOS
      _INTENT(INOUT,character) Str*(*)
      _INTENT(IN,   character) Tag*(*)
      integer lentry, lStr, lTag
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
 101  format (1x, OPT_NAMELIST_PREFIX_CHAR, A)
      lTag   = len_trim (Tag)
      lentry = 1 + len (OPT_NAMELIST_PREFIX_CHAR) + lTag
      lStr   = LEN (STR)
      kPOS   = 0
      if (kPOS + lentry.gt.lStr) then
         iErr = 1
      else
         iErr = 0
         write (STR (kPOS + 1:kPOS + lentry), 101) Tag (1:lTag)
         kPOS = kPOS + lentry
      endif
      RETURN
      END
CCC_ & UNPenF  ## namelist termination (file)
      subroutine UNPenF
     O    (iErr,
     I     Tag, IFP)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, character) Tag*(*)
      _INTENT(IN, integer)   IFP
      iErr = 0
 101  format (1x, OPT_NAMELIST_END_STRING)
      if      (COND_N(IFP))  then
         write (IFP, 101, IOSTAT = iErr)
      else if (COND_S(IFP)) then
         write (*,   101, IOSTAT = iErr)
      else if (Tag.eq.' ') then
cc       dummy condition
         continue
      endif
      RETURN
      END
CCC_ & UNPenS  ## namelist termination (string/file)
      subroutine UNPenS
     O    (iErr,
     I     kPOS, Str,
     I     Tag,  IFP)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, character) Tag*(*)
      _INTENT(IN, integer)   kPOS
      _INTENT(IN, character) Str*(*)
      _INTENT(IN, integer)   IFP
      iErr = 0
 101  format (A, 1x, OPT_NAMELIST_END_STRING)
 102  format (1x, OPT_NAMELIST_END_STRING)
      if      (COND_N(IFP))  then
         if (kPOS.gt.1) then
            write (IFP, 101, IOSTAT = iErr) Str (1:kPOS)
         else
            write (IFP, 102, IOSTAT = iErr)
         endif
      else if (COND_S(IFP)) then
         if (kPOS.gt.1) then
            write (*,   101, IOSTAT = iErr) Str (1:kPOS)
         else
            write (*,   102, IOSTAT = iErr)
         endif
      else if (Tag.eq.' ') then
cc       dummy condition
         continue
      endif
      RETURN
      END
CCC_ & UNPfls  ## namelist flush buffer
      subroutine UNPfls
     O    (iErr,
     M     kPOS, Str,
     I     IFP)
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,integer)   kPOS
      _INTENT(INOUT,character) Str*(*)
      _INTENT(IN,   integer)   IFP
      iErr = 0
      if (kPOS.gt.1) then
 101     format (A)
         if      (COND_N(IFP))  then
            write (IFP, 101, IOSTAT = iErr) Str (1:kPOS)
         else if (COND_S(IFP)) then
            write (*,   101, IOSTAT = iErr) Str (1:kPOS)
         endif
      endif
      Str  = ' '
      kPOS = 1
      RETURN
      END
CCC_ & UNPvvF  ## namelist output var/val pair (file)
      subroutine UNPvvF
     O    (iErr,
     I     VAR,  VAL,  CL, CR, IFP)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, character) VAR*(*), VAL*(*)
      _INTENT(IN, character) CL*(*),  CR*(*)
      _INTENT(IN, integer)   IFP
      integer lvar, lval
      integer lcl,  lcr
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
      iErr = 0
      lvar = len_trim (VAR)
      lval = MAX (1, len_trim (VAL))
      lcl  = len_trim (CL)
      lcr  = len_trim (CR)
c
 2222 format (2x, A,  1x, '=', 1x, A, A, A, ',')
 2221 format (2x, A,  1x, '=', 1x, A, A,    ',')
 2122 format (2x, A,  1x, '=', 1x,    A, A, ',')
 2121 format (2x, A,  1x, '=', 1x,    A,    ',')
 1222 format (2x, 2x, 1x, 1x,  1x, A, A, A, ',')
 1221 format (2x, 2x, 1x, 1x,  1x, A, A,    ',')
 1122 format (2x, 2x, 1x, 1x,  1x,    A, A, ',')
 1121 format (2x, 2x, 1x, 1x,  1x,    A,    ',')
c
      if      (COND_N(IFP))  then
         if   (lvar.eq.0) then
            if ((lcl.eq.0).and.(lcr.eq.0)) then
               write (IFP, 1121, IOSTAT = iErr)
     $                                        VAL (1:lval)
            else if (lcl.eq.0) then
               write (IFP, 1122, IOSTAT = iErr)
     $                                        VAL (1:lval), CR (1:lcr)
            else if (lcr.eq.0) then
               write (IFP, 1221, IOSTAT = iErr)
     $                            CL (1:lcl), VAL (1:lval)
            else
               write (IFP, 1222, IOSTAT = iErr)
     $                            CL (1:lcl), VAL (1:lval), CR (1:lcr)
            endif
         else
            if ((lcl.eq.0).and.(lcr.eq.0)) then
               write (IFP, 2121, IOSTAT = iErr)
     $              VAR (1:lvar),             VAL (1:lval)
            else if (lcl.eq.0) then
               write (IFP, 2122, IOSTAT = iErr)
     $              VAR (1:lvar),             VAL (1:lval), CR (1:lcr)
            else if (lcr.eq.0) then
               write (IFP, 2221, IOSTAT = iErr)
     $              VAR (1:lvar), CL (1:lcl), VAL (1:lval)
            else
               write (IFP, 2222, IOSTAT = iErr)
     $              VAR (1:lvar), CL (1:lcl), VAL (1:lval), CR (1:lcr)
            endif
         endif
      else if (COND_S(IFP)) then
#        define IFP *
         if   (lvar.eq.0) then
            if ((lcl.eq.0).and.(lcr.eq.0)) then
               write (IFP, 1121, IOSTAT = iErr)
     $                                        VAL (1:lval)
            else if (lcl.eq.0) then
               write (IFP, 1122, IOSTAT = iErr)
     $                                        VAL (1:lval), CR (1:lcr)
            else if (lcr.eq.0) then
               write (IFP, 1221, IOSTAT = iErr)
     $                            CL (1:lcl), VAL (1:lval)
            else
               write (IFP, 1222, IOSTAT = iErr)
     $                            CL (1:lcl), VAL (1:lval), CR (1:lcr)
            endif
         else
            if ((lcl.eq.0).and.(lcr.eq.0)) then
               write (IFP, 2121, IOSTAT = iErr)
     $              VAR (1:lvar),             VAL (1:lval)
            else if (lcl.eq.0) then
               write (IFP, 2122, IOSTAT = iErr)
     $              VAR (1:lvar),             VAL (1:lval), CR (1:lcr)
            else if (lcr.eq.0) then
               write (IFP, 2221, IOSTAT = iErr)
     $              VAR (1:lvar), CL (1:lcl), VAL (1:lval)
            else
               write (IFP, 2222, IOSTAT = iErr)
     $              VAR (1:lvar), CL (1:lcl), VAL (1:lval), CR (1:lcr)
            endif
#        undef IFP
         endif
      endif
      RETURN
      END
CCC_ & UNPvvS  ## namelist output var/val pair (string)
      subroutine UNPvvS
     O    (iErr,
     M     kPOS, Str,
     I     VAR,  VAL,  CL, CR)
CCC_  - Description
CC       append '[VAR] = [CL][VAL][CR]' to Str, set kPOS.
CC       return required length if not enough.
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,integer)   kPOS
      _INTENT(INOUT,character) Str*(*)
      _INTENT(IN,   character) VAR*(*), VAL*(*)
      _INTENT(IN,   character) CL*(*),  CR*(*)
      integer lvar, lval
      integer lcl,  lcr
      integer lStr, lEntry
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
CCC_  - Body
      iErr = 0
      lvar = len_trim (VAR)
      lval = MAX (1, len_trim (VAL))
      lcl  = len_trim (CL)
      lcr  = len_trim (CR)
c
      lentry = lcl + lval + lcr
      if (lvar.eq.0) then
         continue
      else
         lentry = lvar + 3 + lentry
      endif
      lentry = lentry + 2
c
      lStr   = LEN (STR)
c
 2222 format (1x, A,  1x, '=', 1x, A, A, A, ',')
 2221 format (1x, A,  1x, '=', 1x, A, A,    ',')
 2122 format (1x, A,  1x, '=', 1x,    A, A, ',')
 2121 format (1x, A,  1x, '=', 1x,    A,    ',')
 1222 format (1x,                  A, A, A, ',')
 1221 format (1x,                  A, A,    ',')
 1122 format (1x,                     A, A, ',')
 1121 format (1x,                     A,    ',')
c
      if (kPOS + lentry.gt.lStr) then
         iErr = lentry
      else
         iErr = 0
         if   (lvar.eq.0) then
            if ((lcl.eq.0).and.(lcr.eq.0)) then
               write (STR (kPOS + 1:kPOS + lentry), 1121)
     $                                        VAL (1:lval)
            else if (lcl.eq.0) then
               write (STR (kPOS + 1:kPOS + lentry), 1122)
     $                                        VAL (1:lval), CR (1:lcr)
            else if (lcr.eq.0) then
               write (STR (kPOS + 1:kPOS + lentry), 1221)
     $                            CL (1:lcl), VAL (1:lval)
            else
               write (STR (kPOS + 1:kPOS + lentry), 1222)
     $                            CL (1:lcl), VAL (1:lval), CR (1:lcr)
            endif
         else
            if ((lcl.eq.0).and.(lcr.eq.0)) then
               write (STR (kPOS + 1:kPOS + lentry), 2121)
     $              VAR (1:lvar),             VAL (1:lval)
            else if (lcl.eq.0) then
               write (STR (kPOS + 1:kPOS + lentry), 2122)
     $              VAR (1:lvar),             VAL (1:lval), CR (1:lcr)
            else if (lcr.eq.0) then
               write (STR (kPOS + 1:kPOS + lentry), 2221)
     $              VAR (1:lvar), CL (1:lcl), VAL (1:lval)
            else
               write (STR (kPOS + 1:kPOS + lentry), 2222)
     $              VAR (1:lvar), CL (1:lcl), VAL (1:lval), CR (1:lcr)
            endif
         endif
         kPOS = kPOS + lentry
      endif
c
      RETURN
      END
CCC_& UNMLEM  ## Unison/Namelist emulation announcement
      subroutine UNMLEM (STRA, STRB, IOP)
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
         STRA = 'OPT_NAMELIST_PREFIX_CHAR'
         write (STRB, *) OPT_NAMELIST_PREFIX_CHAR
      else if (IOP.eq.4) then
         STRA = 'OPT_NAMELIST_END_STRING'
         write (STRB, *) OPT_NAMELIST_END_STRING
      else if (IOP.eq.5) then
         STRA = 'OPT_NAMELIST_BUFFER_LEN'
         write (STRB, *) OPT_NAMELIST_BUFFER_LEN
      else if (IOP.eq.6) then
         STRA = 'OPT_NAMELIST_MODULE_DEFAULT'
         write (STRB, *) OPT_NAMELIST_MODULE_DEFAULT
      else
         STRA = ' '
         STRB = ' '
      endif
      RETURN
      END
CCC_* Test
CCC_ + begin subroutine
#if       TEST_UNMLEM || WITH_TEST_UNMLEM
CCC_ & UNTEST_prm_file
      subroutine UNTEST_prm_file (iErr, KLVL,  KD,AD)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   KLVL
      _INTENT(INOUT,integer)   KD(*)
      _INTENT(INOUT,character) AD(*)*(*)
      integer jfp
      character Tag*(32)
CCC_  - Body
      iErr = 0
      call UDSquo(jfp, KD)
c
      if (iErr.eq.0) call UDSnew(iErr, KD, AD, 0, 'PRIMITIVE/FILE')
      Tag = 'NICHK0'
      if (iErr.eq.0) call UNPbgF(iErr, Tag, jfp)
      if (iErr.eq.0) call UNPenF(iErr, Tag, jfp)
c
      if (iErr.eq.0) call UNPvvF(iErr, 'VAR', 'val', '<''', '''>', jfp)
      if (iErr.eq.0) call UNPvvF(iErr, 'VAR', 'val', '<''', '   ', jfp)
      if (iErr.eq.0) call UNPvvF(iErr, 'VAR', 'val', '   ', '''>', jfp)
      if (iErr.eq.0) call UNPvvF(iErr, 'VAR', 'val', '   ', '   ', jfp)
      if (iErr.eq.0) call UNPvvF(iErr, '   ', 'val', '<''', '''>', jfp)
      if (iErr.eq.0) call UNPvvF(iErr, '   ', 'val', '<''', '   ', jfp)
      if (iErr.eq.0) call UNPvvF(iErr, '   ', 'val', '   ', '''>', jfp)
      if (iErr.eq.0) call UNPvvF(iErr, '   ', 'val', '   ', '   ', jfp)
c
      if (iErr.eq.0) call UNPvvF(iErr, 'VAR', '   ', '<''', '''>', jfp)
      if (iErr.eq.0) call UNPvvF(iErr, 'VAR', '   ', '<''', '   ', jfp)
      if (iErr.eq.0) call UNPvvF(iErr, 'VAR', '   ', '   ', '''>', jfp)
      if (iErr.eq.0) call UNPvvF(iErr, 'VAR', '   ', '   ', '   ', jfp)
      if (iErr.eq.0) call UNPvvF(iErr, '   ', '   ', '<''', '''>', jfp)
      if (iErr.eq.0) call UNPvvF(iErr, '   ', '   ', '<''', '   ', jfp)
      if (iErr.eq.0) call UNPvvF(iErr, '   ', '   ', '   ', '''>', jfp)
      if (iErr.eq.0) call UNPvvF(iErr, '   ', '   ', '   ', '   ', jfp)
c
      RETURN
      END
CCC_  & UNTEST_vvs_suite
      subroutine UNTEST_vvs_suite
     O    (iErr, Str)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,character) Str*(*)
c
      character VAR (2)*16, VAL (2)*16
      character CL  (2)*16, CR  (2)*16
c
      integer   k1, k2, k3, k4
      integer   j,  jj
c
      VAR (1) = 'VAR'
      VAR (2) = ' '
      VAL (1) = 'val'
      VAL (2) = ' '
      CL  (1) = '<'''
      CL  (2) = ' '
      CR  (1) = '''>'
      CR  (2) = ' '
c
      do j = 0, 15
         k1 = 1 + MOD (J / 1, 2)
         k2 = 1 + MOD (J / 2, 2)
         k3 = 1 + MOD (J / 4, 2)
         k4 = 1 + MOD (J / 8, 2)
         jj = j
c$$$ 301     format (I0, 1x, 4I1)
c$$$         write (*, 301) j, k4, k3, k2, k1
         call UNTEST_vvs_core
     $        (iErr, jj, Str, VAR (k3), VAL (k4), CL (k2), CR (k1))
      enddo
c
      RETURN
      END
CCC_  & UNTEST_vvs_core
      subroutine UNTEST_vvs_core
     O    (iErr, jj, Str, var, val, cl, cr)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,character) Str*(*)
      _INTENT(IN, integer)   jj
      _INTENT(IN, character) var*(*), val*(*), cl*(*), cr*(*)
      integer kPOS
      kPOS = 0
      call UNPvvS(iErr, kPOS, Str, var,  val,  cl, cr)
 101  format (I0, ': ', I4, 1x, I4, 1x, '[', A, ']')
      write (*, 101) jj, iErr, kPOS, Str (1:kPOS)
      RETURN
      END
CCC_ & UNTEST_prm_string
      subroutine UNTEST_prm_string (iErr, KLVL,  KD,AD)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   KLVL
      _INTENT(INOUT,integer)   KD(*)
      _INTENT(INOUT,character) AD(*)*(*)
      integer   jfp
      character Tag *(32)
      character StrM*(32)
      character StrS*(3)
      integer   kPos
CCC_  - Body
      iErr = 0
      call UDSquo(jfp, KD)
c
      if (iErr.eq.0) call UDSnew(iErr, KD, AD, 0, 'PRIMITIVE/STRING')
      Tag = 'NICHK1'
      StrM = 'abc''def'
      write (*, *) '//', _TRIM(StrM), '//'
      call UNPbgS(iErr, kPOS, StrM, Tag)
      write (*, *) iErr, StrM (1:kPOS)
      call UNPbgS(iErr, kPOS, StrS, Tag)
      write (*, *) iErr, StrS (1:kPOS)
c
      call UNTEST_vvs_suite(iErr, StrM)
      call UNTEST_vvs_suite(iErr, StrS)
      RETURN
      END
CCC_ & UNTEST_entry
      subroutine UNTEST_entry (iErr, KLVL,  KD,AD)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   KLVL
      _INTENT(INOUT,integer)   KD(*)
      _INTENT(INOUT,character) AD(*)*(*)
c
      integer    LVA
      parameter (LVA = 16)
      integer    IVa (LVA)
      integer    N, NL
      integer    j
      integer    kPOS
      integer    jfp
      character  StrM*(32)
CCC_  - Body
      iErr = 0
      call UDSquo(jfp, KD)
c
      if (iErr.eq.0) call UDSnew(iErr, KD, AD, 0, 'ENTRY')
c
      call UNEsiF(iErr, 'IVAR', -99,              jfp)
      call UNEsoF(iErr, 'OVAR', .false.,          jfp)
      call UNEsaF(iErr, 'AVAR', 'TEXT TEXT TEXT', jfp)
      call UNEssF(iErr, 'SVAR', -999.999d9,       jfp)
c
      call UNEsiF(iErr, '    ', -99,              jfp)
      call UNEsoF(iErr, '    ', .false.,          jfp)
      call UNEsaF(iErr, '    ', 'TEXT TEXT TEXT', jfp)
      call UNEssF(iErr, '    ', -999.999d9,       jfp)
      call UNEsfF(iErr, '    ', -999.999e9,       jfp)
      call UNEsfF(iErr, '    ', -978.e0,          jfp)
c
      do j = 1, LVA
         IVa (j) = ((-1) ** j) * (j * j)
      enddo
      call UNEaiF(iErr, 'IARRAY(F)', IVa, 0, 4, jfp)
c
      do N = 4, LVA, 4
         kPOS = 0
         NL   = -1
         call UNEaiS(iErr, kPOS, StrM, NL, 'IARRAY(S)', IVa, N)
 101     format (I3, 1x, I3, 1x, I3, 1x, '[', A, ']')
         write (*, 101) iErr, NL, N, StrM (1:kPOS)
      enddo
      iErr = 0
      RETURN
      END
CCC_  & UNTEST_unc_suite
      subroutine UNTEST_unc_suite
     $     (iErr, Str, KD, AD)
CCC_   . Declaration
      implicit none
      _INTENT(OUT,integer)     iErr
      _INTENT(OUT,character)   Str*(*)
      _INTENT(INOUT,integer)   KD(*)
      _INTENT(INOUT,character) AD(*)*(*)
c
      character  Tag*(16)
      integer    kPOS
      integer    LVA
      parameter (LVA = 16)
      integer    IVa (LVA)
      integer    j
      integer    lstr
      integer    jfp
CCC_   . Body
      iErr = 0
      call UDSquo(jfp, KD)
c
      lstr = len (Str)
      call UDSopn(iErr, KD, AD, 0, 'CHOICE:')
      call UDSmai(iErr, KD, AD, 0, 0, 'LEN=', lstr)

      Tag = 'NICHK3'
      call UNCbgn(iErr, kPOS, Str, Tag, jfp)
c
      call UNCint(iErr, kPOS, Str, 'INT', -99,    jfp)
      call UNCint(iErr, kPOS, Str, 'INT', -99999, jfp)
c
      do j = 1, LVA
         IVa (j) = ((-1) ** j) * (j * j)
      enddo
      call UNCina(iErr, kPOS, Str, 'IAR0', IVA, LVA, 0,  jfp)
      call UNCina(iErr, kPOS, Str, 'IAR8', IVA, LVA, -1, jfp)
c
      call UNCend(iErr, kPOS, Str, Tag, jfp)
c
      RETURN
      END
CCC_ & UNTEST_choice
      subroutine UNTEST_choice (iErr, KLVL,  KD,AD)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   KLVL
      _INTENT(INOUT,integer)   KD(*)
      _INTENT(INOUT,character) AD(*)*(*)
      character  StrL*(256), StrM*(32), StrS*(3)
CCC_  - Body
      iErr = 0
c
      if (iErr.eq.0) call UDSnew(iErr, KD, AD, 0, 'CHOICE')
      if (iErr.eq.0) call UDSset(iErr, KD, AD, +1)
c
      call UNTEST_unc_suite(iErr, StrS, KD, AD)
      call UNTEST_unc_suite(iErr, StrM, KD, AD)
      call UNTEST_unc_suite(iErr, StrL, KD, AD)

      if (iErr.eq.0) call UDSset(iErr, KD, AD, -1)
c
      RETURN
      END
CCC_  & UNTEST_unb_suite
      subroutine UNTEST_unb_suite
     $     (iErr, KD, AD, LVEML)
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,integer)   KD(*)
      _INTENT(INOUT,character) AD(*)*(*)
      _INTENT(IN,   integer)   LVEML
      character  Tag*(16)
      integer    jfp
c
      integer    LIV
      parameter (LIV = 16)
      integer    IVa (LIV)
      integer    LAV
      parameter (LAV = 8)
      character  AVa(LAV)*(16)
      integer    LSV
      parameter (LSV = 12)
      _REALSTD   SVa(LSV)
c$$$      _REALF     FVa(LSV)
c$$$      _REALD     DVa(LSV)
c
      integer    j
      integer    jsw
c
      iErr = 0
      call UDSquo(jfp, KD)
c
      call UDSopn(iErr, KD, AD, 0, 'BUFFER:')
      call UDSmai(iErr, KD, AD, 0, 0, 'LVEML=', LVEML)
c
      do j = 1, LIV
         IVa (j) = ((-1) ** j) * (j * j)
      enddo
c
 301  format ('TEST', 1x, I3.3)
      do j = 1, LAV
         write (AVa(j), 301) j
      enddo
c
      do j = 1, LSV
         SVa(j) = SQRT(_XREALS(j))
c$$$         FVa(j) = SQRT(_XREALF(j))
c$$$         DVa(j) = SQRT(_XREALD(j))
      enddo
c
      Tag = 'NICHKB'
      jsw = LVEML
      call UNBbgn(iErr, Tag,                   jfp, LVEML)
      call UNBint(iErr, 'LVEML', JSW,          jfp, LVEML)
      call UNBint(iErr, 'INT',   -99,          jfp, LVEML)
      call UNBint(iErr, 'INT',   -99,          jfp, LVEML)
      call UNBrst(iErr, 'RST',   123.d4,       jfp, LVEML)
      call UNBstq(iErr, 'SKP',   ' ',          jfp, LVEML)
      call UNBstq(iErr, 'NSKP',  'NSKP',       jfp, LVEML)
      call UNBina(iErr, 'IAR0',  IVA, LIV, 0,  jfp, LVEML)
      call UNBina(iErr, 'IAR8',  IVA, LIV, 16, jfp, LVEML)
      call UNBsta(iErr, 'AVA',   AVA, LAV, 16, jfp, LVEML)
      call UNBrsa(iErr, 'SVA',   SVA, LSV, 16, jfp, LVEML)
      call UNBint(iErr, 'INT',   -99,          jfp, LVEML)
      call UNBend(iErr, Tag,                   jfp, LVEML)
c
      Tag = 'NICHKB2'
c
      jsw = LVEML
      call UNBbgn(iErr, Tag,                   jfp, LVEML)
      call UNBint(iErr, 'LVEML', JSW,          jfp, LVEML)
      call UNBint(iErr, 'INT',   -99,          jfp, LVEML)
      call UNBint(iErr, 'INT',   -99,          jfp, LVEML)
      call UNBina(iErr, 'IAR0',  IVA, LIV, 0,  jfp, LVEML)
      call UNBina(iErr, 'IAR8',  IVA, LIV, 0,  jfp, LVEML)
      call UNBsta(iErr, 'AVA',   AVA, LAV, 0,  jfp, LVEML)
      call UNBrsa(iErr, 'SVA',   SVA, LSV, 0,  jfp, LVEML)
      call UNBend(iErr, Tag,                   jfp, LVEML)
c
      RETURN
      END
CCC_ & UNTEST_buffer
      subroutine UNTEST_buffer (iErr, KLVL,  KD,AD)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   KLVL
      _INTENT(INOUT,integer)   KD(*)
      _INTENT(INOUT,character) AD(*)*(*)
CCC_  - Body
      iErr = 0
      if (iErr.eq.0) call UDSnew(iErr, KD, AD, 0, 'BUFFER')
      if (iErr.eq.0) call UDSset(iErr, KD, AD, +1)
c
      call UNTEST_unb_suite(iErr, KD,AD, _UNMLEM_LEVEL_END)
      call UNTEST_unb_suite(iErr, KD,AD, _UNMLEM_LEVEL_ENTRY)
      call UNTEST_unb_suite(iErr, KD,AD, _UNMLEM_LEVEL_ELEMENT)

      if (iErr.eq.0) call UDSset(iErr, KD, AD, -1)
c
      RETURN
      END
CCC_ & UNTEST_ctrl
      subroutine UNTEST_ctrl (iErr, KLVL,  KD,AD)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   KLVL
      _INTENT(INOUT,integer)   KD(*)
      _INTENT(INOUT,character) AD(*)*(*)
CCC_  - Body
      iErr = 0
      if (iErr.eq.0) then
         call UNTEST_prm_file(iErr, KLVL, KD, AD)
      endif
      if (iErr.eq.0) then
         call UNTEST_prm_string(iErr, KLVL, KD, AD)
      endif
      if (iErr.eq.0) then
         call UNTEST_entry(iErr, KLVL, KD, AD)
      endif
      if (iErr.eq.0) then
         call UNTEST_choice(iErr, KLVL, KD, AD)
      endif
      if (iErr.eq.0) then
         call UNTEST_buffer(iErr, KLVL, KD, AD)
      endif
      RETURN
      END
#endif /* TEST_UNMLEM || WITH_TEST_UNMLEM */
CCC_ + end subroutine
CCC_ @ UNtest  ## Unison/Namelist emulation test
#if    TEST_UNMLEM
      program UNtest
CCC_  - Test suites
CC::   SOURCES uuioms.F udbgst.F ustrmn.F
CCC_  - Declaration
      implicit none
      integer    iErr
      integer    iplog
CCC_   . debug section
      integer    LDK, LDA
      parameter (LDK = 32, LDA = 24)
      integer    KD(LDK)
      character  AD(LDA)*(128)
#include "orevan.h" /* 0 */
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
CCC_  - Body
      iErr  = 0
      iplog = -1
CCC_   . announcement
#define _ANNOUNCE UNMLEM
#define _LEXT     9999
#include "orevan.h" /* 1 */
CCC_   . test invocation
      call UDSbnm('UNMLEM TESTS', '#', 0, iplog)
      call UDSini(iErr, KD, AD, LDK, LDA, iplog)
      call UNTEST_ctrl(iErr, 0,  KD, AD)
      call UDSbnm('UNMLEM TESTS FINE','#', 0, iplog)
CCC_   . fine
      STOP
      END
CCC_ + end
#endif /* TEST_UNMLEM */
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
