#!/usr/bin/zsh -f
# Time-stamp: <2020/09/15 12:51:55 fuyuki gfig2.sh>
#
# Copyright: 2019--2020 JAMSTEC, Ayako ABE-OUCHI
# Licensed under the Apache License, Version 2.0
#   (https://www.apache.org/licenses/LICENSE-2.0)

# ----------------------------------------------------------------------
zmodload zsh/zprof
zmodload zsh/nearcolor
zmodload zsh/parameter
setopt pipefail

typeset -g ABHsub=(u l p d f)
typeset -g BCVAR=(msmin msmax mbmin mbmax hmin hmax)
typeset -gA SEP=([p]='+' [f]=':' [g]='/' [r]='=' [c]=',' [o]='.' [d]='-' [v]=':')
# ----------------------------------------------------------------------
main ()
{
  local err=0
  local TRACE=()
  local -A OPTS=([verbose]=-1 [exec]='gen draw fig leg' [dir]='.')
  local -A VSET=() XSET=() GSET=()
  local gset=() vset=()
  local etag=
  local DRAW=(0:)
  local a=
  # options
  while [[ $# -gt 0 ]]
  do
    case $1 in
    (--trace=-)  TRACE=();;
    (--trace=*)  TRACE+=(${(s:,:)${1#*=}});;
    (--trace+=*) TRACE=(allf allv ${(s:,:)${1#*=}});;
    (--trace)    TRACE=(allf allv);;
    (--prof)     typeset -g prof=T;;

    (-d)         DRAW=(${(s:,:)2}); shift;;
    (-d*)        DRAW=(${(s:,:)${1: 2}});;
    (+d)         DRAW+=(${(s:,:)2}); shift;;
    (+d*)        DRAW+=(${(s:,:)${1: 2}});;

    (--exec=*)   OPTS[exec]="${1#*=}";;

    (--tex=*)    OPTS[exec]+=" tex"
                 OPTS[tmpl]="${1#*=}";;
    (--tex)      OPTS[exec]+=" tex";;

    (--view)     OPTS[exec]+=" view";;
    (--view=*)   OPTS[exec]+=" view"; OPTS[view]=${1#*=};;
    (--conv)     OPTS[exec]+=" conv"; OPTS[conv]=$2;;
    (--conv=*)   OPTS[exec]+=" conv"; OPTS[conv]=${1#*=};;
    (--prog*)    OPTS[exec]+=" prog";;

    (--marker)   OPTS[marker]=T;;

    (--dir)      OPTS[dir]+=" $2"; shift;;  # search
    (--dir=*)    OPTS[dir]+=" ${1#*=}";;

    (-q)         OPTS[verbose]=+1;;
    (+q)         OPTS[verbose]=+128;;
    (-v)         OPTS[verbose]=0;;
    (+v)         OPTS[verbose]=-128;;

    (+p)         OPTS[proot]=$2; shift;;
    (+p*)        OPTS[proot]=${1: 2};;
    (-p)         OPTS[pfx]+=" $2"; shift;;
    (-p*)        OPTS[pfx]+=" ${1: 2}";;

    (-s)         OPTS[sfx]+=" $2"; shift;;
    (-s*)        OPTS[sfx]+=" ${1: 2}";;

    (-C)         cfg=$2
                 [[ ! -e $cfg ]] && logmsg -e "cannot find $cfg." && return 1
                 . $cfg || return $?
                 shift;;
    (-C*)        cfg=${1: 2}
                 [[ ! -e $cfg ]] && logmsg -e "cannot find $cfg." && return 1
                 . $cfg || return $?
                 ;;
    (+G*)        # +G   GSET ...  -
                 # +G/  GSET ...  /
                 etag=${${1: 2}:--}
                 shift
                 etag=${@[(i)$etag]}; let etag--
                 gset+=("$@[1,$etag]")
                 shift $etag
                 ;;
    (-G)         gset+=("$2"); shift;;
    (-G*)        gset+=("${1: 2}");;

    (+V*)        # +V   VSET ...  -
                 # +V/  VSET ...  /
                 etag=${${1: 2}:--}
                 shift
                 etag=${@[(i)$etag]}; let etag--
                 vset+=("$@[1,$etag]")
                 shift $etag
                 ;;
    (-V)         vset+=("$2"); shift;;
    (-V*)        vset+=("${1: 2}");;

    (--)        shift; break;;
    ([---+]*)   logmsg -e "Unknown argument $1."; return 1;;
    (*)         break;;
    esac
    shift
  done
  adjust_options OPTS || return $?
  # variables configuration
  #    property
  #         ++                   switch back to default property mark (+)
  #         ++<T>                set <T> as property mark
  #         +<PROP>== =          append <PROP> property as '='
  #         +<PROP>== <PARAM>    append <PROP> property as <PARAM> (hungry argument)
  #         +<PROP>=<PARAM>      append <PROP> property as <PARAM>
  #         +<PROP>=             append <PROP> as null ('')
  #         +<P><SHORT>[+<P>...] append <P> properties as <SHORT> (multiple)
  #         +<P>                 append <P> as null ('')
  #         -<PROP>              remove <PROP>
  #    end of configuration
  #         :*                   exit to experiment parser from this
  #         /*                   exit to experiment parser from this
  #         --                   exit to experiment parser from next
  #    variable declaration
  #         <VAR>[+.]                Declare variable <VAR>
  #         <VAR>[+<PROP>=<PARAM>]   Declare variable <VAR> with <PROP> property as <PARAM>
  #         <VAR>[+<P><SHORT>][+...] set <P> (single letter) property as <PARAM>
  #         <VAR>.<OPR>              alias for <VAR>+o<OPR>
  #
  #      <SHORT> cannot contain [+=]
  #      <PARAM> specials (reserved)
  #        +NULL    set property with ''
  #        +DEL     remove property
  #        +SKIP    not touch
  local psep=$SEP[p] fsep=$SEP[f] gsep=$SEP[g] rsep=$SEP[r] dsep=$SEP[d] osep=$SEP[o]
  while [[ $# -ge 0 ]]
  do
    case $1 in
    # variable configuration end
    (--)     shift && break;;
    # property option mark
    ($SEP[p]$SEP[p])    psep=$SEP[p] vset+=($1);;              # switch back to default
    ($psep$psep*)   psep="${1#$psep$psep}" vset+=($1);;  # switch manually
    ($psep*$rsep$rsep)  vset+=("$1" "$2"); shift || return $?;;
    ($psep*)            vset+=($1);;
    ($dsep*)            vset+=($1);;
    # variable configuration end
    ($fsep*) break;;
    ($gsep*) break;;
    ('')     break;;
    # variable declaration
    (*)  [[ -d $1 ]] && break
         vset+=($1);;
    esac
    shift
  done
  # experiment
  #    property
  #         ++                   switch back to default property mark (+)
  #         ++<T>                set <T> as property mark
  #         +<PROP>== =          append <PROP> property as '='
  #         +<PROP>== <PARAM>    append <PROP> property as <PARAM> (hungry argument)
  #         +<PROP>=<PARAM>      append <PROP> property as <PARAM>
  #         +<PROP>=             append <PROP> as null ('')
  #         +<P><SHORT>[+<P>...] append <P> properties as <SHORT> (multiple)
  #         +<P>                 append <P> as null ('')
  #         + <P><SHORT>[+<P>..] append <P> properties as <SHORT> (multiple)
  #         + <PROP>=<PARAM>     append <PROP> property as <PARAM>
  #         -<PROP>              remove <PROP>
  #         -                    alias of +o- (i.e., skip to plot)
  #    entry declaration
  #         /                        update refrence entry
  #         /<NUM>                   pset refrence entry as <NUM>
  #         :                        eat next and parse
  #         :<KEY>== <FILTER>        add <KEY> as <FILTER> in current entry
  #         :<KEY>==<FILTER>         add <KEY> as <FILTER> in current entry
  #         :<KEY>==<FILTER>[:FILTER].. Try filters until found  (e.g., :B==0:0cm)
  #         :<KEY>=[<FILTER>][:...]  add <KEY> as <FILTER> in current entry (multiple)
  #         :<KEY>=[:...]            add <KEY> as null in current entry
  #         :<KEY>[:...]             remove key
  #         ENTRY:<KEY>=<FILTER>...  add entry with filters
  #         <KEY>=<FILTER>           add entry with filters
  local psep=$SEP[p] fsep=$SEP[f] gsep=$SEP[g] rsep=$SEP[r]
  local jx=-1 jxp= jxref=0$SEP[f]
  local kx= kxp= ke= kep= egp=
  local x= p=
  local sdef=SOL$fsep
  for x p in '' '' T hlp D xs2 P xsol S o12i4
  do
    XSET[$sdef$x]=$p
  done
  local ldef=LEV$fsep
  for x p in '' '' T hlp D xs2 P xsol S o15i12m0e1r1000
  do
    XSET[$ldef$x]=$p
  done
  while [[ $# -gt 0 ]]
  do
    jxp=$jx; [[ $jxp -lt 0 ]] && jxp=0
    kxp="$jxp$SEP[p]" kep="$jxp$SEP[f]" egp="e$fsep$jxp"
    case $1 in
    # property option mark (NOT YET IMPLEMENTED)
    ($SEP[p]$SEP[p])    psep=$SEP[p] gset+=($1);;              # switch back to default
    ($psep$psep*)   psep="${1#$psep$psep}" gset+=($1);;  # switch manually
    # property (long)
    ($psep*$rsep$rsep)  gset+=("$egp$1$2"); shift || return $?;;
    ($psep*$rsep*)      gset+=("$egp$1");;
    # single separator eats next
    ($psep)             gset+=("$egp$1$2"); shift;;
    # property (short)
    ($psep*)            gset+=("$egp$1");;
    # property (delete)
    ($dsep*)            gset+=("$egp$1");;
    # reference change
    ($gsep)   jxref="$jx$SEP[f]";;
    ($gsep*)  jxref="${1#$gsep}$SEP[f]";;
    # entry
    (*) x= p=
        case $1 in
        ($fsep)   ke="$kep" p="$1$2"; shift || return $?;;
        ($fsep*)  ke="$kep" p="$1";;
        (*) let jx++
            ke="${jx}$SEP[f]"
            XSET[${ke}R]="$jxref"
            x="$1"
            if [[ ${x[(I)$fsep]} -gt 0 ]]; then
              p=$fsep${x#*$fsep}; x=${x%%$fsep*}
            elif [[ ${x[(I)$rsep]} -gt 0 ]]; then
              p="$x"; x=
            else
              p=
            fi
            XSET[${ke}]="$x"
            # GSET[e$fsep${jx}${psep}o]=$jx    # force set default order
            # GSET[e$fsep${jx}${psep}lo]=$jx
            ;;
        esac
        case $p in
        ('') ;;
        (*$rsep$rsep)  add_prop_long XSET "$ke" "$fsep" "$rsep$rsep" "$p" "$2" || return $?
                       shift;;
        (*$rsep$rsep*) add_prop_long XSET "$ke" "$fsep" "$rsep$rsep" "$p" || return $?
                       ;;
        (*)            add_props_short XSET "$ke" "$fsep" "$rsep" "$p" || return $?;;
        esac
        ;;
    esac
    shift
    # diag -P +p -c gset
  done
  # parse variables
  parse_vset OPTS VSET "${(@)vset}" || return $?
  # parse graphics
  init_gset OPTS GSET || return $?
  parse_gset GSET "${(@)gset}" || return $?
  # parse draw set
  parse_draw DRAW VSET "${(@)DRAW}" || return $?
  # run all procedures
  run_all OPTS GSET VSET XSET "${(@)DRAW}"; err=$? || return $?
  # final diag
  [[ $err -eq 0 && $OPTS[verbose] -ge 0 ]] && diag_debug
  return $err
}
# ----------------------------------------------------------------------
adjust_options ()
{
  local __opts=$1; shift || return $?
  [[ $__opts != OPTS ]] && local -A OPTS=("${(@Pkv)__opts}")

  local x= X=()
  for x in ${=${(s:,:)OPTS[exec]}}
  do
    case $x in
    (--) X=();;
    (-*) X[(r)${x: 1}]=();;
    (+*) X+=(${x: 1});;
    (*)  X+=($x);;
    esac
  done
  X=(${(uo)X})
  OPTS[exec]="$X"

  local proot=${OPTS[proot]:-.}

  : ${OPTS[asc]:=$proot/asc}
  : ${OPTS[tps]:=$proot/tps}

  [[ ${${OPTS[exec]}[(wI)tex]} -gt 0 ]] && : ${OPTS[ps]:=$OPTS[tps]}
  : ${OPTS[ps]:=$proot/ps}
  : ${OPTS[tex]:=$proot/tex}
  : ${OPTS[tmpl]:=-}

  : ${OPTS[c.gsets]:=.cache.gsets}
  : ${OPTS[c.prop]:=cache.prop}
  : ${OPTS[c.btable]:=cache.btable}
  : ${OPTS[c.tidx]:=cache.tidx}

  : ${OPTS[nc.cfg]:=vxcfg.nc}
  : ${OPTS[nc.seq]:=vmta.nc}

  : ${OPTS[pr.BC]:=d}
  : ${OPTS[pr.V]:=d}

  : ${OPTS[f.agesol]:=agesol.dat}
  : ${OPTS[f.levsol]:=levsol.dat}
  : ${OPTS[f.sample]:=sample.dat}

  [[ $__opts != OPTS ]] && set -A $__opts "${(@kv)OPTS}"
  return 0
}
# ----------------------------------------------------------------------
# variables configuration
#    property
#         ++                   switch back to default property mark (+)
#         ++<T>                set <T> as property mark
#         +<PROP>== =          append <PROP> property as '='
#         +<PROP>== <PARAM>    append <PROP> property as <PARAM> (hungry argument)
#         +<PROP>=<PARAM>      append <PROP> property as <PARAM>
#         +<PROP>=             append <PROP> as null ('')
#         +<P><SHORT>[+<P>...] append <P> properties as <SHORT> (multiple)
#         +<P>                 append <P> as null ('')
#         -<PROP>              remove <PROP>
#    end of configuration
#         :*                   exit to experiment parser from this
#         /*                   exit to experiment parser from this
#         --                   exit to experiment parser from next
#    variable declaration
#         <VAR>[+.]                Declare variable <VAR>
#         <VAR>[+<PROP>=<PARAM>]   Declare variable <VAR> with <PROP> property as <PARAM>
#         <VAR>[+<P><SHORT>][+...] set <P> (single letter) property as <PARAM>
#         <VAR>.<OPR>              alias for <VAR>+o<OPR>
#
#      <SHORT> cannot contain [+=]
#      <PARAM> specials (reserved)
#        +NULL    set property with ''
#        +DEL     remove property
#        +SKIP    not touch
parse_vset ()
{
  local err=0
  local _opts=$1; shift || return $?
  local _vset=$1; shift || return $?
  [[ $_opts != OPTS ]] && local -A OPTS=("${(@Pkv)_opts}")
  [[ $_vset != VSET ]] && local -A VSET=("${(@Pkv)_vset}")

  local psep=$SEP[p] rsep=$SEP[r] dsep=$SEP[d] osep=$SEP[o]

  local null=''
  local jv=-1 jvp= vnm= pstr= ostr=
  local kv= kvp=
  while [[ $# -gt 0 ]]
  do
    jvp=$jv; [[ $jvp -lt 0 ]] && jvp=0
    kvp="$jvp$SEP[p]"
    case $1 in
    # variable configuration end
    (--)     shift && break;;
    # property option mark
    ($SEP[p]$SEP[p])    psep=$SEP[p];;              # switch back to default
    ($psep$psep*)   psep="${1#$psep$psep}";;  # switch manually
    # property (long)
    ($psep*$rsep$rsep)  add_prop_long VSET "$kvp" "$psep" "$rsep$rsep" "$1" "$2" || return $?
                        shift || return $?;;
    ($psep*$rsep*)      add_prop_long VSET "$kvp" "$psep" "$rsep"      "$1" || return $?;;
    # property (short)
    ($psep*)            add_props_short VSET "$kvp" "$psep" "$null" "$1" || return $?;;
    # property (delete)
    ($dsep*)            unset "VSET[$kvp${1#$dsep}]";;
    # variable declaration
    (*)  [[ -d $1 ]] && break
         let jv++
         kv="$jv$SEP[p]"
         vnm=${1%%$psep*}
         pstr=${1#$vnm}
         ostr=(${(ps:$osep:)vnm}); vnm=$ostr[1]; shift ostr
         # alias
         if [[ -n $ostr ]]; then
           add_props_short VSET "$kv" "$psep" "$null" "${psep}o${ostr}" || return $?
         fi
         VSET[$jv$SEP[p]]="$vnm"
         # properties
         case $pstr in
         ($psep)        ;;
         ($psep*$rsep*) add_prop_long   VSET "$kv" "$psep" "$rsep" "$pstr" || return $?;;
         ($psep*)       add_props_short VSET "$kv" "$psep" "$null" "$pstr" || return $?;;
         ('')           ;;
         (*)            logmsg -f "Panic"; exit 1;;
         esac
         ;;
    esac
    shift
  done

  [[ $_vset != VSET ]] && set -A $_vset "${(@kv)VSET}"
  return 0
}
# ----------------------------------------------------------------------
parse_draw ()
{
  local _draw=$1; shift || return $?
  local _vset=$1; shift || return $?
  [[ $_vset != VSET ]] && local -A VSET=("${(@Pkv)_vset}")
  [[ $_draw != DRAW ]] && local DRAW=()
  DRAW=()
  local vd=
  local vsep=$SEP[v] psep=$SEP[p]
  local xvi= yvi=
  local vall=(${(n)VSET[(I)[0-9]*$psep]})
  vall=(${vall%$psep})
  for vd in "$@"
  do
    vd=("${(@ps/$vsep/)vd}")
    inq_var xvi "$vd[1]" VSET || return $?
    inq_var yvi "$vd[2]" VSET || return $?
    [[ -z $xvi ]] && xvi=($vall)
    [[ -z $yvi ]] && yvi=($vall)
    for xvi in $xvi
    do
      for yvi in $yvi
      do
        [[ $xvi -eq $yvi ]] && continue
        DRAW+=($xvi$vsep$yvi)
      done
    done
  done
  DRAW=(${(u)DRAW})
  # diag -P +p -c vall DRAW

  [[ $_draw != DRAW ]] && set -A $_draw "${(@)DRAW}"
  return 0
}
# ----------------------------------------------------------------------
run_all ()
{
  local err=0
  local __opts=$1; shift || return $?
  local __gset=$1; shift || return $?
  local __vset=$1; shift || return $?
  local __xset=$1; shift || return $?

  [[ $__opts != OPTS ]] && local -A OPTS=("${(@Pkv)__opts}")
  [[ $__gset != GSET ]] && local -A GSET=("${(@Pkv)__gset}")
  [[ $__vset != VSET ]] && local -A VSET=("${(@Pkv)__vset}")
  [[ $__xset != XSET ]] && local -A XSET=("${(@Pkv)__xset}")

  local vv=("$@")
  parse_vall OPTS GSET VSET XSET || return $?
  draw_vall  OPTS GSET VSET $vv || return $?

  [[ $__opts != OPTS ]] && set -A $__opts "${(@kv)OPTS}"
  [[ $__vset != VSET ]] && set -A $__vset "${(@kv)VSET}"
  [[ $__xset != XSET ]] && set -A $__xset "${(@kv)XSET}"
  return $err
}
# ----------------------------------------------------------------------
draw_vall ()
{
  local err=0
  local _opts=$1; shift || return $?
  local __gset=$1; shift || return $?
  local __vset=$1; shift || return $?
  [[ $_opts  != OPTS ]] && local -A OPTS=("${(@Pkv)_opts}")
  [[ $__gset != GSET ]] && local -A GSET=("${(@Pkv)__gset}")
  [[ $__vset != VSET ]] && local -A VSET=("${(@Pkv)__vset}")

  local prec=$OPTS[pr.V]
  local psep=$SEP[p] fsep=$SEP[f] vsep=$SEP[v]

  set_ranges_all GSET VSET "$prec" ${(on)${VSET[(I)*$psep]}} || return $?

  local psf= PSF=()
  local vd= dreg=() xvi= yvi=

  for vd in "$@"
  do
    vd=(${(ps/$vsep/)vd})
    xvi=$vd[1] yvi=$vd[2]

    set_draw_ranges dreg GSET $xvi $yvi || return $?

    draw_open psf OPTS GSET VSET $xvi $yvi || return $?
    if [[ ${${OPTS[exec]}[(wI)fig]} -gt 0 ]]; then
      if [[ ${${OPTS[exec]}[(wI)draw]} -gt 0 ]]; then
        if [[ x$psf == x- ]]; then
          exec 4>&1
        else
          mkdir -p $psf:h || exit $?
          exec 4> $psf
        fi
        draw_basemap OPTS VSET $xvi $yvi $dreg || return $?
        draw_field GSET VSET $xvi $yvi $dreg || return $?
        draw_markers OPTS || return $?
        draw_fine  OPTS $psf || return $?
        exec 4>&-
      fi
      [[ x$psf != x- ]] && PSF+=($psf)
    fi
  done

  psf=
  draw_open psf OPTS GSET VSET leg || return $?
  if [[ ${${OPTS[exec]}[(wI)leg]} -gt 0 ]]; then
    if [[ ${${OPTS[exec]}[(wI)draw]} -gt 0 ]]; then
      draw_legend OPTS GSET $psf || return $?
    fi
    [[ x$psf != x- ]] && PSF+=($psf)
  fi

  draw_post OPTS "${(@)PSF}" || return $?

  [[ $__vset != VSET ]] && set -A $__vset "${(@kv)VSET}"
  return $err
}
# ----------------------------------------------------------------------
set_ranges_all ()
{
  local __gset=$1; shift || return $?
  local __vset=$1; shift || return $?
  [[ $__gset != GSET ]] && local -A GSET=("${(@Pkv)__gset}")
  [[ $__vset != VSET ]] && local -A VSET=("${(@Pkv)__vset}")

  local prec=$1; shift || return $?

  local psep=$SEP[p] fsep=$SEP[f]
  local gk= rlog= range=()
  local vi=
  for vi in "$@"
  do
    gv=${vi%%[^0-9]*}
    get_var_range range "${(@v)GSET[(I)[0-9]*$fsep$gv]}" || return $?
    gk=$fsep$gv
    GSET[Rl$gk]="$range[1] $range[3]"
    GSET[Ru$gk]="$range[2] $range[4]"
    rlog=(${(s/:/)VSET[${vi}Rlog]})
    GSET[Rlog$gk]="$rlog"
    [[ ${+VSET[${vi}q]} -eq 1 ]] && print -u2 - "range:$vi$VSET[$vi] == ($GSET[Rl$gk]) ($GSET[Ru$gk])"
  done
  [[ $__vset != VSET ]] && set -A $__vset "${(@kv)VSET}"
  [[ $__gset != GSET ]] && set -A $__gset "${(@kv)GSET}"
  return 0
}
# ----------------------------------------------------------------------
inq_var ()
{
  local err=0
  local __vi=$1; shift || return $?
  local var=$1; shift || return $?
  [[ -z $var ]] && : ${(P)__vi::=} && return 0
  local _vset=$1; shift || return $?

  [[ $__vi != vi ]] && local vi=
  [[ $_vset != VSET ]] && local -A VSET=("${(@Pkv)_vset}")
  local psep=$SEP[p]

  local vl=(${(k)VSET[(R)$var]})
  vl=(${(M)vl:#*$psep})
  if [[ $#vl -gt 1 ]]; then
    logmsg -e "Ambiguous variable $var ($vl)"
    return 1
  elif [[ $#vl -eq 1 ]]; then
    vi=${vl%%[^0-9]*}
  elif [[ ${+VSET[$var$psep]} -eq 1 ]];then
    vi=$var
  else
    logmsg -e "No variable $var"
    return 1
  fi

  [[ $__vi != vi ]] && : ${(P)__vi::=$vi}
  return 0
}
# ----------------------------------------------------------------------
draw_post ()
{
  local _opts=$1; shift || return $?
  [[ $_opts  != OPTS ]] && local -A OPTS=("${(@Pkv)_opts}")

  local PSF=($@)

  local psf= epsf= EPSF=()

  for psf in ${(u)PSF}
  do
    epsf=$psf:r.eps
    if [[ ${${OPTS[exec]}[(wI)draw]} -gt 0 ]]; then
      gmt psconvert -A -Z -Te $psf || return $?
    fi
    EPSF+=($epsf)
  done
  # diag -P +p -c PSF EPSF

  if [[ ${${OPTS[exec]}[(wI)tex]} -gt 0 ]]; then
    local psub= texf=
    local oEPSF=($EPSF)
    EPSF=()
    for epsf in $oEPSF
    do
      psub=$(realpath -s --relative-base=$OPTS[ps] -m $epsf)
      texf=$OPTS[tex]/${psub:r}.tex
      gen_tex_psfragx $texf $OPTS[tmpl] $epsf || return $?
      EPSF+=(${texf:r}.eps)
    done
  fi

  if [[ ${${OPTS[exec]}[(wI)view]} -gt 0 ]]; then
    local view=("${(@s/:/)OPTS[view]}")
    local vfmt=${view[1]:-eps}
    local vcmd=${view[2]}
    case $vfmt in
    (ps|eps)
      : ${vcmd:=gv}
      for epsf in $EPSF
      do
        print - $epsf
        $vcmd $epsf
      done
      ;;
    (png)
      : ${vcmd:=display}
      local vf=
      for epsf in $EPSF
      do
        vf=$epsf:r.png
        convert -background white -flatten $epsf $vf || return $?
        print - $vf
        $vcmd $vf
      done
      ;;
    (*) logmsg -e "Unknown format to view: $vfmt"; return 1;;
    esac
  else
    print -l - $EPSF
  fi
  return 0
}
# ----------------------------------------------------------------------
draw_open ()
{
  local err=0
  local __psf=$1; shift || return $?
  local _opts=$1; shift || return $?
  local _gset=$1; shift || return $?
  local _vset=$1; shift || return $?
  [[ $_gset != GSET ]] && local -A GSET=("${(@Pkv)_gset}")
  [[ $_opts != OPTS ]] && local -A OPTS=("${(@Pkv)_opts}")
  [[ $_vset != VSET ]] && local -A VSET=("${(@Pkv)_vset}")

  local psep=$SEP[p]

  [[ $__psf != psf ]] && local psf=

  local xpfx='' rpfx=r
  local vpfx=() vi= vk= vp=
  for vi in "$@"
  do
    vk=${vi}$psep
    vp=$VSET[${vk}o]
    vp+=$VSET[${vk}]
    vp+=$VSET[${vk}sfx]
    vpfx+=(${vp:-$vi})
  done
  vpfx=${(j:_:)vpfx}

  local dbase="$GSET[${psep}base]"
  local dref="$GSET[${psep}ref]"
  local dsub="$GSET[${psep}sub]"
  local sfx="$GSET[${psep}sfx]"

  local usfx=(${=OPTS[sfx]})
  [[ -n $usfx ]] && usfx=_${(j:_:)usfx}

  # print -u2 - dsub:$dsub
  # print -u2 - dref:$dref
  # print -u2 - dbase:$dbase

  psf=$OPTS[ps]/$dsub/$dref/$dbase/$vpfx$sfx$usfx.ps
  # print -u2 - $psf $PWD
  psf=$(realpath -s --relative-base=$PWD:A -m $psf)
  # print -u2 - $psf
  [[ $__psf != psf ]] && : ${(P)__psf::=$psf}
  return 0
}
# ----------------------------------------------------------------------
extract_comdiff ()
{
  local __pcomm=$1 __pdiff=$2; shift 2 || return $?
  local _opts=$1; shift || return $?
  local _xset=$1; shift || return $?
  [[ $_opts != OPTS ]] && local -A OPTS=("${(@Pkv)_opts}")
  [[ $_xset != XSET ]] && local -A XSET=("${(@Pkv)_xset}")

  local tmpd=$(mktemp -d)
  local rf=$tmpd/ref xf=$tmpd/x

  if [[ $__pcomm[1] == + ]]; then
    __pcomm=${__pcomm: 1}
    [[ $__pcomm != pcomm ]] && local pcomm=("${(@P)__pcomm}")
  else
    [[ $__pcomm != pcomm ]] && local pcomm=()
    pcomm=()
  fi
  [[ $__pdiff != pdiff ]] && local pdiff=()
  pdiff=()

  if [[ -n $pcomm ]]; then
    print -l "${(@o)pcomm}" > $rf
  fi

  local pprop=() xt=()
  for xj in "$@"
  do
    cache_pprop pprop OPTS "$XSET[${xj}]" "${XSET[${xj}T]}" "$XSET[${xj}p]" "$XSET[${xj}b]" || return $?
    # diag -P +p -c pprop
    xt=(${${=XSET[${xj}t]}%,*})
    pprop+=("t=${(j:,:)xt}")
    if [[ ! -e $rf ]]; then
      print -l "${(@o)pprop}"> $rf
      pcomm=($pprop) pdiff=()
    else
      print -l "${(@o)pprop}" > $xf
      pcomm=($(comm -12 $rf $xf))
      pdiff+=($(comm -3  $rf $xf))
      print -l "${(@o)pcomm}" > $rf
    fi
  done
  rm -rf $tmpd

  [[ $__pcomm != pcomm ]] && set -A $__pcomm "${(@)pcomm}"
  [[ $__pdiff != pdiff ]] && set -A $__pdiff "${(@)pdiff}"
  return 0
}
# ----------------------------------------------------------------------
set_pdiff ()
{
  local _xset=$1; shift || return $?
  local __pcomm=$1; shift || return $?
  [[ $_xset != XSET ]] && local -A XSET=("${(@Pkv)_xset}")
  [[ $__pcomm != pcomm ]] && local pcomm=("${(@P)__pcomm}")

  local tmpd=$(mktemp -d)
  local rf=$tmpd/ref xf=$tmpd/x

  print -l "${(@o)pcomm}" > $rf
  # print -u2 - "REF: ${(@o)pcomm}"
  local pprop=() xt=() pdiff=()
  for xj in "$@"
  do
    cache_pprop pprop OPTS "$XSET[${xj}]" "${XSET[${xj}T]}" "$XSET[${xj}p]" "$XSET[${xj}b]" || return $?
    # diag -P +p -c pprop
    xt=(${${=XSET[${xj}t]}%,*})
    pprop+=("t=${(j:,:)xt}")
    print -l "${(@o)pprop}" > $xf
    pdiff=($(comm -13 $rf $xf))
    XSET[${xj}xd]="$pdiff"
    # print -u2 - "$xj: ${(@o)pprop} <$pdiff>"
  done
  # diag -P +p -c pcomm

  rm -rf $tmpd

  [[ $_xset != XSET ]] && set -A $_xset "${(@kv_XSET}"
  [[ $__pcomm != pcomm ]] && set -A $__pcomm "${(@)pcomm}"
  return 0
}
# ----------------------------------------------------------------------
gather_comdiff ()
{
  local __pcomm=$1 __pdiff=$2; shift 2 || return $?

  local _opts=$1; shift || return $?
  local _xset=$1; shift || return $?
  [[ $_opts != OPTS ]] && local -A OPTS=("${(@Pkv)_opts}")
  [[ $_xset != XSET ]] && local -A XSET=("${(@Pkv)_xset}")
  local xpfx=$1

  [[ $__pcomm != pcomm ]] && local pcomm=()
  [[ $__pdiff != pdiff ]] && local pdiff=()

  pcomm=() pdiff=()

  local tmpd=$(mktemp -d)

  local rf=$tmpd/ref xf=$tmpd/x
  local xt= xj= XJ=(${(n)${XSET[(I)${xpfx}[0-9]*${fsep}]}})
  for xj in "${(@)XJ}"
  do
    case ${XSET[${xj}T]} in
    (hlp|sol) logmsg -d "$0 skip $xj" && continue;;
    esac
    cache_pprop pprop OPTS "$XSET[${xj}]" "${XSET[${xj}T]}" "$XSET[${xj}p]" "$XSET[${xj}b]" || return $?
    # diag -P +p -c pprop
    xt=(${${=XSET[${xj}t]}%,*})
    pprop+=("t=${(j:,:)xt}")
    if [[ ! -e $rf ]]; then
      print -l "${(@o)pprop}"> $rf
      pcomm=($pprop) pdiff=()
    else
      print -l "${(@o)pprop}" > $xf
      pcomm=($(comm -12 $rf $xf))
      pdiff+=($(comm -3  $rf $xf))
      print -l "${(@o)pcomm}" > $rf
    fi
  done
  rm -rf $tmpd
  [[ $__pcomm != pcomm ]] && set -A $__pcomm "${(@)pcomm}"
  [[ $__pdiff != pdiff ]] && set -A $__pdiff "${(@)pdiff}"
  return 0
}
# ----------------------------------------------------------------------
adj_pcomm ()
{
  local __acomm=$1 __tcomm=$2; shift 2 || return $?
  [[ $__acomm != acomm ]] && local -A acomm=()

  parse_aa_str acomm "$@" || return $?
  local k= kk= v=
  for k in A B H
  do
    if [[ ${acomm[${k}l]:-l} == ${acomm[${k}u]:-u} ]]; then
      v=${acomm[${k}l]}
      for kk in $acomm[(I)$k*]
      do
        unset "acomm[$kk]"
      done
      acomm[$k]=$v
    fi
  done
  [[ ${acomm[A]:-A} == ${acomm[B]:-B} ]] && acomm[W]=${acomm[A]} && unset 'acomm[A]' 'acomm[B]'

  : ${(P)__tcomm::=$acomm[t]}
  unset 'acomm[t]'
  [[ $__acomm != acomm ]] && set -A $__acomm "${(@kv)acomm}"
  return 0
}
# ----------------------------------------------------------------------
adj_pdiff ()
{
  local __adiff=$1 __tdiff=$2; shift 2 || return $?
  [[ $__adiff != adiff ]] && local -A adiff=()

  local k= kk= v=
  local fixchk=()
  for v in "${(u)@}"
  do
    # print -u2 - $v
    k=${v%%=*}
    v=${v#*=}
    case $k in
    ([HAB]) [[ x$v == x- ]] && fixchk+=($k);;
    esac
    adiff[$k]=$((${adiff[$k]-0} + 1))
  done
  for k in H A B
  do
    if [[ $fixchk[(I)$k] -gt 0 ]]; then
      unset "adiff[$k]"
    else
      unset "adiff[${k}u]" "adiff[${k}l]"
    fi
  done
  for k in ${(k)adiff}
  do
    if [[ $adiff[$k] -eq 1 ]]; then
      kk=$pdiff[(r)$k=*]
      adiff[$k]=${kk#*=}
    fi
  done

  : ${(P)__tdiff::=$adiff[t]}
  unset 'adiff[t]'
  [[ $__adiff != adiff ]] && set -A $__adiff "${(@kv)adiff}"
  return 0
}
# ----------------------------------------------------------------------
cache_pprop ()
{
  local __pprop=$1; shift || return $?
  local _opts=$1; shift || return $?
  [[ $_opts != OPTS ]] && local -A OPTS=("${(@Pkv)_opts}")
  local xdir=$1 xtyp="$2"; shift 2 || return $?
  local xp="$1" bp="$2"

  [[ $__pprop != pprop ]] && local pprop=()

  local cache=$OPTS[asc]/$xdir/$OPTS[c.prop]
  bp=(${=bp}); local bpos=(${bp: :2})
  local ckey="pprop:${xdir}:${(j:,:)bpos}"
  read_cache -a pprop "$ckey" $cache || return $?
  if [[ -z $pprop ]]; then
    local -A bprop=() xprop=()
    parse_aa_str xprop $xp || return $?
    parse_aa_str bprop ${bp: 2} || return $?
    local k=
    for k in A B H
    do
      [[ -z $bprop[$k] ]] && xprop[$k]=-
      unset "xprop[${k}L]"
    done
    for k in ${(k)bprop}
    do
      xprop[$k]=$bprop[$k]
    done
    for k in A B H
    do
      if [[ -n ${xprop[$k]} ]]; then
        : ${xprop[${k}u]:=${xprop[$k]}} ${xprop[${k}l]:=${xprop[$k]}}
      fi
    done
    : ${xprop[T]:=${xtyp:-def}}
    # storage
    pprop=()
    for k in ${(ok)xprop}
    do
      pprop+=("$k=$xprop[$k]")
    done
    write_cache -a pprop "$ckey" $cache || return $?
  fi
  [[ $__pprop != pprop ]] && set -A $__pprop "${(@)pprop}"
  return 0
}
# ----------------------------------------------------------------------
draw_basemap ()
{
  local err=0
  local _opts=$1; shift || return $?
  local _vset=$1; shift || return $?
  [[ $_opts != OPTS ]] && local -A OPTS=("${(@Pkv)_opts}")
  [[ $_vset != VSET ]] && local -A VSET=("${(@Pkv)_vset}")
  local xvi=$1 yvi=$2; shift 2 || return $?
  local dreg=("$@")

  local J=() R=() B=() O=()

  local psep=$SEP[p]
  local xvk=$xvi$psep yvk=$yvi$psep

  local tmpd=$(mktemp -d)
  local -A Blx=() Bly=()

  get_base_flags $tmpd J R B Blx x $xvk $dreg[1,2] "${(@kv)VSET[(I)$xvk*]}" || return $?
  get_base_flags $tmpd J R B Bly y $yvk $dreg[3,4] "${(@kv)VSET[(I)$yvk*]}" || return $?

  local tex=${${OPTS[exec]}[(wI)tex]}

  local gopts=()
  gopts+=(-JX$J[1]/$J[2])
  gopts+=(-R${(j:/:)R})
  B=("${(@)B:#}")
  #  0 x y
  if [[ $tex -gt 0 ]]; then
    B[2]+=+l"C:X"
    B[3]+=+l"C:Y"
  else
    local bl=
    gen_bname bl "${(@kv)Blx}"; B[2]+=+l"$bl"
    gen_bname bl "${(@kv)Bly}"; B[3]+=+l"$bl"
  fi
  gopts+=("-B${(@)^B}")
  wgmt psbasemap $gopts -P -X3c -Y3c -K >&4
  if [[ $tex -gt 0 ]]; then
    wpfx -u4 - 'C:X' 'x'   'C' "${(@kv)Blx}"
    wpfx -u4 - 'C:Y' 'y'   'C' "${(@kv)Bly}"
  fi
  rm -rf $tmpd

  return 0
}
# ----------------------------------------------------------------------
get_base_flags ()
{
  local tmpd=$1; shift || return $?
  local _J=$1 _R=$2 _B=$3 _Bl=$4; shift 4 || return $?
  [[ $_J  != J  ]] && local J=("${(@P)_J}")
  [[ $_R  != R  ]] && local R=("${(@P)_R}")
  [[ $_B  != B  ]] && local B=("${(@P)_B}")
  [[ $_Bl != Bl ]] && local -A Bl=()

  local ax=$1; shift || return $?
  local vi=$1; shift || return $?
  local dreg=($1 $2); shift 2 || return $?
  local -A VSET=("$@")
  local R0=()
  draw_region J R0 VSET $vi $dreg || return $?
  R+=($R0)

  [[ -z $B ]] && B+=('')
  local bA=
  local -A AP=()
  case $ax in
  (x) AP=(U E  u e  L W  l w);;
  (y) AP=(U N  u n  L S  l s);;
  esac
  local ch=
  for ch in ${(s::)VSET[${vi}Ba]}
  do
    bA+=$AP[$ch]
  done
  B[1]+="$bA"

  local b=$ax
  if [[ -n ${VSET[${vi}L]} ]]; then
    local lprop=()
    symlog_prop lprop "$VSET[$vi]" "$VSET[${vi}u]" "$VSET[${vi}uorg]" "${VSET[${vi}L]}" || return $?
    opr_xunit uopr -a VSET $vi || return $?
    local slx=$this:h/symlogx.py
    [[ ! -x $slx ]] && logmsg -f "$slx cannot be found" && return 1
    logmsg -d "($ax $vi) symlog plot ${VSET[${vi}L]} $R0 $uopr"
    local cmd=($slx ${lprop: :2} "$VSET[${vi}B]" $R0 $uopr[1])
    ## print -u2 - "${(@q-)cmd}"
    local symx=$tmpd/cL_${vi}
    "${(@)cmd}" > $symx; err=$?
    [[ $err -ne 0 ]] && logmsg -e "Failed: $cmd" && return $err
    # cat $symx
    b+=c$symx
  else
    b+=$VSET[${vi}B]
  fi
  B+=("$b")

  extract_bparam 'Bl[lg]' VSET ${vi} l     lg ''
  extract_bparam 'Bl[lt]' VSET ${vi} l  lt lg ''
  extract_bparam 'Bl[ug]' VSET ${vi} u     ug uorg; [[ $Bl[ug] == 1 ]] && Bl[ug]=
  extract_bparam 'Bl[ut]' VSET ${vi} u  ut ug uorg; [[ $Bl[ut] == 1 ]] && Bl[ut]=
  extract_bparam 'Bl[pg]' VSET ${vi} lp     lpg
  extract_bparam 'Bl[pt]' VSET ${vi} lp lpt lpg
  # diag -P +p -c Bl

  [[ $_J  != J  ]] && set -A $_J  "${(@)J}"
  [[ $_R  != R  ]] && set -A $_R  "${(@)R}"
  [[ $_B  != B  ]] && set -A $_B  "${(@)B}"
  [[ $_Bl != Bl ]] && set -A $_Bl "${(@kv)Bl}"
  return 0
}
# ----------------------------------------------------------------------
extract_bparam ()
{
  local __t="$1"; shift || return $?
  local _VSET=$1; shift || return $?
  [[ $_VSET != VSET ]] && local -A VSET=("${(@kv)_VSET}")
  local val= k=
  local kp=$1; shift || return $?
  for k in "$@"
  do
    val="$VSET[$kp$k]"
    [[ -n $val ]] && break
  done
  : ${(P)__t::="$val"}
  return 0
}
# ---------------------------------------------------------------------
gen_bname ()
{
  local __bl=$1; shift || return $?
  [[ $__bl != bl ]] && local bl=
  bl=
  local -A B=("$@")
  bl="$B[lg]"
  [[ -n $B[ug] ]] && bl="$bl ($B[ug])"
  [[ -n $B[pg] ]] && bl="$B[pg]$bl"

  [[ $__bl != bl ]] && : ${(P)__bl::="$bl"}
  return 0
  }

# ----------------------------------------------------------------------
symlog_prop ()
{
  local __lprop=$1; shift || return $?
  [[ $__lprop != lprop ]] && local lprop=()

  # reserved
  local vtgt=$1; shift || return $?
  local utgt=$1 uorg=$2; shift 2 || return $?
  # print -u2 - "$0($utgt)($uorg)"

  lprop=$1
  lprop=(${(s/:/)lprop})
  : ${lprop[1]:=-4}  # linear-scale magnitude
  : ${lprop[2]:=1}   # log/linear ratio

  local f= v= u=
  case $lprop[1] in
  (u*) u=${uorg:-1}
       v=${lprop[1]: 1}
       f=$(units -t -1 -- $utgt $u)
       lprop[1]=$(gmt math -Q $v $f LOG10 ADD =)
       ;;
  (o*) lprop[1]=${lprop[1]: 1};;
  (r*) u=${uorg:-1}
       v=${lprop[1]: 1}
       f=$(units -t -1 -- $v $u)
       lprop[1]=$(gmt math -Q $f LOG10 =)
       ;;
  esac

  local lm=$lprop[1] lw=$lprop[2]
  local lopr=(DUP SIGN EXCH               # s v
              DUP ABS 10 $lm POW DIV      # s v a=v/10**m
              DUP 1  LT  EXCH             # s v a<1 a
              3 2 ROLL                    # s a<1 a v
              LOG10 $lm SUB $lw MUL 1 ADD # s a<1 a (log(v)-m)w+1
              IFELSE MUL                  # s * ifelse
             )
  lprop=($lm $lw $lopr)

  [[ $__lprop != lprop ]] && set -A $__lprop "${(@)lprop}"
  return 0
}

# ----------------------------------------------------------------------
## draw_region [-o] JVAR RVAR VSET key
draw_region ()
{
  local org=
  if [[ x$1 == x-o ]]; then
    org=T
    shift || return $?
  fi
  local _J=$1; shift || return $?
  local _R=$1; shift || return $?
  [[ $_R != R ]] && local R=("${(@P)_R}")
  [[ $_J != J ]] && local J=("${(@P)_J}")
  local _VSET=$1; shift || return $?
  [[ $_VSET != VSET ]] && local -A VSET=("${(@Pkv)_VSET}")
  local vi=$1; shift || return $?
  local r=($1 $2)
  # local r=($=V[${vi}Rd])
  if [[ $r[1] -eq $r[2] ]]; then
    if [[ $r[1] -eq 0 ]]; then
      r=(-1 1)
    else
      r[1]=$(gmt math -Q $r[1] DUP 0 LT 1.1 0.9 IFELSE MUL =)
      r[2]=$(gmt math -Q $r[2] DUP 0 GT 1.1 0.9 IFELSE MUL =)
    fi
  fi
  if [[ -z $org ]]; then
    if [[ -z ${VSET[${vi}opr]} ]]; then
      local uopr=()
      opr_xunit uopr -a VSET $vi || return $?
      r=($(print -l "${(@)r}" | gmt math -Ca STDIN $uopr =))
    fi
  fi
  local j="$VSET[${vi}Js]$VSET[${vi}J]"
  if [[ -n ${VSET[${vi}L]} ]]; then
    :
  elif [[ ${+VSET[${vi}L]} -eq 1 ]]; then
    j+=l
  fi
  J+=("$j")

  R+=($r)
  [[ $_R != R ]] && set -A $_R "${(@)R}"
  [[ $_J != J ]] && set -A $_J "${(@)J}"
  return 0
}
# ----------------------------------------------------------------------
#  opr_xunit uopr -a ARRAY KEY
#  opr_xunit uopr utgt uorg
opr_xunit ()
{
  local _uopr=$1; shift || return $?
  [[ $_uopr != uopr ]] && local uopr=()
  local ut= uo=
  case $1 in
  (-a) shift
       local _VSET=$1 k=$2
       [[ $_VSET != VSET ]] && local -A VSET=("${(@Pkv)_VSET}")
       ut=$VSET[${k}u] uo=$VSET[${k}uorg]
       ;;
  (*)  ut="$1" uo="$2";;
  esac
  if [[ -z $ut ]]; then
    uopr=()
  else
    local err=
    uopr=($(units -t -1 -- $ut ${uo:-1}) DIV); err=$?
    [[ $err -ne 0 ]] && logmsg -e "unit conversion failed $ut $uo ($uopr)" && return $err
  fi
  [[ $_uopr != uopr ]] && set -A $_uopr "${(@)uopr}"
  return 0
}
# ----------------------------------------------------------------------
draw_field ()
{
  local err=0
  local _gset=$1; shift || return $?
  local _vset=$1; shift || return $?
  [[ $_gset != GSET ]] && local -A GSET=("${(@Pkv)_gset}")
  [[ $_vset != VSET ]] && local -A VSET=("${(@Pkv)_vset}")
  local xvi=$1 yvi=$2; shift 2 || return $?
  local dreg=("$@")

  local psep=$SEP[p]
  local xvk=$xvi$psep yvk=$yvi$psep

  local R=() J=()
  draw_region -o J R VSET $xvk $dreg[1,2] || return $?
  draw_region -o J R VSET $yvk $dreg[3,4] || return $?
  local rarg=-R${(j:/:)R}
  local gopts=(-O -K -JX${(j:/:)J} $rarg)
  local prec=$OPTS[pr.V]
  local fsep=$SEP[f]

  local GODR=(${=GSET[+O]})
  local gj= gk=
  local xf= yf= xtyp=
  local xp=() yp=()
  local -A XP=() YP=()
  local tmpf=$(mktemp)
  local pen= sym= fill=
  local ann=
  for gj in $GODR
  do
    gk=${gj}$fsep
    # xf=${GSET[${gk}x]#-} yf=${GSET[${gk}y]#-}
    xtyp=${GSET[${gk}T]}
    # print -u2 - $0 $gk $xtyp
    xf=${GSET[${gk}$xvi]#-} yf=${GSET[${gk}$yvi]#-}
    if   [[ $xtyp == ann ]]; then
      parse_annot xp XP ${=xf} || return $?
      parse_annot yp YP ${=yf} || return $?
      pen=${GSET[${gk}pen]}
      fill=${GSET[${gk}fill]}
      sym=(${=GSET[${gk}sym]})
      [[ -n $pen ]] && pen=-W$pen
      # for ann in ${=GSET[${gk}$xtyp]}
      for ann in ${(s/,/)GSET[${gk}$xtyp]}
      do
        # print -u2 - "$0 $ann ($xp)($yp)"
        case $ann in
        (line)
          if [[ -n $xp ]]; then
            print -l "$xp[2] $R[3]" "$xp[2] $R[4]" | wgmt psxy $gopts $pen >&4; err=$?
          fi
          if [[ -n $yp ]]; then
            print -l "$R[1] $yp[2]" "$R[2] $yp[2]" | wgmt psxy $gopts $pen >&4; err=$?
          fi
          ;;
        (masku)
          if [[ -n $xp ]]; then
            print -l "$xp[2] $R[3]" "$xp[2] $R[4]" "$R[2] $R[4]" "$R[2] $R[3]" |\
              wgmt psxy $gopts -L -G$fill >&4; err=$?
          fi
          if [[ -n $yp ]]; then
            print -l "$R[1] $yp[2]" "$R[2] $yp[2]" "$R[2] $R[4]" "$R[1] $R[4]" |\
              wgmt psxy $gopts -L -G$fill >&4; err=$?
          fi
          ;;
        (bl*)
          if [[ -n $xp ]]; then
            print -l "$xp[2] $R[3] $XP" | wgmt pstext $gopts -N -F+jCT+f14p >&4; err=$?
          fi
          if [[ -n $yp ]]; then
            print -l "$R[1] $yp[2] $YP" | wgmt pstext $gopts -N -F+jMR+f14p >&4; err=$?
          fi
          ;;
        (bu*)
          if [[ -n $xp ]]; then
            print -l "$xp[2] $R[4] $XP" | wgmt pstext $gopts -N -F+jCB+f14p >&4; err=$?
          fi
          if [[ -n $yp ]]; then
            print -l "$R[2] $yp[2] $YP" | wgmt pstext $gopts -N -F+jML+f14p >&4; err=$?
          fi
        esac
      done
    elif [[ -n $xf && -n $yf ]]; then
      pen=${GSET[${gk}pen]}
      [[ -n $pen ]] && pen=-W$pen
      gmt convert -bi1$prec -Af $xf $yf > $tmpf; err=$?
      [[ $err -ne 0 ]] && logmsg -e "Failed in line extraction." && break
      wgmt psxy $gopts $pen $tmpf >&4; err=$?
      [[ $err -ne 0 ]] && logmsg -e "Failed in line plots." && break
      sym=(${=GSET[${gk}sym]})
      if [[ -n $sym ]]; then
        pen=()
        [[ -n $sym[3] ]] && pen=(-G$sym[3])
        ms=("${(@s:,:)sym[2]}")
        mo=${ms[2]:-+0}; ms=${ms[1]:-1}
        if [[ $ms -le 1 ]]; then
          gmt convert    -bi1$prec -Af $xf $yf
        elif [[ x${mo[1]} == x- ]]; then
          gmt convert -I -bi1$prec -Af $xf $yf | gawk -v m=$ms -v o=$mo '(NR-1)%m==o'
        else
          gmt convert    -bi1$prec -Af $xf $yf | gawk -v m=$ms -v o=$mo '(NR-1)%m==o'
        fi  | gmt select $rarg > $tmpf; err=$?
        [[ $err -ne 0 ]] && logmsg -e "Failed in symbol extraction." && break
        wgmt psxy -N $gopts $pen -S$sym[1] $tmpf >&4
        err=$?
        [[ $err -ne 0 ]] && logmsg -e "Failed in symbol plots." && break
      fi
    fi
  done
  rm -f $tmpf
  return $err
}
# ----------------------------------------------------------------------
parse_annot ()
{
  local _pos=$1 _prop=$2; shift 2 || return $?
  local a=$1
  set -A $_pos ${(s/=/)a}
  [[ $# -gt 0 ]] && shift
  [[ $_prop != prop ]] && local -A prop=()
  parse_aa_str prop "$@" || return $?
  [[ $_prop != prop ]] && set -A $_prop "${(@kv)prop}"
  return 0
}
# ----------------------------------------------------------------------
draw_markers ()
{
  local err=0
  local _opts=$1; shift || return $?
  [[ $_opts != OPTS ]] && local -A OPTS=("${(@Pkv)_opts}")

  [[ -z $OPTS[marker] ]] && return 0
  local lx=0 rx=1
  local ly=0 ry=1

  local gopts=(-O -K -J -R0/1/0/1)
  local font=12p
  local pos= mark=
  local off=0.5c

  local tex=${${OPTS[exec]}[(wI)tex]}

  for pos in TL BL TR BR
  do
    mark="M:$pos"
    print "$mark" | wgmt pstext -Dj$off $gopts -N -F+c${pos}+f$font >&4
    if [[ $tex -gt 0 ]]; then
      wpfx -u4 --opts Bl:Bl "$mark" "" 'M'
    fi
  done

  return $err
}
# ----------------------------------------------------------------------
draw_fine ()
{
  local _opts=$1; shift || return $?
  local psf=$1
  print -u4 - "%%% Source: $psf"
  wgmt psxy -J -R -O -T >&4

  return 0
}
# ----------------------------------------------------------------------
set_var_props ()
{
  local err=0
  local __vset=$1; shift || return $?
  [[ $__vset != VSET ]] && local -A VSET=("${(@Pkv)__vset}")
  local vi=$1 vtgt= opr=
  local -A nprop=() oprop=()
  vtgt=$VSET[$vi] opr=$VSET[${vi}o]
  local namep="@%11%Z@-k@-@%%"

  case $opr in
  (f)    oprop=([u]='%'   [uorg]=       [lpg]='Rel.Diff. '  [lpt]='R');;
  (d)    oprop=(                        [lpg]='Diff '       [lpt]='D');;
  esac
  #  (g)     vprop+=(          bl af3g     u kyr/m  u0 yr/m    l "Age derivative"  lt '$\pd{\Age}{z}$');;
  case $vtgt in
  (a)     nprop=([u]=kyr   [uorg]=yr    [lg]='Age'          [lt]='A');;
  (g)     nprop=([u]=kyr/m [uorg]=yr/m  [lg]='Age deriv.'   [lt]='dAdza');;
  (alt)   nprop=([u]=mm    [uorg]=m     [lg]='@~l@~'        [lt]='L');;
  (altm)  nprop=([u]=mm    [uorg]=m     [lg]='@~l@~@-m@-'   [lt]='Lm');;
  (altc)  nprop=([u]=mm    [uorg]=m     [lg]='@~l@~@-c@-'   [lt]='Lc');;

  (acc)   nprop=([u]=cm/yr [uorg]=m/yr  [lg]='Acc.'         [lt]='acc');;
  (btime) nprop=([u]=kyr   [uorg]=yr    [lg]='Time'         [lt]='time');;

  (H)     nprop=([u]=m     [uorg]=m     [lg]='Thickness'    [lt]='H');;
  (bH)    nprop=([u]=m     [uorg]=m     [lg]='Thickness'    [lt]='H');;
  (bHt)   nprop=([u]=kyr   [uorg]=yr    [lg]='Time'         [lt]='time');;

  (d[ns]) nprop=(          [uorg]=m     [lg]='Depth'        [lt]='d')
          nprop+=([Js]=-);;
  (z[ns]) nprop=(          [uorg]=m     [lg]='Elev.'        [lt]='za')
          ;;
  (D[ns]) nprop=(          [uorg]=      [lg]='Normalized depth'  [lt]='D')
          nprop+=([Js]=-);;
  (Z[ns]) nprop=(          [uorg]=      [lg]='@~z@~'        [lt]='zb')
          ;;
  (p[ns]) nprop=(          [uorg]=      [lg]="$namep"       [lt]='zc')
          nprop+=([R]=0:1);;
  (dp[ns]) nprop=(          [uorg]=     [lg]="@~D@~$namep"  [lt]='dzc')
           ;;
  (dZ[ns]) nprop=(          [uorg]=     [lg]="@~D@~@~z@~"   [lt]='dzb')
           ;;
  (*)    logmsg -e "unknown variable $vtgt."; return 1;;
  esac
  for k v in "${(@kv)oprop}" "${(@kv)nprop}" \
                             J 10  R c:c  B afg  Ba uL  I 1
  do
    k=${vi}$k
    [[ ${+VSET[$k]} -eq 0 ]] && VSET[$k]="$v"
  done
  # # range normalization
  # local ra=()
  # parse_range ra "$VSET[${vi}R]" "$VSET[${vi}u]" "$VSET[${vi}uorg]" || return $?
  # VSET[${vi}R]="${(j/:/)ra}"

  [[ $__vset != VSET ]] && set -A $__vset "${(@kv)VSET}"
  return $err
}
# ----------------------------------------------------------------------
get_var_range ()
{
  local err=0
  local __range=$1; shift || return $?
  [[ $__range != range ]] && local range=()
  local F=()
  expand_files F "$@" || return $?
  [[ $#F -eq 0 ]] && logmsg -e "No input files" && return 1
  local rr=()
  # natural range
  rr=($(gmt info -C -bi1$prec $F)); err=$?
  [[ $err -ne 0 ]] && logmsg -e "gmt info failed" && return $err
  range=($rr)
  # positive minimum
  rr=($(gmt convert -bi1$prec $F | gmt math STDIN DUP 0 GT 0 NAN OR = | gmt info -C))
  range+=($rr[1])
  # negative maximum
  rr=($(gmt convert -bi1$prec $F | gmt math STDIN DUP 0 LT 0 NAN OR = | gmt info -C))
  range+=($rr[2])
  [[ $__range != range ]] && set -A $_range "${(@)range}"
  return 0
}
# ----------------------------------------------------------------------
set_draw_ranges ()
{
  local err=0
  local __dreg=$1; shift || return $?
  local __gset=$1; shift || return $?
  [[ $__dreg != dreg ]] && local dreg=()
  [[ $__gset != GSET ]] && local -A GSET=("${(@Pkv)__gset}")
  local xvi=$1 yvi=$2
  local fsep=$SEP[f]
  local xvk=$fsep$xvi yvk=$fsep$yvi
  local xra=(${=GSET[Rlog${xvk}]})
  local yra=(${=GSET[Rlog${yvk}]})

  local rlx=(${=GSET[Rl$xvk]}) rux=(${=GSET[Ru$xvk]})
  local rly=(${=GSET[Rl$yvk]}) ruy=(${=GSET[Ru$yvk]})

  [[ ${(j::)xra} == cc && ${(j::)yra} == cc ]] && xra=(m m) yra=(m m)
  if [[ $xra[(I)[cx]] -gt 0 || $yra[(I)[cx]] -gt 0 ]];then
    local clipx=() clipy=()
    clip_opr clipx $xra $yra
    clip_opr clipy $yra $xra
    local XFA=() YFA=()
    expand_files XFA "${(@v)GSET[(I)[0-9]*$xvk]}" || return $?
    expand_files YFA "${(@v)GSET[(I)[0-9]*$yvk]}" || return $?
    local tmpd=$(mktemp -d) rr=()
    gmt convert -bi1$prec $XFA | gmt math -Ca STDIN $clipx = $tmpd/x
    gmt convert -bi1$prec $YFA | gmt math -Ca STDIN $clipy = $tmpd/y
    rr=($(gmt convert -sa -Af $tmpd/x $tmpd/y | gmt info -C)); err=$?
    if [[ $err -ne 0 ]]; then
      logmsg -e "Failed in conversion"
      diag -P +p -c XFA YFA
      wc -l $tmpd/x $tmpd/y >&2
      return $err
    fi
    rm -rf $tmpd
    rlx+=($rr[1]) rux+=($rr[2])
    rly+=($rr[3]) ruy+=($rr[4])
  else
    rlx+=(-) rux+=(-)
    rly+=(-) ruy+=(-)
  fi
  local xrd=() yrd=()
  adj_draw_range xrd $xra[1] $rlx
  adj_draw_range xrd $xra[2] $rux
  adj_draw_range yrd $yra[1] $rly
  adj_draw_range yrd $yra[2] $ruy

  dreg=($xrd $yrd)
  [[ $__dreg != dreg ]] && set -A $__dreg "${(@)dreg}"
  return 0
}
# ----------------------------------------------------------------------
get_logical_range ()
{
  local __r=$1; shift || return $?
  [[ $__r != r ]] && local r=
  r=$1; shift || return $?
  r=(${(s/:/)r})
  local opr=("$@")
  if [[ -n $opr ]]; then
    local rr=() j=
    for j in $r
    do
      case $j in
      ([mncx]) ;;
      (*) j=$(gmt math -Q $j $opr =) || return $?;;
      esac
      rr+=($j)
    done
    r=($rr)
  fi
  [[ $__r != r ]] && set -A $__r "${(@)r}"
  return 0
}
# ----------------------------------------------------------------------
adj_draw_range ()
{
  local __r=$1; shift || return $?
  [[ $__r != r ]] && local r=("${(@P)__r}")
  local a=$1; shift || return $?
  local m=$1 n=$2 c=$3
  [[ x$c == x- ]] && c=$m
  case $a in
  (m) r+=($m);;
  (n) r+=($n);;
  ([cx]) r+=($c);;
  (*) r+=($a);;
  esac
  [[ $__r != r ]] && set -A $__r "${(@)r}"
  return 0
}
# ----------------------------------------------------------------------
parse_range ()
{
  local __r=$1; shift || return $?
  local val="$1" defu="$2" orgu="$3"
  val=("${(@s/:/)val}")
  [[ -z $val[1] ]] && val[1]=c
  [[ -z $val[2] ]] && val[2]=c
  [[ -n $val[3] ]] && defu=$val[3]
  local jv= v=
  for jv in 1 2
  do
    v="$val[$jv]"
    # print -u2 - "$jv $v $defu $orgu"
    case $v in
    ([mncx]) ;;
    (*) if units -t -1 -- $v 1 > /dev/null; then
          v=$(units -t -1 -- "$v$defu" "$orgu")
        elif units -t -1 -- $v $ou > /dev/null; then
          v=$(units -t -1 -- "$v" "$orgu")
        else
          logmsg -e "unit conversion failed $v ($defu)($orgu)"; return 1
        fi
        ;;
    esac
    val[$jv]="$v"
  done
  set -A $__r "$val[1]" "$val[2]"
  return 0
}
# ----------------------------------------------------------------------
clip_opr ()
{
  local __opr=$1; shift || return $?
  [[ $__opr != opr ]] && local opr=()
  opr=()
  local low=$1 up=$2; shift || return $?
  local VO=($low LT $up GT)
  [[ $1 == x || $2 == x ]] && VO=($low LE $up GE)
  local v= o=
  for v o in $VO
  do
    case $v in
    ([mncx]) ;;
    (*) opr+=(DUP $v $o 1 NAN OR);;
    esac
  done

  [[ $__opr != opr ]] && set -A $__opr "${(@)opr}"
  return 0
}
# ----------------------------------------------------------------------
# member=-[FILE] is skipped
expand_files ()
{
  local __v=$1; shift || return $?
  [[ $__v != v ]] && local v=()
  v=()
  local f=
  for f in "$@"
  do
    v+=(${(s:,:)f}); v=(${v:#-*})
  done
  [[ $__v != v ]] && set -A $__v "${(@)v}"
  return 0
}
# ----------------------------------------------------------------------
draw_legend ()
{
  local err=0
  local _opts=$1; shift || return $?
  local _gset=$1; shift || return $?
  [[ $_opts != OPTS ]] && local -A OPTS=("${(@Pkv)_opts}")
  [[ $_gset != GSET ]] && local -A GSET=("${(@Pkv)_gset}")

  local legpsf=$1; shift || return $?
  local tex=${${OPTS[exec]}[(wI)tex]}

  local fsep=$SEP[f]
  local gk=
  local pdiff=() t= pen= sym=() leg= ltxt=
  local -A dprop=()
  local legb=${legpsf:h}/${legpsf:t:r}_bgr.dat
  local legl=${legpsf:h}/${legpsf:t:r}_line.dat
  local legt=${legpsf:h}/${legpsf:t:r}_text.dat
  local legs=${legpsf:h}/${legpsf:t:r}_symb.dat

  local -A legrepl=()
  parse_leg_repl legrepl GSET || return $?
  # diag -P +p -c legrepl

  local lk=l.
  local font=("${(@s:,:)GSET[${lk}font]}") # size,name,color
  local ygbgn= ygend=
  local jym=$GSET[${lk}jym] jyb=${font[1]%%[^0-9]*}
  local jyu=${font[1]#$jyb}
  local jy=$(printf '%.2f' $((jyb * jym)))
  jy="$jy$jyu"
  local jx=$GSET[${lk}jx]

  rm -f $legb $legl $legt $legs
  touch $legb $legl $legt $legs
  local gj=0.0 ge=0
  local k= v=
  local -A lusr=()
  for v in "${(@s:,:)GSET[l.sp]}"
  do
    separate_str -x "=" k v "$v"
    lusr[$k]="$v"
  done

  local secj=0
  local seck= secf= dflg="$GSET[${psep}ls]"
  local -A SECF=()
  for gk in "${=GSET[l.O]}"
  do
    if [[ ${gk[(i)sec:]} -eq 1 ]]; then
      ltxt=
      secf=("${(@s/:/)gk}")
      separate_str -x ":" seck secf "${gk#sec:}"
      seck=(${(@s:,:)seck})
      parse_section_prop SECF "$dflg" "$secf" || return $?
      conv_leg_str ltxt dprop GSET legrepl "${seck}" || return $?
      # print -u2 - $gk $gj $ygend
      gj=$(($gj + ${ygend:-0} + ${SECF[b]:-0}))
      if [[ ${SECF[l]:-f} != f ]]; then
        if [[ $tex -gt 0 ]]; then
          leg=G:$secj
          print - "${SECF[x]:-0} $gj ${SECF[xj]:-MC} $leg" >> $legt
          wpfx --opts "$SECF[xp]" --pfx "#P" "$leg" "$ltxt" \
               'G' "${(@kv)dprop}" >> $legt
        else
          print - "${SECF[x]:-0} $gj ${SECF[xj]:-MC} $ltxt" >> $legt
        fi
        seck=(${(M)seck#*=})
        gj=$(($gj + ${SECF[ly]:-1}))
      else
        seck=()
      fi
      let secj++
      ygend=${SECF[e]}
      continue
    fi
    gk=$gk$fsep
    ltxt=
    conv_leg_str ltxt dprop GSET legrepl ${GSET[${gk}u]} ${seck} || return $?
    pen=$GSET[${gk}pen]
    sym=(${=GSET[${gk}sym]}); : ${sym[3]:=$pen}
    # line
    print -l - "> -W$jy,white" "-2 $gj" "0 $gj" >> $legb
    print -l - "> -W$pen" "-2 $gj" "0 $gj" >> $legl
    # symbol
    if [[ -n $sym[1] ]]; then
      print -l - ">-W -S$sym[1] -G$sym[3]" "-1 $gj" >> $legs
    fi
    # text
    if [[ $tex -gt 0 ]]; then
      leg=L:$ge
      print - "0.1 $gj ML $leg" >> $legt
      wpfx --opts Bl:Bl --pfx "#P" "$leg" "$ltxt" \
           'L' "${(@kv)lusr}" "${(@kv)dprop}" j $ge >> $legt
    else
      # print -u2 - "$0 ltxt:$gj $ltxt"
      print - "0.1 $gj ML $ltxt" >> $legt
    fi
    gj=$(($gj+1.0))
    let ge++
  done
  local reg=($(gmt info -C -I1 $legb $legl $legs $legt))
  [[ $reg[3] -eq $reg[4] ]] && reg[4]=$(($reg[3]+1))
  reg=-R${(j:/:)reg}

  exec 4> $legpsf
  wgmt psbasemap -P -K -Jx$jx/-$jy -B+n ${reg} >&4
  wgmt psxy -J -R -O -K $legb $legl >&4
  wgmt psxy -N -J -R -O -K -Sc0.1c $legs >&4
  wgmt pstext -J -R -O -K $legt -N -F+j+f${(j:,:)font} >&4
  draw_fine OPTS $legpsf || return $?
  exec 4>&-
  sed -n -e '/^#P/s///p' $legt >> $legpsf

  return 0
}
# ----------------------------------------------------------------------
parse_section_prop ()
{
  local _secf=$1; shift || return
  [[ $_secf != SECF ]] && local -A SECF=()
  SECF=([l]=t [ly]=1 [x]=c [b]=0.3 [e]=0 [f]=14p)
  local g= k= v= p=()
  local psep=$SEP[p] rsep=$SEP[r] fsep=$SEP[f]
  for g in "$@"
  do
    while [[ -n $g ]]
    do
      g=${g#$psep}
      separate_str "$psep" k g "$g"
      separate_str -x "$rsep" k v "$k"
      SECF[$k]="$v"
    done
  done
  # [l][ly]
  v=("${(@ps/$fsep/)SECF[l]}")
  SECF[l]=${v[1]:-t}
  [[ -n $v[2] ]] && SECF[ly]=$v[2]
  # [x][xp][xj]
  p=("${(@ps/$fsep/)SECF[xp]}")
  v=("${(@ps/$fsep/)SECF[x]}" '' '')
  case ${v[1]:-c} in
  (c) SECF[x]=0;;   # line right
  (s) SECF[x]=-1;;  # line center
  (l) SECF[x]=-2;;  # line left
  (*) SECF[x]="$v[1]";;
  esac
  shift v
  SECF[xj]=$v[1]
  if [[ -z $SECF[xj] ]]; then
    case $SECF[x] in
    (-2) SECF[xj]=ML;;
    (*)  SECF[xj]=MC;;
    esac
  fi
  shift v
  # diag -P +p -c v p
  [[ -z $p[1] ]] && p[1]=${v[1]:-b}
  [[ -z $p[2] ]] && p[2]=${v[2]:-B}
  [[ -z $p[3] && -n $v[3] ]] && p[3]=${v[3]}
  [[ -z $p[4] && -n $v[4] ]] && p[4]=${v[4]}
  SECF[xp]="${(pj/$fsep/)p}"
  # diag -P +p -c SECF
  [[ $_secf != SECF ]] && set -A $_secf "${(@kv)SECF}"
  return 0
}
# ----------------------------------------------------------------------
parse_leg_repl ()
{
  local _lr=$1; shift || return
  local _gset=$1; shift || return
  [[ $_lr != lr ]] && local -A lr=()
  [[ $_gset != GSET ]] && local -A GSET=("${(@Pkv)_gset}")
  local psep=$SEP[p] fsep=$SEP[f]

  local t= p= k= v= s= S=() L=() l= K=()
  for t in $GSET[(I)*${psep}l]
  do
    L=(${=GSET[${t}]})
    t=${t%${psep}l}
    K=(${=GSET[$t$psep]})
    if [[ -z $L ]]; then
      lr[$t:]=""
    elif [[ x$L == x- ]]; then
      lr[$t:]=-
    else
      for l k in ${L:^K}
      do
        lr[$t:$k]="$l"
      done
    fi
  done
  for p in $GSET[(I)*$fsep*${psep}l]
  do
    t=${p%%$psep*}
    lr[$t]="$GSET[$p]"
  done

  [[ $_lr != lr ]] && set -A $_lr "${(@kv)lr}"
  return 0
}
# ----------------------------------------------------------------------
conv_leg_str ()
{
  local _ltxt=$1; shift || return
  local _dprop=$1; shift || return
  local _gset=$1; shift || return
  local _lr=$1; shift || return
  # local gk=$1
  [[ $_ltxt != ltxt ]] && local ltxt=
  [[ $_dprop != dprop ]] && set -A dprop=()
  [[ $_gset != GSET ]] && local -A GSET=("${(@Pkv)_gset}")
  [[ $_lr != lr ]] && local -A lr=("${(@Pkv)_lr}")
  # print -u2 - "$0 $gk"
  # diag -P +p -c GSET
  local -A lprop=()

  # parse_aa_str dprop ${=GSET[${gk}u]} || return $?
  # local t=$GSET[${gk}t]
  # [[ x${t:--} != x- ]] && dprop[t]=$t
  parse_aa_str dprop "$@" || return $?
  # diag -P +p -c dprop
  local k= v=
  local psep=$SEP[p] fsep=$SEP[f]
  local vk=
  local p=
  local defu= utgt= usfx=

  # remove properties
  #    P+lx         remove P
  #    K:V+lx=P,..  remove P if K==V
  for k in ${GSET[(I)*${psep}lx]}
  do
    v=(${(s:,:)GSET[$k]})
    k=${k%%$psep*}
    k=(${(@ps/$fsep/)k})
    p=$k[1]; k=$k[2]
    if [[ -z $k ]]; then
      unset "dprop[$p]"
    elif [[ $dprop[$p] == $k ]]; then
      while [[ -n $v ]]
      do
        unset "dprop[$v[1]]"
        shift v
      done
    fi
  done

  for p defu in A '' B '' H '' t yr
  do
    vk="$p${psep}lu"
    if [[ -n $GSET[$vk] ]]; then
      for k in ${dprop[(I)$p*]}
      do
        usfx=("${(@s/:/)GSET[$vk]}")
        utgt=$usfx[1]; shift usfx
        [[ ${+usfx[1]} -eq 0 ]] && usfx=$utgt
        # print -u2 - units -t -1 -- $dprop[$k] "$utgt"
        # print -u2 - "$dprop[$k] $defu $utgt"
        if v=$(units -t -1 -- $dprop[$k]$defu "$utgt"); then
          dprop[$k]="$v$usfx"
        else
          :
        fi
      done
    fi
  done
  local ll=() ladd=() rk=
  # GSET[l]=abcde-xyz  include abcde exclude xyz
  local lexc=("${(@s/-/)GSET[l]}")
  local linc="$lexc[1]"; lexc="$lexc[2]"
  local li= lx=
  for k in ${(nk)dprop}
  do
    rk="$k:${dprop[$k]}"
    if [[ ${+lr[$rk]} -eq 1 ]]; then
      dprop[$k]="$lr[$rk]"
      ltxt="$lr[$rk]"
    elif [[ x${lr[${k}:]} == x- ]]; then
      ltxt="$dprop[$k]"
    elif [[ ${+lr[${k}:]} -eq 1 ]]; then
      ltxt=""
    else
      ltxt="$k=$dprop[$k]"
    fi
    # print -u2 - "$k $rk (${+lr[$rk]})(${lr[${k}:]})(${+lr[${k}:]})[$ltxt]"
    li=$linc[(I)$k]
    lx=$lexc[(I)$k]
    if [[ $li -gt 0 ]]; then
      ll[$li]="$ltxt"
    elif [[ $lx -eq 0 ]]; then
      ladd+=("$ltxt")
    fi
    # print -u2 - "$k : $li/$linc : $lx/$lexc $ltxt - ${(@q-)ll}"
  done
  ll=($ll $ladd)
  # diag -P +p -c ll
  ltxt="$ll"
  [[ $_ltxt != ltxt ]] && : ${(P)_ltxt::="$ltxt"}
  [[ $_dprop != dprop ]] && set -A $_dprop "${(@kv)dprop}"
  return 0
}
# ----------------------------------------------------------------------
parse_vall ()
{
  local err=0
  local _opts=$1; shift || return $?
  local __gset=$1; shift || return $?
  local __vset=$1; shift || return $?
  local __xset=$1; shift || return $?

  [[ $_opts  != OPTS ]] && local -A OPTS=("${(@Pkv)_opts}")
  [[ $__gset != GSET ]] && local -A GSET=("${(@Pkv)__gset}")
  [[ $__vset != VSET ]] && local -A VSET=("${(@Pkv)__vset}")
  [[ $__xset != XSET ]] && local -A XSET=("${(@Pkv)__xset}")

  local psep=$SEP[p]
  local vtgt=
  local npfx='' rpfx=r
  local -A vprop=()
  local vi= VI=(${(on)${VSET[(I)*$psep]}})
  local ra=()
  for vi in "${(@)VI}"
  do
    set_var_props VSET ${vi} || return $?
    parse_range ra "$VSET[${vi}R]" "$VSET[${vi}u]" "$VSET[${vi}uorg]" || return $?
    VSET[${vi}R]="${(j/:/)ra}"
  done

  expand_entries OPTS XSET $npfx || return $?
  for vi in "${(@)VI}"
  do
    xfiles=()
    vtgt=$VSET[$vi]
    parse_xall xfiles $vtgt OPTS XSET $npfx || return $?
    VSET[${vi}f]="$xfiles"
  done
  # expand_gsets OPTS GSET XSET $npfx || return $?
  # operations
  local rspec=
  parse_refspec rspec VSET || return $?
  for vi in "${(@)VI}"
  do
    vtgt=$VSET[$vi]
    xfiles=(${=VSET[${vi}f]})
    opr=$VSET[${vi}o]
    case $opr in
    ([fdr]) expand_props XSET $rpfx "$rspec" r || return $?
            expand_entries OPTS XSET $rpfx || return $?
            parse_xall rfiles $vtgt OPTS XSET $rpfx || return $?
            opr_files xfiles OPTS XSET $opr $vtgt "$npfx" "$rpfx" ${xfiles:^rfiles} || return $?
            ;;
    ('')    ;;
    (*)     logmsg -e "unknown operation $opr"; return 1;;
    esac
    VSET[${vi}f]="$xfiles"
  done
  # transform
  for vi in "${(@)VI}"
  do
    transform_files xfiles vprop OPTS XSET "$npfx" "$vi" "${(@kv)VSET[(I)$vi*]}" || return $?
    VSET[${vi}f]="$xfiles"
    VSET+=("${(@kv)vprop}")
  done
  # logical range
  for vi in "${(@)VI}"
  do
    get_logical_range ra "${VSET[${vi}R]}" ${=VSET[${vi}opr]} || return $?
    VSET[${vi}Rlog]="${(j/:/)ra}"
  done
  # common/difference
  # parse_common_diff GSET XSET "$npfx" "$rpfx" || return $?
  # annotation special
  for vi in "${(@)VI}"
  do
    [[ -z ${VSET[${vi}a]} ]] && continue
    expand_annotation GSET XSET VSET "$vi" || return $?
  done

  expand_gsets OPTS GSET XSET $npfx || return $?
  parse_common_diff GSET XSET "$npfx" "$rpfx" || return $?
  assign_gsets GSET XSET VSET "$npfx" || return $?
  # diag -P +p -c GSET

  [[ $__gset != GSET ]] && set -A $__gset "${(@kv)GSET}"
  [[ $__vset != VSET ]] && set -A $__vset "${(@kv)VSET}"
  [[ $__xset != XSET ]] && set -A $__xset "${(@kv)XSET}"
  return $err
}
# ----------------------------------------------------------------------
parse_refspec ()
{
  local __rspec=$1; shift || return $?
  local __vset=$1; shift || return $?

  [[ $__rspec != rspec ]] && local rspec=
  [[ $__vset != VSET ]] && local -A VSET=("${(@Pkv)__vset}")

  local psep=$SEP[p]
  local rk=(${VSET[(I)*${psep}r]})
  if [[ $#rk -eq 0 ]]; then
    rspec=
  elif [[ $#rk -gt 1 ]]; then
    logmsg -e "Multiple refspec {$rk}"; return 1
  else
    rspec=${VSET[$rk]:-:}
  fi
  [[ $__rspec != rspec ]] && : ${(P)__rspec::=$rspec}
  return 0
}
# ----------------------------------------------------------------------
expand_entries ()
{
  # print -u2 - "$0 ${(q-)@}"
  local err=0
  local _opts=$1; shift || return $?
  local __xset=$1; shift || return $?
  local xpfx=$1

  [[ $_opts  != OPTS ]] && local -A OPTS=("${(@Pkv)_opts}")
  [[ $__xset != XSET ]] && local -A XSET=("${(@Pkv)__xset}")

  local fsep=$SEP[f]
  local xj= xtag= XJ=(${(n)${XSET[(I)${xpfx}[0-9]*${fsep}]}})
  local sxj= SXJ=()
  for xj in "${(@)XJ}"
  do
    xtag="${XSET[$xj]}"
    case $xtag in
    (SOL)  SXJ+=($xj); XSET[${xj}T]=hlp;;  # automatic solution
    (LEV)  logmsg -f "Discarded feature"; exit 1;;
    # (LEV)  SXJ+=($xj); XSET[${xj}T]=hlp;;  # automatic exact level
    (sol)  ;; # skip at this stage
    (lev)  ;; # skip at this stage
    (*)    expand_xentry OPTS XSET "$xj" || return $?
           xtag="${XSET[$xj]}"
           cache_yseq OPTS $xtag || return $?
           filter_yseq OPTS XSET $xj || return $?
           cache_bpos OPTS $xtag || return $?
           filter_bpos OPTS XSET $xj || return $?
           ;;
    esac
  done
  # auto solution expansion
  for sxj in $SXJ
  do
    expand_sol_auto XSET $sxj "$xpfx" || return $?
  done
  # solution expansion
  ## do again
  XJ=(${(n)${XSET[(I)${xpfx}[0-9]*${fsep}]}})
  for xj in "${(@)XJ}"
  do
    xtag="${XSET[$xj]}"
    case $xtag in
    (sol|lev)  expand_sentry OPTS XSET "$xj" || return $?;;
    esac
  done

  [[ $__xset != XSET ]] && set -A $__xset "${(@kv)XSET}"
  return $err
}
# ----------------------------------------------------------------------
expand_xentry ()
{
  local err=0
  local _opts=$1; shift || return $?
  local __xset=$1; shift || return $?
  [[ $_opts  != OPTS ]] && local -A OPTS=("${(@Pkv)_opts}")
  [[ $__xset != XSET ]] && local -A XSET=("${(@Pkv)__xset}")
  local xj=$1

  local -A xprop=()
  local xdir=$XSET[$xj]
  local reftag=R

  # generate name by replacement
  if [[ -z $xdir ]]; then
    local rdir=$XSET[${xj}$reftag]
    [[ -n $XSET[$rdir] ]] && rdir=$XSET[$rdir]
    [[ -z $rdir   ]] && logmsg -e "${xj} neither reference or target directory is set" && return 1
    [[ ! -d $rdir ]] && logmsg -e "${xj} reference not exist $rdir" && return 1
    cache_xprop xprop OPTS $rdir || return $?
    xdir_replace xdir XSET $xj "${(@kv)xprop}" || return $?
    XSET[${xj}]="$xdir"
  fi
  [[ -z $xdir   ]] && logmsg -e "${xj} null target directory" && return 1
  local xh= xd=
  for xh in $=OPTS[dir]
  do
    for xd in ${=xdir}
    do
      [[ -d $xh/$xd   ]] && xdir=$xh/$xd   && break 2
      [[ -d $xh/$xd:t ]] && xdir=$xh/$xd:t && break 2
    done
  done
  [[ ! -d $xdir ]] && logmsg -e "${xj} target $XSET[$xj] not exist in {$OPTS[dir]}" && return 1
  # print -u2 - $xdir
  # ls -d $xdir

  XSET[${xj}]="$(realpath -s --relative-to=. $xdir)" || return $?

  # not inherit prop:p
  inherit_args XSET $xj "$reftag"  p || return $?

  cache_xprop xprop OPTS $xdir || return $?
  # overwrite by cmdline
  local pstr=${XSET[${xj}p]}
  parse_aa_str +xprop ${=pstr}
  # diag -P +p -c xprop
  # normalization
  local k= v=
  for k in A Au Al B Bu Bl
  do
    [[ -z $xprop[$k] ]] && continue
    v=$xprop[$k]
    if v=$(units -t -1 -- $v m 2> /dev/null); then
      if [[ $v == 0 ]]; then
        logmsg -w "$k=$xprop[$k] replaced in XSET[${xj}p]."
        xprop[$k]=0
      fi
    fi
  done
  unparse_aa_str pstr "${(@kv)xprop}" k def
  XSET[${xj}p]="$pstr"

  [[ $__xset != XSET ]] && set -A $__xset "${(@kv)XSET}"
  return $err
}
# ----------------------------------------------------------------------
#  cache_xprop OPTS bprop directory
cache_xprop ()
{
  local __xprop=$1; shift || return $?
  [[ $__xprop != xprop ]] && local -A xprop=("${(@Pkv)__xprop}")

  local _opts=$1; shift || return $?
  [[ $_opts  != OPTS  ]] && local -A OPTS=("${(@Pkv)_opts}")

  local xdir=$1; shift || return $?
  [[ ! -e $xdir ]] && print -u2 "Not exists $xdir" && return 1

  local cache=$OPTS[asc]/$xdir/$OPTS[c.prop]

  read_cache -A xprop prop $cache || return $?
  if [[ -n $xprop ]]; then
    logmsg -d "Skip to generate $cache"
  else
    logmsg -d "Generate $cache"
    xprop[D]=$(realpath -s --relative-to=. $xdir:h)
    local xbase=$xdir:t
    xprop[S]=$xbase:e; xbase=$xbase:r
    xprop[P]=$xbase:r; xbase=$xbase:e
    local k= v=
    for k in ${(s:_:)xbase}
    do
      v=${k: 1}
      k=${k[1]}
      case $k in
      ([WHABZC]) xprop[$k]=$v;;
      (*) logmsg -e  "Unknown property id $k"; return 1;;
      esac
    done
    local bcp= j=
    for k in A B H
    do
      v=$xprop[$k]
      [[ -z $v ]] && continue
      bcp=()
      if [[ $v == 0 ]]; then
        bcp[1]=$v
      elif [[ $v[1] =~ [a-zA-Z] ]]; then
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
      if [[ $#bcp -eq 1 ]]; then
        xprop[${k}]="$bcp[1]"
      elif [[ $#bcp -eq $#ABHsub ]]; then
        for j in {1..$#bcp}
        do
          xprop[${k}$ABHsub[$j]]="$bcp[$j]"
        done
        unset "xprop[$k]"
        xprop[${k}L]="${(j:,:)bcp}"
      else
        logmsg -f  "Not implemented ${(*)bcp} = $#bcp"
        return 1
      fi
    done
    mkdir -p $cache:h || exit $?
    write_cache -A xprop prop $cache || return $?
  fi
  [[ $__xprop != xprop ]] && set -A $__xprop "${(@kv)xprop}"
  return 0
}
# ----------------------------------------------------------------------
#  cache_xprop OPTS bprop directory
xdir_replace ()
{
  local __xdir=$1; shift || return $?
  local _xset=$1; shift || return $?
  [[ $_xset  != XSET  ]] && local -A XSET=("${(@Pkv)_xset}")
  local xj=$1; shift || return $?
  local -A bprop=("$@")

  local k= kk=
  for k in D W P C S Z
  do
    kk=$xj$k
    [[ -n ${XSET[$kk]} ]] && bprop[$k]=${XSET[$kk]}
  done
  local ik=
  for k in A B H
  do
    kk=$xj$k
    if [[ -n $bprop[$k] ]]; then
      for ik in $XSET[(I)$kk*]
      do
        if [[ $ik == $kk ]]; then
          bprop[$k]=$XSET[$ik]
        else
          logmsg -w  "Ignore replacement $ik=$XSET[$ik]"
        fi
      done
    else
      if [[ -n $XSET[$kk] ]]; then
        logmsg -w  "Single replacement for $k"
        bprop[$k]=$XSET[$kk]
      else
        for ik in $XSET[(I)$kk*]
        do
          bprop[${ik#$xj}]="$XSET[$ik]"
        done
      fi
    fi
  done
  [[ $__xdir != xdir ]] && local xdir=()
  local tprop=()
  local buf=() j= jj=
  for k v in "${(@kv)bprop}"
  do
    v=("${(@s/:/)v}")
    buf=()
    for j in {1..$#v}
    do
      if [[ -z $tprop ]]; then
        buf+=("$k=$v[$j]")
      else
        for jj in "${(@)tprop}"
        do
          buf+=("$jj $k=$v[$j]")
        done
      fi
    done
    tprop=("${(@)buf}")
  done
  # diag -P +p -c tprop
  # diag -P +p -c bprop
  local -A tb=()
  local xd=
  xdir=()
  for jj in "${(@)tprop}"
  do
    parse_aa_str tb "${jj}"
    unparse_xprop xd "${(@kv)tb}"
    xdir+=($xd)
  done
  # unparse_xprop xdir "${(@kv)bprop}"
  # [[ $__xdir != xdir ]] && : ${(P)__xdir::=$xdir}
  [[ $__xdir != xdir ]] && set -A $__xdir "${(@)xdir}"
  return 0
}
# ----------------------------------------------------------------------
unparse_xprop ()
{
  local __dir=$1; shift || return $?
  [[ $__dir != dir ]] && local dir=
  local -A prop=("$@")
  local k= v=
  local j= s=
  for k in A B H
  do
    if [[ x${prop[$k]:--} == x- ]]; then
      v=()
      for j in {1..$#ABHsub}
      do
        s=$ABHsub[$j]
        [[ -n $prop[$k$s] ]] && v[$j]=$prop[$k$s]
      done
      prop[$k]=${(j/,/)v}
    fi
  done
  dir=()
  for k in W H A B Z C
  do
    v=(${(s/,/)prop[$k]}); v=${(j::)v}
    [[ x${prop[$k]:--} == x- ]] || dir=(${dir} $k$v)
  done
  dir=${(j:_:)dir}
  [[ x${prop[P]:--} == x- ]] || dir=$prop[P].$dir
  [[ x${prop[S]:--} == x- ]] || dir=$dir.$prop[S]
  [[ x${prop[D]:--} == x- ]] || dir=$prop[D]/$dir

  [[ $__dir == dir ]] || : ${(P)__dir::=$dir}
  return 0
}
# ----------------------------------------------------------------------
expand_props ()
{
  local err=0
  local __xset=$1; shift || return $?
  local xpfx=$1 rspec=$2 isfx=$3

  [[ $__xset != XSET ]] && local -A XSET=("${(@Pkv)__xset}")

  local fsep=$SEP[f] rsep=$SEP[r] psep=$SEP[p]
  local xj= xtag= pxj= k= v= rk=
  local sdef=SOL$fsep
  for xj in ${(n)${XSET[(I)[0-9]*${fsep}]}}
  do
    pxj="$xpfx$xj"
    [[ ${+XSET[${pxj}R]} -eq 0 ]] && XSET[${pxj}R]=$xj
    rk=${xj%$fsep}${psep}$isfx
    [[ ${+XSET[$rk]} -eq 1 ]] && xtag="${XSET[$rk]}" || xtag="$rspec"
    # print -u2 - "$0($xpfx) $xj $rk $xtag"
    XSET[$pxj]=''
    case $xtag in
    ($fsep)   logmsg -e "No reference experiment for $xj"; return 1;;
    (sol*)    XSET[${pxj}R]="$sdef $XSET[${pxj}R]"
              # print -u2 - "$pxj '$fsep' '$rsep' '${fsep}$rsep$xtag'"
              add_props XSET $pxj "$fsep" "$rsep" "${fsep}$rsep$xtag" || return $?;;
    ([a-zA-Z]*$rsep*)
              add_props XSET $pxj "$fsep" "$rsep" "$fsep$xtag" || return $?
              ;;
    ([0-9]*)  XSET[$pxj]="$XSET[${xtag}$fsep]";;
    (*)       XSET[$pxj]="$xtag";;
    esac
  done
  [[ $__xset != XSET ]] && set -A $__xset "${(@kv)XSET}"
  return $err
}
# ----------------------------------------------------------------------
parse_xall ()
{
  local err=0
  local __xfiles=$1; shift || return $?
  local vtgt=$1; shift || return $?
  local _opts=$1; shift || return $?
  local __xset=$1; shift || return $?
  local xpfx=$1

  [[ $__xfiles != xfiles ]] && local xfiles=()
  [[ $_opts  != OPTS ]] && local -A OPTS=("${(@Pkv)_opts}")
  [[ $__xset != XSET ]] && local -A XSET=("${(@Pkv)__xset}")

  local VarsYseq=(a dadp g ginv zn dn alt altm altc)
  local VarsBpos=($VarsYseq acc)

  local fsep=$SEP[f]
  local xj= xtag=
  local prec=$OPTS[pr.V]
  local bpos= yseq= xf= xjf=() y=
  local xtyp=
  local XJ=(${(n)${XSET[(I)${xpfx}[0-9]*${fsep}]}})
  [[ -n $OPTS[prog] ]] && local pstart=$(vramsteg --now) pj=0
  for xj in "${(@)XJ}"
  do
    [[ -n $pstart ]] && let pj++ && \
      vramsteg --min 1 --max $#XJ --current $pj --start=$pstart --elapsed --estimate --label "$0"
    xtag="${XSET[$xj]}"
    xtyp=$XSET[${xj}T]
    [[ $xtyp == hlp ]] && logmsg -d "Skip $xtag($xtyp)" && continue
    ## print -u2 - "$0 $xj $xtag"
    yseq=(${=XSET[${xj}t]}) bpos=(${=XSET[${xj}b]})
    xjf=()
    case $xtyp in
    (sol) for y in ${yseq:--}
          do
            extract_solution xf $vtgt $OPTS[asc] $xtag $y ${bpos} || return $?
            xjf+=($xf)
          done
          ;;
    (lev)
      xjf+=(-)
      ;;
    (*)   for y in ${yseq:--}
          do
            extract_field xf $vtgt $OPTS[asc] $xtag $y ${bpos} || return $?
            if [[ x$xf == x- && x$y == x- ]]; then
              logmsg -n "No targets $vtgt $xtag"
            fi
            xjf+=($xf)
          done
    esac
    xfiles+=(${(j:,:)xjf})
    # print - "$0 $xj $xtag $vtgt {$bpos} {$yseq}"
  done
  [[ -n $pstart ]] && vramsteg --remove
  [[ $__xfiles != xfiles ]] && set -A $__xfiles "${(@)xfiles}"
  [[ $__xset   != XSET   ]] && set -A $__xset   "${(@kv)XSET}"
  return $err
}
# ----------------------------------------------------------------------
extract_solution ()
{
  local __xf=$1; shift || return $?
  local vtgt=$1; shift || return $?
  local ascd=$1 xdir=$2; shift 2 || return $?
  local yid=$1; shift
  local bpos=("$1" "$2"); shift 2 || return $?
  local -A bprop=()
  parse_aa_str bprop "$@" || return $?
  local prec=$OPTS[pr.V]

  local tid=("${(@s:,:)yid}")
  local tyr=$tid[1]; shift tid
  # print -u2 - $yid $tid $tyr
  local null=
  local defu=m flg=

  if [[ x$__xf == x- ]]; then
    xf=-
  else
    local amask=()
    local k= v=
    [[ $__xf != xf ]] && local xf=
    xf=$ascd/$xdir
    [[ $VarsBpos[(Ie)$vtgt] -gt 0 && -n $bpos ]] && xf=$xf/b${(j:_:)bpos}
    xf=$xf/$vtgt
    if [[ x${tyr:--} != x- ]]; then
      amask=($tyr MIN)
      xf=${xf}_y$tyr
    fi
    mkdir -p $xf:h || exit $?
    local refH=
    unit_orig refH "$bprop[H]" $defu + || return $?
    local srcf=$xdir/$OPTS[f.agesol] flg=-
    [[ $bprop[z] == s ]] && srcf=$xdir/$OPTS[f.sample] flg=
    case $vtgt in
    (a)     [[ ! $xf -nt $srcf ]] && gmt math -bo1$prec -o1 $srcf -C1 $refH MUL $amask = $xf;;
    (g)     [[ ! $xf -nt $srcf ]] && gmt math -bo1$prec -o2 $srcf -C2           = $xf;;
    (alt)   [[ ! $xf -nt $srcf ]] && gmt math -bo1$prec -o2 $srcf -C2 INV   NEG = $xf;;
    # to do: to adjust
    (altm)  [[ ! $xf -nt $srcf ]] && gmt math -bo1$prec -o2 $srcf -C2 INV   NEG = $xf;;
    (altc)  [[ ! $xf -nt $srcf ]] && gmt math -bo1$prec -o2 $srcf -C2 INV   NEG = $xf;;
    #
    (d[ns]) [[ ! $xf -nt $srcf ]] && gmt math -bo1$prec -o0 $srcf -C0 $refH MUL = $xf;;
    (z[ns]) [[ ! $xf -nt $srcf ]] && gmt math -bo1$prec -o0 $srcf -C0 1 SUB NEG $refH MUL = $xf;;
    esac
    # print -u2 - $xf $refH
  fi
  [[ -n $flg ]] && xf=$flg$xf
  [[ $__xf != xf && x$__xf != x- ]] && : ${(P)__xf::=$xf}
  return $err
}
# ----------------------------------------------------------------------
extract_field ()
{
  local __xf=$1; shift || return $?
  local vtgt=$1; shift || return $?
  local ascd=$1 xdir=$2; shift 2 || return $?
  local yid=$1; shift

  local bpos=("$1" "$2") altc=()
  if [[ $# -gt 2 ]]; then
    shift 2
    local -A bprop=()
    parse_aa_str bprop "$@" || return $?
    extract_altclip altc $OPTS[asc]/$xdir/$OPTS[c.prop] "${(@kv)bprop}" || return $?
  fi

  local tid=("${(@s:,:)yid}")
  local tyr=$tid[1]; shift tid
  local null=

  if [[ x$__xf == x- ]]; then
    xf=-
  else
    [[ $__xf != xf ]] && local xf=
    xf=$ascd/$xdir
    if [[ $VarsBpos[(Ie)$vtgt] -gt 0 ]]; then
      if [[ -z $bpos ]]; then
        logmsg -e "Need valid bpos filter for $xdir/$vtgt"
        local -A bchoice=()
        local cache=$OPTS[asc]/$xdir/$OPTS[c.prop]
        read_cache -K bchoice bchoice $cache
        diag -P bchoice
        return 1
      fi
      xf=$xf/b${(j:_:)bpos}
    fi
    xf=$xf/$vtgt
    if [[ $VarsYseq[(Ie)$vtgt] -gt 0 ]]; then
      if [[ -n $tid ]]; then
        xf=${xf}_t$tid
      elif [[ -n $tyr ]]; then
        # no corresponding tidx
        null=T xf=-
      fi
    fi
  fi
  if [[ -n $null ]]; then
    # print -u2 - "$vtgt $xdir $null ($tid/$tyr) ($bpos)"
    logmsg -e "Need valid time filter for $xdir/$vtgt."
    local ytable=$OPTS[asc]/$xdir/$OPTS[c.tidx] yseq=()
    extract_yseq yseq $prec $ytable show || return $?
    return 1
  else
    local copts=($ascd $xdir $yid "${(@)bpos}")
    case $vtgt in
    #---------------------------------------- netcdf direct (3d)
    (a)    extract_nc $xf $xdir/vmta.nc age.Ta  "${(@)bpos}" $tid || return $?;;
    (dadp)
      local gv=dadp
      ## WHY?? grep --silent not work as expected....
      # ncdump -h $xdir/vmta.nc | grep 'double dad3' || echo 'a OR'
      # ncdump -h $xdir/vmta.nc | grep 'double dad3' && echo 'a AND'
      # ncdump -h $xdir/vmta.nc | grep 'double dad3' >& /dev/null || echo 'b OR'
      # ncdump -h $xdir/vmta.nc | grep 'double dad3' >& /dev/null && echo 'b AND'
      # ncdump -h $xdir/vmta.nc | grep --silent 'double dad3' || echo NOT
      # ncdump -h $xdir/vmta.nc | grep --silent 'double dad3' || echo NOT
      # ncdump -h $xdir/vmta.nc | grep --silent 'double dad3' && echo FOUND && gv=dad3
      ncdump -h $xdir/vmta.nc | grep 'double dad3' >& /dev/null && gv=dad3
      extract_nc $xf $xdir/vmta.nc $gv.Ta "${(@)bpos}" $tid || return $?;;
    #---------------------------------------- netcdf direct (2d)
    (acc)   extract_nc $xf $xdir/vmhb.nc Ms.Ha   "${(@)bpos}" -    || return $?;;
    (btime) extract_nc $xf $xdir/vmhb.nc time    "${(@)bpos}" -    || return $?;;
    #----------------------------------------
    (H)    extract_nc $xf $xdir/vmhi.nc oH.Ha   "${(@)bpos}" $tid || return $?;;
    (bH)   extract_nc $xf $xdir/vmhi.nc oH.Ha   "${(@)bpos}" -    || return $?;;
    (bHt)  extract_nc $xf $xdir/vmhi.nc time    "${(@)bpos}" -    || return $?;;
    #---------------------------------------- netcdf derived
    (g)    local zpf= apf=
           $0 apf  dadp  "${(@)copts}" || return $?
           $0 Zpf  dZdpn "${(@)copts}" || return $?
           if extract_math $xf $apf $Zpf $xdir/vmhi.nc; then
             logmsg -d "Latest $xf"
           else
             local H=($($0 - H "${(@)copts}")) || return $?
             # print - extract_math $xf -- -Ca $apf $Zpf DIV $H DIV
             extract_math $xf -- -Ca $apf $Zpf DIV $H DIV || return $?
           fi
           ;;
    (ginv) local gf=
           $0 gf g  "${(@)copts}" || return $?
           extract_math $xf $gf -- -Ca $gf 0 NAN INV || return $?
           ;;
    (alt)  local gif=
           $0 gif ginv  "${(@)copts}" || return $?
           extract_math $xf $gif -- -Ca $gif NEG || return $?
           ;;
    (altm) local gif= af=
           $0 gif ginv  "${(@)copts}" || return $?
           $0 af  a     "${(@)copts}" || return $?
           extract_math $xf $gif $af -- -Ca $gif NEG $af $tyr GE 1 NAN OR || return $?
           ;;
    (altc) local gif=
           [[ -z $altc ]] && logmsg -f "Panic: invalid altc" && exit 1
           $0 gif ginv  "${(@)copts}" || return $?
           extract_math $xf $gif -- -Ca $gif NEG DUP $altc[1] GT 1 NAN OR || return $?
           ;;
    (z[ns])  local Zf=
             $0 Zf Z${vtgt: 1} "${(@)copts}" || return $?
             if extract_math $xf $Zf $xdir/vmhi.nc; then
               logmsg -d "Latest $xf"
             else
               local H=($($0 - H "${(@)copts}")) || return $?
               extract_math $xf -- -Ca $Zf $H MUL || return $?
             fi
             ;;
    (d[ns])  local Df=
             $0 Df D${vtgt: 1} "${(@)copts}" || return $?
             if extract_math $xf $Df $xdir/vmhi.nc; then
               logmsg -d "Latest $xf"
             else
               local H=($($0 - H "${(@)copts}")) || return $?
               extract_math $xf -- -Ca $Df $H MUL || return $?
             fi
             ;;
    #---------------------------------------- coordinate direct
    (dZdp[ns])  extract_coor $xf $xdir $vtgt D1 || return $?;;
    (p[ns])     extract_coor $xf $xdir $vtgt CO || return $?;;
    (dp[ns])    extract_coor $xf $xdir $vtgt DC || return $?;;
    (dZ[ns])    extract_coor $xf $xdir $vtgt DP || return $?;;
    (Z[ns])     extract_coor $xf $xdir $vtgt CP || return $?;;
    #---------------------------------------- coordinate derived
    (D[ns])     local Zf=
                $0 Zf Z${vtgt: 1} "${(@)copts}" || return $?
                extract_math $xf $Zf -- -Ca 1 $Zf SUB || return $?
                ;;
    esac
  fi
  [[ $__xf != xf && x$__xf != x- ]] && : ${(P)__xf::=$xf}
  return $err
}
# ----------------------------------------------------------------------
extract_altclip ()
{
  local __altc=$1; shift || return $?
  local cache=$1; shift || return $?
  local -A bprop=("$@")
  # diag -P +p -c bprop

  local afac=10
  [[ $__altc != altc ]] && local altc=()

  read_cache -a altc altc $cache
  if [[ -z $altc ]]; then
    local k= Amax= Bmax= defu=m
    for k in A Au
    do
      if [[ ${+bprop[$k]} -eq 1 ]]; then
        unit_orig Amax "$bprop[$k]" $defu + || return $?
        break
      fi
    done
    for k in B Bu
    do
      if [[ ${+bprop[$k]} -eq 1 ]]; then
        unit_orig Bmax "$bprop[$k]" $defu - || return $?
        break
      fi
    done
    altc=$(gmt math -Q $Amax 0 MAX $Bmax 0 MAX MAX $afac MUL =)
    altc+=($afac)
    write_cache -a altc altc $cache || return $?
  fi
  [[ $__altc != altc ]] && set -A $__altc "${(@)altc}"
  return 0
}
# ----------------------------------------------------------------------
extract_math ()
{
  local err=0
  local xf=$1; shift || return $?
  local chk=
  if [[ x$1 == x-- ]]; then
    chk=T; shift
  else
    while [[ $# -gt 0 ]]
    do
      [[ x$1 == x-- ]] && shift && break
      [[ $xf -nt $1 ]] || chk=T
      shift
    done
  fi
  if [[ -z $chk ]]; then
    logmsg -d "Latest $xf"
  elif [[ $# -eq 0 ]]; then
    # check only
    err=1
  else
    local cmd=(gmt math -bo1$prec -bi1$prec "$@" = $xf)
    "${(@)cmd}"; err=$?
    [[ $err -ne 0 ]] && rm -f $xf && xf=- && logmsg -f "Failed: ($err) $cmd"
  fi
  return $err
}
# ----------------------------------------------------------------------
extract_coor ()
{
  local err=0
  local xf=$1; shift || return $?
  local xdir=$1; shift || return $?
  local vtgt=$1 tag=$2
  local logf=($xdir/O/error.000*); logf=$logf[1]
  if [[ $xf -nt $logf ]]; then
    logmsg -d "Latest $xf"
  else
    local sub=${vtgt[-1]}
    if [[ $sub == n ]]; then
      sub=a
    elif [[ $sub == s ]]; then
      sub=b
    else
      logmsg -e "invalid coordinate position $sub."; return 1
    fi
    local tmp=($(sed -n -e "/^DVSRPA $tag .*ID\\.Z${sub}/p" $logf)) || return $?
    [[ -z $tmp ]] && logmsg -f  "Panic in $xf parser." && return 1
    local nz=$tmp[5] zcf=$tmp[$#tmp] js=$tmp[8] je=$tmp[9]
    tmp=($(gmt convert -bi${nz}d $xdir/$zcf | sed -n -e "${js},${je}p"))
    shift tmp
    print -l "${(@)tmp}" | gmt convert -bo1$prec > $xf; err=$?
    [[ $err -ne 0 ]] && rm -f $xf && xf=- && logmsg -f  "Failed: $err"
  fi
  return $err
}
# ----------------------------------------------------------------------
extract_nc ()
{
  local err=0
  local xf=$1; shift || return $?
  local ncsrc=$1 ncvar=$2;  shift 2 || return $?
  local bpos=($1 $2); shift 2 || return $?
  local tidx=$1 || return $?

  if [[ x${xf: :1} != x- && $xf -nt $ncsrc ]]; then
    logmsg -d "Latest $xf"
  else
    local nopts=(-V -C -H --trad)
    local nhopts=(-d Ya,$bpos[1] -d Xa,$bpos[2])
    local nzopts= ntopts=
    [[ $ncvar:e == Ta ]] && nzopts=(-d Za,1,-1)
    [[ x$tidx != x- ]] && ntopts=(-d time,$tidx)
    local cmd=(ncks $nopts $nhopts $nzopts $ntopts -v $ncvar $ncsrc)
    local tmp=($("${(@)cmd}")); err=$?
    # print -u2 - $cmd
    if [[ $err -ne 0 ]]; then
      logmsg -e  "Extract failed $ncsrc?${ncvar}[$bpos $tidx] $xf"
    elif [[ x${xf: :1} == x- ]]; then
      print -l "${(@)tmp}"
    else
      mkdir -p $xf:h || exit $?
      print -l "${(@)tmp}" | gmt convert -bo1$prec > $xf; err=$?
      [[ $err -ne 0 ]] && logmsg -e  "Conversion failed $ncsrc?${ncvar}[$bpos $tidx] $xf" && rm -f $xf
    fi
  fi
  return $err
}
# ----------------------------------------------------------------------
parse_yseq ()
{
  local err=0
  local _opts=$1; shift || return $?
  local __xset=$1; shift || return $?
  local xpfx=$1

  [[ $_opts  != OPTS ]] && local -A OPTS=("${(@Pkv)_opts}")
  [[ $__xset != XSET ]] && local -A XSET=("${(@Pkv)__xset}")

  local fsep=$SEP[f]
  local xj= xtag= xtyp=
  for xj in ${(n)${XSET[(I)${xpfx}[0-9]*${fsep}]}}
  do
    xtag="${XSET[$xj]}"
    xtyp="${XSET[${xj}T]}"
    # print -u2 - "$0 $xj $xtag"
    case $xtyp in
    (sol|hlp) ;;
    (*)    cache_yseq OPTS $xtag || return $?
           filter_yseq OPTS XSET $xj || return $?
           ;;
    esac
  done
  [[ $__xset != XSET ]] && set -A $__xset "${(@kv)XSET}"
  return $err
}
# ----------------------------------------------------------------------
cache_yseq ()
{
  local err=0
  local _opts=$1; shift || return $?
  [[ $_opts  != OPTS  ]] && local -A OPTS=("${(@Pkv)_opts}")
  local xdir=$1; shift || return $?

  local ncseq=$xdir/$OPTS[nc.seq]
  [[ ! -e $ncseq ]] && logmsg -e "Not exists $ncseq" && return 1

  local cache=$OPTS[asc]/$xdir/$OPTS[c.tidx]
  local prec=$OPTS[pr.BC]

  if [[ $cache -nt $ncseq ]]; then
    logmsg -d "Skip to update $cache"
  else
    logmsg -d "Generate $cache"
    local tmp=$(ncks -C -Q -H --trad -d time,-1 -v time $ncseq)
    local tfin=${${tmp#*\[}%\]*}
    local yfin=${tmp#*=}
    local err=0
    ncks --trad -V -C -Q -H -v time $ncseq |\
      gawk -v e=$tfin -v y=$yfin 'NF>0{print $1, $1-y, NR-1, NR-e-2}' |\
      gmt convert -bo2$prec,2i > $cache; err=$?
  fi
  return $err
}
# ----------------------------------------------------------------------
filter_yseq ()
{
  local id=t
  local _opts=$1; shift || return $?
  local __xset=$1; shift || return $?

  [[ $_opts  != OPTS ]] && local -A OPTS=("${(@Pkv)_opts}")
  [[ $__xset != XSET ]] && local -A XSET=("${(@Pkv)__xset}")

  local xj=$1; shift || return $?
  # [[ ${+XSET[${xj}${id}]} -eq 1 ]] && logmsg -d "($xj$id) Skipped" && return 0

  logmsg -d "($xj$id) extract filter"

  local xdir=$XSET[$xj]

  local ytable=$OPTS[asc]/$xdir/$OPTS[c.tidx]
  local cache=$OPTS[asc]/$xdir/$OPTS[c.prop]
  local prec=$OPTS[pr.BC]

  [[ ! -e $ytable  ]] && logmsg -e "Not exists $ytable" && return 1

  local filter=()
  parse_filter_yseq filter XSET $xj || return $?

  if [[ -z $filter ]]; then
    logmsg -d "($xj$id) no time filter"
  else
    local yseq=()
    local ckey="yseq:${filter} --"
    read_cache -a yseq "$ckey" $cache || return $?
    if [[ -z $yseq ]]; then
      extract_yseq yseq $prec $ytable $filter || return $?
      if [[ $yseq == skip ]]; then
        yseq=()
      else
        write_cache -n None -a yseq "$ckey" $cache || return $?
      fi
    fi
    [[ $yseq == None ]] && yseq=()

    if [[ $#yseq -eq 0 ]]; then
      logmsg -e "fail in t-filter."
      return 1
    fi
    XSET[${xj}${id}]="$yseq"
  fi
  [[ $__xset != XSET ]] && set -A $__xset "${(@kv)XSET}"
  return 0
}
# ----------------------------------------------------------------------
parse_filter_yseq ()
{
  local __filter=$1; shift || return $?
  [[ $__filter != filter ]] && local filter=()
  local _xset=$1; shift || return $?
  [[ $_xset != XSET ]] && local -A XSET=("${(@Pkv)_xset}")

  local xj=$1; shift || return $?

  filter=()
  local jxk=$xj jxp= bk= bv=
  jxk=$xj
  local yid=y
  while true
  do
    bv=$XSET[$jxk${yid}]
    [[ -n $bv ]] && break
    jxp=$XSET[${jxk}R]
    [[ $jxk == $jxp ]] && break
    jxk=$jxp
  done
  [[ -n $bv ]] && filter+=($bk $bv)
  [[ $__filter != filter ]] && set -A $__filter "${(@)filter}"
  return 0
}
#----------------------------------------------------------------------
extract_yseq ()
{
  local __yseq=$1;   shift || return $?
  local prec=$1; shift || return $?
  local tidxf=$1; shift || return $?
  [[ $__yseq != yseq ]] && local yseq=()
  yseq=()

  local tfmt=2$prec,2i
  if [[ x${tidxf:--} == x- ]]; then
    local yini=- yfin=-
  else
    local yini=($(gmt convert -bi$tfmt $tidxf | head -n 1))
    local yfin=($(gmt convert -bi$tfmt $tidxf | tail -n 1))
    yfin=$yfin[1] yini=$yini[1]
  fi
  # print -u2 - "$yini $yfin"

  local jy= yy= up= defu=yr YY=()
  local show=

  for jy in "$@"
  do
    for jy in ${(s:,:)jy}
    do
      yy=() up=
      case $jy in
      (k*) up=${jy: :1}; jy=${jy: 1};;
      esac
      for jy in "${(@s:/:)jy}"
      do
        if [[ $jy == ini ]]; then
          jy=${yini}
        elif [[ $jy == fin ]]; then
          jy=${yfin}
        elif [[ $jy == show ]]; then
          show=T; jy=
        elif [[ -n $jy ]]; then
          jy=$(units -t -1 -- ${jy}${up}$defu $defu); err=$?
          [[ $err -ne 0 ]] && logmsg -e  "failed ($jy)" && return $err
        fi
        yy+=("$jy")
      done
      if [[ $#yy -eq 1 ]]; then
        YY+=($yy)
      elif [[ -n $yy ]]; then
        if [[ $#yy -eq 2 ]];then
          [[ $yy[1] -gt $yy[2] ]] && yy=($yini "${(@)yy}")
        fi
        yy=($(enum -- ${yy[1]:-$yini} ${yy[3]:-1000} ${yy[2]:-$yfin}))
        YY+=($yy)
      fi
    done
  done
  local ti=
  if [[ x${tidxf:--} == x- ]]; then
    for yy in $YY
    do
      ti=-
      yseq+=("$yy,${ti}")
    done
  else
    for yy in $YY
    do
      ti=$(gmt select -bi$tfmt -Z$yy+c0 -o2 $tidxf)
      yseq+=("$yy,${ti}")
    done
  fi
  if [[ -n $show && -e $tidxf ]]; then
    YY=($(gmt select -bi$tfmt -o0 $tidxf))
    print - "y: $YY"
    yseq=(skip)
  fi
  [[ $__yseq  != yseq  ]] && set -A $__yseq "${(@)yseq}"
  return 0
}
# ----------------------------------------------------------------------
parse_bpos ()
{
  local err=0
  local _opts=$1; shift || return $?
  local __xset=$1; shift || return $?
  local xpfx=$1

  [[ $_opts  != OPTS ]] && local -A OPTS=("${(@Pkv)_opts}")
  [[ $__xset != XSET ]] && local -A XSET=("${(@Pkv)__xset}")

  local fsep=$SEP[f]
  local xj= xtag= xtyp=
  for xj in ${(n)${XSET[(I)${xpfx}[0-9]*${fsep}]}}
  do
    xtag="${XSET[$xj]}"
    xtyp="${XSET[${xj}T]}"
    case $xtyp in
    (sol|hlp) ;;
    (*)    cache_bpos OPTS $xtag || return $?
           filter_bpos OPTS XSET $xj || return $?
           ;;
    esac
  done
  [[ $__xset != XSET ]] && set -A $__xset "${(@kv)XSET}"
  return $err
}
#----------------------------------------------------------------------
cache_bpos ()
{
  local err=0
  local _opts=$1; shift || return $?
  [[ $_opts  != OPTS  ]] && local -A OPTS=("${(@Pkv)_opts}")
  local xdir=$1; shift || return $?

  local nccfg=$xdir/$OPTS[nc.cfg]
  [[ ! -e $nccfg ]] && logmsg -e "Not exists $nccfg" && return 1

  local btable=$OPTS[asc]/$xdir/$OPTS[c.btable]
  local cache=$OPTS[asc]/$xdir/$OPTS[c.prop]

  local prec=$OPTS[pr.BC]

  if [[ $btable -nt $nccfg ]]; then
    logmsg -d "Skip to update $btable"
  else
    logmsg -d "Generate $btable"
    local jv=0 var= o=-Q nopts=(--trad -H -V -C)
    local tmpd=$(mktemp -d)
    for var in $BCVAR
    do
      ncks $nopts $o -v $var.Ha $nccfg > $tmpd/f$jv
      let jv++
      o=
    done
    mkdir -p ${btable:h} || exit $?
    gmt convert -Af -o3-$((jv+2)),1,2 -bo${jv}$prec,2i $tmpd/f* > $btable; err=$?
    [[ $err -ne 0 ]] && print -u2 "Failed to create $btable." && rm -f $btable
    rm -rf $tmp
    [[ $err -ne 0 ]] && return $err
  fi
  if read_cache -K - bchoice $cache; then
    local jv=0 jc= mmeq= cho= vtag= vsfx=
    local -A bch=()
    for jv in {1..$#BCVAR..2}
    do
      case $BCVAR[$jv] in
      (ms*) vtag=A;;
      (mb*) vtag=B;;
      (h*)  vtag=H;;
      (*)   logmsg -e  "Unknown bc variable $BCVAR[$jv]"; return 1;;
      esac
      mmeq=$(gmt convert -bi${#BCVAR}$prec,2i -o$jv,$((jv-1)) $btable |\
               gawk '$1!=$2{print 1; exit}')
      if [[ $mmeq -eq 1 ]]; then
        for jc vsfx in $jv u $((jv-1)) l
        do
          cho=($(gmt convert -bi${#BCVAR}$prec,2i -o$jc $btable | sort -n | uniq))
          # print - "$vtag$vsfx $cho"
          bch[$vtag$vsfx]="$cho"
        done
      else
        jc=$jv
        cho=($(gmt convert -bi${#BCVAR}$prec,2i -o$jc $btable | sort -n | uniq))
        bch[$vtag]="$cho"
        # print - "$vtag $cho"
      fi
    done
    write_cache -K bch bchoice $cache || return $?
  fi
  return $err
}
# ----------------------------------------------------------------------
filter_bpos ()
{
  local id=b
  local _opts=$1; shift || return $?
  local __xset=$1; shift || return $?

  [[ $_opts  != OPTS ]] && local -A OPTS=("${(@Pkv)_opts}")
  [[ $__xset != XSET ]] && local -A XSET=("${(@Pkv)__xset}")

  local xj=$1; shift || return $?

  # [[ ${+XSET[${xj}${id}]} -eq 1 ]] && logmsg -d "($xj$id) Skipped" && return 0

  logmsg -d "($xj$id) extract filter"
  local xdir=$XSET[$xj]

  local btable=$OPTS[asc]/$xdir/$OPTS[c.btable]
  local cache=$OPTS[asc]/$xdir/$OPTS[c.prop]
  local prec=$OPTS[pr.BC]

  [[ ! -e $btable  ]] && logmsg -e "Not exists $btable" && return 1
  local filter=()
  parse_filter_bpos filter XSET $xj || return $?
  if [[ -z $filter ]]; then
    logmsg -d "($xj$id) no bpos filter"
  else
    local bpos=()
    local ckey="bpos:${filter} --"
    read_cache -a bpos "$ckey" $cache || return $?
    if [[ -z $bpos ]]; then
      extract_bpos bpos $prec $btable $cache $filter || return $?
      write_cache -a bpos "$ckey" $cache || return $?
    fi
    XSET[${xj}${id}]="$bpos"
  fi
  [[ $__xset != XSET ]] && set -A $__xset "${(@kv)XSET}"
  return 0
}
# ----------------------------------------------------------------------
parse_filter_bpos ()
{
  local __filter=$1; shift || return $?
  [[ $__filter != filter ]] && local filter=()
  local __xset=$1; shift || return $?
  [[ $__xset != XSET ]] && local -A XSET=("${(@Pkv)__xset}")

  local xj=$1; shift || return $?

  local bid=b
  filter=()
  local jxk=$xj jxp= bk= bv=
  for bk in A B H
  do
    jxk=$xj
    while true
    do
      bv=$XSET[$jxk${bid}$bk]
      [[ -n $bv ]] && break
      jxp=$XSET[${jxk}R]
      [[ $jxk == $jxp ]] && break
      jxk=$jxp
    done
    [[ -n $bv ]] && filter+=($bk $bv)
  done
  [[ $__filter != filter ]] && set -A $__filter "${(@)filter}"
  return 0
}
# ----------------------------------------------------------------------
extract_bpos ()
{
  local __bpos=$1; shift || return $?
  [[ $__bpos != bpos ]] && local bpos=()
  local prec=$1; shift || return $?
  local btable=$1 cache=$2; shift 2 || return $?
  local -A filter=("$@")

  local bk= bv= col= sign= defu=m
  local ov=
  local lch=() uch=()
  local selopts=()
  local BCS=(A 0 +    B 2 -   H 4 +)
  local -A bchoice=()
  read_cache -K bchoice bchoice $cache || return $?

  for bk col sign in $BCS
  do
    bv=$filter[$bk]
    [[ -z $bv ]] && continue
    unit_orig ov "$bv" $defu $sign || return $?
    # print -u2 - "$bk $col $sign $bv $ov"
    # lch=($(sed -ne "/^$bk /s///p" $bchoice))
    lch=(${=bchoice[$bk]})
    if [[ $#lch -eq 0 ]]; then
      # lch=($(sed -ne "/^${bk}l /s///p" $bchoice))
      # uch=($(sed -ne "/^${bk}u /s///p" $bchoice))
      lch=(${=bchoice[${bk}l]})
      uch=(${=bchoice[${bk}u]})
      if [[ $#uch -eq 1 ]]; then
        [[ $ov == c ]] && ov=$uch
        selopts+=(-Z$ov+c$col)
      elif [[ $#lch -eq 1 ]]; then
        [[ $ov == c ]] && ov=$lch
        selopts+=(-Z$ov+c$((col+1)))
      else
        logmsg -e "Need both choice $bk={$uch}{$lch}"
        return 1
      fi
    else
      selopts+=(-Z$ov+c$col)
    fi
  done
  bpos=(${(f)"$(gmt select $selopts -bi${#BCVAR}$prec,2i $btable)"})
  if [[ $#bpos -eq 0 ]]; then
    logmsg -e "No corresponding filter ${(kv)filter}"
    diag -P bchoice
    return 1
  elif [[ $#bpos -gt 1 ]]; then
    logmsg -e "Multiple candidates for filter ${(kv)filter}"
    diag -P bchoice
    print -l $bpos | column -t
    return 1
  else
    bpos=(${=bpos})
    local uv= lv= nmlv=()
    for bk col sign in $BCS
    do
      lv=$bpos[1] uv=$bpos[2]; shift 2 bpos || return $?
      if [[ $lv == $uv ]]; then
        adj_prop lv - $sign $defu || return $?
        nmlv+=("$bk=$lv" "${bk}u=$lv" "${bk}l=$lv")
      else
        adj_prop lv - $sign $defu || return $?
        adj_prop uv - $sign $defu || return $?
        nmlv+=("${bk}u=$uv" "${bk}l=$lv")
      fi
    done
    bpos+=("${(@)nmlv}")
  fi
  [[ $__bpos != bpos ]] && set -A $__bpos "${(@)bpos}"
  return 0
}
# ----------------------------------------------------------------------
unit_orig ()
{
  local _v=$1 i=$2 u=$3 s=$4
  if [[ x$s == x- ]]; then
    case $i in
    (-*) s=${i: 1};;
    (+*) s=-${i: 1};;
    (*)  s=-$i;;
    esac
  else
    s=$i
  fi
  if [[ -z $i ]]; then
    : ${(P)_v::=$i}
  elif [[ $i =~ ^[a-zA-Z] ]]; then
    : ${(P)_v::=$i}
  elif units -t -1 --quiet -- $s 1 > /dev/null; then
    : ${(P)_v::=$s}
  elif s=$(units -t -1 --quiet -- $s $u); then
    : ${(P)_v::=$s}
  else
    logmsg -e  "unit conversion failed: $*"
    : ${(P)_v::=}
    return 1
  fi
  return 0
}
# ----------------------------------------------------------------------
adj_prop ()
{
  local __v=$1;   shift || return $?
  local a=$1;     shift || return $?
  local sign=$1;  shift || return $?
  local defu=$1;  shift || return $?
  [[ x$a == x- ]] && a=${(P)__v}

  a=$sign${a#+}
  a=${${a#--}#+}
  if [[ $a -eq 0 ]]; then
    a=0
  else
    local up= t=
    for up in '' c m u
    do
      t=$(units -t -1 -- ${a}$defu $up$defu)
      [[ $t -eq $(printf '%.0f' $t) ]] && a=${t}$up$defu && break
    done
  fi
  : ${(P)__v::=$a}
  return 0
}
# ----------------------------------------------------------------------
nml_value ()
{
  local __v=$1;   shift || return $?
  local a=$1;     shift || return $?
  local defu=$1;  shift || return $?
  [[ x$a == x- ]] && a=${(P)__v}
  : ${(P)__v::=$a}

  [[ -z $a ]] && return 0
  [[ ${a[(i)[A-Za-z]]} -eq 1 ]] && return 0

  if units -t -1 --quiet -- $a 1 > /dev/null; then
    a=$a$defu
  fi

  if t=($(units -t -1 -- ${a} $defu)); then
    :
  else
    logmsg -e "unit conversion failed: $t"
    return 1
  fi

  for up in '' c m u
  do
    t=$(units -t -1 -- ${a} $up$defu)
    [[ $t -eq $(printf '%.0f' $t) ]] && a=${t}$up$defu && break
  done
  [[ $t -eq 0 ]] && a=0
  : ${(P)__v::=$a}
  return 0
}
# ----------------------------------------------------------------------
opr_files ()
{
  local err=0
  local __xfiles=$1; shift || return $?
  [[ $__xfiles != xfiles ]] && local xfiles=()

  local _opts=$1; shift || return $?
  local __xset=$1; shift || return $?
  [[ $_opts  != OPTS ]] && local -A OPTS=("${(@Pkv)_opts}")
  [[ $__xset != XSET ]] && local -A XSET=("${(@Pkv)__xset}")

  local opr=$1 vtgt=$2; shift 2 || return $?
  local xpfx=$1 rpfx=$2; shift 2 || return $?
  local xf= rf=
  # logmsg -n "Parse $opr $vtgt"
  local prec=$OPTS[pr.V]

  xfiles=()
  if [[ $opr == r ]]; then
    for xf rf in "$@"
    do
      xfiles+=($rf)
    done
  else
    # print -l "$@"
    local fsep=$SEP[f]
    local xj= rj= xb= rb= xt= XT= rt= RT= subd= nf= XF= RF= NF=
    local -A pcommon=()
    local cmd=()
    for xj in ${(n)${XSET[(I)${xpfx}[0-9]*${fsep}]}}
    do
      rj=$rpfx${xj#$xpfx}
      cache_comdiff pcommon OPTS XSET p $xj $rj || return $?
      xb=(${${=XSET[${xj}b]}: :2}) XT=(${=XSET[${xj}t]})
      rb=(${${=XSET[${rj}b]}: :2}) RT=(${=XSET[${rj}t]})
      XF=$1; XF=(${(s:,:)XF})
      RF=$2; RF=(${(s:,:)RF})
      shift 2 || return $?
      [[ -z $RT ]] && RT=(-)
      NF=()
      for xt rt in ${XT:^^RT}
      do
        xf=$XF[1] rf=$RF[1]
        shift XF RF || return $?
        if [[ x$xf == x- || x$rf == x- ]]; then
          nf=-
        else
          XSET[${rj}d]="$pcommon[b]"
          # print -u2 - $rj "$pcommon[b]"
          get_opr_subd subd $opr "$pcommon[b]" "$xb" "$xt" "$rb" "$rt"
          nf=$xf:h/$subd/$xf:t
          if [[ $nf -nt $xf && $nf -nt $rf ]]; then
            logmsg -d "Latest $nf"
          else
            mkdir -p $nf:h || exit $?
            cmd=()
            case $opr in
            (f) cmd=(gmt math -bi1$prec -bo1$prec $xf $rf SUB $rf DIV = $nf);;
            (d) cmd=(gmt math -bi1$prec -bo1$prec $xf $rf SUB = $nf);;
            esac
            logmsg -d "${(@q-)cmd}"
            [[ -n $cmd ]] && "${(@)cmd}"
          fi
        fi
        NF+=($nf)
      done
      xfiles+=(${(j:,:)NF})
    done
  fi
  [[ $__xfiles != xfiles ]] && set -A $__xfiles "${(@)xfiles}"
  [[ $__xset   != XSET   ]] && set -A $__xset   "${(@kv)XSET}"
  return $err
}
# ----------------------------------------------------------------------
transform_files ()
{
  local __xfiles=$1; shift || return $?
  [[ $__xfiles != xfiles ]] && local xfiles=()
  local __vprop=$1; shift || return $?
  [[ $__vprop != vprop ]] && local -A vprop=()

  local _opts=$1; shift || return $?
  local __xset=$1; shift || return $?
  [[ $_opts  != OPTS ]] && local -A OPTS=("${(@Pkv)_opts}")
  [[ $__xset != XSET ]] && local -A XSET=("${(@Pkv)__xset}")

  local xpfx=$1 vi=$2; shift 2 || return $?
  local -A VSET=("$@")

  local oprfull=()
  local vsfx=()
  xfiles=($=VSET[${vi}f])
  if [[ ${+VSET[${vi}L]} -eq 1 ]];then
    if [[ -n ${VSET[${vi}L]} ]]; then
      local lprop=() lopr=() subd=
      symlog_prop lprop "$VSET[$vi]" "$VSET[${vi}u]" "$VSET[${vi}uorg]" "${VSET[${vi}L]}" || return $?
      lopr=(${lprop: 2}); lprop=(${lprop: :2})
      subd=L${(j:_:)lprop}
      symlog_files xfiles "$lopr" $xfiles || return $?
      oprfull+=($lopr)
      vsfx+=(L)
    else
      vsfx+=(l)
    fi
  fi
  vprop[${vi}opr]="$oprfull"
  vprop[${vi}sfx]="$vsfx"
  [[ $__xfiles != xfiles ]] && set -A $__xfiles "${(@)xfiles}"
  [[ $__xset != XSET ]] && set -A $__xset "${(@kv)XSET}"
  [[ $__vprop != vprop ]] && set -A $__vprop "${(@kv)vprop}"
  return 0
}
# ----------------------------------------------------------------------
symlog_files ()
{
  local err=0
  local __xfiles=$1; shift || return $?
  [[ $__xfiles != xfiles ]] && local xfiles=()
  local lopr=$1; shift || return $?
  [[ -z $lopr ]] && set -A $__xfiles "$@" && return 0
  lopr=(${=lopr})

  local prec=$OPTS[pr.V]

  xfiles=()
  local cmd=()
  local XF=() xf=
  local NF=() nf= npfx=

  for XF in "$@"
  do
    NF=()
    for xf in ${(s:,:)XF}
    do
      npfx=${(M)xf#-}
      xf=${xf#-}
      if [[ -z $xf ]]; then
        nf=-
      else
        nf=$xf:h/$subd/$xf:t
        if [[ $nf -nt $xf  ]]; then
          logmsg -d "Latest $nf"
        else
          mkdir -p $nf:h || exit $?
          cmd=(gmt math -Ca -bi1$prec -bo1$prec $xf $lopr = $nf)
          logmsg -d "$cmd"
          "${(@)cmd}"
        fi
        NF+=($npfx$nf)
      fi
    done
    xfiles+=(${(j:,:)NF})
  done
  [[ $__xfiles != xfiles ]] && set -A $__xfiles "${(@)xfiles}"
  [[ $__xset   != XSET   ]] && set -A $__xset   "${(@kv)XSET}"
  return $err
}
# ----------------------------------------------------------------------
cache_comdiff ()
{
  local __com=$1; shift || return $?
  local _opts=$1; shift || return $?
  local _xset=$1; shift || return $?
  [[ $_opts != OPTS ]] && local -A OPTS=("${(@Pkv)_opts}")
  [[ $_xset != XSET ]] && local -A XSET=("${(@Pkv)_xset}")
  [[ $__com != com ]] && local -A com=()

  local tag=$1; shift || return $?
  local xa=$1 xb=$2; shift 2 || return $?

  local da=${XSET[${xa}]} db=${XSET[${xb}]}
  da=$da:h/$da:t db=$db:h/$db:t
  local cache=$OPTS[asc]/$da/$OPTS[c.prop]
  local ctag="comm:$db"
  read_cache -K com "$ctag" $cache
  # print -u2 - $cache $tag
  if [[ -z $com ]]; then
    local tmpd=$(mktemp -d)
    local fa=$tmpd/xa fb=$tmpd/xb
    print -l ${(o)=XSET[${xa}$tag]} > $fa
    print -l ${(o)=XSET[${xb}$tag]} > $fb
    # cat $fa >&2
    # cat $fb >&2
    local co= o= k=
    com=()
    for k co in c -12   a -23   b -13
    do
      o=($(comm $co $fa $fb))
      com[$k]="$o"
    done
    rm -rf $tmpd
    write_cache -K com "$ctag" $cache
  fi
  # diag -P +p -c com
  [[ $__com != com ]] && set -A $__com "${(@kv)com}"
  return 0
}
# ----------------------------------------------------------------------
get_opr_subd ()
{
  local __subd=$1; shift || return $?
  [[ $__subd != subd ]] && local subd=
  local opr=$1; shift || return $?
  subd=$opr
  local props="$1"; shift || return $?
  local k= v=
  for v in ${=props}
  do
    k=${v%%=*}
    v=${v#*=}
    subd="${subd}$k$v"
  done
  local xb=$1 xt=$2 rb=$3 rt=$4
  if [[ $xb != $rb ]]; then
    rb=(${=rb})
    subd="${subd}b${(j:_:)rb}"
  fi
  xt=(${(s:,:)xt})
  if [[ x$rt != x- ]]; then
    rt=(${(s:,:)rt})
    if [[ $xt[2] != $rt[2] ]]; then
      subd="${subd}t$rt[2]"
    fi
  else
    [[ x$xt[2] != x- ]] && subd="${subd}tnone"
  fi
  # subd $opr "$pcommon[a]" "$xb" "$xt" "$rb" "$rt"
  [[ $__subd != subd ]] && ${(P)__subd::=$subd}
  return
}
# ----------------------------------------------------------------------
expand_sol_auto ()
{
  local err=0
  local __xset=$1; shift || return $?
  local sxj=$1; shift || return $?
  local xpfx=$1
  [[ $__xset != XSET ]] && local -A XSET=("${(@Pkv)__xset}")

  local reftag=R
  local fsep=$SEP[f]

  # to do: use extract_ball()
  local cfgA= cfgB= cfgH=
  nml_value cfgA "$XSET[${sxj}A]" m || return $?
  nml_value cfgB "$XSET[${sxj}B]" m || return $?
  nml_value cfgH "$XSET[${sxj}H]" m || return $?

  local cfgz="${XSET[${sxj}z]:-f}"

  local RXJ=(${(n)${XSET[${sxj}$reftag]}})
  [[ -z $RXJ ]] && RXJ=(${(n)${XSET[(I)[0-9]*${fsep}]}})

  local sdef="$XSET[${sxj}]$fsep"
  local stag="${(L)XSET[${sxj}]}"

  local astr=
  local rxj= BX=() AA=() BB=() HH=()
  local subj=0 nxj=
  local XCHECK=() xch= pstr=
  local -A xprop=()
  for rxj in $RXJ
  do
    [[ -n $XSET[${rxj}T] ]] && continue
    BX=()
    if [[ x$rxj != x- ]]; then
      BX=(${=XSET[${rxj}b]})
      [[ -n $BX ]] && shift 2 BX
    fi
    filter_config AA "$cfgA" ${(M)BX##A*} || return 1
    filter_config BB "$cfgB" ${(M)BX##B*} || return 1
    filter_config HH "$cfgH" ${(M)BX##H*} || return 1

    parse_aa_str xprop ${=XSET[${rxj}p]} || return $?
    xprop=("${(@kv)xprop[(I)[^ABHC]*]}")
    xprop[D]=${XSET[${sxj}D]-${XSET[${sdef}D]}}
    xprop[P]=${XSET[${sxj}P]-${XSET[${sdef}P]}}
    xprop[S]=${XSET[${sxj}S]-${XSET[${sdef}S]}}

    # diag -P +p -c -k "${rxj}*" XSET
    # diag -P +p -c AA BB HH BX
    # diag -P +p -c xprop
    for hh in $HH
    do
      for bb in $BB
      do
        for aa in $AA
        do
          xch="$aa $bb $hh $xprop[Z]"
          [[ $XCHECK[(Ie)$xch] -gt 0 ]] && continue
          XCHECK+=($xch)

          nxj=${sxj}$subj$fsep
          XSET[$nxj]=$stag   XSET[${nxj}T]=$stag
          XSET[${nxj}A]=$aa  XSET[${nxj}B]=$bb XSET[${nxj}H]=$hh
          XSET[${nxj}z]=$cfgz
          XSET[${nxj}R]="${sxj} ${sdef} ${rxj}"
          unparse_aa_str pstr "${(@kv)xprop}" A "$aa" B "$bb" k sol
          XSET[${nxj}p]="$pstr"
          [[ ${+XSET[${sxj}y]} -eq 1 ]] && XSET[${nxj}y]=${XSET[${sxj}y]}
          let subj++
        done
      done
    done
  done
  # diag -P +p -c XSET
  [[ $__xset != XSET ]] && set -A $__xset "${(@kv)XSET}"
  return 0
}
# ----------------------------------------------------------------------
expand_sentry ()
{
  local err=0
  local _opts=$1; shift || return $?
  local __xset=$1; shift || return $?
  [[ $_opts  != OPTS ]] && local -A OPTS=("${(@Pkv)_opts}")
  [[ $__xset != XSET ]] && local -A XSET=("${(@Pkv)__xset}")

  local fsep=$SEP[f]
  local reftag=R
  local sxj=$1

  local k= v=

  inherit_args  XSET $sxj "$reftag" bA bB bH y || return $?

  local refs=($=XSET[${sxj}$reftag]); refs="$refs[1]"
  inherit_props XSET $sxj $refs || return $?
  if [[ ${+XSET[${sxj}y]} -eq 1 ]]; then
    logmsg -d "modify year filter on $sxj"
    local tid=t
    local yseq=
    extract_yseq yseq - - ${XSET[${sxj}y]} || return $?
    XSET[${sxj}${tid}]="$yseq"
  fi

  local -A xprop=()
  parse_aa_str xprop ${=XSET[${sxj}p]} || return $?
  unset 'xprop[C]'
  local styp="$XSET[${sxj}]"
  local sdef="$XSET[${sxj}]$fsep"
  # print -u2 - $styp
  # local sdef=SOL$fsep
  for k in P D S
  do
    [[ ${+XSET[${sxj}$k]} -eq 1 ]] && xprop[$k]=$XSET[${sxj}$k]
    [[ -z xprop[$k] ]] && xprop[$k]=$XSET[${sdef}$k]
  done

  local bpos=()
  local -A bprop=()
  bpos=(${=XSET[${sxj}b]})
  parse_aa_str bprop ${bpos: 2} || return $?
  # diag -P +p -c bprop

  bpos=()
  for k in A B H z
  do
    v=$XSET[${sxj}$k]
    [[ -z $v ]] && v=$bprop[$k]
    [[ -z $v ]] && v=$xprop[$k]
    case $v in
    ([ul]) v=$xprop[$k$v];;
    esac
    [[ -z $v ]] && logmsg -e "Need filter $k for solution." && return 1
    bprop[$k]=$v
    bpos+=($k="$v")
  done
  bpos=($bprop[H] $bprop[z] $bpos)
  XSET[${sxj}b]="$bpos"

  xprop=("${(@kv)xprop[(I)[^ABHC]*]}")
  local KR=(A B)
  [[ $styp == lev ]] && KR+=(H)
  # xprop[A]=${bprop[A]%%:*}
  # xprop[B]=${bprop[B]%%:*}
  # xprop[H]=${bprop[H]%%:*}
  for k in $KR
  do
    xprop[$k]=${bprop[$k]%%:*}
    [[ $xprop[$k] != ${bprop[$k]} ]] && logmsg -w "Replacement trial[$k] ${bprop[$k]} in solution"
  done

  unparse_aa_str pstr "${(@kv)xprop}" k sol || return $?
  XSET[${sxj}p]="$pstr"

  local xtag=
  unparse_xprop xtag "${(@kv)xprop}" || return $?
  XSET[${sxj}]="$xtag"
  XSET[${sxj}T]="$styp"

  local refd=${XSET[${sxj}Z]}
  if [[ -z $refd ]]; then
    for refd in ${=XSET[${sxj}R]}
    do
      [[ -d $refd ]] && break
      [[ -z $XSET[${refd}T] ]] && refd=${XSET[$refd]} && break
    done
  fi

  if [[ $xtag -nt $refd ]]; then
    logmsg -d "Skip to create $xtag"
  else
    local keyf=
    case $styp in
    (sol) keyf=f.agesol;;
    (lev) keyf=f.levsol;;
    (*)   logmsg -e  "Unknown solution tyype $styp."; return 1;;
    esac
    local srcf=$xtag/${OPTS[$keyf]}
    gen_sol_source $styp $srcf $refd "${(@kv)xprop}" || return $?
  fi

  [[ $__xset != XSET ]] && set -A $__xset "${(@kv)XSET}"
  return $err
}
# ----------------------------------------------------------------------
filter_config ()
{
  local _v=$1; shift || return $?
  local def=$1; shift
  local args=("$@")
  case $def in
  (u)  args=(${(M)args:#*u=*});;   ## only return *u
  (l)  args=(${(M)args:#*l=*});;   ## only return *l
  ('') ;;
  (*)  set -A $_v $def && return 0;;   ## use default unless empty
  esac
  args=(${args#*=})
  set -A $_v ${(u)args}
  [[ $#args -eq 0 ]] && logmsg -e "No filter $_v for solution" && return 1
  return 0
}
# ----------------------------------------------------------------------
gen_sol_source ()
{
  local styp=$1; shift || return $?
  local srcf=$1 refd=$2; shift 2 || return $?
  local k= v= vv= vk=
  local ma= mb= rh= dasc= defu=m
  local -A AGE=()
  local prec=$OPTS[pr.V]
  for k v in "$@"
  do
    case $k in
    (A) unit_orig ma "$v" $defu + || return $?;;
    (B) unit_orig mb "$v" $defu - || return $?;;
    (H) unit_orig rh "$v" $defu + || return $?;;
    (W) case $v in
        (v)  AGE[pf]=3;;
        (v*) AGE[pf]=${v: 1};;
        (*)  print -u2 - "$0: Not implemented yet for W=$v."; return 1;;
        esac;;
    (S) while [[ -n $v ]]
        do
          vk=${v: :1}; v=${v: 1}
          vv=${v%%[^0-9]*}
          case $vk in
          ([oirme]) AGE[$vk]=$vv;;
          (*) logmsg -e "Panic. $vk $vv"; return 1;;
          esac
          v=${v#$vv}
        done
        ;;
    esac
  done
  local keyx= defx=
  case $styp in
  (sol) : ${AGE[o]:=12} ${AGE[i]:=4}
        keyx=x.ageni defx=ageni;;
  (lev) : ${AGE[o]:=15} ${AGE[i]:=12} ${AGE[m]:=0} ${AGE[e]:=1} ${AGE[r]:=1000}
        keyx=x.levni defx=levopt;;
  (*)   logmsg -e "Unknown solution type $styp"; return 1;;
  esac

  local xcmd=$OPTS[$keyx]
  if [[ -z $xcmd ]]; then
    local t=
    for t in . ./src/etc/misc
    do
      t=$t/$defx
      [[ -e $t ]] && xcmd=$t && break
    done
  fi
  [[ -z $xcmd ]] && logmsg -f "Not found $defx executable." && return 1

  local srcd=$srcf:h
  mkdir -p $srcd || exit $?
  local param=$srcd/param

  local cmd=()
  if [[ $styp == sol ]]; then
    local df=
    extract_field df Dn $OPTS[asc] $refd - || return $?
    local dfa=$srcd/${df:t}.asc
    [[ ! $dfa -nt $df ]] && gmt convert -bi1$prec $df > $dfa

    cmd=($xcmd $AGE[pf] $AGE[o] $AGE[i] $ma $mb $dfa)
    print - "$cmd" > $param
    logmsg -d "Solution by $cmd"
    "${(@)cmd}" > $srcf

    if [[ $styp == sol ]]; then
      local smpf=$srcd/${OPTS[f.sample]}
      gmt sample1d -Fn $srcf -N$dfa > $smpf
    fi
  else
    cmd=($xcmd $AGE[pf] $AGE[o] $AGE[i] $ma $mb $rh ${AGE[r]} $AGE[m] $AGE[e])
    print - "$cmd" > $param
    logmsg -d "Solution by $cmd"
    "${(@)cmd}" > $srcf
  fi

  return 0
}
# ----------------------------------------------------------------------
inherit_args ()
{
  local err=0
  local __xset=$1; shift || return $?
  local xj=$1 reftag=$2; shift 2 || return $?
  local SkipTags=($@)

  [[ $__xset != XSET ]] && local -A XSET=("${(@Pkv)__xset}")

  local k= rk= v= tag=
  for rxj in ${=XSET[${xj}$reftag]}
  do
    if [[ -z $rxj || $rxj == $xj ]]; then
      :
    else
      for rk in ${XSET[(I)${rxj}*]}
      do
        tag=${rk#$rxj}
        [[ ${SkipTags[(I)$tag]} -gt 0 ]] && continue
        [[ ${tag[(i)[0-9]]} -eq 1 ]] && continue  # skip subgroup
        k=${xj}${tag}
        [[ ${+XSET[$k]} -eq 0 ]] && XSET[$k]=$XSET[$rk]
      done
    fi
  done

  [[ $__xset != XSET ]] && set -A $__xset "${(@kv)XSET}"
  return $err
}
# ----------------------------------------------------------------------
inherit_props ()
{
  local err=0
  local __xset=$1; shift || return $?
  local xtgt=$1 xref=$2; shift 2 || return $?
  local SkipTags=($@)

  [[ $__xset != XSET ]] && local -A XSET=("${(@Pkv)__xset}")
  local psep=$SEP[p] fsep=$SEP[f]

  xtgt=${xtgt%$fsep}$psep
  xref=${xref%$fsep}$psep

  # print -u2 - $0 $xtgt $xref
  local k= rk= v= tag=
  for rk in ${XSET[(I)${xref}*]}
  do
    # print -u2 - $0 $rk
    tag=${rk#$xref}
    [[ ${SkipTags[(I)$tag]} -gt 0 ]] && continue
    k=${xtgt}${tag}
    [[ ${+XSET[$k]} -eq 0 ]] && XSET[$k]=$XSET[$rk]
  done

  [[ $__xset != XSET ]] && set -A $__xset "${(@kv)XSET}"
  return $err
}
# ----------------------------------------------------------------------
init_gset ()
{
  local err=0
  local _opts=$1; shift || return $?
  local _gset=$1; shift || return $?
  [[ $_opts != OPTS ]] && local -A OPTS=("${(@Pkv)_opts}")
  [[ $_gset != GSET ]] && local -A GSET=("${(@Pkv)_gset}")

  local DEFV='\tDEF\t' # sentry

  # set tag default
  add_gset GSET d   w  "$DEFV" || return $?
  add_gset GSET d   sz "$DEFV" || return $?
  add_gset GSET d   sm "$DEFV" || return $?
  add_gset GSET d   so "$DEFV" || return $?
  add_gset GSET d   i  "$DEFV" || return $?       # inclusion switch
  add_gset GSET d   li "$DEFV" || return $?       # inclusion switch
  add_gset GSET x   c  "$DEFV" || return $?       # color  along experiment entries
  add_gset GSET x   s  "$DEFV" || return $?       # symbol along experiment entries
  add_gset GSET s   g  "$DEFV" || return $?       # gray-scale along solution entries
  add_gset GSET a   w  "$DEFV" || return $?       # width along annotation
  add_gset GSET t   d  "$DEFV" || return $?       # diminishing along time
  add_gset GSET e   o  "$DEFV" || return $?       # order along entry
  add_gset GSET e   lo "$DEFV" || return $?       # legend order along entry
  # default lists
  add_gset GSET -   c categorical:7:n  || return $?
  add_gset GSET -   d 50:100  || return $?
  add_gset GSET -   g 196 160 128 92 56 || return $?
  add_gset GSET -   w thicker thin || return $?
  add_gset GSET -   s  c t s i a x d h o n
  add_gset GSET -   sz 0.3c
  add_gset GSET -   sm 1
  add_gset GSET -   so +0
  add_gset GSET -   t  solid dashed dotted
  add_gset GSET -   o  aseq   # ascending sequence
  add_gset GSET -   lo aseq   # ascending sequence
  add_gset GSET -   i  a      # activate
  add_gset GSET -   li a      # activate
  add_gset GSET -   ls +l=t:1+x=c:MC:b:B+b=0.3+e=0 # legend section

  # special
  GSET[i]='dakxspetjf'                     # id sequence try
  # d: default
  # j: serial
  # a: annotation
  # k: entry kind
  # x: experiment entry
  # s: solution entry
  # e: entry
  # t: time
  # p: position to insert Prorperties (C A B ....)
  # f: final
  local k=
  for k in d j a x s k e t f
  do
    GSET+=([${k}${psep}f]=-)
  done
  # legend
  add_gset GSET t   lu kyr
  add_gset GSET A   lu cm
  add_gset GSET B   lu cm
  add_gset GSET H   lu m

  GSET+=([l.font]=12p [l.jym]=1.2 [l.jx]=2c)


  [[ $_gset != GSET ]] && set -A $_gset "${(@kv)GSET}"
  return $err
}
# ----------------------------------------------------------------------
add_gset ()
{
  local _gset=$1; shift || return $?
  local tag=$1; shift || return $?
  local prop=$1; shift || return $?

  [[ $_gset != GSET ]] && local -A GSET=("${(@Pkv)_gset}")

  [[ x${tag:--} == x- ]] && tag=
  local psep=$SEP[p]
  local k="$tag$psep$prop"
  GSET[$k]="$*"

  [[ $_gset != GSET ]] && set -A $_gset "${(@kv)GSET}"

  return 0
}
# ----------------------------------------------------------------------
parse_gset ()
{
  local err=0
  local _gset=$1; shift || return $?
  [[ $_gset != GSET ]] && local -A GSET=("${(@Pkv)_gset}")

  local DEFV='\tDEF\t' # sentry

  local rsep=$SEP[r] fsep=$SEP[f] csep=$SEP[c] psep=$SEP[p] dsep=$SEP[d]
  local g= t= p= k= v= l=() c=
  for g in "$@"
  do
    separate_str "$psep$dsep$rsep" t g "$g"
    if [[ ${t[(I)$fsep]} -gt 0 ]]; then  ### single key (T:K[+-=])
      case $g in
      ($rsep$rsep*) # T:K==LEGEND
        GSET[$t${psep}l]="${g#$rsep$rsep}"
        g=;;
      ($rsep*)      # T:K=LEGEND +.....
        separate_str "$psep$dsep" v g "${g#$rsep}"
        GSET[$t${psep}l]="$v"
        ;;
      esac
      while [[ -n $g ]]
      do
        c=${g: :1} g=${g: 1}
        separate_str "$psep$dsep$rsep" p g "$g"
        case $g in
        ([$psep$dsep]*|'')
          if [[ x$c == x$dsep ]]; then # -PROP
            k=${t#*$fsep}
            if [[ "$k" == '*' ]]; then
              # T:*-l  to remove all properties
              t=${t%%$fsep*}
              for k in $GSET[(I)$t$fsep*$psep$p]
              do
                unset "GSET[$k]"
              done
            else
              unset "GSET[$t$psep$p]"
            fi
          else # +PVALUE
            v=${p: 1} p=${p: :1}
            GSET[$t$psep$p]="${v:-$DEFV}"
          fi;;
        ($rsep$rsep*) # +P==VALUE (loop end)
          GSET[$t$psep$p]="${g#$rsep$rsep}"
          g=;;
        ($rsep*)  # +P=VALUE
          separate_str "$psep$dsep" v g "${g#$rsep}"
          GSET[$t$psep$p]="$v";;
        (*)  logmsg -f "FATAL"; exit 1;; # never
        esac
      done
    else # list mode (T+P=LIST)
      while [[ -n $g ]]
      do
        c=${g: :1} g=${g: 1}
        separate_str "$psep$dsep$rsep" p g "$g"
        # print -u2 - "[$c] $t <$p> $g"
        case $c in
        ($dsep) unset "GSET[$t$psep$p]";;    # -P
        ($psep)
          case $g in
          ([$psep$dsep]*|'')     # +P
            GSET[$t$psep$p]="$DEFV";;
          ($rsep$rsep*)          # +P==LIST (loop end)
            v="${g#$rsep$rsep}"
            v=("${(@ps/$csep/)v}")
            GSET[$t$psep$p]="$v"
            g='';;
          ($rsep*)               # +P=LIST
            separate_str "$psep$dsep$rsep" v g "${g#$rsep}"
            # print -u2 - "$t+$p <$v> $g"
            v=("${(@ps/$csep/)v}")
            GSET[$t$psep$p]="$v"
          ;;
          (*)  logmsg -f "FATAL"; exit 1;; # never
          esac;;
        ($rsep)
          case $g in
          ($rsep*) GSET[$t]="${g#$rsep}"; g=;;
          (*) GSET[$t]=$p;;
          esac;;
        esac
      done
    fi
    # diag -P +p -c GSET
  done
  for k in ${GSET[(I)*$psep*]}
  do
    if [[ $GSET[$k] == "$DEFV" ]]; then
      t=${(M)k%%$psep*}
      GSET[$k]="$GSET[$t]"
    fi
  done
  GSET[i]="${${(@s::)GSET[i]}}"

  [[ $_gset != GSET ]] && set -A $_gset "${(@kv)GSET}"
  return $err
}
# ----------------------------------------------------------------------
expand_gsets ()
{
  local err=0
  local _opts=$1; shift || return $?
  local __gset=$1; shift || return $?
  local __xset=$1; shift || return $?
  [[ $_opts  != OPTS ]] && local -A OPTS=("${(@Pkv)_opts}")
  [[ $__gset != GSET ]] && local -A GSET=("${(@Pkv)__gset}")
  [[ $__xset != XSET ]] && local -A XSET=("${(@Pkv)__xset}")
  local xpfx=$1

  gen_prop_gsets GSET XSET $xpfx || return $?

  local ctag=
  local gcache=$OPTS[proot]/$OPTS[c.gsets]
  # [[ ! -e $gcache ]] && touch $gcache

  local fsep=$SEP[f] psep=$SEP[p]
  local -A COUNTS=()
  local jgi= jgp= jgf= JGSEQ=() jgseq=() n=
  for jgi in ${GSET[(I)*$psep]}
  do
    JGSEQ=(${=GSET[$jgi]})
    COUNTS[${jgi%$psep}]=$#JGSEQ
  done
  # diag -P +p -c COUNTS
  # normalize color in XSET
  local clr=() nclr=
  local cpt= cini= cend= cmem= j= c= cseq=()
  local TAB='	'
  local gset=()
  # normalize single color in GSET
  for jgi in ${GSET[(I)*$fsep*${psep}c]}
  do
    clr=$GSET[$jgi]
    if [[ -n $clr ]]; then
      ctag="color:$clr"
      read_cache -a nclr "$ctag" $gcache || return $?
      if [[ -z $nclr ]]; then
        nclr=$(gmt makecpt -N -Fr+c -C$clr | gawk '{print $2}')
        write_cache -a nclr "$ctag" $gcache || return $?
      fi
      GSET[$jgi]=$nclr
    fi
  done

  local wcache= dseq=()
  local cmd=()
  for jgi in ${GSET[(I)*$psep*]}
  do
    jgp=${jgi%%$psep*} jgf=${jgi#*$psep}
    [[ -z $jgf ]] && continue
    [[ -z $jgp ]] && continue
    [[ $jgp[(I)$fsep] -gt 0 ]] && continue
    gset=(${=GSET[$jgi]})
    n=1
    [[ $#gset -eq 1 ]] && n=${COUNTS[$jgp]}
    # cache
    ctag="gset:${jgf}:${COUNTS[$jgp]}:${(j:,:)gset}"
    read_cache -a JGSEQ "$ctag" $gcache || return $?
    if [[ -z $JGSEQ ]]; then
      wcache=T
      case $jgf in
      (c) for cpt in $gset
          do
            cpt=("${(@s/:/)cpt}")
            cini=${cpt[2]:-1} cmem=${cpt[3]:-$n}
            [[ $cmem == n ]] && cmem=${COUNTS[$jgp]}
            cend=$((cini + cmem - 1))
            cpt=$cpt[1]
            if gmt makecpt -C$cpt >& /dev/null; then
              cmd=(gmt makecpt -N -Fr+c -C$cpt -T0/$cend/1)
              jgseq=($("${(@)cmd}" | sed -n -e "${cini},${cend}s/^[^$TAB]*$TAB//p"))
              [[ $#jgseq -eq 0 ]] && logmsg -e "Insufficient colors ($cini:$cend:$cmem) by cmd = $cmd" && return 1
              [[ $#jgseq -lt $cmem ]] && logmsg -w "Fewer colors by cpt=$cpt ($#jgseq < $cmem) $cmd"
              c=$cmem
              while [[ $c -gt 0 ]]
              do
                j=$#jgseq; [[ $j -gt $c ]] && j=$c
                JGSEQ+=(${jgseq: :$j})
                let 'c-=j'
              done
            else
              for j in {${cini}..${cend}}; do jgseq+=($cpt); done
            fi
          done
          ;;
      (d) for cseq in $gset
          do
            cseq=("${(@s/:/)cseq}")
            cini=${cseq[1]-50}
            cend=${cseq[2]-100}
            cmem=${cseq[3]-+$n}
            # +1 use cend
            # -1 use cini
            if [[ $cmem == -0 ]]; then
              cmem=-1
            elif [[ $cmem -eq 0 ]]; then
              cmem=+1
            fi
            if [[ $cmem -gt 0 ]]; then
              cmd=(gmt math --FORMAT_FLOAT_OUT='%.2f'  -T1/$cmem/1 -N1 -C0
                   'T' $cmem SUB 1 $cmem SUB DIV $cend $cini SUB MUL $cend SUB NEG $cend AND =)
            else
              cmd=(gmt math --FORMAT_FLOAT_OUT='%.2f' -T1/$((-cmem))/1 -N1 -C0
                   'T' 1 SUB $cend $cini SUB $cmem NEG 1 SUB DIV MUL $cini ADD $cini AND =)
            fi
            JGSEQ+=($("${(@)cmd}")) || { logmsg -e "Failed $cmd"; return 1 }
          done
          ;;
      (i|li)
        wcache=  # skip caching for inclusion switch
        for cseq in $gset
        do
          cseq=("${(@s/:/)cseq}")
          cmem=${cseq[2]-$n}
          for j in {1..$cmem}
          do
            JGSEQ+=($cseq)
          done
        done
        ;;
      (o|lo)
        wcache=  # skip caching for orders
        for cseq in $gset
        do
          cseq=("${(@s/:/)cseq}")
          cmem=${cseq[2]-${n:-1}}
          case $cseq in
          (aseq) JGSEQ=({1..$cmem});;
          (dseq) JGSEQ=({$cmem..1});;
          (*)    for j in {1..$cmem}
                 do
                   JGSEQ+=($cseq)
                 done;;
          esac
        done
        ;;
      (*) JGSEQ=(${=GSET[$jgi]});;
      esac
      if [[ -n $wcache ]]; then
        write_cache -n none -a JGSEQ "$ctag" $gcache || return $?
      fi
    fi
    [[ $JGSEQ == none ]] && JGSEQ=
    GSET[$jgi]="$JGSEQ"
  done
  # diag -P +p -c GSET

  [[ $__gset != GSET ]] && set -A $__gset "${(@kv)GSET}"

  return 0
}
#----------------------------------------------------------------------
gen_prop_gsets ()
{
  # count and generate choices list for each key
  # also, XSET[*p] modified with xsak entries
  local err=0
  local __gset=$1; shift || return $?
  local __xset=$1; shift || return $?
  [[ $__gset != GSET ]] && local -A GSET=("${(@Pkv)__gset}")
  [[ $__xset != XSET ]] && local -A XSET=("${(@Pkv)__xset}")
  local xpfx=$1

  local fsep=$SEP[f] psep=$SEP[p]
  local -A xprop=()
  local -A gprop=()
  local pstr=
  local k= v= e=
  # for xj in ${(n)${XSET[(I)${xpfx}[0-9]*${fsep}]}}
  # do
  #   e+=(${xj%%$fsep*})
  # done
  # k=e e=(${(u)e})
  # GSET[$k$psep]="$e"

  local -A COUNTS=()
  local xk= g=()
  local XT=()
  local j=0
  for xj in ${(n)${XSET[(I)${xpfx}[0-9]*${fsep}]}}
  do
    xtyp="${XSET[${xj}T]}"
    [[ $xtyp == hlp ]] && continue
    case $xtyp in
    (sol) xk=s;;
    (ann) xk=a;;
    (*)   xk=x;;
    esac
    COUNTS[$xk]=$((${COUNTS[$xk]:-0} + 1))
    e=${xj%%$fsep*}
    parse_aa_str xprop ${=XSET[${xj}p]} d=1 e=$e k=${xtyp:-def} s= a= x= $xk=$COUNTS[$xk] || return $?
    unparse_aa_str pstr "${(@kv)xprop}"
    XSET[${xj}p]="$pstr"
    unset 'xprop[AL]' 'xprop[BL]' 'xprop[HL]'
    XT=(${=XSET[${xj}t]})
    XT=(${XT%%,*})
    j=$(($j + $#XT))
    for k v in "${(@kv)xprop}" t "$XT"
    do
      v=(${=v})
      g=(${=gprop[$k]})
      g+=($v)
      g=(${(u)g})
      gprop[$k]="$g"
    done
  done
  let j--; j=({0..$j})
  for k v in "${(@kv)gprop}" j "$j"
  do
    GSET[$k$psep]="$v"
  done
  # diag -P +p -c GSET
  [[ $__gset != GSET ]] && set -A $__gset "${(@kv)GSET}"
  [[ $__xset != XSET ]] && set -A $__xset "${(@kv)XSET}"
  return 0
}
# ----------------------------------------------------------------------
parse_common_diff ()
{
  local err=0
  local _gset=$1; shift || return $?
  local _xset=$1; shift || return $?
  [[ $_gset != GSET ]] && local -A GSET=("${(@Pkv)_gset}")
  [[ $_xset != XSET ]] && local -A XSET=("${(@Pkv)_xset}")
  local xpfx=$1 rpfx=$2

  local psep=$SEP[p] fsep=$SEP[f]

  local pcomm=() pdiff=()
  local xkeys=() skeys=()
  local xt= xj= XJ=(${(n)${XSET[(I)${xpfx}[0-9]*${fsep}]}})
  for xj in "${(@)XJ}"
  do
    case ${XSET[${xj}T]} in
    (sol) skeys+=($xj);;
    (ann) ;;
    ('')  xkeys+=($xj);;
    esac
  done

  extract_comdiff pcomm pdiff OPTS XSET $xkeys || return $?

  local -A pbase=() pexp=()
  local    tbase=   texp=
  adj_pcomm pbase tbase $pcomm || return $?
  adj_pdiff pexp texp  $pdiff || return $?
  set_pdiff XSET pcomm $xkeys || return $?
  # diag -P +p -c pcomm pdiff

  local ysfx=
  get_ysfx ysfx $OPTS[proot]/$OPTS[c.gsets] "${texp}" ${(s:,:)tbase} || return $?
  # diag -P +p -c ysfx

  local -A psol=()
  local    tsol=
  extract_comdiff pcomm pdiff OPTS XSET $skeys || return $?
  adj_pdiff psol tsol $pdiff || return $?
  set_pdiff XSET pcomm $skeys || return $?
  # diag -P +p -c pcomm pdiff

  local -A pref=()
  if [[ -n $rpfx ]]; then
    local tref=
    pdiff=()
    for k in ${(n)${XSET[(I)${rpfx}[0-9]*${fsep}]}}
    do
      pdiff+=($=XSET[${k}d])
      pdiff+=("T=$XSET[${k}T]")
      # pdiff+=("T=$XSET[${k}T]" "k=$XSET[${k}T]")
    done
    adj_pdiff pref tref $pdiff || return $?
  fi
  # diag -P +p -c pref pdiff

  local dbase= dsub= dref= pstr=
  # base
  unparse_xprop dbase "${(@kv)pbase}"
  unparse_aa_str pstr "${(@kv)pbase}" || return $?
  GSET[${fsep}comm]="$pstr"
  GSET[${psep}base]="$dbase"
  # sub (comparison)
  for k in ${(ok)pexp}
  do
    # print -u2 - $0 dsub $k $pexp[$k] $GSET[${k}${psep}f]
    [[ x$GSET[${k}${psep}f] == x- ]] && continue
    dsub=$dsub$k$pexp[$k]
  done
  [[ -n $dsub ]] && dsub=cmp$dsub
  if [[ -n $skeys ]]; then
    dsub=${dsub:-cmp}sol
    for k in ${(ok)psol}
    do
      [[ x$GSET[${k}${psep}f] == x- ]] && continue
      [[ $psol[$k] -gt 1 ]] && dsub=$dsub$k$psol[$k]
    done
  fi
  [[ -n $dsub ]] && GSET[${psep}sub]="$dsub"

  # sub (reference)
  if [[ $pref[T] == sol ]]; then
    dref=$pref[T]
  else
    for k in ${(ok)pref}
    do
      [[ x$GSET[${k}${psep}f] == x- ]] && continue
      [[ -n $pref[$k] ]] && dref=$dref$k$pref[$k]
    done
  fi
  [[ -n $dref ]] && dref=ref$dref
  [[ -n $dref ]] && GSET[${psep}ref]="$dref"
  [[ -n $ysfx ]] && GSET[${psep}sfx]=_$ysfx

  [[ $_gset != GSET ]] && set -A $_gset "${(@kv)GSET}"

  return 0
}
# ----------------------------------------------------------------------
get_ysfx ()
{
  local __ysfx=$1; shift || return $?
  [[ $__ysfx != ysfx ]] && local ysfx=
  local gcache=$1; shift || return $?
  local tdiff=$1; shift || return $?
  local tcomm=("$@")
  if [[ $#tcomm -gt 1 ]]; then
    local ctag="ysfx: ${(j:,:)tcomm}"
    read_cache ysfx "$ctag" $gcache || return $?
    if [[ -z $ysfx ]]; then
      local count=
      read_cache -c count "ysfx" $gcache || return $?
      ysfx=yseq${count}_$#tcomm
      write_cache ysfx "$ctag" $gcache || return $?
    fi
  elif [[ $#tcomm -eq 1 ]]; then
    local up= tu= uo=yr
    for up in M k
    do
      tu=$(units -t -1 -- ${tcomm}$uo $up$uo) || exit $?
      [[ $tu -eq $(printf '%.0f' $tu) ]] && tcomm=${tu}$up && break
    done
    ysfx=y$tcomm
  elif [[ -n $tdiff ]]; then
    ysfx=yvar
  fi

  [[ $__ysfx != ysfx ]] && : ${(P)__ysfx::=$ysfx}
  return 0
}
# ----------------------------------------------------------------------
assign_gsets ()
{
  local err=0
  local __gset=$1; shift || return $?
  local __xset=$1; shift || return $?
  local __vset=$1; shift || return $?
  [[ $__gset != GSET ]] && local -A GSET=("${(@Pkv)__gset}")
  [[ $__xset != XSET ]] && local -A XSET=("${(@Pkv)__xset}")
  [[ $__vset != VSET ]] && local -A VSET=("${(@Pkv)__vset}")

  local xpfx=$1; shift || return $?

  local fsep=$SEP[f] psep=$SEP[p] rsep=$SEP[r]

  #  diag -P +p -c GSET

  local cmd=()
  # count args
  local xg= xtyp= jt=
  local -A pen=()
  local jgprop= glist=()
  local pskip=() jc=
  local ngj= cset=() gv= clr= cj=
  local k= v= a=
  local vi=  VI=(${(on)${VSET[(I)*$psep]}})
  local xj=  XJ=(${(n)${XSET[(I)${xpfx}[0-9]*${fsep}]}})
  local -A xfiles=() xf=()
  local -A dprop=() xprop=() oprop=()
  local dp=
  local tx=
  # local ydefu=yr yxu=${OPTS[l.uyr]:-$ydefu}
  for vi in "${(@)VI}"
  do
    v=(${=VSET[${vi}f]})
    xfiles[$vi]="${(j:,:)v}"
  done
  # diag -P +p -c xfiles
  # set JGK
  local pk= jgk= JGK=(${=GSET[i]})
  if [[ ${JGK[(I)p]} -gt 0 ]]; then
    local PK=($GSET[(I)*$psep])
    PK=("${(@)PK%$psep}")
    # PK=("${(@)PK:#[a-z]}")
    PK=("${(@)PK:|JGK}")
    j=${JGK[(I)p]}
    JGK[$j]=(${(o)PK})
  fi
  # diag -P +p -c JGK
  # filter
  for jgk in $JGK
  do
    if [[ ${#GSET[(I)$jgk$psep?*]} -eq 0 \
            && ${#GSET[(I)$jgk$fsep*$psep?*]} -eq 0 ]]; then
      j=$JGK[(i)$jgk]
      JGK[$j]=()  # clear if no config
    fi
  done
  #
  local -A ODR=() odr=() LODR=() lodr=()
  local -A cprop=()
  local padd=()
  local exg= lsp=
  local vp=
  # check t uniquness
  local uaddt=
  local ALLT=(${=GSET[t$psep]})
  [[ $#ALLT -gt 1 ]] && uaddt=T

  local tmpf=()
  local jiter=0
  local XT=()
  local jpstr=
  local -A JP=()
  for xj in "${(@)XJ}"
  do
    xtyp="${XSET[${xj}T]}"
    [[ $xtyp == hlp ]] && continue
    parse_aa_str xprop ${=XSET[${xj}p]} || return $?
    cprop=()
    for k v in "${(@kv)xprop}"
    do
      if [[ ${+GSET[${k}$psep]} -eq 1 ]]; then
        a=(${=GSET[${k}$psep]})
        v=${a[(I)$v]}
        [[ $v -gt 0 ]] && cprop[$k]=$v
      fi
    done
    xg="${xj%$fsep}$psep"
    exg="e$fsep${xg%%[$fsep$psep]*}$psep"
    # print -u2 - "$xg $exg"
    XT=(${=XSET[${xj}t]})
    for jt in ${XT:--}
    do
      jt=(${(s:,:)jt})
      ngj=$jiter$fsep
      cprop+=([t]=${ALLT[(I)$jt[1]]} [j]=$jiter)
      for vi in "${(@)VI}"
      do
        tmpf=("${(@s:,:)xfiles[$vi]}")
        xf[$vi]=$tmpf[1]; shift tmpf
        xfiles[$vi]="${(j:,:)tmpf}"
      done
      pen=()
      unparse_aa_str jpstr "${(@kv)xprop}" t "$jt[1]" j "$jiter"
      JP[$jiter]="$jpstr"
      expand_pen pen xprop cprop GSET ${JGK}
      # diag -P +p -c pen
      GSET[${ngj}]=''            #  assign null
      GSET[${ngj}T]=${xtyp:-def}
      # file or value
      if [[ $xtyp == ann ]]; then
        # print -u2 - $xj $XSET[$xj]
        vi=${XSET[$xj]%%$psep*}
        vp=(${(ps/$fsep/)${XSET[$xj]#*$psep}})
        GSET[${ngj}$vi]="- $vp"
        GSET[${ngj}$xtyp]="$pen[a]"
      else
        for vi in "${(@)VI}"
        do
          gv=${vi%%[^0-9]*}
          GSET[${ngj}$gv]="$xf[$vi]"
        done
      fi
      # graphics parameters
      GSET[${ngj}pen]=''
      GSET[${ngj}pen]+="$pen[w],"
      clr=$pen[c]
      # diag -P +p -c xf VI
      GSET[${ngj}fill]="$clr"
      GSET[${ngj}pen]+="$clr,$pen[t]"
      GSET[${ngj}sym]=''
      if [[ -n $pen[s] ]]; then
        GSET[${ngj}sym]="$pen[s]$pen[sz] ${pen[sm]:-1},${pen[so]:-+0} $clr"
      fi
      dprop=()
      parse_aa_str dprop ${XSET[${xj}xd]} k=${XSET[${xj}T]:-def} e=$xprop[e] || return $?
      for k in A B H
      do
        if [[ $dprop[${k}u] == $dprop[${k}l] ]]; then
          # print - $k $dprop[${k}u] $dprop[${k}l] $dprop[${k}]
          if [[ -n $dprop[${k}u] ]]; then
            [[ ${+dprop[$k]} -eq 0 ]] && dprop[$k]=$dprop[${k}u]
            unset "dprop[${k}u]" "dprop[${k}l]"
          fi
        else
          unset "dprop[${k}]"
        fi
      done
      unparse_aa_str dp "${(@kv)dprop}" || return $?
      GSET[${ngj}u]="$dp"
      if [[ x${jt:--} != x- ]]; then
        [[ -n $uaddt ]] && GSET[${ngj}u]+=" t=$jt[1]"
      fi
      # special order - to skip this line
      #               + to increment previous
      #               = to keep previous
      # diag -P +p -c -k "${exg}*" GSET
      if [[ $pen[i] == a ]]; then
        odr="${pen[o]}.${jiter}"
        ODR[$odr]=$jiter
        GSET[${ngj}kf]="$odr"
      else
        odr=
        logmsg -n "Ignore $jiter."
      fi
      if [[ $pen[li] == a ]]; then
        lodr="${pen[lo]}.${jiter}.1"
        LODR[$lodr]=$jiter
        GSET[${ngj}kl]="$lodr"
      else
        lodr=
        logmsg -n "Ignore $jiter in legend."
      fi
      let jiter++
    done
    oprop=("${(@kv)dprop}")
  done
  local godr=()
  # cannot sort netative integer array.....
  # print     -l - "${(@k)ODR}" | sort -V >&2
  for odr in ${(f)"$(print -l "${(@k)ODR}" | sort -V)"}
  do
    godr+=($ODR[$odr])
  done
  GSET[+O]="$godr"

  godr=()
  for lodr in ${(f)"$(print -l "${(@k)LODR}" | sort -V)"}
  do
    godr+=($LODR[$lodr])
  done
  # legend grouping
  legend_section GSET JP $godr || return $?

  [[ $__gset != GSET ]] && set -A $__gset "${(@kv)GSET}"
  return $err
}
# ----------------------------------------------------------------------
legend_section ()
{
  local err=0
  local _gset=$1; shift || return $?
  local _prop=$1; shift || return $?
  [[ $_gset != GSET ]] && local -A GSET=("${(@Pkv)_gset}")
  [[ $_prop != PROP ]] && local -A PROP=("${(@Pkv)_prop}")

  local -A PO=() PN=()
  local pgrp=()
  # local LGK=("${(@s:,:)GSET[l.group]}")
  local k= v= sec=() secf=()
  local psep=$SEP[p] fsep=$SEP[f]
  local -A LGK=()
  for k in ${GSET[(I)*${psep}ls]}
  do
    v=$GSET[$k]
    k=${k%%$psep*}
    k=${k/$fsep/=}
    LGK[$k]="$v"
  done
  local jiter= godr2=()
  for jiter in "$@"
  do
    parse_aa_str PN "$PROP[$jiter]"
    pgrp=()
    for k v in "${(@kv)PN}"
    do
      [[ $PO[$k] != $v ]] && pgrp+=($k $k=$v)
    done
    sec=() secf=()
    for k in ${(k)LGK:*pgrp}
    do
      secf+=($LGK[$k])
      case $k in
      (*=*) sec+=("$k");;
      (*)   sec+=("$k=$PN[$k]")
      esac
    done
    [[ -n $sec ]] && godr2+=("sec:${(j:,:)sec}:${(j//)secf}")
    godr2+=($jiter)
    PO=("${(@kv)PN}")
  done
  GSET[l.O]="$godr2"
  [[ $_gset != GSET ]] && set -A $_gset "${(@kv)GSET}"
  return 0
}
# ----------------------------------------------------------------------
expand_pen ()
{
  local _pen=$1; shift || return $?
  local _xprop=$1; shift || return $?
  local _cprop=$1; shift || return $?
  local _gset=$1; shift || return $?

  [[ $_pen    != pen    ]] && local -A pen=()
  [[ $_xprop  != xprop  ]] && local -A xprop=("${(@Pkv)_xprop}")
  [[ $_cprop  != cprop  ]] && local -A cprop=("${(@Pkv)_cprop}")
  [[ $_gset   != GSET   ]] && local -A GSET=("${(@Pkv)_gset}")

  pen=()
  local jgk= pk= glist=
  local jgprop=
  local jc=
  local -A bufpen=()
  # print -u2 - "$@"
  for jgk in "$@"
  do
    # print -u2 - "$0: $jgk"
    # bufpen=([st.o]=inc [st.lo]=inc)
    bufpen=()
    pk=$xprop[$jgk]
    # print -u2 - $0 $jgk $pk
    # diag -P +p -c -k "$jgk$fsep$pk$psep?*" GSET
    for jgprop in ${GSET[(I)$jgk$fsep$pk$psep?*]}
    do
      glist="${GSET[$jgprop]}"
      jgprop=${jgprop##*$psep}
      bufpen[$jgprop]=$glist
    done
    # diag -P +p -p ":$jgk" -c bufpen
    for jgprop in ${GSET[(I)$jgk$psep?*]}
    do
      glist=(${=GSET[$jgprop]})
      jgprop=${jgprop#*$psep}
      # print -u2 - "$0       $jgprop {$glist}"
      # [[ ${+bufpen[$jgprop]} -eq 1 ]] && continue
      [[ -n $GSET[$jgk$fsep$pk$psep$jgprop] ]] && continue
      [[ -z $glist ]] && glist=(${=GSET[$jgprop]})
      jc=${cprop[$jgk]:-0}
      # print -u2 - "$0 $jgk/$jgprop/$jc"
      if [[ $jc -eq 0 ]]; then
        :
        # bufpen[$jgprop]=$glist[1]
      else
        [[ $jc -gt 0 && -n $glist[$jc] ]] && bufpen[$jgprop]=$glist[$jc]
      fi
    done
    # diag -P +p -p ":$jgk" -c bufpen
    for jgprop in ${(k)bufpen}
    do
      case $jgprop in
      # (o|lo) pen[$jgprop]="$jgk $bufpen[$jgprop] $pen[$jgprop]";;
      (o|lo) pen[$jgprop]="$pen[$jgprop] $jgk $bufpen[$jgprop]";;
      (i|li) pen[$jgprop]+=" $bufpen[$jgprop]";;
      (*)    pen[$jgprop]="$bufpen[$jgprop]";;
      esac
    done
  done
  for jgprop in o lo
  do
    glist=($=pen[$jgprop])
    glist=(${glist//bgr/0.1})  # to enable insertion before
    glist=(${glist//fgr/9999})
    pen[$jgprop]="${(j:.:)glist}"
  done
  # get final condition or never
  for jgprop in i li
  do
    glist=($=pen[$jgprop])
    glist=(${(M)glist#[nad]})
    if [[ ${glist[(I)n]} -gt 0 ]]; then
      pen[$jgprop]=n
    else
      pen[$jgprop]=${glist[-1]}
    fi
  done

  # color adjustment
  if [[ -n $pen[d] ]]; then
    local cset=${pen[c]:-$pen[g]}
    if [[ -n $cset ]]; then
      local clr=() cj=
      for cj in ${(s:/:)cset}
      do
        cj=$(print - "scale=3;$cj * $pen[d] / 100" | bc)
        clr+=($cj)
      done
      pen[c]="${(j:/:)clr}"
    fi
  elif [[ -n $pen[c] ]]; then
    :
  elif [[ -n $pen[g] ]]; then
    pen[c]="$pen[g]"
  fi
  # diag -P +p -c xprop cprop pen

  [[ $_pen != pen ]] && set -A $_pen "${(@kv)pen}"
  return 0
}
# ----------------------------------------------------------------------
expand_annotation ()
{
  local err=0
  local _gset=$1; shift || return $?
  local _xset=$1; shift || return $?
  local _vset=$1; shift || return $?
  [[ $_xset != XSET ]] && local -A XSET=("${(@Pkv)_xset}")
  [[ $_gset != GSET ]] && local -A GSET=("${(@Pkv)_gset}")
  [[ $_vset != VSET ]] && local -A VSET=("${(@Pkv)_vset}")

  local vi=$1; shift || return $?
  local var="$VSET[$vi]" ann="$VSET[${vi}a]"

  local fsep=$SEP[f] psep=$SEP[p] rsep=$SEP[r]
  local sp="$fsep$fsep"
  local aspec=${ann%%$sp*}
  local aprop=${${ann#$aspec}#$sp}
  aspec=(${(ps/$fsep/)aspec})
  local anv=$aspec[1] arefx=$aspec[2]; shift 2 aspec
  local ANN=()
  expand_ann_auto ANN XSET "$var" "$anv" "$arefx" "${(@)aspec}" || return $?

  # inquire unused entry number
  local ja=0
  while true
  do
    [[ ${+XSET[$ja$fsep]} -eq 0 ]] && break
    let ja++
  done
  logmsg -w "Internal XSET entry at $ja"
  local js=0 ann= xk=
  xk="$ja$fsep"
  XSET[${xk}]=''
  XSET[${xk}T]='hlp'
  local egp="e$fsep$ja"
  parse_gset GSET "$egp$aprop" || return $?

  local -A xprop=()
  for ann in "${(@)ANN}"
  do
    parse_aa_str xprop "${(@)ann}" k ann
    xk="$ja$fsep$js$fsep"
    if [[ -n "${VSET[${vi}opr]}" ]]; then
      logmsg -e "Annotation transformation ($vi) not yet implemented."
      return 1
    fi
    XSET[${xk}]="$vi$xprop[val]"
    XSET[${xk}T]='ann'
    XSET[${xk}p]="$ann"
    let js++
  done

  # diag -P +p -c XSET GSET
  [[ $_xset != XSET ]] && set -A $_xset "${(@Pkv)XSET}"
  [[ $_gset != GSET ]] && set -A $_gset "${(@Pkv)GSET}"
  return 0
}
# ----------------------------------------------------------------------
expand_ann_auto ()
{
  local err=0
  local _ann=$1; shift || return $?
  local _xset=$1; shift || return $?
  local var=$1 anv="$2" arefx="$3"; shift 3 || return $?
  local -A aspec=()
  parse_aa_str aspec "$@" || return $?
  : ${aspec[A]:=} ${aspec[B]:=} ${aspec[H]:=}

  [[ $_xset != XSET ]] && local -A XSET=("${(@Pkv)_xset}")
  [[ $_ann  != ANN ]] && local ANN=

  ANN=()
  local stag=
  case $var in
  ([dDzZ]n) case $anv in
       (a) stag=lev;;
       (*) logmsg -f "Annotation $var-$anv not implemented."; return 1;;
       esac;;
  (*) logmsg -f "Annotation $var not implemented."; return 1;;
  esac
  extract_ball BC XSET '' "${(@kv)aspec}" || return $?
  # diag -P +p -c BC aspec
  local sdef=${(U)stag}$fsep
  local bc=
  local a= b= h= y= w=
  local xtag=

  local -A sprop=()
  local k=
  for k in P D S
  do
    [[ ${+aspec[$k]} -eq 1 ]] && sprop[$k]=$aspec[$k]
    [[ -z $sprop[$k] ]] && sprop[$k]=$XSET[${sdef}$k]
  done

  local -A xprop=()
  local srcf= keyf=f.levsol tyr= defu=yr
  local knotf=$(mktemp) smpl=() vsol= rh=
  local pstr=
  for bc in "${(@)BC}"
  do
    bc=("${(@s:/:)bc}")
    xprop=([A]=$bc[1] [B]=$bc[2] [H]=$bc[3] [W]=$bc[4] [y]=$bc[5])
    unparse_xprop xtag "${(@kv)sprop}" "${(@kv)xprop}" || return $?
    srcf=$xtag/${OPTS[$keyf]}
    if [[ ! -e $srcf ]]; then
      logmsg -w "Annotation: $var $anv $arefx {$aspec}{$aprop} $srcf"
      gen_sol_source $stag $srcf - "${(@kv)xprop}" || return $?
    fi
    unit_orig rh "$xprop[H]" m + || return $?
    tyr=$(units -t -1 -- $xprop[y]$defu $defu); err=$?
    print - "$tyr" > $knotf
    case $anv in
    (a) smpl=($(gmt sample1d -Fa $srcf -T4 -N$knotf))
        case $var in
        (dn) vsol=$(gmt math -Q $smpl[2] $rh MUL =);;
        (Dn) vsol=$smpl[2];;
        (Zn) vsol=$(gmt math -Q 1 $smpl[2] SUB =);;
        (zn) vsol=$(gmt math -Q 1 $smpl[2] SUB $rh MUL =);;
        (*)  vsol="$smpl";;
        esac
        ;;
    esac
    unparse_aa_str pstr "${(@kv)sprop}" "${(@kv)xprop}" val "$var=$vsol:$anv=$tyr" || return $?
    ANN+=("$pstr")
  done
  rm -f $knotf
  [[ $_ann != ANN ]] && set -A $_ann "${(@)ANN}"
  return 0
}
# ----------------------------------------------------------------------
extract_ball ()
{
  local _bc=$1; shift || return $?
  local _xset=$1; shift || return $?
  local xpfx="$1"; shift || return $?
  local -A aspec=("$@")

  [[ $_xset != XSET ]] && local -A XSET=("${(@Pkv)_xset}")
  [[ $_bc   != BC ]] && local BC=()

  local cfgA= cfgB= cfgH= u=m
  nml_value cfgA "$aspec[A]" m || return $?
  nml_value cfgB "$aspec[B]" m || return $?
  nml_value cfgH "$aspec[H]" m || return $?

  local BX=() AA=() BB=() HH=() aa= bb= hh=
  local xj= XJ=(${(n)${XSET[(I)[0-9]*${fsep}]}})
  local yseq=() y=
  local -A xprop
  BC=()
  for xj in $XJ
  do
    [[ -n $XSET[${xj}T] ]] && continue
    BX=()
    if [[ x$xj != x- ]]; then
      BX=(${=XSET[${xj}b]})
      [[ -n $BX ]] && shift 2 BX
    fi
    parse_aa_str xprop ${=XSET[${xj}p]} || return $?

    yseq=("${(@s:,:)aspec[y]}")
    [[ -z $yseq ]] && yseq=(${=XSET[${xj}t]})

    filter_config AA "$cfgA" ${(M)BX##A*} || return 1
    filter_config BB "$cfgB" ${(M)BX##B*} || return 1
    filter_config HH "$cfgH" ${(M)BX##H*} || return 1
    for hh in $HH
    do
      for bb in $BB
      do
        for aa in $AA
        do
          for y in $yseq
          do
            y=(${(s:,:)y})
            BC+=($aa/$bb/$hh/$xprop[W]/$y[1])
          done
        done
      done
    done
  done
  BC=(${(u)BC})
  [[ $_bc != BC ]] && set -A $_bc "${(@)BC}"
  return 0
}
# ----------------------------------------------------------------------
wpfx ()
{
  local popts=()
  local pfx=
  local opts=
  while [[ $# -gt 0 ]]
  do
    case $1 in
    (--pfx)  pfx=$2; shift;;
    (--opts) opts=$2; shift;;
    (-) shift; break;;
    (-*) popts+=("$1");;
    (*) break;;
    esac
    shift
  done
  local tag="$1"; shift || return $?
  local def="$1"; shift || return $?
  local mode="$1"; shift || return $?
  local repl=
  local k= v= KV=()
  for k v in "$@"
  do
    [[ -z $k$v ]] && continue
    v="${v//\%/\\Percent}"
    KV+=("$k={$v}")
  done
  repl="\\REPL[mode=$mode,${(j:,:)KV}]{$def}"
  opts=("${(@s/:/)opts}")
  : ${opts[1]:=B} ${opts[2]:=B} ${opts[3]:=1} ${opts[4]:=0}
  local arg="[$opts[1]][$opts[2]][$opts[3]][$opts[4]]"
  [[ -n $tag ]] && print $popts -r - "${pfx}"'%<pfx> \psfrag'"{$tag}${arg}{$repl}"
  return 0
}
# ----------------------------------------------------------------------
gen_tex_psfragx ()
{
  # set -x
  local err=0
  local texf=$1; shift
  local tmpl=$1; shift
  local ops= obase= ohead= odest=
  local nps= neps=
  local cmd=()
  # print -u2 - "00:$tmpl"
  [[ x${tmpl:--} == x- ]] && tmpl=$OPTS[proot]/deftmpl.tex
  # print -u2 - "01:$tmpl"
  if [[ ! -e $tmpl ]]; then
cat <<EOF > $tmpl
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
\newcommand{\REPL}[2][]{{\LARGE\sffamily\bfseries #2}\small\texttt{#1}}
\newcommand{\Percent}{\%}
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
    if [[ $tmpl -nt $otex || ! -e $otex ]];then
      mkdir -p $otex:h
cat <<EOF > $otex
\input{$tmpl:r}
\begin{document}
\includegraphics[overwritepfx=true,ovp=true]%
                {$ops}
\end{document}
EOF
    fi
    if [[ -e $otex ]]; then
      cmd=(latex -halt-on-error --output-directory=$otex:h $otex)
      "${(@)cmd}" >& /dev/null; err=$?
      if [[ $err -ne 0 ]]; then
        logmsg -e "Failed: ${(@q-)cmd}"
        return $err
      else
        nps=$otex:r.ps
        neps=$nps:r.eps
        dvips -E -o $nps $otex:r.dvi >& /dev/null; err=$?
        [[ $err -eq 0 ]] && { epstool -b --copy $nps $neps >& /dev/null; err=$? }
        [[ $err -ne 0 ]] && logmsg -e "Failed in eps conversion: $neps" && return $err
        rm -f $nps
      fi
    fi
  done
  return $err
}
# ----------------------------------------------------------------------
# add_prop_long AAVAR KEY-PFX PSEP RSEP PROP-VALUE [VALUE]
add_prop_long ()
{
  local __prop=$1; shift || return $?

  local kpfx=$1; shift || return $?
  local psep=$1; shift || return $?
  local rsep=$1; shift || return $?
  local k= v=
  if [[ $# -eq 0 ]]; then
    :
  elif [[ $# -eq 1 ]]; then
    k="${1%%$rsep*}" v="${1#*$rsep}"
  elif [[ $# -eq 2 ]]; then
    case $1 in
    (*$rsep) k="${1%$rsep}" v="$2";;
    (*)      logmsg -f "Not hungry argument ($rsep): $1 $2"; return 1;;
    esac
  else
    logmsg -f "Invalid argument $@"; return 1
  fi
  k=${k#$psep}
  __prop="${__prop}[$kpfx$k]"
  : ${(P)__prop::="$v"}
  return 0
}
# ----------------------------------------------------------------------
# add_props AAVAR KEY-PFX PSEP RSEP [STRING.....]
add_props_short ()
{
  local __prop=$1; shift || return $?

  local kpfx=$1; shift || return $?
  local psep=$1; shift || return $?
  local rsep=$1; shift || return $?

  local str=
  local k= v= _p=
  for str in "$@"
  do
    str=${str#$psep}$psep
    while [[ -n $str ]]
    do
      v="${str%%$psep*}"
      if [[ -z $rsep ]]; then
        k=${v: :1}
        v=${v: 1}
        _p="${__prop}[$kpfx$k]"
        : ${(P)_p::="$v"}
      elif [[ ${v[(I)$rsep]} -eq 0 ]]; then
        _p="${__prop}[$kpfx$v]"
        unset "$_p"
      else
        k="${v%%$rsep*}"
        v="${v#*$rsep}"
        _p="${__prop}[$kpfx$k]"
        : ${(P)_p::="$v"}
      fi
      str=${str#*$psep}
    done
  done
  return 0
}
# ----------------------------------------------------------------------
# add_props AAVAR KEY-PFX PSEP RSEP [STRING.....]
add_props ()
{
  local __prop=$1; shift || return $?
  [[ $__prop != prop ]] && local -A prop=("${(@Pkv)__prop}")

  local kpfx=$1; shift || return $?
  local psep=$1; shift || return $?
  local rsep=$1; shift || return $?
  local str=
  local k= v=
  for str in "$@"
  do
    str="$str$psep"
    if [[ "${str#$psep}" == "$str" ]]; then
      prop[$kpfx]="${str%%$psep*}"
      str="${str#*$psep}"
    else
      str="${str#$psep}"
    fi
    while [[ -n $str ]]
    do
      v="${str%%$psep*}"
      if [[ -z $rsep ]]; then
        k="${v: :1}"; v="${v: 1}"
      else
        case $v in
        (*$rsep*) k="${v%%$rsep*}"; v="${v#*$rsep}";;
        (*)       k="${v: :1}"; v="${v: 1}";;
        esac
      fi
      prop[$kpfx$k]="$v"
      str=${str#*$psep}
    done
  done
  [[ $__prop != __prop ]] && set -A $__prop "${(@kv)prop}"
  return 0
}
# ----------------------------------------------------------------------
read_cache ()
{
  local mode=s asep='=' isep= tsep=': '
  while [[ $# -gt 0 ]]
  do
    case $1 in
    (-A)   mode=A;;
    (-A*)  mode=A; asep="${1: 2}";;
    (-K)   mode=K;;
    (-a)   mode=a;;
    (-s)   isep="$2"; shift;;
    (-s*)  isep="${1: 2}";;
    (-c)   mode=c;;
    (*)    break;;
    esac
    shift
  done
  local __var=$1; shift || return $?
  local tag=$1; shift || return $?
  local cache=$1
  [[ ! -e $cache ]] && mkdir -p $cache:h && touch $cache
  tag="$tag$tsep"
  local lines=(${(f)"$(grep -F -e "$tag" $cache)"})

  # check only
  [[ x${__var:--} == x- ]] && return $#lines

  lines=("${(@)lines#$tag}")
  case $mode in
  ([AK]) local k= v= # k=v k=v ....
         [[ $__var != var ]] && local -A var=()
         case $mode in
         (A) if [[ x"$isep" == x ]]; then
               lines=("${(@)=lines}")
             else
               lines=("${(@ps%$isep%)lines}")
             fi
         esac
         for v in "${(@)lines}"
         do
           k=${v%%$asep*}
           var[$k]="${v#*$asep}"
         done
         [[ $__var != var ]] && set -A $__var "${(@kv)var}"
         ;;
  (a) lines=(${lines:#})
      if [[ x"$isep" == x ]]; then
        lines=(${=lines})
      else
        lines=("${(@ps%$isep%)lines}")
      fi
      set -A $__var "${(@)lines}"
      ;;
  (c) : ${(P)__var::="$#lines"};;
  (s) : ${(P)__var::="$lines"};;
  (*) logmsg -e "unknown mode $mode"; return 1;;
  esac
  return 0
}
# ----------------------------------------------------------------------
write_cache ()
{
  local mode=s asep='=' isep=' ' tsep=': ' null=
  while [[ $# -gt 0 ]]
  do
    case $1 in
    (-A)   mode=A;;
    (-A*)  mode=A; asep="${1: 2}";;
    (-K)   mode=K;;
    (-a)   mode=a;;
    (-s)   isep="$2"; shift;;
    (-s*)  isep="${1: 2}";;
    (-n)   null=$2; shift;;
    (*)    break;;
    esac
    shift
  done
  local _var=$1; shift || return $?
  local tag=$1; shift || return $?
  local cache=$1
  [[ ! -e $cache ]] && mkdir -p $cache:h && touch $cache
  tag="$tag$tsep"
  case $mode in
  (A) [[ $_var != var ]] && local -A var=("${(@Pkv)_var}")  # K=V K=V...
      local k= lines=()
      for k in ${(ok)var}
      do
        lines+=("$k$asep${var[$k]}")
      done
      print "$tag$lines" >> $cache
      ;;
  (K) [[ $_var != var ]] && local -A var=("${(@Pkv)_var}")  # K: V per lines
      local k=
      for k in ${(ok)var}
      do
        print "$tag$k$asep${var[$k]}" >> $cache
      done
      ;;
  (a) [[ $_var != var ]] && local var=("${(@P)_var}")
      print "$tag${var:-$null}" >> $cache
      ;;
  (s) [[ $_var != var ]] && local var="${(P)_var}"
      print "$tag${var:-$null}" >> $cache
      ;;
  (*) logmsg -e "unknown mode $mode"
      return 1
      ;;
  esac

  return 0
}
# ----------------------------------------------------------------------
parse_aa_str ()
{
  local __a=$1; shift || return $?
  case $__a in
  (+*) __a=${__a: 1};
       [[ $__a != a ]] && local -A a=("${(@Pkv)__a}");;
  (*)  [[ $__a != a ]] && local -A a=(); set -A $__a;
  esac
  local ksep='=' krm='-'
  local k= v=
  for v in "$@"
  do
    for v in ${=v}
    do
      case $v in
      ($krm) a=();;
      (*$ksep*) k=${v%%$ksep*} v=${v#*$ksep}
                a[$k]="$v";;
      (*) unset "a[$k]";;
      esac
    done
  done
  [[ $__a != a ]] && set -A $__a "${(@kv)a}"
  return 0
}
# ----------------------------------------------------------------------
unparse_aa_str ()
{
  local __s=$1; shift || return $?
  [[ $__s != buf ]] && local buf=
  local -A A=()
  for k v in "$@"
  do
    A[$k]="$v"
  done
  buf=()
  for k in ${(ok)A}
  do
    buf+=("$k=$A[$k]")
  done
  : ${(P)__s::="$buf"}
  return 0
}
# ----------------------------------------------------------------------
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
# ----------------------------------------------------------------------
# separate_str PATTERN P N STRING
#   a+b   P=a N=+b
#   a     P=a N=
#   +b    P=  N=+b
separate_str ()
{
  local nopfx=
  [[ $1 == -x ]] && nopfx=T && shift
  local sep=$1; shift || return $?
  local __p=$1 __n=$2; shift 2 || return $?
  local str="$1"
  : ${(P)__p::=${str%%[$sep]*}}
  str=${(M)str%%[$sep]*}
  [[ -n $nopfx ]] && str="${str#[$sep]}"
  : ${(P)__n::="$str"}
  return 0
}
# ----------------------------------------------------------------------
show_gset ()
{
  local _gset=$1; shift || return $?
  [[ $_gset != GSET ]] && local -A GSET "${(@kv)_gset}"
  local fsep=$SEP[f] psep=$SEP[p] rsep=$SEP[r]
  local gk= fk= gr= gp= pk= xk=
  local popts=(-u2)
  for gk in ${(n)GSET[(I)[0-9]*$fsep]}
  do
    print $popts - "$gk $GSET[${gk}T] $GSET[${gk}u]"
    print $popts - "\t kf:  $GSET[${gk}kf]"
    print $popts - "\t kl:  $GSET[${gk}kl]"
    print $popts - "\t pen: $GSET[${gk}pen]"
    print $popts - "\t sym: $GSET[${gk}sym]"
    for fk in ${(n)GSET[(I)${gk}[0-9]*]}
    do
      print $popts - "\t $fk $GSET[$fk]"
    done
  done
  local PK=()
  for gk in ${GSET[(I)*$psep*]}
  do
    gr=${${gk%%$psep*}%%$fsep*}
    PK+=("$gr")
  done
  PK=("${(@u)PK}")
  local GKS=() GKL=()
  for gr in "${(@o)PK}"
  do
    gk=$gr$psep
    if [[ -z $GSET[(I)$gk?*] && -z $GSET[(I)$gr$fsep*$psep*] ]]; then
      GKS+=("$gr={$GSET[$gk]}")
    else
      GKL+=($gk)
    fi
  done
  print $popts - "List: $GKS"
  for gk in $GKL
  do
    gr=${gk%$psep}
    print $popts -n - "List: $gr={$GSET[$gk]}"
    for gp in $GSET[(I)$gk?*] $GSET[(I)$gr$fsep*$psep*]
    do
      pk=${gp#$gr}
      print $popts -n " $pk={$GSET[$gp]}"
    done
    print $popts -
  done
  for gk in ${(o)GSET[(I)Rl$fsep*]}
  do
    xk=$fsep${gk##*$fsep}
    print $popts - "R$xk ($GSET[Rlog$xk]) {$GSET[Rl$xk]} {$GSET[Ru$xk]}"
  done

  for gk in ${(o)GSET[(I)[^0-9]*]}
  do
    [[ $gk[(I)$psep] -gt 0 ]] && continue
    [[ $gk[(I)$fsep] -gt 1 ]] && continue
    print $popts - "Others: $gk $GSET[$gk]"
  done

  return 0
}
# ----------------------------------------------------------------------
# diag [OPTION] VAR
diag ()
{
  local vt= pfx= color= kpat='*' compact=
  local popts=() func=() proc=()
  while [[ $# -gt 0 ]]
  do
    case $1 in
    (-c)   compact=T;;
    (-k)   kpat="$2"; shift;;
    (-u*)  popts+=("$1");;
    (-l)   popts+=("$1");;
    (-P)   popts+=("$1") color=T;;
    (-p)   pfx+="$2"; shift;;
    (+p)   proc=$functrace[1]
           func=${funcfiletrace[1]##*:}
           pfx="$proc:$func"
           ;;
    (*)    break;;
    esac
    shift
  done
  local _v= _k=
  local cpb= cpe= cvb= cve= ckb= cke=
  local line=()
  [[ -n $color ]] && cvb='%B%F{cyan}' cve='%f%b' ckb='%B%F{#aaff33}' cke='%f%b' \
                     cpb='%B%F{black}%K{white}' cpe='%k%f%b'
  pfx="$cpb$pfx$cpe"
  local vpfx= kpfx=
  for _v in "$@"
  do
    vt=${(tP)_v}
    vpfx=${cvb}${_v}${cve}
    case $vt in
    (association*)
      local -A _A=()
      set -A _A "${(@kvP)_v}"
      if [[ -z $compact ]]; then
        for _k in "${(@ok)_A[(I)$kpat]}"
        do
          print $popts - "${pfx} ${vpfx}[${ckb}$_k${cke}]=${(q-)_A[$_k]}"
        done
      else
        line=()
        for _k in "${(@ok)_A[(I)$kpat]}"
        do
          line+=("[${ckb}$_k${cke}]=${(q-)_A[$_k]}")
        done
        kpfx=
        [[ $kpat != '*' ]] && kpfx="[${ckb}$kpat${cke}]"
        print $popts - "${pfx} $vpfx$kpfx=($line)"
      fi
      ;;
    (array*)
      local _a=()
      set -A _a "${(@P)_v}"
      print $popts - "${pfx} ${cvb}${_v}${cve}=(${(q-@)_a})"
      ;;
    (*)
      local _a="${(P)_v}"
      print $popts - "${pfx}:$vt ${cvb}${_v}${cve}=${(q-)_a}"
      ;;
    esac
  done
  return 0
}
# ----------------------------------------------------------------------
logmsg ()
{
  local tag= ci= co= elev=0
  local vlev=$OPTS[verbose]
  while [[ $# -gt 0 ]]
  do
    case $1 in
    (-d)  elev=-1 tag="detail"   ci='%B%F{magenta}' co='%b%f';;
    (-n)  elev=0  tag="normal"   ci='%B%F{green}'   co='%b%f';;
    (-w)  elev=1  tag="warning"  ci='%B%F{yellow}'  co='%b%f';;
    (-e)  elev=2  tag="error"    ci='%B%F{red}'     co='%b%f';;
    (-c)  elev=4  tag="critical" ci='%B%F{red}'     co='%b%f';;
    (-f)  elev=8  tag="fatal"    ci='%B%F{red}'     co='%b%f';;
    (-l)  elev=1  tag="mark"     ci='%B%F{green}'   co='%b%f'  vlev=0;;
    (-L)  elev=$2; shift;;
    (-L*) elev=${2: 2};;
    (+L)  elev=$((elev+$2)); shift;;
    (+L*) elev=$((elev+${2: 2}));;
    (*)   break;;
    esac
    shift
  done
  local err=0
  if [[ $vlev -lt $elev ]]; then
    local TAB='	'
    local pi='%B' po='%b'
    local li='%U' lo='%u'
    local func=(${(s/:/)funcfiletrace[1]})
    local proc=(${(s/:/)functrace[1]})
    [[ $func[1] == $this ]] && shift func
    local line="$proc[2]/${(j/:/)func}"
    print -P -u2 - "${ci}${tag}${co}:${pi}$proc[1]${po}:${li}${line}${lo}: $*"
    if [[ $elev -gt 1 ]]; then
      local f= s= l= t=
      for f s in ${funcfiletrace:^functrace}
      do
        l=${f##*:}; t=${f%:*}
        format_trace f $f
        format_trace s $s
        print -P -n - "$f$TAB$s$TAB"
        sed -n -e "${l}s/^ *//p" $t
      done | column -t -s"$TAB" >&2
      diag_debug
    fi
  fi
  return $err
}
format_trace ()
{
  local __f=$1; shift
  local trace=("${(@s/:/)1}")
  trace="${pi}$trace[1]${po}:${li}${(j/:/)trace[2,-1]}${lo}"
  : ${(P)__f::="$trace"}
  return 0
}
diag_debug ()
{
  local p= j= k=
  diag -c -P OPTS
  for p in ${(n)XSET[(I)*:]}
  do
    diag -c -P -k "$p*" XSET
    # diag -c -P -k "${p: :-1}+*" XSET
  done
  for p in ${(n)VSET[(I)*+]}
  do
    diag -c -P -k "${p}*" VSET
  done
  show_gset GSET
  # diag -c -P -k '?' GSET
  # diag -c -P -k '*+*' GSET
  # diag -c -P -k ':*' GSET
  # diag -c -P -k '*.*' GSET
  # j=0
  # while true
  # do
  #   p=${j}:
  #   [[ -z $GSET[(i)$p*] ]] && break
  #   diag -c -P -k "$p*" GSET
  #   let j++
  # done
  return 0
}
# ----------------------------------------------------------------------
TRAPEXIT ()
{
  local err=$?
  # print - "Exit"
  # diag -c -P funcsourcetrace
  # diag -c -P funcfiletrace
  # diag -c -P functrace
  # diag -c -P funcstack
  print "Done ($err)."
  return $err
}
# ----------------------------------------------------------------------


this=$0
zwc=$this.zwc
err=0

[[ ! $zwc -nt $this ]] && logmsg -w "compile $this" && (zcompile -U $this; err=$?)
if [[ $err -eq 0 ]]; then
  main "$@"; err=$?
fi
[[ -n $prof ]] && print - 'ZPROF' && zprof
if [[ $err -ne 0 ]]; then
  print -u2 - "ERROR:$err:  $this ${(q-)@}"
fi
exit $err
