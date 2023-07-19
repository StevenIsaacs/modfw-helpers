#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# For test only.
#----------------------------------------------------------------------------
# The prefix tm1 must be unique for all files.
# +++++
# Preamble
ifndef tm1SegId
$(call Enter-Segment,tm1)
# -----

$(call Add-Message,tm1:Path:$(call This-Segment-Path))

# +++++
# Postamble
ifneq ($(call Is-Goal,help-${tm1Seg}),)
$(call test-message,Help message variable: help_${tm1SegN}_msg)
define help_${tm1SegN}_msg
Make segment: ${tm1Seg}.mk

This segment is in the helpers directory and is intended for test only.

Command line goals:
  help-${tm1Seg}   Display this help.
endef
endif
$(call Exit-Segment,tm1)
else
$(call Check-Segment-Conflicts,tm1)
endif # tm1SegId
# -----
