#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# <purpose for this segment>
#----------------------------------------------------------------------------
# The prefix <u> must be unique for all files.
# +++++
# Preamble
ifndef <u>_id
<u>_id := $(call this-segment-id)
<u>_seg := $(call this-segment)
<u>_name := $(call this-segment-name)
# Save the ID of the previous segment to restore context at the end.
<u>_prv_id := ${SegId}
$(eval $(call set-segment-context,${<u>_id}))

$(call verbose,Make segment: $(call segment,${<u>_id}))
# -----
<segment body here>

# +++++
# Postamble
ifneq ($(call is-goal,help-${<u>_seg}),)
$(info Help message variable: help_${<u>_name}_msg)
define help_${<u>_name}_msg
<make segment help messages>
endef
export help_${<u>_name}_msg
help-${<u>_seg}:
> echo "$$help_${<u>_name}_msg" | less
endif
# Restore the previous context.
$(eval $(call set-segment-context,${<u>_prv_id}))

else
  $(call add-message,${<u>_seg} has already been included)
endif
# -----
