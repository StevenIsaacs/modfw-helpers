#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# For test only.
#----------------------------------------------------------------------------
# The prefix tm2 must be unique for all files.
# +++++
# Preamble
ifndef tm2_id
$(call Enter-Segment,tm2)
# -----

$(call Add-Message,tm2:Path:$(call This-Segment-Path))

# +++++
# Postamble
ifneq ($(call Is-Goal,help-${tm2_seg}),)
$(call test-message,Help message variable: help_${tm2_name}_msg)
define help_${tm2_name}_msg
Make segment: ${tm2_seg}.mk

This segment is in the helpers directory and is intended for test only.

Command line goals:
  help-${tm2_seg}   Display this help.
endef
endif
$(call Exit-Segment,tm2)
else
$(call Report-Segment-Exists,tm2)
endif # tm2_id
# -----
