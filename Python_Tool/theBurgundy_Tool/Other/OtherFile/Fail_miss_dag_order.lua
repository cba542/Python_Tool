burgundy = require "Burgundy"

local io = require "io"
local alitaUility = require  "AlitaTestCore/AlitaUility"
local alitaStationConfig = require "AlitaTestCore/AlitaConfig/AlitaStationConfig"

function plist_path()
    if (Group.isAudit()) then
        local auditPlist = "Config/BurgundyAudit.plist"
        local f = io.open(auditPlist, "r")
        if f then
            io.close(f)
            return auditPlist
        end
    end
    return "Config/Burgundy-IO1.plist"
end

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

    print("Atlas-debug unit_tests_dag device: " .. alitaUility.Table.StringifyTable(device))
    print("Atlas-debug unit_tests_dag plugins: " .. alitaUility.Table.StringifyTable(plugins))
    local groupID = Group.getDeviceSystemIndex(device)
    print("Atlas-debug group ID: " .. groupID)

    local interactiveUI = plugins[ "InterActiveUI" ]
    for i, testbox in ipairs(alitaStationConfig.fixturesToCheckCableCount) do
        print("Atlas-debug fixturesToCheckCableCount add box " .. testbox)
        local cableCount = getCableCount(plugins[testbox])
        interactiveUI.logInfoToGroup(groupID, "CableCt[" .. testbox .. "]: " ..  cableCount)
        if alitaStationConfig.checkCableCount then
            if cableCount > alitaStationConfig.cableCountLimit then
                os.execute("osascript -e 'tell app \"System Events\" to display dialog \"Cable Count[" .. testbox .. "] : " .. cableCount .. " exceed limit " .. alitaStationConfig.cableCountLimit .. ", please charge cable\n请更换Neutron.\"'")
                error("CableCount limit exceeded.")
            end
        end
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

    CPort2CaesiumFWCheck = dag.add(
        "CPort2CaesiumFWCheck", --Burgundy Test Name
        "TestBoxVersionTest.lua", --Action file
        {"caesiumCPort2DOWN"}, --plugins
        {
            ["TestName"] = "CPort2CaesiumFWCheck", --TestName
            ["portIdentifier"] = "CPort2DOWN" --PortIdentifier
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

    CPort2DOWNPortOrientationCheck = dag.add(
        "CPort2DOWNPortOrientationCheck", --Burgundy Test Name
        "PortOrientationCheckTest.lua", --Action file
        {"titaniumCPort2DOWN", "dut"}, --plugins
        {
            ["TestName"] = "CPort2DOWNPortOrientationCheck", --TestName
            ["portIdentifier"] = "CPort2DOWN" --PortIdentifier
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

    CPort2DOWNUSBCTestboxUsb2HubEnable = dag.add(
        "CPort2DOWNUSBCTestboxUsb2HubEnable", --Burgundy Test Name
        "AriesUSBCUsb2HubPathSelectTest.lua", --Action file
        {"titaniumCPort2DOWN"}, --plugins
        {
            ["TestName"] = "CPort2DOWNUSBCTestboxUsb2HubEnable", --TestName
            ["portIdentifier"] = "CPort2DOWN" --PortIdentifier
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

    CPort2DOWNUSBCLSTestBoxModeSwitch = dag.add(
        "CPort2DOWNUSBCLSTestBoxModeSwitch", --Burgundy Test Name
        "AriesUSBCUsbSwitchTest.lua", --Action file
        {"titaniumCPort2DOWN"}, --plugins
        {
            ["TestName"] = "CPort2DOWNUSBCLSTestBoxModeSwitch", --TestName
            ["portIdentifier"] = "CPort2DOWN" --PortIdentifier
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

    CPort2DOWNUsbphyTurnOnLS = dag.add(
        "CPort2DOWNUsbphyTurnOnLS", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort2DOWNUsbphyTurnOnLS", --TestName
            ["portIdentifier"] = "CPort2DOWN" --PortIdentifier
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

    CPort2DOWNUsbphyTurnOffLS = dag.add(
        "CPort2DOWNUsbphyTurnOffLS", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort2DOWNUsbphyTurnOffLS", --TestName
            ["portIdentifier"] = "CPort2DOWN" --PortIdentifier
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

    CPort2DOWNUSBCFSTestBoxModeSwitch = dag.add(
        "CPort2DOWNUSBCFSTestBoxModeSwitch", --Burgundy Test Name
        "AriesUSBCUsbSwitchTest.lua", --Action file
        {"titaniumCPort2DOWN"}, --plugins
        {
            ["TestName"] = "CPort2DOWNUSBCFSTestBoxModeSwitch", --TestName
            ["portIdentifier"] = "CPort2DOWN" --PortIdentifier
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

    CPort2DOWNUsbphyTurnOnFS = dag.add(
        "CPort2DOWNUsbphyTurnOnFS", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort2DOWNUsbphyTurnOnFS", --TestName
            ["portIdentifier"] = "CPort2DOWN" --PortIdentifier
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

    CPort2DOWNUsbphyTurnOffFS = dag.add(
        "CPort2DOWNUsbphyTurnOffFS", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort2DOWNUsbphyTurnOffFS", --TestName
            ["portIdentifier"] = "CPort2DOWN" --PortIdentifier
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

    CPort2DOWNUSBCHSTestBoxModeSwitch = dag.add(
        "CPort2DOWNUSBCHSTestBoxModeSwitch", --Burgundy Test Name
        "AriesUSBCUsbSwitchTest.lua", --Action file
        {"titaniumCPort2DOWN"}, --plugins
        {
            ["TestName"] = "CPort2DOWNUSBCHSTestBoxModeSwitch", --TestName
            ["portIdentifier"] = "CPort2DOWN" --PortIdentifier
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

    CPort2DOWNUsbphyTurnOnHS = dag.add(
        "CPort2DOWNUsbphyTurnOnHS", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort2DOWNUsbphyTurnOnHS", --TestName
            ["portIdentifier"] = "CPort2DOWN" --PortIdentifier
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

    CPort2DOWNUsbphyTurnOffHS = dag.add(
        "CPort2DOWNUsbphyTurnOffHS", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort2DOWNUsbphyTurnOffHS", --TestName
            ["portIdentifier"] = "CPort2DOWN" --PortIdentifier
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

    CPort2DOWNUSBCTestboxUsb2HubDisable = dag.add(
        "CPort2DOWNUSBCTestboxUsb2HubDisable", --Burgundy Test Name
        "AriesUSBCUsb2HubPathSelectTest.lua", --Action file
        {"titaniumCPort2DOWN"}, --plugins
        {
            ["TestName"] = "CPort2DOWNUSBCTestboxUsb2HubDisable", --TestName
            ["portIdentifier"] = "CPort2DOWN" --PortIdentifier
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

    CPort2DOWNUsbphyTurnOnSS = dag.add(
        "CPort2DOWNUsbphyTurnOnSS", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort2DOWNUsbphyTurnOnSS", --TestName
            ["portIdentifier"] = "CPort2DOWN" --PortIdentifier
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

    CPort2DOWNUSBCSSTestBoxModeSwitch = dag.add(
        "CPort2DOWNUSBCSSTestBoxModeSwitch", --Burgundy Test Name
        "AriesUSBCUsbSwitchTest.lua", --Action file
        {"titaniumCPort2DOWN"}, --plugins
        {
            ["TestName"] = "CPort2DOWNUSBCSSTestBoxModeSwitch", --TestName
            ["portIdentifier"] = "CPort2DOWN" --PortIdentifier
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

    CPort2DOWNUsbphyTurnOffSS = dag.add(
        "CPort2DOWNUsbphyTurnOffSS", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort2DOWNUsbphyTurnOffSS", --TestName
            ["portIdentifier"] = "CPort2DOWN" --PortIdentifier
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

    CPort2DOWNUsbphyTurnOnSSP = dag.add(
        "CPort2DOWNUsbphyTurnOnSSP", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort2DOWNUsbphyTurnOnSSP", --TestName
            ["portIdentifier"] = "CPort2DOWN" --PortIdentifier
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

    CPort2DOWNUSBCSSPTestBoxModeSwitch = dag.add(
        "CPort2DOWNUSBCSSPTestBoxModeSwitch", --Burgundy Test Name
        "AriesUSBCUsbSwitchTest.lua", --Action file
        {"titaniumCPort2DOWN"}, --plugins
        {
            ["TestName"] = "CPort2DOWNUSBCSSPTestBoxModeSwitch", --TestName
            ["portIdentifier"] = "CPort2DOWN" --PortIdentifier
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

    CPort2DOWNUsbphyTurnOffSSP = dag.add(
        "CPort2DOWNUsbphyTurnOffSSP", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort2DOWNUsbphyTurnOffSSP", --TestName
            ["portIdentifier"] = "CPort2DOWN" --PortIdentifier
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

    CPort2DOWNUSBCVbusLoadTest = dag.add(
        "CPort2DOWNUSBCVbusLoadTest", --Burgundy Test Name
        "USBCVbusLoadTest.lua", --Action file
        {"titaniumCPort2DOWN"}, --plugins
        {
            ["TestName"] = "CPort2DOWNUSBCVbusLoadTest", --TestName
            ["portIdentifier"] = "CPort2DOWN" --PortIdentifier
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

    CPort2DOWNUSBCVconnLoadTest = dag.add(
        "CPort2DOWNUSBCVconnLoadTest", --Burgundy Test Name
        "USBCVconnLoadTest.lua", --Action file
        {"titaniumCPort2DOWN"}, --plugins
        {
            ["TestName"] = "CPort2DOWNUSBCVconnLoadTest", --TestName
            ["portIdentifier"] = "CPort2DOWN" --PortIdentifier
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

    CPort2UPUSBCTestboxUsb2HubEnable = dag.add(
        "CPort2UPUSBCTestboxUsb2HubEnable", --Burgundy Test Name
        "AriesUSBCUsb2HubPathSelectTest.lua", --Action file
        {"titaniumCPort2UP"}, --plugins
        {
            ["TestName"] = "CPort2UPUSBCTestboxUsb2HubEnable", --TestName
            ["portIdentifier"] = "CPort2UP" --PortIdentifier
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

    CPort2UPUSBCLSTestBoxModeSwitch = dag.add(
        "CPort2UPUSBCLSTestBoxModeSwitch", --Burgundy Test Name
        "AriesUSBCUsbSwitchTest.lua", --Action file
        {"titaniumCPort2UP"}, --plugins
        {
            ["TestName"] = "CPort2UPUSBCLSTestBoxModeSwitch", --TestName
            ["portIdentifier"] = "CPort2UP" --PortIdentifier
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

    CPort2UPUsbphyTurnOnLS = dag.add(
        "CPort2UPUsbphyTurnOnLS", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort2UPUsbphyTurnOnLS", --TestName
            ["portIdentifier"] = "CPort2UP" --PortIdentifier
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

    CPort2UPUsbphyTurnOffLS = dag.add(
        "CPort2UPUsbphyTurnOffLS", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort2UPUsbphyTurnOffLS", --TestName
            ["portIdentifier"] = "CPort2UP" --PortIdentifier
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

    CPort2UPUSBCFSTestBoxModeSwitch = dag.add(
        "CPort2UPUSBCFSTestBoxModeSwitch", --Burgundy Test Name
        "AriesUSBCUsbSwitchTest.lua", --Action file
        {"titaniumCPort2UP"}, --plugins
        {
            ["TestName"] = "CPort2UPUSBCFSTestBoxModeSwitch", --TestName
            ["portIdentifier"] = "CPort2UP" --PortIdentifier
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

    CPort2UPUsbphyTurnOnFS = dag.add(
        "CPort2UPUsbphyTurnOnFS", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort2UPUsbphyTurnOnFS", --TestName
            ["portIdentifier"] = "CPort2UP" --PortIdentifier
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

    CPort2UPUsbphyTurnOffFS = dag.add(
        "CPort2UPUsbphyTurnOffFS", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort2UPUsbphyTurnOffFS", --TestName
            ["portIdentifier"] = "CPort2UP" --PortIdentifier
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

    CPort2UPUSBCHSTestBoxModeSwitch = dag.add(
        "CPort2UPUSBCHSTestBoxModeSwitch", --Burgundy Test Name
        "AriesUSBCUsbSwitchTest.lua", --Action file
        {"titaniumCPort2UP"}, --plugins
        {
            ["TestName"] = "CPort2UPUSBCHSTestBoxModeSwitch", --TestName
            ["portIdentifier"] = "CPort2UP" --PortIdentifier
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

    CPort2UPUsbphyTurnOnHS = dag.add(
        "CPort2UPUsbphyTurnOnHS", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort2UPUsbphyTurnOnHS", --TestName
            ["portIdentifier"] = "CPort2UP" --PortIdentifier
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

    CPort2UPUsbphyTurnOffHS = dag.add(
        "CPort2UPUsbphyTurnOffHS", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort2UPUsbphyTurnOffHS", --TestName
            ["portIdentifier"] = "CPort2UP" --PortIdentifier
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

    CPort2UPUSBCTestboxUsb2HubDisable = dag.add(
        "CPort2UPUSBCTestboxUsb2HubDisable", --Burgundy Test Name
        "AriesUSBCUsb2HubPathSelectTest.lua", --Action file
        {"titaniumCPort2UP"}, --plugins
        {
            ["TestName"] = "CPort2UPUSBCTestboxUsb2HubDisable", --TestName
            ["portIdentifier"] = "CPort2UP" --PortIdentifier
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

    CPort2UPUsbphyTurnOnSS = dag.add(
        "CPort2UPUsbphyTurnOnSS", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort2UPUsbphyTurnOnSS", --TestName
            ["portIdentifier"] = "CPort2UP" --PortIdentifier
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

    CPort2UPUSBCSSTestBoxModeSwitch = dag.add(
        "CPort2UPUSBCSSTestBoxModeSwitch", --Burgundy Test Name
        "AriesUSBCUsbSwitchTest.lua", --Action file
        {"titaniumCPort2UP"}, --plugins
        {
            ["TestName"] = "CPort2UPUSBCSSTestBoxModeSwitch", --TestName
            ["portIdentifier"] = "CPort2UP" --PortIdentifier
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

    CPort2UPUsbphyTurnOffSS = dag.add(
        "CPort2UPUsbphyTurnOffSS", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort2UPUsbphyTurnOffSS", --TestName
            ["portIdentifier"] = "CPort2UP" --PortIdentifier
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

    CPort2UPUsbphyTurnOnSSP = dag.add(
        "CPort2UPUsbphyTurnOnSSP", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort2UPUsbphyTurnOnSSP", --TestName
            ["portIdentifier"] = "CPort2UP" --PortIdentifier
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

    CPort2UPUSBCSSPTestBoxModeSwitch = dag.add(
        "CPort2UPUSBCSSPTestBoxModeSwitch", --Burgundy Test Name
        "AriesUSBCUsbSwitchTest.lua", --Action file
        {"titaniumCPort2UP"}, --plugins
        {
            ["TestName"] = "CPort2UPUSBCSSPTestBoxModeSwitch", --TestName
            ["portIdentifier"] = "CPort2UP" --PortIdentifier
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

    CPort2UPUsbphyTurnOffSSP = dag.add(
        "CPort2UPUsbphyTurnOffSSP", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort2UPUsbphyTurnOffSSP", --TestName
            ["portIdentifier"] = "CPort2UP" --PortIdentifier
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

    CPort2SwitchTestBoxNativeDP = dag.add(
        "CPort2SwitchTestBoxNativeDP", --Burgundy Test Name
        "TBTModeSwitchTest.lua", --Action file
        {"titaniumCPort2UP"}, --plugins
        {
            ["TestName"] = "CPort2SwitchTestBoxNativeDP", --TestName
            ["portIdentifier"] = "CPort2UP" --PortIdentifier
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

    CPort2DPHBR3DisplayPattern = dag.add(
        "CPort2DPHBR3DisplayPattern", --Burgundy Test Name
        "TaurusUSBCDisplayPatternTest.lua", --Action file
        {"titaniumCPort2UP","dut"}, --plugins
        {
            ["TestName"] = "CPort2DPHBR3DisplayPattern", --TestName
            ["portIdentifier"] = "CPort2UP" --PortIdentifier
        } 
    )

    CPort0UPUsbphyTurnOffDP = dag.add(
        "CPort0UPUsbphyTurnOffDP", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort0UPUsbphyTurnOffDP", --TestName
            ["portIdentifier"] = "CPort0UP" --PortIdentifier
        } 
    )

    CPort1UPUsbphyTurnOffDP = dag.add(
        "CPort1UPUsbphyTurnOffDP", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort1UPUsbphyTurnOffDP", --TestName
            ["portIdentifier"] = "CPort1UP" --PortIdentifier
        } 
    )

    CPort2UPUsbphyTurnOffDP = dag.add(
        "CPort2UPUsbphyTurnOffDP", --Burgundy Test Name
        "SendCommandToDUT.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort2UPUsbphyTurnOffDP", --TestName
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

    CPort2DPTunnelDisplayPattern = dag.add(
        "CPort2DPTunnelDisplayPattern", --Burgundy Test Name
        "TaurusUSBCDisplayPatternTest.lua", --Action file
        {"titaniumCPort2UP","dut"}, --plugins
        {
            ["TestName"] = "CPort2DPTunnelDisplayPattern", --TestName
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

    CPort2CIO20GR2DRetimerEyeTest = dag.add(
        "CPort2CIO20GR2DRetimerEyeTest", --Burgundy Test Name
        "TaurusRetimerEyeTest.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort2CIO20GR2DRetimerEyeTest", --TestName
            ["portIdentifier"] = "CPort2UP" --PortIdentifier
        } 
    )

    CPort2CIO20GD2RRetimerEyeTest = dag.add(
        "CPort2CIO20GD2RRetimerEyeTest", --Burgundy Test Name
        "TaurusRetimerEyeTest.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "CPort2CIO20GD2RRetimerEyeTest", --TestName
            ["portIdentifier"] = "CPort2UP" --PortIdentifier
        } 
    )

    -- -- CPort0CIO20GHostEyeTest = dag.add(
    -- --     "CPort0CIO20GHostEyeTest", --Burgundy Test Name
    -- --     "TaurusHostEyeTest.lua", --Action file
    -- --     {"dut"}, --plugins
    -- --     {
    -- --         ["TestName"] = "CPort0CIO20GHostEyeTest", --TestName
    -- --         ["portIdentifier"] = "CPort0UP" --PortIdentifier
    -- --     } 
    -- -- )

    -- -- CPort1CIO20GHostEyeTest = dag.add(
    -- --     "CPort1CIO20GHostEyeTest", --Burgundy Test Name
    -- --     "TaurusHostEyeTest.lua", --Action file
    -- --     {"dut"}, --plugins
    -- --     {
    -- --         ["TestName"] = "CPort1CIO20GHostEyeTest", --TestName
    -- --         ["portIdentifier"] = "CPort1UP" --PortIdentifier
    -- --     } 
    -- -- )

    -- -- SystemUPTBTThroughput = dag.add(
    -- --     "SystemUPTBTThroughput", --Burgundy Test Name
    -- --     "TBTThroughputTest.lua", --Action file
    -- --     {"dut"}, --plugins
    -- --     {
    -- --         ["TestName"] = "SystemUPTBTThroughput", --TestName
    -- --         ["portIdentifier"] = "SystemUP" --PortIdentifier
    -- --     } 
    -- -- )

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

    CPort2UPUSBCVconnLoadTest = dag.add(
        "CPort2UPUSBCVconnLoadTest", --Burgundy Test Name
        "USBCVconnLoadTest.lua", --Action file
        {"titaniumCPort2UP"}, --plugins
        {
            ["TestName"] = "CPort2UPUSBCVconnLoadTest", --TestName
            ["portIdentifier"] = "CPort2UP" --PortIdentifier
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

    CPort1UPUSBCAdapterVoltageTest20V = dag.add(
        "CPort1UPUSBCAdapterVoltageTest20V", --Burgundy Test Name
        "USBCAdapterVoltageTest.lua", --Action file
        {"titaniumCPort1UP","dut"}, --plugins
        {
            ["TestName"] = "CPort1UPUSBCAdapterVoltageTest20V", --TestName
            ["portIdentifier"] = "CPort1UP" --PortIdentifier
        } 
    )

    CPort2UPUSBCAdapterVoltageTest5V = dag.add(
        "CPort2UPUSBCAdapterVoltageTest5V", --Burgundy Test Name
        "USBCAdapterVoltageTest.lua", --Action file
        {"titaniumCPort2UP","dut"}, --plugins
        {
            ["TestName"] = "CPort2UPUSBCAdapterVoltageTest5V", --TestName
            ["portIdentifier"] = "CPort2UP" --PortIdentifier
        } 
    )


    CPort2UPUSBCAdapterVoltageTest9V = dag.add(
        "CPort2UPUSBCAdapterVoltageTest9V", --Burgundy Test Name
        "USBCAdapterVoltageTest.lua", --Action file
        {"titaniumCPort2UP","dut"}, --plugins
        {
            ["TestName"] = "CPort2UPUSBCAdapterVoltageTest9V", --TestName
            ["portIdentifier"] = "CPort2UP" --PortIdentifier
        } 
    )

    CPort2UPUSBCAdapterVoltageTest15V = dag.add(
        "CPort2UPUSBCAdapterVoltageTest15V", --Burgundy Test Name
        "USBCAdapterVoltageTest.lua", --Action file
        {"titaniumCPort2UP","dut"}, --plugins
        {
            ["TestName"] = "CPort2UPUSBCAdapterVoltageTest15V", --TestName
            ["portIdentifier"] = "CPort2UP" --PortIdentifier
        } 
    )

    CPort2UPUSBCAdapterVoltageTest20V = dag.add(
        "CPort2UPUSBCAdapterVoltageTest20V", --Burgundy Test Name
        "USBCAdapterVoltageTest.lua", --Action file
        {"titaniumCPort2UP","dut"}, --plugins
        {
            ["TestName"] = "CPort2UPUSBCAdapterVoltageTest20V", --TestName
            ["portIdentifier"] = "CPort2UP" --PortIdentifier
        } 
    )

     SystemReset = dag.add(
         "SystemReset", --Burgundy Test Name
         "SendCommandToDUT.lua", --Action file
         {"dut"}, --plugins
         {
             ["TestName"] = "SystemReset", --TestName
             ["portIdentifier"] = "System" --PortIdentifier
         } 
     )

    -- HDMIWAResetMedea = dag.add(
    --     "HDMIWAResetMedea", --Burgundy Test Name
    --     "SendCommandToDUT.lua", --Action file
    --     {"dut"}, --plugins
    --     {
    --         ["TestName"] = "HDMIWAResetMedea", --TestName
    --         ["portIdentifier"] = "System" --PortIdentifier
    --     } 
    -- )

    -- HDMIDisplayPattern = dag.add(
    --     "HDMIDisplayPattern", --Burgundy Test Name
    --     "HDMIDisplayPatternTest.lua", --Action file
    --     {"titaniumHDMI","dut"}, --plugins
    --     {
    --         ["TestName"] = "HDMIDisplayPattern", --TestName
    --         ["portIdentifier"] = "HDMI" --PortIdentifier
    --     } 
    -- )

    DUTCleanup = dag.add(
        "DUTCleanup", --Burgundy Test Name
        "J316DutIOCleanup.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "DUTCleanup", --TestName
            ["portIdentifier"] = "System" --PortIdentifier
        } 
    )

    SystemUPTBTThroughput = dag.add(
        "SystemUPTBTThroughput", --Burgundy Test Name
        "TBTThroughputTest.lua", --Action file
        {"dut"}, --plugins
        {
            ["TestName"] = "SystemUPTBTThroughput", --TestName
            ["portIdentifier"] = "SystemUP" --PortIdentifier
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

    dag.order(DUTInitialization, CPort0TitaniumFWCheck)
    dag.order(DUTInitialization, CPort1TitaniumFWCheck)
    dag.order(DUTInitialization, CPort2TitaniumFWCheck)

    dag.order(DUTInitialization, CPort0CaesiumFWCheck)
    dag.order(DUTInitialization, CPort1CaesiumFWCheck)
    dag.order(DUTInitialization, CPort2CaesiumFWCheck)


    dag.order(CPort0TitaniumFWCheck, SystemDOWNBatteryDrainTest)
    dag.order(CPort1TitaniumFWCheck, SystemDOWNBatteryDrainTest)
    dag.order(CPort2TitaniumFWCheck, SystemDOWNBatteryDrainTest)

    dag.order(CPort0CaesiumFWCheck, SystemDOWNBatteryDrainTest)
    dag.order(CPort1CaesiumFWCheck, SystemDOWNBatteryDrainTest)
    dag.order(CPort2CaesiumFWCheck, SystemDOWNBatteryDrainTest)

    dag.order(SystemDOWNBatteryDrainTest, CPort0DOWNPortOrientationCheck)

    dag.order(CPort0DOWNPortOrientationCheck, CPort1DOWNPortOrientationCheck)



    dag.order(CPort1DOWNPortOrientationCheck, CPort0DOWNUSBCTestboxUsb2HubEnable)
    dag.order(CPort1DOWNPortOrientationCheck, CPort1DOWNUSBCTestboxUsb2HubEnable)
    dag.order(CPort1DOWNPortOrientationCheck, CPort2DOWNUSBCTestboxUsb2HubEnable)

    dag.order(CPort0DOWNUSBCTestboxUsb2HubEnable, CPort0DOWNUSBCLSTestBoxModeSwitch)
    dag.order(CPort1DOWNUSBCTestboxUsb2HubEnable, CPort1DOWNUSBCLSTestBoxModeSwitch)
    dag.order(CPort2DOWNUSBCTestboxUsb2HubEnable, CPort2DOWNUSBCLSTestBoxModeSwitch)
 
    dag.order(CPort0DOWNUSBCLSTestBoxModeSwitch, CPort0DOWNUsbphyTurnOnLS)
    dag.order(CPort1DOWNUSBCLSTestBoxModeSwitch, CPort0DOWNUsbphyTurnOnLS)
    dag.order(CPort2DOWNUSBCLSTestBoxModeSwitch, CPort0DOWNUsbphyTurnOnLS)

    dag.order(CPort0DOWNUsbphyTurnOnLS, CPort1DOWNUsbphyTurnOnLS)
    dag.order(CPort1DOWNUsbphyTurnOnLS, CPort2DOWNUsbphyTurnOnLS)

    dag.order(CPort2DOWNUsbphyTurnOnLS, SystemDOWNUSBLSPresenceDUTCheck)
    dag.order(SystemDOWNUSBLSPresenceDUTCheck, CPort0DOWNUsbphyTurnOffLS)
    dag.order(CPort0DOWNUsbphyTurnOffLS, CPort1DOWNUsbphyTurnOffLS)
    dag.order(CPort1DOWNUsbphyTurnOffLS, CPort2DOWNUsbphyTurnOffLS)


    dag.order(CPort2DOWNUsbphyTurnOffLS, CPort0DOWNUSBCFSTestBoxModeSwitch)
    dag.order(CPort2DOWNUsbphyTurnOffLS, CPort1DOWNUSBCFSTestBoxModeSwitch)
    dag.order(CPort2DOWNUsbphyTurnOffLS, CPort2DOWNUSBCFSTestBoxModeSwitch)

    dag.order(CPort0DOWNUSBCFSTestBoxModeSwitch, CPort0DOWNUsbphyTurnOnFS)
    dag.order(CPort1DOWNUSBCFSTestBoxModeSwitch, CPort0DOWNUsbphyTurnOnFS)
    dag.order(CPort2DOWNUSBCFSTestBoxModeSwitch, CPort0DOWNUsbphyTurnOnFS)

    dag.order(CPort0DOWNUsbphyTurnOnFS, CPort1DOWNUsbphyTurnOnFS)
    dag.order(CPort1DOWNUsbphyTurnOnFS, CPort2DOWNUsbphyTurnOnFS)

    dag.order(CPort2DOWNUsbphyTurnOnFS, SystemDOWNUSBFSPresenceDUTCheck)
    dag.order(SystemDOWNUSBFSPresenceDUTCheck, CPort0DOWNUsbphyTurnOffFS)
    dag.order(CPort0DOWNUsbphyTurnOffFS, CPort1DOWNUsbphyTurnOffFS)
    dag.order(CPort1DOWNUsbphyTurnOffFS, CPort2DOWNUsbphyTurnOffFS)
 

    dag.order(CPort2DOWNUsbphyTurnOffFS, CPort0DOWNUSBCHSTestBoxModeSwitch)
    dag.order(CPort2DOWNUsbphyTurnOffFS, CPort1DOWNUSBCHSTestBoxModeSwitch)
    dag.order(CPort2DOWNUsbphyTurnOffFS, CPort2DOWNUSBCHSTestBoxModeSwitch)

    dag.order(CPort0DOWNUSBCHSTestBoxModeSwitch, CPort0DOWNUsbphyTurnOnHS)
    dag.order(CPort1DOWNUSBCHSTestBoxModeSwitch, CPort0DOWNUsbphyTurnOnHS)
    dag.order(CPort2DOWNUSBCHSTestBoxModeSwitch, CPort0DOWNUsbphyTurnOnHS)

    dag.order(CPort0DOWNUsbphyTurnOnHS, CPort1DOWNUsbphyTurnOnHS)
    dag.order(CPort1DOWNUsbphyTurnOnHS, CPort2DOWNUsbphyTurnOnHS)

    dag.order(CPort2DOWNUsbphyTurnOnHS, SystemDOWNUSBHSThroughput)
    dag.order(SystemDOWNUSBHSThroughput, CPort0DOWNUsbphyTurnOffHS)
    dag.order(CPort0DOWNUsbphyTurnOffHS, CPort1DOWNUsbphyTurnOffHS)
    dag.order(CPort1DOWNUsbphyTurnOffHS, CPort2DOWNUsbphyTurnOffHS)


    dag.order(CPort2DOWNUsbphyTurnOffHS, CPort0DOWNUSBCTestboxUsb2HubDisable)
    dag.order(CPort2DOWNUsbphyTurnOffHS, CPort1DOWNUSBCTestboxUsb2HubDisable)
    dag.order(CPort2DOWNUsbphyTurnOffHS, CPort2DOWNUSBCTestboxUsb2HubDisable)

    dag.order(CPort0DOWNUSBCTestboxUsb2HubDisable, CPort0DOWNUsbphyTurnOnSS)
    dag.order(CPort1DOWNUSBCTestboxUsb2HubDisable, CPort0DOWNUsbphyTurnOnSS)
    dag.order(CPort2DOWNUSBCTestboxUsb2HubDisable, CPort0DOWNUsbphyTurnOnSS)

    dag.order(CPort0DOWNUsbphyTurnOnSS, CPort1DOWNUsbphyTurnOnSS)
    dag.order(CPort1DOWNUsbphyTurnOnSS, CPort2DOWNUsbphyTurnOnSS)

    dag.order(CPort2DOWNUsbphyTurnOnSS, CPort0DOWNUSBCSSTestBoxModeSwitch)
    dag.order(CPort2DOWNUsbphyTurnOnSS, CPort1DOWNUSBCSSTestBoxModeSwitch)
    dag.order(CPort2DOWNUsbphyTurnOnSS, CPort2DOWNUSBCSSTestBoxModeSwitch)

    dag.order(CPort0DOWNUSBCSSTestBoxModeSwitch, SystemDOWNUSBSSPresenceDUTCheck)
    dag.order(CPort1DOWNUSBCSSTestBoxModeSwitch, SystemDOWNUSBSSPresenceDUTCheck)
    dag.order(CPort2DOWNUSBCSSTestBoxModeSwitch, SystemDOWNUSBSSPresenceDUTCheck)

    dag.order(SystemDOWNUSBSSPresenceDUTCheck, CPort0DOWNUsbphyTurnOffSS)
    dag.order(CPort0DOWNUsbphyTurnOffSS, CPort1DOWNUsbphyTurnOffSS)
    dag.order(CPort1DOWNUsbphyTurnOffSS, CPort2DOWNUsbphyTurnOffSS)


    dag.order(CPort2DOWNUsbphyTurnOffSS, CPort0DOWNUsbphyTurnOnSSP)
    dag.order(CPort0DOWNUsbphyTurnOnSSP, CPort1DOWNUsbphyTurnOnSSP)
    dag.order(CPort1DOWNUsbphyTurnOnSSP, CPort2DOWNUsbphyTurnOnSSP)

    dag.order(CPort2DOWNUsbphyTurnOnSSP, CPort0DOWNUSBCSSPTestBoxModeSwitch)
    dag.order(CPort2DOWNUsbphyTurnOnSSP, CPort1DOWNUSBCSSPTestBoxModeSwitch)
    dag.order(CPort2DOWNUsbphyTurnOnSSP, CPort2DOWNUSBCSSPTestBoxModeSwitch)

    dag.order(CPort0DOWNUSBCSSPTestBoxModeSwitch, SystemDOWNUSBSSPPresenceDUTCheck)
    dag.order(CPort1DOWNUSBCSSPTestBoxModeSwitch, SystemDOWNUSBSSPPresenceDUTCheck)
    dag.order(CPort2DOWNUSBCSSPTestBoxModeSwitch, SystemDOWNUSBSSPPresenceDUTCheck)

    dag.order(SystemDOWNUSBSSPPresenceDUTCheck, CPort0DOWNUsbphyTurnOffSSP)
    dag.order(CPort0DOWNUsbphyTurnOffSSP, CPort1DOWNUsbphyTurnOffSSP)
    dag.order(CPort1DOWNUsbphyTurnOffSSP, CPort2DOWNUsbphyTurnOffSSP)


    dag.order(CPort2DOWNUsbphyTurnOffSSP, CPort0DOWNUSBCVbusLoadTest)
    dag.order(CPort0DOWNUSBCVbusLoadTest, CPort1DOWNUSBCVbusLoadTest)
    dag.order(CPort1DOWNUSBCVbusLoadTest, CPort2DOWNUSBCVbusLoadTest)
    dag.order(CPort2DOWNUSBCVbusLoadTest, CPort0DOWNUSBCVconnLoadTest)
    dag.order(CPort2DOWNUSBCVbusLoadTest, CPort1DOWNUSBCVconnLoadTest)
    dag.order(CPort2DOWNUSBCVbusLoadTest, CPort2DOWNUSBCVconnLoadTest)


    dag.order(CPort0DOWNUSBCVconnLoadTest, CPort0UPPortOrientationCheck)
    dag.order(CPort1DOWNUSBCVconnLoadTest, CPort0UPPortOrientationCheck)
    dag.order(CPort2DOWNUSBCVconnLoadTest, CPort0UPPortOrientationCheck)

    dag.order(CPort0UPPortOrientationCheck, CPort1UPPortOrientationCheck)
    dag.order(CPort1UPPortOrientationCheck, CPort2UPPortOrientationCheck)


    dag.order(CPort2UPPortOrientationCheck, CPort0UPUSBCTestboxUsb2HubEnable)
    dag.order(CPort2UPPortOrientationCheck, CPort1UPUSBCTestboxUsb2HubEnable)
    dag.order(CPort2UPPortOrientationCheck, CPort2UPUSBCTestboxUsb2HubEnable)

    dag.order(CPort0UPUSBCTestboxUsb2HubEnable, CPort0UPUSBCLSTestBoxModeSwitch)
    dag.order(CPort1UPUSBCTestboxUsb2HubEnable, CPort1UPUSBCLSTestBoxModeSwitch)
    dag.order(CPort2UPUSBCTestboxUsb2HubEnable, CPort2UPUSBCLSTestBoxModeSwitch)

    dag.order(CPort0UPUSBCLSTestBoxModeSwitch, CPort0UPUsbphyTurnOnLS)
    dag.order(CPort1UPUSBCLSTestBoxModeSwitch, CPort0UPUsbphyTurnOnLS)
    dag.order(CPort2UPUSBCLSTestBoxModeSwitch, CPort0UPUsbphyTurnOnLS)

    dag.order(CPort0UPUsbphyTurnOnLS, CPort1UPUsbphyTurnOnLS)
    dag.order(CPort1UPUsbphyTurnOnLS, CPort2UPUsbphyTurnOnLS)

    dag.order(CPort2UPUsbphyTurnOnLS, SystemUPUSBLSPresenceDUTCheck)
    dag.order(SystemUPUSBLSPresenceDUTCheck, CPort0UPUsbphyTurnOffLS)
    dag.order(CPort0UPUsbphyTurnOffLS, CPort1UPUsbphyTurnOffLS)
    dag.order(CPort1UPUsbphyTurnOffLS, CPort2UPUsbphyTurnOffLS)

    dag.order(CPort2UPUsbphyTurnOffLS, CPort0UPUSBCFSTestBoxModeSwitch)
    dag.order(CPort2UPUsbphyTurnOffLS, CPort1UPUSBCFSTestBoxModeSwitch)
    dag.order(CPort2UPUsbphyTurnOffLS, CPort2UPUSBCFSTestBoxModeSwitch)

    dag.order(CPort0UPUSBCFSTestBoxModeSwitch, CPort0UPUsbphyTurnOnFS)
    dag.order(CPort1UPUSBCFSTestBoxModeSwitch, CPort0UPUsbphyTurnOnFS)
    dag.order(CPort2UPUSBCFSTestBoxModeSwitch, CPort0UPUsbphyTurnOnFS)

    dag.order(CPort0UPUsbphyTurnOnFS, CPort1UPUsbphyTurnOnFS)
    dag.order(CPort1UPUsbphyTurnOnFS, CPort2UPUsbphyTurnOnFS)

    dag.order(CPort2UPUsbphyTurnOnFS, SystemUPUSBFSPresenceDUTCheck)
    dag.order(SystemUPUSBFSPresenceDUTCheck, CPort0UPUsbphyTurnOffFS)
    dag.order(CPort0UPUsbphyTurnOffFS, CPort1UPUsbphyTurnOffFS)
    dag.order(CPort1UPUsbphyTurnOffFS, CPort2UPUsbphyTurnOffFS)


    dag.order(CPort2UPUsbphyTurnOffFS, CPort0UPUSBCHSTestBoxModeSwitch)
    dag.order(CPort2UPUsbphyTurnOffFS, CPort1UPUSBCHSTestBoxModeSwitch)
    dag.order(CPort2UPUsbphyTurnOffFS, CPort2UPUSBCHSTestBoxModeSwitch)

    dag.order(CPort0UPUSBCHSTestBoxModeSwitch, CPort0UPUsbphyTurnOnHS)
    dag.order(CPort1UPUSBCHSTestBoxModeSwitch, CPort0UPUsbphyTurnOnHS)
    dag.order(CPort2UPUSBCHSTestBoxModeSwitch, CPort0UPUsbphyTurnOnHS)

    dag.order(CPort0UPUsbphyTurnOnHS, CPort1UPUsbphyTurnOnHS)
    dag.order(CPort1UPUsbphyTurnOnHS, CPort2UPUsbphyTurnOnHS)

    dag.order(CPort2UPUsbphyTurnOnHS, SystemUPUSBHSThroughput)
    dag.order(SystemUPUSBHSThroughput, CPort0UPUsbphyTurnOffHS)
    dag.order(CPort0UPUsbphyTurnOffHS, CPort1UPUsbphyTurnOffHS)
    dag.order(CPort1UPUsbphyTurnOffHS, CPort2UPUsbphyTurnOffHS)


    dag.order(CPort2UPUsbphyTurnOffHS, CPort0UPUSBCTestboxUsb2HubDisable)
    dag.order(CPort2UPUsbphyTurnOffHS, CPort1UPUSBCTestboxUsb2HubDisable)
    dag.order(CPort2UPUsbphyTurnOffHS, CPort2UPUSBCTestboxUsb2HubDisable)

    dag.order(CPort0UPUSBCTestboxUsb2HubDisable, CPort0UPUsbphyTurnOnSS)
    dag.order(CPort1UPUSBCTestboxUsb2HubDisable, CPort0UPUsbphyTurnOnSS)
    dag.order(CPort2UPUSBCTestboxUsb2HubDisable, CPort0UPUsbphyTurnOnSS)

    dag.order(CPort0UPUsbphyTurnOnSS, CPort1UPUsbphyTurnOnSS)
    dag.order(CPort1UPUsbphyTurnOnSS, CPort2UPUsbphyTurnOnSS)

    dag.order(CPort2UPUsbphyTurnOnSS, CPort0UPUSBCSSTestBoxModeSwitch)
    dag.order(CPort2UPUsbphyTurnOnSS, CPort1UPUSBCSSTestBoxModeSwitch)
    dag.order(CPort2UPUsbphyTurnOnSS, CPort2UPUSBCSSTestBoxModeSwitch)

    dag.order(CPort0UPUSBCSSTestBoxModeSwitch, SystemUPUSBSSPresenceDUTCheck)
    dag.order(CPort1UPUSBCSSTestBoxModeSwitch, SystemUPUSBSSPresenceDUTCheck)
    dag.order(CPort2UPUSBCSSTestBoxModeSwitch, SystemUPUSBSSPresenceDUTCheck)

    dag.order(SystemUPUSBSSPresenceDUTCheck, CPort0UPUsbphyTurnOffSS)
    dag.order(CPort0UPUsbphyTurnOffSS, CPort1UPUsbphyTurnOffSS)
    dag.order(CPort1UPUsbphyTurnOffSS, CPort2UPUsbphyTurnOffSS)


    dag.order(CPort2UPUsbphyTurnOffSS, CPort0UPUsbphyTurnOnSSP)
    dag.order(CPort0UPUsbphyTurnOnSSP, CPort1UPUsbphyTurnOnSSP)
    dag.order(CPort1UPUsbphyTurnOnSSP, CPort2UPUsbphyTurnOnSSP)

    dag.order(CPort2UPUsbphyTurnOnSSP, CPort0UPUSBCSSPTestBoxModeSwitch)
    dag.order(CPort2UPUsbphyTurnOnSSP, CPort1UPUSBCSSPTestBoxModeSwitch)
    dag.order(CPort2UPUsbphyTurnOnSSP, CPort2UPUSBCSSPTestBoxModeSwitch)

    dag.order(CPort0UPUSBCSSPTestBoxModeSwitch, SystemUPUSBSSPPresenceDUTCheck)
    dag.order(CPort1UPUSBCSSPTestBoxModeSwitch, SystemUPUSBSSPPresenceDUTCheck)
    dag.order(CPort2UPUSBCSSPTestBoxModeSwitch, SystemUPUSBSSPPresenceDUTCheck)
 
    dag.order(SystemUPUSBSSPPresenceDUTCheck, CPort0UPUsbphyTurnOffSSP)
    dag.order(CPort0UPUsbphyTurnOffSSP, CPort1UPUsbphyTurnOffSSP)
    dag.order(CPort1UPUsbphyTurnOffSSP, CPort2UPUsbphyTurnOffSSP)

--native dp
    dag.order(CPort2UPUsbphyTurnOffSSP, CPort0SwitchTestBoxNativeDP)
    dag.order(CPort2UPUsbphyTurnOffSSP, CPort1SwitchTestBoxNativeDP)
    dag.order(CPort2UPUsbphyTurnOffSSP, CPort2SwitchTestBoxNativeDP)

    dag.order(CPort0SwitchTestBoxNativeDP, CPort0DPHBR3DisplayPattern)
    dag.order(CPort1SwitchTestBoxNativeDP, CPort0DPHBR3DisplayPattern)
    dag.order(CPort2SwitchTestBoxNativeDP, CPort0DPHBR3DisplayPattern)
    dag.order(CPort0DPHBR3DisplayPattern, CPort1DPHBR3DisplayPattern)
    dag.order(CPort1DPHBR3DisplayPattern, CPort2DPHBR3DisplayPattern)

    dag.order(CPort2DPHBR3DisplayPattern, CPort0UPUsbphyTurnOffDP)
    dag.order(CPort0UPUsbphyTurnOffDP, CPort1UPUsbphyTurnOffDP)
    dag.order(CPort1UPUsbphyTurnOffDP, CPort2UPUsbphyTurnOffDP)


--tunnel dp
    dag.order(CPort2UPUsbphyTurnOffDP, CPort0SwitchTestBoxTunnelDP)
    dag.order(CPort2UPUsbphyTurnOffDP, CPort1SwitchTestBoxTunnelDP)
    dag.order(CPort2UPUsbphyTurnOffDP, CPort2SwitchTestBoxTunnelDP)

    dag.order(CPort0SwitchTestBoxTunnelDP, CPort0DPTunnelDisplayPattern)
    dag.order(CPort1SwitchTestBoxTunnelDP, CPort0DPTunnelDisplayPattern)
    dag.order(CPort2SwitchTestBoxTunnelDP, CPort0DPTunnelDisplayPattern)
    dag.order(CPort0DPTunnelDisplayPattern, CPort1DPTunnelDisplayPattern)
    dag.order(CPort1DPTunnelDisplayPattern, CPort2DPTunnelDisplayPattern)  

    dag.order(CPort2DPTunnelDisplayPattern, CPort0UPUsbphyTurnOffTunnelDP)
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
    dag.order(CPort1CIO20GD2RRetimerEyeTest, CPort2CIO20GR2DRetimerEyeTest)
    dag.order(CPort2CIO20GR2DRetimerEyeTest, CPort2CIO20GD2RRetimerEyeTest)
--TBTThroughput
    dag.order(CPort2CIO20GD2RRetimerEyeTest, SystemUPTBTThroughput)

    dag.order(SystemUPTBTThroughput, CPort0UPUSBCVconnLoadTest)
    dag.order(SystemUPTBTThroughput, CPort1UPUSBCVconnLoadTest)
    dag.order(SystemUPTBTThroughput, CPort2UPUSBCVconnLoadTest)

--Adapter Voltage Test
--CPort0 5v->9v->15v->20v
    dag.order(CPort0UPUSBCVconnLoadTest, CPort0UPUSBCAdapterVoltageTest5V)
    dag.order(CPort1UPUSBCVconnLoadTest, CPort0UPUSBCAdapterVoltageTest5V)
    dag.order(CPort2UPUSBCVconnLoadTest, CPort0UPUSBCAdapterVoltageTest5V)
    dag.order(CPort0UPUSBCAdapterVoltageTest5V, CPort0UPUSBCAdapterVoltageTest9V)
    dag.order(CPort0UPUSBCAdapterVoltageTest9V, CPort0UPUSBCAdapterVoltageTest15V)
    dag.order(CPort0UPUSBCAdapterVoltageTest15V, CPort0UPUSBCAdapterVoltageTest20V)

--CPort1 5v->9v->15v->20v
    dag.order(CPort0UPUSBCAdapterVoltageTest20V, CPort1UPUSBCAdapterVoltageTest5V)
    dag.order(CPort1UPUSBCAdapterVoltageTest5V, CPort1UPUSBCAdapterVoltageTest9V)
    dag.order(CPort1UPUSBCAdapterVoltageTest9V, CPort1UPUSBCAdapterVoltageTest15V)
    dag.order(CPort1UPUSBCAdapterVoltageTest15V, CPort1UPUSBCAdapterVoltageTest20V)

--CPort2 5v->9v->15v->20v
    dag.order(CPort1UPUSBCAdapterVoltageTest20V, CPort2UPUSBCAdapterVoltageTest5V)
    dag.order(CPort2UPUSBCAdapterVoltageTest5V, CPort2UPUSBCAdapterVoltageTest9V)
    dag.order(CPort2UPUSBCAdapterVoltageTest9V, CPort2UPUSBCAdapterVoltageTest15V)
    dag.order(CPort2UPUSBCAdapterVoltageTest15V, CPort2UPUSBCAdapterVoltageTest20V)

    -- dag.order(CPort0UPUSBCVconnLoadTest, HDMIWAResetMedea)
    -- dag.order(CPort1UPUSBCVconnLoadTest, HDMIWAResetMedea)
    -- dag.order(HDMIWAResetMedea, HDMIDisplayPattern)
    -- dag.order(HDMIDisplayPattern, EnableUSBAUsbphy)

    dag.order(CPort2UPUSBCAdapterVoltageTest20V, SystemReset)
    dag.order(SystemReset, DUTCleanup)
    
    
end