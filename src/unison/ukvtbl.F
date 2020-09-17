C unison/ukvtbl.F --- IcIES/Unison/Kev-Value table manipulation
C Maintainer:  SAITO Fuyuki
C Created: Apr 16 2012
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2016/01/08 10:26:08 fuyuki ukvtbl.F>'
#define _FNAME 'unison/ukvtbl.F'
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
#include "ofdlct.h" /* fortran dialect */
#include "ologfm.h" /* logging */
CCC_* Macros
CCC_* [UKA]  ## allocation
CCC_ & UKAnaA  ## allocation tag:a n times
      subroutine UKAnaA
     M    (Tag,  NTag,
     I     LTag, K0,  XTag, NC)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)    NC
      _INTENT(IN,   integer)    LTag, K0
      _INTENT(INOUT,integer)    NTag
      _INTENT(INOUT,character)  Tag (K0:LTag)*(*)
      _INTENT(IN,   character)  XTag*(*)
      integer ML
      integer j
CCC_  - Body
      ML = MAX (0, LTag - NTag)
      do j = 1, MIN (ML, NC)
         Tag (j + NTag) = XTag
      enddo
      NTag = NTag + NC
      RETURN
      END
CCC_ & UKAstA  ## search or allocation tag:a
      subroutine UKAstA
     O    (ID,
     M     Tag,  NTag,
     I     LTag, K0,  XTag)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)    ID
      _INTENT(IN,   integer)    LTag, K0
      _INTENT(INOUT,integer)    NTag
      _INTENT(INOUT,character)  Tag (K0:LTag)*(*)
      _INTENT(IN,   character)  XTag*(*)
CCC_  - Body
      call UKStgA (ID, Tag, NTag, LTag, K0, XTag)
      if (ID.lt.K0) then
         NTag = NTag + 1
         ID   = NTag
         if (ID.le.LTag) Tag (ID) = XTag
      endif
      RETURN
      END
CCC_ & UKAsvA  ## search or allocation tag/value:a
      subroutine UKAsvA
     O    (ID,
     M     Tag,  Val, NTag,
     I     LTag, K0,  XTag,  XVal)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)    ID
      _INTENT(IN,   integer)    LTag, K0
      _INTENT(INOUT,integer)    NTag
      _INTENT(INOUT,character)  Tag (K0:LTag)*(*)
      _INTENT(INOUT,character)  Val (K0:LTag)*(*)
      _INTENT(IN,   character)  XTag*(*), XVal*(*)
CCC_  - Body
      call UKAstA (ID, Tag, NTag, LTag, K0, XTag)
      if ((ID.ge.K0).and.(ID.le.LTag)) Val (ID) = XVal
      RETURN
      END
CCC_* [UKS]  ## search
CCC_ & UKScoA  ## count tag:a
      subroutine UKScoA
     O     (NC,
     I      Tag, NTag, LTag, K0, XTag)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)    NC
      _INTENT(IN, integer)    NTag, LTag, K0
      _INTENT(IN, character)  Tag (K0:LTag)*(*)
      _INTENT(IN, character)  XTag*(*)
      integer    j
CCC_  - Body
      NC = 0
      do j = K0, MIN (NTag, LTag)
         if (Tag (j) .eq. XTag) NC = NC + 1
      enddo
      RETURN
      END
CCC_ & UKStgA  ## search tag:a
      subroutine UKStgA
     O     (ID,
     I      Tag, NTag, LTag, K0, XTag)
CCC_  - Description
CC        Search XTag in Tag(*) and return its ID
CC        Return (K0 - 1) if not found
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)    ID
      _INTENT(IN, integer)    NTag, LTag, K0
      _INTENT(IN, character)  Tag (K0:LTag)*(*)
      _INTENT(IN, character)  XTag*(*)
      integer    j
CCC_  - Body
      ID = K0 - 1
      do j = K0, MIN (NTag, LTag)
         if (Tag (j) .eq. XTag) then
            ID = j
            goto 100
         endif
      enddo
 100  continue
      RETURN
      END
CCC_ & UKSitA  ## search tag:a (with index)
      subroutine UKSitA
     O     (ID,
     I      Tag, NTag, LTag, K0, XTag, NC)
CCC_  - Description
CC        Search NC-th XTag in Tag(*) and return its ID
CC        Return (K0 - 1) if not found
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)    ID
      _INTENT(IN, integer)    NTag, LTag, K0
      _INTENT(IN, character)  Tag (K0:LTag)*(*)
      _INTENT(IN, character)  XTag*(*)
      _INTENT(IN, integer)    NC
      integer    j, jc
CCC_  - Body
      ID = K0 - 1
      jc = 0
      do j = K0, MIN (NTag, LTag)
         if (Tag (j) .eq. XTag)  jc = jc + 1
         if (jc.eq.NC) then
            ID = j
            goto 100
         endif
      enddo
 100  continue
      RETURN
      END
CCC_* [UKD]  ## diag
CCC_ & UKDk0a  ## diag (key:a only)
      subroutine UKDk0a
     O    (iErr,
     I     Tag, NTag, LTag, K0,
     I     PFX, IFP)
      implicit none
      _INTENT(OUT,integer)    iErr
      _INTENT(IN, integer)    NTag, LTag, K0
      _INTENT(IN, character)  Tag (K0:LTag)*(*)
      _INTENT(IN, character)  PFX*(*)
      _INTENT(IN, integer)    IFP
      integer j
      iErr = 0
 101  format ('UKD:', A, ': ', I0, 1x, I0)
 102  format (2x, I0, 1x, A, ':-')
 109  format ('UKD:', A, ': DONE')
      if (COND_N(IFP)) then
         write (IFP, 101) _TRIM(PFX), NTag, LTag
         do j = K0, MIN (NTag, LTag)
            write (IFP, 102)
     $           j, _TRIM(Tag(j))
         enddo
         write (IFP, 109) _TRIM(PFX)
      else if (COND_S(IFP)) then
#        define IFP *
         write (IFP, 101) _TRIM(PFX), NTag, LTag
         do j = K0, MIN (NTag, LTag)
            write (IFP, 102)
     $           j, _TRIM(Tag(j))
         enddo
         write (IFP, 109) _TRIM(PFX)
#        undef IFP
      endif
      RETURN
      END
CCC_ & UKDkaa  ## diag (key:a value:a)
      subroutine UKDkaa
     O    (iErr,
     I     Tag, NTag, LTag, K0,
     I     Val, PFX,  IFP)
      implicit none
      _INTENT(OUT,integer)    iErr
      _INTENT(IN, integer)    NTag, LTag, K0
      _INTENT(IN, character)  Tag (K0:LTag)*(*)
      _INTENT(IN, character)  Val (K0:LTag)*(*)
      _INTENT(IN, character)  PFX*(*)
      _INTENT(IN, integer)    IFP
      integer j
      iErr = 0
 101  format ('UKD:', A, ': ', I0, 1x, I0)
 102  format (2x, I0, 1x, A, ': ', A, '/')
 109  format ('UKD:', A, ': DONE')
      if (COND_N(IFP)) then
         write (IFP, 101) _TRIM(PFX), NTag, LTag
         do j = K0, MIN (NTag, LTag)
            write (IFP, 102)
     $           j, _TRIM(Tag(j)), _TRIM(Val(j))
         enddo
         write (IFP, 109) _TRIM(PFX)
      else if (COND_S(IFP)) then
#        define IFP *
         write (IFP, 101) _TRIM(PFX), NTag, LTag
         do j = K0, MIN (NTag, LTag)
            write (IFP, 102)
     $           j, _TRIM(Tag(j)), _TRIM(Val(j))
         enddo
         write (IFP, 109) _TRIM(PFX)
#        undef IFP
      endif
      RETURN
      END
CCC_& UKVTBL  ## IcIES/Unison/Key-Value table announcement
      subroutine UKVTBL (STRA, STRB, IOP)
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
#ifdef TEST_UKVTBL
CCC_ @ UKtest  ## UKVTBL test
      program UKtest
CCC_  - Declaration
      implicit none
CCC_  - Body
      STOP
      END
CCC_ + END
#endif /* TEST_UKVTBL */
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
