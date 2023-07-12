#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# For test only.
#----------------------------------------------------------------------------
# The prefix tm1 must be unique for all files.
# +++++
# Preamble
ifndef tm1_id
tm1_id := $(call This-Segment-Id)
tm1_seg := $(call This-Segment-File)
tm1_name := $(call This-Segment-Name)
# Save the ID of the previous segment to restore context at the end.
tm1_prv_id := ${SegId}
$(eval $(call Set-Segment-Context,${tm1_id}))

$(call Verbose,Make segment: $(call Segment-File,${tm1_id}))
# -----

$(call Add-Message,tm1:Path:$(call This-Segment-Path))

# +++++
# Postamble
ifneq ($(call Is-Goal,help-${tm1_seg}),)
$(info Help message variable: help_${tm1_name}_msg)
define help_${tm1_name}_msg
Make segment: ${tm1_seg}.mk

This segment is in the helpers directory and is intended for test only.

Command line goals:
  help-${tm1_seg}   Display this help.
endef
export help_${tm1_name}_msg
help-${tm1_seg}:
> echo "$$help_${tm1_name}_msg" | less
endif # help-${tm1_seg}
# Restore the previous context.
$(eval $(call Set-Segment-Context,${tm1_prv_id}))

else # ${tm1_seg} already loaded.
  ifneq (${tm1_seg},$(call This-Segment-File))
    $(call Signal-Error,\
    Prefix conflict with $(tm1_seg) in $(call This-Segment-File))
  else
    $(call Add-Message,${tm1_seg} has already been included)
  endif
endif # tm1_id
# -----
