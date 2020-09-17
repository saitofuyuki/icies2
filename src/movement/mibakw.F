C movement/mibakw.F --- IcIES/Movement/SIA/b (method 2;9-point) kiwi
C Maintainer:  SAITO Fuyuki
C Created: Dec 20 2011
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2018/11/14 16:52:10 fuyuki mibakw.F>'
#define _FNAME 'movement/mibakw.F'
#define _REV   'Snoopy0.9'
CCC_! MANIFESTO
C
C Copyright (C) 2011--2020
C           Japan Agency for Marine-Earth Science and Technology,
C           Ayako ABE-OUCHI
C
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
CCC_! Policy
CC    DO NOT modify VMI in this routine.
CCC_* Common macros
#include "ofdlct.h"   /* fortran dialect */
#include "oarpea.h"
#include "oarpkw.h"   /* operation id in arpeggio/kiwi */
#ifdef NO_MOVEMENT_H
#else
#  include "movement.h" /* movement definitions */
#endif
#include "odevva.h"
CCC_& MIBtgr  ## Topography gradients
      subroutine MIBtgr
     O    (iErr,
     M     VMC,   CW,
     I     VMI,   WW,
     I     MH,    LH,  ipCG,  LCG, ipKW,  iMA)
CCC_ + Description
CC     compute/update values at bcd using a
CC     input:  S:a;         B:a
CC     output: grad S:bcd;  grad B:bc (stored in new/old mix field)
CCC_ + Declaration
      implicit none
c
      _INTENT(OUT,integer)  iErr
      _INTENT(IN, integer)  MH, LH, LCG
c
      _INTENT(IN,   _REALSTD) VMI  (LH, *)
      _INTENT(INOUT,_REALSTD) VMC  (LH, *)
      _INTENT(OUT,  _REALSTD) CW   (*)
c
      _INTENT(IN, _REALSTD) WW  (*)
      _INTENT(IN, integer)  ipCG (LCG, *)
      _INTENT(IN, integer)  ipKW (*), iMA (*)
CCC_ + Body
      iErr = 0
CCC_  * s:a operation
      call AKCgux
     O    (CW,
     I     VMI,  MH,  LH, VMI_Sa,
     I     iMA,  ipCG (1, CGB_Sa))
CCC_   + gradient ds/dx:b ds/dy:c
      call AKGwaz
     O    (VMC (1, VMC_DSXb),
     I     CW,  VMI (1, VMI_Sa),  WW,
     I     MH,  LH,  ipKW, 3,  ipCG (1, CGB_Sa))
      call AKGwaz
     O    (VMC (1, VMC_DSYc),
     I     CW,  VMI (1, VMI_Sa),  WW,
     I     MH,  LH,  ipKW, 4,  ipCG (1, CGB_Sa))
CC       Todo: odd
CCC_   + gradient ds/dy:b ds/dx:c
      call AKCgux
     O    (CW,
     I     VMI,  MH,  LH, VMI_Sd,
     I     iMA,  ipCG (1, CGB_Sd))
      call AKGwaz
     O    (VMC (1, VMC_DSXc),
     I     CW,  VMI (1, VMI_Sd),  WW,
     I     MH,  LH,  ipKW, 1,  ipCG (1, CGB_Sd))
      call AKGwaz
     O    (VMC (1, VMC_DSYb),
     I     CW,  VMI (1, VMI_Sd),  WW,
     I     MH,  LH,  ipKW, 2,  ipCG (1, CGB_Sd))
CC       Todo: odd
CCC_  * b:a operation
CCC_   + Todo
CC        actually B[XY][bc]M is only used when DVB variation
      call AKCgux
     O    (CW,
     I     VMI,  MH,  LH, VMI_Ba,
     I     iMA,  ipCG (1, CGB_Sa))
CCC_   + gradient db/dx:b db/dy:c (old field everywhere, to be updated)
      call AKGwaz
     O    (VMC (1, VMC_BXbM),
     I     CW,  VMI (1, VMI_Ba),  WW,
     I     MH,  LH,  ipKW, 3,  ipCG (1, CGB_Sa))
      call AKGwaz
     O    (VMC (1, VMC_BYcM),
     I     CW,  VMI (1, VMI_Ba),  WW,
     I     MH,  LH,  ipKW, 4,  ipCG (1, CGB_Sa))
CCC_  * end
      RETURN
      END
CCC_& MIBngs  ## Update surface gradients
      subroutine MIBngs
     O    (iErr,
     M     VMC,   CW,  VMW,
     I     WW,
     I     KWNH,  MH,  LH,  ipCG, LCG, ipKW,  iMA)
CCC_ + Description
CC     compute surface gradient at next step by solutions.
CC     USE grad s = (grad nH) + (grad nB);  may be consistent
CC     NOT grad s = grad (nH + nR);
CCC_ + Declaration
      implicit none
c
      _INTENT(OUT,integer)  iErr
      _INTENT(IN, integer)  MH, LH, LCG
c
      _INTENT(INOUT,_REALSTD) VMC  (LH, *)
      _INTENT(INOUT,_REALSTD) VMW  (LH, *)
      _INTENT(OUT,  _REALSTD) CW   (*)
c
      _INTENT(IN, integer)  KWNH
c
      _INTENT(IN, _REALSTD) WW  (*)
      _INTENT(IN, integer)  ipCG (LCG, *)
      _INTENT(IN, integer)  ipKW (*), iMA (*)
CCC_ + Body
      iErr = 0
#if OPT_NHADJ_SALLY /* to be cleaned */
CC adjusted H is in VMW(*,KWNH)
      call AKCgux
     O    (CW,
     I     VMW,  MH,  LH, KWNH,
     I     iMA,  ipCG (1, CGB_Sa))
      call AKGwaz
     M    (VMC (1, VMC_SXbM),
     I     CW,   VMW (1, KWNH), WW,
     I     MH,  LH,  ipKW, 3,  ipCG (1, CGB_Sa))
      call AKGwaz
     M    (VMC (1, VMC_SYcM),
     I     CW,   VMW (1, KWNH), WW,
     I     MH,  LH,  ipKW, 4,  ipCG (1, CGB_Sa))
#else /* not OPT_NHADJ_SALLY */
CCC_  * clone new H:a (use Sa group)
      call AKCgux
     O    (CW,
     I     VMC,  MH,  LH, VMC_NHa,
     I     iMA,  ipCG (1, CGB_Sa))
CCC_  * dH[new]/dxy to dS[mixed]/dxy
      call AKGwax
     M    (VMC,
     I     CW,   WW,
     I     MH,   LH,  VMC_SXbM, VMC_NHa,
     I     ipKW, 3,   ipCG (1, CGB_Sa))
      call AKGwax
     M    (VMC,
     I     CW,   WW,
     I     MH,   LH,  VMC_SYcM, VMC_NHa,
     I     ipKW, 4,   ipCG (1, CGB_Sa))
#endif /* not OPT_NHADJ_SALLY */
CCC_  * ds[new]/dxy
CC      NOTE:
CC        dB/dx is inconsistent with dB[new]/dx where floated
CC        This is intentional behavior.
      call UV0uaa (VMC, MH, LH, VMC_SXbM, VMC_BXbM)
      call UV0uaa (VMC, MH, LH, VMC_SYcM, VMC_BYcM)
CCC_  * END
      RETURN
      END
CCC_& MIBdfs  ## Diffusion at staggered grids computation suite
      subroutine MIBdfs
     O    (iErr,
     M     VMID,
     I     VMI,   VMC,   VMHB,
     I     DENS,  GRAV,  PF,   FG,
     I     MH,    LH)
CCC_ + Description
CC     Basal velocity not computed
CCC_ + Declaration
      implicit none
      _INTENT(OUT,integer)  iErr
      _INTENT(IN, integer)  MH, LH
c
      _INTENT(INOUT,_REALSTD) VMID (*)
c
      _INTENT(IN,   _REALSTD) VMI  (*)
      _INTENT(IN,   _REALSTD) VMC  (*)
      _INTENT(IN,   _REALSTD) VMHB (*)
c
      _INTENT(IN, _REALSTD) DENS, GRAV, PF
      _INTENT(IN, _REALSTD) FG (3)
CCC_ + Body
      iErr = 0
      call MIBdfp
     O    (iErr,
     M     VMID,
     I     VMI,      VMC,      VMHB,
     I     DENS,     GRAV,     PF,  FG(1),FG(2), FG(3),
     I     MH,       LH,
     I     VMI_Hb,   VMI_RFIIb,
     I     VMC_DSXb, VMC_DSYb,    VMHB_UMSKb,
     I     VMID_Db,  VMID_UIavb,  VMID_BSXb,VMID_BSYb,VMID_BNb)
      call MIBdfp
     O    (iErr,
     M     VMID,
     I     VMI,      VMC,      VMHB,
     I     DENS,     GRAV,     PF,  FG(2),FG(1), FG(3),
     I     MH,       LH,
     I     VMI_Hc,   VMI_RFIIc,
     I     VMC_DSYc, VMC_DSXc,    VMHB_VMSKc,
     I     VMID_Dc,  VMID_VIavc,  VMID_BSYc,VMID_BSXc,VMID_BNc)
c$$$CC x-1d force
c$$$      call UV0sta (VMID, MH, LH, VMID_Dc, 0.0d0)
c$$$      call UV0sta (VMID, MH, LH, VMID_Ec, 0.0d0)
c$$$CC y-1d force
c$$$      call UV0sta (VMID, MH, LH, VMID_Db, 0.0d0)
c$$$      call UV0sta (VMID, MH, LH, VMID_Eb, 0.0d0)
c
      RETURN
      END
CCC_& MIBdfp  ## Diffusion at staggered grids computation primitive
      subroutine MIBdfp
     O    (iErr,
     M     VMID,
     I     VMI,   VMC,   VMHB,
     I     DENS,  GRAV,  PF,   FGL,  FGT, FGZ,
     I     MH,    LH,
     I     KH,    KRFII, KDSL, KDST, KVMSK,
     I     KD,    KE,    KBSL, KBST, KBSN)
CCC_ + Declaration
      implicit none
      _INTENT(OUT,integer)  iErr
      _INTENT(IN, integer)  MH, LH
c
      _INTENT(INOUT,_REALSTD) VMID (*)
c
      _INTENT(IN,   _REALSTD) VMI  (*)
      _INTENT(IN,   _REALSTD) VMC  (*)
      _INTENT(IN,   _REALSTD) VMHB (*)
c
      _INTENT(IN, _REALSTD) DENS, GRAV, PF
      _INTENT(IN, _REALSTD) FGL,  FGT,  FGZ
c
      _INTENT(IN, integer)  KH,   KRFII
      _INTENT(IN, integer)  KDSL, KDST
      _INTENT(IN, integer)  KVMSK
      _INTENT(IN, integer)  KD,   KE,   KBSL, KBST, KBSN
CCC_ + Body
      iErr = 0
CCC_  * basal shear stress
      call MIFpbs
     $     (VMID, VMI,VMC, DENS,GRAV,FGZ,FGL, KBSL,KH,KDSL, MH,LH)
      call MIFpbs
     $     (VMID, VMI,VMC, DENS,GRAV,FGZ,FGT, KBST,KH,KDST, MH,LH)
c
      call MIFpbn (VMID, PF, KBSN,KBSL,KBST, MH,LH)
CCC_  * diffusion coefficient
      call MIFpdc
     $     (VMID, VMI, DENS,GRAV, KD,KBSN,  KRFII,KH, MH,LH)
CCC_  * vertical averaged velocity (without basal velocity)
      call MIFavh
     $     (VMID, VMI, KE,KBSL,KBSN, KRFII,KH, MH,LH)
CCC_  * mask
      call UV1uma (VMID, VMHB, MH, LH, KD, KVMSK)
      call UV1uma (VMID, VMHB, MH, LH, KE, KVMSK)
CCC_  * return
      RETURN
      END
CCC_* Horizontal velocity component
CCC_ & MIBvhs  ## Velocities at staggered grids suite
      subroutine MIBvhs
     O    (iErr,
     W     W,
     O     VMTI,  VMTW,
     I     VMI,   VMID,  VMC,  VMHB, WZV,
     I     DENS,  GRAV,  PF,   FG,
     I     MH,    LH,    NZ,   LZ,   KZ0,
     I     IMM,   MTYP)
CCC_  * Declaration
      implicit none
c
      _INTENT(OUT,  integer)  iErr
      _INTENT(IN,   integer)  MH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
c
      _INTENT(OUT,  _REALSTD) W    (LH, *)
      _INTENT(INOUT,_REALSTD) VMTI (LH, LZ, *)
      _INTENT(INOUT,_REALSTD) VMTW (LH, LZ, *)
c
      _INTENT(IN,   _REALSTD) VMID (LH, *)
      _INTENT(IN,   _REALSTD) VMI  (LH, *)
      _INTENT(IN,   _REALSTD) VMC  (LH, *)
      _INTENT(IN,   _REALSTD) VMHB (LH, *)
c
      _INTENT(IN,   _REALSTD) WZV  (LZ, *)
c
      _INTENT(IN,   _REALSTD) DENS, GRAV, PF
      _INTENT(IN,   _REALSTD) FG (3)
c
      _INTENT(IN,   integer)  IMM (*)
      _INTENT(IN,   integer)  MTYP
CCC_  * Body
      iErr = 0
CCC_   + update basal stress if necessary
      if (iErr.eq.0) then
         if (MTYP.eq. MMXSW_DVB
     $        .and. IMM (IMD_USG).eq. SW_USG_SNOOPY) then
            call MIFpbs
     $          (VMTW (1, 1,  VMTW_SXZb),
     $           VMI, VMC,    DENS, GRAV, FG (3), FG (1),
     $           KZ0, VMI_Hb, VMC_SXbM,  MH,   LH)
            call MIFpbs
     $          (VMTW (1, 1,  VMTW_SYZc),
     $           VMI, VMC,    DENS, GRAV, FG (3), FG (1),
     $           KZ0, VMI_Hc, VMC_SYcM,  MH,   LH)
         else
            call UV1cpa
     $          (VMTW (1, 1, VMTW_SXZb),
     $           VMID, MH, LH, KZ0, VMID_BSXb)
            call UV1cpa
     $          (VMTW (1, 1, VMTW_SYZc),
     $           VMID, MH, LH, KZ0, VMID_BSYc)
         endif
      endif
CCC_   + common part
CCC_    * safety guard
#if VMTW_ziUIb != VMTW_ziDIb
#  error "different ziUIb ziDIb"
#endif
#if VMTW_ziVIc != VMTW_ziDIc
#  error "different ziVIc ziDIc"
#endif
      if (iErr.eq.0) then
         call MIBvps
     O       (iErr,
     W        W,
     O        VMTI,  VMTW,
     I        VMID,  VMI,    VMC,    VMHB, WZV,
     I        MTYP,  DENS,   GRAV,   PF,   FG (1),  FG (3),
     I        MH,    LH,     NZ,     LZ,   KZ0,
     I        VMTI_UHb,
     I        VMTW_ziUIb, VMTW_SXZb, VMTW_EXZb, VMTW_dudZ,
     I        VMTW_EFb,   VMTW_RFb,  VMTW_RFIb, VMTW_RFIIb,
     I        VMI_Hb,     VMID_BNb,  VMID_UBb,  VMHB_UMSKb)
         call MIBvps
     O       (iErr,
     W        W,
     O        VMTI,  VMTW,
     I        VMID,  VMI,    VMC,    VMHB, WZV,
     I        MTYP,  DENS,   GRAV,   PF,   FG (2),  FG (3),
     I        MH,    LH,     NZ,     LZ,   KZ0,
     I        VMTI_VHc,
     I        VMTW_ziVIc, VMTW_SYZc, VMTW_EYZc, VMTW_dvdZ,
     I        VMTW_EFc,   VMTW_RFc,  VMTW_RFIc, VMTW_RFIIc,
     I        VMI_Hc,     VMID_BNc,  VMID_VBc,  VMHB_VMSKc)
      endif
CCC_   + normal stress, strain rate
      call UV0stc (VMTW, MH, LH, NZ, LZ, KZ0, VMTW_SXXa, 0.0d0)
      call UV0stc (VMTW, MH, LH, NZ, LZ, KZ0, VMTW_SYYa, 0.0d0)
      call UV0stc (VMTW, MH, LH, NZ, LZ, KZ0, VMTW_SXYa, 0.0d0)
      call UV0stc (VMTW, MH, LH, NZ, LZ, KZ0, VMTW_EXXa, 0.0d0)
      call UV0stc (VMTW, MH, LH, NZ, LZ, KZ0, VMTW_EYYa, 0.0d0)
      call UV0stc (VMTW, MH, LH, NZ, LZ, KZ0, VMTW_EXYa, 0.0d0)
c$$$      if (iErr.eq.0) then
c$$$         if      (MTYP.eq. MMXSW_DVB) then
c$$$            if (IMM (IMD_USG).eq. SW_USG_SNOOPY) then
c$$$               call MIBvha
c$$$     O             (iErr,
c$$$     W              W,
c$$$     O              VMTI,  VMTW,
c$$$     I              VMI,   VMID, VMC,  WZV,
c$$$     I              DENS,  GRAV, PF,   FG,
c$$$     I              MH,    LH,   NZ,   LZ,   KZ0)
c$$$            else
c$$$               call MIBvho
c$$$     O             (iErr,
c$$$     W              W,
c$$$     O              VMTI,  VMTW,
c$$$     I              VMI,   VMID, VMC,  WZV,
c$$$     I              DENS,  GRAV, PF,   FG,
c$$$     I              MH,    LH,   NZ,   LZ,   KZ0)
c$$$            endif
c$$$         else if (MTYP.eq. MMXSW_ZEV) then
c$$$            call MIBvhf
c$$$     O          (iErr,
c$$$     W           W,
c$$$     O           VMTI,  VMTW,
c$$$     I           VMI,   VMID, VMC,  WZV,
c$$$     I           DENS,  GRAV, PF,   FG,
c$$$     I           MH,    LH,   NZ,   LZ,   KZ0)
c$$$         else if (MTYP.eq. MMXSW_UP1) then
c$$$            call MIBvhu
c$$$     O          (iErr,
c$$$     W           W,
c$$$     O           VMTI,  VMTW,
c$$$     I           VMI,   VMID, VMC,  WZV,
c$$$     I           DENS,  GRAV, PF,   FG,
c$$$     I           MH,    LH,   NZ,   LZ,   KZ0)
c$$$         endif
c$$$      endif
      return
      END
CCC_ & MIBvps  ## Velocities at staggered grids primitive
      subroutine MIBvps
     O    (iErr,
     W     W,
     O     VMTI,   VMTW,
     I     VMID,   VMI,    VMC,   VMHB, WZV,
     I     MTYP,
     I     DENS,   GRAV,   PF,    FGL,  FGZ,
     I     MH,     LH,     NZ,    LZ,   KZ0,
     I     KVVH,
     I     KWZIVI, KWSS,   KWSR,  KWDUZ,
     I     KTEF,   KTRF,   KTRFI, KTRFII,
     I     KIH,    KDBN,   KDVB,  KVMSK)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,integer)  iErr
      _INTENT(IN, integer)  MH, LH
      _INTENT(IN, integer)  NZ, LZ, KZ0
c
      _INTENT(OUT,  _REALSTD) W    (LH, *)
      _INTENT(INOUT,_REALSTD) VMTI (LH, LZ, *)
      _INTENT(INOUT,_REALSTD) VMTW (LH, LZ, *)
c
      _INTENT(IN,   _REALSTD) VMID (LH, *)
      _INTENT(IN,   _REALSTD) VMI  (LH, *)
      _INTENT(IN,   _REALSTD) VMC  (LH, *)
      _INTENT(IN,   _REALSTD) VMHB (LH, *)
c
      _INTENT(IN,   _REALSTD) WZV  (LZ, *)
c
      _INTENT(IN, _REALSTD) DENS, GRAV, PF
      _INTENT(IN, _REALSTD) FGL,  FGZ
c
      _INTENT(IN, integer)  MTYP
c
      _INTENT(IN, integer)  KVVH
      _INTENT(IN, integer)  KWZIVI, KWSS,   KWSR,  KWDUZ
      _INTENT(IN, integer)  KTEF
      _INTENT(IN, integer)  KTRF,   KTRFI,  KTRFII
      _INTENT(IN, integer)  KIH
      _INTENT(IN, integer)  KDBN,   KDVB
      _INTENT(IN, integer)  KVMSK
c
      integer j, jz, jz0
CCC_  * Body
      iErr = 0
CCC_   + basal shear stress must be set before call
CCC_   + shear stress
      call MIFpsm
     M    (VMTW,
     I     WZV (1, VMVZ_cZa),
     I     KWSS, MH, LH, NZ, LZ, KZ0)
CCC_   + shear strain rate
      call MIFpem
     M    (VMTW,
     I     VMID, WZV (1, VMVZ_cZaN),
     I     KWSR, KTEF,  KTRF,
     I     KWSS, KDBN,  MH, LH, NZ, LZ, KZ0)
CCC_   . shear du/dzeta
      call MIFpuz
     M    (VMTW,
     I     VMI,   VMID,  WZV (1, VMVZ_cZaN),
     I     KWDUZ, KIH,   KTEF,  KTRF,
     I     KWSS,  KDBN,  MH, LH, NZ, LZ, KZ0)
CCC_   + velocity (- basal), integral dzeta
      if (MTYP.eq. MMXSW_DVB) then
C     Notes: on case DVB, ziUI are diffusion-like terms,
C     i.e., ziUI grad H == int ui d zeta.
C     assuming KWZIVI == KWZIDI
         call MIFsdv
     O       (VMTI,
     M        VMTW,
     I        VMI,   VMID,
     I        KVVH,  KWZIVI, KWSS,
     I        KTRFI, KTRFII, KIH, KDBN,
     I        DENS,  GRAV,
     I        MH,    LH,     NZ,  LZ,   KZ0)
      else
         call MIFsvv
     O       (VMTI,
     M        VMTW,
     I        VMI,   VMID,
     I        KVVH,  KWZIVI, KWSS,
     I        KTRFI, KTRFII, KIH, KDBN,
     I        MH,    LH,     NZ,  LZ,   KZ0)
      endif
CCC_   + copy basal velocity
      do j = 1, MH
         VMTI (j, KZ0, KVVH)   = VMID (j, KDVB)
         VMTW (j, KZ0, KWZIVI) = VMID (j, KDVB)
      enddo
CCC_   . mask
      do jz0 = 0, NZ - 1
         jz = KZ0 + jz0
         do j = 1, MH
            VMTI(j,jz, KVVH)   = VMTI(j,jz, KVVH)   * VMHB(j, KVMSK)
            VMTW(j,jz, KWZIVI) = VMTW(j,jz, KWZIVI) * VMHB(j, KVMSK)
         enddo
      enddo
      RETURN
      END
CCC_& MIBcgr  ## Movement/SIA/b/kiwi clone gloup declaration
      subroutine MIBcgr
     O    (iErr,
     O     ipCG,
     W     kDTA,
     I     LTBL, LCG, LH, LCK, ipKW, IE, IFP)
CCC_ + Declaration
      implicit none
      _INTENT(OUT,  integer) iErr
      _INTENT(IN,   integer) LCG, LH, LTBL, LCK
      _INTENT(OUT,  integer) ipCG (LCG, *)
      _INTENT(OUT,  integer) kDTA (LTBL, 3)
      _INTENT(IN,   integer) ipKW (*), IE (*), IFP
      integer    kv
CCC_ + Body
      iErr = 0
      kv   = 0
CCC_  * group H (to moved)
      if (iErr.eq.0) then
         kv = CGB_Ha
         call AKCgrs (iErr, ipCG (1, kv), LCG)
         call AKCgad (iErr, ipCG (1, kv), KWO_Lab,  KWM_M, LCG)
         call AKCgad (iErr, ipCG (1, kv), KWO_Lac,  KWM_M, LCG)
         call AKCgsb
     O       (iErr, ipCG (1, kv),  KDTA,
     I        LCG,  LTBL,  LH,   ipKW, IE,   IFP)
      endif
CCC_  * group Sa
      if (iErr.eq.0) then
         kv = CGB_Sa
         call AKCgrs (iErr, ipCG (1, kv), LCG)
         call AKCgad (iErr, ipCG (1, kv), KWO_Lab,  KWM_M, LCG)
         call AKCgad (iErr, ipCG (1, kv), KWO_Lac,  KWM_M, LCG)
         call AKCgad (iErr, ipCG (1, kv), KWO_GXab, KWM_M, LCG)
         call AKCgad (iErr, ipCG (1, kv), KWO_GYac, KWM_M, LCG)
         call AKCgsb
     O       (iErr, ipCG (1, kv),  KDTA,
     I        LCG,  LTBL,  LH,   ipKW, IE,   IFP)
      endif
CCC_  * group Sd
      if (iErr.eq.0) then
         kv = CGB_Sd
         call AKCgrs (iErr, ipCG (1, kv), LCG)
         call AKCgad (iErr, ipCG (1, kv), KWO_GXdc, KWM_M, LCG)
         call AKCgad (iErr, ipCG (1, kv), KWO_GYdb, KWM_M, LCG)
         call AKCgsb
     O       (iErr, ipCG (1, kv),  KDTA,
     I        LCG,  LTBL,  LH,   ipKW, IE,   IFP)
      endif
c
      call DAtrcU (IFP, iErr, 'R', 'MIBCGR')
      RETURN
      END
CCC_& MIBdec  ## Movement/SIA/b/kiwi operator declaration
      subroutine MIBdec
     O    (iErr,
     M     ipKW,
     I     IFP)
      implicit none
      _INTENT(OUT,  integer) iErr
      _INTENT(INOUT,integer) ipKW (*)
      _INTENT(IN,   integer) IFP
      iErr = 0
c
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_Lab,  KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_Lac,  KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_GXab, KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_GYac, KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_GXdc, KWM_BOTH, IFP)
      if (iErr.eq.0) call AKPdec (iErr, ipKW, KWO_GYdb, KWM_BOTH, IFP)
c
      RETURN
      END
CCC_& MIBAKW  ## Movement/SIA/b/kiwi announcement
      subroutine MIBAKW (STRA, STRB, IOP)
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
CCC_ @ MIBKTS  ## Movemeent/SIA/b/kiwi test program
#ifdef     TEST_MIBAKW
#  ifndef    TEST_MIBAKW_SUB
#    define  TEST_MIBAKW_SUB 1
#  endif
#include "ofnstd.h"
#include "odevid.h"  /* MPI table */
      program MIBKTS
CCC_  * Test suites
CC::   SOURCES mifunc.F
CCC_  * Declaration
      implicit none
      integer iErr
      integer ipA (LOG_CHANNEL_MAX)
      integer iMA (MAX_MPI_ATTR)
CCC_  * Body
      call DDcapo
     O    (iErr,
     I     2, ' ', 'O', _FNAME, -1)
c
      if (iErr.eq.0) then
         call DLCmng (ipA, 't')
         call DMArst (iMA)
         call DMAtpi (iMA)
         call DVHrgC (iErr, MOVEMENT_DV_CLS, ' ', ' ', ipA)
      endif
c
      if (iErr.eq.0) call MIBKtestMain (iErr, ipA, iMA)
c
      call ACCrep (FPL(ipA), 0)
      call DevFin (iErr)
c
      STOP
      END
CCC_ & MIBKtestMain   ## main
      subroutine MIBKtestMain (iErr, ipA, iMA)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,integer) iErr
      _INTENT(IN, integer) ipA (*)
      _INTENT(IN, integer) iMA (*)
CCC_   + tables
      character  CROOT * (32)
c
CCC_   + kiwi
#ifndef   OPT_MIBAKW_LHP_MAX
#  define OPT_MIBAKW_LHP_MAX OPT_MOVEMENT_LHP_MAX
#endif
      integer    LHP
      parameter (LHP = OPT_MIBAKW_LHP_MAX)
      integer    LWV
      parameter (LWV = OPT_MIBAKW_LHP_MAX)
c
      integer    ipKW (IPKW_FULL_DECL)
      integer    LKW
      parameter (LKW = 64)
      _REALSTD   WW (LHP * LKW)
      _REALSTD   WV (LWV)
c
      integer    LCK
      parameter (LCK = 4)
      _REALSTD   CW   (LHP * LCK)
c
      integer    LIE
      parameter (LIE = LHP * 8)
      integer    IE (LIE)
CCC_   + variable clusters
      _REALSTD   VMW  (LHP * VMW_MAX)
c
      _REALSTD   VMI  (LHP * VMI_MAX)
      _REALSTD   VMC  (LHP * VMC_MAX)
      _REALSTD   VMHB (LHP * VMHB_MAX)
c
      _REALSTD   VMID (LHP * VMID_MAX)
CCC_   + parameters
      _REALSTD   DENS, GRAV, PF, FG  (3)
      _REALSTD   DT,   WF
CCC_   + size
      integer    MH,  LH
      integer    NZ,  LZ,  KZ0
CCC_   + clone group
      integer    LCG
      parameter (LCG = KWCG_DECL(4))
      integer    ipCG (LCG, CGB_MAX)
      save       ipCG
c
      integer    LTBL
      parameter (LTBL = LHP)
      integer    kDTA (LTBL, 3)
CCC_   + coordinate
      integer  icF
CCC_   + output
      integer  idGM (16)
CCC_   + files
      integer    ipL, ipV, ipP, ipC
      integer    IFPa (16)
CCC_  * Body
      iErr  = 0
      ipL   = FPL(ipA)
      ipV   = FPV(ipA)
      ipC   = FPC(ipA)
      ipP   = FPP(ipA)
      call AFUifp (IFPa, ipP, ipC, ipL, ipV)
      CROOT = 'ID'
CCC_   + just for test
      NZ  = 0
      LZ  = 1
      KZ0 = 1
CCC_   + initialization
      if (iErr.eq.0) call AKPini (ipKW)
      if (iErr.eq.0) call MIBdec (iErr, ipKW, ipL)
      if (iErr.eq.0) then
         call MIBKtestCfg
     O       (iErr,
     O        icF, IE,   LIE,  ipKW,
     O        WV,  WW,   MH,   LH,
     I        LHP, LKW,  LWV,  CROOT, ipA,  iMA)
      endif
      if (iErr.eq.0) then
         call MIBKtestField
     O       (iErr,
     O        VMI, VMHB,
     I        MH,  LH,   IE, CROOT, ipA)
      endif
      if (iErr.eq.0) then
         call MIBKtestField2
     O       (iErr,
     M        VMI,
     W        CW,    VMW,
     I        VMHB,
     I        WW,    MH,  LH,
     I        ipKW,  iMA)
      endif
      if (iErr.eq.0) then
         call MIBKtestParam
     O       (iErr,
     O        VMI,  VMHB, VMID,
     O        FG,   DENS, GRAV, PF, DT, WF,
     I        MH,   LH,   ipA)
      endif
      if (iErr.eq.0) then
         call MIBcgr
     O       (iErr,
     O        ipCG,
     W        kDTA,
     I        LTBL, LCG, LH,  LCK, ipKW, IE, ipL)
c$$$         call MIBcgr
c$$$     O       (iErr,
c$$$     O        ipCG,
c$$$     I        LCG,   LH,     ipKW,  IE,  ipL)
      endif
      if (iErr.eq.0) then
         call MIVgst
     O       (iErr, idGM,
     I        icF,  MH,  LH,    NZ,   LZ,  KZ0,
     I        'C',  ' ', CROOT, IFPa, IE,  iMA)
      endif
      if (iErr.eq.0) then
         call MIBKtestExe
     O       (iErr,
     O        VMC,  VMID, VMW,   CW,
     I        VMI,  FG,   DENS,  GRAV,  PF,
     I        WW,
     I        MH,   LH,
     I        ipCG, LCG,  ipKW,  ipA,   iMA, IE, idGM)
      endif
      RETURN
      END
#endif /* TEST_MIBAKW */
#if TEST_MIBAKW_SUB
#include "ofnstd.h"
CCC_ & MIBKtestCfg   ## configuration suite
      subroutine MIBKtestCfg
     O    (iErr,
     O     icF,   IE,    LIE,  ipKW,
     O     WV,    WW,    MH,   LH,
     I     LHP,   LKW,   LWV,  CR,   ipA,  iMA)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
c
      _INTENT(OUT,integer)   icF
      _INTENT(OUT,integer)   IE (*), ipKW (*)
      _INTENT(OUT,_REALSTD)  WV (*), WW (*)
      _INTENT(OUT,integer)   MH,  LH
c
      _INTENT(IN, integer)   LIE, LHP, LKW, LWV
      _INTENT(IN, character) CR*(*)
      _INTENT(IN, integer)   ipA (*), iMA (*)
c
      integer ipL, ipV, ipP, ipC
      integer NZ, LZ, KZ0
      _REALSTD WZV (1)
      _REALSTD vCX, XW, WXN
      _REALSTD vCY, YW, WYN
      integer  NXG, NYG
      integer  MG,  LG,  LHGref
      integer  jedmy
      integer  IFPa (16)
CCC_  * Body
      iErr = 0
c
      ipL   = FPL(ipA)
      ipV   = FPV(ipA)
      ipC   = FPC(ipA)
      ipP   = FPP(ipA)
      call AFUifp (IFPa, ipP, ipC, ipL, ipV)
c
      NXG = 31
      NYG = 31
c
      vCX = 0.5d0
      vCY = 0.5d0
      XW  = 1500.0d3
      YW  = 1500.0d3
      WXN = -1.0d0
      WYN = -1.0d0
c
      LHGref = LHP
c
      call ACCrgR (jedmy, icF, 0, CR, ipL)
c
      call AMHcnr
     O    (iErr,
     W     WV,
     O     MH,    LH,     MG,     LG,   WW,
     O     ipKW,  IE,
     I     NXG,   NYG,
     I     vCX,   XW,     WXN,
     I     vCY,   YW,     WYN,
     L     LWV,   LHP,    LHGref, LKW,  LIE,
     I     icF,   CR,     iMA,    ipP,  ipC,  ipL)
c
      if (iErr.eq.0) then
         call AMBrep
     O       (iErr,
     I        WW,  IE,  ipKW,
     I        MH,  LH,
     I        icF, CR,  'C',  MOVEMENT_DV_CLS,  IFPa,  iMA)
      endif
c
      RETURN
      END
CCC_ & MIBKtestExe   ## execution suite
      subroutine MIBKtestExe
     O    (iErr,
     O     VMC,  VMID, VMW,   CW,
     I     VMI,  FG,   DENS,  GRAV,  PF,
     I     WW,
     I     MH,   LH,
     I     ipCG, LCG,  ipKW, ipA,  iMA, IE, idGM)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,  integer)  iErr
c
      _INTENT(IN,   integer)  MH,  LH
c
      _INTENT(OUT,_REALSTD) VMC  (*)
      _INTENT(OUT,_REALSTD) VMID (*)
      _INTENT(OUT,_REALSTD) VMW  (*)
      _INTENT(OUT,_REALSTD) CW   (*)
      _INTENT(IN, _REALSTD) VMI (*)
c
      _INTENT(IN,   _REALSTD) WW (*)
      _INTENT(IN,   _REALSTD) DENS, GRAV, PF, FG (3)
c
      _INTENT(IN,   integer)  IE  (*), ipKW (*)
      _INTENT(IN,   integer)  ipA (*), iMA  (*)
c
      _INTENT(IN,   integer)  LCG
      _INTENT(IN,   integer)  ipCG (*)
      _INTENT(IN,   integer)  idGM (*)
c
      integer   ipL
      _REALSTD  T
CCC_  * Body
      iErr = 0
      ipL = FPL(ipA)
c
      if (iErr.eq.0) then
         call MIBtgr
     O       (iErr,
     M        VMC,   CW,
     I        VMI,   WW,
     I        MH,    LH,  ipCG,  LCG, ipKW,  iMA)
      endif
c
      if (iErr.eq.0) then
         call MIBdfs
     O       (iErr,
     M        VMID,
     I        VMI,   VMC,
     I        DENS,  GRAV,  PF,   FG,
     I        MH,    LH)
      endif
c
      T = 0.0d0
CCC_   + output clusters
      if (iErr.eq.0) then
         call AFBptc
     O       (iErr,
     I        VMI,
     I        1, idGM (VGRP_VMI), 0, 0, T,  ' ',  ' ',  IE)
      endif
      if (iErr.eq.0) then
         call AFBptc
     O       (iErr,
     I        VMC,
     I        1, idGM (VGRP_VMC), 0, 0, T,  ' ',  ' ',  IE)
      endif
      if (iErr.eq.0) then
         call AFBptc
     O       (iErr,
     I        VMID,
     I        1, idGM (VGRP_VMID),  0, 0, T,  ' ',  ' ',  IE)
      endif
CCC_   + output D SX; E H
      if (iErr.eq.0) then
         call UV3nma
     $        (VMW, VMID, VMC, MH, LH, VMIW_W1, VMID_Db, VMC_DSXb)
         call UV3nma
     $        (VMW, VMID, VMC, MH, LH, VMIW_W2, VMID_Dc, VMC_DSYc)
         call UV3nma
     $        (VMW, VMID, VMI, MH, LH, VMIW_W3, VMID_UIavb, VMI_Hb)
         call UV3nma
     $        (VMW, VMID, VMI, MH, LH, VMIW_W4, VMID_VIavc, VMI_Hc)
         call AFBptc
     O       (iErr,
     I        VMW,
     I        1, idGM (VGRP_VMIW),  0, 0, T,  ' ',  'Q',  IE)
      endif
CCC_   + end
      RETURN
      END
CCC_ & MIBKtestParam   ## set parameters
      subroutine MIBKtestParam
     O    (iErr,
     O     VMI,  VMHB, VMID,
     O     FG,   D,    G,    F,   DTo,  WFo,
     I     MH,   LH,   ipA)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   MH, LH
      _INTENT(OUT,_REALSTD)  VMI  (LH, *)
      _INTENT(OUT,_REALSTD)  VMHB (LH, *)
      _INTENT(OUT,_REALSTD)  VMID (LH, *)
      _INTENT(OUT,_REALSTD)  FG (3), D, G, F, DTo, WFo
      _INTENT(IN, integer)   ipA (*)
CCC_   + config
      _REALSTD   DENS, GRAV, FGZ, FGX, FGY, PF, RF
      data       DENS, GRAV, FGZ, FGX, FGY, PF, RF
     $     / 910.0d0, 9.81d0, 1.0d0, 0.0d0, 0.0d0, 3.0d0, 1.0d-16 /
      _REALSTD   DT, Acc, WF
      data       DT, Acc, WF / 10.0d0, 0.3d0, 1.0d0 /
      namelist /NITSTP/
     $     DENS, GRAV, FGZ, FGX, FGY, PF,  RF, DT, Acc, WF
      integer j
c
      integer ipL, ipC, ipP
CCC_  * Body
      iErr = 0
      ipL = FPL(ipA)
      ipC = FPC(ipA)
      ipP = FPP(ipA)
c
      call UUrwnd (iErr, ipP)
      read  (ipP, NITSTP, IOSTAT = iErr)
      write (ipC, NITSTP, IOSTAT = iErr)
c
      FG (1) = FGX
      FG (2) = FGY
      FG (3) = FGZ
c
      D      = DENS
      G      = GRAV
      F      = PF
      DTo    = DT
      WFo    = WF
c
      do j = 1, MH
         VMHB (j, VMHB_TMBa) = Acc
      enddo
c
      call UV0sta (VMID, MH, LH, VMID_UBb, 0.0d0)
      call UV0sta (VMID, MH, LH, VMID_VBc, 0.0d0)
c
      call MIFcrw
     O    (VMI,
     I     RF,  1.0d0, PF, VMI_RFIIb, MH, LH)
      call MIFcrw
     O    (VMI,
     I     RF,  1.0d0, PF, VMI_RFIIc, MH, LH)
c
CC    Dummy statements
      iErr = iErr + 0 * ipL
c
      RETURN
      END
CCC_ & MIBKtestField   ## set field
      subroutine MIBKtestField
     O    (iErr,
     O     VMI, VMHB,
     I     MH,  LH, IE, CR, ipA)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(IN, integer)   MH,   LH
      _INTENT(OUT,_REALSTD)  VMI  (LH, *)
      _INTENT(OUT,_REALSTD)  VMHB (LH, *)
      _INTENT(IN, character) CR*(*)
      _INTENT(IN, integer)   IE (*), ipA (*)
c
      integer    LI,        LJ
      parameter (LI = 1024, LJ = 1024)
      _REALSTD BF (LI, LJ)
      integer i, j, l
      integer j0x, j0y, j0m
      integer kp,  km
      _REALSTD V
      integer  IFP
c
      character FNH*(128)
      data      FNH /'D/asc.benchfix_H_ij'/
      namelist /NITSTH/ FNH
c
      integer ipL, ipC, ipP
CCC_  * Body
      iErr = 0
      ipL = FPL(ipA)
      ipC = FPC(ipA)
      ipP = FPP(ipA)
c
      call UUrwnd (iErr, ipP)
      read  (ipP, NITSTH, IOSTAT = iErr)
      write (ipC, NITSTH, IOSTAT = iErr)
c
      if (iErr.eq.0) then
         call UUopnQ (iErr, IFP, FNH, -1, 'F', 'OLD', ' ', ' ')
      endif
      if (iErr.eq.0) then
         do j = 1, LJ
            do i = 1, LI
               BF (i, j) = 0.0d0
            enddo
         enddo
         do
            read  (IFP, *, IOSTAT = iErr) i, j, V
            if (iErr.ne.0) goto 100
 101        format ('CHECK:', A, 1x, 2I5, 1x, E24.16)
            write (ipL, 101) _TRIM(CR), i, j, V
            if (i.gt.LI .or. j.gt.LJ) then
               iErr = 1
               goto 190
            endif
            BF (i, j) = V
         enddo
 100     continue
         iErr = 0
 190     continue
      endif
      if (iErr.eq.0) then
         j0x = EA_idxLX(IE,0)
         j0y = EA_idxLY(IE,0)
         do l = 1, MH
            i = IE (j0x + l - 1)
            j = IE (j0y + l - 1)
            VMI (l, VMI_Ha)    = BF (i, j)
            VMHB (l, VMHB_Ra)   = 0.0d0
            VMHB (l, VMHB_Rb)   = 0.0d0
            VMHB (l, VMHB_Rc)   = 0.0d0
            VMHB (l, VMHB_Rd)   = 0.0d0
            VMHB (l, VMHB_NRa)  = 0.0d0
            VMHB (l, VMHB_NRXb) = 0.0d0
            VMHB (l, VMHB_RXb)  = 0.0d0
            VMHB (l, VMHB_NRYc) = 0.0d0
            VMHB (l, VMHB_RYc)  = 0.0d0
         enddo
      endif
c
      if (iErr.eq.0) then
         J0M = EA_idxMU(IE,0)
         do kp = 0, MH - 1
            km = IE (J0M + kp)
            if (km.eq.0) then
               VMI (1 + kp, VMI_CLa) = 1.0d0
            else
               VMI (1 + kp, VMI_CLa) = 0.0d0
            endif
         enddo
      endif
      RETURN
      END
CCC_ & MIBKtestField2  ## bcd interpolation
      subroutine MIBKtestField2
     O    (iErr,
     M     VMI,
     W     CW,    VW,
     I     VMHB,
     I     WW,    MH,  LH,
     I     ipKW,  iMA)
CCC_  * Description
CC     compute/update values at bcd using a
CCC_  * Declaration
      implicit none
c
      _INTENT(OUT,integer)  iErr
      _INTENT(IN, integer)  MH, LH
c
      _INTENT(INOUT,_REALSTD) VMI  (LH, *)
      _INTENT(OUT,  _REALSTD) VW   (LH, *)
      _INTENT(OUT,  _REALSTD) CW   (*)
      _INTENT(IN,   _REALSTD) VMHB (LH, *)
c
      _INTENT(IN, _REALSTD) WW  (*)
      _INTENT(IN, integer)  ipKW (*), iMA (*)
c
      integer kp
      integer KSW
CCC_  * Body
      iErr = 0
      KSW  = KWM_M
CCC_   + H:a operation (interpolation H:b H:c)
      call AKBwax
     O    (VMI,  CW,
     I     WW,
     I     MH,   LH,  VMI_Hb,  VMI_Ha,
     I     ipKW, iMA, KWO_Lab, KSW)
      call AKBwax
     O    (VMI,  CW,
     I     WW,
     I     MH,   LH,  VMI_Hc,  VMI_Ha,
     I     ipKW, iMA, KWO_Lac, KSW)
CCC_    * interpolation b:d c:d
      call AKBwaz
     O    (VW  (1, VMIW_W1), CW,
     I     VMI (1, VMI_Hb),  WW,
     I     MH,  LH, ipKW, iMA, KWO_Lbd, KWM_M)
      call AKBwaz
     O    (VW  (1, VMIW_W2), CW,
     I     VMI (1, VMI_Hc),  WW,
     I     MH,  LH, ipKW, iMA, KWO_Lcd, KWM_M)
      do kp = 1, MH
         VMI (kp, VMI_Hd)
     $        = (VW (kp, VMIW_W1) + VW (kp, VMIW_W2)) * 0.5d0
      enddo
CCC_   + end
      call UV1cpa (VMI, VMHB, MH, LH, VMI_Ba, VMHB_Ra)
      call UV0naa (VMI,       MH, LH, VMI_Sa, VMI_Ha, VMI_Ba)
      call UV1cpa (VMI, VMHB, MH, LH, VMI_Bb, VMHB_Rb)
      call UV0naa (VMI,       MH, LH, VMI_Sb, VMI_Hb, VMI_Bb)
      call UV1cpa (VMI, VMHB, MH, LH, VMI_Bc, VMHB_Rc)
      call UV0naa (VMI,       MH, LH, VMI_Sc, VMI_Hc, VMI_Bc)
      call UV1cpa (VMI, VMHB, MH, LH, VMI_Bd, VMHB_Rd)
      call UV0naa (VMI,       MH, LH, VMI_Sd, VMI_Hd, VMI_Bd)
c
      RETURN
      END
#endif /* TEST_MIBAKW_SUB */
CCC_* obsolete
CCC_ + begin
#if 0 /* obsolete */
#endif /* 0 */
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
