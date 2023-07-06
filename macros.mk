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
  $(call signal-error,Unable to identify platform)
endif
$(info Running on: ${Platform})

#+
# See help-macros
#-
this-segment = \
  $(basename $(notdir $(word $(words ${MAKEFILE_LIST}),${MAKEFILE_LIST})))

#+
# See help-macros
#-
this-segment-path = \
  $(basename $(dir $(word $(words ${MAKEFILE_LIST}),${MAKEFILE_LIST})))

#+
# See help-macros
#-
is-goal = $(filter $(1),$(Goals))

#+
# See help-macros
#-
define newline
nlnl
endef

define add-message
  $(eval MsgList += ${newline}$(call this-segment):$(1))
  $(eval Messages = yes)
endef

#+
# See help-macros
#-
ifdef VERBOSE
define verbose
    $(info verbose:$(1))
    $(call add-message,$(1))
endef
# Prepend to recipe lines to echo commands being executed.
V := @
endif

#+
# See help-macros
#-
define add-to-manifest
  $(call verbose,Adding $(3) to $(1))
  $(call verbose,Var: $(2))
  $(eval $(2) = $(3))
  $(call verbose,$(2)=$(3))
  $(eval $(1) += $(3))
endef

#+
# See help-macros
#-
define signal-error
  $(eval ErrorMessages += ${newline}$(call this-segment):$(1))
  $(eval Errors = yes)
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

#+
# See help-macros
#-
define require
  $(call verbose,Required in: $(1))
  $(foreach v,$(2),$(call _require-this,$(v), $(1)))
endef

#+
# See help-macros
#-
define must-be-one-of
  $(if $(findstring ${$(1)},$(2)),\
    $(call verbose,$(1) = ${$(1)} and is a valid option),\
    $(call signal-error,Variable $(1) must equal one of: $(2))\
  )
endef

#+
# See help-macros
#-
HELPERS_PATH ?= $(call this-segment-path)
STICKY_PATH ?= /tmp/sticky
define sticky
  $(call verbose Sticky variable: ${1})
  $(eval $(1)=$(shell ${HELPERS_PATH}/sticky.sh $(1)=${$(1)} ${STICKY_PATH} $(2)))
endef

#+
# See help-macros
#+
define basenames-in
  $(foreach f,$(wildcard $(1)),$(basename $(notdir ${f})))
endef

#+
# See help-macros
#+
define directories-in
  $(foreach d,$(shell find $(1) -mindepth 1 -maxdepth 1 -type d),\
  $(notdir ${d}))
endef

#+
# See help-macros
#-
define increment
  $(eval $(1):=$(shell expr $($(1)) + 1))
endef

#+
# See help-macros
#-
display-messages:
> @if [ -n '${MsgList}' ]; then \
    m="${MsgList}";printf "Messages:$${m//${newline}/\\n}" | less;\
  fi

display-errors:
> @if [ -n '${ErrorMessages}' ]; then \
    m="${ErrorMessages}";printf "Errors:$${m//${newline}/\\n}" | less;\
  fi

#+
# See help-macros
#-
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

Defines the makefile helper macros. These are:

is-goal
    Returns the goal if it is a member of the list of goals.
    Parameters:
        1 = The goal to check.

this-segment
    Returns the basename of the most recently included makefile segment.

this-segment-path
    Returns the directory of the most recently included makefile segment.

verbose
    Displays the message if VERBOSE has been defined.
    Parameters:
        1 = The message to display.

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
    by the display-messages goal. All verbose messages are automatically added
    to the message list.
    NOTE: This is NOT intended to be used as part of a rule.
    Parameters:
        1 = The message.

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
        $(call sticky,<var>=<value>)
            Sets the sticky variable equal to <value>. The <value> is saved
            for retrieval at a later time.
        $(call sticky,<var>[=])
            Restores the previously saved <value>.
        $(call sticky,<var>[=],<default>)
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

increment
    Increment the value of a variable by 1.
    Parameters:
        1 = The name of the variable to increment.

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
