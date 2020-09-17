#!/usr/bin/zsh -f
# Time-stamp: <2020/09/17 09:07:56 fuyuki afig.sh>
# Copyright: 2018--2020 JAMSTEC, Ayako ABE-OUCHI
# Licensed under the Apache License, Version 2.0
#   (https://www.apache.org/licenses/LICENSE-2.0)

main ()
{
  local bset= tset= var=age
  local zaxis=zeta
  local aaxis=yr
  local otype=xgraph
  while [[ $# -gt 0 ]]
  do
    case $1 in
    (-o)  otype=$2; shift;;
    (-o*) otype=${1 :1};;
    (-b) bset=$2; shift;;
    (-t) tset=$2; shift;;
    (-v) var=$2; shift;;
    # z-axis
    (-z) zaxis=z;;
    (-Z) zaxis=zeta;;
    # a-axis
    (-y) aaxis=yr;;
    (-k) aaxis=kyr;;
    (-s) aaxis=scaled;;
    #
    (-*) print -u2 "Unknown argument $1"; return 1;;
    (*)  break;;
    esac
    shift
  done
  local dir=

  for dir in $@
  do
    if [[ -d $dir ]]; then
      draw $var $dir ${bset:--} ${tset:--}
    else
      print -u2 - "Not found $dir"; return 1
    fi
  done

  return 0
}

draw ()
{
  local var=$1; shift || return $?
  local dir=$1; shift || return $?
  local bset=$1 tset=$2
  local zeta=$(mktemp)
  local age=$(mktemp)
  local ages=$(mktemp)
  local tmp=

  [[ x${bset:--} == x- ]] && bset=0,0
  bset=(${(s/,/)bset})
  local xpos=$bset[1]
  local ypos=${bset[2]:-0}

  local vmti=$dir/vmti.nc
  local vmta=$dir/vmta.nc
  local vmtd=$dir/vmtd.nc
  local vmhi=$dir/vmhi.nc
  local vmhr=$dir/vmhr.nc
  local vxcfg=$dir/vxcfg.nc

  for cf in $vmti $vmta $vmtd $vmhi $vmhr $vxcfg
  do
    [[ ! -e $cf ]] && print -u2 - "not exists $cf:t in $cf:h." && return 1
  done

  local dpdZ=$dir/dpdZ.asc
  if [[ ! -e $dpdZ ]];then
    tmp=($(sed -n -e '/^DVSRPA D1 .*ID\.Za/p' $dir/O/error.000*)) || return $?
    [[ -z $tmp ]] && print -u2 - "Panic in dpdZ parser." && return 1
    local nz=$tmp[5] zcf=$tmp[$#tmp] js=$tmp[8] je=$tmp[9]
    print -u2 - $nz $zcf $js $je
    tmp=($(gmt convert -bi${nz}d $dir/$zcf | sed -n -e "${js},${je}p"))
    shift tmp
    print -l "${(@)tmp}" > $dpdZ
  fi

  local cf= ovar=$var
  case $ovar in
  (age*)  var=age.Ta  cf=$vmta;;
  (dadz)  var=dadp.Ta cf=$vmta;;
  (dadZ)  var=dadp.Ta cf=$vmta;;
  (dadp*) var=dadp.Ta cf=$vmta;;
  (w)     var=wadv.Ta cf=$vmti;;
  (wp)    var=E3p.Ta  cf=$vmtd;;
  (dwp)   var=E3m.Ta  cf=$vmtd;;
  (a1*)   var=a1.Ta   cf=$vmtd;;
  (a2*)   var=a2.Ta   cf=$vmtd;;
  (a3*)   var=a3.Ta   cf=$vmtd;;
  (ba*)   var=ba.Ta   cf=$vmtd;;
  esac

  tmp=$(ncks -C -Q -H --trad -d time,-1 -v time $cf)
  local tfin=${${tmp#*\[}%\]*}

  [[ x${tset:--} == x- ]] && tset=::
  tset=("${(@s/:/)tset}")

  local tmin=${tset[1]:-0}
  local tmax=${tset[2]:-$tfin}
  local tstp=${tset[3]:-@20}
  [[ $tstp[1] == '@' ]] && tstp=$(( (tmax-tmin+1) / ${tstp: 1}))
  [[ $tstp -le 0 ]] && tstp=1

  print -u2 - "t: $tmin $tmax $tstp"
  
  local nopts= nzopts=
  nopts=(-V -C -H --trad -d Xa,$xpos -d Ya,$ypos)
  nzopts=(-d Za,1,-1)

  ncks $nopts $nzopts -v Za -d time,-1 $cf > $zeta
  local zax= H=
  [[ $zaxis == z ]] && zax=$(mktemp)

  local refms=$(ncks $nopts -v refMs.Ha $vmhr)
  local refmsm=$(ncks $nopts -v rmsmin.Ha $vxcfg)
  local refH=$(ncks $nopts -v oH.Ha -d time,0 $vmhi)
  print -u2 - "ref: $refH $refms $refmsm"

  local ascale=1
  if [[ $ovar == age && $aaxis == scaled ]];then
    ascale=$(gmt math -Q $refH $refms DIV =)
  fi

  # header
  case $otype in
  (x*) # xgraph
    print "TitleText: $dir [$refH $refms $refmsm]"
    print "TitleFont: helvetica-12"
    print -n "YUnitText: $ovar"
    [[ $aaxis == scaled ]] && print -n " (scaled)"
    print
    if [[ $zaxis == zeta ]];then
      print "XUnitText: zeta"
    else
      print "XUnitText: z"
    fi
    ;;
  esac
  local ti=$tmin yr= kyr=

  local opr=
  while [[ $ti -le $tmax ]]
  do
    yr=$(ncks $nopts -v time -d time,$ti $cf)
    kyr=$(units -t -- ${yr}yr kyr)
    ncks $nopts $nzopts -v $var -d time,$ti $cf > $age
    opr=()
    if [[ $ovar == dadZ ]];then
      opr=($opr $dpdZ MUL)
    elif [[ $ovar == dadz ]];then
      H=$(ncks $nopts -v oH.Ha -d time,$ti $vmhi)
      opr=($opr $dpdZ MUL $H DIV)
    fi
    # print -u2 - "gmt math -Ca $age $opr $ascale DIV = $ages"
    gmt math -Ca $age $opr $ascale DIV = $ages || return $?

    case $otype in
    (x*) # xgraph
      print "\"$kyr kyr\""
      if [[ $zaxis == zeta ]];then
        paste $zeta $ages
      else
        H=$(ncks $nopts -v oH.Ha -d time,$ti $vmhi)
        gmt math -Ca $zeta $H MUL = $zax
        paste $zax $ages
      fi
      print
      ;;
    esac
    ti=$((ti + tstp))
  done

  rm -f $zeta $age $ages $zax
}


main "$@"
exit $?
