C development/denvms.F --- IcIES/Development/Environment manipulation
C Maintainer:  SAITO Fuyuki
C Created: Mar  4 2010
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2020/09/17 08:42:43 fuyuki denvms.F>'
#define _FNAME 'development/denvms.F'
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
CCC_* User interfaces
CC      DEput{I,D,A} (L,V,E) : put {integer,double,string}
CC      DEget{I,D,A} (L,V,E) : get {integer,double,string}
CC      put/get V as contents of E, return L=0 if success
CCC_* Limitation
CC
CC  I know the algorithm of these procedures is not good.
CC  Do not use nor depend too much on these.
CC
CC  Now actual environment variables may not affect the content
CC  managed in these procedures.  This function is left for
CC  future development.
CC
CCC_* Design notes
CC    Environment names and contents are stored as follows
CC     E0     V0a
CC     E1     V1
CC     E0     V0b
CC     E0     V0c
CC     blank  blank
CC     E2     V2
CC     :      :
CC        V0 = V0a + V0b + V0c
CCC_* Macros
#include "ofdlct.h" /* fortran dialect */
#include "ologfm.h" /* logging */
CCC_ + Test configuration
#ifdef TEST_DENVMS /* short length, storage for test */
#  define OPT_DENVMS_VAR_LEN 4
#  define OPT_DENVMS_STR_LEN 16
#  define OPT_DENVMS_ENV_MAX 12
#endif
CCC_ + Default configuration
#ifndef   OPT_DENVMS_VAR_LEN
#  define OPT_DENVMS_VAR_LEN 48
#endif
#ifndef   OPT_DENVMS_STR_LEN
#  define OPT_DENVMS_STR_LEN 128
#endif
#ifndef   OPT_DENVMS_BUFFER_LEN
#  define OPT_DENVMS_BUFFER_LEN (OPT_DENVMS_STR_LEN * 5)
#endif
#ifndef   OPT_DENVMS_ENV_MAX
#  define OPT_DENVMS_ENV_MAX 128
#endif
#ifndef   OPT_ENV_PREFIX
#  define OPT_ENV_PREFIX 'ENV_'
#endif
CCC_ + Environment
#ifndef   ENV_NULLIFY
#  define ENV_NULLIFY 'NULL'
#endif
#ifndef   ENV_TERMINATOR
#  define ENV_TERMINATOR '##'
#endif
CCC_* Predefined environment
#define _ENV_TREE_ID 'TREE_ID'
CCC_ & DEPtid  ## Put source-tree ID
      subroutine DEPtid (iErr, A)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, character) A*(*)
      call DEputA (iErr, A, _ENV_TREE_ID)
      RETURN
      END
CCC_ & DEGtid  ## Get source-tree ID
      subroutine DEGtid (iErr, A)
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,character) A*(*)
      call DEgetA (iErr, A, _ENV_TREE_ID)
      RETURN
      END
CCC_* Entries for String
CCC_ & DEmngr  ## Development/Environment manager
      subroutine DEmngr (iErr)
CCC_  - Declaration
      implicit none
CCC_   = Parameter
      character  ENull*(*)
      parameter (ENull = 'NULLIFY')
      character  Eterm*(*)
      parameter (Eterm = 'TERMINATOR')
c$$$      character  Epfx*(*)
c$$$      parameter (Epfx = OPT_ENV_PREFIX)
      integer    Lbuf
      parameter (Lbuf = OPT_DENVMS_BUFFER_LEN)
CCC_   = Arguments
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, character) E*(*)
      _INTENT(OUT,character) AVo*(*)
      _INTENT(IN, character) AVi*(*)
      _INTENT(OUT,integer)   Lrm
CCC_   = Save
      character  Vnull*(Lbuf)
      data       Vnull  /ENV_NULLIFY/
      save       Vnull
      character  Vterm*(Lbuf)
      data       Vterm  /ENV_TERMINATOR/
      save       Vterm
      logical    OFIRST
      data       OFIRST /.true./
      save       OFIRST
CCC_   = Interior
      character  WV*(Lbuf)
CCC_  - Body (DEmngr)
      iErr = 0
      RETURN
CCC_  & DEgetA  ## Development/Environment getenv (string)
      entry DEgetA (Lrm, AVo, E)
      Lrm  = 0
CCC_   . initialization (nullify special)
      if (OFIRST) then
         call DEspcl (Lrm, Vnull, Vterm, Enull, Eterm)
         OFIRST = .false.
      endif
CCC_   . get and put
      if (Lrm.ge.0) then
         call DEgetP (Lrm, AVo, E, Vnull, Vterm)
      endif
      RETURN
CCC_  & DEputA  ## Development/Environment putenv (string)
      entry DEputA (Lrm, AVi, E)
      Lrm = 0
CCC_   . initialization (nullify special)
      if (OFIRST) then
         call DEspcl (Lrm, Vnull, Vterm, Enull, Eterm)
         OFIRST = .false.
      endif
CCC_   . put and get
      if (Lrm.ge.0) then
         call DEputG (Lrm, WV, AVi, E, Vnull, Vterm)
      endif
      return
      END
CCC_* Entries for Numbers
CCC_ + with format argument
CCC_  & DEgtFI  ## Development/Environment getenv (integer, format)
      subroutine DEgtFI (Lrm, IV, E, F)
CCC_   . Declaration
      implicit none
CCC_    = Arguments
      _INTENT(OUT,integer)   Lrm
      _INTENT(OUT,integer)   IV
      _INTENT(IN, character) E*(*)
      _INTENT(IN, character) F*(*)
CCC_    = Interior
      character W*(OPT_DENVMS_BUFFER_LEN)
      integer   lw
CCC_    = Functions
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
CCC_   . Body
      call DEgetA (Lrm, W, E)
      if (Lrm.ge.0) then
         lw = len_trim (W)
         if (lw.gt.0) then
            if (F.eq.' ') then
               read (W, *) IV
            else
               read (W, F) IV
            endif
         endif
      endif
      RETURN
      END
CCC_  & DEgtFD  ## Development/Environment getenv (double, format)
      subroutine DEgtFD (Lrm, DV, E, F)
CCC_   . Declaration
      implicit none
CCC_    = Arguments
      _INTENT(OUT,integer)   Lrm
      _INTENT(OUT,_REALD)    DV
      _INTENT(IN, character) E*(*)
      _INTENT(IN, character) F*(*)
CCC_    = Interior
      character W*(OPT_DENVMS_BUFFER_LEN)
      integer   lw
CCC_    = Functions
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
CCC_   . Body
      call DEgetA (Lrm, W, E)
      if (Lrm.eq.0) then
         lw = len_trim (W)
         if (lw.gt.0) then
            if (F.eq.' ') then
               read (W, *) DV
            else
               read (W, F) DV
            endif
         endif
      endif
      RETURN
      END
CCC_  & DEptFI  ## Development/Environment putenv (integer, format)
      subroutine DEptFI (Lrm, IV, E, F)
CCC_   . Declaration
      implicit none
CCC_    = Arguments
      _INTENT(OUT,integer)   Lrm
      _INTENT(IN, integer)   IV
      _INTENT(IN, character) E*(*)
      _INTENT(IN, character) F*(*)
CCC_    = Interior
      character W*(OPT_DENVMS_BUFFER_LEN)
CCC_   . Body
      if (F.eq.' ') then
         write (W, *) IV
      else
         write (W, F) IV
      endif
      call DEputA (Lrm, W, E)
      RETURN
      END
CCC_  & DEptFD  ## Development/Environment putenv (double, format)
      subroutine DEptFD (Lrm, DV, E, F)
CCC_   . Declaration
      implicit none
CCC_    = Arguments
      _INTENT(OUT,integer)   Lrm
      _INTENT(IN, _REALD)    DV
      _INTENT(IN, character) E*(*)
      _INTENT(IN, character) F*(*)
CCC_    = Interior
      character W*(OPT_DENVMS_BUFFER_LEN)
CCC_   . Body
      if (F.eq.' ') then
         write (W, *) DV
      else
         write (W, F) DV
      endif
      call DEputA (Lrm, W, E)
      RETURN
      END
CCC_ + default format
CCC_  & DEgetI  ## Development/Environment getenv (integer)
      subroutine DEgetI (Lrm, IV, E)
      implicit none
      _INTENT(OUT,integer)   Lrm
      _INTENT(OUT,integer)   IV
      _INTENT(IN, character) E*(*)
      call DEgtFI (Lrm, IV, E, ' ')
      RETURN
      END
CCC_  & DEgetD  ## Development/Environment getenv (double)
      subroutine DEgetD (Lrm, DV, E)
      implicit none
      _INTENT(OUT,integer)   Lrm
      _INTENT(OUT,_REALD)    DV
      _INTENT(IN, character) E*(*)
      call DEgtFD (Lrm, DV, E, ' ')
      RETURN
      END
CCC_  & DEputI  ## Development/Environment putenv (integer)
      subroutine DEputI (Lrm, IV, E)
      implicit none
      _INTENT(OUT,integer)   Lrm
      _INTENT(IN, integer)   IV
      _INTENT(IN, character) E*(*)
      call DEptFI (Lrm, IV, E, ' ')
      RETURN
      END
CCC_  & DEputD  ## Development/Environment putenv (double)
      subroutine DEputD (Lrm, DV, E)
      implicit none
      _INTENT(OUT,integer)   Lrm
      _INTENT(IN, _REALD)    DV
      _INTENT(IN, character) E*(*)
      call DEptFD (Lrm, DV, E, ' ')
      RETURN
      END
CCC_* Get/Put at once
CCC_ & DEgetP  ## Development/Environment get and put
      subroutine DEgetP
     O    (Lr,  V,
     I     E,   SN,  ST)
CCC_  - Description
CC     - Get contents from buffer
CC     - When not found, inquire system environment and put its to buffer
CC     SN null string
CC     ST terminater string
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(OUT,integer)   Lr
      _INTENT(OUT,character) V*(*)
      _INTENT(IN, character) E*(*)
      _INTENT(IN, character) SN*(*), ST*(*)
CCC_  - Body
      call DEBgtA (Lr, V, E)
      if (Lr.lt.0) then
         call UEgenv (V, E)
         if (V.eq.SN) V = ' '
         call DEBptA (Lr, V, E)
      endif
CCC_   . To do: terminator manipulation
CC       Dummy statements
      if (ST.eq.' ') continue
      RETURN
      END
CCC_ & DEputG  ## Development/Environment put and get
      subroutine DEputG
     O    (Lr,
     W     W,
     I     V,
     I     E,    SN,  ST)
CCC_  - Description
CC     - Inquire system environment
CC     - if      NULL  then clear
CC     - else if blank then store V
CC     - else               store it
CC     SN null string
CC     ST terminater string
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(OUT,  integer)   Lr
      _INTENT(INOUT,character) W*(*)
      _INTENT(IN,   character) V*(*)
      _INTENT(IN,   character) E*(*)
      _INTENT(IN,   character) SN*(*), ST*(*)
CCC_  - Body
CC  Runtime environment has a priority
      call UEgenv (W, E)
      if (W .eq. SN) then
         call DEBptA (Lr, ' ', E)
      else if (W .eq. ' ') then
         call DEBptA (Lr, V, E)
      else
         call DEBptA (Lr, W, E)
      endif
CCC_   . To do: terminator manipulation
      if (ST.eq.' ') continue
      RETURN
      END
CCC_* Special treatment
CCC_ & DEspcl  ## Development/Environment special configuration
      subroutine DEspcl (Lr, Vnull, Vterm, Enull, Eterm)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   Lr
      _INTENT(OUT,character) Vnull*(*), Vterm*(*)
      _INTENT(IN, character) Enull*(*), Eterm*(*)
CCC_  - Body
      Lr = 0
      if (Lr.eq.0)
     $     call DEsetD (Lr, Vnull, Enull, ENV_NULLIFY)
      if (Lr.eq.0)
     $     call DEsetD (Lr, Vterm, Eterm, ENV_TERMINATOR)
      RETURN
      END
CCC_ & DEsetD  ## Development/Environment set default
      subroutine DEsetD (Lr, V, E, D)
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(OUT,integer)   Lr
      _INTENT(OUT,character) V*(*)
      _INTENT(IN, character) E*(*), D*(*)
CCC_  - Body
      call UEgenv (V, E)
      if (V .eq. ' ') then
         call DEBgtA (Lr, V, E)
      endif
      if (V .eq. ' ') then
         V = D
         call DEBptA (Lr, D, E)
      endif
      if (V .eq. ' ') Lr = -1
      RETURN
      END
CCC_* Buffer manipulation
CCC_ & DEBffr  ## Development/Environment buffer
      subroutine DEBffr (ifp)
CCC_  - Description
CC    String buffer management
CC    Number-type contents must be converted into string before call
CCC_  - Declaration
      implicit none
CCC_   = Parameter
      integer    Menv
      parameter (Menv = OPT_DENVMS_ENV_MAX)
      integer    Lnam
      parameter (Lnam = OPT_DENVMS_VAR_LEN)
      integer    Lval
      parameter (Lval = OPT_DENVMS_STR_LEN)
CCC_   = Arguments
      _INTENT(IN, integer)   ifp
      _INTENT(OUT,integer)   Lrm
      _INTENT(OUT,character) AVo*(*)
      _INTENT(IN, character) Ei*(*), AVi*(*)
CCC_   = Save
      character Enam (Menv) * (Lnam)
      data      Enam /Menv * ' '/
      character Eval (Menv) * (Lval)
      data      Eval /Menv * ' '/
      save      Enam, Eval
CCC_   = Interior
      integer   lw
      integer   j
      integer   KenvF
CCC_  = Functions
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
CCC_  - Body (DEbffr)
      if (ifp.ge.0) then
         continue
      endif
      RETURN
CCC_  & DEBgtA  ## Development/Environment buffer get string
      entry DEBgtA (Lrm, AVo, Ei)
      call  DEUrst (Lrm, AVo, Ei,   Enam, Eval, Menv)
      RETURN
CCC_  & DEBptA  ## Development/Environment buffer put string
      entry DEBptA (Lrm, AVi, Ei)
      call  DEUclr (Ei,           Enam, Eval,  Menv)
      call  DEUstr (Lrm, Ei, AVi, Enam, Eval,  Menv)
      RETURN
CCC_  & DEBrep  ## Development/Environment buffer report all
      entry DEBrep (ifp)
 101  format (I4, 1x, A, T40, '/', A, '/')
 108  format ('DENVMS Report ', I3, ' getenv () = ',I1)
 109  format ('DENVMS Report DONE')
      call UEdiag (KenvF)
      if (COND_N(ifp)) then
         write (ifp, 108) Menv, KenvF
         do j = 1, Menv
            lw = len_trim (Enam (j))
            if (lw.gt.0)
     $           write (ifp, 101) j, Enam (j)(1:lw),
     $           _TRIML(Eval (j))
         enddo
         write (ifp, 109)
      else if (COND_S(ifp)) then
         write (*, 108) Menv, KenvF
         do j = 1, Menv
            lw = len_trim (Enam (j))
            if (lw.gt.0)
     $        write (*, 101) j, _TRIM(Enam (j)(1:lw)),
     $           _TRIML(Eval (j))
         enddo
         write (*, 109)
      endif
      RETURN
      END
CCC_ & DEUifs  ## Development/environment utility/if set or not
      subroutine DEUifs
     O    (iErr,
     I     E,
     I     Enam, Menv)
CCC_  - Description
CC     IERR < 0 if not found, == 0 if found
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, character) E*(*)
      _INTENT(IN, integer)   Menv
      _INTENT(IN, character) Enam (*)*(*)
CCC_   = Interior
      integer I, IL
CCC_  - Body
      IL   = 0
      call DEUlku (I, E, IL, Enam, Menv)
      if (I.lt.0) then
         iErr = -1
      else
         iErr = 0
      endif
      RETURN
      END
CCC_ & DEUstr  ## Development/Environment utility/store
      subroutine DEUstr
     O    (Lrm,
     I     E,    V,
     M     Enam, Eval,
     I     Menv)
CCC_  - Description
CC      Store contents of environemnt E as V and remaining length to LRM
CC      Lrm < 0 if full
CC      Lrm == 0 when fully restored
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(OUT,  integer)   Lrm
      _INTENT(IN,   character) E*(*)
      _INTENT(IN,   character) V*(*)
      _INTENT(IN,   integer)   Menv
      _INTENT(INOUT,character) Enam (*)*(*)
      _INTENT(INOUT,character) Eval (*)*(*)
CCC_   = Interior
      integer I,    IL
      integer le,   lv
      integer k,    ks,  ke
      integer Lnam, Lval
CCC_  = Functions
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
CCC_  - Body
      Lrm  = -1
c
      Lnam = len (Enam (1))
      Lval = len (Eval (1))
      lv   = MAX (1, len_trim (V))
      le   = MIN (Lnam, len_trim (E))
c
      IL   = 0
      do k = 0, (lv - 1) / Lval
         call DEUlku (I, ' ', IL, Enam, Menv)
         if (I.lt.0) goto 900
         ks  = k * Lval + 1
         ke  = MIN (lv, ks + Lval - 1)
CC       LRM is cumulative length in this loop
         Lrm = ke
         IL  = I
         Enam (I) = E (1:le)
         Eval (I) = V (ks:ke)
      enddo
 900  continue
      if (Lrm.ge.0) Lrm = MAX (0, lv - Lrm)
      RETURN
      END
CCC_ & DEUrst  ## Development/Environment utility/restore
      subroutine DEUrst
     O    (Lrm,  V,
     I     E,
     I     Enam, Eval,
     I     Menv)
CCC_  - Description
CC      Restore contents of environemnt E to V and remaining length to LRM
CC      Lrm < 0 if E not set
CC      Lrm == 0 when fully restored
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(OUT,integer)   Lrm
      _INTENT(OUT,character) V*(*)
      _INTENT(IN, character) E*(*)
      _INTENT(IN, integer)   Menv
      _INTENT(IN, character) Enam (*)*(*)
      _INTENT(IN, character) Eval (*)*(*)
CCC_   = Interior
      integer I,    IL
      integer lvi, MaxV
      integer k,    ks,  ke
      integer Lval
c$$$      integer Lnam, le
CCC_  = Functions
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
CCC_  - Body
      Lrm  = -1
      V    = ' '
c
      MaxV = len (V)
      Lval = len (Eval (1))
c$$$      Lnam = len (Enam (1))
c$$$      le   = MIN (Lnam, len_trim (E))
c
      k  = 0
      ke = 1
c
      IL = 0
      DO
         call DEUlku (I, E, IL, Enam, Menv)
         if (I.lt.0) goto 900
         lvi = len_trim (Eval (I))
         ks  = k * Lval + 1
CC       blank padding may not be necessary
c$$$         do kk = ke + 1, ks - 1
c$$$            V (kk:kk) = ' '
c$$$         enddo
CC       LRM is cumulative length in this loop
         Lrm = ks - 1 + min (lvi, Lval)
         ke  = MIN (MaxV, Lrm)
         if (ks.le.ke) V (ks:ke) = _TRIM(Eval (I))
         IL = I
         k  = k + 1
      ENDDO
 900  continue
      if (Lrm.ge.0) Lrm = MAX (0, Lrm - MaxV)
      RETURN
      END
CCC_ & DEUclr  ## Development/Environment utility/clear
      subroutine DEUclr
     I    (E,
     M     Enam, Eval,
     I     Menv)
CCC_  - Description
CC     Clear Environment E and its content in ENAM and EVAL
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(IN,   character) E*(*)
      _INTENT(IN,   integer)   Menv
      _INTENT(INOUT,character) Enam (*)*(*)
      _INTENT(INOUT,character) Eval (*)*(*)
CCC_   = Interior
      integer I, IL
CCC_  - Body
      IL = 0
      DO
         call DEUlku (I, E, IL, Enam, Menv)
         if (I.lt.0) goto 900
         IL = I
         Enam (I) = ' '
         Eval (I) = ' '
      ENDDO
 900  continue
      RETURN
      END
CCC_ & DEUlku  ## Development/Environment utility/lookup
      subroutine DEUlku
     O    (Idx,
     I     E,
     I     iLast,  Enam, Menv)
CCC_  - Description
CC     Lookup E in Environtment table ENAM (*) from ILAST + 1
CC     and return IDX
CC     Return -1 if not found
CC     Must set ILAST = 0 before the first call
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(OUT,integer)   Idx
      _INTENT(IN, character) E*(*)
      _INTENT(IN, integer)   iLast
      _INTENT(IN, integer)   Menv
      _INTENT(IN, character) Enam (*)*(*)
CCC_   = Interior
      integer le
      integer j
      integer Lnam
CCC_  = Functions
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
CCC_  - Body
      Lnam = len (Enam (1))
      le = MAX (1, MIN (len_trim (E), Lnam))
      Idx = -1
      do j = iLast + 1, Menv
         if (Enam (j) .eq. E (1:le)) then
            Idx = j
            goto 900
         endif
      enddo
 900  continue
      RETURN
      END
CCC_& DENVMS  ## Development/Environment announcement
      subroutine DENVMS (STRA, STRB, IOP)
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
         STRA = 'OPT_ENV_PREFIX'
         write (STRB, *) OPT_ENV_PREFIX
      else if (IOP.eq.4) then
         STRA = 'OPT_DENVMS_STR_LEN'
         write (STRB, *) OPT_DENVMS_STR_LEN
      else if (IOP.eq.5) then
         STRA = 'ENV_TERMINATOR'
         write (STRB, *) ENV_TERMINATOR
      else if (IOP.eq.6) then
         STRA = 'OPT_DENVMS_VAR_LEN'
         write (STRB, *) OPT_DENVMS_VAR_LEN
      else if (IOP.eq.7) then
         STRA = 'OPT_DENVMS_ENV_MAX'
         write (STRB, *) OPT_DENVMS_ENV_MAX
      else if (IOP.eq.8) then
         STRA = 'ENV_NULLIFY'
         write (STRB, *) ENV_NULLIFY
      else if (IOP.eq.9) then
         STRA = 'OPT_DENVMS_BUFFER_LEN'
         write (STRB, *) OPT_DENVMS_BUFFER_LEN
      else
         STRA = ' '
         STRB = ' '
      endif
      RETURN
      END
CCC_@ DEtest  ## Denvms test
#ifdef TEST_DENVMS
      program DETEST
CCC_ + Declaration
      implicit none
CCC_  = Interior
      integer    iEp, iEg
      character  E*(OPT_DENVMS_VAR_LEN*10)
      character  S*(OPT_DENVMS_STR_LEN*10)
      character  T*(OPT_DENVMS_STR_LEN*10)
      character  SS*3
      integer    IS, IT
      _REALD     DS, DT
      integer    j
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
#define _U *
#include "orevan.F" /* 0 */
CCC_ + Body
#define _ANNOUNCE DENVMS
#define _LEXT 9991
#include "orevan.F" /* 1 */
#define _ANNOUNCE UEAOMS
#define _LEXT 9992
#include "orevan.F" /* 2 */
c
 101  format ('[', 2I3, ':', A, '] in /', A,     '/ out /', A,     '/')
 102  format ('[', 2I3, ':', A, '] in /', I12,   '/ out /', A,     '/')
 103  format ('[', 2I3, ':', A, '] in /', I12,   '/ out /', I12,   '/')
 104  format ('[', 2I3, ':', A, '] in /', E16.9, '/ out /', E16.9, '/')
c
      E = 'A0'
      T = 'SHORT'
      call DEputA (iEp, T, E)
      call DEgetA (iEg, S, E)
      write (_U, 101) iEp, iEg, _TRIM(E), _TRIM(T), _TRIM(S)
c
      E = 'B0'
      T = 'LONG TEXT 123456789 END 999!'
      call DEputA (iEp, T, E)
      call DEgetA (iEg, S, E)
      write (_U, 101) iEp, iEg, _TRIM(E), _TRIM(T), _TRIM(S)
c
      E = 'B02'
      T = 'LONG TEXT 1234    9 END 999!'
c          012345678901234567890123456789
      call DEputA (iEp, T, E)
      call DEgetA (iEg, S, E)
      write (_U, 101) iEp, iEg, _TRIM(E), _TRIM(T), _TRIM(S)

      call DEgetA (iEg, SS, E)
      write (_U, 101) iEp, iEg, _TRIM(E), _TRIM(T), _TRIM(SS)
c
c          012345678901234567890123456789
      E = 'C--LONGENVIRONMENT'
      T = 'FOOBAR'
      call DEputA (iEp, T, E)
      call DEgetA (iEg, S, E)
      write (_U, 101) iEp, iEg, _TRIM(E), _TRIM(T), _TRIM(S)
c
c$$$      E = 'A0'
c$$$      T = 'DIFFERENT'
c$$$      call DEnptS (iEp, T, E)
c$$$      call DEgetS (iEg, S, E)
c$$$      write (_U, 101) iEp, iEg, _TRIM(E), _TRIM(T), _TRIM(S)
c
      E = 'B0'
      T = 'TINY'
      call DEputA (iEp, T, E)
      call DEgetA (iEg, S, E)
      write (_U, 101) iEp, iEg, _TRIM(E), _TRIM(T), _TRIM(S)
c
      E = 'I1'
      IT = -9876
      call DEputI (iEp, IT, E)
      call DEgetA (iEg, S, E)
      write (_U, 102) iEp, iEg, _TRIM(E), IT, _TRIM(S)
c
      IS = -9
      call DEgetI (iEg, IS, E)
      write (_U, 103) iEp, iEg, _TRIM(E), IT, IS
c
      E = 'N99'
      IT = 0
      IS = 888
      iEp = 0
      call DEgetA (iEg, S, E)
      write (_U, 102) iEp, iEg, _TRIM(E), IT, _TRIM(S)
c
      call DEgetI (iEg, IS, E)
      write (_U, 103) iEp, iEg, _TRIM(E), IT, IS
c
      E = 'D1'
      DT = 3.1415d0
      call DEputD (iEp, DT, E)
      call DEgetD (iEg, DS, E)
      write (_U, 104) iEp, iEg, _TRIM(E), DT, DS
c
      iEg = 0
      do j = 1, 10
         write (E, '(''X'',I2.2)') j
         write (T, '(''TTX___xxxxyyyyzzzz'',I5.5)') j
         call DEputA (iEp, T, E)
         call DEgetA (iEg, S, E)
         write (_U, 101) iEp, iEg, _TRIM(E), _TRIM(T), _TRIM(S)
      enddo
c
      call DEBrep (-1)
c
      STOP
      END
#endif /* TEST_DENVMS */
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
