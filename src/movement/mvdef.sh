#!/usr/bin/zsh -f
# Maintainer:  SAITO Fuyuki
# Time-stamp: <2020/09/15 12:24:31 fuyuki mvdef.sh>
# Copyright: 2013--2020 JAMSTEC, Ayako ABE-OUCHI
# Licensed under the Apache License, Version 2.0
#   (https://www.apache.org/licenses/LICENSE-2.0)

m4inc=$0:r.m4
m4src=$0:h/movement.m4

autom4te -l m4sugar $m4inc $m4src
