C movement/mbscol.F --- IcIES/Movement/Basal sliding collection
C Maintainer:  SAITO Fuyuki
C Created: May 24 2013
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2016/04/16 22:50:45 fuyuki mbscol.F>'
#define _FNAME 'movement/mbscol.F'
#define _REV   'Snoopy0.9'
CCC_! MANIFESTO
C
C Copyright (C) 2013--2020
C           Japan Agency for Marine-Earth Science and Technology,
C           Ayako ABE-OUCHI
C
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
CCC_* Description
CCC_* Common macros
#include "ofdlct.h"   /* fortran dialect */
#include "ologfm.h"   /* log common format */
#include "oarpkw.h"   /* operation id in arpeggio/kiwi */
#include "movement.h" /* movement definitions */
CCC_ + sally compatiblity
#ifndef   OPT_SALLY_WEERTMAN_RATIO
#  define OPT_SALLY_WEERTMAN_RATIO 1  /* use zero */
#endif
CCC_& MBSmng  ## Movement/Basal sliding manager
      subroutine MBSmng
     O    (iErr,
     O     VMID,
     I     VMI,   VMC,  VMHB,
     I     IMM,   PMM,  MH,   LH)
CCC_ + Declaration
      implicit none
      _INTENT(OUT,integer)  iErr
c
      _INTENT(IN, integer)  MH, LH
      _INTENT(OUT,_REALSTD) VMID (LH, *)
c
      _INTENT(IN, _REALSTD) VMI  (LH, *)
      _INTENT(IN, _REALSTD) VMC  (LH, *)
      _INTENT(IN, _REALSTD) VMHB (LH, *)
c
      _INTENT(IN, _REALSTD) PMM (*)
      _INTENT(IN, integer)  IMM (*)
CCC_ + Body
      iErr = 0
CCC_  - set basal drag for sliding (just copy)
      call UV0cpa (VMID, MH, LH, VMID_vBSXb, VMID_BSXb)
      call UV0cpa (VMID, MH, LH, VMID_vBSYc, VMID_BSYc)
CCC_  * vb computation
      if (IMM (IMD_VB) .eq. SW_VB_NONE) then
         call UV0sta (VMID, MH, LH, VMID_UBb, 0.0d0)
         call UV0sta (VMID, MH, LH, VMID_VBc, 0.0d0)
      else if (IMM (IMD_VB) .eq. SW_VB_SALLY_WA) then
         call MBSswa
     O       (iErr,
     O        VMID,   VMID_UBb,
     I        VMI,    VMI_SLDb,  VMI_Hb, VMI_Bb,
     I        VMC,    VMC_DSXb,  VMC_DSYb,
     I        VMHB,   VMHB_CVBb, VMHB_EVBb, VMHB_DVBb, VMHB_SLVb,
     I        PMM,
     I        MH,  LH)
         call MBSswa
     O       (iErr,
     O        VMID,   VMID_VBc,
     I        VMI,    VMI_SLDc,  VMI_Hc, VMI_Bc,
     I        VMC,    VMC_DSYc,  VMC_DSXc,
     I        VMHB,   VMHB_CVBc, VMHB_EVBc, VMHB_DVBc, VMHB_SLVc,
     I        PMM,
     I        MH,  LH)
      else if (IMM (IMD_VB) .eq. SW_VB_HSFUNC) then
         call MBScmp
     O       (iErr,
     O        VMID,   VMID_UBb,
     I        VMI,    VMI_SLDb,  VMI_Hb,
     I        VMC,    VMC_DSXb,  VMC_DSYb,
     I        VMHB,   VMHB_CVBb, VMHB_EVBb,
     I        MH,  LH)
         call MBScmp
     O       (iErr,
     O        VMID,   VMID_VBc,
     I        VMI,    VMI_SLDc,  VMI_Hc,
     I        VMC,    VMC_DSYc,  VMC_DSXc,
     I        VMHB,   VMHB_CVBc, VMHB_EVBc,
     I        MH,  LH)
      else if (IMM (IMD_VB) .eq. SW_VB_TWEERTMAN) then
         call MBSwtm
     O       (iErr,
     O        VMID,   VMID_UBb,
     I                VMID_BSXb, VMID_BSYb,
     I        VMI,    VMI_SLDb,  VMI_Hb,    VMI_Bb,
     I        VMHB,   VMHB_CVBb, VMHB_EVBb, VMHB_DVBb, VMHB_SLVb,
     I        PMM,    MH,  LH)
         call MBSwtm
     O       (iErr,
     O        VMID,   VMID_VBc,
     I                VMID_BSYc, VMID_BSXc,
     I        VMI,    VMI_SLDc,  VMI_Hc,    VMI_Bc,
     I        VMHB,   VMHB_CVBc, VMHB_EVBc, VMHB_DVBc, VMHB_SLVc,
     I        PMM,    MH,  LH)
      endif
CCC_  * vb limit
      if (PMM(PMD_VBLIM).ge.0.0d0) then
         call MBSlim
     O       (iErr,
     O        VMID, VMID_UBb,
     I        PMM(PMD_VBLIM), MH, LH)
         call MBSlim
     O       (iErr,
     O        VMID, VMID_VBc,
     I        PMM(PMD_VBLIM), MH, LH)
      endif
CCC_  - mask
      call UV1uma (VMID, VMHB, MH, LH, VMID_UBb, VMHB_UMSKb)
      call UV1uma (VMID, VMHB, MH, LH, VMID_VBc, VMHB_VMSKc)
CCC_  - return
      RETURN
      END
CCC_& MBSlim  ## Movement/Basal sliding limitter
      subroutine MBSlim
     O    (iErr,
     O     VMID,      KDV,
     I     VBLIM,     MH,   LH)
CCC_ + Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
c
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  KDV
      _INTENT(OUT,  _REALSTD) VMID (LH, *)
c
      _INTENT(IN,   _REALSTD) VBLIM
c
      integer  jh
      _REALSTD VLP, VLM
CCC_ + Body
      iErr = 0
      VLM = -ABS(VBLIM)
      VLP = +ABS(VBLIM)
      do jh = 1, MH
         VMID(jh, KDV) = MIN(VLP, MAX(VLM, VMID(jh, KDV)))
      enddo
      RETURN
      END
CCC_& MBScmp  ## Movement/Basal sliding computation
      subroutine MBScmp
     O    (iErr,
     O     VMID,      KDV,
     I     VMI,       KIS,  KIH,
     I     VMC,       KCDL, KCDT,
     i     VMHB,      KBC,  KBE,
     I     MH,    LH)
CCC_ + Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
c
      _INTENT(IN,   integer)  MH, LH
      _INTENT(OUT,  _REALSTD) VMID (LH, *)
c
      _INTENT(IN,   _REALSTD) VMI  (LH, *)
      _INTENT(IN,   _REALSTD) VMC  (LH, *)
      _INTENT(IN,   _REALSTD) VMHB (LH, *)

      _INTENT(IN,   integer)  KDV
      _INTENT(IN,   integer)  KIS,  KIH
      _INTENT(IN,   integer)  KCDL, KCDT
      _INTENT(IN,   integer)  KBC,  KBE
c
      integer  jh
      _REALSTD DN
CCC_ + Body
      iErr = 0
      do jh = 1, MH
         DN = (VMC (jh, KCDL)*VMC (jh, KCDL)
     $        +VMC (jh, KCDT)*VMC (jh, KCDT))
         if (DN.ne.0.0d0) then
            DN = DN ** (VMHB (jh, KBE) / 2.0d0)
            VMID (jh, KDV) = VMI (jh, KIS)
     $           * (- VMHB (jh, KBC) * VMI (jh, KIH)) * DN
     $           * VMC (jh, KCDL)
         else
            VMID (jh, KDV) = 0.0d0
         endif
      enddo
      RETURN
      END
CCC_& MBSswa  ## Movement/Basal sliding sally/weertman/A
      subroutine MBSswa
     O    (iErr,
     O     VMID,      KDV,
     I     VMI,       KIS,  KIH,  KIB,
     I     VMC,       KCDL, KCDT,
     i     VMHB,      KBC,  KBE,  KBD,  KBSLV,
     I     PMM,       MH,   LH)
CCC_ + Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
c
      _INTENT(IN,   integer)  MH, LH
      _INTENT(OUT,  _REALSTD) VMID (LH, *)
c
      _INTENT(IN,   _REALSTD) VMI  (LH, *)
      _INTENT(IN,   _REALSTD) VMC  (LH, *)
      _INTENT(IN,   _REALSTD) VMHB (LH, *)

      _INTENT(IN,   integer)  KDV
      _INTENT(IN,   integer)  KIS,  KIH,  KIB
      _INTENT(IN,   integer)  KCDL, KCDT
      _INTENT(IN,   integer)  KBC,  KBE,  KBD,  KBSLV
      _INTENT(IN,   _REALSTD) PMM (*)
c
      integer  jh
      _REALSTD DN
      _REALSTD DI, DW, DR
      _REALSTD HST, HH, HR
CCC_ + Body
      iErr = 0
      DI  = PMM (PMD_DENS)
      DW  = PMM (PMD_DENSW)
#if    OPT_SALLY_WEERTMAN_RATIO == 0
      DR  = DW / DI
#elif  OPT_SALLY_WEERTMAN_RATIO == 1
      DR  = 0.0d0
#else
#   error "invalid choices"
#endif
      do jh = 1, MH
         HST = VMI (jh, KIH) + DR * (VMI (jh, KIB) - VMHB (jh, KBSLV))
         if (HST.le.0.0d0) then
            VMID (jh, KDV) = 0.0d0
         else
c$$$            VMID (jh, KDV) =
c$$$     $           VMI (jh, KIS) *
c$$$     $           (VMHB (jh, KBC)
c$$$     $           * (VMI (jh, KIH)**3.0d0)
c$$$     $           * VMC (jh, KCDL) / HST
c$$$     $           * (VMC (jh, KCDL)**2.0d0
c$$$     $             +VMC (jh, KCDT)**2.0d0))
            HH = (VMI (jh, KIH) / HST) ** (- VMHB (jh, KBD))
            HR = VMI (jh, KIH) ** (VMHB (jh, KBD) + 1.0d0)
            DN = (VMC (jh, KCDL)*VMC (jh, KCDL)
     $           +VMC (jh, KCDT)*VMC (jh, KCDT))
            DN = ((VMI (jh, KIH) * VMI (jh, KIH)) * DN)
     $           ** VMHB (jh, KBE)
            VMID (jh, KDV) = VMI (jh, KIS)
     $           * VMHB (jh, KBC)
     $           * (DN * VMC (jh, KCDL) * (HH * HR))
         endif
      enddo
      RETURN
      END
CCC_& MBSwtm  ## Movement/Basal sliding weertman/A
      subroutine MBSwtm
     O    (iErr,
     O     VMID,      KDV,  KDTL, KDTT,
     I     VMI,       KIS,  KIH,  KIB,
     i     VMHB,      KBC,  KBE,  KBD,  KBSLV,
     I     PMM,       MH,   LH)
CCC_ + Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
c
      _INTENT(IN,   integer)  MH, LH
      _INTENT(OUT,  _REALSTD) VMID (LH, *)
c
      _INTENT(IN,   _REALSTD) VMI  (LH, *)
      _INTENT(IN,   _REALSTD) VMHB (LH, *)

      _INTENT(IN,   integer)  KDV
      _INTENT(IN,   integer)  KDTT, KDTL
      _INTENT(IN,   integer)  KIS,  KIH,  KIB
      _INTENT(IN,   integer)  KBC,  KBE,  KBD, KBSLV
      _INTENT(IN,   _REALSTD) PMM (*)
c
      integer  jh
      _REALSTD DN
      _REALSTD DI,  DW, DR
      _REALSTD HST, HH, HR
CCC_ + Body
      iErr = 0
      do jh = 1, MH
         DN = (VMID (jh, KDTL)*VMID (jh, KDTL)
     $        +VMID (jh, KDTT)*VMID (jh, KDTT))
         if (DN.ne.0.0d0) then
            DN = DN ** ((VMHB (jh, KBE) - 1.0d0)/ 2.0d0)
         endif
         VMID (jh, KDV) = VMI (jh, KIS)
     $        * VMHB (jh, KBC)
     $        * (DN * VMID (jh, KDTL))
      enddo
      RETURN
      END
CCC_& MBSCOL  ## Movement/Basal sliding announcement
      subroutine MBSCOL (STRA, STRB, IOP)
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
         STRA = 'OPT_SALLY_WEERTMAN_RATIO'
         write (STRB, *) OPT_SALLY_WEERTMAN_RATIO
      else
         STRA = ' '
         STRB = ' '
      endif
      RETURN
      END
CCC_* Test
CCC_ + begin
#ifdef TEST_MBSCOL
CCC_ @ MBSTST  ## Movement/Basal sliding test program
#include "ofnstd.h"
#include "odevid.h"  /* MPI table */
      program MBSTST
CCC_  - Test suites
CC::   SOURCES
CCC_  - Declaration
      implicit none
      integer iErr
      integer ipA (LOG_CHANNEL_MAX)
      integer iMA (MAX_MPI_ATTR)
CCC_  - Body
      call DDcapo
     O    (iErr,
     I     2, ' ', 'O', _FNAME, -1)
      if (iErr.eq.0) then
         call DLCmng (ipA, 't')
         call DVHrgC (iErr, MOVEMENT_DV_CLS, ' ', ' ', ipA)
      endif
      if (iErr.eq.0) then
         call DMAtma (iMA)
         call MBStestMain (iErr, ipA, iMA)
         call ACCrep (FPL(ipA), 0)
      endif
      call DevFin (iErr)
      STOP
      END
CCC_ & MBStestMain   ## main
      subroutine MBStestMain (iErr, ipA, iMA)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(IN, integer) ipA (*)
      _INTENT(IN, integer) iMA (*)
CCC_  - Body
      iErr = 0
      RETURN
      END
CCC_ + end
#endif  /* TEST_MBSCOL */
CCC_* obsolete
CCC_ + begin
#if 0 /* obsolete */
CCC_ + end
#endif  /* 0 obsolete */
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
