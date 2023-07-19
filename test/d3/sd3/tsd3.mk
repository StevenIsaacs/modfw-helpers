#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# For test only.
#----------------------------------------------------------------------------
# The prefix tsd3 must be unique for all files.
# +++++
# Preamble
ifndef tsd3SegId
$(call Enter-Segment,tsd3)
# -----

$(call Add-Message,tsd3:Path:$(call This-Segment-Path))

# +++++
# Postamble
ifneq ($(call Is-Goal,help-${tsd3Seg}),)
$(call test-message,Help message variable: help_${tsd3SegN}_msg)
define help_${tsd3SegN}_msg
Make segment: ${tsd3Seg}.mk

This segment is in the helpers directory and is intended for test only.

Command line goals:
  help-${tsd3Seg}   Display this help.
endef
endif
$(call Exit-Segment,tsd3)
else
$(call Check-Segment-Conflicts,tsd3)
endif # tsd3SegId
# -----
