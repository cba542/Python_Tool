
    end




    DUTInitialization = dag.add(
        "DUTInitialization", --Burgundy Test Name
        "J316DutIOInitialization.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "DUTInitialization", --TestName
            ["portIdentifier"] = "System" --PortIdentifier
        } 
    )

    DUTInitialization = dag.add(
        "DUTInitialization", --Burgundy Test Name
        "J316DutIOInitialization.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "DUTInitialization", --TestName
            ["portIdentifier"] = "System" --PortIdentifier
        } 
    )

	CPort0TitaniumFWCheck = dag.add(
        "CPort0TitaniumFWCheck", --Burgundy Test Name
        "TestBoxVersionTest.lua", --Action file
        {"titaniumCPort0DOWN"}, --plugins
        {
            ["TestName"] = "CPort0TitaniumFWCheck", --TestName
            ["portIdentifier"] = "CPort0DOWN" --PortIdentifier
        } 
    )

    CPort1TitaniumFWCheck = dag.add(
        "CPort1TitaniumFWCheck", --Burgundy Test Name
        "TestBoxVersionTest.lua", --Action file
        {"titaniumCPort1DOWN"}, --plugins
        {
            ["TestName"] = "CPort1TitaniumFWCheck", --TestName
            ["portIdentifier"] = "CPort1DOWN" --PortIdentifier
        } 
    )

    CPort2TitaniumFWCheck = dag.add(
        "CPort2TitaniumFWCheck", --Burgundy Test Name
        "TestBoxVersionTest.lua", --Action file
        {"titaniumCPort2DOWN"}, --plugins
        {
            ["TestName"] = "CPort2TitaniumFWCheck", --TestName
            ["portIdentifier"] = "CPort2DOWN" --PortIdentifier
        } 
    )


    SystemDOWNBatteryDrainTest = dag.add(
        "SystemDOWNBatteryDrainTest", --Burgundy Test Name
        "BatteryDrainTest.lua", --Action file
        {"titaniumCPort0DOWN", "titaniumCPort1DOWN","titaniumCPort2DOWN", "dut"}, --plugins
        {
            ["TestName"] = "SystemDOWNBatteryDrainTest", --TestName
            ["portIdentifier"] = "SystemDOWN" --PortIdentifier
        } 
    )

    CPort0UPPortOrientationCheck = dag.add(
        "CPort0UPPortOrientationCheck", --Burgundy Test Name
        "PortOrientationCheckTest.lua", --Action file
        {"titaniumCPort0UP", "dut"}, --plugins
        {
            ["TestName"] = "CPort0UPPortOrientationCheck", --TestName
            ["portIdentifier"] = "CPort0UP" --PortIdentifier
        } 
    )

    CPort1UPPortOrientationCheck = dag.add(
        "CPort1UPPortOrientationCheck", --Burgundy Test Name
        "PortOrientationCheckTest.lua", --Action file
        {"titaniumCPort1UP", "dut"}, --plugins
        {
            ["TestName"] = "CPort1UPPortOrientationCheck", --TestName
            ["portIdentifier"] = "CPort1UP" --PortIdentifier
        } 
    )

    CPort2UPPortOrientationCheck = dag.add(
        "CPort2UPPortOrientationCheck", --Burgundy Test Name
        "PortOrientationCheckTest.lua", --Action file
        {"titaniumCPort2UP", "dut"}, --plugins
        {
            ["TestName"] = "CPort2UPPortOrientationCheck", --TestName
            ["portIdentifier"] = "CPort2UP" --PortIdentifier
        } 
    )

    CPort0SwitchTestBoxTunnelDP = dag.add(
        "CPort0SwitchTestBoxTunnelDP", --Burgundy Test Name
        "TBTModeSwitchTest.lua", --Action file
        {"titaniumCPort0UP"}, --plugins
        {
            ["TestName"] = "CPort0SwitchTestBoxTunnelDP", --TestName
            ["portIdentifier"] = "CPort0UP" --PortIdentifier
        } 
    )

    CPort1SwitchTestBoxTunnelDP = dag.add(
        "CPort1SwitchTestBoxTunnelDP", --Burgundy Test Name
        "TBTModeSwitchTest.lua", --Action file
        {"titaniumCPort1UP"}, --plugins
        {
            ["TestName"] = "CPort1SwitchTestBoxTunnelDP", --TestName
            ["portIdentifier"] = "CPort1UP" --PortIdentifier
        } 
    )

    CPort2SwitchTestBoxTunnelDP = dag.add(
        "CPort2SwitchTestBoxTunnelDP", --Burgundy Test Name
        "TBTModeSwitchTest.lua", --Action file
        {"titaniumCPort2UP"}, --plugins
        {
            ["TestName"] = "CPort2SwitchTestBoxTunnelDP", --TestName
            ["portIdentifier"] = "CPort2UP" --PortIdentifier
        } 
    )

    CPort0UPUsbphyTurnOffTunnelDP = dag.add(
        "CPort0UPUsbphyTurnOffTunnelDP", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort0UPUsbphyTurnOffTunnelDP", --TestName
            ["portIdentifier"] = "CPort0UP" --PortIdentifier
        } 
    )

    CPort1UPUsbphyTurnOffTunnelDP = dag.add(
        "CPort1UPUsbphyTurnOffTunnelDP", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort1UPUsbphyTurnOffTunnelDP", --TestName
            ["portIdentifier"] = "CPort1UP" --PortIdentifier
        } 
    )

    CPort2UPUsbphyTurnOffTunnelDP = dag.add(
        "CPort2UPUsbphyTurnOffTunnelDP", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort2UPUsbphyTurnOffTunnelDP", --TestName
            ["portIdentifier"] = "CPort2UP" --PortIdentifier
        } 
    )

    CPort0CIO20GPresenceTest = dag.add(
        "CPort0CIO20GPresenceTest", --Burgundy Test Name
        "TaurusCIOPresenceTest.lua", --Action file
        {"titaniumCPort0UP", "dut"}, --plugins
        {
            ["TestName"] = "CPort0CIO20GPresenceTest", --TestName
            ["portIdentifier"] = "CPort0UP" --PortIdentifier
        } 
    )

    CPort1CIO20GPresenceTest = dag.add(
        "CPort1CIO20GPresenceTest", --Burgundy Test Name
        "TaurusCIOPresenceTest.lua", --Action file
        {"titaniumCPort1UP", "dut"}, --plugins
        {
            ["TestName"] = "CPort1CIO20GPresenceTest", --TestName
            ["portIdentifier"] = "CPort1UP" --PortIdentifier
        } 
    )

    CPort2CIO20GPresenceTest = dag.add(
        "CPort2CIO20GPresenceTest", --Burgundy Test Name
        "TaurusCIOPresenceTest.lua", --Action file
        {"titaniumCPort2UP", "dut"}, --plugins
        {
            ["TestName"] = "CPort2CIO20GPresenceTest", --TestName
            ["portIdentifier"] = "CPort2UP" --PortIdentifier
        } 
    )

    CPort0CIO20GTunableCheck = dag.add(
        "CPort0CIO20GTunableCheck", --Burgundy Test Name
        "RegisterCheckTest.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort0CIO20GTunableCheck", --TestName
            ["portIdentifier"] = "CPort0UP" --PortIdentifier
        } 
    )

    CPort1CIO20GTunableCheck = dag.add(
        "CPort1CIO20GTunableCheck", --Burgundy Test Name
        "RegisterCheckTest.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort1CIO20GTunableCheck", --TestName
            ["portIdentifier"] = "CPort1UP" --PortIdentifier
        } 
    )

    CPort2CIO20GTunableCheck = dag.add(
        "CPort2CIO20GTunableCheck", --Burgundy Test Name
        "RegisterCheckTest.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort2CIO20GTunableCheck", --TestName
            ["portIdentifier"] = "CPort2UP" --PortIdentifier
        } 
    )

    SystemUPCIO20GHostEyeTest = dag.add(
        "SystemUPCIO20GHostEyeTest", --Burgundy Test Name
        "TaurusParallelHostEyeTest.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "SystemUPCIO20GHostEyeTest", --TestName
            ["portIdentifier"] = "SystemUP" --PortIdentifier
        } 
    )

    CPort0CIO20GTestBoxEyeCapture = dag.add(
        "CPort0CIO20GTestBoxEyeCapture", --Burgundy Test Name
        "TestBoxEyeCaptureTest.lua", --Action file
        {"titaniumCPort0UP"}, --plugins
        {
            ["TestName"] = "CPort0CIO20GTestBoxEyeCapture", --TestName
            ["portIdentifier"] = "CPort0UP" --PortIdentifier
        } 
    )

    CPort1CIO20GTestBoxEyeCapture = dag.add(
        "CPort1CIO20GTestBoxEyeCapture", --Burgundy Test Name
        "TestBoxEyeCaptureTest.lua", --Action file
        {"titaniumCPort1UP"}, --plugins
        {
            ["TestName"] = "CPort1CIO20GTestBoxEyeCapture", --TestName
            ["portIdentifier"] = "CPort1UP" --PortIdentifier
        } 
    )

    CPort2CIO20GTestBoxEyeCapture = dag.add(
        "CPort2CIO20GTestBoxEyeCapture", --Burgundy Test Name
        "TestBoxEyeCaptureTest.lua", --Action file
        {"titaniumCPort2UP"}, --plugins
        {
            ["TestName"] = "CPort2CIO20GTestBoxEyeCapture", --TestName
            ["portIdentifier"] = "CPort2UP" --PortIdentifier
        } 
    )

    CPort0CIO20GR2DRetimerEyeTest = dag.add(
        "CPort0CIO20GR2DRetimerEyeTest", --Burgundy Test Name
        "TaurusRetimerEyeTest.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort0CIO20GR2DRetimerEyeTest", --TestName
            ["portIdentifier"] = "CPort0UP" --PortIdentifier
        } 
    )

    CPort0CIO20GD2RRetimerEyeTest = dag.add(
        "CPort0CIO20GD2RRetimerEyeTest", --Burgundy Test Name
        "TaurusRetimerEyeTest.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort0CIO20GD2RRetimerEyeTest", --TestName
            ["portIdentifier"] = "CPort0UP" --PortIdentifier
        } 
    )

    CPort1CIO20GR2DRetimerEyeTest = dag.add(
        "CPort1CIO20GR2DRetimerEyeTest", --Burgundy Test Name
        "TaurusRetimerEyeTest.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort1CIO20GR2DRetimerEyeTest", --TestName
            ["portIdentifier"] = "CPort1UP" --PortIdentifier
        } 
    )

    CPort1CIO20GD2RRetimerEyeTest = dag.add(
        "CPort1CIO20GD2RRetimerEyeTest", --Burgundy Test Name
        "TaurusRetimerEyeTest.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort1CIO20GD2RRetimerEyeTest", --TestName
            ["portIdentifier"] = "CPort1UP" --PortIdentifier
        } 
    )





    DUTCleanup = dag.add(
        "DUTCleanup", --Burgundy Test Name
        "J316DutIOCleanup.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "DUTCleanup", --TestName
            ["portIdentifier"] = "System" --PortIdentifier
        } 
    )



    dag.order(DUTInitialization, CPort0TitaniumFWCheck)
    dag.order(DUTInitialization, CPort1TitaniumFWCheck)
    dag.order(DUTInitialization, CPort2TitaniumFWCheck)



    dag.order(CPort0TitaniumFWCheck, SystemDOWNBatteryDrainTest)
    dag.order(CPort1TitaniumFWCheck, SystemDOWNBatteryDrainTest)
    dag.order(CPort2TitaniumFWCheck, SystemDOWNBatteryDrainTest)

    dag.order(SystemDOWNBatteryDrainTest, CPort0UPPortOrientationCheck)

  
    dag.order(CPort0UPPortOrientationCheck, CPort1UPPortOrientationCheck)
    dag.order(CPort1UPPortOrientationCheck, CPort2UPPortOrientationCheck)


 

--tunnel dp
    dag.order(CPort2UPPortOrientationCheck, CPort0SwitchTestBoxTunnelDP)
    dag.order(CPort0SwitchTestBoxTunnelDP, CPort1SwitchTestBoxTunnelDP)
    dag.order(CPort0SwitchTestBoxTunnelDP, CPort2SwitchTestBoxTunnelDP)

    dag.order(CPort1SwitchTestBoxTunnelDP, CPort0UPUsbphyTurnOffTunnelDP)
    dag.order(CPort2SwitchTestBoxTunnelDP, CPort0UPUsbphyTurnOffTunnelDP)

    dag.order(CPort0UPUsbphyTurnOffTunnelDP, CPort1UPUsbphyTurnOffTunnelDP)     
    dag.order(CPort1UPUsbphyTurnOffTunnelDP, CPort2UPUsbphyTurnOffTunnelDP)

--cio20
    dag.order(CPort2UPUsbphyTurnOffTunnelDP, CPort0CIO20GPresenceTest)
    dag.order(CPort0CIO20GPresenceTest, CPort1CIO20GPresenceTest)
    dag.order(CPort1CIO20GPresenceTest, CPort2CIO20GPresenceTest)

    dag.order(CPort2CIO20GPresenceTest, CPort0CIO20GTunableCheck)
    dag.order(CPort0CIO20GTunableCheck, CPort1CIO20GTunableCheck)
    dag.order(CPort1CIO20GTunableCheck, CPort2CIO20GTunableCheck)

    dag.order(CPort2CIO20GTunableCheck, SystemUPCIO20GHostEyeTest)

    dag.order(SystemUPCIO20GHostEyeTest, CPort0CIO20GTestBoxEyeCapture)
    dag.order(SystemUPCIO20GHostEyeTest, CPort1CIO20GTestBoxEyeCapture)
    dag.order(SystemUPCIO20GHostEyeTest, CPort2CIO20GTestBoxEyeCapture)

    dag.order(CPort0CIO20GTestBoxEyeCapture, CPort0CIO20GR2DRetimerEyeTest)
    dag.order(CPort1CIO20GTestBoxEyeCapture, CPort0CIO20GR2DRetimerEyeTest)
    dag.order(CPort2CIO20GTestBoxEyeCapture, CPort0CIO20GR2DRetimerEyeTest)

    dag.order(CPort0CIO20GR2DRetimerEyeTest, CPort0CIO20GD2RRetimerEyeTest)
    dag.order(CPort0CIO20GD2RRetimerEyeTest, CPort1CIO20GR2DRetimerEyeTest)
    dag.order(CPort1CIO20GR2DRetimerEyeTest, CPort1CIO20GD2RRetimerEyeTest)


 
    dag.order(CPort1CIO20GD2RRetimerEyeTest, DUTCleanup)
    
    
end