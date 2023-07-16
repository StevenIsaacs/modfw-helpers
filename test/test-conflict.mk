#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Test detection of segment name conflict.
#----------------------------------------------------------------------------
# The prefix tm must be unique for all files.
# This deliberately uses tm to force a conflict with test-macros.mk.
$(call Add-Message,+++++ test-conflict entry. +++++)
# +++++
# Preamble
ifndef tm_id
$(call Enter-Segment,tm)
# -----

#<segment body here>

# +++++
# Postamble
ifneq ($(call Is-Goal,help-${tm_seg}),)
$(call Add-Message,Declaring help message for ${tm_seg}.)
define help_${tm_name}_msg
This make segment is designed to test detection of a prefix conflict between
two or more files. Displaying this help should not be possible because this
file uses the same prefix as test-macros.mk.
endef
endif

$(call Exit-Segment,tm)

else # tm_id already defined.
$(call next-test,ID conflict context.)
$(call report-seg-context,tm)
$(call Report-Segment-Exists,tm)

endif
# -----
$(call Add-Message,----- test-conflict exit. -----)
