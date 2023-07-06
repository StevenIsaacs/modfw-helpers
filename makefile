#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# helpers - A set of helper scripts and utilities designed to be used by
# other projects.
#----------------------------------------------------------------------------
DefaultGoal = help
VERBOSE=1

include macros.mk

ifneq ($(findstring test,$(Goals)),)
include test/test-macros.mk
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
