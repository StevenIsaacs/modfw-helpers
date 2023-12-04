#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# helpers - A set of helper scripts and utilities designed to be used by
# other projects.
#----------------------------------------------------------------------------
#VERBOSE=1
#DEBUG=1

include helpers.mk

$(call Info,WorkingPath: ${WorkingPath})
$(call Info,WorkingVar: ${WorkingVar})

$(call Use-Segment,test-helpers)

$(call Run-Suites,${SUITES_PATH},${CASES})

$(call Resolve-Help-Goals)

ifneq ($(filter help,$(Goals)),)
define help-Usage
Usage: make [<option>=<value> ...] [<goal> [<goal> ...]]

NOTE: This help is displayed if no goal is specified.

This make file is used to run test suites for testing the helpers and the
test helpers.

The sticky variable CASES defines which tests are run. See help-CASES for more
information.

Use the test goal. See help-test-helpers for more information.

endef

endif
