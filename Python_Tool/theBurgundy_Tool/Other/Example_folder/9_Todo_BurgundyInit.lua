burgundy = require "Burgundy"

burgundy.registerStationFunctions(require "Fixture")
burgundy.registerUnitFunctions(require "Unit")

burgundy.registerInitTable("Burgundy/AlitaInitReporter")
burgundy.registerFiniTable("Burgundy/AlitaFiniReporter")

burgundy.registerCoverageRouter("Burgundy/AlitaInitReporter", function (...)
    return burgundy.createCoverage("coverage.plist")
end)

burgundy.setExitFunction(function() return false end)

local io = require "io"
local alitaUility = require  "AlitaTestCore/AlitaUility"
local alitaStationConfig = require "AlitaTestCore/AlitaConfig/AlitaStationConfig"

local function getCableCount(testBoxPlugin)
    local isSource = false
    local cableCount = 0xDEADBEEF
    print("Atlas-debug Measure Vconn on test box before Load")
    local stat, retval = pcall(testBoxPlugin.measureVConnPower, "getCableCount", 2)
    if not stat then
        print("Atlas-debug Fail to measure Vconn before getCableCount, error" .. retval .. "; ")
        return cableCount
    end
    print("Atlas-debug retval.isSource :" .. tostring(retval.isSource))
    isSource = retval.isSource
    if isSource then
        print("Atlas-debug vconnSwapOnPort")
        local stat, retval = pcall(testBoxPlugin.vconnSwap, "getCableCount", 2)
        if not stat then
            print("Atlas-debug Fail to vconn Swap before getCableCount, error" .. retval .. "; ")
            return cableCount
        end
    end
    local stat, retval = pcall(testBoxPlugin.neutronIncrementCycleCount, "getCableCount", 2)
    if not stat then
        print("Atlas-debug Fail to neutronIncrementCycleCount, error" .. retval .. "; ")
        return cableCount
    end
    local stat, retval = pcall(testBoxPlugin.neutronCycleCount, "getCableCount", 2)
    if not stat then
        print("Atlas-debug Fail to neutronCycleCount, error" .. retval .. "; ")
        return cableCount
    end
    cableCount = retval.cableCount
    if isSource then
        print("Atlas-debug vconnSwapOnPort")
        local stat, retval = pcall(testBoxPlugin.vconnSwap, "getCableCount", 2)
        if not stat then
            print("Atlas-debug Fail to vconn Swap before getCableCount, error" .. retval .. "; ")
            return cableCount
        end
    end
    print("Atlas-debug CableCount after incremental: " .. cableCount .. "; ")
    return cableCount
end

scarlet.unit_tests_dag = function (dag, device, plugins)
    if alitaStationConfig.enableStopOnFail then
        dag.enableExitOnFailureRecord()
        dag.enableExitOnAmIOkay()
    end

    print("Atlas-debug unit_tests_dag device: " .. alitaUility.Table.StringifyTable(device))
    print("Atlas-debug unit_tests_dag plugins: " .. alitaUility.Table.StringifyTable(plugins))
    local groupID = Group.getDeviceSystemIndex(device)
    print("Atlas-debug group ID: " .. groupID)

    local cableCountWarning = false
    local cableCountDanger = false

    local interactiveUI = plugins[ "InterActiveUI" ]
    for i, testbox in ipairs(alitaStationConfig.fixturesToCheckCableCount) do
        print("Atlas-debug fixturesToCheckCableCount add box " .. testbox)
        local cableCount = getCableCount(plugins[testbox])
        interactiveUI.logInfoToGroup(groupID, "CableCt[" .. testbox .. "]: " ..  cableCount)
        --<rdar://problem/64241817> PGY FATP USBC Station Neutron Cable&Spartan Box&Spartan Cable Lifecycle/Firmware tracking
        if alitaStationConfig.checkCableCount then
            if cableCount >= (alitaStationConfig.cableCountLimit - 100) and cableCount < (alitaStationConfig.cableCountLimit - 10) then
                cableCountWarning = true
            elseif cableCount >= (alitaStationConfig.cableCountLimit - 10) then
                cableCountDanger = true
            end
            
            if cableCountWarning then
                interactiveUI.setLogWindowBackgroundColor("orange", groupID)
            elseif cableCountDanger then
                interactiveUI.setLogWindowBackgroundColor("red", groupID)
            else
                interactiveUI.setLogWindowBackgroundColor("green", groupID)
            end

            if cableCount > alitaStationConfig.cableCountLimit then
                os.execute("osascript -e 'tell app \"System Events\" to display dialog \"Cable Count[" .. testbox .. "] : " .. cableCount .. " exceed limit " .. alitaStationConfig.cableCountLimit .. ", please change cable\n请更换Neutron后重新启动Atlas.\"'")
                error("CableCount limit exceeded.")
            end
        end
    end

    DutStart = dag.add(
        "DutStart", --Burgundy Test Name
        "DutStart.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "DutStart", --TestName
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

    CPort0CaesiumFWCheck = dag.add(
        "CPort0CaesiumFWCheck", --Burgundy Test Name
        "TestBoxVersionTest.lua", --Action file
        {"caesiumCPort0DOWN"}, --plugins
        {
            ["TestName"] = "CPort0CaesiumFWCheck", --TestName
            ["portIdentifier"] = "CPort0DOWN" --PortIdentifier
        } 
    )

    CPort1CaesiumFWCheck = dag.add(
        "CPort1CaesiumFWCheck", --Burgundy Test Name
        "TestBoxVersionTest.lua", --Action file
        {"caesiumCPort1DOWN"}, --plugins
        {
            ["TestName"] = "CPort1CaesiumFWCheck", --TestName
            ["portIdentifier"] = "CPort1DOWN" --PortIdentifier
        } 
    )

    CPort0CableSerialNumber = dag.add(
        "CPort0CableSerialNumber", --Burgundy Test Name
        "CableSerialNumber.lua", --Action file
        {"titaniumCPort0DOWN"}, --plugins
        {
            ["TestName"] = "CPort0CableSerialNumber", --TestName
            ["portIdentifier"] = "CPort0DOWN" --PortIdentifier
        } 
    )

    CPort1CableSerialNumber = dag.add(
        "CPort1CableSerialNumber", --Burgundy Test Name
        "CableSerialNumber.lua", --Action file
        {"titaniumCPort1DOWN"}, --plugins
        {
            ["TestName"] = "CPort1CableSerialNumber", --TestName
            ["portIdentifier"] = "CPort1DOWN" --PortIdentifier
        } 
    )
        
    SystemDOWNBatteryDrainTest = dag.add(
        "SystemDOWNBatteryDrainTest", --Burgundy Test Name
        "BatteryDrainTest.lua", --Action file
        {"titaniumCPort0DOWN", "titaniumCPort1DOWN", "dut"}, --plugins
        {
            ["TestName"] = "SystemDOWNBatteryDrainTest", --TestName
            ["portIdentifier"] = "SystemDOWN" --PortIdentifier
        } 
    )

    CPort0DOWNPortOrientationCheck = dag.add(
        "CPort0DOWNPortOrientationCheck", --Burgundy Test Name
        "PortOrientationCheckTest.lua", --Action file
        {"titaniumCPort0DOWN", "dut"}, --plugins
        {
            ["TestName"] = "CPort0DOWNPortOrientationCheck", --TestName
            ["portIdentifier"] = "CPort0DOWN" --PortIdentifier
        } 
    )

    CPort1DOWNPortOrientationCheck = dag.add(
        "CPort1DOWNPortOrientationCheck", --Burgundy Test Name
        "PortOrientationCheckTest.lua", --Action file
        {"titaniumCPort1DOWN", "dut"}, --plugins
        {
            ["TestName"] = "CPort1DOWNPortOrientationCheck", --TestName
            ["portIdentifier"] = "CPort1DOWN" --PortIdentifier
        } 
    )

    CPort0DOWNUSBCTestboxUsb2HubEnable = dag.add(
        "CPort0DOWNUSBCTestboxUsb2HubEnable", --Burgundy Test Name
        "AriesUSBCUsb2HubPathSelectTest.lua", --Action file
        {"titaniumCPort0DOWN"}, --plugins
        {
            ["TestName"] = "CPort0DOWNUSBCTestboxUsb2HubEnable", --TestName
            ["portIdentifier"] = "CPort0DOWN" --PortIdentifier
        } 
    )

    CPort1DOWNUSBCTestboxUsb2HubEnable = dag.add(
        "CPort1DOWNUSBCTestboxUsb2HubEnable", --Burgundy Test Name
        "AriesUSBCUsb2HubPathSelectTest.lua", --Action file
        {"titaniumCPort1DOWN"}, --plugins
        {
            ["TestName"] = "CPort1DOWNUSBCTestboxUsb2HubEnable", --TestName
            ["portIdentifier"] = "CPort1DOWN" --PortIdentifier
        } 
    )

    CPort0DOWNUSBCLSTestBoxModeSwitch = dag.add(
        "CPort0DOWNUSBCLSTestBoxModeSwitch", --Burgundy Test Name
        "AriesUSBCUsbSwitchTest.lua", --Action file
        {"titaniumCPort0DOWN"}, --plugins
        {
            ["TestName"] = "CPort0DOWNUSBCLSTestBoxModeSwitch", --TestName
            ["portIdentifier"] = "CPort0DOWN" --PortIdentifier
        } 
    )

    CPort1DOWNUSBCLSTestBoxModeSwitch = dag.add(
        "CPort1DOWNUSBCLSTestBoxModeSwitch", --Burgundy Test Name
        "AriesUSBCUsbSwitchTest.lua", --Action file
        {"titaniumCPort1DOWN"}, --plugins
        {
            ["TestName"] = "CPort1DOWNUSBCLSTestBoxModeSwitch", --TestName
            ["portIdentifier"] = "CPort1DOWN" --PortIdentifier
        } 
    )

    CPort0DOWNUsbphyTurnOnLS = dag.add(
        "CPort0DOWNUsbphyTurnOnLS", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort0DOWNUsbphyTurnOnLS", --TestName
            ["portIdentifier"] = "CPort0DOWN" --PortIdentifier
        } 
    )

    CPort1DOWNUsbphyTurnOnLS = dag.add(
        "CPort1DOWNUsbphyTurnOnLS", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort1DOWNUsbphyTurnOnLS", --TestName
            ["portIdentifier"] = "CPort1DOWN" --PortIdentifier
        } 
    )


    SystemDOWNUSBLSPresenceDUTCheck = dag.add(
        "SystemDOWNUSBLSPresenceDUTCheck", --Burgundy Test Name
        "USBDutDevicePresenceTest.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "SystemDOWNUSBLSPresenceDUTCheck", --TestName
            ["portIdentifier"] = "SystemDOWN" --PortIdentifier
        } 
    )


    CPort0DOWNUsbphyTurnOffLS = dag.add(
        "CPort0DOWNUsbphyTurnOffLS", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort0DOWNUsbphyTurnOffLS", --TestName
            ["portIdentifier"] = "CPort0DOWN" --PortIdentifier
        } 
    )


    CPort1DOWNUsbphyTurnOffLS = dag.add(
        "CPort1DOWNUsbphyTurnOffLS", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort1DOWNUsbphyTurnOffLS", --TestName
            ["portIdentifier"] = "CPort1DOWN" --PortIdentifier
        } 
    )

    CPort0DOWNUSBCFSTestBoxModeSwitch = dag.add(
        "CPort0DOWNUSBCFSTestBoxModeSwitch", --Burgundy Test Name
        "AriesUSBCUsbSwitchTest.lua", --Action file
        {"titaniumCPort0DOWN"}, --plugins
        {
            ["TestName"] = "CPort0DOWNUSBCFSTestBoxModeSwitch", --TestName
            ["portIdentifier"] = "CPort0DOWN" --PortIdentifier
        } 
    )

    CPort1DOWNUSBCFSTestBoxModeSwitch = dag.add(
        "CPort1DOWNUSBCFSTestBoxModeSwitch", --Burgundy Test Name
        "AriesUSBCUsbSwitchTest.lua", --Action file
        {"titaniumCPort1DOWN"}, --plugins
        {
            ["TestName"] = "CPort1DOWNUSBCFSTestBoxModeSwitch", --TestName
            ["portIdentifier"] = "CPort1DOWN" --PortIdentifier
        } 
    )


    CPort0DOWNUsbphyTurnOnFS = dag.add(
        "CPort0DOWNUsbphyTurnOnFS", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort0DOWNUsbphyTurnOnFS", --TestName
            ["portIdentifier"] = "CPort0DOWN" --PortIdentifier
        } 
    )


    CPort1DOWNUsbphyTurnOnFS = dag.add(
        "CPort1DOWNUsbphyTurnOnFS", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort1DOWNUsbphyTurnOnFS", --TestName
            ["portIdentifier"] = "CPort1DOWN" --PortIdentifier
        } 
    )


    SystemDOWNUSBFSPresenceDUTCheck = dag.add(
        "SystemDOWNUSBFSPresenceDUTCheck", --Burgundy Test Name
        "USBDutDevicePresenceTest.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "SystemDOWNUSBFSPresenceDUTCheck", --TestName
            ["portIdentifier"] = "SystemDOWN" --PortIdentifier
        } 
    )


    CPort0DOWNUsbphyTurnOffFS = dag.add(
        "CPort0DOWNUsbphyTurnOffFS", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort0DOWNUsbphyTurnOffFS", --TestName
            ["portIdentifier"] = "CPort0DOWN" --PortIdentifier
        } 
    )


    CPort1DOWNUsbphyTurnOffFS = dag.add(
        "CPort1DOWNUsbphyTurnOffFS", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort1DOWNUsbphyTurnOffFS", --TestName
            ["portIdentifier"] = "CPort1DOWN" --PortIdentifier
        } 
    )

    CPort0DOWNUSBCHSTestBoxModeSwitch = dag.add(
        "CPort0DOWNUSBCHSTestBoxModeSwitch", --Burgundy Test Name
        "AriesUSBCUsbSwitchTest.lua", --Action file
        {"titaniumCPort0DOWN"}, --plugins
        {
            ["TestName"] = "CPort0DOWNUSBCHSTestBoxModeSwitch", --TestName
            ["portIdentifier"] = "CPort0DOWN" --PortIdentifier
        } 
    )

    CPort1DOWNUSBCHSTestBoxModeSwitch = dag.add(
        "CPort1DOWNUSBCHSTestBoxModeSwitch", --Burgundy Test Name
        "AriesUSBCUsbSwitchTest.lua", --Action file
        {"titaniumCPort1DOWN"}, --plugins
        {
            ["TestName"] = "CPort1DOWNUSBCHSTestBoxModeSwitch", --TestName
            ["portIdentifier"] = "CPort1DOWN" --PortIdentifier
        } 
    )

    CPort0DOWNUsbphyTurnOnHS = dag.add(
        "CPort0DOWNUsbphyTurnOnHS", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort0DOWNUsbphyTurnOnHS", --TestName
            ["portIdentifier"] = "CPort0DOWN" --PortIdentifier
        } 
    )


    CPort1DOWNUsbphyTurnOnHS = dag.add(
        "CPort1DOWNUsbphyTurnOnHS", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort1DOWNUsbphyTurnOnHS", --TestName
            ["portIdentifier"] = "CPort1DOWN" --PortIdentifier
        } 
    )

    SystemDOWNUSBHSPresenceDUTCheck = dag.add(
        "SystemDOWNUSBHSPresenceDUTCheck", --Burgundy Test Name
        "USBDutDevicePresenceTest.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "SystemDOWNUSBHSPresenceDUTCheck", --TestName
            ["portIdentifier"] = "SystemDOWN" --PortIdentifier
        } 
    )

    SystemDOWNUSBHSThroughput = dag.add(
        "SystemDOWNUSBHSThroughput", --Burgundy Test Name
        "USBThroughputTest.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "SystemDOWNUSBHSThroughput", --TestName
            ["portIdentifier"] = "SystemDOWN" --PortIdentifier
        } 
    )


    CPort0DOWNUsbphyTurnOffHS = dag.add(
        "CPort0DOWNUsbphyTurnOffHS", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort0DOWNUsbphyTurnOffHS", --TestName
            ["portIdentifier"] = "CPort0DOWN" --PortIdentifier
        } 
    )

    CPort1DOWNUsbphyTurnOffHS = dag.add(
        "CPort1DOWNUsbphyTurnOffHS", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort1DOWNUsbphyTurnOffHS", --TestName
            ["portIdentifier"] = "CPort1DOWN" --PortIdentifier
        } 
    )

    CPort0DOWNUSBCTestboxUsb2HubDisable = dag.add(
        "CPort0DOWNUSBCTestboxUsb2HubDisable", --Burgundy Test Name
        "AriesUSBCUsb2HubPathSelectTest.lua", --Action file
        {"titaniumCPort0DOWN"}, --plugins
        {
            ["TestName"] = "CPort0DOWNUSBCTestboxUsb2HubDisable", --TestName
            ["portIdentifier"] = "CPort0DOWN" --PortIdentifier
        } 
    )

    CPort1DOWNUSBCTestboxUsb2HubDisable = dag.add(
        "CPort1DOWNUSBCTestboxUsb2HubDisable", --Burgundy Test Name
        "AriesUSBCUsb2HubPathSelectTest.lua", --Action file
        {"titaniumCPort1DOWN"}, --plugins
        {
            ["TestName"] = "CPort1DOWNUSBCTestboxUsb2HubDisable", --TestName
            ["portIdentifier"] = "CPort1DOWN" --PortIdentifier
        } 
    )


    CPort0DOWNUsbphyTurnOnSS = dag.add(
        "CPort0DOWNUsbphyTurnOnSS", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort0DOWNUsbphyTurnOnSS", --TestName
            ["portIdentifier"] = "CPort0DOWN" --PortIdentifier
        } 
    )

    CPort1DOWNUsbphyTurnOnSS = dag.add(
        "CPort1DOWNUsbphyTurnOnSS", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort1DOWNUsbphyTurnOnSS", --TestName
            ["portIdentifier"] = "CPort1DOWN" --PortIdentifier
        } 
    )

    CPort0DOWNUSBCSSTestBoxModeSwitch = dag.add(
        "CPort0DOWNUSBCSSTestBoxModeSwitch", --Burgundy Test Name
        "AriesUSBCUsbSwitchTest.lua", --Action file
        {"titaniumCPort0DOWN"}, --plugins
        {
            ["TestName"] = "CPort0DOWNUSBCSSTestBoxModeSwitch", --TestName
            ["portIdentifier"] = "CPort0DOWN" --PortIdentifier
        } 
    )


    CPort1DOWNUSBCSSTestBoxModeSwitch = dag.add(
        "CPort1DOWNUSBCSSTestBoxModeSwitch", --Burgundy Test Name
        "AriesUSBCUsbSwitchTest.lua", --Action file
        {"titaniumCPort1DOWN"}, --plugins
        {
            ["TestName"] = "CPort1DOWNUSBCSSTestBoxModeSwitch", --TestName
            ["portIdentifier"] = "CPort1DOWN" --PortIdentifier
        } 
    )

    SystemDOWNUSBSSPresenceDUTCheck = dag.add(
        "SystemDOWNUSBSSPresenceDUTCheck", --Burgundy Test Name
        "USBDutDevicePresenceTest.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "SystemDOWNUSBSSPresenceDUTCheck", --TestName
            ["portIdentifier"] = "SystemDOWN" --PortIdentifier
        } 
    )

    CPort0USB5GTunableCheck = dag.add(
        "CPort0USB5GTunableCheck", --Burgundy Test Name
        "RegisterCheckTest.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort0USB5GTunableCheck", --TestName
            ["portIdentifier"] = "CPort0DOWN" --PortIdentifier
        } 
    )

    CPort1USB5GTunableCheck = dag.add(
        "CPort1USB5GTunableCheck", --Burgundy Test Name
        "RegisterCheckTest.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort1USB5GTunableCheck", --TestName
            ["portIdentifier"] = "CPort1DOWN" --PortIdentifier
        } 
    )


    CPort0DOWNUsbphyTurnOffSS = dag.add(
        "CPort0DOWNUsbphyTurnOffSS", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort0DOWNUsbphyTurnOffSS", --TestName
            ["portIdentifier"] = "CPort0DOWN" --PortIdentifier
        } 
    )

    CPort1DOWNUsbphyTurnOffSS = dag.add(
        "CPort1DOWNUsbphyTurnOffSS", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort1DOWNUsbphyTurnOffSS", --TestName
            ["portIdentifier"] = "CPort1DOWN" --PortIdentifier
        } 
    )


    CPort0DOWNUsbphyTurnOnSSP = dag.add(
        "CPort0DOWNUsbphyTurnOnSSP", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort0DOWNUsbphyTurnOnSSP", --TestName
            ["portIdentifier"] = "CPort0DOWN" --PortIdentifier
        } 
    )

    CPort1DOWNUsbphyTurnOnSSP = dag.add(
        "CPort1DOWNUsbphyTurnOnSSP", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort1DOWNUsbphyTurnOnSSP", --TestName
            ["portIdentifier"] = "CPort1DOWN" --PortIdentifier
        } 
    )

    CPort0DOWNUSBCSSPTestBoxModeSwitch = dag.add(
        "CPort0DOWNUSBCSSPTestBoxModeSwitch", --Burgundy Test Name
        "AriesUSBCUsbSwitchTest.lua", --Action file
        {"titaniumCPort0DOWN"}, --plugins
        {
            ["TestName"] = "CPort0DOWNUSBCSSPTestBoxModeSwitch", --TestName
            ["portIdentifier"] = "CPort0DOWN" --PortIdentifier
        } 
    )

    CPort1DOWNUSBCSSPTestBoxModeSwitch = dag.add(
        "CPort1DOWNUSBCSSPTestBoxModeSwitch", --Burgundy Test Name
        "AriesUSBCUsbSwitchTest.lua", --Action file
        {"titaniumCPort1DOWN"}, --plugins
        {
            ["TestName"] = "CPort1DOWNUSBCSSPTestBoxModeSwitch", --TestName
            ["portIdentifier"] = "CPort1DOWN" --PortIdentifier
        } 
    )

    SystemDOWNUSBSSPPresenceDUTCheck = dag.add(
        "SystemDOWNUSBSSPPresenceDUTCheck", --Burgundy Test Name
        "USBDutDevicePresenceTest.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "SystemDOWNUSBSSPPresenceDUTCheck", --TestName
            ["portIdentifier"] = "SystemDOWN" --PortIdentifier
        } 
    )

    CPort0USB10GTunableCheck = dag.add(
        "CPort0USB10GTunableCheck", --Burgundy Test Name
        "RegisterCheckTest.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort0USB10GTunableCheck", --TestName
            ["portIdentifier"] = "CPort0DOWN" --PortIdentifier
        } 
    )

    CPort1USB10GTunableCheck = dag.add(
        "CPort1USB10GTunableCheck", --Burgundy Test Name
        "RegisterCheckTest.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort1USB10GTunableCheck", --TestName
            ["portIdentifier"] = "CPort1DOWN" --PortIdentifier
        } 
    )

    CPort0DOWNUsbphyTurnOffSSP = dag.add(
        "CPort0DOWNUsbphyTurnOffSSP", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort0DOWNUsbphyTurnOffSSP", --TestName
            ["portIdentifier"] = "CPort0DOWN" --PortIdentifier
        } 
    )

    CPort1DOWNUsbphyTurnOffSSP = dag.add(
        "CPort1DOWNUsbphyTurnOffSSP", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort1DOWNUsbphyTurnOffSSP", --TestName
            ["portIdentifier"] = "CPort1DOWN" --PortIdentifier
        } 
    )

    CPort0DOWNUSBCVbusLoadTest = dag.add(
        "CPort0DOWNUSBCVbusLoadTest", --Burgundy Test Name
        "USBCVbusLoadTest.lua", --Action file
        {"titaniumCPort0DOWN"}, --plugins
        {
            ["TestName"] = "CPort0DOWNUSBCVbusLoadTest", --TestName
            ["portIdentifier"] = "CPort0DOWN" --PortIdentifier
        } 
    )

    CPort1DOWNUSBCVbusLoadTest = dag.add(
        "CPort1DOWNUSBCVbusLoadTest", --Burgundy Test Name
        "USBCVbusLoadTest.lua", --Action file
        {"titaniumCPort1DOWN"}, --plugins
        {
            ["TestName"] = "CPort1DOWNUSBCVbusLoadTest", --TestName
            ["portIdentifier"] = "CPort1DOWN" --PortIdentifier
        } 
    )


    CPort0DOWNUSBCVconnLoadTest = dag.add(
        "CPort0DOWNUSBCVconnLoadTest", --Burgundy Test Name
        "USBCVconnLoadTest.lua", --Action file
        {"titaniumCPort0DOWN"}, --plugins
        {
            ["TestName"] = "CPort0DOWNUSBCVconnLoadTest", --TestName
            ["portIdentifier"] = "CPort0DOWN" --PortIdentifier
        } 
    )

    CPort1DOWNUSBCVconnLoadTest = dag.add(
        "CPort1DOWNUSBCVconnLoadTest", --Burgundy Test Name
        "USBCVconnLoadTest.lua", --Action file
        {"titaniumCPort1DOWN"}, --plugins
        {
            ["TestName"] = "CPort1DOWNUSBCVconnLoadTest", --TestName
            ["portIdentifier"] = "CPort1DOWN" --PortIdentifier
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

    CPort0UPUSBCTestboxUsb2HubEnable = dag.add(
        "CPort0UPUSBCTestboxUsb2HubEnable", --Burgundy Test Name
        "AriesUSBCUsb2HubPathSelectTest.lua", --Action file
        {"titaniumCPort0UP"}, --plugins
        {
            ["TestName"] = "CPort0UPUSBCTestboxUsb2HubEnable", --TestName
            ["portIdentifier"] = "CPort0UP" --PortIdentifier
        } 
    )

    CPort1UPUSBCTestboxUsb2HubEnable = dag.add(
        "CPort1UPUSBCTestboxUsb2HubEnable", --Burgundy Test Name
        "AriesUSBCUsb2HubPathSelectTest.lua", --Action file
        {"titaniumCPort1UP"}, --plugins
        {
            ["TestName"] = "CPort1UPUSBCTestboxUsb2HubEnable", --TestName
            ["portIdentifier"] = "CPort1UP" --PortIdentifier
        } 
    )

    CPort0UPUSBCLSTestBoxModeSwitch = dag.add(
        "CPort0UPUSBCLSTestBoxModeSwitch", --Burgundy Test Name
        "AriesUSBCUsbSwitchTest.lua", --Action file
        {"titaniumCPort0UP"}, --plugins
        {
            ["TestName"] = "CPort0UPUSBCLSTestBoxModeSwitch", --TestName
            ["portIdentifier"] = "CPort0UP" --PortIdentifier
        } 
    )


    CPort1UPUSBCLSTestBoxModeSwitch = dag.add(
        "CPort1UPUSBCLSTestBoxModeSwitch", --Burgundy Test Name
        "AriesUSBCUsbSwitchTest.lua", --Action file
        {"titaniumCPort1UP"}, --plugins
        {
            ["TestName"] = "CPort1UPUSBCLSTestBoxModeSwitch", --TestName
            ["portIdentifier"] = "CPort1UP" --PortIdentifier
        } 
    )

    CPort0UPUsbphyTurnOnLS = dag.add(
        "CPort0UPUsbphyTurnOnLS", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort0UPUsbphyTurnOnLS", --TestName
            ["portIdentifier"] = "CPort0UP" --PortIdentifier
        } 
    )

    CPort1UPUsbphyTurnOnLS = dag.add(
        "CPort1UPUsbphyTurnOnLS", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort1UPUsbphyTurnOnLS", --TestName
            ["portIdentifier"] = "CPort1UP" --PortIdentifier
        } 
    )

    SystemUPUSBLSPresenceDUTCheck = dag.add(
        "SystemUPUSBLSPresenceDUTCheck", --Burgundy Test Name
        "USBDutDevicePresenceTest.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "SystemUPUSBLSPresenceDUTCheck", --TestName
            ["portIdentifier"] = "SystemUP" --PortIdentifier
        } 
    )

    CPort0UPUsbphyTurnOffLS = dag.add(
        "CPort0UPUsbphyTurnOffLS", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort0UPUsbphyTurnOffLS", --TestName
            ["portIdentifier"] = "CPort0UP" --PortIdentifier
        } 
    )

    CPort1UPUsbphyTurnOffLS = dag.add(
        "CPort1UPUsbphyTurnOffLS", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort1UPUsbphyTurnOffLS", --TestName
            ["portIdentifier"] = "CPort1UP" --PortIdentifier
        } 
    )

    CPort0UPUSBCFSTestBoxModeSwitch = dag.add(
        "CPort0UPUSBCFSTestBoxModeSwitch", --Burgundy Test Name
        "AriesUSBCUsbSwitchTest.lua", --Action file
        {"titaniumCPort0UP"}, --plugins
        {
            ["TestName"] = "CPort0UPUSBCFSTestBoxModeSwitch", --TestName
            ["portIdentifier"] = "CPort0UP" --PortIdentifier
        } 
    )

    CPort1UPUSBCFSTestBoxModeSwitch = dag.add(
        "CPort1UPUSBCFSTestBoxModeSwitch", --Burgundy Test Name
        "AriesUSBCUsbSwitchTest.lua", --Action file
        {"titaniumCPort1UP"}, --plugins
        {
            ["TestName"] = "CPort1UPUSBCFSTestBoxModeSwitch", --TestName
            ["portIdentifier"] = "CPort1UP" --PortIdentifier
        } 
    )

    CPort0UPUsbphyTurnOnFS = dag.add(
        "CPort0UPUsbphyTurnOnFS", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort0UPUsbphyTurnOnFS", --TestName
            ["portIdentifier"] = "CPort0UP" --PortIdentifier
        } 
    )

    CPort1UPUsbphyTurnOnFS = dag.add(
        "CPort1UPUsbphyTurnOnFS", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort1UPUsbphyTurnOnFS", --TestName
            ["portIdentifier"] = "CPort1UP" --PortIdentifier
        } 
    )

    SystemUPUSBFSPresenceDUTCheck = dag.add(
        "SystemUPUSBFSPresenceDUTCheck", --Burgundy Test Name
        "USBDutDevicePresenceTest.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "SystemUPUSBFSPresenceDUTCheck", --TestName
            ["portIdentifier"] = "SystemUP" --PortIdentifier
        } 
    )

    CPort0UPUsbphyTurnOffFS = dag.add(
        "CPort0UPUsbphyTurnOffFS", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort0UPUsbphyTurnOffFS", --TestName
            ["portIdentifier"] = "CPort0UP" --PortIdentifier
        } 
    )

    CPort1UPUsbphyTurnOffFS = dag.add(
        "CPort1UPUsbphyTurnOffFS", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort1UPUsbphyTurnOffFS", --TestName
            ["portIdentifier"] = "CPort1UP" --PortIdentifier
        } 
    )

    CPort0UPUSBCHSTestBoxModeSwitch = dag.add(
        "CPort0UPUSBCHSTestBoxModeSwitch", --Burgundy Test Name
        "AriesUSBCUsbSwitchTest.lua", --Action file
        {"titaniumCPort0UP"}, --plugins
        {
            ["TestName"] = "CPort0UPUSBCHSTestBoxModeSwitch", --TestName
            ["portIdentifier"] = "CPort0UP" --PortIdentifier
        } 
    )

    CPort1UPUSBCHSTestBoxModeSwitch = dag.add(
        "CPort1UPUSBCHSTestBoxModeSwitch", --Burgundy Test Name
        "AriesUSBCUsbSwitchTest.lua", --Action file
        {"titaniumCPort1UP"}, --plugins
        {
            ["TestName"] = "CPort1UPUSBCHSTestBoxModeSwitch", --TestName
            ["portIdentifier"] = "CPort1UP" --PortIdentifier
        } 
    )

    CPort0UPUsbphyTurnOnHS = dag.add(
        "CPort0UPUsbphyTurnOnHS", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort0UPUsbphyTurnOnHS", --TestName
            ["portIdentifier"] = "CPort0UP" --PortIdentifier
        } 
    )

    CPort1UPUsbphyTurnOnHS = dag.add(
        "CPort1UPUsbphyTurnOnHS", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort1UPUsbphyTurnOnHS", --TestName
            ["portIdentifier"] = "CPort1UP" --PortIdentifier
        } 
    )

    SystemUPUSBHSPresenceDUTCheck = dag.add(
        "SystemUPUSBHSPresenceDUTCheck", --Burgundy Test Name
        "USBDutDevicePresenceTest.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "SystemUPUSBHSPresenceDUTCheck", --TestName
            ["portIdentifier"] = "SystemUP" --PortIdentifier
        } 
    )


    SystemUPUSBHSThroughput = dag.add(
        "SystemUPUSBHSThroughput", --Burgundy Test Name
        "USBThroughputTest.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "SystemUPUSBHSThroughput", --TestName
            ["portIdentifier"] = "SystemUP" --PortIdentifier
        } 
    )

    CPort0UPUsbphyTurnOffHS = dag.add(
        "CPort0UPUsbphyTurnOffHS", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort0UPUsbphyTurnOffHS", --TestName
            ["portIdentifier"] = "CPort0UP" --PortIdentifier
        } 
    )

    CPort1UPUsbphyTurnOffHS = dag.add(
        "CPort1UPUsbphyTurnOffHS", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort1UPUsbphyTurnOffHS", --TestName
            ["portIdentifier"] = "CPort1UP" --PortIdentifier
        } 
    )

    CPort0UPUSBCTestboxUsb2HubDisable = dag.add(
        "CPort0UPUSBCTestboxUsb2HubDisable", --Burgundy Test Name
        "AriesUSBCUsb2HubPathSelectTest.lua", --Action file
        {"titaniumCPort0UP"}, --plugins
        {
            ["TestName"] = "CPort0UPUSBCTestboxUsb2HubDisable", --TestName
            ["portIdentifier"] = "CPort0UP" --PortIdentifier
        } 
    )

    CPort1UPUSBCTestboxUsb2HubDisable = dag.add(
        "CPort1UPUSBCTestboxUsb2HubDisable", --Burgundy Test Name
        "AriesUSBCUsb2HubPathSelectTest.lua", --Action file
        {"titaniumCPort1UP"}, --plugins
        {
            ["TestName"] = "CPort1UPUSBCTestboxUsb2HubDisable", --TestName
            ["portIdentifier"] = "CPort1UP" --PortIdentifier
        } 
    )

    CPort0UPUsbphyTurnOnSS = dag.add(
        "CPort0UPUsbphyTurnOnSS", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort0UPUsbphyTurnOnSS", --TestName
            ["portIdentifier"] = "CPort0UP" --PortIdentifier
        } 
    )

    CPort1UPUsbphyTurnOnSS = dag.add(
        "CPort1UPUsbphyTurnOnSS", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort1UPUsbphyTurnOnSS", --TestName
            ["portIdentifier"] = "CPort1UP" --PortIdentifier
        } 
    )

    CPort0UPUsbphyTurnOffSS = dag.add(
        "CPort0UPUsbphyTurnOffSS", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort0UPUsbphyTurnOffSS", --TestName
            ["portIdentifier"] = "CPort0UP" --PortIdentifier
        } 
    )

    CPort1UPUsbphyTurnOffSS = dag.add(
        "CPort1UPUsbphyTurnOffSS", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort1UPUsbphyTurnOffSS", --TestName
            ["portIdentifier"] = "CPort1UP" --PortIdentifier
        } 
    )

    CPort0UPUsbphyTurnOnSSP = dag.add(
        "CPort0UPUsbphyTurnOnSSP", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort0UPUsbphyTurnOnSSP", --TestName
            ["portIdentifier"] = "CPort0UP" --PortIdentifier
        } 
    )

    CPort1UPUsbphyTurnOnSSP = dag.add(
        "CPort1UPUsbphyTurnOnSSP", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort1UPUsbphyTurnOnSSP", --TestName
            ["portIdentifier"] = "CPort1UP" --PortIdentifier
        } 
    )

    CPort0UPUSBCSSPTestBoxModeSwitch = dag.add(
        "CPort0UPUSBCSSPTestBoxModeSwitch", --Burgundy Test Name
        "AriesUSBCUsbSwitchTest.lua", --Action file
        {"titaniumCPort0UP"}, --plugins
        {
            ["TestName"] = "CPort0UPUSBCSSPTestBoxModeSwitch", --TestName
            ["portIdentifier"] = "CPort0UP" --PortIdentifier
        } 
    )

    CPort1UPUSBCSSPTestBoxModeSwitch = dag.add(
        "CPort1UPUSBCSSPTestBoxModeSwitch", --Burgundy Test Name
        "AriesUSBCUsbSwitchTest.lua", --Action file
        {"titaniumCPort1UP"}, --plugins
        {
            ["TestName"] = "CPort1UPUSBCSSPTestBoxModeSwitch", --TestName
            ["portIdentifier"] = "CPort1UP" --PortIdentifier
        } 
    )

    SystemUPUSBSSPPresenceDUTCheck = dag.add(
        "SystemUPUSBSSPPresenceDUTCheck", --Burgundy Test Name
        "USBDutDevicePresenceTest.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "SystemUPUSBSSPPresenceDUTCheck", --TestName
            ["portIdentifier"] = "SystemUP" --PortIdentifier
        } 
    )


    CPort0UPUSBCSSTestBoxModeSwitch = dag.add(
        "CPort0UPUSBCSSTestBoxModeSwitch", --Burgundy Test Name
        "AriesUSBCUsbSwitchTest.lua", --Action file
        {"titaniumCPort0UP"}, --plugins
        {
            ["TestName"] = "CPort0UPUSBCSSTestBoxModeSwitch", --TestName
            ["portIdentifier"] = "CPort0UP" --PortIdentifier
        } 
    )

    CPort1UPUSBCSSTestBoxModeSwitch = dag.add(
        "CPort1UPUSBCSSTestBoxModeSwitch", --Burgundy Test Name
        "AriesUSBCUsbSwitchTest.lua", --Action file
        {"titaniumCPort1UP"}, --plugins
        {
            ["TestName"] = "CPort1UPUSBCSSTestBoxModeSwitch", --TestName
            ["portIdentifier"] = "CPort1UP" --PortIdentifier
        } 
    )

    SystemUPUSBSSPresenceDUTCheck = dag.add(
        "SystemUPUSBSSPresenceDUTCheck", --Burgundy Test Name
        "USBDutDevicePresenceTest.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "SystemUPUSBSSPresenceDUTCheck", --TestName
            ["portIdentifier"] = "SystemUP" --PortIdentifier
        } 
    )

       CPort0UPUsbphyTurnOffSSP = dag.add(
        "CPort0UPUsbphyTurnOffSSP", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort0UPUsbphyTurnOffSSP", --TestName
            ["portIdentifier"] = "CPort0UP" --PortIdentifier
        } 
    )

    CPort1UPUsbphyTurnOffSSP = dag.add(
        "CPort1UPUsbphyTurnOffSSP", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort1UPUsbphyTurnOffSSP", --TestName
            ["portIdentifier"] = "CPort1UP" --PortIdentifier
        } 
    )

   
    CPort0SwitchTestBoxNativeDP = dag.add(
        "CPort0SwitchTestBoxNativeDP", --Burgundy Test Name
        "TBTModeSwitchTest.lua", --Action file
        {"titaniumCPort0UP"}, --plugins
        {
            ["TestName"] = "CPort0SwitchTestBoxNativeDP", --TestName
            ["portIdentifier"] = "CPort0UP" --PortIdentifier
        } 
    )

    CPort1SwitchTestBoxNativeDP = dag.add(
        "CPort1SwitchTestBoxNativeDP", --Burgundy Test Name
        "TBTModeSwitchTest.lua", --Action file
        {"titaniumCPort1UP"}, --plugins
        {
            ["TestName"] = "CPort1SwitchTestBoxNativeDP", --TestName
            ["portIdentifier"] = "CPort1UP" --PortIdentifier
        } 
    )

    CPort0DPHBR3DisplayPattern = dag.add(
        "CPort0DPHBR3DisplayPattern", --Burgundy Test Name
        "TaurusUSBCDisplayPatternTest.lua", --Action file
        {"titaniumCPort0UP","dut"}, --plugins
        {
            ["TestName"] = "CPort0DPHBR3DisplayPattern", --TestName
            ["portIdentifier"] = "CPort0UP" --PortIdentifier
        } 
    )

    CPort1DPHBR3DisplayPattern = dag.add(
        "CPort1DPHBR3DisplayPattern", --Burgundy Test Name
        "TaurusUSBCDisplayPatternTest.lua", --Action file
        {"titaniumCPort1UP","dut"}, --plugins
        {
            ["TestName"] = "CPort1DPHBR3DisplayPattern", --TestName
            ["portIdentifier"] = "CPort1UP" --PortIdentifier
        } 
    )

    CPort0UPUsbphyTurnOffNativeDP = dag.add(
        "CPort0UPUsbphyTurnOffNativeDP", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort0UPUsbphyTurnOffNativeDP", --TestName
            ["portIdentifier"] = "CPort0UP" --PortIdentifier
        } 
    )

    CPort1UPUsbphyTurnOffNativeDP = dag.add(
        "CPort1UPUsbphyTurnOffNativeDP", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort1UPUsbphyTurnOffNativeDP", --TestName
            ["portIdentifier"] = "CPort1UP" --PortIdentifier
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

    CPort0DPTunnelDisplayPattern = dag.add(
        "CPort0DPTunnelDisplayPattern", --Burgundy Test Name
        "TaurusUSBCDisplayPatternTest.lua", --Action file
        {"titaniumCPort0UP","dut"}, --plugins
        {
            ["TestName"] = "CPort0DPTunnelDisplayPattern", --TestName
            ["portIdentifier"] = "CPort0UP" --PortIdentifier
        } 
    )

    CPort1DPTunnelDisplayPattern = dag.add(
        "CPort1DPTunnelDisplayPattern", --Burgundy Test Name
        "TaurusUSBCDisplayPatternTest.lua", --Action file
        {"titaniumCPort1UP","dut"}, --plugins
        {
            ["TestName"] = "CPort1DPTunnelDisplayPattern", --TestName
            ["portIdentifier"] = "CPort1UP" --PortIdentifier
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

    SystemUPCIO20GHostEyeTest = dag.add(
        "SystemUPCIO20GHostEyeTest", --Burgundy Test Name
        "TaurusParallelHostEyeTest.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "SystemUPCIO20GHostEyeTest", --TestName
            ["portIdentifier"] = "SystemUP" --PortIdentifier
        } 
    )
--[[
    
    CPort0CIO20GHostEyeTest = dag.add(
        "CPort0CIO20GHostEyeTest", --Burgundy Test Name
        "TaurusHostEyeTest.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort0CIO20GHostEyeTest", --TestName
            ["portIdentifier"] = "CPort0UP" --PortIdentifier
        } 
    )

    CPort1CIO20GHostEyeTest = dag.add(
        "CPort1CIO20GHostEyeTest", --Burgundy Test Name
        "TaurusHostEyeTest.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort1CIO20GHostEyeTest", --TestName
            ["portIdentifier"] = "CPort1UP" --PortIdentifier
        } 
    )

--]]
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

    -- SystemUPTBTThroughput = dag.add(
    --     "SystemUPTBTThroughput", --Burgundy Test Name
    --     "TBTThroughputTest.lua", --Action file
    --     {"dut"}, --plugins
    --     {
    --         ["TestName"] = "SystemUPTBTThroughput", --TestName
    --         ["portIdentifier"] = "SystemUP" --PortIdentifier
    --     } 
    -- )



    CPort0UPUSBCVconnLoadTest = dag.add(
        "CPort0UPUSBCVconnLoadTest", --Burgundy Test Name
        "USBCVconnLoadTest.lua", --Action file
        {"titaniumCPort0UP"}, --plugins
        {
            ["TestName"] = "CPort0UPUSBCVconnLoadTest", --TestName
            ["portIdentifier"] = "CPort0UP" --PortIdentifier
        } 
    )

    CPort1UPUSBCVconnLoadTest = dag.add(
        "CPort1UPUSBCVconnLoadTest", --Burgundy Test Name
        "USBCVconnLoadTest.lua", --Action file
        {"titaniumCPort1UP"}, --plugins
        {
            ["TestName"] = "CPort1UPUSBCVconnLoadTest", --TestName
            ["portIdentifier"] = "CPort1UP" --PortIdentifier
        } 
    )

    CPort0UPUSBCAdapterVoltageTest5V = dag.add(
        "CPort0UPUSBCAdapterVoltageTest5V", --Burgundy Test Name
        "USBCAdapterVoltageTest.lua", --Action file
        {"titaniumCPort0UP","dut"}, --plugins
        {
            ["TestName"] = "CPort0UPUSBCAdapterVoltageTest5V", --TestName
            ["portIdentifier"] = "CPort0UP" --PortIdentifier
        } 
    )

    CPort0UPUSBCAdapterVoltageTest9V = dag.add(
        "CPort0UPUSBCAdapterVoltageTest9V", --Burgundy Test Name
        "USBCAdapterVoltageTest.lua", --Action file
        {"titaniumCPort0UP","dut"}, --plugins
        {
            ["TestName"] = "CPort0UPUSBCAdapterVoltageTest9V", --TestName
            ["portIdentifier"] = "CPort0UP" --PortIdentifier
        } 
    )

    CPort0UPUSBCAdapterVoltageTest15V = dag.add(
        "CPort0UPUSBCAdapterVoltageTest15V", --Burgundy Test Name
        "USBCAdapterVoltageTest.lua", --Action file
        {"titaniumCPort0UP","dut"}, --plugins
        {
            ["TestName"] = "CPort0UPUSBCAdapterVoltageTest15V", --TestName
            ["portIdentifier"] = "CPort0UP" --PortIdentifier
        } 
    )

    CPort0UPUSBCAdapterVoltageTest20V = dag.add(
        "CPort0UPUSBCAdapterVoltageTest20V", --Burgundy Test Name
        "USBCAdapterVoltageTest.lua", --Action file
        {"titaniumCPort0UP","dut"}, --plugins
        {
            ["TestName"] = "CPort0UPUSBCAdapterVoltageTest20V", --TestName
            ["portIdentifier"] = "CPort0UP" --PortIdentifier
        } 
    )

    CPort1UPUSBCAdapterVoltageTest5V = dag.add(
        "CPort1UPUSBCAdapterVoltageTest5V", --Burgundy Test Name
        "USBCAdapterVoltageTest.lua", --Action file
        {"titaniumCPort1UP","dut"}, --plugins
        {
            ["TestName"] = "CPort1UPUSBCAdapterVoltageTest5V", --TestName
            ["portIdentifier"] = "CPort1UP" --PortIdentifier
        } 
    )

--[[
    CPort1UPUSBCAdapterVoltageTest9V = dag.add(
        "CPort1UPUSBCAdapterVoltageTest9V", --Burgundy Test Name
        "USBCAdapterVoltageTest.lua", --Action file
        {"titaniumCPort1UP","dut"}, --plugins
        {
            ["TestName"] = "CPort1UPUSBCAdapterVoltageTest9V", --TestName
            ["portIdentifier"] = "CPort1UP" --PortIdentifier
        } 
    )

    CPort1UPUSBCAdapterVoltageTest15V = dag.add(
        "CPort1UPUSBCAdapterVoltageTest15V", --Burgundy Test Name
        "USBCAdapterVoltageTest.lua", --Action file
        {"titaniumCPort1UP","dut"}, --plugins
        {
            ["TestName"] = "CPort1UPUSBCAdapterVoltageTest15V", --TestName
            ["portIdentifier"] = "CPort1UP" --PortIdentifier
        } 
    )
--]]


    CPort1UPUSBCAdapterVoltageTest20V = dag.add(
        "CPort1UPUSBCAdapterVoltageTest20V", --Burgundy Test Name
        "USBCAdapterVoltageTest.lua", --Action file
        {"titaniumCPort1UP","dut"}, --plugins
        {
            ["TestName"] = "CPort1UPUSBCAdapterVoltageTest20V", --TestName
            ["portIdentifier"] = "CPort1UP" --PortIdentifier
        } 
    )

    -- SystemReset = dag.add(
    --     "SystemReset", --Burgundy Test Name
    --     "SendCommandToDUT.lua", --Action file
    --     {"dut"}, --plugins
    --     {
    --         ["TestName"] = "SystemReset", --TestName
    --         ["portIdentifier"] = "System" --PortIdentifier
    --     } 
    -- )


    DutEnd = dag.add(
        "DutEnd", --Burgundy Test Name
        "DutEnd.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "DutEnd", --TestName
            ["portIdentifier"] = "System" --PortIdentifier
        } 
    )




--Test Box FW Check
    dag.order(DutStart, CPort0TitaniumFWCheck)
    dag.order(DutStart, CPort1TitaniumFWCheck)
    dag.order(DutStart, CPort0CaesiumFWCheck)
    dag.order(DutStart, CPort1CaesiumFWCheck)

--Read Neutron SN
    dag.order(CPort0TitaniumFWCheck, CPort0CableSerialNumber)
    dag.order(CPort1TitaniumFWCheck, CPort1CableSerialNumber)

--Battery Drain Test
    dag.order(CPort0CableSerialNumber, SystemDOWNBatteryDrainTest)
    dag.order(CPort1CableSerialNumber, SystemDOWNBatteryDrainTest)
    dag.order(CPort0CaesiumFWCheck, SystemDOWNBatteryDrainTest)
    dag.order(CPort1CaesiumFWCheck, SystemDOWNBatteryDrainTest)

--Down Orientation Check
    dag.order(SystemDOWNBatteryDrainTest, CPort0DOWNPortOrientationCheck)
    dag.order(CPort0DOWNPortOrientationCheck, CPort1DOWNPortOrientationCheck)

--Down LS Presence Test
    dag.order(CPort1DOWNPortOrientationCheck, CPort0DOWNUSBCTestboxUsb2HubEnable)
    dag.order(CPort1DOWNPortOrientationCheck, CPort1DOWNUSBCTestboxUsb2HubEnable)
    dag.order(CPort0DOWNUSBCTestboxUsb2HubEnable, CPort0DOWNUSBCLSTestBoxModeSwitch)
    dag.order(CPort1DOWNUSBCTestboxUsb2HubEnable, CPort0DOWNUSBCLSTestBoxModeSwitch)
    dag.order(CPort0DOWNUSBCTestboxUsb2HubEnable, CPort1DOWNUSBCLSTestBoxModeSwitch)
    dag.order(CPort1DOWNUSBCTestboxUsb2HubEnable, CPort1DOWNUSBCLSTestBoxModeSwitch)
    dag.order(CPort0DOWNUSBCLSTestBoxModeSwitch, CPort0DOWNUsbphyTurnOnLS)
    dag.order(CPort1DOWNUSBCLSTestBoxModeSwitch, CPort0DOWNUsbphyTurnOnLS)
    dag.order(CPort0DOWNUsbphyTurnOnLS, CPort1DOWNUsbphyTurnOnLS)
    dag.order(CPort1DOWNUsbphyTurnOnLS, SystemDOWNUSBLSPresenceDUTCheck)
    dag.order(SystemDOWNUSBLSPresenceDUTCheck, CPort0DOWNUsbphyTurnOffLS)
    dag.order(CPort0DOWNUsbphyTurnOffLS, CPort1DOWNUsbphyTurnOffLS)

--Down FS Presence Test
    dag.order(CPort1DOWNUsbphyTurnOffLS, CPort0DOWNUSBCFSTestBoxModeSwitch)
    dag.order(CPort1DOWNUsbphyTurnOffLS, CPort1DOWNUSBCFSTestBoxModeSwitch)
    dag.order(CPort0DOWNUSBCFSTestBoxModeSwitch,CPort0DOWNUsbphyTurnOnFS)
    dag.order(CPort1DOWNUSBCFSTestBoxModeSwitch,CPort0DOWNUsbphyTurnOnFS)
    dag.order(CPort0DOWNUsbphyTurnOnFS, CPort1DOWNUsbphyTurnOnFS)
    dag.order(CPort1DOWNUsbphyTurnOnFS, SystemDOWNUSBFSPresenceDUTCheck)
    dag.order(SystemDOWNUSBFSPresenceDUTCheck, CPort0DOWNUsbphyTurnOffFS)
    dag.order(CPort0DOWNUsbphyTurnOffFS, CPort1DOWNUsbphyTurnOffFS)

--Down HS Presence Test
    dag.order(CPort1DOWNUsbphyTurnOffFS, CPort0DOWNUSBCHSTestBoxModeSwitch)
    dag.order(CPort1DOWNUsbphyTurnOffFS, CPort1DOWNUSBCHSTestBoxModeSwitch)
    dag.order(CPort0DOWNUSBCHSTestBoxModeSwitch, CPort0DOWNUsbphyTurnOnHS)
    dag.order(CPort1DOWNUSBCHSTestBoxModeSwitch, CPort0DOWNUsbphyTurnOnHS)
    dag.order(CPort0DOWNUsbphyTurnOnHS, CPort1DOWNUsbphyTurnOnHS)
    dag.order(CPort1DOWNUsbphyTurnOnHS, SystemDOWNUSBHSPresenceDUTCheck)
    dag.order(SystemDOWNUSBHSPresenceDUTCheck, SystemDOWNUSBHSThroughput)
    dag.order(SystemDOWNUSBHSThroughput, CPort0DOWNUsbphyTurnOffHS)
    dag.order(CPort0DOWNUsbphyTurnOffHS, CPort1DOWNUsbphyTurnOffHS)

--Down SS Presence and Tunable Test
    dag.order(CPort1DOWNUsbphyTurnOffHS, CPort0DOWNUSBCTestboxUsb2HubDisable)
    dag.order(CPort1DOWNUsbphyTurnOffHS, CPort1DOWNUSBCTestboxUsb2HubDisable)
    dag.order(CPort0DOWNUSBCTestboxUsb2HubDisable, CPort0DOWNUsbphyTurnOnSS)
    dag.order(CPort1DOWNUSBCTestboxUsb2HubDisable, CPort0DOWNUsbphyTurnOnSS)
    dag.order(CPort0DOWNUsbphyTurnOnSS, CPort1DOWNUsbphyTurnOnSS)
    dag.order(CPort1DOWNUsbphyTurnOnSS, CPort0DOWNUSBCSSTestBoxModeSwitch)
    dag.order(CPort1DOWNUsbphyTurnOnSS, CPort1DOWNUSBCSSTestBoxModeSwitch)
    dag.order(CPort0DOWNUSBCSSTestBoxModeSwitch, SystemDOWNUSBSSPresenceDUTCheck)
    dag.order(CPort1DOWNUSBCSSTestBoxModeSwitch, SystemDOWNUSBSSPresenceDUTCheck)
    dag.order(SystemDOWNUSBSSPresenceDUTCheck, CPort0USB5GTunableCheck)
    dag.order(CPort0USB5GTunableCheck, CPort1USB5GTunableCheck)
    dag.order(CPort1USB5GTunableCheck, CPort0DOWNUsbphyTurnOffSS)
    dag.order(CPort0DOWNUsbphyTurnOffSS, CPort1DOWNUsbphyTurnOffSS)

--Down SSP Presence and Tunable Test
    dag.order(CPort1DOWNUsbphyTurnOffSS, CPort0DOWNUsbphyTurnOnSSP)
    dag.order(CPort0DOWNUsbphyTurnOnSSP, CPort1DOWNUsbphyTurnOnSSP)
    dag.order(CPort1DOWNUsbphyTurnOnSSP, CPort0DOWNUSBCSSPTestBoxModeSwitch)
    dag.order(CPort1DOWNUsbphyTurnOnSSP, CPort1DOWNUSBCSSPTestBoxModeSwitch)
    dag.order(CPort0DOWNUSBCSSPTestBoxModeSwitch, SystemDOWNUSBSSPPresenceDUTCheck)
    dag.order(CPort1DOWNUSBCSSPTestBoxModeSwitch, SystemDOWNUSBSSPPresenceDUTCheck)
    dag.order(SystemDOWNUSBSSPPresenceDUTCheck, CPort0USB10GTunableCheck)
    dag.order(CPort0USB10GTunableCheck, CPort1USB10GTunableCheck)
    dag.order(CPort1USB10GTunableCheck, CPort0DOWNUsbphyTurnOffSSP)
    dag.order(CPort0DOWNUsbphyTurnOffSSP, CPort1DOWNUsbphyTurnOffSSP)

--Vbus Load Test
    dag.order(CPort0DOWNUsbphyTurnOffSSP, CPort1DOWNUSBCVbusLoadTest)
    
    dag.order(CPort1DOWNUsbphyTurnOffSSP, CPort0DOWNUSBCVbusLoadTest)
    dag.order(CPort1DOWNUSBCVbusLoadTest, CPort0DOWNUSBCVbusLoadTest)
    
--VConn Load Test
    dag.order(CPort0DOWNUSBCVbusLoadTest, CPort0DOWNUSBCVconnLoadTest)
    dag.order(CPort0DOWNUSBCVbusLoadTest, CPort1DOWNUSBCVconnLoadTest)

--Up Orientation Check
    dag.order(CPort0DOWNUSBCVconnLoadTest, CPort0UPPortOrientationCheck)
    dag.order(CPort1DOWNUSBCVconnLoadTest, CPort0UPPortOrientationCheck)
    dag.order(CPort0UPPortOrientationCheck, CPort1UPPortOrientationCheck)

    dag.order(CPort1UPPortOrientationCheck, CPort0UPUSBCTestboxUsb2HubEnable)
    dag.order(CPort1UPPortOrientationCheck, CPort1UPUSBCTestboxUsb2HubEnable)

--Up LS Presence Test
    dag.order(CPort0UPUSBCTestboxUsb2HubEnable, CPort0UPUSBCLSTestBoxModeSwitch)
    dag.order(CPort1UPUSBCTestboxUsb2HubEnable, CPort0UPUSBCLSTestBoxModeSwitch)
    dag.order(CPort0UPUSBCTestboxUsb2HubEnable, CPort1UPUSBCLSTestBoxModeSwitch)
    dag.order(CPort1UPUSBCTestboxUsb2HubEnable, CPort1UPUSBCLSTestBoxModeSwitch)
    dag.order(CPort0UPUSBCLSTestBoxModeSwitch, CPort0UPUsbphyTurnOnLS)
    dag.order(CPort1UPUSBCLSTestBoxModeSwitch, CPort0UPUsbphyTurnOnLS)
    dag.order(CPort0UPUsbphyTurnOnLS, CPort1UPUsbphyTurnOnLS)
    dag.order(CPort1UPUsbphyTurnOnLS, SystemUPUSBLSPresenceDUTCheck)
    dag.order(SystemUPUSBLSPresenceDUTCheck, CPort0UPUsbphyTurnOffLS)
    dag.order(CPort0UPUsbphyTurnOffLS, CPort1UPUsbphyTurnOffLS)

--Up FS Presence Test
    dag.order(CPort1UPUsbphyTurnOffLS, CPort0UPUSBCFSTestBoxModeSwitch)
    dag.order(CPort1UPUsbphyTurnOffLS, CPort1UPUSBCFSTestBoxModeSwitch)
    dag.order(CPort0UPUSBCFSTestBoxModeSwitch, CPort0UPUsbphyTurnOnFS)
    dag.order(CPort1UPUSBCFSTestBoxModeSwitch, CPort0UPUsbphyTurnOnFS)
    dag.order(CPort0UPUsbphyTurnOnFS, CPort1UPUsbphyTurnOnFS)
    dag.order(CPort1UPUsbphyTurnOnFS, SystemUPUSBFSPresenceDUTCheck)
    dag.order(SystemUPUSBFSPresenceDUTCheck, CPort0UPUsbphyTurnOffFS)
    dag.order(CPort0UPUsbphyTurnOffFS, CPort1UPUsbphyTurnOffFS)

--Up HS Presence and Throughput Test
    dag.order(CPort1UPUsbphyTurnOffFS, CPort0UPUSBCHSTestBoxModeSwitch)
    dag.order(CPort1UPUsbphyTurnOffFS, CPort1UPUSBCHSTestBoxModeSwitch)
    dag.order(CPort0UPUSBCHSTestBoxModeSwitch, CPort0UPUsbphyTurnOnHS)
    dag.order(CPort1UPUSBCHSTestBoxModeSwitch, CPort0UPUsbphyTurnOnHS)
    dag.order(CPort0UPUsbphyTurnOnHS, CPort1UPUsbphyTurnOnHS)
    dag.order(CPort1UPUsbphyTurnOnHS, SystemUPUSBHSPresenceDUTCheck)
    dag.order(SystemUPUSBHSPresenceDUTCheck, SystemUPUSBHSThroughput)
    dag.order(SystemUPUSBHSThroughput, CPort0UPUsbphyTurnOffHS)
    dag.order(CPort0UPUsbphyTurnOffHS, CPort1UPUsbphyTurnOffHS)

--Up SS Presence Test
    dag.order(CPort1UPUsbphyTurnOffHS, CPort0UPUSBCTestboxUsb2HubDisable)
    dag.order(CPort1UPUsbphyTurnOffHS, CPort1UPUSBCTestboxUsb2HubDisable)
    dag.order(CPort0UPUSBCTestboxUsb2HubDisable, CPort0UPUsbphyTurnOnSS)
    dag.order(CPort1UPUSBCTestboxUsb2HubDisable, CPort0UPUsbphyTurnOnSS)
    dag.order(CPort0UPUsbphyTurnOnSS, CPort1UPUsbphyTurnOnSS)
    dag.order(CPort1UPUsbphyTurnOnSS, CPort0UPUSBCSSTestBoxModeSwitch)
    dag.order(CPort1UPUsbphyTurnOnSS, CPort1UPUSBCSSTestBoxModeSwitch)
    dag.order(CPort0UPUSBCSSTestBoxModeSwitch, SystemUPUSBSSPresenceDUTCheck)
    dag.order(CPort1UPUSBCSSTestBoxModeSwitch, SystemUPUSBSSPresenceDUTCheck)
    dag.order(SystemUPUSBSSPresenceDUTCheck, CPort0UPUsbphyTurnOffSS)
    dag.order(CPort0UPUsbphyTurnOffSS, CPort1UPUsbphyTurnOffSS)

--Up SSP Presence Test
    dag.order(CPort1UPUsbphyTurnOffSS, CPort0UPUsbphyTurnOnSSP)
    dag.order(CPort0UPUsbphyTurnOnSSP, CPort1UPUsbphyTurnOnSSP)
    dag.order(CPort1UPUsbphyTurnOnSSP, CPort0UPUSBCSSPTestBoxModeSwitch)
    dag.order(CPort1UPUsbphyTurnOnSSP, CPort1UPUSBCSSPTestBoxModeSwitch)
    dag.order(CPort0UPUSBCSSPTestBoxModeSwitch, SystemUPUSBSSPPresenceDUTCheck)
    dag.order(CPort1UPUSBCSSPTestBoxModeSwitch, SystemUPUSBSSPPresenceDUTCheck)
    dag.order(SystemUPUSBSSPPresenceDUTCheck, CPort0UPUsbphyTurnOffSSP)
    dag.order(CPort0UPUsbphyTurnOffSSP, CPort1UPUsbphyTurnOffSSP)

--Native Display Pattern Test
    dag.order(CPort1UPUsbphyTurnOffSSP, CPort0SwitchTestBoxNativeDP)
    dag.order(CPort1UPUsbphyTurnOffSSP, CPort1SwitchTestBoxNativeDP)
    dag.order(CPort0SwitchTestBoxNativeDP, CPort0DPHBR3DisplayPattern)
    dag.order(CPort1SwitchTestBoxNativeDP, CPort0DPHBR3DisplayPattern)
    dag.order(CPort0DPHBR3DisplayPattern, CPort0UPUsbphyTurnOffNativeDP)
    dag.order(CPort0UPUsbphyTurnOffNativeDP, CPort1DPHBR3DisplayPattern)
    dag.order(CPort1DPHBR3DisplayPattern, CPort1UPUsbphyTurnOffNativeDP)

--Tunnel Display Pattern Test
    dag.order(CPort1UPUsbphyTurnOffNativeDP, CPort0SwitchTestBoxTunnelDP)
    dag.order(CPort1UPUsbphyTurnOffNativeDP, CPort1SwitchTestBoxTunnelDP)
    dag.order(CPort0SwitchTestBoxTunnelDP, CPort0DPTunnelDisplayPattern)
    dag.order(CPort1SwitchTestBoxTunnelDP, CPort0DPTunnelDisplayPattern)
    dag.order(CPort0DPTunnelDisplayPattern, CPort0UPUsbphyTurnOffTunnelDP)    
    dag.order(CPort0UPUsbphyTurnOffTunnelDP, CPort1DPTunnelDisplayPattern)
    dag.order(CPort1DPTunnelDisplayPattern, CPort1UPUsbphyTurnOffTunnelDP)

--CIO20G Presence Test
    dag.order(CPort1UPUsbphyTurnOffTunnelDP, CPort0CIO20GPresenceTest)
    dag.order(CPort0CIO20GPresenceTest, CPort1CIO20GPresenceTest)
    
--CIO20G Tunable Check
    dag.order(CPort1CIO20GPresenceTest, CPort0CIO20GTunableCheck)
    dag.order(CPort0CIO20GTunableCheck, CPort1CIO20GTunableCheck)
    
    
--Eye Test
    dag.order(CPort1CIO20GTunableCheck, SystemUPCIO20GHostEyeTest)
--[[
    dag.order(CPort0CIO20GHostEyeTest, CPort1CIO20GHostEyeTest)
--]]
    dag.order(SystemUPCIO20GHostEyeTest, CPort0CIO20GTestBoxEyeCapture)
    dag.order(SystemUPCIO20GHostEyeTest, CPort1CIO20GTestBoxEyeCapture)
    dag.order(CPort0CIO20GTestBoxEyeCapture, CPort0CIO20GR2DRetimerEyeTest)
    dag.order(CPort1CIO20GTestBoxEyeCapture, CPort0CIO20GR2DRetimerEyeTest)
    dag.order(CPort0CIO20GR2DRetimerEyeTest, CPort0CIO20GD2RRetimerEyeTest)
    dag.order(CPort0CIO20GD2RRetimerEyeTest, CPort1CIO20GR2DRetimerEyeTest)
    dag.order(CPort1CIO20GR2DRetimerEyeTest, CPort1CIO20GD2RRetimerEyeTest)

--[[
--TBT Throughput Test
    dag.order(CPort1CIO20GD2RRetimerEyeTest, SystemUPTBTThroughput)
--]]

--Up Vconn Test
    dag.order(CPort1CIO20GD2RRetimerEyeTest, CPort0UPUSBCVconnLoadTest)
    dag.order(CPort1CIO20GD2RRetimerEyeTest, CPort1UPUSBCVconnLoadTest)

--Adapter Voltage Test
--CPort0 5v->9v->15v->20v
    dag.order(CPort0UPUSBCVconnLoadTest, CPort0UPUSBCAdapterVoltageTest5V)
    dag.order(CPort1UPUSBCVconnLoadTest, CPort0UPUSBCAdapterVoltageTest5V)
    dag.order(CPort0UPUSBCAdapterVoltageTest5V, CPort0UPUSBCAdapterVoltageTest9V)
    dag.order(CPort0UPUSBCAdapterVoltageTest9V, CPort0UPUSBCAdapterVoltageTest15V)
    dag.order(CPort0UPUSBCAdapterVoltageTest15V, CPort0UPUSBCAdapterVoltageTest20V)

--CPort1 5v->20v(sync with DY and Alan@05272020: one port drop 9V,15V. Only 5V/20V)
    dag.order(CPort0UPUSBCAdapterVoltageTest20V, CPort1UPUSBCAdapterVoltageTest5V)
    -- dag.order(CPort1UPUSBCAdapterVoltageTest5V, CPort1UPUSBCAdapterVoltageTest9V)
    -- dag.order(CPort1UPUSBCAdapterVoltageTest9V, CPort1UPUSBCAdapterVoltageTest15V)
    dag.order(CPort1UPUSBCAdapterVoltageTest5V, CPort1UPUSBCAdapterVoltageTest20V)
   
--System Reset and DutEnd
    dag.order(CPort1UPUSBCAdapterVoltageTest20V, DutEnd)
    --dag.order(SystemReset, DutEnd)
    
end
