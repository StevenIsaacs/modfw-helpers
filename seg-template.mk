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
<make segment help messages>
endef
export help_${<u>_name}_msg
help-${<u>_seg}:
> echo "$$help_${<u>_name}_msg" | less
endif
# Restore the previous context.
$(eval $(call Set-Segment-Context,${<u>_prv_id}))

else
  $(call Add-Message,${<u>_seg} has already been included)
endif
# -----
