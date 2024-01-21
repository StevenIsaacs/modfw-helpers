#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# <purpose for this test suite segment>
#----------------------------------------------------------------------------
# +++++
$(call Last-Segment-UN)
ifndef ${LastSegUN}.SegID
$(call Enter-Segment,<purpose for this test suite segment>.)
# -----

$(call Declare-Suite,${Seg},<description>)

${.SuiteN}.Prereqs :=

# Define the tests in the order in which they should be run.

$(call Declare-Test,<test>)
define _help
${.TestUN}
  Verify the macro:$(call Get-Test-Name,${.TestUN})
endef
help-${.TestUN} := $(call _help)
${.TestUN}.Prereqs :=
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(call Test-Info,Running test:${.TestUN})

  $(call End-Test)
  $(call Exit-Macro)
endef

# +++++
# Postamble
# Define help only if needed.
__h := \
  $(or \
    $(call Is-Goal,help-${Seg}),\
    $(call Is-Goal,help-${SegUN}),\
    $(call Is-Goal,help-${SegID}))
ifneq (${__h},)
define __help
Make test suite: ${Seg}.mk

<make test suite help messages>

Tests:
$(foreach __t,${${.SuiteN}.TestL},
${help-${__t}})

Command line goals:
  help-${Seg} or help-${SegUN} or help-${SegID}
    Display this help.
endef
${__h} := ${__help}
endif # help goal message.

$(call End-Declare-Suite)

$(call Exit-Segment)
else # <u>SegID exists
$(call Check-Segment-Conflicts)
endif # <u>SegID
# -----
