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
import xml.sax.saxutils



def main():
    options = process_options()
    maxwidth = options[0]
    format = options[1]
    print_start()
    count = 0
    while True:
        try:
            line = input()
            if count == 0:
                color = "lightgreen"
            elif count % 2:
                color = "white"
            else:
                color = "lightyellow"
            print_line(line, color, maxwidth, format)
            count += 1
        except EOFError:
            break
    print_end()


def print_start():
    print("<table border='1'>")


def print_line(line, color, maxwidth, format):
    print("<tr bgcolor='{0}'>".format(color))
    fields = extract_fields(line)
    for field in fields:
        if not field:
            print("<td></td>")
        else:
            number = field.replace(",", "")
            try:
                x = float(number)
                variable_num_format = "<td align='right'>{{0:{0}}}</td>".format(format)
                print(variable_num_format)
               #print("<td align='right'>{0:d}</td>".format(round(x)))
                print(variable_num_format.format(x))
            except ValueError:
                field = field.title()
                field = field.replace(" And ", " and ")
                if len(field) <= maxwidth:
                    field = xml.sax.saxutils.escape(field)
                else:
                    field = "{0} ...".format(
                            xml.sax.saxutils.escape(field[:maxwidth]))
                print("<td>{0}</td>".format(field))
    print("</tr>")


def extract_fields(line):
    fields = []
    field = ""
    quote = None
    for c in line:
        if c in "\"'":
            if quote is None: # start of quoted string
                quote = c
            elif quote == c:  # end of quoted string
                quote = None
            else:
                field += c    # other quote inside quoted string
            continue
        if quote is None and c == ",": # end of a field
            fields.append(field)
            field = ""
        else:
            field += c        # accumulating a field
    if field:
        fields.append(field)  # adding the last field
    return fields



def print_end():
    print("</table>")

def process_options():
   # return a tuple of int max width and a string of format eg. .0f
   # set default maxwidth of 100 and default format of .0f
   # if the user types in -h or -help it should print out the help message and return None None
   maxwidth = 100
   format = ".0f"
 
   if len(sys.argv) > 1:
       if "-h" in sys.argv or "-help" in sys.argv:
           print("usage: \n"
                "csv2html.py [maxwidth=int] [format=str] < input.csv > output.html"
                "\n\n"                                                           
                "maxwidth is an optional integer; if specified, it sets the maximum "
                "number of characters that can be putput for string fields, otherwise "
                "a default of 100 characters is used.")
   if len(sys.argv) > 1: 
       if "maxwidth" in sys.argv[1]:
           arg1 = sys.argv[1].rpartition("=")
           maxwidth = int(arg1[2])
           print("maxwidth set {}".format(maxwidth))

   if len(sys.argv) > 2:
       if "format" in sys.argv[2]:
           arg2 = sys.argv[2].rpartition("=")
           format = str(arg2[2])

           print("format set {}".format(format))
   return maxwidth, format
main()
