*****************
 Coding policies
*****************

:Source: IcIES/doc/r/coding.rst
:Maintainer: SAITO Fuyuki
:Created:    Nov 8 2013
:Time-stamp: <2020/09/17 13:06:47 fuyuki coding.rst>
:Target: Snoopy0.9 or later

Copyright 2016--2020 Japan Agency for Marine-Earth Science and Technology,
                     Ayako ABE-OUCHI
Licensed under the Apache License, Version 2.0
  (https://www.apache.org/licenses/LICENSE-2.0)

.. highlight:: iciesf

.. contents::
..
    1   1. Coding styles
    2   1.1. Fortran dialects
    3   1.2. Outline structure using Emacs ``allout-mode``
    4   1.3. Variable naming conventions
    5   2. Subroutine strucutre design
    6   2.1. Announcement subroutine
    7   2.2. Embedded test program
    8   3. Building
    9   3.1. Building executables
    10  3.2. Building test programs
    11  3.3. Copying origianl sources
    12  3.4. Static source check

Coding styles
=============

There are no strict rules in `IcIES` coding and development.

Fortran dialects
----------------

Fortran 77
Fortran 95

NAMELIST
INTENT statements

Header
------

An example of the header of a source file is as follows::

   C cadenza/cabcnv.F --- IcIES/Cadenza/Ascii Binary conversion
   C Maintainer:  SAITO Fuyuki
   C Created: Jul 3 2013
   #ifdef HAVE_CONFIG_H
   #  include "config.h"
   #endif
   #define _TSTAMP 'Time-stamp: <2013/11/11 22:38:42 fuyuki cabcnv.F>'
   #define _FNAME 'cadenza/cabcnv.F'
   #define _REV   'Snoopy0.9'

::

   C DIRECTORY/FILE --- SHORT DESCRIPTION
   C Maintainer: NAME <ADDRESS>
   C Created: DATE
   C Other properties: something
   #ifdef HAVE_CONFIG_H
   #  include "config.h"
   #endif
   #define _TSTAMP 'Time-stamp: <2013/11/11 22:38:42 fuyuki cabcnv.F>'
   #define _FNAME 'DIRECTORY/FILE'
   #define _REV   'REVISION'

Use ``time-stamp`` in ``time-stamp.el`` to activate automatic
time stamp update when saving files.

Outline structure using Emacs ``allout-mode``
---------------------------------------------

::

   CCC_! Bullet for remark
   CCC_? Bullet for caution
   CCC_@ Bullet for program
   CCC_& Bullet for subroutine/function/entry
   CCC_= Bullet for declaration
   CCC_* Plain bullet level 1
   CCC_ + Plain bullet level 2
   CCC_  - Plain bullet level 3
   CCC_   . Plain bullet level 4
   CCC_    * Plain bullet level 5 

The headings is starting with triplet of capital ``C`` and the
underscore ``_`` as ``CCC_``, which is followed by zero or more blanks
and a bullet character.

The value of ``allout-plain-bullets-string`` is ``"*+-."``.
The non-plain bullets can be used on the any level.

Typical style for subrouine with long declaration part::

   CCC_ & NAME  ## SHORT DESCRIPTION
         subroutine NAME
        O    (ARG1,
        I     ARG2)
   CCC_  - Declaration
         implicit none
   CCC_   = Arguments
   CCC_   = Interior
   CCC_   = :
   CCC_  - Body
         RETURN
         END


Variable naming conventions
---------------------------

Subroutine strucutre design
===========================

Announcement subroutine
-----------------------

Embedded test program
---------------------

Building
========

Building executables
--------------------

Building test programs
----------------------


Copying origianl sources
------------------------


Static source check
-------------------

