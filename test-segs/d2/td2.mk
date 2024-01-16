#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# For test only.
#----------------------------------------------------------------------------
# The prefix $(call Last-Segment-Basename) must be unique for all files.
# +++++
$(call Last-Segment-UN)
ifndef ${LastSegUN}.SegID
$(call Enter-Segment)
# -----

$(call Test-Info,Path:$(call Last-Segment-Path))
$(call Expect-Vars,Seg:td2 td2Seg:td2)

# +++++
# Postamble
ifneq ($(call Is-Goal,help-${Seg}),)
$(call test-message,Help message variable: help-${Seg})
define help-${Seg}
Make segment: ${Seg}.mk

This segment is in the helpers directory and is intended for test only.

Command line goals:
  help-${Seg}   Display this help.
endef
endif
$(call Exit-Segment)
else
$(call Check-Segment-Conflicts)
endif # SegID
# -----
