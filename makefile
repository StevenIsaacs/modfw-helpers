#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# helpers - A set of helper scripts and utilities designed to be used by
# other projects.
#----------------------------------------------------------------------------
DefaultGoal = help
VERBOSE=1

include macros.mk

$(eval $(call set-segment-context,1))

ifneq ($(findstring test,$(Goals)),)
$(call add-message,Running macro tests.)
include test/test-macros.mk
$(call add-message,Macro tests complete.)
$(call add-message,Testing include of same file.)
include test/test-macros.mk
endif

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
