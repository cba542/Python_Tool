#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Oct 29 11:38:40 2020

@author: cheng_sam
"""
import re


with open ("tr.txt", "r") as myfile:
    lines = myfile.readlines()
    myfile.close()
    for numbers, line in enumerate(lines):
        temp = re.search('\{.*\"',line)
        if temp:
            st = temp.group()
            st = st.replace("{", "")
            st = st.replace("\"", "")
            print(st)


x = "    { \"neutron_inc_count\", titanium_inc_neutron_cycle_count, NULL,"

print(x)
# a = re.match("{.*"  ,  "    { \"neutron_inc_count\"\, titanium_inc_neutron_cycle_count\, NULL\," ).group()
a = re.search('\{.*\"',x ).group()
print(a)