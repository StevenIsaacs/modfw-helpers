#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Helper macros for makefiles.
#----------------------------------------------------------------------------
ifndef helpersSegId

#++++++++++++++
# For messages.
NewLine = nlnl
_empty :=
Space := ${_empty} ${_empty}
Comma := ,
Dlr := $

define _Format-Message
  $(eval MsgList += ${NewLine}$(strip $(1)):${Seg}:$(strip $(2)))
  $(if ${QUIET},
  ,
    $(info $(strip $(1)):${Seg}:$(strip $(2)))
  )
  $(eval Messages = yes)
endef

define Info
  $(call _Format-Message,...,$(1))
endef

define Warn
  $(call _Format-Message,WRN,$(1))
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

Error_Handler :=
# This is a semaphore which is ued to avoid recursive calls to an installed
# error handler. If the variable is equal to 1 then a call to the error handler
# is safe.
Error_Safe := 1

define Set-Error-Handler
  $(eval Error_Handler := $(1))
endef

define Signal-Error
  $(eval ErrorList += ${NewLine}ERR:${Seg}:$(1))
  $(call _Format-Message,ERR,$(1))
  $(eval Errors = yes)
  $(warning Error:${Seg}:$(1))
  $(and ${Error_Handler},$(filter ${Error_Safe},1),
    $(eval Error_Safe := )
    $(call Debug,Calling ${Error_Handler}.)
    $(call Debug,Message:$(1).)
    $(call ${Error_Handler},$(1))
    $(eval Error_Safe := 1)
  ,
    $(call Warn,Recursive call to Signal-Error -- handler not called.)
  )
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

To-Shell-Var = _$(subst -,_,$(1))

define Require
$(strip \
  $(call Debug,Required in: ${Seg})
  $(eval _r :=)
  $(foreach _v,$(1),
    $(call Debug,Requiring: ${_v})
    $(if $(findstring undefined,$(flavor ${_v})),
      $(eval _r += ${_v})
      $(call Signal-Error,${Seg} requires variable ${_v} must be defined.)
    )
  )
  ${_r}
)
endef

define _mbof
  $(if $(filter ${$(1)},$(2)),
    $(call Debug,$(1)=${$(1)} and is a valid option) 1,
    $(call Signal-Error,Variable $(1)=${$(1)} must equal one of: $(2))
  )
endef

define Must-Be-One-Of
$(strip $(call _mbof,$(1),$(2)))
endef

StickyVars :=
define Sticky
  $(eval _spl := $(subst =,${Space},$(1)))
  $(eval _sp := $(word 1,${_spl}))
  $(call Debug,Sticky:Var:${_sp})
  $(eval _sv := $(word 2,${_spl}))
  $(call Debug,Sticky:Value:${_sv})
  $(if ${_sv},,\
    $(eval _sv := ${${_sp}}))
  $(call Debug,Sticky:New value:${_sv})
  $(call Debug,Sticky:Path: ${STICKY_PATH})
  $(if $(filter $(1),${StickyVars}),\
  $(call Signal-Error,\
    Sticky:Redefinition of sticky variable ${_sp} ignored.),\
  $(eval StickyVars += ${_sp});\
  $(if $(filter 0,${MAKELEVEL}),\
    $(eval ${_sp}:=$(shell \
      ${helpersSegP}/sticky.sh ${_sp}=${_sv} ${STICKY_PATH} $(2))),\
    $(call Debug,Sticky:Variables are read-only in a sub-make.);\
    $(if ${${_sp}},,\
    $(call Debug,Sticky:Reading variable ${${_sp}});\
    $(eval ${_sp}:=$(shell \
      ${helpersSegP}/sticky.sh ${_sp}= ${STICKY_PATH} $(2))),\
    )\
  )\
  )
endef

define Redefine-Sticky
  $(eval _rs := $(firstword $(subst =,${Space},$(1))))
  $(call Debug,Redefine-Sticky:Redefining:$(1))
  $(call Debug,Redefine-Sticky:Resetting var:${_rs})
  $(eval StickyVars := $(filter-out ${_rs},${StickyVars}))
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
Last-Segment-Id = $(words ${MAKEFILE_LIST})

Last-Segment-File = $(word $(words ${MAKEFILE_LIST}),${MAKEFILE_LIST})

Last-Segment-Basename = \
  $(basename $(notdir $(word $(words ${MAKEFILE_LIST}),${MAKEFILE_LIST})))

Last-Segment-Var = \
  $(subst -,_,$(call Last-Segment-Basename))

Last-Segment-Path = \
  $(realpath $(dir $(word $(words ${MAKEFILE_LIST}),${MAKEFILE_LIST})))

Get-Segment-File = $(word $(1),${MAKEFILE_LIST})

Get-Segment-Basename = \
  $(basename $(notdir $(word $(1),${MAKEFILE_LIST})))

Get-Segment-Var = \
  $(subst -,_,$(call Get-Segment-Basename,$(1)))

Get-Segment-Path = \
  $(realpath $(dir $(word $(1),${MAKEFILE_LIST})))

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

define Set-Segment-Context
  $(eval SegId := $(1))
  $(eval Seg := $(call Get-Segment-Basename,$(1)))
  $(eval SegP := $(call Get-Segment-Path,$(1)))
  $(eval SegF := $(call Get-Segment-File,$(1)))
  $(eval SegV := $(call To-Shell-Var,${Seg}))
endef

define Enter-Segment
  $(eval __s := $(call Last-Segment-Basename))
  $(eval ${__s}SegId := $(call Last-Segment-Id))
  $(eval $(call Debug,Entering segment: $(call Get-Segment-Basename,${${__s}SegId})))
  $(eval ${__s}Seg := $(call Last-Segment-Basename))
  $(eval ${__s}SegP := $(call Last-Segment-Path))
  $(eval ${__s}SegF := $(call Last-Segment-File))
  $(eval ${__s}SegV := $(call To-Shell-Var,${__s}))
  $(eval ${__s}PrvSegId := ${SegId})
  $(call Set-Segment-Context,${${__s}SegId})
endef

# Assumes the context is set to the exiting segment.
define Exit-Segment
$(call Debug,Exiting segment: ${Seg})
$(call Debug,Checking help: $(call Is-Goal,help-${Seg}))
$(if $(call Is-Goal,help-${Seg}),\
$(call Debug,Help message variable: help_${SegV}_msg);\
$(eval hlp${SegV} := $$(call help_${SegV}_msg)):\
$(eval export hlp${SegV});\
$(call Debug,Generating help goal: help-${Seg});\
$(eval \
help-${Seg}:;\
echo "$$$$hlp${SegV}" | less\
))
$(eval $(call Set-Segment-Context,${${Seg}PrvSegId}))
endef

# Assumes the context is set to the exiting segment.
define Check-Segment-Conflicts
  $(eval __s := $(call Last-Segment-Basename))
  $(call Debug,\
  Segment exists: ID = ${${__s}SegId}: file = $(call Get-Segment-File,${${__s}SegId}))
  $(eval \
    $(if $(findstring \
      $(call Last-Segment-File),$(call Get-Segment-File,${${__s}SegId})),
        $(call Info,\
        $(call Get-Segment-File,${${__s}SegId}) has already been included.),\
    $(call Signal-Error,\
      Prefix conflict with $(${__s}Seg) in $(call Last-Segment-File).)))
endef

define Gen-Segment
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# $(strip $(2))
#----------------------------------------------------------------------------
# The prefix $(1) must be unique for all files.
# The format of all the $(1) based names is required.
# +++++
# Preamble
$.ifndef $(1)SegId
$$(call Enter-Segment)
# -----

$$(call Info,New segment: Add variables, macros, goals, and recipes here.)

# The primary goal for the segment.
$(3)

# +++++
# Postamble
# Define help only if needed.
$.ifneq ($$(call Is-Goal,help-$${Seg}),)
$.define help_$${SegV}_msg
Make segment: $${Seg}.mk

# Place overview here.

# Add help messages here.

Defines:
  # Describe each variable or macro.

Command line goals:
  # Describe additional goals provided by the segment.
  help-$${Seg}
    Display this help.
$.endef
$.endif # help goal message.

$$(call Exit-Segment)
$.else # $$(call Last-Segment-Basename)SegId exists
$$(call Check-Segment-Conflicts)
$.endif # $$(call Last-Segment-Basename)SegId
# -----

endef

#--------------

#++++++++++++++
# Goal management.
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
  $(sort $(foreach f,$(wildcard $(1)),$(basename $(notdir ${f}))))
endef

define Directories-In
  $(sort \
    $(strip $(foreach d,$(shell find $(1) -mindepth 1 -maxdepth 1 -type d),\
    $(notdir ${d})))
  )
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

define Return-Code
  $(if $(filter 0,$(lastword $(1))),,$(lastword $(1)))
endef

define Run
  $(call Debug,Run:$(2))
  $(eval $(1) := $(shell $(2) 2>&1;echo $$?))
endef

#--------------

# Set SegId to the segment that included helpers so that the previous segment
# set by Enter-Segment and used by Exit-Segment will have a valid value.
_i := $(call Last-Segment-Id)
$(call Dec-Var,_i)
# Initialize the top level context.
$(call Set-Segment-Context,${_i})
$(call Debug,Included from: SegId = ${SegId})
${Seg}Seg := ${Seg}
${Seg}SegId := ${SegId}
${Seg}SegP := $(call Get-Segment-Path,${SegId})
${Seg}SegF := $(call Get-Segment-File,${SegId})
${Seg}SegV := $(call To-Shell-Var,${Seg})

$(call Enter-Segment)

# These are helper functions for shell scripts (Bash).
HELPER_FUNCTIONS := ${${Seg}SegP}/modfw-functions.sh
export HELPER_FUNCTIONS

# Changing the prefix because some editors, like vscode, don't handle tabs
# in make files very well. This also slightly improves readability.
.RECIPEPREFIX := >
SHELL = /bin/bash

# The directory containing the makefile.
WorkingPath = $(call Get-Segment-Path,1)
WorkingDir = $(notdir ${WorkingPath})
WorkingVar := $(call To-Shell-Var,${WorkingDir})

# For storing sticky options in a known location.
DEFAULT_STICKY_PATH := ${WorkingPath}/.${WorkingDir}/sticky

STICKY_PATH := ${DEFAULT_STICKY_PATH}

# Special goal to force another goal.
FORCE:

DefaultGoal ?= help

ifeq (${MAKECMDGOALS},)
  $(call Info,No goal was specified -- defaulting to: ${DefaultGoal}.)
  .DEFAULT_GOAL := $(DefaultGoal)
else
  .DEFAULT_GOAL :=
endif

Goals = ${.DEFAULT_GOAL} ${MAKECMDGOALS}

$(call Info,Goals: ${Goals})

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
$(call Info,Running on: ${Platform})

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

define help_${helpersSegV}_msg
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
  The full path to the current directory when make was invoked.

WorkingDir = ${WorkingDir}
  The name is the last directory in the WorkingPath.

WorkingVar = ${WorkingVar}
  The WorkingDir converted to a string which can be used as part of a shell variable name.

Platform = $(Platform)
  The platform (OS) on which make is running. This can be one of:
  Microsoft, Linux, or OsX.
Errors = ${Errors}
  If not empty then errors have been reported.

Defines the helper macros:

++++ Variables and variable naming

Inc-Var
  Increment the value of a variable by 1.
  Parameters:
    1 = The name of the variable to increment.
  Returns:
    The value of the variable incremented by 1.

Dec-Var
  Decrement the value of a variable by 1.
  Parameters:
    1 = The name of the variable to decrement.
  Returns:
    The value of the variable decremented by 1.

To-Shell-Var
  Convert string to a format which can be used as a shell (${SHELL}) variable
  name.
  Parameters:
    1 = The string to convert to a variable name.
  Returns:
    A string which can be used as the name of a shell variable.

Require
  Use this macro to verify variables are set.
  Parameters:
    1 = The make file segment.
    2 = A list of required variables.
  Returns:
    A list of undefined variables.

Must-Be-One-Of
  Verify a variable has a valid value. If not then issue a warning.
  Parameters:
    1 = The name to verify is in the list.
    2 = List of valid values.
  Returns:
    A non-empty string if the name is a member of the list.

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
  assign a value BEFORE Overridable is called or on the make command line.
  Parameters:
    1 = The variable name.
    2 = The value.

+++++ Makefile segment handling.

Last-Segment-Id
  Returns the ID of the most recently included makefile segment.

Last-Segment-Basename
  Returns the basename of the most recently included makefile segment.

Last-Segment-Var
  Returns the name of the most recently included makefile segment.

Last-Segment-Path
  Returns the directory of the most recently included makefile segment.

Segment-Basename
  Returns the basename of the makefile segment corresponding to ID.
  Parameters:
    1 = ID of the segment.

Segment-Var
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
    SegP  The path to the makefile segment for the new context.
    SegF  The makefile segment file for the new context.
    SegV  A string which can be used as all or part of a ${SHELL} compatible
          variable name.

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
  Sets the segment specific context variables:
    <u>SegId  The ID for the segment. This is basically the index in
          MAKEFILE_LIST for the segment.
    <u>Seg
      The segment name.
    <u>SegV
      The name of the segment converted to a shell compatible variable name.
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

Check-Segment-Conflicts - Call in the postamble.
  This handles the case where a segment is being used more than once or
  the current segment is attempting to use the same prefix as a previously
  loaded segment.

Gen-Segment - Generate a segment file.
  This generates a segment file template which can then be customized by the
  developer.
  Parameters:
    1 = The segment name. This is used to name the segment file, associated
        variable and, specific goals.
    2 = A one line description.
    3 = An optional goal and list of dependencies for the segment. This should
        be a string formatted as: <goal>: <dependencies>
        If <dependencies> is a variable then it should be escaped so that it
        is not expanded when the segment is generated.
  For example,
  $$(call Gen-Segment,sample-seg,This is a sample segment.,seg_goal: $$$${deps})
  generates:
$(call Gen-Segment,sample-seg,This is a sample segment.,seg_goal: $${deps})

+++++ Make goals or targets

Is-Goal
  Returns the goal if it is a member of the list of goals.
  Parameters:
    1 = The goal to check.

Resolve-Help-Goals
  This scans the goals for references to help and then insures the
  corresponding segment is loaded. This should be called only after all
  other segments have been loaded (Use-Segment) to avoid problems with
  variable declaration sequence dependencies. NOTE: All segments for which
  help is referenced must be in the segment search path (Add-Segment-Path).

Add-To-Manifest
  Add an item to a manifest variable.
  Parameters:
    1 = The list to add to.
    2 = The optional variable to declare for the value. Use "null" to skip
      declaring a new variable.
    3 = The value to add to the list.

+++++ Strings and messaging

NewLine
  Use this macro to insert new lines into multiline messages.

Space
  This is intended to be used in substitution patterns where a space is
  required.

Dlr
  This is a dollar sign and is intended to be used in macros that expand
  to bash command lines which include references to environment variables.

Info
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

Set-Error-Handler
  Install a callback handler for when Signal-Error is called.
  The error handler should support one parameter which will be the error
  message.
  WARNING: An error handler should not do any thing that could in turn  trigger
  and error. Doing so could result in a fatal infinite loop. To help mitigate
  this problem the variable Error_Safe is used as a semaphore. If the variable
  is empty then the error handler will NOT be called.
  Parameters:
    1 = The name of the macro to call when an error occurs. To disable the
        current handler do not pass this parameter or pass an empty value.

Signal-Error
  Use this macro to issue an error message as a warning and signal a
  delayed error exit. The messages can be displayed using the display-errors
  goal. Error messages are prefixed with ERR.
  If an error handler is connected (see Set-Error-Handler) and the
  Error_Safe variable is equal to 1 then the error handler is called with the
  error message as the first parameter.
  NOTE: This is NOT intended to be used as part of a recipe.
  Parameters:
    1 = The error message.
  Uses:
    Error_Handler = ${Error_Handler}
      The name of the macro to call when an error occurs.
    Error_Safe = ${Error_Safe}
      The handler is called only when this is equal to 1.

If QUIET is not empty then all messages except error messages are suppressed.
They are still added to the message list and can still be displayed using
the display-messages goal.

+++++ Paths and file names

Basenames-In
  Get the basenames of all the files in a directory matching a glob pattern.
  Parameters:
    1 = The glob pattern including path.

Directories-In
  Get a list of directories in a directory. The path is stripped.
  Parameters:
    1 = The path to the directory.

+++++ Makefile execution control

Confirm
  Prompts the user for a yes or no response. If the response matches the
  positive response then the positive response is returned. Otherwise an
  empty value is returned.
  Parameters:
    1 = The prompt for the response.
    2 = The expected positive response.

Pause
  Wait until the Enter key is pressed.

Return-Code
  Returns the return code (last line) of the output produced by Run. This can
  then be used in a conditional.
  Parameter:
    1 = The previously captured console output.
  Returns:
    If the return code equals 0 then nothing is returned. Otherwise, the
    return code is returned.

Run
  Run a shell command and return the error code.
  Parameters:
    1 = The name of a variable to store the output in.
    2 = The command to run. This can be multiple commands separated by
        semicolons (;) or AND (&&) OR (||) conditionals.
  Returns:
    The console output with the return code appended as the last line. Use
    Return-Code to retrieve only the return code from the output.

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

endef
endif # help goal
$(call Debug,Last-Segment-Id:$(call Last-Segment-Id))
$(call Debug,${Seg}SegID:${${Seg}SegID})
$(call Exit-Segment)
else # Already loaded.
$(call Check-Segment-Conflicts)
endif # helpersSegId
