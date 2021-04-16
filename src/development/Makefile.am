# src/development/Makefile.tmpl --- IcIES/Development Makefile.am template
# Maintainer:  SAITO Fuyuki
# Created: Nov 2 2011
# Revision:  Snoopy0.9
# Time-stamp: <2020/09/15 11:03:00 fuyuki Makefile.tmpl>

# Copyright: 2011--2020 JAMSTEC, Ayako ABE-OUCHI
# Licensed under the Apache License, Version 2.0
#   (https://www.apache.org/licenses/LICENSE-2.0)

libicies_local_la_ORIGINS	=	danntr.F denvms.F \
								dbstrp.F dpathn.F dmpims.F dlogms.F dvioms.F \
								ddroot.F

LIB_DEPEND_DIRS	=	unison

EXTRA_DIST = dvainc.F dvainc.m4 ##%% a

dvioms.f: dvainc.F

BUILT_SOURCES	=	dvainc.F
MAINTAINERCLEANFILES = dvainc.F ##%% a

CREATE_DVAINC = $(AUTOM4TE) -l M4sugar -o $@ $<
if MAINTAINER_MODE
# always try to build when maintainer-mode
dvainc.F: dvainc.m4
	$(CREATE_DVAINC)
else
dvainc.F: dvainc.m4
	@if test -f $@; then \
       echo keep $@; \
    elif -f $(srcdir)/$@; then \
       $(CP) $(srcdir)/$@ $@; \
    else $(CREATE_DVAINC); fi
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
danntr.$(OBJEXT): danntr.f
denvms.$(OBJEXT): denvms.f
dbstrp.$(OBJEXT): dbstrp.f
dpathn.$(OBJEXT): dpathn.f
dmpims.$(OBJEXT): dmpims.f
dlogms.$(OBJEXT): dlogms.f
dvioms.$(OBJEXT): dvioms.f
ddroot.$(OBJEXT): ddroot.f
ta__copy_source_targets = copy-danntr.F copy-denvms.F copy-dbstrp.F copy-dpathn.F copy-dmpims.F copy-dlogms.F copy-dvioms.F copy-ddroot.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/danntr.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/denvms.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/dbstrp.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/dpathn.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/dmpims.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/dlogms.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/dvioms.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/ddroot.Pf@am__quote@ # am--include-marker
EXTRA_DIST += $(libicies_local_la_ORIGINS)
CLC_SRCS = $(libicies_local_la_ORIGINS)
nodist_libicies_local_la_SOURCES = danntr.f denvms.f dbstrp.f dpathn.f dmpims.f dlogms.f dvioms.f ddroot.f
CLEANFILES = danntr.f denvms.f dbstrp.f dpathn.f dmpims.f dlogms.f dvioms.f ddroot.f gather_libicies_local_la.f
CATALL_files = gather_libicies_local_la.f
gather_libicies_local_la.f: $(nodist_libicies_local_la_SOURCES)
	test -z "$(nodist_libicies_local_la_SOURCES)" || cat $(nodist_libicies_local_la_SOURCES) > $@ || rm -f $@
#### END BUILD libicies_local.la
#### END BUILD FAMILY noinst_LTLIBRARIES
#### ORIGINS/CHECKS danntr.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/danntr-danntr.Pf@am__quote@ # am--include-marker
danntr_CPPFLAGS = -DTEST_DANNTR=1
danntr-danntr.f: danntr.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(danntr_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(danntr_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_danntr_SOURCES = danntr-danntr.f
srcchk-danntr: $(nodist_danntr_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_danntr_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-danntr: $(nodist_danntr_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_danntr_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-danntr.f: $(nodist_danntr_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_danntr_SOURCES)" || cat $(nodist_danntr_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
CLEANFILES += danntr-danntr.f bundle-danntr.f
check_PROGRAMS = danntr
srcchk-all: srcchk-danntr
sublist-all: sublist-danntr
bundle-all: bundle-danntr.f
check-danntr: danntr
#### END ORIGINS/CHECKS danntr.F
#### ORIGINS/CHECKS dbstrp.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/dbstrp-dbstrp.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/dbstrp-denvms.Pf@am__quote@ # am--include-marker
dbstrp_CPPFLAGS = -DTEST_DBSTRP=1
dbstrp-dbstrp.f: dbstrp.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(dbstrp_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(dbstrp_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
dbstrp-denvms.f: denvms.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(dbstrp_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(dbstrp_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_dbstrp_SOURCES = dbstrp-dbstrp.f dbstrp-denvms.f
srcchk-dbstrp: $(nodist_dbstrp_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_dbstrp_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-dbstrp: $(nodist_dbstrp_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_dbstrp_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-dbstrp.f: $(nodist_dbstrp_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_dbstrp_SOURCES)" || cat $(nodist_dbstrp_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
CLEANFILES += dbstrp-dbstrp.f dbstrp-denvms.f bundle-dbstrp.f
check_PROGRAMS += dbstrp
srcchk-all: srcchk-dbstrp
sublist-all: sublist-dbstrp
bundle-all: bundle-dbstrp.f
check-dbstrp: dbstrp
#### END ORIGINS/CHECKS dbstrp.F
#### ORIGINS/CHECKS ddroot.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/ddroot-ddroot.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/ddroot-dpathn.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/ddroot-danntr.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/ddroot-denvms.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/ddroot-dbstrp.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/ddroot-dlogms.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/ddroot-dmpims.Pf@am__quote@ # am--include-marker
ddroot_CPPFLAGS = -DTEST_DDROOT=1
ddroot-ddroot.f: ddroot.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(ddroot_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(ddroot_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
ddroot-dpathn.f: dpathn.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(ddroot_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(ddroot_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
ddroot-danntr.f: danntr.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(ddroot_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(ddroot_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
ddroot-denvms.f: denvms.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(ddroot_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(ddroot_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
ddroot-dbstrp.f: dbstrp.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(ddroot_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(ddroot_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
ddroot-dlogms.f: dlogms.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(ddroot_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(ddroot_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
ddroot-dmpims.f: dmpims.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(ddroot_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(ddroot_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_ddroot_SOURCES = ddroot-ddroot.f ddroot-dpathn.f ddroot-danntr.f ddroot-denvms.f ddroot-dbstrp.f ddroot-dlogms.f ddroot-dmpims.f
srcchk-ddroot: $(nodist_ddroot_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_ddroot_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-ddroot: $(nodist_ddroot_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_ddroot_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-ddroot.f: $(nodist_ddroot_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_ddroot_SOURCES)" || cat $(nodist_ddroot_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
CLEANFILES += ddroot-ddroot.f ddroot-dpathn.f ddroot-danntr.f ddroot-denvms.f ddroot-dbstrp.f ddroot-dlogms.f ddroot-dmpims.f bundle-ddroot.f
check_PROGRAMS += ddroot
srcchk-all: srcchk-ddroot
sublist-all: sublist-ddroot
bundle-all: bundle-ddroot.f
check-ddroot: ddroot
#### END ORIGINS/CHECKS ddroot.F
#### ORIGINS/CHECKS denvms.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/denvms-denvms.Pf@am__quote@ # am--include-marker
denvms_CPPFLAGS = -DTEST_DENVMS=1
denvms-denvms.f: denvms.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(denvms_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(denvms_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_denvms_SOURCES = denvms-denvms.f
srcchk-denvms: $(nodist_denvms_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_denvms_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-denvms: $(nodist_denvms_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_denvms_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-denvms.f: $(nodist_denvms_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_denvms_SOURCES)" || cat $(nodist_denvms_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
CLEANFILES += denvms-denvms.f bundle-denvms.f
check_PROGRAMS += denvms
srcchk-all: srcchk-denvms
sublist-all: sublist-denvms
bundle-all: bundle-denvms.f
check-denvms: denvms
#### END ORIGINS/CHECKS denvms.F
#### ORIGINS/CHECKS dlogms.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/dlogms1-dlogms.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/dlogms1-dmpims.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/dlogms1-dpathn.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/dlogms1-danntr.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/dlogms1-denvms.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/dlogms1-dbstrp.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/dlogms2-dlogms.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/dlogms2-dmpims.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/dlogms2-dpathn.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/dlogms2-danntr.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/dlogms2-denvms.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/dlogms2-dbstrp.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/dlogms3-dlogms.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/dlogms3-dmpims.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/dlogms3-dpathn.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/dlogms3-danntr.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/dlogms3-denvms.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/dlogms3-dbstrp.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/dlogms4-dlogms.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/dlogms4-dmpims.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/dlogms4-dpathn.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/dlogms4-danntr.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/dlogms4-denvms.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/dlogms4-dbstrp.Pf@am__quote@ # am--include-marker
dlogms1_CPPFLAGS = -DTEST_DLOGMS=1
dlogms1-dlogms.f: dlogms.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(dlogms1_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(dlogms1_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
dlogms1-dmpims.f: dmpims.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(dlogms1_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(dlogms1_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
dlogms1-dpathn.f: dpathn.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(dlogms1_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(dlogms1_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
dlogms1-danntr.f: danntr.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(dlogms1_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(dlogms1_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
dlogms1-denvms.f: denvms.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(dlogms1_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(dlogms1_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
dlogms1-dbstrp.f: dbstrp.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(dlogms1_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(dlogms1_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_dlogms1_SOURCES = dlogms1-dlogms.f dlogms1-dmpims.f dlogms1-dpathn.f dlogms1-danntr.f dlogms1-denvms.f dlogms1-dbstrp.f
srcchk-dlogms1: $(nodist_dlogms1_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_dlogms1_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-dlogms1: $(nodist_dlogms1_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_dlogms1_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-dlogms1.f: $(nodist_dlogms1_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_dlogms1_SOURCES)" || cat $(nodist_dlogms1_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
dlogms2_CPPFLAGS = -DTEST_DLOGMS=2
dlogms2-dlogms.f: dlogms.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(dlogms2_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(dlogms2_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
dlogms2-dmpims.f: dmpims.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(dlogms2_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(dlogms2_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
dlogms2-dpathn.f: dpathn.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(dlogms2_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(dlogms2_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
dlogms2-danntr.f: danntr.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(dlogms2_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(dlogms2_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
dlogms2-denvms.f: denvms.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(dlogms2_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(dlogms2_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
dlogms2-dbstrp.f: dbstrp.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(dlogms2_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(dlogms2_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_dlogms2_SOURCES = dlogms2-dlogms.f dlogms2-dmpims.f dlogms2-dpathn.f dlogms2-danntr.f dlogms2-denvms.f dlogms2-dbstrp.f
srcchk-dlogms2: $(nodist_dlogms2_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_dlogms2_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-dlogms2: $(nodist_dlogms2_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_dlogms2_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-dlogms2.f: $(nodist_dlogms2_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_dlogms2_SOURCES)" || cat $(nodist_dlogms2_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
dlogms3_CPPFLAGS = -DTEST_DLOGMS=3
dlogms3-dlogms.f: dlogms.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(dlogms3_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(dlogms3_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
dlogms3-dmpims.f: dmpims.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(dlogms3_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(dlogms3_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
dlogms3-dpathn.f: dpathn.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(dlogms3_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(dlogms3_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
dlogms3-danntr.f: danntr.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(dlogms3_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(dlogms3_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
dlogms3-denvms.f: denvms.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(dlogms3_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(dlogms3_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
dlogms3-dbstrp.f: dbstrp.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(dlogms3_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(dlogms3_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_dlogms3_SOURCES = dlogms3-dlogms.f dlogms3-dmpims.f dlogms3-dpathn.f dlogms3-danntr.f dlogms3-denvms.f dlogms3-dbstrp.f
srcchk-dlogms3: $(nodist_dlogms3_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_dlogms3_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-dlogms3: $(nodist_dlogms3_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_dlogms3_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-dlogms3.f: $(nodist_dlogms3_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_dlogms3_SOURCES)" || cat $(nodist_dlogms3_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
dlogms4_CPPFLAGS = -DTEST_DLOGMS=4
dlogms4-dlogms.f: dlogms.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(dlogms4_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(dlogms4_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
dlogms4-dmpims.f: dmpims.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(dlogms4_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(dlogms4_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
dlogms4-dpathn.f: dpathn.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(dlogms4_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(dlogms4_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
dlogms4-danntr.f: danntr.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(dlogms4_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(dlogms4_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
dlogms4-denvms.f: denvms.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(dlogms4_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(dlogms4_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
dlogms4-dbstrp.f: dbstrp.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(dlogms4_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(dlogms4_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_dlogms4_SOURCES = dlogms4-dlogms.f dlogms4-dmpims.f dlogms4-dpathn.f dlogms4-danntr.f dlogms4-denvms.f dlogms4-dbstrp.f
srcchk-dlogms4: $(nodist_dlogms4_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_dlogms4_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-dlogms4: $(nodist_dlogms4_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_dlogms4_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-dlogms4.f: $(nodist_dlogms4_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_dlogms4_SOURCES)" || cat $(nodist_dlogms4_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
CLEANFILES += dlogms1-dlogms.f dlogms1-dmpims.f dlogms1-dpathn.f dlogms1-danntr.f dlogms1-denvms.f dlogms1-dbstrp.f bundle-dlogms1.f dlogms2-dlogms.f dlogms2-dmpims.f dlogms2-dpathn.f dlogms2-danntr.f dlogms2-denvms.f dlogms2-dbstrp.f bundle-dlogms2.f dlogms3-dlogms.f dlogms3-dmpims.f dlogms3-dpathn.f dlogms3-danntr.f dlogms3-denvms.f dlogms3-dbstrp.f bundle-dlogms3.f dlogms4-dlogms.f dlogms4-dmpims.f dlogms4-dpathn.f dlogms4-danntr.f dlogms4-denvms.f dlogms4-dbstrp.f bundle-dlogms4.f
check_PROGRAMS += dlogms1 dlogms2 dlogms3 dlogms4
srcchk-all: srcchk-dlogms1 srcchk-dlogms2 srcchk-dlogms3 srcchk-dlogms4
sublist-all: sublist-dlogms1 sublist-dlogms2 sublist-dlogms3 sublist-dlogms4
bundle-all: bundle-dlogms1.f bundle-dlogms2.f bundle-dlogms3.f bundle-dlogms4.f
check-dlogms: dlogms1 dlogms2 dlogms3 dlogms4
#### END ORIGINS/CHECKS dlogms.F
#### ORIGINS/CHECKS dmpims.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/dmpims1-dmpims.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/dmpims1-dpathn.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/dmpims1-danntr.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/dmpims1-denvms.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/dmpims1-dbstrp.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/dmpims2-dmpims.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/dmpims2-dpathn.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/dmpims2-danntr.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/dmpims2-denvms.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/dmpims2-dbstrp.Pf@am__quote@ # am--include-marker
dmpims1_CPPFLAGS = -DTEST_DMPIMS=1
dmpims1-dmpims.f: dmpims.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(dmpims1_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(dmpims1_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
dmpims1-dpathn.f: dpathn.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(dmpims1_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(dmpims1_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
dmpims1-danntr.f: danntr.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(dmpims1_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(dmpims1_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
dmpims1-denvms.f: denvms.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(dmpims1_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(dmpims1_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
dmpims1-dbstrp.f: dbstrp.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(dmpims1_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(dmpims1_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_dmpims1_SOURCES = dmpims1-dmpims.f dmpims1-dpathn.f dmpims1-danntr.f dmpims1-denvms.f dmpims1-dbstrp.f
srcchk-dmpims1: $(nodist_dmpims1_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_dmpims1_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-dmpims1: $(nodist_dmpims1_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_dmpims1_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-dmpims1.f: $(nodist_dmpims1_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_dmpims1_SOURCES)" || cat $(nodist_dmpims1_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
dmpims2_CPPFLAGS = -DTEST_DMPIMS=2
dmpims2-dmpims.f: dmpims.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(dmpims2_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(dmpims2_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
dmpims2-dpathn.f: dpathn.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(dmpims2_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(dmpims2_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
dmpims2-danntr.f: danntr.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(dmpims2_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(dmpims2_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
dmpims2-denvms.f: denvms.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(dmpims2_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(dmpims2_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
dmpims2-dbstrp.f: dbstrp.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(dmpims2_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(dmpims2_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_dmpims2_SOURCES = dmpims2-dmpims.f dmpims2-dpathn.f dmpims2-danntr.f dmpims2-denvms.f dmpims2-dbstrp.f
srcchk-dmpims2: $(nodist_dmpims2_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_dmpims2_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-dmpims2: $(nodist_dmpims2_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_dmpims2_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-dmpims2.f: $(nodist_dmpims2_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_dmpims2_SOURCES)" || cat $(nodist_dmpims2_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
CLEANFILES += dmpims1-dmpims.f dmpims1-dpathn.f dmpims1-danntr.f dmpims1-denvms.f dmpims1-dbstrp.f bundle-dmpims1.f dmpims2-dmpims.f dmpims2-dpathn.f dmpims2-danntr.f dmpims2-denvms.f dmpims2-dbstrp.f bundle-dmpims2.f
check_PROGRAMS += dmpims1 dmpims2
srcchk-all: srcchk-dmpims1 srcchk-dmpims2
sublist-all: sublist-dmpims1 sublist-dmpims2
bundle-all: bundle-dmpims1.f bundle-dmpims2.f
check-dmpims: dmpims1 dmpims2
#### END ORIGINS/CHECKS dmpims.F
#### ORIGINS/CHECKS dpathn.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/dpathn-dpathn.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/dpathn-dbstrp.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/dpathn-danntr.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/dpathn-denvms.Pf@am__quote@ # am--include-marker
dpathn_CPPFLAGS = -DTEST_DPATHN=1
dpathn-dpathn.f: dpathn.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(dpathn_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(dpathn_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
dpathn-dbstrp.f: dbstrp.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(dpathn_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(dpathn_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
dpathn-danntr.f: danntr.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(dpathn_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(dpathn_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
dpathn-denvms.f: denvms.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(dpathn_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(dpathn_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_dpathn_SOURCES = dpathn-dpathn.f dpathn-dbstrp.f dpathn-danntr.f dpathn-denvms.f
srcchk-dpathn: $(nodist_dpathn_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_dpathn_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-dpathn: $(nodist_dpathn_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_dpathn_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-dpathn.f: $(nodist_dpathn_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_dpathn_SOURCES)" || cat $(nodist_dpathn_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
CLEANFILES += dpathn-dpathn.f dpathn-dbstrp.f dpathn-danntr.f dpathn-denvms.f bundle-dpathn.f
check_PROGRAMS += dpathn
srcchk-all: srcchk-dpathn
sublist-all: sublist-dpathn
bundle-all: bundle-dpathn.f
check-dpathn: dpathn
#### END ORIGINS/CHECKS dpathn.F
#### ORIGINS/CHECKS dvioms.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/dvioms-dvioms.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/dvioms-dmpims.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/dvioms-dpathn.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/dvioms-danntr.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/dvioms-denvms.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/dvioms-dbstrp.Pf@am__quote@ # am--include-marker
dvioms_CPPFLAGS = -DTEST_DVIOMS=1
dvioms-dvioms.f: dvioms.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(dvioms_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(dvioms_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
dvioms-dmpims.f: dmpims.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(dvioms_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(dvioms_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
dvioms-dpathn.f: dpathn.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(dvioms_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(dvioms_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
dvioms-danntr.f: danntr.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(dvioms_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(dvioms_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
dvioms-denvms.f: denvms.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(dvioms_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(dvioms_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
dvioms-dbstrp.f: dbstrp.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(dvioms_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(dvioms_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_dvioms_SOURCES = dvioms-dvioms.f dvioms-dmpims.f dvioms-dpathn.f dvioms-danntr.f dvioms-denvms.f dvioms-dbstrp.f
srcchk-dvioms: $(nodist_dvioms_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_dvioms_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-dvioms: $(nodist_dvioms_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_dvioms_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-dvioms.f: $(nodist_dvioms_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_dvioms_SOURCES)" || cat $(nodist_dvioms_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
CLEANFILES += dvioms-dvioms.f dvioms-dmpims.f dvioms-dpathn.f dvioms-danntr.f dvioms-denvms.f dvioms-dbstrp.f bundle-dvioms.f
check_PROGRAMS += dvioms
srcchk-all: srcchk-dvioms
sublist-all: sublist-dvioms
bundle-all: bundle-dvioms.f
check-dvioms: dvioms
#### END ORIGINS/CHECKS dvioms.F
am__depfiles_remade = ./$(DEPDIR)/danntr.Pf ./$(DEPDIR)/denvms.Pf ./$(DEPDIR)/dbstrp.Pf ./$(DEPDIR)/dpathn.Pf ./$(DEPDIR)/dmpims.Pf ./$(DEPDIR)/dlogms.Pf ./$(DEPDIR)/dvioms.Pf ./$(DEPDIR)/ddroot.Pf ./$(DEPDIR)/danntr-danntr.Pf ./$(DEPDIR)/dbstrp-dbstrp.Pf ./$(DEPDIR)/dbstrp-denvms.Pf ./$(DEPDIR)/ddroot-ddroot.Pf ./$(DEPDIR)/ddroot-dpathn.Pf ./$(DEPDIR)/ddroot-danntr.Pf ./$(DEPDIR)/ddroot-denvms.Pf ./$(DEPDIR)/ddroot-dbstrp.Pf ./$(DEPDIR)/ddroot-dlogms.Pf ./$(DEPDIR)/ddroot-dmpims.Pf ./$(DEPDIR)/denvms-denvms.Pf ./$(DEPDIR)/dlogms1-dlogms.Pf ./$(DEPDIR)/dlogms1-dmpims.Pf ./$(DEPDIR)/dlogms1-dpathn.Pf ./$(DEPDIR)/dlogms1-danntr.Pf ./$(DEPDIR)/dlogms1-denvms.Pf ./$(DEPDIR)/dlogms1-dbstrp.Pf ./$(DEPDIR)/dlogms2-dlogms.Pf ./$(DEPDIR)/dlogms2-dmpims.Pf ./$(DEPDIR)/dlogms2-dpathn.Pf ./$(DEPDIR)/dlogms2-danntr.Pf ./$(DEPDIR)/dlogms2-denvms.Pf ./$(DEPDIR)/dlogms2-dbstrp.Pf ./$(DEPDIR)/dlogms3-dlogms.Pf ./$(DEPDIR)/dlogms3-dmpims.Pf ./$(DEPDIR)/dlogms3-dpathn.Pf ./$(DEPDIR)/dlogms3-danntr.Pf ./$(DEPDIR)/dlogms3-denvms.Pf ./$(DEPDIR)/dlogms3-dbstrp.Pf ./$(DEPDIR)/dlogms4-dlogms.Pf ./$(DEPDIR)/dlogms4-dmpims.Pf ./$(DEPDIR)/dlogms4-dpathn.Pf ./$(DEPDIR)/dlogms4-danntr.Pf ./$(DEPDIR)/dlogms4-denvms.Pf ./$(DEPDIR)/dlogms4-dbstrp.Pf ./$(DEPDIR)/dmpims1-dmpims.Pf ./$(DEPDIR)/dmpims1-dpathn.Pf ./$(DEPDIR)/dmpims1-danntr.Pf ./$(DEPDIR)/dmpims1-denvms.Pf ./$(DEPDIR)/dmpims1-dbstrp.Pf ./$(DEPDIR)/dmpims2-dmpims.Pf ./$(DEPDIR)/dmpims2-dpathn.Pf ./$(DEPDIR)/dmpims2-danntr.Pf ./$(DEPDIR)/dmpims2-denvms.Pf ./$(DEPDIR)/dmpims2-dbstrp.Pf ./$(DEPDIR)/dpathn-dpathn.Pf ./$(DEPDIR)/dpathn-dbstrp.Pf ./$(DEPDIR)/dpathn-danntr.Pf ./$(DEPDIR)/dpathn-denvms.Pf ./$(DEPDIR)/dvioms-dvioms.Pf ./$(DEPDIR)/dvioms-dmpims.Pf ./$(DEPDIR)/dvioms-dpathn.Pf ./$(DEPDIR)/dvioms-danntr.Pf ./$(DEPDIR)/dvioms-denvms.Pf ./$(DEPDIR)/dvioms-dbstrp.Pf
LCLCNDH = $(builddir)/lclcnd.h
MAINTAINERCLEANFILES += $(LCLDNDH)
#### DEP-DIR
LIB_DEPEND_BASE = src
LIB_DEPEND_NAME = libicies_local.la
LDADD = $(top_builddir)/src/unison/libicies_local.la
FORTRAN_CHECK_ADD = $(top_builddir)/src/unison/gather_libicies_local_la.f
#### END DEP-DIR
