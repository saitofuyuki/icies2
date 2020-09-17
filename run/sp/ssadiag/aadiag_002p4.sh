#!/bin/bash
#
#BSUB -n 4
#BSUB -W 1440
#BSUB -R rusage[mem=1000]
#BSUB -J UV_64a-psrun
#BSUB -a UV
#BSUB -o OUT.%J
#BSUB -e ERR.%J

icies_sfx=1f76
icies_var=
IcIES=$HOME/proj/icies/snoopy/icies-Snoopy0.9_${icies_sfx}
SUB=$IcIES/$icies_var/src/movement
work=/atwork/G10205/saitofuyuki/snoopy/ad

NR=4
exp=ad00002_p${NR}

exe=mdrvrm6
EXEorg=$SUB/$exe

inidir=$HOME/bc/aabc/40km

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
 &NIDPTV TAG = 'RUN', VALUE='$exp', &END
 &NIDPCL CLS = ' ', TOP = '%[T0]', SUB   = '%[S0]', &END
 &NIDPTV CLS = ' ', TAG='SUB', VALUE='%[S0]', &END
 &NIDPTV CLS = ' ', TAG='TOP', VALUE='%[T0]', &END
 &NILOGC CH = 'V', ROOT = 'vrep', &END

 &NIMSWD MSW=4, MINI=0, KRF = 0, KRFI = 2, KWI = 0, KTBDZ = 1, KUSG = 0, KVB = 3, KVBSW = 3, KFGSW = 1, KEGSW = 1, &END

 &NIPRMD CLV = 10.0d0, ItrMax=4096, Etol=1d-6, RF=1.0d-18, &END
 &NIPRMS &END

 &NITPMI CROOT = 'ID', KSW = 6, ACC = 0.3d0, HINI = 0.0d0, RF=1.0d-18, &END
 &NITPMS KTEST = 0, WLX = 6000.d3, WLY=6000.d3, DGL = 0.0d3, RF=1.0d-18, &END

 &NISSAL ItrMax=256, Etol=1e-4, ItrMin=64, &END
 &NISSAN ItrMax=8, Etol=1e-1, Prlx=0.9, ItrGL=0, MaxTry=0, KswL=1, KswN=1, KswBT=0, VXLIMU = -1.0d0, VXLIML = 1.D-12, VDNML = 1e-3, &END

 &NITMMD CROOT = 'ID', TINI = 0, TEND = 1, DT = 0.125d0, TSSA = 0, DTRC = 100, &END
 &NIAFWR CROOT = 'ID', GROUP = ' ', DT = 100, KSW = 0, &END
 &NIAFWR CROOT = 'ID', GROUP = 'VMSXI', ISTEP = 0, KSW = 0, &END
 &NIAFWR CROOT = 'ID', GROUP = 'VMSXT', ISTEP = 0, KSW = 0, &END

 &NITAMI CROOT = 'ID', GROUP = 'VMI', IDX = 2, FNM = 'aasbc/b2_40/H', VUNDEF = 0.0d0, IX = 151, IY = 151, &END
 &NITAMI CROOT = 'ID', GROUP = 'VMHB', IDX = 7, FNM = 'aasbc/b2_40/zl', VUNDEF = 0.0d0, IX = 151, IY = 151, &END

 &NIGEOM CROOT = 'ID', CKIND = 'X', O = 0, T = 'R', W = 6000.d3, WN = -1, &END
 &NIGEOM CROOT = 'ID', CKIND = 'Y', O = 0, T = 'R', W = 6000.d3, WN = -1, &END
 &NICOOR CROOT = 'ID', NZ = 17, &END
 &NIEDLA CROOT = 'ID', KDL=3, NXG=151, NYG=151, LXB=1, LYB=1, LXO=0, LYO=0, ISH=1, NR=$NR,  &END

EOF

mpijob "psrun -f ./$EXE < $sysin"
