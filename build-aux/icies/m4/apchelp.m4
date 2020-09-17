dnl build-aux/icies/m4/apchelp.m4 --- definition for apchelp
dnl Maintainer:  SAITO Fuyuki
dnl Created: Oct 26 2016
dnl Copyright: 2016--2020 JAMSTEC
dnl Licensed under the Apache License, Version 2.0
dnl   (https://www.apache.org/licenses/LICENSE-2.0)
m4_divert(KILL)dnl
dnl --------------------------------------------------------------------------------

dnl OUTPUT type
m4_ifdef([OUTPUT],
         [m4_define([_apc_output_lang], [m4_default(OUTPUT, [CPP])])],
         [m4_define([_apc_output_lang], [CPP])])

dnl ----------------------------------------
dnl diversion INDEX is for index definition.
m4_define([_m4_divert(INDEX)], [10000])
m4_define([BOTTOM(INDEX)], [])

dnl apc_tree_sep
dnl ------------
dnl Separator constant for trees.
m4_define([apc_tree_sep], [:])

dnl apc_prop_sep
dnl ------------
dnl Separator constant for properties
m4_define([apc_prop_sep], [/])

dnl apc_list_len(ARGS...)
dnl ---------------------
dnl Count length of ARGS.
m4_define([apc_list_len], [m4_apply([_$0], m4_unquote([$@]))])
m4_define([_apc_list_len], [$#])
dnl ])

m4_define([apc_debug], [m4_quote($@) :: m4_quote($*)])

dnl apc_last_n(NUM, LIST)
dnl ---------------------
dnl Return last NUM members of LIST.
dnl Negative NUM to return all members but last -NUM.
m4_define([apc_last_n],
[m4_do([m4_pushdef([__i])],
       [m4_shift(m4_for([__i],
                        m4_eval(apc_list_len([$2])-$1+1),
                        apc_list_len([$2]),
                        [1],
                        [,m4_argn(__i, $2)]))],
       [m4_popdef([__i])])])

dnl apc_first_n(NUM, LIST)
dnl ----------------------
dnl Return first NUM members of LIST.
m4_define([apc_first_n],
[m4_if(m4_eval([$1>0]), [1],
       [_$0($@)],
       [_$0(m4_eval(apc_list_len([$2])+($1)), [$2])])])

m4_define([_apc_first_n],
[m4_if([$1], [0], [[]],
       [m4_do([m4_pushdef([__i])],
              [m4_shift(m4_for([__i],
                               [1], [$1], [1],
                               [,m4_argn(__i, $2)]))],
              [m4_popdef([__i])])])])

dnl system properties

dnl apc_prop(PROPERTY, [KEYS..])
dnl ----------------------------
dnl Return property PROPERTY corresponding to KEYS.
m4_define([_apc_prop],
[m4_ifdef([$0($1)],
          [m4_indir([$0($1)])],
          [(<$1>)])])
m4_define([apc_prop],
          [_$0(m4_quote(m4_join(apc_prop_sep, $@)))])

dnl apc_set_prop(VALUE, PROPERTY, [KEYS..])
dnl ---------------------------------------
dnl Set property PROPERTY corresponding to KEYS as VALUE.
m4_define([_apc_set_prop],
[m4_do([m4_define([_apc_prop($1)], [$2])],
       [m4_set_add([PROP], [$1])])])

m4_define([apc_set_prop],
          [_$0(m4_quote(m4_join(apc_prop_sep, m4_shift($@))), [$1])])

dnl apc_ifset_prop(PROPERTY-KEY, IF-THEN, IF-ELSE)
m4_define([apc_ifset_prop],
[_$0(m4_quote(m4_join(apc_prop_sep, $1)), [$2], [$3])])
m4_define([_apc_ifset_prop],
[m4_ifdef([_apc_prop($1)], [$2], [$3])])

dnl apc_ifval_prop(PROPERTY-KEY, IF-THEN, IF-ELSE)
m4_define([apc_ifval_prop],
[apc_ifset_prop([$1],
                [m4_ifblank(apc_prop($1), [$3], [$2])],
                [$3])])

dnl apc_debug_prop()
m4_define([apc_debug_prop],
[m4_set_map([PROP], [_$0])])
m4_define([_apc_debug_prop],
[m4_n(property($1) :: _apc_prop([$1]))])

dnl predefined properties
apc_set_prop([GROUP], [PFX], [ID], [1])
apc_set_prop([TAG],   [PFX], [ID], [2])
apc_set_prop([ARG],   [PFX], [ID], [3])

apc_set_prop([],      [PFX], [IDX], [1])
apc_set_prop([FLAG],  [PFX], [IDX], [2])
apc_set_prop([SW],    [PFX], [IDX], [3])

dnl apc_set_tree(VALUE, PROP-LIST, [TREES..])
m4_define([apc_set_tree],
[_$0([$1], $2, m4_join(apc_tree_sep, m4_shiftn(2, $*)))])
m4_define([_apc_set_tree],[apc_set_prop($@)])

dnl apc_get_tree(PROP-LIST, [TREES..])
m4_define([apc_get_tree],
[_$0($1, m4_join(apc_tree_sep, m4_shift($*)))])
m4_define([_apc_get_tree],[apc_prop($@)])

dnl apc_ifset_tree(PROP-LIST, TREE, IF-THEN, IF-ELSE)
m4_define([apc_ifset_tree],
[_$0([$1], m4_join(apc_tree_sep, $2), [$3], [$4])])
m4_define([_apc_ifset_tree], [apc_ifset_prop([$1, $2], [$3], [$4])])

dnl apc_ifval_tree(PROP-LIST, TREE, IF-THEN, IF-ELSE)
m4_define([apc_ifval_tree],
[_$0([$1], m4_join(apc_tree_sep, $2), [$3], [$4])])
m4_define([_apc_ifval_tree], [apc_ifval_prop([$1, $2], [$3], [$4])])

dnl sentry
apc_set_tree([0],    [OFF])
apc_set_tree([0],    [NUM])
apc_set_tree([0],    [MIN])
apc_set_tree([0],    [MAX])

dnl apc_key_val(LEVEL, [KEYS...])
m4_define([apc_key_val],
[_$0([$1], m4_argn([$1], m4_shift($@)))])
m4_define([_apc_key_val],
[m4_ifblank([$2],
            [apc_prop([KEY], [$1])],
            [m4_do([$2],
                   [apc_set_prop([$2], [KEY], [$1])])])])

dnl apc_nullk(LEVEL)
m4_define([apc_nullk],
[m4_if(m4_eval([$1 > 1]), [1], [$0(m4_decr($1))[]apc_tree_sep])])

dnl apc_key_nml(LEVEL, [KEYS...])
m4_define([_apc_key_nml],
[m4_quote(apc_last_n([$1],
                     m4_split(m4_quote(apc_nullk([$1])[]$2), apc_tree_sep)))])

m4_define([apc_key_nml],
[m4_do([m4_pushdef([__i])],
       [m4_pushdef([__L], _$0($@))],
       [m4_shift(m4_for([__i], 1, [$1], [1],
                        [,apc_key_val(__i, __L)]))],
       [m4_popdef([__L])],
       [m4_popdef([__i])])])

dnl apc_index(LEVEL, TREE, BRANCH, [NUM])
m4_define([apc_index],
[m4_if([$4], apc_tree_sep,
       [_$0([$1], [$2], [$3], [])],
       [_$0([$1], [$2], [$3], [$4])])])

m4_define([_apc_index],
[apc_ifset_tree([NUM], [$2],
                [m4_do([apc_set_branch([$1], [$2], [$4])],
                       [apc_set_tree(m4_quote(apc_get_tree([NUM], $2)),
                                     [IDX], $2, $3)],
                       [apc_set_tree(m4_quote(m4_max(apc_get_tree([MAX], $2), apc_get_tree([NUM], $2))),
                                     [MAX], $2)],
                       [apc_set_tree(m4_quote(m4_incr(apc_get_tree([NUM], $2))),
                                     [NUM], $2)])],
                [($2)ELSE])])

dnl apc_set_branch(LEVEL, TREE, [NUM])
m4_define([apc_set_branch],
[m4_ifnblank([$3],
             [apc_ifset_tree([NUM], [$2, $3],
                             [],
                             [apc_set_tree([$3], [NUM], $2)])])])

dnl apc_set_leaf(LEVEL, TREE, BRANCH, [INI-ARGS..])
m4_define([apc_set_leaf],
[m4_do(
[apc_set_tree(1, [NUM], [$2], [$3])],
[apc_set_tree(1, [MIN], [$2], [$3])],
[apc_set_tree(1, [MAX], [$2], [$3])],
[m4_append([BOTTOM(INDEX)], [apc_min_max([$1], [$2], [$3])])],
[apc_set_tree(m4_eval((apc_get_tree([IDX], [$2], [$3]))
                       *  (m4_default([$4], [1024]))
                       +  (m4_default([$5], [0]))),
              [OFF], [$2], [$3])])])

dnl apc_process(LEVEL, TREE-BRANCH, COMMENT, ID, NUM, LEAVES-INI)
m4_define([apc_process],
[m4_do([m4_pushdef([__LIST__], [m4_quote(apc_key_nml([$1], [$2]))])],
       [_$0($1,
            m4_quote(apc_first_n([-1], __LIST__)),
            apc_last_n([1], __LIST__),
            m4_shift2($@))],
       [m4_popdef([__LIST__])])])
dnl _apc_process(LEVEL, TREE, BRANCH, COMMENT, ID, NUM, LEAVES-INI)
m4_define([_apc_process],
[m4_do([],
       [m4_if([m4_dquote($@) // $1 :: $2 :: $3 // ])],
       [apc_set_tree(m4_default([$5], [$3]), [ID], [$2], [$3])],
       [apc_index([$1], [$2], [$3], [$6])],
       [m4_if([$7], [-], [], [apc_set_leaf([$1], [$2], [$3], $7)])],
       [apc_output([$1], [$2], [$3], [$4])],
       [])])

dnl ----------------------------------------
dnl USER interfaces
dnl ----------------------------------------
dnl cGRP(TREE, COMMENT, [ID],        [INIT-LEAVES])
dnl cTAG(TREE, COMMENT, [ID], [NUM], [INIT-LEAVES])
dnl cFLG(TREE, COMMENT, [ID], [NUM])
m4_define([cGRP], [apc_process([1], [$1], [$2], [$3], [],   [$4])])
m4_define([cTAG], [apc_process([2], [$1], [$2], [$3], [$4], [$5])])
m4_define([cFLG], [apc_process([3], [$1], [$2], [$3], [$4], [-])])

dnl cDIVERT(DIVERSION)
dnl ------------------
m4_define([cDIVERT],
[m4_case([$1],
         [INDEX], [m4_do([m4_undivert([$1])],
                         [m4_indir([BOTTOM($1)])])],
         [m4_fatal([unknown diversion: $1])])])

dnl ----------------------------------------
dnl outputs
dnl ----------------------------------------

dnl apc_dispatch(MACRO, LANG, ARGS....)
dnl -----------------------------------
dnl cf. _AC_LANG_DISPATCH
m4_define([apc_dispatch],
[m4_ifdef([$1($2)],
          [m4_indir([$1($2)], m4_shift2($@))],
          [m4_fatal([$1: unknown output: $2])])])

m4_define([apc_output],  [apc_dispatch([$0], _apc_output_lang, $@)])
m4_define([apc_min_max], [apc_dispatch([$0], _apc_output_lang, $@)])

dnl ----------------------------------------
dnl CPP outputs
dnl ----------------------------------------
m4_define([apc_output(CPP)],
[m4_do([apc_cpp_define_id([$1], [$2], [$3], [$4])],
       [m4_divert_text([INDEX],
                       [apc_cpp_define_index([$1], [$2], [$3], [$4])])])])

dnl CPP id
m4_define([apc_cpp_define_id],
[m4_do([@%:@],
       [apc_cpp_indent([$1])],
       [  define ],
       [apc_cpp_indent(m4_eval(4-$1))],
       [apc_cpp_macro_sp([ID], [$1], [$2], [$3])],
       [  ],
       [apc_cpp_id([$1], [$2], [$3])],
       [apc_cpp_comment([$4])])])

m4_define([apc_cpp_id],
[m4_do([m4_pushdef([__ID], [_$0($@)])],
       ['__ID'],
       [ ],
       [apc_cpp_indent(m4_eval(10 - m4_len(__ID)))],
       [m4_popdef([__ID])])])

m4_define([_apc_cpp_id], [apc_get_tree([ID], [$2], [$3])])

dnl CPP index
m4_define([apc_cpp_define_index],
[apc_ifval_prop([[PFX], [IDX], [$1]],
   [m4_do([@%:@],
       [apc_cpp_indent([$1])],
       [  define ],
       [apc_cpp_indent(m4_eval(4-$1))],
       [apc_cpp_macro_sp([IDX], [$1], [$2], [$3])],
       [  ],
       [apc_cpp_index([$1], [$2], [$3])],
       [apc_cpp_comment([$4])])])])

m4_define([apc_cpp_index],
[m4_do([m4_pushdef([__IDX], m4_eval(_$0($@) + apc_get_tree([OFF], [$2])))],
       [__IDX],
       [ ],
       [apc_cpp_indent(m4_eval(10 - m4_len(__IDX)))],
       [m4_popdef([__IDX])])])

m4_define([_apc_cpp_index], [apc_get_tree([IDX], [$2], [$3])])

dnl apc_cpp_comment(COMMENT)
m4_define([apc_cpp_comment],
[m4_ifval([$1], [   /* [$1] */])])
m4_define([apc_cpp_indent],
[m4_if(m4_eval([$1 > 1]), [1], [$0(m4_decr($1)) ])])

dnl macro name with spaces
m4_define([apc_cpp_macro_sp],
[m4_do([m4_pushdef([__MACRO], [apc_cpp_macro_name($@)])],
       [__MACRO],
       [ ],
       [apc_cpp_indent(m4_eval(25 - m4_len(__MACRO)))],
       [m4_popdef([__MACRO])])])

m4_define([apc_cpp_macro_name],
[m4_join([_], apc_prop([PFX], [$1], [$2]), $3, $4)])

m4_define([apc_cpp_macro_name_pfx],
[m4_join([_],
         [$1],
         apc_prop([PFX], [$2], [$3]),
         m4_shiftn(3,$@))])

dnl apc_min_max
m4_define([apc_min_max(CPP)],
[m4_do(
dnl [C $2 $3 apc_get_tree([OFF], [$2], [$3]) apc_get_tree([MIN], [$2], [$3]) apc_get_tree([MAX], [$2], [$3])],
[m4_n(apc_cpp_min_max([MIN], $@))],
[m4_n(apc_cpp_min_max([MAX], $@))],
)])

m4_define([apc_cpp_min_max],
[m4_do([@%:@],
       [  define ],
       [apc_cpp_macro_name_pfx([$1], [IDX], m4_incr($2), $3, $4)],
       [  ],
       [m4_eval(apc_get_tree([OFF], [$3], [$4]) + apc_get_tree([$1], [$3], [$4]))],
       )])

dnl ----------------------------------------
dnl Fermata
dnl ----------------------------------------
m4_divert()[]dnl
dnl ----------------------------------------
dnl Tests
dnl ----------------------------------------
m4_if([
apc_debug([apc_key_nml(1, [G])])
apc_debug([apc_key_nml(2, [T])])
apc_debug([apc_key_nml(2, [:T])])
apc_debug([apc_key_nml(2, [G:T])])
apc_debug([apc_key_nml(3, [F])])
apc_debug([apc_key_nml(3, [::F])])
apc_debug([apc_key_nml(3, [G:T:F])])

apc_debug([apc_key_nml(1, [G1])])
apc_debug([apc_key_nml(2, [:T1])])
apc_debug([apc_key_nml(3, [::F1])])
apc_debug([apc_key_nml(3, [:T2:F1])])
apc_debug([apc_key_nml(3, [G2::F1])])

apc_first_n(1,  [a,b,c,d])
apc_first_n(-1, [a,b,c,d])
])dnl
m4_if([
cGRP([M],     [Movement switches])dnl
dnl
cTAG([HSOLV], [Thickness matrix solver], [], [], [])dnl
cFLG([DVB],   [Diff(grounded) E(floated)])dnl
cFLG([ZEV],   [E])dnl
cFLG([UP1],   [Dec(v=0) U(other)])dnl
cFLG([UPD],   [Dec(whole)])dnl
dnl
cTAG([HINIG], [Thickness solver initial guess])dnl
cFLG([ZERO],  [zero constant for the initial guess])dnl
cFLG([PREV],  [Previous solution for the initial guess], [], [10])dnl
])dnl
dnl apc_debug_prop()dnl
m4_if([
apc_debug([apc_get_tree(ID, M)])
apc_debug([apc_get_tree(ID, M, HSOLV)])
apc_debug([apc_get_tree(ID, M, HSOLV, DVB)])

apc_debug([apc_get_tree(IDX, M)])
apc_debug([apc_get_tree(IDX, M, HSOLV)])
apc_debug([apc_get_tree(IDX, M, HSOLV, DVB)])
])dnl
dnl ----------------------------------------
dnl
dnl Local Variables:
dnl mode: m4
dnl End:
