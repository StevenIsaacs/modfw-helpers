#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# <purpose for this segment>
#----------------------------------------------------------------------------
# The prefix $(call Last-Segment-Basename) must be unique for all files.
# +++++
# Preamble
ifndef $(call Last-Segment-Basename).SegID
$(call Enter-Segment)
# -----

<segment body here>

# +++++
# Postamble
# Define help only if needed.
ifneq ($(call Is-Goal,help-${Seg}),)
define help-${Seg}
Make segment: ${Seg}.mk

<make segment help messages>

Command line goals:
  help-${Seg}   Display this help.
endef
endif # help goal message.

$(call Exit-Segment)
else # <u>SegID exists
$(call Check-Segment-Conflicts)
endif # <u>SegID
# -----
