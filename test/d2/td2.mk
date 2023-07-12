#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# For test only.
#----------------------------------------------------------------------------
# The prefix ttd2 must be unique for all files.
# +++++
# Preamble
ifndef td2_id
td2_id := $(call This-Segment-Id)
td2_seg := $(call This-Segment-File)
td2_name := $(call This-Segment-Name)
# Save the ID of the previous segment to restore context at the end.
td2_prv_id := ${SegId}
$(eval $(call Set-Segment-Context,${td2_id}))

$(call Verbose,Make segment: $(call Segment-File,${td2_id}))
# -----

$(call Add-Message,td2:Path:$(call This-Segment-Path))

# +++++
# Postamble
ifneq ($(call Is-Goal,help-${td2_seg}),)
$(info Help message variable: help_${td2_name}_msg)
define help_${td2_name}_msg
Make segment: ${td2_seg}.mk

This segment is in the helpers directory and is intended for test only.

Command line goals:
  help-${td2_seg}   Display this help.
endef
export help_${td2_name}_msg
help-${td2_seg}:
> echo "$$help_${td2_name}_msg" | less
endif # help-${td2_seg}
# Restore the previous context.
$(eval $(call Set-Segment-Context,${td2_prv_id}))

else # ${td2_seg} already loaded.
  ifneq (${td2_seg},$(call This-Segment-File))
    $(call Signal-Error,\
    Prefix conflict with $(td2_seg) in $(call This-Segment-File))
  else
    $(call Add-Message,${td2_seg} has already been included)
  endif
endif # td2_id
# -----
