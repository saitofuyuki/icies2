#!/bin/bash
#
#BSUB -n 16
#BSUB -W 1440
#BSUB -R rusage[mem=1000]
#BSUB -J UV_64a-psrun
#BSUB -a UV
#BSUB -o OUT.%J
#BSUB -e ERR.%J

icies_sfx=8d34
icies_var=
IcIES=$HOME/proj/icies/snoopy/icies-Snoopy0.9_${icies_sfx}
SUB=$IcIES/$icies_var/src/movement
work=/atwork/G10205/saitofuyuki/snoopy/ih2

NR=16
exp=heino_001p${NR}a

exe=mdrvrm6
EXEorg=$SUB/$exe

mkdir -p $work
cd $work

mkdir $exp
cd $exp

EXE=exe.$exp

cp $EXEorg $EXE
sysin=sysin

mkdir -p O
mkdir -p V
mkdir -p L

cat <<EOF > $sysin
 &NIDMBS KCHECK = 1, FILE = '$sysin' &END
 &NILOGC CH = 'V', ROOT = 'vrep', &END
 &NIDPCL CLS = ' ', TOP = '%[T0]', SUB   = '%[S0]', &END
 &NIDPTV CLS = ' ', TAG='SUB', VALUE='%[S0]', &END


 &NIPRMD EF = 3.0d0, ETOL=1.d-9, &END
 &NIMSWD MSW=0, MINI=0, KRF = 1, KRFI = 1, KWI = 1, KTBDZ = 0, KVB=1, KVBSW=0,  &END
 &NISSAL ItrMax=1024, Etol=1.d-12, &END
 &NISSAN ItrMax=256, Etol=1.d-8, KswN=, KswL=0, Prlx=1.2d0, &END

 &NITMMD CROOT = 'ID', DT = 0.125d0, TINI=0.0d0, TEND = 200000.0d0, TSSA = 1000000.0d0, TIRC = 0.0d0, DTRC = 2000.d0, &END
 &NITPMI CROOT = 'ID', KSW = 4, HINI = 0.0d0, &END
 &NIAFWR CROOT = 'ID', GROUP = ' ', DT = 2000, KSW = 0, &END
 &NIGEOM CROOT = 'ID', CKIND = 'X', O = 0.5, T = 'R', W = 4000.d3, WN = -1, &END
 &NIGEOM CROOT = 'ID', CKIND = 'Y', O = 0.5, T = 'R', W = 4000.d3, WN = -1, &END
 &NITPMS KTEST = 0, WLX = 4000.d3, WLY=4000.d3, DGL = 0.0d3, &END
 &NICOOR CROOT = 'ID', NZ = 17, &END
 &NIEDLA CROOT = 'ID', KDL=3, NXG=81, NYG=81, LXB=-4, LYB=-4, LXO=0, LYO=0, ISH=-99999, NR=$NR,  &END
EOF

mpijob "psrun -f ./$EXE < $sysin"
