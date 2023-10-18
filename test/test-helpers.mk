#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# This make segment is designed to test macros.mk.
#-----------------------------------------------------------------------------
# The prefix $(call Last-Segment-Basename) must be unique for all files.
# +++++
# Preamble
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

define Test-Result
  $(call Format-Message,$(1):${SuiteID}:${TestC}:$(strip $(2)))
endef

define PASS
  $(call Inc-Var,TestC)
  $(call Test-Result,PASS,$(strip $(1)))
  $(call Inc-Var,PassedC)
  $(eval PassedL += ${SuiteID}:${TestC})
endef

define FAIL
  $(call Inc-Var,TestC)
  $(call Test-Result,FAIL,$(strip $(1)))
  $(call Inc-Var,FailedC)
  $(eval FailedL += ${SuiteID}:${TestC})
endef

_macro := Next-Suite
define _help
${_macro}
  Advance to the next test suite.
  Parameters:
    1 = A message describing the test.
  Uses:
    SuiteID  Incremented by 1.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(eval TestC := 0)
  $(call Inc-Var,SuiteID)
  $(call Info,$(NewLine))
  $(call Test-Info,++++ $(1) ++++)
endef

_macro := Display-Vars
define _help
${_macro}
  Display a list of variables and their values. This produces a series of
  messages formatted as <varname> = <varvalue>
  Parameters:
    1 = The list of variable names.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(foreach _v,$(1),
    $(call Test-Info,$(_v) = ${$(_v)})
  )
endef

_macro := Expect-Vars
define _help
${_macro}
  Steps through a list of <var>:<value> pairs and verifies the <var> has a
  value equal to <value>. PASS or FAIL messages are emitted accordingly.
  Parameters:
    1 = The list of <var>:<value> pairs. The pair must be separated with a
        colon (:) and the <value> cannot contain any spaces.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0),$(1))
  $(foreach _e,$(1),
    $(eval _ve := $(subst :,${Space},${_e}))
    $(call Debug,(${_ve}) Expecting:($(word 1,${_ve}))=($(word 2,${_ve})))
    $(if $(word 2,${_ve}),
      $(if $(filter ${$(word 1,${_ve})},$(word 2,${_ve})),
        $(call PASS,Expecting:(${_e}))
      ,
        $(call FAIL,Expecting:(${_e}) = (${$(word 1,${_ve})}))
      )
    ,
      $(if $(strip ${$(word 1,${_ve})}),
        $(call FAIL,Expecting:(${_e}) = (${$(word 1,${_ve})}))
      ,
        $(call PASS,Expecting:(${_e}))
      )
    )
  )
  $(call Exit-Macro)
endef

_macro := Expect-List
define _help
${_macro}
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
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0),$(1) $(2))
  $(call Debug,Expecting:($(1)) Actual:($(2)))
  $(eval _i := 0)
  $(eval _ex := )
  $(foreach _w,$(1),
    $(call Inc-Var,_i)
    $(if $(filter ${_w},$(word ${_i},$(2))),
      $(call Debug,${_w} = $(word ${_i},$(2)))
    ,
      $(eval _ex += ${_i})
    )
  )
  $(if ${_ex},
    $(call Test-Info,Lists do not match.)
    $(foreach _i,${_ex},
      $(call FAIL,\
        Expected:($(word ${_i},$(1))) Found:($(word ${_i},$(2))))
    )
  ,
    $(call PASS,Lists match.)
  )
  $(call Exit-Macro)
endef

_macro := Expect-String
define _help
${_macro}
  A synonym for Expect-List for clarity when checking strings.
  Parameters:
    1 = The expected string,
    2 = The string to verify.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0),$(1) $(2))
  $(call Debug,Expecting:($(1)) Actual:($(2)))
  $(call Expect-List,$(1),$(2))
  $(call Exit-Macro)
endef

Expected_Warning :=
Actual_Warning :=
_macro := Oneshot-Warning-Handler
define _help
${_macro}
  Use this as a one-shot message callback which verifies the error message using
  Expect-String. This is designed to be called from Warn. Use
  Set-Warning-Handler to install it. Once called Oneshot-Warning-Handler
  disables itself.
  Parameters:
    1 = The error message to verify.
  Uses:
    Expected_Warning
      The parameter is expected to match this string. See Expect-String for
      more information regarding matching.
    Actual_Warning
      The error message is saved for later verification.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0),$(1))
  $(call Set-Warning-Handler)
  $(eval Actual_Warning := $(1))
  $(call Debug,Actual:$(1))
  $(call Expect-String,${Expected_Warning},${Actual_Warning})
  $(call Exit-Macro)
endef

_macro := Expect-Warning
define _help
${_macro}
  Enables (arm) Oneshot-Warning-Handler as a callback and sets
  Expected_Warning.
  Parameters:
    1 = The expected warning.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0),$(1))
  $(eval Expected_Warning := $(1))
  $(call Set-Warning-Handler,Oneshot-Warning-Handler)
  $(call Exit-Macro)
endef

_macro := Verify-Warning
define _help
${_macro}
  Verifies Oneshot-Warning-Handler was called since calling Expect-Warning.
  A PASS is emitted if the error occurred. Otherwise a FAIL is emitted.
  This also disables the warning handler to avoid confusing subsequent tests.
  NOTE: For this to work Expect-Warning must be called to arm the one-shot
  handler.
  Parameters:
    1 = If not empty then the handler should have been called. Otherwise, the
        handler should not have been called.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(if ${Warning_Handler},
    $(call FAIL,Warning did not occur.)
    $(call Set-Warning-Handler)
  ,
    $(call PASS,Warning occurred -- as expected.)
  )
endef

_macro := Verify-No-Warning
define _help
${_macro}
  Verifies Oneshot-Warning-Handler was not called since calling Expect-Warning.
  A PASS is emitted If the warning has NOT occurred. Otherwise a FAIL is
  emitted.
  This also disables the warning handler to avoid confusing subsequent tests.
  NOTE: For this to work Expect-Warning must be called to arm the one-shot
  handler.
  Parameters:
    1 = If not empty then the handler should have been called. Otherwise, the
        handler should not have been called.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(if ${Warning_Handler},
    $(call PASS,Warning did not occur -- as expected.)
    $(call Set-Warning-Handler)
  ,
    $(call FAIL,An unexpected warning occurred.)
  )
endef

Expected_Error :=
Actual_Error :=
_macro := Oneshot-Error-Handler
define _help
${_macro}
  Use this as a one-shot error handler which verifies the error message using
  Expect-String. This is designed to be called from Signal-Error. Use
  Set-Error-Handler to install it. Once called Oneshot-Error-Handler disables
  itself.
  Parameters:
    1 = The error message to verify.
  Uses:
    Expected_Error
      The parameter is expected to match this string. See Expect-String for
      more information regarding matching.
    Actual_Error
      The error message is saved for later verification.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0),$(1))
  $(eval Actual_Error := $(1))
  $(call Expect-String,${Expected_Error},$(1))
  $(call Set-Error-Handler)
  $(call Exit-Macro)
endef

_macro := Expect-Error
define _help
${_macro}
  Enables (arm) Oneshot-Error-Handler as an error handler and sets
  Expected_Error.
  Parameters:
    1 = The expected error message.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(eval Expected_Error := $(1))
  $(call Set-Error-Handler,Oneshot-Error-Handler)
endef

_macro := Verify-Error
define _help
${_macro}
  Verifies Oneshot-Error-Handler was called since calling Expect-Error.
  A PASS is emitted if the error occurred. Otherwise a FAIL is emitted.
  This also disables the error handler to avoid confusing subsequent tests.
  NOTE: For this to work Expect-Error must be called to arm the one-shot
  handler.
  Parameters:
    1 = If not empty then the handler should have been called. Otherwise, the
        handler should not have been called.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(if ${Error_Handler},
    $(call FAIL,Error did not occur.)
    $(call Set-Error-Handler)
  ,
    $(call PASS,Error occurred -- as expected.)
  )
endef

_macro := Verify-No-Error
define _help
${_macro}
  Verifies Oneshot-Error-Handler was not called since calling Expect-Error.
  A PASS is emitted If the error has NOT occurred. Otherwise a FAIL is
  emitted.
  This also disables the error handler to avoid confusing subsequent tests.
  NOTE: For this to work Expect-Error must be called to arm the one-shot
  handler.
  Parameters:
    1 = If not empty then the handler should have been called. Otherwise, the
        handler should not have been called.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(if ${Error_Handler},
    $(call PASS,Error did not occur -- as expected.)
    $(call Set-Error-Handler)
  ,
    $(call FAIL,An unexpected error occurred.)
  )
endef

#+
# Display the current context and the context for a segment.
#-
_macro := Report-Seg-Context
define _help
${_macro}
  Displays a series of messages for the current segment context as defined by
  Enter-Segment and Set-Segment-Context (see help-helpers).
  Uses:
    Variables defined by the helper macros.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0))
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
  $(call Exit-Macro)
endef

#+
# Display a test summary.
#-
_macro := Report-Test-Summary
define _help
${_macro}
  Display a summary of test results.
  Displays:
    TestC   This is also the total number of tests reported.
    PassedC The total number of tests reported as PASS.
    FailedC The total number of tests reported as FAIL.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0))
  $(call Test-Info,${TestC} Total passed:${PassedC} Total failed:${FailedC})
  $(call Test-Info,Passed tests:${PassedL})
  $(call Test-Info,Failed tests:${FailedL})
  $(call Exit-Macro)
endef

# NOTE: This required DEBUG to be defined.
ifneq (${DEBUG},)
  ifneq ($(call Is-Goal,test-stack),)
    $(call Test-Info,Testing the macro stack.)
    define m-3
      $(call Enter-Macro,m-3)
      $(call Test-Info,Macro entered,)
      $(call Exit-Macro)
      $(call Test-Info,Macro exited.)
    endef

    define m-2
      $(call Enter-Macro,m-2)
      $(call Test-Info,Macro entered,)
      $(call m-3)
      $(call Exit-Macro)
      $(call Test-Info,Macro exited.)
    endef

    define m-1
      $(call Enter-Macro,m-1)
      $(call Test-Info,Macro entered,)
      $(call m-2)
      $(call Exit-Macro)
      $(call Test-Info,Macro exited.)
    endef

    $(call Debug,Calling m-1.)
    $(call m-1)

test-stack: display-errors display-messages

  endif

endif

ifneq ($(call Is-Goal,test-helpers),)
  $(call Test-Info,Testing helpers...)

  $(call Next-Suite,String manipulation.)
  t1 := A1bc!4De
  t1l := $(call To-Lower,${t1})
  t1u := $(call To-Upper,${t1})
  t2 := cDeF-gHiJ
  t2l := $(call To-Lower,${t2})
  t2u := $(call To-Upper,${t2})

  $(call Expect-Vars,\
    t1l:a1bc!4de \
    t1u:A1BC!4DE \
    t2l:cdef-ghij\
    t2u:CDEF-GHIJ \
  )

  $(call Next-Suite,Expect-Vars)
  v1 := v1_val
  v2 := v2_val
  v3 := v3_val
  v4 := v4_fail

  $(call Test-Info,FAIL:${SuiteID}:4 Is expected.)
  $(call Expect-Vars,v1:v1_val v2:v2_val v3:v3_val v4:v4_val)

  $(call Next-Suite,Expect-List)
  $(call Test-Info,The list being verified can be longer than the expect list.)
  $(call Expect-List,one two three four,one two three four five)
  $(call Test-Info,Same lists.)
  $(call Expect-List,one two three four,one two three four)
  $(call Test-Info,Lists do not match.)
  $(call Test-Info,Expect FAIL.)
  $(call Expect-List,one two three four,one Two three Four)
  $(call Test-Info,Expect PASS.)
  $(call Expect-String,This should pass.,This should pass.)
  $(call Test-Info,Expect FAIL.)
  $(call Expect-String,This should fail.,This should FAIL.)

  $(call Next-Suite,Add-To-Manifest)

  $(call Add-To-Manifest,l1,null,one)
  $(call Test-Info,List: l1=${l1})
  $(call Expect-List,l1,one)

  $(call Add-To-Manifest,l1,null,two)
  $(call Test-Info,List: l1=${l1})
  $(call Expect-List,${l1},one two)

  $(call Add-To-Manifest,l2,l2_e1,2.one)
  $(call Test-Info,Var: l2_e1=${l2_e1})
  $(call Expect-Vars,l2_e1:2.one)
  $(call Test-Info,List: l2=${l2})
  $(call Expect-List,${l}2,2.one)

  $(call Add-To-Manifest,l2,l2_e2,2.two)
  $(call Test-Info,Var: l2_e2=${l2_e1})
  $(call Expect-Vars,l2_e2:2.two)
  $(call Test-Info,List: l2=${l2})
  $(call Expect-List,${l2},2.one 2.two)

  $(call Next-Suite,Signal-Error)

  $(call Expect-Error,Error one.)
  $(call Signal-Error,Error one.)
  $(call Verify-Error)
  $(call Test-Info,ErrorList: ${ErrorList})
  $(call Expect-Error,Error two.)
  $(call Signal-Error,Error two.)
  $(call Verify-Error)
  $(call Test-Info,ErrorList: ${ErrorList})
  $(call Expect-Error,Error three.)
  $(call Signal-Error,Error three.)
  $(call Verify-Error)
  $(call Test-Info,ErrorList: ${ErrorList})
  $(call Expect-Error,Error four.)
  $(call Signal-Error,Error four.)
  $(call Verify-Error)
  $(call Test-Info,ErrorList: ${ErrorList})
  $(call Expect-Error,Error five.)
  $(call Signal-Error,Error five.)
  $(call Verify-Error)
  $(call Test-Info,ErrorList: ${ErrorList})

$(call Next-Suite,Signal-Error callback.)
  define error-handler
    $(call Enter-Macro,error-handler)
    $(call Test-Info,$(1))
    $(eval _err := 1)
    $(call Exit-Macro)
  endef

  define recursive-error-handler
    $(call Enter-Macro,recursive-error-handler)
    $(call Test-Info,$(1))
    $(call Inc-Var,_err)
    $(call Signal-Error,Recursive error.)
    $(call Exit-Macro)
  endef

  _err :=
  $(call Signal-Error,No error handler.)
  $(call Expect-Vars,_err:)

  $(call Set-Error-Handler,error-handler)
  $(call Signal-Error,Error handler installed.)
  $(call Expect-Vars,_err:1)

  _err := 0
  $(call Set-Error-Handler,recursive-error-handler)
  $(call Signal-Error,Recursive error handler installed.)
  $(call Expect-Vars,_err:1)

  _err :=
  $(call Set-Error-Handler)
  $(call Signal-Error,Error handler removed.)
  $(call Expect-Vars,_err:)

  $(call Next-Suite,Current context.)
  $(call Report-Seg-Context)

  $(call Next-Suite,$(SHELL) HELPER_FUNCTIONS)
  $(call Test-Info,helpersSegId = ${helpersSegId})
  $(call Test-Info,HELPER_FUNCTIONS = ${HELPER_FUNCTIONS})

  $(call Next-Suite,Return-Code)
  _o := 0
  $(call Test-Info,Return-Code:Checking: ${_o})
  # No exception.
  _r := $(call Return-Code,0)
  $(call Test-Info,Return-Code returned: (${_r}))
  ifeq (${_r},)
    $(call PASS,Return-Code returned an empty variable.)
  else
    $(call FAIL,Return-Code returned a non-empty variable.)
  endif
  $(call Expect-Vars,_r:)
  _o := This is 0
  $(call Test-Info,Return-Code:Checking: ${_o})
  _r := $(call Return-Code,${_o})
  $(call Test-Info,Return-Code returned: (${_r}))
  ifeq (${_r},)
    $(call PASS,Return-Code returned an empty variable.)
  else
    $(call FAIL,Return-Code returned a non-empty variable.)
  endif
  $(call Expect-Vars,_r:)
  # Exception.
  _o := 128
  $(call Test-Info,Return-Code:Checking: ${_o})
  _r := $(call Return-Code,${_o})
  $(call Test-Info,Return-Code returned: (${_r}))
  ifeq (${_r},)
    $(call FAIL,Return-Code returned an empty variable.)
  else
    ifeq (${_r},${_o})
      $(call PASS,Return-Code returned ${_o}.)
    else
      $(call FAIL,Return-Code returned ${_o}.)
    endif
  endif
  $(call Expect-Vars,_r:128)

  _o := Exception is 128
  $(call Test-Info,Return-Code:Checking: (${_o}))
  _r := $(call Return-Code,${_o})
  $(call Test-Info,Return-Code returned: (${_r}))
  ifeq (${_r},)
    $(call FAIL,Return-Code returned an empty variable.)
  else
    ifeq (${_r},$(lastword ${_o}))
      $(call PASS,Return-Code expected: ($(lastword ${_o})).)
    else
      $(call FAIL,Return-Code expected:($(lastword ${_o})).)
    endif
  endif
  $(call Expect-Vars,_r:128)

  $(call Next-Suite,Running shell commands.)
  $(call Run,ls test)
  $(call Test-Info,Run output = ${Run_Output})
  $(call Test-Info,Run return code: ${Run_Rc})
  ifeq (${Run_Rc},)
    $(call PASS,Run_Rc is empty.)
  else
    $(call FAIL,Run_Rc is NOT empty.)
  endif
  $(call Expect-Vars,Run_Rc:)
  $(call Run,ls not-exist)
  $(call Test-Info,Run output = ${Run_Output})
  $(call Test-Info,Run return code: ${Run_Rc})
  ifeq (${Run_Rc},)
    $(call FAIL,Run_Rc is empty.)
  else
    ifeq (${Run_Rc},$(lastword ${Run_Output}))
      $(call PASS,Run_Rc (${Run_Rc}).)
    else
      $(call FAIL,Run_Rc is (${Run_Rc}) expected ($(lastword ${Run_Output})).)
    endif
  endif
  $(call Test-Info,Run return code: ${_r})

  $(call Next-Suite,Segment identifiers.)
  $(call Report-Seg-Context)

  $(call Next-Suite,Sticky variables.)
  tv1 := tv1_v
  tv2 := tv2_v
  $(call Test-Info,STICKY_PATH = ${STICKY_PATH})
  $(call Test-Info,StickyVars:${StickyVars})
  $(call Sticky,tv1,tv1)
  $(call Verbose,Sticky tv1 = ${tv1})
  $(call Expect-Vars,tv1:tv1_v)
  $(call Test-Info,StickyVars:${StickyVars})
  $(call Sticky,tv2,tv2)
  $(call Verbose,Sticky tv2 = ${tv2})
  $(call Expect-Vars,tv2:tv2_v)
  $(call Test-Info,StickyVars:${StickyVars})

  $(call Set-Error-Handler,Expect-Error)
  # Should cause redefinition error.
  Expected_Error := Redefinition of sticky variable tv2 ignored.
  $(call Sticky,tv2,xxx)
  $(call Verbose,After second Sticky tv2 = ${tv2})
  $(call Expect-Vars,tv2:tv2_v)
  $(call Test-Info,StickyVars:${StickyVars})
  # Using assignment in call.
  $(call Sticky,tv3=tv3_v)
  $(call Expect-Vars,tv3:tv3_v)
  # Redefine the previous error variable.
  Expected_Error := Redefinition of sticky variable tv2 -- should not happen.
  $(call Redefine-Sticky,tv2=xxx)
  $(call Verbose,After redefined Sticky tv2 = ${tv2})
  $(call Expect-Vars,tv2:xxx)
  $(call Test-Info,StickyVars:${StickyVars})

  $(call Test-Info,StickyVars:Var:<var>=<val>:<saved>)
  $(foreach _v,${StickyVars},\
    $(call Test-Info,Var:${_v} = ${${_v}}:$(shell cat ${STICKY_PATH}/${_v}))\
  )
  $(call Set-Error-Handler)

  $(call Next-Suite,Require)
  a := 1
  b := 2
  c := 3
  r := $(call Require,a b c d)
  ifeq (${r},)
    $(call FAIL,Require: Returned an empty string -- should have returned d.)
  else
    ifeq (${r},d)
      $(call PASS,Require: Returned (${r}).)
    else
      $(call FAIL,Require: Returned (${r}) -- should have been (d).)
    endif
  endif
  r := $(call Require,a b c)
  ifeq (${r},)
    $(call PASS,Require: Returned an empty string as it should.)
  else
    $(call FAIL,Require: Returned (${r})- -- should have been empty.)
  endif

  $(call Next-Suite,Must-Be-One-Of)
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

  $(call Next-Suite,Use-Segment)

  $(call Test-Info,Segments in the current directory.)
  $(call Use-Segment,ts1)
  $(call Use-Segment,ts2)
  $(call Test-Info,Segments in subdirectories.)
  $(call Use-Segment,td1)
  $(call Use-Segment,td2)
  $(call Use-Segment,td3)
  $(call Test-Info,Multiple segments of the same name.)
  $(call Use-Segment,tm1)
  $(call Expect-Error,Prefix conflict with tm1)
  $(call Use-Segment,test/d2/tm1)
  $(call Verify-Error)
  $(call Test-Info,A segment in a subdirectory.)
  $(call Use-Segment,sd3/tsd3)
  $(call Test-Info,Does not exist.)
  $(call Expect-Error,te1.mk not found.)
  $(call Use-Segment,te1)
  $(call Verify-Error)
  $(call Test-Info,Full segment path (no find).)
  $(call Use-Segment,${SegP}/ts3.mk)

  $(call Next-Suite,Test overridable variables.)
  $(call Test-Info,Declaring ov1 as overridable.)
  $(call Overridable,ov1,ov1_val)
  $(call Test-Info,ov1:$(ov1))
  ov2 := ov2_original
  $(call Overridable,ov2,ov2_val)
  $(call Test-Info,ov2:$(ov2))
  # Should trigger an error message because 0v2 is already declared.
  $(call Expect-Error,Var ov2 has already been declared.)
  $(call Overridable,ov2,ov2_new_val)
  $(call Verify-Error)
  $(call Test-Info,ov2:$(ov2))
  $(call Test-Info,Overridables: $(OverridableVars))

  $(call Next-Suite,Confirmations)
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
  $(call Next-Suite,Sticky variables in a sub-make.)
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
define help-${Seg}
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
    SuiteID The current test suite.
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

${help-Next-Suite}

${help-Display-Vars}

${help-Expect-Vars}

${help-Expect-List}

${help-Expect-String}

${help-Oneshot-Error-Handler}

${help-Expect-Error}

${help-Verify-Error}

${help-Verify-No-Error}

${help-Report-Seg-Context}

${help-Report-Test-Summary}

endef
$(call Test-Info,help-${Seg} = ${help-${Seg}})
endif
$(call Exit-Segment)
$(call Next-Suite,Restored context.)
$(call Report-Seg-Context)
else # SegId exists
$(call Next-Suite,ID exists context.)
$(call Report-Seg-Context)
$(call Check-Segment-Conflicts)
endif # SegId
