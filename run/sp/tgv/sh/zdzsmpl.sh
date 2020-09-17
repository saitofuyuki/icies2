#!/usr/bin/zsh -f
# Time-stamp: <2020/09/17 09:08:49 fuyuki zdzsmpl.sh>
# Copyright: 2018--2020 JAMSTEC, Ayako ABE-OUCHI
# Licensed under the Apache License, Version 2.0
#   (https://www.apache.org/licenses/LICENSE-2.0)

odir=asc/zdzs
mkdir -p $odir

refH=$1 refm=$2 intv=$3
[[ $# -lt 3 ]] && print -u2 "Not enough arguments." && exit 1

src=asimp/age_3_12_12.out

refmc=$(units -t -- ${refm}m cm)

gmt math -o1,2 $src -C2 $H $refH MUL $refm DIV NEG = |\
    gmt sample1d -I$intv -T1 |\
    gmt math -o2,0,1 STDIN -N3 -C2 0 ADD 0 COL ADD NEG 1 ADD -C0 DIFF = $odir/zdz_${refH}_${refmc}_$intv.dat
