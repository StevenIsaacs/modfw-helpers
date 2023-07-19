#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# For test only.
#----------------------------------------------------------------------------
# The prefix ts2 must be unique for all files.
# +++++
# Preamble
ifndef ts2SegId
$(call Enter-Segment,ts2)
# -----

$(call Add-Message,ts2:Path:$(call This-Segment-Path))

# +++++
# Postamble
ifneq ($(call Is-Goal,help-${ts2Seg}),)
$(call test-message,Help message variable: help_${ts2SegN}_msg)
define help_${ts2SegN}_msg
Make segment: ${ts2Seg}.mk

This segment is in the helpers directory and is intended for test only.

Command line goals:
  help-${ts2Seg}   Display this help.
endef
endif
$(call Exit-Segment,ts2)
else
$(call Check-Segment-Conflicts,ts2)
endif # ts2SegId
# -----
