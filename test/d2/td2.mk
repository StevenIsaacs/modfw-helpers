#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# For test only.
#----------------------------------------------------------------------------
# The prefix td2 must be unique for all files.
# +++++
# Preamble
ifndef td2_id
$(call Enter-Segment,td2)
# -----

$(call Add-Message,td2:Path:$(call This-Segment-Path))

# +++++
# Postamble
ifneq ($(call Is-Goal,help-${td2_seg}),)
$(call test-message,Help message variable: help_${td2_name}_msg)
define help_${td2_name}_msg
Make segment: ${td2_seg}.mk

This segment is in the helpers directory and is intended for test only.

Command line goals:
  help-${td2_seg}   Display this help.
endef
endif
$(call Exit-Segment,td2)
else
$(call Check-Segment-Conflicts,td2)
endif # td2_id
# -----
