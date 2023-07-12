#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# For test only.
#----------------------------------------------------------------------------
# The prefix ts1 must be unique for all files.
# +++++
# Preamble
ifndef ts1_id
ts1_id := $(call This-Segment-Id)
ts1_seg := $(call This-Segment-File)
ts1_name := $(call This-Segment-Name)
# Save the ID of the previous segment to restore context at the end.
ts1_prv_id := ${SegId}
$(eval $(call Set-Segment-Context,${ts1_id}))

$(call Verbose,Make segment: $(call Segment-File,${ts1_id}))
# -----

$(call Add-Message,ts1:Path:$(call This-Segment-Path))

# +++++
# Postamble
ifneq ($(call Is-Goal,help-${ts1_seg}),)
$(info Help message variable: help_${ts1_name}_msg)
define help_${ts1_name}_msg
Make segment: ${ts1_seg}.mk

This segment is in the helpers directory and is intended for test only.

Command line goals:
  help-${ts1_seg}   Display this help.
endef
export help_${ts1_name}_msg
help-${ts1_seg}:
> echo "$$help_${ts1_name}_msg" | less
endif # help-${ts1_seg}
# Restore the previous context.
$(eval $(call Set-Segment-Context,${ts1_prv_id}))

else # ${ts1_seg} already loaded.
  ifneq (${ts1_seg},$(call This-Segment-File))
    $(call Signal-Error,\
    Prefix conflict with $(ts1_seg) in $(call This-Segment-File))
  else
    $(call Add-Message,${ts1_seg} has already been included)
  endif
endif # ts1_id
# -----
