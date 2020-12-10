#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Sep 15 16:42:27 2020

@author: cheng_sam
"""
import io

# with is like your try .. finally block in this case
# with open('test.txt', 'r') as file:
    # read a list of lines into data
    # data = file.readlines()

# print data
# print "Your name: " + data[0]

# now change the 2nd line, note that you have to add a newline
# data[1] = 'Mage\n'

# and write everything back
# with open('test.txt', 'w') as file:
#     file.writelines( data )
  
    
  
with open("test.txt", "r") as f:
    lines = f.readlines()
with open("test.txt", "w") as f:
    for line in lines:
        if line.strip("\n") != "nickname_to_delete":
            f.write(line)
  
    
# for name2, lines2 in dict_order.items():
#     if name2 in dict_add:
#         continue
#     if name2 not in dict_add and name2 in dict_buffer:

#         for l in dict_buffer[name2]:
#             file1.write(l)
#         file1.write("\n")