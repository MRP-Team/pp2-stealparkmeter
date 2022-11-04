local QBCore = exports['qb-core']:GetCoreObject()
local boxStolen = {}

local function giveStealedMoneyToPlayer(objectCoords)
  local src = source
  local Player = QBCore.Functions.GetPlayer(src)
  local stealedAmount = math.random(Config.MinMoneyWorth, Config.MaxMoneyWorth)
  Player.Functions.AddMoney('cash', stealedAmount, 'stealed parkmeter ' .. objectCoords);
end

RegisterServerEvent('pp2-stealparkmeter:server:stealedmeter', function(objectCoords, pos)
	boxStolen[objectCoords] = pos
  giveStealedMoneyToPlayer(objectCoords)
  TriggerClientEvent('pp2-stealparkmeter:client:reloadStealedMeters', -1, boxStolen)

  CreateThread(function()
    Wait(Config.cooldownTimer)
    boxStolen[objectCoords] = nil
    TriggerClientEvent('pp2-stealparkmeter:client:reloadStealedMeters', -1, boxStolen)
  end)
end)

RegisterServerEvent('pp2-stealparkmeter:server:playerSpawned', function()
  local src = source
  TriggerClientEvent('pp2-stealparkmeter:client:reloadStealedMeters', src, boxStolen)
end)

QBCore.Functions.CreateCallback('pp2-stealparkmeter:server:getmeter', function(source, cb, objectCoords)
  local objectCoords = objectCoords
	cb(boxStolen[objectCoords])
end)
