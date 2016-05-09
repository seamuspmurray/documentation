#!/usr/bin/env python3
import random
import sys

articles = ("a","and","an","the")
subjects = ("ball","man","woman") 
verbs = ("kicked","threw","held")
adverbs = ("vigorusly","lovenly","loudly")

count = 0
try:
     arg1 = int(sys.argv[1])

     if ( ( arg1 > 0) and ( arg1 < 11) ):
         limit = arg1
     else:
         limit = 5
except IndexError:
     limit = 5
except ValueError:
     limit = 5

while count < limit:
    choice = random.randint(1,2)
    if choice == 1:
        print(random.choice(articles),random.choice(subjects),random.choice(verbs),random.choice(adverbs))
    else:
        print(random.choice(articles),random.choice(subjects),random.choice(verbs))
    count += 1
