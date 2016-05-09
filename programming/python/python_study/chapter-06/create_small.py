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
width, height =8 , 8 
image = Image(width, height, img)
for x in range(width):
    for y in range(height):
        if x < width or y < height:
            image[x, y] = blue

width, height =122 , 122 
image.resize(width,height)
#for x, y in ((3, 1), (4, 0), (4, 1), (4, 2), (5, 0), (5, 1), (5, 2),(6, 1)):
#   image[(x, y)] = red

for x in range(width):
    for y in range(height):
        if x < 5 or x >= width - 5 or y < 5 or y >= height -5:
            image[x, y] = border_color

image[width -1 ,height -1] = green
image[width -1 ,height -2] = green
image[width -2 ,height -1] = green
image[width -2 ,height -2] = green

midx = width //2
midy = height //2
for x in range(width):
    for y in range(height):
        if x == midx or  y == midy :
            image[x, y] = black


print(image.width, image.height, len(image.colors), image.background)
image.save("small.save")
image.export("small.xpm")
print(image.colors)

#resize image
width, height = 122, 100
image.resize(width,height)

for x in range(width):
    for y in range(height):
        if x < 5 or x >= width - 5 or y < 5 or y >= height -5:
            image[x, y] = border_color
midx = width //2
midy = height //2

for x in range(width):
    for y in range(height):
        if x == midx or  y == midy :
            image[x, y] = black 

image.save("smaller.save")
image.export("smaller.xpm")
print(image.colors)
image.resize(None,None)
