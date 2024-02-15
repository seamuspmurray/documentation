#!/usr/bin/env python3
print("Type integers, each followed by Enter: or ^D or ^Z to finish")
total = 0
number = 0
lowest = 0
highest = 0
mean = 0
mylist = [] 
while True:
    try:
        line = input("Enter a number or Enter to finish: ")
        if line:
           newnum = int(line)
           mylist += line 
           total += newnum
           number += 1
      
   


           if number == 1:  #placing the first number entered in the lowest spot
                lowest = newnum
           if newnum > highest:
                highest = newnum
           if newnum < lowest:
                lowest = newnum
        elif not line == '\n':
#           print("Enter") 
            if total:
                 print("count =", number, "total =", total, "lowest =", lowest, "highest =" , highest, "mean =", total / number)
            break
    except ValueError as err:
        print(err)
        continue
    except EOFError:
        break

#sort mylist
x = 1
y = 0
while y < ( len(mylist) -1 ):
#    print("x = ",x ,"y = ",y)
#    print(" y < list -1")
    while x < len(mylist):
#        print("x = ",x ,"y = ",y)
        if mylist[y] > mylist[x]:
            temp = mylist[y]
            mylist[y] =  mylist[x]
            mylist[x] =  temp
#        print(mylist)
        x += 1
    y += 1
    x = y +1
#print(mylist)

# find median
if ( ( len(mylist) / 2 ) == (int( len(mylist)/ 2)) ):
     print("even")
     upper_middle = int(len(mylist) / 2 )
     lowwer_middle = int(upper_middle - 1)
     median = ( ( int(mylist[lowwer_middle]) + int(mylist[upper_middle]) ) / 2 )
else:
     print("odd")
     median_location = ( int(len(mylist) / 2) )
     median = mylist[median_location]

print("count =", number, "total =", total, "lowest =", lowest, "highest =" , highest, "mean =", total / number, "median =", median)
