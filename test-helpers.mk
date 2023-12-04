#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# This make segment is designed to test macros.mk.
#-----------------------------------------------------------------------------
# The prefix $(call Last-Segment-Basename) must be unique for all files.
# +++++
# Preamble
ifndef $(call Last-Segment-Basename)SegId
$(call Enter-Segment)
# -----

DEFAULT_SUITES_PATH := test-suites

_var := SUITES_PATH
$(call Sticky,${_var},${DEFAULT_SUITES_PATH})
define _help
(Sticky) ${_var} = ${${_var}}
  The path to the directory containing the test suites to run.
  Default: DEFAULT_SUITES_PATH = ${DEFAULT_SUITES_PATH}
endef
help-${_var} := $(call _help)

_var := CASES
$(call Sticky,${_var},$(call Basenames-In,${SUITES_PATH}/*.mk))
define _help
(Sticky) ${_var} = ${${_var}}
  The list of test cases to run. This defaults to all of the makefile
  segments in the directory indicated by SUITES_PATH. To use this on the
  make command line enclose the test suite list in quotes.
  NOTE: All of the test suites must exist as makefile segments in the
  SUITES_PATH directory.
  The make wildcard character "%" is supported. In other words this can be used
  to match all test names matching the same pattern.
  Tests in a suite can be limited to one or more tests using the
  <suite>.<test>[+<test>...] notation.
  This relies upon each test suite defining a list of available tests. This
  variable must be named <suite>.TestL.
  Examples:
    Run all tests in the SUITES_PATH directory. NOTE: This does not change the
    previously saved sticky value.
      CASES=""
    Run all tests in suite1 and suite2.
      CASES="suite1 suite2"
    Run only test1 and test2 in suite1.
      CASES="suite1.test1+test2"
    Run all tests in the current segment context.
      CASES="."
    Run only test1 from current segment context.
      CASES=".test1"
    Run all tests having the same prefix in the current segment context.
      CASES=".test%"
    Run all tests having the same prefix in suite1 and suite2.
      CASES="suite1.test% suite2.test%"
    Run all tests matching any of multiple prefixes in suite1.
      CASES="suite1.test%+ts_%"
endef
help-${_var} := $(call _help)

_var := SuiteL
${_var} :=
define _help
${_var}
  The list of all test suites which are in use.
endef
help-${_var} := $(call _help)

_var := SuiteRunL
${_var} :=
define _help
${_var}
  The list of test suites to be run in the current session.
endef
help-${_var} := $(call _help)

_var := TestL
${_var} :=
define _help
${_var}
  The list of all tests which have been added to a test suite.
endef
help-${_var} := $(call _help)

_var := SuiteL
${_var} :=
define _help
${_var}
  The list of all test suites which have been added to a test suite.
endef
help-${_var} := $(call _help)

_var := TestRunL
${_var} :=
define _help
${_var}
  The list of tests to be run in the current session.
endef
help-${_var} := $(call _help)

_var := CompletedTestC
${_var := 0}
define _help
${_var}
  The number of tests which have completed.
endef
help-${_var} := $(call _help)

_var := PassedC
${_var} :=
define _help
${_var}
  Total number of passed test steps. This is incremented when a step passes.
endef
help-${_var} := $(call _help)

_var := FailedC
${_var} :=
define _help
${_var}
  Total number of failed test steps. This is incremented when a step fails.
endef
help-${_var} := $(call _help)

_var := SuiteN
${_var} :=
define _help
${_var}
  The name of the running test suite.
endef
help-${_var} := $(call _help)

_var := SuiteID
${_var} := 0
define _help
${_var}
  The current test suite number. This is incremented by Begin-Suite.
endef
help-${_var} := $(call _help)

_var := SuitesL
${_var} :=
define _help
${_var}
  The list of test suite names which have run. This can be used to get the name
  of a test suite using a suite ID. This is appended by Begin-Suite.
endef
help-${_var} := $(call _help)

_var := PassedSuitesL
${_var} :=
define _help
${_var}
  The list of passed test suites. This is appended by End-Suite.
  Each entry has the form:
    <suiteID>
endef
help-${_var} := $(call _help)

_var := FailedSuitesL
${_var} :=
define _help
${_var}
  The list of failed test suites. This is appended by End-Suite.
  Each entry has the form:
    <suiteID>
endef
help-${_var} := $(call _help)

_var := SuiteTestC
${_var} := 0
define _help
${_var}
  The number of tests run in the running test suite. This is reset by
  Begin-Suite and incremented by Begin-Test.
endef
help-${_var} := $(call _help)

_var := SuiteTestL
${_var} := 0
define _help
${_var}
  The list of tests run in the running test suite. This is reset by
  Begin-Suite and appended by Begin-Test.
endef
help-${_var} := $(call _help)

_var := SuitePassedC
${_var} :=
define _help
${_var}
  The number of passing tests in the current test suite. This is reset by
  Begin-Suite and incremented by End-Test.
endef
help-${_var} := $(call _help)

_var := SuitePassedL
${_var} :=
define _help
${_var}
  The list of passing tests in the current test suite. This is reset by
  Begin-Suite and appended by End-Test.
  Each entry has the form:
    <suiteID>:<testID>:<stepID>
endef
help-${_var} := $(call _help)

_var := SuiteFailedC
${_var} :=
define _help
${_var}
  The number of failing tests in the current test suite. This is reset by
  Begin-Suite and incremented by End-Test.
endef
help-${_var} := $(call _help)

_var := SuiteFailedL
${_var} :=
define _help
${_var}
  The list of failing tests in the current test suite. This is reset by
  Begin-Suite and appended by End-Test.
  Each entry has the form:
    <suiteID>:<testID>:<stepID>
endef
help-${_var} := $(call _help)

_var := TestN
${_var} :=
define _help
${_var}
  The name of the running test.
endef
help-${_var} := $(call _help)

_var := TestsL
${_var} :=
define _help
${_var}
  The list of test names which have run. This can be used to get the name
  of a test using a test ID. This is appended by Begin-Test.
endef
help-${_var} := $(call _help)

_var := TestID
${_var} := 0
define _help
${_var}
  The current test number. This is incremented by Begin-Test and also
  indicates the total number of tests run.
endef
help-${_var} := $(call _help)

_var := PassedTestsL
${_var} :=
define _help
${_var}
  The list of all passed tests. This is appended by End-Suite.
  Each entry has the form:
    <suiteID>:<testID>:<stepID>
endef
help-${_var} := $(call _help)

_var := FailedTestsL
${_var} :=
define _help
${_var}
  The list of all failed tests. This is appended by End-Suite.
  Each entry has the form:
    <suiteID>:<testID>:<stepID>
endef
help-${_var} := $(call _help)

_var := PassedTestsC
${_var} := 0
define _help
${_var}
  The total number of tests which passed. This is incremented by End-Test.
endef
help-${_var} := $(call _help)

_var := FailedTestsC
${_var} := 0
define _help
${_var}
  The total number of tests which failed. This is incremented by End-Test.
endef
help-${_var} := $(call _help)

_var := StepC
${_var} := 0
define _help
${_var}
  The total number of steps executed in the test run.
endef
help-${_var} := $(call _help)

_var := StepID
${_var} := 0
define _help
${_var}
  The test step within the running test. This is reset by Begin-Test and
  incremented each time a PASS or FAIL is reported.
endef
help-${_var} := $(call _help)

_var := TestFailed
${_var} :=
define _help
${_var}
  A flag indicating when a test step has failed and therefore a test has
  failed. This is reset by Begin-Test and set by FAIL. A failure is indicated
  when this variable is not empty.
endef
help-${_var} := $(call _help)


_macro := Test-Info
define _help
${_macro}
  Display a test message in a parsable format. This shows the test number along
  with the test message.
  Parameters:
    1 = The message to display.
  Uses:
    SuiteID
    TestID
    StepID
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Info,Suite:${SuiteID}:${TestID}:${StepID}:$(strip $(1)))
endef

_macro := Log-Result
define _help
${_macro}
  Display the result of a test step.
  Parameters:
    1 = A four character prefix for the result message. Typically this is
        PASS or FAIL since this is called by those macros.
    2 = The message for the result.
  Uses:
    SuiteID   The current test suite.
    TestID    The current test in the test suite.
    StepID    The test step in the current test. This is incremented by 1.
    StepC     The total number of steps in the test run. This is incremented
              by 1.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Inc-Var,StepID)
  $(call Inc-Var,StepC)
  $(call Log-Message,$(1),${SuiteID}:${TestID}:${StepID}:$(2))
endef

_macro := Record-PASS
define _help
${_macro}
  Record a PASS test step result.
Uses:
${help-PassedC}
${help-SuiteN}
${help-TestN}
${help-StepID}
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Inc-Var,PassedC)
  $(eval SuitePassedL += ${SuiteN}:${TestN}:${StepID})
endef

_macro := Record-FAIL
define _help
${_macro}
  Record a FAIL test step result.
Uses:
${help-FailedC}
${help-SuiteN}
${help-TestN}
${help-StepID}
$(help-TestFailed)
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Inc-Var,FailedC)
  $(eval SuiteFailedL += ${SuiteN}:${TestN}:${StepID})
  $(eval TestFailed := 1)
endef

_var := ExpectedResultsL
${_var} :=
define _help
${_var}
  The list of PASS or FAIL results to verify. Each call to PASS or FAIL
  advances to the next result in the list. The results are verified in the
  order in which they are specified in this list.
  e.g. FAIL PASS PASS FAIL PASS Expects a FAIL followed by a PASS followed by
  two PASSEs and finally a FAIL.
endef
help-${_var} := $(call _help)

_macro := Verify-Result
define _help
${_macro}
  This is called by either PASS or FAIL when ExpectedResultL is not empty.
  As each result is verified it is removed from the head of the list. The
  message for the result is logged.
  NOTE: If the expected results list is empty then an error is emitted.
  Parameters:
    1 = The step result -- either PASS or FAIL.
    2 = The message for the result.
  Uses:
${help-ExpectedResultsL}
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0),$(1))
  $(if ${ExpectedResultsL},
    $(if $(filter $(1),$(word 1,${ExpectedResultsL})),
      $(call Log-Result,PASS,$(1):$(2))
      $(call Record-PASS)
    ,
      $(call Log-Result,FAIL,$(1):$(2))
      $(call Record-FAIL)
    )
    $(eval ExpectedResultsL := \
      $(wordlist 2,$(words ${ExpectedResultsL}),${ExpectedResultsL}))
  ,
    $(call Signal-Error,Call to Verify-Result when no results are expected.)
  )
  $(call Exit-Macro)
endef

_macro := PASS
define _help
${_macro}
  Display a test passed message. If results are expected the PASS result is
  verified using Verify-Result.
  Parameters:
    1 = The message to display.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(if ${ExpectedResultsL},
    $(call Verify-Result,$(0),$(1))
  ,
    $(call Log-Result,PASS,$(1))
    $(call Record-PASS)
  )
endef

_macro := FAIL
define _help
${_macro}
  Display a test failed message. This also flags the current test and suite
  as having failed. If results are expected the FAIL result is verified using
  Verify-Result.
  Parameters:
    1 = The message to display.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(if ${ExpectedResultsL},
    $(call Verify-Result,$(0),$(1))
  ,
    $(call Log-Result,FAIL,$(1))
    $(call Record-FAIL)
  )
endef

_macro := Set-Expected-Results
define _help
${_macro}
  Sets a list of test step results to be verified when PASS or FAIL are called.
  This is useful when a FAIL result is actually an indication that a test
  step passed. See
  Parameters:
    1 = The list of PASS and FAIL results to verify.
  Uses:
    ${help-ExpectedResultsL}
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0),$(1))
  $(eval ExpectedResultsL := $(1))
  $(call Exit-Macro)
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

ExpectedMessage :=
TestingExpect :=
MatchFound :=
MatchCount := 0

define _Check-Message
  $(if ${TestingExpect},
  ,
    $(eval TestingExpect := 1)
    $(call Enter-Macro,$(0),$(1))
    $(eval _i := 0)
    $(eval _no_match := )
    $(foreach _w,${ExpectedMessage},
      $(call Inc-Var,_i)
      $(if $(filter ${_w},$(word ${_i},$(1))),
      ,
        $(eval _no_match += ${_i})
      )
    )
    $(if ${_no_match},
      $(call Test-Info,Messages do not match.)
    ,
      $(call Test-Info,Message matched.)
      $(eval MatchFound := 1)
      $(call Inc-Var,MatchCount)
    )
    $(call Exit-Macro)
    $(eval TestingExpect :=)
  )
endef

_macro := Expect-Message
define _help
${_macro}
  Use this to check all messages for a match with an expected message. When
  the expected message is detected then indicate the expect passed. Use
  Verify-Message to signal a pass or a fail.
  NOTE: This checks the entire log line including all trace information.
  This works by setting a callback to the expect filter using Set-Log-Callback.
  Parameters:
    1 = The expected message. The make wildcard character "%" can be used in
        individual words.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0),$(1))
  $(eval Expected_Message := $(1))
  $(eval MatchFound := )
  $(eval MatchCount := 0)
  $(call Set-Message-Callback,Check-Message)
  $(call Exit-Macro)
endef

_macro := Verify-Message
define _help
${_macro}
  Verifies one or more messages matched the expected message. If a match
  occurred the specified number of times a PASS is emitted. Otherwise, a FAIL
  is emitted. This also clears the message callback.
  Parameters:
    1 = The number of times the message should have matched. If empty then
        at least one match is verified to have occurred.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Set-Message-Callback)
  $(call Enter-Macro,$(0),$(1))
  $(if ${MatchFound},
    $(if $(1),
      $(call Test-Info,Verifying the message matched $(1) times.)
      $(if $(intcmp ${MessageCount},$(1)),
        $(call PASS,The message matched ${MessageCount} times.)
      ,
        $(call FAIL,The message matched ${MessageCount} times.)
      )
    ,
      $(call PASS,The message matched ${MessageCount} times.)
    )
  ,
    $(call FAIL,No messages matched.)
  )
  $(call Exit-Macro)
endef

Expected_Warning :=
Actual_Warning :=
_macro := Oneshot-Warning-Callback
define _help
${_macro}
  Use this as a one-shot message callback which verifies the error message using
  Expect-String. This is designed to be called from Warn. Use
  Set-Warning-Callback to install it. Once called Oneshot-Warning-Callback
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
  $(call Set-Warning-Callback)
  $(eval Actual_Warning := $(1))
  $(call Debug,Actual:$(1))
  $(call Expect-String,${Expected_Warning},${Actual_Warning})
  $(call Exit-Macro)
endef

_macro := Expect-Warning
define _help
${_macro}
  Enables (arm) Oneshot-Warning-Callback as a callback and sets
  Expected_Warning. The next call should be one which would generate the
  expected warning. That should be followed by a call to Verify-Warning.
  Parameters:
    1 = The expected warning.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0),$(1))
  $(eval Expected_Warning := $(1))
  $(call Set-Warning-Callback,Oneshot-Warning-Callback)
  $(call Exit-Macro)
endef

_macro := Verify-Warning
define _help
${_macro}
  Verifies Oneshot-Warning-Callback was called since calling Expect-Warning.
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
    $(call Set-Warning-Callback)
  ,
    $(call PASS,Warning occurred -- as expected.)
  )
endef

_macro := Verify-No-Warning
define _help
${_macro}
  Verifies Oneshot-Warning-Callback was not called since calling Expect-Warning.
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
    $(call Set-Warning-Callback)
  ,
    $(call FAIL,An unexpected warning occurred.)
  )
endef

Expected_Error :=
Actual_Error :=
_macro := Oneshot-Error-Callback
define _help
${_macro}
  Use this as a one-shot error handler which verifies the error message using
  Expect-String. This is designed to be called from Signal-Error. Use
  Set-Error-Callback to install it. Once called Oneshot-Error-Callback disables
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
  $(call Set-Error-Callback)
  $(call Exit-Macro)
endef

_macro := Expect-Error
define _help
${_macro}
  Enables (arm) Oneshot-Error-Callback as an error handler and sets
  Expected_Error. NOTE: Verify-Error must be called to verify that the
  error occurred and that the expected message was emitted.
  Parameters:
    1 = The expected error message.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(eval Expected_Error := $(1))
  $(call Set-Error-Callback,Oneshot-Error-Callback)
endef

_macro := Verify-Error
define _help
${_macro}
  Verifies Oneshot-Error-Callback was called since calling Expect-Error.
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
    $(call Set-Error-Callback)
  ,
    $(call PASS,Error occurred -- as expected.)
    $(call Expect-String,${Expected_Error},$(1))
  )
endef

_macro := Verify-No-Error
define _help
${_macro}
  Verifies Oneshot-Error-Callback was not called since calling Expect-Error.
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
    $(call Set-Error-Callback)
  ,
    $(call FAIL,An unexpected error occurred.)
  )
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
  $(call Enter-Macro,$(0),$(1))
  $(foreach _v,$(1),
    $(call Test-Info,$(_v) = ${$(_v)})
  )
  $(call Exit-Macro)
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
    ${Seg}.SegId \
    ${Seg}.Seg \
    ${Seg}.SegV \
    ${Seg}.SegP \
    ${Seg}.SegF \
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
  Get-Segment-File:${Seg}.SegId:$(call Get-Segment-File,${${Seg}.SegId}))
  $(call Test-Info,\
  Get-Segment-Basename:${Seg}.SegId:$(call Get-Segment-Basename,${${Seg}.SegId}))
  $(call Test-Info,\
  Get-Segment-Var:${Seg}.SegId:$(call Get-Segment-Var,${${Seg}.SegId}))
  $(call Test-Info,\
  Get-Segment-Path:${Seg}.SegId:$(call Get-Segment-Path,${${Seg}.SegId}))

  $(call Test-Info,Last-Segment-Id:$(call Last-Segment-Id))
  $(call Test-Info,Last-Segment-Basename:$(call Last-Segment-Basename))
  $(call Test-Info,Last-Segment-Var:$(call Last-Segment-Var))
  $(call Test-Info,Last-Segment-Path:$(call Last-Segment-Path))
  $(call Test-Info,Last-Segment-File:$(call Last-Segment-File))
  $(call Test-Info,MAKEFILE_LIST:$(MAKEFILE_LIST))
  $(call Exit-Macro)
endef

_macro := Report-Test-Results
define _help
${_macro}
  Display a summary of test results.
  Displays:
    CompletedTestC
            This is also the total number of tests reported.
    PassedC The total number of tests reported as PASS.
    FailedC The total number of tests reported as FAIL.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0))
  $(call Test-Info,\
    Ran ${StepC} steps in ${CompletedTestC} tests in ${SuiteID} suites.)
  $(call Test-Info,Total passed:${PassedC} Total failed:${FailedC})
  $(if ${FailedTestsL},
    $(call Test-Info,Failed tests:${FailedTestsL})
  )
  $(call Exit-Macro)
endef

_macro := Begin-Test
define _help
${_macro}
  Advance to the next test in the current test suite.
  Parameters:
    1 = The name of the test.
  Uses:
    SuiteN    The name of the running test suite.
    TestN     Set to the name of the test.
    TestID    Incremented by 1.
    SuiteTestC     Incremented by 1.
    StepID    Reset to 0.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0),$(1))
  $(call Test-Info,Begin test:${SuiteN}:$(1))
  $(eval TestN := $(1))
  $(call Inc-Var,TestID)
  $(call Inc-Var,TestC)
  $(eval StepID := 0)
  $(call Line)
  $(call Exit-Macro)
endef

_macro := End-Test
define _help
${_macro}
  Mark the end of a test and do any end of test processing.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0))
  $(call Test-Info,End test:${SuiteID}:$(1))
  $(call Exit-Macro)
endef

_macro := Run-Prerequisites
define _help
${_macro}
  Run a list of prerequisite tests. If a prerequisite test has already run
  it will be skipped. To avoid test loops the prerequisites for a prerequisite
  test are ignored. A reference to a prerequisite test has the format:
    <seg>.<test>
  The segment <seg> is loaded if it has not already been loaded.

  Parameters:
    1 = The test for which the prerequisites should be run.
  Uses:
    <seg>.SegID
      Use to determine if a test suite makefile segment has been loaded or
      not.
    <test>.Prereqs
      The list of prerequisites defined by the test.
    TestFailed
      Used to determine if a prerequisite test failed.
    PrereqFailed
      Indicates when a prerequisite test has failed.
endef
help-${_macro} = $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0),$(1))
  $(if ${$(1).Prereqs},
    $(call Debug,$(1) prereqs:${$(1).Prereqs})
    $(foreach _prereq,${$(1).Prereqs},
      $(call Use-Segment,$(word 1,$(subst ., ,${_prereq})))
      $(if $(filter ${_prereq},${PassedTestsL}),
        $(call Test-Info,Test ${_prereq} has already passed -- skipping.)
      ,
        $(if $(filter ${_prereq},${FailedTestsL}),
          $(call Test-Info,Test ${_prereq} FAILED -- skipping.)
          $(eval PrereqFailed := 1)
        ,
          $(eval TestFailed := )
          $(call ${_prereq})
          $(call Inc-Var,CompletedTestC)
          $(if ${TestFailed},$(eval PrereqFailed := 1))
        )
      )
    )
  )
  $(call Exit-Macro)
endef

_macro := Run-Tests
define _help
${_macro}
  Run each test in a list of tests. The individual tests will be executed only
  if they are included in the list of goals. Each test can declare a list of
  tests which need to be successfully run (PASS) before running the current
  test (prerequisites). This list is declared in a variable named
  <test>.Prereqs. Prerequisite tests do not need to be listed as a goal.
  If any of the prerequisite tests fail as indicated by the variable TestFailed
  the current test is considered to have failed.
  Parameters:  Parameters:
    1 = The name of the list of tests to run.
  Uses:
    <test>.Prereqs
      A list of prerequisite tests which must pass before the current test
      will be run. If any of the prerequisite tests fail the dependent test
      will not be run.
    PrereqFailed
      Indicates when a prerequisite test has failed. The current test is
      skipped if this is not empty. The FAIL macro sets this.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0),$(1))
  $(if $(1),
    $(eval CompletedTestC := 0)
    $(eval FailedSuitesL := )
    $(eval FailedSuitesC := 0)
    $(eval FailedTestsL := )
    $(eval FailedTestsC := 0)
    $(eval StepC := 0)
    $(foreach _t,${$(1)},
      $(call Test-Info,Running test:${_t})
      $(call Test-Info,Test: ${_t})
      $(eval PrereqFailed := )
      $(if ${${_t}.Prereqs},
        $(call Test-Info,Running prereqs for test:${_t})
        $(call Run-Prerequisites,${_t})
      )
      $(if ${PrereqFailed},
        $(call Test-Info,Prerequisites for test ${_t} have failed -- skipping.)
      ,
        $(call Test-Info,Running test:${_t})
        $(eval TestFailed := )
        $(call ${_t})
        $(call Inc-Var,CompletedTestC)
        $(let _s,$(word 1,$(subst ., ,${_t})),
          $(if ${TestFailed},
            $(call Inc-Var,FailedTestsC)
            $(eval FailedTestsL += ${_t})
            $(eval ${_s}.FailedTestsL += ${_t})
          ,
            $(call Inc-Var,PassedTestsC)
            $(eval PassedTestsL += ${_t})
          )
        )
      )
    )
  ,
    $(call Test-Info,No tests have been listed.)
  )
  $(call Exit-Macro)
endef

_macro := Declare-Test
define _help
${_macro}
  Add a test to the list of tests and the current test suite. If the test has
  already been added a warning is issued.
  Parameters:
    1 = The name of the test <test>.
  Uses:
    SuiteN
      The name of the current test suite (<suite>).
  Modifies:
    TestL
      The test name (TestN) is appended to the list of all tests.
    TestN
      Defines the name of the test. This includes the current test suite
      context.
      This uses the form: <suite>.<test>
    <suite>.TestL
      The test name is appended to this list.

endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0),$(1))
  $(eval TestN := ${SuiteN}.$(1))
  $(if $(filter ${SuiteN}${TestN},${TestL}),
    $(call Warning,Name conflict with test ${TestN}.)
  ,
    $(eval TestL += ${TestN})
    $(eval ${SuiteN}.TestL += ${TestN})
  )
  $(call Exit-Macro)
endef

_macro := Begin-Suite
define _help
${_macro}
  Advance to the next test suite.
  Parameters:
    1 = The test suite name (<suite>).
    2 = A message describing the test suite.
  Modifies:
    SuiteL
      The suite name is appended to the list of test suites.
    SuiteN
      Is set to the name of the current test suite $$(1).
    SuiteID
      Incremented by 1.
    SuiteTestC
    SuiteTestL
    SuitePassedC
    SuitePassedL
    SuiteFailedC
    SuiteFailedL
    <suite>.TestL
      Are initialized or reset.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0),$(1) $(2))
  $(call Inc-Var,SuiteID)
  $(eval SuiteL += $(1))
  $(eval SuiteN := $(1))
  $(eval SuiteTestC := 0)
  $(eval SuiteTestL := )
  $(eval SuitePassedC := 0)
  $(eval SuitePassedL := )
  $(eval SuiteFailedC := 0)
  $(eval SuiteFailedL := )
  $(eval $(1).TestL := )
  $(call Line)
  $(call Test-Info,++++ $(1):$(2) ++++)
  $(call Exit-Macro)
endef

_macro := End-Suite
define _help
${_macro}
  End the current test suite. Record the suite test results.
  Uses:
    SuiteN  The test suite name (<suite>).
  Modifies:
    <suite>.TestC
      The number of tests in this test suite.
    <suite>.Failed
      The list of failed tests for this test suite.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0))
  $(eval PassedTestsL += ${SuitePassedL})
  $(call Add-Var,PassedTestsC,${SuitePassedC})
  $(eval FailedTestsL += ${SuiteFailedL})
  $(call Add-Var,FailedTestsC,${SuiteFailedC})
  $(foreach _n,
    CompletedTestC SuiteTestL SuitePassedC SuitePassedL SuiteFailedC SuiteFailedL,
    $(eval ${SuiteN}.${_n} := ${${_n}})
    $(call Debug,${SuiteN}.${_n} = ${${SuiteN}.${_n}})
  )
  $(call Test-Info,---- ${SuiteN} ----)
  $(call Exit-Macro)
endef

_macro := Create-Run-List
define _help
${_macro}
  Create the list of tests to be run and ensure all of the test suite segments
  for a given test list are in use. This calls Use-Segment to load a test suite.
  NOTE: This does not include prerequisite tests.
  Parameters:
    1 = The list of test suites to use. If this is empty then the CASES
        variable is used. If the CASES variable is empty then all suites in
        the directory indicated by SUITES_PATH are used. This supports the
        notation described for CASES, See help-CASES for more information.
  Modifies:
    SuiteRunL
      The list of test suites used.
    TestRunL
      The list of test cases to be run using the dot notation <suite>.<test>.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0),$(1))
  $(if $(1),
    $(eval _cases := $(1))
  ,
    $(if ${CASES},
      $(eval _cases := ${CASES})
    ,
      $(call Test-Info,Running all tests in:${SUITES_PATH})
      $(eval _cases := $(call Basenames-In,${SUITES_PATH}/*.mk))
    )
  )
  $(call Debug,Parsing:${_cases})
  $(foreach _case,${_cases},
    $(eval _s.t := $(subst ., ,${_case}))
    $(if $(word 1,${_s.t}),
      $(eval _suite := $(word 1,${_s.t}))
    ,
      $(eval _suite := ${Seg})
    )
    $(if $(wildcard ${SUITES_PATH}/${_suite}.mk),
      $(if $(filter ${_suite},${SuiteL}),
        $(call Warning,Test suite ${_suite} has already been declared.)
      ,
        $(call Use-Segment,${_suite})
        $(if $(filter ${_suite},${SuiteRunL}),
        ,
          $(eval SuiteRunL += ${_suite})
        )
      )
    ,
      $(call Signal-Error,Test suite does not exist: ${_suite})
    )
    $(if $(word 2,${_s.t}),
      $(foreach _test,$(subst +, ,$(word 2,${_s.t})),
        $(eval TestRunL += $(filter ${_suite}.${_test},${${_suite}.TestL}))
      )
    ,
      $(eval TestRunL += ${${_suite}.TestL})
    )
  )
  $(call Exit-Macro)
endef

_macro := Run-Suites
define _help
${_macro}
  Run each test suite in the suites directory. Each test suite is contained in
  its own makefile segment and must be stand alone (i.e. not dependant upon
  conditions setup by other test suites). A test suite declares a list of tests
  which are to be executed as part of the suite. The suite then runs the tests
  using Run-Tests.
  NOTE: The test suites will not be run if any goal is help.
  Parameters:
    1 = The path to the directory containing the test suites.
    2 = The list of test cases to run. If this is empty then the CASES
        variable is used. This supports the notation described for CASES, See
        help-CASES for more information.
endef
help-${_macro} := $(call _help)
ifneq ($(call Is-Goal,help%),)
define ${_macro}
  $(call Enter-Macro,$(0),$(1):$(2))
  $(call Test-Info,Displaying help -- not running test suites.)
  $(call Add-Segment-Path,$(1))
  $(call Create-Run-List,$(2))
  $(if $(call Is-Goal,help-SuiteRunL),
    $(call Debug,Building SuiteRunL help list.)
    $(call More-Help,SuiteRunL)
  )
  $(if $(call Is-Goal,help-TestRunL),
    $(call Debug,Building TestRunL help list.)
    $(call More-Help,TestRunL)
  )
  $(call Exit-Macro)
endef
else ifneq ($(call Is-Goal,test),)
define ${_macro}
  $(call Enter-Macro,$(0),$(1):$(2))
  $(call Add-Segment-Path,$(1))
  $(eval PassedSuitesC := 0)
  $(eval PassedSuitesL :=)
  $(eval FailedSuitesC := 0)
  $(eval FailedSuitesL :=)
  $(call Create-Run-List,$(2))
  $(if ${TestRunL},
    $(call Run-Tests,TestRunL),
    $(foreach _s,${SuiteRunL},
      $(if ${${_s}.FailedTestsL},
        $(eval FailedSuitesL += ${_s})
        $(call Inc-Var,FailedSuitesC)
      ,
        $(eval PassedSuitesL += ${_s})
        $(call Inc-Var,PassedSuitesC)
      )
    )
  ,
    $(call Warning,No tests in the TestRunL list.)
  )
  $(call Report-Test-Results)

  $(call Exit-Macro)
endef
endif

.PHONY: test
test:

# +++++
# Postamble
ifneq ($(call Is-Goal,help-${Seg}),)
define help-${Seg}
This make segment provides test support macros. These are designed to run
before any goals are processed and when makefile segments are loaded. The
concept is similar to that of a C preprocessor.

Definitions:
Test suite:
  A collection of tests which are closely related. A test suite should begin
  by setting up an environment in which the tests are executed. On completion
  of the tests the environment should then be torn down to avoid corrupting
  the environment for subsequent test suites or normal development. A test
  suite should NOT be dependant upon conditions created by any other test
  suite. HOWEVER, a test suite can require that other test suites pass
  before running any additional tests. A required test suite is termed a
  prerequisite or Prereq. If a Prereq test suite did not pass an error is
  reported and the test run is terminated. This helps avoid cascading failures
  in a test run. For a test suite Prereqs are specified using the variable
  <suite>.Prereqs.
  All test suites in a test run are documented using the following variables:
${help-SuiteN}
${help-SuiteID}
${help-SuitesL}
${help-PassedSuitesL}
${help-FailedSuitesL}

  Tests being run in the context of a test suite are documented using another
  set of variables which are reset at the beginning of each test suite. These
  are:
${help-SuiteTestC}
${help-SuiteTestL}
${help-SuitePassedC}
${help-SuitePassedL}
${help-SuiteFailedC}
${help-SuiteFailedL}

  Each test suite is then further documented using the variables:
<suite>.TestL
  The list of tests included in the test suite. This list is defined by the
  test suite. The variable SuiteTestL should be equal to this after the test suite
  has been run.
<suite>.TestC
  The number of tests run in the test suite.
<suite>.PassedC
  The number of tests in the test suite which passed.
<suite>.PassedL
  The list of passing tests in the test suite.
  These are identified as: <SuiteID>:<TestID>:<StepID>
<suite>.FailedC
  The number of tests in the test suite which failed.
<suite>.FailedL
  The list of failing tests in the test suite.
  These are identified as: <SuiteID>:<TestID>:<StepID>

Test or test case:
  A specific test in a test suite. Each test should begin with a setup
  and end with a teardown. A test should first verify preconditions to ensure
  the environment has been setup properly for the test and to ensure previous
  tests have not corrupted the environment. A test should not rely upon
  conditions from a previous test and should not leave any artifacts to
  clutter the test environment or confuse subsequent tests. A test should be
  able to be executed atomically. Like with a test suite, a test can require
  other test(s) pass beforehand which helps avoid cascading failures. The
  required tests are termed prerequisite or Prereq tests. For a test Prereqs
  are specified using the variable <test>.Prereqs.
  The current test is identified by the variables:
${help-TestN}
${help-TestID}

  All tests in a test run are documented using the following variables:
${help-TestsL}
${help-PassedTestsL}
${help-PassedTestsC}
${help-FailedTestsL}
${help-FailedTestsC}

Test step:
  A single step in a test. This is reset at the beginning of a test.
  This is identified using the variable:
${help-StepID}
${help-StepC}
  If a test step fails the test is considered to have failed. This is
  indicated by:
$(help-TestFailed)

Test implementation recommendations:
  For consistency and to help avoid naming conflicts each test suite should
  be contained in a single makefile segment. The name of the segment ($${Seg})
  can then be passed to Begin-Suite to serve as the suite name (SuiteN).
  SuiteN can then be used as a prefix for naming all of the included tests.
  Each test in a test suite should be contained in a macro making it possible
  for other tests to reference it. This is most important when tests have
  prerequisites which are contained in other test suites. A test suite template
  is provided in suite-template.mk to illustrate this approach.

  All test suites in a test run should be contained within the same directory
  pointed to by the command line option SUITES_PATH.

Command line options:
${help-SUITES_PATH}
$(help-CASES)

Defines the test helper macros:

${help-Test-Info}

${help-Log-Result}

${help-Verify-Result}

${help-PASS}

${help-FAIL}

${help-Set-Expected-Results}

${help-Begin-Suite}

${help-End-Suite}

${help-Begin-Test}

${help-End-Test}

${help-Expect-Vars}

${help-Expect-List}

${help-Expect-String}

${help-Oneshot-Warning-Callback}

${help-Expect-Warning}

${help-Verify-Warning}

${help-Verify-No-Warning}

${help-Oneshot-Error-Callback}

${help-Expect-Error}

${help-Verify-Error}

${help-Verify-No-Error}

${help-Display-Vars}

${help-Report-Seg-Context}

${help-Report-Test-Results}

${help-Run-Suites}

${help-Run-Tests}

${help-Run-Prerequisites}

Goals:
    test
      Use this goal to run all of the specified test suites.

endef
$(call Test-Info,help-${Seg})
endif
$(call Exit-Segment)
else # SegId exists
$(call Check-Segment-Conflicts)
endif # SegId
