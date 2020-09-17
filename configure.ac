# Process this file with autoconf to produce a configure script.
#
# Maintainer: SAITO Fuyuki
# Created: Nov 2 2011
# Revision: JosePeterson0
# Time-stamp: <2020/09/16 11:55:25 fuyuki configure.ac>

dnl _. health check
m4_ifndef([ABT_INIT],
          [m4_fatal([Properly install/configure package ABT.])])
ABT_INIT()

dnl _. icies setup for autoconf
AI_INIT()

dnl _. autoconf

dnl _ , autoconf initialization
AC_PREREQ([2.68])
AC_INIT(AI_PACKAGE, AI_VERSION, [saitofuyuki@jamstec.go.jp], AI_TARNAME)

dnl _ , notice
AC_COPYRIGHT([dnl
Copyright (C) 2011--2020 Japan Agency for Marine-Earth Science and Technology
                         Ayako ABE-OUCHI

Ice sheet model for Integrated Earth system Studies-II (IcIES-2) is developed by
Japan Agency for Marine-Earth Science and Technology (JAMSTEC) and
Atmosphere and Ocean Research Institute, University of Tokyo, Japan (AORI).

Licensed under the Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)
])

AC_REVISION(m4_quote(AI_PACKAGE AI_VERSION))

dnl _ , directories
AC_CONFIG_SRCDIR([src/unison/utmplm.F])
AC_CONFIG_AUX_DIR([build-aux])
AC_CONFIG_MACRO_DIR([build-aux/m4])

dnl _ , canonical
AC_CANONICAL_BUILD
AC_CANONICAL_HOST
AC_CANONICAL_TARGET

dnl _ , prefix
AC_PREFIX_DEFAULT([$PWD/local])

dnl _. automake
AM_INIT_AUTOMAKE([-Wall foreign])
AM_MAINTAINER_MODE

AM_CONDITIONAL([NEVER], [false])
dnl AX_AM_MACROS

dnl _. compilers
AC_PROG_CC
dnl _. preprocessor
AC_PROG_CPP

dnl AC_LANG(Preprocessed Fortran 77)

dnl AC_PROG_F77

dnl _ , mpi

dnl _  . option
AC_ARG_WITH(mpi,
[AS_HELP_STRING([--with-mpi],
[compile with MPI (parallelization) support. If none is found,
MPI is not used. Default: auto])
],,
[with_mpi=auto])

AC_ARG_WITH(petsc,
[AS_HELP_STRING([--with-petsc],
[compile with PETSc support. Default: none])],,
[with_petsc=no])

AS_IF([test "x$with_petsc" = xyes],
      [AC_DEFINE([WITH_PETSC], [1], [Define if you use PETSc])])

dnl _  . result
AX_PROG_F77_MPI([test x"$with_mpi" != xno],
[use_mpi=yes],
[use_mpi=no
if test x"$with_mpi" = xyes; then
  AC_MSG_FAILURE([MPI compiler requested, but couldn't use MPI.])
else
  AC_MSG_WARN([No MPI compiler found, won't use MPI.])
fi
])
AS_IF([test "x$use_mpi" = xyes],
      [AC_DEFINE([OPT_USE_MPI], [1], [Define if you use mpi])])

dnl _ , (discarded) direct compilation (.F to .o or .F to .f to .o)

dnl AC_PROG_FC
dnl   _AM_DEPENDENCIES([CC])
dnl AC_PROG_FPP

dnl _ , cpp concatenation on fortran source
dnl     not easy to write the test
dnl     need use gcc -x c -E to activate ## on fortran files

AC_ARG_ENABLE(cpp-concatenation,
[AS_HELP_STRING([--enable-cpp-concatenation],
[use @%:@@%:@ @<:@default=no@:>@])],
[],
[enable_cpp_concatenation=no])
AS_IF([test "x$enable_cpp_concatenation" = xyes],
      [AC_DEFINE([HAVE_CPP_F_CONCATENATION], [1], [Define if @%:@@%:@ is accepted])])


dnl _ , clock
AC_ARG_ENABLE(clock,
[AS_HELP_STRING([--enable-clock],
[clock information (need explicit kind)@<:@default=no@:>@])],
[],
[enable_clock=no])
AS_IF([test "x$enable_clock" = xyes], [enable_clock=none])
AS_IF([test "x$enable_clock" = xno],  [enable_clock=none])

clock_kind=AS_TR_CPP([$enable_clock])
AC_DEFINE_UNQUOTED([OPT_USE_CLOCK], [_CLOCK_$clock_kind], [clock information])

dnl _ , fortran check

dnl _  . standards
AC_ARG_ENABLE(fortran-standard,
[AS_HELP_STRING([--enable-fortran-standard],
[which fortran features are used@<:@default=95@:>@])],
[],
[enable_fortran_standard=95])
AS_IF([test "x$enable_fortran_standard" = xyes],
      [enable_fortran_standard=95])

dnl _  . standards
AC_ARG_ENABLE(gnu-extension,
[AS_HELP_STRING([--enable-gnu-extension],
[force enable/disable fortran gnu-extension])],
[],
[enable_gnu_extension=null])

AS_IF([test "x$enable_gnu_extension" = xyes],
      [AC_DEFINE([_FORTRAN_GNU_EXTENSION], [1], [whether use GNU extesion])])
AS_IF([test "x$enable_gnu_extension" = xno],
      [AC_DEFINE([_FORTRAN_GNU_EXTENSION], [0], [whether use GNU extesion])])

dnl _  . whether or not check
AC_ARG_ENABLE(fortran-check,
[AS_HELP_STRING([--enable-fortran-check],
[check fortran functions and subroutines@<:@default=yes@:>@])],
[],
[enable_fortran_check=yes])

dnl _  . intrisic procedures
AS_IF([test "x$enable_fortran_check" = xyes],
[dnl
ABT_FORTRAN_CHECK_SUBROUTINE([getenv],   [' ', A], [character A*(30)])

ABT_FORTRAN_CHECK_SUBROUTINE([get_environment_variable],
                                         [' ', A], [character A*(30)])
dnl gnu
ABT_FORTRAN_CHECK_SUBROUTINE([etime],    [V, T],   [real V (2), T])
dnl gnu
ABT_FORTRAN_CHECK_SUBROUTINE([ttynam],   [1,   A], [character A*(30)])

ABT_FORTRAN_CHECK_SUBROUTINE([cpu_time], [T],      [real T])
ABT_FORTRAN_CHECK_SUBROUTINE([get_command],
                                         [A],      [character A*(30)])
ABT_FORTRAN_CHECK_SUBROUTINE([get_command_argument],
                                         [1, A],   [character A*(30)])

ABT_FORTRAN_CHECK_FUNCTION([dummy_none], [999],     [])

ABT_FORTRAN_CHECK_FUNCTION([len_trim], [' '],     [])
ABT_FORTRAN_CHECK_FUNCTION([adjustl],  [' '],     [])
ABT_FORTRAN_CHECK_FUNCTION([adjustr],  [' '],     [])
ABT_FORTRAN_CHECK_FUNCTION([floor],    [1.0d0],   [])
ABT_FORTRAN_CHECK_FUNCTION([ichar],    [' '],     [])
ABT_FORTRAN_CHECK_FUNCTION([iachar],   [' '],     [])
ABT_FORTRAN_CHECK_FUNCTION([trim],     [' '],     [])
ABT_FORTRAN_CHECK_FUNCTION([verify],   [' ',' '], [])
ABT_FORTRAN_CHECK_FUNCTION([scan],     [' ',' '], [])
ABT_FORTRAN_CHECK_FUNCTION([isnan],    [1.0d0],   [])

dnl 2003
ABT_FORTRAN_CHECK_FUNCTION([is_iostat_end], [1],  [])

dnl gnu
ABT_FORTRAN_CHECK_FUNCTION([isatty],   [1],       [])

ABT_FORTRAN_CHECK_FUNCTION([command_argument_count],  [],   [])

ABT_FORTRAN_CHECK_STATEMENT_SPECIFIER([inquire], [convert], [T], [UNIT=1], [character T*(30)])
])

AS_IF([test "x$use_mpi" = xyes],
      [ABT_FORTRAN_CHECK_MPI_DECL([MPI_MAX_OBJECT_NAME])])

AC_DEFINE_UNQUOTED([HAVE_FORTRAN_STANDARD], [$enable_fortran_standard], [Define which fortran features are used])

dnl ABT_FORTRAN_CHECK_SUBROUTINE([flush], [A], [integer A])
dnl ABT_FORTRAN_CHECK_SUBROUTINE([getlog], [A], [character A*(30)])
dnl ABT_FORTRAN_CHECK_SUBROUTINE([date_and_time], [A], [character A*(30)])
dnl ABT_FORTRAN_CHECK_SUBROUTINE([hostnm], [A], [character A*(30)])
dnl HAVE_F90_BIT_FUNCTIONS

dnl _. libtools
AM_PROG_AR

LT_PREREQ([2.4.2])
LT_INIT([disable-shared])

dnl LT_LANG(Fortran 77)

dnl _. commands

AC_PROG_AWK
AC_PROG_LN_S
dnl AC_PROG_RANLIB
AC_PROG_MAKE_SET

AC_PATH_PROGS(GIT,     [git])
AC_PATH_PROGS(SED,     [sed])
AC_PATH_PROGS(CP,      [cp],      :)
AC_PATH_PROGS(FTNCHEK, [ftnchek], :)
AC_PATH_PROGS(GPROF,   [gprof],   :)

AC_PATH_PROGS(ZSH,     [zsh])
AC_PATH_PROGS(MPIEXEC, [mpiexec])

AC_PATH_PROGS(AUTOM4TE, [autom4te])

AC_PATH_PROGS(UUID,     [uuid])
AC_PATH_PROGS(UUIDGEN,  [uuidgen])
AC_PATH_PROGS(UUIDCDEF, [uuidcdef])

AC_PATH_PROGS(GMT,     [GMT gmt])
AC_PATH_PROGS(GMTMATH, [gmtmath])
AC_PATH_PROGS(DC,      [dc])

AC_PATH_PROGS(RST2PDF,   [rst2pdf])
AC_PATH_PROGS(RST2LATEX, [rst2latex])
AC_PATH_PROGS(RST2HTML,  [rst2html])

AS_IF([test "x$UUID" != x],
      [AC_SUBST([UUIDCOM], [$UUID])
       AC_SUBST([UUIDFLAGS], [])],
      [AS_IF([test "x$UUIDGEN" != x],
             [AC_SUBST([UUIDCOM], [$UUIDGEN])
              AC_SUBST([UUIDFLAGS], [])],
             [AS_IF([test "x$UUIDCDEF" != x],
                    [AC_SUBST([UUIDCOM], [$UUIDCDEF])
                     AC_SUBST([UUIDFLAGS], [-u])],
                    [AC_SUBST([UUIDCOM], [echo])
                     AC_SUBST([UUIDFLAGS], [00000000-0000-0000-0000-000000000000])])])])

ABT_CHECK_MPI()

dnl _. icies options
dnl _ , embedded-profiler

AC_ARG_ENABLE([embedded-profiler],
[AS_HELP_STRING([--enable-embedded-profiler],
[whether or not use embedded-profiler (yes/no/level)@<:@default=no@:>@])],
[],
[enable_embedded_profiler=no])

AS_IF([test "x$enable_embedded_profiler" = xyes], [enable_embedded_profiler=10])
AS_IF([test "x$enable_embedded_profiler" = xno],  [enable_embedded_profiler=0])

AC_DEFINE_UNQUOTED([OPT_DEV_PROFILER], [$enable_embedded_profiler], [embedded profile level])

dnl _. Results
AC_CONFIG_HEADER([config.h])

AC_CONFIG_FILES([Makefile
                 doc/Makefile
                 doc/r/Makefile
                 etc/Makefile
                 etc/helper/Makefile
                 run/Makefile
                 src/Makefile
                 src/ostinato/Makefile
                 src/unison/Makefile
                 src/development/Makefile
                 src/arpeggio/Makefile
                 src/movement/Makefile
                 src/begleitung/Makefile
                 src/cadenza/Makefile])

dnl _. libraries
AX_CHECK_LIBRARY([NETCDF], [netcdf.h], [netcdf])

AC_ARG_VAR([NETCDFINC], [directory where nedcdf.inc exists])
AS_IF([test "x$NETCDFINC" = x], [NETCDFINC=/usr/include])

AC_SUBST([XPKG_CPPFLAGS])
AC_SUBST([XPKG_LDFLAGS])

dnl _. source check
AC_SUBST([FORTRAN_CHECK], [$FTNCHEK])
AC_SUBST([FORTRAN_LIST], [$FTNCHEK])
AC_SUBST([FORTRAN_LIST_FLAGS], ['-quiet -nocheck -reference'])

dnl _. helper
etc_helper=etc/helper
AC_SUBST([ETC_HELPER], [$etc_helper])
AC_CONFIG_COMMANDS([dummy], [:], [etc_helper=$etc_helper])

dnl _ , _AC_CONFIG_FILES_HELPER(DIST, SOURCE, ROOT)
AC_DEFUN([_AC_CONFIG_FILES_HELPER],
[AC_CONFIG_FILES([$1:$2.in], [chmod +x $1])dnl
m4_append([_HELPER_ALL], [$(top_srcdir)/$(ETC_HELPER)/$3.in], [ ])dnl
])

dnl _ , AC_CONFIG_FILES_HELPER(SCRIPT[, BOOL-TO-KEEP])
AC_DEFUN([AC_CONFIG_FILES_HELPER],
[m4_ifval([$2],
          [_$0([$etc_helper/$1], [$etc_helper/$1], [$1])],
          [_$0([$1],             [$etc_helper/$1], [$1])])])

dnl _ , zui
AC_CONFIG_FILES_HELPER([zui_insert.sh], [KEEP])
AC_CONFIG_FILES_HELPER([dev_insert.sh], [KEEP])

ZUI_INSERT=$etc_helper/zui_insert.sh
AC_SUBST_FILE([ZUI_INSERT])
DEV_INSERT=$etc_helper/dev_insert.sh
AC_SUBST_FILE([DEV_INSERT])

AC_CONFIG_FILES([src/cadenza/cnx.sh])
AC_CONFIG_FILES([run/xicies_jp.sh])

dnl _. Fine
AC_OUTPUT
