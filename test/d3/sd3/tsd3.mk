#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# For test only.
#----------------------------------------------------------------------------
# The prefix tsd3 must be unique for all files.
# +++++
# Preamble
ifndef tsd3_id
tsd3_id := $(call This-Segment-Id)
tsd3_seg := $(call This-Segment-File)
tsd3_name := $(call This-Segment-Name)
# Save the ID of the previous segment to restore context at the end.
tsd3_prv_id := ${SegId}
$(eval $(call Set-Segment-Context,${tsd3_id}))

$(call Verbose,Make segment: $(call Segment-File,${tsd3_id}))
# -----

$(call Add-Message,tsd3:Path:$(call This-Segment-Path))

# +++++
# Postamble
ifneq ($(call Is-Goal,help-${tsd3_seg}),)
$(info Help message variable: help_${tsd3_name}_msg)
define help_${tsd3_name}_msg
Make segment: ${tsd3_seg}.mk

This segment is in the helpers directory and is intended for test only.

Command line goals:
  help-${tsd3_seg}   Display this help.
endef
export help_${tsd3_name}_msg
help-${tsd3_seg}:
> echo "$$help_${tsd3_name}_msg" | less
endif # help-${tsd3_seg}
# Restore the previous context.
$(eval $(call Set-Segment-Context,${tsd3_prv_id}))

else # ${tsd3_seg} already loaded.
  ifneq (${tsd3_seg},$(call This-Segment-File))
    $(call Signal-Error,\
    Prefix conflict with $(tsd3_seg) in $(call This-Segment-File))
  else
    $(call Add-Message,${tsd3_seg} has already been included)
  endif
endif # tsd3_id
# -----
