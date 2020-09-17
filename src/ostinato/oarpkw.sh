#!/usr/bin/zsh -f
# Maintainer:  SAITO Fuyuki
# Time-stamp: <2020/09/17 08:22:08 fuyuki oarpkw.sh>
# oarpkw.h, akwopr::akbtbi () generation helper

# Copyright: 2016--2020 JAMSTEC, Ayako ABE-OUCHI
# Licensed under the Apache License, Version 2.0
#   (https://www.apache.org/licenses/LICENSE-2.0)

# usage
#  % oarpkw.sh > hoge
#  manually insert hoge to oarpkw.h, akwopr.F

count=0

putdef ()
{
   local comment="$1"; shift
   if [[ -n $comment ]];then
     print "/***_  * $comment */"
   fi
   local v
   for v in $@
   do
     if [[ $sw == h ]];then
       let count++
       printf "#define %-12s $count" "KWO_$v"; print
     else
       print "      Tbl (KWO_$v) = '$PFX$v'"
     fi
   done
   if [[ $sw == h ]];then
     print
   fi
}

for sw in h f
do
  putdef "Gradient" GXab GXba GXcd GXdc
  putdef ""         GYac GYca GYbd GYdb

  putdef "Divergence" DXab DXba DXcd DXdc
  putdef ""           DYac DYca DYbd DYdb

  putdef "Linear interpolation" Lab Lba Lcd Ldc Lac Lca Lbd Ldb

  PFX=C
  putdef "Exchange overlapped"  EWo WEo SNo NSo EWi WEi SNi NSi

  PFX=
  putdef "Simple addition"      SAab SAba SAcd SAdc SAac SAca SAbd SAdb

  putdef "Simple subtraction"   SDab SDba SDcd SDdc SDac SDca SDbd SDdb

  putdef "Full clone"           FCab FCba FCcd FCdc FCac FCca FCbd FCdb

  pat=(ab ba cd dc ac ca bd db)
  putdef "User def 0"           U0${^pat}
  putdef "User def 1"           U1${^pat}
  putdef "User def 2"           U2${^pat}

  [[ $sw == h ]] && print "#define KWO2_MAX $count" && print

  putdef "Derivative (for coordinates transfomation)" XXa XXb XXc XXd
  putdef ""                                           YYa YYb YYc YYd
  putdef ""                                           XYa XYb XYc XYd
  putdef ""                                           YXa YXb YXc YXd

  putdef "Coordinates" Xa Xb Xc Xd
  putdef ""            Ya Yb Yc Yd

  putdef "Size"        dXa dXb dXc dXd
  putdef ""            dYa dYb dYc dYd

  putdef "Odd field mask"   ZXa ZXb ZXc ZXd
  putdef ""                 ZYa ZYb ZYc ZYd

  putdef "Area"        Aa  Ab  Ac  Ad

  putdef "Wing mask"   MWa MWb MWc MWd

  PFX=
  putdef "Exchange wings"       HEW HWE HSN HNS

  [[ $sw == h ]] && print "#define KWO1_MAX $count" && print

  putdef "Meta-info"   MIO MIA

  [[ $sw == h ]] && print "#define KWO_MAX $count" && print
done
