dnl movement/movement.m4 --- Template for Definition for IcIES/Movement modules
dnl Maintainer:  SAITO Fuyuki
dnl Created: Sep 5 2012
dnl Copyright: 2012--2020 JAMSTEC, Ayako ABE-OUCHI
dnl Licensed under the Apache License, Version 2.0
dnl   (https://www.apache.org/licenses/LICENSE-2.0)
m4_divert(KILL)dnl
dnl --------------------------------------------------------------------------------
dnl _cpp_comment(DESCRIPTION, OPERATION)
m4_define([_m4_divert(VDEF)],  123)

m4_define([_cpp_comment], [])
m4_define([cpp_comment],  [])
dnl cpp_define(MACRO, VALUE, DESCRIPTION)
m4_define([cpp_define],   [])

m4_define([c_reset],
[m4_define([_counter], [0])dnl
m4_ifval([$1], [m4_define([_prefix], [$1_])], [m4_define([_prefix], [])])dnl
m4_divert_push([VDEF])dnl

C PREFIX: m4_default([$1], [NONE])
m4_divert_pop([VDEF])dnl
])

m4_define([coor2id],
[m4_case([$1], [a], [1],
               [b], [2],
               [c], [3],
               [d], [4],
               [za], [1],
               [zb], [2],
               [aa], [1],
               [ba], [2],
               [ca], [3],
               [1])])

m4_define([cnamedef], [m4_default([$1], [$2])])

dnl c_xincr([SFX], [COMMENT], [VAR], [COOR], [PFX])
m4_define([_c_xincr],
[m4_divert_push([VDEF])dnl
dnl $5      m4_format([%-15s], icG (_prefix[]$1)) = icGi (coor2id([$4]))
dnl $5      m4_format([%-15s], vNM (_prefix[]$1)) = 'cnamedef([$3], [$1])'
$5      call AFBrgi (iErr, idVG, m4_format([%-10s], _prefix[]$1[,]) icG (coor2id([$4])), 'cnamedef([$3], [$1])')
m4_divert_pop()dnl])

m4_define([c_xincr], [_$0([m4_car($1)], [$2], [$3], [$4], [$5])])

m4_define([c_xkeep], [c_xincr([$1], [$2], [$3], [$4], CC)])

dnl --------------------------------------------------------------------------------
dnl Local Variables:
dnl mode: autoconf
dnl End:
