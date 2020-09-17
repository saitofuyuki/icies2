#!/usr/bin/zsh -f
# Time-stamp: <2020/09/17 09:08:04 fuyuki gfig.sh>
# Copyright: 2018--2020 JAMSTEC, Ayako ABE-OUCHI
# Licensed under the Apache License, Version 2.0
#   (https://www.apache.org/licenses/LICENSE-2.0)

zmodload zsh/zprof

main ()
{
  typeset -g zprof=

  local ascd=asc
  local xsol=xsol

  local quick= verbose=
  local dopts=() xopts=() sopts=()
  local -A Xset=()
  local draw=()
  local CHP='+'
  local OUTPUT=()

  local APREC=f

  ## general options
  ##   -V verbose
  ##   -q quick
  ## options for selection
  ##   -b HPOS,APOS
  ##   -t TIMES
  ##   -r REFERENCE
  ## options for draw
  ##   -d DRAW-ID,....
  ##   -p PREFIX
  ##   -s SUFFIX
  ##   -R VAR=RL:RH  (obsolete)
  ##   -P VAR=VALUE
  ##   -v VAR=CONFIG
  ##   -C VARIOUS-OPTIONS
  ##   -L LEGEND (independent)
  ##   +L LEGEND (included)
  ##
  ## paramters
  ##   DIRECTORY|REPLACEMENT[+PROP...]
  ##   DIRECTORY|REPLACEMENT [+PROP..] [+PROP..]
  ##
  ##   REPLACEMENT: [i]KEY=VALUE,...
  ##
  ##   if DIRECTORY == '/' update base directory for reference
  ##
  ## draw options
  ##   -C KEY+PROP[+PROP..]
  ##   -C KEY=[+]PROP[+PROP..]
  ##   -C [=]+PROP[+PROP..]    for default
  ##
  ##   PROP  +ID[FLAGS]
  ##
  ##   KEY   0: default
  ##         X: experiment
  ##         T: time index
  ##         S: solution
  ##         9: final
  ##   ID    c: color
  ##         w: width
  ##         t: texture
  ##         d: dim-color
  ##         s: symbol                  +sSYM0,[SIM1,...]
  ##         a: symbol size             +aSIZE0,[SIZE1,...]
  ##         l: title                   +l"STRING"
  ##         o: order                   +oPRIORITY
  ##         m: mod (symbol interval)   +m[DIV[:MOD]]
  ##   FLAG  -  to cancel
  ##         :  to skip (use default)
  ##         [K0:]V0[,[K1:V1...]]
  ##         Value distributed along item if with ','.
  ##
  ## variable parameters
  ##   -v VAR+PROP[+PROP..]
  ##   -v VAR=[+]PROP[+PROP..]
  ##   -v [=]+PROP[+PROP..]     for default
  ##
  ##    PROP
  ##      either / for separator
  ##       +jJX[/JY]             basemap size
  ##       +r[LOW][/HIGH]          region
  ##       +bBFLAG[/BFLAG(log)]  basemap axis properties
  ##      only : for separator
  ##       +uDRAW-UNIT
  ##       +iINCREMENT
  ##       +LPARAMS             symmetry-log plot parameters
  ##                            LOG-MAG:LINEAR-MAG:ANNOT-SPACING
  ##       +lNAME               (must be last)

  ## parser
  while [[ $# -gt 0 ]]
  do
    case $1 in
    (--draft) dopts+=("$1");;
    (--tex)   dopts+=("$1");;
    (--zprof) zprof=T;;
    (-V)   verbose=$1 xopts+=("$1");;
    (-q)   quick=-q;;
    (-d)   draw=$2; shift;;
    (-d*)  draw=${1: 2};;
    (-[btr])  Xset[$1]="$2"; shift;;
    (-[btr]*) Xset[${1: :2}]="${1: 2}";;
    (-n)   dry=$1 dopts+=("$1");;
    ([---+]L*)    dopts+=("$1");;
    ([---+][ps])  dopts+=("$1" "$2"); shift;;
    ([---+][ps]*) dopts+=("$1");;
    (-[Cv])       dopts+=("$1" "$2"); shift;;
    (-[Cv]*)      dopts+=("$1");;
    (-P)          dopts+=("$1" "$2"); xopts+=("$1" "$2"); shift;;
    (-P*)         dopts+=("$1");      xopts+=("$1");;
    #
    (-*) print -u2 "Unknown argument $1"; return 1;;
    (*)  break;;
    esac
    shift
  done

  : ${draw:=all}

  [[ -n $verbose ]] && diag -p "$0: " -u2 Xset dopts

  : ${Xset[-b]:=0,0}
  : ${Xset[-t]:=-1}

  sopts=("${(@)sopts}" -a "$ascd" --prec="${APREC:-f}")
  xopts=("${(@)xopts}" -a "$ascd" --prec="${APREC:-f}" -S "$xsol")
  dopts=("${(@)dopts}" -a "$ascd" --prec="${APREC:-f}" +${CHP})

  local -A comx=() unqx=()

  local dir= DIR=()
  local args=()
  local -A xcfg=()
  local jd= prop=
  local -A xid=()
  ## directory parser
  ##   DIR=('HEAD BASE' ....)
  ##   ARGS=(BASE/bH_A+PROP ....)
  jd=1
  for dirx in $@
  do
    if [[ $dirx[1] == "$CHP" ]];then
      args[-1]="$args[-1]$dirx"
    elif [[ $dirx == '/' ]]; then
      basexi=$#DIR; let basexi++
    else
      gen_xdir dir prop xid "${CHP}" "$dirx" "${Xset[-b]}" "${(@)DIR}" || return $?
      print -u2 - "$0: ${dir}"
      DIR+=("$dir")
      extract_all "${(@)xopts}" $quick xid xcfg $jd "${(@)dir}" "${Xset[-b]}" "${Xset[-t]}" || return $?
      args+=("$dir[2]${prop}")
      let jd++
    fi
  done

  check_xprops comx unqx "${(@)DIR}" || return $?
  ## draw raw
  if [[ -z $Xset[-r] ]];then
    draw_all -DS "${(@)dopts}" xcfg comx unqx $draw "${Xset[-t]}" "${(@)args}" || return $?
    draw_all -DC "${(@)dopts}" xcfg comx unqx $draw - "${(@)args}" || return $?
  fi

  ## difference from reference
  local refd= refx=() ddir=
  if [[ -n $Xset[-r] ]];then
    refx=("${(@s:,:)Xset[-r]}")
    local keepr=
    jd=1
    if [[ ${Xset[-r]} =~ ^[0-9] ]];then
      gen_xdir refd prop xid "${CHP}" "=$refx" +1 "${(@)DIR}" || return $?
      get_refid "${CHP}" refx "$comx[0]" $refd
      keepr=T
    fi
    for dir in "${(@)DIR}"
    do
      dir=(${=dir})
      # bset == +1 means to copy from dir:1
      if [[ -z $keepr ]]; then
        gen_xdir refd prop xid "${CHP}" "$refx" +1 "$dir" || return $?
      fi
      if [[ $dir[1] == $refd[1] && $dir[2] == $refd[2] ]]; then
        print -u2 "$0: $dir: same as reference"
        ddir=-
      else
        print -u2 - "$0: ${dir} - ${refd}"
        if [[ $refx != smpl ]]; then
          extract_all "${(@)xopts}" $quick xid xcfg $jd/r "${(@)refd}" "${Xset[-b]}" "${Xset[-t]}" || return $?
        fi
        sub_all "${(@)sopts}" ddir xcfg $jd "$refx" $refd[2] $dir[2] "$dir[1]" "${Xset[-t]}"  || return $?
      fi
      prop=${(M)args[$jd]%%${CHP}*}
      args[$jd]="${ddir}:${refd[2]}$prop"
      let jd++
    done
    draw_all -DR="$refx" "${(@)dopts}" xcfg comx unqx $draw "${Xset[-t]}" "${(@)args}" || return $?
  fi

  [[ -n $OUTPUT ]] && print -l "${(ou@)OUTPUT}"

  return 0
}

# extract results
#   extract_all [OPTIONS] XID XCFG JXCFG DIRH DIR BSET TSET
extract_all ()
{
  local tmp= src= dest=
  local tag= var= sub=
  local quick= verbose= ascd= xsol= prec=f
  local params=()
  local force=(-f)
  while [[ $# -gt 0 ]]
  do
    case $1 in
    (-q)  quick=$1;;
    (-V)  verbose=$1;;
    (-a)  ascd=$2; shift;;
    (-a*) ascd=${1: 2};;
    (-S)  xsol=$2; shift;;
    (-S*) xsol=${1: 2};;
    (-P)  params+=($1 $2); shift;;
    (-P*) params+=($1);;
    (--prec) prec=$2; shift;;
    (--prec=*) prec=${1#*=};;
    (*)  break;;
    esac
    shift
  done
  local _xid=$1; shift || return $?
  local __xcfg=$1; shift || return $?

  local jxcfg=$1; shift || return $?
  local dirh="$1" dir="$2";  shift 2 || return $?
  local bset=$1   tset="$2"; shift 2 || return $?

  [[ $_xid == xid ]] || local -A xid=("${(@Pkv)_xid}")
  [[ $__xcfg == xcfg ]] || local -A xcfg=()

  local k= v=
  local -A lcfg=()
  local p=()
  for k v in "${(@kv)xid}"
  do
    lcfg[+$k]="$v"
    p+=("$k:$v")
  done
  lcfg[+]="$p"

  local -A afile=()
  local xdir=

  while true
  do
    xdir=$dirh/$dir
    if [[ -e $xdir/vmta.nc ]]; then
      break
    elif [[ -e $xdir:h/vmta.nc ]]; then
      bset=${${xdir:t}#b}; bset=${bset/_/,}
      xdir=$xdir:h
      dir=$dir:h
      break
    fi
    [[ $dirh == . ]] && print -u2 "Cannot found xdir $dir" && return 1
    dirh=${$dirh:h:-.}
  done

  local vmta=$xdir/vmta.nc
  local vmti=$xdir/vmti.nc
  local vmtd=$xdir/vmtd.nc
  local vmhi=$xdir/vmhi.nc
  local vmhb=$xdir/vmhb.nc
  local vmhr=$xdir/vmhr.nc
  local vxcfg=$xdir/vxcfg.nc

  local cf=
  if [[ -z $quick ]];then
    for cf in $vmti $vmta $vmtd $vmhi $vmhr $vxcfg $vmhb
    do
      [[ ! -e $cf ]] && print -u2 - "not exists $cf:t in $cf:h." && return 1
    done
  fi

  local ascx=$ascd/$dir; mkdir -p $ascx

  bset=("${(@s/,/)bset}")
  local bid=b${(j/_/)bset}
  local ascb=$ascx/$bid; mkdir -p $ascb
  local cfgf=$ascb/xcfg

  local Hpos=$bset[1]
  local Apos=${bset[2]:-0}
  local nopts=(-V -C -H --trad)
  local nhopts=(-d Xa,$Hpos -d Ya,$Apos)
  local nzopts=(-d Za,1,-1)

  local boarg= biarg= bargs= obin=
  case $prec in
  (a*) ;;
  (*)  obin=T;;
  esac

  if [[ -e $cfgf ]]; then
    # print -u2 - "$0: load $cfgf"
    . ${(a)cfgf} || return $?
  else
    cfbase=$vmta
    # coordinates
    local nz= zcf= js= je=
    for tag var in D1 dZdp   CO p   DC dp   DP dZ   CP Z
    do
      for sub in a b
      do
        dest=$ascx/$var.$sub
        afile[$var.$sub]=$dest
        if [[ ! -e $dest ]];then
          tmp=($(sed -n -e "/^DVSRPA $tag .*ID\\.Z${sub}/p" $xdir/O/error.000*)) || return $?
          [[ -z $tmp ]] && print -u2 - "Panic in $dest:t parser." && return 1
          nz=$tmp[5] zcf=$tmp[$#tmp] js=$tmp[8] je=$tmp[9]
          tmp=($(gmt convert -bi${nz}d $xdir/$zcf | sed -n -e "${js},${je}p"))
          shift tmp
          if [[ -n $obin ]]; then
            print -l "${(@)tmp}" | gmt convert -bo1${prec} > $dest
          else
            print -l "${(@)tmp}" > $dest
          fi
        fi
      done
    done
    # normalized depth
    var=D
    bargs=()
    [[ -n $obin ]] && bargs=(-bi1$prec -bo1$prec)
    for sub in a b
    do
      dest=$ascx/$var.$sub
      src=$ascx/Z.$sub
      afile[$var.$sub]=$dest
      update_if_new $verbose $force -m $dest $src -- $biarg $bargs -Ca 1 $src SUB
    done
    # experiment
    for var in msmin msmax mbmin mbmax hmin hmax
    do
      lcfg[$var]=$(ncks $nopts $nhopts -v $var.Ha $vxcfg) || return $?
    done

    # time index for field, history
    local tfin= tyf= btyf=
    for tag src in .base $cfbase .hb $vmhb
    do
      tmp=$(ncks -C -Q -H --trad -d time,-1 -v time $src)
      tfin=${${tmp#*\[}%\]*}
      tyf=$ascx/ty$tag
      lcfg[tfin$tag]=$tfin
      lcfg[tyf$tag]=$tyf
      if [[ ! -e $tyf ]]; then
        print - "## ti bti yr kyr" > $tyf
        ncks --trad -V -C -Q -H -v time $src |\
          gawk -v e=$tfin 'NF>0{print NR-1, NR-e-2, $1, $1/1000}' >> $tyf
      fi
      if [[ -n $prec ]]; then
        btyf=$ascx/ty$tag.dat
        lcfg[btyf$tag]=$btyf
        gmt convert $tyf -bo2i,2$prec > $btyf
      fi
    done
    # history
    boarg=
    [[ -n $obin ]] && boarg=-bo1${prec}
    for var tag in ms Ms mb Mb
    do
      dest=$ascb/$var
      afile[$var]=$dest
      update_if_new $verbose $force $boarg -s $dest $vmhb -- ncks $nopts $nhopts -v $tag.Ha $vmhb
      # [[ ! -e $dest ]] && ncks $nopts $nhopts -v $tag.Ha $vmhb > $dest
    done
    for var tag in h oH
    do
      dest=$ascb/$var
      afile[$var]=$dest
      update_if_new $verbose $force $boarg -s $dest $vmhi -- ncks $nopts $nhopts -v $tag.Ha $vmhi
    done
    # /solution/
    local a= b=
    local SOLDIR=() SMPLDIR=() dirss=()
    if [[ -n $SKIPSOL ]]; then
      print -u2 - "Skip solution"
    else
      for a in msmax msmin
      do
        for b in mbmax mbmin
        do
          gen_sol "${(@)params}" --prec=$prec -a $ascd -S $xsol dirss xid lcfg $a $b hmax $afile[D.a] $afile[Z.a] || return $?
          [[ -n ${(M)SMPLDIR:#$dirss[1]} ]] || SMPLDIR+=("$dirss[1]")
          [[ -n ${(M)SOLDIR:#$dirss[2]} ]] || SOLDIR+=("$dirss[2]")
        done
      done
      lcfg[soldir]="${SOLDIR}"
      lcfg[smpldir]="${SMPLDIR}"
    fi
    print - "# automatically generated on $(date --rfc-3339=seconds)." > $cfgf
    for k v in "${(@kv)lcfg}"
    do
      print - "lcfg[$k]=${(q-)v}"
    done >> $cfgf
    for k v in "${(@kv)afile}"
    do
      print - "afile[$k]=${(q-)v}"
    done >> $cfgf
  fi

  get_time_range TSET $lcfg[tfin.base] "${(@s/,/)tset}"
  local ti= gv=dadp
  local agef= dadpf= dadkf= dadzf= zf= df= yr=
  ncdump -h $vmta | grep --silent 'double dad3' && gv=dad3
  if [[ -z $quick ]];then
    boarg= biarg=
    [[ -n $obin ]] && boarg=-bo1${prec} biarg=-bi1${prec}
    bargs=($boarg $biarg)

    for ti in "${(@)TSET}"
    do
      agef=$ascb/a_$ti
      if update_if_new $verbose $force -s $agef  $vmta; then
        dadpf=$ascb/dadp_$ti
        dadkf=$ascb/dadk_$ti
        dadzf=$ascb/g_$ti
        zf=$ascb/z_$ti
        df=$ascb/d_$ti
        dzdaf=$ascb/ginv_$ti
        altf=$ascb/A_$ti
        H=$(ncks $nopts $nhopts -v oH.Ha -d time,$ti $vmhi)
        yr=$(ncks $nopts $nhopts -v time -d time,$ti $vmta)
        if [[ -n $obin ]];then
          ncks $nopts $nhopts $nzopts -v age.Ta  -d time,$ti $vmta | gmt convert $boarg > $agef
        else
          ncks $nopts $nhopts $nzopts -v age.Ta  -d time,$ti $vmta > $agef
        fi
        update_if_new $verbose $force $boarg -s $agef  $vmta       -- ncks $nopts $nhopts $nzopts -v age.Ta  -d time,$ti $vmta
        update_if_new $verbose $force $boarg -s $dadpf $vmta       -- ncks $nopts $nhopts $nzopts -v $gv.Ta  -d time,$ti $vmta
        update_if_new $verbose $force        -m $dadkf $dadpf      -- $bargs -Ca $dadpf $afile[dp.a] MUL
        update_if_new $verbose $force        -m $dadzf $dadpf      -- $bargs -Ca $dadpf $afile[dZdp.a] DIV $H DIV
        update_if_new $verbose $force        -m $zf    $afile[Z.a] -- $bargs -Ca   $afile[Z.a]     $H MUL
        update_if_new $verbose $force        -m $df    $afile[Z.a] -- $bargs -Ca 1 $afile[Z.a] SUB $H MUL
        update_if_new $verbose $force        -m $dzdaf $dadzf      -- $bargs -Ca $dadzf 0 NAN INV
        update_if_new $verbose $force        -m $altf  $dzdaf      -- $bargs -Ca $dzdaf NEG DUP $lcfg[msmax] 10 MUL LT 0 NAN OR
      fi
    done
  fi

  # return
  local jx=
  for k v in "${(@kv)lcfg}"
  do
    xcfg[${jxcfg}:$k]="$v"
  done

  # diag -u2 xcfg
  [[ $__xcfg == xcfg ]] || set -A $__xcfg "${(@kv)xcfg}"
  return 0
}

# results subtraction
#   sub_all [OPTIONS] DDIR XCFG JXCFG RSET REFX DIR TSET
sub_all ()
{
  # set -x
  local prec=f
  while [[ $# -gt 0 ]]
  do
    case $1 in
    (-q)  quick=$1;;
    (-V)  verbose=$1;;
    (-a)  ascd=$2; shift;;
    (-a*) ascd=${1: 2};;
    (--prec) prec=$2; shift;;
    (--prec=*) prec=${1#*=};;
    (*)  break;;
    esac
    shift
  done
  local __ddir=$1; shift || return $?
  local __xcfg=$1; shift || return $?
  local jxcfg=$1; shift || return $?
  local rset=$1; shift || return $?
  local refx=$1; shift || return $?
  local dir=$1 dirh=$2; shift 2 || return $?
  local tset=$1; shift || return $?

  [[ $__ddir == ddir ]] || local ddir=
  [[ $__xcfg == xcfg ]] || local -A xcfg=("${(@Pkv)__xcfg}")

  get_time_range TSET $xcfg[${jxcfg}:tfin.base] "${(@s/,/)tset}"
  local tyf=$xcfg[${jxcfg}:tyf.base]

  local refid=()
  local -A dpr=()
  parse_dir -u dpr "$dirh" "$dir"
  # parse_dir -u dpr "$dir"
  ## print -u2 - "$dpr // $dirh $dir"
  local k= v=
  for v in "${=rset}"
  do
    k=${v%%=*}
    v=${v#*=}
    [[ $dpr[$k] != $v ]] && refid+=($k=$v)
  done

  local did=
  unparse_dir did - $refid
  [[ -z $did ]] && did=${(j::)refid}
  # print -u2 - "$0: $refid $did"

  # fields extraction
  local ti=

  ddir=$dir/$did
  local odir=$ascd/$ddir; mkdir -p $odir

  local obin= boarg= biarg=
  case $prec in
  (a*) ;;
  (*)  obin=T boarg=-bo1$prec biarg=-bi1$prec;;
  esac

  local vf= rf= xf= var= df= drf=

  local Zref=$ascd/$refx:h/Z.a
  [[ ! -e $Zref ]] && Zref=$ascd/$refx/Z.a
  [[ ! -e $Zref ]] && Zref=$ascd/$refx/Z
  local Zexp=$ascd/$dir:h/Z.a
  local tyr= clip=
  
  if cmp --silent $Zref $Zexp; then
    [[ -n $verbose ]] && print -u2 - "$0: same Z coordinate"
    for var in a g ginv A
    do
      for ti in "${(@)TSET}"
      do
        tyr=($(sed -n -e "/^$ti /p" $tyf)); tyr=$tyr[3]
        # print -u2 - "$0: $ti $tyr"
        vf=${var}_$ti
        rf=$ascd/$refx/$vf
        clip=
        [[ ! -e $rf ]] && rf=$ascd/$refx/${var} clip=T
        xf=$ascd/$dir/$vf
        df=$odir/$vf
        drf=$odir/dr.$vf
        if [[ ! -e $df ]]; then
          if [[ -e $rf && -e $xf ]]; then
              if [[ $var == a && -n $clip ]]; then
                gmt math $biarg $boarg -Ca $xf $rf $tyr MIN SUB = $df
              else
                gmt math $biarg $boarg -Ca $xf $rf SUB = $df
              fi
          else
            [[ ! -e $rf ]] && print -u2 "$0: not found $rf"
            [[ ! -e $xf ]] && print -u2 "$0: not found $xf"
            return 1
          fi
        fi
        if [[ ! -e $drf ]]; then
          if [[ -e $rf && -e $xf ]]; then
              if [[ $var == a && -n $clip ]]; then
                gmt math $biarg $boarg -Ca $xf $rf $tyr MIN SUB $rf DIV = $drf
              else
                gmt math $biarg $boarg -Ca $xf $rf SUB $rf DIV = $drf
              fi
          else
            [[ ! -e $rf ]] && print -u2 "$0: not found $rf"
            [[ ! -e $xf ]] && print -u2 "$0: not found $xf"
            return 1
          fi
        fi
      done
    done
  else
    [[ -n $verbose ]] && print -u2 - "$0: different Z coordinate"
    print -u2 - "$Zexp vs $Zref"
    print -u2 - "$0: Not implemented yet"
    return 1
  fi
  [[ $__ddir == ddir ]] || : ${(P)__ddir::=$ddir}

  return 0
}

gen_sol ()
{
  local ascd= xsol=
  local AGE= LEV= prec=f
  local k= v=
  while [[ $# -gt 0 ]]
  do
    case $1 in
    (-a) ascd=$2; shift;;
    (-S) xsol=$2; shift;;
    (--prec) prec=$2; shift;;
    (--prec=*) prec=${1#*=};;
    (-P*) if [[ x$1 == x-P ]];then
            v="$2="; shift
          else
            v="${1: 2}="
          fi
          k=${v%%=*}
          v=${${v#*=}: :-1}
          : ${(P)k::=$v}
          ;;
    (*)  break;;
    esac
    shift
  done
  local __sold=$1; shift || return $?
  local __xid=$1; shift || return $?
  local _lcfg=$1; shift || return $?
  [[ $__sold == soldir ]] || local -a soldir=("${(@P)__sold}")
  [[ $__xid  == xid    ]] || local -A xid=("${(@Pkv)__xid}")
  [[ $_lcfg  == lcfg   ]] || local -A lcfg=("${(@Pkv)_lcfg}")
  local ka=$1 kb=$2 kh=$3; shift 3 || return $?
  local ma=$lcfg[$ka]
  local mb=$lcfg[$kb]
  local rh=$lcfg[$kh]
  local dp=$1; shift || return $?
  local zp=$1

  local ida=$ma idb=$mb
  local u= t=
  for u in cm mm um
  do
    t=$(units -t -1 -- ${ma}m $u)
    [[ $t -eq $(printf '%.0f' $t) ]] && ida=${t}$u && break
  done
  if [[ $mb -ne 0 ]]; then
    local negm=$((-mb))
    for u in cm mm um
    do
      t=$(units -t -1 -- ${negm}m $u)
      [[ $t -eq $(printf '%.0f' $t) ]] && idb=${t}$u && break
    done
  fi
  AGE=("${(s/:/)AGE}")
  : ${AGE[2]:=12}
  : ${AGE[3]:=4}
  if [[ x${AGE[1]:--} == x- ]]; then
    case $xid[W] in
    (v)  AGE[1]=3;;
    (v*) AGE[1]=${xid[W]: 1};;
    (*)  print -u2 - "$0: Not implemented yet for W=$xid[w]."; return 1;;
    esac
  fi
  local -A solid=(p xsol s o$AGE[2]i$AGE[3])
  solid+=(Z $xid[Z] W $xid[W])
  solid+=(A $ida B $idb)

  local biarg= boarg= obin=
  case $prec in
  (a*) ;;
  (*)  obin=T biarg=-bi1$prec boarg=-bo1$prec;;
  esac
  local dasc=$dp
  if [[ -n $obin ]]; then
    local dasc=$dp.asc
    if [[ ! -e $dasc ]]; then
      gmt convert $biarg $dp > $dasc || return $?
    fi
  fi

  local xsdir=
  unparse_dir xsdir solid
  xsdir=$xsol/$xsdir
  ### solf kept ascii at the moment.
  local solf=$xsdir/agesol.dat
  local solp=$xsdir/params
  if [[ ! -e $solf ]]; then
    print -u2 - "$0: Create solution benchmark at $xsdir"
    local ageni=
    for t in . ./src/etc/misc
    do
      t=$t/ageni
      [[ -e $t ]] && ageni=$t && break
    done
    [[ -z $ageni ]] && print -u2 "$0: Not found ageni executable." && return 1
    mkdir -p $xsdir
    print - $ageni $AGE[1] $AGE[2] $AGE[3] $ma $mb $dasc > $solp
    $ageni $AGE[1] $AGE[2] $AGE[3] $ma $mb $dasc > $solf
  else
    :
    # print -u2 - "$0: Skip solution benchmark at $xsdir"
  fi
  local smpldir=
  unparse_dir smpldir solid p=xsmpl C=- H=$rh || return $?
  local ascx=$ascd/$smpldir
  mkdir -p $ascx

  local af=$ascx/a
  local gf=$ascx/g
  local ginvf=$ascx/ginv
  local Af=$ascx/A
  local df=$ascx/d
  local Df=$ascx/D
  local Zf=$ascx/Z

  local s1dargs=(-Fn $solf -N$dasc)
  ## ascii Knotfile
  update_if_new $verbose $force $df $dp -- cp $dp $Df
  update_if_new $verbose $force $Zf $zp -- cp $zp $Zf

  if update_if_new $verbose $force $af $solf $Df; then
    gmt sample1d -o1 $s1dargs | gmt math $boarg STDIN -Ca $rh MUL = $af
  fi
  if update_if_new $verbose $force $gf $solf $Df; then
    gmt sample1d -o2 $s1dargs $boarg > $gf
  fi
  if update_if_new $verbose $force $ginvf $gf; then
    gmt math $biarg $boarg $gf -C0 0 NAN INV = $ginvf
  fi
  if update_if_new $verbose $force $Af $ginvf; then
    gmt math $biarg $boarg $ginvf -C0 NEG = $Af
  fi
  if update_if_new $verbose $force $df $solf $Df; then
    gmt sample1d -o0 $s1dargs | gmt math $boarg STDIN -Ca $rh MUL = $df
  fi

  local dir=
  unparse_dir dir solid Z=- C=- H=$rh || return $?
  local asce=$ascd/$dir
  local adf=$asce/ad
  local gdf=$asce/gd
  local agf=$asce/ag
  mkdir -p $asce
  local dest= col= ctgt=
  boarg= biarg=
  [[ -n $obin ]] && boarg=-bo2${prec} biarg=-bi2${prec}
  for dest col ctgt in $adf 1,0 a   $gdf 2,0 0  $agf 1,2 1
  do
    if [[ ! -e $dest ]]; then
      sed -e '/2 *$/d' $solf | gmt math $boarg STDIN -o$col -C$ctgt $rh MUL = $dest
    fi
  done
  update_if_new $verbose $force -m $asce/aginv $agf -- $biarg $boarg $agf INV
  update_if_new $verbose $force -m $asce/aA    $agf -- $biarg $boarg $agf INV NEG
  update_if_new $verbose $force -m $asce/ginvd $gdf -- $biarg $boarg $gdf -C0 INV
  local Adf=$asce/Ad
  update_if_new $verbose $force -m $Adf        $gdf -- $biarg $boarg $gdf -C0 INV NEG
  local Azf=$asce/Az
  update_if_new $verbose $force -m $Azf        $Adf -- $biarg $boarg $Adf -C1 $rh SUB NEG

  # final
  [[ -n $dasc ]] && rm -f -- $dasc

  soldir=("${(@)smpldir}" "$dir")
  [[ $__sold == soldir ]] || set -A $__sold "${(@)soldir}"

  return 0
}

draw_all ()
{
  local reverset=T
  local psd=ps
  local texd=tex

  local Jdepth=10 Jage=15 Jdage=5
  local tmp=
  local dgrp=

  local chp=+
  local COLORS=() VCFGS=()
  local verbose=
  local ptop= ppfx= psfx=()
  local ascd=
  local k= v=
  local dry=
  local prec=f
  local LEGEND=()
  local err=0
  local ARGS=("$@")
  local draft=
  local mode=

  while [[ $# -gt 0 ]]
  do
    case $1 in
    (-V)  verbose=$1;;
    (-P*) if [[ x$1 == x-P ]];then
            v="$2="; shift
          else
            v="${1: 2}="
          fi
          k=${v%%=*}
          v=${${v#*=}: :-1}
          : ${(P)k::=$v}
          ;;
    (-C)  COLORS+=("$2"); shift;;
    (-C*) COLORS+=("${1: 2}");;
    (-v)  VCFGS+=("$2"); shift;;
    (-v*) VCFGS+=("${1: 2}");;
    (-L*) LEGEND+=("$1");;
    (+L*) ;;
    (-D)  dgrp=$2; shift;;
    (-D*) dgrp=${1: 2};;
    (+p)  ptop=$2; shift;;
    (+p*) ptop=${1: 2};;
    (-p)  ppfx=$2; shift;;
    (-p*) ppfx=${1: 2};;
    ([---+]s)  psfx+=("$1" "$2"); shift;;
    ([---+]s*) psfx+=("$1");;
    (-a)  ascd=$2; shift;;
    (-a*) ascd=${1: 2};;
    (-n)  dry=$1;;
    (--prec) prec=$2; shift;;
    (--prec=*) prec=${1#*=};;
    (--draft) draft=$1;;
    (--tex)   mode=tex;;
    (+*)  chp=${1: 1};;
    (-*) print -u2 "Unknown argument $1"; return 1;;
    (*)  break;;
    esac
    shift
  done

  parg=(--prec=${prec:-f})
  [[ $mode == tex ]] && VCFGS+=(+b//tex)

  local _xcfg=$1; shift || return $?
  local _comx=$1; shift || return $?
  local _unqx=$1; shift || return $?

  local draw=$1; shift || return $?
  local tset=$1; shift || return $?

  [[ $_xcfg != xcfg ]] && local -A xcfg=("${(@kvP)_xcfg}")
  [[ $_unqx != unqx ]] && local -A unqx=("${(@kvP)_unqx}")
  [[ $_comx != comx ]] && local -A comx=("${(@kvP)_comx}")

  local -A DPROPS=()
  DPROPS[exp/0]="$comx[0]"
  local dir= prop= DIR=() REFD=()
  local jd=1
  for dir in $@
  do
    DPROPS[exp/$jd]="$comx[$jd]"
    split_props $chp dir prop $dir
    DPROPS[exp/$jd/+]="$prop"
    dir=(${(s/:/)dir})
    DIR+=("$dir[1]")
    if [[ x${dir[1]} == x- ]] ;then
      REFD+=(-)
    else
      REFD+=("$dir[2]")
    fi
    let jd++
  done

  local dsub=()
  split_props -d = dgrp dsub "$dgrp"
  local pspath=()
  set_pspath pspath comx $dsub || return $?
  print -u2 - "$0: pspath = ${(@q-)pspath}"
  ppfx=$ppfx/${(j:/:)pspath}/

  local xv= yv= coor= xc= yc=

  local -A PEN
  local -a TSET
  local -a DSET
  get_time_range TSET $xcfg[1:tfin.base] "${(@s/,/)tset}" || return $?
  [[ -n $reverset ]] && TSET=("${(@On)TSET}")

  gen_pen_args "${chp}" PEN TSET DIR unqx $COLORS || return $?
  # diag -u2 PEN
  [[ -z $ptop ]] && ptop=.
  mkdir -p $ptop/$psd

  local copts=(-a $ascd -v VCFGS --prec=${prec:-f})
  local cdopts=(-D DPROPS -t TSET -P PEN $draft $dry)
  local cgopts=(-D DPROPS -t TSET -P PEN -x xcfg)
  local clopts=(-D DPROPS -t TSET)
  local cpopts=(+p $ptop/$psd -p $ppfx  "${(@)psfx}" -t TSET)
  local ccopts=()

  texd=$ptop/$texd
  [[ $mode == tex ]] && ccopts+=(--tex "$texd")

  # level optimization
  local levdir= LEVDIR=()
  local MSET=() mset=
  jd=1
  for dir in $DIR
  do
    mset="$xcfg[${jd}:+W]:$xcfg[${jd}:msmin]:$xcfg[${jd}:mbmin]:$xcfg[${jd}:hmin]"
    [[ -z ${(M)MSET:#$mset} ]] && MSET+=($mset)
    let jd++
  done
  [[ -z $LEVTRES ]] && local LEVTRES=2000
  js=1
  if [[ x${LEVTRES:--} != x- ]]; then
    for mset in $MSET
    do
      mset=("${(@s/:/)mset}")
      gen_benchmark_levels -b $LEVTRES -a $ascd $parg levdir $mset $LEVTRES
      LEVDIR+=("${levdir} +tres=$LEVTRES")
      DPROPS[lev/$js/sfx]=$LEVTRES
      DPROPS[lev/$js/refh]=$mset[4]
      let js++
    done
  fi
  # print -u2 - "LEVDIR: $LEVDIR"
  # print -u2 - "DPROPS: ${(kv)DPROPS[(I)lev/*]}"

  local -A coms=() unqs=()
  local count=0
  if [[ $dgrp == S ]]; then
    local sol=sol:SOLDIR
    local exp=exp:DIR
    local soldir= SOLDIR=()
    jd=1
    for dir in $DIR
    do
      for soldir in ${=xcfg[${jd}:soldir]}
      do
        [[ -n ${(M)SOLDIR:#$soldir} ]] || SOLDIR+=($soldir)
      done
      let jd++
    done

    check_xprops -s coms unqs "${(@)SOLDIR}"
    DPROPS[sol/0]="$coms[0]"
    js=1
    while [[ $js -le $#SOLDIR ]]
    do
      DPROPS[sol/$js]="$coms[$js]"
      let js++
    done
    gen_lparams $cgopts $sol $exp || return $?
    set_dset DSET DPROPS $sol $exp || return $?

    for xv yv coor in a    d    "- +l" \
                      a    z    "-" \
                      a    Z    "-" \
                      g    d    "- +L" \
                      g    z    "-" \
                      a    g    "- +l  :+L" \
                      a    ginv "-     :+L" \
                      ginv d    "- +L" \
                      ginv z    "- +L:+l" \
                      a    A    "- :+l :+L" \
                      A    d    "- +l +L" \
                      A    z    "- +L +L:+l" \
                      a    dadk "-"     \
                      dadk p    "- +L"
    do
      for coor in ${=coor}
      do
        coor=("${(@s/:/)coor}" - -)
        xc=$coor[1]; [[ x${xc:--} == x- ]] && xc=+c
        yc=$coor[2]; [[ x${yc:--} == x- ]] && yc=+c
        check_draw "${(@)ccopts}" count $chp $xv$xc $yv$yc ${draw} $cpopts -- $copts $cdopts -- "${(@)DSET}" || return $?
      done
    done
  ## coordinate plot
  elif [[ $dgrp == C ]]; then
    local sol=sol:SOLDIR
    local exp=exp:DIR
    local soldir= SOLDIR=()
    # local MSET=() mset=
    MSET=() mset=
    jd=1
    for dir in $DIR
    do
      mset="$xcfg[${jd}:+W]:$xcfg[${jd}:msmin]:$xcfg[${jd}:mbmin]:$xcfg[${jd}:hmin]"
      [[ -z ${(M)MSET:#$mset} ]] && MSET+=($mset)
      let jd++
    done
    local tres=
    # [[ -z $TRES ]] && local TRES=(5000 5000 10000 20000)
    [[ -z $TRES ]] && local TRES=(2000 2000 4000 10000)
    js=1
    if [[ x${TRES:--} != x- ]]; then
      TRES=(${=TRES})
      local bres=$TRES[1]; shift TRES
      for mset in $MSET
      do
        for tres in ${TRES}
        do
          gen_benchmark_levels -b $bres -a $ascd $parg soldir "${(@s/:/)mset}" $tres
          SOLDIR+=("${soldir} +tres=$tres")
          DPROPS[sol/$js/sfx]=$tres
          let js++
        done
      done
    fi
    check_xprops -s coms unqs "${(@)SOLDIR}"
    DPROPS[sol/0]="$coms[0]"
    js=1
    while [[ $js -le $#SOLDIR ]]
    do
      DPROPS[sol/$js]="$coms[$js]"
      # DPROPS[sol/$js/A]="Za:1:1000000:-Sx0.3c -Wthick,red"
      DPROPS[sol/$js/A]="Za:1:1000000:-Sx0.6c -Wthick,orange"
      let js++
    done

    gen_lparams $cgopts $sol $exp || return $?
    set_dset DSET DPROPS $sol $exp || return $?

    for xv yv coor in p    Z    "-" \
                      p    dZdp "- :+l" \
                      p.b  dp.b "- :+l" \
                      Z.b  dZ.b "- :+l"
    do
      for coor in ${=coor}
      do
        coor=("${(@s/:/)coor}" - -)
        xc=$coor[1]; [[ x${xc:--} == x- ]] && xc=+c
        yc=$coor[2]; [[ x${yc:--} == x- ]] && yc=+c
        check_draw "${(@)ccopts}" count $chp $xv$xc $yv$yc $draw $cpopts --  $copts $cdopts -- "${(@)DSET}" || return $?
      done
    done
  ## relative plot
  elif [[ $dgrp == R ]]; then
    local vt=
    local exp=
    local lev=lev:LEVDIR

    gen_lparams $cgopts exp:DIR:REFD $lev || return $?
    for xv yv vt coor in a    d    DR  "- +L" \
                         a    d    FR  "- +L" \
                         g    d    DR  "- +L" \
                         A    d    DR  "- +L" \
                         A    d    FR  "- +L" \
                         a    a    DR  "- +L" \
                         a    a    FR  "- +L" \
                         a    g    RD  "-     :+L" \
                         a    a    RD  "-     :+L" \
                         a    ginv RD  "-     :+L"
    do
      case $vt in
      (DR) xv=$xv+D yv=$yv+R exp=exp:DIR:REFD;;
      (FR) xv=$xv+F yv=$yv+R exp=exp:DIR:REFD;;
      (RD) xv=$xv+R yv=$yv+D exp=exp:REFD:DIR;;
      (DX) xv=$xv+D yv=$yv+R exp=exp:DIR;;
      (XD) xv=$xv+R yv=$yv+D exp=exp:DIR;;
      esac
      DSET=()
      set_dset DSET DPROPS $exp $lev || return $?
      for coor in ${=coor}
      do
        coor=("${(@s/:/)coor}" - -)
        xc=$coor[1]; [[ x${xc:--} == x- ]] && xc=+c
        yc=$coor[2]; [[ x${yc:--} == x- ]] && yc=+c
#         print -u2 - check_draw "${(@)ccopts}" count $chp $xv$xc $yv$yc $draw $cpopts --  $copts $cdopts -- "${(@)DSET}"
        check_draw "${(@)ccopts}" count $chp $xv$xc $yv$yc $draw $cpopts --  $copts $cdopts -- "${(@)DSET}" || return $?
      done
    done
  fi
  ## legend
  if [[ -n $LEGEND && $count -gt 0 ]]; then
    local texf=
    local leg=
    for leg in "${(@)LEGEND}"
    do
      set_psf psf leg -   +$chp $cpopts || return $?
      # print -u2 - draw_legend "$leg,$mode" -o $psf $clopts "${(@)DSET}"
      draw_legend "$leg,$mode" -o $psf $clopts "${(@)DSET}" || return $?
      if [[ $mode == tex ]]; then
        set_psf texf leg - +$chp "${(@)cpopts}" +p $texd
        gen_tex_psfragx $texf $psf:r.eps || return $?
      fi
    done
  fi
  return 0
}

# check_draw VAR-COUNT CHP XV YV [DRAW,...] [PS-OPTIONS....] -- [DRAW-OPTIONS..]
check_draw ()
{
  local texd=
  local cmd=draw
  while [[ $# -gt 0 ]]
  do
    case $1 in
    (--tex)  texd=$2; shift;;
    (--exec) cmd=$2; shift;;
    (*) break;;
    esac
    shift
  done
  # print -u2 - "$0: $@"
  local __count=$1; shift || return $?
  local chp=$1; shift || return $?
  local xorg=$1 yorg=$2; shift 2 || return $?
  local draw=$1; shift || return $?
  local ptop=
  local popts=()
  while [[ $# -gt 0 ]]
  do
    [[ x$1 == x-- ]] && shift && break
    popts+=("$1")
    shift
  done

  draw=("${(@j:,:)draw}")
  local psf=

  local dxv= Xarg= dxtag= didx=
  local dyv= Yarg= dytag= didy=

  split_props $chp dxv Xarg $xorg
  split_props $chp dyv Yarg $yorg
  local dxtag=$dxv:r dytag=$dyv:r
  gen_did $chp didx $dxtag $Xarg
  gen_did $chp didy $dytag $Yarg
  local err=0
  if [[ -n ${(M)draw:#all} ]]; then
    :
  else
    local did=($dxtag$dytag $dytag$dxtag $didx $didy)
    local i=
    for i in $draw
    do
      [[ -z ${(M)did:#$i} ]] && err=1 && break
    done
  fi
  if [[ $err -eq 0 ]]; then
    local xyv=()
    if [[ -n ${(M)draw:#$dxtag$dytag} ]]; then
      xyv=($xorg $yorg)
    else
      xyv=($yorg $xorg)
    fi
    set_psf psf $xyv +$chp "${(@)popts}"
  fi
  if [[ $err -eq 0 ]]; then
    local cmds=($cmd $xyv -o $psf +$chp "$@")
    "${(@)cmds}"; err=$?
    if [[ $err -ne 0 ]]; then
      print -u2 - "$0: ERROR ${(@q-)cmds}"
      return $err
    fi
    if [[ x${texd:--} != x- ]]; then
      local texf=
      set_psf texf $xyv +$chp "${(@)popts}" +p $texd
      gen_tex_psfragx $texf $psf:r.eps || return $?
    fi
    let ${__count}++
  fi  
  return 0
}

draw ()
{
  local dxv=$1 dyv=$2; shift 2 || return $?
  local msgh="${0} $dxv $dyv"

  local ascd= texd=
  local _pen= _tset= _dprops= _vcfgs=
  local chp=+
  local gmtX= gmtY= gmtO= gmtK= gmtB=()
  local psf=-
  local prec=f
  local draft= dry=
  local mode=
  while [[ $# -gt 0 ]]
  do
    case $1 in
    (-V)  verbose=$1;;
    (-n)  dry=$1;;
    (-o)  psf=$2; shift ;;
    (-o*) psf=${1: 2};;
    (-P)  _pen="$2"; shift;;
    (-P*) _pen="${1: 2}";;
    (-t)  _tset=$2; shift;;
    (-t*) _tset=${1: 2};;
    (-D)  _dprops=$2; shift;;
    (-D*) _dprops=${1: 2};;
    (-v)  _vcfgs=$2; shift;;
    (-v*) _vcfgs=${1: 2};;
    (-a)  ascd=$2; shift;;
    (-a*) ascd=${1: 2};;
    (--draft) draft=T;;
    (--prec) prec=$2; shift;;
    (--prec=*) prec=${1#*=};;
    # gmt
    (-O*) gmtO=$1;;
    (-K*) gmtK=$1;;
    (-X*) gmtX=$1;;
    (-Y*) gmtY=$1;;
    (-B*) gmtB+=($1);;
    (+*)  chp=${1: 1};;
    (--)  shift; break;;
    (-*)  print -u2 "$0: Invalid argument $1"; return 1;;
    (*)   break;;
    esac
    shift
  done

  if [[ -n $dry ]]; then
    [[ -z $gmtK ]] && ps_finalize $psf
    return 0
  fi

  : ${chp:=+}

  local DSET=("$@")
  [[ $_tset   != TSET   ]] && local TSET=("${(@P)_tset}")
  [[ $_vcfgs  != VCFGS  ]] && local VCFGS=("${(@P)_vcfgs}")
  [[ $_dprops != DPROPS ]] && local -A DPROPS=("${(@Pkv)_dprops}")
  [[ $_pen    != PEN    ]] && local -A PEN=() && [[ x${_pen:--} != x- ]] && PEN=("${(@Pkv)_pen}")

  local -A XPROP=() YPROP=()
  set_vprops "$chp" XPROP $dxv "${(@)VCFGS}" || return $?
  set_vprops "$chp" YPROP $dyv "${(@)VCFGS}" || return $?

  set_range_xy $prec $ascd DSET TSET XPROP YPROP || return $?

  set_range XPROP DSET 2 TSET $prec $ascd || return $?
  set_range YPROP DSET 3 TSET $prec $ascd || return $?

  # print -u2 - "FILTER:f:$dxv $XPROP[fl]:$XPROP[fu]  $XPROP[fn]"
  # print -u2 - "FILTER:u:$dxv $XPROP[ul]:$XPROP[uu]  $XPROP[un]"
  # print -u2 - "FILTER:f:$dyv $YPROP[fl]:$YPROP[fu]  $YPROP[fn]"
  # print -u2 - "FILTER:u:$dyv $YPROP[ul]:$YPROP[uu]  $YPROP[un]"

  local xu= yu=
  parse_unit xu XPROP || return $?
  parse_unit yu YPROP || return $?

  # symmetric log-plot
  [[ $XPROP[draw] == L ]] && gen_custom_x $XPROP[bc] $XPROP[rl] $XPROP[ru] $XPROP[L]
  [[ $YPROP[draw] == L ]] && gen_custom_x $YPROP[bc] $YPROP[rl] $YPROP[ru] $YPROP[L]

  ## generate figure
  local gmtBase=()
  if [[ -n $gmtO ]]; then
    [[ x${psf:--} != x- && ! -e $psf ]] && print -u2 - "$0: $psf not exists." && return 1
    gmtBase+=($gmtO $gmtX $gmtY)
  else
    [[ x${psf:--} != x- && -e $psf ]] && print -u2 - "$0: $psf removed." && rm -f -- $psf
    gmtBase+=(-P ${gmtX:--X3c} $gmtY)
  fi
  if [[ x${psf:--} == x- ]]; then
    exec 3>&1
  else
    mkdir -p $psf:h || return $?
    exec 3>>! $psf
  fi

  local bttl= 
  local bclr=white
  [[ -n $draft ]] && bclr=black
  gen_basemap_title bttl ${=DPROPS[exp/0]}

  local bsecret=+t"@:8:@;${bclr};$bttl@;;@::"
  [[ $HIDDEN == F ]] && bsecret=
  
  wgmt psbasemap $gmtBase -K \
      -JX$XPROP[jx]/$YPROP[jy] -R$XPROP[rl]/$XPROP[ru]/$YPROP[rl]/$YPROP[ru] \
      -Bx"$XPROP[bparam]" -By"$YPROP[bparam]" \
      -B${BWS:-WSne}"$bsecret" >&3 || return $?
  wpfx -u3 "$XPROP[btag]" "$XPROP[pfg]"
  wpfx -u3 "$YPROP[btag]" "$YPROP[pfg]"
  # wpfx -u3 "$bttl" "\texttt{$DPROPS[exp/0]}"

  [[ -n $XPROP[bc] ]] && rm -f -- $XPROP[bc]
  [[ -n $YPROP[bc] ]] && rm -f -- $YPROP[bc]

  local xf= yf= ti= jt= js= jd=
  local xopr= yopr=
  get_uconv xopr XPROP
  get_uconv yopr YPROP

  local oprxL=() opryL=()
  [[ $XPROP[draw] == L ]] && oprxL=("${(@s/:/)XPROP[L]}") && shift 5 oprxL
  [[ $YPROP[draw] == L ]] && opryL=("${(@s/:/)YPROP[L]}") && shift 5 opryL
  local tmpd=$(mktemp --dir)
  local xtmpf=$tmpd/xf
  local ytmpf=$tmpd/yf
  local tfile=$tmpd/tmp.dat
  local lfile=$tmpd/lines.dat sfile=$tmpd/symbols.dat

  local gopts=()
  local obin= bsarg= biarg= boarg= bxarg=
  case $prec in
  (a*) ;;
  (*)  bsarg=-bi2$prec biarg=-bi1$prec boarg=-bo2$prec bxarg=-bi2$prec;;
  esac
  local srcf= dk=
  local -A Pen
  local xdir=() ydir=()
  local mdiv= mmod= msed=
  local ocols=

  local margs=(-C1 DUP POP -C0 $xopr ${=oprxL} DUP POP -C1 $yopr ${=opryL} DUP POP)
  local dxv=$XPROP[var] dyv=$YPROP[var]
  local dxp=$XPROP[pfx] dyp=$YPROP[pfx]
  local fxv=$dxp$dxv  fyv=$dyp$dyv
  # print -u2 - "pfx: $fxv $fyv"

  for dk dir in "${(@)DSET}"
  do
    # print -u2 - "dset: $dk $dir"
    if [[ $dk == sol ]];then
      js=${dir%%:*} xdir=${dir#*:}
      xdir=${xdir%%$chp*}
      ocols=(0 1)
      srcf=$ascd/$xdir/${dxv}${dyv}
      [[ ! -e $srcf ]] && srcf=$ascd/$xdir/${dxv:r}${dyv:r}
      [[ ! -e $srcf ]] && srcf=$ascd/$xdir/${dxv:r}${dyv:r}_$DPROPS[$dk/$js/sfx]
      if [[ ! -e $srcf ]]; then
        ocols=(${(O)ocols})
        srcf=$ascd/$xdir/${dyv}${dxv}
        [[ ! -e $srcf ]] && srcf=$ascd/$xdir/${dyv:r}${dxv:r}
        [[ ! -e $srcf ]] && srcf=$ascd/$xdir/${dyv:r}${dxv:r}_$DPROPS[$dk/$js/sfx]
        [[ ! -e $srcf ]] && print -u2 "No solution file $srcf" && continue
      fi
      ocols=${(j:,:)ocols}
      extract_pen Pen DPROPS $dk/$js || return $?
      pen=$Pen[w],$Pen[c],$Pen[t]
      print -u2 - "$msgh ${dk}[$js] ${Pen[l]} $srcf ${pen:--} ${sym:--}"
      gmt convert $bsarg -o$ocols $srcf $boarg > $tfile
      gmt math $bxarg $boarg $tfile $margs = $lfile
      wgmt psxy -O -K -J -R -W$pen $bxarg $lfile >&3 || return $?
      sym=$Pen[s]
      if [[ -n $sym ]];then
        gopts=(-W0)
        [[ -n $Pen[c] ]] && gopts=(-W0,$Pen[c] -G$Pen[c])
        gmt select $bxarg $boarg -R $lfile |\
            wgmt psxy -O -K -J -R $gopts -S$sym $bxarg >&3 || return $?
      fi
      if [[ -n $Pen[A] ]]; then
        print -u2 - "Special[$dk/$js] $Pen[A]"
        local aspc=("${(@s/:/)Pen[A]}")
        local aspv=$aspc[1] aspi=$((${aspc[2]:-0} + 2))
        local asf=$srcf:h/$aspv
        local apen=(${=aspc[4]})
        [[ ! -e $asf ]] && asf=$srcf:h/${aspv}_$DPROPS[$dk/$js/sfx]
        [[ ! -e $asf ]] && print -u2 "No solution file $asf" && continue
        gmt convert -Af $bsarg $lfile $asf -o0,1,$aspi > $sfile
        local asel=
        for asel in ${(s:,:)aspc[3]}
        do
          gawk -v a=$asel '$3==a' $sfile
        done | wgmt psxy -O -K -J -R $apen >&3
      fi
    elif [[ $dk == lev ]];then
      js=${dir%%:*} xdir=${dir#*:}
      xdir=${xdir%%$chp*}
      srcf=$ascd/$xdir/Za_$DPROPS[$dk/$js/sfx]
      refh=$DPROPS[$dk/$js/refh]
      # print -u2 - "$dk $js $xdir ${dxv} ${dyv} $srcf"
      # print -u2 - "${(kv)Pen}"
      li=0
      local lev=
      for lev in ${=LEVMARK}
      do
        ymark=($(gmt convert $bsarg $srcf -o0,1 | gawk -v y=$lev '$2==y{print $1}'))
        ylev= yend=
        case $dyv in
        (d) ylev=$(gmt math -Q 1 $ymark SUB $refh MUL =) yend=$YPROP[ru];;
        (z) ylev=$(gmt math -Q   $ymark     $refh MUL =) yend=$YPROP[rl];;
        esac
        extract_pen Pen DPROPS $dk/$js || return $?
        print -u2 - "levmark: $lev $refh $ymark $ylev $Pen"
        pen=$Pen[w],$Pen[c],$Pen[t]
        # pen=thick,orange,dashed
        # if [[ -n $ylev ]]; then
        #   print -l "$XPROP[rl] $ylev" "$XPROP[ru] $ylev" |\
        #     wgmt psxy -O -K -J -R -W$pen >&3 || return $?
        # fi
        if [[ -n $ylev ]]; then
          print -l "$XPROP[rl] $ylev" "$XPROP[ru] $ylev" "$XPROP[ru] $yend" "$XPROP[rl] $yend" |\
            wgmt psxy -G$Pen[c] -L -O -K -J -R -W$pen >&3 || return $?
        fi
      done
    else
      dir=("${(s/:/)dir}")
      jd=$dir[1] xdir=$dir[2] ydir=$dir[3]
      [[ x$xdir == x- || x$ydir == x- ]] && continue
      jt=1
      for ti in $TSET
      do
        extract_pen Pen DPROPS $dk/$jd/$ti || return $?
        pen=$Pen[w],$Pen[c],$Pen[t]
        sym=$Pen[s]
        print -u2 - "$msgh ${dk}[$jd] $DPROPS[$dk/$jd] ${Pen[l]} ${xdir}:${ydir} ($ti) ${pen:--} ${sym:--}"

        xf=$ascd/$xdir/${fxv}_$ti
        [[ ! -e $xf ]] && xf=$ascd/$xdir/${fxv}
        [[ ! -e $xf ]] && xf=$ascd/$xdir:h/${fxv}
        [[ ! -e $xf ]] && xf=$ascd/$xdir:h/${fxv}.a
        yf=$ascd/$ydir/${fyv}_$ti
        [[ ! -e $yf ]] && yf=$ascd/$ydir/${fyv}
        [[ ! -e $yf ]] && yf=$ascd/$ydir:h/${fyv}
        [[ ! -e $yf ]] && yf=$ascd/$ydir:h/${fyv}.a
        check_file $xf || return $?
        check_file $yf || return $?
        gmt convert $biarg -Af $xf $yf $boarg > $tfile
        gmt math $bxarg $boarg $tfile $margs = $lfile
        wgmt psxy -O -K -J -R -W$pen $bxarg $lfile >&3 || return $?
        sym=$Pen[s]
        if [[ -n $sym ]];then
          gopts=(-W0)
          [[ -n $Pen[c] ]] && gopts=(-W0,$Pen[c] -G$Pen[c])
          if [[ x${Pen[m]:--} != x- ]]; then
            # print -u2 - "$0 sparse symbols $Pen[m]"
            if [[ $Pen[m] =~ , ]]; then
              msed=()
              for mmod in ${(s:,:)Pen[m]}
              do
                [[ -n $mmod ]] && msed+=(-e "$((mmod-1))p")
              done
              gmt convert $bxarg $lfile |\
                  sed -n $msed |\
                  gmt select $boarg -R
            else
              mmod=("${(@s/:/)Pen[m]}")
              mdiv=${mmod[1]:-16}
              [[ $mdiv -le 0 ]] && mdiv=1
              shift mmod
              : ${mmod:=0}
              gmt convert $bxarg $lfile   |\
                  gawk -v d=$mdiv -v r=$mmod '(NR-1)%d==r' |\
                  gmt select $boarg -R
            fi
          else
            gmt select $bxarg $boarg -R $lfile
          fi | wgmt psxy -N -O -K -J -R $gopts -S$sym $bxarg >&3 || return $?
        fi
        let jt++
      done
    fi
  done

  rm -rf -- $tmpd
  # final
  if [[ -z $gmtK ]]; then
    wgmt psxy -T -O -J -R >&3 || return $?
    exec 3>&-
    ps_finalize $psf || return $?
  else
    exec 3>&-
  fi
  return 0
}

draw_legend ()
{
  local psf=-
  local legend=
  local _tset= _dprops=
  while [[ $# -gt 0 ]]
  do
    case $1 in
    (-V)  verbose=$1;;
    (-L*) legend="${1: 2}";;
    (-o)  psf=$2; shift ;;
    (-o*) psf=${1: 2};;
    (-t)  _tset=$2; shift;;
    (-t*) _tset=${1: 2};;
    (-D)  _dprops=$2; shift;;
    (-D*) _dprops=${1: 2};;
    (-a)  ascd=$2; shift;;
    (-a*) ascd=${1: 2};;
    # gmt
    (-O*) gmtO=$1;;
    (-K*) gmtK=$1;;
    (-X*) gmtX=$1;;
    (-Y*) gmtY=$1;;
    (-B*) gmtB+=($1);;
    (--)  shift; break;;
    (+*)  chp=${1: 1};;
    (-*)  print -u2 "$0: Invalid argument $1"; return 1;;
    (*)   break;;
    esac
    shift
  done

  : ${chp:=+}
  [[ $_dprops == DPROPS ]] || local -A DPROPS=("${(@Pkv)_dprops}")
  [[ $_tset   == TSET   ]] || local TSET=("${(@P)_tset}")
  # diag -u2 DPROPS
  # diag -u2 TSET
  local nt=$#TSET
  # [[ x$TSET == x- ]] && nt=0

  local -A NK=()
  local dk= dir=
  local DSET_S=() DSET_X=()
  for dk dir in "$@"
  do
    # print -u2 - "$0: $dk $dir"
    dir=(${(s/:/)dir})
    [[ -n ${(M)dir:#-} ]] && continue
    NK[$dk]=$((${NK[$dk]:-0} + 1))
    if [[ $dk == sol ]];then
      DSET_S+=("$dk $dir[1]")
    else
      # DSET_X=("$dk" "$dir[1]" "${(@)DSET_X}")
      DSET_X+=("$dk $dir[1]")
    fi
  done
  local DSET=("${(@)DSET_S}" "${(@n)DSET_X}")
  # print -u2 - ${(kv)NK}
  local dyttl=1.5 dyitm=1.0
  local ry=0.0 nk= nx=
  for nk nx in ${(kv)NK}
  do
    [[ $nk == exp ]] && nx=$((nx * nt))
    ry=$((ry + ${nx-0}))
  done
  local -A lopts=()
  if [[ $#TSET   -gt 1 ]]; then
   lopts[title.exp]=T
   [[ $NK[sol] -gt 1 ]] && lopts[title.sol]=T
  fi

  # print -u2 "$0 $ry"
  [[ -n $lopts[title.sol] ]] && ry=$((ry + dyttl))
  [[ -n $lopts[title.exp] ]] && ry=$((ry + dyttl * $NK[exp] - dyitm))
  # print -u2 "$0 $ry ${(kv)lopts}"
  local dRy=0.5 dJy=0.7 fontl=14p fontx=17p
  local RN=$((0.0-$dRy)) RS=$((ry+$dRy))
  local RW=-2.5 RE=4.5 xl=(-2 0) xs=-1 xt=0.1
  # local xx=-1 xj=MC
  local xx=-2 xj=ML
  local Jx=5 Jy=$(( (RS-RN) * dJy ))
  # print -u2 - "JR: $Jx/-$Jy $RW/$RE/$RN/$RS"

  local gmtBase=()
  if [[ -n $gmtO ]]; then
    [[ x${psf:--} != x- && ! -e $psf ]] && print -u2 - "$0: $psf not exists." && return 1
    gmtBase+=($gmtO $gmtX $gmtY)
  else
    [[ x${psf:--} != x- && -e $psf ]] && print -u2 - "$0: $psf removed." && rm -f -- $psf
    gmtBase+=(-P ${gmtX--X3c} $gmtY)
  fi
  if [[ x${psf:--} == x- ]]; then
    exec 3>&1
  else
    mkdir -p $psf:h || return $?
    exec 3>>! $psf
  fi
  # -B+n+g240
  wgmt psbasemap $gmtBase -K \
      -JX$Jx/-$Jy -R$RW/$RE/$RN/$RS \
      -Ba0f0g0 -B+n >&3 || return $?

  local ly=0.0 md= jsd= jt=
  local -A Pen=()
  local pen= sym= ty= texp=
  local cpt=() jcpt=0
  local tmpd=$(mktemp --dir)
  local tmpl=$tmpd/lines.dat
  local tmps=$tmpd/symbols.dat
  local tmpt=$tmpd/text.dat

  local -A LEGFLG=()
  local lk lv
  for lv in ${(s:,:)legend}
  do
    split_props -d = lk lv $lv
    LEGFLG[$lk]=$lv
  done

  # diag -p "legend: " -u2 DPROPS
  local jsec=0 ptag=
  for dk in "${(@)DSET}"
  do
    dk=(${=dk})
    jsd=$dk[2] dk=$dk[1]
    if [[ $md != $dk ]]; then
      md=$dk
      [[ $dk == exp ]] && md="${md}/${jsd}"
      ## section
      if [[ -n $lopts[title.$dk] ]]; then
        [[ $ly -ne 0.0 ]] && ly=$((ly + $dyttl - $dyitm))
        extract_pen Pen DPROPS $md || return $?
        ty="${Pen[l]}"
        [[ -z $ty ]] && ty="${Pen[U]}"
        [[ -z $ty && $md == sol ]] && ty="Benchmarks"
        if [[ -n $ty ]]; then
          if [[ -n ${LEGFLG[tex]++} ]]; then
            ptag="SEC:$jsec"
            print "$xx $ly ${xj:-MC} ${fontx:-10p} $ptag" >>! $tmpt
            wpfx --pfx '#P ' $ptag "\\SREP{$DPROPS[$dk/0]}{$DPROPS[$dk/${jsd}]}{$ty}" Bl Bl >> $tmpt
          else
            print "$xx $ly ${xj:-MC} ${fontx:-10p} ${ty}" >>! $tmpt
          fi
        fi
        let jsec++
        ly=$((ly + $dyitm))
      fi
    fi
    if [[ ${md%%/*} == exp ]]; then
      if [[ -z $lopts[title.$dk] ]]; then
        extract_pen Pen DPROPS $dk/$jsd || return $?
        texp="${Pen[l]}"
        [[ -z $texp ]] && texp="${Pen[U]}"
      else
        texp=
      fi
      if [[ x$TSET == x- ]]; then
        gen_leg_item DPROPS $tmpl $tmps $tmpt $dk/$jsd $ly $xl $xs $xt
        ly=$((ly + $dyitm))
      else
        for jt in ${(on)TSET}
        do
          gen_leg_item DPROPS $tmpl $tmps $tmpt $dk/$jsd/$jt $ly $xl $xs $xt "$texp" 4 "kyr"
          ly=$((ly + $dyitm))
        done
      fi
    else
      if [[ -z $lopts[title.$dk] ]]; then
        extract_pen Pen DPROPS $dk || return $?
        texp="${Pen[l]}"
        [[ -z $texp ]] && texp="${Pen[U]}"
        [[ -z $texp ]] && texp="$DPROPS[$dk]"
        ## dirty hack
        # if [[ -z $texp ]]; then
        #   texp=$(echo "Benchmark $DPROPS[$dk/$jsd]" | sed -e 's:A1=\([0-9]*.*m\):m@-s@-=\1/yr:')
        # fi
      else
        texp=
      fi
      gen_leg_item DPROPS $tmpl $tmps $tmpt $dk/$jsd $ly $xl $xs $xt "$texp" -
      ly=$((ly + $dyitm))
    fi
  done
  # cat $tmpt >&2
  wgmt psxy   -J -R -O -K $tmpl >&3
  wgmt psxy   -J -R -O -K -N -Sc0.2c $tmps >&3
  wgmt pstext -J -R -O -K -N -F+j+f+a0 $tmpt >&3
  sed -n -e '/^#P */s///p' $tmpt >&3
  # sed -n -e '/^>/p' $tmpl >&2
  # final
  if [[ -z $gmtK ]]; then
    wgmt psxy -T -O -J -R >&3 || return $?
    exec 3>&-
    ps_finalize $psf || return $?
  else
    exec 3>&-
  fi
  print -u2 - $tmpd
  # rm -rf $tmpd
  return 0
}

# gen_leg_item DPROPS FILE-LINE FILE-SYMBOL FILE-TEXT KEY Y X0 X1 XS XT TPFX TCH TSFX
gen_leg_item ()
{
  local _dprops=$1; shift || return $?
  local lfile=$1 sfile=$2 tfile=$3; shift 3 || return $?
  local pkey=$1; shift || return $?
  local ly=$1; shift || return $?
  local xla=$1 xlb=$2 xs=$3 xt=$4; shift 4 || return $?
  local tpfx="$1" tch="$2" tsfx="$3"

  local -A Pen

  extract_pen Pen $_dprops $pkey || return $?
  local pen=$Pen[w],$Pen[c],$Pen[t]
  print - "> -W$pen" >>! $lfile
  print -l - "$xla $ly" "$xlb $ly" >> $lfile

  local sym=$Pen[s]
  if [[ -n $sym ]]; then
    print - "> -W0,$Pen[c] -G$Pen[c] -S$sym" >>! $sfile
    print - "$xs $ly"  >> $sfile
  fi

  if [[ x${tch:-:} == x: ]]; then
    tch=${Pen[l]}
  elif [[ x${tch} == x- ]]; then
    tch=
  else
    local tmp=("${(@s/,/)Pen[U]}")
    tch="${tmp[$tch]}"
  fi
  local ty=($tpfx)
  [[ x${tch:--} != x- ]] && ty+=($tch $tsfx)
  if [[ -n ${LEGFLG[tex]++} ]]; then
    local ptag="X:$pkey"
    print "$xt $ly ML $fontl $ptag" >>! $tfile
    wpfx --pfx '#P ' $ptag \
         "\\XREP{$tpfx}{$tch}{$tsfx}{$ty}" Bl Bl >> $tfile
  elif [[ -n ${LEGFLG[notime]++} ]]; then
    print "$xt $ly ML $fontl $tpfx" >>! $tfile
  else
    print "$xt $ly ML $fontl $ty" >>! $tfile
  fi
  return 0
}

gen_basemap_title ()
{
  # print -u2 - "$0 ${(q-)@}"
  local __v=$1; shift || return $?
  local xk= xv=
  local A=() B=() H=() Z=()
  local O=()
  for xv in "$@"
  do
    split_props -d = xk xv $xv
    [[ -z $xv ]] && continue
    case $xk in
    (A*) A+=($xv);;
    (B*) B+=($xv);;
    (H*) H+=($xv);;
    (Z*) Z+=($xv);;
    (*) O+=("$xk=$xv");;
    esac
  done
  local txt=()
  [[ -n $A ]] && txt+=("A=${(j;,;)A}")
  [[ -n $B ]] && txt+=("B=${(j;,;)B}")
  [[ -n $H ]] && txt+=("H=${(j;,;)H}")
  [[ -n $Z ]] && txt+=("Z=${(j;,;)Z}")
  txt+=($O)
  # : ${(P)__v::="@:6:@;white;$txt@;;@::"}
  : ${(P)__v::="$txt"}
  return 0
}
# gen_benchmark_levels [OPTIONS] SOLDIR XID LCFG MS MB REFH TRES
gen_benchmark_levels ()
{
  local ascd=
  local LEV= prec=f
  local bres=
  local k= v=
  while [[ $# -gt 0 ]]
  do
    case $1 in
    (-a) ascd=$2; shift;;
    (-b) bres=$2; shift;;
    (--prec) prec=$2; shift;;
    (--prec=*) prec=${1#*=};;
    (-P*) if [[ x$1 == x-P ]];then
            v="$2="; shift
          else
            v="${1: 2}="
          fi
          k=${v%%=*}
          v=${${v#*=}: :-1}
          : ${(P)k::=$v}
          ;;
    (*)  break;;
    esac
    shift
  done
  local __levd=$1; shift || return $?
  [[ $__levd == levd ]] || local -a levd=("${(@P)__levd}")
  local wt=$1 ma=$2 mb=$3 rh=$4; shift 4 || return $?
  local tres=$1

  local ida=$ma idb=$mb
  local u= t=
  for u in cm mm um
  do
    t=$(units -t -1 -- ${ma}m $u)
    [[ $t -eq $(printf '%.0f' $t) ]] && ida=${t}$u && break
  done
  if [[ $mb -ne 0 ]]; then
    local negm=$((-mb))
    for u in cm mm um
    do
      t=$(units -t -1 -- ${negm}m $u)
      [[ $t -eq $(printf '%.0f' $t) ]] && idb=${t}$u && break
    done
  fi

  local boarg= obin=
  case $prec in
  (a*) ;;
  (*)  obin=T boarg=-bo2$prec;;
  esac

  # levels optimization
  # LEV=PF/OUTER/INNER/MSTP/TTOL
  LEV=("${(s/:/)LEV}")
  : ${LEV[2]:=15}
  : ${LEV[3]:=12}
  : ${LEV[4]:=0}
  : ${LEV[5]:=1}
  if [[ x${LEV[1]:--} == x- ]]; then
    case $wt in
    (v)  LEV[1]=3;;
    (v*) LEV[1]=${wt: 1};;
    (*)  print -u2 - "$0: Not implemented yet for W=$wt."; return 1;;
    esac
  fi
  [[ -z $bres ]] && bres=$tres
  local -A levid=(p xsol s r${bres}o$LEV[2]i$LEV[3]m$LEV[4]e$LEV[5])
  levid+=(W $wt)
  levid+=(A $ida B $idb H $rh)
  unparse_dir levd levid || return $?
  local ascl=$ascd/$levd
  mkdir -p $ascl
  local levf=$ascl/levopt.dat
  if [[ ! -e $levf ]]; then
    print -u2 - "$0: Create level optimization benchmark at $levd"
    local levopt=
    for t in . ./src/etc/misc
    do
      t=$t/levopt
      [[ -e $t ]] && levopt=$t && break
    done
    [[ -z $levopt ]] && print -u2 "$0: Not found levopt executable." && return 1
    $levopt $LEV[1] $LEV[2] $LEV[3] $ma $mb $rh $bres $LEV[4] $LEV[5] >&2 > $levf
  fi

  local zdz=$ascl/ZdZ_$tres
  local za=$ascl/Za_$tres
  if [[ $bres == $tres ]]; then
    if update_if_new $verbose $force $zdz $levf; then
      gmt math $boarg -o1,2 0 $levf ADD -C2 0 MUL 1 COL DIFF ADD -C1 NEG 1 ADD = $zdz
    fi
    if update_if_new $verbose $force $za $levf; then
      gmt math $boarg -o1,4 0 $levf ADD -C1 NEG 1 ADD = $za
    fi
  else
    if update_if_new $verbose $force $zdz $levf; then
        gmt sample1d -o1 -I$tres -T4 $levf |\
            gmt math $boarg -N2/0 0 STDIN ADD -C1 0 MUL 0 COL DIFF ADD 0 AND -C0 NEG 1 ADD = $zdz
    fi
    if update_if_new $verbose $force $za $levf; then
        gmt sample1d -o1,4 -I$tres -T4 $levf |\
            gmt math $boarg 0 STDIN ADD -C0 NEG 1 ADD = $za
    fi
  fi

  # final
  [[ $__levd == levd ]] || : ${(P)__levd::=$levd}
  return 0
}

# check common/unique properties
#  check_xprops  [OPTIONS] COMX UNQX [DIR...]
check_xprops ()
{
  # print -u2 - "$0 ${(q-)@}"
  local pargs=()
  [[ $1 == -s ]] && pargs+=($1) && shift
  local __comx=$1; shift || return $?
  local __unqx=$1; shift || return $?
  [[ $__comx != comx ]] && local -A comx=()
  [[ $__unqx != unqx ]] && local -A unqx=()
  # print -u2 -l "${(@q-)args}"
  local sep='='
  local dir=
  local -A dprops=()
  local cfgd=$(mktemp --dir)
  local cfgf= CFGF=()
  local k= v= j=1
  for dir in "$@"
  do
    dir=($=dir)
    parse_dir $pargs -u dprops $dir
    cfgf=$cfgd/$j.cfg
    for k in ${(ok)dprops}
    do
      print - "${k}${sep}$dprops[$k]"
    done > $cfgf
    # print -u2 - "## $j $cfgf"
    # cat $cfgf >&2
    CFGF+=($cfgf)
    let j++
  done
  local commf=$cfgd/common tmpf=$cfgd/utmp
  if [[ $#CFGF -ge 1 ]]; then
    j=1
    cp $CFGF[$j] $commf || return $?
    for j in $CFGF[2,-1]
    do
      comm -12 $commf $j > $tmpf
      mv $tmpf $commf
    done
  fi
  local xcfg=()
  [[ -e $commf ]] && xcfg=($(cat $commf))
  comx[0]="${xcfg}"
  for v in $xcfg
  do
    k=${v%%=*}
    v=${v#*=}
    unqx[$k]=":${v}:"
  done
  # print -u2 - "Common: $comx"
  if [[ $#CFGF -ge 1 ]]; then
    for j in {1..$#CFGF}
    do
      xcfg=($(comm -13 $commf $CFGF[$j]))
      # print -u2 - "$j: $xcfg"
      for v in $xcfg
      do
        k=${v%%=*}
        v=":${v#*=}:"
        [[ ${unqx[$k]} =~ $v ]] || unqx[$k]="${unqx[$k]}${v}"
      done
      comx[$j]="${xcfg}"
    done
  fi
  for k v in "${(@kv)unqx}"
  do
    v=(${=v//:/ })
    unqx[$k]="$v"
  done
  [[ $__comx != comx ]] && set -A $__comx "${(@kv)comx}"
  [[ $__unqx != unqx ]] && set -A $__unqx "${(@kv)unqx}"
  # diag -u2 unqx
  rm -rf -- $cfgd
  return 0
}

# get_refid CHP REFID COMX [PROPS...]
get_refid ()
{
  # print -u2 - "$0: ${(q-)@}"
  local chp="$1"; shift || return $?
  local __refid=$1; shift || return $?
  local comx="$1"; shift || return $?

  [[ $__refid != refid ]] && local refid=()
  local -A dpr=()
  parse_dir -u dpr "$@"
  local cx=
  for cx in "${=comx}"
  do
    cx=${cx%%=*}
    unset "dpr[$cx]"
  done
  local k= v=
  refid=()
  for k v in "${(@kv)dpr}"
  do
    refid+=($k=$v)
  done
  [[ $__refid != refid ]] && set -A ${__refid} "${(@)refid}"
}

gen_xdir ()
{
  local __dir=$1; shift || return $?
  local __prop=$1; shift || return $?
  local __xid=$1; shift || return $?
  local chp="$1"; shift || return $?
  local dirx="$1"; shift || return $?
  local bset=$1; shift || return $?
  local DIR=("$@")

  [[ $__dir  == dir  ]] || local dir=
  [[ $__prop == prop ]] || local prop=
  [[ $__xid  == xid  ]] || local -A xid=

  [[ $#DIR == 0 ]] && basexi=1  ## non local

  local rdir=
  split_props $chp rdir prop $dirx
  local -A dprops=()
  if [[ x$bset[1] == x+ ]];then
    local di=${bset: 1}
    [[ $di -gt $#DIR ]] && print -u2 "Not enough directory ($bset > $#DIR)." && return 1
    parse_dir dprops ${=DIR[$di]} || return $?
    bset=$dprops[b]
  else
    [[ x${bset:--} != x- ]] && bset=(${bset/,/_})
  fi

  local dirh=
  if [[ -d $rdir ]];then
    parse_dir dprops $rdir || return $?
    dir=$rdir:t dirh=$rdir:h
    [[ x${bset:--} != x- ]] && dir=$dir/b$bset
  elif [[ $rdir =~ '=' ]];then
    rdir=${rdir#=}
    local xi=${rdir%%[^0-9]*}; : ${xi:=$basexi}
    rdir=${rdir#[0-9]*}
    [[ ${xi} -gt $#DIR ]] && print -u2 "Too large index $xi ($#DIR)." && return 1
    dir=(${=DIR[$xi]})
    dirh=$dir[1]; shift dir
    if parse_dir dprops $dirh $dir; then
      :
    else
      parse_dir dprops $dir || return $?
    fi
    unparse_dir dir dprops b=${bset:--} "${(@s:,:)rdir}" || return $?
  elif [[ $rdir = smpl ]]; then
    # print -u2 - "Extract smpl $jd."
    # print -u2 - "${(kv)xcfg}"
    # print -u2 - "${xcfg[${jd}:smpldir]}"
    dir=${xcfg[${jd}:smpldir]}
  else
    print -u2 - "Invalid experiment $rdir." && return 1
  fi
  : ${dirh:=.}
  if [[ $rdir != smpl ]]; then
    parse_dir xid $dirh $dir || return $?
  fi
  dir=("${dirh}" "$dir")
  [[ $__dir  == dir  ]] || set -A $__dir "${(@)dir}"
  [[ $__prop == prop ]] || : ${(P)__prop::=$prop}
  [[ $__xid  == xid  ]] || set -A $__xid "${(@kv)xid}"
  return 0
}

# pfx.PROPS.sfx[/bset]
# parse_dir [-s][-u] [PATH..] DIR [+K=V...]
parse_dir ()
{
  local ungrp= skipchk= chp=+
  while [[ $# -gt 0 ]]
  do
    case $1 in
    (-u) ungrp=T;;
    (-s) skipchk=T;;
    (+*) chp=${1: 1};;
    (*)  break;;
    esac
    shift
  done

  local __dprops=$1; shift || return $?
  [[ $__dprops == dprops ]] || local -A dprops=()
  local DIR=() aprop=() dir=
  for dir in "$@"
  do
    if [[ $dir[1] == $chp ]]; then
      aprop+=(${dir#$chp})
    else
      DIR+=($dir)
    fi
  done
  local dir=${(j:/:)DIR}
  bflg=
  if [[ -z $skipchk ]]; then
    while [[ x${dir:-.} != x. ]]
    do
      [[ -e $dir/sysin ]] && break
      bflg=$dir:t dir=$dir:h
    done
    [[ x$dir == x. ]] && print -u2 "$0: Cannot parse directory $*." && return 1
  fi
  [[ -n $bflg ]] && dprops[b]="${bflg#b}"
  dprops[h]=$dir:h
  dir=$dir:t
  dprops[s]=$dir:e  dir=$dir:r
  dprops[p]=$dir:r  dir=$dir:e
  local k= v=
  for k in ${(s:_:)dir}
  do
    v=${k: 1}
    k=${k[1]}
    case $k in
    (W) dprops[$k]=$v;;
    (H) dprops[$k]=$v;;
    (A) dprops[$k]=$v;;
    (B) dprops[$k]=$v;;
    (Z) dprops[$k]=$v;;
    (C) dprops[$k]=$v;;
    esac
  done
  if [[ -n $ungrp ]]; then
    local bcp= j=
    for k in A B H
    do
      v=$dprops[$k]
      [[ -z $v ]] && continue
      bcp=()
      if [[ $v == 0 ]] ;then
        bcp[1]=$v
      elif units -t -1 -- $v m > /dev/null; then
        bcp[1]=$v
      elif units -t -1 -- $v 1 > /dev/null; then
        bcp[1]=$v
      else
        bcp[5]=$v[-1] v=${v: 0:-1}
        bcp[4]=${v##*[0-9]};          v=${v%$bcp[4]}
        bcp[1]=${v%%[^0-9]*};         v=${v#$bcp[1]}
        bcp[4]=${v##*[^0-9]}$bcp[4];  v=${v%%[0-9]*}
        bcp[3]=$v[-1]; v=${v%$bcp[3]}
        bcp[2]=$v[-1]; v=${v%$bcp[2]}
        bcp[1]=$bcp[1]$v
      fi
      for j in {1..$#bcp}
      do
        dprops[${k}$j]="$bcp[$j]"
      done
      unset "dprops[${k}]"
    done

    k=Z
    v=$dprops[$k]
    local nz=${v%%[^0-9]*}
    if [[ -n $nz ]]; then
      dprops[${k}1]="$nz"
      dprops[${k}2]="${v#$nz}"
    else
      dprops[${k}1]=
      dprops[${k}2]="$v"
    fi
    unset "dprops[${k}]"
  fi
  for v in "${(@)aprop}"
  do
    # print -u2 - "$v"
    k=${v%%=*}
    v=${v#*=}
    dprops[$k]=$v
  done

  [[ $__dprops == dprops ]] || set -A $__dprops "${(@kv)dprops}"
  # diag -u2 dprops
  return 0
}

#  unparse_dir    DIR DPROPS K=V K=V ...
#  unparse_dir -a DIR DPROPS K V K V ...
unparse_dir ()
{
  local atype=
  [[ x$1 == -a ]] && atype=$1 && shift
  local __dir=$1; shift || return $?
  local __dprops=$1; shift || return $?

  [[ $__dir == dir ]] || local dir=
  if [[ x$__dprops == x- ]]; then
    local -A dprops=()
  else
    [[ $__dprops == dprops ]] || local -A dprops=("${(@Pkv)__dprops}")
  fi
  local k= v=
  if [[ x$atype == x-a ]]; then
    for k v in "$@"
    do
      dprops[$k]="$v"
    done
  else
   for k in "$@"
   do
     v=${k#*=}
     k=${k%%=*}
     dprops[$k]="$v"
   done
  fi
  j= s=
  for k in A B H
  do
    v=(${(s/:/)dprops[$k]})
    for j in {1..5}
    do
      [[ -n $dprops[$k$j] ]] && v[$j]=$dprops[$k$j]
    done
    for s j in u 1 l 2 p 3 d 4 f 5
    do
      [[ -n $dprops[$k$s] ]] && v[$j]=$dprops[$k$s]
    done
    dprops[$k]=${(j/:/)v}
  done
  for k in Z
  do
    v=(${(s/:/)dprops[$k]})
    for j in {1..2}
    do
      [[ -n $dprops[$k$j] ]] && v[$j]=$dprops[$k$j]
    done
    dprops[$k]=${(j/:/)v}
  done
  dir=()
  if [[ -n $dprops[smpl] ]]; then
    dir=($dprops[smpl])
  else
    for k in W H A B Z C
    do
      v=(${(s/:/)dprops[$k]}); v=${(j::)v}
      [[ x${dprops[$k]:--} == x- ]] || dir=(${dir} $k$v)
    done
  fi
  dir=${(j:_:)dir}
  [[ x${dprops[p]:--} == x- ]] || dir=$dprops[p].$dir
  [[ x${dprops[s]:--} == x- ]] || dir=$dir.$dprops[s]
  [[ x${dprops[b]:--} == x- ]] || dir=$dir/b$dprops[b]

  [[ $__dir == dir ]] || : ${(P)__dir::=$dir}
  return 0
}

# update_if_new [OPTIONS] DEST-FILE [SRCS...] -- COMMANDS
#     -m        gmt math COMMANDS = DEST-FILE
#     -s        COMMANDS > DEST-FILE
#     -bBPARAM  COMMANDS | gmt convert -bBPARAM > DEST-FILE
update_if_new ()
{
  local force=0 verbose= chkonly= boarg=
  local otype=
  while [[ $# -gt 0 ]]
  do
    case $1 in
    (-V) verbose=-V;;
    (-m) otype=m;;
    (-s) otype=-;;
    (-f) let force++;;
    (-b*) boarg=$1 otype=-;;
    (*)  break;;
    esac
    shift
  done
  local dest=$1; shift || return $?
  local src=() cmd=()
  while [[ $# -gt 0 ]]
  do
    [[ x$1 == x-- ]] && shift && break
    src+=("$1")
    shift
  done
  while [[ $# -gt 0 ]]
  do
    cmd+=("$1")
    shift
  done

  local upd=
  [[ ! -e $dest ]] && upd=T
  [[ $force -gt 1 ]] && upd=T
  if [[ -z $upd ]]; then
    local s=
    for s in $src
    do
      [[ $dest -ot $s ]] && upd=T && break
    done
  fi

  if [[ -n $upd ]]; then
    [[ -n $verbose ]] && print -u2 - "Create $dest ${(@)cmd}"
    [[ -z $cmd ]] && return 0
    if [[ -z $otype ]]; then
      "${(@)cmd}"; return $?
    elif [[ $otype == m ]]; then
      gmt math "${(@)cmd}" = $dest; return $?
    elif [[ -n $boarg ]]; then
      "${(@)cmd}" | gmt convert $boarg > $dest; return $?
    else
      "${(@)cmd}" > $dest; return $?
    fi
  else
    [[ -n $verbose ]] && print -u2 - "Skip $dest"
    return 0
  fi
}

get_time_range ()
{
  local __tset=$1; shift || return $?
  local tfin=$1; shift || return $?

  [[ $__tset == TSET ]] || local TSET=
  local ts= ti=
  TSET=()
  for ts in "$@"
  do
    ts=("${(@s/:/)ts}")
    if [[ x$ts == x- ]];then
      TSET+=(-)
    elif [[ $#ts -eq 1 ]];then
      if [[ $ts -lt 0 ]]; then
        ti=$(($tfin + $ts + 1))
      else
        ti=$ts
      fi
      TSET+=($ti)
    else
      if  [[ $#ts -eq 2 ]];then
         [[ $ts[1] -gt $ts[2] ]] && ts=(0 "${(@)ts}")
      else
        [[ ${ts[1]:-0} -lt 0 ]] && ts[1]=$(($tfin + $ts[1] + 1))
        [[ ${ts[2]:-0} -lt 0 ]] && ts[2]=$(($tfin + $ts[2] + 1))
      fi
      ts=($(enum -- ${ts[1]:-0} ${ts[3]:-1} ${ts[2]:-$tfin}))
      TSET+=($ts)
    fi
  done
  # diag -u2 TSET
  [[ $__tset == TSET ]] || set -A $__tset "${(@)TSET}"
  return 0
}

gen_lparams ()
{
  local chp= __pen= __tset= __dprops= _xcfg=
  while [[ $# -gt 0 ]]
  do
    case $1 in
    (-V)  verbose=$1;;
    (-D)  __dprops=$2; shift;;
    (-D*) __dprops=${1: 2};;
    (-P)  __pen="$2"; shift;;
    (-P*) __pen="${1: 2}";;
    (-t)  __tset=$2; shift;;
    (-t*) __tset=${1: 2};;
    (-x)  _xcfg=$2; shift;;
    (-x*) _xcfg=${1: 2};;
    (--)  shift; break;;
    (+*)  chp=${1: 1};;
    (-*)  print -u2 "$0: Invalid argument $1"; return 1;;
    (*)   break;;
    esac
    shift
  done
  : ${chp:=+}
  [[ -z $__dprops ]] && print -u2 - "DPROPS not set" && return 1
  [[ $__dprops == DPROPS ]] || local -A DPROPS=("${(@Pkv)__dprops}")
  [[ $__tset  == TSET  ]] || local TSET=("${(@P)__tset}")
  [[ $__pen != PEN ]] && local -A PEN=() && [[ x${__pen:--} != x- ]] && PEN=("${(@Pkv)__pen}")
  [[ $_xcfg != xcfg ]] && local -A xcfg=("${(@Pkv)_xcfg}")
  # diag -p "$0: " -u2 DPROPS

  local js=0 jd=0 jl=0
  local di= dir= xdir= sol= ti= jt= lev=

  local tyf= ttl=
  for dir in "$@"
  do
    dk=${dir%%:*}
    dir=${dir#*:}
    if [[ $dk == sol ]]; then
      for sol in "${(@P)dir}"
      do
        let js++
        add_pen_props $chp DPROPS $dk/$js PEN 0=1 S=$js $DPROPS[$dk/$js] 9=1 || return $?
      done
    elif [[ $dk == lev ]]; then
      for lev in "${(@P)dir}"
      do
        let jl++
        add_pen_props $chp DPROPS $dk/$jl PEN 0=1 L=$jl $DPROPS[$dk/$jl] 9=1 || return $?
      done
    elif [[ $dk == exp ]]; then
      dir=("${(@s/:/)dir}")
      xdir=("${(@P)dir[1]}")
      while [[ $#xdir -gt 0 ]]
      do
        let jd++
        # print -u2 -l ${=xcfg[$jd:+]}
        add_pen_props $chp DPROPS $dk/$jd PEN 0=1 X=$jd ${=DPROPS[$dk/$jd]} $DPROPS[$dk/${jd}/+] 9=1 || return $?
        jt=0
        tyf=$xcfg[${jd}:tyf.base]
        for ti in $TSET
        do
          let jt++
          ttl=($(sed -n -e "/^$ti /p" $tyf))
          add_pen_props $chp DPROPS $dk/$jd/$ti PEN 0=1 X=$jd ${=DPROPS[$dk/$jd]} T=$jt $DPROPS[$dk/${jd}/+] 9=1 +U"${(j:,:)ttl}" || return $?
        done
        shift xdir
      done
    else
      print -u2 - "$0: Not implemented ($dir)."
      return 1
    fi
  done

  [[ $__dprops != DPROPS ]] && set -A $__dprops "${(@Pkv)DPROPS}"
  # diag -u2 DPROPS
  return 0
}

# set ps output filename
#    set_pspath VAR-PSPATH VAR-COMX [DSUB...]
set_pspath ()
{
  local __pspath=$1; shift || return $?
  local _comx="$1"; shift || return $?
  [[ $_comx == comx ]] || local -A comx=("${(@Pkv)_comx}")

  local pb= pg= pr=
  unparse_dir pb - "${=comx[0]}" || return $?
  local jd=1
  local xid=()
  local k= v=
  while [[ -n ${comx[$jd]++} ]]
  do
    for k in "${=comx[$jd]}"
    do
      xid+=(${k%%=*})
    done
    let jd++
  done
  for k in p W H A B Z C s b
  do
    [[ -n ${(M)xid:#$k*} ]] && pg=${pg}$k && xid=(${xid##$k*})
  done
  [[ -n $xid ]] && xid=(${(uo)xid}) && pg=${pg}_${(j::)xid}
  [[ -n $pg ]] && pg=cmp$pg
  [[ $# -gt 0 ]] && unparse_dir pr - "$@"
  [[ -n $pr ]] && pr=ref$pr
  set -A $__pspath "$pg" "$pr" "$pb"
  # diag -u2 $__pspath
  return 0
}

# set ps output filename
# set_psf NAME DRAW_XV DRAW_YV [OPTIONS]
set_psf ()
{
  # set -x
  local __psf=$1; shift || return $?
  local dxv=$1 dyv=$2; shift 2 || return $?
  [[ $__psf != psf ]] && local psf=

  local chp= ptop= ppfx= psfx= asfx=()
  local _tset=
  while [[ $# -gt 0 ]]
  do
    case $1 in
    (-V)  verbose=$1;;
    (+p)  ptop=$2; shift ;;
    (+p*) ptop=${1: 2};;
    (-p)  ppfx=$2; shift ;;
    (-p*) ppfx=${1: 2};;
    (-s)  psfx=$2; shift ;;
    (-s*) psfx=${1: 2};;
    (+s)  asfx+=("$2"); shift ;;
    (+s*) asfx+=("${1: 2}");;
    (-t)  _tset=$2; shift;;
    (-t*) _tset=${1: 2};;
    (+*)  chp=${1: 1};;
    (--)  shift; break;;
    (-*)  print -u2 "$0: Invalid argument $1"; return 1;;
    (*)   break;;
    esac
    shift
  done
  : ${chp:=+}

  local fxv=() Xarg= vk=
  local -A XPROP=()
  local vco=()
  for vk in "$dxv" "$dyv"
  do
    # print -u2 - "vk: $vk"
    if [[ x${vk:--} != x- ]]; then
      split_props $chp vk Xarg $vk
      parse_props $chp XPROP $Xarg
      set_vid_ps +fxv $vk:r "${(@kv)XPROP}"
      vco+=("${${vk:e}:-a}")
    fi
  done
  # print -u2 - "$fxv"
  local csfx=
  [[ -n ${vco:#a} ]] && csfx=.${(j::)vco}
  if [[ x${psfx:--} == x- ]];then
    psfx=
    if [[ x$_tset == x- ]]; then
      :
    else
      [[ $_tset  == TSET  ]] || local TSET=("${(@P)_tset}")
      if [[ x${TSET:--} == x- ]]; then
        :
      elif [[ $#TSET -eq 1 ]]; then
        psfx=${psfx}.t${TSET}
      elif [[ $#TSET -gt 1 ]]; then
        psfx=${psfx}.seq
      fi
    fi
    [[ -n $psfx && $psfx[1] != . ]] && psfx=.$psfx
  fi
  [[ -n $asfx ]] && psfx="$psfx.${(j:_:)asfx}"

  psf=$ptop/$ppfx
  [[ $psf[-1] != / ]] && psf=$psf.
  psf=$psf${(j:.:)fxv}$csfx$psfx.ps
  # print -u2 - "$0: $psf"
  [[ $__psf != psf ]] && : ${(P)__psf::=$psf}
  return 0
}

set_dset ()
{
  local __dset=$1; shift || return $?
  local _dprops=$1; shift || return $?

  [[ $__dset != DSET ]] && local DSET=
  [[ $_dprops == DPROPS ]] || local -A DPROPS=("${(@Pkv)_dprops}")

  local DSET_S=() DSET_X=() DSET_L=() DSET_O=()
  local jd=0 js=0 jl=0 dk= dir=
  local xdir=() ydir=()
  local sol= exp= lev=
  local xodr=
  for dir in "$@"
  do
    # print -u2 - "$0 $dir"
    dk=${dir%%:*}
    dir=${dir#*:}
    if [[ $dk == sol ]]; then
      for sol in "${(@P)dir}"
      do
        let js++
        DSET_S+=($dk "$js:${sol%% *}")
      done
    elif [[ $dk == lev ]]; then
      for lev in "${(@P)dir}"
      do
        let jl++
        DSET_L+=($dk "$jl:${lev%% *}")
      done
    elif [[ $dk == exp ]]; then
      dir=("${(@s/:/)dir}")
      [[ -z $dir[2] ]] && dir[2]=$dir[1]
      xdir=("${(@P)dir[1]}")
      ydir=("${(@P)dir[2]}")
      while [[ $#xdir -gt 0 ]]
      do
        let jd++
        xodr=${(v)DPROPS[(I)exp/$jd/o]:-$jd}
        DSET_X+=("$xodr/$jd:$xdir[1]:$ydir[1]")
        shift xdir
        [[ $#ydir -gt 0 ]] && shift ydir
      done
    else
      let jd++
      DSET_O+=(exp "${jd}:${dir}:${dir}")
    fi
  done
  DSET=("${(@)DSET_L}" "${(@)DSET_S}")
  for dk in "${(@n)DSET_X}"
  do
    DSET+=(exp "${dk#*/}")
  done
  DSET+=("${(@)DSET_O}")
  [[ $__dset != DSET ]] && set -A $__dset "${(@)DSET}"
  return 0
}

gen_did ()
{
  local chp=$1; shift
  local __v=$1; shift
  [[ $__v == tag ]] || local tag=
  tag=$1
  local args=$2
  while [[ $args[1] == + ]]
  do
    args=${args: 1}
    case $args[1] in
    ([clLR]) tag=$tag$args[1];;
    esac
    args=${(M)args%%+*}
  done
  [[ $__v != tag ]] && : ${(P)__v::=$tag}
  return 0
}

check_file ()
{
  [[ ! -e $1 ]] && print -u2 - "Cannot found $1" && return 1
  return 0
}

set_vid_ps ()
{
  local __v=$1; shift || return $?
  local var=$1; shift || return $?
  ## hard-coded
  case $var in
  (A) var=AA;;
  (Z) var=ZZ;;
  (D) var=DD;;
  esac

  local -A props=("$@")
  # print -u2 - "${(kv)props}"
  [[ -n ${props[D]++} ]] && var=D$var
  [[ -n ${props[F]++} ]] && var=F$var
  [[ -n ${props[R]++} ]] && var=R$var
  if [[ -n ${props[l]++} ]]; then
    var=l$var
  elif [[ -n ${props[L]++} ]]; then
    var=L$var
  fi
  if [[ $__v[1] == + ]];then
    __v=${__v: 1}
    set -A $__v "${(@P)__v}" "$var"
  else
    : ${(P)__v::=$var}
  fi
  return 0
}

# set_vprops CHP VAR_PROP VAR [CONFIG...]
set_vprops ()
{
  local chp=$1; shift || return $?
  local __vprop=$1; shift || return $?
  local vnm=$1; shift || return $?

  [[ $__vprop != vprop ]] && local -A vprop=()
  local k= v= vv=
  local xarg= dxv=
  split_props $chp dxv xarg $vnm
  local vtag=$dxv:r
  vprop+=(tag $vtag  var $dxv)

  [[ $xarg[1] != $chp ]] && print -u2 "Invalid property $__prop $chp $xarg." && return 1
  xarg=${xarg#$chp}
  local dtype= otype= flgs= fpfx=
  while [[ -n $xarg ]]
  do
    split_props -d $chp k xarg $xarg
    case $k in
    ([clL]*) dtype="$dtype$k";;
    ([RD]*) otype="$otype$k";;
    ([F]*)  otype="$otype$k" fpfx=dr.;;
    (*)      flgs="$flgs$k";;
    esac
  done
  vprop+=(draw "$dtype"   ref "$otype"  pfx "$fpfx"  flag "$flgs")

  # default
  vprop+=(jx - jy -)
  vprop+=(rl - ru -)
  vprop+=(Frl - Fru -)
  vprop+=(Drl - Dru -)
  vprop+=(i  :)
  vprop+=(b  afg    bl  afg)
  vprop+=(u  :    u0  -)
  vprop+=(Fu '%'  Fu0 -)
  vprop+=(bt gmt)
  local namep="@%11%Z@-k@-@%%"
  # local namep="Z@-k@-"
  case $vtag in
  (a)     vprop+=(          bl af3g     u kyr    u0 yr      l "Age"             lt '$\Age$');;
  (g)     vprop+=(          bl af3g     u kyr/m  u0 yr/m    l "Age derivative"  lt '$\pd{\Age}{z}$');;
  (dadk)  vprop+=(                      u kyr    u0 yr      l "@~D@~Age/layer");;
  (ginv)  vprop+=(                      u mm/yr  u0 m/yr    l "dz/dAge"         lt '$\pd{\Age}{z}^{-1}$');;
  # (A)     vprop+=(rl 0      bl af3g     u mm     u0 m       l "Annual layer thickness");;
  # (A)     vprop+=(rl 0      bl af3g     u mm     u0 m       l "@~l@~"           lt '$\lambda$');;
  (A)     vprop+=(          bl af3g     u mm     u0 m       l "@~l@~"           lt '$\lambda$');;
  (d)     vprop+=(i - jy -- bl a2f3g2            u0 m       l "Depth");;
  (z)     vprop+=(i -       bl a2f3g2            u0 m       l "Elevation");;
  (Z)     vprop+=(rl 0 ru 1                                 l "@~z@~"           lt '$\zeta$');;
  (p)     vprop+=(rl 0 ru 1                                 l "$namep"          lt '$\ZZ$');;
  (dZdp)  vprop+=(                                          l "d@~z@~/d$namep"  lt '$\pd{\zeta}{\ZZ}$');;
  (dp)    vprop+=(          bl a1pf3g2                      l "@~D@~$namep"     lt '$\Delta\ZZ$');;
  (dZ)    vprop+=(i :       bl a1pf3g2                      l "@~Dz@~"          lt '$\Delta\zeta$');;
  (*)     vprop+=(                                          l "$vtag");;
  esac

  local cfg=()
  for v in '' $vtag
  do
    parse_vcfg "$chp" cfg "$v" "$@"
    for k v in "${(@)cfg}"
    do
      vprop[$k]="$v"
    done
  done

  # adjustment
  for k in jx jy
  do
    case $vprop[$k] in
    (-)  vprop[$k]=10;;
    (--) vprop[$k]=-10;;
    esac
  done
  local rpfx= u=
  if [[ x$vprop[u0] != x- ]]; then
    for rpfx in '' D F
    do
      u=$vprop[${rpfx}u]
      [[ x$u == x: ]] && u=$vprop[${rpfx}u0]
      for k in rl ru
      do
        v=$vprop[$rpfx$k]
        [[ x${v:--} == x- ]] && continue
        if units -t -1 -- $v 1 > /dev/null; then
          :
        else
          vprop[$rpfx$k]=$(units -t -1 -- $v $u) || return $?
        fi
        # print -u2 - $k $v $vprop[$k]
      done
      vprop[${rpfx}r]="$vprop[${rpfx}rl]/$vprop[${rpfx}ru]"
    done
  fi
  # [[ -n "$ux" ]] && ux=" ($ux)"
  local bx=
  case ${vprop[draw]} in
  (l*) bx=$vprop[bl];;
  (L*) local bc=$(mktemp)
       vprop[bc]="$bc"
       bx=c$bc
       ;;
  (*)  bx=$vprop[b];;
  esac

  local xu=
  parse_unit xu vprop || return $?
  xp=${vprop[ref]}
  local ttl=()
  [[ $xp == R ]] && ttl=('Ref. ' $ttl)
  [[ $xp == D ]] && ttl=('@~D@~' $ttl)
  [[ $xp == F ]] && ttl=('Rel.@~D@~' $ttl)
  ttl+=("$vprop[l]")
  [[ -n $xu ]] && ttl+=(" ($xu)")
  ttl=${(j::)ttl}

  local tex="$vprop[lt]"
  [[ -z $tex ]] && tex="$vprop[l]"
  local ref=
  if [[ $xp == D ]]; then
    if [[ $tex[1] == '$' ]]; then
      tex="${tex: :1}\\Delta ${tex: 1}"
      # print -u2 - "${tex}"
    fi
  elif [[ $xp == F ]]; then
    tex="Rel. diff. $tex"
    ref=$xp
  fi

  local utex=$vprop[${ref}u]
  [[ x${utex:-:} == x: ]] && utex=$vprop[${ref}u0]
  case $vprop[bt] in
  (t*) # tex
  vprop[btag]="C:${xp}$vtag"
  vprop[bparam]="${bx}+l${vprop[btag]}"
  # \CREP{PFX}{TAG}{UNIT}{TITLE}{ORIG-TITLE}
  vprop[pfg]="\\CREP{$xp}{$vtag}{${utex//\%/\%}}{$tex}{${ttl//\%/}}"
  # vprop[pfg]="$tex"
  # print -u2 -- "$ttl // ${ttl//\%/}"
  ;;
  (*)  # gmt
  vprop[bparam]="${bx}+l$ttl"
  ;;
  esac

  set -A $__vprop "${(@kv)vprop}"
  # diag -u2 $__vprop
  return 0
}

parse_vcfg ()
{
  local chp=$1; shift || return $?
  local __cfg=$1; shift || return $?
  local vkey=$1; shift || return $?
  [[ $__cfg != cfg ]] && local cfg=()
  [[ -z $chp ]] && chp=+
  local pk= pp= pf= po= rpfx=
  for pk in "$@"
  do
    if split_props -d = pk pp $pk; then
      :
    else
      split_props ${chp} pk pp $pk
    fi
    split_props -d : rpfx pk $pk
    # print -u2 - "$0 $vkey ($rpfx) $pk"
    if [[ x$vkey == x$pk ]]; then
      pp=${pp#$chp}
      while [[ -n $pp ]]
      do
        [[ $pp[1] == l ]] && cfg+=(l "${pp: 1}") && break
        split_props -d $chp po pp $pp
        pf=$po[1]; po=${po: 1}
        case $pf in
        (j) po=("${(@s:/:)po}")
            [[ x${po[1]:-:} != x: ]] && cfg+=(jx "$po[1]")
            [[ x${po[2]:-:} != x: ]] && cfg+=(jy "$po[2]")
            ;;
        (r) cfg+=("${rpfx}$pf" "$po")
            po=("${(@s:/:)po}")
            [[ x${po[1]:-:} != x: ]] && cfg+=(${rpfx}rl "$po[1]")
            [[ x${po[2]:-:} != x: ]] && cfg+=(${rpfx}ru "$po[2]")
            ;;
        (b) po=("${(@s:/:)po}")
            [[ x${po[1]:-:} != x: ]] && cfg+=(b  "$po[1]")
            [[ x${po[2]:-:} != x: ]] && cfg+=(bl "$po[2]")
            [[ x${po[3]:-:} != x: ]] && cfg+=(bt "$po[3]")
            ;;
        (*) cfg+=("$pf" "$po");;
        esac
      done
    fi
  done
  # diag -u2 cfg
  [[ $__cfg != cfg ]] && set -A ${__cfg} "${(@)cfg}"
  return 0
}

#   set_range_xy PREC ASCD VAR_DSET VAR_TSET VAR_XPROP VAR_YPROP || return $?
set_range_xy ()
{
  local prec=$1;    shift || return $?
  local ascd=$1;    shift || return $?
  local __dset=$1;  shift || return $?
  local __tset=$1;  shift || return $?
  local __xprop=$1;  shift || return $?
  local __yprop=$1;  shift || return $?

  [[ $__tset == TSET ]] || local -a TSET=("${(@P)__tset}")
  [[ $__dset == DSET ]] || local -a DSET=("${(@P)__dset}")

  [[ $__xprop == XPROP ]] || local -A XPROP=("${(@Pkv)__xprop}")
  [[ $__yprop == YPROP ]] || local -A YPROP=("${(@Pkv)__yprop}")

  local dxv=$XPROP[var] dxtag=$XPROP[tag] dxref=$XPROP[ref] dxp=$XPROP[pfx]
  local dyv=$YPROP[var] dytag=$YPROP[tag] dyref=$YPROP[ref] dyp=$YPROP[pfx]

  [[ $dxref == R ]] && dxref=
  [[ $dyref == R ]] && dyref=
  # print -u2 - "DXV: $dxv $dxtag $dxref"
  # print -u2 - "DYV: $dyv $dytag $dyref"

  local rxl=$XPROP[${dxref}rl]; [[ x$rxl == x- ]] && rxl=
  local rxu=$XPROP[${dxref}ru]; [[ x$rxu == x- ]] && rxu=
  local ryl=$YPROP[${dyref}rl]; [[ x$ryl == x- ]] && ryl=
  local ryu=$YPROP[${dyref}ru]; [[ x$ryu == x- ]] && ryu=

  # print -u2 - limits:$dxv $rxl:$rxu
  # print -u2 - limits:$dyv $ryl:$ryu

  ## range  x=L:U  y=+:+   filter none
  ##        x=L:U  y=+:-          upper
  ##        x=L:U  y=-:+          lower
  ##        x=L:U  y=-:-          both
  ##        x=L:U  y=L:+          none
  ##        x=L:U  y=L:-          upper

  ##        x=+:+  y=+:+          none
  ##        x=-:-  y=-:-          none

  ## range   null     pass filter
  ##         +        extend file min/max

  # if [[ ${rxl:++}${rxu:++}${ryl:++}${ryu:++} == ++++ ]];then
  #   print -u2 "$0: Skip filtering"
  #   return 0
  # fi

  local XDIR=() YDIR=()
  local kd= d=
  for kd d in "${(@)DSET}"
  do
    if [[ $kd == exp ]]; then
      d=("${(s/:/)d}")
      XDIR+=($d[2])
      YDIR+=(${d[3]:-$d[2]})
    fi
  done

  local xallf=() yallf=()
  query_all_file xallf XDIR TSET $ascd $dxv $dxp || return $?
  query_all_file yallf YDIR TSET $ascd $dyv $dyp || return $?

  local xopr=() yopr=()
  get_uconv xopr XPROP || return $?
  get_uconv yopr YPROP || return $?
  # print -u2 - "xopr $xopr"
  # print -u2 - "yopr $yopr"

  local mm= mz=()
  local maxn= minp=

  [[ -z $xallf ]] && print -u2 "No x-files ($dxv)." && return 1
  [[ -z $yallf ]] && print -u2 "No y-files ($dyv)." && return 1

  local obin= biarg=
  case $prec in
  (a*) ;;
  (*)  obin=T biarg=-bi1$prec;;
  esac

  local tmpd=$(mktemp --dir)
  local tmpx=$tmpd/xall
  local tmpy=$tmpd/yall
  local tmpz=$tmpd/xy
  cat $xallf | gmt math $biarg -bo1$prec -Ca STDIN $xopr = $tmpx || return $?
  cat $yallf | gmt math $biarg -bo1$prec -Ca STDIN $yopr = $tmpy || return $?
  # ls -l $tmpx $tmpy >&2

  gmt convert -bi1$prec -bo2$prec -Af $tmpx $tmpy > $tmpz

  mm=($(gmt info -bi2$prec -C $tmpz))
  XPROP+=(ul $mm[1]  uu $mm[2])
  YPROP+=(ul $mm[3]  uu $mm[4])
  # print -u2 - "$mm"

  # get minimum positive and maximum negative
  minp=($(gmt math -Ca -bi2$prec $tmpz DUP 0 GT 0 NAN OR LOWER = -Sf))
  maxn=($(gmt math -Ca -bi2$prec $tmpz DUP 0 LT 0 NAN OR UPPER = -Sf))
  XPROP+=(un "$minp[1] $maxn[1]")
  YPROP+=(un "$minp[2] $maxn[2]")

  if [[ $#xallf -ne $#yallf ]]; then
    print -u2 - "$0: PANIC. Different file numbers $#xallf $#yallf."
  elif [[ ${rxl:-+}${rxu:-+}${ryl:-+}${ryu:-+} == ++++ ]]; then
    :
    # print -u2 - "$0: No filter"
  else
    # print -u2 - "$rxl/$rxu/$ryl/$ryu"
    local fxopr=() fyopr=()
    [[ ${rxl:-+} != + ]] && fxopr=("${(@)fxopr}" DUP $rxl LT 1 NAN OR)
    [[ ${rxu:-+} != + ]] && fxopr=("${(@)fxopr}" DUP $rxu GT 1 NAN OR)
    [[ ${ryl:-+} != + ]] && fyopr=("${(@)fyopr}" DUP $ryl LT 1 NAN OR)
    [[ ${ryu:-+} != + ]] && fyopr=("${(@)fyopr}" DUP $ryu GT 1 NAN OR)

    local tmpf=$(mktemp)
    gmt convert -bi1$prec -bo2$prec -sa -Af \
        <(gmt math -Ca -bo1$prec -bi1$prec $tmpx $fxopr =) \
        <(gmt math -Ca -bo1$prec -bi1$prec $tmpy $fyopr =) > $tmpf || return $?
    mm=($(gmt info -bi2$prec -C $tmpf))
    XPROP+=(fl $mm[1] fu $mm[2])
    YPROP+=(fl $mm[3] fu $mm[4])
    # print -u2 - "$0: $mm"

    mm=($(gmt math -bi2$prec $tmpf -Ca DUP 0 GT 0 NAN OR LOWER = | gmt info -C))
    mz=($mm[1] $mm[3])
    mm=($(gmt math -bi2$prec $tmpf -Ca DUP 0 LT 0 NAN OR UPPER = | gmt info -C))
    mz=($mz $mm[2] $mm[4])

    XPROP+=(fn "$mz[1] $mz[3]")
    YPROP+=(fn "$mz[2] $mz[4]")

    rm -f -- $tmpf
    # print -u2 "FILTER: $mm"
    print -u2 - "FN: $XPROP[fn] $YPROP[fn]"
  fi

  # return
  [[ $__xprop == XPROP ]] || set -A $__xprop "${(@Pkv)XPROP}"
  [[ $__yprop == YPROP ]] || set -A $__yprop "${(@Pkv)YPROP}"

  rm -rf -- $tmpd
  return 0
}

#  set_range PROP DSET INDEX TSET PREC ASCD
set_range ()
{
  # set -x
  local __v=$1; shift || return $?
  local __dset=$1; shift || return $?
  local dj=$1; shift || return $?
  local __tset=$1; shift || return $?
  local prec=$1; shift || return $?
  local ascd=$1; shift || return $?

  [[ $__tset == TSET ]] || local -a TSET=("${(@P)__tset}")
  [[ $__dset == DSET ]] || local -a DSET=("${(@P)__dset}")
  [[ $__v    == prop ]] || local -A prop=("${(@Pkv)__v}")

  local var=$prop[var]

  local kd= dir=
  local DIR=()
  for kd dir in "${(@)DSET}"
  do
    if [[ $kd == exp ]]; then
      dir=("${(s/:/)dir}")
      dir=$dir[$dj]
      [[ x${dir:--} != x- ]] && DIR+=($dir)
    fi
  done

  # diag -u2 -A prop
  # diag -u2 -a TSET
  # local allf=()
  # query_all_file allf DIR TSET $ascd $var || return $?

  local rpfx=$prop[ref]
  [[ $rpfx == R ]] && rpfx=
  local opr= iopts= imod=
  get_uconv opr prop
  if [[ $prop[i] == - ]]; then
    :
  elif [[ $prop[i] == : ]];then
    if [[ $prop[ref] == F ]]; then
      :
    else
      iopts=(-I0.2)
      imod=0.2
    fi
  else
    imod=$prop[i]
  fi
  # print -u2 - "$0 $opr $iopts $imod"

  local uu=$prop[uu] ul=$prop[ul]
  local fu=$prop[fu] fl=$prop[fl]
  local upl=(${=prop[un]})
  local unu=$upl[2]; upl=$upl[1]
  local fpl=(${=prop[fn]})
  local fnu=$fpl[2]; fpl=$fpl[1]

  # print -u2 - "Range/$var: $mm ($prop[u])"
  local argr="${prop[${rpfx}r]:--/-}"
  argr=("${(@s:/:)argr}")

  [[ ${argr[1]:-+} == + ]] || ul=${fl:-$ul}
  [[ ${argr[2]:-+} == + ]] || uu=${fu:-$uu} upl=${fpl:-$upl}

  local mm=()
  case ${prop[draw]} in
  (l*)
    # print -u2 - "adjust $__v for log-plot"
    prop[jx]=$prop[jx]l
    prop[jy]=$prop[jy]l
    mm=($(print -l $upl $uu | gmt info -C $iopts))
    [[ $mm[1] -eq 0 ]] && mm[1]=$upl
    ;;
  (L*)
    local mp= mn=
    local iopr=()
    [[ -n $imod ]] && iopr=($imod DIV CEIL $imod MUL)
    # AND   B   if A == NaN, else A
    # OR    NaN if B == NaN, else A
    mm=($(print - "$ul $uu" | gmt math 10 STDIN -C0 NEG -Ca  DUP 0 GT 0 NAN OR LOG10 $iopr POW 0 AND -C0 NEG =))
    # mp=$(gmt math -Q "$uu"     DUP 0 GT 0 NAN OR LOG10 $iopr 10 EXCH POW     0 AND =)
    # mn=$(gmt math -Q "$ul" NEG DUP 0 GT 0 NAN OR LOG10 $iopr 10 EXCH POW NEG 0 AND =)
    # mm=($mn $mp)
    # print -u2 - "adjusted: $mm ($ul $uu)"
    ;;
  (*)
    mm=($(print -l $ul $uu | gmt info -C $iopts))
    ;;
  esac
  [[ x${argr[1]} == x- || x${argr[1]} == x+ ]] && argr[1]=$mm[1]
  [[ x${argr[2]} == x- || x${argr[2]} == x+ ]] && argr[2]=$mm[2]
  [[ ${prop[draw]} == l && $argr[1] -eq 0 ]] && argr[1]=$mm[1]

  [[ -n $argr[1] ]] && prop[rl]=$argr[1]
  [[ -n $argr[2] ]] && prop[ru]=$argr[2]

  if [[ ${prop[draw]} == L ]]; then
    # print -u2 - "$prop[rl]/$prop[ru] $fl/$fu $fpl/$fnu"
    local opr=() rlx=
    local logm=("${(@s/:/)prop[L]}")
    local lsp=${logm[3]:-1}
    local linm=${logm[2]:-1}
    logm=${logm[1]:-3}
    local lflg=
    if [[ $fu -lt 0 || $fl -gt 0 ]]; then
      # set_symlog opr $prop[rl] $prop[ru] - 0 || return $?
      logm=- linm=0
      set_symlog opr $fl $fu $logm $linm || return $?
      if [[ $fu -lt 0 ]]; then
        lflg=-
      else
        lflg=+
      fi
    else
      set_symlog opr $prop[rl] $prop[ru] $logm $linm || return $?
    fi
    rlx=$opr[1] logm=$opr[2]; shift 2 opr
    local rr=($(print -l "$prop[rl]" "$prop[ru]" | gmt math STDIN "${(@)opr}" =))
    # print -u2 - "adjust $__v for symmetry log-plot (${logm}+${linm} E$rlx) -- $rr"

    prop[L]=${logm}:${linm}:${rlx}:${lflg}:${lsp}:"$opr"
    prop[rl]=$rr[1]
    prop[ru]=$rr[2]
  fi
  if [[ $prop[rl] -eq $prop[ru] ]]; then
    local trl= tru=
    if [[ $prop[rl] -eq 0 ]]; then
      trl=0 tru=1
    else
      ## bc does not handle 1e5 notation
      trl=$(gmt math -Q $prop[rl] DUP 0.99 MUL EXCH 1.01 MUL MIN =)
      tru=$(gmt math -Q $prop[rl] DUP 0.99 MUL EXCH 1.01 MUL MAX =)
    fi
    print -u2 - "$0: range modified [${prop[rl]}:${prop[ru]}] to [${trl}:{$tru}]"
    prop[rl]=$trl
    prop[ru]=$tru
  fi
  # print -u2 - "$prop[rl] $prop[ru]"

  [[ $__v == prop ]] || set -A $__v "${(@kv)prop}"
  return 0
}

# query_all_file VAR-OUT  VAR-DIR VAR-TSET  ASCD DRAW-VAR [VAR-PFX]
query_all_file ()
{
  local __v=$1; shift || return $?
  local __dir=$1 __tset=$2; shift 2 || return $?
  local ascd=$1 var=$2; shift 2 || return $?
  local vpfx=$1

  [[ $__tset == TSET ]] || local -a TSET=("${(@P)__tset}")
  [[ $__dir  == DIR  ]] || local -a DIR=("${(@P)__dir}")

  [[ $__v == allf ]] || local -a allf=()

  local __DIR=()
  local d=
  for d in "${(@)DIR}"
  do
    [[ x$d != x- ]] && __DIR+=($d)
  done
  d=${__DIR[1]}
  [[ -z $d ]] && print -u2 "Panic. $DIR" && return 1
  local t=$TSET[1]
  if    [[ -e $ascd/$d/${vpfx}${var}_$t ]]; then
    allf=($ascd/${^__DIR}/${vpfx}${var}_${^TSET})
  else
    local dummy=("${(@)TSET/*/}")
    if  [[ -e $ascd/$d/${vpfx}${var} ]]; then
      allf=($ascd/${^__DIR}/${vpfx}${var}${^dummy})
    elif [[ -e $ascd/$d:h/${vpfx}${var} ]]; then
      allf=($ascd/${^__DIR:h}/${vpfx}$var${^dummy})
    elif [[ -e $ascd/$d:h/${vpfx}${var}.a ]]; then
      allf=($ascd/${^__DIR:h}/${vpfx}$var.a${^dummy})
    fi
  fi
  # print -u2 -l - $allf
  [[ $__v == allf ]] || set -A $__v "${(@)allf}"
  return 0
}

# set __opr as (rlx OPR)
set_symlog ()
{
  # set -x
  local __opr=$1; shift || return $?
  local lv=$1 uv=$2; shift 2 || return $?
  local logm=$1 linm=$2
  [[ -z $logm || -z $linm ]] && print -u2 "$0: insufficent arguments" && return 1
  local rlx=
  if [[ x$logm == x- ]];then
    rlx=$(gmt math -Q $lv ABS $uv ABS MIN LOG10 FLOOR =)
    logm=$(gmt math -Q $lv ABS LOG10 $uv ABS LOG10 SUB ABS CEIL =)
  else
    rlx=$(gmt math -Q $lv ABS $uv ABS MAX LOG10 $logm SUB CEIL =)
  fi
  set -A $__opr $rlx $logm \
      DUP SIGN EXCH ABS DUP 10 $rlx POW DIV DUP 1 LE 0 NAN EXCH $linm MUL EXCH OR \
        EXCH LOG10 $rlx 1 ADD SUB $linm 1 ADD ADD AND MUL
  return 0
}

gen_custom_x ()
{
  local cxf=$1; shift || return $?
  local rl=$1 ru=$2; shift 2
  local propL=$1
  [[ -z $propL ]] && return 0
  propL=("${(@s/:/)propL}")
  local logm=$propL[1] linm=$propL[2] rlx=$propL[3] lflg=$propL[4] lsp=$propL[5]
  shift 5 propL
  local opr=(${=propL})
  local vx=
  local linf=2 ## div 10
  [[ x$logm == x- ]] && logm=0
  # print -u2 - "$logm/$linm/$rlx $rl/$ru"
  # print -u2 - "$logm/$linm/$rlx ${(q)opr}"
  # negative log
  {
    vx=$((logm+rlx)) bx= ax=
    ## TAB used in sed script
    if [[ x$lflg != x+ ]]; then
      gmt math -T0/$((logm*10+10))/1 -I \
        'T' 1 ADD DUP 10 MOD EXCH 10 DIV FLOOR $rlx ADD 10 EXCH POW NEG MUL \
        $opr 0 NAN -C0 DUP 10 MOD 0 EQ 0 NAN EXCH 10 DIV FLOOR $rlx ADD EXCH OR -o1,0 = | \
        sed -e '/^NaN/d' -e 's/NaN/f/' \
            -e '/	0$/s//	ag -1Q/' \
            -e '/	1$/s//	ag -10Q/' \
            -e '/[^fQ]$/s/\([^	]*\)$/ag -10@+\1@+/' \
            -e 's/Q$//'
    fi
    if [[ $linm -gt 0 ]]; then
      vx=$((10-$linf))
      gmt math -T-$vx/$vx/$linf 'T' 10 DIV $linm MUL -o1 = |\
          sed -e 's/$/ f/' -e '/^0 /s/f/ag @:23:0@::/'
    fi
    vx=$rlx
    if [[ x$lflg != x- ]]; then
      gmt math -T0/$((logm*10+10))/1 \
        'T' 1 ADD DUP 10 MOD EXCH 10 DIV FLOOR $rlx ADD 10 EXCH POW MUL \
        $opr 0 NAN -C0 DUP 10 MOD 0 EQ 0 NAN EXCH 10 DIV FLOOR $rlx ADD EXCH OR -o1,0 = | \
        sed -e '/^NaN/d' -e 's/NaN/f/' \
            -e '/	0$/s//	ag +1Q/' \
            -e '/	1$/s//	ag +10Q/' \
            -e '/[^fQ]$/s/\([^	]*\)$/ag +10@+\1@+/' \
            -e 's/Q$//'
    fi
  } | gawk -v l=$rl -v u=$ru -v s=$lsp '{a=$1}$1<0{a=-$1} /ag/&&(a>1)&&(a-1)%s!=0{$2="g"} $1>=l && $1<=u' > $cxf
  # cat $cxf >&2
  return 0
}

get_uconv ()
{
  local __v=$1; shift || return $?
  local _prop=$1; shift || return $?
  [[ $_prop != PROP ]] && local -A PROP=("${(@Pkv)_prop}")
  local ref=$PROP[ref]
  [[ $ref != F ]] && ref=

  local us="${PROP[${ref}u0]}" ud="${PROP[${ref}u]}"

  [[ x${ud:-:} == x: ]] && set -A $__v && return 0
  [[ x${us:--} == x- ]] && us=1
  set -A $__v $(units -t -1 -- $ud $us) DIV
  return 0
}

parse_unit ()
{
  local __ux=$1; shift || return $?
  local _prop=$1; shift || return $?
  [[ $__ux != ux ]] && local ux=
  [[ $_prop != PROP ]] && local -A PROP=("${(@Pkv)_prop}")
  local ref=$PROP[ref]
  [[ $ref == F ]] || ref=

  ux="${PROP[${ref}u]}"
  [[ x$ux == x: ]] && ux="${PROP[${ref}u0]}"
  if [[ x${ux:--} == x- ]]; then
    ux=
  else
    ux=$(echo "$ux" | sed -e 's!/\([a-zA-Z]*\)! \1@+-1@+!g')
  fi
  : ${(P)__ux::=$ux}
  return 0
}

###_ pen (and other properties) manager
###_. pen configuration parser
#   gen_pen_arg CHP PEN-VAR TSET DIR UNQS [PROPERTIES]
# c color
# b black
# g gray
# d dim
# t texture
#  key T for time index
#      S for solution
#      X for experiment
#      0 for default
#      9 for final
#      WHABZCpbs  experiment properties
gen_pen_args ()
{
  # print -u2 - "$0 ${(q-)@}"
  local chp=$1; shift || return $?
  local __pen=$1; shift || return $?
  local _tset=$1 _dir=$2; shift 2 || return $?
  local _unqs=$1; shift || return $?

  [[ $__pen != PEN ]] && local -A PEN=()
  PEN=()
  [[ $_tset != TSET ]] && local TSET=()    && [[ x${_tset:--} != x- ]] && TSET=("${(@P)_tset}")
  [[ $_dir  != DIR  ]] && local DIR=()     && [[ x${_dir:--}  != x- ]] && DIR=("${(@P)_dir}")
  [[ $_unqs != unqs ]] && local -A unqs=() && [[ x${_unqs:--} != x- ]] && unqs=("${(@Pkv)_unqs}")


  # print -u2 - "$0 TSET=$#TSET DIR=$#DIR $@"
  local def=(0=+wthicker,+a0.3c, X=+s S=+g L=+c128/0/128,+tdotted,+w1p,)
  if [[ $#TSET -le 1 ]];then
    if [[ $#DIR -le 1 ]]; then   # T == 1, X == 1
      def+=(T=: X=+cblack,)
    else                         # T == 1, X > 1
      def+=(T=: X=+c )
    fi
  elif [[ $#DIR -le 1 ]]; then   # T > 1, X == 1
    # def+=(T=+c X=:)
    def+=(T=+d X=:)
  else                           # T > 1, X > 1
    # def+=(T=+c X=+d)
    def+=(T=+d X=+c)
  fi
  local pk= pp= pf= po= pv=
  for pk in "${(@)def}" "$@"
  do
    # print -u2 -n "## $pk"
    if split_props -d = pk pp $pk; then
      :
    else
      split_props $chp pk pp $pk
    fi
    : ${pk:=0}
    # print -u2 - " >> $pk $pp"
    pp=${pp#$chp}
    while [[ -n $pp ]]
    do
      split_props -d $chp po pp $pp
      pf=$po[1]; po=${po: 1}
      # print -u2 - ">> ${pk}[$pf]={$po}  [$pp]"
      case ${pf:--} in
      ([cdgwtsaml]) PEN+=("$pk/$pf" "${po:-:}") ;;  # blank to default(:)
      (:) ;;
      (*) print -u2 "$0 [$pk/$pf=$po] Invalid pen flag." && return 1;;
      esac
    done
  done
  # diag -u2 PEN
  # return 1
  ## set default
  local -A NP=(0 1   T $#TSET   X $#DIR   S 3   L 1)
  local cpt= jp=
  local pux=()
  for pp po in "${(@kv)PEN}"
  do
    [[ x$po == x-  ]] && unset "PEN[$pp]" && continue
    [[ x$po == x-- ]] && continue
    pf=${pp#*/} pk=${pp%%/*}
    np=${NP[$pk]:-1}
    if [[ $po =~ , ]]; then
      po=("${(@s:,:)po}")
    else
      po=($po)
      case $pf in
      (c) [[ x$po == x: ]] && po=categorical:7
          split_props -d : cpt coff $po
          : ${coff:=0}
          po=($(gmt makecpt -Fr -T0/$((np+$coff+1))/1 -C$cpt | gawk '{print $2}'))
          shift $coff po
          ;;
      (d) if [[ x$po == x: ]]; then
            po=(100 90 80 70 60 50 40 30 20)
          else
            po=($(gmt math -o1 -T1/$np/1 'T' $po MUL =))
          fi
          ;;
      (g) [[ x$po == x: ]] && po=$(gmt math -Q 255 $np DIV FLOOR 64 MIN =)
          po=($(gmt math -o1 -T1/$np/1 'T' $po MUL =))
          ;;
      (a) [[ x$po == x: ]] && po=(0.3c);;
      (s) [[ x$po == x: ]] && po=(c t s d i a);;
      (w) [[ x$po == x: ]] && po=(thicker thick thin);;
      (t) [[ x$po == x: ]] && po=(solid - .);;
      (m) [[ x$po == x: ]] && po=(0:0);;
      esac
    fi
    # set total number
    unset "PEN[$pp]"
    PEN[${pp}:0]=$#po
    jp=1
    pux=(${=unqs[$pk]})
    while [[ $jp -le $#po ]]
    do
      if split_props -d : pk pv $po[$jp]; then
        PEN[${pp}:$pk]="$pv"
      else
        pv=$pk
        PEN[${pp}:$jp]="$pv"
        if [[ -n $pux[$jp] ]]; then
          pk=${pp}:$pux[$jp]
          [[ -z ${PEN[$pk]++} ]] && PEN[$pk]="$pv"
        fi
      fi
      let jp++
    done
  done
  # diag -u2 PEN
  # print -u2 "$0: ${(@kv)PEN}"
  [[ $__pen != PEN ]] && set -A $__pen "${(@kv)PEN}"
  return 0
}

extract_pen ()
{
  local __pen=$1; shift || return $?
  local __dprops=$1; shift || return $?
  local kpfx=$1

  [[ $__pen != Pen ]] && local -A Pen=
  Pen=()
  [[ $__dprops != DPROPS ]] && local -A DPROPS=("${(@Pkv)__dprops}")

  local k= kk=
  for k in ${DPROPS[(I)$kpfx/*]}
  do
    kk=${k#$kpfx/}
    # print -u2 - "$0 $k $kk $DPROPS[$k]"
    [[ $kk =~ / ]] && continue
    Pen[${kk}]="$DPROPS[$k]"
  done
  [[ $#Pen[s] == 1 ]] && Pen[s]=$Pen[s]$Pen[a]
  [[ -z $Pen[l] ]] && Pen[l]="${DPROPS[$kpfx]}"
  # print -u2 - "$0 $Pen"
  [[ $__pen != Pen ]] && set -A $__pen "${(@kv)Pen}"
  return 0
}

add_pen_props ()
{
  # print -u2 - "$0 $@"
  local chp=$1; shift || return $?
  local __dprops=$1; shift || return $?
  local __dk=$1; shift || return $?

  [[ $__dprops != DPROPS ]] && local -A DPROPS=("${(@Pkv)__dprops}")

  local -A Pen
  set_pen $chp Pen "$@" || return $?
  local k=
  for k in ${(k)Pen}
  do
    DPROPS[$__dk/$k]="$Pen[$k]"
  done

  [[ $__dprops != DPROPS ]] && set -A $__dprops "${(@Pkv)DPROPS}"
  return 0
}

# set_pen SEP VAR PEN [ARGS...]
#   ARGS  ID[:num]
#         +PROP[+PROP...]
# Later arguments overwrite.
set_pen ()
{
  local chp=$1; shift || return $?
  local __v=$1; shift || return $?
  local _params=$1; shift || return $?
  [[ $__v != Pen ]] && local -A Pen
  Pen=()
  [[ $_params != PARAMS ]] && local -A PARAMS=("${(@Pkv)_params}")
  # diag -u2 PARAMS
  local pf= po= pk= np= pj= pjm= pi=
  for pk in "$@"
  do
    if [[ $pk[1] == $chp ]];then
      while [[ -n $pk ]]
      do
        pk=${pk: 1}
        split_props $chp pf pk $pk
        po=${pf: 1}
        pf=$pf[1]
        if [[ x${po} == x-- || x${po} == x- ]]; then
          Pen[$pf]=
        elif [[ -n $po ]]; then
          Pen[$pf]=$po
        fi
      done
    else
      pi=
      pj=(${(s/=/)pk} 1)
      pk=$pj[1]; pj=$pj[2]
      # print -u2 - $pk $pj ${(kv)PARAMS[(I)$pk/*:0]} ${(kv)PARAMS[(I)$pk/*:$pj]}
      for pf in ${PARAMS[(I)$pk/*:0]}
      do
        np=$PARAMS[$pf]
        pi=${pf%:0}
        pf=${pi#$pk/}
        # print -u2 - $pk $pj $pf $pi $np
        [[ $pf == g ]] && pf=c
        pjm=$pj
        [[ $pjm -gt $np ]] && pjm=$((($pjm - 1) % $np + 1))
        po=${PARAMS[${pi}:$pjm]}
        if [[ x$po == x- ]]; then
          Pen[$pf]=
        elif [[ -n $po ]]; then
          Pen[$pf]=$po
        fi
      done
    fi
  done
  # diag -u2 Pen
  if [[ -n $Pen[d] && -n $Pen[c] ]]; then
    local ctmp=() c=
    for c in ${(s:/:)Pen[c]}
    do
      ## faster than gmtmath -Q
      ctmp+=($(print "scale=2; $c * $Pen[d] / 100" | bc))
    done
    Pen[c]="${(j:/:)ctmp}"
    # local ctmp=(${(s:/:)Pen[c]})
    # ctmp=($(print -l $ctmp | gmt math STDIN -Ca $Pen[d] MUL 100 DIV FLOOR =))
    # Pen[c]="${(j:/:)ctmp}"
  fi

  [[ $__v != Pen ]] && set -A $__v "${(@kv)Pen}"
  return 0
}

ps_finalize ()
{
  local keep=
  # local texd=
  [[ x$1 == x-k ]] && keep=T && shift
  # [[ x$1 == x--tex ]] && texd=$2 && shift 2
  local psf= eps=
  for psf in "$@"
  do
    eps=$psf:r.eps
    if [[ -e $psf ]]; then
      gmt psconvert -A -Te $psf || return $?
      rm -f -- $psf
    fi
    OUTPUT+=($eps)
  #   if [[ -n $texd ]] ;then
  #     gen_tex_psfragx $texd $eps
  #   fi
  done
  return 0
}

# parse_props SEP VALUE-ARRAY STRING....
#    +pPARAM+qPARAM+rPARAM++:XPARAM:YPARAM:ZPARAM::.....
#    ++SEP to change separator
parse_props ()
{
  # print -u2 - "$0 ${(q-)@}"
  local defchp=$1; shift || return $?
  local __varr=$1; shift || return $?
  [[ $__varr != varr ]] && local -A varr=()
  local chp=$defchp

  local str= cfg=
  for str in "$@"
  do
    if [[ $str[1] != $chp ]]; then
      print -u2 - "${0}[$__varr] cannot parse property $str"
      return 1
    fi
    str=${str: 1}
    while [[ -n $str ]]
    do
      if [[ $str[1] == $chp ]]; then
        # change separator
        chp=$str[2]
        str=${str: 2}
      else
        split_props -d "$chp" cfg str $str
        varr[$cfg[1]]="${cfg: 1}"
      fi
    done
  done
  if [[ x$__varr == x- ]]; then
    diag -u2 varr
  else
    [[ $__varr != varr ]] && set -A $__varr "${(@kv)varr}"
  fi
  return 0
}

# split_props [-d] SEP KEY VALUE STRING
#    -d to remove separator in VALUE
#    return 1 if no SEP in STRING
split_props ()
{
  local rmsep=  err=0
  [[ x$1 == x-d ]] && rmsep=T && shift
  local chp=$1; shift
  local __v=$1 __p=$2; shift 2 || return $?
  [[ $__v == v ]] || local v=
  [[ $__p == p ]] || local p=
  p=$1
  v=${p%%${chp}*}
  p=${p#$v}
  [[ x$p[1] != x$chp ]] && err=1
  [[ -n $rmsep ]] && p=${p#$chp}
  [[ x${__v:--} != x- && $__v != v ]] && : ${(P)__v::=$v}
  [[ x${__p:--} != x- && $__p != p ]] && : ${(P)__p::=$p}
  return $err
}

# GMT wrapper
#   wgmt COMMAND [OPTIONS....]
wgmt ()
{
  # local gmtcommon=(--MAP_TICK_LENGTH_PRIMARY=10p/7p
  #                  --MAP_TITLE_OFFSET=5p
  #                  --FONT_ANNOT_PRIMARY=15p
  #                  --FONT_LABEL=20p)
  local gmtcommon=(--MAP_TICK_LENGTH_PRIMARY=10p/7p
                   --MAP_TITLE_OFFSET=5p
                   --FONT_ANNOT_PRIMARY=20p,Helvetica-Narrow
                   --FONT_LABEL=25p)
  local gmtcmd=$1; shift
  local cmd=(gmt $gmtcmd $gmtcommon "$@")
  local err=0
  "${(@)cmd}"; err=$?
  if [[ $err -ne 0 ]]; then
    print -u2 - "FAILED:$err ${(@q-)cmd}"
  fi
  return $err
}

# psfragx wrapper
#   wpfx [PRINT OPTIONS] TAG REPLACEMENT
wpfx ()
{
  local popts=()
  local pfx=
  while [[ $# -gt 0 ]]
  do
    case $1 in
    (--pfx) pfx=$2; shift;;
    (-) shift; break;;
    (-*) popts+=("$1");;
    (*) break;;
    esac
    shift
  done
  local tag="$1" repl="$2"; shift 2
  local opts=
  opts+="[${1:-B}]"
  opts+="[${2:-B}]"
  opts+="[${3:-1}]"
  opts+="[${4:-0}]"
  [[ -n $tag ]] && print $popts -r - "${pfx}"'%<pfx> \psfrag'"{$tag}${opts}{$repl}"
  # [[ -n $tag ]] && print $popts -r - '%<pfx> \psfrag'"{$tag}[B][B][1][0]{$repl}"
  # if [[ -n $tag ]]; then
  #    print $popts -r -l - '%<*pfx>' '% \psfrag'"{$tag}[B][B][1][0]{$repl}" '%</pfx>'
  # fi
  # return 0
}

gen_tex_psfragx ()
{
  # set -x
  local texf=$1; shift
  local ops= obase= ohead= odest=
  local nps= neps=
  local definc=definc.tex
  if [[ ! -e $definc ]]; then
cat <<EOF > $definc
%% automatically generated
\documentclass[a4paper,10pt]{article}
\usepackage{fullpage}
\usepackage[T1]{fontenc}
\usepackage[ansinew]{inputenc}
\usepackage[hiresbb]{graphicx}
\usepackage{grffile}
\usepackage[sub]{psfragx}
\usepackage{color}
\pagestyle{empty}
\usepackage{sistyle}
\usepackage{bropd}
\makeatletter
\let\filename@simple\grffile@filename@simple
\makeatother
\newcommand{\SREP}[3]{{\LARGE\sffamily\bfseries #3}}
\newcommand{\XREP}[4]{{\LARGE\sffamily\bfseries #4}}
\newcommand{\CREP}[5]{{\LARGE\sffamily\bfseries #4 (\SI{}{#3})}}

\newcommand{\Age}{\ensuremath{\mathcal A}}
\newcommand{\ZZ}{\mathrm{Z}}
\newcommand{\TT}{\mathrm{T}}
\newcommand{\WW}{\mathrm{W}}

\endinput
EOF
  fi
  for ops in "$@"
  do
    ohead=$ops:h
    obase=$ops:r:t
    # odest=$texd/${ohead#*/}
    # otex=$odest/$obase.tex
    otex=$texf:r.tex
    # print -u2 - "$0: $ops $odest/$otex"
    if [[ ! -e $otex ]];then
      mkdir -p $otex:h
cat <<EOF > $otex
\input{$definc:r}
\begin{document}
\includegraphics[overwritepfx=false,ovp=false]%
                {$ops}
\end{document}
EOF
    fi
    if [[ -e $otex ]]; then
      latex --output-directory=$otex:h $otex
      nps=$otex:r.ps 
      neps=$nps:r.eps
      dvips -E -o $nps $otex:r.dvi
      epstool -b --copy $nps $neps
      rm -f $nps
      OUTPUT+=($neps)
    fi >& /dev/null
  done
  return 0
}



## diag [OPTION] VAR
diag ()
{
  local popts=()
  local vt=
  local pfx=
  while [[ $# -gt 0 ]]
  do
    case $1 in
    (-u*)  popts+=("$1");;
    (-l)   popts+=("$1");;
    (-p)   pfx="$2"; shift;;
    (*)    break;;
    esac
    shift
  done
  local _v= _k=
  for _v in "$@"
  do
    vt=${(tP)_v}
    case $vt in
    (association*)
      local -A _A=()
      set -A _A "${(@kvP)_v}"
      for _k in "${(@ok)_A}"
      do
        print $popts - "${pfx}diag/A ${_v}[$_k]=${(q-)_A[$_k]}"
      done
      ;;
    (array*)
      local _a=()
      set -A _a "${(@P)_v}"
      print $popts - "${pfx}diag/a ${_v}=(${(q-@)_a})"
      ;;
    (*)
      local _a="${(P)_v}"
      print $popts - "${pfx}diag/$vt ${_v}=${(q-)_a}"
      ;;
    esac
  done
  return 0
}

[[ ! -e $0.zwc || $0.zwc -ot $0 ]] && print -u2 "compile $0" && zcompile $0

main "$@"; err=$?
[[ -n $zprof ]] && print - 'ZPROF' && zprof
if [[ $err -ne 0 ]]; then
  print -u2 - "ERROR: $0 ${(q-)@}"
fi
exit $err
