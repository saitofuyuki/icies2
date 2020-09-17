dnl build-aux/icies/m4/sqidef.m4 --- definition for sqihelp
dnl Maintainer:  SAITO Fuyuki
dnl Created: Sep 5 2012 (original movement/mvheader.m4)
m4_divert(KILL)dnl
dnl --------------------------------------------------------------------------------
dnl typical usage
dnl
dnl c_reset(FOO)
dnl c_xincr(A0)        #define FOO_A0 1
dnl c_xincr(B0)        #define FOO_B0 2
dnl c_xincr(C0)        #define FOO_C0 3
dnl c_xkeep(MAX)       #define FOO_MAX 3
dnl --------------------------------------------------------------------------------

dnl c_reset(PREFIX[, COUNTER])
dnl Starts PREFIX_* macro group from COUNTER (or 0)
dnl Global macro _prefix is defined as PREFIX, used in following macros.
dnl Global _counter is defined as COUNTER.
m4_define([c_reset],
[dnl
m4_ifval([$1], [m4_define([_prefix], [$1])], [m4_define([_prefix], [])])dnl
dnl m4_define([_counter], [0])dnl
m4_define([_counter], [m4_default([$2], [0])])dnl
])

dnl c_entry_core_cpp(SUFFIX, COMMENT)
dnl Inserts #define <_prefix>SUFFIX <_counter>
dnl as well as define <_prefix>SUFFIX m4-macro as <_counter>
m4_define([c_entry_core_cpp],
[dnl
@%:@define m4_format([%-15s %2d], _prefix[]_[$1], _counter)   /* $2 */[]dnl
dnl m4_define(m4_quote(_prefix[]$1), _counter)dnl
dnl _dummy(m4_quote(_prefix[]$1),m4_indir(_prefix[]$1))dnl
])

dnl c_entry_core_shell(SUFFIX, COMMENT)
dnl Inserts <_prefix>SUFFIX=<_counter> as shell
m4_define([c_entry_core_shell],
[dnl
_prefix[]_$1=_counter[]   @%:@ $2[]dnl
])

dnl c_entry_core_aarray(SUFFIX, COMMENT)
dnl Inserts <_prefix>[SUFFIX]=<_counter> as shell
m4_define([c_entry_core_aarray],
[dnl
m4_ifdef(m4_quote([TYPESET](_prefix)), [],
[m4_define(m4_quote([TYPESET](_prefix)), [true])dnl
typeset -A _prefix
])dnl
_prefix@<:@[$1]@:>@=_counter[] @%:@ $2[]dnl
])

dnl c_entry_core_plist(SUFFIX, COMMENT)
dnl make prefix list
m4_define([c_entry_core_plist],
[dnl
m4_ifdef(m4_quote([TYPESET](_prefix)), [],
[m4_define(m4_quote([TYPESET](_prefix)), [true])dnl
_prefix])])

m4_define([c_divert_text_nnl],
[m4_divert_push([$1])$2[]dnl
m4_divert_pop([$1])])

dnl c_entry_core(SUFFIX, COMMENT)
dnl Entry insertion using _c_entry_core as template macro.
dnl As well as define <_prefix>SUFFIX m4-macro as <_counter>
m4_define([c_entry_core],
[dnl
dnl m4_divert_text([DEFS], [_$0([$1], [$2])])[]dnl
c_divert_text_nnl([DEFS], [m4_n(_$0([$1], [$2]))])[]dnl
_$0([$1], [$2])[]dnl
m4_define(m4_quote(_prefix[]_$1), _counter)dnl
_dummy(m4_quote(_prefix[]_$1),m4_indir(_prefix[]_$1))dnl
])

dnl template choice
m4_case(OTYPE,
dnl shell
[shell],
[m4_define([_c_entry_core], [c_entry_core_shell($@)])],
dnl shell/array
[aarray],
[m4_define([_c_entry_core], [c_entry_core_aarray($@)])],
dnl prefix list
[plist],
[m4_define([_c_entry_core], [c_entry_core_plist($@)])],
dnl others
[m4_define([_c_entry_core], [c_entry_core_cpp($@)])])

dnl c_entry_first(SUFFIX, COMMENT)
m4_define([c_entry_first],
[c_entry_core([$1], [$2])[]dnl
])

dnl _c_entry_first(SUFFIX)
m4_define([_c_entry_alias],
[
c_entry_core([$1], [alias])[]dnl
])

dnl c_entry_first([SUFFIX-LIST])
m4_define([c_entry_alias], [m4_map([_$0], [$1])])

dnl c_query(PREFIX, SUFFIX)
m4_define([c_query],
[m4_ifset([_$1_$2],m4_quote(_$1_$2),-1)])

dnl c_xincr(TAGS.., COMMENT, ...)
dnl Increment _counter and set macros.
dnl Third or later arguments are ignored.
dnl The first member of TAGS is defined as base, and others are as aliases.
m4_define([c_xincr],
[m4_define([_counter], m4_incr(_counter))[]dnl
c_entry_first(m4_car($1), [$2])[]dnl
c_entry_alias(m4_cdr($1))[]dnl
])

dnl c_xset(TAGS.., COUNTER, COMMENT, ...)
dnl Force to set COUNTER
m4_define([c_xset],
[m4_pushdef([_counter], [$2])dnl
c_entry_first(m4_car($1), [$3 kept])[]dnl
c_entry_alias(m4_cdr($1))[]dnl
m4_popdef([_counter])dnl
])

dnl c_xkeep(TAGS.., COMMENT, ...)
dnl Do not increment _counter and set macros.
m4_define([c_xkeep],
[dnl
c_entry_first(m4_car($1), [$2 kept])[]dnl
c_entry_alias(m4_cdr($1))[]dnl
])
m4_define([c_xmax], [m4_max($*)])

m4_define([_c_clgrp],
[
m4_define([_counter], m4_incr(_counter))[]dnl
@%:@  define m4_format([%-15s %2d], [_prefix[]_$1], _counter)[]dnl
])

m4_define([_clmem_max], [0])
dnl special wrapper for clone group/members
dnl c_clgrp(TAG, COMMENT, [MEMBERS...])
m4_define([c_clgrp],
[c_xincr([$1], [$2])dnl
m4_pushdef([_counter], [0])m4_pushdef([_prefix],  m4_dquote(_prefix[]_[$1]))dnl
m4_map([_$0], [$3])dnl
m4_define([_clmem_max], m4_max(_clmem_max, _counter))dnl
m4_popdef([_counter])m4_popdef([_prefix])dnl
])

m4_define([_dummy], [])
dnl --------------------------------------------------------------------------------
m4_ifset([DEFONLY],
[m4_define([_m4_divert(DEFS)], 100)],
[m4_define([_m4_divert(DEFS)], -99)m4_divert()])[]dnl
