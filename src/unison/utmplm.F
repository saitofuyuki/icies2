C unison/utmplm.F --- IcIES/Unison/Template manipulation
C Maintainer:  SAITO Fuyuki
C Created: Feb 23 2010
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2020/09/17 08:50:27 fuyuki utmplm.F>'
#define _FNAME 'unison/utmplm.F'
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
CCC_* Description
CC
CCC_ + reference (not completed)
CC
CC       %!       expands to null
CC       %%       expands to single %
CC       %:       expands to : in conditional output context.
CC
CC       %[A]     expands value of A
CC       %A       expands value of A (short form, only when single character)
CC       %[XYZ]   expands value of XYZ
CC       %n[A]    expands first n letters (or all) of value A (if positive n)
CC                expands value of A if n == 0.
CC       %0n[A]   expands first n letters with zero padding if not enough letters.
CC       %+[N]    add sign (+ or -) according to N
CC       %+0n[N]  add sign (+ or -) with zero padding until n letters.
CC
CC       %*[A]    use previous letters to expand.
CC
CC       %(prefix:content)
CC                conditional output.  if content is non-null then concatenate prefix and content
CC                if content is null then expands to null.
CC       %(prefix:content:suffix)
CC                conditional output.  if content is non-null then concatenate prefix, content, and suffix.
CC                if content is null then expands to null.
CC       %n(prefix:content:suffix)
CC                conditional output with the first n letters.
CC       %n(prefix:%[A]:suffix)
CC                conditional output according to the value of A.
CC       %(prefix0:%(prefix1:content1))
CC                nested conditional output.
CC
CCC_* Macros
CCC_ + common
#include "ofdlct.h" /* fortran dialect */
CCC_ + special characters
#define _SPC_INIT(C)    C(1:1)   /* leading character */
#define _SPC_SIGN(C)    C(2:2)   /* sign flag */
#define _SPC_WIDTH(C)   C(3:3)   /* (OBSOLETE) width inheritance */
#define _SPC_LONGL(C)   C(4:4)   /* long name left */
#define _SPC_LONGR(C)   C(5:5)   /* long name right */
#define _SPC_PFXL(C)    C(6:6)   /* prefix left */
#define _SPC_PFXR(C)    C(7:7)   /* prefix right */
#define _SPC_PFXS(C)    C(8:8)   /* prefix separator */
#define _SPC_SKIP(C)    C(9:9)   /* ignore */
#define _SPC_EXTND(C)   C(10:10) /* extend */
#define _SPC_CANCEL(C)  C(11:11) /* cancel */
#define MAX_SPC      11
CCC_ + debug conditions
c$$$#define DBG_UTMPLM_ARG
#ifdef DBG_UTMPLM_ARG
#  define DBG_UTMPLM IDBG
#endif
#ifndef    DBG_UTMPLM
#  define _IDBG -2
#else
#  define _IDBG DBG_UTMPLM
#endif
#define _DBG_STAR  -1
CCC_* Wrappers
CCC_ & UtmpWX  ## Unison/Template Wrapper
      subroutine UtmpWX
     O    (LoopT,  Dst,
     W     W,
     I     Src,
     I     Val, Tag, NTS, OkeepU, IDBG)
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(OUT,integer)   LoopT
      _INTENT(OUT,character) Dst*(*), W*(*)
      _INTENT(IN, character) Src*(*)
      _INTENT(IN, integer)   NTS
      _INTENT(IN, character) Val (*)*(*)
      _INTENT(IN, character) Tag (*)*(*)
      _INTENT(IN, logical)   OkeepU
      _INTENT(IN, integer)   IDBG
CCC_   = Interior
      character CSP*(MAX_SPC)
CCC_  - Body
      call UtmpSC (CSP)
      call UtmpWC
     O    (LoopT, Dst,
     W     W,
     I     Src,   Csp,
     I     Val,   Tag, NTS, -1, OkeepU, IDBG)
      RETURN
      END
CCC_ & UtmpWC  ## Unison/Template Wrapper core
      subroutine UtmpWC
     O    (LoopT,  Dst,
     W     W,
     I     Src,    Csp,
     I     Val,    Tag,    NTS,   LimL,   OkeepU, IDBG)
CCC_  ? Description (TO BE IMPROVED)
CCC_   . CAUTION
CC      DO NOT depend too much on complex recursive expansion!
CC
CCC_   . Arguments
CC       LoopT  total loop count
CC       Dst    result string
CC       W      work area for intermediate results
CC       Src    source template
CC       Csp    special characters for expansion
CC       NTS    size of Tag, Val
CC       Tag    conversion specifier characters for string
CC       Val    target strings corresponding to each conversion specifier
CC       LimL   limit loop count to prevent a infinite loop
CC       OkeepU whether or not to keep unknown conversion specifiers
CC       IDBG   debug level (need compile with DBG_UTMPLM_ARG to enable)
CC
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(OUT,integer)   LoopT
      _INTENT(OUT,character) Dst*(*), W*(*)
      _INTENT(IN, character) Src*(*)
      _INTENT(IN, integer)   NTS
      _INTENT(IN, character) Val (*)*(*)
      _INTENT(IN, character) Tag (*)*(*)
      _INTENT(IN, character) Csp*(*)
      _INTENT(IN, integer)   LimL
      _INTENT(IN, logical)   OkeepU
      _INTENT(IN, integer)   IDBG
CCC_   = Interior
      integer   LC
      integer   LL
CCC_  - Body
      LoopT = 0
      W     = Src
      LL    = LimL
      if (LL .le. 0) LL = 16
CCC_   . Stage 1: string expansion loop
#     if _IDBG > _DBG_STAR
        call UtmpDB (1, W, _IDBG)
#     endif
      call UtmpLS (LC, Dst, W, Csp, Val, Tag, NTS, LL, IDBG)
      LoopT = LoopT + LC
CCC_   . Stage 2: OBSOLETE number expansion loop
CCC_   . Stage 3: delete unknown
      if (.not.OkeepU) then
         W = Dst
#        if _IDBG > _DBG_STAR
           call UtmpDB (3, W, _IDBG)
#        endif
         call UtmpPU (Dst, W, Csp)
      endif
CCC_   . Stage 4: conditional prefix expansion loop
      W = Dst
#     if _IDBG > _DBG_STAR
        call UtmpDB (4, W, _IDBG)
#     endif
      call UtmpLC (LC, Dst, W, Csp,  LL, IDBG)
      LoopT = LoopT + LC
CCC_   . Stage 5: escaped characters expansion
      if (.not.OkeepU) then
         W = Dst
#        if _IDBG > _DBG_STAR
           call UtmpDB (5, W, _IDBG)
#        endif
         call UtmpPE (Dst, W, Csp)
      endif
#     if _IDBG > _DBG_STAR
        call UtmpDB (9, Dst, _IDBG)
#     endif
      RETURN
      END
CCC_* Loop over parsers
CCC_ & UtmpLS  ## Unison/Template/Loop (string expansion)
      subroutine UtmpLS
     O    (LoopC, Dst,
     M     WSrc,
     I     Csp,   Val, Tag, NTS, LimL, IDBG)
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(OUT,  integer)   LoopC
      _INTENT(OUT,  character) Dst*(*)
      _INTENT(INOUT,character) WSrc*(*)
      _INTENT(IN,   integer)   NTS
      _INTENT(IN,   character) Val (*)*(*)
      _INTENT(IN,   character) Tag (*)*(*)
      _INTENT(IN,   character) Csp*(*)
      _INTENT(IN,   integer)   LimL
      _INTENT(IN,   integer)   IDBG
CCC_   = Interior
      integer l
      integer Ncnv
      integer LL
CCC_  - Body
      LL = LimL
      if (LL .le. 0) LL = 16
CC    just for suppression of warning at compilation
      LoopC = 0 * IDBG
      do l = 0, LL
#        if _IDBG > _DBG_STAR
           call UtmpDB (l, Wsrc, _IDBG)
#        endif
         call UtmpPS (Ncnv, Dst, Wsrc, Csp, Val, Tag, NTS)
         if (Ncnv.eq.0) goto 900
         Wsrc  = Dst
         LoopC = LoopC + 1
      enddo
 900  continue
      RETURN
      END
CCC_ & UtmpLC  ## Unison/Template/Loop (conditional prefix)
      subroutine UtmpLC
     O    (LoopC, Dst,
     M     WSrc,
     I     Csp,   LimL, IDBG)
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(OUT,  integer)   LoopC
      _INTENT(OUT,  character) Dst*(*)
      _INTENT(INOUT,character) WSrc*(*)
      _INTENT(IN,   character) Csp*(*)
      _INTENT(IN,   integer)   LimL
      _INTENT(IN,   integer)   IDBG
CCC_   = Interior
      integer l
      integer Ncnv
      integer ll
CCC_  - Body
      LL = LimL
      if (LL .le. 0) LL = 16
CC    just for suppression of warning at compilation
      LoopC = 0 * IDBG
      do l = 0, LL
#        if _IDBG > _DBG_STAR
           call UtmpDB (l, Wsrc, _IDBG)
#        endif
c$$$         write (*, *) 'LC', l, '[', Trim (Wsrc), ']'
         call UtmpPC (Ncnv, Dst, Wsrc, Csp)
         if (Ncnv.eq.0) goto 900
         Wsrc  = Dst
         LoopC = LoopC + 1
      enddo
 900  continue
      RETURN
      END
CCC_ & UtmpDB  ## Unison/Template/Parser (debug)
      subroutine UtmpDB
     I    (K, W, IDBG)
      implicit none
      _INTENT(IN,integer)   K
      _INTENT(IN,character) W*(*)
      _INTENT(IN,integer)   IDBG
 101  format (' UTMPLM/', I2.2, ' [', A, ']')
      if      (IDBG.ge.0) then
         write (IDBG, 101) K, _TRIM(W)
      else if (IDBG.eq._DBG_STAR) then
         write (*,    101) K, _TRIM(W)
      endif
      RETURN
      END
CCC_* Parsers
CCC_ & UtmpPS  ## Unison/Template/Parser (string expansion)
      subroutine UtmpPS
     O    (Ncnv,
     O     Dst,
     I     Src,
     I     Csp,    Val, Tag, NTS)
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(OUT,integer)   Ncnv
      _INTENT(OUT,character) Dst*(*)
      _INTENT(IN, character) Src*(*)
      _INTENT(IN, integer)   NTS
      _INTENT(IN, character) Val (*)*(*)
      _INTENT(IN, character) Tag (*)*(*)
      _INTENT(IN, character) Csp*(*)
CCC_   = Interior
      integer   NWprv, KSprv
      character CPDprv*(4)
      logical   OXTprv
      integer   jpD,   jpS
      integer   lstr
      integer   NW,   Ksign
      integer   kts,  kte
      character ST
      integer   lskpS, lskpD
      integer   it
c
      character CLD, CPL, CPR, CPS, CSK, CXT
      character CPD*(4)
      logical   OXTND
CCC_   = Functions
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
CCC_  - Body
      CLD = _SPC_INIT(CSP)
      CPL = _SPC_PFXL(CSP)
      CPR = _SPC_PFXR(CSP)
      CPS = _SPC_PFXS(CSP)
      CSK = _SPC_SKIP(CSP)
      CXT = _SPC_EXTND(CSP)
c
      Ncnv   = 0
      jpd    = 1
      jps    = 1
      KSprv  = -1
      NWprv  = -1
      CPDprv = ' '
      OXTprv = .false.
      Dst    = ' '
      lstr   = len_trim (Src)
c
      DO
         call UtmpPT
     O       (ST,
     O        LskpS,  Ksign, NW, CPD, OXTND, kts, kte,
     I        Src,    jpS,
     I        Csp)
CCC_   . OBSOLETE (if width inheritance)
         if (NW.eq.-2) then
            NW    = NWprv
            CPD   = CPDprv
            OXTND = OXTprv
            if (Ksign.lt.0) Ksign = KSprv
         endif
         if (ST .eq. 'E') then
c$$$            it = UtmpTS (Tag, NTS, Src (kts:kte))
            call UtmpTS (IT, TAG, NTS, Src (kts:kte))
            if (it.gt.0) then
               call UtmpXT
     O             (lskpD,
     M              Dst,
     I              jpD,  Ksign, NW,   CPD, OXTND, Val (it),
     I              CLD,  CPL,   CPR,  CPS, CSK,   CXT)
               Ncnv = Ncnv + 1
            else
               ST = 'F'
            endif
         endif
         if (ST .ne. 'E') then
            LskpD = LskpS
            Dst (jpD:jpD + LskpD - 1) = Src (jpS:jpS + LskpS - 1)
         endif
         jpS  = jpS + LskpS
         if (jpS.gt.lstr) goto 900
         jpD  = jpD + LskpD
CCC_   . OBSOLETE if width inheritance
         if (NW.ne.-1) then
            KSprv  = Ksign
            NWprv  = NW
            OXTprv = OXTND
            CPDprv = CPD
         endif
      enddo
 900  continue
      RETURN
      END
CCC_ & UtmpPC  ## Unison/Template/Parser (conditional prefix)
      subroutine UtmpPC
     O    (Ncnv, Dst,
     I     Src,  Csp)
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(OUT,integer)   Ncnv
      _INTENT(OUT,character) Dst*(*)
      _INTENT(IN, character) Src*(*)
      _INTENT(IN, character) Csp*(*)
CCC_   = Interior
      integer   jpD,  jpDp, jpDq, jpS
      integer   lstr
      integer   NW,   Ksign
      character CPD*(4)
      logical   OXTND
      integer   kts,  kte
      character ST
      integer   lskpS, lskpD
      integer   j,     izs, ize, lzw
c
      integer   NWS,  KSS
      character CPS*(4)
      logical   OXS
      integer   korg
      integer   lcumP, lcumC, lcumS, ls, lov
c
      character CL0*(MAX_SPC), CL1*(MAX_SPC)
      logical   OaddS
c$$$      logical   OinP
CCC_   = Functions
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
CCC_  - Body
      CL0 = ' '
      CL0 (1:1) = _SPC_SKIP(CSP)
c
      CL1 = ' '
      CL1 (1:1) = _SPC_INIT(CSP)
      CL1 (2:2) = _SPC_PFXR(CSP)
      CL1 (3:3) = _SPC_PFXS(CSP)
      CL1 (4:4) = _SPC_CANCEL(CSP)
c
      Ncnv  = 0
      jpd   = 1
      jpDp  = -1
      jpDq  = -1
      jps   = 1
      Dst   = ' '
      lstr  = len_trim (Src)
      korg  = -1
      lcumC = -1
      lcumP = -1
      lcumS = -1
      NWS   = -1
      OXS   = .false.
      CPS   = ' '
      KSS   = 0
c
c$$$      OinP  = .false.
      DO
         call UtmpPT
     O       (ST,
     O        LskpS,  Ksign, NW, CPD, OXTND, kts, kte,
     I        Src,    jpS,
     I        Csp)
c$$$         write (*, *) 'CC ',
c$$$     $        jpDp, jpDq, ' -- ',
c$$$     $        Trim (ST), korg, ' -- ',
c$$$     $        lcumP, lcumC, lcumS, ' -- ',
c$$$     $        jpS, LskpS, Src (1:jpS), ' ', Src (jpS+1:jpS+LskpS-1),
c$$$     $        ' / ', Trim (Dst)
c$$$     $        OinP
         LskpD = 0
CCC_   . start conditional prefix block
         if      (ST.eq.'P') then
c$$$            write (*, *) 'case P'
c$$$            OinP = .true.
CCC_    * sweep out if already started
            if (korg.gt.0) then
               jpD = jpDp
               LskpD = jpS - korg
               Dst (jpD:jpD + LskpD - 1) = Src (korg:korg + LskpD - 1)
            else
               LskpD = 0
            endif
CCC_    * initiation
            NWS   = NW
            KSS   = Ksign
            CPS   = CPD
            OXS   = OXTND
            korg  = jpS
            jpDp  = jpD + LskpD
            jpDq  = jpDp
            lcumP = 0
            lcumC = -2
            lcumS = -2
CCC_   . inside of suffix block
         else if (lcumS.ge.0) then
c$$$            write (*, *) 'case S'
            LskpD = kte - jpS + 1
            Dst (jpD:jpD + LskpD - 1) = Src (jpS:jpS + LskpD - 1)
            call UtmpTL
     O          (ls,
     I           ST,   Src, kts, kte, CL0,  CL1)
            if (ls.ge.0) then
               if (NWS.gt.0
     $              .and. lcumP.ge.0
     $              .and. lcumC.ge.0
     $              .and. (lcumP + lcumC + lcumS).le.NWS) then
                  lov = MAX (0, ls - (NWS - (lcumP + lcumC + lcumS)))
                  jpDq = jpD + LskpD - 1 - lov
               endif
               lcumS = lcumS + ls
            else
               lcumS = -1
            endif
c$$$            write (*, *) 'case S', lcumS, ls, NWS
CCC_   . inside of contents block
         else if (lcumC.ge.0) then
c$$$            write (*, *) 'case C'
            LskpD = kte - jpS + 1
            Dst (jpD:jpD + LskpD - 1) = Src (jpS:jpS + LskpD - 1)
            call UtmpTL
     O          (ls,
     I           ST,   Src, kts, kte, CL0,  CL1)
            if (OXS.and.CPS.eq.' ') NWS = 0
            if (CPS.ne.' '.and.NWS.gt.0.and.ls.gt.0) then
               continue
            endif
c$$$            write (*, *) 'IC', ls, jpS, LskpD, Src (jpS:jpS + LskpD - 1)
            if (ls.ge.0) then
               if (NWS.gt.0
     $              .and. lcumP.ge.0
     $              .and. (lcumP + lcumC).le.NWS) then
                  lov = MAX (0, ls - (NWS - (lcumP + lcumC)))
                  jpDq = jpD + LskpD - 1 - lov
               endif
               lcumC = lcumC + ls
            else
               lcumC = -1
            endif
CCC_   . inside of prefix block
         else if (lcumP.ge.0) then
c$$$            write (*, *) 'case P'
            LskpD = kte - jpS + 1
            Dst (jpD:jpD + LskpD - 1) = Src (jpS:jpS + LskpD - 1)
            call UtmpTL
     M          (ls,
     I           ST,   Src, kts, kte, CL0,  CL1)
            if (ls.ge.0) then
               if (NWS.gt.0
     $              .and. lcumP.le.NWS) then
                  lov = MAX (0, ls - (NWS - lcumP))
                  jpDq = jpD + LskpD - 1 - lov
               endif
               lcumP = lcumP + ls
            else
               lcumP = -1
            endif
         endif
CCC_   . prefix block end
         if (ST.eq.'p'.and.Korg.gt.0) then
c$$$            write (*, *) 'case p'
            if (lcumC.eq.-2) then
               lcumC  = 0
            else if (lcumS.eq.-2) then
               lcumS  = 0
            endif
CCC_   . content block end
         else if (ST.eq.'c'.and.Korg.gt.0) then
c$$$            write (*, *) 'case c', lcumP, lcumC, lcumS
            if (lcumS.eq.-2) lcumS = 0
c$$$            OinP = .false.
            if (lcumP.ge.0 .and. lcumC.gt.0 .and. lcumS.ge.0) then
               if (KSS.eq.1
     $              .and. INDEX ('0123456789',
     $                           Dst (jpDp:jpDp)).gt.0) then
CC                  write (*, *) 'SR [', Dst (jpDp:jpDp + LskpD - 1), ']'
                  call UtmpSR (Dst, jpDp, jpD + LskpD -1, 1)
                  Dst (jpDp:jpDp) = '+'
                  LskpD = LskpD + 1
                  if (NWS.gt.(lcumP + lcumC + lcumS)) jpDq  = jpDq  + 1
c$$$                  jpDq  = jpDq  + 1
                  OaddS = .true.
c$$$                  write (*, *) 'SR [', Dst (jpDp:jpD + LskpD - 1), ']',
c$$$     $                 jpD, jpDp, jpDq, jpD + LskpD - 1,
c$$$     $                 NWS, lcumP + lcumC
               else
                  OaddS = .false.
               endif
               if (CPS.ne.' '.and.NWS.gt.0) then
                  lzw = NWS - (lcumP + lcumC + lcumS)
                  if (OaddS) lzw = lzw - 1
                  if (lzw.gt.0) then
c$$$                     write (*, *) 'SR1 [', Trim (Dst (jpDp:)), ']', lzw
                     call UtmpSR (Dst, jpDp, jpDq, lzw)
                     if (Dst (jpDp:jpDp).eq.'-'
     $                    .or.Dst (jpDp:jpDp).eq.'+') then
                        izs = jpDp + 1
                        ize = jpDp + lzw
                     else if (lzw.gt.1.and.KSS.eq.1) then
                        Dst (jpDp:jpDp) = '+'
                        izs = jpDp + 1
                        ize = jpDp + lzw - 1
                     else
                        izs = jpDp
                        ize = jpDp + lzw - 1
                     endif
                     do j = izs, ize
                        Dst (j:j) = CPS
                     enddo
                     LskpD = 0
                     jpD = jpDq + 1 + lzw
                  else if (OXS) then
                     continue
                  else
c$$$                     write (*, *) 'SR7', OaddS
                     LskpD = 0
                     jpD = jpDq + 1
c$$$                     if (OaddS) jpD = jpD - 1
                  endif
               else if (NWS.gt.0) then
c$$$                  write (*, *) 'SR6', OaddS, jpDp, jpDq
                  LskpD = 0
                  jpD = jpDq + 1
c$$$                  if (OaddS) jpD = jpD - 1
               else
c$$$                  write (*, *) 'SR8 [', Dst (jpDp:jpD + LskpD -1), ']'
                  continue
               endif
               Ncnv = Ncnv + 1
            else if (lcumC .eq. 0) then
               LskpD = 0
               jpD   = jpDp
               Ncnv = Ncnv + 1
            else
               jpD = jpDp
               LskpD = jpS + LskpS - Korg
c$$$               write (*, *) 'SR9 [', Dst (jpD:jpD + LskpD -1), ']'
c$$$               write (*, *) 'ccc',
c$$$     $              Korg, LskpD, Src (korg:korg + LskpD - 1)
               Dst (jpD:jpD + LskpD - 1)
     $              = Src (korg:korg + LskpD - 1)
            endif
            Korg  = -1
         else if (ST.ne.'P') then
c$$$            write (*, *) 'case P2'
            LskpD = LskpS
            Dst (jpD:jpD + LskpD - 1) = Src (jpS:jpS + LskpS - 1)
         endif
         jpS  = jpS + LskpS
         jpD  = jpD + LskpD
         if (jpS.gt.lstr) goto 900
      ENDDO
 900  continue
c$$$      write (*, *) 'CZ  ', Trim (Dst)
      lstr = len (Dst)
      Dst (jpD:lstr) = ' '
c
      RETURN
      END
CCC_ & UtmpPU  ## Unison/Template/Parser (delete unknown tags)
      subroutine UtmpPU
     O    (Dst,
     I     Src,  Csp)
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(OUT,character) Dst*(*)
      _INTENT(IN, character) Src*(*)
      _INTENT(IN, character) Csp*(*)
CCC_   = Interior
      character ST
      integer   lstr
      integer   NW,    Ksign
      integer   kts,   kte
      integer   jpd,   jps
      integer   lskpS, lskpD
      character CPD*(4)
      logical   OXTND
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
CCC_  - Body
      jpd   = 1
      jps   = 1
      Dst   = ' '
      lstr  = len_trim (Src)
c
      DO
         call UtmpPT
     O       (ST,
     O        LskpS,  Ksign, NW, CPD, OXTND, kts, kte,
     I        Src,    jpS,
     I        Csp)
         if (ST .eq. 'E') then
            if (INDEX (Csp, Src (kts:kte)).gt.0) ST = 'F'
         endif
         if (ST .ne. 'E') then
            LskpD = LskpS
            Dst (jpD:jpD + LskpD - 1) = Src (jpS:jpS + LskpS - 1)
         else
            LskpD = 0
         endif
         jpS  = jpS + LskpS
         if (jpS.gt.lstr) goto 900
         jpD  = jpD + LskpD
      enddo
 900  continue
      RETURN
      END
CCC_ & UtmpPE  ## Unison/Template/Parser (escaped)
      subroutine UtmpPE
     O    (Dst,
     I     Src,  Csp)
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(OUT,character) Dst*(*)
      _INTENT(IN, character) Src*(*)
      _INTENT(IN, character) Csp*(*)
CCC_   = Interior
      character ST
      integer   lstr
      integer   NW,    Ksign
      integer   kts,   kte
      integer   jpd,   jps
      integer   lskpS, lskpD
      character CL0*(MAX_SPC), CL1*(MAX_SPC)
      character CCA
      character CPD*(4)
      logical   OXTND
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
CCC_  - Body
      CL0 = ' '
      CL0 (1:1) = _SPC_SKIP(CSP)
c
      CL1 = ' '
      CL1 (1:1) = _SPC_INIT(CSP)
      CL1 (2:2) = _SPC_PFXR(CSP)
      CL1 (3:3) = _SPC_PFXS(CSP)
c$$$      CL1 (4:4) = CSP (_SPC_CANCEL:_SPC_CANCEL)
c
      CCA = _SPC_CANCEL(CSP)
c
      jpd   = 1
      jps   = 1
      Dst   = ' '
      lstr  = len_trim (Src)
c
      DO
         call UtmpPT
     O       (ST,
     O        LskpS,  Ksign, NW, CPD, OXTND, kts, kte,
     I        Src,    jpS,
     I        Csp)
         if (ST .eq. 'E') then
            if (INDEX (CL0, Src (kts:kte)).gt.0) then
               LskpD = 0
            else if (INDEX (CL1, Src (kts:kte)).gt.0) then
               LskpD = 1
               Dst (jpd:jpd) = Src (kts:kte)
            else if (CCA.eq.Src (kts:kte)) then
               Dst = ' '
               LskpD = - jpD + 1
            else
               ST = 'F'
            endif
         endif
         if (ST .ne. 'E') then
            LskpD = LskpS
            Dst (jpD:jpD + LskpD - 1) = Src (jpS:jpS + LskpS - 1)
         endif
         jpS  = jpS + LskpS
         if (jpS.gt.lstr) goto 900
         jpD  = jpD + LskpD
      enddo
 900  continue
      RETURN
      END
CCC_ & UtmpPT  ## Unison/Template/Parser (one token)
      subroutine UtmpPT
     O    (ST,
     O     LskpS,  Ksign, NW, Cpd, OXTND, kts, kte,
     I     Src,    jpS,
     I     Csp)
CCC_  - Description
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(OUT,character) ST
      _INTENT(OUT,integer)   LskpS
      _INTENT(OUT,integer)   Ksign
      _INTENT(OUT,character) Cpd*(*)
      _INTENT(OUT,logical)   OXTND
      _INTENT(OUT,integer)   NW
      _INTENT(OUT,integer)   kts, kte
      _INTENT(IN, character) Src*(*)
      _INTENT(IN, integer)   jpS
      _INTENT(IN, character) Csp*(*)
CCC_   = Interior
      character CJ
      integer   lsrc
      integer   ipS
      character CLD, CSI, CWD, CLL, CLR, CPL, CPR, CPS, CXT
c
      integer   kns
CCC_   = Functions
      integer UtmpPW
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
CCC_  - Body
CCC_   . clear return values
      LskpS = 0
CCC_   . Special character aliases
      CLD = _SPC_INIT(CSP)
      CSI = _SPC_SIGN(CSP)
      CWD = _SPC_WIDTH(CSP)
      CLL = _SPC_LONGL(CSP)
      CLR = _SPC_LONGR(CSP)
      CPL = _SPC_PFXL(CSP)
      CPR = _SPC_PFXR(CSP)
      CPS = _SPC_PFXS(CSP)
      CXT = _SPC_EXTND(CSP)
CCC_   . initialization
      lsrc  = len_trim (Src)
      ipS   = jpS
      ST    = 'O'
      kts   = ipS
      kte   = lsrc
      NW    = -1
      Ksign = -1
      OXTND = .false.
      Cpd   = ' '
CCC_   . note status ST
CC        O: initial
CC        %: in special token
CC        C: in ordinal token
CC        0: Padding
CC        .: Truncation
CC        p: end of prefix
CC        c: end of content
CC        s: end of suffix
CC        P: conditional expansion
CCC_   . note width
CC       -1: not set
      DO
         if (ipS.gt.lsrc) goto 900
         CJ = Src (ipS:ipS)
CCC_   . begining
         if (ST .eq. 'O') then
            if (CJ .eq. CLD) then
               ST   = '%'
            else
               ST   = 'C'
            endif
         endif
CCC_   . ordinal
         if (ST .eq. 'C') then
            if (CJ .eq. CLD) then
               kte = ipS - 1
               goto 900
            else if (CJ .eq. CPS) then
               ST  = 'p'
               kte = ipS - 1
               ipS = ipS + 1
               goto 900
            else if (CJ .eq. CPR) then
               ST = 'c'
               kte = ipS - 1
               ipS = ipS + 1
               goto 900
            else
               goto 100
            endif
         endif
CCC_   . special token
         if (ST .eq. '%') then
            ST    = '+'
            goto 100
         endif
CCC_    * special: sign
         if (ST .eq. '+') then
            ST = '0'
            NW = -1
            if (CJ .eq. CSI) then
c$$$               kns   = ipS + 1
               Ksign = 1
               goto 100
            endif
            kns = ipS
         endif
CCC_    * special: padding
         if (ST .eq. '0') then
            ST  = 'N'
            Cpd = ' '
            if (CJ .eq. '0') then
               Cpd = CJ
               kns   = ipS + 1
               goto 100
            endif
            kns = ipS
         endif
CCC_    * special: number
         if (ST .eq. 'N') then
            if (CJ .eq. CWD) then
               ST    = '.'
c$$$               nw    = -2
               goto 100
            endif
            if (INDEX ('0123456789', CJ) .gt. 0) then
               goto 100
            endif
            nw     = UtmpPW (kns, ipS - 1, Src)
            ST     = '.'
         endif
CCC_    * special: Truncation
         if (ST .eq. '.') then
            ST = 'X'
            OXTND = (CJ .eq. CXT)
            if (OXTND) goto 100
         endif
CCC_    * special: tag branch
         if (ST .eq. 'X') then
            if (CJ .eq. CLL) then
               kts = ipS + 1
               ST  = 'L'
               goto 100
            else
               kts = ipS
               kte = ipS
               ST  = 'E'
            endif
         endif
CCC_    * special: long name
         if (ST .eq. 'L') then
            if (CJ .eq. CLR) then
               kte = ipS - 1
               ST  = 'E'
            else
               goto 100
            endif
         endif
CCC_    * special: tag expansion
         if (ST .eq. 'E') then
            if (CJ .eq. CPL) then
               ST = 'P'
            endif
            ipS = ipS + 1
            goto 900
         endif
CCC_   . next loop
 100     continue
         ipS = ipS + 1
      ENDDO
CCC_   . loop exit
 900  CONTINUE
      LskpS = ipS - jpS
c
      RETURN
      END
CCC_ & UtmpPW () ## Unison/Template/Parser (width)
      integer function UtmpPW
     I     (kns, kne, FMT)
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(IN, integer)   kns, kne
      _INTENT(IN, character) Fmt*(*)
CCC_  - Body
      if (kns.le.kne) then
         read (Fmt (kns:kne), *) UtmpPW
      else
         UtmpPW = -1
      endif
      RETURN
      END
CCC_* Utilities
CCC_ & UtmpTL  ## Unison/Template token length
      subroutine UtmpTL
     O    (Lstr,
     I     ST,   Src, kts, kte,
     I     CL0,  CL1)
CCC_  - Declaration
CCC_   = Arguments
      _INTENT(OUT,integer)   Lstr
      _INTENT(IN, character) ST
      _INTENT(IN, character) Src*(*)
      _INTENT(IN, integer)   kts, kte
      _INTENT(IN, character) CL0*(*), CL1*(*)
CCC_  - Body
      if (ST.eq.'E') then
         if (INDEX (CL0, Src (kts:kte)).gt.0) then
            Lstr = 0
         else if (INDEX (CL1, Src (kts:kte)).gt.0) then
            Lstr = 1
         else
            Lstr = -1
         endif
      else
         Lstr = kte - kts + 1
      endif
      RETURN
      END
CCC_ & UtmpTS  ## Unison/Template tag search
      subroutine UtmpTS
     O    (IT,
     I     TagA, NT,  T)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)    IT
      _INTENT(IN, integer)    NT
      _INTENT(IN, character)  TagA (NT)*(*)
      _INTENT(IN, character)  T*(*)
      integer    lt, k0
CCC_  - Body
      lt = NT
      k0 = 1
      call UKStgA (IT, TagA, NT, lt, k0, T)
      RETURN
      END
CCC_ & UtmpXT  ## Unison/Template/expansion tag
      subroutine UtmpXT
     O    (lskp,
     M     R,
     I     jp,   Ksign, MaxW, CPD, OXTND, Str,
     I     CLD,  CPL,   CPR,  CPS, CSK,   CXT)
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(OUT,  integer)   lskp
      _INTENT(INOUT,character) R *(*)
      _INTENT(IN,   integer)   jp
      _INTENT(IN,   integer)   MaxW, Ksign
      _INTENT(IN,   character) CPD*(*)
      _INTENT(IN,   logical)   OXTND
      _INTENT(IN,   character) Str *(*)
      _INTENT(IN,   character) CLD,  CPL,  CPR, CPS, CSK, CXT
CCC_   = Interior
      integer   lstr
      integer   ip
CCC_   = Function
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
CCC_  - Body
      ip = jp
CCC_   . initiation
      R (ip:ip)     = CLD
      ip = ip + 1
CCC_   . sign and width
      call UtmpXW
     O    (Lskp,
     M     R,
     I     ip, Ksign, MaxW, CPD, OXTND, CXT)
      ip = ip + lskp
CCC_   . prefix
      R (ip:ip)     = CPL
      R (ip+1:ip+1) = CPS
      ip = ip + 2
CCC_   . expand the sign
#if 0
      if (Ksign.eq.1) then
         if (INDEX ('0123456789', Str (1:1)).gt.0) then
            R (ip:ip) = '+'
            ip = ip + 1
         endif
      endif
#endif
CCC_   . expand the content
      lstr = len_trim (Str)
      R (ip:ip + lstr - 1) = Str (1:lstr)
      ip = ip + lstr
CCC_   . right wrap by prefix specification
      R (ip:ip)     = CPS
      R (ip+1:ip+1) = CPR
      ip = ip + 2
CCC_   . width to remember
      R (ip:ip)     = CLD
      ip = ip + 1
      call UtmpXW
     O    (Lskp,
     M     R,
     I     ip, Ksign, MaxW, CPD, OXTND, CXT)
      ip = ip + lskp
      R (ip:ip) = CSK
      ip = ip + 1
CCC_   . return
      lskp = ip - jp
      RETURN
      END
CCC_ & UtmpXW  ## Unison/Template/expansion width
      subroutine UtmpXW
     O    (Lskp,
     M     R,
     I     jp, Ksign, MaxW, CPD, OXTND, CXT)
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(OUT,  integer)   Lskp
      _INTENT(INOUT,character) R *(*)
      _INTENT(IN,   integer)   jp
      _INTENT(IN,   integer)   Ksign, MaxW
      _INTENT(IN,   character) CPD*(*)
      _INTENT(IN,   logical)   OXTND
      _INTENT(IN,   character) CXT
CCC_   = Interior
      integer ip
      integer l
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
CCC_  - Body
      ip = jp
      if (Ksign.gt.0) then
         R (ip:ip) = '+'
         ip = ip + 1
      endif
      if (CPD.ne.' ') then
         l = len_trim (CPD)
         R (ip:ip + l - 1) = CPD (1:l)
         ip = ip + l
      endif
      if (MaxW.ge.0) then
         call UtmpZI (lskp, R, ip, 0, 1, MaxW)
         ip = ip + lskp
      endif
      if (OXTND) then
         R (ip:ip) = CXT
         ip = ip + 1
      endif
      Lskp = ip - jp
      RETURN
      END
CCC_ & UtmpZI  ## Unison/Template/expansion zero-padding integer
      subroutine UtmpZI
     O    (Lskp,
     M     R,
     I     jp, Ksign, iminw, Inum)
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(OUT,  integer)   Lskp
      _INTENT(INOUT,character) R *(*)
      _INTENT(IN,   integer)   jp
      _INTENT(IN,   integer)   iminw
      _INTENT(IN,   integer)   inum
      _INTENT(IN,   integer)   Ksign
CCC_   = Parameter
CC    Mtmp must be greater than the maximum digits of integer
CC      (it is 2147483647, 10 digits, for 4-bytes)
      integer    Mtmp
      parameter (Mtmp = 16)
      character  TfmtI*(*)
      parameter (TfmtI = '(I16.16)')
CCC_   = Interior
      integer lr
      character Ttmp*(Mtmp)
      integer j
      integer jposNZ
      integer lenZ, lenNZ, lenS
CC            [0]   [1-9]  [+-]
#if HAVE_F77_VERIFY == 0
      integer verify
#endif
CCC_  - Body
      lenS = 0
      if (Inum .eq. 0) then
         if (Ksign.eq.1) then
            R (jp:jp) = '+'
            lenS = lenS + 1
         endif
         lr = Max (lenS, iminw - 1)
         do j = lenS, lr
            R (jp + j:jp + j) = '0'
         enddo
      else
         if (Inum .lt. 0) then
            R (jp:jp) = '-'
            lenS = lenS + 1
            write (Ttmp, TfmtI) -Inum
         else
            if (Ksign.eq.1) then
               R (jp:jp) = '+'
               lenS = lenS + 1
            endif
            write (Ttmp, TfmtI) Inum
         endif
         jposNZ = VERIFY (Ttmp, '0', .false.)
         lenNZ  = Mtmp - jposNZ + 1
         lenZ   = MAX (0, iminw - lenNZ - lenS)
         lr     = lenS + lenZ + lenNZ - 1
         do j = 0, lenZ - 1
            R (jp + lenS + j:jp + lenS + j) = '0'
         enddo
         R (jp + lenS + lenZ:jp + lr) = Ttmp (jposNZ:Mtmp)
      endif
      Lskp = lr + 1
      RETURN
      END
CCC_ & UtmpSR  ## Unison/Template/expansion shift right
      subroutine UtmpSR (S, I0, I9, N)
      implicit none
      _INTENT(INOUT,character) S*(*)
      _INTENT(IN,   integer)   I0, I9, N
      integer j
      do j = I9, I0, -1
         S (j + N:j + N) = S (j:j)
      enddo
      RETURN
      end
CCC_ & UtmpSC  ## Unison/Template special characters manager
      subroutine UtmpSC (CSP)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,character) CSP*(*)
CCC_  - Body
      call UtmpSL (_SPC_INIT(CSP))
      _SPC_SIGN(CSP)  = '+'
      _SPC_WIDTH(CSP) = '*'
      _SPC_LONGL(CSP) = '['
      _SPC_LONGR(CSP) = ']'
      _SPC_PFXL(CSP)  = '('
      _SPC_PFXR(CSP)  = ')'
      _SPC_PFXS(CSP)  = ':'
      _SPC_EXTND(CSP) = '.'
      _SPC_SKIP(CSP)  = '!'
      call UtmpCA (_SPC_CANCEL(CSP))
      RETURN
      END
CCC_ & UtmpSL  ## Unison/Template special characters (leading only)
      subroutine UtmpSL
     O    (CSPL)
      implicit none
      _INTENT(OUT,character) CSPL*(*)
      CSPL = '%'
      RETURN
      END
CCC_ & UtmpCA  ## Unison/Template special characters (cancel only)
      subroutine UtmpCA
     O    (CSPC)
      implicit none
      _INTENT(OUT,character) CSPC*(*)
      CSPC = '#'
      RETURN
      END
CCC_* Tag storage helper
CCC_ & UtmpCS  ## Unison/Template/Helper copy string tag/value
      subroutine UtmpCS
     O    (iErr,
     M          ID,  TD,   SVD,
     I     MD,  Nin, Tin,  SVin)
CCC_  - Description
CC     Copy Tin (Nin), SVin (Nin) array
CC     to TD (MD), SVD (MD) from ID + 1
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)    iErr
      _INTENT(INOUT,integer)    ID
      _INTENT(IN,   integer)    MD,  Nin
      _INTENT(INOUT,character)  TD   (MD)*(*)
      _INTENT(INOUT,character)  SVD  (MD)*(*)
      _INTENT(IN,   character)  Tin  (Nin)*(*)
      _INTENT(IN,   character)  SVin (Nin)*(*)
      integer j, k
CCC_  - Body
      if ((ID + Nin).gt.MD) then
         iErr = -1
      else
         iErr = 0
         k    = 1
         do j = 1, Nin
            if (Tin (j).ne.' ') then
               TD  (ID + k) = Tin  (j)
               SVD (ID + k) = SVin (j)
               k = k + 1
            endif
         enddo
         ID = ID + k - 1
      endif
      RETURN
      END
CCC_ & UtmpCI  ## Unison/Template/Helper copy integer tag/value
      subroutine UtmpCI
     O    (iErr,
     M          ID,  TD,  IVD,
     I     MD,  Nin, Tin, IVin)
CCC_  - Description
CC     Copy Tin (Nin), IVin (Nin) array
CC     to TD (MD), IVD (MD) from ID + 1
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)    iErr
      _INTENT(INOUT,integer)    ID
      _INTENT(IN,   integer)    MD,  Nin
      _INTENT(INOUT,character)  TD   (MD)*(*)
      _INTENT(INOUT,integer)    IVD  (MD)
      _INTENT(IN,   character)  Tin  (Nin)*(*)
      _INTENT(IN,   integer)    IVin (Nin)
      integer j
CCC_  - Body
      if ((ID + Nin).gt.MD) then
         iErr = -1
      else
         iErr = 0
         do j = 1, Nin
            TD  (ID + j) = Tin  (j)
            IVD (ID + j) = IVin (j)
         enddo
         ID = ID + Nin
      endif
      RETURN
      END
CCC_ & UtmpHS  ## Unison/Template/Helper single string tag
      subroutine UtmpHS
     O    (iErr,
     M     ID,  TD,  SVD,
     I     MD,  Tin, SVin,  Cop)
CCC_  - Description
CC     COP 'S': search and store index to iErr (0 if not found)
CC         'R': replace if already defined
CC        else: error if already defined
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(OUT,  integer)    iErr
      _INTENT(INOUT,integer)    ID
      _INTENT(IN,   integer)    MD
      _INTENT(INOUT,character)  TD  (MD)*(*)
      _INTENT(INOUT,character)  SVD (MD)*(*)
      _INTENT(IN,   character)  Tin*(*), SVin*(*)
      _INTENT(IN,   character)  Cop*(*)
CCC_   = Interior
      integer j, JT
CCC_  - Body
      iErr = 0
CCC_   . inquire
      JT = 0
      do j = 1, ID
         if (TD (j).eq.Tin) then
            JT = j
            goto 100
         endif
      enddo
 100  continue
CCC_   . result
      if (Cop (1:1).eq.'S') then
         iErr = JT
      else
         if (JT.eq.0) then
            JT = ID + 1
            if (JT.gt.MD) then
               iErr = 1
            else
               TD  (JT) = Tin
               SVD (JT) = SVin
               ID = ID + 1
            endif
            ID = JT
         else if (Cop (1:1).eq.'R') then
            TD  (JT) = Tin
            SVD (JT) = SVin
         else
            iErr = 1
         endif
      endif
      RETURN
      END
CCC_ & UtmpHI  ## Unison/Template/Helper single integer tag
      subroutine UtmpHI
     O    (iErr,
     M     ID,  TD,  SVD,
     I     MD,  Tin, IVin,  Cop)
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(OUT,  integer)    iErr
      _INTENT(INOUT,integer)    ID
      _INTENT(IN,   integer)    MD
      _INTENT(INOUT,character)  TD  (MD)*(*)
      _INTENT(INOUT,character)  SVD (MD)*(*)
      _INTENT(IN,   character)  Tin*(*)
      _INTENT(IN,   integer)    IVin
      _INTENT(IN,   character)  Cop*(*)
CCC_   = Interior
      integer   jp, lskp, Ksign, iminw
      character W * (32)
CCC_  - Body
      jp    = 1
      Ksign = 0
      iminw = 0
      W     = ' '
      call UtmpZI (lskp, W, jp, Ksign, iminw, IVin)
c$$$      write (*, *) 'HI', IVin, '/', Trim (W), '/'
      call UtmpHS
     O    (iErr,
     M     ID,  TD,  SVD,
     I     MD,  Tin, W,   Cop)
      RETURN
      END
CCC_ & UtmpAL  ## Unison/Template/Helper alias
      subroutine UtmpAL
     O    (iErr,
     M     ID,  TD,   SVD,
     I     MD,  TinL, TinS, Cop)
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(OUT,  integer)    iErr
      _INTENT(INOUT,integer)    ID
      _INTENT(IN,   integer)    MD
      _INTENT(INOUT,character)  TD  (MD)*(*)
      _INTENT(INOUT,character)  SVD (MD)*(*)
      _INTENT(IN,   character)  TinL*(*), TinS*(*)
      _INTENT(IN,   character)  Cop*(*)
      character  W*(64)
      character  CL*(1)
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
CCC_  - Body
      if (TinS.ne.' ') then
         call UtmpSL (CL)
c$$$ 101     format (A, '*[', A, ']')
 101     format (A, '[', A, ']')
         write (W, 101)
     $        _TRIML(CL), _TRIML(TinL)
         call UtmpHS
     O       (iErr,
     M        ID, TD,   SVD,
     I        MD, TinS, W,   Cop)
      endif
      RETURN
      END
CCC_ & UtmpAS  ## Unison/Template/Helper string tag with alias
      subroutine UtmpAS
     O    (iErr,
     M     ID,   TD,   SVD,
     I     MD,   TinL, TinS, SVin,  Cop)
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(OUT,  integer)    iErr
      _INTENT(INOUT,integer)    ID
      _INTENT(IN,   integer)    MD
      _INTENT(INOUT,character)  TD  (MD)*(*)
      _INTENT(INOUT,character)  SVD (MD)*(*)
      _INTENT(IN,   character)  TinL*(*), TinS*(*), SVin*(*)
      _INTENT(IN,   character)  Cop*(*)
CCC_  - Body
      call UtmpHS
     O    (iErr,
     M     ID,  TD,   SVD,
     I     MD,  TinL, SVin,  Cop)
      if (iErr.eq.0) then
         call UtmpAL
     O       (iErr,
     M        ID,  TD,   SVD,
     I        MD,  TinL, TinS,   Cop)
      endif
      RETURN
      END
CCC_ & UtmpAI  ## Unison/Template/Helper integer tag with alias
      subroutine UtmpAI
     O    (iErr,
     M     ID,   TD,   SVD,
     I     MD,   TinL, TinS, IVin,  Cop)
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(OUT,  integer)    iErr
      _INTENT(INOUT,integer)    ID
      _INTENT(IN,   integer)    MD
      _INTENT(INOUT,character)  TD  (MD)*(*)
      _INTENT(INOUT,character)  SVD (MD)*(*)
      _INTENT(IN,   character)  TinL*(*), TinS*(*)
      _INTENT(IN,   integer)    IVin
      _INTENT(IN,   character)  Cop*(*)
CCC_  - Body
      call UtmpHI
     O    (iErr,
     M     ID,  TD,   SVD,
     I     MD,  TinL, IVin,  Cop)
      if (iErr.eq.0) then
         call UtmpAL
     O       (iErr,
     M        ID,  TD,   SVD,
     I        MD,  TinL, TinS,   Cop)
      endif
      RETURN
      END
CCC_& UTMPLM  ## IcIES/Unison/Template manipulation announcement
      subroutine UTMPLM (STRA, STRB, IOP)
CCC_ + Description
CC     called by DevUtl () to return the source information
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
CCC_ + begin
#ifdef TEST_UTMPLM
#define TEST_ALL
#define TEST_KEEP_TRUE   1
#define TEST_KEEP_FALSE  1
CCC_ & TestRg  ## Do Test Registration
      subroutine TestRg (MS, NS, TS, SI)
      implicit none
      _INTENT(IN,  integer)    MS
      _INTENT(OUT, integer)    NS
      _INTENT(OUT, character)  SI (MS)*(*)
      _INTENT(OUT, character)  TS (MS)*(*)
      integer iErr
      integer j
      NS = 0
      call UtmpHS
     O    (iErr,
     M     NS,  TS,  SI,
     I     MS,  'A',     'ALPHA', ' ')
      call UtmpHS
     O    (iErr,
     M     NS,  TS,  SI,
     I     MS,  '_',     '_',     ' ')
      call UtmpHS
     O    (iErr,
     M     NS,  TS,  SI,
     I     MS,  '.',     '.',     ' ')
      call UtmpHS
     O    (iErr,
     M     NS,  TS,  SI,
     I     MS,  'LO',    '0123456789ABCDEF', ' ')
      call UtmpHS
     O    (iErr,
     M     NS,  TS,  SI,
     I     MS,  'X',     '%*A', ' ')
      call UtmpHS
     O    (iErr,
     M     NS,  TS,  SI,
     I     MS,  'Y',     '%*m', ' ')
      call UtmpAS
     O    (iErr,
     M     NS,  TS,  SI,
     I     MS,  'DIR',   'D',  'typewriter', ' ')
      call UtmpHS
     O    (iErr,
     M     NS,  TS,  SI,
     I     MS,  'C',    '%#cancel', ' ')
c
      call UtmpHI
     O    (iErr,
     M     NS,  TS,  SI,
     I     MS,  'p',     23, ' ')
      call UtmpHI
     O    (iErr,
     M     NS,  TS,  SI,
     I     MS,  'm',     -34, ' ')
      call UtmpHI
     O    (iErr,
     M     NS,  TS,  SI,
     I     MS,  'z',     0, ' ')
      call UtmpAI
     O    (iErr,
     M     NS,  TS,  SI,
     I     MS,     'int', 'i', 211,  ' ')
c
 1001 format ('TAG', I3.3, 1x, '[', A, '] [', A, ']')
      do j = 1, NS
         write (*, 1001) j, _TRIM(TS (j)), _TRIM(SI (j))
      enddo
      return
      end
CCC_ & TestPr  ## Do Test Primitive
      subroutine TestPr (F, ICT, OKU, ORST)
CCC_  - Declaration
      implicit none
CCC_   = Parameter
      integer    MS
      parameter (MS = 64)
CCC_   = Arguments
      _INTENT(IN, character)  F*(*)
      _INTENT(IN, integer)    ICT
      _INTENT(IN, logical)    OKU
      _INTENT(IN, logical)    ORST
CCC_   = Save
      integer    NS
      character  SI (MS)*(128)
      character  TS (MS)*(32)
      save       NS, SI, TS
      logical    OFIRST
      data       OFIRST /.true./
      save       OFIRST
CCC_   = Interior
      character R*(1024), W*(1024)
      integer   iErr
      integer   ISTP
      data      ISTP /0/
      save      ISTP
      character CSP*(MAX_SPC)
CCC_  - Body
      if (OFIRST) then
         OFIRST = .false.
         call TestRG (MS, NS, TS, SI)
      endif
      call UtmpSC (CSP)
c
 101  format ('T02', L1, I2.2, I3.3, ': ',
     $     I3, ' <', A, '>', T50, '<', A, '>')
 109  format ('T02', L1, I2.2, I3.3, ': ',
     $     T50, '<', '0123456789012345678901234567890123456789', '>')
c
      if (ORST) then
         write (*, 109) OKU, ICT, 0
         ISTP = 0
      endif
c
      ISTP = ISTP + 1
      call UtmpWX
     O    (iErr, R,
     W     W,
     I     F,    SI, TS, NS, OKU, 0)
      write (*, 101) OKU, ICT, ISTP, iErr, _TRIM(F), _TRIM(R)
c
      return
      end
CCC_ & TestSb  ## Do test sub
      subroutine TestSB
     I     (P, C, ICT, OKU)
      implicit none
      _INTENT(IN, character)  P*(*)
      _INTENT(IN, character)  C*(*)
      _INTENT(IN, integer)    ICT
      _INTENT(IN, logical)    OKU
      integer  ICTsav
      data     ICTsav  /-1/
      save     ICTsav
      logical  ORST
      character F*(1024)
 102  format ('%', A)
 101  format ('%', A, A)
      if (P.eq.' ') then
         if (C (1:1).eq.' ') then
            F = C (2:)
         else
            write (F, 102) _TRIM(C)
         endif
      else
         write (F, 101) _TRIM(P), _TRIM(C)
      endif
      ORST = (ICTsav.ne.ICT)
      call TestPr (F, ICT, OKU, ORST)
      ICTsav = ICT
      return
      end
CCC_ & TestWr  ## Do test wrapper
      subroutine TestWr
     I     (iplog, OKU, C)
      implicit none
      _INTENT(IN, integer)    iplog
      _INTENT(IN, logical)    OKU
      _INTENT(IN, character)  C*(*)
      integer ICT
      data    ICT /0/
      save    ICT
      logical OKUsav
      data    OKUsav /.false./
      save    OKUsav
      if (OKUsav.neqv.OKU) ICT = 0
      OKUsav = OKU
c
      call UDTbna (C, 'SERIES', iplog)

      call TestSB (' ',     C, ICT, OKU)
      if (C (1:1).ne.' ') then
C one
         call TestSB ('+',      C, ICT, OKU)
         call TestSB ('0',      C, ICT, OKU)
         call TestSB ('2',      C, ICT, OKU)
         call TestSB ('4',      C, ICT, OKU)
         call TestSB ('6',      C, ICT, OKU)
         call TestSB ('8',      C, ICT, OKU)
         call TestSB ('10',     C, ICT, OKU)
         call TestSB ('.',      C, ICT, OKU)
C two
         call TestSB ('+0',     C, ICT, OKU)
         call TestSB ('+2',     C, ICT, OKU)
         call TestSB ('+4',     C, ICT, OKU)
         call TestSB ('+6',     C, ICT, OKU)
         call TestSB ('+8',     C, ICT, OKU)
         call TestSB ('+10',    C, ICT, OKU)
         call TestSB ('+.',     C, ICT, OKU)
c
         call TestSB ('00',     C, ICT, OKU)
         call TestSB ('02',     C, ICT, OKU)
         call TestSB ('04',     C, ICT, OKU)
         call TestSB ('06',     C, ICT, OKU)
         call TestSB ('08',     C, ICT, OKU)
         call TestSB ('010',    C, ICT, OKU)
         call TestSB ('0.',     C, ICT, OKU)
c
         call TestSB ('2.',     C, ICT, OKU)
         call TestSB ('4.',     C, ICT, OKU)
         call TestSB ('6.',     C, ICT, OKU)
         call TestSB ('8.',     C, ICT, OKU)
         call TestSB ('10.',    C, ICT, OKU)
C three
         call TestSB ('+00',    C, ICT, OKU)
         call TestSB ('+02',    C, ICT, OKU)
         call TestSB ('+04',    C, ICT, OKU)
         call TestSB ('+06',    C, ICT, OKU)
         call TestSB ('+08',    C, ICT, OKU)
         call TestSB ('+010',   C, ICT, OKU)
         call TestSB ('+0.',    C, ICT, OKU)
c
         call TestSB ('+2.',    C, ICT, OKU)
         call TestSB ('+4.',    C, ICT, OKU)
         call TestSB ('+6.',    C, ICT, OKU)
         call TestSB ('+8.',    C, ICT, OKU)
         call TestSB ('+10.',   C, ICT, OKU)
c
         call TestSB ('00.',    C, ICT, OKU)
         call TestSB ('02.',    C, ICT, OKU)
         call TestSB ('04.',    C, ICT, OKU)
         call TestSB ('06.',    C, ICT, OKU)
         call TestSB ('08.',    C, ICT, OKU)
         call TestSB ('010.',   C, ICT, OKU)
c four
         call TestSB ('+00.',   C, ICT, OKU)
         call TestSB ('+02.',   C, ICT, OKU)
         call TestSB ('+04.',   C, ICT, OKU)
         call TestSB ('+06.',   C, ICT, OKU)
         call TestSB ('+08.',   C, ICT, OKU)
         call TestSB ('+010.',  C, ICT, OKU)
      endif
c
      ICT = ICT + 1
      return
      end
CCC_ @ UTtest  ## UTMPLM test
      program UTtest
CC::   SOURCES ukvtbl.F udbgst.F
CCC_  - Declaration
      implicit none
      integer j
      logical OKU
      logical OTEST
      integer iplog
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
#include "orevan.F" /* 0 */
CCC_  - Body
      iplog = -1
      call UDTbnr ('announcement', iplog)
#define _ANNOUNCE UTMPLM
#define _LEXT     9999
#include "orevan.F" /* 1 */
      do j = 1, 2
         call UDTbnj (j, 'HEAD', ' ', iplog)
         if (TEST_KEEP_TRUE.eq.1.and.j.eq.1) then
            OKU = .true.
            OTEST = .true.
         else if (TEST_KEEP_FALSE.eq.1.and.j.eq.2) then
            OKU = .false.
            OTEST = .true.
         else
            OKU = .false.
            OTEST = .false.
         endif
         if (OTEST) then
            call TestWr (iplog, OKU, ' ordinal')
            call TestWr (iplog, OKU, 'N')
            call TestWr (iplog, OKU, 'A')
            call TestWr (iplog, OKU, 'D')
            call TestWr (iplog, OKU, '[LO]')
            call TestWr (iplog, OKU, '[DIR]')
            call TestWr (iplog, OKU, 'p')
            call TestWr (iplog, OKU, 'p%p')
            call TestWr (iplog, OKU, 'p%*p')
            call TestWr (iplog, OKU, 'p%00!%*p')
            call TestWr (iplog, OKU, 'm')
            call TestWr (iplog, OKU, 'z')
            call TestWr (iplog, OKU, 'i')
            call TestWr (iplog, OKU, '!%i')
            call TestWr (iplog, OKU, '!%+i')
            call TestWr (iplog, OKU, '!%+*i')
            call TestWr (iplog, OKU, ' %5(pfx:content)')
            call TestWr (iplog, OKU, ' abc%5(pfx:content)def')
            call TestWr (iplog, OKU, ' %5(pfx:)')
            call TestWr (iplog, OKU, '(123:789)')
            call TestWr (iplog, OKU, '(pfx:content)')
            call TestWr (iplog, OKU, '(pfx:content:sfx)')
            call TestWr (iplog, OKU, '(pfx::sfx)')
            call TestWr (iplog, OKU, '(pfx%:pfx%3!:(con%)tent)')
            call TestWr (iplog, OKU, '(pfx%N:foobar)')
            call TestWr (iplog, OKU, '(pfx:%A)')
            call TestWr (iplog, OKU, '(p0:%(p1:%(p2:con2)))')
            call TestWr (iplog, OKU, '(_i:%[IRW])')
            call TestWr (iplog, OKU, '(_i%!:%[IRW])')
            call TestWr (iplog, OKU, '(%_i:%[IRW])')
            call TestWr (iplog, OKU, 'X')
            call TestWr (iplog, OKU, 'Y')
            call TestWr (iplog, OKU, '(a%!b:c%!)')
            call TestWr (iplog, OKU, '(a%!b:c%:)')
            call TestWr (iplog, OKU, '(a%:b:c%:)')
            call TestWr (iplog, OKU, '(pfx%#:%#)')
            call TestWr (iplog, OKU, ' ABC%#XYZ')
            call TestWr (iplog, OKU, ' ABC%(%#:abc)')
            call TestWr (iplog, OKU, ' ABC%Cxyz')
            call TestWr (iplog, OKU, ' xyz%[LO]pqr%Aabc%N')
c
            call TestWr (iplog, OKU, '(pfx:%A)')
            call TestWr (iplog, OKU, '(pfx:%A:)')
            call TestWr (iplog, OKU, '(pfx:%A:sfx)')
            call TestWr (iplog, OKU, '(:%A:sfx)')
            call TestWr (iplog, OKU, '(:%A:)')
            call TestWr (iplog, OKU, '(pfx:%N)')
            call TestWr (iplog, OKU, '(pfx:%N:)')
            call TestWr (iplog, OKU, '(pfx:%N:sfx)')
            call TestWr (iplog, OKU, '(:%N:sfx)')
            call TestWr (iplog, OKU, '(:%N:)')
            call TestWr (iplog, OKU, '(pfx:con:sfx)')
            call TestWr (iplog, OKU, '(pfx:con)')
            call TestWr (iplog, OKU, '(con)')
            call TestWr (iplog, OKU, '(:con)')
            call TestWr (iplog, OKU, '(:con:)')
            call TestWr (iplog, OKU, '(pfx:)')
            call TestWr (iplog, OKU, '(pfx::)')
            call TestWr (iplog, OKU, '(::sfx)')
            call TestWr (iplog, OKU, '(pfx:con:)')
            call TestWr (iplog, OKU, '(pfx::sfx)')
            call TestWr (iplog, OKU, '(:con:sfx)')
c
         endif
      enddo
c
      call UDTbnr ('END', iplog)
c
      stop
      end
CCC_ + end
#endif /* TEST_UTMPLM */
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
