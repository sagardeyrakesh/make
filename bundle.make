#
#   bundle.make
#
#   Makefile rules to build GNUstep-based bundles.
#
#   Copyright (C) 1997 Free Software Foundation, Inc.
#
#   Author:  Scott Christley <scottc@net-community.com>
#   Author:  Ovidiu Predescu <ovidiu@net-community.com>
#
#   This file is part of the GNUstep Makefile Package.
#
#   This library is free software; you can redistribute it and/or
#   modify it under the terms of the GNU General Public License
#   as published by the Free Software Foundation; either version 2
#   of the License, or (at your option) any later version.
#   
#   You should have received a copy of the GNU General Public
#   License along with this library; see the file COPYING.LIB.
#   If not, write to the Free Software Foundation,
#   59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

# prevent multiple inclusions
ifeq ($(BUNDLE_MAKE_LOADED),)
BUNDLE_MAKE_LOADED=yes

#
# Include in the common makefile rules
#
include $(GNUSTEP_SYSTEM_ROOT)/Makefiles/rules.make

# The name of the bundle is in the BUNDLE_NAME variable.
# The list of bundle resource file are in xxx_RESOURCES
# The list of bundle resource directories are in xxx_RESOURCE_DIRS
# where xxx is the bundle name
#

ifeq ($(INTERNAL_bundle_NAME),)
# This part is included the first time make is invoked.

internal-all:: $(BUNDLE_NAME:=.all.bundle.variables)

internal-install:: all $(BUNDLE_NAME:=.install.bundle.variables)

internal-uninstall:: $(BUNDLE_NAME:=.uninstall.bundle.variables)

internal-clean:: $(BUNDLE_NAME:=.clean.bundle.variables)

internal-distclean:: $(BUNDLE_NAME:=.distclean.bundle.variables)

$(BUNDLE_NAME):
	@$(MAKE) -f $(MAKEFILE_NAME) --no-print-directory \
		$@.all.bundle.variables

else
# This part gets included the second time make is invoked.

# On Solaris we don't need to specifies the libraries the bundle needs.
# How about the rest of the systems? ALL_BUNDLE_LIBS is temporary empty.
#ALL_BUNDLE_LIBS = $(ADDITIONAL_GUI_LIBS) $(AUXILIARY_GUI_LIBS) $(BACKEND_LIBS) \
   $(GUI_LIBS) $(ADDITIONAL_TOOL_LIBS) $(AUXILIARY_TOOL_LIBS) \
   $(FND_LIBS) $(ADDITIONAL_OBJC_LIBS) $(AUXILIARY_OBJC_LIBS) $(OBJC_LIBS) \
   $(SYSTEM_LIBS) $(TARGET_SYSTEM_LIBS)

#ALL_BUNDLE_LIBS := \
    $(shell $(WHICH_LIB_SCRIPT) $(LIB_DIRS_NO_SYSTEM) $(ALL_BUNDLE_LIBS) \
	debug=$(debug) profile=$(profile) shared=$(shared) libext=$(LIBEXT) \
	shared_libext=$(SHARED_LIBEXT))

internal-bundle-all:: before-$(TARGET)-all $(GNUSTEP_OBJ_DIR) \
		build-bundle-dir build-bundle \
		after-$(TARGET)-all

before-$(TARGET)-all::

after-$(TARGET)-all::

BUNDLE_DIR_NAME := $(INTERNAL_bundle_NAME:=$(BUNDLE_EXTENSION))
BUNDLE_FILE := \
    $(BUNDLE_DIR_NAME)/$(GNUSTEP_TARGET_DIR)/$(LIBRARY_COMBO)/$(BUNDLE_NAME)
BUNDLE_RESOURCE_DIRS = $(foreach d, $(RESOURCE_DIRS), $(BUNDLE_DIR_NAME)/$(d))

build-bundle-dir::
	@$(GNUSTEP_MAKEFILES)/mkinstalldirs \
		$(BUNDLE_DIR_NAME)/Resources \
		$(BUNDLE_DIR_NAME)/$(GNUSTEP_TARGET_DIR)/$(LIBRARY_COMBO) \
		$(BUNDLE_RESOURCE_DIRS)

build-bundle:: $(BUNDLE_FILE) bundle-resource-files

$(BUNDLE_FILE) : $(C_OBJ_FILES) $(OBJC_OBJ_FILES)
	$(BUNDLE_LD) $(BUNDLE_LDFLAGS) $(ALL_LDFLAGS) \
		$(LDOUT)$(BUNDLE_FILE) \
		$(C_OBJ_FILES) $(OBJC_OBJ_FILES) \
		$(ALL_LIB_DIRS) $(ALL_BUNDLE_LIBS)

bundle-resource-files:: $(BUNDLE_DIR_NAME)/Resources/Info-gnustep.plist
	@(if [ "$(RESOURCE_FILES)" != "" ]; then \
	  echo "Copying resources into the bundle wrapper..."; \
	  cp -r $(RESOURCE_FILES) $(BUNDLE_DIR_NAME)/Resources; \
	fi)


$(BUNDLE_DIR_NAME)/Resources/Info-gnustep.plist: $(BUNDLE_DIR_NAME)/Resources
	@(echo "{"; echo '  NOTE = "Automatically generated, do not edit!";'; \
	  echo "  NSExecutable = $(INTERNAL_bundle_NAME);"; \
	  if [ "$(MAIN_MODEL_FILE)" = "" ]; then \
	    echo "  NSMainNibFile = \"\";"; \
	  else \
	    echo "  NSMainNibFile = `echo $(MAIN_MODEL_FILE) | sed 's/.gmodel//'`;"; \
	  fi; \
	  echo "  NSPrincipalClass = $(INTERNAL_bundle_NAME);"; \
	  echo "}") >$@

internal-bundle-install:: $(BUNDLE_INSTALL_DIR)
	rm -rf $(BUNDLE_INSTALL_DIR)/$(BUNDLE_DIR_NAME)
	tar cf - $(BUNDLE_DIR_NAME) | (cd $(BUNDLE_INSTALL_DIR); tar xf -)

$(BUNDLE_DIR_NAME)/Resources $(BUNDLE_INSTALL_DIR)::
	@$(GNUSTEP_MAKEFILES)/mkinstalldirs $@

internal-bundle-uninstall::
	rm -rf $(BUNDLE_INSTALL_DIR)/$(BUNDLE_DIR_NAME)

#
# Cleaning targets
#
internal-bundle-clean::
	rm -rf $(GNUSTEP_OBJ_DIR)

internal-bundle-distclean::
	rm -rf shared_obj static_obj shared_debug_obj shared_profile_obj \
	  static_debug_obj static_profile_obj shared_profile_debug_obj \
	  static_profile_debug_obj

endif

endif
# bundle.make loaded
