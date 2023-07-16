#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# For test only.
#----------------------------------------------------------------------------
# The prefix td1 must be unique for all files.
# +++++
# Preamble
ifndef td1_id
$(call Enter-Segment,td1)
# -----

$(call Add-Message,td1:Path:$(call This-Segment-Path))

# +++++
# Postamble
ifneq ($(call Is-Goal,help-${td1_seg}),)
$(call test-message,Help message variable: help_${td1_name}_msg)
define help_${td1_name}_msg
Make segment: ${td1_seg}.mk

This segment is in the helpers directory and is intended for test only.

Command line goals:
  help-${td1_seg}   Display this help.
endef
endif
$(call Exit-Segment,td1)
else
$(call Report-Segment-Exists,td1)
endif # td1_id
# -----
