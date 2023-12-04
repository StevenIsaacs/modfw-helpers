#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Verify the helper macros for expecting values and results.
#----------------------------------------------------------------------------
# The prefix $(call Last-Segment-Basename) must be unique for all files.
# +++++
# Preamble
ifndef $(call Last-Segment-Basename).SegId
$(call Enter-Segment)
# -----

$(call Begin-Suite,${Seg},Verify the variable related helper macros.)

# Define the tests in the order in which they should be run.

$(call Declare-Test,Expect-Vars)
define _help
${TestN}
  Verify Expect-Vars for both passing and failing.
endef
help-${TestN} := $(call _help)
${TestN}.Prereqs := ${SuiteN}.Set-Expected-Results
define ${TestN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(eval _v1 := 1)
  $(eval _v2 := 2)
  $(eval _v3 := 3)
  $(call Expect-Vars,_v1:1 _v2:2 _v3:3)

  $(eval _v1 := abc)
  $(eval _v2 := Def)
  $(eval _v3 := GhIJKlmnop)
  $(call Expect-Vars,_v1:abc _v2:Def _v3:GhIJKlmnop)

  $(call Set-Expected-Results,PASS PASS FAIL)
  $(call Expect-Vars,_v1:abc _v2:Def _v3:X)

  $(call Set-Expected-Results,PASS FAIL PASS)
  $(call Expect-Vars,_v1:abc _v2:def _v3:GhIJKlmnop)

  $(call End-Test)
  $(call Exit-Macro)
endef

$(call Declare-Test,Set-Expected-Results)
define _help
${TestN}
  Verify a list of expected results will produce the correct test results.
endef
help-${TestN} := $(call _help)
${TestN}.Prereqs :=
define ${TestN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(call Set-Expected-Results,PASS)
  $(call Debug,ExpectedResultsL:${ExpectedResultsL})
  $(call PASS,This should PASS:PASS.)
  $(if ${ExpectedResultsL},
    $(call FAIL,ExpectedResultsL should be empty.)
  ,
    $(call PASS,ExpectedResultsL is empty.)
  )
  $(call Debug,ExpectedResultsL:${ExpectedResultsL})
  $(call PASS,This should not call Verify-Result.)

  $(call Set-Expected-Results,FAIL)
  $(call Debug,ExpectedResultsL:${ExpectedResultsL})
  $(call FAIL,This should PASS:FAIL.)
  $(call Debug,ExpectedResultsL:${ExpectedResultsL})
  $(call PASS,This should not call Verify-Result.)
  $(call Debug,ExpectedResultsL:${ExpectedResultsL})

  $(call Set-Expected-Results,PASS PASS FAIL PASS FAIL)
  $(call Debug,ExpectedResultsL:${ExpectedResultsL})
  $(call PASS,This should PASS:PASS.)
  $(call Debug,ExpectedResultsL:${ExpectedResultsL})
  $(call FAIL,This should FAIL:PASS.)
  $(call Debug,ExpectedResultsL:${ExpectedResultsL})
  $(call FAIL,This should PASS:FAIL.)
  $(call Debug,ExpectedResultsL:${ExpectedResultsL})
  $(call FAIL,This should FAIL:PASS.)
  $(call Debug,ExpectedResultsL:${ExpectedResultsL})
  $(call FAIL,This should PASS:FAIL.)
  $(call Debug,ExpectedResultsL:${ExpectedResultsL})
  $(if ${ExpectedResultsL},
    $(call FAIL,ExpectedResultsL should be empty.)
  ,
    $(call PASS,ExpectedResultsL is empty.)
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

This test suite verifies the variety of expect macros.

Verifies these macros:
${help-Expect-Vars}

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
