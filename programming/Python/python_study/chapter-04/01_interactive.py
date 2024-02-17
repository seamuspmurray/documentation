#!/usr/bin/env python3

import os
import sys
import string

lst_files = {}

def list_files_in_dir():
    key = 1
    all_files = os.listdir(".")
    for filename in all_files:
        if ".lst" in filename:
           lst_files[key] = filename
           key += 1
    if len(lst_files) == 0:
        lst_files[key] = create_new_file()
    return lst_files


def display_lines(line_buffer):
    linenum = 1
    
    if len(line_buffer) <= 9: #formatting the number field
        num_cols = 1
    elif len(line_buffer) <= 99:
        num_cols = 2
    else:
        num_cols = 3
    
    line_buffer = sorted(line_buffer)
    for line in line_buffer:
        print("{0:{2}} {1}".format(linenum,line,num_cols), end="")
        linenum += 1
    if len(line_buffer) == 0: 
         print("File is empty")
    print("") # new line for formating


def create_new_file():
    print("there are no .lst files in the current directory")
    newfilename = input("enter a new filename :")
    if ".lst" not in newfilename:
        newfilename = newfilename+".lst"
    try:
        filehandle = open( newfilename, "a", encoding="utf8")
        return newfilename
    except EnvironmentError as err:
        print("ERROR", err)
    

def display_file_list():
    if len(lst_files) <= 9: #formatting the number field
        num_cols = 1
    elif len(lst_files) <= 99:
        num_cols = 2
    else:
        num_cols = 3
    
    key = 1
    for i in lst_files:
        print("{0:{2}} {1}".format(key ,lst_files[key],num_cols))
        key += 1


def read_file(key, lst_files):
    try:
        filehandle = open(lst_files[key], "r+", encoding="utf8")
        line_buffer = []
        for line in filehandle:
            line_buffer.append(line)
        return line_buffer
    except EnvironmentError as err:
        print("ERROR", err)
    finally:
        if filehandle is not None:
            filehandle.close()

 
def write_file(key, lst_files, line_buffer):
    try:
        filehandle = open(lst_files[key], "w", encoding="utf8")
        for line in line_buffer:
            filehandle.write(line) 
        print("Saved {0}".format(lst_files[key]))
    except EnvironmentError as err:
        print("ERROR", err)
    finally:
        if filehandle is not None:
            filehandle.close()

 
def get_file_key(lst_files): 
    while True:
        try:
            key = int(input("choose a filename :"))
            file = lst_files[key]
            return key
        except ValueError as err:
            print("you must enter an integer coresponding to the list")
        except KeyError as err:
            print("you must enter an integer coresponding to the list")



def del_line(line_buffer): 
    while True:
        try:
            line_num = int(input("Delete item number (or 0 to cancel): "))
            if line_num == 0:
                 return line_buffer # do nothing and return
            del line_buffer[line_num -1 ]
            return line_buffer
        except ValueError as err:
            print("you must enter an integer coresponding to the list")
        except IndexError as err:
            print("you must enter an integer coresponding to the list")
            

def add_or_quit():
    while True:
        action = input("[A]dd  [Q]uit [a]: ")
        if action == "A" or action == "a":
             new_line = input("Add item: ")
             line_buffer.append(new_line + '\n')
             display_lines(line_buffer)
             buffer_dirty = True
             return buffer_dirty
        elif action == "Q" or action == "q":
             exit()
        else:
         print("ERROR: invalid choice--enter one of 'AaQq'")


def add_delete_save_or_quit(key,lst_files,line_buffer,buffer_dirty):
    while True:
        action = None
        if buffer_dirty: #hide the save option if no changes have been made
            action = input("[A]dd  [D]elete  [S]ave  [Q]uit [a]: ")
        else:
            action = input("[A]dd  [D]elete  [Q]uit [a]: ")

        if action == "A" or action == "a":
             new_line = input("Add item: ")
             line_buffer.append(new_line + '\n')
             display_lines(line_buffer)
             buffer_dirty = True
        elif action == "D" or action == "d":
             line_buffer =  del_line(line_buffer)
             display_lines(line_buffer)
             buffer_dirty = True
        elif action == "S" or action == "s":
             write_file(key,lst_files,line_buffer)
             display_lines(line_buffer)
        elif action == "Q" or action == "q":
             exit()
        else:
             print("ERROR: invalid choice--enter one of 'AaDdSsQq'")

buffer_dirty = False
list_files_in_dir()
display_file_list()
key = get_file_key(lst_files)
line_buffer = read_file(key,lst_files)
display_lines(line_buffer)
if len(line_buffer) < 1:
    buffer_dirty = add_or_quit()


add_delete_save_or_quit(key,lst_files,line_buffer,buffer_dirty)


