#!/usr/bin/env python3
mydict = {(7, 3): '#FF0000', (4, 7): '#FF0000', (1, 3): '#FF0000', (6, 4): '#FF0000', (3, 0): '#FF0000', (5, 4): '#FF0000', (2, 1): '#FF0000', (5, 6): '#FF0000', (2, 6): '#FF0000', (1, 6): '#FF0000', (3, 7): '#FF0000', (5, 1): '#FF0000', (2, 5): '#FF0000', (0, 3): '#FF0000', (7, 2): '#FF0000', (4, 0): '#FF0000', (1, 2): '#FF0000', (6, 7): '#FF0000', (3, 3): '#FF0000', (0, 6): '#FF0000', (7, 6): '#FF0000', (4, 4): '#FF0000', (6, 3): '#FF0000', (1, 5): '#FF0000', (3, 6): '#FF0000', (2, 2): '#FF0000', (7, 7): '#33FF00', (5, 7): '#FF0000', (3, 5): '#FF0000', (4, 1): '#FF0000', (1, 1): '#FF0000', (2, 7): '#FF0000', (3, 2): '#FF0000', (0, 0): '#FF0000', (6, 6): '#FF0000', (5, 0): '#FF0000', (7, 1): '#FF0000', (4, 5): '#FF0000', (0, 4): '#FF0000', (5, 5): '#FF0000', (1, 4): '#FF0000', (6, 0): '#FF0000', (7, 5): '#FF0000', (2, 3): '#FF0000', (0, 7): '#FF0000', (4, 2): '#FF0000', (1, 0): '#FF0000', (6, 5): '#FF0000', (5, 3): '#FF0000', (0, 1): '#FF0000', (7, 0): '#FF0000', (4, 6): '#FF0000', (3, 4): '#FF0000', (6, 1): '#FF0000', (3, 1): '#FF0000', (0, 2): '#FF0000', (7, 4): '#FF0000', (2, 0): '#FF0000', (6, 2): '#FF0000', (4, 3): '#FF0000', (1, 7): '#FF0000', (0, 5): '#FF0000', (5, 2): '#FF0000', (2, 4): '#FF0000'}


height = 4
width = 4
newcoords = []
for x in range(width):
     for y in range(height):
         newcoords.append((x,y))
 
#intermediary list created be you you cant delete an item whilst itterating over and object

old_keys = []i
for key in mydict.keys():
    old_keys.append((key))


for key in old_keys:
    if key in newcoords:
         print("save   ",key)
    else:
         del mydict[key]
         print("delete ",key)


print(mydict)
