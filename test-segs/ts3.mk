#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# For test only.
#----------------------------------------------------------------------------
# +++++
$(call Last-Segment-UN)
ifndef ${LastSegUN}.SegID
$(call Enter-Segment)
# -----

$(call Info,${Seg}:Path:$(call Last-Segment-Path))
$(call Expect-Vars,Seg:ts3 ts3Seg:ts3)

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
