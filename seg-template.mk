#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# <purpose for this segment>
#----------------------------------------------------------------------------
# The prefix <u> must be unique for all files.
# +++++
# Preamble
ifndef <u>_id
<u>_id := $(call This-Segment-Id)
<u>_seg := $(call This-Segment-File)
<u>_name := $(call This-Segment-Name)
# Save the ID of the previous segment to restore context at the end.
<u>_prv_id := ${SegId}
$(eval $(call Set-Segment-Context,${<u>_id}))

$(call Verbose,Make segment: $(call Segment-File,${<u>_id}))
# -----
<segment body here>

# +++++
# Postamble
ifneq ($(call Is-Goal,help-${<u>_seg}),)
$(info Help message variable: help_${<u>_name}_msg)
define help_${<u>_name}_msg
Make segment: ${<u>_seg}.mk

<make segment help messages>

Command line goals:
  help-${<u>_seg}   Display this help.
endef
export help_${<u>_name}_msg
help-${<u>_seg}:
> echo "$$help_${<u>_name}_msg" | less
endif # help-${<u>_seg}
# Restore the previous context.
$(eval $(call Set-Segment-Context,${<u>_prv_id}))

else # ${<u>_seg} already loaded.
  ifneq (${<u>_seg},$(call This-Segment-File))
    $(call Signal-Error,\
    Prefix conflict with $(<u>_seg) in $(call This-Segment-File))
  else
    $(call Add-Message,${<u>_seg} has already been included)
  endif
endif # <u>_id
# -----
