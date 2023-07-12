#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# For test only.
#----------------------------------------------------------------------------
# The prefix td1 must be unique for all files.
# +++++
# Preamble
ifndef td1_id
td1_id := $(call This-Segment-Id)
td1_seg := $(call This-Segment-File)
td1_name := $(call This-Segment-Name)
# Save the ID of the previous segment to restore context at the end.
td1_prv_id := ${SegId}
$(eval $(call Set-Segment-Context,${td1_id}))

$(call Verbose,Make segment: $(call Segment-File,${td1_id}))
# -----

$(call Add-Message,td1:Path:$(call This-Segment-Path))

# +++++
# Postamble
ifneq ($(call Is-Goal,help-${td1_seg}),)
$(info Help message variable: help_${td1_name}_msg)
define help_${td1_name}_msg
Make segment: ${td1_seg}.mk

This segment is in the helpers directory and is intended for test only.

Command line goals:
  help-${td1_seg}   Display this help.
endef
export help_${td1_name}_msg
help-${td1_seg}:
> echo "$$help_${td1_name}_msg" | less
endif # help-${td1_seg}
# Restore the previous context.
$(eval $(call Set-Segment-Context,${td1_prv_id}))

else # ${td1_seg} already loaded.
  ifneq (${td1_seg},$(call This-Segment-File))
    $(call Signal-Error,\
    Prefix conflict with $(td1_seg) in $(call This-Segment-File))
  else
    $(call Add-Message,${td1_seg} has already been included)
  endif
endif # td1_id
# -----
