#!/usr/bin/zsh -f
# Time-stamp: <2020/09/17 09:08:17 fuyuki mkzb.sh>
# Copyright: 2019--2020 JAMSTEC, Ayako ABE-OUCHI
# Licensed under the Apache License, Version 2.0
#   (https://www.apache.org/licenses/LICENSE-2.0)


pf=3 outer=14 inner=8
while [[ $# -gt 0 ]]
do
  case $1 in
  (-p) pf=$2; shift;;
  (-o) outer=$2; shift;;
  (-i) inner=$2; shift;;
  (*)  break;;
  esac
  shift
done
TRES=$1 HR=$2 MS=$3
if [[ $# -lt 3 ]];then
  print -u2 - "Usage: $0 [OPTIONS]  TRES HREF MS [MB]"
  exit 1
fi

ageni=ageni
ageni_src=(wvi.F90 $ageni.F90)
gfortran -O3 -g -pg -Wall -o $ageni $ageni_src || exit $?

tmpd=$(mktemp --dir)

atmp=$tmpd/dage.asc
./$ageni $pf $outer $inner | gmt math -o0,1 STDIN -C1 $HR MUL $MS DIV = $atmp
NZ=$(wc -l < $atmp)
print "1 -1" >> $atmp

ALL=($(gawk '{print NR-1,$0}' $atmp))

jini=0
aini=0
ostp=0
typeset -A JSEQ
while true
do
  anxt=$((aini + TRES))
  for j depth age in $ALL
  do
    # print -u2 "[$anxt] $j $depth $age"
    [[ $j -le $jini ]] && continue
    if [[ $age -gt $anxt ]];then  
      jstp=$(gmt math -Q $j $jini SUB LOG2 FLOOR 2 EXCH POW =)
      break
    fi
  done
  [[ $ostp == $jstp ]] && jstp=$((jstp / 2))
  ostp=$jstp
  print -u2 - "## $jini $j $jstp $age"
  # exit 0
  [[ $jstp == 1 ]] && break
  jnxt=$jini
  nmdl=0
  for j depth age in $ALL
  do
    [[ $j -lt $jnxt ]] && continue
    if [[ $j -eq $jini ]];then
      jnxt=$((jnxt + jstp))
    elif [[ $j -eq $jnxt ]]; then
      dage=$(gmt math -Q $age $oage SUB =)
      print -u2 - "$oj $odepth $oage $dage"
      let nmdl++
      [[ $dage -gt $TRES ]] && break
      jnxt=$((jnxt + jstp))
    fi
    oage=$age
    oj=$j
    odepth=$depth
  done
  JSEQ[$jstp]=$nmdl

  jini=$oj
  aini=$oage
done

# JSEQ[1]=$((NZ-jini+2))
JSEQ[1]=$((NZ-jini+1))

MDL=(${(nk)JSEQ})
jnxt=0
nlv=0
print -u2 - ${(On)MDL}
for m in ${(On)MDL}
do
  n=1
  for j depth age in $ALL
  do
     if [[ $jnxt == $j ]];then
       print "$nlv $j $depth $age"
       let nlv++
       jnxt=$((jnxt + m))
       let n++
       [[ $n == $JSEQ[$m] ]] && break
     fi
  done
done
print "$nlv $NZ 1 -1"

let nlv++
for m in ${MDL}
do
  print - "## $m $NZ ${JSEQ[$m]} $nlv"
done
