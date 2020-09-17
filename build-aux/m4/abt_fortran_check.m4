dnl Filename:  abt_fortran_function.m4
dnl Maintainer: SAITO Fuyuki
dnl Created: Feb 24 2009
dnl Time-stamp: <2020/09/14 08:42:22 fuyuki abt_fortran_check.m4>
dnl Package: IcIES-2
dnl
dnl Copyright: 2009--2020 JAMSTEC
dnl Licensed under the Apache License, Version 2.0
dnl   (https://www.apache.org/licenses/LICENSE-2.0)
dnl
dnl User level
dnl   ABT_FORTRAN_CHECK_FUNCTION(function, return, arguments[, dialect])
dnl   ABT_FORTRAN_CHECK_SUBROUTINE(subroutine, arguments[, dialect])
dnl

dnl Macro prefix depends on language
dnl   NEED_DECLARE_lang-prefix_function
dnl   HAVE_lang-prefix_function

# ABT_FORTRAN_CHECK_FUNCTION(FUNCTION, ARGUMENTS, PROLOGUE[, DIALECT])
# --------------------------------------------------------------------
# user function
AC_DEFUN([ABT_FORTRAN_CHECK_FUNCTION],
[ABT_FORTRAN_CHECK([$1],
                   [intrinsic $1
       $3],
                   [WRITE (*,*) $1 ($2)],
                   [CHECK],
                   [ABT_FORTRAN_DIALECT($4)])])# ABT_FORTRAN_CHECK_FUNCTION

# ABT_FORTRAN_CHECK_SUBROUTINE(SUBROUTINE, ARGUMENTS, PROLOGUE[, DIALECT])
# ------------------------------------------------------------------------
# user function
AC_DEFUN([ABT_FORTRAN_CHECK_SUBROUTINE],
[ABT_FORTRAN_CHECK([$1],
                   [$3],
                   [CALL $1 ($2)],
                   [],
                   [ABT_FORTRAN_DIALECT($4)])])# ABT_FORTRAN_CHECK_SUBROUTINE

# ABT_FORTRAN_CHECK_STATEMENT_SPECIFIER(STATEMENT, SPECIFIER, ARGUMENTS, OTHERS, PROLOGUE[, DIALECT])
# ---------------------------------------------------------------------------------------------------
# user function
AC_DEFUN([ABT_FORTRAN_CHECK_STATEMENT_SPECIFIER],
[ABT_FORTRAN_CHECK([$1_$2],
                   [$5],
                   [$1 ($2 = $3, $4)],
                   [],
                   [ABT_FORTRAN_DIALECT($6)])])# ABT_FORTRAN_CHECK_FUNCTION

# ABT_FORTRAN_CHECK_DECL(NAME, PROLOGUE[, DIALECT])
# -------------------------------------------------
# user function
AC_DEFUN([ABT_FORTRAN_CHECK_DECL],
[ABT_FORTRAN_CHECK([DECL_$1],
                   [$2],
                   [write (*,*) $1],
                   [],
                   [ABT_FORTRAN_DIALECT($3)])])# ABT_FORTRAN_CHECK_DECL

# ABT_FORTRAN_CHECK_MPI_DECL(NAME, PROLOGUE[, DIALECT])
# -----------------------------------------------------
# user function
AC_DEFUN([ABT_FORTRAN_CHECK_MPI_DECL],
[ABT_FORTRAN_CHECK_DECL([$1],
[implicit none
       include 'mpif.h'
       $2],
[$3])])# ABT_FORTRAN_CHECK_MPI_DECL

# ABT_FORTRAN_CHECK_MODULE_INTERFACE(MODULE, NAME, PROLOGUE[, DIALECT])
# ---------------------------------------------------------------------
AC_DEFUN([ABT_FORTRAN_CHECK_MODULE_INTERFACE],
[ABT_FORTRAN_CHECK([$1_$2],
                   [use $1, only: $2
      $3],
                   [continue],
                   [],
                   [ABT_FORTRAN_DIALECT($4)])])# ABT_FORTRAN_CHECK_MODULE_INTERFACE

dnl Internal

dnl Default language dialect
# ABT_FORTRAN_DIALECT([LANG])
# ---------------------------
# return Fortran 77 if null
AC_DEFUN([ABT_FORTRAN_DIALECT], [m4_ifval([$1], [$1], [Fortran 77])])# ABT_FORTRAN_DIALECT

# ABT_FORTRAN_CHECK
# -----------------
# sub command for prefix choice
AC_DEFUN([ABT_FORTRAN_CHECK], [_$0($@, ABT_FORTRAN_PREFIX($5))])# ABT_FORTRAN_CHECK

# ABT_FORTRAN_PREFIX(LANG)
# ------------------------
# prefix
AC_DEFUN([ABT_FORTRAN_PREFIX],[m4_indir([$0($1)])])# ABT_FORTRAN_PREFIX

# default prefix for result variables
m4_define([ABT_FORTRAN_PREFIX(Fortran 77)], [F77])
m4_define([ABT_FORTRAN_PREFIX(Fortran)], [FC])

dnl core command
# _ABT_FORTRAN_CHECK(PROCEDURE, PROLOGUE, SOURCE, DECL-CHECK, DIALECT, PREFIX)
# ----------------------------------------------------------------------------
AC_DEFUN([_ABT_FORTRAN_CHECK],[dnl
dnl Init
AC_LANG_PUSH($5)
dnl link check
AC_CACHE_CHECK([for $1 on $5],
   [abt_cv_fortran_link_$1],
   [ABT_FORTRAN_LINK_IFELSE([$2],
                            [$3],
                            [abt_cv_fortran_link_$1=yes],
                            [abt_cv_fortran_link_$1=no])])
dnl Define macros
AS_IF([test x$abt_cv_fortran_link_$1 = xyes],
      [ABT_FORTRAN_DEFINE_HAVE([$1],[$5],[$6])])
dnl declaration check
dnl use LINK instead of COMPILE (for fort77)
m4_ifval([$4],
[dnl
AS_IF([test x$abt_cv_fortran_link_$1 = xyes],
      [AC_CACHE_CHECK([whether need to declare $1 on $5],
                      [abt_cv_fortran_needdec_$1],
                      [ABT_FORTRAN_LINK_IFELSE([implicit none], [$3],
                                               [abt_cv_fortran_needdec_$1=no],
                                               [abt_cv_fortran_needdec_$1=yes])])],
      [AC_CACHE_CHECK([whether need to declare $1 on $5],
                      [abt_cv_fortran_needdec_$1],
                      [abt_cv_fortran_needdec_$1=yes])])
AS_IF([test x$abt_cv_fortran_needdec_$1 = xyes],
      [ABT_FORTRAN_DEFINE_NEED([$1],[$5],[$6])])
])[]dnl
dnl dnl Finalize
AC_LANG_POP($5)
])# _ABT_FORTRAN_CHECK

# ABT_FORTRAN_DEFINE_NEED(FUNCTION, DIALECT, PREFIX[, COMMENT])
# -------------------------------------------------------------
# define macro need_declare
AC_DEFUN([ABT_FORTRAN_DEFINE_NEED],
[ABT_VAR_DEFINE_CHECK([NEED_DECLARE_$3_$1],
                      [yes],
                      [],
                      m4_default([$4], [whether need to declare $1 on $2]))])# ABT_FORTRAN_DEFINE_NEED

# ABT_FORTRAN_DEFINE_HAVE(FUNCTION, DIALECT, PREFIX[, COMMENT])
# -------------------------------------------------------------
# define macro have
AC_DEFUN([ABT_FORTRAN_DEFINE_HAVE],
[ABT_VAR_DEFINE_CHECK([HAVE_$3_$1],
                      [yes],
                      [abt_have_$1],
                      m4_default([$4], [whether you have $1 on $2]))])# ABT_FORTRAN_DEFINE_HAVE

dnl create program source
dnl    (prologue, source)
# ABT_FORTRAN_CREATE_SOURCE
# -------------------------
AC_DEFUN([ABT_FORTRAN_CREATE_SOURCE],[dnl
C123456
      program test1
      $1
      $2
      stop
      end[]dnl
])

# ABT_FORTRAN_COMPILE_IFELSE(PROLOGUE, SOURCE, THEN-PART, ELSE-PART)
# ------------------------------------------------------------------
#  COMPILE_IFELSE wrapper
AC_DEFUN([ABT_FORTRAN_COMPILE_IFELSE],
[AC_COMPILE_IFELSE([ABT_FORTRAN_CREATE_SOURCE([$1],[$2])],
                   [$3],
                   [$4])])# ABT_FORTRAN_COMPILE_IFELSE

# ABT_FORTRAN_LINK_IFELSE(PROLOGUE, SOURCE, THEN-PART, ELSE-PART)
# ---------------------------------------------------------------
# LINK_IFELSE wrapper
AC_DEFUN([ABT_FORTRAN_LINK_IFELSE],
[AC_LINK_IFELSE([ABT_FORTRAN_CREATE_SOURCE([$1],[$2])],
                [$3],
                [$4])])# ABT_FORTRAN_LINK_IFELSE

dnl Local Variables:
dnl mode: autoconf
dnl End:
