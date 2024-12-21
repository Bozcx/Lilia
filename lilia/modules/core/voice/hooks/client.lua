﻿function MODULE:PlayerButtonDown(client, button)
    if button == KEY_F2 and IsFirstTimePredicted() then
        local trace = client:GetEyeTrace()
        if IsValid(trace.Entity) and trace.Entity:isDoor() then return end
        local menu = DermaMenu()
        menu:AddOption("Change voice mode to Whispering range.", function()
            netstream.Start("ChangeSpeakMode", "Whispering")
            client:chatNotify("You have changed your voice mode to Whispering!")
        end)

        menu:AddOption("Change voice mode to Talking range.", function()
            netstream.Start("ChangeSpeakMode", "Talking")
            client:chatNotify("You have changed your voice mode to Talking!")
        end)

        menu:AddOption("Change voice mode to Yelling range.", function()
            netstream.Start("ChangeSpeakMode", "Yelling")
            client:chatNotify("You have changed your voice mode to Yelling!")
        end)

        menu:Open()
        menu:MakePopup()
        menu:Center()
    end
end

function MODULE:LoadFonts()
    surface.CreateFont("3DVoiceDebug", {
        font = "Arial",
        size = 14,
        antialias = true,
        weight = 700,
        underline = true,
    })
end