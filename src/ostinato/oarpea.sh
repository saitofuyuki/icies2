#!/usr/bin/zsh -f
# Maintainer:  SAITO Fuyuki
tst='Time-stamp: <2020/09/17 08:28:33 fuyuki oarpea.sh>'
# oarpea.h generation helper

# usage
#  % oarpea.sh [REV] > oarpea.h

put_header ()
{
  local count=$1 rev=$2
  cat <<EOF
/* ostinato/oarpkw.h --- Ostinato/Arpeggio/Elements(A) definitions */
/* Maintainer: SAITO Fuyuki */
/* Created: Dec 29 2011 */
#ifdef HEADER_PROPERTY
#define _TSTAMP '$tst'
#define _FNAME 'ostinato/oarpea.h'
#define _REV   'Arpeggio 1.0'
#endif /* HEADER_PROPERTY */
/***_! MANIFESTO */
/* Copyright (C) 2011--2020 */
/*           Japan Agency for Marine-Earth Science and Technology */
/* Licensed under the Apache License, Version 2.0  */
/*   (https://www.apache.org/licenses/LICENSE-2.0) */
/***_* Definitions */
#ifndef    _OARPEA_H
#  define  _OARPEA_H

#  define  REVID_EA $rev   /* revision id for arpeggio/elements */

EOF
}

put_footer ()
{
  local lastnum=$1; shift || return $?
  local rev=$1
  let lastnum++
  cat <<EOF
/***_ + Key (LS: List MP) */
#define EA_list0(T)     $lastnum
#define EA_idxMU(T,j)   EA_list0(T)+j
#define EA_idxCU(T,j)   EA_list0(T)+EA_size0(T)*1+j
#define EA_idxCT(T,j)   EA_list0(T)+EA_size0(T)*2+j
#define EA_idxLW(T,j)   EA_list0(T)+EA_size0(T)*3+j
#define EA_idxLX(T,j)   EA_list0(T)+EA_size0(T)*4+j
#define EA_idxLY(T,j)   EA_list0(T)+EA_size0(T)*5+j
EOF
  if [[ $rev -gt 257 ]];then
    cat <<EOF
#define EA_idxPW(T,j)   EA_list0(T)+EA_size0(T)*6+j
#define EA_idxPX(T,j)   EA_list0(T)+EA_size0(T)*7+j
#define EA_idxPY(T,j)   EA_list0(T)+EA_size0(T)*8+j
#define EA_idxXW(T,j)   EA_list0(T)+EA_size0(T)*9+j
#define EA_idxYW(T,j)   EA_list0(T)+EA_size0(T)*10+j

#define EA_memL 11
EOF
  else
    cat <<EOF
#define EA_idxPW(T,j)   EA_idxLW(T,j)
#define EA_idxPX(T,j)   EA_idxLX(T,j)
#define EA_idxPY(T,j)   EA_idxLY(T,j)

#define EA_memL 6
EOF
  fi
  cat <<EOF
#define EA_listMU(T,j)  T(EA_idxMU(T,j))
#define EA_listCU(T,j)  T(EA_idxCU(T,j))
#define EA_listCT(T,j)  T(EA_idxCT(T,j))
#define EA_listLW(T,j)  T(EA_idxLW(T,j))
#define EA_listLX(T,j)  T(EA_idxLX(T,j))
#define EA_listLY(T,j)  T(EA_idxLY(T,j))
#define EA_listPW(T,j)  T(EA_idxPW(T,j))
#define EA_listPX(T,j)  T(EA_idxPX(T,j))
#define EA_listPY(T,j)  T(EA_idxPY(T,j))
#define EA_listXW(T,j)  T(EA_idxXW(T,j))
#define EA_listYW(T,j)  T(EA_idxYW(T,j))
EOF
  cat <<EOF
/***_ + Key (LN: List NR) */
#define EA_list1(T)   EA_list0(T)+EA_size0(T)*EA_memL+1
#define EA_listGSS(T,j) T(EA_list1(T)+j)
#define EA_listGSR(T,j) T(EA_list1(T)+EA_size1(T),j)

/***_ + misc helper */
#define EA_IRn(T,dir) T(EA_IRXP()+dir)
#define EA_ISn(T,dir) T(EA_ISXP()+dir)
#define EA_IIn(T,dir) T(EA_IIXP()+dir)

#define EA_NHn(T,dir) T(EA_NHXP()+dir)
#define EA_JIn(T,dir) T(EA_JIXP()+dir)
#define EA_JEn(T,dir) T(EA_JEXP()+dir)
#define EA_JSn(T,dir) T(EA_JSXP()+dir)

/***_ + maximum */
#define EA_MAX(T)     EA_list1(T)+EA_size1(T)*2

/***_* End definitions */
#endif  /* not _OARPEA_H */
/***_! FOOTER */
EOF
}

putdef ()
{
   local comment="$1"; shift
   if [[ -n $comment ]];then
     print
     print "/***_ + Key ($comment) */"
   else
     print
   fi
   local v= x= st=
   for v in $@
   do
     [[ x$v == x-e ]] && st=x && continue
     if [[ $st == x ]];then
       st=
       x="$v"
     else
       let count++
       printf "#define %-12s T($count)" "EA_$v(T)"
       [[ -n $x ]] && print -n "  /* $x */" && x=
       print
     fi
   done
}

rev=$1
[[ -z $rev ]] && rev=258

VALID=(256 257 258)
[[ -z ${(M)VALID:#$rev} ]] && print -u2 "invalid revision $rev (valid: $VALID)" && exit 1

count=0
put_header $count $rev

putdef 'Meta info' VAR LVDBG ERR

basic=(NXG NYG LXO LYO LXB LYB LXW LYW IR NR ISH)

putdef 'PD: configuration' size0 size1
## L[XY]E from rev 257
if [[ $rev -le 256 ]];then
  putdef '' KDL KDLbi KDLnb $basic
else
  putdef '' KDL KDLbi KDLnb $basic LXE LYE
fi
putdef '' argKDL arg${^basic}

if [[ $rev -le 256 ]];then
  putdef 'NM: Sizes' \
       -e "total number of elements"                   NXW NYW \
       -e "effective number of blocks"                 NBG NBP \
       -e "effective number of elements"               NP  NG \
       -e "actual number of elements"                  MX  MY \
       -e "actual number of blocks"                    MBG MBP \
       -e "actual number of elements"                  MP  MG \
       -e "actual number of blocks"                    MBX MBY
elif [[ $rev -eq 257 ]];then
  putdef 'NM: Sizes' \
       -e "total number of elements (wing dupl)"       NXD NYD \
       -e "total number of elements (wing unique)"     NXU NYU \
       -e "effective number of blocks"                 NBG NBP \
       -e "effective number of elements"               NP  NG \
       -e "actual number of elements"                  MX  MY  MG  MP \
       -e "actual number of blocks"                    MBX MBY MBG MBP
else
  putdef 'NM: Sizes' \
       -e "total number of elements (wing dupl)"       NXD NYD \
       -e "total number of elements (wing unique)"     NXU NYU \
       -e "effective number of blocks"                 NBG NBP \
       -e "effective number of elements"               NP  NG \
       -e "actual number of elements (wing unique)"    MXU MYU \
       -e "actual number of elements"                  MX  MY  MG  MP \
       -e "actual number of blocks"                    MBX MBY MBG MBP \
       -e "null block corner (logical)"                INBCX INBCY
fi

neighbor=(XP XM YP YM NE NW SE SW)

putdef 'NH: Neighbourhood' IR${^neighbor}
putdef ''                  IS${^neighbor}
putdef ''                  II${^neighbor}
putdef ''                  NH${^neighbor}

print '/*          IR: rank  IS: offset (clone)  II: offset (interior) */'

putdef 'LP: Loop' JI${^neighbor}
putdef ''         JE${^neighbor}
putdef ''         JS${^neighbor}

print '/*          do l = JI, JE, JS    for clone */'

putdef 'OX: Overlap/X' LCXo LCXi

OX=(WCo WCi ECi ECo)
putdef '' IR${^OX}
putdef '' IS${^OX}
putdef '' ID${^OX}
putdef '' IT${^OX}

putdef 'OY: Overlap/Y' LCYo LCYi

OY=(SCo SCi NCi NCo)
putdef '' IR${^OY}
putdef '' IS${^OY}
putdef '' ID${^OY}
putdef '' IT${^OY}

put_footer $count $rev
