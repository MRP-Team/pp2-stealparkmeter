local QBCore = exports['qb-core']:GetCoreObject()
local stealedMeters = {}

local function PoliceCall()
  local chance = 75
  if GetClockHours() >= 1 and GetClockHours() <= 6 then
    chance = 50
  end
  if math.random(1, 100) <= chance then
    TriggerServerEvent('police:server:policeAlert', Lang:t("stealmeter.police_notification"))
    QBCore.Functions.Notify(Lang:t("stealmeter.police_notified"), 'error')
  end
end

local function startStealingMeter(entity)
  QBCore.Functions.Progressbar("stealingMeter", Lang:t("stealmeter.stealing_animation_label"), Config.extractTime, false, true, {
    disableMovement = true,
    disableCarMovement = true,
    disableMouse = false,
    disableCombat = true,
  }, {
    animDict = "mini@repair",
    anim = "fixing_a_player",
    flags = 49,
  }, {}, {}, function()
    if DoesEntityExist(entity) then
      local pos = GetEntityCoords(entity)
      local objectCoords = pos.x .. pos.y .. pos.z
      if not stealedMeters[objectCoords] then
        TriggerServerEvent("pp2-stealparkmeter:server:stealedmeter", objectCoords, pos)
        QBCore.Functions.Notify(Lang:t("stealmeter.meter_stolen"), "primary")
        if Config.policeCallInActionEnd then PoliceCall() end
      end
    end
  end, function()
    Lang:t("stealmeter.stealing_animation_canceled")
  end)
end

CreateThread(function()
  exports['qb-target']:AddTargetModel(
    Config.stealableModels, 
    {
      options = {
        {
          targeticon = 'fa-solid fa-screwdriver-wrench', 
          icon = "fas fa-mask",
          type = "client",
          action = function(entity)
            if IsPedAPlayer(entity) then return false end
            TriggerEvent('pp2-stealparkmeter:client:steal', entity)
          end,
          label = Lang:t("stealmeter.target_label"),
          item = Config.stealRequiredItem,
        }
      },
      distance = Config.meterDistance,
    }
  )
end)

RegisterNetEvent("pp2-stealparkmeter:client:steal", function(entity)
  local pos = GetEntityCoords(entity)
  local objectCoords = pos.x .. pos.y .. pos.z
	QBCore.Functions.TriggerCallback('pp2-stealparkmeter:server:getmeter', function(occupied)
		if occupied then
			QBCore.Functions.Notify(Lang:t("stealmeter.already_stolen_error"), 'error')
		else
      if Config.policeCallInActionStart then PoliceCall() end
      exports['ps-ui']:Circle(function(success)
        if success then
          startStealingMeter(entity)
        end
        if not success then
          if Config.policeCallInActionFail then PoliceCall() end
          QBCore.Functions.Notify(Lang:t("stealmeter.messed_up_error"), 'error')
        end
      end, 5, 20)
		end
	end, objectCoords)
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
  TriggerServerEvent('pp2-stealparkmeter:server:playerSpawned')
end)

RegisterNetEvent('pp2-stealparkmeter:client:reloadStealedMeters', function(s)
  stealedMeters = s
end)

Citizen.CreateThread(function ()
  while true do
    Citizen.Wait(0)
    for entityId, entityPos in pairs(stealedMeters) do
      DrawMarker(20, entityPos.x, entityPos.y, entityPos.z+2.0, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 1.0, 1.0, 1.0, 255, 0, 0, 50, 1, 1, 2, 0, 0)	
    end
  end
end)
