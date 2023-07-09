#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# This make segment is designed to test macros.mk.
#-----------------------------------------------------------------------------
#+
ifndef _tm_id
_tm_id := $(call This-Segment-Id)
_tm_seg := $(call This-Segment-File)
_tm_name := $(call This-Segment-Name)
_tm_prv_id := ${SegId}
$(eval $(call Set-Segment-Context,${_tm_id}))

$(call Verbose,Make segment: $(call Segment-File,${_tm_id}))

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

ifneq ($(call Is-Goal,test-macros),)

$(call next-test,Segment identifiers.)
$(call test-message,This-Segment-Id:$(call This-Segment-Id))
$(call test-message,This-Segment:$(call This-Segment-File))
$(call test-message,This-Segment-Name:$(call This-Segment-Name))
$(call test-message,This-Segment-Path:$(call This-Segment-Path))
$(call test-message,segment:$(call Segment-File,${_tm_id}))
$(call test-message,Segment-Path:$(call Segment-Path,${_tm_id}))
$(call test-message,Segment-Name:$(call Segment-Name,${_tm_id}))

$(call next-test,Current context.)
$(call test-message,SegId:$(SegId))
$(call test-message,Seg:$(Seg))
$(call test-message,SegN:$(SegN))

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

test-macros: display-errors display-messages
endif

ifneq ($(call Is-Goal,help-${_tm_seg}),)
$(info Help message variable: help_${_tm_name}_msg)
define help_${_tm_name}_msg
This make segment tests the macros in macros.mk.
endef
export help_${_tm_name}_msg
help-${_tm_seg}:
> echo "$$help_${_tm_name}_msg" | less
endif
$(eval $(call Set-Segment-Context,${_tm_prv_id}))

else
  $(call Add-Message,${_tm_seg} has already been included)
endif
