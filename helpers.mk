#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Helper macros for makefiles.
#----------------------------------------------------------------------------
ifndef helpers.SegId

# Changing the prefix because some editors, like vscode, don't handle tabs
# in make files very well. This also slightly improves readability.
.RECIPEPREFIX := >
# NOTE: Bash is required because of some bash-isms being used.
SHELL = /bin/bash

True := 1
False :=


ifeq (${MAKECMDGOALS},)
  DefaultGoal := help
else
  DefaultGoal :=
endif

Goals = ${DefaultGoal} ${MAKECMDGOALS}

# This indicates when running as a nested make.
ifeq (${MAKELEVEL},0)
  SubMake := ${False}
else
  SubMake := ${True}
endif

# The directory containing the makefile.
WorkingPath = $(realpath $(dir $(word 1,${MAKEFILE_LIST})))
WorkingDir = $(notdir ${WorkingPath})
WorkingVar := _$(subst -,_,$(WorkingDir))
HiddenPath := ${WorkingPath}/.${WorkingDir}
TmpDir := ${WorkingDir}
TmpPath := /tmp/${TmpDir}
$(shell mkdir -p ${TmpPath})
LogPath := ${HiddenPath}/log
LogFile := ${LogPath}/${LOG_FILE}
ifneq (${LOG_FILE},)
  ifeq (${SubMake},${False})
    $(shell mkdir -p ${LogPath})
    $(file >${LogFile},${WorkingDir} log: $(shell date))
  else
    $(file >>${LogFile},++++++++ MAKELEVEL = ${MAKELEVEL} +++++++++)
  endif
endif

# For storing sticky options in a known location.
DEFAULT_STICKY_PATH := ${HiddenPath}/sticky

STICKY_PATH := ${DEFAULT_STICKY_PATH}

#++++++++++++++
# For messages.
NewLine = nlnl
_empty :=
Space := ${_empty} ${_empty}
Comma := ,
Dlr := $

_macro := Div
define _help
${_macro}
  Use this macro to add a divider line between catenated messages.
endef
help-${_macro} := $(call _help)
define ${_macro}

endef

_var := SegID_Stack
${_var} :=
define _help
${_var}
  This is a special variable containing the list of nested makefile segments
  using their segment IDs. This is used to save and restore segment context
  as segments are entered and exited.
endef
help-${_var} := $(call _help)

_var := Entry_Stack
${_var} := $(basename $(notdir $(word 1,${MAKEFILE_LIST})))
define _help
${_var}
  This is a special variable containing the list of macros and segments which
  have been entered using Enter-Macro and Enter-Segment. The last item on the
  stack is emitted with all messages.
endef
help-${_var} := $(call _help)

_var := Caller
${_var} := ${Entry_Stack}
define _help
${_var}
  This is the name of the file or macro calling a macro.
endef
help-${_var} := $(call _help)

_var := Message_Callback
${_var} :=
define _help
${_var}
  This variable is used to reference a macro which will be called when
  any message is emitted. This allows special handling of messages when they
  are reported.
endef
help-${_var} := $(call _help)

_var := Message_Safe
${_var} := 1
define _help
${_var}
  This variable is used as a semaphore to indicate when it is safe to call the
  Message_Callback callback. The purpose is to avoid recursive calls to the
  callback. The callback is safe when this variable is not empty.
endef
help-${_var} := $(call _help)

_var := Warning_Callback
${_var} :=
define _help
${_var}
  This variable is used to reference a macro which will be called when
  Warn is called. This allows special handling of warnings when they
  are reported.
endef
help-${_var} := $(call _help)

_var := Warning_Safe
${_var} := 1
define _help
${_var}
  This variable is used as a semaphore to indicate when it is safe to call the
  Warning_Callback callback. The purpose is to avoid recursive calls to the
  callback. The callback is safe when this variable is not empty.
endef
help-${_var} := $(call _help)

_var := QUIET
${_var} ?=
define _help
${_var}
  Set this variable on the command line to suppress console output.
  If QUIET is not empty then all messages except error messages are suppressed.
  They are still added to the message list and can still be displayed using
  the display-messages goal.
endef
help-${_var} := $(call _help)

_macro := Log-Message
define _help
${_macro}
  Format a message string and display it. If a log file is specified, the
  message is also written to the log file.
  Parameters:
    1 = Four character message prefix.
    2 = The message.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(eval _msg := \
    $(strip $(1)):${Caller}:$(lastword ${Entry_Stack}):$(strip $(2)))
  $(if ${LOG_FILE},
    $(file >>${LogFile},${_msg})
  )
  $(if ${QUIET},
  ,
    $(if $(filter $(lastword $(2)),${NewLine}),
      $(info )
    )
    $(info ${_msg})
  )
  $(if ${Message_Callback},
    $(if ${Message_Safe},
      $(eval Message_Safe :=)
      $(call ${Message_Callback},$(strip ${_msg}))
      $(eval Message_Safe := 1)
    ,
      $(eval _msg := \
        clbk:${Seg}:$(lastword ${Entry_Stack}):$(strip \
          Recursive call to Message_Callback -- callback not called.))
      $(if ${LOG_FILE},
        $(file >>${LogFile},${_msg})
      )
      $(info ${_msg})
    )
  )
  $(eval Messages = yes)
endef

_macro := Line
define _help
${_macro}
  Add a blank line or a line termination to the output.
  Uses:
    NewLine   The newline pattern is appended to the output.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(if ${LOG_FILE},
    $(file >>${LogFile}, )
  )
  $(if ${QUIET},
  ,
    $(info )
  )
endef

_macro := Info
define _help
${_macro}
  Use this macro to add a message to a list of messages to be displayed
  by the display-messages goal. Info uses .... as a message prefix.
  NOTE: This is NOT intended to be used as part of a recipe.
  Parameters:
    1 = The message.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Log-Message,....,$(1))
endef

_macro := Attention
define _help
${_macro}
  Use this macro to flag a message as important. Important messages are
  prefixed with ATTN.
  NOTE: This is NOT intended to be used as part of a recipe.
  Parameters:
    1 = The message to display.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Log-Message,ATTN,$(1))
endef

_macro := Warn
define _help
${_macro}
  Display a warning message. Warning messages are prefixed with WARN.
  NOTE: This is NOT intended to be used as part of a recipe.
  Parameters:
    1 = The message to display.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Log-Message,WARN,$(1))
  $(if ${Warning_Callback},
    $(if ${Warning_Safe},
      $(eval Warning_Safe :=)
      $(call ${Warning_Callback},$(strip $(1)))
      $(eval Warning_Safe := 1)
    ,
      $(call Attention,\
        Recursive call to Warning_Callback -- callback not called.)
    )
  )
endef

_V:=n
_macro := Verbose
define _help
${_macro}
  Displays the message if VERBOSE has been defined. All verbose messages are
  automatically added to the message list. Verbose messages are prefixed with
  vrbs.
  NOTE: This is NOT intended to be used as part of a recipe.
  Parameters:
    1 = The message to display.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(if ${VERBOSE},
    $(call Log-Message,vrbs,$(1))
  )
endef
ifneq (${VERBOSE},)
_V:=v
endif

_macro := Debug
define _help
${_macro}
  Emit a debugging message. All debug messages are automatically added to the
  message list. Debug messages are prefixed with dbug.
  This is disabled unless DEBUG is not empty.
  NOTE: This is NOT intended to be used as part of a recipe.
  Parameters:
    1 = The message to display.
endef
help-${_macro} := $(call _help)
ifneq (${DEBUG},)
define ${_macro}
  $(call Log-Message,dbug,$(1))
endef
_V:=vp --warn-undefined-variables
endif

_macro := Step
define _help
${_macro}
  Issues a step message and waits for the enter key to be pressed.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(shell read -r -p "Step: Press Enter to continue...")
endef

define _Push-Entry
  $(if $(filter $(1),${Entry_Stack}),
    $(call Attention,Recursive entry to $(1) detected.)
  )
  $(eval Caller := $(lastword ${Entry_Stack}))
  $(eval Entry_Stack += $(1))
  $(if ${DEBUG},
    $(call Log-Message, \
      $(words ${Entry_Stack})-->,${Entry_Stack})
    $(if ${Single_Step},$(call Step))
  )
endef

define _Pop-Entry
  $(if ${DEBUG},
    $(call Log-Message, \
      <--$(words ${Entry_Stack}),Exiting:$(lastword ${Entry_Stack}))
  )
  $(eval _l := $(words ${Entry_Stack}))
  $(call Dec-Var,_l)
  $(eval Entry_Stack := $(wordlist 1,${_l},${Entry_Stack}))
  $(eval Caller := $(lastword ${Entry_Stack}))
endef

_macro := Enter-Macro
define _help
${_macro}
  Adds a macro name to the Entry_Stack. This should be called as the first
  line of the macro.
  Parameter:
    1 = The name of the macro to add to the stack.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call _Push-Entry,$(1))
  $(if $(and ${DEBUG},$(2)),
    $(call Log-Message,====,$(2))
  )
endef

_macro := Exit-Macro
define _help
${_macro}
  Removes the last macro name from the Entry_Stack. This should be called as
  the last line of the macro.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call _Pop-Entry)
endef

_macro := Set-Message-Callback
define _help
${_macro}
  Install a message callback for when a Warn is issued.
  The callback should support one parameter which will be the message.
  To avoid recursive callbacks the variable Warning_Safe is used as a semaphore.
  If the variable is empty then the warning callback will NOT be called.
  Recursive callbacks are disallowed.
  To clear the callback simply call this macro with no parameters.
  Parameters:
    1 = The name of the macro to call when a message is called. To disable the
        current handler do not pass this parameter or pass an empty value.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0),$(1))
  $(eval Message_Callback := $(1))
  $(call Exit-Macro)
endef

_macro := Set-Warning-Callback
define _help
${_macro}
  Install a warning message callback for when a Warn is issued.
  The callback should support one parameter which will be the message.
  WARNING: A warning callback should not do any thing that could in turn
  trigger another warning. Doing so could result in a fatal infinite loop. To
  help mitigate this problem the variable Warning_Safe is used as a semaphore.
  If the variable is empty then the warning callback will NOT be called.
  Recursive callbacks are disallowed.
  Parameters:
    1 = The name of the macro to call when a message is called. To disable the
        current handler do not pass this parameter or pass an empty value.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0),$(1))
  $(eval Warning_Callback := $(1))
  $(call Exit-Macro)
endef

_macro := Enable-Single-Step
define _help
${_macro}
  When single step mode is enabled and DEBUG is not empty Step is called
  every time a macro is entered.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0))
  $(eval Single_Step := yes)
  $(call Exit-Macro)
endef

_macro := Disable-Single-Step
define _help
${_macro}
  Disables single step mode.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0))
  $(eval Single_Step :=)
  $(call Exit-Macro)
endef

MAKEFLAGS += --debug=${_V}

_var := Error_Callback
define _help
${_var}
  This variable is used to reference a macro which will be called when
  Signal-Error is called. This allows special handling of errors when they
  are reported.
endef
help-${_var} := $(call _help)
${_var} :=

_var := Error_Safe
define _help
${_var}
  This variable is used as a semaphore to indicate when it is safe to call the
  Error_Callback callback. The purpose is to avoid recursive calls to the
  callback. The callback is safe when this variable is not empty.
endef
help-${_var} := $(call _help)
${_var} := 1

_macro := Set-Error-Callback
define _help
${_macro}
  Install a callback handler for when Signal-Error is called.
  The error handler should support one parameter which will be the error
  message.
  WARNING: An error handler should not do any thing that could in turn trigger
  an error. Doing so could result in a fatal infinite loop. To help mitigate
  this problem the variable Error_Safe is used as a semaphore. If the variable
  is empty then the error handler will NOT be called.
  Parameters:
    1 = The name of the macro to call when an error occurs. To disable the
        current handler do not pass this parameter or pass an empty value.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0),$(1))
  $(eval Error_Callback := $(1))
  $(call Exit-Macro)
endef

_macro := Signal-Error
define _help
${_macro}
  Use this macro to issue an error message as a warning and signal a
  delayed error exit. The messages can be displayed using the display-errors
  goal. Error messages are prefixed with ERR!.
  If an error handler is connected (see Set-Error-Callback) and the
  Error_Safe variable is equal to 1 then the error handler is called with the
  error message as the first parameter.
  NOTE: This is NOT intended to be used as part of a recipe.
  Parameters:
    1 = The error message.
  Uses:
    Error_Callback = ${Error_Callback}
      The name of the macro to call when an error occurs.
    Error_Safe = ${Error_Safe}
      The handler is called only when this is equal to 1.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(eval ErrorList += ${NewLine}ERR!:${Caller}:$(1))
  $(call Log-Message,ERR!,$(1))
  $(eval Errors = yes)
  $(warning Error:${Seg}:$(1))
  $(call Debug,Handler: ${Error_Callback} Safe:${Error_Safe})
  $(if ${Error_Callback},
    $(if ${Error_Safe},
      $(eval Error_Safe := )
      $(call Debug,Calling ${Error_Callback}.)
      $(call Debug,Message:$(1).)
      $(call ${Error_Callback},$(1))
      $(eval Error_Safe := 1)
    ,
      $(call Warn,Recursive call to Signal-Error -- handler not called.)
    )
  )
endef
#--------------

#++++++++++++++
# Variable handling.
_macro := Inc-Var
define _help
${_macro}
  Increment the value of a variable by 1.
  Parameters:
    1 = The name of the variable to increment.
  Returns:
    The value of the variable incremented by 1.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(eval $(1):=$(shell expr ${$(1)} + 1))
endef

_macro := Dec-Var
define _help
${_macro}
  Decrement the value of a variable by 1.
  Parameters:
    1 = The name of the variable to decrement.
  Returns:
    The value of the variable decremented by 1.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(eval $(1):=$(shell expr ${$(1)} - 1))
endef

_macro := Add-Var
define _help
  Add a value to a variable.
  Parameters:
    1 = The variable to which the value is added.
    2 = The value to add.
  Returns:
    The value of the variable increased by the value.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(eval $(1):=$(shell expr ${$(1)} + $(2)))
endef

_macro := Sub-Var
define _help
  Subtract a value from a variable.
  Parameters:
    1 = The variable from which the value is subtracted.
    2 = The value to subtract.
  Returns:
    The value of the variable decreased by the value.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(eval $(1):=$(shell expr ${$(1)} - $(2)))
endef

_macro := To-Shell-Var
define _help
${_macro}
  Convert string to a format which can be used as a shell (${SHELL}) variable
  name.
  Parameters:
    1 = The string to convert to a variable name.
  Returns:
    A string which can be used as the name of a shell variable.
endef
help-${_macro} := $(call _help)
${_macro} = _$(subst -,_,$(1))

_macro := To-Lower
define _help
${_macro}
  Transform all upper case characters to lower case in a string.
endef
help-${_macro} := $(call _help)
${_macro} = $(shell tr '[:upper:]' '[:lower:]' <<< $(1))

_macro := To-Upper
define _help
${_macro}
  Transform all lower case characters to upper case in a string.
endef
help-${_macro} := $(call _help)
${_macro} = $(shell tr '[:lower:]' '[:upper:]' <<< $(1))

_macro := Require
define _help
${_macro}
  Use this macro to verify variables are set.
  Parameters:
    1 = A list of required variables.
  Returns:
    A list of undefined variables.
endef
help-${_macro} := $(call _help)
define ${_macro}
$(strip \
  $(call Enter-Macro,$(0),$(1))
  $(call Debug,Requiring defined variables:$(1))
  $(eval _r :=)
  $(foreach _v,$(1),
    $(call Debug,Requiring: ${_v})
    $(if $(findstring undefined,$(flavor ${_v})),
      $(eval _r += ${_v})
      $(call Signal-Error,${Caller} requires variable ${_v} must be defined.)
    )
  )
  $(call Exit-Macro)
  ${_r}
)
endef

define _mbof
  $(if $(filter ${$(1)},$(2)),
    $(call Debug,$(1)=${$(1)} and is a valid option) 1
  ,
    $(call Signal-Error,Variable $(1)=${$(1)} must equal one of: $(2))
  )
endef

_macro := Must-Be-One-Of
define _help
${_macro}
  Verify a variable has a valid value. If not then issue a warning.
  Parameters:
    1 = The name to verify is in the list.
    2 = List of valid values.
  Returns:
    A non-empty string if the name is a member of the list.
endef
help-${_macro} := $(call _help)
define ${_macro}
$(strip
  $(call Enter-Macro,$(0),$(1) $(2))
  $(call _mbof,$(1),$(2))
  $(call Exit-Macro)
)
endef

_macro := Overridable
define _help
${_macro}
  Declare a variable which may be overridden. This mostly makes it obvious
  which variables are intended to be overridable. The variable is declared
  as a simply expanded variable only if it has not been previously defined.
  An overridable variable can be declared only once. To override the variable
  assign a value BEFORE Overridable is called or on the make command line.
  Parameters:
    1 = The variable name.
    2 = The value.
endef
help-${_macro} := $(call _help)
OverridableVars :=
define ${_macro}
  $(call Enter-Macro,$(0),$(1) $(2))
  $(if $(filter $(1),${OverridableVars}),
    $(call Signal-Error,Var $(1) has already been declared.)
  ,
    $(eval OverridableVars += $(1))
    $(if $(filter $(origin $(1)),undefined),
      $(eval $(1) := $(2))
    ,
      $(call Debug,Var $(1) has override value: ${$(1)})
    )
  )
  $(call Exit-Macro)
endef
#--------------

#++++++++++++++
# Makefile segment handling.
_macro := Last-Segment-Id
define _help
${_macro}
  Returns the ID of the most recently included makefile segment.
endef
help-${_macro} := $(call _help)
${_macro} = $(words ${MAKEFILE_LIST})

_macro := Last-Segment-File
define _help
${_macro}
  Returns the file name of the most recently included makefile segment.
endef
help-${_macro} := $(call _help)
${_macro} = $(word $(words ${MAKEFILE_LIST}),${MAKEFILE_LIST})

_macro := Last-Segment-Basename
define _help
${_macro}
  Returns the basename of the most recently included makefile segment.
endef
help-${_macro} := $(call _help)
${_macro} = \
  $(basename $(notdir $(word $(words ${MAKEFILE_LIST}),${MAKEFILE_LIST})))

_macro := Last-Segment-Var
define _help
${_macro}
  Returns the name of the most recently included makefile segment.
endef
help-${_macro} := $(call _help)
${_macro} = \
  $(subst -,_,$(call Last-Segment-Basename))

_macro := Last-Segment-Path
define _help
${_macro}
  Returns the directory of the most recently included makefile segment.
endef
help-${_macro} := $(call _help)
${_macro} = \
  $(realpath $(dir $(word $(words ${MAKEFILE_LIST}),${MAKEFILE_LIST})))

_macro := Get-Segment-File
define _help
${_macro}
  Returns the file name of the makefile segment corresponding to ID.
endef
help-${_macro} := $(call _help)
${_macro} = $(word $(1),${MAKEFILE_LIST})

_macro := Get-Segment-Basename
define _help
${_macro}
  Returns the basename of the makefile segment corresponding to ID.
  Parameters:
    1 = ID of the segment.
endef
help-${_macro} := $(call _help)
${_macro} = \
  $(basename $(notdir $(word $(1),${MAKEFILE_LIST})))

_macro := Get-Segment-Var
define _help
${_macro}
  Returns the name of the makefile segment corresponding to ID.
  Parameters:
    1 = ID of the segment.
endef
help-${_macro} := $(call _help)
${_macro} = \
  $(subst -,_,$(call Get-Segment-Basename,$(1)))

_macro := Get-Segment-Path
define _help
${_macro}
  Returns the path of the makefile segment corresponding to ID.
  Parameters:
    1 = ID of the segment.
endef
help-${_macro} := $(call _help)
${_macro} = \
  $(realpath $(dir $(word $(1),${MAKEFILE_LIST})))

_macro := SegPaths
SegPaths = ${SegPaths}
define _help
${_macro}
  The list of paths to search to find or use a segment.
endef
help-${_macro} := $(call _help)
${_macro} :=  $(call Get-Segment-Path,1)

_macro := Add-Segment-Path
define _help
${_macro}
  Add one or more path(s) to the list of segment search paths (SegPaths).
  Parameters:
    1 = The path(s) to add.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0),$(1))
  $(if $(filter $(1),${SegPaths}),
    $(call Verbose,Seg path $(1) was already added.)
  ,
    $(eval SegPaths += $(1))
    $(call Verbose,Added path(s):$(1))
  )
  $(call Exit-Macro)
endef

_macro := Find-Segment
define _help
${_macro}
  Search a list of directories for a segment and save its path in a variable.
  The segment can exist in multiple locations and only the last one in the
  list will be found. If the segment is not found in any of the directories
  then the current segment directory (Segment-Path) is searched.
  If the segment cannot be found an error message is added to the error list.
  Parameters:
    1 = The segment to find.
    2 = The name of the variable to store the result in.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0),$(1) $(2))
  $(eval $(2) := )
  $(call Debug,Locating segment: $(1))
  $(call Debug,Segment paths:${SegPaths} $(call Get-Segment-Path,${SegId}))
  $(foreach _p,${SegPaths} $(call Get-Segment-Path,${SegId}),
    $(call Debug,Trying: ${_p})
    $(if $(wildcard ${_p}/$(1).mk),
      $(eval $(2) := ${_p}/$(1).mk)
    )
  )
  $(if ${$(2)},
    $(call Debug,Found segment:${$(2)})
  ,
    $(call Signal-Error,$(1).mk not found.)
  )
  $(call Exit-Macro)
endef

_macro := Use-Segment
define _help
${_macro}
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

  A template for new make segments can be generated using the Gen-Segment-Text
  macro (below).
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0),$(1))
  $(if $(findstring .mk,$(1)),
    $(call Debug,Including segment:${1})
    $(eval include $(1))
  ,
    $(if ${$(1).SegID},
      $(call Debug,Segment $(1) is already loaded.)
    ,
      $(call Find-Segment,$(1),_seg)
      $(call Debug,Using segment:${_seg})
      $(eval include ${_seg})
    )
  )
  $(call Exit-Macro)
endef

_macro := Set-Segment-Context
define _help
${_macro}
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
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0),$(1))
  $(eval SegId := $(1))
  $(eval Seg := $(call Get-Segment-Basename,$(1)))
  $(eval SegP := $(call Get-Segment-Path,$(1)))
  $(eval SegF := $(call Get-Segment-File,$(1)))
  $(eval SegV := $(call To-Shell-Var,${Seg}))
  $(call Exit-Macro)
endef

define _Push-SegID
  $(if $(filter ${SegId},${SegID_Stack}),
    $(call Attention,Recursive entry to ${SegId} detected.)
  )
  $(eval SegID_Stack += ${SegId})
  $(if ${DEBUG},
    $(call Log-Message, \
      $(words ${SegID_Stack})-->,${SegID_Stack})
    $(if ${Single_Step},$(call Step))
  )
endef

define _Pop-SegID
  $(if ${DEBUG},
    $(call Log-Message, \
      <--$(words ${SegID_Stack}),Restoring SegID:$(lastword ${SegID_Stack}))
  )
  $(eval _PrvSegID := $(lastword ${SegID_Stack}))
  $(eval \
    SegID_Stack := $(filter-out $(lastword ${SegID_Stack}),${SegID_Stack})
  )
endef

_macro := Enter-Segment
define _help
${_macro}
  This initializes the context for a new segment and saves information so
  that the context of the previous segment can be restored in the postamble.
  Sets the segment specific context variables:
    <seg>.SegId
      The ID for the segment. This is basically the index in MAKEFILE_LIST for
      the segment.
    <seg>.Seg
      The segment name.
    <seg>.SegV
      The name of the segment converted to a shell compatible variable name.
    <seg>.SegP
      The path to the makefile segment.
    <seg>.SegF
      The path and name of the makefile segment. This can be used as part of a
      dependency list.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0))
  $(eval __s := $(call Last-Segment-Basename))
  $(eval ${__s}.SegId := $(call Last-Segment-Id))
  $(eval $(call Debug,Entering segment: $(call Get-Segment-Basename,${${__s}.SegId})))
  $(eval ${__s}.Seg := $(call Last-Segment-Basename))
  $(eval ${__s}.SegP := $(call Last-Segment-Path))
  $(eval ${__s}.SegF := $(call Last-Segment-File))
  $(eval ${__s}.SegV := $(call To-Shell-Var,${__s}))
  $(call _Push-SegID)
  $(call Set-Segment-Context,${${__s}.SegId})
  $(call Exit-Macro)
  $(call _Push-Entry,${Seg})
endef

_macro := Exit-Segment
define _help
${_macro}
  This initializes the help message for the segment and restores the
  context of the previous segment.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0))
  $(call Debug,Exiting segment: ${Seg})
  $(call _Pop-SegID)
  $(eval $(call Set-Segment-Context,${_PrvSegID}))
  $(call Exit-Macro)
  $(call _Pop-Entry)
endef

_macro := Check-Segment-Conflicts
define _help
${_macro}
  This handles the case where a segment is being used more than once or
  the current segment is attempting to use the same prefix as a previously
  loaded segment.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0))
  $(eval __s := $(call Last-Segment-Basename))
  $(call Debug,\
    Segment exists: ID = ${${__s}.SegId}: file = $(call Get-Segment-File,${${__s}.SegId}))
  $(if \
    $(findstring \
      $(call Last-Segment-File),$(call Get-Segment-File,${${__s}.SegId})),
    $(call Info,\
      $(call Get-Segment-File,${${__s}.SegId}) has already been included.)
  ,
    $(call Signal-Error,\
      Prefix conflict with $(${__s}.Seg) in $(call Last-Segment-File).)
  )
  $(call Exit-Macro)
endef

_macro := Gen-Segment-Text
define ${_macro}
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# $(strip $(2))
#----------------------------------------------------------------------------
# The prefix $(1) must be unique for all files.
# The format of all the $(1) based names is required.
# +++++
# Preamble
$.ifndef $(1).SegId
$$(call Enter-Segment)
# -----

$$(call Info,New segment: Add variables, macros, goals, and recipes here.)

# The command line goal for the segment.
$${Seg}: $${SegF}

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
  $${Seg}
    Build this component.
  # Describe additional goals provided by the segment.
  help-$${Seg}
    Display this help.
$.endef
$.endif # help goal message.

$$(call Exit-Segment)
$.else # $$(call Last-Segment-Basename).SegId exists
$$(call Check-Segment-Conflicts)
$.endif # $$(call Last-Segment-Basename).SegId
# -----

endef
# Help is at the end of the macro declaration in this case because the
# macro is used to generate a portion of the help.
define _help
${_macro}
  This generates segment text which can then be written to a file.
  Parameters:
    1 = The segment name. This is used to name the segment file, associated
        variable and, specific goals.
    2 = A one line description.
  For example:
  $$(call Gen-Segment,sample-seg,This is a sample segment.)
  generates:
$(call Gen-Segment-Text,sample-seg,This is a sample segment.)
endef
help-${_macro} := $(call _help)

_macro := Gen-Segment-File
define _help
${_macro}
  This uses Gen-Segment-Text to generate a segment file and writes it to the
  specified file.
  Parameters:
    1 = The segment name. This is used to name the segment file, associated
        variable and, specific goals.
    2 = A one line description.
    3 = The full path to where to write the segment file.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0),$(1) $(2) $(3))
  $(file >$(3),$(call Gen-Segment-Text,$(1),$(2)))
  $(call Exit-Macro)
endef
#--------------

#++++++++++++++
# Goal management.
_macro := Resolve-Help-Goals
define _help
${_macro}
  This scans the goals for references to help and then insures the
  corresponding segment is loaded. This should be called only after all
  other segments have been loaded (Use-Segment) to avoid problems with
  variable declaration sequence dependencies. NOTE: All segments for which
  help is referenced must be in the segment search path (Add-Segment-Path).
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0))
  $(call Debug,Resolving help goals.)
  $(call Debug,Help goals: $(filter help-%,${Goals}))
  $(foreach _s,$(patsubst help-%,%,$(filter help-%,${Goals})),
    $(call Debug,Resolving help for help-${_s})
    $(if $(findstring undefined,$(flavor help-${_s})),
      $(if $(filter ${_s}.mk,${MAKEFILE_LIST}),
        $(call Debug,Segment ${_s} already loaded.)
      ,
        $(call Use-Segment,${_s})
        $(if $(findstring undefined,$(flavor help-${_s})),
          $(eval help-${_s} := help-${_s} is undefined.)
          $(call Signal-Error,${help-${_s}})
        )
      )
    ,
      $(call Debug,Help help-${_s} is defined.)
    )
  )
  $(call Exit-Macro)
endef

_macro := Is-Goal
define _help
${_macro}
  Returns the goal if it is a member of the list of goals. The special goal
  all is returned if all is in the list of goals.
  Parameters:
    1 = The goal to check.
endef
help-${_macro} := $(call _help)
${_macro} = $(or $(filter all,${Goals}),$(filter $(1),${Goals}))

_macro := Add-To-Manifest
define _help
${_macro}
  Add an item to a manifest variable.
  Parameters:
    1 = The list to add to.
    2 = The optional variable to declare for the value. Use "null" to skip
      declaring a new variable.
    3 = The value to add to the list.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0),$(1) $(2) $(3))
  $(call Debug,Adding $(3) to $(1))
  $(call Debug,Var: $(2))
  $(eval $(2) = $(3))
  $(call Debug,$(2)=$(3))
  $(eval $(1) += $(3))
  $(call Exit-Macro)
endef
#--------------

#++++++++++++++
# Directories and files.
_macro := Basenames-In
define _help
${_macro}
  Get the basenames of all the files in a directory matching a glob pattern.
  Parameters:
    1 = The glob pattern including path.
endef
help-${_macro} := $(call _help)
define ${_macro}
$(sort $(foreach f,$(wildcard $(1)),$(basename $(notdir ${f}))))
endef

_macro := Directories-In
define _help
${_macro}
  Get a list of directories in a directory. The path is stripped.
  Parameters:
    1 = The path to the directory.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(sort \
    $(strip $(foreach d,$(shell find $(1) -mindepth 1 -maxdepth 1 -type d),\
    $(notdir ${d})))
  )
endef

#--------------

#++++++++++++++
# Other helpers.
_macro := Confirm
define _help
${_macro}
  Prompts the user for a yes or no response. If the response matches the
  positive response then the positive response is returned. Otherwise an
  empty value is returned.
  Parameters:
    1 = The prompt for the response.
    2 = The expected positive response.
endef
help-${_macro} := $(call _help)
define ${_macro}
$(strip $(filter $(2),$(shell read -r -p "$(1) [$(2)|N]: "; echo $$REPLY)))
endef

_macro := Pause
define _help
${_macro}
  Wait until the Enter key is pressed.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(shell read -r -p "Press Enter to continue...")
endef

_macro := Return-Code
define _help
${_macro}
  Returns the return code (last line) of the output produced by Run. This can
  then be used in a conditional.
  Parameter:
    1 = The previously captured console output.
  Returns:
    If the return code equals 0 then nothing is returned. Otherwise, the
    return code is returned.
endef
help-${_macro} := $(call _help)
define ${_macro}
$(strip
  $(call Enter-Macro,$(0))
  $(if $(filter 0,$(lastword $(1))),,$(lastword $(1)))
  $(call Exit-Macro)
)
endef

_macro := Run
define _help
${_macro}
  Run a shell command and return the error code.
  Parameters:
    1 = The name of a variable to store the output in.
    2 = The command to run. This can be multiple commands separated by
        semicolons (;) or AND (&&) OR (||) conditionals.
  Returns:
    Run_Output
      The console output with the return code appended at the enf of the last
      line.
    Run_Rc
      The return code from the output.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0),$(1) $(2))
  $(call Debug,Command:$(1))
  $(eval Run_Output := $(shell $(1) 2>&1;echo $$?))
  $(call Debug,Run_Output = ${Run_Output})
  $(eval Run_Rc := $(call Return-Code,${Run_Output}))
  $(if ${Run_Rc},
    $(call Warn,Shell return code:${Run_Rc})
  )
  $(call Debug,Run_Rc = ${Run_Rc})
  $(call Exit-Macro)
endef

_macro := Gen-Command-Goal
define _help
${_macro}
  Generate a goal. This is provided to reduce repetitive typing. The goal is
  generated only if it is referenced on the command line.
  Parameters:
    1 = The name of the goal.
    2 = The commands for the goal.
    3 = An optional prompt. This generates a y/N confirmation and the goal is
        generated only if the response is y.
endef
help-${_macro} := $(call _help)
define ${_macro}
$(call Enter-Macro,$(0),$(1) $(2) $(3))
$(if $(call Is-Goal,$(1)),
  $(call Verbose,Generating $(1) to do "$(2)")
  $(if $(3),
    $(if $(call Confirm,$(3),y),
      $(eval
$(1):
$(strip $(2))
      )
    ,
    $(call Verbose,Not doing $(1))
    )
  ,
    $(eval
$(1):
$(strip $(2))
    )
  )
,
  $(call Verbose,Goal $(1) is not on command line.)
)
$(call Exit-Macro)
endef

#--------------

# Set SegId to the segment that included helpers so that the previous segment
# set by Enter-Segment and used by Exit-Segment will have a valid value.
_i := $(call Last-Segment-Id)
$(call Dec-Var,_i)
# Initialize the top level context.
$(call Set-Segment-Context,${_i})
$(call Debug,Included from: SegId = ${SegId})
${Seg}.Seg := ${Seg}
${Seg}.SegId := ${SegId}
${Seg}.SegP := $(call Get-Segment-Path,${SegId})
${Seg}.SegF := $(call Get-Segment-File,${SegId})
${Seg}.SegV := $(call To-Shell-Var,${Seg})

$(call Enter-Segment)

# These are helper functions for shell scripts (Bash).
HELPER_FUNCTIONS := ${${Seg}.SegP}/modfw-functions.sh
export HELPER_FUNCTIONS

#++++++++++++++
# Sticky variables.
# These need a proper segment context so context has been setup before
# defining the sticky macros.
_var := StickyVars
${_var} :=
define _help
${_var} = ${${_var}}
  This variable is the list of sticky variables which have been defined and is
  used to detect when a sticky variable is being redefined.
endef
help-${_var} := $(call _help)

_macro := Sticky
define _help
${_macro}
  A sticky variable is persistent and needs to be defined on the command line
  at least once or have a default value as an argument.
  Uses sticky.sh to make a variable sticky. If the variable has not been
  declared when this macro is called then the previous value is used. Defining
  the variable will overwrite the previous sticky value.
  Only the first call to Sticky for a given variable will be accepted.
  Additional calls will produce a redefinition error.
  Sticky variables are read only in a sub-make (MAKELEVEL != 0).
  Variables used:
    helpers.SegP=${helpers.SegP}
      The path to the helpers directory. Defaults to the directory
      containing this makefile segment.
    StickyVars=${StickyVars}
      The list of declared sticky variables. This is used to detect when a
      sticky variable is being redefined.
    STICKY_PATH=${STICKY_PATH}
      Where to store the sticky variable values.
      Default:${DEFAULT_STICKY_PATH}
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
      <default>.
  To ignore a sticky variable and instead use its default, from the command
  line use:
    <var>=""
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0),$(1) $(2))
  $(eval _spl := $(subst =,${Space},$(1)))
  $(eval _sp := $(word 1,${_spl}))
  $(call Debug,Sticky:Var:${_sp})
  $(eval _sv := $(word 2,${_spl}))
  $(call Debug,Sticky:Value:${_sv})
  $(if ${_sv},
  ,
    $(eval _sv := ${${_sp}})
  )
  $(call Debug,Sticky:New value:${_sv})
  $(call Debug,Sticky:Path: ${STICKY_PATH})
  $(if $(filter $(1),${StickyVars}),
    $(call Signal-Error,Redefinition of sticky variable ${_sp} ignored.)
  ,
    $(eval StickyVars += ${_sp})
    $(if ${SubMake},
      $(call Debug,Variables are read-only in a sub-make.)
      $(if ${${_sp}},
      ,
        $(call Debug,Reading variable ${${_sp}})
        $(eval ${_sp}:=$(shell \
          ${helpers.SegP}/sticky.sh ${_sp}= ${STICKY_PATH} $(2)))
      )
    ,
      $(eval ${_sp}:=$(shell \
        ${helpers.SegP}/sticky.sh ${_sp}=${_sv} ${STICKY_PATH} $(2)))
    )
  )
  $(call Exit-Macro)
endef

_macro := Get-Sticky
define _help
${_macro}
  Return the value of a sticky variable.
  Parameters:
    1 = Variable name.
endef
help-${_macro} := $(call _help)
${_macro} = $(file < ${STICKY_PATH}/$(1))

_macro := Redefine-Sticky
define _help
${_macro}
  Redefine a sticky variable that has been previously set. The variable is
  saved only if its new value is different than its current value and not
  running as a submake.
  Parameters:
    1 = Variable name[=<value>]
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0),$(1))
  $(eval _rspl := $(subst =,${Space},$(1)))
  $(eval _rsp := $(word 1,${_rspl}))
  $(eval _rsv := $(word 2,${_rspl}))
  $(if $(filter ${_rsp},${StickyVars}),
    $(call Signal-Error,Var ${_rsp} has not been defined.)
  ,
    $(eval _rscv := $(call Get-Sticky,${_rsp}))
    $(if $(filter ${_rsv},${_rscv}),
      $(call Debug,Var ${_rsp} is unchanged.)
    ,
      $(call Debug,Redefining:$(1))
      $(call Debug,Resetting var:${_rsp})
      $(call file > $(STICKY_PATH)/${_rsp},${_rsv})
    )
  )
  $(call Exit-Macro)
endef

_macro := Remove-Sticky
define _help
${_macro}
  Remove (unstick) a sticky variable.
  Parameters:
    1 = Variable name to remove.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0),$(1))
  $(if $(filter $(1),${StickyVars}),
    $(call Debug,Removing sticky variable: $(1))
    $(eval StickyVars := $(filter-out $(1),${StickyVars}))
    $(eval undefine $(1))
    $(shell rm ${STICKY_PATH}/$(1))
  ,
    $(call Debug,Var $(1) has not been defined.)\
  )
  $(call Exit-Macro)
endef
#--------------

#++++++++++++++
# Other macros.

_macro := More-Help
define _help
${_macro}
  Add help messages to the help output.
  Parameters:
    1 = The name of the variable containing the list of macros or variables for
        which to add help messages.
  Defines:
    MoreHelpList
      The list of help messages to append to the help output.
endef
help-${_macro} := $(call ${_help})
define ${_macro}
  $(call Enter-Macro,$(0),$(1))
  $(if $(1),
    $(call Debug,Help list for:$(1):${$(1)})
    $(eval $(1)_MoreHelpList := )
    $(foreach _sym,${$(1)},
      $(call Debug,Adding help for:${_sym})
      $(if $(filter $(origin help-${_sym}),undefined),
        $(call Warning,Undefined help message: help-${_sym})
      ,
        $(eval $(1)_MoreHelpList += help-${_sym})
      )
    )
  ,
    $(call Warning,Attempt to add empty help list ignored.)
  )
  $(call Exit-Macro)
endef

#--------------

# Special goal to force another goal.
FORCE:

$(call Info,Goals: ${Goals})

.DEFAULT_GOAL := ${DefaultGoal}

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

ifneq (${LOG_FILE},)
display-messages: ${LogFile}
> less $<
else
  $(call Attention,Use LOG_FILE=<file> to enable message logging.)
display-messages:
endif

display-errors:
> @if [ -n '${ErrorList}' ]; then \
  m="${ErrorList}";printf "Errors:$${m//${NewLine}/\\n}" | less;\
  fi

show-%:
> @echo '$*=$($*)'

define _Call-Macro
$(eval _w := $(subst :, ,$(2)))
$(foreach pn,1 2 3,
  $(eval p${pn} := $(subst +, ,$(word ${pn},${_w})))
  $(call Debug,p${pn}:${p${pn}})
)
$(call $(1),${p1},${p2},${p3})
endef

call-%:
> $(file >${TmpPath}/call-$*,$(call _Call-Macro,$*,${$*.PARMS}))
> less ${TmpPath}/call-$*
> rm ${TmpPath}/call-$*

help-%:
> $(file >${TmpPath}/help-$*,${help-$*})
> $(if ${$*_MoreHelpList},\
    $(foreach _h,${$*_MoreHelpList},\
      $(file >>${TmpPath}/help-$*,==== ${_h} ====)\
      $(file >>${TmpPath}/help-$*,${${_h}})))
> less ${TmpPath}/help-$*
> rm ${TmpPath}/help-$*

#.PHONY: help help-Usage
help: help-Usage

origin-%:
> @echo 'Origin:$*=$(origin $*)'

ifneq ($(call Is-Goal,help-${Seg}),)

define help-${helpers.Seg}
Make segment: ${helpers.Seg}.mk

This collection of variables and macros help simplify and improve consistency
across different projects using make. Projects should include this makefile
segment as early as possible.

NOTE: These macros and variables are NOT intended to be used as part of
recipes. Instead, they are called as makefile segments are read by make. The
concept is similar to that of a C preprocessor.

Naming conventions:
<seg>           The name of a segment. This is used to declare segment specific
                variables and to derive directory and file names. As a result
                no two segments can have the same file name.
<seg>.mk        The name of a makefile segment. A makefile segment is designed
                to be included from another file. These should be formatted to
                contain a preamble and postamble. See help-helpers for more
                information.
GLOBAL_VARIABLE Can be overridden on the command line. Sticky variables should
                have this form unless they are for a component in which case
                the should use the <seg>_VARIABLE form (below). See
                help-helpers for more information about sticky variables.
GlobalVariable  Camel case is used to identify variables defined by the
                helpers. This is mostly helpers.mk.
Global_Variable This form is also used by the helpers to bring more attention
                to a variable.
<ctx>           A specific context. A context can be a segment, macro or
                group of related variables.
<ctx>.VARIABLE  A global variable prefixed with the name of specific context.
                These can be overridden on the command line.
                Context specific sticky variables should use this form.
<ctx>.Variable  A global variable prefixed with the name of the segment
                defining the variable. These should not be overridden.
_private_variable or _Private_Variable or _PrivateVariable
                Make segment specific. Should not be used by other segments
                since these can be changed without concern for other segments.
Callable-Macro  The name of a callable macro available to all segments.
_private-macro or _Private-Macro
                A private macro specific to a segment.

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
  ${helpers.Seg}.mk sets make variables to simplify editing rules in some editors
  which don't handle tab characters very well.

SHELL = ${SHELL}
  Also to enable some bash specific features.

True = ${True}
  A true value for boolean conditionals.

False = ${False}
  A false value for boolean conditionals.

SubMake = ${SubMake}
  This is NOT empty (equal to False) when running as a nested run of make.

WorkingPath = ${WorkingPath}
  The full path to the current directory when make was invoked.

WorkingDir = ${WorkingDir}
  The name is the last directory in the WorkingPath.

WorkingVar = ${WorkingVar}
  The WorkingDir converted to a string which can be used as part of a shell variable name.

TmpDir = ${TmpDir}
  The name of the directory where temporary files are stored.

TmpPath = ${TmpPath}
  The full path to the temporary directory.

Platform = $(Platform)
  The platform (OS) on which make is running. This can be one of:
  Microsoft, Linux, or OsX.
Errors = ${Errors}
  If not empty then errors have been reported.

${help-SegID_Stack}

${help-Entry_Stack}

${help-Caller}

Defines the helper macros:

++++ Message logging.
Because message lists can become lengthy they are not retained in memory. The
messages can be routed to a log file.

Command line options:
LOG_FILE := ${LOG_FILE}
  When defined all messages are written to a log file and the display-messages
  goal will display them. This is the log file name only -- no path. The
  display-messages goal exists only when LOG_FILE is defined. The log file is
  reset on each run of make except when run as a submake (MAKELEVEL does not equal 0) which continues to use the same log file.
  Uses:
    LogPath = ${LogPath}
      Where log files are written to. This is always relative to the
      temporary directory.
    LogFile = ${LogFile}
      The file the messages are written to.

++++ Variables and variable naming

${help-Inc-Var}

${help-Dec-Var}

${help-Add-Var}

${help-Sub-Var}

${help-To-Shell-Var}

${help-Require}

${help-Must-Be-One-Of}

${help-Sticky}

${help-Redefine-Sticky}

${help-Overridable}

+++++ Makefile segment handling.
${help-Last-Segment-Id}

${help-Last-Segment-File}

${help-Last-Segment-Basename}

${help-Last-Segment-Var}

${help-Last-Segment-Path}

${help-Get-Segment-Basename}

${help-Get-Segment-Var}

${help-Get-Segment-Path}

${help-Set-Segment-Context}

${help-SegPaths}

${help-Add-Segment-Path}

${help-Find-Segment}

${help-Use-Segment}

${help-Enter-Segment}

${help-Exit-Segment}

${help-Check-Segment-Conflicts}

${help-Gen-Segment-Text}

${help-Gen-Segment-File}

+++++ Make goals or targets
${help-Is-Goal}

${help-Resolve-Help-Goals}

${help-Add-To-Manifest}

+++++ Strings and messaging

NewLine = ${NewLine}
  Use this macro to insert new lines into multiline messages.

Space = ${Space}
  This is intended to be used in substitution patterns where a space is
  required.

Dlr = ${Dlr}
  This is a dollar sign and is intended to be used in macros that expand
  to bash command lines which include references to environment variables.

Comma = ${Comma}
  This is a comma and is intended to be used in macros that expand to strings
  which would otherwise confuse the makefile parser.

${help-Div}

${help-Log-Message}

${help-Info}

${help-Attention}

${help-Set-Message-Callback}

${help-Message_Callback}

${help-Message_Safe}

${help-Set-Warning-Callback}

${help-Warning_Callback}

${help-Warning_Safe}

${help-Warn}

${help-Verbose}

${help-Set-Error-Callback}

${help-Error_Callback}

${help-Error_Safe}

${help-Signal-Error}

${help-Enter-Macro}

${help-Exit-Macro}

$(help-QUIET)

+++++ Debug support

When DEBUG is defined macro call trace messages are emitted. These are
prefixed with --> for entry into a segment or macro and <-- for exit from
a segment or macro.

When DEBUG is defined the following macros are defined:
${help-Debug}

${help-Step}

${help-Enable-Single-Step}

${help-Disable-Single-Step}

+++++ Paths and file names
${help-Basenames-In}

${help-Directories-In}

+++++ Makefile execution control
${help-Confirm}

${help-Pause}

${help-Return-Code}

${help-Run}

${help-Gen-Command-Goal}

Special goals:
show-<var>
  Display the value of any variable.

call-<macro>
  Call a macro with parameters.
  Uses:
    <macro>.PARMS
      A list of parameters to pass to the macro. The macro name provides
      context so that multiple calls can be used on the command line.
      Because of the limited manner in which make deals with strings and
      lists of parameters special characters are needed to indicate
      different parameters versus strings. Parameters are separated using the
      colon character (:) and spaces in a parameter are indicated using the
      plus character (+).
      A maximum of three parameters are supported.
      Output form the macro is routed to a text file and then displayed using
      less.
      WARNING: This may not work for all macros. The list of macros this can
      be used with is currently undefined.
      For example:
        <macro>.PARMS="parm1:parm2+string"
        This declares two parameters where the second parameter is a string.

help
  Display the help for the makefile. This help must be named "help-Usage".

help-<sym>
  Display the help for a specific macro, segment, or variable.

origin-<var>
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
$(call Debug,${helpers.Seg}.SegID:${${helpers.Seg}.SegID})
$(call Exit-Segment)
else # Already loaded.
$(call Check-Segment-Conflicts)
endif # helpers.SegId
