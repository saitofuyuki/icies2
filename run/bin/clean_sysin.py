#!/usr/bin/python
# Time-stamp: <2011-04-13 09:38:51 fuyuki>

import os, re, sys

all=[]
for l in sys.stdin:
    l = l[:-1]
    l = re.sub (r'#.*$', r'', l)
    l = re.sub (r'(&\w+)', r'\n\1\n', l)
    for li in l.split ('\n'):
        li = re.sub (r'\s+$', r'', li)
        li = re.sub (r'^\s+', r'', li)
        if li != r'':
            all.append (li)

var = None
val = None
tag = None

CFG = {}

for li in all:
    if li[0] == '&':
        if var and tag:
            x[var] = val.rstrip (',')
            if CFG.has_key (tag):
                CFG[tag].append (x)
            else:
                CFG[tag] = [x]
        tag = li[1:].upper ()
        var = None
        val = None
        x = {}
    else:
        for ls in li.split (','):
            # print ls
            if '=' in ls:
                # print ls
                if var:
                    x[var] = val.rstrip (',')
                var, val = ls.split ('=', 1)
                var = var.strip ().upper ()
            else:
                val = val + ',' + ls

# print CFG

#for l in all:
#    print l

for t in sorted (CFG.keys ()):
    for l in CFG[t]:
        for v in sorted (l.keys ()):
            txt = l[v].lstrip ().rstrip ()
            print t, v, txt
