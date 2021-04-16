# IcIES/src/begleitung
# Author: SAITO Fuyuki
# Created: Aug 8 2013
# Time-stamp: <2020/09/15 11:03:22 fuyuki Makefile.tmpl>

# Copyright: 2013--2020 JAMSTEC, Ayako ABE-OUCHI
# Licensed under the Apache License, Version 2.0
#   (https://www.apache.org/licenses/LICENSE-2.0)

libicies_local_la_ORIGINS	= bglbrt.F

BUILT_SOURCES	=	begleitung.h
EXTRA_DIST  	=	begleitung.m4 $(BUILT_SOURCES) ##%% a
MAINTAINERCLEANFILES = $(BUILT_SOURCES)  ##%% a


SQIHELP	= $(top_srcdir)/build-aux/icies/sqihelp
if MAINTAINER_MODE
begleitung.h: begleitung.m4
	$(SQIHELP) -o $@ $<
else
begleitung.h: begleitung.m4
	@if test -f $@; then \
		echo keep $@; \
	elif test -f $(srcdir)/$@; then \
		$(CP) $(srcdir)/$@ $(builddir); \
	else \
		$(SQIHELP) -o $@ $<; \
	fi
endif

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
EXTRA_DIST += $(LCLCNDH) Makefile.tmpl
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
bglbrt.$(OBJEXT): bglbrt.f
ta__copy_source_targets = copy-bglbrt.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/bglbrt.Pf@am__quote@ # am--include-marker
EXTRA_DIST += $(libicies_local_la_ORIGINS)
CLC_SRCS = $(libicies_local_la_ORIGINS)
nodist_libicies_local_la_SOURCES = bglbrt.f
CLEANFILES = bglbrt.f gather_libicies_local_la.f
CATALL_files = gather_libicies_local_la.f
gather_libicies_local_la.f: $(nodist_libicies_local_la_SOURCES)
	test -z "$(nodist_libicies_local_la_SOURCES)" || cat $(nodist_libicies_local_la_SOURCES) > $@ || rm -f $@
#### END BUILD libicies_local.la
#### END BUILD FAMILY noinst_LTLIBRARIES
#### ORIGINS/CHECKS bglbrt.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/bglbrt-bglbrt.Pf@am__quote@ # am--include-marker
bglbrt_CPPFLAGS = -DTEST_BGLBRT=1
bglbrt-bglbrt.f: bglbrt.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(bglbrt_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(bglbrt_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_bglbrt_SOURCES = bglbrt-bglbrt.f
srcchk-bglbrt: $(nodist_bglbrt_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_bglbrt_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-bglbrt: $(nodist_bglbrt_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_bglbrt_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-bglbrt.f: $(nodist_bglbrt_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_bglbrt_SOURCES)" || cat $(nodist_bglbrt_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
CLEANFILES += bglbrt-bglbrt.f bundle-bglbrt.f
check_PROGRAMS = bglbrt
srcchk-all: srcchk-bglbrt
sublist-all: sublist-bglbrt
bundle-all: bundle-bglbrt.f
check-bglbrt: bglbrt
#### END ORIGINS/CHECKS bglbrt.F
am__depfiles_remade = ./$(DEPDIR)/bglbrt.Pf ./$(DEPDIR)/bglbrt-bglbrt.Pf
LCLCNDH = $(builddir)/lclcnd.h
MAINTAINERCLEANFILES += $(LCLDNDH)
#### DEP-DIR
LIB_DEPEND_BASE = src
LIB_DEPEND_NAME = libicies_local.la
#### END DEP-DIR
