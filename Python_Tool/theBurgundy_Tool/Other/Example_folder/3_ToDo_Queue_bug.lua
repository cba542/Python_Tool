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


    CPort2CaesiumFWCheck = dag.add(
        "CPort2CaesiumFWCheck", --Burgundy Test Name
        "TestBoxVersionTest.lua", --Action file
        {"caesiumCPort2DOWN"}, --plugins
        {
            ["TestName"] = "CPort2CaesiumFWCheck", --TestName
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
    --debug incorrect Queue
    dag.order(CPort2CaesiumFWCheck, CPort2CaesiumFWCheck)

   
    
    
end