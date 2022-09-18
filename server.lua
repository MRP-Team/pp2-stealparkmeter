local QBCore = exports['qb-core']:GetCoreObject()
local boxStolen = {}

local function giveStealedMoneyToPlayer()
  local src = source
  local Player = QBCore.Functions.GetPlayer(src)
  local info = {
      worth = math.random(Config.MinMarkedMoneyWorth, Config.MaxMarkedMoneyWorth)
  }
  Player.Functions.AddItem('markedbills', 1, false, info)
  TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['markedbills'], "add")
end

RegisterServerEvent('pp2-stealparkmeter:server:stealedmeter', function(objectCoords)
	boxStolen[objectCoords] = true
  giveStealedMoneyToPlayer()
end)

QBCore.Functions.CreateCallback('pp2-stealparkmeter:server:getmeter', function(source, cb, objectCoords)
  local objectCoords = objectCoords
	cb(boxStolen[objectCoords])
end)
