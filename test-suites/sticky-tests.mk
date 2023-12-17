#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Test the macros and variables related to Sticky variables.
#----------------------------------------------------------------------------
# The prefix $(call Last-Segment-Basename) must be unique for all files.
# +++++
# Preamble
ifndef $(call Last-Segment-Basename).SegID
$(call Enter-Segment)
# -----

$(call Declare-Suite,${Seg},Verify the Sticky variable macros.)

${.SuiteN}.Prereqs :=

# Define the tests in the order in which they should be run.

$(call Declare-Test,Sticky)
define _help
${.TestUN}
  Verify the macro:${.TestUN}
  This verifies the logic of sticky variables (see help-Sticky).
  Three sticky variables should already exist by the time this macro is
  called. They are:
  CASES
  SUITES
  SUITES_PATH
  These are first verified to have correct values.
endef
help-${.TestUN} := $(call _help)
${.TestUN}.Prereqs :=
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))
  $(call Test-Info,Running test:${.TestUN})

  $(call Test-Info,Verifying existing sticky variables.)
  $(foreach _vn,CASES SUITES_PATH,
    $(eval _tmp := $(file <${STICKY_PATH}/${_vn}))
    $(call Test-Info,Verifying ${_vn} equals ${${_vn}}.)
    $(if $(filter ${_tmp},${${_vn}}),
      $(call PASS,${_vn} has correct value.)
    ,
      $(call FAIL,${_vn} has incorrect sticky value:${_tmp})
    )
  )

  $(call End-Test)
  $(call Exit-Macro)
endef

$(call Declare-Test,Get-Sticky)
define _help
${.TestUN}
  Verify the macro:${.TestUN}

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

$(call Declare-Test,Redefine-Sticky)
define _help
${.TestUN}
  Verify the macro:${.TestUN}

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

$(call Declare-Test,Remove-Sticky)
define _help
${.TestUN}
  Verify the macro:${.TestUN}

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

$(call End-Declare-Suite)

# +++++
# Postamble
# Define help only if needed.
#ifneq ($(call Is-Goal,help-${Seg}),)
define help-${Seg}
Make test suite: ${Seg}.mk

Verify the macros and variables used for maintaining sticky variables.

Command line goals:
  help-${Seg}
    Display this help.
  show-${Seg}.TestL
    Display the list of tests included in this suite.
endef
#endif # help goal message.

$(call Exit-Segment)
else # <u>SegID exists
$(call Check-Segment-Conflicts)
endif # <u>SegID
# -----
