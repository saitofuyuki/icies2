dnl Filename:   ai_init.m4
dnl Maintainer: SAITO Fuyuki
dnl Created:    Sep 16 2020
dnl Time-stamp: <2020/09/16 11:41:10 fuyuki ai_init.m4>

dnl Copyright: 2020 JAMSTEC
dnl Licensed under the Apache License, Version 2.0
dnl   (https://www.apache.org/licenses/LICENSE-2.0)

# AI_INIT([VERSION-FILE])
# -------------------------
# AI system initialization dispatcher
AC_DEFUN([AI_INIT],
[m4_pattern_forbid([^[_]?AI_])
_$0(m4_quote(m4_default([$1], aipackage.m4)))dnl
])# AI_INIT

# _AI_INIT(VERSION-FILE)
# ----------------------------------------------
AC_DEFUN([_AI_INIT],
[dnl
ai_sinclude([$1])dnl
m4_define([AI_PACKAGE], m4_quote(_AI_BASE[](_AI_STAGE)))dnl
m4_define([AI_TARNAME], m4_quote(_AI_BASE_TAR[]_[]_AI_STAGE_TAR[]))dnl
m4_define([AI_VERSION], m4_quote(_AI_VERSION))dnl
])# _AI_INIT

# AI_PACKAGE_BASE(BASENAME, [BASE TARNAME])
# ----------------------------------------------
AC_DEFUN([AI_PACKAGE_BASE],
[m4_define([_AI_BASE], [$1])dnl
m4_define([_AI_BASE_TAR], [m4_default([$2], [$1])])])# AI_PACKAGE_BASE
# AI_PACKAGE_STAGE(STAGE, [STAGE TARNAME])
# ----------------------------------------------
AC_DEFUN([AI_PACKAGE_STAGE],
[m4_define([_AI_STAGE], [$1])dnl
m4_define([_AI_STAGE_TAR], [m4_default([$2], [$1])])])# AI_PACKAGE_STAGE

# AI_PACKAGE_VERSION(VERSION, [VERSION TARNAME])
# ----------------------------------------------
AC_DEFUN([AI_PACKAGE_VERSION],
[m4_define([_AI_VERSION], [$1])dnl
m4_define([_AI_VERSION_TAR], [m4_default([$2], [$1])])])# AI_PACKAGE_VERSION

# ai_sinclude(FILE)
# ai_include(FILE)
# -----------------
# m4_sinclude m4_include wrappers
m4_define([ai_sinclude], [m4_sinclude][([$1])])
m4_define([ai_include],  [m4_include][([$1])])

dnl Local Variables:
dnl mode: autoconf
dnl end:
