C development/dmpims.F --- IcIES/Development/MPI management
C Maintainer:  SAITO Fuyuki
C Created: Feb 25 2010
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2020/09/17 08:42:57 fuyuki dmpims.F>'
#define _FNAME 'development/dmpims.F'
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
CCC_* Policy
CC    DMU* user modules (mainly called outside)
CC    DMC* core modules (mainly called internally)
CC    DMP* DPathN wrapper modules
CC    DMW* MPI wrappers
CC    DMA* MPI attributes assembly
CC    DMZ* miscellaneous modules
CCC_* Macro definition
CCC_ + mpi environement
#ifndef   OPT_USE_MPI
#  define OPT_USE_MPI 0
#endif
CC OPT_USE_MPI    1 if use mpi else 0
CC                You can use mpi and tranditional serial mode
CC                at the same time.  This is useful for, e.g.,
CC                MIROC/Rainbow-like execution.
CCC_ + tests
#ifndef   TEST_DMPIMS
#  define TEST_DMPIMS 0
#endif
#if   TEST_DMPIMS == 1
#  undef  OPT_USE_MPI
#  define OPT_USE_MPI 0 /* force non-MPI check */
#elif TEST_DMPIMS == 2
#  undef  OPT_USE_MPI
#  define OPT_USE_MPI 1 /* force MPI check */
#endif
CCC_ + external
#include "ofdlct.h" /* fortran dialect */
#include "ologfm.h" /* logging */
#include "odevel.h"
#include "ounelv.h" /* namelist emulation levels */
CCC_ + mpi properties
#if OPT_USE_MPI
#  if REAL_STD_KIND == REAL_DOUBLE_KIND
#    define _MPI_REALSTD MPI_REAL8
#  elif REAL_STD_KIND == REAL_FLOAT_KIND
#    define _MPI_REALSTD MPI_REAL4
#  else
#    define _MPI_REALSTD MPI_REAL
#  endif
#endif /* OPT_USE_MPI */
CCC_ + option
#ifndef    OPT_DMPIMS_NRMAX  /* maximum processes (buffer) */
#  define  OPT_DMPIMS_NRMAX 128
#endif
#ifndef    OPT_NAMELIST_OUTPUT_EMULATION
#  define  OPT_NAMELIST_OUTPUT_EMULATION _UNMLEM_LEVEL_END
#endif
CCC_ + common
#define _ROOT_COLOR_NAME 'WORLD'
CCC_& DMinit  ## Development/MPI initialization suite
      subroutine DMinit
     O    (iErr,  ibsA,
     I     kTest, kSplt, LvlIni)
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(OUT,integer) ibsA(*)
      _INTENT(IN, integer) kTest
      _INTENT(IN, integer) kSplt
      _INTENT(IN, integer) LvlIni
      integer j
      iErr = 0
      if (iErr.eq.0) call DMUini (iErr, LvlIni)
      if (iErr.eq.0) call DMUbst (iErr, ibsA, kTest)
      do j = 1, kSplt
         if (iErr.eq.0) call DMUcfg (iErr, ibsA)
      enddo
      RETURN
      END
CCC_* [DMU] User modules
CCC_ & DMUini  ## Development/MPI Capo collection
      subroutine DMUini
     O    (iErr,
     I     LvlIni)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(IN, integer) LvlIni
      integer iMAW (MAX_MPI_ATTR)
      integer iCommW, iCommN
CCC_  - Body
      iErr = 0
CCC_   . common
      call DMWini (iErr)
c
      if (iErr.eq.0) call DMZqcn (iErr, iCommW, 'COMM_WORLD')
      if (iErr.eq.0) call DMZqcn (iErr, iCommN, 'COMM_NULL')
CCC_   . iMAW construction (WORLD)
      if (iErr.eq.0) call DMArst (iMAW)
      if (iErr.eq.0) call DMAput (iMAW, iCommW, 'CO')
      if (iErr.eq.0) call DMAput (iMAW, iCommN, 'PC')
      if (iErr.eq.0) call DMAput (iMAW, 0,      'NC')
      if (iErr.eq.0) call DMAput (iMAW, 0,      'IC')
      if (iErr.eq.0) call DMAput (iMAW, 0,      'LV')
CCC_   . get ranks properties
      if (iErr.eq.0) call DMArnq (iErr, iMAW)
CCC_   . push default parent communicator.
CC    need to correct before calling DMcfgC ().
      if (iErr.eq.0) call DMApsh (iMAW, _ROOT_COLOR_NAME)
CCC_   . template (level 0)
      if (LvlIni.ge.0) then
CCC_    * put templates
         if (iErr.eq.0) call DMAfst (iErr, iMAW, _ROOT_COLOR_NAME)
CCC_    * put template aliases
         if (iErr.eq.0) call DMAfsa (iErr, 0)
      endif
c
      RETURN
      END
CCC_ & DMUbst  ## Development/MPI standard/bootstrap
      subroutine DMUbst
     O    (iErr, ibsA,
     I     kTest)
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   ibsA (*)
      _INTENT(IN, integer)   kTest
CCC_   = Interior
      integer   ipI,  ipO, ipE
      integer   KMAX
      integer   IOS, Icomm, IR, NR
      integer   imaP (MAX_MPI_ATTR)
      character CclrP*(DMPIMS_COLOR_NAME_LEN)
CCC_   = Namelist
      character FILE*(OPT_FILENAME_MAX)
      integer   KCHECK
      namelist  /NIDMBS/ KCHECK, FILE
CCC_  - Body
      iErr = 0
      call DBmngr (iErr, ibsA)
      ipI  = -1
      ipO  = -1
      ipE  = -1
c
      if (iErr.eq.0) then
         ipI  = BOOTSTRAP_IN(ibsA)
         ipO  = BOOTSTRAP_OUT(ibsA)
         ipE  = BOOTSTRAP_ERR(ibsA)
      endif
c
      if (iErr.eq.0) then
         call DMAtop (imaP, CclrP)
         call DMAget (Icomm, imaP, 'CO')
         call DMAget (IR,    imaP, 'IR')
         call DMAget (NR,    imaP, 'NR')
      endif
c
 101  format ('DMUBST[', I2, '] START ERROR = ', I4)
 109  format ('DMUBST[', I2, '] END ERROR = ', I4)
c
      write (ipE, 101) kTest, iErr
      if (kTest.eq.0) then
         continue
      else if (NR.le.1) then
         continue
      else if (iErr.eq.0) then
         call UUrwnd (IOS,  ipI)
         KMAX   = -1
         KCHECK = -1
         if (IOS .eq. 0) then
            KCHECK = 0
            FILE   = ' '
            if (ipI.ge.0) then
               read (ipI, NIDMBS, IOSTAT = IOS)
            else
               read (*,   NIDMBS, IOSTAT = IOS)
            endif
            write (ipO, NIDMBS)
            if (IOS .ne. 0) KCHECK = -2
         endif
         call DMWami (iErr, KMAX, KCHECK, Icomm)
         if (iErr .ne. 0) then
            KCHECK = -3
         endif
         if (KCHECK.le.0) then
            if (KCHECK.eq.0 .and. KMAX.eq.0) then
               iErr = 0
            else
               iErr = 1
            endif
         else
            iErr = 0
         endif
 201     format ('DMUBST: ', I3, 1x, 2I3)
         write (ipE, 201) iErr, KCHECK, KMAX
 301     format ('DMUBST: PROBLEM IN REWIND ', I3)
 302     format ('DMUBST: PROBLEM IN NIDMBS ', I3)
 303     format ('DMUBST: PROBLEM IN REDUCE ', I3)
         if (KCHECK.eq.-1) then
            write (ipE, 301) IR
         else if (KCHECK.eq.-2) then
            write (ipE, 302) IR
         else if (KCHECK.eq.-3) then
            write (ipE, 303) IR
         endif
         call DMZecr (iErr, Icomm, IR, NR)
 401     format ('DMUBST: TRY TO ATTACH ', I3, 1x, A)
         if (iErr.ne.0) then
            call DMWbca (iErr, FILE, 0, ICOMM)
            if (iErr.eq.0.and.FILE.ne.' ') then
               write (ipE, 401) IR, _TRIM(FILE)
               call DBdatt (iErr, ibsA, FILE)
            else
               iErr = 1
            endif
         endif
         call DMZecr (iErr, Icomm, IR, NR)
      endif
      write (ipE, 109) kTest, iErr
      RETURN
      END
CCC_ & DMUcfg  ## Development/MPI manager configuration
      subroutine DMUcfg
     O    (iErr,
     I     ibsA)
CCC_  - Description
CC        - pop current communicator from the storage
CC        - split
CC        - push the new communicator to the storege
CC        Communicator tag is used to distinct the splitting
CC        configuration.
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   ibsA (*)
CCC_   = Interior
      integer   iMAP (MAX_MPI_ATTR)
      integer   iMAC (MAX_MPI_ATTR)
      character CclrP*(DMPIMS_COLOR_NAME_LEN)
      character CclrC*(DMPIMS_COLOR_NAME_LEN)
      integer   ipE
CCC_  - Body
      iErr = 0
      ipE  = BOOTSTRAP_ERR(ibsA)
      call DMArst (iMAP)
      call DMArst (iMAC)
CCC_   . pop parent communicator
      if (iErr.eq.0) call DMAtop (iMAP, CclrP)
CCC_   . call split core
      if (iErr.eq.0) call DMCcfg (iErr, iMAC, CclrC, iMAP, CclrP, ibsA)
CCC_   . get rank information in child communicator
      if (iErr.eq.0) call DMArnq (iErr, iMAC)
CCC_   . push communicator attributes
      if (iErr.eq.0) call DMApsh (iMAC, CclrC)
CCC_   . push attributes into file template
      if (iErr.eq.0) call DMAfst (iErr, iMAC, CclrC)
CCC_   . messages
      call DMAmsg (ipE, IMAP, CclrP, 'p')
      call DMAmsg (ipE, IMAC, CclrC, 'c')
CCC_   . fine
      call DAtrcB (ibsA, iErr, 'R', 'DMUCFG')
      RETURN
      END
CCC_ & DMUrnk  ## Development/MPI query rank and size
      subroutine DMUrnk (IRNK, NRNK)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer) IRNK, NRNK
CCC_  - Body
      call DMAti1 (IRNK, _IDX_MPI_RANK)
      call DMAti1 (NRNK, _IDX_MPI_NRANKS)
      RETURN
      END
CCC_* [DMC] Core modules
CCC_ & DMCcfg  ## Development/MPI manager configuration
      subroutine DMCcfg
     O    (iErr,
     O     iMAC, CclrC,
     I     iMAP, CclrP, ibsA)
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(OUT,  integer)   iErr
      _INTENT(OUT,  integer)   iMAC (*)
      _INTENT(OUT,  character) CclrC*(*)
      _INTENT(INOUT,integer)   iMAP (*)
      _INTENT(IN,   character) CclrP*(*)
      _INTENT(IN,   integer)   ibsA (*)
CCC_   = Interior
      integer              IcommC, LvC
      integer   IRP,  NRP, IcommP, LvP
      integer   ICLR, NCLR
      integer   IkeyC
      integer   ipI,  ipO, ipE
CCC_  - Body
      iErr = 0
      ipI  = BOOTSTRAP_IN(ibsA)
      ipO  = BOOTSTRAP_OUT(ibsA)
      ipE  = BOOTSTRAP_ERR(ibsA)
CCC_   . extract parent attributes
      call DMAget (IRP,    iMAP, 'IR')
      call DMAget (NRP,    iMAP, 'NR')
      call DMAget (IcommP, iMAP, 'CO')
      call DMAget (LvP,    iMAP, 'LV')
CCC_   . get color index
      if (iErr.eq.0) then
         call DMCcsc
     O       (iErr,
     O        ICLR,  NCLR,  IkeyC, CclrC,
     I        IRP,   NRP,   CclrP,
     I        ipI,   ipO,   ipE)
      endif
CCC_   . [MPI] need to circulate error before split
      call DMZecr (iErr, IcommP, IRP, NRP)
CCC_   . [MPI] communicator split
      if (iErr.eq.0)
     $     call DMWspc (iErr, IcommC, ICLR, CclrC, IkeyC, IRP, IcommP)
      if (iErr.eq.0)
     $     call DMZcch (iErr, NCLR, IcommP, IRP, NRP)
CCC_   . store results
      call DMAput (iMAC, IcommC, 'CO')
      call DMAput (iMAC, IcommP, 'PC')
      call DMAput (iMAC, ICLR,   'IC')
      call DMAput (iMAC, NCLR,   'NC')
      LvC = LvP + 1
      call DMAput (iMAC, LvC,    'LV')
CCC_   . fine
      call DAtrcB (ibsA, iErr, 'R', 'DMCCFG')
      RETURN
      END
CCC_* [DMC] MPI Color manipulation
CCC_ + To do
CC     use MPI_MAX_OBJECT_NAME for Color_name length when put/set
CC     pending: need null-termination when put?
CCC_ & DMCcsc  ## Development/MPI color split control
      subroutine DMCcsc
     O    (iErr,
     O     ICLR,  NCLR,  IkeyC, ClrC,
     I     IRNKP, NRNKP, ClrP,
     I     ipI,   ipO,   ipE)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   ICLR,  NCLR
      _INTENT(OUT,integer)   IkeyC
      _INTENT(OUT,character) ClrC*(*)
      _INTENT(IN, integer)   IRNKP, NRNKP
      _INTENT(IN, character) ClrP*(*)
      _INTENT(IN, integer)   ipI, ipO, ipE
CCC_  - Body
      iErr = 0
CCC_   . negative IkeyC will be replaced by split execution
      IkeyC = -1
CCC_   . namelist split (as MIROC/Rainbow)
      call DMCcsn
     O    (iErr,
     I     ICLR,  NCLR,  IkeyC, ClrC,
     I     IRNKP, NRNKP, ClrP,
     I     ipI,   ipO,   ipE)
c$$$      call DAtrcU (ipE, iErr, 'R', 'DMCCSC')
      RETURN
      END
CCC_ & DMCcsn  ## Development/MPI color split by namelist
      subroutine DMCcsn
     O    (iErr,
     O     ICLR,  NCLR,  IkeyC, ClrC,
     I     IRNKP, NRNKP, ClrP,
     I     ipI,   ipO,   ipE)
CCC_  - Declaration
      implicit none
CCC_   = Parameter
      integer    lClrNm
      parameter (lClrNm = DMPIMS_COLOR_NAME_LEN)
      integer    LVEML
      parameter (LVEML  = OPT_NAMELIST_OUTPUT_EMULATION)
CCC_   = Arguments
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   ICLR,  NCLR
      _INTENT(OUT,character) ClrC*(*)
      _INTENT(OUT,integer)   IkeyC
      _INTENT(IN, integer)   IRNKP, NRNKP
      _INTENT(IN, character) ClrP*(*)
      _INTENT(IN, integer)   ipI, ipO, ipE
CCC_   = Configuration
      character Pname*(lClrNm), Cname*(lClrNm), TSTR*(lClrNm)
      integer   ISPLR
      integer   IOSR
      namelist /NICLRS/ IOSR, ISPLR, Pname, Cname
CCC_   = Interior
      integer IOS
      integer IRP,    IRC
      integer IOSsav
      logical OEOF
      integer Inl
CCC_  - Body
      iErr    = 0
      IkeyC   = -1
c
      ICLR    = 0
      NCLR    = 0
      IRP     = -1
c
      ClrC    = ' '
      IOSR  = 0
c
      DO
         call UUrwnd (IOS,  ipI)
         INL    = 0
         IRC    = NRNKP + 1
         TSTR   = ' '
         IOSsav = IOS
c
         DO
            Pname = ' '
            Cname = ' '
            ISPLR = -1
c
            if (IOS .eq. 0) then
               if (ipI.ge.0) then
                  read (ipI, NICLRS, IOSTAT = IOS)
               else
                  read (*,   NICLRS, IOSTAT = IOS)
               endif
            endif
            call UUieof (OEOF, IOS)
            if (OEOF) goto 100
            INL = INL + 1
            if (IOS.ne.0) then
               iErr = iErr + 1
 301           format ('DMCCSN NICLRS ERROR (', I5, ') AT ', I4)
               if (COND_N(ipE)) then
                  write (ipE, 301) IOS, INL
               else if (COND_S(ipE)) then
                  write (*,   301) IOS, INL
               endif
               IOS = 0
            endif
c
            if (Pname .eq. ClrP) then
               if (ISPLR.eq.-9) goto 100
               if (ISPLR .ge. IRP
     $                 .and. ISPLR .lt. IRC) then
                  IRC    = ISPLR
                  TSTR   = Cname
                  IOSsav = IOS
               endif
            endif
         ENDDO
c
 100     continue
         if (IRC.ge.NRNKP) goto 200
c
         Pname = ClrP
         ISPLR = IRC
         Cname = Tstr
         IOSR  = IOSsav
         if (LVEML.gt.0) then
            call UNBbgn (iErr, 'NICLRS',       ipO, LVEML)
            call UNBint (iErr, 'IOSR',  IOSR,  ipO, LVEML)
            call UNBint (iErr, 'ISPLR', ISPLR, ipO, LVEML)
            call UNBstr (iErr, 'PNAME', PNAME, ipO, LVEML)
            call UNBstr (iErr, 'CNAME', CNAME, ipO, LVEML)
            call UNBend (iErr, 'NICLRS',       ipO, LVEML)
         else
            if (COND_N(ipO)) then
               write (ipO, NICLRS)
            else if (COND_S(ipO)) then
               write (*,   NICLRS)
            endif
         endif
c
         if (IRNKP.lt.IRC) then
            ICLR = ICLR + 1
         else
            ClrC = Tstr
         endif
         IRP  = IRC + 1
         NCLR = NCLR + 1
      ENDDO
c
 200  continue
CCC_   . Write fine always
      ISPLR = -9
      CNAME = 'fine'
      if (LVEML.gt.0) then
         call UNBbgn (iErr, 'NICLRS',       ipO, LVEML)
         call UNBint (iErr, 'IOSR',  IOSR,  ipO, LVEML)
         call UNBint (iErr, 'ISPLR', ISPLR, ipO, LVEML)
         call UNBstr (iErr, 'PNAME', PNAME, ipO, LVEML)
         call UNBstr (iErr, 'CNAME', CNAME, ipO, LVEML)
         call UNBend (iErr, 'NICLRS',       ipO, LVEML)
      else
         if (COND_N(ipO)) then
            write (ipO, NICLRS)
         else if (COND_S(ipO)) then
            write (*,   NICLRS)
         endif
      endif
c
      ICLR = NCLR - ICLR - 1
      if (NCLR .eq. 0) ICLR = 0
c
      RETURN
      END
CCC_* [DMA] MPI info assembly
CCC_ & DMAtma  ## Development/MPI get top MPI attributes
      subroutine DMAtma
     O    (iMA)
      implicit none
      _INTENT(OUT,integer)  iMA (*)
      character Ctmp*(DMPIMS_COLOR_NAME_LEN)
      call DMArst (iMA)
      call DMAtop (iMA, Ctmp)
      RETURN
      END
CCC_ & DMArst  ## Development/MPI attributes assembly reset
      subroutine DMArst
     O    (iMA)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iMA(*)
      integer   j
CCC_  - Body
      do j = 1, MAX_MPI_ATTR - 1
         iMA (j) = -999
      enddo
      iMA (_IDX_MPI_ERROR) = 0
      RETURN
      END
CCC_ & DMAget  ## Development/MPI attributes assembly get
      subroutine DMAget
     O    (iAttr,
     I     iMA,
     I     CK)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iAttr
      _INTENT(IN, integer)   iMA(*)
      _INTENT(IN, character) CK*(*)
CCC_  - Body
c$$$      iMA (_IDX_MPI_ERROR) = 0
      if      (CK (1:2).eq.'IR') then
         iAttr = iMA (_IDX_MPI_RANK)
      else if (CK (1:2).eq.'NR') then
         iAttr = iMA (_IDX_MPI_NRANKS)
      else if (CK (1:2).eq.'CO') then
         iAttr = iMA (_IDX_MPI_COMM)
      else if (CK (1:2).eq.'PC') then
         iAttr = iMA (_IDX_MPI_PARENT)
      else if (CK (1:2).eq.'IC') then
         iAttr = iMA (_IDX_MPI_COLOR)
      else if (CK (1:2).eq.'NC') then
         iAttr = iMA (_IDX_MPI_NCOLORS)
      else if (CK (1:2).eq.'LV') then
         iAttr = iMA (_IDX_MPI_LEVEL)
      else
c$$$         iMA (_IDX_MPI_ERROR) = -1
         iAttr = -1
      endif
      RETURN
      END
CCC_ & DMAput  ## Development/MPI attributes assembly put
      subroutine DMAput
     M    (iMA,
     I     iAttr,   CK)
CCC_  - Declaration
      implicit none
      _INTENT(INOUT,integer)   iMA(*)
      _INTENT(IN,   integer)   iAttr
      _INTENT(IN,   character) CK*(*)
CCC_  - Body
      iMA (_IDX_MPI_ERROR) = 0
      if      (CK (1:2).eq.'IR') then
         iMA (_IDX_MPI_RANK) = iAttr
      else if (CK (1:2).eq.'NR') then
         iMA (_IDX_MPI_NRANKS) = iAttr
      else if (CK (1:2).eq.'CO') then
         iMA (_IDX_MPI_COMM) = iAttr
      else if (CK (1:2).eq.'PC') then
         iMA (_IDX_MPI_PARENT) = iAttr
      else if (CK (1:2).eq.'IC') then
         iMA (_IDX_MPI_COLOR) = iAttr
      else if (CK (1:2).eq.'NC') then
         iMA (_IDX_MPI_NCOLORS) = iAttr
      else if (CK (1:2).eq.'LV') then
         iMA (_IDX_MPI_LEVEL) = iAttr
      else
         iMA (_IDX_MPI_ERROR) = -1
      endif
      RETURN
      END
CCC_ & DMArnq  ## Development/MPI attributes assembly query rank
      subroutine DMArnq
     O    (iErr,
     M     iMA)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer) iErr
      _INTENT(INOUT,integer) iMA (*)
      integer IR, NR, IComm
CCC_  - Body
      iErr = 0
      call DMAget (IComm, iMA, 'CO')
      call DMWrnk (IR, NR, IComm)
      call DMAput (iMA, IR, 'IR')
      call DMAput (iMA, NR, 'NR')
      RETURN
      END
CCC_ & DMAmsg  ## Development/MPI attributes assembly report
      subroutine DMAmsg (IP, iMA, Cclr, Tag)
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(IN,   integer)   IP
      _INTENT(INOUT,integer)   iMA  (*)
      _INTENT(IN,   character) Cclr*(*)
      _INTENT(IN,   character) Tag *(*)
CCC_   = Interior
      integer IR, NR, IcommC, IcommP, Iclr, Nclr, Lv
CCC_  - Body
      call DMAget (IR,     iMA, 'IR')
      call DMAget (NR,     iMA, 'NR')
      call DMAget (IcommC, iMA, 'CO')
      call DMAget (IcommP, iMA, 'PC')
      call DMAget (Iclr,   iMA, 'IC')
      call DMAget (Nclr,   iMA, 'NC')
      call DMAget (Lv,     iMA, 'LV')
c
 101  format ('DMAmsg mpi attr. [', A, I2.2, ']',
     $     ' (R: ', I3, I3, ')',
     $     ' (C: ', I3, I3, ')',
     $     1x, I12, I12, ' /', A, '/')
      if (COND_N(IP)) then
         write (IP, 101) _TRIM(Tag), Lv,
     $        IR,   NR,
     $        Iclr, Nclr,
     $        IcommP, IcommC, _TRIM(Cclr)
      else if (COND_S(IP)) then
         write (*,  101) _TRIM(Tag), Lv,
     $        IR,   NR,
     $        Iclr, Nclr,
     $        IcommP, IcommC, _TRIM(Cclr)
      endif
      RETURN
      END
CCC_ & DMAfst  ## Development/MPI file-template configuration
      subroutine DMAfst
     O    (iErr,
     I     iMA,  Cclr)
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,integer)   iMA (*)
      _INTENT(IN,   character) Cclr*(*)
CCC_   = Interior
      integer LV, IR, NR, ICLR, NCLR
CCC_  - Body
      iErr = 0
c
      call DMAget (IR,     iMA, 'IR')
      call DMAget (NR,     iMA, 'NR')
      call DMAget (Iclr,   iMA, 'IC')
      call DMAget (Nclr,   iMA, 'NC')
      call DMAget (Lv,     iMA, 'LV')
c
      call DMPpia (iErr, Lv,  'ir',     'ir', IR)
      call DMPpia (iErr, Lv,  'nr',     'nr', NR)
      call DMPpia (iErr, Lv,  'ig',     'ig', ICLR)
      call DMPpia (iErr, Lv,  'ng',     'ng', NCLR)
      call DMPpsa (iErr, Lv,  'GNAME',  ' ',  Cclr)
c
      if (Lv.eq.0) then
         call DMPpia (iErr, Lv,  'ir',  'irw', IR)
         call DMPpia (iErr, Lv,  'nr',  'nrw', NR)
         call DMPpia (iErr, Lv,  'ig',  'igw', IR)
         call DMPpia (iErr, Lv,  'ng',  'ngw', NR)
      endif
c
      RETURN
      END
CCC_ & DMAfsa  ## Development/MPI file-template put aliases
      subroutine DMAfsa (iErr, ISW)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(IN, integer) ISW
CCC_  - Body
      iErr = 0
c
      if (iErr.eq.0) call DPBpaG (iErr, 'irw', 'J')
      if (iErr.eq.0) call DPBpaG (iErr, 'nrw', 'W')
      if (iErr.eq.0) call DPBpaG (iErr, 'ir',  'I')
      if (iErr.eq.0) call DPBpaG (iErr, 'nr',  'N')
c
      if (OPT_USE_MPI.eq.0.and.ISW.eq.0) then
         continue
      else
         if (iErr.eq.0) call DPBpaG (iErr, 'irw', 'IRW')
         if (iErr.eq.0) call DPBpaG (iErr, 'nrw', 'NRW')
         if (iErr.eq.0) call DPBpaG (iErr, 'ir',  'IR')
         if (iErr.eq.0) call DPBpaG (iErr, 'nr',  'NR')
         if (iErr.eq.0) call DPBpaG (iErr, 'igw', 'IGW')
         if (iErr.eq.0) call DPBpaG (iErr, 'ngw', 'NGW')
         if (iErr.eq.0) call DPBpaG (iErr, 'ig',  'IG')
         if (iErr.eq.0) call DPBpaG (iErr, 'ng',  'NG')
      endif
      RETURN
      END
CCC_ & DMAbfm  ## Development/MPI attributes assembly buffer manager
      subroutine DMAbfm (iErr)
CCC_  - Note
CC       Only top attributes are recorded.
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   iMAo (*)
      _INTENT(OUT,integer)   iMA1
      _INTENT(IN, integer)   iMAi (*)
      _INTENT(OUT,character) CclrO*(*)
      _INTENT(IN, character) CclrI*(*)
      _INTENT(IN, integer)   iAttr
CCC_   = Interior
      integer   j
CCC_   = Save
      integer    LATTR
      parameter (LATTR = MAX_MPI_ATTR)
      integer    iMAsav (LATTR)
      character  ClrNam*(DMPIMS_COLOR_NAME_LEN)
      data       iMAsav /LATTR * -9999/
      data       ClrNam /'INVALID'/
      save       iMAsav, ClrNam
CCC_  - Body (DMAbfm)
      iErr = 0
      RETURN
CCC_  & DMApsh  ## Development/MPI attributes assembly push
      entry DMApsh (iMAi, CClrI)
      do j = 1, LATTR
         iMAsav (j) = iMAi (j)
      enddo
      ClrNam = CclrI
      RETURN
CCC_  & DMAtop  ## Development/MPI attributes assembly stack top
      entry DMAtop (iMAo, CClrO)
      do j = 1, LATTR
         iMAo (j) = iMAsav (j)
      enddo
      CclrO = ClrNam
      RETURN
CCC_  & DMAtpi  ## Development/MPI attributes assembly stack top (integer only)
      entry DMAtpi (iMAo)
      do j = 1, LATTR
         iMAo (j) = iMAsav (j)
      enddo
      RETURN
CCC_  & DMAti1 ## Development/MPI attributes assembly top 1
      entry DMAti1 (iMA1, iAttr)
      iMA1 = iMAsav (iAttr)
      RETURN
CCC_  - End (DMAbfm)
      END
CCC_* [DMP] Contact with Development/Template
CCC_ & DMPpia  ## Development/MPI file-template sub (put integer)
      subroutine DMPpia
     O    (iErr,
     I     Lvl,
     I     TagL,  TagS, Inum)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   Lvl
      _INTENT(IN, character) TagL*(*), TagS*(*)
      _INTENT(IN, integer)   Inum
      character TTag*(32)
CCC_  - Body
      iErr = 0
      call DMPmtg (TTag, TagL, Lvl)
      call DPBpiG (iErr, TTag, TagS, Inum)
      RETURN
      END
CCC_ & DMPpsa  ## Development/MPI file-template sub (put string)
      subroutine DMPpsa
     O    (iErr,
     I     Lvl,
     I     TagL,  TagS, Str)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   Lvl
      _INTENT(IN, character) TagL*(*), TagS*(*)
      _INTENT(IN, character) Str*(*)
      character TTag*(32)
CCC_  - Body
      iErr = 0
      call DMPmtg (TTag, TagL, Lvl)
      call DPBpsG (iErr, TTag, TagS, Str)
      RETURN
      END
CCC_ & DMPmtg  ## Development/MPI file-template sub (make tag)
      subroutine DMPmtg
     O    (Tag,
     I     TagL, Lvl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,character) Tag*(*)
      _INTENT(IN, character) TagL*(*)
      _INTENT(IN, integer)   Lvl
      integer jp, ls
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
CCC_  - Body
      Tag = TagL
      if (lvl.ge.0) then
         jp  = len_trim (Tag) + 1
         call UtmpZI
     O       (ls,
     M        Tag,
     I        jp,   0, 1, lvl)
      endif
      RETURN
      END
CCC_* [DMW] MPI functions wrapper
CCC_ & DMWini  ## Development/MPI manager initialization
      subroutine DMWini (iErr)
      implicit none
      _INTENT(OUT,integer) iErr
#if OPT_USE_MPI
#  include "mpif.h"
      integer iflag
      iErr = 0
      call MPI_Initialized (iflag, iErr)
      if (iflag.eq.0) call MPI_INIT (iErr)
#else  /* not OPT_USE_MPI */
      iErr = 0
#endif /* not OPT_USE_MPI */
      RETURN
      END
CCC_ & DMWfin  ## Development/MPI manager finalization
      subroutine DMWfin (iErr)
      implicit none
      _INTENT(OUT,integer) iErr
#if OPT_USE_MPI
#  include "mpif.h"
      integer iflag
      call MPI_Initialized (iflag, iErr)
      if (iflag.ne.0) then
         call MPI_Finalized (iflag, iErr)
         if (iflag.eq.0) call MPI_Finalize (iErr)
      endif
#else  /* not OPT_USE_MPI */
      iErr = 0
#endif /* not OPT_USE_MPI */
      RETURN
      END
CCC_ & DMWrnk  ## Development/MPI query rank in given communicator
      subroutine DMWrnk
     O    (IR,   NR,
     I     IComm)
      implicit none
      _INTENT(OUT,integer)   IR, NR
      _INTENT(IN, integer)   IComm
#if OPT_USE_MPI
#  include "mpif.h"
      integer iErr
      call MPI_COMM_SIZE (IComm, NR, iErr)
      call MPI_COMM_RANK (IComm, IR, iErr)
#else  /* not OPT_USE_MPI */
CC    To suppress compiler warning
      NR = 0 * IComm
      IR = 0 * IComm
#endif /* not OPT_USE_MPI */
      RETURN
      END
CCC_ & DMWami  ## Development/MPI wrapper/all-reduce/integer/max
      subroutine DMWami
     O    (iErr, KMAX,
     I     Kin,  ICOMM)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   KMAX
      _INTENT(IN, integer)   KIN
      _INTENT(IN, integer)   ICOMM
CCC_  - Body
#if OPT_USE_MPI
#  include "mpif.h"
      call MPI_ALLREDUCE
     $     (KIN, KMAX, 1, MPI_INTEGER, MPI_MAX, ICOMM, iErr)
#else /* not OPT_USE_MPI */
      iErr = 0
      KMAX = KIN + (0 * ICOMM)
#endif
      RETURN
      END
CCC_ & DMWrsi  ## Development/MPI wrapper/reduce/integer/sum (to do)
CCC_ & DMWbca  ## Development/MPI wrapper/broadcast/string
      subroutine DMWbca
     O    (iErr,  S,
     I     IROOT, ICOMM)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,character) S*(*)
      _INTENT(IN, integer)     IROOT, ICOMM
#if OPT_USE_MPI
      integer l
#endif
CCC_  - Body
#if OPT_USE_MPI
#  include "mpif.h"
      l = len_trim (S)
      call MPI_BCAST
     $     (l, 1, MPI_INTEGER, IROOT, ICOMM, iErr)
      call MPI_BCAST
     $     (S, l, MPI_CHARACTER, IROOT, ICOMM, iErr)
      S = S(1:l)
#else /* not OPT_USE_MPI */
      if (S.eq.' ') continue
      iErr = (0 * IROOT) * ICOMM
#endif
      RETURN
      END
CCC_ & DMWspc  ## Development/MPI color split execution
      subroutine DMWspc
     O    (iErr,
     O     IcommC,
     I     ICLR, ClrC,  IkeyC, IRP, IcommP)
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   IcommC
      _INTENT(IN, character) ClrC*(*)
      _INTENT(IN, integer)   ICLR, IkeyC, IRP, IcommP
CCC_   = Interior
#if OPT_USE_MPI
      integer   IK
#  include "mpif.h"
#  if HAVE_F77_DECL_MPI_MAX_OBJECT_NAME
#  else /* pasted from libmpich2-dev 1.4.1-4.1 */
       INTEGER    MPI_MAX_OBJECT_NAME
       PARAMETER (MPI_MAX_OBJECT_NAME=127)
#  endif
      character T*(MPI_MAX_OBJECT_NAME)
      integer   lc
#  if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#  endif
#endif
CCC_  - Body
#if OPT_USE_MPI
      iErr = 0
      IK = IkeyC
      if (IK.lt.0) IK = IRP
      call MPI_Comm_split
     $     (IcommP, ICLR, IK, IcommC, iErr)
      if (iErr.eq.MPI_SUCCESS) then
         lc = len_trim (ClrC)
         T  = ClrC (1:MIN (lc, MPI_MAX_OBJECT_NAME))
         call MPI_Comm_set_name (IcommC, T, iErr)
      endif
#else  /* not OPT_USE_MPI */
CC    To suppress compiler warning
      iErr = (((0 * ICLR) * IcommP) * IkeyC) * IRP
      if (ClrC.eq.' ') continue
      IcommC = -999
#endif /* not OPT_USE_MPI */
      RETURN
      END
CCC_ & DMWcsr  ## Development/MPI clone by sendrecv
      subroutine DMWcsr
     O    (VD,
     I     VS,     NV,
     I     IRfrom, IRto, iMA)
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(IN, integer)  NV
      _INTENT(OUT,_REALSTD) VD (NV)
      _INTENT(IN, _REALSTD) VS (NV)
      _INTENT(IN, integer)  IRfrom, IRto
      _INTENT(IN, integer)  iMA (*)
CCC_   = Interior
      integer l
      integer IRme, ICOM
#if    OPT_USE_MPI
#  include "mpif.h"
      integer NVs, NVd
      integer JtagS, JtagR, Jstt (MPI_STATUS_SIZE), jErr
#endif
CCC_  - Body
      IRme = iMA (_IDX_MPI_RANK)
      ICOM = iMA (_IDX_MPI_COMM)
      if (IRme.eq.IRto) then
         do l = 1, NV
            VD (l) = VS (l)
         enddo
      else
#if OPT_USE_MPI
         JtagS = IRto
         JtagR = IRme
         NVs   = NV
         NVd   = NV
         call MPI_SENDRECV
     $       (VS, NVs, _MPI_REALSTD, IRto,   JtagS,
     $        VD, NVd, _MPI_REALSTD, IRfrom, JtagR, ICOM, jStt, jErr)
#else /* not OPT_USE_MPI */
CC       Dummy statements
         if (IRfrom.eq.0) continue
         if (ICOM.eq.0) continue
#endif /* not OPT_USE_MPI */
c$$$         call DAtrcU (-1, jErr, 'R', 'DMWcsr')
      endif
      RETURN
      END
CCC_ & DMWcrs  ## Development/MPI clone by recieve and send
      subroutine DMWcrs
     O    (VD,
     I     VS,     NV,
     I     IRfrom, IRto, iMA)
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(IN, integer)  NV
      _INTENT(OUT,_REALSTD) VD (NV)
      _INTENT(IN, _REALSTD) VS (NV)
      _INTENT(IN, integer)  IRfrom, IRto
      _INTENT(IN, integer)  iMA (*)
CCC_   = Interior
      integer l
      integer IRme, ICOM
#if    OPT_USE_MPI
#  include "mpif.h"
      integer JerrS, JreqS, JtagS, JsttS (MPI_STATUS_SIZE)
      integer JerrR, JreqR, JtagR, JsttR (MPI_STATUS_SIZE)
#endif
CCC_  - Body
      IRme = iMA (_IDX_MPI_RANK)
      ICOM = iMA (_IDX_MPI_COMM)
      if (IRme.eq.IRto) then
         do l = 1, NV
            VD (l) = VS (l)
         enddo
      else
#if OPT_USE_MPI
         JtagS = IRto
         JtagR = IRme
         call MPI_ISEND
     $        (VS, NV, _MPI_REALSTD, IRto,   JtagS, ICOM, JreqS, JerrS)
         call MPI_IRECV
     $        (VD, NV, _MPI_REALSTD, IRfrom, JtagR, ICOM, JreqR, JerrR)
         call MPI_WAIT (JreqS, JsttS, JerrS)
         call MPI_WAIT (JreqR, JsttR, JerrR)
#else /* not OPT_USE_MPI */
CC       Dummy statements
         if (IRfrom.eq.0) continue
         if (ICOM.eq.0) continue
#endif /* not OPT_USE_MPI */
      endif
      RETURN
      END
CCC_ & DMWbcs  ## Development/MPI broadcast standard
      subroutine DMWbcs
     M    (V,
     I     IROOT, iMA)
CCC_  - Declaration
      implicit none
#if OPT_USE_MPI
#  include "mpif.h"
#endif
CCC_   = Arguments
      _INTENT(INOUT,_REALSTD) V
      _INTENT(IN, integer)  IROOT
      _INTENT(IN, integer)  iMA (*)
CCC_   = Interior
      integer NR
#if OPT_USE_MPI
      integer ICOM
      integer jErr
#endif
CCC_  - Body
      NR   = iMA (_IDX_MPI_NRANKS)
      if (NR.gt.1) then
#if OPT_USE_MPI
         ICOM = iMA (_IDX_MPI_COMM)
         call MPI_Bcast
     $        (V, 1, _MPI_REALSTD, IROOT, ICOM, jErr)
#else /* not OPT_USE_MPI */
CC       Dummy statements
         if (IROOT.eq.0) continue
         if (V.eq.0.0d0) continue
#endif /* not OPT_USE_MPI */
c$$$         call DAtrcU (-1, jErr, 'R', 'DMWbcs')
      endif
      RETURN
      END
CCC_ & DMWgts  ## Development/MPI gather standard
      subroutine DMWgts
     O    (Y,
     I     V,     NV,
     I     IROOT, iMA)
CCC_  - Declaration
      implicit none
#if OPT_USE_MPI
#  include "mpif.h"
#endif
CCC_   = Arguments
      _INTENT(OUT,_REALSTD) Y (*)
      _INTENT(IN, _REALSTD) V (*)
      _INTENT(IN, integer)  NV
      _INTENT(IN, integer)  IROOT, iMA (*)
CCC_   = Interior
      integer j
      integer NR
#if OPT_USE_MPI
      integer ICOM
      integer jErr
#endif
CCC_  - Body
      NR   = iMA (_IDX_MPI_NRANKS)
      if (NR.gt.1) then
#if OPT_USE_MPI
         ICOM = iMA (_IDX_MPI_COMM)
         call MPI_Gather
     $       (V, NV, _MPI_REALSTD,
     $        Y, NV, _MPI_REALSTD, IROOT, ICOM, jErr)
c$$$         call DAtrcU (-1, jErr, 'R', 'DMWgts')
#else /* not OPT_USE_MPI */
CC       Dummy statements
         if (IROOT.eq.0) continue
#endif /* not OPT_USE_MPI */
      else
         do j = 1, NV
            Y (j) = V (j)
         enddo
      endif
      RETURN
      END
CCC_ & DMWgta  ## Development/MPI gather string
      subroutine DMWgta
     O    (Y,
     I     V,     LV,
     I     IROOT, iMA)
CCC_  - Declaration
      implicit none
#if OPT_USE_MPI
#  include "mpif.h"
#endif
CCC_   = Arguments
      _INTENT(OUT,character) Y*(*)
      _INTENT(IN, character) V*(*)
      _INTENT(IN, integer)   LV
      _INTENT(IN, integer)   IROOT, iMA (*)
CCC_   = Interior
      integer NR
#if OPT_USE_MPI
      integer ICOM
      integer jErr
#endif
CCC_  - Body
      NR   = iMA (_IDX_MPI_NRANKS)
      if (NR.gt.1) then
#if OPT_USE_MPI
         ICOM = iMA (_IDX_MPI_COMM)
         call MPI_Gather
     $       (V, LV, MPI_CHARACTER,
     $        Y, LV, MPI_CHARACTER, IROOT, ICOM, jErr)
#else /* not OPT_USE_MPI */
CC       Dummy statements
         if (IROOT.eq.0) continue
#endif /* not OPT_USE_MPI */
      else
         Y (1:LV) = V (1:LV)
      endif
      RETURN
      END
CCC_ & DMWbts  ## Development/MPI broadcast total
      subroutine DMWbts
     O    (Y,
     I     V,
     I     iMA)
CCC_  - Declaration
      implicit none
#if OPT_USE_MPI
#  include "mpif.h"
#endif
CCC_   = Arguments
      _INTENT(OUT,_REALSTD) Y
      _INTENT(IN, _REALSTD) V (1)
      _INTENT(IN, integer)  iMA (*)
CCC_   = Interior
      integer NR
#if OPT_USE_MPI
      integer    LP
      parameter (LP = OPT_DMPIMS_NRMAX)
      integer    j
      _REALSTD B (LP)
c$$$      integer jErr
      integer IRM, ICOM, IRK
#endif
CCC_  - Body
      NR   = iMA (_IDX_MPI_NRANKS)
      if (NR.gt.1) then
#if OPT_USE_MPI
         IRK  = 0
         IRM  = iMA (_IDX_MPI_RANK)
         ICOM = iMA (_IDX_MPI_COMM)
         call DMWgts (B, V, 1, IRK, iMA)
c$$$         call MPI_Gather
c$$$     $        (V, 1, _MPI_REALSTD, B, 1, _MPI_REALSTD, 0, ICOM, jErr)
c$$$         call DAtrcU (-1, jErr, 'G', 'DMWbts')
         if (IRM.eq.IRK) then
            Y = 0.0d0
            do j = 1, NR
               Y = Y + B (j)
            enddo
         endif
         call DMWbcs (Y, IRK, iMA)
c$$$         call MPI_Bcast
c$$$     $        (Y, 1, _MPI_REALSTD, IRK, ICOM, jErr)
c$$$         call DAtrcU (-1, jErr, 'B', 'DMWbts')
#endif
      else
         Y = V (1)
      endif
      RETURN
      END
CCC_ & DMWcma  ## Development/MPI circulation maximum
      subroutine DMWcma
     M    (X,
     I     iMA)
CCC_  - Declaration
      implicit none
#if OPT_USE_MPI
#  include "mpif.h"
#endif
CCC_   = Arguments
      _INTENT(INOUT,_REALSTD) X
      _INTENT(IN,   integer)  iMA (*)
CCC_   = Interior
      integer NR
#if OPT_USE_MPI
      integer IRM, ICOM, IRS, IRD
      integer jErr, jTagS, jTagR, jStt (MPI_STATUS_SIZE)
      integer l
      _REALSTD R
#endif
CCC_  - Body
      NR = iMA (_IDX_MPI_NRANKS)
      if (NR.gt.1) then
#if OPT_USE_MPI
         IRM  = iMA (_IDX_MPI_RANK)
         ICOM = iMA (_IDX_MPI_COMM)
         IRS  = MOD ((IRM + NR - 1), NR)
         IRD  = MOD ((IRM + NR + 1), NR)
         JtagS = IRD
         JtagR = IRM
         do l = 1, NR - 1
            call MPI_SENDRECV
     $          (X, 1, _MPI_REALSTD, IRD, JtagS,
     $           R, 1, _MPI_REALSTD, IRS, JtagR, ICOM, jStt, jErr)
            X = MAX (X, R)
         enddo
#else /* not OPT_USE_MPI */
CC       Dummy statements
         X = X
#endif /* not OPT_USE_MPI */
      endif
      RETURN
      END
CCC_ & DMWbma  ## Development/MPI circulation maximum (gather/broadcast)
      subroutine DMWbma
     M    (X,
     W     W,
     I     iMA)
CCC_  - Declaration
      implicit none
#if OPT_USE_MPI
#  include "mpif.h"
#endif
CCC_   = Arguments
      _INTENT(INOUT,_REALSTD) X (1)
      _INTENT(OUT,  _REALSTD) W (*)
      _INTENT(IN,   integer)  iMA (*)
CCC_   = Interior
      integer NR
#if OPT_USE_MPI
c$$$      integer IRM, ICOM, IRK
      integer IRM,  IRK
      integer l
      _REALSTD R
#endif
CCC_  - Body
      NR = iMA (_IDX_MPI_NRANKS)
      if (NR.gt.1) then
#if OPT_USE_MPI
         IRM  = iMA (_IDX_MPI_RANK)
         IRK  = 0
         call DMWgts (W, X, 1, IRK, iMA)
         if (IRM.eq.IRK) then
            R = W (1)
            do l = 2, NR
               R = MAX (R, W (l))
            enddo
         endif
         call DMWbcs (R, IRK, iMA)
         X (1) = R
#else /* not OPT_USE_MPI */
CC       Dummy statements
         X (1) = X (1)
#endif /* not OPT_USE_MPI */
      endif
      RETURN
      END
CCC_ & DMWtsz  ## Development/MPI wrapper type_size
      subroutine DMWtsz
     O    (iErr,   nSize,
     I     kType)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)  iErr
      _INTENT(OUT,integer)  nSize
      _INTENT(IN, integer)  kType
CCC_  - Body
CC MPI_TYPE_SIZE(DATATYPE, SIZE, IERROR)
#if OPT_USE_MPI
      call MPI_TYPE_SIZE (kType, nSize, iErr)
#else /* not OPT_USE_MPI */
CC       Dummy statements
      iErr  = 0 * kType
      nSize = 0
#endif /* not OPT_USE_MPI */
      RETURN
      END
CCC_ & DMWtxt  ## Development/MPI wrapper type_extent
      subroutine DMWtxt
     O    (iErr,   nExt,
     I     kType)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)  iErr
      _INTENT(OUT,integer)  nExt
      _INTENT(IN, integer)  kType
CCC_  - Body
CC MPI_TYPE_SIZE(DATATYPE, EXTENT, IERROR)
#if OPT_USE_MPI
      call MPI_TYPE_EXTENT (kType, nExt, iErr)
#else /* not OPT_USE_MPI */
CC       Dummy statements
      iErr = 0 * kType
      nExt = 0
#endif /* not OPT_USE_MPI */
      RETURN
      END
CCC_ & DMWdtc  ## Development/MPI wrapper type_contiguous/commit
      subroutine DMWdtc
     O    (iErr,   kNewT,
     I     nCOUNT, kOldT)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)  iErr
      _INTENT(OUT,integer)  kNewT
      _INTENT(IN, integer)  nCOUNT
      _INTENT(IN, integer)  kOldT
CCC_  - Body
CC MPI_TYPE_CONTIGUOUS(COUNT, OLDTYPE, NEWTYPE, IERROR)
#if OPT_USE_MPI
      call MPI_TYPE_CONTIGUOUS (nCOUNT, kOldT, kNewT, iErr)
      call MPI_TYPE_COMMIT (kNewT, iErr)
#else /* not OPT_USE_MPI */
CC       Dummy statements
      iErr  = 0 * nCOUNT
      kNewT = kOldT
#endif /* not OPT_USE_MPI */
      RETURN
      END
CCC_ & DMWdtv  ## Development/MPI wrapper type_vector/commit
      subroutine DMWdtv
     O    (iErr,   kNewT,
     I     nCOUNT, nBlen, nStrd, kOldT)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)  iErr
      _INTENT(OUT,integer)  kNewT
      _INTENT(IN, integer)  nCOUNT, nBlen, nStrd
      _INTENT(IN, integer)  kOldT
CCC_  - Body
CC MPI_TYPE_VECTOR(COUNT, BLOCKLENGTH, STRIDE, OLDTYPE, NEWTYPE, IERROR)
#if OPT_USE_MPI
      call MPI_TYPE_VECTOR (nCOUNT, nBlen, nStrd, kOldT, kNewT, iErr)
      call MPI_TYPE_COMMIT (kNewT, iErr)
#else /* not OPT_USE_MPI */
CC       Dummy statements
      iErr  = ((0 * nCOUNT) * nBlen) * nStrd
      kNewT = kOldT
#endif /* not OPT_USE_MPI */
      RETURN
      END
CCC_ & DMWdts  ## Development/MPI wrapper type_struct/commit
      subroutine DMWdts
     O    (iErr,   kNewT,
     I     nCOUNT, kABL, kDSP, kTYP)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)  iErr
      _INTENT(OUT,integer)  kNewT
      _INTENT(IN, integer)  nCOUNT
      _INTENT(IN, integer)  kABL (*), kDSP (*), kTYP (*)
CCC_  - Body
CC MPI_TYPE_STRUCT(COUNT, ARRAY_OF_BLOCKLENGTHS, ARRAY_OF_DISPLACEMENTS,
CC                ARRAY_OF_TYPES, NEWTYPE, IERROR)
#if OPT_USE_MPI
      call MPI_TYPE_STRUCT (nCOUNT, kABL, kDSP, kTYP, kNewT, iErr)
      call MPI_TYPE_COMMIT (kNewT, iErr)
#else /* not OPT_USE_MPI */
CC       Dummy statements
      iErr  = (((0 * nCount) * kABL (1)) * kDSP (1)) * kTYP (1)
      kNewT = 0
#endif /* not OPT_USE_MPI */
      RETURN
      END
CCC_ & DMWgsa  ## Development/MPI gather in subgroup string
      subroutine DMWgsa
     O    (iErr,  Y,
     I     V,     LV,
     I     IMOD,  IR, NR, ICOMM)
CCC_  - Description
CC     gather string to subgroups of each IMOD processes
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,character) Y*(*)
      _INTENT(IN, character) V*(*)
      _INTENT(IN, integer)   LV
      _INTENT(IN, integer)   IMOD
      _INTENT(IN, integer)   IR, NR, ICOMM
CCC_   = Interior
#if OPT_USE_MPI
      integer IKSUB, IREND, jk, j0, j9
#endif
#if OPT_USE_MPI
#  include "mpif.h"
      integer JreqS, JtagS, JsttS (MPI_STATUS_SIZE)
      integer JreqR, JtagR, JsttR (MPI_STATUS_SIZE)
#endif
CCC_  - Body
      iErr = 0
      if (NR.gt.1) then
#if OPT_USE_MPI
         IKSUB = (IR / IMOD) * IMOD
         IREND = MIN (NR, IKSUB + IMOD) -1
         if (IKSUB.eq.IR) then
            do jk = IKSUB + 1, IREND
               jTagR = jk
               j0 = (jk - IKSUB) * LV + 1
               j9 = j0 + LV - 1
               call MPI_IRecv
     $             (Y (j0:j9), LV, MPI_CHARACTER, jk,
     $              JtagR, ICOMM, JreqR, iErr)
               call MPI_WAIT (JreqR, JsttR, iErr)
            enddo
            Y (1:LV) = V (1:LV)
         else
            jTagS = IR
            call MPI_Isend
     $          (V, LV, MPI_CHARACTER, IKSUB,
     $           JtagS, ICOMM, JreqS, iErr)
            call MPI_WAIT (JreqS, JsttS, iErr)
         endif
#else /* not OPT_USE_MPI */
CC       Dummy statements
         iErr = ((0 * ICOMM) * IR) * IMOD
#endif /* not OPT_USE_MPI */
      else
         Y (1:LV) = V (1:LV)
      endif
      RETURN
      END
CCC_ & DMWgsi  ## Development/MPI gather in subgroup integer
      subroutine DMWgsi
     O    (iErr,  IY,
     I     IV,    Nmem,
     I     IMOD,  IR, NR, ICOMM)
CCC_  - Description
CC     gather string to subgroups of each IMOD processes
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   IY (*)
      _INTENT(IN, integer)   IV (*)
      _INTENT(IN, integer)   Nmem
      _INTENT(IN, integer)   IMOD
      _INTENT(IN, integer)   IR, NR, ICOMM
CCC_   = Interior
#if OPT_USE_MPI
      integer IKSUB, IREND, jk
#endif
      integer j0
#if OPT_USE_MPI
#  include "mpif.h"
      integer JreqS, JtagS, JsttS (MPI_STATUS_SIZE)
      integer JreqR, JtagR, JsttR (MPI_STATUS_SIZE)
#endif
CCC_  - Body
      iErr = 0
      if (NR.gt.1) then
#if OPT_USE_MPI
         IKSUB = (IR / IMOD) * IMOD
         IREND = MIN (NR, IKSUB + IMOD) -1
         if (IKSUB.eq.IR) then
            do jk = IKSUB + 1, IREND
               jTagR = jk
               j0 = (jk - IKSUB) * Nmem + 1
               call MPI_IRecv
     $             (IY (j0), Nmem, MPI_INTEGER, jk,
     $              JtagR, ICOMM, JreqR, iErr)
               call MPI_WAIT (JreqR, JsttR, iErr)
            enddo
            do j0 = 1, Nmem
               IY (j0) = IV (j0)
            enddo
         else
            jTagS = IR
            call MPI_Isend
     $          (IV, Nmem, MPI_INTEGER, IKSUB,
     $           JtagS, ICOMM, JreqS, iErr)
            call MPI_WAIT (JreqS, JsttS, iErr)
         endif
#else /* not OPT_USE_MPI */
CC       Dummy statements
CC       Dummy statements
         iErr = ((0 * ICOMM) * IR) * IMOD
#endif /* not OPT_USE_MPI */
      else
         do j0 = 1, Nmem
            IY (j0) = IV (j0)
         enddo
      endif
      RETURN
      END
CCC_ & DMWoca  ## Development/MPI one-to-one communication string
      subroutine DMWoca
     O    (iErr,
     M     Sbuf,
     I     Lstr,  IR, IRto, IRfrom, ICOMM)
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,character) Sbuf*(*)
      _INTENT(IN,   integer)   Lstr
      _INTENT(IN,   integer)   IR, IRto, IRfrom, ICOMM
#if OPT_USE_MPI
#  include "mpif.h"
      integer JreqS, JtagS, JsttS (MPI_STATUS_SIZE)
      integer JreqR, JtagR, JsttR (MPI_STATUS_SIZE)
#endif
CCC_  - Body
      iErr = 0
      if (IRto.eq.IRfrom) then
         continue
      else if (IRto.eq.IR) then
#      if OPT_USE_MPI
         JtagR = IRfrom
         call MPI_IRecv
     $       (Sbuf, Lstr, MPI_CHARACTER, IRfrom,
     $        JtagR, ICOMM, JreqR, iErr)
         call MPI_WAIT (JreqR, JsttR, iErr)
#      else /* not OPT_USE_MPI */
C        dummy statement
         iErr = (0 * ICOMM) * LSTR
         if (SBUF.eq.' ') continue
#      endif /* not OPT_USE_MPI */
      else if (IRfrom.eq.IR) then
#      if OPT_USE_MPI
         JtagS = IRfrom
         call MPI_Isend
     $       (Sbuf, Lstr, MPI_CHARACTER, IRto,
     $        JtagS, ICOMM, JreqS, iErr)
         call MPI_WAIT (JreqS, JsttS, iErr)
#      else /* not OPT_USE_MPI */
         continue
#      endif /* not OPT_USE_MPI */
      else
         continue
      endif
      RETURN
      END
CCC_ & DMWoci  ## Development/MPI one-to-one communication integer
      subroutine DMWoci
     O    (iErr,
     M     Ibuf,
     I     Nmem,  IR, IRto, IRfrom, ICOMM)
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,integer)   Ibuf (*)
      _INTENT(IN,   integer)   Nmem
      _INTENT(IN,   integer)   IR, IRto, IRfrom, ICOMM
#if OPT_USE_MPI
#  include "mpif.h"
      integer JreqS, JtagS, JsttS (MPI_STATUS_SIZE)
      integer JreqR, JtagR, JsttR (MPI_STATUS_SIZE)
#endif
CCC_  - Body
      iErr = 0
      if (IRto.eq.IRfrom) then
         continue
      else if (IRto.eq.IR) then
#      if OPT_USE_MPI
         JtagR = IRfrom
         call MPI_IRecv
     $       (Ibuf, Nmem, MPI_INTEGER, IRfrom,
     $        JtagR, ICOMM, JreqR, iErr)
         call MPI_WAIT (JreqR, JsttR, iErr)
#      else /* not OPT_USE_MPI */
C        dummy statement
         iErr = ((0 * ICOMM) * Ibuf (1)) * Nmem
         continue
#      endif /* not OPT_USE_MPI */
      else if (IRfrom.eq.IR) then
#      if OPT_USE_MPI
         JtagS = IRfrom
         call MPI_Isend
     $       (Ibuf, Nmem, MPI_INTEGER, IRto,
     $        JtagS, ICOMM, JreqS, iErr)
         call MPI_WAIT (JreqS, JsttS, iErr)
#      else /* not OPT_USE_MPI */
         continue
#      endif /* not OPT_USE_MPI */
      else
         continue
      endif
      RETURN
      END
CCC_* [DMD] MPI functions wrapper (with derived types)
CCC_ & DMDcol  ## Development/MPI collection(gather) by send/recieve
      subroutine DMDcol
     O    (iErr, VG,
     I     VP,   IRto, iTypR, iTypS, nBlk, iMA)
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(OUT,integer)  iErr
      _INTENT(OUT,_REALSTD) VG (*)
      _INTENT(IN, _REALSTD) VP (*)
      _INTENT(IN, integer)  IRto
      _INTENT(IN, integer)  iTypS (*),  iTypR (*), nBlk
      _INTENT(IN, integer)  iMA (*)
CCC_   = Interior
#if    OPT_USE_MPI
#  include "mpif.h"
      integer KS
      integer IR,  NR,  ICOMM
      integer JreqS, JtagS, JsttS (MPI_STATUS_SIZE)
      integer JreqR, JtagR, JsttR (MPI_STATUS_SIZE)
      integer irt
#endif
CCC_  - Dody
#if    OPT_USE_MPI
      iErr = 0
      call DMAget (Icomm, iMA, 'CO')
      call DMAget (IR,    iMA, 'IR')
      call DMAget (NR,    iMA, 'NR')
c
      do irt = 0, NR - 1
         if (IR.eq.irt) then
            KS    = iTypS (1 + irt)
            jTagS = irt
            call MPI_ISend
     $           (VP, nBlk, KS, IRto, jTagS, ICOMM, JreqS, iErr)
         endif
         if (IR.eq.IRto) then
            KS = iTypR (1 + irt)
            jTagR = irt
            call MPI_IRecv
     $           (VG, nBlk, KS, irt,  jTagR, ICOMM, JreqR, iErr)
         endif
         if (IR.eq.irt)  call MPI_WAIT (JreqS, JsttS, iErr)
         if (IR.eq.IRto) call MPI_WAIT (JreqR, JsttR, iErr)
      enddo
#else /* not OPT_USE_MPI */
CC       Dummy statements
      iErr = -1
     $     + ((((0 * IMA (1)) * IRto) * iTypR (1)) * iTypS (1)) * nBlk
#endif /* not OPT_USE_MPI */
      RETURN
      END
CCC_ & DMDdis  ## Development/MPI distribution(scatter) by send/recieve
CCC_ & DMDpsr  ## Development/MPI pass between one-pairs by send/recieve
      subroutine DMDpsr
     O    (iErr, VD,
     I     VS,
     I     IRfrom, IRto, NV, iTypR, iTypS, nBlk, iMA)
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(IN, integer)  NV
      _INTENT(OUT,integer)  iErr
      _INTENT(OUT,_REALSTD) VD (NV)
      _INTENT(IN, _REALSTD) VS (NV)
      _INTENT(IN, integer)  IRfrom, IRto
      _INTENT(IN, integer)  iTypS,  iTypR, nBlk
      _INTENT(IN, integer)  iMA (*)
CCC_   = Interior
      integer l
      integer IRme
#if    OPT_USE_MPI
#  include "mpif.h"
      integer ICOM
      integer JreqS, JtagS, JsttS (MPI_STATUS_SIZE)
      integer JreqR, JtagR, JsttR (MPI_STATUS_SIZE)
#endif
CCC_  - Body
      IRme = iMA (_IDX_MPI_RANK)
      if (IRme.eq.IRfrom .and. IRme.eq.IRto) then
         iErr = 0
         do l = 1, NV
            VD (l) = VS (l)
         enddo
      else
#if OPT_USE_MPI
         ICOM = iMA (_IDX_MPI_COMM)
         if (IRme.eq.IRfrom) then
            JtagS = IRto
            call MPI_ISEND
     $           (VS, nBlk, iTypS, IRto,   JtagS, ICOM, JreqS, iErr)
            call MPI_WAIT (JreqS, JsttS, iErr)
         else if (IRme.eq.IRto) then
            JtagR = IRme
            call MPI_IRECV
     $           (VD, nBlk, iTypR, IRfrom, JtagR, ICOM, JreqR, iErr)
            call MPI_WAIT (JreqR, JsttR, iErr)
         else
            iErr = 0
         endif
#else /* not OPT_USE_MPI */
CC       Dummy statements
         iErr = -1
     $        + (((0 * iTypR) * iTypS) * nBlk)
#endif /* not OPT_USE_MPI */
      endif
      RETURN
      END
CCC_ & DMDcsr  ## Development/MPI clone by sendrecv
      subroutine DMDcsr
     O    (iErr,   VD,
     I     VS,
     I     IRfrom, IRto, NV, iTypR, iTypS, nBlk, iMA)
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(IN, integer)  NV
      _INTENT(OUT,integer)  iErr
      _INTENT(OUT,_REALSTD) VD (NV)
      _INTENT(IN, _REALSTD) VS (NV)
      _INTENT(IN, integer)  IRfrom, IRto
      _INTENT(IN, integer)  iTypS,  iTypR, nBlk
      _INTENT(IN, integer)  iMA (*)
CCC_   = Interior
      integer l
      integer IRme
#if    OPT_USE_MPI
#  include "mpif.h"
c$$$      integer JerrS, JreqS, JtagS, JsttS (MPI_STATUS_SIZE)
c$$$      integer JerrR, JreqR, JtagR, JsttR (MPI_STATUS_SIZE)
      integer ICOM
      integer nBlkS, nBlkD
      integer jTagS, jTagR, jStt (MPI_STATUS_SIZE)
#endif
CCC_  - Body
      IRme = iMA (_IDX_MPI_RANK)
      if (IRme.eq.IRto) then
         iErr = 0
         do l = 1, NV
            VD (l) = VS (l)
         enddo
      else
#if OPT_USE_MPI
         ICOM = iMA (_IDX_MPI_COMM)
         JtagS = IRto
         JtagR = IRme
         nBlkS = nBlk
         nBlkD = nBlk
         call MPI_SENDRECV
     $       (VS, nBlkS, iTypS, IRto,   JtagS,
     $        VD, nBlkD, iTypR, IRfrom, JtagR, ICOM, jStt, iErr)
c$$$         call MPI_ISEND
c$$$     $        (VS, nBlk, iTypS, IRto,   JtagS, ICOM, JreqS, JerrS)
c$$$         call MPI_IRECV
c$$$     $        (VD, nBlk, iTypR, IRfrom, JtagR, ICOM, JreqR, JerrR)
c$$$         call MPI_WAIT (JreqS, JsttS, JerrS)
c$$$         call MPI_WAIT (JreqR, JsttR, JerrR)
c$$$         iErr = jErrS
c$$$         call DAtrcU (-1, iErr, 'W', 'DMDcsr')
#else /* not OPT_USE_MPI */
CC       Dummy statements
         iErr = -1
     $        + (((((0 * IRfrom) * IRto) * iTypS) * iTypR) * nBlk)
#endif /* not OPT_USE_MPI */
      endif
      RETURN
      END
CCC_ & DMDcrs  ## Development/MPI clone by recieve and send
      subroutine DMDcrs
     O    (iErr,   VD,
     I     VS,
     I     IRfrom, IRto, NV, iTypR, iTypS, nBlk, iMA)
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(IN, integer)  NV
      _INTENT(OUT,integer)  iErr
      _INTENT(OUT,_REALSTD) VD (NV)
      _INTENT(IN, _REALSTD) VS (NV)
      _INTENT(IN, integer)  IRfrom, IRto
      _INTENT(IN, integer)  iTypS,  iTypR, nBlk
      _INTENT(IN, integer)  iMA (*)
CCC_   = Interior
      integer l
      integer IRme
#if    OPT_USE_MPI
#  include "mpif.h"
      integer JerrS, JreqS, JtagS, JsttS (MPI_STATUS_SIZE)
      integer JerrR, JreqR, JtagR, JsttR (MPI_STATUS_SIZE)
      integer ICOM
#endif
CCC_  - Body
      IRme = iMA (_IDX_MPI_RANK)
      if (IRme.eq.IRto) then
         iErr = 0
         do l = 1, NV
            VD (l) = VS (l)
         enddo
      else
#if OPT_USE_MPI
         ICOM = iMA (_IDX_MPI_COMM)
         JtagS = IRto
         JtagR = IRme
         call MPI_ISEND
     $        (VS, nBlk, iTypS, IRto,   JtagS, ICOM, JreqS, JerrS)
         call MPI_IRECV
     $        (VD, nBlk, iTypR, IRfrom, JtagR, ICOM, JreqR, JerrR)
         call MPI_WAIT (JreqS, JsttS, JerrS)
         call MPI_WAIT (JreqR, JsttR, JerrR)
         iErr = jErrS
#else /* not OPT_USE_MPI */
CC       Dummy statements
         iErr = -1
     $        + (((((0 * IRfrom) * IRto) * iTypS) * iTypR) * nBlk)
#endif /* not OPT_USE_MPI */
      endif
      RETURN
      END
CCC_ & DMDmrs  ## Development/MPI clone by recieve and send (modify)
      subroutine DMDmrs
     O    (iErr,
     M     V,
     I     IRfrom, IRto, NV, iTypR, iTypS, nBlk, iMA)
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(IN,   integer)  NV
      _INTENT(OUT,  integer)  iErr
      _INTENT(INOUT,_REALSTD) V (NV)
      _INTENT(IN,   integer)  IRfrom, IRto
      _INTENT(IN,   integer)  iTypS,  iTypR, nBlk
      _INTENT(IN,   integer)  iMA (*)
CCC_   = Interior
      integer IRme
#if    OPT_USE_MPI
#  include "mpif.h"
      integer JerrS, JreqS, JtagS, JsttS (MPI_STATUS_SIZE)
      integer JerrR, JreqR, JtagR, JsttR (MPI_STATUS_SIZE)
      integer ICOM
#endif
CCC_  - Body
      IRme = iMA (_IDX_MPI_RANK)
      if (IRme.eq.IRto) then
         iErr = 0
      else
#if OPT_USE_MPI
         ICOM = iMA (_IDX_MPI_COMM)
         JtagS = IRto
         JtagR = IRme
         call MPI_ISEND
     $        (V, nBlk, iTypS, IRto,   JtagS, ICOM, JreqS, JerrS)
         call MPI_IRECV
     $        (V, nBlk, iTypR, IRfrom, JtagR, ICOM, JreqR, JerrR)
         call MPI_WAIT (JreqS, JsttS, JerrS)
         call MPI_WAIT (JreqR, JsttR, JerrR)
         iErr = jErrS
#else /* not OPT_USE_MPI */
CC       Dummy statements
         iErr = -1
     $        + (((((0 * IRfrom) * IRto) * iTypS) * iTypR) * nBlk)
#endif /* not OPT_USE_MPI */
      endif
      RETURN
      END
CCC_* [DMZ] miscellaneous modules
CCC_ & DMZqcn  ## Development/MPI query MPI-constant
      subroutine DMZqcn
     O    (iErr, Iconst,
     I     Cmacro)
CCC_  - Declaration
      implicit none
#if OPT_USE_MPI
#  include "mpif.h"
#endif
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   Iconst
      _INTENT(IN, character) Cmacro*(*)
CCC_  - Body
      iErr = 0
#if OPT_USE_MPI
      if      (Cmacro .eq. 'COMM_WORLD') then
         Iconst = MPI_COMM_WORLD
      else if (Cmacro .eq. 'COMM_NULL') then
         Iconst = MPI_COMM_NULL
      else if (Cmacro .eq. 'ANY_TAG') then
         Iconst = MPI_ANY_TAG
      else if (Cmacro .eq. 'PROC_NULL') then
         Iconst = MPI_PROC_NULL
      else if (Cmacro .eq. 'ERR_UNKNOWN') then
         Iconst = MPI_ERR_UNKNOWN
CCC_   . intrinsic types
      else if (Cmacro .eq. 'INTEGER') then
         Iconst = MPI_INTEGER
      else if (Cmacro .eq. 'REAL8') then
         Iconst = MPI_REAL8
      else if (Cmacro .eq. 'REAL4') then
         Iconst = MPI_REAL4
      else if (Cmacro .eq. 'REAL') then
         Iconst = MPI_REAL
      else if (Cmacro .eq. 'CHARACTER') then
         Iconst = MPI_CHARACTER
      else if (Cmacro .eq. 'DATATYPE_NULL') then
         Iconst = MPI_DATATYPE_NULL
CCC_   . derived type manipulation
      else if (Cmacro .eq. 'UB') then
         Iconst = MPI_UB
      else if (Cmacro .eq. 'LB') then
         Iconst = MPI_LB
CCC_   . types in ostinato
      else if (Cmacro .eq. '_REALSTD') then
         Iconst = _MPI_REALSTD
CCC_   . error
      else
         iErr = 1
         Iconst = MPI_ERR_UNKNOWN
      endif
#else  /* not OPT_USE_MPI */
      if      (Cmacro .eq. 'SUCCESS') then
         Iconst = 0
      else
         Iconst = -999
      endif
#endif /* not OPT_USE_MPI */
      RETURN
      END
CCC_ & DMZecr  ## Development/MPI circulate error or not
      subroutine DMZecr
     M    (iErr,
     I     Icomm, IRNK, NRNK)
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(INOUT,integer) iErr
      _INTENT(IN,   integer) Icomm, IRNK, NRNK
CCC_   = Interior
#if OPT_USE_MPI
#     include "mpif.h"
      integer j
c$$$      integer JbufR, JER, JRR, JRQR, JTGR, JSTR (MPI_STATUS_SIZE)
c$$$      integer JbufS, JES, JRS, JRQS, JTGS, JSTS (MPI_STATUS_SIZE)
      integer JbufR, JbufS, JRR, JRS, JTGR, JTGS
      integer jErr,  jStt (MPI_STATUS_SIZE)
#endif /* OPT_USE_MPI */
CCC_  - Body
#if OPT_USE_MPI
      if (NRNK.le.1) then
         continue
      else
         JRS = MOD (IRNK        + 1, NRNK)
         JRR = MOD (IRNK + NRNK - 1, NRNK)
         JbufS = iErr
         JbufR = 0
         do j = 1, NRNK - 1
            JTGS = JRS
            JTGR = IRNK
            call MPI_SENDRECV
     $          (JbufS, 1, MPI_INTEGER, JRS, JTGS,
     $           JbufR, 1, MPI_INTEGER, JRR, JTGR, Icomm, jStt, jErr)
c$$$            call MPI_ISEND
c$$$     $           (JbufS, 1, MPI_INTEGER, JRS, JTGS, Icomm, JRQS, JES)
c$$$            call MPI_IRECV
c$$$     $           (JbufR, 1, MPI_INTEGER, JRR, JTGR, Icomm, JRQR, JER)
c$$$            call MPI_WAIT (JRQS, JSTS, JES)
c$$$            call MPI_WAIT (JRQR, JSTR, JER)
            if (JbufR.ne.0) JbufS = JbufR
         enddo
         iErr = JbufS
       endif
#else  /* not OPT_USE_MPI */
CC    To suppress compiler warning
       iErr = iErr
     $      + ((0 * Icomm) * IRNK) * NRNK
#endif /* not OPT_USE_MPI */
      RETURN
      END
CCC_ & DMZcch  ## Development/MPI check color consistency
      subroutine DMZcch
     O    (iErr,
     I     NCLR,
     I     Icomm, IRNK, NRNK)
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(OUT,integer) iErr
      _INTENT(IN, integer) NCLR
      _INTENT(IN, integer) Icomm, IRNK, NRNK
CCC_   = Interior
#if OPT_USE_MPI
#     include "mpif.h"
      integer JbufR, JER, JRR, JRQR, JTGR, JSTR (MPI_STATUS_SIZE)
      integer JbufS, JES, JRS, JRQS, JTGS, JSTS (MPI_STATUS_SIZE)
#endif /* OPT_USE_MPI */
CCC_  - Body
#if OPT_USE_MPI
      iErr = 0
      if (NRNK.le.1) then
         continue
      else
         JRS = MOD (IRNK        + 1, NRNK)
         JRR = MOD (IRNK + NRNK - 1, NRNK)
         JbufS = NCLR
         JbufR = 0
         JTGS = JRS
         JTGR = IRNK
         call MPI_ISEND
     $        (JbufS, 1, MPI_INTEGER, JRS, JTGS, Icomm, JRQS, JES)
         call MPI_IRECV
     $        (JbufR, 1, MPI_INTEGER, JRR, JTGR, Icomm, JRQR, JER)
         call MPI_WAIT (JRQS, JSTS, JES)
         call MPI_WAIT (JRQR, JSTR, JER)
         if (JbufS.ne.JbufR) iErr = 1
         call DMZecr (iErr, Icomm, IRNK, NRNK)
       endif
#else  /* not OPT_USE_MPI */
CC    To suppress compiler warning
       iErr = (((0 * NCLR) * Icomm) * IRNK) * NRNK
#endif /* not OPT_USE_MPI */
c$$$      call DAtrcR (-1, iErr, 'R', 'DMZCCH')
      RETURN
      END
CCC_& DMPIMS  ## Development/MPI manager announcement
      subroutine DMPIMS (STRA, STRB, IOP)
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
         STRA = 'OPT_USE_MPI'
         write (STRB, *) OPT_USE_MPI
      else
         STRA = ' '
         STRB = ' '
      endif
      RETURN
      END
CCC_* Test
CCC_ + begin
#if TEST_DMPIMS
CCC_ @ DMTEST  ## Development/MPI test program
      program DMTEST
CCC_  - Test suites
CC::   KINDS   1 2
CC::   SOURCES dpathn.F
CCC_  - Declaration
      implicit none
CCC_   = Parameter
      integer    NRNKW
      parameter (NRNKW = 20)
c$$$      parameter (NRNKW = 1)
      integer    Ntag
      parameter (Ntag = 16)
CC      namelist to error
CCC_   = Interior
      integer    ipA (_MAX_BOOTSTRAP_UNITS)
      integer    ipI, ipO, ipE
#if OPT_USE_MPI
#else /* not OPT_USE_MPI */
      integer    ir,  ic, nc
      character  Cname        * (DMPIMS_COLOR_NAME_LEN)
      character  Pname (Ntag) * (DMPIMS_COLOR_NAME_LEN)
      integer    it
      integer    ik
      integer    IRNKW
#endif /* not OPT_USE_MPI */
      integer    Mgs
      parameter (Mgs = 4)
      integer    Lstr
      parameter (Lstr = 16)
      character  StrIn*(Lstr)
      character  StrOut*(Lstr * Mgs)
c
      integer    Mgi
      parameter (Mgi = 4)
      integer    Nmem
      parameter (Nmem = 8)
      integer    IbfIn  (Nmem)
      integer    IbfOut (Nmem, Mgi)
c
      character CclrC*(16)
      integer irank, nrank, icomm
      integer iMA (MAX_MPI_ATTR)
      integer jr, js0, js9, lslp
      integer j,  jg,  jrto, jrfrom
c
      integer    iErr
CCC_  - Body
      call DPUini (iErr, ' ')
      call DMUini (iErr, 0)
      call DMUbst (iErr, ipA, 1)
      ipI =BOOTSTRAP_IN(ipA)
      ipO =BOOTSTRAP_OUT(ipA)
      ipE =BOOTSTRAP_ERR(ipA)
#if OPT_USE_MPI
      write (ipO, *) 'USE_MPI TRUE'
      if (iErr.eq.0) call DMUcfg (iErr, ipA)
      if (iErr.eq.0) call DMUcfg (iErr, ipA)
#else /* not OPT_USE_MPI */
      write (ipO, *) 'USE_MPI FALSE'
      Pname (1) = 'U'
      Pname (2) = ' '
      Pname (3) = 'D'
      Pname (4) = 'W'
      Pname (5) = 'Q'
      Pname (6) = 'A'
      Pname (7) = 'END'
 101  format ('####', A, ': ', I3, '::', 2I3, '::', 3I3, 1x, A)
      do it = 1, Ntag
         if (Pname (it).eq.'END') goto 200
c$$$         ipO = 20 + it - 1
c$$$         ipE = 40 + it - 1
         do ir = 0, NRNKW - 1
            IRNKW = ir
            call DMCcsc
     O          (iErr,
     O           ic,    nc,    ik,   Cname,
     I           IRNKW, NRNKW, Pname (it),
     I           ipI,   ipO,   ipE)
            write (ipO, 101)
     $           _TRIM(Pname (it)), iErr,
     $           IR, NRNKW,
     $           ic, nc, ik, _TRIM(Cname)
c$$$            if (iErr.ne.0) goto 100
         enddo
 100     continue
      enddo
 200  continue
#endif /* not OPT_USE_MPI */
CCC_   . gather/sub test
      call DMArst (iMA)
      call DMAtop (iMA, CclrC)
      call DMAget (IRANK, iMA, 'IR')
      call DMAget (NRANK, iMA, 'NR')
      call DMAget (ICOMM, iMA, 'CO')
c
 401  format ('CHK', I3.3, 'XX')
      write (StrIn, 401) IRANK
      StrOut = ' '
CCC_    * sleep check
      lslp = Mgs - Mod (IRANK, Mgs)
      call sleep (lslp)
CCC_    * gather/sub
      call DMWgsa (iErr, StrOut, StrIn, Lstr, Mgs, irank, nrank, icomm)
 402  format ('GSA:', I5, '/', A, '/')
      if (MOD (IRANK, Mgs).eq.0) then
         do jr = 0, Mgs - 1
            js0 = jr * Lstr + 1
            js9 = js0 + Lstr - 1
            write (*, 402) IRANK + jr,
     $           _TRIM(StrOut (js0:js9))
         enddo
      endif
CCC_    * gather/sub integer
      do j = 1, Nmem
         IbfIn (j) = IRANK * 100 + j
         do jr = 1, Mgi
            IbfOut (j, jr) = 0
         enddo
      enddo
      lslp = Mgi - Mod (IRANK, Mgi)
      call sleep (lslp)
      call DMWgsi (iErr, IbfOut, IbfIn, Nmem, Mgi, irank, nrank, icomm)
 201  format ('GSI:', 2I3, 1x, I7)
      if (MOD (IRANK, Mgi).eq.0) then
         do jr = 1, Mgi
            do j = 1, Nmem
               write (*, 201) jr, j, IbfOut (j, jr)
            enddo
         enddo
      endif
      jrto = 0
      do jg = 1, (NRANK - 1) / Mgi + 1
         jrfrom = (jg - 1) * Mgi
         call DMWoci
     O       (iErr,
     M        IbfOut,
     I        Nmem,  IRANK, jrto, jrfrom, ICOMM)
c$$$         if (irank.eq.jrto) then
c$$$            call DMWoci
c$$$     O          (iErr,
c$$$     M           IbfOut,
c$$$     I           Nmem,  IRANK, jrto, jrfrom, ICOMM)
c$$$         else if (irank.eq.jrfrom) then
c$$$            call DMWoci
c$$$     O          (iErr,
c$$$     M           IbfOut,
c$$$     I           Nmem,  IRANK, jrto, jrfrom, ICOMM)
c$$$         endif
 301  format ('OCI:', 3I3, 1x, I7)
         if (irank.eq.jrto) then
            do jr = 1, Mgi
               do j = 1, Nmem
                  write (*, 301) jg, jr, j, IbfOut (j, jr)
               enddo
            enddo
         endif
      enddo
CCC_   . development
      call DBmngr
     O     (iErr, ipA)
      call DEBrep (ipO)
      call DPBrep (ipO)
      call DBswpW (iErr, -1, -1)
      call DMWfin (iErr)
      STOP
      END
CCC_ + end
#endif /* TEST_DMPIMS */
CCC_* Obsolete
CCC_ + begin
#if 0
CCC_ & DMWcam  ## Development/MPI circulation absolute max
c$$$      subroutine DMWcam
c$$$     O    (Y,
c$$$     I     V,   NV,
c$$$     I     iMA)
c$$$CCC_  * Declaration
c$$$      implicit none
c$$$#if OPT_USE_MPI
c$$$#  include "mpif.h"
c$$$#endif
c$$$CCC_   = Arguments
c$$$      _INTENT(IN, integer)  NV
c$$$      _INTENT(OUT,_REALSTD) Y
c$$$      _INTENT(IN, _REALSTD) V (NV)
c$$$      _INTENT(IN, integer)  iMA (*)
c$$$CCC_   = Interior
c$$$      integer NR, IRM, ICOM, IRS, IRD
c$$$#if OPT_USE_MPI
c$$$      integer JerrS, JreqS, JtagS, JsttS (MPI_STATUS_SIZE)
c$$$      integer JerrR, JreqR, JtagR, JsttR (MPI_STATUS_SIZE)
c$$$#endif
c$$$      integer l
c$$$      _REALSTD S, R
c$$$CCC_  * Body
c$$$      S = 0.0d0
c$$$      do l = 1, NV
c$$$         S = MAX (ABS (V (l)), S)
c$$$      enddo
c$$$      NR = iMA (_IDX_MPI_NRANKS)
c$$$      if (NR.gt.1) then
c$$$#if OPT_USE_MPI
c$$$         IRM  = iMA (_IDX_MPI_RANK)
c$$$         ICOM = iMA (_IDX_MPI_COMM)
c$$$         IRS  = MOD ((IRM + NR - 1), NR)
c$$$         IRD  = MOD ((IRM + NR + 1), NR)
c$$$         JtagS = IRD
c$$$         JtagR = IRM
c$$$         do l = 1, NR - 1
c$$$            call MPI_ISEND
c$$$     $           (S, 1, _MPI_REALSTD, IRD, JtagS, ICOM, JreqS, JerrS)
c$$$            call MPI_IRECV
c$$$     $           (R, 1, _MPI_REALSTD, IRS, JtagR, ICOM, JreqR, JerrR)
c$$$            call MPI_WAIT (JreqS, JsttS, JerrS)
c$$$            call MPI_WAIT (JreqR, JsttR, JerrR)
c$$$            S = MAX (S, R)
c$$$         enddo
c$$$#endif
c$$$      endif
c$$$      Y = S
c$$$      RETURN
c$$$      END
CCC_ + end
#endif /* 0 */
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
