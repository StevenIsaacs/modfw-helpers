#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# <purpose for this test suite segment>
#----------------------------------------------------------------------------
# The prefix $(call Last-Segment-Basename) must be unique for all files.
# +++++
# Preamble
ifndef $(call Last-Segment-Basename).SegId
$(call Enter-Segment)
# -----

$(call Begin-Suite,${Seg},<description>)

${SuiteN}.Prereqs :=

# Define the tests in the order in which they should be run.

$(call Declare-Test,Inc-Var)
define _help
${TestN}
  Verify the macro:${TestN}
endef
help-${TestN} := $(call _help)
$(call Declare-Test,${TestN})
${TestN}.Prereqs :=
define ${TestN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(call Test-Info,Running test:${TestN})

  $(call End-Test)
  $(call Exit-Macro)
endef

$(call End-Suite)

# +++++
# Postamble
# Define help only if needed.
#ifneq ($(call Is-Goal,help-${Seg}),)
define help-${Seg}
Make test suite: ${Seg}.mk

<make test suite help messages>

Command line goals:
  help-${Seg}
    Display this help.
  show-${Seg}.TestL
    Display the list of tests included in this suite.
endef
#endif # help goal message.

$(call Exit-Segment)
else # <u>SegId exists
$(call Check-Segment-Conflicts)
endif # <u>SegId
# -----
