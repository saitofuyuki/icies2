C movement/mifunc.F --- IcIES/Movement/SIA/common
C Maintainer:  SAITO Fuyuki
C Created: Oct 26 2011
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2020/09/17 08:45:21 fuyuki mifunc.F>'
#define _FNAME 'movement/mifunc.F'
#define _REV   'Snoopy0.97'
CCC_! MANIFESTO
C
C Copyright (C) 2011--2020
C           Japan Agency for Marine-Earth Science and Technology,
C           Ayako ABE-OUCHI
C
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
CCC_* Common macros
#include "ofdlct.h" /* fortran dialect */
CCC_* primitives (2d)
CCC_ & MIFpbs  ## basal shear stress
      subroutine MIFpbs
     O    (VMID,
     I     VMI,  VMC,
     I     DENS, GRAV,  FG,   FS,
     I     KDPB, KIH,   KCDS, N, L)
CC   FG: gravity angle factor (usually 1)
CC   FS: slope angle factor   (usually 0)
      implicit none
      _INTENT(IN, integer)  N,   L
      _INTENT(OUT,_REALSTD) VMID (L, *)
      _INTENT(IN, _REALSTD) VMI  (L, *)
      _INTENT(IN, _REALSTD) VMC  (L, *)
      _INTENT(IN, integer)  KDPB
      _INTENT(IN, integer)  KIH,  KCDS
      _INTENT(IN, _REALSTD) DENS, GRAV
      _INTENT(IN, _REALSTD) FG,   FS
      integer  kp
      _REALSTD C
CC pigpen mnssub operation
      C = - DENS * GRAV * FG
      do kp = 1, N
         VMID (kp, KDPB) = (C * VMC (kp, KCDS) - FS) * VMI (kp, KIH)
      enddo
      RETURN
      END
CCC_ & MIFpbn  ## basal shear stress n-th power
      subroutine MIFpbn
     M    (VMID,
     I     PF,
     I     KDBN, KDBX, KDBY, N, L)
      implicit none
      _INTENT(IN,   integer)  N,    L
      _INTENT(INOUT,_REALSTD) VMID (L, *)
      _INTENT(IN,   integer)  KDBN
      _INTENT(IN,   integer)  KDBX, KDBY
      _INTENT(IN,   _REALSTD) PF
      integer  kp
      _REALSTD C
      C = (PF - 1.0d0) / 2.0d0
      do kp = 1, N
         VMID (kp, KDBN)
     $        = (VMID (kp, KDBX) * VMID (kp, KDBX)
     $         + VMID (kp, KDBY) * VMID (kp, KDBY)) ** C
      enddo
      RETURN
      END
CCC_ & MIFpdc  ## diffusion coefficients
      subroutine MIFpdc
     M    (VMID,
     I     VMI,
     I     DENS, GRAV,
     I     KDD,  KDBN,   KIRFII, KIH,  N, L)
      implicit none
      _INTENT(IN,   integer)  N,    L
      _INTENT(INOUT,_REALSTD) VMID (L, *)
      _INTENT(IN,   _REALSTD) VMI  (L, *)
      _INTENT(IN,   integer)  KDD,    KDBN
      _INTENT(IN,   integer)  KIRFII, KIH
      _INTENT(IN,   _REALSTD) DENS,   GRAV
      integer  kp
      _REALSTD C
      C = - 2.0d0 * DENS * GRAV
      do kp = 1, N
         VMID (kp, KDD) =
     $        ((C * VMI (kp, KIH)) * VMID (kp, KDBN)
     $          * VMI (kp, KIH) * VMI (kp, KIH)) * VMI (kp, KIRFII)
      enddo
      RETURN
      END
CCC_ & MIFavh  ## vertically averaged velocity (without basal velocity)
      subroutine MIFavh
     M    (VMID,
     I     VMI,
     I     KDAVH, KDBS, KDBN, KIRFII, KIH, N, L)
      implicit none
      _INTENT(IN,   integer)  N,    L
      _INTENT(INOUT,_REALSTD) VMID (L, *)
      _INTENT(IN,   _REALSTD) VMI  (L, *)
      _INTENT(IN,   integer)  KDAVH, KDBS, KDBN
      _INTENT(IN,   integer)  KIH,   KIRFII
      integer  kp
      do kp = 1, N
         VMID (kp, KDAVH) = 2.0d0 * VMID (kp, KDBS) * VMID (kp, KDBN)
     $        * VMI (kp, KIH) * VMI (kp, KIRFII)
      enddo
      RETURN
      END
CCC_* primitives (3d)
CCC_ & MIFpss  ## shear stress
      subroutine MIFpss
     M    (VMV,
     I     VMD,  ZC,
     I     KVSS, KDBS, NH, LH, NZ, LZ, KZ0)
      implicit none
      _INTENT(IN, integer)  NH,  LH, NZ, LZ, KZ0
      _INTENT(OUT,_REALSTD) VMV (LH, LZ, *)
      _INTENT(IN, _REALSTD) ZC  (LZ)
      _INTENT(IN, _REALSTD) VMD (LH, *)
      _INTENT(IN, integer)  KVSS
      _INTENT(IN, integer)  KDBS
      integer jh, jz, jz0
c
      do jz0 = 0, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, NH
            VMV (jh, jz, KVSS) = VMD (jh, KDBS) * ZC (jz)
         enddo
      enddo
      RETURN
      END
CCC_ & MIFpsm  ## shear stress (var m)
      subroutine MIFpsm
     M    (VMV,
     I     ZC,
     I     KVSS, NH, LH, NZ, LZ, KZ0)
      implicit none
      _INTENT(IN, integer)  NH,  LH, NZ, LZ, KZ0
      _INTENT(OUT,_REALSTD) VMV (LH, LZ, *)
      _INTENT(IN, _REALSTD) ZC  (LZ)
      _INTENT(IN, integer)  KVSS
      integer jh, jz, jz0
c
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, NH
            VMV (jh, jz, KVSS) = VMV (jh, KZ0, KVSS) * ZC (jz)
         enddo
      enddo
      RETURN
      END
CCC_ & MIFpse  ## shear strain rate (not called)
      subroutine MIFpse
     M    (VMV,
     I     VMD,  VMID, ZCN,
     I     KVSE, KVEF, KVRF,
     I     KBS,  KDBN, NH, LH, NZ, LZ, KZ0)
      implicit none
      _INTENT(IN,   integer)  NH,  LH, NZ, LZ, KZ0
      _INTENT(INOUT,_REALSTD) VMV  (LH, LZ, *)
      _INTENT(IN,   _REALSTD) VMD  (LH, *)
      _INTENT(IN,   _REALSTD) VMID (LH, *)
      _INTENT(IN,   _REALSTD) ZCN  (LZ)
      _INTENT(IN,   integer)  KVSE, KVRF, KVEF
      _INTENT(IN,   integer)  KBS, KDBN
      integer jh, jz, jz0
CC    ZCN = (1 - zeta) ** N
c
      do jz0 = 0, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, NH
            VMV (jh, jz, KVSE)
     $           = (VMD (jh, KBS) * VMID (jh, KDBN))
     $           * (VMV (jh, jz, KVEF) * VMV (jh, jz, KVRF))
     $           * ZCN (jz)
         enddo
      enddo
      RETURN
      END
CCC_ & MIFpem  ## shear strain rate (var m)
      subroutine MIFpem
     M    (VMV,
     I     VMID, ZCN,
     I     KVSE, KVEF, KVRF,
     I     KSS,  KDBN, NH, LH, NZ, LZ, KZ0)
      implicit none
      _INTENT(IN,   integer)  NH,  LH, NZ, LZ, KZ0
      _INTENT(INOUT,_REALSTD) VMV  (LH, LZ, *)
      _INTENT(IN,   _REALSTD) VMID (LH, *)
      _INTENT(IN,   _REALSTD) ZCN  (LZ)
      _INTENT(IN,   integer)  KVSE, KVRF, KVEF
      _INTENT(IN,   integer)  KSS,  KDBN
      integer jh, jz, jz0
CC    ZCN = (1 - zeta) ** N
      do jz0 = 0, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, NH
            VMV (jh, jz, KVSE)
     $           = (VMV (jh, KZ0, KSS) * VMID (jh, KDBN))
     $           * (VMV (jh, jz, KVEF) * VMV (jh, jz, KVRF))
     $           * ZCN (jz)
         enddo
      enddo
      RETURN
      END
CCC_ & MIFpuz  ## du/dzeta
      subroutine MIFpuz
     M    (VMV,
     I     VMI,  VMID, ZCN,
     I     KVUZ, KIH,  KVEF, KVRF,
     I     KSS,  KDBN, NH, LH, NZ, LZ, KZ0)
      implicit none
      _INTENT(IN,   integer)  NH,  LH, NZ, LZ, KZ0
      _INTENT(INOUT,_REALSTD) VMV  (LH, LZ, *)
      _INTENT(IN,   _REALSTD) VMI  (LH, *)
      _INTENT(IN,   _REALSTD) VMID (LH, *)
      _INTENT(IN,   _REALSTD) ZCN  (LZ)
      _INTENT(IN,   integer)  KVUZ, KVRF, KVEF
      _INTENT(IN,   integer)  KIH,  KSS,  KDBN
      integer jh, jz, jz0
CC    ZCN = (1 - zeta) ** N
      do jz0 = 0, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, NH
            VMV (jh, jz, KVUZ)
     $           = 2.0d0
     $           * (VMV (jh, KZ0, KSS) * VMID (jh, KDBN))
     $           * (VMV (jh, jz, KVEF) * VMV (jh, jz, KVRF))
     $           * ZCN (jz)
     $           * VMI (jh, KIH)
         enddo
      enddo
      RETURN
      END
CCC_ + Rate factor integral functions (simple)
CCC_  & MIFcrw  ## constant rate factor double integral
      subroutine MIFcrw
     O    (VMD,
     I     CRF,  CEF, PF, KDRFII,  N, L)
      implicit none
      _INTENT(IN,   integer)  N,   L
      _INTENT(IN,   integer)  KDRFII
      _INTENT(INOUT,_REALSTD) VMD (L, *)
      _INTENT(IN,   _REALSTD) CRF, CEF, PF
      _REALSTD R
      R = (CEF * CRF) / (PF + 2.0d0)
      call UV0sta (VMD, N, L, KDRFII, R)
      RETURN
      END
CCC_  & MIFcro  ## constant rate factor double integral
      subroutine MIFcro
     O    (VMV,
     I     ZT,
     I     CRF,  CEF, PF, KVRFII,  NH, LH, NZ, LZ, KZ0)
      implicit none
      _INTENT(IN,   integer)  NH,  LH, NZ, LZ, KZ0
      _INTENT(INOUT,_REALSTD) VMV (LH, LZ, *)
      _INTENT(IN,   _REALSTD) ZT  (*)
      _INTENT(IN,   integer)  KVRFII
      _INTENT(IN,   _REALSTD) CRF, CEF, PF
      _REALSTD R
      integer  jh, jz, jz0
      do jz0 = 0, NZ - 1
         jz = KZ0 + jz0
c$$$         R = (CEF * CRF)
c$$$     $        * ((ZT (jz) / (PF + 1.0d0))
c$$$     $          + (((1.0d0 - ZT (jz))**(PF + 2.0d0)) - 1.0d0)
c$$$     $             / (PF + 1.0d0) / (PF + 2.0d0))
         R = (CEF * CRF)
     $        * (((ZT (jz) * (PF + 2.0d0))
     $           +(1.0d0 - ZT (jz))**(PF + 2.0d0)
     $           -1.0d0)
     $             / (PF + 1.0d0) / (PF + 2.0d0))
         do jh = 1, NH
            VMV (jh, jz, KVRFII) = R
         enddo
      enddo
      RETURN
      END
CCC_  & MIFcri  ## constant rate factor integral
      subroutine MIFcri
     O    (VMV,
     I     ZT,
     I     CRF,  CEF, PF, KVRFI,  NH, LH, NZ, LZ, KZ0)
      implicit none
      _INTENT(IN,   integer)  NH,  LH, NZ, LZ, KZ0
      _INTENT(INOUT,_REALSTD) VMV (LH, LZ, *)
      _INTENT(IN,   _REALSTD) ZT  (*)
      _INTENT(IN,   integer)  KVRFI
      _INTENT(IN,   _REALSTD) CRF, CEF, PF
      _REALSTD R
      integer  jh, jz, jz0
      do jz0 = 0, NZ - 1
         jz = KZ0 + jz0
         R = (CEF * CRF)
     $        * ((1.0d0 - ((1.0d0 - ZT (jz)) ** (PF + 1.0d0)))
     $           /(PF + 1.0d0))
         do jh = 1, NH
            VMV (jh, jz, KVRFI) = R
         enddo
      enddo
      RETURN
      END
CCC_ + Rate factor integral functions (euler)
CCC_  & MIFera  ## rate factor integral all (euler)
      subroutine MIFera
     O    (VT,   VH,
     I     VZ,
     I     KTI,  KTII, KHII,
     I     KTF,  KTE,
     I     KZ,   KDZ,
     I     PF,
     I     NH,   LH,   NZ, LZ, KZ0)
      implicit none
      _INTENT(IN,   integer)  NH, LH
      _INTENT(IN,   integer)  NZ, LZ, KZ0
      _INTENT(INOUT,_REALSTD) VT (LH, LZ, *)
      _INTENT(INOUT,_REALSTD) VH (LH, *)
      _INTENT(IN,   _REALSTD) VZ (LZ, *)
      _INTENT(IN,   _REALSTD) PF
      _INTENT(IN,   integer)  KTI, KTII, KHII
      _INTENT(IN,   integer)  KTF, KTE
      _INTENT(IN,   integer)  KZ,  KDZ
      integer  jh, jz, jzz
      _REALSTD ZR0, ZR1
      do jh = 1, NH
         VT (jh, KZ0, KTI)  = 0.0d0
         VT (jh, KZ0, KTII) = 0.0d0
      enddo
      do jzz = 2, NZ
         jz = KZ0 + jzz - 1
         ZR0 = (1.0d0 - VZ (jz - 1, KZ)) ** PF
         ZR1 = (1.0d0 - VZ (jz,     KZ)) ** PF
         do jh = 1, NH
            VT (jh, jz, KTI) = VT (jh, jz - 1, KTI)
     $           + 0.5d0 * VZ (jz - 1, KDZ)
     $           * (VT (jh, jz - 1, KTF) * VT (jh, jz - 1, KTE) * ZR0
     $             +VT (jh, jz,     KTF) * VT (jh, jz,     KTE) * ZR1)
         enddo
      enddo
      do jzz = 2, NZ
         jz = KZ0 + jzz - 1
         do jh = 1, NH
            VT (jh, jz, KTII) = VT (jh, jz - 1, KTII)
     $           + 0.5d0 * VZ (jz - 1, KDZ)
     $           * (VT (jh, jz - 1, KTI) + VT (jh, jz, KTI))
         enddo
      enddo
      jz = KZ0 + NZ - 1
      do jh = 1, NH
         VH (jh, KHII) = VT (jh, jz, KTII)
      enddo
      RETURN
      END
CCC_  & MIFerw  ## rate factor double integral (euler)
      subroutine MIFerw
     O    (RFVII,
     W     W,
     I     RF,   EF,  PF,
     I     Z,    DZ,  NH,  LH, NZ)
      implicit none
      _INTENT(IN, integer)  NH, LH, NZ
      _INTENT(OUT,_REALSTD) RFVII (LH)
      _INTENT(OUT,_REALSTD) W  (LH, NZ)
      _INTENT(IN, _REALSTD) RF (LH, NZ), EF (LH, NZ), PF
      _INTENT(IN, _REALSTD) Z  (NZ),     DZ (NZ)
      integer  kh,  kz
      _REALSTD ZR0, ZR1
      do kh = 1, NH
         W     (kh, 1) = 0.0d0
         RFVII (kh)    = 0.0d0
      enddo
      do kz = 2, NZ
         ZR0 = (1.0d0 - Z (kz - 1)) ** PF
         ZR1 = (1.0d0 - Z (kz))     ** PF
         do kh = 1, NH
            W (kh, kz) = W (kh, kz - 1)
     $           + 0.5d0 * DZ (kz - 1)
     $           * (EF (kh, kz - 1) * RF (kh, kz - 1) * ZR0
     $             +EF (kh, kz)     * RF (kh, kz)     * ZR1)
         enddo
      enddo
      do kz = 2, NZ
         do kh = 1, NH
            RFVII (kh) = RFVII (kh)
     $           + 0.5d0 * DZ (kz - 1) * (W (kh, kz - 1) + W (kh, kz))
         enddo
      enddo
      RETURN
      END
CCC_ + integral/G variable definitions
#define _IG  1
#define _DG  2
#define _IGG 3
#define _DGG 4
CC     GG (:,:,:,1) AKiG
CC     GG (:,:,:,2) AKdG
CC     GG (:,:,0,3) AKiGG
CC     GG (:,:,0,4) AKdGG
c$$$      real*8 AKiG (Kdim,0:NTH,0:NTH), AKdG (Kdim,0:NTH,0:NTH)
c$$$      real*8 AKiGG(Kdim,0:NTH),       AKdGG(Kdim,0:NTH)
CCC_  & MIFgst  ## Rate factor integral/G preparation
      subroutine MIFgst
     O    (GG,
     I     ZT,
     I     NZ,  LZ, K0, KZT,   NTH,     PF)
CCC_   . Declaration
      implicit none
CCC_    = Arguments
      _INTENT(IN, integer)  NZ, LZ, K0, KZT
      _INTENT(IN, integer)  NTH
      _INTENT(IN, _REALSTD) ZT  (LZ, *)
      _INTENT(OUT,_REALSTD) GG  (NZ, 0:NTH, 0:NTH, 4)
      _INTENT(IN, _REALSTD) PF
CCC_    = Interior
      _REALSTD TN, TM, TM1, TM2
      integer  i, j, k, p,  ks
CCC_   . Body
      ks = k0 - 1
CCC_    * iG
      do j = 0, NTH
         TN = PF + DBLE (j)
         do    i = 0, NTH
            do k = 1, NZ
               GG (k, i, j, _IG) = 0.0d0
            enddo
            do    p = 0, 0
               TM  = TN + DBLE (i - p)
               TM1 = TM + 1.0d0
               do k = 1, NZ
                  GG (k, i, j, _IG) =
     $                 - 1.0d0
     $                 *((1.0d0 - ZT (ks + k, KZT))**TM1) / TM1
     $                 + DBLE (p) * GG (k, i, j, _IG) / TM1
               enddo
            enddo
            do    p = 1, i
               TM  = TN + DBLE (i - p)
               TM1 = TM + 1.0d0
               do k = 1, NZ
                  GG (k, i, j, _IG) =
     $                 - (ZT (ks + k, KZT)**(DBLE (p)))
     $                 *((1.0d0 - ZT (ks + k, KZT))**TM1) / TM1
     $                 + DBLE (p) * GG (k, i, j, _IG) / TM1
               enddo
            enddo
         enddo
      enddo
CCC_    * iGG
      do j = 0, 0
         TN = PF + DBLE (j)
         do    i = 0, NTH
            do p = 0, 0
               TM  = TN  + DBLE (i - p)
               TM1 = TM  + 1.0d0
               TM2 = TM1 + 1.0d0
               do k = 1, NZ
                  GG (k, i, j, _IGG) =
     $                 ((1.0d0 - ZT (ks + k, KZT))**TM2) / TM1 / TM2
               enddo
            enddo
            do p = 1, i
               TM  = TN + DBLE (i - p)
               TM1 = TM + 1.0d0
               do k = 1, NZ
                  GG (k, i, j, _IGG) =
     $                 - GG (k, p, i - p + 1, _IG) / TM1
     $                 + DBLE (p) * GG (k, i, j, _IGG) / TM1
               enddo
            enddo
         enddo
      enddo
CCC_    * dG
      do       i = 0, NTH
         do    p = 0, NTH
            do k = 2, NZ
               GG (k, p, i, _DG) =
     $              GG (k, p, i, _IG) - GG (k - 1, p, i, _IG)
            enddo
         enddo
      enddo
CCC_    * dGG
      do       i = 0, 0
         do    p = 0, NTH
            do k = 2, NZ
               GG (k, p, i, _DGG) =
     $              GG (k, p, i, _IGG) - GG (k - 1, p, i, _IGG)
            enddo
         enddo
      enddo
      RETURN
      END
CCC_  & MIFgii  ## Rate factor integral/G inner integration
      subroutine MIFgii
     O    (VMV,
     I     GG,    ZT,  DZ,
     I     KVRFI, KVE, KVA, NH, LH, NZ, LZ, KZ0, NTH)
CCC_   . Declaration
      implicit none
      _INTENT(IN,   integer)  NH,  LH, NZ, LZ, KZ0
      _INTENT(INOUT,_REALSTD) VMV (LH, LZ, *)
      _INTENT(IN,   _REALSTD) ZT  (NZ), DZ (NZ)
      _INTENT(IN,   integer)  KVRFI
      _INTENT(IN,   integer)  KVE, KVA
      _INTENT(IN,   integer)  NTH
      _INTENT(iN,   _REALSTD) GG (NZ, 0:NTH, 0:NTH, 4)
      integer jh, jz, jz0
      real*8  TA, TB, TC, TD
      real*8  TALP, TBET, TGAM
CCC_   . Body
      call UV0sta (VMV (1, KZ0, KVRFI), NH, LH, 1, 0.0d0)
      do jz0 = 0, NZ - 2
         jz = KZ0 + jz0
         do jh = 1, NH
            TA = (VMV (jh, jz + 1, KVA)
     $           -VMV (jh, jz,     KVA)) / DZ (jz)
            TB = (VMV (jh, jz,     KVA) * ZT (1 + jz)
     $           -VMV (jh, jz + 1, KVA) * ZT (jz))    / DZ (jz)
            TC = (VMV (jh, jz + 1, KVE)
     $           -VMV (jh, jz,     KVE)) / DZ (jz)
            TD = (VMV (jh, jz,     KVE) * ZT (1 + jz)
     $           -VMV (jh, jz + 1, KVE) * ZT (jz))    / DZ (jz)
            TALP = TA * TC
            TBET = TA * TD + TB * TC
            TGAM = TB * TD
            VMV (jh, jz + 1, KVRFI) = VMV (jh, jz, KVRFI)
     $           + ( TALP * GG (2 + jz0, 2, 0, _DG)
     $             + TBET * GG (2 + jz0, 1, 0, _DG)
     $             + TGAM * GG (2 + jz0, 0, 0, _DG))
         enddo
      enddo
      RETURN
      END
CCC_  & MIFgio  ## Rate factor integral/G outer integration
      subroutine MIFgio
     O    (VMV,
     I     GG,     ZT,  DZ,
     I     KVRFII, KVE, KVA, NH, LH, NZ, LZ, KZ0, NTH)
CCC_   . Declaration
      implicit none
      _INTENT(IN,   integer)  NH,  LH, NZ, LZ, KZ0
      _INTENT(INOUT,_REALSTD) VMV (LH, LZ, *)
      _INTENT(IN,   _REALSTD) ZT (NZ), DZ (NZ)
      _INTENT(IN,   integer)  KVRFII
      _INTENT(IN,   integer)  KVE, KVA
      _INTENT(IN,   integer)  NTH
      _INTENT(IN,   _REALSTD) GG (NZ, 0:NTH, 0:NTH, 4)
      integer jh, jz, jz0
      real*8  TA, TB, TC, TD
      real*8  TALP, TBET, TGAM, TDLT
CCC_   ? Note
CC     At the bottom, INDIFINITE (not definite) integral is required.
CC       VG(:,KVI) is difinite integral.  VG(:,KVI) at the surface is 0
CC       if the form is (1-z)^n and zs==1
CCC_   . Body
CCC_    * bottom
      call UV0sta (VMV (1, KZ0, KVRFII), NH, LH, 1, 0.0d0)
CCC_    * upper
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, NH
            TA = (VMV (jh, jz,     KVA)
     $           -VMV (jh, jz - 1, KVA)) / DZ (jz - 1)
            TB = (VMV (jh, jz - 1, KVA) * ZT (jz)
     $           -VMV (jh, jz,     KVA) * ZT (jz - 1))    / DZ (jz - 1)
            TC = (VMV (jh, jz,     KVE)
     $           -VMV (jh, jz - 1, KVE)) / DZ (jz - 1)
            TD = (VMV (jh, jz - 1, KVE) * ZT (jz)
     $           -VMV (jh, jz,     KVE) * ZT (jz - 1))    / DZ (jz - 1)
            TALP = TA * TC
            TBET = TA * TD + TB * TC
            TGAM = TB * TD
            TDLT = VMV (jh, KZ0, KVRFII)
            VMV (jh, jz, KVRFII) = VMV (jh, jz - 1, KVRFII)
     $           + (  TALP * GG (1 + jz0, 2, 0, _DGG)
     $              + TBET * GG (1 + jz0, 1, 0, _DGG)
     $              + TGAM * GG (1 + jz0, 0, 0, _DGG))
     $           - (  TALP * GG (jz0, 2, 0, _IG)
     $              + TBET * GG (jz0, 1, 0, _IG)
     $              + TGAM * GG (jz0, 0, 0, _IG) - TDLT)
     $           * DZ (jz - 1)
            VMV (jh, KZ0, KVRFII) = TDLT
     $           + ( TALP * GG (1 + jz0, 2, 0, _DG)
     $             + TBET * GG (1 + jz0, 1, 0, _DG)
     $             + TGAM * GG (1 + jz0, 0, 0, _DG))
         enddo
      enddo
CCC_    * bottom reset again
      call UV0sta (VMV (1, KZ0, KVRFII), NH, LH, 1, 0.0d0)
      RETURN
      END
CCC_  & MIFgiw  ## Rate factor integral/G outer integration (only outer)
      subroutine MIFgiw
     O    (VMD,
     W     W,
     I     VMV,
     I     GG,     ZT,  DZ,
     I     KDRFII, KVE, KVA, NH, LH, NZ, LZ, KZ0, NTH)
CCC_   . Declaration
      implicit none
      _INTENT(IN, integer)  NH,  LH, NZ, LZ, KZ0
      _INTENT(OUT,_REALSTD) VMD (LH, *)
      _INTENT(OUT,_REALSTD) W   (LH)
      _INTENT(IN, _REALSTD) VMV (LH, LZ, *)
      _INTENT(IN, _REALSTD) ZT (NZ), DZ (NZ)
      _INTENT(IN, integer)  KDRFII
      _INTENT(IN, integer)  KVE, KVA
      _INTENT(IN, integer)  NTH
      _INTENT(IN, _REALSTD) GG (NZ, 0:NTH, 0:NTH, 4)
      integer jh, jz, jz0
      real*8  TA, TB, TC, TD
      real*8  TALP, TBET, TGAM, TDLT
CCC_   ? Note
CC     At the bottom, INDIFINITE (not definite) integral is required.
CC       VG(:,KVI) is difinite integral.  VG(:,KVI) at the surface is 0
CC       if the form is (1-z)^n and zs==1
CCC_   . Body
CCC_    * bottom
      call UV0sta (W,   NH, LH, 1,      0.0d0)
      call UV0sta (VMD, NH, LH, KDRFII, 0.0d0)
CCC_    * upper
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, NH
            TA = (VMV (jh, jz,     KVA)
     $           -VMV (jh, jz - 1, KVA)) / DZ (jz - 1)
            TB = (VMV (jh, jz - 1, KVA) * ZT (jz)
     $           -VMV (jh, jz,     KVA) * ZT (jz - 1))    / DZ (jz - 1)
            TC = (VMV (jh, jz,     KVE)
     $           -VMV (jh, jz - 1, KVE)) / DZ (jz - 1)
            TD = (VMV (jh, jz - 1, KVE) * ZT (jz)
     $           -VMV (jh, jz,     KVE) * ZT (jz - 1))    / DZ (jz - 1)
            TALP = TA * TC
            TBET = TA * TD + TB * TC
            TGAM = TB * TD
            TDLT = W (jh)
            VMD (jh, KDRFII) = VMD (jh, KDRFII)
     $           + (  TALP * GG (1 + jz0, 2, 0, _DGG)
     $              + TBET * GG (1 + jz0, 1, 0, _DGG)
     $              + TGAM * GG (1 + jz0, 0, 0, _DGG))
     $           - (  TALP * GG (jz0, 2, 0, _IG)
     $              + TBET * GG (jz0, 1, 0, _IG)
     $              + TGAM * GG (jz0, 0, 0, _IG) - TDLT)
     $           * DZ (jz - 1)
            W (jh) = TDLT
     $           + ( TALP * GG (1 + jz0, 2, 0, _DG)
     $             + TBET * GG (1 + jz0, 1, 0, _DG)
     $             + TGAM * GG (1 + jz0, 0, 0, _DG))
         enddo
      enddo
      RETURN
      END
CCC_ & MIFsvh  ## SIA horizontal velocity (without basal velocity)
      subroutine MIFsvh
     O    (VMV,
     M     W,
     I     VMVT,  VMI,  VMID,
     I     KVV,   KWBS, KWC,
     I     KTRFI, KIH,  KDBN,
     I     NH,    LH,   NZ,   LZ, KZ0)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  NH,  LH, NZ, LZ, KZ0
      _INTENT(OUT,  _REALSTD) VMV  (LH, LZ, *)
      _INTENT(INOUT,_REALSTD) W    (LH, *)
      _INTENT(IN,   _REALSTD) VMVT (LH, LZ, *)
      _INTENT(IN,   _REALSTD) VMID (LH, *)
      _INTENT(IN,   _REALSTD) VMI  (LH, *)
      _INTENT(IN,   integer)  KVV,   KWBS, KWC
      _INTENT(IN,   integer)  KTRFI, KIH,  KDBN
      integer jh, jz, jz0
CCC_  - Body
      do jh = 1, NH
         W (jh, KWC)  = 2.0d0 * W (jh, KWBS) * VMID (jh, KDBN)
     $        * VMI (jh, KIH)
      enddo
      do jz0 = 0, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, NH
            VMV (jh, jz, KVV) = W (jh, KWC) * VMVT (jh, jz, KTRFI)
         enddo
      enddo
c$$$      do jh = NH/3, NH/3
c$$$         do jz = KZ0, KZ0 + NZ - 1
c$$$            write (*, *) 'SVH',
c$$$     $           jh, jz, VMV (jh, jz, KVV), VMVT (jh, jz, KTRFI)
c$$$         enddo
c$$$      enddo
      RETURN
      END
CCC_ & MIFsdv  ## SIA horizontal velocity and dzeta integ D (without basal velocity)
      subroutine MIFsdv
     O    (VMV,
     M     VMW,
     I     VMI,   VMID,
     I     KVV,   KWZIDI, KWSS,
     I     KTRFI, KTRFII, KIH,  KDBN,
     I     DENS,  GRAV,
     I     NH,    LH,     NZ,   LZ, KZ0)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  NH,  LH, NZ, LZ, KZ0
      _INTENT(OUT,  _REALSTD) VMV  (LH, LZ, *)
      _INTENT(INOUT,_REALSTD) VMW  (LH, LZ, *)
      _INTENT(IN,   _REALSTD) VMID (LH, *)
      _INTENT(IN,   _REALSTD) VMI  (LH, *)
      _INTENT(IN,   _REALSTD) DENS,   GRAV
      _INTENT(IN,   integer)  KVV
      _INTENT(IN,   integer)  KWZIDI,KWSS
      _INTENT(IN,   integer)  KTRFI, KTRFII, KIH,  KDBN
      integer jh, jz, jz0
      _REALSTD C
CCC_  - Body
CCC_   + temporary
      do jh = 1, NH
         VMW (jh, KZ0, KWZIDI)
     $        = 2.0d0 * VMW (jh, KZ0, KWSS) * VMID (jh, KDBN)
     $          * VMI (jh, KIH)
      enddo
      do jz0 = 0, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, NH
            VMV (jh, jz, KVV)
     $           = VMW (jh, KZ0, KWZIDI) * VMW (jh, jz, KTRFI)
         enddo
      enddo
CCC_   . temporary (cf. MIFpdc)
      C = - 2.0d0 * DENS * GRAV
      do jh = 1, NH
         VMW (jh, KZ0, KWZIDI) =
     $        ((C * VMI (jh, KIH)) * VMID (jh, KDBN)
     $          * VMI (jh, KIH) * VMI (jh, KIH))
      enddo
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, NH
            VMW (jh, jz, KWZIDI)
     $           = VMW (jh, KZ0, KWZIDI) * VMW (jh, jz, KTRFII)
         enddo
      enddo
c$$$      do jh = NH/3, NH/3
c$$$         do jz = KZ0, KZ0 + NZ - 1
c$$$            write (*, *) 'SVH',
c$$$     $           jh, jz, VMV (jh, jz, KVV), VMVT (jh, jz, KTRFI)
c$$$         enddo
c$$$      enddo
      RETURN
      END
CCC_ & MIFsvv  ## SIA horizontal velocity and dzeta integ (without basal velocity)
      subroutine MIFsvv
     O    (VMV,
     M     VMW,
     I     VMI,   VMID,
     I     KVV,   KWZIVI, KWSS,
     I     KTRFI, KTRFII, KIH,  KDBN,
     I     NH,    LH,     NZ,   LZ, KZ0)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  NH,  LH, NZ, LZ, KZ0
      _INTENT(OUT,  _REALSTD) VMV  (LH, LZ, *)
      _INTENT(INOUT,_REALSTD) VMW  (LH, LZ, *)
      _INTENT(IN,   _REALSTD) VMID (LH, *)
      _INTENT(IN,   _REALSTD) VMI  (LH, *)
      _INTENT(IN,   integer)  KVV
      _INTENT(IN,   integer)  KWZIVI,KWSS
      _INTENT(IN,   integer)  KTRFI, KTRFII, KIH,  KDBN
      integer jh, jz, jz0
CCC_  - Body
CCC_   + temporary
      do jh = 1, NH
         VMW (jh, KZ0, KWZIVI)
     $        = 2.0d0 * VMW (jh, KZ0, KWSS) * VMID (jh, KDBN)
     $          * VMI (jh, KIH)
      enddo
      do jz0 = 0, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, NH
            VMV (jh, jz, KVV)
     $           = VMW (jh, KZ0, KWZIVI) * VMW (jh, jz, KTRFI)
         enddo
      enddo
      do jz0 = 1, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, NH
            VMW (jh, jz, KWZIVI)
     $           = VMW (jh, KZ0, KWZIVI) * VMW (jh, jz, KTRFII)
         enddo
      enddo
c$$$      do jh = NH/3, NH/3
c$$$         do jz = KZ0, KZ0 + NZ - 1
c$$$            write (*, *) 'SVH',
c$$$     $           jh, jz, VMV (jh, jz, KVV), VMVT (jh, jz, KTRFI)
c$$$         enddo
c$$$      enddo
      RETURN
      END
CCC_ & MIFhvi  ## SIA velocity integral by z (without basal velocity)
      subroutine MIFhvi
     M    (VMV,
     M     W,
     I     VMI,    VMID,
     I     KVVIH,  KWBS, KWC,
     I     KTRFII, KIH,  KDBN,
     I     NH,     LH,   NZ,   LZ, KZ0)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  NH,  LH, NZ, LZ, KZ0
      _INTENT(INOUT,_REALSTD) VMV  (LH, LZ, *)
      _INTENT(INOUT,_REALSTD) W    (LH, *)
      _INTENT(IN,   _REALSTD) VMID (LH, *)
      _INTENT(IN,   _REALSTD) VMI  (LH, *)
      _INTENT(IN,   integer)  KVVIH,  KWBS, KWC
      _INTENT(IN,   integer)  KTRFII, KIH,  KDBN
      integer jh, jz, jz0
CCC_  - Body
      do jh = 1, NH
         W (jh, KWC)  = 2.0d0 * W (jh, KWBS) * VMID (jh, KDBN)
     $        * VMI (jh, KIH) * VMI (jh, KIH)
c$$$     $        * VMI (jh, KIH) * VMI (jh, KIH) * VMI (jh, KIH)
      enddo
      do jz0 = 0, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, NH
c$$$            write (*, *) jh, jz, W (jh, KWC), VMVT (jh, jz, KTRFII)
            VMV (jh, jz, KVVIH) = W (jh, KWC) * VMV (jh, jz, KTRFII)
         enddo
      enddo
      RETURN
      END
CCC_ & MIFvin  ## SIA velocity integral by zeta (without basal velocity)
      subroutine MIFvin
     M    (VMV,
     M     W,
     I     VMI,    VMID,
     I     KVVIN,  KWBS, KWC,
     I     KTRFII, KIH,  KDBN,
     I     NH,     LH,   NZ,   LZ, KZ0)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  NH,  LH, NZ, LZ, KZ0
      _INTENT(INOUT,_REALSTD) VMV  (LH, LZ, *)
      _INTENT(INOUT,_REALSTD) W    (LH, *)
      _INTENT(IN,   _REALSTD) VMID (LH, *)
      _INTENT(IN,   _REALSTD) VMI  (LH, *)
      _INTENT(IN,   integer)  KVVIN,  KWBS, KWC
      _INTENT(IN,   integer)  KTRFII, KIH,  KDBN
      integer jh, jz, jz0
CCC_  - Body
      do jh = 1, NH
         W (jh, KWC)  = 2.0d0 * W (jh, KWBS) * VMID (jh, KDBN)
     $        * VMI (jh, KIH)
      enddo
      do jz0 = 0, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, NH
            VMV (jh, jz, KVVIN) = W (jh, KWC) * VMV (jh, jz, KTRFII)
         enddo
      enddo
      RETURN
      END
c$$$CCC_ & MIFivh  ## velocity integral (without basal velocity)
c$$$      subroutine MIFivh
c$$$     M    (VMV,
c$$$     W     W,
c$$$     I     VMI,  VMID,
c$$$     I     KVVI, KVRFII, KIH, KDBN, KDBS,
c$$$     I     NH,   LH,     NZ,  LZ,   KZ0)
c$$$      implicit none
c$$$      _INTENT(IN,   integer)  NH,  LH, NZ, LZ, KZ0
c$$$      _INTENT(OUT,  _REALSTD) W (*)
c$$$      _INTENT(INOUT,_REALSTD) VMV  (LH, LZ,*)
c$$$      _INTENT(IN,   _REALSTD) VMID (LH, *)
c$$$      _INTENT(IN,   _REALSTD) VMI  (LH, *)
c$$$      _INTENT(IN,   integer)  KVVI,  KVRFII
c$$$      _INTENT(IN,   integer)  KDBS,  KDBN
c$$$      _INTENT(IN,   integer)  KIH
c$$$      integer jh, jz, jz0
c$$$      do jh = 1, NH
c$$$         W (jh)  = 2.0d0 * VMID (jh, KDBN)
c$$$     $        * VMID (jh, KDBS) * VMI (jh, KIH) * VMI (jh, KIH)
c$$$      enddo
c$$$      do jz0 = 0, NZ - 1
c$$$         jz = KZ0 + jz0
c$$$         do jh = 1, NH
c$$$            VMV (jh, jz, KVVI) = W (jh) * VMV (jh, jz, KVRFII)
c$$$         enddo
c$$$      enddo
c$$$      RETURN
c$$$      END
c$$$CCC_ & MIFhui  ## SIA u integral times H (without basal velocity)
c$$$      subroutine MIFhui
c$$$     O    (VMV,
c$$$     I     VMI,
c$$$     I     KVHU,
c$$$     I     KVVI, KIH,
c$$$     I     NH,   LH,   NZ,  LZ, KZ0)
c$$$CCC_  - Declaration
c$$$      implicit none
c$$$      _INTENT(IN,   integer)  NH,  LH, NZ, LZ, KZ0
c$$$      _INTENT(INOUT,_REALSTD) VMV (LH, LZ, *)
c$$$      _INTENT(IN,   _REALSTD) VMI (LH, *)
c$$$      _INTENT(IN,   integer)  KVHU
c$$$      _INTENT(IN,   integer)  KVVI
c$$$      _INTENT(IN,   integer)  KIH
c$$$      integer jh, jz, jz0
c$$$CCC_  - Body
c$$$      do jz0 = 0, NZ - 1
c$$$         jz = KZ0 + jz0
c$$$         do jh = 1, NH
c$$$            VMV (jh, jz, KVHU) = VMI (jh, KIH) * VMV (jh, jz, KVVI)
c$$$         enddo
c$$$      enddo
c$$$      RETURN
c$$$      END
CCC_ & MIFzsa  ## 3d Z coordinate (b,H)
      subroutine MIFzsa
     M    (VMV,
     I     VMI,  ZT,
     I     KVZS,
     I     KIH,  KIB,
     I     NH,   LH,   NZ,  LZ, KZ0)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  NH,  LH, NZ, LZ, kZ0
      _INTENT(INOUT,_REALSTD) VMV (LH, LZ, *)
      _INTENT(IN,   _REALSTD) VMI (LH, *)
      _INTENT(IN,   _REALSTD) ZT  (LZ)
      _INTENT(IN,   integer)  KVZS
      _INTENT(IN,   integer)  KIH, KIB
      integer jh, jz, jz0
CCC_  - Body
      do jz0 = 0, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, NH
            VMV (jh, jz, KVZS)
     $           = VMI (jh, KIB) + VMI (jh, KIH) * ZT (jz)
         enddo
      enddo
      RETURN
      END
CCC_ & MIFzsb  ## 3d Z coordinate (s,H)
      subroutine MIFzsb
     O    (VMV,
     I     VMD,  ZC,
     I     KVZS,
     I     KDH,  KDS,
     I     NH,   LH,   NZ,  LZ, KZ0)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  NH,  LH, NZ, LZ, KZ0
      _INTENT(INOUT,_REALSTD) VMV (LH, LZ, *)
      _INTENT(IN,   _REALSTD) VMD (LH, *)
      _INTENT(IN,   _REALSTD) ZC  (NZ)
      _INTENT(IN,   integer)  KVZS
      _INTENT(IN,   integer)  KDH, KDS
      integer jh, jz, jz0
CCC_  - Body
      do jz0 = 0, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, NH
            VMV (jh, jz, KVZS)
     $           = VMD (jh, KDS) - VMD (jh, KDH) * ZC (jz)
         enddo
      enddo
      RETURN
      END
CCC_ & MIFzsu  ## 3d Z coordinate times u
      subroutine MIFzsu
     O    (VMV,
     I     KVZSU,
     I     KVV,  KVZS,
     I     NH,   LH,   NZ,  LZ, KZ0)
CCC_  - Declaration
      implicit none
      _INTENT(IN,   integer)  NH,  LH, NZ, LZ, kZ0
      _INTENT(INOUT,_REALSTD) VMV (LH, LZ, *)
      _INTENT(IN,   integer)  KVZSU
      _INTENT(IN,   integer)  KVZS, KVV
      integer jh, jz, jz0
CCC_  - Body
      do jz0 = 0, NZ - 1
         jz = KZ0 + jz0
         do jh = 1, NH
            VMV (jh, jz, KVZSU) = VMV (jh, jz, KVV) * VMV (jh, jz, KVZS)
         enddo
      enddo
      RETURN
      END
CCC_* vertical geometry
CCC_ & MIFvgt  ## geometry and integral table
      subroutine MIFvgt
     O    (iErr,
     O     VZ,
     I     KZa, KCZa,  KDZb, KCNZa,
     I     PF,
     I     LZ,  icZa,  icZb, IFP)
      implicit none
      _INTENT(OUT,integer)  iErr
      _INTENT(IN, integer)  LZ
      _INTENT(OUT,_REALSTD) VZ (LZ, *)
      _INTENT(IN, integer)  KZa,   KCZa,  KDZb,  KCNZa
      _INTENT(IN, _REALSTD) PF
      _INTENT(IN, integer)  icZa,  icZb
      _INTENT(IN, integer)  IFP
      integer jcdmy, jz
      iErr  = 0
      if (iErr.eq.0) then
         call ACCchD (iErr, jcdmy,               icZa,     'CP', IFP)
      endif
      if (iErr.eq.0) then
         call ACCrfD (iErr, jcdmy, VZ (1, KZa),  icZa, -1, 'CP', IFP)
      endif
      if (iErr.eq.0) then
         call ACCchD (iErr, jcdmy,               icZb,     'DP', IFP)
      endif
      if (iErr.eq.0) then
         call ACCrfD (iErr, jcdmy, VZ (1, KDZb), icZb, -1, 'DP', IFP)
      endif
      if (iErr.eq.0) then
         do jz = 1, LZ
            VZ (jz, KCZa)  =  1.0d0 - VZ (jz, KZa)
         enddo
         do jz = 1, LZ
            VZ (jz, KCNZa) =  (1.0d0 - VZ (jz, KZa)) ** PF
         enddo
      endif
      RETURN
      END
CCC_& MIFUNC  ## Movement/SIA/f announcement
      subroutine MIFUNC (STRA, STRB, IOP)
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
CCC_ @ MIFTST  ## test program
#if TEST_MIFUNC
      program MIFTST
CCC_  - Test suites
CC::   KINDS 1
CC::   SOURCES mppmth.F mprtft.F mpenhf.F
CCC_  - Declaration
      implicit none
#include "ofnstd.h"
#include "odevid.h"
      integer iErr
      integer ipA (LOG_CHANNEL_MAX)
      integer iMA (MAX_MPI_ATTR)
CCC_  - Body
      call DDcapo
     O    (iErr,
     I     2, ' ', 'O', _FNAME, -1)
      if (iErr.eq.0) then
         call DLCmng (ipA, 't')
         call DMAtma (iMA)
#if   TEST_MIFUNC == 1
         call MIFTST_rfii (iErr, ipA)
#endif
c$$$         call ACCrep (FPL(ipA), 0)
         call ACCrep (FPL(ipA), 2)
      endif
      call DevFin (iErr)
      STOP
      END
CCC_ & MIFTST_rfii  ## rate factor double integral test
      subroutine MIFTST_rfii (iErr, ipA)
#include "movement.h"
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)  iErr
      _INTENT(IN, integer)  ipA (*)
CCC_   . Vertical layers
      integer    LZref
      parameter (LZref = 256 + 1)
      integer    NZdef
      integer    NZ,  LZ
      integer    KZ0, IZT, IZB, NZX
      _REALSTD VMZ (LZref, VMVZ_MAX)
      integer  icGz (2), icZa, icZb
CCC_   . Horizontal
      integer    LH
      parameter (LH = 2)
      integer    NH
CCC_   . Coordinate
      character  CROOT*(32)
CCC_   . work area
      integer    LW
      parameter (LW = 512)
      _REALSTD W(LW)
CCC_   . i/o
      integer ipL, ipP, ipC
CCC_   . misc
c$$$      integer icV
      integer jh, jz, jz0
      integer KVZ
CCC_   . rate factors
      _REALSTD CEF, CRF, PF
      _REALSTD TB, TS, H0
      integer    LVG0
      parameter (LVG0 = 1)
      _REALSTD VG0 (LH, LVG0)
#define VG1_H0   1
      integer    LVG1
      parameter (LVG1 = 1)
      _REALSTD VG1 (LH, LVG1)
#define VG2_A    1
#define VG2_E    2
#define VG2_I    3
#define VG2_II   4
#define VG2_T    5
#define VG2_TH   6
#define VG2_MISC 7
#define VG2_MAX  7
      integer    LVG2
      parameter (LVG2 = VG2_MAX)
      _REALSTD   VG2 (LH, LZref, LVG2)
c
      integer    NTH,     NTH1
      parameter (NTH = 2, NTH1 = NTH + 1)
      _REALSTD   GG  (LZref * 4 * NTH1 * NTH1)
c
      integer   icF
      integer   jedmy, jcdmy
CCC_  - Body
      iErr  = 0
c
      ipL = FPL(ipA)
      ipP = FPP(ipA)
      ipC = FPC(ipA)
CCC_   . domain configuration
      CROOT   = 'ID'
      NH      = 1
c
      NZdef   = 8 + 1
      IZT     = 1
      IZB     = 1
c
      call ACCrgR (jedmy, icF, 0, CROOT, ipL)
c
      call AMZcns
     O    (iErr,
     W     W,     LW,
     O     NZ,    LZ,    KZ0,
     I     NZdef, LZref, IZB, IZT,  icF, CROOT, ipP, ipC, ipL)
      call ACCrfI (jedmy, jcdmy, icGZ, icF, -1, 'Z', ipL)
      icZa = icGZ (1)
      icZb = icGZ (2)
c     force overwrite
      LZ  = LZref
      NZX = KZ0 + NZ
c$$$      if (iErr.eq.0) call ACCchD (iErr, icV,  icZZa, 'CO', ipL)
c$$$      if (iErr.eq.0) then
c$$$         call ACCrfD (iErr, icV, VMZ (1, VMZ_Za), icZZa, -1, 'CO', ipL)
c$$$      endif
c$$$      if (iErr.eq.0) call ACCchD (iErr, icV,  icZZb, 'DC', ipL)
c$$$      if (iErr.eq.0) then
c$$$         call ACCrfD (iErr, icV, VMZ (1, VMZ_DZb), icZZb, -1, 'DC', ipL)
c$$$      endif
c$$$      do jz = 1, NZX
c$$$         VMZ (jz, VMZ_CZa) =  1.0d0 - VMZ (jz, VMZ_Za)
c$$$      enddo
      PF  = 3.0d0
      call MIFvgt
     O    (iErr,
     O     VMZ,
     I     VMVZ_Za, VMVZ_cZa,  VMVZ_dZb, VMVZ_cZaN,
     I     PF,
     I     LZ,      icZa,      icZb,     ipL)
c
 102  format ('ZRANGE:', 4I4)
      write (ipL, 102) NZ, LZ, KZ0, NZX
 101  format ('ZCHK:', I3.3, 1x, 2F10.6)
      do jz = 1, NZX
         write (ipL, 101) jz, VMZ (jz, VMVZ_Za), VMZ (jz, VMVZ_dZb)
      enddo
CCC_   . test main
 201  format ('RF/VG', I1, ':', I3.3, 1x, 2E24.16)
CCC_    * constant rate factor
      CEF = 1.0d0
      CRF = 1.0d-16
      KVZ = 1
      call MIFgst
     $     (GG, VMZ, NZ, LZ, KZ0, VMVZ_Za, NTH, PF)
CCC_     + crw
      call MIFcrw (VG0, CRF,  CEF, PF, KVZ, NH, LH)
      do jh = 1, NH
         write (ipL, 201) 0, jh, VG0 (jh, 1)
      enddo
CCC_     + cri
      KVZ = VG2_I
      call MIFcri
     O    (VG2,
     I     VMZ (1, VMVZ_Za),
     I     CRF,  CEF, PF, KVZ,  NH, LH, NZ, LZ, KZ0)
      call MIFcro
     O    (VG2,
     I     VMZ (1, VMVZ_Za),
     I     CRF,  CEF, PF, VG2_II, NH, LH, NZ, LZ, KZ0)
      do jh = 1, NH
         do jz0 = 0, NZ - 1
            jz = jz0 + KZ0
            write (ipL, 201) 0, jz,
     $           VG2 (jh, jz, VG2_II), VG2 (jh, jz, KVZ)
         enddo
      enddo
CCC_     + integration check
      H0 = 1000.0d0
      do jh = 1, NH
         VG1 (jh, VG1_H0) = H0
      enddo
      do jz0 = 0, NZ - 1
         jz = jz0 + KZ0
         do jh = 1, NH
            VG2 (jh, jz, VG2_A) = CRF
            VG2 (jh, jz, VG2_E) = CEF
         enddo
      enddo
      call MIFTST_rfii_sub
     $     (iErr,W,VG2,VG1,PF,GG,VMZ,kz0,NH,LH,NZ,LZ,NTH, 'C', ipL)
CCC_    * linear A
      do jz0 = 0, NZ - 1
         jz = jz0 + KZ0
         do jh = 1, NH
            VG2 (jh, jz, VG2_A) =
     $           CRF * (1.0d0 - VMZ (jz, VMVZ_Za) / 2.0d0)
            VG2 (jh, jz, VG2_E) = CEF
         enddo
      enddo
      call MIFTST_rfii_sub
     $     (iErr,W,VG2,VG1,PF,GG,VMZ,kz0,NH,LH,NZ,LZ,NTH, 'L', ipL)
CCC_    * linear A, E
      do jz0 = 0, NZ - 1
         jz = jz0 + KZ0
         do jh = 1, NH
            VG2 (jh, jz, VG2_A) =
     $           CRF * (1.0d0 - VMZ (jz, VMVZ_Za) / 2.0d0)
            VG2 (jh, jz, VG2_E) =
     $           CEF * (1.0d0 - VMZ (jz, VMVZ_Za) / 2.0d0)
         enddo
      enddo
      call MIFTST_rfii_sub
     $     (iErr,W,VG2,VG1,PF,GG,VMZ,kz0,NH,LH,NZ,LZ,NTH, 'W', ipL)
CCC_    * constant T
      TS = 270.0d0
      TB = 270.0d0
      H0 = 1000.0d0
      do jz0 = 0, NZ - 1
         jz = jz0 + KZ0
         do jh = 1, NH
            VG2 (jh, jz, VG2_E) = CEF
            VG2 (jh, jz, VG2_T) = TB + (TS - TB) * VMZ (jz, VMVZ_Za)
         enddo
      enddo
c$$$      VG2 (VG2_H0, VG2_MISC) = H0
      call MIFTST_rfii_sub
     $     (iErr,W,VG2,VG1,PF,GG,VMZ,kz0,NH,LH,NZ,LZ,NTH, 'TC', ipL)
CCC_    * linear T
      TS = 240.0d0
      TB = 270.0d0
      H0 = 1000.0d0
      do jz0 = 0, NZ - 1
         jz = jz0 + KZ0
         do jh = 1, NH
            VG2 (jh, jz, VG2_E) = CEF
            VG2 (jh, jz, VG2_T) = TB + (TS - TB) * VMZ (jz, VMVZ_Za)
         enddo
      enddo
      call MIFTST_rfii_sub
     $     (iErr,W,VG2,VG1,PF,GG,VMZ,kz0,NH,LH,NZ,LZ,NTH, 'TL', ipL)
CCC_    * end
      RETURN
      END
CCC_ & MIFTST_rfii_sub  ## check suite
CCC_  - Declaration
      subroutine MIFTST_rfii_sub
     O    (iErr,
     W     W,
     M     VG2,
     I     VG1, PF,  GG,  VMZ,
     I     KZ0, NH,  LH,  NZ,  LZ, NTH, TAG, IFP)
      implicit none
      _INTENT(OUT,  integer)   iErr
      _INTENT(IN,   integer)   KZ0, NH, LH, NZ, LZ, NTH
      _INTENT(OUT,  _REALSTD)  W (*)
      _INTENT(IN,   _REALSTD)  VG1 (LH, *)
      _INTENT(INOUT,_REALSTD)  VG2 (LH, LZ, *)
      _INTENT(IN,   _REALSTD)  PF
      _INTENT(IN,   _REALSTD)  GG  (NZ, 0:NTH, 0:NTH, 4)
      _INTENT(IN,   _REALSTD)  VMZ (LZ, VMVZ_MAX)
      _INTENT(IN,   character) TAG*(*)
      _INTENT(IN,   integer)   IFP
c
      integer    KVZ, KVE, KVA, KVT, KVH, KVTH
      integer    jh,  jz,  jz0
      _REALSTD   PGP (2), PGR (6)
c
      _REALSTD   VER (LH), VOW (LH)
CCC_  - Body
      iErr = 0
      if (TAG (1:1).eq.'T') then
         call MPPstp (iErr, PGP, 0, 'DEF', -1, IFP, IFP)
         call MPRstp (iErr, PGR, 0, 'DEF', -1, IFP, IFP)
         KVZ = VG2_TH
         KVT = VG2_T
         KVH = VG1_H0
         call MPPtcr
     $       (VG2,  VG1, VMZ (1, VMVZ_cZa),PGP,
     $        KVZ,  KVT, KVH, NH, LH, NZ, LZ, KZ0)
         KVZ  = VG2_A
         KVTH = VG2_TH
         call MPRprA
     M       (VG2,
     I        PGR,
     I        KVZ,  KVTH, NH, LH, NZ, LZ, KZ0)
      endif
c
      call MIFerw
     $    (VER, W, VG2 (1, KZ0, VG2_A), VG2(1, KZ0, VG2_E), PF,
     $     VMZ (KZ0, VMVZ_Za), VMZ (KZ0, VMVZ_dZb), NH, LH, NZ)
c
      KVZ = VG2_I
      KVA = VG2_A
      KVE = VG2_E
      call MIFgii
     O    (VG2,
     I     GG,   VMZ (1, VMVZ_Za), VMZ (1, VMVZ_dZb),
     I     KVZ,  KVE, KVA, NH, LH, NZ, LZ, KZ0, NTH)
      KVZ = VG2_II
      call MIFgio
     O    (VG2,
     I     GG,   VMZ (1, VMVZ_Za), VMZ (1, VMVZ_dZb),
     I     KVZ,  KVE, KVA, NH, LH, NZ, LZ, KZ0, NTH)
c
      KVZ = 1
      call MIFgiw
     O    (VOW,  W,
     I     VG2,
     I     GG,   VMZ (1, VMVZ_Za), VMZ (1, VMVZ_dZb),
     I     KVZ,  KVE, KVA, NH, LH, NZ, LZ, KZ0, NTH)
c
 201  format ('RF/VG/', A, ':', I1, ':', I1, ':', I3.3,
     $     1x, 4E24.16, 2F8.3)
      do jz0 = 0, NZ - 1
         jz = jz0 + KZ0
         do jh = 1, NH
            write (IFP, 201) _TRIM(TAG), 2, jh, jz,
     $           VG2 (jh, jz, VG2_II), VG2 (jh, jz, VG2_I),
     $           VG2 (jh, jz, VG2_A),  VG2 (jh, jz, VG2_E),
     $           VG2 (jh, jz, VG2_TH), VG2 (jh, jz, VG2_T)
         enddo
      enddo
      do jh = 1, NH
         write (IFP, 201) _TRIM(TAG), 3, jh, 0, VOW (jh)
      enddo
      do jh = 1, NH
         write (IFP, 201) _TRIM(TAG), 1, jh, 0, VER (jh)
      enddo
c
      RETURN
      END
#endif /* TEST_MIFUNC */
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
