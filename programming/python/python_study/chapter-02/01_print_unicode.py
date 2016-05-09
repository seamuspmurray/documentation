#!/usr/bin/env python3
# Copyright (c) 2008-11 Qtrac Ltd. All rights reserved.
# This program or module is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version. It is provided for educational
# purposes and is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.

import sys
import unicodedata


def print_unicode_table(word1,word2):
    print("decimal   hex   chr  {0:^40}".format("name"))
    print("-------  -----  ---  {0:-<40}".format(""))
    print("word1 is {}",word1)
    print("word2 is {}",word2)

    code = ord(" ")
    end = min(0xD800, sys.maxunicode) # Stop at surrogate pairs

    while code < end:
        c = chr(code)
        name = unicodedata.name(c, "*** unknown ***")
        if word2 is None:
            if word1 is None or word1 in name.lower():
                print("{0:7}  {0:5X}  {0:^3c}  {1}".format(
                      code, name.title()))
            code += 1
        if word2 is not None:
            if word1 in name.lower() and word2 in name.lower():
                print("{0:7}  {0:5X}  {0:^3c}  {1}".format(
                      code, name.title()))
            code += 1


word1 = None
word2 = None
if len(sys.argv) > 1:
    if sys.argv[1] in ("-h", "--help"):
        print("usage: {0} [string] [string]".format(sys.argv[0]))
        word1 = 0
    else:
        word1 = sys.argv[1].lower()
if len(sys.argv) == 3:
    word2 = sys.argv[2].lower()
if word1 != 0:
    print_unicode_table(word1,word2)
print(sys.argv)
