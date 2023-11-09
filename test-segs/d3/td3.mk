#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# For test only.
#----------------------------------------------------------------------------
# The prefix $(call Last-Segment-Basename) must be unique for all files.
# +++++
# Preamble
ifndef $(call Last-Segment-Basename)SegId
$(call Enter-Segment)
# -----

$(call Test-Info,Path:$(call Last-Segment-Path))
$(call Expect-Vars,Seg:td3 td3Seg:td3)

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
endif # SegId
# -----