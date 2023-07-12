#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# For test only.
#----------------------------------------------------------------------------
# The prefix td3 must be unique for all files.
# +++++
# Preamble
ifndef td3_id
td3_id := $(call This-Segment-Id)
td3_seg := $(call This-Segment-File)
td3_name := $(call This-Segment-Name)
# Save the ID of the previous segment to restore context at the end.
td3_prv_id := ${SegId}
$(eval $(call Set-Segment-Context,${td3_id}))

$(call Verbose,Make segment: $(call Segment-File,${td3_id}))
# -----

$(call Add-Message,td3:Path:$(call This-Segment-Path))

# +++++
# Postamble
ifneq ($(call Is-Goal,help-${td3_seg}),)
$(info Help message variable: help_${td3_name}_msg)
define help_${td3_name}_msg
Make segment: ${td3_seg}.mk

This segment is in the helpers directory and is intended for test only.

Command line goals:
  help-${td3_seg}   Display this help.
endef
export help_${td3_name}_msg
help-${td3_seg}:
> echo "$$help_${td3_name}_msg" | less
endif # help-${td3_seg}
# Restore the previous context.
$(eval $(call Set-Segment-Context,${td3_prv_id}))

else # ${td3_seg} already loaded.
  ifneq (${td3_seg},$(call This-Segment-File))
    $(call Signal-Error,\
    Prefix conflict with $(td3_seg) in $(call This-Segment-File))
  else
    $(call Add-Message,${td3_seg} has already been included)
  endif
endif # td3_id
# -----
