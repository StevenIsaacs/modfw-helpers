#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# helpers - A set of helper scripts and utilities designed to be used by
# other projects.
#----------------------------------------------------------------------------
VERBOSE=1
DEBUG=1

include helpers.mk

$(call Add-Message,ProjectPath: ${ProjectPath})
$(call Add-Message,ProjectName: ${ProjectName})

$(call Add-Segment-Path,test/d1 test/d2 test/d3)

ifneq ($(findstring test,$(Goals)),)
$(call Add-Message,Running helpers tests.)
$(call Add-Message,helpersSegId: ${helpersSegId})
$(call Use-Segment,test/test-helpers)
$(call Add-Message,Macro tests complete.)
$(call Add-Message,Testing include of same file.)
# Test detection of including same file.
$(call Use-Segment,test/test-helpers)
# Test detection of prefix conflict between different files.
$(call Use-Segment,test/test-conflict)
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
endef

export _HelpersUsage
help:
> @echo "$$_HelpersUsage" | less

endif
