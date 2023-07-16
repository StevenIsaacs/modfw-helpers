#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# For test only.
#----------------------------------------------------------------------------
# The prefix td3 must be unique for all files.
# +++++
# Preamble
ifndef td3_id
$(call Enter-Segment,td3)
# -----

$(call Add-Message,td3:Path:$(call This-Segment-Path))

# +++++
# Postamble
ifneq ($(call Is-Goal,help-${td3_seg}),)
$(call test-message,Help message variable: help_${td3_name}_msg)
define help_${td3_name}_msg
Make segment: ${td3_seg}.mk

This segment is in the helpers directory and is intended for test only.

Command line goals:
  help-${td3_seg}   Display this help.
endef
endif
$(call Exit-Segment,td3)
else
$(call Report-Segment-Exists,td3)
endif # td3_id
# -----
