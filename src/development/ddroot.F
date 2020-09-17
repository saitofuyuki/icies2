C development/ddroot.F --- IcIES/Development root
C Maintainer:  SAITO Fuyuki
C Created: Mar  3 2010
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2020/09/15 11:47:46 fuyuki ddroot.F>'
#define _FNAME 'development/ddroot.F'
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
#include "ofnstd.h"
#include "odevel.h"
#include "TreeID"
#ifndef   GIT_INFOs
#  define GIT_INFOs 'none'
#endif
CCC_* Alla Breve
CCC_ & DevDev  ## Development/Development
      subroutine DevDev
     O     (iErr)
      implicit none
      _INTENT(OUT,integer) iErr
      call DDcapo (iErr, 2, ' ', ' ', ' ', -1)
      return
      END
CCC_ & DDmdef  ## Development/Development (mpi/default)
      subroutine DDmdef
     O    (iErr,
     I     FNM)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, character) FNM*(*)
      call DDcapo (iErr, 2, ' ', 'O', FNM, -1)
      return
      END
CCC_ & DDsmpl  ## Development/Development (simple)
      subroutine DDsmpl
     O     (iErr)
      implicit none
      _INTENT(OUT,integer) iErr
      call DDcapC (iErr, 0, '%!', ' ', ' ', -1, 'A')
      return
      END
CCC_ & DDnull  ## Development/Development (null)
      subroutine DDnull
     O     (iErr)
      implicit none
      _INTENT(OUT,integer) iErr
      call DDcapC (iErr, 0, '%!', ' ', ' ', -1, 'N')
      return
      END
CCC_* Capo
CCC_ & DDcapo  ## Development/core Capo
      subroutine DDcapo
     O    (iErr,
     I     KSPLT,
     I     DTMPL, TOP, EXE, KEXE)
      implicit none
      _INTENT(INOUT,integer)   iErr
      _INTENT(IN,   character) DTMPL*(*)
      _INTENT(IN,   character) TOP*(*)
      _INTENT(IN,   character) EXE*(*)
      _INTENT(IN,   integer)   KEXE,  KSPLT
      call DDcapC
     O    (iErr,
     I     KSPLT,
     I     DTMPL, TOP, EXE, KEXE, 'B')
      RETURN
      END
CCC_ & DDcapC  ## Development/core Capo core
      subroutine DDcapC
     O    (iErr,
     I     KSPLT,
     I     DTMPL, TOP, EXE, KEXE, CLOGD)
CCC_  - Declaration
      implicit none
      _INTENT(INOUT,integer)   iErr
      _INTENT(IN,   character) DTMPL*(*)
      _INTENT(IN,   character) TOP*(*)
      _INTENT(IN,   character) EXE*(*)
      _INTENT(IN,   character) CLOGD*(*)
      _INTENT(IN,   integer)   KEXE,  KSPLT
c
      character  BMSG0*(*)
      parameter (BMSG0 = 'WELCOME TO THE IcIES WORLD...')
      integer ibsA (_MAX_BOOTSTRAP_UNITS)
      integer ipA  (LOG_CHANNEL_MAX)
c
      character  Btmp*(80)
      integer    LvlIni
CCC_  - Body
      iErr   = 0
      LvlIni = 0
CCC_   . Environment and Arguments
      if (iErr.eq.0) call DEmngr (iErr)
CCC_   . MPI/Bootstrap initialization suite
      if (iErr.eq.0) call DMinit (iErr, ibsA, 1, KSPLT, LvlIni)
c$$$CCC_  * MPI color manipulation
c$$$      if (iErr.eq.0) call DMUcfg (iErr, ibsA)
c$$$      if (iErr.eq.0) call DMUcfg (iErr, ibsA)
      if (CLOGD.ne.'N') then
         if (iErr.eq.0) then
            call DevBnB (ibsA, BMSG0)
            call DDxidR (iErr)
            DO
               call DDxidG (iErr, Btmp)
               if (iErr.ne.0) goto 200
               call DevBnB (ibsA, Btmp)
            ENDDO
 200        continue
            iErr = 0
 101        format (A, ':', I12.12)
 103        format ('*:', I12.12)
            if (EXE.ne.' ') then
               if (KEXE.ge.0) then
                  write (Btmp, 101) _TRIM(EXE), KEXE
               else
                  Btmp = EXE
               endif
            else if (KEXE.ge.0) then
               write (Btmp, 103) KEXE
            else
               Btmp = ' '
            endif
            if (Btmp.ne.' ') call DevBnB (ibsA, Btmp)
         endif
      endif
CCC_   . System diagnosis
      if (CLOGD.ne.'N') then
         if (iErr.eq.0) call DAdsyB (iErr, ibsA)
      else
         if (iErr.eq.0) call DAdsys (iErr, -2)
         if (iErr.eq.0) call UUiosq (iErr)
      endif
CCC_   . Template default
      if (iErr.eq.0) call DPinit (iErr, DTMPL, TOP, EXE, KEXE)
CCC_   . Default input/log manipulation
      if (CLOGD.eq.'B') then
         if (iErr.eq.0) call DLinit (iErr, ibsA)
      else if (CLOGD.eq.'A') then
         if (iErr.eq.0) call DLiniA (iErr, ibsA)
      else if (CLOGD.eq.'N') then
         if (iErr.eq.0) call DLiniN (iErr, ibsA)
      else
         if (iErr.eq.0) call DLinit (iErr, ibsA)
      endif
CCC_   . Development/Log channels
      if (iErr.eq.0) call DevChn (ipA)
      if (iErr.eq.0) call DLZswp (iErr, ipA)
CCC_   . Run-time tables
      if (iErr.eq.0) call DDrune (iErr, ipA)
CCC_   . return
      call DAtrcA (ipA, iErr, 'R', 'DEVDEV')
      RETURN
      END
CCC_* Fermata
CCC_ & DevFin  ## Development/Finale
      subroutine DevFin
     M     (iErr)
      implicit none
      _INTENT(INOUT,integer) iErr
      call DDfine (iErr, -1, -1, 'A')
      return
      END
CCC_ & DFnull  ## Development/Finale/silent
      subroutine DFnull
     M     (iErr)
      implicit none
      _INTENT(INOUT,integer) iErr
      call DDfine (iErr, -3, -3, 'N')
      return
      END
CCC_* Fine
CCC_ & DDfine  ## Development/core Fine
      subroutine DDfine
     M    (iErr,
     I     iswpO, iswpE, CLOGD)
CCC_  - Declaration
      implicit none
      _INTENT(INOUT,integer)   iErr
      _INTENT(IN,   integer)   iswpO, iswpE
      _INTENT(IN,   character) CLOGD*(*)
c
      character  BMSG8*(*)
      character  BMSG9*(*)
      parameter (BMSG8 = 'HELP ME!!!')
      parameter (BMSG9 = 'HAVE A GOOD TIME!!!')
      integer ipA  (LOG_CHANNEL_MAX)
      integer irepU
CCC_  - Body
CCC_   . get report unit
      call DevChn (ipA)
      if (iErr.eq.0 .and. CLOGD.eq.'N') then
         irepU = -3
      else
         call DLDrpU (irepU, FPF(ipA))
      endif
CCC_   . sub report
      call DEBrep (irepU)
      call DPBrep (irepU)
      call DLDrep (irepU)
      if (iErr.eq.0) then
         if (CLOGD.ne.'N')
     $        call DevBnA (ipA, BMSG9)
      else
         call DevBnA (ipA, BMSG8)
      endif
CCC_   . sweeper
      call DBswpW (iErr, iswpO, iswpE)
CCC_   . MPI finalization
      call DMWfin (iErr)
      RETURN
      END
CCC_* Other bookends
CCC_ & DDcmin  ## Development/Development (coupling minimum)
      subroutine DDcmin
     O    (iErr)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      integer ibsA (_MAX_BOOTSTRAP_UNITS)
      integer LvlIni
CCC_  - Body
      iErr   = 0
      LvlIni = -1
      if (iErr.eq.0) call DMinit (iErr, ibsA, 0, 0, LvlIni)
      RETURN
      END
CCC_ & DDfmin  ## Development/Fine (coupling minimum)
      subroutine DDfmin
     O     (iErr)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer) iErr
CCC_  - Body
      iErr = 0
      call DMWfin (iErr)
      RETURN
      END
CCC_* banner
CCC_ & DevBnB  ## Development banner/B
      subroutine DevBnB (ibsA, BMSG)
      implicit none
      _INTENT(IN,integer)   ibsA  (*)
      _INTENT(IN,character) BMSG *(*)
      call DAbnrB (ibsA, BMSG)
      call DAbnrU (-1,   BMSG)
      RETURN
      END
CCC_ & DevBnA  ## Development banner/A
      subroutine DevBnA (ipA, BMSG)
      implicit none
      _INTENT(IN,integer)   ipA   (*)
      _INTENT(IN,character) BMSG *(*)
      call DAbnrA (ipA, BMSG)
      call DAbnrU (-1,  BMSG)
      RETURN
      END
CCC_* other development wrappers
CCC_ & DVHrgC ## alias for DDPrgC
      subroutine DVHrgC
     O    (iErr,
     I     CLS,  DROOT, DTMPL, ipA)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, character) CLS*(*), DROOT*(*), DTMPL*(*)
      _INTENT(IN, integer )  ipA (*)
      call DDPrgC (iErr, CLS, DROOT, DTMPL, ipA)
      RETURN
      END
CCC_ & DDPrgC ## template class registration (old DVHrgC)
      subroutine DDPrgC
     O    (iErr,
     I     CLS,  DROOT, DTMPL, ipA)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, character) CLS*(*), DROOT*(*), DTMPL*(*)
      _INTENT(IN, integer )  ipA (*)
      iErr = 0
      call DPUrgs
     O    (iErr,
     I     FPP(ipA), FPC(ipA), FPL(ipA), CLS, DROOT, DTMPL)
      RETURN
      END
CCC_* Misc
CCC_ & DDxidm  ## Development/Tree ID manager
      subroutine DDxidm (iErr)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, character) StrI*(*)
      _INTENT(OUT,character) StrO*(*)
      integer    Lbuf,      Lid
      parameter (Lbuf = 16, Lid=40)
      character BufID(0:Lbuf)*(Lid)
      data      BufID
     $    / GIT_INFOs,
     $      Lbuf * ' '/
      save      BufID
      integer   Mid
      data      Mid / 0 /
      save      Mid
      integer   idC
      data      idC / 0 /
      save      idC
CCC_  - Body
      iErr = 0
      return
CCC_  & DDxidR ## reset
      entry DDxidR (iErr)
      iErr = 0
      idC  = 0
      RETURN
CCC_  & DDxidP ## store
      entry DDxidP (iErr, StrI)
      idC = idC + 1
      Mid = Min (Lid, Max (Mid, idC))
      if (idC.gt.Lid) then
         iErr = -1
      else
         iErr = 0
         BufID(idC) = StrI
      endif
      RETURN
CCC_  & DDxidG ## restore
      entry DDxidG (iErr, StrO)
      if (idC.le.Mid) then
         StrO = BufID(idC)
         idC  = idC + 1
         iErr = 0
      else
         StrO = ' '
         iErr = 1
      endif
      RETURN
CCC_  - End
      END
CCC_ & DevChn  ## Development channels
      subroutine DevChn
     O    (ipA)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer) ipA (*)
      logical OFIRST
      data    OFIRST /.true./
      save    OFIRST
      integer ipAsav (LOG_CHANNEL_MAX)
      data    ipAsav /LOG_CHANNEL_MAX * -1/
      save    ipAsav
      integer j
CCC_  - Body
      if (OFIRST) then
         OFIRST = .false.
         call DLCmnD (ipAsav, 'D')
      endif
      do j = 1, LOG_CHANNEL_MAX
         ipA (j) = ipAsav (j)
      enddo
      RETURN
      END
CCC_ & DDrune  ## Development/run-time environment
      subroutine DDrune (iErr, ipA)
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(IN, integer) ipA (*)
      iErr = 0 * ipA (1)
      call DEPtid (iErr, GIT_INFOs)
      RETURN
      END
CCC_@ DDTEST  ## Development/development test
#ifdef TEST_DDROOT
      program DDTEST
CCC_ + Test suites
CC::   SOURCES dlogms.F
      implicit none
      integer   iErr
      call DevDev (iErr)
      call DevFin (iErr)
      STOP
      END
#endif /* TEST_DDROOT */
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
