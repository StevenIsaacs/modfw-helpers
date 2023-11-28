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

$(call Run-Suites,${SUITES_PATH},${SUITES})

$(call Resolve-Help-Goals)

ifneq ($(filter help,$(Goals)),)
define help-Usage
Usage: make [<option>=<value> ...] [<goal> [<goal> ...]]

NOTE: This help is displayed if no goal is specified.

This make file is used to run test suites for testing the helpers and the
test helpers.

Goals:
    all
      Use this goal to run all of the test suites.
    <suite>
      Run a specific test suite.
    test-helpers
        Test the helper macros.
    test-conflicts
        Test ID conflicts among segments. This is also executed by
        test-helpers.

endef

help: help-Usage

endif
