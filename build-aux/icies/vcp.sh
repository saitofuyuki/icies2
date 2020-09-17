#!/usr/bin/zsh -f
# Time-stamp: <2020/09/17 09:43:17 fuyuki vcp.sh>
# Copyright: 2019--2020 JAMSTEC
# Licensed under the Apache License, Version 2.0
#   (https://www.apache.org/licenses/LICENSE-2.0)

thisx=$0 thisb=$0:t thisd=$0:h

main ()
{
  local m4f=()
  local var=()
  local src=
  local sqi=$thisd/sqihelp

  while [[ $# -gt 0 ]]
  do
    case $1 in
    (-m)  m4f+=($2); shift;;
    (-v)  var+=(${(s/:/)2}); shift;;
    (-v*) var+=(${(s/:/)${1: 2}}); shift;;
    (-*) print -u2 - "Unknown arguments $1"; help -u2; return 1;;
    (*)  break;;
    esac
    shift
  done
  if [[ x${var:--} == x- ]]; then
    [[ -z $m4f ]] && print -u2 - "Need m4 definition source(s)." && return 1
    var=($($sqi -tp $m4f))
    var=(${(u)var})
  fi

  for src in "$@"
  do
    parse_source $src "${(@)var}" || return $?
  done
}

help ()
{
  local pargs=($@)
  print "${(@)pargs}" - "$thisx - variable cluster simple parser"
  return 0
}

parse_source ()
{
  local src=$1; shift || return $?
  local var=
  local entries=()
  for var in $@
  do
    entries=($(sed -e '/^[Cc*!]/d' $src | grep -E -o "\<${var}_\w+\>"))
    entries=(${(u)entries})
    print - "${src}:$var  $entries"
  done
  return 0
}

main "$@"; err=$?
exit $?
