#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Test the helpers.
#----------------------------------------------------------------------------
#VERBOSE=1
#DEBUG=1

TmpTestPath := /tmp/test-helpers
LOG_PATH := ${TmpTestPath}/log

STICKY_PATH := ${TmpTestPath}/sticky

MakeD := Run the test suites to test the helpers.

include helpers.mk

$(call Info,WorkingPath: ${WorkingPath})
$(call Info,WorkingVar: ${WorkingVar})

$(call Use-Segment,test-helpers)

$(call Run-Suites,${SUITES_PATH},${CASES})

$(call Display-Segs)

clean:
> rm -rf ${TmpTestPath}

__h := $(or \
  $(call Is-Goal,help-${SegUN}), \
  $(call Is-Goal,help-${SegID}))
ifneq (${__h},)
$(call Attention,Defining ${__h} for:${Seg})
define __help
Makefile: ${Seg}
Usage: make [<option>=<value> ...] [<goal> [<goal> ...]]

NOTE: This help is displayed if no goal is specified.

This make file is used to run test suites for testing the helpers and the
test helpers.

The sticky variable CASES defines which tests are run. See help-CASES for more
information.

Use the test goal. See help-test-helpers for more information.

endef
${__h} := ${__help}
endif
$(call Resolve-Help-Goals)
