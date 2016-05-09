#!/usr/bin/env python3


mylist = ['8','7','5','4','6','1','9','2','3']

print(mylist)


x = 1
y = 0 
while y < ( len(mylist) -1 ):
    print("x = ",x ,"y = ",y)
    print(" y < list -1")
    while x < len(mylist):
        print("x = ",x ,"y = ",y)
        if mylist[y] > mylist[x]:
            temp = mylist[y]
            mylist[y] =  mylist[x]
            mylist[x] =  temp
        print(mylist)
        x += 1
    y += 1
    x = y +1
print(mylist)

