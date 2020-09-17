C ostinato/ofdlct.h --- IcIES/Ostinato Fortran dialect management
C Maintainer:  SAITO Fuyuki
C Created: Apr 23 2010
#ifdef HEADER_PROPERTY
#define _TSTAMP 'Time-stamp: <2018/12/18 08:58:50 fuyuki ofdlct.h>'
#define _FNAME 'ostinato/ofdlct.h'
#define _REV   'Snoopy0.9'
#endif /* HEADER_PROPERTY */
CCC_! MANIFESTO
C
C Copyright (C) 2010--2020
C           Japan Agency for Marine-Earth Science and Technology,
C           Ayako ABE-OUCHI
C
C Licensed under the Apache License, Version 2.0
C   (https://www.apache.org/licenses/LICENSE-2.0)
C
CCC_* Definitions
#ifndef    _OFDLCT_H
#  define  _OFDLCT_H

CCC_ + Compiler characteristics
#if __GFORTRAN__
#  ifndef   _FORTRAN_GNU_EXTENSION
#    define _FORTRAN_GNU_EXTENSION 1
#  endif
#endif
CCC_ + Default fortran standard
#ifndef    HAVE_FORTRAN_STANDARD
#  define  HAVE_FORTRAN_STANDARD 95
#endif
#ifndef   _FORTRAN_GNU_EXTENSION
#  define _FORTRAN_GNU_EXTENSION 0
#endif

CCC_ + GNU extension
#if _FORTRAN_GNU_EXTENSION
#  ifndef   HAVE_F77_FLUSH
#    define HAVE_F77_FLUSH   1
#  endif
#  ifndef   HAVE_F77_ETIME
#    define HAVE_F77_ETIME   1
#  endif
#  ifndef   HAVE_F77_ISATTY
#    define HAVE_F77_ISATTY  1
#  endif
#  ifndef   HAVE_F77_TTYNAM
#    define HAVE_F77_TTYNAM  1
#  endif
#  ifndef   HAVE_F77_INQUIRE_CONVERT
#    define HAVE_F77_INQUIRE_CONVERT 1
#  endif
#else /* not _FORTRAN_GNU_EXTENSION */
#  ifndef   HAVE_F77_FLUSH
#    define HAVE_F77_FLUSH   0
#  endif
#  ifndef   HAVE_F77_ETIME
#    define HAVE_F77_ETIME   0
#  endif
#  ifndef   HAVE_F77_ISATTY
#    define HAVE_F77_ISATTY  0
#  endif
#  ifndef   HAVE_F77_TTYNAM
#    define HAVE_F77_TTYNAM  0
#  endif
#  ifndef   HAVE_F77_INQUIRE_CONVERT
#    define HAVE_F77_INQUIRE_CONVERT 0
#  endif
#endif /* not _FORTRAN_GNU_EXTENSION */
CCC_ + 2003 and later
#if HAVE_FORTRAN_STANDARD > 2002
#  ifndef   HAVE_F77_GET_ENVIRONMENT_VARIABLE
#    define HAVE_F77_GET_ENVIRONMENT_VARIABLE   1
#  endif
#  ifndef   HAVE_F77_IS_IOSTAT_END
#    define HAVE_F77_IS_IOSTAT_END              1
#  endif
#  ifndef   HAVE_F77_GET_COMMAND
#    define HAVE_F77_GET_COMMAND                1
#  endif
#  ifndef   HAVE_F77_GET_COMMAND_ARGUMENT
#    define HAVE_F77_GET_COMMAND_ARGUMENT       1
#  endif
#  ifndef   HAVE_F77_COMMAND_ARGUMENT_COUNT
#    define HAVE_F77_COMMAND_ARGUMENT_COUNT     1
#  endif
#else /* not HAVE_FORTRAN_STANDARD > 2002 */
#  ifndef   HAVE_F77_GET_ENVIRONMENT_VARIABLE
#    define HAVE_F77_GET_ENVIRONMENT_VARIABLE   0
#  endif
#  ifndef   HAVE_F77_IS_IOSTAT_END
#    define HAVE_F77_IS_IOSTAT_END              0
#  endif
#  ifndef   HAVE_F77_GET_COMMAND
#    define HAVE_F77_GET_COMMAND                0
#  endif
#  ifndef   HAVE_F77_GET_COMMAND_ARGUMENT
#    define HAVE_F77_GET_COMMAND_ARGUMENT       0
#  endif
#  ifndef   HAVE_F77_COMMAND_ARGUMENT_COUNT
#    define HAVE_F77_COMMAND_ARGUMENT_COUNT     0
#  endif
#endif /* not HAVE_FORTRAN_STANDARD > 2002 */
CCC_ + 95 and later
#if HAVE_FORTRAN_STANDARD > 94
#  ifndef   HAVE_F77_ADJUSTR
#    define HAVE_F77_ADJUSTR           1
#  endif
#  ifndef   HAVE_F77_LEN_TRIM
#    define HAVE_F77_LEN_TRIM          1
#  endif
#  ifndef   HAVE_F77_TRIM
#    define HAVE_F77_TRIM              1
#  endif
#  ifndef   HAVE_F77_VERIFY
#    define HAVE_F77_VERIFY            1
#  endif
#  ifndef   HAVE_F77_SCAN
#    define HAVE_F77_SCAN              1
#  endif
#  ifndef   HAVE_F77_ICHAR
#    define HAVE_F77_ICHAR             1
#  endif
#  ifndef   HAVE_F77_IACHAR
#    define HAVE_F77_IACHAR            1
#  endif
#  ifndef   HAVE_F77_FLOOR
#    define HAVE_F77_FLOOR             1
#  endif
#  ifndef   HAVE_F77_REPEAT
#    define HAVE_F77_REPEAT            1
#  endif
#  ifndef   HAVE_F77_FORMAT_WIDTH_ZERO
#    define HAVE_F77_FORMAT_WIDTH_ZERO 1
#  endif
#  ifndef   HAVE_F77_RADIX
#    define HAVE_F77_RADIX             1
#  endif
#  ifndef   HAVE_F77_PRECISION
#    define HAVE_F77_PRECISION         1
#  endif
#  ifndef   HAVE_F77_EPSILON
#    define HAVE_F77_EPSILON           1
#  endif
#  ifndef   HAVE_F77_DIGITS
#    define HAVE_F77_DIGITS            1
#  endif
#  ifndef   HAVE_F77_MINEXPONENT
#    define HAVE_F77_MINEXPONENT       1
#  endif
#  ifndef   HAVE_F77_MAXEXPONENT
#    define HAVE_F77_MAXEXPONENT       1
#  endif
#  ifndef   HAVE_F77_FORMAT_Z
#    define HAVE_F77_FORMAT_Z          1
#  endif
#  ifndef   HAVE_F77_CPU_TIME
#    define HAVE_F77_CPU_TIME          1
#  endif
#else /* not HAVE_FORTRAN_STANDARD > 94 */
#  ifndef   HAVE_F77_ADJUSTR
#    define HAVE_F77_ADJUSTR           0
#  endif
#  ifndef   HAVE_F77_LEN_TRIM
#    define HAVE_F77_LEN_TRIM          0
#  endif
#  ifndef   HAVE_F77_TRIM
#    define HAVE_F77_TRIM              0
#  endif
#  ifndef   HAVE_F77_VERIFY
#    define HAVE_F77_VERIFY            0
#  endif
#  ifndef   HAVE_F77_SCAN
#    define HAVE_F77_SCAN              0
#  endif
#  ifndef   HAVE_F77_ICHAR
#    define HAVE_F77_ICHAR             0
#  endif
#  ifndef   HAVE_F77_IACHAR
#    define HAVE_F77_IACHAR            0
#  endif
#  ifndef   HAVE_F77_FLOOR
#    define HAVE_F77_FLOOR             0
#  endif
#  ifndef   HAVE_F77_REPEAT
#    define HAVE_F77_REPEAT            0
#  endif
#  ifndef   HAVE_F77_FORMAT_WIDTH_ZERO
#    define HAVE_F77_FORMAT_WIDTH_ZERO 0
#  endif
#  ifndef   HAVE_F77_RADIX
#    define HAVE_F77_RADIX             0
#  endif
#  ifndef   HAVE_F77_PRECISION
#    define HAVE_F77_PRECISION         0
#  endif
#  ifndef   HAVE_F77_EPSILON
#    define HAVE_F77_EPSILON           0
#  endif
#  ifndef   HAVE_F77_DIGITS
#    define HAVE_F77_DIGITS            0
#  endif
#  ifndef   HAVE_F77_MINEXPONENT
#    define HAVE_F77_MINEXPONENT       0
#  endif
#  ifndef   HAVE_F77_MAXEXPONENT
#    define HAVE_F77_MAXEXPONENT       0
#  endif
#  ifndef   HAVE_F77_FORMAT_Z
#    define HAVE_F77_FORMAT_Z          0
#  endif
#  ifndef   HAVE_F77_CPU_TIME
#    define HAVE_F77_CPU_TIME          0
#  endif
#endif /* not HAVE_FORTRAN_STANDARD > 94 */
CCC_ + 90 and later
CC     note: type conversion with optional kind argument is maybe from f90
#if HAVE_FORTRAN_STANDARD > 89
#  ifndef   HAVE_FORTRAN_INTENT
#    define HAVE_FORTRAN_INTENT       1
#  endif
#  ifndef   HAVE_INQUIRE_IOLENGTH
#    define HAVE_INQUIRE_IOLENGTH     1
#  endif
#  ifndef   HAVE_F90_BIT_FUNCTIONS
#    define HAVE_F90_BIT_FUNCTIONS    1
#  endif
#  ifndef   HAVE_F77_ARRAY_OPERATION
#    define HAVE_F77_ARRAY_OPERATION  1
#  endif
#  ifndef   HAVE_ARRAY_CONVERSION
#    define HAVE_ARRAY_CONVERSION     1
#  endif
#  ifndef   HAVE_OPT_KIND
#    define HAVE_OPT_KIND             1
#  endif
#  ifndef   HAVE_F77_ADJUSTL
#    define HAVE_F77_ADJUSTL          1
#  endif
#  ifndef   HAVE_STATEMENT_EXIT
#    define HAVE_STATEMENT_EXIT       1
#  endif
#else /* not HAVE_FORTRAN_STANDARD > 89 */
#  ifndef   HAVE_FORTRAN_INTENT
#    define HAVE_FORTRAN_INTENT       0
#  endif
#  ifndef   HAVE_INQUIRE_IOLENGTH
#    define HAVE_INQUIRE_IOLENGTH     0
#  endif
#  ifndef   HAVE_F90_BIT_FUNCTIONS
#    define HAVE_F90_BIT_FUNCTIONS    0
#  endif
#  ifndef   HAVE_F77_ARRAY_OPERATION
#    define HAVE_F77_ARRAY_OPERATION  0
#  endif
#  ifndef   HAVE_ARRAY_CONVERSION
#    define HAVE_ARRAY_CONVERSION     0
#  endif
#  ifndef   HAVE_OPT_KIND
#    define HAVE_OPT_KIND             0
#  endif
#  ifndef   HAVE_F77_ADJUSTL
#    define HAVE_F77_ADJUSTL          0
#  endif
#  ifndef   HAVE_STATEMENT_EXIT
#    define HAVE_STATEMENT_EXIT       0
#  endif
#endif /* not HAVE_FORTRAN_STANDARD > 89 */
CCC_ + Various
CCC_  - INTENT
#if HAVE_FORTRAN_INTENT == 1
#  define _INTENT(IO,TYPE) TYPE,INTENT(IO) ::
#  define _II(TYPE,COMMENT) TYPE,INTENT(IN) ::
#  define _IO(TYPE,COMMENT) TYPE,INTENT(OUT) ::
#  define _IB(TYPE,COMMENT) TYPE,INTENT(INOUT) ::
#else  /* not HAVE_FORTRAN_INTENT */
#  define _INTENT(IO,TYPE) TYPE
#  define _II(TYPE,COMMENT) TYPE
#  define _IO(TYPE,COMMENT) TYPE
#  define _IB(TYPE,COMMENT) TYPE
#endif /* not HAVE_FORTRAN_INTENT */
CCC_  - TRIM
#if HAVE_F77_TRIM == 1
#  define _TRIM(A) trim(A)
#  define _TRIML(A) _TRIM(A)
#else
#  define _TRIM(A) A
#  define _TRIML(A) A(1:len_trim(A))
#endif
CCC_ + Precisions
CCC_  - integer
CCC_   . integer environment
#ifndef   HAVE_INTEGER_64_KIND
#  define HAVE_INTEGER_64_KIND 0
#endif
CCC_   . bit-specific types
#define   INTEGER_32_MAX   2147483647
#ifndef   INTEGER_32_BYTES
#  define INTEGER_32_BYTES 4
#endif
#ifndef   INTEGER_32_KIND
#  define INTEGER_32_KIND INTEGER_32_BYTES
#endif
#ifndef   INTEGER_64_BYTES
#  define INTEGER_64_BYTES 8
#endif
#ifndef   INTEGER_64_KIND
#  define INTEGER_64_KIND INTEGER_64_BYTES
#endif
CCC_   . integer without precision
#ifndef   INTEGER_0_BYTES
#  define INTEGER_0_BYTES INTEGER_32_BYTES
#endif
#ifndef   INTEGER_0_KIND
#  define INTEGER_0_KIND INTEGER_32_KIND
#endif
CCC_  - real
CCC_   . bit-specific types
#ifndef   REAL_32_BYTES
#  define REAL_32_BYTES 4
#endif
#ifndef   REAL_64_BYTES
#  define REAL_64_BYTES 8
#endif
#ifndef   REAL_32_KIND
#  define REAL_32_KIND REAL_32_BYTES
#endif
#ifndef   REAL_64_KIND
#  define REAL_64_KIND REAL_64_BYTES
#endif
CCC_   . c-compatible types
#ifndef   REAL_FLOAT_BYTES
#  define REAL_FLOAT_BYTES REAL_32_BYTES
#endif
#ifndef   REAL_DOUBLE_BYTES
#  define REAL_DOUBLE_BYTES REAL_64_BYTES
#endif
#ifndef   REAL_FLOAT_KIND
#  define REAL_FLOAT_KIND REAL_32_KIND
#endif
#ifndef   REAL_DOUBLE_KIND
#  define REAL_DOUBLE_KIND REAL_64_KIND
#endif
CCC_   . real without precision
#ifndef   REAL_0_BYTES
#  define REAL_0_BYTES REAL_FLOAT_BYTES
#endif
#ifndef   REAL_0_KIND
#  define REAL_0_KIND REAL_FLOAT_KIND
#endif
CCC_   . program standard precision
#ifndef   REAL_STD_BYTES
#  define REAL_STD_BYTES REAL_DOUBLE_BYTES
#endif
#ifndef   REAL_STD_KIND
#  define REAL_STD_KIND REAL_DOUBLE_KIND
#endif
CCC_  - precision conversion
#if HAVE_OPT_KIND > 0
#  define _XREALK(V,K) REAL(V,K)

#  define _XREALF(V) _XREALK(V,REAL_FLOAT_KIND)
#  define _XREALD(V) _XREALK(V,REAL_DOUBLE_KIND)
#  define _XREALS(V) _XREALK(V,REAL_STD_KIND)
#  define _XREAL32(V) _XREALK(V,REAL_32_KIND)
#  define _XREAL64(V) _XREALK(V,REAL_64_KIND)

#  define _XINTK(V,K) INT(V,K)
#  define _XINT32(V) INT(V,INTEGER_32_KIND)
#  define _XINT64(V) INT(V,INTEGER_64_KIND)

#else /* not HAVE_OPT_KIND */
#  if __GFORTRAN__
#  else
#    warning "precision conversion functions may not work correctly"
#  endif
#  define _XREALK(V,K) REAL(V)

#  define _XREALF(V) REAL(V)
#  define _XREALD(V) DBLE(V)
#  define _XREAL32(V) REAL(V)
#  define _XREAL64(V) DBLE(V)

#  if   REAL_STD_KIND == REAL_DOUBLE_KIND
#    define _XREALS(V) _XREALD(V)
#  elif REAL_STD_KIND == REAL_FLOAT_KIND
#    define _XREALS(V) _XREALF(V)
#  elif REAL_STD_KIND == REAL_32_KIND
#    define _XREALS(V) _XREAL64(V)
#  elif REAL_STD_KIND == REAL_64_KIND
#    define _XREALS(V) _XREAL32(V)
#  else
#    error "invalid real/standard setting"
#  endif

#  define _XINTK(V,K) INT(V)
#  define _XINT32(V) INT(V)
#  define _XINT64(V) INT(V)
#endif /* not HAVE_OPT_KIND */
CCC_  - declaration
#if HAVE_OPT_KIND > 0
#  define _INTEGER(K) INTEGER(KIND=K)
#  define _REAL(K) REAL(KIND=K)
#else
#  define _REAL(K) REAL*K
#  define _INTEGER(K) INTEGER*K
#endif
#define _REALF  _REAL(REAL_FLOAT_KIND)
#define _REALD  _REAL(REAL_DOUBLE_KIND)
#define _REAL32 _REAL(REAL_32_KIND)
#define _REAL64 _REAL(REAL_64_KIND)
CC #define _REAL8 DOUBLE PRECISION
#define _REALSTD _REAL(REAL_STD_KIND)
cc
#define _INT32 _INTEGER(INTEGER_32_KIND)
#define _INT64 _INTEGER(INTEGER_64_KIND)
CCC_* End definitions
#endif  /* _OFDLCT_H */
CCC_! FOOTER
C Local Variables:
C mode: fortran
C fff-style: "iciesShermy"
C End:
