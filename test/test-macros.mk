#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# This make segment is designed to test macros.mk.
#-----------------------------------------------------------------------------
#+
ifndef _tm_id
_tm_id := $(call this-segment-id)
_tm_seg := $(call this-segment)
_tm_name := $(call this-segment-name)
_tm_prv_id := ${SegId}
$(eval $(call set-segment-context,${_tm_id}))

$(call verbose,Make segment: $(call segment,${_tm_id}))

_test := 0

#+
# Display a test message.
# Uses:
#   _test   The current test number.
# Parameters:
#   1 =     The message to display.
#-
define test-message
$(call add-message,Test:$(_test)=$(1))
endef

#+
# Advance to the next test.
# Uses:
#   _test   The current test number.
# Parameters:
#   1 =     The message to display.
#-
define next-test
$(call increment,_test)
$(call test-message,${newline}${newline}Test number: ${_test} $(1))
endef

ifneq ($(call is-goal,test-macros),)

$(call next-test,Segment identifiers.)
$(call test-message,this-segment-id:$(call this-segment-id))
$(call test-message,this-segment:$(call this-segment))
$(call test-message,this-segment-name:$(call this-segment-name))
$(call test-message,this-segment-path:$(call this-segment-path))
$(call test-message,segment:$(call segment,${_tm_id}))
$(call test-message,segment-path:$(call segment-path,${_tm_id}))
$(call test-message,segment-name:$(call segment-name,${_tm_id}))

$(call next-test,Current context.)
$(call test-message,SegId:$(SegId))
$(call test-message,Seg:$(Seg))
$(call test-message,SegN:$(SegN))

$(call next-test,add-to-manifest)
$(call add-to-manifest,l1,null,one)
$(call test-message,List: l1=${l1})
$(call add-to-manifest,l1,null,two)
$(call test-message,List: l1=${l1})
$(call add-to-manifest,l2,l2_e1,2.one)
$(call test-message,List: l2=${l2})
$(call test-message,Var: l2_e1=${l2_e1})
$(call add-to-manifest,l2,l2_e2,2.two)
$(call test-message,List: l2=${l2})
$(call test-message,Var: l2_e2=${l2_e1})
$(call test-message,Var: null=${null})

$(call next-test,signal-error)
$(call signal-error,Error one.)
$(info ErrorMessages: ${ErrorMessages})
$(call signal-error,Error two.)
$(info ErrorMessages: ${ErrorMessages})
$(call signal-error,Error three.)
$(info ErrorMessages: ${ErrorMessages})
$(call signal-error,Error four.)
$(info ErrorMessages: ${ErrorMessages})
$(call signal-error,Error five.)
$(info ErrorMessages: ${ErrorMessages})
$(call show-errors)

$(call next-test,require)
a := 1
b := 2
c := 3
$(call require,test,a b c d)

$(call next-test,must-be-one-of)

$(call must-be-one-of,a,1 2 3)
$(call must-be-one-of,a,2 3)

test-macros: display-errors display-messages
endif

ifneq ($(call is-goal,help-${_tm_seg}),)
$(info Help message variable: help_${_tm_name}_msg)
define help_${_tm_name}_msg
This make segment tests the macros in macros.mk.
endef
export help_${_tm_name}_msg
help-${_tm_seg}:
> echo "$$help_${_tm_name}_msg" | less
endif
$(eval $(call set-segment-context,${_tm_prv_id}))

else
  $(call add-message,${_tm_seg} has already been included)
endif
