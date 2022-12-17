#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Helper macros for makefiles.
#----------------------------------------------------------------------------
#+
# NOTE: Helper macros can only use variables defined in config.mk.
#-

#+
# Get the included file base name (no path or extension).
#
# Returns:
#   The segment base name.
#-
this_segment = \
  $(basename $(notdir $(word $(words ${MAKEFILE_LIST}),${MAKEFILE_LIST})))

#+
# Get the included file directory path.
#
# Returns:
#   The path to the current segment.
#-
this_segment_dir = \
  $(basename $(dir $(word $(words ${MAKEFILE_LIST}),${MAKEFILE_LIST})))

#+
# Display messages when VERBOSE is defined.
# Parameters:
#  1 = The message to display.
#-
ifdef VERBOSE
define verbose
    $(info verbose:$(1))
endef
endif

#+
# Add an item to a manifest variable.
# Parameters:
#   1 = The list to add to.
#   2 = The optional variable to declare for the value. Use "null" to skip
#       declaring a new variable.
#   3 = The value to add to the list.
#-
define add-to-manifest
  $$(call verbose,Adding $(3) to $(1))
  ifneq ($(2),null)
    $$(call verboase,Declaring: $(2))
    $(2) = $(3)
  endif
  $(1) += $(3)
endef

#+
# Use this macro to insert new lines into multiline messages.
#-
define newline
nlnl
endef

#+
# Use this macro to issue an error message as a warning and signal an
# error exit.
#  Paramaters:
#    1 = The error message.
#-
ifeq (${MAKECMDGOALS},help)
  define signal_error
    $(eval ErrorMessages += $(1)$(newline))
  endef
else
  define signal_error
    $(error ERROR: $1 -- Use: make help)
  endef
endif

#+
# This private macro is used to verify a single variable exists.
# If the variable is empty then an error message is appended to ErrorMessages.
# Parmeters:
#   1 = The name of the variable.
#   2 = The module in which it is required.
#-
define _require_this
  $(call verbose,Requiring: $(1))
  $(if ${$(1)},\
    ,\
    $(eval ErrorMessages += Variable $(1) must be defined in: $(2)$(newline))\
  )
endef

#+
# Use this macro to verify variables are set.
#  Parameters:
#    1 = The make file segment.
#    2 = A list of required variables.
#-
define require
  $(call verbose,Required in: $(1))
  $(foreach v,$(2),$(call _require_this,$(v), $(1)))
endef

#+
# This macro displays a list of accumulated messages if defined.
# Parameters:
# NOTE: This is intended to be used as part of a recipe.
#  1 = The heading for displaying the list of messages.
#  2 = The list of messages separated by ${newline}.
#-
define show-messages
@if [ -n '${$(2)}' ]; then \
    echo $(1);\
    m="${$(2)}";printf "$${m//${newline}/\\n}";\
    read -p "Press ENTER to continue...";\
  fi
endef

#+
# Verify a variable has a valid value. If doesn't then error.
# Parameters:
#  1 = Variable name
#  2 = List of valid values.
#-
define must_be_one_of
  $(if $(findstring ${$(1)},$(2)),\
    $(info $(1) = ${$(1)} and is a valid option),\
    $(warning $(1) must equal one of: $(2))\
  )
endef

#+
# Make a variable sticky (see help-config).
# Parameters:
#  1 = Variable name
# Returns:
#  The variable value.
#-
define sticky
  $(info Sticky variable: ${1})
  $(eval $(1)=$(shell ${HELPERS_DIR}/sticky.sh $(1)=${$(1)} ${STICKY_DIR}))
endef

#+
# Get the basenames of all the files in a directory matching a glob pattern.
# Parameters:
#  1 = The glob pattern including path.
#+
define basenames_in
  $(foreach file,$(wildcard $(1)),$(basename $(notdir ${file})))
endef

#+
# Display the value of any variable.
#-
show-%:
> @echo '$*=$($*)'
