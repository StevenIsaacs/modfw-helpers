#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Helper macros for makefiles.
#----------------------------------------------------------------------------
# Changing the prefix because some editors, like vscode, don't handle tabs
# in make files very well. This also slightly improves readability.
.RECIPEPREFIX := >
SHELL = /bin/bash

$(info Goal: ${MAKECMDGOALS})
ifeq (${MAKECMDGOALS},)
  $(info No goal was specified -- defaulting to: ${DefaultGoal}.)
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

NewLine = nlnl

define Add-Message
  $(eval MsgList += ${NewLine}${Seg}:$(1))
  $(info ${Seg}:$(1))
  $(eval Messages = yes)
endef

ifdef VERBOSE
define Verbose
    $(call Add-Message,Verbose:$(1))
endef
# Prepend to recipe lines to echo commands being executed.
V := @
endif

define Signal-Error
  $(eval ErrorList += ${NewLine}${Seg}:$(1))
  $(eval MsgList += ${NewLine}${Seg}:$(1))
  $(eval Errors = yes)
  $(warning Error:${Seg}:$(1))
endef

define Inc-Var
  $(eval $(1):=$(shell expr $($(1)) + 1))
endef

This-Segment-Id = $(words ${MAKEFILE_LIST})

This-Segment-File = \
  $(basename $(notdir $(word $(words ${MAKEFILE_LIST}),${MAKEFILE_LIST})))

This-Segment-Name = \
  $(subst -,_,$(call This-Segment-File))

This-Segment-Path = \
  $(realpath $(dir $(word $(words ${MAKEFILE_LIST}),${MAKEFILE_LIST})))

Segment-File = \
  $(basename $(notdir $(word $(1),${MAKEFILE_LIST})))

Segment-Name = \
  $(subst -,_,$(call Segment-File,$(1)))

Segment-Path = \
  $(realpath $(dir $(word $(1),${MAKEFILE_LIST})))

define Set-Segment-Context
  SegId := $(1)
  Seg := $(call Segment-File,$(1))
  SegN := $(call Segment-Name,$(1))
endef

SegPaths :=  $(call Segment-Path,1)

define Add-Segment-Path
  $(eval SegPaths += $(1))
  $(call Verbose,Added path(s):$(1))
endef

define Find-Segment
  $(eval $(2) := )
  $(call Verbose,Segment paths:${SegPaths} $(call Segment-Path,${SegId}))
  $(foreach _p,${SegPaths} $(call Segment-Path,${SegId}),\
    $(if $(wildcard ${_p}/$(1).mk),\
      $(eval $(2) := ${_p}/$(1).mk),
      $(call Verbose,${_p}/$(1).mk not found.)))
  $(call Verbose,Found segment:${$(2)})
endef

define Use-Segment
  $(call Find-Segment,$(1),_s)
  $(call Verbose,Using segment:${_s})
  $(eval include ${_s})
endef

Is-Goal = $(filter $(1),${Goals})

define Add-To-Manifest
  $(call Verbose,Adding $(3) to $(1))
  $(call Verbose,Var: $(2))
  $(eval $(2) = $(3))
  $(call Verbose,$(2)=$(3))
  $(eval $(1) += $(3))
endef

#+
# This private macro is used to verify a single variable exists.
# If the variable is empty then an error message is appended to ErrorList.
# Parameters:
#   1 = The name of the variable.
#   2 = The module in which it is required.
#-
define _require-this
  $(call Verbose,Requiring: $(1))
  $(if $(findstring undefined,$(flavor ${1})),\
    $(warning Variable $(1) is not defined); \
    $(call Signal-Error,Variable $(1) must be defined in: $(2))
  )
endef

define Require
  $(call Verbose,Required in: $(1))
  $(foreach v,$(2),$(call _require-this,$(v), $(1)))
endef

define Must-Be-One-Of
  $(if $(findstring ${$(1)},$(2)),\
    $(call Verbose,$(1) = ${$(1)} and is a valid option),\
    $(call Signal-Error,Variable $(1) must equal one of: $(2))\
  )
endef

HELPERS_PATH ?= $(call This-Segment-Path)
STICKY_PATH ?= /tmp/sticky
define Sticky
  $(call Verbose Sticky variable: ${1})
  $(eval $(1)=$(shell ${HELPERS_PATH}/sticky.sh $(1)=${$(1)} ${STICKY_PATH} $(2)))
endef

define Basenames-In
  $(foreach f,$(wildcard $(1)),$(basename $(notdir ${f})))
endef

define Directories-In
  $(foreach d,$(shell find $(1) -mindepth 1 -maxdepth 1 -type d),\
  $(notdir ${d}))
endef

# Context defaults to the top makefile.
$(eval $(call Set-Segment-Context,1))

display-messages:
> @if [ -n '${MsgList}' ]; then \
    m="${MsgList}";printf "Messages:$${m//${NewLine}/\\n}" | less;\
  fi

display-errors:
> @if [ -n '${ErrorList}' ]; then \
    m="${ErrorList}";printf "Errors:$${m//${NewLine}/\\n}" | less;\
  fi

show-%:
> @echo '$*=$($*)'

ifneq ($(findstring help-macros,${Goals}),)
define HelpMacrosMsg
Make segment: macros.mk

Sets make variables to simplify editing rules in some editors which
don't handle tab characters very well. Also to enable some bash specific
features.
.RECIPEPREFIX=${.RECIPEPREFIX}
SHELL=${SHELL}

Preamble and postamble
    Makefile segments should use the standard preamble and postamble to avoid
    inclusion of the same file more than once and to use standardized ID
    variables.

    Preamble:
        To avoid name conflicts a unique prefix is required. In this example
        the unique prefix is indicated by <u>.

        $.ifndef <u>_id
        <u>_id := $$(call This-Segment-Id)
        <u>_seg := $$(call This-Segment-File)
        <u>_name := $$(call This-Segment-Name)
        <u>_prv_id := $${SegId}
        $$(eval $$(call Set-Segment-Context,$${<u>_id}))

        $$(call Verbose,Make segment: $$(call Segment-File,$${<u>_id}))

        ....Make segment body....

    Postamble:

        $$(eval $$(call Set-Segment-Context,$${<u>_prv_id}))

        $.else
        $$(call Add-Message,$${<u>_seg} has already been included)
        $.endif

    A template for new make segments is provided in seg-template.mk.

Defines the helper macros:

Inc-Var
    Increment the value of a variable by 1.
    Parameters:
        1 = The name of the variable to Inc-Var.

Is-Goal
    Returns the goal if it is a member of the list of goals.
    Parameters:
        1 = The goal to check.

This-Segment-Id
    Returns the ID of the most recently included makefile segment.

This-Segment-File
    Returns the basename of the most recently included makefile segment.

This-Segment-Name
    Returns the name of the most recently included makefile segment.

This-Segment-Path
    Returns the directory of the most recently included makefile segment.

Segment-File
    Returns the basename of the makefile segment corresponding to ID.
    Parameters:
        1 = ID of the segment.

Segment-Name
    Returns the name of the makefile segment corresponding to ID.
    Parameters:
        1 = ID of the segment.

Segment-Path
    Returns the path of the makefile segment corresponding to ID.
    Parameters:
        1 = ID of the segment.

Set-Segment-Context
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

SegPaths = ${SegPaths}
    The list of paths to search to find or use a segment.

Add-Segment-Path
    Add one or more path(s) to the list of segment search paths (SegPaths).
    Parameters:
        1 = The path(s) to add.

Find-Segment
    Search a list of directories for a segment and save its path in a variable.
    The segment can exist in multiple locations and only the last one in the
    list will be found. If the segment is not found in any of the directories
    then the current segment directory (Segment-Path) is searched.
    If the segment cannot be found an error message is added to the error list.
    Parameters:
        1 = The segment to find.
        2 = The name of the variable to store the result in.

Use-Segment
    Use Find-Segment to search a list of directories for a segment and load it
    if it exists. The segment can exist in multiple locations and only the last
    one in the list will be loaded. If the segment is not found in any of the
    directories then the segment is loaded from the current segment directory
    (Segment-Path).
    If the segment cannot be found an error message is added to the error list.
    Parameters:
        1 = The segment to load.

Add-To-Manifest
    Add an item to a manifest variable.
    Parameters:
        1 = The list to add to.
        2 = The optional variable to declare for the value. Use "null" to skip
            declaring a new variable.
        3 = The value to add to the list.

NewLine
    Use this macro to insert new lines into multiline messages.

Add-Message
    Use this macro to add a message to a list of messages to be displayed
    by the display-messages goal.
    Messages are prefixed with the variable Segment which is set by the
    calling segment.
    NOTE: This is NOT intended to be used as part of a rule.
    Parameters:
        1 = The message.

Verbose
    Displays the message if VERBOSE has been defined. All verbose messages are
    automatically added to the message list.
    Parameters:
        1 = The message to display.

Signal-Error
    Use this macro to issue an error message as a warning and signal a
    delayed error exit. The messages can be displayed using the display-errors
    goal.
    NOTE: This is NOT intended to be used as part of a rule.
    Parameters:
        1 = The error message.

Require
    Use this macro to verify variables are set.
    Parameters:
        1 = The make file segment.
        2 = A list of required variables.

Must-Be-One-Of
    Verify a variable has a valid value. If not then issue a warning.
    Parameters:
        1 = Variable name
        2 = List of valid values.

Sticky
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
        $$(call Sticky,<var>=<value>)
            Sets the sticky variable equal to <value>. The <value> is saved
            for retrieval at a later time.
        $$(call Sticky,<var>[=])
            Restores the previously saved <value>.
        $$(call Sticky,<var>[=],<default>)
            Restores the previously saved <value> or sets <var> equal to
            <default>. The variable is not saved in this case.

Basenames-In
    Get the basenames of all the files in a directory matching a glob pattern.
    Parameters:
        1 = The glob pattern including path.

Directories-In
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
