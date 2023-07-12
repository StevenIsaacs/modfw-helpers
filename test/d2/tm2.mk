#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# For test only.
#----------------------------------------------------------------------------
# The prefix tm2 must be unique for all files.
# +++++
# Preamble
ifndef tm2_id
tm2_id := $(call This-Segment-Id)
tm2_seg := $(call This-Segment-File)
tm2_name := $(call This-Segment-Name)
# Save the ID of the previous segment to restore context at the end.
tm2_prv_id := ${SegId}
$(eval $(call Set-Segment-Context,${tm2_id}))

$(call Verbose,Make segment: $(call Segment-File,${tm2_id}))
# -----

$(call Add-Message,tm2:Path:$(call This-Segment-Path))

# +++++
# Postamble
ifneq ($(call Is-Goal,help-${tm2_seg}),)
$(info Help message variable: help_${tm2_name}_msg)
define help_${tm2_name}_msg
Make segment: ${tm2_seg}.mk

This segment is in the helpers directory and is intended for test only.

Command line goals:
  help-${tm2_seg}   Display this help.
endef
export help_${tm2_name}_msg
help-${tm2_seg}:
> echo "$$help_${tm2_name}_msg" | less
endif # help-${tm2_seg}
# Restore the previous context.
$(eval $(call Set-Segment-Context,${tm2_prv_id}))

else # ${tm2_seg} already loaded.
  ifneq (${tm2_seg},$(call This-Segment-File))
    $(call Signal-Error,\
    Prefix conflict with $(tm2_seg) in $(call This-Segment-File))
  else
    $(call Add-Message,${tm2_seg} has already been included)
  endif
endif # tm2_id
# -----
