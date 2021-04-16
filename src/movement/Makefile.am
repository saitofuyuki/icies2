# src/movement/Makefile.tmpl --- IcIES/Movement Makefile.am template
# Maintainer:  SAITO Fuyuki
# Created: Nov 4 2011
# Revision:  Snoopy0.9
# Time-stamp: <2020/09/15 22:08:44 fuyuki Makefile.tmpl>

# Copyright: 2011--2020 JAMSTEC, Ayako ABE-OUCHI
# Licensed under the Apache License, Version 2.0
#   (https://www.apache.org/licenses/LICENSE-2.0)

libicies_local_la_ORIGINS	= muvcio.F mutcfg.F mumcol.F mppmth.F mprtft.F mpenhf.F mifunc.F mibakw.F mmxoms.F msbmos.F mmsbcg.F msfunc.F mmcipc.F mmheud.F mmwcol.F mbscol.F mdrvrm.F mslbcg.F mglcol.F msnita.F mscpli.F mtfunc.F mttcol.F magcol.F
## $(MDRVBF)
EXTRA_SRCS = 

LIB_DEPEND_DIRS	=	arpeggio development unison

BUILT_SOURCES	=	movement.h mutests.h
EXTRA_DIST  	=	movement.h movement.m4 mutests.h mutests.m4 mvdef.sh mvdef.m4 ##%% a

MAINTAINERCLEANFILES = movement.h ##%% a

SQIHELP	= $(top_srcdir)/build-aux/icies/sqihelp
if MAINTAINER_MODE
movement.h: movement.m4
	$(SQIHELP) -o $@ $<

mutests.h: mutests.m4
	$(SQIHELP) -o $@ $<

else
movement.h: movement.m4
	@if test -f $@; then \
		echo keep $@; \
	elif test -f $(srcdir)/$@; then \
		$(CP) $(srcdir)/$@ $(builddir); \
	else \
		$(SQIHELP) -o $@ $<; \
	fi
mutests.h: mutests.m4
	@if test -f $@; then \
		echo keep $@; \
	elif test -f $(srcdir)/$@; then \
		$(CP) $(srcdir)/$@ $(builddir); \
	else \
		$(SQIHELP) -o $@ $<; \
	fi
endif

install-cadenza:
	@cd $(top_builddir); $(MAKE) $(AM_MAKEFLAGS) $@

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
muvcio.$(OBJEXT): muvcio.f
mutcfg.$(OBJEXT): mutcfg.f
mumcol.$(OBJEXT): mumcol.f
mppmth.$(OBJEXT): mppmth.f
mprtft.$(OBJEXT): mprtft.f
mpenhf.$(OBJEXT): mpenhf.f
mifunc.$(OBJEXT): mifunc.f
mibakw.$(OBJEXT): mibakw.f
mmxoms.$(OBJEXT): mmxoms.f
msbmos.$(OBJEXT): msbmos.f
mmsbcg.$(OBJEXT): mmsbcg.f
msfunc.$(OBJEXT): msfunc.f
mmcipc.$(OBJEXT): mmcipc.f
mmheud.$(OBJEXT): mmheud.f
mmwcol.$(OBJEXT): mmwcol.f
mbscol.$(OBJEXT): mbscol.f
mdrvrm.$(OBJEXT): mdrvrm.f
mslbcg.$(OBJEXT): mslbcg.f
mglcol.$(OBJEXT): mglcol.f
msnita.$(OBJEXT): msnita.f
mscpli.$(OBJEXT): mscpli.f
mtfunc.$(OBJEXT): mtfunc.f
mttcol.$(OBJEXT): mttcol.f
magcol.$(OBJEXT): magcol.f
ta__copy_source_targets = copy-muvcio.F copy-mutcfg.F copy-mumcol.F copy-mppmth.F copy-mprtft.F copy-mpenhf.F copy-mifunc.F copy-mibakw.F copy-mmxoms.F copy-msbmos.F copy-mmsbcg.F copy-msfunc.F copy-mmcipc.F copy-mmheud.F copy-mmwcol.F copy-mbscol.F copy-mdrvrm.F copy-mslbcg.F copy-mglcol.F copy-msnita.F copy-mscpli.F copy-mtfunc.F copy-mttcol.F copy-magcol.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/muvcio.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mutcfg.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mumcol.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mppmth.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mprtft.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mpenhf.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mifunc.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mibakw.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mmxoms.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/msbmos.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mmsbcg.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/msfunc.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mmcipc.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mmheud.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mmwcol.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mbscol.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mslbcg.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mglcol.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/msnita.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mscpli.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mtfunc.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mttcol.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/magcol.Pf@am__quote@ # am--include-marker
EXTRA_DIST += $(libicies_local_la_ORIGINS)
CLC_SRCS = $(libicies_local_la_ORIGINS)
nodist_libicies_local_la_SOURCES = muvcio.f mutcfg.f mumcol.f mppmth.f mprtft.f mpenhf.f mifunc.f mibakw.f mmxoms.f msbmos.f mmsbcg.f msfunc.f mmcipc.f mmheud.f mmwcol.f mbscol.f mdrvrm.f mslbcg.f mglcol.f msnita.f mscpli.f mtfunc.f mttcol.f magcol.f
CLEANFILES = muvcio.f mutcfg.f mumcol.f mppmth.f mprtft.f mpenhf.f mifunc.f mibakw.f mmxoms.f msbmos.f mmsbcg.f msfunc.f mmcipc.f mmheud.f mmwcol.f mbscol.f mdrvrm.f mslbcg.f mglcol.f msnita.f mscpli.f mtfunc.f mttcol.f magcol.f gather_libicies_local_la.f
CATALL_files = gather_libicies_local_la.f
gather_libicies_local_la.f: $(nodist_libicies_local_la_SOURCES)
	test -z "$(nodist_libicies_local_la_SOURCES)" || cat $(nodist_libicies_local_la_SOURCES) > $@ || rm -f $@
#### END BUILD libicies_local.la
#### END BUILD FAMILY noinst_LTLIBRARIES
#### ORIGINS/CHECKS magcol.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/magcol-magcol.Pf@am__quote@ # am--include-marker
magcol_CPPFLAGS = -DTEST_MAGCOL=1
magcol-magcol.f: magcol.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(magcol_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(magcol_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_magcol_SOURCES = magcol-magcol.f
srcchk-magcol: $(nodist_magcol_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_magcol_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-magcol: $(nodist_magcol_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_magcol_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-magcol.f: $(nodist_magcol_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_magcol_SOURCES)" || cat $(nodist_magcol_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
CLEANFILES += magcol-magcol.f bundle-magcol.f
check_PROGRAMS = magcol
srcchk-all: srcchk-magcol
sublist-all: sublist-magcol
bundle-all: bundle-magcol.f
check-magcol: magcol
#### END ORIGINS/CHECKS magcol.F
#### ORIGINS/CHECKS mbscol.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mbscol-mbscol.Pf@am__quote@ # am--include-marker
mbscol_CPPFLAGS = -DTEST_MBSCOL=1
mbscol-mbscol.f: mbscol.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mbscol_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mbscol_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_mbscol_SOURCES = mbscol-mbscol.f
srcchk-mbscol: $(nodist_mbscol_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_mbscol_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-mbscol: $(nodist_mbscol_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_mbscol_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-mbscol.f: $(nodist_mbscol_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_mbscol_SOURCES)" || cat $(nodist_mbscol_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
CLEANFILES += mbscol-mbscol.f bundle-mbscol.f
check_PROGRAMS += mbscol
srcchk-all: srcchk-mbscol
sublist-all: sublist-mbscol
bundle-all: bundle-mbscol.f
check-mbscol: mbscol
#### END ORIGINS/CHECKS mbscol.F
#### ORIGINS/CHECKS mdrvrm.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm1-mdrvrm.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm1-msnita.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm1-mslbcg.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm1-mifunc.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm1-mmxoms.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm1-mglcol.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm1-mpenhf.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm1-mmwcol.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm1-msfunc.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm1-mumcol.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm1-mutcfg.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm1-mttcol.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm1-mmsbcg.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm1-mtfunc.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm1-muvcio.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm1-mmheud.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm1-msbmos.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm1-mbscol.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm1-mprtft.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm1-mmcipc.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm1-mppmth.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm1-mibakw.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm2-mdrvrm.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm2-msnita.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm2-mslbcg.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm2-mifunc.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm2-mmxoms.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm2-mglcol.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm2-mpenhf.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm2-mmwcol.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm2-msfunc.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm2-mumcol.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm2-mutcfg.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm2-mttcol.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm2-mmsbcg.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm2-mtfunc.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm2-muvcio.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm2-mmheud.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm2-msbmos.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm2-mbscol.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm2-mprtft.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm2-mmcipc.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm2-mppmth.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm2-mibakw.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm3-mdrvrm.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm3-msnita.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm3-mslbcg.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm3-mifunc.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm3-mmxoms.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm3-mglcol.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm3-mpenhf.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm3-mmwcol.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm3-msfunc.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm3-mumcol.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm3-mutcfg.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm3-mttcol.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm3-mmsbcg.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm3-mtfunc.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm3-muvcio.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm3-mmheud.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm3-msbmos.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm3-mbscol.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm3-mprtft.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm3-mmcipc.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm3-mppmth.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm3-mibakw.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm4-mdrvrm.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm4-msnita.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm4-mslbcg.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm4-mifunc.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm4-mmxoms.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm4-mglcol.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm4-mpenhf.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm4-mmwcol.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm4-msfunc.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm4-mumcol.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm4-mutcfg.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm4-mttcol.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm4-mmsbcg.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm4-mtfunc.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm4-muvcio.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm4-mmheud.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm4-msbmos.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm4-mbscol.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm4-mprtft.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm4-mmcipc.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm4-mppmth.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm4-mibakw.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm4-dbg_mttcol.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm5-mdrvrm.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm5-msnita.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm5-mslbcg.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm5-mifunc.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm5-mmxoms.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm5-mglcol.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm5-mpenhf.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm5-mmwcol.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm5-msfunc.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm5-mumcol.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm5-mutcfg.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm5-mttcol.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm5-mmsbcg.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm5-mtfunc.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm5-muvcio.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm5-mmheud.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm5-msbmos.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm5-mbscol.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm5-mprtft.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm5-mmcipc.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm5-mppmth.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm5-mibakw.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm6-mdrvrm.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm6-msnita.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm6-mslbcg.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm6-mifunc.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm6-mmxoms.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm6-mglcol.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm6-mpenhf.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm6-mmwcol.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm6-msfunc.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm6-mumcol.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm6-mutcfg.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm6-mttcol.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm6-mmsbcg.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm6-mtfunc.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm6-muvcio.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm6-mmheud.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm6-msbmos.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm6-mbscol.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm6-mprtft.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm6-mmcipc.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm6-mppmth.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm6-mibakw.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm7-mdrvrm.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm7-msnita.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm7-mslbcg.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm7-mifunc.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm7-mmxoms.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm7-mglcol.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm7-mpenhf.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm7-mmwcol.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm7-msfunc.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm7-mumcol.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm7-mutcfg.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm7-mttcol.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm7-mmsbcg.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm7-mtfunc.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm7-muvcio.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm7-mmheud.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm7-msbmos.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm7-mbscol.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm7-mprtft.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm7-mmcipc.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm7-mppmth.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm7-mibakw.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm8-mdrvrm.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm8-msnita.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm8-mslbcg.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm8-mifunc.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm8-mmxoms.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm8-mglcol.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm8-mpenhf.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm8-mmwcol.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm8-msfunc.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm8-mumcol.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm8-mutcfg.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm8-mttcol.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm8-mmsbcg.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm8-mtfunc.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm8-muvcio.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm8-mmheud.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm8-msbmos.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm8-mbscol.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm8-mprtft.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm8-mmcipc.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm8-mppmth.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mdrvrm8-mibakw.Pf@am__quote@ # am--include-marker
mdrvrm1_CPPFLAGS = -DTEST_MDRVRM=1
mdrvrm1-mdrvrm.f: mdrvrm.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm1_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm1_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm1-msnita.f: msnita.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm1_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm1_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm1-mslbcg.f: mslbcg.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm1_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm1_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm1-mifunc.f: mifunc.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm1_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm1_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm1-mmxoms.f: mmxoms.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm1_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm1_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm1-mglcol.f: mglcol.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm1_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm1_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm1-mpenhf.f: mpenhf.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm1_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm1_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm1-mmwcol.f: mmwcol.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm1_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm1_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm1-msfunc.f: msfunc.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm1_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm1_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm1-mumcol.f: mumcol.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm1_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm1_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm1-mutcfg.f: mutcfg.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm1_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm1_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm1-mttcol.f: mttcol.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm1_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm1_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm1-mmsbcg.f: mmsbcg.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm1_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm1_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm1-mtfunc.f: mtfunc.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm1_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm1_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm1-muvcio.f: muvcio.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm1_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm1_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm1-mmheud.f: mmheud.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm1_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm1_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm1-msbmos.f: msbmos.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm1_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm1_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm1-mbscol.f: mbscol.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm1_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm1_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm1-mprtft.f: mprtft.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm1_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm1_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm1-mmcipc.f: mmcipc.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm1_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm1_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm1-mppmth.f: mppmth.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm1_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm1_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm1-mibakw.f: mibakw.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm1_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm1_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_mdrvrm1_SOURCES = mdrvrm1-mdrvrm.f mdrvrm1-msnita.f mdrvrm1-mslbcg.f mdrvrm1-mifunc.f mdrvrm1-mmxoms.f mdrvrm1-mglcol.f mdrvrm1-mpenhf.f mdrvrm1-mmwcol.f mdrvrm1-msfunc.f mdrvrm1-mumcol.f mdrvrm1-mutcfg.f mdrvrm1-mttcol.f mdrvrm1-mmsbcg.f mdrvrm1-mtfunc.f mdrvrm1-muvcio.f mdrvrm1-mmheud.f mdrvrm1-msbmos.f mdrvrm1-mbscol.f mdrvrm1-mprtft.f mdrvrm1-mmcipc.f mdrvrm1-mppmth.f mdrvrm1-mibakw.f
srcchk-mdrvrm1: $(nodist_mdrvrm1_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_mdrvrm1_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-mdrvrm1: $(nodist_mdrvrm1_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_mdrvrm1_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-mdrvrm1.f: $(nodist_mdrvrm1_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_mdrvrm1_SOURCES)" || cat $(nodist_mdrvrm1_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
mdrvrm2_CPPFLAGS = -DTEST_MDRVRM=2
mdrvrm2-mdrvrm.f: mdrvrm.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm2_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm2_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm2-msnita.f: msnita.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm2_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm2_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm2-mslbcg.f: mslbcg.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm2_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm2_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm2-mifunc.f: mifunc.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm2_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm2_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm2-mmxoms.f: mmxoms.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm2_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm2_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm2-mglcol.f: mglcol.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm2_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm2_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm2-mpenhf.f: mpenhf.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm2_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm2_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm2-mmwcol.f: mmwcol.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm2_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm2_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm2-msfunc.f: msfunc.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm2_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm2_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm2-mumcol.f: mumcol.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm2_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm2_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm2-mutcfg.f: mutcfg.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm2_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm2_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm2-mttcol.f: mttcol.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm2_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm2_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm2-mmsbcg.f: mmsbcg.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm2_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm2_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm2-mtfunc.f: mtfunc.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm2_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm2_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm2-muvcio.f: muvcio.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm2_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm2_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm2-mmheud.f: mmheud.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm2_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm2_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm2-msbmos.f: msbmos.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm2_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm2_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm2-mbscol.f: mbscol.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm2_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm2_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm2-mprtft.f: mprtft.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm2_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm2_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm2-mmcipc.f: mmcipc.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm2_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm2_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm2-mppmth.f: mppmth.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm2_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm2_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm2-mibakw.f: mibakw.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm2_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm2_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_mdrvrm2_SOURCES = mdrvrm2-mdrvrm.f mdrvrm2-msnita.f mdrvrm2-mslbcg.f mdrvrm2-mifunc.f mdrvrm2-mmxoms.f mdrvrm2-mglcol.f mdrvrm2-mpenhf.f mdrvrm2-mmwcol.f mdrvrm2-msfunc.f mdrvrm2-mumcol.f mdrvrm2-mutcfg.f mdrvrm2-mttcol.f mdrvrm2-mmsbcg.f mdrvrm2-mtfunc.f mdrvrm2-muvcio.f mdrvrm2-mmheud.f mdrvrm2-msbmos.f mdrvrm2-mbscol.f mdrvrm2-mprtft.f mdrvrm2-mmcipc.f mdrvrm2-mppmth.f mdrvrm2-mibakw.f
srcchk-mdrvrm2: $(nodist_mdrvrm2_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_mdrvrm2_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-mdrvrm2: $(nodist_mdrvrm2_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_mdrvrm2_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-mdrvrm2.f: $(nodist_mdrvrm2_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_mdrvrm2_SOURCES)" || cat $(nodist_mdrvrm2_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
mdrvrm3_CPPFLAGS = -DTEST_MDRVRM=3
mdrvrm3-mdrvrm.f: mdrvrm.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm3_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm3_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm3-msnita.f: msnita.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm3_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm3_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm3-mslbcg.f: mslbcg.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm3_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm3_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm3-mifunc.f: mifunc.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm3_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm3_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm3-mmxoms.f: mmxoms.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm3_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm3_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm3-mglcol.f: mglcol.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm3_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm3_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm3-mpenhf.f: mpenhf.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm3_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm3_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm3-mmwcol.f: mmwcol.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm3_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm3_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm3-msfunc.f: msfunc.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm3_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm3_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm3-mumcol.f: mumcol.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm3_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm3_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm3-mutcfg.f: mutcfg.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm3_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm3_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm3-mttcol.f: mttcol.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm3_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm3_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm3-mmsbcg.f: mmsbcg.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm3_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm3_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm3-mtfunc.f: mtfunc.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm3_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm3_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm3-muvcio.f: muvcio.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm3_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm3_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm3-mmheud.f: mmheud.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm3_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm3_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm3-msbmos.f: msbmos.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm3_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm3_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm3-mbscol.f: mbscol.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm3_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm3_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm3-mprtft.f: mprtft.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm3_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm3_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm3-mmcipc.f: mmcipc.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm3_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm3_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm3-mppmth.f: mppmth.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm3_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm3_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm3-mibakw.f: mibakw.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm3_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm3_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_mdrvrm3_SOURCES = mdrvrm3-mdrvrm.f mdrvrm3-msnita.f mdrvrm3-mslbcg.f mdrvrm3-mifunc.f mdrvrm3-mmxoms.f mdrvrm3-mglcol.f mdrvrm3-mpenhf.f mdrvrm3-mmwcol.f mdrvrm3-msfunc.f mdrvrm3-mumcol.f mdrvrm3-mutcfg.f mdrvrm3-mttcol.f mdrvrm3-mmsbcg.f mdrvrm3-mtfunc.f mdrvrm3-muvcio.f mdrvrm3-mmheud.f mdrvrm3-msbmos.f mdrvrm3-mbscol.f mdrvrm3-mprtft.f mdrvrm3-mmcipc.f mdrvrm3-mppmth.f mdrvrm3-mibakw.f
srcchk-mdrvrm3: $(nodist_mdrvrm3_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_mdrvrm3_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-mdrvrm3: $(nodist_mdrvrm3_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_mdrvrm3_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-mdrvrm3.f: $(nodist_mdrvrm3_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_mdrvrm3_SOURCES)" || cat $(nodist_mdrvrm3_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
mdrvrm4_CPPFLAGS = -DTEST_MDRVRM=4
mdrvrm4-mdrvrm.f: mdrvrm.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm4_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm4_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm4-msnita.f: msnita.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm4_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm4_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm4-mslbcg.f: mslbcg.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm4_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm4_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm4-mifunc.f: mifunc.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm4_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm4_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm4-mmxoms.f: mmxoms.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm4_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm4_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm4-mglcol.f: mglcol.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm4_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm4_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm4-mpenhf.f: mpenhf.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm4_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm4_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm4-mmwcol.f: mmwcol.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm4_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm4_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm4-msfunc.f: msfunc.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm4_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm4_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm4-mumcol.f: mumcol.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm4_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm4_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm4-mutcfg.f: mutcfg.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm4_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm4_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm4-mttcol.f: mttcol.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm4_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm4_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm4-mmsbcg.f: mmsbcg.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm4_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm4_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm4-mtfunc.f: mtfunc.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm4_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm4_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm4-muvcio.f: muvcio.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm4_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm4_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm4-mmheud.f: mmheud.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm4_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm4_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm4-msbmos.f: msbmos.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm4_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm4_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm4-mbscol.f: mbscol.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm4_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm4_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm4-mprtft.f: mprtft.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm4_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm4_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm4-mmcipc.f: mmcipc.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm4_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm4_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm4-mppmth.f: mppmth.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm4_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm4_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm4-mibakw.f: mibakw.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm4_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm4_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm4-dbg_mttcol.f: dbg_mttcol.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm4_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm4_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_mdrvrm4_SOURCES = mdrvrm4-mdrvrm.f mdrvrm4-msnita.f mdrvrm4-mslbcg.f mdrvrm4-mifunc.f mdrvrm4-mmxoms.f mdrvrm4-mglcol.f mdrvrm4-mpenhf.f mdrvrm4-mmwcol.f mdrvrm4-msfunc.f mdrvrm4-mumcol.f mdrvrm4-mutcfg.f mdrvrm4-mttcol.f mdrvrm4-mmsbcg.f mdrvrm4-mtfunc.f mdrvrm4-muvcio.f mdrvrm4-mmheud.f mdrvrm4-msbmos.f mdrvrm4-mbscol.f mdrvrm4-mprtft.f mdrvrm4-mmcipc.f mdrvrm4-mppmth.f mdrvrm4-mibakw.f mdrvrm4-dbg_mttcol.f
srcchk-mdrvrm4: $(nodist_mdrvrm4_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_mdrvrm4_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-mdrvrm4: $(nodist_mdrvrm4_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_mdrvrm4_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-mdrvrm4.f: $(nodist_mdrvrm4_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_mdrvrm4_SOURCES)" || cat $(nodist_mdrvrm4_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
mdrvrm5_CPPFLAGS = -DTEST_MDRVRM=5
mdrvrm5-mdrvrm.f: mdrvrm.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm5_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm5_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm5-msnita.f: msnita.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm5_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm5_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm5-mslbcg.f: mslbcg.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm5_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm5_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm5-mifunc.f: mifunc.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm5_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm5_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm5-mmxoms.f: mmxoms.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm5_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm5_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm5-mglcol.f: mglcol.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm5_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm5_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm5-mpenhf.f: mpenhf.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm5_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm5_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm5-mmwcol.f: mmwcol.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm5_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm5_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm5-msfunc.f: msfunc.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm5_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm5_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm5-mumcol.f: mumcol.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm5_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm5_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm5-mutcfg.f: mutcfg.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm5_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm5_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm5-mttcol.f: mttcol.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm5_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm5_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm5-mmsbcg.f: mmsbcg.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm5_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm5_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm5-mtfunc.f: mtfunc.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm5_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm5_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm5-muvcio.f: muvcio.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm5_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm5_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm5-mmheud.f: mmheud.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm5_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm5_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm5-msbmos.f: msbmos.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm5_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm5_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm5-mbscol.f: mbscol.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm5_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm5_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm5-mprtft.f: mprtft.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm5_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm5_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm5-mmcipc.f: mmcipc.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm5_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm5_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm5-mppmth.f: mppmth.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm5_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm5_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm5-mibakw.f: mibakw.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm5_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm5_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_mdrvrm5_SOURCES = mdrvrm5-mdrvrm.f mdrvrm5-msnita.f mdrvrm5-mslbcg.f mdrvrm5-mifunc.f mdrvrm5-mmxoms.f mdrvrm5-mglcol.f mdrvrm5-mpenhf.f mdrvrm5-mmwcol.f mdrvrm5-msfunc.f mdrvrm5-mumcol.f mdrvrm5-mutcfg.f mdrvrm5-mttcol.f mdrvrm5-mmsbcg.f mdrvrm5-mtfunc.f mdrvrm5-muvcio.f mdrvrm5-mmheud.f mdrvrm5-msbmos.f mdrvrm5-mbscol.f mdrvrm5-mprtft.f mdrvrm5-mmcipc.f mdrvrm5-mppmth.f mdrvrm5-mibakw.f
srcchk-mdrvrm5: $(nodist_mdrvrm5_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_mdrvrm5_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-mdrvrm5: $(nodist_mdrvrm5_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_mdrvrm5_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-mdrvrm5.f: $(nodist_mdrvrm5_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_mdrvrm5_SOURCES)" || cat $(nodist_mdrvrm5_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
mdrvrm6_CPPFLAGS = -DTEST_MDRVRM=6
mdrvrm6-mdrvrm.f: mdrvrm.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm6_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm6_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm6-msnita.f: msnita.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm6_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm6_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm6-mslbcg.f: mslbcg.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm6_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm6_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm6-mifunc.f: mifunc.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm6_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm6_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm6-mmxoms.f: mmxoms.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm6_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm6_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm6-mglcol.f: mglcol.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm6_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm6_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm6-mpenhf.f: mpenhf.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm6_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm6_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm6-mmwcol.f: mmwcol.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm6_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm6_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm6-msfunc.f: msfunc.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm6_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm6_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm6-mumcol.f: mumcol.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm6_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm6_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm6-mutcfg.f: mutcfg.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm6_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm6_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm6-mttcol.f: mttcol.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm6_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm6_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm6-mmsbcg.f: mmsbcg.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm6_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm6_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm6-mtfunc.f: mtfunc.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm6_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm6_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm6-muvcio.f: muvcio.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm6_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm6_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm6-mmheud.f: mmheud.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm6_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm6_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm6-msbmos.f: msbmos.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm6_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm6_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm6-mbscol.f: mbscol.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm6_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm6_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm6-mprtft.f: mprtft.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm6_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm6_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm6-mmcipc.f: mmcipc.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm6_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm6_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm6-mppmth.f: mppmth.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm6_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm6_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm6-mibakw.f: mibakw.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm6_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm6_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_mdrvrm6_SOURCES = mdrvrm6-mdrvrm.f mdrvrm6-msnita.f mdrvrm6-mslbcg.f mdrvrm6-mifunc.f mdrvrm6-mmxoms.f mdrvrm6-mglcol.f mdrvrm6-mpenhf.f mdrvrm6-mmwcol.f mdrvrm6-msfunc.f mdrvrm6-mumcol.f mdrvrm6-mutcfg.f mdrvrm6-mttcol.f mdrvrm6-mmsbcg.f mdrvrm6-mtfunc.f mdrvrm6-muvcio.f mdrvrm6-mmheud.f mdrvrm6-msbmos.f mdrvrm6-mbscol.f mdrvrm6-mprtft.f mdrvrm6-mmcipc.f mdrvrm6-mppmth.f mdrvrm6-mibakw.f
srcchk-mdrvrm6: $(nodist_mdrvrm6_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_mdrvrm6_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-mdrvrm6: $(nodist_mdrvrm6_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_mdrvrm6_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-mdrvrm6.f: $(nodist_mdrvrm6_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_mdrvrm6_SOURCES)" || cat $(nodist_mdrvrm6_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
mdrvrm7_CPPFLAGS = -DTEST_MDRVRM=7
mdrvrm7-mdrvrm.f: mdrvrm.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm7_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm7_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm7-msnita.f: msnita.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm7_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm7_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm7-mslbcg.f: mslbcg.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm7_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm7_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm7-mifunc.f: mifunc.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm7_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm7_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm7-mmxoms.f: mmxoms.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm7_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm7_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm7-mglcol.f: mglcol.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm7_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm7_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm7-mpenhf.f: mpenhf.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm7_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm7_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm7-mmwcol.f: mmwcol.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm7_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm7_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm7-msfunc.f: msfunc.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm7_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm7_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm7-mumcol.f: mumcol.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm7_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm7_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm7-mutcfg.f: mutcfg.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm7_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm7_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm7-mttcol.f: mttcol.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm7_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm7_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm7-mmsbcg.f: mmsbcg.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm7_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm7_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm7-mtfunc.f: mtfunc.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm7_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm7_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm7-muvcio.f: muvcio.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm7_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm7_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm7-mmheud.f: mmheud.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm7_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm7_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm7-msbmos.f: msbmos.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm7_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm7_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm7-mbscol.f: mbscol.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm7_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm7_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm7-mprtft.f: mprtft.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm7_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm7_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm7-mmcipc.f: mmcipc.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm7_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm7_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm7-mppmth.f: mppmth.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm7_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm7_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm7-mibakw.f: mibakw.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm7_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm7_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_mdrvrm7_SOURCES = mdrvrm7-mdrvrm.f mdrvrm7-msnita.f mdrvrm7-mslbcg.f mdrvrm7-mifunc.f mdrvrm7-mmxoms.f mdrvrm7-mglcol.f mdrvrm7-mpenhf.f mdrvrm7-mmwcol.f mdrvrm7-msfunc.f mdrvrm7-mumcol.f mdrvrm7-mutcfg.f mdrvrm7-mttcol.f mdrvrm7-mmsbcg.f mdrvrm7-mtfunc.f mdrvrm7-muvcio.f mdrvrm7-mmheud.f mdrvrm7-msbmos.f mdrvrm7-mbscol.f mdrvrm7-mprtft.f mdrvrm7-mmcipc.f mdrvrm7-mppmth.f mdrvrm7-mibakw.f
srcchk-mdrvrm7: $(nodist_mdrvrm7_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_mdrvrm7_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-mdrvrm7: $(nodist_mdrvrm7_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_mdrvrm7_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-mdrvrm7.f: $(nodist_mdrvrm7_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_mdrvrm7_SOURCES)" || cat $(nodist_mdrvrm7_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
mdrvrm8_CPPFLAGS = -DTEST_MDRVRM=8
mdrvrm8-mdrvrm.f: mdrvrm.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm8_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm8_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm8-msnita.f: msnita.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm8_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm8_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm8-mslbcg.f: mslbcg.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm8_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm8_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm8-mifunc.f: mifunc.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm8_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm8_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm8-mmxoms.f: mmxoms.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm8_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm8_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm8-mglcol.f: mglcol.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm8_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm8_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm8-mpenhf.f: mpenhf.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm8_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm8_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm8-mmwcol.f: mmwcol.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm8_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm8_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm8-msfunc.f: msfunc.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm8_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm8_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm8-mumcol.f: mumcol.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm8_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm8_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm8-mutcfg.f: mutcfg.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm8_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm8_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm8-mttcol.f: mttcol.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm8_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm8_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm8-mmsbcg.f: mmsbcg.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm8_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm8_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm8-mtfunc.f: mtfunc.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm8_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm8_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm8-muvcio.f: muvcio.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm8_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm8_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm8-mmheud.f: mmheud.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm8_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm8_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm8-msbmos.f: msbmos.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm8_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm8_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm8-mbscol.f: mbscol.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm8_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm8_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm8-mprtft.f: mprtft.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm8_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm8_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm8-mmcipc.f: mmcipc.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm8_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm8_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm8-mppmth.f: mppmth.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm8_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm8_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mdrvrm8-mibakw.f: mibakw.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mdrvrm8_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mdrvrm8_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_mdrvrm8_SOURCES = mdrvrm8-mdrvrm.f mdrvrm8-msnita.f mdrvrm8-mslbcg.f mdrvrm8-mifunc.f mdrvrm8-mmxoms.f mdrvrm8-mglcol.f mdrvrm8-mpenhf.f mdrvrm8-mmwcol.f mdrvrm8-msfunc.f mdrvrm8-mumcol.f mdrvrm8-mutcfg.f mdrvrm8-mttcol.f mdrvrm8-mmsbcg.f mdrvrm8-mtfunc.f mdrvrm8-muvcio.f mdrvrm8-mmheud.f mdrvrm8-msbmos.f mdrvrm8-mbscol.f mdrvrm8-mprtft.f mdrvrm8-mmcipc.f mdrvrm8-mppmth.f mdrvrm8-mibakw.f
srcchk-mdrvrm8: $(nodist_mdrvrm8_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_mdrvrm8_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-mdrvrm8: $(nodist_mdrvrm8_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_mdrvrm8_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-mdrvrm8.f: $(nodist_mdrvrm8_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_mdrvrm8_SOURCES)" || cat $(nodist_mdrvrm8_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
CLEANFILES += mdrvrm1-mdrvrm.f mdrvrm1-msnita.f mdrvrm1-mslbcg.f mdrvrm1-mifunc.f mdrvrm1-mmxoms.f mdrvrm1-mglcol.f mdrvrm1-mpenhf.f mdrvrm1-mmwcol.f mdrvrm1-msfunc.f mdrvrm1-mumcol.f mdrvrm1-mutcfg.f mdrvrm1-mttcol.f mdrvrm1-mmsbcg.f mdrvrm1-mtfunc.f mdrvrm1-muvcio.f mdrvrm1-mmheud.f mdrvrm1-msbmos.f mdrvrm1-mbscol.f mdrvrm1-mprtft.f mdrvrm1-mmcipc.f mdrvrm1-mppmth.f mdrvrm1-mibakw.f bundle-mdrvrm1.f mdrvrm2-mdrvrm.f mdrvrm2-msnita.f mdrvrm2-mslbcg.f mdrvrm2-mifunc.f mdrvrm2-mmxoms.f mdrvrm2-mglcol.f mdrvrm2-mpenhf.f mdrvrm2-mmwcol.f mdrvrm2-msfunc.f mdrvrm2-mumcol.f mdrvrm2-mutcfg.f mdrvrm2-mttcol.f mdrvrm2-mmsbcg.f mdrvrm2-mtfunc.f mdrvrm2-muvcio.f mdrvrm2-mmheud.f mdrvrm2-msbmos.f mdrvrm2-mbscol.f mdrvrm2-mprtft.f mdrvrm2-mmcipc.f mdrvrm2-mppmth.f mdrvrm2-mibakw.f bundle-mdrvrm2.f mdrvrm3-mdrvrm.f mdrvrm3-msnita.f mdrvrm3-mslbcg.f mdrvrm3-mifunc.f mdrvrm3-mmxoms.f mdrvrm3-mglcol.f mdrvrm3-mpenhf.f mdrvrm3-mmwcol.f mdrvrm3-msfunc.f mdrvrm3-mumcol.f mdrvrm3-mutcfg.f mdrvrm3-mttcol.f mdrvrm3-mmsbcg.f mdrvrm3-mtfunc.f mdrvrm3-muvcio.f mdrvrm3-mmheud.f mdrvrm3-msbmos.f mdrvrm3-mbscol.f mdrvrm3-mprtft.f mdrvrm3-mmcipc.f mdrvrm3-mppmth.f mdrvrm3-mibakw.f bundle-mdrvrm3.f mdrvrm4-mdrvrm.f mdrvrm4-msnita.f mdrvrm4-mslbcg.f mdrvrm4-mifunc.f mdrvrm4-mmxoms.f mdrvrm4-mglcol.f mdrvrm4-mpenhf.f mdrvrm4-mmwcol.f mdrvrm4-msfunc.f mdrvrm4-mumcol.f mdrvrm4-mutcfg.f mdrvrm4-mttcol.f mdrvrm4-mmsbcg.f mdrvrm4-mtfunc.f mdrvrm4-muvcio.f mdrvrm4-mmheud.f mdrvrm4-msbmos.f mdrvrm4-mbscol.f mdrvrm4-mprtft.f mdrvrm4-mmcipc.f mdrvrm4-mppmth.f mdrvrm4-mibakw.f mdrvrm4-dbg_mttcol.f bundle-mdrvrm4.f mdrvrm5-mdrvrm.f mdrvrm5-msnita.f mdrvrm5-mslbcg.f mdrvrm5-mifunc.f mdrvrm5-mmxoms.f mdrvrm5-mglcol.f mdrvrm5-mpenhf.f mdrvrm5-mmwcol.f mdrvrm5-msfunc.f mdrvrm5-mumcol.f mdrvrm5-mutcfg.f mdrvrm5-mttcol.f mdrvrm5-mmsbcg.f mdrvrm5-mtfunc.f mdrvrm5-muvcio.f mdrvrm5-mmheud.f mdrvrm5-msbmos.f mdrvrm5-mbscol.f mdrvrm5-mprtft.f mdrvrm5-mmcipc.f mdrvrm5-mppmth.f mdrvrm5-mibakw.f bundle-mdrvrm5.f mdrvrm6-mdrvrm.f mdrvrm6-msnita.f mdrvrm6-mslbcg.f mdrvrm6-mifunc.f mdrvrm6-mmxoms.f mdrvrm6-mglcol.f mdrvrm6-mpenhf.f mdrvrm6-mmwcol.f mdrvrm6-msfunc.f mdrvrm6-mumcol.f mdrvrm6-mutcfg.f mdrvrm6-mttcol.f mdrvrm6-mmsbcg.f mdrvrm6-mtfunc.f mdrvrm6-muvcio.f mdrvrm6-mmheud.f mdrvrm6-msbmos.f mdrvrm6-mbscol.f mdrvrm6-mprtft.f mdrvrm6-mmcipc.f mdrvrm6-mppmth.f mdrvrm6-mibakw.f bundle-mdrvrm6.f mdrvrm7-mdrvrm.f mdrvrm7-msnita.f mdrvrm7-mslbcg.f mdrvrm7-mifunc.f mdrvrm7-mmxoms.f mdrvrm7-mglcol.f mdrvrm7-mpenhf.f mdrvrm7-mmwcol.f mdrvrm7-msfunc.f mdrvrm7-mumcol.f mdrvrm7-mutcfg.f mdrvrm7-mttcol.f mdrvrm7-mmsbcg.f mdrvrm7-mtfunc.f mdrvrm7-muvcio.f mdrvrm7-mmheud.f mdrvrm7-msbmos.f mdrvrm7-mbscol.f mdrvrm7-mprtft.f mdrvrm7-mmcipc.f mdrvrm7-mppmth.f mdrvrm7-mibakw.f bundle-mdrvrm7.f mdrvrm8-mdrvrm.f mdrvrm8-msnita.f mdrvrm8-mslbcg.f mdrvrm8-mifunc.f mdrvrm8-mmxoms.f mdrvrm8-mglcol.f mdrvrm8-mpenhf.f mdrvrm8-mmwcol.f mdrvrm8-msfunc.f mdrvrm8-mumcol.f mdrvrm8-mutcfg.f mdrvrm8-mttcol.f mdrvrm8-mmsbcg.f mdrvrm8-mtfunc.f mdrvrm8-muvcio.f mdrvrm8-mmheud.f mdrvrm8-msbmos.f mdrvrm8-mbscol.f mdrvrm8-mprtft.f mdrvrm8-mmcipc.f mdrvrm8-mppmth.f mdrvrm8-mibakw.f bundle-mdrvrm8.f
check_PROGRAMS += mdrvrm1 mdrvrm2 mdrvrm3 mdrvrm4 mdrvrm5 mdrvrm6 mdrvrm7 mdrvrm8
srcchk-all: srcchk-mdrvrm1 srcchk-mdrvrm2 srcchk-mdrvrm3 srcchk-mdrvrm4 srcchk-mdrvrm5 srcchk-mdrvrm6 srcchk-mdrvrm7 srcchk-mdrvrm8
sublist-all: sublist-mdrvrm1 sublist-mdrvrm2 sublist-mdrvrm3 sublist-mdrvrm4 sublist-mdrvrm5 sublist-mdrvrm6 sublist-mdrvrm7 sublist-mdrvrm8
bundle-all: bundle-mdrvrm1.f bundle-mdrvrm2.f bundle-mdrvrm3.f bundle-mdrvrm4.f bundle-mdrvrm5.f bundle-mdrvrm6.f bundle-mdrvrm7.f bundle-mdrvrm8.f
check-mdrvrm: mdrvrm1 mdrvrm2 mdrvrm3 mdrvrm4 mdrvrm5 mdrvrm6 mdrvrm7 mdrvrm8
#### END ORIGINS/CHECKS mdrvrm.F
#### ORIGINS/CHECKS mglcol.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mglcol-mglcol.Pf@am__quote@ # am--include-marker
mglcol_CPPFLAGS = -DTEST_MGLCOL=1
mglcol-mglcol.f: mglcol.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mglcol_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mglcol_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_mglcol_SOURCES = mglcol-mglcol.f
srcchk-mglcol: $(nodist_mglcol_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_mglcol_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-mglcol: $(nodist_mglcol_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_mglcol_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-mglcol.f: $(nodist_mglcol_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_mglcol_SOURCES)" || cat $(nodist_mglcol_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
CLEANFILES += mglcol-mglcol.f bundle-mglcol.f
check_PROGRAMS += mglcol
srcchk-all: srcchk-mglcol
sublist-all: sublist-mglcol
bundle-all: bundle-mglcol.f
check-mglcol: mglcol
#### END ORIGINS/CHECKS mglcol.F
#### ORIGINS/CHECKS mibakw.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mibakw-mibakw.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mibakw-mifunc.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mibakw-mprtft.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mibakw-mpenhf.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mibakw-mppmth.Pf@am__quote@ # am--include-marker
mibakw_CPPFLAGS = -DTEST_MIBAKW=1
mibakw-mibakw.f: mibakw.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mibakw_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mibakw_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mibakw-mifunc.f: mifunc.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mibakw_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mibakw_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mibakw-mprtft.f: mprtft.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mibakw_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mibakw_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mibakw-mpenhf.f: mpenhf.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mibakw_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mibakw_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mibakw-mppmth.f: mppmth.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mibakw_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mibakw_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_mibakw_SOURCES = mibakw-mibakw.f mibakw-mifunc.f mibakw-mprtft.f mibakw-mpenhf.f mibakw-mppmth.f
srcchk-mibakw: $(nodist_mibakw_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_mibakw_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-mibakw: $(nodist_mibakw_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_mibakw_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-mibakw.f: $(nodist_mibakw_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_mibakw_SOURCES)" || cat $(nodist_mibakw_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
CLEANFILES += mibakw-mibakw.f mibakw-mifunc.f mibakw-mprtft.f mibakw-mpenhf.f mibakw-mppmth.f bundle-mibakw.f
check_PROGRAMS += mibakw
srcchk-all: srcchk-mibakw
sublist-all: sublist-mibakw
bundle-all: bundle-mibakw.f
check-mibakw: mibakw
#### END ORIGINS/CHECKS mibakw.F
#### ORIGINS/CHECKS mifunc.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mifunc1-mifunc.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mifunc1-mprtft.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mifunc1-mpenhf.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mifunc1-mppmth.Pf@am__quote@ # am--include-marker
mifunc1_CPPFLAGS = -DTEST_MIFUNC=1
mifunc1-mifunc.f: mifunc.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mifunc1_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mifunc1_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mifunc1-mprtft.f: mprtft.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mifunc1_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mifunc1_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mifunc1-mpenhf.f: mpenhf.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mifunc1_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mifunc1_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mifunc1-mppmth.f: mppmth.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mifunc1_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mifunc1_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_mifunc1_SOURCES = mifunc1-mifunc.f mifunc1-mprtft.f mifunc1-mpenhf.f mifunc1-mppmth.f
srcchk-mifunc1: $(nodist_mifunc1_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_mifunc1_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-mifunc1: $(nodist_mifunc1_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_mifunc1_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-mifunc1.f: $(nodist_mifunc1_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_mifunc1_SOURCES)" || cat $(nodist_mifunc1_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
CLEANFILES += mifunc1-mifunc.f mifunc1-mprtft.f mifunc1-mpenhf.f mifunc1-mppmth.f bundle-mifunc1.f
check_PROGRAMS += mifunc1
srcchk-all: srcchk-mifunc1
sublist-all: sublist-mifunc1
bundle-all: bundle-mifunc1.f
check-mifunc: mifunc1
#### END ORIGINS/CHECKS mifunc.F
#### ORIGINS/CHECKS mmcipc.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mmcipc-mmcipc.Pf@am__quote@ # am--include-marker
mmcipc_CPPFLAGS = -DTEST_MMCIPC=1
mmcipc-mmcipc.f: mmcipc.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mmcipc_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mmcipc_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_mmcipc_SOURCES = mmcipc-mmcipc.f
srcchk-mmcipc: $(nodist_mmcipc_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_mmcipc_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-mmcipc: $(nodist_mmcipc_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_mmcipc_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-mmcipc.f: $(nodist_mmcipc_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_mmcipc_SOURCES)" || cat $(nodist_mmcipc_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
CLEANFILES += mmcipc-mmcipc.f bundle-mmcipc.f
check_PROGRAMS += mmcipc
srcchk-all: srcchk-mmcipc
sublist-all: sublist-mmcipc
bundle-all: bundle-mmcipc.f
check-mmcipc: mmcipc
#### END ORIGINS/CHECKS mmcipc.F
#### ORIGINS/CHECKS mmheud.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mmheud-mifunc.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mmheud-mmxoms.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mmheud-mpenhf.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mmheud-muvcio.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mmheud-mmheud.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mmheud-mprtft.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mmheud-mppmth.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mmheud-mibakw.Pf@am__quote@ # am--include-marker
mmheud_CPPFLAGS = -DTEST_MMHEUD=1 -DTEST_MMXOMS_SUB=1 -DTEST_MIBAKW_SUB=1
mmheud-mifunc.f: mifunc.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mmheud_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mmheud_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mmheud-mmxoms.f: mmxoms.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mmheud_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mmheud_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mmheud-mpenhf.f: mpenhf.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mmheud_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mmheud_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mmheud-muvcio.f: muvcio.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mmheud_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mmheud_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mmheud-mmheud.f: mmheud.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mmheud_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mmheud_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mmheud-mprtft.f: mprtft.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mmheud_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mmheud_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mmheud-mppmth.f: mppmth.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mmheud_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mmheud_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mmheud-mibakw.f: mibakw.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mmheud_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mmheud_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_mmheud_SOURCES = mmheud-mifunc.f mmheud-mmxoms.f mmheud-mpenhf.f mmheud-muvcio.f mmheud-mmheud.f mmheud-mprtft.f mmheud-mppmth.f mmheud-mibakw.f
srcchk-mmheud: $(nodist_mmheud_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_mmheud_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-mmheud: $(nodist_mmheud_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_mmheud_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-mmheud.f: $(nodist_mmheud_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_mmheud_SOURCES)" || cat $(nodist_mmheud_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
CLEANFILES += mmheud-mifunc.f mmheud-mmxoms.f mmheud-mpenhf.f mmheud-muvcio.f mmheud-mmheud.f mmheud-mprtft.f mmheud-mppmth.f mmheud-mibakw.f bundle-mmheud.f
check_PROGRAMS += mmheud
srcchk-all: srcchk-mmheud
sublist-all: sublist-mmheud
bundle-all: bundle-mmheud.f
check-mmheud: mmheud
#### END ORIGINS/CHECKS mmheud.F
#### ORIGINS/CHECKS mmsbcg.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mmsbcg-mmsbcg.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mmsbcg-mifunc.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mmsbcg-mmxoms.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mmsbcg-mpenhf.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mmsbcg-muvcio.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mmsbcg-mmheud.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mmsbcg-mprtft.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mmsbcg-mppmth.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mmsbcg-mibakw.Pf@am__quote@ # am--include-marker
mmsbcg_CPPFLAGS = -DTEST_MMSBCG=1 -DTEST_MMXOMS_SUB=1 -DTEST_MIBAKW_SUB=1
mmsbcg-mmsbcg.f: mmsbcg.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mmsbcg_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mmsbcg_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mmsbcg-mifunc.f: mifunc.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mmsbcg_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mmsbcg_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mmsbcg-mmxoms.f: mmxoms.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mmsbcg_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mmsbcg_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mmsbcg-mpenhf.f: mpenhf.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mmsbcg_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mmsbcg_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mmsbcg-muvcio.f: muvcio.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mmsbcg_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mmsbcg_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mmsbcg-mmheud.f: mmheud.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mmsbcg_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mmsbcg_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mmsbcg-mprtft.f: mprtft.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mmsbcg_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mmsbcg_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mmsbcg-mppmth.f: mppmth.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mmsbcg_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mmsbcg_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mmsbcg-mibakw.f: mibakw.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mmsbcg_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mmsbcg_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_mmsbcg_SOURCES = mmsbcg-mmsbcg.f mmsbcg-mifunc.f mmsbcg-mmxoms.f mmsbcg-mpenhf.f mmsbcg-muvcio.f mmsbcg-mmheud.f mmsbcg-mprtft.f mmsbcg-mppmth.f mmsbcg-mibakw.f
srcchk-mmsbcg: $(nodist_mmsbcg_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_mmsbcg_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-mmsbcg: $(nodist_mmsbcg_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_mmsbcg_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-mmsbcg.f: $(nodist_mmsbcg_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_mmsbcg_SOURCES)" || cat $(nodist_mmsbcg_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
CLEANFILES += mmsbcg-mmsbcg.f mmsbcg-mifunc.f mmsbcg-mmxoms.f mmsbcg-mpenhf.f mmsbcg-muvcio.f mmsbcg-mmheud.f mmsbcg-mprtft.f mmsbcg-mppmth.f mmsbcg-mibakw.f bundle-mmsbcg.f
check_PROGRAMS += mmsbcg
srcchk-all: srcchk-mmsbcg
sublist-all: sublist-mmsbcg
bundle-all: bundle-mmsbcg.f
check-mmsbcg: mmsbcg
#### END ORIGINS/CHECKS mmsbcg.F
#### ORIGINS/CHECKS mmwcol.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mmwcol-mmwcol.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mmwcol-mifunc.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mmwcol-mmxoms.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mmwcol-mpenhf.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mmwcol-muvcio.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mmwcol-mmheud.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mmwcol-mprtft.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mmwcol-mppmth.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mmwcol-mibakw.Pf@am__quote@ # am--include-marker
mmwcol_CPPFLAGS = -DTEST_MMWCOL=1 -DTEST_MIBAKW_SUB=1
mmwcol-mmwcol.f: mmwcol.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mmwcol_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mmwcol_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mmwcol-mifunc.f: mifunc.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mmwcol_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mmwcol_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mmwcol-mmxoms.f: mmxoms.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mmwcol_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mmwcol_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mmwcol-mpenhf.f: mpenhf.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mmwcol_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mmwcol_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mmwcol-muvcio.f: muvcio.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mmwcol_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mmwcol_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mmwcol-mmheud.f: mmheud.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mmwcol_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mmwcol_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mmwcol-mprtft.f: mprtft.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mmwcol_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mmwcol_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mmwcol-mppmth.f: mppmth.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mmwcol_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mmwcol_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mmwcol-mibakw.f: mibakw.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mmwcol_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mmwcol_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_mmwcol_SOURCES = mmwcol-mmwcol.f mmwcol-mifunc.f mmwcol-mmxoms.f mmwcol-mpenhf.f mmwcol-muvcio.f mmwcol-mmheud.f mmwcol-mprtft.f mmwcol-mppmth.f mmwcol-mibakw.f
srcchk-mmwcol: $(nodist_mmwcol_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_mmwcol_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-mmwcol: $(nodist_mmwcol_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_mmwcol_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-mmwcol.f: $(nodist_mmwcol_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_mmwcol_SOURCES)" || cat $(nodist_mmwcol_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
CLEANFILES += mmwcol-mmwcol.f mmwcol-mifunc.f mmwcol-mmxoms.f mmwcol-mpenhf.f mmwcol-muvcio.f mmwcol-mmheud.f mmwcol-mprtft.f mmwcol-mppmth.f mmwcol-mibakw.f bundle-mmwcol.f
check_PROGRAMS += mmwcol
srcchk-all: srcchk-mmwcol
sublist-all: sublist-mmwcol
bundle-all: bundle-mmwcol.f
check-mmwcol: mmwcol
#### END ORIGINS/CHECKS mmwcol.F
#### ORIGINS/CHECKS mmxoms.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mmxoms-mifunc.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mmxoms-mmxoms.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mmxoms-mpenhf.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mmxoms-muvcio.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mmxoms-mmheud.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mmxoms-mprtft.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mmxoms-mppmth.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mmxoms-mibakw.Pf@am__quote@ # am--include-marker
mmxoms_CPPFLAGS = -DTEST_MMXOMS=1 -DTEST_MMXOMS_SUB=1 -DTEST_MIBAKW_SUB=1
mmxoms-mifunc.f: mifunc.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mmxoms_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mmxoms_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mmxoms-mmxoms.f: mmxoms.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mmxoms_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mmxoms_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mmxoms-mpenhf.f: mpenhf.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mmxoms_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mmxoms_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mmxoms-muvcio.f: muvcio.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mmxoms_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mmxoms_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mmxoms-mmheud.f: mmheud.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mmxoms_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mmxoms_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mmxoms-mprtft.f: mprtft.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mmxoms_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mmxoms_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mmxoms-mppmth.f: mppmth.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mmxoms_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mmxoms_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mmxoms-mibakw.f: mibakw.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mmxoms_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mmxoms_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_mmxoms_SOURCES = mmxoms-mifunc.f mmxoms-mmxoms.f mmxoms-mpenhf.f mmxoms-muvcio.f mmxoms-mmheud.f mmxoms-mprtft.f mmxoms-mppmth.f mmxoms-mibakw.f
srcchk-mmxoms: $(nodist_mmxoms_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_mmxoms_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-mmxoms: $(nodist_mmxoms_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_mmxoms_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-mmxoms.f: $(nodist_mmxoms_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_mmxoms_SOURCES)" || cat $(nodist_mmxoms_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
CLEANFILES += mmxoms-mifunc.f mmxoms-mmxoms.f mmxoms-mpenhf.f mmxoms-muvcio.f mmxoms-mmheud.f mmxoms-mprtft.f mmxoms-mppmth.f mmxoms-mibakw.f bundle-mmxoms.f
check_PROGRAMS += mmxoms
srcchk-all: srcchk-mmxoms
sublist-all: sublist-mmxoms
bundle-all: bundle-mmxoms.f
check-mmxoms: mmxoms
#### END ORIGINS/CHECKS mmxoms.F
#### ORIGINS/CHECKS mpenhf.F
CLEANFILES += 
check_PROGRAMS += 
srcchk-all:
sublist-all:
bundle-all:
check-mpenhf:
#### END ORIGINS/CHECKS mpenhf.F
#### ORIGINS/CHECKS mppmth.F
CLEANFILES += 
check_PROGRAMS += 
srcchk-all:
sublist-all:
bundle-all:
check-mppmth:
#### END ORIGINS/CHECKS mppmth.F
#### ORIGINS/CHECKS mprtft.F
CLEANFILES += 
check_PROGRAMS += 
srcchk-all:
sublist-all:
bundle-all:
check-mprtft:
#### END ORIGINS/CHECKS mprtft.F
#### ORIGINS/CHECKS msbmos.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/msbmos-msbmos.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/msbmos-mifunc.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/msbmos-mpenhf.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/msbmos-msfunc.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/msbmos-mutcfg.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/msbmos-mprtft.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/msbmos-mppmth.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/msbmos-mibakw.Pf@am__quote@ # am--include-marker
msbmos_CPPFLAGS = -DTEST_MSBMOS=1
msbmos-msbmos.f: msbmos.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(msbmos_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(msbmos_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
msbmos-mifunc.f: mifunc.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(msbmos_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(msbmos_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
msbmos-mpenhf.f: mpenhf.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(msbmos_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(msbmos_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
msbmos-msfunc.f: msfunc.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(msbmos_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(msbmos_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
msbmos-mutcfg.f: mutcfg.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(msbmos_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(msbmos_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
msbmos-mprtft.f: mprtft.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(msbmos_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(msbmos_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
msbmos-mppmth.f: mppmth.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(msbmos_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(msbmos_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
msbmos-mibakw.f: mibakw.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(msbmos_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(msbmos_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_msbmos_SOURCES = msbmos-msbmos.f msbmos-mifunc.f msbmos-mpenhf.f msbmos-msfunc.f msbmos-mutcfg.f msbmos-mprtft.f msbmos-mppmth.f msbmos-mibakw.f
srcchk-msbmos: $(nodist_msbmos_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_msbmos_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-msbmos: $(nodist_msbmos_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_msbmos_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-msbmos.f: $(nodist_msbmos_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_msbmos_SOURCES)" || cat $(nodist_msbmos_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
CLEANFILES += msbmos-msbmos.f msbmos-mifunc.f msbmos-mpenhf.f msbmos-msfunc.f msbmos-mutcfg.f msbmos-mprtft.f msbmos-mppmth.f msbmos-mibakw.f bundle-msbmos.f
check_PROGRAMS += msbmos
srcchk-all: srcchk-msbmos
sublist-all: sublist-msbmos
bundle-all: bundle-msbmos.f
check-msbmos: msbmos
#### END ORIGINS/CHECKS msbmos.F
#### ORIGINS/CHECKS mscpli.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mscpli-mscpli.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mscpli-msnita.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mscpli-mslbcg.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mscpli-mifunc.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mscpli-mmxoms.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mscpli-mglcol.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mscpli-mpenhf.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mscpli-msfunc.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mscpli-mutcfg.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mscpli-muvcio.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mscpli-mmheud.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mscpli-msbmos.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mscpli-mprtft.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mscpli-mppmth.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mscpli-mibakw.Pf@am__quote@ # am--include-marker
mscpli_CPPFLAGS = -DTEST_MSCPLI=1 -DTEST_MSBMOS_SUB=1
mscpli-mscpli.f: mscpli.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mscpli_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mscpli_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mscpli-msnita.f: msnita.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mscpli_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mscpli_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mscpli-mslbcg.f: mslbcg.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mscpli_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mscpli_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mscpli-mifunc.f: mifunc.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mscpli_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mscpli_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mscpli-mmxoms.f: mmxoms.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mscpli_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mscpli_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mscpli-mglcol.f: mglcol.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mscpli_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mscpli_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mscpli-mpenhf.f: mpenhf.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mscpli_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mscpli_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mscpli-msfunc.f: msfunc.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mscpli_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mscpli_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mscpli-mutcfg.f: mutcfg.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mscpli_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mscpli_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mscpli-muvcio.f: muvcio.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mscpli_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mscpli_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mscpli-mmheud.f: mmheud.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mscpli_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mscpli_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mscpli-msbmos.f: msbmos.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mscpli_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mscpli_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mscpli-mprtft.f: mprtft.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mscpli_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mscpli_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mscpli-mppmth.f: mppmth.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mscpli_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mscpli_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mscpli-mibakw.f: mibakw.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mscpli_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mscpli_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_mscpli_SOURCES = mscpli-mscpli.f mscpli-msnita.f mscpli-mslbcg.f mscpli-mifunc.f mscpli-mmxoms.f mscpli-mglcol.f mscpli-mpenhf.f mscpli-msfunc.f mscpli-mutcfg.f mscpli-muvcio.f mscpli-mmheud.f mscpli-msbmos.f mscpli-mprtft.f mscpli-mppmth.f mscpli-mibakw.f
srcchk-mscpli: $(nodist_mscpli_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_mscpli_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-mscpli: $(nodist_mscpli_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_mscpli_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-mscpli.f: $(nodist_mscpli_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_mscpli_SOURCES)" || cat $(nodist_mscpli_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
CLEANFILES += mscpli-mscpli.f mscpli-msnita.f mscpli-mslbcg.f mscpli-mifunc.f mscpli-mmxoms.f mscpli-mglcol.f mscpli-mpenhf.f mscpli-msfunc.f mscpli-mutcfg.f mscpli-muvcio.f mscpli-mmheud.f mscpli-msbmos.f mscpli-mprtft.f mscpli-mppmth.f mscpli-mibakw.f bundle-mscpli.f
check_PROGRAMS += mscpli
srcchk-all: srcchk-mscpli
sublist-all: sublist-mscpli
bundle-all: bundle-mscpli.f
check-mscpli: mscpli
#### END ORIGINS/CHECKS mscpli.F
#### ORIGINS/CHECKS msfunc.F
CLEANFILES += 
check_PROGRAMS += 
srcchk-all:
sublist-all:
bundle-all:
check-msfunc:
#### END ORIGINS/CHECKS msfunc.F
#### ORIGINS/CHECKS mslbcg.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mslbcg-mslbcg.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mslbcg-mifunc.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mslbcg-mpenhf.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mslbcg-msfunc.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mslbcg-mutcfg.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mslbcg-msbmos.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mslbcg-mprtft.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mslbcg-mppmth.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mslbcg-mibakw.Pf@am__quote@ # am--include-marker
mslbcg_CPPFLAGS = -DTEST_MSLBCG=1 -DTEST_MSBMOS_SUB=1
mslbcg-mslbcg.f: mslbcg.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mslbcg_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mslbcg_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mslbcg-mifunc.f: mifunc.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mslbcg_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mslbcg_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mslbcg-mpenhf.f: mpenhf.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mslbcg_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mslbcg_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mslbcg-msfunc.f: msfunc.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mslbcg_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mslbcg_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mslbcg-mutcfg.f: mutcfg.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mslbcg_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mslbcg_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mslbcg-msbmos.f: msbmos.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mslbcg_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mslbcg_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mslbcg-mprtft.f: mprtft.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mslbcg_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mslbcg_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mslbcg-mppmth.f: mppmth.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mslbcg_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mslbcg_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mslbcg-mibakw.f: mibakw.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mslbcg_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mslbcg_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_mslbcg_SOURCES = mslbcg-mslbcg.f mslbcg-mifunc.f mslbcg-mpenhf.f mslbcg-msfunc.f mslbcg-mutcfg.f mslbcg-msbmos.f mslbcg-mprtft.f mslbcg-mppmth.f mslbcg-mibakw.f
srcchk-mslbcg: $(nodist_mslbcg_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_mslbcg_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-mslbcg: $(nodist_mslbcg_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_mslbcg_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-mslbcg.f: $(nodist_mslbcg_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_mslbcg_SOURCES)" || cat $(nodist_mslbcg_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
CLEANFILES += mslbcg-mslbcg.f mslbcg-mifunc.f mslbcg-mpenhf.f mslbcg-msfunc.f mslbcg-mutcfg.f mslbcg-msbmos.f mslbcg-mprtft.f mslbcg-mppmth.f mslbcg-mibakw.f bundle-mslbcg.f
check_PROGRAMS += mslbcg
srcchk-all: srcchk-mslbcg
sublist-all: sublist-mslbcg
bundle-all: bundle-mslbcg.f
check-mslbcg: mslbcg
#### END ORIGINS/CHECKS mslbcg.F
#### ORIGINS/CHECKS msnita.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/msnita-msnita.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/msnita-mslbcg.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/msnita-mifunc.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/msnita-mmxoms.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/msnita-mglcol.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/msnita-mpenhf.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/msnita-msfunc.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/msnita-mutcfg.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/msnita-muvcio.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/msnita-mmheud.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/msnita-msbmos.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/msnita-mprtft.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/msnita-mppmth.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/msnita-mibakw.Pf@am__quote@ # am--include-marker
msnita_CPPFLAGS = -DTEST_MSNITA=1 -DTEST_MSBMOS_SUB=1
msnita-msnita.f: msnita.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(msnita_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(msnita_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
msnita-mslbcg.f: mslbcg.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(msnita_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(msnita_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
msnita-mifunc.f: mifunc.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(msnita_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(msnita_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
msnita-mmxoms.f: mmxoms.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(msnita_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(msnita_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
msnita-mglcol.f: mglcol.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(msnita_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(msnita_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
msnita-mpenhf.f: mpenhf.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(msnita_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(msnita_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
msnita-msfunc.f: msfunc.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(msnita_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(msnita_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
msnita-mutcfg.f: mutcfg.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(msnita_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(msnita_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
msnita-muvcio.f: muvcio.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(msnita_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(msnita_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
msnita-mmheud.f: mmheud.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(msnita_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(msnita_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
msnita-msbmos.f: msbmos.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(msnita_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(msnita_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
msnita-mprtft.f: mprtft.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(msnita_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(msnita_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
msnita-mppmth.f: mppmth.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(msnita_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(msnita_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
msnita-mibakw.f: mibakw.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(msnita_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(msnita_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_msnita_SOURCES = msnita-msnita.f msnita-mslbcg.f msnita-mifunc.f msnita-mmxoms.f msnita-mglcol.f msnita-mpenhf.f msnita-msfunc.f msnita-mutcfg.f msnita-muvcio.f msnita-mmheud.f msnita-msbmos.f msnita-mprtft.f msnita-mppmth.f msnita-mibakw.f
srcchk-msnita: $(nodist_msnita_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_msnita_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-msnita: $(nodist_msnita_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_msnita_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-msnita.f: $(nodist_msnita_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_msnita_SOURCES)" || cat $(nodist_msnita_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
CLEANFILES += msnita-msnita.f msnita-mslbcg.f msnita-mifunc.f msnita-mmxoms.f msnita-mglcol.f msnita-mpenhf.f msnita-msfunc.f msnita-mutcfg.f msnita-muvcio.f msnita-mmheud.f msnita-msbmos.f msnita-mprtft.f msnita-mppmth.f msnita-mibakw.f bundle-msnita.f
check_PROGRAMS += msnita
srcchk-all: srcchk-msnita
sublist-all: sublist-msnita
bundle-all: bundle-msnita.f
check-msnita: msnita
#### END ORIGINS/CHECKS msnita.F
#### ORIGINS/CHECKS mtfunc.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mtfunc-mtfunc.Pf@am__quote@ # am--include-marker
mtfunc_CPPFLAGS = -DTEST_MTFUNC=1
mtfunc-mtfunc.f: mtfunc.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mtfunc_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mtfunc_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_mtfunc_SOURCES = mtfunc-mtfunc.f
srcchk-mtfunc: $(nodist_mtfunc_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_mtfunc_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-mtfunc: $(nodist_mtfunc_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_mtfunc_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-mtfunc.f: $(nodist_mtfunc_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_mtfunc_SOURCES)" || cat $(nodist_mtfunc_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
CLEANFILES += mtfunc-mtfunc.f bundle-mtfunc.f
check_PROGRAMS += mtfunc
srcchk-all: srcchk-mtfunc
sublist-all: sublist-mtfunc
bundle-all: bundle-mtfunc.f
check-mtfunc: mtfunc
#### END ORIGINS/CHECKS mtfunc.F
#### ORIGINS/CHECKS mttcol.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mttcol-mttcol.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mttcol-mtfunc.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mttcol-mppmth.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mttcol-mumcol.Pf@am__quote@ # am--include-marker
mttcol_CPPFLAGS = -DTEST_MTTCOL=1
mttcol-mttcol.f: mttcol.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mttcol_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mttcol_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mttcol-mtfunc.f: mtfunc.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mttcol_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mttcol_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mttcol-mppmth.f: mppmth.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mttcol_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mttcol_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mttcol-mumcol.f: mumcol.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mttcol_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mttcol_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_mttcol_SOURCES = mttcol-mttcol.f mttcol-mtfunc.f mttcol-mppmth.f mttcol-mumcol.f
srcchk-mttcol: $(nodist_mttcol_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_mttcol_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-mttcol: $(nodist_mttcol_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_mttcol_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-mttcol.f: $(nodist_mttcol_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_mttcol_SOURCES)" || cat $(nodist_mttcol_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
CLEANFILES += mttcol-mttcol.f mttcol-mtfunc.f mttcol-mppmth.f mttcol-mumcol.f bundle-mttcol.f
check_PROGRAMS += mttcol
srcchk-all: srcchk-mttcol
sublist-all: sublist-mttcol
bundle-all: bundle-mttcol.f
check-mttcol: mttcol
#### END ORIGINS/CHECKS mttcol.F
#### ORIGINS/CHECKS mumcol.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mumcol-mumcol.Pf@am__quote@ # am--include-marker
mumcol_CPPFLAGS = -DTEST_MUMCOL=1
mumcol-mumcol.f: mumcol.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mumcol_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mumcol_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_mumcol_SOURCES = mumcol-mumcol.f
srcchk-mumcol: $(nodist_mumcol_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_mumcol_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-mumcol: $(nodist_mumcol_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_mumcol_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-mumcol.f: $(nodist_mumcol_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_mumcol_SOURCES)" || cat $(nodist_mumcol_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
CLEANFILES += mumcol-mumcol.f bundle-mumcol.f
check_PROGRAMS += mumcol
srcchk-all: srcchk-mumcol
sublist-all: sublist-mumcol
bundle-all: bundle-mumcol.f
check-mumcol: mumcol
#### END ORIGINS/CHECKS mumcol.F
#### ORIGINS/CHECKS mutcfg.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mutcfg-mutcfg.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mutcfg-mifunc.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mutcfg-mprtft.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mutcfg-mpenhf.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mutcfg-msfunc.Pf@am__quote@ # am--include-marker
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/mutcfg-mppmth.Pf@am__quote@ # am--include-marker
mutcfg_CPPFLAGS = -DTEST_MUTCFG=1
mutcfg-mutcfg.f: mutcfg.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mutcfg_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mutcfg_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mutcfg-mifunc.f: mifunc.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mutcfg_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mutcfg_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mutcfg-mprtft.f: mprtft.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mutcfg_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mutcfg_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mutcfg-mpenhf.f: mpenhf.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mutcfg_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mutcfg_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mutcfg-msfunc.f: msfunc.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mutcfg_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mutcfg_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
mutcfg-mppmth.f: mppmth.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(mutcfg_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(mutcfg_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_mutcfg_SOURCES = mutcfg-mutcfg.f mutcfg-mifunc.f mutcfg-mprtft.f mutcfg-mpenhf.f mutcfg-msfunc.f mutcfg-mppmth.f
srcchk-mutcfg: $(nodist_mutcfg_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_mutcfg_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-mutcfg: $(nodist_mutcfg_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_mutcfg_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-mutcfg.f: $(nodist_mutcfg_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_mutcfg_SOURCES)" || cat $(nodist_mutcfg_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
CLEANFILES += mutcfg-mutcfg.f mutcfg-mifunc.f mutcfg-mprtft.f mutcfg-mpenhf.f mutcfg-msfunc.f mutcfg-mppmth.f bundle-mutcfg.f
check_PROGRAMS += mutcfg
srcchk-all: srcchk-mutcfg
sublist-all: sublist-mutcfg
bundle-all: bundle-mutcfg.f
check-mutcfg: mutcfg
#### END ORIGINS/CHECKS mutcfg.F
#### ORIGINS/CHECKS muvcio.F
@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/muvcio-muvcio.Pf@am__quote@ # am--include-marker
muvcio_CPPFLAGS = -DTEST_MUVCIO=1
muvcio-muvcio.f: muvcio.F
@am__fastdepCC_TRUE@	$(F77PREPROCESS) $(muvcio_CPPFLAGS) -MT $@ -MD -MP -MF $(DEPDIR)/$*.TPf -c -o $@ $<
@am__fastdepCC_TRUE@	mv -f $(DEPDIR)/$*.TPf $(DEPDIR)/$*.Pf
@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CPPDEPMODE) $(depcomp) @AMDEPBACKSLASH@
@am__fastdepCC_FALSE@	$(F77PREPROCESS) $(muvcio_CPPFLAGS) `test -f $< || echo '$(srcdir)/'`$< > $@ || rm -f $@
nodist_muvcio_SOURCES = muvcio-muvcio.f
srcchk-muvcio: $(nodist_muvcio_SOURCES)
	$(FORTRAN_CHECK) $(FORTRAN_CHECK_FLAGS) $(nodist_muvcio_SOURCES) $(FORTRAN_CHECK_ADD)
sublist-muvcio: $(nodist_muvcio_SOURCES)
	$(FORTRAN_LIST) $(FORTRAN_LIST_FLAGS) $(nodist_muvcio_SOURCES) $(FORTRAN_CHECK_ADD)
bundle-muvcio.f: $(nodist_muvcio_SOURCES) $(FORTRAN_CHECK_ADD)
	test -z "$(nodist_muvcio_SOURCES)" || cat $(nodist_muvcio_SOURCES) $(FORTRAN_CHECK_ADD) > $@ || rm -f $@
CLEANFILES += muvcio-muvcio.f bundle-muvcio.f
check_PROGRAMS += muvcio
srcchk-all: srcchk-muvcio
sublist-all: sublist-muvcio
bundle-all: bundle-muvcio.f
check-muvcio: muvcio
#### END ORIGINS/CHECKS muvcio.F
am__depfiles_remade = ./$(DEPDIR)/muvcio.Pf ./$(DEPDIR)/mutcfg.Pf ./$(DEPDIR)/mumcol.Pf ./$(DEPDIR)/mppmth.Pf ./$(DEPDIR)/mprtft.Pf ./$(DEPDIR)/mpenhf.Pf ./$(DEPDIR)/mifunc.Pf ./$(DEPDIR)/mibakw.Pf ./$(DEPDIR)/mmxoms.Pf ./$(DEPDIR)/msbmos.Pf ./$(DEPDIR)/mmsbcg.Pf ./$(DEPDIR)/msfunc.Pf ./$(DEPDIR)/mmcipc.Pf ./$(DEPDIR)/mmheud.Pf ./$(DEPDIR)/mmwcol.Pf ./$(DEPDIR)/mbscol.Pf ./$(DEPDIR)/mdrvrm.Pf ./$(DEPDIR)/mslbcg.Pf ./$(DEPDIR)/mglcol.Pf ./$(DEPDIR)/msnita.Pf ./$(DEPDIR)/mscpli.Pf ./$(DEPDIR)/mtfunc.Pf ./$(DEPDIR)/mttcol.Pf ./$(DEPDIR)/magcol.Pf ./$(DEPDIR)/magcol-magcol.Pf ./$(DEPDIR)/mbscol-mbscol.Pf ./$(DEPDIR)/mdrvrm1-mdrvrm.Pf ./$(DEPDIR)/mdrvrm1-msnita.Pf ./$(DEPDIR)/mdrvrm1-mslbcg.Pf ./$(DEPDIR)/mdrvrm1-mifunc.Pf ./$(DEPDIR)/mdrvrm1-mmxoms.Pf ./$(DEPDIR)/mdrvrm1-mglcol.Pf ./$(DEPDIR)/mdrvrm1-mpenhf.Pf ./$(DEPDIR)/mdrvrm1-mmwcol.Pf ./$(DEPDIR)/mdrvrm1-msfunc.Pf ./$(DEPDIR)/mdrvrm1-mumcol.Pf ./$(DEPDIR)/mdrvrm1-mutcfg.Pf ./$(DEPDIR)/mdrvrm1-mttcol.Pf ./$(DEPDIR)/mdrvrm1-mmsbcg.Pf ./$(DEPDIR)/mdrvrm1-mtfunc.Pf ./$(DEPDIR)/mdrvrm1-muvcio.Pf ./$(DEPDIR)/mdrvrm1-mmheud.Pf ./$(DEPDIR)/mdrvrm1-msbmos.Pf ./$(DEPDIR)/mdrvrm1-mbscol.Pf ./$(DEPDIR)/mdrvrm1-mprtft.Pf ./$(DEPDIR)/mdrvrm1-mmcipc.Pf ./$(DEPDIR)/mdrvrm1-mppmth.Pf ./$(DEPDIR)/mdrvrm1-mibakw.Pf ./$(DEPDIR)/mdrvrm2-mdrvrm.Pf ./$(DEPDIR)/mdrvrm2-msnita.Pf ./$(DEPDIR)/mdrvrm2-mslbcg.Pf ./$(DEPDIR)/mdrvrm2-mifunc.Pf ./$(DEPDIR)/mdrvrm2-mmxoms.Pf ./$(DEPDIR)/mdrvrm2-mglcol.Pf ./$(DEPDIR)/mdrvrm2-mpenhf.Pf ./$(DEPDIR)/mdrvrm2-mmwcol.Pf ./$(DEPDIR)/mdrvrm2-msfunc.Pf ./$(DEPDIR)/mdrvrm2-mumcol.Pf ./$(DEPDIR)/mdrvrm2-mutcfg.Pf ./$(DEPDIR)/mdrvrm2-mttcol.Pf ./$(DEPDIR)/mdrvrm2-mmsbcg.Pf ./$(DEPDIR)/mdrvrm2-mtfunc.Pf ./$(DEPDIR)/mdrvrm2-muvcio.Pf ./$(DEPDIR)/mdrvrm2-mmheud.Pf ./$(DEPDIR)/mdrvrm2-msbmos.Pf ./$(DEPDIR)/mdrvrm2-mbscol.Pf ./$(DEPDIR)/mdrvrm2-mprtft.Pf ./$(DEPDIR)/mdrvrm2-mmcipc.Pf ./$(DEPDIR)/mdrvrm2-mppmth.Pf ./$(DEPDIR)/mdrvrm2-mibakw.Pf ./$(DEPDIR)/mdrvrm3-mdrvrm.Pf ./$(DEPDIR)/mdrvrm3-msnita.Pf ./$(DEPDIR)/mdrvrm3-mslbcg.Pf ./$(DEPDIR)/mdrvrm3-mifunc.Pf ./$(DEPDIR)/mdrvrm3-mmxoms.Pf ./$(DEPDIR)/mdrvrm3-mglcol.Pf ./$(DEPDIR)/mdrvrm3-mpenhf.Pf ./$(DEPDIR)/mdrvrm3-mmwcol.Pf ./$(DEPDIR)/mdrvrm3-msfunc.Pf ./$(DEPDIR)/mdrvrm3-mumcol.Pf ./$(DEPDIR)/mdrvrm3-mutcfg.Pf ./$(DEPDIR)/mdrvrm3-mttcol.Pf ./$(DEPDIR)/mdrvrm3-mmsbcg.Pf ./$(DEPDIR)/mdrvrm3-mtfunc.Pf ./$(DEPDIR)/mdrvrm3-muvcio.Pf ./$(DEPDIR)/mdrvrm3-mmheud.Pf ./$(DEPDIR)/mdrvrm3-msbmos.Pf ./$(DEPDIR)/mdrvrm3-mbscol.Pf ./$(DEPDIR)/mdrvrm3-mprtft.Pf ./$(DEPDIR)/mdrvrm3-mmcipc.Pf ./$(DEPDIR)/mdrvrm3-mppmth.Pf ./$(DEPDIR)/mdrvrm3-mibakw.Pf ./$(DEPDIR)/mdrvrm4-mdrvrm.Pf ./$(DEPDIR)/mdrvrm4-msnita.Pf ./$(DEPDIR)/mdrvrm4-mslbcg.Pf ./$(DEPDIR)/mdrvrm4-mifunc.Pf ./$(DEPDIR)/mdrvrm4-mmxoms.Pf ./$(DEPDIR)/mdrvrm4-mglcol.Pf ./$(DEPDIR)/mdrvrm4-mpenhf.Pf ./$(DEPDIR)/mdrvrm4-mmwcol.Pf ./$(DEPDIR)/mdrvrm4-msfunc.Pf ./$(DEPDIR)/mdrvrm4-mumcol.Pf ./$(DEPDIR)/mdrvrm4-mutcfg.Pf ./$(DEPDIR)/mdrvrm4-mttcol.Pf ./$(DEPDIR)/mdrvrm4-mmsbcg.Pf ./$(DEPDIR)/mdrvrm4-mtfunc.Pf ./$(DEPDIR)/mdrvrm4-muvcio.Pf ./$(DEPDIR)/mdrvrm4-mmheud.Pf ./$(DEPDIR)/mdrvrm4-msbmos.Pf ./$(DEPDIR)/mdrvrm4-mbscol.Pf ./$(DEPDIR)/mdrvrm4-mprtft.Pf ./$(DEPDIR)/mdrvrm4-mmcipc.Pf ./$(DEPDIR)/mdrvrm4-mppmth.Pf ./$(DEPDIR)/mdrvrm4-mibakw.Pf ./$(DEPDIR)/mdrvrm4-dbg_mttcol.Pf ./$(DEPDIR)/mdrvrm5-mdrvrm.Pf ./$(DEPDIR)/mdrvrm5-msnita.Pf ./$(DEPDIR)/mdrvrm5-mslbcg.Pf ./$(DEPDIR)/mdrvrm5-mifunc.Pf ./$(DEPDIR)/mdrvrm5-mmxoms.Pf ./$(DEPDIR)/mdrvrm5-mglcol.Pf ./$(DEPDIR)/mdrvrm5-mpenhf.Pf ./$(DEPDIR)/mdrvrm5-mmwcol.Pf ./$(DEPDIR)/mdrvrm5-msfunc.Pf ./$(DEPDIR)/mdrvrm5-mumcol.Pf ./$(DEPDIR)/mdrvrm5-mutcfg.Pf ./$(DEPDIR)/mdrvrm5-mttcol.Pf ./$(DEPDIR)/mdrvrm5-mmsbcg.Pf ./$(DEPDIR)/mdrvrm5-mtfunc.Pf ./$(DEPDIR)/mdrvrm5-muvcio.Pf ./$(DEPDIR)/mdrvrm5-mmheud.Pf ./$(DEPDIR)/mdrvrm5-msbmos.Pf ./$(DEPDIR)/mdrvrm5-mbscol.Pf ./$(DEPDIR)/mdrvrm5-mprtft.Pf ./$(DEPDIR)/mdrvrm5-mmcipc.Pf ./$(DEPDIR)/mdrvrm5-mppmth.Pf ./$(DEPDIR)/mdrvrm5-mibakw.Pf ./$(DEPDIR)/mdrvrm6-mdrvrm.Pf ./$(DEPDIR)/mdrvrm6-msnita.Pf ./$(DEPDIR)/mdrvrm6-mslbcg.Pf ./$(DEPDIR)/mdrvrm6-mifunc.Pf ./$(DEPDIR)/mdrvrm6-mmxoms.Pf ./$(DEPDIR)/mdrvrm6-mglcol.Pf ./$(DEPDIR)/mdrvrm6-mpenhf.Pf ./$(DEPDIR)/mdrvrm6-mmwcol.Pf ./$(DEPDIR)/mdrvrm6-msfunc.Pf ./$(DEPDIR)/mdrvrm6-mumcol.Pf ./$(DEPDIR)/mdrvrm6-mutcfg.Pf ./$(DEPDIR)/mdrvrm6-mttcol.Pf ./$(DEPDIR)/mdrvrm6-mmsbcg.Pf ./$(DEPDIR)/mdrvrm6-mtfunc.Pf ./$(DEPDIR)/mdrvrm6-muvcio.Pf ./$(DEPDIR)/mdrvrm6-mmheud.Pf ./$(DEPDIR)/mdrvrm6-msbmos.Pf ./$(DEPDIR)/mdrvrm6-mbscol.Pf ./$(DEPDIR)/mdrvrm6-mprtft.Pf ./$(DEPDIR)/mdrvrm6-mmcipc.Pf ./$(DEPDIR)/mdrvrm6-mppmth.Pf ./$(DEPDIR)/mdrvrm6-mibakw.Pf ./$(DEPDIR)/mdrvrm7-mdrvrm.Pf ./$(DEPDIR)/mdrvrm7-msnita.Pf ./$(DEPDIR)/mdrvrm7-mslbcg.Pf ./$(DEPDIR)/mdrvrm7-mifunc.Pf ./$(DEPDIR)/mdrvrm7-mmxoms.Pf ./$(DEPDIR)/mdrvrm7-mglcol.Pf ./$(DEPDIR)/mdrvrm7-mpenhf.Pf ./$(DEPDIR)/mdrvrm7-mmwcol.Pf ./$(DEPDIR)/mdrvrm7-msfunc.Pf ./$(DEPDIR)/mdrvrm7-mumcol.Pf ./$(DEPDIR)/mdrvrm7-mutcfg.Pf ./$(DEPDIR)/mdrvrm7-mttcol.Pf ./$(DEPDIR)/mdrvrm7-mmsbcg.Pf ./$(DEPDIR)/mdrvrm7-mtfunc.Pf ./$(DEPDIR)/mdrvrm7-muvcio.Pf ./$(DEPDIR)/mdrvrm7-mmheud.Pf ./$(DEPDIR)/mdrvrm7-msbmos.Pf ./$(DEPDIR)/mdrvrm7-mbscol.Pf ./$(DEPDIR)/mdrvrm7-mprtft.Pf ./$(DEPDIR)/mdrvrm7-mmcipc.Pf ./$(DEPDIR)/mdrvrm7-mppmth.Pf ./$(DEPDIR)/mdrvrm7-mibakw.Pf ./$(DEPDIR)/mdrvrm8-mdrvrm.Pf ./$(DEPDIR)/mdrvrm8-msnita.Pf ./$(DEPDIR)/mdrvrm8-mslbcg.Pf ./$(DEPDIR)/mdrvrm8-mifunc.Pf ./$(DEPDIR)/mdrvrm8-mmxoms.Pf ./$(DEPDIR)/mdrvrm8-mglcol.Pf ./$(DEPDIR)/mdrvrm8-mpenhf.Pf ./$(DEPDIR)/mdrvrm8-mmwcol.Pf ./$(DEPDIR)/mdrvrm8-msfunc.Pf ./$(DEPDIR)/mdrvrm8-mumcol.Pf ./$(DEPDIR)/mdrvrm8-mutcfg.Pf ./$(DEPDIR)/mdrvrm8-mttcol.Pf ./$(DEPDIR)/mdrvrm8-mmsbcg.Pf ./$(DEPDIR)/mdrvrm8-mtfunc.Pf ./$(DEPDIR)/mdrvrm8-muvcio.Pf ./$(DEPDIR)/mdrvrm8-mmheud.Pf ./$(DEPDIR)/mdrvrm8-msbmos.Pf ./$(DEPDIR)/mdrvrm8-mbscol.Pf ./$(DEPDIR)/mdrvrm8-mprtft.Pf ./$(DEPDIR)/mdrvrm8-mmcipc.Pf ./$(DEPDIR)/mdrvrm8-mppmth.Pf ./$(DEPDIR)/mdrvrm8-mibakw.Pf ./$(DEPDIR)/mglcol-mglcol.Pf ./$(DEPDIR)/mibakw-mibakw.Pf ./$(DEPDIR)/mibakw-mifunc.Pf ./$(DEPDIR)/mibakw-mprtft.Pf ./$(DEPDIR)/mibakw-mpenhf.Pf ./$(DEPDIR)/mibakw-mppmth.Pf ./$(DEPDIR)/mifunc1-mifunc.Pf ./$(DEPDIR)/mifunc1-mprtft.Pf ./$(DEPDIR)/mifunc1-mpenhf.Pf ./$(DEPDIR)/mifunc1-mppmth.Pf ./$(DEPDIR)/mmcipc-mmcipc.Pf ./$(DEPDIR)/mmheud-mifunc.Pf ./$(DEPDIR)/mmheud-mmxoms.Pf ./$(DEPDIR)/mmheud-mpenhf.Pf ./$(DEPDIR)/mmheud-muvcio.Pf ./$(DEPDIR)/mmheud-mmheud.Pf ./$(DEPDIR)/mmheud-mprtft.Pf ./$(DEPDIR)/mmheud-mppmth.Pf ./$(DEPDIR)/mmheud-mibakw.Pf ./$(DEPDIR)/mmsbcg-mmsbcg.Pf ./$(DEPDIR)/mmsbcg-mifunc.Pf ./$(DEPDIR)/mmsbcg-mmxoms.Pf ./$(DEPDIR)/mmsbcg-mpenhf.Pf ./$(DEPDIR)/mmsbcg-muvcio.Pf ./$(DEPDIR)/mmsbcg-mmheud.Pf ./$(DEPDIR)/mmsbcg-mprtft.Pf ./$(DEPDIR)/mmsbcg-mppmth.Pf ./$(DEPDIR)/mmsbcg-mibakw.Pf ./$(DEPDIR)/mmwcol-mmwcol.Pf ./$(DEPDIR)/mmwcol-mifunc.Pf ./$(DEPDIR)/mmwcol-mmxoms.Pf ./$(DEPDIR)/mmwcol-mpenhf.Pf ./$(DEPDIR)/mmwcol-muvcio.Pf ./$(DEPDIR)/mmwcol-mmheud.Pf ./$(DEPDIR)/mmwcol-mprtft.Pf ./$(DEPDIR)/mmwcol-mppmth.Pf ./$(DEPDIR)/mmwcol-mibakw.Pf ./$(DEPDIR)/mmxoms-mifunc.Pf ./$(DEPDIR)/mmxoms-mmxoms.Pf ./$(DEPDIR)/mmxoms-mpenhf.Pf ./$(DEPDIR)/mmxoms-muvcio.Pf ./$(DEPDIR)/mmxoms-mmheud.Pf ./$(DEPDIR)/mmxoms-mprtft.Pf ./$(DEPDIR)/mmxoms-mppmth.Pf ./$(DEPDIR)/mmxoms-mibakw.Pf ./$(DEPDIR)/msbmos-msbmos.Pf ./$(DEPDIR)/msbmos-mifunc.Pf ./$(DEPDIR)/msbmos-mpenhf.Pf ./$(DEPDIR)/msbmos-msfunc.Pf ./$(DEPDIR)/msbmos-mutcfg.Pf ./$(DEPDIR)/msbmos-mprtft.Pf ./$(DEPDIR)/msbmos-mppmth.Pf ./$(DEPDIR)/msbmos-mibakw.Pf ./$(DEPDIR)/mscpli-mscpli.Pf ./$(DEPDIR)/mscpli-msnita.Pf ./$(DEPDIR)/mscpli-mslbcg.Pf ./$(DEPDIR)/mscpli-mifunc.Pf ./$(DEPDIR)/mscpli-mmxoms.Pf ./$(DEPDIR)/mscpli-mglcol.Pf ./$(DEPDIR)/mscpli-mpenhf.Pf ./$(DEPDIR)/mscpli-msfunc.Pf ./$(DEPDIR)/mscpli-mutcfg.Pf ./$(DEPDIR)/mscpli-muvcio.Pf ./$(DEPDIR)/mscpli-mmheud.Pf ./$(DEPDIR)/mscpli-msbmos.Pf ./$(DEPDIR)/mscpli-mprtft.Pf ./$(DEPDIR)/mscpli-mppmth.Pf ./$(DEPDIR)/mscpli-mibakw.Pf ./$(DEPDIR)/mslbcg-mslbcg.Pf ./$(DEPDIR)/mslbcg-mifunc.Pf ./$(DEPDIR)/mslbcg-mpenhf.Pf ./$(DEPDIR)/mslbcg-msfunc.Pf ./$(DEPDIR)/mslbcg-mutcfg.Pf ./$(DEPDIR)/mslbcg-msbmos.Pf ./$(DEPDIR)/mslbcg-mprtft.Pf ./$(DEPDIR)/mslbcg-mppmth.Pf ./$(DEPDIR)/mslbcg-mibakw.Pf ./$(DEPDIR)/msnita-msnita.Pf ./$(DEPDIR)/msnita-mslbcg.Pf ./$(DEPDIR)/msnita-mifunc.Pf ./$(DEPDIR)/msnita-mmxoms.Pf ./$(DEPDIR)/msnita-mglcol.Pf ./$(DEPDIR)/msnita-mpenhf.Pf ./$(DEPDIR)/msnita-msfunc.Pf ./$(DEPDIR)/msnita-mutcfg.Pf ./$(DEPDIR)/msnita-muvcio.Pf ./$(DEPDIR)/msnita-mmheud.Pf ./$(DEPDIR)/msnita-msbmos.Pf ./$(DEPDIR)/msnita-mprtft.Pf ./$(DEPDIR)/msnita-mppmth.Pf ./$(DEPDIR)/msnita-mibakw.Pf ./$(DEPDIR)/mtfunc-mtfunc.Pf ./$(DEPDIR)/mttcol-mttcol.Pf ./$(DEPDIR)/mttcol-mtfunc.Pf ./$(DEPDIR)/mttcol-mppmth.Pf ./$(DEPDIR)/mttcol-mumcol.Pf ./$(DEPDIR)/mumcol-mumcol.Pf ./$(DEPDIR)/mutcfg-mutcfg.Pf ./$(DEPDIR)/mutcfg-mifunc.Pf ./$(DEPDIR)/mutcfg-mprtft.Pf ./$(DEPDIR)/mutcfg-mpenhf.Pf ./$(DEPDIR)/mutcfg-msfunc.Pf ./$(DEPDIR)/mutcfg-mppmth.Pf ./$(DEPDIR)/muvcio-muvcio.Pf
LCLCNDH = $(builddir)/lclcnd.h
MAINTAINERCLEANFILES += $(LCLDNDH)
#### DEP-DIR
LIB_DEPEND_BASE = src
LIB_DEPEND_NAME = libicies_local.la
LDADD = $(top_builddir)/src/arpeggio/libicies_local.la $(top_builddir)/src/development/libicies_local.la $(top_builddir)/src/unison/libicies_local.la
FORTRAN_CHECK_ADD = $(top_builddir)/src/arpeggio/gather_libicies_local_la.f $(top_builddir)/src/development/gather_libicies_local_la.f $(top_builddir)/src/unison/gather_libicies_local_la.f
#### END DEP-DIR
