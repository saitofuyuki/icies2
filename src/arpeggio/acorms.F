C arpeggio/acorms.F --- Arpeggio/Coordinate (snoopy0.3/0.7 hack)
C Maintainer:  SAITO Fuyuki
C Created: Jan 27 2010
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2020/09/15 11:55:43 fuyuki acorms.F>'
#define _FNAME 'arpeggio/acorms.F'
#define _REV   'Arpeggio 1.0'
CCC_! MANIFESTO
C
C Copyright (C) 2010--2020
C           Japan Agency for Marine-Earth Science and Technology
C
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
CCC_* Common macros
#include "ofdlct.h" /* fortran dialect */
#include "ologfm.h" /* logging */
#include "odevva.h"
#include "ounelv.h" /* namelist emulation levels */
CCC_ + Maximum
#ifndef   OPT_COOR_MAX
#  define OPT_COOR_MAX 300
#endif
#ifndef   OPT_COOR_ATTRD_MAX
c$$$#  define OPT_COOR_ATTRD_MAX 65536
#  define OPT_COOR_ATTRD_MAX 500000
#endif
#ifndef   OPT_COOR_ATTRI_MAX
c$$$#  define OPT_COOR_ATTRI_MAX 65536
#  define OPT_COOR_ATTRI_MAX 500000
#endif
CCC_ + Coordinate kind
#define _KERR   -1
#define _KROOT  0   /* root */
#define _KEXT   1   /* extended */
#define _KMIX   2   /* mixed */
#define _KSPL   3   /* splitted */
#define _KOPR   4   /* operated */
#define _KATTD  17  /* additional attribute double */
#define _KATTI  18  /* additional attribute integer */
#define _KVAR   19  /* bound variables (variants of ATTI) */
#define _KNOCHK 256 /* sentry for no kind check */
CCC_ + Mdim operation
#define _M_UPD   -255  /* sentry for mdim update */
#define _M_NOCHK -1024 /* sentry for mdim no check */
CCC_ + Coordinate inquire flag
#define _CINQ_CHECK_SKIP        0
#define _CINQ_CHECK_EQUAL       1
#define _CINQ_CHECK_CONSISTENT  2
CCC_ + Coordinate attributes offset
CCC_  - Common
#define _COOR_KIND  1
#define _COOR_DIM   2
CCC_  - Single base
#define _COOR_BASE  3
c
#define _MEM_ROOT   2
#define _MEM_EXTD   3
#define _MEM_OPRD   3
#define _MEM_SPLT   3
CCC_  - Mixed base
#define _MIXD_BASEA 3
#define _MIXD_BASEB 4
c
#define _MEM_MIXED  4
CCC_  - additional attributes
#define _MEM_ATTR   3
#define _MEM_VAR    _MEM_ATTR
CCC_ + Errors
CCC_  - Coordinate error
#define _ERR_TAGID_INVALID     -1
#define _ERR_KIND_INVALID      -2
#define _ERR_TAGID_OVERFLOW    -3
#define _ERR_KIND_INCONSISTENT -4
#define _ERR_MDIM_INCONSISTENT -5
#define _ERR_ATTR_INCONSISTENT -6
#define _ERR_PANIC             -256
#define _ERR_NEW_COOR           1
#define _ERR_NO_BASE            2
#define _ERR_ONE_BASE           3
#define _ERR_TWO_BASES          4
CCC_  - Buffer error
#define _ERR_BUFFER_OVERFLOW  -16
CCC_ + Coordinate attributes
#define _COOR_BASIC_MAX 16
#ifndef   OPT_COOR_LEN
#  define OPT_COOR_LEN 32
#endif
#ifndef   COOR_AUTO_PFX
#  define COOR_AUTO_PFX 'C'
#endif
CCC_ + Options
#ifndef    OPT_NAMELIST_OUTPUT_EMULATION
#  define  OPT_NAMELIST_OUTPUT_EMULATION _UNMLEM_LEVEL_ENTRY
#endif
CCC_ + Test
#ifndef   TEST_ACORMS
#  define TEST_ACORMS 0
#endif
CCC_* [ACC] Manager core
CCC_ & ACCrep  ## Arpeggio/Coordinate/Core report
      subroutine ACCrep (IFPl, LVDBG)
CCC_  - Declaration
      implicit none
c
      _INTENT(IN, integer)   IFPl
      _INTENT(IN, integer)   LVDBG
c
      integer    Lcoor
      parameter (Lcoor  = OPT_COOR_LEN)
      integer    LstrK
      parameter (LstrK  = 16)
c
      integer    Kind
      character  StrK *(LstrK)
      integer    idT, idT2
      integer    jErr
      integer    N
      character  TagO*(Lcoor), TagA*(Lcoor), TagB*(Lcoor)
      integer    jC,           jCa,          jCb
      character  TagC*(Lcoor * 3)
      integer    MTg, NTg, ITg
      integer    Jofs
      integer    Nat, Nop
      integer    j,   jo
      integer    IV (1)
c
      integer    ACFt2c
CCC_  - Body
      call ACOntg (ITg, NTg, MTg)
c
 1008 format ('ACCREP report [', I3, ']')
 1009 format ('ACCREP report DONE')
c
 1001 format (I4, 1x, A2, 1x, A, T25, I7, 1x,
     $     '[', I7, I4, I4, ']', 1x, A)
 1002 format (A4, 1x, A2, 1x, A, T25, A7, 1x,
     $     '[', A7, A4, A4, ']', 1x, A)
c
      if      (COND_N(IFPl)) then
         write (IFPl, 1008) LVDBG
         write (IFPl, 1002)
     $        'C', 'K ','T', 'dim', 'ofs', 'nat', 'nop', 'B'
      else if (COND_S(IFPl)) then
         write (*,    1008) LVDBG
         write (*,    1002)
     $        'C', 'K ','T', 'dim', 'ofs', 'nat', 'nop', 'B'
      endif
c
      do idT = 1, NTg
        jC = ACFt2c (idT)
        call ACWtag (jErr, TagO, jC)
        if (jErr.eq.0) call ACWknd (jErr, Kind, jC)
        if (jErr.eq.0) then
           call ACWk2s (StrK, Kind)
           call ACWnat (jErr, Nat, jC)
           call ACWnop (jErr, Nop, jC)
           call ACWdim (jErr, N, jC)
           call ACWbs1 (jErr, jCA,  jC)
           if (jErr.eq.0) then
              call ACWtag (jErr, TagC, jCA)
           else if (jErr .eq. _ERR_NO_BASE) then
              TagC = '-'
           else if (jErr .eq. _ERR_TWO_BASES) then
              call ACWbs2 (jErr, jCA, jCB, jC)
              call ACWtag (jErr, TagA, jCA)
              call ACWtag (jErr, TagB, jCB)
 1011         format (A, '*', A)
              write (TagC, 1011) _TRIM(TagA), _TRIM(TagB)
           endif
           idT2 = idT
           call ACOqof (jErr, Jofs, idT2)
           if      (COND_N(IFPl)) then
              write (IFPl, 1001)
     $             jC, StrK, _TRIM(TagO), N,
     $             Jofs, Nat, Nop, _TRIM(TagC)
           else if (COND_S(IFPl)) then
              write (*,    1001)
     $             jC, StrK, _TRIM(TagO), N,
     $             Jofs, Nat, Nop, _TRIM(TagC)
           endif
        endif
      enddo
c
 1021 format (I5, 1x, I4, 1x, A1, 1x, I4, 1x, A2, 1x, A, T35, I7)
      do idT = 1, NTg
        jC = ACFt2c (idT)
        call ACWtag (jErr, TagO, jC)
        if (jErr.eq.0) call ACWknd (jErr, Kind, jC)
        if (jErr.eq.0) then
           call ACWk2s (StrK, Kind)
           call ACWnat (jErr, Nat, jC)
           call ACWnop (jErr, Nop, jC)
           idT2 = idT
           call ACOqof (jErr, Jofs, idT2)
           do j = 0, Nat - 1
              jo = Jofs + j
              call ACIget (jErr, IV, jo, 1)
              if      (COND_N(IFPl)) then
                 write (IFPl, 1021)
     $                jo, j, 'A', jC, StrK, _TRIM(TagO), IV
              else if (COND_S(IFPl)) then
                 write (*,    1021)
     $                jo, j, 'A', jC, StrK, _TRIM(TagO), IV
              endif
           enddo
           do j = 0, Nop - 1
              jo = Jofs + Nat + j
              call ACIget (jErr, IV, jo, 1)
              if      (COND_N(IFPl)) then
                 write (IFPl, 1021)
     $                jo, j, 'O', jC, StrK, _TRIM(TagO), IV
              else if (COND_S(IFPl)) then
                 write (*,    1021)
     $                jo, j, 'O', jC, StrK, _TRIM(TagO), IV
              endif
           enddo
        endif
      enddo
c
      call ACOmng (IFPl)
      call ACTmng (IFPl)
      call ACImng (IFPl)
      call ACDmng (IFPl)
      call ACCrpD (IFPl, LVDBG)
c
      if      (COND_N(IFPl)) then
         write (IFPl, 1009)
      else if (COND_S(IFPl)) then
         write (*,    1009)
      endif
c
      RETURN
      END
CCC_ & ACCrpD  ## Arpeggio/Coordinate/Core repord [D]
      subroutine ACCrpD (IFPl, LVDBG)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer) IFPl, LVDBG
      integer    Lcoor
      parameter (Lcoor = OPT_COOR_LEN)
      integer    MTg, NTg, ITg
      integer    idT, jC,  jCb, Kind, N, Jofs, j, jo
      integer    jErr
      character  TagO*(Lcoor), TagB*(Lcoor)
      integer    ACFt2c
      _REALSTD   DV (1)
CCC_  - Body
 1008 format ('ACCRPD report')
 1009 format ('ACCRPD report DONE')
 101  format ('S:', A, ':', A, 1x, I5, 1x, I5, 1x, I3)
 109  format ('E:', A, ':', A)
 102  format (3x, I5, 1x, E16.9)
      if      (COND_N(IFPl)) then
         write (IFPl, 1008)
      else if (COND_S(IFPl)) then
         write (*,    1008)
      endif
c
      call ACOntg (ITg, NTg, MTg)
      do idT = 1, NTg
        jC = ACFt2c (idT)
        call ACWknd (jErr, Kind, jC)
        if (jErr.eq.0.and.Kind.eq. _KATTD) then
           call ACWtag (jErr, TagO, jC)
           call ACWdim (jErr, N, jC)
           call ACWgO1 (jErr, Jofs, 0, jC)
           call ACWbs1 (jErr, jCb,  jC)
           call ACWtag (jErr, TagB, jCb)
           if      (COND_N(IFPl)) then
              write (IFPl, 101) _TRIM(TagO), _TRIM(TagB), Jofs, N, idT
           else if (COND_S(IFPl)) then
              write (*,    101) _TRIM(TagO), _TRIM(TagB), Jofs, N, idT
           endif
           if (LVDBG.gt.1) then
              do j  = 0, N - 1
                 jo = Jofs + j
                 call ACDget (jErr, DV, jo, 1)
                 if      (COND_N(IFPl)) then
                    write (IFPl, 102) j, DV (1)
                 else if (COND_S(IFPl)) then
                    write (*,    102) j, DV (1)
                 endif
              enddo
              if      (COND_N(IFPl)) then
                 write (IFPl, 109) _TRIM(TagO), _TRIM(TagB)
              else if (COND_S(IFPl)) then
                 write (*,    109) _TRIM(TagO), _TRIM(TagB)
              endif
           endif
        endif
      enddo
      if      (COND_N(IFPl)) then
         write (IFPl, 1009)
      else if (COND_S(IFPl)) then
         write (*,    1009)
      endif
      RETURN
      END
CCC_ & ACCrgN  ## Arpeggio/Coordinate/Core register [Root/Number]
      subroutine ACCrgN
     O    (iErr,
     O     idC,
     I     Mdim,
     I     IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   idC
      _INTENT(IN, integer)   Mdim
      _INTENT(IN, integer)   IFPl
      integer ACFc2t
CCC_  - Body
      iErr = 0
      idC  = Mdim
CC    Coordinate == Mdim
 201  format (A, 'ACCRGN', 1x, I7, I7)
      if      (COND_N(IFPl)) then
         write (IFPl, 201) _CHMSG, ACFc2t (idC), Mdim
      else if (COND_S(IFPl)) then
         write (*,    201) _CHMSG, ACFc2t (idC), Mdim
      endif
      RETURN
      END
CCC_ & ACCrgR  ## Arpeggio/Coordinate/Core register [Root]
      subroutine ACCrgR
     O    (iErr,
     O     idC,
     I     Mdim,  Tag,
     I     IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   idC
      _INTENT(IN, integer)   Mdim
      _INTENT(IN, character) Tag *(*)
      _INTENT(IN, integer)   IFPl
      integer N
CCC_  - Body
      N     = Mdim
CC    special base coordinate == 0
      call ACWrg1
     O    (iErr,    idC,
     I     _KROOT,  N,    0, Tag, IFPl, 'R')
      RETURN
      END
CCC_ & ACCrgX  ## Arpeggio/Coordinate/Core register [Extended]
      subroutine ACCrgX
     O    (iErr,
     O     idC,
     I     idCbas,  Mdim, Tag,
     I     IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   idC
      _INTENT(IN, integer)   idCbas
      _INTENT(IN, integer)   Mdim
      _INTENT(IN, character) Tag *(*)
      _INTENT(IN, integer)   IFPl
      integer N, Mb
CCC_  - Body
      N    = Mdim
      call ACWdim (iErr, Mb, idCbas)
      if (N.lt.0) N = Mb
      call ACWrg1
     O    (iErr,  idC,
     I     _KEXT, N,   idCbas, Tag, IFPl, 'X')
 509  format (A, 'ACCRGX WARNING: NOT EXTENSION ', I7, I7, 1x, A)
      if (N.lt.Mb) then
         if      (COND_N(IFPl)) then
            write (IFPl, 509) _CHMSG, N, Mb, _TRIM(Tag)
         else if (COND_S(IFPl)) then
            write (*,    509) _CHMSG, N, Mb, _TRIM(Tag)
         endif
      endif
      RETURN
      END
CCC_ & ACCrgS  ## Arpeggio/Coordinate/Core register [Splitted]
      subroutine ACCrgS
     O    (iErr,
     O     idC,
     I     idCbas,  Mdim, Tag,
     I     IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   idC
      _INTENT(IN, integer)   idCbas
      _INTENT(IN, integer)   Mdim
      _INTENT(IN, character) Tag *(*)
      _INTENT(IN, integer)   IFPl
      integer N, Mb
CCC_  - Body
      N    = Mdim
      Mb   = 0
      call ACWdim (iErr, Mb, idCbas)
      if (iErr.eq.0) then
         if (N.lt.0) N = Mb
         call ACWrg1
     O       (iErr,  idC,
     I        _KSPL, N,   idCbas, Tag, IFPl, 'S')
      endif
 509  format (A, 'ACCRGS WARNING: NOT SPLITTING ', I7, I7, 1x, A)
      if (N.gt.Mb) then
         if      (COND_N(IFPl)) then
            write (IFPl, 509) _CHMSG, N, Mb, _TRIM(Tag)
         else if (COND_S(IFPl)) then
            write (*,    509) _CHMSG, N, Mb, _TRIM(Tag)
         endif
      endif
      RETURN
      END
CCC_ & ACCrgO  ## Arpeggio/Coordinate/Core register [Operated]
      subroutine ACCrgO
     O    (iErr,
     O     idC,
     I     idCbas,  Mdim, Tag,
     I     IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   idC
      _INTENT(IN, integer)   idCbas
      _INTENT(IN, integer)   Mdim
      _INTENT(IN, character) Tag *(*)
      _INTENT(IN, integer)   IFPl
      integer N, Mb
CCC_  - Body
      N    = Mdim
      Mb   = 0
      call ACWdim (iErr, Mb, idCbas)
      if (iErr.eq.0) then
         if (N.lt.0) N = Mb
         call ACWrg1
     O       (iErr,  idC,
     I        _KOPR, N,   idCbas, Tag, IFPl, 'O')
      endif
      RETURN
      END
CCC_ & ACCrgM  ## Arpeggio/Coordinate/Core register [Mixed]
      subroutine ACCrgM
     O    (iErr,
     O     idC,
     I     idCbA, idCbB, Mdim, Tag,
     I     IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   idC
      _INTENT(IN, integer)   idCbA, idCbB
      _INTENT(IN, integer)   Mdim
      _INTENT(IN, character) Tag *(*)
      _INTENT(IN, integer)   IFPl
      integer N, Ma, Mb, Mab
CCC_  - Body
      N    = Mdim
      Ma   = 0
      Mb   = 0
      Mab  = 0
      call ACWdim (iErr, Ma, idCba)
      if (iErr.eq.0) call ACWdim (iErr, Mb, idCbb)
      if (iErr.eq.0) then
         Mab = Ma * Mb
         if (N.lt.0) N = Mab
         call ACWrg2
     O       (iErr,  idC,
     I        _KMIX, N,   idCbA, idCbB, Tag, IFPl, 'M')
      endif
 509  format (A, 'ACCRGM WARNING: INCONSITENT ', I7, I7, 1x, A)
      if (N .ne. Mab) then
         if      (COND_N(IFPl)) then
            write (IFPl, 509) _CHMSG, N, Mab, _TRIM(Tag)
         else if (COND_S(IFPl)) then
            write (*,    509) _CHMSG, N, Mab, _TRIM(Tag)
         endif
      endif
      RETURN
      END
CCC_ & ACCchI  ## Arpeggio/Coordinate/Core check [Attr I]
      subroutine ACCchI
     O    (iErr,
     O     idC,
     I     idCbas,  Tag,
     I     IFPl)
CC  check id for attribute TAG in Coordinate idCBAS.
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   idC
      _INTENT(IN, integer)   idCbas
      _INTENT(IN, character) Tag *(*)
      _INTENT(IN, integer)   IFPl
CCC_  - Body
      iErr = 0 * IFPl
      call ACWqid
     O    (iErr,   idC,
     I     _KATTI, idCbas, Tag)
      RETURN
      END
CCC_ & ACCrgI  ## Arpeggio/Coordinate/Core register [Attr I]
      subroutine ACCrgI
     O    (iErr,
     O     idC,
     I     IV,  idCbas,  Mdim,  Tag,
     I     IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   idC
      _INTENT(IN, integer)   IV (*)
      _INTENT(IN, integer)   idCbas
      _INTENT(IN, integer)   Mdim
      _INTENT(IN, character) Tag *(*)
      _INTENT(IN, integer)   IFPl
      integer N, Mb, Nopts
      integer ACFnop
CCC_  - Body
      N     = Mdim
      Mb    = 0
      call ACWdim (iErr, Mb, idCbas)
      if (iErr.eq.0) then
         if (N.lt.0) N = Mb
         Nopts = ACFnop (_KATTI, N)
         call ACWrgA
     O       (iErr,   idC,
     I        _KATTI, N,   Nopts, idCbas, Tag, IFPl, 'I')
      endif
      if (iErr.ge.0) call ACWstO (iErr, IV, N, 0, idC)
      RETURN
      END
CCC_ & ACCri1  ## Arpeggio/Coordinate/Core register [Attr I] (1)
      subroutine ACCri1
     O    (iErr,
     O     idC,
     I     IV0,  idCbas,  Tag,
     I     IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   idC
      _INTENT(IN, integer)   IV0
      _INTENT(IN, integer)   idCbas
      _INTENT(IN, character) Tag *(*)
      _INTENT(IN, integer)   IFPl
      integer Mdim
      integer IV (1)
CCC_  - Body
      Mdim      = 1
      IV (Mdim) = IV0
      call ACCrgI (iErr, idC, IV, idCbas, Mdim, Tag, IFPl)
      RETURN
      END
CCC_ & ACCrfI  ## Arpeggio/Coordinate/Core reference [Attr I]
      subroutine ACCrfI
     O    (iErr,
     O     idC,     IV,
     I     idCbas,  Mdim,  Tag,
     I     IFPl)
CC  refer attribute TAG in Coordinate idCBAS (no more than MDIM members)
CC  if MDIM < 0 then use attribute dimension
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   idC
      _INTENT(OUT,integer)   IV (*)
      _INTENT(IN, integer)   idCbas
      _INTENT(IN, integer)   Mdim
      _INTENT(IN, character) Tag *(*)
      _INTENT(IN, integer)   IFPl
      integer N
CCC_  - Body
      call ACWrfA
     O    (iErr,   idC,    N,
     I     _KATTI, idCbas, Tag, IFPl, 'I')
      if (iErr.eq.0) then
         if (Mdim.lt.0) then
            continue
         else
            N = MIN (Mdim, N)
         endif
         call ACWgtO (iErr, IV, N, 0, idC)
      endif
      RETURN
      END
CCC_ & ACCfi1  ## Arpeggio/Coordinate/Core reference [Attr I] (1)
      subroutine ACCfi1
     O    (iErr,
     O     idC,    IV0,
     I     idCbas, Tag,
     I     IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   idC
      _INTENT(OUT,integer)   IV0
      _INTENT(IN, integer)   idCbas
      _INTENT(IN, character) Tag *(*)
      _INTENT(IN, integer)   IFPl
      integer Mdim
      integer IV (1)
CCC_  - Body
      Mdim = 1
      call ACCrfI (iErr, idC, IV, idCbas, Mdim, Tag, IFPl)
      IV0 = IV (1)
      RETURN
      END
CCC_ & ACCrgV  ## Arpeggio/Coordinate/Core register [Attr V]
      subroutine ACCrgV
     O    (iErr,
     O     idC,
     I     IVfil, idCbas,  Mdim,  Tag,
     I     IFPl)
CCC_  - Description
CC      Fill Mdim * IVfil as option buffer if new registration
CC      Need to call ACCstV to set actual option buffer
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   idC
      _INTENT(IN, integer)   IVfil
      _INTENT(IN, integer)   idCbas
      _INTENT(IN, integer)   Mdim
      _INTENT(IN, character) Tag *(*)
      _INTENT(IN, integer)   IFPl
      integer N, Nopts
      integer ACFnop
CCC_  - Body
      N     = Mdim
      iErr = 0
      if (iErr.eq.0) then
         if (N.lt.0) N = 0
         Nopts = ACFnop (_KVAR, N)
         call ACWrgA
     O       (iErr,   idC,
     I        _KVAR,  N,   Nopts, idCbas, Tag, IFPl, 'V')
      endif
      if (iErr.eq._ERR_NEW_COOR) call ACWflO (iErr, IVfil, N, 0, idC)
      RETURN
      END
CCC_ & ACCsoV  ## Arpeggio/Coordinate/Core set option [Attr V]
      subroutine ACCsoV
     O    (iErr,
     I     IV,   Mdim,  Ipos, idC,
     I     IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   Mdim
      _INTENT(IN, integer)   Ipos
      _INTENT(IN, integer)   IV (*)
      _INTENT(IN, integer)   idC
      _INTENT(IN, integer)   IFPl
CCC_  - Body
      iErr = 0 * IFPl
      if (iErr.eq.0) call ACWstO (iErr, IV, Mdim, Ipos, idC)
      RETURN
      END
CCC_ & ACCsV1  ## Arpeggio/Coordinate/Core set option [Attr V] (1)
      subroutine ACCsV1
     O    (iErr,
     I     IV1,  Ipos, idC,
     I     IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   Ipos
      _INTENT(IN, integer)   IV1
      _INTENT(IN, integer)   idC
      _INTENT(IN, integer)   IFPl
      integer   IW (1)
CCC_  - Body
      IW (1) = IV1
      call ACCsoV
     O    (iErr,
     I     IW,  1, Ipos, idC, IFPl)
      RETURN
      END
CCC_ & ACCgoV  ## Arpeggio/Coordinate/Core get option [Attr V]
      subroutine ACCgoV
     O    (iErr, IV,
     I     Mdim, Ipos, idC,
     I     IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   IV (*)
      _INTENT(IN, integer)   Mdim
      _INTENT(IN, integer)   Ipos
      _INTENT(IN, integer)   idC
      _INTENT(IN, integer)   IFPl
CCC_  - Body
      iErr = 0 * IFPl
      if (iErr.eq.0) call ACWgtO (iErr, IV, Mdim, Ipos, idC)
      RETURN
      END
CCC_ & ACCchV  ## Arpeggio/Coordinate/Core check [Attr V]
      subroutine ACCchV
     O    (iErr,
     O     idC,
     I     idCbas,  Tag,
     I     IFPl)
CC  check id for attribute TAG in Coordinate idCBAS.
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   idC
      _INTENT(IN, integer)   idCbas
      _INTENT(IN, character) Tag *(*)
      _INTENT(IN, integer)   IFPl
CCC_  - Body
      iErr = 0 * IFPl
      call ACWqid
     O    (iErr,  idC,
     I     _KVAR, idCbas, Tag)
      RETURN
      END
CCC_ & ACCrfV  ## Arpeggio/Coordinate/Core reference [Attr V]
      subroutine ACCrfV
     O    (iErr,
     O     idC,     IV,
     I     idCbas,  Mdim,  Tag,
     I     IFPl)
CC  refer attribute TAG in Coordinate idCBAS (no more than MDIM members)
CC  if MDIM < 0 then use attribute dimension
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   idC
      _INTENT(OUT,integer)   IV (*)
      _INTENT(IN, integer)   idCbas
      _INTENT(IN, integer)   Mdim
      _INTENT(IN, character) Tag *(*)
      _INTENT(IN, integer)   IFPl
      integer N
CCC_  - Body
      call ACWrfA
     O    (iErr,   idC,    N,
     I     _KVAR, idCbas, Tag, IFPl, 'V')
      if (iErr.eq.0) then
         if (Mdim.lt.0) then
            continue
         else
            N = MIN (Mdim, N)
         endif
         call ACWgtO (iErr, IV, N, 0, idC)
      endif
      RETURN
      END
CCC_ & ACCrgD  ## Arpeggio/Coordinate/Core register [Attr D]
      subroutine ACCrgD
     O    (iErr,
     O     idC,
     I     DV,  idCbas,  Mdim,  Tag,
     I     IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   idC
      _INTENT(IN, _REALSTD)  DV (*)
      _INTENT(IN, integer)   idCbas
      _INTENT(IN, integer)   Mdim
      _INTENT(IN, character) Tag *(*)
      _INTENT(IN, integer)   IFPl
      integer N, Mb, Nopts, Joff
      integer ACFnop
CCC_  - Body
      N     = Mdim
      Mb    = 0
      Nopts = ACFnop (_KATTD, N)
      call ACWdim (iErr, Mb, idCbas)
      if (iErr.eq.0) then
         if (N.lt.0) N = Mb
         call ACWrgA
     O       (iErr,   idC,
     I        _KATTD, N,   Nopts, idCbas, Tag, IFPl, 'D')
      endif
      if (iErr.ge.0) call ACDalc (iErr, Joff, N)
      if (iErr.eq.0) call ACDset (iErr, DV,   Joff, N)
CC    option 1 is Joff
c$$$      if (iErr.eq.0) call ACWstO (iErr, Joff, Nopts, 0, idC)
c$$$      write (*, *) 'DN', Nopts
      if (iErr.eq.0) call ACWsO1 (iErr, Joff, 0, idC)
      RETURN
      END
CCC_ & ACCchD  ## Arpeggio/Coordinate/Core check [Attr D]
      subroutine ACCchD
     O    (iErr,
     O     idC,
     I     idCbas,  Tag,
     I     IFPl)
CC  check id for attribute TAG in Coordinate idCBAS.
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   idC
      _INTENT(IN, integer)   idCbas
      _INTENT(IN, character) Tag *(*)
      _INTENT(IN, integer)   IFPl
CCC_  - Body
      iErr = 0 * IFPl
      call ACWqid
     O    (iErr,   idC,
     I     _KATTD, idCbas, Tag)
      RETURN
      END
CCC_ & ACCrfD  ## Arpeggio/Coordinate Core reference [Attr D]
      subroutine ACCrfD
     O    (iErr,
     O     idC,     DV,
     I     idCbas,  Mdim,  Tag,
     I     IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   idC
      _INTENT(OUT,_REALSTD)  DV (*)
      _INTENT(IN, integer)   idCbas
      _INTENT(IN, integer)   Mdim
      _INTENT(IN, character) Tag *(*)
      _INTENT(IN, integer)   IFPl
      integer Joff
      integer N
CCC_  - Body
      call ACWrfA
     O    (iErr,   idC,    N,
     I     _KATTD, idCbas, Tag, IFPl, 'D')
      if (iErr.eq.0) then
         if (Mdim.lt.0) then
            continue
         else
            N = MIN (Mdim, N)
         endif
      endif
CC    option 1 is Joff
c$$$      write (*,*) 'CHK 000',iErr
      if (iErr.eq.0) call ACWgO1 (iErr, Joff, 0, idC)
c$$$      write (*,*) 'CHK 001',iErr
      if (iErr.eq.0) call ACDget (iErr, DV,   Joff, N)
c$$$      write (*,*) 'CHK 002',iErr
c
      if (iErr.ne.0) call DAtrcU (IFPl, iErr, 'E', 'ACWRFD')
      RETURN
      END
CCC_ & ACCupD  ## Arpeggio/Coordinate Core update [Attr D]
      subroutine ACCupD
     O    (iErr,
     O     idC,
     I     DV,  idCbas,  Mdim,  Tag,
     I     IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   idC
      _INTENT(IN, _REALSTD)  DV (*)
      _INTENT(IN, integer)   idCbas
      _INTENT(IN, integer)   Mdim
      _INTENT(IN, character) Tag *(*)
      _INTENT(IN, integer)   IFPl
      integer Joff
      integer N
CCC_  - Body
      call ACWrfA
     O    (iErr,   idC,    N,
     I     _KATTD, idCbas, Tag, IFPl, 'D')
      if (iErr.eq.0) then
         if (Mdim.lt.0) then
            continue
         else
            N = MIN (Mdim, N)
         endif
      endif
CC    option 1 is Joff
      if (iErr.eq.0) call ACWgO1 (iErr, Joff, 0, idC)
      if (iErr.eq.0) call ACDset (iErr, DV,   Joff, N)
c
      if (iErr.ne.0) call DAtrcU (IFPl, iErr, 'E', 'ACCUPD')
      RETURN
      END
CCC_ & ACCrlD  ## Arpeggio/Coordinate Core reference [Attr D/list]
      subroutine ACCrlD
     O    (iErr,
     O     idC,     DV,
     I     idCbas,  NV,  LP, KADD, Tag,
     I     IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   idC
      _INTENT(IN, integer)   NV
      _INTENT(IN, integer)   LP (NV), KADD
      _INTENT(OUT,_REALSTD)  DV (NV)
      _INTENT(IN, integer)   idCbas
      _INTENT(IN, character) Tag *(*)
      _INTENT(IN, integer)   IFPl
      integer Joff
      integer N, j, k
CCC_  - Body
      call ACWrfA
     O    (iErr,   idC,    N,
     I     _KATTD, idCbas, Tag, IFPl, 'D')
      if (iErr.eq.0) call ACWgO1 (iErr, Joff, 0, idC)
      if (iErr.eq.0) then
         do k = 1, NV
            j = LP (K) + KADD
            if (j.lt.1 .or. j.gt.N) then
               DV (k) = 0.0d0
            else
               j = Joff + j - 1
               call ACDget (iErr, DV (k), j, 1)
            endif
c$$$            write (*, *) 'RLD', k, LP(K), DV (k), j
         enddo
      endif
      RETURN
      END
CCC_ & ACCrfE  ## Arpeggio/Coordinate Core reference [Attr D/range]
      subroutine ACCrfE
     O    (iErr,
     O     idC,     DV,
     I     idCbas,  IS, NP, Tag,
     I     IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   idC
      _INTENT(OUT,_REALSTD)  DV (*)
      _INTENT(IN, integer)   idCbas
      _INTENT(IN, integer)   IS, NP
      _INTENT(IN, character) Tag *(*)
      _INTENT(IN, integer)   IFPl
      integer Joff
      integer N
CCC_  - Body
      call ACWrfA
     O    (iErr,   idC,    N,
     I     _KATTD, idCbas, Tag, IFPl, 'D')
CC    option 1 is Joff
      if (iErr.eq.0) call ACWgO1 (iErr, Joff, 0, idC)
      Joff = Joff + MIN (N, IS) - 1
      N    = MIN (NP, (N - IS + 1))
      if (iErr.eq.0) call ACDget (iErr, DV,   Joff, N)
      RETURN
      END
CCC_* [ACW] Wrappers for buffer managers
CCC_ & ACWrg1  ## Arpeggio/Coordinate registration wrapper (1 base)
      subroutine ACWrg1
     O    (iErr,  idC,
     I     Kind,  Mdim, idCbas, Tag, IFPl, Cmdl)
CCC_  - Declaration
      implicit none
c
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   idC
      _INTENT(IN, integer)   Kind
      _INTENT(IN, integer)   Mdim
      _INTENT(IN, integer)   idCbas
      _INTENT(IN, character) Tag*(*)
      _INTENT(IN, integer)   IFPl
      _INTENT(IN, character) Cmdl*(*)
c
      integer    MciMax
      parameter (MciMax = _COOR_BASIC_MAX)
      integer    Lcoor
      parameter (Lcoor  = OPT_COOR_LEN)
c
      integer jEdmy
      integer idT
      integer Nopts
c
      integer Nattr
      integer Iattr (MciMax),  IchkC (MciMax)
      character TagB*(Lcoor)
c
      integer ACFmem
      integer ACFt2c
      integer ACFnop
CCC_  - Body
      iErr = 0
      Nattr = ACFmem (Kind)
      Nopts = ACFnop (Kind, Mdim)
      idC   = 0
c
      Iattr (_COOR_KIND) = Kind
      Iattr (_COOR_DIM)  = Mdim
      Iattr (_COOR_BASE) = idCbas
      IchkC (_COOR_KIND) = _CINQ_CHECK_CONSISTENT
      IchkC (_COOR_DIM)  = _CINQ_CHECK_CONSISTENT
      IchkC (_COOR_BASE) = _CINQ_CHECK_CONSISTENT
c
      call ACOinq (iErr, idT, Iattr, IchkC, Tag, Nattr)
      if (iErr.eq.0 .and. idT.eq.0) then
         call ACOnew (iErr, idT, Iattr, Tag, Nattr, Nopts)
         if (iErr.eq.0) iErr = _ERR_NEW_COOR
      endif
c
      call ACWtag (jEdmy, TagB, idCbas)
 101  format ('ACWRG1 (', A, ') [', I4, '] ', I4, 1x, A, 1x, A, 1x, I7)
      if      (COND_N(IFPl)) then
         write (IFPl, 101)
     $        Cmdl, iErr, idT, _TRIM(Tag), _TRIM(TagB), Mdim
      else if (COND_S(IFPl)) then
         write (*,    101)
     $        Cmdl, iErr, idT, _TRIM(Tag), _TRIM(TagB), Mdim
      endif
c
      if (iErr.ge.0) idC = ACFt2c (idT)
      RETURN
      END
CCC_ & ACWrg2  ## Arpeggio/Coordinate registration wrapper (2 bases)
      subroutine ACWrg2
     O    (iErr,  idC,
     I     Kind,  Mdim, idCbA, idCbB, Tag, IFPl, Cmdl)
CCC_  - Declaration
      implicit none
c
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   idC
      _INTENT(IN, integer)   Kind
      _INTENT(IN, integer)   Mdim
      _INTENT(IN, integer)   idCbA, idCbB
      _INTENT(IN, character) Tag*(*)
      _INTENT(IN, integer)   IFPl
      _INTENT(IN, character) Cmdl*(*)
c
      integer    MciMax
      parameter (MciMax = _COOR_BASIC_MAX)
      integer    Lcoor
      parameter (Lcoor  = OPT_COOR_LEN)
c
      integer    idT
      integer    Nopts
c
      integer    Nattr
      integer    Iattr (MciMax),  IchkC (MciMax)
      character  TagA*(Lcoor), TagB*(Lcoor)
      character  TagT*(Lcoor)
      integer    jEdmy
CCC_   . functions
      integer    ACFmem
      integer    ACFt2c
      integer    ACFnop
CCC_  - Body
      iErr = 0
      Nattr = ACFmem (Kind)
      Nopts = ACFnop (Kind, Mdim)
c
      Iattr (_COOR_KIND)  = Kind
      Iattr (_COOR_DIM)   = Mdim
      Iattr (_MIXD_BASEA) = idCbA
      Iattr (_MIXD_BASEB) = idCbB
      IchkC (_COOR_KIND)  = _CINQ_CHECK_CONSISTENT
      IchkC (_COOR_DIM)   = _CINQ_CHECK_CONSISTENT
      IchkC (_MIXD_BASEA) = _CINQ_CHECK_CONSISTENT
      IchkC (_MIXD_BASEB) = _CINQ_CHECK_CONSISTENT
c
      call ACWtag (jEdmy, TagA, idCbA)
      call ACWtag (jEdmy, TagB, idCbB)
c
      call ACOinq (iErr, idT, Iattr, IchkC, Tag, Nattr)
      if (iErr.eq.0 .and. idT.eq.0) then
         call ACOnew (iErr, idT, Iattr, Tag, Nattr, Nopts)
         if (iErr.eq.0) iErr = _ERR_NEW_COOR
      endif
c
      if (iErr.ge.0) idC = ACFt2c (idT)
      call ACWtag (jEdmy, TagT, idC)
c
 101  format ('ACWRG2 (', A1, ') [', I4, '] ', I4, 1x, A, 1x,
     $     A, '*', A, 1x, I7)
      if      (COND_N(IFPl)) then
         write (IFPl, 101)
     $        Cmdl, iErr, idT,
     $        _TRIM(TagT), _TRIM(TagA), _TRIM(TagB), Mdim
      else if (COND_S(IFPl)) then
         write (*,    101)
     $        Cmdl, iErr, idT,
     $        _TRIM(TagT), _TRIM(TagA), _TRIM(TagB), Mdim
      endif
c
      RETURN
      END
CCC_ & ACWrgA  ## Arpeggio/Coordinate registration wrapper (A)
      subroutine ACWrgA
     O    (iErr,  idC,
     I     Kind,  Mdim, Nopts, idCbas, Tag, IFPl, Cmdl)
CCC_  - Declaration
      implicit none
c
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   idC
      _INTENT(IN, integer)   Kind
      _INTENT(IN, integer)   Mdim
      _INTENT(IN, integer)   Nopts
      _INTENT(IN, integer)   idCbas
      _INTENT(IN, character) Tag*(*)
      _INTENT(IN, integer)   IFPl
      _INTENT(IN, character) Cmdl*(*)
c
      integer    MciMax
      parameter (MciMax = _COOR_BASIC_MAX)
      integer    Lcoor
      parameter (Lcoor  = OPT_COOR_LEN)
c
      integer idT
      integer Nattr
      integer Iattr (MciMax),  IchkC (MciMax)
      character TagB*(Lcoor)
      integer jEdmy
c
      integer ACFmem
      integer ACFt2c
CCC_  - Body
      iErr = 0
      Nattr = ACFmem (Kind)
      idC   = 0
c
      Iattr (_COOR_KIND) = Kind
      Iattr (_COOR_DIM)  = Mdim
      Iattr (_COOR_BASE) = idCbas
c$$$      IchkC (_COOR_KIND) = _CINQ_CHECK_CONSISTENT
      IchkC (_COOR_KIND) = _CINQ_CHECK_EQUAL
      IchkC (_COOR_DIM)  = _CINQ_CHECK_CONSISTENT
      IchkC (_COOR_BASE) = _CINQ_CHECK_EQUAL
c
      call ACOinq (iErr, idT, Iattr, IchkC, Tag, Nattr)
      if (iErr.eq.0 .and. idT.eq.0) then
         call ACOnew (iErr, idT, Iattr, Tag, Nattr, Nopts)
         if (iErr.eq.0) iErr = _ERR_NEW_COOR
      endif
c
      call ACWtag (jEdmy, TagB, idCbas)
 101  format ('ACWRGA (', A, ') [', I4, '] ', I4, 1x, A, 1x, A, 1x, I7)
      if      (COND_N(IFPl)) then
         write (IFPl, 101)
     $        Cmdl, iErr, idT, _TRIM(Tag), _TRIM(TagB), Mdim
      else if (COND_S(IFPl)) then
         write (*,    101)
     $        Cmdl, iErr, idT, _TRIM(Tag), _TRIM(TagB), Mdim
      endif
c
      if (iErr.ge.0) idC = ACFt2c (idT)
      RETURN
      END
CCC_ & ACWrfA  ## Arpeggio/Coordinate reference wrapper (A)
      subroutine ACWrfA
     O    (iErr,  idC,    Mdim,
     I     Kind,  idCbas, Tag,   IFPl, Cmdl)
CCC_  - Declaration
      implicit none
c
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   idC
      _INTENT(OUT,integer)   Mdim
      _INTENT(IN, integer)   Kind
      _INTENT(IN, integer)   idCbas
      _INTENT(IN, character) Tag*(*)
      _INTENT(IN, integer)   IFPl
      _INTENT(IN, character) Cmdl*(*)
c
      integer    MciMax
      parameter (MciMax = _COOR_BASIC_MAX)
      integer    Lcoor
      parameter (Lcoor  = OPT_COOR_LEN)
c
      integer   idT
      integer   Nattr
      integer   Iattr (MciMax),  IchkC (MciMax)
      character TagB*(Lcoor)
      integer   jEdmy
c
      integer ACFmem
      integer ACFt2c
CCC_  - Body
      iErr = 0
      Nattr = ACFmem (Kind)
      idC   = 0
c
      Iattr (_COOR_KIND) = Kind
      Iattr (_COOR_DIM)  = 0
      Iattr (_COOR_BASE) = idCbas
      IchkC (_COOR_KIND) = _CINQ_CHECK_CONSISTENT
      IchkC (_COOR_DIM)  = _CINQ_CHECK_SKIP
      IchkC (_COOR_BASE) = _CINQ_CHECK_EQUAL
c
      call ACOinq (iErr, idT, Iattr, IchkC, Tag, Nattr)
c$$$      write (*, *) 'inq', idCbas, idT, iErr
c
      call ACWtag (jEdmy, TagB, idCbas)
 101  format ('ACWRFA (', A, ') [', I4, '] ', I4, 1x, A, 1x, A)
      if      (COND_N(IFPl)) then
         write (IFPl, 101) Cmdl, iErr, idT, _TRIM(Tag), _TRIM(TagB)
      else if (COND_S(IFPl)) then
         write (*,    101) Cmdl, iErr, idT, _TRIM(Tag), _TRIM(TagB)
      endif
c
      if (iErr.eq.0) idC = ACFt2c (idT)
      if (iErr.eq.0) call ACWdim (iErr, Mdim, idC)
c
      if (iErr.ne.0) call DAtrcU (IFPl, iErr, 'E', 'ACWRFA')
      RETURN
      END
CCC_ & ACWqid  ## Arpeggio/Coordinate wrapper (inquire id)
      subroutine ACWqid
     O    (iErr, idC,
     I     Kind, idCbas, Tag)
CCC_  - Declaration
      implicit none
c
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   idC
      _INTENT(IN, integer)   Kind
      _INTENT(IN, integer)   idCbas
      _INTENT(IN, character) Tag*(*)
c
      integer    MciMax
      parameter (MciMax = _COOR_BASIC_MAX)
      integer    Nattr
      integer    Iattr (MciMax),  IchkC (MciMax)
      integer    idT
c
      integer    ACFmem
      integer    ACFt2c
CCC_  - Body
      iErr = 0
      idC  = 0
      idT  = 0
c
      Nattr = ACFmem (Kind)
c
      Iattr (_COOR_KIND) = Kind
      Iattr (_COOR_DIM)  = 0
      Iattr (_COOR_BASE) = idCbas
      IchkC (_COOR_KIND) = _CINQ_CHECK_CONSISTENT
      IchkC (_COOR_DIM)  = _CINQ_CHECK_SKIP
      IchkC (_COOR_BASE) = _CINQ_CHECK_EQUAL
c
      call ACOinq (iErr, idT, Iattr, IchkC, Tag, Nattr)
      if (iErr.eq.0) idC = ACFt2c (idT)
      RETURN
      END
CCC_ & ACWqit  ## Arpeggio/Coordinate wrapper (inquire id by tag only)
      subroutine ACWqit
     O    (iErr, idC,
     I     Tag)
CCC_  - Declaration
      implicit none
c
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   idC
      _INTENT(IN, character) Tag*(*)
c
      integer    MciMax
      parameter (MciMax = _COOR_BASIC_MAX)
      integer    Nattr
      integer    Iattr (MciMax),  IchkC (MciMax)
      integer    idT
c
      integer    ACFt2c
CCC_  - Body
      iErr  = 0
      idC   = 0
      idT   = 0
      Nattr = 0
c
      Iattr (_COOR_KIND) = 0
      Iattr (_COOR_DIM)  = 0
      Iattr (_COOR_BASE) = 0
      IchkC (_COOR_KIND) = _CINQ_CHECK_SKIP
      IchkC (_COOR_DIM)  = _CINQ_CHECK_SKIP
      IchkC (_COOR_BASE) = _CINQ_CHECK_SKIP
c
      call ACOinq (iErr, idT, Iattr, IchkC, Tag, Nattr)
      if (iErr.eq.0) idC = ACFt2c (idT)
      RETURN
      END
CCC_ & ACWrdm  ## Arpeggio/Coordinate registration wrapper (mdim/base)
      subroutine ACWrdm
     O    (iErr,
     I     idC,  idCbas, Mdim, IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   idC
      _INTENT(IN, integer)   idCbas
      _INTENT(IN, integer)   Mdim
      _INTENT(IN, integer)   IFPl
      integer  Mold
      integer  idT
      integer  iBold
      integer  ACFc2t
CCC_  - Body
      iErr  = 0
      idT   = ACFc2t (idC)
 101  format ('ACWRDM: CANNOT CHANGE ROOT MDIM ', I4)
 102  format ('ACWRDM: FORCE CHANGE MDIM ', I4, 1x, I7, ' TO ', I7)
 201  format ('ACWRDM: KEEP BASE ', I4, 1x, I4)
 202  format ('ACWRDM: FORCE CHANGE BASE ', I4, 1x, I4, ' TO ', I4)
 301  format ('ACWRDM: KEEP BASE (M)', I4)
 302  format ('ACWRDM: CANNOT CHANGE M/BASE', I4)
      if (idC.ge.0) then
         if      (COND_N(IFPl)) then
            write (IFPl, 101) idC
         else if (COND_S(IFPl)) then
            write (*,    101) idC
         endif
         iErr = -1
      else
         call ACWdim (iErr, Mold, idC)
         call ACOst1 (iErr, Mdim, _COOR_DIM - 1, idT)
         if      (COND_N(IFPl)) then
            write (IFPl, 102) idC, Mold, Mdim
         else if (COND_S(IFPl)) then
            write (*,    102) idC, Mold, Mdim
         endif
      endif
      if (iErr.eq.0) then
         call ACWbs1 (iErr, iBold, idC)
         if (iErr .eq. _ERR_TWO_BASES) then
            if (idCbas.eq.0) then
               iErr = 0
               if      (COND_N(IFPl)) then
                  write (IFPl, 301) idC
               else if (COND_S(IFPl)) then
                  write (*,    301) idC
               endif
            else
               if      (COND_N(IFPl)) then
                  write (IFPl, 302) idC
               else if (COND_S(IFPl)) then
                  write (*,    302) idC
               endif
            endif
         else
            if (idCbas.eq.0) then
               if      (COND_N(IFPl)) then
                  write (IFPl, 201) idC, iBold
               else if (COND_S(IFPl)) then
                  write (*,    201) idC, iBold
               endif
            else
               call ACOst1 (iErr, idCbas, _COOR_BASE - 1, idT)
               if      (COND_N(IFPl)) then
                  write (IFPl, 202) idC, iBold, idCbas
               else if (COND_S(IFPl)) then
                  write (*,    202) idC, iBold, idCbas
               endif
            endif
         endif
      endif
      RETURN
      END
CCC_ & ACWdim  ## Arpeggio/Coordinate wrapper (get dim)
      subroutine ACWdim
     O    (iErr, Mdim,
     I     idC)
CCC_  - Description
CC     get Dimension property of coordinate idC
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)  iErr
      _INTENT(OUT,integer)  Mdim
      _INTENT(IN, integer)  idC
      integer  idT
      integer  ACFc2t
CCC_  - Body
      iErr = 0
      if (idC.gt.0) then
         Mdim = idC
      else if (idC.eq.0) then
         Mdim = 0
      else
         idT = ACFc2t (idC)
         call ACOgt1 (iErr, Mdim, _COOR_DIM - 1, idT)
      endif
      RETURN
      END
CCC_ & ACWbs1  ## Arpeggio/Coordinate wrapper (get base 1)
      subroutine ACWbs1
     O    (iErr, idCbas,
     I     idC)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)  iErr
      _INTENT(OUT,integer)  idCbas
      _INTENT(IN, integer)  idC
      integer  idT
      integer  ACFc2t
      integer  Kind
CCC_  - Body
      iErr = 0
      idT = ACFc2t (idC)
      idCbas = 0
      call ACWknd (iErr, Kind, idC)
      if (idT.gt.0) then
         if (Kind.eq._KROOT) then
            iErr = _ERR_NO_BASE
         else if (Kind.eq._KEXT
     $           .or. Kind.eq._KSPL
     $           .or. Kind.eq._KOPR) then
            call ACOgt1 (iErr, idCbas, _COOR_BASE - 1, idT)
         else if (Kind.eq._KATTI
     $           .or. Kind.eq._KATTD
     $           .or. Kind.eq._KVAR) then
            call ACOgt1 (iErr, idCbas, _COOR_BASE - 1, idT)
         else
            iErr = _ERR_TWO_BASES
         endif
      endif
      RETURN
      END
CCC_ & ACWbs2  ## Arpeggio/Coordinate wrapper (get base 2)
      subroutine ACWbs2
     O    (iErr, idCbA, idCbB,
     I     idC)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)  iErr
      _INTENT(OUT,integer)  idCbA,  idCbB
      _INTENT(IN, integer)  idC
      integer  idT
      integer  ACFc2t
      integer  Kind
CCC_  - Body
      iErr = 0
      idT = ACFc2t (idC)
      idCbA = 0
      idCbB = 0
      call ACWknd (iErr, Kind, idC)
      if (idT.gt.0) then
         if (Kind.eq._KROOT) then
            iErr = _ERR_NO_BASE
         else if (Kind.eq._KMIX) then
            call ACOgt1 (iErr, idCbA, _MIXD_BASEA - 1, idT)
            call ACOgt1 (iErr, idCbB, _MIXD_BASEB - 1, idT)
         else
            iErr = _ERR_ONE_BASE
         endif
      endif
      RETURN
      END
CCC_ & ACWbsa  ## Arpeggio/Coordinate wrapper (get base array)
      subroutine ACWbsa
     O    (iErr, idCb,
     I     idC)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)  iErr
      _INTENT(OUT,integer)  idCb (*)
      _INTENT(IN, integer)  idC
CCC_  - Body
      iErr = 0
      idCb (1) = 0
      idCb (2) = 0
c
      call ACWbs2 (iErr, idCb (1), idCb (2), idC)
      if (iErr.eq._ERR_ONE_BASE)
     $     call ACWbs1 (iErr, idCb (1), idC)
c
      RETURN
      END
CCC_ & ACWrb2  ## Arpeggio/Coordinate wrapper (get base 2 recursive)
      subroutine ACWrb2
     O    (iErr, idCbA, idCbB,
     I     idC)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)  iErr
      _INTENT(OUT,integer)  idCbA, idCbB
      _INTENT(IN, integer)  idC
      integer jC, jT
CCC_  - Body
      iErr  = 0
      idCbA = 0
      idCbB = 0
      jC    = idC
      DO
c$$$         write (*, *) jC, iErr
         call ACWbs2 (iErr, idCbA, idCbB, jC)
         if (iErr.eq.0) goto 90
         if (iErr.eq._ERR_ONE_BASE) then
            call ACWbs1 (iErr, jT, jC)
            jC = jT
         else
            iErr = -1
            goto 90
         endif
      ENDDO
 90   continue
c
      RETURN
      END
CCC_ & ACWkbc  ## Arpeggio/Coordinate wrapper (kind/base check)
      subroutine ACWkbc
     O    (iErr,
     I     idC,   idBS, CKind)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   idC
      _INTENT(IN, integer)   idBS
      _INTENT(IN, character) CKind*(*)
      character STRK*(16)
      integer   jcb
      integer   KC
CCC_  - Body
      iErr = 0
      call ACWknd (iErr, KC, idC)
      if (iErr.eq.0) then
         call ACWk2s (StrK, KC)
         if (StrK.ne.CKind) iErr = 1
      endif
      if (iErr.eq.0) then
         call ACWbs1 (iErr, jcb,  idC)
         if (jcb.ne.idBS) iErr = 2
      endif
      RETURN
      END
CCC_ & ACWknd  ## Arpeggio/Coordinate wrapper (get kind)
      subroutine ACWknd
     O    (iErr, Kind,
     I     idC)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)  iErr
      _INTENT(OUT,integer)  Kind
      _INTENT(IN, integer)  idC
      integer  idT
      integer  ACFc2t
CCC_  - Body
      iErr  = 0
      idT   = ACFc2t (idC)
      if (idT.gt.0) then
         call ACOgt1 (iErr, Kind, _COOR_KIND - 1, idT)
      else
         Kind = _KROOT
      endif
      RETURN
      END
CCC_ & ACWk2s  ## Arpeggio/Coordinate kind to string
      subroutine ACWk2s (Str, Kind)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,character) Str *(*)
      _INTENT(IN, integer)   Kind
CCC_  - Body
      if (Kind.eq._KROOT) then
         Str = 'R'
      else if (Kind.eq._KEXT) then
         Str = 'X'
      else if (Kind.eq._KMIX) then
         Str = 'M'
      else if (Kind.eq._KSPL) then
         Str = 'S'
      else if (Kind.eq._KOPR) then
         Str = 'O'
      else if (Kind.eq._KATTD) then
         Str = 'D'
      else if (Kind.eq._KATTI) then
         Str = 'I'
      else if (Kind.eq._KVAR) then
         Str = 'V'
      else
         Str = '!E'
      endif
      RETURN
      END
CCC_ & ACWnat  ## Arpeggio/Coordinate wrapper (get nattr)
      subroutine ACWnat
     O    (iErr, Nattr,
     I     idC)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)  iErr
      _INTENT(OUT,integer)  Nattr
      _INTENT(IN, integer)  idC
      integer  ACFmem
      integer  Kind
CCC_  - Body
      iErr  = 0
      Nattr = 0
      call ACWknd (iErr, Kind, idC)
      if (iErr.eq.0) Nattr = ACFmem (Kind)
      RETURN
      END
CCC_ & ACWnop  ## Arpeggio/Coordinate wrapper (get nopts)
      subroutine ACWnop
     O    (iErr, Nopts,
     I     idC)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)  iErr
      _INTENT(OUT,integer)  Nopts
      _INTENT(IN, integer)  idC
      integer  ACFnop
      integer  Kind
      integer  N
CCC_  - Body
      iErr  = 0
      Nopts = 0
      if (iErr.eq.0) call ACWknd (iErr, Kind, idC)
      if (iErr.eq.0) call ACWdim (iErr, N,    idC)
      if (iErr.eq.0) Nopts = ACFnop (Kind, N)
      RETURN
      END
CCC_ & ACWstO  ## Arpeggio/Coordinate wrapper (set opts)
      subroutine ACWstO
     O    (iErr,
     I     IV,   Mdim, Ipos, idC)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)  iErr
      _INTENT(IN, integer)  Mdim
      _INTENT(IN, integer)  Ipos
      _INTENT(IN, integer)  IV (*)
      _INTENT(IN, integer)  idC
      integer  idT
      integer  ACFc2t
      integer  Nat, Jpos
CCC_  - Body
      iErr = 0
      if (idC.gt.0) iErr = _ERR_PANIC
      if (iErr.eq.0) call ACWnat (iErr, Nat, idC)
      if (iErr.eq.0) then
         idT = ACFc2t (idC)
         Jpos = Nat + Ipos
         call ACOset (iErr, IV, Jpos, Mdim, idT)
      endif
      RETURN
      END
CCC_ & ACWflO  ## Arpeggio/Coordinate wrapper (fill opts)
      subroutine ACWflO
     O    (iErr,
     I     IVfil, Mdim, Ipos, idC)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)  iErr
      _INTENT(IN, integer)  Mdim
      _INTENT(IN, integer)  Ipos
      _INTENT(IN, integer)  IVfil
      _INTENT(IN, integer)  idC
      integer  idT
      integer  ACFc2t
      integer  Nat, Jpos
CCC_  - Body
      iErr = 0
      if (idC.gt.0) iErr = _ERR_PANIC
      if (iErr.eq.0) call ACWnat (iErr, Nat, idC)
      if (iErr.eq.0) then
         idT = ACFc2t (idC)
         Jpos = Nat + Ipos
         call ACOfil (iErr, IVfil, Jpos, Mdim, idT)
      endif
      RETURN
      END
CCC_ & ACWgtO  ## Arpeggio/Coordinate wrapper (get opts)
      subroutine ACWgtO
     O    (iErr, IV,
     I     Mdim, Ipos, idC)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)  iErr
      _INTENT(OUT,integer)  IV (*)
      _INTENT(IN, integer)  Mdim
      _INTENT(IN, integer)  Ipos
      _INTENT(IN, integer)  idC
      integer  idT
      integer  ACFc2t
      integer  Nat, Jpos
CCC_  - Body
      iErr = 0
      if (idC.gt.0) iErr = _ERR_PANIC
      if (iErr.eq.0) call ACWnat (iErr, Nat, idC)
      if (iErr.eq.0) then
         idT = ACFc2t (idC)
         Jpos = Nat + Ipos
         call ACOget (iErr, IV, Jpos, Mdim, idT)
      endif
      RETURN
      END
CCC_ & ACWtag  ## Arpeggio/Coordinate wrapper (get tag)
      subroutine ACWtag
     O    (iErr, Tag,
     I     idC)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,character) Tag*(*)
      _INTENT(IN, integer)   idC
      integer   idT
      integer   ACFc2t
      character Tmp*(20)
      integer   lt
CCC_  - Body
      iErr = 0
      if (idC.gt.0) then
         call USGlni (Tmp, idC)
         lt = MIN (len (Tag), len (Tmp)) - 1
         if (lt.lt.1) then
            iErr = -1
         else
            write (Tag, '(''$'', A)') Tmp (1:lt)
         endif
      else if (idC.eq.0) then
         Tag = '*ROOT*'
      else
         idT = ACFc2t (idC)
         call ACTget (iErr, Tag, idT)
      endif
      RETURN
      END
CCC_ & ACWldi  ## loop decomposition info
       subroutine ACWldi
     O    (iErr,
     I     icTGT, icBAS, IFPl)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   icTGT
      _INTENT(IN, integer)   icBAS
      _INTENT(IN, integer)   IFPl
      integer LPa (3)
      integer jcdmy
c
      iErr = 0
c
      if (iErr.eq.0) call ACWrdi (iErr, jcdmy, icTGT, IFPl)
c
      call ACWlpd (iErr, LPa, icTGT, icBAS, IFPl)
      if (iErr.eq.0) then
         call ACCrgI (iErr, jcdmy, LPa, icTGT, 3, 'EL', IFPl)
         iErr = MIN (0, iErr)
      else
         iErr = -1
      endif
c
      call DAtrcU (IFPl, iErr, 'R', 'ACWLDI')
      RETURN
      END
CCC_ & ACWrld  ## register loop decomposition info
      subroutine ACWrld
     O    (iErr,
     I     icTGT, icBAS, jb0, jb9, IFPl)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   icTGT
      _INTENT(IN, integer)   icBAS (*)
      _INTENT(IN, integer)   jb0, jb9
      _INTENT(IN, integer)   IFPl
      integer j
      integer LPa (3)
      integer jcb, jcdmy
c
      iErr = 0
c
      if (iErr.eq.0) call ACWrdi (iErr, jcdmy, icTGT, IFPl)
c
      do j = jb0, jb9
         jcb = icBAS (j)
         call ACWlpd (iErr, LPa, icTGT, jcb, IFPl)
         if (iErr.eq.0) goto 100
      enddo
 100  continue
      if (iErr.eq.0) then
         call ACCrgI (iErr, jcdmy, LPa, icTGT, 3, 'EL', IFPl)
         iErr = MIN (0, iErr)
      else
         iErr = -1
      endif
c
      call DAtrcU (IFPl, iErr, 'R', 'ACWRLD')
      RETURN
      END
CCC_ & ACWrdi  ## register loop decomposition info
      subroutine ACWrdi
     O    (iErr,  icXM,
     I     icTGT, IFPl)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   icXM
      _INTENT(IN, integer)   icTGT
      _INTENT(IN, integer)   IFPl
      integer    LPR, NPR
      parameter (LPR = 32)
      integer    jcPRM (LPR)
c
      iErr = 0
c
      if (iErr.eq.0) then
         call ACWcmd
     O       (iErr,
     O        jcPRM,  NPR,  LPR,
     I        icTGT,  IFPl)
      endif
      if (iErr.eq.0) then
         call ACCrgI (iErr, icXM, jcPRM, icTGT, NPR, 'XM', IFPl)
         iErr = MIN (0, iErr)
      endif
c
      RETURN
      END
CCC_ & ACWcmd  ## multi-coordinate structure decomposition
      subroutine ACWcmd
     O    (iErr,
     O     icPRM,  NW,  LW,
     I     icTGT,  IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   icPRM (*)
      _INTENT(OUT,integer)   NW
      _INTENT(IN, integer)   LW
      _INTENT(IN, integer)   icTGT
      _INTENT(IN, integer)   IFPl
c
      integer    jwlp (3, LW)
      integer    LPa  (3)
      integer    icBAS
CCC_  - Body
      icBAS = 0
      call ACWlpc
     O    (iErr,
     O     LPa,
     O     icPRM,  JWLP,   NW,  LW,
     I     icTGT,  icBAS,  IFPl)
      RETURN
      END
CCC_ & ACWlpd  ## loop structure decomposition
      subroutine ACWlpd
     O    (iErr,
     O     LPa,
     I     icTGT,  icBAS,  IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(OUT,integer) LPa (*)
      _INTENT(IN, integer) icTGT
      _INTENT(IN, integer) icBAS
      _INTENT(IN, integer) IFPl
c
      integer    NW, LW
      parameter (LW = 64)
      integer    jwlp (3, LW)
      integer    icPRM (LW)
CCC_  - Body
      call ACWlpc
     O    (iErr,
     O     LPa,
     O     icPRM,  JWLP,   NW,  LW,
     I     icTGT,  icBAS,  IFPl)
      RETURN
      END
CCC_ & ACWlpc  ## structure decomposition core
      subroutine ACWlpc
     O    (iErr,
     O     LPa,
     O     icPRM,  JWLP,   NW,  LW,
     I     icTGT,  icBAS,  IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   LPa (*)
      _INTENT(OUT,integer)   icPRM (*)
      _INTENT(OUT,integer)   JWLP (3, *)
      _INTENT(OUT,integer)   NW
      _INTENT(IN, integer)   LW
c
      _INTENT(IN, integer)   icTGT
      _INTENT(IN, integer)   icBAS
      _INTENT(IN, integer)   IFPl
c
      integer    iw, jw
      integer    jj, k
      character  TBS*(32), TGT *(32)
      character  TPR*(32)
      integer    jerr
c
      integer    nchk
      integer    mdim, jcBS (2), kd
#define STT_N 0
#define STT_B 1
#define STT_C 2
#define STT_Z -1
CCC_  - Body
      iErr = 0
      iw = 0
      nw = 0
CCC_   . set initial state
      call ACWtag (jErr, TGT, icTGT)
      call ACWtag (jErr, TBS, icBAS)
c
      iw = iw + 1
      nw = MIN (iw, LW)
      jwlp  (1, iw) = icTGT
      jwlp  (2, iw) = STT_N
      jwlp  (3, iw) = -1
      icPRM (iw)    = 0
c
      DO
         nchk = 0
         jw = 1
         DO
c$$$            write (*, *) nchk, jw
            if (jw.gt.nw) goto 2990
c$$$            write (*, *) 'N0', jw, jwlp (1,jw),jwlp (2,jw), jwlp (3,jw)
            if (jwlp (2, jw).eq.STT_N) then
CC             set coordinate size
               call ACWdim (jErr, Mdim, jwlp (1, jw))
               if (jErr.ne.0) jwlp (2, jw) = STT_Z
               if (jwlp (3, jw).eq.-1) jwlp (3, jw) = Mdim
            endif
c$$$            write (*, *) 'N1', jw, jwlp (1,jw),jwlp (2,jw), jwlp (3,jw)
            if (jwlp (2, jw).eq.STT_N) then
               if (icPRM (jw).eq.0) icPRM (jw) = jwlp (1, jw)
            endif
c$$$            write (*, *) 'N2', jw, jwlp (1,jw),jwlp (2,jw), jwlp (3,jw)
            if (jwlp (2, jw).eq.STT_N) then
CC             root check
               call ACWknd (jerr, KD, jwlp (1, jw))
               if (KD.eq. _KROOT) jwlp (2, jw) = STT_C
            endif
c$$$            write (*, *) 'N3', jw, jwlp (1,jw),jwlp (2,jw), jwlp (3,jw)
            if (jwlp (2, jw).eq.STT_N) then
CC             if base coordinate
               if (jwlp (1, jw) .eq. icBAS) jwlp (2, jw) = STT_B
            endif
c$$$            write (*, *) 'N4', jw, jwlp (1,jw),jwlp (2,jw), jwlp (3,jw)
            if (jwlp (2, jw).eq.STT_N) then
cc             base expansion
               call ACWbsa (jErr, jcBS, jwlp (1, jw))
c$$$               write (*, *) 'N4b', jErr, jcBS (1), jcBS (2)
               jwlp (1, jw) = jcBS (1)
               jwlp (2, jw) = STT_N
CC             keep jwlp (3, jw) at this stage
               Nchk = Nchk + 1
CC             if mixed coordinate
               if (jcBS (2).ne.0) then
CC                clear jwlp (3, jw) only if mixed
                  jwlp (3, jw) = -1
                  icPRM (jw)   = 0
                  do jj = min (nw, lw - 1), jw + 1, -1
                     do k = 1, 3
                        jwlp (k, jj + 1) = jwlp (k, jj)
                     enddo
                     icPRM (jj + 1) = icPRM (jj)
                  enddo
                  jw = jw + 1
                  jwlp (1, jw) = jcBS (2)
                  jwlp (2, jw) = STT_N
                  jwlp (3, jw) = -1
                  icPRM (jw)   = 0
                  Nchk = Nchk + 1
                  nw = nw + 1
               endif
            endif
c$$$            write (*, *) 'N9', jw, jwlp (1,jw),jwlp (2,jw), jwlp (3,jw)
            jw = jw + 1
         ENDDO
 2990    continue
         if (nchk.eq.0) goto 2900
      ENDDO
 2900 continue
CCC_   . check
 101  format ('LOOP ATTR ', A, '[', A, '] ',I3, 3I5, 1x, A)
      if      (COND_N(IFPl)) then
         do jw = 1, nw
            call ACWtag (jErr, TPR, icPRM (jw))
            write (IFPl, 101) _TRIM(TGT), _TRIM(TBS),
     $           jw, jwlp (1, jw), jwlp (2, jw), jwlp (3, jw),
     $           _TRIM(TPR)
         enddo
      else if (COND_S(IFPl)) then
         do jw = 1, nw
            call ACWtag (jErr, TPR, icPRM (jw))
            write (*,   101) _TRIM(TGT), _TRIM(TBS),
     $           jw, jwlp (1, jw), jwlp (2, jw), jwlp (3, jw),
     $           _TRIM(TPR)
         enddo
      endif
CCC_   . finalize
      do jj = 1, 3
         LPa (jj) = 1
      enddo
      jj = 1
      do jw = 1, nw
         if (jwlp (2, jw).eq.STT_B) then
            jj = jj + 1
         endif
         LPa (jj) = LPa (jj) * jwlp (3, jw)
         if (jwlp (2, jw).eq.STT_B) then
            jj = jj + 1
         endif
      enddo
 102  format ('LOOP ATTR FINAL ', A, '[', A, '] ', 3I6)
 103  format ('LOOP ATTR FINAL ', A, '[', A, '] FAILED')
      if (jj.ge.2) then
         if      (COND_N(IFPl)) then
            write (IFPl, 102) _TRIM(TGT), _TRIM(TBS),
     $           (LPa (jj), jj = 1, 3)
         else if (COND_S(IFPl)) then
            write (*,    102) _TRIM(TGT), _TRIM(TBS),
     $           (LPa (jj), jj = 1, 3)
         endif
      else if (icBAS.ne.0) then
         iErr = -1
         if      (COND_N(IFPl)) then
            write (IFPl, 103) _TRIM(TGT), _TRIM(TBS)
         else if (COND_S(IFPl)) then
            write (*,    103) _TRIM(TGT), _TRIM(TBS)
         endif
      endif
c
      RETURN
      END
CCC_ + wrapper to avoid compiler warning
CCC_  & ACWsO1  ## ACWstO wrapper
      subroutine ACWsO1
     O    (iErr,
     I     IV,   Ipos, idC)
CCC_   . Declaration
      implicit none
      _INTENT(OUT,integer)  iErr
      _INTENT(IN, integer)  Ipos
      _INTENT(IN, integer)  IV
      _INTENT(IN, integer)  idC
      integer JV (1)
      JV (1) = IV
      call ACWstO (iErr, JV, 1, Ipos, idC)
      RETURN
      END
CCC_  & ACWgO1  ## ACWgtO wrapper
      subroutine ACWgO1
     O    (iErr, IV,
     I     Ipos, idC)
CCC_   . Declaration
      implicit none
      _INTENT(OUT,integer)  iErr
      _INTENT(OUT,integer)  IV
      _INTENT(IN, integer)  Ipos
      _INTENT(IN, integer)  idC
      integer JV (1)
      call ACWgtO (iErr, JV, 1, Ipos, idC)
      IV = JV (1)
      RETURN
      END
CCC_* [ACF] Functions
CCC_ & ACFmem () ## Arpeggio/Coordinate member function
      integer function ACFmem (Kind)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer) Kind
CCC_  - Body
      if (Kind.eq._KROOT) then
         ACFmem = _MEM_ROOT
      else if (Kind.eq._KEXT) then
         ACFmem = _MEM_EXTD
      else if (Kind.eq._KMIX) then
         ACFmem = _MEM_MIXED
      else if (Kind.eq._KSPL) then
         ACFmem = _MEM_SPLT
      else if (Kind.eq._KOPR) then
         ACFmem = _MEM_OPRD
      else if (Kind.eq._KATTD) then
         ACFmem = _MEM_ATTR
      else if (Kind.eq._KATTI) then
         ACFmem = _MEM_ATTR
      else if (Kind.eq._KVAR) then
         ACFmem = _MEM_VAR
      else
         ACFmem = -1
      endif
      RETURN
      END
CCC_ & ACFnop () ## Arpeggio/Coordinate option function
      integer function ACFnop (Kind, N)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer) Kind
      _INTENT(IN, integer) N
CCC_  - Body
      if (Kind.eq._KROOT) then
         ACFnop = 0
      else if (Kind.eq._KEXT) then
         ACFnop = 0
      else if (Kind.eq._KMIX) then
         ACFnop = 0
      else if (Kind.eq._KSPL) then
         ACFnop = 0
      else if (Kind.eq._KOPR) then
         ACFnop = 0
      else if (Kind.eq._KATTD) then
         ACFnop = 1
      else if (Kind.eq._KATTI) then
         ACFnop = N
      else if (Kind.eq._KVAR) then
         ACFnop = N
      else
         ACFnop = -1
      endif
      RETURN
      END
CCC_ & ACFc2t () ## Arpeggio/Coordinate Coor id to Tag id
      integer function ACFc2t (idC)
      implicit none
      _INTENT(IN, integer) idC
      ACFc2t = - idC
      RETURN
      END
CCC_ & ACFt2c () ## Arpeggio/Coordinate Tag id to Coor id
      integer function ACFt2c (idT)
      implicit none
      integer idT
      ACFt2c = - idT
      RETURN
      END
CCC_* [ACO/T/D/I] Buffer manipulation primitives
CCC_ & ACOmng  ## Arpeggio/Coordinate offset buffer
      subroutine ACOmng (IFPl)
CCC_  - Declaration
      implicit none
CCC_   = Parameter
      integer    Mtag
      parameter (Mtag = OPT_COOR_MAX)
CCC_   = Arguments
      _INTENT(IN,   integer)   IFPl
      _INTENT(OUT,  integer)   iErr
      _INTENT(OUT,  integer)   Jofs
      _INTENT(INOUT,integer)   idT
      _INTENT(IN,   integer)   Iattr  (*), Iatt1I
      _INTENT(OUT,  integer)   IattrO (*), Iatt1O
      _INTENT(IN,   integer)   IchkC  (*)
      _INTENT(IN,   integer)   Ifill
      _INTENT(IN,   integer)   Nattr,  Nopts
      _INTENT(IN,   character) Tag*(*)
      _INTENT(IN,   integer)   Jshf
      _INTENT(OUT,  integer)   IMT, INT, IIT
CCC_   = Configuration
CCC_   = Save
      integer   Ntag,  Itag
      save      Ntag,  Itag
      data      Ntag,  Itag / 0, 0 /
      integer   Soff (Mtag)
      save      Soff
      data      Soff /Mtag * 0/
CCC_   = Interior
      integer   Nbf
      integer   J0
      integer   jA
      logical   Oeqv
      integer   Ibuf (_COOR_BASIC_MAX)
      integer   JVbuf (1)
CCC_  - Body (ACOmng)
 101  format ('ACOMNG = (', I5, I5, ')')
 309  format LOGFMT_INM
      if      (COND_N(IFPl)) then
         write (IFPl, 101) Mtag, Ntag
         write (IFPl, 309)
     $        ITEMS_INM(iTag,nTag,mTag,'ACORMS/O')
      else if (COND_S(IFPl)) then
         write (*,    101) Mtag, Ntag
         write (*,    309)
     $        ITEMS_INM(iTag,nTag,mTag,'ACORMS/O')
      endif
      RETURN
CCC_  & ACOntg  ## Arpeggio/Coordinate offset get ntag info
      entry ACOntg
     O     (IIT, INT, IMT)
      IIT = Itag
      INT = Ntag
      IMT = Mtag
      RETURN
CCC_  & ACOinq  ## Arpeggio/Coordinate offset inquiry
      entry ACOinq
     O     (iErr,  idT,
     I      Iattr, IchkC, Tag,  Nattr)
CCC_   . Description
CC      Iattr (Nattr)  basic attributes to put
CC      IchkC (Nattr)  flag for consistency check
CC
CC      Return idT = 0 if no corresponding coordinate
CCC_   . Initialization
      iErr = 0
      idT  = 0
      do jA = 1, _COOR_BASIC_MAX
         Ibuf (jA) = 0
      enddo
CCC_   . Tag inquire loop
      ITag = 0
      DO
         call ACTinq (iErr, ITag, Tag)
         if (ITag.le.0) goto 200
         J0 = Soff (ITag)
         if (J0.le.0) then
            iErr = _ERR_PANIC
            goto 200
         endif
         call ACIget (iErr, Ibuf, J0, Nattr)
         if (iErr.ne.0) goto 200
         Oeqv = .TRUE.
         do jA = 1, Nattr
            if (IchkC (jA) .eq. _CINQ_CHECK_EQUAL
     $           .and. Ibuf (jA) .ne. Iattr (jA)) Oeqv = .FALSE.
         enddo
         if (Oeqv) goto 200
      ENDDO
 200  continue
CCC_    * done
      if (iErr.eq.0) then
CCC_   . Tag check
         if (ITag.gt.0) then
            Oeqv = .TRUE.
            do jA = 1, Nattr
               if (IchkC (jA) .eq. _CINQ_CHECK_CONSISTENT
     $              .and. Ibuf (jA) .ne. Iattr (jA)) Oeqv = .FALSE.
            enddo
            if (.not.Oeqv) then
               iErr = _ERR_ATTR_INCONSISTENT
            endif
         else
CC  Note: ACTinq return -1 if not found, so ITag must be overwritten
CC        for the upper levels
            ITag = 0
         endif
      endif
CCC_   . post process
      if (iErr.eq.0) idT = ITag
      RETURN
CCC_  & ACOnew  ## Arpeggio/Coordinate offset registration
      entry ACOnew
     O     (iErr,  idT,
     I      Iattr, Tag,  Nattr, Nopts)
CCC_   . Description
CC      Iattr (Nattr)  basic attributes to put
CC      Nopts          optional attributes to put later
CC      Tag            create automatic tag if blank
CCC_   . Initialization
      iErr = 0
      idT  = 0
      Nbf  = Nattr + Nopts
      call ACTrgs (iErr, ITag, Tag)
      if (iErr.eq.0) call ACIalc (iErr, J0,   Nbf)
      if (iErr.eq.0) then
         Ntag = MIN (Itag, Mtag)
         if (Itag.gt.Mtag) iErr = _ERR_TAGID_OVERFLOW
      endif
      if (iErr.eq.0) then
         Soff (ITag) = J0
C           only store Nattr number of members
         call ACIset (iErr, Iattr, J0, Nattr)
      endif
CCC_   . post process
      if (iErr.eq.0) idT = ITag
      RETURN
CCC_  & ACOqof  ## Arpeggio/Coordinate inquiry offset index
      entry ACOqof
     O    (iErr, Jofs,
     I     idT)
      if (idT.le.0 .or. idT.gt.Ntag) then
         iErr = _ERR_TAGID_OVERFLOW
         Jofs = -1
      else
         iErr = 0
         Jofs = Soff (idT)
      endif
      RETURN
CCC_  & ACOget  ## Arpeggio/Coordinate offset get attributes
      entry ACOget
     O     (iErr,  IattrO,
     I      Jshf,  Nattr, idT)
      iErr = 0
      if (idT.le.0 .or. idT.gt.Ntag) then
         iErr = _ERR_TAGID_OVERFLOW
      else
         J0 = Soff (idT)
         if (J0.le.0) iErr = _ERR_PANIC
         if (iErr.eq.0) then
            J0 = J0 + Jshf
            call ACIget (iErr, IattrO, J0, Nattr)
         endif
      endif
c$$$      if (iErr.ne.0) write (*, *) 'CHK OGET', iErr, idT, Ntag
      RETURN
CCC_  & ACOgt1  ## Arpeggio/Coordinate offset get AN attribute
      entry ACOgt1
     O     (iErr,  Iatt1O,
     I      Jshf,  idT)
      iErr = 0
      if (idT.le.0 .or. idT.gt.Ntag) then
         iErr = _ERR_TAGID_OVERFLOW
      else
         J0 = Soff (idT)
         if (J0.le.0) iErr = _ERR_PANIC
         if (iErr.eq.0) then
            J0 = J0 + Jshf
            call ACIget (iErr, JVbuf, J0, 1)
            Iatt1O = JVbuf (1)
         endif
      endif
      RETURN
CCC_  & ACOst1  ## Arpeggio/Coordinate offset set AN attribute
      entry ACOst1
     O    (iErr,
     I     Iatt1I,
     I     Jshf,  idT)
      iErr = 0
      if (idT.le.0 .or. idT.gt.Ntag) then
         iErr = _ERR_TAGID_OVERFLOW
      else
         J0 = Soff (idT)
         if (J0.le.0) iErr = _ERR_PANIC
         if (iErr.eq.0) then
            J0 = J0 + Jshf
            JVbuf (1) = Iatt1I
            call ACIset (iErr, JVbuf, J0, 1)
         endif
      endif
      RETURN
CCC_  & ACOset  ## Arpeggio/Coordinate offset set attributes
      entry ACOset
     O    (iErr,
     I     Iattr,
     I     Jshf,  Nattr, idT)
      iErr = 0
      if (idT.le.0 .or. idT.gt.Ntag) then
         iErr = _ERR_TAGID_OVERFLOW
      else
         J0 = Soff (idT)
         if (J0.le.0) iErr = _ERR_PANIC
         if (iErr.eq.0) then
            J0 = J0 + Jshf
            call ACIset (iErr, Iattr, J0, Nattr)
         endif
      endif
      RETURN
CCC_  & ACOfil  ## Arpeggio/Coordinate offset fill attributes
      entry ACOfil
     O    (iErr,
     I     Ifill,
     I     Jshf,  Nattr, idT)
      iErr = 0
      if (idT.le.0 .or. idT.gt.Ntag) then
         iErr = _ERR_TAGID_OVERFLOW
      else
         J0 = Soff (idT)
         if (J0.le.0) iErr = _ERR_PANIC
         if (iErr.eq.0) then
            J0 = J0 + Jshf
            call ACIfil (iErr, Ifill, J0, Nattr)
         endif
      endif
      RETURN
CCC_  - End (ACOmng)
      END
CCC_ & ACTmng  ## Arpeggio/Coordinate primitive (tag)
      subroutine ACTmng (IFPl)
CCC_  - Declaration
      implicit none
CCC_   = Parameter
#ifndef   OPT_COOR_LEN
#  define OPT_COOR_LEN 32
#endif
      integer    Mtag
      parameter (Mtag  = OPT_COOR_MAX)
      integer    Lcoor
      parameter (Lcoor = OPT_COOR_LEN)
CCC_   = Arguments
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,integer)   idT
      _INTENT(IN,   integer)   IFPl
      _INTENT(IN,   character) TagI*(*)
      _INTENT(OUT,  character) TagO*(*)
CCC_   = Save
      integer   Ntag,  Itag
      save      Ntag,  Itag
      data      Ntag,  Itag / 0, 0 /
      character Stag (Mtag) * (Lcoor)
      save      Stag
CCC_   = Interior
      integer   lTag
      integer   jT
      character TT*(Lcoor)
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
CCC_  - Body (ACTmng)
 101  format ('ACTMNG = (', I5, 1x, I5, 1x, I5, ')')
 309  format LOGFMT_INM
      if      (COND_N(IFPl)) then
         write (IFPl, 101) Mtag, Ntag, Itag
         write (IFPl, 309)
     $        ITEMS_INM(iTag,nTag,mTag,'ACORMS/T')
      else if (COND_S(IFPl)) then
         write (*,    101) Mtag, Ntag, Itag
         write (*,    309)
     $        ITEMS_INM(iTag,nTag,mTag,'ACORMS/T')
      endif
      RETURN
CCC_  & ACTrgs  ## Arpeggio/Coordinate tag registration
CC      create automatic tag if blank
      entry ACTrgs
     O    (iErr, idT,
     I     TagI)
      iErr = 0
      idT  = 0
      Itag = Itag + 1
      Ntag = MIN (Itag, Mtag)
      if (Itag.gt.Mtag) then
         iErr = _ERR_TAGID_OVERFLOW
      else
         idT = Itag
 201     format (COOR_AUTO_PFX, I4.4)
         if (TagI.eq.' ') then
            write (TT, 201) Itag
            Stag (Itag) = TT
         else
            lTag = MIN (len_trim (TagI), Lcoor)
            Stag (Itag) = TagI (1:lTag)
         endif
      endif
      RETURN
CCC_  & ACTget  ## Arpeggio/Coordinate get tag from id
      entry ACTget
     O    (iErr,
     O     TagO,
     I     idT)
      if (idT.le.0 .or. idT.gt.Ntag) then
         iErr = _ERR_TAGID_OVERFLOW
         TagO = '!ERROR'
      else
         TagO = Stag (idT)
      endif
      RETURN
CCC_  & ACTset  ## Arpeggio/Coordinate force set tag from id
      entry ACTset
     O    (iErr,
     I     TagI,
     I     idT)
      if (idT.le.0 .or. idT.gt.Ntag) then
         iErr = _ERR_TAGID_OVERFLOW
      else
         Stag (idT) = TagI
      endif
      RETURN
CCC_  & ACTinq  ## Arpeggio/Coordinate inquire id from tag
CC      set idT as start index - 1  (i.e., 0 if from start)
CC      if not found then idT = -1
      entry ACTinq
     O    (iErr,
     M     idT,
     I     TagI)
      iErr = 0
      if (idT.lt.0) then
         iErr = _ERR_TAGID_OVERFLOW
         RETURN
      endif
      do jT = idT + 1, Ntag
         if (Stag (jT).eq.TagI) then
            idT = jT
            RETURN
         endif
      enddo
      idT = -1
      RETURN
CCC_  - End (ACTmng)
      END
CCC_ & ACDmng  ## Arpeggio/Coordinate attributes primitive (double)
      subroutine ACDmng (IFPl)
CCC_  - Declaration
      implicit none
CCC_   = Parameter
      integer    McaD
      parameter (McaD = OPT_COOR_ATTRD_MAX)
CCC_   = Arguments
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,integer)   J0
      _INTENT(IN,   integer)   Mem
      _INTENT(IN,   _REALSTD)  DVi (Mem)
      _INTENT(OUT,  _REALSTD)  DVo (Mem)
      _INTENT(IN,   integer)   IFPl
c
      _INTENT(IN,   integer)   IRT, KU
      _INTENT(IN,   character) FMT*(*)
      _INTENT(OUT,  integer)   IRN
      _INTENT(INOUT,character) saDV*(*)
      _INTENT(INOUT,integer)   kaDV(*)
      _INTENT(IN,   character) TagS*(*)
CCC_   = Save
      integer   NcaD, IcaD
      save      NcaD, IcaD
      data      NcaD, IcaD / 0, 0 /
c
      _REALSTD  ScaD (McaD)
      save      ScaD
CCC_   = Interior
      integer j
CCC_  - Body (ACDmng)
 101  format ('ACDMNG = (', I7, 1x, I5, 1x, I5, ')')
 309  format LOGFMT_INM
c$$$ 102  format ('ACD', 1x, I5, 1x, E16.9)
      if      (COND_N(IFPl)) then
         write (IFPl, 101) McaD, NcaD, IcaD
         write (IFPl, 309)
     $        ITEMS_INM(icad,ncad,mcad,'ACORMS/D')
      else if (COND_S(IFPl)) then
         write (*,    101) McaD, NcaD, IcaD
         write (*,    309)
     $        ITEMS_INM(icad,ncad,mcad,'ACORMS/D')
      endif
      RETURN
CCC_  & ACDalc  ## Coordinate attribute allocation (double)
      entry ACDalc
     O    (iErr,  J0,
     I     Mem)
      iErr = 0
CCC_   . initial index
      IcaD = IcaD + 1
      NcaD = Min (IcaD, McaD)
      J0   = IcaD
CCC_   . allocate for members
      IcaD = IcaD + Mem - 1
      NcaD = Min (IcaD, McaD)
      do j = J0, NcaD
         ScaD (j) = 0.0d0
      enddo
      if (IcaD.gt.McaD) iErr = _ERR_BUFFER_OVERFLOW
      RETURN
CCC_  & ACDset  ## Coordinate attribute set (double)
      entry ACDset
     O    (iErr,
     I     DVi,   J0,   Mem)
      iErr = 0
      do j = 0, MIN (McaD - J0 + 1, Mem) - 1
         ScaD (J0 + j) = DVi (j + 1)
      enddo
      RETURN
CCC_  & ACDget  ## Coordinate attribute get (double)
      entry ACDget
     O    (iErr, DVo,
     I     J0,   Mem)
      iErr = 0
      do j = 0, MIN (McaD - J0 + 1, Mem) - 1
         DVo (j + 1) = ScaD (J0 + j)
      enddo
      RETURN
CCC_  & ACDget  ## Coordinate attribute send to dv module
      entry ACDsdv
     O    (iErr, IRN,
     I     kaDV, saDV,
     I     IRT,  J0, Mem, KU, FMT, TagS)
      call DVSwtS
     O    (iErr,
     O     IRN,
     M     kaDV, saDV,
     I     IRT,  ScaD (J0), Mem,  KU, FMT, TagS)
      RETURN
CCC_  - End (ACDmng)
      END
CCC_ & ACImng  ## Arpeggio/Coordinate attributes primitive (integer)
      subroutine ACImng (IFPl)
CCC_  - Declaration
      implicit none
CCC_   = Parameter
      integer    McaI
      parameter (McaI = OPT_COOR_ATTRI_MAX)
CCC_   = Arguments
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,integer)   J0
      _INTENT(IN,   integer)   Mem
      _INTENT(IN,   integer)   IV  (Mem)
      _INTENT(OUT,  integer)   IVo (Mem)
      _INTENT(IN,   integer)   Ifill
      _INTENT(IN,   integer)   IFPl
CCC_   = Save
      integer   NcaI, IcaI
      save      NcaI, IcaI
      data      NcaI, IcaI / 0, 0 /
c
      integer   ScaI (McaI)
      save      ScaI
CCC_   = Interior
      integer j
CCC_  - Body (ACImng)
 101  format ('ACIMNG = (', I7, 1x, I5, 1x, I5, ')')
 309  format LOGFMT_INM
      if      (COND_N(IFPl)) then
         write (IFPl, 101) McaI, NcaI, IcaI
         write (IFPl, 309)
     $        ITEMS_INM(icai,ncai,mcai,'ACORMS/I')
      else if (COND_S(IFPl)) then
         write (*,    101) McaI, NcaI, IcaI
         write (*,    309)
     $        ITEMS_INM(icai,ncai,mcai,'ACORMS/I')
      endif
      RETURN
CCC_  & ACIalc  ## Coordinate attribute allocation (integer)
      entry ACIalc
     O    (iErr,  J0,
     I     Mem)
CCC_   . Description
CC    Allocate MEM integer array at the tail of the buffer
CC    Return J0 as the start index
CCC_   . body
      iErr = 0
CCC_   . initial index
      IcaI = IcaI + 1
      NcaI = Min (IcaI, McaI)
      J0   = IcaI
CCC_   . allocate for members
      IcaI = IcaI + Mem - 1
      NcaI = Min (IcaI, McaI)
      do j = J0, NcaI
         ScaI (j) = 0
      enddo
      if (IcaI.gt.McaI) iErr = _ERR_BUFFER_OVERFLOW
      RETURN
CCC_  & ACIset  ## Coordinate attribute set (integer)
      entry ACIset
     O    (iErr,
     I     IV,   J0,   Mem)
CCC_   . Description
CC      Set MEM member of integer from position J0
      iErr = 0
      do j = 0, MIN (McaI - J0 + 1, Mem) - 1
         ScaI (J0 + j) = IV (j + 1)
      enddo
      RETURN
CCC_  & ACIfil  ## Coordinate attribute fill (integer)
      entry ACIfil
     O    (iErr,
     I     Ifill,  J0,   Mem)
CCC_   . Description
CC      Fill MEM member of integer from position J0 as Ifill
      iErr = 0
      do j = 0, MIN (McaI - J0 + 1, Mem) - 1
         ScaI (J0 + j) = Ifill
      enddo
      RETURN
CCC_  & ACIget  ## Coordinate attribute get (integer)
      entry ACIget
     O    (iErr, IVo,
     I     J0,   Mem)
CCC_   . Description
CC      Get MEM member of integer from position J0
      iErr = 0
      do j = 0, MIN (McaI - J0 + 1, Mem) - 1
         IVo (j + 1) = ScaI (J0 + j)
      enddo
      RETURN
CCC_  - End (ACImng)
      END
CCC_* [ACQ] General orthogonal coordinate generation
CCC_* [ACG] Geographic (spherical) coordinate generation
CCC_* [ACU] Misc. utilities
CCC_ & ACUsds  ## system-dependent array size adjustment
      subroutine ACUsds
     O    (iErr, L,
     I     M,    Lref,  T,  IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   L
      _INTENT(IN, integer)   M,  Lref
      _INTENT(IN, character) T*(*)
      _INTENT(IN, integer)   IFPl
      integer LM, LU
      integer jrm
CCC_  - Body
      iErr = 0
      LM   = 0
      LU   = 0
      call DEgetI (jrm, LM, 'SYSTEM_ARRAY_MOD')
      call DEgetI (jrm, LU, 'SYSTEM_ARRAY_UNIT')
      call ACUcsa (iErr, L, M, LM, LU, Lref, T, IFPl)
      RETURN
      END
CCC_ & ACUcsa  ## array size adjustment core
      subroutine ACUcsa
     O    (iErr, L,
     I     M,    LM, LU, Lref, T,  IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   L
      _INTENT(IN, integer)   M,  Lref
      _INTENT(IN, integer)   LM, LU
      _INTENT(IN, character) T*(*)
      _INTENT(IN, integer)   IFPl
CCC_  - Body
      iErr = 0
      L    = 0
c
      if (iErr.eq.0) then
CCC_   . if unit<=0 then just add module
         if (LU.le.0) then
            L = M + MAX (0, LM)
CCC_   . if unit>0 and module>=0 then adjust
         else if (LM.ge.0) then
            L = ((M - 1 - LM) / LU + 1) * LU + LM
CCC_   . if unit>0 and module<0 then just forbid module==0
         else
            L = M
            if (MOD (L, LU).eq.0) L = L + 1
         endif
      endif
CCC_   . check overflow
      if (iErr.eq.0) then
         if (Lref.lt.L) iErr = -9
      endif
CCC_  - report
 101  format ('ACUSDS[', I2, '] ', A,
     $     ' L = ', I7, ' [', I7, I3, I3, I7, ']')
      if      (COND_N(IFPl)) then
         write (IFPl, 101) iErr, _TRIM(T), L, M, LU, LM, Lref
      else if (COND_S(IFPl)) then
#       define  IFPl *
         write (IFPl, 101) iErr, _TRIM(T), L, M, LU, LM, Lref
#       undef   IFPl
      endif
      call DAtrcU (IFPl, iErr, 'R', 'ACUCSA')
      RETURN
      END
CCC_* [ACB] Batch (plane)
CCC_ & ACBnrX  ## H Coordinate/1d registration batch (create)
      subroutine ACBnrX
     O    (iErr,
     O     icXa,  icXb,
     I     CTa,   CTb,
     I     NXa,   MXU,  MX,   LO, IFPl)
CCC_  - Description
CC      NXa original
CC      MXU extended size due to block decompositions (unique)
CC      MX  extended size due to block decompositions (cumulative)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   icXa, icXb
      _INTENT(IN, character) CTa*(*), CTb*(*)
      _INTENT(IN, integer)   NXa,  MXU, MX,  LO
      _INTENT(IN, integer)   IFPl
      integer icU
      integer jcdmy
CCC_  - Body
      iErr = 0
c
      call ACCrgX (iErr, icU,  0,   0,  CTa, IFPl)
      call ACCrgX (iErr, icXa, icU, 0,  ' ', IFPl)
c$$$      call ACCrgX (iErr, icU,  0,   0,  ' ', IFPl)
c$$$      call ACCrgX (iErr, icXa, icU, 0,  ' ', IFPl)
c
      call ACCrgX (iErr, icU,  0,   0,  CTb, IFPl)
      call ACCrgX (iErr, icXb, icU, 0,  ' ', IFPl)
c$$$      call ACCrgX (iErr, icU,  0,   0,  ' ', IFPl)
c$$$      call ACCrgX (iErr, icXb, icU, 0,  ' ', IFPl)
CCC_   . set FN attribute (folding or fan)
      call ACCri1 (iErr, jcdmy, 1, icXa, 'FN', IFPl)
      call ACCri1 (iErr, jcdmy, 1, icXb, 'FN', IFPl)
c
      if (icXa.eq.0 .or. icXb.eq.0) then
         iErr = -1
      else
         call ACBrgX (iErr, icXa, icXb, NXa, MXU, MX, LO, IFPl)
      endif
      RETURN
      END
CCC_ & ACBrgX  ## H Coordinate/1d registration batch
      subroutine ACBrgX
     O    (iErr,
     I     icXa,  icXb,
     I     NXa,   MXU,  MX,   LO, IFPl)
CCC_  - Description
CC      Register [*][ab] coordinates
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   icXa, icXb
      _INTENT(IN, integer)   NXa,  MXU,  MX,  LO
      _INTENT(IN, integer)   IFPl
      integer MUi, NXb, MXi
CCC_  - Body
      iErr  = 0
      MXi   = MX
      if (MXi.le.0) MXi = NXa
      MUi   = MXU
      if (MUi.le.0) MUi = NXa
CCC_   . a
      if (iErr.eq.0) call ACBrcX (iErr, icXa, NXa,  MUi, MXi,   IFPl)
CCC_   . b
      if (iErr.eq.0) then
         if (LO.gt.0) then
            NXb = NXa
         else
            NXb = NXa - 1
         endif
         call ACBrcX (iErr, icXb, NXb,  MUi, MXi,   IFPl)
      endif
      call DAtrcU (IFPl, iErr, 'R', 'ACBRGX')
      RETURN
      END
CCC_ & ACBrcX  ## H Coordinate/1d registration core
      subroutine ACBrcX
     O    (iErr,
     I     icX,
     I     NX,  MXU, MX, IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   icX
      _INTENT(IN, integer)   NX, MXU, MX
      _INTENT(IN, integer)   IFPl
      integer   icN, icB, icU
CCC_  - Body
      iErr  = 0
CCC_   . health check
      if (icX.eq.0) then
         iErr = -1
      else
         icB = 0
         icU = 0
CCC_   . N
         call ACCrgN (iErr, icN, NX, IFPl)
CCC_   . B (base coordinate)
         call ACWbs1 (iErr, icU, icX)
         call ACWbs1 (iErr, icB, icU)
c$$$         write (*, *) 'ACBRCX', icN, icB, icU, icX, MX, MXU, NX
CCC_   . U (extended coordinate physical, unique)
         if (icB.eq.0) then
            call ACWrdm (iErr, icU, icN, MXU, IFPl)
         else
            call ACWrdm (iErr, icB, icN, NX,  IFPl)
            call ACWrdm (iErr, icU, 0,   MXU, IFPl)
         endif
CCC_   . X (extended coordinate logical, cumulative)
         if (icu.eq.0) then
            call ACWrdm (iErr, icX, icN, MX, IFPl)
         else
c$$$            call ACWrdm (iErr, icU, icB, MXU, IFPl)
            call ACWrdm (iErr, icX, 0,   MX, IFPl)
         endif
CCC_   . X attributes (none)
      endif
CCC_   . return
      call DAtrcU (IFPl, iErr, 'R', 'ACBRCX')
      RETURN
      END
CCC_ & ACBnrH  ## Coordinate/Batch Registration/H (create)
      subroutine ACBnrH
     O    (iErr,
     O     icH,
     I     icX, icY, NHG,  NHP,  MHP, LHP, IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   icH
      _INTENT(IN, integer)   icX,  icY
      _INTENT(IN, integer)   NHG,  NHP,  MHP, LHP
      _INTENT(IN, integer)   IFPl
      integer icW, icS
CCC_  - Body
      iErr = 0
      call ACCrgM (iErr, icW,  icX, icY, 0,   ' ', IFPl)
      call ACCrgS (iErr, icS,  icW,      0,   ' ', IFPl)
      call ACCrgX (iErr, icH,  icS,      0,   ' ', IFPl)
      if (icH.eq.0) then
         iErr = -1
      else
         call ACBrgH (iErr, icH, NHG, NHP, MHP, LHP, IFPl)
      endif
      RETURN
      END
CCC_ & ACBrgH  ## Coordinate/Batch Registration/H
      subroutine ACBrgH
     O    (iErr,
     I     icH,
     I     NHG,  NHP,  MHP, LHP, IFPl)
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   icH
      _INTENT(IN, integer)   NHG,  NHP,  MHP, LHP
      _INTENT(IN, integer)   IFPl
CCC_   = Interior
      integer   icX, icY
      integer   icW, icS
      integer   mx,  my
CCC_  - Body
      iErr = 0
      icX  = 0
      icY  = 0
      icW  = 0
      icS  = 0
CCC_   . global/H
      if (icH.eq.0) then
         iErr = -1
      else
         call ACWrdm (iErr, icH, 0, MHP, IFPl)
         if (iErr.eq.0) call ACWbs1 (iErr, icS, icH)
      endif
CCC_   . global/S
      if (icS.eq.0) then
         iErr = -1
      else
         call ACWrdm (iErr, icS, 0, NHP, IFPl)
         if (iErr.eq.0) call ACWbs1 (iErr, icW, icS)
      endif
CCC_   . global/W
      if (icW.eq.0) then
         iErr = -1
      else if (NHG.eq.0) then
         call ACWbs2 (iErr, icX, icY, icW)
         if (icX.ne.0 .and. icY.ne.0) then
            call ACWdim (iErr, mx, icX)
            call ACWdim (iErr, my, icY)
            call ACWrdm (iErr, icW, 0, (mx * my), IFPl)
         endif
      else
         call ACWrdm (iErr, icW, 0, NHG, IFPl)
      endif
 101  format ('ACBRGH: ', 5I5)
      if      (COND_N(IFPl)) then
         write (IFPl, 101) icH, icS, icW, icX, icY
      else if (COND_S(IFPl)) then
         write (*,    101) icH, icS, icW, icX, icY
      endif
c$$$CCC_   . global/L
c$$$      if (icH.ne.0) then
c$$$         call ACUgtg (CTAG, CR,   'L',  CX)
c$$$         call ACCrgX (iErr, icL,  icH,  LHP,  CTAG, IFPl)
c$$$      endif
CCC_   . return
      call DAtrcU (IFPl, iErr, 'R', 'ACBRGH')
      RETURN
      END
CCC_ & ACBrgT  ## Coordinate/Batch Registration/T
      subroutine ACBrgT
     O    (iErr,
     I     icT,
     I     LH,  IFPl)
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   icT
      _INTENT(IN, integer)   LH
      _INTENT(IN, integer)   IFPl
CCC_   = Interior
      integer   icL, icZ
      integer   mz
CCC_  - Body
      iErr = 0
      icL  = 0
      icZ  = 0
CCC_   . global/T
      if (icT.eq.0) then
         iErr = -1
      else
         call ACWbs2 (iErr, icL, icZ, icT)
         if (icL.ne.0 .and. icZ.ne.0) then
            call ACWdim (iErr, mz, icZ)
            call ACWrdm (iErr, icT, 0, (LH * mz), IFPl)
         endif
      endif
CCC_   . global/L
      if (icL.eq.0) then
         iErr = -1
      else
         call ACWrdm (iErr, icL, 0, LH, IFPl)
      endif
 101  format ('ACBRGT: ', 3I5)
      if      (COND_N(IFPl)) then
         write (IFPl, 101) icT, icL, icZ
      else if (COND_S(IFPl)) then
         write (*,    101) icT, icL, icZ
      endif
CCC_   . return
      call DAtrcU (IFPl, iErr, 'R', 'ACBRGT')
      RETURN
      END
CCC_* [ACZ] Batch (overlaid Z)
CCC_ & ACZdcl  ## Coordniate declaration
      subroutine ACZdcl
     O    (iErr,
     O     NZ,    LZ,
     I     NZdef, CR, IFPi, IFPn, IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   NZ,     LZ
c
      _INTENT(IN, integer)   NZdef
      _INTENT(IN, character) CR*(*)
      _INTENT(IN, integer)   IFPi,    IFPn,   IFPl
c
      integer    MaxE
      parameter (MaxE = 3)
      integer    jErrC
      logical    OSET, OEOF
      integer    IOS,  IOSR
c
      character CROOT*(32)
      namelist /NICOOR/ CROOT, NZ, LZ, IOSR
      integer    LVEML
      parameter (LVEML = OPT_NAMELIST_OUTPUT_EMULATION)
CCC_  - Body
      iErr  = 0
c
      jErrC = 0
      OSET  = .false.
      call UUrwnd (IOS, IFPi)
      DO
         CROOT = ' '
         NZ    = NZdef
         LZ    = 0
         if (IOS .eq. 0) then
            if (IFPi.ge.0) then
               read (IFPi, NICOOR, IOSTAT = IOS)
            else if (IFPi.eq.-1) then
               read (*,    NICOOR, IOSTAT = IOS)
            else
               OSET = .true.
               goto 900
            endif
         endif
         if (IOS.eq.0) then
            if (CROOT.eq.CR) then
               OSET = .true.
               goto 900
            endif
         else
            call UUieof (OEOF, IOS)
            if (OEOF) goto 900
            jErrC = jErrC + 1
            if (jErrC.gt.MaxE) goto 900
         endif
      ENDDO
 900  continue
CCC_   . result
      CROOT = CR
      IOSR  = IOS
      if (.not.OSET) then
         NZ = NZdef
         LZ = 0
      endif
      if (LVEML.gt.0) then
         call UNBbgn (iErr, 'NICOOR',       IFPn, LVEML)
         call UNBint (iErr, 'IOSR',  IOSR,  IFPn, LVEML)
         call UNBstr (iErr, 'CROOT', CROOT, IFPn, LVEML)
         call UNBint (iErr, 'NZ',    NZ,    IFPn, LVEML)
         call UNBint (iErr, 'LZ',    LZ,    IFPn, LVEML)
         call UNBend (iErr, 'NICOOR',       IFPn, LVEML)
      else
         if (COND_N(IFPn)) then
            write (IFPn, NICOOR)
         else if (COND_S(IFPn)) then
            write (*,    NICOOR)
         endif
      endif
c
      call DAtrcU (IFPl, iErr, 'R', 'ACZDCL')
      RETURN
      END
CCC_ & ACZreg  ## Z Coordinate registration batch
      subroutine ACZreg
     O    (iErr,
     I     icZa,  icZb,
     I     NZa,   IZB,  IZT, IFPl)
CCC_  - Description
CC      Register [BZ][ab] coordinates
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   icZa, icZb
      _INTENT(IN, integer)   NZa,  IZB, IZT
      _INTENT(IN, integer)   IFPl
CCC_  - Body
      iErr  = 0
      if (iErr.eq.0) call ACZrgc (iErr, icZa, NZa,     IZB, IZT, IFPl)
      if (iErr.eq.0) call ACZrgc (iErr, icZb, NZa - 1, IZB, IZT, IFPl)
      call DAtrcU (IFPl, iErr, 'R', 'ACZREG')
      RETURN
      END
CCC_ & ACZrgc  ## Z Coordinate registration core
      subroutine ACZrgc
     O    (iErr,
     I     icZ,
     I     NZ,   IZB,  IZT, IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   icZ
      _INTENT(IN, integer)   NZ, IZB, IZT
      _INTENT(IN, integer)   IFPl
      integer   icN, icB
      integer   jcdmy
      integer   NZX
      integer   IV (2), Mdim
CCC_  - Body
      iErr  = 0
CCC_   . health check
      if (icZ.eq.0) then
         iErr = -1
      else
         NZX   = NZ + IZB + IZT
         icB   = 0
CCC_   . N
         call ACCrgN (iErr, icN, NZ, IFPl)
CCC_   . B (base coordinate)
         call ACWbs1 (iErr, icB, icZ)
CCC_   . Z (extended coordinate)
         if (icB.eq.0) then
            call ACWrdm (iErr, icZ, icN, NZX, IFPl)
         else
            call ACWrdm (iErr, icB, icN, NZ,  IFPl)
            call ACWrdm (iErr, icZ, 0,   NZX, IFPl)
         endif
CCC_   . Z attributes
         Mdim   = 2
         IV (1) = IZB
         IV (2) = IZT
         call ACCrgI (iErr, jcdmy, IV, icZ,  Mdim, 'XT', IFPl)
      endif
CCC_   . return
      if (icZ.eq.0) then
         iErr = -1
      else
         iErr = 0
      endif
      call DAtrcU (IFPl, iErr, 'R', 'ACZRGC')
      RETURN
      END
CCC_& ACORMS  ## Arpeggio/Coordinate announcement
      subroutine ACORMS (STRA, STRB, IOP)
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
         STRA = 'OPT_COOR_MAX'
         write (STRB, *) OPT_COOR_MAX
      else if (IOP.eq.4) then
         STRA = 'OPT_COOR_ATTRD_MAX'
         write (STRB, *) OPT_COOR_ATTRD_MAX
      else if (IOP.eq.5) then
         STRA = 'OPT_COOR_ATTRI_MAX'
         write (STRB, *) OPT_COOR_ATTRI_MAX
      else if (IOP.eq.6) then
         STRA = 'TEST_ACORMS'
         write (STRB, *) TEST_ACORMS
      else if (IOP.eq.7) then
         STRA = 'OPT_COOR_LEN'
         write (STRB, *) OPT_COOR_LEN
      else
         STRA = ' '
         STRB = ' '
      endif
      RETURN
      END
CCC_@ ACTEST  ## ACORMS test program
#if TEST_ACORMS
#include "ofnstd.h"
CCC_ + Test suites
      program ACTEST
CCC_ + Declaration
      implicit none
c
      integer iErr, jErr
c
      integer    idN,  idNe, idNm, idNd
      integer    idX,  idY,  idZ,  idXerr
      integer    idXe, idYe, idZe, idXne, idXeq
      integer    idXY
      integer    idHd, idH,  idHnd, idT
      integer    idOH
      integer    ivA1, ivA2, ivA3
c
      integer    MX0
      parameter (MX0 = 32)
      integer    IX0 (MX0), JX0 (MX0)
c
      integer    MZ
      parameter (MZ = 128)
      integer    IZ (MZ),   JZ (MZ)
c
      integer    MD
      parameter (MD=64)
      _REALSTD   DH (MD),   EH (MD)
c
      integer   ipA (LOG_CHANNEL_MAX)
      integer   ipL
c
      integer   l, j, k
      integer   jcdmy
c
      integer   NZ, IZB, IZT
c
      integer   icB
      integer   icX, icY, icW, icS, icH, icZ, icT, icQ, icV, icU
c
      integer   inA, inB, inC
c
      integer   LPa (3)
c
      integer   MCH,  LCH
      integer   LMOD, LUNT, LREF
c
      integer   ITEST
CCC_ + Body
      iErr  = 0
      iTEST = 0
CCC_  - preparation
      call DDsmpl (iErr)
      if (iErr.ne.0) then
         call DevFin (iErr)
         stop
      endif
c
      call DLCmng (ipA, 't')
      ipL = FPL(ipA)
      call UDTbni (ITEST, 'START', ' ', ipL)
CCC_  - registration tests
CCC_   . R (root)
      call UDTbni (ITEST, 'REG/R', ' ', ipL)
      call ACCrgR (iErr, idX,    11,              'M11',   ipL)
      call ACCrgR (iErr, idXerr, 21,              'M11',   ipL)
      call ACCrgR (iErr, idY,    11,              'M11',   ipL)
      call ACCrgR (iErr, idZ,    5,               'M5',    ipL)
CCC_   . X (extended)
      call UDTbni (ITEST, 'REG/X', ' ', ipL)
      call ACCrgX (iErr, idXe,   idX,        13,  'XICE',  ipL)
      call ACCrgX (iErr, idYe,   idY,        12,  'YICE',  ipL)
      call ACCrgX (iErr, idZe,   idZ,        5,   'ZICE',  ipL)
      call ACCrgX (iErr, idXne,  idX,        3,   'NXICE', ipL)
      call ACCrgX (iErr, idXeq,  idX,        -1,  'EXICE', ipL)
CCC_   . M (mixed)
      call UDTbni (ITEST, 'REG/M', ' ', ipL)
      call ACCrgM (iErr, idXY,   idXe, idYe, -1,  'XYICE', ipL)
CCC_   . S (splitted)
      call UDTbni (ITEST, 'REG/S', ' ', ipL)
      call ACCrgS (iErr, idHd,   idXY,       30,  'HSPL',  ipL)
      call ACCrgS (iErr, idHnd,  idXY,       -1,  'NHSPL', ipL)
CCC_   . H-T procedures
      call UDTbni (ITEST, 'REG/HT', ' ', ipL)
      call ACCrgX (iErr, idH,    idHd,       33,  'HICE',  ipL)
      call ACCrgM (iErr, idT,    idH,  idZe, -1,  'TICE',  ipL)
CCC_   . O (operated)
      call UDTbni (ITEST, 'REG/O', ' ', ipL)
      call ACCrgO (iErr, idOH,   idH,        3,   'HOPR',  ipL)
CCC_   . N (number) - X - M - S
      call UDTbni (ITEST, 'REG/NXMS', ' ', ipL)
      call ACCrgN (iErr, idN,    2,                       ipL)
      call ACCrgX (iErr, idNe,   idN,        4,   'NN',   ipL)
c
      call ACCrgM (iErr, idNm,   idN, idXe,  -1,  'NM',   ipL)
      call ACCrgS (iErr, idNd,   idN,        1,   'ND',   ipL)
CCC_   . D attributes
      call UDTbni (ITEST, 'REG/D', ' ', ipL)
      do l = 1, MD
         DH (l) = DBLE (l)
         EH (l) = 0.0d0
      enddo
      call ACCrgD (iErr, jcdmy, DH,  idH, MD,  'V',  ipL)
      call ACCrgD (iErr, jcdmy, DH,  idH, MD,  'VD', ipL)
CCC_   . I attributes
      call UDTbni (ITEST, 'REG/I', ' ', ipL)
      do l = 1, MX0
         IX0 (l) = l * l
         JX0 (l) = 0
      enddo
      call ACCrgI (iErr, jcdmy, IX0, idXe, MX0, 'AX0', ipL)
c
      call ACCrgI (iErr, jcdmy, IX0, idXe, MX0, 'V',   ipL)
      call ACCrgI (iErr, jcdmy, IX0, idYe, 1,   'V',   ipL)
c
      do l = 1, MZ
         IZ (l) = MOD (l, 7)
         JZ (l) = -1
      enddo
      call ACCrgI (iErr, jcdmy, IZ,  idZe, MZ,   'Z', ipL)
CCC_   . V attributes
      call UDTbni (ITEST, 'REG/V', ' ', ipL)
      call ACCrgV (iErr, ivA1, -1,  idH,  1,    'V', ipL)
      call ACCrgV (iErr, ivA2, -1,  idH,  2,    'A', ipL)
      call ACCrgV (iErr, ivA3, -1,  idN,  3,    'A', ipL)
c
      call ACCsV1 (iErr, 987, 0, ivA1, ipL)
      call ACCsV1 (iErr, 654, 1, ivA2, ipL)
      call ACCsV1 (iErr, 321, 2, ivA3, ipL)
CCC_  - reference tests
      call UDTbni (ITEST, 'REF', ' ', ipL)
CCC_   . I attributes a
      call UDTbni (ITEST, 'REF/I/AX0', ' ', ipL)
      call ACCrfI
     $     (iErr, jcdmy, JX0, idXe, MAX (MX0 - 10, 10), 'AX0', ipL)
      call UDAtii ('AX0', IX0, JX0, MX0, ipL)
CCC_   . I attributes b
      call UDTbni (ITEST, 'REF/I/Z', ' ', ipL)
      call ACCrfI (iErr, jcdmy, JZ,  idZe, MZ,   'Z', ipL)
      call UDAtii ('Z',  IZ, JZ, MZ, ipL)
CCC_   . D attributes
      call UDTbni (ITEST, 'REF/D/VD', ' ', ipL)
      call ACCrfD (iErr, jcdmy, EH,  idH, MD,  'VD', ipL)
      call UDAtss ('VD',  DH, EH, MD, ipL)
CCC_  - Null base test
      call UDTbni (ITEST, 'NULL-BASE', ' ', ipL)
      call ACCrgX (jErr, inA, 0,   0, 'Null:A', ipL)
      call ACCrgX (jErr, inB, inA, 0, 'Null:B', ipL)
      call ACCrgX (jErr, inC, inB, 0, 'Null:C', ipL)
      call ACWrdm (jErr, inA, 10,  13, ipL)
      call ACWrdm (jErr, inB, 0,   15, ipL)
      call ACWrdm (jErr, inC, 0,   17, ipL)
CCC_  - Null name test
      call UDTbni (ITEST, 'NULL-NAME', ' ', ipL)
      call ACCrgX (jErr, inA, 0,   0, ' ', ipL)
      call ACCrgX (jErr, inB, inA, 0, ' ', ipL)
      call ACCrgM (iErr, inC, inA, inB,  -1,  ' ',   ipL)
CCC_  - ACZ
      call UDTbni (ITEST, 'ACZ', ' ', ipL)
      NZ  = 16
      IZB = 2
      IZT = 1
      call ACCrgX (jErr, icB, 0,   0, 'IZ.B', ipL)
      call ACCrgX (jErr, icZ, icB, 0, 'IZ.Z', ipL)
      call ACZrgc (jErr, icZ, NZ,  IZB,  IZT, ipL)
CCC_  - ACB 1
      call UDTbni (ITEST, 'ACB1', ' ', ipL)
      call ACCrgX (jErr, icX, 0,  0,  'IX', ipL)
      call ACBrcX (jErr, icX, 13, 15, 17, ipL)
CCC_  - ACB 2
      call UDTbni (ITEST, 'ACB2', ' ', ipL)
      call ACCrgX (jErr, icX, 0,        0,  'IHX', ipL)
      call ACCrgX (jErr, icY, 0,        0,  'IHY', ipL)
      call ACCrgM (jErr, icW, icX, icY, 0,  'IHW', ipL)
      call ACCrgS (jErr, icS, icW,      0,  'IHS', ipL)
      call ACCrgX (jErr, icH, icS,      0,  'IHH', ipL)
      call ACBrgH (jErr, icH, 31, 10, 13, 14, ipL)
CCC_  - recursive two-base
      call UDTbni (ITEST, 'RB2', ' ', ipL)
      call ACWrb2 (jErr, icX, icY, idOH)
      write (*, *) idOH, icX, icY, jErr
      call ACWrb2 (jErr, icX, icY, idXe)
      write (*, *) idXe, icX, icY, jErr
CCC_  - Loop check
      call UDTbni (ITEST, 'LOOP', ' ', ipL)
      call ACCrgX (jErr, icX, 5,        -1,  'ID.Xa', ipL)
      call ACCrgX (jErr, icY, 6,        -1,  'ID.Ya', ipL)
      call ACCrgX (jErr, icZ, 7,        11,  'ID.Za', ipL)
      call ACCrgM (jErr, icW, icX, icY, -1,  'ID.Wa', ipL)
      call ACCrgS (jErr, icS, icW,      -1,  'ID.Sa', ipL)
      call ACCrgX (jErr, icH, icS,      -1,  'ID.Ha', ipL)
      call ACCrgM (jErr, icT, icH, icZ, -1,  'ID.Ta', ipL)
      call ACCrgM (jErr, icQ, icZ, icH, -1,  'ID.Qa', ipL)
      call ACCrgM (jErr, icV, icZ, icQ, -1,  'ID.Va', ipL)
      call ACCrgM (jErr, icU, icZ, icT, -1,  'ID.Ua', ipL)
c
c$$$      call ACWlpd (iErr, LPa, icT,  'ID', 'H', ipL)
c$$$      call ACWlpd (iErr, LPa, icQ,  'ID', 'H', ipL)
c$$$      call ACWlpd (iErr, LPa, icV,  'ID', 'H', ipL)
c$$$      call ACWlpd (iErr, LPa, icU,  'ID', 'H', ipL)
      call ACWlpd (jErr, LPa, icT,  icH, ipL)
      call ACWlpd (jErr, LPa, icQ,  icH, ipL)
      call ACWlpd (jErr, LPa, icV,  icH, ipL)
      call ACWlpd (jErr, LPa, icU,  icH, ipL)
      call ACWlpd (jErr, LPa, icH,  icH, ipL)
      call ACWlpd (jErr, LPa, icX,  icH, ipL)
c
      call ACWlpd (jErr, LPa, icQ,  0,   ipL)
      call ACWlpd (jErr, LPa, icT,  0,   ipL)
      call ACWlpd (jErr, LPa, icU,  0,   ipL)
      call ACWlpd (jErr, LPa, icV,  0,   ipL)
CCC_  - CSA
      call UDTbni (ITEST, 'LADJ', ' ', ipL)
      LREF = 15
      LUNT = 5
      do k = -1, 4
         LMOD = k
         do j = 2, 17
            MCH = j
            call ACUcsa
     $           (jErr, LCH, MCH, LMOD, LUNT, LREF, 'LADJ', ipL)
         enddo
      enddo
CCC_   . need reset
      iErr = 0
CCC_  - End
      call UDTbni (ITEST, 'END', ' ', ipl)
c
      call ACCrep (ipL, 2)
      call DevFin (iErr)
      STOP
      END
#endif /* TEST_ACORMS */
CCC_* obsolete
CCC_ + begin
#if 0 /* obsolete */
CCC_ + end
#endif /* 0 obsolete */
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
