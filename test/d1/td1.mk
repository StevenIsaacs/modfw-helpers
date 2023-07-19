#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# For test only.
#----------------------------------------------------------------------------
# The prefix td1 must be unique for all files.
# +++++
# Preamble
ifndef td1SegId
$(call Enter-Segment,td1)
# -----

$(call Add-Message,td1:Path:$(call This-Segment-Path))

# +++++
# Postamble
ifneq ($(call Is-Goal,help-${td1Seg}),)
$(call test-message,Help message variable: help_${td1SegN}_msg)
define help_${td1SegN}_msg
Make segment: ${td1Seg}.mk

This segment is in the helpers directory and is intended for test only.

Command line goals:
  help-${td1Seg}   Display this help.
endef
endif
$(call Exit-Segment,td1)
else
$(call Check-Segment-Conflicts,td1)
endif # td1SegId
# -----
