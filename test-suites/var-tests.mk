#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Verify the helper macros for manipulating variables.
#----------------------------------------------------------------------------
# The prefix $(call Last-Segment-Basename) must be unique for all files.
# +++++
# Preamble
ifndef $(call Last-Segment-Basename).SegID
$(call Enter-Segment)
# -----

$(call Declare-Suite,${Seg},Verify the variable related helper macros.)

# Define the tests in the order in which they should be run.

$(call Declare-Test,Inc-Var)
define _help
${.TestUN}
  Verify the helper macro:${.TestUN}
endef
help-${.TestUN} := $(call _help)
${.TestUN}.Prereqs := expect-tests.Expect-Vars
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(eval _v := 0)
  $(foreach _e,0 1 2,
    $(call Expect-Vars,_v:${_e})
    $(call Inc-Var,_v)
  )

  $(call End-Test)
  $(call Exit-Macro)
endef

$(call Declare-Test,Dec-Var)
define _help
${.TestUN}
  Verify the helper macro:${.TestUN}
endef
help-${.TestUN} := $(call _help)
${.TestUN}.Prereqs := expect-tests.Expect-Vars
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(eval _v := 2)
  $(foreach _e,2 1 0,
    $(call Expect-Vars,_v:${_e})
    $(call Dec-Var,_v)
  )

  $(call End-Test)
  $(call Exit-Macro)
endef

$(call Declare-Test,Add-Var)
define _help
${.TestUN}
  Verify the helper macro:${.TestUN}
endef
help-${.TestUN} := $(call _help)
${.TestUN}.Prereqs := expect-tests.Expect-Vars
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(eval _v := 0)
  $(foreach _e,0 2 4,
    $(call Expect-Vars,_v:${_e})
    $(call Add-Var,_v,2)
  )

  $(eval _v := 0)
  $(foreach _e,0 101 202,
    $(call Expect-Vars,_v:${_e})
    $(call Add-Var,_v,101)
  )

  $(eval _v := -10)
  $(foreach _e,-10 -7 -4,
    $(call Expect-Vars,_v:${_e})
    $(call Add-Var,_v,3)
  )

  $(eval _v := 0)
  $(foreach _e,0 -3 -6,
    $(call Expect-Vars,_v:${_e})
    $(call Add-Var,_v,-3)
  )

  $(call End-Test)
  $(call Exit-Macro)
endef

$(call Declare-Test,Sub-Var)
define _help
${.TestUN}
  Verify the helper macro:${.TestUN}
endef
help-${.TestUN} := $(call _help)
${.TestUN}.Prereqs := expect-tests.Expect-Vars
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(eval _v := 10)
  $(foreach _e,10 7 4,
    $(call Expect-Vars,_v:${_e})
    $(call Sub-Var,_v,3)
  )

  $(eval _v := 202)
  $(foreach _e,202 101 0,
    $(call Expect-Vars,_v:${_e})
    $(call Sub-Var,_v,101)
  )

  $(eval _v := 0)
  $(foreach _e,0 -3 -6,
    $(call Expect-Vars,_v:${_e})
    $(call Sub-Var,_v,3)
  )

  $(eval _v := 0)
  $(foreach _e,0 3 6,
    $(call Expect-Vars,_v:${_e})
    $(call Sub-Var,_v,-3)
  )

  $(call End-Test)
  $(call Exit-Macro)
endef

$(call Declare-Test,To-Shell-Var)
define _help
${.TestUN}
  Verify the helper macro:${.TestUN}
endef
help-${.TestUN} := $(call _help)
${.TestUN}.Prereqs := expect-tests.Expect-Vars
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(eval _v := $(call To-Shell-Var,test-var-name))
  $(call Expect-Vars,_v:_test_var_name)

  $(call End-Test)
  $(call Exit-Macro)
endef

$(call Declare-Test,To-Lower)
define _help
${.TestUN}
  Verify the helper macro:${.TestUN}
endef
help-${.TestUN} := $(call _help)
${.TestUN}.Prereqs := expect-tests.Expect-Vars
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(eval _v := $(call To-Lower,AbCdEF))
  $(call Expect-Vars,_v:abcdef)

  $(eval _v := $(call To-Lower,"A123!=&bCD"))
  $(call Expect-Vars,_v:a123!=&bcd)

  $(call End-Test)
  $(call Exit-Macro)
endef

$(call Declare-Test,To-Upper)
define _help
${.TestUN}
  Verify the helper macro:${.TestUN}
endef
help-${.TestUN} := $(call _help)
${.TestUN}.Prereqs := expect-tests.Expect-Vars
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(eval _v := $(call To-Upper,AbCdEF))
  $(call Expect-Vars,_v:ABCDEF)

  $(eval _v := $(call To-Upper,"A123!=&bCD"))
  $(call Expect-Vars,_v:A123!=&BCD)

  $(call End-Test)
  $(call Exit-Macro)
endef

define _Require-Callback

endef

$(call Declare-Test,Require)
define _help
${.TestUN}
  Verify the helper macro:${.TestUN}
endef
help-${.TestUN} := $(call _help)
${.TestUN}.Prereqs := expect-tests.Expect-List
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(eval _a :=)
  $(eval _b :=)
  $(eval _c :=)
  $(eval _d :=)

  $(eval _u := $(call Require,_a _b _c _d))
  $(if ${_u},
    $(call FAIL,Require returned:${_u})
  ,
    $(call PASS,Require returned an empty list.)
  )

  $(eval _u := $(call Require,_a _x _z _d))
  $(call Test-Info,Require returned:${_u})
  $(if ${_u},
    $(call Expect-List,${_u},_x _z)
  ,
    $(call FAIL,Require returned an empty list when should have been "_x _z")
  )

  $(eval undefine _a)
  $(eval undefine _b)
  $(eval undefine _c)
  $(eval undefine _d)

  $(eval _u := $(call Require,_a _b _c _d))
  $(call Test-Info,Require returned:${_u})
  $(if ${_u},
    $(call Expect-List,${_u},_a _b _c _d)
  ,
    $(call FAIL,\
      Require returned an empty list when should have been "_a _b _c _d")
  )

  $(call End-Test)
  $(call Exit-Macro)
endef

$(call Declare-Test,Strings-Are-Same)
define _help
${.TestUN}
  Verify the helper macro:${.TestUN}
endef
help-${.TestUN} := $(call _help)
${.TestUN}.Prereqs :=
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(eval _s1 := abc)
  $(eval _s2 := abc)
  $(call Test-Info,Comparing: ${_s1} and ${_s2})
  $(if $(call Strings-Are-Same,_s1,_s2),
    $(call PASS,Strings _s1 and _s2 are the same.)
  ,
    $(call FAIL,Strings _s1 and _s2 should have been the same.)
  )

  $(eval _s1 := xxx)
  $(call Test-Info,Comparing: ${_s1} and ${_s2})
  $(if $(call Strings-Are-Same,_s1,_s2),
    $(call FAIL,Strings _s1 and _s2 are the same.)
  ,
    $(call PASS,Strings _s1 and _s2 are not the same.)
  )

  $(eval _s1 := abc def)
  $(eval _s2 := abc def)
  $(call Test-Info,Comparing: ${_s1} and ${_s2})
  $(if $(call Strings-Are-Same,_s1,_s2),
    $(call PASS,Strings _s1 and _s2 are the same.)
  ,
    $(call FAIL,Strings _s1 and _s2 should have been the same.)
  )

  $(eval _s1 := abc xxx)
  $(call Test-Info,Comparing: ${_s1} and ${_s2})
  $(if $(call Strings-Are-Same,_s1,_s2),
    $(call FAIL,Strings _s1 and _s2 are the same.)
  ,
    $(call PASS,Strings _s1 and _s2 are not the same.)
  )

  $(eval _s1 := abc)
  $(call Test-Info,Comparing: ${_s1} and ${_s2})
  $(if $(call Strings-Are-Same,_s1,_s2),
    $(call FAIL,Strings _s1 and _s2 are the same.)
  ,
    $(call PASS,Strings _s1 and _s2 are not the same.)
  )

  $(eval _s1 := This is a line.)
  $(eval _s2 := This is a line.)
  $(call Test-Info,Comparing: ${_s1} and ${_s2}.)
  $(if $(call Strings-Are-Same,_s1,_s2),
    $(call PASS,Strings _s1 and _s2 are the same.)
  ,
    $(call FAIL,Strings _s1 and _s2 should have been the same.)
  )

  $(eval _s1 := this is a line.)
  $(call Test-Info,Comparing: ${_s1} and ${_s2}.)
  $(if $(call Strings-Are-Same,_s1,_s2),
    $(call FAIL,Strings _s1 and _s2 are the same.)
  ,
    $(call PASS,Strings _s1 and _s2 are not the same.)
  )

  $(eval _s1 := This is a line)
  $(call Test-Info,Comparing: ${_s1} and ${_s2}.)
  $(if $(call Strings-Are-Same,_s1,_s2),
    $(call FAIL,Strings _s1 and _s2 are the same.)
  ,
    $(call PASS,Strings _s1 and _s2 are not the same.)
  )

  $(eval undefine _s1)
  $(eval undefine _s2)

  $(call End-Test)
  $(call Exit-Macro)
endef

$(call End-Declare-Suite)

# +++++
# Postamble
# Define help only if needed.
#ifneq ($(call Is-Goal,help-${Seg}),)
define _help
Make test suite: ${Seg}.mk

<make test suite help messages>

Command line goals:
  help-${Seg}
    Display this help.
  show-${Seg}.TestL
    Display the list of tests included in this suite.
endef
help-${Seg} := $(call _help)

#endif # help goal message.

$(call Exit-Segment)
else # <u>SegID exists
$(call Check-Segment-Conflicts)
endif # <u>SegID
# -----
