C development/dpathn.F --- Development/Path name generator
C Maintainer:  SAITO Fuyuki
C Created: Feb 17 2010
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2020/09/15 11:48:31 fuyuki dpathn.F>'
#define _FNAME 'development/dpathn.F'
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
CCC_* Policy
CC    DPU*  user modules
CC    DPS*  standard templates
CC    DPB*  buffer management
CC    DPC*  class-dependent attributes
CCC_* Macros
#include "ofdlct.h" /* fortran dialect */
#include "ologfm.h" /* logging */
#include "odevel.h"
#include "ounelv.h" /* namelist emulation levels */
CCC_ + misc
#ifndef    PATH_SEPARATOR
#  define  PATH_SEPARATOR '/'
#endif
#ifndef    OPT_NAMELIST_OUTPUT_EMULATION
#  define  OPT_NAMELIST_OUTPUT_EMULATION _UNMLEM_LEVEL_ENTRY
#endif
CCC_ + default
#ifndef    OPT_DPATHN_TAG_LEN
#  define  OPT_DPATHN_TAG_LEN   32
#endif
#ifndef    OPT_DPATHN_VALUE_LEN
#  define  OPT_DPATHN_VALUE_LEN 128
#endif
#ifndef    OPT_DPATHN_FORMAT_LEN
#  define  OPT_DPATHN_FORMAT_LEN OPT_DPATHN_VALUE_LEN
#endif
#ifndef    OPT_DPATHN_TAG_MAX
#  define  OPT_DPATHN_TAG_MAX   256
#endif
CCC_ + global modules
#ifndef    OPT_DPATHN_GLOBAL_MAX
#  define  OPT_DPATHN_GLOBAL_MAX 64
#endif
#ifndef    OPT_DPATHN_GTAG_LEN
#  define  OPT_DPATHN_GTAG_LEN   OPT_DPATHN_TAG_LEN
#endif
#ifndef    OPT_DPATHN_GVALUE_LEN
#  define  OPT_DPATHN_GVALUE_LEN OPT_DPATHN_VALUE_LEN
#endif
CCC_ + class-dependent modules
#ifndef    OPT_DPATHN_CLASS_MAX
#  define  OPT_DPATHN_CLASS_MAX 16
#endif
#ifndef    OPT_DPATHN_CLASS_LEN
#  define  OPT_DPATHN_CLASS_LEN 16
#endif
CCC_ + class-dependent modules (common)
#ifndef    OPT_DPATHN_COMMON_MAX
#  define  OPT_DPATHN_COMMON_MAX 32
#endif
#ifndef    OPT_DPATHN_CTAG_LEN
#  define  OPT_DPATHN_CTAG_LEN   OPT_DPATHN_TAG_LEN
#endif
#ifndef    OPT_DPATHN_CVALUE_LEN
#  define  OPT_DPATHN_CVALUE_LEN OPT_DPATHN_VALUE_LEN
#endif
CCC_ + class-dependent modules (each)
#ifndef    OPT_DPATHN_EACH_MAX
#  define  OPT_DPATHN_EACH_MAX   32
#endif
#ifndef    OPT_DPATHN_ETAG_LEN
#  define  OPT_DPATHN_ETAG_LEN   OPT_DPATHN_TAG_LEN
#endif
#ifndef    OPT_DPATHN_EVALUE_LEN
#  define  OPT_DPATHN_EVALUE_LEN OPT_DPATHN_VALUE_LEN
#endif
CCC_ + error
#define _ERR_CLASS_OVERFLOW -1
#define _ERR_CLASS_NEW       1
CCC_ + Test
#ifndef    TEST_DPATHN
#  define  TEST_DPATHN 0
#endif
CCC_& DPinit  ## Development/Path initialization suite
      subroutine DPinit
     O    (iErr,
     I     DTMPL, TOP, EXE, KEXE)
CCC_ + Description
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, character) DTMPL*(*)
      _INTENT(IN, character) TOP*(*)
      _INTENT(IN, character) EXE*(*)
      _INTENT(IN, integer)   KEXE
      integer jcDef
CCC_ + Body
      iErr = 0
      call DPBmng ()
c
      call DPBrgC (iErr, jcDef, ' ')
      call DPSfmF (iErr, DTMPL,    jcDef)
      call DPSfmD (iErr, '%[D0]',  jcDef)
      call DPSfmT (iErr, '%[T1] ', TOP, jcDef)
      call DPSfmS (iErr, '%[S2]', jcDef)
      call DPSfmB (iErr, '%[B0]', jcDef)
      call DPSfmP (iErr, '%[P0]', jcDef)
      call DPSfmX (iErr, '%[X0]', jcDef)
      call DPSfmR (iErr, '%[R1]', jcDef)
      call DPSfmN (iErr)
      call DPSmsc (iErr)
c
      call DPSgex (iErr, EXE, KEXE)
c
      RETURN
      END
CCC_* DPU: user modules
CCC_ & DPUini  ## Development/Path/User initialization
      subroutine DPUini
     O    (iErr,
     I     DTMPL)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, character) DTMPL*(*)
      integer jcDef
CCC_  - Body
      iErr = 0
      call DPBmng ()
c
      call DPBrgC (iErr, jcDef, ' ')
      call DPSfmF (iErr, DTMPL,   jcDef)
      call DPSfmD (iErr, '%[D0]', jcDef)
      call DPSfmT (iErr, '%[T0]', ' ', jcDef)
      call DPSfmS (iErr, '%[S0]', jcDef)
      call DPSfmB (iErr, '%[B0]', jcDef)
      call DPSfmP (iErr, '%[P0]', jcDef)
      call DPSfmX (iErr, '%[X0]', jcDef)
      call DPSfmR (iErr, '%[R0]', jcDef)
      call DPSfmN (iErr)
      call DPSmsc (iErr)
      RETURN
      END
c$$$CCC_ & DPUrgA  ## Development/Path/User class registration wrapper
c$$$      subroutine DPUrgA
c$$$     O    (iErr,
c$$$     I     ipA,  C, DROOT, DTMPL)
c$$$      implicit none
c$$$      _INTENT(OUT,integer)   iErr
c$$$      _INTENT(IN, integer)   ipA (*)
c$$$      _INTENT(IN, character) C*(*)
c$$$      _INTENT(IN, character) DROOT*(*), DTMPL*(*)
c$$$      integer ipI, ipO, ipE
c$$$      ipE = FPL(ipA)
c$$$      ipO = FPC(ipA)
c$$$      ipI = FPP(ipA)
c$$$      call DPUrgs (iErr, ipI, ipO, ipE, C, DROOT, DTMPL)
c$$$      RETURN
c$$$      END
CCC_ & DPUcfG  ## Development/Path/User global registration
      subroutine DPUcfG
     O    (iErr,
     I     ipI, ipO, ipE, DROOT, DTMPL)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   ipI,  ipO,  ipE
      _INTENT(IN, character) DROOT*(*), DTMPL*(*)
      integer jCls
CCC_  - Body
      iErr = 0
      call DPBrgC (iErr, jCls, ' ')
      call DPCciC
     O     (iErr,
     I      ipI,  ipO,  ipE,  jCls, ' ', DROOT, DTMPL)
      RETURN
      END
CCC_ & DPUrgs  ## Development/Path/User class registration
      subroutine DPUrgs
     O    (iErr,
     I     ipI, ipO, ipE, C, DROOT, DTMPL)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   ipI,  ipO,  ipE
      _INTENT(IN, character) C*(*)
      _INTENT(IN, character) DROOT*(*), DTMPL*(*)
      integer jCls
CCC_  - Body
      iErr = 0
      call DPBrgC (iErr, jCls, C)
      if (iErr .eq. _ERR_CLASS_NEW) then
         call DPBrsC (iErr, ' ', jCls)
         call DPCciC
     O       (iErr,
     I        ipI,  ipO,  ipE,  jCls, C, DROOT, DTMPL)
      else if (iErr.eq.0) then
 101     format ('DPURGA WARNING: ALREADY DEFINED ', A)
         if (COND_N(ipE)) then
            write (ipE, 101) _TRIM(C)
         else if (COND_S(ipE)) then
            write (*,   101) _TRIM(C)
         endif
      endif
      RETURN
      END
CCC_ & DPUset  ## Development/Path/User set one-time array
      subroutine DPUset
     O    (N,    TagA, ValA,
     I     MV,   Vitem)
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(IN, integer)   MV
      _INTENT(OUT,character) TagA (MV)*(*)
      _INTENT(OUT,character) ValA (MV)*(*)
      _INTENT(OUT,integer)   N
      _INTENT(IN, character) Vitem*(*)
CCC_  - Body
      N = 0
      if (MV.gt.N) then
         N = N + 1
         TagA (N) = 'ITEM'
         if (VITEM.eq.' ') then
            ValA (N) =  'null_item'
         else
            ValA (N) =  VITEM
         endif
      endif
      if (MV.gt.N) then
         N = N + 1
         TagA (N) = '/'
         ValA (N) = PATH_SEPARATOR
      endif
      RETURN
      END
CCC_ & DPUadd  ## Development/Path/User add item to one-time array
      subroutine DPUadd
     M    (N,
     M     TagA, ValA,
     I     MV,   TS,    VS)
CCC_  - Description
CC    N overflow should be checked after call
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)   MV
      _INTENT(INOUT,integer)   N
      _INTENT(INOUT,character) TagA (MV)*(*)
      _INTENT(INOUT,character) ValA (MV)*(*)
      _INTENT(IN,   character) TS*(*), VS*(*)
CCC_  - Body
      if (TS.ne.' ') then
         N = N + 1
         if (N.le.MV) then
            TagA (N) = TS
            ValA (N) = VS
         endif
      endif
      RETURN
      END
CCC_ & DPUpth  ## Development/Path/User get path
      subroutine DPUpth
     O    (iErr,  Path,
     I     Class, Vitem,   ipL)
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,character) Path*(*)
      _INTENT(IN,   character) Class*(*)
      _INTENT(IN,   character) Vitem*(*)
      _INTENT(IN,   integer)   ipL
CCC_   = Interior
      integer    jCls
      integer    MV
      parameter (MV = 2)
      integer    N
      character  TagA (MV)*(OPT_DPATHN_CTAG_LEN)
      character  ValA (MV)*(OPT_DPATHN_CVALUE_LEN)
CCC_  - Body
      iErr = 0
      call DPBrgC (iErr, jCls, Class)
      call DPUset (N, TagA, ValA, MV, Vitem)
      call DPUptC (iErr, Path, jCls, TagA, ValA, N, ipL)
      RETURN
      END
CCC_ & DPUptC  ## Development/Path/User get path core
      subroutine DPUptC
     O    (iErr,
     M     Path,
     I     jCls, TS, SV, MS, ipL)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,character) Path*(*)
      _INTENT(IN,   integer)   jCls
      _INTENT(IN,   integer)   MS
      _INTENT(IN,   character) TS (*)*(*)
      _INTENT(IN,   character) SV (*)*(*)
      _INTENT(IN,   integer)   ipL
c
      character WS*(OPT_FILENAME_MAX), WW*(OPT_FILENAME_MAX)
      integer Lstg
c
      integer    Mtag, Ltag, Lval
      parameter (Mtag = OPT_DPATHN_TAG_MAX)
      parameter (Ltag = OPT_DPATHN_TAG_LEN)
      parameter (Lval = OPT_DPATHN_VALUE_LEN)
c
      character  TSO (Mtag) * (Ltag)
      character  SVO (Mtag) * (Lval)
c
      integer    ISO, NSO
CCC_  - Body
      iErr = 0
      ISO  = 0
      if (iErr.eq.0) then
         call UtmpCS
     $       (iErr,   ISO,  TSO,  SVO,
     $        Mtag,   MS,   TS,   SV)
      endif
      if (iErr.eq.0) then
         call DPBcpy
     O       (iErr,
     M        TSO, SVO, ISO, Mtag, jCls)
      endif
      if (iErr.eq.0) then
         if (Path.eq.' ') then
            WS = '%[FILE]'
         else
            WS = Path
         endif
 101     format ('DPUPTC STARTER ', A)
 109     format ('DPUPTC RESULT ',  A)
         if       (COND_N(ipL)) then
            write (ipL, 101) _TRIM(WS)
         else if (COND_S(ipL)) then
            write (*,   101) _TRIM(WS)
         endif
         call UtmpWX
     O       (Lstg, Path,
     W        WW,
     I        WS,
     I        SVO, TSO, ISO, .false., ipL)
         if (COND_N(ipL)) then
            write (ipL, 109) _TRIM(Path)
         else if (COND_S(ipL)) then
            write (*,   109) _TRIM(Path)
         endif
      endif
      NSO = Min (ISO, Mtag)
      call DPBIrp
     $     (ipL,   'X',  jCls, '-',
     $      Mtag,  ISO,  NSO,  TSO,  SVO)

      RETURN
      END
#if 0
CCC_ & DPUmdf  ## Development/Path/User modify path
      subroutine DPUmdf
     O    (iErr,
     M     Path,  Ipos,
     I     Class)
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,character) Path*(*)
      _INTENT(INOUT,integer)   Ipos
      _INTENT(IN,   character) Class*(*)
CCC_   = Interior
      integer jCls
CCC_  - Body
      iErr = 0
      call DPBrgC (iErr, jCls, Class)
      call DPUmdC (iErr, Path, Ipos, jCls, PATH_SEPARATOR, '%_')
      RETURN
      END
CCC_ & DPUmdC  ## Development/Path/User modify path core
      subroutine DPUmdC
     O    (iErr,
     M     Path, Ipos,
     I     jCls, CSL, CSEP)
CCC_  - Description
CC      Set Ipos = -1 for first call
CC      return Ipos == 0 if end
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,character) Path*(*)
      _INTENT(INOUT,integer)   Ipos
      _INTENT(IN,   integer)   jCls
      _INTENT(IN,   character) CSL, CSEP*(*)
CCC_   = Interior
      integer   lp, lsep
      character W*(OPT_FILENAME_MAX)
CCC_   . Dummy
      character  DS (1)*(1), DI (1)*(1)
      character  SD (1)*(1)
      integer    ID (1)
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
CCC_  - Body
      iErr = 0
      lp = len_trim (Path)
      if (Ipos.lt.0) then
         Ipos = lp
      else
         Ipos = Ipos - 1
      endif
      if (Ipos.eq.0) return
      Ipos = INDEX (Path (1:Ipos), CSL, .TRUE.)
      if (Ipos.eq.0) return
      lsep = len_trim (CSEP)
      W    = Path (Ipos + 1:lp)
      Path (Ipos:Ipos + lsep - 1) = CSEP (1:lsep)
      Path (Ipos + lsep:lp + lsep) = W
CC TO DO: DPBWXP re-implementaion
      if (iErr.eq.0)
     $     call DPBwxp (iErr, Path, jCls, DS, SD, 0, DI, ID, 0)
c
      RETURN
      END
#endif
CCC_* DPS: standard templates regstration
CCC_ & DPSfmF  ## Development/Path/Standards F family
      subroutine DPSfmF (iErr, DTMPL, icDef)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, character) DTMPL*(*)
      _INTENT(IN, integer)   icDef
CCC_  - Body
      iErr = 0
      if (iErr.eq.0)
     $     call DPBpsG (iErr,  'F0', ' ', '%[DIR]%/%[BASE]')
c
      if (DTMPL.eq.' ') then
         if (iErr.eq.0)
     $        call DPBpsC (iErr, 'FILE', 'F', '%[F0]', icDef)
      else
         if (iErr.eq.0)
     $        call DPBpsC (iErr, 'FILE', 'F', DTMPL,   icDef)
      endif
c
      RETURN
      END
CCC_ & DPSfmD  ## Development/Path/Standards D family
      subroutine DPSfmD (iErr, DFMT, icDef)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, character) DFMT*(*)
      _INTENT(IN, integer)   icDef
CCC_  - Body
      iErr = 0
      if (iErr.eq.0)
     $     call DPBpsG (iErr,  'D0', ' ', '%[TOP]%(%/:%[SUB])')
c
      if (DFMT.eq.' ') then
         if (iErr.eq.0)
     $        call DPBpsC (iErr, 'DIR', 'D', '%[D0]', icDef)
      else
         if (iErr.eq.0)
     $        call DPBpsC (iErr, 'DIR', 'D', DFMT,    icDef)
      endif
c
      RETURN
      END
CCC_ & DPSfmT  ## Development/Path/Standards T family
      subroutine DPSfmT (iErr, DFMT, TOP, icDef)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, character) DFMT*(*)
      _INTENT(IN, character) TOP*(*)
      _INTENT(IN, integer)   icDef
CCC_  - Body
      iErr = 0
      if (iErr.eq.0)
     $     call DPBpsG (iErr,  'T0', ' ', '.')
      if (iErr.eq.0) then
         if (TOP.ne.' ') then
            call DPBpsG (iErr,  'T1', ' ', TOP)
         else
            call DPBpsG (iErr,  'T1', ' ', '%[T0]')
         endif
      endif
c
      if (DFMT.eq.' ') then
         if (iErr.eq.0)
     $        call DPBpsC (iErr, 'TOP', 'T', '%[T0]', icDef)
      else
         if (iErr.eq.0)
     $        call DPBpsC (iErr, 'TOP', 'T', DFMT,    icDef)
      endif
c
      RETURN
      END
CCC_ & DPSfmS  ## Development/Path/Standards S family
      subroutine DPSfmS (iErr, DFMT, icDef)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, character) DFMT*(*)
      _INTENT(IN, integer)   icDef
CCC_  - Body
      iErr = 0
      if (iErr.eq.0)
     $     call DPBpsG (iErr,  'S0', ' ', '%1[CLASS]')
      if (iErr.eq.0)
     $     call DPBpsG (iErr,  'S1', ' ', '%[EXE]%[RUN]%/%[S0]')
      if (iErr.eq.0)
     $     call DPBpsG (iErr,  'S2', ' ', '%[EXE]%(%/:%[RUN])%/%[S0]')
      if (iErr.eq.0)
     $     call DPBpsG (iErr,  'S3', ' ', '%[RUN]%/%[S0]')
c
      if (DFMT.eq.' ') then
         if (iErr.eq.0)
     $        call DPBpsC (iErr, 'SUB', 'S', '%[S0]', icDef)
      else
         if (iErr.eq.0)
     $        call DPBpsC (iErr, 'SUB', 'S', DFMT,    icDef)
      endif
c
      RETURN
      END
CCC_ & DPSfmB  ## Development/Path/Standards B family
      subroutine DPSfmB (iErr, DFMT, icDef)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, character) DFMT*(*)
      _INTENT(IN, integer)   icDef
CCC_  - Body
      iErr = 0
      if (iErr.eq.0)
     $     call DPBpsG (iErr,  'B0', ' ', '%[PFX]%[ROOT]%[EXT]')
c
      if (DFMT.eq.' ') then
         if (iErr.eq.0)
     $        call DPBpsC (iErr, 'BASE', 'B', '%[B0]', icDef)
      else
         if (iErr.eq.0)
     $        call DPBpsC (iErr, 'BASE', 'B', DFMT,    icDef)
      endif
c
      RETURN
      END
CCC_ & DPSfmP  ## Development/Path/Standards P family
      subroutine DPSfmP (iErr, DFMT, icDef)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, character) DFMT*(*)
      _INTENT(IN, integer)   icDef
CCC_  - Body
      iErr = 0
      if (iErr.eq.0)
     $     call DPBpsG (iErr,  'P0', ' ', '%!')
c
      if (DFMT.eq.' ') then
         if (iErr.eq.0)
     $        call DPBpsC (iErr, 'PFX', 'P', '%[P0]', icDef)
      else
         if (iErr.eq.0)
     $        call DPBpsC (iErr, 'PFX', 'P', DFMT,    icDef)
      endif
c
      RETURN
      END
CCC_ & DPSfmX  ## Development/Path/Standards X family
      subroutine DPSfmX (iErr, DFMT, icDef)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, character) DFMT*(*)
      _INTENT(IN, integer)   icDef
CCC_  - Body
      iErr = 0
      if (iErr.eq.0)
     $     call DPBpsG (iErr,  'X0', ' ', '%(%[.]:%[I0]%(%_:%[N0]))')
c
      if (DFMT.eq.' ') then
         if (iErr.eq.0)
     $        call DPBpsC (iErr, 'EXT', 'X', '%[X0]', icDef)
      else
         if (iErr.eq.0)
     $        call DPBpsC (iErr, 'EXT', 'X', DFMT,    icDef)
      endif
c
      RETURN
      END
CCC_ & DPSfmR  ## Development/Path/Standards R family
      subroutine DPSfmR (iErr, DFMT, icDef)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, character) DFMT*(*)
      _INTENT(IN, integer)   icDef
CCC_  - Body
      iErr = 0
      if (iErr.eq.0)
     $     call DPBpsG (iErr,  'R0', ' ', '%[ITEM]')
      if (iErr.eq.0)
     $     call DPBpsG (iErr,  'R1', ' ', '%(:%[CATEGORY]:%[.])%[ITEM]')
c
      if (DFMT.eq.' ') then
         if (iErr.eq.0)
     $        call DPBpsC (iErr, 'ROOT', 'R', '%[R0]', icDef)
      else
         if (iErr.eq.0)
     $        call DPBpsC (iErr, 'ROOT', 'R', DFMT,    icDef)
      endif
c
      RETURN
      END
CCC_ & DPSfmN  ## Development/Path/Standards N,I families
      subroutine DPSfmN (iErr)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
CCC_  - Body
      iErr = 0
      if (iErr.eq.0)
     $     call DPBpsG (iErr,  'N0', ' ', '%03[NRW]')
      if (iErr.eq.0)
     $     call DPBpsG (iErr,  'I0', ' ', '%03[IRW]')
c
      RETURN
      END
CCC_ & DPSmsc  ## Development/Path/Standards misc families
      subroutine DPSmsc (iErr)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer) iErr
CCC_  - Body
      iErr = 0
      if (iErr.eq.0) call DPBpaG (iErr, 'CLASS', 'C')
c$$$      if (iErr.eq.0) call DPBpaG (iErr, 'VAR',   'V')
      RETURN
      END
CCC_ & DPSgex  ## Development/Path/Standards executable info
      subroutine DPSgex (iErr, EXE, KEXE)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, character) EXE*(*)
      _INTENT(IN, integer)   KEXE
      integer js, je, j, jj
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
CCC_  - Body
      iErr = 0
      js = 1
      je = len_trim (EXE)
      jj = 0
      do j = je, 1, -1
         if (EXE (j:j).eq.'.') then
            jj = j
            goto 100
         endif
      enddo
 100  continue
      if (jj.gt.1) je = jj - 1
      jj = 0
      do j = je, 1, -1
         if (EXE (j:j).eq.'/') then
            jj = j
            goto 200
         endif
      enddo
 200  continue
      if (jj.gt.0) js = jj + 1
c
      if (iErr.eq.0) call DPBpsG (iErr, 'EXEB', ' ', EXE (js:je))
      if (iErr.eq.0.and.KEXE.ge.0) then
         call DPBpiG (iErr, 'EXEV', ' ', KEXE)
      endif
      if (iErr.eq.0) then
         call DPBpsG (iErr, 'EXE', ' ', '%[EXEB]%[EXEV]')
      endif
      RETURN
      END
CCC_* DPB: Buffer management
CCC_ & DPBmng  ## Development/Path/Buffer management
      subroutine DPBmng ()
CCC_  - Declaration
      implicit none
CCC_   = Parameter
CCC_    * Value length
      integer    LvalG, LvalC, LvalE
      parameter (LvalG  = OPT_DPATHN_GVALUE_LEN)
      parameter (LvalC  = OPT_DPATHN_CVALUE_LEN)
      parameter (LvalE  = OPT_DPATHN_EVALUE_LEN)
CCC_    * Tag length
      integer    LtagG, LtagC, LtagE
      parameter (LtagG  = OPT_DPATHN_GTAG_LEN)
      parameter (LtagC  = OPT_DPATHN_CTAG_LEN)
      parameter (LtagE  = OPT_DPATHN_ETAG_LEN)
CCC_    * Array size
CCC_     + tag
      integer    MtagSG, MtagSC, MtagSE
      parameter (MtagSG = OPT_DPATHN_GLOBAL_MAX)
      parameter (MtagSC = OPT_DPATHN_COMMON_MAX)
      parameter (MtagSE = OPT_DPATHN_EACH_MAX)
CCC_     + class
      integer    MaxCls
      parameter (MaxCls = OPT_DPATHN_CLASS_MAX)
CCC_     + value
      integer    MvalSC, MvalSE
      parameter (MvalSC = (MaxCls + 1) * MTagSC)
      parameter (MvalSE = (MaxCls + 0) * MTagSE)
CCC_    * Array index special
      integer    ivCls
      parameter (ivCls = 1)
CCC_   = Save
CCC_    * Global
      character TagSG (MtagSG) * (LtagG)
      data      TagSG /MtagSG  * ' '/
      character ValG  (MtagSG) * (LvalG)
      data      ValG  /MtagSG  * ' '/
      save      TagSG, ValG
c
      integer   ITSG, NTSG
      data      ITSG, NTSG  /0, 0/
      save      ITSG, NTSG
CCC_    * Common
      character TagSC (MtagSC) * (LtagC)
      data      TagSC /MtagSC  * ' '/
      character ValC  (MtagSC, 0:MaxCls) * (LvalC)
      data      ValC  /MvalSC  * ' '/
      save      TagSC, ValC
c
      integer   ITSC, NTSC
      data      ITSC, NTSC /0, 0/
      save      ITSC, NTSC
CCC_    * Each
      character TagSE (MtagSE, 1:MaxCls) * (LtagE)
      data      TagSE /MvalSE  * ' '/
      character ValE  (MtagSE, 1:MaxCls) * (LvalE)
      data      ValE  /MvalSE  * ' '/
      save      TagSE, ValE
c
      integer   ITSE (MaxCls), NTSE (MaxCls)
      data      ITSE, NTSE /MaxCls * 0, MaxCls * 0/
      save      ITSE, NTSE
CCC_    * Class
      integer    Icls, Ncls
      data       Icls, Ncls /0, 0/
      save       Icls, Ncls
CCC_   = Arguments
      _INTENT(OUT,  integer)   iErr
      _INTENT(OUT,  integer)   ICO
      _INTENT(OUT,  character) VO*(*)
      _INTENT(IN,   integer)   IC
      _INTENT(IN,   integer)   IFP
      _INTENT(IN,   character) T*(*), V*(*), A*(*)
      _INTENT(IN,   character) C*(*)
      _INTENT(IN,   integer)   IV
c$$$      _INTENT(INOUT,character) P*(*)
      _INTENT(IN,   character) COP*(*)
CCC_    * One-time Tag/Value arrays
      _INTENT(IN,   integer)   LSO
      _INTENT(INOUT,character) TSO (LSO)*(*)
      _INTENT(INOUT,character) SVO (LSO)*(*)
      _INTENT(INOUT,integer)   ISO
#if 0
CCC_    * Optional Tag/Value arrays
      _INTENT(IN,   character) TSopt (*)*(*), TIopt (*)*(*)
      _INTENT(IN,   character) SVopt (*)*(*)
      _INTENT(IN,   integer)   IVopt (*)
      _INTENT(IN,   integer)   MSopt, MIopt
#endif /* 0 */
CCC_   = Interior
      integer   jc
      character TmpC*(LvalC)
c$$$      character W1*(OPT_FILENAME_MAX), W2*(OPT_FILENAME_MAX)
      integer   l
c$$$      integer   Lsum, Lstg
c$$$      integer   LimL
c$$$      logical   OKU
CCC_  - Body (DPBmng)
      TagSC (ivCls) = 'CLASS'
      ITSC = ivCls
      NTSC = MAX (ITSC, NTSC)
      RETURN
CCC_  & DPBcpy  ## Development/Path/Buffer copy configuration
      entry DPBcpy
     O    (iErr,
     M     TSO, SVO, ISO, LSO,
     I     IC)
c
      if (iErr.eq.0) then
         call UtmpCS
     $       (iErr, ISO,       TSO,           SVO,
     $        LSO,  NTSE (IC), TagSE (1, IC), ValE (1, IC))
      endif
      if (iErr.eq.0) then
         call UtmpCS
     $       (iErr, ISO,       TSO,           SVO,
     $        LSO,  NTSC,      TagSC,         ValC (1, IC))
      endif
      if (iErr.eq.0) then
         call UtmpCS
     $       (iErr, ISO,       TSO,           SVO,
     $        LSO,  NTSG,      TagSG,         ValG)
      endif
c
      RETURN
#if 0
CCC_  & DPBwxp  ## Development/Path/Buffer expansion
      entry DPBwxp
     O    (iErr,
     M     P,
     I     IC,
     I     TSopt, SVopt, MSopt, TIopt, IVopt, MIopt)
CCC_   . Description
CC       Expand and modify P for class index IC
CCC_   . initialization
      iErr = 0
      LimL = 16
      OKU  = .true.
      do l = 0, LimL
         Lsum = 0
CCC_   . optional
         W1 = P
         call UtmpWX
     O       (Lstg, P,
     W        W2,
     I        W1,
     I        SVopt, TSopt, MSopt,
     I        IVopt, TIopt, MIopt, OKU)
         Lsum = Lsum + Lstg
CCC_   . common
         W1 = P
         call UtmpWX
     O       (Lstg, P,
     W        W2,
     I        W1,
     I        ValC  (1, IC), TagSC, NTSC,
     I        IvalC (1, IC), TagIC, NTIC, OKU)
         Lsum = Lsum + Lstg
CCC_   . each
         W1 = P
         call UtmpWX
     O       (Lstg, P,
     W        W2,
     I        W1,
     I        ValE  (1, IC), TagSE (1, IC), NTSE (IC),
     I        IvalE (1, IC), TagIE (1, IC), NTIE (IC), OKU)
         Lsum = Lsum + Lstg
CCC_   . global
         W1 = P
         call UtmpWX
     O       (Lstg, P,
     W        W2,
     I        W1,
     I        ValG,  TagSG, NTSG,
     I        IvalG, TagIG, NTIG, OKU)
         Lsum = Lsum + Lstg
         if (Lsum.eq.0) goto 100
      enddo
 100  continue
      W1  = P
      OKU = .false.
      call UtmpWX
     O    (Lstg, P,
     W     W2,
     I     W1,
     I     ValC  (1, IC), TagSC, NTSC,
     I     IvalC (1, IC), TagIC, NTIC, OKU)
CCC_   . final
      return
#endif /* 0 */
CCC_  & DPBrep  ## Development/Path/Buffer report
      entry DPBrep (IFP)
 309  format LOGFMT_INM
      if (COND_N(IFP)) then
         write (IFP, 309)
     $        ITEMS_INM(iCls,nCls,MaxCls,'DPBREP/C')
      else if (COND_S(IFP)) then
         write (*,   309)
     $        ITEMS_INM(iCls,nCls,MaxCls,'DPBREP/C')
      endif
      call DPBIrp
     $    (IFP,   'G',   0,    ' ',
     $     MtagSG, ITSG, NTSG, TagSG, ValG)
      do jc = 0, Ncls
         TmpC = ValC (ivCls, jc)
         call DPBIrp
     $       (IFP,   'C',   jc,   TmpC,
     $        MtagSC, ITSC, NTSC, TagSC, ValC (1, jc))
      enddo
      do jc = 1, Ncls
         TmpC = ValC (ivCls, jc)
         call DPBIrp
     $       (IFP,   'E',        jc,        TmpC,
     $        MtagSE, ITSE (jc), NTSE (jc), TagSE (1, jc),ValE (1, jc))
      enddo
      RETURN
CCC_  & DPBpsG  ## Development/Path/Buffer put string [G]
      entry DPBpsG (iErr, T, A, V)
CC        Set global tag T and its alias A to value V (string)
      iErr = 0
      if (A .eq. ' ') then
         call UtmpHS
     O       (iErr,
     M        ITSG,   TagSG, ValG,
     I        MtagSG, T,     V,    'REPLACE')
      else
         call UtmpAS
     O       (iErr,
     M        ITSG,   TagSG, ValG,
     I        MtagSG, T,     A, V, 'REPLACE')
      endif
      NTSG = MIN (ITSG, MtagSG)
      RETURN
CCC_  & DPBpiG  ## Development/Path/Buffer put integer [G]
      entry DPBpiG (iErr, T, A, IV)
CC        Set global tag T and its alias A to value IV (integer)
      iErr = 0
      if (A. eq. ' ') then
         call UtmpHI
     O       (iErr,
     M        ITSG,   TagSG, ValG,
     I        MTagSG, T,     IV,    'REPLACE')
      else
         call UtmpAI
     O       (iErr,
     M        ITSG,          TagSG,   ValG,
     I        MTagSG, T, A,  IV,    'REPLACE')
      endif
      NTSG = MIN (ITSG, MtagSG)
      RETURN
CCC_  & DPBpaG  ## Development/Path/Buffer put alias [G]
      entry DPBpaG (iErr, T, A)
CC        Set global tag T and its alias
      iErr = 0
      if (A .ne. ' ') then
         call UtmpAL
     O       (iErr,
     M        ITSG,    TagSG,   ValG,
     I        MTagSG,  T,       A,    'REPLACE')
      endif
      NTSG = MIN (ITSG, MtagSG)
      return
CCC_  & DPBrgC  ## Development/Path/Buffer class registration
      entry DPBrgC (iErr, ICO, C)
CC        register class C and return its index ICO
      iErr = 0
      ICO = 0
      if (C .eq. ' ') then
         continue
      else
         do jc = 1, Ncls
            if (ValC (ivCls, jc) .eq. C) ICO = JC
         enddo
         if (ICO.eq.0) then
            Icls = Icls + 1
            Ncls = MIN (MaxCls, Icls)
            if (Icls.gt.MaxCls) then
               ICO  = -1
               iErr = _ERR_CLASS_OVERFLOW
            else
               ICO = Icls
               ValC (ivCls, ICO) = C
               iErr = _ERR_CLASS_NEW
            endif
         endif
      endif
      RETURN
CCC_  & DPBrsC  ## Development/Path/Buffer reset [C]
      entry DPBrsC (iErr, COP, IC)
      iErr = 0
      if (IC.eq.0) return
      if (COP.eq.' ') then
         do l = 1, ivCls - 1
            ValC (l, IC)  = ValC  (l, 0)
         enddo
         do l = ivCls + 1, MtagSC
            ValC (l, IC)  = ValC  (l, 0)
         enddo
      endif
      RETURN
CCC_  & DPBgsC  ## Development/Path/Buffer get string [C]
      entry DPBgsC (iErr, T, VO, IC)
      iErr = 0
      call UtmpHS
     O    (iErr,
     M     ITSC,   TagSC, ValC (1, IC),
     I     MtagSC, T,     ' ',            'SEARCH')
      if (iErr.eq.0) then
         VO = ' '
      else
         VO = ValC (iErr, IC)
         iErr = 0
      endif
      RETURN
CCC_  & DPBpsC  ## Development/Path/Buffer put string [C]
      entry DPBpsC (iErr, T, A, V, IC)
      iErr = 0
      call UtmpHS
     O    (iErr,
     M     ITSC,   TagSC, ValC (1, IC),
     I     MtagSC, T,     V,            'REPLACE')
      if (iErr.eq.0) then
         call UtmpAL
     O       (iErr,
     M        ITSG,   TagSG, ValG,
     I        MtagSG, T,     A,    'REPLACE')
         NTSG = MIN (ITSG, MtagSG)
      endif
      NTSC = MIN (ITSC, MtagSC)
      RETURN
CCC_  & DPBpiC  ## Development/Path/Buffer put integer [C]
      entry DPBpiC (iErr, T, A, IV, IC)
      iErr = 0
      call UtmpHI
     O    (iErr,
     M     ITSC,   TagSC, ValC (1, IC),
     I     MTagSC, T,     IV,           'REPLACE')
CCC_   . Caution: alias is on GLOBAL
      if (iErr.eq.0) then
         call UtmpAL
     O       (iErr,
     M        ITSG,   TagSG, ValG,
     I        MtagSG, T,     A,    'REPLACE')
         NTSG = MIN (ITSG, MtagSG)
      endif
      NTSC = MIN (ITSC, MtagSC)
      RETURN
CCC_  & DPBpaC  ## Development/Path/Buffer put alias [C]
      entry DPBpaC (iErr, T, A, IC)
      iErr = 0
CCC_   . Caution: alias is on COMMON
      if (A .ne. ' ') then
         call UtmpAL
     O       (iErr,
     M        ITSC,   TagSC, ValC (1, IC),
     I        MtagSC, T,     A,    'REPLACE')
         NTSC = MIN (ITSC, MtagSC)
      endif
      RETURN
CCC_  & DPBpsE  ## Development/Path/Buffer put string [E]
      entry DPBpsE (iErr, T, A, V, IC)
      iErr = 0
      if (A .eq. ' ') then
         call UtmpHS
     O       (iErr,
     M        ITSE (IC), TagSE (1, IC), ValE (1, IC),
     I        MtagSE,    T,             V,            'REPLACE')
      else
         call UtmpAS
     O       (iErr,
     M        ITSE (IC), TagSE (1, IC), ValE (1, IC),
     I        MtagSE,    T,             A, V,         'REPLACE')
      endif
      NTSE (IC) = MIN (ITSE (IC), MtagSE)
      RETURN
CCC_  & DPBpiE  ## Development/Path/Buffer put integer [E]
      entry DPBpiE (iErr, T, A, IV, IC)
      iErr = 0
      if (A. eq. ' ') then
         call UtmpHI
     O       (iErr,
     M        ITSE (IC), TagSE (1, IC), ValE (1, IC),
     I        MTagSE,    T,             IV,           'REPLACE')
      else
         call UtmpAI
     O       (iErr,
     M        ITSE (IC),      TagSE (1, IC), ValE  (1, IC),
     I        MTagSE,     T, A,         IV,            'REPLACE')
      endif
      NTSE (IC) = MIN (ITSE (IC), MtagSE)
      RETURN
CCC_   . End (DPBmng)
      END
CCC_ & DPBIrp  ## Development/Path/Buffer report (interior)
      subroutine DPBIrp
     $    (IFP,   CK,   IC,   C,
     $     MS,    IS,   NS,   TS,   SV)
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(IN, integer)   IFP
      _INTENT(IN, character) CK*(*)
      _INTENT(IN, integer)   IC
      _INTENT(IN, character) C*(*)
      _INTENT(IN, integer)   MS, IS, NS
      _INTENT(IN, character) TS (*)*(*)
      _INTENT(IN, character) SV (*)*(*)
CCC_   = Interior
      integer   j
      character Tag*(32)
      integer   ltck, ltc
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
CCC_  - Body
 309  format LOGFMT_INM
 308  format ('DPBMNG/', A, I4.4, A)
      if (HAVE_F77_TRIM.eq.0) then
         ltck = len_trim (CK)
         ltc  = len_trim (C)
         write (Tag, 308) CK(1:ltck), IC, C(1:ltc)
      else
         write (Tag, 308) _TRIM(CK), IC, _TRIM(C)
      endif
      if (COND_N(IFP)) then
         write (IFP, 309)
     $        ITEMS_INM(IS,NS,MS,_TRIM(Tag))
      else if (COND_S(IFP)) then
         write (*,   309)
     $        ITEMS_INM(IS,NS,MS,_TRIM(Tag))
      endif
 101  format ('DPBMNG report [', A, I3, ':', A, '] ', 2I4)
 109  format ('DPBMNG report [', A, '] DONE')
 201  format ('S', I3, 1x, A, T20, A)
      if (COND_N(IFP)) then
         write (IFP, 101) CK, IC, _TRIM(C), IS, NS
         do j = 1, NS
            write (IFP, 201) j, _TRIM(TS (j)),
     $           _TRIML(SV (j))
         enddo
         write (IFP, 109) CK
      else if (COND_S(IFP)) then
         write (*, 101) CK, IC, _TRIM(C), IS, NS
         do j = 1, NS
            write (*, 201) j, _TRIM(TS (j)),
     $           _TRIML(SV (j))
         enddo
         write (*, 109) CK
      endif
      RETURN
      END
CCC_* DPC: Class-dependent buffer (common)
CCC_ & DPCciC  ## Development/Path/Common Configure [C] suite
      subroutine DPCciC
     O    (iErr,
     I     ipI,  ipO,  ipE,  IC, C, DROOT, DTMPL)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   ipI,  ipO,  ipE
      _INTENT(IN, integer)   IC
      _INTENT(IN, character) C*(*)
      _INTENT(IN, character) DROOT*(*), DTMPL*(*)
CCC_  - Body
      iErr = 0
      if (iErr.eq.0) then
         call DPCbsC (iErr, ipI, ipO, ipE, IC, C, DROOT, DTMPL)
      endif
      if (iErr.eq.0) then
         call DPCtvC (iErr, ipI, ipO, ipE, IC, C)
      endif
      call DATrcU (ipE, iErr, 'R', 'DPCCIC')
      RETURN
      END
CCC_ & DPCbsC  ## Development/Path/Common Configure by basic [C]
      subroutine DPCbsC
     O    (iErr,
     I     ipI,  ipO,  ipE,  IC, C, DROOT, DTMPL)
CCC_  - Description
CC     Read IPI and configure class C templates and expansion,
CC     with default template DTMPL.
CC     DROOT is assigned to /ROOT/ tag.
CCC_  - Declaration
      implicit none
CCC_   = Parameters
      integer    MaxE
      parameter (MaxE = 10)
CCC_   = Arguments
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   ipI,  ipO,  ipE
      _INTENT(IN, integer)   IC
      _INTENT(IN, character) C*(*)
      _INTENT(IN, character) DROOT*(*), DTMPL*(*)
CCC_   = Configuration
      character CLS *(OPT_DPATHN_CLASS_LEN)
      character FILE*(OPT_DPATHN_FORMAT_LEN)
      character DIR *(OPT_FILENAME_MAX)
      character TOP *(OPT_FILENAME_MAX)
      character SUB *(OPT_FILENAME_MAX)
      character BASE*(OPT_FILENAME_MAX)
      character PFX *(OPT_FILENAME_MAX)
      character ROOT*(OPT_FILENAME_MAX)
      character EXT *(OPT_FILENAME_MAX)
      character CUB *(OPT_DPATHN_CVALUE_LEN)
      character CPR *(OPT_DPATHN_CVALUE_LEN)
      integer   IOSR, IE
      namelist /NIDPCL/
     $     IOSR, IE,
     $     CLS,
     $     FILE, DIR, TOP, SUB, BASE, PFX, ROOT, EXT,
     $     CUB,  CPR
      integer    LVEML
      parameter (LVEML = OPT_NAMELIST_OUTPUT_EMULATION)
CCC_   = Interior
      integer IOS
      integer jErrC
      logical OEOF
CCC_  - Body
      iErr = 0
      call UUrwnd (IOS,  ipI)
      jErrC = 0
CC    Limited loop (MaxE)
      DO
         IE   = 0
         IOSR = 0
         CLS  = ' '
c
         FILE = DTMPL
         DIR  = ' '
         TOP  = ' '
         SUB  = ' '
         BASE = ' '
         PFX  = ' '
         ROOT = DROOT
         EXT  = ' '
         CUB  = '_'
         CPR  = '.'
         if (IOS .eq. 0) then
            if (ipI.ge.0) then
               read (ipI, NIDPCL, IOSTAT = IOS)
            else
               read (*,   NIDPCL, IOSTAT = IOS)
            endif
         endif
         if (IOS.eq.0) then
            if (CLS.eq.C) goto 900
         else
            call UUieof (OEOF, IOS)
            if (OEOF) goto 900
            jErrC = jErrC + 1
            if (jErrC.gt.MaxE) goto 900
         endif
      ENDDO
 900  continue
c
      if (iErr.eq.0 .and. FILE.ne.' ')
     $     call DPBpsC (iErr, 'FILE',   ' ',  FILE, IC)
      if (iErr.eq.0 .and. DIR.ne.' ')
     $     call DPBpsC (iErr, 'DIR',    ' ',  DIR,  IC)
      if (iErr.eq.0 .and. TOP.ne.' ')
     $     call DPBpsC (iErr, 'TOP',    ' ',  TOP,  IC)
      if (iErr.eq.0 .and. SUB.ne.' ')
     $     call DPBpsC (iErr, 'SUB',    ' ',  SUB,  IC)
      if (iErr.eq.0 .and. BASE.ne.' ')
     $     call DPBpsC (iErr, 'BASE',   ' ',  BASE, IC)
      if (iErr.eq.0 .and. PFX.ne.' ')
     $     call DPBpsC (iErr, 'PFX',    ' ',  PFX,  IC)
      if (iErr.eq.0 .and. ROOT.ne.' ')
     $     call DPBpsC (iErr, 'ROOT',    ' ', ROOT, IC)
      if (iErr.eq.0 .and. EXT.ne.' ')
     $     call DPBpsC (iErr, 'EXT',    ' ',  EXT,  IC)
c
      if (iErr.eq.0 .and. CUB.ne.' ')
     $     call DPBpsC (iErr, '_', ' ',   CUB,  IC)
      if (iErr.eq.0 .and. CPR.ne.' ')
     $     call DPBpsC (iErr, '.', ' ',   CPR,  IC)
c
      IOSR = IOS
      CLS  = C
      if (LVEML.gt.0) then
         call UNBbgn (iErr, 'NIDPCL',       ipO, LVEML)
         call UNBint (iErr, 'IOSR',  IOSR,  ipO, LVEML)
         call UNBint (iErr, 'IE',    IE,    ipO, LVEML)
         call UNBstr (iErr, 'CLS',   CLS,   ipO, LVEML)
         call UNBstr (iErr, 'FILE',  FILE,  ipO, LVEML)
         call UNBstr (iErr, 'DIR',   DIR,   ipO, LVEML)
         call UNBstr (iErr, 'TOP',   TOP,   ipO, LVEML)
         call UNBstr (iErr, 'SUB',   SUB,   ipO, LVEML)
         call UNBstr (iErr, 'BASE',  BASE,  ipO, LVEML)
         call UNBstr (iErr, 'PFX',   PFX,   ipO, LVEML)
         call UNBstr (iErr, 'ROOT',  ROOT,  ipO, LVEML)
         call UNBstr (iErr, 'EXT',   EXT,   ipO, LVEML)
         call UNBstr (iErr, 'CUB',   CUB,   ipO, LVEML)
         call UNBstr (iErr, 'CPR',   CPR,   ipO, LVEML)
         call UNBend (iErr, 'NIDPCL',       ipO, LVEML)
      else
         if (COND_N(ipO)) then
            write (ipO, NIDPCL)
         else if (COND_S(ipO)) then
            write (*,   NIDPCL)
         endif
      endif
      call DATrcU (ipE, iErr, 'R', 'DPCBSC')
      RETURN
      END
CCC_ & DPCtvC  ## Development/Path/Common Configure by Tag-Value [C]
      subroutine DPCtvC
     O    (iErr,
     I     ipI,  ipO,  ipE,  IC, C)
CCC_  - Declaration
      implicit none
CCC_   = Parameters
      integer    MaxE
      parameter (MaxE = 10)
CCC_   = Arguments
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   ipI,  ipO,  ipE
      _INTENT(IN, integer)   IC
      _INTENT(IN, character) C*(*)
CCC_   = Configuration
      character CLS   *(OPT_DPATHN_CLASS_LEN)
      character TAG   *(OPT_FILENAME_MAX)
      character VALUE *(OPT_FILENAME_MAX)
      integer   IOSR, IE
      namelist /NIDPTV/ IOSR, IE,  CLS,  TAG, VALUE
      integer    LVEML
      parameter (LVEML = _UNMLEM_LEVEL_END)
CCC_   = Interior
      integer IOS
      integer jErrC
      logical OEOF
CCC_  - Body
      iErr = 0
      call UUrwnd (IOS,  ipI)
      jErrC = 0
CC    Limited loop (MaxE)
      DO
         IE   = 0
         IOSR = 0
         CLS  = ' '
c
         TAG   = ' '
         VALUE = ' '
         if (IOS .eq. 0) then
            if (ipI.ge.0) then
               read (ipI, NIDPTV, IOSTAT = IOS)
            else
               read (*,   NIDPTV, IOSTAT = IOS)
            endif
         endif
         if (IOS.eq.0) then
            if (CLS.eq.C) then
               IOSR = IOS
               CLS  = C
               if (LVEML.gt.0) then
                  call UNBbgn (iErr, 'NIDPTV',       ipO, LVEML)
                  call UNBint (iErr, 'IOSR',  IOSR,  ipO, LVEML)
                  call UNBint (iErr, 'IE',    IE,    ipO, LVEML)
                  call UNBstr (iErr, 'CLS',   CLS,   ipO, LVEML)
                  call UNBstr (iErr, 'TAG',   TAG,   ipO, LVEML)
                  call UNBstr (iErr, 'VALUE', VALUE, ipO, LVEML)
                  call UNBend (iErr, 'NIDPTV',       ipO, LVEML)
               else if (COND_N(ipO)) then
                  write (ipO, NIDPTV)
               else if (COND_S(ipO)) then
                  write (*,   NIDPTV)
               endif
               call DPBpsC (iErr, TAG, ' ',  VALUE, IC)
               if (iErr.ne.0) goto 900
            endif
         else
            call UUieof (OEOF, IOS)
            if (OEOF) goto 900
            jErrC = jErrC + 1
            if (jErrC.gt.MaxE) goto 900
         endif
      ENDDO
 900  continue
      call DATrcU (ipE, iErr, 'R', 'DPCTVC')
      RETURN
      END
CCC_& DPATHN  ## Development/Path announcment
      subroutine DPATHN (STRA, STRB, IOP)
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
         STRA = 'OPT_DPATHN_EVALUE_LEN'
         write (STRB, *) OPT_DPATHN_EVALUE_LEN
      else if (IOP.eq.4) then
         STRA = 'OPT_DPATHN_VALUE_LEN'
         write (STRB, *) OPT_DPATHN_VALUE_LEN
      else if (IOP.eq.5) then
         STRA = 'OPT_DPATHN_TAG_MAX'
         write (STRB, *) OPT_DPATHN_TAG_MAX
      else if (IOP.eq.6) then
         STRA = 'OPT_DPATHN_CTAG_LEN'
         write (STRB, *) OPT_DPATHN_CTAG_LEN
      else if (IOP.eq.7) then
         STRA = 'OPT_DPATHN_COMMON_MAX'
         write (STRB, *) OPT_DPATHN_COMMON_MAX
      else if (IOP.eq.8) then
         STRA = 'OPT_DPATHN_GVALUE_LEN'
         write (STRB, *) OPT_DPATHN_GVALUE_LEN
      else if (IOP.eq.9) then
         STRA = 'OPT_DPATHN_CLASS_LEN'
         write (STRB, *) OPT_DPATHN_CLASS_LEN
      else if (IOP.eq.10) then
         STRA = 'PATH_SEPARATOR'
         write (STRB, *) PATH_SEPARATOR
      else if (IOP.eq.11) then
         STRA = 'OPT_DPATHN_EACH_MAX'
         write (STRB, *) OPT_DPATHN_EACH_MAX
      else if (IOP.eq.12) then
         STRA = 'OPT_DPATHN_GLOBAL_MAX'
         write (STRB, *) OPT_DPATHN_GLOBAL_MAX
      else if (IOP.eq.13) then
         STRA = 'OPT_DPATHN_FORMAT_LEN'
         write (STRB, *) OPT_DPATHN_FORMAT_LEN
      else if (IOP.eq.14) then
         STRA = 'OPT_DPATHN_CLASS_MAX'
         write (STRB, *) OPT_DPATHN_CLASS_MAX
      else if (IOP.eq.15) then
         STRA = 'OPT_DPATHN_GTAG_LEN'
         write (STRB, *) OPT_DPATHN_GTAG_LEN
      else if (IOP.eq.16) then
         STRA = 'OPT_DPATHN_TAG_LEN'
         write (STRB, *) OPT_DPATHN_TAG_LEN
      else if (IOP.eq.17) then
         STRA = 'OPT_DPATHN_CVALUE_LEN'
         write (STRB, *) OPT_DPATHN_CVALUE_LEN
      else if (IOP.eq.18) then
         STRA = 'OPT_DPATHN_ETAG_LEN'
         write (STRB, *) OPT_DPATHN_ETAG_LEN
      else
         STRA = ' '
         STRB = ' '
      endif
      RETURN
      END
CCC_* Test
CCC_ + begin
#if TEST_DPATHN
CCC_ @ DPtest  ## DPATHN test
      program DPTEST
CCC_  - Test suites
CC::   SOURCES dbstrp.F danntr.F
CCC_  - Declaration
      implicit none
      integer   Ierr
      integer   ibsA (_MAX_BOOTSTRAP_UNITS)
      integer   ipI, ipO, ipE
      integer   jcl
      character C*(32)
      character Path*(OPT_FILENAME_MAX)
#define _REPLACEMENT_TEST 0 /* Replacement temporary disabled */
#if _REPLACEMENT_TEST
      integer   Ipos
#endif
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
#include "orevan.h" /* 0 */
CCC_  - Body
#define _ANNOUNCE DPATHN
#define _LEXT 9999
#include "orevan.h" /* 1 */
      call DBmngr
     O     (iErr, ibsA)
      ipI = BOOTSTRAP_IN(ibsA)
      ipO = BOOTSTRAP_OUT(ibsA)
      ipE = BOOTSTRAP_ERR(ibsA)
      write (*, *) 'BOOTSTRAP', ibsA
c
      call DPinit
     $     (iErr, ' ', ' ', _FNAME, TEST_DPATHN)
c$$$      call DPUini (iErr, ' ')
c
      call DPBpsG (iErr, 'G0', ' ',   'Val G0')
      call DPBpsG (iErr, 'G1', 'AG1', 'Val G1')
      call DPBpsG (iErr, 'G2', 'AG2', 'Val G2')
      call DPBpsG (iErr, 'G2', ' ',   'Val G2 new')
c
      call DPBpiG (iErr, 'g0', ' ',   999)
      call DPBpiG (iErr, 'g1', 'ag1', 888)
      call DPBpiG (iErr, 'g1', ' ',   -888)
c
      call DPBrgC (iErr, jcl, ' ')
      call DPBpsC (iErr, 'C0', ' ',    'Val C0', jcl)
      call DPBpsC (iErr, 'C1', 'AC1',  'Val C1', jcl)
      call DPBpiC (iErr, 'c0', ' ',    123, jcl)
      call DPBpiC (iErr, 'c1', 'ac1',  456, jcl)
c
      call DPBrgC (iErr, jcl, 'Z')
      call DPBpsC (iErr, 'C0', ' ',    'Val C0:Z', jcl)
      call DPBpsC (iErr, 'C1', 'AC1',  'Val C1:Z', jcl)
c
      call DPBrgC (iErr, jcl, 'Z')
      call DPBpsC (iErr, 'C0', ' ',    'Val C0:Z', jcl)
      call DPBpsC (iErr, 'C1', ' ',    'Val C1:Z', jcl)
      call DPBpiC (iErr, 'c0', ' ',    32, jcl)
      call DPBpiC (iErr, 'c1', ' ',    43, jcl)
c
      call DPBrgC (iErr, jcl, 'Y')
      call DPBpsC (iErr, 'C0', ' ',    'Val C0:Y', jcl)
      call DPBpsC (iErr, 'C1', ' ',    'Val C1:Y', jcl)
      call DPBpiC (iErr, 'c0', ' ',    1, jcl)
      call DPBpiC (iErr, 'c1', ' ',    2, jcl)
c
      call DPBrgC (iErr, jcl, 'Z')
      call DPBpsE (iErr, 'E0', ' ',    'Val E0:Z', jcl)
      call DPBpsE (iErr, 'E1', ' ',    'Val E1:Z', jcl)
      call DPBpiE (iErr, 'e0', ' ',    11, jcl)
      call DPBpiE (iErr, 'e1', ' ',    22, jcl)
c
      call DPBrgC (iErr, jcl, 'Y')
      call DPBpsE (iErr, 'E0Y', ' ',    'Val E0:Y', jcl)
      call DPBpsE (iErr, 'E1', ' ',    'Val E1:Y', jcl)
      call DPBpiE (iErr, 'e0y', ' ',    111, jcl)
      call DPBpiE (iErr, 'e1', ' ',     222, jcl)
c
      call DPUrgs (iErr, ipI, ipO, ipE, 'PPP', ' ', '%[F0]')
      call DPUrgs (iErr, ipI, ipO, ipE, 'QQQ', ' ', '%[F0]')
      call DPUrgs (iErr, ipI, ipO, ipE, 'RRR', ' ', '%[F0]')
c
 101  format ('Expansion <', A, '> [', A, ']')
c
      C = 'PPP'
      Path = ' '
      call DPUpth (iErr, Path, C, 'basename', ipE)
      write (ipO, 101) _TRIM(C), _TRIM(Path)
c
      C = 'QQQ'
      Path = ' '
      call DPUpth (iErr, Path, C, 'b_a_s_e', ipE)
      write (ipO, 101) _TRIM(C), _TRIM(Path)
c
      C = 'RRR'
      Path = ' '
      call DPUpth (iErr, Path, C, 'r--r', ipE)
      write (ipO, 101) _TRIM(C), _TRIM(Path)
c
#if _REPLACEMENT_TEST
      Ipos = -1
 102  format ('Replacement <', I3, '> [', A, ']')
      do
c$$$         call DPUmdC (iErr, Path, Ipos, 0, '/',  '%_')
         call DPUmdf (iErr, Path, Ipos, C)
         if (Ipos.eq.0) goto 90
         write (ipO, 102) Ipos, _TRIM(Path)
      enddo
 90   continue
c
      Ipos = -1
      Path = '/ABC/XYZ/PQR'
      do
c$$$         call DPUmdC (iErr, Path, Ipos, 0, '/',  '_/_')
c$$$         call DPUmdC (iErr, Path, Ipos, 0, '/',  '%_')
         call DPUmdf (iErr, Path, Ipos, C)
         if (Ipos.eq.0) goto 190
         write (ipO, 102) Ipos, _TRIM(Path)
      enddo
 190  continue
#endif /* _REPLACEMENT_TEST */
C
      call DEBrep (ipE)
      call DPBrep (ipE)
      call DBswpW (iErr, -1, -1)
      STOP
      END
CC
CCC_ + end
#endif /* TEST_DPATHN */
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
