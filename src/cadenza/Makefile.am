# src/cadenza/Makefile.tmpl --- IcIES/Cadenza Makefile.am template
# Maintainer:  SAITO Fuyuki
# Created: Mar 29 2013
# Revision:  Snoopy0.9
# Time-stamp: <2020/09/15 22:30:37 fuyuki Makefile.tmpl>

# Copyright: 2013--2020 JAMSTEC, Ayako ABE-OUCHI
# Licensed under the Apache License, Version 2.0
#   (https://www.apache.org/licenses/LICENSE-2.0)

libicies_local_la_ORIGINS	= cnxutl.F

EXTRA_SRCS					=
LDADD						= libicies_local.la ../libicies.la  ##%% t

bin_PROGRAMS_ORIGINS	= cnxseq.F cvglst.F caechk.F cabcnv.F

cnxseq_LDADD	= $(LDADD) $(NETCDF_LDFLAGS) -lnetcdf -lnetcdff
cnxseq_CPPFLAGS	= $(NETCDF_CPPFLAGS)  ##%% a
cnxseq_FFLAGS	= -I$(NETCDFINC)  ##%% a

bin_SCRIPTS		= cnx.sh
CLEANFILES		= $(bin_SCRIPTS) ##%% a

LIB_DEPEND_DIRS	=	.
SRC_DEPEND_DIRS	=	cadenza arpeggio development unison

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
cabcnv_ORIGINS = cabcnv.F
cnxseq_ORIGINS = cnxseq.F
cvglst_ORIGINS = cvglst.F
caechk_ORIGINS = caechk.F
bin_PROGRAMS = caechk cabcnv cnxseq cvglst
noinst_LTLIBRARIES = libicies_local.la
#### END ORIGINS/BUILDS
#### BUILD FAMILY bin_PROGRAMS
#### BUILD caechk
caechk.$(OBJEXT): caechk.f
ta__copy_source_targets = copy-caechk.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/caechk.Pf@am__quote@ # am--include-marker
EXTRA_DIST += $(caechk_ORIGINS)
CLC_SRCS = $(caechk_ORIGINS)
CLEANFILES += caechk.f gather_caechk.f
CATALL_files = gather_caechk.f
gather_caechk.f: $(nodist_caechk_SOURCES)
	test -z "$(nodist_caechk_SOURCES)" || cat $(nodist_caechk_SOURCES) > $@ || rm -f $@
#### END BUILD caechk
#### BUILD cabcnv
cabcnv.$(OBJEXT): cabcnv.f
ta__copy_source_targets += copy-cabcnv.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/cabcnv.Pf@am__quote@ # am--include-marker
EXTRA_DIST += $(cabcnv_ORIGINS)
CLC_SRCS += $(cabcnv_ORIGINS)
CLEANFILES += cabcnv.f gather_cabcnv.f
CATALL_files += gather_cabcnv.f
gather_cabcnv.f: $(nodist_cabcnv_SOURCES)
	test -z "$(nodist_cabcnv_SOURCES)" || cat $(nodist_cabcnv_SOURCES) > $@ || rm -f $@
#### END BUILD cabcnv
#### BUILD cnxseq
cnxseq.$(OBJEXT): cnxseq.f
ta__copy_source_targets += copy-cnxseq.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/cnxseq.Pf@am__quote@ # am--include-marker
EXTRA_DIST += $(cnxseq_ORIGINS)
CLC_SRCS += $(cnxseq_ORIGINS)
CLEANFILES += cnxseq.f gather_cnxseq.f
CATALL_files += gather_cnxseq.f
gather_cnxseq.f: $(nodist_cnxseq_SOURCES)
	test -z "$(nodist_cnxseq_SOURCES)" || cat $(nodist_cnxseq_SOURCES) > $@ || rm -f $@
#### END BUILD cnxseq
#### BUILD cvglst
cvglst.$(OBJEXT): cvglst.f
ta__copy_source_targets += copy-cvglst.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/cvglst.Pf@am__quote@ # am--include-marker
EXTRA_DIST += $(cvglst_ORIGINS)
CLC_SRCS += $(cvglst_ORIGINS)
CLEANFILES += cvglst.f gather_cvglst.f
CATALL_files += gather_cvglst.f
gather_cvglst.f: $(nodist_cvglst_SOURCES)
	test -z "$(nodist_cvglst_SOURCES)" || cat $(nodist_cvglst_SOURCES) > $@ || rm -f $@
#### END BUILD cvglst
#### END BUILD FAMILY bin_PROGRAMS
#### BUILD FAMILY noinst_LTLIBRARIES
#### BUILD libicies_local.la
cnxutl.$(OBJEXT): cnxutl.f
ta__copy_source_targets += copy-cnxutl.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/cnxutl.Pf@am__quote@ # am--include-marker
EXTRA_DIST += $(libicies_local_la_ORIGINS)
CLC_SRCS += $(libicies_local_la_ORIGINS)
nodist_libicies_local_la_SOURCES = cnxutl.f
CLEANFILES += cnxutl.f gather_libicies_local_la.f
CATALL_files += gather_libicies_local_la.f
gather_libicies_local_la.f: $(nodist_libicies_local_la_SOURCES)
	test -z "$(nodist_libicies_local_la_SOURCES)" || cat $(nodist_libicies_local_la_SOURCES) > $@ || rm -f $@
#### END BUILD libicies_local.la
#### END BUILD FAMILY noinst_LTLIBRARIES
#### ORIGINS/CHECKS cabcnv.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/cabcnv-cabcnv.Pf@am__quote@ # am--include-marker
cabcnv_CPPFLAGS = -DTEST_CABCNV=1
cabcnv-cabcnv.f: cabcnv.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(cabcnv_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(cabcnv_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_cabcnv_SOURCES = cabcnv-cabcnv.f
srcchk-cabcnv: $(nodist_cabcnv_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_cabcnv_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-cabcnv: $(nodist_cabcnv_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_cabcnv_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-cabcnv.f: $(nodist_cabcnv_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_cabcnv_SOURCES)" || cat $(nodist_cabcnv_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
CLEANFILES += cabcnv-cabcnv.f bundle-cabcnv.f
check_PROGRAMS = cabcnv
srcchk-all: srcchk-cabcnv
sublist-all: sublist-cabcnv
bundle-all: bundle-cabcnv.f
check-cabcnv: cabcnv
#### END ORIGINS/CHECKS cabcnv.F
#### ORIGINS/CHECKS caechk.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/caechk-caechk.Pf@am__quote@ # am--include-marker
caechk_CPPFLAGS = -DTEST_CAECHK=1
caechk-caechk.f: caechk.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(caechk_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(caechk_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_caechk_SOURCES = caechk-caechk.f
srcchk-caechk: $(nodist_caechk_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_caechk_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-caechk: $(nodist_caechk_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_caechk_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-caechk.f: $(nodist_caechk_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_caechk_SOURCES)" || cat $(nodist_caechk_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
CLEANFILES += caechk-caechk.f bundle-caechk.f
check_PROGRAMS += caechk
srcchk-all: srcchk-caechk
sublist-all: sublist-caechk
bundle-all: bundle-caechk.f
check-caechk: caechk
#### END ORIGINS/CHECKS caechk.F
#### ORIGINS/CHECKS cnxseq.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/cnxseq-cnxseq.Pf@am__quote@ # am--include-marker
cnxseq_CPPFLAGS += -DTEST_CNXSEQ=1
cnxseq-cnxseq.f: cnxseq.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(cnxseq_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(cnxseq_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_cnxseq_SOURCES = cnxseq-cnxseq.f
srcchk-cnxseq: $(nodist_cnxseq_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_cnxseq_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-cnxseq: $(nodist_cnxseq_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_cnxseq_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-cnxseq.f: $(nodist_cnxseq_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_cnxseq_SOURCES)" || cat $(nodist_cnxseq_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
CLEANFILES += cnxseq-cnxseq.f bundle-cnxseq.f
check_PROGRAMS += cnxseq
srcchk-all: srcchk-cnxseq
sublist-all: sublist-cnxseq
bundle-all: bundle-cnxseq.f
check-cnxseq: cnxseq
#### END ORIGINS/CHECKS cnxseq.F
#### ORIGINS/CHECKS cnxutl.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/cnxutl-cnxutl.Pf@am__quote@ # am--include-marker
cnxutl_CPPFLAGS = -DTEST_CNXUTL=1
cnxutl-cnxutl.f: cnxutl.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(cnxutl_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(cnxutl_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_cnxutl_SOURCES = cnxutl-cnxutl.f
srcchk-cnxutl: $(nodist_cnxutl_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_cnxutl_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-cnxutl: $(nodist_cnxutl_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_cnxutl_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-cnxutl.f: $(nodist_cnxutl_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_cnxutl_SOURCES)" || cat $(nodist_cnxutl_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
CLEANFILES += cnxutl-cnxutl.f bundle-cnxutl.f
check_PROGRAMS += cnxutl
srcchk-all: srcchk-cnxutl
sublist-all: sublist-cnxutl
bundle-all: bundle-cnxutl.f
check-cnxutl: cnxutl
#### END ORIGINS/CHECKS cnxutl.F
#### ORIGINS/CHECKS cvglst.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/cvglst-cvglst.Pf@am__quote@ # am--include-marker
cvglst_CPPFLAGS = -DTEST_CVGLST=1
cvglst-cvglst.f: cvglst.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(cvglst_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(cvglst_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_cvglst_SOURCES = cvglst-cvglst.f
srcchk-cvglst: $(nodist_cvglst_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_cvglst_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-cvglst: $(nodist_cvglst_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_cvglst_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-cvglst.f: $(nodist_cvglst_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_cvglst_SOURCES)" || cat $(nodist_cvglst_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
CLEANFILES += cvglst-cvglst.f bundle-cvglst.f
check_PROGRAMS += cvglst
srcchk-all: srcchk-cvglst
sublist-all: sublist-cvglst
bundle-all: bundle-cvglst.f
check-cvglst: cvglst
#### END ORIGINS/CHECKS cvglst.F
am__depfiles_remade = ./$(DEPDIR)/caechk.Pf ./$(DEPDIR)/cabcnv.Pf ./$(DEPDIR)/cnxseq.Pf ./$(DEPDIR)/cvglst.Pf ./$(DEPDIR)/cnxutl.Pf ./$(DEPDIR)/cabcnv-cabcnv.Pf ./$(DEPDIR)/caechk-caechk.Pf ./$(DEPDIR)/cnxseq-cnxseq.Pf ./$(DEPDIR)/cnxutl-cnxutl.Pf ./$(DEPDIR)/cvglst-cvglst.Pf
LCLCNDH = $(builddir)/lclcnd.h
MAINTAINERCLEANFILES = $(LCLDNDH)
#### DEP-DIR
LIB_DEPEND_BASE = src
LIB_DEPEND_NAME = libicies_local.la
auto_LDADD_auto = $(top_builddir)/src/./libicies_local.la
FORTRAN_CHECK_ADD = $(top_builddir)/src/cadenza/gather_libicies_local_la.f $(top_builddir)/src/arpeggio/gather_libicies_local_la.f $(top_builddir)/src/development/gather_libicies_local_la.f $(top_builddir)/src/unison/gather_libicies_local_la.f
#### END DEP-DIR
