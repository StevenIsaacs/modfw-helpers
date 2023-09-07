#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# This make segment is designed to test macros.mk.
#-----------------------------------------------------------------------------
# The prefix $(call This-Segment-Basename) must be unique for all files.
# +++++
# Preamble
$(call Info,+++++ $(call This-Segment-Basename) entry. +++++)
ifndef $(call This-Segment-Basename)SegId
$(call Enter-Segment)
# -----

_test := 0

#+
# Display a test message.
# Uses:
#   _test   The current test number.
# Parameters:
#   1 =     The message to display.
#-
define test-message
$(call Info,Test:$(_test)=$(strip $(1)))
endef

#+
# Advance to the next test.
# Uses:
#   _test   The current test number.
# Parameters:
#   1 =     The message to display.
#-
define next-test
$(call Inc-Var,_test)
$(call Info,$(NewLine))
$(call test-message,Test number: ${_test} $(1))
endef

#+
# Display the current context and the context for a segment.
#-
define report-seg-context
$(call test-message,SegId = ${SegId})
$(call test-message,Seg = ${Seg})
$(call test-message,SegV = ${SegV})
$(call test-message,SegF = ${SegF})
$(call test-message,${Seg}SegId = ${${Seg}SegId})
$(call test-message,${Seg}PrvSegId = ${${Seg}PrvSegId})
$(call test-message,${Seg}Seg = ${${Seg}Seg})
$(call test-message,${Seg}SegV = ${${Seg}SegV})
$(call test-message,${Seg}SegF = ${${Seg}SegF})
$(call test-message,\
Get-Segment-File:$(call Get-Segment-File,$(call This-Segment-Id)))
$(call test-message,\
Get-Segment-Basename:$(call Get-Segment-Basename,$(call This-Segment-Id)))
$(call test-message,\
Get-Segment-Var:$(call Get-Segment-Var,$(call This-Segment-Id)))
$(call test-message,\
Get-Segment-Path:$(call Get-Segment-Path,$(call This-Segment-Id)))
$(call test-message,This-Segment-Id:$(call This-Segment-Id))
$(call test-message,This-Segment-File:$(call This-Segment-File))
$(call test-message,This-Segment-Basename:$(call This-Segment-Basename))
$(call test-message,This-Segment-Var:$(call This-Segment-Var))
$(call test-message,This-Segment-Path:$(call This-Segment-Path))
$(call test-message,MAKEFILE_LIST:$(MAKEFILE_LIST))
endef

$(call next-test,Current context.)
$(call report-seg-context)

ifneq ($(call Is-Goal,test-helpers),)
$(call test-message,Testing helpers...)

$(call next-test,$(SHELL) HELPER_FUNCTIONS)
$(call test-message,helpersSegId = ${helpersSegId})
$(call test-message,HELPER_FUNCTIONS = ${HELPER_FUNCTIONS})

$(call next-test,Segment identifiers.)
$(call report-seg-context)

$(call next-test,Sticky variables.)
tv1 := tv1
tv2 := tv2
$(call test-message,STICKY_PATH = ${STICKY_PATH})
$(call test-message,StickyVars:${StickyVars})
$(call Sticky,tv1,tv1)
$(call Verbose,Sticky tv1 = ${tv1})
$(call test-message,StickyVars:${StickyVars})
$(call Sticky,tv2,tv2)
$(call Verbose,Sticky tv2 = ${tv2})
$(call test-message,StickyVars:${StickyVars})
# Should cause redefinition error.
$(call Sticky,tv2,xxx)
$(call Verbose,After second Sticky tv2 = ${tv2})
$(call test-message,StickyVars:${StickyVars})
# Redefine the previous error variable.
$(call Redefine-Sticky,tv2=xxx)
$(call Verbose,After redefined Sticky tv2 = ${tv2})
$(call test-message,StickyVars:${StickyVars})

$(foreach _v,${StickyVars},\
  $(call test-message,Var:${_v} = ${${_v}}:$(shell cat ${STICKY_PATH}/${_v})))

$(call next-test,Add-To-Manifest)
$(call Add-To-Manifest,l1,null,one)
$(call test-message,List: l1=${l1})
$(call Add-To-Manifest,l1,null,two)
$(call test-message,List: l1=${l1})
$(call Add-To-Manifest,l2,l2_e1,2.one)
$(call test-message,List: l2=${l2})
$(call test-message,Var: l2_e1=${l2_e1})
$(call Add-To-Manifest,l2,l2_e2,2.two)
$(call test-message,List: l2=${l2})
$(call test-message,Var: l2_e2=${l2_e1})
$(call test-message,Var: null=${null})

$(call next-test,Signal-Error)
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

$(call next-test,Require)
a := 1
b := 2
c := 3
$(call Require,a b c d)

$(call next-test,Must-Be-One-Of)
$(call Must-Be-One-Of,a,1 2 3)
$(call Must-Be-One-Of,a,2 3)

$(call next-test,Use-Segment)

$(call next-test,Use-Segment:Segments in the current directory.)
$(call Use-Segment,ts1)
$(call Use-Segment,ts2)
$(call next-test,Use-Segment:Segments in subdirectories.)
$(call Use-Segment,td1)
$(call Use-Segment,td2)
$(call Use-Segment,td3)
$(call next-test,Use-Segment:Multiple segments of the same name.)
$(call Use-Segment,tm1)
$(call Use-Segment,test/d2/tm1)
$(call next-test,Use-Segment:A segment in a subdirectory.)
$(call Use-Segment,sd3/tsd3)
$(call next-test,Use-Segment:Does not exist.)
$(call Use-Segment,te1)
$(call next-test,Use-Segment:Full segment path (no find).)
$(call Use-Segment,test/ts3.mk)

$(call next-test,Test overridable variables.)
$(call test-message,Declaring ov1 as overridable.)
$(call Overridable,ov1,ov1_val)
$(call test-message,ov1:$(ov1))
ov2 := ov2_original
$(call Overridable,ov2,ov2_val)
$(call test-message,ov2:$(ov2))
# Should trigger an error message because 0v2 is already declared.
$(call Overridable,ov2,ov2_new_val)
$(call test-message,ov2:$(ov2))
$(call test-message,Overridables: $(OverridableVars))

$(call next-test,Confirmations)
_r := $(call Confirm,Enter positive response.,y)
$(call test-message,Response = "${_r}")
ifeq (${_r},y)
$(call test-message,Confirm = (positive))
else
$(call test-message,Confirm = (negative))
endif
_r := $(call Confirm,Enter negative response.,y)
$(call test-message,Response = ${_r})
ifeq (${_r},y)
$(call test-message,Confirm = (positive))
else
$(call test-message,Confirm = (negative))
endif
$(call Pause)

test-helpers: display-errors display-messages
> ${MAKE} tv1=subtv1 tv3=subtv3 test-submake

else ifneq ($(call Is-Goal,test-submake),)
$(call test-message,Testing sub-make...)
$(call test-message,Before:tv1=${tv1} tv2=${tv2} tv3=${tv3})
$(call next-test,Sticky variables in a sub-make.)
$(call test-message,Cannot set sticky variables in a sub-make.)
$(call test-message,StickyVars:${StickyVars})
# tv1 should have the value from the command line but not saved.
$(call Sticky,tv1,tv1)
$(call Verbose,Sticky tv1 = ${tv1})
$(call test-message,StickyVars:${StickyVars})
# tv2 should be the saved value.
$(call Sticky,tv2,tv2)
$(call Verbose,Sticky tv2 = ${tv2})
$(call test-message,StickyVars:${StickyVars})
$(call test-message,tv3 should not be saved in the sticky directory.)
$(call Sticky,tv3,tv3)
$(call Verbose,Sticky tv3 = ${tv3})
$(call test-message,StickyVars:${StickyVars})
# Should cause redefinition error.
$(call Sticky,tv2,xxx)
$(call Verbose,After second Sticky tv2 = ${tv2})
$(call test-message,StickyVars:${StickyVars})
$(call test-message,After:tv1=${tv1} tv2=${tv2} tv3=${tv3})
$(foreach _v,${StickyVars},\
  $(call test-message,Var vs file:${_v} = ${${_v}}:$(shell cat ${STICKY_PATH}/${_v})))

test-submake: display-errors display-messages

# endif # Goal is test-submake
endif # Goal is test-helpers

# +++++
# Postamble
ifneq ($(call Is-Goal,help-${Seg}),)
define help_${SegV}_msg
This make segment tests the macros in helpers.mk.
endef
$(call test-message,help_${SegV}_msg = ${help_${SegV}_msg})
endif
$(call Exit-Segment)
$(call next-test,Restored context.)
$(call report-seg-context)
else # SegId exists
$(call next-test,ID exists context.)
$(call report-seg-context)
$(call Check-Segment-Conflicts)
endif # SegId
$(call Info,----- $(call This-Segment-Basename) exit. -----)
