#!/bin/bash -f
# Time-stamp: <2020/09/17 09:08:36 fuyuki tgv001.sh>
# Copyright: 2018--2020 JAMSTEC, Ayako ABE-OUCHI
# Licensed under the Apache License, Version 2.0
#   (https://www.apache.org/licenses/LICENSE-2.0)

exesrc=./icies_tgv
out=tgv001
inidir=$PWD/ini

mkdir $out
mkdir $out/O
mkdir $out/L
mkdir $out/V

exe=$(basename $exesrc)

cp $exesrc $out/$exe
cd $out

SYSIN=sysin

cat << EOF > $SYSIN
 &NIDMBS KCHECK = 1, FILE = '$SYSIN' &END
 &NIDPTV TAG = 'TOP', VALUE='.', &END
 &NIDPTV TAG = 'SUB', VALUE='%[S3]', &END
 &NILOGC CH = 'V', ROOT = 'vrep', &END
 &NITPMS KTEST = -1, WLX = 100, WLY=0, DGL = , &END
 &NITPMI CROOT='ID', KSW = 0, ACC = 0.3d0, HINI = 0.0d0, &END
 &NIMSWD MSW=0, MINI=0,  &END
 &NIPRMD &END
 &NIPRMS &END
 &NITMMD CROOT='ID', TINI = 0, TEND = 200010, DT = 10, TSSA = 200010, &END
 &NIBTIM CROOT=' ',  CBGL='B', TINI=100000, &END
 &NIAFWR CROOT='ID', GROUP = ' ', DT = 10000, KSW = 0, &END
 &NIPRMT &END
 &NIDATA CROOT='ID', GROUP='VMI', VAR='*', COOR='*', FMT='SKIP', &END
 &NIDATA CROOT='ID', GROUP='VMTI', VAR='*', COOR='*', FMT='SKIP', &END
 &NIDATA CROOT='ID', GROUP='VMHI', VAR='*', COOR='*', FMT='SKIP', &END
 &NIDATA CROOT='ID', GROUP='VMHB', VAR='*', COOR='*', FMT='SKIP', &END
 &NIDATA CROOT='ID', GROUP='VBBI', VAR='*', COOR='*', FMT='SKIP', &END
 &NIDATA CROOT='ID', GROUP='VBBT', VAR='*', COOR='*', FMT='SKIP', &END
 &NIDATA CROOT='ID', GROUP = 'VMHI', VAR = 'oH', COOR = 'ID.Ha', FNM = '$inidir/HH_2000+500_n101.dat', FMT = ' ', VAL = 0, LB = -1, IR = 0, DIMS = 101,1, &END
 &NIDATA CROOT='ID', GROUP = 'VMHI', VAR = 'oB', COOR = 'ID.Ha', FNM = '$inidir/RR_0+200_n101.dat', FMT = ' ', VAL = 0, LB = -1, IR = 0, DIMS = 101,1, &END
 &NIDATA CROOT='ID', GROUP = 'VMHB', VAR = 'Ms', COOR = 'ID.Ha', FNM = '$inidir/MS_p3_2-10cm_n101.dat', FMT = ' ', VAL = 0, LB = -1, IR = 0, DIMS = 101,1, &END
 &NISSAL &END
 &NISSAN &END
 &NIGEOM CROOT='ID', CKIND = 'X', O = 0.5, T = 'R', W = 100, WN = -1, &END
 &NIGEOM CROOT='ID', CKIND = 'Y', O = 0.5, T = 'R', W = 0, WN = 0, &END
 &NICOOR CROOT='ID', NZ = 17, &END
 &NICOOR CROOT='RD', NZ = 9,  &END
 &NIEDLA CROOT='ID', KDL=3, NXG=101, NYG=1, LXB=1, LYB=1, LXO=0, LYO=0, LXW=0, LYW=0, ISH=1, NR=1,  &END
EOF

./$exe < $SYSIN > log 2>&1

