C unison/uuioms.F --- IcIES/Unison/IO file manipulation
C Maintainer:  SAITO Fuyuki
C Created: Feb 2 2003
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2018/11/13 09:19:43 fuyuki uuioms.F>'
#define _FNAME 'unison/uuioms.F'
#define _REV   'Snoopy0.9'
CCC_! MANIFESTO
C
C Copyright (C) 2010--2020
C           Japan Agency for Marine-Earth Science and Technology,
C           Ayako ABE-OUCHI
C
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
CCC_* Macros
#include "ofdlct.h" /* fortran dialect */
#include "ologfm.h" /* logging */
CCC_ + path name
#ifndef    OPT_FILENAME_MAX
#  define  OPT_FILENAME_MAX 1024
#endif
CCC_ + standard units
#ifndef    OPT_STDOUT_UNIT
#  define  OPT_STDOUT_UNIT -9
#endif
#ifndef    OPT_STDERR_UNIT
#  define  OPT_STDERR_UNIT -9
#endif
#ifndef    OPT_STDIN_UNIT
#  define  OPT_STDIN_UNIT  -9
#endif
#ifndef    OPT_INVALID_UNIT
#  define  OPT_INVALID_UNIT -99
#endif
#ifndef    OPT_IOUNIT_START
#  define  OPT_IOUNIT_START 0
#endif
#ifndef    OPT_IOUNIT_END
#  define  OPT_IOUNIT_END   99
#endif
CCC_ + fortran
#ifndef    HAVE_DIRECT_ACCESS_POSITION
#  define  HAVE_DIRECT_ACCESS_POSITION 0
#endif
#ifndef    HAVE_F77_ISATTY
# define   HAVE_F77_ISATTY 0
#endif
CCC_ + misc
#ifndef    OPT_UUCOPY_LINE_LENGTH
#  define  OPT_UUCOPY_LINE_LENGTH 4096
#endif
#ifndef    OPT_MAX_TRY_UULENU
#  define  OPT_MAX_TRY_UULENU 16
#endif
CCC_ + IOSTAT cache table
#define IOSC_EOF          1
#define IOSC_NO_RECORD    2
#define IOSC_EOR          3
#define IOSC_MAX          3
CCC_ + misc attributes
#define _CONFIG_DEFAULT 0 /* configuration kind default */
#define _UNIT_NEVER -1 /* flag for non-available unit */
#define _UNIT_AVAIL  0 /* flag for available unit */
CCC_& UUdefU  ## Unison/IO file system-dependent standard units
      subroutine UUdefU (IP,  CH)
CCC_ + Declaration
      implicit none
CCC_  = Parameter
      integer    PiUNT, PeUNT, PoUNT
      parameter (PiUNT = OPT_STDIN_UNIT)
      parameter (PoUNT = OPT_STDOUT_UNIT)
      parameter (PeUNT = OPT_STDERR_UNIT)
      integer    PinvU
      parameter (PinvU = OPT_INVALID_UNIT)
CCC_  = Arguments
      _INTENT(OUT,integer)   IP
      _INTENT(IN, character) CH*(*)
CCC_  = Save
      integer   jpI, jpO, jpE
      save      jpI, jpO, jpE
      data      jpI, jpO, jpE / PiUNT, PoUNT, PeUNT /
      integer   jpInv
      save      jpInv
      data      jpInv / PinvU /
CCC_  = Interior
      character TCH
CCC_ + Body
      TCH = CH
      if      (TCH (1:1) .eq. 'I') then
         IP = jpI
      else if (TCH (1:1) .eq. 'O') then
         IP = jpO
      else if (TCH (1:1) .eq. 'E') then
         IP = jpE
      else
         IP = jpInv
      endif
      RETURN
      END
CCC_* File open
CCC_ & UUopnS  ## Unison/IO file open (scratch)
      subroutine UUopnS
     O    (IOS,
     I     IU,  IRL, FRM)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IU
      _INTENT(IN, integer)   IRL
      _INTENT(IN, character) FRM*(*)
CCC_  - Body
      call UUopen (IOS, IU, ' ', IRL, FRM, 'SCRATCH', 'READWRITE', ' ')
      RETURN
      END
CCC_ & UUopOC  ## Unison/IO file open (old or create)
      subroutine UUopOC
     O    (IOS,
     I     IU,   FNM, IRL, FRM, ACT, POS)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IU
      _INTENT(IN, character) FNM*(*)
      _INTENT(IN, integer)   IRL
      _INTENT(IN, character) FRM*(*), ACT*(*), POS*(*)
      logical Oex
CCC_  - Body
      IOS = 0
      call UUqfex (IOS, Oex,  FNM)
      if (IOS.eq.0) then
         if (Oex) then
            call UUopen (IOS, IU, FNM, IRL, FRM, 'O', ACT, POS)
         else
            call UUopen (IOS, IU, FNM, IRL, FRM, 'N', ACT, POS)
         endif
      endif
      RETURN
      END
CCC_ & UUopnN  ## Unison/IO file open (new or error if exists)
      subroutine UUopnN
     O    (IOS,
     I     IU,  FNM, IRL, FRM, ACT, POS)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IU
      _INTENT(IN, character) FNM*(*)
      _INTENT(IN, integer)   IRL
      _INTENT(IN, character) FRM*(*), ACT*(*), POS*(*)
      logical OEX
CCC_  - Body
      IOS = 0
      call UUqfex (IOS, OEX, FNM)
      if (IOS.eq.0) then
         if (OEX) then
            IOS = -1
         else
            call UUopen
     O          (IOS,
     I           IU,  FNM, IRL, FRM, 'NEW', ACT, POS)
         endif
      endif
      RETURN
      END
CCC_ & UUopnC  ## Unison/IO file open (new or clobber)
      subroutine UUopnC
     O    (IOS,
     I     IU,  FNM, IRL, FRM, ACT, POS)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IU
      _INTENT(IN, character) FNM*(*)
      _INTENT(IN, integer)   IRL
      _INTENT(IN, character) FRM*(*), ACT*(*), POS*(*)
CCC_  - Body
      IOS = 0
      call UUopen
     O    (IOS,
     I     IU,  FNM, IRL, FRM, 'REPLACE', ACT, POS)
      RETURN
      END
CCC_ & UUopnQ  ## Unison/IO file open (or inquire unit)
      subroutine UUopnQ
     O    (IOS,  IU,
     I     FNM,  IRL, FRM, STT, ACT, POS)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(OUT,integer)   IU
      _INTENT(IN, character) FNM*(*)
      _INTENT(IN, integer)   IRL
      _INTENT(IN, character) FRM*(*), STT*(*), ACT*(*), POS*(*)
CCC_  - Body
      call UUqnun (IOS, IU, FNM)
      if (IU.lt.0) then
         call UUMCnu (IOS, IU)
         if (IOS.eq.0 .and. IU.ge.0) then
            call UUopen (IOS, IU, FNM, IRL, FRM, STT, ACT, POS)
         endif
         if (IOS.ne.0) IU = -1
      else
         call UUchkC (IOS, IU, IRL, FRM, ACT, POS)
      endif
      RETURN
      END
CCC_ & UUopen  ## Unison/IO file open core
      subroutine UUopen
     O    (IOS,
     I     IU,  FNM,  IRL, FRM, STT, ACT, POS)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IU
      _INTENT(IN, character) FNM*(*)
      _INTENT(IN, integer)   IRL
      _INTENT(IN, character) FRM*(*), STT*(*), ACT*(*), POS*(*)
      character TFORM*(20), TSTAT*(20), TACTI*(20)
      character TACCE*(20), TCASE*(20), TPOSI*(20)
CCC_  - Body
CCC_   . Status
      call UUZstt (TSTAT,          STT)
CCC_   . Action
      call UUZact (TACTI,          ACT)
CCC_   . Access and Form
      call UUZacf (TACCE, TFORM,   IRL, FRM)
CCC_   . Position
      call UUZpos (TPOSI,          POS)
CCC_   . Set case identifier
CC    total 8 cases: D--, D-P, DS-, DSP, S--, S-P, SS-, SSP
      TCASE = '---'
      TCASE (1:1) = TACCE (1:1)
      if (TSTAT (1:1).eq.'S') TCASE (2:2) = 'S'
      if (TPOSI.ne.' ')       TCASE (3:3) = 'P'
      if (HAVE_DIRECT_ACCESS_POSITION.eq.0) then
         if (TCASE (1:1).eq.'D') TCASE (3:3) = '-'
      endif
CCC_   . Open Direct
CCC_    * Direct
      if      (TCASE .eq. 'D--') then
         OPEN (IOSTAT  = IOS,
     $        UNIT     = IU,
     $        FILE     = FNM,
     $        ACCESS   = TACCE, RECL = IRL,
     $        STATUS   = TSTAT,
     $        ACTION   = TACTI,
     $        FORM     = TFORM)
CCC_    * MAYBE ILLEGAL: Direct/position
      else if (TCASE .eq. 'D-P') then
         OPEN (IOSTAT  = IOS,
     $        UNIT     = IU,
     $        FILE     = FNM,
     $        POSITION = TPOSI,
     $        ACCESS   = TACCE, RECL = IRL,
     $        STATUS   = TSTAT,
     $        ACTION   = TACTI,
     $        FORM     = TFORM)
CCC_    * Direct/scratch
      else if (TCASE .eq. 'DS-') then
         OPEN (IOSTAT  = IOS,
     $        UNIT     = IU,
     $        ACCESS   = TACCE, RECL = IRL,
     $        STATUS   = TSTAT,
     $        ACTION   = TACTI,
     $        FORM     = TFORM)
CCC_    * MAYBE ILLEGAL: Direct/scratch/position
      else if (TCASE .eq. 'DSP') then
         OPEN (IOSTAT  = IOS,
     $        UNIT     = IU,
     $        POSITION = TPOSI,
     $        ACCESS   = TACCE, RECL = IRL,
     $        STATUS   = TSTAT,
     $        ACTION   = TACTI,
     $        FORM     = TFORM)
CCC_   . Open Sequential
CCC_    * Sequential
      else if (TCASE .eq. 'S--') then
         OPEN (IOSTAT  = IOS,
     $        UNIT     = IU,
     $        FILE     = FNM,
     $        ACCESS   = TACCE,
     $        STATUS   = TSTAT,
     $        ACTION   = TACTI,
     $        FORM     = TFORM)
CCC_    * Sequential/position
      else if (TCASE .eq. 'S-P') then
         OPEN (IOSTAT  = IOS,
     $        UNIT     = IU,
     $        FILE     = FNM,
     $        POSITION = TPOSI,
     $        ACCESS   = TACCE,
     $        STATUS   = TSTAT,
     $        ACTION   = TACTI,
     $        FORM     = TFORM)
CCC_    * Sequential/scratch
      else if (TCASE .eq. 'SS-') then
         OPEN (IOSTAT  = IOS,
     $        UNIT     = IU,
     $        ACCESS   = TACCE,
     $        STATUS   = TSTAT,
     $        ACTION   = TACTI,
     $        FORM     = TFORM)
CCC_    * MAYBE ILLEGAL: Sequential/scratch/position
      else if (TCASE .eq. 'SSP') then
         OPEN (IOSTAT  = IOS,
     $        UNIT     = IU,
     $        POSITION = TPOSI,
     $        ACCESS   = TACCE,
     $        STATUS   = TSTAT,
     $        ACTION   = TACTI,
     $        FORM     = TFORM)
CCC_   . Error
      else
         IOS = 999
      endif
C
      RETURN
      END
CCC_* File attributes
CCC_ & UUchkC  ## Unison/IO check file attribute consistency
      subroutine UUchkC
     O    (IOS,
     I     IU,  IRL, FRM, ACT, POS)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IU
      _INTENT(IN, integer)   IRL
      _INTENT(IN, character) FRM*(*), ACT*(*), POS*(*)
      character TFORM*(20), CFORM*(20)
      character TACTI*(20), CACTI*(20)
      character TACCE*(20), CACCE*(20)
      integer   IRLC
CCC_  - Body
      call UUZact (TACTI,          ACT)
      call UUZacf (TACCE, TFORM,   IRL, FRM)
c
      CACCE = ' '
      CACTI = ' '
      CFORM = ' '
      IRLC  = 0
      call UUquae (IOS, CACCE, IU)
      if (IOS.eq.0) call UUquat (IOS, CACTI, IU)
      if (IOS.eq.0) call UUqufo (IOS, CFORM, IU)
      if (IOS.eq.0) call UUqurl (IOS, IRLC,  IU)
c
      if (IOS.eq.0) then
         if (TACTI.ne.CACTI) IOS = IOS + 1
         if (TACCE.ne.CACCE) IOS = IOS + 1
         if (TFORM.ne.CFORM) IOS = IOS + 1
         if (IRL.gt.0) then
            if (IRL.ne.IRLC) IOS = IOS + 1
         else
            if (IRLC.gt.0)   IOS = IOS + 1
         endif
      endif
CC       Dummy statements
      if (POS.eq.' ') continue
      RETURN
      END
CCC_ & UUZstt  ## Unison/IO/utility status string
      subroutine UUZstt
     O    (StrO,
     I     StrI)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,character) StrO*(*)
      _INTENT(IN, character) StrI*(*)
CCC_  - Body
      if      (StrI (1:1) .eq. 'O') then
         StrO = 'OLD'
      else if (StrI (1:1) .eq. 'N') then
         StrO = 'NEW'
      else if (StrI (1:1) .eq. 'R') then
         StrO = 'REPLACE'
      else if (StrI (1:1) .eq. 'S') then
         StrO = 'SCRATCH'
      else
         StrO = 'UNKNOWN'
      endif
      RETURN
      END
CCC_ & UUZpos  ## Unison/IO/utility position string
      subroutine UUZpos
     O    (StrO,
     I     StrI)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,character) StrO*(*)
      _INTENT(IN, character) StrI*(*)
CCC_  - Body
      if      (StrI (1:1) .eq. 'A') then
         StrO = 'APPEND'
      else if (StrI (1:1) .eq. 'R') then
         StrO = 'REWIND'
      else
         StrO = StrI
      endif
      RETURN
      END
CCC_ & UUZact  ## Unison/IO/utility action string
      subroutine UUZact
     O    (StrO,
     I     StrI)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,character) StrO*(*)
      _INTENT(IN, character) StrI*(*)
CCC_  - Body
      StrO = ' '
      if (StrI .eq. 'READ'
     $     .or. StrI .eq. 'WRITE'
     $     .or. StrI .eq. 'READWRITE') then
         StrO = StrI
      else if (len (StrI) .ge. 2) then
         if (StrI (1:2) .eq. 'RW'
     $        .or. StrI (1:2) .eq. 'WR') then
            StrO = 'READWRITE'
         endif
      endif
      if (StrO .eq. ' ') then
         if (StrI (1:1) .eq. 'R') then
            StrO = 'READ'
         else if (StrI (1:1) .eq. 'W') then
            StrO = 'WRITE'
         else
            StrO = 'READWRITE'
         endif
      endif
      RETURN
      END
CCC_ & UUZacf  ## Unison/IO/utility access/format strings
      subroutine UUZacf
     O    (StrA, StrF,
     I     IRCL, StrI)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,character) StrA*(*), StrF*(*)
      _INTENT(IN, character) StrI*(*)
      _INTENT(IN, integer)   IRCL
CCC_  - Body
      if (IRCL.gt.0) then
         StrA = 'DIRECT'
CCC_    * unformatted is default
         if (StrI (1:1) .eq. 'F') then
            StrF = 'FORMATTED'
         else
            StrF = 'UNFORMATTED'
         endif
CCC_   . sequential access if RECL <= 0
      else
         StrA = 'SEQUENTIAL'
CCC_    * formatted is default
         if (StrI (1:1) .eq. 'U') then
            StrF = 'UNFORMATTED'
         else
            StrF = 'FORMATTED'
         endif
      endif
      RETURN
      END
CCC_ & UUinqA  ## Unison/IO inquire attributes string
      subroutine UUinqA
     O    (IOS, CATTR,
     I     IU)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(OUT,character) CATTR*(*)
      _INTENT(IN, integer)   IU
      character STR*(32)
      integer   IRLC
CCC_  - Body
      IOS = 0
      CATTR = ' '
      if (IOS.eq.0) call UUquae (IOS, STR, IU)
      if (IOS.eq.0) CATTR (1:1) = STR (1:1)
      if (IOS.eq.0) call UUquat (IOS, STR, IU)
      if (IOS.eq.0) CATTR (2:2) = STR (1:1)
      if (IOS.eq.0) call UUqufo (IOS, STR, IU)
      if (IOS.eq.0) CATTR (3:3) = STR (1:1)
      if (IOS.eq.0) call UUqurl (IOS, IRLC,  IU)
      if (IOS.eq.0) then
         if (IRLC.gt.0) then
            CATTR (4:4) = 'S'
         else
            write (STR, '(I12.12)') IRLC
            CATTR (4:15) = STR (1:12)
         endif
      endif
      RETURN
      END
CCC_* File close
CCC_ & UUclsF  ## Unison/IO force close files
      subroutine UUclsF
     O    (iErr,
     I     IU0, IU9,  IFPlog)
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(IN, integer) IU0, IU9
      _INTENT(IN, integer) IFPlog
      integer   ju, ju0, ju9
      character FNM*(OPT_FILENAME_MAX)
      logical   OPND, ONMD
      integer   jos
c
      iErr = 0
      ju0  = IU0
      ju9  = IU9
      if (ju0.lt.0)   ju0 = OPT_IOUNIT_START
      if (ju9.lt.ju0) ju9 = OPT_IOUNIT_END
 101  format ('UUCLSF FORCE CLOSE[', I3, '] ', I7, 1x, A)
      do ju = ju0, ju9
         call UUquop (jos, OPND, ju)
         if (jos.eq.0) then
            if (OPND) then
               call UUqunm (jos, ONMD, FNM, ju)
               if (.not.ONMD) FNM = '(no name)'
               call UUclsC (jos, ju, FNM, ' ')
               if (COND_N(IFPlog)) then
                  write (IFPlog, 101) ju, jos, _TRIM(FNM)
               else if (COND_S(IFPlog)) then
                  write (*,      101) ju, jos, _TRIM(FNM)
               endif
               if (jos.ne.0) iErr = iErr + 1
            endif
         else
            iErr = iErr + 1
         endif
      enddo
      iErr = - iErr
      RETURN
      END
CCC_ & UUclsC  ## Unison/IO close file core
      subroutine UUclsC
     O    (IOS,
     I     IU,  FNM,  STT)
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IU
      _INTENT(IN, character) STT*(*)
CCC_    * for future extension
      _INTENT(IN, character) FNM*(*)
CCC_   = Interior
      character TSTAT*(20)
CCC_  - Body
CCC_   . status check
      if      (STT (1:1) .eq. 'D') then
         TSTAT = 'DELETE'
      else if (STT (1:1) .eq. 'K') then
         TSTAT = 'KEEP'
      else
         TSTAT = ' '
      endif
CCC_   . To do: file name check
      if (FNM .ne. ' ') then
         continue
      endif
CCC_   . close file
      if (TSTAT .eq. ' ') then
         CLOSE (IOSTAT = IOS, UNIT = IU)
      else
         CLOSE (IOSTAT = IOS, UNIT = IU, STATUS = TSTAT)
      endif
c
      RETURN
      END
CCC_& UUmngC  ## Unison/IO unit management core
      subroutine UUmngC (iErr)
CCC_ + Declaration
      implicit none
CCC_  = Parameter
      integer    IUstt, IUend, MIU
      parameter (IUstt = OPT_IOUNIT_START)
      parameter (IUend = OPT_IOUNIT_END)
      parameter (MIU   = IUend - IUstt + 1)
CCC_  = Arguments
      _INTENT(IN,   integer) KcfgD
      _INTENT(INOUT,integer) IU
      _INTENT(IN,   integer) Iflg
      _INTENT(OUT,  integer) iErr
CCC_  = Save
      integer    IUflg (IUstt:IUend)
      save       IUflg
      data       IUflg  / MIU * _UNIT_AVAIL /
c
      integer    IUcur
      save       IUcur
      data       IUcur / IUstt /
c
      logical    OFIRST
      save       OFIRST
      data       OFIRST / .true. /
CCC_  = Interior
      integer ju, k
      logical OUSD
      integer IOS
CCC_ + Body
      iErr = 0
      RETURN
CCC_ & UUmngI  ## Unison/IO unit management core initialization
      entry  UUmngI (KcfgD)
      if (OFIRST) then
CCC_  - Default:  unit 0..9, 90..99 is never used
         if (KcfgD .eq. _CONFIG_DEFAULT) then
            do ju = MAX (0, IUstt), MIN (9, IUend)
               IUflg (ju) = _UNIT_NEVER
            enddo
            do ju = MAX (90, IUstt), MIN (99, IUend)
               IUflg (ju) = _UNIT_NEVER
            enddo
         endif
         OFIRST = .false.
      endif
      return
CCC_ & UUMCsf  ## Unison/IO unit management core set flag
      entry UUMCsf (IU, Iflg)
      if (IUstt.le.IU .and. IU.le.IUend) then
         if (Iflg .ne. _UNIT_AVAIL) then
            IUflg (IU) = _UNIT_NEVER
         else
            IUflg (IU) = Iflg
         endif
      endif
      return
CCC_ & UUMCnu  ## Unison/IO unit management core get new unit
      entry UUMCnu (iErr, IU)
c
      IU = IUstt - 1
c
      do k = 0, MIU - 1
         ju = IUcur + k
         if (ju .gt. IUend) ju = IUstt + (ju - IUend) - 1
         if (IUflg (ju) .eq. _UNIT_AVAIL) then
            OUSD = .true.
            call UUquop (IOS, OUSD, ju)
            if (.not.OUSD) then
               IU = JU
               goto 900
            endif
         endif
      enddo
 900  continue
c
      if (IU.lt.IUstt) then
         iErr  = -1
      else
         iErr  = 0
         IUcur = JU + 1
      endif
c
      RETURN
CCC_ + End (UUmngC)
      END
CCC_* Write/Read wrappers
CCC_ + [I] write/integer
CCC_  & UUwwFI  ## Unison/IO write wrapper (Format/integer)
      subroutine UUwwFI
     O    (IOS,
     I     IP,  F, N, IV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, character) F*(*)
      _INTENT(IN, integer)   N
      _INTENT(IN, integer)   IV (N)
      write (UNIT = IP, IOSTAT = IOS, FMT = F) IV
      RETURN
      END
CCC_  & UUwwSI  ## Unison/IO write wrapper (*/integer)
      subroutine UUwwSI
     O    (IOS,
     I     IP,  N, IV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   N
      _INTENT(IN, integer)   IV (N)
      write (UNIT = IP, IOSTAT = IOS, FMT = *) IV
      RETURN
      END
CCC_  & UUwwUI  ## Unison/IO write wrapper (unformatted/seq/integer)
      subroutine UUwwUI
     O    (IOS,
     I     IP,  N, IV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   N
      _INTENT(IN, integer)   IV (N)
      write (UNIT = IP, IOSTAT = IOS) IV
      RETURN
      END
CCC_  & UUwwRI  ## Unison/IO write wrapper (unformatted/direct/integer)
      subroutine UUwwRI
     O    (IOS,
     I     IP,  IR, N, IV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   IR
      _INTENT(IN, integer)   N
      _INTENT(IN, integer)   IV (N)
      write (UNIT = IP, IOSTAT = IOS, REC = IR) IV
      RETURN
      END
CCC_  & UUwwDI  ## Unison/IO write wrapper (formatted/direct/integer)
      subroutine UUwwDI
     O    (IOS,
     I     IP,  IR, F, N, IV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   IR
      _INTENT(IN, character) F*(*)
      _INTENT(IN, integer)   N
      _INTENT(IN, integer)   IV (N)
      write (UNIT = IP, IOSTAT = IOS, REC = IR, FMT = F) IV
      RETURN
      END
CCC_ + [I] read/integer
CCC_  & UUwrFI  ## Unison/IO read wrapper (Format/integer)
      subroutine UUwrFI
     O    (IOS,
     I     IP,  F, N,
     O     IV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, character) F*(*)
      _INTENT(IN, integer)   N
      _INTENT(OUT,integer)   IV (N)
      read (UNIT = IP, IOSTAT = IOS, FMT = F) IV
      RETURN
      END
CCC_  & UUwrSI  ## Unison/IO read wrapper (*/integer)
      subroutine UUwrSI
     O    (IOS,
     I     IP,  N,
     O     IV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   N
      _INTENT(OUT,integer)   IV (N)
      read (UNIT = IP, IOSTAT = IOS, FMT = *) IV
      RETURN
      END
CCC_  & UUwrUI  ## Unison/IO read wrapper (unformatted/seq/integer)
      subroutine UUwrUI
     O    (IOS,
     I     IP,  N,
     o     IV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   N
      _INTENT(OUT,integer)   IV (N)
      read (UNIT = IP, IOSTAT = IOS) IV
      RETURN
      END
CCC_  & UUwrRI  ## Unison/IO read wrapper (unformatted/direct/integer)
      subroutine UUwrRI
     O    (IOS,
     I     IP,  IR, N,
     O     IV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   IR
      _INTENT(IN, integer)   N
      _INTENT(OUT,integer)   IV (N)
      read (UNIT = IP, IOSTAT = IOS, REC = IR) IV
      RETURN
      END
CCC_  & UUwrDI  ## Unison/IO read wrapper (formatted/direct/integer)
      subroutine UUwrDI
     O    (IOS,
     I     IP,  IR, F, N,
     O     IV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   IR
      _INTENT(IN, character) F*(*)
      _INTENT(IN, integer)   N
      _INTENT(OUT,integer)   IV (N)
      read (UNIT = IP, IOSTAT = IOS, REC = IR, FMT = F) IV
      RETURN
      END
CCC_ + [N] write/integer[4]
CCC_  & UUwwFN  ## Unison/IO write wrapper (Format/integer[4])
      subroutine UUwwFN
     O    (IOS,
     I     IP,  F, N, IV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, character) F*(*)
      _INTENT(IN, integer)   N
      _INTENT(IN, _INT32)    IV (N)
      write (UNIT = IP, IOSTAT = IOS, FMT = F) IV
      RETURN
      END
CCC_  & UUwwSN  ## Unison/IO write wrapper (*/integer[4])
      subroutine UUwwSN
     O    (IOS,
     I     IP,  N, IV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   N
      _INTENT(IN, _INT32)    IV (N)
      write (UNIT = IP, IOSTAT = IOS, FMT = *) IV
      RETURN
      END
CCC_  & UUwwUN  ## Unison/IO write wrapper (unformatted/seq/integer[4])
      subroutine UUwwUN
     O    (IOS,
     I     IP,  N, IV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   N
      _INTENT(IN, _INT32)    IV (N)
      write (UNIT = IP, IOSTAT = IOS) IV
      RETURN
      END
CCC_  & UUwwRN  ## Unison/IO write wrapper (unformatted/direct/integer[4])
      subroutine UUwwRN
     O    (IOS,
     I     IP,  IR, N, IV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   IR
      _INTENT(IN, integer)   N
      _INTENT(IN, _INT32)    IV (N)
      write (UNIT = IP, IOSTAT = IOS, REC = IR) IV
      RETURN
      END
CCC_  & UUwwDN  ## Unison/IO write wrapper (formatted/direct/integer[4])
      subroutine UUwwDN
     O    (IOS,
     I     IP,  IR, F, N, IV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   IR
      _INTENT(IN, character) F*(*)
      _INTENT(IN, integer)   N
      _INTENT(IN, _INT32)    IV (N)
      write (UNIT = IP, IOSTAT = IOS, REC = IR, FMT = F) IV
      RETURN
      END
CCC_ + [N] read/integer[4]
CCC_  & UUwrFN  ## Unison/IO read wrapper (Format/integer[4])
      subroutine UUwrFN
     O    (IOS,
     I     IP,  F, N,
     O     IV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, character) F*(*)
      _INTENT(IN, integer)   N
      _INTENT(OUT,_INT32)    IV (N)
      read (UNIT = IP, IOSTAT = IOS, FMT = F) IV
      RETURN
      END
CCC_  & UUwrSN  ## Unison/IO read wrapper (*/integer[4])
      subroutine UUwrSN
     O    (IOS,
     I     IP,  N,
     O     IV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   N
      _INTENT(OUT,_INT32)    IV (N)
      read (UNIT = IP, IOSTAT = IOS, FMT = *) IV
      RETURN
      END
CCC_  & UUwrUN  ## Unison/IO read wrapper (unformatted/seq/integer[4])
      subroutine UUwrUN
     O    (IOS,
     I     IP,  N,
     o     IV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   N
      _INTENT(OUT,_INT32)    IV (N)
      read (UNIT = IP, IOSTAT = IOS) IV
      RETURN
      END
CCC_  & UUwrRN  ## Unison/IO read wrapper (unformatted/direct/integer[4])
      subroutine UUwrRN
     O    (IOS,
     I     IP,  IR, N,
     O     IV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   IR
      _INTENT(IN, integer)   N
      _INTENT(OUT,_INT32)    IV (N)
      read (UNIT = IP, IOSTAT = IOS, REC = IR) IV
      RETURN
      END
CCC_  & UUwrDN  ## Unison/IO read wrapper (formatted/direct/integer[4])
      subroutine UUwrDN
     O    (IOS,
     I     IP,  IR, F, N,
     O     IV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   IR
      _INTENT(IN, character) F*(*)
      _INTENT(IN, integer)   N
      _INTENT(OUT,_INT32)    IV (N)
      read (UNIT = IP, IOSTAT = IOS, REC = IR, FMT = F) IV
      RETURN
      END
CCC_ + [L] write/integer[8]
#if HAVE_INTEGER_64_KIND
CCC_  & UUwwFL  ## Unison/IO write wrapper (Format/integer[8])
      subroutine UUwwFL
     O    (IOS,
     I     IP,  F, N, LV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, character) F*(*)
      _INTENT(IN, integer)   N
      _INTENT(IN, _INT64)    LV (N)
      write (UNIT = IP, IOSTAT = IOS, FMT = F) LV
      RETURN
      END
CCC_  & UUwwSL  ## Unison/IO write wrapper (*/integer[8])
      subroutine UUwwSL
     O    (IOS,
     I     IP,  N, LV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   N
      _INTENT(IN, _INT64)    LV (N)
      write (UNIT = IP, IOSTAT = IOS, FMT = *) LV
      RETURN
      END
CCC_  & UUwwUL  ## Unison/IO write wrapper (unformatted/seq/integer[8])
      subroutine UUwwUL
     O    (IOS,
     I     IP,  N, LV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   N
      _INTENT(IN, _INT64)    LV (N)
      write (UNIT = IP, IOSTAT = IOS) LV
      RETURN
      END
CCC_  & UUwwRL  ## Unison/IO write wrapper (unformatted/direct/integer[8])
      subroutine UUwwRL
     O    (IOS,
     I     IP,  IR, N, LV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   IR
      _INTENT(IN, integer)   N
      _INTENT(IN, _INT64)    LV (N)
      write (UNIT = IP, IOSTAT = IOS, REC = IR) LV
      RETURN
      END
CCC_  & UUwwDL  ## Unison/IO write wrapper (formatted/direct/integer[8])
      subroutine UUwwDL
     O    (IOS,
     I     IP,  IR, F, N, LV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   IR
      _INTENT(IN, character) F*(*)
      _INTENT(IN, integer)   N
      _INTENT(IN, _INT64)    LV (N)
      write (UNIT = IP, IOSTAT = IOS, REC = IR, FMT = F) LV
      RETURN
      END
CCC_ + [L] read/integer[8]
CCC_  & UUwrFL  ## Unison/IO read wrapper (Format/integer[8])
      subroutine UUwrFL
     O    (IOS,
     I     IP,  F, N,
     O     LV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, character) F*(*)
      _INTENT(IN, integer)   N
      _INTENT(OUT,_INT64)    LV (N)
      read (UNIT = IP, IOSTAT = IOS, FMT = F) LV
      RETURN
      END
CCC_  & UUwrSL  ## Unison/IO read wrapper (*/integer[8])
      subroutine UUwrSL
     O    (IOS,
     I     IP,  N,
     O     LV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   N
      _INTENT(OUT,_INT64)    LV (N)
      read (UNIT = IP, IOSTAT = IOS, FMT = *) LV
      RETURN
      END
CCC_  & UUwrUL  ## Unison/IO read wrapper (unformatted/seq/integer[8])
      subroutine UUwrUL
     O    (IOS,
     I     IP,  N,
     O     LV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   N
      _INTENT(OUT,_INT64)    LV (N)
      read (UNIT = IP, IOSTAT = IOS) LV
      RETURN
      END
CCC_  & UUwrRL  ## Unison/IO read wrapper (unformatted/direct/integer[8])
      subroutine UUwrRL
     O    (IOS,
     I     IP,  IR, N,
     O     LV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   IR
      _INTENT(IN, integer)   N
      _INTENT(OUT,_INT64)    LV (N)
      read (UNIT = IP, IOSTAT = IOS, REC = IR) LV
      RETURN
      END
CCC_  & UUwrDL  ## Unison/IO read wrapper (formatted/direct/integer[8])
      subroutine UUwrDL
     O    (IOS,
     I     IP,  IR, F, N,
     O     LV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   IR
      _INTENT(IN, character) F*(*)
      _INTENT(IN, integer)   N
      _INTENT(OUT,_INT64)    LV (N)
      read (UNIT = IP, IOSTAT = IOS, REC = IR, FMT = F) LV
      RETURN
      END
#endif /* HAVE_INTEGER_64_KIND */
CCC_ + [C] write/real
CCC_  & UUwwFC  ## Unison/IO write wrapper (Format/real)
      subroutine UUwwFC
     O    (IOS,
     I     IP,  F, N, CV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, character) F*(*)
      _INTENT(IN, integer)   N
      _INTENT(IN, real)      CV (N)
      write (UNIT = IP, IOSTAT = IOS, FMT = F) CV
      RETURN
      END
CCC_  & UUwwSC  ## Unison/IO write wrapper (*/real)
      subroutine UUwwSC
     O    (IOS,
     I     IP,  N, CV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   N
      _INTENT(IN, real)      CV (N)
      write (UNIT = IP, IOSTAT = IOS, FMT = *) CV
      RETURN
      END
CCC_  & UUwwUC  ## Unison/IO write wrapper (unformatted/seq/real)
      subroutine UUwwUC
     O    (IOS,
     I     IP,  N, CV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   N
      _INTENT(IN, real)      CV (N)
      write (UNIT = IP, IOSTAT = IOS) CV
      RETURN
      END
CCC_  & UUwwRC  ## Unison/IO write wrapper (unformatted/direct/real)
      subroutine UUwwRC
     O    (IOS,
     I     IP,  IR, N, CV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   IR
      _INTENT(IN, integer)   N
      _INTENT(IN, real)      CV (N)
      write (UNIT = IP, IOSTAT = IOS, REC = IR) CV
      RETURN
      END
CCC_  & UUwwDC  ## Unison/IO write wrapper (formatted/direct/real)
      subroutine UUwwDC
     O    (IOS,
     I     IP,  IR, F, N, CV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   IR
      _INTENT(IN, character) F*(*)
      _INTENT(IN, integer)   N
      _INTENT(IN, real)      CV (N)
      write (UNIT = IP, IOSTAT = IOS, REC = IR, FMT = F) CV
      RETURN
      END
CCC_ + [C] read/real
CCC_  & UUwrFC  ## Unison/IO read wrapper (Format/real)
      subroutine UUwrFC
     O    (IOS,
     I     IP,  F, N,
     O     CV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, character) F*(*)
      _INTENT(IN, integer)   N
      _INTENT(OUT,real)      CV (N)
      read (UNIT = IP, IOSTAT = IOS, FMT = F) CV
      RETURN
      END
CCC_  & UUwrSC  ## Unison/IO read wrapper (*/real)
      subroutine UUwrSC
     O    (IOS,
     I     IP,  N,
     O     CV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   N
      _INTENT(OUT,real)      CV (N)
      read (UNIT = IP, IOSTAT = IOS, FMT = *) CV
      RETURN
      END
CCC_  & UUwrUC  ## Unison/IO read wrapper (unformatted/seq/real)
      subroutine UUwrUC
     O    (IOS,
     I     IP,  N,
     O     CV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   N
      _INTENT(OUT,real)      CV (N)
      read (UNIT = IP, IOSTAT = IOS) CV
      RETURN
      END
CCC_  & UUwrRC  ## Unison/IO read wrapper (unformatted/direct/real)
      subroutine UUwrRC
     O    (IOS,
     I     IP,  IR, N,
     O     CV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   IR
      _INTENT(IN, integer)   N
      _INTENT(OUT,real)      CV (N)
      read (UNIT = IP, IOSTAT = IOS, REC = IR) CV
      RETURN
      END
CCC_  & UUwrDC  ## Unison/IO read wrapper (formatted/direct/real)
      subroutine UUwrDC
     O    (IOS,
     I     IP,  IR, F, N,
     O     CV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   IR
      _INTENT(IN, character) F*(*)
      _INTENT(IN, integer)   N
      _INTENT(OUT,real)      CV (N)
      read (UNIT = IP, IOSTAT = IOS, REC = IR, FMT = F) CV
      RETURN
      END
CCC_ + [S] write/real-standard
#ifdef _REALSTD
CCC_  & UUwwFS  ## Unison/IO write wrapper (Format/real-standard)
      subroutine UUwwFS
     O    (IOS,
     I     IP,  F, N, SV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, character) F*(*)
      _INTENT(IN, integer)   N
      _INTENT(IN, _REALSTD)  SV (N)
      write (UNIT = IP, IOSTAT = IOS, FMT = F) SV
      RETURN
      END
CCC_  & UUwwSS  ## Unison/IO write wrapper (*/real-standard)
      subroutine UUwwSS
     O    (IOS,
     I     IP,  N, SV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   N
      _INTENT(IN, _REALSTD)  SV (N)
      write (UNIT = IP, IOSTAT = IOS, FMT = *) SV
      RETURN
      END
CCC_  & UUwwUS  ## Unison/IO write wrapper (unformatted/seq/real-standard)
      subroutine UUwwUS
     O    (IOS,
     I     IP,  N, SV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   N
      _INTENT(IN, _REALSTD)  SV (N)
      write (UNIT = IP, IOSTAT = IOS) SV
      RETURN
      END
CCC_  & UUwwRS  ## Unison/IO write wrapper (unformatted/direct/real-standard)
      subroutine UUwwRS
     O    (IOS,
     I     IP,  IR, N, SV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   IR
      _INTENT(IN, integer)   N
      _INTENT(IN, _REALSTD)  SV (N)
      write (UNIT = IP, IOSTAT = IOS, REC = IR) SV
      RETURN
      END
CCC_  & UUwwDS  ## Unison/IO write wrapper (formatted/direct/real-standard)
      subroutine UUwwDS
     O    (IOS,
     I     IP,  IR, F, N, SV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   IR
      _INTENT(IN, character) F*(*)
      _INTENT(IN, integer)   N
      _INTENT(IN, _REALSTD)  SV (N)
      write (UNIT = IP, IOSTAT = IOS, REC = IR, FMT = F) SV
      RETURN
      END
CCC_ + [S] read/real-standard
CCC_  & UUwrFS  ## Unison/IO read wrapper (Format/real-standard)
      subroutine UUwrFS
     O    (IOS,
     I     IP,  F, N,
     O     SV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, character) F*(*)
      _INTENT(IN, integer)   N
      _INTENT(OUT,_REALSTD)  SV (N)
      read (UNIT = IP, IOSTAT = IOS, FMT = F) SV
      RETURN
      END
CCC_  & UUwrSS  ## Unison/IO read wrapper (*/real-standard)
      subroutine UUwrSS
     O    (IOS,
     I     IP,  N,
     O     SV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   N
      _INTENT(OUT,_REALSTD)  SV (N)
      read (UNIT = IP, IOSTAT = IOS, FMT = *) SV
      RETURN
      END
CCC_  & UUwrUS  ## Unison/IO read wrapper (unformatted/seq/real-standard)
      subroutine UUwrUS
     O    (IOS,
     I     IP,  N,
     O     SV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   N
      _INTENT(OUT,_REALSTD)  SV (N)
      read (UNIT = IP, IOSTAT = IOS) SV
      RETURN
      END
CCC_  & UUwrRS  ## Unison/IO read wrapper (unformatted/direct/real-standard)
      subroutine UUwrRS
     O    (IOS,
     I     IP,  IR, N,
     O     SV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   IR
      _INTENT(IN, integer)   N
      _INTENT(OUT,_REALSTD)  SV (N)
      read (UNIT = IP, IOSTAT = IOS, REC = IR) SV
      RETURN
      END
CCC_  & UUwrDS  ## Unison/IO read wrapper (formatted/direct/real-standard)
      subroutine UUwrDS
     O    (IOS,
     I     IP,  IR, F, N,
     O     SV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   IR
      _INTENT(IN, character) F*(*)
      _INTENT(IN, integer)   N
      _INTENT(OUT,_REALSTD)  SV (N)
      read (UNIT = IP, IOSTAT = IOS, REC = IR, FMT = F) SV
      RETURN
      END
#endif /* defined _REALSTD */
CCC_ + [D] write/double
CCC_  & UUwwFD  ## Unison/IO write wrapper (Format/double)
      subroutine UUwwFD
     O    (IOS,
     I     IP,  F, N, DV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, character) F*(*)
      _INTENT(IN, integer)   N
      _INTENT(IN, _REALD)    DV (N)
      write (UNIT = IP, IOSTAT = IOS, FMT = F) DV
      RETURN
      END
CCC_  & UUwwSD  ## Unison/IO write wrapper (*/double)
      subroutine UUwwSD
     O    (IOS,
     I     IP,  N, DV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   N
      _INTENT(IN, _REALD)    DV (N)
      write (UNIT = IP, IOSTAT = IOS, FMT = *) DV
      RETURN
      END
CCC_  & UUwwUD  ## Unison/IO write wrapper (unformatted/seq/double)
      subroutine UUwwUD
     O    (IOS,
     I     IP,  N, DV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   N
      _INTENT(IN, _REALD)    DV (N)
      write (UNIT = IP, IOSTAT = IOS) DV
      RETURN
      END
CCC_  & UUwwRD  ## Unison/IO write wrapper (unformatted/direct/double)
      subroutine UUwwRD
     O    (IOS,
     I     IP,  IR, N, DV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   IR
      _INTENT(IN, integer)   N
      _INTENT(IN, _REALD)    DV (N)
      write (UNIT = IP, IOSTAT = IOS, REC = IR) DV
      RETURN
      END
CCC_  & UUwwDD  ## Unison/IO write wrapper (formatted/direct/double)
      subroutine UUwwDD
     O    (IOS,
     I     IP,  IR, F, N, DV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   IR
      _INTENT(IN, character) F*(*)
      _INTENT(IN, integer)   N
      _INTENT(IN, _REALD)    DV (N)
      write (UNIT = IP, IOSTAT = IOS, REC = IR, FMT = F) DV
      RETURN
      END
CCC_ + [D] read/double
CCC_  & UUwrFD  ## Unison/IO read wrapper (Format/double)
      subroutine UUwrFD
     O    (IOS,
     I     IP,  F, N,
     O     DV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, character) F*(*)
      _INTENT(IN, integer)   N
      _INTENT(OUT,_REALD)    DV (N)
      read (UNIT = IP, IOSTAT = IOS, FMT = F) DV
      RETURN
      END
CCC_  & UUwrSD  ## Unison/IO read wrapper (*/double)
      subroutine UUwrSD
     O    (IOS,
     I     IP,  N,
     O     DV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   N
      _INTENT(OUT,_REALD)    DV (N)
      read (UNIT = IP, IOSTAT = IOS, FMT = *) DV
      RETURN
      END
CCC_  & UUwrUD  ## Unison/IO read wrapper (unformatted/seq/double)
      subroutine UUwrUD
     O    (IOS,
     I     IP,  N,
     o     DV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   N
      _INTENT(OUT,_REALD)    DV (N)
      read (UNIT = IP, IOSTAT = IOS) DV
      RETURN
      END
CCC_  & UUwrRD  ## Unison/IO read wrapper (unformatted/direct/double)
      subroutine UUwrRD
     O    (IOS,
     I     IP,  IR, N,
     O     DV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   IR
      _INTENT(IN, integer)   N
      _INTENT(OUT,_REALD)    DV (N)
      read (UNIT = IP, IOSTAT = IOS, REC = IR) DV
      RETURN
      END
CCC_  & UUwrDD  ## Unison/IO read wrapper (formatted/direct/double)
      subroutine UUwrDD
     O    (IOS,
     I     IP,  IR, F, N,
     O     DV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   IR
      _INTENT(IN, character) F*(*)
      _INTENT(IN, integer)   N
      _INTENT(OUT,_REALD)    DV (N)
      read (UNIT = IP, IOSTAT = IOS, REC = IR, FMT = F) DV
      RETURN
      END
CCC_ + [F] write/float
CCC_  & UUwwFF  ## Unison/IO write wrapper (Format/float)
      subroutine UUwwFF
     O    (IOS,
     I     IP,  F, N, FV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, character) F*(*)
      _INTENT(IN, integer)   N
      _INTENT(IN, _REALF)    FV (N)
      write (UNIT = IP, IOSTAT = IOS, FMT = F) FV
      RETURN
      END
CCC_  & UUwwSF  ## Unison/IO write wrapper (*/float)
      subroutine UUwwSF
     O    (IOS,
     I     IP,  N, FV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   N
      _INTENT(IN, _REALF)    FV (N)
      write (UNIT = IP, IOSTAT = IOS, FMT = *) FV
      RETURN
      END
CCC_  & UUwwUF  ## Unison/IO write wrapper (unformatted/seq/float)
      subroutine UUwwUF
     O    (IOS,
     I     IP,  N, FV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   N
      _INTENT(IN, _REALF)    FV (N)
      write (UNIT = IP, IOSTAT = IOS) FV
      RETURN
      END
CCC_  & UUwwRF  ## Unison/IO write wrapper (unformatted/direct/float)
      subroutine UUwwRF
     O    (IOS,
     I     IP,  IR, N, FV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   IR
      _INTENT(IN, integer)   N
      _INTENT(IN, _REALF)    FV (N)
      write (UNIT = IP, IOSTAT = IOS, REC = IR) FV
      RETURN
      END
CCC_  & UUwwDF  ## Unison/IO write wrapper (formatted/direct/float)
      subroutine UUwwDF
     O    (IOS,
     I     IP,  IR, F, N, FV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   IR
      _INTENT(IN, character) F*(*)
      _INTENT(IN, integer)   N
      _INTENT(IN, _REALF)    FV (N)
      write (UNIT = IP, IOSTAT = IOS, REC = IR, FMT = F) FV
      RETURN
      END
CCC_ + [F] read/float
CCC_  & UUwrFF  ## Unison/IO read wrapper (Format/float)
      subroutine UUwrFF
     O    (IOS,
     I     IP,  F, N,
     O     FV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, character) F*(*)
      _INTENT(IN, integer)   N
      _INTENT(OUT,_REALF)    FV (N)
      read (UNIT = IP, IOSTAT = IOS, FMT = F) FV
      RETURN
      END
CCC_  & UUwrSF  ## Unison/IO read wrapper (*/float)
      subroutine UUwrSF
     O    (IOS,
     I     IP,  N,
     O     FV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   N
      _INTENT(OUT,_REALF)    FV (N)
      read (UNIT = IP, IOSTAT = IOS, FMT = *) FV
      RETURN
      END
CCC_  & UUwrUF  ## Unison/IO read wrapper (unformatted/seq/float)
      subroutine UUwrUF
     O    (IOS,
     I     IP,  N,
     o     FV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   N
      _INTENT(OUT,_REALF)    FV (N)
      read (UNIT = IP, IOSTAT = IOS) FV
      RETURN
      END
CCC_  & UUwrRF  ## Unison/IO read wrapper (unformatted/direct/float)
      subroutine UUwrRF
     O    (IOS,
     I     IP,  IR, N,
     O     FV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   IR
      _INTENT(IN, integer)   N
      _INTENT(OUT,_REALF)    FV (N)
      read (UNIT = IP, IOSTAT = IOS, REC = IR) FV
      RETURN
      END
CCC_  & UUwrDF  ## Unison/IO read wrapper (formatted/direct/float)
      subroutine UUwrDF
     O    (IOS,
     I     IP,  IR, F, N,
     O     FV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   IR
      _INTENT(IN, character) F*(*)
      _INTENT(IN, integer)   N
      _INTENT(OUT,_REALF)    FV (N)
      read (UNIT = IP, IOSTAT = IOS, REC = IR, FMT = F) FV
      RETURN
      END
CCC_ + [M] write/integer[4]-double
CCC_  & UUwwFM  ## Unison/IO write wrapper (Format/integer[4]-double)
      subroutine UUwwFM
     O    (IOS,
     I     IP,  F, NI, ND, IV, DV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, character) F*(*)
      _INTENT(IN, integer)   NI, ND
      _INTENT(IN, _INT32)    IV (NI)
      _INTENT(IN, _REALD)    DV (ND)
      write (UNIT = IP, IOSTAT = IOS, FMT = F) IV, DV
      RETURN
      END
CCC_  & UUwwSM  ## Unison/IO write wrapper (*/integer[4]-double)
      subroutine UUwwSM
     O    (IOS,
     I     IP,  NI, ND, IV, DV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   NI, ND
      _INTENT(IN, _INT32)    IV (NI)
      _INTENT(IN, _REALD)    DV (ND)
      write (UNIT = IP, IOSTAT = IOS, FMT = *) IV, DV
      RETURN
      END
CCC_  & UUwwUM  ## Unison/IO write wrapper (unformatted/seq/integer[4]-double)
      subroutine UUwwUM
     O    (IOS,
     I     IP,  NI, ND, IV, DV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   NI, ND
      _INTENT(IN, _INT32)    IV (NI)
      _INTENT(IN, _REALD)    DV (ND)
      write (UNIT = IP, IOSTAT = IOS) IV, DV
      RETURN
      END
CCC_  & UUwwRM  ## Unison/IO write wrapper (unformatted/direct/integer[4]-double)
      subroutine UUwwRM
     O    (IOS,
     I     IP,  IR, NI, ND, IV, DV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   IR
      _INTENT(IN, integer)   NI, ND
      _INTENT(IN, _INT32)    IV (NI)
      _INTENT(IN, _REALD)    DV (ND)
      write (UNIT = IP, IOSTAT = IOS, REC = IR) IV, DV
      RETURN
      END
CCC_  & UUwwDM  ## Unison/IO write wrapper (formatted/direct/integer[4]-double)
      subroutine UUwwDM
     O    (IOS,
     I     IP,  IR, F, NI, ND, IV, DV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   IR
      _INTENT(IN, character) F*(*)
      _INTENT(IN, integer)   NI, ND
      _INTENT(IN, _INT32)    IV (NI)
      _INTENT(IN, _REALD)    DV (ND)
      write (UNIT = IP, IOSTAT = IOS, REC = IR, FMT = F) IV, DV
      RETURN
      END
CCC_ + [M] read/integer[4]-double
CCC_  & UUwrFM  ## Unison/IO read wrapper (Format/integer[4]-double)
      subroutine UUwrFM
     O    (IOS,
     I     IP,  F, NI, ND,
     O     IV,  DV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, character) F*(*)
      _INTENT(IN, integer)   NI, ND
      _INTENT(OUT,_INT32)    IV (NI)
      _INTENT(OUT,_REALD)    DV (ND)
      read (UNIT = IP, IOSTAT = IOS, FMT = F) IV, DV
      RETURN
      END
CCC_  & UUwrSM  ## Unison/IO read wrapper (*/integer[4]-double)
      subroutine UUwrSM
     O    (IOS,
     I     IP,  NI, ND,
     O     IV,  DV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   NI, ND
      _INTENT(OUT,_INT32)    IV (NI)
      _INTENT(OUT,_REALD)    DV (ND)
      read (UNIT = IP, IOSTAT = IOS, FMT = *) IV, DV
      RETURN
      END
CCC_  & UUwrUM  ## Unison/IO read wrapper (unformatted/seq/integer[4]-double)
      subroutine UUwrUM
     O    (IOS,
     I     IP,  NI, ND,
     o     IV,  DV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   NI, ND
      _INTENT(OUT,_INT32)    IV (NI)
      _INTENT(OUT,_REALD)    DV (ND)
      read (UNIT = IP, IOSTAT = IOS) IV, DV
      RETURN
      END
CCC_  & UUwrRM  ## Unison/IO read wrapper (unformatted/direct/integer[4]-double)
      subroutine UUwrRM
     O    (IOS,
     I     IP,  IR, NI, ND,
     O     IV,  DV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   IR
      _INTENT(IN, integer)   NI, ND
      _INTENT(OUT,_INT32)    IV (NI)
      _INTENT(OUT,_REALD)    DV (ND)
      read (UNIT = IP, IOSTAT = IOS, REC = IR) IV, DV
      RETURN
      END
CCC_  & UUwrDM  ## Unison/IO read wrapper (formatted/direct/integer[4]-double)
      subroutine UUwrDM
     O    (IOS,
     I     IP,  IR, F, NI, ND,
     O     IV,  DV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   IR
      _INTENT(IN, character) F*(*)
      _INTENT(IN, integer)   NI, ND
      _INTENT(OUT,_INT32)    IV (NI)
      _INTENT(OUT,_REALD)    DV (ND)
      read (UNIT = IP, IOSTAT = IOS, REC = IR, FMT = F) IV, DV
      RETURN
      END
CCC_ + [W] write/double-double
CCC_  & UUwwFW  ## Unison/IO write wrapper (Format/double-double)
      subroutine UUwwFW
     O    (IOS,
     I     IP,  F, NW, ND, WV, DV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, character) F*(*)
      _INTENT(IN, integer)   NW, ND
      _INTENT(IN, _REALD)    WV (NW)
      _INTENT(IN, _REALD)    DV (ND)
      write (UNIT = IP, IOSTAT = IOS, FMT = F) WV, DV
      RETURN
      END
CCC_  & UUwwSW  ## Unison/IO write wrapper (*/double-double)
      subroutine UUwwSW
     O    (IOS,
     I     IP,  NW, ND, WV, DV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   NW, ND
      _INTENT(IN, _REALD)    WV (NW)
      _INTENT(IN, _REALD)    DV (ND)
      write (UNIT = IP, IOSTAT = IOS, FMT = *) WV, DV
      RETURN
      END
CCC_  & UUwwUW  ## Unison/IO write wrapper (unformatted/seq/double-double)
      subroutine UUwwUW
     O    (IOS,
     I     IP,  NW, ND, WV, DV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   NW, ND
      _INTENT(IN, _REALD)    WV (NW)
      _INTENT(IN, _REALD)    DV (ND)
      write (UNIT = IP, IOSTAT = IOS) WV, DV
      RETURN
      END
CCC_  & UUwwRW  ## Unison/IO write wrapper (unformatted/direct/double-double)
      subroutine UUwwRW
     O    (IOS,
     I     IP,  IR, NW, ND, WV, DV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   IR
      _INTENT(IN, integer)   NW, ND
      _INTENT(IN, _REALD)    WV (NW)
      _INTENT(IN, _REALD)    DV (ND)
      write (UNIT = IP, IOSTAT = IOS, REC = IR) WV, DV
      RETURN
      END
CCC_  & UUwwDW  ## Unison/IO write wrapper (formatted/direct/double-double)
      subroutine UUwwDW
     O    (IOS,
     I     IP,  IR, F, NW, ND, WV, DV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   IR
      _INTENT(IN, character) F*(*)
      _INTENT(IN, integer)   NW, ND
      _INTENT(IN, _REALD)    WV (NW)
      _INTENT(IN, _REALD)    DV (ND)
      write (UNIT = IP, IOSTAT = IOS, REC = IR, FMT = F) WV, DV
      RETURN
      END
CCC_ + [W] read/double-double
CCC_  & UUwrFW  ## Unison/IO read wrapper (Format/double-double)
      subroutine UUwrFW
     O    (IOS,
     I     IP,  F, NW, ND,
     O     WV,  DV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, character) F*(*)
      _INTENT(IN, integer)   NW, ND
      _INTENT(OUT,_REALD)    WV (NW)
      _INTENT(OUT,_REALD)    DV (ND)
      read (UNIT = IP, IOSTAT = IOS, FMT = F) WV, DV
      RETURN
      END
CCC_  & UUwrSW  ## Unison/IO read wrapper (*/double-double)
      subroutine UUwrSW
     O    (IOS,
     I     IP,  NW, ND,
     O     WV,  DV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   NW, ND
      _INTENT(OUT,_REALD)    WV (NW)
      _INTENT(OUT,_REALD)    DV (ND)
      read (UNIT = IP, IOSTAT = IOS, FMT = *) WV, DV
      RETURN
      END
CCC_  & UUwrUW  ## Unison/IO read wrapper (unformatted/seq/double-double)
      subroutine UUwrUW
     O    (IOS,
     I     IP,  NW, ND,
     o     WV,  DV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   NW, ND
      _INTENT(OUT,_REALD)    WV (NW)
      _INTENT(OUT,_REALD)    DV (ND)
      read (UNIT = IP, IOSTAT = IOS) WV, DV
      RETURN
      END
CCC_  & UUwrRW  ## Unison/IO read wrapper (unformatted/direct/double-double)
      subroutine UUwrRW
     O    (IOS,
     I     IP,  IR, NW, ND,
     O     WV,  DV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   IR
      _INTENT(IN, integer)   NW, ND
      _INTENT(OUT,_REALD)    WV (NW)
      _INTENT(OUT,_REALD)    DV (ND)
      read (UNIT = IP, IOSTAT = IOS, REC = IR) WV, DV
      RETURN
      END
CCC_  & UUwrDW  ## Unison/IO read wrapper (formatted/direct/double-double)
      subroutine UUwrDW
     O    (IOS,
     I     IP,  IR, F, NW, ND,
     O     WV,  DV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   IR
      _INTENT(IN, character) F*(*)
      _INTENT(IN, integer)   NW, ND
      _INTENT(OUT,_REALD)    WV (NW)
      _INTENT(OUT,_REALD)    DV (ND)
      read (UNIT = IP, IOSTAT = IOS, REC = IR, FMT = F) WV, DV
      RETURN
      END
CCC_ + [J] write/integer-integer
CCC_  & UUwwFJ  ## Unison/IO write wrapper (Format/integer-integer)
      subroutine UUwwFJ
     O    (IOS,
     I     IP,  F, NI, NJ, IV, JV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, character) F*(*)
      _INTENT(IN, integer)   NI, NJ
      _INTENT(IN, integer)   IV (NI)
      _INTENT(IN, integer)   JV (NJ)
      write (UNIT = IP, IOSTAT = IOS, FMT = F) IV, JV
      RETURN
      END
CCC_  & UUwwSJ  ## Unison/IO write wrapper (*/integer-integer)
      subroutine UUwwSJ
     O    (IOS,
     I     IP,  NI, NJ, IV, JV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   NI, NJ
      _INTENT(IN, integer)   IV (NI)
      _INTENT(IN, integer)   JV (NJ)
      write (UNIT = IP, IOSTAT = IOS, FMT = *) IV, JV
      RETURN
      END
CCC_  & UUwwUJ  ## Unison/IO write wrapper (unformatted/seq/integer-integer)
      subroutine UUwwUJ
     O    (IOS,
     I     IP,  NI, NJ, IV, JV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   NI, NJ
      _INTENT(IN, integer)   IV (NI)
      _INTENT(IN, integer)   JV (NJ)
      write (UNIT = IP, IOSTAT = IOS) IV, JV
      RETURN
      END
CCC_  & UUwwRJ  ## Unison/IO write wrapper (unformatted/direct/integer-integer)
      subroutine UUwwRJ
     O    (IOS,
     I     IP,  IR, NI, NJ, IV, JV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   IR
      _INTENT(IN, integer)   NI, NJ
      _INTENT(IN, integer)   IV (NI)
      _INTENT(IN, integer)   JV (NJ)
      write (UNIT = IP, IOSTAT = IOS, REC = IR) IV, JV
      RETURN
      END
CCC_  & UUwwDJ  ## Unison/IO write wrapper (formatted/direct/integer-integer)
      subroutine UUwwDJ
     O    (IOS,
     I     IP,  IR, F, NI, NJ, IV, JV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   IR
      _INTENT(IN, character) F*(*)
      _INTENT(IN, integer)   NI, NJ
      _INTENT(IN, integer)   IV (NI)
      _INTENT(IN, integer)   JV (NJ)
      write (UNIT = IP, IOSTAT = IOS, REC = IR, FMT = F) IV, JV
      RETURN
      END
CCC_ + [J] read/integer-integer
CCC_  & UUwrFJ  ## Unison/IO read wrapper (Format/integer-integer)
      subroutine UUwrFJ
     O    (IOS,
     I     IP,  F, NI, NJ,
     O     IV,  JV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, character) F*(*)
      _INTENT(IN, integer)   NI, NJ
      _INTENT(OUT,integer)   IV (NI)
      _INTENT(OUT,integer)   JV (NJ)
      read (UNIT = IP, IOSTAT = IOS, FMT = F) IV, JV
      RETURN
      END
CCC_  & UUwrSJ  ## Unison/IO read wrapper (*/integer-integer)
      subroutine UUwrSJ
     O    (IOS,
     I     IP,  NI, NJ,
     O     IV,  JV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   NI, NJ
      _INTENT(OUT,integer)   IV (NI)
      _INTENT(OUT,integer)   JV (NJ)
      read (UNIT = IP, IOSTAT = IOS, FMT = *) IV, JV
      RETURN
      END
CCC_  & UUwrUJ  ## Unison/IO read wrapper (unformatted/seq/integer-integer)
      subroutine UUwrUJ
     O    (IOS,
     I     IP,  NI, NJ,
     o     IV,  JV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   NI, NJ
      _INTENT(OUT,integer)   IV (NI)
      _INTENT(OUT,integer)   JV (NJ)
      read (UNIT = IP, IOSTAT = IOS) IV, JV
      RETURN
      END
CCC_  & UUwrRJ  ## Unison/IO read wrapper (unformatted/direct/integer-integer)
      subroutine UUwrRJ
     O    (IOS,
     I     IP,  IR, NI, NJ,
     O     IV,  JV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   IR
      _INTENT(IN, integer)   NI, NJ
      _INTENT(OUT,integer)   IV (NI)
      _INTENT(OUT,integer)   JV (NJ)
      read (UNIT = IP, IOSTAT = IOS, REC = IR) IV, JV
      RETURN
      END
CCC_  & UUwrDJ  ## Unison/IO read wrapper (formatted/direct/integer-integer)
      subroutine UUwrDJ
     O    (IOS,
     I     IP,  IR, F, NI, NJ,
     O     IV,  JV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   IR
      _INTENT(IN, character) F*(*)
      _INTENT(IN, integer)   NI, NJ
      _INTENT(OUT,integer)   IV (NI)
      _INTENT(OUT,integer)   JV (NJ)
      read (UNIT = IP, IOSTAT = IOS, REC = IR, FMT = F) IV, JV
      RETURN
      END
CCC_ + [E] write/double to float
CCC_  & UUwwFE  ## Unison/IO write wrapper (Format/double to float)
      subroutine UUwwFE
     O    (IOS,
     I     IP,  F, N, DV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, character) F*(*)
      _INTENT(IN, integer)   N
      _INTENT(IN, _REALD)    DV (N)
      integer k
      write (UNIT = IP, IOSTAT = IOS, FMT = F)
     $     (_XREALF(DV (k)), k = 1, N)
      RETURN
      END
CCC_  & UUwwSE  ## Unison/IO write wrapper (*/double to float)
      subroutine UUwwSE
     O    (IOS,
     I     IP,  N, DV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   N
      _INTENT(IN, _REALD)    DV (N)
      integer k
      write (UNIT = IP, IOSTAT = IOS, FMT = *)
     $     (_XREALF(DV (k)), k = 1, N)
      RETURN
      END
CCC_  & UUwwUE  ## Unison/IO write wrapper (unformatted/seq/double to float)
      subroutine UUwwUE
     O    (IOS,
     I     IP,  N, DV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   N
      _INTENT(IN, _REALD)    DV (N)
      integer k
      write (UNIT = IP, IOSTAT = IOS)
     $     (_XREALF(DV (k)), k = 1, N)
      RETURN
      END
CCC_  & UUwwRE  ## Unison/IO write wrapper (unformatted/direct/double to float)
      subroutine UUwwRE
     O    (IOS,
     I     IP,  IR, N, DV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   IR
      _INTENT(IN, integer)   N
      _INTENT(IN, _REALD)    DV (N)
      integer k
      write (UNIT = IP, IOSTAT = IOS, REC = IR)
     $     (_XREALF(DV (k)), k = 1, N)
      RETURN
      END
CCC_  & UUwwDE  ## Unison/IO write wrapper (formatted/direct/double to float)
      subroutine UUwwDE
     O    (IOS,
     I     IP,  IR, F, N, DV)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(IN, integer)   IP
      _INTENT(IN, integer)   IR
      _INTENT(IN, character) F*(*)
      _INTENT(IN, integer)   N
      _INTENT(IN, _REALD)    DV (N)
      integer k
      write (UNIT = IP, IOSTAT = IOS, REC = IR, FMT = F)
     $     (_XREALF(DV (k)), k = 1, N)
      RETURN
      END
CCC_* Function wrappers
CCC_ & UUiend  ## Unison/IO check IOSTAT whether eof/nor
      subroutine UUiend
     O    (OEND,
     I     LB, IOS)
      implicit none
      _INTENT(OUT,logical) OEND
      _INTENT(IN, integer) LB
      _INTENT(IN, integer) IOS
      if (IOS.eq.0) then
         OEND = .false.
      else
         if (LB.gt.0) then
            call UUinor (OEND, IOS)
         else
            call UUieof (OEND, IOS)
         endif
      endif
      RETURN
      END
CCC_ & UUieof  ## Unison/IO check IOSTAT whether eof
      subroutine UUieof
     O    (Oeof,
     I     IOS)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,logical) Oeof
      _INTENT(IN, integer) IOS
#     if    HAVE_F77_IS_IOSTAT_END
#     else  /* not HAVE_F77_IS_IOSTAT_END */
#       ifdef SYS_IOSTAT_EOF
#       else /* not SYS_IOSTAT_EOF */
      integer jerr, jeof
#       endif
#     endif /* not HAVE_F77_IS_IOSTAT_END */
CCC_  - Body
#     if    HAVE_F77_IS_IOSTAT_END
        Oeof = IS_IOSTAT_END (IOS)
#     else  /* not HAVE_F77_IS_IOSTAT_END */
#       ifdef SYS_IOSTAT_EOF
          Oeof = (IOS .eq. SYS_IOSTAT_EOF)
#       else /* not SYS_IOSTAT_EOF */
          call UUiosc (jerr, jeof, IOSC_EOF, -1, -1)
          if (jerr.eq.0) then
            Oeof = (IOS .eq. jeof)
          else
CC        This may not be correct but may be enough for most system
            Oeof = (IOS .ne. 0)
          endif
#       endif
#     endif /* not HAVE_F77_IS_IOSTAT_END */
      RETURN
      END
CCC_ & UUinor  ## Unison/IO check IOSTAT whether no-record
      subroutine UUinor
     O    (Onor,
     I     IOS)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,logical) Onor
      _INTENT(IN, integer) IOS
      integer jerr, jnor
CCC_  - Body
      call UUiosc (jerr, jnor, IOSC_NO_RECORD, -1, -1)
      if (jerr.eq.0) then
         Onor = (IOS .eq. jnor)
      else
CC        This may not be correct but may be enough for most system
         Onor = (IOS .ne. 0)
      endif
      RETURN
      END
CCC_ & UUrwnd  ## Unison/IO rewind
      subroutine UUrwnd (IOS,  IU)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer) IOS
      _INTENT(IN, integer) IU
CCC_  - Body
      if (IU.ge.0) then
         rewind (Unit = IU, IOSTAT = IOS)
      else
CC          cannot rewind * unit?
c$$$         rewind (*,          IOSTAT = IOS)
         IOS = 0
      endif
      RETURN
      END
CCC_* File copy
CCC_ & UUcopy  ## Unison/IO copy file wrapper
      subroutine UUcopy
     O    (iErrR, iErrW,
     I     iRead, iWrite, PFX)
CCC_  - Declaration
      implicit none
CCC_   = Parameter
      integer    LW
      parameter (LW = OPT_UUCOPY_LINE_LENGTH)
CCC_   = Arguments
      _INTENT(OUT,integer)   iErrR, iErrW
      _INTENT(IN, integer)   iRead, iWrite
      _INTENT(IN, character) PFX*(*)
CCC_   = Interior
      character W*(LW)
CCC_  - Body
      if (PFX.ne.' ') then
         call UUcpyP
     O       (iErrR, iErrW,
     I        iRead, iWrite, PFX,
     W        W)
      else
         call UUcpyF
     O       (iErrR, iErrW,
     I        iRead, iWrite,
     W        W)
      endif
      RETURN
      END
CCC_ & UUcpyF  ## Unison/IO copy file
      subroutine UUcpyF
     O    (iErrR, iErrW,
     I     iRead, iWrite,
     W     W)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErrR, iErrW
      _INTENT(IN, integer)   iRead, iWrite
      _INTENT(OUT,character) W*(*)
c$$$      integer   LW
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
      integer ltw
#endif
CCC_  - Body
c$$$      LW = len (W)
CCC_   . asterisk to asterisk
      iErrR = 0
      iErrW = 0
      if (iRead.lt.0 .and. iWrite.lt.0) then
         DO
            read  (unit = *, fmt = '(A)', IOSTAT = iErrR) W
            if (iErrR.ne.0) goto 100
#if       HAVE_F77_TRIM == 0
            ltw = len_trim (W)
            write (unit = *, fmt = '(A)', IOSTAT = iErrW) W(1:ltw)
#else  /* HAVE_F77_TRIM */
            write (unit = *, fmt = '(A)', IOSTAT = iErrW) _TRIM(W)
#endif /* HAVE_F77_TRIM */
            if (iErrW.ne.0) goto 100
         ENDDO
 100     continue
CCC_   . asterisk to ordinal
      else if (iRead.lt.0) then
         DO
            read  (unit = *,      fmt = '(A)', IOSTAT = iErrR) W
            if (iErrR.ne.0) goto 200
#if       HAVE_F77_TRIM == 0
            ltw = len_trim (W)
            write (unit = iWrite, fmt = '(A)', IOSTAT = iErrW) W(1:ltw)
#else  /* HAVE_F77_TRIM */
            write (unit = iWrite, fmt = '(A)', IOSTAT = iErrW) _TRIM(W)
#endif /* HAVE_F77_TRIM */
            if (iErrW.ne.0) goto 200
         ENDDO
 200     continue
CCC_   . ordinal to asterisk
      else if (iWrite.lt.0) then
         DO
            read  (unit = iRead,  fmt = '(A)', IOSTAT = iErrR) W
            if (iErrR.ne.0) goto 300
#if       HAVE_F77_TRIM == 0
            ltw = len_trim (W)
            write (unit = *,      fmt = '(A)', IOSTAT = iErrW) W(1:ltw)
#else  /* HAVE_F77_TRIM */
            write (unit = *,      fmt = '(A)', IOSTAT = iErrW) _TRIM(W)
#endif /* HAVE_F77_TRIM */
            if (iErrW.ne.0) goto 300
         ENDDO
 300     continue
CCC_   . ordinal to ordinal
      else
         DO
            read  (unit = iRead,  fmt = '(A)', IOSTAT = iErrR) W
            if (iErrR.ne.0) goto 400
#if       HAVE_F77_TRIM == 0
            ltw = len_trim (W)
            write (unit = iWrite, fmt = '(A)', IOSTAT = iErrW) W(1:ltw)
#else  /* HAVE_F77_TRIM */
            write (unit = iWrite, fmt = '(A)', IOSTAT = iErrW) _TRIM(W)
#endif /* HAVE_F77_TRIM */
            if (iErrW.ne.0) goto 400
         ENDDO
 400     continue
      endif
C
      RETURN
      END
CCC_ & UUcpyP  ## Unison/IO copy file with prefix
      subroutine UUcpyP
     O    (iErrR, iErrW,
     I     iRead, iWrite, P,
     W     W)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErrR, iErrW
      _INTENT(IN, integer)   iRead, iWrite
      _INTENT(OUT,character) W*(*)
      _INTENT(IN, character) P*(*)
c$$$      integer   LW
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
      integer ltw, ltp
#endif
CCC_  - Body
c$$$      LW = len (W)
c
 101  format (A, A)
CCC_   . asterisk to asterisk
      iErrR = 0
      iErrW = 0
      if (iRead.lt.0 .and. COND_S(iWrite)) then
         DO
            read  (unit = *, fmt = '(A)', IOSTAT = iErrR) W
            if (iErrR.ne.0) goto 100
#if       HAVE_F77_TRIM == 0
            ltw = len_trim (W)
            ltp = len_trim (P)
            write (unit = *, fmt = 101,   IOSTAT = iErrW)
     $           P(1:ltp), W(1:ltw)
#else  /* HAVE_F77_TRIM */
            write (unit = *, fmt = 101,   IOSTAT = iErrW)
     $           _TRIM(P), _TRIM(W)
#endif /* HAVE_F77_TRIM */
            if (iErrW.ne.0) goto 100
         ENDDO
 100     continue
CCC_   . asterisk to ordinal
      else if (iRead.lt.0 .and. COND_N(iWrite)) then
         DO
            read  (unit = *,      fmt = '(A)', IOSTAT = iErrR) W
            if (iErrR.ne.0) goto 200
#if       HAVE_F77_TRIM == 0
            ltw = len_trim (W)
            ltp = len_trim (P)
            write (unit = iWrite, fmt = 101,   IOSTAT = iErrW)
     $           P(1:ltp), W(1:ltw)
#else  /* HAVE_F77_TRIM */
            write (unit = iWrite, fmt = 101,   IOSTAT = iErrW)
     $           _TRIM(P), _TRIM(W)
#endif /* HAVE_F77_TRIM */
            if (iErrW.ne.0) goto 200
         ENDDO
 200     continue
CCC_   . ordinal to asterisk
      else if (iRead.ge.0 .and. COND_S(iWrite)) then
         DO
            read  (unit = iRead,  fmt = '(A)', IOSTAT = iErrR) W
            if (iErrR.ne.0) goto 300
#if       HAVE_F77_TRIM == 0
            ltw = len_trim (W)
            ltp = len_trim (P)
            write (unit = *,      fmt = 101,   IOSTAT = iErrW)
     $           P(1:ltp), W(1:ltw)
#else  /* HAVE_F77_TRIM */
            write (unit = *,      fmt = 101,   IOSTAT = iErrW)
     $           _TRIM(P), _TRIM(W)
#endif /* HAVE_F77_TRIM */
            if (iErrW.ne.0) goto 300
         ENDDO
 300     continue
CCC_   . ordinal to ordinal
      else if (iRead.ge.0 .and. COND_N(iWrite)) then
         DO
            read  (unit = iRead,  fmt = '(A)', IOSTAT = iErrR) W
            if (iErrR.ne.0) goto 400
#if       HAVE_F77_TRIM == 0
            ltw = len_trim (W)
            ltp = len_trim (P)
            write (unit = iWrite, fmt = 101,   IOSTAT = iErrW)
     $           P(1:ltp), W(1:ltw)
#else  /* HAVE_F77_TRIM */
            write (unit = iWrite, fmt = 101,   IOSTAT = iErrW)
     $           _TRIM(P), _TRIM(W)
#endif /* HAVE_F77_TRIM */
            if (iErrW.ne.0) goto 400
         ENDDO
 400     continue
      endif
C
      RETURN
      END
CCC_* Inquire wrappers
CCC_ & UUquop  ## Unison/IO inquire opened   by unit
      subroutine UUquop
     O    (IOS, OPND,
     I     IU)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(OUT,logical)   OPND
      _INTENT(IN, integer)   IU
      inquire (IOSTAT = IOS, UNIT = IU, OPENED = OPND)
      RETURN
      END
CCC_ & UUquae  ## Unison/IO inquire access   by unit
      subroutine UUquae
     O    (IOS, Str,
     I     IU)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(OUT,character) Str*(*)
      _INTENT(IN, integer)   IU
      inquire (IOSTAT = IOS, UNIT = IU, ACCESS = Str)
      RETURN
      END
CCC_ & UUquat  ## Unison/IO inquire action   by unit
      subroutine UUquat
     O    (IOS, Str,
     I     IU)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(OUT,character) Str*(*)
      _INTENT(IN, integer)   IU
      inquire (IOSTAT = IOS, UNIT = IU, ACTION = Str)
      RETURN
      END
CCC_ & UUqufo  ## Unison/IO inquire form     by unit
      subroutine UUqufo
     O    (IOS, Str,
     I     IU)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(OUT,character) Str*(*)
      _INTENT(IN, integer)   IU
      inquire (IOSTAT = IOS, UNIT = IU, FORM = Str)
      RETURN
      END
CCC_ & UUqurl  ## Unison/IO inquire recl     by unit
      subroutine UUqurl
     O    (IOS, IRL,
     I     IU)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(OUT,integer)   IRL
      _INTENT(IN, integer)   IU
      character A*(20)
      call UUquae (IOS, A, IU)
      if (IOS.eq.0) then
         if (A (1:1).eq.'D') then
            inquire (IOSTAT = IOS, UNIT = IU, RECL = IRL)
         else
            IRL = -1
         endif
      else
         IRL = -1
      endif
      RETURN
      END
CCC_ & UUqunx  ## Unison/IO inquire next rec by unit
      subroutine UUqunx
     O    (IOS, INX,
     I     IU)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(OUT,integer)   INX
      _INTENT(IN, integer)   IU
      inquire (IOSTAT = IOS, UNIT = IU, NEXTREC = INX)
      RETURN
      END
CCC_ & UUqunm  ## Unison/IO inquire name   by unit
      subroutine UUqunm
     O    (IOS, ONMD, FNM,
     I     IU)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(OUT,logical)   ONMD
      _INTENT(OUT,character) FNM*(*)
      _INTENT(IN, integer)   IU
      IOS  = 0
      FNM  = ' '
      ONMD = .FALSE.
      inquire (IOSTAT = IOS, UNIT = IU, NAMED = ONMD)
      if (IOS.eq.0) then
         if (ONMD) then
            inquire (IOSTAT = IOS, UNIT = IU, NAME = FNM)
         endif
      endif
      RETURN
      END
CCC_ & UUqfex  ## Unison/IO inquire existence by name
      subroutine UUqfex
     O    (IOS, Oex,
     I     FNM)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(OUT,logical)   Oex
      _INTENT(IN, character) FNM*(*)
      inquire (IOSTAT = IOS, FILE = FNM, EXIST = OEX)
      RETURN
      END
CCC_ & UUqnop  ## Unison/IO inquire opened    by name
      subroutine UUqnop
     O    (IOS, OPND,
     I     FNM)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(OUT,logical)   OPND
      _INTENT(IN, character) FNM*(*)
      inquire (IOSTAT = IOS, FILE = FNM, OPENED = OPND)
      RETURN
      END
CCC_ & UUqnun  ## Unison/IO inquire unit      by name
      subroutine UUqnun
     O    (IOS, IU,
     I     FNM)
      implicit none
      _INTENT(OUT, integer)   IOS
      _INTENT(OUT, integer)   IU
      _INTENT(IN,  character) FNM*(*)
      logical   OPND
      IOS = 0
      IU  = -1
      call UUqnop (IOS, OPND, FNM)
      if (IOS.eq.0 .and. OPND)
     $     inquire (IOSTAT = IOS, FILE = FNM, NUMBER = IU)
      RETURN
      END
CCC_ & UUqiol  ## Unison/IO inquire iolength (using fortran 90 inquire) or error
      subroutine UUqiol
     O    (IOS, LIO,
     I     CT)
      implicit none
      _INTENT(OUT,integer)   IOS
      _INTENT(OUT,integer)   LIO
      _INTENT(IN, character) CT*(*)
#if HAVE_INQUIRE_IOLENGTH == 0
CC       Dummy statements
      if (CT.eq.' ') continue
      IOS = -1
      LIO = -99
#else /* HAVE_INQUIRE_IOLENGTH */
      _REALD    DV
      _REALF    FV
      real      CV
      _INT32 NV
#  if HAVE_INTEGER_64_KIND
      _INT64 LV
#  endif
#  ifdef _REALSTD
      _REALSTD SV
#  endif
      integer   IV
c
      IOS = 0
      if      (CT.eq.'D') then
         INQUIRE (IOLENGTH = LIO) DV
      else if (CT.eq.'F') then
         INQUIRE (IOLENGTH = LIO) FV
      else if (CT.eq.'C') then
         INQUIRE (IOLENGTH = LIO) CV
#if HAVE_INTEGER_64_KIND
      else if (CT.eq.'L') then
         INQUIRE (IOLENGTH = LIO) LV
#endif
#ifdef _REALSTD
      else if (CT.eq.'S') then
         INQUIRE (IOLENGTH = LIO) SV
#endif
      else if (CT.eq.'N') then
         INQUIRE (IOLENGTH = LIO) NV
      else
         INQUIRE (IOLENGTH = LIO) IV
      endif
#endif /* HAVE_INQUIRE_IOLENGTH */
      RETURN
      END
CCC_ & UUqrsu  ## Unison/IO simple report one unit
      subroutine UUqrsu
     I    (TAG, IU, IPL,
     W     FNM)
      implicit none
      _INTENT(IN, character) TAG*(*)
      _INTENT(IN, integer)   IU, IPL
      _INTENT(OUT,character) FNM*(*)
      logical   OPND, ONMD
      character BU * (16)
      integer   IOS
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
      call UUquop (IOS, OPND,      IU)
      call UUqunm (IOS, ONMD, FNM, IU)
      call USGlni (BU, IU)
 101  format (A, 1x, A, 1x, A)
      if (OPND.and.ONMD) then
         if (COND_N(IPL))  then
            write (IPL, 101)
     $           _TRIM(TAG), _TRIM(BU), _TRIML(FNM)
         else if (COND_S(IPL)) then
            write (*,   101)
     $           _TRIM(TAG), _TRIM(BU), _TRIML(FNM)
         endif
      endif
      RETURN
      END
CCC_ & UUqrpu  ## Unison/IO inquire report one unit
      subroutine UUqrpu
     I    (IU, IPL,
     W     FNM)
      implicit none
      _INTENT(IN, integer)   IU, IPL
      _INTENT(OUT,character) FNM*(*)
      integer   IOS
      logical   OPND, ONMD
      character StrAcc * (16), StrFrm * (16), StrAct * (16)
      integer   IRECL, INXTR
      character BU * (16), BL * (16), BN * (16)
c
#if  HAVE_F77_ISATTY
      logical  OTTY
#endif
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
c
      call UUquop (IOS, OPND,      IU)
      call UUqunm (IOS, ONMD, FNM, IU)
      call UUquae (IOS, StrAcc,    IU)
      call UUqufo (IOS, StrFrm,    IU)
      call UUqurl (IOS, IRECL,     IU)
      call UUqunx (IOS, INXTR,     IU)
      call UUquat (IOS, StrAct,    IU)
c
#if     HAVE_F77_ISATTY
 119  format ('i/o unit check [', A, '] tty ', A)
#endif
 118  format ('i/o unit check [', A, '] ', A)
 117  format ('i/o unit check [', A, '] (no name)')
 115  format ('i/o unit check [', A, '] ',
     $     A, ':', A, ':', A, ':', A, ':', A)
c
      call USGlni (BU, IU)
      call USGlni (BL, IRECL)
      call USGlni (BN, INXTR)
c
      if      (COND_N(IPL))  then
         if (OPND) then
            if    (ONMD) then
               write (IPL, 118) _TRIM(BU), _TRIML(FNM)
            else
               write (IPL, 117) _TRIM(BU)
            endif
            write (IPL, 115) _TRIM(BU),
     $           _TRIM(StrAcc), _TRIM(StrFrm),
     $           _TRIM(BL), _TRIM(BN), _TRIM(StrAct)
         endif
      else if (COND_S(IPL)) then
#        define IPL *
         if (OPND) then
            if    (ONMD) then
               write (IPL, 118) _TRIM(BU), _TRIML(FNM)
            else
               write (IPL, 117) _TRIM(BU)
            endif
            write (IPL, 115) _TRIM(BU),
     $           _TRIM(StrAcc), _TRIM(StrFrm),
     $           _TRIM(BL), _TRIM(BN), _TRIM(StrAct)
         endif
#        undef  IPL
      endif
c
#if     HAVE_F77_ISATTY
      OTTY = ISATTY (IU)
#  if   HAVE_F77_TTYNAM
      if (OTTY) call TTYNAM (IU, FNM)
#  else  /* not HAVE_F77_TTYNAM */
      FNM = '(tty)'
#  endif
      if (OTTY) then
         if      (COND_N(IPL))  then
            write (IPL, 119) _TRIM(BU),
     $           _TRIM(FNM)
         else if (COND_S(IPL)) then
#           define IPL *
            write (IPL, 119) _TRIM(BU),
     $           _TRIM(FNM)
#           undef  IPL
         endif
      endif
#endif
c
      RETURN
      END
CCC_ & UUqrpr  ## Unison/IO inquire report range
      subroutine UUqrpr (IUS, IUE, IPL, FNM)
      implicit none
      _INTENT(IN, integer)   IUS, IUE, IPL
      _INTENT(OUT,character) FNM*(*)
      integer ks, ke, k, kk
      ks = IUS
      if (ks.lt.0) ks = OPT_IOUNIT_START
      ke = IUE
      if (ke.lt.0) ke = OPT_IOUNIT_END
      do k = ks, ke
         kk = k
         call UUqrpu (kk, IPL, FNM)
      enddo
      RETURN
      END
CCC_* System-dependent
CCC_ & UUiosq  ## Uniton/IO iostat table cache (silent)
      subroutine UUiosq (iErr)
      implicit none
      _INTENT(OUT,integer)   iErr
      integer IOS
      iErr = 0
      if (iErr.eq.0) call UUiosc (iErr, IOS, IOSC_NO_RECORD, -3, -3)
      if (iErr.eq.0) call UUiosc (iErr, IOS, IOSC_EOF,       -3, -3)
      RETURN
      END
CCC_ & UUiosc  ## Uniton/IO iostat table cache
      subroutine UUiosc
     O    (iErr, IOS,
     I     kStt, IFPchk, IFPlog)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr,   IOS
      _INTENT(IN, integer)   kStt
      _INTENT(IN, integer)   IFPchk, IFPlog
CCC_   . io status
      integer    kEOF
      parameter (kEOF = IOSC_EOF)
      integer    kNOR
      parameter (kNOR = IOSC_NO_RECORD)
      integer    kEOR
      parameter (kEOR = IOSC_EOR)
      integer    Ltbl
      parameter (Ltbl = IOSC_MAX)
      integer    IOStbl (0:Ltbl)
      data       IOStbl /0, Ltbl * 0/
      save       IOStbl
      integer    jfpchk
      logical    OSET
      data       OSET /.false./
      save       OSET
CCC_  - Body
      if (kStt.lt.0 .and. kStt.gt.Ltbl) then
         iErr = -1
         IOS  = 0
      else
         iErr = 0
         IOS  = IOStbl (kStt)
         if (IOS.eq.0) then
            if (.not.OSET) then
               jfpchk = IFPchk
               if (jfpchk.lt.0) call UUmcnu (iErr, jfpchk)
               if (iErr.eq.0)
     $              call UUchEO (iErr, IOStbl (kEOF), jfpchk)
               if (iErr.eq.0)
     $              call UUchNR (iErr, IOStbl (kNOR), jfpchk)
               if (iErr.eq.0)
     $              call UUchSL (iErr, IOStbl (kEOR), jfpchk)
               if (iErr.eq.0) OSET = .true.
            endif
 101        format ('UUIOSC REPORT[', I7, '] ', A, ' = ', I7)
 102        format ('UUIOSC REPORT[', I7, '] ', A, '(FINAL) = ', I7)
            if (COND_N(IFPlog)) then
               write (IFPlog, 101) iErr, 'EOF',       IOStbl (kEOF)
               write (IFPlog, 101) iErr, 'NO RECORD', IOStbl (kNOR)
               write (IFPlog, 101) iErr, 'EOR',       IOStbl (kEOR)
            else if (COND_S(IFPlog)) then
#              define IFPlog *
               write (IFPlog, 101) iErr, 'EOF',       IOStbl (kEOF)
               write (IFPlog, 101) iErr, 'NO RECORD', IOStbl (kNOR)
               write (IFPlog, 101) iErr, 'EOR',       IOStbl (kEOR)
#              undef  IFPlog
            endif
            if (IOStbl (kEOR).eq.IOStbl (kEOF)) then
               IOStbl (kEOR) = 0
            endif
            if (COND_N(IFPlog)) then
               write (IFPlog, 102) iErr, 'EOR', IOStbl (kEOR)
            else if (COND_S(IFPlog)) then
#              define IFPlog *
               write (IFPlog, 102) iErr, 'EOR', IOStbl (kEOR)
#              undef  IFPlog
            endif
         endif
         if (iErr.eq.0) IOS = IOStbl (kStt)
      endif
      RETURN
      END
CCC_ & UUlenU  ## Unison/IO file get record length in bytes
      subroutine UUlenU
     O    (IOS,  LU,
     I     FNM,  IFPchk, IFPlog)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   IOS,    LU
      _INTENT(IN, integer)   IFPchk, IFPlog
      _INTENT(IN, character) FNM*(*)
      integer LUsav
      data    LUsav /0/
      save    LUsav
      character TFNM*(OPT_FILENAME_MAX)
      integer jfpchk, jerr
CCC_  - Body
 101  format ('UULENU REPORT[', I7, '] ', I7)
      if (LUsav.gt.0) then
         LU  = LUsav
         IOS = 0
      else
         call UUqiol (IOS, LUsav, 'D')
         if (IOS.eq.0) then
            LUsav = REAL_DOUBLE_BYTES / LUsav
         else
            TFNM   = FNM
            if (TFNM.eq.' ') TFNM = 'UUIOMS_UULENU_TEMP'
            jfpchk = IFPchk
            jerr   = 0
            if (jfpchk.lt.0) call UUmcnu (jerr, jfpchk)
            if (jerr.eq.0) then
               call UUchLU (IOS, LUsav, TFNM, IFPchk)
            else
               IOS   = -1
               LUsav = -1
            endif
         endif
         if (COND_N(IFPlog)) then
            write (IFPlog, 101) IOS, LUsav
         else if (COND_S(IFPlog)) then
            write (*,      101) IOS, LUsav
         endif
         LU = LUsav
      endif
      RETURN
      END
CCC_* Run-time check of system-dependent features
CCC_ & UUchLU  ## Unison/IO file run-time check record length
      subroutine UUchLU
     O    (IOS,  LU,
     M     FNM,
     I     IFP)
CCC_  - Description
CC      Run-time check of system-dependent unit record-length.
CC      Open FNMnnnnn, write the test string, close, reopen,
CC      read the test string, get the unit, delete FNMnnnnn.
CCC_  - Declaration
      implicit none
CCC_   = Parameters
      integer    MaxTry
      parameter (MaxTry = OPT_MAX_TRY_UULENU)
      CHARACTER  TSTCH*(*)
      PARAMETER (TSTCH = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ')
CCC_   = Arguments
      _INTENT(OUT,   integer)   IOS
      _INTENT(OUT,   integer)   LU
      _INTENT(INOUT, character) FNM*(*)
      _INTENT(IN,    integer)   IFP
CCC_   = Interior
      integer   j
      integer   kp
      integer   IRL
      character TCH
      integer   JFP
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
CCC_  - Body
      IOS = 0
      LU  = 0
      IRL = len (TSTCH)
      kp  = len_trim (FNM) + 1
      JFP = IFP
      if (JFP.lt.0) call UUMCnu (IOS, JFP)
      if (IOS.eq.0) then
         do j = 0, MaxTry
            write (FNM (kp:kp + 4), '(I5.5)') j
            IOS = 0
            if (IOS.eq.0)
     $           call UUopnN (IOS, JFP, FNM, IRL, 'U', 'W', ' ')
            if (IOS.eq.0)
     $           write (UNIT = JFP, IOSTAT = IOS, REC = 1) TSTCH
            if (IOS.eq.0)
     $           call UUclsC (IOS, JFP, FNM, 'K')
            if (IOS.eq.0)
     $           call UUopen (IOS, JFP, FNM, 1, 'U', 'O', 'R', ' ')
            if (IOS.eq.0)
     $           read  (UNIT = JFP, IOSTAT = IOS, REC = 2) TCH
            if (IOS.eq.0)
     $           LU = INDEX (TSTCH, TCH) - 1
            if (IOS.eq.0)
     $           call UUclsC (IOS, JFP, FNM, 'D')
            if (LU.ne.0) goto 100
         enddo
 100     continue
      endif
      if (LU.eq.0) IOS = -1
      RETURN
      END
CCC_ & UUchEO  ## Unison/IO file run-time check (end of file)
      subroutine UUchEO
     O    (iErr, IOSeof,
     I     IFP)
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(OUT,integer) IOSeof
      _INTENT(IN, integer) IFP
      integer    lv
      parameter (lv = 1)
      integer    iv (lv), jv (lv)
      integer    lrec, jedmy
      lrec   = -1
      iErr   = 0
      IOSeof = 0
      if (iErr.eq.0) call UUopnS (iErr, IFP, lrec, 'F')
      if (iErr.eq.0) then
         iv (1) = 127
         if (iErr.eq.0) call UUwwSI (iErr, IFP, lv, iv)
      endif
      if (iErr.eq.0) call UUrwnd (iErr,  IFP)
      if (iErr.eq.0) call UUwrSI (iErr,  IFP, lv, jv)
      if (iErr.eq.0) then
         call UUwrSI (IOSeof, IFP, lv, jv)
         call UUclsC (jedmy,  IFP, ' ', 'DELETE')
      endif
      RETURN
      END
CCC_ & UUchSL  ## Unison/IO file run-time check (short length)
      subroutine UUchSL
     O    (iErr, IOSsl,
     I     IFP)
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(OUT,integer) IOSsl
      _INTENT(IN, integer) IFP
      integer    liv,     ljv
      parameter (liv = 1, ljv = 2)
      integer    iv (liv), jv (ljv)
      integer    lrec, jedmy
      lrec  = -1
      iErr  = 0
      IOSsl = 0
      if (iErr.eq.0) call UUopnS (iErr, IFP, lrec, 'F')
      if (iErr.eq.0) then
         iv (1) = 127
         if (iErr.eq.0) call UUwwSI (iErr, IFP, liv, iv)
      endif
      if (iErr.eq.0) call UUrwnd (iErr,  IFP)
      if (iErr.eq.0) then
         call UUwrSI (IOSsl, IFP, ljv, jv)
         call UUclsC (jedmy, IFP, ' ', 'DELETE')
      endif
      RETURN
      END
CCC_ & UUchNR  ## Unison/IO file run-time check (no record)
      subroutine UUchNR
     O    (iErr, IOSnr,
     I     IFP)
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(OUT,integer) IOSnr
      _INTENT(IN, integer) IFP
      integer    lv
      parameter (lv = 1)
      integer    iv (lv), jv (lv)
      integer    lrec, jedmy
      lrec  = 16
      iErr  = 0
      IOSnr = 0
      if (iErr.eq.0) call UUopnS (iErr, IFP, lrec, 'U')
      if (iErr.eq.0) then
         iv (1) = 127
         call UUwwRI (iErr,  IFP, 1, lv, iv)
      endif
      if (iErr.eq.0) then
         call UUwrRI (IOSnr, IFP, 2, lv, jv)
         call UUclsC (jedmy, IFP, ' ', 'DELETE')
      endif
      RETURN
      END
CCC_ & UUchSD  ## Unison/IO file run-time check (standard units, no exclusion)
      subroutine UUchSD
     O    (iErr,
     O     IUI,   NUI, LUI,
     O     IUO,   NUO, LUO,
     I     IUstt, IUend)
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(OUT,integer) IUI (*), IUO (*)
      _INTENT(OUT,integer) NUI,     NUO
      _INTENT(IN, integer) LUI,     LUO
      _INTENT(IN, integer) IUstt,   IUend
      integer IUX (1), LUX
      IUX (1) = -1
      LUX     = 0
      call UUchST
     O    (iErr,
     O     IUI,  NUI, LUI,
     O     IUO,  NUO, LUO,
     I     IUX,  LUX, IUstt, IUend)
      RETURN
      END
CCC_ & UUchST  ## Unison/IO file run-time check (standard units)
      subroutine UUchST
     O    (iErr,
     O     IUI,  NUI, LUI,
     O     IUO,  NUO, LUO,
     I     IUX,  LUX, IUstt, IUend)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(OUT,integer) IUI (*), IUO (*)
      _INTENT(OUT,integer) NUI,     NUO
      _INTENT(IN, integer) LUI,     LUO
      _INTENT(IN, integer) IUX (*), LUX
      _INTENT(IN, integer) IUstt,   IUend
      integer   ks, ke, k, kx, ku
      integer   IOS
      logical   OSKP, OPND
      character StrAct * (16)
CCC_  - Body
      iErr  = 0
c
      NUI   = 0
      NUO   = 0
      ks = IUstt
      if (ks.lt.0) ks = OPT_IOUNIT_START
      ke = IUend
      if (ke.lt.0) ke = OPT_IOUNIT_END
c
      do k = ks, ke
         ku = k
         oskp = .false.
         do kx = 1, LUX
            if (ku.eq.IUx(kx)) oskp = .true.
         enddo
         if (oskp) goto 900
         call UUquop (IOS, OPND,   ku)
         if (.not.OPND) goto 900
         call UUquat (IOS, StrAct, ku)
         if      (StrAct (1:1).eq.'W') then
            nuo = nuo + 1
            if (nuo.lt.LUO) IUO (nuo) = ku
         else if (StrAct (1:1).eq.'R') then
            nui = nui + 1
            if (nui.lt.LUI) IUI (nui) = ku
         endif
 900     continue
      enddo
c
      RETURN
      END
CCC_& UUIOMS  ## Unison/IO file open/close announcement
      subroutine UUIOMS (STRA, STRB, IOP)
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
         STRA = 'OPT_FILENAME_MAX'
         write (STRB, *) OPT_FILENAME_MAX
      else if (IOP.eq.4) then
         STRA = 'OPT_STDOUT_UNIT'
         write (STRB, *) OPT_STDOUT_UNIT
      else if (IOP.eq.5) then
         STRA = 'OPT_STDERR_UNIT'
         write (STRB, *) OPT_STDERR_UNIT
      else if (IOP.eq.6) then
         STRA = 'OPT_STDIN_UNIT'
         write (STRB, *) OPT_STDIN_UNIT
      else if (IOP.eq.7) then
         STRA = 'OPT_INVALID_UNIT'
         write (STRB, *) OPT_INVALID_UNIT
      else if (IOP.eq.8) then
         STRA = 'OPT_IOUNIT_START'
         write (STRB, *) OPT_IOUNIT_START
      else if (IOP.eq.9) then
         STRA = 'OPT_IOUNIT_END'
         write (STRB, *) OPT_IOUNIT_END
      else if (IOP.eq.10) then
         STRA = 'HAVE_DIRECT_ACCESS_POSITION'
         write (STRB, *) HAVE_DIRECT_ACCESS_POSITION
      else if (IOP.eq.11) then
         STRA = 'OPT_UUCOPY_LINE_LENGTH'
         write (STRB, *) OPT_UUCOPY_LINE_LENGTH
      else if (IOP.eq.12) then
         STRA = 'OPT_MAX_TRY_UULENU'
         write (STRB, *) OPT_MAX_TRY_UULENU
      else
         STRA = ' '
         STRB = ' '
      endif
      RETURN
      END
CCC_* Test
CCC_ + begin
#ifdef    TEST_UUIOMS
CCC_ @ UUtest  ## Unison/IO test
      program UUtest
CCC_  - Test suites
CC::   SOURCES ufortw.F udbgst.F
CCC_  - Declaration
      implicit none
      integer    j
      integer    iErr, ioso, iosc
      integer    ifp (100)
      data       ifp /100 * -999/
      integer    LU,  LRD
      integer    ifpt
      character  FNM*(100)
c
      integer    LUI,       LUO
      parameter (LUI = 8,   LUO = 8)
      integer    NUI,       NUO
      integer    IUI (LUI), IUO (LUO)
      integer    ju
c
      integer    IOSnr, IOSeof
      integer    je
c
      integer    iplog
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
#include "orevan.h" /* 0 */
CCC_  - Body
      iErr  = 0
      iplog = -1
CCC_   . announcement
      call UDTbnr ('announcement', iplog)
#define _ANNOUNCE UUIOMS
#define _LEXT     9999
#include "orevan.h" /* 1 */
CCC_   . initialization
      call UDTbnr ('initialization', iplog)
      call UUmngC (iErr)
      write (*, *) 'ERR = ', iErr
CCC_   . opened file checks (maybe system files only)
      call UDTbnr ('initial files', iplog)
      call UUqrpr (-1, -1, -1, FNM)
CCC_   . check standard units
      call UDTbnr ('standard units', iplog)
      call UUchSD
     O    (iErr,
     O     IUI,   NUI, LUI,
     O     IUO,   NUO, LUO,
     I     -1,    -1)
 501  format (A, 1x, I3, ' : ', 20I4)
      write (*, 501) 'I', nui, (IUI (ju), ju = 1, nui)
      write (*, 501) 'O', nuo, (IUO (ju), ju = 1, nuo)
CCC_   . unison i/o unit manager
      call UDTbnr ('unison io manager (set flags)', iplog)
      call UUmngC (iErr)
      call UUmngI (_CONFIG_DEFAULT)
CCC_    * drop units 15--85 from candidates
      do j = 15, 85
         ju = j
         call UUMCsf (ju, _UNIT_NEVER)
      enddo
CCC_   . close at once
 101  format (A, 1x, I2.2, 1x, I3, ' :: ', 3I4)
      call UDTbnr ('open/close', iplog)
      do j = 1, 20
         ioso = 0
         iosc = 0
         call UUMCnu (iErr, ifp (j))
         if (iErr.eq.0) then
            call UUTfop (ioso, ifp (j), j)
c$$$            open  (unit = ifp (j), IOSTAT = ioso)
            close (unit = ifp (j), IOSTAT = iosc)
         endif
         write (*, 101) 'OPEN/CLOSE', j, ifp (j), iErr, ioso, iosc
      enddo
CCC_   . keep open
      call UDTbnr ('keep open', iplog)
      do j = 1, 20
         ioso = 0
         iosc = 0
         call UUMCnu (iErr, ifp (j))
         if (iErr.eq.0) then
c$$$            open (unit = ifp (j), IOSTAT = ioso)
            call UUTfop (ioso, ifp (j), j)
         endif
         write (*, 101) 'OPEN/KEEP', j, ifp (j), iErr, ioso, iosc
      enddo
CCC_   . close partly
      call UDTbnr ('close partly', iplog)
      do j = 6, 10
         ioso = 0
         iosc = 0
         iErr = 0
         if (ifp (j).ge.0) then
            close (unit = ifp (j), IOSTAT = iosc)
            ifp (j) = -1
            write (*, 101) 'CLOSE', j, ifp (j), iErr, ioso, iosc
         endif
      enddo
CCC_   . open again
      call UDTbnr ('open again', iplog)
      do j = 1, 20
         if (ifp (j).lt.0) then
            ioso = 0
            iosc = 0
            call UUMCnu (iErr, ifp (j))
            if (iErr.eq.0) then
c$$$               open (unit = ifp (j), IOSTAT = ioso)
               call UUTfop (ioso, ifp (j), j)
            endif
            write (*, 101) 'OPEN/AGAIN', j, ifp (j), iErr, ioso, iosc
         endif
      enddo
CCC_   . record length unit
      call UDTbnr ('record length unit', iplog)
 301  format (A, 1x, I3, 1x, I2, ' :: ', I3)
 201  format (A, 1x, I3, 1x, I2, ' :: ', I2, 1x, A)
CCC_    * uuqiol
      call UUqiol (iERR, LRD, 'D')
      write (*, 301) 'UUQIOL', iErr, REAL_DOUBLE_BYTES / LRD, LRD
CCC_    * uulenu
      ifpt = 9
      FNM = 'XXX'
      call UUlenU (iErr, LU, FNM, -1, -1)
      write (*, 201) 'UULENU', iErr, LU, ifpt, _TRIM(FNM)
CCC_    * uuchlu
      call UUchLU (iErr, LU, FNM, ifpt)
      write (*, 201) 'UUCHLU', iErr, LU, ifpt, _TRIM(FNM)
CCC_   . opened file checks (ii)
      call UDTbnr ('open files (ii)', iplog)
      call UUqrpr (-1, -1, -1, FNM)
CCC_   . force close
      call UDTbnr ('force close', iplog)
      call UUclsF (je, 10, -1, -1)
CCC_   . opened file checks (iii)
      call UDTbnr ('open files (iii)', iplog)
      call UUqrpr (-1, -1, -1, FNM)
CCC_   . iostat check (i)
      call UDTbnr ('iostat (i)', iplog)
      ifpt = 8
      call UUchNR (je, IOSnr, ifpt)
      write (*, *) 'No record: ', IOSnr, je
      call UUchEO (je, IOSeof, ifpt)
#  if HAVE_F77_IS_IOSTAT_END
      write (*, *) 'EOF: ', IOSeof, je, IS_IOSTAT_END (IOSeof)
#  else
      write (*, *) 'EOF: ', IOSeof, je, 'XXX'
#  endif
CCC_   . iostat check (ii)
      call UDTbnr ('iostat', iplog)
      call UUiosc (je, iosc, 0, -1, -1)
CCC_   . end
      call UDTbnr ('END', iplog)
      STOP
      END
CCC_ & UUTfop  ## Unison/IO test open
      subroutine UUTfop
     O    (IOS,
     I     IFP, IDX)
      implicit none
      _INTENT(OUT,integer) IOS
      _INTENT(IN, integer) IFP
      _INTENT(IN, integer) IDX
      integer jsw
      jsw = MOD (IDX, 3)
      if (jsw.eq.0) then
         open  (unit = ifp, IOSTAT = ios,
     $          FORM = 'UNFORMATTED',
     $          ACCESS = 'DIRECT',
     $          RECL   = IDX)
      else if (jsw.eq.1) then
         open  (unit = ifp, IOSTAT = ios,
     $          FORM = 'UNFORMATTED',
     $          ACCESS = 'SEQUENTIAL')
      else
         open  (unit = ifp, IOSTAT = ios)
      endif
      RETURN
      END
CCC_ + end
#endif /* TEST_UUIOMS */
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
