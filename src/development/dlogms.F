C development/dlogms.F --- IcIES/Development/Log-SYSIN manipulation
C Maintainer:  SAITO Fuyuki
C Created: Feb 17 2010
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2020/09/17 08:42:49 fuyuki dlogms.F>'
#define _FNAME 'development/dlogms.F'
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
CCC_* Macros
#include "ofdlct.h" /* fortran dialect */
#include "ologfm.h" /* logging */
#include "ofnstd.h"
#include "odevel.h"
#include "ounelv.h" /* namelist emulation levels */
c
#define _LU_STAR   -1
#define _LU_UNDEF  -2
#define _LU_IGNORE -3
#define _LU_STRING -4
#define _LU_ERROR  -128
c
#define CHANNEL_LEN 8
#ifndef   OPT_MODULE_LEN
#  define OPT_MODULE_LEN 8
#endif
c
#define _TMPL_CLASS_INPUT  'S'
#define _TMPL_CLASS_OUTPUT 'O'
#define _TMPL_CLASS_LOG    'L'
c
#define _TMPL_ITEM_INPUT  'input'
#define _TMPL_ITEM_OUTPUT 'output'
#define _TMPL_ITEM_ERROR  'error'
c
#ifndef    OPT_NAMELIST_OUTPUT_EMULATION
#  define  OPT_NAMELIST_OUTPUT_EMULATION _UNMLEM_LEVEL_END
#endif
c
#ifndef    TEST_DLOGMS
#  define  TEST_DLOGMS 0
#endif
CCC_ + default input/output/error switches
#define DSW_BOOTSTRAP 0   /* bootstrap if not file */
#define DSW_ASTERISK  1   /* asterisk  if not file */
#define DSW_IGNORE    2   /* nothing   if not file */
#define DSW_ERROR     3   /* error     if not file */
CCC_& DLinit  ## Development/Log initialization suite (bootstrap)
      subroutine DLinit
     O    (iErr,
     I     ibsA)
CCC_ + Declaration
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(IN, integer) ibsA (*)
CCC_ + Body
      call DLiniC
     $    (iErr, ibsA,
     $     DSW_BOOTSTRAP, DSW_BOOTSTRAP, DSW_BOOTSTRAP, .true.)
      call DAtrcB (ibsA, iErr, 'R', 'DLINIT')
      RETURN
      END
CCC_& DLiniA  ## Development/Log initialization suite (asterisk for output)
      subroutine DLiniA
     O    (iErr,
     I     ibsA)
CCC_ + Declaration
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(IN, integer) ibsA (*)
CCC_ + Body
      call DLiniC
     $    (iErr, ibsA,
     $     DSW_BOOTSTRAP, DSW_ASTERISK, DSW_ASTERISK, .true.)
      call DAtrcB (ibsA, iErr, 'R', 'DLINIA')
      RETURN
      END
CCC_& DLiniN  ## Development/Log initialization suite (null for output)
      subroutine DLiniN
     O    (iErr,
     I     ibsA)
CCC_ + Declaration
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(IN, integer) ibsA (*)
CCC_ + Body
      call DLiniC
     $    (iErr, ibsA,
     $     DSW_BOOTSTRAP, DSW_IGNORE, DSW_IGNORE, .false.)
      call DAtrcB (ibsA, iErr, 'R', 'DLININ')
      RETURN
      END
CCC_& DLiniC  ## Development/Log initialization suite core
      subroutine DLiniC
     O    (iErr,
     I     ibsA, KswI, KswO, KswE,
     I     Ovbs)
CCC_ + Declaration
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(IN, integer) ibsA (*)
      _INTENT(IN, integer) KswI, KswO, KswE
      _INTENT(IN, logical) Ovbs
      integer jeB, jeG, jeI, jeO, jeC
CCC_ + Body
      call DLDbfr (jeB)
c
      call DLGtmp (jeG, ibsA)
c
      call DLImng (jeI, ibsA, KswI,       Ovbs)
      call DLOmng (jeO, ibsA, KswO, KswE, Ovbs)
      call DLDmng (jeC, ibsA)
c
      iErr = 0
      if (jeI.ne.0) iErr = iErr + 1
      if (jeO.ne.0) iErr = iErr + 2
      if (jeC.ne.0) iErr = iErr + 4
c
      call DAtrcB (ibsA, iErr, 'R', 'DLINIC')
      RETURN
      END
CCC_ & DLGtmp  ## Development/Log Global template configuration
      subroutine DLGtmp
     O    (iErr,
     I     ibsA)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(IN, integer) ibsA (*)
      integer ibsI, ibsO, ibsE
CCC_  - Body
      iErr = 0
      ibsI = BOOTSTRAP_IN(ibsA)
      ibsO = BOOTSTRAP_OUT(ibsA)
      ibsE = BOOTSTRAP_ERR(ibsA)
      call DPUcfG (iErr, ibsI, ibsO, ibsE, ' ', ' ')
      RETURN
      END
CCC_* [DLI] input manager
CCC_ & DLImng  ## Development/Log/Input manager
      subroutine DLImng
     O    (iErr,
     I     ibsA,  KswI, Ovbs)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(IN, integer) ibsA (*)
      _INTENT(IN, integer) KswI
      _INTENT(IN, logical) Ovbs
      integer idfI
      integer ibsI, ibsO, ibsE
      integer jErr
CCC_  - Body
      iErr = 0
      ibsI = BOOTSTRAP_IN(ibsA)
      ibsO = BOOTSTRAP_OUT(ibsA)
      ibsE = BOOTSTRAP_ERR(ibsA)
C
      call DLDrgU (jErr, '*', ibsI)
CCC_   . open (return this error)
      call DLIopn (iErr, idfI, KswI, ibsI, ibsO, ibsE, Ovbs)
CCC_   . default channel registeration
      if (idfI.ge.0) then
         call DLDrgU (jErr, '-', idfI)
      else
         call DLDrgU (jErr, '-', ibsI)
      endif
      RETURN
      END
CCC_ & DLIopn  ## Development/Log/Input open
      subroutine DLIopn
     O    (iErr, idfI,
     I     KswI, ibsI, ibsO, ibsE, Ovbs)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(OUT,integer) idfI
      _INTENT(IN, integer) KswI
      _INTENT(IN, integer) ibsI, ibsO, ibsE
      _INTENT(IN, logical) Ovbs
      character FN*(OPT_FILENAME_MAX)
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
CCC_  - Body
      iErr = 0
      FN = ' '
      call DPUrgs
     $     (iErr, ibsI, ibsO, ibsE, _TMPL_CLASS_INPUT, ' ', '%!')
      call DPUpth (iErr, FN, _TMPL_CLASS_INPUT, _TMPL_ITEM_INPUT, ibsE)
cn
 101  format ('default input equals to bootstrap ', I3)
 102  format ('default ', A, '(', I3, 1x, I3, '): ', A)
 103  format ('default input equals to special ', I3)
 109  format ('default input PANIC ', I3)
      if (FN .eq. ' ') then
         if       (KswI .eq. DSW_BOOTSTRAP) then
            idfI = ibsI
            write (ibsE, 101) idfI
            if (Ovbs) write (*, 101) idfI
         else if  (KswI .eq. DSW_ASTERISK)  then
            idfI = _LU_STAR
            write (ibsE, 103) idfI
            if (Ovbs) write (*, 103) idfI
         else if  (KswI .eq. DSW_IGNORE)    then
            idfI = _LU_IGNORE
            write (ibsE, 103) idfI
            if (Ovbs) write (*, 103) idfI
         else if  (KswI .eq. DSW_ERROR)     then
            idfI = ibsI
            write (ibsE, 109) idfI
            if (Ovbs) write (*, 109) idfI
            iErr = -1
         else
            idfI = ibsI
            write (ibsE, 109) idfI
            if (Ovbs) write (*, 109) idfI
            iErr = -2
         endif
      else
         call UUopnQ (iErr, idfI, FN, 0, 'F', 'O', 'R', ' ')
         call UUMCsf (idfI, -1)
         write (ibsE, 102) 'input', idfI, iErr, _TRIML(FN)
         if (Ovbs)
     $        write (*, 102) 'input', idfI, iErr, _TRIML(FN)
      endif
c
      call DAtrcU (ibsE, iErr, 'R', 'DLIOPN')
      RETURN
      END
CCC_* [DLO] output manager
CCC_ & DLOmng  ## Development/Log/Output manager
      subroutine DLOmng
     O    (iErr,
     I     ibsA, KswO, KswE, Ovbs)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(IN, integer) ibsA (*)
      _INTENT(IN, integer) KswO, KswE
      _INTENT(IN, logical) Ovbs
      integer idfO, idfE
      integer ibsI, ibsO, ibsE
      integer ipCfg
      integer jErr
      integer idef
CCC_  - Body
      iErr = 0
      ibsI = BOOTSTRAP_IN(ibsA)
      ibsO = BOOTSTRAP_OUT(ibsA)
      ibsE = BOOTSTRAP_ERR(ibsA)
c
      ipCfg = ibsI
CCC_   . open
      if (iErr.eq.0) then
         idef = ibsE
         call DLOopn
     $       (iErr, idfE,
     $        KswE, ipCfg, ibsO, ibsE, _TMPL_ITEM_ERROR,  idef, Ovbs)
      endif
      if (iErr.eq.0) then
         idef = ibsO
         call DLOopn
     $       (iErr, idfO,
     $        KswO, ipCfg, ibsO, ibsE, _TMPL_ITEM_OUTPUT, idef, Ovbs)
      endif
CCC_   . default channel registeration (ignore these errors)
      call DLDrgU (jErr, '0', ibsE)
      call DLDrgU (jErr, '1', ibsO)
      call DLDrgU (jErr, '2', idfE)
      call DLDrgU (jErr, '3', idfO)
c
      RETURN
      END
CCC_ & DLOopn  ## Development/Log/Output open
      subroutine DLOopn
     O    (iErr,  IFP,
     I     Ksw,   ipCfg, ibsO, ibsE, CMDL, IDF, Ovbs)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   IFP
      _INTENT(IN, integer)   Ksw
      _INTENT(IN, integer)   ipCfg, ibsO, ibsE, IDF
      _INTENT(IN, character) CMDL*(*)
      _INTENT(IN, logical)   Ovbs
      character FN*(OPT_FILENAME_MAX)
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
CCC_  - Body
      iErr = 0
      FN   = ' '
      call DPUrgs
     $     (iErr, ipCfg, ibsO, ibsE, _TMPL_CLASS_OUTPUT, ' ', ' ')
      if (iErr.eq.0)
     $     call DPUpth (iErr, FN, _TMPL_CLASS_OUTPUT, CMDL, ibsE)
c
      IFP = IDF
 101  format ('default ', A, ' equals to bootstrap ', I3)
 102  format ('default ', A, '(', I3, 1x, I3, '): ', A)
 103  format ('default ', A, ' equals to special ', I3)
 109  format ('default ', A, ' PANIC ', I3)
      if (FN .eq. ' ') then
         if       (Ksw .eq. DSW_BOOTSTRAP) then
            IFP = IDF
            write (ibsE, 101) _TRIM(CMDL), IFP
            if (Ovbs)
     $           write (*, 101) _TRIM(CMDL), IFP
         else if  (Ksw .eq. DSW_ASTERISK)  then
            IFP = _LU_STAR
            write (ibsE, 103) _TRIM(CMDL), IFP
            if (Ovbs)
     $           write (*, 103) _TRIM(CMDL), IFP
         else if  (Ksw .eq. DSW_IGNORE)    then
            IFP = _LU_IGNORE
            write (ibsE, 103) _TRIM(CMDL), IFP
            if (Ovbs)
     $           write (*, 103) _TRIM(CMDL), IFP
         else if  (Ksw .eq. DSW_ERROR)     then
            IFP = IDF
            write (ibsE, 109) _TRIM(CMDL), IFP
            if (Ovbs)
     $           write (*, 109) _TRIM(CMDL), IFP
            iErr = -1
         else
            IFP = IDF
            write (ibsE, 109) _TRIM(CMDL), IFP
            if (Ovbs)
     $           write (*, 109) _TRIM(CMDL), IFP
            iErr = -2
         endif
      else
         if (iErr.eq.0) then
            call UUopnQ (iErr, IFP, FN, 0, 'F', 'U', 'W', ' ')
            call UUMCsf (IFP, -1)
         endif
         write (ibsE, 102) _TRIM(CMDL), IFP, iErr, _TRIML(FN)
         if (Ovbs)
     $        write (*, 102) _TRIM(CMDL), IFP, iErr, _TRIML(FN)
      endif
c
      call DAtrcU (ibsE, iErr, 'R', 'DLOOPN')
      RETURN
      END
CCC_* [DLC] channel manager
CCC_ & DLCmng  ## Development/Log/Channel manager (default)
      subroutine DLCmng (ipA, CMDL)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   ipA  (*)
      _INTENT(IN, character) CMDL*(*)
      character CfgA (LOG_CHANNEL_MAX)*(CHANNEL_LEN)
      integer   ipI, ipO, ipE
      integer   iErr
CCC_  - Body
      call DLDcpy (ipA, CfgA)
      call DLUpcl (iErr, ipI, ipO, ipE, ipA)
      call DLCmnI (ipA, CfgA, CMDL, ipI, ipO, ipE)
      RETURN
      END
CCC_ & DLCmnD  ## Development/Log/Channel manager (before sweeper)
      subroutine DLCmnD (ipA, CMDL)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   ipA  (*)
      _INTENT(IN, character) CMDL*(*)
      character CfgA (LOG_CHANNEL_MAX)*(CHANNEL_LEN)
      integer   ipI, ipO, ipE
      integer   iErr
CCC_  - Body
      call DLDcpy (ipA, CfgA)
      call DLUpbb (iErr, ipI, ipO, ipE, ipA)
      call DLCmnI (ipA, CfgA, CMDL, ipI, ipO, ipE)
      RETURN
      END
CCC_ & DLCmnI  ## Development/Log/Channel manager (core)
      subroutine DLCmnI
     M    (ipA,  CfgA,
     I     CMDL, ipI, ipO, ipE)
CCC_  - Declaration
      implicit none
      integer    Lmax
      parameter (Lmax = 26)
      _INTENT(INOUT,integer)   ipA  (*)
      _INTENT(INOUT,character) CfgA (*)*(*)
      _INTENT(IN,   character) CMDL*(*)
      _INTENT(IN,   integer)   ipI, ipO, ipE
      integer   iErr
      integer   ju
      character CFG*(CHANNEL_LEN)
      integer   j, jch
      integer   l
      character TCH
      integer NCH
CCC_  - Body
CCC_   . configuration
      do j = 1, LOG_CHANNEL_NUM
         jch = j
         call DLUcfg (iErr, ju, CFG, jch, CMDL, ipI, ipO, ipE)
         if (ju.eq._LU_UNDEF) then
            continue
         else if (ju.eq._LU_STRING) then
            call DLUssI (iErr, ipA, CfgA, jch, CFG)
         else
            call DLUsuI (iErr, ipA,       jch, ju)
         endif
c$$$         write (*, *) trim(CMDL), j, ju, CFG, ipA (j), CfgA (j)
      enddo
CCC_   . parser loop
      NCH = 0
      do l = 0, Lmax
         NCH = 0
         do j = 1, LOG_CHANNEL_NUM
            jch = j
            ju  = ipA  (jch)
            CFG = CfgA (jch)
            if (ju.eq._LU_STRING) then
               TCH = CFG (2:2)
               call DLUxuC (iErr, ju, TCH, ipA)
               if (ju.ge. _LU_STAR) call DLUsuI (iErr, ipA, jch, ju)
            endif
            if (ju.ge. _LU_STAR) NCH = NCH + 1
        enddo
         if (NCH.ge.LOG_CHANNEL_NUM) goto 900
      enddo
 900  continue
c
      call DLUrpC (ipE, ipA, CfgA, CMDL)
c
      RETURN
      END
CCC_* [DLD] Default channels manager
CCC_ & DLDmng  ## Development/Log/Default manager
      subroutine DLDmng
     O    (iErr,
     I     ibsA)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(IN, integer) ibsA (*)
      integer ibsI, ibsO, ibsE
      integer j, ju, jch
      character CFG*(CHANNEL_LEN)
      integer   jErr
CCC_  - Body
      iErr = 0
      ibsI = BOOTSTRAP_IN(ibsA)
      ibsO = BOOTSTRAP_OUT(ibsA)
      ibsE = BOOTSTRAP_ERR(ibsA)
c
      call DPUrgs (iErr, ibsI, ibsO, ibsE, _TMPL_CLASS_LOG, ' ', ' ')
c
      if (iErr.eq.0) then
         call DLDrgS (jErr, 'I', '<-')
         call DLDrgS (jErr, 'E', '>2')
         call DLDrgS (jErr, 'O', '>3')
c
         call DLDrgS (jErr, 'P', '<I')
         call DLDrgS (jErr, 'L', '>E')
         call DLDrgS (jErr, 'C', '>O')
         call DLDrgS (jErr, 'J', '>N')
c
         do j = 1, LOG_CHANNEL_NUM
            jch = j
            call DLDiqU (jErr, ju, jch)
            if (ju.eq._LU_UNDEF) then
CC             keep this error
               call DLUcfg (iErr, ju, CFG, jch, ' ', ibsI, ibsO, ibsE)
               if (iErr.ne.0) goto 900
               if (ju.eq._LU_UNDEF) then
                  call DLDriS (jErr, jch, '>L')
               else if (ju.eq._LU_STRING) then
                  call DLDriS (jErr, jch, CFG)
               else
                  call DLDriU (jErr, jch, ju)
               endif
            endif
         enddo
      endif
 900  continue
      call DAtrcU (ibsE, iErr, 'R', 'DLDMNG')
c
      RETURN
      END
CCC_ & DLDbfr  ## Development/Log/Default buffer
      subroutine DLDbfr (iErr)
CCC_  - Declaration
      implicit none
CCC_   = Parameters
      integer    MaxCh
      parameter (MaxCh = LOG_CHANNEL_MAX)
      integer    LCH
      parameter (LCH   = CHANNEL_LEN)
CCC_   = Arguments
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   IU
      _INTENT(IN, character) CHi*(*)

      _INTENT(IN, integer)   IUi
      _INTENT(OUT,integer)   IUA  (*)
      _INTENT(OUT,character) CFGA (*)*(*)
      _INTENT(IN, character) CFG*(*)
      _INTENT(IN, integer)   ICH
      _INTENT(IN, integer)   IFP
      _INTENT(OUT,integer)   irepU
      _INTENT(IN, integer)   idefU
CCC_   = Save
      integer    IPD (MaxCh)
      data       IPD /MaxCh * _LU_UNDEF/
      save       IPD
      character  CFGD (MaxCh) * (Lch)
      save       CFGD
      data       CFGD /MaxCh * ' '/
CCC_   = Interior
      integer   j
CCC_  - Body (DLDbfr)
      iErr = 0
      RETURN
CCC_  & DLDrgU  ## Development/Log/Default registration (ch/unit)
      entry DLDrgU
     O    (iErr,
     I     CHi,  IUi)
      call DLUsuC (iErr, IPD, CHi, IUi)
      RETURN
CCC_  & DLDriU  ## Development/Log/Default registration (ich/unit)
      entry DLDriU
     O    (iErr,
     I     ICH,  IUi)
      call DLUsuI (iErr, IPD, ICH, IUi)
      return
CCC_  & DLDrgS  ## Development/Log/Default registration (ch/string)
      entry DLDrgS
     O    (iErr,
     I     CHi,  CFG)
      call DLUssC (iErr, IPD, CFGD, CHi, CFG)
      RETURN
CCC_  & DLDriS  ## Development/Log/Default registration (ich/string)
      entry DLDriS
     O    (iErr,
     I     ICH,  CFG)
      call DLUssI (iErr, IPD, CFGD, ICH, CFG)
      return
c$$$CCC_ & DLCqcU  ## Development/Log/Channel inquire (unit)
c$$$      subroutine DLCqcU
c$$$     O    (iErr, IU,
c$$$     I     CH)
c$$$      implicit none
c$$$      _INTENT(OUT,integer)   iErr
c$$$      _INTENT(OUT,integer)   IU
c$$$      _INTENT(IN, character) CH*(*)
c$$$      integer   ICH
c$$$      call DLZc2i (ICH, CH)
c$$$      call DLCiqU (iErr, IU, ICH)
c$$$      RETURN
CCC_  & DLDiqU  ## Development/Log/Default inquire (unit)
      entry DLDiqU
     O    (iErr, IU,
     I     ICH)
      call DLUxuI (iErr, IU, ICH, IPD)
      return
CCC_  & DLDcpy  ## Development/Log/Default copy default
      entry DLDcpy (IUA, CFGA)
      do j = 1, MaxCh
         IUA  (j) = IPD  (j)
         CFGA (j) = CFGD (j)
      enddo
      return
CCC_  & DLDrpU  ## Development/Log/Default get report unit
      entry DLDrpU (irepU, idefU)
      irepU = idefU
      if (irepU.lt.0) then
         call DLZc2i (j, '2')
         if (IPD (j).lt.0) call DLZc2i (j, '0')
         if (IPD (j).lt.0) call DLZc2i (j, '3')
         if (IPD (j).lt.0) call DLZc2i (j, '1')
         irepU = IPD (j)
      endif
      return
CCC_  & DLDirp  ## Development/Log/Default report (interior)
      entry DLDirp (IFP)
      call DLUrpC (IFP, IPD, CFGD, ' ')
      RETURN
CCC_  - End (DLDbfr)
      END
CCC_ & DLDrep  ## Development/Log/Default report wrapper
      subroutine DLDrep (IFP)
      implicit none
      _INTENT(IN,integer)  IFP
      integer  JFP
      call DLDrpU (JFP, IFP)
      call DLDirp (JFP)
      RETURN
      END
CCC_* DLU: utility
CCC_ & DLUcfg  ## Development/Log/Utility channel configuration by namelist
      subroutine DLUcfg
     O    (iErr, IU,   CFG,
     I     ICH,  CMDL, ipI, ipO, ipE)
CCC_  - Description
CC     Return IU (bound unit) or CFG to duplication
CCC_  - Declaration
      implicit none
CCC_   = Parameter
      integer    MaxErr
      parameter (MaxErr = 16)
CCC_   = Arguments
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   IU
      _INTENT(OUT,character) CFG*(*)
      _INTENT(IN, integer)   ICH
      _INTENT(IN, character) CMDL*(*)
      _INTENT(IN, integer)   ipI, ipO, ipE
CCC_   = Configuration
      character FILE*(OPT_FILENAME_MAX)
      character ROOT*(OPT_FILENAME_MAX)
      character CH  *(CHANNEL_LEN)
      character MDL *(OPT_MODULE_LEN)
      integer   IOSR
      namelist /NILOGC/ IOSR, MDL, CH, FILE, ROOT
      integer    LVEML
      parameter (LVEML = OPT_NAMELIST_OUTPUT_EMULATION)
CCC_   = Interior
      integer   IOS
      integer   INL
      character TCH
      logical   OSET
      logical   OEOF
CCC_  - Body
      iErr = 0
      CFG  = ' '
      IU   = _LU_UNDEF
      call DLZi2c (ICH, TCH)
CCC_   . get configuration for MDL/CH
      call DAchfU (ipI, 'NILOGC', ipO)
c
      call UUrwnd (IOS, ipI)
      INL = 0
      OSET = .false.
      DO
         MDL  = ' '
         CH   = ' '
         FILE = ' '
         ROOT = ' '
         if (IOS .eq. 0) read (ipI, NILOGC, IOSTAT = IOS)
         IOSR = IOS
         call UUieof (OEOF, IOS)
         if (OEOF) goto 100
         INL = INL + 1
         if (IOS .ne. 0) then
            iErr = iErr + 1
 301        format ('DLUCFG NILOGC ERROR (', I5, ') AT ', I4)
            write (ipE, 301) IOS, INL
            IOS = 0
         endif
         if (MDL .eq. CMDL .and. CH .eq. TCH) then
            OSET = .true.
            goto 100
         endif
         if (iErr.gt.MaxErr) goto 100
      ENDDO
 100  continue
CCC_   . output
      MDL = CMDL
      CH  = TCH
      if (LVEML.gt.0) then
         call UNBbgn (iErr, 'NILOGC',       ipO, LVEML)
         call UNBint (iErr, 'IOSR',  IOSR,  ipO, LVEML)
         call UNBstr (iErr, 'MDL',   MDL,   ipO, LVEML)
         call UNBstr (iErr, 'CH',    CH,    ipO, LVEML)
         call UNBstr (iErr, 'FILE',  FILE,  ipO, LVEML)
         call UNBstr (iErr, 'ROOT',  ROOT,  ipO, LVEML)
         call UNBend (iErr, 'NILOGC',       ipO, LVEML)
      else
         write (ipO, NILOGC)
      endif
CCC_   . binding
      if (OSET) then
CCC_    * dup to other channels (duplication by upper)
         if (FILE (1:1) .eq. '>') then
            IU  = _LU_STRING
            CFG = FILE
CCC_    * path name by template
         else
            call DLUtmp (iErr, IU, FILE, ROOT, CMDL, TCH, ipE)
         endif
      endif
c$$$      call DAtrcR (ipE, iErr, 'R', 'DLUCFG')
      RETURN
      END
CCC_ & DLUtmp  ## Development/Log/Utility template
      subroutine DLUtmp
     O    (iErr, IU,
     M     FILE,
     I     ROOT, CMDL, CH,
     I     ipE)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(OUT,  integer)   IU
      _INTENT(INOUT,character) FILE*(*)
      _INTENT(IN,   character) ROOT*(*), CMDL*(*), CH*(*)
      _INTENT(IN,   integer)   ipE
      integer    jCls
      integer    MV
      parameter (MV = 5)
      integer    N
      character  TagA (MV)*(16)
      character  ValA (MV)*(OPT_FILENAME_MAX)
      integer    lf
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
CCC_  - Body
      iErr = 0
CCC_   . path name
      call DPBrgC (iErr, jCls, _TMPL_CLASS_LOG)
      call DPUset (N, TagA, ValA, MV, ' ')
      if (ROOT.ne.' ') call DPUadd (N, TagA, ValA, MV, 'ROOT', Root)
      call DPUadd (N, TagA, ValA, MV, 'MDL', CMDL)
      call DPUadd (N, TagA, ValA, MV, 'CH',  CH)
 309  format ('DLUTMP:WARNING: OVERFLOW', 2I4)
      if (N.gt.MV) then
         write (ipE, 309) N, MV
         N = MV
      endif
CCC_   . i/o unit
      call DPUptC (iErr, FILE, jCls, TagA, ValA, N, ipE)
      call UUMCnu (iErr, IU)
      if (FILE (1:1).eq.'<') then
         lf = len (FILE)
         call UUopen (iErr, IU, FILE (2:lf), 0, 'F', 'U', 'R', ' ')
      else
         call UUopen (iErr, IU, FILE, 0, 'F', 'U', 'W', ' ')
      endif
      call UUMCsf (IU, -1)
CCC_   . report
      if (iErr.eq.0) then
         write (ipE, 101) 'SUCCESS',
     $        _TRIM(CMDL), _TRIM(CH), iErr, IU, _TRIML(FILE)
      else
         write (ipE, 101) 'FAILED',
     $        _TRIM(CMDL), _TRIM(CH), iErr, IU, _TRIML(FILE)
      endif
 101  format ('DLUCFG OPEN ', A, ' [', A, '/', A, '] ', I4, I3, 1x, A)
      RETURN
      END
CCC_ & DLUxuC  ## Development/Log/Utility extract unit by channel
      subroutine DLUxuC
     O    (iErr, IU,
     I     CH,   IUA)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   IU
      _INTENT(IN, character) CH*(*)
      _INTENT(IN, integer)   IUA (*)
      integer   ICH
      call DLZc2i (ICH, CH)
      call DLUxuI (iErr, IU,    ICH, IUA)
      RETURN
      END
CCC_ & DLUsuC  ## Development/Log/Utility set unit by channel
      subroutine DLUsuC
     O    (iErr, IUA,
     I     CH,   IU)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   IUA (*)
      _INTENT(IN, character) CH*(*)
      _INTENT(IN, integer)   IU
      integer   ICH
      call DLZc2i (ICH, CH)
      call DLUsuI (iErr, IUA,   ICH, IU)
      RETURN
      END
CCC_ & DLUssC  ## Development/Log/Utility set string by character
      subroutine DLUssC
     O    (iErr, IUA, CfgA,
     I     CH,   Str)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   IUA  (*)
      _INTENT(OUT,character) CfgA (*)*(*)
      _INTENT(IN, character) CH*(*)
      _INTENT(IN, character) Str*(*)
      integer   ICH
      call DLZc2i (ICH, CH)
      call DLUssI (iErr, IUA, CfgA,   ICH, Str)
      RETURN
      END
CCC_ & DLUxuI  ## Development/Log/Utility extract unit by index
      subroutine DLUxuI
     O    (iErr, IU,
     I     ICH,  IUA)
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(OUT,integer) IU
      _INTENT(IN, integer) ICH
      _INTENT(IN, integer) IUA (*)
      if (ICH.le.0 .or. ICH.gt.LOG_CHANNEL_MAX) then
         iErr = -1
         IU   = -1
      else
         iErr = 0
         IU   = IUA (ICH)
      endif
      RETURN
      END
CCC_ & DLUsuI  ## Development/Log/Utility set unit by index
      subroutine DLUsuI
     O    (iErr, IUA,
     I     ICH,  IU)
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(OUT,integer) IUA (*)
      _INTENT(IN, integer) IU
      _INTENT(IN, integer) ICH
      if (ICH.le.0 .or. ICH.gt.LOG_CHANNEL_MAX) then
         iErr = -1
      else
         iErr = 0
         IUA (ICH) = IU
      endif
      RETURN
      END
CCC_ & DLUssI  ## Development/Log/Utility set string by index
      subroutine DLUssI
     O    (iErr, IUA, CfgA,
     I     ICH,  Str)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   IUA  (*)
      _INTENT(OUT,character) CfgA (*)*(*)
      _INTENT(IN, integer)   ICH
      _INTENT(IN, character) Str*(*)
      if (ICH.le.0 .or. ICH.gt.LOG_CHANNEL_MAX) then
         iErr = -1
      else
         iErr = 0
         IUA  (ICH) = _LU_STRING
         CfgA (ICH) = Str
      endif
      RETURN
      END
CCC_ & DLUrpC  ## Development/Log/Utility channel report
      subroutine DLUrpC (IFP, IUA, CfgA, CMDL)
CCC_  - Declaration
      implicit none
      _INTENT(IN,integer)   IFP
      _INTENT(IN,integer)   IUA  (*)
      _INTENT(IN,character) CfgA (*)*(*)
      _INTENT(IN,character) CMDL
      integer   jch
      character Tch
      character FNM*(OPT_FILENAME_MAX)
      integer   jErr
      logical   ONMD
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
CCC_  - Body
 101  format ('DLURPC report (', A, ')')
 109  format ('DLURPC report (', A, ') DONE')
 102  format (I2, ' [', A1, '] ', I4, ' (', A2, ')')
 103  format (I2, ' [', A1, '] ', I4, ' (', A2, ') ', A)
      if (COND_N(IFP)) then
         write (IFP, 101) CMDL (1:1)
         do jch = 1, LOG_CHANNEL_MAX
            call DLZi2c (jch, Tch)
            if (IUA (jch).ge.0) then
               call UUqunm (jErr, ONMD, FNM, IUA (jch))
               if (.not.ONMD) FNM = '*scratch*'
               write (IFP, 103)
     $              jch, Tch, IUA (jch), _TRIM(CfgA (jch)),
     $              _TRIML(FNM)
            else
               write (IFP, 102)
     $              jch, Tch, IUA (jch), _TRIM(CfgA (jch))
            endif
         enddo
         write (IFP, 109) CMDL (1:1)
      else if (COND_S(IFP)) then
#        define IFP *
         write (IFP, 101) CMDL (1:1)
         do jch = 1, LOG_CHANNEL_MAX
            call DLZi2c (jch, Tch)
            if (IUA (jch).ge.0) then
               call UUqunm (jErr, ONMD, FNM, IUA (jch))
               if (.not.ONMD) FNM = '*scratch*'
               write (IFP, 103)
     $              jch, Tch, IUA (jch), _TRIM(CfgA (jch)),
     $              _TRIML(FNM)
            else
               write (IFP, 102)
     $              jch, Tch, IUA (jch), _TRIM(CfgA (jch))
            endif
         enddo
         write (IFP, 109) CMDL (1:1)
#        undef  IFP
      endif
      RETURN
      END
CCC_ & DLUchP  ## Development/Log/Utility get channel P
      subroutine DLUchP (iErr, ip, ipA)
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(OUT,integer) ip
      _INTENT(IN, integer) ipA (*)
      call DLUxuC (iErr, ip, 'P', ipA)
      if (ip.lt.0) call DLUxuC (iErr, ip, '-', ipA)
      if (ip.lt.0) call DLUxuC (iErr, ip, '*', ipA)
      RETURN
      END
CCC_ & DLUchL  ## Development/Log/Utility get channel L
      subroutine DLUchL (iErr, ip, ipA)
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(OUT,integer) ip
      _INTENT(IN, integer) ipA (*)
      call DLUxuC (iErr, ip, 'L', ipA)
      if (ip.lt.0) call DLUxuC (iErr, ip, '2', ipA)
      if (ip.lt.0) call DLUxuC (iErr, ip, '0', ipA)
      RETURN
      END
CCC_ & DLUchC  ## Development/Log/Utility get channel C
      subroutine DLUchC (iErr, ip, ipA)
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(OUT,integer) ip
      _INTENT(IN, integer) ipA (*)
      call DLUxuC (iErr, ip, 'C', ipA)
      if (ip.lt.0) call DLUxuC (iErr, ip, '3', ipA)
      if (ip.lt.0) call DLUxuC (iErr, ip, '1', ipA)
      RETURN
      END
CCC_ & DLUpcl  ## Development/Log/Utility get channel PCL
      subroutine DLUpcl
     O    (iErr, IUP, IUC, IUL,
     I     ipA)
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(OUT,integer) IUP, IUC, IUL
      _INTENT(IN, integer) ipA (*)
      iErr = 0
      call DLUchP (iErr, IUP, ipA)
      call DLUchC (iErr, IUC, ipA)
      call DLUchL (iErr, IUL, ipA)
      call DAtrcA (ipA, iErr, 'R', 'DLUPCL')
      RETURN
      END
CCC_ & DLUpbb  ## Development/Log/Utility get channel P01
      subroutine DLUpbb
     O    (iErr, IUP, IUC, IUL,
     I     ipA)
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(OUT,integer) IUP, IUC, IUL
      _INTENT(IN, integer) ipA (*)
      call DLUchP (iErr, IUP, ipA)
      call DLUxuC (iErr, IUC, '1', ipA)
      call DLUxuC (iErr, IUL, '0', ipA)
      RETURN
      END
CCC_* DLZ: misc
CCC_ & DLZc2i  ## Development/Log utility channel to index
      subroutine DLZc2i (IDX, CH)
      implicit none
      character  Pseq *(*)
      parameter (Pseq = LOG_CHANNEL_STRING)
      _INTENT(OUT,integer)   IDX
      _INTENT(IN, character) CH
      IDX = INDEX (Pseq, CH)
      RETURN
      END
CCC_ & DLZi2c  ## Development/Log utility index to channel
      subroutine DLZi2c (IDX, CH)
      implicit none
      character  Pseq *(*)
      parameter (Pseq = LOG_CHANNEL_STRING)
      _INTENT(OUT,character) CH
      _INTENT(IN, integer)   IDX
      CH = Pseq (IDX:IDX)
      RETURN
      END
CCC_ & DLZswp  ## Development/Log Bootstrap sweeper
      subroutine DLZswp
     O    (iErr,
     I     ipA)
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(IN, integer) ipA (*)
      integer ipP, ipC, ipL
      iErr = 0
      call DLUpcl (iErr, ipP, ipC, ipL, ipA)
      call DBswpT (iErr, ipC, ipL, .true.)
      call DAtrcA (ipA, iErr, 'R', 'DLZSWP')
      RETURN
      END
CCC_& DLOGMS  ## Development/Log announcement
      subroutine DLOGMS (STRA, STRB, IOP)
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
         STRA = 'OPT_MODULE_LEN'
         write (STRB, *) OPT_MODULE_LEN
      else
         STRA = ' '
         STRB = ' '
      endif
      RETURN
      END
CCC_* Test
CCC_ + begin
#if TEST_DLOGMS
CCC_ @ DLTEST  ## Development/Log test
      program DLTEST
CCC_  - Test suites
CC::   SOURCES dmpims.F
CC::   KINDS   1 2 3 4
CCC_  - Declaration
      implicit none
CCC_   = Interior
      integer   Ierr
      integer   ibsA (_MAX_BOOTSTRAP_UNITS)
      integer   irepU
      integer   icA (LOG_CHANNEL_MAX)
CCC_  - Body
      iErr = 0
      call DMinit (iErr, ibsA, 0, 1, 2)
c$$$      if (iErr.eq.0) call DMUbst (iErr, ibsA, 1)
c$$$      if (iErr.eq.0) call DMUcfg (iErr, ibsA)
c$$$      if (iErr.eq.0) call DMUcfg (iErr, ibsA)
c
#if TEST_DLOGMS == 1
      if (iErr.eq.0)
     $     call DPinit (iErr, ' ', 'O', _FNAME, TEST_DLOGMS)
#else
      if (iErr.eq.0)
     $     call DPinit (iErr, '%!', ' ', ' ', TEST_DLOGMS)
#endif
c$$$      if (iErr.eq.0) call DPUini (iErr, ' ')
c
#if    TEST_DLOGMS == 1
      if (iErr.eq.0) call DLinit (iErr, ibsA)
#elif  TEST_DLOGMS == 2
      if (iErr.eq.0) call DLinit (iErr, ibsA)
#elif  TEST_DLOGMS == 3
      if (iErr.eq.0) call DLiniA (iErr, ibsA)
#else
      if (iErr.eq.0) call DLiniN (iErr, ibsA)
#endif
c
      if (iErr.eq.0) then
         call DLCmnD (icA, 'X')
         call DLZswp (iErr, icA)
      endif
c
      if (iErr.eq.0) call DLDrpU (irepU, -1)
c
      call DEBrep (irepU)
      call DPBrep (irepU)
      call DLDrep (irepU)
      call DBswpW (iErr, -1, -1)
      call DMWfin (iErr)
      STOP
      END
CCC_ + end
#endif /* TEST_DLOGMS */
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
