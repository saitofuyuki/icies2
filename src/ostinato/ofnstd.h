/* ostinato/ofnstd.h --- IcIES/Ostinato i/o units definitions */
/* Maintainer:  SAITO Fuyuki */
/* Created: Nov 18 1998 */
#ifdef HEADER_PROPERTY
#define _TSTAMP 'Time-stamp: <2020/09/17 08:48:15 fuyuki ofnstd.h>'
#define _FNAME 'ostinato/ofnstd.h'
#define _REV   'Snoopy0.97'
#endif /* HEADER_PROPERTY */
/***_! MANIFESTO */
/* Copyright (C) 2010--2020 */
/*           Japan Agency for Marine-Earth Science and Technology, */
/*           Ayako ABE-OUCHI */
/* Licensed under the Apache License, Version 2.0 */
/*   (https://www.apache.org/licenses/LICENSE-2.0) */
/***_* Definitions */
#ifndef    _OFNSTD_H
#  define  _OFNSTD_H

#ifndef   LOG_CHANNEL_MAX
#  define LOG_CHANNEL_MAX 39
#endif
/*                          012345678901234567890123456789012345678 == 39 */
#define LOG_CHANNEL_STRING 'ABCDEFGHIJKLMNOPQRSTUVWXYZ 0123456789*-'

#ifndef   LOG_CHANNEL_NUM
#  define LOG_CHANNEL_NUM 26
#endif
#define FPA(A) A(1)
#define FPB(A) A(2)
#define FPC(A) A(3)
#define FPD(A) A(4)
#define FPE(A) A(5)
#define FPF(A) A(6)
#define FPG(A) A(7)
#define FPH(A) A(8)
#define FPI(A) A(9)
#define FPJ(A) A(10)
#define FPK(A) A(11)
#define FPL(A) A(12)
#define FPM(A) A(13)
#define FPN(A) A(14)
#define FPO(A) A(15)
#define FPP(A) A(16)
#define FPQ(A) A(17)
#define FPR(A) A(18)
#define FPS(A) A(19)
#define FPT(A) A(20)
#define FPU(A) A(21)
#define FPV(A) A(22)
#define FPW(A) A(23)
#define FPX(A) A(24)
#define FPY(A) A(25)
#define FPZ(A) A(26)
/***_ + Obsolete macros */
#ifndef   _PFP
#  define _PFP ipA
#endif
/***_  - channels */
#define _PFPA _PFP (1)
#define _PFPB _PFP (2)
#define _PFPC _PFP (3)
#define _PFPD _PFP (4)
#define _PFPE _PFP (5)
#define _PFPF _PFP (6)
#define _PFPG _PFP (7)
#define _PFPH _PFP (8)
#define _PFPI _PFP (9)
#define _PFPJ _PFP (10)
#define _PFPK _PFP (11)
#define _PFPL _PFP (12)
#define _PFPM _PFP (13)
#define _PFPN _PFP (14)
#define _PFPO _PFP (15)
#define _PFPP _PFP (16)
#define _PFPQ _PFP (17)
#define _PFPR _PFP (18)
#define _PFPS _PFP (19)
#define _PFPT _PFP (20)
#define _PFPU _PFP (21)
#define _PFPV _PFP (22)
#define _PFPW _PFP (23)
#define _PFPX _PFP (24)
#define _PFPY _PFP (25)
#define _PFPZ _PFP (26)
/***_* End definitions */
#endif  /* not _OFNSTD_H */
/***_! FOOTER */
