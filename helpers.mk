#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Helper macros for makefiles.
#----------------------------------------------------------------------------
ifndef helpersSegId

# Changing the prefix because some editors, like vscode, don't handle tabs
# in make files very well. This also slightly improves readability.
.RECIPEPREFIX := >
# NOTE: Bash is required because of some bash-isms being used.
SHELL = /bin/bash

True := 1
False :=

ifeq (${MAKELEVEL},0)
  SubMake := ${False}
else
  SubMake := ${True}
endif

# The directory containing the makefile.
WorkingPath = $(realpath $(dir $(word 1,${MAKEFILE_LIST})))
WorkingDir = $(notdir ${WorkingPath})
WorkingVar := _$(subst -,_,$(WorkingDir))
TmpDir := ${WorkingDir}
TmpPath := /tmp/${TmpDir}
$(shell mkdir -p ${TmpPath})
LogPath := ${TmpPath}/log
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
DEFAULT_STICKY_PATH := ${WorkingPath}/.${WorkingDir}/sticky

STICKY_PATH := ${DEFAULT_STICKY_PATH}

# This indicates when running as a nested make.
#++++++++++++++
# For messages.
NewLine = nlnl
_empty :=
Space := ${_empty} ${_empty}
Comma := ,
Dlr := $

_var := Entry_Stack
define _help
${_var}
  This is a special variable containing the list of macros and segment which
  have been entered using Enter-Macro and Enter-Segment. The last item on the
  stack is emitted with all messages.
endef
help-${_var} := $(call _help)
Entry_Stack :=

define Format-Message
  $(if ${LOG_FILE},
    $(file >>${LogFile},\
      $(strip $(1)):${Seg}:$(lastword ${Entry_Stack}):$(strip $(2)))
  )
  $(if ${QUIET},
  ,
    $(if $(filter $(lastword $(2)),${NewLine}),
      $(info )
    )
    $(info $(strip $(1)):${Seg}:$(lastword ${Entry_Stack}):$(strip $(2)))
  )
  $(eval Messages = yes)
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
  $(call Format-Message,....,$(1))
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
  $(call Format-Message,ATTN,$(1))
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
  $(call Format-Message,WARN,$(1))
endef

_V:=n
ifneq (${VERBOSE},)
_macro := Verbose
define _help
${_macro}
  Displays the message if VERBOSE has been defined. All verbose messages are
  automatically added to the message list. Verbose messages are prefixed with
  vbrs.
  NOTE: This is NOT intended to be used as part of a recipe.
  Parameters:
    1 = The message to display.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Format-Message,vbrs,$(1))
endef
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
  $(call Format-Message,dbug,$(1))
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
  $(eval Entry_Stack += $(1))
  $(if ${DEBUG},
    $(call Format-Message, \
      $(words ${Entry_Stack})-->,${Entry_Stack})
    $(if ${Single_Step},$(call Step))
  )
endef

define _Pop-Entry
  $(if ${DEBUG},
    $(call Format-Message, \
      <--$(words ${Entry_Stack}),Exiting:$(lastword ${Entry_Stack}))
  )
  $(eval \
    Entry_Stack := $(filter-out $(lastword ${Entry_Stack}),${Entry_Stack})
  )
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
    $(call Format-Message,====,$(2))
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

_macro := Enable-Single-Step
define _help
${_macro}
  When single step mode is enabled and DEBUG is not empty Step is called
  every time a macro is entered.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,Enable-Single-Step)
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
  $(call Enter-Macro,Disable-Single-Step)
  $(eval Single_Step :=)
  $(call Exit-Macro)
endef

MAKEFLAGS += --debug=${_V}

Error_Handler :=
# This is a semaphore which is ued to avoid recursive calls to an installed
# error handler. If the variable is equal to 1 then a call to the error handler
# is safe.
Error_Safe := 1

_macro := Set-Error-Handler
define _help
${_macro}
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
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,Set-Error-Handler)
  $(eval Error_Handler := $(1))
  $(call Exit-Macro)
endef

_macro := Signal-Error
define _help
${_macro}
  Use this macro to issue an error message as a warning and signal a
  delayed error exit. The messages can be displayed using the display-errors
  goal. Error messages are prefixed with ERR?.
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
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(eval ErrorList += ${NewLine}ERR?:${Seg}:$(1))
  $(call Format-Message,ERR?,$(1))
  $(eval Errors = yes)
  $(warning Error:${Seg}:$(1))
  $(call Debug,Handler: ${Error_Handler} Safe:${Error_Safe})
  $(if ${Error_Handler},
    $(if ${Error_Safe},
      $(eval Error_Safe := )
      $(call Debug,Calling ${Error_Handler}.)
      $(call Debug,Message:$(1).)
      $(call ${Error_Handler},$(1))
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
  $(eval $(1):=$(shell expr $($(1)) + 1))
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
  $(eval $(1):=$(shell expr $($(1)) - 1))
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
  $(call Enter-Macro,Require)
  $(call Debug,Requiring defined variables:$(1))
  $(eval _r :=)
  $(foreach _v,$(1),
    $(call Debug,Requiring: ${_v})
    $(if $(findstring undefined,$(flavor ${_v})),
      $(eval _r += ${_v})
      $(call Signal-Error,${Seg} requires variable ${_v} must be defined.)
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
  $(call Enter-Macro,Must-Be-One-Of)
  $(call _mbof,$(1),$(2))
  $(call Exit-Macro)
)
endef

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
endef
help-${_macro} := $(call _help)
StickyVars :=
define ${_macro}
  $(call Enter-Macro,Sticky)
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
          ${helpersSegP}/sticky.sh ${_sp}= ${STICKY_PATH} $(2)))
      )
    ,
      $(eval ${_sp}:=$(shell \
        ${helpersSegP}/sticky.sh ${_sp}=${_sv} ${STICKY_PATH} $(2)))
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
  $(call Enter-Macro,Redefine-Sticky)
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
  $(call Enter-Macro,Remove-Sticky)
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
  $(call Enter-Macro,Overridable)
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
  $(call Enter-Macro,Add-Segment-Path)
  $(eval SegPaths += $(1))
  $(call Debug,Added path(s):$(1))
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
  $(call Enter-Macro,Find-Segment)
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
  $(call Enter-Macro,Use-Segment)
  $(if $(findstring .mk,$(1)),
    $(call Debug,Including segment:${1})
    $(eval include $(1))
  ,
    $(call Find-Segment,$(1),_seg)
    $(call Debug,Using segment:${_seg})
    $(eval include ${_seg})
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
  $(call Enter-Macro,Set-Segment-Context)
  $(eval SegId := $(1))
  $(eval Seg := $(call Get-Segment-Basename,$(1)))
  $(eval SegP := $(call Get-Segment-Path,$(1)))
  $(eval SegF := $(call Get-Segment-File,$(1)))
  $(eval SegV := $(call To-Shell-Var,${Seg}))
  $(call Exit-Macro)
endef

_macro := Enter-Segment
define _help
${_macro}
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
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,Enter-Segment)
  $(eval __s := $(call Last-Segment-Basename))
  $(eval ${__s}SegId := $(call Last-Segment-Id))
  $(eval $(call Debug,Entering segment: $(call Get-Segment-Basename,${${__s}SegId})))
  $(eval ${__s}Seg := $(call Last-Segment-Basename))
  $(eval ${__s}SegP := $(call Last-Segment-Path))
  $(eval ${__s}SegF := $(call Last-Segment-File))
  $(eval ${__s}SegV := $(call To-Shell-Var,${__s}))
  $(eval ${__s}PrvSegId := ${SegId})
  $(call Set-Segment-Context,${${__s}SegId})
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
  $(call Enter-Macro,Exit-Segment)
  $(call Debug,Exiting segment: ${Seg})
  $(eval $(call Set-Segment-Context,${${Seg}PrvSegId}))
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
  $(call Enter-Macro,Check-Segment-Conflicts)
  $(eval __s := $(call Last-Segment-Basename))
  $(call Debug,\
    Segment exists: ID = ${${__s}SegId}: file = $(call Get-Segment-File,${${__s}SegId}))
  $(if \
    $(findstring \
      $(call Last-Segment-File),$(call Get-Segment-File,${${__s}SegId})),
    $(call Info,\
      $(call Get-Segment-File,${${__s}SegId}) has already been included.)
  ,
    $(call Signal-Error,\
      Prefix conflict with $(${__s}Seg) in $(call Last-Segment-File).)
  )
  $(call Exit-Macro)
endef

_macro := Gen-Segment-Text
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
define ${_macro}
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
$.else # $$(call Last-Segment-Basename)SegId exists
$$(call Check-Segment-Conflicts)
$.endif # $$(call Last-Segment-Basename)SegId
# -----

endef

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
  $(call Enter-Macro,Gen-Segment-File)
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
  $(call Enter-Macro,Resolve-Help-Goals)
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
  Returns the goal if it is a member of the list of goals.
  Parameters:
    1 = The goal to check.
endef
help-${_macro} := $(call _help)
${_macro} = $(filter $(1),${Goals})

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
  $(call Enter-Macro,Add-To-Manifest)
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
  $(call Enter-Macro,Return-Code)
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
  $(call Enter-Macro,Run)
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
$(call Enter-Macro,Gen-Command-Goal)
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
${Seg}Seg := ${Seg}
${Seg}SegId := ${SegId}
${Seg}SegP := $(call Get-Segment-Path,${SegId})
${Seg}SegF := $(call Get-Segment-File,${SegId})
${Seg}SegV := $(call To-Shell-Var,${Seg})

$(call Enter-Segment)

# These are helper functions for shell scripts (Bash).
HELPER_FUNCTIONS := ${${Seg}SegP}/modfw-functions.sh
export HELPER_FUNCTIONS

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

ifneq (${LOG_FILE},)
display-messages: ${LogFile}
> less $<
else
  $(call Attention,Use LOG_FILE=1 to enable message logging.)
display-messages:
endif

display-errors:
> @if [ -n '${ErrorList}' ]; then \
  m="${ErrorList}";printf "Errors:$${m//${NewLine}/\\n}" | less;\
  fi

show-%:
> @echo '$*=$($*)'

help-%:
> $(file >${TmpPath}/help-$*,$(help-$*)) less ${TmpPath}/help-$*
> rm ${TmpPath}/help-$*

origin-%:
> @echo 'Origin:$*=$(origin $*)'

ifneq ($(call Is-Goal,help-${Seg}),)

define help-${helpersSeg}
Make segment: ${helpersSeg}.mk

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
  ${helpersSeg}.mk sets make variables to simplify editing rules in some editors
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

Platform = $(Platform)
  The platform (OS) on which make is running. This can be one of:
  Microsoft, Linux, or OsX.
Errors = ${Errors}
  If not empty then errors have been reported.

Defines the helper macros:

++++ Message logging.
Because message lists can become lengthy they are not retained in memory. The
messages can be routed to a log file.

Command line options:
LOG_FILE := ${LOG_FILE}
  When defined all messages are written to a log file and the display-messages
  goal will display them. This is the log file name only -- no path. The
  display-messages goal exists only when LOG_FILE is defined. The log file is
  reset on each run of make except when run as a submake (MAKELEVEL does not
  equal 0).
  Defines:
    LogPath = ${LogPath}
      Where log files are written to. This is always relative to the
      working directory.
    LogFile = ${LogFile}
      The file the messages are written to.

++++ Variables and variable naming

${help-Inc-Var}

${help-Dec-Var}

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

${help-Info}

${help-Attention}

${help-Warn}

${help-Verbose}

${help-Set-Error-Handler}

${help-Signal-Error}

${help-Entry_Stack}

${help-Enter-Macro}

${help-Exit-macro}

If QUIET is not empty then all messages except error messages are suppressed.
They are still added to the message list and can still be displayed using
the display-messages goal.

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
show-%
  Display the value of any variable.

help-%
  Display the help for a specific macro or segment.

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
$(call Debug,${helpersSeg}SegID:${${helpersSeg}SegID})
$(call Exit-Segment)
else # Already loaded.
$(call Check-Segment-Conflicts)
endif # helpersSegId
