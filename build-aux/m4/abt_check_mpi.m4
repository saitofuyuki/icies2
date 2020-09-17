dnl Filename:  abt_check_mpi.m4
dnl Maintainer: SAITO Fuyuki
dnl Created: May 30 2016
dnl Time-stamp: <2020/09/14 08:41:53 fuyuki abt_check_mpi.m4>
dnl Package: IcIES-2
dnl
dnl Copyright: 2016--2020 JAMSTEC
dnl Licensed under the Apache License, Version 2.0
dnl   (https://www.apache.org/licenses/LICENSE-2.0)
dnl

# ABT_CHECK_MPI
# -------------
AC_DEFUN([ABT_CHECK_MPI],
[dnl
AC_PATH_PROGS([MPIEXEC], [mpiexec], [:])
ABT_CACHE_CHECK_MPI_TYPE()
])# ABT_CHECK_MPI

# ABT_CACHE_CHECK_MPI_TYPE
# ------------------------
AC_DEFUN([ABT_CACHE_CHECK_MPI_TYPE],
[AC_CACHE_CHECK([mpi implementation],
[abt_cv_mpi_type],
[abt_cv_mpi_type=no
AS_IF([test $MPIEXEC = :],
      [:],
      [AS_IF([$MPIEXEC --version | sed -n -e 1p | grep --silent -e 'Open MPI' -e 'OpenRTE'],
             [abt_cv_mpi_type=openmpi])])
AS_IF([test "x$abt_cv_mpi_type" = xno],
      [:],
      [MPITYPE=$abt_cv_mpi_type])
])
AC_SUBST([MPITYPE])])# ABT_CACHE_CHECK_MPI_TYPE

dnl AC_DEFUN([ABT_CHECK_MPI_TYPE],
dnl [dnl
dnl # MPITYPE=
dnl if test $MPIEXEC = :; then :;
dnl else
dnl    if $MPIEXEC --version | sed -n -e 1p | grep --silent -e 'Open MPI' -e 'OpenRTE'; then
dnl       MPITYPE=openmpi
dnl    fi
dnl fi
dnl AC_SUBST([MPITYPE])
dnl ])

dnl Local Variables:
dnl mode: autoconf
dnl end:
