#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# For test only.
#----------------------------------------------------------------------------
# The prefix td2 must be unique for all files.
# +++++
# Preamble
ifndef td2SegId
$(call Enter-Segment,td2)
# -----

$(call Add-Message,td2:Path:$(call This-Segment-Path))

# +++++
# Postamble
ifneq ($(call Is-Goal,help-${td2Seg}),)
$(call test-message,Help message variable: help_${td2SegN}_msg)
define help_${td2SegN}_msg
Make segment: ${td2Seg}.mk

This segment is in the helpers directory and is intended for test only.

Command line goals:
  help-${td2Seg}   Display this help.
endef
endif
$(call Exit-Segment,td2)
else
$(call Check-Segment-Conflicts,td2)
endif # td2SegId
# -----
