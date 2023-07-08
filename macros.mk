#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Helper macros for makefiles.
#----------------------------------------------------------------------------
# Changing the prefix because some editors, like vscode, don't handle tabs
# in make files very well. This also slightly improves readability.
.RECIPEPREFIX := >
SHELL = /bin/bash

$(info Goal: ${MAKECMDGOALS})
ifeq (${MAKECMDGOALS},)
  $(info No goal was specified.)
  .DEFAULT_GOAL := $(DefaultGoal)
endif

Goals = ${.DEFAULT_GOAL} ${MAKECMDGOALS}
$(info Goals: ${Goals})

# Special target to force another target.
FORCE:

# Some behavior depends upon which platform.
ifeq ($(shell grep WSL /proc/version > /dev/null; echo $$?),0)
  Platform = Microsoft
else ifeq ($(shell echo $$(expr substr $$(uname -s) 1 5)),Linux)
  Platform = Linux
else ifeq ($(shell uname),Darwin)
# Detecting OS X is untested.
  Platform = OsX
else
  $(error Unable to identify platform)
endif
$(info Running on: ${Platform})

define increment
  $(eval $(1):=$(shell expr $($(1)) + 1))
endef

last-segment-id = $(words ${MAKEFILE_LIST})

last-segment = \
  $(basename $(notdir $(word $(words ${MAKEFILE_LIST}),${MAKEFILE_LIST})))

last-segment-name = \
  $(subst -,_,$(call last-segment))

last-segment-path = \
  $(dir $(word $(words ${MAKEFILE_LIST}),${MAKEFILE_LIST}))

segment = \
  $(basename $(notdir $(word $(1),${MAKEFILE_LIST})))

segment-name = \
  $(subst -,_,$(call segment,$(1)))

segment-path = \
  $(dir $(word $(1),${MAKEFILE_LIST}))

define set-segment-context
  SegId := $(1)
  Seg := $(call segment,$(1))
  SegN := $(call segment-name,$(1))
endef

is-goal = $(filter $(1),$(Goals))

define newline
nlnl
endef

define add-message
  $(eval MsgList += ${newline}${Seg}:$(1))
  $(info ${Seg}:$(1))
  $(eval Messages = yes)
endef

ifdef VERBOSE
define verbose
    $(call add-message,verbose:$(1))
endef
# Prepend to recipe lines to echo commands being executed.
V := @
endif

define add-to-manifest
  $(call verbose,Adding $(3) to $(1))
  $(call verbose,Var: $(2))
  $(eval $(2) = $(3))
  $(call verbose,$(2)=$(3))
  $(eval $(1) += $(3))
endef

define signal-error
  $(eval ErrorMessages += ${newline}${Seg}:$(1))
  $(eval Errors = yes)
  $(warning Error:${Seg}:$(1))
endef

#+
# This private macro is used to verify a single variable exists.
# If the variable is empty then an error message is appended to ErrorMessages.
# Parameters:
#   1 = The name of the variable.
#   2 = The module in which it is required.
#-
define _require-this
  $(call verbose,Requiring: $(1))
  $(if $(findstring undefined,$(flavor ${1})),\
    $(warning Variable $(1) is not defined); \
    $(call signal-error,Variable $(1) must be defined in: $(2))
  )
endef

define require
  $(call verbose,Required in: $(1))
  $(foreach v,$(2),$(call _require-this,$(v), $(1)))
endef

define must-be-one-of
  $(if $(findstring ${$(1)},$(2)),\
    $(call verbose,$(1) = ${$(1)} and is a valid option),\
    $(call signal-error,Variable $(1) must equal one of: $(2))\
  )
endef

HELPERS_PATH ?= $(call last-segment-path)
STICKY_PATH ?= /tmp/sticky
define sticky
  $(call verbose Sticky variable: ${1})
  $(eval $(1)=$(shell ${HELPERS_PATH}/sticky.sh $(1)=${$(1)} ${STICKY_PATH} $(2)))
endef

define basenames-in
  $(foreach f,$(wildcard $(1)),$(basename $(notdir ${f})))
endef

define directories-in
  $(foreach d,$(shell find $(1) -mindepth 1 -maxdepth 1 -type d),\
  $(notdir ${d}))
endef

# Context defaults to the top makefile.
$(eval $(call set-segment-context,1))

display-messages:
> @if [ -n '${MsgList}' ]; then \
    m="${MsgList}";printf "Messages:$${m//${newline}/\\n}" | less;\
  fi

display-errors:
> @if [ -n '${ErrorMessages}' ]; then \
    m="${ErrorMessages}";printf "Errors:$${m//${newline}/\\n}" | less;\
  fi

show-%:
> @echo '$*=$($*)'

ifneq ($(findstring help-macros,${Goals}),)
define HelpMacrosMsg
Make segment: macros.mk

Defines make variables to simplify editing rules in some editors which
don't handle tab characters very well. Also to enable some bash specific
features.
.RECIPEPREFIX=${.RECIPEPREFIX}
SHELL=${SHELL}

Message prefix variable - Seg:
    The variable named Segment is used to prefix all messages issued using
    add-message, verbose and, signal-error. The calling module is expected
    to set this variable. e.g. Seg := <seg>.
    NOTE that the immediate form of the assignment (:=) must be used.

Preamble and postamble
    Makefile segments should use the standard preamble and postamble to avoid
    inclusion of the same file more than once and to use standardized ID
    variables.

    Preamble:
        To avoid name conflicts a unique prefix is required. In this example
        the unique prefix is indicated by <u>.

        $.ifndef <u>_id
        <u>_id := $$(call last-segment-id)
        <u>_seg := $$(call last-segment)
        <u>_name := $$(call last-segment-name)
        <u>_prv_id := $${SegId}
        $$(eval $$(call set-segment-context,$${<u>_id}))

        $$(call verbose,Make segment: $$(call segment,${<u>_id}))

        ....Make segment body....

    Postamble:

        $$(eval $$(call set-segment-context,$${<u>_prv_id}))

        $.else
        $$(call add-message,$${<u>_seg} has already been included)
        $.endif

Defines the helper macros:

increment
    Increment the value of a variable by 1.
    Parameters:
        1 = The name of the variable to increment.

is-goal
    Returns the goal if it is a member of the list of goals.
    Parameters:
        1 = The goal to check.

last-segment-id
    Returns the ID of the most recently included makefile segment.

last-segment
    Returns the basename of the most recently included makefile segment.

last-segment-path
    Returns the directory of the most recently included makefile segment.

segment
    Returns the basename of the makefile segment corresponding to ID.
    Parameters:
        1 = ID of the segment.

segment-name
    Returns the name of the makefile segment corresponding to ID.
    Parameters:
        1 = ID of the segment.

segment-path
    Returns the path of the makefile segment corresponding to ID.
    Parameters:
        1 = ID of the segment.

set-segment-context
    Sets the context for the makefile segment corresponding to ID.
    Among other things this is needed in order to have correct prefixes
    prepended to messages emitted by a makefile segment.
    The context defaults to the top makefile (ID = 1).
    Parameters:
        1 = ID of the segment.
    Sets:
        SegId   The makefile segment ID for the new context.
        Seg     The makefile segment basename for the new context.
        SegN    The makefile segment name for the new context.

add-to-manifest
    Add an item to a manifest variable.
    Parameters:
        1 = The list to add to.
        2 = The optional variable to declare for the value. Use "null" to skip
            declaring a new variable.
        3 = The value to add to the list.

newline
    Use this macro to insert new lines into multiline messages.

add-message
    Use this macro to add a message to a list of messages to be displayed
    by the display-messages goal.
    Messages are prefixed with the variable Segment which is set by the
    calling segment.
    NOTE: This is NOT intended to be used as part of a rule.
    Parameters:
        1 = The message.

verbose
    Displays the message if VERBOSE has been defined. All verbose messages are
    automatically added to the message list.
    Parameters:
        1 = The message to display.

signal-error
    Use this macro to issue an error message as a warning and signal a
    delayed error exit. The messages can be displayed using the display-errors
    goal.
    NOTE: This is NOT intended to be used as part of a rule.
    Parameters:
        1 = The error message.

require
    Use this macro to verify variables are set.
    Parameters:
        1 = The make file segment.
        2 = A list of required variables.

must-be-one-of
    Verify a variable has a valid value. If not then issue a warning.
    Parameters:
        1 = Variable name
        2 = List of valid values.

sticky
    A sticky variable is persistent and needs to be defined on the command line
    at least once or have a default value as an argument.
    Uses sticky.sh to make a variable sticky. If the variable has not been
    defined when this macro is called then the previous value is used. Defining
    the variable will overwrite the previous sticky value.
    WARNING: The variable must be defined at least once.
    Variables used:
        HELPERS_PATH=${HELPERS_PATH}
            The path to the helpers directory. Defaults to the directory
            containing this makefile segment.
        STICKY_PATH=${STICKY_PATH}
            Where to store the sticky variable values. Defaults to /tmp/sticky.
    Parameters:
        1 = Variable name[=<value>]
        2 = Optional default value.
    Returns:
        The variable value.
    Examples:
        $$(call sticky,<var>=<value>)
            Sets the sticky variable equal to <value>. The <value> is saved
            for retrieval at a later time.
        $$(call sticky,<var>[=])
            Restores the previously saved <value>.
        $$(call sticky,<var>[=],<default>)
            Restores the previously saved <value> or sets <var> equal to
            <default>. The variable is not saved in this case.

basenames-in
    Get the basenames of all the files in a directory matching a glob pattern.
    Parameters:
        1 = The glob pattern including path.

directories-in
    Get a list of directories in a directory. The path is stripped.
    Parameters:
        1 = The path to the directory.

Special targets:
show-%
    Display the value of any variable.

display-messages
    This target displays a list of accumulated messages if defined.

display-errors
    This target displays a list of accumulated errors if defined.

Defines:
    Platform = $(Platform)
        The platform (OS) on which make is running. This can be one of:
        Microsoft, Linux, or OsX.
endef

export HelpMacrosMsg
help-macros:
> @echo "$$HelpMacrosMsg" | less

endif
