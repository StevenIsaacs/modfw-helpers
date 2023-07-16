#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# For test only.
#----------------------------------------------------------------------------
# The prefix tm1 must be unique for all files.
# +++++
# Preamble
ifndef tm1_id
$(call Enter-Segment,tm1)
# -----

$(call Add-Message,tm1:Path:$(call This-Segment-Path))

# +++++
# Postamble
ifneq ($(call Is-Goal,help-${tm1_seg}),)
$(call test-message,Help message variable: help_${tm1_name}_msg)
define help_${tm1_name}_msg
Make segment: ${tm1_seg}.mk

This segment is in the helpers directory and is intended for test only.

Command line goals:
  help-${tm1_seg}   Display this help.
endef
endif
$(call Exit-Segment,tm1)
else
$(call Report-Segment-Exists,tm1)
endif # tm1_id
# -----
