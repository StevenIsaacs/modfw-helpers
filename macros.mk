#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Helper macros for makefiles.
#----------------------------------------------------------------------------
#+
# NOTE: Helper macros can only use variables defined in config.mk.
#-

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
this-segment-dir = \
  $(basename $(dir $(word $(words ${MAKEFILE_LIST}),${MAKEFILE_LIST})))

#+
# See help-macros
#-
ifdef VERBOSE
define verbose
    $(info verbose:$(1))
endef
# Prepend to recipe lines to echo commands being executed.
V := @
endif

#+
# See help-macros
#-
define add-to-manifest
  $$(call verbose,Adding $(3) to $(1))
  ifneq ($(2),null)
    $$(call verbose,Declaring: $(2))
    $(2) = $(3)
  endif
  $(1) += $(3)
endef

#+
# See help-macros
#-
define newline
nlnl
endef

#+
# See help-macros
#-
ifeq (${MAKECMDGOALS},help)
  define signal-error
    $(eval ErrorMessages += $(1)$(newline))
  endef
else
  define signal-error
    $(error ERROR: $1 -- Use: make help)
  endef
endif

#+
# This private macro is used to verify a single variable exists.
# If the variable is empty then an error message is appended to ErrorMessages.
# Parameters:
#   1 = The name of the variable.
#   2 = The module in which it is required.
#-
define _require-this
  $(call verbose,Requiring: $(1))
  $(if ${$(1)},\
    ,\
    $(warning Variable $(1) is not defined); \
    $(eval ErrorMessages += Variable $(1) must be defined in: $(2)$(newline))\
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
    $(info $(1) = ${$(1)} and is a valid option),\
    $(warning $(1) must equal one of: $(2))\
  )
endef

#+
# See help-macros
#-
define sticky
  $(info Sticky variable: ${1})
  $(eval $(1)=$(shell ${HELPERS_PATH}/sticky.sh $(1)=${$(1)} ${STICKY_PATH}))
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
display-messages:
> @if [ -n '${${MsgList}}' ]; then \
    echo ${MsgHeading};\
    m="${${MsgList}}";printf "$${m//${newline}/\\n}";\
    read -p "Press ENTER to continue...";\
  fi

#+
# See help-macros
#-
show-%:
> @echo '$*=$($*)'

ifneq ($(findstring help-macros,${MAKECMDGOALS}),)
define HelpMacrosMsg
Make segment: macros.mk

Defines the makefile helper macros. These are:

this-segment
    Returns the basename of the most recently included makefile segment.

this-segment-dir
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

signal-error
    Use this macro to issue an error message as a warning and signal a
    delayed error exit.
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
    at least once.
    Uses sticky.sh to make a variable sticky. If the variable has not been
    defined when this macro is called then the previous value is used. Defining
    the variable will overwrite the previous sticky value.
    WARNING: The variable must be defined at least once.
    Parameters:
        1 = Variable name
    Returns:
        The variable value.

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
    Parameters:
        MsgHeading  = The heading for displaying the list of messages.
        MsgList     = The name of the variable containing the list of messages
                      separated by ${newline}.

Defines:
    Platform = $(Platform)
        The platform (OS) on which make is running. This can be one of:
        Microsoft, Linux, or OsX.
endef

export HelpMacrosMsg
help-macros:
> @echo "$$HelpMacrosMsg" | less
endif
