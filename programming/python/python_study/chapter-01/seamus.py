#!/usr/bin/env python3
line = " ***      *    ***** "
myline = list(line)
print(myline)
charpos = 0
while (charpos < 20):
      if myline[charpos] == "*":
          myline[charpos] = "c"
      charpos = charpos + 1
print(myline)
