#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# This make segment is designed to test macros.mk.
#-----------------------------------------------------------------------------
#+
_n := $(call this-segment)
ifndef $(_n)
${_n} := ${_n}
_m := $(subst -,_,$(_n))
_${_m}MkPath = $(call this-segment-path)
_${_m}Name = _${_m}
$(call verbose,Make segment: ${_${_m}MkPath})

_test := 0

#+
# Display a test message.
# Uses:
#   _test   The current test number.
# Parameters:
#   1 =     The message to display.
#-
define test-message
$(info Test:$(_test)=$(1))
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
$(call test-message,Test number: ${_test} $(1))
endef

ifneq ($(call is-goal,test-macros),)
$(call next-test,Segment identifiers.)
$(call test-message,Segment: $($(_n)))
$(call test-message,Path: $(_${_m}MkPath))
$(call test-message,Name: $(_${_m}Name))

$(call next-test,add-to-manifest)
$(call add-to-manifest,l1,null,one)
$(call test-message,List: l1=$(l1))
$(call add-to-manifest,l1,null,two)
$(call test-message,List: l1=$(l1))
$(call add-to-manifest,l2,l2_e1,2.one)
$(call test-message,List: l2=$(l2))
$(call test-message,Var: l2_e1=$(l2_e1))
$(call add-to-manifest,l2,l2_e2,2.two)
$(call test-message,List: l2=$(l2))
$(call test-message,Var: l2_e2=$(l2_e1))
$(call test-message,Var: null=$(null))

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

ifneq ($(call is-goal,help-${_n}),)
$(info Help message variable: help_${_m}_msg)
define help_${_m}_msg
This make segment tests the macros in macros.mk.
endef
export help_${_m}_msg
help-${_n}:
> @echo "$$help_${_m}_msg" | less
endif

else
  $(info ${_n} has already been included)
endif
