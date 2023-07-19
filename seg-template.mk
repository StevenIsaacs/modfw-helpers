#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# <purpose for this segment>
#----------------------------------------------------------------------------
# The prefix <u> must be unique for all files.
# The format of all the <u> based names is required.
# +++++
# Preamble
ifndef <u>SegId
$(call Enter-Segment,<u>)
# -----

<segment body here>

# +++++
# Postamble
# Define help only if needed.
ifneq ($(call Is-Goal,help-${<u>Seg}),)
define help_${<u>SegN}_msg
Make segment: ${<u>Seg}.mk

<make segment help messages>

Command line goals:
  help-${<u>Seg}   Display this help.
endef
endif # help goal message.

$(call Exit-Segment,<u>)
else # <u>SegId exists
$(call Check-Segment-Conflicts,<u>)
endif # <u>SegId
# -----
