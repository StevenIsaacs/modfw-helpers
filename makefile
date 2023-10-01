#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# helpers - A set of helper scripts and utilities designed to be used by
# other projects.
#----------------------------------------------------------------------------
#VERBOSE=1
#DEBUG=1

include helpers.mk

$(call Info,WorkingPath: ${WorkingPath})
$(call Info,WorkingVar: ${WorkingVar})

$(call Add-Segment-Path,test/d1 test/d2 test/d3)

ifneq ($(findstring test,$(Goals)),)
$(call Info,Running helpers tests.)
$(call Info,helpersSegId: ${helpersSegId})
$(call Add-Segment-Path,test)
$(call Use-Segment,test-helpers)
$(call Info,Macro tests complete.)
$(call Info,Testing include of same file.)
# Test detection of including same file. This uses the path rather than
# relying upon the search path.
$(call Use-Segment,${helpersSegP}/test/test-helpers.mk)
# Test detection of prefix conflict between different files.
$(call Use-Segment,test-conflict)
# Test sub-make.
$(info MAKELEVEL = ${MAKELEVEL})
$(info Filtered: $(filter 0,${MAKELEVEL}))
ifneq (${MAKELEVEL},0)
  $(call test-message,Running in sub-make.)
endif
endif # Test

$(call Resolve-Help-Goals)

ifneq ($(filter help,$(Goals)),)
define _HelpersUsage
Usage: make [<option>=<value> ...] [<goal>]

NOTE: This help is displayed if no goal is specified.

This make file is used to build and/or test helper functions, scripts and,
utilities.

Goals:
    test-helpers
        Test the helper macros.
    test-conflicts
        Test ID conflicts among segments. This is also executed by
        test-helpers.

endef

export _HelpersUsage
help:
> @echo "$$_HelpersUsage" | less

endif
