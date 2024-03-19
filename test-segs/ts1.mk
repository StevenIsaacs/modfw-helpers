#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# For test only.
#----------------------------------------------------------------------------
# +++++
$(call Last-Segment-UN)
ifndef ${LastSegUN}.SegID
$(call Enter-Segment,For test only.)
# -----

$(call Info,${SegUN}:Path:$(call Last-Segment-Path))
$(call Verify-Seg-Attributes,test-segs.ts1)

# +++++
# Postamble
__h := $(or $(call Is-Goal,help-${SegUN}),$(call Is-Goal,help-${SegID}))
ifneq (${__h},)
$(call Attention,Generating help for:${Seg})
define __help
Make segment: ${Seg}.mk

This segment is in the helpers directory and is intended for test only.
WARNING: This assumes a test segment directory structure.

Command line goals:
  help-${SegUN}   Display this help.
endef
${__h} := ${__help}
endif
$(call Exit-Segment)
else
$(call Check-Segment-Conflicts)
endif # SegID
# -----
