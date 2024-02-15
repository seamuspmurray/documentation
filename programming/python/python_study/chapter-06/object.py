#!/usr/bin/env python3


class parent():
     def __init__(self,name,sex,age,yob):
         self.name = name
         self.sex  = sex
         self.age  = age
         self.yob  = yob
     def older(self):
         self.age = self.age + 1
     def yearsalive(self):
         return list(range(self.yob, (self.yob + self.age)))
     def printyeasrsalive(self):
         print("years alive is {0}".format(yearsalive(self)))
         


