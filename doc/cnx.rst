===============
 IcIES/doc/cnx
===============
:Maintainer: SAITO Fuyuki
:Created:    Oct 27 2016
:Time-stamp: <2020/09/15 12:27:21 fuyuki cnx.rst>
:Revision:   1b7c37b718da39e579d28c2509cf267f3dca318d or later

Copyright 2016--2020 Japan Agency for Marine-Earth Science and Technology,
Licensed under the Apache License, Version 2.0
  (https://www.apache.org/licenses/LICENSE-2.0)

Simple extrator ``cnx.sh``
==========================

``PREFIX/local/bin/cnx.sh`` is the helper script for conversion from
`IcIES` original output to ascii/binary/NetCDF format.  It is a zsh script.

Sinopsys::

  PATH-TO/cnx.sh [+q][-q][+v][-v][-f][-n] [-t <TYPE>] [-G <GROUP>]
                 [-V <VAR>] [-T TIME] [-F FILE] <REPORT-FILE>

Common options are as folows.

``-q``
   Silent, to disable verbose message

``+q``
   More silent, to disable verbose message

``-v``
   Verbose

``+v``
   More Verbose

``-f``
   To overwrite existing file.

``-n``
   A dry run.

``-t <TYPE>``
   Specify output type.  TYPE is either ``a`` for ascii, ``b`` for
   binary and ``n`` for NetCDF.

``-F <FILE>``
   Specify output file name.

``-G <GROUP>``
   Specify target variable cluster, such as ``VMI``, ``VMTI`` etc.

``-V <VAR>``
   Specify target variable, such as ``H``, ``T`` etc.

``-T <TIME>``
   Specify start time to extract.

``<REPORT-FILE>``
   IcIES write various report about the output variables in ``EXP-DIR/L/vrep.000_*`` when MPI mode or
   ``EXP-DIR/L/vrep`` when non-MPI mode.  You have to precisely set this file as ``<REPORT-FILE>``.

NetCDF conversion
=================

Typical usage::

  % cd src/movement
  % ../../local/bin/cnx.sh +q -f -tn -G VMI -F VMI.nc \
      O/mdrvrm2/mismip/L/vrep.000_001
  % ls
  VMI.nc

Ascii conversion
================

Typical usage::

  % cd src/movement
  % ../../local/bin/cnx.sh +q -f -ta -T 10000 -G VMI -V HH -F VMI.asc \
      O/mdrvrm2/mismip/L/vrep.000_001
  % ls
  VMI.asc
  % cat VMI.asc
  11 1 1    0.0000000000000000
  11 1 2    0.0000000000000000
  11 1 3    0.0000000000000000
  11 1 4    0.0000000000000000
  11 1 5    0.0000000000000000
  11 1 6    0.0000000000000000
  11 1 7    0.0000000000000000
  11 1 8    0.0000000000000000
  11 1 9    0.0000000000000000
  :

One line contains four columns,  TIME-INDEX, VARIABLE-ID, COORDINATE
and VALUE.
The first three columns are index, where time-index, variable-number
and integrated-grid number.  The last column is the value.

One variable-cluster group contains multiple variable fields.  Those
variables are numbered from 1 on the second column (*VAR*).
The third column (*COOR*) is the grid index represented as 1-dimension
array.  The fourth column (*VALUE*) is the value corresponds to
*TIDX*, *VAR*, and *COOR*.

Binary conversion
=================

Typical usage::

  % cd src/movement
  % ../../local/bin/cnx.sh +q -f -tb -T 10000 -G VMI -V HH -F VMI.dat \
      O/mdrvrm2/mismip/L/vrep.000_001
  % ls
  VMI.dat

The output contains the value of the field variable only, without grid information.

Coordinates
===========

The geometric coordinates are outputted as the group ``AKW`` at the
time **0**.  You can get the ``AKW`` group in the ascii format as::

  % ../../local/bin/cnx.sh -v -ta -f -G AKW -F akw.asc \
    O/mdrvrm2/nm11a_60_cnxtest/L/vrep.000_001 > Log.akw
  % ls
  akw.asc Log.akw

In order to get variable index, you must redirect
its output to a file (``Log.akw`` in the example).  This is quite
long, but only the line begin with ``CAX:V`` is used for this purposes.

::

  % grep -h '^CAX:V' Log.ascii.AKW
  CAX:V     1 GXab.MO
  CAX:V     2 GXab.MA
  CAX:V     3 GXab.TO
  CAX:V     4 GXab.TA
  :

The names of the X- and Y-coordinate of thickness grids are ``Xa.Mo``
and ``Ya.Mo``, respectively, which are normally 105 and 113.

In order to create, for example, 3-column ascii data contains x, y,
and thickness (group ``VMI``, variable ``H.Ha``), the following
procedure can be used::

  % ../../local/bin/cnx.sh -v -t a -f -T 30000 -G VMI -F vmi.asc \
    O/mdrvrm2/nm11a_60_cnxtest/L/vrep.000_001 > Log.vmi
  # check index H.Ha (e.g., 3)

  % ../../local/bin/cnx.sh -v -t a -f -G AKW -F akw.asc \
    O/mdrvrm2/nm11a_60_cnxtest/L/vrep.000_001 > Log.akw
  # check index Xa.Mo (e.g., 105)
  # check index Ya.Mo (e.g., 113)

  % gawk '$1==3   {print $4}' vmi.asc > ascii.VMI_H.Ha
  % gawk '$1==105 {print $4}' vmi.akw > ascii.Xa
  % gawk '$1==113 {print $4}' vii.akw > ascii.Ya
  % paste ascii.Xa ascii.Ya ascii.VMI_H.Ha > ascii.Xa_Ya_H.Ha

Restart configuration
=====================

Constant rate-factor experiment requires just one variable to restart,
which is variable ``oH`` in the cluster ``VMHI``.
In order to restart the model, the following configuration should be used.

::

   &NIDATA
     CROOT = 'ID',
     GROUP = 'VMHI',
     VAR   = 'oH',
     COOR  = 'ID.Ha',
     FNM   = 'vmi_hh.dat',
     FMT   = ' ',
     VAL   = 0,
     LB    = 0,
     IR    = 1,
     DIMS  = 31,31,
   &END

In the example, ``FNM`` and ``DIMS`` are the entry users have to
formulate. The entry ``FNM`` is the file name which contains binary data of ``VMHI/oH``.
This can be extracted by ``cnx.sh`` as follows typically.

::

  % SOMEWHERE/cnx.sh +q -f -tb -T 10000 -G VMHI -V oH -F vmi_hh.dat \
      EXP-DIR/vrep.000_*

The entry ``DIMS`` is the dimension information of the field.  In this
case, a horizontal plane of 31 times 31 is set.  These dimension
information is obtained from experiment log such as ``EXP-DIR/O/error.000_*``.

::

   % grep ACWRGA EXP-DIR/O/error.000_*
   :
   ACWRGA (D) [   1]   40 CO ID.Xa      31
   :
   ACWRGA (D) [   1]   66 CO ID.Ya      31
   :

The are many lines of ACWRGA properties. Search two lines which
contains ``CO ID.Xa`` and ``CO ID.Ya``.  The last column is the
*actual* size of the X and Y coordinates.
These are often different from those set by ``NXG`` or ``NYG`` in the
experiment configuration due to parallelization.

..  LocalWords:  IcIES SAITO Fuyuki
