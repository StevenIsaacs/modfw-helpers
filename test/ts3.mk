#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# For test only.
#----------------------------------------------------------------------------
# The prefix ts3 must be unique for all files.
# +++++
# Preamble
ifndef ts3SegId
$(call Enter-Segment,ts3)
# -----

$(call Add-Message,ts3:Path:$(call This-Segment-Path))

# +++++
# Postamble
ifneq ($(call Is-Goal,help-${ts3Seg}),)
$(call test-message,Help message variable: help_${ts3SegN}_msg)
define help_${ts3SegN}_msg
Make segment: ${ts3Seg}.mk

This segment is in the helpers directory and is intended for test only.

Command line goals:
  help-${ts3Seg}   Display this help.
endef
endif
$(call Exit-Segment,ts3)
else
$(call Check-Segment-Conflicts,ts3)
endif # ts3SegId
# -----
