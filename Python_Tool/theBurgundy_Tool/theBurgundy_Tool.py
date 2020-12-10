#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Jul  1 15:15:55 2020

@author: cheng_sam
"""

# import sys
from sys import exit as sysexit
from sys import argv as sysargv
from pathlib import Path
import sys
# import io
# import getopt
import os
# from os import path, listdir

# from PyQt5 import QtCore, QtGui, QtWidgets 
# from PyQt5.QtWidgets import QApplication, QMainWindow, QListWidget, QListWidgetItem, QPushButton, QLabel
# from PyQt5.QtCore import Qt, QUrl
from PyQt5.QtCore import Qt
# from UI.Label import Ui_MainWindow
# from PyQt5.QtWidgets import *
from PyQt5.QtWidgets import QListWidget, QMainWindow, QScrollArea, QApplication, QLabel, QWidget, QVBoxLayout, QPushButton, QListWidgetItem, QCheckBox
# from PyQt5 import QtWidgets
# from itertools import islice
# from PyQt5 import QtCore, QtGui 
# from PyQt5.QtGui import * 
# from PyQt5.QtCore import * 
# filepath = "BurgundyInit-IO3.lua"
# filepath = "BurgundyInit-IO3 copy.lua"
# filepath = "BurgundyInit-IO1.lua"
# filepath = "BurgundyInit-IO1 copy.lua""\033[32mPASS\033[0m"

import collections

# import cv2

import time

UI_Title = "theBurgundy_Toolv22"

lis_order = []
lis_add = []
lis_ptf = []
dict_order = {}
dict_add = {}
dict_add_buffer = {}
dict_buffer={}
# dag_PASSflag = 0

cycle_dict = {}
exist_check =[]

append_val1 = []
append_val2 = []


output = ""

lis_remove_add = []

# resultStr = ""
# PASS_color_result = "\033[32mPASS\033[0m"

# FAIL_color_result = "\033[31mFAIL\033[0m"

PASS_color_result = "PASS\n"

FAIL_color_result = "FAIL\n"

def releaseNote():
    print("""
          Release Note
          theBurgundy_Toolv19 : Fixed Queue check issue . When there are "--" in the end
          theBurgundy_Toolv20 : Fixed Ptf check issue
          """)

def printHelp():
    print("""
          -h help; -v release note; -i luaFile; -p pftFile; -a luaFile(auto add)
          Python3 BurgundyInit_check.py -i \033[35mluaFile\033[0m -p \033[36mpftFile\033[0m

          Step1 -> Execute CMD
          Step2 -> Compare dag.add and dag.order in \033[35mluaFile\033[0m
          Step3 -> Compare \033[35mluaFile\033[0m and \033[36mpftFile\033[0m(Opeional)
          Step4 -> Check duplicate declartion in \033[36mpftFile\033[0m(Opeional)
          Step5 -> Collect dag.add from current folder(*.lua files) and add miss dag.add to txt file(Opeional)
          Step6 -> Check dag.order queue in \033[35mluaFile\033[0m
          CMD Example:
          -----------------------------------------------------
          Python3 %s -i BurgundyInit-IO1.lua 
          Python3 %s -i BurgundyInit-IO1.lua -p pft.pft
          Python3 %s -a BurgundyInit-IO1.lua -p pft.pft
          -----------------------------------------------------
          """ % ( os.path.basename(sys.argv[0]),os.path.basename(sys.argv[0]), os.path.basename(sys.argv[0]) ) )


                        

def burgundy_compare(luaFilePath, autoflag):

    lis_order = []
    lis_add = []

    dict_order = {}
    global dict_add
    dict_add = {}

    # global dict_buffer
    # dict_buffer = {}
    dag_order_PASSflag = 0
    dag_add_PASSflag = 0
    global output

    global lis_remove_add
    lis_remove_add = []
    
    print("=========Start Check Burgundy==================")
    output += "=========Start Check Burgundy==================\n"
    skipflag = 0
    with open (luaFilePath, "r") as myfile:
        lines = myfile.readlines()
        myfile.close()
        for numbers, line in enumerate(lines):
            #Skip to check lua comment area --[[ ... ]]--
            if "[[" in line:
                skipflag=1
            if "]]" in line:
                skipflag = 0
                continue
        
            if skipflag == 1:
                continue
        	
        
            if "dag.order" in line and "--" not in line:
                lin_mod = line.replace("dag.order(", "")
                lin_mod = lin_mod.replace(")", "")
                lin_mod = lin_mod.replace(" ", "")
                lin_mod = lin_mod.replace("\n", "")
                lin_mod = lin_mod.replace("\t", "")
                lis = lin_mod.split(",")
                for ele in lis:
                    if ele not in lis_order:
                        lis_order.append(ele)
                    if ele not in dict_order:
                        dict_order[ele] = numbers
                # print(lis_order)
                
            if "dag.add" in line and "--" not in line:
                line_mod2 = line.replace("dag.add(", "")
                line_mod2 = line_mod2.replace("=", "")
                line_mod2 = line_mod2.replace(" ", "")
                line_mod2 = line_mod2.replace("\n", "")
                line_mod2 = line_mod2.replace("\t", "")
                # print(line_mod2)
                if line_mod2 not in lis_add:
                    lis_add.append(line_mod2)
                    if line_mod2 not in dict_add:
                        dict_add[line_mod2] = numbers
                else:
                    print("Duplicate dag.add = %s\n" % line_mod2)
                    output += "Duplicate dag.add = %s\n" % line_mod2
                    print(FAIL_color_result)
                    output += FAIL_color_result

                    return 


    dag_order_PASSflag = 1
    dag_add_PASSflag = 1
    for name1, lines1 in dict_add.items():
        if name1 not in dict_order:
            dag_order_PASSflag = 0
            print("dag.order miss %35s(line %4d)" % (name1, lines1+1))
            output += "dag.order miss %35s(line %4d)\n" % (name1, lines1+1)
            lis_remove_add.append(name1)
    for name2, lines2 in dict_order.items():
        if name2 not in  dict_add:
            dag_add_PASSflag = 0
            print("dag.add  miss %35s(line %4d)" % (name2, lines2+1 ))
            output += "dag.add  miss %35s(line %4d)\n" % (name2, lines2+1 )

    if dag_add_PASSflag == 1 and dag_order_PASSflag == 1:
        print("dag.add match dag.order")
        print(PASS_color_result)
        output += "dag.add match dag.order\n"
        output += PASS_color_result
    else:
        print(FAIL_color_result)
        output += FAIL_color_result
        
        if autoflag == 1 and dag_add_PASSflag == 0:
            autoFix(luaFilePath)
    
            file1 = open("dag_add_miss_itmes.txt", "w")


            
            autoCreate_DagAddLog=""     
            for name2, lines2 in dict_order.items():
                if name2 in dict_add:
                    continue
                if name2 not in dict_add and name2 in dict_buffer:
                    # print("add %30s to %s" %(name2, file1.name))
                    # output += ("add %30s to %s" %(name2, file1.name))
                    for l in dict_buffer[name2]:
                        file1.write(l)
                    file1.write("\n")
                else:
                    autoCreate_DagAddLog += ("There is no %30s(line %d) in exist *.lua file\n" %(name2, lines2+1))
            
            if len(autoCreate_DagAddLog) != 0:
                # autoCreate_DagAddLog = autoCreate_DagAddLog[:-2]
                print(autoCreate_DagAddLog)
                print(FAIL_color_result)
                output += autoCreate_DagAddLog
                output += FAIL_color_result
            else:
                # print("Lua file contain are all dag.add items")
                print(PASS_color_result)
                output += PASS_color_result
            file1.close()
        # SamDebug
        if os.path.exists("dag_add_all_items.txt"):
            os.remove("dag_add_all_items.txt")

    # myfile.close()

def autoAdd(luaFilePath):
    global output
    writeflag = 1
    print("\n=========Start Auto Add=======================")
    output += "\n=========Start Auto Add=======================\n"
    print("Auto Add Lost dag.add\n")
    output += "Auto Add Lost dag.add \n"

    with open(luaFilePath, "r") as f:
        lines = f.readlines()
    f.close()
    with open(luaFilePath, "w") as f:
        for pos, line in enumerate(lines):
            if "dag.order" in line and writeflag == 1:
                f.write("\n")
                with open("dag_add_miss_itmes.txt","r") as f1:
                    m_lines = f1.readlines()
                    for m_line in m_lines:
                        f.write(m_line)
                f.write(line)
                
                # f1.close()
                writeflag = 0
            else:
                f.write(line)

    f.close()


def autoDelete(luaFilePath,lis_remove_add):
    global output
    print("\n=========Start Auto Delete====================")
    output += "\n=========Start Auto Delete====================\n"
    print("Auto Delete useless dag.add items\n")
    output += "Auto Delete useless dag.add items\n"
    skipwrite = 0
    skipflag = 0
    with open(luaFilePath, "r") as f:
        lines = f.readlines()
        f.close()
    with open(luaFilePath, "w") as f:
        for line in lines:
            if skipwrite > 0:
                f.write("--")
                f.write(line)
                skipwrite -= 1
                continue
            
            if "[[" in line:
                f.write(line)
                skipflag = 1
                continue
            if "]]" in line:
                f.write(line)
                skipflag = 0
                continue
        
            if skipflag == 1 or "--" in line:
                f.write(line)
                continue
            

            if "dag.order" in line:
                f.write(line)
                continue
            if not any(ele in line for ele in lis_remove_add):
                f.write(line)
            else:
                f.write("--")
                f.write(line)
                skipwrite = 8
        f.close()

def autoFix(luaFilePath):
    global output
    print("\n=========Start Auto Create=====================")
    print("Polling *.lua to create miss dag.add")
    print("dag_add_miss_itmes.txt will auto create miss dag.add items")
    output += ("\n=========Start Auto Create=====================\n")
    output += ("Polling *.lua to create miss dag.add\n")
    output += ("dag_add_miss_itmes.txt will auto create miss dag.add items\n")
    # file1 = open("dag_add_all_items.txt", "w")
    # topdir = './'
    # for dirpath, dirnames, files in os.walk(topdir):
        # print("dirpath =" ,dirpath)
        # print("dirnames =", dirnames)
        # print("files =", files)
    p = Path(luaFilePath)
    os.chdir(p.parent)
        
    files = [file for file in os.listdir('.') if os.path.isfile(file)]
    for file in files:
        for file in files:
            if 'lua' in file[-3:]:
                FilePath = file
                with open (FilePath, "r") as myfile:
                    lines = myfile.readlines()
                    myfile.close()
                    for numbers, lines in enumerate(lines):
                        if "dag.add" in lines and '--' not in lines:
                            lines_mod = lines.replace("dag.add(", "")
                            lines_mod = lines_mod.replace(")", "")
                            lines_mod = lines_mod.replace(" ", "")
                            lines_mod = lines_mod.replace("\n", "")
                            lines_mod = lines_mod.replace("\t", "")
                            lines_mod = lines_mod.replace("=", "")
                            #dag.add format contain 9 lines 

                            with open (FilePath, "r") as myfile:
                                str_buffer = myfile.readlines()[numbers:numbers+9]
                                myfile.close()
                            #Make sure Burgundy Test Name not duplicate
                            if lines not in dict_buffer:
                                #Append dict_buffer, key = Burgundy Test Name, value = dag.add format
                                dict_buffer[lines_mod] = str_buffer
                                # for l in dict_buffer[lines_mod]:
                                    # file1.write(l)
                                # file1.write("\n")
    # file1.close()

    # myfile.close()
    if os.path.exists("dag_add_all_items.txt"):
        os.remove("dag_add_all_items.txt")

def ptf_Compare(ptfFilePath):
    global output
    print("=========Start Compare Burgundy and PTF========")
    output += ("=========Start Compare Burgundy and PTF========\n")
    passFlag = 1;
    lis_ptf = []
    global dict_add
    with open (ptfFilePath, "r") as myfile:
        for line in myfile:
            if "name" in line:
                lin_mod3 = line.replace("name","")
                lin_mod3 = lin_mod3.replace(":","")
                lin_mod3 = lin_mod3.replace("\"","")
                lin_mod3 = lin_mod3.replace(",","")
                lin_mod3 = lin_mod3.replace("\t","")
                lin_mod3 = lin_mod3.replace(" ","")
                lin_mod3 = lin_mod3.replace("\n", "")
                if lin_mod3 not in lis_ptf:
                    lis_ptf.append(lin_mod3)
                else:
                    print("%s duplicate declaration in ptf\n" % lin_mod3)
                    output += ("%s duplicate declaration in ptf\n" % lin_mod3)
              
    for name1,lines1 in dict_add.items():
        if name1 not in lis_ptf:
            # print("%s miss %s(line %d in Burgundy)" % (ptfFilePath, name1, lines1+1))
            print("%s miss %s\n" % (os.path.basename(ptfFilePath), name1))
            output += ("%s miss %s\n" % (os.path.basename(ptfFilePath), name1))
            
            passFlag = 0
            
    if passFlag:
        print("%s include all Burgundy items\n" % (os.path.basename(ptfFilePath)))
        output += ("%s include all Burgundy items\n" % (os.path.basename(ptfFilePath)))
        # print("ptf include all Burgundy items")
        print(PASS_color_result)
        output += (PASS_color_result)
    else:
        print(FAIL_color_result)
        output += (FAIL_color_result)
    myfile.close()
    
def check_cycle(luaFilePath):

    exist_check =[]
    
    append_val1 = []
    append_val2 = []
    global output
    output = ""
    last_line_check = 0
    print("=========Start Queue Check ===================")
    output += ("=========Start Queue Check ===================\n")
    with open (luaFilePath, "r") as myfile:
        lines = myfile.readlines()
        myfile.close()
        skipflag = 0

        for numbers, line in enumerate(lines):
            if "--[[" in line:
                skipflag = 1
            if "--]]" in line:
                skipflag = 0
                continue
        
            if skipflag == 1:
                continue
            
            if "dag.order" in line and "--" not in line.split('order')[0]:
                lin_mod = line.replace("dag.order(", "")
                lin_mod = lin_mod.split(")", 1)[0]
                lin_mod = lin_mod.replace(" ", "")
                lin_mod = lin_mod.replace("\n", "")
                lin_mod = lin_mod.replace("\t", "")
                lis = lin_mod.split(",")
                for ele in lis:
                    if ele not in exist_check:
                        exist_check.append(ele)
    # myfile.close()
    count_flag = 0
    count_flag_next = 0
    append_val3 = []
    append_val4 = {}
    append_val5 = []
    key = 0
    check_cycle_is_PASS = 1
    # myfile.close()
    with open (luaFilePath, "r") as myfile:
        lines = myfile.readlines()
        myfile.close()
        compare = lambda x, y: collections.Counter(x) == collections.Counter(y)
        for numbers, line in enumerate(lines):
            if "[[" in line:
                skipflag = 1
            if "]]" in line:
                skipflag = 0
                continue
        
            if skipflag == 1:
                continue
            
            if "dag.order" in line and "--" not in line.split('order')[0]:
                last_line_check = numbers
                lin_mod = line.replace("dag.order(", "")

                lin_mod = lin_mod.split(")", 1)[0]
                lin_mod = lin_mod.replace(" ", "")
                lin_mod = lin_mod.replace("\n", "")
                lin_mod = lin_mod.replace("\t", "")
                lis = lin_mod.split(",")

                _cur = lis[0]
                _next = lis[1]
                
    
                if _cur in append_val2:

                    # append_val4.key = key
                    # append_val4.key = append_val1
                    # append_val4[key] = [append_val1]
                    append_val4.update({key: append_val1.copy()})
                    key += 1
                    
                    if key >= 3:
                        if not compare(append_val4[key-1], append_val4[key-2]):
                            print("!!!Warring!!! %s , %s (line %d)\n" % (append_val4[key-2], append_val4[key-1], last_line_check+1))
                            output += ("!!!Warring!!! %s, %s (line %d)\n" % (append_val4[key-1], append_val4[key-2], last_line_check+1))
                            print(FAIL_color_result)
                            output += FAIL_color_result
                            check_cycle_is_PASS = 0
                            # return False        

                    for val in append_val1:
                        append_val3.append(val)
                    # for val in append_val2:
                        # append_val3.append(val)

                    # append_val3.update({ (last_line_check-1) : append_val2.copy()})
                    append_val4.update({key: append_val2.copy()})
                    key += 1
                    # append_val4.key = key
                    # append_val4.key = append_val2
                    # append_val1.clear()
                    # append_val1 = append_val2.copy()
                    append_val1.clear()
                    append_val2.clear()
                    last_line_check = numbers
  
                        
       
                #append val1, val2
                if _cur not in append_val1:
                    append_val1.append(_cur)
                    if _next not in append_val2:
                        append_val2.append(_next)
    
                
                if _cur in append_val1:
                    count_flag += 1
                    if _next not in append_val2:
                        append_val2.append(_next) 
    


    
    append_val4.update({key: append_val1.copy()})
    key += 1
    append_val4.update({key: append_val2.copy()})
    key += 1
    #Compare dag.order  _pre and _next
    
    #The feature to check duplicate dag.order
    append_val5 = []

    for _key in append_val4:
        print(len(append_val4) -1, _key)
        if _key % 2 == 0 or _key == (len(append_val4) -1):
            if append_val4[_key] not in append_val5:
                append_val5.append(append_val4[_key])
            else:
                print("!!!Duplicate order : %s" % append_val4[_key])
                output += ("!!!Duplicate order : %s\n" % append_val4[_key])
                check_cycle_is_PASS = 0
    #The feature to check duplicate dag.order

    
    if not compare(append_val4[key-2], append_val4[key-3]):
        print("Incorrect on Item %s , %s (line %d)\n" % (append_val4[key-2], append_val4[key-3], last_line_check+1))
        output += ("Incorrect on Item %s, %s (line %d)\n" % (append_val4[key-2], append_val4[key-3], last_line_check+1))
        print(FAIL_color_result)
        output += FAIL_color_result
        # return False
        check_cycle_is_PASS = 0
    #Compare dag.order cycle duplicate
    print(len(append_val4))
    for i in range(0, len(append_val4), 2):
        print(append_val4[i])
    
    if check_cycle_is_PASS == 1:
        print(PASS_color_result)
        output += PASS_color_result
        # myfile.close()
        return True

# def check_start(argv):
#     global lis_remove_add

#     cycle_result = check_cycle(argv)
#     #if Queue PASS then auto delete or add
#     # if not result:
#     if cycle_result is True:
#         burgundy_compare(argv, 1)
#         if os.path.exists("dag_add_miss_itmes.txt"):
#             autoAdd(argv)
#             os.remove("dag_add_miss_itmes.txt")
#         if lis_remove_add:
#             autoDelete(argv, lis_remove_add)
 
class ListBoxWidget(QListWidget):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setAcceptDrops(True)


        # self.setAttribute(Qt.WA_DeleteOnClose, True)
 
    def dragEnterEvent(self, event):
        if event.mimeData().hasUrls:
            event.accept()
        else:
            event.ignore()
 
    def dragMoveEvent(self, event):
        if event.mimeData().hasUrls():
            event.setDropAction(Qt.CopyAction)
            event.accept()
        else:
            event.ignore()
 
    def dropEvent(self, event):
        self.takeItem(0)
        if event.mimeData().hasUrls():
            event.setDropAction(Qt.CopyAction)
            event.accept()
            
            links = []
            for url in event.mimeData().urls():
                # https://doc.qt.io/qt-5/qurl.html
                if url.isLocalFile():
                    links.append(str(url.toLocalFile()))
                else:
                    links.append(str(url.toString()))
            self.addItems(links)          
        else:
            event.ignore()
        #-Start debug code-
        print("currenct item1 = ", self.currentItem())
        #-End debug code- 
    
class AppDemo(QMainWindow):
    def __init__(self):
        super().__init__()

        self.resize(800,600)
        # layout = QVBoxLayout()
        # self.setLayout(layout)
        
        #Set Windows Title
        self.setWindowTitle(UI_Title)
 
    
        # self.b1 = QtWidgets.QCheckBox("Button1")
        # self.b1.setChecked(True)
        # self.b1.setGeometry(50,0,200,50)
        
        
 
        #Create Label box
        self.lb1 = QLabel('Drag and Drop lua file',self)
        self.lb1.setGeometry(50,15,200,50)
        # self.lb1.setStyleSheet("border: 1px solid black;")
        self.lb1.setAlignment(Qt.AlignLeft | Qt.AlignVCenter)
        
        #Create Drag and Drop box
        self.listbox_view1 = ListBoxWidget(self)
        self.listbox_view1.setGeometry(50,50,700,50)
        #debug
        # print("current row = ", self.listbox_view1.currentRow())

        self.listbox_view2 = ListBoxWidget(self)
        self.listbox_view2.setGeometry(50,125,700,50)
        #debug
        # print("current row = ", self.listbox_view2.currentRow())
        
        
        #Create Label box
        self.lb1 = QLabel('Drag and Drop ptf file',self)
        self.lb1.setGeometry(50,90,200,50)
        # self.lb1.setStyleSheet("border: 1px solid black;")
        self.lb1.setAlignment(Qt.AlignLeft | Qt.AlignVCenter)
        
        #For Result label attribute
        self.lb1 = QLabel('Result',self)
        self.lb1.setGeometry(50,175,100,50)
        # self.lb1.setStyleSheet("border: 1px solid black;")
        # self.lb1.setAlignment(Qt.AlignCenter | Qt.AlignVCenter)

        #For scroll Label result screen
        self.lb2 = ScrollLabel(self) 
        self.lb2.setGeometry(50,225,700,300)
        
        #Create Check Box
        self.cb = QCheckBox('Auto Add/Delete item', self)
        self.cb.setGeometry(600,510,200,50)
        # self.cb = setGeometry()
        # self.cb.toggle()
        # self.cb.stateChanged.connect(self.changeTitle)


        #Create Button box
        self.bt1 = QPushButton('Check',self)
        # self.bt1.setStyleSheet("border: 1px solid black;")
        self.bt1.setGeometry(600,550,200,50)
        self.bt1.clicked.connect(self.showDialog)

        #??unknow Code??
        self.lb2.resize(700,300)
        
    def getSelectedItem(self):
        item = QListWidgetItem(self.listbox_view1.currentItem())
        return item.text()
 
    def getPtfItem(self):
        item = QListWidgetItem(self.listbox_view2.currentItem())
        return item.text()   
 
    def showDialog(self):
        #Sam++ ToDo add time-out
        self.lb2.setText("Running")
        self.lb2.setAlignment(Qt.AlignTop | Qt.AlignLeft)
        

        
        global lis_remove_add
               
        self.listbox_view1.setCurrentRow(0)
        self.listbox_view2.setCurrentRow(0)
        lua_path = ""
        ptf_path = ""
        lua_path = self.getSelectedItem()
        ptf_path = self.getPtfItem()
        
        cycle_result = check_cycle(lua_path)
        

        
        #if Queue PASS then auto delete or add
        # if not result:
        #Queue pass -> box checked -> auto add/delete
        #Queue fail -> only compare dag.order and dag.add 
        if cycle_result is True:
            if self.cb.isChecked():
                burgundy_compare(lua_path, 1)
                if os.path.exists("dag_add_miss_itmes.txt"):
                    autoAdd(lua_path)
                    os.remove("dag_add_miss_itmes.txt")
                if lis_remove_add:
                    autoDelete(lua_path, lis_remove_add)
            else:
                burgundy_compare(lua_path, 0)                
        else:
            if self.cb.isChecked():
                burgundy_compare(lua_path, 1)
                if os.path.exists("dag_add_miss_itmes.txt"):
                    autoAdd(lua_path)
                    os.remove("dag_add_miss_itmes.txt")
                if lis_remove_add:
                    autoDelete(lua_path, lis_remove_add)
            else:
                burgundy_compare(lua_path, 0)
        
        if ptf_path and lua_path:
            ptf_Compare(ptf_path)
        
        # output = new_stdout.getvalue()
        
        # sys.stdout = old_stdout
        print("output = ", output)
        self.lb2.label.setAlignment(Qt.AlignLeft | Qt.AlignTop) 
        self.lb2.setText(output)

        # self.show()

        
# class for scrollable label 
class ScrollLabel(QScrollArea): 
  
    # contructor 
    def __init__(self, *args, **kwargs): 
        QScrollArea.__init__(self, *args, **kwargs) 
  
        # making widget resizable 
        self.setWidgetResizable(True) 
  
        # making qwidget object 
        content = QWidget(self) 
        self.setWidget(content) 
  
        # vertical box layout 
        lay = QVBoxLayout(content) 
  
        # creating label 
        self.label = QLabel(content) 
        # self.setGeometry(50,200,700,300)
        # setting alignment to the text 
        # self.label.setAlignment(Qt.AlignLeft | Qt.AlignTop) 
  
        # making label multi-line 
        self.label.setWordWrap(True)
  
        # adding label to the layout 
        lay.addWidget(self.label) 
        self.setText("Result Screen")
        self.label.setAlignment(Qt.AlignCenter | Qt.AlignVCenter)
    # the setText method 
    def setText(self, text): 
        # setting text to the label 
        self.label.setText(text) 
        
        #refresh the UI
        self.label.repaint()
        # self.show()
if __name__ == '__main__':
    # currentNumpyImage = cv2.imread("/Users/cheng_sam/zhengh8x/Tool/AutoBurgundy/v17/flow.png")
    app = QApplication(sysargv)
 
    demo = AppDemo()
    demo.show()
    # demo = SamDemo()
    # demo.show()    
    sysexit(app.exec_())



