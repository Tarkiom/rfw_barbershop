local BarberShop = {
    vector3(-814.3, -183.8, 36.6),
	vector3(136.8, -1708.4, 29.3),
	vector3(-1282.6, -1116.8, 6.0),
	vector3(1931.5, 3729.7, 31.8),
	vector3(1212.8, -472.9, 65.2),
	vector3(-32.9, -152.3, 56.1),
	vector3(-278.1, 6228.5, 30.7)
    }

local Opti = {}

for k,v in pairs(BarberShop) do
    RegisterActionZone({name = "BarberShop", pos = v}, "[~b~E~w~]~w~ Pour acceder au barber", function()
        OpenBarberShop()
        FreezeEntityPosition(GetPlayerPed(-1), true)
        SetEntityInvincible(PlayerPedId(), true)
        DrawMissionText("~g~Invincible",2500)
    end)
end

Citizen.CreateThread(function()
	for k,v in ipairs(BarberShop) do
		local blip = AddBlipForCoord(v)

		SetBlipSprite (blip, 71)
		SetBlipColour (blip, 51)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName('STRING')
		AddTextComponentSubstringPlayerName('Barber Shop')
		EndTextCommandSetBlipName(blip)
	end
end)

function unloadBarberShop()
    UnregisterActionZone("BarberShop")
end

local open = false
RMenu.Add('core', 'barbershop', RageUI.CreateMenu("Barber Shop", "~b~Barber Shop"))
RMenu:Get('core', 'barbershop').Closed = function()   
    FreezeEntityPosition(GetPlayerPed(-1), false)
    SetEntityInvincible(PlayerPedId(), false)
    DrawMissionText("~r~Invincibilité désactivé.", 2500)
    open = false
end;

RMenu.Add('core', "tenues_create", RageUI.CreateSubMenu(RMenu:Get('core', 'barbershop'), "Barber Shop", "~b~Barber Shop"))
RMenu:Get('core', "tenues_create").Closed = function()
end;

RMenu.Add('core', "tenues", RageUI.CreateSubMenu(RMenu:Get('core', 'barbershop'), "Barber Shop", "~b~Barber Shop"))
RMenu:Get('core', "tenues").Closed = function()
end;



local hair = {}
function GetClothValues()
    local playerPed = PlayerPedId()
    local _hair = {                                                                             
        {price = 24, label = "Coupe de cheuveux", r = "hair_color_1",        item = "hair_1", 	max = GetNumberOfPedDrawableVariations		(playerPed, 2) - 1,	 min = 0,},
        {price = 12, label = "Couleur des cheuveux",   o = "hair_1",  		item = "hair_color_1", 	      max = GetNumHairColors()-1 ,  min = 0,},
      {price = 12, label = "Couleur des cheveux secondaire",       o = "hair_color_2",  		item = "hair_color_2", 	      max = GetNumHairColors()-1, min = 0,},
     {price = 12, label = "Taille de la barbe",        o = "beard_2",  		item = "beard_2", 	     max = 10,           min = 0,},   
     {price = 24, label = "Type de barbe", r = "beard_1",        item = "beard_1", 	max = GetNumHeadOverlayValues(1)-1,	 min = 0,},
     {price = 24, label = "Couleur de la barbe", r = "beard_3",        item = "beard_3", 	max = GetNumHairColors()-1,	 min = 0,},
     {price = 12, label = "Taille des sourcils",        o = "eyebrows_2",  		item = "eyebrows_2", 	     max = 10,         min = 0,},   
     {price = 12, label = "Type  des sourcils",        o = "eyebrows_1",  		item = "eyebrows_1", 	     max = GetNumHeadOverlayValues(2)-1,       min = 0,},   
     {price = 12, label = "Couleur des sourcils",        o = "eyebrows_3",  		item = "eyebrows_3", 	     max = GetNumHairColors()-1,       min = 0,},   

    }
        hair = _hair
end

Citizen.CreateThread(function()
    GetClothValues()
    for k,v in pairs(hair) do
        RMenu.Add('core', v.item.."1", RageUI.CreateSubMenu(RMenu:Get('core', 'tenues_create'), "Barbershop", "~b~Barber shop."))
        RMenu:Get('core', v.item.."1").Closed = function()
        end
    end
end)


function OpenBarberShop()
    hasPaid = false
    RageUI.Visible(RMenu:Get('core', 'barbershop'), not RageUI.Visible(RMenu:Get('core', 'barbershop')))
    OpenBarberShopThread()
    GetClothValues()
end


function OpenBarberShopThread()
    if open then return end
    Citizen.CreateThread(function()
        open = true
        while open do
            if IsControlJustReleased(1, 22) then
                ClearPedTasks(GetPlayerPed(-1))
                local coords = GetOffsetFromEntityInWorldCoords(GetPlayerPed(-1), 0.0, -5.0, 0.0)
                TaskTurnPedToFaceCoord(GetPlayerPed(-1), coords, 3000)
            end

            Wait(1)

            RageUI.IsVisible(RMenu:Get('core', 'barbershop'), true, true, true, function()
                RageUI.ButtonWithStyle("Se relooker", nil, { RightLabel = "→→" }, true, function()
                end, RMenu:Get('core', 'tenues_create'))


            end, function()
            end)

            RageUI.IsVisible(RMenu:Get('core', 'tenues_create'), true, true, true, function()  
                for k,v in pairs(hair) do
                   RageUI.ButtonWithStyle(v.label, nil, { RightLabel = "→→" }, true, function(_,_,s)
                        if s then
                        end
                    end, RMenu:Get('core', v.item.."1"))
                end

            end, function()
            end)

            for k,v in pairs(hair) do
                RageUI.IsVisible(RMenu:Get('core', v.item.."1"), true, true, true, function()
                    RageUI.ButtonWithStyle("Faire tourner son personnage.", nil, {}, true, function(_,_,s)
                        if s then
                            ClearPedTasks(GetPlayerPed(-1))
                            local pos = GetOffsetFromEntityInWorldCoords(GetPlayerPed(-1), 0.0, -5.0, 0.0)
                            TaskTurnPedToFaceCoord(GetPlayerPed(-1), pos, 3000)
                            FreezeEntityPosition(GetPlayerPed(-1), false)
                            Wait(1500)
                            FreezeEntityPosition(GetPlayerPed(-1), true)                       
                        end
                    end)
                    if v.c ~= nil then
                        for i = v.min, GetNumberOfPedTextureVariations(GetPlayerPed(-1), v.c, value) - 1 do
                            if Opti[k] == nil then Opti[k] = i end
                            RageUI.ButtonWithStyle(v.label.." "..i, nil, { RightLabel = "→→ Acheter ~r~"..v.price.."~s~ $" },  true , function(_,h,s)
                                print(v.label)
                                if s then
                                    TriggerEvent("skinchanger:getSkin", function(skin)
                                        TriggerServerEvent("creator:SaveSkin", skin , identity)
                                    end)
                                    local id = GetPlayerServerId(PlayerId())
                                    local rmv = v.price
                                   -- print(id)
                                    TriggerServerEvent("rFw:RemoveMoney", id , rmv)
                                    ShowNotification("Vous avez payer ~r~"..rmv.."~w~ $ .~g~ Merci de votre confiance !")
                                end
                               if h then
                                    if Opti[k] ~= i then
                                        TriggerEvent("skinchanger:change", v.item, i)
                                        Opti[k] = i
                                    end
                               end
                            end) 
                        end
                    else
                        for i = v.min, v.max do
                            if Opti[k] == nil then Opti[k] = i end
                            RageUI.ButtonWithStyle(v.label.." "..i, nil, { RightLabel = "→→ Acheter ~r~"..v.price.."~s~ $" },  true ,function(_,h,s)
                               if s then
                                TriggerEvent("skinchanger:getSkin", function(skin)
                                    TriggerServerEvent("creator:SaveSkin", skin)
                                end)
                                local id = GetPlayerServerId(PlayerId())
                                local rmv = v.price
                                TriggerServerEvent("rFw:RemoveMoney", id , rmv)
                                ShowNotification("Vous avez payer ~r~"..rmv.."~w~ $ .~g~ Merci de votre confiance !")
                               end
                               if h then
                                    if Opti[k] ~= i then
                                        TriggerEvent("skinchanger:change", v.item, i)                     
                                        Opti[k] = i
                                    end
                               end
                            end) 
                        end
                    end
                end, function()

                end)
            end
        end
    end)
end

Citizen.CreateThread(function()
    local hash = GetHashKey("s_f_m_fembarber")
    while not HasModelLoaded(hash) do
    RequestModel(hash)
    Wait(20)
    end
    ped = CreatePed("PED_TYPE_CIVFEMA", "s_f_m_fembarber", 134.851, -1707.744, 28.291, 137.203, true, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)
end)
