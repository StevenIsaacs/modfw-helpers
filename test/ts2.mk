#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# For test only.
#----------------------------------------------------------------------------
# The prefix ts2 must be unique for all files.
# +++++
# Preamble
ifndef ts2_id
ts2_id := $(call This-Segment-Id)
ts2_seg := $(call This-Segment-File)
ts2_name := $(call This-Segment-Name)
# Save the ID of the previous segment to restore context at the end.
ts2_prv_id := ${SegId}
$(eval $(call Set-Segment-Context,${ts2_id}))

$(call Verbose,Make segment: $(call Segment-File,${ts2_id}))
# -----

$(call Add-Message,ts2:Path:$(call This-Segment-Path))

# +++++
# Postamble
ifneq ($(call Is-Goal,help-${ts2_seg}),)
$(info Help message variable: help_${ts2_name}_msg)
define help_${ts2_name}_msg
Make segment: ${ts2_seg}.mk

This segment is in the helpers directory and is intended for test only.

Command line goals:
  help-${ts2_seg}   Display this help.
endef
export help_${ts2_name}_msg
help-${ts2_seg}:
> echo "$$help_${ts2_name}_msg" | less
endif # help-${ts2_seg}
# Restore the previous context.
$(eval $(call Set-Segment-Context,${ts2_prv_id}))

else # ${ts2_seg} already loaded.
  ifneq (${ts2_seg},$(call This-Segment-File))
    $(call Signal-Error,\
    Prefix conflict with $(ts2_seg) in $(call This-Segment-File))
  else
    $(call Add-Message,${ts2_seg} has already been included)
  endif
endif # ts2_id
# -----
