dnl Filename:  abt_var_define_check.m4
dnl Maintainer: SAITO Fuyuki
dnl Created: May 15 2009
dnl Time-stamp: <2020/09/14 08:43:02 fuyuki abt_var_define_check.m4>
dnl Package: IcIES-2
dnl
dnl Copyright: 2009--2020 JAMSTEC
dnl Licensed under the Apache License, Version 2.0
dnl   (https://www.apache.org/licenses/LICENSE-2.0)
dnl

# ABT_VAR_DEFINE_CHECK(VARIABLE, VALUE, VAR-RESULT, COMMENT-FOR-DEFINE[, QUOTE-KIND])
# -----------------------------------------------------------------------------------
AC_DEFUN([ABT_VAR_DEFINE_CHECK],
[_$0(AS_TR_CPP([$1]),
     [$2],
     m4_default(AS_TR_SH([$3]), [abt_tmp]),
     [$4],
     m4_default([$5], [raw]))])# ABT_VAR_DEFINE_CHECK

# _ABT_VAR_DEFINE_CHECK(VARIABLE, VALUE, VAR-RESULT, COMMENT-FOR-DEFINE, QUOTE-KIND)
# ----------------------------------------------------------------------------------
AC_DEFUN([_ABT_VAR_DEFINE_CHECK],
[dnl
AS_IF([test x"$[]$1" = x], [$1="$2"])
AS_IF([test x"$[]$1" = xyes -o x"$[]$1" = xyes-force],
      [$3=1],
      [AS_IF([test x"$[]$1" = xno -o x"$[]$1" = xno-force],
             [$3=],
             [$3="$[]$1]")])
AS_IF([test x"$[]$3" = x],
      [],
      [AC_DEFINE_UNQUOTED([$1], [_ABT_VAR_DEFINE_QUOTE([$5], [$3])], m4_quote($4))])])# _ABT_VAR_DEFINE_CHECK

# _ABT_VAR_DEFINE_QUOTE(QUOTE-KIND, VAR)
# --------------------------------------
AC_DEFUN([_ABT_VAR_DEFINE_QUOTE],
[m4_case([$1],
         [sq], ['$[]$2'],
         [dq], ["$[]$2"],
         [$[]$2])])# _ABT_VAR_DEFINE_QUOTE

dnl Local Variables:
dnl mode: autoconf
dnl End:
