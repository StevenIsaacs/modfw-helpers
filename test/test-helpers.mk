#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# This make segment is designed to test macros.mk.
#-----------------------------------------------------------------------------
# The prefix $(call Last-Segment-Basename) must be unique for all files.
# +++++
# Preamble
$(call Info,+++++ $(call Last-Segment-Basename) entry. +++++)
ifndef $(call Last-Segment-Basename)SegId
$(call Enter-Segment)
# -----

SuiteID := 0
TestC := 0
PassedC := 0
PassedL :=
FailedC := 0
FailedL :=

define Test-Info
  $(call Info,Suite:${SuiteID}:$(strip $(1)))
endef

define PASS
  $(call Inc-Var,TestC)
  $(call Info,PASS:${TestC}:$(strip $(1)))
  $(call Inc-Var,PassedC)
  $(eval PassedL += ${SuiteID}:${TestC})
endef

define FAIL
  $(call Inc-Var,TestC)
  $(call Signal-Error,FAIL:${TestC}:$(strip $(1)))
  $(call Inc-Var,FailedC)
  $(eval FailedL += ${SuiteID}:${TestC})
endef

define Next-Test
$(call Inc-Var,SuiteID)
$(call Info,$(NewLine))
$(call Test-Info,++++ $(1) ++++)
endef

define Display-Vars
  $(foreach _v,$(1),
    $(call Test-Info,$(_v) = ${$(_v)})
  )
endef

define Expect-Vars
  $(foreach _e,$(1),
    $(eval _ve := $(subst :,${Space},${_e}))
    $(call Debug,Expect-Vars:${_ve} $(word 1,${_ve}) $(word 2,${_ve}))
    $(if $(word 2,${_ve}),
      $(if $(filter ${$(word 1,${_ve})},$(word 2,${_ve})),
        $(call PASS,Expecting:${_e})
      ,
        $(call FAIL,Expecting:(${_e}) = (${$(word 1,${_ve})}))
      )
    ,
      $(if $(strip ${$(word 1,${_ve})}),
        $(call FAIL,Expecting:(${_e}) = (${$(word 1,${_ve})}))
      ,
        $(call PASS,Expecting:${_e})
      )
    )
  )
endef

define Expect-List
  $(eval _i := 0)
  $(eval _ex := )
  $(foreach _w,$(1),
    $(call Inc-Var,_i)
    $(if $(filter ${_w},$(word ${_i},$(2))),
      $(call Debug,Expect-List:${_w} = $(word ${_i},$(2)))
    ,
      $(eval _ex += ${_i})
    )
  )
  $(if ${_ex},
    $(call Test-Info,Expect-List:Lists do not match.)
    $(foreach _i,${_ex},
      $(call FAIL,\
        Expected:$(word ${_i},$(1)) Found:$(word ${_i},$(2)))
    )
  ,
    $(call PASS,Lists match.)
  )
endef

#+
# Display the current context and the context for a segment.
#-
define Report-Seg-Context
  $(call Display-Vars,
    SegId \
    Seg \
    SegV \
    SegP \
    SegF \
    ${Seg}SegId \
    ${Seg}PrvSegId \
    ${Seg}Seg
    ${Seg}SegV \
    ${Seg}SegP \
    ${Seg}SegF \
  )

  $(call Test-Info,\
  Get-Segment-File:SegId:$(call Get-Segment-File,${SegId}))
  $(call Test-Info,\
  Get-Segment-Basename:SegId:$(call Get-Segment-Basename,${SegId}))
  $(call Test-Info,\
  Get-Segment-Var:SegId:$(call Get-Segment-Var,${SegId}))
  $(call Test-Info,\
  Get-Segment-Path:SegId:$(call Get-Segment-Path,${SegId}))

  $(call Test-Info,\
  Get-Segment-File:${Seg}SegId:$(call Get-Segment-File,${${Seg}SegId}))
  $(call Test-Info,\
  Get-Segment-Basename:${Seg}SegId:$(call Get-Segment-Basename,${${Seg}SegId}))
  $(call Test-Info,\
  Get-Segment-Var:${Seg}SegId:$(call Get-Segment-Var,${${Seg}SegId}))
  $(call Test-Info,\
  Get-Segment-Path:${Seg}SegId:$(call Get-Segment-Path,${${Seg}SegId}))

  $(call Test-Info,Last-Segment-Id:$(call Last-Segment-Id))
  $(call Test-Info,Last-Segment-Basename:$(call Last-Segment-Basename))
  $(call Test-Info,Last-Segment-Var:$(call Last-Segment-Var))
  $(call Test-Info,Last-Segment-Path:$(call Last-Segment-Path))
  $(call Test-Info,Last-Segment-File:$(call Last-Segment-File))
  $(call Test-Info,MAKEFILE_LIST:$(MAKEFILE_LIST))
endef

#+
# Display a test summary.
#-
define Report-Test-Summary
  $(call Test-Info,\
    Total tests:${TestC} Total passed:${PassedC} Total failed:${FailedC})
  $(call Test-Info,Passed tests:${PassedL})
  $(call Test-Info,Failed tests:${FailedL})
endef

ifneq ($(call Is-Goal,test-helpers),)
  $(call Test-Info,Testing helpers...)

  $(call Next-Test,Signal-Error callback.)
  define error-handler
    $(call Test-Info,error-handler:$(1))
  endef

  define recursive-error-handler
    $(call Test-Info,recursive-error-handler:$(1))
    $(call Signal-Error,Recursive error.)
  endef
  $(call Signal-Error,No error handler.)
  $(call Set-Error-Handler,error-handler)
  $(call Signal-Error,Error handler installed.)
  $(call Set-Error-Handler,recursive-error-handler)
  $(call Signal-Error,Recursive error handler installed.)
  $(call Set-Error-Handler)
  $(call Signal-Error,Error handler removed.)

  $(call Next-Test,Current context.)
  $(call Report-Seg-Context)

  $(call Next-Test,$(SHELL) HELPER_FUNCTIONS)
  $(call Test-Info,helpersSegId = ${helpersSegId})
  $(call Test-Info,HELPER_FUNCTIONS = ${HELPER_FUNCTIONS})

  $(call Next-Test,Running shell commands.)
  _o := $(call Run,ls test)
  $(call Test-Info,Run output = ${_o})
  _r := $(call Return-Code,${_o})
  $(call Test-Info,Run return code: ${_r})
  $(call Expect-Vars,_r:)
  _o := $(call Run,ls not-exist)
  $(call Test-Info,Run output = ${_o})
  _r := $(call Return-Code,${_o})
  $(call Test-Info,Run return code: ${_r})

  $(call Next-Test,Segment identifiers.)
  $(call Report-Seg-Context)

  $(call Next-Test,Sticky variables.)
  tv1 := tv1_v
  tv2 := tv2_v
  $(call Test-Info,STICKY_PATH = ${STICKY_PATH})
  $(call Test-Info,StickyVars:${StickyVars})
  $(call Sticky,tv1,tv1)
  $(call Verbose,Sticky tv1 = ${tv1})
  $(call Test-Info,StickyVars:${StickyVars})
  $(call Sticky,tv2,tv2)
  $(call Verbose,Sticky tv2 = ${tv2})
  $(call Test-Info,StickyVars:${StickyVars})
  # Should cause redefinition error.
  $(call Sticky,tv2,xxx)
  $(call Verbose,After second Sticky tv2 = ${tv2})
  $(call Test-Info,StickyVars:${StickyVars})
  # Using assignment in call.
  $(call Sticky,tv3=tv3_v)
  # Redefine the previous error variable.
  $(call Redefine-Sticky,tv2=xxx)
  $(call Verbose,After redefined Sticky tv2 = ${tv2})
  $(call Test-Info,StickyVars:${StickyVars})

  $(call Test-Info,StickyVars:Var:<var>=<val>:<saved>)
  $(foreach _v,${StickyVars},\
    $(call Test-Info,Var:${_v} = ${${_v}}:$(shell cat ${STICKY_PATH}/${_v})))

  $(call Next-Test,Expect_Vars)
  v1 := v1_val
  v2 := v2_val
  v3 := v3_val
  v4 := v4_fail

  $(call Expect-Vars,v1:v1_val v2:v2_val v3:v3_val v4:v4_val)

  $(call Next-Test,Expect-List)
  $(call Test-Info,The list being verified can be longer than the expect list.)
  $(call Expect-List,one two three four,one two three four five)
  $(call Test-Info,Same lists.)
  $(call Expect-List,one two three four,one two three four)
  $(call Test-Info,Lists do not match.)
  $(call Expect-List,one two three four,one Two three Four)

  $(call Next-Test,Add-To-Manifest)
  $(call Add-To-Manifest,l1,null,one)
  $(call Test-Info,List: l1=${l1})
  $(call Add-To-Manifest,l1,null,two)
  $(call Test-Info,List: l1=${l1})
  $(call Add-To-Manifest,l2,l2_e1,2.one)
  $(call Test-Info,List: l2=${l2})
  $(call Test-Info,Var: l2_e1=${l2_e1})
  $(call Add-To-Manifest,l2,l2_e2,2.two)
  $(call Test-Info,List: l2=${l2})
  $(call Test-Info,Var: l2_e2=${l2_e1})
  $(call Test-Info,Var: null=${null})

  $(call Next-Test,Signal-Error)
  $(call Signal-Error,Error one.)
  $(info ErrorList: ${ErrorList})
  $(call Signal-Error,Error two.)
  $(info ErrorList: ${ErrorList})
  $(call Signal-Error,Error three.)
  $(info ErrorList: ${ErrorList})
  $(call Signal-Error,Error four.)
  $(info ErrorList: ${ErrorList})
  $(call Signal-Error,Error five.)
  $(info ErrorList: ${ErrorList})
  $(call show-errors)

  $(call Next-Test,Require)
  a := 1
  b := 2
  c := 3
  r := $(call Require,a b c d)
  ifeq (${r},)
    $(call FAIL,Require: Returned an empty string -- should have returned d.)
  else
    ifeq (${r},d)
      $(call PASS,Require: Returned -${r}-.)
    else
      $(call FAIL,Require: Returned -${r}- -- should have been d.)
    endif
  endif
  r := $(call Require,a b c)
  ifeq (${r},)
    $(call PASS,Require: Returned an empty string as it should.)
  else
    $(call FAIL,Require: Returned -${r}- -- should have been empty.)
  endif

  $(call Next-Test,Must-Be-One-Of)
  _pat := 1 2 3
  $(call Test-Info,Must-Be-One-Of:${_pat}: -$(call Must-Be-One-Of,a,${_pat})-)
  ifeq ($(call Must-Be-One-Of,a,${_pat}),)
    $(call FAIL,Is NOT one.)
  else
    $(call PASS,Is one.)
  endif
  _pat := 2 3
  $(call Test-Info,Must-Be-One-Of:${_pat}: -$(call Must-Be-One-Of,a,${_pat})-)
  ifeq ($(call Must-Be-One-Of,a,${_pat}),)
    $(call PASS,Is NOT one.)
  else
    $(call FAIL,Is one.)
  endif
  _pat := 21 3
  $(call Test-Info,Must-Be-One-Of:${_pat}: -$(call Must-Be-One-Of,a,${_pat})-)
  ifeq ($(call Must-Be-One-Of,a,${_pat}),)
    $(call PASS,Is NOT one.)
  else
    $(call FAIL,Is one.)
  endif

  $(call Next-Test,Use-Segment)

  $(call Next-Test,Use-Segment:Segments in the current directory.)
  $(call Use-Segment,ts1)
  $(call Use-Segment,ts2)
  $(call Next-Test,Use-Segment:Segments in subdirectories.)
  $(call Use-Segment,td1)
  $(call Use-Segment,td2)
  $(call Use-Segment,td3)
  $(call Next-Test,Use-Segment:Multiple segments of the same name.)
  $(call Use-Segment,tm1)
  $(call Use-Segment,test/d2/tm1)
  $(call Next-Test,Use-Segment:A segment in a subdirectory.)
  $(call Use-Segment,sd3/tsd3)
  $(call Next-Test,Use-Segment:Does not exist.)
  $(call Use-Segment,te1)
  $(call Next-Test,Use-Segment:Full segment path (no find).)
  $(call Use-Segment,${SegP}/ts3.mk)

  $(call Next-Test,Test overridable variables.)
  $(call Test-Info,Declaring ov1 as overridable.)
  $(call Overridable,ov1,ov1_val)
  $(call Test-Info,ov1:$(ov1))
  ov2 := ov2_original
  $(call Overridable,ov2,ov2_val)
  $(call Test-Info,ov2:$(ov2))
  # Should trigger an error message because 0v2 is already declared.
  $(call Overridable,ov2,ov2_new_val)
  $(call Test-Info,ov2:$(ov2))
  $(call Test-Info,Overridables: $(OverridableVars))

  $(call Next-Test,Confirmations)
  _r := $(call Confirm,Enter positive response.,y)
  $(call Test-Info,Response = "${_r}")
  ifeq (${_r},y)
  $(call Test-Info,Confirm = (positive))
  else
  $(call Test-Info,Confirm = (negative))
  endif
  _r := $(call Confirm,Enter negative response.,y)
  $(call Test-Info,Response = ${_r})
  ifeq (${_r},y)
  $(call Test-Info,Confirm = (positive))
  else
  $(call Test-Info,Confirm = (negative))
  endif
  $(call Pause)

test-helpers: display-errors display-messages
> ${MAKE} tv1=subtv1 tv3=subtv3 test-submake

else ifneq ($(call Is-Goal,test-submake),)
  $(call Test-Info,Testing sub-make...)
  $(call Test-Info,Before:tv1=${tv1} tv2=${tv2} tv3=${tv3})
  $(call Next-Test,Sticky variables in a sub-make.)
  $(call Test-Info,Cannot set sticky variables in a sub-make.)
  $(call Test-Info,StickyVars:${StickyVars})
  # tv1 should have the value from the command line but not saved.
  $(call Sticky,tv1,tv1)
  $(call Verbose,Sticky tv1 = ${tv1})
  $(call Test-Info,StickyVars:${StickyVars})
  # tv2 should be the saved value.
  $(call Sticky,tv2,tv2)
  $(call Verbose,Sticky tv2 = ${tv2})
  $(call Test-Info,StickyVars:${StickyVars})
  $(call Test-Info,tv3 should not be saved in the sticky directory.)
  $(call Sticky,tv3,tv3)
  $(call Verbose,Sticky tv3 = ${tv3})
  $(call Test-Info,StickyVars:${StickyVars})
  # Should cause redefinition error.
  $(call Sticky,tv2,xxx)
  $(call Verbose,After second Sticky tv2 = ${tv2})
  $(call Test-Info,StickyVars:${StickyVars})
  $(call Test-Info,After:tv1=${tv1} tv2=${tv2} tv3=${tv3})
  $(foreach _v,${StickyVars},\
    $(call Test-Info,Var vs file:${_v} = ${${_v}}:$(shell cat ${STICKY_PATH}/${_v})))

test-submake: display-errors display-messages

# endif # Goal is test-submake
endif # Goal is test-helpers

# +++++
# Postamble
ifneq ($(call Is-Goal,help-${Seg}),)
define help_${SegV}_msg
This make segment provides test support macros and tests for the macros in
helpers.mk.

Defines:

SuiteID
  Test counter. This is also the current test number.
TestC
  Test result counter. The total number of test results which were reported.
PassedC
  The number of tests which passed.
PassedL
  The list of passing test SuiteIDs.
FailedC
  The number of tests which failed.
FailedL
  The list of failing test SuiteIDs.

Defines the test helper macros:

Test-Info
  Display a test message in a parsable format. This shows the test number along
  with the test message.
  Parameters:
    1 = The message to display.
  Uses:
    SuiteID

PASS
  Display a test passed message.
  Parameters:
    1 = The message to display.
  Uses:
    SuiteID  The current test suite.
    TestC   Is incremented.
    PassedC Is incremented.
    PassedL SuiteID is appended to this list.

FAIL
  Display a test failed message.
  Parameters:
    1 = The message to display.
  Uses:
    SuiteID  The current test suite.
    TestC   Is incremented.
    FailedC Is incremented.
    FailedL SuiteID is appended to this list.

Next-Test
  Advance to the next test suite.
  Parameters:
    1 = A message describing the test.
  Uses:
    SuiteID  Incremented by 1.

Display-Vars
  Display a list of variables and their values. This produces a series of
  messages formatted as <varname> = <varvalue>
  Parameters:
    1 = The list of variable names.

Expect-Vars
  Steps through a list of <var>:<value> pairs and verifies the <var> has a
  value equal to <value>. PASS or FAIL messages are emitted accordingly.
  Parameters:
    1 = The list of <var>:<value> pairs. The pair must be separated with a
        colon (:) and the <value> cannot contain any spaces.

Expect-List
  Verifies a list matches an expected list by stepping through the expected
  list and verifying each word of the list being verified matches.
  Only the words in the expected list are verified -- meaning the list being
  verified can be longer than the expected list.
  Words that do not match produce an error message.
  NOTE: The list can be a typical list or can be a sentence with each word
  separated by spaces.
  Parameters:
    1 = The expected list.
    2 = The list to verify.

Report-Seg-Context
  Displays a series of messages for the current segment context as defined by
  Enter-Segment and Set-Segment-Context (see help-helpers).
  Uses:
    Variables defined by the helper macros.

Report-Test-Summary
  Display a summary of test results.
  Displays:
    TestC   This is also the total number of tests reported.
    PassedC The total number of tests reported as PASS.
    FailedC The total number of tests reported as FAIL.
endef
$(call Test-Info,help_${SegV}_msg = ${help_${SegV}_msg})
endif
$(call Exit-Segment)
$(call Next-Test,Restored context.)
$(call Report-Seg-Context)
else # SegId exists
$(call Next-Test,ID exists context.)
$(call Report-Seg-Context)
$(call Check-Segment-Conflicts)
endif # SegId
$(call Info,----- $(call Last-Segment-Basename) exit. -----)
