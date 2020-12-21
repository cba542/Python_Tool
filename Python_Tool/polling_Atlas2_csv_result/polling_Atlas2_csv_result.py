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
#Fine tune the result.txt format
result_format = "%-35s %-60s %-12s %-20s %-12s %-7s %-s"

#define the condition want to polling
#testName	              subTestName  subSubTestName  upperLimit	measurementValue  lowerLimit	status  failureMessage
#CPort2CIO20GHostEyeTest  CPort2UP	   P2L1_ew	       50	        24.24242424	      15	        PASS    ...
def checkCSV(row):
    testName = row[2]
    subTestName = row[3]
    keyName = row[4]
    upperLimit = row[6]
    measurementValue = row[7]
    lowerLimit = row[8]
    status = row[12]
    failureMessage = row[13]
    # if "OverallTestResult" in subTestName:
    # if "PresenceDUTCheck"  and "SS" in testName and "Data" not in testName and "Throughput" not in testName:
        # if status == "FAIL" : 
            # return True
    # if "CPort1UPUSBCAdapterVoltageTest5V" in testName :
        # if "DxVD" in keyName or "VD0R" in keyName:
            # return True
    # if "DxVD" in keyName  and "CPort1UPUSBCAdapterVoltageTest5V" in testName or "VD0R" in keyName:
    # if status == "PASS" :  
    if status == "FAIL" :      
        # if "Reset" not in testName:
            # return True
    # if status == "FAIL" or status == "PASS":
    # if  Status == "FAIL" or "_ew" in subSubTestName and upLimit == "50" or "Through" in row[2]:
    # if subSubTestName == "OverallTestResult" and Status == "FAIL":
    # if "VoltageTest" in testName:
    # if "DyMa" in testName and status == "FAIL": 
    # if "Host" in testName:
    # if "ID0R failed to reached target current" in failureMessage:
        return True
    else:
        return False

def checkCSVPassFail(row):

    status = row[12]
 
    if status == "FAIL" :      
        return True
    else:
        return False

Root_path = "/Users/cheng_sam/zhengh8x/Code/Python_Tool/Python_Tool/polling_Atlas2_csv_result/"
Fail_Count = 0
DUT_Count = 0
DUT_Criterion_Match_Count = 0


myfile =  open("result.txt", "w")


myfile.write( (result_format +"\n") % (("testName","subTestName","upperLimit","measurementValue","lowerLimit","status","failureMessage")))

for r, d, f in os.walk(Root_path):
    for file in f:

        if 'records.csv' in file:
            DUT_Status = 1
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
                    
                #To calculate the Fail Rate
                if DUT_Status == 1:
                    if checkCSVPassFail(row):
                        DUT_Status = 0
                    
                #condition in the csv want to check     
                # if row[12] == "FAIL" or "_ew" in row[4] and row[6] == "50" or "Through" in row[2]:
                #condition in the csv want to check                       
                if checkCSV(row):

                    
                    #用於顯示結果fine tune
                    result_str = (result_format % ((row[2],row[4],row[6],row[7],row[8],row[12],row[13])))
                    myfile.write(result_str + "\n")
                    display = display + result_str

            if len(display) > 0:
                DUT_Criterion_Match_Count += 1
                print(SN, "Match criterion")
                _FilePath = FilePath.replace("/Users/cheng_sam/zhengh8x/Code/Python_Tool/Python_Tool/polling_Atlas2_csv_result/","")
                myfile.write("(" +  str(Fail_Count+1) + ")" + _FilePath + "\n")
                myfile.write(("============================================================================================================================================================"+ "\n"))
            else:
                print(SN, "Not Match criterion")

            #To calculate the Fail Rate
            if DUT_Status == 0:
                Fail_Count += 1
            DUT_Count += 1

            
            csvFile.close()

            
if DUT_Count is not 0:
    print("%d Fail/%d Total, Match Rate = %f %%" % (Fail_Count, DUT_Criterion_Match_Count, (Fail_Count/DUT_Criterion_Match_Count) *100))
    print("%d Fail/%d Total, Fail  Rate = %f %%" % (Fail_Count, DUT_Count, (Fail_Count/DUT_Count) *100))
    myfile.write("\n%d Fail/%d Total, Match Rate = %f %%" % (Fail_Count, DUT_Criterion_Match_Count, (Fail_Count/DUT_Criterion_Match_Count) *100))
    myfile.write("\n%d Fail/%d Total, Fail  Rate = %f %%" % (Fail_Count, DUT_Count, (Fail_Count/DUT_Count) *100))
    os.popen("open /Users/cheng_sam/zhengh8x/Code/Python_Tool/Python_Tool/polling_Atlas2_csv_result/result.txt")
else:
    print("No input csv")
# csvFile.close()
myfile.close()
    

