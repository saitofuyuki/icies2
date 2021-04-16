# src/unison/Makefile.tmpl --- IcIES/Unison Makefile.am template
# Maintainer:  SAITO Fuyuki
# Created: Nov 2 2011
# Revision:  Snoopy0.9
# Time-stamp: <2020/09/15 11:02:19 fuyuki Makefile.tmpl>

# Copyright: 2011--2020 JAMSTEC, Ayako ABE-OUCHI
# Licensed under the Apache License, Version 2.0
#   (https://www.apache.org/licenses/LICENSE-2.0)

libicies_local_la_ORIGINS = ufortw.F \
							udbgst.F ustrmn.F \
							uarmpi.F ukvtbl.F \
							ueaoms.F utmplm.F uuioms.F usymch.F \
							unmlem.F uxunit.F uxhcal.F uvclst.F \
							uprfem.F

CLEANFILES = fort.* ##%% a

### Local Variables:
### mode: makefile-automake
### end:
#### End of template
#### COMMON
F77PREPROCESS = $(CPP) $(DEFS) $(DEFAULT_INCLUDES) $(INCLUDES) $(AM_CPPFLAGS) $(CPPFLAGS)
STANDARD_CPPFLAGS = -I$(OSTINATO_build) -I$(top_srcdir) -I$(OSTINATO_src)
AM_CPPFLAGS = $(STANDARD_CPPFLAGS) $(XPKG_CPPFLAGS)
AM_LDFLAGS = $(STANDARD_LDFLAGS)  $(XPKG_LDFLAGS)
SUBDIRS = .
OSTINATO = src/ostinato
OSTINATO_src = $(top_srcdir)/$(OSTINATO)
OSTINATO_build = $(top_builddir)/$(OSTINATO)
MKMKAM = $(top_srcdir)/build-aux/icies/mkmkam
MKCLOCKCOND = $(top_srcdir)/build-aux/icies/clockcond
EXTRA_DIST = $(LCLCNDH) Makefile.tmpl
if NEVER
EXTRA_PROGRAMS = dummy_never_built
nodist_dummy_never_built_SOURCES = dummy_never_built.c
endif
#### END COMMON
#### COMMON BUILDS
.tmpl.am:
	$(MKMKAM) $<
force_config_status:
	cd $(top_builddir) && $(SHELL) ./config.status
clockh:
	$(MAKE) $(AM_MAKEFLAGS) RECURSIVE_TARGETS=clockh-recursive clockh-recursive
clockh-am:
if MAINTAINER_MODE
	if test -z "$(CLC_SRCS)"; then :; else \
	$(MKCLOCKCOND) $(MKCLOCKCOND_FLAGS) -s $(subdir) -t $(top_srcdir) -g $(OSTINATO_build) $(CLC_SRCS); \
	fi
else
	test -n '$(LCLCNDH)' && touch $(LCLCNDH)
endif
$(LCLCNDH): clockh-am
tmpl2am:
	$(MAKE) $(AM_MAKEFLAGS) RECURSIVE_TARGETS=tmpl2am-recursive tmpl2am-recursive
tmpl2am-am:
	$(MKMKAM) $(srcdir)/Makefile.tmpl
catall:
	$(MAKE) $(AM_MAKEFLAGS) RECURSIVE_TARGETS=catall-recursive catall-recursive
catall-am: $(CATALL_files)
catall-src:
	@cd ../; $(MAKE) $(AM_MAKEFLAGS) catall
libdepall:
	@fail= failcom='exit 1'; \
	for f in x $$MAKEFLAGS; do \
	case $$f in \
		*=* | --[!k]*);; \
		*k*) failcom='fail=yes';; \
	esac; \
	done; \
	target=all; \
	list='$(LIB_DEPEND_DIRS)'; for subdir in $$list; do \
		subdir=$(top_builddir)/$(LIB_DEPEND_BASE)/$$subdir; \
		echo "Making library in $$subdir"; \
		($(am__cd) $$subdir && $(MAKE) $(AM_MAKEFLAGS) $$target) \
		|| eval $$failcom; \
	done; \
	test -z "$$fail"
.F.f:
@am__fastdepCC_TRUE@	$(F77PREPROCESS)  -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS)  `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
copy-am: $(ta__copy_source_targets)
$(ta__copy_source_targets):
	@fail=; \
	target=`echo $@ | sed s/^.*copy-//`; \
	if test -f $(builddir)/$$target; then \
	echo cannot overwrite $(builddir)/$$target; fail=yes; \
	else \
	$(CP) $(srcdir)/$$target $(builddir); \
	fi; test -z "$$fail"
$(DEPDIR)/dummy_never_built.Po:
	@$(MKDIR_P) $(DEPDIR) && touch $@
#### END COMMON BUILDS
#### ORIGINS/BUILDS
noinst_LTLIBRARIES = libicies_local.la
#### END ORIGINS/BUILDS
#### BUILD FAMILY noinst_LTLIBRARIES
#### BUILD libicies_local.la
ufortw.$(OBJEXT): ufortw.f
udbgst.$(OBJEXT): udbgst.f
ustrmn.$(OBJEXT): ustrmn.f
uarmpi.$(OBJEXT): uarmpi.f
ukvtbl.$(OBJEXT): ukvtbl.f
ueaoms.$(OBJEXT): ueaoms.f
utmplm.$(OBJEXT): utmplm.f
uuioms.$(OBJEXT): uuioms.f
usymch.$(OBJEXT): usymch.f
unmlem.$(OBJEXT): unmlem.f
uxunit.$(OBJEXT): uxunit.f
uxhcal.$(OBJEXT): uxhcal.f
uvclst.$(OBJEXT): uvclst.f
uprfem.$(OBJEXT): uprfem.f
ta__copy_source_targets = copy-ufortw.F copy-udbgst.F copy-ustrmn.F copy-uarmpi.F copy-ukvtbl.F copy-ueaoms.F copy-utmplm.F copy-uuioms.F copy-usymch.F copy-unmlem.F copy-uxunit.F copy-uxhcal.F copy-uvclst.F copy-uprfem.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/ufortw.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/udbgst.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/ustrmn.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/uarmpi.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/ukvtbl.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/ueaoms.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/utmplm.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/uuioms.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/usymch.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/unmlem.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/uxunit.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/uxhcal.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/uvclst.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/uprfem.Pf@am__quote@ # am--include-marker
EXTRA_DIST += $(libicies_local_la_ORIGINS)
CLC_SRCS = $(libicies_local_la_ORIGINS)
nodist_libicies_local_la_SOURCES = ufortw.f udbgst.f ustrmn.f uarmpi.f ukvtbl.f ueaoms.f utmplm.f uuioms.f usymch.f unmlem.f uxunit.f uxhcal.f uvclst.f uprfem.f
CLEANFILES += ufortw.f udbgst.f ustrmn.f uarmpi.f ukvtbl.f ueaoms.f utmplm.f uuioms.f usymch.f unmlem.f uxunit.f uxhcal.f uvclst.f uprfem.f gather_libicies_local_la.f
CATALL_files = gather_libicies_local_la.f
gather_libicies_local_la.f: $(nodist_libicies_local_la_SOURCES)
	test -z "$(nodist_libicies_local_la_SOURCES)" || cat $(nodist_libicies_local_la_SOURCES) > $@ || rm -f $@
#### END BUILD libicies_local.la
#### END BUILD FAMILY noinst_LTLIBRARIES
#### ORIGINS/CHECKS uarmpi.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/uarmpi1-uarmpi.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/uarmpi2-uarmpi.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/uarmpi3-uarmpi.Pf@am__quote@ # am--include-marker
uarmpi1_CPPFLAGS = -DTEST_UARMPI=1
uarmpi1-uarmpi.f: uarmpi.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(uarmpi1_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(uarmpi1_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_uarmpi1_SOURCES = uarmpi1-uarmpi.f
srcchk-uarmpi1: $(nodist_uarmpi1_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_uarmpi1_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-uarmpi1: $(nodist_uarmpi1_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_uarmpi1_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-uarmpi1.f: $(nodist_uarmpi1_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_uarmpi1_SOURCES)" || cat $(nodist_uarmpi1_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
uarmpi2_CPPFLAGS = -DTEST_UARMPI=2
uarmpi2-uarmpi.f: uarmpi.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(uarmpi2_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(uarmpi2_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_uarmpi2_SOURCES = uarmpi2-uarmpi.f
srcchk-uarmpi2: $(nodist_uarmpi2_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_uarmpi2_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-uarmpi2: $(nodist_uarmpi2_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_uarmpi2_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-uarmpi2.f: $(nodist_uarmpi2_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_uarmpi2_SOURCES)" || cat $(nodist_uarmpi2_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
uarmpi3_CPPFLAGS = -DTEST_UARMPI=3
uarmpi3-uarmpi.f: uarmpi.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(uarmpi3_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(uarmpi3_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_uarmpi3_SOURCES = uarmpi3-uarmpi.f
srcchk-uarmpi3: $(nodist_uarmpi3_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_uarmpi3_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-uarmpi3: $(nodist_uarmpi3_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_uarmpi3_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-uarmpi3.f: $(nodist_uarmpi3_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_uarmpi3_SOURCES)" || cat $(nodist_uarmpi3_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
CLEANFILES += uarmpi1-uarmpi.f bundle-uarmpi1.f uarmpi2-uarmpi.f bundle-uarmpi2.f uarmpi3-uarmpi.f bundle-uarmpi3.f
check_PROGRAMS = uarmpi1 uarmpi2 uarmpi3
srcchk-all: srcchk-uarmpi1 srcchk-uarmpi2 srcchk-uarmpi3
sublist-all: sublist-uarmpi1 sublist-uarmpi2 sublist-uarmpi3
bundle-all: bundle-uarmpi1.f bundle-uarmpi2.f bundle-uarmpi3.f
check-uarmpi: uarmpi1 uarmpi2 uarmpi3
#### END ORIGINS/CHECKS uarmpi.F
#### ORIGINS/CHECKS udbgst.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/udbgst-udbgst.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/udbgst-ufortw.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/udbgst-ustrmn.Pf@am__quote@ # am--include-marker
udbgst_CPPFLAGS = -DTEST_UDBGST=1
udbgst-udbgst.f: udbgst.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(udbgst_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(udbgst_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
udbgst-ufortw.f: ufortw.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(udbgst_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(udbgst_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
udbgst-ustrmn.f: ustrmn.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(udbgst_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(udbgst_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_udbgst_SOURCES = udbgst-udbgst.f udbgst-ufortw.f udbgst-ustrmn.f
srcchk-udbgst: $(nodist_udbgst_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_udbgst_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-udbgst: $(nodist_udbgst_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_udbgst_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-udbgst.f: $(nodist_udbgst_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_udbgst_SOURCES)" || cat $(nodist_udbgst_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
CLEANFILES += udbgst-udbgst.f udbgst-ufortw.f udbgst-ustrmn.f bundle-udbgst.f
check_PROGRAMS += udbgst
srcchk-all: srcchk-udbgst
sublist-all: sublist-udbgst
bundle-all: bundle-udbgst.f
check-udbgst: udbgst
#### END ORIGINS/CHECKS udbgst.F
#### ORIGINS/CHECKS ueaoms.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/ueaoms1-ueaoms.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/ueaoms2-ueaoms.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/ueaoms3-ueaoms.Pf@am__quote@ # am--include-marker
ueaoms1_CPPFLAGS = -DTEST_UEAOMS=1
ueaoms1-ueaoms.f: ueaoms.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(ueaoms1_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(ueaoms1_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_ueaoms1_SOURCES = ueaoms1-ueaoms.f
srcchk-ueaoms1: $(nodist_ueaoms1_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_ueaoms1_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-ueaoms1: $(nodist_ueaoms1_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_ueaoms1_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-ueaoms1.f: $(nodist_ueaoms1_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_ueaoms1_SOURCES)" || cat $(nodist_ueaoms1_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
ueaoms2_CPPFLAGS = -DTEST_UEAOMS=2
ueaoms2-ueaoms.f: ueaoms.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(ueaoms2_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(ueaoms2_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_ueaoms2_SOURCES = ueaoms2-ueaoms.f
srcchk-ueaoms2: $(nodist_ueaoms2_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_ueaoms2_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-ueaoms2: $(nodist_ueaoms2_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_ueaoms2_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-ueaoms2.f: $(nodist_ueaoms2_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_ueaoms2_SOURCES)" || cat $(nodist_ueaoms2_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
ueaoms3_CPPFLAGS = -DTEST_UEAOMS=3
ueaoms3-ueaoms.f: ueaoms.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(ueaoms3_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(ueaoms3_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_ueaoms3_SOURCES = ueaoms3-ueaoms.f
srcchk-ueaoms3: $(nodist_ueaoms3_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_ueaoms3_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-ueaoms3: $(nodist_ueaoms3_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_ueaoms3_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-ueaoms3.f: $(nodist_ueaoms3_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_ueaoms3_SOURCES)" || cat $(nodist_ueaoms3_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
CLEANFILES += ueaoms1-ueaoms.f bundle-ueaoms1.f ueaoms2-ueaoms.f bundle-ueaoms2.f ueaoms3-ueaoms.f bundle-ueaoms3.f
check_PROGRAMS += ueaoms1 ueaoms2 ueaoms3
srcchk-all: srcchk-ueaoms1 srcchk-ueaoms2 srcchk-ueaoms3
sublist-all: sublist-ueaoms1 sublist-ueaoms2 sublist-ueaoms3
bundle-all: bundle-ueaoms1.f bundle-ueaoms2.f bundle-ueaoms3.f
check-ueaoms: ueaoms1 ueaoms2 ueaoms3
#### END ORIGINS/CHECKS ueaoms.F
#### ORIGINS/CHECKS ufortw.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/ufortw1-ufortw.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/ufortw2-ufortw.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/ufortw3-ufortw.Pf@am__quote@ # am--include-marker
ufortw1_CPPFLAGS = -DTEST_UFORTW=1
ufortw1-ufortw.f: ufortw.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(ufortw1_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(ufortw1_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_ufortw1_SOURCES = ufortw1-ufortw.f
srcchk-ufortw1: $(nodist_ufortw1_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_ufortw1_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-ufortw1: $(nodist_ufortw1_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_ufortw1_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-ufortw1.f: $(nodist_ufortw1_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_ufortw1_SOURCES)" || cat $(nodist_ufortw1_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
ufortw2_CPPFLAGS = -DTEST_UFORTW=2
ufortw2-ufortw.f: ufortw.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(ufortw2_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(ufortw2_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_ufortw2_SOURCES = ufortw2-ufortw.f
srcchk-ufortw2: $(nodist_ufortw2_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_ufortw2_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-ufortw2: $(nodist_ufortw2_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_ufortw2_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-ufortw2.f: $(nodist_ufortw2_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_ufortw2_SOURCES)" || cat $(nodist_ufortw2_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
ufortw3_CPPFLAGS = -DTEST_UFORTW=3
ufortw3-ufortw.f: ufortw.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(ufortw3_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(ufortw3_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_ufortw3_SOURCES = ufortw3-ufortw.f
srcchk-ufortw3: $(nodist_ufortw3_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_ufortw3_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-ufortw3: $(nodist_ufortw3_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_ufortw3_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-ufortw3.f: $(nodist_ufortw3_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_ufortw3_SOURCES)" || cat $(nodist_ufortw3_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
CLEANFILES += ufortw1-ufortw.f bundle-ufortw1.f ufortw2-ufortw.f bundle-ufortw2.f ufortw3-ufortw.f bundle-ufortw3.f
check_PROGRAMS += ufortw1 ufortw2 ufortw3
srcchk-all: srcchk-ufortw1 srcchk-ufortw2 srcchk-ufortw3
sublist-all: sublist-ufortw1 sublist-ufortw2 sublist-ufortw3
bundle-all: bundle-ufortw1.f bundle-ufortw2.f bundle-ufortw3.f
check-ufortw: ufortw1 ufortw2 ufortw3
#### END ORIGINS/CHECKS ufortw.F
#### ORIGINS/CHECKS ukvtbl.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/ukvtbl-ukvtbl.Pf@am__quote@ # am--include-marker
ukvtbl_CPPFLAGS = -DTEST_UKVTBL=1
ukvtbl-ukvtbl.f: ukvtbl.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(ukvtbl_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(ukvtbl_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_ukvtbl_SOURCES = ukvtbl-ukvtbl.f
srcchk-ukvtbl: $(nodist_ukvtbl_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_ukvtbl_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-ukvtbl: $(nodist_ukvtbl_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_ukvtbl_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-ukvtbl.f: $(nodist_ukvtbl_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_ukvtbl_SOURCES)" || cat $(nodist_ukvtbl_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
CLEANFILES += ukvtbl-ukvtbl.f bundle-ukvtbl.f
check_PROGRAMS += ukvtbl
srcchk-all: srcchk-ukvtbl
sublist-all: sublist-ukvtbl
bundle-all: bundle-ukvtbl.f
check-ukvtbl: ukvtbl
#### END ORIGINS/CHECKS ukvtbl.F
#### ORIGINS/CHECKS unmlem.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/unmlem-unmlem.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/unmlem-ufortw.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/unmlem-uuioms.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/unmlem-ustrmn.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/unmlem-udbgst.Pf@am__quote@ # am--include-marker
unmlem_CPPFLAGS = -DTEST_UNMLEM=1
unmlem-unmlem.f: unmlem.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(unmlem_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(unmlem_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
unmlem-ufortw.f: ufortw.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(unmlem_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(unmlem_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
unmlem-uuioms.f: uuioms.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(unmlem_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(unmlem_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
unmlem-ustrmn.f: ustrmn.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(unmlem_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(unmlem_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
unmlem-udbgst.f: udbgst.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(unmlem_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(unmlem_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_unmlem_SOURCES = unmlem-unmlem.f unmlem-ufortw.f unmlem-uuioms.f unmlem-ustrmn.f unmlem-udbgst.f
srcchk-unmlem: $(nodist_unmlem_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_unmlem_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-unmlem: $(nodist_unmlem_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_unmlem_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-unmlem.f: $(nodist_unmlem_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_unmlem_SOURCES)" || cat $(nodist_unmlem_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
CLEANFILES += unmlem-unmlem.f unmlem-ufortw.f unmlem-uuioms.f unmlem-ustrmn.f unmlem-udbgst.f bundle-unmlem.f
check_PROGRAMS += unmlem
srcchk-all: srcchk-unmlem
sublist-all: sublist-unmlem
bundle-all: bundle-unmlem.f
check-unmlem: unmlem
#### END ORIGINS/CHECKS unmlem.F
#### ORIGINS/CHECKS uprfem.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/uprfem-uprfem.Pf@am__quote@ # am--include-marker
uprfem_CPPFLAGS = -DTEST_UPRFEM=1
uprfem-uprfem.f: uprfem.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(uprfem_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(uprfem_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_uprfem_SOURCES = uprfem-uprfem.f
srcchk-uprfem: $(nodist_uprfem_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_uprfem_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-uprfem: $(nodist_uprfem_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_uprfem_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-uprfem.f: $(nodist_uprfem_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_uprfem_SOURCES)" || cat $(nodist_uprfem_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
CLEANFILES += uprfem-uprfem.f bundle-uprfem.f
check_PROGRAMS += uprfem
srcchk-all: srcchk-uprfem
sublist-all: sublist-uprfem
bundle-all: bundle-uprfem.f
check-uprfem: uprfem
#### END ORIGINS/CHECKS uprfem.F
#### ORIGINS/CHECKS ustrmn.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/ustrmn-ustrmn.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/ustrmn-ufortw.Pf@am__quote@ # am--include-marker
ustrmn_CPPFLAGS = -DTEST_USTRMN=1 -D_NEED_UFTEST_BANNER=1
ustrmn-ustrmn.f: ustrmn.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(ustrmn_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(ustrmn_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
ustrmn-ufortw.f: ufortw.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(ustrmn_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(ustrmn_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_ustrmn_SOURCES = ustrmn-ustrmn.f ustrmn-ufortw.f
srcchk-ustrmn: $(nodist_ustrmn_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_ustrmn_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-ustrmn: $(nodist_ustrmn_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_ustrmn_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-ustrmn.f: $(nodist_ustrmn_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_ustrmn_SOURCES)" || cat $(nodist_ustrmn_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
CLEANFILES += ustrmn-ustrmn.f ustrmn-ufortw.f bundle-ustrmn.f
check_PROGRAMS += ustrmn
srcchk-all: srcchk-ustrmn
sublist-all: sublist-ustrmn
bundle-all: bundle-ustrmn.f
check-ustrmn: ustrmn
#### END ORIGINS/CHECKS ustrmn.F
#### ORIGINS/CHECKS usymch.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/usymch-usymch.Pf@am__quote@ # am--include-marker
usymch_CPPFLAGS = -DTEST_USYMCH=1
usymch-usymch.f: usymch.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(usymch_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(usymch_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_usymch_SOURCES = usymch-usymch.f
srcchk-usymch: $(nodist_usymch_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_usymch_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-usymch: $(nodist_usymch_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_usymch_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-usymch.f: $(nodist_usymch_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_usymch_SOURCES)" || cat $(nodist_usymch_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
CLEANFILES += usymch-usymch.f bundle-usymch.f
check_PROGRAMS += usymch
srcchk-all: srcchk-usymch
sublist-all: sublist-usymch
bundle-all: bundle-usymch.f
check-usymch: usymch
#### END ORIGINS/CHECKS usymch.F
#### ORIGINS/CHECKS utmplm.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/utmplm-utmplm.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/utmplm-ufortw.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/utmplm-udbgst.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/utmplm-ukvtbl.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/utmplm-ustrmn.Pf@am__quote@ # am--include-marker
utmplm_CPPFLAGS = -DTEST_UTMPLM=1
utmplm-utmplm.f: utmplm.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(utmplm_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(utmplm_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
utmplm-ufortw.f: ufortw.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(utmplm_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(utmplm_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
utmplm-udbgst.f: udbgst.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(utmplm_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(utmplm_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
utmplm-ukvtbl.f: ukvtbl.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(utmplm_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(utmplm_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
utmplm-ustrmn.f: ustrmn.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(utmplm_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(utmplm_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_utmplm_SOURCES = utmplm-utmplm.f utmplm-ufortw.f utmplm-udbgst.f utmplm-ukvtbl.f utmplm-ustrmn.f
srcchk-utmplm: $(nodist_utmplm_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_utmplm_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-utmplm: $(nodist_utmplm_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_utmplm_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-utmplm.f: $(nodist_utmplm_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_utmplm_SOURCES)" || cat $(nodist_utmplm_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
CLEANFILES += utmplm-utmplm.f utmplm-ufortw.f utmplm-udbgst.f utmplm-ukvtbl.f utmplm-ustrmn.f bundle-utmplm.f
check_PROGRAMS += utmplm
srcchk-all: srcchk-utmplm
sublist-all: sublist-utmplm
bundle-all: bundle-utmplm.f
check-utmplm: utmplm
#### END ORIGINS/CHECKS utmplm.F
#### ORIGINS/CHECKS uuioms.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/uuioms-uuioms.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/uuioms-ufortw.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/uuioms-udbgst.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/uuioms-ustrmn.Pf@am__quote@ # am--include-marker
uuioms_CPPFLAGS = -DTEST_UUIOMS=1
uuioms-uuioms.f: uuioms.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(uuioms_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(uuioms_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
uuioms-ufortw.f: ufortw.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(uuioms_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(uuioms_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
uuioms-udbgst.f: udbgst.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(uuioms_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(uuioms_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
uuioms-ustrmn.f: ustrmn.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(uuioms_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(uuioms_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_uuioms_SOURCES = uuioms-uuioms.f uuioms-ufortw.f uuioms-udbgst.f uuioms-ustrmn.f
srcchk-uuioms: $(nodist_uuioms_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_uuioms_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-uuioms: $(nodist_uuioms_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_uuioms_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-uuioms.f: $(nodist_uuioms_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_uuioms_SOURCES)" || cat $(nodist_uuioms_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
CLEANFILES += uuioms-uuioms.f uuioms-ufortw.f uuioms-udbgst.f uuioms-ustrmn.f bundle-uuioms.f
check_PROGRAMS += uuioms
srcchk-all: srcchk-uuioms
sublist-all: sublist-uuioms
bundle-all: bundle-uuioms.f
check-uuioms: uuioms
#### END ORIGINS/CHECKS uuioms.F
#### ORIGINS/CHECKS uvclst.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/uvclst-uvclst.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/uvclst-ufortw.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/uvclst-udbgst.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/uvclst-ustrmn.Pf@am__quote@ # am--include-marker
uvclst_CPPFLAGS = -DTEST_UVCLST=1
uvclst-uvclst.f: uvclst.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(uvclst_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(uvclst_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
uvclst-ufortw.f: ufortw.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(uvclst_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(uvclst_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
uvclst-udbgst.f: udbgst.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(uvclst_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(uvclst_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
uvclst-ustrmn.f: ustrmn.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(uvclst_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(uvclst_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_uvclst_SOURCES = uvclst-uvclst.f uvclst-ufortw.f uvclst-udbgst.f uvclst-ustrmn.f
srcchk-uvclst: $(nodist_uvclst_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_uvclst_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-uvclst: $(nodist_uvclst_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_uvclst_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-uvclst.f: $(nodist_uvclst_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_uvclst_SOURCES)" || cat $(nodist_uvclst_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
CLEANFILES += uvclst-uvclst.f uvclst-ufortw.f uvclst-udbgst.f uvclst-ustrmn.f bundle-uvclst.f
check_PROGRAMS += uvclst
srcchk-all: srcchk-uvclst
sublist-all: sublist-uvclst
bundle-all: bundle-uvclst.f
check-uvclst: uvclst
#### END ORIGINS/CHECKS uvclst.F
#### ORIGINS/CHECKS uxhcal.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/uxhcal-uxhcal.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/uxhcal-uxunit.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/uxhcal-udbgst.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/uxhcal-ustrmn.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/uxhcal-ufortw.Pf@am__quote@ # am--include-marker
uxhcal_CPPFLAGS = -DTEST_UXHCAL=1
uxhcal-uxhcal.f: uxhcal.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(uxhcal_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(uxhcal_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
uxhcal-uxunit.f: uxunit.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(uxhcal_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(uxhcal_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
uxhcal-udbgst.f: udbgst.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(uxhcal_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(uxhcal_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
uxhcal-ustrmn.f: ustrmn.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(uxhcal_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(uxhcal_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
uxhcal-ufortw.f: ufortw.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(uxhcal_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(uxhcal_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_uxhcal_SOURCES = uxhcal-uxhcal.f uxhcal-uxunit.f uxhcal-udbgst.f uxhcal-ustrmn.f uxhcal-ufortw.f
srcchk-uxhcal: $(nodist_uxhcal_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_uxhcal_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-uxhcal: $(nodist_uxhcal_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_uxhcal_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-uxhcal.f: $(nodist_uxhcal_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_uxhcal_SOURCES)" || cat $(nodist_uxhcal_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
CLEANFILES += uxhcal-uxhcal.f uxhcal-uxunit.f uxhcal-udbgst.f uxhcal-ustrmn.f uxhcal-ufortw.f bundle-uxhcal.f
check_PROGRAMS += uxhcal
srcchk-all: srcchk-uxhcal
sublist-all: sublist-uxhcal
bundle-all: bundle-uxhcal.f
check-uxhcal: uxhcal
#### END ORIGINS/CHECKS uxhcal.F
#### ORIGINS/CHECKS uxunit.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/uxunit-uxunit.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/uxunit-ufortw.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/uxunit-udbgst.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/uxunit-ustrmn.Pf@am__quote@ # am--include-marker
uxunit_CPPFLAGS = -DTEST_UXUNIT=1
uxunit-uxunit.f: uxunit.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(uxunit_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(uxunit_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
uxunit-ufortw.f: ufortw.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(uxunit_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(uxunit_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
uxunit-udbgst.f: udbgst.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(uxunit_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(uxunit_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
uxunit-ustrmn.f: ustrmn.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(uxunit_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(uxunit_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_uxunit_SOURCES = uxunit-uxunit.f uxunit-ufortw.f uxunit-udbgst.f uxunit-ustrmn.f
srcchk-uxunit: $(nodist_uxunit_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_uxunit_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-uxunit: $(nodist_uxunit_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_uxunit_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-uxunit.f: $(nodist_uxunit_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_uxunit_SOURCES)" || cat $(nodist_uxunit_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
CLEANFILES += uxunit-uxunit.f uxunit-ufortw.f uxunit-udbgst.f uxunit-ustrmn.f bundle-uxunit.f
check_PROGRAMS += uxunit
srcchk-all: srcchk-uxunit
sublist-all: sublist-uxunit
bundle-all: bundle-uxunit.f
check-uxunit: uxunit
#### END ORIGINS/CHECKS uxunit.F
am__depfiles_remade = ./$(DEPDIR)/ufortw.Pf ./$(DEPDIR)/udbgst.Pf ./$(DEPDIR)/ustrmn.Pf ./$(DEPDIR)/uarmpi.Pf ./$(DEPDIR)/ukvtbl.Pf ./$(DEPDIR)/ueaoms.Pf ./$(DEPDIR)/utmplm.Pf ./$(DEPDIR)/uuioms.Pf ./$(DEPDIR)/usymch.Pf ./$(DEPDIR)/unmlem.Pf ./$(DEPDIR)/uxunit.Pf ./$(DEPDIR)/uxhcal.Pf ./$(DEPDIR)/uvclst.Pf ./$(DEPDIR)/uprfem.Pf ./$(DEPDIR)/uarmpi1-uarmpi.Pf ./$(DEPDIR)/uarmpi2-uarmpi.Pf ./$(DEPDIR)/uarmpi3-uarmpi.Pf ./$(DEPDIR)/udbgst-udbgst.Pf ./$(DEPDIR)/udbgst-ufortw.Pf ./$(DEPDIR)/udbgst-ustrmn.Pf ./$(DEPDIR)/ueaoms1-ueaoms.Pf ./$(DEPDIR)/ueaoms2-ueaoms.Pf ./$(DEPDIR)/ueaoms3-ueaoms.Pf ./$(DEPDIR)/ufortw1-ufortw.Pf ./$(DEPDIR)/ufortw2-ufortw.Pf ./$(DEPDIR)/ufortw3-ufortw.Pf ./$(DEPDIR)/ukvtbl-ukvtbl.Pf ./$(DEPDIR)/unmlem-unmlem.Pf ./$(DEPDIR)/unmlem-ufortw.Pf ./$(DEPDIR)/unmlem-uuioms.Pf ./$(DEPDIR)/unmlem-ustrmn.Pf ./$(DEPDIR)/unmlem-udbgst.Pf ./$(DEPDIR)/uprfem-uprfem.Pf ./$(DEPDIR)/ustrmn-ustrmn.Pf ./$(DEPDIR)/ustrmn-ufortw.Pf ./$(DEPDIR)/usymch-usymch.Pf ./$(DEPDIR)/utmplm-utmplm.Pf ./$(DEPDIR)/utmplm-ufortw.Pf ./$(DEPDIR)/utmplm-udbgst.Pf ./$(DEPDIR)/utmplm-ukvtbl.Pf ./$(DEPDIR)/utmplm-ustrmn.Pf ./$(DEPDIR)/uuioms-uuioms.Pf ./$(DEPDIR)/uuioms-ufortw.Pf ./$(DEPDIR)/uuioms-udbgst.Pf ./$(DEPDIR)/uuioms-ustrmn.Pf ./$(DEPDIR)/uvclst-uvclst.Pf ./$(DEPDIR)/uvclst-ufortw.Pf ./$(DEPDIR)/uvclst-udbgst.Pf ./$(DEPDIR)/uvclst-ustrmn.Pf ./$(DEPDIR)/uxhcal-uxhcal.Pf ./$(DEPDIR)/uxhcal-uxunit.Pf ./$(DEPDIR)/uxhcal-udbgst.Pf ./$(DEPDIR)/uxhcal-ustrmn.Pf ./$(DEPDIR)/uxhcal-ufortw.Pf ./$(DEPDIR)/uxunit-uxunit.Pf ./$(DEPDIR)/uxunit-ufortw.Pf ./$(DEPDIR)/uxunit-udbgst.Pf ./$(DEPDIR)/uxunit-ustrmn.Pf
LCLCNDH = $(builddir)/lclcnd.h
MAINTAINERCLEANFILES = $(LCLDNDH)
#### DEP-DIR
LIB_DEPEND_BASE = src
LIB_DEPEND_NAME = libicies_local.la
#### END DEP-DIR
