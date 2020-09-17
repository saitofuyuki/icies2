C arpeggio/akwopr.F --- Arpeggio/Kiwi (multi-grid block) operations
C Maintainer:  SAITO Fuyuki
C Created: Oct 19 2011
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2020/09/17 08:40:19 fuyuki akwopr.F>'
#define _FNAME 'arpeggio/akwopr.F'
#define _REV   'Arpeggio 1.0'
CCC_! MANIFESTO
C
C Copyright (C) 2011--2020
C           Japan Agency for Marine-Earth Science and Technology
C
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
CCC_* Description
CC    Kiwi/no-wing/multi-grid block matrix operation modules
CCC_ + operation notation
CC      AK*x  input X (LH,*)    output X (LH,*)
CC      AK*z  input X (LH,*)    output Z (LH,*)
CC      AK*w  input W (LH,LZ,*) output W (LH,*)
CC      AK*y  input W (LH,LZ,*) output Y (LH,LZ,*)
CCC_* Common macros
#include "ofdlct.h" /* fortran dialect */
#include "ologfm.h" /* log common format */
#include "oarpea.h"
#include "oarpkw.h"  /* operation id */
#include "oarpfi.h"  /* file-interface flags */
#include "odevva.h"
#include "oclock.h"
CCC_ + switches
#define _CPSW_I 0 /* use i  index to copy vector */
#define _CPSW_J 1 /* use j  index to copy vector */
#define _CPSW_G 2 /* use ij index to copy vector */
CCC_* [AKG] Batch with clone group
CCC_ & AKGwax  ## Weighted add [x]
      subroutine AKGwax
     M    (X,
     I     CG,   WW,
     I     MH,   LH,   KL, KR,
     I     ipKW, jOpr, ipCG)
CCC_  - Declaration
      implicit none
      _INTENT(IN,    integer)  MH, LH
      _INTENT(IN,    integer)  KL, KR
      _INTENT(INOUT, _REALSTD) X    (LH, *)
      _INTENT(IN,    _REALSTD) CG   (LH, *)
      _INTENT(IN,    _REALSTD) WW   (LH, *)
      _INTENT(IN,    integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN,    integer)  jOpr
      _INTENT(IN,    integer)  ipCG (*)
      integer KOP, KSW, KCG
      integer JI0, JI9,      JIA
      integer JC0, JC9, JCS, JCA
      integer KO,  KA
CCC_  - Body
      KOP =  ipCG (KWCG_KOP(jOpr))
      KSW =  ipCG (KWCG_KSW(jOpr))
      KCG =  ipCG (KWCG_GID(jOpr)) + ipCG (KWCG_OFS)
c
      JI0 =  ipKW (KWI_LI0, KOP, KSW)
      JI9 =  ipKW (KWI_LI9, KOP, KSW)
      JIA =  ipKW (KWI_OFI, KOP, KSW)
      JC0 =  ipKW (KWI_LC0, KOP, KSW)
      JC9 =  ipKW (KWI_LC9, KOP, KSW)
      JCS =  ipKW (KWI_LCS, KOP, KSW)
      JCA =  ipKW (KWI_OFC, KOP, KSW)
      KO  =  ipKW (KWI_KWO, KOP, KSW)
      KA  =  ipKW (KWI_KWA, KOP, KSW)
c
      call AKXwax
     M    (X,   KL, KR, JI0, JI9,      JIA,
     I     CG,  KCG,    JC0, JC9, JCS, JCA,
     I     WW,  KO, KA,
     I     MH,  LH)
c
      RETURN
      END
CCC_ & AKGwaw  ## Weighted add [w]
      subroutine AKGwaw
     M    (X,
     I     CG,   WW,
     I     MH,   LH,   MO,   LO,  KOS, KXL, KXR,
     I     ipKW, jOpr, ipCG)
CCC_  - Declaration
      implicit none
      _INTENT(IN,    integer)  MH,  LH
      _INTENT(IN,    integer)  MO,  LO,  KOS
      _INTENT(IN,    integer)  KXL, KXR
      _INTENT(INOUT, _REALSTD) X    (LH, LO, *)
      _INTENT(IN,    _REALSTD) CG   (LH, LO, *)
      _INTENT(IN,    _REALSTD) WW   (LH, *)
      _INTENT(IN,    integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN,    integer)  jOpr
      _INTENT(IN,    integer)  ipCG (*)
      integer KOP, KSW, KCG
      integer JI0, JI9,      JIA
      integer JC0, JC9, JCS, JCA
      integer KO,  KA
CCC_  - Body
      KOP =  ipCG (KWCG_KOP(jOpr))
      KSW =  ipCG (KWCG_KSW(jOpr))
      KCG =  ipCG (KWCG_GID(jOpr)) + ipCG (KWCG_OFS)
c
      JI0 =  ipKW (KWI_LI0, KOP, KSW)
      JI9 =  ipKW (KWI_LI9, KOP, KSW)
      JIA =  ipKW (KWI_OFI, KOP, KSW)
      JC0 =  ipKW (KWI_LC0, KOP, KSW)
      JC9 =  ipKW (KWI_LC9, KOP, KSW)
      JCS =  ipKW (KWI_LCS, KOP, KSW)
      JCA =  ipKW (KWI_OFC, KOP, KSW)
      KO  =  ipKW (KWI_KWO, KOP, KSW)
      KA  =  ipKW (KWI_KWA, KOP, KSW)
c
      call AKXwaw
     M    (X,   KXL, KXR, JI0, JI9,      JIA,
     I     CG,  KCG,      JC0, JC9, JCS, JCA,
     I     WW,  KO,  KA,
     I     MH,  LH,  MO,  LO,  KOS)
c
      RETURN
      END
CCC_ & AKGwaz  ## Weighted add [z]
      subroutine AKGwaz
     O    (Z,
     I     CG,   X,    WW,
     I     MH,   LH,
     I     ipKW, jOpr, ipCG)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)  MH, LH
      _INTENT(OUT,_REALSTD) Z  (LH)
      _INTENT(IN, _REALSTD) X  (LH)
      _INTENT(IN, _REALSTD) CG (LH, *)
      _INTENT(IN, _REALSTD) WW (LH, *)
      _INTENT(IN, integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN, integer)  jOpr
      _INTENT(IN, integer)  ipCG (*)
      integer KOP, KSW, KCG
      integer JI0, JI9,      JIA
      integer JC0, JC9, JCS, JCA
      integer KO,  KA
CCC_  - Body
      KOP =  ipCG (KWCG_KOP(jOpr))
      KSW =  ipCG (KWCG_KSW(jOpr))
      KCG =  ipCG (KWCG_GID(jOpr)) + ipCG (KWCG_OFS)
c
      JI0 =  ipKW (KWI_LI0, KOP, KSW)
      JI9 =  ipKW (KWI_LI9, KOP, KSW)
      JIA =  ipKW (KWI_OFI, KOP, KSW)
      JC0 =  ipKW (KWI_LC0, KOP, KSW)
      JC9 =  ipKW (KWI_LC9, KOP, KSW)
      JCS =  ipKW (KWI_LCS, KOP, KSW)
      JCA =  ipKW (KWI_OFC, KOP, KSW)
      KO  =  ipKW (KWI_KWO, KOP, KSW)
      KA  =  ipKW (KWI_KWA, KOP, KSW)
c
      call AKXwaz
     O    (Z,
     I     X,           JI0, JI9,      JIA,
     I     CG,  KCG,    JC0, JC9, JCS, JCA,
     I     WW,  KO, KA,
     I     MH,  LH)
      RETURN
      END
CCC_ & AKGway  ## Weighted add [y]
      subroutine AKGway
     O    (Z,
     I     CG,   X,    WW,
     I     MH,   LH,   MO,   LO,  KOS,
     I     ipKW, jOpr, ipCG)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)  MH, LH
      _INTENT(IN, integer)  MO, LO, KOS
      _INTENT(OUT,_REALSTD) Z    (LH, LO)
      _INTENT(IN, _REALSTD) X    (LH, LO)
      _INTENT(IN, _REALSTD) CG   (LH, LO, *)
      _INTENT(IN, _REALSTD) WW   (LH, *)
      _INTENT(IN, integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN, integer)  jOpr
      _INTENT(IN, integer)  ipCG (*)
      integer KOP, KSW, KCG
      integer JI0, JI9,      JIA
      integer JC0, JC9, JCS, JCA
      integer KO,  KA
CCC_  - Body
      KOP =  ipCG (KWCG_KOP(jOpr))
      KSW =  ipCG (KWCG_KSW(jOpr))
      KCG =  ipCG (KWCG_GID(jOpr)) + ipCG (KWCG_OFS)
c
      JI0 =  ipKW (KWI_LI0, KOP, KSW)
      JI9 =  ipKW (KWI_LI9, KOP, KSW)
      JIA =  ipKW (KWI_OFI, KOP, KSW)
      JC0 =  ipKW (KWI_LC0, KOP, KSW)
      JC9 =  ipKW (KWI_LC9, KOP, KSW)
      JCS =  ipKW (KWI_LCS, KOP, KSW)
      JCA =  ipKW (KWI_OFC, KOP, KSW)
      KO  =  ipKW (KWI_KWO, KOP, KSW)
      KA  =  ipKW (KWI_KWA, KOP, KSW)
c
      call AKXway
     O    (Z,
     I     X,           JI0, JI9,      JIA,
     I     CG,  KCG,    JC0, JC9, JCS, JCA,
     I     WW,  KO, KA,
     I     MH,  LH,     MO,  LO,  KOS)
c
      RETURN
      END
CCC_ & AKGwbz  ## Weighted add [z] (two x)
      subroutine AKGwbz
     O    (Z,
     I     CG,   X,    WW,
     I     MH,   LH,   KXO,  KXA,
     I     ipKW, jOpr, ipCG)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)  MH, LH
      _INTENT(OUT,_REALSTD) Z  (LH)
      _INTENT(IN, _REALSTD) X  (LH, *)
      _INTENT(IN, _REALSTD) CG (LH, *)
      _INTENT(IN, _REALSTD) WW (LH, *)
      _INTENT(IN, integer)  KXO,  KXA
      _INTENT(IN, integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN, integer)  jOpr
      _INTENT(IN, integer)  ipCG (*)
      integer KOP, KSW, KCG
      integer JI0, JI9,      JIA
      integer JC0, JC9, JCS, JCA
      integer KO,  KA
CCC_  - Body
      KOP =  ipCG (KWCG_KOP(jOpr))
      KSW =  ipCG (KWCG_KSW(jOpr))
      KCG =  ipCG (KWCG_GID(jOpr)) + ipCG (KWCG_OFS)
c
      JI0 =  ipKW (KWI_LI0, KOP, KSW)
      JI9 =  ipKW (KWI_LI9, KOP, KSW)
      JIA =  ipKW (KWI_OFI, KOP, KSW)
      JC0 =  ipKW (KWI_LC0, KOP, KSW)
      JC9 =  ipKW (KWI_LC9, KOP, KSW)
      JCS =  ipKW (KWI_LCS, KOP, KSW)
      JCA =  ipKW (KWI_OFC, KOP, KSW)
      KO  =  ipKW (KWI_KWO, KOP, KSW)
      KA  =  ipKW (KWI_KWA, KOP, KSW)
c
      call AKXwbz
     O    (Z,
     I     X,  KXO, KXA, JI0, JI9,      JIA,
     I     CG, KCG,      JC0, JC9, JCS, JCA,
     I     WW, KO,  KA,
     I     MH, LH)
      RETURN
      END
CCC_ & AKGwex  ## Weighted add [x] off-diagonal
      subroutine AKGwex
     M    (X,
     I     CG,   WW,
     I     MH,   LH,   KL, KR,
     I     ipKW, jOpr, ipCG)
CCC_  - Declaration
      implicit none
      _INTENT(IN,    integer)  MH, LH
      _INTENT(IN,    integer)  KL, KR
      _INTENT(INOUT, _REALSTD) X    (LH, *)
      _INTENT(OUT,   _REALSTD) CG   (LH, *)
      _INTENT(IN,    _REALSTD) WW   (LH, *)
      _INTENT(IN,    integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN,    integer)  jOpr
      _INTENT(IN,    integer)  ipCG (*)
      integer KOP, KSW, KCG
      integer JI0, JI9,      JIA
      integer JC0, JC9, JCS, JCA
      integer KA
CCC_  - Body
      KOP =  ipCG (KWCG_KOP(jOpr))
      KSW =  ipCG (KWCG_KSW(jOpr))
      KCG =  ipCG (KWCG_GID(jOpr)) + ipCG (KWCG_OFS)
c
      JI0 =  ipKW (KWI_LI0, KOP, KSW)
      JI9 =  ipKW (KWI_LI9, KOP, KSW)
      JIA =  ipKW (KWI_OFI, KOP, KSW)
      JC0 =  ipKW (KWI_LC0, KOP, KSW)
      JC9 =  ipKW (KWI_LC9, KOP, KSW)
      JCS =  ipKW (KWI_LCS, KOP, KSW)
      JCA =  ipKW (KWI_OFC, KOP, KSW)
      KA  =  ipKW (KWI_KWA, KOP, KSW)
c
      call AKXwex
     M    (X,   KL, KR, JI0, JI9,      JIA,
     I     CG,  KCG,    JC0, JC9, JCS, JCA,
     I     WW,  KA,
     I     MH,  LH)
c
      RETURN
      END
CCC_ & AKGcex  ## Complement factor [x] off-diagonal
      subroutine AKGcex
     M    (X,
     I     CG,   WI,   CF,
     I     MH,   LH,   KL, KR,
     I     ipKW, jOpr, ipCG)
CCC_  - Declaration
      implicit none
      _INTENT(IN,    integer)  MH, LH
      _INTENT(IN,    integer)  KL, KR
      _INTENT(INOUT, _REALSTD) X    (LH, *)
      _INTENT(OUT,   _REALSTD) CG   (LH, *)
      _INTENT(IN,    _REALSTD) WI   (LH)
      _INTENT(IN,    _REALSTD) CF
      _INTENT(IN,    integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN,    integer)  jOpr
      _INTENT(IN,    integer)  ipCG (*)
      integer KOP, KSW, KCG
      integer JI0, JI9,      JIA
      integer JC0, JC9, JCS, JCA
CCC_  - Body
      KOP =  ipCG (KWCG_KOP(jOpr))
      KSW =  ipCG (KWCG_KSW(jOpr))
      KCG =  ipCG (KWCG_GID(jOpr)) + ipCG (KWCG_OFS)
c
      JI0 =  ipKW (KWI_LI0, KOP, KSW)
      JI9 =  ipKW (KWI_LI9, KOP, KSW)
      JIA =  ipKW (KWI_OFI, KOP, KSW)
      JC0 =  ipKW (KWI_LC0, KOP, KSW)
      JC9 =  ipKW (KWI_LC9, KOP, KSW)
      JCS =  ipKW (KWI_LCS, KOP, KSW)
      JCA =  ipKW (KWI_OFC, KOP, KSW)
c
      call AKXcex
     M    (X,   KL, KR, JI0, JI9,      JIA,
     I     CG,  KCG,    JC0, JC9, JCS, JCA,
     I     WI,  CF,
     I     MH,  LH)
      RETURN
      END
CCC_ & AKGcez  ## Complement factor [z] off-diagonal
      subroutine AKGcez
     O    (Z,
     I     CG,   X,    WI,  CF,
     I     MH,   LH,
     I     ipKW, jOpr, ipCG)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)  MH, LH
      _INTENT(OUT,_REALSTD) Z  (LH)
      _INTENT(IN, _REALSTD) X  (LH)
      _INTENT(IN, _REALSTD) CG (LH, *)
      _INTENT(IN, _REALSTD) WI (LH), CF
      _INTENT(IN, integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN, integer)  jOpr
      _INTENT(IN, integer)  ipCG (*)
      integer KOP, KSW, KCG
      integer JI0, JI9,      JIA
      integer JC0, JC9, JCS, JCA
CCC_  - Body
      KOP =  ipCG (KWCG_KOP(jOpr))
      KSW =  ipCG (KWCG_KSW(jOpr))
      KCG =  ipCG (KWCG_GID(jOpr)) + ipCG (KWCG_OFS)
c
      JI0 =  ipKW (KWI_LI0, KOP, KSW)
      JI9 =  ipKW (KWI_LI9, KOP, KSW)
      JIA =  ipKW (KWI_OFI, KOP, KSW)
      JC0 =  ipKW (KWI_LC0, KOP, KSW)
      JC9 =  ipKW (KWI_LC9, KOP, KSW)
      JCS =  ipKW (KWI_LCS, KOP, KSW)
      JCA =  ipKW (KWI_OFC, KOP, KSW)
c
      call AKXcez
     O    (Z,
     I     X,           JI0, JI9,      JIA,
     I     CG,  KCG,    JC0, JC9, JCS, JCA,
     I     WI,  CF,
     I     MH,  LH)
      RETURN
      END
CCC_ & AKGmex  ## shift [x] off-diagonal
      subroutine AKGmex
     M    (X,
     I     CG,
     I     MH,   LH,   KL,  KR,
     I     ipKW, jOpr, ipCG)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  KL, KR
      _INTENT(INOUT,_REALSTD) X  (LH, *)
      _INTENT(IN,   _REALSTD) CG (LH, *)
      _INTENT(IN,   integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN,   integer)  jOpr
      _INTENT(IN,   integer)  ipCG (*)
      integer KOP, KSW, KCG
      integer JI0, JI9,      JIA
      integer JC0, JC9, JCS, JCA
CCC_  - Body
      KOP =  ipCG (KWCG_KOP(jOpr))
      KSW =  ipCG (KWCG_KSW(jOpr))
      KCG =  ipCG (KWCG_GID(jOpr)) + ipCG (KWCG_OFS)
c
      JI0 =  ipKW (KWI_LI0, KOP, KSW)
      JI9 =  ipKW (KWI_LI9, KOP, KSW)
      JIA =  ipKW (KWI_OFI, KOP, KSW)
      JC0 =  ipKW (KWI_LC0, KOP, KSW)
      JC9 =  ipKW (KWI_LC9, KOP, KSW)
      JCS =  ipKW (KWI_LCS, KOP, KSW)
      JCA =  ipKW (KWI_OFC, KOP, KSW)
c
      call AKXmex
     M    (X,  KL,  KR, JI0, JI9,      JIA,
     I     CG, KCG,     JC0, JC9, JCS, JCA,
     I     MH, LH)
c
      RETURN
      END
CCC_ & AKGmez  ## shift [z] off-diagonal
      subroutine AKGmez
     O    (Z,
     I     CG,   X,
     I     MH,   LH,
     I     ipKW, jOpr, ipCG)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)  MH, LH
      _INTENT(OUT,_REALSTD) Z  (LH)
      _INTENT(IN, _REALSTD) X  (LH)
      _INTENT(IN, _REALSTD) CG (LH, *)
      _INTENT(IN, integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN, integer)  jOpr
      _INTENT(IN, integer)  ipCG (*)
      integer KOP, KSW, KCG
      integer JI0, JI9,      JIA
      integer JC0, JC9, JCS, JCA
CCC_  - Body
      KOP =  ipCG (KWCG_KOP(jOpr))
      KSW =  ipCG (KWCG_KSW(jOpr))
      KCG =  ipCG (KWCG_GID(jOpr)) + ipCG (KWCG_OFS)
c
      JI0 =  ipKW (KWI_LI0, KOP, KSW)
      JI9 =  ipKW (KWI_LI9, KOP, KSW)
      JIA =  ipKW (KWI_OFI, KOP, KSW)
      JC0 =  ipKW (KWI_LC0, KOP, KSW)
      JC9 =  ipKW (KWI_LC9, KOP, KSW)
      JCS =  ipKW (KWI_LCS, KOP, KSW)
      JCA =  ipKW (KWI_OFC, KOP, KSW)
c
      call AKXmez
     O    (Z,
     I     X,       JI0, JI9,      JIA,
     I     CG, KCG, JC0, JC9, JCS, JCA,
     I     MH, LH)
c
      RETURN
      END
CCC_ & AKGmey  ## shift [y] off-diagonal
      subroutine AKGmey
     O    (Z,
     I     CG,   X,
     I     MH,   LH,   MO, LO, KOS,
     I     ipKW, jOpr, ipCG)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)  MH, LH
      _INTENT(IN, integer)  MO, LO, KOS
      _INTENT(OUT,_REALSTD) Z  (LH, LO)
      _INTENT(IN, _REALSTD) X  (LH, LO)
      _INTENT(IN, _REALSTD) CG (LH, LO, *)
      _INTENT(IN, integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN, integer)  jOpr
      _INTENT(IN, integer)  ipCG (*)
      integer KOP, KSW, KCG
      integer JI0, JI9,      JIA
      integer JC0, JC9, JCS, JCA
CCC_  - Body
      KOP =  ipCG (KWCG_KOP(jOpr))
      KSW =  ipCG (KWCG_KSW(jOpr))
      KCG =  ipCG (KWCG_GID(jOpr)) + ipCG (KWCG_OFS)
c
      JI0 =  ipKW (KWI_LI0, KOP, KSW)
      JI9 =  ipKW (KWI_LI9, KOP, KSW)
      JIA =  ipKW (KWI_OFI, KOP, KSW)
      JC0 =  ipKW (KWI_LC0, KOP, KSW)
      JC9 =  ipKW (KWI_LC9, KOP, KSW)
      JCS =  ipKW (KWI_LCS, KOP, KSW)
      JCA =  ipKW (KWI_OFC, KOP, KSW)
c
      call AKXmey
     O    (Z,
     I     X,       JI0, JI9,      JIA,
     I     CG, KCG, JC0, JC9, JCS, JCA,
     I     MH, LH,  MO,  LO,  KOS)
c
      RETURN
      END
CCC_* [AKB] Batch with one-time clone
CCC_ & AKBoc2  ## Kiwi/Batch 2 operations with clone
CCC_ & AKBwax  ## Weighted add [x]
      subroutine AKBwax
     M    (X,    CV,
     I     WW,
     I     MH,   LH,  KL,  KR,
     I     ipKW, iMA, KOP, KSW)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  KL, KR
      _INTENT(INOUT,_REALSTD) X  (LH, *)
      _INTENT(OUT,  _REALSTD) CV (LH)
      _INTENT(IN,   _REALSTD) WW (LH, *)
      _INTENT(IN,   integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN,   integer)  iMA  (*)
      _INTENT(IN,   integer)  KOP, KSW
      integer JI0, JI9,      JIA
      integer JC0, JC9, JCS, JCA
      integer KO,  KA,  KC
CCC_  - Body
      call AKCupx
     O    (CV,
     I     X,    MH,   LH,  KR,
     I     ipKW, iMA,  KOP, KSW)
c
      JI0 =  ipKW (KWI_LI0, KOP, KSW)
      JI9 =  ipKW (KWI_LI9, KOP, KSW)
      JIA =  ipKW (KWI_OFI, KOP, KSW)
      JC0 =  ipKW (KWI_LC0, KOP, KSW)
      JC9 =  ipKW (KWI_LC9, KOP, KSW)
      JCS =  ipKW (KWI_LCS, KOP, KSW)
      JCA =  ipKW (KWI_OFC, KOP, KSW)
      KO  =  ipKW (KWI_KWO, KOP, KSW)
      KA  =  ipKW (KWI_KWA, KOP, KSW)
      KC  =  1
c
      call AKXwax
     M    (X,   KL, KR, JI0, JI9,      JIA,
     I     CV,  KC,     JC0, JC9, JCS, JCA,
     I     WW,  KO, KA,
     I     MH,  LH)
      RETURN
      END
CCC_ & AKBwaw  ## Weighted add [w]
      subroutine AKBwaw
     M    (X,    CV,
     I     WW,
     I     MH,   LH,  MO,  LO,  KOS, KXL, KXR,
     I     ipKW, iMA, KOP, KSW)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  MH,  LH
      _INTENT(IN,   integer)  MO,  LO, KOS
      _INTENT(IN,   integer)  KXL, KXR
      _INTENT(INOUT,_REALSTD) X    (LH, LO, *)
      _INTENT(OUT,  _REALSTD) CV   (LH, LO)
      _INTENT(IN,   _REALSTD) WW   (LH, *)
      _INTENT(IN,   integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN,   integer)  iMA  (*)
      _INTENT(IN,   integer)  KOP, KSW
      integer JI0, JI9,      JIA
      integer JC0, JC9, JCS, JCA
      integer KO,  KA,  KC
CCC_  - Body
      call AKCupw
     O    (CV,
     I     X,    MH,   LH,  MO,  LO, KOS, KXR,
     I     ipKW, iMA,  KOP, KSW)
c
      JI0 =  ipKW (KWI_LI0, KOP, KSW)
      JI9 =  ipKW (KWI_LI9, KOP, KSW)
      JIA =  ipKW (KWI_OFI, KOP, KSW)
      JC0 =  ipKW (KWI_LC0, KOP, KSW)
      JC9 =  ipKW (KWI_LC9, KOP, KSW)
      JCS =  ipKW (KWI_LCS, KOP, KSW)
      JCA =  ipKW (KWI_OFC, KOP, KSW)
      KO  =  ipKW (KWI_KWO, KOP, KSW)
      KA  =  ipKW (KWI_KWA, KOP, KSW)
      KC  =  1
c
      call AKXwaw
     M    (X,   KXL, KXR, JI0, JI9,      JIA,
     I     CV,  KC,       JC0, JC9, JCS, JCA,
     I     WW,  KO,  KA,
     I     MH,  LH,  MO,  LO,  KOS)
c
      RETURN
      END
CCC_ & AKBwaz  ## Weighted add [z]
      subroutine AKBwaz
     O    (Z,    CV,
     I     X,    WW,
     I     MH,   LH,
     I     ipKW, iMA, KOP, KSW)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)  MH, LH
      _INTENT(OUT,_REALSTD) Z  (LH)
      _INTENT(OUT,_REALSTD) CV (LH)
      _INTENT(IN, _REALSTD) X  (LH)
      _INTENT(IN, _REALSTD) WW (LH, *)
      _INTENT(IN, integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN, integer)  iMA  (*)
      _INTENT(IN, integer)  KOP, KSW
      integer JI0, JI9,      JIA
      integer JC0, JC9, JCS, JCA
      integer KO,  KA
      integer KR,  KC
CCC_  - Body
      KR = 1
      call AKCupx
     O    (CV,
     I     X,    MH,   LH,  KR,
     I     ipKW, iMA,  KOP, KSW)
c
      JI0 =  ipKW (KWI_LI0, KOP, KSW)
      JI9 =  ipKW (KWI_LI9, KOP, KSW)
      JIA =  ipKW (KWI_OFI, KOP, KSW)
      JC0 =  ipKW (KWI_LC0, KOP, KSW)
      JC9 =  ipKW (KWI_LC9, KOP, KSW)
      JCS =  ipKW (KWI_LCS, KOP, KSW)
      JCA =  ipKW (KWI_OFC, KOP, KSW)
      KO  =  ipKW (KWI_KWO, KOP, KSW)
      KA  =  ipKW (KWI_KWA, KOP, KSW)
      KC  =  1
c
      call AKXwaz
     O    (Z,
     I     X,           JI0, JI9,      JIA,
     I     CV,  KC,     JC0, JC9, JCS, JCA,
     I     WW,  KO, KA,
     I     MH,  LH)
c
      RETURN
      END
CCC_ & AKBway  ## Weighted add [y]
      subroutine AKBway
     O    (Z,    CV,
     I     X,    WW,
     I     MH,   LH,  MO,  LO, KOS,
     I     ipKW, iMA, KOP, KSW)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)  MH, LH
      _INTENT(IN, integer)  MO, LO, KOS
      _INTENT(OUT,_REALSTD) Z    (LH, LO)
      _INTENT(OUT,_REALSTD) CV   (LH, LO)
      _INTENT(IN, _REALSTD) X    (LH, LO)
      _INTENT(IN, _REALSTD) WW   (LH, *)
      _INTENT(IN, integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN, integer)  iMA  (*)
      _INTENT(IN, integer)  KOP, KSW
      integer JI0, JI9,      JIA
      integer JC0, JC9, JCS, JCA
      integer KO,  KA
      integer KC,  KR
CCC_  - Body
      KR = 1
      call AKCupw
     O    (CV,
     I     X,    MH,   LH,  MO, LO, KOS, KR,
     I     ipKW, iMA,  KOP, KSW)
c
      JI0 =  ipKW (KWI_LI0, KOP, KSW)
      JI9 =  ipKW (KWI_LI9, KOP, KSW)
      JIA =  ipKW (KWI_OFI, KOP, KSW)
      JC0 =  ipKW (KWI_LC0, KOP, KSW)
      JC9 =  ipKW (KWI_LC9, KOP, KSW)
      JCS =  ipKW (KWI_LCS, KOP, KSW)
      JCA =  ipKW (KWI_OFC, KOP, KSW)
      KO  =  ipKW (KWI_KWO, KOP, KSW)
      KA  =  ipKW (KWI_KWA, KOP, KSW)
      KC  =  1
c
      call AKXway
     O    (Z,
     I     X,           JI0, JI9,      JIA,
     I     CV,  KC,     JC0, JC9, JCS, JCA,
     I     WW,  KO, KA,
     I     MH,  LH,     MO,  LO,  KOS)
c
      RETURN
      END
CCC_ & AKBuax  ## Weighted add [x] with user weight
      subroutine AKBuax
     O    (X,    CV,
     I     WU,
     I     MH,   LH,  KL,  KR,  KWO, KWA,
     I     ipKW, iMA, KOP, KSW)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH
      _INTENT(INOUT,_REALSTD) X  (LH, *)
      _INTENT(OUT,  _REALSTD) CV (LH)
      _INTENT(IN,   _REALSTD) WU (LH, *)
      _INTENT(IN,   integer)  KL,  KR
      _INTENT(IN,   integer)  KWO, KWA
      _INTENT(IN,   integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN,   integer)  iMA  (*)
      _INTENT(IN,   integer)  KOP, KSW
      integer JI0, JI9,      JIA
      integer JC0, JC9, JCS, JCA
      integer KC
CCC_  - Body
      call AKCupx
     O    (CV,
     I     X,    MH,   LH,  KR,
     I     ipKW, iMA,  KOP, KSW)
c
      JI0 =  ipKW (KWI_LI0, KOP, KSW)
      JI9 =  ipKW (KWI_LI9, KOP, KSW)
      JIA =  ipKW (KWI_OFI, KOP, KSW)
      JC0 =  ipKW (KWI_LC0, KOP, KSW)
      JC9 =  ipKW (KWI_LC9, KOP, KSW)
      JCS =  ipKW (KWI_LCS, KOP, KSW)
      JCA =  ipKW (KWI_OFC, KOP, KSW)
      KC  =  1
c
      call AKXwax
     O    (X,   KL,  KR, JI0, JI9,      JIA,
     I     CV,  KC,      JC0, JC9, JCS, JCA,
     I     WU,  KWO, KWA,
     I     MH,  LH)
      RETURN
      END
CCC_ & AKBuaw  ## Weighted add [w] with user weight
      subroutine AKBuaw
     O    (X,    CV,
     I     WU,
     I     MH,   LH,  MO,  LO,  KOS,  KXL, KXR, KWO, KWA,
     I     ipKW, iMA, KOP, KSW)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  MO,  LO, KOS
      _INTENT(INOUT,_REALSTD) X  (LH, LO, *)
      _INTENT(OUT,  _REALSTD) CV (LH, LO)
      _INTENT(IN,   _REALSTD) WU (LH, *)
      _INTENT(IN,   integer)  KXL, KXR
      _INTENT(IN,   integer)  KWO, KWA
      _INTENT(IN,   integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN,   integer)  iMA  (*)
      _INTENT(IN,   integer)  KOP, KSW
      integer JI0, JI9,      JIA
      integer JC0, JC9, JCS, JCA
      integer KC
CCC_  - Body
      call AKCupw
     O    (CV,
     I     X,    MH,   LH,  MO,  LO, KOS, KXR,
     I     ipKW, iMA,  KOP, KSW)
c
      JI0 =  ipKW (KWI_LI0, KOP, KSW)
      JI9 =  ipKW (KWI_LI9, KOP, KSW)
      JIA =  ipKW (KWI_OFI, KOP, KSW)
      JC0 =  ipKW (KWI_LC0, KOP, KSW)
      JC9 =  ipKW (KWI_LC9, KOP, KSW)
      JCS =  ipKW (KWI_LCS, KOP, KSW)
      JCA =  ipKW (KWI_OFC, KOP, KSW)
      KC  =  1
c
      call AKXwaw
     O    (X,   KXL, KXR, JI0, JI9,      JIA,
     I     CV,  KC,       JC0, JC9, JCS, JCA,
     I     WU,  KWO, KWA,
     I     MH,  LH,  MO,  LO,  KOS)
      RETURN
      END
CCC_ & AKBtax  ## Weighted add [x] with user weight transpose
      subroutine AKBtax
     M    (X,    CV,
     I     WU,
     I     MH,   LH,  KL,  KR,  KWO, KWA,
     I     KXT1, KXT2,
     I     ipKW, iMA, KOP, KSW)
CCC_  * Description
CC    Need two work region in X [KXT1, KXT2]
CC    Weight are in WU [KWO, KWA]
CC
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH
      _INTENT(INOUT,_REALSTD) X  (LH, *)
      _INTENT(OUT,  _REALSTD) CV (LH)
      _INTENT(IN,   _REALSTD) WU (LH, *)
      _INTENT(IN,   integer)  KL,  KR
      _INTENT(IN,   integer)  KWO, KWA
      _INTENT(IN,   integer)  KXT1, KXT2
      _INTENT(IN,   integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN,   integer)  iMA  (*)
      _INTENT(IN,   integer)  KOP, KSW
      integer jh
CCC_  - Body
CCC_   . T1: diagonal * input
      do jh = 1, MH
         X (jh, KXT1) = X (jh, KR) * WU (jh, KWO)
      enddo
CCC_   . T2: off diagonal * input
      do jh = 1, MH
         X (jh, KXT2) = X (jh, KR) * WU (jh, KWA)
      enddo
CCC_   . simple add
      call AKBsbx
     M    (X,    CV,
     I     MH,   LH,  KL,  KXT1, KXT2,
     I     ipKW, iMA, KOP, KSW)
      RETURN
      END
CCC_ & AKBtaz  ## Weighted add [z] with user weight transpose
      subroutine AKBtaz
     M    (Z,    CV,
     I     X,    WU,
     I     MH,   LH,  KZL, KWO, KWA,
     I     KZT1, KZT2,
     I     ipKW, iMA, KOP, KSW)
CCC_  * Description
CC    Need two work region in Z [KXT1, KXT2]
CC    Weight are in WU [KWO, KWA]
CC
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH
      _INTENT(INOUT,_REALSTD) Z  (LH, *)
      _INTENT(OUT,  _REALSTD) CV (LH)
      _INTENT(IN,   _REALSTD) X  (LH)
      _INTENT(IN,   _REALSTD) WU (LH, *)
      _INTENT(IN,   integer)  KZL
      _INTENT(IN,   integer)  KWO,  KWA
      _INTENT(IN,   integer)  KZT1, KZT2
      _INTENT(IN,   integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN,   integer)  iMA  (*)
      _INTENT(IN,   integer)  KOP, KSW
      integer jh
CCC_  - Body
CCC_   . T1: diagonal * input
      do jh = 1, MH
         Z (jh, KZT1) = X (jh) * WU (jh, KWO)
      enddo
CCC_   . T2: off diagonal * input
      do jh = 1, MH
         Z (jh, KZT2) = X (jh) * WU (jh, KWA)
      enddo
CCC_   . simple add
      call AKBsbx
     M    (Z,    CV,
     I     MH,   LH,  KZL, KZT1, KZT2,
     I     ipKW, iMA, KOP, KSW)
      RETURN
      END
CCC_ & AKBuaz  ## Weighted add [z] with user weight
      subroutine AKBuaz
     O    (Z,    CV,
     I     X,    WU,
     I     MH,   LH,  KWO, KWA,
     I     ipKW, iMA, KOP, KSW)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)  MH, LH
      _INTENT(OUT,_REALSTD) Z  (LH)
      _INTENT(OUT,_REALSTD) CV (LH)
      _INTENT(IN, _REALSTD) X  (LH)
      _INTENT(IN, _REALSTD) WU (LH, *)
      _INTENT(IN, integer)  KWO, KWA
      _INTENT(IN, integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN, integer)  iMA  (*)
      _INTENT(IN, integer)  KOP, KSW
      integer JI0, JI9,      JIA
      integer JC0, JC9, JCS, JCA
      integer KR,  KC
CCC_  - Body
      KR = 1
      call AKCupx
     O    (CV,
     I     X,    MH,   LH,  KR,
     I     ipKW, iMA,  KOP, KSW)
c
      JI0 =  ipKW (KWI_LI0, KOP, KSW)
      JI9 =  ipKW (KWI_LI9, KOP, KSW)
      JIA =  ipKW (KWI_OFI, KOP, KSW)
      JC0 =  ipKW (KWI_LC0, KOP, KSW)
      JC9 =  ipKW (KWI_LC9, KOP, KSW)
      JCS =  ipKW (KWI_LCS, KOP, KSW)
      JCA =  ipKW (KWI_OFC, KOP, KSW)
      KC  =  1
c
      call AKXwaz
     O    (Z,
     I     X,            JI0, JI9,      JIA,
     I     CV,  KC,      JC0, JC9, JCS, JCA,
     I     WU,  KWO, KWA,
     I     MH,  LH)
      RETURN
      END
CCC_ & AKBwbx  ## Weighted add [x] (two x)
      subroutine AKBwbx
     M    (X,    CV,
     I     WW,
     I     MH,   LH,  KL,  KXO, KXA,
     I     ipKW, iMA, KOP, KSW)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  KL, KXO, KXA
      _INTENT(INOUT,_REALSTD) X  (LH, *)
      _INTENT(OUT,  _REALSTD) CV (LH)
      _INTENT(IN,   _REALSTD) WW (LH, *)
      _INTENT(IN,   integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN,   integer)  iMA  (*)
      _INTENT(IN,   integer)  KOP, KSW
      integer JI0, JI9,      JIA
      integer JC0, JC9, JCS, JCA
      integer KO,  KA,  KC
CCC_  - Body
      call AKCupx
     O    (CV,
     I     X,    MH,   LH,  KXA,
     I     ipKW, iMA,  KOP, KSW)
c
      JI0 =  ipKW (KWI_LI0, KOP, KSW)
      JI9 =  ipKW (KWI_LI9, KOP, KSW)
      JIA =  ipKW (KWI_OFI, KOP, KSW)
      JC0 =  ipKW (KWI_LC0, KOP, KSW)
      JC9 =  ipKW (KWI_LC9, KOP, KSW)
      JCS =  ipKW (KWI_LCS, KOP, KSW)
      JCA =  ipKW (KWI_OFC, KOP, KSW)
      KO  =  ipKW (KWI_KWO, KOP, KSW)
      KA  =  ipKW (KWI_KWA, KOP, KSW)
      KC  = 1
c
      call AKXwbx
     O    (X,   KL,  KXO, KXA, JI0, JI9,      JIA,
     I     CV,  KC,            JC0, JC9, JCS, JCA,
     I     WW,  KO,  KA,
     I     MH,  LH)
c
      RETURN
      END
CCC_ & AKBwbz  ## Weighted add [z] (two x)
      subroutine AKBwbz
     O    (Z,    CV,
     I     X,    WW,
     I     MH,   LH,  KXO, KXA,
     I     ipKW, iMA, KOP, KSW)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)  MH,  LH
      _INTENT(IN, integer)  KXO, KXA
      _INTENT(OUT,_REALSTD) Z  (LH)
      _INTENT(OUT,_REALSTD) CV (LH)
      _INTENT(IN, _REALSTD) X  (LH, *)
      _INTENT(IN, _REALSTD) WW (LH, *)
      _INTENT(IN, integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN, integer)  iMA  (*)
      _INTENT(IN, integer)  KOP, KSW
      integer JI0, JI9,      JIA
      integer JC0, JC9, JCS, JCA
      integer KO,  KA,  KC
CCC_  - Body
      call AKCupx
     O    (CV,
     I     X,    MH,   LH,  KXA,
     I     ipKW, iMA,  KOP, KSW)
c
      JI0 =  ipKW (KWI_LI0, KOP, KSW)
      JI9 =  ipKW (KWI_LI9, KOP, KSW)
      JIA =  ipKW (KWI_OFI, KOP, KSW)
      JC0 =  ipKW (KWI_LC0, KOP, KSW)
      JC9 =  ipKW (KWI_LC9, KOP, KSW)
      JCS =  ipKW (KWI_LCS, KOP, KSW)
      JCA =  ipKW (KWI_OFC, KOP, KSW)
      KO  =  ipKW (KWI_KWO, KOP, KSW)
      KA  =  ipKW (KWI_KWA, KOP, KSW)
      KC  = 1
c
      call AKXwbz
     O    (Z,
     I     X,  KXO, KXA, JI0, JI9,      JIA,
     I     CV, KC,       JC0, JC9, JCS, JCA,
     I     WW, KO,  KA,
     I     MH, LH)
c
      RETURN
      END
CCC_ & AKBubx  ## Weighted add [x] (two x) user weight
      subroutine AKBubx
     O    (X,    CV,
     I     WU,
     I     MH,   LH,  KL,  KXO, KXA, KWO, KWA,
     I     ipKW, iMA, KOP, KSW)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)  MH, LH
      _INTENT(OUT,_REALSTD) X  (LH, *)
      _INTENT(OUT,_REALSTD) CV (LH, *)
      _INTENT(IN, _REALSTD) WU (LH, *)
      _INTENT(IN, integer)  KL
      _INTENT(IN, integer)  KXO, KXA
      _INTENT(IN, integer)  KWO, KWA
      _INTENT(IN, integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN, integer)  iMA  (*)
      _INTENT(IN, integer)  KOP, KSW
      integer JI0, JI9,      JIA
      integer JC0, JC9, JCS, JCA
      integer KC
CCC_  - Body
      call AKCupx
     O    (CV,
     I     X,    MH,   LH,  KXA,
     I     ipKW, iMA,  KOP, KSW)
c
      JI0 =  ipKW (KWI_LI0, KOP, KSW)
      JI9 =  ipKW (KWI_LI9, KOP, KSW)
      JIA =  ipKW (KWI_OFI, KOP, KSW)
      JC0 =  ipKW (KWI_LC0, KOP, KSW)
      JC9 =  ipKW (KWI_LC9, KOP, KSW)
      JCS =  ipKW (KWI_LCS, KOP, KSW)
      JCA =  ipKW (KWI_OFC, KOP, KSW)
      KC  =  1
c
      call AKXwbx
     O    (X,  KL,  KXO, KXA, JI0, JI9,      JIA,
     I     CV, KC,            JC0, JC9, JCS, JCA,
     I     WU, KWO, KWA,
     I     MH, LH)
c
      RETURN
      END
CCC_ & AKBubz  ## Weighted add [z] (two x) user weight
      subroutine AKBubz
     O    (Z,    CV,
     I     X,    WU,
     I     MH,   LH,  KXO, KXA, KWO, KWA,
     I     ipKW, iMA, KOP, KSW)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)  MH, LH
      _INTENT(OUT,_REALSTD) Z  (LH)
      _INTENT(OUT,_REALSTD) CV (LH, *)
      _INTENT(IN, _REALSTD) X  (LH, *)
      _INTENT(IN, _REALSTD) WU (LH, *)
      _INTENT(IN, integer)  KXO, KXA
      _INTENT(IN, integer)  KWO, KWA
      _INTENT(IN, integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN, integer)  iMA  (*)
      _INTENT(IN, integer)  KOP, KSW
      integer JI0, JI9,      JIA
      integer JC0, JC9, JCS, JCA
      integer KC
CCC_  - Body
      call AKCupx
     O    (CV,
     I     X,    MH,   LH,  KXA,
     I     ipKW, iMA,  KOP, KSW)
c
      JI0 =  ipKW (KWI_LI0, KOP, KSW)
      JI9 =  ipKW (KWI_LI9, KOP, KSW)
      JIA =  ipKW (KWI_OFI, KOP, KSW)
      JC0 =  ipKW (KWI_LC0, KOP, KSW)
      JC9 =  ipKW (KWI_LC9, KOP, KSW)
      JCS =  ipKW (KWI_LCS, KOP, KSW)
      JCA =  ipKW (KWI_OFC, KOP, KSW)
      KC  =  1
c
      call AKXwbz
     O    (Z,
     I     X,  KXO, KXA, JI0, JI9,      JIA,
     I     CV, KC,       JC0, JC9, JCS, JCA,
     I     WU, KWO, KWA,
     I     MH, LH)
c
      RETURN
      END
CCC_ & AKBtbx  ## Weighted add [x] (two x) user weight, transpose
      subroutine AKBtbx
     M    (X,    CV,
     I     WU,
     I     MH,   LH,  KXL, KXO, KXA, KWO, KWA,
     I     KXT1, KXT2,
     I     ipKW, iMA, KOP, KSW)
CCC_  - Description
CC    Need two work region in X [KXT1, KXT2]
CC    Weight are in WU [KWO, KWA]
CC
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH
      _INTENT(INOUT,_REALSTD) X  (LH, *)
      _INTENT(OUT,  _REALSTD) CV (LH, *)
      _INTENT(IN,   _REALSTD) WU (LH, *)
      _INTENT(IN,   integer)  KXL,  KXO, KXA
      _INTENT(IN,   integer)  KWO,  KWA
      _INTENT(IN,   integer)  KXT1, KXT2
      _INTENT(IN,   integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN,   integer)  iMA  (*)
      _INTENT(IN,   integer)  KOP, KSW
      integer jh
CCC_  - Body
CCC_   . T1: diagonal * input
      do jh = 1, MH
         X (jh, KXT1) = X (jh, KXO) * WU (jh, KWO)
      enddo
CCC_   . T2: off diagonal * input
      do jh = 1, MH
         X (jh, KXT2) = X (jh, KXA) * WU (jh, KWA)
      enddo
CCC_   . simple add
      call AKBsbx
     M    (X,    CV,
     I     MH,   LH,  KXL, KXT1, KXT2,
     I     ipKW, iMA, KOP, KSW)
      RETURN
      END
CCC_ & AKBwdx  ## Weighted add [x] diagonal
      subroutine AKBwdx
     M    (X,
     I     WW,
     I     MH,   LH,  KL,  KR,
     I     ipKW, iMA, KOP, KSW)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  KL, KR
      _INTENT(INOUT,_REALSTD) X  (LH, *)
      _INTENT(IN,   _REALSTD) WW (LH, *)
      _INTENT(IN,   integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN,   integer)  iMA  (*)
      _INTENT(IN,   integer)  KOP, KSW
      integer KO
CCC_  - Body
      KO  =  ipKW (KWI_KWO, KOP, KSW)
c
      call AKXwdx
     M    (X,  KL, KR,
     I     WW, KO,
     I     MH, LH)
      RETURN
      END
CCC_ & AKBudx  ## Weighted add [x] diagonal user weight
      subroutine AKBudx
     M    (X,
     I     WU,
     I     MH,   LH,  KL,  KR, KWO,
     I     ipKW, iMA, KOP, KSW)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  KL, KR, KWO
      _INTENT(INOUT,_REALSTD) X  (LH, *)
      _INTENT(IN,   _REALSTD) WU (LH, *)
      _INTENT(IN,   integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN,   integer)  iMA  (*)
      _INTENT(IN,   integer)  KOP, KSW
CCC_  - Body
      call AKXwdx
     M    (X,  KL,  KR,
     I     WU, KWO,
     I     MH, LH)
      RETURN
      END
CCC_ & AKBtex  ## Weighted add [x] off diagonal, user weight, transpose
      subroutine AKBtex
     M    (X,    CV,
     I     WU,
     I     MH,   LH,  KXL, KXA, KWA,
     I     KXT1,
     I     ipKW, iMA, KOP, KSW)
CCC_  - Description
CC    Need two work region in X [KXT1]
CC    Weight are in WU [KWA]
CC
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH
      _INTENT(INOUT,_REALSTD) X  (LH, *)
      _INTENT(OUT,  _REALSTD) CV (LH, *)
      _INTENT(IN,   _REALSTD) WU (LH, *)
      _INTENT(IN,   integer)  KXL,  KXA
      _INTENT(IN,   integer)  KWA
      _INTENT(IN,   integer)  KXT1
      _INTENT(IN,   integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN,   integer)  iMA  (*)
      _INTENT(IN,   integer)  KOP, KSW
      integer jh
CCC_  - Body
CCC_   . T2: off diagonal * input
      do jh = 1, MH
         X (jh, KXT1) = X (jh, KXA) * WU (jh, KWA)
      enddo
CCC_   . shift
      call AKBmex
     M    (X,    CV,
     I     MH,   LH,  KXL, KXT1,
     I     ipKW, iMA, KOP, KSW)
      RETURN
      END
CCC_ & AKBwex  ## Weighted add [x] off-diagonal
      subroutine AKBwex
     M    (X,    CV,
     I     WW,
     I     MH,   LH,  KL,  KR,
     I     ipKW, iMA, KOP, KSW)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  KL, KR
      _INTENT(INOUT,_REALSTD) X  (LH, *)
      _INTENT(OUT,  _REALSTD) CV (LH)
      _INTENT(IN,   _REALSTD) WW (LH, *)
      _INTENT(IN,   integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN,   integer)  iMA  (*)
      _INTENT(IN,   integer)  KOP, KSW
      integer JI0, JI9,      JIA
      integer JC0, JC9, JCS, JCA
      integer KA,  KC
CCC_  - Body
      call AKCupx
     O    (CV,
     I     X,    MH,   LH,  KR,
     I     ipKW, iMA,  KOP, KSW)
c
      JI0 =  ipKW (KWI_LI0, KOP, KSW)
      JI9 =  ipKW (KWI_LI9, KOP, KSW)
      JIA =  ipKW (KWI_OFI, KOP, KSW)
      JC0 =  ipKW (KWI_LC0, KOP, KSW)
      JC9 =  ipKW (KWI_LC9, KOP, KSW)
      JCS =  ipKW (KWI_LCS, KOP, KSW)
      JCA =  ipKW (KWI_OFC, KOP, KSW)
      KA  =  ipKW (KWI_KWA, KOP, KSW)
      KC  =  1
c
      call AKXwex
     M    (X,   KL, KR, JI0, JI9,      JIA,
     I     CV,  KC,     JC0, JC9, JCS, JCA,
     I     WW,  KA,
     I     MH,  LH)
c
      RETURN
      END
CCC_ & AKBwez  ## Weighted add [z] off-diagonal
      subroutine AKBwez
     O    (Z,    CV,
     I     X,    WW,
     I     MH,   LH,
     I     ipKW, iMA, KOP, KSW)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)  MH, LH
      _INTENT(OUT,_REALSTD) Z  (LH)
      _INTENT(OUT,_REALSTD) CV (LH)
      _INTENT(IN, _REALSTD) X  (LH)
      _INTENT(IN, _REALSTD) WW (LH, *)
      _INTENT(IN, integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN, integer)  iMA  (*)
      _INTENT(IN, integer)  KOP, KSW
      integer JI0, JI9,      JIA
      integer JC0, JC9, JCS, JCA
      integer KA,  KC,  KR
CCC_  - Body
      KR = 1
      call AKCupx
     O    (CV,
     I     X,    MH,   LH,  KR,
     I     ipKW, iMA,  KOP, KSW)
c
      JI0 =  ipKW (KWI_LI0, KOP, KSW)
      JI9 =  ipKW (KWI_LI9, KOP, KSW)
      JIA =  ipKW (KWI_OFI, KOP, KSW)
      JC0 =  ipKW (KWI_LC0, KOP, KSW)
      JC9 =  ipKW (KWI_LC9, KOP, KSW)
      JCS =  ipKW (KWI_LCS, KOP, KSW)
      JCA =  ipKW (KWI_OFC, KOP, KSW)
      KA  =  ipKW (KWI_KWA, KOP, KSW)
      KC  =  1
c
      call AKXwez
     O    (Z,
     I     X,       JI0, JI9,      JIA,
     I     CV,  KC, JC0, JC9, JCS, JCA,
     I     WW,  KA,
     I     MH,  LH)
c
      RETURN
      END
CCC_ & AKBfax  ## factored add [x]
      subroutine AKBfax
     M    (X,    CV,
     I     F,
     I     MH,   LH,  KL,  KR,
     I     ipKW, iMA, KOP, KSW)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  KL, KR
      _INTENT(INOUT,_REALSTD) X  (LH, *)
      _INTENT(OUT,  _REALSTD) CV (LH, *)
      _INTENT(IN,   _REALSTD) F
      _INTENT(IN,   integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN,   integer)  iMA  (*)
      _INTENT(IN,   integer)  KOP, KSW
      integer JI0, JI9,      JIA
      integer JC0, JC9, JCS, JCA
      integer KC
CCC_  - Body
      call AKCupx
     O    (CV,
     I     X,    MH,   LH,  KR,
     I     ipKW, iMA,  KOP, KSW)
c
      JI0 =  ipKW (KWI_LI0, KOP, KSW)
      JI9 =  ipKW (KWI_LI9, KOP, KSW)
      JIA =  ipKW (KWI_OFI, KOP, KSW)
      JC0 =  ipKW (KWI_LC0, KOP, KSW)
      JC9 =  ipKW (KWI_LC9, KOP, KSW)
      JCS =  ipKW (KWI_LCS, KOP, KSW)
      JCA =  ipKW (KWI_OFC, KOP, KSW)
      KC  =  1
c
      call AKXfax
     M    (X,   KL, KR, JI0, JI9,      JIA,
     I     CV,  KC,     JC0, JC9, JCS, JCA,
     I     F,
     I     MH,  LH)
c
      RETURN
      END
CCC_ & AKBsax  ## Add [x]
      subroutine AKBsax
     M    (X,    CV,
     I     MH,   LH,  KL,  KR,
     I     ipKW, iMA, KOP, KSW)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  KL, KR
      _INTENT(INOUT,_REALSTD) X  (LH, *)
      _INTENT(OUT,  _REALSTD) CV (LH, *)
      _INTENT(IN,   integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN,   integer)  iMA  (*)
      _INTENT(IN,   integer)  KOP, KSW
      integer JI0, JI9,      JIA
      integer JC0, JC9, JCS, JCA
      integer KC
CCC_  - Body
      call AKCupx
     O    (CV,
     I     X,    MH,   LH,  KR,
     I     ipKW, iMA,  KOP, KSW)
c
      JI0 =  ipKW (KWI_LI0, KOP, KSW)
      JI9 =  ipKW (KWI_LI9, KOP, KSW)
      JIA =  ipKW (KWI_OFI, KOP, KSW)
      JC0 =  ipKW (KWI_LC0, KOP, KSW)
      JC9 =  ipKW (KWI_LC9, KOP, KSW)
      JCS =  ipKW (KWI_LCS, KOP, KSW)
      JCA =  ipKW (KWI_OFC, KOP, KSW)
      KC  =  1
c
      call AKXsax
     M    (X,   KL, KR, JI0, JI9,      JIA,
     I     CV,  KC,     JC0, JC9, JCS, JCA,
     I     MH,  LH)
c
      RETURN
      END
CCC_ & AKBsaz  ## Add [z]
      subroutine AKBsaz
     O    (Z,    CV,
     I     X,
     I     MH,   LH,
     I     ipKW, iMA, KOP, KSW)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)  MH, LH
      _INTENT(OUT,_REALSTD) Z  (LH)
      _INTENT(OUT,_REALSTD) CV (LH)
      _INTENT(IN, _REALSTD) X  (LH)
      _INTENT(IN, integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN, integer)  iMA  (*)
      _INTENT(IN, integer)  KOP, KSW
      integer JI0, JI9,      JIA
      integer JC0, JC9, JCS, JCA
      integer KC,  KR
CCC_  - Body
      KR = 1
      call AKCupx
     O    (CV,
     I     X,    MH,   LH,  KR,
     I     ipKW, iMA,  KOP, KSW)
c
      JI0 =  ipKW (KWI_LI0, KOP, KSW)
      JI9 =  ipKW (KWI_LI9, KOP, KSW)
      JIA =  ipKW (KWI_OFI, KOP, KSW)
      JC0 =  ipKW (KWI_LC0, KOP, KSW)
      JC9 =  ipKW (KWI_LC9, KOP, KSW)
      JCS =  ipKW (KWI_LCS, KOP, KSW)
      JCA =  ipKW (KWI_OFC, KOP, KSW)
      KC  =  1
c
      call AKXsaz
     O    (Z,
     I     X,       JI0, JI9,      JIA,
     I     CV,  KC, JC0, JC9, JCS, JCA,
     I     MH,  LH)
c
      RETURN
      END
CCC_ & AKBsbx  ## Add [x] (two x)
      subroutine AKBsbx
     M    (X,    CV,
     I     MH,   LH,  KL,  KXO, KXA,
     I     ipKW, iMA, KOP, KSW)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  KL, KXO, KXA
      _INTENT(INOUT,_REALSTD) X  (LH, *)
      _INTENT(OUT,  _REALSTD) CV (LH, *)
      _INTENT(IN,   integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN,   integer)  iMA  (*)
      _INTENT(IN,   integer)  KOP, KSW
      integer JI0, JI9,      JIA
      integer JC0, JC9, JCS, JCA
      integer KC
CCC_  - Body
      call AKCupx
     O    (CV,
     I     X,    MH,   LH,  KXA,
     I     ipKW, iMA,  KOP, KSW)
c
      JI0 =  ipKW (KWI_LI0, KOP, KSW)
      JI9 =  ipKW (KWI_LI9, KOP, KSW)
      JIA =  ipKW (KWI_OFI, KOP, KSW)
      JC0 =  ipKW (KWI_LC0, KOP, KSW)
      JC9 =  ipKW (KWI_LC9, KOP, KSW)
      JCS =  ipKW (KWI_LCS, KOP, KSW)
      JCA =  ipKW (KWI_OFC, KOP, KSW)
      KC  =  1
c
      call AKXsbx
     M    (X,  KL, KXO, KXA, JI0, JI9,      JIA,
     I     CV, KC,           JC0, JC9, JCS, JCA,
     I     MH, LH)
c
      RETURN
      END
CCC_ & AKBsdx  ## Difference [x]
      subroutine AKBsdx
     M    (X,    CV,
     I     MH,   LH,  KL,  KR,
     I     ipKW, iMA, KOP, KSW)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  KL, KR
      _INTENT(INOUT,_REALSTD) X  (LH, *)
      _INTENT(OUT,  _REALSTD) CV (LH, *)
      _INTENT(IN,   integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN,   integer)  iMA  (*)
      _INTENT(IN,   integer)  KOP, KSW
      integer JI0, JI9,      JIA
      integer JC0, JC9, JCS, JCA
      integer KC
CCC_  - Body
      call AKCupx
     O    (CV,
     I     X,    MH,   LH,  KR,
     I     ipKW, iMA,  KOP, KSW)
c
      JI0 =  ipKW (KWI_LI0, KOP, KSW)
      JI9 =  ipKW (KWI_LI9, KOP, KSW)
      JIA =  ipKW (KWI_OFI, KOP, KSW)
      JC0 =  ipKW (KWI_LC0, KOP, KSW)
      JC9 =  ipKW (KWI_LC9, KOP, KSW)
      JCS =  ipKW (KWI_LCS, KOP, KSW)
      JCA =  ipKW (KWI_OFC, KOP, KSW)
      KC  =  1
c
      call AKXsdx
     M    (X,  KL, KR, JI0, JI9,      JIA,
     I     CV, KC,     JC0, JC9, JCS, JCA,
     I     MH, LH)
c
      RETURN
      END
CCC_ & AKBsdz  ## Difference [z]
      subroutine AKBsdz
     O    (Z,    CV,
     I     X,
     I     MH,   LH,
     I     ipKW, iMA, KOP, KSW)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)  MH, LH
      _INTENT(OUT,_REALSTD) Z  (LH)
      _INTENT(OUT,_REALSTD) CV (LH)
      _INTENT(IN, _REALSTD) X  (LH)
      _INTENT(IN, integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN, integer)  iMA  (*)
      _INTENT(IN, integer)  KOP, KSW
      integer JI0, JI9,      JIA
      integer JC0, JC9, JCS, JCA
      integer KC,  KR
CCC_  - Body
      KR = 1
      call AKCupx
     O    (CV,
     I     X,    MH,   LH,  KR,
     I     ipKW, iMA,  KOP, KSW)
c
      JI0 =  ipKW (KWI_LI0, KOP, KSW)
      JI9 =  ipKW (KWI_LI9, KOP, KSW)
      JIA =  ipKW (KWI_OFI, KOP, KSW)
      JC0 =  ipKW (KWI_LC0, KOP, KSW)
      JC9 =  ipKW (KWI_LC9, KOP, KSW)
      JCS =  ipKW (KWI_LCS, KOP, KSW)
      JCA =  ipKW (KWI_OFC, KOP, KSW)
      KC  =  1
c
      call AKXsdz
     O    (Z,
     I     X,      JI0, JI9,      JIA,
     I     CV, KC, JC0, JC9, JCS, JCA,
     I     MH, LH)
c
      RETURN
      END
CCC_ & AKBmex  ## Shift off-diagonal [x]
      subroutine AKBmex
     M    (X,    CV,
     I     MH,   LH,  KL,  KR,
     I     ipKW, iMA, KOP, KSW)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  KL, KR
      _INTENT(INOUT,_REALSTD) X  (LH, *)
      _INTENT(OUT,  _REALSTD) CV (LH, *)
      _INTENT(IN,   integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN,   integer)  iMA  (*)
      _INTENT(IN,   integer)  KOP, KSW
      integer JI0, JI9,      JIA
      integer JC0, JC9, JCS, JCA
      integer KC
CCC_  - Body
      call AKCupx
     O    (CV,
     I     X,    MH,   LH,  KR,
     I     ipKW, iMA,  KOP, KSW)
c
      JI0 =  ipKW (KWI_LI0, KOP, KSW)
      JI9 =  ipKW (KWI_LI9, KOP, KSW)
      JIA =  ipKW (KWI_OFI, KOP, KSW)
      JC0 =  ipKW (KWI_LC0, KOP, KSW)
      JC9 =  ipKW (KWI_LC9, KOP, KSW)
      JCS =  ipKW (KWI_LCS, KOP, KSW)
      JCA =  ipKW (KWI_OFC, KOP, KSW)
      KC  =  1
c
      call AKXmex
     M    (X,  KL, KR, JI0, JI9,      JIA,
     I     CV, KC,     JC0, JC9, JCS, JCA,
     I     MH, LH)
c
      RETURN
      END
CCC_ & AKBmez  ## Shift off-diagonal [z]
      subroutine AKBmez
     O    (Z,    CV,
     I     X,
     I     MH,   LH,
     I     ipKW, iMA, KOP, KSW)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)  MH, LH
      _INTENT(OUT,_REALSTD) Z  (LH)
      _INTENT(OUT,_REALSTD) CV (LH)
      _INTENT(IN, _REALSTD) X  (LH)
      _INTENT(IN, integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN, integer)  iMA  (*)
      _INTENT(IN, integer)  KOP, KSW
      integer JI0, JI9,      JIA
      integer JC0, JC9, JCS, JCA
      integer KC,  KR
CCC_  - Body
      KR = 1
      call AKCupx
     O    (CV,
     I     X,    MH,   LH,  KR,
     I     ipKW, iMA,  KOP, KSW)
c
      JI0 =  ipKW (KWI_LI0, KOP, KSW)
      JI9 =  ipKW (KWI_LI9, KOP, KSW)
      JIA =  ipKW (KWI_OFI, KOP, KSW)
      JC0 =  ipKW (KWI_LC0, KOP, KSW)
      JC9 =  ipKW (KWI_LC9, KOP, KSW)
      JCS =  ipKW (KWI_LCS, KOP, KSW)
      JCA =  ipKW (KWI_OFC, KOP, KSW)
      KC  =  1
c
      call AKXmez
     O    (Z,
     I     X,       JI0, JI9,      JIA,
     I     CV, KC,  JC0, JC9, JCS, JCA,
     I     MH, LH)
c
      RETURN
      END
CCC_ & AKBmey  ## Shift off-diagonal [y]
      subroutine AKBmey
     O    (Z,    CV,
     I     X,
     I     MH,   LH,  MO,  LO, KOS,
     I     ipKW, iMA, KOP, KSW)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)  MH, LH
      _INTENT(IN, integer)  MO, LO, KOS
      _INTENT(OUT,_REALSTD) Z  (LH, LO)
      _INTENT(OUT,_REALSTD) CV (LH, LO)
      _INTENT(IN, _REALSTD) X  (LH, LO)
      _INTENT(IN, integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN, integer)  iMA  (*)
      _INTENT(IN, integer)  KOP, KSW
      integer JI0, JI9,      JIA
      integer JC0, JC9, JCS, JCA
      integer KC,  KR
CCC_  - Body
      KR = 1
      call AKCupw
     O    (CV,
     I     X,    MH,   LH,  MO, LO, KOS, KR,
     I     ipKW, iMA,  KOP, KSW)
c
      JI0 =  ipKW (KWI_LI0, KOP, KSW)
      JI9 =  ipKW (KWI_LI9, KOP, KSW)
      JIA =  ipKW (KWI_OFI, KOP, KSW)
      JC0 =  ipKW (KWI_LC0, KOP, KSW)
      JC9 =  ipKW (KWI_LC9, KOP, KSW)
      JCS =  ipKW (KWI_LCS, KOP, KSW)
      JCA =  ipKW (KWI_OFC, KOP, KSW)
      KC  =  1
c
      call AKXmey
     O    (Z,
     I     X,       JI0, JI9,      JIA,
     I     CV, KC,  JC0, JC9, JCS, JCA,
     I     MH, LH,  MO,  LO,  KOS)
c
      RETURN
      END
CCC_ & AKBmew  ## Shift off-diagonal [w]
      subroutine AKBmew
     M    (X,    CV,
     I     MH,   LH,  MO,  LO, KOS,  KXL, KXR,
     I     ipKW, iMA, KOP, KSW)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  MO, LO, KOS
      _INTENT(INOUT,_REALSTD) X  (LH, LO)
      _INTENT(OUT,  _REALSTD) CV (LH, LO)
      _INTENT(IN,   integer)  KXL, KXR
      _INTENT(IN,   integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN,   integer)  iMA  (*)
      _INTENT(IN,   integer)  KOP, KSW
      integer JI0, JI9,      JIA
      integer JC0, JC9, JCS, JCA
      integer KC
CCC_  - Body
      call AKCupw
     O    (CV,
     I     X,    MH,   LH,  MO, LO, KOS, KXR,
     I     ipKW, iMA,  KOP, KSW)
c
      JI0 =  ipKW (KWI_LI0, KOP, KSW)
      JI9 =  ipKW (KWI_LI9, KOP, KSW)
      JIA =  ipKW (KWI_OFI, KOP, KSW)
      JC0 =  ipKW (KWI_LC0, KOP, KSW)
      JC9 =  ipKW (KWI_LC9, KOP, KSW)
      JCS =  ipKW (KWI_LCS, KOP, KSW)
      JCA =  ipKW (KWI_OFC, KOP, KSW)
      KC  =  1
c
      call AKXmew
     O    (X,  KXL, KXR, JI0, JI9,      JIA,
     I     CV, KC,       JC0, JC9, JCS, JCA,
     I     MH, LH,  MO,  LO,  KOS)
c
      RETURN
      END
CCC_ & AKBomx  ## Odd-field mask (x)
      subroutine AKBomx
     M    (X,    CV,
     I     WW,
     I     MH,   LH,  KL, KR,
     I     ipKW, iMA, KOP)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  KL, KR
      _INTENT(INOUT,_REALSTD) X  (LH, *)
      _INTENT(OUT,  _REALSTD) CV (LH, *)
      _INTENT(IN,   integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN,   _REALSTD) WW (LH, *)
      _INTENT(IN,   integer)  iMA  (*)
      _INTENT(IN,   integer)  KOP
      integer KO
      integer KSW
      integer jh
CCC_  - Body
      KSW = KWM_M
      KO  = ipKW (KWI_KWO, KOP, KSW)
      do jh = 1, MH
         X (jh, KL) = WW (jh, KO) * X (jh, KR)
      enddo
      RETURN
      END
CCC_ & AKBomw  ## Odd-field mask (w)
      subroutine AKBomw
     M    (X,    CV,
     I     WW,
     I     MH,   LH,  MO, LO,  KOS, KL, KR,
     I     ipKW, iMA, KOP)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  MH,  LH
      _INTENT(IN,   integer)  MO,  LO,  KOS
      _INTENT(IN,   integer)  KL, KR
      _INTENT(INOUT,_REALSTD) X  (LH, LO, *)
      _INTENT(OUT,  _REALSTD) CV (LH, LO, *)
      _INTENT(IN,   integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN,   _REALSTD) WW (LH, *)
      _INTENT(IN,   integer)  iMA  (*)
      _INTENT(IN,   integer)  KOP
      integer KWO
      integer KSW
      integer jh, jo
CCC_  - Body
      KSW = KWM_M
      KWO  = ipKW (KWI_KWO, KOP, KSW)
      do    jo = KOS, KOS + MO - 1
         do jh = 1, MH
            X (jh, jo, KL) = WW (jh, KWO) * X (jh, jo, KR)
         enddo
      enddo
      RETURN
      END
CCC_ & AKBinz  ## Count operation [z]
      subroutine AKBinz
     O    (Z,
     I     MH,   LH,
     I     ipKW, KOP, KSW)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)  MH, LH
      _INTENT(OUT,_REALSTD) Z  (LH)
      _INTENT(IN, integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN, integer)  KOP, KSW
      integer JI0, JI9
      integer JC0, JC9, JCS
CCC_  - Body
      JI0 =  ipKW (KWI_LI0, KOP, KSW)
      JI9 =  ipKW (KWI_LI9, KOP, KSW)
      JC0 =  ipKW (KWI_LC0, KOP, KSW)
      JC9 =  ipKW (KWI_LC9, KOP, KSW)
      JCS =  ipKW (KWI_LCS, KOP, KSW)
c
      call AKXinz
     O    (Z,
     I     JI0, JI9, JC0,  JC9, JCS,
     I     MH,  LH)
c
      RETURN
      END
CCC_* [AKC] Clone maninuplation
CCC_ & AKCgrs  ## Kiwi/Clone group (cluster) initialization
      subroutine AKCgrs
     O    (iErr,
     O     ipCG, LCG)
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(IN, integer) LCG
      _INTENT(OUT,integer) ipCG (LCG)
      call AKCgro (iErr, ipCG, LCG, 0)
      RETURN
      END
CCC_ & AKCgro  ## Kiwi/Clone group (cluster) initialization (with offset)
      subroutine AKCgro
     O    (iErr,
     O     ipCG, LCG, KOFS)
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(IN, integer) LCG
      _INTENT(OUT,integer) ipCG (LCG)
      _INTENT(IN, integer) KOFS
      integer j
      iErr = 0
      do j = 1, LCG
         ipCG (j) = 0
      enddo
      ipCG (KWCG_OFS) = KOFS
      RETURN
      END
CCC_ & AKCgad  ## Kiwi/Clone group (cluster) add operation
      subroutine AKCgad
     O    (iErr,
     O     ipCG,
     I     KOP, KSW, LCG)
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(IN, integer) LCG
      _INTENT(OUT,integer) ipCG (LCG)
      _INTENT(IN, integer) KOP, KSW
      integer nop, jpo, jps, jpg
      iErr = 0
      nop = ipCG (KWCG_NOP)
      nop = nop + 1
      jpo  = KWCG_KOP(nop)
      jps  = KWCG_KSW(nop)
      jpg  = KWCG_GID(nop)
      if (jpg.gt.LCG) then
         iErr = -1
      else
         ipCG (jpo) = KOP
         ipCG (jps) = KSW
         ipCG (jpg) = -1
      endif
      ipCG (KWCG_NOP) = nop
      RETURN
      END
CCC_ & AKCgqo  ## Kiwi/Clone group operation inquiry
      subroutine AKCgqo
     O    (iErr,
     O     KOP,  KSW, KCG,
     I     ipCG, iGO)
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(OUT,integer) KOP, KSW, KCG
      _INTENT(IN, integer) ipCG (*)
      _INTENT(IN, integer) iGO
      integer jpo, jps
      integer jgi
      iErr = 0
      jpo  = KWCG_KOP(iGO)
      jps  = KWCG_KSW(iGO)
      jgi  = KWCG_GID(iGO)
c$$$      KOP =  ipCG (KWCG_KOP(jOpr))
c$$$      KSW =  ipCG (KWCG_KSW(jOpr))
c$$$      KCG =  ipCG (KWCG_GID(jOpr)) + ipCG (KWCG_OFS)
c
      KOP = ipCG (jpo)
      KSW = ipCG (jps)
      KCG = ipCG (jgi) + ipCG (KWCG_OFS)
c
      RETURN
      END
CCC_ & AKCgso  ## Kiwi/Clone group (cluster) stencil binder (return offset)
      subroutine AKCgso
     O    (iErr,
     O     Noff,
     O     ipCG,
     W     kDTA,
     I     LCG,  LTBL, LHP,
     I     ipKW, IE,   IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer) iErr
      _INTENT(OUT,  integer) Noff
      _INTENT(IN,   integer) LCG, LTBL, LHP
      _INTENT(INOUT,integer) ipCG (LCG)
      _INTENT(IN,   integer) ipKW (IPKW_FULL_DECL)
      _INTENT(IN,   integer) IE (*)
      _INTENT(OUT,  integer) kDTA (LTBL, 3)
      _INTENT(IN,   integer) IFPl
      call AKCgsb
     O    (iErr,
     O     ipCG,
     W     kDTA,
     I     LCG,  LTBL, LHP,
     I     ipKW, IE,   IFPl)
      Noff = ipCG (KWCG_OFS) + ipCG (KWCG_NGR)
      RETURN
      END
CCC_ & AKCgsb  ## Kiwi/Clone group (cluster) stencil binder
      subroutine AKCgsb
     O    (iErr,
     O     ipCG,
     W     kDTA,
     I     LCG,  LTBL, LHP,
     I     ipKW, IE,   IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer) iErr
      _INTENT(IN,   integer) LCG, LTBL, LHP
      _INTENT(INOUT,integer) ipCG (LCG)
      _INTENT(IN,   integer) ipKW (IPKW_FULL_DECL)
      _INTENT(IN,   integer) IE (*)
      _INTENT(OUT,  integer) kDTA (LTBL, 3)
      _INTENT(IN,   integer) IFPl
      integer nop, ngr, kof
      integer jo,  jc, kc
      integer jOPR, JMSW, jRNK
      integer kWS,  kWW,  kWE,  kWN,  KS
      integer jrs,  jrd,  kss,  ksd
      character TSO*(8)
CCC_  - Body
      iErr = 0
      kof  = ipCG (KWCG_OFS)
      nop  = ipCG (KWCG_NOP)
CCC_   . collect operations with same source rank
      ngr = 0
      do jo = 1, nop
         jOPR = ipCG (KWCG_KOP(jo))
         jMSW = ipCG (KWCG_KSW(jo))
         jRNK = ipKW (KWC_IRS, jOPR, jMSW)
         kc = 0
CCC_   . search through assigned operation
         do jc = 1, ngr
            if (jRNK .eq. ipCG (KWCG_IRS(ipCG,jc))) then
               kc = jc
               goto 100
            endif
         enddo
 100     continue
         if (kc.eq.0) then
            ngr = ngr + 1
            kc  = ngr
            ipCG (KWCG_IRS(ipCG,kc)) = ipKW (KWC_IRS, jOPR, jMSW)
            ipCG (KWCG_IRD(ipCG,kc)) = ipKW (KWC_IRD, jOPR, jMSW)
         endif
         ipCG (KWCG_GID(jo)) = kc
      enddo
      ipCG (KWCG_NGR) = ngr
      if (KWCG_TPD(ipCG,ngr).gt.LCG) iErr = -1
CCC_   . create stencils for each clone group
      do kc = 1, ngr
         if (iErr.eq.0) then
            KWS = 0
            KWW = 0
            KWE = 0
            KWN = 0
            do jo = 1, nop
               if (ipCG (KWCG_GID(jo)).eq.kc) then
                  jOPR = ipCG (KWCG_KOP(jo))
                  jMSW = ipCG (KWCG_KSW(jo))
                  KWS = MAX (KWS, ipKW (KWC_CWS, jOPR, jMSW))
                  KWW = MAX (KWW, ipKW (KWC_CWW, jOPR, jMSW))
                  KWE = MAX (KWE, ipKW (KWC_CWE, jOPR, jMSW))
                  KWN = MAX (KWN, ipKW (KWC_CWN, jOPR, jMSW))
               endif
            enddo
            call AEScmt
     O          (iErr, KS,   kDTA, LTBL,
     I           kWS,  kWW,  kWE,  kWN,  LHP,  IE,  IFPl)
C                S     W     E     N
         endif
         if (iErr.eq.0) then
            ipCG (KWCG_TPS(ipCG,kc)) = KS
            ipCG (KWCG_TPD(ipCG,kc)) = KS
         endif
      enddo
CCC_   . log
 101  format ('AKCGSB: ',  I4, 1x, I4, 1x, I4)
 102  format ('AKCGSBo: ', I4, 1x, A, 1x, I4)
 103  format ('AKCGSBg: ', I4, 1x, 2I4, 1x, 2I12)
      if      (COND_N(IFPl))  then
         write (IFPl, 101) nop, ngr, kof
         do jo = 1, nop
            jOPR = ipCG (KWCG_KOP(jo))
            jMSW = ipCG (KWCG_KSW(jo))
            kc   = ipCG (KWCG_GID(jo))
            call AKPo2s (TSO, jOPR, jMSW, '/')
            write (IFPl, 102) jo, _TRIM(TSO), kc
         enddo
         do kc = 1, ngr
            jrs = ipCG (KWCG_IRS(ipCG,kc))
            jrd = ipCG (KWCG_IRD(ipCG,kc))
            kss = ipCG (KWCG_TPS(ipCG,kc))
            ksd = ipCG (KWCG_TPD(ipCG,kc))
            write (IFPl, 103) kc, jrs, jrd, kss, ksd
         enddo
      else if (COND_S(IFPl)) then
#        define IFPl  *
         write (IFPl, 101) nop, ngr
         do jo = 1, nop
            jOPR = ipCG (KWCG_KOP(jo))
            jMSW = ipCG (KWCG_KSW(jo))
            kc   = ipCG (KWCG_GID(jo))
            call AKPo2s (TSO, jOPR, jMSW, '/')
            write (IFPl, 102) jo, _TRIM(TSO), kc
         enddo
         do kc = 1, ngr
            jrs = ipCG (KWCG_IRS(ipCG,kc))
            jrd = ipCG (KWCG_IRD(ipCG,kc))
            kss = ipCG (KWCG_TPS(ipCG,kc))
            ksd = ipCG (KWCG_TPD(ipCG,kc))
            write (IFPl, 103) kc, jrs, jrd, kss, ksd
         enddo
#        undef IFPl
      endif
      RETURN
      END
CCC_ & AKCgch  ## Clone group check
      subroutine AKCgch
     O    (iErr,
     I     CG,
     I     WW,  MH,  LH, MO, ipCG, ipKW,
     I     POS, VAR, IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)    iErr
      _INTENT(IN, integer)    MH, LH, MO
      _INTENT(IN, _REALSTD)   CG (*)
      _INTENT(IN, _REALSTD)   WW (*)
      _INTENT(IN, integer)    ipCG (*), ipKW (*)
      _INTENT(IN, character)  POS*(*), VAR*(*)
      _INTENT(IN, integer)    IFPl
      integer ngr, kg
      ngr    = ipCG(KWCG_NGR)
      do kg = 1, ngr
         call AKVchl
     $        (iErr, CG, POS,VAR, kg, ipKW,WW,MH,LH,MO,' ', IFPl)
      enddo
      RETURN
      END
CCC_ & AKCgnl  ## Clone group reset
      subroutine AKCgnl
     O    (CG,
     I     MH, LH, MO, LO, ipCG)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)  MH, LH, MO, LO
      _INTENT(OUT,_REALSTD) CG (*)
      _INTENT(IN, integer)  ipCG (*)
      integer ngr, kg
      integer NV,  LV
CCC_  - Body
      ngr    = ipCG(KWCG_NGR)
      NV     = LH * MO
      LV     = LH * LO
      do kg = 1, ngr
         call UV0sta (CG, NV, LV, kg, 0.0d0)
      enddo
      RETURN
      END
CCC_ & AKCguw  ## Clone group update (w)
      subroutine AKCguw
     O    (CG,
     I     X,    MH,   LH,  MO, LO, KOS, KXR,
     I     iMA,  ipCG)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)  MH, LH
      _INTENT(IN, integer)  MO, LO, KOS, KXR
      _INTENT(OUT,_REALSTD) CG (LH, LO, *)
      _INTENT(IN, _REALSTD) X  (LH, LO, *)
      _INTENT(IN, integer)  iMA (*), ipCG (*)
      integer IRto, IRfrom
      integer KSto, KSfrom
      integer jErr
      integer NV
      integer ngr, kg, kxo
c$$$      integer jh, jo
CCC_  - Body
      NV  = LH * MO
      ngr = ipCG (KWCG_NGR)
      kg  = 1
      kxo = ipCG (KWCG_OFS)
c$$$      write (*, *) 'GUW',MH,LH,MO,LO,KOS,KXR
CCC_   . kg:1
      if (ngr.ge.kg) then
         IRto   = ipCG (KWCG_IRD(ipCG,kg))
         IRfrom = ipCG (KWCG_IRS(ipCG,kg))
         KSto   = ipCG (KWCG_TPD(ipCG,kg))
         KSfrom = ipCG (KWCG_TPS(ipCG,kg))
c$$$         CG (:, :,kxo+kg)=0.0d0
         call DMDcsr
     O       (jErr, CG (1,KOS,kxo+kg),
     I        X (1,KOS,KXR), IRfrom,IRto,NV,KSfrom,KSto,MO,iMA)
         kg = kg + 1
CCC_   . kg:2
         if (ngr.ge.kg) then
            IRto   = ipCG (KWCG_IRD(ipCG,kg))
            IRfrom = ipCG (KWCG_IRS(ipCG,kg))
            KSto   = ipCG (KWCG_TPD(ipCG,kg))
            KSfrom = ipCG (KWCG_TPS(ipCG,kg))
c$$$            CG (:, :,kxo+kg)=0.0d0
            call DMDcsr
     O          (jErr, CG (1,KOS,kxo+kg),
     I           X (1,KOS,KXR), IRfrom,IRto,NV,KSfrom,KSto,MO,iMA)
            kg = kg + 1
CCC_   . kg:3
            if (ngr.ge.kg) then
               IRto   = ipCG (KWCG_IRD(ipCG,kg))
               IRfrom = ipCG (KWCG_IRS(ipCG,kg))
               KSto   = ipCG (KWCG_TPD(ipCG,kg))
               KSfrom = ipCG (KWCG_TPS(ipCG,kg))
c$$$               CG (:, :,kxo+kg)=0.0d0
               call DMDcsr
     O             (jErr, CG (1,KOS,kxo+kg),
     I              X (1,KOS,KXR), IRfrom,IRto,NV,KSfrom,KSto,MO,iMA)
               kg = kg + 1
CCC_   . kg:4 loop
               do kg = kg, ngr
                  IRto   = ipCG (KWCG_IRD(ipCG,kg))
                  IRfrom = ipCG (KWCG_IRS(ipCG,kg))
                  KSto   = ipCG (KWCG_TPD(ipCG,kg))
                  KSfrom = ipCG (KWCG_TPS(ipCG,kg))
c$$$                  CG (:, :,kxo+kg)=0.0d0
                  call DMDcsr
     O                (jErr, CG (1,KOS,kxo+kg),
     I                 X (1,KOS,KXR), IRfrom,IRto,NV,KSfrom,KSto,MO,iMA)
               enddo
            endif
         endif
      endif
c$$$      do kg = 1, ngr
c$$$         do jo = 1, LO
c$$$            do jh = 1, LH
c$$$               write (*, *) 'CG', kxo+kg, jh,jo, CG (jh,jo,kxo+kg)
c$$$            enddo
c$$$         enddo
c$$$      enddo
      RETURN
      END
CCC_ & AKCgux  ## Clone group update (x)
      subroutine AKCgux
     O    (CG,
     I     X,    MH,   LH,   KR,
     I     iMA,  ipCG)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)  MH, LH, KR
      _INTENT(OUT,_REALSTD) CG (*)
      _INTENT(IN, _REALSTD) X  (LH, *)
      _INTENT(IN, integer)  iMA (*), ipCG (*)
      integer IRto, IRfrom
      integer KSto, KSfrom
      integer jErr
      integer NV,  MO
      integer ngr, kg, ko
CCC_  - Body
      MO     = 1
      NV     = LH * MO
      ngr    = ipCG (KWCG_NGR)
      kg     = 1
      ko     = ipCG (KWCG_OFS)
CCC_   . kg:1
      if (ngr.ge.kg) then
         IRto   = ipCG (KWCG_IRD(ipCG,kg))
         IRfrom = ipCG (KWCG_IRS(ipCG,kg))
         KSto   = ipCG (KWCG_TPD(ipCG,kg))
         KSfrom = ipCG (KWCG_TPS(ipCG,kg))
         call DMDcsr
     O       (jErr, CG (1 + (ko + kg - 1) * NV),
     I        X (1,KR), IRfrom, IRto, NV, KSfrom, KSto, MO, iMA)
         kg = kg + 1
CCC_   . kg:2
         if (ngr.ge.kg) then
            IRto   = ipCG (KWCG_IRD(ipCG,kg))
            IRfrom = ipCG (KWCG_IRS(ipCG,kg))
            KSto   = ipCG (KWCG_TPD(ipCG,kg))
            KSfrom = ipCG (KWCG_TPS(ipCG,kg))
            call DMDcsr
     O          (jErr, CG (1 + (ko + kg - 1) * NV),
     I           X (1,KR), IRfrom, IRto, NV, KSfrom, KSto, MO, iMA)
            kg = kg + 1
CCC_   . kg:3
            if (ngr.ge.kg) then
               IRto   = ipCG (KWCG_IRD(ipCG,kg))
               IRfrom = ipCG (KWCG_IRS(ipCG,kg))
               KSto   = ipCG (KWCG_TPD(ipCG,kg))
               KSfrom = ipCG (KWCG_TPS(ipCG,kg))
               call DMDcsr
     O             (jErr, CG (1 + (ko + kg - 1) * NV),
     I              X (1,KR), IRfrom, IRto, NV, KSfrom, KSto, MO, iMA)
               kg = kg + 1
CCC_   . kg:4 loop
               do kg = kg, ngr
                  IRto   = ipCG (KWCG_IRD(ipCG,kg))
                  IRfrom = ipCG (KWCG_IRS(ipCG,kg))
                  KSto   = ipCG (KWCG_TPD(ipCG,kg))
                  KSfrom = ipCG (KWCG_TPS(ipCG,kg))
                  call DMDcsr
     O                (jErr, CG (1 + (ko + kg - 1) * NV),
     I                 X (1,KR), IRfrom,IRto,NV,KSfrom,KSto,MO,iMA)
               enddo
            endif
         endif
      endif
      RETURN
      END
CCC_ & AKCguz  ## Clone group [z]
      subroutine AKCguz
     O    (CG,
     I     X,    MH,   LH,
     I     iMA,  ipCG)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)  MH, LH
      _INTENT(OUT,_REALSTD) CG (*)
      _INTENT(IN, _REALSTD) X  (LH)
      _INTENT(IN, integer)  iMA (*), ipCG (*)
      integer KR
CCC_  - Body
      KR = 1
      call AKCgux
     O    (CG,
     I     X,    MH,   LH,  KR,
     I     iMA,  ipCG)
      RETURN
      END
CCC_ & AKCupx  ## Clone single [x]
      subroutine AKCupx
     O    (CV,
     I     X,    MH,   LH,  KR,
     I     ipKW, iMA,  KOP, KSW)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)  MH, LH
      _INTENT(OUT,_REALSTD) CV (LH)
      _INTENT(IN, _REALSTD) X  (LH, *)
      _INTENT(IN, integer)  KR
      _INTENT(IN, integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN, integer)  iMA  (*)
      _INTENT(IN, integer)  KOP, KSW
      integer IRto, IRfrom
      integer KSto, KSfrom
      integer jErr
      integer NV
      integer MO
CCC_  - Body
      IRto   = ipKW (KWC_IRD, KOP, KSW)
      IRfrom = ipKW (KWC_IRS, KOP, KSW)
      KSto   = ipKW (KWC_TPD, KOP, KSW)
      KSfrom = ipKW (KWC_TPS, KOP, KSW)
      NV     = LH
      MO     = 1
      call DMDcsr
     O    (jErr,    CV,
     I     X (1, KR),
     I     IRfrom,  IRto, NV, KSfrom, KSto, MO, iMA)
      RETURN
      END
CCC_ & AKCupw  ## Clone single [w]
      subroutine AKCupw
     O    (CV,
     I     X,    MH,   LH,  MO,  LO, KOS, KXR,
     I     ipKW, iMA,  KOP, KSW)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)  MH, LH
      _INTENT(IN, integer)  MO, LO, KOS
      _INTENT(IN, integer)  KXR
      _INTENT(OUT,_REALSTD) CV (LH, LO)
      _INTENT(IN, _REALSTD) X  (LH, LO, *)
      _INTENT(IN, integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN, integer)  iMA  (*)
      _INTENT(IN, integer)  KOP, KSW
      integer IRto, IRfrom
      integer KSto, KSfrom
      integer jErr
      integer NV
CCC_  - Body
      NV     = LH * MO
      IRto   = ipKW (KWC_IRD, KOP, KSW)
      IRfrom = ipKW (KWC_IRS, KOP, KSW)
      KSto   = ipKW (KWC_TPD, KOP, KSW)
      KSfrom = ipKW (KWC_TPS, KOP, KSW)
      call DMDcsr
     O    (jErr, CV (1,KOS),
     I     X (1, KOS, KXR),
     I     IRfrom,  IRto, NV, KSfrom, KSto, MO, iMA)
      RETURN
      END
CCC_ & AKCupz  ## Clone single [z]
      subroutine AKCupz
     O    (CV,
     I     X,    MH,   LH,  MO,
     I     ipKW, iMA,  KOP, KSW)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)  MH, LH, MO
      _INTENT(OUT,_REALSTD) CV (LH, MO)
      _INTENT(IN, _REALSTD) X  (LH, MO)
      _INTENT(IN, integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN, integer)  iMA  (*)
      _INTENT(IN, integer)  KOP, KSW
      integer IRto, IRfrom
      integer KSto, KSfrom
      integer jErr
      integer NV
CCC_  - Body
      NV     = LH * MO
      IRto   = ipKW (KWC_IRD, KOP, KSW)
      IRfrom = ipKW (KWC_IRS, KOP, KSW)
      KSto   = ipKW (KWC_TPD, KOP, KSW)
      KSfrom = ipKW (KWC_TPS, KOP, KSW)
      call DMDcsr
     O    (jErr,   CV,
     I     X,
     I     IRfrom, IRto, NV, KSfrom, KSto, MO, iMA)
      RETURN
      END
CCC_ & AKCxsh  ## wing shift operation batch
      subroutine AKCxsh
     M    (X,
     I     MH,   LH,  MO,
     I     ipKW, iMA)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH, MO
      _INTENT(INOUT,_REALSTD) X  (LH, MO)
      _INTENT(IN,   integer)  ipKW (IPKW_FULL_DECL)
      _INTENT(IN,   integer)  iMA  (*)
      integer jErr
      integer NV, jop, KSW
      integer j
      integer kOpTbl(4)
      data    kOpTbl /KWO_HWE,KWO_HEW, KWO_HSN,KWO_HNS/
      save    kOpTbl
CCC_  - Body
      NV  = LH * MO
      KSW = KWM_M
c
      do j = 1, 4
         jop = kOpTbl(j)
         if (ipKW(KWC_IRS,jop,KSW).lt.0) then
            continue
         else
            call DMDmrs
     O          (jErr,   X,
     I           ipKW(KWC_IRD,jop,KSW), ipKW(KWC_IRS,jop,KSW), NV,
     I           ipKW(KWC_TPD,jop,KSW), ipKW(KWC_TPS,jop,KSW), MO, iMA)
         endif
      enddo
c$$$      jop = KWO_HWE
c$$$      call DMDmrs
c$$$     O    (jErr,   X,
c$$$     I     ipKW(KWC_IRD,jop,KSW), ipKW(KWC_IRS,jop,KSW), NV,
c$$$     I     ipKW(KWC_TPD,jop,KSW), ipKW(KWC_TPS,jop,KSW), MO, iMA)
c$$$c$$$      write (*, *) jop,
c$$$c$$$     $     ipKW(KWC_IRD,jop,KSW), ipKW(KWC_IRS,jop,KSW),
c$$$c$$$     $     ipKW(KWC_TPD,jop,KSW), ipKW(KWC_TPS,jop,KSW)
c$$$      jop = KWO_HEW
c$$$      call DMDmrs
c$$$     O    (jErr,   X,
c$$$     I     ipKW(KWC_IRD,jop,KSW), ipKW(KWC_IRS,jop,KSW), NV,
c$$$     I     ipKW(KWC_TPD,jop,KSW), ipKW(KWC_TPS,jop,KSW), MO, iMA)
c$$$c
c$$$      jop = KWO_HSN
c$$$      call DMDmrs
c$$$     O    (jErr,   X,
c$$$     I     ipKW(KWC_IRD,jop,KSW), ipKW(KWC_IRS,jop,KSW), NV,
c$$$     I     ipKW(KWC_TPD,jop,KSW), ipKW(KWC_TPS,jop,KSW), MO, iMA)
c$$$c
c$$$      jop = KWO_HNS
c$$$      call DMDmrs
c$$$     O    (jErr,   X,
c$$$     I     ipKW(KWC_IRD,jop,KSW), ipKW(KWC_IRS,jop,KSW), NV,
c$$$     I     ipKW(KWC_TPD,jop,KSW), ipKW(KWC_TPS,jop,KSW), MO, iMA)
      RETURN
      END
CCC_* [AKX] Kiwi/Operations/X (KDLbi 1)
CCC_ & AKXinx  ## count XL operation (for debug)
      subroutine AKXinx
     M    (XI,
     I     JI0, JI9, JC0, JC9, JCS,
     I     MH,  LH,  MO,  LO,  KL)
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(IN,   integer)  MH, LH, MO, LO, KL
      _INTENT(INOUT,_REALSTD) XI (LH, LO, *)
      _INTENT(IN,   integer)  JI0, JI9
      _INTENT(IN,   integer)  JC0, JC9, JCS
CCC_   = Interior
      integer jo, jh
CCC_  - Body
CCC_   . reset
      do    jo = 1,   MO
         do jh = 1,   MH
            XI (jh, jo, KL) = 0.0d0
         enddo
      enddo
CCC_   . operation interior
      do    jo = 1,   MO
         do jh = 1,   JI0 - 1
            XI (jh, jo, KL) = 1.0d0 + XI (jh, jo, KL)
         enddo
      enddo
      do    jo = 1,   MO
         do jh = JI0, JI9
            XI (jh, jo, KL) = 1.0d0 + XI (jh, jo, KL)
         enddo
      enddo
      do    jo = 1,       MO
         do jh = JI9 + 1, MH
            XI (jh, jo, KL) = 1.0d0 + XI (jh, jo, KL)
         enddo
      enddo
CCC_   . operation with clone
      do    jo = 1,  MO
         do jh = JC0, JC9, JCS
            XI (jh, jo, KL) = 1.0d0 + XI (jh, jo, KL)
         enddo
      enddo
      RETURN
      END
CCC_ & AKXinz  ## count Z  operation (for debug)
      subroutine AKXinz
     O    (Z,
     I     JI0, JI9, JC0, JC9, JCS,
     I     MH,  LH)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)  MH, LH
      _INTENT(OUT,_REALSTD) Z  (LH)
      _INTENT(IN, integer)  JI0, JI9
      _INTENT(IN, integer)  JC0, JC9, JCS
      integer jh
CCC_  - Body
      do jh = 1, MH
         Z (jh) = 0.0d0
      enddo
CCC_   . internal operation
      do jh = 1, JI0 - 1
         Z (jh) = 1.0d0 + Z (jh)
      enddo
      do jh = JI0, JI9
         Z (jh) = 1.0d0 + Z (jh)
      enddo
      do jh = JI9 + 1, MH
         Z (jh) = 1.0d0 + Z (jh)
      enddo
CCC_   . operation with clone
      do jh = JC0, JC9, JCS
         Z (jh) = 1.0d0 + Z (jh)
      enddo
      RETURN
      END
CCC_ & AKXwax  ## XL = Wo XR  (o) + Wa (XR  (a) or C)
      subroutine AKXwax
     M    (XI,  KXL, KXR, JI0, JI9,      JIA,
     I     XC,  KXC,      JC0, JC9, JCS, JCA,
     I     WW,  KWO, KWA,
     I     MH,  LH)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH
      _INTENT(INOUT,_REALSTD) XI (LH, *)
      _INTENT(IN,   _REALSTD) XC (LH, *)
      _INTENT(IN,   _REALSTD) WW (LH, *)
      _INTENT(IN,   integer)  JI0, JI9,      JIA
      _INTENT(IN,   integer)  JC0, JC9, JCS, JCA
      _INTENT(IN,   integer)  KXL, KXR
      _INTENT(IN,   integer)  KXC
      _INTENT(IN,   integer)  KWO, KWA
      integer jh
CCC_  - Body
CCC_   . head
      CLOCK_IK(AKXWAX_0,'AKXWAX_0',AKXWAX)
      do jh = 1,   JI0 - 1
         XI (jh, KXL) = WW (jh, KWO) * XI (jh, KXR)
      enddo
      CLOCK_OK(AKXWAX_0,'AKXWAX_0',AKXWAX)
CCC_   . body
      CLOCK_IK(AKXWAX_1,'AKXWAX_1',AKXWAX)
      do jh = JI0, JI9
         XI (jh, KXL) = WW (jh, KWO) * XI (jh,       KXR)
     $                + WW (jh, KWA) * XI (jh + JIA, KXR)
      enddo
      CLOCK_OK(AKXWAX_1,'AKXWAX_1',AKXWAX)
CCC_   . tail
      CLOCK_IK(AKXWAX_2,'AKXWAX_2',AKXWAX)
      do jh = JI9 + 1, MH
         XI (jh, KXL) = WW (jh, KWO) * XI (jh, KXR)
      enddo
      CLOCK_OK(AKXWAX_2,'AKXWAX_2',AKXWAX)
CCC_   . operation with clone
      CLOCK_IK(AKXWAX_3,'AKXWAX_3',AKXWAX)
      do jh = JC0, JC9, JCS
         XI (jh, KXL) = WW (jh, KWO) * XI (jh,       KXR)
     $                + WW (jh, KWA) * XC (jh + JCA, KXC)
      enddo
      CLOCK_OK(AKXWAX_3,'AKXWAX_3',AKXWAX)
CCC_   . isnan check
c$$$      do    jo = 1,  MO
c$$$         do jh = 1,  MH
c$$$            if (ISNAN (XI (jh, jo, KL))) then
c$$$ 101           format ('ISNAN:WAX:', I5, 5E11.3)
c$$$               write (*, 101) jh,
c$$$     $              WO (jh), WA (jh),
c$$$     $              XI (jh, jo, KR), XI (jh+KI,jo,KR), XC (jh+KC,jo)
c$$$            endif
c$$$         enddo
c$$$      enddo
      RETURN
      END
CCC_ & AKXwaw  ## XL = Wo XR  (o) + Wa (XR  (a) or C)
      subroutine AKXwaw
     M    (XI,  KXL, KXR, JI0, JI9,      JIA,
     I     XC,  KXC,      JC0, JC9, JCS, JCA,
     I     WW,  KWO, KWA,
     I     MH,  LH,  MO,  LO,  KOS)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  MO, LO, KOS
      _INTENT(INOUT,_REALSTD) XI (LH, LO, *)
      _INTENT(IN,   _REALSTD) XC (LH, LO, *)
      _INTENT(IN,   _REALSTD) WW (LH, *)
      _INTENT(IN,   integer)  JI0, JI9,      JIA
      _INTENT(IN,   integer)  JC0, JC9, JCS, JCA
      _INTENT(IN,   integer)  KXL, KXR
      _INTENT(IN,   integer)  KXC
      _INTENT(IN,   integer)  KWO, KWA
      integer jo, jh
CCC_  - Body
CCC_   . head
      CLOCK_IK(AKXWAW_0,'AKXWAW_0',AKXWAW)
      do    jo = KOS, KOS + MO - 1
         do jh = 1,   JI0 - 1
            XI (jh, jo, KXL) = WW (jh, KWO) * XI (jh,      jo, KXR)
         enddo
      enddo
      CLOCK_OK(AKXWAW_0,'AKXWAW_0',AKXWAW)
CCC_   . body
      CLOCK_IK(AKXWAW_1,'AKXWAW_1',AKXWAW)
      do    jo = KOS, KOS + MO - 1
         do jh = JI0, JI9
            XI (jh, jo, KXL) = WW (jh, KWO) * XI (jh,       jo, KXR)
     $                       + WW (jh, KWA) * XI (jh + JIA, jo, KXR)
         enddo
      enddo
      CLOCK_OK(AKXWAW_1,'AKXWAW_1',AKXWAW)
CCC_   . tail
      CLOCK_IK(AKXWAW_2,'AKXWAW_2',AKXWAW)
      do    jo = KOS,     KOS + MO - 1
         do jh = JI9 + 1, MH
            XI (jh, jo, KXL) = WW (jh, KWO) * XI (jh,      jo, KXR)
         enddo
      enddo
      CLOCK_OK(AKXWAW_2,'AKXWAW_2',AKXWAW)
CCC_   . operation with clone
      CLOCK_IK(AKXWAW_3,'AKXWAW_3',AKXWAW)
      do    jo = KOS, KOS + MO - 1
         do jh = JC0, JC9, JCS
            XI (jh, jo, KXL) = WW (jh, KWO) * XI (jh,       jo, KXR)
     $                       + WW (jh, KWA) * XC (jh + JCA, jo, KXC)
         enddo
      enddo
      CLOCK_OK(AKXWAW_3,'AKXWAW_3',AKXWAW)
      RETURN
      END
CCC_ & AKXwaz  ## Z  = Wo X   (o) + Wa (X   (a) or C)
      subroutine AKXwaz
     O    (Z,
     M     XI,            JI0, JI9,      JIA,
     I     XC,  KXC,      JC0, JC9, JCS, JCA,
     I     WW,  KWO, KWA,
     I     MH,  LH)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)  MH, LH
      _INTENT(OUT,_REALSTD) Z  (LH)
      _INTENT(IN, _REALSTD) XI (LH)
      _INTENT(IN, _REALSTD) XC (LH, *)
      _INTENT(IN, _REALSTD) WW (LH, *)
      _INTENT(IN, integer)  JI0, JI9,      JIA
      _INTENT(IN, integer)  JC0, JC9, JCS, JCA
      _INTENT(IN, integer)  KXC
      _INTENT(IN, integer)  KWO, KWA
      integer jh
CCC_  - Body
CCC_   . head
      CLOCK_IK(AKXWAZ_0,'AKXWAZ_0',AKXWAZ)
      do jh = 1, JI0 - 1
         Z (jh) = WW (jh, KWO) * XI (jh)
      enddo
      CLOCK_OK(AKXWAZ_0,'AKXWAZ_0',AKXWAZ)
CCC_   . body
      CLOCK_IK(AKXWAZ_1,'AKXWAZ_1',AKXWAZ)
      do jh = JI0, JI9
         Z (jh) = WW (jh, KWO) * XI (jh)
     $          + WW (jh, KWA) * XI (jh + JIA)
      enddo
      CLOCK_OK(AKXWAZ_1,'AKXWAZ_1',AKXWAZ)
CCC_   . tail
      CLOCK_IK(AKXWAZ_2,'AKXWAZ_2',AKXWAZ)
      do jh = JI9 + 1, MH
         Z (jh) = WW (jh, KWO) * XI (jh)
      enddo
      CLOCK_OK(AKXWAZ_2,'AKXWAZ_2',AKXWAZ)
CCC_   . operation with clone
      CLOCK_IK(AKXWAZ_3,'AKXWAZ_3',AKXWAZ)
      do jh = JC0, JC9, JCS
         Z (jh) = WW (jh, KWO) * XI (jh)
     $          + WW (jh, KWA) * XC (jh + JCA, KXC)
      enddo
      CLOCK_OK(AKXWAZ_3,'AKXWAZ_3',AKXWAZ)
      RETURN
      END
CCC_ & AKXway  ## Z  = Wo X   (o) + Wa (X   (a) or C)
      subroutine AKXway
     O    (Z,
     I     XI,            JI0, JI9,      JIA,
     I     XC,  KXC,      JC0, JC9, JCS, JCA,
     I     WW,  KWO, KWA,
     I     MH,  LH,  MO,  LO,  KOS)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)  MH, LH
      _INTENT(IN, integer)  MO, LO, KOS
      _INTENT(OUT,_REALSTD) Z  (LH, LO)
      _INTENT(IN, _REALSTD) XI (LH, LO)
      _INTENT(IN, _REALSTD) XC (LH, LO, *)
      _INTENT(IN, _REALSTD) WW (LH, *)
      _INTENT(IN, integer)  JI0, JI9,      JIA
      _INTENT(IN, integer)  JC0, JC9, JCS, JCA
      _INTENT(IN, integer)  KXC
      _INTENT(IN, integer)  KWO, KWA
      integer jo, jh
CCC_  - Body
CCC_   . head
c$$$      write (*,*) 'WAY',MH,LH,MO,LO,KOS,KXC
      CLOCK_IK(AKXWAY_0,'AKXWAY_0',AKXWAY)
      do    jo = KOS, KOS+MO-1
         do jh = 1, JI0 - 1
            Z (jh, jo) = WW (jh, KWO) * XI (jh,      jo)
         enddo
      enddo
      CLOCK_OK(AKXWAY_0,'AKXWAY_0',AKXWAY)
CCC_   . body
      CLOCK_IK(AKXWAY_1,'AKXWAY_1',AKXWAY)
      do    jo = KOS, KOS+MO-1
         do jh = JI0, JI9
            Z (jh, jo) = WW (jh, KWO) * XI (jh,       jo)
     $                 + WW (jh, KWA) * XI (jh + JIA, jo)
c$$$            write (*, *) 'AY', jh, jo,
c$$$     $           WW (jh, KWO), XI (jh,       jo),
c$$$     $           WW (jh, KWA), XI (jh + JIA, jo)
         enddo
      enddo
      CLOCK_OK(AKXWAY_1,'AKXWAY_1',AKXWAY)
CCC_   . tail
      CLOCK_IK(AKXWAY_2,'AKXWAY_2',AKXWAY)
      do    jo = KOS, KOS+MO-1
         do jh = JI9 + 1, MH
            Z (jh, jo) = WW (jh, KWO) * XI (jh,      jo)
         enddo
      enddo
      CLOCK_OK(AKXWAY_2,'AKXWAY_2',AKXWAY)
CCC_   . operation with clone
      CLOCK_IK(AKXWAY_3,'AKXWAY_3',AKXWAY)
      do    jo = KOS, KOS+MO-1
         do jh = JC0, JC9, JCS
            Z (jh, jo) = WW (jh, KWO) * XI (jh,       jo)
     $                 + WW (jh, KWA) * XC (jh + JCA, jo, KXC)
c$$$            write (*, *) 'AC', jh, jo,jh+JCA,
c$$$     $           WW (jh, KWO), XI (jh,       jo),
c$$$     $           WW (jh, KWA), XC (jh + JCA, jo, KXC)
         enddo
      enddo
      CLOCK_OK(AKXWAY_3,'AKXWAY_3',AKXWAY)
      RETURN
      END
CCC_ & AKXwbx  ## XL = Wo XRo (o) + Wa (XRa (a) or C)
      subroutine AKXwbx
     M    (XI,  KXL, KXRO, KXRA, JI0, JI9,      JIA,
     I     XC,  KXC,             JC0, JC9, JCS, JCA,
     I     WW,  KWO, KWA,
     I     MH,  LH)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH
      _INTENT(INOUT,_REALSTD) XI (LH, *)
      _INTENT(IN,   _REALSTD) XC (LH, *)
      _INTENT(IN,   _REALSTD) WW (LH, *)
      _INTENT(IN,   integer)  JI0, JI9,       JIA
      _INTENT(IN,   integer)  JC0, JC9,  JCS, JCA
      _INTENT(IN,   integer)  KXL, KXRO, KXRA
      _INTENT(IN,   integer)  KXC
      _INTENT(IN,   integer)  KWO, KWA
      integer jh
CCC_  - Body
CCC_   . internal operation
      do jh = 1, JI0 - 1
         XI (jh, KXL) = WW (jh, KWO) * XI (jh, KXRO)
      enddo
      do jh = JI0, JI9
         XI (jh, KXL) = WW (jh, KWO) * XI (jh, KXRO)
     $                + WW (jh, KWA) * XI (jh + JIA, KXRA)
      enddo
      do jh = JI9 + 1, MH
         XI (jh, KXL) = WW (jh, KWO) * XI (jh, KXRO)
      enddo
CCC_   . operation with clone
      do jh = JC0, JC9, JCS
         XI (jh, KXL) = WW (jh, KWO) * XI (jh, KXRO)
     $                + WW (jh, KWA) * XC (jh + JCA, KXC)
      enddo
      RETURN
      END
CCC_ & AKXwbz  ## Z  = Wo Xo  (o) + Wa (Xa  (a) or C)
      subroutine AKXwbz
     O    (Z,
     I     XI,  KXO, KXA, JI0, JI9,      JIA,
     I     XC,  KXC,      JC0, JC9, JCS, JCA,
     I     WW,  KWO, KWA,
     I     MH,  LH)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)  MH, LH
      _INTENT(OUT,_REALSTD) Z  (LH)
      _INTENT(IN, _REALSTD) XI (LH, *)
      _INTENT(IN, _REALSTD) XC (LH, *)
      _INTENT(IN, _REALSTD) WW (LH, *)
      _INTENT(IN, integer)  JI0, JI9,       JIA
      _INTENT(IN, integer)  JC0, JC9,  JCS, JCA
      _INTENT(IN, integer)  KXO, KXA
      _INTENT(IN, integer)  KXC
      _INTENT(IN, integer)  KWO, KWA
      integer jh
CCC_  - Body
CCC_   . internal operation
      do jh = 1, JI0 - 1
         Z (jh) = WW (jh, KWO) * XI (jh, KXO)
      enddo
      do jh = JI0, JI9
         Z (jh) = WW (jh, KWO) * XI (jh,       KXO)
     $          + WW (jh, KWA) * XI (jh + JIA, KXA)
      enddo
      do jh = JI9 + 1, MH
         Z (jh) = WW (jh, KWO) * XI (jh, KXO)
      enddo
CCC_   . operation with clone
      do jh = JC0, JC9, JCS
         Z (jh) = WW (jh, KWO) * XI (jh,       KXO)
     $          + WW (jh, KWA) * XC (jh + JCA, KXC)
      enddo
      RETURN
      END
CCC_ & AKXfax  ## XL = 1  XR  (o) + f  (XR  (a) or C)
      subroutine AKXfax
     M    (XI,  KXL, KXR, JI0, JI9,      JIA,
     I     XC,  KXC,      JC0, JC9, JCS, JCA,
     I     F,
     I     MH,  LH)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH
      _INTENT(INOUT,_REALSTD) XI (LH, *)
      _INTENT(IN,   _REALSTD) XC (LH, *)
      _INTENT(IN,   _REALSTD) F
      _INTENT(IN,   integer)  JI0, JI9,      JIA
      _INTENT(IN,   integer)  JC0, JC9, JCS, JCA
      _INTENT(IN,   integer)  KXL, KXR
      _INTENT(IN,   integer)  KXC
      integer jh
CCC_  - Body
      do jh = 1,   JI0 - 1
         XI (jh, KXL) = XI (jh, KXR)
      enddo
      do jh = JI0, JI9
         XI (jh, KXL) = XI (jh, KXR)
     $                + XI (jh + JIA, KXR) * F
      enddo
      do jh = JI9 + 1, MH
         XI (jh, KXL) = XI (jh, KXR)
      enddo
CCC_   . operation with clone
      do jh = JC0, JC9, JCS
         XI (jh, KXL) = XI (jh, KXR)
     $                + XC (jh + JCA, KXC) * F
      enddo
      RETURN
      END
CCC_ & AKXsax  ## XL = 1  XR  (o) + 1  (XR  (a) or C)
      subroutine AKXsax
     M    (XI,  KXL, KXR, JI0, JI9,      JIA,
     I     XC,  KXC,      JC0, JC9, JCS, JCA,
     I     MH,  LH)
CCC_  - Declaration
      _INTENT(IN,   integer)  MH, LH
      _INTENT(INOUT,_REALSTD) XI (LH, *)
      _INTENT(IN,   _REALSTD) XC (LH, *)
      _INTENT(IN,   integer)  JI0, JI9,      JIA
      _INTENT(IN,   integer)  JC0, JC9, JCS, JCA
      _INTENT(IN,   integer)  KXL, KXR
      _INTENT(IN,   integer)  KXC
      integer jh
CCC_  - Body
      do jh = 1,   JI0 - 1
         XI (jh, KXL) = XI (jh, KXR)
      enddo
      do jh = JI0, JI9
         XI (jh, KXL) = XI (jh, KXR)
     $                + XI (jh + JIA, KXR)
      enddo
      do jh = JI9 + 1, MH
         XI (jh, KXL) = XI (jh, KXR)
      enddo
CCC_   . operation with clone
      do jh = JC0, JC9, JCS
         XI (jh, KXL) = XI (jh, KXR)
     $                + XC (jh + JCA, KXC)
      enddo
      RETURN
      END
CCC_ & AKXsaz  ## Z  = 1  X   (o) + 1  (X   (a) or C)
      subroutine AKXsaz
     O    (Z,
     I     XI,       JI0, JI9,      JIA,
     I     XC,  KXC, JC0, JC9, JCS, JCA,
     I     MH,  LH)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)  MH, LH
      _INTENT(OUT,_REALSTD) Z  (LH)
      _INTENT(IN, _REALSTD) XI (LH)
      _INTENT(IN, _REALSTD) XC (LH, *)
      _INTENT(IN, integer)  JI0, JI9,      JIA
      _INTENT(IN, integer)  JC0, JC9, JCS, JCA
      _INTENT(IN, integer)  KXC
      integer jh
CCC_  - Body
CCC_   . internal operation
      do jh = 1, JI0 - 1
         Z (jh) = XI (jh)
      enddo
      do jh = JI0, JI9
         Z (jh) = XI (jh) + XI (jh + JIA)
      enddo
      do jh = JI9 + 1, MH
         Z (jh) = XI (jh)
      enddo
CCC_   . operation with clone
      do jh = JC0, JC9, JCS
         Z (jh) = XI (jh) + XC (jh + JCA, KXC)
      enddo
      RETURN
      END
CCC_ & AKXsbx  ## XL = XRo (o) + (XRa (a) or C)
      subroutine AKXsbx
     M    (XI, KXL, KXRO, KXRA, JI0, JI9,      JIA,
     I     XC, KXC,             JC0, JC9, JCS, JCA,
     I     MH, LH)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH
      _INTENT(INOUT,_REALSTD) XI (LH, *)
      _INTENT(IN,   _REALSTD) XC (LH, *)
      _INTENT(IN,   integer)  JI0, JI9,       JIA
      _INTENT(IN,   integer)  JC0, JC9,  JCS, JCA
      _INTENT(IN,   integer)  KXL, KXRO, KXRA
      _INTENT(IN,   integer)  KXC
      integer jh
CCC_   . internal operation
      do jh = 1, JI0 - 1
         XI (jh, KXL) = XI (jh, KXRO)
      enddo
      do jh = JI0, JI9
         XI (jh, KXL) = XI (jh,       KXRO)
     $                + XI (jh + JIA, KXRA)
      enddo
      do jh = JI9 + 1, MH
         XI (jh, KXL) = XI (jh, KXRO)
      enddo
CCC_   . operation with clone
      do jh = JC0, JC9, JCS
         XI (jh, KXL) = XI (jh,       KXRO)
     $                + XC (jh + JCA, KXC)
      enddo
      RETURN
      END
CCC_ & AKXsdx  ## XL = 1  XR  (o) - 1  (XR  (a) or C)
      subroutine AKXsdx
     M    (XI,  KXL, KXR, JI0, JI9,      JIA,
     I     XC,  KXC,      JC0, JC9, JCS, JCA,
     I     MH,  LH)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH
      _INTENT(INOUT,_REALSTD) XI (LH, *)
      _INTENT(IN,   _REALSTD) XC (LH, *)
      _INTENT(IN,   integer)  JI0, JI9,      JIA
      _INTENT(IN,   integer)  JC0, JC9, JCS, JCA
      _INTENT(IN,   integer)  KXL, KXR
      _INTENT(IN,   integer)  KXC
      integer jh
CCC_  - Body
      do jh = 1,   JI0 - 1
         XI (jh, KXL) = XI (jh, KXR)
      enddo
      do jh = JI0, JI9
         XI (jh, KXL) = XI (jh, KXR)
     $                - XI (jh + JIA, KXR)
      enddo
      do jh = JI9 + 1, MH
         XI (jh, KXL) = XI (jh, KXR)
      enddo
CCC_   . operation with clone
      do jh = JC0, JC9, JCS
         XI (jh, KXL) = XI (jh, KXR)
     $                - XC (jh + JCA, KXC)
      enddo
      RETURN
      END
CCC_ & AKXsdz  ## Z  = 1  X   (o) - 1  (X   (a) or C)
      subroutine AKXsdz
     O    (Z,
     I     XI,       JI0, JI9,      JIA,
     I     XC,  KXC, JC0, JC9, JCS, JCA,
     I     MH,  LH)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)  MH, LH
      _INTENT(OUT,_REALSTD) Z  (LH)
      _INTENT(IN, _REALSTD) XI (LH)
      _INTENT(IN, _REALSTD) XC (LH, *)
      _INTENT(IN,   integer)  JI0, JI9,      JIA
      _INTENT(IN,   integer)  JC0, JC9, JCS, JCA
      _INTENT(IN,   integer)  KXC
      integer jh
CCC_  - Body
CCC_   . internal operation
      do jh = 1, JI0 - 1
         Z (jh) = XI (jh)
      enddo
      do jh = JI0, JI9
         Z (jh) = XI (jh) - XI (jh + JIA)
      enddo
      do jh = JI9 + 1, MH
         Z (jh) = XI (jh)
      enddo
CCC_   . operation with clone
      do jh = JC0, JC9, JCS
         Z (jh) = XI (jh) - XC (jh + JCA, KXC)
      enddo
      RETURN
      END
CCC_ & AKXwdx  ## XL = Wo XR  (o) + 0
      subroutine AKXwdx
     M    (XI,  KXL, KXR,
     I     WW,  KWO,
     I     MH,  LH)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH
      _INTENT(INOUT,_REALSTD) XI (LH, *)
      _INTENT(IN,   _REALSTD) WW (LH, *)
      _INTENT(IN,   integer)  KXL, KXR
      _INTENT(IN,   integer)  KWO
      integer jh
CCC_  - Body
      do jh = 1, MH
         XI (jh, KXL) = WW (jh, KWO) * XI (jh, KXR)
      enddo
      RETURN
      END
CCC_ & AKXwdz  ## Z  = Wo X   (o) + 0
      subroutine AKXwdz
     O    (Z,
     I     XI,  KXO,
     I     WW,
     I     MH,  LH)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)  MH, LH
      _INTENT(OUT,_REALSTD) Z  (LH)
      _INTENT(IN, _REALSTD) XI (LH, *)
      _INTENT(IN, _REALSTD) WW (LH)
      _INTENT(IN, integer)  KXO
      integer jh
CCC_  - Body
      do jh = 1, MH
         Z (jh) = WW (jh) * XI (jh, KXO)
      enddo
      RETURN
      END
CCC_ & AKXwex  ## XL = 0          + Wa     (XR (a) or C)
      subroutine AKXwex
     M    (XI,  KXL, KXR, JI0, JI9,      JIA,
     I     XC,  KXC,      JC0, JC9, JCS, JCA,
     I     WW,  KWA,
     I     MH,  LH)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH
      _INTENT(INOUT,_REALSTD) XI (LH, *)
      _INTENT(IN,   _REALSTD) XC (LH, *)
      _INTENT(IN,   _REALSTD) WW (LH, *)
      _INTENT(IN,   integer)  JI0, JI9,      JIA
      _INTENT(IN,   integer)  JC0, JC9, JCS, JCA
      _INTENT(IN,   integer)  KXL, KXR
      _INTENT(IN,   integer)  KXC
      _INTENT(IN,   integer)  KWA
      integer jh
CCC_  - Body
CCC_   . internal operation
      do jh = 1, JI0 - 1
         XI (jh, KXL) = 0.0d0
      enddo
      do jh = JI0, JI9
         XI (jh, KXL) = 0.0d0
     $                + WW (jh, KWA) * XI (jh + JIA, KXR)
      enddo
      do jh = JI9 + 1, MH
         XI (jh, KXL) = 0.0d0
      enddo
CCC_   . operation with clone
      do jh = JC0, JC9, JCS
         XI (jh, KXL) = 0.0d0
     $                + WW (jh, KWA) * XC (jh + JCA, KXC)
      enddo
      RETURN
      END
CCC_ & AKXwez  ## Z  = 0          + Wa     (X  (a) or C)
      subroutine AKXwez
     O    (Z,
     I     XI,       JI0, JI9,      JIA,
     I     XC,  KXC, JC0, JC9, JCS, JCA,
     I     WW,  KWA,
     I     MH,  LH)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)  MH, LH
      _INTENT(OUT,_REALSTD) Z  (LH)
      _INTENT(IN, _REALSTD) XI (LH)
      _INTENT(IN, _REALSTD) XC (LH, *)
      _INTENT(IN, _REALSTD) WW (LH, *)
      _INTENT(IN,   integer)  JI0, JI9,      JIA
      _INTENT(IN,   integer)  JC0, JC9, JCS, JCA
      _INTENT(IN,   integer)  KXC
      _INTENT(IN,   integer)  KWA
      integer jh
CCC_  - Body
CCC_   . internal operation
      do jh = 1, JI0 - 1
         Z (jh) = 0.0d0
      enddo
      do jh = JI0, JI9
         Z (jh) = 0.0d0
     $          + WW (jh, KWA) * XI (jh + JIA)
      enddo
      do jh = JI9 + 1, MH
         Z (jh) = 0.0d0
      enddo
CCC_   . operation with clone
      do jh = JC0, JC9, JCS
         Z (jh) = 0.0d0
     $            + WW (jh, KWA) * XC (jh + JCA, KXC)
      enddo
      RETURN
      END
CCC_ & AKXcex  ## XL = 0          + (f-Wa) (XR (a) or C)
      subroutine AKXcex
     M    (XI,  KXL, KXR, JI0, JI9,      JIA,
     I     XC,  KXC,      JC0, JC9, JCS, JCA,
     I     WI,  F,
     I     MH,  LH)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH
      _INTENT(INOUT,_REALSTD) XI (LH, *)
      _INTENT(IN,   _REALSTD) XC (LH, *)
      _INTENT(IN,   _REALSTD) WI (LH)
      _INTENT(IN,   _REALSTD) F
      _INTENT(IN,   integer)  JI0, JI9,      JIA
      _INTENT(IN,   integer)  JC0, JC9, JCS, JCA
      _INTENT(IN,   integer)  KXL, KXR
      _INTENT(IN,   integer)  KXC
      integer jh
CCC_  - Body
      do jh = 1,   JI0 - 1
         XI (jh, KXL) = 0.0d0
      enddo
      do jh = JI0, JI9
         XI (jh, KXL) = 0.0d0
     $                + (F - WI (jh)) * XI (jh + JIA, KXR)
      enddo
      do jh = JI9 + 1, MH
         XI (jh, KXL) = 0.0d0
      enddo
CCC_   . operation with clone
      do jh = JC0, JC9, JCS
         XI (jh, KXL) = 0.0d0
     $                + (F - WI (jh)) * XC (jh + JCA, KXC)
      enddo
      RETURN
      END
CCC_ & AKXcez  ## Z  = 0          + (f-Wa) (X  (a) or C)
      subroutine AKXcez
     O    (Z,
     I     XI,       JI0, JI9,      JIA,
     I     XC,  KXC, JC0, JC9, JCS, JCA,
     I     WI,  F,
     I     MH,  LH)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)  MH, LH
      _INTENT(OUT,_REALSTD) Z  (LH)
      _INTENT(IN, _REALSTD) XI (LH)
      _INTENT(IN, _REALSTD) XC (LH, *)
      _INTENT(IN, _REALSTD) WI (LH)
      _INTENT(IN, _REALSTD) F
      _INTENT(IN, integer)  JI0, JI9,      JIA
      _INTENT(IN, integer)  JC0, JC9, JCS, JCA
      _INTENT(IN, integer)  KXC
      integer jh
CCC_  - Body
CCC_   . internal operation
      do jh = 1, JI0 - 1
         Z (jh) = 0.0d0
      enddo
      do jh = JI0, JI9
         Z (jh) = 0.0d0
     $            + (F - WI (jh)) * XI (jh + JIA)
      enddo
      do jh = JI9 + 1, MH
         Z (jh) = 0.0d0
      enddo
CCC_   . operation with clone
      do jh = JC0, JC9, JCS
         Z (jh) = 0.0d0
     $            + (F - WI (jh)) * XC (jh + JCA, KXC)
      enddo
      RETURN
      END
CCC_ & AKXmex  ## XL = 0          + 1      (XR (a) or C)
      subroutine AKXmex
     M    (XI,  KXL, KXR, JI0, JI9,      JIA,
     I     XC,  KXC,      JC0, JC9, JCS, JCA,
     I     MH,  LH)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  MH, LH
      _INTENT(INOUT,_REALSTD) XI (LH, *)
      _INTENT(IN,   _REALSTD) XC (LH, *)
      _INTENT(IN,   integer)  JI0, JI9,      JIA
      _INTENT(IN,   integer)  JC0, JC9, JCS, JCA
      _INTENT(IN,   integer)  KXL, KXR
      _INTENT(IN,   integer)  KXC
      integer jh
CCC_  - Body
      do jh = 1,   JI0 - 1
         XI (jh, KXL) = 0.0d0
      enddo
      do jh = JI0, JI9
         XI (jh, KXL) = XI (jh + JIA, KXR)
      enddo
      do jh = JI9 + 1, MH
         XI (jh, KXL) = 0.0d0
      enddo
CCC_   . operation with clone
      do jh = JC0, JC9, JCS
         XI (jh, KXL) = XC (jh + JCA, KXC)
      enddo
      RETURN
      END
CCC_ & AKXmez  ## Z  = 0          + 1      (X  (a) or C)
      subroutine AKXmez
     O    (Z,
     I     XI,       JI0, JI9,      JIA,
     I     XC,  KXC, JC0, JC9, JCS, JCA,
     I     MH,  LH)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)  MH, LH
      _INTENT(OUT,_REALSTD) Z  (LH)
      _INTENT(IN, _REALSTD) XI (LH)
      _INTENT(IN, _REALSTD) XC (LH, *)
      _INTENT(IN, integer)  JI0, JI9,      JIA
      _INTENT(IN, integer)  JC0, JC9, JCS, JCA
      _INTENT(IN, integer)  KXC
      integer jh
CCC_  - Body
CCC_   . internal operation
      do jh = 1, JI0 - 1
         Z (jh) = 0.0d0
      enddo
      do jh = JI0, JI9
         Z (jh) = XI (jh + JIA)
      enddo
      do jh = JI9 + 1, MH
         Z (jh) = 0.0d0
      enddo
CCC_   . operation with clone
      do jh = JC0, JC9, JCS
         Z (jh) = XC (jh + JCA, KXC)
      enddo
      RETURN
      END
CCC_ & AKXmey  ## Z  = 0          + 1      (X  (a) or C)
      subroutine AKXmey
     O    (Z,
     I     XI,       JI0, JI9,      JIA,
     I     XC,  KXC, JC0, JC9, JCS, JCA,
     I     MH,  LH,  MO,  LO,  KOS)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)  MH, LH
      _INTENT(IN, integer)  MO, LO, KOS
      _INTENT(OUT,_REALSTD) Z  (LH, LO)
      _INTENT(IN, _REALSTD) XI (LH, LO)
      _INTENT(IN, _REALSTD) XC (LH, LO, *)
      _INTENT(IN, integer)  JI0, JI9,      JIA
      _INTENT(IN, integer)  JC0, JC9, JCS, JCA
      _INTENT(IN, integer)  KXC
      integer jo, jh
CCC_  - Body
CCC_   . internal operation
      do    jo = KOS, KOS+MO-1
         do jh = 1, JI0 - 1
            Z (jh, jo) = 0.0d0
         enddo
      enddo
      do    jo = KOS, KOS+MO-1
         do jh = JI0, JI9
            Z (jh, jo) = XI (jh + JIA, jo)
         enddo
      enddo
      do    jo = KOS,     KOS+MO-1
         do jh = JI9 + 1, MH
            Z (jh, jo) = 0.0d0
         enddo
      enddo
CCC_   . operation with clone
      do    jo = KOS, KOS+MO-1
         do jh = JC0, JC9, JCS
            Z (jh, jo) = XC (jh + JCA, jo, KXC)
         enddo
      enddo
      RETURN
      END
CCC_ & AKXmew  ## XL = 0          + 1      (XR (a) or C)
      subroutine AKXmew
     O    (XI,  KXL, KXR, JI0, JI9,      JIA,
     I     XC,  KXC,      JC0, JC9, JCS, JCA,
     I     MH,  LH,  MO,  LO,  KOS)
CCC_  - Declaration
      implicit none
      _INTENT(IN, integer)  MH, LH
      _INTENT(IN, integer)  MO, LO, KOS
      _INTENT(INOUT,_REALSTD) XI (LH, LO, *)
      _INTENT(IN,   _REALSTD) XC (LH, LO, *)
      _INTENT(IN, integer)  KXL, KXR
      _INTENT(IN, integer)  JI0, JI9,      JIA
      _INTENT(IN, integer)  JC0, JC9, JCS, JCA
      _INTENT(IN, integer)  KXC
      integer jo, jh
CCC_  - Body
CCC_   . internal operation
      do    jo = KOS, KOS+MO-1
         do jh = 1, JI0 - 1
            XI (jh, jo, KXL) = 0.0d0
         enddo
      enddo
      do    jo = KOS, KOS+MO-1
         do jh = JI0, JI9
            XI (jh, jo, KXL) = XI (jh + JIA, jo, KXR)
         enddo
      enddo
      do    jo = KOS,     KOS+MO-1
         do jh = JI9 + 1, MH
            XI (jh, jo, KXL) = 0.0d0
         enddo
      enddo
CCC_   . operation with clone
      do    jo = KOS, KOS+MO-1
         do jh = JC0, JC9, JCS
            XI (jh, jo, KXL) = XC (jh + JCA, jo, KXC)
         enddo
      enddo
      RETURN
      END
CCC_* [AKV] Kiwi/Operations/V (KDLbi 1)
CCC_ & AKVwax  ## X(l) = Wo X(r) + Wa (X(r) or C)
      subroutine AKVwax
     M    (XI,
     I     XC,  WO,  WA,
     I     JI0, JI9, KI,  JC0, JC9, JCS, KC,
     I     MH,  MO,  LV,  KL,  KR)
CCC_  - Declaration
      implicit none
CCC_   = Arguments
      _INTENT(IN,   integer)  MH, MO, LV
      _INTENT(INOUT,_REALSTD) XI (LV, *)
      _INTENT(IN,   _REALSTD) XC (LV)
      _INTENT(IN,   _REALSTD) WO (*),  WA (*)
      _INTENT(IN,   integer)  JI0, JI9, KI
      _INTENT(IN,   integer)  JC0, JC9, JCS, KC
      _INTENT(IN,   integer)  KL,  KR
CCC_   = Interior
      integer jo, jh, joh, joi
CCC_  - Body
      do    jo = 1,   MO
         do jh = 1,   JI0 - 1
            joh = (jo - 1) * MH + jh
            XI (joh, KL) = WO (jh) * XI (joh, KR)
         enddo
      enddo
      do    jo = 1,   MO
         do jh = JI0, JI9
            joh = (jo - 1) * MH + jh
            joi = (jo - 1) * MH + jh + KI
            XI (joh, KL) = WO (jh) * XI (joh, KR)
     $                   + WA (jh) * XI (joi, KR)
         enddo
      enddo
      do    jo = 1,       MO
         do jh = JI9 + 1, MH
            joh = (jo - 1) * MH + jh
            XI (joh, KL) = WO (jh) * XI (joh, KR)
         enddo
      enddo
CCC_   . operation with clone
      do    jo = 1,  MO
         do jh = JC0, JC9, JCS
            joh = (jo - 1) * MH + jh
            joi = (jo - 1) * MH + jh + KC
            XI (joh, KL) = WO (jh) * XI (joh, KR)
     $                   + WA (jh) * XC (joi)
         enddo
      enddo
      RETURN
      END
CCC_* [AKY] Kiwi/Operations/Y (KDLbi 0)
CCC_* [AKO] Kiwi/Operations/single-grid block
CCC_* [AKP] Operation property
#define KWF_DECLARED -1
#define KWF_NOTSET   0
CCC_ & AKPini  ## Property/initialization (with elements table)
      subroutine AKPini (ipKW)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,integer) ipKW (IPKW_FULL_DECL)
      integer ji, jo, jm
CCC_  * Body
      do       jm = KWM_M, KWM_T
         do    jo = 1,     KWO_MAX
            do ji = 1,     KWI_MAX
               ipKW (ji, jo, jm) = 0
            enddo
         enddo
      enddo
      do       jm = KWM_M, KWM_T
         do    jo = 1,     KWO_MAX
            ipKW (KWI_FLG, jo, jm) = KWF_NOTSET
         enddo
      enddo
      RETURN
      END
CCC_ & AKPdca  ## Property/declearation all operators
      subroutine AKPdca
     O    (iErr,
     O     ipKW,
     I     IFPl)
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(OUT,integer) ipKW (IPKW_FULL_DECL)
      _INTENT(IN, integer) IFPl
      integer j, jo
      iErr = 0
      do j = 1, KWO1_MAX
         jo = j
         if (iErr.eq.0) then
            call AKPdec (iErr, ipKW, jo, KWM_BOTH, IFPl)
         endif
      enddo
      RETURN
      END
CCC_ & AKPdec  ## Property/declearation operator to use
      subroutine AKPdec
     O    (iErr,
     O     ipKW,
     I     KOP,  KSW, IFPl)
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(OUT,integer) ipKW (IPKW_FULL_DECL)
      _INTENT(IN, integer) KOP, KSW
      _INTENT(IN, integer) IFPl
      iErr = 0
      if (KSW .eq. KWM_BOTH) then
         call AKPdcc (iErr, ipKW, KOP, KWM_M, IFPl)
         if (iErr.eq.0) call AKPdcc (iErr, ipKW, KOP, KWM_T, IFPl)
      else
         call AKPdcc (iErr, ipKW, KOP, KSW, IFPl)
      endif
      RETURN
      END
CCC_ & AKPdcc  ## Property/declearation operator to use (core)
      subroutine AKPdcc
     O    (iErr,
     O     ipKW,
     I     KOP,  KSW, IFPl)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(OUT,integer) ipKW (IPKW_FULL_DECL)
      _INTENT(IN, integer) KOP, KSW
      _INTENT(IN, integer) IFPl
      character TSO*(8)
CCC_  * Body
      call AKPo2s (TSO, KOP, KSW, '/')
      iErr = 0
 101  format ('AKPDCC[', A, '] NEW DECL')
 102  format ('AKPDCC[', A, '] ALREADY DECLARED')
 103  format ('AKPDCC[', A, '] ALREADY DUP ', I3.3)
 109  format ('AKPDCC[', A, '] UNKNOWN ', I3)
CCC_   + new declaration
      if      (ipKW (KWI_FLG, KOP, KSW) .eq. KWF_NOTSET) then
         if      (COND_N(IFPl)) then
            write (IFPl, 101) _TRIM(TSO)
         else if (COND_S(IFPl)) then
            write (*,    101) _TRIM(TSO)
         endif
         ipKW (KWI_FLG, KOP, KSW) = KWF_DECLARED
CCC_   + already declared
      else if (ipKW (KWI_FLG, KOP, KSW) .eq. KWF_DECLARED) then
         if       (COND_N(IFPl)) then
            write (IFPl, 102) _TRIM(TSO)
         else if (COND_S(IFPl)) then
            write (*,    102) _TRIM(TSO)
         endif
CCC_   + already duplicated
      else if (ipKW (KWI_FLG, KOP, KSW) .gt. 0) then
         if      (COND_N(IFPl)) then
            write (IFPl, 103) _TRIM(TSO), ipKW (KWI_FLG, KOP, KSW)
         else if (COND_S(IFPl)) then
            write (*,    103) _TRIM(TSO), ipKW (KWI_FLG, KOP, KSW)
         endif
CCC_   + unknown
      else
         if      (COND_N(IFPl)) then
            write (IFPl, 109) _TRIM(TSO), ipKW (KWI_FLG, KOP, KSW)
         else if (COND_S(IFPl)) then
            write (*,    109) _TRIM(TSO), ipKW (KWI_FLG, KOP, KSW)
         endif
         iErr = -1
      endif
      RETURN
      END
CCC_ & AKPdup  ## Property/declearation to duplicate
      subroutine AKPdup
     O    (iErr,
     O     ipKW,
     I     KOPtgt, KOPref, KSW, IFPl)
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(OUT,integer) ipKW (IPKW_FULL_DECL)
      _INTENT(IN, integer) KOPtgt, KOPref, KSW
      _INTENT(IN, integer) IFPl
      iErr = 0
      if (KSW .eq. KWM_BOTH) then
         call AKPdpc (iErr, ipKW, KOPtgt, KOPref, KWM_M, IFPl)
         if (iErr.eq.0)
     $        call AKPdpc (iErr, ipKW, KOPtgt, KOPref, KWM_T, IFPl)
      else
         call AKPdpc (iErr, ipKW, KOPtgt, KOPref, KSW, IFPl)
      endif
      RETURN
      END
CCC_ & AKPdpc  ## Property/declearation to duplicate (core)
      subroutine AKPdpc
     O    (iErr,
     O     ipKW,
     I     KOPtgt, KOPref, KSW, IFPl)
CC      KOPtgt: target operation to duplicate
CC      KOPref: reference operation to duplicate from
CCC_  * Declaration
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(OUT,integer) ipKW (IPKW_FULL_DECL)
      _INTENT(IN, integer) KOPtgt, KOPref, KSW
      _INTENT(IN, integer) IFPl
      integer jRefO, jTgtO
      integer jOprR
      integer jo
      character TSOt*(8), TSOr*(8)
CCC_  * Body
      call AKPo2s (TSOt, KOPtgt, KSW, '/')
      call AKPo2s (TSOr, KOPref, KSW, '/')
      iErr = 0
      jTgtO = ipKW (KWI_FLG, KOPtgt, KSW)
 109  format ('AKPDPC[', A, '] DUP ',A, ' ERROR ', I4)
 101  format ('AKPDPC[', A, '] DUP ',A, ':', I3.3)
 102  format ('AKPDPC[', A, '] ADJUST DUP ',A, ':', I3.3)
CCC_   + error if already duplicated or unknown
      if ((jTgtO.ne.KWF_DECLARED) .and. (jTgtO.ne.KWF_NOTSET)) then
         iErr = -1
         if      (COND_N(IFPl)) then
            write (IFPl, 109) _TRIM(TSOt), _TRIM(TSOr), jTgtO
         else if (COND_S(IFPl)) then
            write (*,    109) _TRIM(TSOt), _TRIM(TSOr), jTgtO
         endif
      endif
      if (iErr.eq.0) then
CCC_   + Search root operator
         jOprR = KOPref
         do
            if (ipKW (KWI_FLG, jOprR, KSW).le.0) goto 100
            jOprR = ipKW (KWI_FLG, jOprR, KSW)
         enddo
 100     continue
         jRefO = ipKW (KWI_FLG, jOprR, KSW)
         if (jRefO.ne.KWF_DECLARED) then
            ipKW (KWI_FLG, jOprR,  KSW) = jTgtO
         endif
         ipKW (KWI_FLG, KOPtgt, KSW) = jOprR
         if      (COND_N(IFPl)) then
            write (IFPl, 101) _TRIM(TSOt), _TRIM(TSOr), jOprR
         else if (COND_S(IFPl)) then
            write (*,    101) _TRIM(TSOt), _TRIM(TSOr), jOprR
         endif
CCC_   + Search operators duplicated to KOPtgt
         do jo = 1, KWO1_MAX
            if (ipKW (KWI_FLG, jo, KSW) .eq. KOPtgt) then
               call AKPo2s (TSOt, jo, KSW, '/')
               if      (COND_N(IFPl)) then
                  write (IFPl, 102) _TRIM(TSOt), _TRIM(TSOr), jOprR
               else if (COND_S(IFPl)) then
                  write (*,    102) _TRIM(TSOt), _TRIM(TSOr), jOprR
               endif
               ipKW (KWI_FLG, jo, KSW) = jOprR
            endif
         enddo
      endif
      RETURN
      END
CCC_ & AKPsto  ## Property/stencils (overlap operation)
      subroutine AKPsto
     O    (iErr,
     I     LH, IE, ipKW, T, IFPl)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   ipKW (*)
      _INTENT(IN, integer)   LH
      _INTENT(IN, integer)   IE (*)
      _INTENT(IN, character) T*(*)
      _INTENT(IN, integer)   IFPl
CCC_  * Body
      iErr = 0
      if (iErr.eq.0)
     $     call AKPovl (iErr, ipKW, 'Wi', 'X', KWO_EWi, IE, T, IFPl)
      if (iErr.eq.0)
     $     call AKPovl (iErr, ipKW, 'Wo', 'X', KWO_EWo, IE, T, IFPl)
      if (iErr.eq.0)
     $     call AKPovl (iErr, ipKW, 'Ei', 'X', KWO_WEi, IE, T, IFPl)
      if (iErr.eq.0)
     $     call AKPovl (iErr, ipKW, 'Eo', 'X', KWO_WEo, IE, T, IFPl)
      if (iErr.eq.0)
     $     call AKPovl (iErr, ipKW, 'Ni', 'Y', KWO_SNi, IE, T, IFPl)
      if (iErr.eq.0)
     $     call AKPovl (iErr, ipKW, 'No', 'Y', KWO_SNo, IE, T, IFPl)
      if (iErr.eq.0)
     $     call AKPovl (iErr, ipKW, 'Si', 'Y', KWO_NSi, IE, T, IFPl)
      if (iErr.eq.0)
     $     call AKPovl (iErr, ipKW, 'So', 'Y', KWO_NSo, IE, T, IFPl)
      RETURN
      END
CCC_ & AKPovl  ## Property/stencils (overlap operation) set
      subroutine AKPovl
     O    (iErr, ipKW,
     I     Ctag, CX, KOP, IE, T, IFPl)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   ipKW (IPKW_FULL_DECL)
      _INTENT(IN, character) Ctag*(*), CX*(*)
      _INTENT(IN, integer)   IE (*)
      _INTENT(IN, integer)   KOP
      _INTENT(IN, character) T*(*)
      _INTENT(IN, integer)   IFPl
      integer LOV
      integer   IR, NHP
CCC_  * Body
      iErr = 0
      if (iErr.eq.0) IR  = EA_IR(IE)
      if (iErr.eq.0) NHP = EA_NP(IE)
      if (CX.eq.'X') then
         LOV = EA_LXO(IE)
      else
         LOV = EA_LYO(IE)
      endif
c
      if (iErr.eq.0) then
         call AKPovs
     O       (iErr, ipKW,
     I        IR, NHP, LOV, Ctag, KOP, KWM_M, IE, T, IFPl)
      endif
      if (iErr.eq.0) then
         call AKPovs
     O       (iErr, ipKW,
     I        IR, NHP, LOV, Ctag, KOP, KWM_T, IE, T, IFPl)
      endif
      call DAtrcU (IFPl, iErr, 'R', 'AKPOVL')
      RETURN
      END
CCC_ & AKPovs  ## Property/stencils (overlap operation) set/sub
      subroutine AKPovs
     O    (iErr, ipKW,
     I     IR,   NHP, LOV,
     I     Ctag, KOP, KSW, IE, T, IFPl)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   ipKW (IPKW_FULL_DECL)
      _INTENT(IN, character) Ctag*(*)
      _INTENT(IN, integer)   IR, NHP, LOV
      _INTENT(IN, integer)   IE (*)
      _INTENT(IN, integer)   KOP, KSW
      _INTENT(IN, character) T*(*)
      _INTENT(IN, integer)   IFPl
      integer jRdis, jRsrc, jOff
      integer j0, j9, js
      character TSO*(8)
CCC_  * Body
      iErr = 0
      if (LOV.le.0) then
         jOff = 0
         jRdis = -1
         jRsrc = -1
         j0    = 0
         j9    = 0
         js    = -1
         ipKW (KWC_IRD, KOP, KSW) = -1
         ipKW (KWC_IRS, KOP, KSW) = -1
         ipKW (KWI_OFI, KOP, KSW) = 0
         ipKW (KWI_LI0, KOP, KSW) = 1
         ipKW (KWI_LI9, KOP, KSW) = 0
         ipKW (KWI_LIS, KOP, KSW) = -1
         ipKW (KWI_OFC, KOP, KSW) = 0
         ipKW (KWI_LC0, KOP, KSW) = 1
         ipKW (KWI_LC9, KOP, KSW) = 0
         ipKW (KWI_LCS, KOP, KSW) = 1
      else
         if (KSW.eq.KWM_M) then
            call AEAgtp (iErr, jRdis, Ctag(1:1), 'R', Ctag(2:2), IE)
            call AEAgtp (iErr, jRsrc, Ctag(1:1), 'D', Ctag(2:2), IE)
            call AEAgtp (iErr, jOff,  Ctag(1:1), 'S', Ctag(2:2), IE)
         else
            call AEAgtp (iErr, jRdis, Ctag(1:1), 'D', Ctag(2:2), IE)
            call AEAgtp (iErr, jRsrc, Ctag(1:1), 'R', Ctag(2:2), IE)
            call AEAgtp (iErr, jOff,  Ctag(1:1), 'T', Ctag(2:2), IE)
         endif
c
         j0 =        MAX (1,   1   - jOff)
         j9 = MAX (0, NHP - (MAX (NHP, NHP + jOff) - NHP))
         js = 1
c
         ipKW (KWC_IRD, KOP, KSW) = jRdis
         ipKW (KWC_IRS, KOP, KSW) = jRsrc
         if (IR.eq.jRdis .and. IR.eq.jRsrc) then
            ipKW (KWI_OFI, KOP, KSW) = jOff
            ipKW (KWI_LI0, KOP, KSW) = j0
            ipKW (KWI_LI9, KOP, KSW) = j9
            ipKW (KWI_LIS, KOP, KSW) = js
c
            ipKW (KWI_OFC, KOP, KSW) = 0
            ipKW (KWI_LC0, KOP, KSW) = 1
            ipKW (KWI_LC9, KOP, KSW) = 0
            ipKW (KWI_LCS, KOP, KSW) = 1
         else
            ipKW (KWI_OFC, KOP, KSW) = jOff
            ipKW (KWI_LC0, KOP, KSW) = j0
            ipKW (KWI_LC9, KOP, KSW) = j9
            ipKW (KWI_LCS, KOP, KSW) = js
c
            ipKW (KWI_OFI, KOP, KSW) = 0
            ipKW (KWI_LI0, KOP, KSW) = 1
            ipKW (KWI_LI9, KOP, KSW) = 0
            ipKW (KWI_LIS, KOP, KSW) = 1
         endif
      endif
c
 201  format ('AKPOVS:', A, ':', A, ':R', 1x, I5,1x,2I5,1x,I5)
 203  format ('AKPOVS:', A, ':', A, ':L', 1x, 3I5)
      call AKPo2s (TSO, KOP, KSW, '/')
      if      (COND_N(IFPl)) then
         write (IFPl, 201)
     $        _TRIM(T), _TRIM(TSO), jOff, jRdis, jRsrc, IR
         write (IFPl, 203)
     $        _TRIM(T), _TRIM(TSO), j0, j9, js
      else if (COND_S(IFPl)) then
         write (*,    201)
     $        _TRIM(T), _TRIM(TSO), jOff, jRdis, jRsrc, IR
         write (*,    203)
     $        _TRIM(T), _TRIM(TSO), j0, j9, js
      endif
      RETURN
      END
CCC_ & AKPst2  ## Property/stencils (2-terms operation)
      subroutine AKPst2
     O    (iErr,
     I     LH, IE, ipKW, T, IFPl)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   ipKW (*)
      _INTENT(IN, integer)   LH
      _INTENT(IN, integer)   IE (*)
      _INTENT(IN, character) T*(*)
      _INTENT(IN, integer)   IFPl
      integer    LTBL
      parameter (LTBL = 8)
      integer    kDTA (LTBL, 3)
      integer    KSTNCL (4)
      integer    KDLbi
#define _DIR_S 1
#define _DIR_W 2
#define _DIR_E 3
#define _DIR_N 4
CCC_  * Body
      iErr  = 0
      KDLbi = 0
CCC_   + create stencils
      if (iErr.eq.0) then
         call AEScmt
     O       (iErr, KSTNCL (_DIR_S), kDTA, LTBL,
     I        0,  0,  0,  1,  LH,  IE, IFPl)
CC            S   W   E   N
      endif
      if (iErr.eq.0) then
         call AEScmt
     O       (iErr, KSTNCL (_DIR_W), kDTA, LTBL,
     I        0,  0,  1,  0,  LH,  IE, IFPl)
      endif
      if (iErr.eq.0) then
         call AEScmt
     O       (iErr, KSTNCL (_DIR_E), kDTA, LTBL,
     I        0,  1,  0,  0,  LH,  IE, IFPl)
      endif
      if (iErr.eq.0) then
         call AEScmt
     O       (iErr, KSTNCL (_DIR_N), kDTA, LTBL,
     I        1,  0,  0,  0,  LH,  IE, IFPl)
      endif
CCC_   + set property (offset, shift, stencils)
      if (iErr.eq.0) then
         KDLbi = EA_KDLbi(IE)
         if (KDLbi.eq.0) iErr = -512
      endif
      if (iErr.eq.0) then
CCC_    * to east
         call AKPnp2 (ipKW, _DIR_E,KWO_DXab,KSTNCL,IE, T, IFPl)
         call AKPnp2 (ipKW, _DIR_E,KWO_GXab,KSTNCL,IE, T, IFPl)
         call AKPnp2 (ipKW, _DIR_E,KWO_Lab, KSTNCL,IE, T, IFPl)
         call AKPnp2 (ipKW, _DIR_E,KWO_DXcd,KSTNCL,IE, T, IFPl)
         call AKPnp2 (ipKW, _DIR_E,KWO_GXcd,KSTNCL,IE, T, IFPl)
         call AKPnp2 (ipKW, _DIR_E,KWO_Lcd, KSTNCL,IE, T, IFPl)
         call AKPnp2 (ipKW, _DIR_E,KWO_SAab,KSTNCL,IE, T, IFPl)
         call AKPnp2 (ipKW, _DIR_E,KWO_SDab,KSTNCL,IE, T, IFPl)
         call AKPnp2 (ipKW, _DIR_E,KWO_FCab,KSTNCL,IE, T, IFPl)
         call AKPnp2 (ipKW, _DIR_E,KWO_SAcd,KSTNCL,IE, T, IFPl)
         call AKPnp2 (ipKW, _DIR_E,KWO_SDcd,KSTNCL,IE, T, IFPl)
         call AKPnp2 (ipKW, _DIR_E,KWO_FCcd,KSTNCL,IE, T, IFPl)
CCC_    * to west
         call AKPnp2 (ipKW, _DIR_W,KWO_DXba,KSTNCL,IE, T, IFPl)
         call AKPnp2 (ipKW, _DIR_W,KWO_GXba,KSTNCL,IE, T, IFPl)
         call AKPnp2 (ipKW, _DIR_W,KWO_Lba, KSTNCL,IE, T, IFPl)
         call AKPnp2 (ipKW, _DIR_W,KWO_DXdc,KSTNCL,IE, T, IFPl)
         call AKPnp2 (ipKW, _DIR_W,KWO_GXdc,KSTNCL,IE, T, IFPl)
         call AKPnp2 (ipKW, _DIR_W,KWO_Ldc, KSTNCL,IE, T, IFPl)
         call AKPnp2 (ipKW, _DIR_W,KWO_SAba,KSTNCL,IE, T, IFPl)
         call AKPnp2 (ipKW, _DIR_W,KWO_SDba,KSTNCL,IE, T, IFPl)
         call AKPnp2 (ipKW, _DIR_W,KWO_FCba,KSTNCL,IE, T, IFPl)
         call AKPnp2 (ipKW, _DIR_W,KWO_SAdc,KSTNCL,IE, T, IFPl)
         call AKPnp2 (ipKW, _DIR_W,KWO_SDdc,KSTNCL,IE, T, IFPl)
         call AKPnp2 (ipKW, _DIR_W,KWO_FCdc,KSTNCL,IE, T, IFPl)
CCC_    * to north
         call AKPnp2 (ipKW, _DIR_N,KWO_DYac,KSTNCL,IE, T, IFPl)
         call AKPnp2 (ipKW, _DIR_N,KWO_GYac,KSTNCL,IE, T, IFPl)
         call AKPnp2 (ipKW, _DIR_N,KWO_Lac, KSTNCL,IE, T, IFPl)
         call AKPnp2 (ipKW, _DIR_N,KWO_DYbd,KSTNCL,IE, T, IFPl)
         call AKPnp2 (ipKW, _DIR_N,KWO_GYbd,KSTNCL,IE, T, IFPl)
         call AKPnp2 (ipKW, _DIR_N,KWO_Lbd, KSTNCL,IE, T, IFPl)
         call AKPnp2 (ipKW, _DIR_N,KWO_SAac,KSTNCL,IE, T, IFPl)
         call AKPnp2 (ipKW, _DIR_N,KWO_SDac,KSTNCL,IE, T, IFPl)
         call AKPnp2 (ipKW, _DIR_N,KWO_FCac,KSTNCL,IE, T, IFPl)
         call AKPnp2 (ipKW, _DIR_N,KWO_SAbd,KSTNCL,IE, T, IFPl)
         call AKPnp2 (ipKW, _DIR_N,KWO_SDbd,KSTNCL,IE, T, IFPl)
         call AKPnp2 (ipKW, _DIR_N,KWO_FCbd,KSTNCL,IE, T, IFPl)
CCC_    * to south
         call AKPnp2 (ipKW, _DIR_S,KWO_DYca,KSTNCL,IE, T, IFPl)
         call AKPnp2 (ipKW, _DIR_S,KWO_GYca,KSTNCL,IE, T, IFPl)
         call AKPnp2 (ipKW, _DIR_S,KWO_Lca, KSTNCL,IE, T, IFPl)
         call AKPnp2 (ipKW, _DIR_S,KWO_DYdb,KSTNCL,IE, T, IFPl)
         call AKPnp2 (ipKW, _DIR_S,KWO_GYdb,KSTNCL,IE, T, IFPl)
         call AKPnp2 (ipKW, _DIR_S,KWO_Ldb, KSTNCL,IE, T, IFPl)
         call AKPnp2 (ipKW, _DIR_S,KWO_SAca,KSTNCL,IE, T, IFPl)
         call AKPnp2 (ipKW, _DIR_S,KWO_SDca,KSTNCL,IE, T, IFPl)
         call AKPnp2 (ipKW, _DIR_S,KWO_FCca,KSTNCL,IE, T, IFPl)
         call AKPnp2 (ipKW, _DIR_S,KWO_SAdb,KSTNCL,IE, T, IFPl)
         call AKPnp2 (ipKW, _DIR_S,KWO_SDdb,KSTNCL,IE, T, IFPl)
         call AKPnp2 (ipKW, _DIR_S,KWO_FCdb,KSTNCL,IE, T, IFPl)
      endif
      RETURN
      END
CCC_ & AKPnp2  ## Property/set neighborhood (2-term operation)
      subroutine AKPnp2
     O    (ipKW,
     I     kdir, KOP, KSTNCL, IE, T, IFPl)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,integer)   ipKW (IPKW_FULL_DECL)
      _INTENT(IN, integer)   kdir
      _INTENT(IN, integer)   KSTNCL (*)
      _INTENT(IN, integer)   IE (*)
      _INTENT(IN, integer)   KOP
      _INTENT(IN, character) T*(*)
      _INTENT(IN, integer)   IFPl
c
      character CX
c
      integer   KWT (4)
      character CTT (4)
CC                     S    W    E    N
      data      CTT  /'Y', 'X', 'X', 'Y'/
      save      CTT
c     kdfT 1: dist = P, src = M (normal)
c     kdfT 2: dist = M, src = P (normal)
      integer   kdfTbl (4)
CC                       S  W  E  N
      data      kdfTbl / 1, 1, 2, 2/
      save      kdfTbl
      integer   kdfM, kdfT
c
      integer   kstt (4)
      data      kstt /_DIR_N,_DIR_E,_DIR_W,_DIR_S/
      save      kstt
CCC_  * Body
CC    Stencil widths (moat-type) are opposite of operator direction
      KWT (_DIR_S) = 0
      KWT (_DIR_E) = 0
      KWT (_DIR_W) = 0
      KWT (_DIR_N) = 0
c$$$      KWT (kdir)   = 1
      KWT (kstt (kdir))   = 1
c
      ipKW (KWC_CWS, KOP, KWM_M) = KWT (_DIR_S)
      ipKW (KWC_CWW, KOP, KWM_M) = KWT (_DIR_W)
      ipKW (KWC_CWE, KOP, KWM_M) = KWT (_DIR_E)
      ipKW (KWC_CWN, KOP, KWM_M) = KWT (_DIR_N)
      ipKW (KWC_CWS, KOP, KWM_T) = KWT (kstt (_DIR_S))
      ipKW (KWC_CWW, KOP, KWM_T) = KWT (kstt (_DIR_W))
      ipKW (KWC_CWE, KOP, KWM_T) = KWT (kstt (_DIR_E))
      ipKW (KWC_CWN, KOP, KWM_T) = KWT (kstt (_DIR_N))
c
      ipKW (KWC_TPS, KOP, KWM_M) = KSTNCL (kdir)
      ipKW (KWC_TPD, KOP, KWM_M) = KSTNCL (kdir)
      ipKW (KWC_TPS, KOP, KWM_T) = KSTNCL (kstt (kdir))
      ipKW (KWC_TPD, KOP, KWM_T) = KSTNCL (kstt (kdir))
CCC_   + direction config
      CX  = CTT (kdir)
c
      kdfM = kdfTbl (kdir)
      kdfT = 3 - kdfM
c
      call AKPn2s (ipKW, CX, kdfM, KOP, KWM_M, IE, T, IFPl)
      call AKPn2s (ipKW, CX, kdfT, KOP, KWM_T, IE, T, IFPl)
c
      RETURN
      END
CCC_ & AKPn2s  ## Property/set neighborhood (2-term operation/sub)
      subroutine AKPn2s
     O    (ipKW,
     I     CX,   kdirF,  KOP, KSW,
     I     IE,   T,      IFPl)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,integer)   ipKW (IPKW_FULL_DECL)
      _INTENT(IN, character) CX*(*)
      _INTENT(IN, integer)   kdirF, KOP, KSW
      _INTENT(IN, integer)   IE (*)
      _INTENT(IN, character) T*(*)
      _INTENT(IN, integer)   IFPl
      integer jRdis, jRsrc
      integer jOFCm, jOFIm
      integer jc0,   jc9,   jcs
      integer ji0,   ji9,   jis
      integer NHP,   nhpr
      character CDS(2)*1
      data      CDS /'P', 'M'/
      save      CDS
      character CD, CS
      character TSO*(8)
      integer   jkd, jks
      character CXD*(2), CXS*(2)
CCC_  * Body
      CD = CDS (kdirF)
      CS = CDS (3 - kdirF)
 105  format (A1,A1)
      write (CXD, 105) CX, CD
      write (CXS, 105) CX, CS
      call AETqnk (jkd, CXD)
      call AETqnk (jks, CXS)
      if (jkd.ge.0) then
         jRdis = EA_IRn(IE,jkd)
      endif
      if (jks.ge.0) then
         jRsrc = EA_IRn(IE,jks)
         jOFCm = EA_ISn(IE,jks)
         jOFIm = EA_IIn(IE,jks)
         jc0   = EA_JIn(IE,jks)
         jc9   = EA_JEn(IE,jks)
         jcs   = EA_JSn(IE,jks)
         nhpr  = EA_NHn(IE,jks)
      endif
c
      NHP = EA_NP(IE)
      ji0 =                MAX (1,   1   - jOFIm)
      ji9 = MAX (0, NHP - (MAX (NHP, NHP + jOFIm) - NHP))
      jis = 1
c
      ipKW (KWC_IRD, KOP, KSW) = jRdis
      ipKW (KWC_IRS, KOP, KSW) = jRsrc
      ipKW (KWI_OFC, KOP, KSW) = + jOFCm
      ipKW (KWI_OFI, KOP, KSW) = + jOFIm
      ipKW (KWI_LC0, KOP, KSW) = jc0
      ipKW (KWI_LC9, KOP, KSW) = jc9
      ipKW (KWI_LCS, KOP, KSW) = jcs
      ipKW (KWI_LI0, KOP, KSW) = ji0
      ipKW (KWI_LI9, KOP, KSW) = ji9
      ipKW (KWI_LIS, KOP, KSW) = jis
c
 201  format ('AKPN2S:', A, ':', A, ':R',     1x, 2I5)
 204  format ('AKPN2S:', A, ':', A, ':O',     1x, 2I5)
 203  format ('AKPN2S:', A, ':', A, ':L', A1, 1x, 3I5)
 202  format ('AKPN2S:', A, ':', A, ':W',     1x, 4I5)
      call AKPo2s (TSO, KOP, KSW, '/')
      if      (COND_N(IFPl)) then
         write (IFPl, 201) _TRIM(T), _TRIM(TSO), jRdis, jRsrc
         write (IFPl, 204) _TRIM(T), _TRIM(TSO), jOFCm, jOFIm
         write (IFPl, 203) _TRIM(T), _TRIM(TSO), 'C', jc0, jc9, jcs
         write (IFPl, 203) _TRIM(T), _TRIM(TSO), 'I', ji0, ji9, jis
         write (IFPl, 202) _TRIM(T), _TRIM(TSO),
     $        ipKW (KWC_CWS, KOP, KSW), ipKW (KWC_CWW, KOP, KSW),
     $        ipKW (KWC_CWE, KOP, KSW), ipKW (KWC_CWN, KOP, KSW)
      else if (COND_S(IFPl)) then
         write (*,    201) _TRIM(T), _TRIM(TSO), jRdis, jRsrc
         write (*,    204) _TRIM(T), _TRIM(TSO), jOFCm, jOFIm
         write (*,    203) _TRIM(T), _TRIM(TSO), 'C', jc0, jc9, jcs
         write (*,    203) _TRIM(T), _TRIM(TSO), 'I', ji0, ji9, jis
         write (*,    202) _TRIM(T), _TRIM(TSO),
     $        ipKW (KWC_CWS, KOP, KSW), ipKW (KWC_CWW, KOP, KSW),
     $        ipKW (KWC_CWE, KOP, KSW), ipKW (KWC_CWN, KOP, KSW)
      endif
c
      RETURN
      END
CCC_ & AKPmxw  ## Max k-index inquire wrapper
      subroutine AKPmxw
     O    (KI,
     I     ipKW)
      implicit none
      _INTENT(OUT,integer) KI
      _INTENT(IN, integer) ipKW (IPKW_FULL_DECL)
      integer KIO, KIA
      KIO = 0
      KIA = 0
      call AKPmxi (KIO, KWI_KWO, ipKW)
      call AKPmxi (KIA, KWI_KWA, ipKW)
      KI = MAX (KIO, KIA)
      RETURN
      END
CCC_ & AKPmxi  ## Max k-index inquire
      subroutine AKPmxi
     O    (KI,
     I     jAttr, ipKW)
      implicit none
      _INTENT(OUT,integer) KI
      _INTENT(IN, integer) jAttr
      _INTENT(IN, integer) ipKW (IPKW_FULL_DECL)
      integer lm, lo
      KI = 0
      do    lm = KWM_M, KWM_T
         do lo = 1,     KWO1_MAX
            KI = Max (KI, ipKW (jAttr, lo, lm))
         enddo
      enddo
      RETURN
      END
CCC_ & AKPqki  ## k-index inquire
      subroutine AKPqki
     O    (iStt,
     M     KI,
     I     ipKW, LKI, KOP, KSW, IFPl)
CC     return 0 to copy
CC            1 to skip
CC            otherwise error
CCC_  * Declaration
      implicit none
      _INTENT(OUT,  integer)   iStt
      _INTENT(INOUT,integer)   KI
      _INTENT(IN,   integer)   LKI
      _INTENT(IN,   integer)   KOP, KSW
      _INTENT(IN,   integer)   ipKW (IPKW_FULL_DECL)
      _INTENT(IN,   integer)   IFPl
      integer   jFlg
      character TSO*(8)
CCC_  * Body
      jFlg = ipKW (KWI_FLG, KOP, KSW)
      if (jFlg .eq. KWF_NOTSET) then
         iStt = 1
      else if (jFlg .eq. KWF_DECLARED) then
         KI = KI + 1
         if (KI.gt.LKI) then
            iStt = -1
         else
            iStt = 0
         endif
      else
         iStt = -2
      endif
CCC_   + report
 101  format ('AKPQKI:', I3.3, ':', I1, ':', A, ': ', 2I4, 1x, I2)
      call AKPo2s (TSO, KOP, KSW, '/')
      if      (COND_N(IFPl)) then
         write (IFPl, 101)
     $        KOP, KSW, _TRIM(TSO), KI, LKI, iStt
      else if (COND_S(IFPl)) then
         write (*,    101)
     $        KOP, KSW, _TRIM(TSO), KI, LKI, iStt
      endif
      RETURN
      END
CCC_ & AKPski  ## set K-index
      subroutine AKPski
     O    (iErr,
     M     ipKW,
     I     KI, jAttr, KOP, KSW)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   KI
      _INTENT(OUT,integer)   ipKW (IPKW_FULL_DECL)
      _INTENT(IN, integer)   jAttr, KOP, KSW
CCC_  * Body
      iErr = 0
      if (KSW .eq. KWM_BOTH) then
         ipKW (jAttr, KOP, KWM_M) = KI
         ipKW (jAttr, KOP, KWM_T) = KI
      else
         ipKW (jAttr, KOP, KSW) = KI
      endif
      RETURN
      END
CCC_ & AKPuvo  ## update O vector
      subroutine AKPuvo
     O    (iErr,
     M     WV,
     I     V,    MH,   LH,
     I     ipKW, KOP,  KSW)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   MH,  LH
      _INTENT(INOUT,_REALSTD)  WV  (LH, *)
      _INTENT(IN,   _REALSTD)  V   (*)
      _INTENT(IN,   integer)   ipKW (IPKW_FULL_DECL)
      _INTENT(IN,   integer)   KOP, KSW
      integer ki
CCC_  * Body
      iErr = 0
      ki = ipKW (KWI_KWO, KOP, KSW)
      if (ki.gt.0) then
         call UV1cpa (WV, V, MH, LH, KI, 1)
      endif
      RETURN
      END
CCC_ & AKPuva  ## update A vector
      subroutine AKPuva
     O    (iErr,
     M     WV,
     I     V,    MH,   LH,
     I     ipKW, KOP,  KSW)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   MH,  LH
      _INTENT(INOUT,_REALSTD)  WV  (LH, *)
      _INTENT(IN,   _REALSTD)  V   (*)
      _INTENT(IN,   integer)   ipKW (IPKW_FULL_DECL)
      _INTENT(IN,   integer)   KOP, KSW
      integer ki
CCC_  * Body
      iErr = 0
      ki = ipKW (KWI_KWA, KOP, KSW)
      if (ki.gt.0) then
         call UV1cpa (WV, V, MH, LH, KI, 1)
      endif
      RETURN
      END
CCC_ & AKPqcc  ## Property inquire/copy/set batch (for coordinate)
      subroutine AKPqcc
     O    (iErr,
     O     WV,
     M     KI,   ipKW,
     I     MH,   LH,   LKI,
     I     KOP,  KSW,  jAttr,
     I     icX,  CTAG, KADD,  KIDL,
     I     IE,   IFPl)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,integer)   KI
      _INTENT(INOUT,integer)   ipKW (IPKW_FULL_DECL)
      _INTENT(IN,   integer)   MH,  LH, LKI
      _INTENT(OUT,  _REALSTD)  WV  (LH, LKI)
      _INTENT(IN,   integer)   jAttr, KOP, KSW
      _INTENT(IN,   integer)   icX
      _INTENT(IN,   integer)   KADD
      _INTENT(IN,   integer)   KIDL
      _INTENT(IN,   integer)   IE (*)
      _INTENT(IN,   character) CTAG*(*)
      _INTENT(IN,   integer)   IFPl
      integer IV (1), Mdim, jcdmy
CCC_  * Body
      iErr = 0
      call AKPqcs
     O    (iErr,
     O     WV,
     M     KI,   ipKW,
     I     MH,   LH,   LKI,
     I     KOP,  KSW,  jAttr,
     I     icX,  CTAG, KADD,  KIDL,
     I     IE,   IFPl)
CC    TODO: CT may not set by _CPSW_G
      if (iErr.eq.0) then
         Mdim   = 1
         IV (1) = 0
         call ACCrfI
     $        (iErr, jcdmy, IV, icX, Mdim, 'CT', IFPl)
         ipKW (KWI_SW0, KOP, KSW) = IV (1)
      endif
      call DAtrcU (IFPl, iErr, 'R', 'AKEQCC')
      RETURN
      END
CCC_ & AKPqca  ## Property inquire/copy/set batch (for area)
      subroutine AKPqca
     O    (iErr,
     O     WV,
     M     KI,   ipKW,
     I     MH,   LH,   LKI,
     I     KOP,
     I     icX,  icY,
     I     IE,   IFPl)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,integer)   KI
      _INTENT(INOUT,integer)   ipKW (IPKW_FULL_DECL)
      _INTENT(IN,   integer)   MH,  LH, LKI
      _INTENT(OUT,  _REALSTD)  WV  (LH, LKI)
      _INTENT(IN,   integer)   KOP
      _INTENT(IN,   integer)   icX, icY
      _INTENT(IN,   integer)   IE (*)
      _INTENT(IN,   integer)   IFPl
      integer j
      integer KIX, KIY
      integer iStt
      integer jsw, jattr
CCC_  * Body
      iErr  = 0
c
      jsw   = KWM_M
      jattr = KWI_KWO
      call AKPqki (iStt, KI, ipKW, LKI, KOP, jsw, IFPl)
      if (iStt.eq.0) then
         KIX = KI  + 1
         KIY = KIX + 1
         if (KIY.gt.LKI) then
            iErr = -1
         else
            call AKPcpV
     O          (iErr, WV (1, KIX),
     I           MH,   LH,    icX, 'DP', 0, IE, _CPSW_I, IFPl)
            call AKPcpV
     O          (iErr, WV (1, KIY),
     I           MH,   LH,    icY, 'DP', 0, IE, _CPSW_J, IFPl)
            do j = 1, MH
               WV (j, KI) = WV (j, KIX) * WV (j, KIY)
            enddo
         endif
         call AKPski (iErr, ipKW, KI, jAttr, KOP, jsw)
      else if (iStt.eq.1) then
         continue
      else
         iErr = -1
      endif
      call DAtrcU (IFPl, iErr, 'R', 'AKEQCA')
      RETURN
      END
CCC_ & AKPqcw  ## Property inquire/copy/set batch (for wing mask)
      subroutine AKPqcw
     O    (iErr,
     O     WV,
     M     KI,   ipKW,
     I     MH,   LH,   LKI,
     I     KOP,
     I     icX,  icY,
     I     IE,   IFPl)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,integer)   KI
      _INTENT(INOUT,integer)   ipKW (IPKW_FULL_DECL)
      _INTENT(IN,   integer)   MH,  LH, LKI
      _INTENT(OUT,  _REALSTD)  WV  (LH, LKI)
      _INTENT(IN,   integer)   KOP
      _INTENT(IN,   integer)   icX, icY
      _INTENT(IN,   integer)   IE (*)
      _INTENT(IN,   integer)   IFPl
      integer j
      integer iStt
      integer jsw, jattr
      integer j0x, j0y
CCC_  * Body
      iErr  = 0
c
      jsw   = KWM_M
      jattr = KWI_KWO
      call AKPqki (iStt, KI, ipKW, LKI, KOP, jsw, IFPl)
      if (iStt.eq.0) then
         if (KI.gt.LKI) then
            iErr = -1
         else
            j0x = EA_idxXW(IE,0)
            j0y = EA_idxYW(IE,0)
            do j = 0, MH - 1
CCC_   . caution
CC          Condition for x and y are not the same.
CC          If the block has no north block,
CC          then the body should be at the northern boundary of the block.
CC
CC        example.  block x
CC          o - -
CC          o x o
               if (IE(j0x+j).ge.0.and.IE(j0y+j).ne.-1) then
c$$$               if (IE(j0x+j).ge.0.and.IE(j0y+j).ge.0) then
c$$$               if (IE(j0x+j).ne.-1.and.IE(j0y+j).ne.-1) then
                  WV (1+j, KI) = 1.0d0
               else
                  WV (1+j, KI) = 0.0d0
               endif
            enddo
         endif
         call AKPski (iErr, ipKW, KI, jAttr, KOP, jsw)
      else if (iStt.eq.1) then
         continue
      else
         iErr = -1
      endif
      call DAtrcU (IFPl, iErr, 'R', 'AKEQCW')
      RETURN
      END
CCC_ & AKPqcd  ## Property inquire/copy/set batch (for difference)
      subroutine AKPqcd
     O    (iErr,
     O     WW,
     M     KIO,   ipKW,
     I     MH,    LH,   LKW,
     I     KOP,
     I     icX,   CTO,  KADD,  KIDL,
     I     IE,    IFPl)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   MH, LH, LKW
      _INTENT(OUT,  _REALSTD)  WW (LH, LKW)
      _INTENT(INOUT,integer)   ipKW (*)
      _INTENT(INOUT,integer)   KIO
      _INTENT(IN,   integer)   IE   (*)
      _INTENT(IN,   integer)   KOP
      _INTENT(IN,   integer)   icX, KADD, KIDL
      _INTENT(IN,   character) CTO*(*)
      _INTENT(IN,   integer)   IFPl
      character TagA*(16), TagB*(16)
CCC_  * Body
      iErr = 0
c
 101  format (A, A)
      write (TagA, 101) _TRIM(CTO), 'A'
      write (TagB, 101) _TRIM(CTO), 'B'
c
      if (iErr.eq.0) then
         call AKPqcs
     O       (iErr,     WW,    KIO,  ipKW,
     I        MH,       LH,    LKW,
     I        KOP,      KWM_M, KWI_KWO,
     I        icX,      TagA,  0,    KIDL, IE, IFPl)
      endif
      if (iErr.eq.0) then
         call AKPqcs
     O       (iErr,     WW,    KIO,  ipKW,
     I        MH,       LH,    LKW,
     I        KOP,      KWM_M, KWI_KWA,
     I        icX,      TagB,  0,    KIDL, IE, IFPl)
      endif
      if (iErr.eq.0) then
         call AKPqcs
     O       (iErr,     WW,    KIO,  ipKW,
     I        MH,       LH,    LKW,
     I        KOP,      KWM_T, KWI_KWA,
     I        icX,      TagB,  KADD, KIDL, IE, IFPl)
      endif
      call DAtrcU (IFPl, iErr, 'R', 'AKPQCD')
      RETURN
      END
CCC_ & AKPqco  ## Property inquire/copy/set batch (for simple operation) [old:akpqca]
      subroutine AKPqco
     O    (iErr,
     O     WW,
     M     KIO,   ipKW,
     I     MH,    LH,   LKW,
     I     KOP,   FO,   FA,
     I     icX,   CTO,  KADD,  KIDL,
     I     IE,    IFPl)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   MH, LH, LKW
      _INTENT(IN,   _REALSTD)  FO, FA
      _INTENT(OUT,  _REALSTD)  WW (LH, LKW)
      _INTENT(INOUT,integer)   ipKW (*)
      _INTENT(INOUT,integer)   KIO
      _INTENT(IN,   integer)   IE   (*)
      _INTENT(IN,   integer)   KOP
      _INTENT(IN,   integer)   icX, KADD, KIDL
      _INTENT(IN,   character) CTO*(*)
      _INTENT(IN,   integer)   IFPl
      character TagA*(16), TagB*(16)
CCC_  * Body
      iErr = 0
c
 101  format (A, A)
      write (TagA, 101) _TRIM(CTO), 'A'
      write (TagB, 101) _TRIM(CTO), 'B'
c
      if (iErr.eq.0) then
         call AKPqcm
     O       (iErr, WW,    KIO,     ipKW,
     I        MH,   LH,    LKW,
     I        KOP,  KWM_M, KWI_KWO, FO,
     I        icX,  TagA,  0,       KIDL, IE, IFPl)
      endif
      if (iErr.eq.0) then
         call AKPqcm
     O       (iErr, WW,    KIO,     ipKW,
     I        MH,   LH,    LKW,
     I        KOP,  KWM_M, KWI_KWA, FA,
     I        icX,  TagB,  0,       KIDL, IE, IFPl)
      endif
      if (iErr.eq.0) then
         call AKPqcm
     O       (iErr, WW,    KIO,     ipKW,
     I        MH,   LH,    LKW,
     I        KOP,  KWM_T, KWI_KWA, FA,
     I        icX,  TagB,  KADD,    KIDL, IE, IFPl)
      endif
      call DAtrcU (IFPl, iErr, 'R', 'AKPQCO')
      RETURN
      END
CCC_ & AKPqcs  ## Property inquire/copy/set batch
      subroutine AKPqcs
     O    (iErr,
     O     WV,
     M     KI,   ipKW,
     I     MH,   LH,   LKI,
     I     KOP,  KSW,  jAttr,
     I     icX,  CTAG, KADD,  KIDL,
     I     IE,   IFPl)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,integer)   KI
      _INTENT(INOUT,integer)   ipKW (IPKW_FULL_DECL)
      _INTENT(IN,   integer)   MH,  LH, LKI
      _INTENT(OUT,  _REALSTD)  WV  (LH, LKI)
      _INTENT(IN,   integer)   jAttr, KOP, KSW
      _INTENT(IN,   integer)   IE (*)
      _INTENT(IN,   integer)   icX
      _INTENT(IN,   integer)   KADD, KIDL
      _INTENT(IN,   character) CTAG*(*)
      _INTENT(IN,   integer)   IFPl
      integer iStt
      integer jSW
CCC_  * Body
      iErr = 0
      call AKPqki (iStt, KI, ipKW, LKI, KOP, KSW, IFPl)
c
 101  format ('AKPQCS[', I2, ']: ',
     $     I3, 1x, I3.3, I1, 1x, I3, ' CF ', I3, '[', A, ']')
      if      (COND_N(IFPl)) then
         write (IFPl, 101)
     $        iStt, KI, KOP, KSW, jAttr, icX, _TRIM(CTAG)
      else if (COND_S(IFPl)) then
         write (*,    101)
     $        iStt, KI, KOP, KSW, jAttr, icX, _TRIM(CTAG)
      endif
c
      if (iStt.eq.0) then
         call AKPcpV
     O       (iErr, WV (1, KI),
     I        MH,   LH,    icX, CTAG, KADD, IE, KIDL, IFPl)
         if (iErr.eq.0) then
            if (KSW .eq. KWM_M) then
               jsw = KWM_BOTH
            else
               jsw = KSW
            endif
            call AKPski (iErr, ipKW, KI, jAttr, KOP, jsw)
         endif
      else if (iStt.eq.1) then
         continue
      else
         iErr = -1
      endif
      call DAtrcU (IFPl, iErr, 'R', 'AKPQCS')
      RETURN
      END
CCC_ & AKPqcm  ## Property inquire/copy/set batch (modify if not zero)
      subroutine AKPqcm
     O    (iErr,
     O     WV,
     M     KI,   ipKW,
     I     MH,   LH,   LKI,
     I     KOP,  KSW,  jAttr, CM,
     I     icX,  CTAG, KADD,  KIDL,
     I     IE,   IFPl)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,integer)   KI
      _INTENT(INOUT,integer)   ipKW (IPKW_FULL_DECL)
      _INTENT(IN,   integer)   MH,  LH, LKI
      _INTENT(OUT,  _REALSTD)  WV  (LH, LKI)
      _INTENT(IN,   _REALSTD)  CM
      _INTENT(IN,   integer)   jAttr, KOP, KSW
      _INTENT(IN,   integer)   IE (*)
      _INTENT(IN,   integer)   icX
      _INTENT(IN,   integer)   KADD, KIDL
      _INTENT(IN,   character) CTAG*(*)
      _INTENT(IN,   integer)   IFPl
      integer iStt
      integer jSW
      integer j
CCC_  * Body
      iErr = 0
      call AKPqki (iStt, KI, ipKW, LKI, KOP, KSW, IFPl)
c
 101  format ('AKPQCM[', I2, ']: ',
     $     I3, 1x, I3.3, I1, 1x, I3, ' CF ', I3, '[', A, ']')
      if      (COND_N(IFPl)) then
         write (IFPl, 101)
     $        iStt, KI, KOP, KSW, jAttr, icX, _TRIM(CTAG)
      else if (COND_S(IFPl)) then
         write (*,    101)
     $        iStt, KI, KOP, KSW, jAttr, icX, _TRIM(CTAG)
      endif
c
      if (iStt.eq.0) then
         call AKPcpV
     O       (iErr, WV (1, KI),
     I        MH,   LH,    icX, CTAG, KADD, IE, KIDL, IFPl)
         if (iErr.eq.0) then
            do j = 1, MH
               if (WV (j, KI).ne.0.0d0) then
                  WV (j, KI) = CM
               endif
            enddo
         endif
         if (iErr.eq.0) then
            if (KSW .eq. KWM_M) then
               jsw = KWM_BOTH
            else
               jsw = KSW
            endif
            call AKPski (iErr, ipKW, KI, jAttr, KOP, jsw)
         endif
      else if (iStt.eq.1) then
         continue
      else
         iErr = -1
      endif
      RETURN
      END
CCC_ & AKPcpV  ## copy vector
      subroutine AKPcpV
     O    (iErr,
     O     WV,
     I     MH,  LH,
     I     icX, CTAG, KADD, IE, KIDL, IFPl)
CCC_  * Description
CC     copy icX[D:CTAG] using IE/list-vector
CCC_  * Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   MH,  LH
      _INTENT(OUT,_REALSTD)  WV  (LH)
      _INTENT(IN, integer)   IE (*)
      _INTENT(IN, integer)   icX
      _INTENT(IN, integer)   KADD
      _INTENT(IN, character) CTAG*(*)
      _INTENT(IN, integer)   KIDL
      _INTENT(IN, integer)   IFPl
      integer   icV, icDmy
      integer   j0x
      integer   kadi
CCC_  * Body
      iErr = 0
      kadi = KADD
      j0x  = -1
      icV  = 0
CCC_   + search corresponding value
      call ACCchD (iErr, icV, icX, CTAG, IFPl)
      if (icV.eq.0) then
 101     format ('AKPCPV: NO TARGET VECTOR ', I4, 1x, A)
         if      (COND_N(IFPl)) then
            write (IFPl, 101) icX, _TRIM(CTAG)
         else if (COND_S(IFPl)) then
            write (*,    101) icX, _TRIM(CTAG)
         endif
         iErr = -1
      else
         iErr = 0
         if      (KIDL.eq. _CPSW_I) then
c$$$            j0x = EA_idxLX(IE,0)
            j0x = EA_idxPX(IE,0)
         else if (KIDL.eq. _CPSW_J) then
c$$$            j0x = EA_idxLY(IE,0)
            j0x = EA_idxPY(IE,0)
         else if (KIDL.eq. _CPSW_G) then
c$$$            j0x = EA_idxLW(IE,0)
            j0x = EA_idxPW(IE,0)
         else
 102        format ('AKPCPV: INVALID COPY SWITCH ', I4, 1x, I4)
            if      (COND_N(IFPl)) then
               write (IFPl, 102) icX, KIDL
            else if (COND_S(IFPl)) then
               write (*,    102) icX, KIDL
            endif
            iErr = -1
         endif
      endif
CCC_   + copy vector using index-array
      if (iErr.eq.0) then
c$$$         write (*, *) 'j0x', j0x
         call ACCrlD
     O       (iErr, icDmy, WV,
     I        icX,  MH,    IE (j0x),  kadi, CTAG, IFPl)
      endif
      call DAtrcU (IFPl, iErr, 'R', 'AKPCPV')
      RETURN
      END
CCC_ & AKPcpo  ## Cartesian properties copy (overlap/sub)
      subroutine AKPcpo
     O    (iErr,
     O     WW,
     M     KIO,   ipKW,
     I     KOP,   Ctag,
     I     MH,    LH,   LKW,
     I     IE,    IFPl)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   MH, LH, LKW
      _INTENT(OUT,  _REALSTD)  WW (LH, LKW)
      _INTENT(INOUT,integer)   ipKW (*)
      _INTENT(INOUT,integer)   KIO
      _INTENT(IN,   integer)   IE   (*)
      _INTENT(IN,   integer)   KOP
      _INTENT(IN,   character) CTag*(*)
      _INTENT(IN,   integer)   IFPl
      integer   KCU, KSW, J0C
      integer   ju
      integer   kp
      integer   iStt
CCC_  * Body
      iErr = 0
      call AEPctu (Ctag, KCU)
CCC_   + normal
      KSW = KWM_M
      call AKPqki (iStt, KIO, ipKW, LKW, KOP, KSW, IFPl)
      if (iStt.eq.0) then
         J0C = EA_idxCU(IE,0)
         do kp = 0, MH - 1
            ju = IE (J0C + kp)
            if (ju.eq.KCU) then
               WW (1 + kp, KIO) = 1.0d0
            else
               WW (1 + kp, KIO) = 0.0d0
            endif
         enddo
         call AKPski (iErr, ipKW, KIO, KWI_KWO, KOP, ksw)
      else if (iStt.eq.1) then
         iErr = 0
      else
         iErr = -1
      endif
CCC_   + transpose
      KSW = KWM_T
      call AKPqki (iStt, KIO, ipKW, LKW, KOP, KSW, IFPl)
      if (iStt.eq.0) then
         J0C = EA_idxCT(IE,0)
         do kp = 0, MH - 1
            ju = MOD (IE (J0C + kp) / (2 ** (KCU - 1)), 2)
            if (ju.eq.1) then
               WW (1 + kp, KIO) = 1.0d0
            else
               WW (1 + kp, KIO) = 0.0d0
            endif
         enddo
         call AKPski (iErr, ipKW, KIO, KWI_KWO, KOP, ksw)
      else if (iStt.eq.1) then
         iErr = 0
      else
         iErr = -1
      endif
      call DAtrcU (IFPl, iErr, 'R', 'AKPCPO')
      RETURN
      END
CCC_ & AKPadj  ## Property adjustment
      subroutine AKPadj
     O    (iErr,
     M     ipKW,
     I     IFPl)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(INOUT,integer)   ipKW (IPKW_FULL_DECL)
      _INTENT(IN,   integer)   IFPl
      integer jo, jm, jroot
CCC_  * Body
      iErr = 0
      do jo = 1, KWO1_MAX
         do jm = KWM_M, KWM_T
            if (ipKW (KWI_FLG, jo, jm) .gt. 0) then
               jroot = ipKW (KWI_FLG, jo, jm)
               ipKW (KWI_KWO, jo, jm) = ipKW (KWI_KWO, jroot, jm)
               ipKW (KWI_KWA, jo, jm) = ipKW (KWI_KWA, jroot, jm)
            endif
         enddo
      enddo
      call DAtrcU (IFPl, iErr, 'R', 'AKPADJ')
      RETURN
      END
CCC_ & AKPrpp  ## Property report
      subroutine AKPrpp
     I    (ipKW, T, LKW, IFPl)
CCC_  * Declaration
      implicit none
      _INTENT(IN, integer)   ipKW (IPKW_FULL_DECL)
      _INTENT(IN, character) T*(*)
      _INTENT(IN, integer)   LKW
      _INTENT(IN, integer)   IFPl
      integer   jo, jm, jroot
      character Stt*(16), Flg*(1)
      character TSO*(8)
      integer   KIW
CCC_  * Body
 301  format ('AKPRPP[', A, ':', A, '] ',A1, 1x, A, 1x, 2I4)
      do jo = 1, KWO1_MAX
         do jm = KWM_M, KWM_T
            jroot = jo
            if (ipKW (KWI_FLG, jroot, jm) .gt. 0) then
               jroot = ipKW (KWI_FLG, jroot, jm)
 101           format ('DUP/',I3.3)
               write (Stt, 101) ipKW (KWI_FLG, jo, jm)
            else if (ipKW (KWI_FLG, jroot, jm) .eq. KWF_NOTSET) then
               Stt = 'ROOT'
            else if (ipKW (KWI_FLG, jroot, jm) .eq. KWF_DECLARED) then
               Stt = 'ROOT'
            else
 102           format ('ERR/',I5.5)
               write (Stt, 102) ipKW (KWI_FLG, jo, jm)
            endif
            if (ipKW (KWI_FLG, jroot, jm) .ge. KWF_NOTSET) then
               Flg = '.'
            else if (ipKW (KWI_FLG, jroot, jm) .eq. KWF_DECLARED) then
               Flg = 'X'
            else
               Flg = '!'
            endif
            call AKPo2s (TSO, jo, jm, '/')
            if      (COND_N(IFPl)) then
               write (IFPl, 301) _TRIM(T), _TRIM(TSO),
     $              Flg, _TRIM(Stt),
     $              ipKW (KWI_KWO, jo, jm),ipKW (KWI_KWA, jo, jm)
            else if (COND_S(IFPl)) then
               write (*,    301) _TRIM(T), _TRIM(TSO),
     $              Flg, _TRIM(Stt),
     $              ipKW (KWI_KWO, jo, jm),ipKW (KWI_KWA, jo, jm)
            endif
         enddo
      enddo
c
 302  format ('AKPRPP[', A, '/', A, '] ', 2I4)
      call AKPmxw (KIW, ipKW)
      if      (COND_N(IFPl)) then
         write (IFPl, 302) _TRIM(T), 'O', KIW, LKW
         write (IFPl, 302) _TRIM(T), 'A', KIW, LKW
      else if (COND_S(IFPl)) then
         write (*,    302) _TRIM(T), 'O', KIW, LKW
         write (*,    302) _TRIM(T), 'A', KIW, LKW
      endif
c
      RETURN
      END
CCC_ & AKPrpv  ## Vector report
      subroutine AKPrpv
     I    (WW,
     I     MH,  LH, ipKW, T, IFPl)
CCC_  * Declaration
      implicit none
      _INTENT(IN, _REALSTD)  WW (*)
      _INTENT(IN, integer)   MH, LH
      _INTENT(IN, integer)   ipKW (IPKW_FULL_DECL)
      _INTENT(IN, character) T*(*)
      _INTENT(IN, integer)   IFPl
      integer jo,  kop
      integer kom, kot
      integer kam, kat
      character TSO*(8)
CCC_  * Body
 101  format ('AKPRPV[', A, ':', A, ':', I3.3, '] ', 4I4)
      do jo = 1, KWO1_MAX
         kop = jo
         kom = ipKW (KWI_KWO, kop, KWM_M)
         kot = ipKW (KWI_KWO, kop, KWM_T)
         kam = ipKW (KWI_KWA, kop, KWM_M)
         kat = ipKW (KWI_KWA, kop, KWM_T)
         call AKPo2s (TSO, kop, -1, ' ')
         if      (COND_N(IFPl)) then
            write (IFPl, 101)
     $           _TRIM(T), _TRIM (TSO), kop, kom, kot, kam, kat
         else if (COND_S(IFPl)) then
            write (*,    101)
     $           _TRIM(T), _TRIM (TSO), kop, kom, kot, kam, kat
         endif
         if (kom.gt.0) then
            call AKPrpw (WW, kom, 'MO', MH, LH, kop, T, IFPl)
         endif
         if (kot.gt.0) then
            call AKPrpw (WW, kot, 'TO', MH, LH, kop, T, IFPl)
         endif
         if (kam.gt.0) then
            call AKPrpw (WW, kam, 'MA', MH, LH, kop, T, IFPl)
         endif
         if (kat.gt.0) then
            call AKPrpw (WW, kat, 'TA', MH, LH, kop, T, IFPl)
         endif
      enddo
      RETURN
      END
CCC_ & AKPrpw  ## Vector report (core)
      subroutine AKPrpw
     I    (W,
     I     KV, TAG, MH, LH, KOP, T, IFPl)
CCC_  * Declaration
      implicit none
      _INTENT(IN, integer)   MH, LH, KV
      _INTENT(IN, _REALSTD)  W (LH, KV)
      _INTENT(IN, character) T*(*), TAG*(*)
      _INTENT(IN, integer)   KOP
      _INTENT(IN, integer)   IFPl
      integer j
      character TSO*(8)
CCC_  * Body
 101  format ('AKPRPW:', A, ':', A, '/', A, 1x, I5, 1x,E16.9)
      call AKPo2s (TSO, KOP, -1, ' ')
      if      (COND_N(IFPl)) then
         do j = 1, MH
            write (IFPl, 101)
     $           _TRIM(T), _TRIM(TSO), _TRIM(TAG), j, W (j, KV)
         enddo
c$$$         call FLUSH (IFPl)
      else if (COND_S(IFPl)) then
         do j = 1, MH
            write (*,    101)
     $           _TRIM(T), _TRIM(TSO), _TRIM(TAG), j, W (j, KV)
         enddo
      endif
      RETURN
      END
CCC_ & AKPtbi  ## table generation operator id to string
      subroutine AKPtbi (Tbl)
      implicit none
      _INTENT(OUT,character) Tbl (*)*(*)
CCC_  * Gradient
      Tbl (KWO_GXab) = 'GXab'
      Tbl (KWO_GXba) = 'GXba'
      Tbl (KWO_GXcd) = 'GXcd'
      Tbl (KWO_GXdc) = 'GXdc'
      Tbl (KWO_GYac) = 'GYac'
      Tbl (KWO_GYca) = 'GYca'
      Tbl (KWO_GYbd) = 'GYbd'
      Tbl (KWO_GYdb) = 'GYdb'
CCC_  * Divergence
      Tbl (KWO_DXab) = 'DXab'
      Tbl (KWO_DXba) = 'DXba'
      Tbl (KWO_DXcd) = 'DXcd'
      Tbl (KWO_DXdc) = 'DXdc'
      Tbl (KWO_DYac) = 'DYac'
      Tbl (KWO_DYca) = 'DYca'
      Tbl (KWO_DYbd) = 'DYbd'
      Tbl (KWO_DYdb) = 'DYdb'
CCC_  * Linear interpolation
      Tbl (KWO_Lab) = 'Lab'
      Tbl (KWO_Lba) = 'Lba'
      Tbl (KWO_Lcd) = 'Lcd'
      Tbl (KWO_Ldc) = 'Ldc'
      Tbl (KWO_Lac) = 'Lac'
      Tbl (KWO_Lca) = 'Lca'
      Tbl (KWO_Lbd) = 'Lbd'
      Tbl (KWO_Ldb) = 'Ldb'
CCC_  * Exchange overlapped
      Tbl (KWO_EWo) = 'CEWo'
      Tbl (KWO_WEo) = 'CWEo'
      Tbl (KWO_SNo) = 'CSNo'
      Tbl (KWO_NSo) = 'CNSo'
      Tbl (KWO_EWi) = 'CEWi'
      Tbl (KWO_WEi) = 'CWEi'
      Tbl (KWO_SNi) = 'CSNi'
      Tbl (KWO_NSi) = 'CNSi'
CCC_  * Simple addition
      Tbl (KWO_SAab) = 'SAab'
      Tbl (KWO_SAba) = 'SAba'
      Tbl (KWO_SAcd) = 'SAcd'
      Tbl (KWO_SAdc) = 'SAdc'
      Tbl (KWO_SAac) = 'SAac'
      Tbl (KWO_SAca) = 'SAca'
      Tbl (KWO_SAbd) = 'SAbd'
      Tbl (KWO_SAdb) = 'SAdb'
CCC_  * Simple subtraction
      Tbl (KWO_SDab) = 'SDab'
      Tbl (KWO_SDba) = 'SDba'
      Tbl (KWO_SDcd) = 'SDcd'
      Tbl (KWO_SDdc) = 'SDdc'
      Tbl (KWO_SDac) = 'SDac'
      Tbl (KWO_SDca) = 'SDca'
      Tbl (KWO_SDbd) = 'SDbd'
      Tbl (KWO_SDdb) = 'SDdb'
CCC_  * Full clone
      Tbl (KWO_FCab) = 'FCab'
      Tbl (KWO_FCba) = 'FCba'
      Tbl (KWO_FCcd) = 'FCcd'
      Tbl (KWO_FCdc) = 'FCdc'
      Tbl (KWO_FCac) = 'FCac'
      Tbl (KWO_FCca) = 'FCca'
      Tbl (KWO_FCbd) = 'FCbd'
      Tbl (KWO_FCdb) = 'FCdb'
CCC_  * User def 0
      Tbl (KWO_U0ab) = 'U0ab'
      Tbl (KWO_U0ba) = 'U0ba'
      Tbl (KWO_U0cd) = 'U0cd'
      Tbl (KWO_U0dc) = 'U0dc'
      Tbl (KWO_U0ac) = 'U0ac'
      Tbl (KWO_U0ca) = 'U0ca'
      Tbl (KWO_U0bd) = 'U0bd'
      Tbl (KWO_U0db) = 'U0db'
CCC_  * User def 1
      Tbl (KWO_U1ab) = 'U1ab'
      Tbl (KWO_U1ba) = 'U1ba'
      Tbl (KWO_U1cd) = 'U1cd'
      Tbl (KWO_U1dc) = 'U1dc'
      Tbl (KWO_U1ac) = 'U1ac'
      Tbl (KWO_U1ca) = 'U1ca'
      Tbl (KWO_U1bd) = 'U1bd'
      Tbl (KWO_U1db) = 'U1db'
CCC_  * User def 2
      Tbl (KWO_U2ab) = 'U2ab'
      Tbl (KWO_U2ba) = 'U2ba'
      Tbl (KWO_U2cd) = 'U2cd'
      Tbl (KWO_U2dc) = 'U2dc'
      Tbl (KWO_U2ac) = 'U2ac'
      Tbl (KWO_U2ca) = 'U2ca'
      Tbl (KWO_U2bd) = 'U2bd'
      Tbl (KWO_U2db) = 'U2db'
CCC_  * Derivative (for coordinates transfomation)
      Tbl (KWO_XXa) = 'XXa'
      Tbl (KWO_XXb) = 'XXb'
      Tbl (KWO_XXc) = 'XXc'
      Tbl (KWO_XXd) = 'XXd'
      Tbl (KWO_YYa) = 'YYa'
      Tbl (KWO_YYb) = 'YYb'
      Tbl (KWO_YYc) = 'YYc'
      Tbl (KWO_YYd) = 'YYd'
      Tbl (KWO_XYa) = 'XYa'
      Tbl (KWO_XYb) = 'XYb'
      Tbl (KWO_XYc) = 'XYc'
      Tbl (KWO_XYd) = 'XYd'
      Tbl (KWO_YXa) = 'YXa'
      Tbl (KWO_YXb) = 'YXb'
      Tbl (KWO_YXc) = 'YXc'
      Tbl (KWO_YXd) = 'YXd'
CCC_  * Coordinates
      Tbl (KWO_Xa) = 'Xa'
      Tbl (KWO_Xb) = 'Xb'
      Tbl (KWO_Xc) = 'Xc'
      Tbl (KWO_Xd) = 'Xd'
      Tbl (KWO_Ya) = 'Ya'
      Tbl (KWO_Yb) = 'Yb'
      Tbl (KWO_Yc) = 'Yc'
      Tbl (KWO_Yd) = 'Yd'
CCC_  * Size
      Tbl (KWO_dXa) = 'dXa'
      Tbl (KWO_dXb) = 'dXb'
      Tbl (KWO_dXc) = 'dXc'
      Tbl (KWO_dXd) = 'dXd'
      Tbl (KWO_dYa) = 'dYa'
      Tbl (KWO_dYb) = 'dYb'
      Tbl (KWO_dYc) = 'dYc'
      Tbl (KWO_dYd) = 'dYd'
CCC_  * Odd field mask
      Tbl (KWO_ZXa) = 'ZXa'
      Tbl (KWO_ZXb) = 'ZXb'
      Tbl (KWO_ZXc) = 'ZXc'
      Tbl (KWO_ZXd) = 'ZXd'
      Tbl (KWO_ZYa) = 'ZYa'
      Tbl (KWO_ZYb) = 'ZYb'
      Tbl (KWO_ZYc) = 'ZYc'
      Tbl (KWO_ZYd) = 'ZYd'
CCC_  * Area
      Tbl (KWO_Aa) = 'Aa'
      Tbl (KWO_Ab) = 'Ab'
      Tbl (KWO_Ac) = 'Ac'
      Tbl (KWO_Ad) = 'Ad'
CCC_  * Wing mask
      Tbl (KWO_MWa) = 'MWa'
      Tbl (KWO_MWb) = 'MWb'
      Tbl (KWO_MWc) = 'MWc'
      Tbl (KWO_MWd) = 'MWd'
CCC_  - Exchange wings
      Tbl (KWO_HEW) = 'HEW'
      Tbl (KWO_HWE) = 'HWE'
      Tbl (KWO_HSN) = 'HSN'
      Tbl (KWO_HNS) = 'HNS'
CCC_  * Meta-info
      Tbl (KWO_MIO) = 'MIO'
      Tbl (KWO_MIA) = 'MIA'
      RETURN
      END
CCC_ & AKPo2s  ## operator id to string
      subroutine AKPo2s (CS, KOP, KSW, CSEP)
      implicit none
      _INTENT(OUT,character) CS*(*), CX*(*)
      _INTENT(IN, character) CSi*(*)
      _INTENT(IN, integer)   KOP, KSW
      _INTENT(OUT,integer)   KOPo
      _INTENT(IN, character) CSEP*(*)
      integer   jo
      character TM
      character TOPR (KWO_MAX)*(4)
      save      TOPR
      logical   OFIRST
      data      OFIRST /.true./
      save      OFIRST
      integer   lo
#if HAVE_F77_LEN_TRIM == 0
      integer len_trim
#endif
      if (OFIRST) then
         OFIRST = .false.
         call AKPtbi (TOPR)
      endif
      if      (KSW.eq.KWM_M) then
         TM = 'M'
      else if (KSW.eq.KWM_T) then
         TM = 'T'
      else if (KSW.eq.-1) then
         TM = ' '
      else
         TM = 'E'
      endif
 101  format (A, A, A1)
      if (KOP.gt.0 .and. KOP.le. KWO_MAX) then
         write (CS, 101) _TRIM(TOPR (KOP)), _TRIM(CSEP), TM
      else
         write (CS, 101) 'ERR', _TRIM(CSEP), TM
      endif
      RETURN
CCC_  & AKPo2x  ## operator id to coordinate suffix (source)
      entry AKPo2x (CX, KOP)
      if (OFIRST) then
         OFIRST = .false.
         call AKPtbi (TOPR)
      endif
      if (KOP.gt.0 .and. KOP.le. KWO1_MAX) then
         CX = TOPR (KOP)(2:2)
         if (INDEX ('abcd', CX (1:1)).le.0) then
            CX = TOPR (KOP)(3:3)
            if (INDEX ('abcd', CX (1:1)).le.0) then
               CX = 'a'
            endif
         endif
      else
         CX = '!'
      endif
      RETURN
CCC_  & AKPo2z  ## operator id to coordinate suffix (target)
      entry AKPo2z (CX, KOP)
      if (OFIRST) then
         OFIRST = .false.
         call AKPtbi (TOPR)
      endif
      if (KOP.gt.0 .and. KOP.le. KWO1_MAX) then
         lo = len_trim (TOPR (KOP))
         CX = TOPR (KOP) (lo:lo)
         if (INDEX ('abcd', CX (1:1)).le.0) then
            CX = 'a'
         endif
      else
         CX = '!'
      endif
      RETURN
CCC_  & AKPs2o  ## operator string to id
      entry AKPs2o (KOPo, CSi)
      if (OFIRST) then
         OFIRST = .false.
         call AKPtbi (TOPR)
      endif
      KOPo = -1
      do jo = 1, KWO_MAX
         if (CSi .eq. TOPR (jo)) then
            KOPo = jo
            goto 900
         endif
      enddo
 900  continue
      RETURN
      END
CCC_ & AKPdvw  ## Vector report by DV module
      subroutine AKPdvw
     O    (iErr,
     I     WW,   MH,  LH,  ipKW,
     I     icHA, ivG, IE,  iMA)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, _REALSTD)  WW (*)
      _INTENT(IN, integer)   MH, LH
      _INTENT(IN, integer)   ipKW (IPKW_FULL_DECL)
      _INTENT(IN, integer)   IE (*)
      _INTENT(IN, integer)   icHA (*), ivG
      _INTENT(IN, integer)   iMA  (*)
c
      integer   jo,  jot
CCC_  * Body
      iErr  = 0
c
      do jo = 1, KWO1_MAX
         jot = jo
         if (iErr.eq.0) then
            call AKPdvp
     $          (iErr,
     $           WW,   MH,  LH, ipKW, jot, 'MO', KWM_M, KWI_KWO,
     $           icHA, ivG, IE, iMA)
         endif
         if (iErr.eq.0) then
            call AKPdvp
     $          (iErr,
     $           WW,   MH,  LH, ipKW, jot, 'MA', KWM_M, KWI_KWA,
     $           icHA, ivG, IE, iMA)
         endif
         if (iErr.eq.0) then
            call AKPdvp
     $          (iErr,
     $           WW,   MH,  LH, ipKW, jot, 'TO', KWM_T, KWI_KWO,
     $           icHA, ivG, IE, iMA)
         endif
         if (iErr.eq.0) then
            call AKPdvp
     $          (iErr,
     $           WW,   MH,  LH, ipKW, jot, 'TA', KWM_T, KWI_KWA,
     $           icHA, ivG, IE, iMA)
         endif
      enddo
c$$$      call DAtrcU (IFPl, iErr, 'R', 'AKPDVW')
      RETURN
      END
CCC_ & AKPdvp  ## Vector report by DV module (inner)
      subroutine AKPdvp
     O    (iErr,
     I     W,    MH,  LH,  ipKW, KOP, TAG, KWM, KWI,
     I     icHA, ivG, IE,  iMA)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,integer)     iErr
      _INTENT(IN, integer)     MH, LH
      _INTENT(IN, integer)     ipKW (IPKW_FULL_DECL)
      _INTENT(IN, integer)     IE  (*)
      _INTENT(IN, integer)     iMA (*)
      _INTENT(IN, _REALSTD)    W (LH, *)
      _INTENT(IN, character)   TAG*(*)
      _INTENT(IN, integer)     KOP, KWI, KWM
      _INTENT(IN, integer)     icHA (*)
      _INTENT(IN, integer)     ivG
      integer   kv
      integer   jc
      _REALSTD  T
      character VNM*(32)
      character TSO*(32), TSX*(32)
CCC_  * Body
      iErr = 0
      T    = 0.0d0
c
      if (iErr.eq.0) then
         kv = ipKW (KWI, KOP, KWM)
         if (kv.gt.0) then
            jc = 1
            call AKPo2s (TSO,  KOP, -1, ' ')
            VNM = TSO
            call AKPo2x (TSX,  KOP)
            jc = INDEX ('abcd', TSX (1:1))
            if (jc.le.0) jc = 1
            call USJnta (VNM, '.', TAG)
            call AFBwnc
     $           (iErr, W (1, kv), ivG, VNM, icHA (jc), T, ' ', ' ', IE)
         endif
      endif
      RETURN
      END
CCC_* [AKV] Variables diagnosis
CCC_ & AKVchl  ## variable check wrapper (with variable kind)
      subroutine AKVchl
     O    (iErr,
     I     V,    CPOS, PFX, IVK,
     I     ipKW, XX,   MH,  LH,  MO, FMT, IFPl)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   MH, LH, MO, IVK
      _INTENT(IN, _REALSTD)  V  (LH, MO, IVK)
      _INTENT(IN, _REALSTD)  XX (*)
      _INTENT(IN, character) CPOS*(*)
      _INTENT(IN, character) PFX*(*), FMT*(*)
      _INTENT(IN, integer)   IFPl
      _INTENT(IN, integer)   ipKW (*)
CCC_  * Body
      call AKVchk
     O    (iErr,
     I     V (1, 1, IVK),  CPOS, PFX,
     I     ipKW, XX, MH, LH, MO, FMT, IFPl)
      RETURN
      END
CCC_ & AKVchk  ## variable check wrapper
      subroutine AKVchk
     O    (iErr,
     I     V,    CPOS, PFX,
     I     ipKW, XX,   MH,  LH, MO, FMT, IFPl)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   MH, LH, MO
      _INTENT(IN, _REALSTD)  V    (*)
      _INTENT(IN, _REALSTD)  XX   (*)
      _INTENT(IN, character) CPOS*(*)
      _INTENT(IN, character) PFX*(*), FMT*(*)
      _INTENT(IN, integer)   IFPl
      _INTENT(IN, integer)   ipKW (IPKW_FULL_DECL)
c
      integer   kx, ky, kwm
      character TPFX*(32), TFMT*(32)
CCC_  * Body
      iErr = 0
 101  format ('@:', A, 1x, A1)
      write (TPFX, 101) _TRIM(PFX), _TRIM(CPOS)
      if (FMT.eq.' ') then
         TFMT = '(E24.16)'
      else
         TFMT = FMT
      endif
      if      (CPOS.eq.'a') then
         kx = ipKW (KWI_KWO, KWO_Xa, KWM_M)
         ky = ipKW (KWI_KWO, KWO_Ya, KWM_M)
      else if (CPOS.eq.'b') then
         kx = ipKW (KWI_KWO, KWO_Xb, KWM_M)
         ky = ipKW (KWI_KWO, KWO_Yb, KWM_M)
      else if (CPOS.eq.'c') then
         kx = ipKW (KWI_KWO, KWO_Xc, KWM_M)
         ky = ipKW (KWI_KWO, KWO_Yc, KWM_M)
      else if (CPOS.eq.'d') then
         kx = ipKW (KWI_KWO, KWO_Xd, KWM_M)
         ky = ipKW (KWI_KWO, KWO_Yd, KWM_M)
      else
         kx = ipKW (KWI_KWO, KWO_Xa, KWM_M)
         ky = ipKW (KWI_KWO, KWO_Ya, KWM_M)
      endif
      kwm = ipKW (KWI_KWO, KWO_MWa, KWM_M)
c
      call AKVchc
     O    (iErr,
     I     V,   TPFX,
     I     XX,  kx,   ky,  kwm, MH,   LH,  MO, TFMT, IFPl)
c
      RETURN
      END
CCC_ & AKVchc  ## variable check core
      subroutine AKVchc
     O    (iErr,
     I     V,   PFX,
     I     XY,  KX,   KY,  KWM,  MH,  LH,  MO, FMT, IFPl)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   MH, LH, MO
      _INTENT(IN, _REALSTD)  V  (LH, MO)
      _INTENT(IN, integer)   KX, KY, KWM
      _INTENT(IN, _REALSTD)  XY (LH, *)
      _INTENT(IN, character) PFX*(*), FMT*(*)
      _INTENT(IN, integer)   IFPl
      integer   j, k
      _REALSTD  x, y, wm
      character TPOS*(64), TVAL*(64)
CCC_  * Body
      iErr = 0
 102  format (F9.1, 1x, F9.1, 1x, I1)
 103  format (A, 1x, A, 1x, A)
      if (MO.eq.1) then
         k = 1
         if      (COND_N(IFPl)) then
            do j = 1, MH
               x  = XY (j, KX)
               y  = XY (j, KY)
               wm = XY (j, KWM)
               write (TPOS, 102) x, y, INT(WM)
               write (TVAL, FMT) V (j, k)
               write (IFPl, 103) _TRIM(PFX), _TRIM(TPOS), _TRIM(TVAL)
            enddo
         else if (COND_S(IFPl)) then
            do j = 1, MH
               x  = XY (j, KX)
               y  = XY (j, KY)
               wm = XY (j, KWM)
               write (TPOS, 102) x, y, INT(WM)
               write (TVAL, FMT) V (j, k)
               write (*,    103) _TRIM(PFX), _TRIM(TPOS), _TRIM(TVAL)
            enddo
         endif
      endif
      RETURN
      END
CCC_* [AKU] Coordinate utils
CCC_* [AKE] Cartesian coordinate properties
CCC_ & AKEcfg  ## wrapper: Cartesian/equal configuration suite
      subroutine AKEcfg
     O    (iErr,
     O     WW,
     M     ipKW,
     I     LKW,
     I     MH,    LH,     icW,  IE,
     I     T,     IFPl)
CCC_  - Description
CC    Must call ACHrng before this routine, to set kCX and other variables
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)   LKW
c
      _INTENT(OUT,  integer)   iErr
      _INTENT(OUT,  _REALSTD)  WW   (*)
      _INTENT(INOUT,integer)   ipKW (*)
c
      _INTENT(IN,   integer)   MH, LH
      _INTENT(IN,   integer)   icW  (*)
      _INTENT(IN,   integer)   IE   (*)
      _INTENT(IN,   character) T*(*)
      _INTENT(IN,   integer)   IFPl
c
      integer LVDBG
c
      integer  icWH (16)
      integer  icXa, icXb, icXX
      integer  icYa, icYb, icYY
      integer  iuXa, iuXb
      integer  iuYa, iuYb
CCC_  - Body
      iErr = 0
c
      if (iErr.eq.0) call AKPst2 (iErr, LH, IE, ipKW, T, IFPl)
      if (iErr.eq.0) call AKPsto (iErr, LH, IE, ipKW, T, IFPl)
c
      if (iErr.eq.0) call ACWrb2 (iErr, icXa, icYa, icW (1))
      if (iErr.eq.0) call ACWrb2 (iErr, icXb, icYY, icW (2))
      if (icYY.ne.icYa) iErr = -1
      if (iErr.eq.0) call ACWrb2 (iErr, icXX, icYb, icW (3))
      if (icXX.ne.icXa) iErr = -1
      if (iErr.eq.0) call ACWrb2 (iErr, icXX, icYY, icW (4))
      if (icXX.ne.icXb) iErr = -1
      if (icYY.ne.icYb) iErr = -1
c
      if (iErr.eq.0) call AGUqgi (iErr, iuXa, icXa, IFPl)
      if (iErr.eq.0) call AGUqgi (iErr, iuXb, icXb, IFPl)
      if (iErr.eq.0) call AGUqgi (iErr, iuYa, icYa, IFPl)
      if (iErr.eq.0) call AGUqgi (iErr, iuYb, icYb, IFPl)
c
 102  format ('AKECFG: TARGET COOR ', 4I4)
 101  format ('AKECFG: BASE COOR ', 5I5)
 103  format ('AKECFG: GEOMETRY COOR ', 5I5)
      if      (COND_N(IFPl)) then
         write (IFPl, 102) icW (1), icW (2), icW (3), icW (4)
         write (IFPl, 101) icXa, icXb, icYa, icYb, iErr
         write (IFPl, 103) iuXa, iuXb, iuYa, iuYb, iErr
      else if (COND_S(IFPl)) then
         write (*,    102) icW (1), icW (2), icW (3), icW (4)
         write (*,    101) icXa, icXb, icYa, icYb, iErr
         write (*,    103) iuXa, iuXb, iuYa, iuYb, iErr
      endif
c
      icWH (1) = icW (1)
      icWH (2) = icW (2)
      icWH (3) = icW (3)
      icWH (4) = icW (4)
      icWH (5) = iuXa
      icWH (6) = iuXb
      icWH (7) = iuYa
      icWH (8) = iuYb
c
      if (iErr.eq.0) then
         call AKEcco
     O       (iErr, WW,  ipKW,
     I        MH,   LH,  LKW,  icWH, IE, IFPl)
      endif
      if (iErr.eq.0) then
         call AKEcar
     O       (iErr, WW,  ipKW,
     I        MH,   LH,  LKW,  icWH, IE, IFPl)
      endif
      if (iErr.eq.0) then
         call AKEcwm
     O       (iErr, WW,  ipKW,
     I        MH,   LH,  LKW,  icWH, IE, IFPl)
      endif
      if (iErr.eq.0) then
         call AKEcdf
     O       (iErr, WW,  ipKW,
     I        MH,   LH,  LKW,  icWH, IE, IFPl)
      endif
      if (iErr.eq.0) then
         call AKEcli
     O       (iErr, WW,  ipKW,
     I        MH,   LH,  LKW,  icWH, IE, IFPl)
      endif
      if (iErr.eq.0) then
         call AKEcso
     O       (iErr, WW,  ipKW,
     I        MH,   LH,  LKW,  icWH, IE, IFPl)
      endif
      if (iErr.eq.0) then
         call AKEcud
     O       (iErr, WW,  ipKW,
     I        MH,   LH,  LKW,  icWH, IE, IFPl)
      endif
      if (iErr.eq.0) then
         call AKEcov
     O       (iErr, WW,  ipKW,
     I        MH,   LH,  LKW,  IE, IFPl)
      endif
      if (iErr.eq.0) then
         call AKEwxs
     O       (iErr, ipKW,
     I        MH,   LH,   IE, IFPl)
      endif
c
      if (iErr.eq.0) call AKPadj (iErr, ipKW, IFPl)
CCC_   . report
      LVDBG = EA_LVDBG(IE)
      if (LVDBG.ge.0)
     $     call AKPrpp (ipKW, T, LKW, IFPl)
      if (LVDBG.gt.1)
     $     call AKPrpv (WW, MH, LH, ipKW, T, IFPl)
c
      call DAtrcU (IFPl, iErr, 'R', 'AKECFG')
c
      RETURN
      END
CCC_ & AKEcco  ## Cartesian properties copy (coordinates)
      subroutine AKEcco
     O    (iErr,
     O     WW,
     M     ipKW,
     I     MH,    LH,   LKW,
     I     icWH,  IE,
     I     IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   MH, LH, LKW
      _INTENT(OUT,  _REALSTD)  WW (LH, LKW)
      _INTENT(INOUT,integer)   ipKW (*)
      _INTENT(IN,   integer)   icWH (*)
      _INTENT(IN,   integer)   IE   (*)
      _INTENT(IN,   integer)   IFPl
      integer  KI
      integer  icXa, icXb, icYa, icYb
CCC_  - Body
      iErr = 0
CCC_   . duplication
      if (iErr.eq.0)
     $     call AKPdup (iErr, ipKW, KWO_Xc,   KWO_Xa,   KWM_BOTH, IFPl)
      if (iErr.eq.0)
     $     call AKPdup (iErr, ipKW, KWO_Xd,   KWO_Xb,   KWM_BOTH, IFPl)
      if (iErr.eq.0)
     $     call AKPdup (iErr, ipKW, KWO_Yb,   KWO_Ya,   KWM_BOTH, IFPl)
      if (iErr.eq.0)
     $     call AKPdup (iErr, ipKW, KWO_Yd,   KWO_Yc,   KWM_BOTH, IFPl)
c
      if (iErr.eq.0)
     $     call AKPdup (iErr, ipKW, KWO_ZXc,  KWO_ZXa,  KWM_BOTH, IFPl)
      if (iErr.eq.0)
     $     call AKPdup (iErr, ipKW, KWO_ZXd,  KWO_ZXb,  KWM_BOTH, IFPl)
      if (iErr.eq.0)
     $     call AKPdup (iErr, ipKW, KWO_ZYb,  KWO_ZYa,  KWM_BOTH, IFPl)
      if (iErr.eq.0)
     $     call AKPdup (iErr, ipKW, KWO_ZYd,  KWO_ZYc,  KWM_BOTH, IFPl)
CCC_   . coordinate configuration
      icXa = icWH (5)
      icXb = icWH (6)
      icYa = icWH (7)
      icYb = icWH (8)
CCC_   . set
      call AKPmxw (KI, ipKW)
      if (iErr.eq.0) then
         call AKPqcc
     O       (iErr,   WW,    KI,  ipKW,
     I        MH,     LH,    LKW,
     I        KWO_Xa, KWM_M, KWI_KWO,
     I        icXa,   'CO',  0,      _CPSW_I, IE, IFPl)
      endif
      if (iErr.eq.0) then
         call AKPqcc
     O       (iErr,   WW,    KI,  ipKW,
     I        MH,     LH,    LKW,
     I        KWO_Ya, KWM_M, KWI_KWO,
     I        icYa,   'CO',  0,      _CPSW_J, IE, IFPl)
      endif
      if (iErr.eq.0) then
         call AKPqcc
     O       (iErr,   WW,    KI,  ipKW,
     I        MH,     LH,    LKW,
     I        KWO_Xb, KWM_M, KWI_KWO,
     I        icXb,   'CO',  0,      _CPSW_I, IE, IFPl)
      endif
      if (iErr.eq.0) then
         call AKPqcc
     O       (iErr,   WW,    KI,  ipKW,
     I        MH,     LH,    LKW,
     I        KWO_Yc, KWM_M, KWI_KWO,
     I        icYb,   'CO',  0,      _CPSW_J, IE, IFPl)
      endif
      if (iErr.eq.0) then
         call AKPqcc
     O       (iErr,    WW,    KI,  ipKW,
     I        MH,      LH,    LKW,
     I        KWO_dXb, KWM_M, KWI_KWO,
     I        icXb,    'DC',  0,      _CPSW_I, IE, IFPl)
      endif
      if (iErr.eq.0) then
         call AKPqcc
     O       (iErr,    WW,    KI,  ipKW,
     I        MH,      LH,    LKW,
     I        KWO_dYc, KWM_M, KWI_KWO,
     I        icYb,    'DC',  0,      _CPSW_J, IE, IFPl)
      endif
c
      if (iErr.eq.0) then
         call AKPqcc
     O       (iErr,   WW,    KI,  ipKW,
     I        MH,     LH,    LKW,
     I        KWO_ZXa, KWM_M, KWI_KWO,
     I        icXa,   'ZO',  0,      _CPSW_I, IE, IFPl)
      endif
      if (iErr.eq.0) then
         call AKPqcc
     O       (iErr,   WW,    KI,  ipKW,
     I        MH,     LH,    LKW,
     I        KWO_ZYa, KWM_M, KWI_KWO,
     I        icYa,   'ZO',  0,      _CPSW_J, IE, IFPl)
      endif
      if (iErr.eq.0) then
         call AKPqcc
     O       (iErr,   WW,    KI,  ipKW,
     I        MH,     LH,    LKW,
     I        KWO_ZXb, KWM_M, KWI_KWO,
     I        icXb,   'ZO',  0,      _CPSW_I, IE, IFPl)
      endif
      if (iErr.eq.0) then
         call AKPqcc
     O       (iErr,   WW,    KI,  ipKW,
     I        MH,     LH,    LKW,
     I        KWO_ZYc, KWM_M, KWI_KWO,
     I        icYb,   'ZO',  0,      _CPSW_J, IE, IFPl)
      endif
c
      call DAtrcU (IFPl, iErr, 'R', 'AKECCO')
      RETURN
      END
CCC_ & AKEcar  ## Cartesian properties copy (area)
      subroutine AKEcar
     O    (iErr,
     O     WW,
     M     ipKW,
     I     MH,    LH,   LKW,
     I     icWH,  IE,
     I     IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   MH, LH, LKW
      _INTENT(OUT,  _REALSTD)  WW (LH, LKW)
      _INTENT(INOUT,integer)   ipKW (*)
      _INTENT(IN,   integer)   icWH (*)
      _INTENT(IN,   integer)   IE   (*)
      _INTENT(IN,   integer)   IFPl
      integer  KI
      integer  icXa, icXb, icYa, icYb
CCC_  - Body
      iErr = 0
CCC_   . coordinate configuration
      icXa = icWH (5)
      icXb = icWH (6)
      icYa = icWH (7)
      icYb = icWH (8)
CCC_   . set
      call AKPmxw (KI, ipKW)
      if (iErr.eq.0) then
         call AKPqca
     O       (iErr,   WW,    KI,  ipKW,
     I        MH,     LH,    LKW,
     I        KWO_Aa,
     I        icXa,   icYa,  IE, IFPl)
      endif
      call DAtrcU (IFPl, iErr, 'R', 'AKECAR')
      RETURN
      END
CCC_ & AKEcwm  ## Cartesian properties copy (wing mask)
      subroutine AKEcwm
     O    (iErr,
     O     WW,
     M     ipKW,
     I     MH,    LH,   LKW,
     I     icWH,  IE,
     I     IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   MH, LH, LKW
      _INTENT(OUT,  _REALSTD)  WW (LH, LKW)
      _INTENT(INOUT,integer)   ipKW (*)
      _INTENT(IN,   integer)   icWH (*)
      _INTENT(IN,   integer)   IE   (*)
      _INTENT(IN,   integer)   IFPl
      integer  KI
      integer  icXa, icXb, icYa, icYb
CCC_  - Body
      iErr = 0
CCC_   . coordinate configuration
      icXa = icWH (5)
      icXb = icWH (6)
      icYa = icWH (7)
      icYb = icWH (8)
CCC_   . set
      call AKPmxw (KI, ipKW)
      if (iErr.eq.0) then
         call AKPqcw
     O       (iErr,   WW,    KI,  ipKW,
     I        MH,     LH,    LKW,
     I        KWO_MWa,
     I        icXa,   icYa,  IE, IFPl)
      endif
      call DAtrcU (IFPl, iErr, 'R', 'AKECWM')
      RETURN
      END
CCC_ & AKEcdf  ## Cartesian properties copy (finite difference)
      subroutine AKEcdf
     O    (iErr,
     O     WW,
     M     ipKW,
     I     MH,    LH,   LKW,
     I     icWH,  IE,
     I     IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   MH, LH, LKW
      _INTENT(OUT,  _REALSTD)  WW (LH, LKW)
      _INTENT(INOUT,integer)   ipKW (*)
      _INTENT(IN,   integer)   icWH (*)
      _INTENT(IN,   integer)   IE   (*)
      _INTENT(IN,   integer)   IFPl
      integer  KIO
      integer  icXa, icXb, icYa, icYb
CCC_  - Body
      iErr = 0
#if 0
CCC_   . duplication (divergence equal gradient)
      if (iErr.eq.0)
     $     call AKPdup (iErr, ipKW, KWO_DXab, KWO_GXab, KWM_BOTH, IFPl)
      if (iErr.eq.0)
     $     call AKPdup (iErr, ipKW, KWO_DXba, KWO_GXba, KWM_BOTH, IFPl)
      if (iErr.eq.0)
     $     call AKPdup (iErr, ipKW, KWO_DXcd, KWO_GXcd, KWM_BOTH, IFPl)
      if (iErr.eq.0)
     $     call AKPdup (iErr, ipKW, KWO_DXdc, KWO_GXdc, KWM_BOTH, IFPl)
c
      if (iErr.eq.0)
     $     call AKPdup (iErr, ipKW, KWO_DYac, KWO_GYac, KWM_BOTH, IFPl)
      if (iErr.eq.0)
     $     call AKPdup (iErr, ipKW, KWO_DYca, KWO_GYca, KWM_BOTH, IFPl)
      if (iErr.eq.0)
     $     call AKPdup (iErr, ipKW, KWO_DYbd, KWO_GYbd, KWM_BOTH, IFPl)
      if (iErr.eq.0)
     $     call AKPdup (iErr, ipKW, KWO_DYdb, KWO_GYdb, KWM_BOTH, IFPl)
#endif
CCC_   . coordinate configuration
      icXa = icWH (5)
      icXb = icWH (6)
      icYa = icWH (7)
      icYb = icWH (8)
C
      call AKPmxw (KIO, ipKW)
      if (iErr.eq.0) then
         call AKPqcd
     O       (iErr,  WW,  KIO,  ipKW,
     I        MH,    LH,  LKW,  KWO_GXab,
     I        icXa,  'G', -1,   _CPSW_I, IE,     IFPl)
      endif
      if (iErr.eq.0) then
         call AKPqcd
     O       (iErr,  WW,  KIO,  ipKW,
     I        MH,    LH,  LKW,  KWO_GYac,
     I        icYa,  'G', -1,   _CPSW_J, IE,     IFPl)
      endif
      if (iErr.eq.0) then
         call AKPqcd
     O       (iErr,  WW,  KIO,  ipKW,
     I        MH,    LH,  LKW,  KWO_GXba,
     I        icXb,  'G', +1,   _CPSW_I, IE,     IFPl)
      endif
      if (iErr.eq.0) then
         call AKPqcd
     O       (iErr,  WW,  KIO,  ipKW,
     I        MH,    LH,  LKW,  KWO_GYca,
     I        icYb,  'G', +1,   _CPSW_J, IE,     IFPl)
      endif
c
      if (iErr.eq.0) then
         call AKPqcd
     O       (iErr,  WW,  KIO,  ipKW,
     I        MH,    LH,  LKW,  KWO_GXdc,
     I        icXb,  'G', +1,   _CPSW_I, IE,     IFPl)
      endif
      if (iErr.eq.0) then
         call AKPqcd
     O       (iErr,  WW,  KIO,  ipKW,
     I        MH,    LH,  LKW,  KWO_GYdb,
     I        icYb,  'G', +1,   _CPSW_J, IE,     IFPl)
      endif
CC    TODO DUP GXcd, GYbd
      if (iErr.eq.0) then
         call AKPqcd
     O       (iErr,  WW,  KIO,  ipKW,
     I        MH,    LH,  LKW,  KWO_GXcd,
     I        icXa,  'G', -1,   _CPSW_I, IE,     IFPl)
      endif
      if (iErr.eq.0) then
         call AKPqcd
     O       (iErr,  WW,  KIO,  ipKW,
     I        MH,    LH,  LKW,  KWO_GYbd,
     I        icYa,  'G', -1,   _CPSW_J, IE,     IFPl)
      endif
c
      if (iErr.eq.0) then
         call AKPqcd
     O       (iErr,  WW,  KIO,  ipKW,
     I        MH,    LH,  LKW,  KWO_DXab,
     I        icXa,  'D', -1,   _CPSW_I, IE,     IFPl)
      endif
      if (iErr.eq.0) then
         call AKPqcd
     O       (iErr,  WW,  KIO,  ipKW,
     I        MH,    LH,  LKW,  KWO_DYac,
     I        icYa,  'D', -1,   _CPSW_J, IE,     IFPl)
      endif
      if (iErr.eq.0) then
         call AKPqcd
     O       (iErr,  WW,  KIO,  ipKW,
     I        MH,    LH,  LKW,  KWO_DXba,
     I        icXb,  'D', +1,   _CPSW_I, IE,     IFPl)
      endif
      if (iErr.eq.0) then
         call AKPqcd
     O       (iErr,  WW,  KIO,  ipKW,
     I        MH,    LH,  LKW,  KWO_DYca,
     I        icYb,  'D', +1,   _CPSW_J, IE,     IFPl)
      endif
c
      if (iErr.eq.0) then
         call AKPqcd
     O       (iErr,  WW,  KIO,  ipKW,
     I        MH,    LH,  LKW,  KWO_DXdc,
     I        icXb,  'D', +1,   _CPSW_I, IE,     IFPl)
      endif
      if (iErr.eq.0) then
         call AKPqcd
     O       (iErr,  WW,  KIO,  ipKW,
     I        MH,    LH,  LKW,  KWO_DYdb,
     I        icYb,  'D', +1,   _CPSW_J, IE,     IFPl)
      endif
CC    TODO DUP GXcd, GYbd
      if (iErr.eq.0) then
         call AKPqcd
     O       (iErr,  WW,  KIO,  ipKW,
     I        MH,    LH,  LKW,  KWO_DXcd,
     I        icXa,  'D', -1,   _CPSW_I, IE,     IFPl)
      endif
      if (iErr.eq.0) then
         call AKPqcd
     O       (iErr,  WW,  KIO,  ipKW,
     I        MH,    LH,  LKW,  KWO_DYbd,
     I        icYa,  'D', -1,   _CPSW_J, IE,     IFPl)
      endif

      call DAtrcU (IFPl, iErr, 'R', 'AKECDF')
      RETURN
      END
CCC_ & AKEcli  ## Cartesian properties copy (linear interpolation)
      subroutine AKEcli
     O    (iErr,
     O     WW,
     M     ipKW,
     I     MH,    LH,   LKW,
     I     icWH,  IE,
     I     IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   MH, LH, LKW
      _INTENT(OUT,  _REALSTD)  WW (LH, LKW)
      _INTENT(INOUT,integer)   ipKW (*)
      _INTENT(IN,   integer)   IE   (*)
      _INTENT(IN,   integer)   icWH (*)
      _INTENT(IN,   integer)   IFPl
      integer  KIO
      integer  icXa, icXb, icYa, icYb
CCC_  - Body
      iErr = 0
CCC_   . duplication
      if (iErr.eq.0)
     $     call AKPdup (iErr, ipKW, KWO_Lcd, KWO_Lab, KWM_BOTH, IFPl)
      if (iErr.eq.0)
     $     call AKPdup (iErr, ipKW, KWO_Lbd, KWO_Lac, KWM_BOTH, IFPl)
CCC_   . coordinate configuration
CC    TODO  Hd/xy dup
      icXa = icWH (5)
      icXb = icWH (6)
      icYa = icWH (7)
      icYb = icWH (8)
C
      call AKPmxw (KIO, ipKW)
      if (iErr.eq.0) then
         call AKPqcd
     O       (iErr,  WW,  KIO,  ipKW,
     I        MH,    LH,  LKW,  KWO_Lab,
     I        icXa,  'L', -1,   _CPSW_I, IE,     IFPl)
      endif
      if (iErr.eq.0) then
         call AKPqcd
     O       (iErr,  WW,  KIO,  ipKW,
     I        MH,    LH,  LKW,  KWO_Lac,
     I        icYa,  'L', -1,   _CPSW_J, IE,     IFPl)
      endif
      if (iErr.eq.0) then
         call AKPqcd
     O       (iErr,  WW,  KIO,  ipKW,
     I        MH,    LH,  LKW,  KWO_Lba,
     I        icXb,  'L', +1,   _CPSW_I, IE,     IFPl)
      endif
      if (iErr.eq.0) then
         call AKPqcd
     O       (iErr,  WW,  KIO,  ipKW,
     I        MH,    LH,  LKW,  KWO_Lca,
     I        icYb,  'L', +1,   _CPSW_J, IE,     IFPl)
      endif
C
      if (iErr.eq.0) then
         call AKPqcd
     O       (iErr,  WW,  KIO,  ipKW,
     I        MH,    LH,  LKW,  KWO_Ldc,
     I        icXb,  'L', +1,   _CPSW_I, IE,     IFPl)
      endif
      if (iErr.eq.0) then
         call AKPqcd
     O       (iErr,  WW,  KIO,  ipKW,
     I        MH,    LH,  LKW,  KWO_Ldb,
     I        icYb,  'L', +1,   _CPSW_J, IE,     IFPl)
      endif
      call DAtrcU (IFPl, iErr, 'R', 'AKECLI')
      RETURN
      END
CCC_ & AKEcso  ## Cartesian properties copy (simple operations)
      subroutine AKEcso
     O    (iErr,
     O     WW,
     M     ipKW,
     I     MH,    LH,   LKW,
     I     icWH,  IE,
     I     IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   MH, LH, LKW
      _INTENT(OUT,  _REALSTD)  WW (LH, LKW)
      _INTENT(INOUT,integer)   ipKW (*)
      _INTENT(IN,   integer)   IE   (*)
      _INTENT(IN,   integer)   icWH (*)
      _INTENT(IN,   integer)   IFPl
CCC_  - Body
      iErr = 0
      call AKEcss
     O    (iErr,  WW, ipKW,
     I     KWO_SAab, KWO_SAba, KWO_SAac, KWO_SAca,
     I     KWO_SAdb, KWO_SAbd, KWO_SAdc, KWO_SAcd,
     I     1.0d0,    1.0d0,
     I     MH,    LH,   LKW,   icWH, IE, IFPl)
      call AKEcss
     O    (iErr,  WW, ipKW,
     I     KWO_SDab, KWO_SDba, KWO_SDac, KWO_SDca,
     I     KWO_SDdb, KWO_SDbd, KWO_SDdc, KWO_SDcd,
     I     1.0d0,    -1.0d0,
     I     MH,    LH,   LKW,   icWH, IE, IFPl)
      call AKEcss
     O    (iErr,  WW, ipKW,
     I     KWO_FCab, KWO_FCba, KWO_FCac, KWO_FCca,
     I     KWO_FCdb, KWO_FCbd, KWO_FCdc, KWO_FCcd,
     I     0.0d0,    1.0d0,
     I     MH,    LH,   LKW,   icWH, IE, IFPl)
      call DAtrcU (IFPl, iErr, 'R', 'AKECSO')
      RETURN
      END
CCC_ & AKEcud  ## Cartesian properties copy (user defined)
      subroutine AKEcud
     O    (iErr,
     O     WW,
     M     ipKW,
     I     MH,    LH,   LKW,
     I     icWH,  IE,
     I     IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   MH, LH, LKW
      _INTENT(OUT,  _REALSTD)  WW (LH, LKW)
      _INTENT(INOUT,integer)   ipKW (*)
      _INTENT(IN,   integer)   IE   (*)
      _INTENT(IN,   integer)   icWH (*)
      _INTENT(IN,   integer)   IFPl
CCC_  - Body
      iErr = 0
      call AKEcss
     O    (iErr,  WW, ipKW,
     I     KWO_U0ab, KWO_U0ba, KWO_U0ac, KWO_U0ca,
     I     KWO_U0db, KWO_U0bd, KWO_U0dc, KWO_U0cd,
     I     0.0d0,    0.0d0,
     I     MH,    LH,   LKW,   icWH, IE, IFPl)
      call AKEcss
     O    (iErr,  WW, ipKW,
     I     KWO_U1ab, KWO_U1ba, KWO_U1ac, KWO_U1ca,
     I     KWO_U1db, KWO_U1bd, KWO_U1dc, KWO_U1cd,
     I     0.0d0,    0.0d0,
     I     MH,    LH,   LKW,   icWH, IE, IFPl)
      call AKEcss
     O    (iErr,  WW, ipKW,
     I     KWO_U2ab, KWO_U2ba, KWO_U2ac, KWO_U2ca,
     I     KWO_U2db, KWO_U2bd, KWO_U2dc, KWO_U2cd,
     I     0.0d0,    0.0d0,
     I     MH,    LH,   LKW,   icWH, IE, IFPl)
      call DAtrcU (IFPl, iErr, 'R', 'AKECUD')
      RETURN
      END
CCC_ & AKEcss  ## Cartesian properties copy sub (simple operations)
      subroutine AKEcss
     O    (iErr,
     O     WW,
     M     ipKW,
     I     Kab,   Kba,  Kac,   Kca,  Kdb, Kbd, Kdc, Kcd,
     I     FO,    FA,
     I     MH,    LH,   LKW,
     I     icWH,  IE,
     I     IFPl)
CCC_  - Description
CC     Just use linear-interpolation subroutine.
CC     Need adjustment after this procedure.
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   MH, LH, LKW
      _INTENT(IN,   _REALSTD)  FO, FA
      _INTENT(OUT,  _REALSTD)  WW (LH, LKW)
      _INTENT(INOUT,integer)   ipKW (*)
      _INTENT(IN,   integer)   Kab, Kba, Kac, Kca
      _INTENT(IN,   integer)   Kdb, Kbd, Kdc, Kcd
      _INTENT(IN,   integer)   IE   (*)
      _INTENT(IN,   integer)   icWH (*)
      _INTENT(IN,   integer)   IFPl
      integer  KIO
      integer  icXa, icXb, icYa, icYb
CCC_  - Body
      iErr = 0
CCC_   . coordinate configuration
      icXa = icWH (5)
      icXb = icWH (6)
      icYa = icWH (7)
      icYb = icWH (8)
C
      call AKPmxw (KIO, ipKW)
c
      if (iErr.eq.0) then
         call AKPqco
     O       (iErr,  WW,  KIO,  ipKW,
     I        MH,    LH,  LKW,  Kab, FO,  FA,
     I        icXa,  'L', -1,   _CPSW_I, IE,  IFPl)
      endif
      if (iErr.eq.0) then
         call AKPqco
     O       (iErr,  WW,  KIO,  ipKW,
     I        MH,    LH,  LKW,  Kac, FO,  FA,
     I        icYa,  'L', -1,   _CPSW_J, IE,  IFPl)
      endif
c
      if (iErr.eq.0) then
         call AKPqco
     O       (iErr,  WW,  KIO,  ipKW,
     I        MH,    LH,  LKW,  Kba, FO,  FA,
     I        icXb,  'L', +1,   _CPSW_I, IE,  IFPl)
      endif
      if (iErr.eq.0) then
         call AKPqco
     O       (iErr,  WW,  KIO,  ipKW,
     I        MH,    LH,  LKW,  Kbd, FO,  FA,
     I        icYa,  'L', -1,   _CPSW_J, IE,  IFPl)
      endif
c
      if (iErr.eq.0) then
         call AKPqco
     O       (iErr,  WW,  KIO,  ipKW,
     I        MH,    LH,  LKW,  Kca, FO,  FA,
     I        icYb,  'L', +1,   _CPSW_J, IE,  IFPl)
      endif
      if (iErr.eq.0) then
         call AKPqco
     O       (iErr,  WW,  KIO,  ipKW,
     I        MH,    LH,  LKW,  Kcd, FO,  FA,
     I        icXa,  'L', -1,   _CPSW_I, IE,  IFPl)
      endif
C
      if (iErr.eq.0) then
         call AKPqco
     O       (iErr,  WW,  KIO,  ipKW,
     I        MH,    LH,  LKW,  Kdc, FO,  FA,
     I        icXb,  'L', +1,   _CPSW_I, IE,  IFPl)
      endif
      if (iErr.eq.0) then
         call AKPqco
     O       (iErr,  WW,  KIO,  ipKW,
     I        MH,    LH,  LKW,  Kdb, FO,  FA,
     I        icYb,  'L', +1,   _CPSW_J, IE,  IFPl)
      endif
      call DAtrcU (IFPl, iErr, 'R', 'AKECSS')
      RETURN
      END
CCC_ & AKEcov  ## Properties copy (common/overlap)
      subroutine AKEcov
     O    (iErr,
     O     WW,
     M     ipKW,
     I     MH,    LH,   LKW,
     I     IE,    IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   MH, LH, LKW
      _INTENT(OUT,  _REALSTD)  WW (LH, LKW)
      _INTENT(INOUT,integer)   ipKW (*)
      _INTENT(IN,   integer)   IE   (*)
      _INTENT(IN,   integer)   IFPl
      integer  KIO
CCC_  - Body
      iErr = 0
      call AKPmxw (KIO, ipKW)
      if (iErr.eq.0) then
         call AKPcpo
     O       (iErr,     WW,   KIO,  ipKW,
     I        KWO_EWo,  'Wo',
     I        MH,       LH,   LKW,  IE,  IFPl)
      endif
      if (iErr.eq.0) then
         call AKPcpo
     O       (iErr,     WW,   KIO,  ipKW,
     I        KWO_EWi,  'Wi',
     I        MH,       LH,   LKW,  IE,  IFPl)
      endif
      if (iErr.eq.0) then
         call AKPcpo
     O       (iErr,     WW,   KIO,  ipKW,
     I        KWO_WEo,  'Eo',
     I        MH,       LH,   LKW,  IE,  IFPl)
      endif
      if (iErr.eq.0) then
         call AKPcpo
     O       (iErr,     WW,   KIO,  ipKW,
     I        KWO_WEi,  'Ei',
     I        MH,       LH,   LKW,  IE,  IFPl)
      endif
      if (iErr.eq.0) then
         call AKPcpo
     O       (iErr,     WW,   KIO,  ipKW,
     I        KWO_NSo,  'So',
     I        MH,       LH,   LKW,  IE,  IFPl)
      endif
      if (iErr.eq.0) then
         call AKPcpo
     O       (iErr,     WW,   KIO,  ipKW,
     I        KWO_NSi,  'Si',
     I        MH,       LH,   LKW,  IE,  IFPl)
      endif
      if (iErr.eq.0) then
         call AKPcpo
     O       (iErr,     WW,   KIO,  ipKW,
     I        KWO_SNo,  'No',
     I        MH,       LH,   LKW,  IE,  IFPl)
      endif
      if (iErr.eq.0) then
         call AKPcpo
     O       (iErr,     WW,   KIO,  ipKW,
     I        KWO_SNi,  'Ni',
     I        MH,       LH,   LKW,  IE,  IFPl)
      endif
      call DAtrcU (IFPl, iErr, 'R', 'AKUCOV')
      RETURN
      END
CCC_ & AKEwxs  ## Properties copy (wing shift)
      subroutine AKEwxs
     O    (iErr,
     M     ipKW,
     I     MH,    LH,
     I     IE,    IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   MH, LH
      _INTENT(INOUT,integer)   ipKW (IPKW_FULL_DECL)
      _INTENT(IN,   integer)   IE   (*)
      _INTENT(IN,   integer)   IFPl
      integer    LTBL
      parameter (LTBL = 1024)
      integer    kDTA (LTBL, 3)
      integer    KSTNCS (4), KSTNCD (4)
      integer    IRStbl (4), IRDtbl (4)
      integer    ji
      integer    KOP
#define _shiftE 1
#define _shiftW 2
#define _shiftN 3
#define _shiftS 4
CCC_  - Body
      iErr = 0
      if (iErr.eq.0) then
        call AESwsh
     O       (iErr,
     W        kDTA,
     O        kStncS, kStncD, IRStbl, IRDtbl,
     I        LTBL,   LH,     IE,      IFPl)
      endif
      if (iErr.eq.0) then
         KOP = KWO_HWE
         ji  = _shiftE
         ipKW (KWC_TPS, KOP, KWM_M) = kStncS(ji)
         ipKW (KWC_TPD, KOP, KWM_M) = kStncD(ji)
         ipKW (KWC_IRS, KOP, KWM_M) = IRStbl(ji)
         ipKW (KWC_IRD, KOP, KWM_M) = IRDtbl(ji)
c
         KOP = KWO_HEW
         ji  = _shiftW
         ipKW (KWC_TPS, KOP, KWM_M) = kStncS(ji)
         ipKW (KWC_TPD, KOP, KWM_M) = kStncD(ji)
         ipKW (KWC_IRS, KOP, KWM_M) = IRStbl(ji)
         ipKW (KWC_IRD, KOP, KWM_M) = IRDtbl(ji)
c
         KOP = KWO_HSN
         ji  = _shiftN
         ipKW (KWC_TPS, KOP, KWM_M) = kStncS(ji)
         ipKW (KWC_TPD, KOP, KWM_M) = kStncD(ji)
         ipKW (KWC_IRS, KOP, KWM_M) = IRStbl(ji)
         ipKW (KWC_IRD, KOP, KWM_M) = IRDtbl(ji)
c
         KOP = KWO_HNS
         ji  = _shiftS
         ipKW (KWC_TPS, KOP, KWM_M) = kStncS(ji)
         ipKW (KWC_TPD, KOP, KWM_M) = kStncD(ji)
         ipKW (KWC_IRS, KOP, KWM_M) = IRStbl(ji)
         ipKW (KWC_IRD, KOP, KWM_M) = IRDtbl(ji)
      endif
c
      call DAtrcU (IFPl, iErr, 'R', 'AKEWXS')
      RETURN
      END
CCC_& AKWOPR  ## Arpeggio/Kiwi announcement
      subroutine AKWOPR (STRA, STRB, IOP)
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
CCC_* [TEST]
CCC_ + begin test
#if TEST_AKWOPR
CCC_ @ AKTEST  ## Arpeggio/Kiwi test
      program AKTEST
CCC_  - Test suites
CC::   SOURCES aedlra.F:TEST_AEDLRA_CFG=1 agmtry.F afintf.F
CCC_  - Declaration
#include "ofnstd.h"
#include "odevid.h"  /* MPI table */
      implicit none
      integer iErr
      integer ipA (LOG_CHANNEL_MAX)
      integer iMA (MAX_MPI_ATTR)
#define AKW_CLS 'V'
CCC_  - Body
      call DDcapo
     O    (iErr,
     I     2, ' ', 'O', _FNAME, -1)
      if (iErr.eq.0) then
         call DLCmng (ipA, 't')
         call DVHrgC (iErr, AKW_CLS, ' ', ' ', ipA)
      endif
      if (iErr.eq.0) then
         call DMAtma (iMA)
         call AKTESTmain (iErr, ipA, iMA)
         call ACCrep (FPL(ipA), 2    )
      endif
      call DevFin (iErr)
      STOP
      END
CCC_ & AKTESTmain  ## Arpeggio/Kiwi test/main
      subroutine AKTESTmain (iErr, ipA, iMA)
CCC_  - Declaration
#include "ofnstd.h"
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(IN, integer) ipA (*)
      _INTENT(IN, integer) iMA (*)
c
      integer    LIE
      parameter (LIE = 32769)
      integer    IE (LIE)
      integer    ipKW (IPKW_FULL_DECL)
      integer    MH, LH
c
      integer    LKW
      parameter (LKW = 256)
      integer    LWA
      parameter (LWA = 32769)
      _REALSTD   WW (LWA * LKW)
      integer    LHPref
      parameter (LHPref = 8192)
      _REALSTD   HA (LHPref)
      character  CROOT * (32)
      integer    icW (16)
      integer    ivG (4)
c
      integer    ITEST
      integer    ipL
CCC_  - Body
      iErr = 0
      CROOT = 'ID'
      ITEST = 0
      ipL = FPL(ipA)
c
      call UDTbni (ITEST, 'BEGIN', ' ', ipL)
c
      if (iErr.eq.0) then
         call AKTESTcfg
     O       (iErr,
     O        HA,      WW,   MH,   LH,  IE,  ipKW, icW, ivG,
     I        LHPref,  LWA,  LKW,  LIE,
     I        CROOT,   ipA,  iMA,  ITEST)
      endif
c
      call UDTbni (ITEST, 'EXE', ' ', ipL)
c
      if (iErr.eq.0) then
         call AKTESTexe
     O       (iErr,
     I        HA,    WW,   MH,   LH,   IE,  ipKW,
     I        CROOT, icW,  ivG,  ipA,  iMA, ITEST)
      endif
c
      call AFBrpG (iErr, ipL)
c
      call UDTbni (ITEST, 'END', ' ', ipL)
c
      RETURN
      END
CCC_ & AKTESTcfg  ## Arpeggio/Kiwi test/configuration
      subroutine AKTESTcfg
     O    (iErr,
     O     HA,     WW,  MH,   LH,  IE,  ipKW, icW, ivG,
     I     LHPref, LWA, LKW,  LIE,
     I     CROOT,  ipA, iMA,  ITEST)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,_REALSTD)  HA (*), WW (*)
      _INTENT(OUT,integer)   MH,  LH
      _INTENT(OUT,integer)   icW (*)
      _INTENT(OUT,integer)   ivG (*)
      _INTENT(OUT,integer)   IE (*), ipKW (*)
      _INTENT(IN, integer)   LWA, LKW, LIE, LHPref
      _INTENT(IN, integer)   ipA (*)
      _INTENT(IN, integer)   iMA (*)
      _INTENT(IN, character) CROOT*(*)
      _INTENT(INOUT,integer) ITEST
c
      integer    IR,  NR
      _REALSTD   vCX, vCY, XW, YW
      integer    icXa, icXb, icYa, icYb
      integer    icHa, icHb, icHc, icHd
c
      _REALSTD   SS
      data       SS / 10.0d0 /
c
      integer    LWV
      parameter (LWV = 32769)
      _REALSTD   WV (LWV)
      _REALSTD   WXN, WYN
c
      namelist /NITEST/  SS, XW, YW
c
      integer   MO
      integer   ipL, ipC, ipP, ipV
      integer   ipFI (AFI_FLAG_MAX)
c
      integer MX,  MY, NX, NY, NXU, NYU, LXO, LYO
      integer NHP, NHG
      integer MXU, MYU
      integer jg
c
      character CSW*(16)
CCC_  - Body
      iErr = 0
c
      ipL = FPL(ipA)
      ipC = FPC(ipA)
      ipP = FPP(ipA)
      ipV = FPV(ipA)
c
      call AFUifp (ipFI, ipP, ipC, ipL, ipV)
c
      call UDTbni (ITEST, 'CFG/IN', ' ', ipL)
c
      call DMAget (IR,    iMA, 'IR')
      call DMAget (NR,    iMA, 'NR')
CCC_   . element dealer
      call UDTbni (ITEST, 'CFG/AE', ' ', ipL)
c
      call AETESTcfg (iErr, IE, LIE, IR, NR, CROOT, ipP, ipC, ipL)
      call AEAgen (iErr, IE, LIE, CROOT, ipL)
c
      call AFEdvw
     O    (iErr,
     I     IE,   'C', AKW_CLS, CROOT, ' ', ipFI, iMA)
CCC_   . geometry
      call UDTbni (ITEST, 'CFG/NML', ' ', ipL)
c
      vCX = 0.0d0
      vCY = 0.0d0
      XW  = 500.0d0
      YW  = 200.0d0
      WXN = -1.0d0
      WYN = -1.0d0
c
      call UUrwnd (iErr, ipP)
      read  (ipP, NITEST, IOSTAT = iErr)
      write (ipC, NITEST, IOSTAT = iErr)
c
      NX  = EA_NXG(IE)
      NY  = EA_NYG(IE)
      NXU = EA_NXU(IE)
      NYU = EA_NYU(IE)
      MXU = EA_MXU(IE)
      MYU = EA_MYU(IE)
      MX  = EA_MX(IE)
      MY  = EA_MY(IE)
      LXO = EA_LXO(IE)
      LYO = EA_LYO(IE)
      MH  = EA_MP(IE)
      NHP = EA_NP(IE)
      NHG = EA_NG(IE)
CCC_   . h 1d
      call UDTbni (ITEST, 'CFG/ACB', ' ', ipL)
c
      if (iErr.eq.0)
     $     call ACBnrX (iErr, icXa,icXb, ' ', ' ', NX,MXU,MX,LXO, ipL)
      if (iErr.eq.0)
     $     call ACBnrX (iErr, icYa,icYb, ' ', ' ', NY,MYU,MY,LYO, ipL)
c
      call UDTbni (ITEST, 'CFG/AGH', ' ', ipL)
      if (iErr.eq.0) then
         call AGHnmr
     O       (iErr,
     W        WV,    LWV,
     I        vCX,   XW,   WXN,
     I        CROOT, 'X',  icXa, icXb,
     I        ipP,   ipC,  ipL)
         iErr = Min (0, iErr)
      endif
      if (iErr.eq.0) then
         call AGHnmr
     O       (iErr,
     W        WV,    LWV,
     I        vCY,   YW,   WYN,
     I        CROOT, 'Y',  icYa, icYb,
     I        ipP,   ipC,  ipL)
         iErr = Min (0, iErr)
      endif
c
      call AFCwrb (iErr, icXa, 'C', AKW_CLS, ' ', ipFI, iMA)
      call AFCwrb (iErr, icXb, 'C', AKW_CLS, ' ', ipFI, iMA)
      call AFCwrb (iErr, icYa, 'C', AKW_CLS, ' ', ipFI, iMA)
      call AFCwrb (iErr, icYb, 'C', AKW_CLS, ' ', ipFI, iMA)
c$$$      call AFCwnb (iErr, icXa, 1, 'C', AKW_CLS, ' ', ipFI, iMA)
c$$$      call AFCwnb (iErr, icXb, 1, 'C', AKW_CLS, ' ', ipFI, iMA)
c$$$      call AFCwnb (iErr, icYa, 1, 'C', AKW_CLS, ' ', ipFI, iMA)
c$$$      call AFCwnb (iErr, icYb, 1, 'C', AKW_CLS, ' ', ipFI, iMA)
CCC_   . h 2d
      call UDTbni (ITEST, 'CFG/ACB2D', ' ', ipL)
c
      if (iErr.eq.0) call ACUsds (iErr, LH, MH, LHPref, CROOT, ipL)
      if (iErr.eq.0) then
         call ACBnrH (iErr, icHa, icXa, icYa, NHG,  NHP, MH, LH, ipL)
      endif
      if (iErr.eq.0) then
         call ACBnrH (iErr, icHb, icXb, icYa, NHG,  NHP, MH, LH, ipL)
      endif
      if (iErr.eq.0) then
         call ACBnrH (iErr, icHc, icXa, icYb, NHG,  NHP, MH, LH, ipL)
      endif
      if (iErr.eq.0) then
         call ACBnrH (iErr, icHd, icXb, icYb, NHG,  NHP, MH, LH, ipL)
      endif
c
      icW (1) = icHa
      icW (2) = icHb
      icW (3) = icHc
      icW (4) = icHd
CCC_   . check overflow
      call UDTbni (ITEST, 'CFG/CHP', ' ', ipL)
c
      if (iErr.eq.0) call AEAchp (iErr, IE, LHPref, 'LHPref', ipL)
      if (iErr.eq.0) call AEAchp (iErr, IE, LWA,    'LWA',    ipL)
      if (iErr.eq.0) call AEAchp (iErr, IE, LWV,    'LWV',    ipL)
CCC_   . kiwi declaration
      call UDTbni (ITEST, 'CFG/DEC', ' ', ipL)
c
      if (iErr.eq.0) call AKPini (ipKW)
      if (iErr.eq.0) call AKPdca (iErr, ipKW, ipL)
CCC_   . kiwi weights
      call UDTbni (ITEST, 'CFG/AKE', ' ', ipL)
c
      if (iErr.eq.0) then
         call AKEcfg
     O       (iErr,
     O        WW,
     M        ipKW,
     I        LKW,
     I        MH,    LH,     icW, IE,
     I        CROOT, ipL)
      endif
CCC_   . file interfaces
      CSW = 'C'
      if (iErr.eq.0) then
         call AFBrgd
     O       (iErr,
     O        ivG (1),
     I        'AKTa', MH, LH, 1,1, 0, icW (1),
     I        CSW,    AKW_CLS,  CROOT, ipFI, iMA)
      endif
      if (iErr.eq.0) then
         call AFBrgd
     O       (iErr,
     O        ivG (2),
     I        'AKTb', MH, LH, 1,1, 0, icW (2),
     I        CSW,    AKW_CLS,  CROOT, ipFI, iMA)
      endif
      if (iErr.eq.0) then
         call AFBrgd
     O       (iErr,
     O        ivG (3),
     I        'AKTc', MH, LH, 1,1, 0, icW (3),
     I        CSW,    AKW_CLS,  CROOT, ipFI, iMA)
      endif
      if (iErr.eq.0) then
         call AFBrgd
     O       (iErr,
     O        ivG (4),
     I        'AKTd', MH, LH, 1,1, 0, icW (4),
     I        CSW,    AKW_CLS,  CROOT, ipFI, iMA)
      endif
      if (iErr.eq.0) then
         do jg = 1, 4
            call AFBgmf
     O          (iErr,
     I           ivG (jg),  ' ', ' ', IE, ipFI)
         enddo
      endif
CCC_   . input field
      call UDTbni (ITEST, 'CFG/SET', ' ', ipL)
      if (iErr.eq.0) then
         MO = 1
         call AKTESTset
     O       (Ha,
     I        WW, XW, YW, SS, MH, LH, LKW, IE, ipKW, IR)
         call AKTESTcheck
     O       (iErr,
     I        Ha,   'a', 'a',  'S',
     I        icW,  ivG,  ipKW, IE, WW, MH, LH, ipL)
         call AKCxsh
     M       (Ha,
     I        MH,   LH,  1,
     I        ipKW, iMA)
         call AKTESTcheck
     O       (iErr,
     I        Ha,   'a', 'a',  'T',
     I        icW,  ivG,  ipKW, IE, WW, MH, LH, ipL)
      endif
c
      call UDTbni (ITEST, 'CFG/DONE', ' ', ipL)
      RETURN
      END
CCC_ & AKTESTset  ## set test H
      subroutine AKTESTset
     O    (Ha,
     I     WW, XW, YW, SS, MH, LH, LKW, IE, ipKW, IR)
      implicit none
c
      _INTENT(IN, integer)   MH, LH, LKW
      _INTENT(OUT,_REALSTD)  Ha (LH)
      _INTENT(IN, _REALSTD)  XW,  YW,  SS
      _INTENT(IN, _REALSTD)  WW (LH, *)
      _INTENT(IN, integer)   IE(*)
      _INTENT(IN, integer)   ipKW (IPKW_FULL_DECL)
      _INTENT(IN, integer)   IR
c
      _REALSTD PI
      _REALSTD X0, Y0, X,  Y,  ZW, Z
      _REALSTD XC, YC, XL, YL, XD, YD
      integer  j
      integer  kx, ky, kwm
      integer  NXG, NYG, JXP, JYP, jhp
      integer  jxl, jyl
c
      kx  = ipKW (KWI_KWO, KWO_Xa, KWM_M)
      ky  = ipKW (KWI_KWO, KWO_Ya, KWM_M)
      kwm = ipKW (KWI_KWO, KWO_MWa, KWM_M)
c
      X0 = 0.0d0
      Y0 = 0.0d0
c
      NXG = EA_argNXG(IE)
      NYG = EA_argNYG(IE)
c
      PI  = ATAN2 (1.0d0, 1.0d0) * 4.0d0
      ZW = min (XW, YW) / 2.0d0
      XC = X0 + XW / 2.0d0
      YC = Y0 + YW / 2.0d0
      XL = X0 + XW
      YL = Y0 + YW
      do j = 1, MH
         x = WW (j, kx)
         y = WW (j, ky)
         jhp = j - 1
         jxp = EA_listPX(IE, jhp)
         jyp = EA_listPY(IE, jhp)
         jxl = EA_listLX(IE, jhp)
         jyl = EA_listLY(IE, jhp)
#if 0
         Ha (j) = + DBLE(jyl-1)*1.d2 + DBLE(jxl-1)
         if (WW(j,kwm).eq.0.0d0) then
            Ha (j) = - DBLE(IR+1)*1.d4 - Ha(j)
         endif
#else
c$$$         if (x.ge.XL .or. y.ge.YL) then
c$$$            Ha (j) = 0.0d0
c$$$         else if (x.le.X0 .or. y.le.Y0) then
c$$$            Ha (j) = 0.0d0
c$$$         else
            xd = x - XC
            yd = y - YC
            z = SIN ((x / ZW + y / ZW) * PI)
            Ha (j) = SS * z
c$$$         endif
c$$$         Ha (j) = x / ZW + (y / ZW) * 1000.0d0
         Ha (j) = Ha (j) * WW (j, kwm)
     $        - SS * (2.0d0 + DBLE(IR)) * (1.0d0 - WW (j, kwm))
         if (jxp.gt.NXG.or.jyp.gt.NYG) then
c$$$            Ha(j) = -SS * 100.0d0
            Ha(j) = 0.0d0
         endif
c$$$         write (*, *) j, jhp, jxp, jyp, nxg, nyg, Ha(j)
#endif
      enddo
      RETURN
      END
CCC_ & AKTESTexe  ## Arpeggio/Kiwi test/execution
      subroutine AKTESTexe
     O    (iErr,
     I     HA,    WW,  MH,  LH,  IE,  ipKW,
     I     CROOT, icW, ivG, ipA, iMA, ITEST)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, _REALSTD)  HA (*), WW (*)
      _INTENT(IN, integer)   MH,  LH
      _INTENT(IN, integer)   IE (*), ipKW (*)
      _INTENT(IN, integer)   ipA (*)
      _INTENT(IN, integer)   icW (*)
      _INTENT(IN, integer)   ivG (*)
      _INTENT(IN, integer)   iMA (*)
      _INTENT(IN, character) CROOT*(*)
      _INTENT(INOUT,integer) ITEST
      integer    LHE
      parameter (LHE = 8192)
      _REALSTD HB (LHE), HC (LHE), HDb (LHE), HDc (LHE)
      _REALSTD Z  (LHE)
      _REALSTD CV (LHE)
c
      integer    LTBL
      parameter (LTBL = 8)
      integer    kDTA (LTBL, 3)
      integer    LCG
      parameter (LCG = KWCG_DECL(6))
      integer    ipCG (LCG)
      _REALSTD   CG (LHE * 6)
c
      integer  ipL, ipV
      integer  j, jo
      character SX*16
CCC_  - Body
      iErr = 0
      ipL = FPL(ipA)
      ipV = FPV(ipA)
c
      call UDTbni (ITEST, 'EXE/IN', ' ', ipL)
CCC_   . first create S[abcd]
      call UDTbni (ITEST, 'EXE/INPUT', ' ', ipL)
      if (iErr.eq.0) then
         call AKTESTotc
     O       (iErr, HB,      CV,
     I        Ha,   KWO_Lab, KWM_M, 'Ia',
     I        WW,   MH,      LH,  ipKW, IE, icW, ivG, iMA, ipL)
      endif
      if (iErr.eq.0) then
         call AKTESTotc
     O       (iErr, HC,      CV,
     I        Ha,   KWO_Lac, KWM_M, 'Ia',
     I        WW,   MH,      LH,  ipKW, IE, icW, ivG, iMA, ipL)
      endif
      if (iErr.eq.0) then
         call AKTESTotc
     O       (iErr, HDb,     CV,
     I        Hb,   KWO_Lbd, KWM_M, 'Ib',
     I        WW,   MH,      LH,  ipKW, IE, icW, ivG, iMA, ipL)
      endif
      if (iErr.eq.0) then
         call AKTESTotc
     O       (iErr, HDc,     CV,
     I        Hc,   KWO_Lcd, KWM_M, 'Ic',
     I        WW,   MH,      LH,  ipKW, IE, icW, ivG, iMA, ipL)
      endif
CCC_   . operation check (input a)
      call UDTbni (ITEST, 'EXE/OTCa', ' ', ipL)
      do j = 1, KWO2_MAX
         jo = j
         call AKPo2x (SX, jo)
         if (SX.eq.'a') then
            call AKTESTotc
     O          (iErr, Z,  CV,
     I           Ha,   jo, KWM_M, 'Za',
     I           WW,   MH, LH,  ipKW, IE, icW, ivG, iMA, ipL)
         endif
      enddo
CCC_   . operation check (input b)
      call UDTbni (ITEST, 'EXE/OTCb', ' ', ipL)
      do j = 1, KWO2_MAX
         jo = j
         call AKPo2x (SX, jo)
         if (SX.eq.'b') then
            call AKTESTotc
     O          (iErr, Z,  CV,
     I           Hb,   jo, KWM_M, 'Zb',
     I           WW,   MH, LH,  ipKW, IE, icW, ivG, iMA, ipL)
         endif
      enddo
CCC_   . operation check (input c)
      call UDTbni (ITEST, 'EXE/OTCc', ' ', ipL)
      do j = 1, KWO2_MAX
         jo = j
         call AKPo2x (SX, jo)
         if (SX.eq.'c') then
            call AKTESTotc
     O          (iErr, Z,  CV,
     I           Hc,   jo, KWM_M, 'Zc',
     I           WW,   MH, LH,  ipKW, IE, icW, ivG, iMA, ipL)
         endif
      enddo
CCC_   . operation check (input d)
      call UDTbni (ITEST, 'EXE/OTCd', ' ', ipL)
      do j = 1, KWO2_MAX
         jo = j
         call AKPo2x (SX, jo)
         if (SX.eq.'d') then
            call AKTESTotc
     O          (iErr, Z,  CV,
     I           HDb,  jo, KWM_M, 'Zd',
     I           WW,   MH, LH,  ipKW, IE, icW, ivG, iMA, ipL)
         endif
      enddo
CCC_   . Clone caching
      call UDTbni (ITEST, 'EXE/CC', ' ', ipL)
c
      call AKCgrs (iErr, ipCG, LCG)
      call AKCgad (iErr, ipCG, KWO_Lab,  KWM_M, LCG)
      call AKCgad (iErr, ipCG, KWO_Lac,  KWM_M, LCG)
      call AKCgad (iErr, ipCG, KWO_DXab, KWM_M, LCG)
      call AKCgad (iErr, ipCG, KWO_DYac, KWM_M, LCG)
      call AKCgad (iErr, ipCG, KWO_FCab, KWM_M, LCG)
      call AKCgad (iErr, ipCG, KWO_FCac, KWM_M, LCG)
      call AKCgsb
     O    (iErr, ipCG,  KDTA,
     I     LCG,  LTBL,  LH,   ipKW, IE,   ipL)
c
      call AKCguz
     O    (CG,
     I     Ha,   MH,   LH,
     I     iMA,  ipCG)
      do j = 1, 6
         jo = j
         call AKTESTcc
     O       (iErr, Z,
     I        Ha,   CG, ipCG, jo,
     I        WW,   MH, LH, ipKW, IE, icW, ivG, iMA, ipL)
      enddo
CCC_   . final report
      call UDTbni (ITEST, 'EXE/DONE', ' ', ipL)
c
      RETURN
      END
CCC_ & AKTESTotc
      subroutine AKTESTotc
     O    (iErr, Z,     CV,
     I     X,    KOP,   KSW,  CPFX,
     I     WW,   MH,    LH,   ipKW, IE, icW, ivG, iMA, IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,_REALSTD)  Z (*), CV (*)
      _INTENT(IN, _REALSTD)  X (*), WW (*)
      _INTENT(IN, integer)   KOP, KSW
      _INTENT(IN, character) CPFX*(*)
      _INTENT(IN, integer)   MH,  LH
      _INTENT(IN, integer)   ipKW (*), iMA (*)
      _INTENT(IN, integer)   IE   (*)
      _INTENT(IN, integer)   IFPl
      _INTENT(IN, integer)   icW  (*)
      _INTENT(IN, integer)   ivG  (*)
c
      character TV*32
      character SO*32, SX*16, SZ*16
c
      integer   j
CCC_  - Body
      iErr = 0
c
      call AKPo2s (SO, KOP, KSW, ' ')
      call AKPo2x (SX, KOP)
      call AKPo2z (SZ, KOP)
c
 301  format ('TEST/otc: ', A, 1x, A)
 302  format ('TEST/otc: SKIP')
      if      (COND_N(IFPl)) then
         write (IFPl, 301) _TRIM(SO), _TRIM(SX)
      else if (COND_S(IFPl)) then
         write (*,    301) _TRIM(SO), _TRIM(SX)
      endif
      if (SO(1:1).eq.'C' .or. SO(1:1).eq.'U') then
         if      (COND_N(IFPl)) then
            write (IFPl, 302)
         else if (COND_S(IFPl)) then
            write (*,    302)
         endif
      else
         call AKBinz
     O       (Z,
     I        MH,   LH,
     I        ipKW, KOP, KSW)
CCC_   . before operation
 101     format ('n', A, A)
         write (TV, 101) _TRIM(CPFX), _TRIM(SO)
         call AKTESTcheck
     O       (iErr,
     I        Z,    SX,   SZ,   TV,
     I        icW,  ivG,  ipKW, IE, WW, MH, LH, IFPl)
CCC_   . after operation
         call AKBwaz
     O       (Z,    CV,
     I        X,    WW,
     I        MH,   LH,
     I        ipKW, iMA, KOP, KSW)
 102     format ('d', A, A)
         write (TV, 102) _TRIM(CPFX), _TRIM(SO)
         if (CPFX (1:1).eq.'I') then
            call AKTESTcheck
     O          (iErr,
     I           Z,    SZ,   SZ,   TV,
     I           icW,  ivG,  ipKW, IE, WW, MH, LH, IFPl)
         endif
         call AKTESTcheck
     O       (iErr,
     I        Z,    SX,   SZ,   TV,
     I        icW,  ivG,  ipKW, IE, WW, MH, LH, IFPl)
CCC_   . clear one-time clone for test
         do j = 1, LH
            CV (j) = -999.9d9
         enddo
      endif
      RETURN
      END
CCC_ & AKTESTcc
      subroutine AKTESTcc
     O    (iErr, Z,
     I     X,    CG,  ipCG, KCO,
     I     WW,   MH,  LH,   ipKW, IE, icW, ivG, iMA, IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,_REALSTD)  Z  (*)
      _INTENT(IN, _REALSTD)  CG (*)
      _INTENT(IN, _REALSTD)  X  (*), WW (*)
      _INTENT(IN, integer)   KCO
      _INTENT(IN, integer)   MH,  LH
      _INTENT(IN, integer)   ipKW (*), iMA (*)
      _INTENT(IN, integer)   IE   (*)
      _INTENT(IN, integer)   IFPl
      _INTENT(IN, integer)   ipCG (*)
      _INTENT(IN, integer)   icW  (*)
      _INTENT(IN, integer)   ivG  (*)
c
      character TV*32
      character SO*32, SX*16, SZ*16
      integer   KOP,   KSW,   KCG
CCC_  - Body
      iErr = 0
      call AKCgqo (iErr, KOP, KSW, KCG, ipCG, KCO)
c
      call AKGwaz
     O    (Z,
     I     CG,   X,   WW,
     I     MH,   LH,
     I     ipKW, KCO, ipCG)
c
      call AKPo2s (SO, KOP, KSW, ' ')
      call AKPo2x (SX, KOP)
      call AKPo2z (SZ, KOP)
c
 301  format ('TEST/cc: ', A, 1x, A)
 102  format ('c', A, A)
      write (TV, 102) _TRIM(SO)
      call AKTESTcheck
     O    (iErr,
     I     Z,    SX,   SZ,   TV,
     I     icW,  ivG,  ipKW, IE, WW, MH, LH, IFPl)
CCC_   . clear one-time clone for test
      RETURN
      END
CCC_ & AKTESTcheck
      subroutine AKTESTcheck
     O    (iErr,
     I     V,    CPOSs, CPOSd, VNM,
     I     icW,  ivG,   ipKW,  IE, XX, MH, LH, IFPl)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   MH, LH
      _INTENT(IN, _REALSTD)  V    (*)
      _INTENT(IN, _REALSTD)  XX   (*)
      _INTENT(IN, character) CPOSs*(*), CPOSd*(*)
      _INTENT(IN, character) VNM *(*)
      _INTENT(IN, integer)   icW  (*)
      _INTENT(IN, integer)   IE   (*)
      _INTENT(IN, integer)   ivG  (*)
      _INTENT(IN, integer)   IFPl
      _INTENT(IN, integer)   ipKW (IPKW_FULL_DECL)
      integer   MO
      character FMT*(16)
      integer   jps, jpd
      _REALSTD  T
CCC_  - Body
      iErr = 0
      MO   = 1
      FMT  = ' '
      T    = 0.0d0
c
      call AKVchk
     O     (iErr, V, CPOSs, VNM, ipKW, XX, MH, LH, MO, FMT, IFPl)
c
      jps = INDEX ('abcd', CPOSs (1:1))
      jpd = INDEX ('abcd', CPOSd (1:1))
      if (jps.le.0) jps = 1
      if (jps.le.0) jpd = 1
      call AFBwnc
     $     (iErr, V, ivG (jps), VNM, icW (jpd), T, ' ', ' ', IE)
c
      RETURN
      END
CCC_ + end test
#endif /* TEST_AKWOPR */
CCC_* Obsolete
CCC_ + begin
#if 0
CCC_ + end
#endif /* 0 */
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
