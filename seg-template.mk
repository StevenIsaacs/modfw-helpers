#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# <purpose for this segment>
#----------------------------------------------------------------------------
# The prefix <u> must be unique for all files.
# The format of all the <u> based names is required.
# +++++
# Preamble
ifndef <u>_id
$(call Enter-Segment,<u>)
# -----

<segment body here>

# +++++
# Postamble
# Define help only if needed.
ifneq ($(call Is-Goal,help-${<u>_seg}),)
define help_${<u>_name}_msg
Make segment: ${<u>_seg}.mk

<make segment help messages>

Command line goals:
  help-${<u>_seg}   Display this help.
endef
endif # help goal message.

$(call Exit-Segment,<u>)
else # <u>_id exists
$(call Report-Segment-Exists,<u>)
endif # <u>_id
# -----
