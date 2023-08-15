#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Helper macros for makefiles.
#----------------------------------------------------------------------------
ifndef helpersSegId

#++++++++++++++
# For messages.
NewLine = nlnl
_empty :=
Space := ${_empty} ${_empty}

define _Format-Message
  $(eval MsgList += ${NewLine}$(strip $(1)):${Seg}:$(strip $(2)))
  $(info $(strip $(1)):${Seg}:$(strip $(2)))
  $(eval Messages = yes)
endef

define Add-Message
  $(call _Format-Message,...,$(1))
endef

define Warn
  $(call __Format-Message,WRN,$(1))
endef

_V:=n
ifneq (${VERBOSE},)
define Verbose
  $(call _Format-Message,vbs,$(1))
endef
_V:=v
endif

ifneq (${DEBUG},)
define Debug
  $(call _Format-Message,dbg,$(1))
endef
_V:=vp
endif

MAKEFLAGS += --debug=${_V}

define Signal-Error
  $(eval ErrorList += ${NewLine}ERR:${Seg}:$(1))
  $(call _Format-Message,ERR,$(1))
  $(eval Errors = yes)
  $(warning Error:${Seg}:$(1))
endef
#--------------

#++++++++++++++
# Variable handling.
define Inc-Var
  $(eval $(1):=$(shell expr $($(1)) + 1))
endef

define Dec-Var
  $(eval $(1):=$(shell expr $($(1)) - 1))
endef

To-Name = $(subst -,_,$(1))

#+
# This private macro is used to verify a single variable exists.
# If the variable is empty then an error message is appended to ErrorList.
# Parameters:
#   1 = The name of the variable.
#   2 = The module in which it is required.
#-
define _require-this
  $(call Debug,Requiring: $(1))
  $(if $(findstring undefined,$(flavor ${1})),\
  $(warning Variable $(1) is not defined); \
  $(call Signal-Error,Variable $(1) must be defined in: $(2))
  )
endef

define Require
  $(call Debug,Required in: $(1))
  $(foreach v,$(2),$(call _require-this,$(v), $(1)))
endef

define Must-Be-One-Of
  $(if $(findstring ${$(1)},$(2)),\
  $(call Debug,$(1) = ${$(1)} and is a valid option),\
  $(call Signal-Error,Variable $(1) must equal one of: $(2))\
  )
endef

StickyVars :=
define Sticky
  $(call Debug,Sticky:Var:$(1))
  $(call Debug,Sticky:Path: ${STICKY_PATH})
  $(if $(filter $(1),${StickyVars}),\
  $(call Signal-Error,\
    Sticky:Redefinition of sticky variable $(1) ignored.),\
  $(eval StickyVars += $(1));\
  $(if $(filter 0,${MAKELEVEL}),\
    $(eval $(1):=$(shell \
    ${helpersSegP}/sticky.sh $(1)=${$(1)} ${STICKY_PATH} $(2))),\
    $(call Debug,Sticky:Variables are read-only in a sub-make.);\
    $(if ${$(1)},,\
    $(call Debug,Sticky:Reading variable ${(1)});\
    $(eval $(1):=$(shell \
      ${helpersSegP}/sticky.sh $(1)= ${STICKY_PATH} $(2))),\
    )\
  )\
  )
endef

define Redefine-Sticky
  $(eval _v := $(firstword $(subst =,$(Space),$(1))))
  $(call Debug,Redefine-Sticky:Redefining:$(1))
  $(call Debug,Redefine-Sticky:Resetting var:${_v})
  $(eval StickyVars := $(filter-out ${_v},${StickyVars}))
  $(call Debug,Redefine-Sticky:StickyVars:${StickyVars})
  $(call Sticky,$(1))
endef

define Remove-Sticky
  $(if $(filter $(1),${StickyVars}),\
  $(call Debug,Remove-Sticky:Removing sticky variable: $(1));\
  $(eval StickyVars := $(filter-out $(1),${StickyVars}));\
  $(eval undefine $(1));\
  $(shell rm ${STICKY_PATH}/$(1)),\
  $(call Debug,Remove-Sticky:Var $(1) has not been defined.)\
  )
endef

OverridableVars :=
define Overridable
  $(if $(filter $(1),${OverridableVars}),\
  $(call Signal-Error,\
    Overridable:Var $(1) has already been declared.),\
  $(eval OverridableVars += $(1));\
  $(if $(filter $(origin $(1)),undefined),\
    $(eval $(1) := $(2)),\
    $(call Debug,Overridable:Var $(1) has override value: ${$(1)})\
    )\
  )
endef
#--------------

#++++++++++++++
# Makefile segment handling.
This-Segment-Id = $(words ${MAKEFILE_LIST})

This-Segment-File = $(word $(words ${MAKEFILE_LIST}),${MAKEFILE_LIST})

This-Segment-Basename = \
  $(basename $(notdir $(word $(words ${MAKEFILE_LIST}),${MAKEFILE_LIST})))

This-Segment-Name = \
  $(subst -,_,$(call This-Segment-Basename))

This-Segment-Path = \
  $(realpath $(dir $(word $(words ${MAKEFILE_LIST}),${MAKEFILE_LIST})))

Get-Segment-File = $(word $(1),${MAKEFILE_LIST})

Get-Segment-Basename = \
  $(basename $(notdir $(word $(1),${MAKEFILE_LIST})))

Get-Segment-Name = \
  $(subst -,_,$(call Get-Segment-Basename,$(1)))

Get-Segment-Path = \
  $(realpath $(dir $(word $(1),${MAKEFILE_LIST})))

define Set-Segment-Context
  $(eval SegId := $(1))
  $(eval Seg := $(call Get-Segment-Basename,$(1)))
  $(eval SegN := $(call Get-Segment-Name,$(1)))
  $(eval SegP := $(call Get-Segment-Path,$(1)))
  $(eval SegF := $(call Get-Segment-File,$(1)))
endef

SegPaths :=  $(call Get-Segment-Path,1)

define Add-Segment-Path
  $(eval SegPaths += $(1))
  $(call Debug,Added path(s):$(1))
endef

define Find-Segment
  $(eval $(2) := )
  $(call Debug,Locating segment: $(1))
  $(call Debug,Segment paths:${SegPaths} $(call Get-Segment-Path,${SegId}))
  $(foreach _p,${SegPaths} $(call Get-Segment-Path,${SegId}),\
  $(call Debug,Trying: ${_p});\
  $(if $(wildcard ${_p}/$(1).mk),\
    $(eval $(2) := ${_p}/$(1).mk))))
  $(if ${$(2)},\
  $(call Debug,Found segment:${$(2)}),
  $(call Signal-Error,$(1).mk not found.))
endef

define Use-Segment
  $(if $(findstring .mk,$(1)),\
  $(call Debug,Including segment:${1});\
  $(eval include $(1)),\
  $(call Find-Segment,$(1),_seg);\
  $(call Debug,Using segment:${_seg});\
  $(eval include ${_seg})\
  )
endef

define Enter-Segment
  $(eval $(1)SegId := $(call This-Segment-Id))
  $(eval $(call Debug,Entering segment: $(call Get-Segment-Basename,${$(1)SegId})))
  $(eval $(1)Seg := $(call This-Segment-Basename))
  $(eval $(1)SegN := $(call This-Segment-Name))
  $(eval $(1)SegP := $(call This-Segment-Path))
  $(eval $(1)SegF := $(call This-Segment-File))
  $(eval $(1)PrvSegId := ${SegId})
  $(call Set-Segment-Context,${$(1)SegId})
endef

define Exit-Segment
$(call Debug,Exiting segment: $(call Get-Segment-Basename,${$(1)SegId}))
$(call Debug,Checking help: $(call Is-Goal,help-${$(1)Seg}))
$(if $(call Is-Goal,help-${$(1)Seg}),\
$(call Debug,Help message variable: help_${$(1)SegN}_msg);\
$(eval export help_${$(1)SegN}_msg);\
$(call Debug,Generating help goal: help-${$(1)Seg});\
$(eval \
help-${$(1)Seg}:;\
echo "$$$$help_${$(1)SegN}_msg" | less\
))
$(eval $(call Set-Segment-Context,${$(1)PrvSegId}))
endef

define Check-Segment-Conflicts
  $(call Debug,\
  Segment exists: ID = ${$(1)SegId}: file = $(call Get-Segment-File,${$(1)SegId}))
  $(eval $(if $(findstring $(call This-Segment-File),$(call Get-Segment-File,${$(1)SegId})),
  $(call Add-Message,\
    $(call Get-Segment-File,${$(1)SegId}) has already been included.),\
  $(call Signal-Error,\
    Prefix conflict with $($(1)Seg) in $(call This-Segment-File).)))
endef

define Gen-Segment
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# $(1): $(2)
#----------------------------------------------------------------------------
# The prefix $(3) must be unique for all files.
# The format of all the $(3) based names is required.
# +++++
# Preamble
$.ifndef $(3)SegId
$$(call Enter-Segment,$(3))
# -----

# Add variables, macros, goals, and recipes here.

# +++++
# Postamble
# Define help only if needed.
$.ifneq ($$(call Is-Goal,help-$${$(3)Seg}),)
$.define help_$${$(3)SegN}_msg
Make segment: $${$(3)Seg}.mk

Project specific configs for the project: ${PROJECT}

# Add help messages here.

Defines:
  # Describe each variable or macro.

Command line goals:
  # Describe additional goals provided by the segment.
  help-$${$(3)Seg}
    Display this help.
$.endef
$.endif # help goal message.

$$(call Exit-Segment,$(3))
$.else # $(3)SegId exists
$$(call Check-Segment-Conflicts,$(3))
$.endif # $(3)SegId
# -----

endef

#--------------

#++++++++++++++
# Goal management.
DefaultGoal ?= help

$(call Add-Message,Goal: ${MAKECMDGOALS})
ifeq (${MAKECMDGOALS},)
  $(call Add-Message,No goal was specified -- defaulting to: ${DefaultGoal}.)
  .DEFAULT_GOAL := $(DefaultGoal)
endif

Goals = ${.DEFAULT_GOAL} ${MAKECMDGOALS}
$(call Add-Message,Goals: ${Goals})

define Resolve-Help-Goals
$(call Debug,Resolving help goals.)
$(call Debug,Help goals: $(filter help-%,${Goals}))
$(foreach _s,$(patsubst help-%,%,$(filter help-%,${Goals})),\
  $(call Debug,Resolving help for segment ${_s});\
  $(if $(filter ${_s}.mk,${MAKEFILE_LIST}),\
  $(call Debug,Segment ${_s} already loaded.),\
  $(call Use-Segment,${_s})))
endef

Is-Goal = $(filter $(1),${Goals})

define Add-To-Manifest
  $(call Debug,Adding $(3) to $(1))
  $(call Debug,Var: $(2))
  $(eval $(2) = $(3))
  $(call Debug,$(2)=$(3))
  $(eval $(1) += $(3))
endef
#--------------

#++++++++++++++
# Directories and files.
define Basenames-In
  $(foreach f,$(wildcard $(1)),$(basename $(notdir ${f})))
endef

define Directories-In
  $(strip $(foreach d,$(shell find $(1) -mindepth 1 -maxdepth 1 -type d),\
  $(notdir ${d})))
endef
#--------------

#++++++++++++++
# Other helpers.
define Confirm
$(strip $(filter $(2),$(shell read -r -p "$(1) [$(2)|N]: "; echo $$REPLY)))
endef

define Pause
  $(shell read -r -p "Press Enter to continue...")
endef
#--------------

# Set SegId to the segment that included helpers so that the previous segment
# set by Enter-Segment and used by Exit-Segment will have a valid value.
_i := $(call This-Segment-Id)
$(call Dec-Var,_i)
SegId := ${_i}
$(call Debug,Included from: SegId = ${SegId})

$(call Enter-Segment,helpers)

# These are helper functions for shell scripts (Bash).
HELPER_FUNCTIONS := ${helpersSegP}/modfw-functions.sh

# Changing the prefix because some editors, like vscode, don't handle tabs
# in make files very well. This also slightly improves readability.
.RECIPEPREFIX := >
SHELL = /bin/bash

# The directory containing the makefile.
WorkingPath = $(call Get-Segment-Path,1)
WorkingDir = $(notdir ${WorkingPath})
WorkingName := $(subst -,_,${WorkingDir})

# Where sticky variables are initially stored.
STICKY_PATH ?= ${WorkingPath}/.modfw/sticky

# Special goal to force another goal.
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
  $(call Signal-Error,Unable to identify platform)
endif
$(call Add-Message,Running on: ${Platform})

$(call Debug,MAKELEVEL = ${MAKELEVEL})
$(call Debug,MAKEFLAGS = ${MAKEFLAGS})

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

origin-%:
> @echo 'Origin:$*=$(origin $*)'

ifneq ($(call Is-Goal,help-${helpersSeg}),)
_SampleSeg = $(call Gen-Segment,This is a sample segment,sample-seg,sample_seg)

define help_${helpersSegN}_msg
Make segment: helpers.mk

Optionally defined before including helpers:
DefaultGoal = ${DefaultGoal}
  This sets .DEFAULT_GOAL only if no other goals have been set and defaults
  to help. The primary makefile should provide this help goal to display
  a help message when no command line goals are specified. This can be
  overridden by defining this variable before including the helpers.

Defines:
HELPER_FUNCTIONS = ${HELPER_FUNCTIONS}
  The path to the bash script helper functions. This is intended to be used
  by bash shell scripts.

.RECIPEPREFIX = ${.RECIPEPREFIX}
  macros.mk sets make variables to simplify editing rules in some editors
  which don't handle tab characters very well.

SHELL = ${SHELL}
  Also to enable some bash specific features.

WorkingPath = ${WorkingPath}
  The full path to the project directory.

WorkingDir = ${WorkingDir}
  The name is the last directory in the WorkingPath.

WorkingName = ${WorkingName}
  The WorkingDir converted to a string which can be used as part of a variable
  name.

Defines the helper macros:

Inc-Var
  Increment the value of a variable by 1.
  Parameters:
    1 = The name of the variable to increment.

Dec-Var
  Decrement the value of a variable by 1.
  Parameters:
    1 = The name of the variable to decrement.

To-Name
  Convert string to a variable name compatible format.

Is-Goal
  Returns the goal if it is a member of the list of goals.
  Parameters:
    1 = The goal to check.

This-Segment-Id
  Returns the ID of the most recently included makefile segment.

This-Segment-Basename
  Returns the basename of the most recently included makefile segment.

This-Segment-Name
  Returns the name of the most recently included makefile segment.

This-Segment-Path
  Returns the directory of the most recently included makefile segment.

Segment-Basename
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
  Sets current context variables:
    SegId   The makefile segment ID for the new context.
    Seg   The makefile segment basename for the new context.
    SegN  The makefile segment name for the new context.
    SegP  The path to the makefile segment for the new context.
    SegF  The makefile segment file for the new context.

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
  If the segment contains .mk then a valid path to the segment is assumed and
  the segment is loaded directly. Otherwise, Find-Segment is used to search a
  list of directories for a segment and the segment is loaded it if it
  exists. The segment can exist in multiple locations and only the last
  one in the list will be loaded. If the segment is not found in any of the
  directories then the segment is loaded from the current segment directory
  (Segment-Path).
  If the segment cannot be found an error message is added to the error list.
  Parameters:
    1 = The segment to load.

  The loaded segment is expected to define a new context to be used during
  its initialization and then to restore the previous context when it has
  completed initialization. The new segment is also expected to avoid
  executing the initialization a second time. Helper macros are provided to
  standardize this process. They are intended to be used at the beginning
  in a preamble and at the end in a postamble. Unfortunately, make syntax
  limitations prevent this from being simplified even further.

  Makefile segments should use the standard preamble and postamble to avoid
  inclusion of the same file more than once and to use standardized ID
  variables.

  Each loaded segment is added to SegDeps to trigger rebuilds when a
  a segment is changed. NOTE: All components will be rebuilt in this case
  because it is unknown if a change in a segment will cause a change in the
  build output of another segment.

  A template for new make segments can be generated using the Gen-Segment
  macro (below).

Enter-Segment - Call in the preamble
  This initializes the context for a new segment and saves information so
  that the context of the previous segment can be restored in the postamble.
  Parameters:
    1 = The prefix to use for segment context variables.
  Sets the segment specific context variables:
    <u>SegId  The ID for the segment. This is basically the index in
          MAKEFILE_LIST for the segment.
    <u>Seg
      The segment name.
    <u>SegN
      The name of the segment ('-' replaced with '_').
    <u>SegP
      The path to the makefile segment.
    <u>SegF
      The path and name of the makefile segment. This can be used as part of a
      dependency list.
    <u>PrvSegId
      The previous segment ID which is used to restore the previous context.

Exit-Segment - Call in the postamble.
  This initializes the help message for the segment and restores the
  context of the previous segment.
  Parameters:
    1 = The prefix to use for the current context variables.

Check-Segment-Conflicts - Call in the postamble.
  This handles the case where a segment is being used more than once or
  the current segment is attempting to use the same prefix as a previously
  loaded segment.
  Parameters:
    1 = The prefix to use for the current context variables.

Gen-Segment - Generate a segment file.
  This generates a segment file template which can then be customized for a
  project.
  Parameters:
    1 = A one line description.
    2 = The segment.
    3 = The segment name.
  For example,
  $$(call Gen-Segment,This is a sample segment,sample-seg,sample_seg)
  generates:
$(call Gen-Segment,This is a sample segment,sample-seg,sample_seg)

Resolve-Help-Goals
  This scans the goals for references to help and then insures the
  corresponding segment is loaded. This should be called only after all
  other segments have been loaded (Use-Segment) to avoid problems with
  variable declaration sequence dependencies.

Add-To-Manifest
  Add an item to a manifest variable.
  Parameters:
    1 = The list to add to.
    2 = The optional variable to declare for the value. Use "null" to skip
      declaring a new variable.
    3 = The value to add to the list.

NewLine
  Use this macro to insert new lines into multiline messages.

Space
  This is intended to be used in substitution patterns where a space is
  required.

Add-Message
  Use this macro to add a message to a list of messages to be displayed
  by the display-messages goal.
  Messages are prefixed with the variable Segment which is set by the
  calling segment.
  NOTE: This is NOT intended to be used as part of a recipe.
  Parameters:
    1 = The message.

Warn
  Display a warning message. Warning messages are prefixed with WRN.
  NOTE: This is NOT intended to be used as part of a recipe.
  Parameters:
    1 = The message to display.

Verbose
  Displays the message if VERBOSE has been defined. All verbose messages are
  automatically added to the message list. Verbose messages are prefixed with
  vbs.
  NOTE: This is NOT intended to be used as part of a recipe.
  Parameters:
    1 = The message to display.

Debug
  Displays the message if DEBUG has been defined. All debug messages are
  automatically added to the message list. Debug messages are prefixed with
  dbg.
  NOTE: This is NOT intended to be used as part of a recipe.
  Parameters:
    1 = The message to display.

Signal-Error
  Use this macro to issue an error message as a warning and signal a
  delayed error exit. The messages can be displayed using the display-errors
  goal. Error messages are prefixed with ERR.
  NOTE: This is NOT intended to be used as part of a recipe.
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
  declared when this macro is called then the previous value is used. Defining
  the variable will overwrite the previous sticky value.
  Only the first call to Sticky for a given variable will be accepted.
  Additional calls will produce a redefinition error.
  Sticky variables are read only in a sub-make (MAKELEVEL != 0).
  WARNING: The variable must be defined at least once.
  Variables used:
    helpersSegP=${helpersSegP}
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

Redefine-Sticky
  Redefine a sticky variable that has been previously set.
  Parameters:
    1 = Variable name[=<value>]

Overridable
  Declare a variable which may be overridden. This mostly makes it obvious
  which variables are intended to be overridable. The variable is declared
  as a simply expanded variable only if it has not been previously defined.
  An overridable variable can be declared only once. To override the variable
  assign a value BEFORE Overridable is called.
  Parameters:
    1 = The variable name.
    2 = The value.

Basenames-In
  Get the basenames of all the files in a directory matching a glob pattern.
  Parameters:
    1 = The glob pattern including path.

Directories-In
  Get a list of directories in a directory. The path is stripped.
  Parameters:
    1 = The path to the directory.

Confirm
  Prompts the user for a yes or no response. If the response matches the
  positive response then the positive response is returned. Otherwise an
  empty value is returned.
  Parameters:
    1 = The prompt for the response.
    2 = The expected positive response.

Pause
  Wait until the Enter key is pressed.

Special goals:
show-%
  Display the value of any variable.

origin-%
  Display the origin of a variable. The result can be any of the
  values described in section 8.11 of the GNU make documentation
  (https://www.gnu.org/software/make/manual/html_node/Origin-Function.html).

display-messages
  This goal displays a list of accumulated messages if defined.

display-errors
  This goal displays a list of accumulated errors if defined.

Defines:
  Platform = $(Platform)
    The platform (OS) on which make is running. This can be one of:
    Microsoft, Linux, or OsX.
  Errors = ${Errors}
    If not empty then errors have been reported.
endef
endif # help goal
$(call Debug,This-Segment-Id:$(call This-Segment-Id))
$(call Debug,${SegN}SegID:${${SegN}SegID})
$(call Exit-Segment,helpers)
else # Already loaded.
$(call Check-Segment-Conflicts,helpers)
endif # helpersSegId
