#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# For test only.
#----------------------------------------------------------------------------
# The prefix ts1 must be unique for all files.
# +++++
# Preamble
ifndef ts1SegId
$(call Enter-Segment,ts1)
# -----

$(call Add-Message,ts1:Path:$(call This-Segment-Path))

# +++++
# Postamble
ifneq ($(call Is-Goal,help-${ts1Seg}),)
$(call test-message,Help message variable: help_${ts1SegN}_msg)
define help_${ts1SegN}_msg
Make segment: ${ts1Seg}.mk

This segment is in the helpers directory and is intended for test only.

Command line goals:
  help-${ts1Seg}   Display this help.
endef
endif
$(call Exit-Segment,ts1)
else
$(call Check-Segment-Conflicts,ts1)
endif # ts1SegId
# -----
