#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# For test only.
#----------------------------------------------------------------------------
# The prefix tm2 must be unique for all files.
# +++++
# Preamble
ifndef tm2SegId
$(call Enter-Segment,tm2)
# -----

$(call Add-Message,tm2:Path:$(call This-Segment-Path))

# +++++
# Postamble
ifneq ($(call Is-Goal,help-${tm2Seg}),)
$(call test-message,Help message variable: help_${tm2SegN}_msg)
define help_${tm2SegN}_msg
Make segment: ${tm2Seg}.mk

This segment is in the helpers directory and is intended for test only.

Command line goals:
  help-${tm2Seg}   Display this help.
endef
endif
$(call Exit-Segment,tm2)
else
$(call Check-Segment-Conflicts,tm2)
endif # tm2SegId
# -----
