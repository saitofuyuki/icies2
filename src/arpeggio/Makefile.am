# arpeggio/Makefile.tmpl --- Arpeggio Makefile.am template
# Maintainer:  SAITO Fuyuki
# Created: Nov 4 2011
# Revision:  Arpeggio 1.0
# Time-stamp: <2020/09/15 22:30:01 fuyuki Makefile.tmpl>

# Copyright: 2011--2020 JAMSTEC
# Licensed under the Apache License, Version 2.0
#   (https://www.apache.org/licenses/LICENSE-2.0)

libicies_local_la_ORIGINS	= acorms.F agmtry.F aedlra.F akwopr.F afintf.F apscfg.F arpmng.F
EXTRA_SRCS =

LIB_DEPEND_DIRS	=	development unison

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
acorms.$(OBJEXT): acorms.f
agmtry.$(OBJEXT): agmtry.f
aedlra.$(OBJEXT): aedlra.f
akwopr.$(OBJEXT): akwopr.f
afintf.$(OBJEXT): afintf.f
apscfg.$(OBJEXT): apscfg.f
arpmng.$(OBJEXT): arpmng.f
ta__copy_source_targets = copy-acorms.F copy-agmtry.F copy-aedlra.F copy-akwopr.F copy-afintf.F copy-apscfg.F copy-arpmng.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/acorms.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/agmtry.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/aedlra.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/akwopr.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/afintf.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/apscfg.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/arpmng.Pf@am__quote@ # am--include-marker
EXTRA_DIST += $(libicies_local_la_ORIGINS)
CLC_SRCS = $(libicies_local_la_ORIGINS)
nodist_libicies_local_la_SOURCES = acorms.f agmtry.f aedlra.f akwopr.f afintf.f apscfg.f arpmng.f
CLEANFILES = acorms.f agmtry.f aedlra.f akwopr.f afintf.f apscfg.f arpmng.f gather_libicies_local_la.f
CATALL_files = gather_libicies_local_la.f
gather_libicies_local_la.f: $(nodist_libicies_local_la_SOURCES)
	test -z "$(nodist_libicies_local_la_SOURCES)" || cat $(nodist_libicies_local_la_SOURCES) > $@ || rm -f $@
#### END BUILD libicies_local.la
#### END BUILD FAMILY noinst_LTLIBRARIES
#### ORIGINS/CHECKS acorms.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/acorms-acorms.Pf@am__quote@ # am--include-marker
acorms_CPPFLAGS = -DTEST_ACORMS=1
acorms-acorms.f: acorms.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(acorms_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(acorms_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_acorms_SOURCES = acorms-acorms.f
srcchk-acorms: $(nodist_acorms_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_acorms_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-acorms: $(nodist_acorms_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_acorms_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-acorms.f: $(nodist_acorms_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_acorms_SOURCES)" || cat $(nodist_acorms_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
CLEANFILES += acorms-acorms.f bundle-acorms.f
check_PROGRAMS = acorms
srcchk-all: srcchk-acorms
sublist-all: sublist-acorms
bundle-all: bundle-acorms.f
check-acorms: acorms
#### END ORIGINS/CHECKS acorms.F
#### ORIGINS/CHECKS aedlra.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/aedlra1-aedlra.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/aedlra2-aedlra.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/aedlra3-aedlra.Pf@am__quote@ # am--include-marker
aedlra1_CPPFLAGS = -DTEST_AEDLRA=1
aedlra1-aedlra.f: aedlra.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(aedlra1_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(aedlra1_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_aedlra1_SOURCES = aedlra1-aedlra.f
srcchk-aedlra1: $(nodist_aedlra1_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_aedlra1_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-aedlra1: $(nodist_aedlra1_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_aedlra1_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-aedlra1.f: $(nodist_aedlra1_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_aedlra1_SOURCES)" || cat $(nodist_aedlra1_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
aedlra2_CPPFLAGS = -DTEST_AEDLRA=2
aedlra2-aedlra.f: aedlra.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(aedlra2_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(aedlra2_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_aedlra2_SOURCES = aedlra2-aedlra.f
srcchk-aedlra2: $(nodist_aedlra2_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_aedlra2_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-aedlra2: $(nodist_aedlra2_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_aedlra2_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-aedlra2.f: $(nodist_aedlra2_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_aedlra2_SOURCES)" || cat $(nodist_aedlra2_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
aedlra3_CPPFLAGS = -DTEST_AEDLRA=3
aedlra3-aedlra.f: aedlra.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(aedlra3_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(aedlra3_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_aedlra3_SOURCES = aedlra3-aedlra.f
srcchk-aedlra3: $(nodist_aedlra3_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_aedlra3_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-aedlra3: $(nodist_aedlra3_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_aedlra3_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-aedlra3.f: $(nodist_aedlra3_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_aedlra3_SOURCES)" || cat $(nodist_aedlra3_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
CLEANFILES += aedlra1-aedlra.f bundle-aedlra1.f aedlra2-aedlra.f bundle-aedlra2.f aedlra3-aedlra.f bundle-aedlra3.f
check_PROGRAMS += aedlra1 aedlra2 aedlra3
srcchk-all: srcchk-aedlra1 srcchk-aedlra2 srcchk-aedlra3
sublist-all: sublist-aedlra1 sublist-aedlra2 sublist-aedlra3
bundle-all: bundle-aedlra1.f bundle-aedlra2.f bundle-aedlra3.f
check-aedlra: aedlra1 aedlra2 aedlra3
#### END ORIGINS/CHECKS aedlra.F
#### ORIGINS/CHECKS afintf.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/afintf-afintf.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/afintf-acorms.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/afintf-aedlra.Pf@am__quote@ # am--include-marker
afintf_CPPFLAGS = -DTEST_AFINTF=1
afintf-afintf.f: afintf.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(afintf_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(afintf_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
afintf-acorms.f: acorms.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(afintf_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(afintf_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
afintf-aedlra.f: aedlra.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(afintf_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(afintf_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_afintf_SOURCES = afintf-afintf.f afintf-acorms.f afintf-aedlra.f
srcchk-afintf: $(nodist_afintf_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_afintf_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-afintf: $(nodist_afintf_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_afintf_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-afintf.f: $(nodist_afintf_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_afintf_SOURCES)" || cat $(nodist_afintf_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
CLEANFILES += afintf-afintf.f afintf-acorms.f afintf-aedlra.f bundle-afintf.f
check_PROGRAMS += afintf
srcchk-all: srcchk-afintf
sublist-all: sublist-afintf
bundle-all: bundle-afintf.f
check-afintf: afintf
#### END ORIGINS/CHECKS afintf.F
#### ORIGINS/CHECKS agmtry.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/agmtry1-agmtry.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/agmtry1-acorms.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/agmtry2-agmtry.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/agmtry2-acorms.Pf@am__quote@ # am--include-marker
agmtry1_CPPFLAGS = -DTEST_AGMTRY=1
agmtry1-agmtry.f: agmtry.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(agmtry1_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(agmtry1_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
agmtry1-acorms.f: acorms.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(agmtry1_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(agmtry1_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_agmtry1_SOURCES = agmtry1-agmtry.f agmtry1-acorms.f
srcchk-agmtry1: $(nodist_agmtry1_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_agmtry1_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-agmtry1: $(nodist_agmtry1_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_agmtry1_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-agmtry1.f: $(nodist_agmtry1_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_agmtry1_SOURCES)" || cat $(nodist_agmtry1_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
agmtry2_CPPFLAGS = -DTEST_AGMTRY=2
agmtry2-agmtry.f: agmtry.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(agmtry2_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(agmtry2_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
agmtry2-acorms.f: acorms.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(agmtry2_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(agmtry2_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_agmtry2_SOURCES = agmtry2-agmtry.f agmtry2-acorms.f
srcchk-agmtry2: $(nodist_agmtry2_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_agmtry2_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-agmtry2: $(nodist_agmtry2_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_agmtry2_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-agmtry2.f: $(nodist_agmtry2_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_agmtry2_SOURCES)" || cat $(nodist_agmtry2_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
CLEANFILES += agmtry1-agmtry.f agmtry1-acorms.f bundle-agmtry1.f agmtry2-agmtry.f agmtry2-acorms.f bundle-agmtry2.f
check_PROGRAMS += agmtry1 agmtry2
srcchk-all: srcchk-agmtry1 srcchk-agmtry2
sublist-all: sublist-agmtry1 sublist-agmtry2
bundle-all: bundle-agmtry1.f bundle-agmtry2.f
check-agmtry: agmtry1 agmtry2
#### END ORIGINS/CHECKS agmtry.F
#### ORIGINS/CHECKS akwopr.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/akwopr-akwopr.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/akwopr-agmtry.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/akwopr-acorms.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/akwopr-aedlra.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/akwopr-afintf.Pf@am__quote@ # am--include-marker
akwopr_CPPFLAGS = -DTEST_AKWOPR=1 -DTEST_AEDLRA_CFG=1
akwopr-akwopr.f: akwopr.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(akwopr_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(akwopr_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
akwopr-agmtry.f: agmtry.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(akwopr_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(akwopr_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
akwopr-acorms.f: acorms.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(akwopr_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(akwopr_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
akwopr-aedlra.f: aedlra.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(akwopr_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(akwopr_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
akwopr-afintf.f: afintf.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(akwopr_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(akwopr_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_akwopr_SOURCES = akwopr-akwopr.f akwopr-agmtry.f akwopr-acorms.f akwopr-aedlra.f akwopr-afintf.f
srcchk-akwopr: $(nodist_akwopr_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_akwopr_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-akwopr: $(nodist_akwopr_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_akwopr_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-akwopr.f: $(nodist_akwopr_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_akwopr_SOURCES)" || cat $(nodist_akwopr_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
CLEANFILES += akwopr-akwopr.f akwopr-agmtry.f akwopr-acorms.f akwopr-aedlra.f akwopr-afintf.f bundle-akwopr.f
check_PROGRAMS += akwopr
srcchk-all: srcchk-akwopr
sublist-all: sublist-akwopr
bundle-all: bundle-akwopr.f
check-akwopr: akwopr
#### END ORIGINS/CHECKS akwopr.F
#### ORIGINS/CHECKS apscfg.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/apscfg-apscfg.Pf@am__quote@ # am--include-marker
apscfg_CPPFLAGS = -DTEST_APSCFG=1
apscfg-apscfg.f: apscfg.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(apscfg_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(apscfg_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_apscfg_SOURCES = apscfg-apscfg.f
srcchk-apscfg: $(nodist_apscfg_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_apscfg_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-apscfg: $(nodist_apscfg_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_apscfg_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-apscfg.f: $(nodist_apscfg_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_apscfg_SOURCES)" || cat $(nodist_apscfg_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
CLEANFILES += apscfg-apscfg.f bundle-apscfg.f
check_PROGRAMS += apscfg
srcchk-all: srcchk-apscfg
sublist-all: sublist-apscfg
bundle-all: bundle-apscfg.f
check-apscfg: apscfg
#### END ORIGINS/CHECKS apscfg.F
#### ORIGINS/CHECKS arpmng.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/arpmng-arpmng.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/arpmng-agmtry.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/arpmng-acorms.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/arpmng-akwopr.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/arpmng-aedlra.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/arpmng-afintf.Pf@am__quote@ # am--include-marker
arpmng_CPPFLAGS = -DTEST_ARPMNG=1 -DTEST_AEDLRA_CFG=1
arpmng-arpmng.f: arpmng.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(arpmng_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(arpmng_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
arpmng-agmtry.f: agmtry.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(arpmng_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(arpmng_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
arpmng-acorms.f: acorms.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(arpmng_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(arpmng_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
arpmng-akwopr.f: akwopr.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(arpmng_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(arpmng_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
arpmng-aedlra.f: aedlra.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(arpmng_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(arpmng_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
arpmng-afintf.f: afintf.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(arpmng_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(arpmng_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_arpmng_SOURCES = arpmng-arpmng.f arpmng-agmtry.f arpmng-acorms.f arpmng-akwopr.f arpmng-aedlra.f arpmng-afintf.f
srcchk-arpmng: $(nodist_arpmng_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_arpmng_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-arpmng: $(nodist_arpmng_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_arpmng_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-arpmng.f: $(nodist_arpmng_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_arpmng_SOURCES)" || cat $(nodist_arpmng_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
CLEANFILES += arpmng-arpmng.f arpmng-agmtry.f arpmng-acorms.f arpmng-akwopr.f arpmng-aedlra.f arpmng-afintf.f bundle-arpmng.f
check_PROGRAMS += arpmng
srcchk-all: srcchk-arpmng
sublist-all: sublist-arpmng
bundle-all: bundle-arpmng.f
check-arpmng: arpmng
#### END ORIGINS/CHECKS arpmng.F
am__depfiles_remade = ./$(DEPDIR)/acorms.Pf ./$(DEPDIR)/agmtry.Pf ./$(DEPDIR)/aedlra.Pf ./$(DEPDIR)/akwopr.Pf ./$(DEPDIR)/afintf.Pf ./$(DEPDIR)/apscfg.Pf ./$(DEPDIR)/arpmng.Pf ./$(DEPDIR)/acorms-acorms.Pf ./$(DEPDIR)/aedlra1-aedlra.Pf ./$(DEPDIR)/aedlra2-aedlra.Pf ./$(DEPDIR)/aedlra3-aedlra.Pf ./$(DEPDIR)/afintf-afintf.Pf ./$(DEPDIR)/afintf-acorms.Pf ./$(DEPDIR)/afintf-aedlra.Pf ./$(DEPDIR)/agmtry1-agmtry.Pf ./$(DEPDIR)/agmtry1-acorms.Pf ./$(DEPDIR)/agmtry2-agmtry.Pf ./$(DEPDIR)/agmtry2-acorms.Pf ./$(DEPDIR)/akwopr-akwopr.Pf ./$(DEPDIR)/akwopr-agmtry.Pf ./$(DEPDIR)/akwopr-acorms.Pf ./$(DEPDIR)/akwopr-aedlra.Pf ./$(DEPDIR)/akwopr-afintf.Pf ./$(DEPDIR)/apscfg-apscfg.Pf ./$(DEPDIR)/arpmng-arpmng.Pf ./$(DEPDIR)/arpmng-agmtry.Pf ./$(DEPDIR)/arpmng-acorms.Pf ./$(DEPDIR)/arpmng-akwopr.Pf ./$(DEPDIR)/arpmng-aedlra.Pf ./$(DEPDIR)/arpmng-afintf.Pf
LCLCNDH = $(builddir)/lclcnd.h
MAINTAINERCLEANFILES = $(LCLDNDH)
#### DEP-DIR
LIB_DEPEND_BASE = src
LIB_DEPEND_NAME = libicies_local.la
LDADD = $(top_builddir)/src/development/libicies_local.la $(top_builddir)/src/unison/libicies_local.la
FORTRAN_CHECK_ADD = $(top_builddir)/src/development/gather_libicies_local_la.f $(top_builddir)/src/unison/gather_libicies_local_la.f
#### END DEP-DIR
