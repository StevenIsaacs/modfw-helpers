#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# For test only.
#----------------------------------------------------------------------------
# The prefix $(call This-Segment-Basename) must be unique for all files.
# +++++
# Preamble
ifndef $(call This-Segment-Basename)SegId
$(call Enter-Segment)
# -----

$(call Info,${Seg}:Path:$(call This-Segment-Path))

# +++++
# Postamble
ifneq ($(call Is-Goal,help-${Seg}),)
$(call test-message,Help message variable: help_${SegV}_msg)
define help_${SegV}_msg
Make segment: ${Seg}.mk

This segment is in the helpers directory and is intended for test only.

Command line goals:
  help-${Seg}   Display this help.
endef
endif
$(call Exit-Segment)
else
$(call Check-Segment-Conflicts)
endif # SegId
# -----
