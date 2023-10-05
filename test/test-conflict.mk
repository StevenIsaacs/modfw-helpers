#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Test detection of segment name conflict.
#----------------------------------------------------------------------------
# The prefix $(call Last-Segment-Basename) must be unique for all files.
# This deliberately uses tm to force a conflict with test-macros.mk.
$(call Info,+++++ $(call Last-Segment-Basename) entry. +++++)
# +++++
# Preamble
ifndef $(call Last-Segment-Basename)SegId
$(call Enter-Segment)
# -----

#<segment body here>

# +++++
# Postamble
ifneq ($(call Is-Goal,help-${Seg}),)
$(call Info,Declaring help message for ${Seg}.)
define help_${SegV}_msg
This make segment is designed to test detection of a prefix conflict between
two or more files. Displaying this help should not be possible because this
file uses the same prefix as test-macros.mk.
endef
endif

$(call Exit-Segment)

else # tmSegId already defined.
$(call next-test,ID conflict context.)
$(call report-seg-context)
$(call Expect-Error,Prefix conflict with test-helpers in)
$(call Check-Segment-Conflicts)
$(call Verify-Error-Occurred,yes)

endif
# -----
$(call Info,----- $(call Last-Segment-Basename) exit. -----)
