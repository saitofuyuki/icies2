#!/usr/bin/env python3
# Time-stamp: <2020/09/15 12:51:03 fuyuki symlogx.py>
#
# Copyright: 2019--2020 JAMSTEC
# Licensed under the Apache License, Version 2.0
#   (https://www.apache.org/licenses/LICENSE-2.0)

import os, sys
import re
import math
import pprint as pp

# main LINMAG LIN-W BSET REG-L REG-H [CONV....]
def main(argv, arg0=None):
    # linmag
    lmag = float(argv.pop(0))
    linw = float(argv.pop(0))
    # lmag = lmag.split(':')
    # if len(lmag) < 2:
    #     linw = 1.0
    # else:
    #     linw = float(lmag[1])
    # lmag = float(lmag[0])
    # print((lmag, linw))
    # bset
    bset = argv.pop(0)
    bset = re.split(r'([afg])', bset)
    bprop = {}
    bset = bset[1:]
    while bset:
        k = bset.pop(0)
        v = bset.pop(0)
        if v:
            bprop[k] = int(v)
        else:
            bprop[k] = 0
    # region
    rl = float(argv.pop(0))
    rh = float(argv.pop(0))
    # conversion
    if argv:
        factor = float(argv[0])
    else:
        factor = 1.0

    # sys.stderr.write("%s\n" % factor)
    factor = math.log10(factor)
    # attr
    attr = ((lmag, linw), bprop, (rl, rh), factor)
    print('#', attr)
    if rl >= 0:
        mfull = (max(0.0, +rh - 1.0) - max(0.0, +rl - 1.0)) / linw
    elif rh >= 0:
        mfull = (max(0.0, +rh - 1.0) + max(0,0, -rl - 1.0)) / linw + 2.0
    else:
        mfull = (max(0.0, -rh - 1.0) - max(0.0, -rl - 1.0)) / linw
    ## print((rl, rh), mfull)
    ## f
    F = list(range(1, 10))
    # G = [1, 2, 5]
    G = [1]
    astp = bprop.get('a', 0)

    C = {}

    o = 1.0
    i = 0
    while True:
        if o + linw * i > rh:
            break
        C.update(log_part (o, i, +1.0, F, G, astp, linw, lmag, factor))
        i = i + 1
    o = -1.0
    i = 0
    while True:
        if o - linw * i < rl:
            break
        C.update(log_part (o, i, -1.0, F, G, astp, linw, lmag, factor))
        i = i + 1
    o = -1.0
    i = 1
    while True:
        x = o + 0.1 * i
        if x >= 1.0:
            break
        if i == 10:
            C[x]='ag @:30:0@::'
        else:
            C[x]='f'
        i = i + 1
    # pp.pprint(C)
    for x in sorted(C.keys()):
        if x >= rl and x <= rh:
            print("%f %s" % (x, C[x]))

def log_part(o, i, d, F, G, astp, linw, lmag, factor):
    C = {}
    astp = astp or 1
    for j in range(1,10):
        x = o + d * (math.log10(j) + i) * linw
        ch = ''
        ann = ''
        if j in F:
            ch = ch + 'f'
        if j in G:
            ch = ch + 'g'
        if j == 1 and i % astp == 0:
            ch = ch + 'a'
            ann = int(i + lmag - factor)
            if ann == 0:
                ann = '1'
            elif ann == 1:
                ann = '10'
            else:
                ann = '10@+%d@+' % ann
            if d < 0:
                ann = '-' + ann
        l = ch
        if ann:
            l = l + (' %s' % ann)
        C[x] = l
    return C


if __name__ == "__main__":
    main(sys.argv[1:], sys.argv[0])
