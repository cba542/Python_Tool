#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Oct 29 11:38:40 2020

@author: cheng_sam
"""
import re
import datetime
from pathlib import Path
import os
import csv

#define the condition want to polling
def checkCSV(row):
    Status = row[12] 
    testName = row[2] 
    upLimit = row[6]
    lowLimit = row[7]
    measueValue = row[8]
    subSubTestName = row[4]
    subTestName = row[5]
    #condition in the csv want to check     
    # if row[12] == "FAIL" or "_ew" in row[4] and row[6] == "50" or "Through" in row[2]:
    #condition in the csv want to check
    
    # if Status == "FAIL":
    # if  Status == "FAIL" or "_ew" in subSubTestName and upLimit == "50" or "Through" in row[2]:
    # if subSubTestName == "OverallTestResult" and Status == "FAIL":
    # if "VoltageTest" in testName:
    if "DyMa" in testName and Status == "FAIL": 
        return True
    else:
        return False



_Path = "records.csv"
Root_path = "/Users/cheng_sam/zhengh8x/Code/Python_Tool/Python_Tool/polling_Atlas2_csv_result/"
FAIL_count = 0
DUT_count = 0
myfile =  open("result.txt", "w")
myfile.write("testName                          subTestName                    upperLimit           measurementValue     lowerLimit           status\n")
for r, d, f in os.walk(Root_path):
    for file in f:

        if 'records.csv' in file:

            FilePath = (os.path.join(r, file))
            #放在ignore資料夾底下的檔案不處理, 方便debug
            if "ignore" in FilePath:
                continue

            with open(FilePath, newline='') as csvFile:
                # print(FilePath)
                # 1.直接讀取：讀取 CSV 檔案內容
                rows = csv.reader(csvFile)
                rows = list(rows)
            display = ""
            for index, row in enumerate(rows):
                if index == 1:
                    SN = row[1]
                    
                #ingore STOP_DEVICE FAIL
                if row[2] == "STOP_DEVICE":
                        continue
                #condition in the csv want to check     
                # if row[12] == "FAIL" or "_ew" in row[4] and row[6] == "50" or "Through" in row[2]:
                #condition in the csv want to check                       
                if checkCSV(row):

                    
                    #用於顯示結果fine tune
                    result_str = ("%-33s %-30s %-20s %-20s %-20s %-9s" % ((row[2],row[4],row[6],row[7],row[8],row[12])))
                    myfile.write(result_str + "\n")
                    display = display + result_str

            if len(display) > 0:
                FAIL_count += 1
                _FilePath = FilePath.replace("/Users/cheng_sam/zhengh8x/Code/Python_Tool/Python_Tool/polling_Atlas2_csv_result/","")
                myfile.write(_FilePath + "\n")
                myfile.write(("============================================================================================================================================================"+ "\n"))
            else:
                print(SN, "PASS")
            DUT_count += 1

print("%d Fail/%d Total, RR = %f %%" % (FAIL_count, DUT_count, (FAIL_count/DUT_count) *100))
os.popen("open /Users/cheng_sam/zhengh8x/Code/Python_Tool/Python_Tool/polling_Atlas2_csv_result/result.txt")

csvFile.close()
myfile.close()
    

