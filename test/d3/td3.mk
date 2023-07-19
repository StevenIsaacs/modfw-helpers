#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# For test only.
#----------------------------------------------------------------------------
# The prefix td3 must be unique for all files.
# +++++
# Preamble
ifndef td3SegId
$(call Enter-Segment,td3)
# -----

$(call Add-Message,td3:Path:$(call This-Segment-Path))

# +++++
# Postamble
ifneq ($(call Is-Goal,help-${td3Seg}),)
$(call test-message,Help message variable: help_${td3SegN}_msg)
define help_${td3SegN}_msg
Make segment: ${td3Seg}.mk

This segment is in the helpers directory and is intended for test only.

Command line goals:
  help-${td3Seg}   Display this help.
endef
endif
$(call Exit-Segment,td3)
else
$(call Check-Segment-Conflicts,td3)
endif # td3SegId
# -----
