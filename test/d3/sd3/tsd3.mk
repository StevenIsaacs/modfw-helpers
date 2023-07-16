#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# For test only.
#----------------------------------------------------------------------------
# The prefix tsd3 must be unique for all files.
# +++++
# Preamble
ifndef tsd3_id
$(call Enter-Segment,tsd3)
# -----

$(call Add-Message,tsd3:Path:$(call This-Segment-Path))

# +++++
# Postamble
ifneq ($(call Is-Goal,help-${tsd3_seg}),)
$(call test-message,Help message variable: help_${tsd3_name}_msg)
define help_${tsd3_name}_msg
Make segment: ${tsd3_seg}.mk

This segment is in the helpers directory and is intended for test only.

Command line goals:
  help-${tsd3_seg}   Display this help.
endef
endif
$(call Exit-Segment,tsd3)
else
$(call Report-Segment-Exists,tsd3)
endif # tsd3_id
# -----
