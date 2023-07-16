#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# For test only.
#----------------------------------------------------------------------------
# The prefix ts2 must be unique for all files.
# +++++
# Preamble
ifndef ts2_id
$(call Enter-Segment,ts2)
# -----

$(call Add-Message,ts2:Path:$(call This-Segment-Path))

# +++++
# Postamble
ifneq ($(call Is-Goal,help-${ts2_seg}),)
$(call test-message,Help message variable: help_${ts2_name}_msg)
define help_${ts2_name}_msg
Make segment: ${ts2_seg}.mk

This segment is in the helpers directory and is intended for test only.

Command line goals:
  help-${ts2_seg}   Display this help.
endef
endif
$(call Exit-Segment,ts2)
else
$(call Check-Segment-Conflicts,ts2)
endif # ts2_id
# -----
