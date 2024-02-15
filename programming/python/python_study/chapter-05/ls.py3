#!/usr/bin/env python3
import os, sys, collections, time 
import locale #required for the "n" in the file size number format
import optparse
import pprint

locale.setlocale(locale.LC_ALL, "")


parser = optparse.OptionParser()
parser.add_option("-m", "--modified", action="store_true", dest="modified", default=False, help=("show last modified date/time [default: off]"))
parser.add_option("-o", "--order", dest="order", default="name", help=("order by ('name', 'n', 'modified', 'm', 'size', 's') [default: name]"))
parser.add_option("-r", "--recursive", action="store_true", dest="recursive", default=False, help=("recurse into subdirectories [default: off]"))
parser.add_option("-s", "--sizes", action="store_true", dest="sizes", default=False, help=("show sizes [default: off]"))
parser.add_option("-H", "--hidden", action="store_true", dest="hidden", default=False, help=("show hidden files [default: off]"))
(opts, args) = parser.parse_args()

# put the file list in a 3 tuple list
# create a fuction to use as a sort key
# itterrate over the list and run it through the filter if else statements

file_list = []
if not args:
    args.append('.') #default to local directory

for dirs in args:
    if opts.recursive == False:
       files = os.listdir(dirs) 
       for filename in files:
          fullname = filename
          filesize = os.path.getsize(fullname)
          modified = time.strftime("%Y-%m-%d %H:%M:%S",time.gmtime(os.path.getmtime(fullname)))
          file_list.append([modified,filesize,fullname])
          if ((fullname.startswith('.')) and (opts.hidden == False)):
              pass # filter out the hidden files
          else:
              if (opts.modified == opts.sizes): # if either both are true or both are false
                  print("a  {0} {1:>12n} {2}".format(modified , filesize,fullname))
              elif ((opts.modified  == True) &  (opts.sizes == False)) :
                  print("b  {0} {1}".format(modified,fullname))
              elif ((opts.modified == False) & (opts.sizes == True)):
                  print("c  {0:>12n} {1}".format(filesize,fullname))

    else:
        for root, dirs, files in os.walk(dirs):
            for filename in files:
                file_name = filename
                fullname = os.path.join(root,filename)
                filesize = os.path.getsize(fullname)
                modified = time.strftime("%Y-%m-%d %H:%M:%S",time.gmtime(os.path.getmtime(fullname)))
                file_list.append([modified,filesize,fullname])
                if ((file_name.startswith('.')) and (opts.hidden == False)):
                    pass # filter out the hidden files
                else:
                    if (opts.modified == opts.sizes): # if either both are true or both are false
                        print("a  {0} {1:>12n} {2}".format(modified , filesize,fullname))
                    elif ((opts.modified  == True) &  (opts.sizes == False)) :
                        print("b  {0} {1}".format(modified,fullname))
                    elif ((opts.modified == False) & (opts.sizes == True)):
                        print("c  {0:>12n} {1}".format(filesize,fullname))
print("sort by name")
for files in sorted(file_list, key=lambda file_list: file_list[2]): #name
    print("a  {0} {1:>12n} {2}".format(files[0],files[1],files[2]))
print("sorted by size")
for files in sorted(file_list, key=lambda file_list: file_list[1]):
    print("a  {0} {1:>12n} {2}".format(files[0],files[1],files[2]))
print("sorted by modified")
for files in sorted(file_list, key=lambda file_list: file_list[0]):
    print("a  {0} {1:>12n} {2}".format(files[0],files[1],files[2]))
