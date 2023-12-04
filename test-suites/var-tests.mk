#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Verify the helper macros for manipulating variables.
#----------------------------------------------------------------------------
# The prefix $(call Last-Segment-Basename) must be unique for all files.
# +++++
# Preamble
ifndef $(call Last-Segment-Basename).SegId
$(call Enter-Segment)
# -----

$(call Begin-Suite,${Seg},Verify the variable related helper macros.)

# Define the tests in the order in which they should be run.

$(call Declare-Test,Inc-Var)
define _help
${TestN}
  Verify the helper macro:${TestN}
endef
help-${TestN} := $(call _help)
${TestN}.Prereqs := expect-tests.Expect-Vars
define ${TestN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(call Test-Info,Running test:${TestN})
  $(eval _v := 0)
  $(foreach _e,0 1 2,
    $(call Expect-Vars,_v:${_e})
    $(call Inc-Var,_v)
  )

  $(call End-Test)
  $(call Exit-Macro)
endef

$(call Declare-Test,Dec-Var)
define _help
${TestN}
  Verify the helper macro:${TestN}
endef
help-${TestN} := $(call _help)
${TestN}.Prereqs := expect-tests.Expect-Vars
define ${TestN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(call Test-Info,Running test:${TestN})
  $(eval _v := 2)
  $(foreach _e,2 1 0,
    $(call Expect-Vars,_v:${_e})
    $(call Dec-Var,_v)
  )

  $(call End-Test)
  $(call Exit-Macro)
endef

$(call End-Suite)

# +++++
# Postamble
# Define help only if needed.
#ifneq ($(call Is-Goal,help-${Seg}),)
define _help
Make test suite: ${Seg}.mk

<make test suite help messages>

Command line goals:
  help-${Seg}
    Display this help.
  show-${Seg}.TestL
    Display the list of tests included in this suite.
endef
help-${Seg} := $(call _help)

#endif # help goal message.

$(call Exit-Segment)
else # <u>SegId exists
$(call Check-Segment-Conflicts)
endif # <u>SegId
# -----
