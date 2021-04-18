# Makefile.tmpl - IcIES root Makefile.am template
# Maintainer:  SAITO Fuyuki
# Created: Nov 2 2011
# Revision:  JosePeterson0
# Time-stamp: <2021/04/19 08:24:22 fuyuki Makefile.tmpl>

# Copyright: 2011-2021 JAMSTEC, Ayako ABE-OUCHI
# Licensed under the Apache License, Version 2.0
#   (https://www.apache.org/licenses/LICENSE-2.0)

ACLOCAL_AMFLAGS = -I build-aux/m4

BUILD_AUX	  = build-aux
SUBDIRS       = src run ##%% t
DIST_SUBDIRS  = $(SUBDIRS) etc doc
TREEID		  = TreeID
REVISION_CACHE	=	autorevision.cache
DOC_DIST      = INSTALL-icies2 NOTICE LICENSE HOWTORUN
EXTRA_DIST    = $(TREEID) $(REVISION_CACHE) $(BUILD_AUX) $(DOC_DIST) ##%% a

IDGEN		=	$(BUILD_AUX)/icies/idgen
RUN_IDGEN	=	$(top_srcdir)/$(IDGEN)
GIT			=	@GIT@
RUN_GIT		=	cd $(top_srcdir); $(GIT)
COMMIT		=	HEAD
SHA			=	$(RUN_GIT) rev-parse --short $(COMMIT)
DIST_ID		=	`$(SHA)`

STATUS_COUNT_M	=	`($(RUN_GIT) status -s --porcelain) | grep -c '^ M'`

DIST_SFX		=
DIST_DIR_GIT	=	$(PACKAGE)-$(VERSION)_$(DIST_ID)$(DIST_SFX)

SP_DIST_HOOK	=
# force nullify
LCLCNDH	= ##%% t
# distdir	=	$(PACKAGE)-$(VERSION)_$(DIST_ID)

install-etc:
	@cd etc; $(MAKE) $(AM_MAKEFLAGS) install

install-run:
	@cd run; $(MAKE) $(AM_MAKEFLAGS) install

install-cadenza: install-etc
	@cd src; $(MAKE) $(AM_MAKEFLAGS) $@

dist-git-full: dist-git dist-git-ign

dist-git-batch:
	$(MAKE) $(AM_MAKEFLAGS) distdir=$(DIST_DIR_GIT) DIST_SFX=$(DIST_SFX) dist
	$(MAKE) $(AM_MAKEFLAGS) distdir=$(DIST_DIR_GIT) DIST_SFX=$(DIST_SFX) show-distdir

dist-git-force:
	$(MAKE) $(AM_MAKEFLAGS) dist-git-batch DIST_SFX="+f"

dist-git-mod:
	@msfx=''; \
	modf=$(STATUS_COUNT_M); \
	test $$modf -gt 0 && msfx="+m$$modf"; \
	$(MAKE) $(AM_MAKEFLAGS) dist-git-batch DIST_SFX="$$msfx"

dist-git-head:
	$(MAKE) $(AM_MAKEFLAGS) dist-git-batch SP_DIST_HOOK=dist-git-head-hook COMMIT=$(COMMIT) DIST_SFX="+h"

dist-git:
	@if test $(STATUS_COUNT_M) = 0; then \
		$(MAKE) $(AM_MAKEFLAGS) dist-git-batch;\
	else \
		echo "RESOURCES ARE NOT CLEAN."; \
		( $(RUN_GIT) status ); \
		echo "Alternative targets: dist-git-force dist-git-head dist-git-mod"; \
		echo "or try $(srcdir)/$(BUILD_AUX)/icies/dist-rev"; \
	fi

dist-git-ign:
	@$(srcdir)/$(BUILD_AUX)/icies/dist-ignored $(builddir) $(srcdir) $(DIST_DIR_GIT)
	$(MAKE) $(AM_MAKEFLAGS) distdir=$(DIST_DIR_GIT) show-distdir-git

dist-hook: $(SP_DIST_HOOK)

dist-git-head-hook:
	@files=`($(RUN_GIT) status -s --porcelain) | sed -n -e '/^ M/s///p'`; \
	for f in $$files; do \
		if test -e $(distdir)/$$f; then \
			echo "Revert $$f to $(COMMIT)"; \
			git show $(COMMIT):$$f > $(distdir)/$$f; \
		fi; done

show-distdir:
	@echo $(distdir)

show-distdir-git:
	$(MAKE) $(AM_MAKEFLAGS) distdir=$(DIST_DIR_GIT) show-distdir

show-archives:
	@echo $(DIST_ARCHIVES)

show-archives-git:
	$(MAKE) $(AM_MAKEFLAGS) distdir=$(DIST_DIR_GIT) show-archives

$(TREEID):
	$(RUN_IDGEN) $@

$(REVISION_CACHE):
	echo "# dummy" > $@

### Local Variables:
### mode: makefile-automake
### end:
#### End of template
#### COMMON
F77PREPROCESS = $(CPP) $(DEFS) $(DEFAULT_INCLUDES) $(INCLUDES) $(AM_CPPFLAGS) $(CPPFLAGS)
STANDARD_CPPFLAGS = -I$(OSTINATO_build) -I$(top_srcdir) -I$(OSTINATO_src)
AM_CPPFLAGS = $(STANDARD_CPPFLAGS) $(XPKG_CPPFLAGS)
AM_LDFLAGS = $(STANDARD_LDFLAGS)  $(XPKG_LDFLAGS)
auto_SUBDIRS_auto = .
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
am__depfiles_remade = 
#### DEP-DIR
LIB_DEPEND_BASE = src
LIB_DEPEND_NAME = libicies_local.la
#### END DEP-DIR
