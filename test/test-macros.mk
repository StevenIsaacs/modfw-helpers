#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# This make segment is designed to test macros.mk.
#-----------------------------------------------------------------------------
# The prefix tm must be unique for all files.
# +++++
# Preamble
$(call Add-Message,+++++ test-macros entry. +++++)
ifndef tm_id
$(call Enter-Segment,tm)
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
$(call Add-Message,Test:$(_test)=$(1))
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
$(call Add-Message,$(NewLine))
$(call test-message,Test number: ${_test} $(1))
endef

#+
# Display the current context and the context for a segment.
# Parameters:
#  1 = The prefix for the segment.
#-
define report-seg-context
$(call test-message,SegId = $(SegId))
$(call test-message,Seg = $(Seg))
$(call test-message,SegN = $(SegN))
$(call test-message,SegF = $(SegF))
$(call test-message,tm_id = ${$(1)_id})
$(call test-message,tm_prv_id = ${$(1)_prv_id})
$(call test-message,tm_seg = ${$(1)_seg})
$(call test-message,tm_name = ${$(1)_name})
$(call test-message,tm_file = ${$(1)_file})
$(call test-message,\
 Get-Segment-File:$(call Get-Segment-File,$(call This-Segment-Id)))
$(call test-message,\
 Get-Segment-Basename:$(call Get-Segment-Basename,$(call This-Segment-Id)))
$(call test-message,\
 Get-Segment-Name:$(call Get-Segment-Name,$(call This-Segment-Id)))
$(call test-message,\
 Get-Segment-Path:$(call Get-Segment-Path,$(call This-Segment-Id)))
$(call test-message,This-Segment-Id:$(call This-Segment-Id))
$(call test-message,This-Segment-File:$(call This-Segment-File))
$(call test-message,This-Segment-Basename:$(call This-Segment-Basename))
$(call test-message,This-Segment-Name:$(call This-Segment-Name))
$(call test-message,This-Segment-Path:$(call This-Segment-Path))
$(call test-message,MAKEFILE_LIST:$(MAKEFILE_LIST))
endef

ifneq ($(call Is-Goal,test-macros),)

$(call next-test,HELPERS_PATH)
$(call test-message,macros_id = ${macros_id})
$(call test-message,HELPERS_PATH = ${HELPERS_PATH})

$(call next-test,Segment identifiers.)
$(call report-seg-context,tm)

$(call next-test,Sticky variables.)
tv1 := tv1
tv2 := tv2
$(call test-message,STICKY_PATH = ${STICKY_PATH})
$(call test-message,StickyVars:${StickyVars})
$(call Sticky,tv1,tv1)
$(call test-message,StickyVars:${StickyVars})
$(call Sticky,tv2,tv2)
$(call test-message,StickyVars:${StickyVars})
# Should cause redefinition error.
$(call Sticky,tv2,xxx)
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
$(call Require,test,a b c d)

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
$(call Use-Segment,tm2)
$(call next-test,Use-Segment:A segment in a subdirectory.)
$(call Use-Segment,sd3/tsd3)
$(call next-test,Use-Segment:Does not exist.)
$(call Use-Segment,te1)

test-macros: display-errors display-messages
endif # Goal is test-macros

# +++++
# Postamble
ifneq ($(call Is-Goal,help-${tm_seg}),)
define help_${tm_name}_msg
This make segment tests the macros in macros.mk.
endef
$(call test-message,help_${tm_name}_msg = ${help_${tm_name}_msg})
endif
$(call Exit-Segment,tm)
$(call next-test,Restored context.)
$(call report-seg-context,tm)
else # tm_id exists
$(call next-test,ID exists context.)
$(call report-seg-context,tm)
$(call Check-Segment-Conflicts,tm)
endif # tm_id
$(call Add-Message,----- test-macros exit. -----)
