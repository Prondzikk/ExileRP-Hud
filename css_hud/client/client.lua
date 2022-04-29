local Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
    ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

ESX = nil
CreateThread(function()
	local breakMe = 0
    while ESX == nil do
        Wait(100)
		breakMe = breakMe + 1
        TriggerEvent('esx:getSharedObject',function(obj) ESX = obj end)
		if breakMe > 10 then
			break
		end
    end
end)

local directions = {
    N = 360, 0,
    NE = 315,
    E = 270,
    SE = 225,
    S = 180,
    SW = 135,
    W = 90,
    NW = 45
}

function round(value, numDecimalPlaces)
    return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", value))
end

CreateThread(function() 
    while true do
        Wait(5000)
        local expanded = IsBigmapActive()
        local fullMap = IsBigmapFull()
        if expanded or fullMap then
            SetRadarBigmapEnabled(true, false)
            Wait(0)
            SetRadarBigmapEnabled(false, false)
        end    
    end
end)

-- Car Hud

function _DrawRect(X, Y, W, H, R, G, B, A, L)
    SetUiLayer(L)
    DrawRect(X, Y, W, H, R, G, B, A)
end

CreateThread(function() 
    local minimap = RequestScaleformMovie("minimap")
    SetRadarBigmapEnabled(true, false)
    Wait(0)
    SetRadarBigmapEnabled(false, false)
    while true do
        Wait(0)
        BeginScaleformMovieMethod(minimap, "SETUP_HEALTH_ARMOUR")
        ScaleformMovieMethodAddParamInt(3)
        EndScaleformMovieMethod()   
    end    
end)

CreateThread(function()
    while true do
        Wait(0)
        if IsPedInAnyVehicle(PlayerPedId()) and not IsPauseMenuActive() then
            Wait(75)
            local PedCar = GetVehiclePedIsUsing(PlayerPedId(), false)
            carSpeed = math.floor(GetEntitySpeed(PedCar) * 3.6 + 0.5)
            carMaxSpeed = math.ceil(GetVehicleEstimatedMaxSpeed(PedCar) * 3.6 + 0.5)
            carSpeedPercent = carSpeed / carMaxSpeed * 100
            rpm = GetVehicleCurrentRpm(PedCar) * 100

            local eHealth = GetVehicleEngineHealth(PedCar)
            SendNUIMessage({
                speedometer = true,
                speed = carSpeed,
                percent = carSpeedPercent,
                tachometer = true,
                rpmx = rpm,
                gear = GetVehicleCurrentGear(PedCar),
                eHealth = eHealth
            })
        else
            Citizen.Wait(500)
        end 
    end
end)

CreateThread(function()
    while true do
            Wait(450)
            if IsPedInAnyVehicle(PlayerPedId()) and not IsPauseMenuActive() then
                local PedCar = GetVehiclePedIsUsing(PlayerPedId(), false)
                local coords = GetEntityCoords(PlayerPedId())

                local _,b,c = GetVehicleLightsState(PedCar)

                SetMapZoomDataLevel(0, 0.96, 0.9, 0.08, 0.0, 0.0) -- Level 0
                SetMapZoomDataLevel(1, 1.6, 0.9, 0.08, 0.0, 0.0) -- Level 1
                SetMapZoomDataLevel(2, 8.6, 0.9, 0.08, 0.0, 0.0) -- Level 2
                SetMapZoomDataLevel(3, 12.3, 0.9, 0.08, 0.0, 0.0) -- Level 3
                SetMapZoomDataLevel(4, 22.3, 0.9, 0.08, 0.0, 0.0) -- Level 4

                --  Show hud
                SendNUIMessage({
                    showhud = true,
                    stylex = 'classic',
                    showCompass = 'on',
                    lights = 1+b+c,
                    seatbelt = exports['exile_blackout']:pasyState()
                })
            else
                SendNUIMessage({
                    showhud = false
                })
                Wait(2000)
            end   
    end
end)


local hash1, hash2;
CreateThread(function() 
    while true do
            Wait(470)
            local ped, direction = PlayerPedId(), nil
            for k, v in pairs(Config.Directions) do
                direction = GetEntityHeading(ped)
                if math.abs(direction - k) < 22.5 then
                    direction = v
                    break
                end
            end

            local coords = GetEntityCoords(ped, true)
            local zone = GetNameOfZone(coords.x, coords.y, coords.z)
            local zoneLabel = GetLabelText(zone)
            local var1, var2 = GetStreetNameAtCoord(coords.x, coords.y, coords.z, Citizen.ResultAsInteger(), Citizen.ResultAsInteger())
            hash1 = GetStreetNameFromHashKey(var1);
			hash2 = GetStreetNameFromHashKey(var2);

            local street2;
            if (hash2 == '') then
				street2 = zoneLabel;
			else
				street2 = hash2..', '..zoneLabel;
			end

            SendNUIMessage({
                street = street2,
                direction = (direction or 'N')
            })   
    end    
end)

-- Radio jebane
CreateThread(function() 
    while true do
            Wait(2000)
            local data = exports['rp-radio']:GetRadioData()
            if tostring(data[3]) == "0" then
                SendNUIMessage({
                    hideradio = true
                })    
            else
                SendNUIMessage({
                    showradio = true
                })  
            end    
            SendNUIMessage({
                radionumber = data[2],
                radiocount = data[3],
            })  
    end
end)

RegisterCommand("switchhud", function(src,args,raw) 
    SendNUIMessage({
        switchhud = true
    })
    ESX.ShowNotification("~w~Zmieniono tryb hudu")
end)

RegisterNetEvent("csskrouble:toggleSpeedo", function(b) 
    SendNUIMessage({
        type = "SWITCH_SPEEDO",
        bool = b
    })
end)

-- Show/Hide Radar
radardisplayed = true
CreateThread(function()
    while true do
        Wait(400)
        if hudhidden then
            radardisplayed = false
            TriggerEvent("csskrouble:hideHud", false)
            DisplayRadar(0)
        else 
            if IsPedInAnyVehicle(PlayerPedId()) or exports["gcphone"]:getMenuIsOpen() then
                radardisplayed = true
                TriggerEvent("csskrouble:hideHud", true)
                DisplayRadar(1)
            else
                radardisplayed = false
                TriggerEvent("csskrouble:hideHud", false)
                DisplayRadar(0)
            end  
        end     
    end
end)

RegisterNUICallback("sethud", function(data, cb)
    --[[TriggerEvent("csskrouble:changeHud", true)]]
    cb({})
end)

function RadarShown()
    return radardisplayed
end

function toboolean(str)
    local bool = false
    if str == "true" then
        bool = true
    end
    return bool
end


-- MiniMap
RegisterNetEvent("route68:kino", function() 
    handleCam()
end)
RegisterNetEvent("route68:kino2", function() 
    handleCam()
end)

hudhidden = false
function handleCam() 
    hudhidden = not hudhidden
    SendNUIMessage({type="SWITCH_DISPLAY"})
end
-- Status hud update

Citizen.CreateThread(function() 
    while true do
            Wait(875)
            local armor = GetPedArmour(PlayerPedId())
            local hp = GetEntityHealth(PlayerPedId()) - 100
            SendNUIMessage({
                type = 'UPDATE_HUD',
                armor = armor,
                nurkowanie = GetPlayerUnderwaterTimeRemaining(PlayerId())*10,
                inwater = IsPedSwimmingUnderWater(PlayerPedId()),
                zycie = hp,
                isdead = hp <= 0
            })      
    end
end)

RegisterCommand("hudsettings", function(src, args, raw)
        SetNuiFocus(true, true)
        SendNUIMessage({
            type = "OPEN_SETTINGS"
        })
end, false)

RegisterCommand("fixcursor", function(src,args,raw) 
    SetNuiFocus(false, false)
end)

RegisterNUICallback("NUIFocusOff", function(data,cb) 
    SetNuiFocus(false, false)
    cb({})
end)

CreateThread(function()
    while true do
            Wait(1000)

            TriggerEvent('esx_status:getStatus', 'hunger', function(status)
                hunger = status.getPercent()
            end)
            TriggerEvent('esx_status:getStatus', 'thirst', function(status)
                thirst = status.getPercent()
            end)

            SendNUIMessage({
                type = 'UPDATE_HUD',
                hunger = hunger,
                thirst = thirst,
            }) 
    end
end)

CreateThread(function() 
    while true do
        Wait(180000)
        TriggerEvent('esx_status:getStatus', 'hunger', function(status)
            hunger = status.getPercent()
        end)
        TriggerEvent('esx_status:getStatus', 'thirst', function(status)
            thirst = status.getPercent()
        end)
        if hunger < 10 and thirst < 10 then
            ESX.ShowNotification("~r~Zostało Ci poniżej 10% jedzenia i picia!")
        elseif hunger < 10 then
            ESX.ShowNotification("~r~Zostało Ci poniżej 10% jedzenia!")
        elseif thirst < 10 then
            ESX.ShowNotification("~r~Zostało Ci poniżej 10% picia!")
        end    
    end    
end)




-- voice

function GetProximity(proximity)
    for k,v in pairs(Config.proximityModes) do
        if v[1] == proximity then
            return v[2]
        end
    end
    return 0
end

CreateThread(function()
    while true do
            Wait(333)
            local state = NetworkIsPlayerTalking(PlayerId())
            local mode = Player(GetPlayerServerId(PlayerId())).state.proximity.mode
            SendNUIMessage({
                type = 'UPDATE_VOICE',
                isTalking = state,
                mode = mode
            })
    end
end)

-- toggle hud

RegisterNetEvent("csskrouble:changeHud", function(mode) 
    newhud = mode
    SendNUIMessage({type="SWITCH_VISIBILITY", bool=mode})
    if not mode then
        CreateThread(function()
            Wait(1500)
            SetRadarBigmapEnabled(true, false)
            Wait(0)
            SetRadarBigmapEnabled(false, false)
        end)
    end    
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerData)
    SendNUIMessage({
        type = 'TOGGLE_HUD'
    })
end)

RegisterCommand('togglehud', function()
    SendNUIMessage({
        type = 'TOGGLE_HUD'
    })
end, false)

RegisterKeyMapping('togglehud', 'Toggle Hud', 'mouse_button', 'MOUSE_MIDDLE')

RegisterCommand("minimapfix", function(src, args, raw) 
    local minimap = RequestScaleformMovie("minimap")
    SetRadarBigmapEnabled(true, false)
    Wait(0)
    SetRadarBigmapEnabled(false, false)
end)



-- hud settings



--[[ Stary HUD ]]
--[[function GetStreetsCustom(coords)
	local s1, s2 = Citizen.InvokeNative(0x2EB41072B4C1E4C0, coords.x, coords.y, coords.z, Citizen.PointerValueInt(), Citizen.PointerValueInt())
	local street1, street2 = GetStreetNameFromHashKey(s1), GetStreetNameFromHashKey(s2)
	return "~y~" .. street1 .. (street2 ~= "" and "~s~ / " .. street2 or "")
end

local RPM = 0
local RPMTime = GetGameTimer()
local Status = true

AddEventHandler('carhud:display', function(status)
	Status = status
end)

local Ped = {
	Vehicle = nil,
	VehicleClass = nil,
	VehicleStopped = true,
	VehicleEngine = false,
	VehicleGear = nil
}

local CruiseControl = false
CreateThread(function()
	while true do
		Citizen.Wait(255)
        if not newhud then
            CruiseControl = exports['esx_cruisecontrol']:IsEnabled()
            if Status and not exports['esx_policejob']:IsCuffed() then
                local ped = PlayerPedId()
                if IsPedInAnyVehicle(ped, false) then
                    Ped.Vehicle = GetVehiclePedIsIn(ped, false)
                    Ped.VehicleClass = GetVehicleClass(Ped.Vehicle)
                    Ped.VehicleStopped = IsVehicleStopped(Ped.Vehicle)
                    Ped.VehicleEngine = GetIsVehicleEngineRunning(Ped.Vehicle)
                    Ped.VehicleGear = GetVehicleCurrentGear(Ped.Vehicle)	
                else
                    Ped.Vehicle = nil
                end
            else
                Ped.Vehicle = nil
            end
        else
            Wait(1000)
        end
	end
end)
CreateThread(function()
	while true do
		Wait(0)
		if not newhud and showlabels then
			if Ped.Vehicle then
				local Gear = Ped.VehicleGear
				if not Ped.VehicleEngine then
					Gear = 'P'
				elseif Ped.VehicleStopped then
					Gear = 'N'
				elseif Ped.VehicleClass == 15 or Ped.VehicleClass == 16 then
					Gear = 'F'
				elseif Ped.VehicleClass == 14 then
					Gear = 'S'
				elseif Gear == 0 then
					Gear = 'R'
				end

				local RPMScale = 0
				if (Ped.VehicleClass >= 0 and Ped.VehicleClass <= 5) or (Ped.VehicleClass >= 9 and Ped.VehicleClass <= 12) or Ped.VehicleClass == 17 or Ped.VehicleClass == 18 or Ped.VehicleClass == 20 then
					RPMScale = 7000
				elseif Ped.VehicleClass == 6 then
					RPMScale = 7500
				elseif Ped.VehicleClass == 7 then
					RPMScale = 8000
				elseif Ped.VehicleClass == 8 then
					RPMScale = 11000
				elseif Ped.VehicleClass == 15 or Ped.VehicleClass == 16 then
					RPMScale = -1
				end

				local Speed = math.floor(GetEntitySpeed(Ped.Vehicle) * 3.6 + 0.5)
				if RPMTime <= GetGameTimer() then
					local r = GetVehicleCurrentRpm(Ped.Vehicle)
					if not Ped.VehicleEngine then
						r = 0
					elseif r > 0.99 then
						r = r * 100
						r = r + math.random(-2,2)

						r = r / 100
						if r < 0.12 then
							r = 0.12
						end
					else
						r = r - 0.1
					end

					RPM = math.floor(RPMScale * r + 0.5)
					if RPM < 0 then
						RPM = 0
					elseif Speed == 0.0 and r ~= 0 then
						RPM = math.random(RPM, (RPM + 50))
					end

					RPM = math.floor(RPM / 10) * 10
					RPMTime = GetGameTimer() + 50
				end

				local UI = { x = 0.0, y = 0.0 }
				if RPMScale > 0 then
					drawRct(UI.x + 0.1135, 	UI.y + 0.804, 0.042,0.026,0,0,0,100)
					drawTxt(UI.x + 0.6137, 	UI.y + 1.296, 1.0,1.0,0.45 , "~" .. (RPM > (RPMScale - 1000) and "r" or "w") .. "~" .. RPM, 255, 255, 255, 255)
					drawTxt(UI.x + 0.635, 	UI.y + 1.3, 1.0,1.0,0.35, "~w~rpm/~y~" .. Gear, 255, 255, 255, 255)
				else
					drawRct(UI.x + 0.1135, 	UI.y + 0.804, 0.042,0.026,0,0,0,100)
					local coords = GetEntityCoords(Ped.Vehicle, false)
					drawTxt(UI.x + 0.6137, 	UI.y + 1.296, 1.0,1.0,0.45, math.floor(coords.z), 255, 255, 255, 255)
					drawTxt(UI.x + 0.635, 	UI.y + 1.3, 1.0,1.0,0.35, "mnpm", 255, 255, 255, 255)
				end

				drawRct(UI.x + 0.1195, 	UI.y + 0.938, 0.036,0.03,0,0,0,100)
				drawTxt(UI.x + 0.62, 	UI.y + 1.431, 1.0,1.0,0.5 , "~" .. (CruiseControl and "b" or "w") .. "~" .. Speed, 255, 255, 255, 255)
				drawTxt(UI.x + 0.637, 	UI.y + 1.438, 1.0,1.0,0.35, "~" .. (Speed > 85 and (Speed > 155 and "r" or "y") or "w") .. "~km/h", 255, 255, 255, 255)
			else
				Wait(255)
			end
		else
			Wait(1500)
		end	
	end
end)

function drawTxt(x, y, width, height, scale, text, r, g, b, a)
    SetTextFont(4)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(2, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()

    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - width / 2, y - height / 2 + 0.005)
end

function drawRct(x, y, width, height, r, g, b, a)
	DrawRect(x + width / 2, y + height / 2, width, height, r, g, b, a)
end]]

