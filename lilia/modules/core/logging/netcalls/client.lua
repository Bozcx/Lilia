﻿net.Receive("liaDrawLogs", function()
    local client = LocalPlayer()
    if not client:HasPrivilege("Commands - View Logs") then
        client:notify(":|")
        return
    end

    local logs = net.ReadTable()
    local logFrame = vgui.Create("DFrame")
    logFrame:SetSize(900, 600)
    logFrame:SetTitle("Log Viewer")
    logFrame:Center()
    logFrame:MakePopup()
    local logList = vgui.Create("DListView", logFrame)
    logList:Dock(FILL)
    logList:SetMultiSelect(false)
    logList:AddColumn("Timestamp")
    logList:AddColumn("Log Message")
    for _, logEntry in ipairs(logs) do
        logList:AddLine(logEntry.timestamp, logEntry.message)
    end
end)

net.Receive("liaRequestLogsClient", function()
    local client = LocalPlayer()
    if not client:HasPrivilege("Commands - View Logs") then
        client:notify(":|")
        return
    end

    local logFiles = net.ReadTable()
    local logType = net.ReadString()
    if table.Count(logFiles) <= 0 then
        client:chatNotify("No logs of this type!")
        return
    end

    local datePicker = vgui.Create("DFrame")
    datePicker:SetSize(300, 100)
    datePicker:SetTitle("Select Date")
    datePicker:Center()
    datePicker:MakePopup()
    local dateLabel = vgui.Create("DLabel", datePicker)
    dateLabel:Dock(TOP)
    dateLabel:SetTall(20)
    dateLabel:SetText("Select a Date:")
    local dateDropdown = vgui.Create("DComboBox", datePicker)
    dateDropdown:Dock(TOP)
    dateDropdown:SetTall(25)
    dateDropdown:SetValue(os.date("%x"))
    for _, fileName in pairs(logFiles) do
        dateDropdown:AddChoice(fileName)
    end

    local confirmButton = vgui.Create("DButton", datePicker)
    confirmButton:Dock(BOTTOM)
    confirmButton:SetText("Confirm")
    confirmButton.DoClick = function()
        local selectedDate = dateDropdown:GetValue()
        net.Start("liaRequestLogsServer")
        net.WriteString(logType)
        net.WriteString(selectedDate)
        net.SendToServer()
        datePicker:Close()
    end
end)
