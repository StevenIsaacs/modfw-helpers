#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Test detection of segment name conflict.
#----------------------------------------------------------------------------
# The prefix tm must be unique for all files.
# This deliberately uses tm to force a conflict with test-macros.mk.
# +++++
# Preamble
ifndef tm_id
tm_id := $(call This-Segment-Id)
tm_seg := $(call This-Segment-File)
tm_name := $(call This-Segment-Name)
# Save the ID of the previous segment to restore context at the end.
tm_prv_id := ${SegId}
$(eval $(call Set-Segment-Context,${tm_id}))

$(call Verbose,Make segment: $(call Segment-File,${tm_id}))
# -----

#<segment body here>

# +++++
# Postamble
ifneq ($(call Is-Goal,help-${tm_seg}),)
$(info Help message variable: help_${tm_name}_msg)
define help_${tm_name}_msg
This make segment is designed to test detection of a prefix conflict between
two or more files. Displaying this help should not be possible because this
file uses the same prefix as test-macros.mk.
endef
export help_${tm_name}_msg
help-${tm_seg}:
> echo "$$help_${tm_name}_msg" | less
endif
# Restore the previous context.
$(eval $(call Set-Segment-Context,${tm_prv_id}))

else
  ifneq (${tm_seg},$(call This-Segment-File))
    $(call Signal-Error,\
    Prefix conflict with $(tm_seg) in $(call This-Segment-File))
  else
    $(call Add-Message,${tm_seg} has already been included)
  endif
endif
# -----
