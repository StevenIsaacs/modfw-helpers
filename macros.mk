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
# Use this macro to verify variables are set.
#  Parameters:
#    1 = A list of required variables.
#-
define _require_this
  $(if ${$(1)},\
    ,\
    $(eval ErrorMessages += Variable $(1) must be defined in: $(2)$(newline))\
  )
endef

define require
  $(foreach v,$(2),$(call _require_this,$(v), $(1)))
endef

#+
# Verify a variable has a valid value. If doesn't then error.
# Parameters:
#  1 = Variable name
#  2 = List of valid values.
#-
define must_be_one_of
  $(if $(filter ${$(1)},$(2)),\
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
# Declare an item in a manifest. A manifest is a list of items which are
# associated with each other.
# Parameters:
#  1 = The manifest
#  2 = The line item in the manifest. Use dummy if not important.
#  3 = The path to the line item.
#-
define add-to-manifest
${2} = ${3}
${1} += ${2}
endef

# Display the value of any variable.
show-%:
> @echo '$*=$($*)'

ifneq ($(findstring help-macros,${MAKECMDGOALS}),)
define HelpMacrosMsg
Make segment: macros.mk

Defines a number of useful macros.

Defines:

this_segment
  This callable macro returns the basename of the newly included make segment.
  This should be used at the beginning of a make segment and before including
  additional make segments.

this_segment_dir
  This callable macro returns the path to the newly included make segment.
  This should be used at the beginning of a make segment and before including
  additional make segments.
  Returns:
    The path to the make segment.

newline
  Use this macro to insert a newline pattern into a multiline message.

signal_error
  Generates an error message and exits make.
  Parameters:
    1 = The error message.

require
  A callable marco which verifies each of the variables in a list have
  been defined.
  Parameters:
    1 = A list of variable names.
  Returns:
    Adds a message to the error message list for each of the variables which
    have not been defined.

must_be_one_of
  A callable macro which verifies the value of a variable is one of the
  values in a list of possible values.
  Parameters:
    1 = The name of the variable.
    2 = A space delimited list of acceptable values.
  Returns:
    Issues a warning if the variable does not have a valid value.

sticky
  A callable macro for setting sticky options. This can be used in a mod
  using a mod specific sticky directory. An option becomes sticky only
  if it hasn't been previously defined.
  Parameters:
    1 = The name of the sticky variable.
  Returns:
    The value of the sticky variable.

  Other make segments can define sticky options. These are options which become
  defaults once they have been used. Sticky options can also be preset in the
  stick directory which helps simplify automated builds especially when build
  repeatability is required.

basenames_in
  A callable macro to get a list of basenames for all files matching a glob
  pattern.
  Parameters:
    1 = The glob pattern including the path.
  Returns:
    A list of basenames for all files matching the glob pattern.

endef

export HelpMacrosMsg
help-macros:
> @echo "$$HelpMacrosMsg" | less
endif
