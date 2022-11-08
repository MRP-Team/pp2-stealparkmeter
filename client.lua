local QBCore = exports['qb-core']:GetCoreObject()
local stealedMeters = {}
local CurrentCops = 0

RegisterNetEvent('police:SetCopCount')
AddEventHandler('police:SetCopCount', function(amount)
    CurrentCops = amount
end)

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

local function RemoveMeterFromScene(entity)
  NetworkRegisterEntityAsNetworked(entity)
  Wait(100)
  NetworkRequestControlOfEntity(entity)
  SetEntityAsMissionEntity(entity)
  Wait(100)
  DeleteEntity(entity)
end

function makeEntityFaceEntity(entity1, entity2)
  local p1 = GetEntityCoords(entity1, true)
  local p2 = GetEntityCoords(entity2, true)

  local dx = p2.x - p1.x
  local dy = p2.y - p1.y

  local heading = GetHeadingFromVector_2d(dx, dy)
  SetEntityHeading(entity1, heading)
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
    Config.parkMeterModels,
    {
      options = {
        {
          targeticon = 'fa-solid fa-screwdriver-wrench',
          icon = "fas fa-sack-dollar",
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
    local ped = PlayerPedId()
    makeEntityFaceEntity(ped, entity)
    Citizen.Wait(1000)
		if occupied then
			QBCore.Functions.Notify(Lang:t("stealmeter.already_stolen_error"), 'error')
    elseif CurrentCops < Config.requiredCopsCount then
			QBCore.Functions.Notify(Lang:t("stealmeter.not_enough_cops"), 'error')
		else
      ClearPedTasks(ped)
      local animDict = "mini@repair"
      local animName = "fixing_a_player"
      RequestAnimDict(animDict)
      while not HasAnimDictLoaded(animDict) do
        Citizen.Wait(100)
      end
      TaskPlayAnim(ped, animDict, animName, 1.0, 1.0, 1.0, 1, 0.0, 0, 0, 0)
      TriggerServerEvent('hud:server:GainStress', math.random(Config.MinStress, Config.MaxStress)) -- Gain stress.
      if Config.policeCallInActionStart then PoliceCall() end
      TriggerEvent('qb-lockpick:client:openLockpick', function(success)
        ClearPedTasks(ped)
        if success then
          startStealingMeter(entity)
        else
          local chance = math.random(1, 100)
          if chance <= Config.RemoveRequiredItemChance then
            TriggerServerEvent("pp2-stealparkmeter:server:breakRequiredItem")
          end
          if Config.policeCallInActionFail then PoliceCall() end
          QBCore.Functions.Notify(Lang:t("stealmeter.messed_up_error"), 'error')
        end
      end)
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
    if Config.parkMeterRemoveOnSteal then
      Citizen.Wait(1000)
    else
      Citizen.Wait(0)
    end
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    for entityId, entityPos in pairs(stealedMeters) do
      if entityPos and #(coords - entityPos) < Config.parkMeterRemoveDistance then
        if Config.parkMeterRemoveOnSteal then
          for i = 1, #Config.parkMeterModels do
            local parkMeter = GetClosestObjectOfType(entityPos.x, entityPos.y, entityPos.z, 0.75, Config.parkMeterModels[i], false, false, false)
            if DoesEntityExist(parkMeter) then
              RemoveMeterFromScene(parkMeter)
            end
          end
        else
          DrawMarker(5, entityPos.x, entityPos.y, entityPos.z+1.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 255, 0, 0, 50, 0, 1, 2, 0, 0)
        end
      end
    end
  end
end)
