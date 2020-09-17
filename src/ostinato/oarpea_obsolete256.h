C ostinato/oarpkw.h --- Ostinato/Arpeggio/Elements(A) definitions
C Maintainer:  SAITO Fuyuki
C Created: Dec 29 2011
#ifdef HEADER_PROPERTY
#define _TSTAMP 'Time-stamp: <2020/09/17 08:37:45 fuyuki oarpea_obsolete256.h>'
#define _FNAME 'ostinato/oarpea.h'
#define _REV   'Arpeggio 1.0'
#endif /* HEADER_PROPERTY */
CCC_! MANIFESTO
C
C Copyright (C) 2011--2020
C           Japan Agency for Marine-Earth Science and Technology
C
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
CCC_* Definitions
#ifndef    _OARPEA_H
#  define  _OARPEA_H

#  define  REVID_EA 256   /* revision id for arpeggio/elements */


CCC_ + Key (Meta info)
#define EA_VAR(T)    T(1)
#define EA_LVDBG(T)  T(2)
#define EA_ERR(T)    T(3)

CCC_ + Key (PD: configuration)
#define EA_size0(T)  T(4)
#define EA_size1(T)  T(5)

#define EA_KDL(T)    T(6)
#define EA_KDLbi(T)  T(7)
#define EA_KDLnb(T)  T(8)
#define EA_NXG(T)    T(9)
#define EA_NYG(T)    T(10)
#define EA_LXO(T)    T(11)
#define EA_LYO(T)    T(12)
#define EA_LXB(T)    T(13)
#define EA_LYB(T)    T(14)
#define EA_LXW(T)    T(15)
#define EA_LYW(T)    T(16)
#define EA_IR(T)     T(17)
#define EA_NR(T)     T(18)
#define EA_ISH(T)    T(19)

#define EA_argKDL(T) T(20)
#define EA_argNXG(T) T(21)
#define EA_argNYG(T) T(22)
#define EA_argLXO(T) T(23)
#define EA_argLYO(T) T(24)
#define EA_argLXB(T) T(25)
#define EA_argLYB(T) T(26)
#define EA_argLXW(T) T(27)
#define EA_argLYW(T) T(28)
#define EA_argIR(T)  T(29)
#define EA_argNR(T)  T(30)
#define EA_argISH(T) T(31)

CCC_ + Key (NM: Sizes)
#define EA_NXW(T)    T(32)  /* total number of elements */
#define EA_NYW(T)    T(33)
#define EA_NBG(T)    T(34)  /* effective number of blocks */
#define EA_NBP(T)    T(35)
#define EA_NP(T)     T(36)  /* effective number of elements */
#define EA_NG(T)     T(37)
#define EA_MX(T)     T(38)  /* actual number of elements */
#define EA_MY(T)     T(39)
#define EA_MBG(T)    T(40)  /* actual number of blocks */
#define EA_MBP(T)    T(41)
#define EA_MP(T)     T(42)  /* actual number of elements */
#define EA_MG(T)     T(43)
#define EA_MBX(T)    T(44)  /* actual number of blocks */
#define EA_MBY(T)    T(45)

CCC_ + Key (NH: Neighbourhood)
#define EA_IRXP(T)   T(46)
#define EA_IRXM(T)   T(47)
#define EA_IRYP(T)   T(48)
#define EA_IRYM(T)   T(49)
#define EA_IRNE(T)   T(50)
#define EA_IRNW(T)   T(51)
#define EA_IRSE(T)   T(52)
#define EA_IRSW(T)   T(53)

#define EA_ISXP(T)   T(54)
#define EA_ISXM(T)   T(55)
#define EA_ISYP(T)   T(56)
#define EA_ISYM(T)   T(57)
#define EA_ISNE(T)   T(58)
#define EA_ISNW(T)   T(59)
#define EA_ISSE(T)   T(60)
#define EA_ISSW(T)   T(61)

#define EA_IIXP(T)   T(62)
#define EA_IIXM(T)   T(63)
#define EA_IIYP(T)   T(64)
#define EA_IIYM(T)   T(65)
#define EA_IINE(T)   T(66)
#define EA_IINW(T)   T(67)
#define EA_IISE(T)   T(68)
#define EA_IISW(T)   T(69)

#define EA_NHXP(T)   T(70)
#define EA_NHXM(T)   T(71)
#define EA_NHYP(T)   T(72)
#define EA_NHYM(T)   T(73)
#define EA_NHNE(T)   T(74)
#define EA_NHNW(T)   T(75)
#define EA_NHSE(T)   T(76)
#define EA_NHSW(T)   T(77)
CC          IR: rank  IS: offset (clone)  II: offset (interior)

CCC_ + Key (LP: Loop)
#define EA_JIXP(T)   T(78)
#define EA_JIXM(T)   T(79)
#define EA_JIYP(T)   T(80)
#define EA_JIYM(T)   T(81)
#define EA_JINE(T)   T(82)
#define EA_JINW(T)   T(83)
#define EA_JISE(T)   T(84)
#define EA_JISW(T)   T(85)

#define EA_JEXP(T)   T(86)
#define EA_JEXM(T)   T(87)
#define EA_JEYP(T)   T(88)
#define EA_JEYM(T)   T(89)
#define EA_JENE(T)   T(90)
#define EA_JENW(T)   T(91)
#define EA_JESE(T)   T(92)
#define EA_JESW(T)   T(93)

#define EA_JSXP(T)   T(94)
#define EA_JSXM(T)   T(95)
#define EA_JSYP(T)   T(96)
#define EA_JSYM(T)   T(97)
#define EA_JSNE(T)   T(98)
#define EA_JSNW(T)   T(99)
#define EA_JSSE(T)   T(100)
#define EA_JSSW(T)   T(101)
CC          do l = JI, JE, JS    for clone

CCC_ + Key (OX: Overlap/X)
#define EA_LCXo(T)   T(102)
#define EA_LCXi(T)   T(103)

#define EA_IRWCo(T)  T(104)
#define EA_IRWCi(T)  T(105)
#define EA_IRECi(T)  T(106)
#define EA_IRECo(T)  T(107)

#define EA_ISWCo(T)  T(108)
#define EA_ISWCi(T)  T(109)
#define EA_ISECi(T)  T(110)
#define EA_ISECo(T)  T(111)

#define EA_IDWCo(T)  T(112)
#define EA_IDWCi(T)  T(113)
#define EA_IDECi(T)  T(114)
#define EA_IDECo(T)  T(115)

#define EA_ITWCo(T)  T(116)
#define EA_ITWCi(T)  T(117)
#define EA_ITECi(T)  T(118)
#define EA_ITECo(T)  T(119)

CCC_ + Key (OY: Overlap/Y)
#define EA_LCYo(T)   T(120)
#define EA_LCYi(T)   T(121)

#define EA_IRSCo(T)  T(122)
#define EA_IRSCi(T)  T(123)
#define EA_IRNCi(T)  T(124)
#define EA_IRNCo(T)  T(125)

#define EA_ISSCo(T)  T(126)
#define EA_ISSCi(T)  T(127)
#define EA_ISNCi(T)  T(128)
#define EA_ISNCo(T)  T(129)

#define EA_IDSCo(T)  T(130)
#define EA_IDSCi(T)  T(131)
#define EA_IDNCi(T)  T(132)
#define EA_IDNCo(T)  T(133)

#define EA_ITSCo(T)  T(134)
#define EA_ITSCi(T)  T(135)
#define EA_ITNCi(T)  T(136)
#define EA_ITNCo(T)  T(137)
CCC_ + Key (LS: List MP)
#define EA_list0(T)     138
#define EA_idxMU(T,j)   EA_list0(T)+j
#define EA_idxCU(T,j)   EA_list0(T)+EA_size0(T)*1+j
#define EA_idxCT(T,j)   EA_list0(T)+EA_size0(T)*2+j
#define EA_idxLW(T,j)   EA_list0(T)+EA_size0(T)*3+j
#define EA_idxLX(T,j)   EA_list0(T)+EA_size0(T)*4+j
#define EA_idxLY(T,j)   EA_list0(T)+EA_size0(T)*5+j

#define EA_listMU(T,j)  T(EA_idxMU(T,j))
#define EA_listCU(T,j)  T(EA_idxCU(T,j))
#define EA_listCT(T,j)  T(EA_idxCT(T,j))
#define EA_listLW(T,j)  T(EA_idxLW(T,j))
#define EA_listLX(T,j)  T(EA_idxLX(T,j))
#define EA_listLY(T,j)  T(EA_idxLY(T,j))

CCC_ + Key (LN: List NR)
#define EA_list1(T)   EA_list0(T)+EA_size0(T)*6+1
#define EA_listGSS(T,j) T(EA_list1(T)+j)
#define EA_listGSR(T,j) T(EA_list1(T)+EA_size1(T),j)

CCC_ + misc helper
#define EA_IRn(T,dir) T(EA_IRXP()+dir)
#define EA_ISn(T,dir) T(EA_ISXP()+dir)
#define EA_IIn(T,dir) T(EA_IIXP()+dir)

#define EA_NHn(T,dir) T(EA_NHXP()+dir)
#define EA_JIn(T,dir) T(EA_JIXP()+dir)
#define EA_JEn(T,dir) T(EA_JEXP()+dir)
#define EA_JSn(T,dir) T(EA_JSXP()+dir)
<
CCC_ + maximum
#define EA_MAX(T)     EA_list1(T)+EA_size1(T)*2

CCC_* End definitions
#endif  /* not _OARPEA_H */
CCC_! FOOTER
C Local Variables:
C mode: fortran
C fff-style: "iciesShermy"
C End:
