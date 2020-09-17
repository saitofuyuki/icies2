#!/bin/sh
# Time-stamp: <2020/09/17 09:03:26 fuyuki xicies.sh>
#
# Copyright: 2011--2020 JAMSTEC, Ayako ABE-OUCHI
# Licensed under the Apache License, Version 2.0
#   (https://www.apache.org/licenses/LICENSE-2.0)

command="$0 $@"
where=`dirname $0`
pwd=`pwd`
create=`date +%s`
host=`uname -n`
base=`basename $0`

usage ()
{
  echo "$base -- IcIES script generator"
  echo
  echo "usage: $0 [OPTIONS] [SCR_TMPL...] -- [CFG_TMPL...] [CFG_VAR0=VAL0...]"
}


CFGPFX='## CONFIG'

## uuid assignment
for u in uuidgen uuid
do
  if type $u > /dev/null 2>&1;then
    uuid=`$u`
    break
  fi
done

test x$uuid = x && uuid=unset

## templates
tmplSdir=$where/../tmpl/sh
tmplCdir=$where/../tmpl/c

tmplH='sx8q head minor'
tmplM='out prepare'
tmplF='exec'

## option/arguments
parse_envs ()
{
  while test $# -gt 0
  do
    case $1 in
	*=*) envs="$envs $1";;
	*)   tmplC="$tmplC $1";;
    esac
    shift
  done
}

parse_tmpl ()
{
  while test $# -gt 0
  do
    if test $1 = --;then
      shift
      break
    else
      tmplS="$tmplS $1"
    fi
    shift
  done
  parse_envs "$@"
}

parse_opts ()
{
  while test $# -gt 0
  do
    case $1 in
	-h) usage >&2; exit 0;;
    -n) dry=$1;;
    -o) out=$2; shift;;
    -f) ovw=$1;;
    -s) tmplS="$tmplS head minor prepare exec";;
    -t) tmplS="$tmplS head minor prepare";;
    -c) tmplC="$tmplC g.minimum g.default x.standard o.default o.rdefault o.ldefault o.vdefault o.gdefault o.pdefault";;
    --) break;;
    -*) : ;;
  	*)  break
  	esac
  	shift
  done
  parse_tmpl $@
}

parse_opts $@

## configuration templates
if test x"$tmplC" = x;then
  tmplC='g.default o.default'
fi

## output manager
if test x$out = x;then
  :
elif test -f $out;then
  if test x$ovw = x; then
    echo "$0:ERROR: $out exists" >&2
    exit 1
  else
    exec > $out
    echo "$0:WARN: clobber $out" >&2
  fi
else
  exec > $out
fi

## script generator
scr_first ()
{
  echo "#!/bin/sh"
}

parse_tmpl_sh ()
{
  ## parse_tmpl_sh FILE [SED ARGUMENTS...]
  f=$1
  shift
  ##    -e '/^\(#[^#].*\)## *$/{s//\1/;p;n}'
  sed -n \
	  -e '/^#[^#]/d' \
	  -e '/^#$/d' \
	  -e '/^## *FINE *$/q' \
	  -e '/^## #/s//#/' \
	  -e "s,@SOURCE\@,$f," \
	  -e "s,@CREATE\@,$create," \
	  -e "s,@COMMAND\@,$command," \
	  -e "s,@PWD\@,$pwd," \
	  -e "s,@UUID\@,$uuid," \
	  -e "s,@HOST\@,$host," \
	  -e "s,@IFMDIR\@,$IFMDIR," \
	  -e "s,@SYSTEM\@,$SYSTEM," \
	  "$@" \
	  -e 'p' \
	  $f
}

expand_tmpl_sh ()
{
  for i
  do
    if echo "$tmplS" | grep -q "\\<$i\\>";then
      for d in . $tmplSdir
	  do
        f=$d/$i	
		if test -f $f;then
		  parse_tmpl_sh $f
		  break
		fi
	  done
	fi
  done
}


parse_envs ()
{
  echo "$i"
}

expand_envs ()
{
  echo "$CFGPFX 0 default"
  for i
  do
    parse_envs "$i"
  done
  echo "$CFGPFX -"
}

aWa='@\([A-Za-z_0-9]*\)@'
sep=' *## *'
re="^.*${aWa}.*${sep}\(.*[^ ]\)${sep}\(.*\)\$"

find_tmplC ()
{
  in=
  i=$1
  if test -f $i;then
    in=$i
  else
    for d in . $tmplCdir
	do
      f=$d/$i	
	  if test -f $f;then
		in=$f
		break
	  fi
	done
  fi
  echo "# $i ($in)"
}

parse_config_default ()
{
  test x$1 = x || \
    sed -n -e "/$re/s//: \${\\1:=\\2} ## \\3/p" $1
}

expand_config_default ()
{
  for i
  do
    find_tmplC $i
    parse_config_default $in
  done
}

parse_tmpl_config ()
{
  test x$1 = x || \
    sed -e '/^#[^#]/d' -e "/$aWa/s//\$\1/g" $1
}

expand_tmpl_config ()
{
  id=SYSIN
  echo "cat <<$id | sed -e '/^#/d' -e 's/##.*$//' > \$sysin"
  echo " &NIUUID ORIG = '$uuid' &END"
  echo " &NIUUID UUID = '\$uuid' &END"
  for i
  do
    find_tmplC $i
    parse_tmpl_config $in
  done
  echo "$id"
}

section ()
{
  echo "#### section $@"
}

scr_first
set - $tmplH; expand_tmpl_sh        "$@"; echo
section user configuration by arguments
set - $envs;  expand_envs           "$@"; echo
section default configuration if empty
set - $tmplC; expand_config_default "$@"; echo
section preparation
set - $tmplM; expand_tmpl_sh        "$@"; echo
section sysin 
set - $tmplC; expand_tmpl_config    "$@"; echo
section exec
set - $tmplF; expand_tmpl_sh        "$@"

exit 0
