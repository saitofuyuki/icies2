C development/dbstrp.F --- IcIES/Development/Bootstrap
C Maintainer:  SAITO Fuyuki
C Created: Feb 17 2010
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2020/09/15 11:47:32 fuyuki dbstrp.F>'
#define _FNAME 'development/dbstrp.F'
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
CCC_* Description
CCC_ + Policy
CC     Diagnosis outputs should be managed outside of these routines
CCC_* Macros
#include "ofdlct.h" /* fortran dialect */
#include "odevel.h"
#define _FLG_NEED_SWEEP 1
CCC_* Bootstrap integration
CCC_ & DBmngr  ## Development/Bootstrap Manager batch initialization
      subroutine DBmngr
     O     (iErr, ibsA)
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   ibsA (_MAX_BOOTSTRAP_UNITS)
      _INTENT(IN, integer)   IFP
      _INTENT(IN, integer)   idxB
      _INTENT(IN, logical)   ONOTAG
      _INTENT(IN, character) FILE*(*)
CCC_   = Save
      logical OFIRST
      data    OFIRST / .true. /
      save    OFIRST
c
      integer iBSsav (_MAX_BOOTSTRAP_UNITS)
      data    iBSsav /_MAX_BOOTSTRAP_UNITS * -9/
      save    iBSsav
      integer iBSflg (_MAX_BOOTSTRAP_UNITS)
      data    iBSflg /_MAX_BOOTSTRAP_UNITS * 0/
      save    iBSflg
CCC_   = Interior
      integer   j
      character Tag*(16)
CCC_  - Body (DBmngr)
      iErr = 0
      if (OFIRST) then
         OFIRST = .false.
         if (iErr.eq.0) call DBOmng(iErr, iBSsav, iBSflg)
         if (iErr.eq.0) call DBImng(iErr, iBSsav, iBSflg)
      endif
c
      if (iErr.eq.0) then
         do j = 1, _MAX_BOOTSTRAP_UNITS
            ibsA(j) = iBSsav(j)
         enddo
      else
         do j = 1, _MAX_BOOTSTRAP_UNITS
            ibsA(j) = -99
         enddo
      endif
c
      RETURN
CCC_  & DBdatt  ## Development/Bootstrap dettach/attach input file
      entry DBdatt
     O    (iErr, ibsA,
     I     FILE)
      iErr = 0
      if (OFIRST) iErr = 1
      if (iErr.eq.0) call DBattI (iErr, iBSsav, FILE)
      if (iErr.eq.0) then
         do j = 1, _MAX_BOOTSTRAP_UNITS
            ibsA (j) = iBSsav (j)
         enddo
      else
         do j = 1, _MAX_BOOTSTRAP_UNITS
            ibsA (j) = -99
         enddo
      endif
      RETURN
CCC_  & DBswpO  ## Development/Bootstrap sweeper
      entry DBswpO
     O    (iErr,
     I     IFP, idxB, ONOTAG)
CCC_  - To do: logical and operation
      iErr = 0
      if (iBSflg (idxB).eq.0) then
         continue
      else if (ONOTAG) then
         call DBOswi (iErr, iBSsav (idxB), IFP, ' ')
      else
         if (idxB .eq. _IDX_BOOTSTRAP_ERR) then
            Tag = '(E) '
         else if (idxB .eq. _IDX_BOOTSTRAP_OUT) then
            Tag = '(O) '
         else
 101        format ('(', I2.2, ') ')
            write (Tag, 101) idxB
         endif
         call DBOswi (iErr, iBSsav (idxB), IFP, Tag)
      endif
      call DBDtrc (iErr, 'DBSWPO')
      RETURN
CCC_   . End (DBmngr)
      END
CCC_ & DBswpT  ## Development/Bootstrap sweeper (tag argument)
      subroutine DBswpT
     O    (iErr,
     I     ifpO, ifpE, ONOTAG)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(IN, integer) ifpO, ifpE
      _INTENT(IN, logical) ONOTAG
CCC_  - Body
      iErr = 0
      call DBswpO (iErr, ifpO, _IDX_BOOTSTRAP_OUT, ONOTAG)
      if (iErr.eq.0)
     $     call DBswpO (iErr, ifpE, _IDX_BOOTSTRAP_ERR, ONOTAG)
      RETURN
      END
CCC_ & DBswpW  ## Development/Bootstrap sweeper wrapper
      subroutine DBswpW
     O    (iErr,
     I     ifpO, ifpE)
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(IN, integer) ifpO, ifpE
      call DBswpT (iErr, ifpO, ifpE, .false.)
      RETURN
      END
CCC_* Output manager
CCC_ & DBOmng  ## Development/Bootstrap manager [Output/Error]
      subroutine DBOmng
     O    (iErr, ibsA, iBSflg)
CCC_  - Description
CC    Prepare arguments for DBcorO () using system environments.
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(OUT,integer) ibsA(*), iBSflg(*)
CCC_  - Body
      iErr = 0
CCC_   . standard error
      call DBOwrp
     $    (iErr, BOOTSTRAP_ERR(ibsA), BOOTSTRAP_ERR(iBSflg),
     $     'ERROR',  'STDERR')
CCC_   . standard output
      call DBOwrp
     $    (iErr, BOOTSTRAP_OUT(ibsA), BOOTSTRAP_OUT(iBSflg),
     $     'OUTPUT', 'STDOUT')
c
      if (BOOTSTRAP_OUT(ibsA).lt.0) iErr = -1
      RETURN
      END
CCC_ & DBOwrp  ## Development/Bootstrap manager [Output] wrapper
      subroutine DBOwrp
     O    (iErr, IBSO, iFlg,
     I     Tag1, Tag2)
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   IBSO
      _INTENT(OUT,integer)   iFlg
      _INTENT(IN, character) Tag1*(*), Tag2*(*)
CCC_   = Interior
      character BFILE*(OPT_FILENAME_MAX)
      integer   ISTD
      integer   KIFX
CC  when exists  0 error
CC               1 append
CC               2 clear
      character EnvFIL*(40)
      character EnvIFX*(40)
      character EnvUNT*(40)
CCC_  - Body
      iErr = 0
CCC_   . Create environment names
 101  format ('BOOTSTRAP_', A)
 102  format ('BOOTSTRAP_', A, '_IFEXISTS')
 103  format (A, '_UNIT')
      write (EnvFIL, 101) _TRIM(Tag1)
      write (EnvIFX, 102) _TRIM(Tag1)
      write (EnvUNT, 103) _TRIM(Tag2)
CCC_   . Get environments
      BFILE = ' '
      call DEgetA (iErr, BFILE, EnvFIL)
      if (BFILE.eq.'/') BFILE = ' '
c
      KIFX = 0
      call DEgetI (iErr, KIFX,  EnvIFX)
c
      call UUdefU (ISTD, Tag1)
      call DEgetI (iErr, ISTD,  EnvUNT)
c
      call DBcorO (iErr, IBSO, iFlg,    BFILE, KIFX, ISTD)
c
      RETURN
      END
CCC_ & DBcorO  ## Development/Bootstrap manager core [Output]
      subroutine DBcorO
     O    (iErr,   IBSO,  iFlg,
     I     Bfile,  Kifx,  Istd)
CCC_  - Description
CC    Present bootstrap output unit IBSO according to the arguments.
CCC_   . Priority
CC       - if BFILE is not blank      use BFILE.
CC       - if standard unit ISTD > 0  use ISTD
CC       - else                       use scratch and set sweep flag
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   IBSO
      _INTENT(OUT,integer)   iFlg
      _INTENT(IN, character) Bfile*(*)
      _INTENT(IN, integer)   Kifx
      _INTENT(IN, integer)   Istd
CCC_  - Body
      call UUmngI (0)
      iFlg = 0
c
      if (Bfile .ne. ' ') then
         call DBOfil (iErr, IBSO, Bfile, Kifx)
      else if (Istd.ge.0) then
         IBSO = iStd
      else
         call DBOscr (iErr, IBSO)
         iFlg = iFlg + _FLG_NEED_SWEEP
      endif
c     register unit IBS in the blacklist
      call UUMCsf (IBSO, -1)
      RETURN
      END
CCC_ & DBOfil  ## Development/Bootstrap[O] kind file
      subroutine DBOfil
     O    (iErr,  IBS,
     I     Bfile, Kflag)
CCC_  - Description
CC    Open BFILE as output and connect to unit IBS.
CC    When BFILE exists, result depends on KFLAG.
CCC_  - Declaration
      implicit none
CCC_   = Parameter
      integer    ifxErr,     ifxApp,     ifxClr
      parameter (ifxErr = 0, ifxApp = 1, ifxClr = 2)
CCC_   = Arguments
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   iBS
      _INTENT(IN, character) Bfile*(*)
      _INTENT(IN, integer)   Kflag
CCC_   = Interior
      logical   Oex
CCC_  - Body
      iErr = 0
      call UUMCnu (iErr, IBS)
      if (iErr.eq.0) then
         call UUqfex (iErr, Oex, Bfile)
      endif
      if (iErr.eq.0) then
         if (Oex) then
            if (Kflag .eq. ifxErr) then
               iErr = -1
            else if (Kflag .eq. ifxApp) then
               call UUopen
     $             (iErr, IBS,
     $              Bfile, 0, 'F', 'O', 'RW', 'APPEND')
            else if (Kflag .eq. ifxClr) then
               call UUopen (iErr, IBS, Bfile, 0, 'F', 'R', 'RW', ' ')
            else
               iErr = -99
            endif
         else
            call UUopen (iErr, IBS, Bfile, 0, 'F', 'N', 'RW', ' ')
         endif
         if (iErr.ne.0) IBS = -1
      endif
      RETURN
      END
CCC_ & DBOscr  ## Development/Bootstrap[O] kind scratch
      subroutine DBOscr
     O    (iErr, IBS)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(OUT,integer) IBS
CCC_  - Body
      call UUMCnu (iErr, IBS)
      if (iErr.eq.0) call UUopnS (iErr, IBS, 0, 'F')
      if (iErr.ne.0) IBS = -1
      RETURN
      END
CCC_ & DBOswi  ## Bootstrap output sweeper (interior)
      subroutine DBOswi (iErr, IU, IFP, P)
CCC_  - Description
CC    Sweep scratch IU to file IFP and reopen IU.
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   IU, IFP
      _INTENT(IN, character) P*(*)
CCC_   = Interior
      integer iEr, iEw
CCC_  - Body
      iErr = 0
      if (IU.eq.IFP) then
         continue
      else
         if (iErr.eq.0) rewind (UNIT = IU, IOSTAT = iErr)
         if (iErr.eq.0) then
            call UUcopy (iEr, iEw, IU, IFP, P)
CC reopen scratch
CC rewind is not good when no write executed after rewinding
CC         rewind (UNIT = IU, IOSTAT = iErr)
            call UUclsC (iErr, IU, ' ', ' ')
            call UUopnS (iErr, IU, 0, 'F')
         endif
         if (iErr.eq.0) then
            if (iEw.eq.0) then
               iErr = MAX (0, iEr)
            else
               iErr = iEw
            endif
         endif
      endif
      RETURN
      END
CCC_* Input manager
CCC_ & DBImng  ## Development/Bootstrap manager [Input]
      subroutine DBImng
     O    (iErr, ibsA, iBSflg)
CCC_  - Description
CC    Prepare arguments for DBcorI () using system environments.
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(OUT,integer) iErr
      _INTENT(OUT,integer) ibsA   (*)
      _INTENT(OUT,integer) iBSflg (*)
CCC_   = Interior
      integer   ISTD
c
      character BSYSIN*(OPT_FILENAME_MAX)
      character CSYSIN*(OPT_FILENAME_MAX)
      logical   OSWCRE, ORWD, OSWCLB
      integer   ISWCRE, IRWD, ISWCLB
CCC_  - Body
      iErr = 0
c
      BSYSIN = ' '
      ISWCRE = 0
      call DEgetA (iErr, BSYSIN, 'BOOTSTRAP_INPUT')
      call DEgetI (iErr, ISWCRE, 'CREATE_BOOTSTRAP')
      OSWCRE = (ISWCRE.ne.0)
      if (BSYSIN.eq.'/') BSYSIN = ' '
c
      call UUdefU (ISTD, 'I')
      IRWD = 0
      call DEgetI (iErr, ISTD,   'STDIN_UNIT')
      call DEgetI (iErr, IRWD,   'STDIN_CAN_REWIND')
      ORWD = (IRWD.ne.0)
c
      CSYSIN = ' '
      ISWclb = 0
      call DEgetA (iErr, CSYSIN, 'STDIN_COPY_FILE')
      call DEgetI (iErr, ISWCLB, 'CLOBBER_STDIN_COPY')
      OSWCLB = (ISWCLB.ne.0)
      if (CSYSIN.eq.'/') CSYSIN = ' '
c
      call DBcorI
     $    (iErr, BOOTSTRAP_IN(ibsA), BOOTSTRAP_IN(iBSflg),
     $     BSYSIN, OSWCRE, ISTD, ORWD, CSYSIN, OSWCLB)
c
      if (BOOTSTRAP_IN(ibsA).lt.0) iErr = -1
      RETURN
      END
CCC_ & DBcorI  ## Development/Bootstrap core [Input]
      subroutine DBcorI
     O    (iErr,   iBS,   iFlg,
     I     Bfile,  Ocreat,
     I     iStd,   Orwd,
     I     Cfile,  Oclobb)
CCC_  - Description
CC    Present bootstrap input unit IBS according to the arguments.
CCC_   . Priority
CC       - if BFILE is not blank      use BFILE.
CC       - if standard input ISTD > 0
CC         and its rewindable (ORWD)  use ISTD
CC       - else                       copy standard input to CFILE
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   iBS
      _INTENT(OUT,integer)   iFlg
      _INTENT(IN, character) Bfile*(*)
      _INTENT(IN, logical)   Ocreat
      _INTENT(IN, integer)   iStd
      _INTENT(IN, logical)   Orwd
      _INTENT(IN, character) Cfile*(*)
      _INTENT(IN, logical)   Oclobb
CCC_  - Body
      iErr = 0
      iFlg = 0
c
      call UUmngI (0)
c
      if (Bfile .ne. ' ') then
         call DBIfil (iErr, IBS, Bfile, Ocreat)
      else if (iStd.ge.0 .and. Orwd) then
         IBS = iStd
      else
         call DBIcpy (iErr, IBS, iStd, Cfile, Oclobb)
      endif
c     register unit IBS in the blacklist
      call UUMCsf (IBS, -1)
c
      RETURN
      END
CCC_ & DBattI  ## Development/Bootstrap manager [input attach]
      subroutine DBattI
     O    (iErr, ibsA, FILE)
CCC_  - Description
CC    Prepare arguments for DBcorI () using system environments.
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   ibsA (*)
      _INTENT(IN, character) FILE*(*)
CCC_   = Interior
      integer   ipI
CCC_  - Body
      iErr   = 0
      ipI    = BOOTSTRAP_IN(ibsA)
      call UUclsC (iErr, ipI, ' ', ' ')
      if (iErr.eq.0) then
         call UUopen (iErr, ipI, FILE, 0, 'F', 'O', 'R', ' ')
      endif
      RETURN
      END
CCC_ & DBIfil  ## Development/Bootstrap[I] kind file
      subroutine DBIfil
     O    (iErr,  IBS,
     I     Bfile, Ocreat)
CCC_  - Description
CC    Open BFILE and return destination unit IBS.
CC    Create BFILE when not exists if OCREAT.
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   iBS
      _INTENT(IN, character) Bfile*(*)
      _INTENT(IN, logical)   Ocreat
CCC_  - Body
      iErr = 0
      call UUMCnu (iErr, IBS)
      if (iErr.eq.0) then
         if (Ocreat) then
            call UUopOC (iErr, IBS, Bfile, 0, 'F', 'R', ' ')
         else
            call UUopen (iErr, IBS, Bfile, 0, 'F', 'O', 'R', ' ')
         endif
         if (iErr.ne.0) IBS = -1
      endif
      RETURN
      END
CCC_ & DBIcpy  ## Development/Bootstrap[I] kind copy
      subroutine DBIcpy
     O    (iErr, IBS,
     I     iStd, Cfile, Oclobb)
CCC_  - Description
CC    Copy file content of unit ISTD to CFILE or scratch,
CC    and return destination unit IBS.
CC    Use scratch if blank CFILE.
CC    Clobber CFILE if OCLOBB.
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   IBS
      _INTENT(IN, integer)   iStd
      _INTENT(IN, character) Cfile*(*)
      _INTENT(IN, logical)   Oclobb
CCC_   = Interior
      integer   jEw, jEr
CCC_  - Body
      call UUMCnu (iErr, IBS)
      if (iErr.eq.0) then
         if (Cfile .eq. ' ') then
            call UUopnS (iErr, IBS, 0, 'F')
         else if (Oclobb) then
            call UUopen (iErr, IBS,  Cfile,  0, 'F', 'W', 'R', ' ')
         else
            call UUopen (iErr, IBS,  Cfile,  0, 'F', 'N', 'W', ' ')
         endif
      endif
      if (iErr.eq.0) then
         call UUcopy (jEr, jEw, iStd, IBS, ' ')
         if (jEw.eq.0) then
            iErr = MAX (0, jEr)
         else
            iErr = jEw
         endif
      endif
      RETURN
      END
CCC_* Debug
CCC_ & DBDtrc  ## Bootstrap debug trace
      subroutine DBDtrc (iErr, CMDL)
      implicit none
      _INTENT(IN,integer)   iErr
      _INTENT(IN,character) CMDL*(*)
 101  format ('BOOTSTRAP TRACE [', A, '] ', I7)
      if (iErr.ne.0) then
         write (*, 101) CMDL, iErr
      endif
      RETURN
      END
CCC_& DBSTRP  ## Development/Bootstrap announcement
      subroutine DBSTRP (STRA, STRB, IOP)
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
#ifdef TEST_DBSTRP
CCC_ @ DBTEST  ## Development/Bootstrap test
CCC_  - Test suites
CC::   SOURCES denvms.F
      program DBTEST
CCC_  - Declaration
      implicit none
CCC_   = Configuration
      integer   IX, J, K
      namelist /NITEST/ J, K, IX
CCC_   = Interior
      integer ibsA (_MAX_BOOTSTRAP_UNITS)
      integer iErr, IBI, IBO, IBE
      integer IOS
CCC_  - Body
      call DBmngr (iErr, ibsA)
      IBI = BOOTSTRAP_IN(ibsA)
      IBO = BOOTSTRAP_OUT(ibsA)
      IBE = BOOTSTRAP_ERR(ibsA)
c
      write (IBO, *) 'O', iErr, IBI, IBO, IBE
c
      if (iErr.ne.0) then
         write (IBE, *) 'ERROR', iErr
      else
         do k = 0, 1
            rewind (unit = IBI, IOSTAT = IOS)
            j = 0
            do
               IX = -999
               if (IOS.eq.0)
     $              read (unit = IBI, IOSTAT = IOS, NML = NITEST)
               if (IOS.ne.0) goto 190
               write (IBO, NITEST)
               j = j + 1
            enddo
 190        continue
         enddo
      endif
c
      call DEBrep (IBO)
c
      call DBswpW (iErr, -1, -1)
c
      STOP
      END
CCC_ + end
#endif
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
