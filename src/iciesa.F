C iciesa.F --- IcIES/score A
C Author: SAITO Fuyuki
C Created: Aug 6 2013
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2020/09/17 06:52:23 fuyuki iciesa.F>'
#define _FNAME 'iciesa.F'
#define _REV   'Snoopy0.8'
CCC_! MANIFESTO
C
C Copyright (C) 2013--2020
C           Japan Agency for Marine-Earth Science and Technology,
C           Ayako ABE-OUCHI
C
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
CCC_* Common macros
#include "ofdlct.h"   /* fortran dialect */
#include "odevva.h"
#include "ofnstd.h"
CCC_@ IAdriv  ## IcIES/A driver
      program IAdriv
CCC_ + Declaration
      implicit none
      integer iErr
      integer ipA (LOG_CHANNEL_MAX)
      integer iMA (MAX_MPI_ATTR)
CCC_ + Body
      call DDcapo
     O    (iErr,
     I     2, ' ', 'O', _FNAME, 0)
c
      if (iErr.eq.0) then
         call DLCmng (ipA, 't')
         call DVHrgC (iErr, 'V', ' ', ' ', ipA)
      endif
c
      if (iErr.eq.0) then
         call DMAtma (iMA)
      endif
      call DevFin (iErr)
      STOP
      END
CCC_& IAcond  ## IcIES/A conductor
#include "oarpea.h"
#include "oarpkw.h"   /* operation id in arpeggio/kiwi */
CCC_* Hauptstimme/Movement
#include "movement/movement.h" /* movement definitions */
CCC_* Begleitung
CCC_ + Begl./Climate Ts
CCC_ + Begl./Climate Acc
CCC_ + Begl./Climate Abl
CCC_ + Begl./Climate Ms
CCC_ + Begl./Ocean Mb
CCC_ + Begl./Ocean Level
CCC_ + Begl./Ocean Calving
CCC_ + Begl./Bedrock Type
CCC_ + Begl./Bedrock Isostacy
CCC_ + Begl./Bedrock Heat flux
CCC_& IcIESa  ## Announcement
      subroutine IcIESa (STRA, STRB, IOP)
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
CCC_* Obsolete
CCC_ + begin
#if 0 /* obsolete */
CCC_ + end
#endif /* 0 obsolete */
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
