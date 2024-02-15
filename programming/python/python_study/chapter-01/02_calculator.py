#!/usr/bin/env python3
print("Type integers, each followed by Enter: or ^D or ^Z to finish")
total = 0
number = 0
lowest = 0
highest = 0
mean = 0
while True:
    try:
        line = input("Enter a number or Enter to finish: ")
        if line:
           newnum = int(line)
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

