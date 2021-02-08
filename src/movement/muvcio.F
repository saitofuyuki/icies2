C movement/muvcio.F --- IcIES/Movement/Utility variable cluster
C Maintainer:  SAITO Fuyuki
C Created: Oct 3 2012
#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif
#define _TSTAMP 'Time-stamp: <2021/02/08 11:01:44 fuyuki muvcio.F>'
#define _FNAME 'movement/muvcio.F'
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
CCC_* Common macros
#include "ofdlct.h"   /* fortran dialect */
#include "oarpea.h"
#include "oarpkw.h"   /* operation id in arpeggio/kiwi */
#include "odevva.h"
#include "movement.h" /* movement definitions */
CCC_* Set attributes
CCC_ & MUVrgd  ## variable cluster group default register
      subroutine MUVrgd
     O    (iErr,
     O     idGM,
     I     icF,  MH,  LH, NZ,   LZ,  KZ0,
     I     CSW,  CLS, CR, ipFI, IE,  iMA)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   idGM (*)
      _INTENT(IN, integer)   icF
      _INTENT(IN, integer)   MH, LH, NZ, LZ, KZ0
      _INTENT(IN, character) CSW*(*)
      _INTENT(IN, character) CLS*(*), CR*(*)
      _INTENT(IN, integer)   ipFI (*)
      _INTENT(IN, integer)   IE  (*), iMA (*)
      if (iErr.eq.0) then
         call MUVmng
     O       (iErr, idGM,
     I        'VMHB',
     I        icF,  MH,  LH, 0,    0,  0,
     I        CSW,  CLS, CR, ipFI, IE, iMA)
      endif
      if (iErr.eq.0) then
         call MUVmng
     O       (iErr, idGM,
     I        'VMHR',
     I        icF,  MH,  LH, 0,    0,  0,
     I        CSW,  CLS, CR, ipFI, IE, iMA)
      endif
      if (iErr.eq.0) then
         call MUVmng
     O       (iErr, idGM,
     I        'VMQ',
     I        icF,  MH,  LH, 0,    0,  0,
     I        CSW,  CLS, CR, ipFI, IE, iMA)
      endif
      if (iErr.eq.0) then
         call MUVmng
     O       (iErr, idGM,
     I        'VMX',
     I        icF,  MH,  LH, 0,    0,  0,
     I        CSW,  CLS, CR, ipFI, IE, iMA)
      endif
      if (iErr.eq.0) then
         call MUVmng
     O       (iErr, idGM,
     I        'VMHW',
     I        icF,  MH,  LH, 0,    0,  0,
     I        CSW,  CLS, CR, ipFI, IE, iMA)
      endif
      if (iErr.eq.0) then
         call MUVmng
     O       (iErr, idGM,
     I        'VMHI',
     I        icF,  MH,  LH, 0,    0,  0,
     I        CSW,  CLS, CR, ipFI, IE, iMA)
      endif
      if (iErr.eq.0) then
         call MUVmng
     O       (iErr, idGM,
     I        'VMI',
     I        icF,  MH,  LH, 0,    0,  0,
     I        CSW,  CLS, CR, ipFI, IE, iMA)
      endif
      if (iErr.eq.0) then
         call MUVmng
     O       (iErr, idGM,
     I        'VMC',
     I        icF,  MH,  LH, 0,    0,  0,
     I        CSW,  CLS, CR, ipFI, IE, iMA)
      endif
      if (iErr.eq.0) then
         call MUVmng
     O       (iErr, idGM,
     I        'VMID',
     I        icF,  MH,  LH, 0,    0,  0,
     I        CSW,  CLS, CR, ipFI, IE, iMA)
      endif
      if (iErr.eq.0) then
         call MUVmng
     O       (iErr, idGM,
     I        'VMIW',
     I        icF,  MH,  LH, 0,    0,  0,
     I        CSW,  CLS, CR, ipFI, IE, iMA)
      endif
      if (iErr.eq.0) then
         call MUVmng
     O       (iErr, idGM,
     I        'VMTI',
     I        icF,  MH,  LH, NZ,   LZ, KZ0,
     I        CSW,  CLS, CR, ipFI, IE, iMA)
      endif
      if (iErr.eq.0) then
         call MUVmng
     O       (iErr, idGM,
     I        'VMTW',
     I        icF,  MH,  LH, NZ,   LZ, KZ0,
     I        CSW,  CLS, CR, ipFI, IE, iMA)
      endif
      if (iErr.eq.0) then
         call MUVmng
     O       (iErr, idGM,
     I        'VMSC',
     I        icF,  MH,  LH, 0,    0,  0,
     I        CSW,  CLS, CR, ipFI, IE, iMA)
      endif
      if (iErr.eq.0) then
         call MUVmng
     O       (iErr, idGM,
     I        'VMSV',
     I        icF,  MH,  LH, 0,    0,  0,
     I        CSW,  CLS, CR, ipFI, IE, iMA)
      endif
      if (iErr.eq.0) then
         call MUVmng
     O       (iErr, idGM,
     I        'VMSN',
     I        icF,  MH,  LH, 0,    0,  0,
     I        CSW,  CLS, CR, ipFI, IE, iMA)
      endif
      if (iErr.eq.0) then
         call MUVmng
     O       (iErr, idGM,
     I        'VMST',
     I        icF,  MH,  LH, 0,    0,  0,
     I        CSW,  CLS, CR, ipFI, IE, iMA)
      endif
      if (iErr.eq.0) then
         call MUVmng
     O       (iErr, idGM,
     I        'VMSX',
     I        icF,  MH,  LH, 0,    0,  0,
     I        CSW,  CLS, CR, ipFI, IE, iMA)
      endif
      if (iErr.eq.0) then
         call MUVmng
     O       (iErr, idGM,
     I        'VMSXI',
     I        icF,  MH,  LH, 0,    0,  0,
     I        CSW,  CLS, CR, ipFI, IE, iMA)
      endif
      if (iErr.eq.0) then
         call MUVmng
     O       (iErr, idGM,
     I        'VMSXT',
     I        icF,  MH,  LH, 0,    0,  0,
     I        CSW,  CLS, CR, ipFI, IE, iMA)
      endif
      if (iErr.eq.0) then
         call MUVmng
     O       (iErr, idGM,
     I        'VMTA',
     I        icF,  MH,  LH, NZ,   LZ, KZ0,
     I        CSW,  CLS, CR, ipFI, IE, iMA)
      endif
      if (iErr.eq.0) then
         call MUVmng
     O       (iErr, idGM,
     I        'VMTD',
     I        icF,  MH,  LH, NZ,   LZ, KZ0,
     I        CSW,  CLS, CR, ipFI, IE, iMA)
      endif
      RETURN
      END
CCC_ & MUVmng  ## variable cluster group manager
      subroutine MUVmng
     O    (iErr, idGM,
     I     CGRP,
     I     icF,  MH,  LH,  NZ,   LZ, KZ0,
     I     CSW,  CLS, CRT, IFPa, IE, iMA)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   idGM (*)
      _INTENT(IN, integer)   icF
      _INTENT(IN, integer)   MH, LH
      _INTENT(IN, integer)   NZ, LZ, KZ0
      _INTENT(IN, character) CGRP*(*)
      _INTENT(IN, character) CSW*(*)
      _INTENT(IN, character) CLS*(*), CRT*(*)
      _INTENT(IN, integer)   IFPa (*)
      _INTENT(IN, integer)   IE  (*)
      _INTENT(IN, integer)   iMA (*)
      integer jg
      integer icGH (4)
      integer icGT (16)
      integer jedmy, jcdmy
      integer jpL
      integer MZI
CCC_  - Body
      iErr = 0
c
      call AFUqip (jpL, 'L', IFPa)
c
      MZI = NZ + KZ0 - 1
c
      call ACCrfI (jedmy, jcdmy, icGH, icF, -1, 'H', jpL)
      call ACCrfI (jedmy, jcdmy, icGT, icF, -1, 'T', jpL)
c
      if (CGRP.eq.'VMHB') then
         call MUVmhb
     O       (iErr, jg,
     I        CGRP, icGH, MH, LH, CSW, CLS, CRT, IFPa, IE, iMA)
         if (iErr.eq.0) idGM (VGRP_VMHB) = jg
      else if (CGRP.eq.'VMHR') then
         call MUVmhr
     O       (iErr, jg,
     I        CGRP, icGH, MH, LH, CSW, CLS, CRT, IFPa, IE, iMA)
         if (iErr.eq.0) idGM (VGRP_VMHR) = jg
      else if (CGRP.eq.'VMQ') then
         call MUVvmq
     O       (iErr, jg,
     I        CGRP, icGH, MH, LH, CSW, CLS, CRT, IFPa, IE, iMA)
         if (iErr.eq.0) idGM (VGRP_VMQ) = jg
      else if (CGRP.eq.'VMX') then
         call MUVvmx
     O       (iErr, jg,
     I        CGRP, icGH, MH, LH, CSW, CLS, CRT, IFPa, IE, iMA)
         if (iErr.eq.0) idGM (VGRP_VMX) = jg
      else if (CGRP.eq.'VMHW') then
         call MUVmhw
     O       (iErr, jg,
     I        CGRP, icGH, MH, LH, CSW, CLS, CRT, IFPa, IE, iMA)
         if (iErr.eq.0) idGM (VGRP_VMHW) = jg
      else if (CGRP.eq.'VMHI') then
         call MUVmhi
     O       (iErr, jg,
     I        CGRP, icGH, MH, LH, CSW, CLS, CRT, IFPa, IE, iMA)
         if (iErr.eq.0) idGM (VGRP_VMHI) = jg
      else if (CGRP.eq.'VMI') then
         call MUVvmi
     O       (iErr, jg,
     I        CGRP, icGH, MH,   LH,   CSW,  CLS, CRT,
     I        IFPa, IE,   iMA)
         if (iErr.eq.0) idGM (VGRP_VMI) = jg
      else if (CGRP.eq.'VMC') then
         call MUVvmc
     O       (iErr, jg,
     I        CGRP, icGH, MH,   LH,   CSW,  CLS, CRT,
     I        IFPa, IE,   iMA)
         if (iErr.eq.0) idGM (VGRP_VMC) = jg
      else if (CGRP.eq.'VMID') then
         call MUVmid
     O       (iErr, jg,
     I        CGRP, icGH, MH,   LH,   CSW,  CLS, CRT,
     I        IFPa, IE,   iMA)
         if (iErr.eq.0) idGM (VGRP_VMID) = jg
      else if (CGRP.eq.'VMIW') then
         call MUVmiw
     O       (iErr, jg,
     I        CGRP, icGH, MH,   LH,   CSW,  CLS, CRT,
     I        IFPa, IE,   iMA)
         if (iErr.eq.0) idGM (VGRP_VMIW) = jg
      else if (CGRP.eq.'VMTI') then
         call MUVmti
     O       (iErr, jg,
     I        CGRP, icGT, MH,  LH, MZI, LZ, CSW,  CLS, CRT,
     I        IFPa, IE,   iMA)
         if (iErr.eq.0) idGM (VGRP_VMTI) = jg
      else if (CGRP.eq.'VMTW') then
         call MUVmtw
     O       (iErr, jg,
     I        CGRP, icGT, MH,  LH, MZI, LZ, CSW,  CLS, CRT,
     I        IFPa, IE,   iMA)
         if (iErr.eq.0) idGM (VGRP_VMTW) = jg
      else if (CGRP.eq.'VMSC') then
         call MUVmsc
     O       (iErr, jg,
     I        CGRP, icGH, MH,   LH,   CSW,  CLS, CRT,
     I        IFPa, IE,   iMA)
         if (iErr.eq.0) idGM (VGRP_VMSC) = jg
      else if (CGRP.eq.'VMSV') then
         call MUVmsv
     O       (iErr, jg,
     I        CGRP, icGH, MH,   LH,   CSW,  CLS, CRT,
     I        IFPa, IE,   iMA)
         if (iErr.eq.0) idGM (VGRP_VMSV) = jg
      else if (CGRP.eq.'VMSN') then
         call MUVswn
     O       (iErr, jg,
     I        CGRP, icGH, MH,   LH,   CSW,  CLS, CRT,
     I        IFPa, IE,   iMA)
         if (iErr.eq.0) idGM (VGRP_VMSN) = jg
      else if (CGRP.eq.'VMST') then
         call MUVswt
     O       (iErr, jg,
     I        CGRP, icGH, MH,   LH,   CSW,  CLS, CRT,
     I        IFPa, IE,   iMA)
         if (iErr.eq.0) idGM (VGRP_VMST) = jg
      else if (CGRP.eq.'VMSX') then
         call MUVmsx
     O       (iErr,   jg,
     I        CGRP,  .FALSE.,
     I        icGH,   MH, LH, CSW, CLS, CRT, IFPa, IE, iMA)
         if (iErr.eq.0) idGM (VGRP_VMSX) = jg
      else if (CGRP.eq.'VMSXI') then
         call MUVmsx
     O       (iErr,   jg,
     I        CGRP,  .TRUE.,
     I        icGH,   MH, LH, CSW, CLS, CRT, IFPa, IE, iMA)
         if (iErr.eq.0) idGM (VGRP_VMSXI) = jg
      else if (CGRP.eq.'VMSXT') then
         call MUVmsx
     O       (iErr,   jg,
     I        CGRP,  .TRUE.,
     I        icGH,   MH, LH, CSW, CLS, CRT, IFPa, IE, iMA)
         if (iErr.eq.0) idGM (VGRP_VMSXT) = jg
      else if (CGRP.eq.'VMTA') then
         call MUVmta
     O       (iErr, jg,
     I        CGRP, icGT, MH,  LH, MZI, LZ, CSW,  CLS, CRT,
     I        IFPa, IE,   iMA)
         if (iErr.eq.0) idGM (VGRP_VMTA) = jg
      else if (CGRP.eq.'VMTD') then
         call MUVmtd
     O       (iErr, jg,
     I        CGRP, icGT, MH,  LH, MZI, LZ, CSW,  CLS, CRT,
     I        IFPa, IE,   iMA)
         if (iErr.eq.0) idGM (VGRP_VMTD) = jg
      else
         iErr = -1
      endif
c
      call DAtrcU (jpL, iErr, CGRP, 'MUVMNG')
      RETURN
      END
CCC_ & MUVmhb  ## Set VMHB attributes [Boundary conditions]
      subroutine MUVmhb
     O    (iErr, idVG,
     I     CGRP, icG,  MH, LH, CSW, CLS, CRT, IFPa, IE, iMA)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   idVG
      _INTENT(IN, integer)   icG (*)
      _INTENT(IN, integer)   MH, LH
      _INTENT(IN, character) CGRP*(*)
      _INTENT(IN, character) CSW*(*)
      _INTENT(IN, character) CLS*(*), CRT*(*)
      _INTENT(IN, integer)   IFPa (*)
      _INTENT(IN, integer)   IE  (*)
      _INTENT(IN, integer)   iMA (*)
CCC_  - Body
      call AFBrgd
     O    (iErr,
     O     idVG,
     I     CGRP, MH,  LH,  0, 0,  VMHB_MAX, icG (1),
     I     CSW,  CLS, CRT, IFPa,  iMA)
c
      call AFBrgi (iErr, idVG, VMHB_TMBa, icG (1), 'TMB')
      call AFBrgi (iErr, idVG, VMHB_MS,   icG (1), 'Ms')
      call AFBrgi (iErr, idVG, VMHB_MB,   icG (1), 'Mb')
      call AFBrgi (iErr, idVG, VMHB_TSI,  icG (1), 'Tsi')
      call AFBrgi (iErr, idVG, VMHB_TBI,  icG (1), 'Tbi')
      call AFBrgi (iErr, idVG, VMHB_TBFLG,icG (1), 'Tbflg')
      call AFBrgi (iErr, idVG, VMHB_GH,   icG (1), 'gh')
      call AFBrgi (iErr, idVG, VMHB_Ra,   icG (1), 'R')
      call AFBrgi (iErr, idVG, VMHB_Rb,   icG (2), 'R')
      call AFBrgi (iErr, idVG, VMHB_Rc,   icG (3), 'R')
      call AFBrgi (iErr, idVG, VMHB_Rd,   icG (4), 'R')
      call AFBrgi (iErr, idVG, VMHB_NRa,  icG (1), 'NR')
      call AFBrgi (iErr, idVG, VMHB_NRb,  icG (2), 'NR')
      call AFBrgi (iErr, idVG, VMHB_NRc,  icG (3), 'NR')
      call AFBrgi (iErr, idVG, VMHB_NRXb, icG (2), 'drndx')
      call AFBrgi (iErr, idVG, VMHB_NRYc, icG (3), 'drndy')
      call AFBrgi (iErr, idVG, VMHB_RXb,  icG (2), 'drdx')
      call AFBrgi (iErr, idVG, VMHB_RYc,  icG (3), 'drdy')
      call AFBrgi (iErr, idVG, VMHB_LMSK, icG (1), 'lmsk')
      call AFBrgi (iErr, idVG, VMHB_UMSKb,icG (2), 'umsk')
      call AFBrgi (iErr, idVG, VMHB_VMSKc,icG (3), 'vmsk')
      call AFBrgi (iErr, idVG, VMHB_CVBb, icG (2), 'Cvb')
      call AFBrgi (iErr, idVG, VMHB_CVBc, icG (3), 'Cvb')
      call AFBrgi (iErr, idVG, VMHB_EVBb, icG (2), 'Evb')
      call AFBrgi (iErr, idVG, VMHB_EVBc, icG (3), 'Evb')
      call AFBrgi (iErr, idVG, VMHB_DVBb, icG (2), 'Dvb')
      call AFBrgi (iErr, idVG, VMHB_DVBc, icG (3), 'Dvb')
      call AFBrgi (iErr, idVG, VMHB_FVBb, icG (2), 'Fvb')
      call AFBrgi (iErr, idVG, VMHB_FVBc, icG (3), 'Fvb')
      call AFBrgi (iErr, idVG, VMHB_GVBb, icG (2), 'Gvb')
      call AFBrgi (iErr, idVG, VMHB_GVBc, icG (3), 'Gvb')
      call AFBrgi (iErr, idVG, VMHB_GLO,  icG (1), 'glo')
      call AFBrgi (iErr, idVG, VMHB_GLA,  icG (1), 'gla')
      call AFBrgi (iErr, idVG, VMHB_SLVa, icG (1), 'slv')
      call AFBrgi (iErr, idVG, VMHB_SLVb, icG (2), 'slv')
      call AFBrgi (iErr, idVG, VMHB_SLVc, icG (3), 'slv')
      call AFBrgi (iErr, idVG, VMHB_SLVd, icG (4), 'slv')
c
      if (iErr.eq.0) call AFBgmf (iErr, idVG, ' ', ' ', IE, IFPa)
c
      RETURN
      END
CCC_ & MUVmhr  ## Set VMHR attributes [Boundary condition references]
      subroutine MUVmhr
     O    (iErr, idVG,
     I     CGRP, icG,  MH, LH, CSW, CLS, CRT, IFPa, IE, iMA)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   idVG
      _INTENT(IN, integer)   icG (*)
      _INTENT(IN, integer)   MH, LH
      _INTENT(IN, character) CGRP*(*)
      _INTENT(IN, character) CSW*(*)
      _INTENT(IN, character) CLS*(*), CRT*(*)
      _INTENT(IN, integer)   IFPa (*)
      _INTENT(IN, integer)   IE  (*)
      _INTENT(IN, integer)   iMA (*)
CCC_  - Body
      call AFBrgd
     O    (iErr,
     O     idVG,
     I     CGRP, MH,  LH,  0, 0,  VMHR_MAX, icG (1),
     I     CSW,  CLS, CRT, IFPa,  iMA)
c
      call AFBrgi (iErr, idVG, VMHR_REFMS, icG (1), 'refMs')
      call AFBrgi (iErr, idVG, VMHR_REFTS, icG (1), 'refTs')
c
      if (iErr.eq.0) call AFBgmf (iErr, idVG, ' ', ' ', IE, IFPa)
c
      RETURN
      END
CCC_ & MUVmhi  ## Set VMHI attributes
      subroutine MUVmhi
     O    (iErr, idVG,
     I     CGRP, icG,  MH, LH, CSW, CLS, CRT, IFPa, IE, iMA)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   idVG
      _INTENT(IN, integer)   icG (*)
      _INTENT(IN, integer)   MH, LH
      _INTENT(IN, character) CGRP*(*)
      _INTENT(IN, character) CSW*(*)
      _INTENT(IN, character) CLS*(*), CRT*(*)
      _INTENT(IN, integer)   IFPa (*)
      _INTENT(IN, integer)   IE  (*)
      _INTENT(IN, integer)   iMA (*)
CCC_  * Body
      call AFBrgd
     O    (iErr,
     O     idVG,
     I     CGRP, MH,  LH,  0, 0,  VMHI_MAX, icG (1),
     I     CSW,  CLS, CRT, IFPa,  iMA)
c
      call AFBrgi (iErr, idVG, VMHI_oHa, icG (1), 'oH')
      call AFBrgi (iErr, idVG, VMHI_oBa, icG (1), 'oB')
      call AFBrgi (iErr, idVG, VMHI_oSa, icG (1), 'oS')
      call AFBrgi (iErr, idVG, VMHI_oHXa, icG (1), 'oHX')
      call AFBrgi (iErr, idVG, VMHI_oHYa, icG (1), 'oHY')
      call AFBrgi (iErr, idVG, VMHI_nHa, icG (1), 'nH')
      call AFBrgi (iErr, idVG, VMHI_nBa, icG (1), 'nB')
      call AFBrgi (iErr, idVG, VMHI_nSa, icG (1), 'nS')
      call AFBrgi (iErr, idVG, VMHI_ADVXe, icG (1), 'advxe')
      call AFBrgi (iErr, idVG, VMHI_ADVXw, icG (1), 'advxw')
      call AFBrgi (iErr, idVG, VMHI_ADVYn, icG (1), 'advyn')
      call AFBrgi (iErr, idVG, VMHI_ADVYs, icG (1), 'advys')
      call AFBrgi (iErr, idVG, VMHI_frd,   icG (1), 'frd')
c
      if (iErr.eq.0) call AFBgmf (iErr, idVG, ' ', ' ', IE, IFPa)
c
      RETURN
      END
CCC_ & MUVmti  ## Set VMTI attributes
      subroutine MUVmti
     O    (iErr, idVG,
     I     CGRP, icG,  MH,  LH, MZ, LZ, CSW,  CLS, CRT, IFPa, IE,  iMA)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   idVG
      _INTENT(IN, integer)   icG (*)
      _INTENT(IN, integer)   MH,  LH
      _INTENT(IN, integer)   MZ,  LZ
      _INTENT(IN, character) CGRP*(*)
      _INTENT(IN, character) CSW*(*)
      _INTENT(IN, character) CLS*(*), CRT*(*)
      _INTENT(IN, integer)   IFPa (*)
      _INTENT(IN, integer)   IE  (*)
      _INTENT(IN, integer)   iMA (*)
CCC_  * Body
      call AFBrgd
     O    (iErr,
     O     idVG,
     I     CGRP, MH,  LH,  MZ, LZ, VMTI_MAX, icG (1),
     I     CSW,  CLS, CRT, IFPa,   iMA)
c
      call AFBrgi (iErr, idVG, VMTI_T,    icG (1), 'T')
      call AFBrgi (iErr, idVG, VMTI_EF,   icG (1), 'ef')
      call AFBrgi (iErr, idVG, VMTI_Wadv, icG (1), 'wadv')
      call AFBrgi (iErr, idVG, VMTI_Uadv, icG (1), 'uadv')
      call AFBrgi (iErr, idVG, VMTI_Vadv, icG (1), 'vadv')
      call AFBrgi (iErr, idVG, VMTI_dwdZ, icG (1), 'dwdZ')
      call AFBrgi (iErr, idVG, VMTI_WHa,  icG (1), 'wh')
      call AFBrgi (iErr, idVG, VMTI_UHa,  icG (1), 'uh')
      call AFBrgi (iErr, idVG, VMTI_VHa,  icG (1), 'vh')
      call AFBrgi (iErr, idVG, VMTI_UHb,  icG (2), 'uh')
      call AFBrgi (iErr, idVG, VMTI_VHc,  icG (3), 'vh')
      call AFBrgi (iErr, idVG, VMTI_dTdXb, icG (2), 'dTdX')
      call AFBrgi (iErr, idVG, VMTI_dTdYc, icG (3), 'dTdY')
      call AFBrgi (iErr, idVG, VMTI_sh,   icG (1), 'sh')
c
      if (iErr.eq.0) call AFBgmf (iErr, idVG, ' ', ' ', IE, IFPa)
c
      RETURN
      END
CCC_ & MUVvmi  ## Set VMI attributes
      subroutine MUVvmi
     O    (iErr, idVG,
     I     CGRP, icG,  MH, LH, CSW, CLS, CRT, IFPa, IE, iMA)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   idVG
      _INTENT(IN, integer)   icG (*)
      _INTENT(IN, integer)   MH, LH
      _INTENT(IN, character) CGRP*(*)
      _INTENT(IN, character) CSW*(*)
      _INTENT(IN, character) CLS*(*), CRT*(*)
      _INTENT(IN, integer)   IFPa (*)
      _INTENT(IN, integer)   IE  (*)
      _INTENT(IN, integer)   iMA (*)
CCC_  * Body
      call AFBrgd
     O    (iErr,
     O     idVG,
     I     CGRP, MH,  LH,  0,    0, VMI_MAX, icG (1),
     I     CSW,  CLS, CRT, IFPa, iMA)
c
      call AFBrgi (iErr, idVG, VMI_CLa,   icG (1), 'CL')
      call AFBrgi (iErr, idVG, VMI_HH,    icG (1), 'HH')
      call AFBrgi (iErr, idVG, VMI_Ha,    icG (1), 'H')
      call AFBrgi (iErr, idVG, VMI_Sa,    icG (1), 'S')
      call AFBrgi (iErr, idVG, VMI_Ba,    icG (1), 'B')
      call AFBrgi (iErr, idVG, VMI_Hb,    icG (2), 'H')
      call AFBrgi (iErr, idVG, VMI_Sb,    icG (2), 'S')
      call AFBrgi (iErr, idVG, VMI_Bb,    icG (2), 'B')
      call AFBrgi (iErr, idVG, VMI_Hc,    icG (3), 'H')
      call AFBrgi (iErr, idVG, VMI_Sc,    icG (3), 'S')
      call AFBrgi (iErr, idVG, VMI_Bc,    icG (3), 'B')
      call AFBrgi (iErr, idVG, VMI_Hd,    icG (4), 'H')
      call AFBrgi (iErr, idVG, VMI_Sd,    icG (4), 'S')
      call AFBrgi (iErr, idVG, VMI_Bd,    icG (4), 'B')
      call AFBrgi (iErr, idVG, VMI_RFIIb, icG (2), 'RFII')
      call AFBrgi (iErr, idVG, VMI_RFIIc, icG (3), 'RFII')
      call AFBrgi (iErr, idVG, VMI_daRFa, icG (1), 'daRF')
CC      call AFBrgi (iErr, idVG, VMI_daRFd, icG (4), 'daRF')
      call AFBrgi (iErr, idVG, VMI_daBAa, icG (1), 'daBA')
      call AFBrgi (iErr, idVG, VMI_daBAd, icG (4), 'daBA')
      call AFBrgi (iErr, idVG, VMI_SLDb,  icG (2), 'SLD')
      call AFBrgi (iErr, idVG, VMI_SLDc,  icG (3), 'SLD')
      call AFBrgi (iErr, idVG, VMI_HX,    icG (1), 'HX')
      call AFBrgi (iErr, idVG, VMI_HY,    icG (1), 'HY')
c
      if (iErr.eq.0) call AFBgmf (iErr, idVG, ' ', ' ', IE, IFPa)
c
      RETURN
      END
CCC_ & MUVvmc  ## Set VMC attributes
      subroutine MUVvmc
     O    (iErr, idVG,
     I     CGRP, icG,  MH, LH, CSW, CLS, CRT, IFPa, IE, iMA)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   idVG
      _INTENT(IN, integer)   icG (*)
      _INTENT(IN, integer)   MH, LH
      _INTENT(IN, character) CGRP*(*)
      _INTENT(IN, character) CSW*(*)
      _INTENT(IN, character) CLS*(*), CRT*(*)
      _INTENT(IN, integer)   IFPa (*)
      _INTENT(IN, integer)   IE  (*)
      _INTENT(IN, integer)   iMA (*)
CCC_  * Body
      call AFBrgd
     O    (iErr,
     O     idVG,
     I     CGRP, MH,  LH,  0,    0, VMC_MAX, icG (1),
     I     CSW,  CLS, CRT, IFPa, iMA)
c
      call AFBrgi (iErr, idVG, VMC_HCa,   icG (1), 'HC')
      call AFBrgi (iErr, idVG, VMC_IKa,   icG (1), 'IK')
      call AFBrgi (iErr, idVG, VMC_IKb,   icG (2), 'IK')
      call AFBrgi (iErr, idVG, VMC_IKc,   icG (3), 'IK')
      call AFBrgi (iErr, idVG, VMC_IKd,   icG (4), 'IK')
      call AFBrgi (iErr, idVG, VMC_DSXb,  icG (2), 'DSX')
      call AFBrgi (iErr, idVG, VMC_DSYb,  icG (2), 'DSY')
      call AFBrgi (iErr, idVG, VMC_DSXc,  icG (3), 'DSX')
      call AFBrgi (iErr, idVG, VMC_DSYc,  icG (3), 'DSY')
      call AFBrgi (iErr, idVG, VMC_DSXd,  icG (4), 'DSX')
      call AFBrgi (iErr, idVG, VMC_DSYd,  icG (4), 'DSY')
      call AFBrgi (iErr, idVG, VMC_HE,    icG (1), 'He')
      call AFBrgi (iErr, idVG, VMC_NHa,   icG (1), 'NH')
      call AFBrgi (iErr, idVG, VMC_NHb,   icG (2), 'NH')
      call AFBrgi (iErr, idVG, VMC_NHc,   icG (3), 'NH')
      call AFBrgi (iErr, idVG, VMC_HX,    icG (1), 'HX')
      call AFBrgi (iErr, idVG, VMC_HY,    icG (1), 'HY')
      call AFBrgi (iErr, idVG, VMC_NBa,   icG (1), 'NB')
      call AFBrgi (iErr, idVG, VMC_NBb,   icG (2), 'NB')
      call AFBrgi (iErr, idVG, VMC_NBc,   icG (3), 'NB')
      call AFBrgi (iErr, idVG, VMC_SXbM,  icG (2), 'dsdxm')
      call AFBrgi (iErr, idVG, VMC_SYcM,  icG (3), 'dsdym')
      call AFBrgi (iErr, idVG, VMC_BXbM,  icG (2), 'dbdxm')
      call AFBrgi (iErr, idVG, VMC_BYcM,  icG (3), 'dbdym')
      call AFBrgi (iErr, idVG, VMC_dHdtE, icG (1), 'dHdte')
      call AFBrgi (iErr, idVG, VMC_QXaU,  icG (2), 'QXaU')
      call AFBrgi (iErr, idVG, VMC_QXbU,  icG (2), 'QXbU')
      call AFBrgi (iErr, idVG, VMC_QXcU,  icG (2), 'QXcU')
      call AFBrgi (iErr, idVG, VMC_QXdU,  icG (2), 'QXdU')
      call AFBrgi (iErr, idVG, VMC_QXaL,  icG (2), 'QXaL')
      call AFBrgi (iErr, idVG, VMC_QXbL,  icG (2), 'QXbL')
      call AFBrgi (iErr, idVG, VMC_QXcL,  icG (2), 'QXcL')
      call AFBrgi (iErr, idVG, VMC_QXdL,  icG (2), 'QXdL')
      call AFBrgi (iErr, idVG, VMC_QYaU,  icG (3), 'QYaU')
      call AFBrgi (iErr, idVG, VMC_QYbU,  icG (3), 'QYbU')
      call AFBrgi (iErr, idVG, VMC_QYcU,  icG (3), 'QYcU')
      call AFBrgi (iErr, idVG, VMC_QYdU,  icG (3), 'QYdU')
      call AFBrgi (iErr, idVG, VMC_QYaL,  icG (3), 'QYaL')
      call AFBrgi (iErr, idVG, VMC_QYbL,  icG (3), 'QYbL')
      call AFBrgi (iErr, idVG, VMC_QYcL,  icG (3), 'QYcL')
      call AFBrgi (iErr, idVG, VMC_QYdL,  icG (3), 'QYdL')
c
      if (iErr.eq.0) call AFBgmf (iErr, idVG, ' ', ' ', IE, IFPa)
c
      RETURN
      END
CCC_ & MUVmid  ## Set VMID attributes
      subroutine MUVmid
     O    (iErr, idVG,
     I     CGRP, icG,  MH, LH, CSW, CLS, CRT, IFPa, IE, iMA)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   idVG
      _INTENT(IN, integer)   icG (*)
      _INTENT(IN, integer)   MH, LH
      _INTENT(IN, character) CGRP*(*)
      _INTENT(IN, character) CSW*(*)
      _INTENT(IN, character) CLS*(*), CRT*(*)
      _INTENT(IN, integer)   IFPa (*)
      _INTENT(IN, integer)   IE  (*)
      _INTENT(IN, integer)   iMA (*)
CCC_  * Body
      call AFBrgd
     O    (iErr,
     O     idVG,
     I     CGRP, MH,  LH,  0,    0, VMID_MAX, icG (1),
     I     CSW,  CLS, CRT, IFPa, iMA)
c
      call AFBrgi (iErr, idVG, VMID_BSXb, icG (2), 'BSX')
      call AFBrgi (iErr, idVG, VMID_BSYb, icG (2), 'BSY')
      call AFBrgi (iErr, idVG, VMID_BNb,  icG (2), 'BN')
      call AFBrgi (iErr, idVG, VMID_Db,   icG (2), 'D')
      call AFBrgi (iErr, idVG, VMID_UIavb,icG (2), 'uiav')
      call AFBrgi (iErr, idVG, VMID_UBb,  icG (2), 'ub')
      call AFBrgi (iErr, idVG, VMID_vBSXb, icG (2), 'vBSX')
      call AFBrgi (iErr, idVG, VMID_BSXc, icG (3), 'BSX')
      call AFBrgi (iErr, idVG, VMID_BSYc, icG (3), 'BSY')
      call AFBrgi (iErr, idVG, VMID_BNc,  icG (3), 'BN')
      call AFBrgi (iErr, idVG, VMID_Dc,   icG (3), 'D')
      call AFBrgi (iErr, idVG, VMID_VIavc,icG (3), 'viav')
      call AFBrgi (iErr, idVG, VMID_VBc,  icG (3), 'vb')
      call AFBrgi (iErr, idVG, VMID_vBSYc, icG (3), 'vBSY')
c
      if (iErr.eq.0) call AFBgmf (iErr, idVG, ' ', ' ', IE, IFPa)
c
      RETURN
      END
CCC_ & MUVmiw  ## Set VMIW attributes
      subroutine MUVmiw
     O    (iErr, idVG,
     I     CGRP, icG,  MH, LH, CSW, CLS, CRT, IFPa, IE, iMA)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   idVG
      _INTENT(IN, integer)   icG (*)
      _INTENT(IN, integer)   MH, LH
      _INTENT(IN, character) CGRP*(*)
      _INTENT(IN, character) CSW*(*)
      _INTENT(IN, character) CLS*(*), CRT*(*)
      _INTENT(IN, integer)   IFPa (*)
      _INTENT(IN, integer)   IE  (*)
      _INTENT(IN, integer)   iMA (*)
CCC_  * Body
      call AFBrgd
     O    (iErr,
     O     idVG,
     I     CGRP, MH,  LH,  0,    0, VMIW_MAX, icG (1),
     I     CSW,  CLS, CRT, IFPa, iMA)
c
      call AFBrgi (iErr, idVG, VMIW_W1,   icG (1), 'W1')
      call AFBrgi (iErr, idVG, VMIW_W2,   icG (1), 'W2')
      call AFBrgi (iErr, idVG, VMIW_W3,   icG (1), 'W3')
      call AFBrgi (iErr, idVG, VMIW_W4,   icG (1), 'W4')
      call AFBrgi (iErr, idVG, VMIW_W5,   icG (1), 'W5')
      call AFBrgi (iErr, idVG, VMIW_W6,   icG (1), 'W6')
c
      if (iErr.eq.0) call AFBgmf (iErr, idVG, ' ', ' ', IE, IFPa)
c
      RETURN
      END
CCC_ & MUVvmq  ## Set QM attributes
      subroutine MUVvmq
     O    (iErr, idVG,
     I     CGRP, icG,  MH, LH, CSW, CLS, CRT, IFPa, IE, iMA)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   idVG
      _INTENT(IN, integer)   icG (*)
      _INTENT(IN, integer)   MH, LH
      _INTENT(IN, character) CGRP*(*)
      _INTENT(IN, character) CSW*(*)
      _INTENT(IN, character) CLS*(*), CRT*(*)
      _INTENT(IN, integer)   IFPa (*)
      _INTENT(IN, integer)   IE  (*)
      _INTENT(IN, integer)   iMA (*)
CCC_  - Body
      call AFBrgd
     O    (iErr,
     O     idVG,
     I     CGRP, MH,  LH,  0,    0,  VMQQ_MAX, icG (1),
     I     CSW,  CLS, CRT, IFPa, iMA)
c
      call AFBrgi (iErr, idVG, VMQ_MSK,   icG (1), 'MSK')
      call AFBrgi (iErr, idVG, VMQ_DIAG,  icG (1), 'DIAG')
      call AFBrgi (iErr, idVG, VMQ_BB,    icG (1), 'BB')
      call AFBrgi (iErr, idVG, VMQ_Db,    icG (1), 'Db')
      call AFBrgi (iErr, idVG, VMQ_Dc,    icG (1), 'Dc')
      call AFBrgi (iErr, idVG, VMQ_Eb,    icG (1), 'Eb')
      call AFBrgi (iErr, idVG, VMQ_Ec,    icG (1), 'Ec')
c
      if (iErr.eq.0) call AFBgmf (iErr, idVG, ' ', ' ', IE, IFPa)
c
      RETURN
      END
CCC_ & MUVvmx  ## Set X attributes
      subroutine MUVvmx
     O    (iErr, idVG,
     I     CGRP, icG,  MH, LH, CSW, CLS, CRT, IFPa, IE, iMA)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   idVG
      _INTENT(IN, integer)   icG (*)
      _INTENT(IN, integer)   MH, LH
      _INTENT(IN, character) CGRP*(*)
      _INTENT(IN, character) CSW*(*)
      _INTENT(IN, character) CLS*(*), CRT*(*)
      _INTENT(IN, integer)   IFPa (*)
      _INTENT(IN, integer)   IE  (*)
      _INTENT(IN, integer)   iMA (*)
CCC_  - Body
      call AFBrgd
     O    (iErr,
     O     idVG,
     I     CGRP, MH,  LH,  0,   0,  BCGW_MAX, icG (1),
     I     CSW,  CLS, CRT, IFPa,    iMA)
c
      call AFBrgi (iErr, idVG, BCGW_BB,   icG (1), 'BB')
      call AFBrgi (iErr, idVG, BCGW_R,    icG (1), 'R')
      call AFBrgi (iErr, idVG, BCGW_P,    icG (1), 'P')
      call AFBrgi (iErr, idVG, BCGW_Z,    icG (1), 'Z')
      call AFBrgi (iErr, idVG, BCGW_RR,   icG (1), 'RR')
      call AFBrgi (iErr, idVG, BCGW_PP,   icG (1), 'PP')
      call AFBrgi (iErr, idVG, BCGW_ZZ,   icG (1), 'ZZ')
      call AFBrgi (iErr, idVG, BCGW_B1,   icG (1), 'B1')
      call AFBrgi (iErr, idVG, BCGW_XX,   icG (1), 'XX')
      call AFBrgi (iErr, idVG, BCGW_XH1,  icG (1), 'XH1')
      call AFBrgi (iErr, idVG, BCGW_XH2,  icG (1), 'XH2')
c
      if (iErr.eq.0) call AFBgmf (iErr, idVG, ' ', ' ', IE, IFPa)
c
      RETURN
      END
CCC_ & MUVmhw  ## Set VMHW attributes
      subroutine MUVmhw
     O    (iErr, idVG,
     I     CGRP, icG,  MH, LH, CSW, CLS, CRT, IFPa, IE, iMA)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   idVG
      _INTENT(IN, integer)   icG (*)
      _INTENT(IN, integer)   MH, LH
      _INTENT(IN, character) CGRP*(*)
      _INTENT(IN, character) CSW*(*)
      _INTENT(IN, character) CLS*(*), CRT*(*)
      _INTENT(IN, integer)   IFPa (*)
      _INTENT(IN, integer)   IE  (*)
      _INTENT(IN, integer)   iMA (*)
CCC_  - Body
      call AFBrgd
     O    (iErr,
     O     idVG,
     I     CGRP, MH,  LH,  0,    0,  VMHW_MAX, icG (1),
     I     CSW,  CLS, CRT, IFPa, iMA)
c
      call AFBrgi (iErr, idVG, VMHW_Hinv, icG (1), 'Hinv')
      call AFBrgi (iErr, idVG, VMHW_dHdt, icG (1), 'dHdt')
      call AFBrgi (iErr, idVG, VMHW_dBdt, icG (1), 'dbdt')
      call AFBrgi (iErr, idVG, VMHW_dHdx, icG (1), 'dHdx')
      call AFBrgi (iErr, idVG, VMHW_dBdx, icG (1), 'dbdx')
      call AFBrgi (iErr, idVG, VMHW_dHdy, icG (1), 'dHdy')
      call AFBrgi (iErr, idVG, VMHW_dBdy, icG (1), 'dbdy')
      call AFBrgi (iErr, idVG, VMHW_HSB,  icG (1), 'HSB')
      call AFBrgi (iErr, idVG, VMHW_W1,   icG (1), 'W1')
      call AFBrgi (iErr, idVG, VMHW_W2,   icG (1), 'W2')
c
      if (iErr.eq.0) call AFBgmf (iErr, idVG, ' ', ' ', IE, IFPa)
c
      RETURN
      END
CCC_ & MUVmtw  ## Set VMTW attributes
      subroutine MUVmtw
     O    (iErr, idVG,
     I     CGRP, icG,  MH, LH, MZ, LZ, CSW,  CLS, CRT, IFPa, IE, iMA)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   idVG
      _INTENT(IN, integer)   icG (*)
      _INTENT(IN, integer)   MH,  LH
      _INTENT(IN, integer)   MZ,  LZ
      _INTENT(IN, character) CGRP*(*)
      _INTENT(IN, character) CSW*(*)
      _INTENT(IN, character) CLS*(*), CRT*(*)
      _INTENT(IN, integer)   IFPa (*)
      _INTENT(IN, integer)   IE  (*)
      _INTENT(IN, integer)   iMA (*)
CCC_  * Body
      call AFBrgd
     O    (iErr,
     O     idVG,
     I     CGRP,  MH,  LH,  MZ, LZ, VMTW_MAX, icG (1),
     I     CSW,   CLS, CRT, IFPa,   iMA)
c
      call AFBrgi (iErr, idVG, VMTW_RFb,  icG (2), 'rf')
      call AFBrgi (iErr, idVG, VMTW_RFIb, icG (2), 'rfi')
      call AFBrgi (iErr, idVG, VMTW_RFIIb, icG (2), 'rfii')
      call AFBrgi (iErr, idVG, VMTW_RFc,  icG (3), 'rf')
      call AFBrgi (iErr, idVG, VMTW_RFIc, icG (3), 'rfi')
      call AFBrgi (iErr, idVG, VMTW_RFIIc, icG (3), 'rfii')
      call AFBrgi (iErr, idVG, VMTW_ARFa, icG (1), 'arf')
      call AFBrgi (iErr, idVG, VMTW_ARFd, icG (4), 'arf')
      call AFBrgi (iErr, idVG, VMTW_divHziue, icG (1), 'divHziue')
      call AFBrgi (iErr, idVG, VMTW_ugradz, icG (1), 'ugradz')
      call AFBrgi (iErr, idVG, VMTW_divuh, icG (1), 'divuh')
c$$$      call AFBrgi (iErr, idVG, VMTW_divziuh, icG (1), 'divziuh')
      call AFBrgi (iErr, idVG, VMTW_ziUIb, icG (2), 'ziui')
      call AFBrgi (iErr, idVG, VMTW_ziVIc, icG (3), 'zivi')
c$$$      call AFBrgi (iErr, idVG, VMTW_ziUIa, icG (1), 'ziui')
c$$$      call AFBrgi (iErr, idVG, VMTW_ziVIa, icG (1), 'zivi')
      call AFBrgi (iErr, idVG, VMTW_EFb,  icG (2), 'ef')
      call AFBrgi (iErr, idVG, VMTW_EFc,  icG (3), 'ef')
      call AFBrgi (iErr, idVG, VMTW_EFd,  icG (1), 'ef')
      call AFBrgi (iErr, idVG, VMTW_SXZb, icG (2), 'sxz')
      call AFBrgi (iErr, idVG, VMTW_EXZb, icG (2), 'exz')
      call AFBrgi (iErr, idVG, VMTW_SYZc, icG (3), 'syz')
      call AFBrgi (iErr, idVG, VMTW_EYZc, icG (3), 'eyz')
      call AFBrgi (iErr, idVG, VMTW_SXZa, icG (1), 'sxz')
      call AFBrgi (iErr, idVG, VMTW_SYZa, icG (1), 'syz')
      call AFBrgi (iErr, idVG, VMTW_EXZa, icG (1), 'exz')
      call AFBrgi (iErr, idVG, VMTW_EYZa, icG (1), 'eyz')
      call AFBrgi (iErr, idVG, VMTW_SXXa, icG (1), 'sxx')
      call AFBrgi (iErr, idVG, VMTW_SYYa, icG (1), 'syy')
      call AFBrgi (iErr, idVG, VMTW_SXYa, icG (1), 'sxy')
      call AFBrgi (iErr, idVG, VMTW_EXXa, icG (1), 'exx')
      call AFBrgi (iErr, idVG, VMTW_EYYa, icG (1), 'eyy')
      call AFBrgi (iErr, idVG, VMTW_EXYa, icG (1), 'exy')
CC      call AFBrgi (iErr, idVG, VMTW_MAXD, icG (1), 'MAXD')
      call AFBrgi (iErr, idVG, VMTW_QD,   icG (1), 'qd')
      call AFBrgi (iErr, idVG, VMTW_QU,   icG (1), 'qu')
      call AFBrgi (iErr, idVG, VMTW_QL,   icG (1), 'ql')
      call AFBrgi (iErr, idVG, VMTW_QB,   icG (1), 'qb')
      call AFBrgi (iErr, idVG, VMTW_E1,   icG (1), 'E1')
      call AFBrgi (iErr, idVG, VMTW_E2,   icG (1), 'E2')
      call AFBrgi (iErr, idVG, VMTW_E3p,  icG (1), 'E3p')
      call AFBrgi (iErr, idVG, VMTW_E3m,  icG (1), 'E3m')
      call AFBrgi (iErr, idVG, VMTW_E33,  icG (1), 'E33')
      call AFBrgi (iErr, idVG, VMTW_HS,   icG (1), 'HS')
      call AFBrgi (iErr, idVG, VMTW_dTdXa, icG (1), 'dTdX')
      call AFBrgi (iErr, idVG, VMTW_dTdYa, icG (1), 'dTdY')
      call AFBrgi (iErr, idVG, VMTW_kti,  icG (1), 'kti')
      call AFBrgi (iErr, idVG, VMTW_dktidz, icG (1), 'dktidz')
      call AFBrgi (iErr, idVG, VMTW_hcap, icG (1), 'hcap')
      call AFBrgi (iErr, idVG, VMTW_W1,   icG (1), 'W1')
      call AFBrgi (iErr, idVG, VMTW_W2,   icG (1), 'W2')
      call AFBrgi (iErr, idVG, VMTW_W3x,  icG (1), 'W3x')
      call AFBrgi (iErr, idVG, VMTW_W3y,  icG (1), 'W3y')

c
      if (iErr.eq.0) call AFBgmf (iErr, idVG, ' ', ' ', IE, IFPa)
c
      RETURN
      END
CCC_ & MUVmsc  ## Set VMSC attributes
      subroutine MUVmsc
     O    (iErr, idVG,
     I     CGRP, icG,  MH, LH, CSW, CLS, CRT, IFPa, IE, iMA)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   idVG
      _INTENT(IN, integer)   icG (*)
      _INTENT(IN, integer)   MH, LH
      _INTENT(IN, character) CGRP*(*)
      _INTENT(IN, character) CSW*(*)
      _INTENT(IN, character) CLS*(*), CRT*(*)
      _INTENT(IN, integer)   IFPa (*)
      _INTENT(IN, integer)   IE  (*)
      _INTENT(IN, integer)   iMA (*)
CCC_  - Body
      iErr = 0
c
      call AFBrgd
     O    (iErr,
     O     idVG,
     I     CGRP, MH,  LH,  0,    0, VMSC_MAX, icG (1),
     I     CSW,  CLS, CRT, IFPa,    iMA)
c
      call AFBrgi (iErr, idVG, VMSC_Da_MI, icG (1), 'ID')
CC      call MUVbri (je, idVG, VMSC_PaE_MI, icG (1), 'PaE_MI')
      call AFBrgi (iErr, idVG, VMSC_Ub_MI, icG (2), 'Iu')
      call AFBrgi (iErr, idVG, VMSC_Vc_MI, icG (3), 'Iv')
      call AFBrgi (iErr, idVG, VMSC_Rd_MI, icG (4), 'IR')
      call AFBrgi (iErr, idVG, VMSC_BVIa, icG (1), 'BVI')
      call AFBrgi (iErr, idVG, VMSC_BVId, icG (4), 'BVI')
      call AFBrgi (iErr, idVG, VMSC_UbN_MF, icG (2), 'FuN')
      call AFBrgi (iErr, idVG, VMSC_UbS_MF, icG (2), 'FuS')
      call AFBrgi (iErr, idVG, VMSC_VcE_MF, icG (3), 'FvE')
      call AFBrgi (iErr, idVG, VMSC_VcW_MF, icG (3), 'FvW')
      call AFBrgi (iErr, idVG, VMSC_PaE_MF, icG (1), 'FpE')
      call AFBrgi (iErr, idVG, VMSC_PaW_MF, icG (1), 'FpW')
      call AFBrgi (iErr, idVG, VMSC_QaN_MF, icG (1), 'FqN')
      call AFBrgi (iErr, idVG, VMSC_QaS_MF, icG (1), 'FqS')
      call AFBrgi (iErr, idVG, VMSC_PaN_MF, icG (1), 'FpN')
      call AFBrgi (iErr, idVG, VMSC_PaS_MF, icG (1), 'FpS')
      call AFBrgi (iErr, idVG, VMSC_QaE_MF, icG (1), 'FqE')
      call AFBrgi (iErr, idVG, VMSC_QaW_MF, icG (1), 'FqW')
      call AFBrgi (iErr, idVG, VMSC_RdA_MF, icG (4), 'FrA')
      call AFBrgi (iErr, idVG, VMSC_UbN_MG, icG (2), 'GuN')
      call AFBrgi (iErr, idVG, VMSC_UbS_MG, icG (2), 'GuS')
      call AFBrgi (iErr, idVG, VMSC_VcE_MG, icG (3), 'GvE')
      call AFBrgi (iErr, idVG, VMSC_VcW_MG, icG (3), 'GvW')
      call AFBrgi (iErr, idVG, VMSC_PaE_MG, icG (1), 'GpE')
      call AFBrgi (iErr, idVG, VMSC_PaW_MG, icG (1), 'GpW')
      call AFBrgi (iErr, idVG, VMSC_QaN_MG, icG (1), 'GqN')
      call AFBrgi (iErr, idVG, VMSC_QaS_MG, icG (1), 'GqS')
      call AFBrgi (iErr, idVG, VMSC_PaN_MG, icG (1), 'GpN')
      call AFBrgi (iErr, idVG, VMSC_PaS_MG, icG (1), 'GpS')
      call AFBrgi (iErr, idVG, VMSC_QaE_MG, icG (1), 'GqE')
      call AFBrgi (iErr, idVG, VMSC_QaW_MG, icG (1), 'GqW')
      call AFBrgi (iErr, idVG, VMSC_QbHe, icG (2), 'LLhe')
      call AFBrgi (iErr, idVG, VMSC_QbHw, icG (2), 'LLhw')
      call AFBrgi (iErr, idVG, VMSC_QbNe, icG (2), 'LLNe')
      call AFBrgi (iErr, idVG, VMSC_QbNw, icG (2), 'LLNw')
      call AFBrgi (iErr, idVG, VMSC_QbSe, icG (2), 'LLSe')
      call AFBrgi (iErr, idVG, VMSC_QbSw, icG (2), 'LLSw')
      call AFBrgi (iErr, idVG, VMSC_PcVn, icG (3), 'LLvn')
      call AFBrgi (iErr, idVG, VMSC_PcVs, icG (3), 'LLvs')
      call AFBrgi (iErr, idVG, VMSC_PcEn, icG (3), 'LLEn')
      call AFBrgi (iErr, idVG, VMSC_PcEs, icG (3), 'LLEs')
      call AFBrgi (iErr, idVG, VMSC_PcWn, icG (3), 'LLWn')
      call AFBrgi (iErr, idVG, VMSC_PcWs, icG (3), 'LLWs')
      call AFBrgi (iErr, idVG, VMSC_NdX,  icG (4), 'Nx')
      call AFBrgi (iErr, idVG, VMSC_NdY,  icG (4), 'Ny')
      call AFBrgi (iErr, idVG, VMSC_NbX,  icG (2), 'Nx')
      call AFBrgi (iErr, idVG, VMSC_NbY,  icG (2), 'Ny')
      call AFBrgi (iErr, idVG, VMSC_NcX,  icG (3), 'Nx')
      call AFBrgi (iErr, idVG, VMSC_NcY,  icG (3), 'Ny')
      call AFBrgi (iErr, idVG, VMSC_NdXXY, icG (4), 'NxNxNy')
      call AFBrgi (iErr, idVG, VMSC_NdYYX, icG (4), 'NyNyNx')
      call AFBrgi (iErr, idVG, VMSC_NbXX, icG (2), 'NxNx')
      call AFBrgi (iErr, idVG, VMSC_NbYY, icG (2), 'NyNy')
      call AFBrgi (iErr, idVG, VMSC_NbXY, icG (2), 'NxNy')
      call AFBrgi (iErr, idVG, VMSC_NcYY, icG (3), 'NyNy')
      call AFBrgi (iErr, idVG, VMSC_NcXX, icG (3), 'NxNx')
      call AFBrgi (iErr, idVG, VMSC_NcYX, icG (3), 'NyNx')
      call AFBrgi (iErr, idVG, VMSC_DxSwEb, icG (2), 'DxSwE')
      call AFBrgi (iErr, idVG, VMSC_DxSwWb, icG (2), 'DxSwW')
      call AFBrgi (iErr, idVG, VMSC_DySwNc, icG (3), 'DySwN')
      call AFBrgi (iErr, idVG, VMSC_DySwSc, icG (3), 'DySwS')
      call AFBrgi (iErr, idVG, VMSC_DxSwEd, icG (4), 'DxSwE')
      call AFBrgi (iErr, idVG, VMSC_DxSwWd, icG (4), 'DxSwW')
      call AFBrgi (iErr, idVG, VMSC_DySwNd, icG (4), 'DySwN')
      call AFBrgi (iErr, idVG, VMSC_DySwSd, icG (4), 'DySwS')
      call AFBrgi (iErr, idVG, VMSC_CxSwNb, icG (2), 'CxSwN')
      call AFBrgi (iErr, idVG, VMSC_CySwNb, icG (2), 'CySwN')
      call AFBrgi (iErr, idVG, VMSC_CxSwSb, icG (2), 'CxSwS')
      call AFBrgi (iErr, idVG, VMSC_CySwSb, icG (2), 'CySwS')
      call AFBrgi (iErr, idVG, VMSC_CxSwEc, icG (3), 'CxSwE')
      call AFBrgi (iErr, idVG, VMSC_CySwEc, icG (3), 'CySwE')
      call AFBrgi (iErr, idVG, VMSC_CxSwWc, icG (3), 'CxSwW')
      call AFBrgi (iErr, idVG, VMSC_CySwWc, icG (3), 'CySwW')
c
      if (iErr.eq.0) call AFBgmf (iErr, idVG, ' ', ' ', IE, IFPa)
c
      RETURN
      END
CCC_ & MUVmsv  ## Set VMSV attributes
      subroutine MUVmsv
     O    (iErr, idVG,
     I     CGRP, icG,  MH, LH, CSW, CLS, CRT, IFPa, IE, iMA)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   idVG
      _INTENT(IN, integer)   icG (*)
      _INTENT(IN, integer)   MH, LH
      _INTENT(IN, character) CGRP*(*)
      _INTENT(IN, character) CSW*(*)
      _INTENT(IN, character) CLS*(*), CRT*(*)
      _INTENT(IN, integer)   IFPa (*)
      _INTENT(IN, integer)   IE  (*)
      _INTENT(IN, integer)   iMA (*)
CCC_  - Body
      call AFBrgd
     O    (iErr,
     O     idVG,
     I     CGRP, MH,  LH,  0,   0,  VMSV_MAX, icG (1),
     I     CSW,  CLS, CRT, IFPa,    iMA)
c
      call AFBrgi (iErr, idVG, VMSV_fsrp, icG (1), 'fsrp')
      call AFBrgi (iErr, idVG, VMSV_URa,  icG (1), 'ur')
      call AFBrgi (iErr, idVG, VMSV_UXa,  icG (1), 'ux')
      call AFBrgi (iErr, idVG, VMSV_VYa,  icG (1), 'vy')
      call AFBrgi (iErr, idVG, VMSV_MUa,  icG (1), 'mu')
      call AFBrgi (iErr, idVG, VMSV_MUd,  icG (4), 'mu')
      call AFBrgi (iErr, idVG, VMSV_MUaN, icG (1), 'muN')
      call AFBrgi (iErr, idVG, VMSV_MUaS, icG (1), 'muS')
      call AFBrgi (iErr, idVG, VMSV_MUaE, icG (1), 'muE')
      call AFBrgi (iErr, idVG, VMSV_MUaW, icG (1), 'muW')
      call AFBrgi (iErr, idVG, VMSV_MUa0, icG (1), 'mubuf0')
      call AFBrgi (iErr, idVG, VMSV_MUd0, icG (4), 'mubuf0')
      call AFBrgi (iErr, idVG, VMSV_MUa1, icG (1), 'mubuf1')
      call AFBrgi (iErr, idVG, VMSV_MUd1, icG (4), 'mubuf1')
      call AFBrgi (iErr, idVG, VMSV_BDb,  icG (2), 'BD')
      call AFBrgi (iErr, idVG, VMSV_BDc,  icG (3), 'BD')
      call AFBrgi (iErr, idVG, VMSV_UGb_MI, icG (2), 'Iug')
      call AFBrgi (iErr, idVG, VMSV_VGc_MI, icG (3), 'Ivg')
      call AFBrgi (iErr, idVG, VMSV_UGb,  icG (2), 'ugl')
      call AFBrgi (iErr, idVG, VMSV_VGc,  icG (3), 'vgl')
      call AFBrgi (iErr, idVG, VMSV_Hglb, icG (2), 'Hgl')
      call AFBrgi (iErr, idVG, VMSV_Hglc, icG (3), 'Hgl')
      call AFBrgi (iErr, idVG, VMSV_Dglb, icG (2), 'Dgl')
      call AFBrgi (iErr, idVG, VMSV_Dglc, icG (3), 'Dgl')
      call AFBrgi (iErr, idVG, VMSV_Qglb, icG (2), 'Qgl')
      call AFBrgi (iErr, idVG, VMSV_Qglc, icG (3), 'Qgl')
      call AFBrgi (iErr, idVG, VMSV_BIglb, icG (2), 'BIgl')
      call AFBrgi (iErr, idVG, VMSV_BIglc, icG (3), 'BIgl')
      call AFBrgi (iErr, idVG, VMSV_CCglb, icG (2), 'CCgl')
      call AFBrgi (iErr, idVG, VMSV_CCglc, icG (3), 'CCgl')
      call AFBrgi (iErr, idVG, VMSV_CPglb, icG (2), 'CPgl')
      call AFBrgi (iErr, idVG, VMSV_CPglc, icG (3), 'CPgl')
      call AFBrgi (iErr, idVG, VMSV_WQgb, icG (2), 'WQg')
      call AFBrgi (iErr, idVG, VMSV_WQlb, icG (2), 'WQl')
      call AFBrgi (iErr, idVG, VMSV_WQub, icG (2), 'WQu')
      call AFBrgi (iErr, idVG, VMSV_WQgc, icG (3), 'WQg')
      call AFBrgi (iErr, idVG, VMSV_WQlc, icG (3), 'WQl')
      call AFBrgi (iErr, idVG, VMSV_WQuc, icG (3), 'WQu')
      call AFBrgi (iErr, idVG, VMSV_WTglEb, icG (2), 'WTglE')
      call AFBrgi (iErr, idVG, VMSV_WTglWb, icG (2), 'WTglW')
      call AFBrgi (iErr, idVG, VMSV_WTglNc, icG (3), 'WTglN')
      call AFBrgi (iErr, idVG, VMSV_WTglSc, icG (3), 'WTglS')
      call AFBrgi (iErr, idVG, VMSV_Btrb, icG (2), 'Btr')
      call AFBrgi (iErr, idVG, VMSV_Btrc, icG (3), 'Btr')
      call AFBrgi (iErr, idVG, VMSV_Xglb, icG (2), 'Xgl')
      call AFBrgi (iErr, idVG, VMSV_Yglc, icG (3), 'Ygl')
c
      if (iErr.eq.0) call AFBgmf (iErr, idVG, ' ', ' ', IE, IFPa)
c
      RETURN
      END
CCC_ & MUVmsx  ## Set VMSX attributes (choice)
      subroutine MUVmsx
     O    (iErr, idVG,
     I     CGRP, OSUBI,
     I     icG,  MH, LH, CSW, CLS, CRT, IFPa, IE, iMA)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   idVG
      _INTENT(IN, character) CGRP*(*)
      _INTENT(IN, logical)   OSUBI
      _INTENT(IN, integer)   icG (*)
      _INTENT(IN, integer)   MH, LH
      _INTENT(IN, character) CSW*(*)
      _INTENT(IN, character) CLS*(*), CRT*(*)
      _INTENT(IN, integer)   IFPa (*)
      _INTENT(IN, integer)   IE  (*)
      _INTENT(IN, integer)   iMA (*)
CCC_  - Body
      call AFBrgc
     O    (iErr,
     O     idVG,
     I     CGRP,  OSUBI, MH,  LH,   0,   0,  VMSX_MAX, icG (1),
     I     CSW,   CLS,   CRT, IFPa, iMA)
c
      call AFBrgi (iErr, idVG, VMSX_PaE,  icG (1), 'PE')
      call AFBrgi (iErr, idVG, VMSX_PaW,  icG (1), 'PW')
      call AFBrgi (iErr, idVG, VMSX_QaN,  icG (1), 'QN')
      call AFBrgi (iErr, idVG, VMSX_QaS,  icG (1), 'QS')
      call AFBrgi (iErr, idVG, VMSX_UbN,  icG (2), 'uN')
      call AFBrgi (iErr, idVG, VMSX_UbS,  icG (2), 'uS')
      call AFBrgi (iErr, idVG, VMSX_VcE,  icG (3), 'vE')
      call AFBrgi (iErr, idVG, VMSX_VcW,  icG (3), 'vW')
      call AFBrgi (iErr, idVG, VMSX_RdA,  icG (4), 'R')
      call AFBrgi (iErr, idVG, VMSX_PaN,  icG (1), 'PN')
      call AFBrgi (iErr, idVG, VMSX_PaS,  icG (1), 'PS')
      call AFBrgi (iErr, idVG, VMSX_QaE,  icG (1), 'QE')
      call AFBrgi (iErr, idVG, VMSX_QaW,  icG (1), 'QW')
c
      if (iErr.eq.0) call AFBgmf (iErr, idVG, ' ', ' ', IE, IFPa)
c
      RETURN
      END
CCC_ & MUVswn  ## Set VMSW/N attributes
      subroutine MUVswn
     O    (iErr, idVG,
     I     CGRP, icG,  MH, LH, CSW, CLS, CRT, IFPa, IE, iMA)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   idVG
      _INTENT(IN, integer)   icG (*)
      _INTENT(IN, integer)   MH, LH
      _INTENT(IN, character) CGRP*(*)
      _INTENT(IN, character) CSW*(*)
      _INTENT(IN, character) CLS*(*), CRT*(*)
      _INTENT(IN, integer)   IFPa (*)
      _INTENT(IN, integer)   IE  (*)
      _INTENT(IN, integer)   iMA (*)
CCC_  - Body
      call AFBrgd
     O    (iErr,
     O     idVG,
     I     CGRP, MH,  LH,  0,    0, VMSN_MAX, icG (1),
     I     CSW,  CLS, CRT, IFPa, iMA)
c
      call AFBrgi (iErr, idVG, VMSN_B1,   icG (1), 'B1')
      call AFBrgi (iErr, idVG, VMSN_B2,   icG (1), 'B2')
      call AFBrgi (iErr, idVG, VMSN_B3,   icG (1), 'B3')
      call AFBrgi (iErr, idVG, VMSN_B4,   icG (1), 'B4')
      call AFBrgi (iErr, idVG, VMSN_MiPXRY, icG (1), 'IDR')
CC      call MUVbri (je, idVG, VMSN_MiQYRX, icG (1), 'MiQYRX')
CC      call MUVbri (je, idVG, VMSN_PIa,  icG (1), 'PIa')
CC      call MUVbri (je, idVG, VMSN_QIa,  icG (1), 'QIa')
      call AFBrgi (iErr, idVG, VMSN_NxRd, icG (1), 'NR')
      call AFBrgi (iErr, idVG, VMSN_NyRd, icG (1), 'NyRd')
CC      call MUVbri (je, idVG, VMSN_NPNRb, icG (1), 'NPNRb')
CC      call MUVbri (je, idVG, VMSN_NQNRc, icG (1), 'NQNRc')
CC      call MUVbri (je, idVG, VMSN_NQNRb, icG (1), 'NQNRb')
CC      call MUVbri (je, idVG, VMSN_NPNRc, icG (1), 'NPNRc')
      call AFBrgi (iErr, idVG, VMSN_SwPbH, icG (1), 'SwPh')
      call AFBrgi (iErr, idVG, VMSN_SwQbH, icG (1), 'SwQh')
      call AFBrgi (iErr, idVG, VMSN_SumDUDXa, icG (1), 'Sumdudx')
      call AFBrgi (iErr, idVG, VMSN_SumDVDYa, icG (1), 'Sumdvdy')
      call AFBrgi (iErr, idVG, VMSN_DUDXaN, icG (1), 'dudxN')
      call AFBrgi (iErr, idVG, VMSN_DUDXaS, icG (1), 'dudxS')
      call AFBrgi (iErr, idVG, VMSN_DVDYaE, icG (1), 'dvdyE')
      call AFBrgi (iErr, idVG, VMSN_DVDYaW, icG (1), 'dvdyW')
      call AFBrgi (iErr, idVG, VMSN_Rb,   icG (2), 'R')
CC      call MUVbri (je, idVG, VMSN_Rc,   icG (3), 'R')
CC      call MUVbri (je, idVG, VMSN_MAX,  icG (1), 'MAX')
c
      if (iErr.eq.0) call AFBgmf (iErr, idVG, ' ', ' ', IE, IFPa)
c
      RETURN
      END
CCC_ & MUVswt  ## Set VMSW/T attributes
      subroutine MUVswt
     O    (iErr, idVG,
     I     CGRP, icG,  MH, LH, CSW, CLS, CRT, IFPa, IE, iMA)
CCC_  - Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   idVG
      _INTENT(IN, integer)   icG (*)
      _INTENT(IN, integer)   MH, LH
      _INTENT(IN, character) CGRP*(*)
      _INTENT(IN, character) CSW*(*)
      _INTENT(IN, character) CLS*(*), CRT*(*)
      _INTENT(IN, integer)   IFPa (*)
      _INTENT(IN, integer)   IE  (*)
      _INTENT(IN, integer)   iMA (*)
CCC_  - Body
      call AFBrgd
     O    (iErr,
     O     idVG,
     I     CGRP, MH,  LH,  0,    0, VMST_MAX, icG (1),
     I     CSW,  CLS, CRT, IFPa, iMA)
c
      call AFBrgi (iErr, idVG, VMST_B1,   icG (1), 'B1')
      call AFBrgi (iErr, idVG, VMST_B2,   icG (1), 'B2')
      call AFBrgi (iErr, idVG, VMST_B3,   icG (1), 'B3')
      call AFBrgi (iErr, idVG, VMST_B4,   icG (1), 'B4')
      call AFBrgi (iErr, idVG, VMST_MuIPa, icG (1), 'muIP')
      call AFBrgi (iErr, idVG, VMST_MuIQa, icG (1), 'muIQ')
      call AFBrgi (iErr, idVG, VMST_SumCxGU, icG (1), 'SumCxGU')
      call AFBrgi (iErr, idVG, VMST_SumCxGV, icG (1), 'SumCxGV')
      call AFBrgi (iErr, idVG, VMST_SumCyGV, icG (1), 'SumCyGV')
      call AFBrgi (iErr, idVG, VMST_SumCyGU, icG (1), 'SumCyGU')
      call AFBrgi (iErr, idVG, VMST_IGPN, icG (1), 'IGPN')
      call AFBrgi (iErr, idVG, VMST_IGPS, icG (1), 'IGPS')
      call AFBrgi (iErr, idVG, VMST_IGQE, icG (1), 'IGQE')
      call AFBrgi (iErr, idVG, VMST_IGQW, icG (1), 'IGQW')
      call AFBrgi (iErr, idVG, VMST_MuIRd, icG (1), 'MuIRd')
      call AFBrgi (iErr, idVG, VMST_Iuu,  icG (2), 'Iuu')
      call AFBrgi (iErr, idVG, VMST_Ivv,  icG (3), 'Ivv')
      call AFBrgi (iErr, idVG, VMST_GSumPa, icG (1), 'GP')
      call AFBrgi (iErr, idVG, VMST_GSumQa, icG (1), 'GQ')
      call AFBrgi (iErr, idVG, VMST_nGSumPa, icG (1), 'nGP')
      call AFBrgi (iErr, idVG, VMST_nCGUN, icG (1), 'nCGUN')
      call AFBrgi (iErr, idVG, VMST_nCGUS, icG (1), 'nCGUS')
      call AFBrgi (iErr, idVG, VMST_nCGVE, icG (1), 'nCGVE')
      call AFBrgi (iErr, idVG, VMST_nCGVW, icG (1), 'nCGVW')
      call AFBrgi (iErr, idVG, VMST_LnCGU, icG (1), 'LnCGU')
c
      if (iErr.eq.0) call AFBgmf (iErr, idVG, ' ', ' ', IE, IFPa)
c
      RETURN
      END
CCC_ & MUVmta  ## Set VMTA attributes
      subroutine MUVmta
     O    (iErr, idVG,
     I     CGRP, icG,  MH,  LH, MZ, LZ, CSW,  CLS, CRT, IFPa, IE,  iMA)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   idVG
      _INTENT(IN, integer)   icG (*)
      _INTENT(IN, integer)   MH,  LH
      _INTENT(IN, integer)   MZ,  LZ
      _INTENT(IN, character) CGRP*(*)
      _INTENT(IN, character) CSW*(*)
      _INTENT(IN, character) CLS*(*), CRT*(*)
      _INTENT(IN, integer)   IFPa (*)
      _INTENT(IN, integer)   IE  (*)
      _INTENT(IN, integer)   iMA (*)
CCC_  * Body
      call AFBrgd
     O    (iErr,
     O     idVG,
     I     CGRP, MH,  LH,  MZ, LZ, VMTA_MAX, icG (1),
     I     CSW,  CLS, CRT, IFPa,   iMA)
c
      call AFBrgi (iErr, idVG, VMTA_age,  icG (1), 'age')
      call AFBrgi (iErr, idVG, VMTA_dad3, icG (1), 'dad3')
      call AFBrgi (iErr, idVG, VMTA_dad1, icG (1), 'dad1')
      call AFBrgi (iErr, idVG, VMTA_dad2, icG (1), 'dad2')
      call AFBrgi (iErr, idVG, VMTA_dadz, icG (1), 'dadz')
c
      if (iErr.eq.0) call AFBgmf (iErr, idVG, ' ', ' ', IE, IFPa)
c
      RETURN
      END
CCC_ & MUVmtd  ## Set VMTD attributes
      subroutine MUVmtd
     O    (iErr, idVG,
     I     CGRP, icG,  MH,  LH, MZ, LZ, CSW,  CLS, CRT, IFPa, IE,  iMA)
CCC_  * Declaration
      implicit none
      _INTENT(OUT,integer)   iErr
      _INTENT(OUT,integer)   idVG
      _INTENT(IN, integer)   icG (*)
      _INTENT(IN, integer)   MH,  LH
      _INTENT(IN, integer)   MZ,  LZ
      _INTENT(IN, character) CGRP*(*)
      _INTENT(IN, character) CSW*(*)
      _INTENT(IN, character) CLS*(*), CRT*(*)
      _INTENT(IN, integer)   IFPa (*)
      _INTENT(IN, integer)   IE  (*)
      _INTENT(IN, integer)   iMA (*)
CCC_  * Body
      call AFBrgd
     O    (iErr,
     O     idVG,
     I     CGRP, MH,  LH,  MZ, LZ, VMTD_MAX, icG (1),
     I     CSW,  CLS, CRT, IFPa,   iMA)
c
      call AFBrgi (iErr, idVG, VMTD_QD,   icG (1), 'qd')
      call AFBrgi (iErr, idVG, VMTD_QU,   icG (1), 'qu')
      call AFBrgi (iErr, idVG, VMTD_QL,   icG (1), 'ql')
      call AFBrgi (iErr, idVG, VMTD_QB,   icG (1), 'qb')
      call AFBrgi (iErr, idVG, VMTD_E1,   icG (1), 'E1')
      call AFBrgi (iErr, idVG, VMTD_E2,   icG (1), 'E2')
      call AFBrgi (iErr, idVG, VMTD_E3p,  icG (1), 'E3p')
      call AFBrgi (iErr, idVG, VMTD_E3m,  icG (1), 'E3m')
      call AFBrgi (iErr, idVG, VMTD_E33,  icG (1), 'E33')
      call AFBrgi (iErr, idVG, VMTD_dAswp, icG (1), 'dAswp')
      call AFBrgi (iErr, idVG, VMTD_dAswm, icG (1), 'dAswm')
      call AFBrgi (iErr, idVG, VMTD_kai,  icG (1), 'kai')
      call AFBrgi (iErr, idVG, VMTD_W1,   icG (1), 'W1')
      call AFBrgi (iErr, idVG, VMTD_W2,   icG (1), 'W2')
c$$$      call AFBrgi (iErr, idVG, VMTD_a1,   icG (1), 'a1')
      call AFBrgi (iErr, idVG, VMTD_a2,   icG (1), 'a2')
      call AFBrgi (iErr, idVG, VMTD_a3,   icG (1), 'a3')
      call AFBrgi (iErr, idVG, VMTD_ba,   icG (1), 'ba')
      call AFBrgi (iErr, idVG, VMTD_cfl,  icG (1), 'cfl')
      call AFBrgi (iErr, idVG, VMTD_udt,  icG (1), 'udt')
c
      if (iErr.eq.0) call AFBgmf (iErr, idVG, ' ', ' ', IE, IFPa)
c
      RETURN
      END
CCC_& MUVCIO  ## Movement/SSA/cluster io announcement
      subroutine MUVCIO (STRA, STRB, IOP)
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
CCC_* [TEST]  ## test
#ifdef TEST_MUVCIO
#include "ofnstd.h"
CCC_ @ MUVtst  ## test program
      program MUVtst
CCC_  - Test suites
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
c
      if (iErr.eq.0) then
         call DMAtma (iMA)
      endif
      if (iErr.eq.0) then
         call MUVtestMain (iErr, ipA, iMA)
      endif
      if (iErr.eq.0) then
         call ACCrep (FPL(ipA), 0)
      endif
      call DevFin (iErr)
      STOP
      END
CCC_ & MUVtestMain  ## check main
      subroutine MUVtestMain (iErr, ipA, iMA)
CCC_  - Declaration
      implicit none
#include "odevva.h"
      _INTENT(OUT,integer)  iErr
      _INTENT(IN, integer)  ipA (*)
      _INTENT(IN, integer)  iMA (*)
CCC_  - Body
      iErr = 0
CCC_  - return
      RETURN
      END
#endif /* TEST_MUVCIO */
CCC_! FOOTER
C Local Variables:
C fff-style: "iciesShermy"
C End:
