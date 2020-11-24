#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Aug  7 11:21:08 2020

@author: cheng_sam
"""
"Auto_Buildv1.py :Basic function"
"Auto_Buildv2.py :hardcode for overlay version from *.plist"
"Auto_Buildv3.py :add ssh cmd to sned or receive files"
"Auto_Toolv4.py  :1)Rename the file name 2)Code enhance"
import os
import sys
import glob
import getpass


func_list = ["Build Code",
             "terminal scp file"
             ]

# prj_lsit = ["j31x",
# 			"j314",
# 			"j316"
#             ]

prj_lsit = ["J31x"
            ]

filepath_lsit = ["/Users/cheng_sam/zhengh8x/Code/AlitaJr_31x/",
				 "/Users/cheng_sam/zhengh8x/Code/AlitaJr_314/",
				 "/Users/cheng_sam/zhengh8x/Code/AlitaJr_316/"
                 ]

CMD_list = ["./build_overlay.sh -n IO1",
            "./build_overlay.sh -n IO2",
            "./build_overlay.sh -n IO3",
            "./build_overlay.sh -n DyOs",
            "./build_overlay.sh -n IrOs"
            ]

# =============================================================================
# ssh_CMD =["cp /Users/cheng_sam/.ssh/known_hosts_copy /Users/cheng_sam/.ssh/known_hosts",
#           "scp -o StrictHostKeyChecking=no -r /Users/cheng_sam/.ssh/send gdlocal@10.0.100.1:~/Desktop/From_Sam",
#           "scp -o StrictHostKeyChecking=no -r gdlocal@10.0.100.1:~/Desktop/log /Users/cheng_sam/.ssh/receive"
#           ]
# =============================================================================



ssh_CMD = ["cp /Users/%s/.ssh/Org_known_hosts /Users/%s/.ssh/known_hosts" % (getpass.getuser(), getpass.getuser())]
ssh_CMD.append("scp -o StrictHostKeyChecking=no -r /Users/%s/.ssh/send gdlocal@10.0.100.1:~/Desktop/From_host" % getpass.getuser())
ssh_CMD.append("scp -o StrictHostKeyChecking=no -r gdlocal@10.0.100.1:~/Desktop/log /Users/%s/.ssh/receive" % getpass.getuser())

Station_plist_lines_hardcode = 40

def build():
    build_message = ""
    station_message = ""
    for i, p in enumerate(prj_lsit):
        print("(%s) %s" %(i+1,p)) 
    
    prj = input("")
    prj = (int(prj) - 1)
    
    
    for i, p in enumerate(prj_lsit):
        if prj == i:
            build_message += "Build "
            build_message += p
    
    for i, p in enumerate(CMD_list):
        p = p.replace("./build_overlay.sh -n ","")
        print("(%s) %s" %(i+1,p))
    
    station = input("")
    station = (int(station) -1)
    for i, p in enumerate(CMD_list):
        p = p.replace("./build_overlay.sh -n ","")
        if station == i:
            build_message += p
            station_message = p
    print(build_message)
    
    
    if prj >= len(filepath_lsit):
        print("\033[31mIncorrect Project parameter\033[0m")
        sys.exit()
    filepath = filepath_lsit[prj]
    
    os.chdir(filepath)
    
    if station >= len(CMD_list):
        print("\033[31mIncorrect Station parameter\033[0m")
        sys.exit()
    build_command = CMD_list[station]
    print(filepath+build_command)
    
    #-----    
    for root, dirs, files in os.walk(os.path.abspath(filepath)):
        for file in files:
            if "plist" in file and "Burgundy" in file and station_message in root:
                # print(os.path.join(root, file))
                with open(os.path.join(root, file), "r") as myfile:
                    for index, data in enumerate(myfile):
                        # print(index,data)
                        if index == 7:
                            data = data.replace("<string>","")
                            data = data.replace("</string>","")
                            print("version in %s:%s" % (os.path.basename(myfile.name),data))
            if "plist" in file and "station" in file and station_message in root:
                # print(os.path.join(root, file))
                with open(os.path.join(root, file), "r") as myfile:
                    for index, data in enumerate(myfile):
                        # print(index,data)
                        if index == (Station_plist_lines_hardcode - 1):
                            data = data.replace("<string>","")
                            data = data.replace("</string>","")
                            print("version in %s:%s" % (os.path.basename(myfile.name),data))
    #-----
    os.system(build_command)

def terminal_scp():
    #rollback known_host
    print(ssh_CMD[0])
    os.system(ssh_CMD[0])
    
    print("(1) send (2)receive")
    ssh = input("")

    
    if int(ssh) == 1:
        print(ssh_CMD[1])
        os.system(ssh_CMD[1])
    elif int(ssh) == 2:
        print(ssh_CMD[2])
        os.system(ssh_CMD[2])
        

def main(argv):
    for i, p in enumerate(func_list):
        print("(%s) %s" %(i+1,p)) 
        
    func = input("")
    func = (int(func) - 1)
        
    if func == 0:
        build()
    elif func == 1:
        terminal_scp()


if __name__ == "__main__":
    main(sys.argv[1:])
