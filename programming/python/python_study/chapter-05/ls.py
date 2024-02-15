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


file_list = []
sorted_file_list = []

if not args:
    args.append('.') #default to local directory

def display_files():
    for filename in sorted_file_list:
        if ((filename[3].startswith('.')) and (opts.hidden == False)):
            pass # filter out the hidden files
        else:
            if (opts.modified == opts.sizes): # if either both are true or both are false
                print("{0} {1:>12n} {2}".format(filename[0],filename[1],filename[2] ))
            elif ((opts.modified  == True) &  (opts.sizes == False)) :
                print("{0} {1}".format(filename[0],filename[2]))
            elif ((opts.modified == False) & (opts.sizes == True)):
                print("{0:>12n} {1}".format(filename[1],filename[2]))

def sort_files(file_list): 
    if opts.order == "name":
        sorted_file_list=sorted(file_list, key=lambda file_list: file_list[2])
    elif opts.order == "size":
        sorted_file_list=sorted(file_list, key=lambda file_list: file_list[1])
    elif opts.order == "modified":
        sorted_file_list=sorted(file_list, key=lambda file_list: file_list[0])
    return sorted_file_list 

for dirs in args:
    if opts.recursive == False:
       files = os.listdir(dirs) 
       for filename in files:
          fullname = filename
          filesize = os.path.getsize(fullname)
          modified = time.strftime("%Y-%m-%d %H:%M:%S",time.gmtime(os.path.getmtime(fullname)))
          file_list.append([modified,filesize,fullname,filename])
    else:
        for root, dirs, files in os.walk(dirs):
            for filename in files:
                fullname = os.path.join(root,filename)
                filesize = os.path.getsize(fullname)
                modified = time.strftime("%Y-%m-%d %H:%M:%S",time.gmtime(os.path.getmtime(fullname)))
                file_list.append([modified,filesize,fullname,filename])

sorted_file_list = sort_files(file_list)
display_files()
