local AlitaStationSequence = {}

function AlitaStationSequence.buildDag(dag)



-- FW Check

--    DUTInitialization = dag.add(
--        "DUTInitialization", --Burgundy Test Name
--        "J316DutIOInitialization.lua", --Action file
--        {"dut"}, --plugins
--        {
--            ["TestName"] = "DUTInitialization", --TestName
--            ["portIdentifier"] = "System" --PortIdentifier
--        } 
--    )

--	CPort0TitaniumFWCheck = dag.add(
--        "CPort0TitaniumFWCheck", --Burgundy Test Name
--        "TestBoxVersionTest.lua", --Action file
--        {"titaniumCPort0DOWN"}, --plugins
--        {
--            ["TestName"] = "CPort0TitaniumFWCheck", --TestName
--            ["portIdentifier"] = "CPort0DOWN" --PortIdentifier
--        } 
--    )

--    CPort1TitaniumFWCheck = dag.add(
--        "CPort1TitaniumFWCheck", --Burgundy Test Name
--        "TestBoxVersionTest.lua", --Action file
--        {"titaniumCPort1DOWN"}, --plugins
--        {
--            ["TestName"] = "CPort1TitaniumFWCheck", --TestName
--            ["portIdentifier"] = "CPort1DOWN" --PortIdentifier
--        } 
--    )

--    CPort2TitaniumFWCheck = dag.add(
--        "CPort2TitaniumFWCheck", --Burgundy Test Name
--        "TestBoxVersionTest.lua", --Action file
--        {"titaniumCPort2DOWN"}, --plugins
--        {
--            ["TestName"] = "CPort2TitaniumFWCheck", --TestName
--            ["portIdentifier"] = "CPort2DOWN" --PortIdentifier
--        } 
--    )

--    CPort0CaesiumFWCheck = dag.add(
--        "CPort0CaesiumFWCheck", --Burgundy Test Name
--        "TestBoxVersionTest.lua", --Action file
--        {"caesiumCPort0DOWN"}, --plugins
--        {
--            ["TestName"] = "CPort0CaesiumFWCheck", --TestName
--            ["portIdentifier"] = "CPort0DOWN" --PortIdentifier
--        } 
--    )

--    CPort1CaesiumFWCheck = dag.add(
--        "CPort1CaesiumFWCheck", --Burgundy Test Name
--        "TestBoxVersionTest.lua", --Action file
--        {"caesiumCPort1DOWN"}, --plugins
--        {
--            ["TestName"] = "CPort1CaesiumFWCheck", --TestName
--            ["portIdentifier"] = "CPort1DOWN" --PortIdentifier
--        } 
--    )

--    CPort2CaesiumFWCheck = dag.add(
--        "CPort2CaesiumFWCheck", --Burgundy Test Name
--        "TestBoxVersionTest.lua", --Action file
--        {"caesiumCPort2DOWN"}, --plugins
--        {
--            ["TestName"] = "CPort2CaesiumFWCheck", --TestName
--            ["portIdentifier"] = "CPort2DOWN" --PortIdentifier
--        } 
--    )

--    CPort0DOWNPortOrientationCheck = dag.add(
--        "CPort0DOWNPortOrientationCheck", --Burgundy Test Name
--        "PortOrientationCheckTest.lua", --Action file
--        {"titaniumCPort0DOWN", "dut"}, --plugins
--        {
--            ["TestName"] = "CPort0DOWNPortOrientationCheck", --TestName
--            ["portIdentifier"] = "CPort0DOWN" --PortIdentifier
--        } 
--    )

--    CPort1DOWNPortOrientationCheck = dag.add(
--        "CPort1DOWNPortOrientationCheck", --Burgundy Test Name
--        "PortOrientationCheckTest.lua", --Action file
--        {"titaniumCPort1DOWN", "dut"}, --plugins
--        {
--            ["TestName"] = "CPort1DOWNPortOrientationCheck", --TestName
--            ["portIdentifier"] = "CPort1DOWN" --PortIdentifier
--        } 
--    )

--    CPort2DOWNPortOrientationCheck = dag.add(
--        "CPort2DOWNPortOrientationCheck", --Burgundy Test Name
--        "PortOrientationCheckTest.lua", --Action file
--        {"titaniumCPort2DOWN", "dut"}, --plugins
--        {
--            ["TestName"] = "CPort2DOWNPortOrientationCheck", --TestName
--            ["portIdentifier"] = "CPort2DOWN" --PortIdentifier
--        } 
--    )

--    CPort0CIO10GPresenceTest = dag.add(
--        "CPort0CIO10GPresenceTest", --Burgundy Test Name
--        "TaurusCIOPresenceTest.lua", --Action file
--        {"titaniumCPort0UP", "dut"}, --plugins
--        {
--            ["TestName"] = "CPort0CIO10GPresenceTest", --TestName
--            ["portIdentifier"] = "CPort0UP" --PortIdentifier
--        } 
--    )

--    CPort0CIO10GTestBoxEyeCapture = dag.add(
--        "CPort0CIO10GTestBoxEyeCapture", --Burgundy Test Name
--        "TestBoxEyeCaptureTest.lua", --Action file
--        {"titaniumCPort0UP"}, --plugins
--        {
--            ["TestName"] = "CPort0CIO10GTestBoxEyeCapture", --TestName
--            ["portIdentifier"] = "CPort0UP" --PortIdentifier
--        } 
--    )

--    CPort0CIO10GR2DRetimerEyeTest = dag.add(
--        "CPort0CIO10GR2DRetimerEyeTest", --Burgundy Test Name
--        "TaurusRetimerEyeTest.lua", --Action file
--        {"dut"}, --plugins
--        {
--            ["TestName"] = "CPort0CIO10GR2DRetimerEyeTest", --TestName
--            ["portIdentifier"] = "CPort0UP" --PortIdentifier
--        } 
--    )

--    CPort0CIO10GD2RRetimerEyeTest = dag.add(
--        "CPort0CIO10GD2RRetimerEyeTest", --Burgundy Test Name
--        "TaurusRetimerEyeTest.lua", --Action file
--        {"dut"}, --plugins
--        {
--            ["TestName"] = "CPort0CIO10GD2RRetimerEyeTest", --TestName
--            ["portIdentifier"] = "CPort0UP" --PortIdentifier
--        } 
--    )

--    CPort0CIO10GHostEyeTest = dag.add(
--        "CPort0CIO10GHostEyeTest", --Burgundy Test Name
--        "TaurusHostEyeTest.lua", --Action file
--        {"dut"}, --plugins
--        {
--            ["TestName"] = "CPort0CIO10GHostEyeTest", --TestName
--            ["portIdentifier"] = "CPort0UP" --PortIdentifier
--        } 
--    )

--    CPort1CIO10GPresenceTest = dag.add(
--        "CPort1CIO10GPresenceTest", --Burgundy Test Name
--        "TaurusCIOPresenceTest.lua", --Action file
--        {"titaniumCPort1UP", "dut"}, --plugins
--        {
--            ["TestName"] = "CPort1CIO10GPresenceTest", --TestName
--            ["portIdentifier"] = "CPort1UP" --PortIdentifier
--        } 
--    )

--    CPort1CIO10GTestBoxEyeCapture = dag.add(
--        "CPort1CIO10GTestBoxEyeCapture", --Burgundy Test Name
--        "TestBoxEyeCaptureTest.lua", --Action file
--        {"titaniumCPort1UP"}, --plugins
--        {
--            ["TestName"] = "CPort1CIO10GTestBoxEyeCapture", --TestName
--            ["portIdentifier"] = "CPort1UP" --PortIdentifier
--        } 
--    )

--    CPort1CIO10GR2DRetimerEyeTest = dag.add(
--        "CPort1CIO10GR2DRetimerEyeTest", --Burgundy Test Name
--        "TaurusRetimerEyeTest.lua", --Action file
--        {"dut"}, --plugins
--        {
--            ["TestName"] = "CPort1CIO10GR2DRetimerEyeTest", --TestName
--            ["portIdentifier"] = "CPort1UP" --PortIdentifier
--        } 
--    )

    CPort1CIO10GD2RRetimerEyeTest = dag.add(
        "CPort1CIO10GD2RRetimerEyeTest", --Burgundy Test Name
        "TaurusRetimerEyeTest.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort1CIO10GD2RRetimerEyeTest", --TestName
            ["portIdentifier"] = "CPort1UP" --PortIdentifier
        } 
    )

    CPort1CIO10GHostEyeTest = dag.add(
        "CPort1CIO10GHostEyeTest", --Burgundy Test Name
        "TaurusHostEyeTest.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort1CIO10GHostEyeTest", --TestName
            ["portIdentifier"] = "CPort1UP" --PortIdentifier
        } 
    )

    CPort2CIO10GPresenceTest = dag.add(
        "CPort2CIO10GPresenceTest", --Burgundy Test Name
        "TaurusCIOPresenceTest.lua", --Action file
        {"titaniumCPort2UP", "dut"}, --plugins
        {
            ["TestName"] = "CPort2CIO10GPresenceTest", --TestName
            ["portIdentifier"] = "CPort2UP" --PortIdentifier
        } 
    )

--    CPort0CIO10GTunableCheck_314 = dag.add(
--        "CPort0CIO10GTunableCheck_314", --Burgundy Test Name
--        "RegisterCheckTest.lua", --Action file
--        {"dut"}, --plugins
--        {
--            ["TestName"] = "CPort0CIO10GTunableCheck_314", --TestName
--            ["portIdentifier"] = "CPort0UP" --PortIdentifier
--        } 
--    )

--    CPort1CIO10GTunableCheck_314 = dag.add(
--        "CPort1CIO10GTunableCheck_314", --Burgundy Test Name
--        "RegisterCheckTest.lua", --Action file
--        {"dut"}, --plugins
--        {
--            ["TestName"] = "CPort1CIO10GTunableCheck_314", --TestName
--            ["portIdentifier"] = "CPort1UP" --PortIdentifier
--        } 
--    )




    CPort0CIO10GTunableCheck_314 = dag.add(
        "CPort0CIO10GTunableCheck_314", --Burgundy Test Name
        "RegisterCheckTest.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort0CIO10GTunableCheck_314", --TestName
            ["portIdentifier"] = "CPort0UP" --PortIdentifier
        } 
    )

    CPort1CIO10GTunableCheck_314 = dag.add(
        "CPort1CIO10GTunableCheck_314", --Burgundy Test Name
        "RegisterCheckTest.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort1CIO10GTunableCheck_314", --TestName
            ["portIdentifier"] = "CPort1UP" --PortIdentifier
        } 
    )
--[[
    dag.order(DUTInitialization, CPort0TitaniumFWCheck)
    dag.order(DUTInitialization, CPort1TitaniumFWCheck)
    dag.order(DUTInitialization, CPort2TitaniumFWCheck)
    dag.order(DUTInitialization, CPort0CaesiumFWCheck)
    dag.order(DUTInitialization, CPort1CaesiumFWCheck)
    dag.order(DUTInitialization, CPort2CaesiumFWCheck)


--Down Orientation Check
    dag.order(CPort0TitaniumFWCheck, CPort0DOWNPortOrientationCheck)
    dag.order(CPort1TitaniumFWCheck, CPort0DOWNPortOrientationCheck)
    dag.order(CPort2TitaniumFWCheck, CPort0DOWNPortOrientationCheck)
    dag.order(CPort0CaesiumFWCheck, CPort0DOWNPortOrientationCheck)
    dag.order(CPort1CaesiumFWCheck, CPort0DOWNPortOrientationCheck)
    dag.order(CPort2CaesiumFWCheck, CPort0DOWNPortOrientationCheck)

    dag.order(CPort0DOWNPortOrientationCheck, CPort1DOWNPortOrientationCheck)
    dag.order(CPort1DOWNPortOrientationCheck, CPort2DOWNPortOrientationCheck)
    
    dag.order(CPort2DOWNPortOrientationCheck, CPort0CIO10GPresenceTest)
--debug Start
    --TBT 10G Presence, Retimer, HostEye, Disable
    dag.order(CPort0CIO10GPresenceTest, CPort0CIO10GTestBoxEyeCapture)
    dag.order(CPort0CIO10GTestBoxEyeCapture, CPort0CIO10GR2DRetimerEyeTest)
    dag.order(CPort0CIO10GR2DRetimerEyeTest, CPort0CIO10GD2RRetimerEyeTest)
    dag.order(CPort0CIO10GD2RRetimerEyeTest, CPort0CIO10GHostEyeTest)
    dag.order(CPort0CIO10GHostEyeTest, CPort1CIO10GPresenceTest)


    dag.order(CPort1CIO10GPresenceTest, CPort1CIO10GTestBoxEyeCapture)
    

    dag.order(CPort1CIO10GTestBoxEyeCapture, CPort1CIO10GR2DRetimerEyeTest)
    dag.order(CPort1CIO10GR2DRetimerEyeTest, CPort1CIO10GD2RRetimerEyeTest)
--]]    


    dag.order(CPort1CIO10GD2RRetimerEyeTest, CPort1CIO10GHostEyeTest)
    dag.order(CPort1CIO10GHostEyeTest, CPort2CIO10GPresenceTest)
--debug there is "--" in the end of line
    dag.order(CPort2CIO10GPresenceTest, CPort0CIO10GTunableCheck_314)-- added CIO10G Tunable check
    dag.order(CPort0CIO10GTunableCheck_314, CPort1CIO10GTunableCheck_314)
--    dag.order(CPort2CIO10GPresenceTest, CPort0CIO10GTunableCheck_314)   -- added CIO10G Tunable check
--    dag.order(CPort0CIO10GTunableCheck_314, CPort1CIO10GTunableCheck_314)




    
	return dag
end
return AlitaStationSequence
