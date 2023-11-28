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

_test := ${SuiteN}.<test-name>
define _help
${_test}
  Test specific help message.
endef
help-${_test} := $(call _help)
$(call Add-Test-To-Suite,${_test})
${_test}.Prereqs :=
define ${_test}
$(call Enter-Macro,$(0))
$(call Begin-Test,$(0))

<test body here>

$(call End-Test)
$(call Exit-Macro)
endef

# The test suite goal to be specified in order to run the suite.
${SuiteN}:

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
