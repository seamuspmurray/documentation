#!/usr/bin/env python3

import os
import tempfile
import Image
from Image import Image

red = "#FF0000"
blue = "#0000FF"
yellow = "#FFFF00"
border_color = "#FF0000" # red
square_color = "#0000FF" # blue
black = "#000000"
green = "#33FF00"


img = os.path.join(tempfile.gettempdir(), "test.img")
xpm = os.path.join(tempfile.gettempdir(), "test.xpm")

#create a small image and fill with blue
width, height =10 ,8 
image = Image(width, height, img)
for x, y in ((0, 0), (0, 7), (1, 0), (1, 1), (1, 6), (1, 7), (2, 1),
            (2, 2), (2, 5), (2, 6), (2, 7), (3, 2), (3, 3), (3, 4),
            (3, 5), (3, 6), (4, 3), (4, 4), (4, 5), (5, 3), (5, 4),
            (5, 5), (6, 2), (6, 3), (6, 4), (6, 5), (6, 6), (7, 1),
            (7, 2), (7, 5), (7, 6), (7, 7), (8, 0), (8, 1), (8, 6),
            (8, 7), (9, 0), (9, 7)):
   image[x, y] = blue
for x, y in ((3, 1), (4, 0), (4, 1), (4, 2), (5, 0), (5, 1), (5, 2),(6, 1)):
   image[(x, y)] = red
image.save("small.save")
image.export("small.xpm")

#expand the image
width, height =500,500 
midx, midy = width // 2, height // 2
newimage = Image(width, height, img, "#F0F0F0")
for x in range(width):
    for y in range(height):
        #green vertical bars for inner border
        if ((x >= 10 and x < 15) or ( x >= width - 15 and x <= width - 10 )) and (y >= 10 and y <= height -10):
           newimage[x, y] = green 
        #green horizontal bars for inner border
        if (x >= 10 and x <= width - 10 ) and ((y >= 10 and y <= 15) or ( y >= height -15 and y <= height -10)):
            newimage[x, y] = green            
        #black vertical bars on sides
        if ((x >= 30 and x < 65) or ( x >= width - 65 and x <= width - 30 )) and (y >= 30 and y <= height -30) and x % 3 == 0:
            newimage[x, y] = black 
        # green horizontal lines in center
        if ( x >= 85 and x <= width - 85 and x % 2 == 0 ) and (y >= 85 and y <= height - 85) and y % 4 == 0:
            newimage[x, y] =  green 
        #black horizontal lines in center
        if ( x >= 85 and x <= width - 85 and x % 2 == 1 ) and (y >= 85 and y <= height - 85) and y % 4 == 0:
            newimage[x, y] = black 
        #red horizontal lines in center
        if ( x >= 85 and x <= width - 85 ) and (y >= 85 and y <= height - 85) and (y % 2 == 0 and not y % 4 == 0):
            newimage[x, y] = red 
        if ( x >= 85 and x <= width - 85 and x % 3 == 0 ) and (y >= 85 and y <= height - 85) and (y % 2 == 0 and not y % 4 == 0):
           newimage[x, y] = yellow
 
for x in range(width):
    for y in range(height):
        if x < 5 or x >= width - 5 or y < 5 or y >= height -5:
            newimage[x, y] = border_color
        elif midx - 20 < x < midx + 20 and midy - 20 < y < midy + 20:
            newimage[x, y] = square_color

for x in range(width):
    for y in range(height):
        if x < 5 or x >= width - 5 or y < 5 or y >= height -5:
            newimage[x, y] = border_color

print(newimage.width, newimage.height, len(newimage.colors), newimage.background)
newimage[midy,midx] = black
newimage.save("meduim.save")
newimage.export("seamus.xpm")

newimage.resize(800,800)
newimage.export("large.xpm")

newimage.resize(300,300)
newimage.export("shrink.xpm")
print(newimage.colors)
